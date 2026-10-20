/*
	FunTrial.pwn — триал 5 часов для новых аккаунтов (Fun Russia)
	- свой virtual world
	- без чата
	- можно бегать / смотреть сервер
	- после 5ч — сообщение купить доступ (AccessGate)
	filterscripts FunTrial
*/

#include <a_samp>
#include <a_mysql>

#if !defined mysql_tquery
	native mysql_tquery(conn, query[], callback[] = "", format[] = "", {Float,_}:...);
#endif
#if !defined mysql_format
	native mysql_format(conn, output[], len, format[], {Float,_}:...);
#endif
#if !defined cache_get_row_count
	native cache_get_row_count(conn = 1);
	native cache_get_row_int(row, field, conn = 1);
#endif

#define FT_SQL_HOST		"localhost"
#define FT_SQL_USER		"user42665"
#define FT_SQL_PASS		""
#define FT_SQL_DB		"user42665"
#define FT_TRIAL_SEC	(5 * 3600) // 5 часов
#define FT_VW_BASE		50000

new MySQL:FT_SQL;
new bool:FT_SQLOk;
new bool:FT_Trial[MAX_PLAYERS];
new bool:FT_Expired[MAX_PLAYERS];
new bool:FT_LoadRequested[MAX_PLAYERS];
new FT_EndAt[MAX_PLAYERS];
new FT_Acc[MAX_PLAYERS];
new FT_TickTimer;

forward FT_Load(playerid);
forward FT_OnLoad(playerid);
forward FT_Minute();
forward FT_KickTrial(playerid);
forward FT_OnKickCheck(playerid, accountid);

public OnFilterScriptInit()
{
	FT_SQL = mysql_connect(FT_SQL_HOST, FT_SQL_USER, FT_SQL_PASS, FT_SQL_DB);
	FT_SQLOk = (mysql_errno(FT_SQL) == 0);
	if(FT_SQLOk)
	{
		mysql_tquery(FT_SQL, "ALTER TABLE `accounts` ADD COLUMN `fun_trial_end` INT NOT NULL DEFAULT 0");
		mysql_tquery(FT_SQL, "ALTER TABLE `accounts` ADD COLUMN `fun_trial_used` TINYINT NOT NULL DEFAULT 0");
		print("[FunTrial] SQL OK, trial 5h for new accounts");
	}
	else print("[FunTrial] SQL FAIL — trial offline");

	FT_TickTimer = SetTimer("FT_Minute", 60000, true);
	return 1;
}

public OnFilterScriptExit()
{
	if(FT_TickTimer) KillTimer(FT_TickTimer);
	if(FT_SQLOk) mysql_close(FT_SQL);
	return 1;
}

public OnPlayerConnect(playerid)
{
	FT_Trial[playerid] = false;
	FT_Expired[playerid] = false;
	FT_LoadRequested[playerid] = false;
	FT_EndAt[playerid] = 0;
	FT_Acc[playerid] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if(FT_Trial[playerid] && FT_SQLOk && FT_Acc[playerid] > 0)
	{
		new q[120];
		mysql_format(FT_SQL, q, sizeof q,
			"UPDATE `accounts` SET `fun_trial_end`=%d WHERE `id`=%d LIMIT 1",
			FT_EndAt[playerid], FT_Acc[playerid]);
		mysql_tquery(FT_SQL, q);
	}
	FT_Trial[playerid] = false;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(FT_Trial[playerid])
	{
		SetPlayerVirtualWorld(playerid, FT_VW_BASE + playerid);
		FT_ShowHelp(playerid);
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(FT_Trial[playerid])
	{
		SendClientMessage(playerid, 0xFF6666FF, "[Триал] Чат отключён. Только осмотр сервера 5 часов. Купи доступ — пиши в Max.");
		return 0;
	}
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(FT_Trial[playerid])
	{
		// разрешаем минимум, режем опасное
		if(!strcmp(cmdtext, "/trial", true, 6) || !strcmp(cmdtext, "/help", true, 5))
		{
			FT_ShowHelp(playerid);
			return 1;
		}
		SendClientMessage(playerid, 0xFF6666FF, "[Триал] Команды ограничены. Осмотри сервер или купи полный доступ.");
		return 1;
	}
	return 0;
}

// Вызывать после логина (из таймера — ищем account по нику)
public OnPlayerRequestClass(playerid, classid)
{
	#pragma unused classid
	if(FT_SQLOk && !FT_LoadRequested[playerid])
	{
		FT_LoadRequested[playerid] = true;
		SetTimerEx("FT_Load", 8000, false, "i", playerid);
	}
	return 1;
}

public FT_Load(playerid)
{
	if(!IsPlayerConnected(playerid) || !FT_SQLOk) return 1;
	new nick[MAX_PLAYER_NAME], q[220];
	GetPlayerName(playerid, nick, sizeof nick);
	mysql_format(FT_SQL, q, sizeof q,
		"SELECT `id`, IFNULL(`access_ok`,0), IFNULL(`fun_trial_end`,0), IFNULL(`fun_trial_used`,0) FROM `accounts` WHERE `name`='%e' LIMIT 1",
		nick);
	mysql_tquery(FT_SQL, q, "FT_OnLoad", "i", playerid);
	return 1;
}

public FT_OnLoad(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(cache_get_row_count(FT_SQL) < 1) return 1;

	new acc = cache_get_row_int(0, 0, FT_SQL);
	new ok = cache_get_row_int(0, 1, FT_SQL);
	new tend = cache_get_row_int(0, 2, FT_SQL);
	new used = cache_get_row_int(0, 3, FT_SQL);
	FT_Acc[playerid] = acc;

	// Полный доступ — триал не нужен.
	if(ok == 1)
	{
		FT_Trial[playerid] = false;
		FT_Expired[playerid] = false;
		return 1;
	}

	new nowt = gettime();

	// Триал уже использован и истёк: не разрешаем обход ограничений.
	if(used == 1 && tend <= nowt)
	{
		FT_Trial[playerid] = true;
		FT_Expired[playerid] = true;
		FT_EndAt[playerid] = tend;
		SetPlayerVirtualWorld(playerid, FT_VW_BASE + playerid);
		SendClientMessage(playerid, 0xFF4444FF, "[Триал] Бесплатное время закончено. Купи доступ и переподключись.");
		SetTimerEx("FT_KickTrial", 15000, false, "i", playerid);
		return 1;
	}

	// активный триал
	if(tend > nowt)
	{
		FT_Trial[playerid] = true;
		FT_Expired[playerid] = false;
		FT_EndAt[playerid] = tend;
		SetPlayerVirtualWorld(playerid, FT_VW_BASE + playerid);
		FT_Announce(playerid);
		return 1;
	}

	// новый: выдать 5 часов один раз
	if(used == 0 && ok == 0)
	{
		FT_Trial[playerid] = true;
		FT_Expired[playerid] = false;
		FT_EndAt[playerid] = nowt + FT_TRIAL_SEC;
		SetPlayerVirtualWorld(playerid, FT_VW_BASE + playerid);
		new q[180];
		mysql_format(FT_SQL, q, sizeof q,
			"UPDATE `accounts` SET `fun_trial_end`=%d, `fun_trial_used`=1 WHERE `id`=%d LIMIT 1",
			FT_EndAt[playerid], acc);
		mysql_tquery(FT_SQL, q);
		FT_Announce(playerid);
		printf("[FunTrial] start %s acc=%d until %d", FT_Name(playerid), acc, FT_EndAt[playerid]);
		return 1;
	}
	return 1;
}

stock FT_Name(playerid)
{
	new n[MAX_PLAYER_NAME];
	GetPlayerName(playerid, n, sizeof n);
	return n;
}

stock FT_Announce(playerid)
{
	new left = FT_EndAt[playerid] - gettime();
	if(left < 0) left = 0;
	new h = left / 3600, m = (left % 3600) / 60;
	new str[160];
	format(str, sizeof str, "{7CFC00}[Триал] {FFFFFF}Бесплатный осмотр {7CFC00}%d ч %d мин{FFFFFF}. Свой мир, без чата. Понравится — покупай доступ.", h, m);
	SendClientMessage(playerid, -1, str);
	SendClientMessage(playerid, 0xAAAAAAFF, "Команда /trial — подсказка. Полный доступ: спецкод (AccessGate) / Max.");
	FT_ShowHelp(playerid);
	return 1;
}

stock FT_ShowHelp(playerid)
{
	ShowPlayerDialog(playerid, 29801, DIALOG_STYLE_MSGBOX, "Fun Russia — Триал",
		"Добро пожаловать!\n\n\
		Это бесплатный триал на 5 часов.\n\
		Ты в своём виртуальном мире — не мешаешь другим.\n\n\
		Можно: бегать, смотреть локации, привыкнуть к управлению.\n\
		Нельзя: писать в чат, мешать игрокам, полный онлайн.\n\n\
		Понравится сервер — купи доступ (спецкод).\n\
		Код и донат: Max (аналог Telegram для РФ).\n\
		Клиент: FreeSoft + IP сервера с сайта Fun Russia.",
		"OK", "");
	return 1;
}

public FT_Minute()
{
	new nowt = gettime();
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i) || !FT_Trial[i] || FT_Expired[i]) continue;
		if(FT_EndAt[i] <= nowt)
		{
			FT_Expired[i] = true;
			SendClientMessage(i, 0xFF4444FF, "[Триал] 5 часов вышли. Купи доступ, чтобы играть с игроками.");
			GameTextForPlayer(i, "~r~Trial ended", 5000, 3);
			SetTimerEx("FT_KickTrial", 15000, false, "i", i);
		}
		else if((FT_EndAt[i] - nowt) == 600) // 10 мин
			SendClientMessage(i, 0xFFAA00FF, "[Триал] Осталось ~10 минут бесплатного осмотра.");
	}
	return 1;
}

public FT_KickTrial(playerid)
{
	if(!IsPlayerConnected(playerid) || !FT_Expired[playerid] || !FT_SQLOk || FT_Acc[playerid] <= 0) return 1;
	new q[160];
	mysql_format(FT_SQL, q, sizeof q,
		"SELECT IFNULL(`access_ok`,0) FROM `accounts` WHERE `id`=%d LIMIT 1",
		FT_Acc[playerid]);
	mysql_tquery(FT_SQL, q, "FT_OnKickCheck", "ii", playerid, FT_Acc[playerid]);
	return 1;
}

public FT_OnKickCheck(playerid, accountid)
{
	if(!IsPlayerConnected(playerid) || FT_Acc[playerid] != accountid || !FT_Expired[playerid]) return 1;
	if(cache_get_row_count(FT_SQL) > 0 && cache_get_row_int(0, 0, FT_SQL) == 1)
	{
		FT_Trial[playerid] = false;
		FT_Expired[playerid] = false;
		SetPlayerVirtualWorld(playerid, 0);
		SendClientMessage(playerid, 0x7CFC00FF, "Доступ активирован. Приятной игры!");
		return 1;
	}
	SendClientMessage(playerid, 0xFF4444FF, "Триал завершён. После покупки доступа переподключись.");
	Kick(playerid);
	return 1;
}
