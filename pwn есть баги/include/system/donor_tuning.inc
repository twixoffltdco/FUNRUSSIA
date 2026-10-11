#if defined _donor_tuning_included
    #endinput
#endif
#define _donor_tuning_included

// Tuning system ported from the donor "mode (6)" archive.
// Storage is adapted to ULTIMATE's ownable_cars schema; the GUI protocol,
// catalogue ids, prices and shop split remain donor-compatible.

new bool:gDonorTuningStyling[MAX_PLAYERS];

new const DonorTuningVinylNames[][] = {
    "remapbody8", "remapbody5", "remapbody32", "remapbody40", "remapbody21", "remapbody29",
    "remapbody41", "remapbody6", "remapbody31", "remapbody19", "remapbody28", "remapbody30",
    "remapbody11", "remapbody12", "remapbody15", "remapbody26", "remapbody16", "remapbody13",
    "remapbody18", "remapbody35", "remapbody10", "remapbody17", "remapbody38", "remapbody2",
    "remapbody23", "remapbody36", "remapbody4", "remapbody14", "remapbody37", "remapbody20",
    "remapbody7", "remapbody25", "remapbody39", "remapbody1", "remapbody33", "remapbody9",
    "remapbody22", "remapbody24", "remapbody34", "remapbody42", "remapbody47", "remapbody48",
    "remapbody43", "remapbody44", "remapbody49", "remapbody51", "remapbody45", "remapbody46",
    "remaphbody1", "remaphbody2", "remaphbody3", "remaphbody4", "remaphbody5", "remaphbody6",
    "remaphbody7", "remaphbody8", "remaphbody9", "remaphbody10", "remaphbody11", "remapnbody1",
    "remapnbody2", "remapnbody3", "remapnbody4", "remapnbody5", "remapnbody6", "remapnbody7",
    "remapnbody8", "remapnbody9", "remapnbody10", "remapnbody11", "remapnbody12", "remapnbody13",
    "remapnbody14", "remapnbody15", "remapnbody16", "remapnbody17", "remapmbody1", "remapmbody2",
    "remapmbody3", "remapmbody4", "remapmbody5", "remapmbody6", "remapmbody7", "remapmbody8",
    "remapmbody9", "remapmbody10", "remapmbody11", "remapmbody12", "remapmbody13", "remapmbody14",
    "remapmbody15", "remapmbody16", "remapmbody17", "", "", "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "remapnbody18", "remapnbody19", "remapnbody20", "remapnbody21",
    "remapnbody22", "remapnbody23", "remapnbody24", "remapnbody25", "remapnbody26", "remapnbody27"
};

stock DonorTuning_GetIndex(playerid, vehicleid)
{
    if(vehicleid == 0 || vehicleid == INVALID_VEHICLE_ID) return -1;
    if(!Styling_CanEdit(playerid, vehicleid)) return -1;
    new index = GetVehicleData(vehicleid, V_ACTION_ID);
    if(index < 0 || index >= MAX_OWNABLE_CARS) return -1;
    return index;
}

stock DonorTuning_BodyCost(price) return (price / 100) + 10000;
stock DonorTuning_UniversalCost(price) return (price / 100) + 50000;
stock DonorTuning_FarLightCost(price) return (price / 1000) + 10000;
stock DonorTuning_DoubleCost(price) return ((price / 100) + 10000) * 2;
stock DonorTuning_ExtraCost(price) return (price / 100) + 20000;
stock DonorTuning_DonateCost(price) return (((price / 100) + 50000) * 3) / 1000;

stock DonorTuning_FirmwareCost(price, line)
{
    new Float:percent, added;
    switch(line)
    {
        case FSTATE_COMFORT:    { percent = 4.0;   added = 15000; }
        case FSTATE_SPORT:      { percent = 7.0;   added = 15000; }
        case FSTATE_DRIFT:      { percent = 5.0;   added = 15000; }
        case FSTATE_SPORT_PLUS: { percent = 0.005; added = 20; }
        default: return 0;
    }
    return floatround((float(price) * percent / 100.0) + float(added));
}

stock DonorTuning_NitroCost(price, nitro)
{
    new Float:percent;
    switch(nitro)
    {
        case 0: percent = 2.0;
        case 1: percent = 5.0;
        case 2: percent = 7.0;
        default: return 0;
    }
    return floatround((float(price) * percent / 100.0) + 15000.0);
}

stock DonorTuning_SendFailure(playerid, JSON:response, type)
{
    JSON_SetInt(response, "t", type);
    JSON_SetInt(response, "s", 0);
    JSON_SetInt(response, "m", GetPlayerMoneyEx(playerid));
    ShowNotificationNew(playerid, 3, 5, 0, 0, "Недостаточно средств, деталь уже установлена или недоступна", "OK");
    return 1;
}

stock DonorTuning_SendSuccess(playerid)
{
    ShowNotificationNew(playerid, 2, 6, 0, 0, "Покупка успешно установлена", "OK");
    return 1;
}

stock DonorTuning_Open(playerid, shop)
{
    new vehicleid = GetPlayerVehicleID(playerid);
    new index = DonorTuning_GetIndex(playerid, vehicleid);
    if(index == -1) return SendClientMessage(playerid, -1, "{FF0000}You must be driving your own vehicle.");

    new model = GetVehicleData(vehicleid, V_MODELID);
    new JSON:tuning = JSON_Object();
    new model_name[32];
    GetVehicleModelName(model, model_name);

    gDonorTuningStyling[playerid] = (shop != 3);
    switch(shop)
    {
        case 0: SetPlayerData(playerid, P_LAST_TUNING, 0);
        case 2: SetPlayerData(playerid, P_LAST_TUNING, 2);
        case 3: SetPlayerData(playerid, P_LAST_TUNING, 3);
    }

    JSON_SetInt(tuning, "o", 1);
    JSON_SetInt(tuning, "w", shop);
    JSON_SetInt(tuning, "j", GetVehiclePriceByModel(model));
    JSON_SetInt(tuning, "s", model);
    JSON_SetString(tuning, "nm", GetPlayerNameEx(playerid));
    JSON_SetString(tuning, "n", model_name);
    JSON_SetInt(tuning, "m", GetPlayerMoneyEx(playerid));

    new world = vehicleid + 1000;
    SetPlayerVirtualWorld(playerid, world);
    SetVehicleVirtualWorld(vehicleid, world);
    SetPlayerInterior(playerid, 1);
    LinkVehicleToInterior(vehicleid, 1);

    switch(shop)
    {
        case 0:
        {
            SetVehiclePos(vehicleid, 1000.0, 1500.0, 1498.0);
            SetVehicleZAngle(vehicleid, 180.0);
            SetPlayerCameraPos(playerid, 1003.9196, 1493.9724, 1499.7500);
            SetPlayerCameraLookAt(playerid, 1003.3480, 1494.7935, 1499.5002);
        }
        case 2:
        {
            SetVehiclePos(vehicleid, 995.7154, 1000.5235, 1500.1683);
            SetVehicleZAngle(vehicleid, 180.0);
            SetPlayerCameraPos(playerid, 999.1838, 995.9953, 1501.7263);
            SetPlayerCameraLookAt(playerid, 998.5103, 996.7333, 1501.5776);
        }
        case 3:
        {
            SetVehiclePos(vehicleid, 996.1070, 999.4791, 1000.5);
            SetVehicleZAngle(vehicleid, -90.0);
            SetPlayerCameraPos(playerid, 1001.1626, 1002.8044, 1000.9689);
            SetPlayerCameraLookAt(playerid, 1000.3796, 1002.1858, 1001.0136);

            new JSON:installed = JSON_Array();
            new part_ids[] = {4,5,6,7,9,10,11,12,14,15,16,17,19,20,21,22,24,25,26,27};
            new E_OWNABLE_CAR_STRUCT:slots[] = {
                OC_COMFORT_PL, OC_SPORT, OC_DRIFT, OC_SPORT_PL,
                OC_COMFORT1, OC_SPORT1, OC_DRIFT1, OC_SPORT_PL1,
                OC_COMFORT2, OC_SPORT2, OC_DRIFT2, OC_SPORT_PL2,
                OC_COMFORT3, OC_SPORT3, OC_DRIFT3, OC_SPORT_PL3,
                OC_COMFORT4, OC_SPORT4, OC_DRIFT4, OC_SPORT_PL4
            };
            for(new i; i < sizeof part_ids; i++)
            {
                if(!GetOwnableCarData(index, slots[i])) continue;
                installed = JSON_Append(installed, JSON_Array(JSON_Int(part_ids[i])));
                installed = JSON_Append(installed, JSON_Array(JSON_Int(2)));
            }
            if(GetOwnableCarData(index, OC_NITRO) >= 1 && GetOwnableCarData(index, OC_NITRO) <= 3)
            {
                installed = JSON_Append(installed, JSON_Array(JSON_Int(GetOwnableCarData(index, OC_NITRO) - 1)));
                installed = JSON_Append(installed, JSON_Array(JSON_Int(2)));
            }
            JSON_SetArray(tuning, "k", installed);
        }
    }

    OnPacketIncoming(playerid, 28, tuning);
    JSON_Cleanup(tuning);
    return 1;
}

CMD:tungui(playerid, params[]) return DonorTuning_Open(playerid, 0);
CMD:shinka(playerid, params[]) return DonorTuning_Open(playerid, 2);
CMD:techcentergui(playerid, params[]) return DonorTuning_Open(playerid, 3);

stock DonorTuning_TryOpenAtLocation(playerid)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 0;
    if(IsPlayerInRangeOfPoint(playerid, 5.0, -426.235290, 1005.412658, 12.307508) ||
       IsPlayerInRangeOfPoint(playerid, 5.0, -420.054534, 1005.409240, 12.307003) ||
       IsPlayerInRangeOfPoint(playerid, 5.0, -413.549285, 1005.543029, 12.326748))
        return DonorTuning_Open(playerid, 3);

    if(IsPlayerInRangeOfPoint(playerid, 5.0, 2311.993896, -2607.235107, 21.829063) ||
       IsPlayerInRangeOfPoint(playerid, 5.0, 2311.326416, -2613.377685, 21.829063) ||
       IsPlayerInRangeOfPoint(playerid, 5.0, 2311.343261, -2619.453125, 21.829063))
        return DonorTuning_Open(playerid, 0);

    if(IsPlayerInRangeOfPoint(playerid, 5.0, 1728.810302, 2462.126220, 14.979245) ||
       IsPlayerInRangeOfPoint(playerid, 5.0, 1729.730712, 2457.556396, 14.979245) ||
       IsPlayerInRangeOfPoint(playerid, 5.0, 1730.881835, 2452.856689, 14.979245))
        return DonorTuning_Open(playerid, 2);
    return 0;
}

stock DonorTuning_SetFirmware(playerid, firmware_state)
{
    new vehicleid = GetPlayerVehicleID(playerid);
    new index = DonorTuning_GetIndex(playerid, vehicleid);
    if(index == -1) return 0;
    if(firmware_state != FSTATE_NONE && !CheckFirmwareLine(index, firmware_state))
        return SendClientMessage(playerid, -1, "{FF0000}The complete five-part firmware kit is not installed.");

    vInfo[index][vFstate] = firmware_state;
    vInfo[vehicleid][vFstate] = firmware_state;
    SetOwnableCarData(index, OC_FSTATE, firmware_state);
    new query[96];
    mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET f_state=%d WHERE id=%d", firmware_state, GetOwnableCarData(index, OC_SQL_ID));
    mysql_tquery(mysql, query);
    TechCenter_ApplyPerformance(vehicleid);
    return 1;
}

CMD:comforton(playerid, params[]) return DonorTuning_SetFirmware(playerid, FSTATE_COMFORT);
CMD:sporton(playerid, params[]) return DonorTuning_SetFirmware(playerid, FSTATE_SPORT);
CMD:sportpluson(playerid, params[]) return DonorTuning_SetFirmware(playerid, FSTATE_SPORT_PLUS);
CMD:drifton(playerid, params[]) return DonorTuning_SetFirmware(playerid, FSTATE_DRIFT);
CMD:comfortoff(playerid, params[]) return DonorTuning_SetFirmware(playerid, FSTATE_NONE);
CMD:sportoff(playerid, params[]) return DonorTuning_SetFirmware(playerid, FSTATE_NONE);
CMD:sportplusoff(playerid, params[]) return DonorTuning_SetFirmware(playerid, FSTATE_NONE);
CMD:driftoff(playerid, params[]) return DonorTuning_SetFirmware(playerid, FSTATE_NONE);
CMD:tuningoff(playerid, params[]) return DonorTuning_SetFirmware(playerid, FSTATE_NONE);

stock DonorTuning_BuyFirmwarePart(playerid, vehicleid, index, item)
{
    new firmware_state = TechCenter_GetFirmwareLineByItem(item);
    if(firmware_state == FSTATE_NONE) return 0;

    new E_OWNABLE_CAR_STRUCT:slot;
    new field[20];
    switch(item)
    {
        case 4:  { slot = OC_COMFORT_PL; format(field, sizeof field, "comfort"); }
        case 5:  { slot = OC_SPORT;      format(field, sizeof field, "sport"); }
        case 6:  { slot = OC_DRIFT;      format(field, sizeof field, "drift"); }
        case 7:  { slot = OC_SPORT_PL;   format(field, sizeof field, "sport_plus"); }
        case 9:  { slot = OC_COMFORT1;   format(field, sizeof field, "comfort1"); }
        case 10: { slot = OC_SPORT1;     format(field, sizeof field, "sport1"); }
        case 11: { slot = OC_DRIFT1;     format(field, sizeof field, "drift1"); }
        case 12: { slot = OC_SPORT_PL1;  format(field, sizeof field, "sport_plus1"); }
        case 14: { slot = OC_COMFORT2;   format(field, sizeof field, "comfort2"); }
        case 15: { slot = OC_SPORT2;     format(field, sizeof field, "sport2"); }
        case 16: { slot = OC_DRIFT2;     format(field, sizeof field, "drift2"); }
        case 17: { slot = OC_SPORT_PL2;  format(field, sizeof field, "sport_plus2"); }
        case 19: { slot = OC_COMFORT3;   format(field, sizeof field, "comfort3"); }
        case 20: { slot = OC_SPORT3;     format(field, sizeof field, "sport3"); }
        case 21: { slot = OC_DRIFT3;     format(field, sizeof field, "drift3"); }
        case 22: { slot = OC_SPORT_PL3;  format(field, sizeof field, "sport_plus3"); }
        case 24: { slot = OC_COMFORT4;   format(field, sizeof field, "comfort4"); }
        case 25: { slot = OC_SPORT4;     format(field, sizeof field, "sport4"); }
        case 26: { slot = OC_DRIFT4;     format(field, sizeof field, "drift4"); }
        case 27: { slot = OC_SPORT_PL4;  format(field, sizeof field, "sport_plus4"); }
        default: return 0;
    }
    if(GetOwnableCarData(index, slot)) return 0;

    new base = GetVehiclePriceByModel(GetVehicleData(vehicleid, V_MODELID));
    new cost = DonorTuning_FirmwareCost(base, firmware_state);
    if(firmware_state == FSTATE_SPORT_PLUS)
    {
        if(GetPlayerDonateRub(playerid) < cost) return 0;
        GivePlayerDonateRub(playerid, -cost, "Donor tuning firmware", true, true);
    }
    else
    {
        if(GetPlayerMoneyEx(playerid) < cost) return 0;
        GivePlayerMoneyEx(playerid, -cost, "Donor tuning firmware", true, true);
    }

    SetOwnableCarData(index, slot, 1);
    TechCenter_SetFirmwareItemOwned(index, item);
    new query[128];
    mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET `%s`=1 WHERE id=%d", field, GetOwnableCarData(index, OC_SQL_ID));
    mysql_tquery(mysql, query);
    return 1;
}

stock DonorTuning_BuyColor(playerid, vehicleid, index, selector, const text[])
{
    new color;
    if(!ParseTuningColor(text, color)) return 0;
    new length = strlen(text), offset;
    if(text[0] == '#') offset = 1;
    else if(text[0] == '0' && (text[1] == 'x' || text[1] == 'X')) offset = 2;
    if(length - offset == 6) color = (color >>> 8) | 0xFF000000;

    new base = GetVehiclePriceByModel(GetVehicleData(vehicleid, V_MODELID));
    new cost, field[32];
    new E_OWNABLE_CAR_STRUCT:slot;
    switch(selector)
    {
        case 0:  { cost = DonorTuning_BodyCost(base);      format(field, sizeof field, "body_colors"); slot = OC_body_colors; }
        case 1:  { cost = DonorTuning_BodyCost(base);      format(field, sizeof field, "wheel_colors"); slot = OC_wheelcolors; }
        case 3:  { cost = DonorTuning_ExtraCost(base);     format(field, sizeof field, "tonir_ft"); slot = OC_tonir_ft; }
        case 4:  { cost = DonorTuning_ExtraCost(base);     format(field, sizeof field, "tonir_rr"); slot = OC_tonir_rr; }
        case 10: { cost = DonorTuning_DoubleCost(base);    format(field, sizeof field, "lights_color"); slot = OC_lights_color; }
        case 11: { cost = DonorTuning_UniversalCost(base); format(field, sizeof field, "underlights_color"); slot = OC_underlights_color; }
        case 12: { cost = DonorTuning_UniversalCost(base); format(field, sizeof field, "underlights_color_rt"); slot = OC_underlights_color_rt; }
        case 13: { cost = DonorTuning_UniversalCost(base); format(field, sizeof field, "underlights_color_lf"); slot = OC_underlights_color_lf; }
        default: return 0;
    }
    if(GetPlayerMoneyEx(playerid) < cost) return 0;
    GivePlayerMoneyEx(playerid, -cost, "Donor tuning color", true, true);
    SetOwnableCarData(index, slot, color);
    switch(selector)
    {
        case 0: vInfo[index][body_colors] = color;
        case 1: vInfo[index][wheel_colors] = color;
        case 3: vInfo[index][tonir_ft] = color;
        case 4: vInfo[index][tonir_rr] = color;
        case 10: vInfo[index][lights_color] = color;
        case 11: vInfo[index][underlights_color] = color;
        case 12: vInfo[index][underlights_color_rt] = color;
        case 13: vInfo[index][underlights_color_lf] = color;
    }
    new query[160];
    if(selector >= 11 && selector <= 13)
    {
        SetOwnableCarData(index, OC_EnableNeon, 1);
        vInfo[index][vEnableNeon] = 1;
        mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET `%s`=%d,EnableNeon=1 WHERE id=%d", field, color, GetOwnableCarData(index, OC_SQL_ID));
    }
    else mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET `%s`=%d WHERE id=%d", field, color, GetOwnableCarData(index, OC_SQL_ID));
    mysql_tquery(mysql, query);
    ApplyOwnableVehicleColors(vehicleid, index);
    return 1;
}

stock DonorTuning_HandlePacket(playerid, JSON:json, JSON:response)
{
    new type, item, selector, detail_type, vehicleid = GetPlayerVehicleID(playerid);
    new color[32];
    JSON_GetInt(json, "t", type);
    // ULTIMATE's launcher sends the selected catalogue item in "d" and the
    // displayed price in "p". Older donor launchers omit integer "d" and use
    // "p" for the item, so prefer a present integer "d" and retain the fallback.
    if(!JSON_GetInt(json, "d", item)) JSON_GetInt(json, "p", item);
    JSON_GetInt(json, "m", selector);
    JSON_GetInt(json, "mt", detail_type);
    JSON_GetString(json, "d", color, sizeof color);
    JSON_SetInt(response, "s", 0);

    if(type == 0)
    {
        new Float:x, Float:y, Float:z, Float:a;
        switch(GetPlayerData(playerid, P_LAST_TUNING))
        {
            case 2: { x = 1747.741943; y = 2467.266601; z = 14.979245; a = 0.0; }
            case 3: { x = -422.748107; y = 1030.279174; z = 11.246218; a = 0.0; }
            default: { x = 2297.047607; y = -2612.994873; z = 21.829063; a = 0.0; }
        }
        gDonorTuningStyling[playerid] = false;
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerInterior(playerid, 0);
        if(vehicleid != 0 && vehicleid != INVALID_VEHICLE_ID)
        {
            SetVehicleVirtualWorld(vehicleid, 0);
            LinkVehicleToInterior(vehicleid, 0);
            SetVehiclePos(vehicleid, x, y, z);
            SetVehicleZAngle(vehicleid, a);
            PutPlayerInVehicle(playerid, vehicleid, 0);
            SetTimerEx("ReapplyPurchasedVehicleTuning", 500, false, "dd", playerid, vehicleid);
        }
        else SetPlayerPos(playerid, x, y, z);
        TogglePlayerControllable(playerid, 1);
        SetCameraBehindPlayer(playerid);
        return 1;
    }

    new index = DonorTuning_GetIndex(playerid, vehicleid);
    if(index == -1) return DonorTuning_SendFailure(playerid, response, type);
    new base = GetVehiclePriceByModel(GetVehicleData(vehicleid, V_MODELID));
    new success;

    switch(type)
    {
        case 28:
        {
            success = Styling_WheelState(playerid, vehicleid, response);
        }
        case 12:
        {
            success = Styling_BuyWheelSetting(playerid, vehicleid, selector, item);
        }
        case 1,2: success = DonorTuning_BuyColor(playerid, vehicleid, index, selector, color);
        case 3:
        {
            new selected_vinyl[32];
            if(Styling_IsSafeVinylName(g_styling_preview_vinyl[playerid]))
                format(selected_vinyl, sizeof selected_vinyl, "%s", g_styling_preview_vinyl[playerid]);
            else if(item >= 0 && item < sizeof DonorTuningVinylNames && DonorTuningVinylNames[item][0] != EOS)
                format(selected_vinyl, sizeof selected_vinyl, "%s", DonorTuningVinylNames[item]);

            if(selected_vinyl[0] != EOS)
            {
                new cost = DonorTuning_UniversalCost(base);
                if(GetPlayerMoneyEx(playerid) >= cost)
                {
                    // Persist and read back before charging the player. A visual
                    // preview is not proof that the database accepted the change.
                    new query[192];
                    mysql_format(mysql, query, sizeof query,
                        "UPDATE ownable_cars SET vinyl='%e',vynil_name='%e',vinil_current=%d WHERE id=%d LIMIT 1",
                        selected_vinyl, selected_vinyl, item, GetOwnableCarData(index, OC_SQL_ID));
                    mysql_query(mysql, query, false);
                    new save_error = mysql_errno();

                    new verify_query[128], verified_vinyl[32];
                    mysql_format(mysql, verify_query, sizeof verify_query,
                        "SELECT vynil_name FROM ownable_cars WHERE id=%d LIMIT 1",
                        GetOwnableCarData(index, OC_SQL_ID));
                    new Cache:verify_cache = mysql_query(mysql, verify_query, true);
                    new verify_rows = cache_num_rows();
                    if(verify_rows > 0) cache_get_field_content(0, "vynil_name", verified_vinyl, mysql, sizeof verified_vinyl);
                    cache_delete(verify_cache);

                    if(save_error != 0 || verify_rows != 1 || strcmp(verified_vinyl, selected_vinyl, false) != 0)
                    {
                        printf("[DONOR_TUNING][VINYL_DB_ERROR] player=%d car=%d item=%d wanted=%s saved=%s rows=%d errno=%d",
                            playerid, GetOwnableCarData(index, OC_SQL_ID), item, selected_vinyl, verified_vinyl, verify_rows, save_error);
                        return 0;
                    }

                    GivePlayerMoneyEx(playerid, -cost, "Donor tuning vinyl", true, true);
                    format(g_ownable_car[index][OC_VINYL], 32, "%s", selected_vinyl);
                    format(vInfo[index][vynil_name], 32, "%s", selected_vinyl);
                    vInfo[index][vinil_current] = item;
                    format(vInfo[vehicleid][vynil_name], 32, "%s", selected_vinyl);
                    vInfo[vehicleid][vinil_current] = item;
                    SetOwnableCarData(index, OC_vinil_current, item);
                    foreach(new target: Player) if(IsVehicleStreamedIn(vehicleid, target) || GetPlayerVehicleID(target) == vehicleid)
                        SetVehicleVinylForPlayer(target, vehicleid, selected_vinyl);
                    g_styling_preview_vinyl[playerid][0] = EOS;
                    printf("[DONOR_TUNING][VINYL_DB_OK] player=%d car=%d item=%d vinyl=%s",
                        playerid, GetOwnableCarData(index, OC_SQL_ID), item, selected_vinyl);
                    success = 1;
                }
            }
        }
        case 7:
        {
            if(selector == 31)
            {
                success = Styling_BuyDisk(playerid, vehicleid, item);
            }
            else switch(item)
            {
                case 4,5,6,7,9,10,11,12,14,15,16,17,19,20,21,22,24,25,26,27:
                    success = DonorTuning_BuyFirmwarePart(playerid, vehicleid, index, item);
                case 0,1,2:
                {
                    new cost = DonorTuning_NitroCost(base, item);
                    if(GetPlayerMoneyEx(playerid) >= cost && GetOwnableCarData(index, OC_NITRO) != item + 1)
                    {
                        GivePlayerMoneyEx(playerid, -cost, "Donor tuning nitro", true, true);
                        vInfo[index][vNitro] = item + 1;
                        SetOwnableCarData(index, OC_NITRO, item + 1);
                        new query[112];
                        mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET nitro_level=%d WHERE id=%d", item + 1, GetOwnableCarData(index, OC_SQL_ID));
                        mysql_tquery(mysql, query);
                        ApplyOwnableVehicleNitro(playerid, vehicleid, item + 1);
                        success = 1;
                    }
                }
                case 28,29,30,31:
                {
                    new cost = DonorTuning_UniversalCost(base);
                    if(GetPlayerMoneyEx(playerid) >= cost)
                    {
                        GivePlayerMoneyEx(playerid, -cost, "Donor tuning strobe", true, true);
                        vInfo[index][vStrob] = item - 27;
                        vInfo[index][strab_current] = item;
                        SetOwnableCarData(index, OC_STROBOSCOPE, item - 27);
                        SetOwnableCarData(index, OC_strab_current, item);
                        new query[144];
                        mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET stroboscope_type=%d,strab_current=%d WHERE id=%d", item - 27, item, GetOwnableCarData(index, OC_SQL_ID));
                        mysql_tquery(mysql, query);
                        SetVehicleStroboscope(vehicleid, item - 28, 1);
                        success = 1;
                    }
                }
                case 32:
                {
                    new cost = DonorTuning_DonateCost(base);
                    if(GetPlayerDonateRub(playerid) >= cost)
                    {
                        GivePlayerDonateRub(playerid, -cost, "Donor tuning strobe", true, true);
                        vInfo[index][vStrob] = 5;
                        vInfo[index][strab_current] = 32;
                        SetOwnableCarData(index, OC_STROBOSCOPE, 5);
                        SetOwnableCarData(index, OC_strab_current, 32);
                        new query[144];
                        mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET stroboscope_type=5,strab_current=32 WHERE id=%d", GetOwnableCarData(index, OC_SQL_ID));
                        mysql_tquery(mysql, query);
                        SetVehicleStroboscope(vehicleid, 4, 1);
                        success = 1;
                    }
                }
                case 130:
                {
                    new cost = DonorTuning_FarLightCost(base);
                    if(GetPlayerMoneyEx(playerid) >= cost && !GetOwnableCarData(index, OC_isFarLightBought))
                    {
                        GivePlayerMoneyEx(playerid, -cost, "Donor tuning far light", true, true);
                        vInfo[index][IsFarLightBought] = 1;
                        vInfo[index][IsFarLightActive] = 1;
                        SetOwnableCarData(index, OC_isFarLightBought, 1);
                        SetOwnableCarData(index, OC_isFarLightActive, 1);
                        new query[144];
                        mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET is_FarLight_bought=1,is_FarLight_active=1 WHERE id=%d", GetOwnableCarData(index, OC_SQL_ID));
                        mysql_tquery(mysql, query);
                        SetVehicleFarLight(playerid, vehicleid, 1);
                        success = 1;
                    }
                }
            }
        }
        case 5:
        {
            new database_id = GetOwnableCarData(index, OC_SQL_ID);
            if(detail_type == -1)
            {
                success = ResetOwnableCarSelectorToStock(playerid, vehicleid, index, selector, database_id);
            }
            else if(detail_type == 4 && selector == 31)
            {
                new wheel_componentid = GetWheelTuneComponentId(GetOwnableCarData(index, OC_wheelcomp));
                if(wheel_componentid > 0)
                    RemoveFromVehicleComponentForPlayer(playerid, vehicleid, wheel_componentid);
                SetOwnableCarData(index, OC_wheelcomp, 0);
                vInfo[index][wheel_comp] = 0;
                new query[112];
                mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET wheel_comp=0 WHERE id=%d", database_id);
                mysql_query(mysql, query, false);
                PermanentTuning_RebuildVehicleState(vehicleid);
                Styling_ScheduleWheelShopReapply(vehicleid);
                success = 1;
            }
        }
        case 25,26:
        {
            new vinyl[32];
            JSON_GetString(json, "v", vinyl, sizeof vinyl);
            if(Styling_IsSafeVinylName(vinyl))
            {
                format(g_styling_preview_vinyl[playerid], 32, "%s", vinyl);
                SetVehicleVinylForPlayer(playerid, vehicleid, vinyl);
                success = 1;
            }
        }
    }

    JSON_SetInt(response, "t", type);
    JSON_SetInt(response, "s", success);
    JSON_SetInt(response, "p", item);
    JSON_SetInt(response, "m", GetPlayerMoneyEx(playerid));
    JSON_SetInt(response, "r", GetPlayerMoneyEx(playerid));
    if(success && type != 28 && type != 25 && type != 26) DonorTuning_SendSuccess(playerid);
    else if(!success && type != 28) DonorTuning_SendFailure(playerid, response, type);
    return 1;
}
