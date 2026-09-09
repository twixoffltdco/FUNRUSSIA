/*
 *  FamilyHouse AUTO — без команд, дом не слетает
 *  При выходе из интерьера с семьёй — дом запоминается.
 *  Всей семье виден маркер "Семейный дом".
 *
 *  filterscripts FamilyHouse
 *  scriptfiles/FamilyHouse.cfg
 */

#include <a_samp>
#tryinclude <streamer>
#if defined _streamer_included
	#define FH_ST 1
#endif

#define FH_MAX     (200)
#define FH_PICKUP  (1273)
#define FH_FILE    "FamilyHouse.cfg"

enum E_FH {
	bool:fh_on,
	fh_fam,
	Float:fh_x, Float:fh_y, Float:fh_z,
	fh_title[48]
}
new gFH[FH_MAX][E_FH];
new gFH_Pick[MAX_PLAYERS], Text3D:gFH_Lab[MAX_PLAYERS], bool:gFH_Vis[MAX_PLAYERS];
new gFH_LastInt[MAX_PLAYERS];
new gFH_Timer;

stock FH_GetFamily(playerid)
{
	new f;
	f = GetPVarInt(playerid, "FG_FAMILY"); if(f > 0) return f;
	f = GetPVarInt(playerid, "FAMILY_ID"); if(f > 0) return f;
	f = GetPVarInt(playerid, "FamilyID"); if(f > 0) return f;
	f = GetPVarInt(playerid, "pFamily"); if(f > 0) return f;
	f = GetPVarInt(playerid, "Member"); if(f > 0) return f;
	f = GetPVarInt(playerid, "family"); if(f > 0) return f;
	f = CallRemoteFunction("FG_GetPlayerFamily", "i", playerid);
	if(f > 0) return f;
	return 0;
}

stock FH_FindFam(fam)
{
	if(fam <= 0) return -1;
	for(new i; i < FH_MAX; i++)
		if(gFH[i][fh_on] && gFH[i][fh_fam] == fam) return i;
	return -1;
}
stock FH_Free()
{
	for(new i; i < FH_MAX; i++) if(!gFH[i][fh_on]) return i;
	return -1;
}

stock FH_Save()
{
	new File:f = fopen(FH_FILE, io_write);
	if(!f) return 0;
	for(new i; i < FH_MAX; i++)
	{
		if(!gFH[i][fh_on]) continue;
		new line[128];
		new ttl[48];
		if(gFH[i][fh_title][0]) format(ttl, sizeof ttl, "%s", gFH[i][fh_title]);
		else format(ttl, sizeof ttl, "-");
		format(line, sizeof line, "%d|%.3f|%.3f|%.3f|%s\r\n",
			gFH[i][fh_fam], gFH[i][fh_x], gFH[i][fh_y], gFH[i][fh_z], ttl);
		fwrite(f, line);
	}
	fclose(f);
	return 1;
}

forward bool:FH_Parse(const buf[], &fam, &Float:x, &Float:y, &Float:z, title[]);

stock FH_Load()
{
	for(new i; i < FH_MAX; i++) { gFH[i][fh_on] = false; gFH[i][fh_title][0] = 0; }
	if(!fexist(FH_FILE)) return 0;
	new File:f = fopen(FH_FILE, io_read);
	if(!f) return 0;
	new buf[128], cnt;
	while(fread(f, buf))
	{
		for(new k = strlen(buf)-1; k >= 0; k--)
			if(buf[k] == '\n' || buf[k] == '\r') buf[k] = 0; else break;
		if(!buf[0]) continue;
		new fam, Float:x, Float:y, Float:z, title[48];
		if(FH_Parse(buf, fam, x, y, z, title)) continue;
		new slot = FH_Free();
		if(slot == -1) break;
		gFH[slot][fh_on] = true;
		gFH[slot][fh_fam] = fam;
		gFH[slot][fh_x] = x; gFH[slot][fh_y] = y; gFH[slot][fh_z] = z;
		if(title[0] && strcmp(title, "-")) format(gFH[slot][fh_title], 48, "%s", title);
		cnt++;
	}
	fclose(f);
	printf("[FamilyHouse] auto-loaded %d", cnt);
	return 1;
}

stock bool:FH_Parse(const buf[], &fam, &Float:x, &Float:y, &Float:z, title[])
{
	new p1 = strfind(buf, "|"); if(p1 < 0) return true;
	new p2 = strfind(buf, "|", false, p1+1); if(p2 < 0) return true;
	new p3 = strfind(buf, "|", false, p2+1); if(p3 < 0) return true;
	new p4 = strfind(buf, "|", false, p3+1);
	new tmp[48];
	strmid(tmp, buf, 0, p1); fam = strval(tmp);
	strmid(tmp, buf, p1+1, p2); x = floatstr(tmp);
	strmid(tmp, buf, p2+1, p3); y = floatstr(tmp);
	if(p4 < 0)
	{
		strmid(tmp, buf, p3+1, strlen(buf)); z = floatstr(tmp);
		title[0] = 0;
	}
	else
	{
		strmid(tmp, buf, p3+1, p4); z = floatstr(tmp);
		strmid(title, buf, p4+1, strlen(buf), 48);
	}
	return false;
}

stock FH_Register(fam, Float:x, Float:y, Float:z)
{
	if(fam <= 0) return -1;
	new slot = FH_FindFam(fam);
	if(slot == -1)
	{
		slot = FH_Free();
		if(slot == -1) return -1;
		gFH[slot][fh_on] = true;
		gFH[slot][fh_fam] = fam;
		gFH[slot][fh_title][0] = 0;
	}
	gFH[slot][fh_x] = x; gFH[slot][fh_y] = y; gFH[slot][fh_z] = z;
	FH_Save();
	// sync garage point too
	CallRemoteFunction("FG_AutoGarage", "ifff", fam, x, y, z);
	return slot;
}

forward FH_AutoHouse(fam, Float:x, Float:y, Float:z);
public FH_AutoHouse(fam, Float:x, Float:y, Float:z)
{
	return FH_Register(fam, x, y, z);
}

stock FH_Kill(playerid)
{
	if(!gFH_Vis[playerid]) return;
	#if defined FH_ST
		if(gFH_Pick[playerid] != -1) { DestroyDynamicPickup(gFH_Pick[playerid]); gFH_Pick[playerid] = -1; }
		if(_:gFH_Lab[playerid] != 0) { DestroyDynamic3DTextLabel(_:gFH_Lab[playerid]); gFH_Lab[playerid] = Text3D:0; }
	#else
		if(gFH_Pick[playerid] != -1) { DestroyPickup(gFH_Pick[playerid]); gFH_Pick[playerid] = -1; }
	#endif
	gFH_Vis[playerid] = false;
}

stock FH_Show(playerid)
{
	if(!IsPlayerConnected(playerid)) { FH_Kill(playerid); return 0; }
	new fam = FH_GetFamily(playerid);
	new slot = FH_FindFam(fam);
	if(slot == -1) { FH_Kill(playerid); return 0; }

	new Float:x = gFH[slot][fh_x], Float:y = gFH[slot][fh_y], Float:z = gFH[slot][fh_z] + 0.3;
	new lab[96];
	if(gFH[slot][fh_title][0])
		format(lab, sizeof lab, "{FF99FF}Семейный дом\n{FFFFFF}%s", gFH[slot][fh_title]);
	else
		format(lab, sizeof lab, "{FF99FF}Семейный дом\n{FFFFFF}Семья #%d", fam);

	#if defined FH_ST
		if(gFH_Vis[playerid])
		{
			Streamer_SetItemPos(STREAMER_TYPE_PICKUP, gFH_Pick[playerid], x, y, z);
			if(_:gFH_Lab[playerid] != 0)
			{
				Streamer_SetItemPos(STREAMER_TYPE_3D_TEXT_LABEL, _:gFH_Lab[playerid], x, y, z + 0.9);
				UpdateDynamic3DTextLabelText(_:gFH_Lab[playerid], 0xFF99FFFF, lab);
			}
		}
		else
		{
			gFH_Pick[playerid] = CreateDynamicPickup(FH_PICKUP, 1, x, y, z, -1, -1, playerid, 40.0);
			gFH_Lab[playerid] = Text3D:CreateDynamic3DTextLabel(lab, 0xFF99FFFF, x, y, z + 0.9, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, playerid);
			gFH_Vis[playerid] = true;
		}
	#else
		if(gFH_Vis[playerid] && gFH_Pick[playerid] != -1) DestroyPickup(gFH_Pick[playerid]);
		gFH_Pick[playerid] = CreatePickup(FH_PICKUP, 1, x, y, z, -1);
		gFH_Vis[playerid] = true;
	#endif
	return 1;
}

stock FH_AutoCapture(playerid)
{
	new fam = FH_GetFamily(playerid);
	if(fam <= 0) return 0;
	if(GetPlayerInterior(playerid) != 0) return 0;
	if(GetPlayerVirtualWorld(playerid) != 0) return 0;
	if(FH_FindFam(fam) != -1) return 0;
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if(z < -5.0 || z > 800.0) return 0;
	FH_Register(fam, x, y, z);
	SendClientMessage(playerid, 0xFF99FFFF, "Семейный дом сохранён (не слетит после рестарта).");
	return 1;
}

forward FH_Tick();
public FH_Tick()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		new intid = GetPlayerInterior(i);
		if(gFH_LastInt[i] > 0 && intid == 0)
			FH_AutoCapture(i);
		gFH_LastInt[i] = intid;
		FH_Show(i);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	gFH_Pick[playerid] = -1; gFH_Lab[playerid] = Text3D:0; gFH_Vis[playerid] = false;
	gFH_LastInt[playerid] = 0;
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	FH_Kill(playerid);
	return 1;
}
public OnPlayerSpawn(playerid)
{
	gFH_LastInt[playerid] = GetPlayerInterior(playerid);
	SetTimerEx("FH_Later", 1200, false, "i", playerid);
	return 1;
}
forward FH_Later(playerid);
public FH_Later(playerid) { if(IsPlayerConnected(playerid)) FH_Show(playerid); return 1; }

public OnFilterScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		gFH_Pick[i] = -1; gFH_Lab[i] = Text3D:0; gFH_Vis[i] = false;
		gFH_LastInt[i] = 0;
	}
	FH_Load();
	gFH_Timer = SetTimer("FH_Tick", 2000, true);
	print("[FamilyHouse] AUTO no-commands | persist");
	return 1;
}
public OnFilterScriptExit()
{
	if(gFH_Timer) KillTimer(gFH_Timer);
	for(new i; i < MAX_PLAYERS; i++) FH_Kill(i);
	FH_Save();
	return 1;
}
