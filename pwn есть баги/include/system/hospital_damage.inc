stock bool:Hospital_IsUsableSpawnSkin(skinid)
{
    // Model 413 is confirmed missing in this client build ("Can't find skin Model Info Id 413").
    // Do not change the account skin here: hospital spawn must never corrupt/save a fallback.
    if(skinid == 413) return false;
    return (skinid >= 0);
}

stock GetPlayerHospitalSpawnSkin(playerid)
{
    // Prefer the skin that is actually rendered on the player before the hospital
    // respawn. P_SKIN can contain a stale/internal id while the live ped is valid.
    if(GetPlayerState(playerid) != PLAYER_STATE_NONE)
    {
        new live_skin = GetPlayerSkin(playerid);
        if(Hospital_IsUsableSpawnSkin(live_skin))
        {
            SetPVarInt(playerid, "hospital_spawn_skin", live_skin + 1);
            return live_skin;
        }
    }

    // SpawnPlayer temporarily puts the player in NONE state, so keep the last
    // working live model across that transition. +1 lets model 0 be stored too.
    new saved_skin = GetPVarInt(playerid, "hospital_spawn_skin") - 1;
    if(saved_skin >= 0 && Hospital_IsUsableSpawnSkin(saved_skin))
        return saved_skin;

    new account_skin = GetPlayerSkinEx(playerid);
    if(Hospital_IsUsableSpawnSkin(account_skin))
    {
        SetPVarInt(playerid, "hospital_spawn_skin", account_skin + 1);
        return account_skin;
    }

    // Last-resort hospital-only fallback. Never write it to P_SKIN/database.
    new fallback_skin = reg_skin_data[GetPlayerSex(playerid)][0];
    SetPVarInt(playerid, "hospital_spawn_skin", fallback_skin + 1);
    printf("[HOSPITAL][SKIN] invalid account skin=%d player=%d, temporary fallback=%d", account_skin, playerid, fallback_skin);
    return fallback_skin;
}

stock SetPlayerHospitalSpawnInit(playerid)
{
    // Reuse the same room for every duplicate spawn callback belonging to this
    // death.  Randomising it again is what made the player appear to die/spawn
    // twice and could leave the Android client between two interior loads.
    new room = GetPVarInt(playerid, "hospital_spawn_room") - 1;
    if(room < 0 || room >= sizeof g_hospital_death_spawn)
    {
        room = random(sizeof g_hospital_death_spawn);
        SetPVarInt(playerid, "hospital_spawn_room", room + 1);
    }

    // Spawn directly at the selected bed. The old exterior bootstrap could
    // become the final position when a mobile client missed OnPlayerSpawn.
    SetPlayerInterior(playerid, 1);
    SetPlayerVirtualWorld(playerid, 1);
    SetSpawnInfo
    (
        playerid,
        0,
        GetPlayerHospitalSpawnSkin(playerid),
        g_hospital_death_spawn[room][0],
        g_hospital_death_spawn[room][1],
        g_hospital_death_spawn[room][2],
        g_hospital_death_spawn[room][3],
        0, 0, 0, 0, 0, 0
    );
    return 1;
}

stock HospitalSetPlayerPosition(playerid, room)
{
    if(room < 0 || room >= sizeof g_hospital_death_spawn) return 0;

    // Use the exact same transition order as the normal working hospital
    // teleport: position -> interior -> virtual world.  The old hotfix used
    // VW -> position -> interior, which can leave the mobile client at the
    // correct coordinates while the custom hospital itself is not loaded.
    // The mobile client loads this custom map only on a real interior change.
    // Keep the same order as the working hospital entrance: position, interior, VW.
    SetPlayerPos(playerid,
        g_hospital_death_spawn[room][0],
        g_hospital_death_spawn[room][1],
        g_hospital_death_spawn[room][2]);
    SetPlayerFacingAngle(playerid, g_hospital_death_spawn[room][3]);
    SetPlayerInterior(playerid, 1);
    SetPlayerVirtualWorld(playerid, 1);
    SetCameraBehindPlayer(playerid);
    Streamer_Update(playerid);
    SetPlayerHealthEx(playerid, 30.0);
    return 1;
}

stock HospitalPrimeInterior(playerid)
{
    // This is the same destination used by the regular hospital entrance.
    // Priming the custom interior here before moving to a bed gives Android
    // clients one streaming frame to load the hospital map.
    SetPlayerPos(playerid, 1501.540039, 2489.010986, 2501.000000);
    SetPlayerFacingAngle(playerid, 360.0);
    SetPlayerInterior(playerid, 1);
    SetPlayerVirtualWorld(playerid, 1);
    SetCameraBehindPlayer(playerid);
    Streamer_Update(playerid);
    SetPlayerHealthEx(playerid, 30.0);
    return 1;
}

// Extra reconnect watchdog for the rare mobile case where SpawnPlayer() is
// accepted by the server but the client remains in PLAYER_STATE_NONE or a late
// auth/spawn callback resets Interior/VW. This runs only for hospital reconnects.
forward HospitalLoginSpawnGuard(playerid, token, session, pass);
public HospitalLoginSpawnGuard(playerid, token, session, pass)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(mysql_race[playerid] != session) return 1;
    if(!GetPlayerData(playerid, P_HOSPITAL)) return 1;
    if(GetPVarInt(playerid, "hospital_spawn_token") != token) return 1;

    new room = GetPVarInt(playerid, "hospital_spawn_room") - 1;
    if(room < 0 || room >= sizeof g_hospital_death_spawn)
    {
        SetPlayerHospitalSpawnInit(playerid);
        room = GetPVarInt(playerid, "hospital_spawn_room") - 1;
    }

    if(GetPlayerState(playerid) == PLAYER_STATE_NONE)
    {
        // The login screen can visually finish while the mobile client has not
        // completed the actual player spawn. Retry the same hospital spawn.
        SetPlayerHospitalSpawnInit(playerid);
        SpawnPlayer(playerid);
    }
    else
    {
        new bool:wrong_world = (GetPlayerInterior(playerid) != 1 || GetPlayerVirtualWorld(playerid) != 1);
        new bool:wrong_pos = !IsPlayerInRangeOfPoint(playerid, 180.0, 1484.458862, 2494.261474, 2501.000000);

        if(wrong_world || wrong_pos)
        {
            // Re-prime instead of only changing VW: on affected Android clients
            // the map itself may still be missing even at correct coordinates.
            TogglePlayerControllable(playerid, false);
            HospitalPrimeInterior(playerid);
            SetTimerEx("HospitalSpawnLateRoom", 700, false, "iiii", playerid, room, token, session);
        }
        else
        {
            SetPlayerInterior(playerid, 1);
            SetPlayerVirtualWorld(playerid, 1);
            Streamer_Update(playerid);
            SetPlayerHealthEx(playerid, 30.0);
        }
    }

    // Three login-only passes cover slow emulators/phones without creating a
    // permanent timer. The normal hospital late guard continues afterwards.
    if(pass < 3)
    {
        SetTimerEx("HospitalLoginSpawnGuard", 3200, false, "iiii", playerid, token, session, pass + 1);
    }
    return 1;
}

forward HospitalSpawnSync(playerid, room, token, session, stage);
public HospitalSpawnSync(playerid, room, token, session, stage)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(mysql_race[playerid] != session) return 1;
    if(!GetPlayerData(playerid, P_HOSPITAL)) return 1;
    if(room < 0 || room >= sizeof g_hospital_death_spawn) return 1;
    if(GetPVarInt(playerid, "hospital_spawn_token") != token) return 1;

    // Some Android clients need substantially longer than one second to load
    // the custom hospital. Keep the player frozen and prime the known-good
    // entrance twice before moving to the bed room.
    switch(stage)
    {
        case 1:
        {
            HospitalPrimeInterior(playerid);
            SetTimerEx("HospitalSpawnSync", 900, false, "iiiii", playerid, room, token, session, 2);
        }
        case 2:
        {
            HospitalSetPlayerPosition(playerid, room);
            SetTimerEx("HospitalSpawnSync", 1400, false, "iiiii", playerid, room, token, session, 3);
        }
        default:
        {
            HospitalSetPlayerPosition(playerid, room);
            SetPVarInt(playerid, "hospital_spawn_state", 2);
            TogglePlayerControllable(playerid, true);

            // Hospital login bypasses the normal spawn selector, so open the
            // admin PIN only after the hospital transition has fully finished.
            SRAdmin_OpenAfterSpawnSelection(playerid);

            // Catch late teleports/VW resets from other spawn systems.
            SetTimerEx("HospitalSpawnLateGuard", 2500, false, "iiiii", playerid, room, token, session, 1);
        }
    }
    return 1;
}

forward HospitalSpawnLateGuard(playerid, room, token, session, pass);
public HospitalSpawnLateGuard(playerid, room, token, session, pass)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(mysql_race[playerid] != session) return 1;
    if(!GetPlayerData(playerid, P_HOSPITAL)) return 1;
    if(room < 0 || room >= sizeof g_hospital_death_spawn) return 1;
    if(GetPVarInt(playerid, "hospital_spawn_token") != token) return 1;

    new bool:wrong_world = (GetPlayerInterior(playerid) != 1 || GetPlayerVirtualWorld(playerid) != 1);
    new bool:wrong_pos = !IsPlayerInRangeOfPoint(playerid, 180.0, 1484.458862, 2494.261474, 2501.000000);

    if(wrong_world || wrong_pos)
    {
        TogglePlayerControllable(playerid, false);
        HospitalPrimeInterior(playerid);
        SetTimerEx("HospitalSpawnLateRoom", 700, false, "iiii", playerid, room, token, session);
    }
    else
    {
        // Even when coordinates are correct, resend Interior/VW and force one
        // more streamer refresh for clients that were slow to finish loading.
        SetPlayerInterior(playerid, 1);
        SetPlayerVirtualWorld(playerid, 1);
        Streamer_Update(playerid);
    }

    // Keep a few finite late passes: on slower Android/emulator clients a
    // delayed auth/spawn helper can still reset Interior/VW several seconds
    // after the first successful room load.
    if(pass < 4)
    {
        SetTimerEx("HospitalSpawnLateGuard", 3000, false, "iiiii", playerid, room, token, session, pass + 1);
    }
    return 1;
}

forward HospitalSpawnLateRoom(playerid, room, token, session);
public HospitalSpawnLateRoom(playerid, room, token, session)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(mysql_race[playerid] != session) return 1;
    if(!GetPlayerData(playerid, P_HOSPITAL)) return 1;
    if(room < 0 || room >= sizeof g_hospital_death_spawn) return 1;
    if(GetPVarInt(playerid, "hospital_spawn_token") != token) return 1;

    HospitalSetPlayerPosition(playerid, room);
    SetPVarInt(playerid, "hospital_spawn_state", 2);
    TogglePlayerControllable(playerid, true);
    return 1;
}

stock ApplyPlayerHospitalSpawn(playerid)
{
    // Reapply only a hospital-safe/resolved model. This is isolated from the
    // normal skin inventory/account logic and never persists a fallback.
    SetPlayerSkin(playerid, GetPlayerHospitalSpawnSkin(playerid));

    new room = GetPVarInt(playerid, "hospital_spawn_room") - 1;
    if(room < 0 || room >= sizeof g_hospital_death_spawn)
    {
        room = random(sizeof g_hospital_death_spawn);
        SetPVarInt(playerid, "hospital_spawn_room", room + 1);
    }

    new hospital_state = GetPVarInt(playerid, "hospital_spawn_state");
    if(hospital_state != 0)
    {
        // A duplicate OnPlayerSpawn may reset interior/VW back to 0. Reapply
        // the same room; if loading is still in progress keep the player frozen.
        HospitalSetPlayerPosition(playerid, room);
        TogglePlayerControllable(playerid, hospital_state == 2);
        return 1;
    }

    // SpawnInfo already targets this exact room. Reapply its interior/world
    // immediately in case the client reset either value during SpawnPlayer.
    SetPVarInt(playerid, "hospital_spawn_state", 2);
    TogglePlayerControllable(playerid, false);
    SetPlayerInterior(playerid, 1);
    SetPlayerVirtualWorld(playerid, 1);
    HospitalSetPlayerPosition(playerid, room);
    Streamer_Update(playerid);
    TogglePlayerControllable(playerid, true);

    new token = GetPVarInt(playerid, "hospital_spawn_token");
    if(token <= 0)
    {
        token = 1;
        SetPVarInt(playerid, "hospital_spawn_token", token);
    }
    SetTimerEx("HospitalSpawnLateGuard", 1800, false, "iiiii", playerid, room, token, mysql_race[playerid], 1);
    return 1;
}

stock Float:GetServerPlayerDamage(weaponid, Float:reported_damage)
{
    // Значения синхронизированы с m_fWeaponDamages мобильного клиента.
    switch(weaponid)
    {
        case 0 .. 15:
        {
            if(reported_damage > 5.0 && reported_damage <= 25.0) return reported_damage;
            return 5.0;
        }
        case 16: return 75.0;
        case 18: return 75.0;
        case 22: return 25.0;
        case 23: return 10.0;
        case 24: return 45.0;
        case 25: return 40.0;
        case 26 .. 31: return 10.0;
        case 32: return 20.0;
        case 33, 34: return 45.0;
        case 35, 36: return 75.0;
        case 37: return 5.0;
        case 38: return 70.0;
        case 39: return 75.0;
        case 41: return 1.0;
        case 42: return 5.0;
    }

    if(reported_damage < 0.0) return 0.0;
    if(reported_damage > 75.0) return 75.0;
    return reported_damage;
}

forward HospitalDeathPositionGuard(playerid, token, session, pass);
public HospitalDeathPositionGuard(playerid, token, session, pass)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(mysql_race[playerid] != session) return 1;
    if(!GetPlayerData(playerid, P_HOSPITAL)) return 1;
    if(GetPVarInt(playerid, "hospital_spawn_token") != token) return 1;

    // Keep enforcing the selected hospital room after SpawnPlayer. This also
    // catches late client-side resets of the interior or virtual world.
    if(GetPlayerState(playerid) != PLAYER_STATE_NONE)
    {
        new room = GetPVarInt(playerid, "hospital_spawn_room") - 1;
        if(room < 0 || room >= sizeof g_hospital_death_spawn)
        {
            SetPlayerHospitalSpawnInit(playerid);
            room = GetPVarInt(playerid, "hospital_spawn_room") - 1;
        }
        HospitalSetPlayerPosition(playerid, room);
        SetPVarInt(playerid, "hospital_spawn_state", 2);
        TogglePlayerControllable(playerid, true);
    }

    if(pass < 3)
        SetTimerEx("HospitalDeathPositionGuard", 700, false, "iiii", playerid, token, session, pass + 1);
    return 1;
}

forward HospitalDeathRespawn(playerid, token, session);
public HospitalDeathRespawn(playerid, token, session)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(mysql_race[playerid] != session) return 1;
    if(!GetPlayerData(playerid, P_HOSPITAL)) return 1;
    if(GetPVarInt(playerid, "hospital_spawn_token") != token) return 1;

    // После повторной смерти координаты/интерьер всё ещё принадлежат старому
    // (уже мёртвому) ped. Нельзя считать это успешным больничным спавном:
    // без SpawnPlayer клиент может остаться со старым мёртвым ped. Каждая
    // смерть создаёт новый ped сразу внутри выбранной палаты, после
    // чего OnPlayerSpawn переносит его в выбранную палату.
    SetPlayerHospitalSpawnInit(playerid);
    SpawnPlayer(playerid);
    SetTimerEx("HospitalDeathPositionGuard", 120, false, "iiii", playerid, token, session, 1);
    return 1;
}

new g_admin_health_sync_token[MAX_PLAYERS];

forward AdminHealthSync(playerid, token, session);
public AdminHealthSync(playerid, token, session)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(mysql_race[playerid] != session) return 1;
    if(g_admin_health_sync_token[playerid] != token) return 1;

    new Float:health = GetPlayerHealthEx(playerid);
    if(health < 0.0) health = 0.0;
    if(health > 100.0) health = 100.0;
    SetPlayerHealth(playerid, health);
    return 1;
}

stock SetAdminPlayerHealth(playerid, health)
{
    new Float:value = float(health);
    SetPlayerData(playerid, P_HEALTH, value);

    // Delayed confirmations keep the mobile client HUD in sync with the server value.
    new token = ++g_admin_health_sync_token[playerid];
    SetPlayerHealth(playerid, value);
    SetTimerEx("AdminHealthSync", 100, false, "iii", playerid, token, mysql_race[playerid]);
    SetTimerEx("AdminHealthSync", 500, false, "iii", playerid, token, mysql_race[playerid]);
    return 1;
}

// V11: authoritative health replay for the mobile client.
// The custom damage path blocks the stock GiveTakeDamage handling, so some
// clients keep their local HP at the pre-hit value until a later sync/death.
new g_damage_health_sync_token[MAX_PLAYERS];

forward DamageHealthResync(playerid, token, race);
public DamageHealthResync(playerid, token, race)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(mysql_race[playerid] != race) return 0;
    if(g_damage_health_sync_token[playerid] != token) return 0;
    if(!IsPlayerLogged(playerid)) return 0;

    new Float:hp = GetPlayerHealthEx(playerid);
    if(hp <= 0.0) return 0; // death is handled by the normal V9/V10 path
    if(hp > 100.0) hp = 100.0;

    SetPlayerHealth(playerid, hp);
    return 1;
}

stock DamageHealthScheduleResync(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;

    new token = ++g_damage_health_sync_token[playerid];
    if(token <= 0)
    {
        token = 1;
        g_damage_health_sync_token[playerid] = token;
    }

    SetTimerEx("DamageHealthResync", 70, false, "iii", playerid, token, mysql_race[playerid]);
    SetTimerEx("DamageHealthResync", 220, false, "iii", playerid, token, mysql_race[playerid]);
    return 1;
}

// One physical hit can reach the mode through RPC 115 and then once more
// through OnPlayerTakeDamage (or through two copies of the same mobile RPC).
// Filter only an extremely short identical replay, so normal automatic fire
// and consecutive melee attacks continue to deal damage.
new g_damage_apply_tick[MAX_PLAYERS];
new g_damage_apply_issuer[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};
new g_damage_apply_weapon[MAX_PLAYERS];
new Float:g_damage_apply_amount[MAX_PLAYERS];

stock bool:DamageApply_IsDuplicate(playerid, issuerid, weaponid, Float:reported_damage)
{
    new now = GetTickCount();
    new elapsed = now - g_damage_apply_tick[playerid];
    if(elapsed >= 0 && elapsed <= 80 &&
       g_damage_apply_issuer[playerid] == issuerid &&
       g_damage_apply_weapon[playerid] == weaponid &&
       floatabs(g_damage_apply_amount[playerid] - reported_damage) < 0.01)
    {
        return true;
    }

    g_damage_apply_tick[playerid] = now;
    g_damage_apply_issuer[playerid] = issuerid;
    g_damage_apply_weapon[playerid] = weaponid;
    g_damage_apply_amount[playerid] = reported_damage;
    return false;
}

stock ApplyServerPlayerDamage(playerid, issuerid, Float:reported_damage, weaponid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(issuerid == INVALID_PLAYER_ID || issuerid < 0 || issuerid >= MAX_PLAYERS || !IsPlayerConnected(issuerid)) return 0;
    if(playerid == issuerid || GetPVarInt(playerid, "agm")) return 0;
    if(reported_damage <= 0.0) return 0;
	if(DamageApply_IsDuplicate(playerid, issuerid, weaponid, reported_damage)) return 1;

    new Float:damage = GetServerPlayerDamage(weaponid, reported_damage);
    if(damage <= 0.0) return 0;

    new Float:armour;
    GetPlayerArmour(playerid, armour);

    if(armour > 0.0)
    {
        if(armour >= damage)
        {
            SetPlayerArmour(playerid, armour - damage);
            // Client may already have changed its local health bar. Keep server HP authoritative.
            SetPlayerHealth(playerid, GetPlayerHealthEx(playerid));
            return 1;
        }
        damage -= armour;
        SetPlayerArmour(playerid, 0.0);
    }

    new Float:health = GetPlayerHealthEx(playerid);
    health -= damage;
    if(health < 0.0) health = 0.0;

    // Keep exact kill credit before forcing HP to zero. SetPlayerHealth() does
    // not carry issuerid/weaponid into OnPlayerDeath on every mobile client.
    if(health <= 0.0)
    {
        SetPVarInt(playerid, "server_death_killer", issuerid + 1);
        SetPVarInt(playerid, "server_death_weapon", weaponid);
        SetPVarInt(playerid, "server_death_tick", GetTickCount());
    }

    SetPlayerHealthEx(playerid, health);
    if(health > 0.0) DamageHealthScheduleResync(playerid);
    return 1;
}

// RPC 115 (GiveTakeDamage) is the authoritative player-vs-player damage source.
// true = TakeDamage report, false = GiveDamage report. We apply GiveDamage only
// so the same hit is never counted twice when both clients report it.
new g_damage_rpc_tick[MAX_PLAYERS];
new g_damage_rpc_target[MAX_PLAYERS];
new g_damage_rpc_weapon[MAX_PLAYERS];
new g_damage_rpc_bodypart[MAX_PLAYERS];
new g_damage_rpc_source[MAX_PLAYERS];
new Float:g_damage_rpc_amount[MAX_PLAYERS];

stock DamageRpc_ResetPlayer(playerid)
{
    g_damage_rpc_tick[playerid] = 0;
    g_damage_rpc_target[playerid] = INVALID_PLAYER_ID;
    g_damage_rpc_weapon[playerid] = -1;
    g_damage_rpc_bodypart[playerid] = -1;
    g_damage_rpc_source[playerid] = 0;
    g_damage_rpc_amount[playerid] = 0.0;
	g_damage_apply_tick[playerid] = 0;
	g_damage_apply_issuer[playerid] = INVALID_PLAYER_ID;
	g_damage_apply_weapon[playerid] = -1;
	g_damage_apply_amount[playerid] = 0.0;
    return 1;
}

stock bool:DamageRpc_IsImmediateDuplicate(playerid, targetid, weaponid, bodypart, Float:damage, source)
{
    new now = GetTickCount();
    new elapsed = now - g_damage_rpc_tick[playerid];
    if(g_damage_rpc_target[playerid] == targetid &&
       g_damage_rpc_weapon[playerid] == weaponid &&
       g_damage_rpc_bodypart[playerid] == bodypart &&
       floatabs(g_damage_rpc_amount[playerid] - damage) < 0.01 &&
       elapsed >= 0 &&
       ((g_damage_rpc_source[playerid] != source && elapsed <= 300) ||
        (g_damage_rpc_source[playerid] == source && elapsed <= 80)))
    {
        return true;
    }

    g_damage_rpc_tick[playerid] = now;
    g_damage_rpc_target[playerid] = targetid;
    g_damage_rpc_weapon[playerid] = weaponid;
    g_damage_rpc_bodypart[playerid] = bodypart;
    g_damage_rpc_amount[playerid] = damage;
    g_damage_rpc_source[playerid] = source;
    return false;
}

stock DamageRpc_Handle115(playerid, bool:take_damage, targetid, Float:damage, weaponid, bodypart, source)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;

    // The victim also reports TakeDamage. Ignore that side and trust the shooter's GiveDamage
    // to avoid applying one hit twice.
    if(take_damage) return 1;

    if(targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid)) return 0;
    if(targetid == playerid) return 0;
    if(damage <= 0.0) return 0;
    if(weaponid < 0 || weaponid > 54) return 0;
    if(bodypart < 0 || bodypart > 9) bodypart = 3;

    // Protect against the same RPC being delivered through both native RakNet and packet 252.
    if(DamageRpc_IsImmediateDuplicate(playerid, targetid, weaponid, bodypart, damage, source)) return 1;

    return HandleServerTakeDamage(targetid, playerid, damage, weaponid, bodypart);
}

stock bool:MedBed_IsPlayerInHospitalArea(playerid)
{
    if(IsPlayerInRangeOfPoint(playerid, 150.0, 1484.458862, 2494.261474, 2501.000000)) return true;
    if(IsPlayerInRangeOfPoint(playerid, 70.0, 2035.7643, 1416.3625, 999.7344)) return true;
    if(FsinFull_IsPlayerInLazaret(playerid)) return true;
    return false;
}

stock GetNearestMedBed(playerid, Float:range = 2.7)
{
    for(new i; i < sizeof g_med_bed_pos; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, range, g_med_bed_pos[i][0], g_med_bed_pos[i][1], g_med_bed_pos[i][2])) return i;
    }
    return -1;
}

stock bool:IsMedBedDynamicArea(areaid)
{
    return (
        areaid == koika1 || areaid == koika2 || areaid == koika3 || areaid == koika4 ||
        areaid == koika5 || areaid == koika6 || areaid == koika7 || areaid == koika8 ||
        areaid == koika9 || areaid == koika10 || areaid == koika11 || areaid == koika12 ||
        areaid == koika13 || areaid == koika14 || areaid == koika15 || areaid == koika16 ||
        areaid == koika17 || areaid == koika18 || areaid == koika19 || areaid == koika20 ||
        areaid == koika21 || areaid == koika22 || areaid == koika23 || areaid == koika24 ||
        areaid == koika25 || areaid == koika26 || areaid == koika27 || areaid == koika28 ||
        areaid == koika29 || areaid == koika30 || areaid == koika31 || areaid == koika32 ||
        FsinFull_IsLazaretBedArea(areaid)
    );
}

stock ClearMedBed(playerid, bedid)
{
    if(!(0 <= bedid < sizeof g_med_bed_used)) return 0;

    if(GetPlayerData(playerid, P_OCCUPIED_BED) != -1)
    {
        SetPlayerData(playerid, P_OCCUPIED_BED, -1);
    }

    g_med_bed_used[bedid] = false;
    UpdateMedBed(bedid);
    return 1;
}

stock UpdateMedBed(bedid)
{
    if(!(0 <= bedid < sizeof g_med_bed_used)) return 0;
    new fmt_text[220];
    format(fmt_text, sizeof fmt_text,
        "{ffff00}« Свободная больничная койка »\n\n{ffff00}|{ffffff}Номер койки: {ffff00}%d\n{ffff00}|{ffffff}Пациент: {ffff00}отсутствует\n\n{ffffff}Подойдите ближе для взаимодействия",
        bedid + 1);
    UpdateDynamic3DTextLabelText(g_med_bed_label[bedid], 0xFFFFFFEE, fmt_text);
    return 1;
}

stock MedBed_TryOccupy(playerid, bedid = -1)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    // Уже лежит на койке: ничего не показываем и не создаём повторное взаимодействие.
    if(GetPlayerData(playerid, P_OCCUPIED_BED) != -1) return 1;
    if(!MedBed_IsPlayerInHospitalArea(playerid)) return 1;

    if(bedid < 0 || bedid >= sizeof g_med_bed_pos ||
       !IsPlayerInRangeOfPoint(playerid, 2.8, g_med_bed_pos[bedid][0], g_med_bed_pos[bedid][1], g_med_bed_pos[bedid][2]))
    {
        bedid = GetNearestMedBed(playerid, 2.8);
    }
    if(bedid == -1) return 1;

    if(GetPlayerHealthEx(playerid) >= 95.0)
        return SendClientMessage(playerid, 0xCECECEFF, "Вы не нуждаетесь в лечении");
    if(g_med_bed_used[bedid])
        return SendClientMessage(playerid, 0xCECECEFF, "Эта койка занята");

    SetPlayerData(playerid, P_OCCUPIED_BED, bedid);
    g_med_bed_used[bedid] = true;

    new fmt_msg[220];
    format(fmt_msg, sizeof fmt_msg,
        "{ffff00}« Занятая больничная койка »\n\n{ffff00}|{ffffff}Номер койки: {ffff00}%d\n{ffffff}Пациент: {ffff00}%s",
        bedid + 1, GetPlayerNameEx(playerid));
    UpdateDynamic3DTextLabelText(g_med_bed_label[bedid], 0xFFFFFFFF, fmt_msg);

    format(fmt_msg, sizeof fmt_msg,
        "Вы заняли койку №%d. В зависимости от состояния здоровья лечение может занять время", bedid + 1);
    SendClientMessage(playerid, 0x32a44bFF, fmt_msg);
    SendClientMessage(playerid, -1, "Чтобы выписаться подойдите к врачу или выйдите за пределы больницы");

    // Перезаписываем интерактивный notify обычным коротким сообщением без кнопки.
    ShowNotificationNew(playerid, 3, 2, 0, 0, "Вы заняли больничную койку", "");
    return 1;
}

public: HospitalTreatment()
{
    for(new playerid; playerid < MAX_PLAYERS; playerid++)
    {
        if(!IsPlayerConnected(playerid)) continue;
        else if(!IsPlayerLogged(playerid)) continue;
        else if(GetPlayerData(playerid, P_OCCUPIED_BED) == -1) continue;
        if(!MedBed_IsPlayerInHospitalArea(playerid))
        {
            ClearMedBed(playerid, GetPlayerData(playerid, P_OCCUPIED_BED));
        }
					else
        {
            new Float:health = GetPlayerHealthEx(playerid);
            if(health >= 100.0) // Проверка на максимальное здоровье
            {
                SendClientMessage(playerid, 0x32a44bFF, "Лечение завершено! Вы полностью здоровы.");
                ClearMedBed(playerid, GetPlayerData(playerid, P_OCCUPIED_BED));
            }
					else
            {
                // Добавляем здоровье с ограничением до 100.0
                new Float:newhealth = health + 3.0;
                if(newhealth > 100.0) newhealth = 100.0;
                
                GameTextForPlayer(playerid, "~g~~h~~h~+ 3 HP", 1000, 4);
                SetPlayerChatBubble(playerid, "+3 hp", 0x33CC33FF, 5.0, 1000);
                SetPlayerHealthEx(playerid, newhealth);
            }
        }
    }
    SetTimer("HospitalTreatment", (random(5) + 1) * 1000, false);
    return 1;
}



