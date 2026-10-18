/*
	EuroSystem.pwn - Euro + Bit + Memecoin (Alabuga)
	.euro .bit .meme
	ASCII UI (no encoding break)
*/

#define FILTERSCRIPT
#include <a_samp>
#include <a_mysql>
#include <a_http>

#if !defined MYSQL_INVALID_HANDLE
	#define MYSQL_INVALID_HANDLE (0)
#endif

#define MYSQL_FILE			"bykranin_mysql_settings.ini"
#define EURO_PAYDAY			10
#define BIT_PAYDAY			5
#define EURO_FAMILY_PRICE	100000
#define BIT_FEE_PCT			5
#define EURO_TO_BIT_FEE_PCT	20
#define BIT_TRANSFER_FEE_PCT	20
#define MEME_FEE_PCT			50
#define MEME_GROW_PCT_DAY		2
#define MEME_OFFLINE_DAYS		30
#define MEME_ANNOUNCE_MS		300000
#define MEME_FLY_PRICE			10
#define MEME_FLY_SECONDS		90
#define MEME_RAND_BASE			5000
#define UAH_ADMIN_PRICE			200000
#define UAH_LEADER_PRICE		200000
#define KZT_FEE_PCT				70
#define UAH_FEE_PCT				90
#define KZT_TRANSFER_FEE_PCT	20
#define UAH_TRANSFER_FEE_PCT	20
#define EURO_TUNE_PRICE			10000
#define PLAY_HOURS_REWARD		12

#define MEME_NAME			"Алабуга"
#define MEME_END_YEAR		2028
#define MEME_END_MONTH		12
#define MEME_END_DAY		31
#define MEME_END_HOUR		23
#define MEME_END_MIN		59

#define COLOR_EURO			0xFFD700FF
#define COLOR_BIT			0x00BFFFFF
#define COLOR_MEME			0xFF69B4FF
#define COLOR_ERR			0xFF6347FF

#define D_EURO_MENU			29510
#define D_EURO_GIVE			29511
#define D_EURO_GIVE_AMT		29512
#define D_EURO_TOP			29514
#define D_EURO_EX			29515
#define D_EURO_EX_AMT		29516
#define D_EURO_BUY_AMT		29518
#define D_EURO_SKIN			29520
#define D_EURO_ACS			29521
#define D_EURO_CAR			29522
#define D_EURO_FAM_NAME		29523
#define D_EURO_FAM_OK		29524
#define D_BIT_MENU			29530
#define D_BIT_GIVE			29531
#define D_BIT_GIVE_AMT		29532
#define D_BIT_EX			29533
#define D_BIT_EX_AMT		29534
#define D_BIT_TOP			29535
#define D_E2B_AMT			29536
#define D_B2E_AMT			29537
#define D_MEME_MENU			29540
#define D_MEME_EX_AMT		29542
#define D_MEME_GIVE			29543
#define D_MEME_GIVE_AMT		29544
#define D_MEME_TOP			29545
#define D_MEME_DONATE		29546
#define D_MEME_FROM_EUR		29547
#define D_MEME_FROM_BIT		29548
#define D_UAH_MENU			29550
#define D_KZT_MENU			29551
#define D_KZT_EX			29552
#define D_KZT_EX_AMT		29553
#define D_MEME_FLY_OK		29554
#define D_MEME_RAND_OK		29555
#define D_UAH_TOP			29556
#define D_KZT_TOP			29557
#define D_UAH_GIVE			29558
#define D_UAH_GIVE_AMT		29559
#define D_KZT_GIVE			29560
#define D_KZT_GIVE_AMT		29561
#define D_UAH_EX_AMT		29562
#define D_EURO_TUNE			29563
#define D_MEME_SEASON_REW	29564
#define D_FUN_MENU			29570
#define D_FUN_GIVE			29571
#define D_FUN_GIVE_AMT		29572
#define D_FUN_EX_AMT		29573
#define D_FUN_CODE_NICK		29574
#define D_FUN_CODE_DAYS		29575
#define D_FUN_CODE_LIST		29576
#define D_FUN_ACTIVATE		29577
#define D_FUN_TOP			29578

#define FUN_HOUR_REWARD		200
#define FUN_CODE_PRICE		500
#define FUN_FEE_PCT			99
#define FUN_DAYS_30			30
#define FUN_DAYS_365		365

#define ITEM_SKIN			134

new Float:gEuroRate = 94.97;
new Float:gBitRate = 6500000.0;
new Float:gMemeRate = 100.0;
new Float:gUahRate = 2.5;   // RUB per 1 UAH approx
new Float:gKztRate = 0.18;  // RUB per 1 KZT approx
new gSQL, gSQLOk;
new SQL_Host[64], SQL_User[64], SQL_Pass[128], SQL_DB[64];
new PlayerEuro[MAX_PLAYERS], PlayerEuroEx[MAX_PLAYERS], PlayerAccID[MAX_PLAYERS];
new PlayerBit[MAX_PLAYERS], PlayerMeme[MAX_PLAYERS], PlayerDonate[MAX_PLAYERS];
new PlayerUAH[MAX_PLAYERS], PlayerKZT[MAX_PLAYERS], PlayerFun[MAX_PLAYERS];
new FunGiveTarget[MAX_PLAYERS];
new FunCodeNick[MAX_PLAYERS][MAX_PLAYER_NAME];
new FunCodeDays[MAX_PLAYERS];
new FunListIds[MAX_PLAYERS][12]; // code row ids for revoke menu
new FunListCount[MAX_PLAYERS];
new EuroMenuTick[MAX_PLAYERS];
new PlayerPlaySec[MAX_PLAYERS], PlayerRandBuys[MAX_PLAYERS];
new PlayerFlyTimer[MAX_PLAYERS];
new KztExMode[MAX_PLAYERS];
new PlayerLastLogin[MAX_PLAYERS];
new bool:PlayerLoaded[MAX_PLAYERS];
new EuroGiveTarget[MAX_PLAYERS], EuroExMode[MAX_PLAYERS], EuroBuyMode[MAX_PLAYERS];
new BitGiveTarget[MAX_PLAYERS], BitExMode[MAX_PLAYERS];
new MemeGiveTarget[MAX_PLAYERS], MemeExMode[MAX_PLAYERS];
new UahGiveTarget[MAX_PLAYERS], UahExMode[MAX_PLAYERS];
new KztGiveTarget[MAX_PLAYERS];
new PlayerFlyActive[MAX_PLAYERS];
new LastPaydayHour = -1;
new FamilyNamePending[MAX_PLAYERS][32];
new bool:gMemeSeasonEnded = false;
new gMemeName[32];              // текущий сезон (из БД)
new gMemeEndY, gMemeEndMo, gMemeEndD, gMemeEndH, gMemeEndMi;
new bool:gMemeSeasonLoaded = false;


stock trim(s[])
{
	new a, b = strlen(s);
	while(a < b && s[a] <= ' ') a++;
	while(b > a && s[b - 1] <= ' ') b--;
	strdel(s, b, strlen(s));
	if(a) strdel(s, 0, a);
}

stock bool:MemeSeasonActive()
{
	if(!gMemeSeasonLoaded) return false;
	new y, mo, d, h, mi, s;
	getdate(y, mo, d);
	gettime(h, mi, s);
	#pragma unused s
	if(y > gMemeEndY) return false;
	if(y < gMemeEndY) return true;
	if(mo > gMemeEndMo) return false;
	if(mo < gMemeEndMo) return true;
	if(d > gMemeEndD) return false;
	if(d < gMemeEndD) return true;
	if(h > gMemeEndH) return false;
	if(h < gMemeEndH) return true;
	if(mi > gMemeEndMi) return false;
	return true;
}

// Записать текущий сезон в БД
stock MemeSaveSeasonToDB()
{
	if(!gSQLOk) return 0;
	new q[320];
	mysql_format(gSQL, q, sizeof q,
		"CREATE TABLE IF NOT EXISTS `memecoin_season` (`id` INT NOT NULL PRIMARY KEY, `name` VARCHAR(32) NOT NULL, `end_y` INT NOT NULL, `end_mo` INT NOT NULL, `end_d` INT NOT NULL, `end_h` INT NOT NULL, `end_mi` INT NOT NULL)");
	mysql_tquery(gSQL, q);
	mysql_format(gSQL, q, sizeof q,
		"INSERT INTO `memecoin_season` (`id`,`name`,`end_y`,`end_mo`,`end_d`,`end_h`,`end_mi`) VALUES (1,'%e',%d,%d,%d,%d,%d) ON DUPLICATE KEY UPDATE `name`='%e',`end_y`=%d,`end_mo`=%d,`end_d`=%d,`end_h`=%d,`end_mi`=%d",
		gMemeName, gMemeEndY, gMemeEndMo, gMemeEndD, gMemeEndH, gMemeEndMi,
		gMemeName, gMemeEndY, gMemeEndMo, gMemeEndD, gMemeEndH, gMemeEndMi);
	mysql_tquery(gSQL, q);
	return 1;
}

// Применить сезон из #define (новый сезон)
stock MemeApplyDefinesAsSeason()
{
	format(gMemeName, sizeof gMemeName, "%s", MEME_NAME);
	gMemeEndY = MEME_END_YEAR;
	gMemeEndMo = MEME_END_MONTH;
	gMemeEndD = MEME_END_DAY;
	gMemeEndH = MEME_END_HOUR;
	gMemeEndMi = MEME_END_MIN;
	gMemeSeasonLoaded = true;
	gMemeSeasonEnded = false;
	MemeSaveSeasonToDB();
	printf("[Euro] New memecoin season from code: %s until %02d.%02d.%04d %02d:%02d",
		gMemeName, gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi);
	return 1;
}

forward OnMemeSeasonLoad();
public OnMemeSeasonLoad()
{
	if(cache_get_row_count(gSQL) < 1)
	{
		// В БД нет сезона — стартуем из кода
		MemeApplyDefinesAsSeason();
		return 1;
	}
	cache_get_field_content(0, "name", gMemeName, gSQL, sizeof gMemeName);
	gMemeEndY = cache_get_field_content_int(0, "end_y", gSQL);
	gMemeEndMo = cache_get_field_content_int(0, "end_mo", gSQL);
	gMemeEndD = cache_get_field_content_int(0, "end_d", gSQL);
	gMemeEndH = cache_get_field_content_int(0, "end_h", gSQL);
	gMemeEndMi = cache_get_field_content_int(0, "end_mi", gSQL);
	// защита от ??? из БД: если имя битое — всегда MEME_NAME
	{
		new qi, qcnt, bad;
		bad = !gMemeName[0];
		for(qi = 0; gMemeName[qi] && qi < 31; qi++)
		{
			if(gMemeName[qi] == '?') qcnt++;
		}
		if(qcnt >= 2) bad = 1;
		if(bad)
		{
			format(gMemeName, sizeof gMemeName, "%s", MEME_NAME);
			MemeSaveSeasonToDB();
		}
	}
	gMemeSeasonLoaded = true;

	printf("[Euro] Season from DB: %s until %02d.%02d.%04d %02d:%02d",
		gMemeName, gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi);

	// Если сезон в БД уже закончился — включаем новый из #define
	if(!MemeSeasonActive())
	{
		printf("[Euro] DB season ended -> apply #define as new season");
		MemeApplyDefinesAsSeason();
		new str[144];
		format(str, sizeof str, "{FF69B4}[Мемкоин] Новый сезон: %s до %02d.%02d.%04d %02d:%02d",
			gMemeName, gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi);
		SendClientMessageToAll(-1, str);
	}
	else
	{
		// Сезон ещё идёт: #define (другое имя) ждёт окончания
		if(strcmp(gMemeName, MEME_NAME, true) != 0)
			printf("[Euro] Code name pending until DB season ends: code=%s db=%s", MEME_NAME, gMemeName);
	}
	return 1;
}

stock MemeLoadSeasonFromDB()
{
	if(!gSQLOk) return 0;
	new q[280];
	mysql_format(gSQL, q, sizeof q,
		"CREATE TABLE IF NOT EXISTS `memecoin_season` (`id` INT NOT NULL PRIMARY KEY, `name` VARCHAR(32) NOT NULL, `end_y` INT NOT NULL, `end_mo` INT NOT NULL, `end_d` INT NOT NULL, `end_h` INT NOT NULL, `end_mi` INT NOT NULL)");
	mysql_tquery(gSQL, q);
	mysql_tquery(gSQL, "SELECT `id`,`name`,`end_y`,`end_mo`,`end_d`,`end_h`,`end_mi` FROM `memecoin_season` WHERE `id`=1 LIMIT 1", "OnMemeSeasonLoad", "");
	return 1;
}

forward MemeCheckSeasonTick();
public MemeCheckSeasonTick() { return MemeCheckSeason(); }

stock MemeCheckSeason()
{
	if(!gMemeSeasonLoaded) return 1;
	new bool:active = MemeSeasonActive();
	if(!active && !gMemeSeasonEnded)
	{
		gMemeSeasonEnded = true;
		new str[128];
		format(str, sizeof str, "[Мемкоин] Сезон %s ОКОНЧЕН.", gMemeName);
		SendClientMessageToAll(COLOR_MEME, str);
		// Сразу стартуем новый сезон из #define (если уже прописали другое имя/даты)
		MemeApplyDefinesAsSeason();
		format(str, sizeof str, "{FF69B4}[Мемкоин] Новый сезон: %s до %02d.%02d.%04d %02d:%02d",
			gMemeName, gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi);
		SendClientMessageToAll(-1, str);
	}
	else if(active)
		gMemeSeasonEnded = false;
	return 1;
}


stock MemeFixName()
{
	new qi, qcnt, bad;
	bad = !gMemeName[0];
	for(qi = 0; gMemeName[qi] && qi < 31; qi++)
	{
		if(gMemeName[qi] == '?') qcnt++;
	}
	if(qcnt >= 2) bad = 1;
	if(bad)
	{
		format(gMemeName, sizeof gMemeName, "%s", MEME_NAME);
		if(gSQLOk) MemeSaveSeasonToDB();
	}
	return 1;
}

stock bool:MemeRequireActive(playerid)
{
	MemeCheckSeason();
	if(!MemeSeasonActive())
	{
		SendClientMessage(playerid, COLOR_ERR, "Мемкоин сезона окончен. Дождитесь нового сезона.");
		return false;
	}
	return true;
}

stock LoadIni()
{
	format(SQL_Host, sizeof SQL_Host, "127.0.0.1");
	SQL_User[0] = SQL_Pass[0] = SQL_DB[0] = 0;
	if(!fexist(MYSQL_FILE)) { print("[Euro] нет ini"); return 0; }
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
			format(SQL_Host, sizeof SQL_Host, "%s", val);
		else if(!strcmp(key, "username", true) || !strcmp(key, "user", true) || !strcmp(key, "login", true))
			format(SQL_User, sizeof SQL_User, "%s", val);
		else if(!strcmp(key, "password", true) || !strcmp(key, "pass", true))
			format(SQL_Pass, sizeof SQL_Pass, "%s", val);
		else if(!strcmp(key, "database", true) || !strcmp(key, "db", true) || !strcmp(key, "dbname", true))
			format(SQL_DB, sizeof SQL_DB, "%s", val);
	}
	fclose(f);
	printf("[Euro] %s@%s / %s", SQL_User, SQL_Host, SQL_DB);
	return (SQL_User[0] && SQL_DB[0]);
}

stock ConnectSQL()
{
	gSQL = mysql_connect(SQL_Host, SQL_User, SQL_DB, SQL_Pass);
	if(gSQL && mysql_errno(gSQL) == 0)
	{
		mysql_tquery(gSQL, "SET NAMES 'cp1251'");
		mysql_tquery(gSQL, "SET CHARACTER SET cp1251");
		return 1;
	}
	gSQL = mysql_connect(SQL_Host, SQL_User, SQL_Pass, SQL_DB);
	if(gSQL && mysql_errno(gSQL) == 0)
	{
		mysql_tquery(gSQL, "SET NAMES 'cp1251'");
		mysql_tquery(gSQL, "SET CHARACTER SET cp1251");
		return 1;
	}
	gSQL = 0;
	return 0;
}

stock SaveEuro(playerid)
{
	// async — mysql_query на leave/PayDay клал поток сервера
	if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
	if(!gSQLOk || !PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
	new q[400];
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` SET `evro`=%d,`evro_exchanged`=%d,`bitok`=%d,`memecoin`=%d,`meme_last`=%d,`uah`=%d,`kzt`=%d,`play_sec`=%d,`meme_rand`=%d,`funcoin`=%d WHERE `id`=%d LIMIT 1",
		PlayerEuro[playerid], PlayerEuroEx[playerid], PlayerBit[playerid],
		PlayerMeme[playerid], PlayerLastLogin[playerid],
		PlayerUAH[playerid], PlayerKZT[playerid], PlayerPlaySec[playerid], PlayerRandBuys[playerid],
		PlayerFun[playerid], PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	return 1;
}

// SIMPLE load - only columns we ALTER ourselves (no donate in SELECT - avoids fail)
stock LoadEuro(playerid)
{
	if(!gSQLOk) return 0;
	new name[24], q[280];
	GetPlayerName(playerid, name, sizeof name);
	mysql_format(gSQL, q, sizeof q,
		"SELECT `id`, IFNULL(`evro`,0), IFNULL(`evro_exchanged`,0), IFNULL(`bitok`,0), IFNULL(`memecoin`,0), IFNULL(`meme_last`,0), IFNULL(`uah`,0), IFNULL(`kzt`,0), IFNULL(`play_sec`,0), IFNULL(`meme_rand`,0), IFNULL(`funcoin`,0) FROM `accounts` WHERE `name`='%e' LIMIT 1",
		name);
	mysql_tquery(gSQL, q, "OnEuroLoad", "i", playerid);
	return 1;
}

forward OnEuroLoad(playerid);
public OnEuroLoad(playerid)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL);
	if(rows < 1)
	{
		// retry without meme cols (first start before ALTER finishes)
		new name[24], q[200];
		GetPlayerName(playerid, name, sizeof name);
		mysql_format(gSQL, q, sizeof q,
			"SELECT `id`, IFNULL(`evro`,0), IFNULL(`evro_exchanged`,0) FROM `accounts` WHERE `name`='%e' LIMIT 1", name);
		mysql_tquery(gSQL, q, "OnEuroLoadSimple", "i", playerid);
		return 1;
	}
	PlayerAccID[playerid] = cache_get_row_int(0, 0, gSQL);
	PlayerEuro[playerid] = cache_get_row_int(0, 1, gSQL);
	PlayerEuroEx[playerid] = cache_get_row_int(0, 2, gSQL);
	PlayerBit[playerid] = cache_get_row_int(0, 3, gSQL);
	PlayerMeme[playerid] = cache_get_row_int(0, 4, gSQL);
	PlayerLastLogin[playerid] = cache_get_row_int(0, 5, gSQL);
	PlayerUAH[playerid] = cache_get_row_int(0, 6, gSQL);
	PlayerKZT[playerid] = cache_get_row_int(0, 7, gSQL);
	PlayerPlaySec[playerid] = cache_get_row_int(0, 8, gSQL);
	PlayerRandBuys[playerid] = cache_get_row_int(0, 9, gSQL);
	PlayerFun[playerid] = cache_get_row_int(0, 10, gSQL);
	PlayerLoaded[playerid] = true;
	MemeOnLogin(playerid);
	printf("[Euro] загружен %d acc=%d евро=%d бит=%d мем=%d", playerid, PlayerAccID[playerid], PlayerEuro[playerid], PlayerBit[playerid], PlayerMeme[playerid]);
	return 1;
}

forward OnEuroLoadSimple(playerid);
public OnEuroLoadSimple(playerid)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 1;
	if(cache_get_row_count(gSQL) < 1)
	{
		PlayerLoaded[playerid] = false;
		print("[Euro] аккаунт не найден в БД");
		return 1;
	}
	PlayerAccID[playerid] = cache_get_row_int(0, 0, gSQL);
	PlayerEuro[playerid] = cache_get_row_int(0, 1, gSQL);
	PlayerEuroEx[playerid] = cache_get_row_int(0, 2, gSQL);
	PlayerBit[playerid] = 0;
	PlayerMeme[playerid] = 0;
	PlayerFun[playerid] = 0;
	PlayerLastLogin[playerid] = gettime();
	PlayerLoaded[playerid] = true;
	printf("[Euro] простая загрузка %d acc=%d евро=%d", playerid, PlayerAccID[playerid], PlayerEuro[playerid]);
	return 1;
}

stock MemeOnLogin(playerid)
{
	if(!PlayerLoaded[playerid]) return 0;
	new nowt = gettime();
	new last = PlayerLastLogin[playerid];
	if(last <= 0)
	{
		PlayerLastLogin[playerid] = nowt;
		SaveEuro(playerid);
		return 1;
	}
	new delta = nowt - last;
	if(delta < 0) delta = 0;
	new days = delta / 86400;

	if(days >= MEME_OFFLINE_DAYS && PlayerMeme[playerid] > 0)
	{
		new old = PlayerMeme[playerid];
		PlayerMeme[playerid] = 0;
		PlayerLastLogin[playerid] = nowt;
		SaveEuro(playerid);
		new str[144];
		format(str, sizeof str, "{FF69B4}[Мемкоин] Ваш %s (%d шт.) расформирован: нет входа %d+ дней.", gMemeName, old, MEME_OFFLINE_DAYS);
		SendClientMessage(playerid, -1, str);
		return 1;
	}
	if(days >= 1 && PlayerMeme[playerid] > 0 && MemeSeasonActive())
	{
		new add = (PlayerMeme[playerid] * MEME_GROW_PCT_DAY * days) / 100;
		if(add < 1) add = 1;
		PlayerMeme[playerid] += add;
		new str[128];
		format(str, sizeof str, "{FF69B4}[Мемкоин] %s вырос на +%d (%d дн.). Итого: %d", gMemeName, add, days, PlayerMeme[playerid]);
		SendClientMessage(playerid, -1, str);
	}
	PlayerLastLogin[playerid] = nowt;
	SaveEuro(playerid);
	return 1;
}

forward UpdateRate();
public UpdateRate()
{
	HTTP(9911, HTTP_GET, "www.cbr.ru/scripts/XML_daily.asp", "", "OnRateHTTP");
	HTTP(9912, HTTP_GET, "api.coindesk.com/v1/bpi/currentprice/RUB.json", "", "OnBitRateHTTP");
	new h, mi, s; gettime(h, mi, s);
	gMemeRate = 50.0 + float(h) * 3.5 + float(mi) * 0.1;
	if(gMemeRate < 10.0) gMemeRate = 10.0;
	MemeCheckSeason();
	return 1;
}

stock Float:CBRParseVal(data[], code[])
{
	new p = strfind(data, code, true);
	if(p == -1) return 0.0;
	new v = strfind(data, "<Value>", true, p);
	if(v == -1) return 0.0;
	v += 7;
	new buf[24], i;
	while(data[v] && data[v] != '<' && i < 20) { buf[i++] = (data[v] == ',') ? '.' : data[v]; v++; }
	buf[i] = 0;
	return floatstr(buf);
}

forward OnRateHTTP(index, response_code, data[]);
public OnRateHTTP(index, response_code, data[])
{
	#pragma unused index
	if(response_code != 200 || strlen(data) < 40) return 1;
	new Float:r;
	r = CBRParseVal(data, "EUR");
	if(r > 20.0 && r < 250.0) gEuroRate = r;
	// UAH: ЦБ даёт за 10 гривен — делим на 10
	r = CBRParseVal(data, "UAH");
	if(r > 5.0 && r < 100.0) gUahRate = r / 10.0;
	else if(r > 0.5 && r < 20.0) gUahRate = r;
	// KZT: ЦБ даёт за 100 тенге — делим на 100
	r = CBRParseVal(data, "KZT");
	if(r > 5.0 && r < 50.0) gKztRate = r / 100.0;
	else if(r > 0.05 && r < 2.0) gKztRate = r;
	return 1;
}

forward OnBitRateHTTP(index, response_code, data[]);
public OnBitRateHTTP(index, response_code, data[])
{
	#pragma unused index
	if(response_code != 200 || strlen(data) < 20) return 1;
	new p = strfind(data, "rate_float", true); if(p == -1) return 1;
	p = strfind(data, ":", true, p); if(p == -1) return 1; p++;
	while(data[p] == ' ') p++;
	new buf[32], i;
	while(data[p] && ((data[p] >= '0' && data[p] <= '9') || data[p] == '.') && i < 30) { buf[i++] = data[p]; p++; }
	buf[i] = 0;
	new Float:r = floatstr(buf);
	if(r > 100000.0 && r < 500000000.0) gBitRate = r;
	return 1;
}

forward MemeAnnounce();
public MemeAnnounce()
{
	MemeCheckSeason();
	MemeFixName();
	new str[160];
	if(MemeSeasonActive())
		format(str, sizeof str, "{FF69B4}[Мемкоин] Сейчас: %s | до %02d.%02d.%04d %02d:%02d | курс %.1f | .meme",
			gMemeName, gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi, gMemeRate);
	else
		format(str, sizeof str, "{FF69B4}[Мемкоин] Сезон %s завершён.", gMemeName);
	SendClientMessageToAll(-1, str);
	return 1;
}

stock DoExchange(playerid, amount, toBank)
{
	if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Евро не загружены"), 0;
	if(amount <= 0 || PlayerEuro[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new rub = floatround(float(amount) * gEuroRate, floatround_floor); if(rub < 1) rub = 1;
	PlayerEuro[playerid] -= amount; PlayerEuroEx[playerid] += amount; SaveEuro(playerid);
	new q[280];
	if(toBank)
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `bank`=IFNULL(`bank`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
	else
	{
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `money`=IFNULL(`money`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
		GivePlayerMoney(playerid, rub);
	}
	mysql_tquery(gSQL, q);
	new str[128]; format(str, sizeof str, "{FFD700}Евро->руб: -%d = +%d (%s)", amount, rub, toBank ? "банк" : "нал");
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BuyEuroFromRub(playerid, rub_amount, fromBank)
{
	if(!PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return SendClientMessage(playerid, COLOR_ERR, "Евро не загружены"), 0;
	if(rub_amount < 1) return SendClientMessage(playerid, COLOR_ERR, "Сумма"), 0;
	if(gEuroRate < 1.0) return SendClientMessage(playerid, COLOR_ERR, "Курс ещё не загружен"), 0;
	new euro = floatround(float(rub_amount) / gEuroRate, floatround_floor);
	if(euro < 1) return SendClientMessage(playerid, COLOR_ERR, "Мало на 1 евро"), 0;
	new cost = floatround(float(euro) * gEuroRate, floatround_ceil); if(cost < 1) cost = 1;
	EuroBuyMode[playerid] = fromBank ? 1 : 0;
	new q[200];
	if(fromBank)
		mysql_format(gSQL, q, sizeof q, "SELECT IFNULL(`bank`,0) FROM `accounts` WHERE `id`=%d LIMIT 1", PlayerAccID[playerid]);
	else
		mysql_format(gSQL, q, sizeof q, "SELECT IFNULL(`money`,0) FROM `accounts` WHERE `id`=%d LIMIT 1", PlayerAccID[playerid]);
	mysql_tquery(gSQL, q, "OnBuyEuroCheck", "iii", playerid, euro, cost);
	return 1;
}

forward OnBuyEuroCheck(playerid, euro, cost);
public OnBuyEuroCheck(playerid, euro, cost)
{
	if(!IsPlayerConnected(playerid) || !PlayerLoaded[playerid]) return 1;
	new have = 0;
	if(cache_get_row_count(gSQL) > 0) have = cache_get_row_int(0, 0, gSQL);
	new fromBank = EuroBuyMode[playerid];
	if(!fromBank) { new pm = GetPlayerMoney(playerid); if(pm > have) have = pm; }
	if(have < cost) { SendClientMessage(playerid, COLOR_ERR, "Не хватает рублей"); return 1; }
	new q[260];
	if(fromBank)
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `bank`=IFNULL(`bank`,0)-%d WHERE `id`=%d AND IFNULL(`bank`,0)>=%d LIMIT 1", cost, PlayerAccID[playerid], cost);
	else
	{
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `money`=IFNULL(`money`,0)-%d WHERE `id`=%d LIMIT 1", cost, PlayerAccID[playerid]);
		if(GetPlayerMoney(playerid) >= cost) GivePlayerMoney(playerid, -cost);
	}
	mysql_tquery(gSQL, q);
	PlayerEuro[playerid] += euro; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FFD700}Руб->евро: -%d = +%d евро", cost, euro);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BitToRub(playerid, bit_amount, toBank)
{
	if(!PlayerLoaded[playerid]) return 0;
	if(bit_amount <= 0 || PlayerBit[playerid] < bit_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало битка"), 0;
	new Float:gross = float(bit_amount) * gBitRate;
	new fee = floatround(gross * float(BIT_FEE_PCT) / 100.0, floatround_ceil);
	new rub = floatround(gross, floatround_floor) - fee; if(rub < 1) rub = 1;
	PlayerBit[playerid] -= bit_amount; SaveEuro(playerid);
	new q[260];
	if(toBank)
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `bank`=IFNULL(`bank`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
	else
	{
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `money`=IFNULL(`money`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
		GivePlayerMoney(playerid, rub);
	}
	mysql_tquery(gSQL, q);
	new str[120]; format(str, sizeof str, "{00BFFF}Бит->руб: -%d = +%d (комиссия %d%%)", bit_amount, rub, BIT_FEE_PCT);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BitToEuro(playerid, bit_amount)
{
	if(!PlayerLoaded[playerid]) return 0;
	if(bit_amount <= 0 || PlayerBit[playerid] < bit_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало битка"), 0;
	new Float:rub_value = float(bit_amount) * gBitRate * (1.0 - float(BIT_FEE_PCT) / 100.0);
	new euro = floatround(rub_value / gEuroRate, floatround_floor);
	if(euro < 1) return SendClientMessage(playerid, COLOR_ERR, "Мало после комиссии"), 0;
	PlayerBit[playerid] -= bit_amount; PlayerEuro[playerid] += euro; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{00BFFF}Бит->евро: -%d = +%d евро", bit_amount, euro);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock EuroToBit(playerid, euro_amount)
{
	if(!PlayerLoaded[playerid]) return 0;
	if(euro_amount <= 0 || PlayerEuro[playerid] < euro_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new Float:rub_value = float(euro_amount) * gEuroRate * (1.0 - float(EURO_TO_BIT_FEE_PCT) / 100.0);
	new bit = floatround(rub_value / gBitRate, floatround_floor);
	if(bit < 1) return SendClientMessage(playerid, COLOR_ERR, "Мало после 20%"), 0;
	PlayerEuro[playerid] -= euro_amount; PlayerBit[playerid] += bit; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FFD700}Евро->бит: -%d = +%d бит", euro_amount, bit);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock MemeToRub(playerid, amount, toBank)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerMeme[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало мемкоина"), 0;
	new Float:gross = float(amount) * gMemeRate;
	new fee = floatround(gross * float(MEME_FEE_PCT) / 100.0, floatround_ceil);
	new rub = floatround(gross, floatround_floor) - fee;
	if(rub < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% ничего"), 0;
	PlayerMeme[playerid] -= amount; SaveEuro(playerid);
	new q[260];
	if(toBank)
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `bank`=IFNULL(`bank`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
	else
	{
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `money`=IFNULL(`money`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
		GivePlayerMoney(playerid, rub);
	}
	mysql_tquery(gSQL, q);
	new str[120]; format(str, sizeof str, "{FF69B4}%s->руб: -%d = +%d (комиссия 50%%)", gMemeName, amount, rub);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock MemeToEuro(playerid, amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerMeme[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало мемкоина"), 0;
	new Float:rub_value = float(amount) * gMemeRate * (1.0 - float(MEME_FEE_PCT) / 100.0);
	new euro = floatround(rub_value / gEuroRate, floatround_floor);
	if(euro < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% мало"), 0;
	PlayerMeme[playerid] -= amount; PlayerEuro[playerid] += euro; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FF69B4}%s->евро: -%d = +%d", gMemeName, amount, euro);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock MemeToBit(playerid, amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerMeme[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало мемкоина"), 0;
	new Float:rub_value = float(amount) * gMemeRate * (1.0 - float(MEME_FEE_PCT) / 100.0);
	new bit = floatround(rub_value / gBitRate, floatround_floor);
	if(bit < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% мало"), 0;
	PlayerMeme[playerid] -= amount; PlayerBit[playerid] += bit; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FF69B4}%s->бит: -%d = +%d", gMemeName, amount, bit);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock EuroToMeme(playerid, euro_amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || euro_amount <= 0 || PlayerEuro[playerid] < euro_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new Float:rub_value = float(euro_amount) * gEuroRate * (1.0 - float(MEME_FEE_PCT) / 100.0);
	new meme = floatround(rub_value / gMemeRate, floatround_floor);
	if(meme < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% мало"), 0;
	PlayerEuro[playerid] -= euro_amount; PlayerMeme[playerid] += meme; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FF69B4}Евро->%s: -%d = +%d", gMemeName, euro_amount, meme);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BitToMeme(playerid, bit_amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || bit_amount <= 0 || PlayerBit[playerid] < bit_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало битка"), 0;
	new Float:rub_value = float(bit_amount) * gBitRate * (1.0 - float(MEME_FEE_PCT) / 100.0);
	new meme = floatround(rub_value / gMemeRate, floatround_floor);
	if(meme < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% мало"), 0;
	PlayerBit[playerid] -= bit_amount; PlayerMeme[playerid] += meme; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FF69B4}Бит->%s: -%d = +%d", gMemeName, bit_amount, meme);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock DonateToMeme(playerid, don_amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || don_amount <= 0) return 0;
	if(PlayerAccID[playerid] < 1) return 0;
	// БЦ / BlackCoin в этой БД = поле `rub` (у новичков 333333, у топов миллиарды)
	new q[220];
	mysql_format(gSQL, q, sizeof q,
		"SELECT IFNULL(`rub`,0) FROM `accounts` WHERE `id`=%d LIMIT 1",
		PlayerAccID[playerid]);
	mysql_tquery(gSQL, q, "OnDonateToMemeCheck", "ii", playerid, don_amount);
	return 1;
}

forward OnDonateToMemeCheck(playerid, don_amount);
public OnDonateToMemeCheck(playerid, don_amount)
{
	if(!IsPlayerConnected(playerid) || !PlayerLoaded[playerid]) return 1;
	new have = 0;
	if(cache_get_row_count(gSQL) > 0)
		have = cache_get_row_int(0, 0, gSQL);

	if(have < don_amount)
	{
		new str[120];
		format(str, sizeof str, "Мало БЦ (rub). Нужно %d, на счету %d", don_amount, have);
		SendClientMessage(playerid, COLOR_ERR, str);
		return 1;
	}

	new after = don_amount - (don_amount * MEME_FEE_PCT) / 100;
	if(after < 1)
	{
		SendClientMessage(playerid, COLOR_ERR, "После 50% ничего");
		return 1;
	}
	new meme = floatround(float(after) / gMemeRate, floatround_floor);
	if(meme < 1) meme = after;

	new q[280];
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` SET `rub`=IFNULL(`rub`,0)-%d WHERE `id`=%d AND IFNULL(`rub`,0)>=%d LIMIT 1",
		don_amount, PlayerAccID[playerid], don_amount);
	mysql_tquery(gSQL, q);

	PlayerMeme[playerid] += meme;
	PlayerDonate[playerid] = have - don_amount;
	SaveEuro(playerid);

	new str[160];
	format(str, sizeof str, "{FF69B4}БЦ(rub)->%s: -%d = +%d мем (комиссия 50%%). Остаток БЦ в БД: %d",
		gMemeName, don_amount, meme, PlayerDonate[playerid]);
	SendClientMessage(playerid, -1, str);
	SendClientMessage(playerid, COLOR_EURO, "GUI обновится после релога (мод кэширует rub).");
	printf("[Euro] BC(rub)->meme player=%d -%d left=%d meme+=%d", playerid, don_amount, PlayerDonate[playerid], meme);
	return 1;
}

stock MemeToDonate(playerid, amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerMeme[playerid] < amount)
		return SendClientMessage(playerid, COLOR_ERR, "Мало мемкоина"), 0;
	new Float:rub_value = float(amount) * gMemeRate;
	new fee = floatround(rub_value * float(MEME_FEE_PCT) / 100.0, floatround_ceil);
	new don = floatround(rub_value, floatround_floor) - fee;
	if(don < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% доната нет"), 0;

	PlayerMeme[playerid] -= amount;
	new q[260];
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` SET `rub`=IFNULL(`rub`,0)+%d WHERE `id`=%d LIMIT 1",
		don, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SaveEuro(playerid);

	new str[140];
	format(str, sizeof str, "{FF69B4}%s->БЦ(rub): -%d = +%d (комиссия 50%%)", gMemeName, amount, don);
	SendClientMessage(playerid, -1, str);
	SendClientMessage(playerid, COLOR_EURO, "БЦ записаны в rub. Релог если GUI не обновился.");
	printf("[Euro] meme->BC(rub) player=%d meme=-%d rub+=%d", playerid, amount, don);
	return 1;
}

stock BuySkin(playerid, modelid)
{
	if(modelid < 1 || !PlayerLoaded[playerid]) return 0;
	new price = 25 + (modelid % 80); if(modelid > 1000) price = 100 + (modelid % 120);
	if(PlayerEuro[playerid] < price) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	PlayerEuro[playerid] -= price; SaveEuro(playerid);
	new acc = PlayerAccID[playerid], q[380];
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `invskins` (`account_id`,`internal_id`,`modelid`) VALUES (%d,%d,%d)", acc, modelid, modelid);
	mysql_tquery(gSQL, q);
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `inventory` (`account_id`,`item_id`,`model_id`,`old_skin`,`slot`,`amount`,`extra_1`,`extra_2`,`sim`,`oldsim`,`source_internal_id`) SELECT %d,%d,%d,0,IFNULL(MAX(`slot`),0)+1,1,0,0,0,0,%d FROM `inventory` WHERE `account_id`=%d", acc, ITEM_SKIN, modelid, modelid, acc);
	mysql_tquery(gSQL, q);
	SetPlayerSkin(playerid, modelid);
	new str[64]; format(str, sizeof str, "{FFD700}Скин %d за %d евро", modelid, price);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BuyAcs(playerid, modelid)
{
	if(modelid < 1 || !PlayerLoaded[playerid]) return 0;
	new price = 35 + (modelid % 90); if(modelid > 10000) price = 80 + (modelid % 100);
	if(PlayerEuro[playerid] < price) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	PlayerEuro[playerid] -= price; SaveEuro(playerid);
	new acc = PlayerAccID[playerid], q[380];
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `accessory_inventory` (`player_id`,`acs_id`,`use`) VALUES (%d,%d,0)", acc, modelid);
	mysql_tquery(gSQL, q);
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `inventory` (`account_id`,`item_id`,`model_id`,`old_skin`,`slot`,`amount`,`extra_1`,`extra_2`,`sim`,`oldsim`,`source_internal_id`) SELECT %d,%d,%d,0,IFNULL(MAX(`slot`),0)+1,1,0,0,0,0,0 FROM `inventory` WHERE `account_id`=%d", acc, modelid, modelid, acc);
	mysql_tquery(gSQL, q);
	new str[64]; format(str, sizeof str, "{FFD700}Акс %d за %d евро", modelid, price);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BuyCar(playerid, modelid)
{
	if(modelid < 1 || !PlayerLoaded[playerid]) return 0;
	new price = 150 + (modelid % 250);
	if(PlayerEuro[playerid] < price) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z); GetPlayerFacingAngle(playerid, a);
	x += floatsin(-a, degrees) * 5.0; y += floatcos(-a, degrees) * 5.0;
	PlayerEuro[playerid] -= price; SaveEuro(playerid);
	new q[400];
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `ownable_cars` (`owner_id`,`model_id`,`color_1`,`color_2`,`pos_x`,`pos_y`,`pos_z`,`angle`,`create_time`,`alarm`,`key_in`,`mileage`,`fuel`,`health`,`vinilcar`,`pt_engine`,`pt_brake`,`pt_stability`,`nitro`,`launch`,`fars`) VALUES (%d,%d,1,1,%f,%f,%f,%f,%d,0,0,0.0,40.0,1000.0,0,0,0,0,0,0,0)",
		PlayerAccID[playerid], modelid, x, y, z, a, gettime());
	mysql_tquery(gSQL, q);
	new v = CreateVehicle(modelid, x, y, z + 0.3, a, 1, 1, -1);
	if(v != INVALID_VEHICLE_ID) PutPlayerInVehicle(playerid, v, 0);
	new str[64]; format(str, sizeof str, "{FFD700}Машина %d за %d евро", modelid, price);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock StartFamilyBuy(playerid)
{
	if(!PlayerLoaded[playerid]) return 0;
	if(PlayerEuro[playerid] < EURO_FAMILY_PRICE) return SendClientMessage(playerid, COLOR_ERR, "Нужно 100000 евро"), 0;
	ShowPlayerDialog(playerid, D_EURO_FAM_NAME, DIALOG_STYLE_INPUT, "Семья", "Название (2-30):", "OK", "X");
	return 1;
}

stock ConfirmFamily(playerid)
{
	new q[140];
	mysql_format(gSQL, q, sizeof q, "SELECT `family_id` FROM `accounts` WHERE `id`=%d LIMIT 1", PlayerAccID[playerid]);
	mysql_tquery(gSQL, q, "OnFamCheck", "i", playerid);
	return 1;
}

forward OnFamCheck(playerid);
public OnFamCheck(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new fid = 0;
	if(cache_get_row_count(gSQL) > 0) fid = cache_get_row_int(0, 0, gSQL);
	if(fid > 0) return SendClientMessage(playerid, COLOR_ERR, "Уже в семье"), 1;
	if(PlayerEuro[playerid] < EURO_FAMILY_PRICE) return 1;
	PlayerEuro[playerid] -= EURO_FAMILY_PRICE; SaveEuro(playerid);
	new q[650];
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `familynew` (`owner`,`name`,`color`,`chatcolor`,`slot_veh`,`reputation`,`zaxvati`,`moneti`,`syndicate`,`patron`,`material`,`heath_kit`,`armour`,`money`,`mask`,`level_storage`,`level_weapon`,`level_compound`,`house`,`notif`,`notif_seq`,`rang_1`,`rang_2`,`rang_3`,`rang_4`,`rang_5`,`last_active`) VALUES (%d,'%e',0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,-1,'',0,'1 rang,1,0,0,0,1','2 rang,1,0,0,0,1','3 rang,1,0,0,0,1','4 rang,1,1,1,1,1','5 rang,1,1,1,1,1',%d)",
		PlayerAccID[playerid], FamilyNamePending[playerid], gettime());
	mysql_tquery(gSQL, q, "OnFamIns", "i", playerid);
	return 1;
}

forward OnFamIns(playerid);
public OnFamIns(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new id = cache_insert_id(gSQL);
	if(id < 1) { mysql_tquery(gSQL, "SELECT MAX(`id`) FROM `familynew`", "OnFamMax", "i", playerid); return 1; }
	new q[160];
	mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `family_id`=%d,`family_rang`=5 WHERE `id`=%d LIMIT 1", id, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SendClientMessage(playerid, COLOR_EURO, "Семья создана. Релог!");
	return 1;
}

forward OnFamMax(playerid);
public OnFamMax(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new id = 0;
	if(cache_get_row_count(gSQL) > 0) id = cache_get_row_int(0, 0, gSQL);
	if(id < 1) { PlayerEuro[playerid] += EURO_FAMILY_PRICE; SaveEuro(playerid); return 1; }
	new q[160];
	mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `family_id`=%d,`family_rang`=5 WHERE `id`=%d LIMIT 1", id, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SendClientMessage(playerid, COLOR_EURO, "Семья создана. Релог!");
	return 1;
}

forward PayDay();
public PayDay()
{
	if(!gSQLOk) return 1;
	new h, m, s; gettime(h, m, s);
	if(m != 0 || LastPaydayHour == h) return 1;
	LastPaydayHour = h;
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i) || !PlayerLoaded[i] || PlayerAccID[i] < 1) continue;
		PlayerEuro[i] += EURO_PAYDAY;
		PlayerBit[i] += BIT_PAYDAY;
		PlayerFun[i] += FUN_HOUR_REWARD;
		// НЕ трогаем PlayerLastLogin — иначе рост мемкоина не считает дни оффлайна
		SaveEuro(i);
		SendClientMessage(i, COLOR_EURO, "PayDay +10 евро");
		SendClientMessage(i, COLOR_BIT, "PayDay +5 биток");
	}
	return 1;
}

stock ShowTop(playerid)
{
	mysql_tquery(gSQL, "SELECT `name`,IFNULL(`evro`,0) AS e FROM `accounts` ORDER BY IFNULL(`evro`,0) DESC LIMIT 50", "OnTop", "i", playerid);
	return 1;
}
stock ShowBitTop(playerid)
{
	mysql_tquery(gSQL, "SELECT `name`,IFNULL(`bitok`,0) AS b FROM `accounts` ORDER BY IFNULL(`bitok`,0) DESC LIMIT 50", "OnBitTop", "i", playerid);
	return 1;
}
stock ShowMemeTop(playerid)
{
	mysql_tquery(gSQL, "SELECT `name`,IFNULL(`memecoin`,0) AS m FROM `accounts` ORDER BY IFNULL(`memecoin`,0) DESC LIMIT 50", "OnMemeTop", "i", playerid);
	return 1;
}

forward OnTop(playerid);
public OnTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[90], name[24], e;
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_field_content(i, "name", name, gSQL, sizeof name);
		e = cache_get_field_content_int(i, "e", gSQL);
		if(i == 0) format(line, sizeof line, "{FFD700}1. %s - %d\n", name, e);
		else if(i == 1) format(line, sizeof line, "{C0C0C0}2. %s - %d\n", name, e);
		else if(i == 2) format(line, sizeof line, "{CD7F32}3. %s - %d\n", name, e);
		else format(line, sizeof line, "%d. %s - %d\n", i + 1, name, e);
		if(strlen(body) + strlen(line) >= sizeof body - 2) break;
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	ShowPlayerDialog(playerid, D_EURO_TOP, DIALOG_STYLE_MSGBOX, "{FFD700}Топ евро", body, "OK", "");
	return 1;
}

forward OnBitTop(playerid);
public OnBitTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[90], name[24], b;
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_field_content(i, "name", name, gSQL, sizeof name);
		b = cache_get_field_content_int(i, "b", gSQL);
		if(i == 0) format(line, sizeof line, "{00BFFF}1. %s - %d\n", name, b);
		else if(i == 1) format(line, sizeof line, "{C0C0C0}2. %s - %d\n", name, b);
		else if(i == 2) format(line, sizeof line, "{CD7F32}3. %s - %d\n", name, b);
		else format(line, sizeof line, "%d. %s - %d\n", i + 1, name, b);
		if(strlen(body) + strlen(line) >= sizeof body - 2) break;
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	ShowPlayerDialog(playerid, D_BIT_TOP, DIALOG_STYLE_MSGBOX, "{00BFFF}Топ битка", body, "OK", "");
	return 1;
}

forward OnMemeTop(playerid);
public OnMemeTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[90], name[24], m;
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_field_content(i, "name", name, gSQL, sizeof name);
		m = cache_get_field_content_int(i, "m", gSQL);
		if(i == 0) format(line, sizeof line, "{FF69B4}1. %s - %d\n", name, m);
		else if(i == 1) format(line, sizeof line, "{C0C0C0}2. %s - %d\n", name, m);
		else if(i == 2) format(line, sizeof line, "{CD7F32}3. %s - %d\n", name, m);
		else format(line, sizeof line, "%d. %s - %d\n", i + 1, name, m);
		if(strlen(body) + strlen(line) >= sizeof body - 2) break;
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	new mt[56];
	format(mt, sizeof mt, "{FF69B4}Топ %s", gMemeName);
	ShowPlayerDialog(playerid, D_MEME_TOP, DIALOG_STYLE_MSGBOX, mt, body, "OK", "");
	return 1;
}


// ===== MEME: полёт =====
stock MemeBuyFly(playerid)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(PlayerMeme[playerid] < MEME_FLY_PRICE)
		return SendClientMessage(playerid, COLOR_ERR, "Нужно 10 мемкоинов"), 0;
	if(PlayerFlyActive[playerid])
		return SendClientMessage(playerid, COLOR_ERR, "Полёт уже активен"), 0;
	PlayerMeme[playerid] -= MEME_FLY_PRICE;
	SaveEuro(playerid);
	PlayerFlyActive[playerid] = 1;
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	if(PlayerFlyTimer[playerid]) KillTimer(PlayerFlyTimer[playerid]);
	// тик полёта каждые 200мс + авто-конец
	PlayerFlyTimer[playerid] = SetTimerEx("MemeFlyTick", 200, true, "i", playerid);
	SetTimerEx("MemeFlyEnd", MEME_FLY_SECONDS * 1000, false, "i", playerid);
	new str[96];
	format(str, sizeof str, "{FF69B4}Полёт на %d сек. Списано %d мемкоинов. W/A/S/D + Space", MEME_FLY_SECONDS, MEME_FLY_PRICE);
	SendClientMessage(playerid, -1, str);
	return 1;
}

forward MemeFlyTick(playerid);
public MemeFlyTick(playerid)
{
	if(!IsPlayerConnected(playerid) || !PlayerFlyActive[playerid])
	{
		if(PlayerFlyTimer[playerid]) { KillTimer(PlayerFlyTimer[playerid]); PlayerFlyTimer[playerid] = 0; }
		return 0;
	}
	// если джетпак сняли (AC/смерть) — поднимаем velocity-полётом
	if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_USEJETPACK)
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	new keys, ud, lr;
	GetPlayerKeys(playerid, keys, ud, lr);
	new Float:vx, Float:vy, Float:vz;
	GetPlayerVelocity(playerid, vx, vy, vz);
	new Float:a;
	GetPlayerFacingAngle(playerid, a);
	if(keys & KEY_SPRINT) // space up
		vz = 0.35;
	else if(keys & KEY_CROUCH)
		vz = -0.25;
	else
		vz = 0.05;
	if(ud < 0) // forward
	{
		vx = floatsin(-a, degrees) * 0.6;
		vy = floatcos(-a, degrees) * 0.6;
	}
	else if(ud > 0)
	{
		vx = floatsin(-a, degrees) * -0.4;
		vy = floatcos(-a, degrees) * -0.4;
	}
	SetPlayerVelocity(playerid, vx, vy, vz);
	return 1;
}

forward MemeFlyEnd(playerid);
public MemeFlyEnd(playerid)
{
	PlayerFlyActive[playerid] = 0;
	if(PlayerFlyTimer[playerid]) { KillTimer(PlayerFlyTimer[playerid]); PlayerFlyTimer[playerid] = 0; }
	if(!IsPlayerConnected(playerid)) return 1;
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	SendClientMessage(playerid, COLOR_MEME, "Полёт окончен.");
	return 1;
}

// ===== MEME: рандом скин/тачка/акс =====
stock MemeRandPrice(playerid)
{
	new n = PlayerRandBuys[playerid];
	// 5000, 6000, 10000, 20000, 30000...
	if(n <= 0) return MEME_RAND_BASE;
	if(n == 1) return 6000;
	if(n == 2) return 10000;
	if(n == 3) return 20000;
	return 20000 + (n - 3) * 10000;
}

stock MemeBuyRandom(playerid)
{
	if(!MemeRequireActive(playerid)) return 0;
	new price = MemeRandPrice(playerid);
	if(PlayerMeme[playerid] < price)
	{
		new str[80];
		format(str, sizeof str, "Мало мемкоинов. Нужно %d", price);
		return SendClientMessage(playerid, COLOR_ERR, str), 0;
	}
	PlayerMeme[playerid] -= price;
	PlayerRandBuys[playerid]++;
	SaveEuro(playerid);

	new kind = random(3); // 0 skin 1 car 2 acs
	new str[144];
	if(kind == 0)
	{
		new model = 1 + random(300);
		if(model < 1) model = 1;
		BuySkin(playerid, model); // may charge euro - bad
		// direct give without euro charge - inline
		PlayerEuro[playerid] += 0;
		new acc = PlayerAccID[playerid], q[380];
		// refund if BuySkin took euro - don't use BuySkin
		format(str, sizeof str, "{FF69B4}Рандом: скин ID %d (цена была %d мем)", model, price);
		SetPlayerSkin(playerid, model);
		mysql_format(gSQL, q, sizeof q, "INSERT INTO `invskins` (`account_id`,`internal_id`,`modelid`) VALUES (%d,%d,%d)", acc, model, model);
		mysql_tquery(gSQL, q);
	}
	else if(kind == 1)
	{
		new model = 400 + random(212);
		if(model > 611) model = 411;
		new Float:x, Float:y, Float:z, Float:a;
		GetPlayerPos(playerid,x,y,z); GetPlayerFacingAngle(playerid,a);
		x += floatsin(-a, degrees)*5.0; y += floatcos(-a, degrees)*5.0;
		new acc = PlayerAccID[playerid], q[400];
		mysql_format(gSQL, q, sizeof q, "INSERT INTO `ownable_cars` (`owner_id`,`model_id`,`color_1`,`color_2`,`pos_x`,`pos_y`,`pos_z`,`angle`,`create_time`,`alarm`,`key_in`,`mileage`,`fuel`,`health`,`vinilcar`,`pt_engine`,`pt_brake`,`pt_stability`,`nitro`,`launch`,`fars`) VALUES (%d,%d,1,1,%f,%f,%f,%f,%d,0,0,0.0,40.0,1000.0,0,0,0,0,0,0,0)",
			acc, model, x, y, z, a, gettime());
		mysql_tquery(gSQL, q);
		new v = CreateVehicle(model, x, y, z+0.3, a, 1, 1, -1);
		if(v != INVALID_VEHICLE_ID) PutPlayerInVehicle(playerid, v, 0);
		format(str, sizeof str, "{FF69B4}Рандом: машина ID %d (цена %d мем)", model, price);
	}
	else
	{
		new model = 1000 + random(5000);
		new acc = PlayerAccID[playerid], q[300];
		mysql_format(gSQL, q, sizeof q, "INSERT INTO `accessory_inventory` (`player_id`,`acs_id`,`use`) VALUES (%d,%d,0)", acc, model);
		mysql_tquery(gSQL, q);
		format(str, sizeof str, "{FF69B4}Рандом: акс ID %d (цена %d мем)", model, price);
	}
	SendClientMessage(playerid, -1, str);
	format(str, sizeof str, "Следующий рандом будет стоить %d мемкоинов", MemeRandPrice(playerid));
	SendClientMessage(playerid, COLOR_MEME, str);
	return 1;
}

// ===== Playtime -> UAH/KZT =====
forward PlaytimeTick();
public PlaytimeTick()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i) || !PlayerLoaded[i]) continue;
		PlayerPlaySec[i]++;
		if(PlayerPlaySec[i] >= PLAY_HOURS_REWARD * 3600)
		{
			PlayerPlaySec[i] -= PLAY_HOURS_REWARD * 3600;
			PlayerUAH[i]++;
			PlayerKZT[i]++;
			SaveEuro(i);
			SendClientMessage(i, 0x0057B8FF, "Награда за 12 ч игры: +1 гривна, +1 тенге (не обмениваются).");
		}
	}
	return 1;
}


// ===== UAH exchange (90%) + transfer =====
stock UahToEuro(playerid, amount)
{
	if(amount <= 0 || PlayerUAH[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало гривен"), 0;
	new Float:rub = float(amount) * gUahRate * (1.0 - float(UAH_FEE_PCT) / 100.0);
	new euro = floatround(rub / gEuroRate, floatround_floor);
	if(euro < 1) return SendClientMessage(playerid, COLOR_ERR, "После 90% мало"), 0;
	PlayerUAH[playerid] -= amount; PlayerEuro[playerid] += euro; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Гривна->евро: -%d = +%d (комиссия 90%%)", amount, euro);
	SendClientMessage(playerid, 0x0057B8FF, str);
	return 1;
}

stock UahToBit(playerid, amount)
{
	if(amount <= 0 || PlayerUAH[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало гривен"), 0;
	new Float:rub = float(amount) * gUahRate * (1.0 - float(UAH_FEE_PCT) / 100.0);
	new bit = floatround(rub / gBitRate, floatround_floor);
	if(bit < 1) return SendClientMessage(playerid, COLOR_ERR, "После 90% мало"), 0;
	PlayerUAH[playerid] -= amount; PlayerBit[playerid] += bit; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Гривна->бит: -%d = +%d (комиссия 90%%)", amount, bit);
	SendClientMessage(playerid, 0x0057B8FF, str);
	return 1;
}

stock EuroToUah(playerid, amount)
{
	if(amount <= 0 || PlayerEuro[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new Float:rub = float(amount) * gEuroRate * (1.0 - float(UAH_FEE_PCT) / 100.0);
	new uah = floatround(rub / gUahRate, floatround_floor);
	if(uah < 1) return SendClientMessage(playerid, COLOR_ERR, "После 90% мало"), 0;
	PlayerEuro[playerid] -= amount; PlayerUAH[playerid] += uah; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Евро->гривна: -%d = +%d (комиссия 90%%)", amount, uah);
	SendClientMessage(playerid, 0x0057B8FF, str);
	return 1;
}

stock BitToUah(playerid, amount)
{
	if(amount <= 0 || PlayerBit[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало битка"), 0;
	new Float:rub = float(amount) * gBitRate * (1.0 - float(UAH_FEE_PCT) / 100.0);
	new uah = floatround(rub / gUahRate, floatround_floor);
	if(uah < 1) return SendClientMessage(playerid, COLOR_ERR, "После 90% мало"), 0;
	PlayerBit[playerid] -= amount; PlayerUAH[playerid] += uah; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Бит->гривна: -%d = +%d (комиссия 90%%)", amount, uah);
	SendClientMessage(playerid, 0x0057B8FF, str);
	return 1;
}

stock DonateToUah(playerid, don_amount)
{
	if(!PlayerLoaded[playerid] || don_amount <= 0 || PlayerAccID[playerid] < 1) return 0;
	new q[220];
	mysql_format(gSQL, q, sizeof q, "SELECT IFNULL(`rub`,0) FROM `accounts` WHERE `id`=%d LIMIT 1", PlayerAccID[playerid]);
	mysql_tquery(gSQL, q, "OnDonateToUahCheck", "ii", playerid, don_amount);
	return 1;
}

forward OnDonateToUahCheck(playerid, don_amount);
public OnDonateToUahCheck(playerid, don_amount)
{
	if(!IsPlayerConnected(playerid) || !PlayerLoaded[playerid]) return 1;
	new have = 0;
	if(cache_get_row_count(gSQL) > 0) have = cache_get_row_int(0, 0, gSQL);
	if(have < don_amount)
	{
		new str[100]; format(str, sizeof str, "Мало БЦ (rub). Нужно %d, есть %d", don_amount, have);
		return SendClientMessage(playerid, COLOR_ERR, str), 1;
	}
	new after = don_amount - (don_amount * UAH_FEE_PCT) / 100;
	if(after < 1) return SendClientMessage(playerid, COLOR_ERR, "После 90% ничего"), 1;
	new uah = floatround(float(after) / gUahRate, floatround_floor);
	if(uah < 1) uah = after;
	new q[280];
	mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `rub`=IFNULL(`rub`,0)-%d WHERE `id`=%d AND IFNULL(`rub`,0)>=%d LIMIT 1", don_amount, PlayerAccID[playerid], don_amount);
	mysql_tquery(gSQL, q);
	PlayerUAH[playerid] += uah; SaveEuro(playerid);
	new str[120]; format(str, sizeof str, "{0057B8}БЦ->гривна: -%d = +%d (комиссия 90%%)", don_amount, uah);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock ShowUahTop(playerid)
{
	mysql_tquery(gSQL, "SELECT `name`,IFNULL(`uah`,0) AS u FROM `accounts` ORDER BY IFNULL(`uah`,0) DESC LIMIT 50", "OnUahTop", "i", playerid);
	return 1;
}
forward OnUahTop(playerid);
public OnUahTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[90], name[24], u;
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_field_content(i, "name", name, gSQL, sizeof name);
		u = cache_get_field_content_int(i, "u", gSQL);
		if(i == 0) format(line, sizeof line, "{0057B8}1. %s - %d\n", name, u);
		else if(i == 1) format(line, sizeof line, "{C0C0C0}2. %s - %d\n", name, u);
		else if(i == 2) format(line, sizeof line, "{CD7F32}3. %s - %d\n", name, u);
		else format(line, sizeof line, "%d. %s - %d\n", i + 1, name, u);
		if(strlen(body) + strlen(line) >= sizeof body - 2) break;
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	ShowPlayerDialog(playerid, D_UAH_TOP, DIALOG_STYLE_MSGBOX, "{0057B8}Топ гривны", body, "OK", "");
	return 1;
}

stock ShowKztTop(playerid)
{
	mysql_tquery(gSQL, "SELECT `name`,IFNULL(`kzt`,0) AS k FROM `accounts` ORDER BY IFNULL(`kzt`,0) DESC LIMIT 50", "OnKztTop", "i", playerid);
	return 1;
}
forward OnKztTop(playerid);
public OnKztTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[90], name[24], k;
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_field_content(i, "name", name, gSQL, sizeof name);
		k = cache_get_field_content_int(i, "k", gSQL);
		if(i == 0) format(line, sizeof line, "{00AFCA}1. %s - %d\n", name, k);
		else if(i == 1) format(line, sizeof line, "{C0C0C0}2. %s - %d\n", name, k);
		else if(i == 2) format(line, sizeof line, "{CD7F32}3. %s - %d\n", name, k);
		else format(line, sizeof line, "%d. %s - %d\n", i + 1, name, k);
		if(strlen(body) + strlen(line) >= sizeof body - 2) break;
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	ShowPlayerDialog(playerid, D_KZT_TOP, DIALOG_STYLE_MSGBOX, "{00AFCA}Топ тенге", body, "OK", "");
	return 1;
}

stock ShowUahMenu(playerid)
{
	if(!PlayerLoaded[playerid]) return 1;
	new body[700];
	format(body, sizeof body,
		"Гривна (UAH): %d\nКурс ~%.2f руб\nКомиссия обмена 90%%\nГривна -> евро\nГривна -> бит\nЕвро -> гривна\nБит -> гривна\nБЦ(донат) -> гривна\nПередать гривну (20%%)\nТоп гривны\nКупить админку (%d)\nКупить лидерку семьи (%d)\nНазад",
		PlayerUAH[playerid], gUahRate, UAH_ADMIN_PRICE, UAH_LEADER_PRICE);
	ShowPlayerDialog(playerid, D_UAH_MENU, DIALOG_STYLE_LIST, "{0057B8}Гривна", body, "OK", "X");
	return 1;
}

stock ShowKztMenu(playerid)
{
	if(!PlayerLoaded[playerid]) return 1;
	new body[700];
	format(body, sizeof body,
		"Тенге (KZT): %d\nКурс ~%.3f руб\nКомиссия обмена 70%%\nТенге -> евро\nТенге -> бит\nЕвро -> тенге\nБит -> тенге\nПередать тенге (20%%)\nТоп тенге\nНазад",
		PlayerKZT[playerid], gKztRate);
	ShowPlayerDialog(playerid, D_KZT_MENU, DIALOG_STYLE_LIST, "{00AFCA}Тенге", body, "OK", "X");
	return 1;
}

// ===================== FUNCOIN =====================
stock FunFeeReceive(amount)
{
	new fee = (amount * FUN_FEE_PCT) / 100;
	if(fee < 1 && amount >= 1) fee = amount; // 99% — почти всё
	new recv = amount - fee;
	if(recv < 1) recv = 0;
	return recv;
}

stock ShowFunMenu(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(!gSQLOk || !PlayerLoaded[playerid])
	{
		LoadEuro(playerid);
		SendClientMessage(playerid, COLOR_ERR, "Загрузка...");
		return 1;
	}
	new body[1400];
	format(body, sizeof body,
		"Баланс FC: %d\n+200 каждый час\nКупить код (500 FC)\nМои коды\nПередать FC (99%%)\nFC в евро (99%%)\nFC в бит (99%%)\nЕвро в FC (99%%)\nБит в FC (99%%)\nМем в FC (99%%)\nГривна в FC (99%%)\nТенге в FC (99%%)\nТоп FC\nНазад",
		PlayerFun[playerid]);
	ShowPlayerDialog(playerid, D_FUN_MENU, DIALOG_STYLE_LIST, "{7CFC00}Фанкоины", body, "OK", "X");
	return 1;
}

stock FunBuyCodeStart(playerid)
{
	if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Не загружено"), 0;
	if(PlayerFun[playerid] < FUN_CODE_PRICE) return SendClientMessage(playerid, COLOR_ERR, "Нужно 500 фанкоинов"), 0;
	ShowPlayerDialog(playerid, D_FUN_CODE_NICK, DIALOG_STYLE_INPUT, "Код для ника", "Ник игрока (как в игре), которому даёшь доступ:", "Далее", "X");
	return 1;
}

stock FunGenCode(dest[])
{
	static const c[] = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
	for(new i; i < 8; i++) dest[i] = c[random(sizeof(c) - 1)];
	dest[8] = 0;
}



forward OnFunCodeShow(playerid, days);
public OnFunCodeShow(playerid, days)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new code[16];
	if(cache_get_row_count(gSQL) < 1) return SendClientMessage(playerid, COLOR_ERR, "Ошибка кода"), 1;
	cache_get_row(0, 0, code, gSQL, sizeof code);
	new str[160];
	format(str, sizeof str, "{7CFC00}Код для {FFFFFF}%s{7CFC00}: {FFFF00}%s{7CFC00} (%d дн.). Передай никy этот код.", FunCodeNick[playerid], code, days);
	SendClientMessage(playerid, -1, str);
	SendClientMessage(playerid, 0xFFD700FF, "Получатель вводит этот код как спецкод при входе (AccessGate).");
	return 1;
}

stock FunCreateCode(playerid, days)
{
	if(!PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
	if(days != FUN_DAYS_30 && days != FUN_DAYS_365) days = FUN_DAYS_30;
	if(PlayerFun[playerid] < FUN_CODE_PRICE) return SendClientMessage(playerid, COLOR_ERR, "Мало фанкоинов"), 0;
	if(!FunCodeNick[playerid][0]) return SendClientMessage(playerid, COLOR_ERR, "Нет ника"), 0;

	PlayerFun[playerid] -= FUN_CODE_PRICE;
	SaveEuro(playerid);

	new code[16], fromname[MAX_PLAYER_NAME];
	FunGenCode(code);
	GetPlayerName(playerid, fromname, sizeof fromname);

	new q[360];
	mysql_format(gSQL, q, sizeof q,
		"INSERT INTO `fun_codes` (`code`,`from_acc`,`from_name`,`to_name`,`days`,`active`,`used`) VALUES ('%e',%d,'%e','%e',%d,1,0)",
		code, PlayerAccID[playerid], fromname, FunCodeNick[playerid], days);
	mysql_tquery(gSQL, q);

	// access_code у получателя НЕ трогаем, если уже есть свой код/доступ
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` SET `access_code`='%e' WHERE `name`='%e' AND (`access_code`='' OR `access_code` IS NULL) AND IFNULL(`access_ok`,0)=0 LIMIT 1",
		code, FunCodeNick[playerid]);
	mysql_tquery(gSQL, q);

	new str[200];
	format(str, sizeof str, "{7CFC00}-%d FC. Код для %s: {FFFF00}%s{7CFC00} | %d дн. Игрок вводит его как СПЕЦКОД (AccessGate).", FUN_CODE_PRICE, FunCodeNick[playerid], code, days);
	SendClientMessage(playerid, -1, str);
	printf("[Fun] code %s from %d to %s days=%d", code, PlayerAccID[playerid], FunCodeNick[playerid], days);
	return 1;
}

stock FunShowMyCodes(playerid)
{
	if(!PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
	new q[200];
	mysql_format(gSQL, q, sizeof q,
		"SELECT `id`,`code`,`to_name`,`days`,`active`,`used` FROM `fun_codes` WHERE `from_acc`=%d ORDER BY `id` DESC LIMIT 12",
		PlayerAccID[playerid]);
	mysql_tquery(gSQL, q, "OnFunList", "i", playerid);
	return 1;
}

forward OnFunList(playerid);
public OnFunList(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL);
	if(rows < 1) return SendClientMessage(playerid, COLOR_ERR, "Нет выданных кодов"), 1;
	new body[1400], line[96], code[16], ton[24];
	body[0] = 0;
	FunListCount[playerid] = 0;
	for(new i; i < rows && i < 12; i++)
	{
		new id = cache_get_row_int(i, 0, gSQL);
		cache_get_row(i, 1, code, gSQL, sizeof code);
		cache_get_row(i, 2, ton, gSQL, sizeof ton);
		new days = cache_get_row_int(i, 3, gSQL);
		new act = cache_get_row_int(i, 4, gSQL);
		new used = cache_get_row_int(i, 5, gSQL);
		FunListIds[playerid][FunListCount[playerid]++] = id;
		format(line, sizeof line, "%s -> %s | %dд | %s%s\n",
			code, ton, days,
			act ? "" : "[ОТОЗВАН] ",
			used ? "использован" : "ждёт");
		strcat(body, line);
	}
	strcat(body, "Назад");
	ShowPlayerDialog(playerid, D_FUN_CODE_LIST, DIALOG_STYLE_LIST, "Мои коды (выбери = отозвать)", body, "Отозвать", "X");
	return 1;
}

stock FunRevokeCode(playerid, listitem)
{
	if(listitem < 0 || listitem >= FunListCount[playerid]) return ShowFunMenu(playerid);
	new id = FunListIds[playerid][listitem];
	new q[280];
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `fun_codes` SET `active`=0 WHERE `id`=%d AND `from_acc`=%d LIMIT 1",
		id, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	// снять доступ у получателя если код был активен
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` a INNER JOIN `fun_codes` f ON a.`name`=f.`to_name` SET a.`access_ok`=0 WHERE f.`id`=%d AND f.`from_acc`=%d",
		id, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SendClientMessage(playerid, 0xFF4444FF, "Код отозван. Он больше не действует.");
	ShowFunMenu(playerid);
	return 1;
}

stock FunActivateCode(playerid, code[])
{
	if(!PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
	new q[200];
	mysql_format(gSQL, q, sizeof q,
		"SELECT `id`,`to_name`,`days`,`active`,`used` FROM `fun_codes` WHERE `code`='%e' LIMIT 1", code);
	mysql_tquery(gSQL, q, "OnFunActivate", "is", playerid, code);
	return 1;
}

forward OnFunActivate(playerid, code[]);
public OnFunActivate(playerid, code[])
{
	if(!IsPlayerConnected(playerid) || !PlayerLoaded[playerid]) return 1;
	if(cache_get_row_count(gSQL) < 1) return SendClientMessage(playerid, COLOR_ERR, "Код не найден"), 1;
	new id = cache_get_row_int(0, 0, gSQL);
	new ton[24];
	cache_get_row(0, 1, ton, gSQL, sizeof ton);
	new days = cache_get_row_int(0, 2, gSQL);
	new act = cache_get_row_int(0, 3, gSQL);
	new used = cache_get_row_int(0, 4, gSQL);
	if(!act) return SendClientMessage(playerid, COLOR_ERR, "Код отозван отправителем"), 1;
	if(used) return SendClientMessage(playerid, COLOR_ERR, "Код уже использован"), 1;

	new myname[MAX_PLAYER_NAME];
	GetPlayerName(playerid, myname, sizeof myname);
	if(strcmp(myname, ton, true) != 0)
		return SendClientMessage(playerid, COLOR_ERR, "Этот код выписан на другой ник"), 1;

	// дата до
	new y, m, d, ey, em, ed;
	getdate(y, m, d);
	// reuse AccessGate-style add days inline
	ey = y; em = m; ed = d;
	new left = days;
	while(left > 0)
	{
		new dim, leap;
		static const dima[] = {0,31,28,31,30,31,30,31,31,30,31,30,31};
		leap = ((ey % 4 == 0 && ey % 100 != 0) || (ey % 400 == 0));
		dim = (em == 2) ? (leap ? 29 : 28) : dima[em];
		new room = dim - ed;
		if(left <= room) { ed += left; left = 0; }
		else { left -= (room + 1); ed = 1; em++; if(em > 12) { em = 1; ey++; } }
	}

	new q[320];
	mysql_format(gSQL, q, sizeof q, "UPDATE `fun_codes` SET `used`=1, `to_acc`=%d WHERE `id`=%d LIMIT 1", PlayerAccID[playerid], id);
	mysql_tquery(gSQL, q);
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` SET `access_ok`=1, `access_code`='%e', `access_until_y`=%d, `access_until_m`=%d, `access_until_d`=%d WHERE `id`=%d LIMIT 1",
		code, ey, em, ed, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);

	new str[96];
	format(str, sizeof str, "{7CFC00}Код принят! Access до %02d.%02d.%04d (%d дн.)", ed, em, ey, days);
	SendClientMessage(playerid, -1, str);
	SendClientMessage(playerid, 0xFFD700FF, "Перезайди или подожди — AccessGate подхватит доступ.");
	return 1;
}

stock FunToEuro(playerid, amount)
{
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerFun[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало FC"), 0;
	new recv = FunFeeReceive(amount);
	if(recv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 99% ничего не остаётся (нужна большая сумма)"), 0;
	// грубо: 1 FC ~ как мелкий бонус в евро
	new euro = recv; // 1:1 после комиссии
	PlayerFun[playerid] -= amount;
	PlayerEuro[playerid] += euro;
	SaveEuro(playerid);
	new str[96];
	format(str, sizeof str, "FC->евро: -%d FC = +%d евро (комиссия 99%%)", amount, euro);
	SendClientMessage(playerid, 0x7CFC00FF, str);
	return 1;
}

stock FunToBit(playerid, amount)
{
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerFun[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало FC"), 0;
	new recv = FunFeeReceive(amount);
	if(recv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 99% пусто"), 0;
	PlayerFun[playerid] -= amount;
	PlayerBit[playerid] += recv;
	SaveEuro(playerid);
	new str[96];
	format(str, sizeof str, "FC->бит: -%d FC = +%d бит (комиссия 99%%)", amount, recv);
	SendClientMessage(playerid, 0x7CFC00FF, str);
	return 1;
}

stock CurrencyToFun(playerid, amount, ctype)
{
	// ctype: 1 euro 2 bit 3 meme 4 uah 5 kzt  | комиссия 99%
	if(!PlayerLoaded[playerid] || amount <= 0) return SendClientMessage(playerid, COLOR_ERR, "Неверная сумма"), 0;
	new bal;
	if(ctype == 1) bal = PlayerEuro[playerid];
	else if(ctype == 2) bal = PlayerBit[playerid];
	else if(ctype == 3) bal = PlayerMeme[playerid];
	else if(ctype == 4) bal = PlayerUAH[playerid];
	else if(ctype == 5) bal = PlayerKZT[playerid];
	else return 0;
	if(bal < amount) return SendClientMessage(playerid, COLOR_ERR, "Недостаточно средств"), 0;
	new recv = FunFeeReceive(amount);
	if(recv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 99% комиссии FC = 0 (нужна большая сумма)"), 0;
	if(ctype == 1) PlayerEuro[playerid] -= amount;
	else if(ctype == 2) PlayerBit[playerid] -= amount;
	else if(ctype == 3) PlayerMeme[playerid] -= amount;
	else if(ctype == 4) PlayerUAH[playerid] -= amount;
	else if(ctype == 5) PlayerKZT[playerid] -= amount;
	PlayerFun[playerid] += recv;
	SaveEuro(playerid);
	new str[120], cname[16];
	if(ctype == 1) format(cname, sizeof cname, "евро");
	else if(ctype == 2) format(cname, sizeof cname, "бит");
	else if(ctype == 3) format(cname, sizeof cname, "мем");
	else if(ctype == 4) format(cname, sizeof cname, "гривен");
	else format(cname, sizeof cname, "тенге");
	format(str, sizeof str, "{7CFC00}-%d %s = +%d FC (комиссия 99%%). FC: %d", amount, cname, recv, PlayerFun[playerid]);
	SendClientMessage(playerid, -1, str);
	return 1;
}



stock KztFromEuro(playerid, euro_amount)
{
	if(euro_amount <= 0 || PlayerEuro[playerid] < euro_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new getv = euro_amount - (euro_amount * KZT_FEE_PCT) / 100;
	if(getv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 70% ничего"), 0;
	PlayerEuro[playerid] -= euro_amount;
	PlayerKZT[playerid] += getv;
	SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Евро->тенге: -%d = +%d (комиссия 70%%)", euro_amount, getv);
	SendClientMessage(playerid, 0x00AFCAFF, str);
	return 1;
}

stock KztFromBit(playerid, bit_amount)
{
	if(bit_amount <= 0 || PlayerBit[playerid] < bit_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало битка"), 0;
	new getv = bit_amount - (bit_amount * KZT_FEE_PCT) / 100;
	if(getv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 70% ничего"), 0;
	PlayerBit[playerid] -= bit_amount;
	PlayerKZT[playerid] += getv;
	SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Бит->тенге: -%d = +%d (комиссия 70%%)", bit_amount, getv);
	SendClientMessage(playerid, 0x00AFCAFF, str);
	return 1;
}

stock KztToEuro(playerid, kzt_amount)
{
	if(kzt_amount <= 0 || PlayerKZT[playerid] < kzt_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало тенге"), 0;
	new getv = kzt_amount - (kzt_amount * KZT_FEE_PCT) / 100;
	if(getv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 70% ничего"), 0;
	PlayerKZT[playerid] -= kzt_amount;
	PlayerEuro[playerid] += getv;
	SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Тенге->евро: -%d = +%d (комиссия 70%%)", kzt_amount, getv);
	SendClientMessage(playerid, 0x00AFCAFF, str);
	return 1;
}

stock KztToBit(playerid, kzt_amount)
{
	if(kzt_amount <= 0 || PlayerKZT[playerid] < kzt_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало тенге"), 0;
	new getv = kzt_amount - (kzt_amount * KZT_FEE_PCT) / 100;
	if(getv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 70% ничего"), 0;
	PlayerKZT[playerid] -= kzt_amount;
	PlayerBit[playerid] += getv;
	SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Тенге->бит: -%d = +%d (комиссия 70%%)", kzt_amount, getv);
	SendClientMessage(playerid, 0x00AFCAFF, str);
	return 1;
}

stock UahBuyAdmin(playerid)
{
	if(PlayerUAH[playerid] < UAH_ADMIN_PRICE)
		return SendClientMessage(playerid, COLOR_ERR, "Нужно 200000 гривен"), 0;
	PlayerUAH[playerid] -= UAH_ADMIN_PRICE;
	SaveEuro(playerid);
	new q[160];
	mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `admin`=1 WHERE `id`=%d LIMIT 1", PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SendClientMessage(playerid, 0x0057B8FF, "Куплена админка (admin=1). Релог!");
	return 1;
}

stock UahBuyLeader(playerid)
{
	if(PlayerUAH[playerid] < UAH_LEADER_PRICE)
		return SendClientMessage(playerid, COLOR_ERR, "Нужно 200000 гривен"), 0;
	PlayerUAH[playerid] -= UAH_LEADER_PRICE;
	SaveEuro(playerid);
	new q[180];
	mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `family_rang`=5 WHERE `id`=%d AND `family_id`>0 LIMIT 1", PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SendClientMessage(playerid, 0x0057B8FF, "Лидерка семьи (rang 5), если ты уже в семье. Релог!");
	return 1;
}


stock ShowMenu(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(!gSQLOk) return SendClientMessage(playerid, COLOR_ERR, "БД offline"), 1;
	if(!PlayerLoaded[playerid])
	{
		LoadEuro(playerid);
		SendClientMessage(playerid, COLOR_ERR, "Загрузка... напиши .euro ещё раз через 2 сек");
		return 1;
	}
	// анти-спам .euro (двойной вызов иногда роняет диалоги)
	new now = GetTickCount();
	if(EuroMenuTick[playerid] && now - EuroMenuTick[playerid] < 400) return 1;
	EuroMenuTick[playerid] = now;
	UpdateRate();
	MemeFixName();
	new body[1400];
	format(body, sizeof body,
		"Евро: %d | Бит: %d | %s: %d\nГривна: %d | Тенге: %d | FC: %d\nКурс евро %.2f | BTC %.0f\nЕвро -> нал\nЕвро -> банк\nНал -> евро\nБанк -> евро\nЕвро -> бит (20%%)\nПередать евро\nСкин\nАкс\nМашина\nТюнинг (10000, в авто)\nСемья\nТоп евро\nМеню битка\nМеню мемкоина\nГривна\nТенге\nФанкоины\nОбновить",
		PlayerEuro[playerid], PlayerBit[playerid], gMemeName, PlayerMeme[playerid],
		PlayerUAH[playerid], PlayerKZT[playerid], PlayerFun[playerid], gEuroRate, gBitRate);
	ShowPlayerDialog(playerid, D_EURO_MENU, DIALOG_STYLE_LIST, "{FFD700}Евро", body, "OK", "X");
	return 1;
}

stock ShowBitMenu(playerid)
{
	if(!gSQLOk || !PlayerLoaded[playerid]) { LoadEuro(playerid); return SendClientMessage(playerid, COLOR_ERR, "Загрузка..."), 1; }
	new body[600];
	format(body, sizeof body,
		"Биток: %d\nКурс BTC %.0f\nБит -> нал (5%%)\nБит -> банк (5%%)\nБит -> евро (5%%)\nПередать бит (20%%)\nТоп битка\nEuro\nMeme\nRefresh",
		PlayerBit[playerid], gBitRate);
	ShowPlayerDialog(playerid, D_BIT_MENU, DIALOG_STYLE_LIST, "{00BFFF}Биток", body, "OK", "X");
	return 1;
}

stock ShowMemeMenu(playerid)
{
	if(!gSQLOk || !PlayerLoaded[playerid]) { LoadEuro(playerid); return SendClientMessage(playerid, COLOR_ERR, "Загрузка..."), 1; }
	MemeFixName();
	new body[800], status[16];
	if(MemeSeasonActive()) format(status, sizeof status, "активен");
	else format(status, sizeof status, "ОКОНЧЕН");
	format(body, sizeof body,
		"%s: %d (%s)\nДо %02d.%02d.%04d %02d:%02d | курс %.1f\nМем -> нал\nМем -> банк\nМем -> евро\nМем -> бит\nЕвро -> мем\nБит -> мем\nДонат(БЦ) -> мем\nМем -> донат(БЦ)\nПередать мем (50%%)\nПолёт (10 мем)\nРандом скин/тачка/акс (%d)\nТоп мемкоина\nГривна\nТенге\nЕвро | Биток\nОбновить",
		gMemeName, PlayerMeme[playerid], status,
		gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi, gMemeRate,
		MemeRandPrice(playerid));
	new mt[48];
	format(mt, sizeof mt, "{FF69B4}%s", gMemeName);
	ShowPlayerDialog(playerid, D_MEME_MENU, DIALOG_STYLE_LIST, mt, body, "OK", "X");
	return 1;
}

stock Cmd(playerid, cmd[])
{
	if(!strcmp(cmd, "euro", true) || !strcmp(cmd, "eurobal", true)) return ShowMenu(playerid);
	if(!strcmp(cmd, "bit", true) || !strcmp(cmd, "bitok", true)) return ShowBitMenu(playerid);
	if(!strcmp(cmd, "meme", true) || !strcmp(cmd, "memecoin", true) || !strcmp(cmd, "mm", true)) return ShowMemeMenu(playerid);
	if(!strcmp(cmd, "uah", true) || !strcmp(cmd, "grivna", true)) return ShowUahMenu(playerid);
	if(!strcmp(cmd, "kzt", true) || !strcmp(cmd, "tenge", true)) return ShowKztMenu(playerid);
	if(!strcmp(cmd, "fun", true) || !strcmp(cmd, "funcoin", true) || !strcmp(cmd, "fc", true)) return ShowFunMenu(playerid);
	if(!strcmp(cmd, "eurotop", true)) return ShowTop(playerid);
	if(!strcmp(cmd, "bittop", true)) return ShowBitTop(playerid);
	if(!strcmp(cmd, "memetop", true)) return ShowMemeTop(playerid);
	if(!strcmp(cmd, "euroex", true))
	{
		ShowPlayerDialog(playerid, D_EURO_EX, DIALOG_STYLE_LIST, "{FFD700}Обмен", "Евро->нал\nЕвро->банк\nНал->евро\nБанк->евро\nЕвро->бит", "OK", "X");
		return 1;
	}
	if(!strcmp(cmd, "bitex", true))
	{
		ShowPlayerDialog(playerid, D_BIT_EX, DIALOG_STYLE_LIST, "{00BFFF}Обмен", "Бит->нал\nБит->банк\nБит->евро", "OK", "X");
		return 1;
	}
	if(!strcmp(cmd, "euroskin", true)) { ShowPlayerDialog(playerid, D_EURO_SKIN, DIALOG_STYLE_INPUT, "Скин", "ID:", "OK", "X"); return 1; }
	if(!strcmp(cmd, "euroacs", true)) { ShowPlayerDialog(playerid, D_EURO_ACS, DIALOG_STYLE_INPUT, "Акс", "ID:", "OK", "X"); return 1; }
	if(!strcmp(cmd, "eurocar", true)) { ShowPlayerDialog(playerid, D_EURO_CAR, DIALOG_STYLE_INPUT, "Машина", "ID:", "OK", "X"); return 1; }
	if(!strcmp(cmd, "eurofamily", true)) return StartFamilyBuy(playerid);
	return 0;
}


forward OnFunTop(playerid);
public OnFunTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[64], name[24];
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_row(i, 0, name, gSQL, sizeof name);
		new v = cache_get_row_int(i, 1, gSQL);
		format(line, sizeof line, "%d. %s - %d FC\n", i + 1, name, v);
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	ShowPlayerDialog(playerid, D_FUN_TOP, DIALOG_STYLE_MSGBOX, "Топ фанкоинов", body, "OK", "");
	return 1;
}

public OnFilterScriptInit()
{
	print("  [Euro+Bit+Meme] Алабуга загрузка");
	gSQLOk = 0; gSQL = 0; gMemeSeasonEnded = false;
	if(!LoadIni()) { print("[Euro] нет ini"); return 1; }
	if(!ConnectSQL()) { print("[Euro] MySQL ошибка"); return 1; }
	gSQLOk = 1;
	mysql_tquery(gSQL, "SET NAMES 'cp1251'");
	mysql_tquery(gSQL, "SET CHARACTER SET cp1251");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `evro` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `evro_exchanged` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `bitok` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `memecoin` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `meme_last` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `uah` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `kzt` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `play_sec` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `meme_rand` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `funcoin` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "CREATE TABLE IF NOT EXISTS `fun_codes` (`id` INT AUTO_INCREMENT PRIMARY KEY, `code` VARCHAR(16) NOT NULL, `from_acc` INT NOT NULL, `from_name` VARCHAR(24) NOT NULL, `to_name` VARCHAR(24) NOT NULL, `days` INT NOT NULL DEFAULT 30, `active` TINYINT NOT NULL DEFAULT 1, `used` TINYINT NOT NULL DEFAULT 0, `to_acc` INT NOT NULL DEFAULT 0, UNIQUE KEY `uk_code` (`code`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
	MemeLoadSeasonFromDB();
	UpdateRate();
	SetTimer("UpdateRate", 300000, true);
	SetTimer("PayDay", 30000, true);
	SetTimer("MemeAnnounce", MEME_ANNOUNCE_MS, true);
	SetTimer("MemeCheckSeasonTick", 60000, true);
	SetTimer("PlaytimeTick", 1000, true);
	print("[Euro+Bit+Meme] OK");
	return 1;
}

public OnFilterScriptExit()
{
	if(gSQLOk) mysql_close(gSQL);
	return 1;
}

public OnPlayerConnect(playerid)
{
	PlayerEuro[playerid] = 0; PlayerEuroEx[playerid] = 0; PlayerAccID[playerid] = 0;
	PlayerBit[playerid] = 0; PlayerMeme[playerid] = 0; PlayerDonate[playerid] = 0;
	PlayerUAH[playerid] = 0; PlayerKZT[playerid] = 0; PlayerFun[playerid] = 0; PlayerPlaySec[playerid] = 0;
	PlayerRandBuys[playerid] = 0; PlayerFlyTimer[playerid] = 0; PlayerFlyActive[playerid] = 0; KztExMode[playerid] = 0;
	UahGiveTarget[playerid] = KztGiveTarget[playerid] = INVALID_PLAYER_ID; UahExMode[playerid] = 0;
	PlayerLastLogin[playerid] = 0; PlayerLoaded[playerid] = false;
	EuroGiveTarget[playerid] = BitGiveTarget[playerid] = MemeGiveTarget[playerid] = INVALID_PLAYER_ID;
	EuroExMode[playerid] = EuroBuyMode[playerid] = BitExMode[playerid] = MemeExMode[playerid] = 0;
	FamilyNamePending[playerid][0] = 0;
	SetTimerEx("LoadEuro", 5000, false, "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if(playerid < 0 || playerid >= MAX_PLAYERS) return 1;

	// остановить полёт — таймер иначе дергает GetPlayerKeys после leave
	if(PlayerFlyTimer[playerid])
	{
		KillTimer(PlayerFlyTimer[playerid]);
		PlayerFlyTimer[playerid] = 0;
	}
	PlayerFlyActive[playerid] = 0;

	if(PlayerLoaded[playerid] && PlayerAccID[playerid] > 0)
	{
		PlayerLastLogin[playerid] = gettime();
		SaveEuro(playerid); // async
	}
	PlayerLoaded[playerid] = false;
	PlayerAccID[playerid] = 0;
	EuroGiveTarget[playerid] = BitGiveTarget[playerid] = MemeGiveTarget[playerid] = INVALID_PLAYER_ID;
	UahGiveTarget[playerid] = KztGiveTarget[playerid] = INVALID_PLAYER_ID;
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(text[0] != '.') return 1;
	new cmd[40]; format(cmd, sizeof cmd, "%s", text[1]);
	new sp = strfind(cmd, " "); if(sp != -1) cmd[sp] = 0;
	if(Cmd(playerid, cmd)) return 0;
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(cmdtext[0] != '/') return 0;
	new cmd[40]; format(cmd, sizeof cmd, "%s", cmdtext[1]);
	new sp = strfind(cmd, " "); if(sp != -1) cmd[sp] = 0;
	if(Cmd(playerid, cmd)) return 1;
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == D_EURO_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1, 2: ShowMenu(playerid);
			case 3: { EuroExMode[playerid] = 0; ShowPlayerDialog(playerid, D_EURO_EX_AMT, DIALOG_STYLE_INPUT, "Евро->нал", "Сколько евро?", "OK", "X"); }
			case 4: { EuroExMode[playerid] = 1; ShowPlayerDialog(playerid, D_EURO_EX_AMT, DIALOG_STYLE_INPUT, "Евро->банк", "Сколько евро?", "OK", "X"); }
			case 5: { EuroBuyMode[playerid] = 0; ShowPlayerDialog(playerid, D_EURO_BUY_AMT, DIALOG_STYLE_INPUT, "Нал->евро", "Сколько руб?", "OK", "X"); }
			case 6: { EuroBuyMode[playerid] = 1; ShowPlayerDialog(playerid, D_EURO_BUY_AMT, DIALOG_STYLE_INPUT, "Банк->евро", "Сколько руб?", "OK", "X"); }
			case 7: ShowPlayerDialog(playerid, D_E2B_AMT, DIALOG_STYLE_INPUT, "Евро->бит", "Сколько евро?", "OK", "X");
			case 8: ShowPlayerDialog(playerid, D_EURO_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "ID:", "OK", "X");
			case 9: ShowPlayerDialog(playerid, D_EURO_SKIN, DIALOG_STYLE_INPUT, "Скин", "ID:", "OK", "X");
			case 10: ShowPlayerDialog(playerid, D_EURO_ACS, DIALOG_STYLE_INPUT, "Акс", "ID:", "OK", "X");
			case 11: ShowPlayerDialog(playerid, D_EURO_CAR, DIALOG_STYLE_INPUT, "Машина", "ID:", "OK", "X");
			case 12: // тюнинг
			{
				if(!IsPlayerInAnyVehicle(playerid)) SendClientMessage(playerid, COLOR_ERR, "Сядь в машину для тюнинга");
				else if(PlayerEuro[playerid] < EURO_TUNE_PRICE) SendClientMessage(playerid, COLOR_ERR, "Нужно 10000 евро");
				else ShowPlayerDialog(playerid, D_EURO_TUNE, DIALOG_STYLE_LIST, "{FFD700}Тюнинг 10000 евро",
					"Нитро\nГидравлика\nСпойлер 1\nСпойлер 2\nГлушитель 1\nГлушитель 2\nГлушитель 3\nГлушитель 4\nГлушитель 5\nСпойлер 3\nСпойлер 4\nСпойлер 5\nСпойлер 6\nКапот 1\nКапот 2\nКапот 3\nПороги 1\nПороги 2\nПороги 3\nФары\nВоздухозаборник 1\nВоздухозаборник 2\nВоздухозаборник 3\nВоздухозаборник 4\nСпойлер 7\nАнтенна\nКолёса Offroad\nКолёса Shadow\nКолёса Mega\nКолёса Rimshine\nКолёса Wires\nКолёса Classic\nКолёса Twist\nКолёса Cutter\nКолёса Shift\nКолёса Dollar\nКолёса Trance\nКолёса Atomic\nКолёса Ahab\nКолёса Virtual\nКолёса Access\nКолёса Import\nКолёса Grove\nКолёса Vista\nPaintjob 0\nPaintjob 1\nPaintjob 2\nPaintjob 3\nНомер EURO\nРемонт",
					"OK", "X");
			}
			case 13: StartFamilyBuy(playerid);
			case 14: ShowTop(playerid);
			case 15: ShowBitMenu(playerid);
			case 16: ShowMemeMenu(playerid);
			case 17: ShowUahMenu(playerid);
			case 18: ShowKztMenu(playerid);
			case 19: ShowFunMenu(playerid);
			case 20: { SaveEuro(playerid); ShowMenu(playerid); }
		}
		return 1;
	}
	if(dialogid == D_BIT_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1: ShowBitMenu(playerid);
			case 2: { BitExMode[playerid] = 0; ShowPlayerDialog(playerid, D_BIT_EX_AMT, DIALOG_STYLE_INPUT, "Бит->нал", "Сколько?", "OK", "X"); }
			case 3: { BitExMode[playerid] = 1; ShowPlayerDialog(playerid, D_BIT_EX_AMT, DIALOG_STYLE_INPUT, "Бит->банк", "Сколько?", "OK", "X"); }
			case 4: ShowPlayerDialog(playerid, D_B2E_AMT, DIALOG_STYLE_INPUT, "Бит->евро", "Сколько?", "OK", "X");
			case 5: ShowPlayerDialog(playerid, D_BIT_GIVE, DIALOG_STYLE_INPUT, "ID", "ID игрока:", "OK", "X");
			case 6: ShowBitTop(playerid);
			case 7: ShowMenu(playerid);
			case 8: ShowMemeMenu(playerid);
			case 9: { SaveEuro(playerid); ShowBitMenu(playerid); }
		}
		return 1;
	}
	if(dialogid == D_MEME_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1: ShowMemeMenu(playerid);
			case 2: { MemeExMode[playerid] = 0; ShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->нал", "Сколько?", "OK", "X"); }
			case 3: { MemeExMode[playerid] = 1; ShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->банк", "Сколько?", "OK", "X"); }
			case 4: { MemeExMode[playerid] = 2; ShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->евро", "Сколько?", "OK", "X"); }
			case 5: { MemeExMode[playerid] = 3; ShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->бит", "Сколько?", "OK", "X"); }
			case 6: ShowPlayerDialog(playerid, D_MEME_FROM_EUR, DIALOG_STYLE_INPUT, "Евро->мем", "Сколько евро?", "OK", "X");
			case 7: ShowPlayerDialog(playerid, D_MEME_FROM_BIT, DIALOG_STYLE_INPUT, "Бит->мем", "Сколько бит?", "OK", "X");
			case 8: ShowPlayerDialog(playerid, D_MEME_DONATE, DIALOG_STYLE_INPUT, "Донат->мем", "Сколько БЦ?", "OK", "X");
			case 9: { MemeExMode[playerid] = 4; ShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->донат", "Сколько?", "OK", "X"); }
			case 10: ShowPlayerDialog(playerid, D_MEME_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "ID:", "OK", "X");
			case 11: MemeBuyFly(playerid);
			case 12: MemeBuyRandom(playerid);
			case 13: ShowMemeTop(playerid);
			case 14: ShowUahMenu(playerid);
			case 15: ShowKztMenu(playerid);
			case 16: ShowMenu(playerid);
			case 17: { SaveEuro(playerid); ShowMemeMenu(playerid); }
		}
		return 1;
	}
	if(dialogid == D_EURO_EX)
	{
		if(!response) return 1;
		if(listitem <= 1) { EuroExMode[playerid] = listitem; ShowPlayerDialog(playerid, D_EURO_EX_AMT, DIALOG_STYLE_INPUT, "Евро", "Сколько?", "OK", "X"); }
		else if(listitem <= 3) { EuroBuyMode[playerid] = (listitem == 3); ShowPlayerDialog(playerid, D_EURO_BUY_AMT, DIALOG_STYLE_INPUT, "Руб", "Сколько?", "OK", "X"); }
		else ShowPlayerDialog(playerid, D_E2B_AMT, DIALOG_STYLE_INPUT, "Евро->бит", "Сколько?", "OK", "X");
		return 1;
	}
	if(dialogid == D_BIT_EX)
	{
		if(!response) return 1;
		if(listitem <= 1) { BitExMode[playerid] = listitem; ShowPlayerDialog(playerid, D_BIT_EX_AMT, DIALOG_STYLE_INPUT, "Бит", "Сколько?", "OK", "X"); }
		else ShowPlayerDialog(playerid, D_B2E_AMT, DIALOG_STYLE_INPUT, "Бит->евро", "Сколько?", "OK", "X");
		return 1;
	}
	if(dialogid == D_EURO_EX_AMT) { if(response) DoExchange(playerid, strval(inputtext), EuroExMode[playerid] == 1); return 1; }
	if(dialogid == D_EURO_BUY_AMT) { if(response) BuyEuroFromRub(playerid, strval(inputtext), EuroBuyMode[playerid] == 1); return 1; }
	if(dialogid == D_BIT_EX_AMT) { if(response) BitToRub(playerid, strval(inputtext), BitExMode[playerid] == 1); return 1; }
	if(dialogid == D_E2B_AMT) { if(response) EuroToBit(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_B2E_AMT) { if(response) BitToEuro(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_MEME_EX_AMT)
	{
		if(!response) return 1;
		new a = strval(inputtext);
		switch(MemeExMode[playerid])
		{
			case 0: MemeToRub(playerid, a, 0);
			case 1: MemeToRub(playerid, a, 1);
			case 2: MemeToEuro(playerid, a);
			case 3: MemeToBit(playerid, a);
			case 4: MemeToDonate(playerid, a);
		}
		return 1;
	}
	if(dialogid == D_MEME_FROM_EUR) { if(response) EuroToMeme(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_MEME_FROM_BIT) { if(response) BitToMeme(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_MEME_DONATE) { if(response) DonateToMeme(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_EURO_SKIN) { if(response) BuySkin(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_EURO_ACS) { if(response) BuyAcs(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_EURO_CAR) { if(response) BuyCar(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_EURO_FAM_NAME)
	{
		if(!response) return 1;
		if(strlen(inputtext) < 2 || strlen(inputtext) > 30) return SendClientMessage(playerid, COLOR_ERR, "2-30 символов"), 1;
		format(FamilyNamePending[playerid], 32, "%s", inputtext);
		ShowPlayerDialog(playerid, D_EURO_FAM_OK, DIALOG_STYLE_MSGBOX, "Семья", "Купить за 100000 евро?", "OK", "X");
		return 1;
	}
	if(dialogid == D_EURO_FAM_OK) { if(response) ConfirmFamily(playerid); return 1; }
	if(dialogid == D_EURO_GIVE)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Евро ещё не загружены"), 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID игрока"), 1;
		if(!PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "У игрока ещё не загружен баланс, подождите 2-5 сек"), 1;
		EuroGiveTarget[playerid] = tid;
		ShowPlayerDialog(playerid, D_EURO_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать евро", "Сколько евро отправить?", "OK", "X");
		return 1;
	}
	if(dialogid == D_EURO_GIVE_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Евро не загружены"), 1;
		new amt = strval(inputtext), tid = EuroGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "Игрок оффлайн или баланс не загружен"), 1;
		if(amt <= 0) return SendClientMessage(playerid, COLOR_ERR, "Сумма должна быть больше 0"), 1;
		if(PlayerEuro[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Недостаточно евро"), 1;
		PlayerEuro[playerid] -= amt;
		PlayerEuro[tid] += amt;
		SaveEuro(playerid);
		SaveEuro(tid);
		new str[96], n1[24], n2[24];
		GetPlayerName(playerid, n1, sizeof n1);
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{FFD700}Вы передали %d евро игроку %s [%d]", amt, n2, tid);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{FFD700}%s [%d] передал вам %d евро. Баланс: %d", n1, playerid, amt, PlayerEuro[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}
	if(dialogid == D_BIT_GIVE)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс ещё не загружен"), 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID игрока"), 1;
		if(!PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "У игрока ещё не загружен баланс, подождите 2-5 сек"), 1;
		BitGiveTarget[playerid] = tid;
		ShowPlayerDialog(playerid, D_BIT_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать бит", "Сколько бит? (комиссия 20%)", "OK", "X");
		return 1;
	}
	if(dialogid == D_BIT_GIVE_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс не загружен"), 1;
		new amt = strval(inputtext), tid = BitGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "Игрок оффлайн или баланс не загружен"), 1;
		if(amt <= 0) return SendClientMessage(playerid, COLOR_ERR, "Сумма должна быть больше 0"), 1;
		new fee = (amt * BIT_TRANSFER_FEE_PCT) / 100; if(fee < 1 && amt >= 5) fee = 1;
		new receive = amt - fee;
		if(receive < 1 || PlayerBit[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало битка / комиссия"), 1;
		PlayerBit[playerid] -= amt; PlayerBit[tid] += receive; SaveEuro(playerid); SaveEuro(tid);
		new str[112], n2[24];
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{00BFFF}-%d бит (комиссия %d), %s получил +%d", amt, fee, n2, receive);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{00BFFF}Вам пришло %d бит (с учётом комиссии). Баланс: %d", receive, PlayerBit[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}
	if(dialogid == D_MEME_GIVE)
	{
		if(!response) return 1;
		if(!MemeRequireActive(playerid)) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс ещё не загружен"), 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID игрока"), 1;
		if(!PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "У игрока ещё не загружен баланс, подождите 2-5 сек"), 1;
		MemeGiveTarget[playerid] = tid;
		ShowPlayerDialog(playerid, D_MEME_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать мем (50%)", "Сколько?", "OK", "X");
		return 1;
	}
	if(dialogid == D_MEME_GIVE_AMT)
	{
		if(!response) return 1;
		if(!MemeRequireActive(playerid)) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс не загружен"), 1;
		new amt = strval(inputtext), tid = MemeGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "Игрок оффлайн или баланс не загружен"), 1;
		if(amt <= 0) return SendClientMessage(playerid, COLOR_ERR, "Сумма должна быть больше 0"), 1;
		new fee = (amt * MEME_FEE_PCT) / 100; if(fee < 1 && amt >= 2) fee = 1;
		new receive = amt - fee;
		if(receive < 1 || PlayerMeme[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало мемкоина / комиссия 50%"), 1;
		PlayerMeme[playerid] -= amt; PlayerMeme[tid] += receive; SaveEuro(playerid); SaveEuro(tid);
		new str[112], n2[24];
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{FF69B4}-%d (комиссия 50%%=%d), %s получил +%d", amt, fee, n2, receive);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{FF69B4}+%d %s. Баланс: %d", receive, gMemeName, PlayerMeme[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}
	
	if(dialogid == D_UAH_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1, 2: ShowUahMenu(playerid);
			case 3: { UahExMode[playerid]=0; ShowPlayerDialog(playerid, D_UAH_EX_AMT, DIALOG_STYLE_INPUT, "Гривна->евро", "Сколько гривен?", "OK", "X"); }
			case 4: { UahExMode[playerid]=1; ShowPlayerDialog(playerid, D_UAH_EX_AMT, DIALOG_STYLE_INPUT, "Гривна->бит", "Сколько гривен?", "OK", "X"); }
			case 5: { UahExMode[playerid]=2; ShowPlayerDialog(playerid, D_UAH_EX_AMT, DIALOG_STYLE_INPUT, "Евро->гривна", "Сколько евро?", "OK", "X"); }
			case 6: { UahExMode[playerid]=3; ShowPlayerDialog(playerid, D_UAH_EX_AMT, DIALOG_STYLE_INPUT, "Бит->гривна", "Сколько бит?", "OK", "X"); }
			case 7: { UahExMode[playerid]=4; ShowPlayerDialog(playerid, D_UAH_EX_AMT, DIALOG_STYLE_INPUT, "БЦ->гривна", "Сколько БЦ?", "OK", "X"); }
			case 8: ShowPlayerDialog(playerid, D_UAH_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "ID:", "OK", "X");
			case 9: ShowUahTop(playerid);
			case 10: UahBuyAdmin(playerid);
			case 11: UahBuyLeader(playerid);
			case 12: ShowMenu(playerid);
		}
		return 1;
	}
	if(dialogid == D_KZT_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1, 2: ShowKztMenu(playerid);
			case 3: { KztExMode[playerid]=0; ShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Тенге->евро", "Сколько тенге?", "OK", "X"); }
			case 4: { KztExMode[playerid]=1; ShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Тенге->бит", "Сколько тенге?", "OK", "X"); }
			case 5: { KztExMode[playerid]=2; ShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Евро->тенге", "Сколько евро?", "OK", "X"); }
			case 6: { KztExMode[playerid]=3; ShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Бит->тенге", "Сколько бит?", "OK", "X"); }
			case 7: ShowPlayerDialog(playerid, D_KZT_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "ID:", "OK", "X");
			case 8: ShowKztTop(playerid);
			case 9: ShowMenu(playerid);
		}
		return 1;
	}
	if(dialogid == D_KZT_EX_AMT)
	{
		if(!response) return 1;
		new a = strval(inputtext);
		switch(KztExMode[playerid])
		{
			case 0: KztToEuro(playerid, a);
			case 1: KztToBit(playerid, a);
			case 2: KztFromEuro(playerid, a);
			case 3: KztFromBit(playerid, a);
		}
		return 1;
	}

	if(dialogid == D_UAH_EX_AMT)
	{
		if(!response) return 1;
		new a = strval(inputtext);
		switch(UahExMode[playerid])
		{
			case 0: UahToEuro(playerid, a);
			case 1: UahToBit(playerid, a);
			case 2: EuroToUah(playerid, a);
			case 3: BitToUah(playerid, a);
			case 4: DonateToUah(playerid, a);
		}
		return 1;
	}
	if(dialogid == D_UAH_GIVE)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс ещё не загружен"), 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID игрока"), 1;
		if(!PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "У игрока ещё не загружен баланс, подождите 2-5 сек"), 1;
		UahGiveTarget[playerid] = tid;
		ShowPlayerDialog(playerid, D_UAH_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать гривну", "Сколько? (комиссия 20%)", "OK", "X");
		return 1;
	}
	if(dialogid == D_UAH_GIVE_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс не загружен"), 1;
		new amt = strval(inputtext), tid = UahGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "Игрок оффлайн или баланс не загружен"), 1;
		if(amt <= 0) return SendClientMessage(playerid, COLOR_ERR, "Сумма должна быть больше 0"), 1;
		new fee = (amt * UAH_TRANSFER_FEE_PCT) / 100; if(fee < 1 && amt >= 5) fee = 1;
		new receive = amt - fee;
		if(receive < 1 || PlayerUAH[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало гривен / комиссия"), 1;
		PlayerUAH[playerid] -= amt; PlayerUAH[tid] += receive; SaveEuro(playerid); SaveEuro(tid);
		new str[112], n2[24];
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{0057B8}-%d гривен (комиссия %d), %s получил +%d", amt, fee, n2, receive);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{0057B8}Вам пришло %d гривен. Баланс: %d", receive, PlayerUAH[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}
	if(dialogid == D_KZT_GIVE)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс ещё не загружен"), 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID игрока"), 1;
		if(!PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "У игрока ещё не загружен баланс, подождите 2-5 сек"), 1;
		KztGiveTarget[playerid] = tid;
		ShowPlayerDialog(playerid, D_KZT_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать тенге", "Сколько? (комиссия 20%)", "OK", "X");
		return 1;
	}
	if(dialogid == D_KZT_GIVE_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс не загружен"), 1;
		new amt = strval(inputtext), tid = KztGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "Игрок оффлайн или баланс не загружен"), 1;
		if(amt <= 0) return SendClientMessage(playerid, COLOR_ERR, "Сумма должна быть больше 0"), 1;
		new fee = (amt * KZT_TRANSFER_FEE_PCT) / 100; if(fee < 1 && amt >= 5) fee = 1;
		new receive = amt - fee;
		if(receive < 1 || PlayerKZT[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало тенге / комиссия"), 1;
		PlayerKZT[playerid] -= amt; PlayerKZT[tid] += receive; SaveEuro(playerid); SaveEuro(tid);
		new str[112], n2[24];
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{00AFCA}-%d тенге (комиссия %d), %s получил +%d", amt, fee, n2, receive);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{00AFCA}Вам пришло %d тенге. Баланс: %d", receive, PlayerKZT[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}

	// ===== FUNCOIN dialogs =====
	if(dialogid == D_FUN_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1: ShowFunMenu(playerid);
			case 2: FunBuyCodeStart(playerid);
			case 3: FunShowMyCodes(playerid);
			case 4: ShowPlayerDialog(playerid, D_FUN_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "Кому передать FC (комиссия 99%):", "OK", "X");
			case 5:
			{
				FunCodeDays[playerid] = 0;
				ShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "FC -> евро", "Сколько FC? (комиссия 99%)", "OK", "X");
			}
			case 6:
			{
				FunCodeDays[playerid] = 1;
				ShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "FC -> бит", "Сколько FC? (комиссия 99%)", "OK", "X");
			}
			case 7:
			{
				FunCodeDays[playerid] = 10;
				ShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "Евро -> FC", "Сколько евро? (комиссия 99%)", "OK", "X");
			}
			case 8:
			{
				FunCodeDays[playerid] = 11;
				ShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "Бит -> FC", "Сколько бит? (комиссия 99%)", "OK", "X");
			}
			case 9:
			{
				FunCodeDays[playerid] = 12;
				ShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "Мем -> FC", "Сколько мемкоинов? (комиссия 99%)", "OK", "X");
			}
			case 10:
			{
				FunCodeDays[playerid] = 13;
				ShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "Гривна -> FC", "Сколько гривен? (комиссия 99%)", "OK", "X");
			}
			case 11:
			{
				FunCodeDays[playerid] = 14;
				ShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "Тенге -> FC", "Сколько тенге? (комиссия 99%)", "OK", "X");
			}
			case 12:
			{
				mysql_tquery(gSQL, "SELECT `name`,IFNULL(`funcoin`,0) AS f FROM `accounts` ORDER BY IFNULL(`funcoin`,0) DESC LIMIT 50", "OnFunTop", "i", playerid);
			}
			case 13: ShowMenu(playerid);
		}
		return 1;
	}
	if(dialogid == D_FUN_CODE_NICK)
	{
		if(!response) return ShowFunMenu(playerid);
		if(!PlayerLoaded[playerid]) return 1;
		new nick[MAX_PLAYER_NAME];
		format(nick, sizeof nick, "%s", inputtext);
		for(new i = strlen(nick) - 1; i >= 0; i--) if(nick[i] <= ' ') nick[i] = 0; else break;
		if(strlen(nick) < 3) return SendClientMessage(playerid, COLOR_ERR, "Короткий ник"), ShowFunMenu(playerid);
		format(FunCodeNick[playerid], MAX_PLAYER_NAME, "%s", nick);
		ShowPlayerDialog(playerid, D_FUN_CODE_DAYS, DIALOG_STYLE_LIST, "Срок кода", "30 дней (500 FC)\n365 дней (500 FC)", "OK", "X");
		return 1;
	}
	if(dialogid == D_FUN_CODE_DAYS)
	{
		if(!response) return ShowFunMenu(playerid);
		new days = (listitem == 1) ? FUN_DAYS_365 : FUN_DAYS_30;
		FunCreateCode(playerid, days);
		return 1;
	}
	if(dialogid == D_FUN_CODE_LIST)
	{
		if(!response) return ShowFunMenu(playerid);
		if(listitem >= FunListCount[playerid]) return ShowFunMenu(playerid);
		FunRevokeCode(playerid, listitem);
		return 1;
	}
	if(dialogid == D_FUN_ACTIVATE)
	{
		if(!response) return ShowFunMenu(playerid);
		new code[32];
		format(code, sizeof code, "%s", inputtext);
		for(new i = strlen(code) - 1; i >= 0; i--) if(code[i] <= ' ') code[i] = 0; else break;
		if(strlen(code) < 4) return SendClientMessage(playerid, COLOR_ERR, "Короткий код"), 1;
		FunActivateCode(playerid, code);
		return 1;
	}
	if(dialogid == D_FUN_GIVE)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID"), 1;
		if(!PlayerLoaded[tid]) return SendClientMessage(playerid, COLOR_ERR, "У игрока баланс не загружен"), 1;
		FunGiveTarget[playerid] = tid;
		ShowPlayerDialog(playerid, D_FUN_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать FC", "Сумма (комиссия 99%):", "OK", "X");
		return 1;
	}
	if(dialogid == D_FUN_GIVE_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return 1;
		new amt = strval(inputtext), tid = FunGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid]) return SendClientMessage(playerid, COLOR_ERR, "Игрок офф"), 1;
		if(amt <= 0 || PlayerFun[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало FC"), 1;
		new recv = FunFeeReceive(amt);
		if(recv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 99% получателю 0"), 1;
		PlayerFun[playerid] -= amt;
		PlayerFun[tid] += recv;
		SaveEuro(playerid); SaveEuro(tid);
		new str[112], n2[24];
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{7CFC00}-%d FC (99%% комиссия), %s получил +%d", amt, n2, recv);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{7CFC00}Вам пришло %d FC (с комиссией 99%%). Баланс: %d", recv, PlayerFun[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}
	if(dialogid == D_FUN_EX_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return 1;
		new amt = strval(inputtext);
		new mode = FunCodeDays[playerid];
		FunCodeDays[playerid] = 0;
		if(mode == 1) FunToBit(playerid, amt);
		else if(mode == 10) CurrencyToFun(playerid, amt, 1); // euro
		else if(mode == 11) CurrencyToFun(playerid, amt, 2); // bit
		else if(mode == 12) CurrencyToFun(playerid, amt, 3); // meme
		else if(mode == 13) CurrencyToFun(playerid, amt, 4); // uah
		else if(mode == 14) CurrencyToFun(playerid, amt, 5); // kzt
		else FunToEuro(playerid, amt);
		return 1;
	}
	if(dialogid == D_FUN_TOP)
	{
		return 1;
	}

	if(dialogid == D_EURO_TUNE)
	{
		if(!response) return 1;
		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_ERR, "Сядь в машину"), 1;
		if(PlayerEuro[playerid] < EURO_TUNE_PRICE) return SendClientMessage(playerid, COLOR_ERR, "Нужно 10000 евро"), 1;
		new vid = GetPlayerVehicleID(playerid);
		PlayerEuro[playerid] -= EURO_TUNE_PRICE; SaveEuro(playerid);
		switch(listitem)
		{
			case 0: AddVehicleComponent(vid, 1010); // nitro
			case 1: AddVehicleComponent(vid, 1087); // hydraulics
			case 2: AddVehicleComponent(vid, 1008); // spoiler
			case 3: AddVehicleComponent(vid, 1009);
			case 4: AddVehicleComponent(vid, 1018); // exhaust
			case 5: AddVehicleComponent(vid, 1019);
			case 6: AddVehicleComponent(vid, 1020);
			case 7: AddVehicleComponent(vid, 1021);
			case 8: AddVehicleComponent(vid, 1022);
			case 9: AddVehicleComponent(vid, 1000); // spoiler
			case 10: AddVehicleComponent(vid, 1001);
			case 11: AddVehicleComponent(vid, 1002);
			case 12: AddVehicleComponent(vid, 1003);
			case 13: AddVehicleComponent(vid, 1004); // hood
			case 14: AddVehicleComponent(vid, 1005);
			case 15: AddVehicleComponent(vid, 1006);
			case 16: AddVehicleComponent(vid, 1007); // sideskirt
			case 17: AddVehicleComponent(vid, 1011);
			case 18: AddVehicleComponent(vid, 1012);
			case 19: AddVehicleComponent(vid, 1013); // lamps
			case 20: AddVehicleComponent(vid, 1014);
			case 21: AddVehicleComponent(vid, 1015);
			case 22: AddVehicleComponent(vid, 1016);
			case 23: AddVehicleComponent(vid, 1017);
			case 24: AddVehicleComponent(vid, 1023);
			case 25: AddVehicleComponent(vid, 1024);
			case 26: AddVehicleComponent(vid, 1025); // wheels
			case 27: AddVehicleComponent(vid, 1073);
			case 28: AddVehicleComponent(vid, 1074);
			case 29: AddVehicleComponent(vid, 1075);
			case 30: AddVehicleComponent(vid, 1076);
			case 31: AddVehicleComponent(vid, 1077);
			case 32: AddVehicleComponent(vid, 1078);
			case 33: AddVehicleComponent(vid, 1079);
			case 34: AddVehicleComponent(vid, 1080);
			case 35: AddVehicleComponent(vid, 1081);
			case 36: AddVehicleComponent(vid, 1082);
			case 37: AddVehicleComponent(vid, 1083);
			case 38: AddVehicleComponent(vid, 1084);
			case 39: AddVehicleComponent(vid, 1085);
			case 40: AddVehicleComponent(vid, 1086);
			case 41: AddVehicleComponent(vid, 1096);
			case 42: AddVehicleComponent(vid, 1097);
			case 43: AddVehicleComponent(vid, 1098);
			case 44: ChangeVehiclePaintjob(vid, 0);
			case 45: ChangeVehiclePaintjob(vid, 1);
			case 46: ChangeVehiclePaintjob(vid, 2);
			case 47: ChangeVehiclePaintjob(vid, 3);
			case 48: SetVehicleNumberPlate(vid, "EURO");
			case 49: RepairVehicle(vid);
		}
		SendClientMessage(playerid, COLOR_EURO, "Тюнинг установлен (-10000 евро)");
		return 1;
	}
	if(dialogid == D_EURO_TOP || dialogid == D_BIT_TOP || dialogid == D_MEME_TOP || dialogid == D_UAH_TOP || dialogid == D_KZT_TOP) return 1;
	return 0;
}
