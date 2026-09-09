/*
 *  FakeLifeBR v3
 *  - City bots (walk / drive / chat)
 *  - SBP: "Sluzhba bezopasnosti po borbe s botami"
 *    Trigger: player writes bot/npc/fake in chat
 *    -> message, black car arrives, put player in, drive away, interrogate, optional task
 *
 *  Need: FCNPC plugin
 *  Download: https://github.com/ziggi/FCNPC/releases
 *  server.cfg:
 *    plugins FCNPC
 *    maxnpc 40
 *    filterscripts FakeLifeBR
 */

#include <a_samp>
#include <FCNPC>

#define FL_MAX_BOTS       (20)
#define FL_MAX_SBP        (4)     // security agents
#define FL_TICK_MS        (2000)
#define FL_CHAT_CHANCE    (4)
#define FL_BOOT_DELAY     (8000)
#define FL_SBP_COOLDOWN   (180)   // sec between SBP events per player

// ---------- city life ----------
new g_Bot[FL_MAX_BOTS];
new g_BotVeh[FL_MAX_BOTS];
new g_BotWP[FL_MAX_BOTS];
new bool:g_Run;
new g_Timer;

#define FL_WP 24
new Float:g_WP[FL_WP][3] = {
	{1742.8,-1862.5,13.6},{1715.2,-1880.1,13.6},{1685.4,-1850.3,13.5},
	{1352.2,-1755.4,13.4},{1284.5,-1500.2,13.6},{1481.0,-1740.0,13.6},
	{1529.0,-1670.0,13.5},{1805.0,-1600.0,13.5},{1920.0,-1760.0,13.5},
	{1100.0,-920.0,43.0},{750.0,-1280.0,13.6},{2220.0,-1350.0,23.9},
	{2450.0,-1680.0,13.5},{2495.0,-1666.0,13.3},{1750.0,-1900.0,13.6},
	{1400.0,-1850.0,13.6},{1000.0,-1500.0,13.6},{800.0,-1600.0,13.5},
	{1680.0,-2280.0,13.6},{1550.0,-2320.0,13.6},{1450.0,-2250.0,13.6},
	{1224.0,-1410.0,13.2},{1570.0,-1330.0,16.5},{2300.0,-1650.0,14.5}
};

new const g_Names[][] = {
	"Ivan_Petrov","Alexey_Smirnov","Dmitry_Ivanov","Sergey_Kuznetsov","Andrey_Popov",
	"Maxim_Sokolov","Nikita_Lebedev","Artem_Kozlov","Pavel_Novikov","Roman_Morozov",
	"Kirill_Volkov","Egor_Alekseev","Denis_Egorov","Anton_Pavlov","Timur_Stepanov",
	"Anna_Petrova","Maria_Ivanova","Elena_Smirnova","Olga_Kuznetsova","Daria_Lebedeva",
	"Alina_Kozlova","Polina_Novikova","Vadim_Fedorov","Igor_Borisov"
};

new const g_Skins[] = {
	1,2,7,12,15,17,19,21,22,23,24,25,28,29,30,36,37,46,47,48,49,50,
	57,58,59,60,67,72,98,100,101,102,103,104,105,106,107,108,109,110,
	111,112,113,114,115,116,120,121,122,123,124,125,126,127,142,147,156,170
};

new const g_Cars[] = {
	400,401,404,405,410,418,419,421,422,426,445,458,466,467,474,479,
	482,491,496,507,516,518,526,529,540,546,547,550,566,579,580,585,462,468
};
new const g_Buses[] = { 431, 437 };

new const g_Chat[][] = {
	"kuda vse?","poehali","privet","skuchno","na rabotu",
	"gde bank","nado deneg","v centr","ya na avtobus","tiho segodnya"
};
new const g_Reply[][] = { "aga","ok","ponyal","da","norm","ha","seychas","ya tut" };

// ---------- SBP (anti-bot security) ----------
enum {
	SBP_NONE = 0,
	SBP_DISPATCH,
	SBP_ARRIVE,
	SBP_PICKUP,
	SBP_DRIVE,
	SBP_TALK,
	SBP_TASK,
	SBP_DONE
}

new g_SBP_Npc[FL_MAX_SBP];
new g_SBP_Veh;
new g_SBP_Target;
new g_SBP_State;
new g_SBP_Timer;
new g_SBP_Step;
new g_SBP_Cooldown[MAX_PLAYERS];
new g_SBP_Task[MAX_PLAYERS]; // 0 none, 1 active
new Float:g_SBP_Drop[3];

// forest / remote drop points
new Float:g_DropPts[][3] = {
	{2350.0, -650.0, 128.0},
	{2100.0, -100.0, 2.5},
	{800.0, -1800.0, 12.5},
	{2500.0, -2000.0, 13.5},
	{1100.0, -2100.0, 69.0},
	{400.0, -1400.0, 23.0}
};

new const g_SBP_Names[][] = {
	"SBP_Agent_01","SBP_Agent_02","SBP_Agent_03","SBP_Agent_04"
};

new const g_SBP_Lines[][] = {
	"[SBP] Chto ty zdes' ustroil?",
	"[SBP] Zachem nazyvaesh vseh botami?",
	"[SBP] Dumaesh, my ne vidim?",
	"[SBP] Ty chelovek ili net? Otvechai.",
	"[SBP] Hvatit loftit' onlayn. My vsyo znaem.",
	"[SBP] Seyeduschemu razu bez preduprezhdeniya.",
	"[SBP] Vypolni zadanie — i my otstanem."
};

// ===================== city bots =====================
stock FL_Name(dest[], len = sizeof dest)
{
	format(dest, len, "%s", g_Names[random(sizeof g_Names)]);
	if(random(100) < 30)
	{
		new t[24];
		format(t, sizeof t, "%s%d", dest, 10+random(89));
		format(dest, len, "%s", t);
	}
}

stock FL_ClearBot(i)
{
	if(!(0 <= i < FL_MAX_BOTS)) return;
	if(g_Bot[i] != INVALID_PLAYER_ID && FCNPC_IsValid(g_Bot[i]))
	{
		if(g_BotVeh[i] != INVALID_VEHICLE_ID) FCNPC_RemoveFromVehicle(g_Bot[i]);
		FCNPC_Destroy(g_Bot[i]);
	}
	g_Bot[i] = INVALID_PLAYER_ID;
	if(g_BotVeh[i] != INVALID_VEHICLE_ID)
	{
		if(GetVehicleModel(g_BotVeh[i]) > 0) DestroyVehicle(g_BotVeh[i]);
		g_BotVeh[i] = INVALID_VEHICLE_ID;
	}
}

stock FL_Go(i, bool:drive)
{
	new npcid = g_Bot[i];
	if(npcid == INVALID_PLAYER_ID || !FCNPC_IsValid(npcid)) return;
	new n = random(FL_WP);
	if(n == g_BotWP[i]) n = (n + 1) % FL_WP;
	g_BotWP[i] = n;
	if(drive && g_BotVeh[i] != INVALID_VEHICLE_ID)
		FCNPC_GoTo(npcid, g_WP[n][0], g_WP[n][1], g_WP[n][2], FCNPC_MOVE_TYPE_DRIVE, 1.1, true);
	else
		FCNPC_GoTo(npcid, g_WP[n][0], g_WP[n][1], g_WP[n][2], FCNPC_MOVE_TYPE_WALK, 0.85, true);
}

stock FL_PutCar(i, bool:bus)
{
	new npcid = g_Bot[i];
	if(npcid == INVALID_PLAYER_ID || !FCNPC_IsValid(npcid)) return 0;
	new Float:x,y,z,a;
	FCNPC_GetPosition(npcid, x,y,z);
	FCNPC_GetAngle(npcid, a);
	new model = bus ? g_Buses[random(sizeof g_Buses)] : g_Cars[random(sizeof g_Cars)];
	new vid = CreateVehicle(model, x+3.0, y, z+0.3, a, random(100), random(100), 180);
	if(vid == INVALID_VEHICLE_ID) return 0;
	g_BotVeh[i] = vid;
	FCNPC_PutInVehicle(npcid, vid, 0);
	FL_Go(i, true);
	return 1;
}

stock FL_SpawnBot(i)
{
	FL_ClearBot(i);
	new name[24];
	FL_Name(name);
	new npcid = FCNPC_Create(name);
	if(npcid == INVALID_PLAYER_ID) return 0;
	new wp = random(FL_WP);
	FCNPC_Spawn(npcid, g_Skins[random(sizeof g_Skins)], g_WP[wp][0], g_WP[wp][1], g_WP[wp][2]+0.4);
	FCNPC_SetAngle(npcid, float(random(360)));
	FCNPC_SetHealth(npcid, 100.0);
	FCNPC_SetInvulnerable(npcid, true);
	g_Bot[i] = npcid;
	g_BotVeh[i] = INVALID_VEHICLE_ID;
	g_BotWP[i] = wp;
	new r = random(100);
	if(r < 12) FL_PutCar(i, true);
	else if(r < 45) FL_PutCar(i, false);
	else FL_Go(i, false);
	return 1;
}

stock FL_Say(i, const t[])
{
	new npcid = g_Bot[i];
	if(npcid == INVALID_PLAYER_ID || !FCNPC_IsValid(npcid)) return;
	new n[24], m[144];
	GetPlayerName(npcid, n, sizeof n);
	format(m, sizeof m, "%s: %s", n, t);
	SendClientMessageToAll(0xFFEEEEEE, m);
}

// ===================== SBP =====================
stock SBP_Clear()
{
	if(g_SBP_Timer) { KillTimer(g_SBP_Timer); g_SBP_Timer = 0; }
	for(new i; i < FL_MAX_SBP; i++)
	{
		if(g_SBP_Npc[i] != INVALID_PLAYER_ID && FCNPC_IsValid(g_SBP_Npc[i]))
			FCNPC_Destroy(g_SBP_Npc[i]);
		g_SBP_Npc[i] = INVALID_PLAYER_ID;
	}
	if(g_SBP_Veh != INVALID_VEHICLE_ID)
	{
		if(GetVehicleModel(g_SBP_Veh) > 0) DestroyVehicle(g_SBP_Veh);
		g_SBP_Veh = INVALID_VEHICLE_ID;
	}
	g_SBP_Target = INVALID_PLAYER_ID;
	g_SBP_State = SBP_NONE;
	g_SBP_Step = 0;
}

stock bool:SBP_IsBusy()
{
	return g_SBP_State != SBP_NONE;
}

stock SBP_Broadcast(const msg[])
{
	SendClientMessageToAll(0xFF3333FF, msg);
}

stock SBP_Msg(playerid, const msg[])
{
	if(IsPlayerConnected(playerid))
		SendClientMessage(playerid, 0xFF5555FF, msg);
}

stock SBP_Start(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(SBP_IsBusy()) return 0;
	if(g_SBP_Cooldown[playerid] > gettime()) return 0;

	SBP_Clear();
	g_SBP_Target = playerid;
	g_SBP_State = SBP_DISPATCH;
	g_SBP_Step = 0;
	g_SBP_Cooldown[playerid] = gettime() + FL_SBP_COOLDOWN;

	new name[24];
	GetPlayerName(playerid, name, sizeof name);

	new line[144];
	format(line, sizeof line, "[SBP] Vnimanie: za igrokom %s vyehala Sluzhba bezopasnosti po borbe s botami.", name);
	SBP_Broadcast(line);
	SBP_Msg(playerid, "[SBP] Za vami vyehala sluzhba. Ne pytaites' sbezhat'.");

	// spawn black car near player + agents
	new Float:x,y,z,a;
	GetPlayerPos(playerid, x,y,z);
	GetPlayerFacingAngle(playerid, a);

	// spawn 25m behind
	x += floatsin(-a, degrees) * 28.0;
	y += floatcos(-a, degrees) * 28.0;

	g_SBP_Veh = CreateVehicle(405, x, y, z + 0.5, a, 0, 0, 120); // black Sentinel
	if(g_SBP_Veh == INVALID_VEHICLE_ID)
	{
		SBP_Clear();
		return 0;
	}

	for(new i; i < FL_MAX_SBP; i++)
	{
		new npcid = FCNPC_Create(g_SBP_Names[i]);
		if(npcid == INVALID_PLAYER_ID) continue;
		FCNPC_Spawn(npcid, 163 + (i % 3), x + float(i)*0.8, y, z + 0.5); // suit-ish skins
		FCNPC_SetInvulnerable(npcid, true);
		FCNPC_SetHealth(npcid, 100.0);
		g_SBP_Npc[i] = npcid;
		if(i == 0)
			FCNPC_PutInVehicle(npcid, g_SBP_Veh, 0);
		else if(i < 4)
			FCNPC_PutInVehicle(npcid, g_SBP_Veh, i);
	}

	g_SBP_State = SBP_ARRIVE;
	// drive to player
	GetPlayerPos(playerid, x,y,z);
	if(g_SBP_Npc[0] != INVALID_PLAYER_ID && FCNPC_IsValid(g_SBP_Npc[0]))
		FCNPC_GoTo(g_SBP_Npc[0], x, y, z, FCNPC_MOVE_TYPE_DRIVE, 1.3, true);

	g_SBP_Timer = SetTimer("SBP_Think", 1500, true);
	return 1;
}

forward SBP_Think();
public SBP_Think()
{
	if(g_SBP_State == SBP_NONE) return 0;
	new pid = g_SBP_Target;
	if(!IsPlayerConnected(pid))
	{
		SBP_Clear();
		return 0;
	}

	new Float:px,py,pz;
	GetPlayerPos(pid, px,py,pz);

	switch(g_SBP_State)
	{
		case SBP_ARRIVE:
		{
			g_SBP_Step++;
			if(g_SBP_Npc[0] != INVALID_PLAYER_ID && FCNPC_IsValid(g_SBP_Npc[0]))
			{
				new Float:x,y,z;
				FCNPC_GetPosition(g_SBP_Npc[0], x,y,z);
				if(((x-px)*(x-px)+(y-py)*(y-py)) < 12.0*12.0 || g_SBP_Step > 20)
				{
					g_SBP_State = SBP_PICKUP;
					g_SBP_Step = 0;
					SBP_Msg(pid, "[SBP] Ostanovites'. Vy zaderzhany.");
					SBP_Broadcast("[SBP] Cel' zaderzhana. Posadka v transport.");
				}
				else
					FCNPC_GoTo(g_SBP_Npc[0], px, py, pz, FCNPC_MOVE_TYPE_DRIVE, 1.3, true);
			}
		}
		case SBP_PICKUP:
		{
			g_SBP_Step++;
			// force into vehicle seat 3 (rear)
			if(g_SBP_Veh != INVALID_VEHICLE_ID)
			{
				PutPlayerInVehicle(pid, g_SBP_Veh, 3);
				TogglePlayerControllable(pid, 0);
			}
			if(g_SBP_Step >= 2)
			{
				g_SBP_State = SBP_DRIVE;
				g_SBP_Step = 0;
				new d = random(sizeof g_DropPts);
				g_SBP_Drop[0] = g_DropPts[d][0];
				g_SBP_Drop[1] = g_DropPts[d][1];
				g_SBP_Drop[2] = g_DropPts[d][2];
				if(g_SBP_Npc[0] != INVALID_PLAYER_ID && FCNPC_IsValid(g_SBP_Npc[0]))
					FCNPC_GoTo(g_SBP_Npc[0], g_SBP_Drop[0], g_SBP_Drop[1], g_SBP_Drop[2], FCNPC_MOVE_TYPE_DRIVE, 1.25, true);
				SBP_Msg(pid, "[SBP] Poehali. Budet razgovor.");
				SBP_Broadcast("[SBP] Transport s zaderzhannym ubyl s mesta.");
			}
		}
		case SBP_DRIVE:
		{
			g_SBP_Step++;
			if(g_SBP_Veh != INVALID_VEHICLE_ID && GetPlayerVehicleID(pid) != g_SBP_Veh)
				PutPlayerInVehicle(pid, g_SBP_Veh, 3);

			new Float:x,y,z;
			if(g_SBP_Npc[0] != INVALID_PLAYER_ID && FCNPC_IsValid(g_SBP_Npc[0]))
				FCNPC_GetPosition(g_SBP_Npc[0], x,y,z);
			else
				GetVehiclePos(g_SBP_Veh, x,y,z);

			if(((x-g_SBP_Drop[0])*(x-g_SBP_Drop[0])+(y-g_SBP_Drop[1])*(y-g_SBP_Drop[1])) < 20.0*20.0 || g_SBP_Step > 45)
			{
				g_SBP_State = SBP_TALK;
				g_SBP_Step = 0;
				// remove from car, freeze for talk
				RemovePlayerFromVehicle(pid);
				SetPlayerPos(pid, g_SBP_Drop[0] + 2.0, g_SBP_Drop[1], g_SBP_Drop[2]);
				TogglePlayerControllable(pid, 0);
				SBP_Msg(pid, "[SBP] Vykhodi. Pogovorim.");
			}
			else if(g_SBP_Npc[0] != INVALID_PLAYER_ID && FCNPC_IsValid(g_SBP_Npc[0]) && !FCNPC_IsMoving(g_SBP_Npc[0]))
				FCNPC_GoTo(g_SBP_Npc[0], g_SBP_Drop[0], g_SBP_Drop[1], g_SBP_Drop[2], FCNPC_MOVE_TYPE_DRIVE, 1.25, true);
		}
		case SBP_TALK:
		{
			g_SBP_Step++;
			if(g_SBP_Step == 1)
				SBP_Msg(pid, g_SBP_Lines[0]);
			else if(g_SBP_Step == 3)
				SBP_Msg(pid, g_SBP_Lines[1]);
			else if(g_SBP_Step == 5)
				SBP_Msg(pid, g_SBP_Lines[2]);
			else if(g_SBP_Step == 7)
				SBP_Msg(pid, g_SBP_Lines[3]);
			else if(g_SBP_Step == 9)
				SBP_Msg(pid, g_SBP_Lines[4]);
			else if(g_SBP_Step == 11)
			{
				SBP_Msg(pid, g_SBP_Lines[6]);
				g_SBP_State = SBP_TASK;
				g_SBP_Step = 0;
			}
		}
		case SBP_TASK:
		{
			// give simple task: stand still 30s / or just release with warning
			g_SBP_Task[pid] = 1;
			SBP_Msg(pid, "[SBP] Zadanie: ne pishi pro botov 10 minut. Inache vernyomsya.");
			SBP_Broadcast("[SBP] Zaderzhanie zaversheno. Subekt otpuschen s preduprezhdeniem.");
			TogglePlayerControllable(pid, 1);
			SetTimerEx("SBP_EndTask", 10 * 60 * 1000, false, "i", pid);
			g_SBP_State = SBP_DONE;
			g_SBP_Step = 0;
		}
		case SBP_DONE:
		{
			g_SBP_Step++;
			if(g_SBP_Step >= 3)
				SBP_Clear();
		}
	}
	return 1;
}

forward SBP_EndTask(playerid);
public SBP_EndTask(playerid)
{
	if(IsPlayerConnected(playerid) && g_SBP_Task[playerid])
	{
		g_SBP_Task[playerid] = 0;
		SBP_Msg(playerid, "[SBP] Zadanie zachteno. Poka ty chist.");
	}
	return 1;
}

stock bool:SBP_TextIsTrigger(const text[])
{
	// keywords: bot, npc, fake, robot, humanoid, feyk, boty
	if(strfind(text, "bot", true) != -1) return true;
	if(strfind(text, "npc", true) != -1) return true;
	if(strfind(text, "fake", true) != -1) return true;
	if(strfind(text, "robot", true) != -1) return true;
	if(strfind(text, "feyk", true) != -1) return true;
	if(strfind(text, "feik", true) != -1) return true;
	if(strfind(text, "humanoid", true) != -1) return true;
	if(strfind(text, "chelovek ili", true) != -1) return true;
	return false;
}

// ===================== main loop =====================
forward FL_Boot();
public FL_Boot()
{
	new n;
	for(new i; i < FL_MAX_BOTS; i++)
		if(FL_SpawnBot(i)) n++;
	g_Run = true;
	g_Timer = SetTimer("FL_Tick", FL_TICK_MS, true);
	printf("[FakeLife] city bots: %d | SBP system ready", n);
	return 1;
}

forward FL_Tick();
public FL_Tick()
{
	if(!g_Run) return 0;
	for(new i; i < FL_MAX_BOTS; i++)
	{
		if(g_Bot[i] == INVALID_PLAYER_ID) continue;
		if(!FCNPC_IsValid(g_Bot[i])) { FL_ClearBot(i); continue; }

		if(random(100) < FL_CHAT_CHANCE)
			FL_Say(i, g_Chat[random(sizeof g_Chat)]);

		if(!FCNPC_IsMoving(g_Bot[i]))
		{
			if(g_BotVeh[i] != INVALID_VEHICLE_ID)
			{
				if(random(100) < 25)
				{
					FCNPC_RemoveFromVehicle(g_Bot[i]);
					if(GetVehicleModel(g_BotVeh[i]) > 0) DestroyVehicle(g_BotVeh[i]);
					g_BotVeh[i] = INVALID_VEHICLE_ID;
					FL_Go(i, false);
				}
				else FL_Go(i, true);
			}
			else
			{
				if(random(100) < 35) FL_PutCar(i, random(100) < 12);
				else FL_Go(i, false);
			}
		}
	}
	return 1;
}

public FCNPC_OnReachDestination(npcid)
{
	// city bots
	for(new i; i < FL_MAX_BOTS; i++)
	{
		if(g_Bot[i] == npcid)
		{
			FL_Go(i, g_BotVeh[i] != INVALID_VEHICLE_ID);
			return 1;
		}
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(IsPlayerNPC(playerid)) return 1;

	// SBP trigger
	if(SBP_TextIsTrigger(text))
	{
		if(!SBP_IsBusy() && g_SBP_Cooldown[playerid] <= gettime())
			SetTimerEx("SBP_DelayedStart", 1500 + random(1500), false, "i", playerid);
	}

	// city bot reply nearby
	if(g_Run)
	{
		new Float:px,py,pz;
		GetPlayerPos(playerid, px,py,pz);
		for(new i; i < FL_MAX_BOTS; i++)
		{
			if(g_Bot[i] == INVALID_PLAYER_ID || !FCNPC_IsValid(g_Bot[i])) continue;
			new Float:x,y,z;
			FCNPC_GetPosition(g_Bot[i], x,y,z);
			if(((x-px)*(x-px)+(y-py)*(y-py)) > 20.0*20.0) continue;
			if(random(100) < 22)
			{
				SetTimerEx("FL_Reply", 600+random(800), false, "i", i);
				break;
			}
		}
	}
	return 1;
}

forward SBP_DelayedStart(playerid);
public SBP_DelayedStart(playerid)
{
	SBP_Start(playerid);
	return 1;
}

forward FL_Reply(i);
public FL_Reply(i)
{
	FL_Say(i, g_Reply[random(sizeof g_Reply)]);
	return 1;
}

public OnPlayerConnect(playerid)
{
	g_SBP_Cooldown[playerid] = 0;
	g_SBP_Task[playerid] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if(g_SBP_Target == playerid) SBP_Clear();
	g_SBP_Task[playerid] = 0;
	return 1;
}

public OnFilterScriptInit()
{
	for(new i; i < FL_MAX_BOTS; i++)
	{
		g_Bot[i] = INVALID_PLAYER_ID;
		g_BotVeh[i] = INVALID_VEHICLE_ID;
	}
	for(new i; i < FL_MAX_SBP; i++)
		g_SBP_Npc[i] = INVALID_PLAYER_ID;
	g_SBP_Veh = INVALID_VEHICLE_ID;
	g_SBP_Target = INVALID_PLAYER_ID;
	g_SBP_State = SBP_NONE;
	g_Run = false;
	g_Timer = 0;

	print("=================================");
	print(" FakeLifeBR v3 + SBP system");
	print(" FCNPC: github.com/ziggi/FCNPC");
	print(" Auto city bots + anti-bot police");
	print("=================================");
	SetTimer("FL_Boot", FL_BOOT_DELAY, false);
	return 1;
}

public OnFilterScriptExit()
{
	g_Run = false;
	if(g_Timer) KillTimer(g_Timer);
	for(new i; i < FL_MAX_BOTS; i++) FL_ClearBot(i);
	SBP_Clear();
	return 1;
}
