#define MAX_AUCTION_SLOT 1024
#define MAX_AUCTION_LIST 256

#define TYPE_BUSINESS         1                
#define TYPE_VEHICLE          2      
#define TYPE_HOUSE            3  
#define TYPE_VEHICLE_NUMBER   4          
#define TYPE_SUM_NUMBER       5      
#define TYPE_CLOTHES          6      

#define AUCTION_WORLD       183
#define DIALOG_AUCTION_MY_SALES 5994
#define DIALOG_AUCTION_CANCEL_CONFIRM 5995
#define DIALOG_AUCTION_SELECT_VEHICLE 5996
#define DIALOG_AUCTION_SELECT_BUSINESS 5997
#define AUCTION_COMMISSION_PERCENT 5
#define AUCTION_BID_STEP_PERCENT 3
#define AUCTION_MIN_BID_STEP 1000
#define AUCTION_BID_HOLD_SECONDS 3600
#define AUCTION_BUSINESS_SOURCE_REGULAR 0
#define AUCTION_BUSINESS_SOURCE_FUEL 1
#define AUCTION_LIST_FUEL_BASE (-10000)

new enter_auction, exit_auction;

new type_slot[7][22] =
{
    {""},
    {"Бизнес"},
    {"Транспортное_средство"},
    {"Недвижимость"},
    {"Номерной_знак"},
    {"Сим-карта"},
    {"Одежда"}
};

new icon_slot[7][17] =
{
    {""},           //  none
    {"txd:braucbiz"},               //   бизнес
    {"txd:brauccar"},               //   транспорт
    {"txd:brauchome"},               //   дом/недвижимость
    {"txd:braucnumber"},            //   т/с номер
    {"txd:braucsimcard"},           //   сим-карта             
    {"txd:brauccloth"}             //   одежда
};

new bool:load_business_action;
new auction_last_free_business_sync;
enum STRUCT_AUCTION_SLOT
{
    SLOT_TYPE, 
    OWNER_SLOT_SQL,
    OWNER_SLOT_NAME[24],
    SLOT_NAME[64],
    OPISANIE_SLOT[124],
    OWNER_RATE,
    START_RATE,
    CURRENT_RATE,
    //TIMER_ID,
    TIMER_END,
    //database and server
    DATABASE_ID,
    SERVER_ID,
    //number vehicle and SUM
    NUMBER_VEHICLE[7],
    NUMBER_SUM,
    AUCTION_DB_ID,
    BUSINESS_TYPE_SLOT,
    BUSINESS_SOURCE_SLOT
}

new auction_slot[MAX_AUCTION_SLOT][STRUCT_AUCTION_SLOT];
new bool:auction_slot_busy[MAX_AUCTION_SLOT];

stock AuctionManager_IsBiddingTime()
{
    return 1;
}

stock AuctionManager_GetTodayFinishTime()
{
    return gettime() + AUCTION_BID_HOLD_SECONDS;
}

stock AuctionManager_GetRemainingHours(ends_at)
{
    new seconds_left = ends_at - gettime();
    if(seconds_left <= 0) return 0;
    return (seconds_left + 3599) / 3600;
}

stock Exchange_Fail(player, player_1, const reason[])
{
    if(IsPlayerConnected(player)) SendClientMessage(player, 0xFF7777FF, reason);
    if(IsPlayerConnected(player_1)) SendClientMessage(player_1, 0xFF7777FF, reason);
    if(IsPlayerConnected(player)) DeleteFullPVarExchange(player);
    if(IsPlayerConnected(player_1)) DeleteFullPVarExchange(player_1);
    return 0;
}

stock Exchange_GetSimpleAsset(playerid, type)
{
    switch(type)
    {
        case E_HOUSE: return GetPlayerHouse(playerid);
        case E_BUSINESS: return GetPlayerBusiness(playerid);
        case E_FUELSTATION: return GetPlayerFuelStation(playerid);
        case E_GARAGE:
            return ExchangeGarage_GetPlayerDbId(playerid);
    }
    return -1;
}

stock Exchange_GetTypeName(type, output[], size)
{
    switch(type)
    {
        case E_HOUSE: format(output, size, "Дом/квартира");
        case E_VEHICLE: format(output, size, "Машина");
        case E_BUSINESS: format(output, size, "Бизнес");
        case E_FUELSTATION: format(output, size, "АЗС");
        case E_GARAGE: format(output, size, "Гараж");
        default: format(output, size, "Имущество");
    }
    return 1;
}

stock Exchange_SelectSimpleAsset(viewerid, ownerid, type, bool:is_other)
{
    new asset_id = Exchange_GetSimpleAsset(ownerid, type), type_name[24], message[144];
    Exchange_GetTypeName(type, type_name, sizeof type_name);
    if(asset_id < 0)
    {
        format(message, sizeof message, is_other ? "У игрока нет имущества типа «%s»." : "У Вас нет имущества типа «%s».", type_name);
        SendClientMessage(viewerid, 0xCECECEFF, message);
        return ShowDialogSelectTypeExchange(viewerid);
    }

    SetPVarInt(ownerid, "select_type_exchange", type);
    SetPVarInt(ownerid, "exchange_asset_id", asset_id);
    format(message, sizeof message, "%s #%d", type_name, asset_id);
    SetPVarString(ownerid, "exchange_asset_name", message);

    if(!is_other)
    {
        SetPVarInt(viewerid, "select_to_player", 1);
        ShowNotificationNew(viewerid, 1, 3, 0, 0, "Выберите имущество игрока", "");
        return ShowDialogSelectTypeExchange(viewerid);
    }

    return Dialog(viewerid, DIALOG_EXCHANGE_SURCHARGE, DIALOG_STYLE_LIST,
        "{E0584B}BR BONUS | {FFFFFF}Предоплата",
        "Без доплаты\nДоплачиваете Вы\nДоплачивает игрок", "Выбрать", "Отмена");
}

stock Exchange_ValidateAsset(playerid, type, asset_id)
{
    new accountid = GetPlayerAccountID(playerid), query[192], Cache:result;
    switch(type)
    {
        case E_HOUSE:
            return 0 <= asset_id < MAX_HOUSES && GetHouseData(asset_id, H_OWNER_ID) == accountid;
        case E_BUSINESS:
            return 0 <= asset_id < g_business_loaded && GetBusinessData(asset_id, B_OWNER_ID) == accountid && !IsBusinessOnAuction(asset_id);
        case E_FUELSTATION:
            return 0 <= asset_id < g_fuel_station_loaded && GetFuelStationData(asset_id, FS_OWNER_ID) == accountid;
        case E_GARAGE:
            return ExchangeGarage_Validate(playerid, asset_id);
        case E_VEHICLE:
        {
            mysql_format(mysql, query, sizeof query, "SELECT id FROM ownable_cars WHERE id=%d AND owner_id=%d LIMIT 1", asset_id, accountid);
            result = mysql_query(mysql, query, true);
            new valid = !mysql_errno() && cache_num_rows() == 1;
            cache_delete(result);
            return valid;
        }
    }
    return 0;
}

stock Exchange_CanReceive(playerid, incoming_type, outgoing_type)
{
    if(incoming_type == outgoing_type) return 1;
    switch(incoming_type)
    {
        case E_HOUSE: return GetPlayerHouse(playerid) == -1;
        case E_BUSINESS:
        {
            new max_business = 1 + GetPlayerData(playerid, P_BUSS_SLOTS);
            if(max_business > 2) max_business = 2;
            return GetPlayerBusinessCount(playerid) < max_business;
        }
        case E_FUELSTATION: return GetPlayerFuelStation(playerid) == -1;
        case E_GARAGE: return GarageSys_GetPlayerGarage(playerid) == -1;
    }
    return 1;
}

stock Exchange_TransferAssetDatabase(type, asset_id, from_account, to_account)
{
    new query[256];
    switch(type)
    {
        case E_VEHICLE:
            mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET owner_id=%d WHERE id=%d AND owner_id=%d LIMIT 1", to_account, asset_id, from_account);
        case E_HOUSE:
            mysql_format(mysql, query, sizeof query, "UPDATE houses SET owner_id=%d WHERE id=%d AND owner_id=%d LIMIT 1", to_account, GetHouseData(asset_id, H_SQL_ID), from_account);
        case E_BUSINESS:
            mysql_format(mysql, query, sizeof query, "UPDATE business SET owner_id=%d WHERE id=%d AND owner_id=%d LIMIT 1", to_account, GetBusinessData(asset_id, B_SQL_ID), from_account);
        case E_FUELSTATION:
            mysql_format(mysql, query, sizeof query, "UPDATE fuel_stations SET owner_id=%d WHERE id=%d AND owner_id=%d LIMIT 1", to_account, GetFuelStationData(asset_id, FS_SQL_ID), from_account);
        case E_GARAGE:
            mysql_format(mysql, query, sizeof query, "UPDATE garages SET owner_id=%d WHERE id=%d AND owner_id=%d LIMIT 1", to_account, asset_id, from_account);
        default: return 0;
    }
    if(!AuctionDatabaseExecuteAffected(query)) return 0;

    switch(type)
    {
        case E_HOUSE:
        {
            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET house=-1,house_type=-1 WHERE id=%d AND house=%d", from_account, asset_id);
            mysql_query(mysql, query, false);
            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET house=%d,house_type=%d WHERE id=%d", asset_id, HOUSE_TYPE_HOME, to_account);
            mysql_query(mysql, query, false);
        }
        case E_BUSINESS:
        {
            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET business=-1 WHERE id=%d AND business=%d", from_account, asset_id);
            mysql_query(mysql, query, false);
            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET business=%d WHERE id=%d", asset_id, to_account);
            mysql_query(mysql, query, false);
        }
        case E_FUELSTATION:
        {
            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET fuel_st=-1 WHERE id=%d AND fuel_st=%d", from_account, asset_id);
            mysql_query(mysql, query, false);
            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET fuel_st=%d WHERE id=%d", asset_id, to_account);
            mysql_query(mysql, query, false);
        }
        case E_GARAGE:
        {
            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET garage=-1 WHERE id=%d AND garage=%d", from_account, asset_id);
            mysql_query(mysql, query, false);
            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET garage=%d WHERE id=%d", asset_id, to_account);
            mysql_query(mysql, query, false);
        }
    }
    return mysql_errno() == 0;
}

stock Exchange_ApplyAssetMemory(type, asset_id, from_player, to_player)
{
    switch(type)
    {
        case E_HOUSE:
        {
            if(GetPlayerHouse(from_player) == asset_id) SetPlayerData(from_player, P_HOUSE, -1), SetPlayerData(from_player, P_HOUSE_TYPE, -1);
            SetPlayerData(to_player, P_HOUSE, asset_id); SetPlayerData(to_player, P_HOUSE_TYPE, HOUSE_TYPE_HOME);
            SetHouseData(asset_id, H_OWNER_ID, GetPlayerAccountID(to_player));
            format(g_house[asset_id][H_OWNER_NAME], 21, "%s", GetPlayerNameEx(to_player)); UpdateHouse(asset_id);
        }
        case E_BUSINESS:
        {
            if(GetPlayerBusiness(from_player) == asset_id) SetPlayerData(from_player, P_BUSINESS, -1);
            SetPlayerData(to_player, P_BUSINESS, asset_id); SetBusinessData(asset_id, B_OWNER_ID, GetPlayerAccountID(to_player));
            format(g_business[asset_id][B_OWNER_NAME], 21, "%s", GetPlayerNameEx(to_player)); UpdateBusinessLabel(asset_id);
        }
        case E_FUELSTATION:
        {
            if(GetPlayerFuelStation(from_player) == asset_id) SetPlayerData(from_player, P_FUEL_ST, -1);
            SetPlayerData(to_player, P_FUEL_ST, asset_id); SetFuelStationData(asset_id, FS_OWNER_ID, GetPlayerAccountID(to_player));
            format(g_fuel_station[asset_id][FS_OWNER_NAME], 21, "%s", GetPlayerNameEx(to_player)); CallLocalFunction("UpdateFuelStationLabel", "i", asset_id);
        }
        case E_GARAGE:
            ExchangeGarage_ApplyMemory(asset_id, from_player, to_player);
        case E_VEHICLE:
        {
            new vehicleid = GetPlayerOwnableCar(from_player);
            if(vehicleid != INVALID_VEHICLE_ID && GetOwnableCarData(GetVehicleData(vehicleid, V_ACTION_ID), OC_SQL_ID) == asset_id)
                UnloadPlayerOwnableCar(from_player);
        }
    }
    return 1;
}

stock AuctionManager_FormatRemainingTime(ends_at, output[], size)
{
    new seconds_left = ends_at - gettime();
    if(seconds_left <= 0) return format(output, size, "0m");
    if(seconds_left > 3540)
        return format(output, size, "1h");
    return format(output, size, "%dm", (seconds_left + 59) / 60);
}

stock AuctionBusiness_IsAuctionable(businessid)
{
    if(businessid < 0 || businessid >= g_business_loaded) return 0;
    if(GetBusinessData(businessid, B_SQL_ID) <= 0) return 0;

    switch(GetBusinessData(businessid, B_TYPE))
    {
        case BUSINESS_TYPE_SHOP_24_7,
             BUSINESS_TYPE_CLUB,
             BUSINESS_TYPE_REALTOR_BIZ,
             BUSINESS_TYPE_REALTOR_HOME,
             BUSINESS_TYPE_CLOTHING_SHOP,
             BUSINESS_TYPE_HOTEL,
             BUSINESS_TYPE_CAR_MARKET,
             BUSINESS_TYPE_CASINO,
             BUSINESS_TYPE_CELL_SALON,
             BUSINESS_TYPE_CAR_TUNING,
             BUSINESS_TYPE_SHOP_GUN,
             BUSINESS_TYPE_LAREK,
             BUSINESS_TYPE_ACCESSORY_SHOP,
             BUSINESS_TYPE_STYLING_CENTER,
             BUSINESS_TYPE_TECH_CENTER,
             BUSINESS_TYPE_TIRE_CENTER:
            return 1;
    }
    return 0;
}

stock BusinessManager_GetTypeName(businessid, output[], size)
{
    switch(GetBusinessData(businessid, B_TYPE))
    {
        case BUSINESS_TYPE_SHOP_24_7: format(output, size, "Магазин 24/7");
        case BUSINESS_TYPE_CLUB: format(output, size, "Клуб");
        case BUSINESS_TYPE_REALTOR_BIZ: format(output, size, "Управление статистики");
        case BUSINESS_TYPE_REALTOR_HOME: format(output, size, "Риелторское агентство");
        case BUSINESS_TYPE_CLOTHING_SHOP: format(output, size, "Магазин одежды");
        case BUSINESS_TYPE_HOTEL: format(output, size, "Отель");
        case BUSINESS_TYPE_CAR_MARKET:
        {
            switch(businessid)
            {
                case 35: format(output, size, "Автосалон низкого класса");
                case 36: format(output, size, "Автосалон высокого класса");
                case 37: format(output, size, "Автосалон среднего класса");
                case STATIC_BIZ_ID_MOTO_SALON: format(output, size, "Мотосалон");
                case STATIC_BIZ_ID_TRUCK_SALON: format(output, size, "Салон грузовых автомобилей");
                default: format(output, size, "Автосалон");
            }
        }
        case BUSINESS_TYPE_CASINO: format(output, size, "Казино");
        case BUSINESS_TYPE_CELL_SALON: format(output, size, "Сотовый салон");
        case BUSINESS_TYPE_CAR_TUNING: format(output, size, "СТО");
        case BUSINESS_TYPE_SHOP_GUN: format(output, size, "Магазин оружия");
        case BUSINESS_TYPE_LAREK: format(output, size, "Ларёк");
        case BUSINESS_TYPE_ACCESSORY_SHOP: format(output, size, "Магазин аксессуаров");
        case BUSINESS_TYPE_STYLING_CENTER: format(output, size, "Стайлинг центр");
        case BUSINESS_TYPE_TECH_CENTER: format(output, size, "Технический центр");
        case BUSINESS_TYPE_TIRE_CENTER: format(output, size, "Шиномонтажный центр");
        default: format(output, size, "Другой бизнес");
    }
    return 1;
}

stock IsBonusCasinoBusiness(businessid)
{
    if(businessid < 0 || businessid >= g_business_loaded)
        return 0;

    if(GetBusinessData(businessid, B_TYPE) != BUSINESS_TYPE_CASINO)
        return 0;

    new Float:delta_x = GetBusinessData(businessid, B_POS_X) - 1333.740600;
    new Float:delta_y = GetBusinessData(businessid, B_POS_Y) - 2372.598632;
    new Float:delta_z = GetBusinessData(businessid, B_POS_Z) - 17.712001;
    return (delta_x * delta_x + delta_y * delta_y + delta_z * delta_z) < 25.0;
}

stock AuctionBusiness_FormatLotName(source, server_id, output[], size)
{
    if(source == AUCTION_BUSINESS_SOURCE_FUEL)
    {
        if(server_id < 0 || server_id >= g_fuel_station_loaded)
            return format(output, size, "АЗС");

        return format(output, size, "АЗС (%d)", server_id);
    }

    if(!AuctionBusiness_IsAuctionable(server_id))
        return format(output, size, "Бизнес");

    new type_name[32];
    BusinessManager_GetTypeName(server_id, type_name, sizeof type_name);
    return format(output, size, "%s (%d)", type_name, IsBonusCasinoBusiness(server_id) ? 30 : server_id);
}

stock BusinessManager_CanSell(playerid, businessid, error[], error_size)
{
    if(!AuctionBusiness_IsAuctionable(businessid))
        return format(error, error_size, "Бизнес не существует или не загружен."), 0;
    if(GetBusinessData(businessid, B_OWNER_ID) != GetPlayerAccountID(playerid))
        return format(error, error_size, "Вы не являетесь владельцем бизнеса."), 0;
    if(IsBusinessOnAuction(businessid))
        return format(error, error_size, "Этот бизнес уже находится на аукционе."), 0;
    if(GetBusinessData(businessid, B_EVICTION))
        return format(error, error_size, "Бизнес находится в процессе изъятия."), 0;
    return 1;
}

stock AuctionBusiness_FindActiveSlot(businessid)
{
    if(!AuctionBusiness_IsAuctionable(businessid)) return -1;

    for(new slot; slot < MAX_AUCTION_SLOT; slot++)
    {
        if(auction_slot[slot][SLOT_TYPE] != TYPE_BUSINESS) continue;
        if(auction_slot[slot][SERVER_ID] == businessid
            || auction_slot[slot][DATABASE_ID] == GetBusinessData(businessid, B_SQL_ID))
            return slot;
    }
    return -1;
}

stock IsBusinessOnAuction(businessid)
{
    return AuctionBusiness_FindActiveSlot(businessid) != -1;
}

stock AuctionBid_GetMinimum(slot)
{
    if(slot < 0 || slot >= MAX_AUCTION_SLOT) return 0;
    new current = auction_slot[slot][CURRENT_RATE];
    if(current < 0 || current > 2000000000 - AUCTION_MIN_BID_STEP) return 0;

    new step = current / 100 * AUCTION_BID_STEP_PERCENT;
    if(step < AUCTION_MIN_BID_STEP) step = AUCTION_MIN_BID_STEP;
    if(current > 2000000000 - step) return 0;
    return current + step;
}
stock AuctionBid_GetActiveLotForAccount(accountid)
{
    if(accountid <= 0) return -1;
    new query[320], Cache:result;
    mysql_format(mysql, query, sizeof query,
        "SELECT ab.auction_id FROM auction_bids ab INNER JOIN auction_lots al ON al.id=ab.auction_id WHERE ab.bidder_account_id=%d AND al.status='active' AND al.ends_at>%d ORDER BY ab.id DESC LIMIT 1",
        accountid, gettime());
    result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        cache_delete(result);
        return -2;
    }
    new auction_id = -1;
    if(cache_num_rows()) auction_id = cache_get_field_content_int(0, "auction_id");
    cache_delete(result);
    return auction_id;
}

new player_cd_auction[MAX_PLAYERS];
new PlayerText:auction_PTD[MAX_PLAYERS][40];

new slot_td[4][3] = //айди тд где информация о слоте
{
    {11, 12, 13},
    {15, 16, 17},
    {19, 20, 21},
    {7, 8, 9}
};

enum STRUCT_AUCTION_PANEL
{
    bool:show_panel,
    count_list,
    select_slot,
    select_type,
    select_tab,
    filter_min_price,
    filter_max_price,
    filter_type,
    filter_tovar_type,
    filter_vehicle_model,
    bool:type_tovar, 
    bool:price_tovar, 
    bool:opisanie_tovar, 
    bool:tovar,
}

stock AuctionDatabaseExecuteAffected(query[])
{
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        cache_delete(result);
        return 0;
    }

    new affected = cache_affected_rows();
    cache_delete(result);
    return affected > 0;
}
stock AuctionBid_ReserveDatabaseUpdate(slot, rate, old_rate, bidder_account_id, bidder_name[], new_ends_at)
{
    if(auction_slot[slot][AUCTION_DB_ID] <= 0) return 1;

    new query[512], Cache:result;
    mysql_format(mysql, query, sizeof query,
        "UPDATE auction_lots SET current_price=%d,highest_bidder_account_id=%d,highest_bidder_name='%e',ends_at=%d WHERE id=%d AND status='active' AND ends_at>%d AND current_price=%d AND highest_bidder_account_id=%d",
        rate, bidder_account_id, bidder_name, new_ends_at, auction_slot[slot][AUCTION_DB_ID], gettime(),
        auction_slot[slot][CURRENT_RATE], old_rate);
    result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        cache_delete(result);
        return 0;
    }

    new affected = cache_affected_rows();
    cache_delete(result);
    return affected == 1;
}
stock AuctionBid_RollbackDatabaseUpdate(slot, rate, bidder_account_id, old_rate, old_bidder_account_id)
{
    if(auction_slot[slot][AUCTION_DB_ID] <= 0) return 1;

    new query[384], Cache:result;
    mysql_format(mysql, query, sizeof query,
        "UPDATE auction_lots SET current_price=%d,highest_bidder_account_id=%d,highest_bidder_name='' WHERE id=%d AND status='active' AND current_price=%d AND highest_bidder_account_id=%d",
        auction_slot[slot][CURRENT_RATE], old_bidder_account_id, auction_slot[slot][AUCTION_DB_ID], rate, bidder_account_id);
    result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        cache_delete(result);
        return 0;
    }

    new affected = cache_affected_rows();
    cache_delete(result);
    return affected == 1;
}

new player_show_slot[MAX_PLAYERS][4];
new player_info_panel[MAX_PLAYERS][STRUCT_AUCTION_PANEL];

/*new type_panel_auction[3][14] =
{
    {"txd:braucbuy"},
    {"txd:braucsell"},
    {"txd:braucmy"}
};*/
new auction_button[8][2][20] =
{
    {"txd:braucnulist", "txd:brauculist"}, //slot
    {"txd:braucnubuy", "txd:braucubuy"}, //купиьь
    {"txd:braucnusell", "txd:braucusell"}, //продать
    {"txd:braucnumy", "txd:braucumy"}, //вкладка мое
    {"txd:braucnutip", "txd:braucutip"}, //тип товара
    {"txd:braucnutovar", "txd:braucutovar"}, //выбор товара
    {"txd:braucnuopisanie", "txd:braucuopisanie"}, //описание товара
    {"txd:braucnucost", "txd:braucucost"} //цена товара
};




public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(Wedding_OnDialog(playerid, dialogid, response, listitem)) return 1;
    if(dialogid == DIALOG_AUCTION_SELECT_BUSINESS)
    {
        if(!response) return 1;
        new selected = GetPlayerListitemValue(playerid, listitem), error[96], text[256];
        if(selected <= AUCTION_LIST_FUEL_BASE)
        {
            new stationid = AUCTION_LIST_FUEL_BASE - selected;
            if(stationid < 0 || stationid >= g_fuel_station_loaded
                || GetFuelStationData(stationid, FS_OWNER_ID) != GetPlayerAccountID(playerid))
                return SendClientMessage(playerid, -1, ""SC" АЗС не найдена или больше вам не принадлежит.");

            SetPVarInt(playerid, "auction_business_source", AUCTION_BUSINESS_SOURCE_FUEL);
            SetPVarInt(playerid, "tovar_param", GetFuelStationData(stationid, FS_SQL_ID));
            SetPVarInt(playerid, "tovar_param_server", stationid);
            format(text, sizeof text,
                "Вы хотите выставить АЗС «%s» [ID: %d]?\n\nКомиссия аукциона составляет %d%%.",
                GetFuelStationData(stationid, FS_NAME), GetFuelStationData(stationid, FS_SQL_ID), AUCTION_COMMISSION_PERCENT);
            Dialog(playerid, 5992, DIALOG_STYLE_MSGBOX, "{FF0000}Продажа", text, "Далее", "Назад");
            return 1;
        }

        new business = selected;
        if(!BusinessManager_CanSell(playerid, business, error, sizeof error))
            return SendClientMessage(playerid, -1, error);

        SetPVarInt(playerid, "tovar_param", GetBusinessData(business, B_SQL_ID));
        SetPVarInt(playerid, "tovar_param_server", business);
        format(text, sizeof text,
            "Вы хотите выставить на аукцион бизнес «%s» [ID: %d]?\n\nКомиссия аукциона составляет %d%% от итоговой цены.",
            GetBusinessData(business, B_NAME), GetBusinessData(business, B_SQL_ID), AUCTION_COMMISSION_PERCENT);
        Dialog(playerid, 5992, DIALOG_STYLE_MSGBOX, "{FF0000}Продажа", text, "Далее", "Назад");
        return 1;
    }

    if(dialogid == 5990)
    {
        if(response)
        {
            if(!AuctionManager_IsBiddingTime())
                return SendClientMessage(playerid, -1, ""SC" Новые ставки принимаются с 08:00 до 23:00 GMT+3.");
            new rate = strval(inputtext), id = GetPVarInt(playerid, "select_slot"), string[32];
            if(id < 0 || id >= MAX_AUCTION_SLOT || !auction_slot[id][SLOT_TYPE])
                return SendClientMessage(playerid, -1, ""SC" Лот больше не существует.");
            if(auction_slot[id][TIMER_END] <= gettime())
                return SendClientMessage(playerid, -1, ""SC" Время торгов уже закончилось.");
            if(auction_slot_busy[id])
                return SendClientMessage(playerid, -1, ""SC" Лот сейчас обрабатывается. Попробуйте ещё раз.");

            new price = AuctionBid_GetMinimum(id), old_rate = auction_slot[id][OWNER_RATE];
            if(price <= 0 || rate < price || rate > 2000000000)
                return SendClientMessage(playerid, -1, ""SC" Ваша ставка должна быть не меньше указанной минимальной суммы.");
            if(auction_slot[id][OWNER_SLOT_SQL] == GetPlayerAccountID(playerid))
                return SendClientMessage(playerid, -1, ""SC" Нельзя делать ставку на свой лот.");
            if(old_rate == GetPlayerAccountID(playerid))
                return SendClientMessage(playerid, -1, ""SC" Вы уже лидируете в этом лоте.");
            new active_bid_lot = AuctionBid_GetActiveLotForAccount(GetPlayerAccountID(playerid));
            if(active_bid_lot == -2)
                return SendClientMessage(playerid, -1, ""SC" Не удалось проверить ваши активные ставки. Попробуйте позже.");
            if(active_bid_lot > 0 && active_bid_lot != auction_slot[id][AUCTION_DB_ID])
                return SendClientMessage(playerid, -1, ""SC" У вас уже есть ставка на другом активном лоте. Дождитесь завершения его торгов.");
            if(auction_slot[id][SLOT_TYPE] == TYPE_BUSINESS)
            {
                new businessid = auction_slot[id][SERVER_ID];
                if(auction_slot[id][BUSINESS_SOURCE_SLOT] == AUCTION_BUSINESS_SOURCE_FUEL)
                {
                    if(businessid < 0 || businessid >= g_fuel_station_loaded
                        || GetFuelStationData(businessid, FS_SQL_ID) != auction_slot[id][DATABASE_ID])
                        return SendClientMessage(playerid, -1, ""SC" АЗС этого лота не найдена.");
                    if(GetPlayerFuelStation(playerid) != -1)
                        return SendClientMessage(playerid, -1, ""SC" У вас уже имеется АЗС.");
                }
                else
                {
                    if(!AuctionBusiness_IsAuctionable(businessid)
                        || GetBusinessData(businessid, B_SQL_ID) != auction_slot[id][DATABASE_ID])
                        return SendClientMessage(playerid, -1, ""SC" Бизнес этого лота не найден.");
                    new max_business = 1 + GetPlayerData(playerid, P_BUSS_SLOTS);
                    if(max_business > 2) max_business = 2;
                    if(GetPlayerBusinessCount(playerid) >= max_business)
                        return SendClientMessage(playerid, -1, ""SC" Достигнут лимит бизнесов.");
                }
            }

            if(GetPlayerMoneyEx(playerid) >= rate)
            {
                auction_slot_busy[id] = true;
                new new_ends_at = gettime() + AUCTION_BID_HOLD_SECONDS;
                if(!AuctionBid_ReserveDatabaseUpdate(id, rate, old_rate, GetPlayerAccountID(playerid), GetPlayerNameEx(playerid), new_ends_at))
                {
                    auction_slot_busy[id] = false;
                    return SendClientMessage(playerid, -1, ""SC" Ставка изменилась или торги завершились. Обновите аукцион.");
                }
                // Persist the new bid before touching the previous bidder's
                // money. Without this row a restart made the winning hold
                // impossible to refund or complete safely.
                if(auction_slot[id][AUCTION_DB_ID] > 0)
                {
                    new bid_query[384], Cache:bid_result;
                    mysql_format(mysql, bid_query, sizeof bid_query,
                        "INSERT INTO auction_bids (auction_id,bidder_account_id,bidder_name,amount,created_at,status) VALUES (%d,%d,'%e',%d,%d,'active')",
                        auction_slot[id][AUCTION_DB_ID], GetPlayerAccountID(playerid), GetPlayerNameEx(playerid), rate, gettime());
                    bid_result = mysql_query(mysql, bid_query, true);
                    if(mysql_errno())
                    {
                        cache_delete(bid_result);
                        AuctionBid_RollbackDatabaseUpdate(id, rate, GetPlayerAccountID(playerid), old_rate, old_rate);
                        auction_slot_busy[id] = false;
                        return SendClientMessage(playerid, -1, ""SC" Не удалось надёжно сохранить ставку. Деньги не списаны.");
                    }
                    cache_delete(bid_result);
                }
                if(old_rate != -1)
                {
                    if(!AuctionRefundBid(id, "Вашу ставку перебили. Деньги возвращены."))
                    {
                        if(auction_slot[id][AUCTION_DB_ID] > 0)
                        {
                            new cancel_bid_query[256];
                            mysql_format(mysql, cancel_bid_query, sizeof cancel_bid_query,
                                "UPDATE auction_bids SET status='cancelled' WHERE auction_id=%d AND bidder_account_id=%d AND amount=%d AND status='active' ORDER BY id DESC LIMIT 1",
                                auction_slot[id][AUCTION_DB_ID], GetPlayerAccountID(playerid), rate);
                            mysql_query(mysql, cancel_bid_query, false);
                        }
                        if(!AuctionBid_RollbackDatabaseUpdate(id, rate, GetPlayerAccountID(playerid), old_rate, old_rate))
                            print("[AUCTION] Failed to roll back a reserved bid after refund failure.");
                        auction_slot_busy[id] = false;
                        return SendClientMessage(playerid, -1, ""SC" Не удалось безопасно вернуть предыдущую ставку.");
                    }
                }

                GivePlayerMoneyEx(playerid, -rate);

                default_select_slot(playerid);

                player_info_panel[playerid][select_slot] = 0;

                for(new i = 1; i < 6;i++ ) PlayerTextDrawSetString(playerid, auction_PTD[playerid][i], "-");

                auction_slot[id][OWNER_RATE] = GetPlayerAccountID(playerid);
                auction_slot[id][CURRENT_RATE] = rate;
                auction_slot[id][TIMER_END] = new_ends_at;
                auction_slot_busy[id] = false;

                for(new td; td < 4; td++)
                {
                    if(player_show_slot[playerid][td] == -1) continue;
                    PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][0]], auction_slot[player_show_slot[playerid][td]][OWNER_SLOT_NAME]);
                    PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][1]], auction_slot[player_show_slot[playerid][td]][SLOT_NAME]);

                    format(string, sizeof string, "Ставка~n~%d",
                        auction_slot[player_show_slot[playerid][td]][CURRENT_RATE]);
                    
                    PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][2]], string);
                }

                SendClientMessage(playerid, -1, ""SC" Вы успешно сделали ставку на лот.");
            }
            else SendClientMessage(playerid, -1, ""SC" Недостаточно денег для этой ставки.");
        }
        
    }
    if(dialogid == 5991)
    {
        if(!response) return 0;

        switch(GetPVarInt(playerid, "select_param"))
        {
            case 1://type
            {
                switch(listitem + 1)
                {
                    case 1:SetPVarInt(playerid, "type_param", TYPE_VEHICLE);
                    case 2:SetPVarInt(playerid, "type_param", TYPE_HOUSE);
                    case 3:SetPVarInt(playerid, "type_param", TYPE_BUSINESS);
                    case 4:SetPVarInt(playerid, "type_param", TYPE_VEHICLE_NUMBER);
                    case 5:SetPVarInt(playerid, "type_param", TYPE_SUM_NUMBER);
                    case 6:SetPVarInt(playerid, "type_param", TYPE_CLOTHES);
                }

                if(!player_info_panel[playerid][type_tovar])
                {
                    player_info_panel[playerid][type_tovar] = true;
                    PlayerTextDrawSetString(playerid, auction_PTD[playerid][29], auction_button[4][1]);
                } 

                PlayerTextDrawSetString(playerid, auction_PTD[playerid][22], icon_slot[GetPVarInt(playerid, "type_param")]);
                PlayerTextDrawSetString(playerid, auction_PTD[playerid][1], type_slot[GetPVarInt(playerid, "type_param")]);
            }
            case 2: // opisanie
            {
                //if(!inputtext) return SendClientMessage(playerid, -1, ""USC" Нельзя оставлять описание пустым");

                SetPVarString(playerid, "opisanie_param", inputtext);

                if(!player_info_panel[playerid][opisanie_tovar])
                {
                    player_info_panel[playerid][opisanie_tovar] = true;
                    PlayerTextDrawSetString(playerid, auction_PTD[playerid][31], auction_button[6][1]);
                }
                PlayerTextDrawSetString(playerid, auction_PTD[playerid][3], "Есть");
            }
            case 3://price
            {
                new price;

                sscanf(inputtext, "d", price);

                if(price >= 1_000_000_001 || price <= 4_999) return SendClientMessage(playerid, -1, ""USC" Введите сумму от 5000 руб до 1000000000 руб");

                SetPVarInt(playerid, "price_param", price);

                if(!player_info_panel[playerid][price_tovar])
                {
                    player_info_panel[playerid][price_tovar] = true;
                    PlayerTextDrawSetString(playerid, auction_PTD[playerid][28], auction_button[7][1]);
                } 
                PlayerTextDrawSetString(playerid, auction_PTD[playerid][4], inputtext);
            }
        }
    }
    if(dialogid == DIALOG_AUCTION_SELECT_VEHICLE)
    {
        if(!response) return 1;

        new id_car = GetPlayerListitemValue(playerid, listitem), Cache:result, text[128], name[24];
        if(id_car <= 0) return 1;

        mysql_format(mysql, text, sizeof text, "SELECT * FROM ownable_cars WHERE id='%d' AND owner_id='%d' LIMIT 1", id_car, GetPlayerAccountID(playerid));
        result = mysql_query(mysql, text);
        if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 2.1");
        if(!cache_num_rows()) return SendClientMessage(playerid, -1, "errror");

        new model_id = cache_get_field_content_int(0, "model_id");
        SetPVarInt(playerid, "tovar_param", id_car);
        SetPVarInt(playerid, "tovar_param_server", model_id);

        format(text, sizeof text, "Вы хотите выставить на аукцион транспорт %s [%d]?", GetVehicleInfo(model_id - 400, VI_NAME), id_car);
        format(name, 24, ProbelText(GetVehicleInfo(model_id - 400, VI_NAME)));
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][2], name);
        cache_delete(result);

        Dialog
        (
            playerid, 5992, DIALOG_STYLE_MSGBOX,
            "{FF0000}Продажа",
            text,
            "Далее", "Назад"
        );
        return 1;
    }
    if(dialogid == 5992) // согласие
    {
        if(!response) return 1;

        new text[124], name[24];

        switch(GetPVarInt(playerid, "type_param"))
        {
            case TYPE_VEHICLE_NUMBER:
            {
                new num[7];

                GetPVarString(playerid, "tovar_param_num", num, 7);

                if(num[0] == 0)
                {
                    new id_car = GetPlayerListitemValue(playerid, listitem), num_car[7], Cache:result;
                    
                    printf("id_car: %d", id_car);

                    mysql_format(mysql, text, sizeof text, "SELECT * FROM ownable_cars WHERE id='%d' AND owner_id='%d' LIMIT 1", id_car, GetPlayerAccountID(playerid));
                    result = mysql_query(mysql, text);
                    if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 2");

                    if(!cache_num_rows()) return SendClientMessage(playerid, -1, "errror");

                    for(new i, sql = GetPlayerAccountID(playerid);i < MAX_AUCTION_SLOT;i++)
                    {
                        if(auction_slot[i][OWNER_SLOT_SQL] != sql) continue;

                        if(auction_slot[i][SLOT_TYPE] == TYPE_VEHICLE && auction_slot[i][DATABASE_ID] == id_car) 
                            return SendClientMessage(playerid, -1, ""SC" Транспорт на аукционе");


                    }
                    //new rows = cache_num_rows();
                    
                    cache_get_field_content(0, "number", num_car, mysql, 7);

                    format(text, sizeof text, "Вы хотите выставить на аукцион номерной знак %s", num_car);

                    SetPVarString(playerid, "tovar_param_num", num_car);
                    SetPVarInt(playerid, "tovar_param", id_car);
                    SetPVarInt(playerid, "tovar_param_server", cache_get_field_content_int(0, "model_id"));

                    format(name, 24, num_car);

                    Dialog
                    (
                        playerid, 5992, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Продажа",
                        text,
                        "Далее", "Назад"
                    );
                }
            }
            case TYPE_CLOTHES:
            {
                if(GetPVarInt(playerid, "tovar_param")) return 1;

                new id_clothers = GetPlayerListitemValue(playerid, listitem), Cache:result;

                mysql_format(mysql, text, sizeof text, "SELECT * FROM inventory_skins WHERE id='%d' AND owner_skin='%d' AND use_skin=0 LIMIT 1", id_clothers, GetPlayerAccountID(playerid));
                result = mysql_query(mysql, text);
                if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 3");
          
                if(!cache_num_rows()) return SendClientMessage(playerid, -1, "errror");
                
                new server = cache_get_field_content_int(0, "skin_id");

                format(text, sizeof text, "Вы хотите выставить на аукцион одежду %s", GetSkinInfo(server, S_NAME));

                SetPVarInt(playerid, "tovar_param", id_clothers);
                SetPVarInt(playerid, "tovar_param_server", server);

                format(name, 24, GetSkinInfo(server, S_NAME));

                Dialog
                (
                    playerid, 5992, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Продажа",
                    text,
                    "Далее", "Назад"
                );      
            }
            case TYPE_BUSINESS:
                format(name, 24, GetBusinessData(GetPVarInt(playerid, "tovar_param_server"), B_NAME));

            case TYPE_HOUSE:
                format(name, 24, "Дом %d", GetPVarInt(playerid, "tovar_param_server"));

            case TYPE_SUM_NUMBER:
            {
                new string[6];
                valstr(string, GetPVarInt(playerid, "tovar_param"));

                format(name, 24, string);
            }
            case TYPE_VEHICLE:
            {
                new id = GetVehicleModel(GetPVarInt(playerid, "tovar_param_server")) - 400;
                format(name, 24, ProbelText(GetVehicleInfo(id, VI_NAME)));
            }
        }

        if(!player_info_panel[playerid][tovar])
        {
            player_info_panel[playerid][tovar] = true;
            PlayerTextDrawSetString(playerid, auction_PTD[playerid][30], auction_button[5][1]);
        }
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][2], name);

    }
    if(dialogid == DIALOG_AUCTION_MY_SALES)
    {
        if(!response) return 1;

        new slot = GetPlayerListitemValue(playerid, listitem);
        if(slot < 0 || slot >= MAX_AUCTION_SLOT) return 1;
        if(auction_slot[slot][OWNER_SLOT_SQL] != GetPlayerAccountID(playerid)) return 1;
        if(!auction_slot[slot][SLOT_TYPE]) return 1;

        SetPVarInt(playerid, "auction_cancel_slot", slot);
        Dialog(playerid, DIALOG_AUCTION_CANCEL_CONFIRM, DIALOG_STYLE_MSGBOX,
            "{FF0000}Снятие лота",
            "Вы действительно хотите снять свой лот с аукциона?\n\nЕсли на лот уже была сделана ставка, деньги будут возвращены покупателю.",
            "Да", "Нет");
        return 1;
    }
    if(dialogid == DIALOG_AUCTION_CANCEL_CONFIRM)
    {
        if(!response)
        {
            DeletePVar(playerid, "auction_cancel_slot");
            return 1;
        }

        new slot = GetPVarInt(playerid, "auction_cancel_slot");
        DeletePVar(playerid, "auction_cancel_slot");
        return AuctionCancelSlot(slot, GetPlayerAccountID(playerid));
    }
    if(dialogid == 5993)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "filter_select_veh"))
            {
                new model = GetPlayerListitemValue(playerid, listitem);

                player_info_panel[playerid][filter_vehicle_model] = model;
                player_info_panel[playerid][filter_tovar_type] = TYPE_VEHICLE;

                player_info_panel[playerid][count_list] = 1;
                LeafAuction(playerid, 3);
                DeletePVar(playerid, "filter_select_veh");

                return 1;
            }
            else if(player_info_panel[playerid][filter_type] == 2)
            {
                new min_price, max_price;

                if(sscanf(inputtext, "P<,>dd", min_price, max_price))
                {
                    SendClientMessage(playerid, 0x999999FF, "Некорректный ввод");
                    player_info_panel[playerid][filter_type] = 0;

                    LeafAuction(playerid, 3);
                    return 1;
                }
                else
                {
                    if(min_price >= max_price) 
                    {
                        SendClientMessage(playerid, 0xFFFFFFFF, ""USC" Минимальная цена должна быть меньше чем максимальная");
                        player_info_panel[playerid][filter_type] = 0;

                        LeafAuction(playerid, 3);
                    return 1;
                    }
                    else if(min_price <= 999 || max_price >= 500_000_000)
                    {
                        SendClientMessage(playerid, 0xFFFFFFFF, ""USC" Цена должна быть от 1000 руб до 500000000 руб");
                        player_info_panel[playerid][filter_type] = 0;

                        LeafAuction(playerid, 3);
                    return 1;                               
                    }
                    else
                    {
                        player_info_panel[playerid][filter_type] = 2;
                        player_info_panel[playerid][filter_min_price] = min_price;
                        player_info_panel[playerid][filter_max_price] = max_price;

                        player_info_panel[playerid][count_list] = 1;
                        LeafAuction(playerid, 3);
                        return 1;
                    }
                }
            }
            else if(player_info_panel[playerid][filter_type] == 1)
            {
                if(player_info_panel[playerid][filter_tovar_type] == TYPE_VEHICLE)
                {
                    new dialog[284], list[54], market;

                    switch(listitem+1)
                    {
                        case 1:market = 1;
                        case 2:market = 3;
                        case 3:market = 2;
                    }

                    for(new v, model; v < 32;v++)
                    {
                        if(!car_market_data[market][v][0]) continue;

                        model = car_market_data[market][v][0]-400;

                        format(list, sizeof list, "%d. %s\n", v + 1, GetVehicleInfo(model, VI_NAME));
                        strcat(dialog, list);

                        SetPlayerListitemValue(playerid, v, model);
                    }

                    Dialog
                    (
                        playerid, 5993, DIALOG_STYLE_LIST,
                        "{FF0000}Фильтр",
                        dialog,
                        "Далее", "Назад"
                    );

                    SetPVarInt(playerid, "filter_select_veh", 1);

                    return 1;
                }
                else
                {
                    switch(listitem)
                    {
                        case 0:
                        {
                            Dialog
                            (
                                playerid, 5993, DIALOG_STYLE_LIST,
                                "{FF0000}Фильтр",
                                "1. Низкий класс\n"\
                                "1. Средний класс\n"\
                                "1. Высокий класс",
                                "Далее", "Назад"
                            );
                            
                            player_info_panel[playerid][filter_tovar_type] = TYPE_VEHICLE;

                            return 1;
                        }
                        case 1:
                        {
                            player_info_panel[playerid][filter_tovar_type] = TYPE_HOUSE;

                            player_info_panel[playerid][count_list] = 1;
                            LeafAuction(playerid, 3);
                        }
                        case 2:
                        {
                            player_info_panel[playerid][filter_tovar_type] = TYPE_BUSINESS;

                            player_info_panel[playerid][count_list] = 1;
                            LeafAuction(playerid, 3);
                        }
                        case 3:
                        {
                            player_info_panel[playerid][filter_tovar_type] = TYPE_VEHICLE_NUMBER;

                            player_info_panel[playerid][count_list] = 1;
                            LeafAuction(playerid, 3);
                        }
                        case 4:
                        {
                            player_info_panel[playerid][filter_tovar_type] = TYPE_SUM_NUMBER;

                            player_info_panel[playerid][count_list] = 1;
                            LeafAuction(playerid, 3);
                        }
                        case 5:
                        {
                            player_info_panel[playerid][filter_tovar_type] = TYPE_CLOTHES;

                            player_info_panel[playerid][count_list] = 1;
                            LeafAuction(playerid, 3);
                        }
                    }
                }
            }    
            else
            {       
                switch(listitem)
                {
                    case 0:
                    {
                        Dialog
                        (
                            playerid, 5993, DIALOG_STYLE_LIST,
                            "{FF0000}Фильтр",
                            "1. Автомобиль\n"\
                            "2. Недвижимость\n"\
                            "3. Бизнес\n"\
                            "4. Номерной знак\n"\
                            "5. Сим-карта\n"\
                            "6. Одежда",
                            "Далее", "Назад"
                        );

                        player_info_panel[playerid][filter_type] = 1;
                        return 1;
                    }
                    case 1:
                    {   
                        Dialog
                        (
                            playerid, 5993, DIALOG_STYLE_INPUT,
                            "{FF0000}Фильтр",
                            "Введите цену от и до через запятую (1000, 500000000)",
                            "Далее", "Назад"
                        );

                        player_info_panel[playerid][filter_type] = 2;
                        return 1;
                    }
                }
            }
        }
        else 
        {
            player_info_panel[playerid][filter_type] = 0;
            player_info_panel[playerid][filter_tovar_type] = 0;
        }
    }
    #if defined auc_OnDialogResponse
        return auc_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    #else
        return 0;
    #endif
}


#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse auc_OnDialogResponse
#if defined auc_OnDialogResponse
forward auc_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

public:PlayerTextDrawAuction(playerid)
{
    auction_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 27.3333, 100.2444, "txd:braucbuy"); // фон / основа
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][0], 588.0000, 294.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][0], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][0], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][0], 0);

    auction_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 490.6665, 211.9851, "-"); // имя владельца слота
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][1], 0.2480, 1.3330);//0.3133, 1.2888
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][1], -21.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][1], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][1], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][1], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][1], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][1], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][1], 0);

    auction_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 490.6665, 236.4593, "-"); // тип слота
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][2], 0.2480, 1.3330);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][2], -21.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][2], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][2], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][2], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][2], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][2], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][2], 0);

    auction_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 490.6665, 261.7631, "-"); // стартовая
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][3], 0.2480, 1.3330);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][3], -21.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][3], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][3], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][3], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][3], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][3], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][3], 0);

    auction_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 490.6665, 286.6520, "-"); // текущяя цена
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][4], 0.2480, 1.3330);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][4], -21.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][4], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][4], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][4], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][4], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][4], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][4], 0);

    auction_PTD[playerid][5] = CreatePlayerTextDraw(playerid, 490.6665, 311.5410, "-"); // время
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][5], 0.2480, 1.3330);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][5], -20.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][5], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][5], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][5], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][5], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][5], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][5], 0);

    auction_PTD[playerid][6] = CreatePlayerTextDraw(playerid, 174.6666, 293.9630, "txd:braucnulist"); // 4
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][6], 298.0000, 70.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][6], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][6], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][6], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][6], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][6], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][6], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][6], 1);

    auction_PTD[playerid][7] = CreatePlayerTextDraw(playerid, 193.3333, 316.5185, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][7], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][7], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][7], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][7], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][7], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][7], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][7], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][7], 0);

    auction_PTD[playerid][8] = CreatePlayerTextDraw(playerid, 303.6669, 317.3482, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][8], 0.2350, 1.4262);//0.3026, 1.2971
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][8], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][8], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][8], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][8], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][8], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][8], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][8], 0);

    auction_PTD[playerid][9] = CreatePlayerTextDraw(playerid, 381.3334, 326.8889, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][9], 0.2150, 1.3262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][9], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][9], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][9], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][9], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][9], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][9], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][9], 0);

    auction_PTD[playerid][10] = CreatePlayerTextDraw(playerid, 174.6666, 144.6296, "txd:braucnulist"); // 1
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][10], 298.0000, 70.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][10], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][10], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][10], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][10], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][10], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][10], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][10], 1);

    auction_PTD[playerid][11] = CreatePlayerTextDraw(playerid, 193.3333, 167.1852, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][11], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][11], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][11], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][11], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][11], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][11], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][11], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][11], 0);

    auction_PTD[playerid][12] = CreatePlayerTextDraw(playerid, 303.6669, 168.0148, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][12], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][12], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][12], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][12], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][12], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][12], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][12], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][12], 0);

    auction_PTD[playerid][13] = CreatePlayerTextDraw(playerid, 381.3334, 177.5556, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][13], 0.2150, 1.3262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][13], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][13], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][13], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][13], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][13], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][13], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][13], 0);

    auction_PTD[playerid][14] = CreatePlayerTextDraw(playerid, 174.6666, 195.2370, "txd:braucnulist"); // 2
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][14], 298.0000, 70.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][14], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][14], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][14], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][14], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][14], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][14], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][14], 1);

    auction_PTD[playerid][15] = CreatePlayerTextDraw(playerid, 193.3333, 217.7926, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][15], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][15], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][15], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][15], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][15], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][15], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][15], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][15], 0);

    auction_PTD[playerid][16] = CreatePlayerTextDraw(playerid, 303.6669, 218.6222, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][16], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][16], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][16], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][16], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][16], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][16], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][16], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][16], 0);

    auction_PTD[playerid][17] = CreatePlayerTextDraw(playerid, 381.3334, 228.1630, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][17], 0.2150, 1.3262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][17], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][17], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][17], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][17], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][17], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][17], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][17], 0);

    auction_PTD[playerid][18] = CreatePlayerTextDraw(playerid, 174.6666, 244.6000, "txd:braucnulist"); // 3
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][18], 298.0000, 70.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][18], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][18], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][18], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][18], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][18], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][18], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][18], 1);

    auction_PTD[playerid][19] = CreatePlayerTextDraw(playerid, 193.3333, 267.1556, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][19], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][19], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][19], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][19], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][19], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][19], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][19], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][19], 0);

    auction_PTD[playerid][20] = CreatePlayerTextDraw(playerid, 303.6669, 267.9852, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][20], 0.2350, 1.4262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][20], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][20], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][20], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][20], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][20], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][20], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][20], 0);

    auction_PTD[playerid][21] = CreatePlayerTextDraw(playerid, 381.3334, 277.5260, "-"); // пусто
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][21], 0.2150, 1.3262);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][21], -70.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][21], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][21], -1107374134);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][21], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][21], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][21], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][21], 0);

    auction_PTD[playerid][22] = CreatePlayerTextDraw(playerid, 492.3333, 132.6000, "txd:brauchome"); // иконка слота
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][22], 103.0000, 65.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][22], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][22], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][22], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][22], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][22], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][22], 0);

    auction_PTD[playerid][23] = CreatePlayerTextDraw(playerid, 43.3333, 125.1333, "txd:braucubuy"); // вклада покупки
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][23], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][23], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][23], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][23], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][23], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][23], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][23], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][23], 1);

    auction_PTD[playerid][24] = CreatePlayerTextDraw(playerid, 43.3333, 170.3481, "txd:braucnusell"); // вкладка продажа
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][24], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][24], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][24], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][24], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][24], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][24], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][24], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][24], 1);

    auction_PTD[playerid][25] = CreatePlayerTextDraw(playerid, 43.6666, 216.8074, "txd:braucnumy"); // вкладка мои
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][25], 109.0000, 61.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][25], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][25], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][25], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][25], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][25], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][25], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][25], 1);

    auction_PTD[playerid][26] = CreatePlayerTextDraw(playerid, 43.3333, 285.6667, "txd:braucexit"); // выйти
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][26], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][26], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][26], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][26], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][26], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][26], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][26], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][26], 1);

    auction_PTD[playerid][27] = CreatePlayerTextDraw(playerid, 94.3333, 368.3703, "1"); // страница
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][27], 0.3563, 1.6207);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][27], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][27], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][27], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][27], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][27], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][27], 0);

    auction_PTD[playerid][28] = CreatePlayerTextDraw(playerid, 172.0000, 289.4001, "txd:braucnucost"); // пусто
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][28], 302.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][28], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][28], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][28], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][28], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][28], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][28], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][28], 1);

    auction_PTD[playerid][29] = CreatePlayerTextDraw(playerid,171.3333, 154.5852, "txd:braucnutip"); // тип товара
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][29], 302.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][29], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][29], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][29], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][29], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][29], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][29], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][29], 1);

    auction_PTD[playerid][30] = CreatePlayerTextDraw(playerid,172.0000, 200.2147, "txd:braucnutovar"); // товар
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][30], 302.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][30], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][30], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][30], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][30], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][30], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][30], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][30], 1);

    auction_PTD[playerid][31] = CreatePlayerTextDraw(playerid,172.6666, 244.1851, "txd:braucnuopisanie"); // описание
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][31], 302.0000, 63.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][31], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][31], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][31], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][31], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][31], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][31], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][31], 1);

    auction_PTD[playerid][32] = CreatePlayerTextDraw(playerid,491.9997, 310.7110, "0_RUB"); // продвижение
    PlayerTextDrawLetterSize(playerid, auction_PTD[playerid][32], 0.2480, 1.3330);
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][32], 496.9997, 0.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][32], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][32], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][32], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][32], 1);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][32], 1);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][32], 0);

    auction_PTD[playerid][33] = CreatePlayerTextDraw(playerid, 240.3332, 132.1851, "txd:braucsale"); // пусто
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][33], 158.0000, 197.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][33], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][33], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][33], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][33], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][33], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][33], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][33], 1);

    auction_PTD[playerid][34] = CreatePlayerTextDraw(playerid, 393.3332, 146.2888, "txd:braucpurchase"); // пусто
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][34], 143.0000, 175.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][34], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][34], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][34], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][34], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][34], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][34], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][34], 1);

    auction_PTD[playerid][35] = CreatePlayerTextDraw(playerid, 140.0001, 362.5701, "txd:braucright"); //следующий список
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][35], 24.0000, 27.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][35], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][35], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][35], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][35], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][35], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][35], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][35], 1);

    auction_PTD[playerid][36] = CreatePlayerTextDraw(playerid, 39.3333, 362.9849, "txd:braucleft"); // прошлый список
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][36], 23.0000, 27.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][36], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][36], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][36], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][36], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][36], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][36], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][36], 1);

    auction_PTD[playerid][37] = CreatePlayerTextDraw(playerid, 482.3333, 319.6813, "txd:braucbet"); // сделать ставку
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][37], 122.0000, 57.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][37], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][37], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][37], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][37], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][37], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][37], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][37], 1);

    auction_PTD[playerid][38] = CreatePlayerTextDraw(playerid, 439.0000, 115.1778, "txd:braucfilter"); // фильтер
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][38], 24.0000, 26.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][38], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][38], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][38], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][38], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][38], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][38], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][38], 1);

    auction_PTD[playerid][39] = CreatePlayerTextDraw(playerid, 482.3333, 319.6813, "txd:braucexpose"); // выставить
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][39], 122.0000, 57.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][39], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][39], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][39], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][39], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][39], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][39], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][39], 1);
}

public OnGameModeInit()
{
    for(new i;i < MAX_BUSINESS; i ++)
    {
        if(GetBusinessData(i, B_NAME)) continue;

        SetTimer("SetBusinessName", 1500, false);

        break;
    }

    CreateDynamic3DTextLabel("Введите команду {FF0000}/auction{FFFFFF}\nЧтобы использовать аукцион", -1, 1000.000915,2508.325927,1497.994628, 5.0);
    enter_auction = CreateDynamicSphere(2092.610351,-2283.928955,23.096267, 1.0, 0, 0);
    exit_auction = CreateDynamicSphere(999.965148,2488.335205,1499.304687, 2.0, AUCTION_WORLD, 1);
    CreateDynamicPickup(19134, 23, 2092.610351,-2283.928955,23.096267, 0, 0);
    CreateDynamicPickup(19134, 23, 999.965148,2488.335205,1499.304687, AUCTION_WORLD, 1);
    CreateDynamic3DTextLabel("{FFFF00}Выход из аукциона\n{FFFFFF}Подойдите ближе, чтобы выйти", -1, 999.965148,2488.335205,1500.104687, 8.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, AUCTION_WORLD, 1);
    Create3DTextLabel("{FFFF00}Вход в аукцион\n{FFFFFF}Подойдите ближе чтобы войти", -1, 2092.610351,-2283.928955,23.096267, 10.0, 0);
    
    defualt_slot();
    SetTimer("AuctionUpdate", 1000, true);
    #if defined auc_OnGameModeInit
        return auc_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit auc_OnGameModeInit
#if defined auc_OnGameModeInit
    forward auc_OnGameModeInit();
#endif

public OnPlayerConnect(playerid)
{
    SetTimerEx("PlayerTextDrawAuction", 6000, false, "i", playerid);
    #if defined auc_OnPlayerConnect
        return auc_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect auc_OnPlayerConnect
#if defined auc_OnPlayerConnect
    forward auc_OnPlayerConnect(playerid);
#endif

cmd:tpa(playerid){
    CallLocalFunction("OnPlayerEnterDynamicArea", "ii", playerid, enter_auction);
    return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(Wedding_OnEnterArea(playerid, areaid)) return 1;
    if(areaid == enter_auction)
    {
        // Spawn beyond the 2.0-radius exit sphere (its centre is Y=2488.335),
        // facing towards the auction hall instead of immediately leaving it.
        SetPlayerPosEx(playerid, 999.987854,2492.800048,1499.304687,359.335876, 1, AUCTION_WORLD);
        Streamer_Update(playerid);
        SetCameraBehindPlayer(playerid);
    }
    if(areaid == exit_auction)
    {
        SetPlayerPosEx(playerid, 2090.941650,-2283.999511,23.101566,92.530944, 0, 0);
        Streamer_Update(playerid);
        return 1;
    }
    #if defined auc_OnPlayerEnterDynamicArea
        return auc_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
    #else
        return 0;
    #endif
}
   #if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea auc_OnPlayerEnterDynamicArea
#if defined auc_OnPlayerEnterDynamicArea
    forward auc_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
#endif

stock default_select_slot(playerid)
{
    if(player_info_panel[playerid][select_slot] != 0)
    {
        new string[20];
        strcat(string, auction_button[0][0]);
        switch(player_info_panel[playerid][select_slot])
        {
            case 4:PlayerTextDrawSetString(playerid, auction_PTD[playerid][6], string);
            case 1:PlayerTextDrawSetString(playerid, auction_PTD[playerid][10], string);
            case 2:PlayerTextDrawSetString(playerid, auction_PTD[playerid][14], string);
            case 3:PlayerTextDrawSetString(playerid, auction_PTD[playerid][18], string);
        }
    }
    return 1;
}
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    printf("[TD] TextDraw:%d", _:auction_PTD[playerid][0]);
    if(playertextid == auction_PTD[playerid][6])
    {
        default_select_slot(playerid);
        new slot = player_show_slot[playerid][3];
        if(slot == -1) return 1;

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][1], auction_slot[slot][OWNER_SLOT_NAME]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][2], type_slot[auction_slot[slot][SLOT_TYPE]]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][22], icon_slot[auction_slot[slot][SLOT_TYPE]]);

        new string[13];
        format(string, sizeof string, "%d_руб", auction_slot[slot][START_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][3], string);
        
        format(string, sizeof string, "%d_руб", auction_slot[slot][CURRENT_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][4], string);

        AuctionManager_FormatRemainingTime(auction_slot[slot][TIMER_END], string, sizeof string);

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][5], string);


        player_info_panel[playerid][select_slot] = 4;
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][6], auction_button[0][1]);

        //SCM(playerid, -1, "ВЫБРАЛ 4 СЛОТ");
    }
    if(playertextid == auction_PTD[playerid][10])
    {
        default_select_slot(playerid);

        new slot = player_show_slot[playerid][0];
        if(slot == -1) return 1;

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][1], auction_slot[slot][OWNER_SLOT_NAME]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][2], type_slot[auction_slot[slot][SLOT_TYPE]]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][22], icon_slot[auction_slot[slot][SLOT_TYPE]]);

        new string[13];
        format(string, sizeof string, "%d_руб", auction_slot[slot][START_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][3], string);
        
        format(string, sizeof string, "%d_руб", auction_slot[slot][CURRENT_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][4], string);

        AuctionManager_FormatRemainingTime(auction_slot[slot][TIMER_END], string, sizeof string);

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][5], string);


        player_info_panel[playerid][select_slot] = 1;
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][10], auction_button[0][1]);

        //SCM(playerid, -1, "ВЫБРАЛ 1 СЛОТ");
    }
    if(playertextid == auction_PTD[playerid][14])
    {
        default_select_slot(playerid);
        new slot = player_show_slot[playerid][1];
        if(slot == -1) return 1;

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][1], auction_slot[slot][OWNER_SLOT_NAME]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][2], type_slot[auction_slot[slot][SLOT_TYPE]]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][22], icon_slot[auction_slot[slot][SLOT_TYPE]]);

        new string[13];
        format(string, sizeof string, "%d_руб", auction_slot[slot][START_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][3], string);
        
        format(string, sizeof string, "%d_руб", auction_slot[slot][CURRENT_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][4], string);

        AuctionManager_FormatRemainingTime(auction_slot[slot][TIMER_END], string, sizeof string);

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][5], string);

        player_info_panel[playerid][select_slot] = 2;
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][14], auction_button[0][1]);

        //SCM(playerid, -1, "ВЫБРАЛ 2 СЛОТ");
    }
    if(playertextid == auction_PTD[playerid][18])
    {
        default_select_slot(playerid);
        new slot = player_show_slot[playerid][2];
        if(slot == -1) return 1;
        
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][1], auction_slot[slot][OWNER_SLOT_NAME]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][2], type_slot[auction_slot[slot][SLOT_TYPE]]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][22], icon_slot[auction_slot[slot][SLOT_TYPE]]);

        new string[13];
        format(string, sizeof string, "%d_руб", auction_slot[slot][START_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][3], string);
        
        format(string, sizeof string, "%d_руб", auction_slot[slot][CURRENT_RATE]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][4], string);

        AuctionManager_FormatRemainingTime(auction_slot[slot][TIMER_END], string, sizeof string);

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][5], string);

        player_info_panel[playerid][select_slot] = 3;
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][18], auction_button[0][1]);

        //SCM(playerid, -1, "ВЫБРАЛ 3 СЛОТ");
    }
    if(playertextid == auction_PTD[playerid][23])
    {
        //SCM(playerid, -1, "ВКЛАДКА ПОКУПКА");      
        ShowTabBuy(playerid);
    }
    if(playertextid == auction_PTD[playerid][24])
    {
        //SCM(playerid, -1, "ВКЛАДКА ПРОДАЖА");   
        ShowTabSell(playerid);     
    }
    if(playertextid == auction_PTD[playerid][25])
    {
        //player_info_panel[playerid][select_tab] = 3;

        //SCM(playerid, -1, "ВКЛАДКА МОИ");  
        ShowTabMy(playerid);     
    }
    if(playertextid == auction_PTD[playerid][26])
    {
        HideTextDrawAuction(playerid);
        //SCM(playerid, -1, "ВЫЙТИ");
    }
    if(playertextid == auction_PTD[playerid][28])
    {
        if(!player_info_panel[playerid][opisanie_tovar]) return SCM(playerid, -1, " Сначало напишите описание");
        if(player_info_panel[playerid][price_tovar]) return 0;

        Dialog
        (
            playerid, 5991, DIALOG_STYLE_INPUT,
            "{FF0000} Продажа",
            "Введите начальную цену за Ваш товар: (5 процентов коммиссия аукциона от итоговой суммы)",
            "Далее","Назад"
        );
        SetPVarInt(playerid, "select_param", 3);
        //SCM(playerid, -1, "ЦЕНА");
    }
    if(playertextid == auction_PTD[playerid][29])
    {
        player_info_panel[playerid][filter_vehicle_model] = 0;
        player_info_panel[playerid][filter_tovar_type] = 0;
        player_info_panel[playerid][filter_type] = 0;
        player_info_panel[playerid][type_tovar] = false;
        player_info_panel[playerid][price_tovar] = false;
        player_info_panel[playerid][tovar] = false;
        player_info_panel[playerid][opisanie_tovar] = false;

        //if(GetPVarInt(playerid, "type_param")) return 1;
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][31], auction_button[6][0]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][30], auction_button[5][0]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][28], auction_button[7][0]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][29], auction_button[4][0]);

        for(new pon = 1; pon < 6;pon++)
        {
            PlayerTextDrawSetString(playerid, auction_PTD[playerid][pon], "-");
        }

        DeletePVar(playerid, "opisanie_param");
        DeletePVar(playerid, "tovar_param_num");
        if(GetPVarInt(playerid, "type_param"))DeletePVar(playerid, "type_param");
        if(GetPVarInt(playerid, "tovar_param_server"))DeletePVar(playerid, "tovar_param_server");
        if(GetPVarInt(playerid, "price_param"))DeletePVar(playerid, "price_param");
        if(GetPVarInt(playerid, "tovar_param"))DeletePVar(playerid, "tovar_param");
        if(GetPVarInt(playerid, "select_type"))DeletePVar(playerid, "select_type");

        Dialog
        (
            playerid, 5991, DIALOG_STYLE_LIST,
            "{FF0000}Продажа",
            "1. Автомобиль\n"\
            "2. Недвижимость\n"\
            "3. Бизнес\n"\
            "4. Номерной знак\n"\
            "5. Сим-карта\n"\
            "6. Одежда",
            "Далее", "Назад"
        );

        SetPVarInt(playerid, "select_param", 1);
        //SCM(playerid, -1, "ТИП");
    }
    if(playertextid == auction_PTD[playerid][30])
    {
        if(!player_info_panel[playerid][type_tovar]) return SCM(playerid, -1, "Сначало выберите тип товара");
        if(player_info_panel[playerid][tovar]) return 0;

        new text[284];

        switch(GetPVarInt(playerid, "type_param"))
        {
            case TYPE_VEHICLE:
            {
                if(GetPlayerOwnableCar(playerid) != INVALID_VEHICLE_ID)
                {
                    new vehicle = GetPlayerOwnableCar(playerid);
                    new model = GetVehicleModel(vehicle) - 400;
                    new action = GetVehicleData(vehicle, V_ACTION_ID);

                    SetPVarInt(playerid, "tovar_param", GetOwnableCarData(action, OC_SQL_ID));
                    SetPVarInt(playerid, "tovar_param_server", vehicle);

                    format(text, sizeof text, "Вы хотите выставить на аукцион транспорт %s [%d]?", GetVehicleInfo(model, VI_NAME), GetOwnableCarData(action, OC_SQL_ID));

                    Dialog
                    (
                        playerid, 5992, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Продажа",
                        text,
                        "Далее", "Назад"
                    );
                }
                else
                {
                    new Cache:result;
                    mysql_format(mysql, text, sizeof text, "SELECT id,model_id FROM ownable_cars WHERE owner_id = %d", GetPlayerAccountID(playerid));
                    result = mysql_query(mysql, text);
                    if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 4.1");
                    if(!cache_num_rows()) return SendClientMessage(playerid, -1, ""USC" У вас нет транспорта");

                    new rows = cache_num_rows(), query[64], id_car, model_id, list[512];
                    ClearPlayerListitemValues(playerid);
                    list[0] = EOS;

                    for(new i = 0; i < rows; i++)
                    {
                        id_car = cache_get_field_content_int(i, "id");
                        model_id = cache_get_field_content_int(i, "model_id") - 400;
                        format(query, sizeof query, "{FFFFFF}%d. %s [%d]\n", i + 1, GetVehicleInfo(model_id, VI_NAME), id_car);
                        strcat(list, query);
                        SetPlayerListitemValue(playerid, i, id_car);
                    }
                    cache_delete(result);

                    Dialog
                    (
                        playerid, DIALOG_AUCTION_SELECT_VEHICLE, DIALOG_STYLE_LIST,
                        "{FF0000}Продажа",
                        list,
                        "Далее", "Назад"
                    );
                }
            }
            case TYPE_BUSINESS:
            {
                new list[2048], row[128], count, type_name[32];
                for(new business; business < g_business_loaded; business++)
                {
                    if(GetBusinessData(business, B_OWNER_ID) != GetPlayerAccountID(playerid)) continue;
                    BusinessManager_GetTypeName(business, type_name, sizeof type_name);
                    format(row, sizeof row, "[%d] %s ? %s\n",
                        GetBusinessData(business, B_SQL_ID), GetBusinessData(business, B_NAME), type_name);
                    strcat(list, row);
                    SetPlayerListitemValue(playerid, count++, business);
                }
                for(new stationid; stationid < g_fuel_station_loaded; stationid++)
                {
                    if(GetFuelStationData(stationid, FS_OWNER_ID) != GetPlayerAccountID(playerid)) continue;
                    format(row, sizeof row, "[%d] %s — АЗС\n",
                        GetFuelStationData(stationid, FS_SQL_ID), GetFuelStationData(stationid, FS_NAME));
                    strcat(list, row);
                    SetPlayerListitemValue(playerid, count++, AUCTION_LIST_FUEL_BASE - stationid);
                }
                if(!count) return SendClientMessage(playerid, -1, ""USC" У вас нет бизнеса");
                Dialog(playerid, DIALOG_AUCTION_SELECT_BUSINESS, DIALOG_STYLE_LIST,
                    "{FF0000}Выберите бизнес", list, "Далее", "Назад");
            }
            case TYPE_HOUSE:
            {
                if(GetPlayerHouse(playerid) != -1)
                {
                    new house = GetPlayerHouse(playerid);
                    new sql = GetHouseData(house, H_SQL_ID);

                    SetPVarInt(playerid, "tovar_param", sql);
                    SetPVarInt(playerid, "tovar_param_server", house);

                    format(text, sizeof text, "Вы хотите выставить на аукцион Дом %d?", house);

                    Dialog
                    (
                        playerid, 5992, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Продажа",
                        text,
                        "Далее", "Назад"
                    );
                }
                else SendClientMessage(playerid, -1, ""USC" У вас нет недвижимости");
            }
            case TYPE_SUM_NUMBER:
            {
                if(GetPlayerPhone(playerid))
                {
                    new sum = GetPlayerPhone(playerid);

                    SetPVarInt(playerid, "tovar_param", sum);

                    format(text, sizeof text, "Вы хотите выставить на аукцион сим-карту %d?", sum);

                    Dialog
                    (
                        playerid, 5992, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Продажа",
                        text,
                        "Далее", "Назад"
                    );
                }
                else SendClientMessage(playerid, -1, ""USC" У вас нет сим-карта");
            }
            case TYPE_VEHICLE_NUMBER:
            {
                new Cache:result;

                mysql_format(mysql, text, sizeof text, "SELECT * FROM ownable_cars WHERE owner_id = %d AND number != '------'", GetPlayerAccountID(playerid));
                result = mysql_query(mysql, text);
                if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 4");

                if(!cache_num_rows()) return SendClientMessage(playerid, -1, ""USC" У вас нет транспорта с номером");

                new rows = cache_num_rows(), query[54], id, model_id, car_number[7];
                
                format(text, sizeof text, "");

				for(new i = 0; i < rows; i ++)
				{
					id = cache_get_field_content_int(i, "id");
					model_id = cache_get_field_content_int(i, "model_id") - 400;
					cache_get_field_content(i, "number", car_number);

					format(query, sizeof query, "{FFFFFF}%d. %s - %s\n", i + 1, GetVehicleInfo(model_id, VI_NAME), car_number);
					strcat(text, query);
					SetPlayerListitemValue(playerid, i, id);
                    printf("lisitem: %d | id_car: %d", i, id);
				}

                Dialog
                (
                    playerid, 5992, DIALOG_STYLE_LIST,
                    "{FF0000}Продажа",
                    text, 
                    "Далее", "Назад"
                );
            }
            case TYPE_CLOTHES:
            {
                new Cache:result;
                format(text, sizeof text, "SELECT * FROM inventory_skins WHERE owner_skin = %d AND use_skin = 0", GetPlayerAccountID(playerid));
                result = mysql_query(mysql, text);
                if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 4");

                if(!cache_num_rows()) return SendClientMessage(playerid, -1, ""USC" У вас нет свободной одежды");

                new rows = cache_num_rows(), query[54], id, model_id;

                format(text, sizeof text, "");
                
				for(new i = 0; i < rows; i ++)
				{
					id = cache_get_field_content_int(i, "id");
					model_id = cache_get_field_content_int(i, "skin_id");

					format(query, sizeof query, "{FFFFFF}%d. %s\n", i + 1, GetSkinInfo(model_id, S_NAME));
					strcat(text, query);
					SetPlayerListitemValue(playerid, i, id);
				}

                Dialog
                (
                    playerid, 5992, DIALOG_STYLE_LIST,
                    "{FF0000}Продажа",
                    text, 
                    "Далее", "Назад"
                );
            }
        }

        //SCM(playerid, -1, "ТОВАР");
    }
    if(playertextid == auction_PTD[playerid][31])
    {
        if(!player_info_panel[playerid][tovar]) return SCM(playerid, -1, "Сначало выберите товар");
        if(player_info_panel[playerid][opisanie_tovar]) return 0;

        Dialog
        (
            playerid, 5991, DIALOG_STYLE_INPUT,
           "{FF0000}Продажа",
           "Введите описание к Вашему товару, чем лучше описание - тем быстрее Вы сможете продать Ваш товар",
           "Далее","Назад"
        );

        SetPVarInt(playerid, "select_param", 2);
        //SCM(playerid, -1, "ОПИСАНИЕ");
    }
    if(playertextid == auction_PTD[playerid][33])
    {
        new bool:have_sell, list[64], dialog[512];
        new count;

        ClearPlayerListitemValues(playerid);

        for(new c, account = GetPlayerAccountID(playerid);c < MAX_AUCTION_SLOT;c++)
        {
            if(auction_slot[c][OWNER_SLOT_SQL] != account) continue;

            new remaining[12];
            AuctionManager_FormatRemainingTime(auction_slot[c][TIMER_END], remaining, sizeof remaining);
            format(list, sizeof list, "%d. %s \t %s\n", c + 1, auction_slot[c][SLOT_NAME], remaining);
            strcat(dialog, list);
            SetPlayerListitemValue(playerid, count, c);
            count++;
            have_sell = true;
        }

        if(!have_sell) return ShowNotificationNew(playerid, 2, 3, 0, 0, "У вас нет ставок на продажу", "");

        Dialog
        (
            playerid, DIALOG_AUCTION_MY_SALES, DIALOG_STYLE_LIST,
            "{FF0000}Продажи",
            dialog, 
            "Снять", "Выйти"
        );

        //SCM(playerid, -1, "МОИ ПРОДАЖИ");
    }
    if(playertextid == auction_PTD[playerid][34])
    {
        new bool:have_buy, list[48], dialog[284];
        for(new c, account = GetPlayerAccountID(playerid);c < MAX_AUCTION_SLOT;c++)
        {
            if(auction_slot[c][OWNER_RATE] != account) continue;

            new remaining[12];
            AuctionManager_FormatRemainingTime(auction_slot[c][TIMER_END], remaining, sizeof remaining);
            format(list, sizeof list, "%d. %s \t %s\n", c + 1, auction_slot[c][SLOT_NAME], remaining);
            strcat(dialog, list);
            have_buy = true;
        }

        if(!have_buy) return ShowNotificationNew(playerid, 2, 3, 0, 0, "У вас нет ставок на покупку", ""); 

        Dialog
        (
            playerid, -1, DIALOG_STYLE_LIST,
            "{FF0000}Покупки",
            dialog, 
            "Выйти", ""
        );
        //SCM(playerid, -1, "МОИ ПОКУПКА");
    } 
    if(playertextid == auction_PTD[playerid][37])
    {
        new id_slot, dialog[254];

        switch(player_info_panel[playerid][select_slot])
        {
            case 1:id_slot = player_show_slot[playerid][0];
            case 2:id_slot = player_show_slot[playerid][1];
            case 3:id_slot = player_show_slot[playerid][2];
            case 4:id_slot = player_show_slot[playerid][3];
        }

        if(id_slot < 0 || id_slot >= MAX_AUCTION_SLOT || !auction_slot[id_slot][SLOT_TYPE]) return SendClientMessage(playerid, -1, ""SC" Лот не выбран или больше не существует.");

        if(auction_slot[id_slot][TIMER_END] <= gettime()) return SendClientMessage(playerid, -1, ""SC" Время вышло. Лот скоро удалиться.");

        if(GetPlayerMoneyEx(playerid) < auction_slot[id_slot][CURRENT_RATE])
        {
            format(dialog, sizeof dialog, "У вас %d, а нужно %d рублей", GetPlayerMoneyEx(playerid), auction_slot[id_slot][CURRENT_RATE]);
            ShowNotificationNew(playerid, 2, 2, 0, 0, dialog, "");

            return 1;
        }
        else if(auction_slot[id_slot][OWNER_SLOT_SQL] == GetPlayerAccountID(playerid))
        {
            SendClientMessage(playerid, -1, ""SC" Вы не можете сделать ставку на свой лот.");
            return 1;
        }
        else if(auction_slot[id_slot][OWNER_RATE] == GetPlayerAccountID(playerid))
        {
            SendClientMessage(playerid, -1, ""SC" Вы уже сделали ставку.");
            return 1;
        }
        
        switch(auction_slot[id_slot][SLOT_TYPE])
        {
            case TYPE_BUSINESS:
            {
                new max_business = 1 + GetPlayerData(playerid, P_BUSS_SLOTS);
                if(max_business > 2) max_business = 2;
                if(GetPlayerBusinessCount(playerid) >= max_business) return SendClientMessage(playerid, -1, ""SC" Достигнут лимит бизнесов");
            }
            case TYPE_HOUSE:
            {
                if(GetPlayerHouse(playerid) != -1) return SendClientMessage(playerid, -1, ""SC" У вас уже имеется недвижемость");

                for(new i, account = GetPlayerAccountID(playerid); i < MAX_AUCTION_SLOT; i ++)
                {
                    if(auction_slot[i][SLOT_TYPE] != TYPE_HOUSE) continue;
                    else if(auction_slot[i][OWNER_RATE] != account) continue;

                    SendClientMessage(playerid, -1, ""SC" Вы уже делали ставку на другую недвижимость.");
                    return 1;   
                }
            }
            case TYPE_VEHICLE_NUMBER:
            {
                new query[128];
                new Cache: result, rows;

                mysql_format(mysql, query, sizeof query, "SELECT * FROM ownable_cars WHERE number = '------' AND owner_id='%d' LIMIT 1", GetPlayerAccountID(playerid));
                result = mysql_query(mysql, query);
                if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 5");

                rows = cache_num_rows();

                if(!rows) return SendClientMessage(playerid, -1, ""SC" У вас нет транспорта без номерного знака");

                cache_delete(result);
            }
            case TYPE_SUM_NUMBER:
            {
                if(GetPlayerPhone(playerid)) 
                {
                    for(new i; i < 5; i++) SendClientMessage(playerid, -1, ""USC" У вас уже есть сим-карта. При выйгрыше она измениться на новую");
                }
            }
        }

        new price = AuctionBid_GetMinimum(id_slot);

        format(dialog, sizeof dialog,
        "Описание от {FFFF00}продавца: {FFFFFF}%s\n\n"\
        "{FFFFFF}%s: {FFFF00}%s\n\n"\
        "{FFFFFF}Введите сумму которую хотите отдать за данный лот. Минимальная ставка: {FFFF00}%d рублей",
        auction_slot[id_slot][OPISANIE_SLOT], type_slot[auction_slot[id_slot][SLOT_TYPE]], auction_slot[id_slot][SLOT_NAME], 
        price
        );

        Dialog
        (
            playerid, 5990, DIALOG_STYLE_INPUT,
            "{FF0000}Ставка",
            dialog,
            "Далее", "Назад"
        );


        SetPVarInt(playerid, "select_slot", id_slot);

        //SCM(playerid, -1, "ПОСТАВИТЬ");
    }
    if(playertextid == auction_PTD[playerid][38]) 
    {
        Dialog
        (
            playerid, 5993, DIALOG_STYLE_LIST,
            "{FF0000}Фильтр",
            "1. Выбрать тип покупки\n"\
            "2. Выбрать цену покупки",
            "Далее", "Назад"
        );

        player_info_panel[playerid][filter_type] = 0;
        player_info_panel[playerid][filter_tovar_type] = 0;
        player_info_panel[playerid][count_list] = 1;
        LeafAuction(playerid, 3);
    }
    if(playertextid == auction_PTD[playerid][39]) 
    {
        if(!player_info_panel[playerid][price_tovar]) return SendClientMessage(playerid, -1, ""USC" Сначало выберите все");
               
        new type, opisanie[124], start, data_base, server_id, number_veh[7], number_phone;

        type = GetPVarInt(playerid, "type_param");
        
        if(type == TYPE_SUM_NUMBER) number_phone = GetPVarInt(playerid, "tovar_param");

        GetPVarString(playerid, "opisanie_param", opisanie, 124);
        GetPVarString(playerid, "tovar_param_num", number_veh, 7);

        data_base = GetPVarInt(playerid, "tovar_param");
        server_id = GetPVarInt(playerid, "tovar_param_server");
        if(type == TYPE_VEHICLE)
        {
            if(GetPlayerOwnableCar(playerid) != GetPVarInt(playerid, "tovar_param_server"))
                return SendClientMessage(playerid,-1, ""USC" Ваш транспорт выгружен");

            server_id = GetVehicleModel(GetPVarInt(playerid, "tovar_param_server"));
        } 
        
        start = GetPVarInt(playerid, "price_param");
        

        create_auction_slot(playerid, type, opisanie, start, data_base, server_id, number_veh, number_phone);
    }
    if(playertextid == auction_PTD[playerid][35])
    {
        if(player_info_panel[playerid][count_list] == 256) return 1;

        player_info_panel[playerid][count_list]++;

        new all_slot = player_info_panel[playerid][count_list]*4 - 1;

        LeafAuction(playerid, all_slot);
        //UpdateListSlot(playerid, player_info_panel[playerid][count_list]);
        //SCM(playerid, -1, "СЛЕДУЮЩИЙ СПИСОК");
    }
    if(playertextid == auction_PTD[playerid][36])
    {
        if(player_info_panel[playerid][count_list] == 1) return 1;

        player_info_panel[playerid][count_list]--;

        new all_slot = player_info_panel[playerid][count_list]*4 - 1;
        
        LeafAuction(playerid, all_slot);
        //UpdateListSlot(playerid, player_info_panel[playerid][count_list]);
        //SCM(playerid, -1, "ПРЕДЫДУЩИЙ СПИСОК");
    }
	#if defined auc_OnPlayerClickPlayer
		return auc_OnPlayerClickPlayer(playerid, playertextid);
	#else
	    return 0;
	#endif
}
#if defined _ALS_OnPlayerClickPlayerTextD
    #undef OnPlayerClickPlayerTextDraw
#else
    #define _ALS_OnPlayerClickPlayerTextD
#endif
#if defined auc_OnPlayerClickPlayer
	forward auc_OnPlayerClickPlayer(playerid, PlayerText:playertextid);
#endif
#define	OnPlayerClickPlayerTextDraw auc_OnPlayerClickPlayer


CMD:auction(playerid)
{
    if(GetPlayerLevel(playerid) < 3)
        return SendClientMessage(playerid, -1, ""USC" Аукцион доступен с 3 игрового уровня.");

    if(GetPlayerVirtualWorld(playerid) != AUCTION_WORLD)
    {
        EnablePlayerGPS(playerid, 55, 2090.941650,-2283.999511,23.101566, "Местоположение аукциона отмечено на карте.");
        return 1;
    }

    HideTextDrawAuction(playerid);

    if(player_cd_auction[playerid] < gettime()) HideHud(playerid);
    SetPlayerCleanChat(playerid, 1);
    SetPlayerCleanChat(playerid, 0);

    ShowTabBuy(playerid);

    return 1;
}

stock HideTextDrawAuction(playerid)
{
    ShowHud(playerid);
    SetPlayerCleanChat(playerid, 0);

    default_select_slot(playerid);
    switch(player_info_panel[playerid][select_tab])
    {
        case 1:HideTabBuy(playerid);
        case 2:HideTabSell(playerid);
        case 3:HideTabMy(playerid);
    }

    player_info_panel[playerid][count_list] = 1;
    player_info_panel[playerid][show_panel] = false;
    player_info_panel[playerid][select_slot] = 0;
    player_info_panel[playerid][select_type] = 0;
    player_info_panel[playerid][select_tab] = 0;
    player_info_panel[playerid][filter_min_price] = -1;
    player_info_panel[playerid][filter_max_price] = -1;
    player_info_panel[playerid][filter_vehicle_model] = 0;
    player_info_panel[playerid][filter_tovar_type] = 0;
    player_info_panel[playerid][filter_type] = 0;
    player_info_panel[playerid][type_tovar] = false;
    player_info_panel[playerid][price_tovar] = false;
    player_info_panel[playerid][tovar] = false;
    player_info_panel[playerid][opisanie_tovar] = false;

    TogglePlayerControllable(playerid, true);

    return 1;
}

stock ShowTabBuy(playerid)
{
    new time = gettime();
    if(player_cd_auction[playerid] > time) return SendClientMessage(playerid, -1, "Подождите немного...");

    player_cd_auction[playerid] = time+5;
    switch(player_info_panel[playerid][select_tab])
    {
        case 2:HideTabSell(playerid);
        case 3:HideTabMy(playerid);
        case 1:return 1;
    }

    SelectTextDraw(playerid, -1);

    player_info_panel[playerid][select_tab] = 1;

        //load slot auction

    if(player_info_panel[playerid][select_slot])
    {
        new string[34];
        strcat(string, auction_button[0][0]);

        PlayerTextDrawSetString(playerid, auction_PTD[playerid][6], string);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][10], string);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][14], string);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][18], string);

        player_info_panel[playerid][select_slot] = 0;
    }

    for(new p = 1;p < 6;p++) PlayerTextDrawSetString(playerid, auction_PTD[playerid][p], "-");
    
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][27], "1");
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][0], "txd:braucbuy");

    PlayerTextDrawSetString(playerid, auction_PTD[playerid][23], auction_button[1][1]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][24], auction_button[2][0]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][25], auction_button[3][0]);

    //PlayerTextDrawShow(playerid, auction_PTD[playerid][0]);
    // Synchronize newly released businesses before composing the first page.
    AuctionManager_EnsureAllFreeBusinesses();
    new all_slot = player_info_panel[playerid][count_list]*4 - 1;
    LeafAuction(playerid, all_slot);

    for(new t; t < 39; t++)
    {
        if(28 <= t <= 34) continue;

        PlayerTextDrawShow(playerid, auction_PTD[playerid][t]);
    }

    return 1;
}

stock ShowTabSell(playerid)
{
    new time = gettime();
    if(player_cd_auction[playerid] > time) return SendClientMessage(playerid, -1, "Подождите немного...");

    player_cd_auction[playerid] = time+5;
    switch(player_info_panel[playerid][select_tab])
    {
        case 1:HideTabBuy(playerid);
        case 3:HideTabMy(playerid);
        default:return 1;
    }

    SelectTextDraw(playerid, -1);

    player_info_panel[playerid][select_tab] = 2;
    
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][0], "txd:braucsell");

    PlayerTextDrawSetString(playerid, auction_PTD[playerid][23], auction_button[1][0]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][24], auction_button[2][1]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][25], auction_button[3][0]);


    //PlayerTextDrawSetString(playerid, auction_TD[5]);
    
    for(new p = 1;p < 5;p++) PlayerTextDrawSetString(playerid, auction_PTD[playerid][p], "-");
    PlayerTextDrawColor(playerid, auction_PTD[playerid][3], -1);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][5], "Нет");
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][32], "Нет");

    //PlayerTextDrawShow(playerid, auction_PTD[playerid][0]);

    for(new t; t < 5; t++)
    {
        PlayerTextDrawShow(playerid, auction_PTD[playerid][t]);
    }
    for(new t = 28; t < 33; t++)
    {
        PlayerTextDrawShow(playerid, auction_PTD[playerid][t]);
    }

    PlayerTextDrawShow(playerid, auction_PTD[playerid][22]);

    for(new b = 23;b < 27;b++) // цикл для открытия вкладок
    {
        PlayerTextDrawShow(playerid, auction_PTD[playerid][b]);
    }

    PlayerTextDrawShow(playerid, auction_PTD[playerid][39]);

    return 1;
}

stock HideTabSell(playerid)
{
    CancelSelectTextDraw(playerid);
    player_info_panel[playerid][type_tovar] = false;
    player_info_panel[playerid][price_tovar] = false;
    player_info_panel[playerid][tovar] = false;
    player_info_panel[playerid][opisanie_tovar] = false;

    PlayerTextDrawHide(playerid, auction_PTD[playerid][39]);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][3], -1107374134);

    for(new t; t < 6; t++)
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][t]);
    }

    PlayerTextDrawHide(playerid, auction_PTD[playerid][22]);

    for(new t = 28; t < 33; t++)
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][t]);
    }

    for(new b = 23;b < 27;b++) // цикл для открытия вкладок
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][b]);
    }
    return 1;
}

stock HideTabBuy(playerid)
{
    default_select_slot(playerid);
    CancelSelectTextDraw(playerid);
    player_info_panel[playerid][count_list] = 1;
    player_info_panel[playerid][show_panel] = false;
    player_info_panel[playerid][select_slot] = 0;
    player_info_panel[playerid][select_type] = 0;
    player_info_panel[playerid][select_tab] = 0;
    player_info_panel[playerid][filter_min_price] = -1;
    player_info_panel[playerid][filter_max_price] = -1;

    for(new t = 35; t < 39; t++)
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][t]);
    }

    for(new t; t < 28; t++)
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][t]);
    }
    return 1;
}

stock HideTabMy(playerid)
{
    CancelSelectTextDraw(playerid);

    PlayerTextDrawDestroy(playerid, auction_PTD[playerid][0]);
    for(new i = 23;i < 27;i++) PlayerTextDrawDestroy(playerid, auction_PTD[playerid][i]);
    
    auction_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 27.3333, 100.2444, "txd:braucbuy"); // фон / основа
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][0], 588.0000, 294.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][0], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][0], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][0], 0);

    auction_PTD[playerid][23] = CreatePlayerTextDraw(playerid, 43.3333, 125.1333, "txd:braucubuy"); // вклада покупки
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][23], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][23], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][23], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][23], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][23], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][23], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][23], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][23], 1);

    auction_PTD[playerid][24] = CreatePlayerTextDraw(playerid, 43.3333, 170.3481, "txd:braucnusell"); // вкладка продажа
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][24], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][24], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][24], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][24], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][24], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][24], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][24], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][24], 1);

    auction_PTD[playerid][25] = CreatePlayerTextDraw(playerid, 43.6666, 216.8074, "txd:braucnumy"); // вкладка мои
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][25], 109.0000, 61.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][25], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][25], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][25], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][25], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][25], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][25], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][25], 1);

    auction_PTD[playerid][26] = CreatePlayerTextDraw(playerid, 43.3333, 285.6667, "txd:braucexit"); // выйти
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][26], 109.0000, 62.0000);
    PlayerTextDrawAlignment(playerid, auction_PTD[playerid][26], 1);
    PlayerTextDrawColor(playerid, auction_PTD[playerid][26], -1);
    PlayerTextDrawBackgroundColor(playerid, auction_PTD[playerid][26], 255);
    PlayerTextDrawFont(playerid, auction_PTD[playerid][26], 4);
    PlayerTextDrawSetProportional(playerid, auction_PTD[playerid][26], 0);
    PlayerTextDrawSetShadow(playerid, auction_PTD[playerid][26], 0);
    PlayerTextDrawSetSelectable(playerid, auction_PTD[playerid][26], 1);

    PlayerTextDrawHide(playerid, auction_PTD[playerid][0]);

    for(new t = 23; t < 27;t++)
    {
        PlayerTextDrawHide(playerid, auction_PTD[playerid][t]);
    }
    
    PlayerTextDrawHide(playerid, auction_PTD[playerid][33]);
    PlayerTextDrawHide(playerid, auction_PTD[playerid][34]);

    return 1;
}

stock ShowTabMy(playerid)
{
    new time = gettime();
    if(player_cd_auction[playerid] > time) return SendClientMessage(playerid, -1, "Подождите немного...");

    player_cd_auction[playerid] = time+5;
    switch(player_info_panel[playerid][select_tab])
    {
        case 1:HideTabBuy(playerid);
        case 2:HideTabSell(playerid);
        default:return 1;
    }

    SelectTextDraw(playerid, -1);

    player_info_panel[playerid][select_tab] = 3;

    PlayerTextDrawDestroy(playerid, auction_PTD[playerid][0]);
    for(new i = 23;i < 27;i++) PlayerTextDrawDestroy(playerid, auction_PTD[playerid][i]);

    auction_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 83.9999, 103.5629, "txd:braucmy"); // пусто
    PlayerTextDrawTextSize(playerid, auction_PTD[playerid][0], 462.0000, 256.0000);
    PlayerTextDrawAlignment(playerid,auction_PTD[playerid][0], 1);
    PlayerTextDrawColor(playerid,auction_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid,auction_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid,auction_PTD[playerid][0], 4);
    PlayerTextDrawSetProportional(playerid,auction_PTD[playerid][0], 0);
    PlayerTextDrawSetShadow(playerid,auction_PTD[playerid][0], 0);

    auction_PTD[playerid][23] = CreatePlayerTextDraw(playerid,97.3332, 115.5925, "txd:braucnubuy"); // пусто
    PlayerTextDrawTextSize(playerid,auction_PTD[playerid][23], 120.0000, 68.0000);
    PlayerTextDrawAlignment(playerid,auction_PTD[playerid][23], 1);
    PlayerTextDrawColor(playerid,auction_PTD[playerid][23], -1);
    PlayerTextDrawBackgroundColor(playerid,auction_PTD[playerid][23], 255);
    PlayerTextDrawFont(playerid,auction_PTD[playerid][23], 4);
    PlayerTextDrawSetProportional(playerid,auction_PTD[playerid][23], 0);
    PlayerTextDrawSetShadow(playerid,auction_PTD[playerid][23], 0);
    PlayerTextDrawSetSelectable(playerid,auction_PTD[playerid][23], 1);

    auction_PTD[playerid][24] = CreatePlayerTextDraw(playerid,97.6666, 164.5406, "txd:braucnusell"); // пусто
    PlayerTextDrawTextSize(playerid,auction_PTD[playerid][24], 120.0000, 68.0000);
    PlayerTextDrawAlignment(playerid,auction_PTD[playerid][24], 1);
    PlayerTextDrawColor(playerid,auction_PTD[playerid][24], -1);
    PlayerTextDrawBackgroundColor(playerid,auction_PTD[playerid][24], 255);
    PlayerTextDrawFont(playerid,auction_PTD[playerid][24], 4);
    PlayerTextDrawSetProportional(playerid,auction_PTD[playerid][24], 0);
    PlayerTextDrawSetShadow(playerid,auction_PTD[playerid][24], 0);
    PlayerTextDrawSetSelectable(playerid,auction_PTD[playerid][24], 1);

    auction_PTD[playerid][25] = CreatePlayerTextDraw(playerid,97.6666, 213.4888, "txd:braucumy"); // пусто
    PlayerTextDrawTextSize(playerid,auction_PTD[playerid][25], 120.0000, 68.0000);
    PlayerTextDrawAlignment(playerid,auction_PTD[playerid][25], 1);
    PlayerTextDrawColor(playerid,auction_PTD[playerid][25], -1);
    PlayerTextDrawBackgroundColor(playerid,auction_PTD[playerid][25], 255);
    PlayerTextDrawFont(playerid,auction_PTD[playerid][25], 4);
    PlayerTextDrawSetProportional(playerid,auction_PTD[playerid][25], 0);
    PlayerTextDrawSetShadow(playerid,auction_PTD[playerid][25], 0);
    PlayerTextDrawSetSelectable(playerid,auction_PTD[playerid][25], 1);

    auction_PTD[playerid][26] = CreatePlayerTextDraw(playerid,97.6666, 272.3926, "txd:braucexit"); // пусто
    PlayerTextDrawTextSize(playerid,auction_PTD[playerid][26], 120.0000, 62.0000);
    PlayerTextDrawAlignment(playerid,auction_PTD[playerid][26], 1);
    PlayerTextDrawColor(playerid,auction_PTD[playerid][26], -1);
    PlayerTextDrawBackgroundColor(playerid,auction_PTD[playerid][26], 255);
    PlayerTextDrawFont(playerid,auction_PTD[playerid][26], 4);
    PlayerTextDrawSetProportional(playerid,auction_PTD[playerid][26], 0);
    PlayerTextDrawSetShadow(playerid,auction_PTD[playerid][26], 1);
    PlayerTextDrawSetSelectable(playerid,auction_PTD[playerid][26], 1);

    PlayerTextDrawShow(playerid, auction_PTD[playerid][0]);

    for(new t = 23; t < 27;t++)
    {
        PlayerTextDrawShow(playerid, auction_PTD[playerid][t]);
    }

    PlayerTextDrawShow(playerid, auction_PTD[playerid][33]);
    PlayerTextDrawShow(playerid, auction_PTD[playerid][34]);
    
    return 1;
}

public:AuctionUpdate()
{
    if(!load_business_action)
    {
        AuctionManager_InitDatabase();
        LoadBusinessToAuction();
    }

    new hour;

    gettime(hour);

    //if(hour >= 22) return 0;

    for(new slot;slot < MAX_AUCTION_SLOT; slot++)
    {
        if(!auction_slot[slot][SLOT_TYPE]) continue;

        if(auction_slot[slot][TIMER_END] <= gettime()) finish_auction_slot(slot);
    }

    // Keep the opened details panel live; previously the value changed only
    // after clicking another lot, so "1 hour" could remain on screen forever.
    foreach(new playerid : Player)
    {
        if(!player_info_panel[playerid][show_panel]) continue;
        new selected = player_info_panel[playerid][select_slot];
        if(selected < 1 || selected > 4) continue;
        new slot = player_show_slot[playerid][selected - 1];
        if(slot < 0 || slot >= MAX_AUCTION_SLOT || !auction_slot[slot][SLOT_TYPE]) continue;
        new remaining[12];
        AuctionManager_FormatRemainingTime(auction_slot[slot][TIMER_END], remaining, sizeof remaining);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][5], remaining);
    }

    // A business may become state-owned while the server is already running.
    // Keep the public auction complete without requiring a gamemode restart.
    if(auction_last_free_business_sync <= gettime())
    {
        auction_last_free_business_sync = gettime() + 15;
        AuctionManager_EnsureAllFreeBusinesses();
    }

    return 1;
}

stock AuctionItem_IsOwnedBy(type, data_base, server_id, const number_vehicle[], number_sum, accountid)
{
    if(accountid <= 0) return 0;
    if(type == TYPE_HOUSE)
        return 0 <= server_id < MAX_HOUSES && GetHouseData(server_id, H_SQL_ID) == data_base && GetHouseData(server_id, H_OWNER_ID) == accountid;
    if(type == TYPE_SUM_NUMBER)
    {
        new query[128], Cache:result;
        mysql_format(mysql, query, sizeof query, "SELECT id FROM accounts WHERE id=%d AND phone=%d LIMIT 1", accountid, number_sum);
        result = mysql_query(mysql, query, true);
        new valid = !mysql_errno() && cache_num_rows() == 1;
        cache_delete(result);
        return valid;
    }

    new query[192], Cache:result;
    switch(type)
    {
        case TYPE_VEHICLE: mysql_format(mysql, query, sizeof query, "SELECT id FROM ownable_cars WHERE id=%d AND owner_id=%d AND model_id=%d LIMIT 1", data_base, accountid, server_id);
        case TYPE_VEHICLE_NUMBER: mysql_format(mysql, query, sizeof query, "SELECT id FROM ownable_cars WHERE id=%d AND owner_id=%d AND number='%e' LIMIT 1", data_base, accountid, number_vehicle);
        case TYPE_CLOTHES: mysql_format(mysql, query, sizeof query, "SELECT id FROM inventory_skins WHERE id=%d AND owner_skin=%d AND skin_id=%d AND use_skin=0 LIMIT 1", data_base, accountid, server_id);
        default: return 0;
    }
    result = mysql_query(mysql, query, true);
    new valid = !mysql_errno() && cache_num_rows() == 1;
    cache_delete(result);
    return valid;
}
stock AuctionBuyerCanReceive(type, accountid)
{
    if(accountid <= 0) return 0;
    new query[256], Cache:result;
    switch(type)
    {
        case TYPE_BUSINESS: mysql_format(mysql, query, sizeof query, "SELECT id FROM accounts WHERE id=%d AND (SELECT COUNT(*) FROM business WHERE owner_id=%d) < LEAST(2,1+buss_slots) LIMIT 1", accountid, accountid);
        case TYPE_HOUSE: mysql_format(mysql, query, sizeof query, "SELECT id FROM accounts WHERE id=%d AND house=-1 LIMIT 1", accountid);
        case TYPE_VEHICLE_NUMBER: mysql_format(mysql, query, sizeof query, "SELECT id FROM ownable_cars WHERE owner_id=%d AND number='------' LIMIT 1", accountid);
        default: return 1;
    }
    result = mysql_query(mysql, query, true);
    new valid = !mysql_errno() && cache_num_rows() > 0;
    cache_delete(result);
    return valid;
}
stock create_auction_slot(playerid, type, opisanie[124], start_rate, data_base, server_id, number_vehicle[7] = "", number_SUM = 0)
{
    new id = -1, bool:stop_create;
    new business_source = GetPVarInt(playerid, "auction_business_source");
    if(!AuctionManager_IsBiddingTime())
        return SendClientMessage(playerid, -1, ""SC" Выставлять лоты можно с 08:00 до 23:00 GMT+3.");
    if(type < TYPE_BUSINESS || type > TYPE_CLOTHES || start_rate < 5000 || start_rate > 1000000000)
        return SendClientMessage(playerid, -1, ""SC" Некорректные параметры или начальная цена лота.");
    if(type != TYPE_BUSINESS && !AuctionItem_IsOwnedBy(type, data_base, server_id, number_vehicle, number_SUM, GetPlayerAccountID(playerid)))
        return SendClientMessage(playerid, -1, ""SC" Товар не найден или больше вам не принадлежит.");

    if(type == TYPE_BUSINESS)
    {
        if(business_source == AUCTION_BUSINESS_SOURCE_FUEL)
        {
            if(server_id < 0 || server_id >= g_fuel_station_loaded
                || GetFuelStationData(server_id, FS_SQL_ID) != data_base
                || GetFuelStationData(server_id, FS_OWNER_ID) != GetPlayerAccountID(playerid))
                return SendClientMessage(playerid, -1, ""SC" АЗС не найдена или больше вам не принадлежит.");
        }
        else
        {
            new error[96];
            if(!BusinessManager_CanSell(playerid, server_id, error, sizeof error)
                || GetBusinessData(server_id, B_SQL_ID) != data_base)
                return SendClientMessage(playerid, -1, error);
        }
    }

    PlayerTextDrawSetString(playerid, auction_PTD[playerid][31], auction_button[6][0]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][30], auction_button[5][0]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][28], auction_button[7][0]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][29], auction_button[4][0]);

    DeletePVar(playerid, "opisanie_param");
    DeletePVar(playerid, "tovar_param_num");
    DeletePVar(playerid, "type_param");
    DeletePVar(playerid, "tovar_param_server");
    DeletePVar(playerid, "price_param");
    DeletePVar(playerid, "tovar_param");
    DeletePVar(playerid, "select_type");
    DeletePVar(playerid, "auction_business_source");

    for(new pon = 1; pon < 6;pon++)
    {
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][pon], "-");
    }

    for(new s;s < MAX_AUCTION_SLOT;s++)
    {
        if(auction_slot[s][OWNER_SLOT_SQL] == GetPlayerAccountID(playerid))
        {
            if(auction_slot[s][DATABASE_ID] == data_base && auction_slot[s][SERVER_ID] == server_id)
            {
                if(auction_slot[s][SLOT_TYPE] == type)
                {
                    stop_create = true;
                    break;
                } 
                
            }

            if(auction_slot[s][SLOT_TYPE] == TYPE_VEHICLE_NUMBER)
            {
                if(!strcmp(number_vehicle, auction_slot[s][NUMBER_VEHICLE], true))
                {
                    stop_create = true;
                    break;
                }
            }
            
            if(auction_slot[s][SLOT_TYPE] == TYPE_SUM_NUMBER)
            {
                if(auction_slot[s][NUMBER_SUM] == number_SUM)
                {
                    stop_create = true;
                    break;
                }
            }
        }
        
    }

    if(stop_create) return SendClientMessage(playerid, -1, ""USC" Вы уже выставляли данный товар.");

    for(new s; s < MAX_AUCTION_SLOT;s++)
    {
        if(auction_slot[s][SLOT_TYPE] >= 1) continue;
        
        id = s;        
        break;
    }

    if(id == -1) return SendClientMessage(playerid, -1, ""SC" В данный момент достигнут лимит слотов в аукционе.");

    auction_slot[id][OWNER_SLOT_SQL] = GetPlayerAccountID(playerid);
    auction_slot[id][SLOT_TYPE] = type;
    auction_slot[id][START_RATE] = start_rate;
    auction_slot[id][CURRENT_RATE] = start_rate;
    auction_slot[id][DATABASE_ID] = data_base;
    auction_slot[id][SERVER_ID] = server_id;
    auction_slot[id][BUSINESS_SOURCE_SLOT] = business_source;
    auction_slot[id][OWNER_RATE] = -1;
    format(auction_slot[id][OWNER_SLOT_NAME], 24, GetPlayerNameEx(playerid));
    format(auction_slot[id][OPISANIE_SLOT], 124, opisanie);

    auction_slot[id][TIMER_END] = AuctionManager_GetTodayFinishTime();
    if(!auction_slot[id][TIMER_END])
    {
        reset_slot_auction(id);
        return SendClientMessage(playerid, -1, ""SC" Торги на сегодня уже завершены.");
    }

    switch(type)
    {
        case TYPE_BUSINESS:
        {
            if(business_source == AUCTION_BUSINESS_SOURCE_FUEL)
            {
                AuctionBusiness_FormatLotName(AUCTION_BUSINESS_SOURCE_FUEL,
                    server_id, auction_slot[id][SLOT_NAME], 64);
                auction_slot[id][BUSINESS_TYPE_SLOT] = 1000;
            }
            else
            {
                AuctionBusiness_FormatLotName(AUCTION_BUSINESS_SOURCE_REGULAR,
                    server_id, auction_slot[id][SLOT_NAME], 64);
                auction_slot[id][BUSINESS_TYPE_SLOT] = GetBusinessData(server_id, B_TYPE);
            }
            new query[768], Cache:insert_result;
            mysql_format(mysql, query, sizeof query,
                "INSERT INTO auction_lots (server_id,item_type,item_database_id,business_type,seller_account_id,seller_name,item_name,description,start_price,current_price,highest_bidder_account_id,highest_bidder_name,commission_percent,created_at,ends_at,status) VALUES (%d,%d,%d,%d,%d,'%e','%e','%e',%d,%d,-1,'',%d,%d,%d,'active')",
                auction_slot[id][SERVER_ID], TYPE_BUSINESS, auction_slot[id][DATABASE_ID], auction_slot[id][BUSINESS_TYPE_SLOT],
                auction_slot[id][OWNER_SLOT_SQL], auction_slot[id][OWNER_SLOT_NAME],
                auction_slot[id][SLOT_NAME], auction_slot[id][OPISANIE_SLOT],
                auction_slot[id][START_RATE], auction_slot[id][CURRENT_RATE],
                AUCTION_COMMISSION_PERCENT, gettime(), auction_slot[id][TIMER_END]);
            insert_result = mysql_query(mysql, query, true);
            if(mysql_errno())
            {
                cache_delete(insert_result);
                reset_slot_auction(id);
                return SendClientMessage(playerid, -1, ""SC" Не удалось сохранить лот. Попробуйте позднее.");
            }
            auction_slot[id][AUCTION_DB_ID] = cache_insert_id();
            cache_delete(insert_result);
            CallLocalFunction("UpdateBusinessLabel", "i", auction_slot[id][SERVER_ID]);
        }
        case TYPE_VEHICLE:
        {
            
            new id_model = server_id - 400;

            format(auction_slot[id][SLOT_NAME], 24, ProbelText(GetVehicleInfo(id_model, VI_NAME)));
            UnloadPlayerOwnableCar(playerid);
        }
        case TYPE_HOUSE:
        {
            for(new s;s < MAX_HOUSES;s++)
            {
                if(GetHouseData(s, H_SQL_ID) == data_base)
                {
                    auction_slot[id][SERVER_ID] = s;
                    format(auction_slot[id][SLOT_NAME], 24, "Дом_(%d)", s);
                    break;
                }
            }
        }
        case TYPE_VEHICLE_NUMBER:
        {
            format(auction_slot[id][SLOT_NAME], 24, number_vehicle);
            format(auction_slot[id][NUMBER_VEHICLE], 7, number_vehicle);
        }
        case TYPE_SUM_NUMBER:
        {
            auction_slot[id][NUMBER_SUM] = number_SUM;

            new sum[6];
            valstr(sum, number_SUM);
            format(auction_slot[id][SLOT_NAME], 24, sum);
        }
        case TYPE_CLOTHES:
        {
            format(auction_slot[id][SLOT_NAME], 24, GetSkinName(server_id));
        }
    }



    if(auction_slot[id][AUCTION_DB_ID] <= 0)
    {
        new persist_query[768], Cache:persist_result;
        mysql_format(mysql, persist_query, sizeof persist_query,
            "INSERT INTO auction_lots (server_id,item_type,item_database_id,business_type,seller_account_id,seller_name,item_name,description,start_price,current_price,highest_bidder_account_id,highest_bidder_name,commission_percent,created_at,ends_at,status) VALUES (%d,%d,%d,0,%d,'%e','%e','%e',%d,%d,-1,'',%d,%d,%d,'active')",
            auction_slot[id][SERVER_ID], auction_slot[id][SLOT_TYPE], auction_slot[id][DATABASE_ID],
            auction_slot[id][OWNER_SLOT_SQL], auction_slot[id][OWNER_SLOT_NAME], auction_slot[id][SLOT_NAME],
            auction_slot[id][OPISANIE_SLOT], auction_slot[id][START_RATE], auction_slot[id][CURRENT_RATE],
            AUCTION_COMMISSION_PERCENT, gettime(), auction_slot[id][TIMER_END]);
        persist_result = mysql_query(mysql, persist_query, true);
        if(mysql_errno())
        {
            cache_delete(persist_result);
            reset_slot_auction(id);
            return SendClientMessage(playerid, -1, ""SC" Не удалось сохранить лот. Попробуйте позднее.");
        }
        auction_slot[id][AUCTION_DB_ID] = cache_insert_id();
        cache_delete(persist_result);
    }
    SendClientMessage(playerid, -1, ""SC" Вы выставили слот на аукцион");

    return 1;
}

stock finish_auction_slot(slot)
{
    if(slot < 0 || slot >= MAX_AUCTION_SLOT || !auction_slot[slot][SLOT_TYPE]) return 0;
    if(auction_slot_busy[slot]) return 0;
    auction_slot_busy[slot] = true;

    if(auction_slot[slot][OWNER_RATE] == -1)
    {
        // State businesses must always remain available. With no bids, start a
        // fresh one-hour period in the same slot instead of removing the lot.
        if(auction_slot[slot][SLOT_TYPE] == TYPE_BUSINESS
            && auction_slot[slot][OWNER_SLOT_SQL] == 0)
        {
            auction_slot[slot][TIMER_END] = AuctionManager_GetTodayFinishTime();
            if(auction_slot[slot][AUCTION_DB_ID] > 0)
            {
                new renew_query[256];
                mysql_format(mysql, renew_query, sizeof renew_query,
                    "UPDATE auction_lots SET ends_at=%d,status='active' WHERE id=%d",
                    auction_slot[slot][TIMER_END], auction_slot[slot][AUCTION_DB_ID]);
                mysql_query(mysql, renew_query, false);
            }
            auction_slot_busy[slot] = false;
            return 1;
        }

        if(auction_slot[slot][AUCTION_DB_ID] > 0)
        {
            new expire_query[512];
            mysql_format(mysql, expire_query, sizeof expire_query,
                "UPDATE auction_lots SET status='expired_no_bids' WHERE id=%d AND status='active'",
                auction_slot[slot][AUCTION_DB_ID]);
            mysql_query(mysql, expire_query, false);
            mysql_format(mysql, expire_query, sizeof expire_query,
                "INSERT INTO auction_history (auction_id,business_id,seller_account_id,buyer_account_id,final_price,commission,result,completed_at) VALUES (%d,%d,%d,-1,0,0,'expired_no_bids',%d)",
                auction_slot[slot][AUCTION_DB_ID], auction_slot[slot][DATABASE_ID],
                auction_slot[slot][OWNER_SLOT_SQL], gettime());
            mysql_query(mysql, expire_query, false);
        }
        auction_slot_busy[slot] = false;
        reset_slot_auction(slot);
        return 1;
    }

    if(auction_slot[slot][SLOT_TYPE] == TYPE_BUSINESS)
    {
        new businessid = auction_slot[slot][SERVER_ID];
        if(auction_slot[slot][AUCTION_DB_ID] > 0)
        {
            new processing_query[256];
            mysql_format(mysql, processing_query, sizeof processing_query,
                "UPDATE auction_lots SET status='processing' WHERE id=%d AND status='active'",
                auction_slot[slot][AUCTION_DB_ID]);
            mysql_query(mysql, processing_query, false);
        }
        new bool:item_valid;
        if(auction_slot[slot][BUSINESS_SOURCE_SLOT] == AUCTION_BUSINESS_SOURCE_FUEL)
        {
            item_valid = 0 <= businessid < g_fuel_station_loaded
                && GetFuelStationData(businessid, FS_SQL_ID) == auction_slot[slot][DATABASE_ID]
                && GetFuelStationData(businessid, FS_OWNER_ID) == auction_slot[slot][OWNER_SLOT_SQL];
        }
        else
        {
            item_valid = AuctionBusiness_IsAuctionable(businessid)
                && GetBusinessData(businessid, B_SQL_ID) == auction_slot[slot][DATABASE_ID]
                && GetBusinessData(businessid, B_OWNER_ID) == auction_slot[slot][OWNER_SLOT_SQL];
        }
        if(!item_valid)
        {
            AuctionRefundBid(slot, "Казино недоступно, ставка возвращена.");
            if(auction_slot[slot][AUCTION_DB_ID] > 0)
            {
                new cancel_query[256];
                mysql_format(mysql, cancel_query, sizeof cancel_query,
                    "UPDATE auction_lots SET status='cancelled_invalid_business' WHERE id=%d",
                    auction_slot[slot][AUCTION_DB_ID]);
                mysql_query(mysql, cancel_query, false);
            }
            auction_slot_busy[slot] = false;
            reset_slot_auction(slot);
            return 1;
        }

        new final_price = auction_slot[slot][CURRENT_RATE];
        new commission = final_price / 100 * AUCTION_COMMISSION_PERCENT;
        new seller_money = final_price - commission;
        new transfer_result;
        if(auction_slot[slot][BUSINESS_SOURCE_SLOT] == AUCTION_BUSINESS_SOURCE_FUEL)
            transfer_result = AuctionTransferFuelStation(businessid, auction_slot[slot][DATABASE_ID],
                auction_slot[slot][OWNER_SLOT_SQL], auction_slot[slot][OWNER_RATE]);
        else
            transfer_result = AuctionTransferBusiness(businessid, auction_slot[slot][DATABASE_ID],
                auction_slot[slot][OWNER_SLOT_SQL], auction_slot[slot][OWNER_RATE]);
        if(!transfer_result)
        {
            // Never destroy a valid winning bid because of a temporary transfer
            // failure. The money stays reserved and the same winner is retried.
            auction_slot[slot][TIMER_END] = gettime() + 60;
            if(auction_slot[slot][AUCTION_DB_ID] > 0)
            {
                new retry_query[256];
                mysql_format(mysql, retry_query, sizeof retry_query,
                    "UPDATE auction_lots SET status='active',ends_at=%d WHERE id=%d AND status='processing'",
                    auction_slot[slot][TIMER_END], auction_slot[slot][AUCTION_DB_ID]);
                mysql_query(mysql, retry_query, false);
            }
            printf("[AUCTION][RETRY] transfer failed: slot=%d lot=%d buyer=%d",
                slot, auction_slot[slot][AUCTION_DB_ID], auction_slot[slot][OWNER_RATE]);
            auction_slot_busy[slot] = false;
            return 0;
        }

        if(auction_slot[slot][OWNER_SLOT_SQL] > 0)
        {
            AuctionGiveAccountMoney(auction_slot[slot][OWNER_SLOT_SQL], seller_money,
                "Продажа бизнеса на аукционе");
        }

        new history_query[512];
        mysql_format(mysql, history_query, sizeof history_query,
            "UPDATE auction_lots SET status='completed' WHERE id=%d",
            auction_slot[slot][AUCTION_DB_ID]);
        mysql_query(mysql, history_query, false);
        mysql_format(mysql, history_query, sizeof history_query,
            "UPDATE auction_bids SET status='won' WHERE auction_id=%d AND bidder_account_id=%d AND status='active'",
            auction_slot[slot][AUCTION_DB_ID], auction_slot[slot][OWNER_RATE]);
        mysql_query(mysql, history_query, false);
        mysql_format(mysql, history_query, sizeof history_query,
            "INSERT INTO auction_history (auction_id,business_id,seller_account_id,buyer_account_id,final_price,commission,result,completed_at) VALUES (%d,%d,%d,%d,%d,%d,'completed',%d)",
            auction_slot[slot][AUCTION_DB_ID],
            auction_slot[slot][DATABASE_ID], auction_slot[slot][OWNER_SLOT_SQL],
            auction_slot[slot][OWNER_RATE], final_price, commission, gettime());
        mysql_query(mysql, history_query, false);

        auction_slot_busy[slot] = false;
        reset_slot_auction(slot);
        return 1;
    }

    new legacy_type = auction_slot[slot][SLOT_TYPE];
    new seller_account = auction_slot[slot][OWNER_SLOT_SQL];
    new buyer_account = auction_slot[slot][OWNER_RATE];
    new final_price = auction_slot[slot][CURRENT_RATE];
    new commission = final_price / 100 * AUCTION_COMMISSION_PERCENT;
    new seller_money = final_price - commission;
    new auction_db_id = auction_slot[slot][AUCTION_DB_ID];
    new item_database_id = auction_slot[slot][DATABASE_ID];

    if(!AuctionItem_IsOwnedBy(legacy_type, item_database_id, auction_slot[slot][SERVER_ID], auction_slot[slot][NUMBER_VEHICLE], auction_slot[slot][NUMBER_SUM], seller_account)
        || !AuctionBuyerCanReceive(legacy_type, buyer_account))
    {
        AuctionRefundBid(slot, "Лот не может быть передан. Ставка возвращена.");
        if(auction_db_id > 0)
        {
            new invalid_query[160];
            mysql_format(mysql, invalid_query, sizeof invalid_query, "UPDATE auction_lots SET status='cancelled_invalid_item' WHERE id=%d", auction_db_id);
            mysql_query(mysql, invalid_query, false);
        }
        auction_slot_busy[slot] = false;
        reset_slot_auction(slot);
        return 1;
    }

    new query[256];
    switch(auction_slot[slot][SLOT_TYPE])
    {
        case TYPE_BUSINESS:
        {
            foreach(new i : Player)
            {
                if(auction_slot[slot][OWNER_RATE] == GetPlayerAccountID(i)) SendClientMessage(i, -1, ""SC" Поздравляем! Вы получили бизнес с аукциона");
            }

            AuctionBusiness(auction_slot[slot][OWNER_RATE], slot);
        }
        case TYPE_HOUSE:
        {
            foreach(new i : Player)
            {
                if(auction_slot[slot][OWNER_RATE] == GetPlayerAccountID(i)) SendClientMessage(i, -1, ""SC" Поздравляем! Вы получили недвижимость с аукциона");
            }

            if(!AuctionHouse(slot, auction_slot[slot][OWNER_RATE], auction_slot[slot][SERVER_ID]))
            {
                auction_slot[slot][TIMER_END] = gettime() + 60;
                auction_slot_busy[slot] = false;
                printf("[AUCTION][RETRY] House transfer failed: slot=%d lot=%d", slot, auction_db_id);
                return 0;
            }
        }
        case TYPE_VEHICLE:
        {
            foreach(new i : Player)
            {
                if(auction_slot[slot][OWNER_RATE] == GetPlayerAccountID(i)) SendClientMessage(i, -1, ""SC" Поздравляем! Вы получили транспорт с аукциона");
            }

            mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET owner_id=%d WHERE id=%d AND owner_id=%d", auction_slot[slot][OWNER_RATE], auction_slot[slot][DATABASE_ID], auction_slot[slot][OWNER_SLOT_SQL]);
            mysql_query(mysql, query, false);

            /*mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET owner_id=%d WHERE id=%d AND owner_id=%d", auction_slot[slot][OWNER_RATE], auction_slot[slot][DATABASE_ID], auction_slot[slot][OWNER_SLOT_SQL]);
            mysql_query(mysql, query, false);*/

            reset_slot_auction(slot);
            if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 7");
        }
        case TYPE_VEHICLE_NUMBER:
        {
            foreach(new i : Player)
            {
                if(GetPlayerAccountID(i) == auction_slot[slot][OWNER_RATE]) SendClientMessage(i, -1, ""SC" Поздравляем! Вы приобрели на номерной знак");
                if(GetPlayerAccountID(i) == auction_slot[slot][OWNER_SLOT_SQL]) SendClientMessage(i, -1, ""SC" Поздравляем! Вы продали на номерной знак");
            }

            mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET number='%e' WHERE owner_id='%d' AND number = '------' LIMIT 1", auction_slot[slot][NUMBER_VEHICLE], auction_slot[slot][OWNER_RATE]);
            mysql_query(mysql, query, false);
            if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 8");

            mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET number='------' WHERE owner_id='%d' AND number = '%e' LIMIT 1", auction_slot[slot][OWNER_SLOT_SQL], auction_slot[slot][NUMBER_VEHICLE]);
            mysql_query(mysql, query, false);
            
            if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 8.1");

            reset_slot_auction(slot);
        }
        case TYPE_SUM_NUMBER:
        {

            foreach(new i : Player)
            {
                if(GetPlayerAccountID(i) == auction_slot[slot][OWNER_RATE])
                {
                    SetPlayerData(i, P_PHONE, auction_slot[slot][NUMBER_SUM]);
                    SendClientMessage(i, -1, ""SC" Поздравляем! Вы приобрели на аукционе сим-карту");
                }

                if(GetPlayerAccountID(i) == auction_slot[slot][OWNER_SLOT_SQL])
                {
                    SetPlayerData(i, P_PHONE, 0);
                    SendClientMessage(i, -1, ""SC" Поздравляем! Вы продали на аукционе сим-карту");
                }
            }

            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET phone = %d WHERE id = %d", auction_slot[slot][NUMBER_SUM], auction_slot[slot][OWNER_RATE]);
            mysql_query(mysql, query, false);
            if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 9");

            mysql_format(mysql, query, sizeof query, "UPDATE accounts SET phone = 0 WHERE id = %d", auction_slot[slot][OWNER_SLOT_SQL]);
            mysql_query(mysql, query, false);
            if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 9.1");

            reset_slot_auction(slot);
        }
        case TYPE_CLOTHES:
        {
            foreach(new i : Player)
            {
                if(GetPlayerAccountID(i) == auction_slot[slot][OWNER_RATE]) SendClientMessage(i, -1, ""SC" Поздравляем! Вы приобрели на аукционе одежду");
                if(GetPlayerAccountID(i) == auction_slot[slot][OWNER_SLOT_SQL]) SendClientMessage(i, -1, ""SC" Поздравляем! Вы продали на аукционе одежду");
            }

            new fmt_text[144],
            Cache: result;

            mysql_format(mysql, query, sizeof query, "INSERT INTO inventory_skins (owner_skin,skin_id) VALUES (%d,%d)", auction_slot[slot][OWNER_RATE], auction_slot[slot][SERVER_ID]);
            mysql_query(mysql, query, false);
            if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 10");

            mysql_format(mysql, query, sizeof query, "DELETE FROM inventory_skins WHERE id = %d", auction_slot[slot][DATABASE_ID]);
            mysql_query(mysql, query, false);
            if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 10.1");

            reset_slot_auction(slot);
        }
        
    }

    if(seller_account > 0 && !AuctionGiveAccountMoney(seller_account, seller_money, "Продажа лота на аукционе"))
        print("[AUCTION] Critical: failed to pay legacy lot seller");
    if(auction_db_id > 0)
    {
        new complete_query[512];
        mysql_format(mysql, complete_query, sizeof complete_query, "UPDATE auction_lots SET status='completed' WHERE id=%d", auction_db_id);
        mysql_query(mysql, complete_query, false);
        mysql_format(mysql, complete_query, sizeof complete_query, "UPDATE auction_bids SET status='won' WHERE auction_id=%d AND bidder_account_id=%d AND status='active'", auction_db_id, buyer_account);
        mysql_query(mysql, complete_query, false);
        mysql_format(mysql, complete_query, sizeof complete_query, "INSERT INTO auction_history (auction_id,business_id,seller_account_id,buyer_account_id,final_price,commission,result,completed_at) VALUES (%d,%d,%d,%d,%d,%d,'completed',%d)", auction_db_id, item_database_id, seller_account, buyer_account, final_price, commission, gettime());
        mysql_query(mysql, complete_query, false);
    }
    return 1;
}

stock AuctionCancelSlot(slot, requester_account_id = -1)
{
    if(slot < 0 || slot >= MAX_AUCTION_SLOT) return 0;
    if(!auction_slot[slot][SLOT_TYPE]) return 0;
    if(requester_account_id != -1 && auction_slot[slot][OWNER_SLOT_SQL] != requester_account_id) return 0;
    if(auction_slot_busy[slot]) return 0;
    if(auction_slot[slot][OWNER_RATE] != -1)
    {
        foreach(new i : Player)
        {
            if(GetPlayerAccountID(i) == auction_slot[slot][OWNER_SLOT_SQL])
                SendClientMessage(i, -1, ""SC" Нельзя снять казино с аукциона после первой ставки.");
        }
        return 0;
    }
    auction_slot_busy[slot] = true;

    new accountid = auction_slot[slot][OWNER_SLOT_SQL];
    new owner_player = INVALID_PLAYER_ID;

    foreach(new i : Player)
    {
        if(GetPlayerAccountID(i) == accountid)
        {
            owner_player = i;
            break;
        }
    }

    if(auction_slot[slot][AUCTION_DB_ID] > 0)
    {
        new query[192];
        mysql_format(mysql, query, sizeof query,
            "UPDATE auction_lots SET status='cancelled' WHERE id=%d AND status='active'",
            auction_slot[slot][AUCTION_DB_ID]);
        mysql_query(mysql, query, false);
    }

    auction_slot_busy[slot] = false;
    reset_slot_auction(slot);

    if(owner_player != INVALID_PLAYER_ID)
    {
        SendClientMessage(owner_player, -1, ""SC" Вы сняли лот с аукциона.");
    }
    return 1;
}
stock reset_slot_auction(slot)
{
    new businessid = auction_slot[slot][SERVER_ID];
    new bool:update_business_label =
        auction_slot[slot][SLOT_TYPE] == TYPE_BUSINESS && AuctionBusiness_IsAuctionable(businessid);
    auction_slot[slot][SLOT_TYPE] = 0;
    auction_slot[slot][OWNER_SLOT_SQL] = -1;
    format(auction_slot[slot][OWNER_SLOT_NAME], 24, "-");
    format(auction_slot[slot][SLOT_NAME], 64, "-");
    format(auction_slot[slot][OPISANIE_SLOT], 124, "-");
    format(auction_slot[slot][NUMBER_VEHICLE], 7, "-");
    auction_slot[slot][OWNER_RATE] = -1;
    auction_slot[slot][START_RATE] = 0;
    auction_slot[slot][CURRENT_RATE] = 0;
    auction_slot[slot][TIMER_END] = 0;
    auction_slot[slot][DATABASE_ID] = -1;
    auction_slot[slot][SERVER_ID] = -1;
    auction_slot[slot][NUMBER_SUM] = 0;
    auction_slot[slot][AUCTION_DB_ID] = 0;
    auction_slot[slot][BUSINESS_TYPE_SLOT] = 0;
    auction_slot[slot][BUSINESS_SOURCE_SLOT] = AUCTION_BUSINESS_SOURCE_REGULAR;
    auction_slot_busy[slot] = false;

    if(update_business_label) CallLocalFunction("UpdateBusinessLabel", "i", businessid);
    
    return 1;
}

stock AuctionManager_InitDatabase()
{
    new auction_schema[1024];
    format(auction_schema, sizeof auction_schema,
        "CREATE TABLE IF NOT EXISTS auction_lots (id INT NOT NULL AUTO_INCREMENT,server_id INT NOT NULL DEFAULT 0,item_type INT NOT NULL,item_database_id INT NOT NULL,business_type INT NOT NULL DEFAULT 0,seller_account_id INT NOT NULL DEFAULT 0,seller_name VARCHAR(24) NOT NULL,item_name VARCHAR(64) NOT NULL,description VARCHAR(128) NOT NULL DEFAULT '',start_price INT NOT NULL,current_price INT NOT NULL,highest_bidder_account_id INT NOT NULL DEFAULT -1,highest_bidder_name VARCHAR(24) NOT NULL DEFAULT '',commission_percent INT NOT NULL DEFAULT 5,is_state_lot TINYINT NOT NULL DEFAULT 0,state_reason VARCHAR(64) NOT NULL DEFAULT '',created_at INT NOT NULL,ends_at INT NOT NULL,status VARCHAR(32) NOT NULL DEFAULT 'active',PRIMARY KEY(id),INDEX idx_status_ends(status,ends_at),INDEX idx_item(item_type,item_database_id))");
    mysql_query(mysql, auction_schema, false);
    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS auction_bids (id INT NOT NULL AUTO_INCREMENT,auction_id INT NOT NULL,bidder_account_id INT NOT NULL,bidder_name VARCHAR(24) NOT NULL,amount INT NOT NULL,created_at INT NOT NULL,status VARCHAR(24) NOT NULL DEFAULT 'active',refunded_at INT NOT NULL DEFAULT 0,PRIMARY KEY(id),INDEX idx_auction_id(auction_id))", false);
    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS auction_history (id INT NOT NULL AUTO_INCREMENT,auction_id INT NOT NULL,business_id INT NOT NULL,seller_account_id INT NOT NULL,buyer_account_id INT NOT NULL DEFAULT -1,final_price INT NOT NULL DEFAULT 0,commission INT NOT NULL DEFAULT 0,result VARCHAR(32) NOT NULL,completed_at INT NOT NULL,PRIMARY KEY(id))", false);
    mysql_query(mysql, "ALTER TABLE business ADD COLUMN IF NOT EXISTS ownership_started_at INT NOT NULL DEFAULT 0", false);
    return 1;
}

stock AuctionGiveAccountMoney(accountid, amount, reason[])
{
    foreach(new i : Player)
    {
        if(GetPlayerAccountID(i) != accountid) continue;
        GivePlayerMoneyEx(i, amount, reason, false, false);
        return 1;
    }

    new query[160];
    mysql_format(mysql, query, sizeof query,
        "UPDATE accounts SET money=money+%d WHERE id=%d LIMIT 1", amount, accountid);
    mysql_query(mysql, query, false);
    return mysql_errno() == 0;
}

stock AuctionRefundBid(slot, message[])
{
    if(auction_slot[slot][OWNER_RATE] == -1) return 1;
    new accountid = auction_slot[slot][OWNER_RATE], amount = auction_slot[slot][CURRENT_RATE];

    if(auction_slot[slot][AUCTION_DB_ID] > 0)
    {
        new query[256], Cache:result;
        mysql_format(mysql, query, sizeof query,
            "UPDATE auction_bids SET status='refunded',refunded_at=%d WHERE auction_id=%d AND bidder_account_id=%d AND status='active' ORDER BY id DESC LIMIT 1",
            gettime(), auction_slot[slot][AUCTION_DB_ID], accountid);
        result = mysql_query(mysql, query, true);
        if(mysql_errno())
        {
            cache_delete(result);
            return 0;
        }
        new affected = cache_affected_rows();
        cache_delete(result);
        if(!affected) return 0;
    }

    if(!AuctionGiveAccountMoney(accountid, amount, "Возврат ставки аукциона")) return 0;
    foreach(new i : Player)
    {
        if(GetPlayerAccountID(i) == accountid) SendClientMessage(i, -1, message);
    }
    return 1;
}

stock AuctionManager_AddStateBusiness(businessid, const state_reason[])
{
    if(!AuctionBusiness_IsAuctionable(businessid)
        || GetBusinessData(businessid, B_OWNER_ID) != 0
        || IsBusinessOnAuction(businessid)) return 0;

    new slot = -1;
    for(new s; s < MAX_AUCTION_SLOT; s++)
    {
        if(!auction_slot[s][SLOT_TYPE])
        {
            slot = s;
            break;
        }
    }
    if(slot == -1) return 0;

    auction_slot[slot][SLOT_TYPE] = TYPE_BUSINESS;
    auction_slot[slot][BUSINESS_SOURCE_SLOT] = AUCTION_BUSINESS_SOURCE_REGULAR;
    auction_slot[slot][BUSINESS_TYPE_SLOT] = GetBusinessData(businessid, B_TYPE);
    auction_slot[slot][OWNER_SLOT_SQL] = 0;
    auction_slot[slot][OWNER_RATE] = -1;
    auction_slot[slot][SERVER_ID] = businessid;
    auction_slot[slot][DATABASE_ID] = GetBusinessData(businessid, B_SQL_ID);
    auction_slot[slot][START_RATE] = GetBusinessData(businessid, B_PRICE);
    auction_slot[slot][CURRENT_RATE] = auction_slot[slot][START_RATE];
    auction_slot[slot][TIMER_END] = AuctionManager_GetTodayFinishTime();
    format(auction_slot[slot][OWNER_SLOT_NAME], 24, "Государство");
    AuctionBusiness_FormatLotName(AUCTION_BUSINESS_SOURCE_REGULAR,
        businessid, auction_slot[slot][SLOT_NAME], 64);
    format(auction_slot[slot][OPISANIE_SLOT], 124,
        "Государственный бизнес [ID:%d]", businessid);

    new query[768];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO auction_lots (server_id,item_type,item_database_id,business_type,seller_account_id,seller_name,item_name,description,start_price,current_price,highest_bidder_account_id,highest_bidder_name,commission_percent,is_state_lot,state_reason,created_at,ends_at,status) VALUES (%d,%d,%d,%d,0,'Государство','%e','%e',%d,%d,-1,'',%d,1,'%e',%d,%d,'active')",
        businessid, TYPE_BUSINESS, GetBusinessData(businessid, B_SQL_ID),
        GetBusinessData(businessid, B_TYPE), auction_slot[slot][SLOT_NAME],
        auction_slot[slot][OPISANIE_SLOT], auction_slot[slot][START_RATE],
        auction_slot[slot][CURRENT_RATE], AUCTION_COMMISSION_PERCENT,
        state_reason, gettime(), auction_slot[slot][TIMER_END]);

    new Cache:insert_result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        cache_delete(insert_result);
        reset_slot_auction(slot);
        return 0;
    }
    auction_slot[slot][AUCTION_DB_ID] = cache_insert_id();
    cache_delete(insert_result);

    CallLocalFunction("UpdateBusinessLabel", "i", businessid);
    return 1;
}

stock AuctionManager_EnsureAllFreeBusinesses()
{
    new added;
    for(new businessid; businessid < g_business_loaded; businessid++)
    {
        if(GetBusinessData(businessid, B_OWNER_ID) != 0) continue;
        if(!AuctionBusiness_IsAuctionable(businessid)) continue;
        if(IsBusinessOnAuction(businessid)) continue;
        if(AuctionManager_AddStateBusiness(businessid, "Автоматический возврат на аукцион")) added++;
    }
    return added;
}

stock AuctionTransferBusiness(businessid, business_sql_id, seller_account_id, buyer_account_id)
{
    if(!AuctionBusiness_IsAuctionable(businessid)
        || GetBusinessData(businessid, B_SQL_ID) != business_sql_id
        || GetBusinessData(businessid, B_OWNER_ID) != seller_account_id)
        return 0;

    new buyer_name[24], buyer_player = INVALID_PLAYER_ID;
    foreach(new i : Player)
    {
        if(GetPlayerAccountID(i) != buyer_account_id) continue;
        buyer_player = i;
        format(buyer_name, sizeof buyer_name, "%s", GetPlayerNameEx(i));
        break;
    }

    new account_query[160], Cache:account_result;
    mysql_format(mysql, account_query, sizeof account_query,
        "SELECT name,buss_slots,(SELECT COUNT(*) FROM business WHERE owner_id=%d) AS owned_count FROM accounts WHERE id=%d LIMIT 1",
        buyer_account_id, buyer_account_id);
    account_result = mysql_query(mysql, account_query, true);
    if(mysql_errno() || !cache_num_rows())
    {
        cache_delete(account_result);
        return 0;
    }
    new max_business = 1 + cache_get_field_content_int(0, "buss_slots");
    if(max_business > 2) max_business = 2;
    // Capacity was checked when the bid was accepted. A paid winning bid must
    // not be cancelled if the account state changes before finalization.
    cache_get_field_content(0, "name", buyer_name, mysql, sizeof buyer_name);
    cache_delete(account_result);

    new transfer_query[256];
    mysql_query(mysql, "START TRANSACTION", false);
    if(mysql_errno()) return 0;
    new paid_until = gettime() + 2 * 86400;
    mysql_format(mysql, transfer_query, sizeof transfer_query,
        "UPDATE business SET owner_id=%d,ownership_started_at=%d,rent_time=%d WHERE id=%d AND owner_id=%d",
        buyer_account_id, gettime(), paid_until, business_sql_id, seller_account_id);
    if(!AuctionDatabaseExecuteAffected(transfer_query))
    {
        mysql_query(mysql, "ROLLBACK", false);
        return 0;
    }
    if(seller_account_id > 0)
    {
        mysql_format(mysql, transfer_query, sizeof transfer_query,
            "UPDATE accounts SET business=-1 WHERE id=%d AND business=%d", seller_account_id, businessid);
        mysql_query(mysql, transfer_query, false);
        if(mysql_errno())
        {
            mysql_query(mysql, "ROLLBACK", false);
            return 0;
        }
    }    mysql_format(mysql, transfer_query, sizeof transfer_query,
        "UPDATE accounts SET business=%d WHERE id=%d", businessid, buyer_account_id);
    if(!AuctionDatabaseExecuteAffected(transfer_query))
    {
        mysql_query(mysql, "ROLLBACK", false);
        return 0;
    }
    if(GetBusinessData(businessid, B_TYPE) == BUSINESS_TYPE_CASINO)
    {
        mysql_format(mysql, transfer_query, sizeof transfer_query, "UPDATE accounts SET casino_job=0,casino_business=-1 WHERE casino_business=%d", businessid);
        mysql_query(mysql, transfer_query, false);
        if(mysql_errno())
        {
            mysql_query(mysql, "ROLLBACK", false);
            return 0;
        }
    }
    mysql_query(mysql, "COMMIT", false);
    if(mysql_errno()) return 0;

    foreach(new i : Player)
    {
        if(seller_account_id > 0 && GetPlayerAccountID(i) == seller_account_id && GetPlayerData(i, P_BUSINESS) == businessid)
            SetPlayerData(i, P_BUSINESS, -1);
        if(GetBusinessData(businessid, B_TYPE) == BUSINESS_TYPE_CASINO && GetPlayerData(i, P_CASINO_BUSINESS) == businessid)
        {
            SetPlayerData(i, P_CASINO_JOB, 0);
            SetPlayerData(i, P_CASINO_BUSINESS, -1);
            pInfo[i][CasinoDealerJob] = false;
            pInfo[i][CasinoManagerJob] = false;
            SetPlayerSkin(i, GetPlayerSkinEx(i));
            SendClientMessage(i, 0xFF9900FF, "Состав казино распущен после смены владельца.");
        }
    }
    if(buyer_player != INVALID_PLAYER_ID)
    {
        SetPlayerData(buyer_player, P_BUSINESS, businessid);
        SendClientMessage(buyer_player, 0x66CC00FF, "Поздравляем! Вы выиграли бизнес на аукционе.");
    }

    SetBusinessData(businessid, B_OWNER_ID, buyer_account_id);
	SetBusinessData(businessid, B_RENT_DATE, paid_until);
    format(g_business[businessid][B_OWNER_NAME], 21, "%s", buyer_name);
	UpdateBusinessLabel(businessid);
    return 1;
}

stock AuctionTransferFuelStation(stationid, station_sql_id, seller_account_id, buyer_account_id)
{
    if(stationid < 0 || stationid >= g_fuel_station_loaded
        || GetFuelStationData(stationid, FS_SQL_ID) != station_sql_id
        || GetFuelStationData(stationid, FS_OWNER_ID) != seller_account_id)
        return 0;

    new buyer_name[24], query[256], Cache:result;
    mysql_format(mysql, query, sizeof query,
        "SELECT name,fuel_st FROM accounts WHERE id=%d LIMIT 1", buyer_account_id);
    result = mysql_query(mysql, query, true);
    if(mysql_errno() || !cache_num_rows() || cache_get_field_content_int(0, "fuel_st") != -1)
    {
        cache_delete(result);
        return 0;
    }
    cache_get_field_content(0, "name", buyer_name, mysql, sizeof buyer_name);
    cache_delete(result);

    mysql_query(mysql, "START TRANSACTION", false);
    if(mysql_errno()) return 0;
    mysql_format(mysql, query, sizeof query,
        "UPDATE fuel_stations SET owner_id=%d WHERE id=%d AND owner_id=%d",
        buyer_account_id, station_sql_id, seller_account_id);
    if(!AuctionDatabaseExecuteAffected(query)) return mysql_query(mysql, "ROLLBACK", false), 0;

    if(seller_account_id > 0)
    {
        mysql_format(mysql, query, sizeof query, "UPDATE accounts SET fuel_st=-1 WHERE id=%d", seller_account_id);
        if(!AuctionDatabaseExecuteAffected(query)) return mysql_query(mysql, "ROLLBACK", false), 0;
    }
    mysql_format(mysql, query, sizeof query,
        "UPDATE accounts SET fuel_st=%d WHERE id=%d AND fuel_st=-1", stationid, buyer_account_id);
    if(!AuctionDatabaseExecuteAffected(query)) return mysql_query(mysql, "ROLLBACK", false), 0;
    mysql_query(mysql, "COMMIT", false);
    if(mysql_errno()) return 0;

    foreach(new i : Player)
    {
        if(seller_account_id > 0 && GetPlayerAccountID(i) == seller_account_id)
            SetPlayerData(i, P_FUEL_ST, -1);
        if(GetPlayerAccountID(i) == buyer_account_id)
            SetPlayerData(i, P_FUEL_ST, stationid);
    }
    SetFuelStationData(stationid, FS_OWNER_ID, buyer_account_id);
    format(g_fuel_station[stationid][FS_OWNER_NAME], 21, "%s", buyer_name);
    CallLocalFunction("UpdateFuelStationLabel", "i", stationid);
    return 1;
}

stock AuctionBusiness(sql_id, slot)
{
        new query[256];
        new player = -1, businessid = auction_slot[slot][SERVER_ID];


        foreach(new i : Player)
        {
            if(sql_id == GetPlayerAccountID(i)) player = i;
        }

        foreach(new i : Player)
        {
            if(auction_slot[slot][OWNER_SLOT_SQL] == GetPlayerAccountID(i)) SetPlayerData(i, P_BUSINESS, -1);
        }

        
        mysql_format(mysql, query, sizeof query, "UPDATE accounts SET business=-1 WHERE id=%d", auction_slot[slot][OWNER_SLOT_SQL]);
        mysql_query(mysql, query, false);
        if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 11");

        mysql_format(mysql, query, sizeof query, "UPDATE accounts a, business b SET a.business=%d,b.owner_id=%d WHERE a.id=%d AND b.id=%d", businessid, sql_id, sql_id, GetBusinessData(businessid, B_SQL_ID));
        mysql_query(mysql, query, false);
        if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 11.1");
        printf("sql %s", query);

        if(!mysql_errno())
        {
            SetPlayerData(player, P_BUSINESS, businessid);

            SetBusinessData(businessid, B_OWNER_ID, sql_id);
            SetBusinessData(businessid, B_IMPROVEMENTS, 	0);

            new time = gettime();
            new rent_time = (time - (time % 86400)) + 86400;


            SetBusinessData(businessid,	B_PRODS, 		20);
            SetBusinessData(businessid,	B_PROD_PRICE, 	0);

            SetBusinessData(businessid,	B_ENTER_MUSIC, 	0);
            SetBusinessData(businessid,	B_ENTER_PRICE, 	0);

            SetBusinessData(businessid,	B_BALANCE, 		0);
            SetBusinessData(businessid,	B_RENT_DATE,	rent_time);
            SetBusinessData(businessid,	B_LOCK_STATUS,	false);

            new name[24], Cache:result;

            mysql_format(mysql, query, sizeof query, "SELECT name FROM accounts WHERE id = %d", sql_id);
            result = mysql_query(mysql, query);
            if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 11.2");

            cache_get_row(0, 0, name);
            if(mysql_errno()) return print("error name label to business");

            format(g_business[businessid][B_OWNER_NAME], 21, name, 0);
            CallLocalFunction("UpdateBusinessLabel", "i", businessid);

            cache_delete(result);

            SendClientMessage(player, 0x66CC00FF, "Напишите {0099FF}/business {66CC00}чтобы узнать о возможностях");

            format(query, sizeof query, "UPDATE business SET improvements=0,products=%d,prod_price=%d,balance=%d,rent_time=%d,`lock`=%d WHERE id=%d LIMIT 1", GetBusinessData(businessid, B_PRODS), GetBusinessData(businessid, B_PROD_PRICE), GetBusinessData(businessid, B_BALANCE), GetBusinessData(businessid, B_RENT_DATE), GetBusinessData(businessid, B_LOCK_STATUS), GetBusinessData(businessid, B_SQL_ID));
            mysql_query(mysql, query, false);
            if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 11.3");

            format(query, sizeof query, "UPDATE business_profit SET view=0 WHERE bid=%d AND view=1", GetBusinessData(businessid, B_SQL_ID));
            mysql_query(mysql, query, false);
            if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 11.4");
            reset_slot_auction(slot);

            return 1;
        }

        return 0;
}

public: SetBusinessName()
{
    new text[124];

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Магазин 24/7' WHERE 	ype` = 1");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Клуб' WHERE 	ype` = 2");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Управление Статистики' WHERE 	ype` = 3");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Риелторское Агенство' WHERE 	ype` = 4");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Магазин одежды' WHERE 	ype` = 5");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Отель' WHERE 	ype` = 6");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Автосалон' WHERE 	ype` = 7");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Казино' WHERE 	ype` = 8");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='СТО' WHERE 	ype` = 10");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Сотовый салон' WHERE 	ype` = 9");
    mysql_query(mysql, text, false);

    mysql_format(mysql, text, sizeof text, "UPDATE business SET `name`='Магазин Оружия' WHERE 	ype` = 11");
    mysql_query(mysql, text, false);

    if(mysql_errno()) print("ERROR AUCTION UPDATE NAME BUSINESS SQL");

}

public:LoadBusinessToAuction()
{
    load_business_action = true;
    AuctionManager_InitDatabase();
    AuctionManager_ProcessSpecialBusinessCycle();

	// Restore persisted bids first, then create durable state lots for every free business.
	AuctionManager_RestoreCasinoLots();
	for(new businessid; businessid < g_business_loaded; businessid++)
	{
		if(GetBusinessData(businessid, B_OWNER_ID) != 0) continue;
		if(!AuctionBusiness_IsAuctionable(businessid)) continue;
		if(IsBusinessOnAuction(businessid)) continue;
		AuctionManager_AddStateBusiness(businessid, "Свободный бизнес");
	}
	AuctionManager_LoadStateFuelStations();
	AuctionManager_EnsureBonusCasinoLot();
	return 1;

	#if 0 // Legacy volatile loader; durable lots above replace it.

    new text[114], Cache:result;
    mysql_format(mysql, text, sizeof text, "SELECT * FROM business WHERE `owner_id` = 0");
    result = mysql_query(mysql, text, true);
    if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 12");

    if(mysql_errno()) return print("error_sql auction business");

    new memory = cache_num_rows(), da = 1;

    for(new b;b < memory;b++)
    {
        if(auction_slot[b][SLOT_TYPE] != 0) continue;

        auction_slot[b][SLOT_TYPE] = 1;
        auction_slot[b][OWNER_SLOT_SQL] = 0;
        auction_slot[b][OWNER_RATE] = -1;

        format(auction_slot[b][OWNER_SLOT_NAME], 24, "Государство");

        auction_slot[b][DATABASE_ID] = cache_get_field_content_int(b, "id");
        auction_slot[b][START_RATE] = cache_get_field_content_int(b, "price");
        auction_slot[b][CURRENT_RATE] = auction_slot[b][START_RATE];

        auction_slot[b][TIMER_END] = AuctionManager_GetTodayFinishTime();
        

        //new business_id;

        for(new sql;sql < MAX_BUSINESS;sql++)
        {
            if(GetBusinessData(sql, B_SQL_ID) == auction_slot[b][DATABASE_ID]) 
            {
                auction_slot[b][SERVER_ID] = sql;
                AuctionBusiness_FormatLotName(AUCTION_BUSINESS_SOURCE_REGULAR,
                    sql, auction_slot[b][SLOT_NAME], 64);
                format(auction_slot[b][OPISANIE_SLOT], 124, "Государственный бизнес [ID:%d]",
                    auction_slot[b][DATABASE_ID]);
                break;
            }
        }

        da++;
    }

    printf("%d", da);

    cache_delete(result);
    AuctionManager_LoadStateFuelStations();
    AuctionManager_RestoreCasinoLots();
    AuctionManager_EnsureBonusCasinoLot();
    return 1;
	#endif
}

stock AuctionManager_EnsureBonusCasinoLot()
{
    new businessid = -1;
    for(new i; i < g_business_loaded; i++)
    {
        if(IsBonusCasinoBusiness(i))
        {
            businessid = i;
            break;
        }
    }
    if(businessid == -1)
    {
        if(g_business_loaded >= MAX_BUSINESS)
        {
            print("[AUCTION] Cannot create bonus casino: MAX_BUSINESS reached");
            return 0;
        }

        new create_query[512];
        mysql_format(mysql, create_query, sizeof create_query,
            "INSERT INTO business (owner_id,name,improvements,products,prod_price,balance,rent_time,price,rent_price,type,interior,enter_price,enter_music,`lock`,x,y,z,exit_x,exit_y,exit_z,exit_angle,eviction,ownership_started_at) VALUES (0,'Казино',0,0,0,0,0,150000000,0,%d,%d,0,0,0,1333.740600,2372.598632,17.712001,1333.630000,2368.660000,17.664200,180.0,0,0)",
            BUSINESS_TYPE_CASINO, BUSINESS_INTERIOR_CASINO);
        new Cache:create_result = mysql_query(mysql, create_query, true);
        if(mysql_errno())
        {
            print("[AUCTION] Cannot insert bonus casino into business table");
            cache_delete(create_result);
            return 0;
        }

        businessid = g_business_loaded;
        SetBusinessData(businessid, B_SQL_ID, cache_insert_id());
        cache_delete(create_result);
        SetBusinessData(businessid, B_OWNER_ID, 0);
        SetBusinessData(businessid, B_IMPROVEMENTS, 0);
        SetBusinessData(businessid, B_PRODS, 0);
        SetBusinessData(businessid, B_PROD_PRICE, 0);
        SetBusinessData(businessid, B_BALANCE, 0);
        SetBusinessData(businessid, B_RENT_DATE, 0);
        SetBusinessData(businessid, B_PRICE, 150000000);
        SetBusinessData(businessid, B_RENT_PRICE, 0);
        SetBusinessData(businessid, B_TYPE, BUSINESS_TYPE_CASINO);
        SetBusinessData(businessid, B_INTERIOR, BUSINESS_INTERIOR_CASINO);
        SetBusinessData(businessid, B_ENTER_PRICE, 0);
        SetBusinessData(businessid, B_ENTER_MUSIC, 0);
        SetBusinessData(businessid, B_LOCK_STATUS, false);
        SetBusinessData(businessid, B_POS_X, 1333.740600);
        SetBusinessData(businessid, B_POS_Y, 2372.598632);
        SetBusinessData(businessid, B_POS_Z, 17.712001);
        SetBusinessData(businessid, B_EXIT_POS_X, 1333.630000);
        SetBusinessData(businessid, B_EXIT_POS_Y, 2368.660000);
        SetBusinessData(businessid, B_EXIT_POS_Z, 17.664200);
        SetBusinessData(businessid, B_EXIT_ANGLE, 180.0);
        SetBusinessData(businessid, B_EVICTION, 0);
        SetBusinessData(businessid, B_ORDER_ID, -1);
        SetBusinessData(businessid, B_LABEL, Text3D:-1);
        format(g_business[businessid][B_NAME], 26, "Казино");
        format(g_business[businessid][B_OWNER_NAME], 21, "Государство");
        g_business_loaded++;
        printf("[AUCTION] Created missing bonus casino: business=%d sql=%d",
            businessid, GetBusinessData(businessid, B_SQL_ID));
    }

    new sql_id = GetBusinessData(businessid, B_SQL_ID);
    for(new s; s < MAX_AUCTION_SLOT; s++)
    {
        if(auction_slot[s][SLOT_TYPE] == TYPE_BUSINESS
            && auction_slot[s][BUSINESS_SOURCE_SLOT] == AUCTION_BUSINESS_SOURCE_REGULAR
            && auction_slot[s][DATABASE_ID] == sql_id)
        {
            CallLocalFunction("UpdateBusinessLabel", "i", businessid);
            return 1;
        }
    }

    new previous_owner = GetBusinessData(businessid, B_OWNER_ID);
    if(previous_owner > 0)
    {
        new compensation = BusinessImprovementsPrice(businessid) * 60 / 100;
        new state_query[384];
        mysql_format(mysql, state_query, sizeof state_query,
            "UPDATE accounts SET business=-1 WHERE id=%d", previous_owner);
        mysql_query(mysql, state_query, false);
        if(compensation > 0)
        {
            mysql_format(mysql, state_query, sizeof state_query,
                "INSERT INTO return_money (uid,money,description,status) VALUES (%d,%d,'Компенсация 60%% за улучшения казино',0)",
                previous_owner, compensation);
            mysql_query(mysql, state_query, false);
        }
        foreach(new p : Player)
            if(GetPlayerAccountID(p) == previous_owner) SetPlayerData(p, P_BUSINESS, -1);
    }

    new query[512];
    mysql_format(mysql, query, sizeof query,
        "UPDATE business SET owner_id=0,improvements=0,ownership_started_at=0 WHERE id=%d", sql_id);
    mysql_query(mysql, query, false);
    SetBusinessData(businessid, B_OWNER_ID, 0);
    SetBusinessData(businessid, B_IMPROVEMENTS, 0);
    format(g_business[businessid][B_OWNER_NAME], 21, "Государство");

    new slot = -1;
    for(new s; s < MAX_AUCTION_SLOT; s++)
    {
        if(!auction_slot[s][SLOT_TYPE])
        {
            slot = s;
            break;
        }
    }
    if(slot == -1) return 0;

    auction_slot[slot][SLOT_TYPE] = TYPE_BUSINESS;
    auction_slot[slot][BUSINESS_SOURCE_SLOT] = AUCTION_BUSINESS_SOURCE_REGULAR;
    auction_slot[slot][BUSINESS_TYPE_SLOT] = BUSINESS_TYPE_CASINO;
    auction_slot[slot][OWNER_SLOT_SQL] = 0;
    auction_slot[slot][OWNER_RATE] = -1;
    auction_slot[slot][SERVER_ID] = businessid;
    auction_slot[slot][DATABASE_ID] = sql_id;
    auction_slot[slot][START_RATE] = GetBusinessData(businessid, B_PRICE);
    auction_slot[slot][CURRENT_RATE] = auction_slot[slot][START_RATE];
    auction_slot[slot][TIMER_END] = AuctionManager_GetTodayFinishTime();
    format(auction_slot[slot][OWNER_SLOT_NAME], 24, "Государство");
    format(auction_slot[slot][SLOT_NAME], 64, "Казино (30)");
    format(auction_slot[slot][OPISANIE_SLOT], 124, "Государственное казино");

    mysql_format(mysql, query, sizeof query,
        "INSERT INTO auction_lots (server_id,item_type,item_database_id,business_type,seller_account_id,seller_name,item_name,description,start_price,current_price,highest_bidder_account_id,highest_bidder_name,commission_percent,is_state_lot,state_reason,created_at,ends_at,status) VALUES (%d,%d,%d,%d,0,'Государство','Казино (30)','Государственное казино',%d,%d,-1,'',%d,1,'Открытие сервера',%d,%d,'active')",
        businessid, TYPE_BUSINESS, sql_id, BUSINESS_TYPE_CASINO,
        auction_slot[slot][START_RATE], auction_slot[slot][CURRENT_RATE],
        AUCTION_COMMISSION_PERCENT, gettime(), auction_slot[slot][TIMER_END]);
    new Cache:insert_result = mysql_query(mysql, query, true);
    if(!mysql_errno()) auction_slot[slot][AUCTION_DB_ID] = cache_insert_id();
    cache_delete(insert_result);

    CallLocalFunction("UpdateBusinessLabel", "i", businessid);
    printf("[AUCTION] Bonus casino added as public ID 30: business=%d sql=%d slot=%d",
        businessid, sql_id, slot);
    return 1;
}

stock AuctionManager_ProcessSpecialBusinessCycle()
{
    new query[256], Cache:result;
    mysql_format(mysql, query, sizeof query,
        "SELECT id,owner_id FROM business WHERE owner_id>0 AND type IN (%d,%d) AND ownership_started_at>0 AND ownership_started_at<=%d",
        BUSINESS_TYPE_CASINO, BUSINESS_TYPE_CAR_TUNING, gettime() - (15 * 86400));
    result = mysql_query(mysql, query, true);
    if(mysql_errno()) { cache_delete(result); return 0; }

    new rows = cache_num_rows();
    for(new row; row < rows; row++)
    {
        new sql_id = cache_get_field_content_int(row, "id");
        new owner_id = cache_get_field_content_int(row, "owner_id");
        new businessid = -1;
        for(new i; i < g_business_loaded; i++)
        {
            if(GetBusinessData(i, B_SQL_ID) == sql_id) { businessid = i; break; }
        }
        if(businessid == -1) continue;

        new compensation = BusinessImprovementsPrice(businessid) * 60 / 100;
        mysql_format(mysql, query, sizeof query,
            "UPDATE business SET owner_id=0,improvements=0,ownership_started_at=0 WHERE id=%d AND owner_id=%d",
            sql_id, owner_id);
        mysql_query(mysql, query, false);
        mysql_format(mysql, query, sizeof query,
            "UPDATE accounts SET business=-1 WHERE id=%d", owner_id);
        mysql_query(mysql, query, false);
        if(compensation > 0)
        {
            mysql_format(mysql, query, sizeof query,
                "INSERT INTO return_money (uid,money,description,status) VALUES (%d,%d,'Компенсация 60%% за улучшения бизнеса',0)",
                owner_id, compensation);
            mysql_query(mysql, query, false);
        }
        SetBusinessData(businessid, B_OWNER_ID, 0);
        SetBusinessData(businessid, B_IMPROVEMENTS, 0);
        format(g_business[businessid][B_OWNER_NAME], 21, "Государство");
        foreach(new p : Player)
            if(GetPlayerAccountID(p) == owner_id) SetPlayerData(p, P_BUSINESS, -1);
        CallLocalFunction("UpdateBusinessLabel", "i", businessid);
    }
    cache_delete(result);
    return 1;
}

stock AuctionManager_LoadStateFuelStations()
{
    new Cache:result = mysql_query(mysql, "SELECT id,name,price FROM fuel_stations WHERE owner_id=0", true);
    if(mysql_errno())
    {
        cache_delete(result);
        return 0;
    }
    new rows = cache_num_rows();
    for(new row; row < rows; row++)
    {
        new sql_id = cache_get_field_content_int(row, "id"), stationid = -1, slot = -1;
        for(new i; i < g_fuel_station_loaded; i++)
        {
            if(GetFuelStationData(i, FS_SQL_ID) == sql_id) { stationid = i; break; }
        }
        if(stationid == -1) continue;
        for(new s; s < MAX_AUCTION_SLOT; s++)
        {
            if(!auction_slot[s][SLOT_TYPE]) { slot = s; break; }
        }
        if(slot == -1) break;
        auction_slot[slot][SLOT_TYPE] = TYPE_BUSINESS;
        auction_slot[slot][BUSINESS_SOURCE_SLOT] = AUCTION_BUSINESS_SOURCE_FUEL;
        auction_slot[slot][BUSINESS_TYPE_SLOT] = 1000;
        auction_slot[slot][OWNER_SLOT_SQL] = 0;
        auction_slot[slot][OWNER_RATE] = -1;
        auction_slot[slot][SERVER_ID] = stationid;
        auction_slot[slot][DATABASE_ID] = sql_id;
        auction_slot[slot][START_RATE] = cache_get_field_content_int(row, "price");
        auction_slot[slot][CURRENT_RATE] = auction_slot[slot][START_RATE];
        auction_slot[slot][TIMER_END] = AuctionManager_GetTodayFinishTime();
        format(auction_slot[slot][OWNER_SLOT_NAME], 24, "Государство");
        AuctionBusiness_FormatLotName(AUCTION_BUSINESS_SOURCE_FUEL,
            stationid, auction_slot[slot][SLOT_NAME], 64);
        format(auction_slot[slot][OPISANIE_SLOT], 124, "Государственная АЗС");
    }
    cache_delete(result);
    return 1;
}

stock AuctionManager_RestoreCasinoLots()
{
    new query[256], Cache:result;
    mysql_format(mysql, query, sizeof query,
        "SELECT * FROM auction_lots WHERE status IN ('active','processing') ORDER BY id ASC");
    result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        cache_delete(result);
        return print("[AUCTION] Failed to restore active lots");
    }

    new rows = cache_num_rows();
    for(new row; row < rows; row++)
    {
        cache_set_active(result);
        new item_type = cache_get_field_content_int(row, "item_type");
        if(item_type < TYPE_BUSINESS || item_type > TYPE_CLOTHES) continue;

        new slot = -1;
        for(new s; s < MAX_AUCTION_SLOT; s++) if(!auction_slot[s][SLOT_TYPE]) { slot = s; break; }
        if(slot == -1) break;

        auction_slot[slot][SLOT_TYPE] = item_type;
        auction_slot[slot][AUCTION_DB_ID] = cache_get_field_content_int(row, "id");
        auction_slot[slot][DATABASE_ID] = cache_get_field_content_int(row, "item_database_id");
        auction_slot[slot][OWNER_SLOT_SQL] = cache_get_field_content_int(row, "seller_account_id");
        auction_slot[slot][START_RATE] = cache_get_field_content_int(row, "start_price");
        auction_slot[slot][CURRENT_RATE] = cache_get_field_content_int(row, "current_price");
        auction_slot[slot][OWNER_RATE] = cache_get_field_content_int(row, "highest_bidder_account_id");
        auction_slot[slot][BUSINESS_TYPE_SLOT] = cache_get_field_content_int(row, "business_type");
        auction_slot[slot][TIMER_END] = cache_get_field_content_int(row, "ends_at");
        auction_slot[slot][SERVER_ID] = cache_get_field_content_int(row, "server_id");
        cache_get_field_content(row, "seller_name", auction_slot[slot][OWNER_SLOT_NAME], mysql, 24);
        cache_get_field_content(row, "item_name", auction_slot[slot][SLOT_NAME], mysql, 64);
        cache_get_field_content(row, "description", auction_slot[slot][OPISANIE_SLOT], mysql, 124);

        new bool:item_valid = true;
        if(item_type == TYPE_BUSINESS)
        {
            new business_sql_id = auction_slot[slot][DATABASE_ID];
            new business_source = auction_slot[slot][BUSINESS_TYPE_SLOT] == 1000 ? AUCTION_BUSINESS_SOURCE_FUEL : AUCTION_BUSINESS_SOURCE_REGULAR;
            auction_slot[slot][BUSINESS_SOURCE_SLOT] = business_source;
            auction_slot[slot][SERVER_ID] = -1;
            if(business_source == AUCTION_BUSINESS_SOURCE_FUEL)
            {
                for(new stationid; stationid < g_fuel_station_loaded; stationid++) if(GetFuelStationData(stationid, FS_SQL_ID) == business_sql_id) { auction_slot[slot][SERVER_ID] = stationid; break; }
                item_valid = auction_slot[slot][SERVER_ID] != -1 && GetFuelStationData(auction_slot[slot][SERVER_ID], FS_OWNER_ID) == auction_slot[slot][OWNER_SLOT_SQL];
            }
            else
            {
                for(new businessid; businessid < g_business_loaded; businessid++) if(GetBusinessData(businessid, B_SQL_ID) == business_sql_id) { auction_slot[slot][SERVER_ID] = businessid; break; }
                item_valid = auction_slot[slot][SERVER_ID] != -1 && GetBusinessData(auction_slot[slot][SERVER_ID], B_OWNER_ID) == auction_slot[slot][OWNER_SLOT_SQL];
            }
            if(item_valid) AuctionBusiness_FormatLotName(business_source, auction_slot[slot][SERVER_ID], auction_slot[slot][SLOT_NAME], 64);
        }
        else
        {
            if(item_type == TYPE_HOUSE)
            {
                auction_slot[slot][SERVER_ID] = -1;
                for(new houseid; houseid < MAX_HOUSES; houseid++) if(GetHouseData(houseid, H_SQL_ID) == auction_slot[slot][DATABASE_ID]) { auction_slot[slot][SERVER_ID] = houseid; break; }
            }
            if(item_type == TYPE_VEHICLE_NUMBER) format(auction_slot[slot][NUMBER_VEHICLE], 7, "%s", auction_slot[slot][SLOT_NAME]);
            if(item_type == TYPE_SUM_NUMBER) auction_slot[slot][NUMBER_SUM] = auction_slot[slot][DATABASE_ID];
            item_valid = AuctionItem_IsOwnedBy(item_type, auction_slot[slot][DATABASE_ID], auction_slot[slot][SERVER_ID], auction_slot[slot][NUMBER_VEHICLE], auction_slot[slot][NUMBER_SUM], auction_slot[slot][OWNER_SLOT_SQL]);
        }

        if(!item_valid)
        {
            AuctionRefundBid(slot, "Лот больше недоступен. Ставка возвращена.");
            new stale_query[160];
            mysql_format(mysql, stale_query, sizeof stale_query, "UPDATE auction_lots SET status='cancelled_invalid_item' WHERE id=%d", auction_slot[slot][AUCTION_DB_ID]);
            mysql_query(mysql, stale_query, false);
            reset_slot_auction(slot);
            continue;
        }

        if(item_type == TYPE_BUSINESS)
        {
            if(auction_slot[slot][BUSINESS_SOURCE_SLOT] == AUCTION_BUSINESS_SOURCE_FUEL) CallLocalFunction("UpdateFuelStationLabel", "i", auction_slot[slot][SERVER_ID]);
            else CallLocalFunction("UpdateBusinessLabel", "i", auction_slot[slot][SERVER_ID]);
        }
    }
    cache_delete(result);
    return 1;
}

stock defualt_slot()
{
    for(new DEATH; DEATH < MAX_AUCTION_SLOT; DEATH++)
    {
        auction_slot[DEATH][SLOT_TYPE] = 0;
        auction_slot[DEATH][OWNER_SLOT_SQL] = -1;
        format(auction_slot[DEATH][OWNER_SLOT_NAME], 24, "-");
        format(auction_slot[DEATH][SLOT_NAME], 64, "-");
        format(auction_slot[DEATH][OPISANIE_SLOT], 124, "-");
        format(auction_slot[DEATH][NUMBER_VEHICLE], 7 , "-");
        auction_slot[DEATH][OWNER_RATE] = -1;
        auction_slot[DEATH][START_RATE] = 0;
        auction_slot[DEATH][CURRENT_RATE] = 0;
        auction_slot[DEATH][TIMER_END] = 0;
        auction_slot[DEATH][DATABASE_ID] = 0;
        auction_slot[DEATH][SERVER_ID] = 0;
        auction_slot[DEATH][NUMBER_SUM] = 0;
        auction_slot[DEATH][AUCTION_DB_ID] = 0;
        auction_slot[DEATH][BUSINESS_TYPE_SLOT] = 0;
        auction_slot[DEATH][BUSINESS_SOURCE_SLOT] = AUCTION_BUSINESS_SOURCE_REGULAR;
        auction_slot_busy[DEATH] = false;
    }
}

stock AuctionHouse(slot, win_slot, houseid)
{
    new query[256];

    foreach(new i : Player)
    {
        if(auction_slot[slot][OWNER_SLOT_SQL] == GetPlayerAccountID(i))
        {
            SetPlayerData(i, P_HOUSE, -1);
            SetPlayerData(i, P_HOUSE_TYPE, -1);
        }
    }

    mysql_format(mysql, query, sizeof query, "UPDATE accounts SET house_type = -1, house = -1 WHERE id=%d", auction_slot[slot][OWNER_SLOT_SQL]);
    mysql_query(mysql, query, false);

    format(query, sizeof query, "UPDATE accounts a, houses h SET a.house_type=%d,a.house=%d,h.owner_id=%d WHERE a.id=%d AND h.id=%d", HOUSE_TYPE_HOME, houseid, win_slot, win_slot, GetHouseData(houseid, H_SQL_ID));
    mysql_query(mysql, query, false);
    if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 13");
    printf("sql %s", query);

    if(!mysql_errno())
    {
        foreach(new i : Player)
        {
            if(GetPlayerAccountID(i) == win_slot)
            {
                SetPlayerData(i, P_HOUSE, 		houseid);
                SetPlayerData(i, P_HOUSE_TYPE, 	HOUSE_TYPE_HOME);
            }
        }


        SetHouseData(houseid, H_OWNER_ID, win_slot);
        SetHouseData(houseid, H_IMPROVEMENTS, 	0);

        SetHouseData(houseid, H_STORE_X, 0.0);
        SetHouseData(houseid, H_STORE_Y, 0.0);
        SetHouseData(houseid, H_STORE_Z, 0.0);

        new time = gettime();
        new rent_time = (time - (time % 86400)) + 86400;

        SetHouseData(houseid,	H_RENT_DATE,	rent_time);
        SetHouseData(houseid,	H_LOCK_STATUS,	false);

        new entranceid = GetHouseData(houseid, H_ENTRACE);
        if(entranceid != -1)
        {
            CallLocalFunction("EntranceStatusInit", "i", entranceid);
        }

        new Cache:result, name[24];

        mysql_format(mysql, query, sizeof query, "SELECT * FROM accounts WHERE id=%d LIMIT 1", win_slot);
        result = mysql_query(mysql, query, true);
        if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 13.1");

        cache_get_field_content(0, "name", name, mysql, 24);

        format(g_house[houseid][H_OWNER_NAME], 21, name, 0);

        cache_delete(result);

        UpdateHouse(houseid);

        HouseHealthInit(houseid);
        HouseStoreInit(houseid);

        format(query, sizeof query, "UPDATE houses SET improvements=0,rent_time=%d,`lock`=%d,store_x=0.0,store_y=0.0,store_z=0.0 WHERE id=%d LIMIT 1", GetHouseData(houseid, H_RENT_DATE), GetHouseData(houseid, H_LOCK_STATUS), GetHouseData(houseid, H_SQL_ID));
        mysql_query(mysql, query, false);
        if(mysql_errno()) return print("[ERROR AUCTION MYSQL] ID ERROR:: 13.2");
        reset_slot_auction(slot);

        return 1;
    }

        return 0;
}

stock LeafAuction(playerid, all_slot)
{
    new active_slot_id[MAX_AUCTION_SLOT], slot, filter, tovar_type, string[32];

rebuild_auction_page:
    slot = -1;
    filter = player_info_panel[playerid][filter_type];
    tovar_type = player_info_panel[playerid][filter_tovar_type];
    for(new p;p < 4;p++) player_show_slot[playerid][p] = -1;

    for(new td; td < 4; td++)
    {
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][0]], "-");
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][1]], "-");
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][2]], "-");
    }

    for(new i = 1; i < 6;i++ ) PlayerTextDrawSetString(playerid, auction_PTD[playerid][i], "-");

    default_select_slot(playerid);

    player_info_panel[playerid][select_slot] = 0;

    for(new i;i < 4;i++) player_show_slot[playerid][i] = -1;
    valstr(string, player_info_panel[playerid][count_list]);
    PlayerTextDrawSetString(playerid, auction_PTD[playerid][27], string);

    for(new c;c < MAX_AUCTION_SLOT;c++)
    {
        if(!auction_slot[c][SLOT_TYPE]) continue;

        switch(filter)
        {
            case 1:
            {
                switch(tovar_type)
                {
                    case TYPE_VEHICLE: if(auction_slot[c][SLOT_TYPE] != TYPE_VEHICLE || auction_slot[c][SERVER_ID] != player_info_panel[playerid][filter_vehicle_model]) continue;
                    case TYPE_BUSINESS: if(auction_slot[c][SLOT_TYPE] != TYPE_BUSINESS) continue;
                    case TYPE_HOUSE: if(auction_slot[c][SLOT_TYPE] != TYPE_HOUSE) continue;
                    case TYPE_VEHICLE_NUMBER: if(auction_slot[c][SLOT_TYPE] != TYPE_VEHICLE_NUMBER) continue;
                    case TYPE_SUM_NUMBER: if(auction_slot[c][SLOT_TYPE] != TYPE_SUM_NUMBER) continue;
                    case TYPE_CLOTHES: if(auction_slot[c][SLOT_TYPE] != TYPE_CLOTHES) continue;
                }
            }
            case 2:
            {
                if(auction_slot[c][CURRENT_RATE] < player_info_panel[playerid][filter_min_price]) continue;
                else if(auction_slot[c][CURRENT_RATE] > player_info_panel[playerid][filter_max_price]) continue;
            }
        }
    
        slot++;

        active_slot_id[slot] = c;
        
        if(slot == all_slot - 3) player_show_slot[playerid][0] = active_slot_id[slot];
        if(slot == all_slot - 2) player_show_slot[playerid][1] = active_slot_id[slot];
        if(slot == all_slot - 1) player_show_slot[playerid][2] = active_slot_id[slot];
        if(slot == all_slot)
        {
            player_show_slot[playerid][3] = active_slot_id[slot];
            break;
        }
    }

    // Do not leave the player on a non-existent page after lots were sold or
    // removed while the auction window was open.
    if(player_show_slot[playerid][0] == -1
        && player_info_panel[playerid][count_list] > 1)
    {
        player_info_panel[playerid][count_list]--;
        all_slot = player_info_panel[playerid][count_list] * 4 - 1;
        goto rebuild_auction_page;
    }

    for(new td; td < 4; td++)
    {
        if(player_show_slot[playerid][td] == -1) continue;
        
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][0]], auction_slot[player_show_slot[playerid][td]][OWNER_SLOT_NAME]);
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][1]], auction_slot[player_show_slot[playerid][td]][SLOT_NAME]);
        printf("%d | slot td = %d", td, player_show_slot[playerid][td]);

        format(string, sizeof string, "Ставка~n~%d",
            auction_slot[player_show_slot[playerid][td]][CURRENT_RATE]);
        
        PlayerTextDrawSetString(playerid, auction_PTD[playerid][slot_td[td][2]], string);
    }
    return 1;
}

stock ProbelText(string[])
{
    new result[256], length = strlen(string);
    if(length >= sizeof result) length = sizeof result - 1;
    for(new i; i < length; i++)
    {
        result[i] = string[i] == ' ' ? '_' : string[i];
    }
    result[length] = EOS;
    return result;
}
