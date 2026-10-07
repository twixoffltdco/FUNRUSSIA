#if defined _org_warehouse_included
	#endinput
#endif
#define _org_warehouse_included

#define ORG_WH_DIALOG_EQUIPMENT         (32970)
#define ORG_WH_DIALOG_MANAGE            (32971)
#define ORG_WH_PICKUP_MODEL             (3013)
#define ORG_WH_PICKUP_TYPE              (23)
#define ORG_WH_INTERACTION_DISTANCE     (4.0)
#define ORG_WH_PICKUP_RELEASE_DISTANCE  (2.0)
#define ORG_WH_ITEM_COOLDOWN_MS         (3000)
#define ORG_WH_WEAPON_COOLDOWN_SEC      (300)
#define ORG_WH_MAX_MENU_ITEMS           (6)

enum E_ORG_WH_ITEM
{
	ORG_WH_ITEM_NONE = 0,
	ORG_WH_ITEM_DEAGLE,
	ORG_WH_ITEM_AK47,
	ORG_WH_ITEM_STUN,
	ORG_WH_ITEM_MEDKIT,
	ORG_WH_ITEM_ARMOR
};

enum E_ORG_WAREHOUSE
{
	OW_ORG_ID,
	OW_NAME[32],
	Float:OW_X,
	Float:OW_Y,
	Float:OW_Z,
	Float:OW_ANGLE,
	OW_INTERIOR,
	OW_WORLD,
	bool:OW_ENABLED,
	bool:OW_OPENED,
	OW_PICKUP_ID,
	STREAMER_TAG_3D_TEXT_LABEL:OW_LABEL_ID
};

/* Координаты УМВД привязаны к его отдельному virtual world 2. */
new g_org_warehouse[][E_ORG_WAREHOUSE] =
{
	{TEAM_GOVERNMENT, "Правительство", -871.157531, -1590.545043, 1398.501098, 255.285629, 1, 1, true, true, -1, STREAMER_TAG_3D_TEXT_LABEL:-1},
	{TEAM_ARMY, "Армия", 1802.828002, 1730.312622, 1493.079833, 161.967666, 1, 1, true, true, -1, STREAMER_TAG_3D_TEXT_LABEL:-1},
	{TEAM_DPS, "ГИБДД", -1101.681396, 1523.185668, 1499.987304, 351.940643, 1, 1, true, true, -1, STREAMER_TAG_3D_TEXT_LABEL:-1},
	{TEAM_PPS, "УМВД", -1101.886352, 1523.722656, 1499.987304, 5.742703, 1, 2, true, true, -1, STREAMER_TAG_3D_TEXT_LABEL:-1},
	{TEAM_FBI, "ФСБ", 2915.609130, 2008.550659, 2051.005126, 1.036115, 1, 1, true, true, -1, STREAMER_TAG_3D_TEXT_LABEL:-1}
};

new g_org_wh_selected[MAX_PLAYERS];
new g_org_wh_menu_items[MAX_PLAYERS][ORG_WH_MAX_MENU_ITEMS];
new g_org_wh_menu_count[MAX_PLAYERS];
new g_org_wh_last_item_tick[MAX_PLAYERS];
new g_org_wh_locked_index[MAX_PLAYERS];

stock OrgWarehouse_GetIndexByTeam(team)
{
	for(new index; index < sizeof(g_org_warehouse); index++)
	{
		if(g_org_warehouse[index][OW_ORG_ID] == team)
			return index;
	}
	return -1;
}

stock bool:OrgWarehouse_IsSupportedTeam(team)
{
	new index = OrgWarehouse_GetIndexByTeam(team);
	return index != -1 && g_org_warehouse[index][OW_ENABLED];
}

stock bool:OrgWarehouse_IsPlayerAtWarehouse(playerid, index)
{
	if(index < 0 || index >= sizeof(g_org_warehouse)) return false;
	if(GetPlayerInterior(playerid) != g_org_warehouse[index][OW_INTERIOR]) return false;
	if(GetPlayerVirtualWorld(playerid) != g_org_warehouse[index][OW_WORLD]) return false;
	return IsPlayerInRangeOfPoint(playerid, ORG_WH_INTERACTION_DISTANCE,
		g_org_warehouse[index][OW_X],
		g_org_warehouse[index][OW_Y],
		g_org_warehouse[index][OW_Z]);
}

stock OrgWarehouse_UpdateLabel(index)
{
	if(index < 0 || index >= sizeof(g_org_warehouse)) return 0;
	if(!g_org_warehouse[index][OW_ENABLED]) return 0;

	new label_text[180];
	format(label_text, sizeof(label_text),
		"{33CC33}Оружейный склад\n{FFFFFF}%s\nСтатус: %s%s",
		g_org_warehouse[index][OW_NAME],
		g_org_warehouse[index][OW_OPENED] ? "{33CC33}" : "{FF5533}",
		g_org_warehouse[index][OW_OPENED] ? "Открыт" : "Закрыт");

	if(g_org_warehouse[index][OW_LABEL_ID] != STREAMER_TAG_3D_TEXT_LABEL:-1)
	{
		UpdateDynamic3DTextLabelText(g_org_warehouse[index][OW_LABEL_ID], -1, label_text);
	}
	return 1;
}

stock OrgWarehouse_CreateWorldElements(index)
{
	if(index < 0 || index >= sizeof(g_org_warehouse)) return 0;
	if(!g_org_warehouse[index][OW_ENABLED]) return 0;

	g_org_warehouse[index][OW_PICKUP_ID] = CreateDynamicPickup(
		ORG_WH_PICKUP_MODEL,
		ORG_WH_PICKUP_TYPE,
		g_org_warehouse[index][OW_X],
		g_org_warehouse[index][OW_Y],
		g_org_warehouse[index][OW_Z],
		g_org_warehouse[index][OW_WORLD],
		g_org_warehouse[index][OW_INTERIOR]
	);

	g_org_warehouse[index][OW_LABEL_ID] = CreateDynamic3DTextLabel(
		" ", -1,
		g_org_warehouse[index][OW_X],
		g_org_warehouse[index][OW_Y],
		g_org_warehouse[index][OW_Z] + 0.8,
		8.0,
		INVALID_PLAYER_ID,
		INVALID_VEHICLE_ID,
		0,
		g_org_warehouse[index][OW_WORLD],
		g_org_warehouse[index][OW_INTERIOR]
	);

	OrgWarehouse_UpdateLabel(index);
	return 1;
}

stock OrgWarehouse_LoadStates()
{
	mysql_query(mysql,
		"CREATE TABLE IF NOT EXISTS `org_warehouses` (`org_id` INT NOT NULL, `opened` TINYINT(1) NOT NULL DEFAULT 1, PRIMARY KEY (`org_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251",
		false
	);

	new query[144];
	for(new index; index < sizeof(g_org_warehouse); index++)
	{
		if(!g_org_warehouse[index][OW_ENABLED]) continue;
		mysql_format(mysql, query, sizeof(query),
			"INSERT IGNORE INTO `org_warehouses` (`org_id`, `opened`) VALUES (%d, 1)",
			g_org_warehouse[index][OW_ORG_ID]);
		mysql_query(mysql, query, false);
	}

	new Cache:result = mysql_query(mysql, "SELECT `org_id`, `opened` FROM `org_warehouses`", true);
	if(mysql_errno())
	{
		printf("[ORG_WAREHOUSE] Failed to load states, mysql errno=%d", mysql_errno());
		cache_delete(result);
		return 0;
	}

	new rows = cache_num_rows();
	for(new row; row < rows; row++)
	{
		new team = cache_get_row_int(row, 0);
		new index = OrgWarehouse_GetIndexByTeam(team);
		if(index != -1 && g_org_warehouse[index][OW_ENABLED])
		{
			g_org_warehouse[index][OW_OPENED] = cache_get_row_int(row, 1) != 0;
		}
	}
	cache_delete(result);
	return 1;
}

stock OrgWarehouse_SaveState(index)
{
	if(index < 0 || index >= sizeof(g_org_warehouse)) return 0;
	if(!g_org_warehouse[index][OW_ENABLED]) return 0;

	new query[144];
	mysql_format(mysql, query, sizeof(query),
		"UPDATE `org_warehouses` SET `opened`=%d WHERE `org_id`=%d LIMIT 1",
		_:g_org_warehouse[index][OW_OPENED],
		g_org_warehouse[index][OW_ORG_ID]);
	mysql_query(mysql, query, false);
	return mysql_errno() == 0;
}

stock OrgWarehouse_Init()
{
	OrgWarehouse_LoadStates();
	for(new index; index < sizeof(g_org_warehouse); index++)
	{
		OrgWarehouse_CreateWorldElements(index);
	}
	return 1;
}

stock OrgWarehouse_AddMenuItem(playerid, item, const item_name[], menu[], menu_size)
{
	if(g_org_wh_menu_count[playerid] >= ORG_WH_MAX_MENU_ITEMS) return 0;
	g_org_wh_menu_items[playerid][g_org_wh_menu_count[playerid]++] = item;
	strcat(menu, item_name, menu_size);
	strcat(menu, "\n", menu_size);
	return 1;
}

stock bool:OrgWarehouse_CanUseGovernmentWarehouse(playerid)
{
	return GetPlayerTeamEx(playerid) != TEAM_GOVERNMENT || (1 <= GetPlayerJob(playerid) <= 3);
}

stock OrgWarehouse_ShowEquipmentDialog(playerid, index)
{
	if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
	if(index < 0 || index >= sizeof(g_org_warehouse)) return 0;
	if(!g_org_warehouse[index][OW_ENABLED]) return 0;
	if(GetPlayerTeamEx(playerid) != g_org_warehouse[index][OW_ORG_ID])
		return SendClientMessage(playerid, 0xFF5533FF, "У Вас нет доступа к складу чужой организации.");
	if(!OrgWarehouse_IsPlayerAtWarehouse(playerid, index))
		return SendClientMessage(playerid, 0xFF5533FF, "Вы находитесь не у своего оружейного склада.");
	if(!g_org_warehouse[index][OW_OPENED])
		return SendClientMessage(playerid, 0xFF5533FF, "Оружейный склад организации закрыт.");
	if(!OrgWarehouse_CanUseGovernmentWarehouse(playerid))
		return SendClientMessage(playerid, 0xFF5533FF, "Склад Правительства доступен только сотрудникам службы охраны.");

	new menu[256], title[96];
	g_org_wh_selected[playerid] = index;
	g_org_wh_menu_count[playerid] = 0;

	switch(g_org_warehouse[index][OW_ORG_ID])
	{
		case TEAM_GOVERNMENT:
		{
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_DEAGLE, "Desert Eagle", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_MEDKIT, "Аптечка", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_ARMOR, "Бронежилет", menu, sizeof(menu));
		}
		case TEAM_ARMY:
		{
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_DEAGLE, "Desert Eagle", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_AK47, "AK-47", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_MEDKIT, "Аптечка", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_ARMOR, "Бронежилет", menu, sizeof(menu));
		}
		case TEAM_DPS, TEAM_PPS:
		{
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_DEAGLE, "Desert Eagle", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_STUN, "Шокер / дубинка", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_MEDKIT, "Аптечка", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_ARMOR, "Бронежилет", menu, sizeof(menu));
		}
		case TEAM_FBI:
		{
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_DEAGLE, "Desert Eagle", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_AK47, "AK-47", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_STUN, "Шокер", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_MEDKIT, "Аптечка", menu, sizeof(menu));
			OrgWarehouse_AddMenuItem(playerid, ORG_WH_ITEM_ARMOR, "Бронежилет", menu, sizeof(menu));
		}
		default: return 0;
	}

	format(title, sizeof(title), "Оружейный склад: %s", g_org_warehouse[index][OW_NAME]);
	Dialog(playerid, ORG_WH_DIALOG_EQUIPMENT, DIALOG_STYLE_LIST, title, menu, "Взять", "Закрыть");
	return 1;
}

stock bool:OrgWarehouse_IsItemAllowed(team, item)
{
	switch(team)
	{
		case TEAM_GOVERNMENT: return item == ORG_WH_ITEM_DEAGLE || item == ORG_WH_ITEM_MEDKIT || item == ORG_WH_ITEM_ARMOR;
		case TEAM_ARMY: return item == ORG_WH_ITEM_DEAGLE || item == ORG_WH_ITEM_AK47 || item == ORG_WH_ITEM_MEDKIT || item == ORG_WH_ITEM_ARMOR;
		case TEAM_DPS, TEAM_PPS: return item == ORG_WH_ITEM_DEAGLE || item == ORG_WH_ITEM_STUN || item == ORG_WH_ITEM_MEDKIT || item == ORG_WH_ITEM_ARMOR;
		case TEAM_FBI: return item == ORG_WH_ITEM_DEAGLE || item == ORG_WH_ITEM_AK47 || item == ORG_WH_ITEM_STUN || item == ORG_WH_ITEM_MEDKIT || item == ORG_WH_ITEM_ARMOR;
	}
	return false;
}

stock OrgWarehouse_GiveItem(playerid, item)
{
	new current_time = gettime();
	switch(item)
	{
		case ORG_WH_ITEM_DEAGLE:
		{
			if(GetPVarInt(playerid, "took_deagle") > current_time)
				return SendClientMessage(playerid, 0x999999FF, "Вы уже недавно брали Desert Eagle."), 0;
			GivePlayerWeapon(playerid, WEAPON_DEAGLE, 120);
			SetPVarInt(playerid, "took_deagle", current_time + ORG_WH_WEAPON_COOLDOWN_SEC);
			SendClientMessage(playerid, 0x33CC66FF, "Вы взяли Desert Eagle и 120 патронов.");
		}
		case ORG_WH_ITEM_AK47:
		{
			if(GetPVarInt(playerid, "took_ak47") > current_time)
				return SendClientMessage(playerid, 0x999999FF, "Вы уже недавно брали AK-47."), 0;
			GivePlayerWeapon(playerid, WEAPON_AK47, 230);
			SetPVarInt(playerid, "took_ak47", current_time + ORG_WH_WEAPON_COOLDOWN_SEC);
			SendClientMessage(playerid, 0x33CC66FF, "Вы взяли AK-47 и 230 патронов.");
		}
		case ORG_WH_ITEM_STUN:
		{
			if(GetPVarInt(playerid, "took_nitestick") > current_time)
				return SendClientMessage(playerid, 0x999999FF, "Вы уже недавно брали шокер / дубинку."), 0;
			GivePlayerWeapon(playerid, WEAPON_NITESTICK, 1);
			SetPVarInt(playerid, "took_nitestick", current_time + ORG_WH_WEAPON_COOLDOWN_SEC);
			SendClientMessage(playerid, 0x33CC66FF, "Вы взяли шокер / дубинку.");
		}
		case ORG_WH_ITEM_MEDKIT:
		{
			if(Inventory11_AddItemToDatabase(playerid, 22, 1, 1, 0, 0) == -1)
				return SendClientMessage(playerid, 0xFF5533FF, "Не удалось добавить аптечку: проверьте место и вес инвентаря."), 0;
			SendClientMessage(playerid, 0x33CC66FF, "Аптечка добавлена в инвентарь (/inv).");
		}
		case ORG_WH_ITEM_ARMOR:
		{
			new Float:armour;
			GetPlayerArmour(playerid, armour);
			if(armour > 20.0)
				return SendClientMessage(playerid, 0x999999FF, "У Вас уже есть бронежилет."), 0;
			SetPlayerArmour(playerid, 100.0);
			SendClientMessage(playerid, 0x33CC66FF, "Вы надели бронежилет.");
		}
		default: return 0;
	}
	return 1;
}

stock OrgWarehouse_HandleEquipmentDialog(playerid, response, listitem)
{
	if(!response) return 1;
	if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;

	new index = g_org_wh_selected[playerid];
	if(index < 0 || index >= sizeof(g_org_warehouse)) return 1;
	if(!g_org_warehouse[index][OW_ENABLED]) return 1;
	if(GetPlayerTeamEx(playerid) != g_org_warehouse[index][OW_ORG_ID]) return 1;
	if(!g_org_warehouse[index][OW_OPENED])
		return SendClientMessage(playerid, 0xFF5533FF, "Оружейный склад организации закрыт.");
	if(!OrgWarehouse_IsPlayerAtWarehouse(playerid, index)) return 1;
	if(!OrgWarehouse_CanUseGovernmentWarehouse(playerid)) return 1;
	if(listitem < 0 || listitem >= g_org_wh_menu_count[playerid]) return 1;

	new item = g_org_wh_menu_items[playerid][listitem];
	if(!OrgWarehouse_IsItemAllowed(GetPlayerTeamEx(playerid), item)) return 1;

	new now_tick = GetTickCount();
	if(g_org_wh_last_item_tick[playerid] != 0 && now_tick - g_org_wh_last_item_tick[playerid] < ORG_WH_ITEM_COOLDOWN_MS)
		return SendClientMessage(playerid, 0x999999FF, "Подождите несколько секунд перед следующей выдачей.");

	if(OrgWarehouse_GiveItem(playerid, item))
	{
		g_org_wh_last_item_tick[playerid] = now_tick;
	}
	return 1;
}

stock OrgWarehouse_ShowManageDialog(playerid)
{
	if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
	if(GetPlayerJob(playerid) != 10)
		return SendClientMessage(playerid, 0xFF5533FF, "Управлять складом может только лидер организации.");

	new index = OrgWarehouse_GetIndexByTeam(GetPlayerTeamEx(playerid));
	if(index == -1 || !g_org_warehouse[index][OW_ENABLED])
		return SendClientMessage(playerid, 0xFF5533FF, "Для этой организации оружейный склад пока не реализован.");

	new title[128];
	format(title, sizeof(title), "Склад %s | Статус: %s%s",
		g_org_warehouse[index][OW_NAME],
		g_org_warehouse[index][OW_OPENED] ? "{33CC33}" : "{FF5533}",
		g_org_warehouse[index][OW_OPENED] ? "Открыт" : "Закрыт");

	Dialog(playerid, ORG_WH_DIALOG_MANAGE, DIALOG_STYLE_LIST, title,
		"Открыть склад\nЗакрыть склад", "Выбрать", "Закрыть");
	return 1;
}

stock OrgWarehouse_HandleManageDialog(playerid, response, listitem)
{
	if(!response) return 1;
	if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
	if(GetPlayerJob(playerid) != 10) return 1;

	new index = OrgWarehouse_GetIndexByTeam(GetPlayerTeamEx(playerid));
	if(index == -1 || !g_org_warehouse[index][OW_ENABLED]) return 1;
	if(listitem < 0 || listitem > 1) return 1;

	new bool:open_warehouse = listitem == 0;
	if(g_org_warehouse[index][OW_OPENED] == open_warehouse)
	{
		return SendClientMessage(playerid, 0x999999FF,
			open_warehouse ? "Склад уже открыт." : "Склад уже закрыт.");
	}

	g_org_warehouse[index][OW_OPENED] = open_warehouse;
	OrgWarehouse_SaveState(index);
	OrgWarehouse_UpdateLabel(index);
	SendClientMessage(playerid, 0x33CC66FF,
		open_warehouse ? "Оружейный склад организации открыт." : "Оружейный склад организации закрыт.");
	return 1;
}

public OnGameModeInit()
{
	#if defined orgwh_OnGameModeInit
		orgwh_OnGameModeInit();
	#endif
	OrgWarehouse_Init();
	return 1;
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit orgwh_OnGameModeInit
#if defined orgwh_OnGameModeInit
	forward orgwh_OnGameModeInit();
#endif

public OnPlayerConnect(playerid)
{
	g_org_wh_selected[playerid] = -1;
	g_org_wh_menu_count[playerid] = 0;
	g_org_wh_last_item_tick[playerid] = 0;
	g_org_wh_locked_index[playerid] = -1;
	#if defined orgwh_OnPlayerConnect
		return orgwh_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect orgwh_OnPlayerConnect
#if defined orgwh_OnPlayerConnect
	forward orgwh_OnPlayerConnect(playerid);
#endif

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	for(new index; index < sizeof(g_org_warehouse); index++)
	{
		if(g_org_warehouse[index][OW_ENABLED] && pickupid == g_org_warehouse[index][OW_PICKUP_ID])
		{
			// Один вход на пикап = одно открытие. Повтор разрешается
			// только после фактического выхода игрока из зоны ящика.
			if(g_org_wh_locked_index[playerid] == index) return 1;
			g_org_wh_locked_index[playerid] = index;
			return OrgWarehouse_ShowEquipmentDialog(playerid, index);
		}
	}

	#if defined orgwh_OnPlayerPickUpDynamicPickup
		return orgwh_OnPlayerPickUpDynamicPickup(playerid, pickupid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerPickUpDynamicPickup
	#undef OnPlayerPickUpDynamicPickup
#else
	#define _ALS_OnPlayerPickUpDynamicPickup
#endif
#define OnPlayerPickUpDynamicPickup orgwh_OnPlayerPickUpDynamicPickup
#if defined orgwh_OnPlayerPickUpDynamicPickup
	forward orgwh_OnPlayerPickUpDynamicPickup(playerid, pickupid);
#endif

public OnPlayerUpdate(playerid)
{
	new index = g_org_wh_locked_index[playerid];
	if(index >= 0 && index < sizeof(g_org_warehouse))
	{
		if(GetPlayerInterior(playerid) != g_org_warehouse[index][OW_INTERIOR]
		|| GetPlayerVirtualWorld(playerid) != g_org_warehouse[index][OW_WORLD]
		|| !IsPlayerInRangeOfPoint(playerid, ORG_WH_PICKUP_RELEASE_DISTANCE,
			g_org_warehouse[index][OW_X],
			g_org_warehouse[index][OW_Y],
			g_org_warehouse[index][OW_Z]))
		{
			g_org_wh_locked_index[playerid] = -1;
		}
	}

	#if defined orgwh_OnPlayerUpdate
		return orgwh_OnPlayerUpdate(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerUpdate
	#undef OnPlayerUpdate
#else
	#define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate orgwh_OnPlayerUpdate
#if defined orgwh_OnPlayerUpdate
	forward orgwh_OnPlayerUpdate(playerid);
#endif

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == ORG_WH_DIALOG_EQUIPMENT)
		return OrgWarehouse_HandleEquipmentDialog(playerid, response, listitem);
	if(dialogid == ORG_WH_DIALOG_MANAGE)
		return OrgWarehouse_HandleManageDialog(playerid, response, listitem);

	#if defined orgwh_OnDialogResponse
		return orgwh_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnDialogResponse
	#undef OnDialogResponse
#else
	#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse orgwh_OnDialogResponse
#if defined orgwh_OnDialogResponse
	forward orgwh_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif
