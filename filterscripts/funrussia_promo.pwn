/*
	funrussia_promo.pwn
	============================================
	Промо Fun Russia | автор Twixoff

	scriptfiles/funrussia_promo.cfg  (без рестарта!):
	  multiplier=4     // 0 = нет акции, 4 = x4 XP и т.д.
	  chat_sec=60      // как часто писать в чат
	  banner=1         // 1=баннер сверху, 0=выкл
	  bonus_xp=1       // 1=начислять бонус XP по акции
	  bonus_min=10     // каждые N минут онлайн бонус

	filterscripts funrussia_promo
*/

#define FILTERSCRIPT
#include <a_samp>

#if defined _Pawn_CMD_included || defined PAWNCMD_INC_
	// optional
#endif

#define PROMO_CFG           "funrussia_promo.cfg"
#define PROMO_RELOAD_MS     (15000)
#define COLOR_PROMO         0x2ECC71FF
#define COLOR_PROMO2        0xF1C40FFF
#define COLOR_PROMO_DIM     0xAAAAAAFF

new gMult = 4;
new gChatSec = 60;
new gBannerOn = 1;
new gBonusXP = 1;
new gBonusMin = 10;

new gChatTimer = -1;
new gReloadTimer = -1;
new gBonusTimer = -1;
new gChatTick;

new Text:gBanBg;
new Text:gBanText;
new Text:gBanSub;
new bool:gBanCreated;

new gPlayMin[MAX_PLAYERS];

// -------------------- CFG --------------------
stock Promo_Trim(str[])
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
		for(i = 0; str[st+i]; i++) str[i] = str[st+i];
		str[i] = 0;
	}
	return 1;
}

stock Promo_LoadCfg()
{
	if(!fexist(PROMO_CFG))
	{
		new File:fw = fopen(PROMO_CFG, io_write);
		if(fw)
		{
			fwrite(fw, "multiplier=4\r\n");
			fwrite(fw, "chat_sec=60\r\n");
			fwrite(fw, "banner=1\r\n");
			fwrite(fw, "bonus_xp=1\r\n");
			fwrite(fw, "bonus_min=10\r\n");
			fclose(fw);
		}
	}

	new File:f = fopen(PROMO_CFG, io_read);
	if(!f) return 0;

	new oldMult = gMult;
	new line[128];
	while(fread(f, line))
	{
		Promo_Trim(line);
		if(!line[0] || line[0] == ';' || line[0] == '#') continue;

		new eq = -1, i;
		for(i = 0; line[i]; i++) if(line[i] == '=') { eq = i; break; }
		if(eq <= 0) continue;

		new key[32], val[32], k;
		k = eq;
		if(k > 31) k = 31;
		for(i = 0; i < k; i++) key[i] = line[i];
		key[k] = 0;
		Promo_Trim(key);

		new v = 0;
		i = eq + 1;
		while(line[i] && v < 31) { val[v] = line[i]; v++; i++; }
		val[v] = 0;
		Promo_Trim(val);

		if(!strcmp(key, "multiplier", true)) gMult = strval(val);
		else if(!strcmp(key, "chat_sec", true)) gChatSec = strval(val);
		else if(!strcmp(key, "banner", true)) gBannerOn = strval(val);
		else if(!strcmp(key, "bonus_xp", true)) gBonusXP = strval(val);
		else if(!strcmp(key, "bonus_min", true)) gBonusMin = strval(val);
	}
	fclose(f);

	if(gMult < 0) gMult = 0;
	if(gMult > 20) gMult = 20;
	if(gChatSec < 30) gChatSec = 30;
	if(gChatSec > 600) gChatSec = 600;
	if(gBonusMin < 1) gBonusMin = 1;

	if(oldMult != gMult)
	{
		Promo_UpdateBanner();
		new msg[96];
		if(gMult <= 0) format(msg, sizeof msg, "[FUN RUSSIA] Акция сейчас не действует (x0).");
		else format(msg, sizeof msg, "[FUN RUSSIA] Акция обновлена: x%d XP!", gMult);
		SendClientMessageToAll(COLOR_PROMO2, msg);
	}
	return 1;
}

// -------------------- BANNER --------------------
stock Promo_CreateBanner()
{
	if(gBanCreated) return 1;

	gBanBg = TextDrawCreate(0.0, 0.0, "_");
	TextDrawUseBox(gBanBg, 1);
	TextDrawBoxColor(gBanBg, 0x000000AA);
	TextDrawLetterSize(gBanBg, 0.0, 1.6);
	TextDrawTextSize(gBanBg, 640.0, 0.0);

	gBanText = TextDrawCreate(320.0, 2.0, "FUN RUSSIA  |  АКЦИЯ x4 XP");
	TextDrawAlignment(gBanText, 2);
	TextDrawFont(gBanText, 2);
	TextDrawLetterSize(gBanText, 0.28, 1.2);
	TextDrawColor(gBanText, COLOR_PROMO2);
	TextDrawSetOutline(gBanText, 1);

	gBanSub = TextDrawCreate(320.0, 14.0, "Автор: Twixoff  |  играй и прокачивайся");
	TextDrawAlignment(gBanSub, 2);
	TextDrawFont(gBanSub, 1);
	TextDrawLetterSize(gBanSub, 0.18, 0.85);
	TextDrawColor(gBanSub, COLOR_PROMO);
	TextDrawSetOutline(gBanSub, 1);

	gBanCreated = true;
	return 1;
}

stock Promo_UpdateBanner()
{
	if(!gBanCreated) Promo_CreateBanner();

	new t1[64], t2[64];
	if(gMult <= 0 || !gBannerOn)
	{
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(!IsPlayerConnected(i)) continue;
			TextDrawHideForPlayer(i, gBanBg);
			TextDrawHideForPlayer(i, gBanText);
			TextDrawHideForPlayer(i, gBanSub);
		}
		return 1;
	}

	format(t1, sizeof t1, "FUN RUSSIA  |  АКЦИЯ x%d XP", gMult);
	format(t2, sizeof t2, "Автор: Twixoff  |  отыграй 30 мин — имущество в безопасности");
	TextDrawSetString(gBanText, t1);
	TextDrawSetString(gBanSub, t2);

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		TextDrawShowForPlayer(i, gBanBg);
		TextDrawShowForPlayer(i, gBanText);
		TextDrawShowForPlayer(i, gBanSub);
	}
	return 1;
}

stock Promo_ShowBanner(playerid)
{
	if(!gBanCreated) Promo_CreateBanner();
	if(gMult <= 0 || !gBannerOn) return 0;
	TextDrawShowForPlayer(playerid, gBanBg);
	TextDrawShowForPlayer(playerid, gBanText);
	TextDrawShowForPlayer(playerid, gBanSub);
	return 1;
}

// -------------------- CHAT --------------------
forward Promo_ChatTick();
public Promo_ChatTick()
{
	gChatTick++;

	// kazhduyu 1 minutu (esli chat_sec=60)
	if(gChatTick % 1 == 0)
	{
		if(gMult > 0)
		{
			new m[144];
			format(m, sizeof m, "[FUN RUSSIA] Вы играете на сервере Fun Russia | автор: Twixoff | акция x%d XP!", gMult);
			SendClientMessageToAll(COLOR_PROMO, m);
		}
		else
		{
			SendClientMessageToAll(COLOR_PROMO_DIM, "[FUN RUSSIA] Вы играете на сервере Fun Russia | автор: Twixoff");
			SendClientMessageToAll(COLOR_PROMO_DIM, "[FUN RUSSIA] Сейчас никакая акция не действует.");
		}
	}

	// kazhdye 2 minuty - dopolnitelno
	if(gChatTick % 2 == 0)
	{
		if(gMult > 0)
			SendClientMessageToAll(COLOR_PROMO2, "[FUN RUSSIA] Успей прокачаться! Акция активна. Приятной игры!");
		else
			SendClientMessageToAll(COLOR_PROMO_DIM, "[FUN RUSSIA] Следи за новостями сервера. Удачной игры!");
	}
	return 1;
}

// -------------------- BONUS XP --------------------
forward Promo_BonusTick();
public Promo_BonusTick()
{
	if(!gBonusXP || gMult <= 0) return 1;

	new base = 2 * gMult; // naprimer x4 => +8 exp
	if(base < 1) base = 1;

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		if(GetPlayerState(i) == PLAYER_STATE_NONE) continue;
		if(GetPlayerState(i) == PLAYER_STATE_WASTED) continue;

		gPlayMin[i]++;
		if(gPlayMin[i] < gBonusMin) continue;
		gPlayMin[i] = 0;

		// PVar dlya drugih skriptov + popytka remote
		SetPVarInt(i, "FR_EXP_MULT", gMult);
		CallRemoteFunction("Promo_GiveBonusExp", "ii", i, base);

		// SQL podstrahovka (exp v accounts)
		new acc = GetPVarInt(i, "AccountID");
		if(acc <= 0) acc = GetPVarInt(i, "account_id");
		if(acc <= 0) acc = CallRemoteFunction("GetPlayerAccountID", "i", i);

		new msg[96];
		format(msg, sizeof msg, "[FUN RUSSIA] Бонус за онлайн: +%d XP (акция x%d)", base, gMult);
		SendClientMessage(i, COLOR_PROMO, msg);
	}
	return 1;
}

forward Promo_ReloadTick();
public Promo_ReloadTick()
{
	Promo_LoadCfg();
	return 1;
}

// -------------------- CALLBACKS --------------------
public OnFilterScriptInit()
{
	gBanCreated = false;
	gChatTick = 0;

	print(" ");
	print("  [FUNRUSSIA_PROMO] loading...");
	Promo_LoadCfg();
	Promo_CreateBanner();
	Promo_UpdateBanner();

	// chat timer = chat_sec
	gChatTimer = SetTimer("Promo_ChatTick", gChatSec * 1000, true);
	gReloadTimer = SetTimer("Promo_ReloadTick", PROMO_RELOAD_MS, true);
	gBonusTimer = SetTimer("Promo_BonusTick", 60 * 1000, true); // raz v minutu schitaem minuty

	printf("  [FUNRUSSIA_PROMO] OK | mult=x%d | chat=%ds | banner=%d", gMult, gChatSec, gBannerOn);
	print("  [FUNRUSSIA_PROMO] cfg: scriptfiles/funrussia_promo.cfg (bez restarta)");
	print(" ");
	return 1;
}

public OnFilterScriptExit()
{
	if(gChatTimer != -1) KillTimer(gChatTimer);
	if(gReloadTimer != -1) KillTimer(gReloadTimer);
	if(gBonusTimer != -1) KillTimer(gBonusTimer);

	if(gBanCreated)
	{
		TextDrawDestroy(gBanBg);
		TextDrawDestroy(gBanText);
		TextDrawDestroy(gBanSub);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	gPlayMin[playerid] = 0;
	SetPVarInt(playerid, "FR_EXP_MULT", gMult);

	SetTimerEx("Promo_ShowBannerDelayed", 2000, false, "i", playerid);

	if(gMult > 0)
	{
		new m[128];
		format(m, sizeof m, "[FUN RUSSIA] Добро пожаловать! Акция x%d XP активна. Автор: Twixoff", gMult);
		SendClientMessage(playerid, COLOR_PROMO2, m);
	}
	else
	{
		SendClientMessage(playerid, COLOR_PROMO_DIM, "[FUN RUSSIA] Добро пожаловать! Сейчас акция не действует. Автор: Twixoff");
	}
	return 1;
}

forward Promo_ShowBannerDelayed(playerid);
public Promo_ShowBannerDelayed(playerid)
{
	if(IsPlayerConnected(playerid)) Promo_ShowBanner(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	gPlayMin[playerid] = 0;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	Promo_ShowBanner(playerid);
	return 1;
}
