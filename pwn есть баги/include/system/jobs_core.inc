public: SetPlayerLoaderJobLoad(playerid, epoch) // брать груз
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(epoch != g_BRAuthEpoch[playerid] || !IsPlayerLogged(playerid)) return 0;
	if(GetPlayerTempJob(playerid) == TEMP_JOB_LOADER)
	{
		if(GetPlayerTempJobState(playerid) == TEMP_JOB_STATE_LOADER_LOAD)
		{
			//new rand = random(sizeof loader_job_attach_obj);

			ApplyAnimationEx(playerid, "CARRY", "crry_prtial", 4.1, 1, 1, 1, 1, 1, 0);
		//	SetPlayerAttachedObject(playerid, A_OBJECT_SLOT_HAND, loader_job_attach_obj[rand][L_OBJECT], A_OBJECT_BONE_RIGHT_HAND, loader_job_attach_obj[rand][L_POS_X], loader_job_attach_obj[rand][L_POS_Y], loader_job_attach_obj[rand][L_POS_Z], loader_job_attach_obj[rand][L_ROT_X], loader_job_attach_obj[rand][L_ROT_Y], loader_job_attach_obj[rand][L_ROT_Z], 1.0, 1.0, 1.0, 0);

			SetPlayerLoaderJobUnLoadCP(playerid);

//			if(!random(6))
//				SetPlayerTempJobState(playerid, TEMP_JOB_STATE_LOADER_DROP_LOAD);
		}
	}
	return 1;
}

stock Mine_ClearCarry(playerid)
{
    new bool:active = g_mineCarrySlot[playerid] != -1 || g_mineExtractionPending[playerid];
    g_mineCarryTicket[playerid]++;
    g_mineExtractionPending[playerid] = false;
    if(g_mineCarrySlot[playerid] != -1)
    {
        RemovePlayerAttachedObject(playerid, g_mineCarrySlot[playerid]);
        g_mineCarrySlot[playerid] = -1;
    }
    if(active)
    {
        if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CARRY)
            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        SetPlayerData(playerid, P_USE_ANIM_TYPE, USE_ANIM_TYPE_NONE);
        ClearAnimations(playerid);
    }
    return 1;
}

public: SetPlayerMinerJobTakeOre(playerid, ticket, epoch)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(epoch != g_BRAuthEpoch[playerid] || ticket != g_mineCarryTicket[playerid]) return 1;
    if(!g_mineExtractionPending[playerid]) return 1;
    if(GetPlayerTempJob(playerid) != TEMP_JOB_MINER ||
        GetPlayerTempJobState(playerid) != TEMP_JOB_STATE_MINER_LOAD ||
        GetPlayerState(playerid) != PLAYER_STATE_ONFOOT ||
        !IsPlayerInRangeOfPoint(playerid, 3.0, GetPlayerCPInfo(playerid, CP_POS_X),
            GetPlayerCPInfo(playerid, CP_POS_Y), GetPlayerCPInfo(playerid, CP_POS_Z)))
    {
        Mine_ClearCarry(playerid);
        if(GetPlayerTempJob(playerid) == TEMP_JOB_MINER &&
            GetPlayerTempJobState(playerid) == TEMP_JOB_STATE_MINER_LOAD)
            SetPlayerMinerJobLoadCP(playerid);
        return 1;
    }

    new slot = -1;
    for(new i; i < 10; i++)
    {
        if(!IsPlayerAttachedObjectSlotUsed(playerid, i)) { slot = i; break; }
    }
    if(slot == -1)
    {
        Mine_ClearCarry(playerid);
        SetPlayerMinerJobLoadCP(playerid);
        return SendClientMessage(playerid, -1, "Освободите один слот аксессуаров для переноски руды.");
    }
    // Original mine rock model and hand attachment, not a new client model.
    if(!SetPlayerAttachedObject(playerid, slot, 905, A_OBJECT_BONE_LEFT_HAND,
        0.1, 0.05, -0.1, 0.0, 90.0, 0.0, 0.2, 0.2, 0.2))
    {
        Mine_ClearCarry(playerid);
        SetPlayerMinerJobLoadCP(playerid);
        return 1;
    }
    g_mineCarrySlot[playerid] = slot;
    g_mineExtractionPending[playerid] = false;
    ClearAnimations(playerid);
    ApplyAnimationEx(playerid, "CARRY", "crry_prtial", 4.1, 1, 0, 0, 0, 0, 1);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
    SetPlayerMinerJobUnLoadCP(playerid);
    return 1;
}

public: SetPlayerLumberJackTakeWood(playerid, epoch)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    if(epoch != g_BRAuthEpoch[playerid] || !IsPlayerLogged(playerid)) return 0;
    if(GetPlayerTempJobState(playerid) != TEMP_JOB_STATE_LUMBERJACK_CHOP) return 0;
	if(GetPlayerTempJob(playerid) == TEMP_JOB_LUMBERJACK)
	{
		SetPlayerTempJobState(playerid, TEMP_JOB_STATE_LUMBERJACK_PUT);

		SetPlayerLumberUnJackChopCP(playerid);

		RemovePlayerAttachedObject(playerid, A_OBJECT_SLOT_HAND);
		ApplyAnimation(playerid, "CARRY", "liftup", 4.1, 1, 0, 1, 0, 1500, 0);

		ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.1, 1, 0, 1, 1, 1);
	//	SetPlayerAttachedObject(playerid, A_OBJECT_SLOT_HAND, 1463, A_OBJECT_BONE_RIGHT_HAND, 0.006, 0.138, -0.192, -109.8, -2.2, -102.9, 0.505, 0.328, 0.57);
	}
	return 1;
}

public: LumberJackPlayerDrop(playerid, bool: message)
{
	SetPlayerTempJobState(playerid, TEMP_JOB_STATE_LUMBERJACK_CHOP);

	if(message)
		SendClientMessage(playerid, 0xFF6600FF, "Вы уронили дрова");

	RemovePlayerAttachedObject(playerid, A_OBJECT_SLOT_HAND);
//	SetPlayerAttachedObject(playerid, A_OBJECT_SLOT_HAND, 326, A_OBJECT_BONE_RIGHT_HAND, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0);

	ApplyAnimationEx(playerid, "MISC", "Idle_Chat_02", 4.1, 0, 0, 0, 0, 1, 0);

	SetPlayerLumberJackChopCP(playerid);

	return 1;
}

public: MinerCarriageUpdate(carriageid)
{
	if(miner_carriage[carriageid][MC_STATUS] && !miner_carriage[carriageid][MC_IN_MOVE])
	{
		if(miner_carriage[carriageid][MC_ORE_COUNT] >= 500)
		{
			new fmt_str[55],
				items = GetRepositoryData(REPOSITORY_TYPE_MINER, REPOSITORY_ACTION_MINER_ORE, R_AMOUNT);

			miner_carriage[carriageid][MC_ORE_COUNT] -= 500;

			SetRepositoryData(REPOSITORY_TYPE_MINER, REPOSITORY_ACTION_MINER_ORE, R_AMOUNT, items + 500);
			UpdateRepository(REPOSITORY_TYPE_MINER, REPOSITORY_ACTION_MINER_ORE);

			format(fmt_str, sizeof fmt_str, "Разгрузка\n\n{FFCC00}Количество руды\n%d / 10000 кг", miner_carriage[carriageid][MC_ORE_COUNT]);
			UpdateDynamic3DTextLabelText(miner_carriage[carriageid][MC_LABEL], 0x66CCFFFF, fmt_str);
		}
					else if(miner_carriage[carriageid][MC_ORE_COUNT] <= 0)
		{
			miner_carriage[carriageid][MC_IN_MOVE] = true;

			SetTimerEx("MinerCarriageMove", 7_000, false, "i", carriageid);
			UpdateDynamic3DTextLabelText(miner_carriage[carriageid][MC_LABEL], 0xFFFF00FF, "Ожидание...");
		}
	}
}

public: MinerCarriageMove(carriageid)
{
	new bool: status = miner_carriage[carriageid][MC_STATUS];
	if(status)
	{
	//	MoveDynamicObject(miner_carriage[carriageid][MC_OBJECT_ID], miner_carriage[carriageid][MC_START_POS_X], miner_carriage[carriageid][MC_START_POS_Y], miner_carriage[carriageid][MC_START_POS_Z], 10.0, 0.0, 0.0, 90.0);
	}
					else
	{
	//	MoveDynamicObject(miner_carriage[carriageid][MC_OBJECT_ID], miner_carriage[carriageid][MC_END_POS_X], miner_carriage[carriageid][MC_END_POS_Y], miner_carriage[carriageid][MC_END_POS_Z], 10.0, 0.0, 0.0, 90.0);
	}

	DestroyDynamic3DTextLabel(miner_carriage[carriageid][MC_LABEL]);

	miner_carriage[carriageid][MC_IN_MOVE] = true;

	miner_carriage[carriageid][MC_STATUS] = (status ^ true);
}

public: MinerCarriageSetState(carriageid)
{
	if(miner_carriage[carriageid][MC_STATUS]) // вагонетка
	{
		miner_carriage[carriageid][MC_LABEL] = CreateDynamic3DTextLabel("Разгрузка\n\n{FFCC00}Количество руды\n10000 / 10000 кг", 0x66CCFFFF, -2548.1213, 294.7194, -15.4815 + 3.0, 10.0);
		miner_carriage[carriageid][MC_ORE_COUNT] = 10_000;
	}
					else
	{
		miner_carriage[carriageid][MC_LABEL] = CreateDynamic3DTextLabel("Загрузка\n\n{FFCC00}Количество руды\n0 / 10000 кг", 0x66CC00FF, -2375.1228, 294.7194, -15.4815 + 3.0, 10.0);
		miner_carriage[carriageid][MC_PICKUP_ID] = CreatePickup(1239, 23, -2375.1228, 296.8900, -15.7689, -1, PICKUP_ACTION_TYPE_MINER_CARRI);
		miner_carriage[carriageid][MC_ORE_COUNT] = 0;
	}
}

public: NextBusRouteCP(playerid)
{
	if(GetPlayerJob(playerid) == JOB_BUS_DRIVER)
	{
		if(IsPlayerInJob(playerid))
		{
			new route_id = GetPlayerData(playerid, P_BUS_ROUTE);
			new route_step = GetPlayerData(playerid, P_BUS_ROUTE_STEP);
			new next_cp = route_step + 1;

			if(g_bus_route[route_id][next_cp][BRS_POS_X] == 0.0)
			{
				next_cp = 0;
			}

			SetPlayerRaceCheckpoint
			(
				playerid,
				g_bus_route[route_id][route_step][BRS_STOP],
				g_bus_route[route_id][route_step][BRS_POS_X],
				g_bus_route[route_id][route_step][BRS_POS_Y],
				g_bus_route[route_id][route_step][BRS_POS_Z],
				g_bus_route[route_id][next_cp][BRS_POS_X],
				g_bus_route[route_id][next_cp][BRS_POS_Y],
				g_bus_route[route_id][next_cp][BRS_POS_Z],
				4.0,
				RCP_ACTION_TYPE_BUS_ROUTE
			);
			AddPlayerData(playerid, P_BUS_ROUTE_STEP, +, 1);
		}
	}
}

public: StartPlayerJob(playerid, jobid)
{
	if(GetPlayerJob(playerid) == jobid)
	{
		//if(!IsPlayerInJob(playerid))
		//{
			new job_car = GetPlayerJobCar(playerid);
			//if(IsPlayerInVehicle(playerid, job_car))
			//{
				new action_type = GetVehicleData(job_car, V_ACTION_TYPE);
				new car_type = (action_type - VEHICLE_ACTION_TYPE_BUS_DRIVER) + 1;

				//if(jobid == car_type)
				//{
					SetPlayerJobLoadItems(playerid, 0);

					SetPlayerData(playerid, P_JOB_WAGE, 0);
					SetPlayerData(playerid, P_IN_JOB, true);
					SetVehicleData(job_car, V_ACTION_ID, true);

					new fmt_str[128];

					switch(jobid)
					{
						case JOB_BUS_DRIVER:
						{
							new route_id = GetPlayerData(playerid, P_BUS_ROUTE);

							format(fmt_str, sizeof fmt_str, "%s\n{FFFFFF}Стоимость проезда: {FF9900}%d руб", g_bus_routes[route_id][BR_NAME], GetPlayerData(playerid, P_JOB_TARIFF));
							CreateVehicleLabel(job_car, fmt_str, g_bus_routes[route_id][BR_COLOR], 0.0, 0.0, 2.6, 45.0);

							format(fmt_str, sizeof fmt_str, "начал работу водителя автобуса на маршруте %s", g_bus_routes[route_id][BR_NAME]);
							Action(playerid, fmt_str, _, false);

							NextBusRouteCP(playerid);

							SetPVarFloat(playerid, "car_damage", 1000.0);
						}
						case 6:
						{
							format(fmt_str, sizeof fmt_str, "%s{FFFF00}Тариф: %d руб", GetPlayerData(playerid, P_JOB_SERVICE_NAME), GetPlayerData(playerid, P_JOB_TARIFF));
							CreateVehicleLabel(job_car, fmt_str, 0x3399FFFF, 0.0, 0.0, 1.4, 25.0);

							Action(playerid, "начал работу таксиста", _, false);
						}
						case JOB_UNUSED_3:
						{
							SetPlayerData(playerid, P_MECHANIC_FILL_PAY, 0);
							SetPlayerData(playerid, P_MECHANIC_REPAIR_PAY, 0);

							format(fmt_str, sizeof fmt_str, "%s{FFFFFF}Автомеханик\n{999999}Нет топлива", GetPlayerData(playerid, P_JOB_SERVICE_NAME));
							CreateVehicleLabel(job_car, fmt_str, 0xCC9900FF, 0.0, 0.0, 2.0, 25.0);

							Action(playerid, "начал работу автомеханика", _, false);
						}
						case JOB_TRUCKER:
						{
							if(!GetTruckIndex(job_car))
							{
								fmt_str = "Служба\n{FFFFFF}Доставки продуктов";

								SendClientMessage(playerid, 0x66CC00FF, "Используйте {3399FF}/bizlist {66CC00}чтобы посмотреть заказы от владельцев бизнесов");
								Action(playerid, "начал работу развозчика продуктов", _, false);
							}
					else
							{
								fmt_str = "Служба\n{FFFFFF}Доставки топлива";

								SendClientMessage(playerid, 0x66CC00FF, "Используйте {3399FF}/fuellist {66CC00}для просмотра заказов от владельцев АЗС");
								Action(playerid, "начал работу развозчика топлива", _, false);
							}

							CreateVehicleLabel(job_car, fmt_str, 0x3399FFFF, 0.0, 2.1, 2.1, 20.0);
						}
					//}
				//}
			//}
		}
	}
	return 1;
}

public: EndPlayerJob(playerid)
{
	if(IsPlayerInJob(playerid))
	{
		new vehicleid = GetPlayerJobCar(playerid);
		if(vehicleid != INVALID_VEHICLE_ID)
		{
			SetVehicleToRespawn(vehicleid);
			SetPlayerData(playerid, P_JOB_CAR, INVALID_VEHICLE_ID);
		}
	}
	KillEndJobTimer(playerid);

	new fmt_str[128];
	new wage = GetPlayerJobWage(playerid);
	new items = GetPlayerJobLoadItems(playerid);

	SetPlayerData(playerid, P_JOB_WAGE, 0);
	SendClientMessage(playerid, 0xFFFF00FF, "Рабочий день завершен!");

	SetPlayerData(playerid, P_IN_JOB, false);
	switch(GetPlayerData(playerid, P_JOB))
	{
		case JOB_BUS_DRIVER:
		{
			new Float: health = GetPVarFloat(playerid, "car_damage");
			new repair_sum;

			if(health < 1000.0)
				repair_sum = (floatround((1000.0 - health) + float(random(100)+10))) / 3;

			DisablePlayerRaceCheckpoint(playerid);

			format(fmt_str, sizeof fmt_str, "Заработано: {00FF00}%d руб", wage + (items * GetPlayerData(playerid, P_JOB_TARIFF)));
			SendClientMessage(playerid, 0xFFFFFFFF, fmt_str);

			format(fmt_str, sizeof fmt_str, "Количество пассажиров: {00FF00}%d{FFFFFF}. Куплено билетов на {00FF00}%d руб", items, items * GetPlayerData(playerid, P_JOB_TARIFF));
			SendClientMessage(playerid, 0xFFFFFFFF, fmt_str);

			format(fmt_str, sizeof fmt_str, "За ремонт автобуса: {FF6600}-%d руб", repair_sum);
			SendClientMessage(playerid, 0xFFFFFFFF, fmt_str);

			if(repair_sum < wage)
				wage -= repair_sum;

			//GiveMoney(playerid, salary, "Зарплата Водителя Маршрутки", true, true);
		}
		case 6:
		{
			DisablePlayerRaceCheckpoint(playerid);
			wage = items * GetPlayerData(playerid, P_JOB_TARIFF);

			format(fmt_str, sizeof fmt_str, "Заработано: {00FF00}%d руб", wage);
			SendClientMessage(playerid, 0xFFFFFFFF, fmt_str);

			format(fmt_str, sizeof fmt_str, "Количество пассажиров: {00FF00}%d", items);
			SendClientMessage(playerid, 0xFFFFFFFF, fmt_str);
		}
		case JOB_UNUSED_3:
		{
			DisablePlayerRaceCheckpoint(playerid);
			wage = GetPlayerData(playerid, P_MECHANIC_FILL_PAY) + GetPlayerData(playerid, P_MECHANIC_REPAIR_PAY);

			format(fmt_str, sizeof fmt_str, "Получено за ремонт: {00FF00}%d руб", GetPlayerData(playerid, P_MECHANIC_REPAIR_PAY));
			SendClientMessage(playerid, 0xFFFFFFFF, fmt_str);

			format(fmt_str, sizeof fmt_str, "Получено за заправку: {00FF00}%d руб", GetPlayerData(playerid, P_MECHANIC_FILL_PAY));
			SendClientMessage(playerid, 0xFFFFFFFF, fmt_str);

			format(fmt_str, sizeof fmt_str, "Всего заработано: {FFCD00}%d руб", wage);
			SendClientMessage(playerid, 0xFFFFFFFF, fmt_str);
		}
		case JOB_TRUCKER:
		{
			DisablePlayerRaceCheckpoint(playerid);

			format(fmt_str, sizeof fmt_str, "Ваша общая чистая прибыль составляет {00CC00}%d руб", wage);
			SendClientMessage(playerid, -1, fmt_str);

			if(GetPlayerData(playerid, P_ORDER) != -1)
				SetOrderData(GetPlayerData(playerid, P_ORDER), O_USED, false);

			return 1;
		}
		/*
		case JOB_PITCHMAN:
		{
			new marketid = player_use_market[playerid];
			player_use_market[playerid] = -1;

			if(marketid != -1)
			{
				market_status[marketid] = false;
				UpdateMarket(marketid);
			}

			salary = player_job_load_items[playerid];

			format(fmt_str, sizeof fmt_str, "Общее количество покупателей: {00FF00}%d", market_buyers_count[playerid]);
			SendClientMessage(playerid, -1, fmt_str);

			format(fmt_str, sizeof fmt_str, "Всего продано товаров на {00FF00}%d руб", salary);
			SendClientMessage(playerid, -1, fmt_str);
		}

		case JOB_FIREFIGHTER:
		{
			check_extinguish_the_fire{playerid} = false;

			DisablePlayerRaceCheckpoint(playerid);
			TextDrawHideForPlayer(playerid, time_to_fire_TD);

			salary = player_job_load_items[playerid];

			format(fmt_str, sizeof fmt_str, "Потушено очагов возгорания: {FF3333}%d", extinguished_fires_count[playerid]);
			SendClientMessage(playerid, -1, fmt_str);

			format(fmt_str, sizeof fmt_str, "Заработано {0099CC}%d руб", salary);
			SendClientMessage(playerid, -1, fmt_str);
		}
		*/
		default:
		{
			switch(GetPlayerTempJob(playerid))
			{
				case TEMP_JOB_FACTORY_TRUCKER:
				{
			//		RemovePlayerAttachedObjects(playerid);
					SetPlayerSkinInit(playerid);

					format(fmt_str, sizeof fmt_str, "Ваша общая чистая прибыль составляет {00CC00}%d руб", wage);
					SendClientMessage(playerid, 0xFFFFFFFF, fmt_str);

					SetPlayerJobLoadItems(playerid, 0);
					SetPlayerTempJob(playerid, TEMP_JOB_NONE);
				}
			}
			return 1;
		}
	}
	SendClientMessage(playerid, 0x66CC00FF, "Деньги будут перечислены на Ваш счет во время зарплаты");

	AddPlayerData(playerid, P_WAGE, +, wage);
	
	AddPlayerData(playerid, P_TOP_2, +, wage);
	UpdatePlayerDatabaseInt(playerid, "TOP_SalaryGosWork", GetPlayerData(playerid, P_TOP_2));

	format(fmt_str, sizeof fmt_str, "UPDATE accounts SET wage=%d WHERE id=%d LIMIT 1", GetPlayerData(playerid, P_WAGE), GetPlayerAccountID(playerid));
	mysql_query(mysql, fmt_str, false);

	return 1;
}

