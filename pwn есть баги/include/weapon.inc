#if defined _weapon_included
	#endinput
#endif

#define _weapon_included
#pragma library samp
#include <a_samp>

#define MAX_WEAPON_SLOTS	(13)

#define SetPlayerWeaponInfo(%0,%1,%2,%3)		g_player_weapon[%0][%1][%2] = %3
#define GetPlayerWeaponInfo(%0,%1,%2)			g_player_weapon[%0][%1][%2]
#define AddPlayerWeaponInfo(%0,%1,%2,%3,%4)		g_player_weapon[%0][%1][%2] %3= %4

enum E_PLAYER_WEAPON_STRUCT
{
	TRACK_W_ID,
	TRACK_W_AMMO
}

new g_player_weapon[MAX_PLAYERS][MAX_WEAPON_SLOTS][E_PLAYER_WEAPON_STRUCT];

stock GetWeaponSlot(weapon_id)
{
	switch(weapon_id)
	{
		case 0, 1:      	return 0;
		case 2..9:      	return 1;
		case 22..24:    	return 2;
		case 25..27:    	return 3;
		case 28, 29, 32:  	return 4;
		case 30, 31:     	return 5;
		case 33, 34:     	return 6;
		case 35..38:    	return 7;
		case 16..18:    	return 8;
		case 41..43:    	return 9;
		case 10..15:    	return 10;
		case 44..46:    	return 11;
		case 40:        	return 12;
	}
	return -1;
}

stock n_GivePlayerWeapon(playerid, weapon_id, weapon_ammo)
{
	new weapon_slot = GetWeaponSlot(weapon_id);
	if(weapon_slot == -1 || weapon_ammo == 0) return 0;

	SetPlayerWeaponInfo(playerid, weapon_slot, TRACK_W_ID,		weapon_id);
	AddPlayerWeaponInfo(playerid, weapon_slot, TRACK_W_AMMO, +, 	weapon_ammo);
	if(GetPlayerWeaponInfo(playerid, weapon_slot, TRACK_W_AMMO) < 0)
		SetPlayerWeaponInfo(playerid, weapon_slot, TRACK_W_AMMO, 0);

	return GivePlayerWeapon(playerid, weapon_id, weapon_ammo);
}

stock n_TakePlayerWeapon(playerid, weapon_id)
{
	new weapon_slot = GetWeaponSlot(weapon_id),
		slot_weapon,
		slot_ammo;

	for(new idx; idx < MAX_WEAPON_SLOTS; idx ++)
	{
		GetPlayerWeaponData(playerid, idx, slot_weapon, slot_ammo);

		if(idx == weapon_slot && weapon_id == slot_weapon)
		{
			SetPlayerWeaponInfo(playerid, weapon_slot, TRACK_W_ID, 0);
			SetPlayerWeaponInfo(playerid, weapon_slot, TRACK_W_AMMO, 0);
			SetPlayerAmmo(playerid, weapon_id, 0);
			break;
		}
	}
	return 1;
}

stock n_ResetPlayerWeapons(playerid)
{
	for(new idx; idx < MAX_WEAPON_SLOTS; idx ++)
	{
		SetPlayerWeaponInfo(playerid, idx, TRACK_W_ID, 	0);
		SetPlayerWeaponInfo(playerid, idx, TRACK_W_AMMO,	0);
	}

	return ResetPlayerWeapons(playerid);
}

#if defined _ALS_GivePlayerWeapon
	#undef GivePlayerWeapon
#else
	#define _ALS_GivePlayerWeapon
#endif
#define GivePlayerWeapon n_GivePlayerWeapon

#if defined _ALS_ResetPlayerWeapons
	#undef ResetPlayerWeapons
#else
	#define _ALS_ResetPlayerWeapons
#endif
#define ResetPlayerWeapons n_ResetPlayerWeapons

stock ClearPlayerWeaponTracking(playerid)
{
	for(new idx; idx < MAX_WEAPON_SLOTS; idx++)
	{
		SetPlayerWeaponInfo(playerid, idx, TRACK_W_ID, 0);
		SetPlayerWeaponInfo(playerid, idx, TRACK_W_AMMO, 0);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	ClearPlayerWeaponTracking(playerid);

	#if defined weapon_OnPlayerConnect
		return weapon_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect weapon_OnPlayerConnect
#if defined weapon_OnPlayerConnect
	forward weapon_OnPlayerConnect(playerid);
#endif
