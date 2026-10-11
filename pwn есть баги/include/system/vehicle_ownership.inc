public: PlayerOwnableCarInit(playerid)
{
	new index;
	new vehicleid = -1;

	while(vehicleid < MAX_VEHICLES-1)
	{
		vehicleid ++;
		index = GetVehicleData(vehicleid, V_ACTION_ID);

		if(GetVehicleData(vehicleid, V_ACTION_TYPE) != VEHICLE_ACTION_TYPE_OWNABLE_CAR) continue;
		if(GetOwnableCarData(index, OC_OWNER_ID) != GetPlayerAccountID(playerid)) continue;

		SetPlayerData(playerid, P_OWNABLE_CAR, vehicleid);
		break;
	}
}

public: SaveOwnableCar(vehicleid)
{
	if(IsAOwnableCar(vehicleid))
	{
		new query[360];
		new index = GetVehicleData(vehicleid, V_ACTION_ID);

		new Float: health;

		GetVehicleHealth(vehicleid, health);

		format
		(
			query, sizeof query,
			"UPDATE ownable_cars SET "\
			"pos_x=%f,"\
			"pos_y=%f,"\
			"pos_z=%f,"\
			"angle=%f,"\
			"status=%d,"\
			"alarm=%d,"\
			"key_in=%d,"\
			"mileage=%f,"\
			"fuel=%f,"\
			"health=%f,"\
			"number='%s'"\
			" WHERE id=%d LIMIT 1",
			GetOwnableCarData(index, OC_POS_X),
			GetOwnableCarData(index, OC_POS_Y),
			GetOwnableCarData(index, OC_POS_Z),
			GetOwnableCarData(index, OC_ANGLE),
			GetVehicleParam(vehicleid, V_LOCK),
			VEHICLE_PARAM_OFF, // active GTA alarm is never persisted across spawns
			GetOwnableCarData(index, OC_KEY_IN),
			GetVehicleData(vehicleid, V_MILEAGE),
			GetVehicleData(vehicleid, V_FUEL),
			GetVehicleData(vehicleid, V_HEALTH),
			GetOwnableCarData(index, OC_NUMBER),
			GetOwnableCarData(index, OC_SQL_ID)
		);
		mysql_query(mysql, query, false);

		g_ownable_mileage_saved[vehicleid] = GetVehicleData(vehicleid, V_MILEAGE);
		g_ownable_mileage_sync_time[vehicleid] = gettime();
        g_ownable_fuel_saved[vehicleid] = GetVehicleData(vehicleid, V_FUEL);
        g_ownable_fuel_sync_time[vehicleid] = gettime();

		return mysql_errno();
	}
	return -1;
}

stock SaveOwnableCarMileage(vehicleid)
{
	if(!IsAOwnableCar(vehicleid)) return 0;

	new index = GetVehicleData(vehicleid, V_ACTION_ID);
	if(index < 0) return 0;

	new sql_id = GetOwnableCarData(index, OC_SQL_ID);
	if(sql_id <= 0) return 0;

	new query[128];
	mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET mileage=%f WHERE id=%d LIMIT 1", GetVehicleData(vehicleid, V_MILEAGE), sql_id);
	mysql_tquery(mysql, query);

	return 1;
}
stock SaveOwnableCarFuel(vehicleid)
{
	if(!IsAOwnableCar(vehicleid)) return 0;

	new index = GetVehicleData(vehicleid, V_ACTION_ID);
	if(index < 0) return 0;

	new sql_id = GetOwnableCarData(index, OC_SQL_ID);
	if(sql_id <= 0) return 0;

	new query[128];
	mysql_format(mysql, query, sizeof query, "UPDATE ownable_cars SET fuel=%f WHERE id=%d LIMIT 1", GetVehicleData(vehicleid, V_FUEL), sql_id);
	mysql_tquery(mysql, query);

	return 1;
}


public: ShowTrunkDialog(playerid, vehicleid, view)
{
	new count, type;

	new fmt_str[36];
	new string[(sizeof fmt_str) * MAX_VEHICLE_TRUNK_SLOTS + 1];

	ClearPlayerListitemValues(playerid);
	for(new idx; idx < MAX_VEHICLE_TRUNK_SLOTS; idx ++)
	{
		if(IsTrunkFreeSlot(vehicleid, idx)) continue;

		type = GetTrunkData(vehicleid, idx, VT_ITEM_TYPE);

		format(fmt_str, sizeof fmt_str, "%d. %s:\t{66CC00}%d %s\n", count + 1, GetItemInfo(type, I_NAME), GetTrunkData(vehicleid, idx, VT_ITEM_AMOUNT), GetItemInfo(type, I_NAME_COUNT));
		strcat(string, fmt_str);

		SetPlayerListitemValue(playerid, count ++, idx);
	}

	if(!view)
	{
		SetPlayerListitemValue(playerid, count, -1);
		SetPlayerUseTrunk(playerid, vehicleid);

		format(fmt_str, sizeof fmt_str, "{888888}%d. Положить", count + 1);
		strcat(string, fmt_str);

		Dialog(playerid, DIALOG_VEHICLE_TRUNK, DIALOG_STYLE_LIST, "{0099FF}Содержимое багажника", string, "Выбрать", "Закрыть");
	}
					else
	{
		if(!count)
			strcat(string, "{888888}Пусто");

		SetPlayerUseTrunk(playerid, INVALID_VEHICLE_ID);
		Dialog(playerid, DIALOG_VEHICLE_TRUNK, DIALOG_STYLE_LIST, "{0099FF}Содержимое багажника", string, "Закрыть", "");
	}
	return 1;
}

// ------------------------------------------
stock GetTrunkFreeSlot(vehicleid, item_type)
{
	new free_slot = -1, comb_slot = -1;
	new bool: comb = GetItemInfo(item_type, I_COMBINATION);

	for(new idx; idx < MAX_VEHICLE_TRUNK_SLOTS; idx ++)
	{
		if(GetTrunkData(vehicleid, idx, VT_ITEM_TYPE) == item_type && comb)
		{
			comb_slot = idx;
		}
					else if(free_slot == -1 && IsTrunkFreeSlot(vehicleid, idx))
		{
			free_slot = idx;
		}
					else continue;
	}
	return comb_slot != -1 ? comb_slot : free_slot;
}

stock GetTrunkBusySlot(vehicleid, item_type)
{
	new busy_slot = -1;

	for(new idx; idx < MAX_VEHICLE_TRUNK_SLOTS; idx ++)
	{
		if(GetTrunkData(vehicleid, idx, VT_ITEM_TYPE) == item_type)
		{
			busy_slot = idx;
		}
					else continue;
	}
	return busy_slot;
}

stock AddTrunkItem(vehicleid, item_id, amount, value = 0)
{
	if(1 <= item_id <= sizeof(g_item_type)-1)
	{
		new free_slot = GetTrunkFreeSlot(vehicleid, item_id);
		if(free_slot != -1)
		{
			SetTrunkData(vehicleid, free_slot, VT_SQL_ID, 1);

			SetTrunkData(vehicleid, free_slot, VT_ITEM_TYPE, item_id);
			SetTrunkData(vehicleid, free_slot, VT_ITEM_VALUE, value);

			new query[100],
				index,
				oc_id;

			index = GetVehicleData(vehicleid, V_ACTION_ID);
			oc_id = GetOwnableCarData(index, OC_SQL_ID);

			if(!IsTrunkFreeSlot(vehicleid, free_slot))
			{
				AddTrunkData(vehicleid, free_slot, VT_ITEM_AMOUNT, +, amount);

				if((GetTrunkData(vehicleid, free_slot, VT_ITEM_AMOUNT) - amount) == 0)
				{
					mysql_format(mysql, query, sizeof query, "INSERT INTO trunks (oc_id,item_id,amount,value) VALUES (%d,%d,%d,%d)", oc_id, item_id, amount, value);
					mysql_query(mysql, query, false);
				}
					else
				{
					mysql_format(mysql, query, sizeof query, "UPDATE trunks SET amount='%d' WHERE item_id='%d' AND oc_id='%d' LIMIT 1", GetTrunkData(vehicleid, free_slot, VT_ITEM_AMOUNT), item_id, oc_id);
					mysql_query(mysql, query, false);
				}
			}
					else
			{
				SetTrunkData(vehicleid, free_slot, VT_ITEM_AMOUNT, amount);

				mysql_format(mysql, query, sizeof query, "INSERT INTO trunks (oc_id,item_id,amount,value) VALUES (%d,%d,%d,%d)", oc_id, item_id, amount, value);
				mysql_query(mysql, query, false);
			}

			return 1;
		}
		return -1;
	}
	return 0;
}


stock TakeTrunkItem(vehicleid, item_id, amount)
{
	if(1 <= item_id <= sizeof(g_item_type)-1)
	{
		new busy_slot = GetTrunkBusySlot(vehicleid, item_id);

		new query[100],
			index,
			oc_id;

		index = GetVehicleData(vehicleid, V_ACTION_ID);
		oc_id = GetOwnableCarData(index, OC_SQL_ID);

		if(!IsTrunkFreeSlot(vehicleid, busy_slot))
		{
			AddTrunkData(vehicleid, busy_slot, VT_ITEM_AMOUNT, -, amount);

			if(GetTrunkData(vehicleid, busy_slot, VT_ITEM_AMOUNT) >= 0)
			{
				if(!GetTrunkData(vehicleid, busy_slot, VT_ITEM_AMOUNT))
				{
					mysql_format(mysql, query, sizeof query, "DELETE FROM trunks WHERE item_id='%d' AND oc_id='%d'", item_id, oc_id);
					mysql_query(mysql, query, false);

					RemoveTrunkItem(vehicleid, busy_slot);
				}
					else
				{
					mysql_format(mysql, query, sizeof query, "UPDATE trunks SET amount='%d' WHERE item_id='%d' AND oc_id='%d' LIMIT 1", GetTrunkData(vehicleid, busy_slot, VT_ITEM_AMOUNT), item_id, oc_id);
					mysql_query(mysql, query, false);
				}
				return 1;
			}
					else
			{
				AddTrunkData(vehicleid, busy_slot, VT_ITEM_AMOUNT, +, amount);
				return -1;
			}
		}
		return -1;
	}
	return 0;
}

stock RemoveTrunkItem(vehicleid, item_slot)
{
	if(!IsTrunkFreeSlot(vehicleid, item_slot))
	{
		SetTrunkData(vehicleid, item_slot, VT_SQL_ID,	0);

		SetTrunkData(vehicleid, item_slot, VT_ITEM_TYPE, 	0);
		SetTrunkData(vehicleid, item_slot, VT_ITEM_AMOUNT, 	0);
		SetTrunkData(vehicleid, item_slot, VT_ITEM_VALUE, 	0);

		return 1;
	}
	return 0;
}

stock GetCoordVehicle(vehicleid, type, &Float:x, &Float:y, &Float:z, &Float:angle, &Float:distance) // by Essle (багажник / капот)
{
    GetVehicleModelInfo(GetVehicleData(vehicleid, V_MODELID), 1, x, distance, z); // узнаем длину машины
    distance = distance / 2 + 0.1; // полученную длину делим на два

    GetVehiclePos(vehicleid, x, y, z); // узнаем координаты авто
    GetVehicleZAngle(vehicleid, angle); // узнаем угол поворота авто

	switch(type)
	{
		case VEHICLE_COORD_TYPE_BOOT: // багажник
		{
			x += (distance * floatsin(-angle+180, degrees)); // вычитаем координату x бaгажника
			y += (distance * floatcos(-angle+180, degrees)); // вычитаем координату y бaгажника
		}
		case VEHICLE_COORD_TYPE_BONNET: // капот
		{
			x -= (distance * floatsin(-angle+180, degrees)); // вычитаем координату x капота
			y -= (distance * floatcos(-angle+180, degrees)); // вычитаем координату y капота
		}
		default:
		{
			return 0;
		}
	}
	return 1;
}

stock GetVehicleTurnSignalPos(vehicleid, type, &Float:x, &Float:y)
{
	/*

		Типы:
		1 - левый передний
		2 - левый задний
		3 - правый передний
		4 - правый задний

	*/

	new Float: size_x,
		Float: size_y,
		Float: size_z;

	GetVehicleModelInfo(GetVehicleData(vehicleid, V_MODELID), 1, size_x, size_y, size_z);

	switch(type)
	{
		case 1:
		{
			x = -(size_x / 2) + 0.3;
			y = size_y / 2 - 0.5;
		}
		case 2:
		{
			x = -(size_x / 2) + 0.3;
			y = -(size_y / 2) + 0.4;
		}
		case 3:
		{
			x = size_x / 2 - 0.3;
			y = size_y / 2 - 0.5;
		}
		case 4:
		{
			x = size_x / 2 - 0.3;
			y = -(size_y / 2) + 0.4;
		}
	}

	return 1;
}

stock SetVehicleToHotelRespawn(hotelid, vehicleid)
{
	if(IsValidVehicle(vehicleid))
	{
		new free_slot = GetHotelFreePark(hotelid);
		if(free_slot != -1)
		{
			g_hotel_car_park_pos[hotelid][free_slot][HC_VEHICLE_ID] = vehicleid;

			SetVehiclePos(vehicleid, g_hotel_car_park_pos[hotelid][free_slot][HC_POS_X], g_hotel_car_park_pos[hotelid][free_slot][HC_POS_Y], g_hotel_car_park_pos[hotelid][free_slot][HC_POS_Z]);
			SetVehicleZAngle(vehicleid, g_hotel_car_park_pos[hotelid][free_slot][HC_ANGLE]);

			return 1;
		}
	}
	return 0;
}

stock GetHotelFreePark(hotelid)
{
	new vehicleid, slot = -1;

	for(new idx; idx < sizeof(g_hotel_car_park_pos[]); idx ++)
	{
		vehicleid = g_hotel_car_park_pos[hotelid][idx][HC_VEHICLE_ID];
		if(GetVehicleDistanceFromPoint(vehicleid, g_hotel_car_park_pos[hotelid][idx][HC_POS_X], g_hotel_car_park_pos[hotelid][idx][HC_POS_Y], g_hotel_car_park_pos[hotelid][idx][HC_POS_Z]) >= 8.0) continue;

		slot = idx;
		break;
	}
	return slot;
}

stock GetVehicleDisplayNameByModel(modelid, dest[], size = sizeof dest)
{
	for(new marketid; marketid < sizeof(car_market_data); marketid ++)
	{
		for(new idx; idx < sizeof(car_market_data[]); idx ++)
		{
			if(car_market_data[marketid][idx][CM_MODELID] != modelid) continue;
			if(!car_market_data[marketid][idx][CM_NAME][0]) continue;

			format(dest, size, "%s", car_market_data[marketid][idx][CM_NAME]);
			return 1;
		}
	}

	GetVehicleModelName(modelid, dest);
	return 1;
}

stock SetPlayerSexEx(playerid, sex, bool:save = true)
{
	sex = sex ? 1 : 0;
	SetPlayerData(playerid, P_SEX, sex);
	if(save) UpdatePlayerDatabaseInt(playerid, "sex", sex);
	return 1;
}

stock ShowOwnableCarPass(playerid, vehicleid)
{
	new model_id = GetVehicleData(vehicleid, V_MODELID);

	if(model_id && IsAOwnableCar(vehicleid))
	{
		new fmt_str[300];
		new Float: health;
		new index = GetVehicleData(vehicleid, V_ACTION_ID);

		new description[32], model_name[32];
		GetVehicleDisplayNameByModel(model_id, model_name, sizeof model_name);

		format(description, sizeof description, "{0099FF}Документы на ТС №%d", GetOwnableCarData(index, OC_SQL_ID));

		GetVehicleHealth(vehicleid, health);

		format
		(
			fmt_str, sizeof fmt_str,
			"{FFFFFF}Название:\t\t{3399FF}%s\n\n"\
			"{FFFFFF}Модель:\t\t{3399FF}%d\n"\
			"{FFFFFF}Состояние:\t\t{3399FF}%d\n"\
			"{FFFFFF}Пробег:\t\t{3399FF}%07i\n"\
			"{FFFFFF}Цвет:\t\t\t{3399FF}ID %d, %d\n"\
			"{FFFFFF}Гос. стоимость:\t{3399FF}%d руб\n"\
			"{FFFFFF}Номерные знаки:\t{3399FF}%s",
			model_name,
			model_id,
			floatround(health),
			floatround(GetVehicleData(vehicleid, V_MILEAGE), floatround_ceil),
			GetOwnableCarData(index, OC_COLOR_1),
			GetOwnableCarData(index, OC_COLOR_2),
			GetVehicleInfo(model_id-400, VI_PRICE),
			GetOwnableCarData(index, OC_NUMBER)
		);
		Dialog(playerid, INVALID_DIALOG_ID, DIALOG_STYLE_MSGBOX, description, fmt_str, "Закрыть", "");

		return 1;
	}
	return 0;
}

stock IsAOwnableCar(vehicleid)
{
	if(IsValidVehicleID(vehicleid))
	{
		if(GetVehicleData(vehicleid, V_ACTION_TYPE) == VEHICLE_ACTION_TYPE_OWNABLE_CAR)
		{
			return 1;
		}
	}
	return 0;
}

stock IsVehicleSeatOccupied(vehicleid, seatid)
{
	foreach(new i : Player)
	{
		if(!IsPlayerConnected(i)) continue;
		else if(!IsPlayerLogged(i)) continue;
		else if(!IsPlayerInVehicle(i, vehicleid)) continue;
		else if(GetPlayerVehicleSeat(i) != seatid) continue;

		return 1;
	}

	return 0;
}

stock IsVehicleOccupied(vehicleid)
{
	foreach(new i : Player)
	{
		if(!IsPlayerInAnyVehicle(i)) continue;

		if(GetPlayerVehicleID(i) == vehicleid)
			return 1;
	}

	return 0;
}

stock IsTrailerAttachedToAnyVehicle(trailerid)
{
	for(new i = 1; i < MAX_VEHICLES; i ++)
	{
		if(!IsValidVehicle(i)) continue;

		if(GetVehicleTrailer(i) == trailerid)
			return 1;
	}

	return 0;
}

stock ShowPlayerHotelRoomPayForRent(playerid)
{
	new hotel_id = GetPlayerInHotelID(playerid);
	new room_id = GetPlayerData(playerid, P_HOUSE_ROOM);

	if(GetPlayerHouse(playerid, HOUSE_TYPE_HOTEL) == hotel_id)
	{
		new rent_days = GetElapsedTime(GetHotelData(hotel_id, room_id, H_RENT_DATE), gettime(), CONVERT_TIME_TO_DAYS);
		if(rent_days < 0)
		{
			rent_days = 0;
		}

		new fmt_str[128];
		format
		(
			fmt_str, sizeof fmt_str,
			"{FFFFFF}Оплаченных дней:\t\t%d из 30\n"\
			"Ежедневная плата:\t\t1000 руб\n\n"\
			"На сколько дней Вы хотите оплатить номер?",
			rent_days
		);
		Dialog(playerid, DIALOG_HOTEL_PAY_FOR_ROOM, DIALOG_STYLE_INPUT, "{66CC99}Оплата проживания в отеле", fmt_str, "Оплатить", "Назад");
	}
}

stock ShowPlayerHotelClientMenu(playerid, hotel_id)
{
	if(GetPlayerHouse(playerid, HOUSE_TYPE_HOTEL) == hotel_id)
	{
		Dialog
		(
			playerid, DIALOG_HOTEL_CLIENT_MENU, DIALOG_STYLE_LIST,
			"{66CC99}Меню клиента",
			"1. Оплатить проживание\n"\
			"2. Информация о транспорте\n"\
			"3. Отметить транспорт на GPS\n"\
			"4. Подогнать транспорт к отелю (1000 руб)\n"\
			"5. Продать транспорт\n"\
			"6. Выселиться из отеля",
			"Выбрать", "Назад"
		);
	}
					else
	{
		SendClientMessage(playerid, 0xCECECEFF, "Вы не проживаете в этой гостинице");
		ShowPlayerHotelDialog(playerid);
	}
}

stock GetHotelFreeRoom(hotelid)
{
	new free_room = -1;
	if(0 <= hotelid <= MAX_HOTELS-1)
	{
		new max_rooms = g_hotel_rooms_loaded[hotelid] / 12;

		for(new idx; idx < max_rooms; idx ++)
		{
			if(IsHotelRoomOwned(hotelid, idx)) continue;

			free_room = idx;
			break;
		}
	}
	return free_room;
}

stock ExitPlayerFromHotelRoom(playerid)
{
	new room_id = GetPlayerData(playerid, P_IN_HOTEL_ROOM);
	if(room_id != -1)
	{
		new hotel_id = GetPlayerInHotelID(playerid);
		if(hotel_id != -1)
		{
			if(IsPlayerInRangeOfPoint(playerid, 1.0, 490.0204, -992.8733, 1002.9255))
			{
				new floor = (room_id / 12) + 1;
				new index = (room_id % 12) / 5;

				SetPlayerPosEx
				(
					playerid,
					g_hotel_room_exit_pos[index][0],
					g_hotel_room_exit_pos[index][1],
					g_hotel_room_exit_pos[index][2],
					180.0,
					floor,
					((hotel_id + 1) * 200) + (floor + 1000)
				);
				SetPlayerData(playerid, P_IN_HOTEL_ROOM, -1);
			}
		}
	}
}

stock EnterPlayerToHotelRoom(playerid, hotel_id, room_id)
{
	if(GetPlayerData(playerid, P_IN_HOTEL_ROOM) == -1)
	{
		if(!GetHotelData(hotel_id, room_id, H_STATUS) || GetPlayerAccountID(playerid) == GetHotelData(hotel_id, room_id, H_OWNER_ID))
		{
			SetPlayerPosEx(playerid, 491.5204, -992.8733, 1002.9255, 0.0, 6, ((hotel_id + 1) * 400) + (room_id + 2000));
			SetPlayerData(playerid, P_IN_HOTEL_ROOM, room_id);

			SetPlayerData(playerid, P_IN_HOTEL_FLOOR, (room_id / 12) + 1);
		}
					else GameTextForPlayer(playerid, "~r~Closed", 2500, 1);
	}
	return 1;
}

stock ShowPlayerHotelFloorsInfo(playerid, hotel_id)
{
	new fmt_str[8 + 1];
	new string[(sizeof fmt_str - 1) * MAX_HOTEL_FLOORS];

	new max_floors = g_hotel_rooms_loaded[hotel_id] / 12;
	for(new idx; idx < max_floors; idx ++)
	{
		format(fmt_str, sizeof fmt_str, "%d этаж\n", idx + 1);
		strcat(string, fmt_str);
	}
	Dialog(playerid, DIALOG_HOTEL_FLOOR_SELECT, DIALOG_STYLE_LIST, "{FFCD00}Выберите этаж", string, "Выбрать", "Отмена");
}

stock ShowPlayerHotelFloorsLift(playerid, hotel_id, floor_id)
{
	new fmt_str[8 + 1];
	new string[(sizeof fmt_str - 1) * MAX_HOTEL_FLOORS];

	new max_floors = g_hotel_rooms_loaded[hotel_id] / 12;
	for(new idx, count; idx <= max_floors; idx ++)
	{
		if(idx == floor_id) continue;
		if(idx)
		{
			format(fmt_str, sizeof fmt_str, "%d этаж\n", idx);
			strcat(string, fmt_str);
		}
					else strcat(string, "Выход\n");

		SetPlayerListitemValue(playerid, count ++, idx);
	}
	Dialog(playerid, DIALOG_HOTEL_FLOOR_LIFT, DIALOG_STYLE_LIST, "{FFCD00}Выберите этаж", string, "Выбрать", "Отмена");
}

stock ShowPlayerHotelFloorInfo(playerid, hotel_id, floor_id)
{
	if(0 <= hotel_id <= MAX_HOTELS-1)
	{
		if(0 <= floor_id <= MAX_HOTEL_FLOORS-1)
		{
			new string[256];
			new fmt_str[45 + 1];

			new rent_time;
			new time = gettime();

			new s_idx = floor_id * 12;
			new e_idx = s_idx + 12;

			string = "Номер\t\tСтатус\t\tОплаченные дни\tПостоялец\n\n{FFFFFF}";
			while(s_idx < e_idx)
			{
				if(IsHotelRoomOwned(hotel_id, s_idx))
				{
					rent_time = GetElapsedTime(GetHotelData(hotel_id, s_idx, H_RENT_DATE), time, CONVERT_TIME_TO_DAYS);
					if(rent_time < 0)
						rent_time = 0;

					format(fmt_str, sizeof fmt_str, "%d\t\t%s\t\t%d\t\t%s\n", (s_idx % 12) + 1, rent_time > 0 ? ("Занят\t") : ("Выселение"), rent_time, GetHotelData(hotel_id, s_idx, H_OWNER_NAME));
				}
					else format(fmt_str, sizeof fmt_str, "%d\t\tСвободен\n", (s_idx % 12) + 1);
				strcat(string, fmt_str);

				s_idx ++;
			}

			format(fmt_str, sizeof fmt_str, "{66CC99}Список номеров на %d этаже", floor_id + 1);
			Dialog(playerid, DIALOG_HOTEL_FLOOR_INFO, DIALOG_STYLE_MSGBOX, fmt_str, string, "Назад", "Закрыть");
		}
	}
}

stock ShowPlayerHotelDialog(playerid)
{
	if(GetPlayerInHotelID(playerid) != -1)
	{
		new businessid = GetPlayerInBiz(playerid);

		Dialog
		(
			playerid, DIALOG_HOTEL, DIALOG_STYLE_LIST,
			GetBusinessData(businessid, B_NAME),
			"1. Список номеров\n"\
			"2. Регистрация\n"\
			"3. Меню клиента",
			"Выбрать", "Закрыть"
		);
	}
}

stock GetPlayerInHotelID(playerid)
{
	new hotel_id = -1;
	new businessid = GetPlayerInBiz(playerid);

	if(businessid != -1)
	{
		if(GetBusinessData(businessid, B_TYPE) == BUSINESS_TYPE_HOTEL)
		{
			switch(businessid)
			{
				case 30:
					hotel_id = 0;

				case 31:
					hotel_id = 1;

				case 32:
					hotel_id = 2;

				default:
					hotel_id = -1;
			}
		}
	}
	return hotel_id;
}

stock EntranceStatusInitAll()
{
	for(new idx; idx < g_entrance_loaded; idx ++)
	{
		CallLocalFunction("EntranceStatusInit", "i", idx);
	}
}

stock UpdateEntrance(entranceid, houses)
{
	new status = (houses >= GetEntranceData(entranceid, E_FLOORS) * 4);

	if(GetEntranceData(entranceid, E_STATUS) != status)
	{
		if(GetEntranceData(entranceid, E_PICKUP_ID))
			DestroyPickup(GetEntranceData(entranceid, E_PICKUP_ID));

		if(IsValidDynamicMapIcon(GetEntranceData(entranceid, E_MAP_ICON)))
			DestroyDynamicMapIcon(GetEntranceData(entranceid, E_MAP_ICON));

		SetEntranceData(entranceid, E_PICKUP_ID, CreatePickup((status ? 1272 : 1273), 23, GetEntranceData(entranceid, E_POS_X), GetEntranceData(entranceid, E_POS_Y), GetEntranceData(entranceid, E_POS_Z), 0, PICKUP_ACTION_TYPE_ENTRANCE_ENT, entranceid));
		SetEntranceData(entranceid, E_MAP_ICON, CreateDynamicMapIcon(GetEntranceData(entranceid, E_POS_X), GetEntranceData(entranceid, E_POS_Y), GetEntranceData(entranceid, E_POS_Z), (status ? 40 : 40), 0, 0, 0, -1, STREAMER_MAP_ICON_SD, MAPICON_LOCAL));

		SetEntranceData(entranceid, E_STATUS, status);
	}
}

stock ShowPlayerEntranceFloorsLift(playerid, entranceid, floor)
{
	new fmt_str[10];
	new string[(sizeof fmt_str) * MAX_ENTRANCE_FLOORS];

	new max_floors = GetEntranceData(entranceid, E_FLOORS) + 1;

	for(new idx, count; idx < max_floors; idx ++)
	{
		if(idx == floor) continue;
		if(idx)
		{
			format(fmt_str, sizeof fmt_str, "%d этаж\n", idx);
			strcat(string, fmt_str);
		}
					else strcat(string, "Подъезд\n");

		SetPlayerListitemValue(playerid, count ++, idx);
	}
	Dialog(playerid, DIALOG_ENTRANCE_LIFT, DIALOG_STYLE_LIST, "{FFCD00}Выберите этаж", string, "Выбрать", "Отмена");
}

stock EnterPlayerToEntrance(playerid, entranceid)
{
	if(GetPlayerInEntrance(playerid) == -1)
	{
		SetPlayerPosEx(playerid, 558.4705, 24.8017, 1049.2731, 357.8067, 1, entranceid + 2500);

		SendClientMessage(playerid, -1, "ЧТО БЫ КУПИТЬ КВАРТИРУ, СНАЧАЛО ИСПОЛЬЗУЙТЕ ЛИФТ, И ВЫБЕРИТЕ ЭТАЖ!");

		SetPlayerInEntranceFloor(playerid, 0);
		SetPlayerInEntrance(playerid, entranceid);
	}
}

stock SetPlayerFactoryDeskUse(playerid, deskid, bool: status)
{
	if(!(0 <= deskid <= sizeof factory_desk-1)) return ;

	if(GetPlayerTempJob(playerid) == TEMP_JOB_FACTORY)
	{
		if(status)
		{
			if(!factory_desk[deskid][FD_USED] && GetPlayerData(playerid, P_FACTORY_USE_DESK) == -1)
			{
				if(GetPlayerTempJobState(playerid) == TEMP_JOB_STATE_FACTORY_CREATE_P)
				{
					factory_desk[deskid][FD_USED] = true;

					// static const
					//	p_object_id[3] = {1954, 2926, 1718};

					// static const
					//	Float: p_object_z[3] = {0.09, 0.0, 0.06};

					// new rand = random(sizeof(p_object_id));
					// new Float: x, Float: y, Float: z;
					// GetPlayerPos(playerid, x, y, z);

					new Float: angle;

					new take_metall = GetPVarInt(playerid, "factory_take_metall");
					new factory_fuel = GetRepositoryData(REPOSITORY_TYPE_FACTORY, REPOSITORY_ACTION_FACTORY_FUEL, R_AMOUNT);

					SetPlayerData(playerid, P_FACTORY_USE_DESK, deskid);
					TogglePlayerFactoryCP(playerid, false);

					if(!((deskid / 4) % 2))
					{
						angle = 180.0;
					}
					else angle = 0.0;
					SetPlayerFacingAngle(playerid, angle);

					//factory_object[playerid] = CreateDynamicObject(p_object_id[rand], x, y, 1044.08 + p_object_z[rand], 0.0, 0.0, angle + 180.0);
					ApplyAnimationEx(playerid, "OTB", "betslp_loop", 4.1, 1, 0, 0, 1, 20_000, 0, USE_ANIM_TYPE_NONE - 1);

				//	SetPlayerAttachedObject(playerid, A_OBJECT_SLOT_HAND, 18644, A_OBJECT_BONE_RIGHT_HAND, 0.06, 0.02, 0.0, 30.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0);
				//	SetPlayerAttachedObject(playerid, A_OBJECT_SLOT_HAND + 1, 18635, A_OBJECT_BONE_LEFT_HAND, 0.1, 0.06, -0.1, 180.0, 80.0, 0.0, 1.0, 1.0, 1.0, 0);

					SetPlayerTempJobState(playerid, TEMP_JOB_STATE_FACTORY_CREATED);
					SetTimerEx("CreateFactoryProd", 18_000, false, "i", playerid);

					SetRepositoryData(REPOSITORY_TYPE_FACTORY, REPOSITORY_ACTION_FACTORY_FUEL, R_AMOUNT, factory_fuel - (take_metall * 6));
					UpdateRepository(REPOSITORY_TYPE_FACTORY, REPOSITORY_ACTION_FACTORY_FUEL);
				}
					else
				{
					if(GetPlayerTempJobState(playerid) != TEMP_JOB_STATE_FACTORY_PUT_PROD)
						SendClientMessage(playerid, 0x999999FF, "Возьмите Материалы у раздаточного стола");
				}
			}
		}
					else
		{
			if(factory_desk[deskid][FD_USED])
			{
				if(GetPlayerData(playerid, P_FACTORY_USE_DESK) == deskid)
				{
					TogglePlayerFactoryCP(playerid, true);
					SetPlayerData(playerid, P_FACTORY_USE_DESK, -1);

					/*
					if(IsValidDynamicObject(factory_object[playerid]))
					{
						DestroyDynamicObject(factory_object[playerid]);
						factory_object[playerid] = -1;
					}
					*/
					factory_desk[deskid][FD_USED] = false;
				}
			}
		}
		UpdateFactoryDesk(deskid);
	}
}

stock AddBan(user_id, time, days, ip[], description[], admin_name[])
{
	new query[512];
	new c_time = time-(time % 86400);
	new unban_time = c_time + (days * 86400);
	new bool:ok = true;

	mysql_format(mysql, query, sizeof query, "INSERT INTO ban_list (user_id,time,ban_time,ip,description,admin) VALUES (%d,%d,%d,'%e','%e','%e')", user_id, c_time, unban_time, ip, description, admin_name);
	mysql_query(mysql, query, false);

	if(mysql_errno())
	{
		ok = false;
		printf("[BAN][ERROR] ban_list insert failed: uid=%d errno=%d query=%s", user_id, mysql_errno(), query);
	}

	if(user_id > 0)
	{
		mysql_format(mysql, query, sizeof query,
			"INSERT INTO listban (acc_id, player_name, admin_name, reason, ban_time, unban_time) VALUES (%d, IFNULL((SELECT name FROM accounts WHERE id=%d LIMIT 1), 'Unknown'), '%e', '%e', %d, %d) ON DUPLICATE KEY UPDATE player_name = VALUES(player_name), admin_name = VALUES(admin_name), reason = VALUES(reason), ban_time = VALUES(ban_time), unban_time = VALUES(unban_time)",
			user_id, user_id, admin_name, description, c_time, unban_time
		);
		mysql_query(mysql, query, false);

		if(mysql_errno())
		{
			ok = false;
			printf("[BAN][ERROR] listban insert failed: uid=%d errno=%d query=%s", user_id, mysql_errno(), query);
		}
	}

	return ok;
}

stock GivePlayerDrinkItem(playerid, itemid)
{
	new action_id = -1;
	switch(itemid+1)
	{
		case 1: // Лимонад
		{
			action_id = 23;
		}
		case 2, 6..7: // Пиво, Коньяк, Виски
		{
			action_id = 20;
		}
		case 3..5, 8: // Вино, Шампанское, Водка, Абсент
		{
			action_id = 22;
		}
		case 9: // Закуска
		{
			if(GetPlayerData(playerid, P_DRINK_STEP))
			{
				SetPlayerData(playerid, P_DRINK_STEP, 0);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			}

		//	SetPlayerAttachedObject(playerid, A_OBJECT_SLOT_HAND, 10213, A_OBJECT_BONE_RIGHT_HAND, 0.08, 0.05, 0.06, 180.0, 270.0, -30.0, 1.0, 1.0, 1.0, 0, 0);
			SetPlayerData(playerid, P_SNACK, true);
		}
		case 10: // Сигара
		{
			action_id = 21;
		}
	}
	if(action_id != -1)
	{
		if(GetPlayerData(playerid, P_SNACK))
		{
			SetPlayerData(playerid, P_SNACK, false);
		//	T_RemovePlayerAttachedObject(playerid, A_OBJECT_SLOT_HAND);
		}

		SetPlayerData(playerid, P_DRINK_STEP, 7);
		SetPlayerSpecialAction(playerid, action_id);
	}
	return 1;
}

stock FactoryPlayerDrop(playerid, bool: reject = true)
{
	if(GetPlayerTempJob(playerid) == TEMP_JOB_FACTORY)
	{
		if(reject)
		{
			if(GetPlayerTempJobState(playerid) != TEMP_JOB_STATE_FACTORY_CREATED) return ;

			SetPlayerChatBubble(playerid, "Брак", 0xFF0000FF, 10.0, 1500);
			ApplyAnimationEx(playerid, "OTB", "WTCHRACE_LOSE", 4.1, 0, 0, 0, 0, 0, 0, USE_ANIM_TYPE_NONE);
		}
					else
		{
			if(GetPlayerTempJobState(playerid) != TEMP_JOB_STATE_FACTORY_DROP_P) return ;
			SetPlayerTempJobCheckAnim(playerid, false);

			//RemovePlayerAttachedObject(playerid, A_OBJECT_SLOT_FOREARM);
			SetPlayerFactoryDeskUse(playerid, GetPlayerData(playerid, P_FACTORY_USE_DESK), false);

			ApplyAnimationEx(playerid, "CARRY", "crry_prtial", 4.1, 0, 0, 0, 0, 1, 0, USE_ANIM_TYPE_NONE);
		}

		new bad_prods = GetPVarInt(playerid, "factory_bad_prods") + 1;
		SetPVarInt(playerid, "factory_bad_prods", bad_prods);

		SetPlayerTempJobState(playerid, TEMP_JOB_STATE_FACTORY_TAKE_MET);
	}
}

new bool:g_clothing_shop_ptd_created[MAX_PLAYERS];

stock ShowPlayerClothingShopPanel(playerid)
{
	new businessid = GetPlayerInBiz(playerid);
	if(!IsPlayerConnected(playerid) || businessid < 0 || businessid >= g_business_loaded) return 0;
	if(GetBusinessData(businessid, B_TYPE) != BUSINESS_TYPE_CLOTHING_SHOP) return 0;
	if(GetPlayerSelectSkin(playerid) != -1) return 1;

	if(GetPlayerTeamEx(playerid) <= 0)
	{
		// Clothing preview from mode v0.3: it uses the common selector and
		// does not depend on launcher-only shop_clothes TXD textures.
		SetPlayerSelectClothingSkin(playerid, 0);
		SetPlayerPosEx(playerid, 1200.399902, 607.876281, 1349.309448, 184.824386, 1, playerid + 32, false);
		SetPlayerCameraPos(playerid, 1201.510253, 604.738281, 1350.530395);
		SetPlayerCameraLookAt(playerid, 1193.910253, 630.0, 1342.530395);
		ShowPlayerSelectPanel(playerid, SELECT_PANEL_TYPE_CLOTHING);
		TogglePlayerControllable(playerid, false);
	}
	else SendClientMessage(playerid, 0xCECECEFF, "Вы состоите в организации, купить новую внешность нельзя");
	return 1;
}

stock ExitPlayerClothingShopPanel(playerid)
{
	new in_biz = GetPlayerInBiz(playerid);
	if(in_biz != -1)
	{
		// Сначала снимаем состояние магазина, чтобы обработчик INVALID_TEXT_DRAW
		// не включил выбор повторно на мобильном клиенте.
		HidePlayerSelectPanel(playerid);
		CancelSelectTextDraw(playerid);
		SetPlayerData(playerid, P_USE_SELECT_PANEL, SELECT_PANEL_TYPE_NONE);
		SetPlayerData(playerid, P_SELECT_SKIN, -1);

		SetPlayerSkinInit(playerid);

		PlayerTextDrawSetString(playerid, price_select_TD[playerid][0], "exit...");
		SetTimerEx("HidePlayerSelectPanelPriceTimer", 1000, false, "i", playerid);
		
		HideClothesShopTextDraws(playerid);

		SetPlayerPosEx
		(
			playerid,
			GetBusinessData(in_biz, B_EXIT_POS_X),
			GetBusinessData(in_biz, B_EXIT_POS_Y),
			GetBusinessData(in_biz, B_EXIT_POS_Z),
			GetBusinessData(in_biz, B_EXIT_ANGLE),
			0,
			0
		);
		SetPlayerInBiz(playerid, -1);

		ClearAnimations(playerid, 1);
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
		TogglePlayerControllable(playerid, true);
		SetCameraBehindPlayer(playerid);

		// Android-клиент закрывает режим TextDraw не сразу. Повторный сброс
		// после завершения callback убирает зажатое движение вперёд и камеру.
		SetTimerEx("ClothingShopRestoreControl", 350, false, "i", playerid);

	}
	return 1;
}

forward ClothingShopRestoreControl(playerid);
public ClothingShopRestoreControl(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	CancelSelectTextDraw(playerid);
	SetPlayerData(playerid, P_USE_SELECT_PANEL, SELECT_PANEL_TYPE_NONE);
	SetPlayerData(playerid, P_SELECT_SKIN, -1);
	ClearAnimations(playerid, 1);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
	TogglePlayerControllable(playerid, true);
	SetCameraBehindPlayer(playerid);
	return 1;
}

public: BuySkinPTDUpdate(playerid)
{
    new select_skin = GetPlayerSelectSkin(playerid);
    if(!g_clothing_shop_ptd_created[playerid] || select_skin < 0 || select_skin >= sizeof g_business_clothing_skins[])
        return 0;
    
	new price = g_business_clothing_skins[GetPlayerSex(playerid)][select_skin][1];

	new fmt_str[50];
	
	PlayerTextDrawHide(playerid, shop_clothes_PTD[playerid][0]);
	
	PlayerTextDrawShow(playerid, shop_clothes_PTD[playerid][0]);

    format(fmt_str, sizeof fmt_str, "%d РУБ", price);
	PlayerTextDrawSetString(playerid, shop_clothes_PTD[playerid][0], fmt_str);
	
	return 1;
}

stock HidePlayerSelectPanelPrice(playerid)
{
	for(new idx; idx < sizeof price_select_TD[]; idx ++)
	{
		if(price_select_TD[playerid][idx] != PlayerText: -1)
		{
			PlayerTextDrawHide(playerid, price_select_TD[playerid][idx]);
			PlayerTextDrawDestroy(playerid, price_select_TD[playerid][idx]);

			price_select_TD[playerid][idx] = PlayerText: -1;
		}
	}
}

stock SetPlayerSelectClothingSkin(playerid, index = 0)
{
	new sex = GetPlayerSex(playerid);
	if(sex < 0 || sex >= sizeof g_business_clothing_skins) sex = 0;
	if(index < 0 || index >= sizeof g_business_clothing_skins[]) index = 0;

	SetPlayerSelectSkin(playerid, index, g_business_clothing_skins[sex][index][0]);
}

/*stock CreateTeleportObjects(playerid)
{
	for(new idx; idx < 2; idx ++)
	{
		if(g_teleport_object[playerid][idx] == -1)
		{
			g_teleport_object[playerid][idx] = CreatePlayerObject(playerid, 3034, 0.0, 0.0, -2000.0, 0.0, 0.0, 0.0);
		}
	}
}

stock DestroyTeleportObjects(playerid)
{
	for(new idx; idx < 2; idx ++)
	{
		if(g_teleport_object[playerid][idx] != -1)
		{
			DestroyPlayerObject(playerid, g_teleport_object[playerid][idx]);
			g_teleport_object[playerid][idx] = -1;
		}
	}
}

stock PlayerTeleportInit(playerid, Float: x, Float: y, Float: z, Float: angle)
{
	new Float: dist = -0.862;
	angle += 90.0; //прибавление угла; можно и отнимать

	for(new idx = 2; idx --; )
	{
		SetPlayerObjectPos(playerid, g_teleport_object[playerid][idx], x + dist * -floatsin(angle, degrees), y + dist * floatcos(angle, degrees), z - 1.02);
		SetPlayerObjectRot(playerid, g_teleport_object[playerid][idx], 90.0, 90.0, angle - 90.0);

		dist = floatabs(dist);
	}
}*/

stock GetOwnableCarBySqlID(sql_id, buffer[] = {0, 0, 0})
{
	buffer[2] = INVALID_VEHICLE_ID;
	for(buffer[0] = 1; buffer[0] < MAX_VEHICLES; buffer[0] ++)
	{
		if(!IsAOwnableCar(buffer[0])) continue;
		buffer[1] = GetVehicleData(buffer[0], V_ACTION_ID);

		if(GetOwnableCarData(buffer[1], OC_SQL_ID) != sql_id) continue;

		buffer[2] = buffer[0];
		break;
	}
	return buffer[2];
}

stock SaveOwnableCarUnloadPosition(sql_id, Float:x, Float:y, Float:z, Float:a)
{
    if(sql_id <= 0) return 0;

    new slot = -1;
    for(new i = 0; i < MAX_OWNABLE_CARS; i++)
    {
        if(!g_ownable_unload_pos_set[i])
        {
            if(slot == -1) slot = i;
            continue;
        }

        if(g_ownable_unload_sql[i] == sql_id)
        {
            slot = i;
            break;
        }
    }

    if(slot == -1) slot = sql_id % MAX_OWNABLE_CARS;

    g_ownable_unload_pos_set[slot] = true;
    g_ownable_unload_sql[slot] = sql_id;
    g_ownable_unload_pos[slot][0] = x;
    g_ownable_unload_pos[slot][1] = y;
    g_ownable_unload_pos[slot][2] = z;
    g_ownable_unload_pos[slot][3] = a;
    return 1;
}

stock bool:GetOwnableCarUnloadPosition(sql_id, &Float:x, &Float:y, &Float:z, &Float:a)
{
    if(sql_id <= 0) return false;

    for(new i = 0; i < MAX_OWNABLE_CARS; i++)
    {
        if(!g_ownable_unload_pos_set[i]) continue;
        if(g_ownable_unload_sql[i] != sql_id) continue;

        x = g_ownable_unload_pos[i][0];
        y = g_ownable_unload_pos[i][1];
        z = g_ownable_unload_pos[i][2];
        a = g_ownable_unload_pos[i][3];
        return true;
    }
    return false;
}

stock ResetOwnableCarUnloadPosition(sql_id)
{
    if(sql_id <= 0) return 0;

    for(new i = 0; i < MAX_OWNABLE_CARS; i++)
    {
        if(!g_ownable_unload_pos_set[i]) continue;
        if(g_ownable_unload_sql[i] != sql_id) continue;

        g_ownable_unload_pos_set[i] = false;
        g_ownable_unload_sql[i] = 0;
        g_ownable_unload_pos[i][0] = 0.0;
        g_ownable_unload_pos[i][1] = 0.0;
        g_ownable_unload_pos[i][2] = 0.0;
        g_ownable_unload_pos[i][3] = 0.0;
        return 1;
    }
    return 0;
}

stock bool:GetOwnableCarParkPosition(sql_id, &Float:x, &Float:y, &Float:z, &Float:a)
{
    if(sql_id <= 0) return false;

    new vehicleid = GetOwnableCarBySqlID(sql_id);
    if(vehicleid != INVALID_VEHICLE_ID)
    {
        new index = GetVehicleData(vehicleid, V_ACTION_ID);
        if(index >= 0)
        {
            x = GetOwnableCarData(index, OC_POS_X);
            y = GetOwnableCarData(index, OC_POS_Y);
            z = GetOwnableCarData(index, OC_POS_Z);
            a = GetOwnableCarData(index, OC_ANGLE);
            return true;
        }
    }

    new query[96], Cache:result;
    mysql_format(mysql, query, sizeof query, "SELECT pos_x, pos_y, pos_z, angle FROM ownable_cars WHERE id=%d LIMIT 1", sql_id);
    result = mysql_query(mysql, query, true);

    if(!cache_num_rows(result))
    {
        cache_delete(result);
        return false;
    }

    x = cache_get_row_float(0, 0);
    y = cache_get_row_float(0, 1);
    z = cache_get_row_float(0, 2);
    a = cache_get_row_float(0, 3);
    cache_delete(result);
    return true;
}

stock ResetOwnableCarParkPosition(playerid, sql_id)
{
    if(sql_id <= 0) return 0;

    new query[180];
    mysql_format(mysql, query, sizeof query,
        "UPDATE ownable_cars SET pos_x=%f,pos_y=%f,pos_z=%f,angle=%f WHERE id=%d AND owner_id=%d LIMIT 1",
        g_ownable_default_park_pos[0],
        g_ownable_default_park_pos[1],
        g_ownable_default_park_pos[2],
        g_ownable_default_park_pos[3],
        sql_id,
        GetPlayerAccountID(playerid)
    );
    mysql_query(mysql, query, false);
    if(mysql_errno()) return 0;

    new vehicleid = GetOwnableCarBySqlID(sql_id);
    if(vehicleid != INVALID_VEHICLE_ID)
    {
        new index = GetVehicleData(vehicleid, V_ACTION_ID);
        if(index >= 0)
        {
            SetOwnableCarData(index, OC_POS_X, g_ownable_default_park_pos[0]);
            SetOwnableCarData(index, OC_POS_Y, g_ownable_default_park_pos[1]);
            SetOwnableCarData(index, OC_POS_Z, g_ownable_default_park_pos[2]);
            SetOwnableCarData(index, OC_ANGLE, g_ownable_default_park_pos[3]);
        }
    }

    ResetOwnableCarUnloadPosition(sql_id);
    return 1;
}


