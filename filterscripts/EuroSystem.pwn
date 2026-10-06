/*
	EuroSystem.pwn
	Kranin / Black Russia

	.euro .eurotop .europay .eurobal
	PayDay XX:00 = +10 euro
	Top-50, euro -> euro
*/

#define FILTERSCRIPT
#include <a_samp>
#include <a_mysql>

#define MYSQL_FILE			"bykranin_mysql_settings.ini"
#define EURO_PAYDAY			10
#define COLOR_EURO			0xFFD700FF
#define COLOR_ERR			0xFF6347FF

#define D_EURO_MENU			9510
#define D_EURO_GIVE			9511
#define D_EURO_GIVE_AMT		9512
#define D_EURO_TOP			9514

new gSQL;
new gSQLOk;

new SQL_Host[64], SQL_User[64], SQL_Pass[128], SQL_DB[64];

new PlayerEuro[MAX_PLAYERS];
new PlayerEuroExchanged[MAX_PLAYERS];
new PlayerAccID[MAX_PLAYERS];
new bool:PlayerEuroLoaded[MAX_PLAYERS];
new EuroGiveTarget[MAX_PLAYERS];
new LastPaydayHour = -1;

stock UnixNow() return gettime();

stock trim(str[])
{
	new s, e = strlen(str);
	while(s < e && str[s] <= ' ') s++;
	while(e > s && str[e-1] <= ' ') e--;
	strdel(str, e, strlen(str));
	if(s > 0) strdel(str, 0, s);
}

stock LoadMySQLIni()
{
	format(SQL_Host, sizeof(SQL_Host), "127.0.0.1");
	SQL_User[0] = 0; SQL_Pass[0] = 0; SQL_DB[0] = 0;

	if(!fexist(MYSQL_FILE))
	{
		print("[Euro] NET bykranin_mysql_settings.ini");
		return 0;
	}
	new File:f = fopen(MYSQL_FILE, io_read);
	if(!f) return 0;

	new line[256];
	while(fread(f, line))
	{
		for(new i = 0; line[i]; i++)
			if(line[i] == '\r' || line[i] == '\n') { line[i] = 0; break; }
		trim(line);
		if(!line[0] || line[0] == ';' || line[0] == '#') continue;

		new eq = strfind(line, "=");
		if(eq == -1) continue;
		new key[64], val[128];
		strmid(key, line, 0, eq);
		strmid(val, line, eq+1, strlen(line));
		trim(key); trim(val);

		if(!strcmp(key, "host", true) || !strcmp(key, "hostname", true))
			format(SQL_Host, sizeof(SQL_Host), "%s", val);
		else if(!strcmp(key, "username", true) || !strcmp(key, "user", true))
			format(SQL_User, sizeof(SQL_User), "%s", val);
		else if(!strcmp(key, "password", true) || !strcmp(key, "pass", true))
			format(SQL_Pass, sizeof(SQL_Pass), "%s", val);
		else if(!strcmp(key, "database", true) || !strcmp(key, "db", true))
			format(SQL_DB, sizeof(SQL_DB), "%s", val);
	}
	fclose(f);
	printf("[Euro] MySQL %s@%s db=%s", SQL_User, SQL_Host, SQL_DB);
	return 1;
}

stock MigrateEuroColumns()
{
	mysql_query(gSQL, "ALTER TABLE `accounts` ADD COLUMN `evro` INT NOT NULL DEFAULT 0", false);
	mysql_query(gSQL, "ALTER TABLE `accounts` ADD COLUMN `evro_exchanged` INT NOT NULL DEFAULT 0", false);
	print("[Euro] Migraciya OK");
}

stock SavePlayerEuro(playerid)
{
	if(!gSQLOk || !PlayerEuroLoaded[playerid]) return 0;
	if(PlayerAccID[playerid] <= 0) return 0;
	new q[192];
	mysql_format(gSQL, q, sizeof(q),
		"UPDATE `accounts` SET `evro` = %d, `evro_exchanged` = %d WHERE `id` = %d LIMIT 1",
		PlayerEuro[playerid], PlayerEuroExchanged[playerid], PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	return 1;
}

stock ShowEuroMenu(playerid)
{
	if(!PlayerEuroLoaded[playerid])
	{
		SendClientMessage(playerid, COLOR_ERR, "Евро загружается, подожди...");
		return 0;
	}
	new str[256];
	format(str, sizeof(str),
		"Баланс: %d евро | Передано: %d\n\
Передать евро игроку\n\
Топ-50 по евро\n\
Обновить баланс",
		PlayerEuro[playerid], PlayerEuroExchanged[playerid]);
	ShowPlayerDialog(playerid, D_EURO_MENU, DIALOG_STYLE_LIST, "{FFD700}Евро", str, "Выбор", "Закрыть");
	return 1;
}

stock ShowEuroTop(playerid)
{
	if(!gSQLOk) return 0;
	mysql_tquery(gSQL,
		"SELECT `name`, `evro`, `evro_exchanged` FROM `accounts` ORDER BY `evro` DESC LIMIT 50",
		"OnEuroTop", "i", playerid);
	return 1;
}

forward OnEuroTop(playerid);
public OnEuroTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;

	new rows = cache_get_row_count(gSQL);
	if(rows < 1)
	{
		ShowPlayerDialog(playerid, D_EURO_TOP, DIALOG_STYLE_MSGBOX, "{FFD700}Топ-50 евро", "Топ пока пуст", "ОК", "");
		return 1;
	}

	new body[2048], line[96], name[24], evro, exch;
	body[0] = 0;
	strcat(body, "{FFFF00}Топ-50 по евро\n\n{FFFFFF}");

	new maxr = rows;
	if(maxr > 50) maxr = 50;

	for(new i = 0; i < maxr; i++)
	{
		cache_get_field_content(i, "name", name, gSQL, sizeof(name));
		evro = cache_get_field_content_int(i, "evro", gSQL);
		exch = cache_get_field_content_int(i, "evro_exchanged", gSQL);

		if(i == 0) format(line, sizeof(line), "{FFD700}#1. %s - %d евро (передал %d)\n", name, evro, exch);
		else if(i == 1) format(line, sizeof(line), "{C0C0C0}#2. %s - %d евро (передал %d)\n", name, evro, exch);
		else if(i == 2) format(line, sizeof(line), "{CD7F32}#3. %s - %d евро (передал %d)\n", name, evro, exch);
		else format(line, sizeof(line), "{FFFFFF}#%d. %s - %d евро (передал %d)\n", i+1, name, evro, exch);

		if(strlen(body) + strlen(line) >= sizeof(body) - 2) break;
		strcat(body, line);
	}
	ShowPlayerDialog(playerid, D_EURO_TOP, DIALOG_STYLE_MSGBOX, "{FFD700}Топ-50 евро", body, "ОК", "");
	return 1;
}

forward LoadEuroForPlayer(playerid);
public LoadEuroForPlayer(playerid)
{
	if(!IsPlayerConnected(playerid) || !gSQLOk) return 1;
	new name[MAX_PLAYER_NAME], q[192];
	GetPlayerName(playerid, name, sizeof(name));
	mysql_format(gSQL, q, sizeof(q),
		"SELECT `id`, `evro`, `evro_exchanged` FROM `accounts` WHERE `name` = '%e' LIMIT 1", name);
	mysql_tquery(gSQL, q, "OnEuroLoaded", "i", playerid);
	return 1;
}

forward OnEuroLoaded(playerid);
public OnEuroLoaded(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL);
	if(rows < 1)
	{
		PlayerEuroLoaded[playerid] = false;
		return 1;
	}
	PlayerAccID[playerid] = cache_get_field_content_int(0, "id", gSQL);
	PlayerEuro[playerid] = cache_get_field_content_int(0, "evro", gSQL);
	PlayerEuroExchanged[playerid] = cache_get_field_content_int(0, "evro_exchanged", gSQL);
	PlayerEuroLoaded[playerid] = true;
	return 1;
}

forward PayDayEuro();
public PayDayEuro()
{
	if(!gSQLOk) return 1;
	new h, m, s;
	gettime(h, m, s);
	if(m != 0) return 1;
	if(LastPaydayHour == h) return 1;
	LastPaydayHour = h;

	new count;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		if(!PlayerEuroLoaded[i]) continue;
		PlayerEuro[i] += EURO_PAYDAY;
		SavePlayerEuro(i);
		count++;
		new str[96];
		format(str, sizeof(str), "{FFD700}[PayDay] +%d евро | Баланс: %d", EURO_PAYDAY, PlayerEuro[i]);
		SendClientMessage(i, -1, str);
	}
	printf("[Euro] PayDay %02d:00 | %d players +%d", h, count, EURO_PAYDAY);
	return 1;
}

stock HandleEuroCmd(playerid, const cmd[])
{
	if(!strcmp(cmd, "euro", true))
	{
		if(!PlayerEuroLoaded[playerid])
		{
			SendClientMessage(playerid, COLOR_ERR, "Баланс загружается...");
			LoadEuroForPlayer(playerid);
			SetTimerEx("DelayedEuroMenu", 1500, false, "i", playerid);
			return 1;
		}
		ShowEuroMenu(playerid);
		return 1;
	}
	if(!strcmp(cmd, "eurotop", true))
	{
		ShowEuroTop(playerid);
		return 1;
	}
	if(!strcmp(cmd, "eurobal", true))
	{
		if(!PlayerEuroLoaded[playerid])
		{
			SendClientMessage(playerid, COLOR_ERR, "Баланс не загружен");
			return 1;
		}
		new str[96];
		format(str, sizeof(str), "Евро: %d | Передано другим: %d", PlayerEuro[playerid], PlayerEuroExchanged[playerid]);
		SendClientMessage(playerid, COLOR_EURO, str);
		return 1;
	}
	if(!strcmp(cmd, "europay", true))
	{
		if(!PlayerEuroLoaded[playerid])
		{
			SendClientMessage(playerid, COLOR_ERR, "Баланс не загружен");
			return 1;
		}
		ShowPlayerDialog(playerid, D_EURO_GIVE, DIALOG_STYLE_INPUT,
			"{FFD700}Передать евро", "Введите ID игрока:", "Далее", "Отмена");
		return 1;
	}
	return 0;
}

forward DelayedEuroMenu(playerid);
public DelayedEuroMenu(playerid)
{
	if(IsPlayerConnected(playerid)) ShowEuroMenu(playerid);
	return 1;
}

public OnFilterScriptInit()
{
	print(" ");
	print("  [Euro] sistema evro | .euro .eurotop .europay");
	print(" ");

	gSQLOk = 0;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		PlayerEuro[i] = 0;
		PlayerEuroExchanged[i] = 0;
		PlayerAccID[i] = 0;
		PlayerEuroLoaded[i] = false;
		EuroGiveTarget[i] = -1;
	}

	if(!LoadMySQLIni() || !SQL_DB[0])
	{
		print("[Euro] ini/db fail");
		return 1;
	}

	gSQL = mysql_connect(SQL_Host, SQL_User, SQL_DB, SQL_Pass);
	if(mysql_errno(gSQL) != 0)
		gSQL = mysql_connect(SQL_Host, SQL_User, SQL_Pass, SQL_DB);
	if(mysql_errno(gSQL) != 0)
	{
		print("[Euro] MySQL FAIL");
		return 1;
	}
	gSQLOk = 1;
	MigrateEuroColumns();
	SetTimer("PayDayEuro", 30000, true);
	print("[Euro] OK");
	return 1;
}

public OnFilterScriptExit()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
		if(IsPlayerConnected(i) && PlayerEuroLoaded[i]) SavePlayerEuro(i);
	if(gSQLOk) mysql_close(gSQL);
	return 1;
}

public OnPlayerConnect(playerid)
{
	PlayerEuro[playerid] = 0;
	PlayerEuroExchanged[playerid] = 0;
	PlayerAccID[playerid] = 0;
	PlayerEuroLoaded[playerid] = false;
	EuroGiveTarget[playerid] = -1;
	SetTimerEx("LoadEuroForPlayer", 5000, false, "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if(PlayerEuroLoaded[playerid]) SavePlayerEuro(playerid);
	PlayerEuroLoaded[playerid] = false;
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(text[0] == '.')
	{
		new cmd[64];
		format(cmd, sizeof(cmd), "%s", text[1]);
		new sp = strfind(cmd, " ");
		if(sp != -1)
		{
			new only[64];
			strmid(only, cmd, 0, sp);
			if(HandleEuroCmd(playerid, only)) return 0;
		}
		else if(HandleEuroCmd(playerid, cmd)) return 0;
	}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(cmdtext[0] == '/')
	{
		new cmd[64];
		format(cmd, sizeof(cmd), "%s", cmdtext[1]);
		new sp = strfind(cmd, " ");
		if(sp != -1)
		{
			new only[64];
			strmid(only, cmd, 0, sp);
			if(HandleEuroCmd(playerid, only)) return 1;
		}
		else if(HandleEuroCmd(playerid, cmd)) return 1;
	}
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == D_EURO_MENU)
	{
		if(!response) return 1;
		if(!PlayerEuroLoaded[playerid]) return 1;
		switch(listitem)
		{
			case 0: ShowEuroMenu(playerid);
			case 1:
			{
				ShowPlayerDialog(playerid, D_EURO_GIVE, DIALOG_STYLE_INPUT,
					"{FFD700}Передать евро", "Введите ID игрока:", "Далее", "Отмена");
			}
			case 2: ShowEuroTop(playerid);
			case 3:
			{
				LoadEuroForPlayer(playerid);
				SetTimerEx("DelayedEuroMenu", 1000, false, "i", playerid);
			}
		}
		return 1;
	}

	if(dialogid == D_EURO_GIVE)
	{
		if(!response) return 1;
		new tid = strval(inputtext);
		if(!IsPlayerConnected(tid))
		{
			SendClientMessage(playerid, COLOR_ERR, "Игрок не в сети");
			return 1;
		}
		if(tid == playerid)
		{
			SendClientMessage(playerid, COLOR_ERR, "Нельзя себе");
			return 1;
		}
		if(!PlayerEuroLoaded[tid])
		{
			SendClientMessage(playerid, COLOR_ERR, "У игрока не загружен баланс");
			return 1;
		}
		EuroGiveTarget[playerid] = tid;
		ShowPlayerDialog(playerid, D_EURO_GIVE_AMT, DIALOG_STYLE_INPUT,
			"{FFD700}Сумма", "Сколько евро передать?", "ОК", "Отмена");
		return 1;
	}

	if(dialogid == D_EURO_GIVE_AMT)
	{
		if(!response) return 1;
		new amt = strval(inputtext);
		new tid = EuroGiveTarget[playerid];
		if(amt <= 0)
		{
			SendClientMessage(playerid, COLOR_ERR, "Сумма должна быть больше 0");
			return 1;
		}
		if(!IsPlayerConnected(tid) || !PlayerEuroLoaded[tid])
		{
			SendClientMessage(playerid, COLOR_ERR, "Игрок недоступен");
			return 1;
		}
		if(PlayerEuro[playerid] < amt)
		{
			SendClientMessage(playerid, COLOR_ERR, "Недостаточно евро");
			return 1;
		}

		PlayerEuro[playerid] -= amt;
		PlayerEuro[tid] += amt;
		PlayerEuroExchanged[playerid] += amt;
		SavePlayerEuro(playerid);
		SavePlayerEuro(tid);

		new str[144], n1[24], n2[24];
		GetPlayerName(playerid, n1, sizeof(n1));
		GetPlayerName(tid, n2, sizeof(n2));
		format(str, sizeof(str), "{FFD700}Вы передали %d евро -> %s | Ваш баланс: %d", amt, n2, PlayerEuro[playerid]);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof(str), "{FFD700}%s передал вам %d евро | Ваш баланс: %d", n1, amt, PlayerEuro[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}

	if(dialogid == D_EURO_TOP) return 1;
	return 0;
}
