#if defined _DUELS_INCLUDED
    #endinput
#endif
#define _DUELS_INCLUDED

#include <a_samp>
#include <pawncmd>
#include <sscanf2>
#include <a_mysql>

#define DUEL_DB                 g_SQL
#define DUEL_ELO_DEFAULT        1000
#define DUEL_ELO_SILVER         1200
#define DUEL_ELO_GOLD           1600
#define DUEL_ELO_K              32
#define DUEL_MIN_BET            0
#define DUEL_MAX_BET            10000000
#define DUEL_WORLD_START        7000
#define DUEL_BRONZE_REWARD      50000
#define DUEL_SILVER_REWARD      150000
#define DUEL_GOLD_REWARD        300000

#define DIALOG_DUEL_WEAPON      8800
#define DIALOG_DUEL_BET         8801
#define DIALOG_DUEL_INVITE      8802
#define DIALOG_DUEL_STATS       8803
#define DIALOG_DUEL_HISTORY     8804

#define DUEL_COLOR              0xE5B64AFF
#define DUEL_ERROR              0xE74C3CFF
#define DUEL_GREEN              0x2ECC71FF
#define DUEL_WHITE              0xFFFFFFFF
#define DUEL_GRAY               0xBFC0C2FF

#define DUEL_P1_X               1415.3203
#define DUEL_P1_Y              -1700.6411
#define DUEL_P1_Z               13.5395
#define DUEL_P1_A               270.0
#define DUEL_P2_X               1455.2194
#define DUEL_P2_Y              -1700.6411
#define DUEL_P2_Z               13.5395
#define DUEL_P2_A               90.0

enum
{
    DUEL_STATE_NONE,
    DUEL_STATE_SETUP,
    DUEL_STATE_OUTGOING,
    DUEL_STATE_INCOMING,
    DUEL_STATE_FIGHT
};

new gDuelState[MAX_PLAYERS];
new gDuelOpponent[MAX_PLAYERS];
new gDuelWeapon[MAX_PLAYERS];
new gDuelBet[MAX_PLAYERS];
new gDuelWorld[MAX_PLAYERS];
new gDuelElo[MAX_PLAYERS];
new gDuelWins[MAX_PLAYERS];
new gDuelLosses[MAX_PLAYERS];
new gDuelMatches[MAX_PLAYERS];
new gDuelSeasonWins[MAX_PLAYERS];
new gDuelSeasonLosses[MAX_PLAYERS];
new bool:gDuelStatsLoaded[MAX_PLAYERS];
new bool:gDuelRestoreAfterSpawn[MAX_PLAYERS];
new bool:gDuelRewardQuery[MAX_PLAYERS];
new gDuelWorldCounter = DUEL_WORLD_START;

new Float:gDuelOldX[MAX_PLAYERS];
new Float:gDuelOldY[MAX_PLAYERS];
new Float:gDuelOldZ[MAX_PLAYERS];
new Float:gDuelOldA[MAX_PLAYERS];
new Float:gDuelOldHealth[MAX_PLAYERS];
new Float:gDuelOldArmour[MAX_PLAYERS];
new gDuelOldWorld[MAX_PLAYERS];
new gDuelOldInterior[MAX_PLAYERS];
new gDuelOldWeapon[MAX_PLAYERS][13];
new gDuelOldAmmo[MAX_PLAYERS][13];

stock Duel_GetAccountID(playerid)
{
    return GetPVarInt(playerid, "AccountID");
}

stock Duel_GetMoney(playerid)
{
    return GetPlayerMoney(playerid);
}

stock Duel_AddMoney(playerid, amount)
{
    GivePlayerMoney(playerid, amount);
    return 1;
}

stock Duel_GetName(playerid, name[], size)
{
    GetPlayerName(playerid, name, size);
    return 1;
}

stock Duel_GetDivision(elo, division[], size)
{
    if(elo >= DUEL_ELO_GOLD) format(division, size, "Gold");
    else if(elo >= DUEL_ELO_SILVER) format(division, size, "Silver");
    else format(division, size, "Bronze");
    return 1;
}

stock Duel_GetWeaponName(weaponid, weapon[], size)
{
    switch(weaponid)
    {
        case 24: format(weapon, size, "Desert Eagle");
        case 25: format(weapon, size, "Shotgun");
        case 29: format(weapon, size, "MP5");
        case 30: format(weapon, size, "AK-47");
        case 31: format(weapon, size, "M4");
        case 33: format(weapon, size, "Rifle");
        default: format(weapon, size, "Weapon %d", weaponid);
    }
    return 1;
}

stock Duel_GetWeaponFromList(listitem)
{
    switch(listitem)
    {
        case 0: return 24;
        case 1: return 25;
        case 2: return 29;
        case 3: return 30;
        case 4: return 31;
        case 5: return 33;
    }
    return 24;
}

stock Duel_InitPlayer(playerid)
{
    gDuelState[playerid] = DUEL_STATE_NONE;
    gDuelOpponent[playerid] = INVALID_PLAYER_ID;
    gDuelWeapon[playerid] = 0;
    gDuelBet[playerid] = 0;
    gDuelWorld[playerid] = 0;
    gDuelElo[playerid] = DUEL_ELO_DEFAULT;
    gDuelWins[playerid] = 0;
    gDuelLosses[playerid] = 0;
    gDuelMatches[playerid] = 0;
    gDuelSeasonWins[playerid] = 0;
    gDuelSeasonLosses[playerid] = 0;
    gDuelStatsLoaded[playerid] = false;
    gDuelRestoreAfterSpawn[playerid] = false;
    gDuelRewardQuery[playerid] = false;
    return 1;
}

stock Duel_LoadStats(playerid)
{
    new accountid = Duel_GetAccountID(playerid);
    if(accountid <= 0) return 0;

    new query[256];
    mysql_format(DUEL_DB, query, sizeof(query), "SELECT * FROM duel_stats WHERE account_id=%d LIMIT 1", accountid);
    mysql_tquery(DUEL_DB, query, "Duel_OnStatsLoaded", "d", playerid);
    return 1;
}

forward Duel_OnStatsLoaded(playerid);
public Duel_OnStatsLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;

    if(cache_num_rows())
    {
        cache_get_value_name_int(0, "elo", gDuelElo[playerid]);
        cache_get_value_name_int(0, "wins", gDuelWins[playerid]);
        cache_get_value_name_int(0, "losses", gDuelLosses[playerid]);
        cache_get_value_name_int(0, "matches", gDuelMatches[playerid]);
        cache_get_value_name_int(0, "season_wins", gDuelSeasonWins[playerid]);
        cache_get_value_name_int(0, "season_losses", gDuelSeasonLosses[playerid]);
    }
    else Duel_SaveStats(playerid);

    gDuelStatsLoaded[playerid] = true;
    return 1;
}

stock Duel_SaveStats(playerid)
{
    new accountid = Duel_GetAccountID(playerid);
    if(accountid <= 0) return 0;

    new query[700];
    mysql_format(DUEL_DB, query, sizeof(query),
        "INSERT INTO duel_stats (account_id,elo,wins,losses,matches,season_wins,season_losses) VALUES (%d,%d,%d,%d,%d,%d,%d) ON DUPLICATE KEY UPDATE elo=VALUES(elo),wins=VALUES(wins),losses=VALUES(losses),matches=VALUES(matches),season_wins=VALUES(season_wins),season_losses=VALUES(season_losses)",
        accountid, gDuelElo[playerid], gDuelWins[playerid], gDuelLosses[playerid], gDuelMatches[playerid], gDuelSeasonWins[playerid], gDuelSeasonLosses[playerid]);
    mysql_tquery(DUEL_DB, query);
    return 1;
}

stock Duel_SavePlayerState(playerid)
{
    GetPlayerPos(playerid, gDuelOldX[playerid], gDuelOldY[playerid], gDuelOldZ[playerid]);
    GetPlayerFacingAngle(playerid, gDuelOldA[playerid]);
    GetPlayerHealth(playerid, gDuelOldHealth[playerid]);
    GetPlayerArmour(playerid, gDuelOldArmour[playerid]);
    gDuelOldWorld[playerid] = GetPlayerVirtualWorld(playerid);
    gDuelOldInterior[playerid] = GetPlayerInterior(playerid);

    for(new slot = 0; slot < 13; slot++)
        GetPlayerWeaponData(playerid, slot, gDuelOldWeapon[playerid][slot], gDuelOldAmmo[playerid][slot]);
    return 1;
}

stock Duel_RestorePlayer(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    SetPlayerVirtualWorld(playerid, gDuelOldWorld[playerid]);
    SetPlayerInterior(playerid, gDuelOldInterior[playerid]);
    SetPlayerPos(playerid, gDuelOldX[playerid], gDuelOldY[playerid], gDuelOldZ[playerid]);
    SetPlayerFacingAngle(playerid, gDuelOldA[playerid]);
    SetPlayerHealth(playerid, gDuelOldHealth[playerid]);
    SetPlayerArmour(playerid, gDuelOldArmour[playerid]);
    ResetPlayerWeapons(playerid);

    for(new slot = 0; slot < 13; slot++)
        if(gDuelOldWeapon[playerid][slot] != 0)
            GivePlayerWeapon(playerid, gDuelOldWeapon[playerid][slot], gDuelOldAmmo[playerid][slot]);

    TogglePlayerControllable(playerid, true);
    return 1;
}

stock Duel_Reset(playerid)
{
    gDuelState[playerid] = DUEL_STATE_NONE;
    gDuelOpponent[playerid] = INVALID_PLAYER_ID;
    gDuelWeapon[playerid] = 0;
    gDuelBet[playerid] = 0;
    gDuelWorld[playerid] = 0;
    return 1;
}

stock Duel_CalculateElo(winnerid, loserid, &winnerDelta, &loserDelta)
{
    new Float:difference = float(gDuelElo[loserid] - gDuelElo[winnerid]) / 400.0;
    new Float:expected = 1.0 / (1.0 + floatpower(10.0, difference));
    winnerDelta = floatround(float(DUEL_ELO_K) * (1.0 - expected), floatround_round);
    if(winnerDelta < 1) winnerDelta = 1;
    loserDelta = winnerDelta;
    return 1;
}

forward Duel_Unfreeze(player1, player2);
public Duel_Unfreeze(player1, player2)
{
    if(!IsPlayerConnected(player1) || !IsPlayerConnected(player2)) return 1;
    if(gDuelState[player1] != DUEL_STATE_FIGHT || gDuelState[player2] != DUEL_STATE_FIGHT) return 1;

    TogglePlayerControllable(player1, true);
    TogglePlayerControllable(player2, true);
    GameTextForPlayer(player1, "~g~FIGHT!", 1500, 3);
    GameTextForPlayer(player2, "~g~FIGHT!", 1500, 3);
    return 1;
}

stock Duel_Start(player1, player2)
{
    if(!IsPlayerConnected(player1) || !IsPlayerConnected(player2)) return 0;

    new bet = gDuelBet[player1];
    new weapon = gDuelWeapon[player1];

    if(IsPlayerInAnyVehicle(player1) || IsPlayerInAnyVehicle(player2))
    {
        SendClientMessage(player1, DUEL_ERROR, "Один из игроков находится в транспорте.");
        SendClientMessage(player2, DUEL_ERROR, "Один из игроков находится в транспорте.");
        Duel_Reset(player1);
        Duel_Reset(player2);
        return 0;
    }

    if(Duel_GetMoney(player1) < bet || Duel_GetMoney(player2) < bet)
    {
        SendClientMessage(player1, DUEL_ERROR, "У одного из игроков недостаточно денег для ставки.");
        SendClientMessage(player2, DUEL_ERROR, "У одного из игроков недостаточно денег для ставки.");
        Duel_Reset(player1);
        Duel_Reset(player2);
        return 0;
    }

    if(bet > 0)
    {
        Duel_AddMoney(player1, -bet);
        Duel_AddMoney(player2, -bet);
    }

    Duel_SavePlayerState(player1);
    Duel_SavePlayerState(player2);

    gDuelWorldCounter++;
    if(gDuelWorldCounter > 200000) gDuelWorldCounter = DUEL_WORLD_START;
    new world = gDuelWorldCounter;

    gDuelWorld[player1] = world;
    gDuelWorld[player2] = world;
    gDuelState[player1] = DUEL_STATE_FIGHT;
    gDuelState[player2] = DUEL_STATE_FIGHT;
    gDuelOpponent[player1] = player2;
    gDuelOpponent[player2] = player1;
    gDuelWeapon[player2] = weapon;
    gDuelBet[player2] = bet;

    SetPlayerVirtualWorld(player1, world);
    SetPlayerVirtualWorld(player2, world);
    SetPlayerInterior(player1, 0);
    SetPlayerInterior(player2, 0);
    SetPlayerPos(player1, DUEL_P1_X, DUEL_P1_Y, DUEL_P1_Z);
    SetPlayerFacingAngle(player1, DUEL_P1_A);
    SetPlayerPos(player2, DUEL_P2_X, DUEL_P2_Y, DUEL_P2_Z);
    SetPlayerFacingAngle(player2, DUEL_P2_A);

    ResetPlayerWeapons(player1);
    ResetPlayerWeapons(player2);
    GivePlayerWeapon(player1, weapon, 9999);
    GivePlayerWeapon(player2, weapon, 9999);
    SetPlayerHealth(player1, 100.0);
    SetPlayerHealth(player2, 100.0);
    SetPlayerArmour(player1, 0.0);
    SetPlayerArmour(player2, 0.0);
    TogglePlayerControllable(player1, false);
    TogglePlayerControllable(player2, false);
    GameTextForPlayer(player1, "~w~DUEL~n~~y~GET READY", 3000, 3);
    GameTextForPlayer(player2, "~w~DUEL~n~~y~GET READY", 3000, 3);
    SetTimerEx("Duel_Unfreeze", 3000, false, "dd", player1, player2);
    return 1;
}

stock Duel_AddHistory(winner, loser, weapon, bet, winnerBefore, winnerAfter, loserBefore, loserAfter)
{
    new winnerName[MAX_PLAYER_NAME + 1], loserName[MAX_PLAYER_NAME + 1], query[1000];
    Duel_GetName(winner, winnerName, sizeof(winnerName));
    Duel_GetName(loser, loserName, sizeof(loserName));

    mysql_format(DUEL_DB, query, sizeof(query),
        "INSERT INTO duel_history (player1_id,player2_id,player1_name,player2_name,winner_id,weapon,bet,winner_elo_before,winner_elo_after,loser_elo_before,loser_elo_after) VALUES (%d,%d,'%e','%e',%d,%d,%d,%d,%d,%d,%d)",
        Duel_GetAccountID(winner), Duel_GetAccountID(loser), winnerName, loserName, Duel_GetAccountID(winner), weapon, bet, winnerBefore, winnerAfter, loserBefore, loserAfter);
    mysql_tquery(DUEL_DB, query);
    return 1;
}

stock Duel_Finish(winner, loser, bool:loserDisconnected = false)
{
    if(!IsPlayerConnected(winner)) return 0;

    new bet = gDuelBet[winner], weapon = gDuelWeapon[winner];
    new winnerEloBefore = gDuelElo[winner], loserEloBefore = gDuelElo[loser];
    new gain, loss;
    Duel_CalculateElo(winner, loser, gain, loss);

    gDuelElo[winner] += gain;
    gDuelElo[loser] -= loss;
    if(gDuelElo[loser] < 0) gDuelElo[loser] = 0;

    gDuelWins[winner]++;
    gDuelSeasonWins[winner]++;
    gDuelMatches[winner]++;
    gDuelLosses[loser]++;
    gDuelSeasonLosses[loser]++;
    gDuelMatches[loser]++;

    if(bet > 0) Duel_AddMoney(winner, bet * 2);

    Duel_AddHistory(winner, loser, weapon, bet, winnerEloBefore, gDuelElo[winner], loserEloBefore, gDuelElo[loser]);
    Duel_SaveStats(winner);
    Duel_SaveStats(loser);

    new winnerName[MAX_PLAYER_NAME + 1], loserName[MAX_PLAYER_NAME + 1], string[256];
    Duel_GetName(winner, winnerName, sizeof(winnerName));
    Duel_GetName(loser, loserName, sizeof(loserName));

    format(string, sizeof(string), "DUEL: Вы победили %s | +%d ELO | выигрыш: %d руб.", loserName, gain, bet * 2);
    SendClientMessage(winner, DUEL_GREEN, string);

    if(!loserDisconnected && IsPlayerConnected(loser))
    {
        format(string, sizeof(string), "DUEL: Вы проиграли %s | -%d ELO.", winnerName, loss);
        SendClientMessage(loser, DUEL_ERROR, string);
    }

    gDuelState[winner] = DUEL_STATE_NONE;
    gDuelOpponent[winner] = INVALID_PLAYER_ID;
    gDuelState[loser] = DUEL_STATE_NONE;
    gDuelOpponent[loser] = INVALID_PLAYER_ID;

    Duel_RestorePlayer(winner);

    if(!loserDisconnected && IsPlayerConnected(loser))
    {
        gDuelRestoreAfterSpawn[loser] = true;
        SpawnPlayer(loser);
    }
    return 1;
}

CMD:duel(playerid, params[])
{
    if(!gDuelStatsLoaded[playerid])
        return SendClientMessage(playerid, DUEL_ERROR, "Статистика дуэлей ещё не загружена.");

    if(gDuelState[playerid] != DUEL_STATE_NONE)
        return SendClientMessage(playerid, DUEL_ERROR, "Вы уже участвуете в дуэли или отправили вызов.");

    new target;
    if(sscanf(params, "u", target))
        return SendClientMessage(playerid, DUEL_WHITE, "Используйте: /duel [ID игрока]");

    if(target == playerid)
        return SendClientMessage(playerid, DUEL_ERROR, "Нельзя вызвать на дуэль самого себя.");

    if(!IsPlayerConnected(target))
        return SendClientMessage(playerid, DUEL_ERROR, "Игрок не найден.");

    if(gDuelState[target] != DUEL_STATE_NONE)
        return SendClientMessage(playerid, DUEL_ERROR, "Этот игрок уже занят дуэлью.");

    if(IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, DUEL_ERROR, "Выйдите из транспорта.");

    gDuelOpponent[playerid] = target;
    gDuelState[playerid] = DUEL_STATE_SETUP;

    ShowPlayerDialog(playerid, DIALOG_DUEL_WEAPON, DIALOG_STYLE_LIST,
        "Дуэль | Выбор оружия",
        "Desert Eagle\nShotgun\nMP5\nAK-47\nM4\nRifle",
        "Выбрать", "Отмена");
    return 1;
}

CMD:duelstats(playerid, params[])
{
    new target = playerid;
    if(strlen(params)) if(sscanf(params, "u", target)) target = playerid;
    if(!IsPlayerConnected(target)) return 1;

    new division[16], name[MAX_PLAYER_NAME + 1], text[512];
    Duel_GetDivision(gDuelElo[target], division, sizeof(division));
    Duel_GetName(target, name, sizeof(name));

    format(text, sizeof(text),
        "{FFFFFF}Игрок:\t{E5B64A}%s\n{FFFFFF}ELO:\t{E5B64A}%d\n{FFFFFF}Дивизион:\t{E5B64A}%s\n\n{FFFFFF}Побед:\t{2ECC71}%d\n{FFFFFF}Поражений:\t{E74C3C}%d\n{FFFFFF}Всего матчей:\t%d\n\n{FFFFFF}Побед в сезоне:\t%d\n{FFFFFF}Поражений в сезоне:\t%d",
        name, gDuelElo[target], division, gDuelWins[target], gDuelLosses[target], gDuelMatches[target], gDuelSeasonWins[target], gDuelSeasonLosses[target]);

    ShowPlayerDialog(playerid, DIALOG_DUEL_STATS, DIALOG_STYLE_MSGBOX, "DUEL | Статистика", text, "Закрыть", "");
    return 1;
}

CMD:duelhistory(playerid, params[])
{
    new accountid = Duel_GetAccountID(playerid), query[800];
    mysql_format(DUEL_DB, query, sizeof(query),
        "SELECT IF(player1_id=%d,player2_name,player1_name) AS opponent,winner_id,weapon,bet,DATE_FORMAT(created_at,'%%d.%%m %%H:%%i') AS match_date FROM duel_history WHERE player1_id=%d OR player2_id=%d ORDER BY id DESC LIMIT 10",
        accountid, accountid, accountid);
    mysql_tquery(DUEL_DB, query, "Duel_OnHistoryLoaded", "dd", playerid, accountid);
    return 1;
}

forward Duel_OnHistoryLoaded(playerid, accountid);
public Duel_OnHistoryLoaded(playerid, accountid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    new rows = cache_num_rows();

    if(!rows)
        return ShowPlayerDialog(playerid, DIALOG_DUEL_HISTORY, DIALOG_STYLE_MSGBOX, "DUEL | История", "Вы ещё не участвовали в дуэлях.", "Закрыть", "");

    new text[2000];
    format(text, sizeof(text), "Результат\tСоперник\tОружие\tСтавка\tДата\n");

    for(new row = 0; row < rows; row++)
    {
        new opponent[MAX_PLAYER_NAME + 1], date[32], winnerid, weaponid, bet, weaponName[32], line[180];
        cache_get_value_name(row, "opponent", opponent, sizeof(opponent));
        cache_get_value_name(row, "match_date", date, sizeof(date));
        cache_get_value_name_int(row, "winner_id", winnerid);
        cache_get_value_name_int(row, "weapon", weaponid);
        cache_get_value_name_int(row, "bet", bet);
        Duel_GetWeaponName(weaponid, weaponName, sizeof(weaponName));

        format(line, sizeof(line), "%s\t%s\t%s\t%d\t%s\n", (winnerid == accountid) ? "{2ECC71}WIN" : "{E74C3C}LOSE", opponent, weaponName, bet, date);
        strcat(text, line, sizeof(text));
    }

    ShowPlayerDialog(playerid, DIALOG_DUEL_HISTORY, DIALOG_STYLE_TABLIST_HEADERS, "DUEL | Последние матчи", text, "Закрыть", "");
    return 1;
}

CMD:duelreward(playerid, params[])
{
    if(gDuelRewardQuery[playerid]) return 1;
    gDuelRewardQuery[playerid] = true;

    new query[400];
    mysql_format(DUEL_DB, query, sizeof(query), "SELECT id,season_id,division,elo,reward FROM duel_rewards WHERE account_id=%d AND claimed=0 ORDER BY season_id ASC LIMIT 1", Duel_GetAccountID(playerid));
    mysql_tquery(DUEL_DB, query, "Duel_OnRewardLoaded", "d", playerid);
    return 1;
}

forward Duel_OnRewardLoaded(playerid);
public Duel_OnRewardLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    gDuelRewardQuery[playerid] = false;

    if(!cache_num_rows())
        return SendClientMessage(playerid, DUEL_GRAY, "У вас нет доступных сезонных наград.");

    new rewardid, seasonid, elo, reward, division[16];
    cache_get_value_name_int(0, "id", rewardid);
    cache_get_value_name_int(0, "season_id", seasonid);
    cache_get_value_name_int(0, "elo", elo);
    cache_get_value_name_int(0, "reward", reward);
    cache_get_value_name(0, "division", division, sizeof(division));

    new query[300];
    mysql_format(DUEL_DB, query, sizeof(query), "UPDATE duel_rewards SET claimed=1 WHERE id=%d AND account_id=%d", rewardid, Duel_GetAccountID(playerid));
    mysql_tquery(DUEL_DB, query);

    Duel_AddMoney(playerid, reward);

    new string[256];
    format(string, sizeof(string), "DUEL: Награда за сезон #%d | %s | ELO: %d | +%d руб.", seasonid, division, elo, reward);
    SendClientMessage(playerid, DUEL_GREEN, string);
    return 1;
}

stock Duel_CloseSeason(seasonid)
{
    new query[1500];
    mysql_format(DUEL_DB, query, sizeof(query),
        "INSERT INTO duel_rewards (account_id,season_id,division,elo,reward) SELECT account_id,%d,CASE WHEN elo >= %d THEN 'Gold' WHEN elo >= %d THEN 'Silver' ELSE 'Bronze' END,elo,CASE WHEN elo >= %d THEN %d WHEN elo >= %d THEN %d ELSE %d END FROM duel_stats WHERE matches > 0 ON DUPLICATE KEY UPDATE account_id=account_id",
        seasonid, DUEL_ELO_GOLD, DUEL_ELO_SILVER, DUEL_ELO_GOLD, DUEL_GOLD_REWARD, DUEL_ELO_SILVER, DUEL_SILVER_REWARD, DUEL_BRONZE_REWARD);
    mysql_tquery(DUEL_DB, query);
    mysql_tquery(DUEL_DB, "UPDATE duel_stats SET elo=1000,season_wins=0,season_losses=0");

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        gDuelElo[i] = DUEL_ELO_DEFAULT;
        gDuelSeasonWins[i] = 0;
        gDuelSeasonLosses[i] = 0;
    }
    return 1;
}

forward Duel_InviteTimeout(player1, player2);
public Duel_InviteTimeout(player1, player2)
{
    if(IsPlayerConnected(player1) && gDuelState[player1] == DUEL_STATE_OUTGOING && gDuelOpponent[player1] == player2)
    {
        SendClientMessage(player1, DUEL_GRAY, "Вызов на дуэль истёк.");
        Duel_Reset(player1);
    }

    if(IsPlayerConnected(player2) && gDuelState[player2] == DUEL_STATE_INCOMING && gDuelOpponent[player2] == player1)
    {
        SendClientMessage(player2, DUEL_GRAY, "Вызов на дуэль истёк.");
        Duel_Reset(player2);
    }
    return 1;
}

stock Duel_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_DUEL_WEAPON)
    {
        if(!response) { Duel_Reset(playerid); return 1; }
        if(gDuelState[playerid] != DUEL_STATE_SETUP) return 1;

        gDuelWeapon[playerid] = Duel_GetWeaponFromList(listitem);
        ShowPlayerDialog(playerid, DIALOG_DUEL_BET, DIALOG_STYLE_INPUT,
            "Дуэль | Ставка",
            "{FFFFFF}Введите сумму ставки.\nДеньги будут сняты у обоих игроков\nтолько после принятия вызова.\n\n{E5B64A}Введите 0 для игры без ставки.",
            "Продолжить", "Назад");
        return 1;
    }

    if(dialogid == DIALOG_DUEL_BET)
    {
        if(!response) { Duel_Reset(playerid); return 1; }
        if(gDuelState[playerid] != DUEL_STATE_SETUP) return 1;

        new bet = strval(inputtext);
        if(bet < DUEL_MIN_BET || bet > DUEL_MAX_BET)
            return ShowPlayerDialog(playerid, DIALOG_DUEL_BET, DIALOG_STYLE_INPUT, "Дуэль | Ошибка", "{E74C3C}Некорректная ставка.\n\n{FFFFFF}Введите другую сумму:", "Продолжить", "Отмена");

        if(Duel_GetMoney(playerid) < bet)
            return ShowPlayerDialog(playerid, DIALOG_DUEL_BET, DIALOG_STYLE_INPUT, "Дуэль | Недостаточно денег", "{E74C3C}У вас недостаточно средств.\n\n{FFFFFF}Введите меньшую ставку:", "Продолжить", "Отмена");

        new target = gDuelOpponent[playerid];
        if(target == INVALID_PLAYER_ID || !IsPlayerConnected(target))
        {
            Duel_Reset(playerid);
            SendClientMessage(playerid, DUEL_ERROR, "Игрок вышел с сервера.");
            return 1;
        }

        if(gDuelState[target] != DUEL_STATE_NONE)
        {
            Duel_Reset(playerid);
            SendClientMessage(playerid, DUEL_ERROR, "Игрок уже участвует в другой дуэли.");
            return 1;
        }

        gDuelBet[playerid] = bet;
        gDuelState[playerid] = DUEL_STATE_OUTGOING;
        gDuelState[target] = DUEL_STATE_INCOMING;
        gDuelOpponent[target] = playerid;
        gDuelWeapon[target] = gDuelWeapon[playerid];
        gDuelBet[target] = bet;

        new playerName[MAX_PLAYER_NAME + 1], weaponName[32], text[600];
        Duel_GetName(playerid, playerName, sizeof(playerName));
        Duel_GetWeaponName(gDuelWeapon[playerid], weaponName, sizeof(weaponName));

        format(text, sizeof(text),
            "{FFFFFF}Игрок {E5B64A}%s {FFFFFF}вызывает вас на дуэль.\n\n{FFFFFF}Оружие: {E5B64A}%s\n{FFFFFF}Ставка с каждого: {2ECC71}%d руб.\n{FFFFFF}Общий банк: {2ECC71}%d руб.\n\n{AAAAAA}При победе весь банк получает победитель.",
            playerName, weaponName, bet, bet * 2);

        ShowPlayerDialog(target, DIALOG_DUEL_INVITE, DIALOG_STYLE_MSGBOX, "Вызов на дуэль", text, "Принять", "Отказать");
        SendClientMessage(playerid, DUEL_GREEN, "Вызов отправлен. Ожидание ответа...");
        SetTimerEx("Duel_InviteTimeout", 20000, false, "dd", playerid, target);
        return 1;
    }

    if(dialogid == DIALOG_DUEL_INVITE)
    {
        if(gDuelState[playerid] != DUEL_STATE_INCOMING) return 1;

        new challenger = gDuelOpponent[playerid];
        if(challenger == INVALID_PLAYER_ID || !IsPlayerConnected(challenger))
        {
            Duel_Reset(playerid);
            return SendClientMessage(playerid, DUEL_ERROR, "Игрок больше недоступен.");
        }

        if(!response)
        {
            SendClientMessage(challenger, DUEL_ERROR, "Игрок отказался от дуэли.");
            SendClientMessage(playerid, DUEL_GRAY, "Вы отказались от дуэли.");
            Duel_Reset(challenger);
            Duel_Reset(playerid);
            return 1;
        }

        if(Duel_GetMoney(playerid) < gDuelBet[playerid])
        {
            SendClientMessage(playerid, DUEL_ERROR, "У вас недостаточно денег для ставки.");
            SendClientMessage(challenger, DUEL_ERROR, "У соперника недостаточно денег.");
            Duel_Reset(challenger);
            Duel_Reset(playerid);
            return 1;
        }

        Duel_Start(challenger, playerid);
        return 1;
    }
    return 0;
}

stock Duel_OnPlayerDeath(playerid, killerid)
{
    if(gDuelState[playerid] != DUEL_STATE_FIGHT) return 0;

    new opponent = gDuelOpponent[playerid];
    if(opponent == INVALID_PLAYER_ID || !IsPlayerConnected(opponent))
    {
        Duel_Reset(playerid);
        return 1;
    }

    Duel_Finish(opponent, playerid);
    return 1;
}

stock Duel_OnPlayerSpawn(playerid)
{
    if(!gDuelRestoreAfterSpawn[playerid]) return 0;
    gDuelRestoreAfterSpawn[playerid] = false;
    Duel_RestorePlayer(playerid);
    return 1;
}

stock Duel_OnPlayerDisconnect(playerid)
{
    new opponent = gDuelOpponent[playerid];

    if(gDuelState[playerid] == DUEL_STATE_FIGHT && opponent != INVALID_PLAYER_ID && IsPlayerConnected(opponent))
    {
        Duel_Finish(opponent, playerid, true);
        return 1;
    }

    if(opponent != INVALID_PLAYER_ID && IsPlayerConnected(opponent))
    {
        if(gDuelState[opponent] == DUEL_STATE_OUTGOING || gDuelState[opponent] == DUEL_STATE_INCOMING)
        {
            SendClientMessage(opponent, DUEL_GRAY, "Вызов отменён: игрок вышел с сервера.");
            Duel_Reset(opponent);
        }
    }

    Duel_Reset(playerid);
    return 1;
}
