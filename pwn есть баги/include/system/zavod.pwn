#if defined _factory_job_included
    #endinput
#endif
#define _factory_job_included

#define FACTORY_JOB_SKIN            (188)
#define FACTORY_JOB_INTERIOR        (1)
#define FACTORY_JOB_MACHINE_COUNT   (4)
#define FACTORY_JOB_ATTACH_SLOT     (1)

static g_factory_enter_pickup;
static g_factory_exit_pickup;
static g_factory_job_pickup;
static bool:g_factory_working[MAX_PLAYERS];
static bool:g_factory_has_material[MAX_PLAYERS];
static bool:g_factory_has_product[MAX_PLAYERS];
static bool:g_factory_processing[MAX_PLAYERS];
static g_factory_target_machine[MAX_PLAYERS] = { -1, ... };
static g_factory_salary[MAX_PLAYERS];
static g_factory_timer[MAX_PLAYERS];

static const Float:g_factory_machine_pos[FACTORY_JOB_MACHINE_COUNT][3] =
{
    {-5.9090, -6.0739, 1381.0601},
    {-5.9169, -0.8683, 1381.0601},
    {-5.9155,  4.3760, 1381.0601},
    {-5.9155,  9.7351, 1381.0601}
};

stock FactoryJob_ResetPlayer(playerid, bool:restore_skin = false)
{
    if(g_factory_timer[playerid])
    {
        KillTimer(g_factory_timer[playerid]);
        g_factory_timer[playerid] = 0;
    }
    g_factory_working[playerid] = false;
    g_factory_has_material[playerid] = false;
    g_factory_has_product[playerid] = false;
    g_factory_processing[playerid] = false;
    g_factory_target_machine[playerid] = -1;
    g_factory_salary[playerid] = 0;
    DisablePlayerCheckpoint(playerid);
    TogglePlayerControllable(playerid, true);
    if(IsPlayerAttachedObjectSlotUsed(playerid, FACTORY_JOB_ATTACH_SLOT))
        RemovePlayerAttachedObject(playerid, FACTORY_JOB_ATTACH_SLOT);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    if(restore_skin && IsPlayerConnected(playerid))
        SetPlayerSkin(playerid, GetPlayerData(playerid, P_SKIN));
    return 1;
}

stock FactoryJob_Init()
{
    g_factory_enter_pickup = CreatePickup(19130, 23, -978.7820, 2070.2219, 45.3795, -1);
    g_factory_exit_pickup = CreatePickup(19130, 23, -31.8808, -3.9729, 1381.0601, -1);
    Create3DTextLabel("{FFFFFF}Вход на завод", -1, -978.7820, 2070.2219, 45.8795, 15.0, 0);
    Create3DTextLabel("{FFFFFF}Выход на улицу", -1, -31.8808, -3.9729, 1381.5601, 10.0, 0);

    CreateActor(8, -25.2997, -10.0753, 1381.0596, 182.0);
    g_factory_job_pickup = CreatePickup(1275, 23, -25.1597, -10.9273, 1381.0596, -1);
    Create3DTextLabel("{FFFFFF}РАЗДЕВАЛКА ЗАВОДА\n{FFFF00}Наступите для начала или завершения работы", -1, -25.1597, -10.9273, 1381.5596, 10.0, 0);
    Create3DTextLabel("{00FFFF}СКЛАД МАТЕРИАЛОВ\n{FFFFFF}Взять заготовку", -1, -2.1210, -14.0634, 1381.5601, 10.0, 0);
    Create3DTextLabel("{00FF00}СКЛАД ПРОДУКЦИИ\n{FFFFFF}Сдать изделие", -1, -10.9001, 22.8166, 1381.5601, 10.0, 0);

    for(new i; i < FACTORY_JOB_MACHINE_COUNT; i++)
    {
        new label[32];
        format(label, sizeof label, "{FFFF00}Станок №%d", i + 1);
        Create3DTextLabel(label, -1, g_factory_machine_pos[i][0], g_factory_machine_pos[i][1], g_factory_machine_pos[i][2] + 0.5, 10.0, 0);
    }
    for(new playerid; playerid < MAX_PLAYERS; playerid++) FactoryJob_ResetPlayer(playerid);
    return 1;
}

stock FactoryJob_TakeMaterial(playerid)
{
    g_factory_has_material[playerid] = true;
    g_factory_target_machine[playerid] = random(FACTORY_JOB_MACHINE_COUNT);
    new machine = g_factory_target_machine[playerid], message[128];
    SetPlayerCheckpoint(playerid, g_factory_machine_pos[machine][0], g_factory_machine_pos[machine][1], g_factory_machine_pos[machine][2], 2.0);
    format(message, sizeof message, "{FFFF00}Вы взяли материал. {FFFFFF}Идите к станку №%d.", machine + 1);
    SendClientMessage(playerid, -1, message);
    return 1;
}

forward FactoryJob_CraftingFinished(playerid);
public FactoryJob_CraftingFinished(playerid)
{
    g_factory_timer[playerid] = 0;
    if(!g_factory_working[playerid] || !g_factory_processing[playerid]) return 0;
    g_factory_processing[playerid] = false;
    g_factory_has_material[playerid] = false;
    TogglePlayerControllable(playerid, true);
    ClearAnimations(playerid);

    if(random(100) < 10)
    {
        SendClientMessage(playerid, 0xFF0000FF, "Ошибка! Деталь оказалась бракованной. Возьмите новый материал.");
        SetPlayerCheckpoint(playerid, -2.1210, -14.0634, 1381.0601, 2.0);
        return 1;
    }

    g_factory_has_product[playerid] = true;
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
    SetPlayerAttachedObject(playerid, FACTORY_JOB_ATTACH_SLOT, 1221, 6, 0.15, 0.11, 0.0, 0.0, 90.0, 0.0, 0.6, 0.6, 0.6);
    SetPlayerCheckpoint(playerid, -10.9001, 22.8166, 1381.0601, 2.0);
    SendClientMessage(playerid, -1, "{00FF00}Готово! {FFFFFF}Отнесите деталь на конвейер завода.");
    return 1;
}

stock FactoryJob_OnPickup(playerid, pickupid)
{
    if(pickupid == g_factory_enter_pickup)
    {
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerInterior(playerid, FACTORY_JOB_INTERIOR);
        SetPlayerPos(playerid, -29.9151, -5.4584, 1381.0601);
        SetPlayerFacingAngle(playerid, 90.0);
        return 1;
    }
    if(pickupid == g_factory_exit_pickup)
    {
        if(g_factory_working[playerid])
            SendClientMessage(playerid, 0xFF6600FF, "Сначала завершите смену в раздевалке завода.");
        else
        {
            SetPlayerVirtualWorld(playerid, 0);
            SetPlayerInterior(playerid, 0);
            SetPlayerPos(playerid, -973.2694, 2070.3044, 44.5868);
            SetPlayerFacingAngle(playerid, 270.0);
        }
        return 1;
    }
    if(pickupid != g_factory_job_pickup) return 0;

    if(g_factory_working[playerid])
    {
        new total_money = g_factory_salary[playerid], message[128];
        if(total_money > 0)
        {
            GivePlayerMoneyEx(playerid, total_money, "Зарплата на заводе", true, true);
            format(message, sizeof message, "{00FF00}Смена завершена. {FFFFFF}Заработано: %d руб.", total_money);
            SendClientMessage(playerid, -1, message);
        }
        else SendClientMessage(playerid, -1, "Смена завершена, но Вы ничего не заработали.");
        FactoryJob_ResetPlayer(playerid, true);
    }
    else
    {
        FactoryJob_ResetPlayer(playerid);
        g_factory_working[playerid] = true;
        SetPlayerSkin(playerid, FACTORY_JOB_SKIN);
        SetPlayerCheckpoint(playerid, -2.1210, -14.0634, 1381.0601, 2.0);
        SendClientMessage(playerid, -1, "Вы начали смену. Отправляйтесь на склад за материалом.");
    }
    return 1;
}

stock FactoryJob_OnPlayerUpdate(playerid)
{
    if(!g_factory_working[playerid] || g_factory_processing[playerid]) return 0;
    if(!g_factory_has_material[playerid] && !g_factory_has_product[playerid])
    {
        if(IsPlayerInRangeOfPoint(playerid, 2.0, -2.1210, -14.0634, 1381.0601)) FactoryJob_TakeMaterial(playerid);
    }
    else if(g_factory_has_material[playerid])
    {
        new machine = g_factory_target_machine[playerid];
        if(machine >= 0 && IsPlayerInRangeOfPoint(playerid, 1.5, g_factory_machine_pos[machine][0], g_factory_machine_pos[machine][1], g_factory_machine_pos[machine][2]))
        {
            g_factory_processing[playerid] = true;
            DisablePlayerCheckpoint(playerid);
            TogglePlayerControllable(playerid, false);
            ApplyAnimation(playerid, "CAR", "Fixn_Car_Loop", 4.1, 1, 1, 1, 1, 1, 1);
            SendClientMessage(playerid, -1, "{FFFF00}Сборка детали... {FFFFFF}Подождите 8 секунд.");
            g_factory_timer[playerid] = SetTimerEx("FactoryJob_CraftingFinished", 8000, false, "i", playerid);
        }
    }
    else if(g_factory_has_product[playerid] && IsPlayerInRangeOfPoint(playerid, 2.0, -10.9001, 22.8166, 1381.0601))
    {
        g_factory_has_product[playerid] = false;
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        if(IsPlayerAttachedObjectSlotUsed(playerid, FACTORY_JOB_ATTACH_SLOT)) RemovePlayerAttachedObject(playerid, FACTORY_JOB_ATTACH_SLOT);
        new money = 500000 + random(100000), message[144];
        g_factory_salary[playerid] += money;
        SetPlayerCheckpoint(playerid, -2.1210, -14.0634, 1381.0601, 2.0);
        ApplyAnimation(playerid, "CARRY", "putdwn", 4.0, 0, 0, 0, 0, 0, 1);
        format(message, sizeof message, "{00FF00}Изделие сдано! {FFFFFF}+%d руб. Всего за смену: %d руб.", money, g_factory_salary[playerid]);
        SendClientMessage(playerid, -1, message);
    }
    return 1;
}
