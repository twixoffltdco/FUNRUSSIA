/*
	host_keepalive.pwn
	============================================
	Chtoby host (HostGTA i t.p.) NE gasil server pri 0 online.

	1) OnSendPlayerCount - dlya query / brauzera (esli est FakeOnline plugin
	   ili server vyzyvaet etot public - kak v starom fakeonline)
	2) NPC-boty - REALNYE podkljucheniya, host vidit online > 0

	Cfg: scriptfiles/host_keepalive.ini
	  Enabled=1
	  MinOnline=5
	  FakeOnline=15
	  RandomRange=3
	  UseNPC=1
	  NPCCount=2

	BEZ komand. Bez blokirovok.
	filterscripts host_keepalive
*/

#define FILTERSCRIPT
#include <a_samp>

#define HK_CFG          "host_keepalive.ini"
#define HK_NPC_PREFIX   "FR_Keep_"
#define HK_MAX_NPC      8

new gHK_Enabled = 1;
new gHK_MinOnline = 3;
new gHK_FakeOnline = 12;
new gHK_RandomRange = 3;
new gHK_UseNPC = 1;
new gHK_NPCCount = 2;

new gHK_NPC_ID[HK_MAX_NPC];
new gHK_NPC_Name[HK_MAX_NPC][24];
new gHK_Spawned = 0;
new gHK_Timer = -1;

stock HK_Trim(str[])
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

stock HK_LoadCfg()
{
	if(!fexist(HK_CFG))
	{
		new File:fw = fopen(HK_CFG, io_write);
		if(fw)
		{
			fwrite(fw, "Enabled=1\r\n");
			fwrite(fw, "MinOnline=3\r\n");
			fwrite(fw, "FakeOnline=15\r\n");
			fwrite(fw, "RandomRange=3\r\n");
			fwrite(fw, "UseNPC=1\r\n");
			fwrite(fw, "NPCCount=2\r\n");
			fclose(fw);
		}
	}

	new File:f = fopen(HK_CFG, io_read);
	if(!f) return 0;

	new line[128];
	while(fread(f, line))
	{
		HK_Trim(line);
		if(!line[0] || line[0] == ';' || line[0] == '#') continue;
		new eq = -1, i;
		for(i = 0; line[i]; i++) if(line[i] == '=') { eq = i; break; }
		if(eq <= 0) continue;
		new key[32], val[32], k = eq;
		if(k > 31) k = 31;
		for(i = 0; i < k; i++) key[i] = line[i];
		key[k] = 0; HK_Trim(key);
		new v = 0; i = eq + 1;
		while(line[i] && v < 31) { val[v] = line[i]; v++; i++; }
		val[v] = 0; HK_Trim(val);

		if(!strcmp(key, "Enabled", true)) gHK_Enabled = strval(val);
		else if(!strcmp(key, "MinOnline", true)) gHK_MinOnline = strval(val);
		else if(!strcmp(key, "FakeOnline", true)) gHK_FakeOnline = strval(val);
		else if(!strcmp(key, "RandomRange", true)) gHK_RandomRange = strval(val);
		else if(!strcmp(key, "UseNPC", true)) gHK_UseNPC = strval(val);
		else if(!strcmp(key, "NPCCount", true)) gHK_NPCCount = strval(val);
	}
	fclose(f);

	if(gHK_MinOnline < 1) gHK_MinOnline = 1;
	if(gHK_FakeOnline < gHK_MinOnline) gHK_FakeOnline = gHK_MinOnline;
	if(gHK_NPCCount < 0) gHK_NPCCount = 0;
	if(gHK_NPCCount > HK_MAX_NPC) gHK_NPCCount = HK_MAX_NPC;
	return 1;
}

stock HK_CountRealPlayers()
{
	new c, i;
	for(i = 0; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		if(IsPlayerNPC(i)) continue;
		c++;
	}
	return c;
}

// Query / server browser (kak staryj FakeOnline plugin callback)
forward OnSendPlayerCount(count);
public OnSendPlayerCount(count)
{
	#pragma unused count
	if(!gHK_Enabled) return count;

	new realp = HK_CountRealPlayers();
	new show = gHK_FakeOnline;
	if(gHK_RandomRange > 0)
		show += random(gHK_RandomRange * 2 + 1) - gHK_RandomRange;

	// nikogda ne otdavat 0 esli vkljucheno
	if(show < gHK_MinOnline) show = gHK_MinOnline;
	// esli realnyh bolshe - pokazyvaem realnyh (ili nemnogo bolshe)
	if(realp > show) show = realp + random(3);

	return show;
}

// NPC - realnye sloty dlya host-monitoringa
stock HK_ConnectNPCs()
{
	if(!gHK_UseNPC || !gHK_Enabled) return 0;

	new i, name[24];
	for(i = 0; i < gHK_NPCCount; i++)
	{
		format(name, sizeof name, "%s%d", HK_NPC_PREFIX, i + 1);
		format(gHK_NPC_Name[i], 24, "%s", name);
		// scriptname - ljuboy, server sozdaet NPC-slot
		ConnectNPC(name, "npctest");
	}
	printf("[HOST_KEEPALIVE] ConnectNPC x%d", gHK_NPCCount);
	return 1;
}

stock HK_IsOurNPC(playerid)
{
	if(!IsPlayerNPC(playerid)) return 0;
	new n[24];
	GetPlayerName(playerid, n, sizeof n);
	new i;
	for(i = 0; i < gHK_NPCCount; i++)
	{
		if(gHK_NPC_Name[i][0] && !strcmp(n, gHK_NPC_Name[i], true)) return 1;
	}
	// prefix check
	if(strfind(n, HK_NPC_PREFIX, true) == 0) return 1;
	return 0;
}

forward HK_Tick();
public HK_Tick()
{
	// perezagruzka cfg bez restarta
	HK_LoadCfg();

	// esli NPC otvalilis - podkljuchit snova
	if(gHK_UseNPC && gHK_Enabled)
	{
		new alive, i;
		for(i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i) && IsPlayerNPC(i) && HK_IsOurNPC(i)) alive++;
		}
		if(alive < gHK_NPCCount)
		{
			printf("[HOST_KEEPALIVE] NPC alive=%d need=%d -> reconnect", alive, gHK_NPCCount);
			HK_ConnectNPCs();
		}
	}
	return 1;
}

public OnFilterScriptInit()
{
	new i;
	for(i = 0; i < HK_MAX_NPC; i++)
	{
		gHK_NPC_ID[i] = -1;
		gHK_NPC_Name[i][0] = 0;
	}

	HK_LoadCfg();
	print(" ");
	print("  [HOST_KEEPALIVE] loading...");
	printf("  Enabled=%d FakeOnline=%d Min=%d NPC=%d", gHK_Enabled, gHK_FakeOnline, gHK_MinOnline, gHK_NPCCount);

	// zaderzhka chtoby server uspel startovat
	SetTimer("HK_DelayedStart", 5000, false);
	gHK_Timer = SetTimer("HK_Tick", 120000, true); // cfg + check kazhdye 2 min

	print("  [HOST_KEEPALIVE] OK | host ne uvidit 0 online");
	print(" ");
	return 1;
}

forward HK_DelayedStart();
public HK_DelayedStart()
{
	if(gHK_Enabled && gHK_UseNPC) HK_ConnectNPCs();
	return 1;
}

public OnFilterScriptExit()
{
	if(gHK_Timer != -1) KillTimer(gHK_Timer);
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid) && HK_IsOurNPC(playerid))
	{
		// spawn v void - ne meshayut
		SetTimerEx("HK_SpawnNPC", 1000, false, "i", playerid);
	}
	return 1;
}

forward HK_SpawnNPC(playerid);
public HK_SpawnNPC(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(!IsPlayerNPC(playerid)) return 0;

	SetSpawnInfo(playerid, 0, 0, 0.0, 0.0, 3.0, 0.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	SetPlayerVirtualWorld(playerid, 7777);
	SetPlayerInterior(playerid, 0);
	TogglePlayerControllable(playerid, 0);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	#pragma unused classid
	if(IsPlayerNPC(playerid))
	{
		SpawnPlayer(playerid);
		return 1;
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	#pragma unused killerid, reason
	if(IsPlayerNPC(playerid))
	{
		SpawnPlayer(playerid);
		return 1;
	}
	return 1;
}
