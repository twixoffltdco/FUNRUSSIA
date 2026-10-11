new sphere_menu_electric, sphere_arenda_electric, sphere_razdew_electric;

new sphere_exit_for_electric, sphere_enter_for_electric;

new bool:player_electric[MAX_PLAYERS];
new player_arenda_electric[MAX_PLAYERS];
new player_salary_electric[MAX_PLAYERS];
new player_orders_electric[MAX_PLAYERS];

enum struct_orders_electric
{
    E_NAME[42],
    Float:E_MULTIPLIER,
    Float:E_X,        
    Float:E_Y,    
    Float:E_Z,
    E_SPHERE
}

new Float:coord_houses_electric[4][3] =
{
    {-244.631195,998.545166,12.000000},
    {-284.473846,1006.350891,12.125518},
    {-307.238586,1005.557983,12.132812},
    {-359.540252,1005.697875,12.132812}
};

new orders_electric[10][struct_orders_electric] = 
{
    {"Сломанный щиток в подъезде №1", 1.0,                      559.875244,27.876850,1049.265625, -1},
    {"Сломанный щиток в подъезде №2", 1.0,                      559.875244,27.876850,1049.265625, -1},
    {"Сломанный щиток в подъезде №3", 1.0,                      559.875244,27.876850,1049.265625, -1},
    {"Сломанный щиток в подъезде №4", 1.0,                      559.875244,27.876850,1049.265625, -1},
    {"Неисправность в зарядной станции Tesla №1", 1.3,          -2536.122802,-658.716003,29.775791, -1},
    {"Неисправность в зарядной станции Tesla №2", 1.3,          1054.243530,-779.238525,41.320312, -1},
    {"Неисправность в зарядной станции Tesla №3", 1.3,          2239.327880,-733.792724,13.573974, -1},
    {"Сломанный щиток в Лыткаринском Банке", 1.5,               -2345.448974,-29.695926,26.682226, -1},
    {"Сломанный щиток в Торговом центре", 1.5,                  -2391.774414,-6.903286,26.517688, -1},
    {"Сломанный щиток в Больнице", 2.0,                         -236.503936,551.704528,13.089560, -1}
};

public OnPlayerDisconnect(playerid, reason)
{
    Wedding_OnDisconnect(playerid);
    OrdinaryNewElectric(playerid);
    #if defined e_OnPlayerDisconnect
        return e_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect e_OnPlayerDisconnect
#if defined e_OnPlayerDisconnect
    forward e_OnPlayerDisconnect(playerid, reason);
#endif

public OnPlayerConnect(playerid)
{
    OrdinaryNewElectric(playerid);
    #if defined e_OnPlayerConnect
        return e_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect e_OnPlayerConnect
#if defined e_OnPlayerConnect
    forward e_OnPlayerConnect(playerid);
#endif

public OnPlayerSpawn(playerid)
{
    OrdinaryNewElectric(playerid);
    #if defined e_OnPlayerSpawn
        return e_OnPlayerSpawn(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn e_OnPlayerSpawn
#if defined e_OnPlayerSpawn
    forward e_OnPlayerSpawn(playerid);
#endif

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 3244)
    {
        if(response)
        {
            if(GetPlayerMoneyEx(playerid) >= 1000)
            {
                player_arenda_electric[playerid] = CreateVehicle(428, -2570.248291,-452.710601,27.108392,179.166900,  0, 0, 0);

                PutPlayerInVehicle(playerid, player_arenda_electric[playerid], 0);

                GivePlayerMoneyEx(playerid, -1000);

                SendClientMessage(playerid, -1, ""SC" Вы успешно арендовали транспорт. Чтобы взять заказ: {FFFF00}/eorders");

            }
            else SendClientMessage(playerid, -1, ""USC" У вас нехватает денег.");
        }
    }
    if(dialogid == 3245)
    {
        if(response)
        {
            if(GetPlayerSkin(playerid) == 206)
            {
                SetPlayerSkinInit(playerid);
                SendClientMessage(playerid, -1, ""SC" Вы успешно переоделись обратно в свою одежду");
            }
            else
            {
                SetPlayerSkin(playerid, 206);
                SendClientMessage(playerid, -1, ""SC" Вы успешно переоделись в рабочую одежду");
                EnablePlayerGPS(playerid, 55, -2548.372802,-442.577972,27.999729, "");
                SendClientMessage(playerid, -1, "{00FF00}|{FFFFFF} Отлично! Теперь арендуйте транспорт для перемещения по заказам");
            }
        }
    }
    if(dialogid == 3246)
    {
        if(response)
        {
            if(!player_electric[playerid])
            {
                SendClientMessage(playerid, -1, ""USC" Вы успешно устроились на работу электрика");
                EnablePlayerGPS(playerid, 55, -2465.773925,352.950286,1501.085937, "");
                SendClientMessage(playerid, -1, "{00FF00}|{FFFFFF} Отлично! Теперь переоденьтесь в рабочую форму");
                player_electric[playerid] = true;
            }
            else
            {
                SendClientMessage(playerid, -1, ""USC" Вы успешно уволились с работы электрика");
                OrdinaryNewElectric(playerid);

                if(GetPlayerSkin(playerid) == 206)
                {
                    SetPlayerSkinInit(playerid);
                    SendClientMessage(playerid, -1, ""SC" Вы успешно переоделись обратно в свою одежду");
                }
            }
        }
    }
    if(dialogid == 3247)
    {
        if(response)
        {
            if(!GetPVarInt(playerid, "stage_dialog_wire"))
            {
                new wire[16];

                switch(GetPVarInt(playerid, "color_wire"))
                {
                    case 0: wire = "{FF0000}Красный";
                    case 1: wire = "{0004FF}Синий";
                    case 2: wire = "{00FF00}Зеленый";
                }

                SetPVarInt(playerid, "stage_dialog_wire", 1);

                Dialog
                (
                    playerid, 3247, DIALOG_STYLE_LIST, 
                    "Выберите неисправный провод",
                    "{FF0000}Красный\n"\
                    "{0004FF}Синий\n"\
                    "{00FF00}Зеленый",
                    "Выбрать", ""
                );
            }
            else
            {
                DeletePVar(playerid, "stage_dialog_wire");

                new wire = GetPVarInt(playerid, "color_wire");

                if(GetPVarInt(playerid, "color_wire") != listitem)
                {
                    SendClientMessage(playerid, -1, ""USC" Вы выбрали не правильный провод!");

                    SendClientMessage(playerid, -1, ""USC" Заказ провален. Взять новый заказ: {FFFF00}/eorders");

                    if(GetPlayerMoneyEx(playerid) >= 2500)
                    {
                        SendClientMessage(playerid, -1, ""USC" Штраф составляет 2500 рублей");
                        GivePlayerMoneyEx(playerid, -2500);
                    }
                }
                else
                {
                    new text[148];

                    SendClientMessage(playerid, -1, "{00FF00}|{FFFFFF} Вы выбрали правильный провод!");

                    SendClientMessage(playerid, -1, ""SC" Заказ выполнен. Взять новый заказ: {FFFF00}/eorders");

                    format(text, sizeof text, ""SC" За успешно выполненный заказ вы получили {FFFF00}%d {FFFFFF}рублей", player_salary_electric[playerid]);
                    GivePlayerMoneyEx(playerid, player_salary_electric[playerid]);
                }

                player_orders_electric[playerid] = -1;

                DeletePVar(playerid, "color_wire");

            }
        }
    }
    #if defined e_OnDialogResponse
return e_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse e_OnDialogResponse
#if defined e_OnDialogResponse
forward e_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif


public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(areaid == sphere_enter_for_electric)
    {
        SetPlayerPosEx(playerid, -2477.525390,353.286193,1501.085937, 264.647674, 1, 1);
    }
    if(areaid == sphere_exit_for_electric)
    {
        SetPlayerPosEx(playerid, -2541.825683,-424.392333,28.291095, 267.011932, 0, 0);
    }
    if(areaid == sphere_arenda_electric)
    {
        if(player_electric[playerid])
        {
            Dialog
            (
                playerid, 3244, DIALOG_STYLE_MSGBOX, 
                "Электрик | Аренда рабочего транспорта",
                "Вы действительно хотите арендовать рабочий транспорт\n"\
                "Стоимость аренды транспорта: {FFFF00}1000 {FFFFFF}рублей",
                "Далее", "Назад"
            );
        }
    }
    if(areaid == sphere_razdew_electric)
    {
        if(player_electric[playerid])
        {
            Dialog
            (
                playerid, 3245, DIALOG_STYLE_MSGBOX, 
                "Электрик | Раздевалка",
                "Вы действительно хотите переодеться в рабочую форму",
                "Далее", "Назад"
            );
        }
    }
    if(areaid == sphere_menu_electric)
    {
        if(GetPlayerLevel(playerid) >= 7)
        {
            if(!player_electric[playerid])
            {
                Dialog
                (
                    playerid, 3246, DIALOG_STYLE_MSGBOX, 
                    "Электрик | Устройство на работу",
                    "Вы действительно хотите устроиться на работу электрика",
                    "Далее", "Назад"
                );
            }
            else
            {
                Dialog
                (
                    playerid, 3246, DIALOG_STYLE_MSGBOX, 
                    "Электрик | Увольнение с работы",
                    "Вы действительно хотите уволиться с работы электрика",
                    "Далее", "Назад"
                );
            }
        }
        else SendClientMessage(playerid, -1, ""USC" Работа электрика с 7 уровня");
    }
    if(orders_electric[0][E_SPHERE] <= areaid <= orders_electric[sizeof orders_electric - 1][E_SPHERE])
    {
        if(player_electric[playerid])
        {
            if(player_orders_electric[playerid] == -1) return SendClientMessage(playerid, -1, ""USC" Сначало возьмите заказ");

            new orders = IsPlayerInOrdersElectric(playerid);

            if(player_orders_electric[playerid] == orders || 0 <= player_orders_electric[playerid] <= 3)
            {
                if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, ""USC" Выйдите из транспорта");

                ApplyAnimationEx(playerid, "INT_SHOP","shop_shelf", 3.1, 1, 1, 1, 0, 0, 0, USE_ANIM_TYPE_NONE - 1);
                SetTimerEx("NextStageElectric", 5000, false, "i", playerid);
            }
            else SendClientMessage(playerid, -1, ""USC" Это не ваш заказ");
        }
    }
    #if defined e_OnPlayerEnterDynamicArea
        return e_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
    #else
        return 0;
    #endif
}
   #if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea e_OnPlayerEnterDynamicArea
#if defined e_OnPlayerEnterDynamicArea
    forward e_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
#endif


public OnGameModeInit()
{
    print("[W_SYSTEN] Работа электрика загружена.");
    CreateElectric();
    #if defined e_OnGameModeInit
        return e_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit e_OnGameModeInit
#if defined e_OnGameModeInit
    forward e_OnGameModeInit();
#endif

stock CreateElectric()
{
    print("telegram: @welsistudio");

    for(new e;e < sizeof orders_electric;e++)
    {
        orders_electric[e][E_SPHERE] = CreateDynamicSphere(orders_electric[e][E_X], orders_electric[e][E_Y], orders_electric[e][E_Z], 1.5, -1, -1);

        if(orders_electric[e][E_MULTIPLIER] == 1.3) Create3DTextLabel("{FFFF00}Зарядная станция", -1, orders_electric[e][E_X], orders_electric[e][E_Y], orders_electric[e][E_Z], 10.0, 0);
        
    }

    CreateActorEx("{FFFF00}Начальник\n\n{818181}[Работа электрика]", "", 84, -2477.608886,361.562500,1501.085937,264.647674, 1, 1);
    sphere_menu_electric = CreateDynamicSphere(-2477.608886,361.562500,1501.085937, 3.0, 1, 1);

    CreateDynamicPickup(19131, 23, -2548.372802,-442.577972,27.999729, 0, 0);
    sphere_arenda_electric = CreateDynamicSphere(-2548.372802,-442.577972,27.999729, 3.0, 0, 0);
    Create3DTextLabel("{FFFF00}Аренда транспорта\n\n{818181}[Работа электрика]", -1, -2548.372802,-442.577972,27.999729, 10.0, 0);

    CreateDynamicPickup(1275, 23, -2465.773925,352.950286,1501.085937, 1, 1);
    sphere_razdew_electric = CreateDynamicSphere(-2465.773925,352.950286,1501.085937, 3.0, 1, 1);
    Create3DTextLabel("{FFFF00}Раздевалка\n\n{818181}[Работа электрика]", -1, -2465.773925,352.950286,1501.085937, 10.0, 1);    

    sphere_enter_for_electric = CreateDynamicSphere(-2542.872558,-424.708251,28.280979, 1.0, 0, 0);
    Create3DTextLabel("{FFFF00}Вход\n\n{818181}[Работа электрика]", -1, -2542.872558,-424.708251,28.280979, 10.0, 0);
    sphere_exit_for_electric =  CreateDynamicSphere(-2479.000732,352.865173,1501.085937, 1.0, 1, 1); 
    CreateDynamicPickup(19134, 23, -2542.872558,-424.708251,28.280979, 0, 0);
    CreateDynamicPickup(19134, 23, -2479.000732,352.865173,1501.085937, 1, 1);
}

CMD:eorders(playerid)
{
    if(!player_electric[playerid]) return 1;

    if(player_orders_electric[playerid] != -1) return SendClientMessage(playerid, -1, "Сначало выполните предыдущий заказ");

    if(GetPlayerSkin(playerid) != 206) return SendClientMessage(playerid, -1, ""USC" Переоденьтесь в рабочую форму чтобы взять заказ");

    if(player_arenda_electric[playerid] == -1) return SendClientMessage(playerid, -1, ""USC" Сначало арендуйте рабочий транспорт");

    if(GetPlayerVehicleID(playerid) != player_arenda_electric[playerid]) return SendClientMessage(playerid, -1, ""USC" Вы должны находиться в рабочим транспорте");

    player_orders_electric[playerid] = random(10);

    new p = player_orders_electric[playerid], text[114];

    new Float:dist = GetPlayerDistanceFromPoint(playerid, orders_electric[p][E_X], orders_electric[p][E_Y], orders_electric[p][E_Z]);

    new Float:salary = orders_electric[player_orders_electric[playerid]][E_MULTIPLIER] * (floatround(dist) * 3) + random(2500);
    player_salary_electric[playerid] = floatround(salary);
    
    format(text, sizeof text, "Ваш заказ: {FFFF00}%s. {FFFFFF}Зарплата: {FFFF00}%d", orders_electric[p][E_NAME], player_salary_electric[playerid]);

    SendClientMessage(playerid, -1, text);

    if(0 <= p <= 3)
    {
        EnablePlayerGPS(playerid, 55, coord_houses_electric[p][0], coord_houses_electric[p][1], coord_houses_electric[p][2], "На карте отмечен ваш заказ");
    }
    else EnablePlayerGPS(playerid, 55, orders_electric[p][E_X], orders_electric[p][E_Y], orders_electric[p][E_Z], "На карте отмечен ваш заказ");

    return 1;
}

stock IsPlayerInOrdersElectric(playerid)
{
	for(new p; p < sizeof orders_electric; p ++)
	{
		if(IsPlayerInDynamicArea(playerid, orders_electric[p][E_SPHERE])) return p;
	}

	return -1;
}

stock OrdinaryNewElectric(playerid)
{
    if(player_arenda_electric[playerid] != -1) DestroyVehicle(player_arenda_electric[playerid]);

    player_arenda_electric[playerid] = -1;

    player_electric[playerid] = false;
    player_salary_electric[playerid] = 0;
    player_orders_electric[playerid] = -1;
    
    if(GetPVarInt(playerid, "color_wire")) DeletePVar(playerid, "color_wire");

    return 1;
}

public:NextStageElectric(playerid)
{
    ClearAnimations(playerid);

    new r = random(3), wire[16], text[184];

    switch(r)
    {
        case 0: wire = "{FF0000}Красный";
        case 1: wire = "{0004FF}Синий";
        case 2: wire = "{00FF00}Зеленый";
    }

    SetPVarInt(playerid, "color_wire", r);

    format(text, sizeof text, "В последствии изучения проблемы:\nвы поняли что неисправен %s {FFFFFF}провод", wire);

    Dialog
    (
        playerid, 3247, DIALOG_STYLE_MSGBOX, 
        "Элетрик | Информация о щитке",
        text,
        "Далее", ""
    );

}
