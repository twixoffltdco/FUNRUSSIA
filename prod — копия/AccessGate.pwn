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
#define AG_DLG_TRIAL        41711
#define AG_DLG_TRIAL_OFFER  41712
#define AG_TRIAL_SEC        (5 * 3600)
#define AG_DELAY           10000
#define AG_MAX_TRIES       5

new MySQL:AG_SQL = MySQL:0;
new bool:AG_SQLOk;
new AG_Host[64], AG_User[64], AG_Pass[64], AG_DB[64];

new AG_Acc[MAX_PLAYERS];
new bool:AG_Ok[MAX_PLAYERS];
new bool:AG_Trial[MAX_PLAYERS];
new AG_TrialEnd[MAX_PLAYERS];
new AG_TrialRemaining[MAX_PLAYERS]; // remaining online trial seconds
new AG_TrialJoinAt[MAX_PLAYERS];
new bool:AG_TrialOfferShown[MAX_PLAYERS];
new Float:AG_Tx[MAX_PLAYERS], Float:AG_Ty[MAX_PLAYERS], Float:AG_Tz[MAX_PLAYERS];
new bool:AG_TPos[MAX_PLAYERS];
new AG_TrialVeh[MAX_PLAYERS];
new AG_TrialCarWait[MAX_PLAYERS]; // gettime until allow vw0 for cars
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
	// Count month chunks instead of iterating one day at a time; long codes (1000+ days) stay efficient.
	while(y < ey || (y == ey && m < em))
	{
		days += AG_DaysInMonth(y, m) - d + 1;
		d = 1;
		m++;
		if(m > 12) { m = 1; y++; }
	}
	if(y == ey && m == em && ed >= d) days += ed - d;
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
	AG_SQL = MySQL:mysql_connect(AG_Host, AG_User, AG_DB, AG_Pass);
	if(_:AG_SQL && mysql_errno(AG_SQL) == 0) return 1;
	AG_SQL = MySQL:mysql_connect(AG_Host, AG_User, AG_Pass, AG_DB);
	if(_:AG_SQL && mysql_errno(AG_SQL) == 0) return 1;
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
		mysql_tquery(AG_SQL, "ALTER TABLE `accounts` ADD COLUMN `fun_trial_end` INT NOT NULL DEFAULT 0");
		mysql_tquery(AG_SQL, "ALTER TABLE `accounts` ADD COLUMN `fun_trial_used` TINYINT NOT NULL DEFAULT 0");
		mysql_tquery(AG_SQL, "ALTER TABLE `accounts` ADD COLUMN `fun_trial_remaining` INT NOT NULL DEFAULT 0");
		print("[AccessGate] MySQL OK");
	}
	else print("[AccessGate] MySQL не подключен");
	SetTimer("AG_Pulse", 1000, true);
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
	AG_Trial[playerid] = false;
	AG_TrialEnd[playerid] = 0;
	AG_TrialRemaining[playerid] = AG_TRIAL_SEC;
	AG_TrialJoinAt[playerid] = 0;
	AG_TrialOfferShown[playerid] = false;
	AG_TPos[playerid] = false;
	AG_TrialVeh[playerid] = 0;
	AG_TrialCarWait[playerid] = 0;
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

public OnPlayerText(playerid, text[])
{
	if(AG_Trial[playerid] && AG_TrialEnd[playerid] > gettime())
	{
		SendClientMessage(playerid, 0xFF4444FF, "[Триал] Чат выключен. Только /cars /donate /inv /reward");
		return 0;
	}
	return 1;
}


public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!AG_Trial[playerid] || AG_TrialEnd[playerid] <= gettime()) return 0;
	new cmd[64];
	format(cmd, sizeof cmd, "%s", cmdtext);
	for(new i; cmd[i]; i++) if(cmd[i] >= 'A' && cmd[i] <= 'Z') cmd[i] += 32;

	if(AG_CmdAllow(cmd, "/cars") || AG_CmdAllow(cmd, "/donate") || AG_CmdAllow(cmd, "/inv") || AG_CmdAllow(cmd, "/reward"))
	{
		if(AG_CmdAllow(cmd, "/cars"))
			SetTimerEx("AG_TrialCatchVeh", 1000, false, "i", playerid);
		return 0;
	}

	SendClientMessage(playerid, 0xFF4444FF, "[Триал] Запрещено. Только /cars /donate /inv /reward");
	return 1;
}

// pawncmd plugin (BlackRush часто через него)
public OnPlayerCommandReceived(playerid, cmd[])
{
	if(!AG_Trial[playerid] || AG_TrialEnd[playerid] <= gettime()) return 1;
	new c[64];
	format(c, sizeof c, "%s", cmd);
	for(new i; c[i]; i++) if(c[i] >= 'A' && c[i] <= 'Z') c[i] += 32;
	// pawncmd без слэша
	if(AG_CmdAllow(c, "cars") || AG_CmdAllow(c, "donate") || AG_CmdAllow(c, "inv") || AG_CmdAllow(c, "reward")
		|| AG_CmdAllow(c, "/cars") || AG_CmdAllow(c, "/donate") || AG_CmdAllow(c, "/inv") || AG_CmdAllow(c, "/reward"))
	{
		if(AG_CmdAllow(c, "cars") || AG_CmdAllow(c, "/cars"))
			SetTimerEx("AG_TrialCatchVeh", 800, false, "i", playerid);
		return 1;
	}
	SendClientMessage(playerid, 0xFF4444FF, "[Триал] Команда заблокирована.");
	return 0; // pawncmd: 0 = block
}

public OnPlayerCommandPerformed(playerid, cmd[], success)
{
	#pragma unused cmd, success
	if(AG_Trial[playerid] && AG_TrialEnd[playerid] > gettime())
		AG_TrialLock(playerid);
	return 1;
}

stock bool:AG_CmdAllow(cmd[], name[])
{
	new len = strlen(name);
	if(strfind(cmd, name, true) != 0) return false;
	new ch = cmd[len];
	return (ch == 0 || ch == ' ');
}

stock AG_TrialLock(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(!AG_Trial[playerid] || AG_TrialEnd[playerid] <= gettime()) return 0;

	new vw = 50000 + playerid;
	// окно для /cars — не тянуть обратно в VW 4 сек
	if(AG_TrialCarWait[playerid] > gettime())
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			new vid = GetPlayerVehicleID(playerid);
			if(vid > 0) AG_TrialVeh[playerid] = vid;
		}
		return 1;
	}
	new bool:bad_vw = (GetPlayerVirtualWorld(playerid) != vw);
	if(bad_vw)
		SetPlayerVirtualWorld(playerid, vw);

	// аренда/парковка спавнит в мире 0 — тянем пустые тачки рядом в VW триала
	{
		new Float:px, Float:py, Float:pz;
		GetPlayerPos(playerid, px, py, pz);
		new interior = GetPlayerInterior(playerid);
		for(new v = 1; v < MAX_VEHICLES; v++)
		{
			if(GetVehicleModel(v) < 400) continue;
			new Float:vx, Float:vy, Float:vz;
			GetVehiclePos(v, vx, vy, vz);
			new Float:dx = vx - px, Float:dy = vy - py, Float:dz = vz - pz;
			if((dx*dx + dy*dy + dz*dz) > 225.0) continue; // >15м
			// занята другим игроком?
			new bool:busy = false;
			for(new p; p < MAX_PLAYERS; p++)
			{
				if(p == playerid || !IsPlayerConnected(p)) continue;
				if(IsPlayerInVehicle(p, v)) { busy = true; break; }
			}
			if(busy) continue;
			if(GetVehicleVirtualWorld(v) != vw)
			{
				SetVehicleVirtualWorld(v, vw);
				LinkVehicleToInterior(v, interior);
			}
		}
	}

	// машина только триал-игрока в его VW
	if(IsPlayerInAnyVehicle(playerid))
	{
		new vid = GetPlayerVehicleID(playerid);
		if(vid > 0)
		{
			AG_TrialVeh[playerid] = vid;
			if(GetVehicleVirtualWorld(vid) != vw)
				SetVehicleVirtualWorld(vid, vw);
		}
	}
	else if(AG_TrialVeh[playerid] > 0)
	{
		new vid = AG_TrialVeh[playerid];
		if(GetVehicleModel(vid) > 0 && GetVehicleVirtualWorld(vid) != vw)
			SetVehicleVirtualWorld(vid, vw);
	}

	// анти-ТП: админ /gethere или /tp игрока к себе
	if(AG_TPos[playerid])
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		new Float:dx = x - AG_Tx[playerid], Float:dy = y - AG_Ty[playerid], Float:dz = z - AG_Tz[playerid];
		new Float:dist2 = dx*dx + dy*dy + dz*dz;
		// >15м за тик или сменили VW = насильственный ТП
		if(bad_vw || dist2 > 225.0)
		{
			SetPlayerPos(playerid, AG_Tx[playerid], AG_Ty[playerid], AG_Tz[playerid]);
			SetPlayerVirtualWorld(playerid, vw);
			if(IsPlayerInAnyVehicle(playerid))
			{
				new vid = GetPlayerVehicleID(playerid);
				if(vid > 0)
				{
					SetVehiclePos(vid, AG_Tx[playerid], AG_Ty[playerid], AG_Tz[playerid]);
					SetVehicleVirtualWorld(vid, vw);
				}
			}
			SendClientMessage(playerid, 0xFF4444FF, "[Триал] Телепорт админа сброшен. Ты в своём мире.");
		}
		else
		{
			// только обычное движение — обновляем точку
			AG_Tx[playerid] = x;
			AG_Ty[playerid] = y;
			AG_Tz[playerid] = z;
		}
	}
	else
	{
		GetPlayerPos(playerid, AG_Tx[playerid], AG_Ty[playerid], AG_Tz[playerid]);
		AG_TPos[playerid] = true;
	}
	return 1;
}

// выкинуть админов/игроков из VW триала
stock AG_KickFromTrialWorlds(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(AG_Trial[playerid] && AG_TrialEnd[playerid] > gettime()) return 0;
	new vw = GetPlayerVirtualWorld(playerid);
	if(vw >= 50000 && vw < 50000 + MAX_PLAYERS)
	{
		SetPlayerVirtualWorld(playerid, 0);
		SendClientMessage(playerid, 0xFF4444FF, "Нельзя в мир триал-игрока (ТП к триалу запрещён).");
		return 1;
	}
	return 0;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	#pragma unused weaponid, hittype, hitid, fX, fY, fZ
	if(AG_Trial[playerid]) return 0; // нельзя стрелять по игрокам
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	#pragma unused amount, weaponid, bodypart
	if(AG_Trial[playerid]) return 0;
	if(issuerid != INVALID_PLAYER_ID && AG_Trial[issuerid]) return 0;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	#pragma unused killerid, reason
	if(AG_Trial[playerid])
		SetTimerEx("AG_TrialFixVW", 1000, false, "i", playerid);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	#pragma unused oldstate
	if(!AG_Trial[playerid] || AG_TrialEnd[playerid] <= gettime()) return 1;
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		new vid = GetPlayerVehicleID(playerid);
		if(vid > 0)
		{
			AG_TrialVeh[playerid] = vid;
			SetVehicleVirtualWorld(vid, 50000 + playerid);
			SetPlayerVirtualWorld(playerid, 50000 + playerid);
			LinkVehicleToInterior(vid, GetPlayerInterior(playerid));
		}
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	static upd[MAX_PLAYERS];
	if(AG_Trial[playerid] && AG_TrialEnd[playerid] > gettime())
	{
		upd[playerid]++;
		if(upd[playerid] >= 15) // ~2 раза в секунду
		{
			upd[playerid] = 0;
			AG_TrialLock(playerid);
		}
	}
	return 1;
}


forward AG_TrialCatchVeh(playerid);
public AG_TrialCatchVeh(playerid)
{
	// шаг 1: на 4 сек в мир 0, чтобы /cars заспавнил тачку и игрок сел
	if(!IsPlayerConnected(playerid)) return 1;
	if(!AG_Trial[playerid] || AG_TrialEnd[playerid] <= gettime()) return 1;

	AG_TrialCarWait[playerid] = gettime() + 5;
	SetPlayerVirtualWorld(playerid, 0);
	SendClientMessage(playerid, 0x7CFC00FF, "[Триал] Выбери/сядь в тачку за 4 сек — потом вернём в твой мир.");
	SetTimerEx("AG_TrialCatchVeh2", 4000, false, "i", playerid);
	return 1;
}

forward AG_TrialCatchVeh2(playerid);
public AG_TrialCatchVeh2(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(!AG_Trial[playerid] || AG_TrialEnd[playerid] <= gettime()) return 1;

	new vw = 50000 + playerid;
	new vid = 0;

	if(IsPlayerInAnyVehicle(playerid))
		vid = GetPlayerVehicleID(playerid);

	if(vid <= 0)
	{
		// ищем ближайшую тачку (координаты видны из любого VW)
		new Float:px, Float:py, Float:pz;
		GetPlayerPos(playerid, px, py, pz);
		new Float:best_d = 40.0;
		for(new v = 1; v < MAX_VEHICLES; v++)
		{
			if(GetVehicleModel(v) < 400) continue;
			new Float:vx, Float:vy, Float:vz;
			GetVehiclePos(v, vx, vy, vz);
			new Float:dx = vx - px, Float:dy = vy - py, Float:dz = vz - pz;
			new Float:d = floatsqroot(dx * dx + dy * dy + dz * dz);
			if(d < best_d)
			{
				best_d = d;
				vid = v;
			}
		}
	}

	if(vid > 0)
	{
		SetVehicleVirtualWorld(vid, vw);
		LinkVehicleToInterior(vid, GetPlayerInterior(playerid));
		AG_TrialVeh[playerid] = vid;
		SetPlayerVirtualWorld(playerid, vw);
		if(!IsPlayerInAnyVehicle(playerid))
			PutPlayerInVehicle(playerid, vid, 0);
		else
			SetPlayerVirtualWorld(playerid, vw);
		GetPlayerPos(playerid, AG_Tx[playerid], AG_Ty[playerid], AG_Tz[playerid]);
		AG_TPos[playerid] = true;
		SendClientMessage(playerid, 0x7CFC00FF, "[Триал] Тачка в твоём мире. Катайся.");
		printf("[AccessGate] trial car ok veh=%d vw=%d %s", vid, vw, AG_Nick[playerid]);
	}
	else
	{
		SetPlayerVirtualWorld(playerid, vw);
		SendClientMessage(playerid, 0xFFAA00FF, "[Триал] Тачка не найдена. Напиши /cars ещё раз и сядь в неё быстрее.");
	}
	return 1;
}

forward AG_TrialFixVW(playerid);
public AG_TrialFixVW(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(AG_Trial[playerid] && AG_TrialEnd[playerid] > gettime())
	{
		SetPlayerVirtualWorld(playerid, 50000 + playerid);
		ResetPlayerWeapons(playerid);
		GetPlayerPos(playerid, AG_Tx[playerid], AG_Ty[playerid], AG_Tz[playerid]);
		AG_TPos[playerid] = true;
		AG_TrialLock(playerid);
	}
	return 1;
}


public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if(AG_Tmr[playerid]) { KillTimer(AG_Tmr[playerid]); AG_Tmr[playerid] = 0; }
	// Save remaining seconds so offline time does not consume the trial.
	if(AG_Trial[playerid] && AG_SQLOk && AG_Acc[playerid] > 0)
	{
		new remaining = AG_TrialEnd[playerid] - gettime();
		if(remaining < 0) remaining = 0;
		new q[180];
		mysql_format(AG_SQL, q, sizeof q,
			"UPDATE `accounts` SET `fun_trial_remaining`=%d, `fun_trial_end`=%d WHERE `id`=%d LIMIT 1",
			remaining, gettime() + remaining, AG_Acc[playerid]);
		mysql_tquery(AG_SQL, q);
	}
	AG_Ok[playerid] = false;
	AG_Need[playerid] = false;
	AG_Trial[playerid] = false;
	return 1;
}

forward AG_Load(playerid);
public AG_Load(playerid)
{
	AG_Tmr[playerid] = 0;
	if(!IsPlayerConnected(playerid)) return 1;
	// уже в триале или с доступом — не трогать
	if(AG_Ok[playerid]) return 1;
	if(AG_Trial[playerid] && AG_TrialEnd[playerid] > gettime()) return 1;
	if(!AG_SQLOk)
	{
		print("[AccessGate] нет SQL при проверке");
		AG_Need[playerid] = true;
		AG_ShowKey(playerid);
		return 1;
	}
	new q[280];
	mysql_format(AG_SQL, q, sizeof q,
		"SELECT `id`, `access_ok`, `access_code`, `access_until_y`, `access_until_m`, `access_until_d`, IFNULL(`fun_trial_end`,0), IFNULL(`fun_trial_used`,0), IFNULL(`fun_trial_remaining`,0) FROM `accounts` WHERE `name`='%e' LIMIT 1",
		AG_Nick[playerid]);
	mysql_tquery(AG_SQL, q, "AG_OnLoad", "i", playerid);
	return 1;
}

forward AG_OnLoad(playerid);
public AG_OnLoad(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(AG_Ok[playerid] && (!AG_Trial[playerid] || AG_TrialEnd[playerid] > gettime())) return 1;
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

	// --- Триал 5 часов для новичков ---
	new trial_end = cache_get_row_int(0, 6, AG_SQL);
	new trial_used = cache_get_row_int(0, 7, AG_SQL);
	new saved_remaining = cache_get_row_int(0, 8, AG_SQL);
	new nowt = gettime();

	// Active trial: offline time does not consume the remaining seconds.
	if(saved_remaining > 0 || (trial_end > nowt && trial_used == 1))
	{
		if(saved_remaining <= 0) saved_remaining = trial_end - nowt; // legacy rows
		AG_TrialRemaining[playerid] = saved_remaining;
		AG_Ok[playerid] = true;
		AG_Need[playerid] = false;
		AG_Trial[playerid] = true;
		AG_TrialEnd[playerid] = nowt + saved_remaining;
		AG_TrialJoinAt[playerid] = gettime();
		AG_TrialOfferShown[playerid] = false;
		AG_DlgOpen[playerid] = false;
		AG_Need[playerid] = false;
		TogglePlayerControllable(playerid, 1);
		SetPlayerVirtualWorld(playerid, 50000 + playerid);
		AG_TPos[playerid] = false;
		SetTimerEx("AG_TrialFixVW", 2000, false, "i", playerid);
		new left = saved_remaining;
		new h = left / 3600, m = (left % 3600) / 60;
		new str[140];
		format(str, sizeof str, "[Триал] Бесплатный осмотр: ~%d ч %d мин. Свой мир, без полного доступа. Потом купи код.", h, m);
		SendClientMessage(playerid, 0x7CFC00FF, str);
		printf("[AccessGate] TRIAL %s left=%ds", AG_Nick[playerid], left);
		return 1;
	}

	// триал ещё не выдавался - выдать 5 часов
	if(trial_used == 0)
	{
		trial_end = nowt + AG_TRIAL_SEC;
		AG_TrialRemaining[playerid] = AG_TRIAL_SEC;
		AG_Ok[playerid] = true;
		AG_Need[playerid] = false;
		AG_Trial[playerid] = true;
		AG_TrialEnd[playerid] = trial_end;
		AG_TrialJoinAt[playerid] = gettime();
		AG_TrialOfferShown[playerid] = false;
		AG_DlgOpen[playerid] = false;
		AG_Need[playerid] = false;
		TogglePlayerControllable(playerid, 1);
		SetPlayerVirtualWorld(playerid, 50000 + playerid);
		AG_TPos[playerid] = false;
		SetTimerEx("AG_TrialFixVW", 2000, false, "i", playerid);
		new q2[200];
		mysql_format(AG_SQL, q2, sizeof q2,
			"UPDATE `accounts` SET `fun_trial_end`=%d, `fun_trial_remaining`=%d, `fun_trial_used`=1 WHERE `id`=%d LIMIT 1",
			trial_end, AG_TRIAL_SEC, AG_Acc[playerid]);
		mysql_tquery(AG_SQL, q2);
		SendClientMessage(playerid, 0x7CFC00FF, "[Триал] Тебе выдали 5 часов бесплатно. Осмотри сервер. Чат/полный онлайн - после покупки доступа.");
		ShowPlayerDialog(playerid, AG_DLG_TRIAL, DIALOG_STYLE_MSGBOX, "Триал Fun Russia",
			"Бесплатный триал: 5 часов.\n\nСвой виртуальный мир.\nМожно бегать и смотреть локации.\n\nКогда закончится - купи спецкод\nили попроси у друга.\n\nДоступ: Max / сайт Fun Russia.",
			"OK", "");
		printf("[AccessGate] === TRIAL START === nick=%s acc=%d until=%d (5h)", AG_Nick[playerid], AG_Acc[playerid], trial_end);
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
	if(AG_Trial[playerid] && AG_TrialEnd[playerid] > gettime()) return 0;
	if(AG_DlgOpen[playerid]) return 1; // уже открыт - не сбрасывать ввод
	AG_Need[playerid] = true;
	AG_DlgOpen[playerid] = true;
	TogglePlayerControllable(playerid, 0);
	SendClientMessage(playerid, 0xFFD700FF, "=== ПЛАТНЫЙ ДОСТУП | 30 дней ===");
	SendClientMessage(playerid, 0xFFFFFFFF, "Сервер платный. Введи спецкод.");
	SendClientMessage(playerid, 0xFFD700FF, "750 руб | для друзей - бесплатно");
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
	if(AG_Trial[playerid] && AG_TrialEnd[playerid] > gettime())
	{
		SetPlayerVirtualWorld(playerid, 50000 + playerid);
		ResetPlayerWeapons(playerid);
		return 1;
	}
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
	new nowt = gettime();
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;

		// админ/игрок не должен быть в VW триала
		AG_KickFromTrialWorlds(i);

		// конец триала
		if(AG_Trial[i] && AG_TrialEnd[i] > 0 && AG_TrialEnd[i] <= nowt)
		{
			AG_Trial[i] = false;
			AG_Ok[i] = false;
			AG_Need[i] = true;
			AG_TrialEnd[i] = 0;
			AG_TrialRemaining[i] = 0;
			if(AG_SQLOk && AG_Acc[i] > 0)
			{
				new qend[120];
				mysql_format(AG_SQL, qend, sizeof qend, "UPDATE `accounts` SET `fun_trial_remaining`=0 WHERE `id`=%d LIMIT 1", AG_Acc[i]);
				mysql_tquery(AG_SQL, qend);
			}
			TogglePlayerControllable(i, 0);
			SetPlayerVirtualWorld(i, 0);
			ShowPlayerDialog(i, AG_DLG_TRIAL, DIALOG_STYLE_MSGBOX, "Триал закончился",
				"Бесплатные 5 часов вышли.\n\nКупи спецкод или попроси у друга.\nМожно ввести код сейчас или выйти.\n\nДоступ: Max / Fun Russia.",
				"Ввести код", "Выйти");
			printf("[AccessGate] TRIAL END %s", AG_Nick[i]);
			continue;
		}

				if(AG_Trial[i] && AG_TrialEnd[i] > nowt)
		{
			// Через 15 минут онлайн предлагаем ввести спецкод досрочно.
			if(!AG_TrialOfferShown[i] && AG_TrialJoinAt[i] > 0 && nowt - AG_TrialJoinAt[i] >= 900 && !AG_DlgOpen[i])
			{
				AG_TrialOfferShown[i] = true;
				AG_DlgOpen[i] = true;
				ShowPlayerDialog(i, AG_DLG_TRIAL_OFFER, DIALOG_STYLE_MSGBOX,
					"Fun Russia — понравился сервер?",
					"Ты уже играешь 15 минут. Не хочешь ждать окончания триала?\\n\\nМожешь ввести спецкод и открыть полный доступ сейчас.\\nЕсли нажмёшь «Позже», продолжишь триал. Пять часов считаются только пока ты онлайн.",
					"Ввести код", "Позже");
			}
			AG_TrialLock(i);
			continue;
		}
		if(AG_Ok[i] || !AG_Need[i]) continue;
		TogglePlayerControllable(i, 0);
		if(!AG_DlgOpen[i]) AG_ShowKey(i);
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	#pragma unused listitem
	if(dialogid == AG_DLG_TRIAL_OFFER)
	{
		AG_DlgOpen[playerid] = false;
		if(!response)
		{
			SendClientMessage(playerid, 0xAAAAAAFF, "[Триал] Хорошо, продолжай играть. Предложение больше не появится в этой сессии.");
			return 1;
		}
		AG_DlgOpen[playerid] = true;
		ShowPlayerDialog(playerid, AG_DLG, DIALOG_STYLE_INPUT, "Ввод спецкода",
			"Введи свой спецкод, чтобы открыть полный доступ сейчас.\nЕсли передумал — нажми «Отмена».",
			"Активировать", "Отмена");
		return 1;
	}
	if(dialogid == AG_DLG_TRIAL)
	{
		AG_DlgOpen[playerid] = false;
		if(!response)
		{
			SendClientMessage(playerid, 0xFF4444FF, "Без доступа вход закрыт. Купи код и зайди снова.");
			SetTimerEx("AG_Kick", 1500, false, "i", playerid);
			return 1;
		}
		// Ввести код
		AG_Need[playerid] = true;
		AG_Ok[playerid] = false;
		AG_ShowKey(playerid);
		return 1;
	}
	if(dialogid != AG_DLG) return 0;

	AG_DlgOpen[playerid] = false;

	if(!response)
	{
		if(AG_Trial[playerid] && AG_TrialEnd[playerid] > gettime())
		{
			SendClientMessage(playerid, 0xAAAAAAFF, "[Триал] Ввод кода отменён. Можешь продолжать триал.");
			return 1;
		}
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
	if(AG_Trial[playerid] && AG_TrialEnd[playerid] > gettime())
	{
		AG_DlgOpen[playerid] = true;
		ShowPlayerDialog(playerid, AG_DLG, DIALOG_STYLE_INPUT, "Ввод спецкода",
			"Код не подошёл. Попробуй ещё раз или нажми «Отмена», чтобы продолжить триал.",
			"Активировать", "Отмена");
		return 1;
	}
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
	if(days < 1 || days > 36500)
	{
		SendClientMessage(playerid, 0xFF4444FF, "Invalid code duration.");
		return 1;
	}

	new q[240];
	mysql_format(AG_SQL, q, sizeof q, "UPDATE `fun_codes` SET `used`=1, `to_acc`=%d WHERE `id`=%d LIMIT 1", AG_Acc[playerid], fid);
	mysql_tquery(AG_SQL, q);

	format(AG_Code[playerid], 16, "%s", code);
	AG_Trial[playerid] = false;
	AG_TrialEnd[playerid] = 0;
	AG_TrialRemaining[playerid] = 0;
	if(IsPlayerInAnyVehicle(playerid))
	{
		new trial_vehicle = GetPlayerVehicleID(playerid);
		if(trial_vehicle > 0) SetVehicleVirtualWorld(trial_vehicle, 0);
	}
	SetPlayerVirtualWorld(playerid, 0);
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
	AG_Trial[playerid] = false;
	AG_TrialEnd[playerid] = 0;
	AG_TrialRemaining[playerid] = 0;
	if(IsPlayerInAnyVehicle(playerid))
	{
		new trial_vehicle = GetPlayerVehicleID(playerid);
		if(trial_vehicle > 0) SetVehicleVirtualWorld(trial_vehicle, 0);
	}
	SetPlayerVirtualWorld(playerid, 0);
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
