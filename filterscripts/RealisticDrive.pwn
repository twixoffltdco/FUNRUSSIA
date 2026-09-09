/*
	RealisticDrive.pwn
	Bolee realistic collisions + soft handling
	Does not break acceleration / drift firmware
*/

#define FILTERSCRIPT
#include <a_samp>

new Float:LastHP[MAX_VEHICLES];
new LastColTick[MAX_VEHICLES];

public OnFilterScriptInit()
{
	print(" ");
	print("  [RealisticDrive] Zagruzhen");
	print(" ");
	for(new i = 0; i < MAX_VEHICLES; i++)
	{
		LastHP[i] = 1000.0;
		LastColTick[i] = 0;
	}
	return 1;
}

public OnFilterScriptExit() return 1;

public OnVehicleSpawn(vehicleid)
{
	LastHP[vehicleid] = 1000.0;
	return 1;
}

// When vehicle takes damage - soften unrealistic fly-off
public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	#pragma unused playerid
	new Float:hp;
	GetVehicleHealth(vehicleid, hp);

	new Float:diff = LastHP[vehicleid] - hp;
	LastHP[vehicleid] = hp;

	if(diff < 15.0) return 1; // small scratch

	new now = GetTickCount();
	if(now - LastColTick[vehicleid] < 400) return 1;
	LastColTick[vehicleid] = now;

	new Float:vx, Float:vy, Float:vz;
	GetVehicleVelocity(vehicleid, vx, vy, vz);
	new Float:spd = floatsqroot(vx*vx + vy*vy + vz*vz);

	// hard hit - kill upward velocity, reduce speed (no rocket bounce)
	if(diff > 40.0 || spd > 0.45)
	{
		vx *= 0.55;
		vy *= 0.55;
		if(vz > 0.08) vz = 0.08;
		if(vz < -0.15) vz *= 0.5;
		SetVehicleVelocity(vehicleid, vx, vy, vz);
	}
	else if(diff > 20.0)
	{
		vx *= 0.75;
		vy *= 0.75;
		if(vz > 0.12) vz = 0.12;
		SetVehicleVelocity(vehicleid, vx, vy, vz);
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
	new vid = GetPlayerVehicleID(playerid);
	if(vid == INVALID_VEHICLE_ID) return 1;

	new Float:vx, Float:vy, Float:vz;
	GetVehicleVelocity(vid, vx, vy, vz);

	// anti crazy fly from bumps
	if(vz > 0.35)
	{
		vz = 0.18;
		SetVehicleVelocity(vid, vx, vy, vz);
	}
	return 1;
}
