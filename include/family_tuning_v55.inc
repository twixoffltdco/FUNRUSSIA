// Family-only tuning persistence. No ownable-cache indices are borrowed.
#if defined _family_tuning_v55
    #endinput
#endif
#define _family_tuning_v55

enum E_FT55
{
    FT55_BODY, FT55_WHEEL_COLOR, FT55_TINT_F, FT55_TINT_R, FT55_DISK,
    FT55_OFFSET_F, FT55_OFFSET_R, FT55_ALIGN_F, FT55_ALIGN_R,
    FT55_WIDTH_F, FT55_WIDTH_R, FT55_RADIUS,
    FT55_BRAKE, FT55_HIGHLIGHT, FT55_STROB, FT55_EXHAUST, FT55_HORN,
    FT55_HORN_ACTIVE, FT55_STROB_ACTIVE, FT55_ENGINE, FT55_TURBO, FT55_SUPER,
    FT55_HYDRO_BOUGHT, FT55_FAR_BOUGHT, FT55_PNEVMO_BOUGHT,
    FT55_PT_BRAKE, FT55_PT_STABILITY, FT55_COMFORT, FT55_SPORT,
    FT55_SPORT_PLUS, FT55_DRIFT, FT55_HYDRAULIC, FT55_CASE,
    FT55_TONER_F, FT55_TONER_R
};
new const FT55_Fields[][32] = {
    "body_colors", "wheel_colors", "tonir_ft", "tonir_rr", "wheel_comp",
    "wheel_offset_ft", "wheel_offset_rr", "align_ft", "align_rr",
    "width_ft", "width_rr", "wheel_radius",
    "brake_level", "highlight_type", "stroboscope_type", "exhaust_type", "horn_id",
    "horn_current", "strab_current", "pt_engine", "pt_turbo", "supercharger",
    "is_hydro_bought", "is_FarLight_bought", "is_pnevmo_bought",
    "pt_brake", "pt_stability", "comfort", "sport", "sport_plus", "drift", "hydraulic", "iscase",
    "toner_front", "toner_rear",
    // Legacy string fields must survive the return to the owner unchanged.
    "color_body_r", "color_body_g", "color_wheels", "light_color",
    "neon_center", "neon_left", "neon_right", "vinilcar",
    "EnableNeon", "vinil_current", "exhsuast_current", "max_speed",
    "sport1", "sport2", "sport3", "sport4", "comfort1", "comfort2", "comfort3", "comfort4",
    "drift1", "drift2", "drift3", "drift4", "sport_plus1", "sport_plus2", "sport_plus3", "sport_plus4"
};
new g_FT55[MAX_OWNABLE_CARS][E_FT55];
new bool:g_FT55_New[MAX_OWNABLE_CARS];
new bool:g_FT55_Ready;
new g_FT55_Token[MAX_VEHICLES];

stock bool:FT55_Query(query[])
{
    mysql_query(mysql, query, false);
    if(!mysql_errno()) return true;
    printf("[FAMILY_TUNING][SQL_ERROR] errno=%d", mysql_errno());
    return false;
}

stock bool:FT55_Init()
{
    if(g_FT55_Ready) return true;
    new query[256];
    new Cache:check, valid;
    for(new f; f < sizeof FT55_Fields; f++)
    {
        mysql_format(mysql, query, sizeof query, "SHOW COLUMNS FROM ownable_cars WHERE Field='%e'", FT55_Fields[f]);
        check = mysql_query(mysql, query, true);
        valid = !mysql_errno() && cache_num_rows() == 1;
        cache_delete(check);
        if(!valid) { printf("[FAMILY_TUNING][MISSING_SOURCE_FIELD] %s", FT55_Fields[f]); return false; }
        mysql_format(mysql, query, sizeof query, "SHOW COLUMNS FROM family_cars WHERE Field='%e'", FT55_Fields[f]);
        check = mysql_query(mysql, query, true);
        new err = mysql_errno(), found = cache_num_rows();
        cache_delete(check);
        if(err) return false;
        if(!found)
        {
            // String storage preserves signed/unsigned colors and legacy hex values.
            mysql_format(mysql, query, sizeof query, "ALTER TABLE family_cars ADD `%s` VARCHAR(64) NOT NULL DEFAULT '0'", FT55_Fields[f]);
            if(!FT55_Query(query)) return false;
        }
    }
    check = mysql_query(mysql, "SHOW COLUMNS FROM family_cars WHERE Field='tuning_v55'", true);
    new err = mysql_errno(), found = cache_num_rows();
    cache_delete(check);
    if(err) return false;
    if(!found && !FT55_Query("ALTER TABLE family_cars ADD tuning_v55 INT NOT NULL DEFAULT 0")) return false;
    if(!FT55_Query("CREATE TABLE IF NOT EXISTS family_vehicle_components (vehicleid INT NOT NULL, componentid INT NOT NULL, state INT DEFAULT 0, KEY family_vehicle_id (vehicleid)) ENGINE=InnoDB")) return false;
    check = mysql_query(mysql, "SELECT ENGINE FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='family_vehicle_components'", true);
    new engine[16];
    if(!mysql_errno() && cache_num_rows()) cache_get_field_content(0, "ENGINE", engine, mysql, sizeof engine);
    cache_delete(check);
    if(strcmp(engine, "InnoDB", true)) return false;
    g_FT55_Ready = true;
    return true;
}

stock bool:FT55_CopyFields(source, target, bool:to_family)
{
    new query[4096], part[128];
    if(to_family)
        format(query, sizeof query, "UPDATE family_cars d JOIN ownable_cars s ON s.id=%d SET ", source);
    else
        format(query, sizeof query, "UPDATE ownable_cars d JOIN family_cars s ON s.id=%d SET ", source);
    for(new f; f < sizeof FT55_Fields; f++)
    {
        format(part, sizeof part, "%sd.`%s`=s.`%s`", f ? "," : "", FT55_Fields[f], FT55_Fields[f]);
        if(strlen(query) + strlen(part) + 100 >= sizeof query) return false;
        strcat(query, part);
    }
    if(to_family) strcat(query, ",d.tuning_v55=1");
    format(part, sizeof part, " WHERE d.id=%d", target);
    strcat(query, part);
    return FT55_Query(query);
}

// The existing ownable_cars dump is MyISAM: do not pretend ROLLBACK can undo it.
// Copy first, validate every query, and delete the source only after success.
stock FT55_DiscardCopy(target, bool:to_family)
{
    if(target <= 0) return 0;
    new query[160];
    mysql_format(mysql, query, sizeof query, "DELETE FROM %s WHERE id=%d", to_family ? "family_cars" : "ownable_cars", target);
    if(!FT55_Query(query)) { printf("[FAMILY_TUNING][RECOVERY_REQUIRED] target=%d family=%d", target, to_family); return 0; }
    // Only newly allocated family namespace entries are safe to remove here.
    // Legacy personal component rows can have pre-existing IDs; retain on failure.
    if(to_family)
    {
        mysql_format(mysql, query, sizeof query, "DELETE FROM family_vehicle_components WHERE vehicleid=%d", target);
        FT55_Query(query);
    }
    return 1;
}

stock bool:FT55_CopyComponents(source, target, bool:to_family, bool:modern = true)
{
    if(source <= 0 || target <= 0) return false;
    // A legacy family row shared the personal namespace. Never erase its own source.
    if(!to_family && !modern && source == target) return true;
    new query[320], src[40], dst[40];
    format(src, sizeof src, "%s", to_family || !modern ? "vehicle_store_components" : "family_vehicle_components");
    format(dst, sizeof dst, "%s", to_family ? "family_vehicle_components" : "vehicle_store_components");
    mysql_format(mysql, query, sizeof query, "DELETE FROM `%s` WHERE vehicleid=%d", dst, target);
    if(!FT55_Query(query)) return false;
    mysql_format(mysql, query, sizeof query, "INSERT INTO `%s` (vehicleid,componentid,state) SELECT %d,componentid,state FROM `%s` WHERE vehicleid=%d", dst, target, src, source);
    return FT55_Query(query);
}

stock FT55_ReadCache(index)
{
    if(index < 0 || index >= MAX_OWNABLE_CARS) return 0;
    g_FT55_New[index] = cache_get_field_content_int(0, "tuning_v55") != 0;
    for(new f; f < _:E_FT55; f++)
        g_FT55[index][E_FT55:f] = cache_get_field_content_int(0, FT55_Fields[f]);
    return 1;
}

stock FT55_Percent(stored, fallback)
{
    return stored > 0 ? min(100, max(0, stored - 1)) : fallback;
}

stock FT55_Apply(playerid, vehicleid)
{
    if(!IsPlayerConnected(playerid) || !IsValidVehicle(vehicleid) || !IsAFamilyCar(vehicleid)) return 0;
    new idx = GetVehicleData(vehicleid, V_ACTION_ID);
    if(idx < 0 || idx >= MAX_OWNABLE_CARS || !g_FT55_New[idx]) return 0;
    SetVehicleColorHexForPlayers(playerid, vehicleid, g_FT55[idx][FT55_BODY], g_FT55[idx][FT55_WHEEL_COLOR]);
    SetVehicleColorTonrrHexForPlayers(playerid, vehicleid, g_FT55[idx][FT55_TINT_F], g_FT55[idx][FT55_TINT_R]);
    new bool:wheels;
    for(new f = _:FT55_DISK; f <= _:FT55_RADIUS; f++)
        if(g_FT55[idx][E_FT55:f]) wheels = true;
    if(wheels || GetCarFamily(idx, V_F_PERCENT_CLR) || GetCarFamily(idx, V_F_PERCENT_CLR_Z))
    {
        SetVehicleWheelOffsetForPlayer(playerid, vehicleid, FT55_Percent(g_FT55[idx][FT55_OFFSET_F], 50) / 400.0 - 0.125, FT55_Percent(g_FT55[idx][FT55_OFFSET_R], 50) / 400.0 - 0.125);
        SetVehicleWheelAlignForPlayer(playerid, vehicleid, FT55_Percent(g_FT55[idx][FT55_ALIGN_F], 0) / -200.0, FT55_Percent(g_FT55[idx][FT55_ALIGN_R], 0) / -200.0);
        SetVehicleWheelAddForPlayer(playerid, vehicleid, FT55_Percent(g_FT55[idx][FT55_WIDTH_F], 40) / 80.0 + 0.5, FT55_Percent(g_FT55[idx][FT55_WIDTH_R], 40) / 80.0 + 0.5);
        SetVehicleWheelRadForPlayer(playerid, vehicleid, FT55_Percent(g_FT55[idx][FT55_RADIUS], 75) / 250.0 + 0.7);
    }
    new disk = GetWheelTuneComponentId(g_FT55[idx][FT55_DISK]);
    if(disk > 0) AddToVehicleComponentForPlayer(playerid, vehicleid, disk);
    if(GetCarFamily(idx, V_F_PERCENT_CLR) > 0 && !GetCarFamily(idx, V_F_SELECTED_PNEVMO))
    {
        new Float:height = FT55_Percent(GetCarFamily(idx, V_F_PERCENT_CLR), 50) / 50.0;
        if(height < 0.2) height = 0.2;
        SetVehicleSuspensionBiasForPlayer(playerid, vehicleid, height);
    }
    if(GetCarFamily(idx, V_F_PERCENT_CLR_Z) > 0)
    {
        new Float:bias = FT55_Percent(GetCarFamily(idx, V_F_PERCENT_CLR_Z), 50) / 100.0;
        if(bias < 0.1) bias = 0.1;
        if(bias > 0.9) bias = 0.9;
        SetVehicleSuspensionBiasFor(playerid, vehicleid, bias);
    }
    if(g_FT55[idx][FT55_EXHAUST] > 0) SetVehicleExhaustForPlayer(playerid, vehicleid, g_FT55[idx][FT55_EXHAUST] - 1);
    if(g_FT55[idx][FT55_HORN] > 0 && g_FT55[idx][FT55_HORN_ACTIVE]) SetVehicleHornSoundForPlayer(playerid, vehicleid, g_FT55[idx][FT55_HORN]);
    if(g_FT55[idx][FT55_STROB] > 0 && g_FT55[idx][FT55_STROB_ACTIVE] && EnableStrob[vehicleid])
        SetVehicleStroboscopeForPlayere(playerid, vehicleid, g_FT55[idx][FT55_STROB] - 1);
    FamilyCarApplyVehicleStoreComponents(vehicleid, GetCarFamily(idx, CAR_F_database), playerid);
    return 1;
}

stock FT55_Queue(vehicleid)
{
    if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES || !IsValidVehicle(vehicleid) || !IsAFamilyCar(vehicleid)) return 0;
    new idx = GetVehicleData(vehicleid, V_ACTION_ID);
    if(idx < 0 || idx >= MAX_OWNABLE_CARS || !g_FT55_New[idx]) return 0;
    new token = ++g_FT55_Token[vehicleid];
    SetTimerEx("FT55_Replay", 700, false, "iiii", vehicleid, idx, GetCarFamily(idx, CAR_F_database), token);
    return 1;
}

forward FT55_Replay(vehicleid, idx, sqlid, token);
public FT55_Replay(vehicleid, idx, sqlid, token)
{
    if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES || token != g_FT55_Token[vehicleid]) return 0;
    if(!IsValidVehicle(vehicleid) || !IsAFamilyCar(vehicleid) || GetVehicleData(vehicleid, V_ACTION_ID) != idx) return 0;
    if(idx < 0 || idx >= MAX_OWNABLE_CARS || GetCarFamily(idx, CAR_F_database) != sqlid) return 0;
    foreach(new target: Player)
        if(IsVehicleStreamedIn(vehicleid, target) || GetPlayerVehicleID(target) == vehicleid) ApplyVehicleTuning(target, vehicleid);
    return 1;
}
