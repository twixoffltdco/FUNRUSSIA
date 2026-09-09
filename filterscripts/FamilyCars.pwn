/*
	FamilyCars.pwn
	Semejnye mashiny + gonka 1v1
	Teksty na russkom
*/

#define FILTERSCRIPT
#include <a_samp>

#define MAX_FAM_CARS			100
#define INACTIVE_TIME			300
#define COLOR_FAM				0x00FF00FF
#define COLOR_ERR				0xFF6600FF
#define COLOR_RACE				0x00CCFFFF
#define SAVE_FILE				"familycars.txt"

#define RACE_NEED_PRESSES		3
#define RACE_COUNTDOWN			3
#define RACE_DIST				80.0
#define RACE_NEAR				12.0

enum E_FAMCAR
{
	fcVehID,
	fcModel,
	Float:fcX,
	Float:fcY,
	Float:fcZ,
	Float:fcA,
	fcColor1,
	fcColor2,
	fcFamilyID,
	fcLastUsed
}
new FamCar[MAX_FAM_CARS][E_FAMCAR];
new FamCarCount;

new RacePresses[MAX_PLAYERS];
new RaceLastPress[MAX_PLAYERS];
new RacePartner[MAX_PLAYERS];
new bool:RaceActive[MAX_PLAYERS];
new Float:RaceStartX[MAX_PLAYERS], Float:RaceStartY[MAX_PLAYERS], Float:RaceStartZ[MAX_PLAYERS];
new RaceCountdown[MAX_PLAYERS];

stock GetUnixTime() return gettime();

stock SaveFamCars()
{
	new File:f = fopen(SAVE_FILE, io_write);
	if(!f) return 0;
	for(new i = 0; i < FamCarCount; i++)
	{
		new line[160];
		format(line, sizeof(line), "%d %d %.4f %.4f %.4f %.4f %d %d\n",
			FamCar[i][fcModel], FamCar[i][fcFamilyID],
			FamCar[i][fcX], FamCar[i][fcY], FamCar[i][fcZ], FamCar[i][fcA],
			FamCar[i][fcColor1], FamCar[i][fcColor2]);
		fwrite(f, line);
	}
	fclose(f);
	return 1;
}

stock ParseLine(const str[], &model, &famid, &Float:x, &Float:y, &Float:z, &Float:a, &c1, &c2)
{
	new idx, len = strlen(str), buf[32], b;
	b=0; while(idx<len && str[idx]!=' ' && str[idx]!='\n' && str[idx]!='\r') buf[b++]=str[idx++];
	buf[b]=0; model=strval(buf); while(idx<len && str[idx]==' ') idx++;
	b=0; while(idx<len && str[idx]!=' ' && str[idx]!='\n' && str[idx]!='\r') buf[b++]=str[idx++];
	buf[b]=0; famid=strval(buf); while(idx<len && str[idx]==' ') idx++;
	b=0; while(idx<len && str[idx]!=' ' && str[idx]!='\n' && str[idx]!='\r') buf[b++]=str[idx++];
	buf[b]=0; x=floatstr(buf); while(idx<len && str[idx]==' ') idx++;
	b=0; while(idx<len && str[idx]!=' ' && str[idx]!='\n' && str[idx]!='\r') buf[b++]=str[idx++];
	buf[b]=0; y=floatstr(buf); while(idx<len && str[idx]==' ') idx++;
	b=0; while(idx<len && str[idx]!=' ' && str[idx]!='\n' && str[idx]!='\r') buf[b++]=str[idx++];
	buf[b]=0; z=floatstr(buf); while(idx<len && str[idx]==' ') idx++;
	b=0; while(idx<len && str[idx]!=' ' && str[idx]!='\n' && str[idx]!='\r') buf[b++]=str[idx++];
	buf[b]=0; a=floatstr(buf); while(idx<len && str[idx]==' ') idx++;
	b=0; while(idx<len && str[idx]!=' ' && str[idx]!='\n' && str[idx]!='\r') buf[b++]=str[idx++];
	buf[b]=0; c1=strval(buf); while(idx<len && str[idx]==' ') idx++;
	b=0; while(idx<len && str[idx]!=' ' && str[idx]!='\n' && str[idx]!='\r') buf[b++]=str[idx++];
	buf[b]=0; c2=strval(buf);
	return 1;
}

stock LoadFamCars()
{
	if(!fexist(SAVE_FILE)) return 0;
	new File:f = fopen(SAVE_FILE, io_read);
	if(!f) return 0;
	FamCarCount = 0;
	new line[160];
	while(fread(f, line) && FamCarCount < MAX_FAM_CARS)
	{
		new model, famid, c1, c2;
		new Float:x, Float:y, Float:z, Float:a;
		if(!ParseLine(line, model, famid, x, y, z, a, c1, c2)) continue;
		new vid = CreateVehicle(model, x, y, z, a, c1, c2, -1);
		if(vid == INVALID_VEHICLE_ID) continue;
		FamCar[FamCarCount][fcVehID] = vid;
		FamCar[FamCarCount][fcModel] = model;
		FamCar[FamCarCount][fcX] = x;
		FamCar[FamCarCount][fcY] = y;
		FamCar[FamCarCount][fcZ] = z;
		FamCar[FamCarCount][fcA] = a;
		FamCar[FamCarCount][fcColor1] = c1;
		FamCar[FamCarCount][fcColor2] = c2;
		FamCar[FamCarCount][fcFamilyID] = famid;
		FamCar[FamCarCount][fcLastUsed] = GetUnixTime();
		FamCarCount++;
	}
	fclose(f);
	printf("[FamilyCars] Zagruzheno %d semejnyh mashin", FamCarCount);
	return 1;
}

stock FindFamCarByVeh(vehicleid)
{
	for(new i = 0; i < FamCarCount; i++)
		if(FamCar[i][fcVehID] == vehicleid) return i;
	return -1;
}

stock bool:IsPlayerFamilyMember(playerid, familyid)
{
	#pragma unused familyid
	if(IsPlayerAdmin(playerid)) return true;
	return false;
}

stock ReturnCarToSpawn(idx)
{
	new vid = FamCar[idx][fcVehID];
	if(vid == INVALID_VEHICLE_ID) return 0;
	for(new p = 0; p < MAX_PLAYERS; p++)
	{
		if(IsPlayerConnected(p) && GetPlayerVehicleID(p) == vid)
			RemovePlayerFromVehicle(p);
	}
	SetVehiclePos(vid, FamCar[idx][fcX], FamCar[idx][fcY], FamCar[idx][fcZ]);
	SetVehicleZAngle(vid, FamCar[idx][fcA]);
	RepairVehicle(vid);
	SetVehicleHealth(vid, 1000.0);
	FamCar[idx][fcLastUsed] = GetUnixTime();
	return 1;
}

forward CheckInactiveCars();
public CheckInactiveCars()
{
	new now = GetUnixTime();
	for(new i = 0; i < FamCarCount; i++)
	{
		new vid = FamCar[i][fcVehID];
		if(vid == INVALID_VEHICLE_ID) continue;
		new bool:occupied = false;
		for(new p = 0; p < MAX_PLAYERS; p++)
		{
			if(!IsPlayerConnected(p)) continue;
			if(GetPlayerVehicleID(p) == vid && GetPlayerState(p) == PLAYER_STATE_DRIVER)
			{
				FamCar[i][fcLastUsed] = now;
				occupied = true;
				break;
			}
		}
		if(occupied) continue;
		if(now - FamCar[i][fcLastUsed] >= INACTIVE_TIME)
			ReturnCarToSpawn(i);
	}
	return 1;
}

stock FindNearbyDriver(playerid, Float:maxdist)
{
	if(!IsPlayerInAnyVehicle(playerid)) return -1;
	new Float:x1, Float:y1, Float:z1;
	GetPlayerPos(playerid, x1, y1, z1);
	new best = -1;
	new Float:bestd = maxdist;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(i == playerid || !IsPlayerConnected(i)) continue;
		if(GetPlayerState(i) != PLAYER_STATE_DRIVER) continue;
		new Float:x2, Float:y2, Float:z2;
		GetPlayerPos(i, x2, y2, z2);
		new Float:d = floatsqroot((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
		if(d < bestd) { bestd = d; best = i; }
	}
	return best;
}

stock StartRaceCountdown(p1, p2)
{
	RaceActive[p1] = true;
	RaceActive[p2] = true;
	RacePartner[p1] = p2;
	RacePartner[p2] = p1;
	RaceCountdown[p1] = RACE_COUNTDOWN;
	RaceCountdown[p2] = RACE_COUNTDOWN;
	new Float:x, Float:y, Float:z;
	GetPlayerPos(p1, x, y, z);
	RaceStartX[p1]=x; RaceStartY[p1]=y; RaceStartZ[p1]=z;
	GetPlayerPos(p2, x, y, z);
	RaceStartX[p2]=x; RaceStartY[p2]=y; RaceStartZ[p2]=z;
	new n1[MAX_PLAYER_NAME], n2[MAX_PLAYER_NAME];
	GetPlayerName(p1, n1, sizeof(n1));
	GetPlayerName(p2, n2, sizeof(n2));
	new str[144];
	format(str, sizeof(str), "[Гонка] %s против %s | Старт через %d...", n1, n2, RACE_COUNTDOWN);
	SendClientMessageToAll(COLOR_RACE, str);
	SetTimerEx("RaceTick", 1000, false, "i", p1);
}

forward RaceTick(playerid);
public RaceTick(playerid)
{
	if(!RaceActive[playerid]) return 1;
	new partner = RacePartner[playerid];
	if(partner == -1 || !RaceActive[partner]) return 1;
	RaceCountdown[playerid]--;
	if(RaceCountdown[playerid] > 0)
	{
		new str[64];
		format(str, sizeof(str), "~w~%d", RaceCountdown[playerid]);
		GameTextForPlayer(playerid, str, 900, 3);
		GameTextForPlayer(partner, str, 900, 3);
		SetTimerEx("RaceTick", 1000, false, "i", playerid);
	}
	else
	{
		GameTextForPlayer(playerid, "~g~ПОЕХАЛИ!", 1000, 3);
		GameTextForPlayer(partner, "~g~ПОЕХАЛИ!", 1000, 3);
		SendClientMessage(playerid, COLOR_RACE, "Гонка началась!");
		SendClientMessage(partner, COLOR_RACE, "Гонка началась!");
		SetTimerEx("RaceCheckFinish", 500, true, "i", playerid);
	}
	return 1;
}

forward RaceCheckFinish(playerid);
public RaceCheckFinish(playerid)
{
	if(!RaceActive[playerid]) return 0;
	new partner = RacePartner[playerid];
	if(partner == -1) return 0;
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	new Float:d1 = floatsqroot((x-RaceStartX[playerid])*(x-RaceStartX[playerid])+(y-RaceStartY[playerid])*(y-RaceStartY[playerid]));
	GetPlayerPos(partner, x, y, z);
	new Float:d2 = floatsqroot((x-RaceStartX[partner])*(x-RaceStartX[partner])+(y-RaceStartY[partner])*(y-RaceStartY[partner]));
	if(d1 >= RACE_DIST)
	{
		new n[MAX_PLAYER_NAME];
		GetPlayerName(playerid, n, sizeof(n));
		new str[144];
		format(str, sizeof(str), "[Гонка] %s финишировал первым!", n);
		SendClientMessageToAll(COLOR_RACE, str);
		RaceActive[playerid]=false; RaceActive[partner]=false;
		RacePartner[playerid]=-1; RacePartner[partner]=-1;
		return 0;
	}
	if(d2 >= RACE_DIST)
	{
		new n[MAX_PLAYER_NAME];
		GetPlayerName(partner, n, sizeof(n));
		new str[144];
		format(str, sizeof(str), "[Гонка] %s финишировал первым!", n);
		SendClientMessageToAll(COLOR_RACE, str);
		RaceActive[playerid]=false; RaceActive[partner]=false;
		RacePartner[playerid]=-1; RacePartner[partner]=-1;
		return 0;
	}
	return 1;
}

public OnFilterScriptInit()
{
	print(" ");
	print("  [FamilyCars] Zagruzhen");
	print(" ");
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		RacePresses[i]=0; RacePartner[i]=-1; RaceActive[i]=false;
	}
	LoadFamCars();
	SetTimer("CheckInactiveCars", 30000, true);
	return 1;
}

public OnFilterScriptExit()
{
	SaveFamCars();
	return 1;
}

public OnPlayerConnect(playerid)
{
	RacePresses[playerid]=0; RacePartner[playerid]=-1; RaceActive[playerid]=false;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(RaceActive[playerid])
	{
		new p = RacePartner[playerid];
		if(p != -1) RaceActive[p]=false;
		RaceActive[playerid]=false;
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
		new vid = GetPlayerVehicleID(playerid);
		new idx = FindFamCarByVeh(vid);
		if(idx == -1) return 1;
		FamCar[idx][fcLastUsed] = GetUnixTime();
		if(!IsPlayerFamilyMember(playerid, FamCar[idx][fcFamilyID]))
		{
			new str[144];
			format(str, sizeof(str), "Данная машина принадлежит семье (ID: %d)", FamCar[idx][fcFamilyID]);
			SendClientMessage(playerid, COLOR_ERR, str);
			RemovePlayerFromVehicle(playerid);
			SetTimerEx("ForceEject", 200, false, "i", playerid);
			return 1;
		}
	}
	return 1;
}

forward ForceEject(playerid);
public ForceEject(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
		RemovePlayerFromVehicle(playerid);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	new idx = FindFamCarByVeh(vehicleid);
	if(idx != -1) ReturnCarToSpawn(idx);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
	if(RaceActive[playerid]) return 1;
	new bool:hb = false;
	if((newkeys & KEY_JUMP) && !(oldkeys & KEY_JUMP)) hb = true;
	if((newkeys & KEY_HANDBRAKE) && !(oldkeys & KEY_HANDBRAKE)) hb = true;
	if(!hb) return 1;
	new now = GetTickCount();
	if(now - RaceLastPress[playerid] > 2000) RacePresses[playerid] = 0;
	RacePresses[playerid]++;
	RaceLastPress[playerid] = now;
	if(RacePresses[playerid] >= RACE_NEED_PRESSES)
	{
		RacePresses[playerid] = 0;
		new other = FindNearbyDriver(playerid, RACE_NEAR);
		if(other == -1)
		{
			SendClientMessage(playerid, COLOR_ERR, "Рядом нет другой машины для гонки");
			return 1;
		}
		if(RaceActive[other])
		{
			SendClientMessage(playerid, COLOR_ERR, "Игрок уже в гонке");
			return 1;
		}
		StartRaceCountdown(playerid, other);
	}
	return 1;
}

// Auto-mark: admin sits in vehicle and types nothing - we keep silent load from file only
// To add cars without commands: place vehicles in world and they get saved when FS loads from file
// Admin still needs one-time setup via file or we accept first vehicle create - simplified: no public commands
