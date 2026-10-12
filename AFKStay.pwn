/*
	AFKStay.pwn — тела как «АФК» на месте выхода
	Визуально: скин + анимация AFK/idle (как стоят в афк в моде).
	В /id и tab как живой игрок с статусом AFK мода — только геймод умеет.
	Без команд, без ботов.
*/

#define FILTERSCRIPT
#include <a_samp>

#define MAX_AFK_BODIES 150

enum E_AFK
{
	bool:afk_used,
	afk_actor,
	afk_veh,
	Float:afk_x,
	Float:afk_y,
	Float:afk_z,
	Float:afk_a,
	afk_interior,
	afk_vw,
	afk_skin,
	afk_name[MAX_PLAYER_NAME]
}
new AFK[MAX_AFK_BODIES][E_AFK];

stock AFK_FindByName(const name[])
{
	for(new i; i < MAX_AFK_BODIES; i++)
	{
		if(!AFK[i][afk_used]) continue;
		if(!strcmp(AFK[i][afk_name], name, true)) return i;
	}
	return -1;
}

stock AFK_FreeSlot()
{
	for(new i; i < MAX_AFK_BODIES; i++)
		if(!AFK[i][afk_used]) return i;
	return -1;
}

stock AFK_Clear(slot)
{
	if(slot < 0 || slot >= MAX_AFK_BODIES || !AFK[slot][afk_used]) return 0;
	if(IsValidActor(AFK[slot][afk_actor]))
		DestroyActor(AFK[slot][afk_actor]);
	if(AFK[slot][afk_veh] != INVALID_VEHICLE_ID)
		DestroyVehicle(AFK[slot][afk_veh]);
	AFK[slot][afk_used] = false;
	AFK[slot][afk_actor] = INVALID_ACTOR_ID;
	AFK[slot][afk_veh] = INVALID_VEHICLE_ID;
	AFK[slot][afk_name][0] = 0;
	return 1;
}

stock AFK_ClearByName(const name[])
{
	new s = AFK_FindByName(name);
	if(s != -1) AFK_Clear(s);
	return 1;
}

// Анимации как у типичного AFK в модах (стоит / скучает)
stock AFK_ApplyAnim(actorid, style)
{
	if(!IsValidActor(actorid)) return 0;
	switch(style % 5)
	{
		case 0: ApplyActorAnimation(actorid, "PED", "IDLE_chat", 4.1, 1, 0, 0, 0, 0);
		case 1: ApplyActorAnimation(actorid, "COP_AMBIENT", "Coplook_loop", 4.0, 1, 0, 0, 0, 0);
		case 2: ApplyActorAnimation(actorid, "PED", "XPRESSscratch", 4.0, 1, 0, 0, 0, 0);
		case 3: ApplyActorAnimation(actorid, "DEALER", "DEALER_IDLE", 4.0, 1, 0, 0, 0, 0);
		case 4: ApplyActorAnimation(actorid, "PED", "IDLE_stance", 4.1, 1, 0, 0, 0, 0);
	}
	return 1;
}

stock AFK_CreateFromPlayer(playerid)
{
	if(!IsPlayerConnected(playerid) || IsPlayerNPC(playerid)) return 0;

	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof name);
	AFK_ClearByName(name);

	new slot = AFK_FreeSlot();
	if(slot == -1) { AFK_Clear(0); slot = 0; }

	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);
	new skin = GetPlayerSkin(playerid);
	new intid = GetPlayerInterior(playerid);
	new vw = GetPlayerVirtualWorld(playerid);

	new act = CreateActor(skin, x, y, z, a);
	if(act == INVALID_ACTOR_ID) return 0;

	SetActorVirtualWorld(act, vw);
	SetActorInvulnerable(act, true);
	AFK_ApplyAnim(act, slot + skin);

	AFK[slot][afk_used] = true;
	AFK[slot][afk_actor] = act;
	AFK[slot][afk_skin] = skin;
	AFK[slot][afk_x] = x;
	AFK[slot][afk_y] = y;
	AFK[slot][afk_z] = z;
	AFK[slot][afk_a] = a;
	AFK[slot][afk_interior] = intid;
	AFK[slot][afk_vw] = vw;
	format(AFK[slot][afk_name], MAX_PLAYER_NAME, "%s", name);
	AFK[slot][afk_veh] = INVALID_VEHICLE_ID;

	if(IsPlayerInAnyVehicle(playerid))
	{
		new pveh = GetPlayerVehicleID(playerid);
		new model = GetVehicleModel(pveh);
		new Float:vx, Float:vy, Float:vz, Float:va;
		GetVehiclePos(pveh, vx, vy, vz);
		GetVehicleZAngle(pveh, va);
		new nv = CreateVehicle(model, vx, vy, vz, va, 1, 1, 0);
		if(nv != INVALID_VEHICLE_ID)
		{
			SetVehicleVirtualWorld(nv, vw);
			LinkVehicleToInterior(nv, intid);
			SetVehicleParamsEx(nv, 0, 0, 0, 1, 0, 0, 0);
			AFK[slot][afk_veh] = nv;
			// тело чуть сбоку от тачки, не внутри модели
			SetActorPos(act, vx + 1.2, vy, vz);
		}
	}
	return 1;
}

stock AFK_RestorePlayer(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof name);
	new s = AFK_FindByName(name);
	if(s == -1) return 0;

	SetPlayerInterior(playerid, AFK[s][afk_interior]);
	SetPlayerVirtualWorld(playerid, AFK[s][afk_vw]);
	SetPlayerPos(playerid, AFK[s][afk_x], AFK[s][afk_y], AFK[s][afk_z] + 0.15);
	SetPlayerFacingAngle(playerid, AFK[s][afk_a]);
	SetCameraBehindPlayer(playerid);
	AFK_Clear(s);
	return 1;
}

// периодически обновлять аним (чтобы не сбрасывалась)
forward AFK_RefreshAnims();
public AFK_RefreshAnims()
{
	for(new i; i < MAX_AFK_BODIES; i++)
	{
		if(!AFK[i][afk_used]) continue;
		if(!IsValidActor(AFK[i][afk_actor])) continue;
		AFK_ApplyAnim(AFK[i][afk_actor], i + AFK[i][afk_skin]);
	}
	return 1;
}

public OnFilterScriptInit()
{
	print("  [AFKStay] AFK-тела на месте выхода");
	for(new i; i < MAX_AFK_BODIES; i++)
	{
		AFK[i][afk_used] = false;
		AFK[i][afk_actor] = INVALID_ACTOR_ID;
		AFK[i][afk_veh] = INVALID_VEHICLE_ID;
		AFK[i][afk_name][0] = 0;
	}
	SetTimer("AFK_RefreshAnims", 30000, true);
	return 1;
}

public OnFilterScriptExit()
{
	for(new i; i < MAX_AFK_BODIES; i++) AFK_Clear(i);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if(IsPlayerNPC(playerid)) return 1;
	AFK_CreateFromPlayer(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	SetTimerEx("AFK_SpawnDelay", 1200, false, "i", playerid);
	return 1;
}

forward AFK_SpawnDelay(playerid);
public AFK_SpawnDelay(playerid)
{
	if(!IsPlayerConnected(playerid) || IsPlayerNPC(playerid)) return 1;
	AFK_RestorePlayer(playerid);
	return 1;
}
