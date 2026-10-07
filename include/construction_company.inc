#if defined _CONSTRUCTION_COMPANY_INCLUDED
    #endinput
#endif
#define _CONSTRUCTION_COMPANY_INCLUDED

#define DIALOG_CONSTRUCTION_JOIN   (30110)
#define DIALOG_CONSTRUCTION_START  (30111)
#define DIALOG_CONSTRUCTION_END    (30112)
#define CONSTRUCTION_COOLDOWN      (18000)
#define CONSTRUCTION_PANEL_REWARD  (5000)
#define CONSTRUCTION_FINAL_REWARD  (150000)
#define CONSTRUCTION_AREA_COUNT    (12)

enum E_CONSTRUCTION_STAGE
{
    CONSTRUCTION_NONE,
    CONSTRUCTION_HIRED,
    CONSTRUCTION_PANEL_1,
    CONSTRUCTION_PANEL_2,
    CONSTRUCTION_PANEL_3,
    CONSTRUCTION_BAG_1_TAKE,
    CONSTRUCTION_BAG_1_DROP,
    CONSTRUCTION_BAG_2_TAKE,
    CONSTRUCTION_BAG_2_DROP,
    CONSTRUCTION_BAG_3_TAKE,
    CONSTRUCTION_BAG_3_DROP,
    CONSTRUCTION_DELIVERY
};

new g_construction_area[CONSTRUCTION_AREA_COUNT];
new g_construction_stage[MAX_PLAYERS];
new g_construction_action_timer[MAX_PLAYERS];
new g_construction_action_seconds[MAX_PLAYERS];
new g_construction_action_epoch[MAX_PLAYERS];
new g_construction_vehicle[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};
new bool:g_construction_has_bag[MAX_PLAYERS];
#define CONSTRUCTION_MAP_ICON_SLOT (97)

static const Float:g_construction_pos[CONSTRUCTION_AREA_COUNT][4] =
{
    {179.305343, 391.597808, 16.192012, 1.5},
    {-9.116186, 1807.725463, 9.477350, 1.5},
    {18.071474, 1875.481445, 9.907059, 1.4},
    {18.053916, 1875.414550, 18.907058, 1.4},
    {18.054027, 1875.414428, 15.407059, 1.4},
    {44.907081, 1868.700561, 15.407059, 1.4},
    {7.416964, 1869.525146, 15.407059, 1.4},
    {39.442390, 1868.927612, 22.407058, 1.4},
    {75.329261, 1863.635009, 18.907058, 1.4},
    {7.857259, 1876.818725, 15.407059, 1.4},
    {7.346275, 1869.510864, 9.907059, 1.4},
    {79.417998, 1836.903564, 9.408595, 4.0}
};

stock Construction_SetCheckpoint(playerid, area_index)
{
    if(!(0 <= area_index < CONSTRUCTION_AREA_COUNT)) return 0;
    RemovePlayerMapIcon(playerid, CONSTRUCTION_MAP_ICON_SLOT);
    SetPlayerCheckpoint(playerid, g_construction_pos[area_index][0], g_construction_pos[area_index][1],
        g_construction_pos[area_index][2], g_construction_pos[area_index][3]);
    SetPlayerMapIcon(playerid, CONSTRUCTION_MAP_ICON_SLOT,
        g_construction_pos[area_index][0], g_construction_pos[area_index][1], g_construction_pos[area_index][2],
        0, 0xFF0000FF, MAPICON_GLOBAL);
    return 1;
}

stock Construction_RemoveBag(playerid)
{
    if(g_construction_has_bag[playerid])
    {
        RemovePlayerAttachedObject(playerid, 8);
        g_construction_has_bag[playerid] = false;
    }
    return 1;
}

stock Construction_ResetPlayer(playerid, bool:restore_skin = true)
{
    g_construction_action_epoch[playerid]++;
    if(g_construction_action_timer[playerid])
    {
        KillTimer(g_construction_action_timer[playerid]);
        g_construction_action_timer[playerid] = 0;
    }
    g_construction_action_seconds[playerid] = 0;
    TogglePlayerControllable(playerid, true);
    Construction_RemoveBag(playerid);
    DisablePlayerCheckpoint(playerid);
    RemovePlayerMapIcon(playerid, CONSTRUCTION_MAP_ICON_SLOT);

    if(g_construction_vehicle[playerid] != INVALID_VEHICLE_ID)
    {
        if(IsValidVehicle(g_construction_vehicle[playerid])) DestroyVehicle(g_construction_vehicle[playerid]);
        g_construction_vehicle[playerid] = INVALID_VEHICLE_ID;
    }
    g_construction_stage[playerid] = CONSTRUCTION_NONE;
    if(restore_skin && IsPlayerConnected(playerid)) SetPlayerSkinInit(playerid);
    return 1;
}

stock bool:Construction_IsWorking(playerid)
{
    return g_construction_stage[playerid] != CONSTRUCTION_NONE;
}

stock Construction_GetCooldown(playerid)
{
    new query[160];
    mysql_format(mysql, query, sizeof query,
        "SELECT cooldown_until FROM construction_cooldowns WHERE account_id=%d LIMIT 1", GetPlayerAccountID(playerid));
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        cache_delete(result);
        return -1;
    }
    new cooldown;
    if(cache_num_rows(result)) cooldown = cache_get_field_content_int(0, "cooldown_until");
    cache_delete(result);
    return cooldown;
}

stock Construction_SaveCooldown(playerid, cooldown_until)
{
    new query[220];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO construction_cooldowns(account_id,cooldown_until) VALUES(%d,%d) ON DUPLICATE KEY UPDATE cooldown_until=%d",
        GetPlayerAccountID(playerid), cooldown_until, cooldown_until);
    new Cache:result = mysql_query(mysql, query, true);
    new error = mysql_errno();
    cache_delete(result);
    return error == 0;
}

forward Construction_ActionTick(playerid, epoch);
public Construction_ActionTick(playerid, epoch)
{
    if(!IsPlayerConnected(playerid) || epoch != g_construction_action_epoch[playerid] || !g_construction_action_timer[playerid]) return 0;
    g_construction_action_seconds[playerid]--;
    if(g_construction_action_seconds[playerid] > 0)
    {
        new timer_text[24];
        format(timer_text, sizeof timer_text, "~r~%d", g_construction_action_seconds[playerid]);
        GameTextForPlayer(playerid, timer_text, 1100, 4);
        return 1;
    }

    KillTimer(g_construction_action_timer[playerid]);
    g_construction_action_timer[playerid] = 0;
    TogglePlayerControllable(playerid, true);
    ClearAnimations(playerid);
    GivePlayerMoneyEx(playerid, CONSTRUCTION_PANEL_REWARD, "Строительная компания: ремонт щитка", true, true);

    switch(g_construction_stage[playerid])
    {
        case CONSTRUCTION_PANEL_1: { g_construction_stage[playerid] = CONSTRUCTION_PANEL_2; Construction_SetCheckpoint(playerid, 3); }
        case CONSTRUCTION_PANEL_2: { g_construction_stage[playerid] = CONSTRUCTION_PANEL_3; Construction_SetCheckpoint(playerid, 4); }
        case CONSTRUCTION_PANEL_3: { g_construction_stage[playerid] = CONSTRUCTION_BAG_1_TAKE; Construction_SetCheckpoint(playerid, 5); }
    }
    SendClientMessage(playerid, 0x66CC00FF, "Щиток отремонтирован. Вы получили 5 000 рублей");
    return 1;
}

stock Construction_StartPanelRepair(playerid, panel)
{
    if(g_construction_action_timer[playerid]) return SendClientMessage(playerid, 0xCECECEFF, "Вы уже выполняете работу");
    if(g_construction_stage[playerid] != CONSTRUCTION_PANEL_1 + panel) return SendClientMessage(playerid, 0xCECECEFF, "Сначала выполните предыдущий этап");
    if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, 0xCECECEFF, "Выйдите из транспорта");

    g_construction_action_seconds[playerid] = 10;
    new epoch = ++g_construction_action_epoch[playerid];
    TogglePlayerControllable(playerid, false);
    SetPlayerAnimation(playerid, 6); // /anim 7
    GameTextForPlayer(playerid, "~r~10", 1100, 4);
    g_construction_action_timer[playerid] = SetTimerEx("Construction_ActionTick", 1000, true, "ii", playerid, epoch);
    SendClientMessage(playerid, 0xFFFF00FF, "Ремонт щитка начат. Не покидайте сервер до завершения");
    return 1;
}

stock Construction_TakeBag(playerid, bag_number)
{
    new required_stage = CONSTRUCTION_BAG_1_TAKE + (bag_number * 2);
    if(g_construction_stage[playerid] != required_stage) return SendClientMessage(playerid, 0xCECECEFF, "Сначала выполните предыдущий этап");
    if(g_construction_has_bag[playerid]) return SendClientMessage(playerid, 0xCECECEFF, "У Вас уже есть мешок");
    if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, 0xCECECEFF, "Выйдите из транспорта");

    g_construction_has_bag[playerid] = true;
    SetPlayerAttachedObject(playerid, 8, 1264, 1, 0.15, 0.35, 0.0, 0.0, 90.0, 0.0, 0.7, 0.7, 0.7);
    g_construction_stage[playerid]++;
    Construction_SetCheckpoint(playerid, 6 + bag_number * 2);
    SendClientMessage(playerid, 0xFFFF00FF, "Вы взяли мешок. Отнесите его к точке разгрузки");
    return 1;
}

stock Construction_DropBag(playerid, bag_number)
{
    new required_stage = CONSTRUCTION_BAG_1_DROP + (bag_number * 2);
    if(g_construction_stage[playerid] != required_stage || !g_construction_has_bag[playerid])
        return SendClientMessage(playerid, 0xCECECEFF, "У Вас нет нужного мешка");

    Construction_RemoveBag(playerid);
    if(bag_number < 2)
    {
        g_construction_stage[playerid]++;
        Construction_SetCheckpoint(playerid, 7 + bag_number * 2);
        return SendClientMessage(playerid, 0x66CC00FF, "Мешок сдан. Заберите следующий");
    }

    g_construction_stage[playerid] = CONSTRUCTION_DELIVERY;
    g_construction_vehicle[playerid] = CreateVehicle(486, -41.542228, 1881.632202, 4.548228, 177.128326, 3, 3, -1, 1, 0, playerid);
    if(g_construction_vehicle[playerid] == INVALID_VEHICLE_ID || !IsValidVehicle(g_construction_vehicle[playerid]))
    {
        Construction_ResetPlayer(playerid);
        return SendClientMessage(playerid, 0xFF6600FF, "Не удалось создать рабочий транспорт. Начните работу заново");
    }
    SetVehicleVirtualWorld(g_construction_vehicle[playerid], GetPlayerVirtualWorld(playerid));
    LinkVehicleToInterior(g_construction_vehicle[playerid], GetPlayerInterior(playerid));
    PutPlayerInVehicle(playerid, g_construction_vehicle[playerid], 0);
    Construction_SetCheckpoint(playerid, 11);
    SendClientMessage(playerid, 0x66CC00FF, "Мешки убраны. Доставьте бульдозер к мусорному баку");
    return 1;
}

stock Construction_Finish(playerid)
{
    if(g_construction_stage[playerid] != CONSTRUCTION_DELIVERY) return 0;
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER || GetPlayerVehicleID(playerid) != g_construction_vehicle[playerid])
        return SendClientMessage(playerid, 0xCECECEFF, "Подъедьте к баку на выданном бульдозере");

    GivePlayerMoneyEx(playerid, CONSTRUCTION_FINAL_REWARD, "Строительная компания: завершение смены", true, true);
    SendClientMessage(playerid, 0x66CC00FF, "Смена завершена. Вы получили 150 000 рублей");
    Construction_ResetPlayer(playerid);
    return 1;
}

stock bool:Construction_IsForemanArea(areaid)
{
    return g_construction_area[1] == areaid;
}

stock bool:Construction_IsPlayerNearForeman(playerid)
{
    if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return false;
    return IsPlayerInRangeOfPoint(playerid, g_construction_pos[1][3],
        g_construction_pos[1][0], g_construction_pos[1][1], g_construction_pos[1][2]);
}

stock bool:Construction_TryInteract(playerid)
{
    if(!Construction_IsPlayerNearForeman(playerid)) return false;
    if(GetPlayerJob(playerid) != JOB_CONSTRUCTION)
    {
        SendClientMessage(playerid, 0xCECECEFF, "Сначала устройтесь Строителем у начальника Андреевича");
        return true;
    }
    if(g_construction_stage[playerid] != CONSTRUCTION_NONE)
    {
        ShowPlayerDialog(playerid, DIALOG_CONSTRUCTION_END, DIALOG_STYLE_MSGBOX,
            "Прораб Александр", "Вы действительно хотите завершить рабочий день? Весь прогресс смены будет потерян.", "Завершить", "Назад");
        return true;
    }
    ShowPlayerDialog(playerid, DIALOG_CONSTRUCTION_START, DIALOG_STYLE_MSGBOX,
        "Прораб Александр", "Получить рабочую форму и начать смену?", "Начать", "Отмена");
    return true;
}

stock Construction_OnEnterArea(playerid, areaid)
{
    new index = -1;
    for(new i; i < CONSTRUCTION_AREA_COUNT; i++) if(g_construction_area[i] == areaid) { index = i; break; }
    if(index == -1) return 0;

    // The foreman uses the same bottom interaction button as casino tables.
    if(index == 1)
    {
        ToggleInteractionWindow(playerid, true);
        return 1;
    }

    if(index == 0)
    {
        if(GetPlayerJob(playerid) == JOB_CONSTRUCTION)
            return SendClientMessage(playerid, 0xCECECEFF, "Вы уже работаете Строителем. Для начала смены обратитесь к прорабу Александру"), 1;
        if(GetPlayerJob(playerid) != 0)
            return SendClientMessage(playerid, 0xCECECEFF, "Сначала увольтесь с текущей работы через /mm"), 1;
        if(GetPlayerLevel(playerid) < 8) return SendClientMessage(playerid, 0xCECECEFF, "Работа доступна с 8 уровня"), 1;
        ShowPlayerDialog(playerid, DIALOG_CONSTRUCTION_JOIN, DIALOG_STYLE_MSGBOX,
            "Строительная компания", "Устроиться на постоянную работу Строителем?", "Устроиться", "Отмена");
        return 1;
    }
    if(2 <= index <= 4) return Construction_StartPanelRepair(playerid, index - 2), 1;
    if(index == 5) return Construction_TakeBag(playerid, 0), 1;
    if(index == 6) return Construction_DropBag(playerid, 0), 1;
    if(index == 7) return Construction_TakeBag(playerid, 1), 1;
    if(index == 8) return Construction_DropBag(playerid, 1), 1;
    if(index == 9) return Construction_TakeBag(playerid, 2), 1;
    if(index == 10) return Construction_DropBag(playerid, 2), 1;
    if(index == 11) return Construction_Finish(playerid), 1;
    return 1;
}

stock Construction_OnDialogResponse(playerid, dialogid, response)
{
    if(dialogid == DIALOG_CONSTRUCTION_JOIN)
    {
        if(!response) return 1;
        if(GetPlayerJob(playerid) != 0) return SendClientMessage(playerid, 0xCECECEFF, "Сначала увольтесь с текущей работы"), 1;
        if(GetPlayerLevel(playerid) < 8) return 1;
        SetPlayerData(playerid, P_JOB, JOB_CONSTRUCTION);
        UpdatePlayerDatabaseInt(playerid, "job", JOB_CONSTRUCTION);
        SendClientMessage(playerid, 0x66CC00FF, "Вы устроились Строителем. Работа сохранена; для начала смены отправляйтесь к прорабу Александру");
        return 1;
    }
    if(dialogid == DIALOG_CONSTRUCTION_END)
    {
        if(response && g_construction_stage[playerid] != CONSTRUCTION_NONE)
        {
            Construction_ResetPlayer(playerid);
            SendClientMessage(playerid, 0xFFFF00FF, "Вы принудительно завершили рабочий день без награды");
        }
        return 1;
    }
    if(dialogid == DIALOG_CONSTRUCTION_START)
    {
        if(!response || g_construction_stage[playerid] != CONSTRUCTION_NONE || GetPlayerJob(playerid) != JOB_CONSTRUCTION) return 1;
        g_construction_stage[playerid] = CONSTRUCTION_PANEL_1;
        SetPlayerSkin(playerid, 206);
        Construction_SetCheckpoint(playerid, 2);
        SendClientMessage(playerid, 0xFFFF00FF, "Рабочий день начат. Отремонтируйте три электрощитка по порядку");
        return 1;
    }
    return 0;
}

stock Construction_Init()
{
    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS construction_cooldowns (account_id INT NOT NULL, cooldown_until INT NOT NULL DEFAULT 0, PRIMARY KEY(account_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", false);

    for(new i; i < CONSTRUCTION_AREA_COUNT; i++)
        g_construction_area[i] = CreateDynamicSphere(g_construction_pos[i][0], g_construction_pos[i][1], g_construction_pos[i][2], g_construction_pos[i][3], 0, 0);

    CreateActor(34, 179.305297, 391.597808, 16.195312, 92.8);
    CreateDynamic3DTextLabel("{FFDC33}Начальник Андреевич\n{FFFFFF}Строительная компания, работа с 8 уровня", 0xFFFFFFFF, 179.305343, 391.597808, 17.1, 12.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    CreateActor(228, -9.116186, 1807.725463, 9.477350, 86.5);
    CreateDynamic3DTextLabel("{FFDC33}Прораб Александр\n{FFFFFF}Начало рабочей смены", 0xFFFFFFFF, -9.116186, 1807.725463, 10.4, 12.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);

    CreateDynamic3DTextLabel("{FFFF00}Электрощиток №1", 0xFFFFFFFF, 18.071474, 1875.481445, 10.7, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    CreateDynamic3DTextLabel("{FFFF00}Электрощиток №2", 0xFFFFFFFF, 18.053916, 1875.414550, 19.7, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    CreateDynamic3DTextLabel("{FFFF00}Электрощиток №3", 0xFFFFFFFF, 18.054027, 1875.414428, 16.2, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    CreateDynamic3DTextLabel("{A9A9A9}Мешок с мусором", 0xFFFFFFFF, 44.907081, 1868.700561, 16.2, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    CreateDynamic3DTextLabel("{A9A9A9}Мешок с мусором", 0xFFFFFFFF, 39.442390, 1868.927612, 23.2, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    CreateDynamic3DTextLabel("{A9A9A9}Мешок с мусором", 0xFFFFFFFF, 7.857259, 1876.818725, 16.2, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    CreateDynamicObject(1334, 79.417998, 1836.903564, 8.85, 0.0, 0.0, 90.0, 0, 0, -1, 150.0, 150.0);
    CreateDynamic3DTextLabel("{FF5533}Мусорный бак\n{FFFFFF}Сюда складывать мешки с мусором", 0xFFFFFFFF, 79.417998, 1836.903564, 10.8, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    return 1;
}
