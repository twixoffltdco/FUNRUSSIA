new player_vehicle_carshare[MAX_PLAYERS];
new player_timer_carshare[MAX_PLAYERS];
#define MAX_CARSHARE    50

new const vehicle_carshare[MAX_CARSHARE] = 
{
    546,516,467,527,445,477,589,587,436,560,565,550,523,463,461,401,404,479,
    412,439,458,491,492,585,496,489,480,543,558,503,505,400,495,502,405,402,410,
    475,506,604,490,533,429,494,466,451,579,411,541,415
};

new Float:coord_carshare_spawn[39][4] =
{
    {1790.770874,2496.592773,13.699392,303.788},
    {1870.207275,2239.963867,14.428012,82.2372},
    {1923.499511,2034.484863,15.040723,180.810},
    {1992.566650,1597.451904,14.800248,183.687},
    {1884.871948,1430.360473,9.085097,184.1231},
    {1759.549926,1317.526855,8.970207,87.31928},
    {2508.680908,-740.481811,11.344062,178.062},
    {2478.394531,-217.063690,1.391940,278.6309},
    {1647.153198,-582.393310,39.288024,358.444},
    {1042.027465,-772.444702,40.295421,196.139},
    {703.357116,-1158.566284,40.131732,87.2845},
    {643.286010,-1347.118774,40.142501,98.7401},
    {-532.781921,-1724.039794,39.878669,149.82},
    {-748.250122,-1733.059326,38.430412,59.865},
    {-1027.571899,232.406005,23.995771,204.982},
    {-1788.529174,778.625488,34.739345,268.136},
    {-2347.369140,-19.168188,25.633939,183.135},
    {-2552.128662,-274.757080,26.425085,0.2818},
    {-2632.363281,2194.656494,52.164409,180.27},
    {-2393.377441,2675.691162,37.567836,173.97},
    {-1492.116577,1629.749511,35.546630,0.3961},
    {-1535.464233,1693.191894,35.740108,89.182},
    {-25.757070,905.758300,11.175165,70.785049},
    {-315.747741,841.021362,12.234659,279.0840},
    {876.620971,851.433959,12.629769,153.35745},
    {554.745727,1092.270751,11.701558,252.3124},
    {42.042980,1191.196655,11.179736,285.47143},
    {123.564216,1578.336547,11.167082,58.20625},
    {1325.734252,2280.020507,16.676370,93.8828},
    {8.622725,2521.187744,10.048373,182.170745},
    {-1864.743774,-2267.511718,6.661220,50.705},
    {-1574.654052,-2635.123535,4.618018,246.44},
    {2224.798339,-2319.630126,20.914402,88.120},
    {1926.114624,-2233.912353,10.422215,356.64},
    {2410.509765,-2087.451904,21.045942,179.77},
    {2567.386718,-2173.074218,21.145484,185.33},
    {2584.434570,-1811.424560,21.055377,181.51},
    {2758.627441,-2418.819091,20.846084,326.51},
    {2776.829101,778.938720,30.150285,120.1565}
};

public OnPlayerConnect(playerid)
{
    player_timer_carshare[playerid] = -1;
    player_vehicle_carshare[playerid] = -1;
    #if defined car_OnPlayerConnect
        return car_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect car_OnPlayerConnect
#if defined car_OnPlayerConnect
    forward car_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
    if(player_vehicle_carshare[playerid] != -1) DeleteCarShareVehicle(playerid);
    #if defined car_OnPlayerDisconnect
        return car_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect car_OnPlayerDisconnect
#if defined car_OnPlayerDisconnect
    forward car_OnPlayerDisconnect(playerid, reason);
#endif

public OnGameModeInit()
{
    print("[KRANIN_SYSTEM] Система каршеринга загружена.");
    #if defined car_OnGameModeInit
        return car_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit car_OnGameModeInit
#if defined car_OnGameModeInit
    forward car_OnGameModeInit();
#endif

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 2310)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    DeleteCarShareVehicle(playerid);
                    SendClientMessage(playerid, -1, "{FFFF00}Вы успешно прекратили аренду транспорта. Возвращайтесь ещё!");
                }
            }
        }
    }
    if(dialogid == 2311)
    {
        if(response)
        {
            if(listitem == 10 || listitem == 11)
            {
                if(listitem == 10) SetPVarInt(playerid, "count_list_carshare", GetPVarInt(playerid, "count_list_carshare")+1);
                else if(listitem == 11) SetPVarInt(playerid, "count_list_carshare", GetPVarInt(playerid, "count_list_carshare")-1);

                new list = GetPVarInt(playerid, "count_list_carshare");

                new count = list*10;

                new price, text[128], dialog[sizeof text*10+50] = "{FFFFFF}№\t{FFFFFF}Название\t{FFFFFF}Цена\n";

                for(new i = count-10, c = -1;i < count;i++)
                {
                    c++;
                    price = floatround(GetVehicleInfo(vehicle_carshare[i]-400, VI_PRICE) * 0.01 / 100);

                    format(text, sizeof text, "{FFFFFF}№%d\t{FFFFFF}%s\t{FFFFFF}%d р./мин.\n", i+1, GetVehicleInfo(vehicle_carshare[i]-400, VI_NAME), price);
                    strcat(dialog, text);
                    SetPlayerListitemValue(playerid, c, i);
                }
                
                if(list != 50) strcat(dialog, "{FFFFFF}Следующая страница\n");

                if(list >= 2) strcat(dialog, "{FFFFFF}Предыдущая страница\n");

                DialogCarShare(playerid, 2311, DIALOG_STYLE_TABLIST_HEADERS, "Каршеринг", dialog, "Далее", "Назад");

            }
            else
            {
                new id = GetPlayerListitemValue(playerid, listitem);

                new price = floatround(GetVehicleInfo(vehicle_carshare[id]-400, VI_PRICE) * 0.01 / 100); 

                new string[84], text[124];
                format
                (
                    string, sizeof string,
                    "%s | %d р. / 1 мин.",
                    GetVehicleInfo(vehicle_carshare[id]-400, VI_NAME), price
                );

                format
                (
                    text, sizeof text,
                    "5 минут - %d рублей\n"\
                    "10 минут - %d рублей\n"\
                    "15 минут - %d рублей\n"\
                    "30 минут - %d рублей\n"\
                    "60 минут - %d рублей\n",
                    price*5,price*10,price*15,price*30,price*60
                );

                Dialog(playerid, 2313, DIALOG_STYLE_LIST, string, text, "Далее", "Назад");

                SetPVarInt(playerid, "car_share", id);
            }
        }
    }
    if(dialogid == 2313)
    {
        if(response)
        {
            new time_munite;

            switch(listitem+1)
            {
                case 1:time_munite = 5;
                case 2:time_munite = 10;
                case 3:time_munite = 15;
                case 4:time_munite = 30;
                case 5:time_munite = 60;
            }

            new time_second = time_munite*60;

            new id = GetPVarInt(playerid, "car_share"), text[184];

            new price = floatround(GetVehicleInfo(vehicle_carshare[id]-400, VI_PRICE) * 0.01 / 100)*time_munite;

            if(GetPlayerMoneyEx(playerid) >= price)
            {
                GivePlayerMoneyEx(playerid, -price);
                format(text, sizeof text, "Вы успешно оплатили аренду {FFFF00}%s {FFFFFF}на {FFFF00}%d{FFFFFF} минут за{FFFF00} %d {FFFFFF}рублей.", 
                GetVehicleInfo(vehicle_carshare[id]-400, VI_NAME), time_munite, price);

                SendClientMessage(playerid, -1, text);
                GivePlayerMoneyEx(playerid, -price);
            }
            else
            {
                SendClientMessage(playerid, -1, "У вас нехватает денег чтобы арендовать этот транспорт.");
                return 1;
            }


            player_timer_carshare[playerid] = SetTimerEx("CarShare", time_second*1000, false, "i", playerid);

            new id_coord, Float:distance, Float:old_distance = GetPlayerDistanceFromPoint(playerid, coord_carshare_spawn[0][0],coord_carshare_spawn[0][1],coord_carshare_spawn[0][2]);

            for(new i; i < sizeof coord_carshare_spawn;i++)
            {
                distance = GetPlayerDistanceFromPoint(playerid, coord_carshare_spawn[i][0], coord_carshare_spawn[i][1], coord_carshare_spawn[i][2]);

                if(old_distance >= distance)
                {
                    old_distance = distance;
                    id_coord = i; 
                }
            }

            new Float:x = coord_carshare_spawn[id_coord][0],
            Float:y = coord_carshare_spawn[id_coord][1],
            Float:z = coord_carshare_spawn[id_coord][2],
            Float:a = coord_carshare_spawn[id_coord][3];

            player_vehicle_carshare[playerid] = CreateVehicle(vehicle_carshare[id], x, y, z, a, 0, 0, -1, 0);

            new info[124];
            format(info, sizeof info, "Арендный Транспорт\n{FFFFFF}%s\n{2BB1FF}Арендодатель:{FFFFFF} %s", GetVehicleInfo(vehicle_carshare[id]-400, VI_NAME), GetPlayerNameEx(playerid));
            CreateVehicleLabel(player_vehicle_carshare[playerid], info, 0x2BB1FFFF, x, y, z, 5.0);
            EnablePlayerGPS(playerid, 1, x, y, z, "Местоположение транспорта отмечено на карте.");
        }
    }
    if(dialogid == 2312)
    {
        if(response)
        {
            new time_munite;
            switch(listitem+1)
            {
                case 1:time_munite = 5;
                case 2:time_munite = 10;
                case 3:time_munite = 15;
                case 4:time_munite = 30;
                case 5:time_munite = 60;
            }
            
            new id = GetPVarInt(playerid, "car_share"), text[184];
            new price = floatround(GetVehicleInfo(vehicle_carshare[id]-400, VI_PRICE) * 0.01 / 100)*time_munite;

            if(GetPlayerMoneyEx(playerid) >= price)
            {
                GivePlayerMoneyEx(playerid, -price);
                format(text, sizeof text, "Вы успешно оплатили аренду {FFFF00}%s {FFFFFF}на {FFFF00}%d{FFFFFF} минут за{FFFF00} %d {FFFFFF}рублей.", 
                GetVehicleInfo(vehicle_carshare[id]-400, VI_NAME), time_munite, price);

                SendClientMessage(playerid, -1, text);
                GivePlayerMoneyEx(playerid, -price);
            }
            else
            {
                SendClientMessage(playerid, -1, "У вас нехватает денег чтобы арендовать этот транспорт.");
                DeleteCarShareVehicle(playerid);
                return 1;
            }

            new time_second = time_munite*60;

            player_timer_carshare[playerid] = SetTimerEx("CarShare", time_second*1000, false, "i", playerid);
        }
        else DeleteCarShareVehicle(playerid);
    }
    #if defined car_OnDialogResponse
return car_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse car_OnDialogResponse
#if defined car_OnDialogResponse
forward car_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

CMD:arendacar(playerid)
{
    if(player_timer_carshare[playerid] != -1 && player_vehicle_carshare[playerid] != -1)
    {
        Dialog
        (
            playerid, 2310, DIALOG_STYLE_LIST,
            "Каршеринг",
            "Прекратить аренду транспорта",
            "Далее", "Назад"
        );
    }
    else
    {
        new price, text[128], dialog[sizeof text*10 +50] = "{FFFFFF}№\t{FFFFFF}Название\t{FFFFFF}Цена\n";

        for(new i;i < 10;i++)
        {
            price = floatround(GetVehicleInfo(vehicle_carshare[i]-400, VI_PRICE) * 0.01 / 100);

            format(text, sizeof text, "{FFFFFF}№%d\t{FFFFFF}%s\t{FFFFFF}%d р./мин\n", i+1, GetVehicleInfo(vehicle_carshare[i]-400, VI_NAME), price);
            strcat(dialog, text);
            SetPlayerListitemValue(playerid, i, i);
        }

        strcat(dialog, "{FFFFFF}Следующая страница\n");

        SetPVarInt(playerid, "count_list_carshare", 1);

        DialogCarShare(playerid, 2311, DIALOG_STYLE_TABLIST_HEADERS, "Каршеринг", dialog, "Далее", "Назад");
    }
}

stock DialogCarShare(playerid, dialogid, style, title[], text[], button[], button2[])
{
  if(style == 5)
  {
     ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, "...", "...", "...", ""); 
  }
  ShowPlayerDialog(playerid, dialogid, style, title, text, button, button2);
  return 1;
}

public:CarShare(playerid)
{
    if(player_vehicle_carshare[playerid] == -1 || player_timer_carshare[playerid] == -1) return 1;

    SendClientMessage(playerid, -1, "{FFFF00}Срок аренды транспорта подошел к концу.");

    Dialog
    (
        playerid, 2312, DIALOG_STYLE_LIST,
        "Каршеринг",
        "Продлить на 5 минут\n"\
        "Продлить на 10 минут\n"\
        "Продлить на 15 минут\n"\
        "Продлить на 30 минут\n"\
        "Продлить на 60 минут",
        "Далее", "Назад"
    );

    KillTimer(player_timer_carshare[playerid]);
    return 1;
}

stock DeleteCarShareVehicle(playerid)
{
    DestroyVehicleLabel(player_vehicle_carshare[playerid]);
    DestroyVehicle(player_vehicle_carshare[playerid]);
    KillTimer(player_timer_carshare[playerid]);
    player_vehicle_carshare[playerid] = -1;
    player_timer_carshare[playerid] = -1;

    return 1;
}
