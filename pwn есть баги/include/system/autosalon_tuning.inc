stock GetCarMarketIdByBizId(biz_id)
{
	switch(biz_id)
	{
		case STATIC_BIZ_ID_MOTO_SALON: return MOTO_SALON_MARKET_ID;
		case 35: return 1;
		case 36: return 2;
		case 37: return 3;
		case STATIC_BIZ_ID_TRUCK_SALON: return TRUCK_SALON_MARKET_ID;
	}
	return -1;
}

stock GetBizIdByCarMarketId(car_market_id)
{
	switch(car_market_id)
	{
		case MOTO_SALON_MARKET_ID: return STATIC_BIZ_ID_MOTO_SALON;
		case 1: return 35;
		case 2: return 36;
		case 3: return 37;
		case TRUCK_SALON_MARKET_ID: return STATIC_BIZ_ID_TRUCK_SALON;
	}
	return -1;
}

stock bool:AutosalonHasBusinessProducts(playerid, car_market_id, &businessid)
{
	businessid = GetBizIdByCarMarketId(car_market_id);
	if(businessid < 0 || businessid >= g_business_loaded ||
		GetBusinessData(businessid, B_TYPE) != BUSINESS_TYPE_CAR_MARKET)
	{
		SendClientMessage(playerid, 0xCECECEFF, "Автосалон временно недоступен.");
		return false;
	}
	if(GetBusinessData(businessid, B_PRODS) < AUTOSALON_PRODUCTS_PER_CAR)
	{
		SendClientMessage(playerid, 0xCECECEFF, "В автосалоне закончились продукты. Владелец должен пополнить склад.");
		return false;
	}
	return true;
}

stock AutosalonUseBusinessProducts(businessid, playerid, vehicle_price)
{
	if(businessid < 0 || businessid >= g_business_loaded) return 0;
	AddBusinessData(businessid, B_PRODS, -, AUTOSALON_PRODUCTS_PER_CAR);
	new owner_income = vehicle_price / 5; // 20%, division first prevents 32-bit overflow above 107m
	AddBusinessData(businessid, B_BALANCE, +, owner_income);
	new query[320];
	mysql_format(mysql, query, sizeof query,
		"UPDATE business SET products=%d,balance=%d WHERE id=%d LIMIT 1",
		GetBusinessData(businessid, B_PRODS), GetBusinessData(businessid, B_BALANCE),
		GetBusinessData(businessid, B_SQL_ID));
	mysql_query(mysql, query, false);
	mysql_format(mysql, query, sizeof query,
		"INSERT INTO business_profit (bid,uid,uip,time,money,view) VALUES (%d,%d,'%e',%d,%d,%d)",
		GetBusinessData(businessid, B_SQL_ID), GetPlayerAccountID(playerid), GetPlayerIpEx(playerid),
		gettime(), owner_income, IsBusinessOwned(businessid));
	mysql_query(mysql, query, false);
	CallLocalFunction("UpdateBusinessLabel", "i", businessid);
	return 1;
}

stock bool:IsMotoSalonBiz(biz_id)
{
	return biz_id == STATIC_BIZ_ID_MOTO_SALON;
}

stock GetCarMarketDialogName(car_market_id, dest[], size = sizeof dest)
{
	if(car_market_id == MOTO_SALON_MARKET_ID)
	{
		format(dest, size, "Мотосалон");
	}
	else if(car_market_id == TRUCK_SALON_MARKET_ID)
	{
		format(dest, size, "Автосалон");
	}
	else
	{
		format(dest, size, "Автосалон");
	}
	return 1;
}

stock IsMotoSalonCameraAnimating(playerid)
{
	if(GetPlayerInBiz(playerid) != STATIC_BIZ_ID_MOTO_SALON) return 0;
	return GetPVarInt(playerid, "moto_salon_camera_anim_until") > GetTickCount();
}

stock ApplyCarMarketPreviewScene(playerid, vehicleid, car_market_id, bool:animate_camera = false)
{
	if(!(0 <= car_market_id <= 4)) return 1;
	if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid)) return 1;

	new bool:keep_moto_camera_animation =
	(
		car_market_id == MOTO_SALON_MARKET_ID
		&& !animate_camera
		&& IsMotoSalonCameraAnimating(playerid)
	);

	if(!keep_moto_camera_animation)
	{
		SetPlayerVirtualWorld(playerid, playerid + 1);
		SetPlayerInterior(playerid, g_car_market_scene[car_market_id][CMS_INTERIOR]);
		SetPlayerPosEx
		(
			playerid,
			g_car_market_scene[car_market_id][CMS_PLAYER_X],
			g_car_market_scene[car_market_id][CMS_PLAYER_Y],
			g_car_market_scene[car_market_id][CMS_PLAYER_Z],
			g_car_market_scene[car_market_id][CMS_PLAYER_A],
			g_car_market_scene[car_market_id][CMS_INTERIOR],
			playerid + 1,
			false
		);
		TogglePlayerControllable(playerid, false);
	}

	SetVehiclePos
	(
		vehicleid,
		g_car_market_scene[car_market_id][CMS_VEH_X],
		g_car_market_scene[car_market_id][CMS_VEH_Y],
		g_car_market_scene[car_market_id][CMS_VEH_Z]
	);
	SetVehicleZAngle(vehicleid, g_car_market_scene[car_market_id][CMS_VEH_A]);
	SetVehicleVirtualWorld(vehicleid, playerid + 1);
	LinkVehicleToInterior(vehicleid, g_car_market_scene[car_market_id][CMS_INTERIOR]);
	SetVehicleNumberPlateEx(vehicleid, TYPE_RU, "", "");

	if(car_market_id == MOTO_SALON_MARKET_ID && animate_camera)
	{
		SetPVarInt(playerid, "moto_salon_camera_anim_until", GetTickCount() + 2500);
		SetPlayerCameraPos(playerid, -586.811035, 2288.229980, 1501.715820);
		SetPlayerCameraLookAt
		(
			playerid,
			g_car_market_scene[car_market_id][CMS_LOOK_X],
			g_car_market_scene[car_market_id][CMS_LOOK_Y],
			g_car_market_scene[car_market_id][CMS_LOOK_Z]
		);
		InterpolateCameraPos
		(
			playerid,
			-586.811035, 2288.229980, 1501.715820,
			g_car_market_scene[car_market_id][CMS_CAM_X],
			g_car_market_scene[car_market_id][CMS_CAM_Y],
			g_car_market_scene[car_market_id][CMS_CAM_Z],
			2500,
			CAMERA_MOVE
		);
		InterpolateCameraLookAt
		(
			playerid,
			g_car_market_scene[car_market_id][CMS_LOOK_X],
			g_car_market_scene[car_market_id][CMS_LOOK_Y],
			g_car_market_scene[car_market_id][CMS_LOOK_Z],
			g_car_market_scene[car_market_id][CMS_LOOK_X],
			g_car_market_scene[car_market_id][CMS_LOOK_Y],
			g_car_market_scene[car_market_id][CMS_LOOK_Z],
			2500,
			CAMERA_MOVE
		);
	}
	else
	{
		if(keep_moto_camera_animation)
		{
			return 1;
		}
		if(car_market_id == MOTO_SALON_MARKET_ID)
		{
			DeletePVar(playerid, "moto_salon_camera_anim_until");
		}
		SetPlayerCameraPos
		(
			playerid,
			g_car_market_scene[car_market_id][CMS_CAM_X],
			g_car_market_scene[car_market_id][CMS_CAM_Y],
			g_car_market_scene[car_market_id][CMS_CAM_Z]
		);
		SetPlayerCameraLookAt
		(
			playerid,
			g_car_market_scene[car_market_id][CMS_LOOK_X],
			g_car_market_scene[car_market_id][CMS_LOOK_Y],
			g_car_market_scene[car_market_id][CMS_LOOK_Z]
		);
	}
	return 1;
}

public: BuyCarPTDUpdate(playerid)
{
	new fmt_str[64];
	new fmt_text[96];
	if(GetPlayerData(playerid, P_BUY_CAR) == INVALID_VEHICLE_ID) return 1;

	new biz_id = GetPlayerInBiz(playerid);
	if (biz_id == -1) return 1;
	new car_market_id = GetCarMarketIdByBizId(biz_id);
	if(car_market_id == -1) return 1;

	new select_car = buy_car_select_car[playerid];
	new modelid = car_market_data[car_market_id][select_car][CM_MODELID];
	if(!modelid) return 1;

	new vehicle_price = car_market_data[car_market_id][select_car][CM_COST];
	new vehicle_speed = car_market_data[car_market_id][select_car][CM_SPEED];
	new Float:vehicle_acceleration = car_market_data[car_market_id][select_car][CM_ACCELERATION];
	new limit_text[32];
	if(IsAutosalonInfiniteStock(car_market_id))
		format(limit_text, sizeof limit_text, "INF");
	else
		format(limit_text, sizeof limit_text, "%d", GetAutosalonVehicleSlots(car_market_id, modelid));

	if(!vehicle_price && car_market_id != TRUCK_SALON_MARKET_ID) vehicle_price = GetVehicleInfo(modelid - 400, VI_PRICE);
	if(!vehicle_speed) vehicle_speed = GetVehicleInfo(modelid - 400, VI_MAXSP);
	if(vehicle_acceleration <= 0.0) vehicle_acceleration = float(GetVehicleInfo(modelid - 400, VI_USCOR));

	if(car_market_data[car_market_id][select_car][CM_NAME][0])
		format(fmt_text, sizeof fmt_text, "%s", car_market_data[car_market_id][select_car][CM_NAME]);
	else
		format(fmt_text, sizeof fmt_text, "%s", GetVehicleInfo(modelid - 400, VI_NAME));
	PlayerTextDrawSetString(playerid, avtsln_PTDD[playerid][0], fmt_text);
	new price_str[32], price_td_str[48];
	FormatNumberDots(vehicle_price, price_str, sizeof price_str);
	format(price_td_str, sizeof price_td_str, "%s РУБ.      ", price_str);
	PlayerTextDrawSetString(playerid, avtsln_PTDD[playerid][1], price_td_str);

	format(fmt_text, sizeof fmt_text, "%d ??/?", vehicle_speed);
	PlayerTextDrawSetString(playerid, avtsln_PTDD[playerid][2], fmt_text);

	format(fmt_text, sizeof fmt_text, "%.1f сек", vehicle_acceleration);
	PlayerTextDrawSetString(playerid, avtsln_PTDD[playerid][3], fmt_text);

	TextDrawSetString(avtsln_TD[7], "txd:brsalonlimit");
	if(car_market_id == TRUCK_SALON_MARKET_ID)
	{
		format(limit_text, sizeof limit_text, "-");
		switch(modelid)
		{
			case 514:
			{
				TextDrawSetString(avtsln_TD[7], "txd:brsaloncargo");
				format(limit_text, sizeof limit_text, "15.0 ТОНН");
			}
			case 403:
			{
				TextDrawSetString(avtsln_TD[7], "txd:brsaloncargo");
				format(limit_text, sizeof limit_text, "14.5 ТОНН");
			}
		}
	}
	PlayerTextDrawSetString(playerid, avtsln_PTDD[playerid][4], limit_text);
	buy_car_select_color[playerid][0] = GetPlayerData(playerid, P_AUTOSALON_COLOR1);
	buy_car_select_color[playerid][1] = GetPlayerData(playerid, P_AUTOSALON_COLOR2);
	ApplyAutosalonPreviewColor(playerid);
	return 1;
}
public: ShowBuyCarInfo(playerid, vehicleid)
{
	new text[275];

	//static const vehicle_class_name[][] = {"Мото-вело", "Эконом", "Средний", "Премиум"};

	new modelid = GetVehicleModel(vehicleid) - 400;
	format
	(
		text, sizeof text,
		"{FFFFFF}Тип автомобиля:\t%s класс\n\
		Название:\t\t%s\n\
		Номер модели:\t%d\n\
		Стоимость аренды:\t{FFFF00}%d руб.\n\
		{FFFFFF}Стоимость покупки:\t{00CC00}%d руб.\n\n\
		{FFFFFF}Для покупки этой модели нажмите \"Купить\"\n\
		Чтобы взять авто в аренду используйте /rentcar",
		"Неопределённый",
		//vehicle_class_name[ GetVehicleInfo(modelid, VI_TYPE) ],
		GetVehicleInfo(modelid, VI_NAME),
		modelid + 400,
		GetVehicleInfo(modelid, VI_PRICE) / 100,
		GetVehicleInfo(modelid, VI_PRICE)
	);

	Dialog(playerid, DIALOG_BIZ_CAR_MARKET_CAR_INFO, DIALOG_STYLE_MSGBOX, "{FF9900}Авторынок", text, "Купить", "Выйти");
	return 1;
}

stock RefreshAutosalonChat(playerid)
{
	SetPlayerCleanChat(playerid, 1);
	SetPlayerCleanChat(playerid, 0);
	return 1;
}

stock bool:PlayerHasFreeCarSlotForMarket(playerid, biz_id)
{
	if((GetPlayerOwnableCars(playerid) + 1) <= GetPlayerCarSlots(playerid))
	{
		return true;
	}

	if(IsMotoSalonBiz(biz_id))
	{
		SendClientMessage(playerid, 0x3399FFFF, "Все слоты для покупки нового мотоцикла заняты. Вы можете увеличить их: {FFFF00}\"/donate\"");
	}
	else
	{
		SendClientMessage(playerid, 0x3399FFFF, ""USC"У вас нет свободного слота. Вы можете купить их: {FFFF00}/donate");
	}
	return false;
}

stock EnterPlayerBuyCarMarket(playerid, biz_id)
{
	if(!PlayerHasFreeCarSlotForMarket(playerid, biz_id))
	{
		return 1;
	}

	if(biz_id == -1 || GetBusinessData(biz_id, B_TYPE) != BUSINESS_TYPE_CAR_MARKET)
		return 1;

	if(GetPVarInt(playerid, "car_market_open_lock") > GetTickCount())
		return 1;
	SetPVarInt(playerid, "car_market_open_lock", GetTickCount() + 1000);

	SetPlayerInBiz(playerid, biz_id);

	if(GetPlayerData(playerid, P_BUY_CAR) != INVALID_VEHICLE_ID)
	{
		DestroyVehicle(GetPlayerData(playerid, P_BUY_CAR));
		SetPlayerData(playerid, P_BUY_CAR, INVALID_VEHICLE_ID);
	}

	new car_market_id = GetCarMarketIdByBizId(biz_id);
	if(car_market_id == -1)
		return 1;

	new modelid = car_market_data[car_market_id][0][CM_MODELID];
	if(!modelid)
		return 1;

	buy_car_select_car[playerid] = 0;
	buy_car_select_color_type[playerid] = 0;
	buy_car_select_color[playerid][0] = 1;
	buy_car_select_color[playerid][1] = 1;
	SetPlayerData(playerid, P_AUTOSALON_COLOR1, 1);
	SetPlayerData(playerid, P_AUTOSALON_COLOR2, 1);

	new vehicleid = CreateVehicle(modelid, 1149.8434, 226.0655, 995.1953, 67.6542, 1, 1, 1);
	SetPlayerData(playerid, P_BUY_CAR, vehicleid);
	ApplyCarMarketPreviewScene(playerid, vehicleid, car_market_id, (car_market_id == MOTO_SALON_MARKET_ID));

	CallLocalFunction("BuyCarPTDUpdate", "i", playerid);
	CreateAutosalonTextDraws(playerid);
	HideHud(playerid);
	RefreshAutosalonChat(playerid);
	return 1;
}

stock DebugMotoSalonLog(playerid, const debug_event[], pickupid = -1, action_type = -1)
{
	new Float:pos_x, Float:pos_y, Float:pos_z;
	new pickup_action_type = -1;
	new pickup_action_id = -1;

	GetPlayerPos(playerid, pos_x, pos_y, pos_z);
	if(IsValidPickupID(pickupid))
	{
		pickup_action_type = GetPickupInfo(pickupid, P_ACTION_TYPE);
		pickup_action_id = GetPickupInfo(pickupid, P_ACTION_ID);
	}

	printf
	(
		"[MOTO_DEBUG] %s | playerid=%d name=%s pickupid=%d action_type=%d pickup_info_type=%d pickup_info_id=%d pos=%.4f %.4f %.4f interior=%d vw=%d biz=%d buy_car=%d last_pickup=%d exit_block=%d tick=%d",
		debug_event,
		playerid,
		GetPlayerNameEx(playerid),
		pickupid,
		action_type,
		pickup_action_type,
		pickup_action_id,
		pos_x,
		pos_y,
		pos_z,
		GetPlayerInterior(playerid),
		GetPlayerVirtualWorld(playerid),
		GetPlayerInBiz(playerid),
		GetPlayerData(playerid, P_BUY_CAR),
		GetPlayerData(playerid, P_LAST_PICKUP),
		GetPVarInt(playerid, "moto_salon_exit_block"),
		GetTickCount()
	);
	return 1;
}

stock ExitPlayerBuyCarMarket(playerid)
{
	if(GetPlayerData(playerid, P_BUY_CAR) == INVALID_VEHICLE_ID) return -1;

	StopAutosalonTestDriveMonitor(playerid);
    DeletePVar(playerid, "autosalon_testdrive_active");
    DeletePVar(playerid, "autosalon_testdrive_price");

	DestroyVehicle(GetPlayerData(playerid, P_BUY_CAR));
	SetPlayerData(playerid, P_BUY_CAR, INVALID_VEHICLE_ID);

	new in_biz = GetPlayerInBiz(playerid);
	if (in_biz == -1) return 1;
	new car_market_id = GetCarMarketIdByBizId(in_biz);
	new biz_interior = 0;

	if(IsMotoSalonBiz(in_biz))
	{
		biz_interior = 1;
	}

	TogglePlayerControllable(playerid, true);
	SetPlayerCleanChat(playerid, 0);
	DebugMotoSalonLog(playerid, "ExitPlayerBuyCarMarket:before");

	SetPlayerPosEx
	(
		playerid,
		GetBusinessData(in_biz, B_EXIT_POS_X),
		GetBusinessData(in_biz, B_EXIT_POS_Y),
		GetBusinessData(in_biz, B_EXIT_POS_Z),
		GetBusinessData(in_biz, B_EXIT_ANGLE),
		biz_interior,
		0
	);
	if(car_market_id == -1 || !IsMotoSalonBiz(in_biz))
	{
		SetPlayerInBiz(playerid, -1);
	}

	DebugMotoSalonLog(playerid, "ExitPlayerBuyCarMarket:after");
	
	HideAutosalonTextDraws(playerid);
	ShowHud(playerid);
	return 1;
}

stock CarMarketShowNextCar(playerid, next = '+')
{
	new biz_id = GetPlayerInBiz(playerid);
	if(biz_id == -1) return 1;
	new car_market_id = GetCarMarketIdByBizId(biz_id);
	if(car_market_id == -1) return 1;

	if(GetBusinessData(biz_id, B_TYPE) != BUSINESS_TYPE_CAR_MARKET) return 1;

	new max_car_index = GetCarMarketMaxIndex(car_market_id);

	if(next == '+')
	{
		if(++buy_car_select_car[playerid] > max_car_index)
			buy_car_select_car[playerid] = 0;
	}
					else
	{
		if(--buy_car_select_car[playerid] < 0)
			buy_car_select_car[playerid] = max_car_index;
	}

    new select_car = buy_car_select_car[playerid];
    SyncAutosalonSelectedColors(playerid);

    new old_vehicleid = GetPlayerData(playerid, P_BUY_CAR);
    if(old_vehicleid != INVALID_VEHICLE_ID && IsValidVehicle(old_vehicleid))
    {
        ResetVehicleStreamCache(old_vehicleid);
        DestroyVehicle(old_vehicleid);
    }
    SetPlayerData(playerid, P_BUY_CAR, INVALID_VEHICLE_ID);

    new vehicleid = CreateVehicle(car_market_data[car_market_id][select_car][CM_MODELID], 1149.8434, 226.0655, 995.1953, 67.6542, 1, 1, 1);
    if(vehicleid == INVALID_VEHICLE_ID) return 1;

    ResetVehicleStreamCache(vehicleid);
    SetPlayerData(playerid, P_BUY_CAR, vehicleid);
    ApplyCarMarketPreviewScene(playerid, vehicleid, car_market_id);
    ApplyAutosalonPreviewColor(playerid);

    CallLocalFunction("BuyCarPTDUpdate", "i", playerid);
	return 1;
}
stock GetCarMarketMaxIndex(market_id)
{
    new max_index = -1;

    for(new idx; idx < sizeof(car_market_data[]); idx++)
    {
        if(car_market_data[market_id][idx][CM_MODELID] != 0)
            max_index = idx;
    }
    return max_index;
}


stock PermanentTuning_ClearVehicleState(vehicleid)
{
    if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES) return 0;
    g_perm_tuning_ready[vehicleid] = false;
    g_perm_tuning_action[vehicleid] = VEHICLE_ACTION_TYPE_NONE;
    g_perm_tuning_identity[vehicleid] = 0;
    g_perm_tuning_count[vehicleid] = 0;
    g_perm_tuning_epoch[vehicleid]++;
    for(new i; i < PERM_TUNING_MAX_COMPONENTS; i++)
        g_perm_tuning_components[vehicleid][i] = 0;
    return 1;
}

stock PermanentTuning_GetIdentity(vehicleid, &action_type, &action_id)
{
    if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES || !IsValidVehicle(vehicleid)) return 0;
    action_type = GetVehicleData(vehicleid, V_ACTION_TYPE);
    action_id = GetVehicleData(vehicleid, V_ACTION_ID);

    if(action_type == VEHICLE_ACTION_TYPE_OWNABLE_CAR)
    {
        if(action_id < 0 || action_id >= MAX_OWNABLE_CARS) return 0;
        return GetOwnableCarData(action_id, OC_SQL_ID);
    }
    if(action_type == VEHICLE_ACTION_TYPE_FAMILY_CAR)
    {
        if(action_id < 0 || action_id >= MAX_OWNABLE_CARS) return 0;
        return GetCarFamily(action_id, CAR_F_database);
    }
    return 0;
}

stock PermanentTuning_RebuildVehicleState(vehicleid)
{
    new action_type, action_id;
    new identity = PermanentTuning_GetIdentity(vehicleid, action_type, action_id);
    if(identity <= 0)
    {
        PermanentTuning_ClearVehicleState(vehicleid);
        return 0;
    }

    if(action_type == VEHICLE_ACTION_TYPE_OWNABLE_CAR)
        SyncOwnableVehicleTuningData(vehicleid);

    new table_name[40];
    if(action_type == VEHICLE_ACTION_TYPE_FAMILY_CAR && g_FT55_New[action_id])
        format(table_name, sizeof table_name, "family_vehicle_components");
    else
        format(table_name, sizeof table_name, "vehicle_store_components");

    new query[160];
    mysql_format(mysql, query, sizeof query,
        "SELECT componentid FROM %s WHERE vehicleid=%d AND state=2", table_name, identity);
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        printf("[PERM_TUNING][SQL_ERROR] vehicle=%d identity=%d errno=%d", vehicleid, identity, mysql_errno());
        cache_delete(result);
        return 0;
    }

    new count, rows = cache_num_rows(result);
    new modelid = GetVehicleData(vehicleid, V_MODELID);
    for(new row; row < rows && count < PERM_TUNING_MAX_COMPONENTS; row++)
    {
        new itemid = cache_get_field_content_int(row, "componentid");
        if(!IsStoredTuneItemAllowedForModel(modelid, itemid)) continue;
        new componentid = GetTuneIdFromItem(itemid);
        if(componentid <= 0) continue;

        new bool:duplicate;
        for(new x; x < count; x++)
        {
            if(g_perm_tuning_components[vehicleid][x] == componentid)
            {
                duplicate = true;
                break;
            }
        }
        if(duplicate) continue;
        g_perm_tuning_components[vehicleid][count++] = componentid;
    }
    cache_delete(result);

    // wheel_comp is stored in ownable/family fields rather than the component table.
    // Put it in the same runtime layer so the self-heal path restores the visible
    // wheel model too, not only body-kit rows.
    new wheel_component;
    if(action_type == VEHICLE_ACTION_TYPE_OWNABLE_CAR)
        wheel_component = GetWheelTuneComponentId(GetOwnableCarData(action_id, OC_wheelcomp));
    else if(action_type == VEHICLE_ACTION_TYPE_FAMILY_CAR && g_FT55_New[action_id])
        wheel_component = GetWheelTuneComponentId(g_FT55[action_id][FT55_DISK]);
    if(wheel_component > 0 && count < PERM_TUNING_MAX_COMPONENTS)
    {
        new bool:wheel_duplicate;
        for(new x; x < count; x++)
        {
            if(g_perm_tuning_components[vehicleid][x] == wheel_component)
            {
                wheel_duplicate = true;
                break;
            }
        }
        if(!wheel_duplicate) g_perm_tuning_components[vehicleid][count++] = wheel_component;
    }

    for(new x = count; x < PERM_TUNING_MAX_COMPONENTS; x++)
        g_perm_tuning_components[vehicleid][x] = 0;

    g_perm_tuning_action[vehicleid] = action_type;
    g_perm_tuning_identity[vehicleid] = identity;
    g_perm_tuning_count[vehicleid] = count;
    g_perm_tuning_ready[vehicleid] = true;
    g_perm_tuning_epoch[vehicleid]++;

    printf("[PERM_TUNING][BUILD] vehicle=%d type=%d identity=%d components=%d epoch=%d",
        vehicleid, action_type, identity, count, g_perm_tuning_epoch[vehicleid]);
    return 1;
}

stock PermanentTuning_EnsureVehicleState(vehicleid)
{
    new action_type, action_id;
    new identity = PermanentTuning_GetIdentity(vehicleid, action_type, action_id);
    if(identity <= 0) return 0;

    if(!g_perm_tuning_ready[vehicleid] ||
       g_perm_tuning_action[vehicleid] != action_type ||
       g_perm_tuning_identity[vehicleid] != identity)
    {
        return PermanentTuning_RebuildVehicleState(vehicleid);
    }
    return 1;
}

stock PermanentTuning_ApplyComponentsForPlayer(playerid, vehicleid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(!PermanentTuning_EnsureVehicleState(vehicleid)) return 0;

    for(new i; i < g_perm_tuning_count[vehicleid]; i++)
    {
        new componentid = g_perm_tuning_components[vehicleid][i];
        if(componentid > 0)
            AddToVehicleComponentForPlayer(playerid, vehicleid, componentid);
    }
    return 1;
}

stock PermanentTuning_ApplyVehicleForPlayer(playerid, vehicleid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES || !IsValidVehicle(vehicleid)) return 0;

    new action_type = GetVehicleData(vehicleid, V_ACTION_TYPE);
    if(action_type != VEHICLE_ACTION_TYPE_OWNABLE_CAR && action_type != VEHICLE_ACTION_TYPE_FAMILY_CAR)
        return 0;

    PermanentTuning_EnsureVehicleState(vehicleid);

    // Do not send REMOVE ALL during stream recovery. The client destroys/recreates
    // the vehicle entity itself; a late REMOVE ALL can win the race and leave stock.
    g_tuning_additive_replay[playerid] = true;
    ApplyVehicleTuning(playerid, vehicleid);
    g_tuning_additive_replay[playerid] = false;
    ApplyVehicleFirmware(playerid, vehicleid);
    Styling_QueueSuspension(vehicleid);
    FT55_Queue(vehicleid);
    return 1;
}

stock ResetVehicleStreamCache(vehicleid)
{
    if(!IsValidVehicleID(vehicleid)) return 1;

    foreach(new stream_playerid : streamed_players_in_veh[vehicleid])
    {
        Iter_Remove(vehicle_in_stream[stream_playerid], vehicleid);
    }
    Iter_Clear(streamed_players_in_veh[vehicleid]);
    return 1;
}

stock ResetPlayerVehicleStreamCache(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;

    foreach(new stream_vehicleid : vehicle_in_stream[playerid])
    {
        if(IsValidVehicleID(stream_vehicleid))
            Iter_Remove(streamed_players_in_veh[stream_vehicleid], playerid);
    }
    Iter_Clear(vehicle_in_stream[playerid]);
    return 1;
}

stock QueuePlayerVehicleVisualRefresh(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    new epoch = ++g_vehicle_stream_refresh_epoch[playerid];
    SetTimerEx("Player_ReapplyStreamedVehicleVisuals", 250, false, "dd", playerid, epoch);
    SetTimerEx("Player_ReapplyStreamedVehicleVisuals", 900, false, "dd", playerid, epoch);
    SetTimerEx("Player_ReapplyStreamedVehicleVisuals", 2200, false, "dd", playerid, epoch);
    SetTimerEx("Player_ReapplyStreamedVehicleVisuals", 4500, false, "dd", playerid, epoch);
    return 1;
}

forward Player_ReapplyStreamedVehicleVisuals(playerid, epoch);
public Player_ReapplyStreamedVehicleVisuals(playerid, epoch)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
    if(epoch != g_vehicle_stream_refresh_epoch[playerid]) return 0;

    foreach(new vehicleid : Vehicle)
    {
        new action_type = GetVehicleData(vehicleid, V_ACTION_TYPE);
        if(action_type != VEHICLE_ACTION_TYPE_OWNABLE_CAR && action_type != VEHICLE_ACTION_TYPE_FAMILY_CAR)
            continue;

        if(!IsVehicleStreamedIn(vehicleid, playerid) && GetPlayerVehicleID(playerid) != vehicleid)
            continue;

        if(!Iter_Contains(streamed_players_in_veh[vehicleid], playerid))
            Iter_Add(streamed_players_in_veh[vehicleid], playerid);
        if(!Iter_Contains(vehicle_in_stream[playerid], vehicleid))
            Iter_Add(vehicle_in_stream[playerid], vehicleid);

        UpdateVehicleVisualForPlayer(playerid, vehicleid);
        PermanentTuning_ApplyVehicleForPlayer(playerid, vehicleid);
    }
    return 1;
}


// V16 tuning stream replay v2:
// The CRMP mobile client may finish creating/resetting the streamed vehicle a little
// after OnVehicleStreamIn. A full ApplyVehicleTuning contains REMOVE ALL, so delayed
// retries must be additive: once the client entity is stable we only put the saved
// components back, never clear them again.
stock ReplaySavedVehicleComponentsForPlayer(playerid, vehicleid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid)) return 0;

    new action_type = GetVehicleData(vehicleid, V_ACTION_TYPE);
    new index = GetVehicleData(vehicleid, V_ACTION_ID);

    if(action_type == VEHICLE_ACTION_TYPE_FAMILY_CAR)
    {
        if(index < 0 || index >= MAX_OWNABLE_CARS) return 0;
        FamilyCarApplyVehicleStoreComponents(vehicleid, GetCarFamily(index, CAR_F_database), playerid);

        new family_vinyl[32];
        ResolveFamilyCarVinylName(index, family_vinyl, sizeof family_vinyl, true);
        if(family_vinyl[0] != EOS) SetVehicleVinylForPlayer(playerid, vehicleid, family_vinyl);

        new nitro_component = GetNitroComponentByLevel(GetCarFamily(index, V_F_NITRO));
        if(nitro_component > 0) AddToVehicleComponentForPlayer(playerid, vehicleid, nitro_component);
        FT55_Apply(playerid, vehicleid);
        return 1;
    }

    if(action_type != VEHICLE_ACTION_TYPE_OWNABLE_CAR) return 0;
    if(index < 0 || index >= MAX_OWNABLE_CARS) return 0;

    // Re-sync the runtime visual cache from the authoritative loaded ownable-car row.
    SyncOwnableVehicleTuningData(vehicleid);
    Styling_ApplyWheels(playerid, vehicleid);

    PermanentTuning_ApplyComponentsForPlayer(playerid, vehicleid);
    ApplyOwnableVehicleNitro(playerid, vehicleid, vInfo[index][vNitro]);
    return 1;
}

stock QueueVehicleStreamTuningReplay(playerid, vehicleid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid)) return 0;

    new action_type = GetVehicleData(vehicleid, V_ACTION_TYPE);
    if(action_type != VEHICLE_ACTION_TYPE_OWNABLE_CAR && action_type != VEHICLE_ACTION_TYPE_FAMILY_CAR) return 0;

    new action_id = GetVehicleData(vehicleid, V_ACTION_ID);
    new identity;
    if(action_type == VEHICLE_ACTION_TYPE_OWNABLE_CAR)
    {
        if(action_id < 0 || action_id >= MAX_OWNABLE_CARS) return 0;
        identity = GetOwnableCarData(action_id, OC_SQL_ID);
    }
    else
    {
        if(action_id < 0 || action_id >= MAX_OWNABLE_CARS) return 0;
        identity = GetCarFamily(action_id, CAR_F_database);
    }

    // One early and one late retry cover entity creation on normal and slow mobile
    // clients. Further periodic RPC replays congest the reliable ordered channel
    // and can delay vehicle-enter/state traffic.
    SetTimerEx("Vehicle_StreamTuningReplay", 250, false, "ddddd", playerid, vehicleid, action_type, action_id, identity);
    SetTimerEx("Vehicle_StreamTuningReplay", 1100, false, "ddddd", playerid, vehicleid, action_type, action_id, identity);
    return 1;
}

forward Vehicle_StreamTuningReplay(playerid, vehicleid, action_type, action_id, identity);
public Vehicle_StreamTuningReplay(playerid, vehicleid, action_type, action_id, identity)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
    if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid)) return 0;
    if(GetVehicleData(vehicleid, V_ACTION_TYPE) != action_type || GetVehicleData(vehicleid, V_ACTION_ID) != action_id) return 0;
    if(!IsVehicleStreamedIn(vehicleid, playerid) && GetPlayerVehicleID(playerid) != vehicleid) return 0;

    if(action_type == VEHICLE_ACTION_TYPE_OWNABLE_CAR)
    {
        if(action_id < 0 || action_id >= MAX_OWNABLE_CARS || GetOwnableCarData(action_id, OC_SQL_ID) != identity) return 0;
    }
    else if(action_type == VEHICLE_ACTION_TYPE_FAMILY_CAR)
    {
        if(action_id < 0 || action_id >= MAX_OWNABLE_CARS || GetCarFamily(action_id, CAR_F_database) != identity) return 0;
    }
    else return 0;

    UpdateVehicleVisualForPlayer(playerid, vehicleid);
    PermanentTuning_ApplyVehicleForPlayer(playerid, vehicleid);
    return 1;
}

stock SendAutosalonPreviewColor(playerid, vehicleid, body_color, wheel_color)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid)) return 1;
    if(!(0 <= body_color < sizeof(VehicleColoursTableRGBA))) return 1;
    if(!(0 <= wheel_color < sizeof(VehicleColoursTableRGBA))) return 1;

    vInfo[vehicleid][vColorBody] = VehicleColoursTableRGBA[body_color];
    vInfo[vehicleid][vColorWheels] = VehicleColoursTableRGBA[wheel_color];
    SetVehicleColorForPlayer(playerid, vehicleid, RGBA_to_ARGB(vInfo[vehicleid][vColorBody]), RGBA_to_ARGB(vInfo[vehicleid][vColorWheels]));
    return 1;
}

forward AutosalonApplyPreviewColorDelayed(playerid, vehicleid, body_color, wheel_color);
public AutosalonApplyPreviewColorDelayed(playerid, vehicleid, body_color, wheel_color)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(GetPlayerData(playerid, P_BUY_CAR) != vehicleid) return 1;
    return SendAutosalonPreviewColor(playerid, vehicleid, body_color, wheel_color);
}

stock SyncAutosalonSelectedColors(playerid)
{
    new body_color = buy_car_select_color[playerid][0];
    new wheel_color = buy_car_select_color[playerid][1];

    if(!(0 <= body_color <= MAX_COLOR_ID)) body_color = GetPlayerData(playerid, P_AUTOSALON_COLOR1);
    if(!(0 <= wheel_color <= MAX_COLOR_ID)) wheel_color = GetPlayerData(playerid, P_AUTOSALON_COLOR2);
    if(!(0 <= body_color <= MAX_COLOR_ID)) body_color = 1;
    if(!(0 <= wheel_color <= MAX_COLOR_ID)) wheel_color = 1;

    buy_car_select_color[playerid][0] = body_color;
    buy_car_select_color[playerid][1] = wheel_color;
    SetPlayerData(playerid, P_AUTOSALON_COLOR1, body_color);
    SetPlayerData(playerid, P_AUTOSALON_COLOR2, wheel_color);
    return 1;
}

stock ApplyAutosalonPreviewColor(playerid)
{
	new vehicleid = GetPlayerData(playerid, P_BUY_CAR);
	if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid)) return 1;

    SyncAutosalonSelectedColors(playerid);
	new body_color = GetPlayerData(playerid, P_AUTOSALON_COLOR1);
	new wheel_color = GetPlayerData(playerid, P_AUTOSALON_COLOR2);

    SendAutosalonPreviewColor(playerid, vehicleid, body_color, wheel_color);
    SetTimerEx("AutosalonApplyPreviewColorDelayed", 80, false, "iiii", playerid, vehicleid, body_color, wheel_color);
    SetTimerEx("AutosalonApplyPreviewColorDelayed", 250, false, "iiii", playerid, vehicleid, body_color, wheel_color);
    SetTimerEx("AutosalonApplyPreviewColorDelayed", 600, false, "iiii", playerid, vehicleid, body_color, wheel_color);
	return 1;
}

stock GetAutosalonTestDrivePrice(playerid)
{
	new biz_id = GetPlayerInBiz(playerid);
	if(biz_id == -1) return 2500;

	switch(GetCarMarketIdByBizId(biz_id))
	{
		case MOTO_SALON_MARKET_ID: return 5000;
		case 2: return 15000;
		case 3: return 7500;
		case TRUCK_SALON_MARKET_ID: return 3500;
	}
	return 2500;
}

forward AutosalonTestDriveFinishMessage(playerid);
forward AutosalonTestDriveMonitor(playerid);

stock StopAutosalonTestDriveMonitor(playerid)
{
	new timerid = GetPVarInt(playerid, "autosalon_testdrive_timer");
	if(timerid)
	{
		KillTimer(timerid);
		DeletePVar(playerid, "autosalon_testdrive_timer");
	}
	return 1;
}

stock StartAutosalonTestDriveMonitor(playerid)
{
	StopAutosalonTestDriveMonitor(playerid);
	SetPVarInt(playerid, "autosalon_testdrive_timer", SetTimerEx("AutosalonTestDriveMonitor", 1000, false, "i", playerid));
	return 1;
}

public AutosalonTestDriveFinishMessage(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	ShowNotificationNew(playerid, 2, 6, 0, 0, "Мы очень надеемся, что нам удалось Вам определиться с выбором транспорта!", " ");
	return 1;
}

public AutosalonTestDriveMonitor(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	DeletePVar(playerid, "autosalon_testdrive_timer");

	if(!GetPVarInt(playerid, "autosalon_testdrive_active"))
		return 1;

	new vehicleid = GetPlayerData(playerid, P_BUY_CAR);
	if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid))
		return ReturnPlayerToAutosalonPreview(playerid, 1);

	new Float:x, Float:y, Float:z;
	if(IsPlayerInVehicle(playerid, vehicleid))
		GetVehiclePos(vehicleid, x, y, z);
	else
		GetPlayerPos(playerid, x, y, z);

	if(!IsPointInSphere(x, y, z, -1569.918945, 1620.401245, 36.440906, 350.0))
	{
		if(IsPlayerInVehicle(playerid, vehicleid))
			RemovePlayerFromVehicle(playerid);
		return ReturnPlayerToAutosalonPreview(playerid, 2);
	}

	return StartAutosalonTestDriveMonitor(playerid);
}

stock ReturnPlayerToAutosalonPreview(playerid, finish_reason = 1)
{
	new return_lock = GetPVarInt(playerid, "autosalon_preview_return_lock");
	if(return_lock > GetTickCount())
	{
		return 1;
	}
	SetPVarInt(playerid, "autosalon_preview_return_lock", GetTickCount() + 1500);

	new vehicleid = GetPlayerData(playerid, P_BUY_CAR);
	new biz_id = GetPlayerInBiz(playerid);
	if(biz_id == -1) return 1;

	new car_market_id = GetCarMarketIdByBizId(biz_id);
	if(car_market_id == -1) return 1;
	new select_car = buy_car_select_car[playerid];

	StopAutosalonTestDriveMonitor(playerid);
	DeletePVar(playerid, "autosalon_testdrive_active");
	DeletePVar(playerid, "autosalon_testdrive_price");

	if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid))
	{
		vehicleid = CreateVehicle
		(
			car_market_data[car_market_id][select_car][CM_MODELID],
			1149.8434, 226.0655, 995.1953, 67.6542,
			1,
			1,
			1
		);
		SetPlayerData(playerid, P_BUY_CAR, vehicleid);
		SetVehicleNumberPlateEx(vehicleid, TYPE_RU, "", "");
	}

	ApplyCarMarketPreviewScene(playerid, vehicleid, car_market_id);
	ApplyAutosalonPreviewColor(playerid);

	CreateAutosalonTextDraws(playerid);
	HideHud(playerid);
	SelectTextDraw(playerid, 0xFFFFFFFF);
	RefreshAutosalonChat(playerid);

	switch(finish_reason)
	{
		case 1:
		{
			ShowNotificationNew(playerid, 2, 6, 0, 0, "Вы покинули транспортное средство, тест-драйв был закончен.", " ");
			SetTimerEx("AutosalonTestDriveFinishMessage", 1500, false, "i", playerid);
		}
		case 2:
		{
			ShowNotificationNew(playerid, 2, 6, 0, 0, "Вы покинули поле для тест-драйва, он был закончен.", " ");
			SetTimerEx("AutosalonTestDriveFinishMessage", 1500, false, "i", playerid);
		}
	}
	return 1;
}

stock StartAutosalonTestDrive(playerid)
{
	new vehicleid = GetPlayerData(playerid, P_BUY_CAR);
	if(vehicleid == INVALID_VEHICLE_ID) return 1;
	DeletePVar(playerid, "autosalon_preview_return_lock");

	new price = GetAutosalonTestDrivePrice(playerid);
	if(GetPlayerMoneyEx(playerid) < price)
	{
		ShowNotificationNew(playerid, 2, 6, 0, 0, "Недостаточно средств для оплаты тест-драйва", " ");
		return 1;
	}

	GivePlayerMoneyEx(playerid, -price, "Тест-драйв", true, true);

	new spend_str[64];
	format(spend_str, sizeof spend_str, "Вы потратили %d рублей", price);
	ShowNotificationNew(playerid, 2, 6, 0, 0, spend_str, " ");

	HideAutosalonTextDraws(playerid);
	ShowHud(playerid);

	SetPVarInt(playerid, "autosalon_testdrive_active", 1);
	SetPVarInt(playerid, "autosalon_testdrive_price", price);
	BlackPass_OnTestDriveStarted(playerid);

	TogglePlayerControllable(playerid, true);
	SetPlayerCleanChat(playerid, 0);
	SetPlayerVirtualWorld(playerid, playerid + 5000);
	SetPlayerInterior(playerid, 0);
	SetPlayerPosEx(playerid, -1569.918945, 1620.401245, 36.440906, 178.751403, 0, playerid + 5000, false);

	SetVehiclePos(vehicleid, -1569.918945, 1620.401245, 36.440906);
	SetVehicleZAngle(vehicleid, 178.751403);
	SetVehicleVirtualWorld(vehicleid, playerid + 5000);
	LinkVehicleToInterior(vehicleid, 0);
	SetVehicleNumberPlateEx(vehicleid, TYPE_RU, "", "");
	ApplyAutosalonPreviewColor(playerid);
	PutPlayerInVehicle(playerid, vehicleid, 0);

	SetVehicleParamsEx(vehicleid, VEHICLE_PARAM_OFF, VEHICLE_PARAM_OFF, VEHICLE_PARAM_OFF, VEHICLE_PARAM_OFF, VEHICLE_PARAM_OFF, VEHICLE_PARAM_OFF, VEHICLE_PARAM_OFF);
	ShowNotificationNew(playerid, 4, 6, 0, 0, "Двигатель автомобиля выключен.", " ");
	StartAutosalonTestDriveMonitor(playerid);
	return 1;
}
public: ChangeColorPTDUpdate(playerid)
{
	return 1;
}
#define MAX_TUNE_ITEM_ID 2507

static const ItemTuneId[MAX_TUNE_ITEM_ID+1] =
{
    1008,1009,1010,3,0,1,2,3,8,0,1,2,3,13,0,1,2,3,18,0,
    1,2,3,23,0,1,2,3,0,1,2,3,4,0,0,36,1908,1909,1910,1911,
    1912,1913,1914,1915,1916,1917,1918,1919,1920,1921,1922,1923,1924,1925,1926,1927,1928,1929,1930,1931,
    1932,1933,1934,1935,1936,1937,1938,1939,1940,1941,1942,1943,1944,1945,1946,1947,1948,1949,1950,1951,
    1952,1953,1954,1955,1956,1957,1958,1959,1960,1961,1962,1963,1964,0,1,2,3,4,5,14,
    15,16,17,18,19,23,29,30,31,32,33,34,24,25,41,42,43,44,20,21,
    22,26,27,28,35,36,37,38,39,40,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,384,
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,
    20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,
    40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,
    60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,
    80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,
    100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,
    120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,
    140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,
    160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,
    180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,
    200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,
    220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,
    240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,
    260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,
    280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,296,297,298,299,
    300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,
    320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,338,339,
    340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,358,359,
    360,361,362,363,364,365,366,367,368,369,370,371,372,373,374,375,376,377,378,379,
    380,381,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,399,
    400,401,402,403,404,405,406,407,408,409,410,411,412,413,414,415,416,417,418,419,
    420,421,422,423,424,425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,
    440,441,442,443,444,445,446,447,448,449,450,451,452,453,454,455,456,457,458,459,
    460,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,477,478,479,
    480,481,482,483,484,485,486,487,488,489,490,491,492,493,494,495,496,497,498,499,
    500,501,502,503,504,505,506,507,508,509,510,511,512,513,514,515,516,517,518,519,
    520,521,522,523,524,525,526,527,528,529,530,531,532,533,534,535,536,537,538,539,
    540,541,542,543,544,545,548,549,550,551,552,553,554,555,556,557,558,559,560,561,
    562,563,564,565,566,567,568,569,570,571,572,573,574,575,576,577,578,579,580,581,
    582,583,584,585,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,607,
    608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,
    628,629,630,631,632,633,634,635,636,637,638,639,640,641,642,643,644,645,646,647,
    648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,
    668,669,670,671,672,673,674,675,676,677,678,679,680,681,682,683,684,685,686,687,
    688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,703,704,705,706,707,
    708,709,710,711,712,713,714,715,716,717,718,719,720,721,722,723,724,725,726,727,
    728,729,730,731,732,733,734,735,736,737,738,739,740,741,742,0,0,0,0,0,
    0,0,0,0,0,751,754,752,753,755,756,757,758,759,760,761,762,763,764,765,
    766,767,768,769,770,771,772,773,774,775,776,777,778,779,780,781,782,783,784,785,
    786,787,788,789,790,791,792,793,794,795,796,797,798,799,800,801,802,803,804,805,
    806,807,808,809,810,811,812,813,814,815,816,817,821,818,819,820,822,823,824,825,
    826,827,828,829,830,831,832,833,834,835,837,836,838,841,842,843,844,845,846,847,
    848,861,862,863,864,865,866,867,868,869,870,871,872,873,874,875,876,877,878,849,
    850,851,852,853,854,879,880,881,882,855,856,857,858,859,860,886,887,888,889,890,
    891,883,884,885,892,893,894,895,905,896,897,898,899,900,901,902,903,904,910,911,
    912,913,914,915,916,917,906,907,908,909,918,963,964,965,966,967,968,969,970,971,
    972,973,974,975,927,928,929,930,931,985,0,955,956,957,986,987,988,989,990,991,
    992,993,994,919,920,921,922,923,924,925,926,937,938,939,940,941,942,943,944,945,
    946,947,948,949,950,951,952,953,0,959,960,961,962,995,996,997,998,977,978,979,
    980,981,982,983,984,932,933,934,935,936,958,1007,1008,999,1000,1001,1002,1003,1004,1005,
    1006,1062,1063,1064,1065,1066,1067,1068,1069,1070,1014,1015,1016,1017,1018,1019,1020,1021,1022,1023,
    1024,976,1026,1027,1029,1028,1030,1049,1050,1051,1052,1053,1054,1055,1056,1057,1058,1059,1060,1061,
    1130,1131,1132,1133,1134,1135,1136,1137,1138,1139,1140,1141,1031,1032,1033,1034,1035,1036,1037,1038,
    1039,1040,1041,1142,1143,1144,1145,1146,1147,1148,1149,1150,1151,1152,1153,1154,1155,1156,1157,1158,
    1009,1010,1011,1012,1013,1042,1043,1044,1045,1046,1047,1048,1159,1160,1161,1162,1163,1164,1165,1166,
    1167,1168,1071,1072,1086,1087,1110,1088,1089,1111,1112,1113,1114,1115,1116,1101,1102,1103,1104,1105,
    1171,1106,1107,1108,1172,1173,1174,1175,1176,1177,1178,1179,1180,1090,1091,1092,1093,1094,1095,1099,
    1100,1109,1117,1118,1119,1120,1121,1122,1181,1182,1183,1184,1190,1185,1186,1187,1188,1189,0,1278,
    1279,1280,1281,1282,1283,1284,1285,1286,1287,1288,1263,1264,1265,1266,1267,1268,1269,1270,1299,1300,
    1301,1302,1303,1304,1305,0,1307,1289,1290,1291,1292,1293,1294,1295,1296,1297,1298,1271,1272,1273,
    1274,1275,1276,1277,1308,1309,1310,1311,1312,1313,1314,1324,1325,1326,1327,1329,1330,1332,1333,1335,
    1337,1339,1341,1315,1316,1317,1318,1319,1320,1321,1342,1343,1344,1345,1346,1347,1348,1349,1350,1351,
    1352,1353,1354,1355,1356,1357,1358,1359,1360,1257,1258,1259,1260,1261,1262,1250,1251,1252,1253,1254,
    1255,1256,1209,1210,1211,1212,1213,1214,1215,1216,1217,1218,1219,1220,1221,1222,1223,1224,1225,1226,
    1227,1228,1229,1230,1231,1232,1233,1234,1235,1236,1237,1238,1239,1198,1199,1200,1201,1202,1203,1204,
    1205,1206,1393,1394,1395,1396,1397,1398,1123,1124,1125,1126,1127,1128,1129,1384,1385,1386,1387,1388,
    1389,1390,1391,1392,1362,1363,1364,1365,1366,1367,1368,1369,1370,1371,1420,1421,1422,1423,1424,1425,
    1426,1427,1428,1429,1430,1431,1432,1433,1434,1435,1436,1437,1438,1439,1440,1441,1442,1378,1379,1380,
    1381,1382,1240,1241,1242,1243,1244,1245,1246,1247,1248,1249,1383,1372,1373,1374,1375,1376,1377,1408,
    1409,1410,1472,1448,1449,1450,1451,1452,1453,1454,1455,1456,1457,1458,1459,1460,1461,1462,1463,1464,
    1411,1412,1413,1414,1415,1416,1417,1418,1419,1465,1466,1467,1468,1469,1470,1471,1443,1444,1445,1446,
    1447,1399,1400,1401,1402,1405,1406,1403,1404,1323,1407,1473,1474,1475,1476,1477,1478,1479,1480,1481,
    1482,1483,1484,1485,1486,1487,1488,1489,1490,1491,1492,1493,1494,1495,1496,1497,1498,1499,1514,1515,
    1516,1517,1518,1519,1520,1521,1522,1523,1524,1525,1500,1501,1502,1503,1504,1505,1506,1507,1526,1527,
    1528,1529,1530,1531,1532,1533,1534,1535,1536,1537,1538,1539,1508,1509,1510,1511,1512,1513,1540,1541,
    1542,1543,1544,1545,1546,1547,1548,1549,1550,1551,1552,1553,1568,1569,1570,1571,1572,1573,1574,1575,
    1576,1577,1578,1579,1580,1556,1557,1558,1559,1560,1561,1562,1563,1564,1565,1566,1567,1581,1582,1583,
    1584,1585,1586,1587,1588,1594,1595,1596,1597,1598,1599,1589,1590,1591,1592,1593,1600,1647,1648,1649,
    1650,1651,1652,1653,1654,1655,1620,1621,1622,1623,1624,1625,1626,1627,1628,1629,1608,1609,1610,1611,
    1612,1613,1614,1615,1616,1617,1618,1619,1639,1640,1641,1642,1643,1644,1645,1646,1630,1631,1632,1633,
    1634,1635,1636,1637,1638,1601,1602,1603,1604,1605,1606,1607,1656,1657,1658,1659,1660,1661,1662,1663,
    1664,1665,1667,1668,1669,1670,1671,1672,1673,1674,1684,1685,1686,1687,1688,1689,1690,1691,1692,1675,
    1676,1677,1678,1679,1680,1681,1682,1683,1693,1694,1695,1696,1697,1698,1699,1700,1701,1702,1703,1704,
    1705,1706,1707,1708,1721,1722,1723,1724,1725,1726,1727,1728,1729,1730,1666,1713,1714,1715,1716,1717,
    1718,1719,1720,1747,1748,1749,839,1750,1751,1752,1753,1754,1709,1710,1711,1712,1755,1756,1757,1758,
    1759,1760,1761,1762,1763,1764,1765,840,1739,1740,1741,1742,1743,1744,1745,1746,1731,1732,1733,1734,
    1735,1736,1737,1738,1766,1767,1768,1769,1770,1771,1772,1773,1774,1775,1776,1777,1778,1779,1780,1781,
    1782,1783,1784,1785,1786,1787,1788,1798,1799,1800,1801,1802,1803,1804,1805,1806,1789,1790,1791,1792,
    1793,1794,1795,1796,1797,1808,1809,1810,1811,1812,1813,1814,1815,1816,1817,1818,1819,1820,1807,1832,
    1833,1834,1835,1836,1837,1838,1839,1840,1841,1842,1843,1844,1845,1846,1847,1848,1849,1850,1851,1852,
    1853,1863,1864,1865,1866,1867,1854,1855,1868,1869,1870,1871,1872,1873,1874,1875,1876,1877,1878,1879,
    1880,1881,1883,1884,1885,1886,1887,1888,1889,1821,1822,1823,1824,1825,1826,1827,1828,1829,1830,1831,
    1897,1890,1891,1892,1893,1894,1895,1896,1856,1857,1858,1859,1860,1861,1862,1898,1899,1900,1901,1902,
    1903,1904,1905,1906,1965,1966,1967,1968,1969,1979,1980,1981,1982,1983,1984,1985,1986,1994,1970,1971,
    1972,1973,1974,1975,1976,1977,1978,1987,1988,1989,1990,1991,1992,1993,1995,1996,2002,1997,1998,1999,
    2000,2001,2064,2065,2066,2067,2068,2069,2070,2071,2072,2023,2024,2025,2026,2027,2028,2029,2079,2080,
    2081,2082,2083,2084,2047,2048,2049,2050,2051,2052,2053,2054,2055,2003,2004,2005,2006,2007,2008,2009,
    2010,2073,2074,2060,2076,2077,2078,2098,2099,2100,2101,2102,2103,2104,2105,2106,2107,2056,2057,2058,
    2059,2060,2061,2062,2063,2089,2090,2091,2092,2093,2094,2095,2096,2097,2030,2031,2032,2033,0,2035,
    2036,2037,2114,2115,2116,2117,2118,2119,2120,2121,2122,2011,2012,2013,2014,2015,2016,2017,2018,2019,
    2020,2021,0,0,0,0,0,0,0,2085,2086,2087,2088,2108,2038,2039,2040,2123,2041,2042,
    2109,2043,2044,2045,2110,2111,2046,2112,2113,2124,2125,2126,2127,2128,2129,2130,2131,2157,2158,2159,
    2160,2161,2162,2163,2164,2187,2188,2189,2190,2191,2192,2193,2194,2195,2196,2197,2151,2152,2153,2154,
    2155,2156,2165,2166,2167,2168,2169,2170,2171,2172,2173,2174,2175,2176,2177,2178,2179,2180,2181,2182,
    2184,2185,2186,2183,2132,2133,2134,2135,2136,2137,2138,2139,2140,2141,2142,2143,2144,2145,2146,2147,
    2148,2149,2150,2198,2199,2200,2201,2202,3151,3152,3155,3156,3157,2208,2238,2239,2240,2241,2242,2243,
    2244,2245,2275,2276,2277,2278,2279,2280,2281,2282,2283,2284,2285,2229,2230,2231,2232,2233,2234,2235,
    2236,2237,2246,2247,2248,2249,2250,2251,2252,2253,2254,2255,2256,2215,2216,2217,2218,2219,2220,2221,
    2257,2258,2259,2260,2261,2262,2213,2214,2263,2264,2265,2266,2267,2268,2269,2270,2271,2272,2273,2274,
    2286,2287,2288,2289,2290,2291,2292,2293,2294,2295,2296,2297,2298,2222,2223,2224,2225,2226,2227,2228,
    2315,2308,2309,2310,2311,2312,2313,2314
};

static const ItemTuneSelector[MAX_TUNE_ITEM_ID+1] =
{
    42,42,42,36,36,36,36,36,37,37,37,37,37,38,38,38,38,38,39,39,39,39,39,40,
    40,40,40,40,14,14,14,14,14,34,35,41,31,31,31,31,31,31,31,31,31,31,31,31,
    31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,
    31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,31,9,9,9,
    9,9,9,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
    7,7,7,7,7,7,7,7,7,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,48,17,17,17,17,17,17,16,16,16,19,19,19,
    43,21,45,17,17,17,17,17,17,16,16,43,18,17,17,17,17,17,17,16,16,16,18,18,
    19,46,17,17,17,17,17,17,17,17,16,16,16,47,47,19,19,43,43,43,18,18,45,45,
    20,20,20,20,20,20,17,17,17,17,17,17,20,20,20,20,20,43,43,19,19,16,16,16,
    47,47,47,18,18,18,17,17,17,17,17,17,43,43,43,16,16,16,16,18,18,18,19,19,
    19,17,17,17,17,16,21,18,18,19,19,17,17,20,17,17,16,16,16,21,19,19,17,17,
    17,17,20,20,16,16,19,19,21,17,17,17,17,16,16,18,18,19,19,19,20,20,20,20,
    17,17,16,16,21,18,19,19,17,17,20,20,16,16,18,19,19,17,17,20,20,17,20,20,
    16,16,18,18,47,17,17,17,17,16,16,19,19,17,17,17,17,16,16,21,18,18,19,19,
    17,17,20,20,17,17,16,16,21,21,18,18,19,19,47,47,17,17,17,17,16,16,21,21,
    18,17,17,17,17,16,16,16,21,18,18,19,19,17,17,17,17,17,17,17,17,20,16,16,
    16,16,16,16,16,18,18,18,19,19,17,17,16,21,18,19,17,17,18,17,17,17,17,18,
    19,19,17,20,16,16,19,19,43,43,43,19,19,19,17,17,17,20,20,20,17,17,17,16,
    16,16,46,47,47,18,18,45,45,45,45,45,45,43,43,19,19,19,17,17,17,20,20,20,
    17,17,17,16,16,16,47,47,47,45,45,45,45,45,45,-1,-1,-1,-1,17,17,17,17,16,
    16,19,19,18,18,17,17,17,17,16,16,16,18,18,19,20,20,20,17,19,19,17,17,17,
    17,16,16,47,47,18,18,16,47,47,19,19,17,17,17,17,17,17,43,18,18,18,19,19,
    19,17,17,17,17,17,17,18,18,18,45,45,45,45,17,17,17,17,17,17,16,16,16,16,
    21,18,18,18,19,19,19,17,17,17,17,17,17,16,16,16,18,18,18,19,19,19,21,46,
    17,17,17,20,20,17,17,17,16,18,18,18,19,19,19,17,17,17,17,17,17,16,16,16,
    18,18,18,19,19,19,17,17,17,17,17,17,16,16,16,18,18,18,19,19,19,17,17,17,
    17,17,17,16,16,16,18,18,18,19,19,19,17,17,17,17,17,17,43,43,43,16,16,21,
    18,18,18,19,19,19,46,46,46,47,47,47,17,17,20,20,20,17,17,18,18,18,45,45,
    47,47,47,-1,-1,21,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,17,17,43,16,
    21,19,46,47,16,21,17,17,21,16,47,17,17,17,17,17,17,43,43,43,16,16,16,21,
    18,18,18,45,45,47,-1,-1,17,20,20,20,20,43,16,16,18,18,45,45,17,17,17,17,
    43,43,16,16,18,18,19,19,45,45,17,17,43,16,18,45,45,17,17,17,17,43,43,16,
    16,21,21,18,18,19,19,46,46,20,43,44,16,21,17,17,43,16,21,18,19,17,20,17,
    20,43,44,16,16,16,21,18,19,45,45,17,20,17,20,43,44,16,21,18,19,45,45,17,
    20,17,43,44,16,21,19,45,17,17,43,44,16,21,18,19,0,0,0,17,17,43,16,21,
    18,45,45,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,17,
    17,43,44,16,19,44,16,18,19,20,20,17,17,43,16,16,21,18,19,45,45,17,17,43,
    16,18,19,17,17,43,16,18,19,47,17,0,17,0,43,0,16,0,18,0,19,0,45,45,
    43,19,20,16,21,21,46,47,21,21,21,21,17,17,17,17,20,20,43,43,16,16,18,18,
    45,45,16,21,21,21,0,0,0,0,0,0,0,19,17,46,45,45,17,16,18,17,20,17,
    17,43,16,16,18,18,19,20,21,45,47,46,21,16,16,16,21,16,16,18,46,21,21,16,
    17,43,16,16,21,17,17,21,16,21,21,18,16,17,20,17,20,43,16,18,19,46,17,17,
    43,16,18,19,45,45,17,17,43,16,19,0,0,0,0,0,0,0,0,0,0,0,0,0,
    20,43,16,21,45,16,0,17,43,19,17,17,17,16,21,21,45,45,47,17,44,16,16,21,
    18,45,45,17,20,17,20,43,44,16,21,18,45,45,45,45,46,47,0,0,0,17,17,16,
    21,17,16,16,18,17,43,16,16,16,16,21,18,17,17,16,21,21,21,17,43,17,17,43,
    43,16,21,19,46,0,0,0,0,0,0,0,0,0,17,20,17,43,44,16,21,18,18,45,
    45,46,47,-1,-1,-1,-1,17,17,17,43,16,16,16,18,19,45,45,46,46,17,17,17,17,
    43,16,16,21,18,18,45,47,17,17,43,16,16,21,21,18,18,19,47,17,17,20,17,43,
    43,16,21,18,45,45,46,46,47,47,-1,-1,17,16,21,18,46,20,20,20,43,16,16,46,
    17,17,20,16,16,16,16,18,18,46,43,44,16,21,19,45,45,45,45,46,47,-1,-1,17,
    17,43,44,16,16,18,45,46,17,17,43,16,16,19,45,45,47,17,17,43,44,16,21,19,
    46,17,17,43,16,18,19,47,17,17,43,16,47,18,45,45,46,20,0,17,17,20,17,43,
    16,16,21,18,0,46,17,20,43,21,21,18,19,46,17,17,20,17,43,43,44,0,18,17,
    17,20,43,16,16,21,21,18,45,17,17,17,43,16,16,45,17,20,16,21,18,19,46,17,
    43,19,0,0,0,0,0,0,0,0,0,20,17,43,44,21,19,46,0,0,0,0,0,0,
    0,0,17,20,20,17,17,43,43,20,16,18,45,17,17,16,21,46,47,17,20,17,43,16,
    16,18,17,17,20,20,20,17,17,17,43,43,43,16,16,16,21,21,18,18,19,19,19,45,
    45,45,45,46,46,46,47,47,47,17,17,43,16,18,45,45,46,46,17,17,43,16,18,19,
    17,17,43,19,45,45,46,17,20,17,43,16,21,18,46,47,0,0,0,0,0,0,0,0,
    0,0,17,17,0,17,17,0,20,20,43,43,0,44,44,44,16,16,18,18,18,19,19,19,
    45,17,20,16,16,18,17,17,43,21,21,18,19,45,45,0,0,17,20,44,21,18,46,20,
    20,43,16,17,17,20,17,17,20,43,21,21,46,17,17,17,17,20,16,18,17,17,20,17,
    43,16,21,18,19,17,17,19,43,21,21,18,17,17,43,16,46,17,17,43,43,16,16,21,
    18,0,0,17,20,17,16,21,18,0,0,0,0,0,0,0,17,17,17,17,43,16,18,45,
    46,20,20,16,45,0,17,17,20,43,43,16,21,18,19,45,-1,-1,17,17,21,21,18,19,
    45,45,17,17,20,20,20,43,43,16,21,18,45,45,-1,-1,17,17,20,44,19,19,17,17,
    17,43,16,21,18,18,45,47,-1,-1,21,45,17,17,20,20,17,43,43,16,21,19,46,-1,
    -1,17,17,17,43,16,21,18,18,45,45,-1,-1,17,17,20,43,43,16,18,19,17,17,43,
    16,16,18,17,17,43,16,18,19,17,17,19,43,16,16,18,45,45,17,17,20,17,17,16,
    16,18,45,45,17,17,17,43,16,16,18,45,45,46,-1,-1,17,17,43,43,16,16,16,18,
    17,20,20,17,43,43,16,21,45,17,17,43,16,16,45,45,17,43,16,16,16,21,18,45,
    45,46,17,17,20,43,16,18,49,49,17,17,19,16,16,18,18,45,45,17,17,17,43,16,
    16,16,18,45,45,-1,-1,17,17,20,17,16,16,18,19,45,45,47,-1,-1,17,17,20,20,
    43,43,44,21,18,47,47,17,17,17,20,16,16,18,19,17,20,21,20,17,17,17,43,18,
    17,19,19,43,17,17,17,17,43,43,16,16,16,18,45,43,17,17,17,17,43,16,18,45,
    17,43,43,16,16,21,18,19,17,17,43,16,18,47,17,17,17,43,16,16,21,18,-1,-1,
    17,17,17,43,43,21,18,17,17,17,17,16,21,18,19,19,17,17,17,43,16,16,21,18,
    47,17,17,17,16,16,18,17,17,16,16,21,21,18,20,20,20,17,43,16,16,18,43,43,
    16,16,18,19,45,17,20,43,44,44,21,19,19,46,20,20,16,18,17,16,17,17,43,18,
    17,16,18,-1,-1,17,17,16,16,18,17,17,20,43,44,44,19,17,17,43,16,16,16,21,
    18,19,19,45,47,17,17,17,44,21,21,18,17,17,17,43,16,16,18,17,17,17,43,43,
    16,16,18,18,17,17,43,16,18,17,17,17,43,16,16,21,18,16,17,17,43,16,16,21,
    18,45,45,17,43,44,21,21,19,45,17,17,20,17,17,16,21,18,17,17,20,20,16,16,
    21,21,18,17,17,20,43,16,21,18,20,43,16,45,-1,-1,17,17,43,16,16,21,18,45,
    45,17,17,20,17,21,21,18,46,20,17,17,43,43,46,17,17,17,43,16,16,21,18,-1,
    -1,17,17,17,43,16,16,18,45,17,17,17,43,16,16,18,-1,-1,20,20,43,44,0,21,
    21,18,17,43,16,21,47,17,17,18,16,17,17,17,43,16,16,21,18,45,45,46,0,0,
    0,0,0,0,0,17,20,43,21,17,17,17,20,43,44,21,21,21,21,18,45,45,47,-1,
    -1,17,17,44,21,19,46,46,44,17,17,17,43,44,16,16,18,17,17,17,17,43,16,16,
    18,45,45,46,17,17,43,43,19,19,17,17,17,43,16,16,21,18,45,46,47,-1,-1,17,
    17,17,43,16,16,21,46,47,17,17,17,17,16,16,18,45,17,17,20,17,43,43,44,44,
    21,18,45,17,17,44,21,18,31,31,31,31,31,45,17,17,17,44,44,21,18,19,17,17,
    17,17,16,16,18,45,45,46,46,17,17,17,43,43,16,16,18,45,17,17,20,17,16,16,
    18,45,45,-1,-1,17,17,17,43,16,16,18,17,17,17,16,19,46,17,16,17,17,17,17,
    43,16,16,18,45,45,-1,-1,17,17,17,17,43,16,16,16,18,45,45,-1,-1,17,17,17,
    43,43,16,18,21,17,17,43,16,18,45,45
};

stock GetTuneSelectorFromItem(itemid)
{
    if(itemid < 0 || itemid > MAX_TUNE_ITEM_ID) return 0;
    return ItemTuneSelector[itemid];
}

stock GetTuneIdFromItem(id)
{
    if(id < 0 || id > MAX_TUNE_ITEM_ID) return 0;
    return ItemTuneId[id];
}

stock GetWheelTuneComponentId(itemid)
{
    if(itemid < 36 || itemid > 92) return 0;

    new componentid = GetTuneIdFromItem(itemid);
    if(componentid <= 0 && itemid > 35 && itemid < 93)
    {
        componentid = itemid + 1872;
    }
    if(componentid < 1908 || componentid > 1964) return 0;
    return componentid;
}

stock GetNitroComponentByLevel(level)
{
    switch(level)
    {
        case 1: return 1009;
        case 2: return 1008;
        case 3: return 1010;
    }
    return 0;
}

stock ApplyOwnableVehicleNitro(playerid, vehicleid, level)
{
    if(vehicleid == 0 || vehicleid == INVALID_VEHICLE_ID) return 0;

    RemoveVehicleComponent(vehicleid, 1008);
    RemoveVehicleComponent(vehicleid, 1009);
    RemoveVehicleComponent(vehicleid, 1010);

    new componentid = GetNitroComponentByLevel(level);
    if(componentid == 0) return 1;

    // The mobile client applies nitro through its firmware RPC. Using the
    // standard GTA tuning component on custom vehicle models makes the client
    // render an unrelated oversized object on the car body.
    SendCarFirmware(playerid, componentid);
    return 1;
}

stock ApplyOwnableVehicleColors(vehicleid, index)
{
    if(vehicleid == 0 || vehicleid == INVALID_VEHICLE_ID || index < 0 || index >= sizeof(vInfo)) return 0;

    // Zero means "no custom ARGB color" in the database, but sending literal
    // 0x00000000 leaves black cars without an initialized custom material.
    // Fall back to the opaque native vehicle colors so vinyl remains visible.
    new body_color = vInfo[index][body_colors];
    new wheel_color = vInfo[index][wheel_colors];
    if(body_color == 0)
        body_color = RGBA_to_ARGB(GetVehicleRGBAColorById(GetOwnableCarData(index, OC_COLOR_1)));
    if(wheel_color == 0)
        wheel_color = RGBA_to_ARGB(GetVehicleRGBAColorById(GetOwnableCarData(index, OC_COLOR_2)));

    foreach(new targetid: Player)
    {
        if(!IsVehicleStreamedIn(vehicleid, targetid) && GetPlayerVehicleID(targetid) != vehicleid) continue;

        SetVehicleColorHexForPlayers(targetid, vehicleid, body_color, wheel_color);
        SetVehicleColorTonrrHexForPlayers(targetid, vehicleid, vInfo[index][tonir_ft], vInfo[index][tonir_rr]);
        if(vInfo[index][lights_color] != 0)
        {
            ddSetVehicleColorHexForPlayers(targetid, vehicleid, vInfo[index][lights_color]);
        }
        if(vInfo[index][vEnableNeon])
        {
            SetVehicleNeonForPlayer(targetid, vehicleid,
                vInfo[index][underlights_color],
                vInfo[index][underlights_color_lf],
                vInfo[index][underlights_color_rt]);
        }
    }
    return 1;
}

forward ReapplyPurchasedVehicleTuning(playerid, vehicleid);
public ReapplyPurchasedVehicleTuning(playerid, vehicleid)
{
    if(!IsPlayerConnected(playerid) || !Styling_CanEdit(playerid, vehicleid) ||
       !Styling_SyncVisualCache(vehicleid)) return 0;

    new index = GetVehicleData(vehicleid, V_ACTION_ID);
    if(index < 0 || index >= sizeof(vInfo)) return 0;

    ApplyOwnableVehicleColors(vehicleid, index);

    foreach(new targetid: Player)
    {
        if(!IsVehicleStreamedIn(vehicleid, targetid) && GetPlayerVehicleID(targetid) != vehicleid) continue;

        // The wheel/styling RPC can rebuild the client-side vehicle materials.
        // Apply the saved vinyl LAST so it cannot be wiped by that rebuild.
        Styling_ApplyWheels(targetid, vehicleid);
        if(g_ownable_car[index][OC_VINYL][0] != EOS)
        {
            SetVehicleVinylForPlayer(targetid, vehicleid, g_ownable_car[index][OC_VINYL]);
        }
    }

    if(GetPlayerVehicleID(playerid) == vehicleid)
    {
        ApplyOwnableVehicleNitro(playerid, vehicleid, vInfo[index][vNitro]);
    }
    return 1;
}

