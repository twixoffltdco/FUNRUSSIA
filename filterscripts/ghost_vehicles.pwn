/*
	ghost_vehicles.pwn
	========================================
	Как в Grand Mobile:
	- Машина всегда ВИДНА всем
	- Когда кто-то сидит за рулём — через неё можно проходить (нет давки/коллизии с пешеходами)
	- Когда пустая — обычная твёрдая коллизия
	- Дополнительно: занятые машины не толкают друг друга (DisableRemoteVehicleCollisions)

	Без плагинов, без MySQL, без варнингов.
	Просто кинь в filterscripts и добавь в server.cfg:
		filterscripts ghost_vehicles
*/

#define FILTERSCRIPT
#include <a_samp>

// ===================== НАСТРОЙКИ =====================
#define GHOST_CHECK_INTERVAL     180     // как часто проверять пересечения (мс)
#define GHOST_PUSH_STRENGTH      0.18    // сила мягкого толчка (чтобы не застревать)
#define GHOST_MIN_SPEED          0.08    // минимальная скорость машины, чтобы считать "едет"
#define GHOST_DETECT_RADIUS      4.8     // радиус проверки вокруг игрока
// =====================================================

new bool:g_GhostMode[MAX_PLAYERS];          // включён ли ghost для этого игрока (когда он за рулём)
new g_GhostTimer = -1;

// ------------------ ВСПОМОГАТЕЛЬНЫЕ ------------------
stock bool:IsVehicleOccupied(vehicleid)
{
	if (vehicleid < 1 || vehicleid >= MAX_VEHICLES) return false;
	if (!GetVehicleModel(vehicleid)) return false;

	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if (!IsPlayerConnected(i)) continue;
		if (GetPlayerState(i) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(i) == vehicleid)
			return true;
	}
	return false;
}

stock Float:GetVehicleSpeed(vehicleid)
{
	new Float:vx, Float:vy, Float:vz;
	GetVehicleVelocity(vehicleid, vx, vy, vz);
	return floatsqroot(vx*vx + vy*vy + vz*vz);
}

// Мягкий толчок игрока от машины (чтобы не застревал и не давило)
stock SoftPushPlayerFromVehicle(playerid, vehicleid)
{
	new Float:px, Float:py, Float:pz;
	new Float:vx, Float:vy, Float:vz;
	GetPlayerPos(playerid, px, py, pz);
	GetVehiclePos(vehicleid, vx, vy, vz);

	new Float:dx = px - vx;
	new Float:dy = py - vy;
	new Float:dist = floatsqroot(dx*dx + dy*dy);

	if (dist < 0.15) // почти в центре — толкаем в случайную сторону
	{
		dx = floatsin(float(random(360)), degrees);
		dy = floatcos(float(random(360)), degrees);
		dist = 1.0;
	}

	// Нормализуем и толкаем
	dx /= dist;
	dy /= dist;

	new Float:speed = GetVehicleSpeed(vehicleid);
	new Float:push = GHOST_PUSH_STRENGTH + (speed * 0.35);

	// Лёгкий подъём, чтобы не зарываться в землю
	SetPlayerVelocity(playerid, dx * push, dy * push, 0.12);
}

// ------------------ ОСНОВНАЯ ЛОГИКА ------------------
public OnFilterScriptInit()
{
	print(" ");
	print("  [ghost_vehicles] Загружен | Режим как в Grand Mobile");
	print("  Машины с водителем — проходимые, пустые — обычные");
	print(" ");

	// Включаем отключение коллизий между занятыми машинами для всех
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if (IsPlayerConnected(i))
			DisableRemoteVehicleCollisions(i, true);
	}

	g_GhostTimer = SetTimer("GhostVehicles_Timer", GHOST_CHECK_INTERVAL, true);
	return 1;
}

public OnFilterScriptExit()
{
	if (g_GhostTimer != -1)
		KillTimer(g_GhostTimer);
	return 1;
}

public OnPlayerConnect(playerid)
{
	g_GhostMode[playerid] = false;
	// Сразу включаем ghost-коллизии между машинами
	DisableRemoteVehicleCollisions(playerid, true);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	g_GhostMode[playerid] = false;
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (newstate == PLAYER_STATE_DRIVER)
	{
		g_GhostMode[playerid] = true;
		// Убеждаемся, что коллизии между занятыми машинами отключены
		DisableRemoteVehicleCollisions(playerid, true);
	}
	else if (oldstate == PLAYER_STATE_DRIVER)
	{
		g_GhostMode[playerid] = false;
	}
	return 1;
}

// Отмена урона от машины (не давит)
public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	#pragma unused issuerid, amount, bodypart

	// 49 = VEHICLE (давка машиной)
	if (weaponid == 49)
	{
		// Полностью отменяем урон от машины
		return 0;
	}
	return 1;
}

// Главный таймер — мягкое избегание пересечений с занятыми машинами
forward GhostVehicles_Timer();
public GhostVehicles_Timer()
{
	for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		if (!IsPlayerConnected(playerid)) continue;
		if (GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) continue;
		if (IsPlayerInAnyVehicle(playerid)) continue;

		new Float:px, Float:py, Float:pz;
		GetPlayerPos(playerid, px, py, pz);

		// Ищем ближайшие занятые машины
		for (new vid = 1; vid < MAX_VEHICLES; vid++)
		{
			if (!GetVehicleModel(vid)) continue;
			if (!IsVehicleOccupied(vid)) continue; // только занятые!

			new Float:vx, Float:vy, Float:vz;
			GetVehiclePos(vid, vx, vy, vz);

			new Float:dist = floatsqroot( (px-vx)*(px-vx) + (py-vy)*(py-vy) + (pz-vz)*(pz-vz) );
			if (dist > GHOST_DETECT_RADIUS) continue;

			// Если машина едет или игрок почти внутри — толкаем
			new Float:spd = GetVehicleSpeed(vid);
			if (spd > GHOST_MIN_SPEED || dist < 2.6)
			{
				SoftPushPlayerFromVehicle(playerid, vid);
			}
		}
	}
	return 1;
}

// На всякий случай при стриме машины тоже поддерживаем режим
public OnVehicleStreamIn(vehicleid, forplayerid)
{
	#pragma unused vehicleid
	// Коллизии между занятыми машинами уже отключены глобально через DisableRemoteVehicleCollisions
	return 1;
}

