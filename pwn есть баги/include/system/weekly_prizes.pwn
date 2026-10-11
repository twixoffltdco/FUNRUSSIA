enum Weekly_Prizes
{
    WP_Name[24],
    WP_Type,
    WP_Index

}

#define WP_RUB  1
#define WP_MONEY   2
#define WP_VIP 3
#define WP_SLOT 4

new weekly_prizes[7][Weekly_Prizes] =
{
    {"100 доната-руб.", WP_RUB, 100},
    {"500000 руб.", WP_MONEY, 500000},
    {"150 доната-руб.", WP_RUB, 150},
    {"VIP подписка (3 дня.)", WP_VIP, 3},
    {"30000000 руб.", WP_MONEY, 30000000},
    {"500 доната-руб.", WP_RUB, 500},
    {"3 слот на машину", WP_SLOT, 3}
};


#define STATUS_WP_WAITING   0
#define STATUS_WP_MAYBE     1
#define STATUS_WP_TOOK_IT   2

new player_wp[MAX_PLAYERS][8]; // 7 (8) - используется чтобы знать получил ли игрок награду сегодня

public:CREATE_ACCOUNTS_TABLE_WP()
{
    mysql_query(mysql, "SELECT * FROM accounts WHERE weekly_prizes AND weekly_day", false);

    if(mysql_errno())
    {
        mysql_query(mysql, "ALTER TABLE `accounts` ADD `weekly_prizes` TEXT NOT NULL DEFAULT '0,0,0,0,0,0,0' AFTER `level`, ADD `weekly_day` INT NOT NULL DEFAULT '0' AFTER `weekly_prizes`", false);
        
        if(!mysql_errno()) print("[KRANIN_SYSTEM] Столбцы созданы для еженедельных наград");
    }

    return 1;
}

public:LoadWeeklyPrizes(playerid)
{
    new string[84];

    mysql_format(mysql, string, sizeof string, "SELECT weekly_prizes, weekly_day FROM accounts WHERE id = %d", GetPlayerAccountID(playerid));
    new Cache:cache = mysql_query(mysql, string);

    if(!mysql_errno())
    {
        new weekly[48];

        cache_get_row(0,0,weekly);

        sscanf(weekly, "P<,>a<i>[48]", player_wp[playerid]);

        player_wp[playerid][7] = cache_get_row_int(0, 1);

       // printf("weekly");
    }

    cache_delete(cache);

    return 1;
}

public:UnLoadWeeklyPrizes(playerid)
{
    new string[48];

    format(string, sizeof string, "%d,%d,%d,%d,%d,%d,%d", 
    player_wp[playerid][0],
    player_wp[playerid][1],
    player_wp[playerid][2],
    player_wp[playerid][3],
    player_wp[playerid][4],
    player_wp[playerid][5],
    player_wp[playerid][6]);

    new query[184];

    mysql_format(mysql, query, sizeof query, "UPDATE accounts SET weekly_prizes = '%s', weekly_day = %d WHERE id=%d", string, player_wp[playerid][7], GetPlayerAccountID(playerid));
    mysql_query(mysql, query, false);
    
    //if(!mysql_errno()) printf("weekly update");

    return 1;
}



public OnPlayerConnect(playerid)
{
    SetTimerEx("LoadWeeklyPrizes", 2000, false, "i", playerid);
    #if defined weekly_OnPlayerConnect
        return weekly_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect weekly_OnPlayerConnect
#if defined weekly_OnPlayerConnect
    forward weekly_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
    UnLoadWeeklyPrizes(playerid);
    #if defined weekly_OnPlayerDisconnect
        return weekly_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect weekly_OnPlayerDisconnect
#if defined weekly_OnPlayerDisconnect
    forward weekly_OnPlayerDisconnect(playerid, reason);
#endif

public OnGameModeInit()
{
    SetTimer("CREATE_ACCOUNTS_TABLE_WP", 3000, false);

    print("[KRANIN_SYSTEM] Система еженедельных наград загружена.");

    #if defined weekly_OnGameModeInit
        return weekly_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit weekly_OnGameModeInit
#if defined weekly_OnGameModeInit
    forward weekly_OnGameModeInit();
#endif

public:CheckWeeklyPrizes()
{
    new year, month, day, hour, minute;

    getdate(year, month, day);
    gettime(hour, minute);

    new day_weekly = GetDayOfWeek(year, month, day)-1;

    if(!day_weekly && !hour && !minute) mysql_query(mysql, "UPDATE accounts SET weekly_prizes = '0,0,0,0,0,0,0'");
    
    if(!hour && !minute) mysql_query(mysql, "UPDATE accounts SET weekly_day = 0");

    new pday;

    foreach(new i : Player)
    {
        if(player_wp[i][7]) continue;

        pday = -1;
        for(new q;q < 7; q++) if(!player_wp[i][q]) pday = q;

        if(pday == -1) continue;

        if(!player_wp[i][7] && GetPlayerData(i, P_GAME_FOR_DAY) >= 7200)
        {
            SendClientMessage(i, -1, "Поздравляем, вы отыграли 2 часа и можете забрать свою награду! ({FFFF00}/everyprize{FFFFFF})");
            player_wp[i][pday]++;
            player_wp[i][7]++;
            UnLoadWeeklyPrizes(i);
        }
    }

    return 1;
}

cmd:everyprize(playerid)
{
    new dialog[348];

    for(new i, prize[28], list[84]; i < 7;i ++)
    {
        switch(player_wp[playerid][i]) 
        {
            case STATUS_WP_WAITING: format(prize, sizeof prize, "{787878}[Отыграйте 2 часа]");
            case STATUS_WP_MAYBE: format(prize, sizeof prize, "{E6E32C}[Можно получить]");
            case STATUS_WP_TOOK_IT: format(prize, sizeof prize, "{39D055}[Получен]");

        }

        format(list, sizeof list, "%d. %s ? %s\n", i+1, weekly_prizes[i][WP_Name], prize);
        strcat(dialog, list);
    } 

    ShowPlayerDialog(playerid, 3882, DIALOG_STYLE_LIST, "Еженедельные награды", dialog, "Получить", "Выйти");

    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 3882)
    {
        if(response)
        {
            new day = listitem;

            if(day && player_wp[playerid][day] == STATUS_WP_MAYBE && player_wp[playerid][day-1] == STATUS_WP_MAYBE) // status_maybe
                return SendClientMessage(playerid, -1, "{E6E32C}[Еженедельные награды] {FFFFFF}Чтобы получить награду, получите предыдущие");

            if(day && !player_wp[playerid][day] && !player_wp[playerid][day-1])
                return SendClientMessage(playerid, -1, "{E6E32C}[Еженедельные награды] {FFFFFF}Вы сможете получить эту награду только после того, как получите предыдущие");

            if(player_wp[playerid][day] == STATUS_WP_TOOK_IT) return SendClientMessage(playerid, -1, "{E6E32C}[Еженедельные награды] {FFFFFF}Вы уже получали данную награду");

            switch(player_wp[playerid][day])
            {
                case STATUS_WP_WAITING: SendClientMessage(playerid, -1, "{E6E32C}[Еженедельные награды] {FFFFFF}Чтобы получить награду отыграйте 2 часа");
                case STATUS_WP_MAYBE:
                {
                    switch(weekly_prizes[day][WP_Type])
                    {
                        case WP_RUB: GivePlayerDonateRub(playerid, weekly_prizes[day][WP_Index]);
                        case WP_MONEY: GivePlayerMoneyEx(playerid, weekly_prizes[day][WP_Index]);
                        case WP_VIP: {

                            if(!GetPlayerPremium(playerid))
                            {
                                SetPlayerData(playerid, P_PREMIUM, 3);
                                SetPlayerData(playerid, P_PREMIUM_DATE, gettime() +  weekly_prizes[day][WP_Index] * 86400);
                            }
                            else
                            {
                                AddPlayerData(playerid, P_PREMIUM_DATE, +,  weekly_prizes[day][WP_Index] * 86400);
                            }
                            new prem_day,
                            prem_month,
                            prem_year;

                            timestamp_to_date(GetPlayerData(playerid, P_PREMIUM_DATE), prem_year, prem_month, prem_day);

                            UpdatePlayerDatabaseInt(playerid, "premium", 3);
                            UpdatePlayerDatabaseInt(playerid, "premium_date", GetPlayerData(playerid, P_PREMIUM_DATE));
                        }
                        case WP_SLOT: {
                            AddPlayerData(playerid, P_CAR_SLOTS, +, weekly_prizes[day][WP_Index]);
                            UpdatePlayerDatabaseInt(playerid, "car_slots", GetPlayerData(playerid, P_CAR_SLOTS));
                        }
                    }

                    new string[144];
                    format(string, sizeof string, "{E6E32C}[Еженедельные награды] {FFFFFF} Поздравляем! Вы получили {E6E32C}%s{FFFFFF}", weekly_prizes[day][WP_Name]);
                    SendClientMessage(playerid, -1, string);

                    player_wp[playerid][day] = STATUS_WP_TOOK_IT;
                    player_wp[playerid][7] = 1;
                    UnLoadWeeklyPrizes(playerid);
                    
                }
                case STATUS_WP_TOOK_IT: SendClientMessage(playerid, -1, "{E6E32C}[Еженедельные награды] {FFFFFF}Вы уже получили данный приз");
            }
        }
    }
    #if defined weekly_OnDialogResponse
    return weekly_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse weekly_OnDialogResponse
#if defined weekly_OnDialogResponse
forward weekly_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif
