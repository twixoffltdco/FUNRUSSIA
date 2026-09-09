/*
 *  HomeMarkers Ч /famgo + маркер гаража у семейного дома
 *  filterscripts HomeMarkers
 *  ”бери FamilyGarage FamilyHouse
 */

#include <a_samp>
#tryinclude <streamer>
#tryinclude <Pawn.CMD>

#if defined _streamer_included
	#define HM_ST 1
#endif

#define HM_MAX     (200)
#define HM_PICKUP  (19131)
#define HM_SCOOTER (462)
#define HM_FILE    "HomeMarkers.cfg"
#define HM_DIALOG  (45301)
#define HM_TICK    (2000)

new bool:hm_on[HM_MAX];
new hm_fam[HM_MAX];
new hm_owner[HM_MAX][MAX_PLAYER_NAME];
new Float:hm_x[HM_MAX], Float:hm_y[HM_MAX], Float:hm_z[HM_MAX];
new Float:hm_px[HM_MAX], Float:hm_py[HM_MAX], Float:hm_pz[HM_MAX];
new hm_vw[HM_MAX];

new gPick[MAX_PLAYERS];
new Text3D:gLab[MAX_PLAYERS];
new bool:gVis[MAX_PLAYERS];
new gSlot[MAX_PLAYERS];
new gScoot[MAX_PLAYERS];
new gLastInt[MAX_PLAYERS];
new gTimer;

stock HM_Name(playerid, dest[], len = sizeof dest) { GetPlayerName(playerid, dest, len); }
stock bool:HM_Eq(const a[], const b[]) { return (a[0] && b[0] && !strcmp(a, b, true)); }

stock bool:HM_ValidPos(Float:x, Float:y, Float:z)
{
	if(floatabs(x) < 1.0 && floatabs(y) < 1.0) return false;
	if(z < -20.0 || z > 1200.0) return false;
	if(floatabs(x) < 50.0 && floatabs(y) < 50.0 && z < 5.0) return false;
	return true;
}

stock HM_Family(playerid)
{
	new f;
	f = GetPVarInt(playerid, "FG_FAMILY"); if(f > 0) return f;
	f = GetPVarInt(playerid, "FAMILY_ID"); if(f > 0) return f;
	f = GetPVarInt(playerid, "FamilyID"); if(f > 0) return f;
	f = GetPVarInt(playerid, "pFamily"); if(f > 0) return f;
	f = GetPVarInt(playerid, "Member"); if(f > 0) return f;
	f = GetPVarInt(playerid, "family"); if(f > 0) return f;
	f = GetPVarInt(playerid, "FamID"); if(f > 0) return f;
	f = CallRemoteFunction("GetPlayerIdFamily", "i", playerid); if(f > 0) return f;
	f = CallRemoteFunction("GetPlayerFamily", "i", playerid); if(f > 0) return f;
	return 0;
}

stock HM_Free()
{
	for(new i; i < HM_MAX; i++) if(!hm_on[i]) return i;
	return -1;
}

stock bool:HM_CanSee(playerid, slot)
{
	if(!(0 <= slot < HM_MAX) || !hm_on[slot]) return false;
	new name[MAX_PLAYER_NAME];
	HM_Name(playerid, name);
	if(HM_Eq(hm_owner[slot], name)) return true;
	new fam = HM_Family(playerid);
	if(fam > 0 && hm_fam[slot] > 0 && fam == hm_fam[slot]) return true;
	return false;
}

stock HM_FindForPlayer(playerid)
{
	new name[MAX_PLAYER_NAME];
	HM_Name(playerid, name);
	new fam = HM_Family(playerid);
	for(new i; i < HM_MAX; i++)
		if(hm_on[i] && HM_Eq(hm_owner[i], name)) return i;
	if(fam > 0)
		for(new i; i < HM_MAX; i++)
			if(hm_on[i] && hm_fam[i] == fam) return i;
	return -1;
}

stock HM_Save()
{
	new File:f = fopen(HM_FILE, io_write);
	if(!f) return 0;
	for(new i; i < HM_MAX; i++)
	{
		if(!hm_on[i] || !HM_ValidPos(hm_x[i], hm_y[i], hm_z[i])) continue;
		new line[160];
		format(line, sizeof line, "%d|%s|%.3f|%.3f|%.3f|%d\r\n",
			hm_fam[i], hm_owner[i], hm_x[i], hm_y[i], hm_z[i], hm_vw[i]);
		fwrite(f, line);
	}
	fclose(f);
	return 1;
}

stock HM_Load()
{
	for(new i; i < HM_MAX; i++) { hm_on[i] = false; hm_owner[i][0] = 0; hm_fam[i] = 0; hm_vw[i] = 0; }
	if(!fexist(HM_FILE)) return 0;
	new File:f = fopen(HM_FILE, io_read);
	if(!f) return 0;
	new buf[160], cnt;
	while(fread(f, buf))
	{
		for(new k = strlen(buf)-1; k >= 0; k--)
			if(buf[k]=='\n'||buf[k]=='\r') buf[k]=0; else break;
		if(!buf[0]) continue;
		new p1 = strfind(buf, "|"); if(p1 < 0) continue;
		new p2 = strfind(buf, "|", false, p1+1); if(p2 < 0) continue;
		new p3 = strfind(buf, "|", false, p2+1); if(p3 < 0) continue;
		new p4 = strfind(buf, "|", false, p3+1); if(p4 < 0) continue;
		new p5 = strfind(buf, "|", false, p4+1);
		new tmp[48], Float:x, Float:y, Float:z, fam, vw, owner[MAX_PLAYER_NAME];
		strmid(tmp, buf, 0, p1); fam = strval(tmp);
		strmid(owner, buf, p1+1, p2, MAX_PLAYER_NAME);
		strmid(tmp, buf, p2+1, p3); x = floatstr(tmp);
		strmid(tmp, buf, p3+1, p4); y = floatstr(tmp);
		if(p5 < 0) { strmid(tmp, buf, p4+1, strlen(buf)); z = floatstr(tmp); vw = 0; }
		else { strmid(tmp, buf, p4+1, p5); z = floatstr(tmp); strmid(tmp, buf, p5+1, strlen(buf)); vw = strval(tmp); }
		if(!HM_ValidPos(x, y, z)) continue;
		new slot = HM_Free();
		if(slot == -1) break;
		hm_on[slot] = true;
		hm_fam[slot] = fam;
		format(hm_owner[slot], MAX_PLAYER_NAME, "%s", owner);
		hm_x[slot] = x; hm_y[slot] = y; hm_z[slot] = z; hm_vw[slot] = vw;
		hm_px[slot] = x + 2.5; hm_py[slot] = y + 1.5; hm_pz[slot] = z;
		cnt++;
	}
	fclose(f);
	printf("[HomeMarkers] loaded %d", cnt);
	return 1;
}

stock HM_SaveAt(playerid)
{
	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);
	if(!HM_ValidPos(x, y, z)) return 0;

	new name[MAX_PLAYER_NAME];
	HM_Name(playerid, name);
	new fam = HM_Family(playerid);

	new slot = -1;
	for(new i; i < HM_MAX; i++)
		if(hm_on[i] && HM_Eq(hm_owner[i], name)) { slot = i; break; }
	if(slot == -1 && fam > 0)
		for(new i; i < HM_MAX; i++)
			if(hm_on[i] && hm_fam[i] == fam) { slot = i; break; }
	if(slot == -1) slot = HM_Free();
	if(slot == -1) return 0;

	hm_on[slot] = true;
	hm_fam[slot] = fam;
	format(hm_owner[slot], MAX_PLAYER_NAME, "%s", name);
	hm_x[slot] = x; hm_y[slot] = y; hm_z[slot] = z;
	hm_vw[slot] = GetPlayerVirtualWorld(playerid);
	hm_px[slot] = x + (2.5 * floatsin(-a, degrees));
	hm_py[slot] = y + (2.5 * floatcos(-a, degrees));
	hm_pz[slot] = z;
	HM_Save();
	gVis[playerid] = false;
	gSlot[playerid] = -1;
	HM_ShowVis(playerid);
	SendClientMessage(playerid, 0x33CCFFFF, "[√араж] “очка дома сохранена. ћаркер р€дом. /famgo Ч сюда.");
	return 1;
}

stock HM_KillVis(playerid)
{
	if(!gVis[playerid]) return;
	#if defined HM_ST
		if(gPick[playerid] != -1) { DestroyDynamicPickup(gPick[playerid]); gPick[playerid] = -1; }
		if(_:gLab[playerid] != 0) { DestroyDynamic3DTextLabel(_:gLab[playerid]); gLab[playerid] = Text3D:0; }
	#endif
	gVis[playerid] = false;
}

stock HM_ShowVis(playerid)
{
	if(!IsPlayerConnected(playerid)) { HM_KillVis(playerid); gSlot[playerid] = -1; return 0; }
	new slot = HM_FindForPlayer(playerid);
	if(slot == -1 || !HM_CanSee(playerid, slot))
	{
		HM_KillVis(playerid);
		gSlot[playerid] = -1;
		return 0;
	}
	if(gSlot[playerid] == slot && gVis[playerid]) return 1;

	HM_KillVis(playerid);
	gSlot[playerid] = slot;

	new Float:x = hm_px[slot], Float:y = hm_py[slot], Float:z = hm_pz[slot] + 0.3;
	new lab[64];
	format(lab, sizeof lab, "{33CCFF}√араж\n{FFFFFF}Alt Ч вз€ть “—");

	#if defined HM_ST
		gPick[playerid] = CreateDynamicPickup(HM_PICKUP, 1, x, y, z, -1, -1, playerid, 50.0);
		gLab[playerid] = Text3D:CreateDynamic3DTextLabel(lab, 0x33CCFFFF, x, y, z + 0.85, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, playerid);
		gVis[playerid] = true;
	#endif
	return 1;
}

stock HM_Open(playerid)
{
	new slot = gSlot[playerid];
	if(slot == -1) slot = HM_FindForPlayer(playerid);
	if(slot == -1 || !HM_CanSee(playerid, slot)) return 0;
	if(!IsPlayerInRangeOfPoint(playerid, 12.0, hm_px[slot], hm_py[slot], hm_pz[slot])) return 0;

	CallRemoteFunction("ShowOwnableCarListDialog", "i", playerid);
	CallRemoteFunction("ShowPlayerOwnableCars", "i", playerid);

	ShowPlayerDialog(playerid, HM_DIALOG, DIALOG_STYLE_LIST, "{33CCFF}√араж",
		"1. —во€ машина (мод)\n2. —кутер\n3. «акрыть", "OK", "X");
	return 1;
}

stock HM_Scooter(playerid)
{
	new slot = gSlot[playerid];
	if(slot == -1 || !HM_CanSee(playerid, slot)) return 0;
	new Float:x = hm_px[slot]+1.2, Float:y = hm_py[slot], Float:z = hm_pz[slot], Float:a;
	GetPlayerFacingAngle(playerid, a);
	if(gScoot[playerid] && GetVehicleModel(gScoot[playerid]) > 0) DestroyVehicle(gScoot[playerid]);
	new vid = CreateVehicle(HM_SCOOTER, x, y, z+0.4, a, 1, 1, 180);
	if(vid == INVALID_VEHICLE_ID) return 0;
	gScoot[playerid] = vid;
	SetVehicleVirtualWorld(vid, GetPlayerVirtualWorld(playerid));
	LinkVehicleToInterior(vid, GetPlayerInterior(playerid));
	PutPlayerInVehicle(playerid, vid, 0);
	SendClientMessage(playerid, 0x66CC00FF, "—кутер.");
	return 1;
}

stock HM_DoFamgo(playerid)
{
	new slot = HM_FindForPlayer(playerid);
	if(slot == -1)
	{
		SendClientMessage(playerid, 0xFFCC00FF, "ƒом ещЄ не сохранЄн. ¬ыйди из квартиры/дома на улицу Ч точка запишетс€.");
		return 1;
	}
	if(!HM_CanSee(playerid, slot) || !HM_ValidPos(hm_x[slot], hm_y[slot], hm_z[slot]))
	{
		SendClientMessage(playerid, 0xFF0000FF, "Ќет точки дома.");
		return 1;
	}
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, hm_vw[slot]);
	SetPlayerPos(playerid, hm_x[slot], hm_y[slot], hm_z[slot] + 0.5);
	SendClientMessage(playerid, 0x66CC00FF, "/famgo Ч вы у дома.");
	HM_ShowVis(playerid);
	return 1;
}

// ---- commands: ALWAYS both Pawn.CMD and OnPlayerCommandText ----
#if defined _Pawn_CMD_included
CMD:famgo(playerid, params[])
{
	#pragma unused params
	return HM_DoFamgo(playerid);
}
CMD:homesave(playerid, params[])
{
	#pragma unused params
	if(GetPlayerInterior(playerid) != 0)
	{
		SendClientMessage(playerid, 0xFFCC00FF, "—охран€й на улице.");
		return 1;
	}
	HM_SaveAt(playerid);
	return 1;
}
#endif

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/famgo", true) || !strcmp(cmdtext, "famgo", true))
		return HM_DoFamgo(playerid);
	if(!strcmp(cmdtext, "/homesave", true))
	{
		if(GetPlayerInterior(playerid) != 0)
		{
			SendClientMessage(playerid, 0xFFCC00FF, "—охран€й на улице.");
			return 1;
		}
		HM_SaveAt(playerid);
		return 1;
	}
	return 0;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return 1;
	if(!((newkeys & KEY_WALK) || (newkeys & KEY_CROUCH) || (newkeys & KEY_SECONDARY_ATTACK))) return 1;
	if(GetPVarInt(playerid, "HM_CD") > GetTickCount()) return 1;
	if(gSlot[playerid] == -1) return 1;
	new s = gSlot[playerid];
	if(IsPlayerInRangeOfPoint(playerid, 12.0, hm_px[s], hm_py[s], hm_pz[s]))
	{
		SetPVarInt(playerid, "HM_CD", GetTickCount() + 2000);
		HM_Open(playerid);
	}
	return 1;
}

forward HM_Tick();
public HM_Tick()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		new intid = GetPlayerInterior(i);
		// вышел из интерьера дома/квартиры на улицу -> сохранить точку 1 раз
		if(gLastInt[i] > 0 && intid == 0)
		{
			if(HM_ValidPos(0.0, 0.0, 0.0) || true)
			{
				new Float:x, Float:y, Float:z;
				GetPlayerPos(i, x, y, z);
				if(HM_ValidPos(x, y, z))
					HM_SaveAt(i);
			}
		}
		gLastInt[i] = intid;
		HM_ShowVis(i);
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	#pragma unused inputtext
	if(dialogid != HM_DIALOG) return 0;
	if(!response) return 1;
	if(listitem == 0) SendClientMessage(playerid, 0xFFCC00FF, "ћашина Ч через мод.");
	else if(listitem == 1) HM_Scooter(playerid);
	return 1;
}

public OnPlayerConnect(playerid)
{
	gPick[playerid] = -1; gLab[playerid] = Text3D:0; gVis[playerid] = false;
	gSlot[playerid] = -1; gScoot[playerid] = 0; gLastInt[playerid] = 0;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	HM_KillVis(playerid);
	if(gScoot[playerid] && GetVehicleModel(gScoot[playerid]) > 0) DestroyVehicle(gScoot[playerid]);
	gScoot[playerid] = 0;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	gLastInt[playerid] = GetPlayerInterior(playerid);
	SetTimerEx("HM_Later", 1200, false, "i", playerid);
	return 1;
}

forward HM_Later(playerid);
public HM_Later(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	HM_ShowVis(playerid);
	SendClientMessage(playerid, 0x33CCFFFF, "[HomeMarkers] /famgo | выйди из дома на улицу Ч по€витс€ гараж");
	return 1;
}

public OnFilterScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		gPick[i] = -1; gLab[i] = Text3D:0; gVis[i] = false;
		gSlot[i] = -1; gScoot[i] = 0; gLastInt[i] = 0;
	}
	for(new i; i < HM_MAX; i++) hm_on[i] = false;
	HM_Load();
	gTimer = SetTimer("HM_Tick", HM_TICK, true);
	print("========================================");
	print(" [HomeMarkers] LOADED Ч /famgo works");
	print(" Exit house to street = garage marker");
	print("========================================");
	return 1;
}

public OnFilterScriptExit()
{
	if(gTimer) KillTimer(gTimer);
	for(new i; i < MAX_PLAYERS; i++) HM_KillVis(i);
	HM_Save();
	return 1;
}
