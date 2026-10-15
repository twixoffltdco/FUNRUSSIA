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

#define ITEM_SKIN			134

new Float:gEuroRate = 94.97;
new Float:gBitRate = 6500000.0;
new Float:gMemeRate = 100.0;
new gSQL, gSQLOk;
new SQL_Host[64], SQL_User[64], SQL_Pass[128], SQL_DB[64];
new PlayerEuro[MAX_PLAYERS], PlayerEuroEx[MAX_PLAYERS], PlayerAccID[MAX_PLAYERS];
new PlayerBit[MAX_PLAYERS], PlayerMeme[MAX_PLAYERS], PlayerDonate[MAX_PLAYERS];
new PlayerUAH[MAX_PLAYERS], PlayerKZT[MAX_PLAYERS];
new PlayerPlaySec[MAX_PLAYERS], PlayerRandBuys[MAX_PLAYERS];
new PlayerFlyTimer[MAX_PLAYERS];
new KztExMode[MAX_PLAYERS];
new PlayerLastLogin[MAX_PLAYERS];
new bool:PlayerLoaded[MAX_PLAYERS];
new EuroGiveTarget[MAX_PLAYERS], EuroExMode[MAX_PLAYERS], EuroBuyMode[MAX_PLAYERS];
new BitGiveTarget[MAX_PLAYERS], BitExMode[MAX_PLAYERS];
new MemeGiveTarget[MAX_PLAYERS], MemeExMode[MAX_PLAYERS];
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
	if(gSQL && mysql_errno(gSQL) == 0) return 1;
	gSQL = mysql_connect(SQL_Host, SQL_User, SQL_Pass, SQL_DB);
	if(gSQL && mysql_errno(gSQL) == 0) return 1;
	gSQL = 0;
	return 0;
}

stock SaveEuro(playerid)
{
	if(!gSQLOk || !PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
	new q[360];
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` SET `evro`=%d,`evro_exchanged`=%d,`bitok`=%d,`memecoin`=%d,`meme_last`=%d,`uah`=%d,`kzt`=%d,`play_sec`=%d,`meme_rand`=%d WHERE `id`=%d LIMIT 1",
		PlayerEuro[playerid], PlayerEuroEx[playerid], PlayerBit[playerid],
		PlayerMeme[playerid], PlayerLastLogin[playerid],
		PlayerUAH[playerid], PlayerKZT[playerid], PlayerPlaySec[playerid], PlayerRandBuys[playerid],
		PlayerAccID[playerid]);
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
		"SELECT `id`, IFNULL(`evro`,0), IFNULL(`evro_exchanged`,0), IFNULL(`bitok`,0), IFNULL(`memecoin`,0), IFNULL(`meme_last`,0), IFNULL(`uah`,0), IFNULL(`kzt`,0), IFNULL(`play_sec`,0), IFNULL(`meme_rand`,0) FROM `accounts` WHERE `name`='%e' LIMIT 1",
		name);
	mysql_tquery(gSQL, q, "OnEuroLoad", "i", playerid);
	return 1;
}

forward OnEuroLoad(playerid);
public OnEuroLoad(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
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
	PlayerLoaded[playerid] = true;
	MemeOnLogin(playerid);
	printf("[Euro] загружен %d acc=%d евро=%d бит=%d мем=%d", playerid, PlayerAccID[playerid], PlayerEuro[playerid], PlayerBit[playerid], PlayerMeme[playerid]);
	return 1;
}

forward OnEuroLoadSimple(playerid);
public OnEuroLoadSimple(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
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

forward OnRateHTTP(index, response_code, data[]);
public OnRateHTTP(index, response_code, data[])
{
	#pragma unused index
	if(response_code != 200 || strlen(data) < 40) return 1;
	new p = strfind(data, "EUR", true); if(p == -1) return 1;
	new v = strfind(data, "<Value>", true, p); if(v == -1) return 1; v += 7;
	new buf[24], i;
	while(data[v] && data[v] != '<' && i < 20) { buf[i++] = (data[v] == ',') ? '.' : data[v]; v++; }
	buf[i] = 0;
	new Float:r = floatstr(buf);
	if(r > 20.0 && r < 250.0) gEuroRate = r;
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
		PlayerLastLogin[i] = gettime();
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
	ShowPlayerDialog(playerid, D_MEME_TOP, DIALOG_STYLE_MSGBOX, "{FF69B4}Топ Алабуга", body, "OK", "");
	return 1;
}


// ===== MEME: полёт =====
stock MemeBuyFly(playerid)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(PlayerMeme[playerid] < MEME_FLY_PRICE)
		return SendClientMessage(playerid, COLOR_ERR, "Нужно 10 мемкоинов"), 0;
	PlayerMeme[playerid] -= MEME_FLY_PRICE;
	SaveEuro(playerid);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	if(PlayerFlyTimer[playerid]) KillTimer(PlayerFlyTimer[playerid]);
	PlayerFlyTimer[playerid] = SetTimerEx("MemeFlyEnd", MEME_FLY_SECONDS * 1000, false, "i", playerid);
	new str[96];
	format(str, sizeof str, "{FF69B4}Полёт на %d сек. Списано %d мемкоинов.", MEME_FLY_SECONDS, MEME_FLY_PRICE);
	SendClientMessage(playerid, -1, str);
	return 1;
}

forward MemeFlyEnd(playerid);
public MemeFlyEnd(playerid)
{
	PlayerFlyTimer[playerid] = 0;
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

stock ShowUahMenu(playerid)
{
	if(!PlayerLoaded[playerid]) return 1;
	new body[400];
	format(body, sizeof body,
		"Гривна (UAH): %d\nНе обменивается\nКупить админку (%d)\nКупить лидерку семьи (%d)\nНазад",
		PlayerUAH[playerid], UAH_ADMIN_PRICE, UAH_LEADER_PRICE);
	ShowPlayerDialog(playerid, D_UAH_MENU, DIALOG_STYLE_LIST, "{0057B8}Гривна", body, "OK", "X");
	return 1;
}

stock ShowKztMenu(playerid)
{
	if(!PlayerLoaded[playerid]) return 1;
	new body[500];
	format(body, sizeof body,
		"Тенге (KZT): %d\nКомиссия обмена 70%%\nТенге -> евро (70%%)\nТенге -> бит (70%%)\nЕвро -> тенге (70%%)\nБит -> тенге (70%%)\nНазад",
		PlayerKZT[playerid]);
	ShowPlayerDialog(playerid, D_KZT_MENU, DIALOG_STYLE_LIST, "{00AFCA}Тенге", body, "OK", "X");
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
	if(!gSQLOk) return SendClientMessage(playerid, COLOR_ERR, "БД offline"), 1;
	if(!PlayerLoaded[playerid])
	{
		LoadEuro(playerid);
		SendClientMessage(playerid, COLOR_ERR, "Загрузка... напиши .euro ещё раз через 2 сек");
		return 1;
	}
	UpdateRate();
	new body[900];
	format(body, sizeof body,
		"Евро: %d | Бит: %d | %s: %d\n" \
		"Гривна: %d | Тенге: %d\n" \
		"Курс евро %.2f | BTC %.0f\n" \
		"Евро -> нал\n" \
		"Евро -> банк\n" \
		"Нал -> евро\n" \
		"Банк -> евро\n" \
		"Евро -> бит (20%%)\n" \
		"Передать евро\n" \
		"Скин\n" \
		"Акс\n" \
		"Машина\n" \
		"Семья\n" \
		"Топ евро\n" \
		"Меню битка\n" \
		"Меню мемкоина\n" \
		"Гривна\n" \
		"Тенге\n" \
		"Обновить",
		PlayerEuro[playerid], PlayerBit[playerid], gMemeName, PlayerMeme[playerid],
		PlayerUAH[playerid], PlayerKZT[playerid], gEuroRate, gBitRate);
	ShowPlayerDialog(playerid, D_EURO_MENU, DIALOG_STYLE_LIST, "{FFD700}Евро", body, "OK", "X");
	return 1;
}

stock ShowBitMenu(playerid)
{
	if(!gSQLOk || !PlayerLoaded[playerid]) { LoadEuro(playerid); return SendClientMessage(playerid, COLOR_ERR, "Загрузка..."), 1; }
	new body[600];
	format(body, sizeof body, "Биток: %d\nКурс BTC %.0f\nБит -> нал (5%%)\nБит -> банк (5%%)\nБит -> евро (5%%)\nПередать бит (20%%)\nТоп битка\nEuro\nMeme\nRefresh", PlayerBit[playerid], gBitRate);
	ShowPlayerDialog(playerid, D_BIT_MENU, DIALOG_STYLE_LIST, "{00BFFF}Биток", body, "OK", "X");
	return 1;
}

stock ShowMemeMenu(playerid)
{
	if(!gSQLOk || !PlayerLoaded[playerid]) { LoadEuro(playerid); return SendClientMessage(playerid, COLOR_ERR, "Загрузка..."), 1; }
	new body[800], status[16];
	if(MemeSeasonActive()) format(status, sizeof status, "активен");
	else format(status, sizeof status, "ОКОНЧЕН");
	format(body, sizeof body,
		"%s: %d (%s)\n" \
		"До %02d.%02d.%04d %02d:%02d | курс %.1f\n" \
		"Мем -> нал\n" \
		"Мем -> банк\n" \
		"Мем -> евро\n" \
		"Мем -> бит\n" \
		"Евро -> мем\n" \
		"Бит -> мем\n" \
		"Донат(БЦ) -> мем\n" \
		"Мем -> донат(БЦ)\n" \
		"Передать мем (50%%)\n" \
		"Полёт (10 мем)\n" \
		"Рандом скин/тачка/акс (%d)\n" \
		"Топ мемкоина\n" \
		"Гривна\n" \
		"Тенге\n" \
		"Евро | Биток\n" \
		"Обновить",
		gMemeName, PlayerMeme[playerid], status, gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi, gMemeRate, MemeRandPrice(playerid));
	ShowPlayerDialog(playerid, D_MEME_MENU, DIALOG_STYLE_LIST, "{FF69B4}Алабуга", body, "OK", "X");
	return 1;
}

stock Cmd(playerid, cmd[])
{
	if(!strcmp(cmd, "euro", true) || !strcmp(cmd, "eurobal", true)) return ShowMenu(playerid);
	if(!strcmp(cmd, "bit", true) || !strcmp(cmd, "bitok", true)) return ShowBitMenu(playerid);
	if(!strcmp(cmd, "meme", true) || !strcmp(cmd, "memecoin", true) || !strcmp(cmd, "mm", true)) return ShowMemeMenu(playerid);
	if(!strcmp(cmd, "uah", true) || !strcmp(cmd, "grivna", true)) return ShowUahMenu(playerid);
	if(!strcmp(cmd, "kzt", true) || !strcmp(cmd, "tenge", true)) return ShowKztMenu(playerid);
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

public OnFilterScriptInit()
{
	print("  [Euro+Bit+Meme] Алабуга загрузка");
	gSQLOk = 0; gSQL = 0; gMemeSeasonEnded = false;
	if(!LoadIni()) { print("[Euro] нет ini"); return 1; }
	if(!ConnectSQL()) { print("[Euro] MySQL ошибка"); return 1; }
	gSQLOk = 1;
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `evro` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `evro_exchanged` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `bitok` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `memecoin` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `meme_last` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `uah` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `kzt` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `play_sec` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `meme_rand` INT NOT NULL DEFAULT 0");
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
	PlayerUAH[playerid] = 0; PlayerKZT[playerid] = 0; PlayerPlaySec[playerid] = 0;
	PlayerRandBuys[playerid] = 0; PlayerFlyTimer[playerid] = 0; KztExMode[playerid] = 0;
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
	if(PlayerLoaded[playerid])
	{
		PlayerLastLogin[playerid] = gettime();
		SaveEuro(playerid);
	}
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
			case 0, 1: ShowMenu(playerid);
			case 2: { EuroExMode[playerid] = 0; ShowPlayerDialog(playerid, D_EURO_EX_AMT, DIALOG_STYLE_INPUT, "Евро->нал", "Сколько евро?", "OK", "X"); }
			case 3: { EuroExMode[playerid] = 1; ShowPlayerDialog(playerid, D_EURO_EX_AMT, DIALOG_STYLE_INPUT, "Евро->банк", "Сколько евро?", "OK", "X"); }
			case 4: { EuroBuyMode[playerid] = 0; ShowPlayerDialog(playerid, D_EURO_BUY_AMT, DIALOG_STYLE_INPUT, "Нал->евро", "Сколько руб?", "OK", "X"); }
			case 5: { EuroBuyMode[playerid] = 1; ShowPlayerDialog(playerid, D_EURO_BUY_AMT, DIALOG_STYLE_INPUT, "Банк->евро", "Сколько руб?", "OK", "X"); }
			case 6: ShowPlayerDialog(playerid, D_E2B_AMT, DIALOG_STYLE_INPUT, "Евро->бит", "Сколько евро?", "OK", "X");
			case 7: ShowPlayerDialog(playerid, D_EURO_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "ID:", "OK", "X");
			case 8: ShowPlayerDialog(playerid, D_EURO_SKIN, DIALOG_STYLE_INPUT, "Скин", "ID:", "OK", "X");
			case 9: ShowPlayerDialog(playerid, D_EURO_ACS, DIALOG_STYLE_INPUT, "Акс", "ID:", "OK", "X");
			case 10: ShowPlayerDialog(playerid, D_EURO_CAR, DIALOG_STYLE_INPUT, "Машина", "ID:", "OK", "X");
			case 11: StartFamilyBuy(playerid);
			case 12: ShowTop(playerid);
			case 13: ShowBitMenu(playerid);
			case 14: ShowMemeMenu(playerid);
			case 15: ShowUahMenu(playerid);
			case 16: ShowKztMenu(playerid);
			case 17: LoadEuro(playerid);
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
			case 9: LoadEuro(playerid);
		}
		return 1;
	}
	if(dialogid == D_MEME_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1, 2: ShowMemeMenu(playerid);
			case 3: { MemeExMode[playerid] = 0; ShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->нал", "Сколько?", "OK", "X"); }
			case 4: { MemeExMode[playerid] = 1; ShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->банк", "Сколько?", "OK", "X"); }
			case 5: { MemeExMode[playerid] = 2; ShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->евро", "Сколько?", "OK", "X"); }
			case 6: { MemeExMode[playerid] = 3; ShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->бит", "Сколько?", "OK", "X"); }
			case 7: ShowPlayerDialog(playerid, D_MEME_FROM_EUR, DIALOG_STYLE_INPUT, "Евро->мем", "Сколько евро?", "OK", "X");
			case 8: ShowPlayerDialog(playerid, D_MEME_FROM_BIT, DIALOG_STYLE_INPUT, "Бит->мем", "Сколько бит?", "OK", "X");
			case 9: ShowPlayerDialog(playerid, D_MEME_DONATE, DIALOG_STYLE_INPUT, "Донат->мем", "Сколько БЦ?", "OK", "X");
			case 10: { MemeExMode[playerid] = 4; ShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->донат", "Сколько?", "OK", "X"); }
			case 11: ShowPlayerDialog(playerid, D_MEME_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "ID:", "OK", "X");
			case 12: MemeBuyFly(playerid);
			case 13: MemeBuyRandom(playerid);
			case 14: ShowMemeTop(playerid);
			case 15: ShowUahMenu(playerid);
			case 16: ShowKztMenu(playerid);
			case 17: ShowMenu(playerid);
			case 18: LoadEuro(playerid);
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
		new tid = strval(inputtext);
		if(!IsPlayerConnected(tid) || tid == playerid) return SendClientMessage(playerid, COLOR_ERR, "Неверный ID"), 1;
		EuroGiveTarget[playerid] = tid;
		ShowPlayerDialog(playerid, D_EURO_GIVE_AMT, DIALOG_STYLE_INPUT, "Евро", "Сумма:", "OK", "X");
		return 1;
	}
	if(dialogid == D_EURO_GIVE_AMT)
	{
		if(!response) return 1;
		new amt = strval(inputtext), tid = EuroGiveTarget[playerid];
		if(amt <= 0 || !IsPlayerConnected(tid) || PlayerEuro[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Нельзя"), 1;
		PlayerEuro[playerid] -= amt; PlayerEuro[tid] += amt; SaveEuro(playerid); SaveEuro(tid);
		SendClientMessage(playerid, COLOR_EURO, "Отправлено"); SendClientMessage(tid, COLOR_EURO, "Вам пришли евро");
		return 1;
	}
	if(dialogid == D_BIT_GIVE)
	{
		if(!response) return 1;
		new tid = strval(inputtext);
		if(!IsPlayerConnected(tid) || tid == playerid) return SendClientMessage(playerid, COLOR_ERR, "Неверный ID"), 1;
		BitGiveTarget[playerid] = tid;
		ShowPlayerDialog(playerid, D_BIT_GIVE_AMT, DIALOG_STYLE_INPUT, "Бит", "Сумма:", "OK", "X");
		return 1;
	}
	if(dialogid == D_BIT_GIVE_AMT)
	{
		if(!response) return 1;
		new amt = strval(inputtext), tid = BitGiveTarget[playerid];
		if(amt <= 0 || !IsPlayerConnected(tid) || !PlayerLoaded[tid]) return SendClientMessage(playerid, COLOR_ERR, "Нельзя"), 1;
		new fee = (amt * BIT_TRANSFER_FEE_PCT) / 100; if(fee < 1 && amt >= 5) fee = 1;
		new receive = amt - fee;
		if(receive < 1 || PlayerBit[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало / комиссия"), 1;
		PlayerBit[playerid] -= amt; PlayerBit[tid] += receive; SaveEuro(playerid); SaveEuro(tid);
		new str[96]; format(str, sizeof str, "{00BFFF}-%d бит (комиссия %d), ему +%d", amt, fee, receive);
		SendClientMessage(playerid, -1, str); SendClientMessage(tid, COLOR_BIT, "Вам пришёл биток");
		return 1;
	}
	if(dialogid == D_MEME_GIVE)
	{
		if(!response) return 1;
		if(!MemeRequireActive(playerid)) return 1;
		new tid = strval(inputtext);
		if(!IsPlayerConnected(tid) || tid == playerid) return SendClientMessage(playerid, COLOR_ERR, "Неверный ID"), 1;
		MemeGiveTarget[playerid] = tid;
		ShowPlayerDialog(playerid, D_MEME_GIVE_AMT, DIALOG_STYLE_INPUT, "Мем 50%", "Сумма:", "OK", "X");
		return 1;
	}
	if(dialogid == D_MEME_GIVE_AMT)
	{
		if(!response) return 1;
		if(!MemeRequireActive(playerid)) return 1;
		new amt = strval(inputtext), tid = MemeGiveTarget[playerid];
		if(amt <= 0 || !IsPlayerConnected(tid) || !PlayerLoaded[tid]) return SendClientMessage(playerid, COLOR_ERR, "Нельзя"), 1;
		new fee = (amt * MEME_FEE_PCT) / 100; if(fee < 1 && amt >= 2) fee = 1;
		new receive = amt - fee;
		if(receive < 1 || PlayerMeme[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало / 50%"), 1;
		PlayerMeme[playerid] -= amt; PlayerMeme[tid] += receive; SaveEuro(playerid); SaveEuro(tid);
		new str[100]; format(str, sizeof str, "{FF69B4}-%d (комиссия 50%%=%d), ему +%d", amt, fee, receive);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{FF69B4}+%d %s", receive, gMemeName);
		SendClientMessage(tid, -1, str);
		return 1;
	}
	
	if(dialogid == D_UAH_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1: ShowUahMenu(playerid);
			case 2: UahBuyAdmin(playerid);
			case 3: UahBuyLeader(playerid);
			case 4: ShowMenu(playerid);
		}
		return 1;
	}
	if(dialogid == D_KZT_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1: ShowKztMenu(playerid);
			case 2: { KztExMode[playerid]=0; ShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Тенге->евро", "Сколько тенге?", "OK", "X"); }
			case 3: { KztExMode[playerid]=1; ShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Тенге->бит", "Сколько тенге?", "OK", "X"); }
			case 4: { KztExMode[playerid]=2; ShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Евро->тенге", "Сколько евро?", "OK", "X"); }
			case 5: { KztExMode[playerid]=3; ShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Бит->тенге", "Сколько бит?", "OK", "X"); }
			case 6: ShowMenu(playerid);
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

	if(dialogid == D_EURO_TOP || dialogid == D_BIT_TOP || dialogid == D_MEME_TOP) return 1;
	return 0;
}
