enum Game_HAT
{
    HAT_Owner,
    HAT_Player,
    HAT_Role,
    bool:HAT_Throw,
    HAT_Bid,
    bool:HAT_Game,
}

#define HAT_Role_Heads 1 //Орёл
#define HAT_Role_Tails 2 //Решка

#define HAT_MSG "{FF9500}[Орёл и Решка]{FFFFFF} "
#define MAX_BID_HAT 10_000_000 //максимальная ставка в Орел и Решка
#define MAX_BID_HAT_str "10.000.000" //максимальная ставка в Орел и Решка 

new player_HAT[MAX_PLAYERS][Game_HAT];

new player_timer_acceptHAT[MAX_PLAYERS];
public OnGameModeInit()
{
    printf("[KRANIN_SYSTEM] Игра \"Орёл и решка\" загружена");
    #if defined HAT_OnGameModeInit
        return HAT_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit HAT_OnGameModeInit
#if defined HAT_OnGameModeInit
    forward HAT_OnGameModeInit();
#endif


cmd:spin(playerid, params[])
{
    new to_player = -1;

    if(sscanf(params, "d", to_player)) return SendClientMessage(playerid, -1, ""HAT_MSG"/spin [ID - игрока]");

    if(!IsPlayerInRangeOfPlayer(playerid, to_player, 3.5)) return SendClientMessage(playerid, -1, ""HAT_MSG"Игрок слишком далеко от Вас");

    if(player_HAT[to_player][HAT_Owner] != -1) return SendClientMessage(playerid, -1, ""HAT_MSG"У игрока уже есть активное предложение");

    ShowPlayerDialog(playerid, 4374, DIALOG_STYLE_INPUT, "Орёл и Решка", "Введите ставку\nВведите 0 чтобы играть без ставки\n\
    Максимальная ставка: "MAX_BID_HAT_str" руб.", "Далее", "Выйти");

    player_HAT[playerid][HAT_Player] = to_player;

    return 1;
}

cmd:spins(playerid, params[])
{
    if(player_HAT[playerid][HAT_Game]) return SendClientMessage(playerid, -1, ""HAT_MSG"Ждите окончания игры");

    if(player_HAT[playerid][HAT_Owner] == -1) return SendClientMessage(playerid, -1, ""HAT_MSG"У вас нет актуального предложения");

   // if(strlen(params) > 3) return SendClientMessage(playerid, -1, ""HAT_MSG"/spins [Yes / No]");

    if(!strcmp(params, "Yes", true)) {
        if(player_HAT[playerid][HAT_Owner] == playerid) return 0;

        new to_player = player_HAT[playerid][HAT_Owner];

        KillTimer(player_timer_acceptHAT[to_player]);

        if(player_HAT[playerid][HAT_Role] == HAT_Role_Heads) StartHAT(playerid, to_player);
        else StartHAT(to_player, playerid);
    }
    else if(!strcmp(params, "No", true))
    {
        new to_player = -1;
        if(player_HAT[playerid][HAT_Owner] == playerid) to_player = player_HAT[playerid][HAT_Player];
        else to_player = player_HAT[playerid][HAT_Owner];

        SendClientMessage(to_player, -1, ""HAT_MSG"Игрок отказался от предложения");
        SendClientMessage(playerid, -1, ""HAT_MSG"Вы отказались от предложения");

        DefaultHAT(playerid);
        DefaultHAT(to_player);
    }
    else SendClientMessage(playerid, -1, ""HAT_MSG"/spins [Yes / No]");

    return 1;
}

stock StartHAT(heads, tails)
{
    if(!IsPlayerConnected(heads) || !IsPlayerConnected(tails))
    {
        SendClientMessage(heads, -1, ""HAT_MSG"Один из игроков вышел");
        SendClientMessage(tails, -1, ""HAT_MSG"Один из игроков вышел");

        DefaultHAT(heads);
        DefaultHAT(tails);

        return 1;
    }

    new bid = player_HAT[heads][HAT_Bid];
    if(GetPlayerMoneyEx(heads) < bid || GetPlayerMoneyEx(tails) < bid) {
        SendClientMessage(heads, -1, "У одного из игроков не хватает деньги на ставку");
        SendClientMessage(tails, -1, "У одного из игроков не хватает деньги на ставку");

        DefaultHAT(heads);
        DefaultHAT(tails);
        return 1;
    }
    new string[144];

	if(player_HAT[heads][HAT_Throw]) format(string, sizeof string, "%s бросил монету...", GetPlayerNameEx(heads));
    else format(string, sizeof string, "%s бросил монету...", GetPlayerNameEx(tails));
	SendClientMessage(heads, 0xDD90FFFF, string);
	SendClientMessage(tails, 0xDD90FFFF, string);
    format(string, sizeof string, ""HAT_MSG"%s - Орёл", GetPlayerNameEx(heads));
    format(string, sizeof string, ""HAT_MSG"%s - Решка", GetPlayerNameEx(tails));

    player_HAT[heads][HAT_Game] = true;
    player_HAT[tails][HAT_Game] = true;
    SetTimerEx("EndHAT", 3000, false, "ii", heads, tails);
    return 1;
}

public:EndHAT(heads, tails)
{
    if(!IsPlayerConnected(heads) || !IsPlayerConnected(tails))
    {
        SendClientMessage(heads, -1, ""HAT_MSG"Один из игроков вышел");
        SendClientMessage(tails, -1, ""HAT_MSG"Один из игроков вышел");

        DefaultHAT(heads);
        DefaultHAT(tails);

        return 1;
    }
    
    new winner, loser, r = random(2);

    if(!r) { winner = heads; loser = tails; }
    else { winner = tails; loser = heads; }

    new string[144];

    new owner, player;

    if(player_HAT[heads][HAT_Owner] == heads) { owner = heads; player = tails; }
    else { owner = tails; player = heads; }

    format(string, sizeof string, ""HAT_MSG"Выпал(а) %s", r > 0 ? "Решка" : "Орёл");
    SendClientMessage(heads, -1, string);
    SendClientMessage(tails, -1, string);

    new bid = player_HAT[owner][HAT_Bid];

    if(bid)
    {
        if(GetPlayerMoneyEx(loser) >= bid) {
            GivePlayerMoneyEx(loser, -bid, "Орёл и Решка");
            GivePlayerMoneyEx(winner, bid, "Орёл и Решка");
        }
        else {
            SendClientMessage(loser, -1, "У Вас не хватает денег для выплаты выигрыша");
            SendClientMessage(winner, -1, "У Игрока не хватает денег для выплаты выигрыша");
        }
    }

    ShowPlayerDialog(owner, 4377, DIALOG_STYLE_LIST, "Орёл и решка",
    "Изменить роли или бросающего монету\n"\
    "Предложить снова",
    "Далее", "Выйти"
    );

    player_HAT[player][HAT_Owner] = -1;
    player_HAT[player][HAT_Bid] = 0;


    player_HAT[owner][HAT_Game] = false;
    player_HAT[player][HAT_Game] = false;

    return 1;
}

stock DefaultHAT(playerid)
{
    player_HAT[playerid][HAT_Bid] = 0;
    player_HAT[playerid][HAT_Owner] = -1;
    player_HAT[playerid][HAT_Player] = -1;
    player_HAT[playerid][HAT_Game] = false;
    player_HAT[playerid][HAT_Role] = 0;
}

stock DialogThrowHAT(playerid)
{
    new string[144];

    format(string, sizeof string, "Бросает %s\nБросает %s", GetPlayerNameEx(playerid), GetPlayerNameEx(player_HAT[playerid][HAT_Player]));

    ShowPlayerDialog(
        playerid, 4375, DIALOG_STYLE_LIST, 
        "Орёл и Решка", string, "Выбрать", "Выйти"
    );
    return 1;
}

stock DialogRoleHAT(playerid)
{
    new string[144], to_player = player_HAT[playerid][HAT_Player];

    format(string, sizeof string, "Я – Орёл, %s – Решка\n%s – Орёл, Я – Решка", GetPlayerNameEx(to_player), GetPlayerNameEx(to_player));

    ShowPlayerDialog(
        playerid, 4376, DIALOG_STYLE_LIST, 
        "Орёл и Решка", string, "Выбрать", "Выйти"
    );
    return 1;
}

stock AcceptHAT(playerid, to_player)
{
    if(player_HAT[to_player][HAT_Owner] != -1) { SendClientMessage(playerid, -1, ""HAT_MSG"У игрока уже есть актуальное предложение"); DefaultHAT(playerid); return 1;}

    if(player_HAT[playerid][HAT_Throw]) player_HAT[to_player][HAT_Throw] = false;
    else player_HAT[to_player][HAT_Throw] = true;

    if(player_HAT[playerid][HAT_Role] == HAT_Role_Heads) player_HAT[to_player][HAT_Role] = HAT_Role_Tails;
    else player_HAT[to_player][HAT_Role] = HAT_Role_Heads;
    
    new bid = player_HAT[playerid][HAT_Bid];

    player_HAT[to_player][HAT_Owner] = playerid;
    player_HAT[playerid][HAT_Owner] = playerid;
    player_HAT[to_player][HAT_Bid] = bid; 

    new string[144], bid_text[42] = "без ставки";

    if(bid > 0) format(bid_text, sizeof bid_text, "со ставкой: %d руб.", bid);

    format(string, sizeof string, "%s предлагает Вам сыграть в \"Орёл и решка\" %s", GetPlayerNameEx(playerid), bid_text);
    SendClientMessage(to_player, 0xFF9500FF, string);
    format(string, sizeof string, "Вы %s", player_HAT[to_player][HAT_Role] > 1 ? "Решка" : "Орёл");
    SendClientMessage(to_player, 0xFF9500FF, string);

    format(string, sizeof string, "Вы предложили %s сыграть в \"Орёл и решка\" %s", GetPlayerNameEx(to_player), bid_text);
    SendClientMessage(playerid, 0xFF9500FF, string);

    format(string, sizeof string, "Вы %s", player_HAT[playerid][HAT_Role] > 1 ? "Решка" : "Орёл");
    SendClientMessage(playerid, 0xFF9500FF, string);

    SendClientMessage(to_player, -1, ""HAT_MSG"{D22323}Чтобы отказаться /spins No");
    SendClientMessage(playerid, -1, ""HAT_MSG"{D22323}Чтобы отозвать /spins No");
    SendClientMessage(to_player, -1, ""HAT_MSG"{45CF29}Чтобы принять /spins Yes");

    player_timer_acceptHAT[playerid] = SetTimerEx("CancelAcceptHAT", 10000, false, "ii", playerid, to_player);
    return 1;
}

public:CancelAcceptHAT(playerid, to_player)
{
    SendClientMessage(to_player, -1, ""HAT_MSG"Игрок отказался от предложения");
    SendClientMessage(playerid, -1, ""HAT_MSG"Вы отказались от предложения");

    DefaultHAT(playerid);
    DefaultHAT(to_player);
    player_timer_acceptHAT[playerid]= -1;
    return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 4374)
    {
        if(response)
        {
            new bid;
            if(sscanf(inputtext, "d", bid)) SendClientMessage(playerid, -1, ""HAT_MSG"Вы не правильно ввели данные");
            else {
                if(bid > MAX_BID_HAT) return SendClientMessage(playerid, -1, ""HAT_MSG"Ваша ставка превышает максимальную ("MAX_BID_HAT_str" руб.)");

                new to_player = player_HAT[playerid][HAT_Player];

                if(!IsPlayerInRangeOfPlayer(playerid, to_player, 4.5)) return SendClientMessage(playerid, -1, ""HAT_MSG"Игрок слишком далеко от Вас");

                if(GetPlayerMoneyEx(to_player) < bid) return SendClientMessage(playerid, -1, ""HAT_MSG"У игрока не хватает денег");
                player_HAT[playerid][HAT_Bid] = bid;
                
                DialogRoleHAT(playerid);
            }
        }
        else
        {
            DefaultHAT(player_HAT[playerid][HAT_Player]); DefaultHAT(playerid);
        }
    }
    if(dialogid == 4375)
    {
        if(response)
        {
            new to_player = player_HAT[playerid][HAT_Player];
            if(!listitem) player_HAT[playerid][HAT_Throw] = true;

            AcceptHAT(playerid, to_player);
        }
        else {
            DefaultHAT(player_HAT[playerid][HAT_Player]); DefaultHAT(playerid);
        }
    }
    if(dialogid == 4376)
    {
        if(response)
        {
            if(!listitem) { player_HAT[playerid][HAT_Role] = HAT_Role_Heads;}
            else { player_HAT[playerid][HAT_Role] = HAT_Role_Tails;}

            DialogThrowHAT(playerid);
        }
        else {
            DefaultHAT(player_HAT[playerid][HAT_Player]); DefaultHAT(playerid);
        }
    }
    if(dialogid == 4377) {
    if(response) { 
        if(!listitem) DialogRoleHAT(playerid);
        else AcceptHAT(playerid, player_HAT[playerid][HAT_Player]);
    }
    else { DefaultHAT(player_HAT[playerid][HAT_Player]); DefaultHAT(playerid); }

    }
    #if defined HAT_OnDialogResponse
    return HAT_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse HAT_OnDialogResponse
#if defined HAT_OnDialogResponse
forward HAT_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

public OnPlayerSpawn(playerid)
{
    DefaultHAT(playerid);
    #if defined HAT_OnPlayerSpawn
        return HAT_OnPlayerSpawn(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn HAT_OnPlayerSpawn
#if defined HAT_OnPlayerSpawn
    forward HAT_OnPlayerSpawn(playerid);
#endif
