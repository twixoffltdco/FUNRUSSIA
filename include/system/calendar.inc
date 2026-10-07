#if defined _event_calendar_included
    #endinput
#endif
#define _event_calendar_included


#define CALENDAR_GUI_ID                 (71)
#define CALENDAR_EVENT_ID               (1)
#define CALENDAR_EVENT_TOTAL_DAYS       (42)
#define CALENDAR_SEASON_VERSION         (2)
#define CALENDAR_DAY_SECONDS            (86400)
#define CALENDAR_REQUIRED_PLAY_SECONDS  (1200)
#define CALENDAR_UPDATE_INTERVAL        (3600000)
#define CALENDAR_PLAYER_TICK_INTERVAL   (15000)
#define CALENDAR_BONUS_REWARDS          (5)
#define CALENDAR_BONUS_MIN_LEVEL        (4)
#define CALENDAR_REWARD_CASE_ID         (100)
#define CALENDAR_MAIN_REWARD_BASE       (4000)
#define CALENDAR_BONUS_REWARD_BASE      (4010)

#define CALENDAR_REWARD_NOT_STARTED     (0)
#define CALENDAR_REWARD_IN_PROGRESS     (1)
#define CALENDAR_REWARD_AVAILABLE       (2)
#define CALENDAR_REWARD_RECEIVED        (3)

#define CALENDAR_BONUS_NOT_RECEIVED             (0)
#define CALENDAR_BONUS_NOT_RECEIVED_LOW_LEVEL   (1)
#define CALENDAR_BONUS_AVAILABLE                (2)
#define CALENDAR_BONUS_AVAILABLE_LOW_LEVEL      (3)
#define CALENDAR_BONUS_RECEIVED                 (4)

#define CALENDAR_PACKET_BUTTON          (1)
#define CALENDAR_PACKET_GET_REWARD      (2)
#define CALENDAR_REWARD_LIST_MAIN       (1)
#define CALENDAR_REWARD_LIST_BONUS      (2)
#define CALENDAR_BUTTON_CLOSE           (2)

forward Calendar_UpdateDaysLeft();
forward Calendar_OnGlobalDaysUpdated();
forward Calendar_OnGlobalStateLoaded();
forward Calendar_OnPlayerLoaded(playerid, account_id);
forward Calendar_PlayerTick();
forward Calendar_FinishOpen(playerid, account_id, open_serial, open_attempt);
forward Calendar_SendOpeningState(playerid, account_id, open_serial, attempt);
forward Calendar_ClearCloseGuard(playerid, account_id, open_serial);

new g_CalendarEndTime;
new g_CalendarCachedDaysLeft = CALENDAR_EVENT_TOTAL_DAYS;
new g_CalendarTickPhase;
new bool:g_CalendarInitialized;
new g_CalendarGlobalTimer = -1;
new g_CalendarPlayerTimer = -1;
new g_CalendarOpenTimer[MAX_PLAYERS] = {-1, ...};
new g_CalendarSyncTimer[MAX_PLAYERS] = {-1, ...};
new g_CalendarGuardTimer[MAX_PLAYERS] = {-1, ...};

new bool:g_CalendarPlayerLoaded[MAX_PLAYERS];
new bool:g_CalendarPlayerLoading[MAX_PLAYERS];
new bool:g_CalendarPlayerOpen[MAX_PLAYERS];
new bool:g_CalendarIgnoreNextClose[MAX_PLAYERS];
new g_CalendarOpenSerial[MAX_PLAYERS];
new g_CalendarPlayerAccount[MAX_PLAYERS];
new g_CalendarPlayerLastTick[MAX_PLAYERS];
new g_CalendarPlayerDirtyDay[MAX_PLAYERS];
new g_CalendarPlayerClaimedCount[MAX_PLAYERS];
new g_CalendarPlayerLastClaimTime[MAX_PLAYERS];
new g_CalendarPlayerSeconds[MAX_PLAYERS][CALENDAR_EVENT_TOTAL_DAYS];
new bool:g_CalendarPlayerClaimed[MAX_PLAYERS][CALENDAR_EVENT_TOTAL_DAYS];
new bool:g_CalendarBonusClaimed[MAX_PLAYERS][CALENDAR_BONUS_REWARDS];

stock Calendar_GetSecondsUntilReset()
{
    new hour, minute, second;
    gettime(hour, minute, second);

    new seconds_until_reset = CALENDAR_DAY_SECONDS -
        (hour * 3600 + minute * 60 + second);

    if(seconds_until_reset < 1 || seconds_until_reset > CALENDAR_DAY_SECONDS)
        seconds_until_reset = CALENDAR_DAY_SECONDS;

    return seconds_until_reset;
}

stock Calendar_GetDaysLeft()
{
    if(g_CalendarEndTime > 0)
    {
        new seconds_left = g_CalendarEndTime - gettime();
        if(seconds_left <= 0) return 0;

        new days_left = (seconds_left + CALENDAR_DAY_SECONDS - 1) / CALENDAR_DAY_SECONDS;
        if(days_left < 0) days_left = 0;
        else if(days_left > CALENDAR_EVENT_TOTAL_DAYS) days_left = CALENDAR_EVENT_TOTAL_DAYS;
        return days_left;
    }

    return g_CalendarCachedDaysLeft;
}


stock Calendar_GetTodayStart()
{
    new hour, minute, second;
    new current_time = gettime();
    gettime(hour, minute, second);
    return current_time - (hour * 3600 + minute * 60 + second);
}

stock Calendar_GetPlayerActiveDay(playerid)
{
    if(Calendar_GetDaysLeft() <= 0) return -1;
    if(g_CalendarPlayerLastClaimTime[playerid] >= Calendar_GetTodayStart())
        return -1;

    new active_day = g_CalendarPlayerClaimedCount[playerid];
    if(active_day < 0 || active_day >= CALENDAR_EVENT_TOTAL_DAYS)
        return -1;
    return active_day;
}

stock Calendar_GetPlaySecondsLeft(playerid, active_day)
{
    if(active_day < 0 || active_day >= CALENDAR_EVENT_TOTAL_DAYS) return -1;
    if(g_CalendarPlayerClaimed[playerid][active_day]) return 0;

    new seconds_left = CALENDAR_REQUIRED_PLAY_SECONDS -
        g_CalendarPlayerSeconds[playerid][active_day];

    if(seconds_left < 0) seconds_left = 0;
    else if(seconds_left > CALENDAR_REQUIRED_PLAY_SECONDS)
        seconds_left = CALENDAR_REQUIRED_PLAY_SECONDS;

    return seconds_left;
}

stock Calendar_GetRewardState(playerid, day, active_day)
{
    if(day < 0 || day >= CALENDAR_EVENT_TOTAL_DAYS)
        return CALENDAR_REWARD_NOT_STARTED;

    if(g_CalendarPlayerClaimed[playerid][day])
        return CALENDAR_REWARD_RECEIVED;

    if(day != active_day)
        return CALENDAR_REWARD_NOT_STARTED;

    if(g_CalendarPlayerSeconds[playerid][day] >= CALENDAR_REQUIRED_PLAY_SECONDS)
        return CALENDAR_REWARD_AVAILABLE;

    return CALENDAR_REWARD_IN_PROGRESS;
}

stock Calendar_BuildMainStatePacket(playerid, active_day, output[], size)
{
    format(output, size, "{\"t\":1,\"ml\":[");

    for(new day = 0; day < CALENDAR_EVENT_TOTAL_DAYS; day++)
    {
        new value[8];
        format(value, sizeof value, "%s%d",
            day == 0 ? "" : ",",
            Calendar_GetRewardState(playerid, day, active_day)
        );
        strcat(output, value, size);
    }

    strcat(output, "]}", size);
    return 1;
}

stock Calendar_GetBonusRequiredDays(bonus_id)
{
    static const bonus_days[CALENDAR_BONUS_REWARDS] = {5, 10, 15, 20, 25};

    if(bonus_id < 0 || bonus_id >= CALENDAR_BONUS_REWARDS) return -1;
    return bonus_days[bonus_id];
}


stock Calendar_BuildBonusStatePacket(playerid, days_played, output[], size)
{
    new bool:level_allowed =
        (GetPlayerLevel(playerid) >= CALENDAR_BONUS_MIN_LEVEL);

    format(output, size, "{\"t\":3,\"bl\":[");
    for(new index = 0; index < CALENDAR_BONUS_REWARDS; index++)
    {
        new reward_state;
        if(g_CalendarBonusClaimed[playerid][index])
        {
            reward_state = CALENDAR_BONUS_RECEIVED;
        }
        else if(days_played >= Calendar_GetBonusRequiredDays(index))
        {
            reward_state = level_allowed
                ? CALENDAR_BONUS_AVAILABLE
                : CALENDAR_BONUS_AVAILABLE_LOW_LEVEL;
        }
        else
        {
            reward_state = level_allowed
                ? CALENDAR_BONUS_NOT_RECEIVED
                : CALENDAR_BONUS_NOT_RECEIVED_LOW_LEVEL;
        }

        new value[8];
        format(value, sizeof value, "%s%d",
            index == 0 ? "" : ",",
            reward_state
        );
        strcat(output, value, size);
    }

    strcat(output, "]}", size);
    return 1;
}

stock Calendar_SendStateUpdate(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;

    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0 || g_CalendarPlayerAccount[playerid] != account_id) return 0;

    new active_day = Calendar_GetPlayerActiveDay(playerid);
    new days_played = g_CalendarPlayerClaimedCount[playerid];

    if(days_played < 0) days_played = 0;
    else if(days_played > CALENDAR_EVENT_TOTAL_DAYS)
        days_played = CALENDAR_EVENT_TOTAL_DAYS;

    new packet[256];
    new Node:json;

    Calendar_BuildMainStatePacket(playerid, active_day, packet, sizeof packet);
    if(JSON_Parse(packet, json) == 0)
    {
        OnPacketIncoming(playerid, CALENDAR_GUI_ID, json);
        JSON_Cleanup(json);
    }

    Calendar_BuildBonusStatePacket(playerid, days_played, packet, sizeof packet);
    if(JSON_Parse(packet, json) == 0)
    {
        OnPacketIncoming(playerid, CALENDAR_GUI_ID, json);
        JSON_Cleanup(json);
    }
    return 1;
}

stock Calendar_Show(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;

    new days_left = Calendar_GetDaysLeft();
    new days_played = CALENDAR_EVENT_TOTAL_DAYS - days_left;
    new active_day = Calendar_GetPlayerActiveDay(playerid);

    if(days_played < 0) days_played = 0;
    else if(days_played > CALENDAR_EVENT_TOTAL_DAYS)
        days_played = CALENDAR_EVENT_TOTAL_DAYS;

    new Node:json = JSON_Object(
        "a", JSON_Int(days_left > 0 ? days_left : 1),
        "d", JSON_Int(days_left),
        "dp", JSON_Int(days_played),
        "tu", JSON_Int(Calendar_GetSecondsUntilReset()),
        "tp", JSON_Int(Calendar_GetPlaySecondsLeft(playerid, active_day)),
        "vd", JSON_Int(0),
        "vs", JSON_Int(0),
        "pl", JSON_Int(4),
        "lv", JSON_Int(GetPlayerLevel(playerid)),
        "bn", JSON_Int(0),
        "i", JSON_Int(0),
        "o", JSON_Int(1)
    );

    g_CalendarPlayerOpen[playerid] = true;
    ShowPlayerGUI(playerid, CALENDAR_GUI_ID, json);
    JSON_Cleanup(json);
    return 1;
}

stock Calendar_ResetPlayer(playerid)
{
    if(g_CalendarOpenTimer[playerid] != -1) KillTimer(g_CalendarOpenTimer[playerid]);
    if(g_CalendarSyncTimer[playerid] != -1) KillTimer(g_CalendarSyncTimer[playerid]);
    if(g_CalendarGuardTimer[playerid] != -1) KillTimer(g_CalendarGuardTimer[playerid]);
    g_CalendarOpenTimer[playerid] = -1;
    g_CalendarSyncTimer[playerid] = -1;
    g_CalendarGuardTimer[playerid] = -1;
    g_CalendarOpenSerial[playerid]++;
    g_CalendarPlayerLoaded[playerid] = false;
    g_CalendarPlayerLoading[playerid] = false;
    g_CalendarPlayerOpen[playerid] = false;
    g_CalendarIgnoreNextClose[playerid] = false;
    g_CalendarPlayerAccount[playerid] = 0;
    g_CalendarPlayerLastTick[playerid] = gettime();
    g_CalendarPlayerDirtyDay[playerid] = -1;
    g_CalendarPlayerClaimedCount[playerid] = 0;
    g_CalendarPlayerLastClaimTime[playerid] = 0;

    for(new day = 0; day < CALENDAR_EVENT_TOTAL_DAYS; day++)
    {
        g_CalendarPlayerSeconds[playerid][day] = 0;
        g_CalendarPlayerClaimed[playerid][day] = false;
    }

    for(new bonus_id = 0; bonus_id < CALENDAR_BONUS_REWARDS; bonus_id++)
        g_CalendarBonusClaimed[playerid][bonus_id] = false;
    return 1;
}


stock Calendar_SavePlayerState(playerid, bool:synchronous = false)
{
    new account_id = g_CalendarPlayerAccount[playerid];
    if(account_id <= 0) return 0;

    new query[512];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO `calendar_user_state` " \
        "(`account_id`,`season_version`,`claimed_count`,`last_claim_at`,`updated_at`) " \
        "VALUES (%d,%d,%d,%d,UNIX_TIMESTAMP()) " \
        "ON DUPLICATE KEY UPDATE " \
        "`claimed_count`=GREATEST(`claimed_count`,VALUES(`claimed_count`))," \
        "`last_claim_at`=GREATEST(`last_claim_at`,VALUES(`last_claim_at`))," \
        "`updated_at`=VALUES(`updated_at`)",
        account_id,
        CALENDAR_SEASON_VERSION,
        g_CalendarPlayerClaimedCount[playerid],
        g_CalendarPlayerLastClaimTime[playerid]
    );

    if(synchronous) mysql_query(mysql, query, false);
    else mysql_tquery(mysql, query);
    return 1;
}

stock Calendar_LoadPlayer(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;

    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0) return 0;

    if(g_CalendarPlayerLoading[playerid] &&
        g_CalendarPlayerAccount[playerid] == account_id) return 1;

    new bool:was_open = g_CalendarPlayerOpen[playerid];
    Calendar_ResetPlayer(playerid);
    g_CalendarPlayerOpen[playerid] = was_open;
    g_CalendarPlayerLoading[playerid] = true;
    g_CalendarPlayerAccount[playerid] = account_id;

    new query[1280];
    mysql_format(mysql, query, sizeof query,
        "SELECT 0 AS `entry_type`,`day_number` AS `entry_id`,`play_seconds`,`claimed`," \
        "`updated_at`,0 AS `claimed_count`,0 AS `last_claim_at` " \
        "FROM `calendar_user_progress` " \
        "WHERE `account_id`=%d AND `season_version`=%d " \
        "UNION ALL " \
        "SELECT 1 AS `entry_type`,`bonus_id` AS `entry_id`,0 AS `play_seconds`,`claimed`," \
        "0 AS `updated_at`,0 AS `claimed_count`,0 AS `last_claim_at` " \
        "FROM `calendar_user_bonus` " \
        "WHERE `account_id`=%d AND `season_version`=%d " \
        "UNION ALL " \
        "SELECT 2 AS `entry_type`,0 AS `entry_id`,0 AS `play_seconds`,0 AS `claimed`," \
        "0 AS `updated_at`,`claimed_count`,`last_claim_at` " \
        "FROM `calendar_user_state` " \
        "WHERE `account_id`=%d AND `season_version`=%d",
        account_id,
        CALENDAR_SEASON_VERSION,
        account_id,
        CALENDAR_SEASON_VERSION,
        account_id,
        CALENDAR_SEASON_VERSION
    );
    mysql_tquery(mysql, query, "Calendar_OnPlayerLoaded", "ii",
        playerid, account_id);
    return 1;
}

public Calendar_OnPlayerLoaded(playerid, account_id)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(GetPlayerAccountID(playerid) != account_id) return 1;
    if(g_CalendarPlayerAccount[playerid] != account_id) return 1;

    new rows, fields;
    new legacy_claimed_count;
    new legacy_last_claim_time;
    new state_claimed_count = -1;
    new state_last_claim_time;
    cache_get_data(rows, fields);

    for(new row = 0; row < rows; row++)
    {
        new entry_type = cache_get_field_content_int(row, "entry_type");
        new entry_id = cache_get_field_content_int(row, "entry_id");

        if(entry_type == 2)
        {
            state_claimed_count =
                cache_get_field_content_int(row, "claimed_count");
            state_last_claim_time =
                cache_get_field_content_int(row, "last_claim_at");
            continue;
        }

        if(entry_type == 1)
        {
            if(entry_id >= 0 && entry_id < CALENDAR_BONUS_REWARDS)
            {
                g_CalendarBonusClaimed[playerid][entry_id] =
                    (cache_get_field_content_int(row, "claimed") != 0);
            }
            continue;
        }

        new day_number = entry_id;
        if(day_number < 1 || day_number > CALENDAR_EVENT_TOTAL_DAYS) continue;

        new day = day_number - 1;
        new play_seconds = cache_get_field_content_int(row, "play_seconds");

        if(play_seconds < 0) play_seconds = 0;
        else if(play_seconds > CALENDAR_REQUIRED_PLAY_SECONDS)
            play_seconds = CALENDAR_REQUIRED_PLAY_SECONDS;

        g_CalendarPlayerSeconds[playerid][day] = play_seconds;
        if(cache_get_field_content_int(row, "claimed") != 0)
        {
            legacy_claimed_count++;
            new claim_time =
                cache_get_field_content_int(row, "updated_at");
            if(claim_time > legacy_last_claim_time)
                legacy_last_claim_time = claim_time;
        }
    }

    if(state_claimed_count < 0)
    {
        g_CalendarPlayerClaimedCount[playerid] = legacy_claimed_count;
        g_CalendarPlayerLastClaimTime[playerid] = legacy_last_claim_time;
        Calendar_SavePlayerState(playerid);
    }
    else
    {
        if(state_claimed_count > CALENDAR_EVENT_TOTAL_DAYS)
            state_claimed_count = CALENDAR_EVENT_TOTAL_DAYS;

        g_CalendarPlayerClaimedCount[playerid] = state_claimed_count;
        g_CalendarPlayerLastClaimTime[playerid] = state_last_claim_time;
    }

    if(g_CalendarPlayerClaimedCount[playerid] > CALENDAR_EVENT_TOTAL_DAYS)
        g_CalendarPlayerClaimedCount[playerid] = CALENDAR_EVENT_TOTAL_DAYS;

    for(new day = 0; day < CALENDAR_EVENT_TOTAL_DAYS; day++)
    {
        g_CalendarPlayerClaimed[playerid][day] =
            (day < g_CalendarPlayerClaimedCount[playerid]);
    }

    g_CalendarPlayerLoading[playerid] = false;
    g_CalendarPlayerLoaded[playerid] = true;
    g_CalendarPlayerLastTick[playerid] = gettime();

    if(g_CalendarPlayerOpen[playerid])
        Calendar_SendStateUpdate(playerid);
    return 1;
}

stock Calendar_SaveDay(playerid, day, bool:synchronous = false)
{
    if(day < 0 || day >= CALENDAR_EVENT_TOTAL_DAYS) return 0;

    new account_id = g_CalendarPlayerAccount[playerid];
    if(account_id <= 0) return 0;

    new query[640];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO `calendar_user_progress` " \
        "(`account_id`,`season_version`,`day_number`,`play_seconds`,`claimed`,`updated_at`) " \
        "VALUES (%d,%d,%d,%d,%d,UNIX_TIMESTAMP()) " \
        "ON DUPLICATE KEY UPDATE " \
        "`play_seconds`=GREATEST(`play_seconds`,VALUES(`play_seconds`))," \
        "`claimed`=GREATEST(`claimed`,VALUES(`claimed`))," \
        "`updated_at`=VALUES(`updated_at`)",
        account_id,
        CALENDAR_SEASON_VERSION,
        day + 1,
        g_CalendarPlayerSeconds[playerid][day],
        g_CalendarPlayerClaimed[playerid][day] ? 1 : 0
    );

    if(synchronous) mysql_query(mysql, query, false);
    else mysql_tquery(mysql, query);

    if(g_CalendarPlayerDirtyDay[playerid] == day)
        g_CalendarPlayerDirtyDay[playerid] = -1;
    return 1;
}



stock Calendar_SaveBonus(playerid, bonus_id)
{
    if(bonus_id < 0 || bonus_id >= CALENDAR_BONUS_REWARDS) return 0;

    new account_id = g_CalendarPlayerAccount[playerid];
    if(account_id <= 0) return 0;

    new query[512];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO `calendar_user_bonus` " \
        "(`account_id`,`season_version`,`bonus_id`,`claimed`,`updated_at`) " \
        "VALUES (%d,%d,%d,%d,UNIX_TIMESTAMP()) " \
        "ON DUPLICATE KEY UPDATE " \
        "`claimed`=GREATEST(`claimed`,VALUES(`claimed`))," \
        "`updated_at`=VALUES(`updated_at`)",
        account_id,
        CALENDAR_SEASON_VERSION,
        bonus_id,
        g_CalendarBonusClaimed[playerid][bonus_id] ? 1 : 0
    );
    mysql_tquery(mysql, query);
    return 1;
}

stock Calendar_AccumulatePlayer(playerid, current_time)
{
    if(!g_CalendarPlayerLoaded[playerid]) return 0;

    new last_tick = g_CalendarPlayerLastTick[playerid];
    g_CalendarPlayerLastTick[playerid] = current_time;
    if(last_tick <= 0 || current_time <= last_tick) return 0;

    new elapsed = current_time - last_tick;
    if(elapsed > 60) elapsed = 60;

    new active_day = Calendar_GetPlayerActiveDay(playerid);
    if(active_day < 0) return 0;
    if(g_CalendarPlayerClaimed[playerid][active_day]) return 0;
    if(g_CalendarPlayerSeconds[playerid][active_day] >= CALENDAR_REQUIRED_PLAY_SECONDS)
        return 0;

    if(g_CalendarPlayerDirtyDay[playerid] != -1 &&
        g_CalendarPlayerDirtyDay[playerid] != active_day)
    {
        Calendar_SaveDay(playerid, g_CalendarPlayerDirtyDay[playerid]);
    }

    new old_seconds = g_CalendarPlayerSeconds[playerid][active_day];
    g_CalendarPlayerSeconds[playerid][active_day] += elapsed;

    if(g_CalendarPlayerSeconds[playerid][active_day] >= CALENDAR_REQUIRED_PLAY_SECONDS)
        g_CalendarPlayerSeconds[playerid][active_day] = CALENDAR_REQUIRED_PLAY_SECONDS;

    g_CalendarPlayerDirtyDay[playerid] = active_day;

    if(old_seconds < CALENDAR_REQUIRED_PLAY_SECONDS &&
        g_CalendarPlayerSeconds[playerid][active_day] >= CALENDAR_REQUIRED_PLAY_SECONDS)
    {
        Calendar_SaveDay(playerid, active_day);
        if(g_CalendarPlayerOpen[playerid]) Calendar_SendStateUpdate(playerid);
    }
    return 1;
}

public Calendar_PlayerTick()
{
    new current_time = gettime();
    new phase = g_CalendarTickPhase++ & 3;

    foreach(new playerid : Player)
    {
        if(!IsPlayerLogged(playerid) || !g_CalendarPlayerLoaded[playerid]) continue;

        Calendar_AccumulatePlayer(playerid, current_time);

        new dirty_day = g_CalendarPlayerDirtyDay[playerid];
        if(dirty_day != -1 && (playerid & 3) == phase)
            Calendar_SaveDay(playerid, dirty_day);

        if(g_CalendarPlayerOpen[playerid])
            Calendar_SendStateUpdate(playerid);
    }
    return 1;
}


stock Calendar_OnDisconnect(playerid)
{
    if(g_CalendarPlayerLoaded[playerid])
    {
        Calendar_AccumulatePlayer(playerid, gettime());

        new dirty_day = g_CalendarPlayerDirtyDay[playerid];
        if(dirty_day != -1) Calendar_SaveDay(playerid, dirty_day);
    }

    Calendar_ResetPlayer(playerid);
    return 1;
}

stock Calendar_FlushAll()
{
    new current_time = gettime();

    foreach(new playerid : Player)
    {
        if(!g_CalendarPlayerLoaded[playerid]) continue;

        Calendar_AccumulatePlayer(playerid, current_time);
        new dirty_day = g_CalendarPlayerDirtyDay[playerid];
        if(dirty_day != -1) Calendar_SaveDay(playerid, dirty_day, true);
        Calendar_SavePlayerState(playerid, true);
    }
    return 1;
}

stock Calendar_GetRewardInventoryData(itemid, name[], name_len, &type, &internal, &count, &rarity, &price)
{
    name[0] = EOS;
    type = 0;
    internal = 0;
    count = 0;
    rarity = 0;
    price = 0;

    switch(itemid)
    {
        case CALENDAR_MAIN_REWARD_BASE + 1:
        {
            format(name, name_len, "VIP GOLD na 2 dnya");
            type = 9; internal = 2; count = 48; rarity = 2;
            return 1;
        }
        case CALENDAR_MAIN_REWARD_BASE + 2:
        {
            format(name, name_len, "10 BC");
            type = 3; count = 10; rarity = 1;
            return 1;
        }
        case CALENDAR_MAIN_REWARD_BASE + 3:
        {
            format(name, name_len, "1000 BP EXP");
            type = 13; count = 1000; rarity = 1;
            return 1;
        }
        case CALENDAR_MAIN_REWARD_BASE + 4:
        {
            format(name, name_len, "BMW na 12 chasov");
            type = 5; internal = 402; count = 12; rarity = 3;
            return 1;
        }
        case CALENDAR_MAIN_REWARD_BASE + 5:
        {
            format(name, name_len, "X2 na 24 chasa");
            type = 8; count = 24; rarity = 1;
            return 1;
        }
        case CALENDAR_MAIN_REWARD_BASE + 6:
        {
            format(name, name_len, "25000 RUB");
            type = 2; count = 25000; rarity = 1;
            return 1;
        }
        case CALENDAR_MAIN_REWARD_BASE + 7:
        {
            format(name, name_len, "Aksessuar");
            type = 11; internal = 890; count = 1; rarity = 2;
            return 1;
        }
        case CALENDAR_BONUS_REWARD_BASE + 1, CALENDAR_BONUS_REWARD_BASE + 2, CALENDAR_BONUS_REWARD_BASE + 3:
        {
            format(name, name_len, "Keys BOMZhA x1");
            type = 15; internal = 1; count = 1; rarity = 2;
            return 1;
        }
        case CALENDAR_BONUS_REWARD_BASE + 4:
        {
            format(name, name_len, "Keys BOMZhA x2");
            type = 15; internal = 1; count = 2; rarity = 3;
            return 1;
        }
        case CALENDAR_BONUS_REWARD_BASE + 5:
        {
            format(name, name_len, "Standartnyy keys x1");
            type = 15; internal = 2; count = 1; rarity = 4;
            return 1;
        }
    }
    return 0;
}

stock Calendar_AddCaseToInventory(playerid, caseid, amount)
{
    if(caseid < 1 || caseid > MAX_CASES || amount <= 0) return 0;

    new values[MAX_CASES];
    for(new i = 0; i < MAX_CASES; i++) values[i] = 0;

    if(strlen(g_player_case[playerid]) > 0)
    {
        new parts[MAX_CASES][16];
        new count = explode(parts, g_player_case[playerid], ',', sizeof(parts));
        for(new i = 0; i < count && i < MAX_CASES; i++)
            values[i] = strval(parts[i]);
    }

    values[caseid - 1] += amount;
    if(values[caseid - 1] > 300) values[caseid - 1] = 300;

    new data[1024], part[16];
    data[0] = EOS;
    for(new i = 0; i < MAX_CASES; i++)
    {
        format(part, sizeof(part), "%d", values[i]);
        if(i > 0) strcat(data, ",", sizeof(data));
        strcat(data, part, sizeof(data));
    }

    format(g_player_case[playerid], sizeof(g_player_case[]), "%s", data);
    UpdatePlayerDatabaseString(playerid, "case", g_player_case[playerid]);
    return 1;
}

stock Calendar_GiveRewardToStorage(playerid, day_number)
{
    if(day_number < 1 || day_number > CALENDAR_EVENT_TOTAL_DAYS) return 0;
    new itemid = CALENDAR_MAIN_REWARD_BASE + (((day_number - 1) % 7) + 1);
    return AddPlayerCaseReward(playerid, CALENDAR_REWARD_CASE_ID, itemid, false);
}

stock Calendar_GiveBonusRewardToStorage(playerid, bonus_id)
{
    if(bonus_id < 0 || bonus_id >= CALENDAR_BONUS_REWARDS) return 0;
    return AddPlayerCaseReward(playerid, CALENDAR_REWARD_CASE_ID, CALENDAR_BONUS_REWARD_BASE + bonus_id + 1, false);
}

stock Calendar_ClaimBonusReward(playerid, bonus_id)
{
    if(bonus_id < 0 || bonus_id >= CALENDAR_BONUS_REWARDS)
    {
        Calendar_SendStateUpdate(playerid);
        return 1;
    }

    if(g_CalendarBonusClaimed[playerid][bonus_id])
    {
        Calendar_SendStateUpdate(playerid);
        return 1;
    }

    if(GetPlayerLevel(playerid) < CALENDAR_BONUS_MIN_LEVEL)
    {
        Calendar_SendStateUpdate(playerid);
        return 1;
    }

    new days_played = g_CalendarPlayerClaimedCount[playerid];
    if(days_played < Calendar_GetBonusRequiredDays(bonus_id))
    {
        Calendar_SendStateUpdate(playerid);
        return 1;
    }

    if(!Calendar_GiveBonusRewardToStorage(playerid, bonus_id))
        return 1;

    g_CalendarBonusClaimed[playerid][bonus_id] = true;
    Calendar_SaveBonus(playerid, bonus_id);
    Calendar_SendStateUpdate(playerid);
    return 1;
}

stock Calendar_HandlePacket(playerid, Node:json)
{
    new close_state;
    if(JSON_GetType(json, "c") == JSON_NODE_NUMBER)
    {
        JSON_GetInt(json, "c", close_state);
        if(close_state == 1)
        {
            if(g_CalendarIgnoreNextClose[playerid])
            {
                g_CalendarIgnoreNextClose[playerid] = false;
                return 1;
            }

            g_CalendarPlayerOpen[playerid] = false;
            if(g_CalendarSyncTimer[playerid] != -1) KillTimer(g_CalendarSyncTimer[playerid]);
            g_CalendarSyncTimer[playerid] = -1;
            return 1;
        }
    }

    new type = -1;
    JSON_GetInt(json, "t", type);

    if(type == CALENDAR_PACKET_BUTTON)
    {
        new button = -1;
        JSON_GetInt(json, "b", button);
        if(button == CALENDAR_BUTTON_CLOSE)
        {
            g_CalendarPlayerOpen[playerid] = false;
            g_CalendarIgnoreNextClose[playerid] = false;
            if(g_CalendarSyncTimer[playerid] != -1) KillTimer(g_CalendarSyncTimer[playerid]);
            g_CalendarSyncTimer[playerid] = -1;
        }
        return 1;
    }

    if(type != CALENDAR_PACKET_GET_REWARD) return 0;

    if(!g_CalendarPlayerLoaded[playerid])
    {
        if(!g_CalendarPlayerLoading[playerid]) Calendar_LoadPlayer(playerid);
        return 1;
    }

    Calendar_AccumulatePlayer(playerid, gettime());

    new reward_list = -1;
    new reward_id = -1;
    JSON_GetInt(json, "l", reward_list);
    JSON_GetInt(json, "id", reward_id);

    if(reward_list == CALENDAR_REWARD_LIST_BONUS)
        return Calendar_ClaimBonusReward(playerid, reward_id);

    new active_day = Calendar_GetPlayerActiveDay(playerid);
    if(active_day < 0)
    {
        Calendar_SendStateUpdate(playerid);
        return 1;
    }

    if(reward_list != CALENDAR_REWARD_LIST_MAIN || reward_id != active_day)
    {
        Calendar_SendStateUpdate(playerid);
        return 1;
    }

    if(g_CalendarPlayerClaimed[playerid][active_day])
    {
        Calendar_SendStateUpdate(playerid);
        return 1;
    }

    if(g_CalendarPlayerSeconds[playerid][active_day] < CALENDAR_REQUIRED_PLAY_SECONDS)
    {
        Calendar_SendStateUpdate(playerid);
        return 1;
    }

    if(!Calendar_GiveRewardToStorage(playerid, active_day + 1))
        return 1;

    g_CalendarPlayerClaimed[playerid][active_day] = true;
    g_CalendarPlayerClaimedCount[playerid]++;
    g_CalendarPlayerLastClaimTime[playerid] = gettime();
    g_CalendarPlayerDirtyDay[playerid] = active_day;
    Calendar_SaveDay(playerid, active_day);
    Calendar_SavePlayerState(playerid);
    Calendar_SendStateUpdate(playerid);
    return 1;
}

stock Calendar_BuildDaysUpdateQuery(query[], size)
{
    return format(query, size,
        "UPDATE `calendar_event_state` SET " \
        "`days_left`=GREATEST(0,LEAST(`total_days`,((`end_time`-UNIX_TIMESTAMP()+%d) DIV %d)))," \
        "`last_update_date`=CURDATE() WHERE `id`=%d",
        CALENDAR_DAY_SECONDS - 1,
        CALENDAR_DAY_SECONDS,
        CALENDAR_EVENT_ID
    );
}



stock Calendar_Init()
{
    if(g_CalendarInitialized) return 1;
    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `calendar_event_state` (" \
        "`id` TINYINT UNSIGNED NOT NULL," \
        "`total_days` SMALLINT UNSIGNED NOT NULL DEFAULT 42," \
        "`start_time` INT UNSIGNED NOT NULL," \
        "`end_time` INT UNSIGNED NOT NULL," \
        "`days_left` SMALLINT UNSIGNED NOT NULL DEFAULT 42," \
        "`last_update_date` DATE NOT NULL," \
        "`season_version` SMALLINT UNSIGNED NOT NULL DEFAULT 2," \
        "PRIMARY KEY (`id`)" \
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci",
        false
    );
    if(mysql_errno() != 0)
    {
        print("[Calendar] Failed to create calendar_event_state");
        return 0;
    }

    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `calendar_user_progress` (" \
        "`account_id` INT UNSIGNED NOT NULL," \
        "`season_version` SMALLINT UNSIGNED NOT NULL," \
        "`day_number` TINYINT UNSIGNED NOT NULL," \
        "`play_seconds` SMALLINT UNSIGNED NOT NULL DEFAULT 0," \
        "`claimed` TINYINT UNSIGNED NOT NULL DEFAULT 0," \
        "`updated_at` INT UNSIGNED NOT NULL DEFAULT 0," \
        "PRIMARY KEY (`account_id`,`season_version`,`day_number`)," \
        "KEY `idx_calendar_progress_season` (`season_version`,`day_number`)" \
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci",
        false
    );
    if(mysql_errno() != 0)
    {
        print("[Calendar] Failed to create calendar_user_progress");
        return 0;
    }

    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `calendar_user_state` (" \
        "`account_id` INT UNSIGNED NOT NULL," \
        "`season_version` SMALLINT UNSIGNED NOT NULL," \
        "`claimed_count` TINYINT UNSIGNED NOT NULL DEFAULT 0," \
        "`last_claim_at` INT UNSIGNED NOT NULL DEFAULT 0," \
        "`updated_at` INT UNSIGNED NOT NULL DEFAULT 0," \
        "PRIMARY KEY (`account_id`,`season_version`)," \
        "KEY `idx_calendar_state_season` (`season_version`,`claimed_count`)" \
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci",
        false
    );
    if(mysql_errno() != 0)
    {
        print("[Calendar] Failed to create calendar_user_state");
        return 0;
    }

    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `calendar_user_bonus` (" \
        "`account_id` INT UNSIGNED NOT NULL," \
        "`season_version` SMALLINT UNSIGNED NOT NULL," \
        "`bonus_id` TINYINT UNSIGNED NOT NULL," \
        "`claimed` TINYINT UNSIGNED NOT NULL DEFAULT 0," \
        "`updated_at` INT UNSIGNED NOT NULL DEFAULT 0," \
        "PRIMARY KEY (`account_id`,`season_version`,`bonus_id`)," \
        "KEY `idx_calendar_bonus_season` (`season_version`,`bonus_id`)" \
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci",
        false
    );
    if(mysql_errno() != 0)
    {
        print("[Calendar] Failed to create calendar_user_bonus");
        return 0;
    }

    new query[512];
    mysql_format(mysql, query, sizeof query,
        "INSERT IGNORE INTO `calendar_event_state` " \
        "(`id`,`total_days`,`start_time`,`end_time`,`days_left`,`last_update_date`,`season_version`) " \
        "VALUES (%d,%d,UNIX_TIMESTAMP(CURDATE())," \
        "UNIX_TIMESTAMP(DATE_ADD(CURDATE(),INTERVAL %d DAY)),%d,CURDATE(),%d)",
        CALENDAR_EVENT_ID,
        CALENDAR_EVENT_TOTAL_DAYS,
        CALENDAR_EVENT_TOTAL_DAYS,
        CALENDAR_EVENT_TOTAL_DAYS,
        CALENDAR_SEASON_VERSION
    );
    mysql_query(mysql, query, false);
    if(mysql_errno() != 0)
    {
        print("[Calendar] Failed to initialize calendar event");
        return 0;
    }

    mysql_format(mysql, query, sizeof query,
        "UPDATE `calendar_event_state` SET " \
        "`total_days`=%d," \
        "`start_time`=UNIX_TIMESTAMP(CURDATE())," \
        "`end_time`=UNIX_TIMESTAMP(DATE_ADD(CURDATE(),INTERVAL %d DAY))," \
        "`days_left`=%d," \
        "`last_update_date`=CURDATE()," \
        "`season_version`=%d " \
        "WHERE `id`=%d AND (`season_version`<%d OR `total_days`<>%d)",
        CALENDAR_EVENT_TOTAL_DAYS,
        CALENDAR_EVENT_TOTAL_DAYS,
        CALENDAR_EVENT_TOTAL_DAYS,
        CALENDAR_SEASON_VERSION,
        CALENDAR_EVENT_ID,
        CALENDAR_SEASON_VERSION,
        CALENDAR_EVENT_TOTAL_DAYS
    );
    mysql_query(mysql, query, false);
    if(mysql_errno() != 0)
    {
        print("[Calendar] Failed to update calendar season");
        return 0;
    }

    Calendar_UpdateDaysLeft();
    g_CalendarGlobalTimer = SetTimer("Calendar_UpdateDaysLeft", CALENDAR_UPDATE_INTERVAL, true);
    g_CalendarPlayerTimer = SetTimer("Calendar_PlayerTick", CALENDAR_PLAYER_TICK_INTERVAL, true);
    g_CalendarInitialized = true;
    return 1;
}



stock Calendar_Shutdown()
{
    if(g_CalendarGlobalTimer != -1) KillTimer(g_CalendarGlobalTimer);
    if(g_CalendarPlayerTimer != -1) KillTimer(g_CalendarPlayerTimer);
    g_CalendarGlobalTimer = -1;
    g_CalendarPlayerTimer = -1;

    foreach(new playerid : Player)
    {
        if(g_CalendarOpenTimer[playerid] != -1) KillTimer(g_CalendarOpenTimer[playerid]);
        if(g_CalendarSyncTimer[playerid] != -1) KillTimer(g_CalendarSyncTimer[playerid]);
        if(g_CalendarGuardTimer[playerid] != -1) KillTimer(g_CalendarGuardTimer[playerid]);
        g_CalendarOpenTimer[playerid] = -1;
        g_CalendarSyncTimer[playerid] = -1;
        g_CalendarGuardTimer[playerid] = -1;
    }
    g_CalendarInitialized = false;
    return 1;
}

public Calendar_UpdateDaysLeft()
{
    new query[256];
    Calendar_BuildDaysUpdateQuery(query, sizeof query);
    mysql_tquery(mysql, query, "Calendar_OnGlobalDaysUpdated");
    return 1;
}

public Calendar_OnGlobalDaysUpdated()
{
    new query[320];
    mysql_format(mysql, query, sizeof query,
        "SELECT `end_time`," \
        "GREATEST(0,LEAST(`total_days`,((`end_time`-UNIX_TIMESTAMP()+%d) DIV %d))) AS `days_left` " \
        "FROM `calendar_event_state` WHERE `id`=%d LIMIT 1",
        CALENDAR_DAY_SECONDS - 1,
        CALENDAR_DAY_SECONDS,
        CALENDAR_EVENT_ID
    );
    mysql_tquery(mysql, query, "Calendar_OnGlobalStateLoaded");
    return 1;
}

public Calendar_OnGlobalStateLoaded()
{
    if(cache_num_rows() == 0) return 1;

    g_CalendarEndTime = cache_get_field_content_int(0, "end_time");
    g_CalendarCachedDaysLeft = cache_get_field_content_int(0, "days_left");

    if(g_CalendarCachedDaysLeft < 0) g_CalendarCachedDaysLeft = 0;
    else if(g_CalendarCachedDaysLeft > CALENDAR_EVENT_TOTAL_DAYS)
        g_CalendarCachedDaysLeft = CALENDAR_EVENT_TOTAL_DAYS;
    return 1;
}

stock Calendar_Open(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0) return 0;

    if(!g_CalendarPlayerLoaded[playerid] && !g_CalendarPlayerLoading[playerid])
        Calendar_LoadPlayer(playerid);

    g_CalendarPlayerOpen[playerid] = false;
    new open_serial = ++g_CalendarOpenSerial[playerid];
    g_CalendarIgnoreNextClose[playerid] = true;
    HidePlayerGUI(playerid, CALENDAR_GUI_ID);
    g_CalendarOpenTimer[playerid] = SetTimerEx("Calendar_FinishOpen", 75, false, "iiii",
        playerid, account_id, open_serial, 0);
    g_CalendarGuardTimer[playerid] = SetTimerEx("Calendar_ClearCloseGuard", 3000, false, "iii",
        playerid, account_id, open_serial);
    return 1;
}

public Calendar_ClearCloseGuard(playerid, account_id, open_serial)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(GetPlayerAccountID(playerid) != account_id) return 1;
    if(g_CalendarOpenSerial[playerid] != open_serial) return 1;

    g_CalendarIgnoreNextClose[playerid] = false;
    return 1;
}



public Calendar_FinishOpen(playerid, account_id, open_serial, open_attempt)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(GetPlayerAccountID(playerid) != account_id) return 1;
    if(g_CalendarOpenSerial[playerid] != open_serial) return 1;

    g_CalendarOpenTimer[playerid] = -1;

    if(!g_CalendarPlayerLoaded[playerid] && open_attempt < 20)
    {
        if(!g_CalendarPlayerLoading[playerid])
            Calendar_LoadPlayer(playerid);

        g_CalendarOpenTimer[playerid] = SetTimerEx("Calendar_FinishOpen", 50, false, "iiii",
            playerid, account_id, open_serial, open_attempt + 1);
        return 1;
    }

    Calendar_Show(playerid);
    g_CalendarOpenTimer[playerid] = -1;
    g_CalendarSyncTimer[playerid] = SetTimerEx("Calendar_SendOpeningState", 600, false, "iiii",
        playerid, account_id, open_serial, 0);
    return 1;
}

public Calendar_SendOpeningState(playerid, account_id, open_serial, attempt)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 1;
    if(GetPlayerAccountID(playerid) != account_id) return 1;
    if(g_CalendarOpenSerial[playerid] != open_serial) return 1;
    if(!g_CalendarPlayerOpen[playerid]) { g_CalendarSyncTimer[playerid] = -1; return 1; }

    Calendar_SendStateUpdate(playerid);

    if(attempt < 5)
    {
        static const sync_delays[5] = {900, 1300, 2000, 3000, 4500};
        new delay = sync_delays[attempt];
        g_CalendarSyncTimer[playerid] = SetTimerEx("Calendar_SendOpeningState", delay, false, "iiii",
            playerid, account_id, open_serial, attempt + 1);
    }
    else
    {
        g_CalendarSyncTimer[playerid] = -1;
    }
    return 1;
}
