/*
 *  FamilyGarage AUTO — без команд
 *  Если у игрока есть семья (PVar) и известна точка дома —
 *  маркер гаража в 10 м, как на вокзале. Видят только свои.
 *
 *  filterscripts FamilyGarage
 *  scriptfiles/FamilyGarage.cfg
 */

#include <a_samp>
#tryinclude <streamer>
#if defined _streamer_included
	#define FG_ST 1
#endif

#define FG_MAX       (200)
#define FG_PICKUP    (19131)
#define FG_SCOOTER   (462)
#define FG_DIST      (10.0)
#define FG_FILE      "FamilyGarage.cfg"
#define FG_DIALOG    (45201)

enum E_FG {
	bool:fg_on,
	fg_fam,
	Float:fg_hx, Float:fg_hy, Float:fg_hz,
	Float:fg_px, Float:fg_py, Float:fg_pz
}
new gFG[FG_MAX][E_FG];
new gFG_Pick[MAX_PLAYERS], Text3D:gFG_Lab[MAX_PLAYERS], bool:gFG_Vis[MAX_PLAYERS];
new gFG_Slot[MAX_PLAYERS], gFG_Scoot[MAX_PLAYERS], gFG_LastInt[MAX_PLAYERS];
new gFG_Timer;

stock FG_GetFamily(playerid)
{
	new f;
	f = GetPVarInt(playerid, "FG_FAMILY"); if(f > 0) return f;
	f = GetPVarInt(playerid, "FAMILY_ID"); if(f > 0) return f;
	f = GetPVarInt(playerid, "FamilyID"); if(f > 0) return f;
	f = GetPVarInt(playerid, "pFamily"); if(f > 0) return f;
	f = GetPVarInt(playerid, "Member"); if(f > 0) return f;
	f = GetPVarInt(playerid, "family"); if(f > 0) return f;
	// remote from gamemode if exported
	f = CallRemoteFunction("FG_GetPlayerFamily", "i", playerid);
	if(f > 0) return f;
	return 0;
}

stock FG_FindFam(fam)
{
	if(fam <= 0) return -1;
	for(new i; i < FG_MAX; i++)
		if(gFG[i][fg_on] && gFG[i][fg_fam] == fam) return i;
	return -1;
}

stock FG_Free()
{
	for(new i; i < FG_MAX; i++) if(!gFG[i][fg_on]) return i;
	return -1;
}

stock FG_Calc(slot)
{
	gFG[slot][fg_px] = gFG[slot][fg_hx] + FG_DIST;
	gFG[slot][fg_py] = gFG[slot][fg_hy];
	gFG[slot][fg_pz] = gFG[slot][fg_hz];
}

stock FG_Save()
{
	new File:f = fopen(FG_FILE, io_write);
	if(!f) return 0;
	for(new i; i < FG_MAX; i++)
	{
		if(!gFG[i][fg_on]) continue;
		new line[96];
		format(line, sizeof line, "%d|%.3f|%.3f|%.3f\r\n",
			gFG[i][fg_fam], gFG[i][fg_hx], gFG[i][fg_hy], gFG[i][fg_hz]);
		fwrite(f, line);
	}
	fclose(f);
	return 1;
}

stock FG_Load()
{
	for(new i; i < FG_MAX; i++) gFG[i][fg_on] = false;
	if(!fexist(FG_FILE)) return 0;
	new File:f = fopen(FG_FILE, io_read);
	if(!f) return 0;
	new buf[96], cnt;
	while(fread(f, buf))
	{
		for(new k = strlen(buf)-1; k >= 0; k--)
			if(buf[k] == '\n' || buf[k] == '\r') buf[k] = 0; else break;
		if(!buf[0]) continue;
		new fam, Float:x, Float:y, Float:z;
		if(sscanf_line(buf, fam, x, y, z)) continue;
		new slot = FG_Free();
		if(slot == -1) break;
		gFG[slot][fg_on] = true;
		gFG[slot][fg_fam] = fam;
		gFG[slot][fg_hx] = x; gFG[slot][fg_hy] = y; gFG[slot][fg_hz] = z;
		FG_Calc(slot);
		cnt++;
	}
	fclose(f);
	printf("[FamilyGarage] auto-loaded %d", cnt);
	return 1;
}

stock bool:sscanf_line(const buf[], &fam, &Float:x, &Float:y, &Float:z)
{
	new p1 = strfind(buf, "|");
	if(p1 == -1) return true;
	new p2 = strfind(buf, "|", false, p1+1);
	if(p2 == -1) return true;
	new p3 = strfind(buf, "|", false, p2+1);
	if(p3 == -1) return true;
	new tmp[32];
	strmid(tmp, buf, 0, p1); fam = strval(tmp);
	strmid(tmp, buf, p1+1, p2); x = floatstr(tmp);
	strmid(tmp, buf, p2+1, p3); y = floatstr(tmp);
	strmid(tmp, buf, p3+1, strlen(buf)); z = floatstr(tmp);
	return false;
}

stock FG_Register(fam, Float:x, Float:y, Float:z)
{
	if(fam <= 0) return -1;
	new slot = FG_FindFam(fam);
	if(slot == -1)
	{
		slot = FG_Free();
		if(slot == -1) return -1;
		gFG[slot][fg_on] = true;
		gFG[slot][fg_fam] = fam;
	}
	gFG[slot][fg_hx] = x; gFG[slot][fg_hy] = y; gFG[slot][fg_hz] = z;
	FG_Calc(slot);
	FG_Save();
	return slot;
}

// callable from gamemode: CallRemoteFunction("FG_AutoGarage", "ifff", familyid, x, y, z);
forward FG_AutoGarage(fam, Float:x, Float:y, Float:z);
public FG_AutoGarage(fam, Float:x, Float:y, Float:z)
{
	return FG_Register(fam, x, y, z);
}

stock FG_Kill(playerid)
{
	if(!gFG_Vis[playerid]) return;
	#if defined FG_ST
		if(gFG_Pick[playerid] != -1) { DestroyDynamicPickup(gFG_Pick[playerid]); gFG_Pick[playerid] = -1; }
		if(_:gFG_Lab[playerid] != 0) { DestroyDynamic3DTextLabel(_:gFG_Lab[playerid]); gFG_Lab[playerid] = Text3D:0; }
	#else
		if(gFG_Pick[playerid] != -1) { DestroyPickup(gFG_Pick[playerid]); gFG_Pick[playerid] = -1; }
	#endif
	gFG_Vis[playerid] = false;
}

stock FG_Show(playerid)
{
	if(!IsPlayerConnected(playerid)) { FG_Kill(playerid); gFG_Slot[playerid] = -1; return 0; }
	new fam = FG_GetFamily(playerid);
	new slot = FG_FindFam(fam);
	gFG_Slot[playerid] = slot;
	if(slot == -1) { FG_Kill(playerid); return 0; }

	new Float:x = gFG[slot][fg_px], Float:y = gFG[slot][fg_py], Float:z = gFG[slot][fg_pz] + 0.2;
	new lab[64];
	format(lab, sizeof lab, "{33CCFF}Семейный гараж\n{FFFFFF}Alt — транспорт");

	#if defined FG_ST
		if(gFG_Vis[playerid])
		{
			Streamer_SetItemPos(STREAMER_TYPE_PICKUP, gFG_Pick[playerid], x, y, z);
			if(_:gFG_Lab[playerid] != 0)
			{
				Streamer_SetItemPos(STREAMER_TYPE_3D_TEXT_LABEL, _:gFG_Lab[playerid], x, y, z + 0.8);
				UpdateDynamic3DTextLabelText(_:gFG_Lab[playerid], 0x33CCFFFF, lab);
			}
		}
		else
		{
			gFG_Pick[playerid] = CreateDynamicPickup(FG_PICKUP, 23, x, y, z, -1, -1, playerid, 30.0);
			gFG_Lab[playerid] = Text3D:CreateDynamic3DTextLabel(lab, 0x33CCFFFF, x, y, z + 0.8, 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, playerid);
			gFG_Vis[playerid] = true;
		}
	#else
		if(gFG_Vis[playerid] && gFG_Pick[playerid] != -1) DestroyPickup(gFG_Pick[playerid]);
		gFG_Pick[playerid] = CreatePickup(FG_PICKUP, 23, x, y, z, -1);
		gFG_Vis[playerid] = true;
	#endif
	return 1;
}

stock FG_Menu(playerid)
{
	new slot = gFG_Slot[playerid];
	if(slot == -1) return 0;
	if(!IsPlayerInRangeOfPoint(playerid, 4.0, gFG[slot][fg_px], gFG[slot][fg_py], gFG[slot][fg_pz]))
		return 0;
	ShowPlayerDialog(playerid, FG_DIALOG, DIALOG_STYLE_LIST, "{33CCFF}Семейный гараж",
		"1. Своя машина (мода)\n2. Семейный скутер бесплатно\n3. Закрыть", "OK", "X");
	return 1;
}

stock FG_DoScooter(playerid)
{
	new slot = gFG_Slot[playerid];
	if(slot == -1) return 0;
	new Float:x = gFG[slot][fg_px] + 1.2, Float:y = gFG[slot][fg_py], Float:z = gFG[slot][fg_pz], Float:a;
	GetPlayerFacingAngle(playerid, a);
	if(gFG_Scoot[playerid] && GetVehicleModel(gFG_Scoot[playerid]) > 0) DestroyVehicle(gFG_Scoot[playerid]);
	new vid = CreateVehicle(FG_SCOOTER, x, y, z + 0.3, a, 1, 1, 180);
	if(vid == INVALID_VEHICLE_ID) return 0;
	gFG_Scoot[playerid] = vid;
	SetVehicleVirtualWorld(vid, GetPlayerVirtualWorld(playerid));
	LinkVehicleToInterior(vid, GetPlayerInterior(playerid));
	PutPlayerInVehicle(playerid, vid, 0);
	SendClientMessage(playerid, 0x66CC00FF, "Семейный скутер.");
	return 1;
}

// auto: exit interior with family -> register house exit as garage base
stock FG_AutoCapture(playerid)
{
	new fam = FG_GetFamily(playerid);
	if(fam <= 0) return 0;
	if(GetPlayerInterior(playerid) != 0) return 0;
	if(GetPlayerVirtualWorld(playerid) != 0) return 0;
	new Float:x,y,z;
	GetPlayerPos(playerid, x,y,z);
	if(z < -5.0 || z > 800.0) return 0;
	// only if not registered yet OR update softly first time
	new slot = FG_FindFam(fam);
	if(slot != -1) return 0; // already have
	FG_Register(fam, x, y, z);
	SendClientMessage(playerid, 0x33CCFFFF, "Семейный гараж: маркер появится в 10 м от дома.");
	return 1;
}

forward FG_Tick();
public FG_Tick()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;

		new intid = GetPlayerInterior(i);
		if(gFG_LastInt[i] > 0 && intid == 0)
			FG_AutoCapture(i);
		gFG_LastInt[i] = intid;

		FG_Show(i);

		if(GetPlayerState(i) == PLAYER_STATE_ONFOOT && gFG_Slot[i] != -1)
		{
			new keys, ud, lr; GetPlayerKeys(i, keys, ud, lr);
			if(keys & KEY_WALK)
			{
				if(GetPVarInt(i, "FG_CD") <= GetTickCount())
				{
					if(IsPlayerInRangeOfPoint(i, 3.5, gFG[gFG_Slot[i]][fg_px], gFG[gFG_Slot[i]][fg_py], gFG[gFG_Slot[i]][fg_pz]))
					{
						SetPVarInt(i, "FG_CD", GetTickCount() + 2000);
						FG_Menu(i);
					}
				}
			}
		}
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	#pragma unused inputtext
	if(dialogid != FG_DIALOG) return 0;
	if(!response) return 1;
	if(listitem == 0) SendClientMessage(playerid, 0xFFCC00FF, "Свою машину — через систему мода.");
	else if(listitem == 1) FG_DoScooter(playerid);
	return 1;
}

public OnPlayerConnect(playerid)
{
	gFG_Pick[playerid] = -1; gFG_Lab[playerid] = Text3D:0; gFG_Vis[playerid] = false;
	gFG_Slot[playerid] = -1; gFG_Scoot[playerid] = 0; gFG_LastInt[playerid] = 0;
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	FG_Kill(playerid);
	if(gFG_Scoot[playerid] && GetVehicleModel(gFG_Scoot[playerid]) > 0) DestroyVehicle(gFG_Scoot[playerid]);
	gFG_Scoot[playerid] = 0;
	return 1;
}
public OnPlayerSpawn(playerid)
{
	gFG_LastInt[playerid] = GetPlayerInterior(playerid);
	SetTimerEx("FG_Later", 1500, false, "i", playerid);
	return 1;
}
forward FG_Later(playerid);
public FG_Later(playerid) { if(IsPlayerConnected(playerid)) FG_Show(playerid); return 1; }

public OnFilterScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		gFG_Pick[i] = -1; gFG_Lab[i] = Text3D:0; gFG_Vis[i] = false;
		gFG_Slot[i] = -1; gFG_Scoot[i] = 0; gFG_LastInt[i] = 0;
	}
	FG_Load();
	gFG_Timer = SetTimer("FG_Tick", 2000, true);
	print("[FamilyGarage] AUTO no-commands | 10m marker");
	return 1;
}
public OnFilterScriptExit()
{
	if(gFG_Timer) KillTimer(gFG_Timer);
	for(new i; i < MAX_PLAYERS; i++) FG_Kill(i);
	FG_Save();
	return 1;
}
