#if defined _LIRIPAWN_FUEL_SYSTEM_INC
    #endinput
#endif
#define _LIRIPAWN_FUEL_SYSTEM_INC

#if !defined PACKET_CUSTOMRPC
    #define PACKET_CUSTOMRPC 252
#endif

#if !defined RPC_CUSTOM_SET_FUEL
    #define RPC_CUSTOM_SET_FUEL 0x25
#endif

#define FUEL_MAX_LITERS   (150.0)
#define FUEL_INTERACT_DIST (35.0)
#define FUEL_TYPE_AI92    (0)
#define FUEL_TYPE_AI95    (1)
#define FUEL_TYPE_AI98    (2)
#define FUEL_TYPE_AI100   (3)
#define FUEL_TYPE_DT      (4)
#define FUEL_TYPE_ELECTRO (5)

forward SetVehicleSpeedometerInfo(vehicleid, Float:fuel = 52.0, Float:mileage = 1488.0);
forward SetVehicleSpeedometerInfoFP(playerid, vehicleid, Float:fuel = 52.0, Float:mileage = 1488.0);
forward OnPacketIncoming(playerid, guiid, Node:json);
#include "../include/auth_brpro.inc"
forward SaveOwnableCarFuel(vehicleid);
forward ShowNotificationNew(playerid, type, duration, id, subId, caption[], btnCaption[]);
forward Fuel_ShowGui(playerid);

stock Float:Fuel_ClampValue(Float:value)
{
    if(_:value != _:value) return 0.0;
    if(value < 0.0) return 0.0;
    if(value > FUEL_MAX_LITERS) return FUEL_MAX_LITERS;
    return value;
}

stock bool:Fuel_IsPedalVehicleModel(modelid)
{
    switch(modelid)
    {
        case 481, 509, 510:
            return true;
    }
    return false;
}

stock Fuel_GetNearbyStation(playerid)
{
    new stationid = GetNearestFuelStation(playerid, FUEL_INTERACT_DIST);
    if(stationid == -1 && IsPlayerInRangeOfPoint(playerid, 12.0, 2642.489990, 2587.287597, 15.633455))
    {
        stationid = GetNearestFuelStation(playerid, 80.0);
    }
    return stationid;
}

stock Fuel_GetVehicleFuelTypeByModel(modelid)
{
    switch(modelid)
    {
        case 401, 404, 412, 421, 434, 438, 439, 448, 458, 479, 491, 492, 496, 529, 536, 542: return FUEL_TYPE_AI92;
        case 545, 547, 549, 555, 567, 573, 585, 597, 612, 616, 644, 646, 647, 652, 675, 682: return FUEL_TYPE_AI92;
        case 739, 743, 745, 746, 747, 749, 753, 758, 760, 762, 767, 769, 2375, 2378, 2379, 2615: return FUEL_TYPE_AI92;
        case 2616, 2629, 2630, 28655, 28658, 28659, 28677, 28681, 28696, 28699, 28700, 28703, 28707, 28711, 28722, 28727: return FUEL_TYPE_AI92;
        case 28729, 28732, 28739, 28745, 28756, 28761, 28762, 28763: return FUEL_TYPE_AI92;

        case 400, 405, 410, 411, 413, 417, 418, 419, 420, 422, 423, 424, 425, 426, 427, 428: return FUEL_TYPE_AI95;
        case 430, 431, 432, 435, 436, 437, 440, 441, 442, 443, 445, 446, 447, 449, 450, 455: return FUEL_TYPE_AI95;
        case 456, 457, 459, 460, 461, 462, 463, 464, 465, 467, 468, 469, 471, 472, 473, 474: return FUEL_TYPE_AI95;
        case 476, 477, 478, 480, 481, 484, 485, 486, 487, 488, 489, 490, 493, 495, 497, 499: return FUEL_TYPE_AI95;
        case 500, 501, 502, 503, 504, 505, 507, 508, 509, 510, 511, 512, 513, 516, 517, 518: return FUEL_TYPE_AI95;
        case 519, 520, 521, 522, 523, 524, 526, 527, 528, 530, 531, 532, 534, 535, 537, 538: return FUEL_TYPE_AI95;
        case 539, 540, 543, 544, 546, 548, 550, 551, 552, 553, 554, 559, 560, 561, 562, 563: return FUEL_TYPE_AI95;
        case 564, 565, 566, 568, 569, 570, 571, 572, 574, 575, 577, 578, 580, 581, 583, 584: return FUEL_TYPE_AI95;
        case 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 598, 599, 600, 602, 603, 604: return FUEL_TYPE_AI95;
        case 605, 606, 607, 608, 609, 610, 611, 613, 614, 615, 617, 618, 619, 620, 621, 622: return FUEL_TYPE_AI95;
        case 625, 626, 627, 628, 629, 630, 631, 633, 634, 635, 636, 637, 638, 639, 640, 641: return FUEL_TYPE_AI95;
        case 642, 649, 650, 651, 653, 654, 655, 656, 658, 660, 673, 674, 678, 681, 741, 744: return FUEL_TYPE_AI95;
        case 750, 751, 754, 759, 761, 763, 764, 768, 770, 771, 2374, 2376, 2380, 2381, 2382, 2383: return FUEL_TYPE_AI95;
        case 2384, 2385, 2390, 2394, 2395, 2396, 2397, 2404, 2405, 2407, 2408, 2546, 2547, 2548, 2549, 2550: return FUEL_TYPE_AI95;
        case 2551, 2552, 2553, 2554, 2555, 2556, 2557, 2558, 2559, 2560, 2561, 2562, 2563, 2564, 2565, 2566: return FUEL_TYPE_AI95;
        case 2567, 2568, 2569, 2570, 2571, 2573, 2574, 2575, 2576, 2577, 2578, 2579, 2580, 2582, 2583, 2584: return FUEL_TYPE_AI95;
        case 2585, 2588, 2589, 2599, 2602, 2604, 2606, 2607, 2608, 2609, 2610, 2611, 2612, 2613, 2614, 2617: return FUEL_TYPE_AI95;
        case 2618, 2620, 2623, 2624, 2625, 2627, 2628, 2631, 2632, 2633, 28656, 28663, 28664, 28665, 28667, 28668: return FUEL_TYPE_AI95;
        case 28670, 28671, 28675, 28678, 28680, 28683, 28684, 28685, 28686, 28687, 28688, 28691, 28692, 28695, 28698, 28702: return FUEL_TYPE_AI95;
        case 28704, 28708, 28709, 28710, 28713, 28714, 28716, 28718, 28726, 28728, 28730, 28737, 28741, 28743, 28746, 28748: return FUEL_TYPE_AI95;
        case 28754, 28758, 28759, 28760, 28764: return FUEL_TYPE_AI95;

        case 402, 409, 429, 451, 466, 475, 506, 533, 541, 558, 576, 579, 596, 624, 632, 643: return FUEL_TYPE_AI98;
        case 648, 657, 661, 672, 679, 680, 740, 742, 748, 752, 755, 756, 757, 765, 766, 772: return FUEL_TYPE_AI98;
        case 2371, 2372, 2377, 2387, 2388, 2389, 2398, 2400, 2401, 2403, 2409, 2545, 2586, 2591, 2592, 2593: return FUEL_TYPE_AI98;
        case 2594, 2595, 2596, 2597, 2598, 2600, 2601, 2603, 2605, 2619, 2626, 28654, 28657, 28661, 28662, 28669: return FUEL_TYPE_AI98;
        case 28672, 28673, 28674, 28676, 28682, 28689, 28697, 28701, 28705, 28706, 28717, 28720, 28721, 28723, 28724, 28733: return FUEL_TYPE_AI98;
        case 28734, 28735, 28736, 28738, 28740, 28742, 28744, 28747, 28749, 28750, 28752, 28755, 28757, 28765: return FUEL_TYPE_AI98;

        case 415, 452, 453, 454, 645, 665, 666, 667, 668, 670, 671, 2373, 2386, 2391, 2392, 2393: return FUEL_TYPE_AI100;
        case 2399, 2402, 2406, 28751: return FUEL_TYPE_AI100;

        case 403, 406, 407, 408, 414, 416, 433, 444, 470, 482, 483, 498, 514, 515, 525, 556: return FUEL_TYPE_DT;
        case 557, 582, 601, 623, 2587, 28679, 28690, 28712, 28715, 28725: return FUEL_TYPE_DT;

        case 494, 659, 669, 2543, 2544, 2572, 2581, 2590, 2621, 2622, 28660, 28666, 28693, 28694, 28719, 28731: return FUEL_TYPE_ELECTRO;
        case 28753, 28766: return FUEL_TYPE_ELECTRO;
    }
    return FUEL_TYPE_AI95;
}

stock Fuel_GetTypeName(fuel_type, dest[], size = 16)
{
    switch(fuel_type)
    {
        case FUEL_TYPE_AI92:    format(dest, size, "??-92");
        case FUEL_TYPE_AI95:    format(dest, size, "??-95");
        case FUEL_TYPE_AI98:    format(dest, size, "??-98");
        case FUEL_TYPE_AI100:   format(dest, size, "??-100");
        case FUEL_TYPE_DT:      format(dest, size, "??");
        case FUEL_TYPE_ELECTRO: format(dest, size, "ЭЛЕКТРО");
        default:                format(dest, size, "??-95");
    }
    return 1;
}

stock Fuel_GetGuiHintByType(fuel_type, dest[], size = 64)
{
    new fuel_name[16];
    Fuel_GetTypeName(fuel_type, fuel_name, sizeof(fuel_name));
    format(dest, size, "Рекомендуемый тип топлива: %s", fuel_name);
    return 1;
}

stock bool:Fuel_IsGuiTypeCompatible(selected_type, required_type)
{
    if(required_type == FUEL_TYPE_ELECTRO)
    {
        return (selected_type >= FUEL_TYPE_AI92 && selected_type <= FUEL_TYPE_DT);
    }
    return selected_type == required_type;
}

stock Fuel_GetStationPricePerLiter(stationid, fuel_type)
{
    new base_price = 65;

    if(stationid >= 0 && stationid < g_fuel_station_loaded)
    {
        base_price = GetFuelStationData(stationid, FS_FUEL_PRICE);
        if(base_price < 20)
        {
            base_price = 65;
        }
    }

    switch(fuel_type)
    {
        case FUEL_TYPE_AI92:    return base_price;
        case FUEL_TYPE_AI95:    return base_price + 4;
        case FUEL_TYPE_AI98:    return base_price + 12;
        case FUEL_TYPE_AI100:   return base_price + 20;
        case FUEL_TYPE_DT:      return base_price + 9;
        case FUEL_TYPE_ELECTRO: return base_price + 7;
    }
    return base_price;
}

stock Fuel_CloseGui(playerid)
{
    new Node:close_json = JSON_Object();
    JSON_SetInt(close_json, "c", 1);
    OnPacketIncoming(playerid, GUIFuelFill, close_json);
    JSON_Cleanup(close_json);
    return 1;
}

stock Fuel_SendError(playerid, const message[])
{
    new caption[144], button[8];
    format(caption, sizeof(caption), "%s", message);
    format(button, sizeof(button), "OK");
    SendClientMessage(playerid, 0xCECECEFF, caption);
    ShowNotificationNew(playerid, 3, 6, 0, 0, caption, button);
    return 1;
}

stock Fuel_SendSuccess(playerid, const message[])
{
    new caption[144], button[8];
    format(caption, sizeof(caption), "%s", message);
    format(button, sizeof(button), "OK");
    SendClientMessage(playerid, 0x66CC00FF, caption);
    ShowNotificationNew(playerid, 2, 6, 0, 0, caption, button);
    return 1;
}

stock bool:Fuel_TryOpenGuiOnHorn(playerid)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        return false;
    }

    if(GetPlayerVehicleID(playerid) == INVALID_VEHICLE_ID)
    {
        return false;
    }

    if(Fuel_GetNearbyStation(playerid) == -1)
    {
        return false;
    }

    if(GetPVarInt(playerid, "fuel_horn_gui_cd") > gettime())
    {
        return true;
    }

    SetPVarInt(playerid, "fuel_horn_gui_cd", gettime() + 1);
    Fuel_ShowGui(playerid);
    return true;
}

stock Fuel_ShowGui(playerid)
{
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        return Fuel_SendError(playerid, "Вы должны быть за рулем транспорта");
    }

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == INVALID_VEHICLE_ID)
    {
        return Fuel_SendError(playerid, "Транспорт не найден");
    }

    if(Fuel_IsPedalVehicleModel(GetVehicleModel(vehicleid)))
    {
        return Fuel_SendError(playerid, "Для этого транспорта заправка через интерфейс недоступна");
    }

    new stationid = Fuel_GetNearbyStation(playerid);
    if(stationid == -1)
    {
        return Fuel_SendError(playerid, "Вы не рядом с заправкой");
    }

    if(GetFuelStationData(stationid, FS_LOCK_STATUS))
    {
        return Fuel_SendError(playerid, "Заправочная станция сейчас закрыта");
    }

    new Float:current_fuel = Fuel_ClampValue(GetVehicleData(vehicleid, V_FUEL));
    new free_liters = floatround(FUEL_MAX_LITERS - current_fuel, floatround_floor);
    if(free_liters <= 0)
    {
        return Fuel_SendError(playerid, "Бак уже заполнен");
    }

    new required_type = Fuel_GetVehicleFuelTypeByModel(GetVehicleModel(vehicleid));
    new gui_hint[64];
    new Node:root = JSON_Object();
    new Node:prices = JSON_Array(
        JSON_Int(Fuel_GetStationPricePerLiter(stationid, FUEL_TYPE_AI92)),
        JSON_Int(Fuel_GetStationPricePerLiter(stationid, FUEL_TYPE_AI95)),
        JSON_Int(Fuel_GetStationPricePerLiter(stationid, FUEL_TYPE_AI98)),
        JSON_Int(Fuel_GetStationPricePerLiter(stationid, FUEL_TYPE_AI100)),
        JSON_Int(Fuel_GetStationPricePerLiter(stationid, FUEL_TYPE_DT))
    );

    SetPVarInt(playerid, "fuel_station_id", stationid);
    Fuel_GetGuiHintByType(required_type, gui_hint, sizeof(gui_hint));

    JSON_SetInt(root, "o", 1);
    JSON_SetInt(root, "m", free_liters);
    JSON_SetString(root, "h", gui_hint);
    JSON_SetArray(root, "ma", prices);
    JSON_SetInt(root, "cf", floatround(current_fuel));

    OnPacketIncoming(playerid, GUIFuelFill, root);

    JSON_Cleanup(prices);
    JSON_Cleanup(root);
    return 1;
}

stock Fuel_HandleRefuelCommand(playerid)
{
    return Fuel_ShowGui(playerid);
}

stock bool:Fuel_HandleGuiPacket(playerid, Node:json)
{
    new action = -1000;
    JSON_GetInt(json, "t", action);
    if(action == -1000)
    {
        return false;
    }

    if(action == 1)
    {
        DeletePVar(playerid, "fuel_station_id");
        return true;
    }

    if(action != 0)
    {
        return false;
    }

    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        DeletePVar(playerid, "fuel_station_id");
        Fuel_CloseGui(playerid);
        return true;
    }

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == INVALID_VEHICLE_ID)
    {
        DeletePVar(playerid, "fuel_station_id");
        Fuel_CloseGui(playerid);
        return true;
    }

    new stationid = GetPVarInt(playerid, "fuel_station_id");
    if(stationid < 0 || stationid >= g_fuel_station_loaded)
    {
        DeletePVar(playerid, "fuel_station_id");
        Fuel_CloseGui(playerid);
        return Fuel_SendError(playerid, "Не удалось определить АЗС");
    }

    if(Fuel_GetNearbyStation(playerid) == -1)
    {
        DeletePVar(playerid, "fuel_station_id");
        Fuel_CloseGui(playerid);
        return Fuel_SendError(playerid, "Вы слишком далеко от заправки");
    }

    if(GetFuelStationData(stationid, FS_LOCK_STATUS))
    {
        DeletePVar(playerid, "fuel_station_id");
        Fuel_CloseGui(playerid);
        return Fuel_SendError(playerid, "Заправочная станция сейчас закрыта");
    }

    new fuel_type = FUEL_TYPE_AI95;
    new fuel_amount = 0;
    JSON_GetInt(json, "f", fuel_type);
    JSON_GetInt(json, "v", fuel_amount);

    if(fuel_type < FUEL_TYPE_AI92 || fuel_type > FUEL_TYPE_DT)
    {
        return Fuel_SendError(playerid, "Неверный тип топлива");
    }

    if(fuel_amount <= 0)
    {
        return Fuel_SendError(playerid, "Введите корректный объем топлива");
    }

    new required_type = Fuel_GetVehicleFuelTypeByModel(GetVehicleModel(vehicleid));
    if(!Fuel_IsGuiTypeCompatible(fuel_type, required_type))
    {
        new fuel_name[16], text[96];
        Fuel_GetTypeName(required_type, fuel_name, sizeof(fuel_name));
        format(text, sizeof(text), "Для этого транспорта подходит только %s", fuel_name);
        return Fuel_SendError(playerid, text);
    }

    new Float:current_fuel = Fuel_ClampValue(GetVehicleData(vehicleid, V_FUEL));
    new available_liters = floatround(FUEL_MAX_LITERS - current_fuel, floatround_floor);
    if(available_liters <= 0)
    {
        DeletePVar(playerid, "fuel_station_id");
        Fuel_CloseGui(playerid);
        return Fuel_SendError(playerid, "Бак уже заполнен");
    }

    if(fuel_amount > available_liters)
    {
        fuel_amount = available_liters;
    }

    if(IsFuelStationOwned(stationid) && GetFuelStationData(stationid, FS_FUELS) < fuel_amount)
    {
        return Fuel_SendError(playerid, "На этой АЗС недостаточно топлива");
    }

    new price_per_liter = Fuel_GetStationPricePerLiter(stationid, required_type);
    new total_price = price_per_liter * fuel_amount;
    if(GetPlayerMoneyEx(playerid) < total_price)
    {
        return Fuel_SendError(playerid, "Недостаточно денег для заправки");
    }

    GivePlayerMoneyEx(playerid, -total_price, "Покупка топлива", false, true);

    if(IsFuelStationOwned(stationid))
    {
        new query[160];

        AddFuelStationData(stationid, FS_FUELS, -, fuel_amount);
        AddFuelStationData(stationid, FS_BALANCE, +, total_price);

        mysql_format
        (
            mysql,
            query,
            sizeof(query),
            "UPDATE fuel_stations SET fuels=%d,balance=%d WHERE id=%d LIMIT 1",
            GetFuelStationData(stationid, FS_FUELS),
            GetFuelStationData(stationid, FS_BALANCE),
            GetFuelStationData(stationid, FS_SQL_ID)
        );
        mysql_tquery(mysql, query);
        CallLocalFunction("UpdateFuelStationLabel", "i", stationid);
    }

    new Float:new_fuel = Fuel_ClampValue(current_fuel + float(fuel_amount));
    SetVehicleSpeedometerInfo(vehicleid, new_fuel, GetVehicleData(vehicleid, V_MILEAGE));
    SetVehicleSpeedometerInfoFP(playerid, vehicleid, new_fuel, GetVehicleData(vehicleid, V_MILEAGE));
    if(IsAOwnableCar(vehicleid))
    {
        SaveOwnableCarFuel(vehicleid);
    }

    {
        new fuel_name[16], text[144], spent_text[96];
        Fuel_GetTypeName(required_type, fuel_name, sizeof(fuel_name));
        format(text, sizeof(text), "Вы заправили %d л (%s). В баке: %d л.", fuel_amount, fuel_name, floatround(new_fuel));
        Fuel_SendSuccess(playerid, text);
        format(spent_text, sizeof(spent_text), "Вы потратили %d рублей", total_price);
        ShowNotificationNew(playerid, 2, 6, 0, 0, spent_text, "OK");
    }

    DeletePVar(playerid, "fuel_station_id");
    Fuel_CloseGui(playerid);
    return true;
}

CMD:fuelfill(playerid, params[])
{
    #pragma unused params
    return Fuel_HandleRefuelCommand(playerid);
}

CMD:fueldebug(playerid, params[])
{
    #pragma unused params

    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        return Fuel_SendError(playerid, "Вы должны быть за рулем транспорта");
    }

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == INVALID_VEHICLE_ID)
    {
        return Fuel_SendError(playerid, "Транспорт не найден");
    }

    new text[96];
    format
    (
        text,
        sizeof(text),
        "FuelDebug: %.1f l, mileage %.1f km",
        GetVehicleData(vehicleid, V_FUEL),
        GetVehicleData(vehicleid, V_MILEAGE)
    );
    SendClientMessage(playerid, 0xFFFFFFFF, text);
    return 1;
}
