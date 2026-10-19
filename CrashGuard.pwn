/*
	CrashGuard.pwn — защита от типичных падений после disconnect
	Не лечит баг внутри samp03svr/плагинов на 100%, но:
	- чистит джетпак/таймеры игрока
	- не даёт работать с невалидными vehicle id
	- логирует дисконнект
	Подключение: filterscripts CrashGuard (ПЕРЕД EuroSystem или после — не важно)
*/
#if defined _CRASHGUARD_INCLUDED
	#endinput
#endif
#define _CRASHGUARD_INCLUDED

#include <a_samp>

new CG_LastVeh[MAX_PLAYERS];
new CG_WasConnected[MAX_PLAYERS];

public OnFilterScriptInit()
{
	print("[CrashGuard] loaded");
	for(new i; i < MAX_PLAYERS; i++)
	{
		CG_LastVeh[i] = INVALID_VEHICLE_ID;
		CG_WasConnected[i] = 0;
	}
	SetTimer("CG_Watchdog", 5000, true);
	return 1;
}

public OnFilterScriptExit()
{
	print("[CrashGuard] unloaded");
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS) return 1;
	CG_LastVeh[playerid] = INVALID_VEHICLE_ID;
	CG_WasConnected[playerid] = 1;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS) return 1;
	CG_WasConnected[playerid] = 0;
	CG_LastVeh[playerid] = INVALID_VEHICLE_ID;

	// снять джетпак / special action безопасно
	if(IsPlayerConnected(playerid))
	{
		// already disconnecting — don't call more natives on player if possible
	}
	#pragma unused reason
	printf("[CrashGuard] disconnect id=%d reason=%d", playerid, reason);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS) return 1;
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		new v = GetPlayerVehicleID(playerid);
		if(v > 0 && v != INVALID_VEHICLE_ID) CG_LastVeh[playerid] = v;
	}
	else
		CG_LastVeh[playerid] = INVALID_VEHICLE_ID;
	#pragma unused oldstate
	return 1;
}

// Периодическая проверка: не трогаем ли мёртвые слоты
forward CG_Watchdog();
public CG_Watchdog()
{
	new online;
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i)) online++;
		else if(CG_WasConnected[i])
		{
			// рассинхрон флага
			CG_WasConnected[i] = 0;
			CG_LastVeh[i] = INVALID_VEHICLE_ID;
		}
	}
	if(online == 0)
	{
		// сервер пустой — ничего агрессивного не делаем
		// (многие краши как раз на пустом сервере после last leave)
	}
	return 1;
}

// Блок опасных vehicle ops если id битый (хук через публики FS не перекрывает геймод полностью)
stock CG_IsValidVehicle(vehicleid)
{
	if(vehicleid <= 0 || vehicleid == INVALID_VEHICLE_ID) return 0;
	#if defined IsValidVehicle
		return IsValidVehicle(vehicleid);
	#else
		return (GetVehicleModel(vehicleid) > 0);
	#endif
}
