
new evro;

enum E_PLAYER_DATA
{
    P_EVRO,
    P_RUB,
    P_EVRO_BOUGHT
}

enum E_DIALOG_IDS
{
    DIALOG_UNUSED = 32700
}

new MySQL:g_SQL;

CMD:give_evro(playerid, params[])
{
    new to_player, amount;
    if(sscanf(params, "ud", to_player, amount))
        return SendClientMessage(playerid, 0x999999FF, "Используйте: /give_evro [id игрока] [кол-во]");

    if(GetPlayerAdminEx(playerid) < 7) return 0;

    if(amount <= 0)
        return SendClientMessage(playerid, 0xCECECEFF, "{FF6347} Количество должно быть больше 0");

    if(amount > 500)
        return SendClientMessage(playerid, 0xCECECEFF, "{FF6347} Нельзя больше 500 за раз");

    if(!IsPlayerConnected(to_player) || !IsPlayerLogged(to_player))
        return SendClientMessage(playerid, 0xCECECEFF, "{FF6347} Игрок не в сети!");

    new target_name[MAX_PLAYER_NAME];
    GetPlayerName(to_player, target_name, sizeof(target_name));

    new admin_name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, admin_name, sizeof(admin_name));

    SetPlayerData(to_player, P_EVRO, GetPlayerData(to_player, P_EVRO) + amount);
    UpdatePlayerDatabaseInt(to_player, "evro", GetPlayerData(to_player, P_EVRO));

    new str[144];
    format(str, sizeof(str), "{FFFFFF} Вы выдали %d евро игроку %s", amount, target_name);
    SendClientMessage(playerid, -1, str);

    format(str, sizeof(str), "{FFFFFF} Администратор %s выдал вам %d евро", admin_name, amount);
    SendClientMessage(to_player, -1, str);

    return 1;
}

CMD:info_evro(playerid)
{
    new str[128];
    format(str, sizeof(str), "Количество EVRO: %d", GetPlayerData(playerid, P_EVRO));
    SendClientMessage(playerid, 0xCECECEFF, str);
    return 1;
}

CMD:exchange(playerid, params[])
{
    new amount, type_str[16];

    if(sscanf(params, "s[16]d", type_str, amount))
        return SendClientMessage(playerid, 0x999999FF, "Используйте: /exchange [buy/sell/rate] [кол-во]");

    if(amount <= 0)
        return SendClientMessage(playerid, 0xCECECEFF, "{FF6347} Количество должно быть больше 0");

    if(amount > 500)
        return SendClientMessage(playerid, 0xCECECEFF, "{FF6347} За раз не больше 500");

    if(!strcmp(type_str, "buy", true))
    {
        new need_rub = amount * 100;
        new cur_rub = GetPlayerData(playerid, P_RUB);

        if(cur_rub < need_rub)
            return SendClientMessage(playerid, 0xCECECEFF, "{FF6347} Недостаточно рублей для покупки");

        SetPlayerData(playerid, P_RUB, cur_rub - need_rub);
        UpdatePlayerDatabaseInt(playerid, "rub", GetPlayerData(playerid, P_RUB));

        SetPlayerData(playerid, P_EVRO, GetPlayerData(playerid, P_EVRO) + amount);
        UpdatePlayerDatabaseInt(playerid, "evro", GetPlayerData(playerid, P_EVRO));

        SetPlayerData(playerid, P_EVRO_BOUGHT, GetPlayerData(playerid, P_EVRO_BOUGHT) + amount);
        UpdatePlayerDatabaseInt(playerid, "evro_bought", GetPlayerData(playerid, P_EVRO_BOUGHT));

        new str[160];
        format(str, sizeof(str), "{FFFFFF} Вы купили %d евро за %d рублей", amount, need_rub);
        SendClientMessage(playerid, -1, str);

        format(str, sizeof(str), "{FFFFFF} Курс: 1 евро = 100 рублей | Баланс евро: %d", GetPlayerData(playerid, P_EVRO));
        SendClientMessage(playerid, -1, str);
    }
    else if(!strcmp(type_str, "sell", true))
    {
        new cur_evro = GetPlayerData(playerid, P_EVRO);
        if(cur_evro < amount)
            return SendClientMessage(playerid, 0xCECECEFF, "{FF6347} У вас нет столько евро");

        new get_rub = amount * 100;

        SetPlayerData(playerid, P_EVRO, cur_evro - amount);
        UpdatePlayerDatabaseInt(playerid, "evro", GetPlayerData(playerid, P_EVRO));

        SetPlayerData(playerid, P_RUB, GetPlayerData(playerid, P_RUB) + get_rub);
        UpdatePlayerDatabaseInt(playerid, "rub", GetPlayerData(playerid, P_RUB));

        new str[160];
        format(str, sizeof(str), "{FFFFFF} Вы продали %d евро и получили %d рублей", amount, get_rub);
        SendClientMessage(playerid, -1, str);

        format(str, sizeof(str), "{FFFFFF} Курс: 1 евро = 100 рублей | Баланс евро: %d", GetPlayerData(playerid, P_EVRO));
        SendClientMessage(playerid, -1, str);
    }
    else if(!strcmp(type_str, "rate", true))
    {
        new str[160];
        format(str, sizeof(str), "{FFFFFF} Текущий курс: 1 евро = 100 рублей | Лимит за операцию: 500");
        SendClientMessage(playerid, -1, str);
    }
    else
    {
        SendClientMessage(playerid, 0x999999FF, "Используйте: /exchange [buy/sell/rate] [кол-во]");
    }

    return 1;
}

CMD:evrotop(playerid)
{
    new query[128];
    mysql_format(g_SQL, query, sizeof(query), "SELECT name, evro_bought FROM `players` ORDER BY evro_bought DESC LIMIT 10");
    mysql_tquery(g_SQL, query, "ShowEvroTop", "i", playerid);
    return 1;
}

forward ShowEvroTop(playerid);
public ShowEvroTop(playerid)
{
    new rows = cache_num_rows();
    if(rows == 0)
        return SendClientMessage(playerid, 0xCECECEFF, "{FF6347} Топ пока пуст");

    new header[64];
    format(header, sizeof(header), "{FFFF00}Топ %d покупателей евро", rows);

    new str[(64 + 24) * 20];
    str[0] = EOS;
    strcat(str, header);
    strcat(str, "\n\n");

    new line[64], name[MAX_PLAYER_NAME], evro_bought, pos;
    for(new i = 0; i < rows; i++)
    {
        cache_get_value_name(i, "name", name, sizeof(name));
        cache_get_value_name_int(i, "evro_bought", evro_bought);
        pos = i + 1;

        if(pos == 1)      format(line, sizeof(line), "{FFD700}#1. %s - %d evro\n", name, evro_bought);
        else if(pos == 2) format(line, sizeof(line), "{C0C0C0}#2. %s - %d evro\n", name, evro_bought);
        else if(pos == 3) format(line, sizeof(line), "{CD7F32}#3. %s - %d evro\n", name, evro_bought);
        else              format(line, sizeof(line), "{FFFFFF}#%d. %s - %d evro\n", pos, name, evro_bought);

        strcat(str, line);
    }

    strcat(str, "\n{999999}Обновлено: ");
    new date_str[3], time_str[3];
    getdate(date_str[0], date_str[1], date_str[2]);
    gettime(time_str[0], time_str[1], time_str[2]);
    format(line, sizeof(line), "%02d/%02d/%04d %02d:%02d", date_str[0], date_str[1], date_str[2], time_str[0], time_str[1]);
    strcat(str, line);

    ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "{FFCC00}Топ покупателей евро", str, "Закрыть", "");
    return 1;
}
