#if defined _m1stoks_main_included
	#endinput
#endif
#define _m1stoks_main_included

// BEGIN INLINED: modules/m1stoks/larek/headers.inc
#if defined _m1stoks_headers_included
	#endinput
#endif
#define _m1stoks_headers_included

#define LAREK_AREA_RANGE                (2.0)
#define LAREK_INTERACT_RANGE            (2.0)
#define LAREK_ITEM_COUNT                (6)
#define LAREK_NOTIFY_COOLDOWN_MS        (1500)
#define LAREK_NOTIFY_ID                 (62)
#define LAREK_STATIC_PRICE             (500000)
#define LAREK_STATIC_RENT_PRICE        (5000)
#define LAREK_STATIC_PRODUCTS          (10000)
#define LAREK_STATIC_INTERIOR          (0)
#define LAREK_STATIC_FIND_RANGE        (2.0)

new const Float:g_larek_static_positions[][3] =
{
	{-113.201, 942.369, 12.2141},
	{-111.83, 905.018, 12.2142},
	{57.9155, 942.644, 12.2129},
	{154.984, 586.486, 12.2141},
	{-256.276, 573.732, 12.195},
	{-2402.3, 194.55, 26.0326},
	{1801.86, 2531.64, 14.6583},
	{1905.67, 2104.01, 15.7135},
	{2744.2, -2429.01, 21.8987},
	{2283.69, -2171.79, 22.0376},
	{2251.62, -2110.84, 22.0376},
	{1912.64, -2266.77, 11.0912},
	{1889.19, -2243.52, 11.0754},
	{847.375, 802.654, 13.3786},
	{-2322.84, -150.564, 26.5272},
	{-1760.46, 790.768, 35.7447},
	{-2638.4, 2002.19, 9.64933},
	{-2146.13, 1598.92, 9.88}
};

new g_larek_area[MAX_BUSINESS] = {STREAMER_TAG_AREA:-1, ...};

new const g_larek_item_price[LAREK_ITEM_COUNT] =
{
	120, 230, 320, 580, 80, 30
};

new const g_larek_item_satiety[LAREK_ITEM_COUNT] =
{
	8, 15, 21, 39, 5, 2
};

new
	p_larek_biz_id[MAX_PLAYERS] = {-1, ...},
	p_larek_notify_biz[MAX_PLAYERS] = {-1, ...},
	p_larek_last_check_ms[MAX_PLAYERS];
// END INLINED: modules/m1stoks/larek/headers.inc
// BEGIN INLINED: modules/m1stoks/larek/functions.inc
#if defined _m1stoks_functions_included
	#endinput
#endif
#define _m1stoks_functions_included

stock Larek_IsBusinessLarek(biz_id)
{
	if(biz_id < 0 || biz_id >= g_business_loaded) return 0;
	return GetBusinessData(biz_id, B_TYPE) == BUSINESS_TYPE_LAREK;
}

stock Larek_ResetPlayer(playerid)
{
	p_larek_biz_id[playerid] = -1;
	p_larek_notify_biz[playerid] = -1;
	p_larek_last_check_ms[playerid] = 0;
	return 1;
}

stock Larek_DestroyAllAreas()
{
	for(new i; i < MAX_BUSINESS; i++)
	{
		if(g_larek_area[i] == STREAMER_TAG_AREA:-1) continue;
		if(IsValidDynamicArea(g_larek_area[i]))
			DestroyDynamicArea(g_larek_area[i]);

		g_larek_area[i] = STREAMER_TAG_AREA:-1;
	}
	return 1;
}

stock Larek_CreateArea(biz_id)
{
	if(biz_id < 0 || biz_id >= MAX_BUSINESS) return 0;
	if(!Larek_IsBusinessLarek(biz_id)) return 0;

	if(g_larek_area[biz_id] != STREAMER_TAG_AREA:-1 && IsValidDynamicArea(g_larek_area[biz_id]))
		DestroyDynamicArea(g_larek_area[biz_id]);

	new STREAMER_TAG_AREA:areaid = CreateDynamicSphere(
		GetBusinessData(biz_id, B_POS_X),
		GetBusinessData(biz_id, B_POS_Y),
		GetBusinessData(biz_id, B_POS_Z),
		LAREK_AREA_RANGE
	);

	g_larek_area[biz_id] = areaid;
	Streamer_SetIntData(STREAMER_TYPE_AREA, _:areaid, E_STREAMER_EXTRA_ID, biz_id);
	return 1;
}

stock Larek_FindStaticBusiness(Float:x, Float:y, Float:z)
{
	for(new i; i < g_business_loaded; i++)
	{
		new Float:dx = x - GetBusinessData(i, B_POS_X);
		new Float:dy = y - GetBusinessData(i, B_POS_Y);
		new Float:dz = z - GetBusinessData(i, B_POS_Z);

		if(floatsqroot((dx * dx) + (dy * dy) + (dz * dz)) <= LAREK_STATIC_FIND_RANGE)
			return i;
	}
	return -1;
}

stock Larek_ApplyStaticBusinessData(businessid, pos_idx, bool:is_new)
{
	new Float:x = g_larek_static_positions[pos_idx][0];
	new Float:y = g_larek_static_positions[pos_idx][1];
	new Float:z = g_larek_static_positions[pos_idx][2];

	if(is_new)
	{
		SetBusinessData(businessid, B_OWNER_ID, 0);
		SetBusinessData(businessid, B_IMPROVEMENTS, 0);
		SetBusinessData(businessid, B_BALANCE, 0);
		SetBusinessData(businessid, B_RENT_DATE, 0);
		SetBusinessData(businessid, B_LOCK_STATUS, false);
		SetBusinessData(businessid, B_EVICTION, 0);
		format(g_business[businessid][B_OWNER_NAME], 21, "None");
	}
	else if(!IsBusinessOwned(businessid))
	{
		SetBusinessData(businessid, B_LOCK_STATUS, false);
		format(g_business[businessid][B_OWNER_NAME], 21, "None");
	}

	SetBusinessData(businessid, B_ENTER_PRICE, 0);
	SetBusinessData(businessid, B_ENTER_MUSIC, 0);
	SetBusinessData(businessid, B_PRODS, LAREK_STATIC_PRODUCTS);
	SetBusinessData(businessid, B_PROD_PRICE, 0);
	SetBusinessData(businessid, B_PRICE, LAREK_STATIC_PRICE);
	SetBusinessData(businessid, B_RENT_PRICE, LAREK_STATIC_RENT_PRICE);
	SetBusinessData(businessid, B_TYPE, BUSINESS_TYPE_LAREK);
	SetBusinessData(businessid, B_INTERIOR, LAREK_STATIC_INTERIOR);
	SetBusinessData(businessid, B_POS_X, x);
	SetBusinessData(businessid, B_POS_Y, y);
	SetBusinessData(businessid, B_POS_Z, z);
	SetBusinessData(businessid, B_EXIT_POS_X, x);
	SetBusinessData(businessid, B_EXIT_POS_Y, y);
	SetBusinessData(businessid, B_EXIT_POS_Z, z);
	SetBusinessData(businessid, B_EXIT_ANGLE, 0.0);
	SetBusinessData(businessid, B_ORDER_ID, -1);

	if(GetBusinessData(businessid, B_HEALTH_PICKUP))
	{
		DestroyPickup(GetBusinessData(businessid, B_HEALTH_PICKUP));
		SetBusinessData(businessid, B_HEALTH_PICKUP, 0);
	}

	format(g_business[businessid][B_NAME], 24, "Ларёк #%d", businessid + 1);
	return 1;
}

stock Larek_InitStaticBusinesses()
{
	new query[512];
	new created_count, updated_count, skipped_count;
	new Cache:insert_result;

	for(new pos_idx; pos_idx < sizeof g_larek_static_positions; pos_idx++)
	{
		new Float:x = g_larek_static_positions[pos_idx][0];
		new Float:y = g_larek_static_positions[pos_idx][1];
		new Float:z = g_larek_static_positions[pos_idx][2];
		new businessid = Larek_FindStaticBusiness(x, y, z);

		if(businessid != -1)
		{
			Larek_ApplyStaticBusinessData(businessid, pos_idx, false);

			if(GetBusinessData(businessid, B_SQL_ID) > 0)
			{
				mysql_format(mysql, query, sizeof query,
					"UPDATE business SET type=%d,interior=%d,name='%e',price=%d,rent_price=%d,x='%f',y='%f',z='%f',exit_x='%f',exit_y='%f',exit_z='%f',exit_angle='%f' WHERE id=%d LIMIT 1",
					BUSINESS_TYPE_LAREK,
					LAREK_STATIC_INTERIOR,
					g_business[businessid][B_NAME],
					LAREK_STATIC_PRICE,
					LAREK_STATIC_RENT_PRICE,
					x, y, z,
					x, y, z,
					0.0,
					GetBusinessData(businessid, B_SQL_ID)
				);
				mysql_query(mysql, query, false);
			}

			RecreateBusinessEnterPickup(businessid);
			Larek_CreateArea(businessid);
			Larek_UpdateLabel(businessid);
			updated_count++;
			continue;
		}

		if(g_business_loaded >= MAX_BUSINESS)
		{
			skipped_count++;
			continue;
		}

		businessid = g_business_loaded++;
		SetBusinessData(businessid, B_SQL_ID, 0);
		SetBusinessData(businessid, B_LABEL, Text3D:-1);
		Larek_ApplyStaticBusinessData(businessid, pos_idx, true);

		mysql_format(mysql, query, sizeof query,
			"INSERT INTO business (type, price, rent_price, x, y, z, interior, name, exit_x, exit_y, exit_z, exit_angle) VALUES (%d, %d, %d, '%f', '%f', '%f', %d, '%e', '%f', '%f', '%f', '%f')",
			BUSINESS_TYPE_LAREK,
			LAREK_STATIC_PRICE,
			LAREK_STATIC_RENT_PRICE,
			x, y, z,
			LAREK_STATIC_INTERIOR,
			g_business[businessid][B_NAME],
			x, y, z,
			0.0
		);
		insert_result = mysql_query(mysql, query, true);
		SetBusinessData(businessid, B_SQL_ID, cache_insert_id());
		cache_delete(insert_result);

		RecreateBusinessEnterPickup(businessid);
		CreateDynamicMapIcon(x, y, z, 52, 0, 0, 0, -1, STREAMER_MAP_ICON_SD, MAPICON_LOCAL);
		Larek_CreateArea(businessid);
		Larek_UpdateLabel(businessid);
		created_count++;
	}

	printf("[Larek]: Static businesses init: created=%d updated=%d skipped=%d loaded=%d", created_count, updated_count, skipped_count, g_business_loaded);
	return 1;
}
stock Larek_InitAreas()
{
	Larek_DestroyAllAreas();

	for(new i; i < g_business_loaded; i++)
	{
		if(Larek_IsBusinessLarek(i))
			Larek_CreateArea(i);
	}
	return 1;
}

stock Larek_GetBizByArea(STREAMER_TAG_AREA:areaid)
{
	new biz_id;
	biz_id = Streamer_GetIntData(STREAMER_TYPE_AREA, _:areaid, E_STREAMER_EXTRA_ID);
	if(0 <= biz_id < MAX_BUSINESS)
	{
		if(Larek_IsBusinessLarek(biz_id) && g_larek_area[biz_id] == areaid)
			return biz_id;
	}

	for(new i; i < g_business_loaded; i++)
	{
		if(!Larek_IsBusinessLarek(i)) continue;
		if(g_larek_area[i] == areaid) return i;
	}
	return -1;
}

stock Larek_ShowInteractNotification(playerid, biz_id)
{
	if(!IsPlayerLogged(playerid)) return 0;
	if(!Larek_IsBusinessLarek(biz_id)) return 0;
	if(GetBusinessData(biz_id, B_LOCK_STATUS)) return 0;

	p_larek_biz_id[playerid] = biz_id;

	if(p_larek_notify_biz[playerid] == biz_id) return 1;

	ShowNotificationNew(playerid, 4, 7, LAREK_NOTIFY_ID, 1, "Взаимодействовать", ">>");

	p_larek_notify_biz[playerid] = biz_id;
	return 1;
}

stock Larek_OpenFromNotify(playerid)
{
	new biz_id = p_larek_biz_id[playerid];

	if(biz_id == -1 || !Larek_IsBusinessLarek(biz_id))
		biz_id = Larek_GetNearest(playerid, LAREK_INTERACT_RANGE);

	if(biz_id == -1)
		return SendClientMessage(playerid, 0x999999FF, "Рядом нет ларька."), 0;

	return Larek_OpenJsonShop(playerid, biz_id);
}

public Larek_OpenFromNotifyPublic(playerid)
{
	return Larek_OpenFromNotify(playerid);
}

public Larek_HandleNotificationClickPublic(playerid, notif_id)
{
	if(notif_id != LAREK_NOTIFY_ID) return 0;
	return Larek_OpenFromNotify(playerid);
}

stock Larek_OpenJsonShop(playerid, biz_id)
{
	if(!IsPlayerLogged(playerid)) return 0;
	if(!Larek_IsBusinessLarek(biz_id)) return 0;

	if(GetBusinessData(biz_id, B_LOCK_STATUS))
		return SendClientMessage(playerid, 0x999999FF, "Ларёк закрыт."), 0;

	p_larek_biz_id[playerid] = biz_id;

	new Node:json = JSON_Object();
	JSON_SetInt(json, "m", GetPlayerMoneyEx(playerid));
	ShowPlayerGUI(playerid, BrDialogDiner, json);
	JSON_Cleanup(json);
	return 1;
}

stock Larek_RefreshJsonShop(playerid)
{
	if(p_larek_biz_id[playerid] < 0) return 0;

	new Node:json = JSON_Object();
	JSON_SetInt(json, "m", GetPlayerMoneyEx(playerid));
	ShowPlayerGUI(playerid, BrDialogDiner, json);
	JSON_Cleanup(json);
	return 1;
}

stock Larek_CreditBusiness(playerid, biz_id, price)
{
	if(!IsBusinessOwned(biz_id)) return 0;

	AddBusinessData(biz_id, B_BALANCE, +, price);

	new query[160];
	mysql_format(mysql, query, sizeof query, "UPDATE business SET balance=%d WHERE id=%d LIMIT 1",
		GetBusinessData(biz_id, B_BALANCE),
		GetBusinessData(biz_id, B_SQL_ID));
	mysql_query(mysql, query, false);

	mysql_format(mysql, query, sizeof query,
		"INSERT INTO business_profit (bid,uid,uip,time,money,view) VALUES (%d,%d,'%e',%d,%d,1)",
		GetBusinessData(biz_id, B_SQL_ID),
		GetPlayerAccountID(playerid),
		GetPlayerIpEx(playerid),
		gettime(),
		price
	);
	mysql_query(mysql, query, false);
	return 1;
}

stock Larek_TryBuyOrder(playerid, order)
{
	new biz_id = p_larek_biz_id[playerid];
	if(biz_id < 0 || !Larek_IsBusinessLarek(biz_id))
		return SendClientMessage(playerid, 0x999999FF, "Вы не у ларька."), 0;

	new item[LAREK_ITEM_COUNT], price, satiety;

	for(new i; i < LAREK_ITEM_COUNT; i++)
		item[i] = (order >> i) & 1;

	for(new i; i < LAREK_ITEM_COUNT; i++)
	{
		if(item[i])
		{
			price += g_larek_item_price[i];
			satiety += g_larek_item_satiety[i];
		}
	}

	if(price <= 0)
		return SendClientMessage(playerid, 0x999999FF, "Выберите товар."), 0;

	if(GetPlayerMoneyEx(playerid) < price)
		return SendClientMessage(playerid, 0x999999FF, "Недостаточно денег."), 0;

	GivePlayerMoneyEx(playerid, -price, "Покупка еды в ларьке", true, true);
	Larek_CreditBusiness(playerid, biz_id, price);

	new msg[128];
	format(msg, sizeof msg,
		"{FFFFFF}Вы успешно приобрели еды на {FFFF00}%d{FFFFFF} рублей, вам добавлено {FFFF00}%d{FFFFFF} сытости.",
		price, satiety
	);
	SendClientMessage(playerid, -1, msg);

	// Фракционное задание №25: купить любую еду в ларьке.
	// Вызывается только после успешной оплаты и зачисления покупки.
	FracQuestProgresskmonarch(playerid, 25);
	return 1;
}

stock Larek_HandleJsonPacket(playerid, Node:json)
{
	new type;
	JSON_GetInt(json, "t", type);

	switch(type)
	{
		case 0:
		{
			p_larek_biz_id[playerid] = -1;
		}
		case 1:
		{
			new order;
			JSON_GetInt(json, "r", order);

			if(Larek_TryBuyOrder(playerid, order))
				Larek_RefreshJsonShop(playerid);
		}
	}
	return 1;
}

stock Larek_EnsureBusinessName(biz_id)
{
	if(!Larek_IsBusinessLarek(biz_id)) return 0;

	if(!strlen(g_business[biz_id][B_NAME]))
		format(g_business[biz_id][B_NAME], 24, "Ларёк #%d", biz_id + 1);

	new query[128];
	mysql_format(mysql, query, sizeof query,
		"UPDATE business SET name='%e' WHERE id=%d LIMIT 1",
		g_business[biz_id][B_NAME],
		GetBusinessData(biz_id, B_SQL_ID));
	mysql_query(mysql, query, false);
	return 1;
}

public Larek_EnsureBusinessNamePublic(biz_id)
{
	return Larek_EnsureBusinessName(biz_id);
}

stock Larek_FormatOwnerName(biz_id, output[], size = sizeof output)
{
	if(IsBusinessOwned(biz_id) && strlen(g_business[biz_id][B_OWNER_NAME]) && strcmp(g_business[biz_id][B_OWNER_NAME], "None", true))
		format(output, size, "%s", g_business[biz_id][B_OWNER_NAME]);
	else
		format(output, size, "Государство");
	return 1;
}

stock Larek_BuildLabelText(biz_id, output[], size)
{
	new owner_display[24];
	Larek_FormatOwnerName(biz_id, owner_display);

	format(output, size,
		"{FFFF00}Ларёк (%d)\n\
		{FFFF00}Крыша: Арзамасская ОПГ\n\
		{FFFFFF}Владелец: {0099CC}%s\n\
		{FFFF00}Подойдите для выбора товара",
		GetBusinessData(biz_id, B_SQL_ID),
		owner_display
	);

	if(g_business[biz_id][B_LOCK_STATUS])
		strcat(output, "\n{FF6600}Закрыто", size);

	return 1;
}

stock Larek_UpdateLabel(biz_id)
{
	if(biz_id < 0 || biz_id >= g_business_loaded) return 0;
	if(!Larek_IsBusinessLarek(biz_id)) return 0;

	Larek_EnsureBusinessName(biz_id);

	new label_text[256];
	Larek_BuildLabelText(biz_id, label_text, sizeof label_text);

	if(IsValidDynamic3DTextLabel(Text3D:g_business[biz_id][B_LABEL]))
		DestroyDynamic3DTextLabel(Text3D:g_business[biz_id][B_LABEL]);

	g_business[biz_id][B_LABEL] = CreateDynamic3DTextLabel(
		label_text,
		0xFFFF00FF,
		GetBusinessData(biz_id, B_POS_X),
		GetBusinessData(biz_id, B_POS_Y),
		GetBusinessData(biz_id, B_POS_Z) + 1.0,
		6.50
	);
	return 1;
}

public Larek_UpdateLabelPublic(biz_id)
{
	return Larek_UpdateLabel(biz_id);
}

stock Larek_RefreshAllLabels()
{
	for(new i; i < g_business_loaded; i++)
	{
		if(Larek_IsBusinessLarek(i))
			Larek_UpdateLabel(i);
	}
	return 1;
}

stock Larek_OnBusinessCreated(biz_id, type)
{
	if(type != BUSINESS_TYPE_LAREK) return 0;

	format(g_business[biz_id][B_NAME], 24, "Ларёк #%d", biz_id + 1);
	Larek_EnsureBusinessName(biz_id);
	Larek_CreateArea(biz_id);
	Larek_UpdateLabel(biz_id);
	return 1;
}

public Larek_OnBusinessCreatedPublic(biz_id, type)
{
	return Larek_OnBusinessCreated(biz_id, type);
}

stock Float:Larek_GetDistanceToBiz(playerid, biz_id)
{
	new Float:px, Float:py, Float:pz;
	GetPlayerPos(playerid, px, py, pz);

	new Float:dx = px - GetBusinessData(biz_id, B_POS_X);
	new Float:dy = py - GetBusinessData(biz_id, B_POS_Y);

	return floatsqroot((dx * dx) + (dy * dy));
}

stock Larek_GetNearest(playerid, Float:range = LAREK_INTERACT_RANGE)
{
	new nearest = -1;
	new Float:best_dist = range;

	for(new i; i < g_business_loaded; i++)
	{
		if(!Larek_IsBusinessLarek(i)) continue;

		new Float:dist = Larek_GetDistanceToBiz(playerid, i);
		if(dist <= best_dist)
		{
			best_dist = dist;
			nearest = i;
		}
	}
	return nearest;
}

stock Larek_ProcessProximity(playerid)
{
	if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid))
		return 0;

	new biz_id = Larek_GetNearest(playerid, LAREK_INTERACT_RANGE);

	if(biz_id == -1)
	{
		p_larek_notify_biz[playerid] = -1;
		p_larek_biz_id[playerid] = -1;
		return 0;
	}

	if(GetBusinessData(biz_id, B_LOCK_STATUS))
		return 0;

	p_larek_biz_id[playerid] = biz_id;

	if(p_larek_notify_biz[playerid] != biz_id)
		Larek_ShowInteractNotification(playerid, biz_id);

	return 1;
}

stock Larek_OnPlayerTimer(playerid)
{
	return Larek_ProcessProximity(playerid);
}

stock Larek_OnPlayerUpdate(playerid)
{
	new tick = GetTickCount();

	if(tick - p_larek_last_check_ms[playerid] < LAREK_NOTIFY_COOLDOWN_MS)
		return 0;

	p_larek_last_check_ms[playerid] = tick;
	return Larek_ProcessProximity(playerid);
}

public Larek_OnPlayerUpdatePublic(playerid)
{
	return Larek_OnPlayerUpdate(playerid);
}

public Larek_OnPlayerTimerPublic(playerid)
{
	return Larek_OnPlayerTimer(playerid);
}

stock Larek_ShowBusinessInfo(playerid)
{
	new businessid = GetPlayerBusiness(playerid);
	if(businessid == -1 || !Larek_IsBusinessLarek(businessid)) return 0;

	new fmt_str[768], city[MAX_ZONES_NAME + 1], area[MAX_ZONES_NAME + 1];
	GetCityName(GetBusinessData(businessid, B_POS_X), GetBusinessData(businessid, B_POS_Y), city);
	GetAreaName(GetBusinessData(businessid, B_POS_X), GetBusinessData(businessid, B_POS_Y), area);

	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Название:\t\t\t\t{339999}%s\n"\
		"{FFFFFF}Номер бизнеса:\t\t\t%d\n"\
		"Владелец:\t\t\t\t%s\n"\
		"Город / область:\t\t\t%s\n"\
		"Район:\t\t\t\t\t%s\n"\
		"Баланс предприятия:\t\t\t%d руб\n"\
		"Бизнес арендован на:\t\t{66CC00}%d {FFFFFF}из {FFFF00}30 {FFFFFF}дней\n"\
		"{FFFFFF}Гос. стоимость:\t\t\t%d руб\n"\
		"Аренда помещения:\t\t\t%d руб в день\n"\
		"Тип аренды:\t\t\t\t%s\n"\
		"Статус:\t\t\t\t\t%s\n\n"\
		"{669966}Цены на товары фиксированы.\n"\
		"100%% выручки от продаж поступает на баланс бизнеса.\n\n"\
		"{669966}Для открытия панели управления\n"\
		"нажмите кнопку \"Изменить\"",
		GetBusinessData(businessid, B_NAME),
		businessid,
		GetBusinessData(businessid, B_OWNER_NAME),
		city,
		area,
		GetBusinessData(businessid, B_BALANCE),
		GetBusinessData(businessid, B_RENT_DATE) <= gettime() ? 0 :
		GetElapsedTime(GetBusinessData(businessid, B_RENT_DATE), gettime(), CONVERT_TIME_TO_DAYS),
		GetBusinessData(businessid, B_PRICE),
		GetBusinessData(businessid, B_IMPROVEMENTS) < 3 ? (GetBusinessData(businessid, B_RENT_PRICE)) : (GetBusinessData(businessid, B_RENT_PRICE) / 2),
		GetBusinessData(businessid, B_IMPROVEMENTS) < 3 ? ("Полная") : ("Льготная"),
		GetBusinessData(businessid, B_LOCK_STATUS) ? ("{CC3333}Ларёк закрыт") : ("{66CC33}Ларёк открыт")
	);

	Dialog(playerid, DIALOG_BIZ_INFO, DIALOG_STYLE_LIST,
		"{00FFFF}"SERVER_NAME"{ffffff} -> Информация о ларьке",
		fmt_str, "Изменить", "Отмена"
	);
	return 1;
}

public Larek_ShowBusinessInfoPublic(playerid)
{
	return Larek_ShowBusinessInfo(playerid);
}

stock Larek_ShowBusinessDialog(playerid, operationid)
{
	new businessid = GetPlayerBusiness(playerid);
	if(businessid == -1 || !Larek_IsBusinessLarek(businessid)) return 0;

	switch(operationid)
	{
		case 0:
		{
			Dialog(playerid, DIALOG_BIZ_PARAMS, DIALOG_STYLE_LIST,
				"{33AACC}Управление ларьком",
				"1. {669966}Открыть {FFFFFF}или {CC3333}закрыть {FFFFFF}ларёк\n"\
				"2. Финансовая статистика",
				"Выбрать", "Назад"
			);
		}
		case 1:
		{
			if(GetBusinessData(businessid, B_LOCK_STATUS))
			{
				SetBusinessData(businessid, B_LOCK_STATUS, false);
				SendClientMessage(playerid, 0x66CC00FF, "Ларёк открыт");
			}
			else
			{
				SetBusinessData(businessid, B_LOCK_STATUS, true);
				SendClientMessage(playerid, 0xFF6600FF, "Ларёк закрыт");
			}

			Larek_UpdateLabel(businessid);

			new query[75];
			mysql_format(mysql, query, sizeof query,
				"UPDATE business SET `lock`=%d WHERE `id`=%d LIMIT 1",
				GetBusinessData(businessid, B_LOCK_STATUS),
				GetBusinessData(businessid, B_SQL_ID)
			);
			mysql_query(mysql, query, false);

			Dialog(playerid, DIALOG_BIZ_PARAMS, DIALOG_STYLE_LIST,
				"{33AACC}Larek management",
				"1. Open or close the kiosk\n2. Financial statistics",
				"Select", "Back"
			);
		}
		case 6:
		{
			new query[256];
			new time = gettime();
			new cur_day = time - (time % 86400);
			new start_day = cur_day - (86400 * 20);

			mysql_format(mysql, query, sizeof query,
				"SELECT FROM_UNIXTIME(time, '%%Y-%%m-%%d') AS date, SUM(money) as total FROM business_profit WHERE bid=%d AND view=1 AND time >= %d AND time < %d GROUP BY time ORDER BY time DESC LIMIT 20",
				GetBusinessData(businessid, B_SQL_ID), start_day, cur_day
			);
			mysql_tquery(mysql, query, "ShowBusinessProfit", "ii", playerid, ++ mysql_race[playerid]);
		}
	}
	return 1;
}

public Larek_ShowBusinessDialogPublic(playerid, operationid)
{
	return Larek_ShowBusinessDialog(playerid, operationid);
}

stock Larek_OnBizParamsList(playerid, listitem)
{
	switch(listitem)
	{
		case 0: Larek_ShowBusinessDialog(playerid, 1);
		case 1: Larek_ShowBusinessDialog(playerid, 6);
	}
	return 1;
}

public Larek_OnBizParamsListPublic(playerid, listitem)
{
	return Larek_OnBizParamsList(playerid, listitem);
}
// END INLINED: modules/m1stoks/larek/functions.inc
// BEGIN INLINED: modules/m1stoks/larek/callbacks.inc
#if defined _m1stoks_callbacks_included
	#endinput
#endif
#define _m1stoks_callbacks_included

forward Larek_OnGameModeInit();
public Larek_OnGameModeInit()
{
	Larek_InitStaticBusinesses();
	Larek_InitAreas();
	Larek_RefreshAllLabels();
	printf("[Larek]: Система ларьков загружена.");
	return 1;
}

forward Larek_OnPlayerConnect(playerid);
public Larek_OnPlayerConnect(playerid)
{
	Larek_ResetPlayer(playerid);
	return 1;
}

forward Larek_OnPlayerDisconnect(playerid);
public Larek_OnPlayerDisconnect(playerid)
{
	p_larek_biz_id[playerid] = -1;
	p_larek_notify_biz[playerid] = -1;
	p_larek_last_check_ms[playerid] = 0;
	return 1;
}

forward Larek_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
public Larek_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
	new biz_id = Larek_GetBizByArea(areaid);
	if(biz_id == -1) return 0;

	Larek_ShowInteractNotification(playerid, biz_id);
	return 1;
}

forward Larek_OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
public Larek_OnPlayerLeaveDynamicArea(playerid, STREAMER_TAG_AREA:areaid)
{
	new biz_id = Larek_GetBizByArea(areaid);
	if(biz_id == -1) return 0;

	if(p_larek_biz_id[playerid] == biz_id)
		p_larek_biz_id[playerid] = -1;

	p_larek_notify_biz[playerid] = -1;
	return 1;
}

forward Larek_OnPlayerPickUpPickupEx(playerid, pickupid, action_type, action_id);
public Larek_OnPlayerPickUpPickupEx(playerid, pickupid, action_type, action_id)
{
	#pragma unused pickupid

	if(action_type != PICKUP_ACTION_TYPE_BIZ_ENTER) return 0;
	if(action_id < 0 || action_id >= g_business_loaded) return 0;
	if(!Larek_IsBusinessLarek(action_id)) return 0;

	Larek_ShowInteractNotification(playerid, action_id);
	return 1;
}
// END INLINED: modules/m1stoks/larek/callbacks.inc
// BEGIN INLINED: modules/m1stoks/autoReboot/autoreboot.inc
#if defined _autoreboot_included
	#endinput
#endif
#define _autoreboot_included

#define AUTOREBOOT_HOUR       9
#define AUTOREBOOT_MINUTE     0
#define AUTOREBOOT_SECOND     0

#define AUTOREBOOT_WARN_1H    3600
#define AUTOREBOOT_WARN_30M   1800
#define AUTOREBOOT_WARN_15M   900
#define AUTOREBOOT_WARN_5M    300
#define AUTOREBOOT_WARN_1M    60
#define AUTOREBOOT_WARN_30S   30

#define AUTOREBOOT_COLOR      0xFF6600FF

enum E_AUTOREBOOT_WARN
{
	AR_WARN_1H,
	AR_WARN_30M,
	AR_WARN_15M,
	AR_WARN_5M,
	AR_WARN_1M,
	AR_WARN_30S,
	MAX_AR_WARNINGS
}

new bool:ar_warn_sent[MAX_AR_WARNINGS];
new ar_rebooting;

stock AutoReboot_ResetWarnings()
{
	for(new i = 0; i < MAX_AR_WARNINGS; i++)
		ar_warn_sent[i] = false;

	ar_rebooting = 0;
}

stock AutoReboot_SecondsUntilReboot()
{
	new hour, minute, second;
	gettime(hour, minute, second);

	new now_secs    = hour * 3600 + minute * 60 + second;
	new target_secs = AUTOREBOOT_HOUR * 3600 + AUTOREBOOT_MINUTE * 60 + AUTOREBOOT_SECOND;

	new diff = target_secs - now_secs;
	if(diff < 0)
		diff += 86400;

	return diff;
}

stock AutoReboot_SendWarning(const text[])
{
	new string[128];
	format(string, sizeof(string), "[Сервер]: {FFFFFF}Сервер будет автоматически перезагружен через: %s.", text);
	SendClientMessageToAll(AUTOREBOOT_COLOR, string);
	printf("[AutoReboot]: Сервер будет автоматически перезагружен через: %s.", text);
}

stock AutoReboot_Notify(E_AUTOREBOOT_WARN:warn_id, const text[])
{
	if(ar_warn_sent[_:warn_id])
		return 0;

	ar_warn_sent[_:warn_id] = true;
	AutoReboot_SendWarning(text);
	return 1;
}

stock AutoReboot_ExecuteRestart()
{
	if(ar_rebooting)
		return 0;

	ar_rebooting = 1;
	SendClientMessageToAll(AUTOREBOOT_COLOR, "[Сервер]: {FFFFFF}Сервер начал перезапуск.");
	print("[AutoReboot]: Сервер начал перезапуск.");
	SendRconCommand("exit");
	return 1;
}

stock AutoReboot_Init()
{
	AutoReboot_ResetWarnings();

	new seconds_left = AutoReboot_SecondsUntilReboot();
	printf("[AutoReboot]: Система загружена. Следующий перезапуск через %d сек. (%02d:%02d)", seconds_left, seconds_left / 3600, (seconds_left % 3600) / 60);
}

stock AutoReboot_OnSecondTimer()
{
	if(ar_rebooting)
		return 0;

	new seconds_left = AutoReboot_SecondsUntilReboot();

	switch(seconds_left)
	{
		case AUTOREBOOT_WARN_1H:   AutoReboot_Notify(AR_WARN_1H,   "1 час");
		case AUTOREBOOT_WARN_30M:  AutoReboot_Notify(AR_WARN_30M,  "30 минут");
		case AUTOREBOOT_WARN_15M:  AutoReboot_Notify(AR_WARN_15M,  "15 минут");
		case AUTOREBOOT_WARN_5M:   AutoReboot_Notify(AR_WARN_5M,   "5 минут");
		case AUTOREBOOT_WARN_1M:   AutoReboot_Notify(AR_WARN_1M,   "1 минуту");
		case AUTOREBOOT_WARN_30S:  AutoReboot_Notify(AR_WARN_30S,  "30 секунд");
		case 0: AutoReboot_ExecuteRestart();
	}
	return 1;
}

CMD:testinc(playerid)
{
	SendClientMessage(playerid, -1, "testinc");
	return 1;
}
// END INLINED: modules/m1stoks/autoReboot/autoreboot.inc
// BEGIN INLINED: modules/m1stoks/magazinSkinov/magazinskinov.inc
#if defined _magazinskinov_included
	#endinput
#endif
#define _magazinskinov_included

#define MSKIN_TD_COUNT          15

#define MSKIN_TD_BTN_LEFT       3
#define MSKIN_TD_BTN_RIGHT      8
#define MSKIN_TD_BTN_BUY_BOX    11
#define MSKIN_TD_BTN_EXIT_BOX   12
#define MSKIN_TD_BTN_BUY        13
#define MSKIN_TD_BTN_EXIT       14

#define MSKIN_PRICE_BOX_X1      249.6667
#define MSKIN_PRICE_BOX_X2      392.0000
#define MSKIN_PRICE_BOX_Y       379.5701
#define MSKIN_PRICE_BOX_H       1.4665
#define MSKIN_PRICE_PTD_X       320.8333
#define MSKIN_PRICE_PTD_Y       381.0000

#define MSKIN_REG_POS_X         1200.4557
#define MSKIN_REG_POS_Y         607.9025
#define MSKIN_REG_POS_Z         1349.3094
#define MSKIN_REG_ANGLE         180.0
#define MSKIN_REG_INTERIOR      1
#define MSKIN_REG_CAM_X         1200.0
#define MSKIN_REG_CAM_Y         605.0
#define MSKIN_REG_CAM_Z         1350.0

/*
	Ассортимент магазина одежды — редактируйте здесь.
	Формат строки: { skin_id, price_rub, "название (только для кодера, не показывается игроку)" }
	Мужские и женские скины — в отдельных таблицах, отсортированы по цене.
	Количество позиций меняется через MSKIN_CATALOG_MALE_ITEMS / MSKIN_CATALOG_FEMALE_ITEMS.
*/
#define MSKIN_CATALOG_MALE_ITEMS    87
#define MSKIN_CATALOG_FEMALE_ITEMS  12
#define MSKIN_CAT_NAME_LEN      32

enum E_MSKIN_CATALOG
{
	MSKIN_CAT_ID,
	MSKIN_CAT_PRICE,
	MSKIN_CAT_NAME[MSKIN_CAT_NAME_LEN]
};

new const g_magazinskinov_catalog_m[MSKIN_CATALOG_MALE_ITEMS][E_MSKIN_CATALOG] =
{
		{29,    5850,  "Борзый>"},
		{33, 	9750,  "Базовый 1"},
		{30,    14625, "Мерзляк"},
		{36,    15600, "Сосед 1"},
		{37,    19500, "Сосед 2"},
		{278,    20000,  "Спайк"},
		{43,   23400,   "Друг 1"},
		{18594, 25000, ""},
		{44,   29250,  "Друг 2"},
		{45,   31200,  ""},
		{297,  35000,  ""},
		{47, 	35100,  ""},
		{60, 39000,  ""},
		{96, 40000, ""},
		{97, 40000, ""},
		{66, 42900, ""},
		{67, 42900, ""},
		// {18680, 45000, "Кудряш"},
		{142, 48750, ""},
		{7, 50000, ""},
		{143, 52650, "Тинэйджер"},
		{18615, 55000, "Рокер"},
		{144, 58500, "Плохиш"},
		{6, 60000, ""},
		{154, 62400, ""}, //old: {45, 62400, ""},
		{128, 100000, "Мажор 1"},
		{268, 100000, ""},
		{101, 107250, ""},
		{3, 117000, "Гопник в красном"},
		{18861, 120000, ""},
		{177, 130000, ""},
		{180, 156000, "Социофоб 2"},
		{181, 175500, ""},
		{182, 195000, ""},
		{123, 200000, ""},
		{183, 214500, ""},
		{185, 234000, ""},
		{189, 263000, ""},
		{18608, 270000, ""},
		{247, 292000, "Mr. Mallboro"},
		{18603, 330000, ""},
		{19199, 500000, ""},
		{242, 682500, ""},
		{121, 780000, ""},
		{18611, 800000, ""},
		{248, 975000, ""},
		{107, 980000, ""},
		{50, 1100000, ""},
		{250, 1267500, ""},
		{217, 1365000, "Lil Peep"},
		{110, 1500000, ""},
		{121, 1500000, ""},
		{221, 1755000, ""},
		{18860, 1900000, ""},
		{68, 2000000, ""},
		{18616, 2300000, ""},
		{95, 2500000, "Мексу"},
		{223, 2535000, "Американец"},
		{290, 2730000, "Ядовито-зелёный"},
		{291, 2925000, "Модник 2"},
		{108, 3000000, "Full White"},
		{124, 3000000, "Хмурый"},
		{292, 3000000, "Социофоб"},
		{109, 3250000, "Батори"},
		{272, 3500000, "Mr. Бежевый"},
		{18, 3700000, ""},
		{51, 4500000, ""},
		{52, 4550000, ""},
		{125, 5000000, ""},
		{18617, 5500000, ""},
		{293, 5850000, ""},
		{294, 6000000, ""},
		{80, 6100000, ""},
		{146, 6200000, ""},
		{153, 6300000, ""},
		{120, 6400000, ""},
		{81, 6500000, ""},
		{83, 6600000, ""},
		{82, 6800000, ""},
		{213, 6800000, ""},
		{98, 6900000, ""},
		{127, 7000000, ""},
		{203, 7000000, ""},
		{42, 7500000, ""},
		{271, 8000000, ""},
		{273, 8500000, ""},
		{73, 9000000, "Пижон"},
		{106, 22800000, "Mr. Alen"}
};

new const g_magazinskinov_catalog_f[MSKIN_CATALOG_FEMALE_ITEMS][E_MSKIN_CATALOG] =
{
		{75,    1000,  "Casual A"},
		{169,   1400,  "Casual B"},
		{172,   1600,  "Office A"},
		{197,   1800,  "Office B"},
		{214,   2000,  "Sport A"},
		{201,   2100,  "Street A"},
		{215,   2200,  "Sport B"},
		{216,   2300,  "Street B"},
		{246,   2500,  "Classic A"},
		{5321,  4800,  "Premium A"},
		{5363,  5500,  "Premium B"},
		{5364,  5900,  "Premium C"}
};

stock MagazinSkinov_GetCatalogCount(sex)
{
	if(sex) return MSKIN_CATALOG_FEMALE_ITEMS;
	return MSKIN_CATALOG_MALE_ITEMS;
}

stock MagazinSkinov_GetCatalogSkinId(sex, index)
{
	if(sex) return g_magazinskinov_catalog_f[index][MSKIN_CAT_ID];
	return g_magazinskinov_catalog_m[index][MSKIN_CAT_ID];
}

stock MagazinSkinov_GetCatalogPrice(sex, index)
{
	if(sex) return g_magazinskinov_catalog_f[index][MSKIN_CAT_PRICE];
	return g_magazinskinov_catalog_m[index][MSKIN_CAT_PRICE];
}

new Text:g_skin_business[MSKIN_TD_COUNT];
new bool:p_skinshop_open[MAX_PLAYERS];
new bool:p_skinshop_active[MAX_PLAYERS];
new Float:p_skinshop_save_pos[MAX_PLAYERS][4];
new p_skinshop_save_int[MAX_PLAYERS];
new p_skinshop_save_vw[MAX_PLAYERS];
new p_skinshop_save_skin[MAX_PLAYERS];
new p_skinshop_count[MAX_PLAYERS];
new p_skinshop_index[MAX_PLAYERS];
new PlayerText:p_skinshop_price_ptd[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

stock MagazinSkinov_CreateTextDraws()
{
	g_skin_business[0] = TextDrawCreate(30.0002, 361.7333, "Box");
	TextDrawLetterSize(g_skin_business[0], 0.0000, 3.4999);
	TextDrawTextSize(g_skin_business[0], 66.0000, 0.0000);
	TextDrawAlignment(g_skin_business[0], 1);
	TextDrawColor(g_skin_business[0], -1);
	TextDrawUseBox(g_skin_business[0], 1);
	TextDrawBoxColor(g_skin_business[0], -1523963137);
	TextDrawBackgroundColor(g_skin_business[0], 255);
	TextDrawFont(g_skin_business[0], 1);
	TextDrawSetProportional(g_skin_business[0], 1);
	TextDrawSetShadow(g_skin_business[0], 0);

	g_skin_business[1] = TextDrawCreate(31.3332, 363.3927, "Box");
	TextDrawLetterSize(g_skin_business[1], 0.0000, 0.2666);
	TextDrawTextSize(g_skin_business[1], 65.0000, 0.0000);
	TextDrawAlignment(g_skin_business[1], 1);
	TextDrawColor(g_skin_business[1], -1);
	TextDrawUseBox(g_skin_business[1], 1);
	TextDrawBoxColor(g_skin_business[1], 255);
	TextDrawBackgroundColor(g_skin_business[1], 255);
	TextDrawFont(g_skin_business[1], 1);
	TextDrawSetProportional(g_skin_business[1], 1);
	TextDrawSetShadow(g_skin_business[1], 0);
	TextDrawSetSelectable(g_skin_business[1], 1);

	g_skin_business[2] = TextDrawCreate(31.6667, 388.6965, "Box");
	TextDrawLetterSize(g_skin_business[2], 0.0000, 0.2666);
	TextDrawTextSize(g_skin_business[2], 65.0000, 0.0000);
	TextDrawAlignment(g_skin_business[2], 1);
	TextDrawColor(g_skin_business[2], -1);
	TextDrawUseBox(g_skin_business[2], 1);
	TextDrawBoxColor(g_skin_business[2], 255);
	TextDrawBackgroundColor(g_skin_business[2], 255);
	TextDrawFont(g_skin_business[2], 1);
	TextDrawSetProportional(g_skin_business[2], 1);
	TextDrawSetShadow(g_skin_business[2], 0);
	TextDrawSetSelectable(g_skin_business[2], 1);

	g_skin_business[3] = TextDrawCreate(43.6665, 370.4443, "<<");
	TextDrawLetterSize(g_skin_business[3], 0.4000, 1.6000);
	TextDrawAlignment(g_skin_business[3], 1);
	TextDrawColor(g_skin_business[3], -1);
	TextDrawBackgroundColor(g_skin_business[3], 255);
	TextDrawFont(g_skin_business[3], 1);
	TextDrawSetProportional(g_skin_business[3], 1);
	TextDrawSetShadow(g_skin_business[3], 0);
	TextDrawSetSelectable(g_skin_business[3], 1);

	g_skin_business[4] = TextDrawCreate(247.3332, 340.1625, "Box");
	TextDrawLetterSize(g_skin_business[4], 0.0000, 6.1665);
	TextDrawTextSize(g_skin_business[4], 394.0000, 0.0000);
	TextDrawAlignment(g_skin_business[4], 1);
	TextDrawColor(g_skin_business[4], -1);
	TextDrawUseBox(g_skin_business[4], 1);
	TextDrawBoxColor(g_skin_business[4], -1523963137);
	TextDrawBackgroundColor(g_skin_business[4], 255);
	TextDrawFont(g_skin_business[4], 1);
	TextDrawSetProportional(g_skin_business[4], 1);
	TextDrawSetShadow(g_skin_business[4], 0);

	g_skin_business[5] = TextDrawCreate(582.3336, 362.1480, "Box");
	TextDrawLetterSize(g_skin_business[5], 0.0000, 3.4999);
	TextDrawTextSize(g_skin_business[5], 619.0000, 0.0000);
	TextDrawAlignment(g_skin_business[5], 1);
	TextDrawColor(g_skin_business[5], -1);
	TextDrawUseBox(g_skin_business[5], 1);
	TextDrawBoxColor(g_skin_business[5], -1523963137);
	TextDrawBackgroundColor(g_skin_business[5], 255);
	TextDrawFont(g_skin_business[5], 1);
	TextDrawSetProportional(g_skin_business[5], 1);
	TextDrawSetShadow(g_skin_business[5], 0);

	g_skin_business[6] = TextDrawCreate(583.6666, 363.8074, "Box");
	TextDrawLetterSize(g_skin_business[6], 0.0000, 0.2666);
	TextDrawTextSize(g_skin_business[6], 618.0000, 0.0000);
	TextDrawAlignment(g_skin_business[6], 1);
	TextDrawColor(g_skin_business[6], -1);
	TextDrawUseBox(g_skin_business[6], 1);
	TextDrawBoxColor(g_skin_business[6], 255);
	TextDrawBackgroundColor(g_skin_business[6], 255);
	TextDrawFont(g_skin_business[6], 1);
	TextDrawSetProportional(g_skin_business[6], 1);
	TextDrawSetShadow(g_skin_business[6], 0);
	TextDrawSetSelectable(g_skin_business[6], 1);

	g_skin_business[7] = TextDrawCreate(584.0000, 389.1111, "Box");
	TextDrawLetterSize(g_skin_business[7], 0.0000, 0.2666);
	TextDrawTextSize(g_skin_business[7], 618.0000, 0.0000);
	TextDrawAlignment(g_skin_business[7], 1);
	TextDrawColor(g_skin_business[7], -1);
	TextDrawUseBox(g_skin_business[7], 1);
	TextDrawBoxColor(g_skin_business[7], 255);
	TextDrawBackgroundColor(g_skin_business[7], 255);
	TextDrawFont(g_skin_business[7], 1);
	TextDrawSetProportional(g_skin_business[7], 1);
	TextDrawSetShadow(g_skin_business[7], 0);
	TextDrawSetSelectable(g_skin_business[7], 1);

	g_skin_business[8] = TextDrawCreate(595.9995, 371.2738, ">>");
	TextDrawLetterSize(g_skin_business[8], 0.4000, 1.6000);
	TextDrawAlignment(g_skin_business[8], 1);
	TextDrawColor(g_skin_business[8], -1);
	TextDrawBackgroundColor(g_skin_business[8], 255);
	TextDrawFont(g_skin_business[8], 1);
	TextDrawSetProportional(g_skin_business[8], 1);
	TextDrawSetShadow(g_skin_business[8], 0);
	TextDrawSetSelectable(g_skin_business[8], 1);

	g_skin_business[9] = TextDrawCreate(249.3332, 341.8219, "Box");
	TextDrawLetterSize(g_skin_business[9], 0.0000, 0.4332);
	TextDrawTextSize(g_skin_business[9], 392.0000, 0.0000);
	TextDrawAlignment(g_skin_business[9], 1);
	TextDrawColor(g_skin_business[9], -1);
	TextDrawUseBox(g_skin_business[9], 1);
	TextDrawBoxColor(g_skin_business[9], 255);
	TextDrawBackgroundColor(g_skin_business[9], 255);
	TextDrawFont(g_skin_business[9], 1);
	TextDrawSetProportional(g_skin_business[9], 1);
	TextDrawSetShadow(g_skin_business[9], 0);

	g_skin_business[10] = TextDrawCreate(249.6667, 379.5701, "Box");
	TextDrawLetterSize(g_skin_business[10], 0.0000, 1.4665);
	TextDrawTextSize(g_skin_business[10], 392.0000, 0.0000);
	TextDrawAlignment(g_skin_business[10], 1);
	TextDrawColor(g_skin_business[10], -1);
	TextDrawUseBox(g_skin_business[10], 1);
	TextDrawBoxColor(g_skin_business[10], 255);
	TextDrawBackgroundColor(g_skin_business[10], 255);
	TextDrawFont(g_skin_business[10], 1);
	TextDrawSetProportional(g_skin_business[10], 1);
	TextDrawSetShadow(g_skin_business[10], 0);

	g_skin_business[11] = TextDrawCreate(250.0000, 350.9479, "Box");
	TextDrawLetterSize(g_skin_business[11], 0.0000, 2.5999);
	TextDrawTextSize(g_skin_business[11], 316.0000, 0.0000);
	TextDrawAlignment(g_skin_business[11], 1);
	TextDrawColor(g_skin_business[11], -1);
	TextDrawUseBox(g_skin_business[11], 1);
	TextDrawBoxColor(g_skin_business[11], 255);
	TextDrawBackgroundColor(g_skin_business[11], 255);
	TextDrawFont(g_skin_business[11], 1);
	TextDrawSetProportional(g_skin_business[11], 1);
	TextDrawSetShadow(g_skin_business[11], 0);
	TextDrawSetSelectable(g_skin_business[11], 1);

	g_skin_business[12] = TextDrawCreate(320.6664, 351.3627, "Box");
	TextDrawLetterSize(g_skin_business[12], 0.0000, 2.5999);
	TextDrawTextSize(g_skin_business[12], 392.0000, 0.0000);
	TextDrawAlignment(g_skin_business[12], 1);
	TextDrawColor(g_skin_business[12], -1);
	TextDrawUseBox(g_skin_business[12], 1);
	TextDrawBoxColor(g_skin_business[12], 255);
	TextDrawBackgroundColor(g_skin_business[12], 255);
	TextDrawFont(g_skin_business[12], 1);
	TextDrawSetProportional(g_skin_business[12], 1);
	TextDrawSetShadow(g_skin_business[12], 0);
	TextDrawSetSelectable(g_skin_business[12], 1);

	g_skin_business[13] = TextDrawCreate(283.0000, 355.9500, "КУПИТЬ");
	TextDrawLetterSize(g_skin_business[13], 0.4000, 1.6000);
	TextDrawAlignment(g_skin_business[13], 2);
	TextDrawColor(g_skin_business[13], -1);
	TextDrawBackgroundColor(g_skin_business[13], 0);
	TextDrawFont(g_skin_business[13], 1);
	TextDrawSetProportional(g_skin_business[13], 1);
	TextDrawSetShadow(g_skin_business[13], 0);
	TextDrawSetSelectable(g_skin_business[13], 1);

	g_skin_business[14] = TextDrawCreate(356.3332, 356.3600, "ВЫХОД");
	TextDrawLetterSize(g_skin_business[14], 0.4000, 1.6000);
	TextDrawAlignment(g_skin_business[14], 2);
	TextDrawColor(g_skin_business[14], -1);
	TextDrawBackgroundColor(g_skin_business[14], 0);
	TextDrawFont(g_skin_business[14], 1);
	TextDrawSetProportional(g_skin_business[14], 1);
	TextDrawSetShadow(g_skin_business[14], 0);
	TextDrawSetSelectable(g_skin_business[14], 1);
}

stock MagazinSkinov_Init()
{
	MagazinSkinov_CreateTextDraws();
	printf("[MagazinSkinov]: Загружено %d текстдравов.", MSKIN_TD_COUNT);
}

stock MagazinSkinov_ResetPlayer(playerid)
{
	p_skinshop_open[playerid] = false;
	p_skinshop_active[playerid] = false;
	p_skinshop_count[playerid] = 0;
	p_skinshop_index[playerid] = 0;
}

stock MagazinSkinov_DestroyPricePTD(playerid)
{
	if(p_skinshop_price_ptd[playerid] != PlayerText:INVALID_TEXT_DRAW)
	{
		PlayerTextDrawDestroy(playerid, p_skinshop_price_ptd[playerid]);
		p_skinshop_price_ptd[playerid] = PlayerText:INVALID_TEXT_DRAW;
	}
}

stock MagazinSkinov_CreatePricePTD(playerid)
{
	MagazinSkinov_DestroyPricePTD(playerid);

	p_skinshop_price_ptd[playerid] = CreatePlayerTextDraw(playerid, MSKIN_PRICE_PTD_X, MSKIN_PRICE_PTD_Y, "_");
	PlayerTextDrawLetterSize(playerid, p_skinshop_price_ptd[playerid], 0.3500, 1.2000);
	PlayerTextDrawAlignment(playerid, p_skinshop_price_ptd[playerid], 2);
	PlayerTextDrawColor(playerid, p_skinshop_price_ptd[playerid], 0x808080FF);
	PlayerTextDrawBackgroundColor(playerid, p_skinshop_price_ptd[playerid], 0);
	PlayerTextDrawFont(playerid, p_skinshop_price_ptd[playerid], 1);
	PlayerTextDrawSetProportional(playerid, p_skinshop_price_ptd[playerid], 1);
	PlayerTextDrawSetShadow(playerid, p_skinshop_price_ptd[playerid], 0);
}

stock MagazinSkinov_UpdatePricePTD(playerid)
{
	new idx = p_skinshop_index[playerid];
	new sex = GetPlayerSex(playerid);
	new fmt_str[48];

	format(fmt_str, sizeof fmt_str, "ЦЕНА: %d", MagazinSkinov_GetCatalogPrice(sex, idx));
	PlayerTextDrawSetString(playerid, p_skinshop_price_ptd[playerid], fmt_str);
	PlayerTextDrawShow(playerid, p_skinshop_price_ptd[playerid]);
}

stock MagazinSkinov_LoadAssortment(playerid)
{
	p_skinshop_count[playerid] = MagazinSkinov_GetCatalogCount(GetPlayerSex(playerid));
	p_skinshop_index[playerid] = 0;
}

stock MagazinSkinov_SelectIndex(playerid, index)
{
	if(p_skinshop_count[playerid] <= 0)
		return 0;

	if(index < 0)
		index = p_skinshop_count[playerid] - 1;
	else if(index >= p_skinshop_count[playerid])
		index = 0;

	p_skinshop_index[playerid] = index;
	SetPlayerSkin(playerid, MagazinSkinov_GetCatalogSkinId(GetPlayerSex(playerid), index));
	MagazinSkinov_UpdatePricePTD(playerid);
	return 1;
}

stock MagazinSkinov_IsClothingBiz(playerid)
{
	new businessid = GetPlayerInBiz(playerid);

	if(businessid == -1)
		return 0;

	return GetBusinessData(businessid, B_TYPE) == BUSINESS_TYPE_CLOTHING_SHOP;
}

stock MagazinSkinov_TeleportToBizExit(playerid)
{
	new businessid = GetPlayerInBiz(playerid);

	if(businessid == -1)
		return 0;

	SetPlayerPosEx
	(
		playerid,
		GetBusinessData(businessid, B_EXIT_POS_X),
		GetBusinessData(businessid, B_EXIT_POS_Y),
		GetBusinessData(businessid, B_EXIT_POS_Z),
		GetBusinessData(businessid, B_EXIT_ANGLE),
		0,
		0,
		false
	);
	SetPlayerInBiz(playerid, -1);
	return 1;
}

stock MagazinSkinov_Show(playerid)
{
	for(new i = 0; i < MSKIN_TD_COUNT; i++)
		TextDrawShowForPlayer(playerid, g_skin_business[i]);

	p_skinshop_open[playerid] = true;
	SelectTextDraw(playerid, 0xFFFFFFFF);
}

stock MagazinSkinov_Hide(playerid)
{
	if(!p_skinshop_open[playerid])
		return 0;

	for(new i = 0; i < MSKIN_TD_COUNT; i++)
		TextDrawHideForPlayer(playerid, g_skin_business[i]);

	if(p_skinshop_price_ptd[playerid] != PlayerText:INVALID_TEXT_DRAW)
		PlayerTextDrawHide(playerid, p_skinshop_price_ptd[playerid]);

	CancelSelectTextDraw(playerid);
	p_skinshop_open[playerid] = false;
	return 1;
}

stock MagazinSkinov_EnterShop(playerid)
{
	if(p_skinshop_active[playerid])
		return 0;

	if(GetPlayerTeamEx(playerid) > 0)
	{
		SendClientMessage(playerid, 0xCECECEFF, "Вы состоите в организации, купить новую внешность нельзя");
		return 0;
	}

	if(!MagazinSkinov_IsClothingBiz(playerid))
		return 0;

	GetPlayerPos(playerid, p_skinshop_save_pos[playerid][0], p_skinshop_save_pos[playerid][1], p_skinshop_save_pos[playerid][2]);
	GetPlayerFacingAngle(playerid, p_skinshop_save_pos[playerid][3]);
	p_skinshop_save_int[playerid] = GetPlayerInterior(playerid);
	p_skinshop_save_vw[playerid] = GetPlayerVirtualWorld(playerid);
	p_skinshop_save_skin[playerid] = GetPlayerSkinEx(playerid);

	MagazinSkinov_LoadAssortment(playerid);

	TogglePlayerControllable(playerid, false);
	SetPlayerPosEx(playerid, MSKIN_REG_POS_X, MSKIN_REG_POS_Y, MSKIN_REG_POS_Z, MSKIN_REG_ANGLE, MSKIN_REG_INTERIOR, p_skinshop_save_vw[playerid], false);
	SetPlayerCameraPos(playerid, MSKIN_REG_CAM_X, MSKIN_REG_CAM_Y, MSKIN_REG_CAM_Z, 5.0050);
	SetPlayerCameraLookAt(playerid, MSKIN_REG_POS_X, MSKIN_REG_POS_Y, MSKIN_REG_POS_Z);

	SetPlayerSkin(playerid, MagazinSkinov_GetCatalogSkinId(GetPlayerSex(playerid), 0));
	p_skinshop_active[playerid] = true;

	MagazinSkinov_CreatePricePTD(playerid);
	MagazinSkinov_UpdatePricePTD(playerid);
	MagazinSkinov_Show(playerid);
	return 1;
}

stock MagazinSkinov_ExitShop(playerid, bool:keep_skin = false)
{
	if(!p_skinshop_active[playerid])
	{
		MagazinSkinov_Hide(playerid);
		return 0;
	}

	new bool:clothing_biz = bool:MagazinSkinov_IsClothingBiz(playerid);

	MagazinSkinov_Hide(playerid);
	MagazinSkinov_DestroyPricePTD(playerid);

	if(!keep_skin)
		SetPlayerSkin(playerid, p_skinshop_save_skin[playerid]);

	if(clothing_biz)
		MagazinSkinov_TeleportToBizExit(playerid);
	else
	{
		SetPlayerPosEx
		(
			playerid,
			p_skinshop_save_pos[playerid][0],
			p_skinshop_save_pos[playerid][1],
			p_skinshop_save_pos[playerid][2],
			p_skinshop_save_pos[playerid][3],
			p_skinshop_save_int[playerid],
			p_skinshop_save_vw[playerid],
			false
		);
	}
	p_skinshop_active[playerid] = false;
	// Полностью сбрасываем оба режима выбора. На мобильном клиенте одного
	// CancelSelectTextDraw недостаточно: после выхода остаются захвачены камера
	// и направление движения персонажа.
	HidePlayerSelectPanel(playerid);
	CancelSelectTextDraw(playerid);
	ClearAnimations(playerid, 1);
	TogglePlayerControllable(playerid, true);
	SetCameraBehindPlayer(playerid);
	return 1;
}

stock MagazinSkinov_BuySkin(playerid)
{
	if(!p_skinshop_active[playerid])
		return 0;

	new sex = GetPlayerSex(playerid);
	new idx = p_skinshop_index[playerid];
	new skinid = MagazinSkinov_GetCatalogSkinId(sex, idx);
	new price = MagazinSkinov_GetCatalogPrice(sex, idx);

	if(GetPlayerMoneyEx(playerid) < price)
	{
		SendClientMessage(playerid, 0xCECECEFF, "У Вас недостаточно денег для покупки скина");
		return 1;
	}

	if(!Inventory11_CanAddItemWeight(playerid, 134, 1))
	{
		SendClientMessage(playerid, 0xFF6347FF, "В инвентаре недостаточно места для одежды");
		return 1;
	}

	if(!Inventory11_AddSkinToInventory(playerid, skinid, skinid))
	{
		SendClientMessage(playerid, 0xFF6347FF, "Не удалось добавить одежду в инвентарь. Деньги не списаны");
		return 1;
	}

	GivePlayerMoneyEx(playerid, -price, "Покупка скина (магазин одежды)", false, true);
	SendClientMessage(playerid, 0x66CC00FF, "Одежда куплена и добавлена в инвентарь. Ваш текущий скин не изменен");
	MagazinSkinov_ExitShop(playerid, false);
	return 1;
}

stock MagazinSkinov_OnPlayerConnect(playerid)
{
	MagazinSkinov_ResetPlayer(playerid);
}

stock MagazinSkinov_OnPlayerDisconnect(playerid)
{
	MagazinSkinov_DestroyPricePTD(playerid);
	MagazinSkinov_ResetPlayer(playerid);
}

stock MagazinSkinov_OnClickTextDraw(playerid, Text:clickedid)
{
	if(!p_skinshop_open[playerid])
		return 0;

	if(clickedid == g_skin_business[MSKIN_TD_BTN_BUY] || clickedid == g_skin_business[MSKIN_TD_BTN_BUY_BOX])
	{
		MagazinSkinov_BuySkin(playerid);
		if(p_skinshop_open[playerid])
			SelectTextDraw(playerid, 0xFFFFFFFF);
		return 1;
	}

	if(clickedid == g_skin_business[MSKIN_TD_BTN_EXIT] || clickedid == g_skin_business[MSKIN_TD_BTN_EXIT_BOX])
	{
		MagazinSkinov_ExitShop(playerid, false);
		return 1;
	}

	if(clickedid == g_skin_business[MSKIN_TD_BTN_LEFT])
	{
		MagazinSkinov_SelectIndex(playerid, p_skinshop_index[playerid] - 1);
		SelectTextDraw(playerid, 0xFFFFFFFF);
		return 1;
	}

	if(clickedid == g_skin_business[MSKIN_TD_BTN_RIGHT])
	{
		MagazinSkinov_SelectIndex(playerid, p_skinshop_index[playerid] + 1);
		SelectTextDraw(playerid, 0xFFFFFFFF);
		return 1;
	}

	if(clickedid == Text:INVALID_TEXT_DRAW)
	{
		SelectTextDraw(playerid, 0xFFFFFFFF);
		return 1;
	}

	return 0;
}
// END INLINED: modules/m1stoks/magazinSkinov/magazinskinov.inc
// BEGIN INLINED: modules/m1stoks/transportCompany/transportcompany.inc
#if defined _transportcompany_included
	#endinput
#endif
#define _transportcompany_included

// BEGIN INLINED: modules/m1stoks/transportCompany/tcomp_defs.inc
#if defined _tcomp_defs_included
	#endinput
#endif
#define _tcomp_defs_included




#define TC_COLOR_ACCENT         0xFFFF24FF
#define TC_COLOR_MSG            0xFFFF24FF
#define TC_COLOR_WHITE          0xFFFFFFFF
#define TC_COLOR_ERROR          0xE04646FF
#define TC_COLOR_GOOD           0x66CC33FF
#define TC_MSG                  "{FFFF24}[Транспортная компания] {FFFFFF}"
#define TC_TITLE                "{FFFF24}Меню компании"
#define TC_CHAT_MAX             144

stock TC_Send(playerid, message[192])
{
	new tc_msg_buf[160];
	tc_msg_buf[0] = 0;
	strcat(tc_msg_buf, TC_MSG, sizeof tc_msg_buf);
	strcat(tc_msg_buf, message, sizeof tc_msg_buf);
	if(strlen(tc_msg_buf) < TC_CHAT_MAX)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, tc_msg_buf);
		return 1;
	}
	SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG);
	if(strlen(message) < TC_CHAT_MAX)
		SendClientMessage(playerid, TC_COLOR_MSG, message);
	else
	{
		new short[TC_CHAT_MAX];
		strmid(short, message, 0, TC_CHAT_MAX - 1);
		SendClientMessage(playerid, TC_COLOR_MSG, short);
	}
	return 1;
}



#define TC_JOIN_MIN_LEVEL           2
#define GPS_DIALOG_TC_OFFICES       29140
#define GPS_DIALOG_TUNING_ATELIER   29141

#define TC_COMPANIES_PER_OFFICE     12
#define TC_COMPANIES_TOTAL          24
#define TC_FLEET_TRIPS_MAX          50
#define TC_RENAME_PRICE             100000
#define TC_RENAME_COOLDOWN_DAYS     7
#define TC_WITHDRAW_FEE_PERCENT     3
#define TC_PRIVATE_ORDER_WAIT_SEC   120
#define TC_PRIVATE_AUTO_DELIVER_SEC 300
#define TC_GOV_PLUS_MIN_RATING_LVL  3
#define TC_GOV_PLUS_PAY_MIN         50000
#define TC_GOV_PLUS_PAY_MAX         200000
#define TC_FLEET_PAGE_SIZE          7
#define TC_COMPANY_PAGE_SIZE        7
#define TC_RENT_PAGE_SIZE           7
#define TC_ORDERS_PAGE_SIZE         10
#define TC_EMPLOYEE_PAGE_SIZE       8
#define TC_RENT_OCCUPY_SEC          120
#define TC_TRAILER_DEBUG            0
#define TC_TRAILER_LINK_MS          250
#define TC_TRAILER_RECOVER_COOLDOWN_MS 4000
#define TC_TRAILER_SOFT_RECOVER_MISSES 2
#define TC_TRAILER_HARD_RECOVER_MISSES 5
#define TC_TRAILER_RELINK_DISTANCE  55.0
#define TC_TRAILER_HARD_DISTANCE    180.0
#define TC_TRAILER_FORCE_SNAP_MS    700
#define TC_LOAD_UNLOAD_FREEZE_MS    5000
#define TC_LOAD_UNLOAD_WATCH_MS     500
#define TC_ORDER_PICKUP_RANGE       3.0
#define TC_ROUTE_CHECKPOINT_SIZE    15.0
#define TC_LOAD_POINT_RANGE         18.0
#define TC_UNLOAD_POINT_RANGE       18.0
#define TC_ROUTE_MAP_ICON_SLOT      50
#define TC_ROUTE_MAP_ICON_TYPE      55
#define TC_NOTIFY_INFO              2
#define TC_NOTIFY_SUCCESS           1
#define TC_NOTIFY_ERROR             3
#define TC_NOTIFY_DUR_LOAD          5
#define TC_NOTIFY_DUR               6
#define MAX_TC_FLEET                256
#define MAX_TC_RUNTIME_ORDERS       64
#define TC_COMMISSION_MIN           90
#define TC_COMMISSION_MAX           99
#define TC_SELL_REFUND_PERCENT      50
#define TC_FLEET_SELL_REFUND_PERCENT 50

#define TC_BUY_TRUCK_PRICE          250000
#define TC_BUY_VAN_PRICE            180000
#define TC_BUY_DAF_PRICE            300000
#define TC_REPAIR_PRICE             50000
#define TC_RENT_PRICE_MIN           1000
#define TC_RENT_PRICE_MAX           10000
#define TC_FIN_TRANSPORT            0
#define TC_FIN_WITHDRAW             1
#define TC_FIN_EXPENSE              2
#define TC_FIN_RENT                 3
#define TC_FIN_DEPOSIT              4
#define TC_FINANCE_DAYS             20
#define TC_UPGRADE_OFFICE_PRICE     50000
#define TC_UPGRADE_GARAGE_PRICE     1000000
#define TC_UPGRADE_LICENSE_PRICE    2000000

#define TC_UPGRADE_OFFICE           0
#define TC_UPGRADE_GARAGE           1
#define TC_UPGRADE_LICENSE          2

#define TC_EMPLOYEE_LIMIT_BASE        8
#define TC_EMPLOYEE_LIMIT_OFFICE      150
#define TC_FLEET_LIMIT_BASE           5
#define TC_FLEET_LIMIT_UPGRADE_ADD    20

#define TC_BUY_TYPE_TRUCK           0
#define TC_BUY_TYPE_VAN             1
#define TC_BUY_TYPE_DAF             2

#define TC_TRUCK_MODEL_DEFAULT      403
#define TC_VAN_MODEL_DEFAULT        498
#define TC_DAF_MODEL_DEFAULT        514

#define TC_OFFICE_BATUREVO      0
#define TC_OFFICE_BUSAEVO       1

#define TC_ORDER_GOV            0
#define TC_ORDER_PRIVATE        1
#define TC_ORDER_GOV_PLUS       2

#define TC_POINT_MINE       0
#define TC_POINT_WAREHOUSE  1
#define TC_POINT_PORT       2

#define TC_PARKING_SLOTS_MAX        20
#define TC_PARKING_TRUCK_SLOTS_USED 7
#define TC_PARKING_TRAILER_SLOTS_USED 7


new const Float: g_tc_building_enter[2][4] =
{
	{2327.705566, 2009.635742, 16.620204, 354.957916},
	{-426.065887, -1687.605712, 41.526901, 151.296875}
};

new const Float: g_tc_interior_enter[2][4] =
{
	{-0.251249, 2501.800000, 2011.005126, 0.857749},
	{-0.251249, 2501.800000, 2011.005126, 0.857749}
};

new const g_tc_interior_id = 1;
new const g_tc_interior_vw[2] = {1, 2};

stock TC_PlayerInTcInterior(playerid)
{
	if(GetPlayerInterior(playerid) != g_tc_interior_id) return 0;
	new vw = GetPlayerVirtualWorld(playerid);
	return (vw == g_tc_interior_vw[0] || vw == g_tc_interior_vw[1]);
}

stock TC_CanShowWorldCheckpoint(playerid)
{
	if(TC_PlayerInTcInterior(playerid)) return 0;
	if(GetPlayerInterior(playerid) != 0) return 0;
	return 1;
}

new Float:p_tc_route_mark_x[MAX_PLAYERS];
new Float:p_tc_route_mark_y[MAX_PLAYERS];
new Float:p_tc_route_mark_z[MAX_PLAYERS];
new bool:p_tc_route_marker_active[MAX_PLAYERS];

stock TC_RememberRouteMarkerPos(playerid, Float:x, Float:y, Float:z)
{
	p_tc_route_mark_x[playerid] = x;
	p_tc_route_mark_y[playerid] = y;
	p_tc_route_mark_z[playerid] = z;
	p_tc_route_marker_active[playerid] = true;
	return 1;
}

stock TC_GetActiveRouteMarkerPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!p_tc_route_marker_active[playerid]) return 0;
	x = p_tc_route_mark_x[playerid];
	y = p_tc_route_mark_y[playerid];
	z = p_tc_route_mark_z[playerid];
	return 1;
}

stock TC_ShowNotify(playerid, type, duration, caption[], btnCaption[] = "")
{
	new cap[160], btn[32];
	format(cap, sizeof cap, "%s", caption);
	format(btn, sizeof btn, "%s", btnCaption);
	ShowNotificationNew(playerid, type, duration, 0, 0, cap, btn);
	return 1;
}

stock TC_ApplyRouteMarker(playerid, Float:x, Float:y, Float:z, Float:size = TC_ROUTE_CHECKPOINT_SIZE)
{
	TC_RememberRouteMarkerPos(playerid, x, y, z);
	EnablePlayerGPS(playerid, TC_ROUTE_MAP_ICON_TYPE, x, y, z, "");
	SetPlayerCheckpoint(playerid, x, y, z, size, CP_ACTION_TYPE_NONE);
	SetPlayerMapIcon(playerid, TC_ROUTE_MAP_ICON_SLOT, x, y, z, TC_ROUTE_MAP_ICON_TYPE, 0xFFFF24FF, MAPICON_GLOBAL_CHECKPOINT);
	SetPlayerGPSInfo(playerid, G_ENABLED, GPS_STATUS_ON);
	return 1;
}

stock TC_ClearRouteMarker(playerid)
{
	p_tc_route_marker_active[playerid] = false;
	RemovePlayerMapIcon(playerid, TC_ROUTE_MAP_ICON_SLOT);
	DisablePlayerGPS(playerid);
	DisablePlayerCheckpoint(playerid);
	return 1;
}

stock TC_PlaceRouteCheckpoint(playerid, Float:x, Float:y, Float:z, Float:size = TC_ROUTE_CHECKPOINT_SIZE)
{
	return TC_ApplyRouteMarker(playerid, x, y, z, size);
}

stock TC_SetRouteCheckpoint(playerid, order_idx, bool:loading, Float:size = TC_ROUTE_CHECKPOINT_SIZE, bool:notify = true)
{
	new Float:x, Float:y, Float:z;
	TC_GetRoutePointPos(order_idx, loading, x, y, z, playerid);
	if(notify)
		TC_SendRouteMessage(playerid, order_idx, loading);
	TC_PlaceRouteCheckpoint(playerid, x, y, z, size);
	return 1;
}

new const Float: g_tc_building_exit[2][4] =
{
	{2327.662353, 2011.768310, 16.121875, 354.957916},
	{-426.906463, -1688.774536, 41.029911, 151.296875}
};

new const Float: g_tc_interior_exit[4] =
	{-0.251249, 2500.500000, 2011.005126, 0.857749};

new const Float: g_tc_marker_order[3] =
	{2.028566, 2503.603271, 2011.005126};

new const Float: g_tc_marker_company_list[3] =
	{-2.693784, 2504.187255, 2011.040039};

new const Float: g_tc_marker_rent[2][3] =
{
	{2320.732666, 2012.828857, 16.121875},
	{-413.875732, -1696.201904, 41.069911}
};

new const Float: g_tc_truck_parking[2][TC_PARKING_SLOTS_MAX][4] =
{
	{
		{2313.000000, 1992.950000, 15.660000, 2.060000},
		{2306.600000, 1992.980000, 15.670000, 2.060000},
		{2300.280000, 1992.310000, 15.660000, 2.060000},
		{2293.740000, 1992.360000, 15.670000, 2.060000},
		{2287.030000, 1993.110000, 15.660000, 2.060000},
		{2280.160000, 1992.920000, 15.670000, 2.060000},
		{2272.570000, 1992.890000, 15.670000, 2.060000},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}
	},
	{
		{-406.060000, -1689.130000, 40.600000, 149.760000},
		{-401.080000, -1692.530000, 40.600000, 149.760000},
		{-395.730000, -1695.842000, 40.600000, 149.760000},
		{-389.300000, -1699.543000, 40.600000, 149.760000},
		{-384.530000, -1702.104000, 40.600000, 149.760000},
		{-379.120000, -1705.562000, 40.600000, 149.760000},
		{-374.090000, -1709.198000, 40.600000, 149.760000},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}
	}
};

new const Float: g_tc_trailer_parking[2][TC_PARKING_SLOTS_MAX][4] =
{
	{
		{2287.050000, 2057.900000, 15.660000, 182.790000},
		{2296.590000, 2058.410000, 15.670000, 182.790000},
		{2307.050000, 2059.090000, 15.670000, 182.790000},
		{2316.680000, 2059.640000, 15.660000, 182.790000},
		{2342.840000, 2058.120000, 15.670000, 182.790000},
		{2348.800000, 2058.290000, 15.670000, 182.790000},
		{2355.140000, 2058.690000, 15.660000, 182.790000},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}
	},
	{
		{-386.510000, -1738.530000, 40.600000, 329.760000},
		{-392.660000, -1737.330000, 40.600000, 329.760000},
		{-397.250000, -1733.010000, 40.600000, 329.760000},
		{-402.830000, -1731.030000, 40.600000, 329.760000},
		{-408.050000, -1728.220000, 40.600000, 329.760000},
		{-412.630000, -1723.960000, 40.600000, 329.760000},
		{-417.880000, -1720.820000, 40.600000, 329.760000},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0}, {0.0, 0.0, 0.0, 0.0},
		{0.0, 0.0, 0.0, 0.0}
	}
};

new const Float: g_tc_gov_points[3][3] =
{
	{2435.937744, 1770.656372, 13.629980},
	{-1329.494628, -1549.859252, 60.841377},
	{-1733.898681, 2207.515869, 9.664999}
};

new const Float: g_tc_mine_load_points[][3] =
{
	{2435.937744, 1770.656372, 13.629980},
	{2372.254638, 1718.976196, 13.696249},
	{2316.785400, 1744.028442, 13.650000}
};

new const Float: g_tc_port_docks[][3] =
{
	{-1732.715454, 2195.462158, 9.674424},
	{-1732.835693, 2201.456298, 9.664999},
	{-1733.898681, 2207.515869, 9.664999},
	{-1734.082641, 2213.364257, 9.664999},
	{-1734.429321, 2219.395507, 9.664999}
};

new const g_tc_point_names[][] =
{
	"Шахта",
	"Загородный склад",
	"Порт"
};

new const g_tc_office_names[][] =
{
	"п. Батырево",
	"тгт. Бусаево"
};

enum E_TC_COMPANY
{
	TC_SQL_ID,
	TC_OFFICE,
	TC_SLOT,
	TC_OWNER_ID,
	TC_BALANCE,
	TC_COMMISSION,
	TC_LAST_RENAME,
	TC_UPG_OFFICE,
	TC_UPG_GARAGE,
	TC_UPG_LICENSE
};

enum E_TC_FLEET
{
	TF_SQL_ID,
	TF_COMPANY_ID,
	TF_MODEL_ID,
	TF_RENT_PRICE,
	TF_TRIPS_LEFT,
	TF_TRIPS_MAX,
	bool:TF_BROKEN,
	TF_RENTED_ACCOUNT_ID
};

enum E_TC_RT_ORDER
{
	RT_USED,
	RT_OFFICE,
	RT_TYPE,
	RT_FROM,
	RT_TO,
	RT_TOTAL_PAY,
	RT_MIN_RATING,
	RT_TRAILER_MODEL,
	RT_BUSINESS_ID,
	RT_AMOUNT,
	RT_SQL_ID,
	RT_CARGO_NAME[24],
	RT_TYPE_NAME[16]
};

new g_tc_companies[TC_COMPANIES_TOTAL][E_TC_COMPANY];
new g_tc_company_name[TC_COMPANIES_TOTAL][48];
new g_tc_owner_name[TC_COMPANIES_TOTAL][24];
new g_tc_company_rating[TC_COMPANIES_TOTAL];
new g_tc_companies_loaded;

new g_tc_fleet[MAX_TC_FLEET][E_TC_FLEET];
new g_tc_fleet_name[MAX_TC_FLEET][32];
new g_tc_fleet_loaded;

new g_tc_rt_orders[MAX_TC_RUNTIME_ORDERS][E_TC_RT_ORDER];
new g_tc_rt_orders_count;

new g_tc_private_business[MAX_BUSINESS] = {-1, ...};


new p_tc_company[MAX_PLAYERS] = {-1, ...};
new p_tc_rating[MAX_PLAYERS];
new p_tc_office[MAX_PLAYERS];
new p_tc_fleet_page[MAX_PLAYERS];
new p_tc_admin_company[MAX_PLAYERS] = {-1, ...};
new p_tc_join_company[MAX_PLAYERS] = {-1, ...};
new p_tc_company_page[MAX_PLAYERS];
new p_tc_rent_page[MAX_PLAYERS];
new p_tc_orders_page[MAX_PLAYERS];
new p_tc_emp_page[MAX_PLAYERS];
new p_tc_emp_view_mode[MAX_PLAYERS];
new p_tc_fire_target[MAX_PLAYERS][24];
new p_tc_emp_row_name[MAX_PLAYERS][TC_EMPLOYEE_PAGE_SIZE][24];
new p_tc_emp_list_shown[MAX_PLAYERS];
new p_tc_emp_total[MAX_PLAYERS];
new p_tc_finance_mode[MAX_PLAYERS];
new p_tc_upgrade_sel[MAX_PLAYERS];
new p_tc_pick_order[MAX_PLAYERS] = {-1, ...};
new p_tc_fleet_sel[MAX_PLAYERS] = {-1, ...};
new p_tc_rent_vehicle[MAX_PLAYERS] = {-1, ...};
new p_tc_rent_fleet_idx[MAX_PLAYERS] = {-1, ...};
new p_tc_trailer_vehicle[MAX_PLAYERS] = {-1, ...};
new p_tc_active_order[MAX_PLAYERS] = {-1, ...};
new p_tc_order_progress[MAX_PLAYERS];
new bool:p_tc_trailer_detached[MAX_PLAYERS];
new bool:p_tc_trailer_was_attached[MAX_PLAYERS];
new p_tc_trailer_detach_misses[MAX_PLAYERS];
new p_tc_trailer_last_recover_ms[MAX_PLAYERS];
new Float:p_tc_trailer_last_x[MAX_PLAYERS];
new Float:p_tc_trailer_last_y[MAX_PLAYERS];
new Float:p_tc_trailer_last_z[MAX_PLAYERS];
new Float:p_tc_trailer_last_a[MAX_PLAYERS];
new bool:p_tc_trailer_has_last_pos[MAX_PLAYERS];
new p_tc_trailer_lock_fail_since_ms[MAX_PLAYERS];
new p_tc_dest_port_dock[MAX_PLAYERS] = {-1, ...};
new p_tc_mine_load_dock[MAX_PLAYERS] = {-1, ...};
new p_tc_rent_timer[MAX_PLAYERS];
new p_tc_rent_sec_left[MAX_PLAYERS];
new p_tc_trailer_watch_timer[MAX_PLAYERS];
new p_tc_operation_timer[MAX_PLAYERS];
new p_tc_operation_watch_timer[MAX_PLAYERS];
new bool:p_tc_operation_loading[MAX_PLAYERS];

stock TC_GetRatingLevel(rating)
{
	if(rating < 10) return 1;
	return 2;
}

stock TC_GetCompanyIndexBySqlId(sql_id)
{
	if(sql_id <= 0) return -1;
	for(new i = 0; i < g_tc_companies_loaded; i++)
		if(g_tc_companies[i][TC_SQL_ID] == sql_id)
			return i;
	return -1;
}

stock TC_GetPlayerCompanyIndex(playerid)
{
	new cid = p_tc_company[playerid];
	if(cid < 0 || cid >= g_tc_companies_loaded)
		return -1;
	return cid;
}

stock TC_IsCompanyOwner(playerid, company_idx)
{
	if(company_idx < 0) return 0;
	return g_tc_companies[company_idx][TC_OWNER_ID] == GetPlayerAccountID(playerid);
}

stock TC_GetOwnedCompanyIndexByAccount(account_id)
{
	if(account_id <= 0) return -1;
	for(new i = 0; i < g_tc_companies_loaded; i++)
		if(g_tc_companies[i][TC_OWNER_ID] == account_id)
			return i;
	return -1;
}

stock TC_GetOwnedCompanyIndex(playerid)
{
	if(!IsPlayerConnected(playerid)) return -1;
	return TC_GetOwnedCompanyIndexByAccount(GetPlayerAccountID(playerid));
}

stock TC_PlayerHasTcCompany(playerid, allow_company_idx = -1)
{
	new member_idx = TC_GetPlayerCompanyIndex(playerid);
	if(member_idx != -1 && member_idx != allow_company_idx)
		return 1;

	new owned_idx = TC_GetOwnedCompanyIndex(playerid);
	if(owned_idx != -1 && owned_idx != allow_company_idx)
		return 1;

	new member_sql = GetPlayerData(playerid, P_TC_COMPANY_ID);
	if(member_sql > 0)
	{
		new idx = TC_GetCompanyIndexBySqlId(member_sql);
		if(idx != -1 && idx != allow_company_idx)
			return 1;
	}
	return 0;
}

stock TC_GetDriverPay(total_pay, commission_percent)
{
	new company_take = total_pay * commission_percent / 100;
	return total_pay - company_take;
}

stock TC_ModelNeedsTrailer(model_id)
{
	return (model_id == 403 || model_id == 413 || model_id == 514 || model_id == 515);
}

stock TC_GetRandomPortDock(&Float:x, &Float:y, &Float:z)
{
	new d = random(sizeof g_tc_port_docks);
	x = g_tc_port_docks[d][0];
	y = g_tc_port_docks[d][1];
	z = g_tc_port_docks[d][2];
	return d;
}

stock TC_IsNearAnyPortDock(playerid, Float:range = 14.0)
{
	for(new d = 0; d < sizeof g_tc_port_docks; d++)
		if(IsPlayerInRangeOfPoint(playerid, range, g_tc_port_docks[d][0], g_tc_port_docks[d][1], g_tc_port_docks[d][2]))
			return 1;
	return 0;
}

stock Float:TC_GetPointsDistanceKm(from_point, to_point)
{
	new Float:dx = g_tc_gov_points[from_point][0] - g_tc_gov_points[to_point][0];
	new Float:dy = g_tc_gov_points[from_point][1] - g_tc_gov_points[to_point][1];
	new Float:dz = g_tc_gov_points[from_point][2] - g_tc_gov_points[to_point][2];
	return floatsqroot(dx * dx + dy * dy + dz * dz) / 1000.0;
}

stock TC_IsParkingSlotValid(office, slot, bool:trailer = false)
{
	if(office < 0 || office > 1) return 0;
	if(slot < 0 || slot >= TC_PARKING_SLOTS_MAX) return 0;

	new used = trailer ? TC_PARKING_TRAILER_SLOTS_USED : TC_PARKING_TRUCK_SLOTS_USED;
	if(slot >= used) return 0;

	new Float:x, Float:y, Float:z;
	if(trailer)
	{
		x = g_tc_trailer_parking[office][slot][0];
		y = g_tc_trailer_parking[office][slot][1];
		z = g_tc_trailer_parking[office][slot][2];
	}
	else
	{
		x = g_tc_truck_parking[office][slot][0];
		y = g_tc_truck_parking[office][slot][1];
		z = g_tc_truck_parking[office][slot][2];
	}
	return (x != 0.0 || y != 0.0 || z != 0.0);
}

stock TC_GetTruckParkingPos(office, slot, &Float:x, &Float:y, &Float:z, &Float:a)
{
	if(!TC_IsParkingSlotValid(office, slot, false)) return 0;
	x = g_tc_truck_parking[office][slot][0];
	y = g_tc_truck_parking[office][slot][1];
	z = g_tc_truck_parking[office][slot][2];
	a = g_tc_truck_parking[office][slot][3];
	return 1;
}

stock TC_GetTrailerParkingPos(office, slot, &Float:x, &Float:y, &Float:z, &Float:a)
{
	if(!TC_IsParkingSlotValid(office, slot, true)) return 0;
	x = g_tc_trailer_parking[office][slot][0];
	y = g_tc_trailer_parking[office][slot][1];
	z = g_tc_trailer_parking[office][slot][2];
	a = g_tc_trailer_parking[office][slot][3];
	return 1;
}

stock TC_GetRandomTruckParkingSlot(office)
{
	#pragma unused office
	return random(TC_PARKING_TRUCK_SLOTS_USED);
}

stock TC_GetRandomTrailerParkingSlot(office)
{
	#pragma unused office
	return random(TC_PARKING_TRAILER_SLOTS_USED);
}

stock TC_GetOfficeByPlayer(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx != -1)
		return g_tc_companies[company_idx][TC_OFFICE];
	if(p_tc_office[playerid] >= 0 && p_tc_office[playerid] <= 1)
		return p_tc_office[playerid];
	return TC_OFFICE_BATUREVO;
}

stock TC_GetOwnerDisplayName(company_idx, dest[], size)
{
	if(company_idx < 0 || company_idx >= g_tc_companies_loaded)
	{
		format(dest, size, "-");
		return 0;
	}
	if(g_tc_companies[company_idx][TC_OWNER_ID] == -1)
	{
		format(dest, size, "Свободна");
		return 0;
	}
	format(dest, size, "%s", g_tc_owner_name[company_idx]);
	return 1;
}

stock TC_FormatMoneyBR(amount, dest[], size)
{
	new src[16], len;
	format(src, sizeof src, "%d", amount);
	len = strlen(src);

	new tmp[20], pos;
	for(new i = len - 1, grp; i >= 0; i--)
	{
		tmp[pos++] = src[i];
		grp++;
		if(grp == 3 && i > 0)
			tmp[pos++] = '.';
	}

	dest[0] = 0;
	for(new j = pos - 1; j >= 0; j--)
	{
		new ch[2];
		ch[0] = tmp[j];
		ch[1] = 0;
		strcat(dest, ch, size);
	}
	return 1;
}

stock TC_GetCompanyDisplayName(company_idx, dest[], size)
{
	if(company_idx < 0 || company_idx >= g_tc_companies_loaded)
	{
		dest[0] = 0;
		return 0;
	}
	format(dest, size, "%s", g_tc_company_name[company_idx]);
	return 1;
}

stock TC_IsValidCompanyName(const name[])
{
	new len = strlen(name);
	if(len < 2 || len > 32) return 0;
	for(new i = 0; i < len; i++)
	{
		new ch = name[i];
		if((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9') || ch == '_' || ch == ' ')
			continue;
		return 0;
	}
	return 1;
}

stock TC_GetMaxEmployees(company_idx)
{
	if(company_idx < 0 || company_idx >= g_tc_companies_loaded) return TC_EMPLOYEE_LIMIT_BASE;
	if(TC_CompanyHasUpgrade(company_idx, TC_UPGRADE_OFFICE))
		return TC_EMPLOYEE_LIMIT_OFFICE;
	return TC_EMPLOYEE_LIMIT_BASE;
}

stock TC_GetMaxFleetSlots(company_idx)
{
	new max_slots = TC_FLEET_LIMIT_BASE;
	if(company_idx < 0 || company_idx >= g_tc_companies_loaded) return max_slots;
	if(TC_CompanyHasUpgrade(company_idx, TC_UPGRADE_GARAGE))
		max_slots += TC_FLEET_LIMIT_UPGRADE_ADD;
	return max_slots;
}

stock TC_CompanyHasTransportLicense(company_idx)
{
	return TC_CompanyHasUpgrade(company_idx, TC_UPGRADE_LICENSE);
}

stock TC_CountEmployeesSync(company_sql_id)
{
	new query[96], Cache:result = Cache:0, count;
	mysql_format(mysql, query, sizeof query,
		"SELECT COUNT(*) AS cnt FROM tc_employees WHERE company_id=%d", company_sql_id);
	result = mysql_query(mysql, query, true);
	count = 0;
	if(cache_num_rows())
		count = cache_get_field_content_int(0, "cnt");
	cache_delete(result);
	return count;
}

stock TC_CheckEmploymentRequirements(playerid)
{
	if(GetPlayerLevel(playerid) < TC_JOIN_MIN_LEVEL)
	{
		new msg[128];
		format(msg, sizeof msg, TC_MSG"Для работы в ТК нужен {FFFF24}%d{FFFFFF} уровень.", TC_JOIN_MIN_LEVEL);
		SendClientMessage(playerid, TC_COLOR_ERROR, msg);
		return 0;
	}
	if(GetPlayerData(playerid, P_DRIVING_LIC) < 1)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Для работы в ТК нужны {FFFF24}водительские права{FFFFFF}.");
		return 0;
	}
	return 1;
}

stock TC_CompanyHasUpgrade(company_idx, upgrade_type)
{
	if(company_idx < 0 || company_idx >= g_tc_companies_loaded) return 0;
	switch(upgrade_type)
	{
		case TC_UPGRADE_OFFICE: return g_tc_companies[company_idx][TC_UPG_OFFICE] != 0;
		case TC_UPGRADE_GARAGE: return g_tc_companies[company_idx][TC_UPG_GARAGE] != 0;
		case TC_UPGRADE_LICENSE: return g_tc_companies[company_idx][TC_UPG_LICENSE] != 0;
	}
	return 0;
}

stock TC_GetFleetSellRefund(model_id)
{
	switch(model_id)
	{
		case TC_VAN_MODEL_DEFAULT: return TC_BUY_VAN_PRICE * TC_FLEET_SELL_REFUND_PERCENT / 100;
		case TC_DAF_MODEL_DEFAULT: return TC_BUY_DAF_PRICE * TC_FLEET_SELL_REFUND_PERCENT / 100;
	}
	return TC_BUY_TRUCK_PRICE * TC_FLEET_SELL_REFUND_PERCENT / 100;
}

stock TC_GetFleetCountForCompany(company_sql_id)
{
	new count;
	for(new i = 0; i < g_tc_fleet_loaded; i++)
		if(g_tc_fleet[i][TF_COMPANY_ID] == company_sql_id)
			count++;
	return count;
}

stock TC_GetFleetUsageText(vehicle_idx, dest[], size)
{
	if(g_tc_fleet[vehicle_idx][TF_BROKEN] || g_tc_fleet[vehicle_idx][TF_TRIPS_LEFT] <= 0)
		format(dest, size, "?? ?/?");
	else if(g_tc_fleet[vehicle_idx][TF_RENTED_ACCOUNT_ID] != -1)
		format(dest, size, "Арендована");
	else
		format(dest, size, "Не используется");
	return 1;
}

stock TC_GetRoutePointName(order_idx, bool:loading, dest[], size)
{
	if(order_idx < 0 || order_idx >= MAX_TC_RUNTIME_ORDERS || !g_tc_rt_orders[order_idx][RT_USED])
	{
		format(dest, size, "-");
		return 0;
	}

	if(!loading && g_tc_rt_orders[order_idx][RT_TYPE] == TC_ORDER_PRIVATE && g_tc_rt_orders[order_idx][RT_BUSINESS_ID] >= 0)
	{
		new bid = g_tc_rt_orders[order_idx][RT_BUSINESS_ID];
		format(dest, size, "Бизнес \"%s\"", GetBusinessData(bid, B_NAME));
		return 1;
	}

	new point = loading ? g_tc_rt_orders[order_idx][RT_FROM] : g_tc_rt_orders[order_idx][RT_TO];
	if(point == TC_POINT_PORT)
		format(dest, size, "Порт");
	else
		format(dest, size, "%s", g_tc_point_names[point]);
	return 1;
}

stock TC_GetRoutePointPos(order_idx, bool:loading, &Float:x, &Float:y, &Float:z, playerid = INVALID_PLAYER_ID)
{
	if(order_idx < 0 || order_idx >= MAX_TC_RUNTIME_ORDERS || !g_tc_rt_orders[order_idx][RT_USED])
		return 0;

	if(!loading && g_tc_rt_orders[order_idx][RT_TYPE] == TC_ORDER_PRIVATE && g_tc_rt_orders[order_idx][RT_BUSINESS_ID] >= 0)
	{
		new bid = g_tc_rt_orders[order_idx][RT_BUSINESS_ID];
		x = GetBusinessData(bid, B_POS_X);
		y = GetBusinessData(bid, B_POS_Y);
		z = GetBusinessData(bid, B_POS_Z);
		return 1;
	}

	new point = loading ? g_tc_rt_orders[order_idx][RT_FROM] : g_tc_rt_orders[order_idx][RT_TO];
	if(point == TC_POINT_PORT)
	{
		if(playerid != INVALID_PLAYER_ID && p_tc_dest_port_dock[playerid] >= 0 && p_tc_dest_port_dock[playerid] < sizeof g_tc_port_docks)
		{
			new d = p_tc_dest_port_dock[playerid];
			x = g_tc_port_docks[d][0];
			y = g_tc_port_docks[d][1];
			z = g_tc_port_docks[d][2];
			return 1;
		}
		x = g_tc_gov_points[TC_POINT_PORT][0];
		y = g_tc_gov_points[TC_POINT_PORT][1];
		z = g_tc_gov_points[TC_POINT_PORT][2];
		return 1;
	}
	if(point == TC_POINT_MINE)
	{
		new d = 0;
		if(playerid != INVALID_PLAYER_ID && p_tc_mine_load_dock[playerid] >= 0
			&& p_tc_mine_load_dock[playerid] < sizeof g_tc_mine_load_points)
			d = p_tc_mine_load_dock[playerid];
		x = g_tc_mine_load_points[d][0];
		y = g_tc_mine_load_points[d][1];
		z = g_tc_mine_load_points[d][2];
		return 1;
	}

	x = g_tc_gov_points[point][0];
	y = g_tc_gov_points[point][1];
	z = g_tc_gov_points[point][2];
	return 1;
}

stock TC_SendRouteMessage(playerid, order_idx, bool:loading)
{
	new pname[48];
	TC_GetRoutePointName(order_idx, loading, pname, sizeof pname);

	new msg[192];
	if(loading)
		format(msg, sizeof msg, "Загрузка: {FFFF24}%s{FFFFFF}.", pname);
	else
		format(msg, sizeof msg, "Разгрузка: {FFFF24}%s{FFFFFF}.", pname);
	TC_Send(playerid, msg);
	return 1;
}

stock TC_SelectMineLoadDock(playerid)
{
	new best = 0;
	new Float:px, Float:py, Float:pz, Float:dist, Float:best_dist = 999999.0;
	GetPlayerPos(playerid, px, py, pz);

	for(new i = 0; i < sizeof g_tc_mine_load_points; i++)
	{
		dist = floatsqroot(
			floatpower(px - g_tc_mine_load_points[i][0], 2.0) +
			floatpower(py - g_tc_mine_load_points[i][1], 2.0) +
			floatpower(pz - g_tc_mine_load_points[i][2], 2.0));
		if(dist < best_dist)
		{
			best_dist = dist;
			best = i;
		}
	}
	p_tc_mine_load_dock[playerid] = best;
	return best;
}

stock TC_IsAtMineLoadPoint(playerid, Float:range = TC_LOAD_POINT_RANGE)
{
	for(new i = 0; i < sizeof g_tc_mine_load_points; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, range,
			g_tc_mine_load_points[i][0], g_tc_mine_load_points[i][1], g_tc_mine_load_points[i][2]))
			return 1;
	}
	return 0;
}
// END INLINED: modules/m1stoks/transportCompany/tcomp_defs.inc
// BEGIN INLINED: modules/m1stoks/transportCompany/tcomp_logic.inc
#if defined _tcomp_logic_included
	#endinput
#endif
#define _tcomp_logic_included

forward TC_OnAdminCompanyListRefreshed(playerid);

stock TC_SyncPlayerCompanyBinding(playerid)
{
	new owned_idx = TC_GetOwnedCompanyIndex(playerid);
	if(owned_idx != -1)
	{
		p_tc_company[playerid] = owned_idx;
		new sql_id = g_tc_companies[owned_idx][TC_SQL_ID];
		if(GetPlayerData(playerid, P_TC_COMPANY_ID) != sql_id)
		{
			SetPlayerData(playerid, P_TC_COMPANY_ID, sql_id);
			UpdatePlayerDatabaseInt(playerid, "tc_company_id", sql_id);
		}
		return 1;
	}

	p_tc_company[playerid] = TC_GetCompanyIndexBySqlId(GetPlayerData(playerid, P_TC_COMPANY_ID));
	return 1;
}

stock TC_RequestAdminCompanyList(playerid)
{
	if(!GetPlayerAdminEx(playerid)) return 0;
	mysql_tquery(mysql,
		"SELECT tc.id, tc.owner_id, IFNULL(a.name,'') AS owner_name \
		FROM tc_companies tc LEFT JOIN accounts a ON a.id=tc.owner_id \
		ORDER BY tc.office ASC, tc.slot ASC",
		"TC_OnAdminCompanyListRefreshed", "d", playerid);
	return 1;
}

public TC_OnAdminCompanyListRefreshed(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	new rows = cache_num_rows();
	for(new r = 0; r < rows; r++)
	{
		new sql_id = cache_get_field_content_int(r, "id");
		new idx = TC_GetCompanyIndexBySqlId(sql_id);
		if(idx == -1) continue;

		g_tc_companies[idx][TC_OWNER_ID] = cache_get_field_content_int(r, "owner_id");
		cache_get_field_content(r, "owner_name", g_tc_owner_name[idx], mysql, 24);
		if(g_tc_companies[idx][TC_OWNER_ID] == -1)
			format(g_tc_owner_name[idx], 24, "Свободна");
	}

	TC_ShowAdminCompanyList(playerid);
	return 1;
}

forward TC_OnCompaniesSeeded();
forward TC_OnCompaniesLoaded();
forward TC_OnFleetLoaded();
forward TC_RentTimerTick(playerid);
forward TC_PrivateWaitTick(rt_idx);
forward TC_PrivateAutoDeliver(rt_idx);

stock TC_LogFinance(company_sql_id, type, amount, const note[])
{
	new query[192];
	mysql_format(mysql, query, sizeof query,
		"INSERT INTO tc_finance (company_id, type, amount, note, created_at) VALUES (%d, %d, %d, '%e', %d)",
		company_sql_id, type, amount, note, gettime());
	mysql_query(mysql, query, false);
}

stock TC_InstallSchema()
{
	mysql_query(mysql,
		"CREATE TABLE IF NOT EXISTS 	c_companies` (\
		`id` INT NOT NULL AUTO_INCREMENT,\
		`office` TINYINT NOT NULL DEFAULT 0,\
		`slot` TINYINT NOT NULL DEFAULT 0,\
		`name` VARCHAR(48) NOT NULL DEFAULT '',\
		`owner_id` INT NOT NULL DEFAULT -1,\
		`balance` BIGINT NOT NULL DEFAULT 0,\
		`commission` TINYINT NOT NULL DEFAULT 10,\
		`last_rename` INT NOT NULL DEFAULT 0,\
		`created_at` INT NOT NULL DEFAULT 0,\
		PRIMARY KEY (`id`), UNIQUE KEY `office_slot` (`office`,`slot`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);

	mysql_query(mysql,
		"CREATE TABLE IF NOT EXISTS 	c_fleet` (\
		`id` INT NOT NULL AUTO_INCREMENT,\
		`company_id` INT NOT NULL,\
		`model_id` INT NOT NULL DEFAULT 403,\
		`name` VARCHAR(32) NOT NULL DEFAULT '',\
		`rent_price` INT NOT NULL DEFAULT 1000,\
			rips_left` INT NOT NULL DEFAULT 50,\
			rips_max` INT NOT NULL DEFAULT 50,\
		`broken` TINYINT NOT NULL DEFAULT 0,\
		`rented_account_id` INT NOT NULL DEFAULT -1,\
		`created_at` INT NOT NULL DEFAULT 0,\
		PRIMARY KEY (`id`), KEY `company_id` (`company_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);

	mysql_query(mysql,
		"CREATE TABLE IF NOT EXISTS 	c_employees` (\
		`id` INT NOT NULL AUTO_INCREMENT,\
		`company_id` INT NOT NULL,\
		`account_id` INT NOT NULL,\
		`hired_at` INT NOT NULL DEFAULT 0,\
		`orders_done` INT NOT NULL DEFAULT 0,\
		`earned` BIGINT NOT NULL DEFAULT 0,\
		PRIMARY KEY (`id`), UNIQUE KEY `company_account` (`company_id`,`account_id`), KEY `account_id` (`account_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);

	mysql_query(mysql,
		"CREATE TABLE IF NOT EXISTS 	c_finance` (\
		`id` INT NOT NULL AUTO_INCREMENT,\
		`company_id` INT NOT NULL,\
			ype` TINYINT NOT NULL DEFAULT 0,\
		`amount` BIGINT NOT NULL DEFAULT 0,\
		`note` VARCHAR(64) NOT NULL DEFAULT '',\
		`created_at` INT NOT NULL DEFAULT 0,\
		PRIMARY KEY (`id`), KEY `company_id` (`company_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);

	mysql_query(mysql,
		"CREATE TABLE IF NOT EXISTS 	c_orders` (\
		`id` INT NOT NULL AUTO_INCREMENT,\
		`office` TINYINT NOT NULL DEFAULT 0,\
			ype` TINYINT NOT NULL DEFAULT 0,\
		`from_point` TINYINT NOT NULL DEFAULT 0,\
			o_point` TINYINT NOT NULL DEFAULT 0,\
		`business_id` INT NOT NULL DEFAULT -1,\
		`amount` INT NOT NULL DEFAULT 0,\
			otal_pay` INT NOT NULL DEFAULT 0,\
		`min_rating` INT NOT NULL DEFAULT 0,\
		`status` TINYINT NOT NULL DEFAULT 0,\
			aken_by` INT NOT NULL DEFAULT -1,\
		`created_at` INT NOT NULL DEFAULT 0,\
		PRIMARY KEY (`id`), KEY `business_id` (`business_id`), KEY `status` (`status`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);

	mysql_query(mysql, "ALTER TABLE `accounts` ADD COLUMN 	c_company_id` INT NOT NULL DEFAULT 0", false);
	mysql_query(mysql, "ALTER TABLE `accounts` ADD COLUMN 	c_rating` INT NOT NULL DEFAULT 0", false);
	mysql_query(mysql, "ALTER TABLE `accounts` ADD COLUMN 	c_rating_day` INT NOT NULL DEFAULT 0", false);
	mysql_query(mysql, "ALTER TABLE `accounts` ADD COLUMN 	c_rating_week` INT NOT NULL DEFAULT 0", false);
	mysql_query(mysql, "ALTER TABLE 	c_companies` ADD COLUMN `upgrade_office` TINYINT NOT NULL DEFAULT 0", false);
	mysql_query(mysql, "ALTER TABLE 	c_companies` ADD COLUMN `upgrade_garage` TINYINT NOT NULL DEFAULT 0", false);
	mysql_query(mysql, "ALTER TABLE 	c_companies` ADD COLUMN `upgrade_licenses` TINYINT NOT NULL DEFAULT 0", false);

	mysql_query(mysql, "ALTER TABLE 	c_companies` MODIFY `name` VARCHAR(48) CHARACTER SET cp1251 COLLATE cp1251_general_ci NOT NULL DEFAULT ''", false);
}

stock TC_Init()
{
	static bool:initialized;
	if(initialized) return 1;
	initialized = true;
	printf("[TransportCompany] build 2026-09-03 cargo-finalcp-v13");
	mysql_set_charset("cp1251");
	mysql_query(mysql, "SET NAMES cp1251", false);
	SetTimer("TC_TrailerLinkTimer", TC_TRAILER_LINK_MS, true);
	g_tc_companies_loaded = 0;
	g_tc_fleet_loaded = 0;
	g_tc_rt_orders_count = 0;
	TC_InstallSchema();
	TC_CreateWorldPickups();
	mysql_tquery(mysql, "SELECT COUNT(*) AS cnt FROM tc_companies", "TC_OnCompaniesSeeded", "");
	return 1;
}

forward TC_TrailerLinkTimer();
public TC_TrailerLinkTimer()
{
	foreach(new i : Player)
	{
		if(!IsPlayerLogged(i)) continue;
		if(p_tc_order_progress[i] == 1)
			TC_TryDetectTrailerLink(i);
		else if(p_tc_order_progress[i] >= 2)
		{
			TC_ForceTrailerLock(i, true);
			TC_MaintainTrailerOnRoute(i);

			// Mobile fallback: OnPlayerEnterCheckpoint can be missed after a large
			// vehicle/trailer sync correction. The visible route checkpoint is 15m,
			// so poll the final unload radius as well and start the same unload flow.
			if(p_tc_order_progress[i] == 3 && !p_tc_operation_timer[i] &&
				TC_IsPlayerInRentTruck(i) && p_tc_active_order[i] != -1 &&
				TC_IsAtUnloadPoint(i, p_tc_active_order[i]))
			{
				TC_LogTrailerServer(i, "unload_proximity_fallback");
				TC_StartLoadUnloadOperation(i, false);
			}
		}
	}
	return 1;
}

public TC_OnCompaniesSeeded()
{
	new count = cache_get_field_content_int(0, "cnt");
	if(count < TC_COMPANIES_TOTAL)
	{
		new query[192];
		for(new office = 0; office < 2; office++)
		{
			for(new slot = 0; slot < TC_COMPANIES_PER_OFFICE; slot++)
			{
				new display_num = office * TC_COMPANIES_PER_OFFICE + slot + 1;
				mysql_format(mysql, query, sizeof query,
					"INSERT IGNORE INTO tc_companies (office, slot, name, commission, owner_id, created_at) VALUES (%d, %d, 'N%d', 10, -1, %d)",
					office, slot, display_num, gettime());
				mysql_query(mysql, query, false);
			}
		}
	}
	TC_LoadCompanies();
	return 1;
}

stock TC_LoadCompanies()
{
	mysql_tquery(mysql,
		"SELECT tc.*, IFNULL(a.name,'') AS owner_name, \
		IFNULL((SELECT SUM(ac.tc_rating) FROM accounts ac WHERE ac.tc_company_id=tc.id),0) AS company_rating \
		FROM tc_companies tc LEFT JOIN accounts a ON a.id=tc.owner_id \
		ORDER BY tc.office ASC, tc.slot ASC",
		"TC_OnCompaniesLoaded", "");
}

public TC_OnCompaniesLoaded()
{
	g_tc_companies_loaded = cache_num_rows();
	if(g_tc_companies_loaded > TC_COMPANIES_TOTAL)
		g_tc_companies_loaded = TC_COMPANIES_TOTAL;

	for(new i = 0; i < g_tc_companies_loaded; i++)
	{
		g_tc_companies[i][TC_SQL_ID] = cache_get_field_content_int(i, "id");
		g_tc_companies[i][TC_OFFICE] = cache_get_field_content_int(i, "office");
		g_tc_companies[i][TC_SLOT] = cache_get_field_content_int(i, "slot");
		g_tc_companies[i][TC_OWNER_ID] = cache_get_field_content_int(i, "owner_id");
		cache_get_field_content(i, "name", g_tc_company_name[i], mysql, 48);
		g_tc_companies[i][TC_BALANCE] = cache_get_field_content_int(i, "balance");
		g_tc_companies[i][TC_COMMISSION] = cache_get_field_content_int(i, "commission");
		g_tc_companies[i][TC_LAST_RENAME] = cache_get_field_content_int(i, "last_rename");
		g_tc_companies[i][TC_UPG_OFFICE] = cache_get_field_content_int(i, "upgrade_office");
		g_tc_companies[i][TC_UPG_GARAGE] = cache_get_field_content_int(i, "upgrade_garage");
		g_tc_companies[i][TC_UPG_LICENSE] = cache_get_field_content_int(i, "upgrade_licenses");
		cache_get_field_content(i, "owner_name", g_tc_owner_name[i], mysql, 24);
		g_tc_company_rating[i] = cache_get_field_content_int(i, "company_rating");
	}

	TC_LoadFleet();
	TC_CreateWorldPickups();
	printf("[TransportCompany]: Загружено компаний: %d", g_tc_companies_loaded);

	foreach(new i : Player)
	{
		if(IsPlayerLogged(i))
			TC_SyncPlayerCompanyBinding(i);
	}
	return 1;
}

stock TC_LoadFleet()
{
	// Sprinter-only fleet: preserve existing fleet slots, but migrate every legacy
	// tractor/truck to the single supported company vehicle. No schema changes.
	mysql_query(mysql, "UPDATE tc_fleet SET model_id=498, name='Mercedes-Benz Sprinter' WHERE model_id<>498", false);
	mysql_tquery(mysql, "SELECT * FROM tc_fleet ORDER BY company_id ASC, id ASC", "TC_OnFleetLoaded", "");
}

public TC_OnFleetLoaded()
{
	g_tc_fleet_loaded = cache_num_rows();
	if(g_tc_fleet_loaded > MAX_TC_FLEET)
		g_tc_fleet_loaded = MAX_TC_FLEET;

	for(new i = 0; i < g_tc_fleet_loaded; i++)
	{
		g_tc_fleet[i][TF_SQL_ID] = cache_get_field_content_int(i, "id");
		g_tc_fleet[i][TF_COMPANY_ID] = cache_get_field_content_int(i, "company_id");
		g_tc_fleet[i][TF_MODEL_ID] = cache_get_field_content_int(i, "model_id");
		cache_get_field_content(i, "name", g_tc_fleet_name[i], mysql, 32);
		// Runtime hard guard for old/stale DB rows: TC fleet is Sprinter-only.
		if(g_tc_fleet[i][TF_MODEL_ID] != TC_VAN_MODEL_DEFAULT)
		{
			g_tc_fleet[i][TF_MODEL_ID] = TC_VAN_MODEL_DEFAULT;
			format(g_tc_fleet_name[i], 32, "Mercedes-Benz Sprinter");
		}
		g_tc_fleet[i][TF_RENT_PRICE] = cache_get_field_content_int(i, "rent_price");
		g_tc_fleet[i][TF_TRIPS_LEFT] = cache_get_field_content_int(i, "trips_left");
		g_tc_fleet[i][TF_TRIPS_MAX] = cache_get_field_content_int(i, "trips_max");
		if(g_tc_fleet[i][TF_TRIPS_MAX] <= 0) g_tc_fleet[i][TF_TRIPS_MAX] = TC_FLEET_TRIPS_MAX;
		g_tc_fleet[i][TF_BROKEN] = bool:cache_get_field_content_int(i, "broken");
		g_tc_fleet[i][TF_RENTED_ACCOUNT_ID] = cache_get_field_content_int(i, "rented_account_id");
	}

	printf("[TransportCompany]: Загружено ТС в автопарках: %d", g_tc_fleet_loaded);
	TC_ClearOrphanFleetRents();
	TC_GenerateGovOrders();
	return 1;
}

stock TC_GetFleetIndexBySqlId(sql_id)
{
	for(new i = 0; i < g_tc_fleet_loaded; i++)
		if(g_tc_fleet[i][TF_SQL_ID] == sql_id)
			return i;
	return -1;
}

stock TC_FindFreeOrderSlot()
{
	for(new i = 0; i < g_tc_rt_orders_count; i++)
		if(!g_tc_rt_orders[i][RT_USED])
			return i;
	if(g_tc_rt_orders_count < MAX_TC_RUNTIME_ORDERS)
		return g_tc_rt_orders_count++;
	return -1;
}

stock TC_GenerateGovOrders()
{
	g_tc_rt_orders_count = 0;

	new routes[][2] =
	{
		{TC_POINT_MINE, TC_POINT_WAREHOUSE},
		{TC_POINT_WAREHOUSE, TC_POINT_PORT},
		{TC_POINT_MINE, TC_POINT_PORT}
	};
	new cargos[][24] = {"Металл", "Уголь", "Контейнеры"};

	for(new office = 0; office < 2; office++)
	{
		for(new r = 0; r < sizeof routes; r++)
		{
			new idx = TC_FindFreeOrderSlot();
			if(idx == -1) return 1;

			g_tc_rt_orders[idx][RT_USED] = 1;
			g_tc_rt_orders[idx][RT_OFFICE] = office;
			g_tc_rt_orders[idx][RT_TYPE] = TC_ORDER_GOV;
			g_tc_rt_orders[idx][RT_FROM] = routes[r][0];
			g_tc_rt_orders[idx][RT_TO] = routes[r][1];
			g_tc_rt_orders[idx][RT_MIN_RATING] = 0;
			g_tc_rt_orders[idx][RT_TRAILER_MODEL] = 435;
			g_tc_rt_orders[idx][RT_BUSINESS_ID] = -1;
			g_tc_rt_orders[idx][RT_AMOUNT] = 0;
			g_tc_rt_orders[idx][RT_SQL_ID] = -1;
			format(g_tc_rt_orders[idx][RT_CARGO_NAME], 24, "%s", cargos[r % sizeof(cargos)]);
			format(g_tc_rt_orders[idx][RT_TYPE_NAME], 16, "Гос.");

			new Float:km = TC_GetPointsDistanceKm(routes[r][0], routes[r][1]);
			g_tc_rt_orders[idx][RT_TOTAL_PAY] = floatround(km * 10000.0) + random(5000) + 30000;
		}
	}
	return 1;
}

stock TC_AddGovPlusOrder(office)
{
	new idx = TC_FindFreeOrderSlot();
	if(idx == -1) return -1;

	new routes[][2] =
	{
		{TC_POINT_MINE, TC_POINT_WAREHOUSE},
		{TC_POINT_WAREHOUSE, TC_POINT_PORT},
		{TC_POINT_MINE, TC_POINT_PORT}
	};
	new r = random(sizeof routes);

	g_tc_rt_orders[idx][RT_USED] = 1;
	g_tc_rt_orders[idx][RT_OFFICE] = office;
	g_tc_rt_orders[idx][RT_TYPE] = TC_ORDER_GOV_PLUS;
	g_tc_rt_orders[idx][RT_FROM] = routes[r][0];
	g_tc_rt_orders[idx][RT_TO] = routes[r][1];
	g_tc_rt_orders[idx][RT_MIN_RATING] = 10;
	g_tc_rt_orders[idx][RT_TRAILER_MODEL] = 435;
	g_tc_rt_orders[idx][RT_BUSINESS_ID] = -1;
	g_tc_rt_orders[idx][RT_AMOUNT] = 0;
	g_tc_rt_orders[idx][RT_SQL_ID] = -1;
	format(g_tc_rt_orders[idx][RT_CARGO_NAME], 24, "Спецгруз");
	format(g_tc_rt_orders[idx][RT_TYPE_NAME], 16, "Гос+");
	g_tc_rt_orders[idx][RT_TOTAL_PAY] = TC_GOV_PLUS_PAY_MIN + random(TC_GOV_PLUS_PAY_MAX - TC_GOV_PLUS_PAY_MIN + 1);
	return idx;
}

stock TC_GetOfficeForBusiness(businessid)
{

	new Float:bx = GetBusinessData(businessid, B_POS_X);
	new Float:by = GetBusinessData(businessid, B_POS_Y);
	new Float:d0 = floatabs(bx - g_tc_building_enter[0][0]) + floatabs(by - g_tc_building_enter[0][1]);
	new Float:d1 = floatabs(bx - g_tc_building_enter[1][0]) + floatabs(by - g_tc_building_enter[1][1]);
	return (d1 < d0) ? 1 : 0;
}

stock TC_CreatePrivateOrder(businessid, amount)
{
	if(businessid < 0 || businessid >= MAX_BUSINESS) return -1;
	if(g_tc_private_business[businessid] != -1) return -2;

	new idx = TC_FindFreeOrderSlot();
	if(idx == -1) return -1;

	new office = TC_GetOfficeForBusiness(businessid);

	g_tc_rt_orders[idx][RT_USED] = 1;
	g_tc_rt_orders[idx][RT_OFFICE] = office;
	g_tc_rt_orders[idx][RT_TYPE] = TC_ORDER_PRIVATE;
	g_tc_rt_orders[idx][RT_FROM] = TC_POINT_WAREHOUSE;
	g_tc_rt_orders[idx][RT_TO] = TC_POINT_PORT;
	g_tc_rt_orders[idx][RT_MIN_RATING] = 0;
	g_tc_rt_orders[idx][RT_TRAILER_MODEL] = 435;
	g_tc_rt_orders[idx][RT_BUSINESS_ID] = businessid;
	g_tc_rt_orders[idx][RT_AMOUNT] = amount;
	g_tc_rt_orders[idx][RT_SQL_ID] = -1;
	format(g_tc_rt_orders[idx][RT_CARGO_NAME], 24, "Продукты");
	format(g_tc_rt_orders[idx][RT_TYPE_NAME], 16, "Частный");
	g_tc_rt_orders[idx][RT_TOTAL_PAY] = amount * 25 + 5000;

	g_tc_private_business[businessid] = idx;

	new query[160];
	mysql_format(mysql, query, sizeof query,
		"INSERT INTO tc_orders (office, type, from_point, to_point, business_id, amount, total_pay, status, created_at) \
		VALUES (%d, %d, %d, %d, %d, %d, %d, 0, %d)",
		office, TC_ORDER_PRIVATE, TC_POINT_WAREHOUSE, TC_POINT_PORT, businessid, amount,
		g_tc_rt_orders[idx][RT_TOTAL_PAY], gettime());
	mysql_query(mysql, query, false);

	SetTimerEx("TC_PrivateWaitTick", TC_PRIVATE_ORDER_WAIT_SEC * 1000, false, "i", idx);
	return idx;
}

stock TC_IsOrderActiveForAnyPlayer(rt_idx)
{
	if(rt_idx < 0 || rt_idx >= MAX_TC_RUNTIME_ORDERS) return 0;
	foreach(new i : Player)
	{
		if(!IsPlayerLogged(i)) continue;
		if(p_tc_active_order[i] == rt_idx) return 1;
	}
	return 0;
}

public TC_PrivateWaitTick(rt_idx)
{
	if(rt_idx < 0 || rt_idx >= MAX_TC_RUNTIME_ORDERS) return 0;
	if(!g_tc_rt_orders[rt_idx][RT_USED]) return 0;
	if(g_tc_rt_orders[rt_idx][RT_TYPE] != TC_ORDER_PRIVATE) return 0;

	new businessid = g_tc_rt_orders[rt_idx][RT_BUSINESS_ID];
	if(businessid < 0 || g_tc_private_business[businessid] != rt_idx) return 0;

	// Do not tell the business owner that nobody accepted the order when a
	// real player is already driving it. The watchdog is still armed so an
	// abandoned order can be auto-delivered later.
	if(!TC_IsOrderActiveForAnyPlayer(rt_idx))
	{
		new owner_acc = GetBusinessData(businessid, B_OWNER_ID);
		foreach(new i : Player)
		{
			if(IsPlayerLogged(i) && GetPlayerAccountID(i) == owner_acc)
			{
				SendClientMessage(i, TC_COLOR_MSG, TC_MSG"Никто из дальнобойщиков не взял заказ продуктов.");
				SendClientMessage(i, TC_COLOR_MSG, TC_MSG"Система имитирует доставку — продукты пополнятся через 5 минут.");
			}
		}
	}
	SetTimerEx("TC_PrivateAutoDeliver", TC_PRIVATE_AUTO_DELIVER_SEC * 1000, false, "i", rt_idx);
	return 1;
}

public TC_PrivateAutoDeliver(rt_idx)
{
	if(rt_idx < 0 || rt_idx >= MAX_TC_RUNTIME_ORDERS) return 0;
	if(!g_tc_rt_orders[rt_idx][RT_USED]) return 0;
	if(g_tc_rt_orders[rt_idx][RT_TYPE] != TC_ORDER_PRIVATE) return 0;

	new businessid = g_tc_rt_orders[rt_idx][RT_BUSINESS_ID];
	if(businessid < 0 || g_tc_private_business[businessid] != rt_idx) return 0;

	// Critical: an old auto-delivery timer must never invalidate an order that
	// a real driver has already accepted. Recheck later while the route is active.
	if(TC_IsOrderActiveForAnyPlayer(rt_idx))
	{
		SetTimerEx("TC_PrivateAutoDeliver", 60000, false, "i", rt_idx);
		return 1;
	}

	new amount = g_tc_rt_orders[rt_idx][RT_AMOUNT];
	AddBusinessData(businessid, B_PRODS, +, amount);

	new query[160];
	mysql_format(mysql, query, sizeof query,
		"UPDATE business SET products=%d WHERE id=%d LIMIT 1",
		GetBusinessData(businessid, B_PRODS), GetBusinessData(businessid, B_SQL_ID));
	mysql_query(mysql, query, false);

	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_orders SET status=4 WHERE business_id=%d AND status IN (0,1) ORDER BY id DESC LIMIT 1", businessid);
	mysql_query(mysql, query, false);

	new owner_acc = GetBusinessData(businessid, B_OWNER_ID);
	foreach(new i : Player)
		if(IsPlayerLogged(i) && GetPlayerAccountID(i) == owner_acc)
			SendClientMessage(i, TC_COLOR_MSG, TC_MSG"Продукты вашего бизнеса автоматически пополнены.");

	g_tc_private_business[businessid] = -1;
	g_tc_rt_orders[rt_idx][RT_USED] = 0;
	return 1;
}

stock TC_ReleaseFleetRentSlot(fleet_idx)
{
	if(fleet_idx < 0 || fleet_idx >= g_tc_fleet_loaded) return 0;
	if(g_tc_fleet[fleet_idx][TF_RENTED_ACCOUNT_ID] == -1) return 0;

	g_tc_fleet[fleet_idx][TF_RENTED_ACCOUNT_ID] = -1;
	new query[128];
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_fleet SET rented_account_id=-1 WHERE id=%d LIMIT 1",
		g_tc_fleet[fleet_idx][TF_SQL_ID]);
	mysql_query(mysql, query, false);
	return 1;
}

stock TC_ReleaseAccountFleetRents(account_id)
{
	if(account_id <= 0) return 0;

	new released;
	for(new i = 0; i < g_tc_fleet_loaded; i++)
	{
		if(g_tc_fleet[i][TF_RENTED_ACCOUNT_ID] == account_id)
		{
			TC_ReleaseFleetRentSlot(i);
			released++;
		}
	}
	return released;
}

stock TC_ClearOrphanFleetRents()
{
	for(new i = 0; i < g_tc_fleet_loaded; i++)
	{
		new acc = g_tc_fleet[i][TF_RENTED_ACCOUNT_ID];
		if(acc == -1) continue;

		new bool:has_active_rent;
		foreach(new p : Player)
		{
			if(!IsPlayerLogged(p)) continue;
			if(GetPlayerAccountID(p) != acc) continue;
			if(p_tc_rent_vehicle[p] != -1 && p_tc_rent_fleet_idx[p] == i)
			{
				has_active_rent = true;
				break;
			}
		}
		if(!has_active_rent)
			TC_ReleaseFleetRentSlot(i);
	}
	return 1;
}

stock TC_ResetPlayerWork(playerid)
{
	if(p_tc_rent_timer[playerid])
	{
		KillTimer(p_tc_rent_timer[playerid]);
		p_tc_rent_timer[playerid] = 0;
	}
	if(p_tc_trailer_watch_timer[playerid])
	{
		KillTimer(p_tc_trailer_watch_timer[playerid]);
		p_tc_trailer_watch_timer[playerid] = 0;
	}
	if(p_tc_operation_timer[playerid])
	{
		KillTimer(p_tc_operation_timer[playerid]);
		p_tc_operation_timer[playerid] = 0;
	}
	if(p_tc_operation_watch_timer[playerid])
	{
		KillTimer(p_tc_operation_watch_timer[playerid]);
		p_tc_operation_watch_timer[playerid] = 0;
	}
	p_tc_operation_loading[playerid] = false;
	p_tc_trailer_detach_misses[playerid] = 0;
	if(p_tc_rent_vehicle[playerid] != -1 && IsValidVehicle(p_tc_rent_vehicle[playerid]))
		TC_ForceDestroyVehicle(p_tc_rent_vehicle[playerid]);
	if(p_tc_trailer_vehicle[playerid] != -1 && IsValidVehicle(p_tc_trailer_vehicle[playerid]))
		TC_ForceDestroyVehicle(p_tc_trailer_vehicle[playerid]);
	else if(p_tc_trailer_vehicle[playerid] != -1)
		TC_ClearGuardedVehicle(p_tc_trailer_vehicle[playerid]);

	p_tc_rent_vehicle[playerid] = -1;
	p_tc_rent_fleet_idx[playerid] = -1;
	p_tc_trailer_vehicle[playerid] = -1;
	p_tc_active_order[playerid] = -1;
	p_tc_order_progress[playerid] = 0;
	p_tc_trailer_detached[playerid] = false;
	p_tc_trailer_was_attached[playerid] = false;
	p_tc_trailer_detach_misses[playerid] = 0;
	p_tc_trailer_last_recover_ms[playerid] = 0;
	p_tc_trailer_lock_fail_since_ms[playerid] = 0;
	p_tc_trailer_has_last_pos[playerid] = false;
	p_tc_dest_port_dock[playerid] = -1;
	p_tc_mine_load_dock[playerid] = -1;
	p_tc_rent_sec_left[playerid] = 0;
	TC_ClearRouteMarker(playerid);
}

stock TC_EndRent(playerid, bool:return_payment)
{
	#pragma unused return_payment

	new fleet_idx = p_tc_rent_fleet_idx[playerid];
	if(fleet_idx >= 0 && fleet_idx < g_tc_fleet_loaded)
		TC_ReleaseFleetRentSlot(fleet_idx);
	else if(IsPlayerLogged(playerid))
		TC_ReleaseAccountFleetRents(GetPlayerAccountID(playerid));

	TC_ResetPlayerWork(playerid);
	return 1;
}

stock TC_RestoreActiveCheckpoint(playerid)
{
	if(p_tc_active_order[playerid] == -1)
	{
		if(p_tc_rent_vehicle[playerid] != -1 && IsValidVehicle(p_tc_rent_vehicle[playerid]))
		{
			if(GetPlayerVehicleID(playerid) != p_tc_rent_vehicle[playerid])
			{
				new Float:x, Float:y, Float:z;
				GetVehiclePos(p_tc_rent_vehicle[playerid], x, y, z);
				TC_RememberRouteMarkerPos(playerid, x, y, z);
				SetPlayerCheckpoint(playerid, x, y, z, 5.0);
			}
		}
		return 1;
	}

	new order_idx = p_tc_active_order[playerid];
	new Float:x, Float:y, Float:z;

	if(p_tc_order_progress[playerid] == 1)
	{
		if(p_tc_trailer_vehicle[playerid] != -1 && IsValidVehicle(p_tc_trailer_vehicle[playerid]))
		{
			GetVehiclePos(p_tc_trailer_vehicle[playerid], x, y, z);
			TC_RememberRouteMarkerPos(playerid, x, y, z);
			SetPlayerCheckpoint(playerid, x, y, z, 6.0);
		}
		return 1;
	}
	if(p_tc_order_progress[playerid] == 2)
	{
		if(g_tc_rt_orders[order_idx][RT_FROM] == TC_POINT_MINE)
			TC_SelectMineLoadDock(playerid);
		TC_SetRouteCheckpoint(playerid, order_idx, true, TC_ROUTE_CHECKPOINT_SIZE, false);
		return 1;
	}
	if(p_tc_order_progress[playerid] == 3)
	{
		TC_SetUnloadCheckpoint(playerid, order_idx, false);
		return 1;
	}
	return 1;
}

stock TC_EnterOffice(playerid, office)
{
	if(office < 0 || office > 1) return 0;
	p_tc_office[playerid] = office;
	return 1;
}

stock TC_ExitOffice(playerid, office)
{
	#pragma unused office
	p_tc_office[playerid] = -1;
	TC_RestoreActiveCheckpoint(playerid);
	return 1;
}

stock TC_OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	#pragma unused oldinteriorid
	if(newinteriorid == g_tc_interior_id)
	{
		new vw = GetPlayerVirtualWorld(playerid);
		if(vw == g_tc_interior_vw[0]) { TC_EnterOffice(playerid, TC_OFFICE_BATUREVO); return 1; }
		if(vw == g_tc_interior_vw[1]) { TC_EnterOffice(playerid, TC_OFFICE_BUSAEVO); return 1; }
	}
	else if(p_tc_office[playerid] != -1)
	{
		TC_ExitOffice(playerid, p_tc_office[playerid]);
		return 1;
	}
	return 0;
}

stock TC_StartRent(playerid, fleet_idx)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	if(p_tc_rent_vehicle[playerid] != -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"У вас уже есть арендованный транспорт.");
		return 0;
	}
	if(fleet_idx < 0 || fleet_idx >= g_tc_fleet_loaded) return 0;
	if(g_tc_fleet[fleet_idx][TF_COMPANY_ID] != g_tc_companies[company_idx][TC_SQL_ID]) return 0;
	if(g_tc_fleet[fleet_idx][TF_MODEL_ID] != TC_VAN_MODEL_DEFAULT)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"В автопарке ТК разрешен только Mercedes-Benz Sprinter.");
		return 0;
	}

	if(g_tc_fleet[fleet_idx][TF_BROKEN] || g_tc_fleet[fleet_idx][TF_TRIPS_LEFT] <= 0)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Это ТС на техобслуживании.");
		return 0;
	}
	if(g_tc_fleet[fleet_idx][TF_RENTED_ACCOUNT_ID] != -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Это ТС уже арендовано.");
		return 0;
	}

	new price = g_tc_fleet[fleet_idx][TF_RENT_PRICE];
	if(GetPlayerMoneyEx(playerid) < price)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Недостаточно денег для аренды.");
		return 0;
	}

	new office = g_tc_companies[company_idx][TC_OFFICE];
	new slot = TC_GetRandomTruckParkingSlot(office);
	new Float:x, Float:y, Float:z, Float:a;
	if(!TC_GetTruckParkingPos(office, slot, x, y, z, a)) return 0;

	GivePlayerMoneyEx(playerid, -price, "Аренда ТК", true, true);

	new vehicleid = CreateVehicle(g_tc_fleet[fleet_idx][TF_MODEL_ID], x, y, z, a, random(126), random(126), -1, 0, VEHICLE_ACTION_TYPE_TC, playerid);
	TC_RegisterGuardedVehicle(vehicleid, playerid);
	p_tc_rent_vehicle[playerid] = vehicleid;
	p_tc_rent_fleet_idx[playerid] = fleet_idx;
	g_tc_fleet[fleet_idx][TF_RENTED_ACCOUNT_ID] = GetPlayerAccountID(playerid);

	new query[160];
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_fleet SET rented_account_id=%d WHERE id=%d LIMIT 1",
		GetPlayerAccountID(playerid), g_tc_fleet[fleet_idx][TF_SQL_ID]);
	mysql_query(mysql, query, false);

	g_tc_companies[company_idx][TC_BALANCE] += price;
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET balance=balance+%d WHERE id=%d LIMIT 1", price, g_tc_companies[company_idx][TC_SQL_ID]);
	mysql_query(mysql, query, false);
	TC_LogFinance(g_tc_companies[company_idx][TC_SQL_ID], TC_FIN_RENT, price, "Аренда ТС");

	if(TC_CanShowWorldCheckpoint(playerid))
		SetPlayerCheckpoint(playerid, x, y, z, 5.0);
	p_tc_rent_sec_left[playerid] = TC_RENT_OCCUPY_SEC;
	if(p_tc_rent_timer[playerid]) KillTimer(p_tc_rent_timer[playerid]);
	p_tc_rent_timer[playerid] = SetTimerEx("TC_RentTimerTick", 1000, true, "i", playerid);

	new price_msg[192];
	format(price_msg, sizeof price_msg, "Списано {FFFF24}%d{FFFFFF} руб. за аренду.", price);
	TC_Send(playerid, price_msg);
	TC_Send(playerid, "Транспорт отмечен на карте.");
	TC_Send(playerid, "У вас 2 минуты, чтобы занять машину.");
	return 1;
}

public TC_RentTimerTick(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(p_tc_rent_sec_left[playerid] <= 0) return 0;

	if(p_tc_office[playerid] != -1) return 1;

	if(p_tc_rent_vehicle[playerid] != -1 && GetPlayerVehicleID(playerid) == p_tc_rent_vehicle[playerid])
	{
		KillTimer(p_tc_rent_timer[playerid]);
		p_tc_rent_timer[playerid] = 0;
		p_tc_rent_sec_left[playerid] = 0;
		if(p_tc_active_order[playerid] == -1)
			DisablePlayerCheckpoint(playerid);
		else
			TC_RestoreActiveCheckpoint(playerid);
		return 1;
	}

	p_tc_rent_sec_left[playerid]--;

	if(p_tc_rent_sec_left[playerid] <= 0)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Время аренды истекло — вы не заняли транспорт.");
		TC_EndRent(playerid, false);
		return 1;
	}

	new sec_msg[48];
	format(sec_msg, sizeof sec_msg, "~y~%d~w~ сек.", p_tc_rent_sec_left[playerid]);
	GameTextForPlayer(playerid, sec_msg, 1100, 3);
	return 1;
}

stock TC_IsTrailerLinked(playerid)
{
	if(p_tc_rent_vehicle[playerid] == -1 || p_tc_trailer_vehicle[playerid] == -1)
		return 0;
	if(!IsValidVehicle(p_tc_rent_vehicle[playerid]) || !IsValidVehicle(p_tc_trailer_vehicle[playerid]))
		return 0;

	new truck = p_tc_rent_vehicle[playerid];
	new trailer = p_tc_trailer_vehicle[playerid];

	if(!IsTrailerAttachedToVehicle(truck))
		return 0;

	new linked = GetVehicleTrailer(truck);
	if(linked == trailer)
		return 1;

	if(linked == 0)
	{
		new Float:dist;
		if(TC_GetTrailerDistance(playerid, dist) && dist < 20.0)
			return 1;
	}
	return 0;
}

stock TC_GetTrailerDistance(playerid, &Float:dist)
{
	new truck = p_tc_rent_vehicle[playerid];
	new trailer = p_tc_trailer_vehicle[playerid];
	if(truck == -1 || trailer == -1) return 0;

	new Float:tx, Float:ty, Float:tz, Float:px, Float:py, Float:pz;
	GetVehiclePos(trailer, tx, ty, tz);
	GetVehiclePos(truck, px, py, pz);
	new Float:dx = tx - px, Float:dy = ty - py, Float:dz = tz - pz;
	dist = floatsqroot(dx * dx + dy * dy + dz * dz);
	return 1;
}

stock TC_IsTrailerNearTruck(playerid, Float:max_dist)
{
	new Float:dist;
	if(!TC_GetTrailerDistance(playerid, dist)) return 0;
	return dist <= max_dist;
}

stock TC_LogTrailerServer(playerid, const tag[])
{
	#if !TC_TRAILER_DEBUG
		#pragma unused tag
		return 0;
	#endif
	new tid = p_tc_trailer_vehicle[playerid];
	new truck = p_tc_rent_vehicle[playerid];
	new linked = -1;
	if(truck != -1 && IsValidVehicle(truck))
		linked = GetVehicleTrailer(truck);
	printf("[TC trailer] %s | p=%d tid=%d truck=%d link=%d prog=%d",
		tag, playerid, tid, truck, linked, p_tc_order_progress[playerid]);
	return 1;
}

stock TC_LogTrailerDebug(playerid, const tag[])
{
	return TC_LogTrailerServer(playerid, tag);
}

stock TC_OnTrailerLinked(playerid)
{
	if(p_tc_trailer_was_attached[playerid])
		return 1;

	p_tc_trailer_was_attached[playerid] = true;
	p_tc_trailer_detached[playerid] = false;
	p_tc_trailer_detach_misses[playerid] = 0;
	p_tc_trailer_lock_fail_since_ms[playerid] = 0;
	TC_OnTrailerAttached(playerid);
	return 1;
}

stock TC_TryDetectTrailerLink(playerid)
{
	if(p_tc_active_order[playerid] == -1 || p_tc_trailer_vehicle[playerid] == -1) return 0;
	if(p_tc_order_progress[playerid] < 1) return 0;

	new truck = p_tc_rent_vehicle[playerid];
	if(truck == -1 || GetPlayerVehicleID(playerid) != truck) return 0;
	if(!IsValidVehicle(truck)) return 0;

	new trailer = p_tc_trailer_vehicle[playerid];
	if(!IsValidVehicle(trailer)) return 0;

	if(TC_IsTrailerLinked(playerid))
		return TC_OnTrailerLinked(playerid);

	if(p_tc_order_progress[playerid] == 1 && TC_IsTrailerNearTruck(playerid, 22.0))
	{
		AttachTrailerToVehicle(trailer, truck);
		if(TC_IsTrailerLinked(playerid))
		{
			TC_LogTrailerServer(playerid, "link_detect_p1");
			return TC_OnTrailerLinked(playerid);
		}
	}
	return 0;
}

stock TC_EnsureTrailerForCargo(playerid)
{
	new model_id = TC_GetRentModelId(playerid);
	if(!TC_ModelNeedsTrailer(model_id)) return 1;

	// On an accepted route the assigned trailer is hard-locked. Never let the
	// old tolerant "near truck == linked" shortcut bypass a real re-attachment.
	if(p_tc_order_progress[playerid] >= 2)
	{
		if(TC_ForceTrailerLock(playerid, true)) return 1;
		TC_RecoverTrailerForActiveCargo(playerid, true);
		return p_tc_trailer_vehicle[playerid] != -1;
	}

	// Before the first coupling keep the old mobile-friendly detection.
	if(TC_IsTrailerLinked(playerid)) return 1;

	new truck = p_tc_rent_vehicle[playerid];
	new trailer = p_tc_trailer_vehicle[playerid];
	if(truck == -1 || trailer == -1 || !IsValidVehicle(truck) || !IsValidVehicle(trailer))
		return 0;
	if(GetPlayerVehicleID(playerid) != truck)
		return 0;

	SetVehicleVirtualWorld(trailer, GetVehicleVirtualWorld(truck));
	LinkVehicleToInterior(trailer, GetPlayerInterior(playerid));
	AttachTrailerToVehicle(trailer, truck);
	TC_LogTrailerServer(playerid, "reattach_before_cargo");
	if(TC_IsTrailerLinked(playerid))
	{
		p_tc_trailer_was_attached[playerid] = true;
		return 1;
	}
	return 0;
}

stock bool:TC_IsTrailerPhysicallyLinked(playerid)
{
	new truck = p_tc_rent_vehicle[playerid];
	new trailer = p_tc_trailer_vehicle[playerid];
	if(truck == -1 || trailer == -1 || !IsValidVehicle(truck) || !IsValidVehicle(trailer))
		return false;
	return IsTrailerAttachedToVehicle(truck) && GetVehicleTrailer(truck) == trailer;
}

// Hard lock for an accepted TC route. Once the driver has attached the assigned
// trailer (progress >= 2), the route must never remain in a detached state.
// Do NOT use TC_IsTrailerLinked() here: that helper intentionally treats a nearby
// trailer as linked for mobile tolerance and used to leave a detached trailer loose.
stock TC_ForceTrailerLock(playerid, bool:allow_snap = true)
{
	if(p_tc_active_order[playerid] == -1 || p_tc_order_progress[playerid] < 2)
		return 0;
	if(!TC_ModelNeedsTrailer(TC_GetRentModelId(playerid)))
		return 1;

	new truck = p_tc_rent_vehicle[playerid];
	new trailer = p_tc_trailer_vehicle[playerid];
	if(truck == -1 || trailer == -1 || !IsValidVehicle(truck) || !IsValidVehicle(trailer))
		return 0;

	TC_RegisterGuardedVehicle(trailer, playerid);
	SetVehicleHealth(trailer, 100000.0);
	SetVehicleVirtualWorld(trailer, GetVehicleVirtualWorld(truck));
	LinkVehicleToInterior(trailer, GetPlayerInterior(playerid));

	if(TC_IsTrailerPhysicallyLinked(playerid))
	{
		p_tc_trailer_lock_fail_since_ms[playerid] = 0;
		p_tc_trailer_detach_misses[playerid] = 0;
		p_tc_trailer_detached[playerid] = false;
		p_tc_trailer_was_attached[playerid] = true;
		GetVehiclePos(trailer,
			p_tc_trailer_last_x[playerid],
			p_tc_trailer_last_y[playerid],
			p_tc_trailer_last_z[playerid]);
		p_tc_trailer_has_last_pos[playerid] = true;
		return 1;
	}

	// If some foreign/stale trailer id is linked to our truck, discard that link.
	new linked = GetVehicleTrailer(truck);
	if(linked != 0 && linked != trailer)
		DetachTrailerFromVehicle(truck);

	// Immediate hard re-link. There is deliberately no distance/angle gate here:
	// the assigned cargo trailer belongs to this route and must stay on this truck.
	AttachTrailerToVehicle(trailer, truck);
	p_tc_trailer_detached[playerid] = false;
	p_tc_trailer_was_attached[playerid] = true;
	p_tc_trailer_detach_misses[playerid] = 0;
	p_tc_trailer_last_recover_ms[playerid] = 0;

	if(TC_IsTrailerPhysicallyLinked(playerid))
	{
		p_tc_trailer_lock_fail_since_ms[playerid] = 0;
		return 1;
	}

	// Some mobile clients can keep a stale trailer transform after a severe jackknife.
	// Keep re-sending attach every update; only if the strict link still cannot be
	// restored for a short period, snap the same trailer behind the truck once.
	new now = GetTickCount();
	if(p_tc_trailer_lock_fail_since_ms[playerid] == 0)
		p_tc_trailer_lock_fail_since_ms[playerid] = now;

	if(allow_snap && now - p_tc_trailer_lock_fail_since_ms[playerid] >= TC_TRAILER_FORCE_SNAP_MS)
	{
		new Float:x, Float:y, Float:z, Float:a;
		if(TC_GetTrailerRecoveryPos(playerid, x, y, z, a))
		{
			SetVehiclePos(trailer, x, y, z);
			SetVehicleZAngle(trailer, a);
			SetVehicleVirtualWorld(trailer, GetVehicleVirtualWorld(truck));
			LinkVehicleToInterior(trailer, GetPlayerInterior(playerid));
			AttachTrailerToVehicle(trailer, truck);
			p_tc_trailer_lock_fail_since_ms[playerid] = now;
			p_tc_trailer_last_x[playerid] = x;
			p_tc_trailer_last_y[playerid] = y;
			p_tc_trailer_last_z[playerid] = z;
			p_tc_trailer_has_last_pos[playerid] = true;
			TC_LogTrailerServer(playerid, "hard_lock_snap");
		}
	}
	return 1;
}

stock TC_GetTrailerRecoveryPos(playerid, &Float:x, &Float:y, &Float:z, &Float:a)
{
	new truck = p_tc_rent_vehicle[playerid];
	if(truck == -1 || !IsValidVehicle(truck)) return 0;
	GetVehiclePos(truck, x, y, z);
	GetVehicleZAngle(truck, a);

	// Put the recovered trailer behind the truck, not inside the cab.
	x += 8.0 * floatsin(-a + 180.0, degrees);
	y += 8.0 * floatcos(-a + 180.0, degrees);
	z += 0.25;
	return 1;
}

stock TC_RecoverTrailerForActiveCargo(playerid, bool:allow_recreate = true)
{
	if(p_tc_active_order[playerid] == -1 || p_tc_order_progress[playerid] < 2) return 0;
	if(!TC_ModelNeedsTrailer(TC_GetRentModelId(playerid))) return 1;

	new truck = p_tc_rent_vehicle[playerid];
	if(truck == -1 || !IsValidVehicle(truck)) return 0;
	if(GetPlayerVehicleID(playerid) != truck) return 0;

	new now = GetTickCount();
	if(p_tc_trailer_last_recover_ms[playerid] != 0 &&
		now - p_tc_trailer_last_recover_ms[playerid] < TC_TRAILER_RECOVER_COOLDOWN_MS)
		return 0;
	p_tc_trailer_last_recover_ms[playerid] = now;

	new trailer = p_tc_trailer_vehicle[playerid];
	if(trailer != -1 && IsValidVehicle(trailer))
	{
		// A valid route trailer is hard-locked regardless of current angle/distance.
		// This replaces the old wait-for-misses behavior for normal detach/desync.
		if(TC_ForceTrailerLock(playerid, true))
			return 1;

		TC_RegisterGuardedVehicle(trailer, playerid);
		SetVehicleHealth(trailer, 100000.0);
		SetVehicleVirtualWorld(trailer, GetVehicleVirtualWorld(truck));
		LinkVehicleToInterior(trailer, GetPlayerInterior(playerid));

		new Float:dist = 99999.0;
		TC_GetTrailerDistance(playerid, dist);

		// First recovery is non-destructive: only ask SA-MP to re-link the
		// existing trailer. No teleport while a normal sync recovery is possible.
		if(dist <= TC_TRAILER_RELINK_DISTANCE)
		{
			AttachTrailerToVehicle(trailer, truck);
			if(TC_IsTrailerLinked(playerid))
			{
				p_tc_trailer_detached[playerid] = false;
				p_tc_trailer_was_attached[playerid] = true;
				p_tc_trailer_detach_misses[playerid] = 0;
				GetVehiclePos(trailer, p_tc_trailer_last_x[playerid], p_tc_trailer_last_y[playerid], p_tc_trailer_last_z[playerid]);
				p_tc_trailer_has_last_pos[playerid] = true;
				TC_LogTrailerServer(playerid, "recover_relink");
				return 1;
			}
		}

		// After a sustained desync the server-side position can be stale forever.
		// Move only the tracked TC trailer behind its own truck and keep progress.
		if(p_tc_trailer_detach_misses[playerid] >= TC_TRAILER_HARD_RECOVER_MISSES || dist > TC_TRAILER_HARD_DISTANCE)
		{
			new Float:x, Float:y, Float:z, Float:a;
			if(TC_GetTrailerRecoveryPos(playerid, x, y, z, a))
			{
				SetVehiclePos(trailer, x, y, z);
				SetVehicleZAngle(trailer, a);
				SetVehicleVirtualWorld(trailer, GetVehicleVirtualWorld(truck));
				LinkVehicleToInterior(trailer, GetPlayerInterior(playerid));
				AttachTrailerToVehicle(trailer, truck);
				p_tc_trailer_detached[playerid] = false;
				p_tc_trailer_was_attached[playerid] = true;
				p_tc_trailer_detach_misses[playerid] = 0;
				p_tc_trailer_last_x[playerid] = x;
				p_tc_trailer_last_y[playerid] = y;
				p_tc_trailer_last_z[playerid] = z;
				p_tc_trailer_has_last_pos[playerid] = true;
				TC_LogTrailerServer(playerid, "recover_reposition");
				return 1;
			}
		}
		return 0;
	}

	if(!allow_recreate) return 0;

	// Vehicle id can be lost after OnVehicleDeath/stream glitches. Recreate the
	// trailer, but DO NOT change p_tc_order_progress: loaded cargo stays loaded.
	new order_idx = p_tc_active_order[playerid];
	if(order_idx < 0 || order_idx >= MAX_TC_RUNTIME_ORDERS) return 0;
	new trailer_model = g_tc_rt_orders[order_idx][RT_TRAILER_MODEL];
	new Float:x, Float:y, Float:z, Float:a;
	if(!TC_GetTrailerRecoveryPos(playerid, x, y, z, a)) return 0;

	new trailerid = CreateVehicle(trailer_model, x, y, z, a, random(126), random(126), -1, 0, VEHICLE_ACTION_TYPE_TC, playerid);
	if(trailerid == INVALID_VEHICLE_ID) return 0;

	p_tc_trailer_vehicle[playerid] = trailerid;
	TC_RegisterGuardedVehicle(trailerid, playerid);
	SetVehicleHealth(trailerid, 100000.0);
	SetVehicleVirtualWorld(trailerid, GetVehicleVirtualWorld(truck));
	LinkVehicleToInterior(trailerid, GetPlayerInterior(playerid));
	AttachTrailerToVehicle(trailerid, truck);

	p_tc_trailer_detached[playerid] = false;
	p_tc_trailer_was_attached[playerid] = true;
	p_tc_trailer_detach_misses[playerid] = 0;
	p_tc_trailer_last_x[playerid] = x;
	p_tc_trailer_last_y[playerid] = y;
	p_tc_trailer_last_z[playerid] = z;
	p_tc_trailer_has_last_pos[playerid] = true;
	TC_LogTrailerServer(playerid, "recover_recreate");

	// Restore the marker for the stage that was active before recovery.
	TC_RestoreActiveCheckpoint(playerid);
	return 1;
}

forward TC_RecoverTrailerDelayed(playerid, order_idx, progress, epoch);
public TC_RecoverTrailerDelayed(playerid, order_idx, progress, epoch)
{
	if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
	if(g_BRAuthEpoch[playerid] != epoch) return 0;
	if(p_tc_active_order[playerid] != order_idx || p_tc_order_progress[playerid] != progress) return 0;
	if(progress < 2) return 0;
	return TC_RecoverTrailerForActiveCargo(playerid, true);
}

stock TC_MaintainTrailerOnRoute(playerid)
{
	if(p_tc_active_order[playerid] == -1 || p_tc_order_progress[playerid] < 2)
		return 0;

	new model_id = TC_GetRentModelId(playerid);
	if(!TC_ModelNeedsTrailer(model_id)) return 1;

	new truck = p_tc_rent_vehicle[playerid];
	if(truck == -1 || !IsValidVehicle(truck)) return 0;

	new trailer = p_tc_trailer_vehicle[playerid];
	if(trailer == -1 || !IsValidVehicle(trailer))
	{
		if(trailer != -1) TC_ClearGuardedVehicle(trailer);
		p_tc_trailer_vehicle[playerid] = -1;
		p_tc_trailer_last_recover_ms[playerid] = 0;
		p_tc_trailer_lock_fail_since_ms[playerid] = 0;

		// Real entity loss is the only case where recovery/recreation is needed.
		// Cargo/order progress is preserved; no "detached for 10 seconds" state.
		if(GetPlayerVehicleID(playerid) == truck)
			TC_RecoverTrailerForActiveCargo(playerid, true);
		return p_tc_trailer_vehicle[playerid] != -1;
	}

	// A valid assigned trailer is never allowed to remain detached. This call has
	// no angle or distance restriction and is repeated by OnPlayerUpdate + timer.
	return TC_ForceTrailerLock(playerid, true);
}

stock TC_SpawnTrailerForPlayer(playerid, bool:respawn_detach)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || p_tc_rent_vehicle[playerid] == -1) return 0;

	if(p_tc_active_order[playerid] == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Сначала возьмите заказ у путевых листов.");
		return 0;
	}

	new order_idx = p_tc_active_order[playerid];
	new model_id = g_tc_fleet[p_tc_rent_fleet_idx[playerid]][TF_MODEL_ID];

	if(!TC_ModelNeedsTrailer(model_id))
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Для этого транспорта прицеп не нужен.");
		return 0;
	}

	if(p_tc_trailer_vehicle[playerid] != -1 && IsValidVehicle(p_tc_trailer_vehicle[playerid]))
	{
		if(!respawn_detach && !p_tc_trailer_detached[playerid])
		{
			SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Прицеп уже создан. Подцепите его к фуре.");
			return 0;
		}
		TC_ForceDestroyVehicle(p_tc_trailer_vehicle[playerid]);
		p_tc_trailer_vehicle[playerid] = -1;
	}

	p_tc_trailer_detached[playerid] = false;
	p_tc_trailer_was_attached[playerid] = false;
	p_tc_trailer_detach_misses[playerid] = 0;
	p_tc_trailer_last_recover_ms[playerid] = 0;
	p_tc_trailer_lock_fail_since_ms[playerid] = 0;
	p_tc_order_progress[playerid] = 1;

	new office = g_tc_companies[company_idx][TC_OFFICE];
	new slot = TC_GetRandomTrailerParkingSlot(office);
	new Float:x, Float:y, Float:z, Float:a;
	if(!TC_GetTrailerParkingPos(office, slot, x, y, z, a)) return 0;

	new trailer_model = g_tc_rt_orders[order_idx][RT_TRAILER_MODEL];

	new trailerid = CreateVehicle(trailer_model, x, y, z, a, random(126), random(126), -1, 0, VEHICLE_ACTION_TYPE_TC, playerid);
	if(trailerid == INVALID_VEHICLE_ID)
		return 0;

	p_tc_trailer_vehicle[playerid] = trailerid;
	TC_RegisterGuardedVehicle(trailerid, playerid);
	SetVehicleHealth(trailerid, 100000.0);

	SetVehicleVirtualWorld(trailerid, GetVehicleVirtualWorld(p_tc_rent_vehicle[playerid]));

	p_tc_trailer_last_x[playerid] = x;
	p_tc_trailer_last_y[playerid] = y;
	p_tc_trailer_last_z[playerid] = z;
	p_tc_trailer_has_last_pos[playerid] = true;

	SendClientMessage(playerid, TC_COLOR_GOOD, TC_MSG"Прицеп подготовлен. Подцепите его к фуре.");
	TC_LogTrailerServer(playerid, "spawn");

	if(TC_CanShowWorldCheckpoint(playerid))
	{
		TC_RememberRouteMarkerPos(playerid, x, y, z);
		SetPlayerCheckpoint(playerid, x, y, z, 6.0);
	}
	TC_Send(playerid, "Подъедьте к прицепу и подцепите его к фуре.");
	return 1;
}

stock TC_OnTrailerAttached(playerid)
{
	if(p_tc_active_order[playerid] == -1) return 0;

	new order_idx = p_tc_active_order[playerid];

	if(p_tc_order_progress[playerid] == 1)
	{
		TC_ClearRouteMarker(playerid);
		p_tc_order_progress[playerid] = 2;
		if(g_tc_rt_orders[order_idx][RT_FROM] == TC_POINT_MINE)
			TC_SelectMineLoadDock(playerid);
		TC_SetRouteCheckpoint(playerid, order_idx, true, TC_ROUTE_CHECKPOINT_SIZE);
		TC_LogTrailerServer(playerid, "attached_route_cp");
	}
	return 1;
}

stock TC_SetUnloadCheckpoint(playerid, order_idx, bool:notify = true)
{
	new Float:x, Float:y, Float:z;
	new to_point = g_tc_rt_orders[order_idx][RT_TO];

	if(g_tc_rt_orders[order_idx][RT_TYPE] == TC_ORDER_PRIVATE && g_tc_rt_orders[order_idx][RT_BUSINESS_ID] >= 0)
	{
		new bid = g_tc_rt_orders[order_idx][RT_BUSINESS_ID];
		x = GetBusinessData(bid, B_POS_X);
		y = GetBusinessData(bid, B_POS_Y);
		z = GetBusinessData(bid, B_POS_Z);
		p_tc_dest_port_dock[playerid] = -1;
	}
	else if(to_point == TC_POINT_PORT)
	{
		p_tc_dest_port_dock[playerid] = TC_GetRandomPortDock(x, y, z);
	}
	else
	{
		p_tc_dest_port_dock[playerid] = -1;
		TC_GetRoutePointPos(order_idx, false, x, y, z, playerid);
	}

	if(notify)
		TC_SendRouteMessage(playerid, order_idx, false);
	TC_PlaceRouteCheckpoint(playerid, x, y, z, TC_ROUTE_CHECKPOINT_SIZE);
	return 1;
}

stock TC_ShowReturnRentDialog(playerid)
{
	if(p_tc_rent_vehicle[playerid] == -1)
	{
		TC_ShowRentList(playerid, 0);
		return 0;
	}

	new fmt_str[256];
	if(p_tc_active_order[playerid] != -1)
		format(fmt_str, sizeof fmt_str,
			"{FFFFFF}У вас арендован транспорт и активный заказ.\n\
Сдать Sprinter сейчас — заказ будет отменён.\n\n\
Продажа машины");
	else
		format(fmt_str, sizeof fmt_str,
			"{FFFFFF}У вас уже арендован транспорт.\n\
Сдать Sprinter и завершить аренду?");

	Dialog(playerid, DIALOG_TC_RETURN_RENT, DIALOG_STYLE_MSGBOX,
		"{FFFF24}Сдача транспорта", fmt_str, "Сдать", "Отмена");
	return 1;
}

stock TC_ReturnRentedTruck(playerid)
{
	if(p_tc_rent_vehicle[playerid] == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"У вас нет арендованного транспорта.");
		return 0;
	}

	if(p_tc_active_order[playerid] != -1)
	{
		new order_idx = p_tc_active_order[playerid];
		if(order_idx >= 0 && g_tc_rt_orders[order_idx][RT_TYPE] == TC_ORDER_PRIVATE)
		{
			new bid = g_tc_rt_orders[order_idx][RT_BUSINESS_ID];
			if(bid >= 0) g_tc_private_business[bid] = -1;
		}
		if(order_idx >= 0 && g_tc_rt_orders[order_idx][RT_TYPE] != TC_ORDER_GOV)
			g_tc_rt_orders[order_idx][RT_USED] = 0;
	}

	TC_EndRent(playerid, false);
	SendClientMessage(playerid, TC_COLOR_GOOD, TC_MSG"Транспорт сдан. Аренда завершена.");
	return 1;
}

stock TC_GetRentModelId(playerid)
{
	if(p_tc_rent_fleet_idx[playerid] >= 0 && p_tc_rent_fleet_idx[playerid] < g_tc_fleet_loaded)
		return g_tc_fleet[p_tc_rent_fleet_idx[playerid]][TF_MODEL_ID];
	if(p_tc_rent_vehicle[playerid] != -1 && IsValidVehicle(p_tc_rent_vehicle[playerid]))
		return GetVehicleModel(p_tc_rent_vehicle[playerid]);
	return TC_VAN_MODEL_DEFAULT;
}

stock TC_AcceptOrder(playerid, order_idx)
{
	if(order_idx < 0 || order_idx >= MAX_TC_RUNTIME_ORDERS) return 0;
	if(!g_tc_rt_orders[order_idx][RT_USED]) return 0;
	if(p_tc_active_order[playerid] != -1)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Сначала завершите текущий заказ.");
		return 0;
	}
	if(g_tc_rt_orders[order_idx][RT_TYPE] != TC_ORDER_GOV && TC_IsOrderActiveForAnyPlayer(order_idx))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Этот заказ уже взял другой водитель.");
		return 0;
	}

	new company_idx = p_tc_company[playerid];
	if(g_tc_rt_orders[order_idx][RT_TYPE] == TC_ORDER_PRIVATE)
	{
		if(company_idx == -1 || !TC_CompanyHasTransportLicense(company_idx))
		{
			SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Частные заказы доступны после покупки лицензии на перевозку.");
			return 0;
		}
	}

	p_tc_active_order[playerid] = order_idx;

	if(g_tc_rt_orders[order_idx][RT_TYPE] == TC_ORDER_PRIVATE)
	{
		new bid = g_tc_rt_orders[order_idx][RT_BUSINESS_ID];
		new query[128];
		mysql_format(mysql, query, sizeof query,
			"UPDATE tc_orders SET status=1, taken_by=%d WHERE business_id=%d AND status=0 ORDER BY id DESC LIMIT 1",
			GetPlayerAccountID(playerid), bid);
		mysql_query(mysql, query, false);
	}

	new model_id = TC_GetRentModelId(playerid);
	if(TC_ModelNeedsTrailer(model_id))
	{
		if(TC_IsTrailerLinked(playerid))
		{
			p_tc_order_progress[playerid] = 2;
			if(g_tc_rt_orders[order_idx][RT_FROM] == TC_POINT_MINE)
				TC_SelectMineLoadDock(playerid);
			TC_SetRouteCheckpoint(playerid, order_idx, true, TC_ROUTE_CHECKPOINT_SIZE);
		}
		else
		{
			p_tc_order_progress[playerid] = 0;
			TC_Send(playerid, "Введите {FFFF24}/cargo{FFFFFF} для получения прицепа.");
		}
	}
	else
	{
		p_tc_order_progress[playerid] = 2;
		if(g_tc_rt_orders[order_idx][RT_FROM] == TC_POINT_MINE)
			TC_SelectMineLoadDock(playerid);
		TC_SetRouteCheckpoint(playerid, order_idx, true, TC_ROUTE_CHECKPOINT_SIZE);
	}

	return 1;
}

stock TC_CompleteOrder(playerid)
{
	new order_idx = p_tc_active_order[playerid];
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(order_idx < 0 || company_idx < 0) return 0;

	new total_pay = g_tc_rt_orders[order_idx][RT_TOTAL_PAY];
	new commission = g_tc_companies[company_idx][TC_COMMISSION];
	new driver_pay = TC_GetDriverPay(total_pay, commission);
	new company_take = total_pay - driver_pay;
	new order_type = g_tc_rt_orders[order_idx][RT_TYPE];

	GivePlayerMoneyEx(playerid, driver_pay, "Заказ ТК", true, true);
	TC_SetPlayerRating(playerid, p_tc_rating[playerid] + 1);

	new query[192];
	new acc_id = GetPlayerAccountID(playerid);
	mysql_format(mysql, query, sizeof query,
		"UPDATE accounts SET tc_rating_day=tc_rating_day+1, tc_rating_week=tc_rating_week+1 WHERE id=%d LIMIT 1", acc_id);
	mysql_query(mysql, query, false);

	g_tc_companies[company_idx][TC_BALANCE] += company_take;
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET balance=balance+%d WHERE id=%d LIMIT 1",
		company_take, g_tc_companies[company_idx][TC_SQL_ID]);
	mysql_query(mysql, query, false);
	TC_LogFinance(g_tc_companies[company_idx][TC_SQL_ID], 0, company_take, "Комиссия с заказа");

	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_employees SET orders_done=orders_done+1, earned=earned+%d WHERE company_id=%d AND account_id=%d LIMIT 1",
		driver_pay, g_tc_companies[company_idx][TC_SQL_ID], GetPlayerAccountID(playerid));
	mysql_query(mysql, query, false);

	new fleet_idx = p_tc_rent_fleet_idx[playerid];
	if(fleet_idx >= 0 && fleet_idx < g_tc_fleet_loaded)
	{
		g_tc_fleet[fleet_idx][TF_TRIPS_LEFT]--;
		if(g_tc_fleet[fleet_idx][TF_TRIPS_LEFT] <= 0)
			g_tc_fleet[fleet_idx][TF_BROKEN] = true;

		mysql_format(mysql, query, sizeof query,
			"UPDATE tc_fleet SET trips_left=%d, broken=%d WHERE id=%d LIMIT 1",
			g_tc_fleet[fleet_idx][TF_TRIPS_LEFT], g_tc_fleet[fleet_idx][TF_BROKEN], g_tc_fleet[fleet_idx][TF_SQL_ID]);
		mysql_query(mysql, query, false);

		if(g_tc_fleet[fleet_idx][TF_BROKEN])
		{
			SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Транспорт требует техобслуживания. Аренда завершена.");
			TC_EndRent(playerid, false);
			return 1;
		}
	}

	if(order_type == TC_ORDER_PRIVATE)
	{
		new bid = g_tc_rt_orders[order_idx][RT_BUSINESS_ID];
		if(bid >= 0 && bid < MAX_BUSINESS)
		{
			AddBusinessData(bid, B_PRODS, +, g_tc_rt_orders[order_idx][RT_AMOUNT]);
			mysql_format(mysql, query, sizeof query,
				"UPDATE business SET products=%d WHERE id=%d LIMIT 1",
				GetBusinessData(bid, B_PRODS), GetBusinessData(bid, B_SQL_ID));
			mysql_query(mysql, query, false);

			mysql_format(mysql, query, sizeof query,
				"UPDATE tc_orders SET status=2 WHERE business_id=%d AND status=1 ORDER BY id DESC LIMIT 1", bid);
			mysql_query(mysql, query, false);

			g_tc_private_business[bid] = -1;
		}
	}

	new done_msg[96];
	format(done_msg, sizeof done_msg, TC_MSG"Заказ выполнен. Вы получили {FFFF24}%d{FFFFFF} руб.", driver_pay);
	SendClientMessage(playerid, TC_COLOR_MSG, done_msg);

	if(p_tc_trailer_vehicle[playerid] != -1 && IsValidVehicle(p_tc_trailer_vehicle[playerid]))
	{
		DetachTrailerFromVehicle(p_tc_rent_vehicle[playerid]);
		TC_ForceDestroyVehicle(p_tc_trailer_vehicle[playerid]);
	}
	else if(p_tc_trailer_vehicle[playerid] != -1)
		TC_ClearGuardedVehicle(p_tc_trailer_vehicle[playerid]);

	if(order_type != TC_ORDER_GOV)
		g_tc_rt_orders[order_idx][RT_USED] = 0;

	p_tc_trailer_vehicle[playerid] = -1;
	p_tc_active_order[playerid] = -1;
	p_tc_order_progress[playerid] = 0;
	p_tc_trailer_detached[playerid] = false;
	p_tc_trailer_was_attached[playerid] = false;
	p_tc_trailer_lock_fail_since_ms[playerid] = 0;
	p_tc_dest_port_dock[playerid] = -1;
	p_tc_mine_load_dock[playerid] = -1;
	TC_ClearRouteMarker(playerid);
	return 1;
}

stock TC_IsAtLoadPoint(playerid, order_idx)
{
	if(g_tc_rt_orders[order_idx][RT_FROM] == TC_POINT_MINE)
		return TC_IsAtMineLoadPoint(playerid, TC_LOAD_POINT_RANGE);

	new Float:fx, Float:fy, Float:fz;
	TC_GetRoutePointPos(order_idx, true, fx, fy, fz, playerid);
	return IsPlayerInRangeOfPoint(playerid, TC_LOAD_POINT_RANGE, fx, fy, fz);
}

stock TC_IsAtUnloadPoint(playerid, order_idx)
{
	if(g_tc_rt_orders[order_idx][RT_TYPE] == TC_ORDER_PRIVATE && g_tc_rt_orders[order_idx][RT_BUSINESS_ID] >= 0)
	{
		new bid = g_tc_rt_orders[order_idx][RT_BUSINESS_ID];
		return IsPlayerInRangeOfPoint(playerid, TC_UNLOAD_POINT_RANGE,
			GetBusinessData(bid, B_POS_X), GetBusinessData(bid, B_POS_Y), GetBusinessData(bid, B_POS_Z));
	}
	if(g_tc_rt_orders[order_idx][RT_TO] == TC_POINT_PORT)
	{
		if(p_tc_dest_port_dock[playerid] >= 0 && p_tc_dest_port_dock[playerid] < sizeof g_tc_port_docks)
		{
			new d = p_tc_dest_port_dock[playerid];
			if(IsPlayerInRangeOfPoint(playerid, TC_UNLOAD_POINT_RANGE,
				g_tc_port_docks[d][0], g_tc_port_docks[d][1], g_tc_port_docks[d][2]))
				return 1;
		}
		return TC_IsNearAnyPortDock(playerid, TC_UNLOAD_POINT_RANGE);
	}

	new Float:dx, Float:dy, Float:dz;
	TC_GetRoutePointPos(order_idx, false, dx, dy, dz, playerid);
	return IsPlayerInRangeOfPoint(playerid, TC_UNLOAD_POINT_RANGE, dx, dy, dz);
}

stock TC_IsPlayerInRentTruck(playerid)
{
	if(p_tc_rent_vehicle[playerid] == -1) return 0;
	if(!IsValidVehicle(p_tc_rent_vehicle[playerid])) return 0;
	return GetPlayerVehicleID(playerid) == p_tc_rent_vehicle[playerid];
}

stock TC_CancelLoadUnloadOperation(playerid)
{
	if(p_tc_operation_timer[playerid])
	{
		KillTimer(p_tc_operation_timer[playerid]);
		p_tc_operation_timer[playerid] = 0;
	}
	if(p_tc_operation_watch_timer[playerid])
	{
		KillTimer(p_tc_operation_watch_timer[playerid]);
		p_tc_operation_watch_timer[playerid] = 0;
	}
	p_tc_operation_loading[playerid] = false;
	if(IsPlayerConnected(playerid))
		TogglePlayerControllable(playerid, true);
	return 1;
}

stock TC_StartLoadUnloadOperation(playerid, bool:loading)
{
	if(p_tc_operation_timer[playerid]) return 1;

	if(!TC_IsPlayerInRentTruck(playerid))
	{
		if(loading)
			TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Для загрузки нужно быть в арендованном Sprinter.", "OK");
		else
			TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Для разгрузки нужно быть в арендованном Sprinter.", "OK");
		return 1;
	}

	TogglePlayerControllable(playerid, false);
	p_tc_operation_loading[playerid] = loading;

	if(loading)
		TC_ShowNotify(playerid, TC_NOTIFY_INFO, TC_NOTIFY_DUR_LOAD, "Идёт загрузка груза...", "");
	else
		TC_ShowNotify(playerid, TC_NOTIFY_INFO, TC_NOTIFY_DUR_LOAD, "Идёт разгрузка груза...", "");

	p_tc_operation_watch_timer[playerid] = SetTimerEx("TC_LoadUnloadWatch", TC_LOAD_UNLOAD_WATCH_MS, true, "i", playerid);
	p_tc_operation_timer[playerid] = SetTimerEx("TC_OnLoadUnloadDone", TC_LOAD_UNLOAD_FREEZE_MS, false, "i", playerid);
	return 1;
}

forward TC_LoadUnloadWatch(playerid);
public TC_LoadUnloadWatch(playerid)
{
	if(!p_tc_operation_timer[playerid])
	{
		if(p_tc_operation_watch_timer[playerid])
		{
			KillTimer(p_tc_operation_watch_timer[playerid]);
			p_tc_operation_watch_timer[playerid] = 0;
		}
		return 0;
	}

	if(TC_IsPlayerInRentTruck(playerid)) return 1;

	new bool:loading = p_tc_operation_loading[playerid];
	TC_CancelLoadUnloadOperation(playerid);

	if(loading)
		TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Загрузка прервана — оставайтесь в арендованном Sprinter.", "OK");
	else
		TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Разгрузка прервана — оставайтесь в арендованном Sprinter.", "OK");
	return 1;
}

forward TC_OnLoadUnloadDone(playerid);
public TC_OnLoadUnloadDone(playerid)
{
	if(p_tc_operation_watch_timer[playerid])
	{
		KillTimer(p_tc_operation_watch_timer[playerid]);
		p_tc_operation_watch_timer[playerid] = 0;
	}
	p_tc_operation_timer[playerid] = 0;

	if(!IsPlayerConnected(playerid)) return 0;

	TogglePlayerControllable(playerid, true);

	if(p_tc_active_order[playerid] == -1) return 0;

	new order_idx = p_tc_active_order[playerid];
	new bool:loading = p_tc_operation_loading[playerid];
	p_tc_operation_loading[playerid] = false;

	if(!TC_IsPlayerInRentTruck(playerid))
	{
		if(loading)
			TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Загрузка прервана — оставайтесь в арендованном Sprinter.", "OK");
		else
			TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Разгрузка прервана — оставайтесь в арендованном Sprinter.", "OK");
		return 1;
	}

	if(loading)
	{
		if(p_tc_order_progress[playerid] != 2 || !TC_IsAtLoadPoint(playerid, order_idx))
		{
			TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Загрузка прервана — оставайтесь в точке.", "OK");
			return 1;
		}

		if(!TC_EnsureTrailerForCargo(playerid))
		{
			TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Сначала подцепите прицеп к фуре.", "OK");
			return 1;
		}

		TC_ClearRouteMarker(playerid);
		p_tc_order_progress[playerid] = 3;
		TC_SetUnloadCheckpoint(playerid, order_idx, true);
		TC_ShowNotify(playerid, TC_NOTIFY_SUCCESS, TC_NOTIFY_DUR, "Груз загружен.", "OK");
		return 1;
	}

	if(p_tc_order_progress[playerid] != 3 || !TC_IsAtUnloadPoint(playerid, order_idx))
	{
		TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Разгрузка прервана — оставайтесь в точке.", "OK");
		return 1;
	}

	if(!TC_EnsureTrailerForCargo(playerid))
	{
		TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Для разгрузки нужен прицеп. Введите /cargo.", "OK");
		return 1;
	}

	TC_ClearRouteMarker(playerid);
	TC_ShowNotify(playerid, TC_NOTIFY_SUCCESS, TC_NOTIFY_DUR, "Груз разгружен.", "OK");
	TC_CompleteOrder(playerid);
	return 1;
}

stock TC_OnTrailerUpdate(playerid, vehicleid)
{
	if(p_tc_active_order[playerid] == -1 || p_tc_trailer_vehicle[playerid] == -1) return 0;
	if(vehicleid != p_tc_trailer_vehicle[playerid]) return 0;
	if(GetPlayerVehicleID(playerid) != p_tc_rent_vehicle[playerid]) return 0;

	TC_LogTrailerServer(playerid, "OnTrailerUpdate");

	// After the first successful coupling, reject the idea of a detached route:
	// immediately restore the strict trailer->truck link on every trailer sync.
	if(p_tc_order_progress[playerid] >= 2)
	{
		TC_ForceTrailerLock(playerid, true);
		return 1;
	}

	if(!TC_IsTrailerLinked(playerid)) return 0;
	p_tc_trailer_detach_misses[playerid] = 0;
	p_tc_trailer_detached[playerid] = false;
	p_tc_trailer_was_attached[playerid] = true;
	p_tc_trailer_last_recover_ms[playerid] = 0;
	p_tc_trailer_lock_fail_since_ms[playerid] = 0;

	if(p_tc_order_progress[playerid] == 1)
		TC_OnTrailerLinked(playerid);
	return 1;
}

stock TC_OnPlayerEnterCheckpoint(playerid)
{
	if(p_tc_active_order[playerid] == -1) return 0;

	new order_idx = p_tc_active_order[playerid];

	if(p_tc_order_progress[playerid] == 2)
	{
		if(TC_IsAtLoadPoint(playerid, order_idx))
		{
			if(!TC_IsPlayerInRentTruck(playerid))
			{
				TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Для загрузки нужно быть в арендованном Sprinter.", "OK");
				return 1;
			}

			if(!TC_EnsureTrailerForCargo(playerid))
			{
				TC_LogTrailerDebug(playerid, "not_linked_at_load");
				SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Сначала подцепите прицеп к фуре.");
				return 1;
			}

			TC_StartLoadUnloadOperation(playerid, true);
			return 1;
		}
	}

	if(p_tc_order_progress[playerid] == 3)
	{
		if(TC_IsAtUnloadPoint(playerid, order_idx))
		{
			if(!TC_IsPlayerInRentTruck(playerid))
			{
				TC_ShowNotify(playerid, TC_NOTIFY_ERROR, TC_NOTIFY_DUR, "Для разгрузки нужно быть в арендованном Sprinter.", "OK");
				return 1;
			}

			if(!TC_EnsureTrailerForCargo(playerid))
			{
				TC_LogTrailerDebug(playerid, "not_linked_at_unload");
				SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Для разгрузки нужен прицеп. Введите {FFFF24}/cargo{FFFFFF}.");
				return 1;
			}

			TC_StartLoadUnloadOperation(playerid, false);
			return 1;
		}
	}

	if(p_tc_order_progress[playerid] == 1)
	{
		if(TC_IsTrailerLinked(playerid) || TC_IsTrailerNearTruck(playerid, 22.0))
		{
			TC_TryDetectTrailerLink(playerid);
			return 1;
		}

		new office = TC_GetOfficeByPlayer(playerid);
		new slot = TC_GetRandomTrailerParkingSlot(office);
		new Float:tx, Float:ty, Float:tz, Float:ta;
		if(TC_GetTrailerParkingPos(office, slot, tx, ty, tz, ta))
		{
			if(IsPlayerInRangeOfPoint(playerid, 8.0, tx, ty, tz))
			{
				DisablePlayerCheckpoint(playerid);
				SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Подцепите прицеп к фуре.");
				return 1;
			}
		}
	}
	return 0;
}

stock TC_JoinCompany(playerid, company_idx)
{
	if(company_idx < 0 || company_idx >= g_tc_companies_loaded) return 0;
	if(!TC_CheckEmploymentRequirements(playerid)) return 0;
	if(g_tc_companies[company_idx][TC_OWNER_ID] == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"У этой компании нет владельца.");
		return 0;
	}
	if(TC_PlayerHasTcCompany(playerid))
	{
		if(TC_GetOwnedCompanyIndex(playerid) != -1)
			SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Вы владелец транспортной компании. Сначала продайте её.");
		else
			SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Вы уже состоите в транспортной компании.");
		return 0;
	}

	new company_sql = g_tc_companies[company_idx][TC_SQL_ID];
	new emp_cnt = TC_CountEmployeesSync(company_sql);
	if(emp_cnt >= TC_GetMaxEmployees(company_idx))
	{
		new msg[128];
		if(TC_CompanyHasUpgrade(company_idx, TC_UPGRADE_OFFICE))
			format(msg, sizeof msg, TC_MSG"В компании достигнут лимит сотрудников ({FFFF24}%d{FFFFFF}).", TC_EMPLOYEE_LIMIT_OFFICE);
		else
			format(msg, sizeof msg, TC_MSG"Лимит сотрудников ({FFFF24}%d{FFFFFF}). Купите улучшение офиса в меню компании.", TC_EMPLOYEE_LIMIT_BASE);
		SendClientMessage(playerid, TC_COLOR_ERROR, msg);
		return 0;
	}

	new account_id = GetPlayerAccountID(playerid);
	new query[256];

	mysql_format(mysql, query, sizeof query,
		"UPDATE accounts SET tc_company_id=%d WHERE id=%d LIMIT 1", company_sql, account_id);
	mysql_query(mysql, query, false);

	mysql_format(mysql, query, sizeof query,
		"INSERT IGNORE INTO tc_employees (company_id, account_id, hired_at) VALUES (%d, %d, %d)",
		company_sql, account_id, gettime());
	mysql_query(mysql, query, false);

	p_tc_company[playerid] = company_idx;
	SetPlayerData(playerid, P_TC_COMPANY_ID, company_sql);
	UpdatePlayerDatabaseInt(playerid, "tc_company_id", company_sql);
	SendClientMessage(playerid, TC_COLOR_GOOD, TC_MSG"Вы устроились в транспортную компанию.");
	return 1;
}

stock TC_LeaveCompany(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Вы не состоите в компании.");
		return 0;
	}
	if(TC_IsCompanyOwner(playerid, company_idx))
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Владелец не может покинуть компанию. Продайте её в меню «Управление».");
		return 0;
	}

	new account_id = GetPlayerAccountID(playerid);
	new company_sql = g_tc_companies[company_idx][TC_SQL_ID];
	new query[160];

	mysql_format(mysql, query, sizeof query,
		"DELETE FROM tc_employees WHERE company_id=%d AND account_id=%d", company_sql, account_id);
	mysql_query(mysql, query, false);

	mysql_format(mysql, query, sizeof query,
		"UPDATE accounts SET tc_company_id=0 WHERE id=%d LIMIT 1", account_id);
	mysql_query(mysql, query, false);

	TC_EndRent(playerid, false);
	p_tc_company[playerid] = -1;
	SetPlayerData(playerid, P_TC_COMPANY_ID, 0);
	UpdatePlayerDatabaseInt(playerid, "tc_company_id", 0);
	SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Вы покинули транспортную компанию.");
	return 1;
}

stock TC_ShowDepositDialog(playerid)
{
	if(!IsPlayerLogged(playerid)) return 0;
	new idx = TC_GetPlayerCompanyIndex(playerid);
	if(idx == -1 || g_tc_companies[idx][TC_OWNER_ID] <= 0) return 0;
	SetPVarInt(playerid, "TCDepositCompany", g_tc_companies[idx][TC_SQL_ID]);
	new body[256];
	format(body, sizeof body, "{FFFFFF}Введите сумму пополнения из денег на руках.\nБез комиссии.\nВаш баланс: %d руб.\nБаланс компании: %d руб.",
		GetPlayerMoneyEx(playerid), g_tc_companies[idx][TC_BALANCE]);
	Dialog(playerid, DIALOG_TC_DEPOSIT, DIALOG_STYLE_INPUT, "Пополнение компании", body, "Пополнить", "Назад");
	return 1;
}

stock TC_DepositMoney(playerid, company_sql, const input[])
{
	if(!IsPlayerLogged(playerid)) return 0;
	new idx = TC_GetPlayerCompanyIndex(playerid);
	if(idx == -1 || company_sql <= 0 || g_tc_companies[idx][TC_SQL_ID] != company_sql) return 0;
	if(g_tc_companies[idx][TC_OWNER_ID] <= 0) return 0;
	new amount, len = strlen(input);
	if(len < 1 || len > 10)
		return SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Введите целую положительную сумму цифрами.");
	for(new i; i < len; i++)
	{
		if(input[i] < '0' || input[i] > '9')
			return SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Допустимы только цифры.");
		new digit = input[i] - '0';
		if(amount > (2147483647 - digit) / 10)
			return SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Слишком большая сумма.");
		amount = amount * 10 + digit;
	}
	new cash = GetPlayerMoneyEx(playerid), balance = g_tc_companies[idx][TC_BALANCE];
	if(amount <= 0 || cash < amount)
		return SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Неверная сумма или недостаточно денег на руках.");
	if(balance < 0 || balance > 2147483647 - amount)
		return SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Достигнут лимит баланса компании.");

	// One atomic multi-table UPDATE; refuse nontransactional installations.
	new Cache:result = mysql_query(mysql, "SELECT COUNT(*) AS n FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN ('accounts','tc_companies') AND ENGINE='InnoDB'");
	new err = mysql_errno(mysql), engines;
	if(!err && cache_num_rows() == 1) engines = cache_get_field_content_int(0, "n");
	cache_delete(result);
	if(err || engines != 2)
	{
		printf("[TRUCK_COMPANY] Deposit refused player=%d company=%d errno=%d reason=transactional_tables_required", playerid, company_sql, err);
		return SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Пополнение недоступно: требуется проверка БД администратором. Деньги не списаны.");
	}
	new query[768], account = GetPlayerAccountID(playerid);
	mysql_format(mysql, query, sizeof query,
		"UPDATE accounts a JOIN tc_companies c ON c.id=%d SET a.money=a.money-%d,c.balance=c.balance+%d WHERE a.id=%d AND a.money=%d AND a.money>=%d AND c.balance=%d AND c.owner_id=%d AND c.owner_id>0 AND (c.owner_id=a.id OR (a.tc_company_id=c.id AND EXISTS (SELECT 1 FROM tc_employees e WHERE e.company_id=c.id AND e.account_id=a.id)))",
		company_sql, amount, amount, account, cash, amount, balance, g_tc_companies[idx][TC_OWNER_ID]);
	result = mysql_query(mysql, query);
	err = mysql_errno(mysql);
	new affected;
	if(!err) affected = cache_affected_rows();
	cache_delete(result);
	if(err || affected != 2)
	{
		printf("[TRUCK_COMPANY] Deposit failed player=%d account=%d company=%d amount=%d errno=%d affected=%d", playerid, account, company_sql, amount, err, affected);
		return SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Перевод не подтверждён: проверьте членство и баланс, откройте меню повторно.");
	}
	// SQL already saved both balances. Keep the existing wallet/HUD/log API, without a second account UPDATE.
	GivePlayerMoneyEx(playerid, -amount, "Пополнение ТК", false, true);
	g_tc_companies[idx][TC_BALANCE] += amount;
	TC_LogFinance(company_sql, TC_FIN_DEPOSIT, amount, "Пополнение участником");
	printf("[TRUCK_COMPANY] Deposit success player=%d account=%d company=%d amount=%d balance=%d", playerid, account, company_sql, amount, g_tc_companies[idx][TC_BALANCE]);
	new message[128];
	format(message, sizeof message, TC_MSG"Баланс компании пополнен на %d руб. Теперь в кассе: %d руб.", amount, g_tc_companies[idx][TC_BALANCE]);
	SendClientMessage(playerid, TC_COLOR_MSG, message);
	return 1;
}

stock TC_WithdrawMoney(playerid, amount)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	if(amount <= 0)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Неверная сумма.");
		return 0;
	}
	if(amount > g_tc_companies[company_idx][TC_BALANCE])
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"В кассе компании недостаточно денег.");
		return 0;
	}

	new fee = amount * TC_WITHDRAW_FEE_PERCENT / 100;
	new gain = amount - fee;

	g_tc_companies[company_idx][TC_BALANCE] -= amount;
	new query[160];
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET balance=balance-%d WHERE id=%d LIMIT 1", amount, g_tc_companies[company_idx][TC_SQL_ID]);
	mysql_query(mysql, query, false);
	TC_LogFinance(g_tc_companies[company_idx][TC_SQL_ID], 1, amount, "Снятие из кассы");

	GivePlayerMoneyEx(playerid, gain, "Снятие из кассы ТК", true, true);

	new msg[128];
	format(msg, sizeof msg, TC_MSG"Снято {FFFF24}%d{FFFFFF} руб. (комиссия %d%%: %d руб.). На руки: {FFFF24}%d{FFFFFF} руб.",
		amount, TC_WITHDRAW_FEE_PERCENT, fee, gain);
	SendClientMessage(playerid, TC_COLOR_MSG, msg);
	return 1;
}

stock TC_RenameCompany(playerid, const newname[])
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	new len = strlen(newname);
	if(len < 2 || len > 32)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Название должно быть от 2 до 32 символов.");
		return 0;
	}

	if(!TC_IsValidCompanyName(newname))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Название только на английском: буквы A-Z, цифры, пробел и _.");
		return 0;
	}

	new elapsed = gettime() - g_tc_companies[company_idx][TC_LAST_RENAME];
	if(g_tc_companies[company_idx][TC_LAST_RENAME] > 0 && elapsed < TC_RENAME_COOLDOWN_DAYS * 86400)
	{
		new days_left = (TC_RENAME_COOLDOWN_DAYS * 86400 - elapsed) / 86400 + 1;
		new msg[128];
		format(msg, sizeof msg, TC_MSG"Менять название можно раз в 7 дней. Осталось дней: {FFFF24}%d{FFFFFF}.", days_left);
		SendClientMessage(playerid, TC_COLOR_ERROR, msg);
		return 0;
	}

	if(GetPlayerMoneyEx(playerid) < TC_RENAME_PRICE)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Недостаточно денег для смены названия (100000).");
		return 0;
	}

	GivePlayerMoneyEx(playerid, -TC_RENAME_PRICE, "Смена названия ТК", true, true);

	new clean_name[48];
	format(clean_name, sizeof clean_name, "%s", newname);
	format(g_tc_company_name[company_idx], 48, "%s", clean_name);
	g_tc_companies[company_idx][TC_LAST_RENAME] = gettime();

	new query[160];
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET name='%e', last_rename=%d WHERE id=%d LIMIT 1",
		clean_name, gettime(), g_tc_companies[company_idx][TC_SQL_ID]);
	mysql_query(mysql, query, false);

	new msg[96];
	format(msg, sizeof msg, TC_MSG"Название изменено: {FFFF24}%s", clean_name);
	SendClientMessage(playerid, TC_COLOR_GOOD, msg);
	return 1;
}

stock TC_SetCommission(playerid, percent)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	if(percent < TC_COMMISSION_MIN || percent > TC_COMMISSION_MAX)
	{
		new msg[96];
		format(msg, sizeof msg, TC_MSG"Комиссия должна быть от %d%% до %d%%.", TC_COMMISSION_MIN, TC_COMMISSION_MAX);
		SendClientMessage(playerid, TC_COLOR_ERROR, msg);
		return 0;
	}

	g_tc_companies[company_idx][TC_COMMISSION] = percent;
	new query[128];
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET commission=%d WHERE id=%d LIMIT 1", percent, g_tc_companies[company_idx][TC_SQL_ID]);
	mysql_query(mysql, query, false);

	new msg[96];
	format(msg, sizeof msg, TC_MSG"Комиссия компании установлена на {FFFF24}%d%%{FFFFFF}.", percent);
	SendClientMessage(playerid, TC_COLOR_GOOD, msg);
	return 1;
}

stock TC_PrepareFireTarget(playerid, inputtext[])
{
	if(isnull(inputtext))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Введите ID или имя сотрудника.");
		return 0;
	}

	p_tc_fire_target[playerid][0] = 0;

	if(IsNumeric(inputtext))
	{
		new pid = strval(inputtext);
		if(!IsPlayerConnected(pid) || !IsPlayerLogged(pid))
		{
			SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Игрок с таким ID не в сети.");
			return 0;
		}
		GetPlayerName(pid, p_tc_fire_target[playerid], 24);
		return 1;
	}

	format(p_tc_fire_target[playerid], 24, "%s", inputtext);
	return 1;
}

stock TC_FireEmployee(playerid, targetname[])
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	new company_sql = g_tc_companies[company_idx][TC_SQL_ID];
	new targetid = GetPlayerID(targetname);

	if(targetid != INVALID_PLAYER_ID && IsPlayerLogged(targetid))
	{
		new acc = GetPlayerAccountID(targetid);
		if(acc == g_tc_companies[company_idx][TC_OWNER_ID])
		{
			SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Нельзя уволить владельца.");
			return 0;
		}
		new query[160];
		mysql_format(mysql, query, sizeof query,
			"DELETE FROM tc_employees WHERE company_id=%d AND account_id=%d LIMIT 1", company_sql, acc);
		mysql_query(mysql, query, false);
		mysql_format(mysql, query, sizeof query, "UPDATE accounts SET tc_company_id=0 WHERE id=%d LIMIT 1", acc);
		mysql_query(mysql, query, false);

		p_tc_company[targetid] = -1;
		SetPlayerData(targetid, P_TC_COMPANY_ID, 0);
		UpdatePlayerDatabaseInt(targetid, "tc_company_id", 0);
		TC_EndRent(targetid, false);
		SendClientMessage(targetid, TC_COLOR_MSG, TC_MSG"Вас уволили из транспортной компании.");
		SendClientMessage(playerid, TC_COLOR_GOOD, TC_MSG"Сотрудник уволен.");
		return 1;
	}

	new query[192];
	mysql_format(mysql, query, sizeof query,
		"UPDATE accounts SET tc_company_id=0 WHERE name='%e' AND tc_company_id=%d LIMIT 1", targetname, company_sql);
	mysql_query(mysql, query, false);
	mysql_format(mysql, query, sizeof query,
		"DELETE te FROM tc_employees te JOIN accounts a ON a.id=te.account_id WHERE a.name='%e' AND te.company_id=%d LIMIT 1",
		targetname, company_sql);
	mysql_query(mysql, query, false);
	SendClientMessage(playerid, TC_COLOR_GOOD, TC_MSG"Сотрудник уволен (оффлайн).");
	return 1;
}

stock TC_SellCompany(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	new company_sql = g_tc_companies[company_idx][TC_SQL_ID];
	new refund = g_tc_companies[company_idx][TC_BALANCE] * TC_SELL_REFUND_PERCENT / 100;
	if(refund > 0)
		GivePlayerMoneyEx(playerid, refund, "Закрытие ТК", true, true);

	new query[160];

	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET owner_id=-1, balance=0, upgrade_office=0, upgrade_garage=0, upgrade_licenses=0 WHERE id=%d LIMIT 1", company_sql);
	mysql_query(mysql, query, false);

	mysql_format(mysql, query, sizeof query, "UPDATE accounts SET tc_company_id=0 WHERE tc_company_id=%d", company_sql);
	mysql_query(mysql, query, false);
	mysql_format(mysql, query, sizeof query, "DELETE FROM tc_employees WHERE company_id=%d", company_sql);
	mysql_query(mysql, query, false);

	mysql_format(mysql, query, sizeof query, "DELETE FROM tc_fleet WHERE company_id=%d", company_sql);
	mysql_query(mysql, query, false);

	g_tc_companies[company_idx][TC_OWNER_ID] = -1;
	g_tc_companies[company_idx][TC_BALANCE] = 0;
	g_tc_companies[company_idx][TC_UPG_OFFICE] = 0;
	g_tc_companies[company_idx][TC_UPG_GARAGE] = 0;
	g_tc_companies[company_idx][TC_UPG_LICENSE] = 0;
	format(g_tc_owner_name[company_idx], 24, "Свободна");

	foreach(new i : Player)
	{
		if(IsPlayerLogged(i) && p_tc_company[i] == company_idx)
		{
			p_tc_company[i] = -1;
			SetPlayerData(i, P_TC_COMPANY_ID, 0);
			TC_EndRent(i, false);
		}
	}

	new msg[128];
	format(msg, sizeof msg, TC_MSG"Компания закрыта. Возврат из кассы: {FFFF24}%d{FFFFFF} руб.", refund);
	SendClientMessage(playerid, TC_COLOR_MSG, msg);
	TC_LoadFleet();
	return 1;
}

stock TC_BuyFleet(playerid, model_type)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	// Fleet purchase is Sprinter-only. Reject legacy truck/DAF dialog values too,
	// so old clients cannot buy them by sending a stale listitem/model type.
	if(model_type != TC_BUY_TYPE_VAN) return 0;

	new price = TC_BUY_VAN_PRICE;
	new model = TC_VAN_MODEL_DEFAULT;
	new name[32];
	format(name, sizeof name, "Mercedes-Benz Sprinter");

	if(g_tc_companies[company_idx][TC_BALANCE] < price)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"В кассе компании недостаточно денег на покупку.");
		return 0;
	}

	new fleet_cnt = TC_GetFleetCountForCompany(g_tc_companies[company_idx][TC_SQL_ID]);
	if(fleet_cnt >= TC_GetMaxFleetSlots(company_idx))
	{
		new msg[128];
		if(TC_CompanyHasUpgrade(company_idx, TC_UPGRADE_GARAGE))
			format(msg, sizeof msg, TC_MSG"Лимит автопарка ({FFFF24}%d{FFFFFF} машин).", TC_GetMaxFleetSlots(company_idx));
		else
			format(msg, sizeof msg, TC_MSG"Лимит автопарка ({FFFF24}%d{FFFFFF}). Купите улучшение гаража.", TC_FLEET_LIMIT_BASE);
		SendClientMessage(playerid, TC_COLOR_ERROR, msg);
		return 0;
	}

	g_tc_companies[company_idx][TC_BALANCE] -= price;
	new query[256];
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET balance=balance-%d WHERE id=%d LIMIT 1", price, g_tc_companies[company_idx][TC_SQL_ID]);
	mysql_query(mysql, query, false);
	TC_LogFinance(g_tc_companies[company_idx][TC_SQL_ID], 2, price, "Покупка ТС");

	mysql_format(mysql, query, sizeof query,
		"INSERT INTO tc_fleet (company_id, model_id, name, rent_price, trips_left, trips_max, broken, rented_account_id, created_at) \
		VALUES (%d, %d, '%e', 1000, %d, %d, 0, -1, %d)",
		g_tc_companies[company_idx][TC_SQL_ID], model, name, TC_FLEET_TRIPS_MAX, TC_FLEET_TRIPS_MAX, gettime());
	mysql_query(mysql, query, false);

	SendClientMessage(playerid, TC_COLOR_GOOD, TC_MSG"Транспорт добавлен в автопарк.");
	TC_LoadFleet();
	return 1;
}

stock TC_RepairFleet(playerid, fleet_idx)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;
	if(fleet_idx < 0 || fleet_idx >= g_tc_fleet_loaded) return 0;
	if(g_tc_fleet[fleet_idx][TF_COMPANY_ID] != g_tc_companies[company_idx][TC_SQL_ID]) return 0;

	if(!g_tc_fleet[fleet_idx][TF_BROKEN] && g_tc_fleet[fleet_idx][TF_TRIPS_LEFT] > 0)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Этому ТС не требуется обслуживание.");
		return 0;
	}
	if(g_tc_companies[company_idx][TC_BALANCE] < TC_REPAIR_PRICE)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"В кассе недостаточно денег на Т/О.");
		return 0;
	}

	g_tc_companies[company_idx][TC_BALANCE] -= TC_REPAIR_PRICE;
	g_tc_fleet[fleet_idx][TF_BROKEN] = false;
	g_tc_fleet[fleet_idx][TF_TRIPS_LEFT] = g_tc_fleet[fleet_idx][TF_TRIPS_MAX];

	new query[160];
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET balance=balance-%d WHERE id=%d LIMIT 1", TC_REPAIR_PRICE, g_tc_companies[company_idx][TC_SQL_ID]);
	mysql_query(mysql, query, false);
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_fleet SET broken=0, trips_left=%d WHERE id=%d LIMIT 1",
		g_tc_fleet[fleet_idx][TF_TRIPS_MAX], g_tc_fleet[fleet_idx][TF_SQL_ID]);
	mysql_query(mysql, query, false);
	TC_LogFinance(g_tc_companies[company_idx][TC_SQL_ID], 2, TC_REPAIR_PRICE, "Техобслуживание");

	SendClientMessage(playerid, TC_COLOR_GOOD, TC_MSG"Техобслуживание выполнено.");
	return 1;
}

stock TC_SellFleetVehicle(playerid, fleet_idx)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;
	if(fleet_idx < 0 || fleet_idx >= g_tc_fleet_loaded) return 0;
	if(g_tc_fleet[fleet_idx][TF_COMPANY_ID] != g_tc_companies[company_idx][TC_SQL_ID]) return 0;

	if(g_tc_fleet[fleet_idx][TF_RENTED_ACCOUNT_ID] != -1)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Нельзя продать арендованный транспорт.");
		return 0;
	}

	new refund = TC_GetFleetSellRefund(g_tc_fleet[fleet_idx][TF_MODEL_ID]);
	g_tc_companies[company_idx][TC_BALANCE] += refund;

	new query[160];
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET balance=balance+%d WHERE id=%d LIMIT 1",
		refund, g_tc_companies[company_idx][TC_SQL_ID]);
	mysql_query(mysql, query, false);
	mysql_format(mysql, query, sizeof query,
		"DELETE FROM tc_fleet WHERE id=%d LIMIT 1", g_tc_fleet[fleet_idx][TF_SQL_ID]);
	mysql_query(mysql, query, false);
	TC_LogFinance(g_tc_companies[company_idx][TC_SQL_ID], 0, refund, "Продажа ТС");

	new msg[96];
	format(msg, sizeof msg, TC_MSG"Транспорт продан. В кассу зачислено {FFFF24}%d{FFFFFF} руб.", refund);
	SendClientMessage(playerid, TC_COLOR_GOOD, msg);
	TC_LoadFleet();
	return 1;
}

stock TC_SetFleetRentPrice(playerid, fleet_idx, price)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;
	if(fleet_idx < 0 || fleet_idx >= g_tc_fleet_loaded) return 0;
	if(g_tc_fleet[fleet_idx][TF_COMPANY_ID] != g_tc_companies[company_idx][TC_SQL_ID]) return 0;
	if(price < TC_RENT_PRICE_MIN || price > TC_RENT_PRICE_MAX)
	{
		new msg[96];
		format(msg, sizeof msg, TC_MSG"Стоимость аренды: от %d до %d руб.", TC_RENT_PRICE_MIN, TC_RENT_PRICE_MAX);
		SendClientMessage(playerid, TC_COLOR_ERROR, msg);
		return 0;
	}

	g_tc_fleet[fleet_idx][TF_RENT_PRICE] = price;
	new query[128];
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_fleet SET rent_price=%d WHERE id=%d LIMIT 1", price, g_tc_fleet[fleet_idx][TF_SQL_ID]);
	mysql_query(mysql, query, false);
	SendClientMessage(playerid, TC_COLOR_GOOD, TC_MSG"Стоимость аренды обновлена.");
	return 1;
}

stock TC_AdminSetCompanyName(company_sql, const newname[])
{
	new idx = TC_GetCompanyIndexBySqlId(company_sql);
	if(idx == -1) return 0;

	new clean_name[48];
	format(clean_name, sizeof clean_name, "%s", newname);
	format(g_tc_company_name[idx], 48, "%s", clean_name);
	new query[160];
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET name='%e' WHERE id=%d LIMIT 1", clean_name, company_sql);
	mysql_query(mysql, query, false);
	return 1;
}

stock TC_AdminResetRenameCooldown(company_sql)
{
	new idx = TC_GetCompanyIndexBySqlId(company_sql);
	if(idx == -1) return 0;

	g_tc_companies[idx][TC_LAST_RENAME] = 0;
	new query[96];
	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET last_rename=0 WHERE id=%d LIMIT 1", company_sql);
	mysql_query(mysql, query, false);
	return 1;
}

stock TC_AdminGiveCompany(playerid, company_idx, targetid)
{
	if(company_idx < 0 || company_idx >= g_tc_companies_loaded) return 0;
	if(targetid == INVALID_PLAYER_ID || !IsPlayerLogged(targetid)) return 0;

	if(TC_PlayerHasTcCompany(targetid, company_idx))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"У игрока уже есть транспортная компания.");
		return 0;
	}

	new account_id = GetPlayerAccountID(targetid);
	new company_sql = g_tc_companies[company_idx][TC_SQL_ID];
	new prev_owner = g_tc_companies[company_idx][TC_OWNER_ID];
	new query[192];

	if(prev_owner != -1 && prev_owner != account_id)
	{
		mysql_format(mysql, query, sizeof query,
			"DELETE FROM tc_employees WHERE company_id=%d AND account_id=%d",
			company_sql, prev_owner);
		mysql_query(mysql, query, false);

		mysql_format(mysql, query, sizeof query,
			"UPDATE accounts SET tc_company_id=0 WHERE id=%d AND tc_company_id=%d LIMIT 1",
			prev_owner, company_sql);
		mysql_query(mysql, query, false);

		foreach(new i : Player)
		{
			if(!IsPlayerLogged(i)) continue;
			if(GetPlayerAccountID(i) != prev_owner) continue;
			p_tc_company[i] = -1;
			SetPlayerData(i, P_TC_COMPANY_ID, 0);
			TC_EndRent(i, false);
			SendClientMessage(i, TC_COLOR_MSG, TC_MSG"С вас снято владение транспортной компанией.");
			break;
		}
	}

	mysql_format(mysql, query, sizeof query,
		"UPDATE tc_companies SET owner_id=%d WHERE id=%d LIMIT 1", account_id, company_sql);
	mysql_query(mysql, query, false);

	mysql_format(mysql, query, sizeof query,
		"UPDATE accounts SET tc_company_id=%d WHERE id=%d LIMIT 1", company_sql, account_id);
	mysql_query(mysql, query, false);

	g_tc_companies[company_idx][TC_OWNER_ID] = account_id;
	GetPlayerName(targetid, g_tc_owner_name[company_idx], 24);
	p_tc_company[targetid] = company_idx;
	SetPlayerData(targetid, P_TC_COMPANY_ID, company_sql);
	UpdatePlayerDatabaseInt(targetid, "tc_company_id", company_sql);

	SendClientMessage(playerid, TC_COLOR_GOOD, TC_MSG"Компания выдана игроку.");
	SendClientMessage(targetid, TC_COLOR_GOOD, TC_MSG"Вам выдана транспортная компания!");
	TC_RequestAdminCompanyList(playerid);
	return 1;
}

stock TC_BuyCompanyUpgrade(playerid, upgrade_type)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	if(TC_CompanyHasUpgrade(company_idx, upgrade_type))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Это улучшение уже приобретено.");
		return 0;
	}

	new price, note[48], msg[128];
	switch(upgrade_type)
	{
		case TC_UPGRADE_OFFICE:
		{
			price = TC_UPGRADE_OFFICE_PRICE;
			format(note, sizeof note, "Покупка офиса");
			format(msg, sizeof msg, TC_MSG"Куплено улучшение: {FFFF24}150 рабочих мест{FFFFFF}.");
		}
		case TC_UPGRADE_GARAGE:
		{
			price = TC_UPGRADE_GARAGE_PRICE;
			format(note, sizeof note, "Места в гараже");
			format(msg, sizeof msg, TC_MSG"Куплено улучшение: {FFFF24}+20 мест{FFFFFF} в автопарке.");
		}
		case TC_UPGRADE_LICENSE:
		{
			price = TC_UPGRADE_LICENSE_PRICE;
			format(note, sizeof note, "Лицензии перевозки");
			format(msg, sizeof msg, TC_MSG"Приобретены лицензии на перевозку {FFFF24}продуктов, топлива, оружия{FFFFFF}.");
		}
		default: return 0;
	}

	if(g_tc_companies[company_idx][TC_BALANCE] < price)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"В кассе компании недостаточно денег.");
		return 0;
	}

	g_tc_companies[company_idx][TC_BALANCE] -= price;
	switch(upgrade_type)
	{
		case TC_UPGRADE_OFFICE: g_tc_companies[company_idx][TC_UPG_OFFICE] = 1;
		case TC_UPGRADE_GARAGE: g_tc_companies[company_idx][TC_UPG_GARAGE] = 1;
		case TC_UPGRADE_LICENSE: g_tc_companies[company_idx][TC_UPG_LICENSE] = 1;
	}

	new query[192];
	switch(upgrade_type)
	{
		case TC_UPGRADE_OFFICE:
			mysql_format(mysql, query, sizeof query,
				"UPDATE tc_companies SET balance=balance-%d, upgrade_office=1 WHERE id=%d LIMIT 1",
				price, g_tc_companies[company_idx][TC_SQL_ID]);
		case TC_UPGRADE_GARAGE:
			mysql_format(mysql, query, sizeof query,
				"UPDATE tc_companies SET balance=balance-%d, upgrade_garage=1 WHERE id=%d LIMIT 1",
				price, g_tc_companies[company_idx][TC_SQL_ID]);
		case TC_UPGRADE_LICENSE:
			mysql_format(mysql, query, sizeof query,
				"UPDATE tc_companies SET balance=balance-%d, upgrade_licenses=1 WHERE id=%d LIMIT 1",
				price, g_tc_companies[company_idx][TC_SQL_ID]);
	}
	mysql_query(mysql, query, false);
	TC_LogFinance(g_tc_companies[company_idx][TC_SQL_ID], TC_FIN_EXPENSE, price, note);
	SendClientMessage(playerid, TC_COLOR_GOOD, msg);
	return 1;
}

stock TC_SendChatMessage(playerid, message[])
{
	if(p_tc_company[playerid] == -1) return 0;
	if(isnull(message)) return 0;

	new company_idx = p_tc_company[playerid];
	new cname[48], pname[24], text[128];
	TC_GetCompanyDisplayName(company_idx, cname, sizeof cname);
	format(pname, sizeof pname, "%s", GetPlayerNameEx(playerid));
	format(text, sizeof text, "%s", message);

	new chat_line[192];
	chat_line[0] = 0;
	strcat(chat_line, "{FFFF24}[", sizeof chat_line);
	strcat(chat_line, cname, sizeof chat_line);
	strcat(chat_line, "]{FFFFFF} ", sizeof chat_line);

	new part[96];
	format(part, sizeof part, "%s [%d]: ", pname, playerid);
	strcat(chat_line, part, sizeof chat_line);
	strcat(chat_line, text, sizeof chat_line);

	foreach(new i : Player)
	{
		if(!IsPlayerLogged(i)) continue;
		if(p_tc_company[i] == -1) continue;
		SendClientMessage(i, TC_COLOR_MSG, chat_line);
	}
	return 1;
}

stock TC_SetPlayerRating(playerid, rating)
{
	p_tc_rating[playerid] = rating;
	SetPlayerData(playerid, P_TC_RATING, rating);
	UpdatePlayerDatabaseInt(playerid, "tc_rating", rating);
}

stock TC_OnPlayerDataLoaded(playerid)
{
	new query[128];
	mysql_format(mysql, query, sizeof query, "SELECT tc_company_id,tc_rating FROM accounts WHERE id=%d LIMIT 1", GetPlayerAccountID(playerid));
	mysql_tquery(mysql, query, "TC_OnPlayerBindingLoaded", "iii", playerid, GetPlayerAccountID(playerid), g_BRAuthEpoch[playerid]);
	return 1;
}

forward TC_OnPlayerBindingLoaded(playerid, accountid, epoch);
public TC_OnPlayerBindingLoaded(playerid, accountid, epoch)
{
	if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
	if(GetPlayerAccountID(playerid) != accountid || g_BRAuthEpoch[playerid] != epoch) return 1;
	if(!cache_num_rows()) return 1;
	SetPlayerData(playerid, P_TC_COMPANY_ID, cache_get_field_content_int(0, "tc_company_id"));
	SetPlayerData(playerid, P_TC_RATING, cache_get_field_content_int(0, "tc_rating"));
	p_tc_rating[playerid] = GetPlayerData(playerid, P_TC_RATING);
	TC_SyncPlayerCompanyBinding(playerid);

	if(p_tc_rent_vehicle[playerid] == -1)
		TC_ReleaseAccountFleetRents(GetPlayerAccountID(playerid));
	return 1;
}

stock TC_OnPlayerDeath(playerid)
{
	if(p_tc_rent_vehicle[playerid] != -1 || p_tc_rent_fleet_idx[playerid] != -1)
		TC_EndRent(playerid, false);
	return 1;
}

stock TC_OnVehicleSpawn(vehicleid)
{
	new bool:handled;

	if(GetVehicleData(vehicleid, V_ACTION_TYPE) == VEHICLE_ACTION_TYPE_TC)
	{
		TC_GuardVehicle(vehicleid, true);
		SetVehicleHealth(vehicleid, 100000.0);
		handled = true;
	}

	foreach(new i : Player)
	{
		if(p_tc_trailer_vehicle[i] != vehicleid)
			continue;

		TC_RegisterGuardedVehicle(vehicleid, i);
		if(p_tc_rent_vehicle[i] != -1 && IsValidVehicle(p_tc_rent_vehicle[i]))
			SetVehicleVirtualWorld(vehicleid, GetVehicleVirtualWorld(p_tc_rent_vehicle[i]));
		TC_LogTrailerDebug(i, "respawn");
		handled = true;
		break;
	}

	return handled ? 1 : 0;
}

stock TC_OnVehicleDeath(vehicleid)
{
	foreach(new i : Player)
	{
		if(p_tc_rent_vehicle[i] == vehicleid)
		{
			TC_EndRent(i, false);
			return 1;
		}
		if(p_tc_trailer_vehicle[i] == vehicleid)
		{
			printf("[TC_TRAILER_GUARD] OnVehicleDeath player=%d trailer=%d progress=%d", i, vehicleid, p_tc_order_progress[i]);
			TC_LogTrailerDebug(i, "death");
			TC_ClearGuardedVehicle(vehicleid);

			new saved_order = p_tc_active_order[i];
			new saved_progress = p_tc_order_progress[i];
			p_tc_trailer_vehicle[i] = -1;
			p_tc_trailer_last_recover_ms[i] = 0;
			p_tc_trailer_lock_fail_since_ms[i] = 0;
			p_tc_trailer_detach_misses[i] = TC_TRAILER_SOFT_RECOVER_MISSES;
			p_tc_trailer_detached[i] = true;
			p_tc_trailer_has_last_pos[i] = false;

			// Loaded cargo is logical route state, not the lifetime of one vehicle id.
			// Recreate only the trailer and keep the accepted order/progress intact.
			if(saved_order != -1 && saved_progress >= 2 && p_tc_rent_vehicle[i] != -1)
				SetTimerEx("TC_RecoverTrailerDelayed", 700, false, "iiii", i, saved_order, saved_progress, g_BRAuthEpoch[i]);
			return 1;
		}
	}
	return 0;
}

#include "../include/tc_purchase_v56.inc"

stock TC_OnPlayerConnect(playerid)
{
	TC56_Reset(playerid);
	p_tc_company[playerid] = -1;
	p_tc_rating[playerid] = 0;
	p_tc_office[playerid] = -1;
	p_tc_fleet_page[playerid] = 0;
	p_tc_admin_company[playerid] = -1;
	p_tc_join_company[playerid] = -1;
	p_tc_pick_order[playerid] = -1;
	p_tc_fleet_sel[playerid] = -1;
	p_tc_rent_timer[playerid] = 0;
	p_tc_trailer_watch_timer[playerid] = 0;
	TC_ResetPlayerWork(playerid);
}

stock TC_OnPlayerDisconnect(playerid)
{
	TC56_Reset(playerid);
	TC_EndRent(playerid, false);
	p_tc_company[playerid] = -1;
	p_tc_admin_company[playerid] = -1;
}

stock TC_CreateWorldPickups()
{
	static bool:created;
	if(created) return 1;
	created = true;
	TC56_CreateMarker();
	for(new office = 0; office < 2; office++)
	{
		CreateDynamic3DTextLabel("{FFFF24}Транспортная компания\n{FFFFFF}Вход в офис",
			-1, g_tc_building_enter[office][0], g_tc_building_enter[office][1],
			g_tc_building_enter[office][2] + 0.6, 20.0,
			INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
		CreatePickup(19135, 23,
			g_tc_building_enter[office][0], g_tc_building_enter[office][1], g_tc_building_enter[office][2],
			0, PICKUP_ACTION_TYPE_TC_OFFICE_ENTER, office);

		CreatePickup(19135, 23,
			g_tc_interior_exit[0], g_tc_interior_exit[1], g_tc_interior_exit[2],
			g_tc_interior_vw[office], PICKUP_ACTION_TYPE_TC_OFFICE_EXIT, office);

		CreatePickup(1274, 23,
			g_tc_marker_order[0], g_tc_marker_order[1], g_tc_marker_order[2],
			g_tc_interior_vw[office], PICKUP_ACTION_TYPE_TC_ORDER, office);

		CreatePickup(1239, 23,
			g_tc_marker_company_list[0], g_tc_marker_company_list[1], g_tc_marker_company_list[2],
			g_tc_interior_vw[office], PICKUP_ACTION_TYPE_TC_COMPANY_LIST, office);

		CreateDynamic3DTextLabel("{FFFF24}Устройство в транспортную компанию",
			-1,
			g_tc_marker_company_list[0], g_tc_marker_company_list[1], g_tc_marker_company_list[2] + 0.3,
			12.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, g_tc_interior_vw[office], g_tc_interior_id);

		CreatePickup(1239, 23,
			g_tc_marker_rent[office][0], g_tc_marker_rent[office][1], g_tc_marker_rent[office][2],
			0, PICKUP_ACTION_TYPE_TC_RENT, office);

		CreateDynamic3DTextLabel("{FFFF24}Аренда / сдача Sprinter",
			-1,
			g_tc_marker_rent[office][0], g_tc_marker_rent[office][1], g_tc_marker_rent[office][2] + 0.5,
			20.0);
	}
	print("[TransportCompany] World entrances created: Baturevo / Busaevo");
	return 1;
}
// END INLINED: modules/m1stoks/transportCompany/tcomp_logic.inc
// BEGIN INLINED: modules/m1stoks/transportCompany/tcomp_ui.inc
#if defined _tcomp_ui_included
	#endinput
#endif
#define _tcomp_ui_included

forward TC_OnEmployeesLoaded(playerid, mode, page);
forward TC_OnRatingLoaded(playerid, mode);
forward TC_OnPersonalLoaded(playerid);
forward TC_OnFinanceDetailLoaded(playerid, mode);

stock TC_ShowMainMenu(playerid)
{
	DeletePVar(playerid, "TCDepositCompany");
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Вы не состоите в транспортной компании.");
		return 0;
	}

	new fmt_str[512];
	format(fmt_str, sizeof fmt_str,
		"Информация\n\
Автопарк\n\
Управление\n\
Сотрудники\n\
Финансовая статистика\n\
Личная карточка\n\
Улучшение\n\
Помощь");

	if(!TC_IsCompanyOwner(playerid, company_idx))
		strcat(fmt_str, "\n{FFFF24}Покинуть компанию", sizeof fmt_str);
	strcat(fmt_str, "\nПополнить баланс компании", sizeof fmt_str);

	Dialog(playerid, DIALOG_TC_MAIN_MENU, DIALOG_STYLE_LIST, TC_TITLE, fmt_str, "Далее", "Выйти");
	return 1;
}

stock TC_ShowInfo(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	new query[256];
	mysql_format(mysql, query, sizeof query,
		"SELECT (SELECT COUNT(*) FROM tc_employees WHERE company_id=%d) AS emp_cnt, \
		(SELECT IFNULL(SUM(orders_done),0) FROM tc_employees WHERE company_id=%d) AS orders_sum",
		g_tc_companies[company_idx][TC_SQL_ID], g_tc_companies[company_idx][TC_SQL_ID]);
	mysql_tquery(mysql, query, "TC_OnInfoLoaded", "d", playerid);
	return 1;
}

public TC_OnInfoLoaded(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	new emp_cnt, orders_sum;
	if(cache_num_rows())
	{
		emp_cnt = cache_get_field_content_int(0, "emp_cnt");
		orders_sum = cache_get_field_content_int(0, "orders_sum");
	}

	new owner[24];
	TC_GetOwnerDisplayName(company_idx, owner, sizeof owner);

	new fleet_cnt = TC_GetFleetCountForCompany(g_tc_companies[company_idx][TC_SQL_ID]);
	new cname[48];
	TC_GetCompanyDisplayName(company_idx, cname, sizeof cname);

	new fmt_str[640];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Название компании: {FFFF24}%s{FFFFFF}\n\
Владелец компании: {FFFF24}%s{FFFFFF}\n\
Количество сотрудников: {FFFF24}%d шт.{FFFFFF}\n\
Комиссия компании: {FFFF24}%d процентов{FFFFFF}\n\
Рейтинг компании: {FFFF24}%d шт.{FFFFFF}\n\
Количество выполненных заказов: {FFFF24}%d шт.{FFFFFF}\n\
Количество машин в компании: {FFFF24}%d шт.{FFFFFF}\n\
'Лучшая компания дня': {FFFF24}%d шт.{FFFFFF}\n\
'Лучшая компания недели': {FFFF24}%d шт.",
		cname,
		owner,
		emp_cnt,
		g_tc_companies[company_idx][TC_COMMISSION],
		g_tc_company_rating[company_idx],
		orders_sum,
		fleet_cnt,
		0,
		0);

	Dialog(playerid, DIALOG_TC_INFO, DIALOG_STYLE_MSGBOX, "{FFFF24}Информация", fmt_str, "Назад", "");
	return 1;
}

stock TC_ShowFleetList(playerid, page = 0)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	new company_sql = g_tc_companies[company_idx][TC_SQL_ID];
	new body[1024];
	new row_offset = 0;

	format(body, sizeof body, "{FFFF24}Транспорт\tРейсов до Т/О\tСтоимость аренды\tИспользование\n");

	if(page > 0)
	{
		strcat(body, "{FFFF24}<< Предыдущая страница\n");
		row_offset = 1;
	}

	new shown, skipped;
	new page_start = page * TC_FLEET_PAGE_SIZE;

	for(new i = 0; i < g_tc_fleet_loaded; i++)
	{
		if(g_tc_fleet[i][TF_COMPANY_ID] != company_sql) continue;
		if(skipped < page_start) { skipped++; continue; }
		if(shown >= TC_FLEET_PAGE_SIZE) break;

		new usage[24];
		TC_GetFleetUsageText(i, usage, sizeof usage);

		new tc_line[160];
		format(tc_line, sizeof tc_line, "{FFFFFF}%s\t%d\t%d руб.\t%s\n",
			g_tc_fleet_name[i], g_tc_fleet[i][TF_TRIPS_LEFT], g_tc_fleet[i][TF_RENT_PRICE], usage);
		strcat(body, tc_line);
		SetPlayerListitemValue(playerid, shown + row_offset + 1, i);
		shown++;
	}

	if(shown == 0)
		strcat(body, "{FFFFFF}Автопарк пуст\t-\t-\t-\n");

	new total = TC_GetFleetCountForCompany(company_sql);
	if((page + 1) * TC_FLEET_PAGE_SIZE < total)
		strcat(body, "{FFFF24}Следующая страница >>\n");

	if(TC_IsCompanyOwner(playerid, company_idx))
		strcat(body, "{FFFF24}Купить транспорт\n");

	p_tc_fleet_page[playerid] = page;

	new title[56];
	format(title, sizeof title, "{FFFF24}Список автопарка страница %d", page + 1);
	Dialog(playerid, DIALOG_TC_FLEET_LIST, DIALOG_STYLE_TABLIST_HEADERS, title, body, "Выбрать", "Закрыть");
	return 1;
}

stock TC_ShowFleetVehicleMenu(playerid, fleet_idx)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;
	if(fleet_idx < 0 || fleet_idx >= g_tc_fleet_loaded) return 0;

	p_tc_fleet_sel[playerid] = fleet_idx;

	if(!TC_IsCompanyOwner(playerid, company_idx))
	{
		new usage[24];
		TC_GetFleetUsageText(fleet_idx, usage, sizeof usage);

		new fmt_str[320];
		format(fmt_str, sizeof fmt_str,
			"{FFFFFF}Транспорт: {FFFF24}%s{FFFFFF}\n\
Состояние: {FFFF24}%s{FFFFFF}\n\
Рейсов до Т/О: {FFFF24}%d / %d{FFFFFF}\n\
Стоимость аренды: {FFFF24}%d руб.{FFFFFF}",
			g_tc_fleet_name[fleet_idx], usage,
			g_tc_fleet[fleet_idx][TF_TRIPS_LEFT], g_tc_fleet[fleet_idx][TF_TRIPS_MAX],
			g_tc_fleet[fleet_idx][TF_RENT_PRICE]);

		Dialog(playerid, DIALOG_TC_FLEET_MANAGE, DIALOG_STYLE_MSGBOX, "{FFFF24}Транспорт", fmt_str, "Назад", "");
		return 1;
	}

	new fmt_str[128];
	format(fmt_str, sizeof fmt_str,
		"Провести Т/О\n\
Изменить стоимость аренды\n\
Продажа машины");

	Dialog(playerid, DIALOG_TC_FLEET_MANAGE, DIALOG_STYLE_LIST, "{FFFF24}Меню машины", fmt_str, "Далее", "Назад");
	return 1;
}

stock TC_ShowFleetRepairConfirm(playerid)
{
	new fmt_str[256];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Чтобы использовать грузовик Вам нужно проводить Т/О.\n\
Стоимость Т/О ровняется {FFFF24}%d{FFFFFF} рублей.",
		TC_REPAIR_PRICE);

	Dialog(playerid, DIALOG_TC_FLEET_REPAIR, DIALOG_STYLE_MSGBOX, "{FFFF24}Техническое обслуживание", fmt_str, "Далее", "Назад");
	return 1;
}

stock TC_ShowFleetRentPriceDialog(playerid)
{
	new fmt_str[320];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Введите стоимость аренды грузовика которую сотрудник будет оплачивать при каждой аренде:\n\
(мин. {FFFF24}%d{FFFFFF} руб., макс. {FFFF24}%d{FFFFFF} руб.)",
		TC_RENT_PRICE_MIN, TC_RENT_PRICE_MAX);

	Dialog(playerid, DIALOG_TC_FLEET_RENTPRICE, DIALOG_STYLE_INPUT, "{FFFF24}Цена за аренду", fmt_str, "Далее", "Назад");
	return 1;
}

stock TC_ShowFleetSellConfirm(playerid, fleet_idx)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || fleet_idx < 0 || fleet_idx >= g_tc_fleet_loaded) return 0;

	new refund = TC_GetFleetSellRefund(g_tc_fleet[fleet_idx][TF_MODEL_ID]);
	new fmt_str[256];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Продать {FFFF24}%s{FFFFFF}?\n\
В кассу компании вернётся {FFFF24}%d{FFFFFF} руб.\n\n\
Транспорт нельзя продать, пока он арендован.",
		g_tc_fleet_name[fleet_idx], refund);

	p_tc_fleet_sel[playerid] = fleet_idx;
	Dialog(playerid, DIALOG_TC_FLEET_SELL_VEH, DIALOG_STYLE_MSGBOX, "{FFFF24}Продажа машины", fmt_str, "Далее", "Назад");
	return 1;
}

stock TC_ShowFleetManage(playerid, fleet_idx)
{
	return TC_ShowFleetVehicleMenu(playerid, fleet_idx);
}

stock TC_ShowManageMenu(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;
	if(!TC_IsCompanyOwner(playerid, company_idx))
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Раздел доступен только владельцу компании.");
		return 0;
	}

	new fmt_str[256];
	format(fmt_str, sizeof fmt_str,
		"Снять деньги\n\
Изменить название компании\n\
Изменить процент комиссии\n\
Уволить игрока\n\
{FFFF24}Закрыть компанию");

	Dialog(playerid, DIALOG_TC_MANAGE, DIALOG_STYLE_LIST, "{FFFF24}Управление", fmt_str, "Выбрать", "Назад");
	return 1;
}

stock TC_ShowWithdrawDialog(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	new fmt_str[256];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Введите число денег, которые вы желаете снять.\n\
Комиссия на снятие: {FFFF24}%d процента{FFFFFF}\n\
Текущее число денег: {FFFF24}%d рублей",
		TC_WITHDRAW_FEE_PERCENT, g_tc_companies[company_idx][TC_BALANCE]);

	Dialog(playerid, DIALOG_TC_WITHDRAW, DIALOG_STYLE_INPUT, "{FFFF24}Снятие денег с компании", fmt_str, "Далее", "Назад");
	return 1;
}

stock TC_ShowRenameDialog(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	new cname[48];
	TC_GetCompanyDisplayName(company_idx, cname, sizeof cname);

	new fmt_str[512];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Название компании – первое, с чем сталкиваются заказчики.\n\
Текущее название: {FFFF24}%s{FFFFFF}.\n\n\
Менять название можно {FFFF24}1 раз в 7 дней{FFFFFF}, стоимость: {FFFF24}%d рублей{FFFFFF}.\n\n\
{FFFFFF}Только английские буквы (A-Z), цифры, пробел и _.\n\
Введите новое название компании:",
		cname, TC_RENAME_PRICE);

	Dialog(playerid, DIALOG_TC_RENAME, DIALOG_STYLE_INPUT, "{FFFF24}Изменить название", fmt_str, "Далее", "Назад");
	return 1;
}

stock TC_ShowCommissionDialog(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	new fmt_str[256];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Комиссия – процент, который компания удерживает с заказа водителя.\n\
Текущая комиссия: {FFFF24}%d%%{FFFFFF}\n\n\
Введите новый процент (%d - %d):",
		g_tc_companies[company_idx][TC_COMMISSION], TC_COMMISSION_MIN, TC_COMMISSION_MAX);

	Dialog(playerid, DIALOG_TC_COMMISSION, DIALOG_STYLE_INPUT, "{FFFF24}Процент комиссии", fmt_str, "Далее", "Назад");
	return 1;
}

stock TC_ShowFireDialog(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	Dialog(playerid, DIALOG_TC_FIRE, DIALOG_STYLE_INPUT, "{FFFF24}Увольнение сотрудника",
		"{FFFFFF}Для увольнения сотрудника введите его ID или имя в поле ниже:\n\
Пример: {FFFF24}144{FFFFFF} или {FFFF24}Persona_Persona",
		"Далее", "Назад");
	return 1;
}

stock TC_ShowFireConfirm(playerid)
{
	new fmt_str[128];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Вы действительно хотите уволить данного игрока из компании??\n\n\
Сотрудник: {FFFF24}%s{FFFFFF}",
		p_tc_fire_target[playerid]);

	Dialog(playerid, DIALOG_TC_FIRE_CONFIRM, DIALOG_STYLE_MSGBOX, "{FFFF24}Увольнение игрока", fmt_str, "Далее", "Назад");
	return 1;
}

stock TC_ShowBuyDialog(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	new fmt_str[192];
	format(fmt_str, sizeof fmt_str,
		"{FFFF24}Транспорт\t{FFFF24}Цена\n\
{FFFFFF}Mercedes-Benz Sprinter\t{FFFFFF}%d\n",
		TC_BUY_VAN_PRICE);

	Dialog(playerid, DIALOG_TC_BUY, DIALOG_STYLE_TABLIST_HEADERS, "{FFFF24}Покупка транспорта", fmt_str, "Купить", "Назад");
	return 1;
}

stock TC_ShowSellConfirm(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1 || !TC_IsCompanyOwner(playerid, company_idx)) return 0;

	new refund = g_tc_companies[company_idx][TC_BALANCE] * TC_SELL_REFUND_PERCENT / 100;
	new fmt_str[256];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Вы уверены, что хотите закрыть компанию?\n\
Все сотрудники будут уволены, автопарк удалён.\n\
Возврат из кассы (%d%%): {FFFF24}%d руб.",
		TC_SELL_REFUND_PERCENT, refund);

	Dialog(playerid, DIALOG_TC_SELL, DIALOG_STYLE_MSGBOX, "{FFFF24}Закрытие компании", fmt_str, "Закрыть", "Отмена");
	return 1;
}

stock TC_ShowEmployeesMenu(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	Dialog(playerid, DIALOG_TC_EMPLOYEES, DIALOG_STYLE_LIST, "{FFFF24}Сотрудники",
		"Список сотрудников\nРейтинг сотрудников", "Далее", "Назад");
	return 1;
}

stock TC_ShowEmpListSubmenu(playerid)
{
	Dialog(playerid, DIALOG_TC_EMP_SUBMENU, DIALOG_STYLE_LIST, "{FFFF24}Сотрудники",
		"Список сотрудников в игре\nСписок сотрудников не в игре\nОбщий список", "Далее", "Назад");
	return 1;
}

stock TC_ShowEmpRatingMenu(playerid)
{
	Dialog(playerid, DIALOG_TC_EMP_RATING_MENU, DIALOG_STYLE_LIST, "{FFFF24}Рейтинг сотрудников",
		"Рейтинг сотрудников за день\nРейтинг сотрудников за неделю\nРейтинг сотрудников за все время\nПомощь по рейтингу",
		"Далее", "Назад");
	return 1;
}

stock TC_ShowRatingHelp(playerid)
{
	Dialog(playerid, DIALOG_TC_RATING_HELP, DIALOG_STYLE_MSGBOX, "{FFFF24}Помощь по рейтингу",
		"{FFFFFF}Рейтинг складывается из двух факторов: перевозки и повреждения груза.\n\
За рейс можно получить максимум {FFFF24}10{FFFFFF} баллов.\n\
За доставку: {FFFF24}4{FFFFFF} балла, за отсутствие повреждений: {FFFF24}6{FFFFFF} баллов.\n\
Повреждение груза снижает рейтинг на {FFFF24}1–10{FFFFFF} баллов.\n\n\
Рейтинг за день обнуляется ежедневно в {FFFF24}00:00{FFFFFF} (МСК).\n\
Рейтинг за неделю обнуляется каждое {FFFF24}воскресенье в 00:00{FFFFFF} (МСК).",
		"Назад", "");
	return 1;
}

stock TC_RequestRatingList(playerid, mode)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	p_tc_emp_view_mode[playerid] = mode + 10;

	new query[384];
	new company_sql = g_tc_companies[company_idx][TC_SQL_ID];
	new owner_id = g_tc_companies[company_idx][TC_OWNER_ID];
	new order_field[16];

	switch(mode)
	{
		case 0: format(order_field, sizeof order_field, "tc_rating_day");
		case 1: format(order_field, sizeof order_field, "tc_rating_week");
		default: format(order_field, sizeof order_field, "tc_rating");
	}

	mysql_format(mysql, query, sizeof query,
		"SELECT a.name AS pname, a.%e AS prating FROM tc_employees te \
		JOIN accounts a ON a.id=te.account_id \
		WHERE te.company_id=%d AND te.account_id!=%d \
		ORDER BY prating DESC LIMIT 50",
		order_field, company_sql, owner_id);
	mysql_tquery(mysql, query, "TC_OnRatingLoaded", "dd", playerid, mode);
	return 1;
}

public TC_OnRatingLoaded(playerid, mode)
{
	new body[1536];
	format(body, sizeof body, "{FFFF24}Имя\tРейтинг\n");

	new rows = cache_num_rows();
	if(!rows) strcat(body, "{FFFFFF}Нет данных\t-\n");
	for(new i = 0; i < rows; i++)
	{
		new name[24];
		cache_get_field_content(i, "pname", name, mysql, 24);
		new rating = cache_get_field_content_int(i, "prating");

		new eline[80];
		format(eline, sizeof eline, "{FFFFFF}%s\t%d\n", name, rating);
		strcat(body, eline);
	}

	new title[48];
	switch(mode)
	{
		case 0: format(title, sizeof title, "{FFFF24}Рейтинг игроков за день");
		case 1: format(title, sizeof title, "{FFFF24}Рейтинг игроков за неделю");
		default: format(title, sizeof title, "{FFFF24}Рейтинг игроков за все время");
	}

	Dialog(playerid, DIALOG_TC_EMP_RATING_LIST, DIALOG_STYLE_TABLIST_HEADERS, title, body, "Назад", "");
	return 1;
}

stock TC_ShowEmployeesInGame(playerid, page = 0)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	p_tc_emp_view_mode[playerid] = 0;
	p_tc_emp_page[playerid] = page;

	new owner_id = g_tc_companies[company_idx][TC_OWNER_ID];
	new body[1536];
	format(body, sizeof body, "{FFFF24}Имя сотрудника\tРейтинг\tСтатус\n");

	new shown, skipped;
	new page_start = page * TC_EMPLOYEE_PAGE_SIZE;

	foreach(new i : Player)
	{
		if(!IsPlayerLogged(i)) continue;
		if(p_tc_company[i] != company_idx) continue;
		if(GetPlayerAccountID(i) == owner_id) continue;

		if(skipped < page_start) { skipped++; continue; }
		if(shown >= TC_EMPLOYEE_PAGE_SIZE) break;

		new name[32];
		format(name, sizeof name, "%s[%d]", GetPlayerNameEx(i), i);
		format(p_tc_emp_row_name[playerid][shown], 24, "%s", GetPlayerNameEx(i));
		new status[24];
		format(status, sizeof status, (p_tc_active_order[i] != -1) ? ("На рейсе") : ("Не на рейсе"));

		new eline[128];
		format(eline, sizeof eline, "{FFFFFF}%s\t%d\t%s\n", name, p_tc_rating[i], status);
		strcat(body, eline);
		SetPlayerListitemValue(playerid, shown + 1, shown);
		shown++;
	}
	if(!shown && !page) strcat(body, "{FFFFFF}Нет сотрудников в игре\t-\t-\n");

	new total;
	foreach(new i : Player)
	{
		if(!IsPlayerLogged(i)) continue;
		if(p_tc_company[i] != company_idx) continue;
		if(GetPlayerAccountID(i) == owner_id) continue;
		total++;
	}
	p_tc_emp_list_shown[playerid] = shown;
	p_tc_emp_total[playerid] = total;
	if((page + 1) * TC_EMPLOYEE_PAGE_SIZE < total)
		strcat(body, "{FFFF24}Следующая страница >>\n");

	new title[56];
	format(title, sizeof title, "{FFFF24}Список online игроков страница: %d", page + 1);
	Dialog(playerid, DIALOG_TC_EMP_LIST, DIALOG_STYLE_TABLIST_HEADERS, title, body, "Далее", "Назад");
	return 1;
}

stock TC_ShowEmployeesDB(playerid, mode, page = 0)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	p_tc_emp_view_mode[playerid] = mode;
	p_tc_emp_page[playerid] = page;

	new query[512];
	new company_sql = g_tc_companies[company_idx][TC_SQL_ID];
	new owner_id = g_tc_companies[company_idx][TC_OWNER_ID];

	if(mode == 2)
	{
		mysql_format(mysql, query, sizeof query,
			"SELECT a.name AS pname, a.tc_rating AS prating, IFNULL(a.tc_rating_day,0) AS prday, \
			a.last_login AS plast FROM tc_employees te \
			JOIN accounts a ON a.id=te.account_id \
			WHERE te.company_id=%d AND a.tc_company_id=%d AND te.account_id!=%d \
			ORDER BY a.tc_rating DESC LIMIT 50",
			company_sql, company_sql, owner_id);
	}
	else
	{
		mysql_format(mysql, query, sizeof query,
			"SELECT a.name AS pname, a.tc_rating AS prating, a.last_login AS plast FROM tc_employees te \
			JOIN accounts a ON a.id=te.account_id \
			WHERE te.company_id=%d AND a.tc_company_id=%d AND te.account_id!=%d \
			ORDER BY a.tc_rating DESC LIMIT 50",
			company_sql, company_sql, owner_id);
	}
	mysql_tquery(mysql, query, "TC_OnEmployeesLoaded", "ddd", playerid, mode, page);
	return 1;
}

public TC_OnEmployeesLoaded(playerid, mode, page)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	new rows = cache_num_rows();
	new body[2048];
	new shown, skipped;
	new page_start = page * TC_EMPLOYEE_PAGE_SIZE;

	if(mode == 2)
		format(body, sizeof body, "{FFFF24}Имя\tПоследний вход\tРейтинг\tРейтинг сегодня\n");
	else
		format(body, sizeof body, "{FFFF24}Имя\tРейтинг\n");

	for(new i = 0; i < rows; i++)
	{
		new name[24];
		cache_get_field_content(i, "pname", name, mysql, 24);
		new rating = cache_get_field_content_int(i, "prating");

		new online = (GetPlayerID(name) != INVALID_PLAYER_ID);
		if(mode == 1 && online) continue;

		if(skipped < page_start) { skipped++; continue; }
		if(shown >= TC_EMPLOYEE_PAGE_SIZE) break;

		format(p_tc_emp_row_name[playerid][shown], 24, "%s", name);

		if(mode == 2)
		{
			new last_login = cache_get_field_content_int(i, "plast");
			new rday = cache_get_field_content_int(i, "prday");
			new last_date[6];
			timestamp_to_date(last_login, last_date[2], last_date[1], last_date[0], last_date[3], last_date[4], last_date[5]);

			new date_str[32];
			format(date_str, sizeof date_str, "%02d.%02d.%04d - %02d:%02d:%02d",
				last_date[0], last_date[1], last_date[2], last_date[3], last_date[4], last_date[5]);

			new eline[160];
			format(eline, sizeof eline, "{FFFFFF}%s\t%s\t%d\t%d\n", name, date_str, rating, rday);
			strcat(body, eline);
		}
		else
		{
			new eline[80];
			format(eline, sizeof eline, "{FFFFFF}%s\t%d\n", name, rating);
			strcat(body, eline);
		}
		SetPlayerListitemValue(playerid, shown + 1, shown);
		shown++;
	}

	if(!shown && !page)
	{
		if(mode == 2) strcat(body, "{FFFFFF}Нет записей\t-\t-\t-\n");
		else strcat(body, "{FFFFFF}Нет записей\t-\n");
	}

	new total_off = 0;
	for(new i = 0; i < rows; i++)
	{
		new name[24];
		cache_get_field_content(i, "pname", name, mysql, 24);
		if(mode == 1 && GetPlayerID(name) != INVALID_PLAYER_ID) continue;
		total_off++;
	}
	p_tc_emp_list_shown[playerid] = shown;
	p_tc_emp_total[playerid] = total_off;
	if((page + 1) * TC_EMPLOYEE_PAGE_SIZE < total_off)
		strcat(body, "{FFFF24}Следующая страница >>\n");

	new title[56];
	format(title, sizeof title, "{FFFF24}Список offline игроков страница: %d", page + 1);

	if(mode == 2)
		Dialog(playerid, DIALOG_TC_EMP_LIST, DIALOG_STYLE_TABLIST_HEADERS, title, body, "Выбрать", "Закрыть");
	else
		Dialog(playerid, DIALOG_TC_EMP_LIST, DIALOG_STYLE_TABLIST_HEADERS, title, body, "Выбрать", "Закрыть");
	return 1;
}

stock TC_ShowFinance(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	Dialog(playerid, DIALOG_TC_FINANCE, DIALOG_STYLE_LIST, "{FFFF24}Финансовая статистика",
		"Деньги с аренды\nДеньги с перевозок\nЗатраты\nПополнения участниками", "Далее", "Назад");
	return 1;
}

stock TC_RequestFinanceDetail(playerid, mode)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	p_tc_finance_mode[playerid] = mode;
	new since = gettime() - (TC_FINANCE_DAYS * 86400);
	new query[384];
	mysql_format(mysql, query, sizeof query,
		"SELECT DAY(FROM_UNIXTIME(created_at)) AS d, SUM(amount) AS s FROM tc_finance \
		WHERE company_id=%d AND type=%d AND created_at>=%d \
		GROUP BY DATE(FROM_UNIXTIME(created_at)) ORDER BY created_at DESC LIMIT %d",
		g_tc_companies[company_idx][TC_SQL_ID], mode, since, TC_FINANCE_DAYS);
	mysql_tquery(mysql, query, "TC_OnFinanceDetailLoaded", "dd", playerid, mode);
	return 1;
}

public TC_OnFinanceDetailLoaded(playerid, mode)
{
	new body[2048];
	format(body, sizeof body, "{FFFF24}Дата\tПрибыль\n");

	new rows = cache_num_rows();
	if(!rows)
		strcat(body, "{FFFFFF}-\t0 руб\n");
	for(new i = 0; i < rows; i++)
	{
		new day = cache_get_field_content_int(i, "d");
		new sum = cache_get_field_content_int(i, "s");
		if(mode == TC_FIN_EXPENSE) sum = -sum;

		new eline[64];
		format(eline, sizeof eline, "{FFFFFF}%02d\t%d руб\n", day, sum);
		strcat(body, eline);
	}

	Dialog(playerid, DIALOG_TC_FINANCE_DETAIL, DIALOG_STYLE_TABLIST_HEADERS,
		"{FFFF24}Доход компании за 20 дней", body, "Назад", "Закрыть");
	return 1;
}

stock TC_ShowPersonal(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	new query[320];
	mysql_format(mysql, query, sizeof query,
		"SELECT te.orders_done, IFNULL(a.tc_rating_day,0) AS rday, IFNULL(a.tc_rating_week,0) AS rweek, \
		IFNULL(a.tc_rating,0) AS rt FROM tc_employees te \
		JOIN accounts a ON a.id=te.account_id \
		WHERE te.company_id=%d AND te.account_id=%d LIMIT 1",
		g_tc_companies[company_idx][TC_SQL_ID], GetPlayerAccountID(playerid));
	mysql_tquery(mysql, query, "TC_OnPersonalLoaded", "d", playerid);
	return 1;
}

public TC_OnPersonalLoaded(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	new orders_done, rday, rweek, rt;
	if(cache_num_rows())
	{
		orders_done = cache_get_field_content_int(0, "orders_done");
		rday = cache_get_field_content_int(0, "rday");
		rweek = cache_get_field_content_int(0, "rweek");
		rt = cache_get_field_content_int(0, "rt");
	}

	new name[24];
	GetPlayerName(playerid, name, sizeof name);

	new cname[48];
	TC_GetCompanyDisplayName(company_idx, cname, sizeof cname);

	new fmt_str[640];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Имя сотрудника: {FFFF24}%s{FFFFFF}\n\
Транспортная компания: {FFFF24}%s{FFFFFF}\n\
Рейтинг сегодня: {FFFF24}%d{FFFFFF}\n\
Рейтинг недельный: {FFFF24}%d{FFFFFF}\n\
Рейтинг за все время: {FFFF24}%d{FFFFFF}\n\
Выполненных рейсов: {FFFF24}%d шт.{FFFFFF}\n\
Лучший водитель дня: {FFFF24}%d шт.{FFFFFF}\n\
Лучший водитель недели: {FFFF24}%d шт.",
		name, cname,
		rday, rweek, rt, orders_done, 0, 0);

	Dialog(playerid, DIALOG_TC_PERSONAL, DIALOG_STYLE_MSGBOX, "{FFFF24}Личная карточка", fmt_str, "Назад", "");
	return 1;
}

stock TC_ShowUpgrade(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;
	if(!TC_IsCompanyOwner(playerid, company_idx))
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Улучшения доступны только владельцу компании.");
		return 0;
	}

	new price_office[16], price_garage[16], price_license[16];
	TC_FormatMoneyBR(TC_UPGRADE_OFFICE_PRICE, price_office, sizeof price_office);
	TC_FormatMoneyBR(TC_UPGRADE_GARAGE_PRICE, price_garage, sizeof price_garage);
	TC_FormatMoneyBR(TC_UPGRADE_LICENSE_PRICE, price_license, sizeof price_license);

	new cost_office[24], cost_garage[24], cost_license[24];
	if(TC_CompanyHasUpgrade(company_idx, TC_UPGRADE_OFFICE))
		format(cost_office, sizeof cost_office, "Куплено");
	else
		format(cost_office, sizeof cost_office, "%s", price_office);
	if(TC_CompanyHasUpgrade(company_idx, TC_UPGRADE_GARAGE))
		format(cost_garage, sizeof cost_garage, "Куплено");
	else
		format(cost_garage, sizeof cost_garage, "%s", price_garage);
	if(TC_CompanyHasUpgrade(company_idx, TC_UPGRADE_LICENSE))
		format(cost_license, sizeof cost_license, "Куплено");
	else
		format(cost_license, sizeof cost_license, "%s", price_license);

	new fmt_str[384];
	format(fmt_str, sizeof fmt_str,
		"{FFFF24}Пункт\t{FFFF24}Стоимость\n\
{FFFFFF}Покупка нового офиса\t{FFFFFF}%s\n\
{FFFFFF}Покупка новых мест в гараже\t{FFFFFF}%s\n\
{FFFFFF}Покупка лицензий на транспортировку\t{FFFFFF}%s",
		cost_office, cost_garage, cost_license);

	Dialog(playerid, DIALOG_TC_UPGRADE, DIALOG_STYLE_TABLIST_HEADERS, "{FFFF24}Улучшения", fmt_str, "Далее", "Назад");
	return 1;
}

stock TC_ShowUpgradeConfirm(playerid, upgrade_type)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1) return 0;

	if(TC_CompanyHasUpgrade(company_idx, upgrade_type))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Это улучшение уже приобретено.");
		TC_ShowUpgrade(playerid);
		return 0;
	}

	p_tc_upgrade_sel[playerid] = upgrade_type;
	new fmt_str[768];

	switch(upgrade_type)
	{
		case TC_UPGRADE_OFFICE:
			format(fmt_str, sizeof fmt_str,
				"{FFFFFF}Покупка нового офиса - отличный способ увеличить рабочий персонал Вашей компании!\n\
В новом офисе смогут находиться больше сотрудников, а значит прибыль Вашей компании вырастет.\n\
Конечно, для этого Вам нужны дополнительные фуры, так что не забудьте приобрести и новые места в гараже компании!\n\
Покупая данное улучшение, Вы получите: {FFFF24}150 рабочих мест{FFFFFF} за {FFFF24}50.000{FFFFFF} рублей!");
		case TC_UPGRADE_GARAGE:
			format(fmt_str, sizeof fmt_str,
				"{FFFFFF}Покупка новых мест в гараже - увеличение числа транспорта, работающего на компанию!\n\
Чем больше транспорт - тем активнее идет работа, чем активнее идет работа - тем больше денег получит владелец компании!\n\
Не скупитесь на покупку новых машин для своих сотрудников - они помогут Вам стать богаче!\n\n\
Для покупки этого улучшения Вам понадобится {FFFF24}1.000.000{FFFFFF} рублей\n\n\
Приобретя это улучшение Вы получите дополнительные {FFFF24}20 мест{FFFFFF} в автопарк компании!");
		case TC_UPGRADE_LICENSE:
			format(fmt_str, sizeof fmt_str,
				"{FFFFFF}Покупка новых лицензий для транспортировки - отличное решение, чтобы повысить капитализацию своей компании!\n\
Новые лицензии - новые заказы, новые заказы - больше денег! Всё просто!\n\
Приобретая эти лицензии Вы сможете перевозить {FFFF24}продукты, топливо, оружие{FFFFFF}, всем бизнесам которые только есть!\n\
Для покупки этого улучшения Вам необходимо {FFFF24}2.000.000{FFFFFF} рублей");
		default: return 0;
	}

	new title[48];
	switch(upgrade_type)
	{
		case TC_UPGRADE_OFFICE: format(title, sizeof title, "{FFFF24}Покупка нового офиса");
		case TC_UPGRADE_GARAGE: format(title, sizeof title, "{FFFF24}Улучшение автопарка");
		case TC_UPGRADE_LICENSE: format(title, sizeof title, "{FFFF24}Покупка лицензии");
	}

	Dialog(playerid, DIALOG_TC_UPGRADE_CONFIRM, DIALOG_STYLE_MSGBOX, title, fmt_str, "Далее", "Назад");
	return 1;
}

stock TC_ShowHelp(playerid)
{
	Dialog(playerid, DIALOG_TC_HELP, DIALOG_STYLE_MSGBOX, "{FFFF24}BLACK RUSSIA | Транспортные компании",
		"{FFFFFF}Команды:\n\
{FFFF24}/company{FFFFFF} — основное меню компании\n\
{FFFF24}/orders{FFFFFF} — список заказов компании\n\
{FFFF24}/cargo{FFFFFF} — прицеп для тягача\n\
{FFFF24}/tc [текст]{FFFFFF} — чат дальнобойщиков\n\n\
{FFFFFF}Описание системы:\n\
Устройство на работу доступно в главных офисах в {FFFF24}пгт. Батурево{FFFFFF} и {FFFF24}п. Бусаево{FFFFFF}.\n\
Для работы нужны уровень, мед. карта и профессиональные лицензии.\n\
Арендуйте фуру на парковке ТК, затем в офисе возьмите заказ.\n\
Заказы делятся на классы: обычные, хрупкие, ценные и нелегальные.\n\
Доступ к заказам зависит от рейтинга — смотрите его в {FFFF24}/company{FFFFFF}.",
		"Назад", "");
	return 1;
}

stock TC_ShowLeaveConfirm(playerid)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx != -1 && TC_IsCompanyOwner(playerid, company_idx))
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Владелец не может покинуть компанию. Продайте её в меню «Управление».");
		return 0;
	}

	Dialog(playerid, DIALOG_TC_LEAVE, DIALOG_STYLE_MSGBOX, "{FFFF24}Покинуть компанию",
		"{FFFFFF}Вы уверены, что хотите покинуть транспортную компанию?", "Да", "Нет");
	return 1;
}

stock TC_ShowWorkerCompanyList(playerid, office, page = 0)
{
	if(!TC_CheckEmploymentRequirements(playerid)) return 0;

	if(TC_PlayerHasTcCompany(playerid))
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"У вас уже есть транспортная компания.");
		return 0;
	}

	p_tc_office[playerid] = office;
	p_tc_company_page[playerid] = page;

	new body[1024];
	format(body, sizeof body, "{FFFF24}Название\tРейтинг\tКомиссия\n");

	new shown, skipped;
	new page_start = page * TC_COMPANY_PAGE_SIZE;

	for(new i = 0; i < g_tc_companies_loaded; i++)
	{
		if(g_tc_companies[i][TC_OFFICE] != office) continue;
		if(g_tc_companies[i][TC_OWNER_ID] == -1) continue;
		if(skipped < page_start) { skipped++; continue; }
		if(shown >= TC_COMPANY_PAGE_SIZE) break;

		new cname[48];
		TC_GetCompanyDisplayName(i, cname, sizeof cname);

		new tc_line[96];
		format(tc_line, sizeof tc_line, "{FFFFFF}%s\t%d\t%d%%\n",
			cname, g_tc_company_rating[i], g_tc_companies[i][TC_COMMISSION]);
		strcat(body, tc_line);
		SetPlayerListitemValue(playerid, shown + 1, i);
		shown++;
	}
	if(shown == 0) strcat(body, "{FFFFFF}Нет компаний\t-\t-\n");

	new total;
	for(new i = 0; i < g_tc_companies_loaded; i++)
		if(g_tc_companies[i][TC_OFFICE] == office && g_tc_companies[i][TC_OWNER_ID] != -1)
			total++;
	if((page + 1) * TC_COMPANY_PAGE_SIZE < total)
		strcat(body, "{FFFF24}Далее >>\n");

	Dialog(playerid, DIALOG_TC_COMPANY_LIST, DIALOG_STYLE_TABLIST_HEADERS, "{FFFF24}Список компаний", body, "Выбрать", "Закрыть");
	return 1;
}

stock TC_ShowCompanyJoinConfirm(playerid, company_idx)
{
	if(!TC_CheckEmploymentRequirements(playerid)) return 0;

	if(TC_PlayerHasTcCompany(playerid))
	{
		if(TC_GetOwnedCompanyIndex(playerid) != -1)
			SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Вы владелец транспортной компании. Сначала продайте её.");
		else
			SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Вы уже состоите в транспортной компании.");
		return 0;
	}

	p_tc_join_company[playerid] = company_idx;

	new owner_name[24];
	TC_GetOwnerDisplayName(company_idx, owner_name, sizeof owner_name);

	new cname[48];
	TC_GetCompanyDisplayName(company_idx, cname, sizeof cname);

	new fmt_str[384];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Название компании: {FFFF24}%s{FFFFFF}\n\
Учредитель: {FFFF24}%s{FFFFFF}\n\
Процентная ставка: {FFFF24}%d%%{FFFFFF}\n\
Рейтинг компании: {FFFF24}%d{FFFFFF}\n\n\
Хотите вступить в данную транспортную компанию?",
		cname, owner_name,
		g_tc_companies[company_idx][TC_COMMISSION], g_tc_company_rating[company_idx]);

	Dialog(playerid, DIALOG_TC_COMPANY_JOIN, DIALOG_STYLE_MSGBOX, "{FFFF24}Информация", fmt_str, "Вступить", "Назад");
	return 1;
}

stock TC_ShowRentList(playerid, page = 0)
{
	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	if(company_idx == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Сначала устройтесь в транспортную компанию.");
		return 0;
	}
	if(p_tc_rent_vehicle[playerid] != -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"У вас уже есть арендованный транспорт.");
		return 0;
	}

	new company_sql = g_tc_companies[company_idx][TC_SQL_ID];
	new body[1024];
	format(body, sizeof body, "{FFFF24}Транспорт\tСтоимость аренды\n");

	new shown, skipped;
	new page_start = page * TC_RENT_PAGE_SIZE;
	p_tc_rent_page[playerid] = page;

	for(new i = 0; i < g_tc_fleet_loaded; i++)
	{
		if(g_tc_fleet[i][TF_COMPANY_ID] != company_sql) continue;
		if(g_tc_fleet[i][TF_BROKEN] || g_tc_fleet[i][TF_TRIPS_LEFT] <= 0) continue;
		if(g_tc_fleet[i][TF_RENTED_ACCOUNT_ID] != -1) continue;
		if(skipped < page_start) { skipped++; continue; }
		if(shown >= TC_RENT_PAGE_SIZE) break;

		new tc_line[80];
		format(tc_line, sizeof tc_line, "{FFFFFF}%s\t%d руб.\n", g_tc_fleet_name[i], g_tc_fleet[i][TF_RENT_PRICE]);
		strcat(body, tc_line);
		SetPlayerListitemValue(playerid, shown + 1, i);
		shown++;
	}
	if(shown == 0) strcat(body, "{FFFFFF}Нет свободного транспорта\t-\n");

	new total;
	for(new i = 0; i < g_tc_fleet_loaded; i++)
	{
		if(g_tc_fleet[i][TF_COMPANY_ID] != company_sql) continue;
		if(g_tc_fleet[i][TF_BROKEN] || g_tc_fleet[i][TF_TRIPS_LEFT] <= 0) continue;
		if(g_tc_fleet[i][TF_RENTED_ACCOUNT_ID] != -1) continue;
		total++;
	}
	if((page + 1) * TC_RENT_PAGE_SIZE < total)
		strcat(body, "{FFFF24}Далее >>\n");

	new title[56];
	format(title, sizeof title, "{FFFF24}Аренда транспорта (стр. %d)", page + 1);
	Dialog(playerid, DIALOG_TC_RENT_LIST, DIALOG_STYLE_TABLIST_HEADERS, title, body, "Выбрать", "Закрыть");
	return 1;
}

stock TC_ShowOrdersList(playerid, page = 0)
{
	if(p_tc_company[playerid] == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Вы не состоите в транспортной компании.");
		return 0;
	}
	if(p_tc_rent_vehicle[playerid] == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Сначала арендуйте транспорт.");
		return 0;
	}
	if(p_tc_active_order[playerid] != -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Сначала выполните текущий заказ.");
		return 0;
	}

	new office = TC_GetOfficeByPlayer(playerid);
	new company_idx = p_tc_company[playerid];
	new body[1024];
	format(body, sizeof body, "{FFFF24}Название груза\tТип\tДоступность\n");

	new shown, skipped;
	new page_start = page * TC_ORDERS_PAGE_SIZE;
	p_tc_orders_page[playerid] = page;

	for(new i = 0; i < g_tc_rt_orders_count; i++)
	{
		if(!g_tc_rt_orders[i][RT_USED]) continue;
		if(g_tc_rt_orders[i][RT_OFFICE] != office) continue;
		if(g_tc_rt_orders[i][RT_TYPE] != TC_ORDER_GOV && TC_IsOrderActiveForAnyPlayer(i)) continue;
		if(p_tc_rating[playerid] < g_tc_rt_orders[i][RT_MIN_RATING]) continue;
		if(g_tc_rt_orders[i][RT_TYPE] == TC_ORDER_PRIVATE && !TC_CompanyHasTransportLicense(company_idx))
			continue;

		if(skipped < page_start) { skipped++; continue; }
		if(shown >= TC_ORDERS_PAGE_SIZE) break;

		new req[32];
		if(g_tc_rt_orders[i][RT_TYPE] == TC_ORDER_GOV_PLUS)
			format(req, sizeof req, "{FFFF24}3+ ??.");
		else
			format(req, sizeof req, "{FFFFFF}Доступно");

		new tc_line[128];
		format(tc_line, sizeof tc_line, "{FFFFFF}%s\t%s\t%s\n",
			g_tc_rt_orders[i][RT_CARGO_NAME], g_tc_rt_orders[i][RT_TYPE_NAME], req);
		strcat(body, tc_line);
		SetPlayerListitemValue(playerid, shown + 1, i);
		shown++;
	}
	if(shown == 0) strcat(body, "{FFFFFF}Нет заказов\t-\t-\n");

	Dialog(playerid, DIALOG_TC_ORDERS_LIST, DIALOG_STYLE_TABLIST_HEADERS, "{FFFF24}Доступные грузы", body, "Далее", "Выйти");
	return 1;
}

stock TC_ShowOrderInfo(playerid, order_idx)
{
	if(order_idx < 0 || order_idx >= MAX_TC_RUNTIME_ORDERS) return 0;
	if(!g_tc_rt_orders[order_idx][RT_USED]) return 0;

	p_tc_pick_order[playerid] = order_idx;

	new company_idx = TC_GetPlayerCompanyIndex(playerid);
	new commission = g_tc_companies[company_idx][TC_COMMISSION];
	new driver_pay = TC_GetDriverPay(g_tc_rt_orders[order_idx][RT_TOTAL_PAY], commission);
	new Float:km = TC_GetPointsDistanceKm(g_tc_rt_orders[order_idx][RT_FROM], g_tc_rt_orders[order_idx][RT_TO]);
	new weight = floatround(km * 3000.0) + 8000;

	new to_name[32];
	if(g_tc_rt_orders[order_idx][RT_TYPE] == TC_ORDER_PRIVATE && g_tc_rt_orders[order_idx][RT_BUSINESS_ID] >= 0)
		format(to_name, sizeof to_name, "%s", GetBusinessData(g_tc_rt_orders[order_idx][RT_BUSINESS_ID], B_NAME));
	else
		format(to_name, sizeof to_name, "%s", g_tc_point_names[g_tc_rt_orders[order_idx][RT_TO]]);

	new fmt_str[512];
	format(fmt_str, sizeof fmt_str,
		"{FFFFFF}Название груза: {FFFF24}%s{FFFFFF}\n\
Тип груза: {FFFF24}%s{FFFFFF}\n\
Точка загрузки: {FFFF24}%s{FFFFFF}\n\
Точка разгрузки: {FFFF24}%s{FFFFFF}\n\
Расстояние: {FFFF24}%.1f км.{FFFFFF}\n\
Вес груза: {FFFF24}%d кг.{FFFFFF}\n\
Ваша зарплата: {FFFF24}%d рублей.",
		g_tc_rt_orders[order_idx][RT_CARGO_NAME],
		g_tc_rt_orders[order_idx][RT_TYPE_NAME],
		g_tc_point_names[g_tc_rt_orders[order_idx][RT_FROM]],
		to_name, km, weight, driver_pay);

	Dialog(playerid, DIALOG_TC_ORDER_INFO, DIALOG_STYLE_MSGBOX, "{FFFF24}Информация о грузе", fmt_str, "Взять", "Назад");
	return 1;
}

stock TC_ShowAdminCompanyList(playerid)
{
	if(!GetPlayerAdminEx(playerid)) return 0;

	new body[2048];
	format(body, sizeof(body), "{FFFF24}Компания\tОфис\tСтатус\n");

	for(new i = 0; i < g_tc_companies_loaded; i++)
	{
		new status[32];
		if(g_tc_companies[i][TC_OWNER_ID] == -1)
			format(status, sizeof(status), "{66CC33}Свободна");
		else
			format(status, sizeof(status), "{FFFF24}%s", g_tc_owner_name[i]);

		new cname[48];
		TC_GetCompanyDisplayName(i, cname, sizeof cname);

		new tc_line[96];
		format(tc_line, sizeof tc_line, "{FFFFFF}%s\t%s\t%s\n",
			cname, g_tc_office_names[g_tc_companies[i][TC_OFFICE]], status);
		strcat(body, tc_line);
	}

	Dialog(playerid, DIALOG_TC_ADMIN_LIST, DIALOG_STYLE_TABLIST_HEADERS, "{FFFF24}Выдача транспортной компании", body, "Выбрать", "Отмена");
	return 1;
}

stock TC_ShowAdminGiveInput(playerid, company_idx)
{
	p_tc_admin_company[playerid] = company_idx;

	new cname[48];
	TC_GetCompanyDisplayName(company_idx, cname, sizeof cname);

	new fmt_str[160];
	format(fmt_str, sizeof fmt_str, "{FFFFFF}Компания: {FFFF24}%s{FFFFFF}\n\nВведите никнейм игрока:", cname);
	Dialog(playerid, DIALOG_TC_ADMIN_GIVE, DIALOG_STYLE_INPUT, "{FFFF24}Выдача компании", fmt_str, "Выдать", "Назад");
	return 1;
}
// END INLINED: modules/m1stoks/transportCompany/tcomp_ui.inc
// BEGIN INLINED: modules/m1stoks/transportCompany/tcomp_dialog.inc
#if defined _tcomp_dialog_included
	#endinput
#endif
#define _tcomp_dialog_included

stock TC_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
	if(dialogid == DIALOG_TC_DEPOSIT)
	{
		new company_sql = GetPVarInt(playerid, "TCDepositCompany");
		DeletePVar(playerid, "TCDepositCompany"); // consume before any SQL; duplicate replies cannot pay again
		if(!IsPlayerLogged(playerid) || company_sql <= 0) return 1;
		if(response) TC_DepositMoney(playerid, company_sql, inputtext);
		TC_ShowMainMenu(playerid);
		return 1;
	}
	if(TC56_Dialog(playerid, dialogid, response, inputtext)) return 1;
	if(dialogid >= DIALOG_TC_MAIN_MENU && dialogid <= DIALOG_TC_RETURN_RENT)
	{
		if(!IsPlayerLogged(playerid)) return 1;
		if(!g_tc_companies_loaded)
			return SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Компании ещё не загружены. Обратитесь к администратору.");
	}
	switch(dialogid)
	{
		case DIALOG_TC_MAIN_MENU:
		{
			if(!response) return 1;
			new company_idx = TC_GetPlayerCompanyIndex(playerid);
			new bool:is_owner = (company_idx != -1 && TC_IsCompanyOwner(playerid, company_idx));
			switch(listitem)
			{
				case 0: TC_ShowInfo(playerid);
				case 1: TC_ShowFleetList(playerid, 0);
				case 2: TC_ShowManageMenu(playerid);
				case 3: TC_ShowEmployeesMenu(playerid);
				case 4: TC_ShowFinance(playerid);
				case 5: TC_ShowPersonal(playerid);
				case 6: TC_ShowUpgrade(playerid);
				case 7: TC_ShowHelp(playerid);
				case 8:
				{
					if(is_owner)
						TC_ShowDepositDialog(playerid);
					else
						TC_ShowLeaveConfirm(playerid);
				}
				case 9: if(!is_owner) TC_ShowDepositDialog(playerid);
			}
			return 1;
		}
		case DIALOG_TC_INFO:
		{
			if(response) TC_ShowMainMenu(playerid);
			return 1;
		}
		case DIALOG_TC_HELP:
		{
			if(response) TC_ShowMainMenu(playerid);
			return 1;
		}
		case DIALOG_TC_FLEET_LIST:
		{
			if(!response) return 1;

			new company_idx = TC_GetPlayerCompanyIndex(playerid);
			if(company_idx == -1) return 1;

			new company_sql = g_tc_companies[company_idx][TC_SQL_ID];
			new total = TC_GetFleetCountForCompany(company_sql);
			new page = p_tc_fleet_page[playerid];
			new row_offset = (page > 0) ? 1 : 0;
			new items_on_page = total - page * TC_FLEET_PAGE_SIZE;
			if(items_on_page > TC_FLEET_PAGE_SIZE) items_on_page = TC_FLEET_PAGE_SIZE;
			new has_next = ((page + 1) * TC_FLEET_PAGE_SIZE < total);
			new bool:owner_can_buy = TC_IsCompanyOwner(playerid, company_idx);
			new buy_row = -1;
			if(owner_can_buy && has_next)
				buy_row = row_offset + items_on_page + 1;
			else if(owner_can_buy && !has_next)
				buy_row = row_offset + items_on_page;

			if(page > 0 && listitem == 0)
			{
				TC_ShowFleetList(playerid, page - 1);
				return 1;
			}
			if(has_next && listitem == row_offset + items_on_page)
			{
				TC_ShowFleetList(playerid, page + 1);
				return 1;
			}
			if(owner_can_buy && listitem == buy_row)
			{
				TC_ShowBuyDialog(playerid);
				return 1;
			}

			new fleet_idx = GetPlayerListitemValue(playerid, listitem + 1);
			TC_ShowFleetVehicleMenu(playerid, fleet_idx);
			return 1;
		}
		case DIALOG_TC_FLEET_MANAGE:
		{
			new fleet_idx = p_tc_fleet_sel[playerid];
			new company_idx = TC_GetPlayerCompanyIndex(playerid);
			if(company_idx == -1) return 1;

			if(!TC_IsCompanyOwner(playerid, company_idx))
			{
				TC_ShowFleetList(playerid, p_tc_fleet_page[playerid]);
				return 1;
			}

			if(!response)
			{
				TC_ShowFleetList(playerid, p_tc_fleet_page[playerid]);
				return 1;
			}

			switch(listitem)
			{
				case 0: TC_ShowFleetRepairConfirm(playerid);
				case 1: TC_ShowFleetRentPriceDialog(playerid);
				case 2: TC_ShowFleetSellConfirm(playerid, fleet_idx);
			}
			return 1;
		}
		case DIALOG_TC_FLEET_REPAIR:
		{
			if(!response)
			{
				TC_ShowFleetVehicleMenu(playerid, p_tc_fleet_sel[playerid]);
				return 1;
			}
			TC_RepairFleet(playerid, p_tc_fleet_sel[playerid]);
			TC_ShowFleetVehicleMenu(playerid, p_tc_fleet_sel[playerid]);
			return 1;
		}
		case DIALOG_TC_FLEET_SELL_VEH:
		{
			if(!response)
			{
				TC_ShowFleetVehicleMenu(playerid, p_tc_fleet_sel[playerid]);
				return 1;
			}
			TC_SellFleetVehicle(playerid, p_tc_fleet_sel[playerid]);
			TC_ShowFleetList(playerid, p_tc_fleet_page[playerid]);
			return 1;
		}
		case DIALOG_TC_FLEET_RENTPRICE:
		{
			if(!response)
			{
				TC_ShowFleetVehicleMenu(playerid, p_tc_fleet_sel[playerid]);
				return 1;
			}
			if(!TC_SetFleetRentPrice(playerid, p_tc_fleet_sel[playerid], strval(inputtext)))
			{
				TC_ShowFleetRentPriceDialog(playerid);
				return 1;
			}
			TC_ShowFleetVehicleMenu(playerid, p_tc_fleet_sel[playerid]);
			return 1;
		}
		case DIALOG_TC_MANAGE:
		{
			if(!response) { TC_ShowMainMenu(playerid); return 1; }
			switch(listitem)
			{
				case 0: TC_ShowWithdrawDialog(playerid);
				case 1: TC_ShowRenameDialog(playerid);
				case 2: TC_ShowCommissionDialog(playerid);
				case 3: TC_ShowFireDialog(playerid);
				case 4: TC_ShowSellConfirm(playerid);
			}
			return 1;
		}
		case DIALOG_TC_WITHDRAW:
		{
			if(!response) { TC_ShowManageMenu(playerid); return 1; }
			TC_WithdrawMoney(playerid, strval(inputtext));
			return 1;
		}
		case DIALOG_TC_RENAME:
		{
			if(!response) { TC_ShowManageMenu(playerid); return 1; }
			TC_RenameCompany(playerid, inputtext);
			return 1;
		}
		case DIALOG_TC_COMMISSION:
		{
			if(!response) { TC_ShowManageMenu(playerid); return 1; }
			TC_SetCommission(playerid, strval(inputtext));
			return 1;
		}
		case DIALOG_TC_FIRE:
		{
			if(!response) { TC_ShowManageMenu(playerid); return 1; }
			if(!TC_PrepareFireTarget(playerid, inputtext))
			{
				TC_ShowFireDialog(playerid);
				return 1;
			}
			TC_ShowFireConfirm(playerid);
			return 1;
		}
		case DIALOG_TC_FIRE_CONFIRM:
		{
			if(!response) { TC_ShowFireDialog(playerid); return 1; }
			TC_FireEmployee(playerid, p_tc_fire_target[playerid]);
			return 1;
		}
		case DIALOG_TC_BUY:
		{
			if(!response) { TC_ShowFleetList(playerid, p_tc_fleet_page[playerid]); return 1; }
			if(listitem != 0) return 1;
			TC_BuyFleet(playerid, TC_BUY_TYPE_VAN);
			return 1;
		}
		case DIALOG_TC_SELL:
		{
			if(!response) { TC_ShowManageMenu(playerid); return 1; }
			TC_SellCompany(playerid);
			return 1;
		}
		case DIALOG_TC_EMPLOYEES:
		{
			if(!response) { TC_ShowMainMenu(playerid); return 1; }
			switch(listitem)
			{
				case 0: TC_ShowEmpListSubmenu(playerid);
				case 1: TC_ShowEmpRatingMenu(playerid);
			}
			return 1;
		}
		case DIALOG_TC_EMP_SUBMENU:
		{
			if(!response) { TC_ShowEmployeesMenu(playerid); return 1; }
			switch(listitem)
			{
				case 0: TC_ShowEmployeesInGame(playerid, 0);
				case 1: TC_ShowEmployeesDB(playerid, 1, 0);
				case 2: TC_ShowEmployeesDB(playerid, 2, 0);
			}
			return 1;
		}
		case DIALOG_TC_EMP_RATING_MENU:
		{
			if(!response) { TC_ShowEmployeesMenu(playerid); return 1; }
			switch(listitem)
			{
				case 0: TC_RequestRatingList(playerid, 0);
				case 1: TC_RequestRatingList(playerid, 1);
				case 2: TC_RequestRatingList(playerid, 2);
				case 3: TC_ShowRatingHelp(playerid);
			}
			return 1;
		}
		case DIALOG_TC_EMP_RATING_LIST:
		{
			TC_ShowEmpRatingMenu(playerid);
			return 1;
		}
		case DIALOG_TC_RATING_HELP:
		{
			TC_ShowEmpRatingMenu(playerid);
			return 1;
		}
		case DIALOG_TC_EMP_LIST:
		{
			new mode = p_tc_emp_view_mode[playerid];
			new page = p_tc_emp_page[playerid];
			new company_idx = TC_GetPlayerCompanyIndex(playerid);
			new bool:is_owner = (company_idx != -1 && TC_IsCompanyOwner(playerid, company_idx));

			if(!response)
			{
				if(mode == 0) TC_ShowEmpListSubmenu(playerid);
				else TC_ShowEmpListSubmenu(playerid);
				return 1;
			}

			if(mode == 0)
			{
				new owner_id = g_tc_companies[company_idx][TC_OWNER_ID];
				new total;
				foreach(new i : Player)
				{
					if(!IsPlayerLogged(i)) continue;
					if(p_tc_company[i] != company_idx) continue;
					if(GetPlayerAccountID(i) == owner_id) continue;
					total++;
				}
				new items_on_page = total - page * TC_EMPLOYEE_PAGE_SIZE;
				if(items_on_page > TC_EMPLOYEE_PAGE_SIZE) items_on_page = TC_EMPLOYEE_PAGE_SIZE;
				new has_next = ((page + 1) * TC_EMPLOYEE_PAGE_SIZE < total);

				if(has_next && listitem == items_on_page)
				{
					TC_ShowEmployeesInGame(playerid, page + 1);
					return 1;
				}

				if(is_owner && listitem < items_on_page)
				{
					new row = GetPlayerListitemValue(playerid, listitem + 1);
					format(p_tc_fire_target[playerid], 24, "%s", p_tc_emp_row_name[playerid][row]);
					TC_ShowFireConfirm(playerid);
					return 1;
				}
				return 1;
			}

			if(mode == 1 || mode == 2)
			{
				new shown = p_tc_emp_list_shown[playerid];
				new total = p_tc_emp_total[playerid];
				new has_next = ((page + 1) * TC_EMPLOYEE_PAGE_SIZE < total);

				if(has_next && listitem == shown)
				{
					TC_ShowEmployeesDB(playerid, mode, page + 1);
					return 1;
				}

				if(is_owner && listitem < shown)
				{
					new row = GetPlayerListitemValue(playerid, listitem + 1);
					format(p_tc_fire_target[playerid], 24, "%s", p_tc_emp_row_name[playerid][row]);
					TC_ShowFireConfirm(playerid);
				}
				return 1;
			}
			return 1;
		}
		case DIALOG_TC_FINANCE:
		{
			if(!response) { TC_ShowMainMenu(playerid); return 1; }
			switch(listitem)
			{
				case 0: TC_RequestFinanceDetail(playerid, TC_FIN_RENT);
				case 1: TC_RequestFinanceDetail(playerid, TC_FIN_TRANSPORT);
				case 2: TC_RequestFinanceDetail(playerid, TC_FIN_EXPENSE);
				case 3: TC_RequestFinanceDetail(playerid, TC_FIN_DEPOSIT);
			}
			return 1;
		}
		case DIALOG_TC_FINANCE_DETAIL:
		{
			if(response) TC_ShowFinance(playerid);
			return 1;
		}
		case DIALOG_TC_PERSONAL:
		{
			if(response) TC_ShowMainMenu(playerid);
			return 1;
		}
		case DIALOG_TC_UPGRADE:
		{
			if(!response) { TC_ShowMainMenu(playerid); return 1; }
			if(listitem < 0 || listitem > 2) return 1;
			TC_ShowUpgradeConfirm(playerid, listitem);
			return 1;
		}
		case DIALOG_TC_UPGRADE_CONFIRM:
		{
			if(!response)
			{
				TC_ShowUpgrade(playerid);
				return 1;
			}
			TC_BuyCompanyUpgrade(playerid, p_tc_upgrade_sel[playerid]);
			TC_ShowUpgrade(playerid);
			return 1;
		}
		case DIALOG_TC_LEAVE:
		{
			if(!response) { TC_ShowMainMenu(playerid); return 1; }
			TC_LeaveCompany(playerid);
			return 1;
		}
		case DIALOG_TC_COMPANY_LIST:
		{
			if(!response) return 1;

			new office = p_tc_office[playerid];
			new page = p_tc_company_page[playerid];
			new total;
			for(new i = 0; i < g_tc_companies_loaded; i++)
				if(g_tc_companies[i][TC_OFFICE] == office && g_tc_companies[i][TC_OWNER_ID] != -1)
					total++;

			new items_on_page = total - page * TC_COMPANY_PAGE_SIZE;
			if(items_on_page > TC_COMPANY_PAGE_SIZE) items_on_page = TC_COMPANY_PAGE_SIZE;
			new has_next = ((page + 1) * TC_COMPANY_PAGE_SIZE < total);

			if(has_next && listitem == items_on_page)
			{
				TC_ShowWorkerCompanyList(playerid, office, page + 1);
				return 1;
			}

			new company_idx = GetPlayerListitemValue(playerid, listitem + 1);
			if(company_idx < 0 || company_idx >= g_tc_companies_loaded) return 1;
			TC_ShowCompanyJoinConfirm(playerid, company_idx);
			return 1;
		}
		case DIALOG_TC_COMPANY_JOIN:
		{
			new company_idx = p_tc_join_company[playerid];
			if(!response)
			{
				if(company_idx >= 0)
					TC_ShowWorkerCompanyList(playerid, g_tc_companies[company_idx][TC_OFFICE], p_tc_company_page[playerid]);
				return 1;
			}
			if(company_idx < 0 || company_idx >= g_tc_companies_loaded) return 1;

			if(p_tc_company[playerid] != -1 || TC_GetOwnedCompanyIndex(playerid) != -1)
			{
				SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Вы уже состоите в транспортной компании.");
				return 1;
			}
			TC_JoinCompany(playerid, company_idx);
			return 1;
		}
		case DIALOG_TC_RENT_LIST:
		{
			if(!response) return 1;

			new page = p_tc_rent_page[playerid];
			new company_idx = TC_GetPlayerCompanyIndex(playerid);
			if(company_idx == -1) return 1;

			new company_sql = g_tc_companies[company_idx][TC_SQL_ID];
			new total;
			for(new i = 0; i < g_tc_fleet_loaded; i++)
			{
				if(g_tc_fleet[i][TF_COMPANY_ID] != company_sql) continue;
				if(g_tc_fleet[i][TF_BROKEN] || g_tc_fleet[i][TF_TRIPS_LEFT] <= 0) continue;
				if(g_tc_fleet[i][TF_RENTED_ACCOUNT_ID] != -1) continue;
				total++;
			}

			new items_on_page = total - page * TC_RENT_PAGE_SIZE;
			if(items_on_page > TC_RENT_PAGE_SIZE) items_on_page = TC_RENT_PAGE_SIZE;
			new has_next = ((page + 1) * TC_RENT_PAGE_SIZE < total);

			if(has_next && listitem == items_on_page)
			{
				TC_ShowRentList(playerid, page + 1);
				return 1;
			}

			new fleet_idx = GetPlayerListitemValue(playerid, listitem + 1);
			TC_StartRent(playerid, fleet_idx);
			return 1;
		}
		case DIALOG_TC_ORDERS_LIST:
		{
			if(!response) return 1;
			new order_idx = GetPlayerListitemValue(playerid, listitem + 1);
			TC_ShowOrderInfo(playerid, order_idx);
			return 1;
		}
		case DIALOG_TC_ORDER_INFO:
		{
			if(!response) { TC_ShowOrdersList(playerid, p_tc_orders_page[playerid]); return 1; }
			TC_AcceptOrder(playerid, p_tc_pick_order[playerid]);
			TC_Send(playerid, "Заказ принят.");
			return 1;
		}
		case DIALOG_TC_CARGO_RESPAWN:
		{
			if(!response) return 1;
			if(p_tc_order_progress[playerid] >= 2)
			{
				p_tc_trailer_last_recover_ms[playerid] = 0;
				TC_RecoverTrailerForActiveCargo(playerid, true);
				TC_RestoreActiveCheckpoint(playerid);
			}
			else TC_SpawnTrailerForPlayer(playerid, true);
			return 1;
		}
		case DIALOG_TC_RETURN_RENT:
		{
			if(!response) return 1;
			TC_ReturnRentedTruck(playerid);
			return 1;
		}
		case DIALOG_TC_ADMIN_LIST:
		{
			if(!response || !GetPlayerAdminEx(playerid)) return 1;
			if(listitem < 0 || listitem >= g_tc_companies_loaded) return 1;
			TC_ShowAdminGiveInput(playerid, listitem);
			return 1;
		}
		case DIALOG_TC_ADMIN_GIVE:
		{
			if(!response || !GetPlayerAdminEx(playerid))
			{
				if(GetPlayerAdminEx(playerid)) TC_RequestAdminCompanyList(playerid);
				return 1;
			}

			new company_idx = p_tc_admin_company[playerid];
			if(company_idx < 0 || company_idx >= g_tc_companies_loaded) return 1;

			new targetid = GetPlayerID(inputtext);
			if(targetid == INVALID_PLAYER_ID || !IsPlayerLogged(targetid))
			{
				SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Игрок не найден на сервере.");
				TC_ShowAdminGiveInput(playerid, company_idx);
				return 1;
			}
			TC_AdminGiveCompany(playerid, company_idx, targetid);
			return 1;
		}
	}
	return 0;
}
// END INLINED: modules/m1stoks/transportCompany/tcomp_dialog.inc
// BEGIN INLINED: modules/m1stoks/transportCompany/tcomp_events.inc
#if defined _tcomp_events_included
	#endinput
#endif
#define _tcomp_events_included

stock TC_CMD_Cargo(playerid)
{
	if(p_tc_company[playerid] == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Вы не состоите в транспортной компании.");
		return 1;
	}
	if(p_tc_active_order[playerid] == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Сначала возьмите заказ.");
		return 1;
	}

	// During an active loaded route /cargo is a recovery command. It must never
	// reset progress to the parking/spawn stage and therefore cannot lose cargo.
	if(p_tc_order_progress[playerid] >= 2)
	{
		if(TC_IsTrailerLinked(playerid))
		{
			SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Прицеп уже подцеплен, груз сохранён.");
			return 1;
		}
		p_tc_trailer_last_recover_ms[playerid] = 0;
		if(TC_RecoverTrailerForActiveCargo(playerid, true))
		{
			TC_RestoreActiveCheckpoint(playerid);
			SendClientMessage(playerid, TC_COLOR_GOOD, TC_MSG"Прицеп восстановлен. Текущий груз и маршрут сохранены.");
		}
		else
		{
			SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Не удалось восстановить прицеп. Остановите фуру и повторите /cargo.");
		}
		return 1;
	}

	if(p_tc_trailer_detached[playerid] && p_tc_trailer_vehicle[playerid] != -1)
	{
		Dialog(playerid, DIALOG_TC_CARGO_RESPAWN, DIALOG_STYLE_MSGBOX, "{FFFF24}Прицеп",
			"{FFFFFF}Прицеп был отцеплен.\nВернуться на стартовую точку и взять новый прицеп\nбез нового заказа?",
			"Да", "Нет");
		return 1;
	}

	TC_SpawnTrailerForPlayer(playerid, false);
	return 1;
}

stock TC_OnPlayerPickUpPickupEx(playerid, pickupid, action_type, action_id)
{
	#pragma unused pickupid
	if(action_type >= PICKUP_ACTION_TYPE_TC_OFFICE_ENTER && action_type <= PICKUP_ACTION_TYPE_TC_RENT)
	{
		if(!IsPlayerLogged(playerid)) return 1;
		if(action_type != PICKUP_ACTION_TYPE_TC_OFFICE_ENTER && action_type != PICKUP_ACTION_TYPE_TC_OFFICE_EXIT && !g_tc_companies_loaded)
			return SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Компании ещё не загружены. Обратитесь к администратору.");
	}
	switch(action_type)
	{
		case PICKUP_ACTION_TYPE_TC_OFFICE_ENTER:
		{
			if(action_id < 0 || action_id > 1) return 0;
			if(p_tc_company[playerid] == -1 && TC_GetOwnedCompanyIndex(playerid) == -1)
			{
				if(!TC_CheckEmploymentRequirements(playerid))
					return 1;
			}
			SetPlayerPosEx(playerid,
				g_tc_interior_enter[action_id][0], g_tc_interior_enter[action_id][1],
				g_tc_interior_enter[action_id][2], g_tc_interior_enter[action_id][3],
				g_tc_interior_id, g_tc_interior_vw[action_id], false);
			TC_EnterOffice(playerid, action_id);
			return 1;
		}
		case PICKUP_ACTION_TYPE_TC_OFFICE_EXIT:
		{
			if(action_id < 0 || action_id > 1) return 0;
			SetPlayerPosEx(playerid,
				g_tc_building_exit[action_id][0], g_tc_building_exit[action_id][1],
				g_tc_building_exit[action_id][2], g_tc_building_exit[action_id][3],
				0, 0, false);
			TC_ExitOffice(playerid, action_id);
			return 1;
		}
		case PICKUP_ACTION_TYPE_TC_ORDER:
		{
			new Float:px = g_tc_marker_order[0], Float:py = g_tc_marker_order[1], Float:pz = g_tc_marker_order[2];
			if(IsValidPickupID(pickupid))
			{
				px = GetPickupInfo(pickupid, P_POS_X);
				py = GetPickupInfo(pickupid, P_POS_Y);
				pz = GetPickupInfo(pickupid, P_POS_Z);
			}
			if(!IsPlayerInRangeOfPoint(playerid, TC_ORDER_PICKUP_RANGE, px, py, pz))
				return 0;
			TC_ShowOrdersList(playerid, 0);
			return 1;
		}
		case PICKUP_ACTION_TYPE_TC_COMPANY_LIST:
		{
			TC_ShowWorkerCompanyList(playerid, action_id, 0);
			return 1;
		}
		case PICKUP_ACTION_TYPE_TC_RENT:
		{
			if(p_tc_rent_vehicle[playerid] != -1)
			{
				TC_ShowReturnRentDialog(playerid);
				return 1;
			}
			TC_ShowRentList(playerid, 0);
			return 1;
		}
	}
	return 0;
}

CMD:tc(playerid, params[])
{
	if(p_tc_company[playerid] == -1)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Чат /tc доступен только сотрудникам транспортных компаний.");
		return 1;
	}
	if(isnull(params))
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Использование: /tc [текст]");
		return 1;
	}
	if(GetPlayerData(playerid, P_MUTE))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Вы не можете писать в чат во время мута.");
		return 1;
	}
	TC_SendChatMessage(playerid, params);
	return 1;
}

CMD:company(playerid, params[])
{
	#pragma unused params
	if(p_tc_company[playerid] == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Вы не состоите в компании. Устройтесь через стойку в офисе.");
		return 1;
	}
	TC_ShowMainMenu(playerid);
	return 1;
}

CMD:cargo(playerid, params[])
{
	#pragma unused params
	if(!IsPlayerLogged(playerid)) return 1;
	return TC_CMD_Cargo(playerid);
}

CMD:orders(playerid, params[])
{
	#pragma unused params
	TC_ShowOrdersList(playerid, 0);
	return 1;
}

CMD:givecompany(playerid, params[])
{
	#pragma unused params
	if(!GetPlayerAdminEx(playerid))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Команда доступна только администрации.");
		return 1;
	}
	TC_RequestAdminCompanyList(playerid);
	return 1;
}

CMD:tcsetname(playerid, params[])
{
	if(!GetPlayerAdminEx(playerid))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Команда доступна только администрации.");
		return 1;
	}

	new company_sql, name[48];
	if(sscanf(params, "us[48]", company_sql, name))
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Использование: /tcsetname [id в БД] [название]");
		return 1;
	}

	if(!TC_IsValidCompanyName(name))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Название только на английском: буквы A-Z, цифры, пробел и _.");
		return 1;
	}

	if(!TC_AdminSetCompanyName(company_sql, name))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Компания с таким id не найдена.");
		return 1;
	}

	new msg[96];
	format(msg, sizeof msg, TC_MSG"Название компании #%d: {FFFF24}%s", company_sql, name);
	SendClientMessage(playerid, TC_COLOR_GOOD, msg);
	return 1;
}

CMD:tcrenamereset(playerid, params[])
{
	if(!GetPlayerAdminEx(playerid))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Команда доступна только администрации.");
		return 1;
	}

	new company_sql;
	if(sscanf(params, "i", company_sql))
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Использование: /tcrenamereset [id компании в БД]");
		return 1;
	}

	if(!TC_AdminResetRenameCooldown(company_sql))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Компания с таким id не найдена.");
		return 1;
	}

	SendClientMessage(playerid, TC_COLOR_GOOD, TC_MSG"Кулдаун смены названия сброшен. Владелец может переименовать компанию.");
	return 1;
}

CMD:tcgovplus(playerid, params[])
{
	if(!GetPlayerAdminEx(playerid))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Команда доступна только администрации.");
		return 1;
	}

	new office;
	if(sscanf(params, "d", office))
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Использование: /tcgovplus [офис: 0 - Батырево, 1 - Бусаево]");
		return 1;
	}
	if(office < 0 || office > 1) office = 0;

	new idx = TC_AddGovPlusOrder(office);
	if(idx == -1)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Нет свободных слотов для заказа.");
		return 1;
	}

	new msg[128];
	format(msg, sizeof msg, TC_MSG"Добавлен Гос+ заказ в офис \"%s\" (оплата %d руб.).",
		g_tc_office_names[office], g_tc_rt_orders[idx][RT_TOTAL_PAY]);
	SendClientMessage(playerid, TC_COLOR_GOOD, msg);
	return 1;
}

CMD:tpcheck(playerid, params[])
{
	#pragma unused params
	if(!GetPlayerAdminEx(playerid))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Команда доступна только администрации.");
		return 1;
	}

	new Float:x, Float:y, Float:z;
	if(!TC_GetActiveRouteMarkerPos(playerid, x, y, z))
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Активный маркер маршрута не установлен.");
		return 1;
	}

	new vehicleid = GetPlayerVehicleID(playerid);
	if(vehicleid != INVALID_VEHICLE_ID && IsValidVehicle(vehicleid))
	{
		SetVehiclePos(vehicleid, x, y, z + 1.0);
		SetVehicleZAngle(vehicleid, 0.0);
		LinkVehicleToInterior(vehicleid, 0);
		SetVehicleVirtualWorld(vehicleid, 0);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
		SetCameraBehindPlayer(playerid);

		new msg[128];
		format(msg, sizeof msg, TC_MSG"Телепорт на маркер с транспортом: {FFFF24}%.2f, %.2f, %.2f{FFFFFF}.", x, y, z);
		SendClientMessage(playerid, TC_COLOR_GOOD, msg);
		return 1;
	}

	SetPlayerPosEx(playerid, x, y, z + 1.0, 0.0, 0, 0, false);

	new msg[128];
	format(msg, sizeof msg, TC_MSG"Телепорт на маркер: {FFFF24}%.2f, %.2f, %.2f{FFFFFF}.", x, y, z);
	SendClientMessage(playerid, TC_COLOR_GOOD, msg);
	return 1;
}

CMD:tcprod(playerid, params[])
{
	new businessid = GetPlayerInBiz(playerid);
	if(businessid == -1)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Зайдите в свой бизнес, чтобы заказать продукты.");
		return 1;
	}
	if(GetBusinessData(businessid, B_OWNER_ID) != GetPlayerAccountID(playerid))
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Вы не владелец этого бизнеса.");
		return 1;
	}

	new amount;
	if(sscanf(params, "d", amount) || amount <= 0 || amount > 5000)
	{
		SendClientMessage(playerid, TC_COLOR_MSG, TC_MSG"Использование: /tcprod [кол-во продуктов 1-5000]");
		return 1;
	}

	new res = TC_CreatePrivateOrder(businessid, amount);
	if(res == -2)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"По вашему бизнесу уже есть активный заказ продуктов.");
		return 1;
	}
	if(res < 0)
	{
		SendClientMessage(playerid, TC_COLOR_ERROR, TC_MSG"Не удалось создать заказ (нет свободных слотов).");
		return 1;
	}

	new msg[128];
	format(msg, sizeof msg, TC_MSG"Заказ на {FFFF24}%d{FFFFFF} продуктов размещён. Дальнобойщики уведомлены.", amount);
	SendClientMessage(playerid, TC_COLOR_GOOD, msg);
	return 1;
}
// END INLINED: modules/m1stoks/transportCompany/tcomp_events.inc
// BEGIN INLINED: modules/m1stoks/transportCompany/tcomp_vehicle_guard.inc
#if defined _tcomp_vehicle_guard_included
	#endinput
#endif
#define _tcomp_vehicle_guard_included

new bool:g_tc_guarded_vehicle[MAX_VEHICLES];
new g_tc_guard_owner[MAX_VEHICLES];

stock TC_GuardVehicle(vehicleid, bool:guard)
{
	if(vehicleid < 1 || vehicleid >= MAX_VEHICLES) return 0;
	g_tc_guarded_vehicle[vehicleid] = guard;
	if(!guard)
		g_tc_guard_owner[vehicleid] = -1;
	return 1;
}

stock TC_RegisterGuardedVehicle(vehicleid, playerid)
{
	if(vehicleid < 1 || vehicleid >= MAX_VEHICLES) return 0;
	g_tc_guarded_vehicle[vehicleid] = true;
	g_tc_guard_owner[vehicleid] = playerid;
	return 1;
}

stock TC_IsGuardedVehicle(vehicleid)
{
	if(vehicleid < 1 || vehicleid >= MAX_VEHICLES) return 0;
	return g_tc_guarded_vehicle[vehicleid];
}

stock TC_IsModuleWorkVehicle(vehicleid)
{
	if(vehicleid < 1 || vehicleid >= MAX_VEHICLES) return 0;
	if(TC_IsGuardedVehicle(vehicleid)) return 1;
	foreach(new i : Player)
	{
		if(!IsPlayerConnected(i)) continue;
		if(p_tc_trailer_vehicle[i] == vehicleid) return 1;
		if(p_tc_rent_vehicle[i] == vehicleid) return 1;
	}
	return 0;
}

stock TC_ClearGuardedVehicle(vehicleid)
{
	return TC_GuardVehicle(vehicleid, false);
}

stock TC_ForceDestroyVehicle(vehicleid)
{
	if(vehicleid < 1 || vehicleid >= MAX_VEHICLES) return 0;
	TC_ClearGuardedVehicle(vehicleid);
	return n_veh_DestroyVehicle(vehicleid);
}

stock tc_DestroyVehicle(vehicleid)
{
	if(TC_IsGuardedVehicle(vehicleid))
	{
		printf("[TransportCompany] Заблокирован DestroyVehicle для ТС #%d (owner %d)", vehicleid, g_tc_guard_owner[vehicleid]);
		return 0;
	}
	return n_veh_DestroyVehicle(vehicleid);
}

#if defined _ALS_DestroyVehicle
	#undef DestroyVehicle
#else
	#define _ALS_DestroyVehicle
#endif
#define DestroyVehicle tc_DestroyVehicle
// END INLINED: modules/m1stoks/transportCompany/tcomp_vehicle_guard.inc
// END INLINED: modules/m1stoks/transportCompany/transportcompany.inc

