#if defined _fractiongui_included
    #endinput
#endif
#define _fractiongui_included

#define FRACGUIID 46
#define FRACDOCMAX 32

#if !defined NOTIFICATION_ID_FRAC_INVITE
    #define NOTIFICATION_ID_FRAC_INVITE (1306)
#endif

forward Fracdocsload(playerid, teamid);
forward Fracctrlload(playerid, teamid);
forward Fracplayerdb(playerid, uid, teamid);
forward Fracplayeract(playerid, uid, actionid, changeid, teamid);
forward FracTokensLoad(playerid, accountid, pageid, openid);
forward FracQuestStartLoad(playerid, accountid, taskid, required, rewardmoney, rewardtokens);

new fracpayload[16384];
new fracpiece[512];
new fracname[64];
new fracescaped[128];
new fracnp[8192];
new fracrs[8192];
new fracchosen[MAX_PLAYERS];
new fracdocs[FRACDOCMAX];
new fractestdoc[MAX_PLAYERS];
new fractestpos[MAX_PLAYERS];
new fractestok[MAX_PLAYERS];
new fractesttotal[MAX_PLAYERS];
new fractokens[MAX_PLAYERS];
new fracquestaccount[MAX_PLAYERS];
new fracquesttask[MAX_PLAYERS];
new fracquestfaction[MAX_PLAYERS];
new fracquestprogress[MAX_PLAYERS];
new fracquestrequired[MAX_PLAYERS];
new fracquestmoney[MAX_PLAYERS];
new fracquesttokens[MAX_PLAYERS];
new fracquestseconds[MAX_PLAYERS];
new bool:fracquestactive[MAX_PLAYERS];

stock Fracnotifykmonarch(playerid, sid, text[])
{
    ShowNotificationNew(playerid, 1, 4, sid, 0, text, "ОК");
    return 1;
}

CMD:givefcoins(playerid, params[])
{
    if(GetPlayerAdminEx(playerid) < 13)
        return SendClientMessage(playerid, 0x999999FF, "Команда доступна администраторам 13 уровня");

    extract params -> new to_player, amount; else
        return SendClientMessage(playerid, 0x999999FF, "Используйте: /givefcoins [id игрока] [количество]");

    if(!IsPlayerConnected(to_player) || !IsPlayerLogged(to_player))
        return SendClientMessage(playerid, 0x999999FF, "Игрок не найден или не авторизован");

    if(amount <= 0 || amount > 1000000)
        return SendClientMessage(playerid, 0x999999FF, "Количество должно быть от 1 до 1 000 000");

    if(fractokens[to_player] > 2147483647 - amount)
        return SendClientMessage(playerid, 0x999999FF, "Баланс фракционных монет игрока переполнен");

    if(!FracAddTokenskmonarch(to_player, amount))
        return SendClientMessage(playerid, 0x999999FF, "Не удалось выдать фракционные монеты");

    new message[160];
    format(message, sizeof message, "Вы выдали игроку %s %d фракционных монет. Новый баланс: %d.",
        GetPlayerNameEx(to_player), amount, fractokens[to_player]);
    SendClientMessage(playerid, 0xFFFF00FF, message);

    format(message, sizeof message, "Администратор %s выдал Вам %d фракционных монет. Новый баланс: %d.",
        GetPlayerNameEx(playerid), amount, fractokens[to_player]);
    SendClientMessage(to_player, 0x3399FFFF, message);

    printf("[ADMIN][GIVEFCOINS] admin=%s(%d) target=%s(%d) amount=%d balance=%d",
        GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(to_player), to_player, amount, fractokens[to_player]);
    return 1;
}

stock FracInviteSend(playerid, to_player)
{
    if (GetPlayerTeamEx(playerid) < 1 || GetPlayerTeamEx(playerid) >= MAX_ORG)
    {
        return SendClientMessage(playerid, 0x999999FF, "Вам недоступна данная функция");
    }

    if (GetPlayerJob(playerid) != 10)
    {
        return SendClientMessage(playerid, 0xCECECEFF, "Функция доступна только лидеру фракции");
    }

    if (!IsPlayerConnected(to_player) || !IsPlayerLogged(to_player) || to_player == playerid)
    {
        return SendClientMessage(playerid, 0xCECECEFF, "Такого игрока нет");
    }

    if (GetPlayerTeamEx(to_player) >= 1 && GetPlayerTeamEx(to_player) < MAX_ORG)
    {
        return SendClientMessage(playerid, 0xCECECEFF, "Этот игрок уже состоит в организации");
    }

    if (GetPlayerData(to_player, P_WARN))
    {
        return SendClientMessage(playerid, 0xCECECEFF, "У игрока есть предупреждения");
    }

    if (!IsPlayerInRangeOfPlayer(playerid, to_player, 10.0))
    {
        return SendClientMessage(playerid, 0xCECECEFF, "Игрок находится слишком далеко");
    }

    if (GetPlayerOfferInfo(playerid, O_OUTCOMIG_PLAYER) != INVALID_PLAYER_ID)
    {
        return SendClientMessage(playerid, 0xFFFFFFFF, "Используйте {FF9900}/cancel {FFFFFF}чтобы отозвать предыдущее предложение");
    }

    SendPlayerOffer(playerid, to_player, OFFER_TYPE_INVITE);

    new caption[160];
    format(caption, sizeof(caption), "%s приглашает Вас во фракцию \"%s\"", GetPlayerNameEx(playerid), GetPlayerTeamName(playerid));
    ShowNotificationNew(to_player, 4, 6, NOTIFICATION_ID_FRAC_INVITE, playerid, caption, "Да");
    return 1;
}

stock FracInviteAccept(playerid, inviterid)
{
    new offer_id = GetPlayerOfferInfo(playerid, O_INCOMING_PLAYER);
    new offer_type = GetPlayerOfferInfo(playerid, O_INCOMING_TYPE);

    if (offer_id == INVALID_PLAYER_ID || offer_type != OFFER_TYPE_INVITE || offer_id != inviterid)
    {
        ClearPlayerOffer(playerid);
        return Fracnotifykmonarch(playerid, 4611, "Приглашение во фракцию уже не активно");
    }

    if (!IsPlayerConnected(offer_id) || !IsPlayerLogged(offer_id))
    {
        ClearPlayerOffer(playerid);
        return Fracnotifykmonarch(playerid, 4612, "Лидер вышел из игры");
    }

    if (GetPlayerOfferInfo(offer_id, O_OUTCOMIG_PLAYER) != playerid)
    {
        ClearPlayerOffer(playerid);
        return Fracnotifykmonarch(playerid, 4613, "Приглашение во фракцию уже не активно");
    }

    new teamid = GetPlayerTeamEx(offer_id);
    if (teamid < 1 || teamid >= MAX_ORG)
    {
        ClearPlayerOffer(offer_id);
        ClearPlayerOffer(playerid);
        return Fracnotifykmonarch(playerid, 4614, "Фракция лидера не найдена");
    }

    if (GetPlayerTeamEx(playerid) >= 1 && GetPlayerTeamEx(playerid) < MAX_ORG)
    {
        ClearPlayerOffer(offer_id);
        ClearPlayerOffer(playerid);
        return Fracnotifykmonarch(playerid, 4615, "Вы уже состоите в организации");
    }

    new Float:x, Float:y, Float:z;
    GetPlayerPos(offer_id, x, y, z);

    if (GetPlayerDistanceFromPoint(playerid, x, y, z) > 10.0)
    {
        ClearPlayerOffer(offer_id);
        ClearPlayerOffer(playerid);
        return Fracnotifykmonarch(playerid, 4616, "Лидер слишком далеко");
    }

    ClearPlayerOffer(offer_id);
    ClearPlayerOffer(playerid);

    InvitePlayer(playerid, teamid, 1, true);

    new msg[160];
    format(msg, sizeof(msg), "Поздравляем! Вы вступили во фракцию \"%s\"", GetTeamName(teamid));
    SendClientMessage(playerid, 0x66CC00FF, msg);

    format(msg, sizeof(msg), "%s принял приглашение во фракцию", GetPlayerNameEx(playerid));
    SendClientMessage(offer_id, 0x66CC00FF, msg);
    GameTextForPlayer(offer_id, "~b~~h~yes", 4000, 1);

    format(msg, sizeof(msg), "Принял %s[acc:%d] во фракцию %s", GetPlayerNameEx(playerid), GetPlayerAccountID(playerid), GetTeamName(teamid));
    SendLog(offer_id, LOG_TYPE_FRACTION, msg);
    Fracmainkmonarch(playerid, 1);
    return 1;
}

stock FracInviteDecline(playerid, inviterid)
{
    new offer_id = GetPlayerOfferInfo(playerid, O_INCOMING_PLAYER);
    new offer_type = GetPlayerOfferInfo(playerid, O_INCOMING_TYPE);

    if (offer_id != INVALID_PLAYER_ID && offer_type == OFFER_TYPE_INVITE && offer_id == inviterid)
    {
        if (GetPlayerOfferInfo(offer_id, O_OUTCOMIG_PLAYER) == playerid)
        {
            ClearPlayerOffer(offer_id);

            new msg[96];
            format(msg, sizeof(msg), "%s отказался от приглашения во фракцию", GetPlayerNameEx(playerid));
            SendClientMessage(offer_id, 0xFF6600FF, msg);
            GameTextForPlayer(offer_id, "~r~no", 4000, 1);
        }
    }

    ClearPlayerOffer(playerid);
    return 1;
}
stock Fracfractionidkmonarch(teamid)
{
    switch (teamid)
    {
        case 1..7, 11: return teamid;
    }

    return 0;
}

stock Fracesckmonarch(const source[], destination[], size)
{
    new w = 0;

    for (new r = 0; source[r] != '\0' && w < size - 1; r++)
    {
        switch (source[r])
        {
            case '\\', '"':
            {
                if (w >= size - 2)
                {
                    break;
                }

                destination[w++] = '\\';
                destination[w++] = source[r];
            }
            case '\n':
            {
                if (w >= size - 2)
                {
                    break;
                }

                destination[w++] = '\\';
                destination[w++] = 'n';
            }
            case '\r':
            {
                if (w >= size - 2)
                {
                    break;
                }

                destination[w++] = '\\';
                destination[w++] = 'r';
            }
            case '\t':
            {
                if (w >= size - 2)
                {
                    break;
                }

                destination[w++] = '\\';
                destination[w++] = 't';
            }
            default: destination[w++] = source[r];
        }
    }

    destination[w] = '\0';
    return 1;
}

stock Fracsendkmonarch(playerid, const payload[])
{
    new BitStream:bitstream = BS_New();

    BS_WriteValue(bitstream, PR_UINT8, 252);
    BS_WriteValue(bitstream, PR_UINT16, FRACGUIID);
    BS_WriteValue(bitstream, PR_UINT32, strlen(payload));
    BS_WriteValue(bitstream, PR_STRING, payload);
    PR_SendPacket(bitstream, playerid, PR_HIGH_PRIORITY, PR_RELIABLE);
    BS_Delete(bitstream);
    return 1;
}

stock Fracensurekmonarch()
{
    static bool:done = false;

    if (done)
    {
        return 1;
    }

    done = true;

    mysql_query
    (
        mysql,
        "CREATE TABLE IF NOT EXISTS `fraction_documents` (\
        `uid` INT NOT NULL,\
        `fraction_id` INT NOT NULL,\
        `document_id` INT NOT NULL DEFAULT 0,\
        `document_number` INT NOT NULL DEFAULT 0,\
        `acquainted` INT NOT NULL DEFAULT 1,\
        PRIMARY KEY (`uid`,`fraction_id`,`document_number`),\
        KEY `uid` (`uid`)\
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci",
        false
    );

    mysql_query
    (
        mysql,
        "CREATE TABLE IF NOT EXISTS `fraction_quests` (\
        `uid` INT NOT NULL,\
        `task_id` INT NOT NULL,\
        `fraction_id` INT NOT NULL,\
        `progress` INT NOT NULL DEFAULT 0,\
        `required` INT NOT NULL,\
        `reward_money` INT NOT NULL DEFAULT 0,\
        `reward_tokens` INT NOT NULL DEFAULT 0,\
        `quest_date` DATE NOT NULL,\
        `completed` TINYINT NOT NULL DEFAULT 0,\
        PRIMARY KEY (`uid`),\
        KEY `quest_date` (`quest_date`)\
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci",
        false
    );

    mysql_query
    (
        mysql,
        "CREATE TABLE IF NOT EXISTS `fraction_tokens` (\
        `uid` INT NOT NULL,\
        `tokens` INT NOT NULL DEFAULT 0,\
        PRIMARY KEY (`uid`)\
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci",
        false
    );

    return 1;
}

stock Fracfindkmonarch(const json[], const key[])
{
    new pattern[48];
    format(pattern, sizeof(pattern), "\"%s\":", key);

    new plen = strlen(pattern);
    new jlen = strlen(json);

    for (new i = 0; i <= jlen - plen; i++)
    {
        if (!strcmp(json[i], pattern, true, plen))
        {
            i += plen;

            while (json[i] == ' ' || json[i] == '\t')
            {
                i++;
            }

            return i;
        }
    }

    return -1;
}

stock bool:Fracintkmonarch(const json[], const key[], &value)
{
    new pos = Fracfindkmonarch(json, key);
    if (pos == -1)
    {
        return false;
    }//автор системы kmonarch/@lilmorphe/@werixtonstudio

    new sign = 1;
    if (json[pos] == '-')
    {
        sign = -1;
        pos++;
    }

    if (!(json[pos] >= '0' && json[pos] <= '9'))
    {
        return false;
    }

    value = 0;

    while (json[pos] >= '0' && json[pos] <= '9')
    {
        value = (value * 10) + (json[pos] - '0');
        pos++;
    }

    value *= sign;
    return true;
}

stock Fracutfkmonarch(const source[], destination[], size)
{
    new r = 0;
    new w = 0;

    while (source[r] != '\0' && w < size - 1)
    {
        new cur = source[r] & 0xFF;

        if (cur == 0xD0 && source[r + 1] != '\0')
        {
            new nxt = source[r + 1] & 0xFF;

            if (nxt == 0x81)
            {
                destination[w++] = 0xA8;
                r += 2;
                continue;
            }

            if (nxt >= 0x90 && nxt <= 0xBF)
            {
                destination[w++] = nxt + 0x30;
                r += 2;
                continue;
            }
        }
        else if (cur == 0xD1 && source[r + 1] != '\0')
        {
            new nxt = source[r + 1] & 0xFF;

            if (nxt == 0x91)
            {
                destination[w++] = 0xB8;
                r += 2;
                continue;
            }

            if (nxt >= 0x80 && nxt <= 0x8F)
            {
                destination[w++] = nxt + 0x70;
                r += 2;
                continue;
            }
        }

        destination[w++] = source[r++];
    }

    destination[w] = '\0';
    return 1;
}

stock bool:Fracstrkmonarch(const json[], const key[], output[], size)
{
    new pos = Fracfindkmonarch(json, key);
    if (pos == -1 || json[pos] != '"')
    {
        output[0] = '\0';
        return false;
    }

    pos++;

    new w = 0;
    while (json[pos] != '\0' && json[pos] != '"' && w < size - 1)
    {
        if (json[pos] == '\\' && json[pos + 1] != '\0')
        {
            pos++;

            switch (json[pos])
            {
                case 'n': output[w++] = '\n';
                case 'r': output[w++] = '\r';
                case 't': output[w++] = '\t';
                default: output[w++] = json[pos];
            }

            pos++;
            continue;
        }

        output[w++] = json[pos++];
    }

    output[w] = '\0';
    Fracutfkmonarch(output, output, size);
    return true;
}

stock Fracuidkmonarch(uid)
{
    foreach (new i : Player)
    {
        if (!IsPlayerLogged(i))
        {
            continue;
        }

        if (GetPlayerAccountID(i) == uid)
        {
            return i;
        }
    }

    return INVALID_PLAYER_ID;
}

stock Fraconlinekmonarch(uid)
{
    return Fracuidkmonarch(uid) != INVALID_PLAYER_ID;
}

stock Fracranknamekmonarch(teamid, rankid, output[], size)
{
    if (rankid < 1 || rankid > 10)
    {
        rankid = 1;
    }

    format(output, size, GetTeamRankName(teamid, rankid));
    return 1;
}

stock FracSendMainkmonarch(playerid, openid = 0)
{
    new teamid = GetPlayerTeamEx(playerid);
    new fractionid = Fracfractionidkmonarch(teamid);
    new rankid = GetPlayerJob(playerid);
    new status[10];

    if (rankid < 1 || rankid > 10)
    {
        rankid = 1;
    }

    for (new i = 0; i < 10; i++)
    {
        new rowrank = i + 1;

        if (rowrank < rankid)
        {
            status[i] = 4;
        }
        else if (rowrank == rankid)
        {
            status[i] = 1;
        }
        else if (rowrank == rankid + 1)
        {
            status[i] = 5;
        }
        else
        {
            status[i] = 0;
        }
    }

    format
    (
        fracpayload,
        sizeof(fracpayload),
        "%s\"page\":1,\"fraction_id\":%d,\"fraction_tokens\":1,\"fraction_tokens_value\":%d,\"token_price\":0,\"rank_status\":[%d,%d,%d,%d,%d,%d,%d,%d,%d,%d],\"rank_progress\":[0,0]}",
        openid ? ("{\"o\":1,") : ("{"),
        fractionid,
        fractokens[playerid],
        status[0], status[1], status[2], status[3], status[4],
        status[5], status[6], status[7], status[8], status[9]
    );
    Fracsendkmonarch(playerid, fracpayload);
    return 1;
}

stock Fracmainkmonarch(playerid, openid = 0)
{
    new query[128];
    new accountid = GetPlayerAccountID(playerid);
    Fracensurekmonarch();
    mysql_format(mysql, query, sizeof(query), "SELECT `tokens` FROM `fraction_tokens` WHERE `uid`=%d LIMIT 1", accountid);
    mysql_tquery(mysql, query, "FracTokensLoad", "dddd", playerid, accountid, 1, openid);
    return 1;
}

stock Fracdocskmonarch(playerid)
{
    new query[160];
    new teamid = GetPlayerTeamEx(playerid);

    Fracensurekmonarch();

    mysql_format
    (
        mysql,
        query,
        sizeof(query),
        "SELECT `document_number`,`acquainted` FROM `fraction_documents` WHERE `uid`=%d AND `fraction_id`=%d ORDER BY `document_number` ASC",
        GetPlayerAccountID(playerid),
        teamid
    );
    mysql_tquery(mysql, query, "Fracdocsload", "dd", playerid, teamid);
    return 1;
}

stock Fraccontrolkmonarch(playerid)
{
    new query[160];
    new teamid = GetPlayerTeamEx(playerid);

    mysql_format
    (
        mysql,
        query,
        sizeof(query),
        "SELECT `id`,`name`,`job` FROM `accounts` WHERE `team`=%d ORDER BY `job` DESC, `name` ASC LIMIT 200",
        teamid
    );
    mysql_tquery(mysql, query, "Fracctrlload", "dd", playerid, teamid);
    return 1;
}

stock Fracplayerkmonarch(playerid, uid)
{
    new target = Fracuidkmonarch(uid);
    new teamid = GetPlayerTeamEx(playerid);

    fracchosen[playerid] = uid;

    if (target != INVALID_PLAYER_ID)
    {
        Fracranknamekmonarch(teamid, GetPlayerJob(target), fracname, sizeof(fracname));
        Fracesckmonarch(GetPlayerNameEx(target), fracescaped, sizeof(fracescaped));
        Fracesckmonarch(fracname, fracpiece, sizeof(fracpiece));

        format
        (
            fracpayload,
            sizeof(fracpayload),
            "{\"page\":9,\"type\":2,\"nickname\":\"%s\",\"skin_id\":%d,\"level\":%d,\"rank_name\":\"%s\",\"rank\":%d,\"reprimand\":%d,\"phone\":\"%d\"}",
            fracescaped,
            GetPlayerData(target, P_OSKIN),
            GetPlayerLevel(target),
            fracpiece,
            GetPlayerJob(target),
            GetPlayerData(target, P_OWARN),
            GetPlayerPhone(target)
        );
        Fracsendkmonarch(playerid, fracpayload);
        return 1;
    }

    new query[192];
    mysql_format
    (
        mysql,
        query,
        sizeof(query),
        "SELECT `id`,`name`,`level`,`phone`,`job`,`owarn`,`org_skin`,`team` FROM `accounts` WHERE `id`=%d AND `team`=%d LIMIT 1",
        uid,
        teamid
    );
    mysql_tquery(mysql, query, "Fracplayerdb", "ddd", playerid, uid, teamid);
    return 1;
}

stock Fracquestkmonarch(playerid)
{
    format(fracpayload, sizeof(fracpayload), "{\"page\":3,\"taskRank\":%d}", GetPlayerJob(playerid));
    Fracsendkmonarch(playerid, fracpayload);
    return 1;
}

stock bool:FracQuestConfigkmonarch(taskid, &required, &rewardmoney, &rewardtokens)
{
    required = 0;
    rewardmoney = 0;
    rewardtokens = 0;

    switch (taskid)
    {
        case 0:  { required = 1;  rewardmoney = 0;      rewardtokens = 0; }
        case 1:  { required = 2;  rewardmoney = 100000; rewardtokens = 2; }
        case 2:  { required = 1;  rewardmoney = 100000; rewardtokens = 2; }
        case 3:  { required = 5;  rewardmoney = 100000; rewardtokens = 2; }
        case 4:  { required = 3;  rewardmoney = 100000; rewardtokens = 2; }
        case 5:  { required = 1;  rewardmoney = 100000; rewardtokens = 2; }
        case 6:  { required = 1;  rewardmoney = 200000; rewardtokens = 2; }
        case 7:  { required = 2;  rewardmoney = 100000; rewardtokens = 2; }
        case 8:  { required = 20; rewardmoney = 100000; rewardtokens = 2; }
        case 9:  { required = 2;  rewardmoney = 100000; rewardtokens = 2; }
        case 10: { required = 15; rewardmoney = 100000; rewardtokens = 2; }
        case 11: { required = 5;  rewardmoney = 100000; rewardtokens = 2; }
        case 12: { required = 1;  rewardmoney = 100000; rewardtokens = 2; }
        case 13: { required = 5;  rewardmoney = 10000;  rewardtokens = 2; }
        case 14: { required = 10; rewardmoney = 10000;  rewardtokens = 2; }
        case 15: { required = 5;  rewardmoney = 10000;  rewardtokens = 2; }
        case 16: { required = 1;  rewardmoney = 20000;  rewardtokens = 0; }
        case 17: { required = 15; rewardmoney = 100000; rewardtokens = 3; }
        case 18: { required = 50; rewardmoney = 10000;  rewardtokens = 3; }
        case 19: { required = 5;  rewardmoney = 10000;  rewardtokens = 2; }
        case 20: { required = 1;  rewardmoney = 20000;  rewardtokens = 0; }
        case 21: { required = 1;  rewardmoney = 100000; rewardtokens = 2; }
        case 22: { required = 15; rewardmoney = 100000; rewardtokens = 2; }
        case 23: { required = 3;  rewardmoney = 100000; rewardtokens = 2; }
        case 24: { required = 60; rewardmoney = 150000; rewardtokens = 2; }
        case 25: { required = 1;  rewardmoney = 100000; rewardtokens = 2; }
        case 26: { required = 1;  rewardmoney = 100000; rewardtokens = 2; }
        case 27: { required = 15; rewardmoney = 100000; rewardtokens = 2; }
        case 28: { required = 3;  rewardmoney = 100000; rewardtokens = 2; }
        case 29: { required = 60; rewardmoney = 200000; rewardtokens = 2; }
        case 30: { required = 1;  rewardmoney = 200000; rewardtokens = 2; }
        case 31: { required = 1;  rewardmoney = 10000;  rewardtokens = 2; }
        case 32: { required = 15; rewardmoney = 10000;  rewardtokens = 2; }
        case 33: { required = 1;  rewardmoney = 10000;  rewardtokens = 2; }
        case 34: { required = 20; rewardmoney = 10000;  rewardtokens = 2; }
        case 35: { required = 1;  rewardmoney = 20000;  rewardtokens = 2; }
        case 36: { required = 30; rewardmoney = 10000;  rewardtokens = 1; }
        case 37: { required = 30; rewardmoney = 10000;  rewardtokens = 5; }
        case 38: { required = 5;  rewardmoney = 10000;  rewardtokens = 1; }
        case 39: { required = 1;  rewardmoney = 10000;  rewardtokens = 1; }
        case 40: { required = 1;  rewardmoney = 10000;  rewardtokens = 1; }
        case 41: { required = 5;  rewardmoney = 10000;  rewardtokens = 1; }
        case 42: { required = 1;  rewardmoney = 10000;  rewardtokens = 1; }
        case 43: { required = 5;  rewardmoney = 10000;  rewardtokens = 1; }
        case 44: { required = 1;  rewardmoney = 15000;  rewardtokens = 0; }
        case 45: { required = 1;  rewardmoney = 15000;  rewardtokens = 0; }
        default: return false;
    }
    return true;
}

stock FracQuestClearkmonarch(playerid)
{
    fracquestactive[playerid] = false;
    fracquestaccount[playerid] = 0;
    fracquesttask[playerid] = 0;
    fracquestfaction[playerid] = 0;
    fracquestprogress[playerid] = 0;
    fracquestrequired[playerid] = 0;
    fracquestmoney[playerid] = 0;
    fracquesttokens[playerid] = 0;
    fracquestseconds[playerid] = 0;
    return 1;
}

stock FracQuestCancelkmonarch(playerid, bool:notify = true)
{
    if(!fracquestactive[playerid])
    {
        if(notify) SendClientMessage(playerid, 0x999999FF, "У Вас нет активного фракционного задания");
        return 0;
    }

    new accountid = fracquestaccount[playerid];
    if(accountid <= 0 && IsPlayerLogged(playerid)) accountid = GetPlayerAccountID(playerid);
    if(accountid > 0)
    {
        new query[160];
        mysql_format(mysql, query, sizeof(query), "UPDATE `fraction_quests` SET `progress`=0,`required`=0 WHERE `uid`=%d AND `quest_date`=CURDATE()", accountid);
        mysql_tquery(mysql, query);
    }

    FracQuestClearkmonarch(playerid);
    if(notify) SendClientMessage(playerid, 0xFFCC66FF, "Фракционное задание отменено. Награда и прогресс не сохраняются.");
    return 1;
}

stock FracQuestCompletekmonarch(playerid)
{
    new query[256];
    mysql_format(mysql, query, sizeof(query), "UPDATE `fraction_quests` SET `completed`=LEAST(`completed`+1,3),`progress`=0,`required`=0 WHERE `uid`=%d AND `quest_date`=CURDATE() AND `required`>0", GetPlayerAccountID(playerid));
    mysql_tquery(mysql, query);
    if (fracquestmoney[playerid] > 0) GivePlayerMoneyEx(playerid, fracquestmoney[playerid], "Faction quest", true, true);
    if (fracquesttokens[playerid] > 0) FracAddTokenskmonarch(playerid, fracquesttokens[playerid]);
    new completedmsg[160];
    format(completedmsg, sizeof(completedmsg), "Фракционное задание выполнено: +%d руб. и +%d фракционных монет", fracquestmoney[playerid], fracquesttokens[playerid]);
    SendClientMessage(playerid, 0x66CC00FF, completedmsg);
    FracQuestClearkmonarch(playerid);
    return 1;
}

stock FracQuestProgresskmonarch(playerid, taskid, amount = 1)
{
    if (!fracquestactive[playerid] || fracquesttask[playerid] != taskid || amount <= 0) return 0;
    if (!IsPlayerLogged(playerid) || GetPlayerAccountID(playerid) != fracquestaccount[playerid] || GetPlayerTeamEx(playerid) != fracquestfaction[playerid]) return 0;
    fracquestprogress[playerid] += amount;
    if (fracquestprogress[playerid] > fracquestrequired[playerid]) fracquestprogress[playerid] = fracquestrequired[playerid];
    new query[256];
    mysql_format(mysql, query, sizeof(query), "UPDATE `fraction_quests` SET `progress`=%d WHERE `uid`=%d AND `quest_date`=CURDATE() AND `required`>0", fracquestprogress[playerid], GetPlayerAccountID(playerid));
    mysql_tquery(mysql, query);
    if (fracquestprogress[playerid] >= fracquestrequired[playerid]) return FracQuestCompletekmonarch(playerid);
    new message[128];
    format(message, sizeof(message), "Фракционное задание: %d из %d.", fracquestprogress[playerid], fracquestrequired[playerid]);
    SendClientMessage(playerid, 0x66CCFFFF, message);
    return 1;
}

stock FracQuestStartkmonarch(playerid, taskid)
{
    new required, rewardmoney, rewardtokens;
    if (!FracQuestConfigkmonarch(taskid, required, rewardmoney, rewardtokens))
    {
        return Fracnotifykmonarch(playerid, 4620, "Для этого задания пока нет механики в моде");
    }

    HidePlayerGUI(playerid, FRACGUIID);

    new query[256];
    new accountid = GetPlayerAccountID(playerid);
    Fracensurekmonarch();
    mysql_format(mysql, query, sizeof(query), "SELECT `task_id`,`fraction_id`,`progress`,`required`,`reward_money`,`reward_tokens`,`completed` FROM `fraction_quests` WHERE `uid`=%d AND `quest_date`=CURDATE() LIMIT 1", accountid);
    mysql_tquery(mysql, query, "FracQuestStartLoad", "dddddd", playerid, accountid, taskid, required, rewardmoney, rewardtokens);
    return 1;
}

stock FracQuestTickkmonarch(playerid)
{
    if (!fracquestactive[playerid] || fracquestrequired[playerid] <= 0)
    {
        return 1;
    }

    if (!IsPlayerLogged(playerid) || GetPlayerAccountID(playerid) != fracquestaccount[playerid] || GetPlayerTeamEx(playerid) != fracquestfaction[playerid] || !GetPVarInt(playerid, "Form") || IsPlayerAFK(playerid))
    {
        if (IsPlayerLogged(playerid) && GetPlayerAccountID(playerid) != fracquestaccount[playerid]) FracQuestClearkmonarch(playerid);
        fracquestseconds[playerid] = 0;
        return 1;
    }

    new taskid = fracquesttask[playerid];
    if (taskid != 8 && taskid != 10 && taskid != 22 && taskid != 24 && taskid != 27 && taskid != 29 && taskid != 32 && taskid != 34 && taskid != 36 && taskid != 37) return 1;

    if (taskid == 8 && !IsPlayerInRangeOfPoint(playerid, 350.0, 1731.4894, 1768.2654, 16.7501))
    {
        fracquestseconds[playerid] = 0;
        return 1;
    }
    if (taskid == 10)
    {
        new Float:army_x, Float:army_y, Float:army_z;
        GetPlayerPos(playerid, army_x, army_y, army_z);
        if (!IsPlayerInRangeOfPoint(playerid, 350.0, 1731.4894, 1768.2654, 16.7501) || army_z < 20.0)
        {
            fracquestseconds[playerid] = 0;
            return 1;
        }
    }

    if (taskid == 36 && !IsPlayerInRangeOfPoint(playerid, 300.0, -1817.0083, -2631.8076, 7.5909))
    {
        fracquestseconds[playerid] = 0;
        return 1;
    }
    if (taskid == 37)
    {
        new Float:fsin_x, Float:fsin_y, Float:fsin_z;
        GetPlayerPos(playerid, fsin_x, fsin_y, fsin_z);
        if (!IsPlayerInRangeOfPoint(playerid, 300.0, -1817.0083, -2631.8076, 7.5909) || fsin_z < 14.0)
        {
            fracquestseconds[playerid] = 0;
            return 1;
        }
    }

    if (taskid == 34 && !GetPVarInt(playerid, "FBI_UNDERCOVER"))
    {
        fracquestseconds[playerid] = 0;
        return 1;
    }

    if (taskid == 22 || taskid == 27 || taskid == 32)
    {
        if (!IsPlayerInAnyVehicle(playerid) || !IsPlayerInPoliceCar(playerid)) { fracquestseconds[playerid] = 0; return 1; }
        new vehicleid = GetPlayerVehicleID(playerid), bool:partner = false;
        for (new i = 0; i < MAX_PLAYERS; i++) if (i != playerid && IsPlayerConnected(i) && GetPlayerVehicleID(i) == vehicleid && GetPlayerTeamEx(i) == GetPlayerTeamEx(playerid)) { partner = true; break; }
        if (!partner) { fracquestseconds[playerid] = 0; return 1; }

        new Float:velocity_x, Float:velocity_y, Float:velocity_z;
        GetVehicleVelocity(vehicleid, velocity_x, velocity_y, velocity_z);
        if (floatsqroot(velocity_x * velocity_x + velocity_y * velocity_y + velocity_z * velocity_z) < 0.03)
        {
            fracquestseconds[playerid] = 0;
            return 1;
        }
    }
    fracquestseconds[playerid]++;
    if (fracquestseconds[playerid] < 60)
    {
        return 1;
    }

    fracquestseconds[playerid] = 0;
    return FracQuestProgresskmonarch(playerid, taskid);
}

stock Fracshopkmonarch(playerid)
{
    new query[128];
    new accountid = GetPlayerAccountID(playerid);
    Fracensurekmonarch();
    mysql_format(mysql, query, sizeof(query), "SELECT `tokens` FROM `fraction_tokens` WHERE `uid`=%d LIMIT 1", accountid);
    mysql_tquery(mysql, query, "FracTokensLoad", "dddd", playerid, accountid, 8, 0);
    return 1;
}

stock FracSendShopkmonarch(playerid)
{
    format(fracpayload, sizeof(fracpayload), "{\"page\":8,\"fraction_tokens\":1,\"fraction_tokens_value\":%d,\"token_price\":0}", fractokens[playerid]);
    Fracsendkmonarch(playerid, fracpayload);
    return 1;
}

stock FracShopFindFamilyAccessory(shop_id)
{
    for(new i; i < sizeof(FamilyGuiShopItems); i++)
    {
        if(FamilyGuiShopItems[i][FAMILY_GUI_SHOP_ID] != shop_id) continue;
        if(FamilyGuiShopItems[i][FAMILY_GUI_SHOP_TYPE] != 0) return -1;
        return i;
    }
    return -1;
}

stock FracShopResolveReward(item_index)
{
    if(item_index < 0 || item_index >= sizeof(FamilyGuiShopItems)) return -1;
    if(FamilyGuiShopItems[item_index][FAMILY_GUI_SHOP_TYPE] != 0) return -1;
    if(FamilyGuiShopItems[item_index][FAMILY_GUI_SHOP_ID] != 0) return item_index;

    new indexes[sizeof(FamilyGuiShopItems)], count;
    for(new i; i < sizeof(FamilyGuiShopItems); i++)
    {
        if(i == item_index || FamilyGuiShopItems[i][FAMILY_GUI_SHOP_TYPE] != 0) continue;
        indexes[count++] = i;
    }
    return count ? indexes[random(count)] : -1;
}

stock FracShopPurchasekmonarch(playerid, shop_id)
{
    if(GetPlayerTeamEx(playerid) < 1 || GetPlayerTeamEx(playerid) >= MAX_ORG)
        return Fracnotifykmonarch(playerid, 4605, "Вы не состоите в организации");

    new item_index = FracShopFindFamilyAccessory(shop_id);
    if(item_index == -1)
    {
        printf("[FRACTION_SHOP][ERROR] unknown item player=%d shop_id=%d", playerid, shop_id);
        return Fracnotifykmonarch(playerid, 4605, "Этот аксессуар временно недоступен");
    }

    new price = FamilyGuiShopItems[item_index][FAMILY_GUI_SHOP_PRICE];
    if(fractokens[playerid] < price)
        return Fracnotifykmonarch(playerid, 4605, "Недостаточно фракционных монет");

    new reward_index = FracShopResolveReward(item_index);
    if(reward_index == -1)
        return Fracnotifykmonarch(playerid, 4605, "Не удалось определить аксессуар");

    new modelid = FamilyGuiShopItems[reward_index][FAMILY_GUI_SHOP_OBJECT_ID];
    new inv_item_id = AccessoryShop_GetInventoryItemByModel(modelid);
    if(inv_item_id <= 0)
    {
        new resolved_item_id = -1, resolved_modelid = -1;
        if(Inv11_ResolveAccessoryReward(FamilyGuiShopItems[reward_index][FAMILY_GUI_SHOP_SERVER_ID], resolved_item_id, resolved_modelid))
        {
            inv_item_id = resolved_item_id;
            modelid = resolved_modelid;
        }
    }

    if(inv_item_id <= 0 || modelid <= 0)
    {
        printf("[FRACTION_SHOP][ERROR] resolve player=%d shop_id=%d object=%d server_id=%d",
            playerid, shop_id, FamilyGuiShopItems[reward_index][FAMILY_GUI_SHOP_OBJECT_ID],
            FamilyGuiShopItems[reward_index][FAMILY_GUI_SHOP_SERVER_ID]);
        return Fracnotifykmonarch(playerid, 4605, "Аксессуар временно недоступен");
    }

    new slot = Inventory11_AddItemToDatabase(playerid, inv_item_id, modelid, 1, modelid, 0);
    if(slot == -1)
        return Fracnotifykmonarch(playerid, 4605, "В инвентаре недостаточно места");

    fractokens[playerid] -= price;
    new query[192];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO `fraction_tokens` (`uid`,`tokens`) VALUES (%d,%d) ON DUPLICATE KEY UPDATE `tokens`=%d",
        GetPlayerAccountID(playerid), fractokens[playerid], fractokens[playerid]);
    mysql_tquery(mysql, query);

    printf("[FRACTION_SHOP] player=%d shop_id=%d reward_id=%d item=%d model=%d slot=%d price=%d balance=%d",
        playerid, shop_id, FamilyGuiShopItems[reward_index][FAMILY_GUI_SHOP_ID], inv_item_id,
        modelid, slot, price, fractokens[playerid]);
    Fracnotifykmonarch(playerid, 4604, "Аксессуар приобретён и добавлен в инвентарь");
    return FracSendShopkmonarch(playerid);
}

stock FracTestCountkmonarch(docid)
{
    switch (docid)
    {
        case 1: return 2;
        case 2: return 10;
        case 3: return 2;
        case 4: return 13;
        case 5: return 2;
        case 6: return 10;
        case 7: return 6;
        case 8: return 2;
        case 9: return 10;
        case 10: return 9;
        case 11: return 5;
        case 12: return 2;
        case 13: return 11;
        case 14: return 10;
        case 15: return 6;
        case 16: return 2;
        case 17: return 11;
        case 18: return 10;
        case 19: return 6;
        case 20: return 2;
        case 21: return 11;
        case 22: return 10;
        case 23: return 6;
        case 24: return 2;
        case 25: return 13;
    }

    return 0;
}

stock FracTestCorrectkmonarch(docid, indexid)
{
    switch (docid)
    {
        case 1:
        {
            switch (indexid)
            {
                case 0: return 1;
                case 1: return 3;
            }
        }
        case 2:
        {
            switch (indexid)
            {
                case 0: return 2;
                case 1: return 1;
                case 2: return 3;
                case 3: return 3;
                case 4: return 4;
                case 5: return 2;
                case 6: return 3;
                case 7: return 1;
                case 8: return 4;
                case 9: return 4;
            }
        }
        case 3:
        {
            switch (indexid)
            {
                case 0: return 1;
                case 1: return 3;
            }
        }
        case 4:
        {
            switch (indexid)
            {
                case 0: return 4;
                case 1: return 3;
                case 2: return 1;
                case 3: return 2;
                case 4: return 4;
                case 5: return 3;
                case 6: return 3;
                case 7: return 1;
                case 8: return 2;
                case 9: return 4;
                case 10: return 3;
                case 11: return 3;
                case 12: return 1;
            }
        }
        case 5:
        {
            switch (indexid)
            {
                case 0: return 1;
                case 1: return 3;
            }
        }
        case 6:
        {
            switch (indexid)
            {
                case 0: return 2;
                case 1: return 1;
                case 2: return 2;
                case 3: return 3;
                case 4: return 4;
                case 5: return 1;
                case 6: return 2;
                case 7: return 1;
                case 8: return 4;
                case 9: return 2;
            }
        }
        case 7:
        {
            switch (indexid)
            {
                case 0: return 4;
                case 1: return 2;
                case 2: return 1;
                case 3: return 3;
                case 4: return 1;
                case 5: return 4;
            }
        }
        case 8:
        {
            switch (indexid)
            {
                case 0: return 1;
                case 1: return 3;
            }
        }
        case 9:
        {
            switch (indexid)
            {
                case 0: return 3;
                case 1: return 1;
                case 2: return 4;
                case 3: return 2;
                case 4: return 1;
                case 5: return 3;
                case 6: return 1;
                case 7: return 2;
                case 8: return 3;
                case 9: return 4;
            }
        }
        case 10:
        {
            switch (indexid)
            {
                case 0: return 1;
                case 1: return 3;
                case 2: return 1;
                case 3: return 4;
                case 4: return 2;
                case 5: return 3;
                case 6: return 1;
                case 7: return 4;
                case 8: return 2;
            }
        }
        case 11:
        {
            switch (indexid)
            {
                case 0: return 3;
                case 1: return 1;
                case 2: return 2;
                case 3: return 4;
                case 4: return 3;
            }
        }
        case 12:
        {
            switch (indexid)
            {
                case 0: return 1;
                case 1: return 3;
            }
        }
        case 13:
        {
            switch (indexid)
            {
                case 0: return 3;
                case 1: return 1;
                case 2: return 4;
                case 3: return 3;
                case 4: return 1;
                case 5: return 2;
                case 6: return 4;
                case 7: return 3;
                case 8: return 1;
                case 9: return 2;
                case 10: return 3;
            }
        }
        case 14:
        {
            switch (indexid)
            {
                case 0: return 3;
                case 1: return 1;
                case 2: return 2;
                case 3: return 4;
                case 4: return 3;
                case 5: return 3;
                case 6: return 1;
                case 7: return 2;
                case 8: return 4;
                case 9: return 1;
            }
        }
        case 15:
        {
            switch (indexid)
            {
                case 0: return 2;
                case 1: return 3;
                case 2: return 1;
                case 3: return 4;
                case 4: return 2;
                case 5: return 1;
            }
        }
        case 16:
        {
            switch (indexid)
            {
                case 0: return 1;
                case 1: return 3;
            }
        }
        case 17:
        {
            switch (indexid)
            {
                case 0: return 3;
                case 1: return 1;
                case 2: return 4;
                case 3: return 3;
                case 4: return 1;
                case 5: return 2;
                case 6: return 4;
                case 7: return 3;
                case 8: return 1;
                case 9: return 2;
                case 10: return 2;
            }
        }
        case 18:
        {
            switch (indexid)
            {
                case 0: return 3;
                case 1: return 1;
                case 2: return 2;
                case 3: return 4;
                case 4: return 3;
                case 5: return 3;
                case 6: return 1;
                case 7: return 2;
                case 8: return 4;
                case 9: return 1;
            }
        }
        case 19:
        {
            switch (indexid)
            {
                case 0: return 2;
                case 1: return 3;
                case 2: return 1;
                case 3: return 4;
                case 4: return 2;
                case 5: return 1;
            }
        }
        case 20:
        {
            switch (indexid)
            {
                case 0: return 1;
                case 1: return 3;
            }
        }
        case 21:
        {
            switch (indexid)
            {
                case 0: return 3;
                case 1: return 1;
                case 2: return 4;
                case 3: return 3;
                case 4: return 1;
                case 5: return 2;
                case 6: return 4;
                case 7: return 3;
                case 8: return 1;
                case 9: return 2;
                case 10: return 4;
            }
        }
        case 22:
        {
            switch (indexid)
            {
                case 0: return 3;
                case 1: return 1;
                case 2: return 2;
                case 3: return 4;
                case 4: return 3;
                case 5: return 3;
                case 6: return 1;
                case 7: return 2;
                case 8: return 4;
                case 9: return 1;
            }
        }
        case 23:
        {
            switch (indexid)
            {
                case 0: return 2;
                case 1: return 3;
                case 2: return 1;
                case 3: return 4;
                case 4: return 2;
                case 5: return 1;
            }
        }
        case 24:
        {
            switch (indexid)
            {
                case 0: return 1;
                case 1: return 3;
            }
        }
        case 25:
        {
            switch (indexid)
            {
                case 0: return 4;
                case 1: return 2;
                case 2: return 3;
                case 3: return 1;
                case 4: return 2;
                case 5: return 3;
                case 6: return 4;
                case 7: return 2;
                case 8: return 1;
                case 9: return 3;
                case 10: return 1;
                case 11: return 4;
                case 12: return 2;
            }
        }
    }

    return 0;
}


stock FracTestAnswerkmonarch(playerid, answerid)
{
    new total = fractesttotal[playerid];

    if (total <= 0)
    {
        total = FracTestCountkmonarch(fractestdoc[playerid]);
        fractesttotal[playerid] = total;
    }

    if (total <= 0)
    {
        return Fractestresultkmonarch(playerid, 0, 0, 1);
    }

    new indexid = fractestpos[playerid];
    new correct = FracTestCorrectkmonarch(fractestdoc[playerid], indexid);

    if (answerid == correct)
    {
        fractestok[playerid]++;
    }

    fractestpos[playerid]++;

    if (fractestpos[playerid] >= total)
    {
        new passed = fractestok[playerid] == total ? 1 : 0;
        new right = fractestok[playerid];

        if (passed) FracQuestProgresskmonarch(playerid, 0);

        fractestdoc[playerid] = 0;
        fractestpos[playerid] = 0;
        fractestok[playerid] = 0;
        fractesttotal[playerid] = 0;

        return Fractestresultkmonarch(playerid, passed, right, total);
    }

    return 1;
}
stock Fractestresultkmonarch(playerid, positive = 1, total = 1, questions = 1)
{
    format
    (
        fracpayload,
        sizeof(fracpayload),
        "{\"page\":6,\"testing_result\":%d,\"testing_total\":%d,\"question_total\":%d}",
        positive,
        total,
        questions
    );
    Fracsendkmonarch(playerid, fracpayload);
    return 1;
}

stock Fracbuydialogkmonarch(playerid, bcvalue = 0)
{
    format(fracpayload, sizeof(fracpayload), "{\"page\":7,\"type\":2,\"bc_value\":%d,\"token_price\":0}", bcvalue);
    Fracsendkmonarch(playerid, fracpayload);
    return 1;
}

stock Fracrewardkmonarch(playerid)
{
    if (GetPlayerJob(playerid) < 10)
    {
        return Fracnotifykmonarch(playerid, 4601, "Доступно только лидеру");
    }

    return Fracnotifykmonarch(playerid, 4602, "Лидер назначается через /setleader");
}

stock Fracdocsetkmonarch(playerid, docid, docnum)
{
    new query[256];
    new teamid = GetPlayerTeamEx(playerid);

    fractestdoc[playerid] = docid;
    fractestpos[playerid] = 0;
    fractestok[playerid] = 0;
    fractesttotal[playerid] = FracTestCountkmonarch(docid);
    Fracensurekmonarch();

    mysql_format
    (
        mysql,
        query,
        sizeof(query),
        "INSERT INTO `fraction_documents` (`uid`,`fraction_id`,`document_id`,`document_number`,`acquainted`) VALUES (%d,%d,%d,%d,1) \
        ON DUPLICATE KEY UPDATE `document_id`=%d,`acquainted`=1",
        GetPlayerAccountID(playerid),
        teamid,
        docid,
        docnum,
        docid
    );
    mysql_query(mysql, query, false);
    format(fracpayload, sizeof(fracpayload), "{\"page\":5}");
    Fracsendkmonarch(playerid, fracpayload);
    return 1;
}

stock Fracactkmonarch(playerid, actionid, changeid)
{
    new uid = fracchosen[playerid];

    if (uid <= 0)
    {
        return 1;
    }

    new query[224];
    new teamid = GetPlayerTeamEx(playerid);

    mysql_format
    (
        mysql,
        query,
        sizeof(query),
        "SELECT `id`,`name`,`job`,`owarn`,`phone`,`level`,`org_skin`,`sex`,`team` FROM `accounts` WHERE `id`=%d AND `team`=%d LIMIT 1",
        uid,
        teamid
    );
    mysql_tquery(mysql, query, "Fracplayeract", "ddddd", playerid, uid, actionid, changeid, teamid);
    return 1;
}

stock Fracopenkmonarch(playerid)
{
    new teamid = GetPlayerTeamEx(playerid);

    if (teamid < 1 || teamid >= MAX_ORG)
    {
        return Fracnotifykmonarch(playerid, 4600, "Вы не состоите во фракции");
    }

    if (!Fracfractionidkmonarch(teamid))
    {
        return Fracnotifykmonarch(playerid, 4610, "Меню доступно только для гос. фракций");
    }

    fracchosen[playerid] = 0;
    Fracmainkmonarch(playerid, 1);
    return 1;
}

stock FracHandlekmonarch(playerid, const data[])
{
    new pageid;
    new buttonid;
    new changeid;
    new uid;
    new docid;
    new docnum;
    new typeid;
    new amount;

    if (!Fracintkmonarch(data, "page", pageid))
    {
        if (!Fracintkmonarch(data, "p", pageid))
        {
            Fracintkmonarch(data, "screen", pageid);
        }
    }

    if (!Fracintkmonarch(data, "button", buttonid))
    {
        if (!Fracintkmonarch(data, "action", buttonid))
        {
            if (!Fracintkmonarch(data, "a", buttonid))
            {
                Fracintkmonarch(data, "c", buttonid);
            }
        }
    }
    Fracintkmonarch(data, "type", typeid);

    switch (buttonid)
    {
        case 1: return 1;
        case 3: return Fracshopkmonarch(playerid);
        case 4: return Fraccontrolkmonarch(playerid);
        case 5: return Fracdocskmonarch(playerid);
        case 6: return Fracquestkmonarch(playerid);
        case 7: return Fracrewardkmonarch(playerid);
        case 8: return Fracmainkmonarch(playerid);
        case 9:
        {
            if (pageid == 4)
            {
                if (Fracintkmonarch(data, "document_id", docid) && Fracintkmonarch(data, "document_number", docnum))
                {
                    return Fracdocsetkmonarch(playerid, docid, docnum);
                }
            }
            return 1;
        }
        case 10:
        {
            new taskid;
            new bool:has_task = Fracintkmonarch(data, "taskID", taskid);
            if (!has_task) has_task = Fracintkmonarch(data, "taskId", taskid);
            if (!has_task) has_task = Fracintkmonarch(data, "task_id", taskid);
            if (!has_task) has_task = Fracintkmonarch(data, "id", taskid);
            if (has_task && (pageid == 0 || pageid == 3))
            {
                return FracQuestStartkmonarch(playerid, taskid);
            }
            return 1;
        }
        case 11: return Fracmainkmonarch(playerid);
        case 12: return Fracdocskmonarch(playerid);
        case 13:
        {
            new answerid;
            Fracintkmonarch(data, "answer_id", answerid);
            return FracTestAnswerkmonarch(playerid, answerid);
        }
        case 14:
        {
            if (pageid == 7)
            {
                Fracnotifykmonarch(playerid, 4604, "Покупка токенов в разработке");
            }
            return 1;
        }
        case 15:
        {
            if (Fracintkmonarch(data, "account_id", uid))
            {
                return Fracplayerkmonarch(playerid, uid);
            }
            return 1;
        }
        case 16:
        {
            Fracintkmonarch(data, "change", changeid);
            return Fracactkmonarch(playerid, 16, changeid);
        }
        case 17:
        {
            Fracintkmonarch(data, "change", changeid);
            return Fracactkmonarch(playerid, 17, changeid);
        }
        case 18: return Fracactkmonarch(playerid, 18, 0);
        case 20:
        {
            new shop_id = -1;
            if(!Fracintkmonarch(data, "unique_id", shop_id))
                if(!Fracintkmonarch(data, "uniqueId", shop_id))
                    if(!Fracintkmonarch(data, "item_id", shop_id))
                        if(!Fracintkmonarch(data, "shop_id", shop_id))
                            Fracintkmonarch(data, "id", shop_id);

            printf("[FRACTION_SHOP][PACKET] player=%d item=%d data=%s", playerid, shop_id, data);
            return FracShopPurchasekmonarch(playerid, shop_id);
        }
        case 21: return 1;
    }

    if (pageid == 7 && typeid == 1 && Fracintkmonarch(data, "token_amount", amount))
    {
        if (amount < 0)
        {
            amount = 0;
        }
        return Fracbuydialogkmonarch(playerid, amount);
    }

    return 1;
}

public FracTokensLoad(playerid, accountid, pageid, openid)
{
    if (!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid) || GetPlayerAccountID(playerid) != accountid)
    {
        return 1;
    }

    fractokens[playerid] = 0;
    if (cache_num_rows())
    {
        fractokens[playerid] = cache_get_field_content_int(0, "tokens");
    }

    if (pageid == 8)
    {
        return FracSendShopkmonarch(playerid);
    }

    return FracSendMainkmonarch(playerid, openid);
}

public FracQuestStartLoad(playerid, accountid, taskid, required, rewardmoney, rewardtokens)
{
    if (!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid) || GetPlayerAccountID(playerid) != accountid)
    {
        return 1;
    }

    if (cache_num_rows())
    {
        new completed = cache_get_field_content_int(0, "completed");
        new stored_progress = cache_get_field_content_int(0, "progress");
        new stored_required = cache_get_field_content_int(0, "required");
        if (stored_required > 0 && stored_progress < stored_required)
        {
            fracquestactive[playerid] = true;
            fracquestaccount[playerid] = accountid;
            fracquesttask[playerid] = cache_get_field_content_int(0, "task_id");
            fracquestfaction[playerid] = cache_get_field_content_int(0, "fraction_id");
            fracquestprogress[playerid] = stored_progress;
            fracquestrequired[playerid] = stored_required;
            fracquestmoney[playerid] = cache_get_field_content_int(0, "reward_money");
            fracquesttokens[playerid] = cache_get_field_content_int(0, "reward_tokens");
            fracquestseconds[playerid] = 0;

            new activemsg[160];
            format(activemsg, sizeof(activemsg), "У Вас уже есть активное фракционное задание. Продолжайте выполнять цель: %d из %d.", fracquestprogress[playerid], fracquestrequired[playerid]);
            return SendClientMessage(playerid, 0xFFCC66FF, activemsg);
        }

        if(completed >= 3)
            return Fracnotifykmonarch(playerid, 4621, "Сегодня Вы уже выполнили 3 фракционных квеста");
    }

    fracquestactive[playerid] = true;
    fracquestaccount[playerid] = accountid;
    fracquesttask[playerid] = taskid;
    fracquestfaction[playerid] = GetPlayerTeamEx(playerid);
    fracquestprogress[playerid] = 0;
    fracquestrequired[playerid] = required;
    fracquestmoney[playerid] = rewardmoney;
    fracquesttokens[playerid] = rewardtokens;
    fracquestseconds[playerid] = 0;

    new query[768];
    mysql_format(mysql, query, sizeof(query), "INSERT INTO `fraction_quests` (`uid`,`task_id`,`fraction_id`,`progress`,`required`,`reward_money`,`reward_tokens`,`quest_date`,`completed`) VALUES (%d,%d,%d,0,%d,%d,%d,CURDATE(),0) ON DUPLICATE KEY UPDATE `completed`=IF(`quest_date`=CURDATE(),`completed`,0),`task_id`=VALUES(`task_id`),`fraction_id`=VALUES(`fraction_id`),`progress`=0,`required`=VALUES(`required`),`reward_money`=VALUES(`reward_money`),`reward_tokens`=VALUES(`reward_tokens`),`quest_date`=CURDATE()", accountid, taskid, fracquestfaction[playerid], required, rewardmoney, rewardtokens);
    mysql_tquery(mysql, query);

    new startmsg[192];
    format(startmsg, sizeof(startmsg), "Фракционное задание принято. Выполняйте условие из карточки задания. Текущий прогресс: 0 из %d.", required);
    return SendClientMessage(playerid, 0x66CCFFFF, startmsg);
}

stock FracAddTokenskmonarch(playerid, amount)
{
    if (!IsPlayerLogged(playerid) || amount <= 0)
    {
        return 0;
    }

    new query[192];
    new accountid = GetPlayerAccountID(playerid);
    fractokens[playerid] += amount;
    Fracensurekmonarch();
    mysql_format(mysql, query, sizeof(query), "INSERT INTO `fraction_tokens` (`uid`,`tokens`) VALUES (%d,%d) ON DUPLICATE KEY UPDATE `tokens`=`tokens`+%d", accountid, amount, amount);
    mysql_tquery(mysql, query);
    return 1;
}

public Fracdocsload(playerid, teamid)
{
    #pragma unused teamid

    for (new i = 0; i < FRACDOCMAX; i++)
    {
        fracdocs[i] = 0;
    }

    for (new row = 0; row < cache_num_rows(); row++)
    {
        new num = cache_get_field_content_int(row, "document_number");
        if (num >= 0 && num < FRACDOCMAX)
        {
            fracdocs[num] = cache_get_field_content_int(row, "acquainted") ? 1 : 0;
        }
    }

    format(fracpayload, sizeof(fracpayload), "{\"page\":4,\"document_status\":[");

    for (new i = 0; i < FRACDOCMAX; i++)
    {
        format(fracpiece, sizeof(fracpiece), "%s%d", i ? "," : "", fracdocs[i]);
        strcat(fracpayload, fracpiece, sizeof(fracpayload));
    }

    strcat(fracpayload, "]}", sizeof(fracpayload));
    Fracsendkmonarch(playerid, fracpayload);
    return 1;
}

public Fracctrlload(playerid, teamid)
{
    fracnp[0] = '\0';
    fracrs[0] = '\0';

    strcat(fracnp, "[", sizeof(fracnp));
    strcat(fracrs, "[", sizeof(fracrs));

    for (new row = 0; row < cache_num_rows(); row++)
    {
        new uid = cache_get_field_content_int(row, "id");
        new rankid = cache_get_field_content_int(row, "job");
        new online = Fraconlinekmonarch(uid) ? 1 : 0;

        cache_get_field_content(row, "name", fracname, mysql, sizeof(fracname));
        Fracesckmonarch(fracname, fracescaped, sizeof(fracescaped));

        format(fracpiece, sizeof(fracpiece), "%s\"%s\"", row ? "," : "", fracescaped);
        strcat(fracnp, fracpiece, sizeof(fracnp));

        format(fracpiece, sizeof(fracpiece), "%s%d,%d,%d", row ? "," : "", uid, rankid, online);
        strcat(fracrs, fracpiece, sizeof(fracrs));
    }

    strcat(fracnp, "]", sizeof(fracnp));
    strcat(fracrs, "]", sizeof(fracrs));

    format
    (
        fracpayload,
        sizeof(fracpayload),
        "{\"t\":4,\"page\":9,\"type\":1,\"np\":%s,\"rs\":%s}",
        fracnp,
        fracrs
    );
    Fracsendkmonarch(playerid, fracpayload);

    if (cache_num_rows() > 0)
    {
        fracchosen[playerid] = cache_get_field_content_int(0, "id");
        Fracplayerkmonarch(playerid, fracchosen[playerid]);
    }

    #pragma unused teamid
    return 1;
}

public Fracplayerdb(playerid, uid, teamid)
{
    if (!cache_num_rows())
    {
        return 1;
    }

    new rankid = cache_get_field_content_int(0, "job");
    new skinid = cache_get_field_content_int(0, "org_skin");
    new levelid = cache_get_field_content_int(0, "level");
    new owarn = cache_get_field_content_int(0, "owarn");
    new phone = cache_get_field_content_int(0, "phone");

    cache_get_field_content(0, "name", fracname, mysql, sizeof(fracname));
    Fracesckmonarch(fracname, fracescaped, sizeof(fracescaped));
    Fracranknamekmonarch(teamid, rankid, fracname, sizeof(fracname));
    Fracesckmonarch(fracname, fracpiece, sizeof(fracpiece));

    format
    (
        fracpayload,
        sizeof(fracpayload),
        "{\"page\":9,\"type\":2,\"nickname\":\"%s\",\"skin_id\":%d,\"level\":%d,\"rank_name\":\"%s\",\"rank\":%d,\"reprimand\":%d,\"phone\":\"%d\"}",
        fracescaped,
        skinid,
        levelid,
        fracpiece,
        rankid,
        owarn,
        phone
    );
    Fracsendkmonarch(playerid, fracpayload);

    #pragma unused uid
    return 1;
}

public Fracplayeract(playerid, uid, actionid, changeid, teamid)
{
    if (!cache_num_rows())
    {
        return 1;
    }

    if (GetPlayerJob(playerid) < 10)
    {
        return Fracnotifykmonarch(playerid, 4606, "Действие доступно только лидеру");
    }

    new rankid = cache_get_field_content_int(0, "job");
    new owarn = cache_get_field_content_int(0, "owarn");
    new target = Fracuidkmonarch(uid);

    if (rankid >= 10)
    {
        return Fracnotifykmonarch(playerid, 4607, "Нельзя изменять лидера");
    }

    switch (actionid)
    {
        case 16:
        {
            new newrank = rankid;
            new sexid = cache_get_field_content_int(0, "sex");
            new skinid;

            if (changeid == 1)
            {
                if (newrank >= 9)
                {
                    return Fracnotifykmonarch(playerid, 4608, "Максимальный ранг 9");
                }
                newrank++;
            }
            else
            {
                if (newrank <= 1)
                {
                    return Fracnotifykmonarch(playerid, 4609, "Минимальный ранг 1");
                }
                newrank--;
            }

            if (!sexid)
            {
                skinid = GetTeamData(teamid, O_SKINS)[newrank - 1];
            }
            else
            {
                skinid = GetTeamData(teamid, O_WOMEN_SKIN);
            }

            format(fracpayload, sizeof(fracpayload), "UPDATE accounts SET job=%d,org_skin=%d WHERE id=%d", newrank, skinid, uid);
            mysql_query(mysql, fracpayload, false);

            if (target != INVALID_PLAYER_ID)
            {
                SetPlayerData(target, P_JOB, newrank);

                if (!GetPlayerSex(target))
                {
                    SetPlayerData(target, P_OSKIN, GetTeamData(teamid, O_SKINS)[newrank - 1]);
                }
                else
                {
                    SetPlayerData(target, P_OSKIN, GetTeamData(teamid, O_WOMEN_SKIN));
                }

                ResetSkin(target);
            }

            Fracranknamekmonarch(teamid, newrank, fracname, sizeof(fracname));
            Fracesckmonarch(fracname, fracescaped, sizeof(fracescaped));

            format
            (
                fracpayload,
                sizeof(fracpayload),
                "{\"page\":9,\"type\":3,\"new_rank\":%d,\"new_rank_name\":\"%s\"}",
                newrank,
                fracescaped
            );
            Fracsendkmonarch(playerid, fracpayload);
            return 1;
        }
        case 17:
        {
            new newwarn = owarn;

            if (changeid == 1)
            {
                newwarn++;
            }
            else if (newwarn > 0)
            {
                newwarn--;
            }

            if (newwarn >= 3)
            {
                if (target != INVALID_PLAYER_ID)
                {
                    SetPlayerData(target, P_OWARN, 0);
                    InvitePlayer(target, 0, 0, true);
                }
                else
                {
                    format(fracpayload, sizeof(fracpayload), "UPDATE accounts SET owarn=0,team=0,job=0,org_skin=0 WHERE id=%d", uid);
                    mysql_query(mysql, fracpayload, false);
                }

                fracchosen[playerid] = 0;
                format(fracpayload, sizeof(fracpayload), "{\"page\":9,\"type\":5,\"dismissed_account_id\":%d}", uid);
                Fracsendkmonarch(playerid, fracpayload);
                return 1;
            }

            format(fracpayload, sizeof(fracpayload), "UPDATE accounts SET owarn=%d WHERE id=%d", newwarn, uid);
            mysql_query(mysql, fracpayload, false);

            if (target != INVALID_PLAYER_ID)
            {
                SetPlayerData(target, P_OWARN, newwarn);
            }

            format
            (
                fracpayload,
                sizeof(fracpayload),
                "{\"page\":9,\"type\":4,\"reprimand\":%d}",
                newwarn
            );
            Fracsendkmonarch(playerid, fracpayload);
            return 1;
        }
        case 18:
        {
            if (target != INVALID_PLAYER_ID)
            {
                UnInvite(playerid, target, "GUI");
            }
            else
            {
                format(fracpayload, sizeof(fracpayload), "UPDATE accounts SET owarn=0,team=0,job=0,org_skin=0 WHERE id=%d", uid);
                mysql_query(mysql, fracpayload, false);
            }

            fracchosen[playerid] = 0;
            format(fracpayload, sizeof(fracpayload), "{\"page\":9,\"type\":5,\"dismissed_account_id\":%d}", uid);
            Fracsendkmonarch(playerid, fracpayload);
            return 1;
        }
    }

    return 1;
}





