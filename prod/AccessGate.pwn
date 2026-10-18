/*
	AccessGate v6
	- MySQL как у EuroSystem (тот же ini + dual mysql_connect)
	- ключ 30 дней, даты y/m/d (2038-safe)
	- код на спавне
*/
#include <a_samp>
#include <a_mysql>

#define FILTERSCRIPT

#define MYSQL_FILE         "bykranin_mysql_settings.ini"
#define AG_DAYS            30
#define AG_DLG             41710
#define AG_DELAY           10000
#define AG_MAX_TRIES       5

new MySQL:AG_SQL = MySQL:0;
new bool:AG_SQLOk;
new AG_Host[64], AG_User[64], AG_Pass[64], AG_DB[64];

new AG_Acc[MAX_PLAYERS];
new bool:AG_Ok[MAX_PLAYERS];
new bool:AG_Need[MAX_PLAYERS];
new AG_Tries[MAX_PLAYERS];
new bool:AG_DlgOpen[MAX_PLAYERS];
new AG_Cancel[MAX_PLAYERS];
new AG_Code[MAX_PLAYERS][16];
new AG_Uy[MAX_PLAYERS], AG_Um[MAX_PLAYERS], AG_Ud[MAX_PLAYERS];
new AG_Nick[MAX_PLAYERS][MAX_PLAYER_NAME];
new AG_Tmr[MAX_PLAYERS];

stock trim(str[])
{
	new len = strlen(str);
	while(len > 0 && str[len - 1] <= ' ') str[--len] = 0;
	new s;
	while(str[s] && str[s] <= ' ') s++;
	if(s) strdel(str, 0, s);
}

stock AG_DaysInMonth(y, m)
{
	static const dim[] = {0,31,28,31,30,31,30,31,31,30,31,30,31};
	if(m == 2) return ((y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)) ? 29 : 28;
	if(m < 1 || m > 12) return 30;
	return dim[m];
}

stock AG_AddDays(y, m, d, add, &ny, &nm, &nd)
{
	ny = y; nm = m; nd = d;
	new left = add;
	while(left > 0)
	{
		new dim = AG_DaysInMonth(ny, nm);
		new room = dim - nd;
		if(left <= room) { nd += left; left = 0; }
		else { left -= (room + 1); nd = 1; nm++; if(nm > 12) { nm = 1; ny++; } }
	}
}

stock bool:AG_DatePassed(ey, em, ed)
{
	new y, m, d;
	getdate(y, m, d);
	if(y > ey) return true;
	if(y < ey) return false;
	if(m > em) return true;
	if(m < em) return false;
	return (d >= ed);
}

stock AG_DaysLeft(ey, em, ed)
{
	new y, m, d, days;
	getdate(y, m, d);
	if(AG_DatePassed(ey, em, ed)) return 0;
	while(y < ey || (y == ey && m < em) || (y == ey && m == em && d < ed))
	{
		d++; days++;
		if(d > AG_DaysInMonth(y, m)) { d = 1; m++; }
		if(m > 12) { m = 1; y++; }
		if(days > 400) break;
	}
	return days;
}

stock AG_LoadIni()
{
	format(AG_Host, sizeof AG_Host, "127.0.0.1");
	AG_User[0] = AG_Pass[0] = AG_DB[0] = 0;
	if(!fexist(MYSQL_FILE))
	{
		print("[AccessGate] нет ini bykranin_mysql_settings.ini");
		return 0;
	}
	new File:f = fopen(MYSQL_FILE, io_read), line[256];
	if(!f) return 0;
	while(fread(f, line))
	{
		for(new i; line[i]; i++) if(line[i] == '\r' || line[i] == '\n') { line[i] = 0; break; }
		trim(line);
		if(!line[0] || line[0] == ';' || line[0] == '#' || line[0] == '[') continue;
		new eq = strfind(line, "="); if(eq < 1) continue;
		new key[64], val[128];
		strmid(key, line, 0, eq); strmid(val, line, eq + 1, strlen(line));
		trim(key); trim(val);
		if(!strcmp(key, "host", true) || !strcmp(key, "hostname", true) || !strcmp(key, "server", true))
			format(AG_Host, sizeof AG_Host, "%s", val);
		else if(!strcmp(key, "username", true) || !strcmp(key, "user", true) || !strcmp(key, "login", true))
			format(AG_User, sizeof AG_User, "%s", val);
		else if(!strcmp(key, "password", true) || !strcmp(key, "pass", true))
			format(AG_Pass, sizeof AG_Pass, "%s", val);
		else if(!strcmp(key, "database", true) || !strcmp(key, "db", true) || !strcmp(key, "dbname", true))
			format(AG_DB, sizeof AG_DB, "%s", val);
	}
	fclose(f);
	printf("[AccessGate] ini %s@%s / %s", AG_User, AG_Host, AG_DB);
	return (AG_User[0] && AG_DB[0]);
}

stock AG_ConnectSQL()
{
	// как EuroSystem: два порядка аргументов
	AG_SQL = mysql_connect(AG_Host, AG_User, AG_DB, AG_Pass);
	if(AG_SQL && mysql_errno(AG_SQL) == 0) return 1;
	AG_SQL = mysql_connect(AG_Host, AG_User, AG_Pass, AG_DB);
	if(AG_SQL && mysql_errno(AG_SQL) == 0) return 1;
	printf("[AccessGate] MySQL FAIL errno=%d", mysql_errno(AG_SQL));
	return 0;
}

stock AG_Gen(dest[])
{
	static const c[] = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
	for(new i; i < 8; i++) dest[i] = c[random(sizeof(c) - 1)];
	dest[8] = 0;
}

public OnFilterScriptInit()
{
	print("[AccessGate] v6 load...");
	AG_SQLOk = false;
	if(AG_LoadIni() && AG_ConnectSQL())
	{
		AG_SQLOk = true;
		mysql_tquery(AG_SQL, "ALTER TABLE `accounts` ADD COLUMN `access_code` VARCHAR(16) NOT NULL DEFAULT ''");
		mysql_tquery(AG_SQL, "ALTER TABLE `accounts` ADD COLUMN `access_ok` TINYINT NOT NULL DEFAULT 0");
		mysql_tquery(AG_SQL, "ALTER TABLE `accounts` ADD COLUMN `access_until_y` INT NOT NULL DEFAULT 0");
		mysql_tquery(AG_SQL, "ALTER TABLE `accounts` ADD COLUMN `access_until_m` INT NOT NULL DEFAULT 0");
		mysql_tquery(AG_SQL, "ALTER TABLE `accounts` ADD COLUMN `access_until_d` INT NOT NULL DEFAULT 0");
		print("[AccessGate] MySQL OK");
	}
	else print("[AccessGate] MySQL не подключен");
	SetTimer("AG_Pulse", 5000, true);
	print("[AccessGate] v6 ready");
	return 1;
}

public OnFilterScriptExit()
{
	if(AG_SQLOk) mysql_close(AG_SQL);
	return 1;
}

public OnPlayerConnect(playerid)
{
	AG_Acc[playerid] = 0;
	AG_Ok[playerid] = false;
	AG_Need[playerid] = false;
	AG_Tries[playerid] = 0;
	AG_DlgOpen[playerid] = false;
	AG_Cancel[playerid] = 0;
	AG_Uy[playerid] = AG_Um[playerid] = AG_Ud[playerid] = 0;
	AG_Code[playerid][0] = 0;
	GetPlayerName(playerid, AG_Nick[playerid], MAX_PLAYER_NAME);
	if(AG_Tmr[playerid]) KillTimer(AG_Tmr[playerid]);
	AG_Tmr[playerid] = SetTimerEx("AG_Load", AG_DELAY, false, "i", playerid);
	printf("[AccessGate] connect %s", AG_Nick[playerid]);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if(AG_Tmr[playerid]) { KillTimer(AG_Tmr[playerid]); AG_Tmr[playerid] = 0; }
	AG_Ok[playerid] = false;
	AG_Need[playerid] = false;
	return 1;
}

forward AG_Load(playerid);
public AG_Load(playerid)
{
	AG_Tmr[playerid] = 0;
	if(!IsPlayerConnected(playerid) || AG_Ok[playerid]) return 1;
	if(!AG_SQLOk)
	{
		print("[AccessGate] нет SQL при проверке");
		AG_Need[playerid] = true;
		AG_ShowKey(playerid);
		return 1;
	}
	new q[280];
	mysql_format(AG_SQL, q, sizeof q,
		"SELECT `id`, `access_ok`, `access_code`, `access_until_y`, `access_until_m`, `access_until_d` FROM `accounts` WHERE `name`='%e' LIMIT 1",
		AG_Nick[playerid]);
	mysql_tquery(AG_SQL, q, "AG_OnLoad", "i", playerid);
	return 1;
}

forward AG_OnLoad(playerid);
public AG_OnLoad(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(AG_SQL);
	printf("[AccessGate] load %s rows=%d", AG_Nick[playerid], rows);
	if(rows < 1)
	{
		AG_Tmr[playerid] = SetTimerEx("AG_Load", 4000, false, "i", playerid);
		return 1;
	}

	AG_Acc[playerid] = cache_get_row_int(0, 0, AG_SQL);
	new aok = cache_get_row_int(0, 1, AG_SQL);
	cache_get_row(0, 2, AG_Code[playerid], AG_SQL, 16);
	AG_Uy[playerid] = cache_get_row_int(0, 3, AG_SQL);
	AG_Um[playerid] = cache_get_row_int(0, 4, AG_SQL);
	AG_Ud[playerid] = cache_get_row_int(0, 5, AG_SQL);

	if(aok == 1 && AG_Uy[playerid] > 0 && AG_DatePassed(AG_Uy[playerid], AG_Um[playerid], AG_Ud[playerid]))
	{
		aok = 0;
		AG_Gen(AG_Code[playerid]);
		AG_Uy[playerid] = AG_Um[playerid] = AG_Ud[playerid] = 0;
		new q[280];
		mysql_format(AG_SQL, q, sizeof q,
			"UPDATE `accounts` SET `access_ok`=0, `access_code`='%e', `access_until_y`=0, `access_until_m`=0, `access_until_d`=0 WHERE `id`=%d LIMIT 1",
			AG_Code[playerid], AG_Acc[playerid]);
		mysql_tquery(AG_SQL, q);
		SendClientMessage(playerid, 0xFF4444FF, "[Access] Срок ключа 30 дней истёк. Нужен новый код.");
	}

	if(aok == 1 && AG_Uy[playerid] > 0 && !AG_DatePassed(AG_Uy[playerid], AG_Um[playerid], AG_Ud[playerid]))
	{
		AG_Ok[playerid] = true;
		AG_Need[playerid] = false;
		TogglePlayerControllable(playerid, 1);
		new left = AG_DaysLeft(AG_Uy[playerid], AG_Um[playerid], AG_Ud[playerid]);
		new str[100];
		format(str, sizeof str, "[Access] Доступ до %02d.%02d.%04d (осталось ~%d дн.).", AG_Ud[playerid], AG_Um[playerid], AG_Uy[playerid], left);
		SendClientMessage(playerid, 0x00FF88FF, str);
		return 1;
	}

	if(AG_Code[playerid][0] == '\0')
	{
		AG_Gen(AG_Code[playerid]);
		new q[160];
		mysql_format(AG_SQL, q, sizeof q,
			"UPDATE `accounts` SET `access_code`='%e', `access_ok`=0 WHERE `id`=%d LIMIT 1",
			AG_Code[playerid], AG_Acc[playerid]);
		mysql_tquery(AG_SQL, q);
		printf("[AccessGate] NEW CODE %s = %s", AG_Nick[playerid], AG_Code[playerid]);
	}

	AG_Need[playerid] = true;
	AG_ShowKey(playerid);
	return 1;
}

stock AG_ShowKey(playerid)
{
	if(!IsPlayerConnected(playerid) || AG_Ok[playerid]) return 0;
	if(AG_DlgOpen[playerid]) return 1; // уже открыт — не сбрасывать ввод
	AG_Need[playerid] = true;
	AG_DlgOpen[playerid] = true;
	TogglePlayerControllable(playerid, 0);
	SendClientMessage(playerid, 0xFFD700FF, "=== ПЛАТНЫЙ ДОСТУП | 30 дней ===");
	SendClientMessage(playerid, 0xFFFFFFFF, "Сервер платный. Введи спецкод.");
	SendClientMessage(playerid, 0xFFD700FF, "750 руб | для друзей — бесплатно");
	SendClientMessage(playerid, 0x00BFFFFF, "Получить код: fillshow.t.me");
	SendClientMessage(playerid, 0xFFFFFFFF, "Ключ действует 30 дней, потом новый.");
	new body[320];
	format(body, sizeof body, "Введи спецкод\n\n750 руб | друзьям бесплатно\nTelegram: fillshow.t.me\n\nКлюч на 30 дней");
	ShowPlayerDialog(playerid, AG_DLG, DIALOG_STYLE_INPUT, "Спецкод", body, "Войти", "Выход");
	printf("[AccessGate] SHOW %s", AG_Nick[playerid]);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(AG_Ok[playerid]) return 1;
	if(AG_Need[playerid])
	{
		TogglePlayerControllable(playerid, 0);
		if(!AG_DlgOpen[playerid]) AG_ShowKey(playerid);
	}
	else if(AG_SQLOk && AG_Acc[playerid] == 0) AG_Load(playerid);
	return 1;
}

forward AG_Pulse();
public AG_Pulse()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i) || AG_Ok[i] || !AG_Need[i]) continue;
		TogglePlayerControllable(i, 0);
		// не трогать диалог, если игрок уже вводит код
		if(!AG_DlgOpen[i]) AG_ShowKey(i);
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	#pragma unused listitem
	if(dialogid != AG_DLG) return 0;

	AG_DlgOpen[playerid] = false;

	if(!response)
	{
		AG_Cancel[playerid]++;
		if(AG_Cancel[playerid] >= 3)
		{
			SendClientMessage(playerid, 0xFF4444FF, "Без кода вход запрещён.");
			SetTimerEx("AG_Kick", 1000, false, "i", playerid);
			return 1;
		}
		SendClientMessage(playerid, 0xFFAA00FF, "Нужен спецкод. Введи его в окне.");
		SetTimerEx("AG_ReShow", 1000, false, "i", playerid);
		return 1;
	}

	new code[32];
	format(code, sizeof code, "%s", inputtext);
	for(new i = strlen(code) - 1; i >= 0; i--) if(code[i] <= ' ') code[i] = 0; else break;

	if(strlen(code) < 4)
	{
		SendClientMessage(playerid, 0xFF4444FF, "Слишком короткий код.");
		SetTimerEx("AG_ReShow", 500, false, "i", playerid);
		return 1;
	}

	if(AG_Code[playerid][0] && !strcmp(code, AG_Code[playerid], true))
	{
		AG_Activate(playerid);
		return 1;
	}

	if(AG_SQLOk && AG_Acc[playerid] > 0)
	{
		new q[140];
		mysql_format(AG_SQL, q, sizeof q, "SELECT `access_code` FROM `accounts` WHERE `id`=%d LIMIT 1", AG_Acc[playerid]);
		mysql_tquery(AG_SQL, q, "AG_Chk", "is", playerid, code);
	}
	else
	{
		AG_Tries[playerid]++;
		SendClientMessage(playerid, 0xFF4444FF, "Неверный код.");
		if(AG_Tries[playerid] >= AG_MAX_TRIES)
			SetTimerEx("AG_Kick", 1000, false, "i", playerid);
		else
			SetTimerEx("AG_ReShow", 500, false, "i", playerid);
	}
	return 1;
}

forward AG_ReShow(playerid);
public AG_ReShow(playerid)
{
	if(!IsPlayerConnected(playerid) || AG_Ok[playerid]) return 1;
	AG_DlgOpen[playerid] = false;
	AG_ShowKey(playerid);
	return 1;
}

forward AG_Chk(playerid, code[]);
public AG_Chk(playerid, code[])
{
	if(!IsPlayerConnected(playerid)) return 1;
	new dbc[16];
	if(cache_get_row_count(AG_SQL) > 0) cache_get_row(0, 0, dbc, AG_SQL, sizeof dbc);
	if(dbc[0] && !strcmp(code, dbc, true))
	{
		format(AG_Code[playerid], 16, "%s", dbc);
		AG_Activate(playerid);
		return 1;
	}
	new q[300];
	mysql_format(AG_SQL, q, sizeof q,
		"SELECT `id`,`days` FROM `fun_codes` WHERE `code`='%e' AND `active`=1 AND `used`=0 AND `to_name`='%e' LIMIT 1",
		code, AG_Nick[playerid]);
	mysql_tquery(AG_SQL, q, "AG_ChkFun", "is", playerid, code);
	return 1;
}

forward AG_ChkFun(playerid, code[]);
public AG_ChkFun(playerid, code[])
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(cache_get_row_count(AG_SQL) < 1)
	{
		AG_Tries[playerid]++;
		SendClientMessage(playerid, 0xFF4444FF, "Nevernyy speckod.");
		if(AG_Tries[playerid] >= AG_MAX_TRIES)
			SetTimerEx("AG_Kick", 1000, false, "i", playerid);
		else
			SetTimerEx("AG_ReShow", 500, false, "i", playerid);
		return 1;
	}
	new fid = cache_get_row_int(0, 0, AG_SQL);
	new days = cache_get_row_int(0, 1, AG_SQL);
	if(days != 30 && days != 365) days = 30;

	new q[240];
	mysql_format(AG_SQL, q, sizeof q, "UPDATE `fun_codes` SET `used`=1, `to_acc`=%d WHERE `id`=%d LIMIT 1", AG_Acc[playerid], fid);
	mysql_tquery(AG_SQL, q);

	format(AG_Code[playerid], 16, "%s", code);
	AG_Ok[playerid] = true;
	AG_Need[playerid] = false;
	AG_DlgOpen[playerid] = false;
	TogglePlayerControllable(playerid, 1);
	new y, m, d, ey, em, ed;
	getdate(y, m, d);
	AG_AddDays(y, m, d, days, ey, em, ed);
	AG_Uy[playerid] = ey; AG_Um[playerid] = em; AG_Ud[playerid] = ed;
	if(AG_SQLOk && AG_Acc[playerid] > 0)
	{
		mysql_format(AG_SQL, q, sizeof q,
			"UPDATE `accounts` SET `access_ok`=1, `access_code`='%e', `access_until_y`=%d, `access_until_m`=%d, `access_until_d`=%d WHERE `id`=%d LIMIT 1",
			code, ey, em, ed, AG_Acc[playerid]);
		mysql_tquery(AG_SQL, q);
	}
	new str[100];
	format(str, sizeof str, "Kod prinyat! Do %02d.%02d.%04d (%d dn.)", ed, em, ey, days);
	SendClientMessage(playerid, 0x00FF88FF, str);
	printf("[AccessGate] FUN code OK %s days=%d", AG_Nick[playerid], days);
	return 1;
}

stock AG_Activate(playerid)
{
	AG_Ok[playerid] = true;
	AG_Need[playerid] = false;
	AG_DlgOpen[playerid] = false;
	TogglePlayerControllable(playerid, 1);
	new y, m, d, ey, em, ed;
	getdate(y, m, d);
	AG_AddDays(y, m, d, AG_DAYS, ey, em, ed);
	AG_Uy[playerid] = ey; AG_Um[playerid] = em; AG_Ud[playerid] = ed;
	if(AG_SQLOk && AG_Acc[playerid] > 0)
	{
		new q[220];
		mysql_format(AG_SQL, q, sizeof q,
			"UPDATE `accounts` SET `access_ok`=1, `access_until_y`=%d, `access_until_m`=%d, `access_until_d`=%d WHERE `id`=%d LIMIT 1",
			ey, em, ed, AG_Acc[playerid]);
		mysql_tquery(AG_SQL, q);
	}
	new str[96];
	format(str, sizeof str, "Код принят! Доступ до %02d.%02d.%04d", ed, em, ey);
	SendClientMessage(playerid, 0x00FF88FF, str);
	printf("[AccessGate] ACTIVATED %s", AG_Nick[playerid]);
	return 1;
}

forward AG_Kick(playerid);
public AG_Kick(playerid)
{
	if(IsPlayerConnected(playerid) && !AG_Ok[playerid]) Kick(playerid);
	return 1;
}
