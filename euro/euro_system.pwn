/*
	euro_system.pwn
	BEZ Pawn.CMD / sscanf. Tolko a_samp + a_mysql.

	/euro
	/payeuro [id] [сумма]
	/eurohelp

	Payday: +N euro v nachale kazhdogo chasa
	Migraciya: player_euros, euro_transfers

	filterscripts euro_system
	plugins mysql
*/

#define FILTERSCRIPT
#include <a_samp>
#include <a_mysql>

#define EURO_MYSQL_FILE     "bykranin_mysql_settings.ini"
#define EURO_CFG_FILE       "euro_system.ini"
#define EURO_LOG_FILE       "euro_system.log"

#define COLOR_EURO          0x3498DBFF
#define COLOR_EURO_OK       0x2ECC71FF
#define COLOR_EURO_ERR      0xFF5555FF
#define COLOR_EURO_DIM      0xAAAAAAFF

new gEU_SQL = 1;
new gEU_Ready = 0;
new gEU_PayTimer = -1;
new gEU_LastHour = -1;
new gEU_PayAmount = 10;
new gEU_MinTransfer = 1;
new gEU_MaxTransfer = 10000;

new gEU_Host[64], gEU_User[64], gEU_Pass[64], gEU_Db[64];
new gEU_Balance[MAX_PLAYERS];
new gEU_Acc[MAX_PLAYERS];
new gEU_Loaded[MAX_PLAYERS];

stock EU_Log(const txt[])
{
	printf("[EURO] %s", txt);
	new File:f = fopen(EURO_LOG_FILE, io_append);
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

stock EU_Trim(str[])
{
	new len = strlen(str);
	while(len > 0 && (str[len-1] == '\r' || str[len-1] == '\n' || str[len-1] == ' ' || str[len-1] == '\t'))
	{ str[len-1] = 0; len--; }
	new st = 0;
	while(str[st] == ' ' || str[st] == '\t') st++;
	if(st > 0)
	{
		new i;
		for(i = 0; str[st+i]; i++) str[i] = str[st+i];
		str[i] = 0;
	}
	return 1;
}

stock EU_LoadMysqlCfg()
{
	gEU_Host[0] = gEU_User[0] = gEU_Pass[0] = gEU_Db[0] = 0;
	if(!fexist(EURO_MYSQL_FILE)) return 0;
	new File:f = fopen(EURO_MYSQL_FILE, io_read);
	if(!f) return 0;
	new line[128];
	while(fread(f, line))
	{
		EU_Trim(line);
		if(!line[0] || line[0] == ';' || line[0] == '#') continue;
		new eq = -1, i;
		for(i = 0; line[i]; i++) if(line[i] == '=') { eq = i; break; }
		if(eq <= 0) continue;
		new key[32], val[64], k = eq;
		if(k > 31) k = 31;
		for(i = 0; i < k; i++) key[i] = line[i];
		key[k] = 0; EU_Trim(key);
		new v = 0; i = eq + 1;
		while(line[i] && v < 63) { val[v] = line[i]; v++; i++; }
		val[v] = 0; EU_Trim(val);
		if(!strcmp(key, "host", true)) format(gEU_Host, sizeof(gEU_Host), "%s", val);
		else if(!strcmp(key, "username", true) || !strcmp(key, "user", true)) format(gEU_User, sizeof(gEU_User), "%s", val);
		else if(!strcmp(key, "password", true) || !strcmp(key, "pass", true)) format(gEU_Pass, sizeof(gEU_Pass), "%s", val);
		else if(!strcmp(key, "database", true) || !strcmp(key, "db", true)) format(gEU_Db, sizeof(gEU_Db), "%s", val);
	}
	fclose(f);
	return (gEU_Host[0] && gEU_User[0] && gEU_Db[0]);
}

stock EU_LoadCfg()
{
	if(!fexist(EURO_CFG_FILE))
	{
		new File:fw = fopen(EURO_CFG_FILE, io_write);
		if(fw)
		{
			fwrite(fw, "payday_euro=10\r\nmin_transfer=1\r\nmax_transfer=10000\r\n");
			fclose(fw);
		}
	}
	new File:f = fopen(EURO_CFG_FILE, io_read);
	if(!f) return 0;
	new line[128];
	while(fread(f, line))
	{
		EU_Trim(line);
		if(!line[0] || line[0] == ';' || line[0] == '#') continue;
		new eq = -1, i;
		for(i = 0; line[i]; i++) if(line[i] == '=') { eq = i; break; }
		if(eq <= 0) continue;
		new key[32], val[32], k = eq;
		if(k > 31) k = 31;
		for(i = 0; i < k; i++) key[i] = line[i];
		key[k] = 0; EU_Trim(key);
		new v = 0; i = eq + 1;
		while(line[i] && v < 31) { val[v] = line[i]; v++; i++; }
		val[v] = 0; EU_Trim(val);
		if(!strcmp(key, "payday_euro", true)) gEU_PayAmount = strval(val);
		else if(!strcmp(key, "min_transfer", true)) gEU_MinTransfer = strval(val);
		else if(!strcmp(key, "max_transfer", true)) gEU_MaxTransfer = strval(val);
	}
	fclose(f);
	if(gEU_PayAmount < 0) gEU_PayAmount = 0;
	if(gEU_MinTransfer < 1) gEU_MinTransfer = 1;
	return 1;
}

stock EU_Connect()
{
	gEU_SQL = mysql_connect(gEU_Host, gEU_User, gEU_Db, gEU_Pass);
	if(mysql_errno(gEU_SQL) != 0) { gEU_SQL = 1; return 0; }
	return 1;
}

stock EU_Migrate()
{
	mysql_tquery(gEU_SQL,
		"CREATE TABLE IF NOT EXISTS `player_euros` (`account_id` INT NOT NULL, `amount` INT NOT NULL DEFAULT 0, `total_earned` INT NOT NULL DEFAULT 0, `total_sent` INT NOT NULL DEFAULT 0, `total_received` INT NOT NULL DEFAULT 0, `updated_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251",
		"", "");
	mysql_tquery(gEU_SQL,
		"CREATE TABLE IF NOT EXISTS `euro_transfers` (`id` INT NOT NULL AUTO_INCREMENT, `from_account` INT NOT NULL, `to_account` INT NOT NULL, `amount` INT NOT NULL, `created_at` INT NOT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251",
		"", "");
	EU_Log("migration OK");
	return 1;
}

stock EU_GetAcc(playerid)
{
	new id;
	id = GetPVarInt(playerid, "AccountID"); if(id > 0) return id;
	id = GetPVarInt(playerid, "account_id"); if(id > 0) return id;
	id = GetPVarInt(playerid, "pSQLID"); if(id > 0) return id;
	id = GetPVarInt(playerid, "SQL_ID"); if(id > 0) return id;
	id = CallRemoteFunction("GetPlayerAccountID", "i", playerid);
	if(id > 0) return id;
	return 0;
}

stock EU_LoadPlayer(playerid)
{
	gEU_Balance[playerid] = 0;
	gEU_Loaded[playerid] = 0;
	gEU_Acc[playerid] = 0;
	new acc = EU_GetAcc(playerid);
	if(acc <= 0)
	{
		SetTimerEx("EU_RetryLoad", 3000, false, "i", playerid);
		return 0;
	}
	gEU_Acc[playerid] = acc;
	new q[120];
	mysql_format(gEU_SQL, q, sizeof(q), "SELECT amount FROM player_euros WHERE account_id=%d LIMIT 1", acc);
	mysql_tquery(gEU_SQL, q, "EU_OnBalance", "i", playerid);
	return 1;
}

forward EU_RetryLoad(playerid);
public EU_RetryLoad(playerid)
{
	if(!IsPlayerConnected(playerid) || gEU_Loaded[playerid]) return 0;
	EU_LoadPlayer(playerid);
	return 1;
}

forward EU_OnBalance(playerid);
public EU_OnBalance(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(cache_get_row_count(gEU_SQL) > 0)
	{
		gEU_Balance[playerid] = cache_get_field_content_int(0, "amount", gEU_SQL);
		gEU_Loaded[playerid] = 1;
	}
	else
	{
		new acc = gEU_Acc[playerid];
		if(acc <= 0) acc = EU_GetAcc(playerid);
		if(acc > 0)
		{
			new q[160];
			mysql_format(gEU_SQL, q, sizeof(q),
				"INSERT INTO player_euros (account_id, amount, updated_at) VALUES (%d, 0, %d)", acc, gettime());
			mysql_tquery(gEU_SQL, q, "", "");
			gEU_Acc[playerid] = acc;
			gEU_Balance[playerid] = 0;
			gEU_Loaded[playerid] = 1;
		}
	}
	return 1;
}

stock EU_Save(playerid)
{
	if(!gEU_Loaded[playerid] || gEU_Acc[playerid] <= 0) return 0;
	new q[160];
	mysql_format(gEU_SQL, q, sizeof(q),
		"UPDATE player_euros SET amount=%d, updated_at=%d WHERE account_id=%d",
		gEU_Balance[playerid], gettime(), gEU_Acc[playerid]);
	mysql_tquery(gEU_SQL, q, "", "");
	return 1;
}

stock EU_AddEarn(playerid, amount)
{
	if(!gEU_Loaded[playerid] || amount <= 0) return 0;
	gEU_Balance[playerid] += amount;
	new q[220];
	mysql_format(gEU_SQL, q, sizeof(q),
		"UPDATE player_euros SET amount=%d, total_earned=total_earned+%d, updated_at=%d WHERE account_id=%d",
		gEU_Balance[playerid], amount, gettime(), gEU_Acc[playerid]);
	mysql_tquery(gEU_SQL, q, "", "");
	return 1;
}

forward EU_PayDayTick();
public EU_PayDayTick()
{
	if(!gEU_Ready || gEU_PayAmount <= 0) return 0;
	new h, m, s;
	gettime(h, m, s);
	if(m > 1) return 1;
	if(gEU_LastHour == h) return 1;
	gEU_LastHour = h;

	new i, cnt, msg[100];
	for(i = 0; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		if(IsPlayerNPC(i)) continue;
		if(!gEU_Loaded[i]) continue;
		if(GetPlayerState(i) == PLAYER_STATE_NONE) continue;

		EU_AddEarn(i, gEU_PayAmount);
		format(msg, sizeof(msg), "[EURO] Payday! +%d евро. Баланс: %d", gEU_PayAmount, gEU_Balance[i]);
		SendClientMessage(i, COLOR_EURO_OK, msg);
		cnt++;
	}
	format(msg, sizeof(msg), "payday h=%d n=%d", h, cnt);
	EU_Log(msg);
	return 1;
}

stock EU_Transfer(playerid, targetid, amount)
{
	if(playerid == targetid) { SendClientMessage(playerid, COLOR_EURO_ERR, "[EURO] Нельзя себе."); return 0; }
	if(!gEU_Loaded[playerid] || !gEU_Loaded[targetid])
	{ SendClientMessage(playerid, COLOR_EURO_ERR, "[EURO] Баланс не загружен."); return 0; }
	if(amount < gEU_MinTransfer || amount > gEU_MaxTransfer)
	{ SendClientMessage(playerid, COLOR_EURO_ERR, "[EURO] Сумма вне лимита."); return 0; }
	if(gEU_Balance[playerid] < amount)
	{ SendClientMessage(playerid, COLOR_EURO_ERR, "[EURO] Мало евро."); return 0; }

	gEU_Balance[playerid] -= amount;
	gEU_Balance[targetid] += amount;

	new q[240];
	mysql_format(gEU_SQL, q, sizeof(q),
		"UPDATE player_euros SET amount=%d, total_sent=total_sent+%d, updated_at=%d WHERE account_id=%d",
		gEU_Balance[playerid], amount, gettime(), gEU_Acc[playerid]);
	mysql_tquery(gEU_SQL, q, "", "");
	mysql_format(gEU_SQL, q, sizeof(q),
		"UPDATE player_euros SET amount=%d, total_received=total_received+%d, updated_at=%d WHERE account_id=%d",
		gEU_Balance[targetid], amount, gettime(), gEU_Acc[targetid]);
	mysql_tquery(gEU_SQL, q, "", "");
	mysql_format(gEU_SQL, q, sizeof(q),
		"INSERT INTO euro_transfers (from_account, to_account, amount, created_at) VALUES (%d,%d,%d,%d)",
		gEU_Acc[playerid], gEU_Acc[targetid], amount, gettime());
	mysql_tquery(gEU_SQL, q, "", "");

	new n1[24], n2[24], msg[120];
	GetPlayerName(playerid, n1, sizeof n1);
	GetPlayerName(targetid, n2, sizeof n2);
	format(msg, sizeof msg, "[EURO] Передано %d евро -> %s. Осталось: %d", amount, n2, gEU_Balance[playerid]);
	SendClientMessage(playerid, COLOR_EURO_OK, msg);
	format(msg, sizeof msg, "[EURO] %s передал вам %d евро. Баланс: %d", n1, amount, gEU_Balance[targetid]);
	SendClientMessage(targetid, COLOR_EURO_OK, msg);
	return 1;
}

stock EU_CmdPayEuro(playerid, params[])
{
	new targetid, amount, id_str[8], amt_str[16], pos = -1, i, j;
	if(!params[0])
	{
		SendClientMessage(playerid, COLOR_EURO_DIM, "[EURO] /payeuro [id] [сумма]");
		return 1;
	}
	for(i = 0; params[i]; i++) if(params[i] == ' ') { pos = i; break; }
	if(pos <= 0)
	{
		SendClientMessage(playerid, COLOR_EURO_DIM, "[EURO] /payeuro [id] [сумма]");
		return 1;
	}
	for(j = 0; j < pos && j < 7; j++) id_str[j] = params[j];
	id_str[j] = 0;
	targetid = strval(id_str);
	j = 0; i = pos + 1;
	while(params[i] == ' ') i++;
	while(params[i] && j < 15) { amt_str[j] = params[i]; j++; i++; }
	amt_str[j] = 0;
	amount = strval(amt_str);

	if(targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid))
	{
		SendClientMessage(playerid, COLOR_EURO_ERR, "[EURO] Игрок не найден.");
		return 1;
	}
	if(amount <= 0)
	{
		SendClientMessage(playerid, COLOR_EURO_ERR, "[EURO] Сумма > 0.");
		return 1;
	}
	EU_Transfer(playerid, targetid, amount);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/euro", true))
	{
		if(!gEU_Ready) { SendClientMessage(playerid, COLOR_EURO_ERR, "[EURO] Не готово."); return 1; }
		if(!gEU_Loaded[playerid]) { EU_LoadPlayer(playerid); SendClientMessage(playerid, COLOR_EURO_DIM, "[EURO] Загрузка..."); return 1; }
		new msg[90];
		format(msg, sizeof msg, "[EURO] Баланс: %d евро | Payday +%d/час", gEU_Balance[playerid], gEU_PayAmount);
		SendClientMessage(playerid, COLOR_EURO, msg);
		return 1;
	}
	if(!strcmp(cmdtext, "/eurohelp", true))
	{
		SendClientMessage(playerid, COLOR_EURO, "=== EURO ===");
		SendClientMessage(playerid, COLOR_EURO_DIM, "/euro — баланс");
		SendClientMessage(playerid, COLOR_EURO_DIM, "/payeuro [id] [сумма]");
		return 1;
	}
	if(strfind(cmdtext, "/payeuro", true) == 0)
	{
		new params[64];
		params[0] = 0;
		if(strlen(cmdtext) > 9)
		{
			new i, j = 0, start = 9;
			while(cmdtext[start] == ' ') start++;
			for(i = start; cmdtext[i] && j < 63; i++) { params[j] = cmdtext[i]; j++; }
			params[j] = 0;
		}
		EU_CmdPayEuro(playerid, params);
		return 1;
	}
	return 0;
}

public OnFilterScriptInit()
{
	new i;
	for(i = 0; i < MAX_PLAYERS; i++) { gEU_Balance[i] = 0; gEU_Acc[i] = 0; gEU_Loaded[i] = 0; }
	gEU_Ready = 0;
	gEU_LastHour = -1;
	print("  [EURO] loading...");
	EU_LoadCfg();
	if(!EU_LoadMysqlCfg() || !EU_Connect())
	{
		print("  [EURO] FAIL mysql");
		return 1;
	}
	EU_Migrate();
	gEU_Ready = 1;
	gEU_PayTimer = SetTimer("EU_PayDayTick", 60000, true);
	printf("  [EURO] OK +%d/hour (no pawncmd)", gEU_PayAmount);
	return 1;
}

public OnFilterScriptExit()
{
	if(gEU_PayTimer != -1) KillTimer(gEU_PayTimer);
	new i;
	for(i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && gEU_Loaded[i]) EU_Save(i);
	if(gEU_Ready) mysql_close(gEU_SQL);
	return 1;
}

public OnPlayerConnect(playerid)
{
	gEU_Balance[playerid] = 0;
	gEU_Acc[playerid] = 0;
	gEU_Loaded[playerid] = 0;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(!gEU_Loaded[playerid] && gEU_Ready)
		SetTimerEx("EU_RetryLoad", 1500, false, "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if(gEU_Loaded[playerid]) EU_Save(playerid);
	gEU_Balance[playerid] = 0;
	gEU_Acc[playerid] = 0;
	gEU_Loaded[playerid] = 0;
	return 1;
}
