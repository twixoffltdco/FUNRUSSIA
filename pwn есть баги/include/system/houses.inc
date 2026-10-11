stock UpdateHouse(houseid)
{
	if(GetHouseData(houseid, H_ENTRACE) == -1)
	{
		if(GetHouseData(houseid, H_ENTER_PICKUP))
			DestroyPickup(GetHouseData(houseid, H_ENTER_PICKUP));

		if(IsValidDynamicMapIcon(GetHouseData(houseid, H_MAP_ICON)))
			DestroyDynamicMapIcon(GetHouseData(houseid, H_MAP_ICON));

		SetHouseData(houseid, H_ENTER_PICKUP, CreatePickup((IsHouseOwned(houseid) ? 1272 : 1273), 23, GetHouseData(houseid, H_POS_X), GetHouseData(houseid, H_POS_Y), GetHouseData(houseid, H_POS_Z), 0, PICKUP_ACTION_TYPE_HOUSE, houseid));
		SetHouseData(houseid, H_MAP_ICON, CreateDynamicMapIcon(GetHouseData(houseid, H_POS_X), GetHouseData(houseid, H_POS_Y), GetHouseData(houseid, H_POS_Z), (IsHouseOwned(houseid) ? 32 : 31), 0, 0, 0, -1, STREAMER_MAP_ICON_SD, MAPICON_LOCAL));
	}
}

stock HouseHealthInit(houseid, type = -1)
{
	if(GetHouseData(houseid, H_IMPROVEMENTS) >= 2)
	{
		if(!GetHouseData(houseid, H_HEALTH_PICKUP))
		{
			type = GetHouseData(houseid, H_TYPE);
			SetHouseData(houseid, H_HEALTH_PICKUP, CreatePickup(1240, 23, GetHouseTypeInfo(type, HT_HEALTH_POS_X), GetHouseTypeInfo(type, HT_HEALTH_POS_Y), GetHouseTypeInfo(type, HT_HEALTH_POS_Z), houseid + 2000, PICKUP_ACTION_TYPE_HOUSE_HEALTH, houseid));
		}
	}
					else
	{
		if(GetHouseData(houseid, H_HEALTH_PICKUP))
		{
			DestroyPickup(GetHouseData(houseid, H_HEALTH_PICKUP));
			SetHouseData(houseid, H_HEALTH_PICKUP, 0);
		}
	}
}

stock HouseStoreInit(houseid, type = -1)
{
	if(GetHouseData(houseid, H_IMPROVEMENTS) >= 5)
	{
		if(GetHouseData(houseid, H_STORE_LABEL) == Text3D:-1)
		{
			if(GetHouseData(houseid, H_STORE_X) == 0.0 && GetHouseData(houseid, H_STORE_Y) == 0.0 && GetHouseData(houseid, H_STORE_Z) == 0.0)
			{
				type = GetHouseData(houseid, H_TYPE);

				SetHouseData(houseid, H_STORE_X, GetHouseTypeInfo(type, HT_STORE_POS_X));
				SetHouseData(houseid, H_STORE_Y, GetHouseTypeInfo(type, HT_STORE_POS_Y));
				SetHouseData(houseid, H_STORE_Z, GetHouseTypeInfo(type, HT_STORE_POS_Z));
			}
			SetHouseData(houseid, H_STORE_LABEL, CreateDynamic3DTextLabel("Шкаф", 0xFFFF00FF, GetHouseData(houseid, H_STORE_X), GetHouseData(houseid, H_STORE_Y), GetHouseData(houseid, H_STORE_Z) + 0.5, 6.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, houseid + 2000, -1, -1, 50.0));

			CallLocalFunction("UpdateHouseStore", "i", houseid);
		}
	}
					else
	{
		if(GetHouseData(houseid, H_STORE_LABEL) != Text3D:-1)
		{
			if(IsValidDynamic3DTextLabel(GetHouseData(houseid, H_STORE_LABEL)))
			{
				DestroyDynamic3DTextLabel(GetHouseData(houseid, H_STORE_LABEL));
				SetHouseData(houseid, H_STORE_LABEL, Text3D:-1);
			}
		}
	}
}

stock SellHouse(playerid, to_player = INVALID_PLAYER_ID, price = 0)
{
	new houseid = GetPlayerHouse(playerid, HOUSE_TYPE_HOME);
	if(houseid != -1)
	{
		new house_price = GetHouseData(houseid, H_PRICE);
		new house_percent = (house_price * 30) / 100;
		new house_improvemnts_price = HouseImprovementsPrice(houseid);

		if(house_improvemnts_price)
			house_improvemnts_price = (house_improvemnts_price * 60) / 100;

		new query[200];
		new return_money = (house_price - house_percent) + house_improvemnts_price;

		CallLocalFunction("EvictHouseRentersAll", "i", houseid);

		SetPlayerData(playerid, P_HOUSE, -1);
		SetPlayerData(playerid, P_HOUSE_TYPE, HOUSE_TYPE_NONE);

		SetHouseData(houseid, H_OWNER_ID, 0);

		if(to_player == INVALID_PLAYER_ID)
		{
			AddPlayerData(playerid, P_BANK, +, return_money);

			BankLog(playerid, return_money, "Продажа дома");

			SetHouseData(houseid, H_IMPROVEMENTS,	0);

			SetHouseData(houseid, H_RENT_DATE,		0);
			SetHouseData(houseid, H_LOCK_STATUS,	false);

			format(query, sizeof query, "UPDATE accounts a,houses h SET a.bank=%d,a.house_type=-1,a.house=-1,h.owner_id=0,h.lock=0 WHERE a.id=%d AND h.id=%d", GetPlayerData(playerid, P_BANK), GetPlayerAccountID(playerid), GetHouseData(houseid, H_SQL_ID));
			mysql_query(mysql, query, false);

			UpdateHouse(houseid);

			HouseHealthInit(houseid);
			HouseStoreInit(houseid);

			GivePlayerMoneyEx(playerid, 0, "Продажа дома государству", false, false);

			format(query, sizeof query, "Налог за продажу дома составил 30 процентов от его стоимости {99CC00}(%d руб)", house_percent);
			SendClientMessage(playerid, 0xCECECEFF, query);

			format(query, sizeof query, "Вам было возвращено 60 процентов от стоимости купленных улучшений: {CCFF00}%d руб", house_improvemnts_price);
			SendClientMessage(playerid, 0xCECECEFF, query);
			
			format(query, sizeof query, "Вам было возвращено 60 процентов от стоимости купленных улучшений подвала: {CCFF00}%d руб", house_improvemnts_price);
			SendClientMessage(playerid, 0xCECECEFF, query);

			format(query, sizeof query, "Итого на банковский счет перечислено: {3399FF}%d руб", return_money);
			SendClientMessage(playerid, 0xFFFFFFFF, query);

			new entranceid = GetHouseData(houseid, H_ENTRACE);
			if(entranceid != -1)
			{
				CallLocalFunction("EntranceStatusInit", "i", entranceid);
			}
		}
					else
		{
			if(BuyPlayerHouse(to_player, houseid, true, price) == 1)
			{
				new total_price = price + house_improvemnts_price;

				format(query, sizeof query, "Вам было возвращено 60 процентов от стоимости купленных улучшений: {CCFF00}%d руб", house_improvemnts_price);
				SendClientMessage(playerid, 0xCECECEFF, query);

				format(query, sizeof query, "UPDATE accounts SET money=%d,house=-1 WHERE id=%d LIMIT 1", GetPlayerMoneyEx(playerid)+total_price, GetPlayerAccountID(playerid));
				mysql_query(mysql, query, false);

				GivePlayerMoneyEx(playerid, total_price, "Продажа дома игроку", false, false);

				house_price = price;
				house_percent = 0;
			}
					else return ;
		}
		format(query, sizeof query, "~g~+%d rub~n~+%d rub", (house_price - house_percent), house_improvemnts_price);
		GameTextForPlayer(playerid, query, 4000, 1);
	}
}

stock BuyPlayerHouse(playerid, houseid, bool: buy_from_owner = false, price = -1)
{
	if(!IsHouseOwned(houseid) && GetPlayerHouse(playerid) == -1)
	{
		if(price <= 0)
			price = GetHouseData(houseid, H_PRICE);

		if(GetPlayerMoneyEx(playerid) >= price)
		{
			new query[256];

			format(query, sizeof query, "UPDATE accounts a, houses h SET a.money=%d,a.house_type=%d,a.house=%d,h.owner_id=%d WHERE a.id=%d AND h.id=%d", GetPlayerMoneyEx(playerid)-price, HOUSE_TYPE_HOME, houseid, GetPlayerAccountID(playerid), GetPlayerAccountID(playerid), GetHouseData(houseid, H_SQL_ID));
			mysql_query(mysql, query, false);
			printf("sql %s", query);

			if(!mysql_errno())
			{
				SetPlayerData(playerid, P_HOUSE, 		houseid);
				SetPlayerData(playerid, P_HOUSE_TYPE, 	HOUSE_TYPE_HOME);

				SetHouseData(houseid, H_OWNER_ID, GetPlayerAccountID(playerid));
				SetHouseData(houseid, H_IMPROVEMENTS, 	0);

				SetHouseData(houseid, H_STORE_X, 0.0);
				SetHouseData(houseid, H_STORE_Y, 0.0);
				SetHouseData(houseid, H_STORE_Z, 0.0);

				new time = gettime();
				new rent_time = (time - (time % 86400)) + 86400;

				if(!buy_from_owner)
				{
					SetHouseData(houseid,	H_RENT_DATE,	rent_time);
					SetHouseData(houseid,	H_LOCK_STATUS,	false);

					new entranceid = GetHouseData(houseid, H_ENTRACE);
					if(entranceid != -1)
					{
						CallLocalFunction("EntranceStatusInit", "i", entranceid);
					}
				}
					else
				{
					if(GetElapsedTime(GetHouseData(houseid, H_RENT_DATE), time, CONVERT_TIME_TO_DAYS) <= 0)
					{
						SetHouseData(houseid, H_RENT_DATE, rent_time);
					}
				}
				format(g_house[houseid][H_OWNER_NAME], 21, GetPlayerNameEx(playerid), 0);

				UpdateHouse(houseid);

				HouseHealthInit(houseid);
				HouseStoreInit(houseid);

				GivePlayerMoneyEx(playerid, -price, "Покупка дома", false, true);
				SendClientMessage(playerid, 0x66CC00FF, "{FFFFFF}Поздравляем с успешным приобретением нового дома / квартиры.");
				SendClientMessage(playerid, 0xFFCC00FF, "{FFFFFF}Чтобы сменить место своего появления воспользуйтесь командой: {ffff00} /setspawn.");

				format(query, sizeof query, "UPDATE houses SET improvements=0,rent_time=%d,`lock`=%d,store_x=0.0,store_y=0.0,store_z=0.0 WHERE id=%d LIMIT 1", GetHouseData(houseid, H_RENT_DATE), GetHouseData(houseid, H_LOCK_STATUS), GetHouseData(houseid, H_SQL_ID));
				mysql_query(mysql, query, false);

				return 1;
			}
					else SendClientMessage(playerid, 0xFF6600FF, "Ошибка сохранения, повторите попытку {FF0000}(equ-code 34)");

			return 0;
		}
		return 0;
	}
	return -1;
}

stock EnterPlayerToHouse(playerid, houseid)
{
	if(GetPlayerInHouse(playerid) == -1)
	{
		new type = GetHouseData(houseid, H_TYPE);

		SetPlayerPosEx
		(
			playerid,
			GetHouseTypeInfo(type, HT_ENTER_POS_X),
			GetHouseTypeInfo(type, HT_ENTER_POS_Y),
			GetHouseTypeInfo(type, HT_ENTER_POS_Z),
			GetHouseTypeInfo(type, HT_ENTER_POS_ANGLE),
			GetHouseTypeInfo(type, HT_INTERIOR),
			houseid + 2000
		);
		SetPlayerInHouse(playerid, houseid);
	}
}

stock ExitPlayerFromHouse(playerid, Float: radius = 3.0, pos = 0)
{
	new houseid = GetPlayerInHouse(playerid);
	if(houseid != -1)
	{
		new type = GetHouseData(houseid, H_TYPE);
		if(IsPlayerInRangeOfPoint(playerid, radius, GetHouseTypeInfo(type, HT_ENTER_POS_X), GetHouseTypeInfo(type, HT_ENTER_POS_Y), GetHouseTypeInfo(type, HT_ENTER_POS_Z)) || IsPlayerInRangeOfPoint(playerid, radius, 1.2011, 1994.7356, 1554.2031))
		{
			switch(pos)
			{
				case 0:
				{
					SetPlayerInHouse(playerid, -1);

					new entranceid = GetHouseData(houseid, H_ENTRACE);
					if(entranceid != -1)
					{
						new floor = GetHouseData(houseid, H_FLAT_ID) / 4 + 1;
						type = GetHouseData(houseid, H_FLAT_ID) % 4;

						SetPlayerInEntrance(playerid, entranceid);
						SetPlayerInEntranceFloor(playerid, floor);

						SetPlayerPosEx
						(
							playerid,
							g_entrance_flat_pos[type][3],
							g_entrance_flat_pos[type][4],
							g_entrance_flat_pos[type][2],
							g_entrance_flat_pos[type][5],
							floor + 1,
							(entranceid * 100) + floor
						);
					}
					else
					{
						SetPlayerPosEx
						(
							playerid,
							GetHouseData(houseid, H_EXIT_POS_X),
							GetHouseData(houseid, H_EXIT_POS_Y),
							GetHouseData(houseid, H_EXIT_POS_Z),
							GetHouseData(houseid, H_EXIT_ANGLE),
							0,
							0
						);
					}
				}
				case 1:
				{
					
					SetPlayerPosEx
					(
						playerid,
						1.2011,
						1994.7356,
						1554.2031,
						353.9531,
						GetHouseTypeInfo(type, HT_INTERIOR),
						houseid + 2000
					);
					
				}
			}
			
			return 1;
		}
	}
	return 0;
}

stock GetPlayerHouse(playerid, type = -1)
{
	new houseid = GetPlayerData(playerid, P_HOUSE);
	if(houseid != -1)
	{
		switch(type)
		{
			case HOUSE_TYPE_HOME:
			{
				if(GetPlayerData(playerid, P_HOUSE_TYPE) == HOUSE_TYPE_HOME)
				{
					if(GetHouseData(houseid, H_OWNER_ID) == GetPlayerAccountID(playerid))
					{
						return houseid;
					}
				}
			}
			case HOUSE_TYPE_ROOM:
			{
				if(GetPlayerData(playerid, P_HOUSE_TYPE) == HOUSE_TYPE_ROOM)
				{
					new room = GetPlayerData(playerid, P_HOUSE_ROOM);
					if(room != -1)
					{
						if(GetHouseRenterInfo(houseid, room, HR_OWNER_ID) == GetPlayerAccountID(playerid))
						{
							return houseid;
						}
					}
				}
			}
			case HOUSE_TYPE_HOTEL:
			{
				if(GetPlayerData(playerid, P_HOUSE_TYPE) == HOUSE_TYPE_HOTEL)
				{
					new room = GetPlayerData(playerid, P_HOUSE_ROOM);
					if(room != -1)
					{
						if(GetHotelData(houseid, room, H_OWNER_ID) == GetPlayerAccountID(playerid))
						{
							return houseid;
						}
					}
				}
			}
			default:
				return houseid;
		}
	}
	return -1;
}

stock HouseImprovementsPrice(houseid)
{
	new price;
	new level = GetHouseData(houseid, H_IMPROVEMENTS);

	if(1 <= level <= sizeof g_house_improvements)
	{
		for(new idx; idx < level; idx ++)
		{
			price += g_house_improvements[idx][I_PRICE];
		}
	}
	return price;
}

stock IsPlayerInRangeOfHouse(playerid, houseid, Float: radius = 10.0)
{
	new result;
	if(GetHouseData(houseid, H_ENTRACE) != -1)
	{
		new flatid = GetHouseData(houseid, H_FLAT_ID) % 4;
		result = IsPlayerInRangeOfPoint(playerid, radius, g_entrance_flat_pos[flatid][0], g_entrance_flat_pos[flatid][1], g_entrance_flat_pos[flatid][2]);
	}
					else result = IsPlayerInRangeOfPoint(playerid, radius, GetHouseData(houseid, H_POS_X), GetHouseData(houseid, H_POS_Y), GetHouseData(houseid, H_POS_Z));

	return result;
}

stock BuyOwnableCarFamily(playerid, marketid, ownablecar)
{
	new color_1 = GetPlayerData(playerid, P_AUTOSALON_COLOR1);
	new color_2 = GetPlayerData(playerid, P_AUTOSALON_COLOR2);
	
    HideAutosalonTextDraws(playerid);
	RemovePlayerFromVehicle(playerid);
    new modelid, vehicle_price, query[256];
 	printf("player_cars: %d / player_slots: %d", GetPlayerOwnableCars(playerid), GetPlayerCarSlots(playerid));

	printf("BuyOwnableCar(%d, %d, %d, %d, %d)", playerid, marketid, ownablecar, color_1, color_2);

	if(ownablecar < 1000)
	{
		modelid = car_market_data[marketid][ownablecar][CM_MODELID];
		vehicle_price = car_market_data[marketid][ownablecar][CM_COST];
	}
	else
		modelid = ownablecar - 1000;
	if(!vehicle_price) vehicle_price = GetVehicleInfo(modelid - 400, VI_PRICE);

/*	if(marketid != 0 && marketid != 2)
	{
		if(GetPlayerHouse(playerid, HOUSE_TYPE_HOME) == -1 &&
		GetPlayerHouse(playerid, HOUSE_TYPE_HOTEL) == -1 &&
		GetPlayerHouse(playerid, HOUSE_TYPE_ROOM) == -1)
		{
			SendClientMessage(playerid, 0xCECECEFF, "Для покупки транспорта этого класса нужно иметь недвижимость");
			return -1;
		}
	}

	if(GetPlayerOwnableCar(playerid) != INVALID_VEHICLE_ID)
	{
		SendClientMessage(playerid, 0xCECECEFF, "{E0584B} {FFFFFF} Чтобы приобрести новое транспортное средство необходимо выгрузить активное: {FFFF00}\"/car\".");
		return -1;
	}
	*/
	
	new fam = GetPlayerData(playerid, P_FAMILY) + 1;
	if(!GetPlayerData(playerid, P_FAMILY)) return SendClientMessage(playerid, 0xCECECEFF, "Вы не состоите в семье");
	
	if(GetPlayerData(playerid, P_FAMILY_RANK) != 10)
		return SendClientMessage(playerid, 0x999999FF, "Вы не глава семьи");
	
	if(GetFamilyData(fam, F_FAMILY_CARS) >= 5) return Send(playerid, -1, "В семье уже нет места для транспорта");
	
	if(GetPlayerMoneyEx(playerid) < vehicle_price)
	{
		SendClientMessage(playerid, 0x999999FF, "Недостаточно денег для покупки транспорта");
		return -1;
	}
	new biz_id;
	if(!AutosalonHasBusinessProducts(playerid, marketid, biz_id)) return -1;

	GivePlayerMoneyEx(playerid, -vehicle_price, "Покупка семейного транспорта", true, true);
	AutosalonUseBusinessProducts(biz_id, playerid, vehicle_price);

  	//TransferCoffersMoney((vehicle_price), "Покупка авто", "", false);

	new buy_cars_count = cars_after_purchase_count[marketid]++;

	new fam_id = GetPlayerData(playerid, P_FAMILY);

	new vehicleid = GetPlayerVehicleID(playerid);

	if(buy_cars_count >= cars_after_purchase_limit[marketid] - 1)
		cars_after_purchase_count[marketid] = 0;

	new Float: pos_x = cars_pos_after_purchase[marketid][buy_cars_count][0];
	new Float: pos_y = cars_pos_after_purchase[marketid][buy_cars_count][1];
	new Float: pos_z = cars_pos_after_purchase[marketid][buy_cars_count][2];
	new Float: angle = cars_pos_after_purchase[marketid][buy_cars_count][3];

	new Cache: result,
		idx;

	idx = GetFreeFamilyCarID();

    SetFamilyCarData(idx, F_OWNER_ID,     GetPlayerAccountID(playerid));

    SetFamilyCarData(idx, F_MODEL_ID,     modelid);
    SetFamilyCarData(idx, F_COLOR_1,      color_1);
    SetFamilyCarData(idx, F_COLOR_2,      color_2);

    SetFamilyCarData(idx, F_POS_X,        pos_x);
    SetFamilyCarData(idx, F_POS_Y,        pos_y);
    SetFamilyCarData(idx, F_POS_Z,        pos_z);
    SetFamilyCarData(idx, F_ANGLE,        angle);

    SetOwnableCarData(idx, OC_KEY_IN,       false);

    SetOwnableCarData(idx, OC_CREATE,       gettime());

    // ----------------------------------------------------------------------------------------

    g_family_car[idx][F_CAR_ID] = CreateVehicle
    (
        GetFamilyCarData(idx, F_MODEL_ID),
        GetFamilyCarData(idx, F_POS_X),
        GetFamilyCarData(idx, F_POS_Y),
        GetFamilyCarData(idx, F_POS_Z),
        GetFamilyCarData(idx, F_ANGLE),
        GetFamilyCarData(idx, F_COLOR_1),
        GetFamilyCarData(idx, F_COLOR_2),
        -1,
        0,
        VEHICLE_ACTION_TYPE_FAMILY_CAR,
        idx
    );
    if(GetFamilyCarData(idx, F_CAR_ID) != INVALID_VEHICLE_ID)
    {
        CreateVehicleLabel(GetFamilyCarData(idx, F_CAR_ID), GetFamilyData(fam_id, F_NAME), 0x6666CCEE, 0.0, 0.0, 1.3, 20.0);
        SetVehicleParam(GetFamilyCarData(idx, F_CAR_ID), V_LOCK, false);

        SetVehicleData(GetFamilyCarData(idx, F_CAR_ID), V_MILEAGE, 0.0);
        SetVehicleData(GetFamilyCarData(idx, F_CAR_ID), V_FUEL, 50.0);
    }
    format
    (
        query, sizeof query,
        "INSERT INTO family_cars \
        (owner_id,model_id,color_1,color_2,pos_x,pos_y,pos_z,angle,create_time) \
        VALUES \
        ('%d','%d','%d','%d','%f','%f','%f','%f','%d')",
        fam_id,
        GetFamilyCarData(idx, F_MODEL_ID),
        GetFamilyCarData(idx, F_COLOR_1),
        GetFamilyCarData(idx, F_COLOR_2),
        GetFamilyCarData(idx, F_POS_X),
        GetFamilyCarData(idx, F_POS_Y),
        GetFamilyCarData(idx, F_POS_Z),
        GetFamilyCarData(idx, F_ANGLE),
        gettime()
    );

    result = mysql_query(mysql, query, true);
    printf("%s",query);

    SetFamilyCarData(idx, F_SQL_ID, cache_insert_id());
    cache_delete(result);

	SaveFamilyCar(vehicleid);
	
	fam_id = GetPlayerData(playerid, P_FAMILY) + 1;
	new fmt_text[120];
	
	AddFamilyData(fam_id,F_FAMILY_CARS,+,1);
	
	mysql_format(mysql, fmt_text, sizeof fmt_text, "UPDATE family SET family_cars='%d' WHERE id='%d' LIMIT 1", GetFamilyData(fam_id, F_FAMILY_CARS), fam_id);
 	mysql_query(mysql, fmt_text, false);

	SendClientMessage(playerid, 0x32a44bFF, "Поздравляем с покупкой нового транспорта в семью!");
    SendClientMessage(playerid, 0x1E90FFFF, "Документы на транспорт будут оформлены в течении нескольких минут");

    return 1;
}

stock BuyOwnableCar(playerid, marketid, ownablecar)
{
    if(GetPVarInt(playerid, "autosalon_buy_lock") > gettime())
        return 1;
    SetPVarInt(playerid, "autosalon_buy_lock", gettime() + 2);

    SyncAutosalonSelectedColors(playerid);
    new color_1 = buy_car_select_color[playerid][0];
    new color_2 = buy_car_select_color[playerid][1];
    if(!(0 <= color_1 <= MAX_COLOR_ID)) color_1 = GetPlayerData(playerid, P_AUTOSALON_COLOR1);
    if(!(0 <= color_2 <= MAX_COLOR_ID)) color_2 = GetPlayerData(playerid, P_AUTOSALON_COLOR2);
    SetPlayerData(playerid, P_AUTOSALON_COLOR1, color_1);
    SetPlayerData(playerid, P_AUTOSALON_COLOR2, color_2);
    buy_car_select_color[playerid][0] = color_1;
    buy_car_select_color[playerid][1] = color_2;

	printf("player_cars: %d / player_slots: %d", GetPlayerOwnableCars(playerid), GetPlayerCarSlots(playerid));

	printf("BuyOwnableCar(%d, %d, %d, %d, %d)", playerid, marketid, ownablecar, color_1, color_2);

	if((GetPlayerOwnableCars(playerid) + 1) > GetPlayerCarSlots(playerid))
	{
		SendClientMessage(playerid, 0x3399FFFF, "Все слоты для транспорта заняты. Вы можете увеличить их: {FFFF00}/menu > Дополнительно");
		return -1;
	}
	
	if(GetPlayerOwnableCar(playerid) != INVALID_VEHICLE_ID)
	{
		SendClientMessage(playerid, 0x999999FF, "{E0584B} {FFFFFF} Чтобы приобрести новое транспортное средство необходимо выгрузить активное: {FFFF00}\"/car\".");
		return -1;
	}
	
	new modelid, vehicle_price;

	if(ownablecar < 1000)
	{
		modelid = car_market_data[marketid][ownablecar][CM_MODELID];
		vehicle_price = car_market_data[marketid][ownablecar][CM_COST];
	}
	else
		modelid = ownablecar - 1000;
	if(!vehicle_price) vehicle_price = GetVehicleInfo(modelid - 400, VI_PRICE);

	printf("modelid = %d | ownablecar = %d", modelid, ownablecar);

	if(modelid <= 0)
		return -1;

	if(!AutosalonHasVehicleSlots(marketid, modelid))
	{
		ShowNotificationNew(playerid, 2, 6, 0, 0, "Данной машины нет в наличии", " ");
		return -1;
	}
/*if(marketid != 0 && marketid != 2)
	{
		if(GetPlayerHouse(playerid, HOUSE_TYPE_HOME) == -1 &&
		GetPlayerHouse(playerid, HOUSE_TYPE_HOTEL) == -1 &&
		GetPlayerHouse(playerid, HOUSE_TYPE_ROOM) == -1)
		{
			SendClientMessage(playerid, 0x999999FF, "Для покупки транспорта этого класса нужно иметь недвижимость");
			return -1;
		}
	}*/


	if(GetPlayerMoneyEx(playerid) < vehicle_price)
	{
		SendClientMessage(playerid, -1, "{E0584B} {FFFFFF} У вас недостаточно денежных средств для покупки данного транспортного средства.");
		return -1;
	}
	new biz_id;
	if(!AutosalonHasBusinessProducts(playerid, marketid, biz_id)) return -1;

	new idx = GetFreeOwnableCarID();
	if(idx == -1)
	{
		SendClientMessage(playerid, 0x999999FF, "Нет свободных слотов транспорта на сервере");
		return -1;
	}

	new autosalon_slot_modelid;
	if(!AutosalonTakeVehicleSlot(marketid, modelid, autosalon_slot_modelid))
	{
		ShowNotificationNew(playerid, 2, 6, 0, 0, "Данной машины нет в наличии", " ");
		return -1;
	}
    HideAutosalonTextDraws(playerid);
	ExitPlayerBuyCarMarket(playerid);
	GivePlayerMoneyEx(playerid, -vehicle_price, "Покупка ТС в автосалоне", true, true);
	AutosalonUseBusinessProducts(biz_id, playerid, vehicle_price);

	new buy_cars_count = cars_after_purchase_count[marketid]++;

	if(buy_cars_count >= cars_after_purchase_limit[marketid] - 1)
		cars_after_purchase_count[marketid] = 0;

	new Float: pos_x = cars_pos_after_purchase[marketid][buy_cars_count][0];
	new Float: pos_y = cars_pos_after_purchase[marketid][buy_cars_count][1];
	new Float: pos_z = cars_pos_after_purchase[marketid][buy_cars_count][2];
	new Float: angle = cars_pos_after_purchase[marketid][buy_cars_count][3];

	new query[512],
		Cache: result;

	SetOwnableCarData(idx, OC_OWNER_ID, 	GetPlayerAccountID(playerid));

	SetOwnableCarData(idx, OC_MODEL_ID, 	modelid);
	SetOwnableCarData(idx, OC_COLOR_1, 		color_1);
	SetOwnableCarData(idx, OC_COLOR_2, 		color_2);
    SetOwnableCarData(idx, OC_body_colors,     0);
    SetOwnableCarData(idx, OC_wheelcolors,     0);

	SetOwnableCarData(idx, OC_POS_X, 		pos_x);
	SetOwnableCarData(idx, OC_POS_Y, 		pos_y);
	SetOwnableCarData(idx, OC_POS_Z, 		pos_z);
	SetOwnableCarData(idx, OC_ANGLE, 		angle);

	strmid(g_ownable_car[idx][OC_NUMBER], "------", 0, 8, 8);

	SetOwnableCarData(idx, OC_ALARM, 		false);
	SetOwnableCarData(idx, OC_KEY_IN, 		false);

	SetOwnableCarData(idx, OC_CREATE, 		gettime());

	format(g_ownable_car[idx][OC_OWNER_NAME], 21, GetPlayerNameEx(playerid));
	// ----------------------------------------------------------------------------------------

	new vehicleid = CreateVehicle
	(
		GetOwnableCarData(idx, OC_MODEL_ID),
		GetOwnableCarData(idx, OC_POS_X),
		GetOwnableCarData(idx, OC_POS_Y),
		GetOwnableCarData(idx, OC_POS_Z),
		GetOwnableCarData(idx, OC_ANGLE),
		GetOwnableCarData(idx, OC_COLOR_1),
		GetOwnableCarData(idx, OC_COLOR_2),
		-1,
		0,
		VEHICLE_ACTION_TYPE_OWNABLE_CAR,
		idx
	);
	if(vehicleid != INVALID_VEHICLE_ID)
	{
		//CreateVehicleLabel(vehicleid, GetOwnableCarData(idx, OC_NUMBER), 0xFFFF00EE, 0.0, 0.0, 1.3, 20.0);
		//index = GetVehicleData(vehicleid, V_ACTION_ID);
        format(g_ownable_car[idx][OC_NUMBER], 32, g_ownable_car[idx][OC_NUMBER]);
        SetVehicleColor(vehicleid, GetVehicleRGBAColorById(color_1), GetVehicleRGBAColorById(color_2), 1);
        ChangeVehicleColor(vehicleid, color_1, color_2);
        ApplyOwnableCarStoredPlate(vehicleid, idx);
		SetVehicleParam(vehicleid, V_LOCK, false);

		SetVehicleData(vehicleid, V_MILEAGE, 0.0);
							SetVehicleData(vehicleid, V_FUEL, 40.0);
	}

	SetPlayerData(playerid, P_OWNABLE_CAR, vehicleid);

	format
	(
		query, sizeof query,
		"INSERT INTO ownable_cars \
		(owner_id,model_id,color_1,color_2,pos_x,pos_y,pos_z,angle,create_time,body_colors,wheel_colors) \
		VALUES \
		('%d','%d','%d','%d','%f','%f','%f','%f','%d','0','0')",
		GetPlayerAccountID(playerid),
		modelid,
		color_1,
		color_2,
		pos_x,
		pos_y,
		pos_z,
		angle,
		gettime()
	);
	result = mysql_query(mysql, query, true);

		if(mysql_errno())
	{
		AutosalonAddVehicleSlot(marketid, autosalon_slot_modelid, 1);
		GivePlayerMoneyEx(playerid, vehicle_price, "Возврат за покупку ТС", true, true);
		if(vehicleid != INVALID_VEHICLE_ID)
			DestroyVehicle(vehicleid);

		SetPlayerData(playerid, P_OWNABLE_CAR, INVALID_VEHICLE_ID);
		SetOwnableCarData(idx, OC_OWNER_ID, 0);
		SetOwnableCarData(idx, OC_MODEL_ID, 0);
		SetOwnableCarData(idx, OC_COLOR_1, 0);
		SetOwnableCarData(idx, OC_COLOR_2, 0);
		SetOwnableCarData(idx, OC_POS_X, 0.0);
		SetOwnableCarData(idx, OC_POS_Y, 0.0);
		SetOwnableCarData(idx, OC_POS_Z, 0.0);
		SetOwnableCarData(idx, OC_ANGLE, 0.0);
		SetOwnableCarData(idx, OC_CREATE, 0);
		cache_delete(result);
		return SendClientMessage(playerid, 0xFF6600FF, "Ошибка сохранения транспорта в базу данных");
	}
SetOwnableCarData(idx, OC_SQL_ID, cache_insert_id());

	cache_delete(result);

    ShowHud(playerid);
    launch[playerid] = 0;
    diski[playerid] = 0;
    fars[playerid] = 0;
    nitro[playerid] = 0;
	SendClientMessage(playerid, 0x66CC00FF, "{FFFFFF}Для загрузки транспорта воспользуйтесь{ffff00} Меню - Транспорт.");
	SendClientMessage(playerid, 0x66CC00FF, "{FFFFFF}Или воспользуйтесь{ffff00} парковкой.");
	UnloadPlayerOwnableCar(playerid);

	AddPlayerData(playerid, P_QUEST_EXP_5, +, 1);
	UpdatePlayerDatabaseInt(playerid, "quest_exp_5", GetPlayerData(playerid, P_QUEST_EXP_5));

	if(GetPlayerData(playerid, P_QUEST_EXP_5) == 1)
	{
	    SendClientMessage(playerid, COR_SERVER, "{ffffff}Вы успешно выполнили квест {009900}'Первый транспорт'. {ffffff}Ваша награда: {009900}5000 руб, 1exp");
        SendClientMessage(playerid, COR_SERVER, "{ffffff}Введите {009900}/quest{ffffff},для подробной информации по Вашим квестам");
	    GivePlayerMoneyEx(playerid, 10000, "Выполнение квеста");

	    SetPlayerData(playerid, P_QUEST_5, 1);
	    UpdatePlayerDatabaseInt(playerid, "quest_5", 1);
	    
	    AddPlayerData(playerid, P_TOP_5, +, 1);
		UpdatePlayerDatabaseInt(playerid, "TOP_Quest", GetPlayerData(playerid, P_TOP_5));
	}

	return 1;
}

stock GetFreeHousesCount()
{
	new count;
	for(new idx; idx < g_house_loaded; idx ++)
	{
		if(IsHouseOwned(idx)) continue;

		count ++;
	}
	return count;
}

stock ShowHouseRenterInfo(playerid, houseid, roomid)
{
	if(GetPlayerHouse(playerid, HOUSE_TYPE_HOME) == houseid)
	{
		if(0 <= roomid <= MAX_HOUSE_ROOMS-1)
		{
			if(IsHouseRoomOwned(houseid, roomid))
			{
				SetPlayerUseListitem(playerid, roomid);

				new string[144];
				new time = gettime();

				new s_year, s_month, s_day; // поселение
				timestamp_to_date(GetHouseRenterInfo(houseid, roomid, HR_RENT_TIME), s_year, s_month, s_day);

				//new e_year, e_month, e_day;	// выселение
				//timestamp_to_date(GetHouseRoomInfo(houseid, roomid, HR_RENT_DATE), e_year, e_month, e_day);

				format
				(
					string, sizeof string,
					"1. Арендатор\t\t\t{CCCC00}%s\n"\
					"2. Поселился\t\t\t%02d-%02d-%d\n"\
					"3. Проживает\t\t\t{66BB33}%d дней\n"\
					"{888888}4. Выселить",
					GetHouseRenterInfo(houseid, roomid, HR_OWNER_NAME),
					s_day, s_month, s_year,
					GetElapsedTime(time, GetHouseRenterInfo(houseid, roomid, HR_RENT_TIME), CONVERT_TIME_TO_DAYS)
				);
				Dialog(playerid, DIALOG_HOUSE_RENTER_INFO, DIALOG_STYLE_LIST, "{33AACC}Информация о арендаторе", string, "Действие", "Назад");
			}
					else SendClientMessage(playerid, 0x999999FF, "В этой комнате уже никто не проживает");
		}
	}
}

stock AddHouseRenter(houseid, roomid, playerid)
{
	if(!IsHouseRoomOwned(houseid, roomid))
	{
		new query[128];
		new Cache: result;

		new time = gettime();

		format(query, sizeof query, "UPDATE accounts SET house_type=%d,house_room=%d,house=%d WHERE id=%d LIMIT 1", HOUSE_TYPE_ROOM, roomid, houseid, GetPlayerAccountID(playerid));
		mysql_query(mysql, query, false);

		format(query, sizeof query, "INSERT INTO houses_renters (owner_id,house_id,room_id,rent_time,time) VALUES (%d,%d,%d,%d,%d)", GetPlayerAccountID(playerid), GetHouseData(houseid, H_SQL_ID), roomid, 0, time);
		result = mysql_query(mysql, query, true);

		SetHouseRenterInfo(houseid, roomid, HR_SQL_ID, 		cache_insert_id());
		SetHouseRenterInfo(houseid, roomid, HR_OWNER_ID,	GetPlayerAccountID(playerid));
		SetHouseRenterInfo(houseid, roomid, HR_RENT_DATE,	0);
		SetHouseRenterInfo(houseid, roomid, HR_RENT_TIME,	time);

		format(GetHouseRenterInfo(houseid, roomid, HR_OWNER_NAME), 21, GetPlayerNameEx(playerid));

		SetPlayerData(playerid, P_HOUSE, 		houseid);
		SetPlayerData(playerid, P_HOUSE_TYPE, 	HOUSE_TYPE_ROOM);
		SetPlayerData(playerid, P_HOUSE_ROOM, 	roomid);

		AddHouseRentersCount(houseid, +, 1);

		cache_delete(result);
	}
}

stock EvictHouseRenter(houseid, roomid, renter_id = INVALID_PLAYER_ID, ownerid = INVALID_PLAYER_ID)
{
	if(IsHouseRoomOwned(houseid, roomid))
	{
		new query[90];

		format(query, sizeof query, "DELETE FROM houses_renters WHERE owner_id=%d AND house_id=%d", GetHouseRenterInfo(houseid, roomid, HR_OWNER_ID), GetHouseData(houseid, H_SQL_ID));
		mysql_query(mysql, query, false);

		format(query, sizeof query, "UPDATE accounts SET house_type=-1,house_room=-1,house=-1 WHERE id=%d LIMIT 1", GetHouseRenterInfo(houseid, roomid, HR_OWNER_ID));
		mysql_query(mysql, query, false);

		if(!mysql_errno())
		{
			if(renter_id == INVALID_PLAYER_ID)
				renter_id = GetPlayerID(GetHouseRenterInfo(houseid, roomid, HR_OWNER_NAME));

			if(renter_id != INVALID_PLAYER_ID)
			{
				if(GetPlayerHouse(renter_id, HOUSE_TYPE_ROOM) == houseid)
				{
					if(ownerid != INVALID_PLAYER_ID)
					{
						format(query, sizeof query, "%s выселил Вас из своего дома", GetPlayerNameEx(ownerid));
						SendClientMessage(renter_id, 0x3399FFFF, query);
					}

					SetPlayerData(renter_id, P_HOUSE, -1);
					SetPlayerData(renter_id, P_HOUSE_TYPE, -1);
					SetPlayerData(renter_id, P_HOUSE_ROOM, -1);
				}
			}

			SetHouseRenterInfo(houseid, roomid, HR_SQL_ID, 	0);
			SetHouseRenterInfo(houseid, roomid, HR_OWNER_ID,	0);
			SetHouseRenterInfo(houseid, roomid, HR_RENT_DATE,	0);
			SetHouseRenterInfo(houseid, roomid, HR_RENT_TIME,	0);

			AddHouseRentersCount(houseid, -, 1);
			return 1;
		}
		return -1;
	}
	return 0;
}

stock GetHouseIndexBySQLID(sql_id)
{
	new index = -1;

	for(new idx; idx < MAX_HOUSES; idx ++)
	{
		if(GetHouseData(idx, H_SQL_ID) != sql_id) continue;

		index = idx;
		break;
	}
	return index;
}

stock GetHouseFreeRoom(houseid)
{
	new roomid = -1;

	for(new idx; idx < MAX_HOUSE_ROOMS; idx ++)
	{
		if(IsHouseRoomOwned(houseid, idx)) continue;

		roomid = idx;
		break;
	}
	return roomid;
}

