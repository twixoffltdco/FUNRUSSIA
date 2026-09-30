/*
	inactive_auction.pwn
	============================================
	3 dnya oflajn | 30 min otygrovki za zahod
	Lichnyj dom / biznes / garazh -> gosudarstvo
	Semejnye doma (FamilyHouse) NE trogaem.
	Bez komand.

	filterscripts inactive_auction
	plugin mysql
	scriptfiles/bykranin_mysql_settings.ini
*/

#define FILTERSCRIPT
#include <a_samp>
#include <a_mysql>

#define IA_DAYS             3
#define IA_INACTIVE_SEC     (IA_DAYS * 24 * 60 * 60)
#define IA_NEED_PLAY_SEC    (30 * 60)
#define IA_CHECK_MS         (30 * 60 * 1000)
#define IA_MYSQL_FILE       "bykranin_mysql_settings.ini"
#define IA_LOG_FILE         "inactive_auction.log"

#define COLOR_IA            0x2ECC71FF
#define COLOR_IA_WARN       0xF1C40FFF

new gIA_SQL = 1;
new gIA_Timer = -1;
new gIA_Ready = 0;
new gIA_SessionStart[MAX_PLAYERS];
new gIA_Protected[MAX_PLAYERS];

new gIA_Host[64];
new gIA_User[64];
new gIA_Pass[64];
new gIA_Db[64];

stock IA_Log(const txt[])
{
	printf("[IA] %s", txt);
	new File:f = fopen(IA_LOG_FILE, io_append);
	if(f)
	{
		new line[200], y, mo, d, h, mi, s;
		getdate(y, mo, d);
		gettime(h, mi, s);
		format(line, sizeof(line), "[%02d.%02d.%04d %02d:%02d:%02d] %s\r\n", d, mo, y, h, mi, s, txt);
		fwrite(f, line);
		fclose(f);
	}
	return 1;
}

stock IA_Trim(str[])
{
	new len = strlen(str);
	while(len > 0 && (str[len-1] == '\r' || str[len-1] == '\n' || str[len-1] == ' ' || str[len-1] == '\t'))
	{
		str[len-1] = 0;
		len--;
	}
	new st = 0;
	while(str[st] == ' ' || str[st] == '\t') st++;
	if(st > 0)
	{
		new i;
		for(i = 0; str[st + i]; i++) str[i] = str[st + i];
		str[i] = 0;
	}
	return 1;
}

stock IA_LoadCfg()
{
	gIA_Host[0] = 0;
	gIA_User[0] = 0;
	gIA_Pass[0] = 0;
	gIA_Db[0] = 0;

	if(!fexist(IA_MYSQL_FILE))
	{
		IA_Log("ERROR: no bykranin_mysql_settings.ini");
		return 0;
	}

	new File:f = fopen(IA_MYSQL_FILE, io_read);
	if(!f) return 0;

	new line[128];
	while(fread(f, line))
	{
		IA_Trim(line);
		if(!line[0] || line[0] == ';' || line[0] == '#') continue;

		new eq = -1, i;
		for(i = 0; line[i]; i++)
		{
			if(line[i] == '=')
			{
				eq = i;
				break;
			}
		}
		if(eq <= 0) continue;

		new key[32], val[64], k, v;
		k = eq;
		if(k > 31) k = 31;
		for(i = 0; i < k; i++) key[i] = line[i];
		key[k] = 0;
		IA_Trim(key);

		v = 0;
		i = eq + 1;
		while(line[i] && v < 63)
		{
			val[v] = line[i];
			v++;
			i++;
		}
		val[v] = 0;
		IA_Trim(val);

		if(!strcmp(key, "host", true)) format(gIA_Host, sizeof(gIA_Host), "%s", val);
		else if(!strcmp(key, "username", true)) format(gIA_User, sizeof(gIA_User), "%s", val);
		else if(!strcmp(key, "user", true)) format(gIA_User, sizeof(gIA_User), "%s", val);
		else if(!strcmp(key, "password", true)) format(gIA_Pass, sizeof(gIA_Pass), "%s", val);
		else if(!strcmp(key, "pass", true)) format(gIA_Pass, sizeof(gIA_Pass), "%s", val);
		else if(!strcmp(key, "database", true)) format(gIA_Db, sizeof(gIA_Db), "%s", val);
		else if(!strcmp(key, "db", true)) format(gIA_Db, sizeof(gIA_Db), "%s", val);
	}
	fclose(f);

	if(!gIA_Host[0] || !gIA_User[0] || !gIA_Db[0])
	{
		IA_Log("ERROR: mysql ini incomplete");
		return 0;
	}
	return 1;
}

stock IA_Connect()
{
	// host, user, database, password - kak v gamemode
	gIA_SQL = mysql_connect(gIA_Host, gIA_User, gIA_Db, gIA_Pass);
	if(mysql_errno(gIA_SQL) != 0)
	{
		IA_Log("ERROR: mysql connect failed");
		gIA_SQL = 1;
		return 0;
	}
	IA_Log("MySQL OK");
	return 1;
}

stock IA_GetAccID(playerid)
{
	new id;
	id = GetPVarInt(playerid, "AccountID");
	if(id > 0) return id;
	id = GetPVarInt(playerid, "account_id");
	if(id > 0) return id;
	id = GetPVarInt(playerid, "pSQLID");
	if(id > 0) return id;
	id = GetPVarInt(playerid, "SQL_ID");
	if(id > 0) return id;
	id = CallRemoteFunction("GetPlayerAccountID", "i", playerid);
	if(id > 0) return id;
	return 0;
}

stock IA_IsOnlineAcc(acc_id)
{
	new p, id;
	for(p = 0; p < MAX_PLAYERS; p++)
	{
		if(!IsPlayerConnected(p)) continue;
		id = IA_GetAccID(p);
		if(id == acc_id) return 1;
	}
	return 0;
}

forward IA_PlayTick(playerid);
public IA_PlayTick(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(gIA_Protected[playerid]) return 0;

	new played = gettime() - gIA_SessionStart[playerid];
	if(played < IA_NEED_PLAY_SEC) return 0;

	gIA_Protected[playerid] = 1;

	new acc = IA_GetAccID(playerid);
	if(acc > 0 && gIA_Ready)
	{
		new q[96];
		mysql_format(gIA_SQL, q, sizeof(q), "UPDATE accounts SET last_login=%d WHERE id=%d", gettime(), acc);
		mysql_tquery(gIA_SQL, q, "", "");
	}

	SendClientMessage(playerid, COLOR_IA, "[Имущество] Вы отыграли 30 минут. Дом, бизнес и гараж защищены.");
	return 1;
}

forward IA_DoCheck();
public IA_DoCheck()
{
	if(!gIA_Ready) return 0;

	new th = gettime() - IA_INACTIVE_SEC;
	new q[420];

	format(q, sizeof(q),
		"SELECT a.id, a.name FROM accounts a WHERE a.last_login > 0 AND a.last_login < %d AND (EXISTS(SELECT 1 FROM houses h WHERE h.owner_id=a.id) OR EXISTS(SELECT 1 FROM business b WHERE b.owner_id=a.id) OR EXISTS(SELECT 1 FROM garages g WHERE g.owner_id=a.id)) LIMIT 100",
		th);

	mysql_tquery(gIA_SQL, q, "IA_OnFound", "");
	return 1;
}

forward IA_OnFound();
public IA_OnFound()
{
	new rows = cache_get_row_count(gIA_SQL);
	if(rows <= 0)
	{
		IA_Log("no inactive owners");
		return 1;
	}

	new i, acc, name[24], msg[120];
	format(msg, sizeof(msg), "found: %d", rows);
	IA_Log(msg);

	for(i = 0; i < rows; i++)
	{
		acc = cache_get_field_content_int(i, "id", gIA_SQL);
		cache_get_field_content(i, "name", name, gIA_SQL, sizeof(name));

		if(IA_IsOnlineAcc(acc)) continue;
		IA_Seize(acc, name);
	}
	return 1;
}

stock IA_Seize(acc, const name[])
{
	new q[180], msg[140];

	mysql_format(gIA_SQL, q, sizeof(q), "UPDATE houses SET owner_id=0, improvements=0, `lock`=0 WHERE owner_id=%d", acc);
	mysql_tquery(gIA_SQL, q, "", "");

	mysql_format(gIA_SQL, q, sizeof(q), "UPDATE business SET owner_id=0, improvements=0, ownership_started_at=0 WHERE owner_id=%d", acc);
	mysql_tquery(gIA_SQL, q, "", "");

	mysql_format(gIA_SQL, q, sizeof(q), "UPDATE garages SET owner_id=0, improvements=0, `lock`=0 WHERE owner_id=%d", acc);
	mysql_tquery(gIA_SQL, q, "", "");

	mysql_format(gIA_SQL, q, sizeof(q), "UPDATE accounts SET house=-1, house_type=-1, business=-1, garage=-1 WHERE id=%d", acc);
	mysql_tquery(gIA_SQL, q, "", "");

	format(msg, sizeof(msg), "SEIZE %s acc=%d -> state", name, acc);
	IA_Log(msg);

	CallRemoteFunction("IA_OnPropertySeized", "is", acc, name);
	return 1;
}

public OnFilterScriptInit()
{
	new p;
	gIA_Ready = 0;
	gIA_SQL = 1;

	for(p = 0; p < MAX_PLAYERS; p++)
	{
		gIA_SessionStart[p] = 0;
		gIA_Protected[p] = 0;
	}

	print(" ");
	print("  [IA] inactive_auction loading...");

	if(!IA_LoadCfg())
	{
		print("  [IA] FAIL cfg");
		print(" ");
		return 1;
	}
	if(!IA_Connect())
	{
		print("  [IA] FAIL mysql");
		print(" ");
		return 1;
	}

	gIA_Ready = 1;
	gIA_Timer = SetTimer("IA_DoCheck", IA_CHECK_MS, true);
	SetTimer("IA_DoCheck", 60000, false);

	print("  [IA] OK | 3 days | 30 min play | personal only");
	print(" ");
	return 1;
}

public OnFilterScriptExit()
{
	if(gIA_Timer != -1) KillTimer(gIA_Timer);
	if(gIA_SQL && gIA_Ready) mysql_close(gIA_SQL);
	return 1;
}

public OnPlayerConnect(playerid)
{
	gIA_SessionStart[playerid] = gettime();
	gIA_Protected[playerid] = 0;

	SendClientMessage(playerid, COLOR_IA_WARN, "========================================");
	SendClientMessage(playerid, COLOR_IA_WARN, "[Имущество] Чтобы дом, бизнес и гараж НЕ ушли в гос:");
	SendClientMessage(playerid, COLOR_IA_WARN, "[Имущество] нужно отыграть минимум 30 минут за заход.");
	SendClientMessage(playerid, COLOR_IA_WARN, "[Имущество] Если не заходить 3 дня — имущество слетает.");
	SendClientMessage(playerid, COLOR_IA_WARN, "[Имущество] Семейные дома (Family) не трогаются.");
	SendClientMessage(playerid, COLOR_IA_WARN, "========================================");

	SetTimerEx("IA_PlayTick", (IA_NEED_PLAY_SEC + 2) * 1000, false, "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason

	if(gIA_Protected[playerid] && gIA_Ready)
	{
		new acc = IA_GetAccID(playerid);
		if(acc > 0)
		{
			new q[96];
			mysql_format(gIA_SQL, q, sizeof(q), "UPDATE accounts SET last_login=%d WHERE id=%d", gettime(), acc);
			mysql_tquery(gIA_SQL, q, "", "");
		}
	}

	gIA_SessionStart[playerid] = 0;
	gIA_Protected[playerid] = 0;
	return 1;
}
