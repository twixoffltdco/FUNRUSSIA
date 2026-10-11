//Рулетка
#define T_NONE		0
#define	T_MONEY		1
#define	T_LIC		2
#define	T_VIP		3
#define	T_CAR		4
#define	T_GUN		5
#define	T_EXP		6
#define	T_DONATE	7
#define	T_SLOT		8

enum R_STRUCT
{
	R_TYPE, 
	R_NAME_TXD[48], 
	R_NAME_TEXT[48],
    R_NAME_PRIZE[48],
	R_COUNT
}

enum WELSI_BLYAT
{
    last_player_name[24],
    id_ruletka_prize
};

new last_player_td[3][4] =
{
    {6,5,7,8},
    {11,9,10,12},
    {15,13,14,16}
};

new last_player_ruletka[3][WELSI_BLYAT] =
{
    {"Nick_Name", 0},
    {"Nick_Name", 0},
    {"Nick_Name", 0}
};

new ruletka_prize[12][R_STRUCT] =//раставлено в порядке:чем меньше [] тем реже
{
    {T_CAR, "txd:brgiftsuncar", 	"Toyota_Mark_2", "Toyota Mark II",		547},
	{T_CAR, "txd:brgiftsuncar", 	"Ford_Mustang", "Ford Mustang GT",			603},
	{T_DONATE, "txd:brgiftsdonate", 		"до_150_донат-руб.", "до 150 донат-руб", 150},
    {T_MONEY, "txd:brgiftscash", 	"љo_500000_p.", "до 500000 рублей",		500000},
	{T_SLOT, "txd:brgiftsfreeslot", 		"Слот_для_транспорта", 	"Слот для транспорта",	1},
    {T_VIP, "txd:brgiftsgvip", 		"Gold-Vip", "GOLD-VIP на 15 дней",			3},
    {T_LIC, "txd:brgiftslic", 		"ЊaЈka_c_ћњ e®џњ¬Їњ", 	"Пакет с лицензиями",	1},
    {T_MONEY, "txd:brgiftscash", 	"љo_100000_p.",  "до 100000 рублей",	100000},
    {T_GUN, "txd:brgiftsgun", 		"Cћy¤aќ®oe_opy›њe", 	"Случайное оружие",	25},
    {T_EXP, "txd:brgiftsexp", 	"15_EXP",  "15 EXP", 15},
    {T_EXP, "txd:brgiftsexp", 	"3_EXP",  "3 EXP", 3},
    {T_EXP, "txd:brgiftsexp", 	"1_EXP",  "1 EXP", 1}
};

new player_roulette_bronz[MAX_PLAYERS];
new menu_prize_player[MAX_PLAYERS][5];
new ruletka_count[MAX_PLAYERS];
new bool:animation_player[MAX_PLAYERS];
new timer_player_ruletka[MAX_PLAYERS];
new Text:welsirltk_TD[35];
new PlayerText:ruletka_PTD[MAX_PLAYERS][5]; 
new PlayerText:ruletka_PTD_t[MAX_PLAYERS][18];
public OnGameModeInit()
{
    printf("[KRANIN_SYSTEM] Система рулетки загружена.\n");
    RuletkaMenu();
    LoadPrizeRuletka();
    SetTimer("CreateTablistRoulette", 1500, false);
    #if defined rul_OnGameModeInit
        return rul_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit rul_OnGameModeInit
#if defined rul_OnGameModeInit
    forward rul_OnGameModeInit();
#endif

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 2832)
    {
        if(response)
        {
            if(listitem == 0 || listitem == 1)
            {
                new count_listt = GetPVarInt(playerid, "count_list"), query[94];

                if(!listitem) count_listt++;
                else if(listitem == 1 && count_listt != 1) count_listt--;
                

                mysql_format(mysql, query, sizeof query, "SELECT * FROM roulette_prize WHERE owner = %d", GetPlayerAccountID(playerid));
                new Cache:cache = mysql_query(mysql, query);

                new list_max = count_listt*10, rows, prize_id, id, list[52], dialog[sizeof list*10+54];

                strcat(dialog, "Следующая страница\nПредыдущая страница\n");

                rows = cache_num_rows();

                if(rows >= list_max) rows = list_max;

                for(new i = list_max - 10, c=2;i < rows;i++, c++)
                {
                    prize_id = cache_get_field_content_int(i, "prize");
                    id = cache_get_field_content_int(i, "id");

                    format(list, sizeof list, "%d. %s\n", i+1, ruletka_prize[prize_id][R_NAME_PRIZE]);
                    strcat(dialog, list);
                    SetPlayerListitemValue(playerid, c, prize_id);
                    format(list, sizeof list, "rouletteid_%d", c);
                    SetPVarInt(playerid, list, id);
                }

                cache_delete(cache);
                SetPVarInt(playerid, "count_list", count_listt);
                Dialog(playerid, 2832, DIALOG_STYLE_LIST, "{FF0000}Призы с рулетки", dialog, "Далее", "Выйти");
                return 1;
            }

            new id = GetPlayerListitemValue(playerid, listitem), text[134],count;

            format(text, sizeof text, "");

            switch(id)
            {
                case 0,1:
                {
                    if(GetPlayerOwnableCar(playerid) != INVALID_VEHICLE_ID)
                    return SendClientMessage(playerid, -1, "Выгрузите транспорт");
                    GivePlayerCarRoulette(playerid, ruletka_prize[id][R_COUNT], 0, 0);

                    format(text, sizeof text, "Вы забрали %s с призов. Поздравляем!",  ruletka_prize[id][R_NAME_PRIZE]);
                }
                case 2:
                {
                    count = random(150)+1;

                    GivePlayerDonateRub(playerid, count);
                    format(text, sizeof text, "Вы забрали %d донат-рублей с призов. Поздравляем!", count);
                }
                case 3,7:
                {
                    count = random(ruletka_prize[id][R_COUNT])+1;

                    GivePlayerMoneyEx(playerid, count);
                    format(text, sizeof text, "Вы забрали %d рублей с призов. Поздравляем!", count);
                }
                case 4:
                {
                    AddPlayerData(playerid, P_CAR_SLOTS, +, 1);
                    UpdatePlayerDatabaseInt(playerid, "car_slots", GetPlayerData(playerid, P_CAR_SLOTS));

                    format(text, sizeof text, "Вы забрали %s с призов. Поздравляем!", ruletka_prize[id][R_NAME_PRIZE]);
                }
                case 5:
                {
                    new prem_day,prem_month,prem_year,premium = GetPlayerPremium(playerid);
                    if(!premium)
                    {
                        AddPlayerData(playerid, P_CAR_SLOTS, +, 2);
                        SetPlayerData(playerid, P_PREMIUM, 3);
                        SetPlayerData(playerid, P_PREMIUM_DATE, gettime() + 15 * 86400);
                    }
                    else
                    {
                        AddPlayerData(playerid, P_PREMIUM_DATE, +, 15 * 86400);
                    }

                    timestamp_to_date(GetPlayerData(playerid, P_PREMIUM_DATE), prem_year, prem_month, prem_day);

                    format(text, sizeof text, "Вы забрали {FFEE00}VIP Gold{FFFFFF} до {F5D000}%02d.%02d.%d с призов. Поздравляем", prem_day, prem_month, prem_year);

                    UpdatePlayerDatabaseInt(playerid, "premium", 3);
                    UpdatePlayerDatabaseInt(playerid, "premium_date", GetPlayerData(playerid, P_PREMIUM_DATE));
                }
                case 6:
                {
                    SetPlayerData(playerid, P_DRIVING_LIC,	2);
                    SetPlayerData(playerid, P_WEAPON_LIC,	1);

                    UpdatePlayerDatabaseInt(playerid, "driving_lic", 2);
                    UpdatePlayerDatabaseInt(playerid, "weapon_lic", 1); 

                    format(text, sizeof text, "Вы забрали %s с призов. Поздравляем!", ruletka_prize[id][R_NAME_PRIZE]);
                }
                case 8:
                {
                    new gun[7] = {23,24,25,29,30,31,33};

                    GivePlayerWeapon(playerid, gun[random(sizeof gun)], 1000);

                    format(text, sizeof text, "Вы забрали %s с призов. Поздравляем!", ruletka_prize[id][R_NAME_PRIZE]);
                }
                case 9,10,11:
                {
                    AddPlayerData(playerid, P_EXP, +, ruletka_prize[id][R_COUNT]);
				    UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));

                    if(GetPlayerExp(playerid) > GetExpToNextLevel(playerid))
                    {
                        SetPlayerData(playerid, P_EXP, 0);
                        AddPlayerData(playerid, P_LEVEL, +, 1);

                        SetPlayerLevelInit(playerid);
                        SendClientMessage(playerid, -1, "Поздравляем! Ваш уровень повышен");
                    }

                    format(text, sizeof text, "Вы забрали %s с призов. Поздравляем!", ruletka_prize[id][R_NAME_PRIZE]);
                }
            }

            SendClientMessage(playerid, -1, text);

            format(text, sizeof text, "rouletteid_%d", listitem);
            new id_data = GetPVarInt(playerid, text);
            mysql_format(mysql, text, sizeof text, "DELETE FROM roulette_prize WHERE id = %d", id_data);
            mysql_query(mysql, text, false);
            if(mysql_errno()) return SendClientMessage(playerid, -1, "Ошибка в запросе.");
        }
    }
    #if defined name_OnDialogResponse
return name_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse name_OnDialogResponse
#if defined name_OnDialogResponse
forward name_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

public OnPlayerConnect(playerid)
{
    timer_player_ruletka[playerid] = -1;

    SetTimerEx("LoadRuletka", 6000, false, "i", playerid);
    #if defined rul_OnPlayerConnect
        return rul_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect rul_OnPlayerConnect
#if defined rul_OnPlayerConnect
    forward rul_OnPlayerConnect(playerid);
#endif

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == welsirltk_TD[4])
	{
        if(animation_player[playerid]) return SCM(playerid, -1, ""USC"Подождите окончания анимации.");
        if(GetPlayerDonateRub(playerid) >= 50)
        {
            player_roulette_bronz[playerid]++;
            UpdatePlayerDatabaseInt(playerid, "roulette_bronz", player_roulette_bronz[playerid]);
            SendClientMessage(playerid, -1, "Вы купили бронзовую рулетку");
            GivePlayerDonateRub(playerid, -50);
            
            new string[10];
            format(string, sizeof string, "%d", player_roulette_bronz[playerid]);
            PlayerTextDrawSetString(playerid, ruletka_PTD_t[playerid][17], string);
        }
        else SendClientMessage(playerid, -1, "Бронзовая рулетка стоит 50 донат-рублей.");
	}
	if(clickedid == welsirltk_TD[31])
	{
        UpdateLastPlayerRuletka(playerid);
	}
	if(clickedid == welsirltk_TD[33])
	{
        if(player_roulette_bronz[playerid])
        {
            if(timer_player_ruletka[playerid] == -1) 
            {
                if(animation_player[playerid]) return SCM(playerid, -1, ""USC"Подождите окончания анимации.");
                player_roulette_bronz[playerid]--;
                UpdatePlayerDatabaseInt(playerid, "roulette_bronz", player_roulette_bronz[playerid]);
                
                new string[10];
                format(string, sizeof string, "%d", player_roulette_bronz[playerid]);
                PlayerTextDrawSetString(playerid, ruletka_PTD_t[playerid][17], string);

                animation_player[playerid] = true;
                timer_player_ruletka[playerid] = SetTimerEx("RunRuletka", 500, true, "d", playerid);
            }
        }
        else SendClientMessage(playerid, -1, "У вас нет бронзовых рулеток.");
	}
	if(clickedid == welsirltk_TD[32])
	{
		if(animation_player[playerid]) return SCM(playerid, -1, ""USC"Подождите окончания анимации.");

		TogglePlayerControllable(playerid, true);
		ShowHud(playerid);
		for(new t;t < sizeof welsirltk_TD;t++)
		{
			TextDrawHideForPlayer(playerid, welsirltk_TD[t]);
		}

        PlayerTextDrawHide(playerid, ruletka_PTD_t[playerid][17]);

		for(new t;t < 5;t++)
		{
			PlayerTextDrawHide(playerid, ruletka_PTD[playerid][t]);
			PlayerTextDrawHide(playerid, ruletka_PTD_t[playerid][t]);
			menu_prize_player[playerid][t] = -1;
		}

        for(new i; i < 3;i++)
        {
            PlayerTextDrawHide(playerid, ruletka_PTD_t[playerid][last_player_td[i][0]]);
            PlayerTextDrawHide(playerid, ruletka_PTD_t[playerid][last_player_td[i][1]]);
            PlayerTextDrawHide(playerid, ruletka_PTD_t[playerid][last_player_td[i][2]]);
            PlayerTextDrawHide(playerid, ruletka_PTD_t[playerid][last_player_td[i][3]]);
        }

        CancelSelectTextDraw(playerid);
	}
    #if defined rul_OnPlayerClickTextDraw
        return rul_OnPlayerClickTextDraw(playerid, clickedid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerClickTextDraw
    #undef OnPlayerClickTextDraw
#else
    #define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw rul_OnPlayerClickTextDraw
#if defined rul_OnPlayerClickTextDraw
    forward rul_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif


CMD:openroulette(playerid)
{
	TogglePlayerControllable(playerid, false);
	HideHud(playerid);
	RuletkaPlayer(playerid);
    SelectTextDraw(playerid, -1);
	for(new i;i < 20;i++) SendClientMessage(playerid, -1, "");

	for(new t;t < sizeof welsirltk_TD;t++)
	{
		TextDrawShowForPlayer(playerid, welsirltk_TD[t]);
	}

	for(new t,welsi;t < 5;t++, welsi = random(12))
	{
		PlayerTextDrawSetString(playerid, ruletka_PTD[playerid][t], ruletka_prize[welsi][R_NAME_TXD]);
		PlayerTextDrawSetString(playerid, ruletka_PTD_t[playerid][t], ruletka_prize[welsi][R_NAME_TEXT]);
		PlayerTextDrawShow(playerid, ruletka_PTD[playerid][t]);
		PlayerTextDrawShow(playerid, ruletka_PTD_t[playerid][t]);
		menu_prize_player[playerid][t] = welsi;
	}

    UpdateLastPlayerRuletka(playerid);

    for(new i; i < 3;i++)
    {
        PlayerTextDrawShow(playerid, ruletka_PTD_t[playerid][last_player_td[i][0]]);
        PlayerTextDrawShow(playerid, ruletka_PTD_t[playerid][last_player_td[i][1]]);
        PlayerTextDrawShow(playerid, ruletka_PTD_t[playerid][last_player_td[i][2]]);
        PlayerTextDrawShow(playerid, ruletka_PTD_t[playerid][last_player_td[i][3]]);
    }

    new string[10];
    format(string, sizeof string, "%d", player_roulette_bronz[playerid]);
    PlayerTextDrawSetString(playerid, ruletka_PTD_t[playerid][17], string);

    PlayerTextDrawShow(playerid, ruletka_PTD_t[playerid][17]);
    return 1;
}
stock RuletkaMenu()
{
    welsirltk_TD[0] = TextDrawCreate(3.6665, 208.3332, "txd:brgiftsdownpanel"); // пусто
    TextDrawTextSize(welsirltk_TD[0], 624.0000, 209.0000);
    TextDrawAlignment(welsirltk_TD[0], 1);
    TextDrawColor(welsirltk_TD[0], -1);
    TextDrawBackgroundColor(welsirltk_TD[0], 255);
    TextDrawFont(welsirltk_TD[0], 4);
    TextDrawSetProportional(welsirltk_TD[0], 0);
    TextDrawSetShadow(welsirltk_TD[0], 0);

    welsirltk_TD[1] = TextDrawCreate(47.2378, 11.6280, "txd:brgiftsbgspin"); // пусто
    TextDrawTextSize(welsirltk_TD[1], 530.0000, 49.0000);
    TextDrawAlignment(welsirltk_TD[1], 1);
    TextDrawColor(welsirltk_TD[1], -1);
    TextDrawBackgroundColor(welsirltk_TD[1], 255);
    TextDrawFont(welsirltk_TD[1], 4);
    TextDrawSetProportional(welsirltk_TD[1], 0);
    TextDrawSetShadow(welsirltk_TD[1], 0);
    TextDrawSetSelectable(welsirltk_TD[1], true);

    welsirltk_TD[2] = TextDrawCreate(255.0950, 167.3733, "txd:brgiftsdostupno"); // пусто
    TextDrawTextSize(welsirltk_TD[2], 87.0000, 27.0000);
    TextDrawAlignment(welsirltk_TD[2], 1);
    TextDrawColor(welsirltk_TD[2], -1);
    TextDrawBackgroundColor(welsirltk_TD[2], 255);
    TextDrawFont(welsirltk_TD[2], 4);
    TextDrawSetProportional(welsirltk_TD[2], 0);
    TextDrawSetShadow(welsirltk_TD[2], 0);

    welsirltk_TD[4] = TextDrawCreate(114.1427, 66.2651, "txd:brgiftsbuycase"); // пусто
    TextDrawTextSize(welsirltk_TD[4], 105.0000, 70.0000);
    TextDrawAlignment(welsirltk_TD[4], 1);
    TextDrawColor(welsirltk_TD[4], -1);
    TextDrawBackgroundColor(welsirltk_TD[4], 255);
    TextDrawFont(welsirltk_TD[4], 4);
    TextDrawSetProportional(welsirltk_TD[4], 0);
    TextDrawSetShadow(welsirltk_TD[4], 0);
    TextDrawSetSelectable(welsirltk_TD[4], true);

    welsirltk_TD[5] = TextDrawCreate(553.9045, 366.4369, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[5], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[5], 1);
    TextDrawColor(welsirltk_TD[5], -1);
    TextDrawBackgroundColor(welsirltk_TD[5], 255);
    TextDrawFont(welsirltk_TD[5], 4);
    TextDrawSetProportional(welsirltk_TD[5], 0);
    TextDrawSetShadow(welsirltk_TD[5], 0);

    welsirltk_TD[6] = TextDrawCreate(586.6188, 399.6828, "љo_100000_p."); // пусто
    TextDrawLetterSize(welsirltk_TD[6], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[6], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[6], 2);
    TextDrawColor(welsirltk_TD[6], -1);
    TextDrawBackgroundColor(welsirltk_TD[6], 255);
    TextDrawFont(welsirltk_TD[6], 1);
    TextDrawSetProportional(welsirltk_TD[6], 1);
    TextDrawSetShadow(welsirltk_TD[6], 0);

    welsirltk_TD[7] = TextDrawCreate(196.6666, 288.5704, "txd:brgiftbronzatext"); // пусто
    TextDrawTextSize(welsirltk_TD[7], 171.0000, 202.0000);
    TextDrawAlignment(welsirltk_TD[7], 1);
    TextDrawColor(welsirltk_TD[7], -1);
    TextDrawBackgroundColor(welsirltk_TD[7], 255);
    TextDrawFont(welsirltk_TD[7], 4);
    TextDrawSetProportional(welsirltk_TD[7], 0);
    TextDrawSetShadow(welsirltk_TD[7], 0);

    welsirltk_TD[8] = TextDrawCreate(239.3332, 219.0370, "ЂPOH€O‹‘†"); // пусто
    TextDrawLetterSize(welsirltk_TD[8], 0.3193, 1.7368);
    TextDrawTextSize(welsirltk_TD[8], -6.0000, 0.0000);
    TextDrawAlignment(welsirltk_TD[8], 1);
    TextDrawColor(welsirltk_TD[8], -1);
    TextDrawBackgroundColor(welsirltk_TD[8], 255);
    TextDrawFont(welsirltk_TD[8], 2);
    TextDrawSetProportional(welsirltk_TD[8], 1);
    TextDrawSetShadow(welsirltk_TD[8], 0);

    welsirltk_TD[9] = TextDrawCreate(399.5713, 366.8517, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[9], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[9], 1);
    TextDrawColor(welsirltk_TD[9], -1);
    TextDrawBackgroundColor(welsirltk_TD[9], 255);
    TextDrawFont(welsirltk_TD[9], 4);
    TextDrawSetProportional(welsirltk_TD[9], 0);
    TextDrawSetShadow(welsirltk_TD[9], 0);

    welsirltk_TD[10] = TextDrawCreate(433.2857, 400.5124, "љo_100000_p."); // пусто
    TextDrawLetterSize(welsirltk_TD[10], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[10], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[10], 2);
    TextDrawColor(welsirltk_TD[10], -1);
    TextDrawBackgroundColor(welsirltk_TD[10], 255);
    TextDrawFont(welsirltk_TD[10], 1);
    TextDrawSetProportional(welsirltk_TD[10], 1);
    TextDrawSetShadow(welsirltk_TD[10], 0);

    welsirltk_TD[11] = TextDrawCreate(476.2379, 366.4370, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[11], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[11], 1);
    TextDrawColor(welsirltk_TD[11], -1);
    TextDrawBackgroundColor(welsirltk_TD[11], 255);
    TextDrawFont(welsirltk_TD[11], 4);
    TextDrawSetProportional(welsirltk_TD[11], 0);
    TextDrawSetShadow(welsirltk_TD[11], 0);

    welsirltk_TD[12] = TextDrawCreate(509.6188, 400.5125, "љo_100000_p."); // пусто
    TextDrawLetterSize(welsirltk_TD[12], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[12], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[12], 2);
    TextDrawColor(welsirltk_TD[12], -1);
    TextDrawBackgroundColor(welsirltk_TD[12], 255);
    TextDrawFont(welsirltk_TD[12], 1);
    TextDrawSetProportional(welsirltk_TD[12], 1);
    TextDrawSetShadow(welsirltk_TD[12], 0);

    welsirltk_TD[13] = TextDrawCreate(551.9046, 213.7850, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[13], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[13], 1);
    TextDrawColor(welsirltk_TD[13], -1);
    TextDrawBackgroundColor(welsirltk_TD[13], 255);
    TextDrawFont(welsirltk_TD[13], 4);
    TextDrawSetProportional(welsirltk_TD[13], 0);
    TextDrawSetShadow(welsirltk_TD[13], 0);

    welsirltk_TD[14] = TextDrawCreate(585.9521, 247.4457, "љo_100000_p."); // пусто
    TextDrawLetterSize(welsirltk_TD[14], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[14], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[14], 2);
    TextDrawColor(welsirltk_TD[14], -1);
    TextDrawBackgroundColor(welsirltk_TD[14], 255);
    TextDrawFont(welsirltk_TD[14], 1);
    TextDrawSetProportional(welsirltk_TD[14], 1);
    TextDrawSetShadow(welsirltk_TD[14], 0);

    welsirltk_TD[15] = TextDrawCreate(399.2380, 214.1998, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[15], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[15], 1);
    TextDrawColor(welsirltk_TD[15], -1);
    TextDrawBackgroundColor(welsirltk_TD[15], 255);
    TextDrawFont(welsirltk_TD[15], 4);
    TextDrawSetProportional(welsirltk_TD[15], 0);
    TextDrawSetShadow(welsirltk_TD[15], 0);

    welsirltk_TD[16] = TextDrawCreate(432.9524, 247.8605, "љo_100000_p."); // пусто
    
    TextDrawLetterSize(welsirltk_TD[16], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[16], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[16], 2);
    TextDrawColor(welsirltk_TD[16], -1);
    TextDrawBackgroundColor(welsirltk_TD[16], 255);
    TextDrawFont(welsirltk_TD[16], 1);
    TextDrawSetProportional(welsirltk_TD[16], 1);
    TextDrawSetShadow(welsirltk_TD[16], 0);

    welsirltk_TD[17] = TextDrawCreate(475.9046, 213.7850, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[17], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[17], 1);
    TextDrawColor(welsirltk_TD[17], -1);
    TextDrawBackgroundColor(welsirltk_TD[17], 255);
    TextDrawFont(welsirltk_TD[17], 4);
    TextDrawSetProportional(welsirltk_TD[17], 0);
    TextDrawSetShadow(welsirltk_TD[17], 0);

    welsirltk_TD[34] = TextDrawCreate(580.9998, 2.0888, "t.me/prizmamobile"); // пусто
    welsirltk_TD[18] = TextDrawCreate(509.2855, 247.8606, "љo_100000_p."); // пусто
    TextDrawLetterSize(welsirltk_TD[18], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[18], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[18], 2);
    TextDrawColor(welsirltk_TD[18], -1);
    TextDrawBackgroundColor(welsirltk_TD[18], 255);
    TextDrawFont(welsirltk_TD[18], 1);
    TextDrawSetProportional(welsirltk_TD[18], 1);
    TextDrawSetShadow(welsirltk_TD[18], 0);

    welsirltk_TD[19] = TextDrawCreate(551.5712, 264.8072, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[19], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[19], 1);
    TextDrawColor(welsirltk_TD[19], -1);
    TextDrawBackgroundColor(welsirltk_TD[19], 255);
    TextDrawFont(welsirltk_TD[19], 4);
    TextDrawSetProportional(welsirltk_TD[19], 0);
    TextDrawSetShadow(welsirltk_TD[19], 0);

    welsirltk_TD[20] = TextDrawCreate(585.6187, 298.4679, "љo_100000_p."); // пусто
    TextDrawLetterSize(welsirltk_TD[20], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[20], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[20], 2);
    TextDrawColor(welsirltk_TD[20], -1);
    TextDrawBackgroundColor(welsirltk_TD[20], 255);
    TextDrawFont(welsirltk_TD[20], 1);
    TextDrawSetProportional(welsirltk_TD[20], 1);
    TextDrawSetShadow(welsirltk_TD[20], 0);

    TextDrawLetterSize(welsirltk_TD[34], 0.1480, 0.8740);
    TextDrawTextSize(welsirltk_TD[34], -101.0000, 0.0000);
    TextDrawAlignment(welsirltk_TD[34], 1);
    TextDrawColor(welsirltk_TD[34], -81);
    TextDrawBackgroundColor(welsirltk_TD[34], 255);
    TextDrawFont(welsirltk_TD[34], 1);
    TextDrawSetProportional(welsirltk_TD[34], 1);
    TextDrawSetShadow(welsirltk_TD[34], 0);

    welsirltk_TD[21] = TextDrawCreate(398.9046, 265.2220, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[21], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[21], 1);
    TextDrawColor(welsirltk_TD[21], -1);
    TextDrawBackgroundColor(welsirltk_TD[21], 255);
    TextDrawFont(welsirltk_TD[21], 4);
    TextDrawSetProportional(welsirltk_TD[21], 0);
    TextDrawSetShadow(welsirltk_TD[21], 0);

    welsirltk_TD[22] = TextDrawCreate(432.6191, 298.8827, "љo_100000_p."); // пусто
    TextDrawLetterSize(welsirltk_TD[22], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[22], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[22], 2);
    TextDrawColor(welsirltk_TD[22], -1);
    TextDrawBackgroundColor(welsirltk_TD[22], 255);
    TextDrawFont(welsirltk_TD[22], 1);
    TextDrawSetProportional(welsirltk_TD[22], 1);
    TextDrawSetShadow(welsirltk_TD[22], 0);

    welsirltk_TD[23] = TextDrawCreate(475.5713, 264.8073, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[23], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[23], 1);
    TextDrawColor(welsirltk_TD[23], -1);
    TextDrawBackgroundColor(welsirltk_TD[23], 255);
    TextDrawFont(welsirltk_TD[23], 4);
    TextDrawSetProportional(welsirltk_TD[23], 0);
    TextDrawSetShadow(welsirltk_TD[23], 0);

    welsirltk_TD[24] = TextDrawCreate(508.9522, 298.8828, "љo_100000_p."); // пусто
    TextDrawLetterSize(welsirltk_TD[24], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[24], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[24], 2);
    TextDrawColor(welsirltk_TD[24], -1);
    TextDrawBackgroundColor(welsirltk_TD[24], 255);
    TextDrawFont(welsirltk_TD[24], 1);
    TextDrawSetProportional(welsirltk_TD[24], 1);
    TextDrawSetShadow(welsirltk_TD[24], 0);

    welsirltk_TD[25] = TextDrawCreate(552.2379, 315.4146, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[25], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[25], 1);
    TextDrawColor(welsirltk_TD[25], -1);
    TextDrawBackgroundColor(welsirltk_TD[25], 255);
    TextDrawFont(welsirltk_TD[25], 4);
    TextDrawSetProportional(welsirltk_TD[25], 0);
    TextDrawSetShadow(welsirltk_TD[25], 0);

    welsirltk_TD[26] = TextDrawCreate(586.2855, 349.0754, "љo_100000_p."); // пусто
    TextDrawLetterSize(welsirltk_TD[26], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[26], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[26], 2);
    TextDrawColor(welsirltk_TD[26], -1);
    TextDrawBackgroundColor(welsirltk_TD[26], 255);
    TextDrawFont(welsirltk_TD[26], 1);
    TextDrawSetProportional(welsirltk_TD[26], 1);
    TextDrawSetShadow(welsirltk_TD[26], 0);

    welsirltk_TD[27] = TextDrawCreate(399.5713, 315.8294, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[27], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[27], 1);
    TextDrawColor(welsirltk_TD[27], -1);
    TextDrawBackgroundColor(welsirltk_TD[27], 255);
    TextDrawFont(welsirltk_TD[27], 4);
    TextDrawSetProportional(welsirltk_TD[27], 0);
    TextDrawSetShadow(welsirltk_TD[27], 0);

    welsirltk_TD[28] = TextDrawCreate(433.2857, 349.4902, "љo_100000_p."); // пусто
    TextDrawLetterSize(welsirltk_TD[28], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[28], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[28], 2);
    TextDrawColor(welsirltk_TD[28], -1);
    TextDrawBackgroundColor(welsirltk_TD[28], 255);
    TextDrawFont(welsirltk_TD[28], 1);
    TextDrawSetProportional(welsirltk_TD[28], 1);
    TextDrawSetShadow(welsirltk_TD[28], 0);

    welsirltk_TD[29] = TextDrawCreate(476.2379, 315.4147, "txd:brgiftscash"); // пусто
    TextDrawTextSize(welsirltk_TD[29], 70.0000, 44.0000);
    TextDrawAlignment(welsirltk_TD[29], 1);
    TextDrawColor(welsirltk_TD[29], -1);
    TextDrawBackgroundColor(welsirltk_TD[29], 255);
    TextDrawFont(welsirltk_TD[29], 4);
    TextDrawSetProportional(welsirltk_TD[29], 0);
    TextDrawSetShadow(welsirltk_TD[29], 0);

    welsirltk_TD[30] = TextDrawCreate(509.6188, 349.4902, "љo_100000_p."); // пусто
    TextDrawLetterSize(welsirltk_TD[30], 0.1946, 0.7720);
    TextDrawTextSize(welsirltk_TD[30], 0.0000, -24.0000);
    TextDrawAlignment(welsirltk_TD[30], 2);
    TextDrawColor(welsirltk_TD[30], -1);
    TextDrawBackgroundColor(welsirltk_TD[30], 255);
    TextDrawFont(welsirltk_TD[30], 1);
    TextDrawSetProportional(welsirltk_TD[30], 1);
    TextDrawSetShadow(welsirltk_TD[30], 0);

    welsirltk_TD[31] = TextDrawCreate(27.5713, 143.9302, "txd:brgiftsupdate"); // пусто
    TextDrawTextSize(welsirltk_TD[31], 126.0000, 74.0000);
    TextDrawAlignment(welsirltk_TD[31], 1);
    TextDrawColor(welsirltk_TD[31], -1);
    TextDrawBackgroundColor(welsirltk_TD[31], 255);
    TextDrawFont(welsirltk_TD[31], 4);
    TextDrawSetProportional(welsirltk_TD[31], 0);
    TextDrawSetShadow(welsirltk_TD[31], 0);
    TextDrawSetSelectable(welsirltk_TD[31], true);

    welsirltk_TD[32] = TextDrawCreate(528.2379, 159.6932, "ruletka:brgiftsexit"); // пусто
    TextDrawTextSize(welsirltk_TD[32], 91.0000, 56.0000);
    TextDrawAlignment(welsirltk_TD[32], 1);
    TextDrawColor(welsirltk_TD[32], -1);
    TextDrawBackgroundColor(welsirltk_TD[32], 255);
    TextDrawFont(welsirltk_TD[32], 4);
    TextDrawSetProportional(welsirltk_TD[32], 0);
    TextDrawSetShadow(welsirltk_TD[32], 0);
    TextDrawSetSelectable(welsirltk_TD[32], true);

    welsirltk_TD[33] = TextDrawCreate(259.6665, 68.3864, "ruletka:brgiftsspin"); // пусто
    TextDrawTextSize(welsirltk_TD[33], 110.0000, 66.0000);
    TextDrawAlignment(welsirltk_TD[33], 1);
    TextDrawColor(welsirltk_TD[33], -1);
    TextDrawBackgroundColor(welsirltk_TD[33], 255);
    TextDrawFont(welsirltk_TD[33], 4);
    TextDrawSetProportional(welsirltk_TD[33], 0);
    TextDrawSetShadow(welsirltk_TD[33], 0);
    TextDrawSetSelectable(welsirltk_TD[33], true);
}

stock RuletkaPlayer(playerid)
{
	ruletka_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 430.2377, 13.7539, "txd:brgiftslic"); // пусто
	PlayerTextDrawTextSize(playerid, ruletka_PTD[playerid][0], 70.0000, 44.0000);
	PlayerTextDrawAlignment(playerid, ruletka_PTD[playerid][0], 1);
	PlayerTextDrawColor(playerid, ruletka_PTD[playerid][0], -1);
	PlayerTextDrawBackgroundColor(playerid, ruletka_PTD[playerid][0], 255);
	PlayerTextDrawFont(playerid, ruletka_PTD[playerid][0], 4);
	PlayerTextDrawSetProportional(playerid, ruletka_PTD[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, ruletka_PTD[playerid][0], 0);

	ruletka_PTD[playerid][1] = CreatePlayerTextDraw(playerid, 352.6664, 13.7340, "txd:brgiftsuncar"); // пусто
	PlayerTextDrawTextSize(playerid, ruletka_PTD[playerid][1], 70.0000, 44.0000);
	PlayerTextDrawAlignment(playerid, ruletka_PTD[playerid][1], 1);
	PlayerTextDrawColor(playerid, ruletka_PTD[playerid][1], -1);
	PlayerTextDrawBackgroundColor(playerid, ruletka_PTD[playerid][1], 255);
	PlayerTextDrawFont(playerid, ruletka_PTD[playerid][1], 4);
	PlayerTextDrawSetProportional(playerid, ruletka_PTD[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, ruletka_PTD[playerid][1], 0);

	ruletka_PTD[playerid][2] = CreatePlayerTextDraw(playerid, 276.3807, 14.9784, "txd:brgiftsgvip"); // пусто
	PlayerTextDrawTextSize(playerid, ruletka_PTD[playerid][2], 70.0000, 44.0000);
	PlayerTextDrawAlignment(playerid, ruletka_PTD[playerid][2], 1);
	PlayerTextDrawColor(playerid, ruletka_PTD[playerid][2], -1);
	PlayerTextDrawBackgroundColor(playerid, ruletka_PTD[playerid][2], 255);
	PlayerTextDrawFont(playerid, ruletka_PTD[playerid][2], 4);
	PlayerTextDrawSetProportional(playerid, ruletka_PTD[playerid][2], 0);
	PlayerTextDrawSetShadow(playerid, ruletka_PTD[playerid][2], 0);

	ruletka_PTD[playerid][4] = CreatePlayerTextDraw(playerid, 123.9045, 14.6739, "txd:brgiftscash"); // пусто
	PlayerTextDrawTextSize(playerid, ruletka_PTD[playerid][4], 70.0000, 44.0000);
	PlayerTextDrawAlignment(playerid, ruletka_PTD[playerid][4], 1);
	PlayerTextDrawColor(playerid, ruletka_PTD[playerid][4], -1);
	PlayerTextDrawBackgroundColor(playerid, ruletka_PTD[playerid][4], 255);
	PlayerTextDrawFont(playerid, ruletka_PTD[playerid][4], 4);
	PlayerTextDrawSetProportional(playerid, ruletka_PTD[playerid][4], 0);
	PlayerTextDrawSetShadow(playerid, ruletka_PTD[playerid][4], 0);

	ruletka_PTD[playerid][3] = CreatePlayerTextDraw(playerid, 200.4284, 15.0650, "txd:brgiftsgun"); // пусто
	PlayerTextDrawTextSize(playerid, ruletka_PTD[playerid][3], 70.0000, 44.0000);
	PlayerTextDrawAlignment(playerid, ruletka_PTD[playerid][3], 1);
	PlayerTextDrawColor(playerid, ruletka_PTD[playerid][3], -1);
	PlayerTextDrawBackgroundColor(playerid, ruletka_PTD[playerid][3], 255);
	PlayerTextDrawFont(playerid, ruletka_PTD[playerid][3], 4);
	PlayerTextDrawSetProportional(playerid, ruletka_PTD[playerid][3], 0);
	PlayerTextDrawSetShadow(playerid, ruletka_PTD[playerid][3], 0);

	ruletka_PTD_t[playerid][1] = CreatePlayerTextDraw(playerid, 389.3807, 44.9925, "BMW_M5_F90"); // пусто
	PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][1] , 0.1946, 0.7720);
	PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][1] , 0.0000, -24.0000);
	PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][1] , 2);
	PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][1] , -1);
	PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][1] , 255);
	PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][1] , 1);
	PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][1] , 1);
	PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][1] , 0);

	ruletka_PTD_t[playerid][2]  = CreatePlayerTextDraw(playerid, 311.8570, 46.6399, "Gold-Vip"); // пусто
	PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][2] , 0.1946, 0.7720);
	PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][2] , 0.0000, -24.0000);
	PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][2] , 2);
	PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][2] , -1);
	PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][2] , 255);
	PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][2] , 1);
	PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][2] , 1);
	PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][2] , 0);

	ruletka_PTD_t[playerid][3]  = CreatePlayerTextDraw(playerid, 235.2379, 47.0784, "Случайное оружие"); // пусто
	PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][3] , 0.1946, 0.7720);
	PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][3] , 0.0000, -24.0000);
	PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][3] , 2);
	PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][3] , -1);
	PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][3] , 255);
	PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][3] , 1);
	PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][3] , 1);
	PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][3] , 0);

	ruletka_PTD_t[playerid][4]  = CreatePlayerTextDraw(playerid, 157.2856, 48.3346, "до 100000 р."); // пусто
	PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][4] , 0.1946, 0.7720);
	PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][4] , 0.0000, -24.0000);
	PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][4] , 2);
	PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][4] , -1);
	PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][4] , 255);
	PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][4] , 1);
	PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][4] , 1);
	PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][4] , 0);

	ruletka_PTD_t[playerid][0]  = CreatePlayerTextDraw(playerid, 466.8570, 45.8340, "Пакет с лицензиями"); // пусто
	PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][0] , 0.1946, 0.7720);
	PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][0] , 0.0000, -24.0000);
	PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][0] , 2);
	PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][0] , -1);
	PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][0] , 255);
	PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][0] , 1);
	PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][0] , 1);
	PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][0] , 0);

    ruletka_PTD_t[playerid][5] = CreatePlayerTextDraw(playerid, 11.6664, 358.4451, "txd:brgiftsuncar"); // пусто
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][5], 70.0000, 44.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][5], 1);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][5], -1);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][5], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][5], 4);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][5], 0);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][5], 0);

    ruletka_PTD_t[playerid][6] = CreatePlayerTextDraw(playerid, 99.6666, 361.7334, "Welsi_Developer"); // пусто
    PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][6], 0.2506, 1.2391);
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][6], -9.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][6], 1);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][6], -1);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][6], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][6], 1);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][6], 1);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][6], 0);

    ruletka_PTD_t[playerid][7] = CreatePlayerTextDraw(playerid, 47.7141, 388.8739, "BMW_M5_F90"); // пусто
    PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][7], 0.1946, 0.7720);
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][7], 0.0000, -24.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][7], 2);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][7], -1);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][7], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][7], 1);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][7], 1);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][7], 0);

    ruletka_PTD_t[playerid][8] = CreatePlayerTextDraw(playerid, 86.9999, 376.6668, "ЂPOH€O‹‘† KE†C"); // пусто
    PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][8], 0.1793, 1.0897);
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][8], -9.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][8], 1);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][8], -86);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][8], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][8], 2);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][8], 1);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][8], 0);

    ruletka_PTD_t[playerid][9] = CreatePlayerTextDraw(playerid, 10.9998, 305.7636, "txd:brgiftsuncar"); // пусто
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][9], 70.0000, 44.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][9], 1);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][9], -1);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][9], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][9], 4);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][9], 0);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][9], 0);

    ruletka_PTD_t[playerid][10] = CreatePlayerTextDraw(playerid, 47.3807, 336.1924, "BMW_M5_F90"); // пусто
    PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][10], 0.1946, 0.7720);
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][10], 0.0000, -24.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][10], 2);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][10], -1);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][10], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][10], 1);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][10], 1);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][10], 0);

    ruletka_PTD_t[playerid][11] = CreatePlayerTextDraw(playerid, 99.6666, 308.2222, "Welsi_Developer"); // пусто
    PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][11], 0.2526, 1.2640);
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][11], -9.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][11], 1);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][11], -1);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][11], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][11], 1);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][11], 1);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][11], 0);

    ruletka_PTD_t[playerid][12] = CreatePlayerTextDraw(playerid, 86.9999, 323.1556, "ЂPOH€O‹‘† KE†C"); // пусто
    PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][12], 0.1813, 1.1146);
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][12], -9.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][12], 1);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][12], -86);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][12], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][12], 2);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][12], 1);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][12], 0);

    ruletka_PTD_t[playerid][13] = CreatePlayerTextDraw(playerid,11.3331, 253.0822, "txd:brgiftsuncar"); // пусто
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][13], 70.0000, 44.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][13], 1);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][13], -1);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][13], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][13], 4);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][13], 0);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][13], 0);

    ruletka_PTD_t[playerid][14] = CreatePlayerTextDraw(playerid,47.7141, 283.5110, "BMW_M5_F90"); // пусто
    PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][14], 0.1946, 0.7720);
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][14], 0.0000, -24.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][14], 2);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][14], -1);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][14], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][14], 1);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][14], 1);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][14], 0);

    ruletka_PTD_t[playerid][15] = CreatePlayerTextDraw(playerid,99.6666, 256.3703, "Welsi_Developer"); // пусто
    PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][15], 0.2526, 1.2640);
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][15], -9.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][15], 1);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][15], -1);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][15], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][15], 1);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][15], 1);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][15], 0);

    ruletka_PTD_t[playerid][16] = CreatePlayerTextDraw(playerid,86.9999, 271.3037, "ЂPOH€O‹‘† KE†C"); // пусто
    PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][16], 0.1813, 1.1146);
    PlayerTextDrawTextSize(playerid, ruletka_PTD_t[playerid][16], -9.0000, 0.0000);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][16], 1);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][16], -86);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][16], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][16], 2);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][16], 1);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][16], 0);

    
    ruletka_PTD_t[playerid][17] = CreatePlayerTextDraw(playerid, 317.3334, 173.8222, "4"); // пусто
    PlayerTextDrawLetterSize(playerid, ruletka_PTD_t[playerid][17], 0.2939, 1.3386);
    PlayerTextDrawAlignment(playerid, ruletka_PTD_t[playerid][17], 1);
    PlayerTextDrawColor(playerid, ruletka_PTD_t[playerid][17], -1);
    PlayerTextDrawBackgroundColor(playerid, ruletka_PTD_t[playerid][17], 255);
    PlayerTextDrawFont(playerid, ruletka_PTD_t[playerid][17], 1);
    PlayerTextDrawSetProportional(playerid, ruletka_PTD_t[playerid][17], 1);
    PlayerTextDrawSetShadow(playerid, ruletka_PTD_t[playerid][17], 0);
}

new td_prize[12][2] =
{
    {5,6},
    {9,10},
    {11,12},
    {13,14},
    {15,16},
    {17,18},
    {19,20},
    {21,22},
    {23,24},
    {25,26},
    {27,28},
    {29,30}
};

stock LoadPrizeRuletka()
{
    for(new i;i <12;i++)
    {
        TextDrawSetString(welsirltk_TD[td_prize[i][0]], ruletka_prize[i][R_NAME_TXD]);
        TextDrawSetString(welsirltk_TD[td_prize[i][1]], ruletka_prize[i][R_NAME_TEXT]);
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    player_roulette_bronz[playerid] = 0;
    ruletka_count[playerid] = 0;
    animation_player[playerid] = false;
    timer_player_ruletka[playerid] = -1;
    #if defined rul_OnPlayerDisconnect
        return rul_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect rul_OnPlayerDisconnect
#if defined rul_OnPlayerDisconnect
    forward rul_OnPlayerDisconnect(playerid, reason);
#endif


public:RunRuletka(playerid)
{
	animation_player[playerid] = true;

	if(ruletka_count[playerid])
	{
		new text[135];

		if(ruletka_count[playerid] == 15)
		{
			format(text, sizeof text, "Поздравляем! Вам выпал %s{FFFF00}.{FFFFFF} Чтобы забрать приз {FFFF00}/roulette", ruletka_prize[menu_prize_player[playerid][2]][R_NAME_PRIZE]);
			SendClientMessage(playerid, -1, text);
            GivePrizeRoulette(playerid, menu_prize_player[playerid][2]);

			animation_player[playerid] = false;
			KillTimer(timer_player_ruletka[playerid]);
			timer_player_ruletka[playerid] = -1;
			ruletka_count[playerid]=0;

            format(last_player_ruletka[0][last_player_name], 24, last_player_ruletka[1][last_player_name]);
            last_player_ruletka[0][id_ruletka_prize] = last_player_ruletka[1][id_ruletka_prize];
            format(last_player_ruletka[1][last_player_name], 24, last_player_ruletka[2][last_player_name]);
            last_player_ruletka[1][id_ruletka_prize] = last_player_ruletka[2][id_ruletka_prize];
            format(last_player_ruletka[2][last_player_name], 24, GetPlayerNameEx(playerid));
            last_player_ruletka[2][id_ruletka_prize] = menu_prize_player[playerid][2];

			return 1;
		}
		else
		{
			ruletka_count[playerid]++;
			
			new o = 5;
			while(o > 1)
			{
				o--;
				PlayerTextDrawSetString(playerid, ruletka_PTD[playerid][o], ruletka_prize[menu_prize_player[playerid][o-1]][R_NAME_TXD]);
				PlayerTextDrawSetString(playerid, ruletka_PTD_t[playerid][o], ruletka_prize[menu_prize_player[playerid][o-1]][R_NAME_TEXT]);
				menu_prize_player[playerid][o] = menu_prize_player[playerid][o-1];

			}

            new array[] = {2,2,8,8,8,8,8,8,8,8,16,18};
			menu_prize_player[playerid][0] = random2(array);
			PlayerTextDrawSetString(playerid, ruletka_PTD[playerid][0], ruletka_prize[menu_prize_player[playerid][0]][R_NAME_TXD]);
			PlayerTextDrawSetString(playerid, ruletka_PTD_t[playerid][0], ruletka_prize[menu_prize_player[playerid][0]][R_NAME_TEXT]);
		}
	}
	else 
	{
		ruletka_count[playerid]=1;
	}

	return 1;
}

stock UpdateLastPlayerRuletka(playerid)
{
    for(new i; i < 3;i++)
    {
        PlayerTextDrawSetString(playerid, ruletka_PTD_t[playerid][last_player_td[i][0]], last_player_ruletka[i][last_player_name]);
        PlayerTextDrawSetString(playerid, ruletka_PTD_t[playerid][last_player_td[i][1]], ruletka_prize[last_player_ruletka[i][id_ruletka_prize]][R_NAME_TXD]);
        PlayerTextDrawSetString(playerid, ruletka_PTD_t[playerid][last_player_td[i][2]], ruletka_prize[last_player_ruletka[i][id_ruletka_prize]][R_NAME_TEXT]);
    }

    return 1;
}

random2(array[], size_w = sizeof(array))
 { 
	if(size_w < 1) return -1; 
	new sum = 0, result = 0; 

	for(new i = size_w - 1; i > -1; i--) 
	{ 
		sum += array[i];
		 if(random(sum) < array[i])
		  { 
			result = i;
		  }
	}
		    return result; 
}

stock GivePrizeRoulette(playerid, prize_id)
{
    new query[94];
    mysql_format(mysql, query, sizeof query, "INSERT INTO roulette_prize (owner, prize) VALUES (%d,%d)", GetPlayerAccountID(playerid), prize_id);
    mysql_query(mysql, query, false);

    if(mysql_errno()) SendClientMessage(playerid, -1, "Ошибка в запросе.");

    return 1;
}

public: CreateTablistRoulette()
{
    new Cache:cache = mysql_query(mysql, "SELECT * FROM roulette_prize", true);

    if(mysql_errno())
    {
        mysql_query(mysql, "CREATE TABLE .`roulette_prize` ( `id` INT NOT NULL AUTO_INCREMENT , `owner` INT NOT NULL , `prize` INT NOT NULL , PRIMARY KEY (`id`)) ENGINE = InnoDB", false);

        if(mysql_errno()) printf("%d error create tablist roulette_prize", mysql_errno());
    }


    cache_delete(cache);

    cache = mysql_query(mysql, "SELECT * FROM accounts WHERE roulette_bronz", true);

    if(mysql_errno())
    {
        mysql_query(mysql, "ALTER TABLE `accounts` ADD `roulette_bronz` INT NOT NULL DEFAULT '0' AFTER `money`", false);

        if(mysql_errno()) printf("%d error alter roulette_bronz", mysql_errno());
    }

    cache_delete(cache);

    return 1;
}

stock GivePlayerCarRoulette(playerid, modelid, color_1, color_2)
{
		new to_player = playerid;
		new Float:POS[3];
		GetPlayerPos(to_player, POS[0],POS[1],POS[2]);
		new Float: pos_x = POS[0];
		new Float: pos_y = POS[1];
		new Float: pos_z = POS[2];
		new Float: angle = 356.7986;
		new query[220],
			Cache: result,
			idx;

		idx = GetFreeOwnableCarID();
		SetOwnableCarData(idx, OC_OWNER_ID, 	GetPlayerAccountID(to_player));
		SetOwnableCarData(idx, OC_MODEL_ID, 	modelid);
		SetOwnableCarData(idx, OC_COLOR_1, 		color_1);
		SetOwnableCarData(idx, OC_COLOR_2, 		color_2);
		SetOwnableCarData(idx, OC_POS_X, 		pos_x);
		SetOwnableCarData(idx, OC_POS_Y, 		pos_y);
		SetOwnableCarData(idx, OC_POS_Z, 		pos_z);
		SetOwnableCarData(idx, OC_ANGLE, 		angle);
		strmid(g_ownable_car[idx][OC_NUMBER], "--------", 0, 8, 8);
		SetOwnableCarData(idx, OC_ALARM, 		false);
		SetOwnableCarData(idx, OC_KEY_IN, 		true);
		SetOwnableCarData(idx, OC_CREATE, 		gettime());
		/*new idt = GetFreeOwnableCarID();*/
		format(g_ownable_car[idx][OC_OWNER_NAME], 21, GetPlayerNameEx(playerid));
		//SetVehicleRuNumberPlate(vehicleid, g_ownable_car[idt][OC_NUMBER], "52");

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
			format(g_ownable_car[idx][OC_NUMBER], 12, g_ownable_car[idx][OC_NUMBER]);
			SetVehicleRuNumberPlate(vehicleid, g_ownable_car[idx][OC_NUMBER], "17");
			SetVehicleParam(vehicleid, V_LOCK, false);

			SetVehicleData(vehicleid, V_MILEAGE, 0.0);
		}

		SetPlayerData(to_player, P_OWNABLE_CAR, vehicleid);

		format
		(
			query, sizeof query,
			"INSERT INTO ownable_cars \
			(owner_id,model_id,color_1,color_2,pos_x,pos_y,pos_z,angle,create_time) \
			VALUES \
			('%d','%d','%d','%d','%f','%f','%f','%f','%d')",
			GetPlayerAccountID(to_player),
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
		SetOwnableCarData(idx, OC_SQL_ID, cache_insert_id());
		cache_delete(result);
}

CMD:roulette(playerid)
{
    new query[94];
    mysql_format(mysql, query, sizeof query, "SELECT * FROM roulette_prize WHERE owner = %d", GetPlayerAccountID(playerid));
    new Cache:cache = mysql_query(mysql, query);

    if(!cache_num_rows()) return SendClientMessage(playerid, -1, "У вас нет призов с рулетки.");

    new rows, prize_id,id, list[52], dialog[sizeof list*10+54];

    strcat(dialog, "Следующая страница\nПредыдущая страница\n");

    rows = cache_num_rows();

    if(rows >= 10) rows = 10;

    for(new i,c=2;i < rows;i++,c++)
    {
        prize_id = cache_get_field_content_int(i, "prize");
        id = cache_get_field_content_int(i, "id");

        format(list, sizeof list, "%d. %s\n", i+1, ruletka_prize[prize_id][R_NAME_PRIZE]);
        strcat(dialog, list);
        SetPlayerListitemValue(playerid, c, prize_id);
        format(list, sizeof list, "rouletteid_%d", c);
        SetPVarInt(playerid, list, id);
    }

    SetPVarInt(playerid, "count_list", 1);
    Dialog(playerid, 2832, DIALOG_STYLE_LIST, "{FF0000}Призы с рулетки", dialog, "Далее", "Выйти");
    return 1;
}

public:LoadRuletka(playerid)
{
    new text[124];
    mysql_format(mysql, text, sizeof text, "SELECT roulette_bronz FROM accounts WHERE id=%d", GetPlayerAccountID(playerid));
    new Cache:cache = mysql_query(mysql, text, true);
    if(mysql_errno()) SendClientMessage(playerid, -1, "Ошибка в запросе.");

    player_roulette_bronz[playerid] = cache_get_row_int(0, 0);
    cache_delete(cache);
    return 1;
}


//?













