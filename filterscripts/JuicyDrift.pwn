/*
	JuicyDrift.pwn
	Soft drift on handbrake only
	Does not kill acceleration / firmware
*/

#define FILTERSCRIPT
#include <a_samp>

#define DRIFT_FORCE		0.028
#define MIN_SPEED		40.0
#define MAX_SIDE		0.07

public OnFilterScriptInit()
{
	print(" ");
	print("  [JuicyDrift] Soft | ruchnik");
	print(" ");
	return 1;
}

public OnFilterScriptExit() return 1;

public OnPlayerUpdate(playerid)
{
	if(!IsPlayerConnected(playerid) || IsPlayerNPC(playerid)) return 1;
	if(!IsPlayerInAnyVehicle(playerid)) return 1;
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;

	new vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid == INVALID_VEHICLE_ID) return 1;

	new keys, updown, leftright;
	GetPlayerKeys(playerid, keys, updown, leftright);

	if(!(keys & KEY_JUMP) && !(keys & KEY_HANDBRAKE)) return 1;
	if(leftright == 0) return 1;

	new Float:vx, Float:vy, Float:vz;
	GetVehicleVelocity(vehicleid, vx, vy, vz);
	new Float:speed = floatsqroot(vx*vx + vy*vy + vz*vz) * 180.0;
	if(speed < MIN_SPEED) return 1;

	new Float:angle;
	GetVehicleZAngle(vehicleid, angle);
	new Float:rad = angle * 3.14159265 / 180.0;
	new Float:sideX = -floatsin(rad);
	new Float:sideY =  floatcos(rad);

	new Float:force = DRIFT_FORCE * (speed / 110.0);
	if(force > MAX_SIDE) force = MAX_SIDE;

	if(leftright < 0) { vx += sideX * force; vy += sideY * force; }
	else              { vx -= sideX * force; vy -= sideY * force; }

	if(vz > 0.10) vz = 0.10;
	SetVehicleVelocity(vehicleid, vx, vy, vz);
	return 1;
}
