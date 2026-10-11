#define E_HOUSE 1
#define E_VEHICLE   2
#define E_BUSINESS  3
#define E_FUELSTATION    4
#define E_GARAGE    5

#define EXCHANGE_LIST_PREV   (-1)
#define EXCHANGE_LIST_NEXT   (-2)
#define EXCHANGE_VEH_PAGE_SIZE (20)
// Dedicated IDs: the old 1610-1614/enum values collide with the ATM dialogs.
#define DIALOG_EXCHANGE_TYPE              (19810)
#define DIALOG_EXCHANGE_VEHICLE           (19811)
#define DIALOG_EXCHANGE_SURCHARGE         (19812)
#define DIALOG_EXCHANGE_SURCHARGE_AMOUNT  (19813)
#define DIALOG_EXCHANGE_CONFIRM           (19814)
#define NOTIFY_EXCHANGE_OFFER              (9210)

new string_284[285];

new player_exchange[MAX_PLAYERS];

public OnGameModeInit()
{
    print("[KRANIN_SYSTEM] Команда для обмена загружена.");
    #if defined ch_OnGameModeInit
        return ch_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit ch_OnGameModeInit
#if defined ch_OnGameModeInit
    forward ch_OnGameModeInit();
#endif

public OnPlayerDisconnect(playerid, reason)
{
    if(player_exchange[playerid] != -1)
    {
        new to_player = player_exchange[playerid];

        SendClientMessage(to_player, -1, ""USC" Игрок с которым вы обменивались вышел.");
        player_exchange[to_player] = -1;
        player_exchange[playerid] = -1;
    }
    #if defined name_OnPlayerDisconnect
        return name_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect name_OnPlayerDisconnect
#if defined name_OnPlayerDisconnect
    forward name_OnPlayerDisconnect(playerid, reason);
#endif

public OnPlayerConnect(playerid)
{
    player_exchange[playerid] = -1;
    #if defined ch_OnPlayerConnect
        return ch_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect ch_OnPlayerConnect
#if defined ch_OnPlayerConnect
    forward ch_OnPlayerConnect(playerid);
#endif



public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
        if(dialogid == DIALOG_EXCHANGE_TYPE)
    {
        if(response)
        {
            new to_player = player_exchange[playerid];
            if(to_player == -1 || !IsPlayerConnected(to_player))
            {
                DeleteFullPVarExchange(playerid);
                return 1;
            }

            if(listitem < 0 || listitem > 4) return ShowDialogSelectTypeExchange(playerid);
            new type = listitem + 1;
            new bool:is_select_other = (GetPVarInt(playerid, "select_to_player") != 0);
            new player = is_select_other ? to_player : playerid;

            if(type != E_VEHICLE)
                return Exchange_SelectSimpleAsset(playerid, player, type, is_select_other);

            if(is_select_other)
            {
                SendClientMessage(to_player, -1, "{FFD900}[Обмен] {FFFFFF}Игрок выбрал Ваш тип имущества - {FFD900}Машина");
                ShowNotificationNew(playerid, 1, 3, 0, 0, "Выберите имущество игрока", "");
            }
            else
            {
                SendClientMessage(to_player, -1, "{FFD900}[Обмен] {FFFFFF}Игрок выбрал свой тип имущества - {FFD900}Машина");
            }

            if(!Exchange_ShowVehicleList(playerid, player, 0, is_select_other))
            {
                ShowDialogSelectTypeExchange(playerid);
            }
        }
        else
        {
            new to_player = player_exchange[playerid];
            if(to_player != -1) DeleteFullPVarExchange(to_player);
            DeleteFullPVarExchange(playerid);
        }
    }

        if(dialogid == DIALOG_EXCHANGE_VEHICLE)
    {
        if(response)
        {
            new select_player = GetPVarInt(playerid, "select_to_player");

            new player = -1;
            if(select_player) player = player_exchange[playerid];
            else player = playerid;

            if(player == -1 || !IsPlayerConnected(player))
            {
                return 1;
            }

            new id = GetPlayerListitemValue(playerid, listitem);
            if(id == EXCHANGE_LIST_PREV)
            {
                return Exchange_ShowVehicleList(playerid, player, GetPVarInt(playerid, "exchange_veh_page") - 1, select_player != 0);
            }
            if(id == EXCHANGE_LIST_NEXT)
            {
                return Exchange_ShowVehicleList(playerid, player, GetPVarInt(playerid, "exchange_veh_page") + 1, select_player != 0);
            }
            if(id <= 0)
            {
                return ShowDialogSelectTypeExchange(playerid);
            }

            SetPVarInt(player, "database_vehicle", id);

            mysql_format(mysql, string_284, sizeof string_284, "SELECT model_id FROM ownable_cars WHERE id=%d", id);
            new Cache:result;
            result = mysql_query(mysql, string_284);

            if(!cache_num_rows())
            {
                print("[ERROR EXCHANGE MYSQL] ID ERROR:: 4");
                cache_delete(result);
                return ShowDialogSelectTypeExchange(playerid);
            }

            new model_id = cache_get_field_content_int(0, "model_id");
            new string_vehicle[68];
            GetVehicleModelName(model_id, string_vehicle, sizeof(string_vehicle));
            if(!strlen(string_vehicle))
            {
                format(string_vehicle, sizeof string_vehicle, "Model %d", model_id);
            }
            SetPVarString(player, "string_vehicle", string_vehicle);
            cache_delete(result);

            new to_player = player_exchange[playerid];
            if(to_player == -1 || !IsPlayerConnected(to_player))
            {
                return 1;
            }

            new message[144];

            if(!select_player)
            {
                format(message, sizeof message, "{FFD900}[Обмен] {FFFFFF}Игрок %s выбрал свой {FFD900}Машина %s", GetPlayerNameEx(playerid), string_vehicle);
            }
            else
            {
                format(message, sizeof message, "{FFD900}[Обмен] {FFFFFF}Игрок %s выбрал ваш {FFD900}Машина %s", GetPlayerNameEx(playerid), string_vehicle);
            }

            SendClientMessage(to_player, -1, message);

            if(!GetPVarInt(playerid, "select_to_player"))
            {
                ShowNotificationNew(playerid, 1, 3, 0, 0, "Выберите тип имущества игрока", "");
                SetPVarInt(playerid, "select_to_player", 1);
                ShowDialogSelectTypeExchange(playerid);
            }
            else
            {
                Dialog
                (
                    playerid, DIALOG_EXCHANGE_SURCHARGE, DIALOG_STYLE_LIST,
                    "{E0584B}BR BONUS | {FFFFFF}Предоплата",
                    "Без доплаты\n"\
                    "Доплачиваете Вы\n"\
                    "Доплачивает Игрок",
                    "Выбрать", "Отмена"
                );
            }
        }
        else ShowDialogSelectTypeExchange(playerid);
    }

    if(dialogid == DIALOG_EXCHANGE_SURCHARGE || dialogid == DIALOG_EXCHANGE_SURCHARGE_AMOUNT)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "surchange_type"))
            {
                new surchange = strval(inputtext), to_player = player_exchange[playerid];

                if(!surchange) return SendClientMessage(playerid, -1, ""SC" Нужно ввести сумму больше 0");

                if(GetPVarInt(playerid, "surchange_type") == 2)
                {
                    if(GetPlayerMoneyEx(to_player) >= surchange)
                    {
                        SetPVarInt(playerid, "surchange", surchange);
                        SendExchange(to_player);
                    }
                    else
                    {
                        player_exchange[to_player] = -1;
                        player_exchange[playerid] = -1;
                        
                        DeleteFullPVarExchange(playerid);
                    }
                }
                else
                {
                    if(GetPlayerMoneyEx(playerid) >= surchange)
                    {
                        SetPVarInt(playerid, "surchange", surchange);
                        SendExchange(to_player);
                    }
                    else
                    {
                        player_exchange[to_player] = -1;
                        player_exchange[playerid] = -1;
                        
                        DeleteFullPVarExchange(playerid);
                    }
                }           

                return 1;
            }

            switch(listitem)
            {
                case 0:
                {
                    new wait_text[128];
                    format(wait_text, sizeof wait_text, "{FFD900}[Обмен] {FFFFFF}Ожидайте подтверждение от игрока {FFD900}%s", GetPlayerNameEx(player_exchange[playerid]));
                    SendClientMessage(playerid, -1, wait_text);
                    SendExchange(player_exchange[playerid]);
                }
                case 1:
                {
                    Dialog
                    (
                        playerid, DIALOG_EXCHANGE_SURCHARGE_AMOUNT, DIALOG_STYLE_INPUT,
                        "{E0584B}BR BONUS | {FFFFFF}Предоплата",
                        "Введите сумму которую Вы должны доплатить игроку за обмен.",
                        "Обмен", "Выйти"
                    );
                    SetPVarInt(playerid, "surchange_type", 1);
                }
                case 2:
                {
                    Dialog
                    (
                        playerid, DIALOG_EXCHANGE_SURCHARGE_AMOUNT, DIALOG_STYLE_INPUT,
                        "{E0584B}BR BONUS | {FFFFFF}Предоплата",
                        "Введите сумму которую игрок должен доплатить Вам за обмен.",
                        "Обмен", "Выйти"
                    );
                    SetPVarInt(playerid, "surchange_type", 2);
                }
            }
        }
        else ShowDialogSelectTypeExchange(playerid);
    }
    if(dialogid == DIALOG_EXCHANGE_CONFIRM)
    {
        if(response)
        {
            new to_player = player_exchange[playerid];

            new type = GetPVarInt(playerid, "select_type_exchange"),
            type_1 = GetPVarInt(to_player, "select_type_exchange"),
            surchange = GetPVarInt(to_player, "surchange"),
            surchange_p = GetPVarInt(to_player, "surchange_type")-1;

            new vehicle_sql, vehicle_sql_1;
            if(type == E_VEHICLE) vehicle_sql = GetPVarInt(playerid, "database_vehicle");
            if(type_1 == E_VEHICLE) vehicle_sql_1 = GetPVarInt(to_player, "database_vehicle");

            Exchange(type, type_1, playerid, to_player, surchange, surchange_p, vehicle_sql, vehicle_sql_1);
        }
        else
        {
            SendClientMessage(player_exchange[playerid], -1,""USC"Игрок отказался от обмена.");
            SendClientMessage(playerid, -1,""USC"Вы отказались от обмена.");
            DeleteFullPVarExchange(playerid);
            DeleteFullPVarExchange(player_exchange[playerid]);
        }
    }
    #if defined ch_OnDialogResponse
return ch_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse ch_OnDialogResponse
#if defined ch_OnDialogResponse
forward ch_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif


CMD:changeprop(playerid, params[])
{
	extract params -> new to_player; else return SendClientMessage(playerid, 0x999999FF, "Используйте: /changeprop [id игрока]");

	if(!IsPlayerConnected(to_player) || to_player == playerid)
		return SendClientMessage(playerid, 0x999999FF, "Такого игрока нет");

	if(!IsPlayerInRangeOfPlayer(playerid, to_player, 6.0))
		return SendClientMessage(playerid, 0x999999FF, "Игрок находится слишком далеко");
    
    if(player_exchange[to_player] != -1)
        return SendClientMessage(playerid, -1, ""USC"Игрок в данный момент обменивается с другим игроком.");

    player_exchange[playerid] = -1;

    new text[144];
    format(text, sizeof text, "Вы предложили %s начать обмен имуществом.", GetPlayerNameEx(to_player));
    SendClientMessage(playerid, 0x3399FFFF, text);

    format(text, sizeof text, "Предложение от %s", GetPlayerNameEx(playerid));
    ShowNotificationNew(to_player, 4, 10, NOTIFY_EXCHANGE_OFFER, 0, text, ">>");
    

    SetPVarInt(to_player, "to_player", playerid);
    SetPVarInt(playerid, "playerid", to_player);

    return 1;
}

cmd:yeschange(playerid)
{
    new id = GetPVarInt(playerid, "to_player");
    if(id == -1 || !IsPlayerConnected(id))
        return SendClientMessage(playerid, 0x999999FF, "Предложение на обмен недоступно");

    new from_player = GetPVarInt(id, "playerid");
    if(from_player != playerid)
        return SendClientMessage(playerid, 0x999999FF, "Предложение на обмен устарело");

    if(player_exchange[playerid] != -1 || player_exchange[id] != -1)
        return SendClientMessage(playerid, 0x999999FF, "Один из игроков уже в обмене");

    player_exchange[id] = from_player;
    player_exchange[playerid] = id;

    SendClientMessage(id, 0xFFD900FF, "Игрок согласился на обмен имуществом.");
    SendClientMessage(playerid, 0xFFD900FF, "Вы согласились на обмен имуществом.");

    ShowDialogSelectTypeExchange(id);
    return 1;
}
stock Exchange(type, type_1, player, player_1, surcharge = 0, surcharge_p = -1, vehicle_sql = -1, vehicle_sql_1 = -1)
{
    if(player_exchange[player] != player_1 || player_exchange[player_1] != player)
        return 0;
    if(!IsPlayerConnected(player) || !IsPlayerConnected(player_1) || !IsPlayerInRangeOfPlayer(player, player_1, 6.0))
        return Exchange_Fail(player, player_1, "Игрок отошёл слишком далеко. Обмен отменён.");

    new asset_id = GetPVarInt(player, "exchange_asset_id");
    new asset_id_1 = GetPVarInt(player_1, "exchange_asset_id");
    if(type == E_VEHICLE) asset_id = vehicle_sql;
    if(type_1 == E_VEHICLE) asset_id_1 = vehicle_sql_1;
    if(!Exchange_ValidateAsset(player, type, asset_id) || !Exchange_ValidateAsset(player_1, type_1, asset_id_1))
        return Exchange_Fail(player, player_1, "Состав имущества изменился. Обмен отменён.");
    if(!Exchange_CanReceive(player, type_1, type) || !Exchange_CanReceive(player_1, type, type_1))
        return Exchange_Fail(player, player_1, "У одного из игроков нет свободного слота для имущества.");
    if(surcharge > 0)
    {
        new payer = surcharge_p ? player_1 : player;
        if(GetPlayerMoneyEx(payer) < surcharge)
            return Exchange_Fail(player, player_1, "У плательщика недостаточно денег. Обмен отменён.");
    }

    mysql_query(mysql, "START TRANSACTION", false);
    if(mysql_errno()
        || !Exchange_TransferAssetDatabase(type, asset_id, GetPlayerAccountID(player), GetPlayerAccountID(player_1))
        || !Exchange_TransferAssetDatabase(type_1, asset_id_1, GetPlayerAccountID(player_1), GetPlayerAccountID(player)))
    {
        mysql_query(mysql, "ROLLBACK", false);
        return Exchange_Fail(player, player_1, "Ошибка базы данных. Имущество не было изменено.");
    }
    mysql_query(mysql, "COMMIT", false);
    if(mysql_errno()) return Exchange_Fail(player, player_1, "Не удалось завершить обмен. Обратитесь к администрации.");

    Exchange_ApplyAssetMemory(type, asset_id, player, player_1);
    Exchange_ApplyAssetMemory(type_1, asset_id_1, player_1, player);

    if(surcharge > 0)
    {
        new payer = surcharge_p ? player_1 : player;
        new receiver = surcharge_p ? player : player_1;
        GivePlayerMoneyEx(payer, -surcharge, "Доплата при обмене имуществом", false, true);
        GivePlayerMoneyEx(receiver, surcharge, "Доплата при обмене имуществом", false, false);
    }

    new final_msg[128];
    format(final_msg, sizeof final_msg, "{FFD900}[Обмен] {FFFFFF}Вы провели обмен с игроком {FFD900}%s", GetPlayerNameEx(player_1));
    SendClientMessage(player, -1, final_msg);
    format(final_msg, sizeof final_msg, "{FFD900}[Обмен] {FFFFFF}Вы провели обмен с игроком {FFD900}%s", GetPlayerNameEx(player));
    SendClientMessage(player_1, -1, final_msg);
    DeleteFullPVarExchange(player);
    DeleteFullPVarExchange(player_1);
    return 1;

    /* Legacy transfer implementation retained below for reference. */
    #if 0
    switch(type)
    {
        case E_HOUSE:ExchangeHouse(player, player_1);
        case E_VEHICLE:ExchangeVehicle(player_1, vehicle_sql);
        case E_BUSINESS:ExchangeBusiness(player, player_1);
        case E_FUELSTATION:ExchangeFuelStation(player, player_1);
        default:print("ERROR EXCHANGE - None Type");
    }

    switch(type_1)
    {
        case E_HOUSE:ExchangeHouse(player_1, player);
        case E_VEHICLE:ExchangeVehicle(player, vehicle_sql_1);
        case E_BUSINESS:ExchangeBusiness(player_1, player);
        case E_FUELSTATION:ExchangeFuelStation(player_1, player);
        default:print("ERROR EXCHANGE - None Type_1");
    }

    if(surcharge >= 1)
    {
        new player_money = -1, player_take_money = -1;

        if(!surcharge_p)
        {
            player_money = player;
            player_take_money = player_1;
        } 
        else if(surcharge_p)
        {
            player_money = player_1;
            player_take_money = player;
        } 
        else return print("Error");

        GivePlayerMoneyEx(player_money, surcharge);
        GivePlayerMoneyEx(player_take_money, -surcharge);
    }

        SendClientMessage(player, -1, "{FFD900}[Обмен] {FFFFFF}Идет проверка имущества игрока который предложил Вам обмен.");
    SendClientMessage(player, -1, "{FFD900}[Обмен] {FFFFFF}Идет проверка Вашего имущества.");
    SendClientMessage(player, -1, "{FFD900}{FFFFFF}Напишите {FFD900}/car {FFFFFF}чтобы узнать о возможностях.");
    SendClientMessage(player, -1, "{FFD900}{FFFFFF}Вам были переданы ключи от транспорта.");

    SendClientMessage(player_1, -1, "{FFD900}[Обмен] {FFFFFF}Идет проверка Вашего имущества.");
    SendClientMessage(player_1, -1, "{FFD900}[Обмен] {FFFFFF}Идет проверка имущества игрока который предложил Вам обмен.");
    SendClientMessage(player_1, -1, "{FFD900}{FFFFFF}Напишите {FFD900}/car {FFFFFF}чтобы узнать о возможностях.");
    SendClientMessage(player_1, -1, "{FFD900}{FFFFFF}Вам были переданы ключи от транспорта.");

    new final_msg[128];
    format(final_msg, sizeof final_msg, "{FFD900}[Обмен] {FFFFFF}Вы провели обмен с игроком {FFD900}%s", GetPlayerNameEx(player_1));
    SendClientMessage(player, -1, final_msg);

    format(final_msg, sizeof final_msg, "{FFD900}[Обмен] {FFFFFF}Вы провели обмен с игроком {FFD900}%s", GetPlayerNameEx(player));
    SendClientMessage(player_1, -1, final_msg);

    DeleteFullPVarExchange(player);
    DeleteFullPVarExchange(player_1);
    return 1;
    #endif
}

stock ExchangeVehicle(playerid, sql_id)
{
    new vehicleid = GetPlayerOwnableCar(player_exchange[playerid]);

	if(vehicleid != INVALID_VEHICLE_ID)
    {
        new index = GetVehicleData(vehicleid, V_ACTION_ID);
        if(GetOwnableCarData(index, OC_SQL_ID) == sql_id) UnloadPlayerOwnableCar(player_exchange[playerid]);
    }
    
    mysql_format(mysql, string_284, sizeof string_284, "UPDATE ownable_cars SET owner_id=%d WHERE id=%d", GetPlayerAccountID(playerid), sql_id);
    mysql_query(mysql, string_284, false);

    if(mysql_errno()) return print("[ERROR EXCHANGE MYSQL] ID ERROR:: 3");
    return 1;
}

stock ExchangeFuelStation(playerid, to_player)
{
    new stationid = GetPlayerFuelStation(playerid);
    new account_player = GetPlayerAccountID(playerid),
    account_to_player = GetPlayerAccountID(to_player);

    SetPlayerData(playerid, P_FUEL_ST, -1);

    mysql_format(mysql, string_284, sizeof string_284, "UPDATE accounts SET fuel_st=-1 WHERE id=%d", account_player);
    mysql_query(mysql, string_284, false);
    if(mysql_errno()) return print("[ERROR EXCHANGE MYSQL] ID ERROR:: 6");
    

    format(string_284, sizeof string_284, "UPDATE accounts a, fuel_stations f SET a.fuel_st=%d,f.owner_id=%d WHERE a.id=%d AND f.id=%d", stationid, account_to_player, account_to_player, GetFuelStationData(stationid, FS_SQL_ID));
    mysql_query(mysql, string_284, false);
    if(mysql_errno()) return print("[ERROR EXCHANGE MYSQL] ID ERROR:: 6.1");

    if(!mysql_errno())
    {
        SetPlayerData(to_player, P_FUEL_ST, stationid);

        SetFuelStationData(stationid, FS_OWNER_ID, 		account_to_player);
        SetFuelStationData(stationid, FS_IMPROVEMENTS, 0);

        new time = gettime();
        new rent_time = (time - (time % 86400)) + 86400;

        SetFuelStationData(stationid, FS_FUELS, 		50);
        SetFuelStationData(stationid, FS_FUEL_PRICE,	3);
        SetFuelStationData(stationid, FS_BUY_FUEL_PRICE,0);

        SetFuelStationData(stationid, FS_BALANCE,		0);
        SetFuelStationData(stationid, FS_RENT_DATE,		rent_time);
        SetFuelStationData(stationid, FS_LOCK_STATUS,	false);

        format(g_fuel_station[stationid][FS_OWNER_NAME], 21, GetPlayerNameEx(to_player), 0);
        CallLocalFunction("UpdateFuelStationLabel", "i", stationid);

        SendClientMessage(to_player, 0x66CC00FF, "Напишите {3399FF}/fuelst {66CC00}чтобы узнать о возможностях");

        format(string_284, sizeof string_284, "UPDATE fuel_stations SET improvements=0,fuels=%d,fuel_price=%d,buy_fuel_price=%d,balance=%d,rent_time=%d,`lock`=%d WHERE id=%d LIMIT 1", GetFuelStationData(stationid, FS_FUELS), GetFuelStationData(stationid, FS_FUEL_PRICE), GetFuelStationData(stationid, FS_BUY_FUEL_PRICE), GetFuelStationData(stationid, FS_BALANCE), GetFuelStationData(stationid, FS_RENT_DATE), GetFuelStationData(stationid, FS_LOCK_STATUS), GetFuelStationData(stationid, FS_SQL_ID));
        mysql_query(mysql, string_284, false);

        format(string_284, sizeof string_284, "UPDATE fuel_stations_profit SET view=0 WHERE fid=%d AND view=1",  GetFuelStationData(stationid, FS_SQL_ID));
        mysql_query(mysql, string_284, false);

        return 1;
    }

    return 1;
}
stock ExchangeBusiness(playerid, to_player)
{
    new businessid = GetPlayerBusiness(playerid);
    
    new account_player = GetPlayerAccountID(playerid),
    account_to_player = GetPlayerAccountID(to_player);

    SetPlayerData(playerid, P_BUSINESS, -1);
    
    mysql_format(mysql, string_284, sizeof string_284, "UPDATE accounts SET business=-1 WHERE id=%d", account_player);
    mysql_query(mysql, string_284, false);
    if(mysql_errno()) return print("[ERROR EXCHANGE MYSQL] ID ERROR:: 2");

    mysql_format(mysql, string_284, sizeof string_284, "UPDATE accounts a, business b SET a.business=%d,b.owner_id=%d WHERE a.id=%d AND b.id=%d", businessid, account_to_player, account_to_player, GetBusinessData(businessid, B_SQL_ID));
    mysql_query(mysql, string_284, false);
    if(mysql_errno()) return print("[ERROR EXCHANGE MYSQL] ID ERROR:: 2.1");
    printf("sql %s", string_284);

    if(!mysql_errno())
    {
        SetPlayerData(to_player, P_BUSINESS, businessid);

        SetBusinessData(businessid, B_OWNER_ID, account_to_player);
        SetBusinessData(businessid, B_IMPROVEMENTS, 	0);

        new time = gettime();//Автор данной системы https://t.me/welsistudio (Welsi Studio)
        new rent_time = (time - (time % 86400)) + 86400;


        SetBusinessData(businessid,	B_PRODS, 		20);
        SetBusinessData(businessid,	B_PROD_PRICE, 	0);

        SetBusinessData(businessid,	B_ENTER_MUSIC, 	0);
        SetBusinessData(businessid,	B_ENTER_PRICE, 	0);

        SetBusinessData(businessid,	B_BALANCE, 		0);
        SetBusinessData(businessid,	B_RENT_DATE,	rent_time);
        SetBusinessData(businessid,	B_LOCK_STATUS,	false);


        format(g_business[businessid][B_OWNER_NAME], 21, GetPlayerNameEx(to_player), 0);
        CallLocalFunction("UpdateBusinessLabel", "i", businessid);

        SendClientMessage(to_player, 0x66CC00FF, "Напишите {0099FF}/business {66CC00}чтобы узнать о возможностях");

        format(string_284, sizeof string_284, "UPDATE business SET improvements=0,products=%d,prod_price=%d,balance=%d,rent_time=%d,`lock`=%d WHERE id=%d LIMIT 1", GetBusinessData(businessid, B_PRODS), GetBusinessData(businessid, B_PROD_PRICE), GetBusinessData(businessid, B_BALANCE), GetBusinessData(businessid, B_RENT_DATE), GetBusinessData(businessid, B_LOCK_STATUS), GetBusinessData(businessid, B_SQL_ID));
        mysql_query(mysql, string_284, false);
        if(mysql_errno()) return print("[ERROR EXCHANGE MYSQL] ID ERROR:: 2.2");

        format(string_284, sizeof string_284, "UPDATE business_profit SET view=0 WHERE bid=%d AND view=1", GetBusinessData(businessid, B_SQL_ID));
        mysql_query(mysql, string_284, false);
        if(mysql_errno()) return print("[ERROR EXCHANGE MYSQL] ID ERROR:: 2.3");

        return 1;
    }
    return 1;
}
stock ExchangeHouse(playerid, to_player)
{
    new houseid = GetPlayerHouse(playerid);

    new account_player = GetPlayerAccountID(playerid),
    account_to_player = GetPlayerAccountID(to_player);


    SetPlayerData(playerid, P_HOUSE, 		-1);
    SetPlayerData(playerid, P_HOUSE_TYPE, 	-1);

    mysql_format(mysql, string_284, sizeof string_284, "UPDATE accounts SET house_type = -1, house = -1 WHERE id=%d", account_player);
    mysql_query(mysql, string_284, false);
    if(mysql_errno()) return print("[ERROR EXCHANGE MYSQL] ID ERROR:: 0.9");


    format(string_284, sizeof string_284, "UPDATE accounts a, houses h SET a.house_type=%d,a.house=%d,h.owner_id=%d WHERE a.id=%d AND h.id=%d", HOUSE_TYPE_HOME, houseid, account_to_player, account_to_player, GetHouseData(houseid, H_SQL_ID));
    mysql_query(mysql, string_284, false);
    if(mysql_errno()) return print("[ERROR EXCHANGE MYSQL] ID ERROR:: 1");
    printf("sql %s", string_284);

    if(!mysql_errno())
    {
        SetPlayerData(to_player, P_HOUSE, 		houseid);
        SetPlayerData(to_player, P_HOUSE_TYPE, 	HOUSE_TYPE_HOME);


        SetHouseData(houseid, H_OWNER_ID, account_to_player);
        SetHouseData(houseid, H_IMPROVEMENTS, 	0);

        SetHouseData(houseid, H_STORE_X, 0.0);
        SetHouseData(houseid, H_STORE_Y, 0.0);
        SetHouseData(houseid, H_STORE_Z, 0.0);

        new time = gettime();
        new rent_time = (time - (time % 86400)) + 86400;

        if(GetElapsedTime(GetHouseData(houseid, H_RENT_DATE), time, CONVERT_TIME_TO_DAYS) <= 0)
        {
            SetHouseData(houseid, H_RENT_DATE, rent_time);
        }

        new entranceid = GetHouseData(houseid, H_ENTRACE);
        if(entranceid != -1)
        {
            CallLocalFunction("EntranceStatusInit", "i", entranceid);
        }

        new Cache:result, name[24];

        if(mysql_errno()) return print("[ERROR EXCHANGE MYSQL] ID ERROR:: 1.1");


        format(g_house[houseid][H_OWNER_NAME], 21, GetPlayerNameEx(to_player), 0);

        cache_delete(result);

        UpdateHouse(houseid);

        HouseHealthInit(houseid);
        HouseStoreInit(houseid);

        format(string_284, sizeof string_284, "UPDATE houses SET improvements=0,rent_time=%d,`lock`=%d,store_x=0.0,store_y=0.0,store_z=0.0 WHERE id=%d LIMIT 1", GetHouseData(houseid, H_RENT_DATE), GetHouseData(houseid, H_LOCK_STATUS), GetHouseData(houseid, H_SQL_ID));
        mysql_query(mysql, string_284, false);
        if(mysql_errno()) return print("[ERROR EXCHANGE MYSQL] ID ERROR:: 1.2");
    }
    return 1;
}

stock bool:Exchange_ShowVehicleList(viewerid, ownerid, page = 0, bool:is_select_other = false)
{
    if(ownerid == INVALID_PLAYER_ID || !IsPlayerConnected(ownerid))
    {
        return false;
    }

    new Cache:result;
    mysql_format(mysql, string_284, sizeof string_284, "SELECT id, model_id FROM ownable_cars WHERE owner_id='%d'", GetPlayerAccountID(ownerid));
    result = mysql_query(mysql, string_284);

    if(mysql_errno())
    {
        print("[ERROR EXCHANGE MYSQL] ID ERROR:: 5");
        cache_delete(result);
        return false;
    }

    new rows = cache_num_rows();
    if(!rows)
    {
        SendClientMessage(viewerid, -1, is_select_other ? ""USC" У игрока нет транспорта" : ""USC" У вас нет транспорта");
        cache_delete(result);
        return false;
    }

    new max_page = (rows - 1) / EXCHANGE_VEH_PAGE_SIZE;
    if(page < 0) page = 0;
    if(page > max_page) page = max_page;

    new start = page * EXCHANGE_VEH_PAGE_SIZE;
    new end = start + EXCHANGE_VEH_PAGE_SIZE;
    if(end > rows) end = rows;

    new dialog[4096], row_text[160], listed = 0;
    format(dialog, sizeof dialog, "{E0584B}##\t{E0584B}Название\t{808080}Взаимодействие\n");

    for(new i = start; i < end; i++)
    {
        new id = cache_get_field_content_int(i, "id");
        new model_id = cache_get_field_content_int(i, "model_id");
        new model_name[32];

        GetVehicleModelName(model_id, model_name, sizeof(model_name));
        if(!strlen(model_name))
        {
            format(model_name, sizeof model_name, "Model %d", model_id);
        }

        format(row_text, sizeof row_text, "{E0584B}#%d\t{FFFFFF}%s\tНажмите для взаимодействия\n", id, model_name);
        if(strlen(dialog) + strlen(row_text) + 64 >= sizeof(dialog))
        {
            break;
        }

        strcat(dialog, row_text, sizeof(dialog));
        SetPlayerListitemValue(viewerid, listed, id);
        listed++;
    }

    if(page > 0)
    {
        format(row_text, sizeof row_text, "{AAAAAA}<< Назад\t\t\n");
        if(strlen(dialog) + strlen(row_text) < sizeof(dialog))
        {
            strcat(dialog, row_text, sizeof(dialog));
            SetPlayerListitemValue(viewerid, listed, EXCHANGE_LIST_PREV);
            listed++;
        }
    }

    if(page < max_page)
    {
        format(row_text, sizeof row_text, "{AAAAAA}Далее >>\t\t\n");
        if(strlen(dialog) + strlen(row_text) < sizeof(dialog))
        {
            strcat(dialog, row_text, sizeof(dialog));
            SetPlayerListitemValue(viewerid, listed, EXCHANGE_LIST_NEXT);
            listed++;
        }
    }

    SetPVarInt(viewerid, "exchange_veh_page", page);
    SetPVarInt(ownerid, "select_type_exchange", E_VEHICLE);

    Dialog(viewerid, DIALOG_EXCHANGE_VEHICLE, DIALOG_STYLE_TABLIST_HEADERS, "{E0584B}BR BONUS | {FFFFFF}Выберете что обменять", dialog, "Выбрать", "Отмена");

    cache_delete(result);
    return true;
}
stock ShowDialogSelectTypeExchange(playerid)
{
    if(player_exchange[playerid] != -1)
    {
        Dialog
        (
            playerid, DIALOG_EXCHANGE_TYPE, DIALOG_STYLE_TABLIST_HEADERS,
            "{E0584B}BR BONUS | {FFFFFF}Выберете тип имущества",
             "{E0584B}##\t{E0584B}Тип\t{808080}Взаимодействие\n"\
             "{FFFFFF}#1.\t{FFFFFF}Дом/квартира\tНажмите для взаимодействия\n"\
             "{FFFFFF}#2.\t{FFFFFF}Машина\tНажмите для взаимодействия\n"\
             "{FFFFFF}#3.\t{FFFFFF}Бизнес\tНажмите для взаимодействия\n"\
             "{FFFFFF}#4.\t{FFFFFF}АЗС\tНажмите для взаимодействия\n"\
             "{FFFFFF}#5.\t{FFFFFF}Гараж\tНажмите для взаимодействия",
            "Выбрать", "Отмена"
        );
    }

    return 1;
}

stock SendExchange(playerid)
{
    new to_player = player_exchange[playerid];

    new surchange_money = GetPVarInt(to_player, "surchange");
    new surchange[48] = "Без доплаты";

    new asset_self[68], asset_other[68];
    if(GetPVarInt(playerid, "select_type_exchange") == E_VEHICLE)
        GetPVarString(playerid, "string_vehicle", asset_self, sizeof(asset_self));
    else GetPVarString(playerid, "exchange_asset_name", asset_self, sizeof(asset_self));
    if(GetPVarInt(to_player, "select_type_exchange") == E_VEHICLE)
        GetPVarString(to_player, "string_vehicle", asset_other, sizeof(asset_other));
    else GetPVarString(to_player, "exchange_asset_name", asset_other, sizeof(asset_other));

    if(!strlen(asset_self)) format(asset_self, sizeof asset_self, "Неизвестно");
    if(!strlen(asset_other)) format(asset_other, sizeof asset_other, "Неизвестно");

    if(surchange_money >= 1)
    {
        switch(GetPVarInt(to_player, "surchange_type"))
        {
            case 1: format(surchange, sizeof surchange, "Доплачиваете Вы %d рублей", surchange_money);
            case 2: format(surchange, sizeof surchange, "Доплачивает игрок %d рублей", surchange_money);
        }
    }

    format
    (
        string_284, sizeof string_284,
        "Вы выполняете обмен с {FFD900}%s\n\
        {FFFFFF}Игрок отдаёт: {FFD900}%s\n\
        {FFFFFF}Вы отдаёте: {FFD900}%s\n\
        {FFFFFF}Вам платят: %s\n\n\
        Вы согласны",
        GetPlayerNameEx(to_player),
        asset_other,
        asset_self,
        surchange
    );

    Dialog
    (
        playerid, DIALOG_EXCHANGE_CONFIRM, DIALOG_STYLE_MSGBOX,
        "{E0584B}BR BONUS | {FFFFFF}Обмен",
        string_284,
        "Обмен", "Выйти"
    );

    return 1;
}

stock DeleteFullPVarExchange(playerid)
{
    player_exchange[playerid] = -1;
    DeletePVar(playerid, "surcharge");
    DeletePVar(playerid, "surchange");
    DeletePVar(playerid, "surchange_type");
    DeletePVar(playerid, "select_to_player");
    DeletePVar(playerid, "string_vehicle");
    DeletePVar(playerid, "database_vehicle");
    DeletePVar(playerid, "select_type_exchange");
    DeletePVar(playerid, "exchange_veh_page");
    DeletePVar(playerid, "exchange_asset_id");
    DeletePVar(playerid, "exchange_asset_name");
    
    return 1;
}
