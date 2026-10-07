#define BLACKPASS_SEASON_NUMBER         28
#define BLACKPASS_SEASON_NAME           "BROKEN BP"
#define BLACKPASS_MAX_LEVELS            75
#define BLACKPASS_DEFAULT_PREMIUM_PRICE 790
#define BLACKPASS_DEFAULT_DELUXE_PRICE  1690
#define BLACKPASS_SEASON_DAYS           42
#define BLACKPASS_LEVEL_EXP             1000
#define BLACKPASS_LEVEL_PRICE           150
#define BLACKPASS_STATUS_NONE           0
#define BLACKPASS_STATUS_PREMIUM        1
#define BLACKPASS_STATUS_DELUXE         2

enum E_BLACKPASS_PLAYER_DATA
{
    bool:BP_DATA_LOADED,
    BP_ACCOUNT_ID,
    BP_EXPERIENCE,
    BP_LEVEL,
    BP_PREMIUM_STATUS,
    BP_DUST,
    BP_SELECTED_LAYOUT,
    bool:BP_DELUXE_REWARDS_CLAIMED
};

new g_blackpass_player[MAX_PLAYERS][E_BLACKPASS_PLAYER_DATA];
new bool:g_blackpass_claimed_standard[MAX_PLAYERS][BLACKPASS_MAX_LEVELS + 1];
new bool:g_blackpass_claimed_premium[MAX_PLAYERS][BLACKPASS_MAX_LEVELS + 1];

#define BLACKPASS_TASK_SLOT_COUNT        11
#define BLACKPASS_TASK_DEF_COUNT         15
#define BLACKPASS_DAILY_TASK_COUNT       6
#define BLACKPASS_WEEKLY_TASK_COUNT      5
#define BLACKPASS_TASK_GROUP_DAILY       1
#define BLACKPASS_TASK_GROUP_WEEKLY      2
#define BLACKPASS_TASK_STATUS_REWARD     1
#define BLACKPASS_TASK_STATUS_PREMIUM    2
#define BLACKPASS_TASK_STATUS_TRACKED    3
#define BLACKPASS_TASK_STATUS_GO_TO      4
#define BLACKPASS_TASK_STATUS_LOCKED     5
#define BLACKPASS_TASK_STATUS_CLAIMED    6
#define BLACKPASS_TASK_GUI_READY         65
#define BLACKPASS_EXCHANGE_COST          10

enum E_BLACKPASS_TASK_DEF
{
    BP_TASK_DEF_ID,
    BP_TASK_DEF_GROUP,
    BP_TASK_DEF_TARGET,
    BP_TASK_DEF_EXP_REWARD,
    BP_TASK_DEF_MONEY_REWARD,
    BP_TASK_DEF_ROUTE_ID,
    BP_TASK_DEF_BUTTON_TYPE,
    BP_TASK_DEF_LEVEL,
    bool:BP_TASK_DEF_PREMIUM_ONLY
};

new const g_blackpass_task_defs[BLACKPASS_TASK_DEF_COUNT][E_BLACKPASS_TASK_DEF] =
{
    {254, BLACKPASS_TASK_GROUP_DAILY, 1, 200, 1000,   0, 1, 1, false},
    {52,  BLACKPASS_TASK_GROUP_DAILY, 1, 200, 1000,   0, 6, 1, false},
    {124, BLACKPASS_TASK_GROUP_DAILY, 1, 200, 1000,   0, 6, 1, false},
    {108, BLACKPASS_TASK_GROUP_DAILY, 1, 200, 1000, 126, 6, 1, false},
    {96,  BLACKPASS_TASK_GROUP_DAILY, 1, 200, 1000,  32, 6, 2, false},
    {97,  BLACKPASS_TASK_GROUP_DAILY, 1, 200, 1000, 157, 6, 1, false},
    {99,  BLACKPASS_TASK_GROUP_WEEKLY, 15000, 800, 5000, 144, 1, 1, false},
    {256, BLACKPASS_TASK_GROUP_WEEKLY, 8, 800, 5000,  49, 6, 1, false},
    {257, BLACKPASS_TASK_GROUP_WEEKLY, 100000, 800, 5000, 0, 6, 1, false},
    {6,   BLACKPASS_TASK_GROUP_WEEKLY, 1, 800, 5000,  69, 1, 1, false},
    {255, BLACKPASS_TASK_GROUP_WEEKLY, 5, 800, 5000,   0, 4, 1, false},
    {143, BLACKPASS_TASK_GROUP_WEEKLY, 2, 800, 5000,   0, 1, 1, false},
    {104, BLACKPASS_TASK_GROUP_DAILY, 1, 200, 1000, 147, 6, 2, false},
    {2,   BLACKPASS_TASK_GROUP_DAILY, 1, 200, 1000, 144, 1, 1, false},
    {4,   BLACKPASS_TASK_GROUP_DAILY, 1, 200, 1000,  49, 1, 1, false}
};

new const g_blackpass_default_task_ids[BLACKPASS_TASK_SLOT_COUNT] =
{
    254,
    52,
    124,
    108,
    96,
    97,
    99,
    256,
    257,
    6,
    255
};

enum E_BLACKPASS_TASK_DATA
{
    BP_TASK_ROW_ID,
    BP_TASK_ID,
    BP_TASK_GROUP,
    BP_TASK_PERIOD_KEY,
    BP_TASK_PROGRESS,
    BP_TASK_STORED_STATUS,
    bool:BP_TASK_TRACKED,
    bool:BP_TASK_COMPLETE_NOTIFIED
};

new g_blackpass_tasks[MAX_PLAYERS][BLACKPASS_TASK_SLOT_COUNT][E_BLACKPASS_TASK_DATA];
new bool:g_blackpass_tasks_loaded[MAX_PLAYERS];
new g_blackpass_daily_period[MAX_PLAYERS];
new g_blackpass_weekly_period[MAX_PLAYERS];
new g_blackpass_task_popup[MAX_PLAYERS];
new g_blackpass_tracked_task[MAX_PLAYERS];
new g_blackpass_rating_refresh_until[MAX_PLAYERS];

#define BLACKPASS_REWARD_CASE_ID        99
#define BLACKPASS_REWARD_CASE_INDEX     98
#define BLACKPASS_STANDARD_REWARD_BASE  1000
#define BLACKPASS_PREMIUM_REWARD_BASE   2000
#define BLACKPASS_DELUXE_REWARD_BASE    3000

enum E_BLACKPASS_REWARD_INFO
{
    BP_REWARD_TYPE,
    BP_REWARD_INTERNAL,
    BP_REWARD_COUNT,
    BP_REWARD_RARITY,
    BP_REWARD_PRICE
};

new const g_blackpass_standard_reward_data[BLACKPASS_MAX_LEVELS + 1][E_BLACKPASS_REWARD_INFO] =
{
    {0, 0, 0, 0, 0},
    {9, 2, 8, 2, 0}, {2, 0, 5000, 1, 0}, {3, 0, 5, 1, 0}, {21, 0, 5, 1, 0}, {4, 1, 1, 2, 0},
    {9, 1, 2, 1, 0}, {2, 0, 5000, 1, 0}, {3, 0, 5, 1, 0}, {8, 0, 24, 1, 0}, {11, 951, 1, 4, 0},
    {9, 1, 2, 1, 0}, {2, 0, 5000, 1, 0}, {1, 0, 5, 1, 0}, {21, 0, 5, 1, 0}, {4, 1, 1, 2, 0},
    {9, 1, 2, 1, 0}, {2, 0, 5000, 1, 0}, {3, 0, 5, 1, 0}, {8, 0, 24, 1, 0}, {11, 955, 1, 4, 0},
    {9, 1, 2, 1, 0}, {2, 0, 5000, 1, 0}, {1, 0, 5, 1, 0}, {21, 0, 10, 1, 0}, {4, 1, 1, 2, 0},
    {9, 1, 2, 1, 0}, {2, 0, 5000, 1, 0}, {3, 0, 5, 1, 0}, {8, 0, 24, 1, 0}, {12, 6876, 1, 4, 0},
    {9, 1, 2, 1, 0}, {2, 0, 7500, 1, 0}, {1, 0, 10, 1, 0}, {21, 0, 10, 1, 0}, {4, 1, 1, 2, 0},
    {9, 1, 2, 1, 0}, {2, 0, 7500, 1, 0}, {3, 0, 5, 1, 0}, {8, 0, 24, 1, 0}, {4, 2, 1, 2, 0},
    {9, 2, 2, 1, 0}, {2, 0, 7500, 1, 0}, {1, 0, 10, 2, 0}, {21, 0, 10, 1, 0}, {4, 1, 1, 2, 0},
    {9, 2, 2, 1, 0}, {2, 0, 7500, 1, 0}, {3, 0, 10, 2, 0}, {8, 0, 24, 1, 0}, {12, 6879, 1, 4, 0},
    {9, 2, 2, 1, 0}, {2, 0, 10000, 1, 0}, {1, 0, 10, 1, 0}, {21, 0, 10, 1, 0}, {4, 1, 1, 2, 0},
    {9, 2, 2, 1, 0}, {2, 0, 10000, 1, 0}, {3, 0, 10, 2, 0}, {8, 0, 24, 1, 0}, {4, 2, 2, 3, 0},
    {9, 2, 2, 1, 0}, {2, 0, 10000, 1, 0}, {1, 0, 10, 1, 0}, {21, 0, 10, 1, 0}, {4, 1, 1, 2, 0},
    {9, 3, 2, 2, 0}, {2, 0, 10000, 1, 0}, {3, 0, 10, 2, 0}, {8, 0, 24, 1, 0}, {5, 747, 0, 5, 0},
    {9, 3, 2, 2, 0}, {2, 0, 10000, 1, 0}, {3, 0, 10, 2, 0}, {1, 0, 10, 2, 0}, {2, 0, 5000, 1, 0}
};

new const g_blackpass_standard_reward_names[BLACKPASS_MAX_LEVELS + 1][64] =
{
    "",
    "GOLD 8Ч.", "5000 Р", "5 BC", "X5 ПЫЛЬ", "ЕЖЕДНЕВНЫЙ X1",
    "SILVER 2Ч.", "5000 Р", "5 BC", "X2 НА 24Ч.", "Очки Street",
    "SILVER 2Ч.", "5000 Р", "5 EXP", "X5 ПЫЛЬ", "ЕЖЕДНЕВНЫЙ X1",
    "SILVER 2Ч.", "5000 Р", "5 BC", "X2 НА 24Ч.", "Рюкзак",
    "SILVER 2Ч.", "5000 Р", "5 EXP", "X10 ПЫЛЬ", "ЕЖЕДНЕВНЫЙ X1",
    "SILVER 2Ч.", "5000 Р", "5 BC", "X2 НА 24Ч.", "Азартный",
    "SILVER 2Ч.", "7500 Р", "10 EXP", "X10 ПЫЛЬ", "ЕЖЕДНЕВНЫЙ X1",
    "SILVER 2Ч.", "7500 Р", "5 BC", "X2 НА 24Ч.", "БОМЖА X1",
    "GOLD 2Ч.", "7500 Р", "10 EXP", "X10 ПЫЛЬ", "ЕЖЕДНЕВНЫЙ X1",
    "GOLD 2Ч.", "7500 Р", "10 BC", "X2 НА 24Ч.", "Анна",
    "GOLD 2Ч.", "10000 Р", "10 EXP", "X10 ПЫЛЬ", "ЕЖЕДНЕВНЫЙ X1",
    "GOLD 2Ч.", "10000 Р", "10 BC", "X2 НА 24Ч.", "БОМЖА X2",
    "VIP GOLD НА 2Ч.", "10000 Р", "10 EXP", "X10 ПЫЛЬ", "ЕЖЕДНЕВНЫЙ X1",
    "PLATINUM 2Ч.", "10000 Р", "10 BC", "X2 НА 24Ч.", "BMW 3.5 CSL",
    "PLATINUM 2Ч.", "10000 Р", "10 BC", "10 EXP", "5000 Р"
};

new const g_blackpass_premium_reward_data[BLACKPASS_MAX_LEVELS + 1][E_BLACKPASS_REWARD_INFO] =
{
    {0, 0, 0, 0, 0},
    {3, 0, 40, 3, 0}, {2, 0, 15000, 2, 0}, {3, 0, 10, 2, 0}, {21, 0, 10, 1, 0}, {11, 952, 1, 4, 0},
    {9, 2, 2, 1, 0}, {2, 0, 15000, 2, 0}, {3, 0, 10, 2, 0}, {4, 2, 1, 2, 0}, {5, 743, 0, 5, 0},
    {9, 2, 2, 1, 0}, {2, 0, 15000, 2, 0}, {3, 0, 10, 2, 0}, {21, 0, 15, 1, 0}, {12, 6877, 1, 4, 0},
    {9, 2, 2, 1, 0}, {2, 0, 15000, 2, 0}, {3, 0, 10, 2, 0}, {4, 1, 1, 2, 0}, {11, 953, 1, 4, 0},
    {9, 2, 2, 1, 0}, {2, 0, 15000, 2, 0}, {3, 0, 10, 2, 0}, {21, 0, 15, 1, 0}, {12, 6878, 1, 4, 0},
    {9, 2, 2, 1, 0}, {2, 0, 15000, 2, 0}, {3, 0, 10, 2, 0}, {4, 2, 1, 2, 0}, {5, 744, 0, 5, 0},
    {9, 2, 2, 1, 0}, {2, 0, 20000, 2, 0}, {3, 0, 10, 2, 0}, {21, 0, 20, 2, 0}, {11, 954, 1, 4, 0},
    {9, 2, 2, 1, 0}, {2, 0, 20000, 2, 0}, {3, 0, 10, 2, 0}, {4, 2, 1, 2, 0}, {12, 6880, 1, 4, 0},
    {9, 3, 2, 2, 0}, {2, 0, 20000, 2, 0}, {3, 0, 20, 2, 0}, {21, 0, 20, 2, 0}, {4, 3, 1, 4, 0},
    {9, 3, 2, 2, 0}, {2, 0, 20000, 2, 0}, {3, 0, 20, 2, 0}, {4, 2, 1, 2, 0}, {5, 745, 0, 5, 0},
    {9, 3, 2, 2, 0}, {2, 0, 20000, 2, 0}, {3, 0, 20, 2, 0}, {21, 0, 20, 2, 0}, {11, 957, 1, 4, 0},
    {9, 3, 2, 2, 0}, {2, 0, 20000, 2, 0}, {3, 0, 20, 2, 0}, {4, 2, 1, 2, 0}, {12, 6875, 1, 4, 0},
    {9, 3, 2, 2, 0}, {2, 0, 20000, 2, 0}, {3, 0, 20, 2, 0}, {21, 0, 20, 2, 0}, {11, 956, 1, 4, 0},
    {9, 3, 2, 2, 0}, {2, 0, 20000, 2, 0}, {3, 0, 20, 2, 0}, {4, 2, 1, 2, 0}, {5, 746, 0, 5, 0},
    {9, 3, 2, 2, 0}, {2, 0, 20000, 2, 0}, {3, 0, 20, 2, 0}, {4, 3, 1, 4, 0}, {2, 0, 10000, 1, 0}
};

new const g_blackpass_premium_reward_names[BLACKPASS_MAX_LEVELS + 1][64] =
{
    "",
    "40 BC", "15000 Р", "10 BC", "X10 ПЫЛЬ", "Пояс Nitro",
    "GOLD 2Ч.", "15000 Р", "10 BC", "БОМЖА X1", "Mercedes 190 Evo",
    "GOLD 2Ч.", "15000 Р", "10 BC", "X15 ПЫЛЬ", "Петр Тренер",
    "GOLD 2Ч.", "15000 Р", "10 BC", "ЕЖЕДНЕВНЫЙ X1", "Маска",
    "GOLD 2Ч.", "15000 Р", "10 BC", "X15 ПЫЛЬ", "Кристина",
    "GOLD 2Ч.", "15000 Р", "10 BC", "БОМЖА X1", "Toyota Tundra",
    "GOLD 2Ч.", "20000 Р", "10 BC", "X20 ПЫЛЬ", "DeathSnake",
    "GOLD 2Ч.", "20000 Р", "10 BC", "БОМЖА X1", "Продюсер",
    "PLATINUM 2Ч.", "20000 Р", "20 BC", "X20 ПЫЛЬ", "СТАНДАРТНЫЙ X1",
    "PLATINUM 2Ч.", "20000 Р", "20 BC", "БОМЖА X1", "Viper GTC",
    "PLATINUM 2Ч.", "20000 Р", "20 BC", "X20 ПЫЛЬ", "Нагрудник",
    "PLATINUM 2Ч.", "20000 Р", "20 BC", "БОМЖА X1", "Виктор",
    "PLATINUM 2Ч.", "20000 Р", "20 BC", "X20 ПЫЛЬ", "Скоростные Крылья",
    "PLATINUM 2Ч.", "20000 Р", "20 BC", "БОМЖА X1", "Lamborghini",
    "PLATINUM 2Ч.", "20000 Р", "20 BC", "СТАНДАРТНЫЙ X1", "10000 Р"
};

new const g_blackpass_deluxe_reward_data[5][E_BLACKPASS_REWARD_INFO] =
{
    {0, 0, 0, 0, 0},
    {5, 28744, 0, 5, 0},
    {9, 3, 360, 5, 0},
    {21, 0, 250, 5, 0},
    {10, 0, 10000, 5, 0}
};

new const g_blackpass_deluxe_reward_names[5][64] =
{
    "",
    "Porsche 718 Cayman GT4 RS",
    "VIP PLATINUM НА 15 Д.",
    "X250 ПЫЛЬ",
    "10 уровней BP"
};

stock BlackPass_LogEvent(playerid, const action[], reward_id = 0, reward_type = 0, reward_value = 0, amount = 0, extra = 0)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;

    new query[512];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO blackpass_logs (account_id,season_number,action,reward_id,reward_type,reward_value,amount,extra,created_at) VALUES (%d,%d,'%e',%d,%d,%d,%d,%d,UNIX_TIMESTAMP())",
        GetPlayerAccountID(playerid),
        BLACKPASS_SEASON_NUMBER,
        action,
        reward_id,
        reward_type,
        reward_value,
        amount,
        extra
    );
    mysql_query(mysql, query, false);
    return 1;
}


stock BlackPass_CreateTables()
{
    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS `blackpass_players` (`account_id` INT NOT NULL, `season_number` INT NOT NULL, `experience` INT NOT NULL DEFAULT 0, `level` INT NOT NULL DEFAULT 1, `premium_status` INT NOT NULL DEFAULT 0, `dust` INT NOT NULL DEFAULT 0, `selected_layout` INT NOT NULL DEFAULT 0, `deluxe_rewards_claimed` TINYINT(1) NOT NULL DEFAULT 0, `claimed_standard` VARCHAR(80) NOT NULL DEFAULT '', `claimed_premium` VARCHAR(80) NOT NULL DEFAULT '', `created_at` INT NOT NULL DEFAULT 0, `updated_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`,`season_number`), KEY `idx_blackpass_players_season` (`season_number`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);
    if(mysql_errno()) printf("[BLACKPASS][DB][ERROR] create blackpass_players errno=%d", mysql_errno());

    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS `blackpass_tasks` (`id` INT NOT NULL AUTO_INCREMENT, `account_id` INT NOT NULL, `season_number` INT NOT NULL, `task_id` INT NOT NULL, `task_group` INT NOT NULL, `period_key` INT NOT NULL, `target_count` INT NOT NULL DEFAULT 0, `reward_exp` INT NOT NULL DEFAULT 0, `reward_money` INT NOT NULL DEFAULT 0, `route_id` INT NOT NULL DEFAULT 0, `button_type` INT NOT NULL DEFAULT 0, `premium_only` TINYINT(1) NOT NULL DEFAULT 0, `progress` INT NOT NULL DEFAULT 0, `status` INT NOT NULL DEFAULT 0, `tracked` TINYINT(1) NOT NULL DEFAULT 0, `complete_notified` TINYINT(1) NOT NULL DEFAULT 0, `created_at` INT NOT NULL DEFAULT 0, `updated_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`), KEY `idx_blackpass_tasks_player` (`account_id`,`season_number`,`task_group`,`period_key`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);
    if(mysql_errno()) printf("[BLACKPASS][DB][ERROR] create blackpass_tasks errno=%d", mysql_errno());

    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS `blackpass_logs` (`id` INT NOT NULL AUTO_INCREMENT, `account_id` INT NOT NULL, `season_number` INT NOT NULL, `action` VARCHAR(32) NOT NULL, `reward_id` INT NOT NULL DEFAULT 0, `reward_type` INT NOT NULL DEFAULT 0, `reward_value` INT NOT NULL DEFAULT 0, `amount` INT NOT NULL DEFAULT 0, `extra` INT NOT NULL DEFAULT 0, `created_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`), KEY `idx_blackpass_logs_player` (`account_id`,`season_number`), KEY `idx_blackpass_logs_action` (`action`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);
    if(mysql_errno()) printf("[BLACKPASS][DB][ERROR] create blackpass_logs errno=%d", mysql_errno());

    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS `rewards` (`id` INT NOT NULL AUTO_INCREMENT, `uid` INT NOT NULL, `award_id` INT NOT NULL, `case_id` INT NOT NULL, PRIMARY KEY (`id`), KEY `uid_idx` (`uid`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", false);
    if(mysql_errno()) printf("[BLACKPASS][DB][ERROR] create rewards errno=%d", mysql_errno());

    return 1;
}
stock BlackPass_ResetPlayer(playerid)
{
    g_blackpass_player[playerid][BP_DATA_LOADED] = false;
    g_blackpass_player[playerid][BP_ACCOUNT_ID] = -1;
    g_blackpass_player[playerid][BP_EXPERIENCE] = 0;
    g_blackpass_player[playerid][BP_LEVEL] = 1;
    g_blackpass_player[playerid][BP_PREMIUM_STATUS] = BLACKPASS_STATUS_NONE;
    g_blackpass_player[playerid][BP_DUST] = 0;
    g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 0;
    g_blackpass_player[playerid][BP_DELUXE_REWARDS_CLAIMED] = false;

    for(new i = 0; i <= BLACKPASS_MAX_LEVELS; i++)
    {
        g_blackpass_claimed_standard[playerid][i] = false;
        g_blackpass_claimed_premium[playerid][i] = false;
    }

    g_blackpass_tasks_loaded[playerid] = false;
    g_blackpass_daily_period[playerid] = 0;
    g_blackpass_weekly_period[playerid] = 0;
    g_blackpass_task_popup[playerid] = 0;
    g_blackpass_tracked_task[playerid] = 0;
    g_blackpass_rating_refresh_until[playerid] = 0;

    for(new task_idx = 0; task_idx < BLACKPASS_TASK_SLOT_COUNT; task_idx++)
    {
        g_blackpass_tasks[playerid][task_idx][BP_TASK_ROW_ID] = 0;
        new default_task_id = g_blackpass_default_task_ids[task_idx];
        new def_index = BlackPass_FindTaskDefIndex(default_task_id);
        g_blackpass_tasks[playerid][task_idx][BP_TASK_ID] = default_task_id;
        g_blackpass_tasks[playerid][task_idx][BP_TASK_GROUP] = def_index == -1 ? (task_idx < BLACKPASS_DAILY_TASK_COUNT ? BLACKPASS_TASK_GROUP_DAILY : BLACKPASS_TASK_GROUP_WEEKLY) : g_blackpass_task_defs[def_index][BP_TASK_DEF_GROUP];
        g_blackpass_tasks[playerid][task_idx][BP_TASK_PERIOD_KEY] = 0;
        g_blackpass_tasks[playerid][task_idx][BP_TASK_PROGRESS] = 0;
        g_blackpass_tasks[playerid][task_idx][BP_TASK_STORED_STATUS] = BLACKPASS_STATUS_NONE;
        g_blackpass_tasks[playerid][task_idx][BP_TASK_TRACKED] = false;
        g_blackpass_tasks[playerid][task_idx][BP_TASK_COMPLETE_NOTIFIED] = false;
    }
    return 1;
}

stock BlackPass_GetLevelFromExperience(experience)
{
    new level = 1 + (experience / BLACKPASS_LEVEL_EXP);
    if(level < 1) level = 1;
    if(level > BLACKPASS_MAX_LEVELS) level = BLACKPASS_MAX_LEVELS;
    return level;
}

stock BlackPass_GetMaxExperience()
{
    return (BLACKPASS_MAX_LEVELS - 1) * BLACKPASS_LEVEL_EXP;
}

stock BlackPass_BuildClaimFlagsString(playerid, bool:is_premium, output[], output_len)
{
    output[0] = EOS;
    for(new i = 1; i <= BLACKPASS_MAX_LEVELS; i++)
    {
        new part[2];
        part[0] = (is_premium ? g_blackpass_claimed_premium[playerid][i] : g_blackpass_claimed_standard[playerid][i]) ? '1' : '0';
        part[1] = EOS;
        strcat(output, part, output_len);
    }
    return 1;
}

stock BlackPass_ParseClaimFlagsString(playerid, bool:is_premium, const source[])
{
    for(new i = 1; i <= BLACKPASS_MAX_LEVELS; i++)
    {
        new bool:is_claimed = ((i - 1) < strlen(source) && source[i - 1] == '1');
        if(is_premium) g_blackpass_claimed_premium[playerid][i] = is_claimed;
        else g_blackpass_claimed_standard[playerid][i] = is_claimed;
    }
    return 1;
}

stock BlackPass_GetCurrentLevel(playerid)
{
    g_blackpass_player[playerid][BP_LEVEL] = BlackPass_GetLevelFromExperience(g_blackpass_player[playerid][BP_EXPERIENCE]);
    return g_blackpass_player[playerid][BP_LEVEL];
}

stock BlackPass_GetClientPremiumStatus(status)
{
    switch(status)
    {
        case BLACKPASS_STATUS_PREMIUM: return 2;
        case BLACKPASS_STATUS_DELUXE: return 1;
    }
    return 0;
}

stock BlackPass_RefreshStateFlags(playerid, Node:json)
{
    new current_level = BlackPass_GetCurrentLevel(playerid);
    JSON_SetInt(json, "lv", current_level);
    JSON_SetInt(json, "ec", g_blackpass_player[playerid][BP_EXPERIENCE] % BLACKPASS_LEVEL_EXP);
    JSON_SetInt(json, "a", BlackPass_GetClientPremiumStatus(g_blackpass_player[playerid][BP_PREMIUM_STATUS]));
    JSON_SetInt(json, "es", g_blackpass_player[playerid][BP_EXPERIENCE]);
    JSON_SetInt(json, "l", g_blackpass_player[playerid][BP_EXPERIENCE]);
    JSON_SetInt(json, "lc", g_blackpass_player[playerid][BP_SELECTED_LAYOUT]);
    JSON_SetInt(json, "is", g_blackpass_claimed_standard[playerid][current_level] ? 0 : 1);
    JSON_SetInt(json, "ps", g_blackpass_claimed_premium[playerid][current_level] ? 0 : 1);
    return 1;
}

stock BlackPass_GetRewardInventoryItemId(level, bool:is_premium)
{
    return (is_premium ? BLACKPASS_PREMIUM_REWARD_BASE : BLACKPASS_STANDARD_REWARD_BASE) + level;
}

stock BlackPass_GetDeluxeInventoryItemId(index)
{
    return BLACKPASS_DELUXE_REWARD_BASE + index;
}

stock BlackPass_IsRewardInventoryItem(itemid)
{
    if(itemid >= BLACKPASS_STANDARD_REWARD_BASE + 1 && itemid <= BLACKPASS_STANDARD_REWARD_BASE + BLACKPASS_MAX_LEVELS) return 1;
    if(itemid >= BLACKPASS_PREMIUM_REWARD_BASE + 1 && itemid <= BLACKPASS_PREMIUM_REWARD_BASE + BLACKPASS_MAX_LEVELS) return 1;
    if(itemid >= BLACKPASS_DELUXE_REWARD_BASE + 1 && itemid <= BLACKPASS_DELUXE_REWARD_BASE + 4) return 1;
    return 0;
}

stock BlackPass_GetRewardInventoryData(itemid, name[], name_len, &type, &internal, &count, &rarity, &price)
{
    name[0] = EOS;
    type = 0;
    internal = 0;
    count = 0;
    rarity = 0;
    price = 0;
    if(itemid >= BLACKPASS_STANDARD_REWARD_BASE + 1 && itemid <= BLACKPASS_STANDARD_REWARD_BASE + BLACKPASS_MAX_LEVELS)
    {
        new level = itemid - BLACKPASS_STANDARD_REWARD_BASE;
        if(1 <= level <= BLACKPASS_MAX_LEVELS)
        {
            format(name, name_len, "%s", g_blackpass_standard_reward_names[level]);
            type = g_blackpass_standard_reward_data[level][BP_REWARD_TYPE];
            internal = g_blackpass_standard_reward_data[level][BP_REWARD_INTERNAL];
            count = g_blackpass_standard_reward_data[level][BP_REWARD_COUNT];
            if(type == 12) { type = 11; count = internal; internal = 134; }
            rarity = g_blackpass_standard_reward_data[level][BP_REWARD_RARITY];
            price = g_blackpass_standard_reward_data[level][BP_REWARD_PRICE];
            return 1;
        }
        return 0;
    }
    if(itemid >= BLACKPASS_PREMIUM_REWARD_BASE + 1 && itemid <= BLACKPASS_PREMIUM_REWARD_BASE + BLACKPASS_MAX_LEVELS)
    {
        new level = itemid - BLACKPASS_PREMIUM_REWARD_BASE;
        if(1 <= level <= BLACKPASS_MAX_LEVELS)
        {
            format(name, name_len, "%s", g_blackpass_premium_reward_names[level]);
            type = g_blackpass_premium_reward_data[level][BP_REWARD_TYPE];
            internal = g_blackpass_premium_reward_data[level][BP_REWARD_INTERNAL];
            count = g_blackpass_premium_reward_data[level][BP_REWARD_COUNT];
            if(type == 12) { type = 11; count = internal; internal = 134; }
            rarity = g_blackpass_premium_reward_data[level][BP_REWARD_RARITY];
            price = g_blackpass_premium_reward_data[level][BP_REWARD_PRICE];
            return 1;
        }
        return 0;
    }
    if(itemid >= BLACKPASS_DELUXE_REWARD_BASE + 1 && itemid <= BLACKPASS_DELUXE_REWARD_BASE + 4)
    {
        new index = itemid - BLACKPASS_DELUXE_REWARD_BASE;
        if(1 <= index <= 4)
        {
            format(name, name_len, "%s", g_blackpass_deluxe_reward_names[index]);
            type = g_blackpass_deluxe_reward_data[index][BP_REWARD_TYPE];
            internal = g_blackpass_deluxe_reward_data[index][BP_REWARD_INTERNAL];
            count = g_blackpass_deluxe_reward_data[index][BP_REWARD_COUNT];
            if(type == 12) { type = 11; count = internal; internal = 134; }
            rarity = g_blackpass_deluxe_reward_data[index][BP_REWARD_RARITY];
            price = g_blackpass_deluxe_reward_data[index][BP_REWARD_PRICE];
            return 1;
        }
    }
    return 0;
}

stock BlackPass_HasQueuedReward(playerid, itemid)
{
    #pragma unused playerid
    #pragma unused itemid
    return 0;
}

stock BlackPass_GiveCarDirect(playerid, modelid, const name[])
{
    #pragma unused name
    // Машина только РЕГИСТРИРУЕТСЯ как принадлежащая игроку (в базе + в памяти
    // ownable-массива) - НЕ спавнится физически в мире. Игрок вызовет её сам
    // из гаража, как и любую другую свою купленную машину.
    new Float:pos_x = 0.0, Float:pos_y = 0.0, Float:pos_z = 0.0, Float:angle = 0.0;
    new color_1 = -1, color_2 = -1;
    new query[220], Cache:result, idx;

    idx = GetFreeOwnableCarID();

    SetOwnableCarData(idx, OC_OWNER_ID, GetPlayerAccountID(playerid));

    SetOwnableCarData(idx, OC_MODEL_ID, modelid);
    SetOwnableCarData(idx, OC_COLOR_1, color_1);
    SetOwnableCarData(idx, OC_COLOR_2, color_2);

    SetOwnableCarData(idx, OC_POS_X, pos_x);
    SetOwnableCarData(idx, OC_POS_Y, pos_y);
    SetOwnableCarData(idx, OC_POS_Z, pos_z);
    SetOwnableCarData(idx, OC_ANGLE, angle);

    strmid(g_ownable_car[idx][OC_NUMBER], "", 0, 8, 8);

    SetOwnableCarData(idx, OC_ALARM, false);
    SetOwnableCarData(idx, OC_KEY_IN, false);

    SetOwnableCarData(idx, OC_CREATE, gettime());

    format(g_ownable_car[idx][OC_OWNER_NAME], 21, GetPlayerNameEx(playerid));

    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO ownable_cars (owner_id,model_id,color_1,color_2,pos_x,pos_y,pos_z,angle,create_time) VALUES (\'%d\',\'%d\',\'%d\',\'%d\',\'%f\',\'%f\',\'%f\',\'%f\',\'%d\')",
        GetPlayerAccountID(playerid), modelid, color_1, color_2, pos_x, pos_y, pos_z, angle, gettime());
    result = mysql_query(mysql, query, true);

    SetOwnableCarData(idx, OC_SQL_ID, cache_insert_id());
    cache_delete(result);

    return 1;
}

stock BlackPass_QueueInventoryReward(playerid, itemid)
{
    if(!BlackPass_IsRewardInventoryItem(itemid)) return 0;

    // Rewards are put into the common /reward queue.
    // Actual giving is handled by the gamemode GiveInventoryReward().
    if(!AddPlayerCaseReward(playerid, BLACKPASS_REWARD_CASE_ID, itemid, false))
    {
        printf("[BLACKPASS][REWARD][QUEUE_FAIL] player=%d item=%d", playerid, itemid);
        return 0;
    }

    return 1;
}

stock BlackPass_QueueLevelReward(playerid, level, bool:is_premium)
{
    if(level < 1 || level > BLACKPASS_MAX_LEVELS) return 0;
    return BlackPass_QueueInventoryReward(playerid, BlackPass_GetRewardInventoryItemId(level, is_premium));
}

stock BlackPass_QueueDeluxeRewards(playerid, bool:skip_level_reward = true)
{
    new queued = 1;
    for(new i = 1; i <= 4; i++)
    {
        if(skip_level_reward && i == 4) continue;
        if(!BlackPass_QueueInventoryReward(playerid, BlackPass_GetDeluxeInventoryItemId(i)))
            queued = 0;
    }
    return queued;
}

stock BlackPass_ShowLootNotification(playerid, message[])
{
    ShowNotificationNew(playerid, 3, 3, 0, 0, message, "");
    return 1;
}

stock BlackPass_SendLayoutPacket(playerid, layout_id)
{
    new Node:layout_json = JSON_Object();
    BlackPass_SendMainPacket(playerid, layout_json, layout_id);
    JSON_Cleanup(layout_json);
    return 1;
}

stock BlackPass_OpenLoot(playerid)
{
    return ShowNotificationNew(playerid, 2, 4, 0, 0, "Добыча BlackPass временно отключена", "");
}

stock BlackPass_SendStateRefresh(playerid, current_layout = 0, visible_layout = -1)
{
    new Node:refresh_json = JSON_Object();
    BlackPass_FillBasePacket(playerid, refresh_json);
    JSON_SetInt(refresh_json, "t", -1);
    JSON_SetInt(refresh_json, "ty", -1);
    JSON_SetInt(refresh_json, "la", visible_layout);
    JSON_SetInt(refresh_json, "lv", g_blackpass_player[playerid][BP_LEVEL]);
    JSON_SetInt(refresh_json, "ec", g_blackpass_player[playerid][BP_EXPERIENCE] % BLACKPASS_LEVEL_EXP);
    JSON_SetInt(refresh_json, "a", BlackPass_GetClientPremiumStatus(g_blackpass_player[playerid][BP_PREMIUM_STATUS]));
    JSON_SetInt(refresh_json, "es", g_blackpass_player[playerid][BP_EXPERIENCE]);
    JSON_SetInt(refresh_json, "l", g_blackpass_player[playerid][BP_EXPERIENCE]);
    JSON_SetInt(refresh_json, "lc", current_layout);
    JSON_SetInt(refresh_json, "is", g_blackpass_claimed_standard[playerid][BlackPass_GetCurrentLevel(playerid)] ? 0 : 1);
    JSON_SetInt(refresh_json, "ps", g_blackpass_claimed_premium[playerid][BlackPass_GetCurrentLevel(playerid)] ? 0 : 1);
    SendPacketToClient(playerid, 22, refresh_json);
    JSON_Cleanup(refresh_json);
    return 1;
}
stock BlackPass_AutoClaimRewardsRange(playerid, start_level, end_level, bool:claim_standard, bool:claim_premium)
{
    if(start_level < 1) start_level = 1;
    if(end_level > BLACKPASS_MAX_LEVELS) end_level = BLACKPASS_MAX_LEVELS;
    if(start_level > end_level) return 0;

    for(new level = start_level; level <= end_level; level++)
    {
        if(claim_standard && !g_blackpass_claimed_standard[playerid][level])
        {
            if(BlackPass_QueueLevelReward(playerid, level, false))
                g_blackpass_claimed_standard[playerid][level] = true;
        }

        if(claim_premium && !g_blackpass_claimed_premium[playerid][level])
        {
            if(BlackPass_QueueLevelReward(playerid, level, true))
                g_blackpass_claimed_premium[playerid][level] = true;
        }
    }
    return 1;
}

stock BlackPass_AddDust(playerid, amount)
{
    if(!g_blackpass_player[playerid][BP_DATA_LOADED])
    {
        if(!BlackPass_LoadPlayer(playerid)) return 0;
    }

    g_blackpass_player[playerid][BP_DUST] += amount;
    if(g_blackpass_player[playerid][BP_DUST] < 0) g_blackpass_player[playerid][BP_DUST] = 0;
    BlackPass_SavePlayer(playerid);
    BlackPass_LogEvent(playerid, "dust_add", 0, 21, 0, amount, g_blackpass_player[playerid][BP_DUST]);
    return 1;
}

stock BlackPass_GrantExperience(playerid, experience)
{
    if(!g_blackpass_player[playerid][BP_DATA_LOADED])
    {
        if(!BlackPass_LoadPlayer(playerid)) return 0;
    }

    g_blackpass_player[playerid][BP_EXPERIENCE] += experience;
    if(g_blackpass_player[playerid][BP_EXPERIENCE] < 0) g_blackpass_player[playerid][BP_EXPERIENCE] = 0;
    if(g_blackpass_player[playerid][BP_EXPERIENCE] > BlackPass_GetMaxExperience())
    {
        g_blackpass_player[playerid][BP_EXPERIENCE] = BlackPass_GetMaxExperience();
    }

    g_blackpass_player[playerid][BP_LEVEL] = BlackPass_GetLevelFromExperience(g_blackpass_player[playerid][BP_EXPERIENCE]);
    BlackPass_SavePlayer(playerid);
    return 1;
}

stock BlackPass_SetLevelWithReset(playerid, target_level)
{
    if(!g_blackpass_player[playerid][BP_DATA_LOADED])
    {
        if(!BlackPass_LoadPlayer(playerid)) return 0;
    }

    if(target_level < 1) target_level = 1;
    if(target_level > BLACKPASS_MAX_LEVELS) target_level = BLACKPASS_MAX_LEVELS;

    g_blackpass_player[playerid][BP_LEVEL] = target_level;
    g_blackpass_player[playerid][BP_EXPERIENCE] = (target_level - 1) * BLACKPASS_LEVEL_EXP;
    BlackPass_SavePlayer(playerid);
    return 1;
}

stock BlackPass_AddLevelsWithReset(playerid, levels_to_add)
{
    if(levels_to_add <= 0) return BlackPass_GetCurrentLevel(playerid);

    new old_level = BlackPass_GetCurrentLevel(playerid);
    new target_level = old_level + levels_to_add;
    if(target_level > BLACKPASS_MAX_LEVELS) target_level = BLACKPASS_MAX_LEVELS;

    BlackPass_SetLevelWithReset(playerid, target_level);
    return BlackPass_GetCurrentLevel(playerid);
}

stock BlackPass_SendLevelSyncPacket(playerid, level = -1, exp_value = -1)
{
    new Node:sync_json = JSON_Object();
    if(level == -1) level = BlackPass_GetCurrentLevel(playerid);
    if(exp_value == -1) exp_value = g_blackpass_player[playerid][BP_EXPERIENCE] % BLACKPASS_LEVEL_EXP;
    JSON_SetInt(sync_json, "t", -1);
    JSON_SetInt(sync_json, "ty", 3);
    JSON_SetInt(sync_json, "tb", -2);
    JSON_SetInt(sync_json, "e", exp_value);
    JSON_SetInt(sync_json, "l", level);
    SendPacketToClient(playerid, 22, sync_json);
    JSON_Cleanup(sync_json);
    return 1;
}

stock BlackPass_SendLevelSyncRange(playerid, old_level, new_level)
{
    if(new_level <= old_level)
    {
        return BlackPass_SendLevelSyncPacket(playerid);
    }

    for(new level = old_level + 1; level <= new_level; level++)
    {
        BlackPass_SendLevelSyncPacket(playerid, level, level == new_level ? g_blackpass_player[playerid][BP_EXPERIENCE] % BLACKPASS_LEVEL_EXP : 0);
    }
    return 1;
}


stock BlackPass_SavePlayer(playerid)
{
    if(!g_blackpass_player[playerid][BP_DATA_LOADED]) return 0;

    new claimed_standard[BLACKPASS_MAX_LEVELS + 1];
    new claimed_premium[BLACKPASS_MAX_LEVELS + 1];
    new query[1024];

    BlackPass_BuildClaimFlagsString(playerid, false, claimed_standard, sizeof(claimed_standard));
    BlackPass_BuildClaimFlagsString(playerid, true, claimed_premium, sizeof(claimed_premium));

    mysql_format(mysql, query, sizeof(query),
        "UPDATE blackpass_players SET experience=%d, level=%d, premium_status=%d, dust=%d, selected_layout=%d, deluxe_rewards_claimed=%d, claimed_standard='%e', claimed_premium='%e', updated_at=UNIX_TIMESTAMP() WHERE account_id=%d AND season_number=%d LIMIT 1",
        g_blackpass_player[playerid][BP_EXPERIENCE],
        g_blackpass_player[playerid][BP_LEVEL],
        g_blackpass_player[playerid][BP_PREMIUM_STATUS],
        g_blackpass_player[playerid][BP_DUST],
        g_blackpass_player[playerid][BP_SELECTED_LAYOUT],
        g_blackpass_player[playerid][BP_DELUXE_REWARDS_CLAIMED],
        claimed_standard,
        claimed_premium,
        GetPlayerAccountID(playerid),
        BLACKPASS_SEASON_NUMBER
    );
    mysql_query(mysql, query, false);

    printf("[BLACKPASS][SAVE] player=%d account=%d exp=%d level=%d premium=%d dust=%d layout=%d deluxe=%d",
        playerid,
        GetPlayerAccountID(playerid),
        g_blackpass_player[playerid][BP_EXPERIENCE],
        g_blackpass_player[playerid][BP_LEVEL],
        g_blackpass_player[playerid][BP_PREMIUM_STATUS],
        g_blackpass_player[playerid][BP_DUST],
        g_blackpass_player[playerid][BP_SELECTED_LAYOUT],
        g_blackpass_player[playerid][BP_DELUXE_REWARDS_CLAIMED]
    );
    return 1;
}


stock BlackPass_SendRewardClaimPacket(playerid, reward_id, bool:is_premium, layout_id = 0)
{
    new Node:claim_json = JSON_Object();
    JSON_SetInt(claim_json, "t", -1);
    JSON_SetInt(claim_json, "ty", 2);
    JSON_SetInt(claim_json, "la", layout_id);
    JSON_SetInt(claim_json, "s", 1);
    JSON_SetInt(claim_json, "id", reward_id);
    JSON_SetInt(claim_json, "p", is_premium ? 1 : 0);
    SendPacketToClient(playerid, 22, claim_json);
    JSON_Cleanup(claim_json);
    return 1;
}


stock BlackPass_SendClaimPacketsRange(playerid, start_level, end_level, bool:claim_standard, bool:claim_premium, layout_id = 0)
{
    if(start_level < 1) start_level = 1;
    if(end_level > BLACKPASS_MAX_LEVELS) end_level = BLACKPASS_MAX_LEVELS;
    if(start_level > end_level) return 0;

    for(new level = start_level; level <= end_level; level++)
    {
        if(claim_standard && g_blackpass_claimed_standard[playerid][level])
        {
            BlackPass_SendRewardClaimPacket(playerid, level, false, layout_id);
        }

        if(claim_premium && g_blackpass_claimed_premium[playerid][level])
        {
            BlackPass_SendRewardClaimPacket(playerid, level, true, layout_id);
        }
    }
    return 1;
}
stock BlackPass_SendAutoClaimSyncRange(playerid, old_level, new_level, bool:claim_standard, bool:claim_premium, layout_id = 0)
{
    if(new_level <= old_level)
    {
        return 0;
    }

    for(new level = old_level + 1; level <= new_level; level++)
    {
        BlackPass_SendLevelSyncPacket(playerid, level, level == new_level ? g_blackpass_player[playerid][BP_EXPERIENCE] % BLACKPASS_LEVEL_EXP : 0);

        if(claim_standard && g_blackpass_claimed_standard[playerid][level])
        {
            BlackPass_SendRewardClaimPacket(playerid, level, false, layout_id);
        }

        if(claim_premium && g_blackpass_claimed_premium[playerid][level])
        {
            BlackPass_SendRewardClaimPacket(playerid, level, true, layout_id);
        }
    }
    return 1;
}
stock BlackPass_LoadPlayer(playerid)
{

    BlackPass_ResetPlayer(playerid);

    new query[256];
    mysql_format(mysql, query, sizeof(query),
        "SELECT * FROM blackpass_players WHERE account_id=%d AND season_number=%d LIMIT 1",
        GetPlayerAccountID(playerid),
        BLACKPASS_SEASON_NUMBER
    );

    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        printf("[BLACKPASS][ERROR] Load failed: player=%d account=%d errno=%d query=%s", playerid, GetPlayerAccountID(playerid), mysql_errno(), query);
        cache_delete(result);
        return 0;
    }

    if(cache_num_rows() == 0)
    {
        mysql_format(mysql, query, sizeof(query),
            "INSERT INTO blackpass_players (account_id,season_number,experience,level,premium_status,dust,selected_layout,deluxe_rewards_claimed,claimed_standard,claimed_premium,created_at,updated_at) VALUES (%d,%d,0,1,0,0,0,0,'%s','%s',UNIX_TIMESTAMP(),UNIX_TIMESTAMP())",
            GetPlayerAccountID(playerid),
            BLACKPASS_SEASON_NUMBER,
            "0000000000000000000000000000000000000000000000000000000000000",
            "0000000000000000000000000000000000000000000000000000000000000"
        );
        mysql_query(mysql, query, false);
        g_blackpass_player[playerid][BP_DATA_LOADED] = true;
        g_blackpass_player[playerid][BP_ACCOUNT_ID] = GetPlayerAccountID(playerid);
        cache_delete(result);
        return 1;
    }

    new claimed_standard[BLACKPASS_MAX_LEVELS + 1];
    new claimed_premium[BLACKPASS_MAX_LEVELS + 1];

    g_blackpass_player[playerid][BP_EXPERIENCE] = cache_get_field_content_int(0, "experience");
    g_blackpass_player[playerid][BP_LEVEL] = cache_get_field_content_int(0, "level");
    g_blackpass_player[playerid][BP_PREMIUM_STATUS] = cache_get_field_content_int(0, "premium_status");
    g_blackpass_player[playerid][BP_DUST] = cache_get_field_content_int(0, "dust");
    g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = cache_get_field_content_int(0, "selected_layout");
    g_blackpass_player[playerid][BP_DELUXE_REWARDS_CLAIMED] = bool:cache_get_field_content_int(0, "deluxe_rewards_claimed");

    cache_get_field_content(0, "claimed_standard", claimed_standard, sizeof(claimed_standard));
    cache_get_field_content(0, "claimed_premium", claimed_premium, sizeof(claimed_premium));
    BlackPass_ParseClaimFlagsString(playerid, false, claimed_standard);
    BlackPass_ParseClaimFlagsString(playerid, true, claimed_premium);

    if(g_blackpass_player[playerid][BP_LEVEL] < 1)
    {
        g_blackpass_player[playerid][BP_LEVEL] = BlackPass_GetLevelFromExperience(g_blackpass_player[playerid][BP_EXPERIENCE]);
    }

    g_blackpass_player[playerid][BP_DATA_LOADED] = true;
    g_blackpass_player[playerid][BP_ACCOUNT_ID] = GetPlayerAccountID(playerid);
    cache_delete(result);

    return 1;
}

stock BlackPass_GetCurrentTaskPeriod(task_group)
{
    switch(task_group)
    {
        case BLACKPASS_TASK_GROUP_DAILY: return gettime() / 86400;
        case BLACKPASS_TASK_GROUP_WEEKLY: return gettime() / 604800;
    }
    return 0;
}

stock BlackPass_GetTaskResetTimer()
{
    new left = 86400 - (gettime() % 86400);
    if(left <= 0) left = 1;
    return left;
}

stock BlackPass_FindTaskDefIndex(task_id)
{
    for(new idx = 0; idx < BLACKPASS_TASK_DEF_COUNT; idx++)
    {
        if(g_blackpass_task_defs[idx][BP_TASK_DEF_ID] == task_id)
        {
            return idx;
        }
    }
    return -1;
}

stock BlackPass_FindTaskSlot(playerid, task_id)
{
    for(new idx = 0; idx < BLACKPASS_TASK_SLOT_COUNT; idx++)
    {
        if(g_blackpass_tasks[playerid][idx][BP_TASK_ID] == task_id)
        {
            return idx;
        }
    }
    return -1;
}

stock BlackPass_GetTaskDefIndexFromSlot(playerid, task_index)
{
    if(!(0 <= task_index < BLACKPASS_TASK_SLOT_COUNT)) return -1;
    if(g_blackpass_tasks[playerid][task_index][BP_TASK_ID] <= 0) return -1;
    return BlackPass_FindTaskDefIndex(g_blackpass_tasks[playerid][task_index][BP_TASK_ID]);
}

stock BlackPass_ClearTaskSlot(playerid, task_index, task_group)
{
    g_blackpass_tasks[playerid][task_index][BP_TASK_ROW_ID] = 0;
    g_blackpass_tasks[playerid][task_index][BP_TASK_ID] = 0;
    g_blackpass_tasks[playerid][task_index][BP_TASK_GROUP] = task_group;
    g_blackpass_tasks[playerid][task_index][BP_TASK_PERIOD_KEY] = BlackPass_GetCurrentTaskPeriod(task_group);
    g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] = 0;
    g_blackpass_tasks[playerid][task_index][BP_TASK_STORED_STATUS] = BLACKPASS_STATUS_NONE;
    g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED] = false;
    g_blackpass_tasks[playerid][task_index][BP_TASK_COMPLETE_NOTIFIED] = false;
    return 1;
}

stock BlackPass_AssignTaskSlot(playerid, task_index, task_id, row_id = 0)
{
    new def_index = BlackPass_FindTaskDefIndex(task_id);
    if(def_index == -1) return 0;

    g_blackpass_tasks[playerid][task_index][BP_TASK_ROW_ID] = row_id;
    g_blackpass_tasks[playerid][task_index][BP_TASK_ID] = task_id;
    g_blackpass_tasks[playerid][task_index][BP_TASK_GROUP] = g_blackpass_task_defs[def_index][BP_TASK_DEF_GROUP];
    g_blackpass_tasks[playerid][task_index][BP_TASK_PERIOD_KEY] = BlackPass_GetCurrentTaskPeriod(g_blackpass_task_defs[def_index][BP_TASK_DEF_GROUP]);
    g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] = 0;
    g_blackpass_tasks[playerid][task_index][BP_TASK_STORED_STATUS] = BLACKPASS_STATUS_NONE;
    g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED] = false;
    g_blackpass_tasks[playerid][task_index][BP_TASK_COMPLETE_NOTIFIED] = false;
    return 1;
}

stock BlackPass_GetNextFreeTaskSlot(playerid, task_group)
{
    new start_idx = (task_group == BLACKPASS_TASK_GROUP_WEEKLY) ? BLACKPASS_DAILY_TASK_COUNT : 0;
    new end_idx = (task_group == BLACKPASS_TASK_GROUP_WEEKLY) ? BLACKPASS_TASK_SLOT_COUNT : BLACKPASS_DAILY_TASK_COUNT;

    for(new idx = start_idx; idx < end_idx; idx++)
    {
        if(g_blackpass_tasks[playerid][idx][BP_TASK_ID] == 0)
        {
            return idx;
        }
    }
    return -1;
}

stock BlackPass_IsTaskActive(playerid, task_id)
{
    return BlackPass_FindTaskSlot(playerid, task_id) != -1;
}

stock BlackPass_GetTaskDescription(task_id, output[], output_len)
{
    output[0] = EOS;

    switch(task_id)
    {
        case 254: format(output, output_len, "Войдите в игру");
        case 52: format(output, output_len, "Отыграйте 1 час");
        case 124: format(output, output_len, "Наденьте любой аксессуар");
        case 108: format(output, output_len, "Арендуйте скутер");
        case 96: format(output, output_len, "Подайте объявление в СМИ (/ad)");
        case 97: format(output, output_len, "Прокрутите случайные номера авто в ГИБДД");
        case 99: format(output, output_len, "Пожертвуйте 15000 рублей или более в Банке");
        case 143: format(output, output_len, "Поздоровайтесь с 2 игроками");
        case 256: format(output, output_len, "Сыграйте 8 любых игр в Казино");
        case 257: format(output, output_len, "Заработайте 100 000 рублей");
        case 6: format(output, output_len, "Сделайте тюнинг своего автомобиля в СТО");
        case 255: format(output, output_len, "Откройте 5 любых кейсов");
        case 104: format(output, output_len, "Возьмите машину на тест драйв в любом автосалоне");
        case 2: format(output, output_len, "Посетите Банк");
        case 4: format(output, output_len, "Посетите Казино");
        default: format(output, output_len, "Задание Black Pass");
    }
    return 1;
}

stock BlackPass_TaskHasAction(playerid, task_index)
{
    if(!(0 <= task_index < BLACKPASS_TASK_SLOT_COUNT)) return 0;
    new def_index = BlackPass_GetTaskDefIndexFromSlot(playerid, task_index);
    if(def_index == -1) return 0;
    if(g_blackpass_task_defs[def_index][BP_TASK_DEF_ROUTE_ID] > 0) return 1;
    if(g_blackpass_task_defs[def_index][BP_TASK_DEF_BUTTON_TYPE] >= 4) return 1;
    return 0;
}

stock BlackPass_GetStoredTaskStatus(playerid, task_index)
{
    new def_index = BlackPass_GetTaskDefIndexFromSlot(playerid, task_index);
    if(def_index == -1) return BLACKPASS_STATUS_NONE;

    if(g_blackpass_tasks[playerid][task_index][BP_TASK_STORED_STATUS] == BLACKPASS_TASK_STATUS_CLAIMED)
    {
        return BLACKPASS_TASK_STATUS_CLAIMED;
    }

    if(g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] >= g_blackpass_task_defs[def_index][BP_TASK_DEF_TARGET])
    {
        return BLACKPASS_TASK_STATUS_REWARD;
    }

    if(g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED] && BlackPass_TaskHasAction(playerid, task_index))
    {
        return BLACKPASS_TASK_STATUS_TRACKED;
    }

    return BLACKPASS_STATUS_NONE;
}

stock BlackPass_GetClientTaskStatus(playerid, task_index)
{
    if(!(0 <= task_index < BLACKPASS_TASK_SLOT_COUNT)) return BLACKPASS_TASK_STATUS_LOCKED;
    new def_index = BlackPass_GetTaskDefIndexFromSlot(playerid, task_index);
    if(def_index == -1) return BLACKPASS_TASK_STATUS_LOCKED;

    if(GetPlayerLevel(playerid) < g_blackpass_task_defs[def_index][BP_TASK_DEF_LEVEL])
    {
        return BLACKPASS_TASK_STATUS_LOCKED;
    }

    if(g_blackpass_task_defs[def_index][BP_TASK_DEF_PREMIUM_ONLY] && g_blackpass_player[playerid][BP_PREMIUM_STATUS] == BLACKPASS_STATUS_NONE)
    {
        return BLACKPASS_TASK_STATUS_PREMIUM;
    }

    if(g_blackpass_tasks[playerid][task_index][BP_TASK_STORED_STATUS] == BLACKPASS_TASK_STATUS_CLAIMED)
    {
        return BLACKPASS_TASK_STATUS_CLAIMED;
    }

    if(g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] >= g_blackpass_task_defs[def_index][BP_TASK_DEF_TARGET])
    {
        return BLACKPASS_TASK_STATUS_REWARD;
    }

    if(g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED] && BlackPass_TaskHasAction(playerid, task_index))
    {
        return BLACKPASS_TASK_STATUS_TRACKED;
    }

    if(BlackPass_TaskHasAction(playerid, task_index))
    {
        return BLACKPASS_TASK_STATUS_GO_TO;
    }

    return BLACKPASS_TASK_STATUS_LOCKED;
}

stock BlackPass_EnableTaskGps(playerid, task_id)
{
    switch(task_id)
    {
        case 108: return EnablePlayerGPS(playerid, gps_jobs[2][G_MARKET_TYPE], gps_jobs[2][G_POS_X], gps_jobs[2][G_POS_Y], gps_jobs[2][G_POS_Z], "");
        case 96: return EnablePlayerGPS(playerid, gps_state_organizations[5][G_MARKET_TYPE], gps_state_organizations[5][G_POS_X], gps_state_organizations[5][G_POS_Y], gps_state_organizations[5][G_POS_Z], "");
        case 97: return EnablePlayerGPS(playerid, gps_state_organizations[1][G_MARKET_TYPE], gps_state_organizations[1][G_POS_X], gps_state_organizations[1][G_POS_Y], gps_state_organizations[1][G_POS_Z], "");
        case 99, 2: return EnablePlayerGPS(playerid, gps_banks[0][G_MARKET_TYPE], gps_banks[0][G_POS_X], gps_banks[0][G_POS_Y], gps_banks[0][G_POS_Z], "");
        case 256, 4: return EnablePlayerGPS(playerid, gps_entertainment[0][G_MARKET_TYPE], gps_entertainment[0][G_POS_X], gps_entertainment[0][G_POS_Y], gps_entertainment[0][G_POS_Z], "");
        case 6: return EnablePlayerGPS(playerid, gps_jobs[0][G_MARKET_TYPE], gps_jobs[0][G_POS_X], gps_jobs[0][G_POS_Y], gps_jobs[0][G_POS_Z], "");
        case 104: return EnablePlayerGPS(playerid, gps_autosalons[0][G_MARKET_TYPE], gps_autosalons[0][G_POS_X], gps_autosalons[0][G_POS_Y], gps_autosalons[0][G_POS_Z], "");
    }
    return 0;
}

stock BlackPass_SaveTaskSlot(playerid, task_index)
{
    if(!(0 <= task_index < BLACKPASS_TASK_SLOT_COUNT)) return 0;

    new query[512];
    new stored_status = BlackPass_GetStoredTaskStatus(playerid, task_index);
    g_blackpass_tasks[playerid][task_index][BP_TASK_STORED_STATUS] = stored_status;

    mysql_format(mysql, query, sizeof(query),
        "UPDATE blackpass_tasks SET progress=%d,status=%d,tracked=%d,complete_notified=%d,updated_at=UNIX_TIMESTAMP() WHERE id=%d LIMIT 1",
        g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS],
        stored_status,
        g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED],
        g_blackpass_tasks[playerid][task_index][BP_TASK_COMPLETE_NOTIFIED],
        g_blackpass_tasks[playerid][task_index][BP_TASK_ROW_ID]
    );
    mysql_query(mysql, query, false);
    return 1;
}

stock BlackPass_InsertTaskSlot(playerid, task_index)
{
    if(!(0 <= task_index < BLACKPASS_TASK_SLOT_COUNT)) return 0;
    new def_index = BlackPass_GetTaskDefIndexFromSlot(playerid, task_index);
    if(def_index == -1) return 0;

    new query[768];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO blackpass_tasks (account_id,season_number,task_id,task_group,period_key,target_count,reward_exp,reward_money,route_id,button_type,premium_only,progress,status,tracked,complete_notified,created_at,updated_at) VALUES (%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,0,0,0,0,UNIX_TIMESTAMP(),UNIX_TIMESTAMP())",
        GetPlayerAccountID(playerid),
        BLACKPASS_SEASON_NUMBER,
        g_blackpass_task_defs[def_index][BP_TASK_DEF_ID],
        g_blackpass_task_defs[def_index][BP_TASK_DEF_GROUP],
        g_blackpass_tasks[playerid][task_index][BP_TASK_PERIOD_KEY],
        g_blackpass_task_defs[def_index][BP_TASK_DEF_TARGET],
        g_blackpass_task_defs[def_index][BP_TASK_DEF_EXP_REWARD],
        g_blackpass_task_defs[def_index][BP_TASK_DEF_MONEY_REWARD],
        g_blackpass_task_defs[def_index][BP_TASK_DEF_ROUTE_ID],
        g_blackpass_task_defs[def_index][BP_TASK_DEF_BUTTON_TYPE],
        g_blackpass_task_defs[def_index][BP_TASK_DEF_PREMIUM_ONLY]
    );
    mysql_query(mysql, query, false);
    return 1;
}

stock BlackPass_LoadTasks(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;

    new daily_period = BlackPass_GetCurrentTaskPeriod(BLACKPASS_TASK_GROUP_DAILY);
    new weekly_period = BlackPass_GetCurrentTaskPeriod(BLACKPASS_TASK_GROUP_WEEKLY);

    if(g_blackpass_tasks_loaded[playerid]
    && g_blackpass_daily_period[playerid] == daily_period
    && g_blackpass_weekly_period[playerid] == weekly_period)
    {
        return 1;
    }

    g_blackpass_tracked_task[playerid] = 0;

    for(new task_idx = 0; task_idx < BLACKPASS_DAILY_TASK_COUNT; task_idx++) BlackPass_ClearTaskSlot(playerid, task_idx, BLACKPASS_TASK_GROUP_DAILY);
    for(new task_idx = BLACKPASS_DAILY_TASK_COUNT; task_idx < BLACKPASS_TASK_SLOT_COUNT; task_idx++) BlackPass_ClearTaskSlot(playerid, task_idx, BLACKPASS_TASK_GROUP_WEEKLY);

    for(new pass = 0; pass < 2; pass++)
    {
        new bool:loaded_defs[BLACKPASS_TASK_DEF_COUNT];
        new daily_loaded, weekly_loaded;
        new query[256];
        mysql_format(mysql, query, sizeof(query),
            "SELECT id,task_id,task_group,period_key,progress,status,tracked,complete_notified FROM blackpass_tasks WHERE account_id=%d AND season_number=%d AND ((task_group=%d AND period_key=%d) OR (task_group=%d AND period_key=%d)) ORDER BY task_group ASC,id ASC",
            GetPlayerAccountID(playerid),
            BLACKPASS_SEASON_NUMBER,
            BLACKPASS_TASK_GROUP_DAILY,
            daily_period,
            BLACKPASS_TASK_GROUP_WEEKLY,
            weekly_period
        );

        new Cache:result = mysql_query(mysql, query, true);
        if(mysql_errno())
        {
            printf("[BLACKPASS][TASKS][ERROR] Load failed: player=%d errno=%d query=%s", playerid, mysql_errno(), query);
            cache_delete(result);
            return 0;
        }

        for(new row = 0; row < cache_num_rows(); row++)
        {
            new task_id = cache_get_field_content_int(row, "task_id");
            new task_group = cache_get_field_content_int(row, "task_group");
            new def_index = BlackPass_FindTaskDefIndex(task_id);
            new task_status = cache_get_field_content_int(row, "status");
            if(def_index == -1) continue;
            if(g_blackpass_task_defs[def_index][BP_TASK_DEF_GROUP] != task_group) continue;
            if(loaded_defs[def_index]) continue;

            if(task_status == BLACKPASS_TASK_STATUS_CLAIMED)
            {
                loaded_defs[def_index] = true;
                continue;
            }

            new task_index = BlackPass_GetNextFreeTaskSlot(playerid, task_group);
            if(task_index == -1) continue;

            BlackPass_AssignTaskSlot(playerid, task_index, task_id, cache_get_field_content_int(row, "id"));
            g_blackpass_tasks[playerid][task_index][BP_TASK_PERIOD_KEY] = cache_get_field_content_int(row, "period_key");
            g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] = cache_get_field_content_int(row, "progress");
            g_blackpass_tasks[playerid][task_index][BP_TASK_STORED_STATUS] = cache_get_field_content_int(row, "status");
            g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED] = bool:cache_get_field_content_int(row, "tracked");
            g_blackpass_tasks[playerid][task_index][BP_TASK_COMPLETE_NOTIFIED] = bool:cache_get_field_content_int(row, "complete_notified");
            loaded_defs[def_index] = true;

            if(task_group == BLACKPASS_TASK_GROUP_DAILY) daily_loaded++;
            else weekly_loaded++;

            if(g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED])
            {
                g_blackpass_tracked_task[playerid] = task_id;
            }
        }
        cache_delete(result);

        if(pass == 1) break;

        new missing_tasks;
        for(new task_idx = 0; task_idx < BLACKPASS_TASK_SLOT_COUNT; task_idx++)
        {
            new default_task_id = g_blackpass_default_task_ids[task_idx];
            new def_index = BlackPass_FindTaskDefIndex(default_task_id);
            if(def_index == -1 || loaded_defs[def_index]) continue;

            new task_group = g_blackpass_task_defs[def_index][BP_TASK_DEF_GROUP];
            if(task_group == BLACKPASS_TASK_GROUP_DAILY && daily_loaded >= BLACKPASS_DAILY_TASK_COUNT) continue;
            if(task_group == BLACKPASS_TASK_GROUP_WEEKLY && weekly_loaded >= BLACKPASS_WEEKLY_TASK_COUNT) continue;

            BlackPass_AssignTaskSlot(playerid, task_idx, default_task_id);
            BlackPass_InsertTaskSlot(playerid, task_idx);
            loaded_defs[def_index] = true;
            if(task_group == BLACKPASS_TASK_GROUP_DAILY) daily_loaded++;
            else weekly_loaded++;
            missing_tasks++;
        }

        if(missing_tasks == 0) break;
    }

    g_blackpass_daily_period[playerid] = daily_period;
    g_blackpass_weekly_period[playerid] = weekly_period;
    g_blackpass_tasks_loaded[playerid] = true;
    return 1;
}

stock BlackPass_ShowTaskReadyGui(playerid, task_id)
{
    new Node:json = JSON_Object();
    JSON_SetInt(json, "o", 1);
    JSON_SetInt(json, "t", 2);
    JSON_SetInt(json, "tm", 6);
    JSON_SetString(json, "h", "Заберите награду BLACK PASS");
    JSON_SetString(json, "s", "Условия задания <font color='#ffd801'></font> выполнены. Нажмите, чтобы  получить награду.");
    JSON_SetString(json, "b", "Получить");
    ShowPlayerGUI(playerid, BLACKPASS_TASK_GUI_READY, json);
    JSON_Cleanup(json);

    g_blackpass_task_popup[playerid] = task_id;
    return 1;
}

stock BlackPass_ShowTrackedTaskGui(playerid, task_id)
{
    new task_text[96];
    BlackPass_GetTaskDescription(task_id, task_text, sizeof(task_text));

    new Node:json = JSON_Object();
    JSON_SetInt(json, "o", 1);
    JSON_SetInt(json, "m", 5);
    JSON_SetInt(json, "t", 4);
    JSON_SetString(json, "mq", task_text);
    JSON_SetInt(json, "mt", 0);
    JSON_SetInt(json, "ma", 1);
    JSON_SetString(json, "mc", "#0BDA51");
    JSON_SetArray(json, "aq", JSON_Array());
    JSON_SetArray(json, "at", JSON_Array());
    JSON_SetArray(json, "aa", JSON_Array());
    JSON_SetArray(json, "ac", JSON_Array());
    JSON_SetInt(json, "f", 0);
    ShowPlayerGUI(playerid, 39, json);
    JSON_Cleanup(json);
    return 1;
}

stock BlackPass_OpenTasksScreen(playerid)
{
    if(!BlackPass_LoadPlayer(playerid)) return 0;
    if(!BlackPass_LoadTasks(playerid)) return 0;

    g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 1;

    new Node:gui_json = JSON_Object();
    JSON_SetInt(gui_json, "o", 1);
    JSON_SetInt(gui_json, "t", 0);
    JSON_SetInt(gui_json, "lc", 3);
    JSON_SetInt(gui_json, "k", 0);
    JSON_SetInt(gui_json, "sv", 1);
    JSON_SetInt(gui_json, "ds", 0);
    JSON_SetInt(gui_json, "r", GetPlayerMoney(playerid));
    JSON_SetInt(gui_json, "d", GetPlayerDonateRub(playerid));
    JSON_SetInt(gui_json, "p", GetPlayerData(playerid, P_SALE_TIME));
    JSON_SetArray(gui_json, "s", g_player_donate_data[playerid][JSON_PROMOTIONS_ARRAY]);
    if(strcmp("None", GetPlayerData(playerid, P_EMAIL)))
    {
        JSON_SetString(gui_json, "em", GetPlayerData(playerid, P_EMAIL));
    }
    else
    {
        JSON_SetString(gui_json, "em", "0");
    }
    JSON_SetString(gui_json, "nm", GetPlayerNameEx(playerid));
    SendPacketToClient(playerid, 22, gui_json);
    JSON_Cleanup(gui_json);

    new Node:init_json = JSON_Object();
    BlackPass_SendMainPacket(playerid, init_json, 0);
    JSON_Cleanup(init_json);

    new Node:tasks_json = JSON_Object();
    new result = BlackPass_SendMainPacket(playerid, tasks_json, 1);
    JSON_Cleanup(tasks_json);
    return result;
}

stock BlackPass_AddTaskProgress(playerid, task_id, amount)
{
    if(amount <= 0) return 0;
    if(!BlackPass_LoadPlayer(playerid)) return 0;
    if(!BlackPass_LoadTasks(playerid)) return 0;

    new task_index = BlackPass_FindTaskSlot(playerid, task_id);
    if(task_index == -1) return 0;
    new def_index = BlackPass_GetTaskDefIndexFromSlot(playerid, task_index);
    if(def_index == -1) return 0;
    if(g_blackpass_tasks[playerid][task_index][BP_TASK_STORED_STATUS] == BLACKPASS_TASK_STATUS_CLAIMED) return 0;

    new target = g_blackpass_task_defs[def_index][BP_TASK_DEF_TARGET];
    new old_progress = g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS];

    g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] += amount;
    if(g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] > target)
    {
        g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] = target;
    }

    if(old_progress < target
    && g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] >= target
    && !g_blackpass_tasks[playerid][task_index][BP_TASK_COMPLETE_NOTIFIED])
    {
        g_blackpass_tasks[playerid][task_index][BP_TASK_COMPLETE_NOTIFIED] = true;
        BlackPass_ShowTaskReadyGui(playerid, task_id);
    }

    BlackPass_SaveTaskSlot(playerid, task_index);

    if(g_blackpass_player[playerid][BP_SELECTED_LAYOUT] == 1)
    {
        BlackPass_SendLayoutPacket(playerid, 1);
    }
    return 1;
}

stock BlackPass_ClaimTaskReward(playerid, task_id)
{
    if(!BlackPass_LoadPlayer(playerid)) return 0;
    if(!BlackPass_LoadTasks(playerid)) return 0;

    new task_index = BlackPass_FindTaskSlot(playerid, task_id);
    if(task_index == -1) return 0;
    new def_index = BlackPass_GetTaskDefIndexFromSlot(playerid, task_index);
    if(def_index == -1) return 0;
    if(g_blackpass_tasks[playerid][task_index][BP_TASK_STORED_STATUS] == BLACKPASS_TASK_STATUS_CLAIMED) return 0;
    if(g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] < g_blackpass_task_defs[def_index][BP_TASK_DEF_TARGET]) return 0;

    new old_level = BlackPass_GetCurrentLevel(playerid);
    new exp_reward = g_blackpass_task_defs[def_index][BP_TASK_DEF_EXP_REWARD];
    new money_reward = g_blackpass_task_defs[def_index][BP_TASK_DEF_MONEY_REWARD];
    new group = g_blackpass_task_defs[def_index][BP_TASK_DEF_GROUP];
    new notify_str[96];

    g_blackpass_tasks[playerid][task_index][BP_TASK_STORED_STATUS] = BLACKPASS_TASK_STATUS_CLAIMED;
    g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED] = false;
    g_blackpass_tasks[playerid][task_index][BP_TASK_COMPLETE_NOTIFIED] = true;
    if(g_blackpass_tracked_task[playerid] == task_id) g_blackpass_tracked_task[playerid] = 0;
    if(g_blackpass_task_popup[playerid] == task_id) g_blackpass_task_popup[playerid] = 0;
    HidePlayerGUI(playerid, 39);
    DisablePlayerGPS(playerid);
    HidePlayerGUI(playerid, BLACKPASS_TASK_GUI_READY);

    BlackPass_SaveTaskSlot(playerid, task_index);
    BlackPass_ClearTaskSlot(playerid, task_index, group);
    BlackPass_GrantExperience(playerid, exp_reward);
    if(money_reward > 0)
    {
        GivePlayerMoneyEx(playerid, money_reward, "BlackPass task reward", true, true);
    }
    BlackPass_LogEvent(playerid, "task_claim", task_id, 10, exp_reward, 1, group);

    format(notify_str, sizeof(notify_str), "Вы получили %d рублей", money_reward);
    ShowNotificationNew(playerid, 3, 4, 0, 0, notify_str, "");

    if(BlackPass_GetCurrentLevel(playerid) > old_level)
    {
        ShowNotificationNew(playerid, 3, 3, 0, 0, "Вы успешно получили новый уровень Black Pass.", "");
        BlackPass_SendLevelSyncRange(playerid, old_level, BlackPass_GetCurrentLevel(playerid));
    }

    g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 1;
    return BlackPass_OpenTasksScreen(playerid);
}

stock BlackPass_BeginTrackTask(playerid, task_id)
{
    if(!BlackPass_LoadTasks(playerid)) return 0;

    new task_index = BlackPass_FindTaskSlot(playerid, task_id);
    if(task_index == -1) return 0;
    if(!BlackPass_TaskHasAction(playerid, task_index)) return 0;

    for(new idx = 0; idx < BLACKPASS_TASK_SLOT_COUNT; idx++)
    {
        if(g_blackpass_tasks[playerid][idx][BP_TASK_TRACKED] && idx != task_index)
        {
            g_blackpass_tasks[playerid][idx][BP_TASK_TRACKED] = false;
            BlackPass_SaveTaskSlot(playerid, idx);
        }
    }

    g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED] = true;
    g_blackpass_tracked_task[playerid] = task_id;
    BlackPass_SaveTaskSlot(playerid, task_index);

    BlackPass_EnableTaskGps(playerid, task_id);
    HidePlayerGUI(playerid, 22);
    ShowNotificationNew(playerid, 3, 3, 0, 0, "Место отмечено у Вас на GPS", "");
    BlackPass_ShowTrackedTaskGui(playerid, task_id);
    return 1;
}

stock BlackPass_StopTrackTask(playerid, task_id)
{
    if(!BlackPass_LoadTasks(playerid)) return 0;

    new task_index = BlackPass_FindTaskSlot(playerid, task_id);
    if(task_index == -1) return 0;
    if(!g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED]) return 0;

    g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED] = false;
    if(g_blackpass_tracked_task[playerid] == task_id) g_blackpass_tracked_task[playerid] = 0;
    BlackPass_SaveTaskSlot(playerid, task_index);
    DisablePlayerGPS(playerid);
    HidePlayerGUI(playerid, 39);

    g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 1;
    return BlackPass_OpenTasksScreen(playerid);
}

stock BlackPass_FindExchangeReplacement(playerid, task_index)
{
    new current_task_id = g_blackpass_tasks[playerid][task_index][BP_TASK_ID];
    new current_def_index = BlackPass_GetTaskDefIndexFromSlot(playerid, task_index);
    if(current_def_index == -1) return -1;

    for(new def_index = 0; def_index < BLACKPASS_TASK_DEF_COUNT; def_index++)
    {
        if(def_index == current_def_index) continue;
        if(g_blackpass_task_defs[def_index][BP_TASK_DEF_GROUP] != g_blackpass_task_defs[current_def_index][BP_TASK_DEF_GROUP]) continue;
        if(BlackPass_IsTaskActive(playerid, g_blackpass_task_defs[def_index][BP_TASK_DEF_ID])) continue;
        if(g_blackpass_task_defs[def_index][BP_TASK_DEF_ID] == current_task_id) continue;
        return def_index;
    }
    return -1;
}

stock BlackPass_HandleTaskPress(playerid, Node:json)
{
    if(!BlackPass_LoadPlayer(playerid)) return 0;
    if(!BlackPass_LoadTasks(playerid)) return 0;

    new task_id;
    JSON_GetInt(json, "id", task_id);

    new task_index = BlackPass_FindTaskSlot(playerid, task_id);
    if(task_index == -1)
    {
        g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 1;
        return BlackPass_SendMainPacket(playerid, json, 1);
    }

    switch(BlackPass_GetClientTaskStatus(playerid, task_index))
    {
        case BLACKPASS_TASK_STATUS_REWARD: return BlackPass_ClaimTaskReward(playerid, task_id);
        case BLACKPASS_TASK_STATUS_TRACKED: return BlackPass_StopTrackTask(playerid, task_id);
        case BLACKPASS_TASK_STATUS_GO_TO: return BlackPass_BeginTrackTask(playerid, task_id);
    }

    g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 1;
    return BlackPass_SendMainPacket(playerid, json, 1);
}

stock BlackPass_HandleTaskExchange(playerid, Node:json)
{
    new task_id;
    JSON_GetInt(json, "id", task_id);

    if(!BlackPass_LoadPlayer(playerid)) return 1;
    if(!BlackPass_LoadTasks(playerid)) return 1;

    new task_index = BlackPass_FindTaskSlot(playerid, task_id);
    if(task_index == -1) return 1;
    new def_index = BlackPass_GetTaskDefIndexFromSlot(playerid, task_index);
    if(def_index == -1) return 1;
    if(g_blackpass_tasks[playerid][task_index][BP_TASK_STORED_STATUS] == BLACKPASS_TASK_STATUS_CLAIMED) return 1;
    if(g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] >= g_blackpass_task_defs[def_index][BP_TASK_DEF_TARGET]) return 1;

    if(GetPlayerDonateRub(playerid) < BLACKPASS_EXCHANGE_COST)
    {
        ShowNotificationNew(playerid, 2, 3, 0, 0, "Недостаточно BC.", "");
        return 1;
    }

    new replacement_def_index = BlackPass_FindExchangeReplacement(playerid, task_index);
    if(replacement_def_index == -1)
    {
        ShowNotificationNew(playerid, 2, 3, 0, 0, "Сейчас это задание нельзя заменить.", "");
        return 1;
    }

    new row_id = g_blackpass_tasks[playerid][task_index][BP_TASK_ROW_ID];
    if(g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED])
    {
        DisablePlayerGPS(playerid);
        HidePlayerGUI(playerid, 39);
    }

    GivePlayerDonateRub(playerid, -BLACKPASS_EXCHANGE_COST, "Смена задания BlackPass", true, true);

    g_blackpass_tasks[playerid][task_index][BP_TASK_ID] = g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_ID];
    g_blackpass_tasks[playerid][task_index][BP_TASK_GROUP] = g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_GROUP];
    g_blackpass_tasks[playerid][task_index][BP_TASK_PERIOD_KEY] = BlackPass_GetCurrentTaskPeriod(g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_GROUP]);
    g_blackpass_tasks[playerid][task_index][BP_TASK_PROGRESS] = 0;
    g_blackpass_tasks[playerid][task_index][BP_TASK_STORED_STATUS] = BLACKPASS_STATUS_NONE;
    g_blackpass_tasks[playerid][task_index][BP_TASK_TRACKED] = false;
    g_blackpass_tasks[playerid][task_index][BP_TASK_COMPLETE_NOTIFIED] = false;
    g_blackpass_tasks[playerid][task_index][BP_TASK_ROW_ID] = row_id;
    if(g_blackpass_tracked_task[playerid] == task_id) g_blackpass_tracked_task[playerid] = 0;

    new query[768];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE blackpass_tasks SET task_id=%d,task_group=%d,period_key=%d,target_count=%d,reward_exp=%d,reward_money=%d,route_id=%d,button_type=%d,premium_only=%d,progress=0,status=0,tracked=0,complete_notified=0,updated_at=UNIX_TIMESTAMP() WHERE id=%d LIMIT 1",
        g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_ID],
        g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_GROUP],
        g_blackpass_tasks[playerid][task_index][BP_TASK_PERIOD_KEY],
        g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_TARGET],
        g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_EXP_REWARD],
        g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_MONEY_REWARD],
        g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_ROUTE_ID],
        g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_BUTTON_TYPE],
        g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_PREMIUM_ONLY],
        row_id
    );
    mysql_query(mysql, query, false);

    BlackPass_LogEvent(playerid, "task_exchange", task_id, 0, BLACKPASS_EXCHANGE_COST, 1, g_blackpass_task_defs[replacement_def_index][BP_TASK_DEF_ID]);
    ShowNotificationNew(playerid, 3, 3, 0, 0, "Вы потратили 10 BC и успешно сменили задание!", "");

    return BlackPass_OpenTasksScreen(playerid);
}

stock BlackPass_HandleExtraGui(playerid, guiid, Node:json)
{
    new type, close_state;
    JSON_GetInt(json, "t", type);
    JSON_GetInt(json, "c", close_state);

    switch(guiid)
    {
        case BLACKPASS_TASK_GUI_READY:
        {
            if(close_state == 1 || type == 1)
            {
                g_blackpass_task_popup[playerid] = 0;
                HidePlayerGUI(playerid, BLACKPASS_TASK_GUI_READY);
                return 1;
            }

            if(type == 2)
            {
                g_blackpass_task_popup[playerid] = 0;
                g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 1;
                HidePlayerGUI(playerid, BLACKPASS_TASK_GUI_READY);
                return BlackPass_OpenTasksScreen(playerid);
            }
        }

        case 39:
        {
            if(close_state == 1)
            {
                HidePlayerGUI(playerid, 39);
                return 1;
            }

            if(type == 4)
            {
                HidePlayerGUI(playerid, 39);
                return BlackPass_OpenTasksScreen(playerid);
            }
        }
    }

    return 0;
}

stock BlackPass_OnPlayerLogged(playerid)
{
    if(!BlackPass_LoadPlayer(playerid)) return 0;
    if(!BlackPass_LoadTasks(playerid)) return 0;
    return BlackPass_AddTaskProgress(playerid, 254, 1);
}

stock BlackPass_OnPlayedHour(playerid)
{
    return BlackPass_AddTaskProgress(playerid, 52, 1);
}

stock BlackPass_OnAccessoryUsed(playerid)
{
    return BlackPass_AddTaskProgress(playerid, 124, 1);
}

stock BlackPass_OnScooterRent(playerid)
{
    return BlackPass_AddTaskProgress(playerid, 108, 1);
}

stock BlackPass_OnAdvertSent(playerid)
{
    return BlackPass_AddTaskProgress(playerid, 96, 1);
}

stock BlackPass_OnPlateRegenerated(playerid)
{
    return BlackPass_AddTaskProgress(playerid, 97, 1);
}

stock BlackPass_OnBankDeposit(playerid, amount)
{
    BlackPass_AddTaskProgress(playerid, 2, 1);
    return BlackPass_AddTaskProgress(playerid, 99, amount);
}

stock BlackPass_OnCasinoGamePlayed(playerid)
{
    BlackPass_AddTaskProgress(playerid, 4, 1);
    return BlackPass_AddTaskProgress(playerid, 256, 1);
}

stock BlackPass_OnMoneyEarned(playerid, amount, const description[] = "")
{
    if(amount <= 0) return 0;
    if(strfind(description, "BlackPass", true) != -1) return 0;
    return BlackPass_AddTaskProgress(playerid, 257, amount);
}

stock BlackPass_OnTuningPurchase(playerid)
{
    return BlackPass_AddTaskProgress(playerid, 6, 1);
}

stock BlackPass_OnCaseOpened(playerid)
{
    return BlackPass_AddTaskProgress(playerid, 255, 1);
}

stock BlackPass_OnPlayerGreeting(playerid)
{
    return BlackPass_AddTaskProgress(playerid, 143, 1);
}

stock BlackPass_OnTestDriveStarted(playerid)
{
    return BlackPass_AddTaskProgress(playerid, 104, 1);
}

stock BlackPass_FillBasePacket(playerid, Node:json)
{
    new current_level = BlackPass_GetCurrentLevel(playerid);

    JSON_SetInt(json, "t", -1);
    JSON_SetInt(json, "ty", -1);
    JSON_SetInt(json, "la", 0);
    JSON_SetInt(json, "lv", current_level);
    JSON_SetInt(json, "ec", g_blackpass_player[playerid][BP_EXPERIENCE] % BLACKPASS_LEVEL_EXP);
    JSON_SetInt(json, "a", BlackPass_GetClientPremiumStatus(g_blackpass_player[playerid][BP_PREMIUM_STATUS]));
    JSON_SetInt(json, "es", g_blackpass_player[playerid][BP_EXPERIENCE]);
    JSON_SetInt(json, "l", g_blackpass_player[playerid][BP_EXPERIENCE]);
    JSON_SetInt(json, "lc", g_blackpass_player[playerid][BP_SELECTED_LAYOUT]);
    JSON_SetInt(json, "is", g_blackpass_claimed_standard[playerid][current_level] ? 0 : 1);
    JSON_SetInt(json, "ps", g_blackpass_claimed_premium[playerid][current_level] ? 0 : 1);
    return 1;
}

stock BlackPass_SendMainPacket(playerid, Node:json, latype)
{
    switch(latype)
    {
        case 0:
        {
            JSON_SetInt(json, "t", -1);
            JSON_SetInt(json, "ty", -1);
            JSON_SetInt(json, "la", 0);
            JSON_SetString(json, "sn", BLACKPASS_SEASON_NAME);
            JSON_SetString(json, "ln", GetPlayerNameEx(playerid));
            JSON_SetInt(json, "lv", g_blackpass_player[playerid][BP_LEVEL]);
            JSON_SetInt(json, "td", BLACKPASS_SEASON_DAYS * 86400);
            JSON_SetInt(json, "ec", g_blackpass_player[playerid][BP_EXPERIENCE] % BLACKPASS_LEVEL_EXP);
            JSON_SetInt(json, "a", BlackPass_GetClientPremiumStatus(g_blackpass_player[playerid][BP_PREMIUM_STATUS]));
            JSON_SetInt(json, "sp", 0);
            JSON_SetInt(json, "is", g_blackpass_claimed_standard[playerid][BlackPass_GetCurrentLevel(playerid)] ? 0 : 1);
            JSON_SetInt(json, "ps", g_blackpass_claimed_premium[playerid][BlackPass_GetCurrentLevel(playerid)] ? 0 : 1);

            SendPacketToClient(playerid, 22, json);
            return 1;
        }

        case 1:
        {
            BlackPass_LoadTasks(playerid);

            JSON_SetInt(json, "t", -1);
            JSON_SetInt(json, "ty", 0);
            JSON_SetInt(json, "la", 1);
            JSON_SetString(json, "sn", BLACKPASS_SEASON_NAME);
            JSON_SetString(json, "ln", GetPlayerNameEx(playerid));
            JSON_SetInt(json, "lv", g_blackpass_player[playerid][BP_LEVEL]);
            JSON_SetInt(json, "ec", g_blackpass_player[playerid][BP_EXPERIENCE] % BLACKPASS_LEVEL_EXP);

            // ВАЖНО: JSON_ArrayAppend в этом моде работает через (родительский_объект, ключ, значение),
            // а не через отдельный хендл массива - именно поэтому задания раньше не долетали до клиента:
            // JSON_ArrayAppend(tkArray, "", x) тихо ничего не делал.
            JSON_SetArray(json, "tk", JSON_Array());

            for(new task_idx = 0; task_idx < BLACKPASS_TASK_SLOT_COUNT; task_idx++)
            {
                if(g_blackpass_tasks[playerid][task_idx][BP_TASK_ID] <= 0) continue;
                new Node:task_object = JSON_Object();
                new task_id_value = g_blackpass_tasks[playerid][task_idx][BP_TASK_ID];
                new task_client_status = BlackPass_GetClientTaskStatus(playerid, task_idx);

                // ВАЖНО: SendPacketToClient сериализует весь пакет в буфер [2048] байт -
                // при 11 заданиях с полным именем+описанием в каждом легко вылезти за лимит,
                // JSON обрежется и клиент не сможет его распарсить (задания не покажутся).
                // Поэтому здесь только компактные поля - id/d на случай другого имени ключа у клиента.
                JSON_SetInt(task_object, "id", task_id_value);
                JSON_SetInt(task_object, "d", task_id_value);
                JSON_SetInt(task_object, "p", g_blackpass_tasks[playerid][task_idx][BP_TASK_PROGRESS]);
                JSON_SetInt(task_object, "s", task_client_status);
                JSON_ArrayAppend(json, "tk", task_object);
            }
            JSON_SetInt(json, "tm", BlackPass_GetTaskResetTimer());

            SendPacketToClient(playerid, 22, json);
            return 1;
        }

        case 2:
        {
            JSON_SetInt(json, "t", -1);
            JSON_SetInt(json, "ty", 0);
            JSON_SetInt(json, "la", 2);

            SendPacketToClient(playerid, 22, json);
            return 1;
        }

        case 3:
        {
            printf("[BLACKPASS][SEND] rating packet");

            JSON_SetInt(json, "t", -1);
            JSON_SetInt(json, "ty", 0);
            JSON_SetInt(json, "la", 3);

            new query[1024];
            mysql_format(mysql, query, sizeof(query),
                "SELECT a.name,IFNULL(SUM(l.reward_value),0) AS quest_exp FROM blackpass_players bp INNER JOIN accounts a ON a.id=bp.account_id LEFT JOIN blackpass_logs l ON l.account_id=bp.account_id AND l.season_number=bp.season_number AND l.action='task_claim' WHERE bp.season_number=%d GROUP BY bp.account_id,a.name ORDER BY quest_exp DESC,a.name ASC LIMIT 50",
                BLACKPASS_SEASON_NUMBER
            );

            new Cache:rating_cache = mysql_query(mysql, query, true);
            JSON_SetArray(json, "j", JSON_Array());
            for(new row = 0; row < cache_num_rows(); row++)
            {
                new nickname[MAX_PLAYER_NAME + 1];
                new Node:rating_player = JSON_Object();

                cache_get_field_content(row, "name", nickname, sizeof(nickname));
                JSON_SetString(rating_player, "n", nickname);
                JSON_SetInt(rating_player, "och", cache_get_field_content_int(row, "quest_exp"));
                JSON_ArrayAppend(json, "j", rating_player);
            }
            cache_delete(rating_cache);

            mysql_format(mysql, query, sizeof(query),
                "SELECT COUNT(*) + 1 AS place_value FROM (SELECT bp.account_id,IFNULL(SUM(l.reward_value),0) AS quest_exp FROM blackpass_players bp LEFT JOIN blackpass_logs l ON l.account_id=bp.account_id AND l.season_number=bp.season_number AND l.action='task_claim' WHERE bp.season_number=%d GROUP BY bp.account_id) rating WHERE rating.quest_exp > (SELECT IFNULL(SUM(reward_value),0) FROM blackpass_logs WHERE account_id=%d AND season_number=%d AND action='task_claim')",
                BLACKPASS_SEASON_NUMBER,
                GetPlayerAccountID(playerid),
                BLACKPASS_SEASON_NUMBER
            );

            new Cache:place_cache = mysql_query(mysql, query, true);
            new place_value = 1;
            if(cache_num_rows())
            {
                place_value = cache_get_field_content_int(0, "place_value");
            }
            cache_delete(place_cache);

            JSON_SetInt(json, "m", place_value);

            SendPacketToClient(playerid, 22, json);
            return 1;
        }

        case 4:
        {
            new premium_price = 790;
            new deluxe_price = 1690;

            if(g_blackpass_player[playerid][BP_PREMIUM_STATUS] == BLACKPASS_STATUS_PREMIUM)
            {
                deluxe_price = 900;
            }

            JSON_SetInt(json, "t", -1);
            JSON_SetInt(json, "ty", 0);
            JSON_SetInt(json, "la", 4);
            JSON_SetInt(json, "p", premium_price);
            JSON_SetInt(json, "pp", deluxe_price);
            JSON_SetInt(json, "a", BlackPass_GetClientPremiumStatus(g_blackpass_player[playerid][BP_PREMIUM_STATUS]));
            JSON_SetString(json, "leftImage", "img_bp_left_ch.png");
            JSON_SetString(json, "rightImage", "img_bp_right_ch.png");
            JSON_SetString(json, "renderId", "img_28744.png");

            SendPacketToClient(playerid, 22, json);
            return 1;
        }
    }

    return 0;
}

stock BlackPass_HandleBuyLevels(playerid, Node:json)
{
    new levels_to_buy;
    JSON_GetInt(json, "p", levels_to_buy);
    if(levels_to_buy <= 0) levels_to_buy = 1;

    new old_level = BlackPass_GetCurrentLevel(playerid);
    if(old_level >= BLACKPASS_MAX_LEVELS)
    {
        JSON_SetInt(json, "t", -1);
        JSON_SetInt(json, "ty", 1);
        JSON_SetInt(json, "la", 0);
        JSON_SetInt(json, "s", 0);
        SendPacketToClient(playerid, 22, json);
        return 1;
    }

    new target_level = old_level + levels_to_buy;
    if(target_level > BLACKPASS_MAX_LEVELS) target_level = BLACKPASS_MAX_LEVELS;
    levels_to_buy = target_level - old_level;

    new price = levels_to_buy * BLACKPASS_LEVEL_PRICE;
    if(GetPlayerDonateRub(playerid) < price)
    {
        JSON_SetInt(json, "t", -1);
        JSON_SetInt(json, "ty", 1);
        JSON_SetInt(json, "la", 0);
        JSON_SetInt(json, "s", 0);
        SendPacketToClient(playerid, 22, json);
        return 1;
    }

    BlackPass_SetLevelWithReset(playerid, target_level);
    new new_level = BlackPass_GetCurrentLevel(playerid);

    if(new_level > old_level)
    {
        BlackPass_AutoClaimRewardsRange(
            playerid,
            old_level + 1,
            new_level,
            true,
            (g_blackpass_player[playerid][BP_PREMIUM_STATUS] != BLACKPASS_STATUS_NONE)
        );
    }

    GivePlayerDonateRub(playerid, -price, "Покупка уровней BlackPass", true, true);
    BlackPass_SavePlayer(playerid);
    BlackPass_LogEvent(playerid, "buy_levels", 0, 10, 0, levels_to_buy, price);

    JSON_SetInt(json, "t", -1);
    JSON_SetInt(json, "ty", 1);
    JSON_SetInt(json, "la", 0);
    JSON_SetInt(json, "s", 1);
    SendPacketToClient(playerid, 22, json);
    BlackPass_SendAutoClaimSyncRange(playerid, old_level, new_level, true, (g_blackpass_player[playerid][BP_PREMIUM_STATUS] != BLACKPASS_STATUS_NONE), 0);
    BlackPass_SendMainPacket(playerid, json, 0);
    BlackPass_SendStateRefresh(playerid, 0, -1);
    BlackPass_ShowLootNotification(playerid, "Награды получены в «Добычу»");
    return 1;
}

stock BlackPass_HandlePurchasePremium(playerid, Node:json)
{
    new premium_id;
    JSON_GetInt(json, "id", premium_id);

    new bool:is_deluxe = (premium_id == 0);
    new new_status = is_deluxe ? BLACKPASS_STATUS_DELUXE : BLACKPASS_STATUS_PREMIUM;
    new old_level = BlackPass_GetCurrentLevel(playerid);
    new price = is_deluxe ? BLACKPASS_DEFAULT_DELUXE_PRICE : BLACKPASS_DEFAULT_PREMIUM_PRICE;

    if(new_status == BLACKPASS_STATUS_DELUXE && g_blackpass_player[playerid][BP_PREMIUM_STATUS] == BLACKPASS_STATUS_PREMIUM)
    {
        price = 900;
    }

    if(g_blackpass_player[playerid][BP_PREMIUM_STATUS] >= new_status)
    {
        JSON_SetInt(json, "t", -1);
        JSON_SetInt(json, "ty", 1);
        JSON_SetInt(json, "la", 4);
        JSON_SetInt(json, "s", 1);
        JSON_SetInt(json, "a", BlackPass_GetClientPremiumStatus(g_blackpass_player[playerid][BP_PREMIUM_STATUS]));
        JSON_SetInt(json, "td", BLACKPASS_SEASON_DAYS * 86400);
        SendPacketToClient(playerid, 22, json);
        return 1;
    }

    if(GetPlayerDonateRub(playerid) < price)
    {
        JSON_SetInt(json, "t", -1);
        JSON_SetInt(json, "ty", 1);
        JSON_SetInt(json, "la", 4);
        JSON_SetInt(json, "s", 0);
        SendPacketToClient(playerid, 22, json);
        return 1;
    }

    GivePlayerDonateRub(playerid, -price, is_deluxe ? "Покупка BlackPass Deluxe" : "Покупка BlackPass Premium", true, true);
    g_blackpass_player[playerid][BP_PREMIUM_STATUS] = new_status;
    g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 0;

    if(is_deluxe)
    {
        BlackPass_AddLevelsWithReset(playerid, 10);
        BlackPass_AutoClaimRewardsRange(playerid, 1, BlackPass_GetCurrentLevel(playerid), true, true);
        if(!g_blackpass_player[playerid][BP_DELUXE_REWARDS_CLAIMED])
        {
            g_blackpass_player[playerid][BP_DELUXE_REWARDS_CLAIMED] = true;
            BlackPass_QueueDeluxeRewards(playerid, true);
        }
    }
    else
    {
        BlackPass_AutoClaimRewardsRange(playerid, 1, BlackPass_GetCurrentLevel(playerid), false, true);
    }

    BlackPass_SavePlayer(playerid);
    BlackPass_LogEvent(playerid, "buy_pass", 0, 0, new_status, 1, price);

    JSON_SetInt(json, "t", -1);
    JSON_SetInt(json, "ty", 1);
    JSON_SetInt(json, "la", 4);
    JSON_SetInt(json, "s", 1);
    JSON_SetInt(json, "a", BlackPass_GetClientPremiumStatus(g_blackpass_player[playerid][BP_PREMIUM_STATUS]));
    JSON_SetInt(json, "td", BLACKPASS_SEASON_DAYS * 86400);
    JSON_SetInt(json, "lv", BlackPass_GetCurrentLevel(playerid));
    JSON_SetInt(json, "ec", g_blackpass_player[playerid][BP_EXPERIENCE] % BLACKPASS_LEVEL_EXP);
    SendPacketToClient(playerid, 22, json);

    if(is_deluxe)
    {
        new new_level = BlackPass_GetCurrentLevel(playerid);
        BlackPass_SendAutoClaimSyncRange(playerid, old_level, new_level, true, (g_blackpass_player[playerid][BP_PREMIUM_STATUS] != BLACKPASS_STATUS_NONE), 0);
        BlackPass_SendMainPacket(playerid, json, 0);
        BlackPass_SendStateRefresh(playerid, 0, -1);
        BlackPass_ShowLootNotification(playerid, "Награды Premium Deluxe получены в «Добычу»");
    }
    else
    {
        BlackPass_SendClaimPacketsRange(playerid, 1, BlackPass_GetCurrentLevel(playerid), false, true, 0);
        BlackPass_SendMainPacket(playerid, json, 0);
        BlackPass_SendStateRefresh(playerid, 0, -1);
        BlackPass_ShowLootNotification(playerid, "Награды Premium получены в «Добычу»");
    }
    return 1;
}

stock BlackPass_HandleGetPrize(playerid, Node:json)
{
    new reward_id, is_premium, layout_id;
    JSON_GetInt(json, "id", reward_id);
    JSON_GetInt(json, "p", is_premium);
    JSON_GetInt(json, "la", layout_id);

    if(reward_id < 1 || reward_id > BLACKPASS_MAX_LEVELS) return 1;
    if(BlackPass_GetCurrentLevel(playerid) < reward_id) return 1;
    if(is_premium && g_blackpass_player[playerid][BP_PREMIUM_STATUS] == BLACKPASS_STATUS_NONE) return 1;

    // First put the reward into /reward. Only after a successful queue
    // operation do we mark the BP reward as claimed. This prevents cars,
    // accessories and other special rewards from becoming "claimed" while
    // never reaching the player's reward inventory.
    if(is_premium)
    {
        if(g_blackpass_claimed_premium[playerid][reward_id]) return 1;
        if(!BlackPass_QueueLevelReward(playerid, reward_id, true))
        {
            printf("[BLACKPASS][CLAIM][ERROR] premium reward was not queued: player=%d level=%d", playerid, reward_id);
            return 1;
        }
        g_blackpass_claimed_premium[playerid][reward_id] = true;
    }
    else
    {
        if(g_blackpass_claimed_standard[playerid][reward_id]) return 1;
        if(!BlackPass_QueueLevelReward(playerid, reward_id, false))
        {
            printf("[BLACKPASS][CLAIM][ERROR] standard reward was not queued: player=%d level=%d", playerid, reward_id);
            return 1;
        }
        g_blackpass_claimed_standard[playerid][reward_id] = true;
    }

    g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = layout_id;
    BlackPass_SavePlayer(playerid);
    BlackPass_LogEvent(playerid, "reward_claim", reward_id, 0, 0, 1, is_premium);

    JSON_SetInt(json, "t", -1);
    JSON_SetInt(json, "ty", 2);
    JSON_SetInt(json, "la", layout_id);
    JSON_SetInt(json, "s", 1);
    JSON_SetInt(json, "id", reward_id);
    JSON_SetInt(json, "p", is_premium);
    SendPacketToClient(playerid, 22, json);
    return 1;
}

stock BlackPass_HandleRefreshRating(playerid, Node:json)
{
    new current_time = gettime();
    if(g_blackpass_rating_refresh_until[playerid] > current_time)
    {
        printf("[BLACKPASS][RATING] cooldown player=%d left=%d", playerid, g_blackpass_rating_refresh_until[playerid] - current_time);
        ShowNotificationNew(playerid, 2, 4, 0, 0, "Обновлять рейтинг можно раз в 30 секунд", "");
        return 1;
    }

    g_blackpass_rating_refresh_until[playerid] = current_time + 30;
    g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 3;
    return BlackPass_SendMainPacket(playerid, json, 3);
}

stock BlackPass_HandlePacket(playerid, Node:json)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
    if(!BlackPass_LoadPlayer(playerid)) return 0;

    new type;
    JSON_GetInt(json, "t", type);

    new ty;
    JSON_GetInt(json, "ty", ty);

    new latype;
    JSON_GetInt(json, "la", latype);


    if(type == -2)
    {
        type = -1;
        ty = -1;
        latype = 0;

        JSON_SetInt(json, "t", -1);
        JSON_SetInt(json, "ty", -1);
        JSON_SetInt(json, "la", 0);
    }

    switch(type)
    {
        case -1:
        {

            JSON_SetInt(json, "t", -1);
            JSON_SetInt(json, "ty", ty);
            JSON_SetInt(json, "la", latype);
            JSON_SetInt(json, "lv", g_blackpass_player[playerid][BP_LEVEL]);
            JSON_SetInt(json, "ec", g_blackpass_player[playerid][BP_EXPERIENCE] % BLACKPASS_LEVEL_EXP);
            JSON_SetInt(json, "a", BlackPass_GetClientPremiumStatus(g_blackpass_player[playerid][BP_PREMIUM_STATUS]));
            JSON_SetInt(json, "es", g_blackpass_player[playerid][BP_EXPERIENCE]);
            JSON_SetInt(json, "l", g_blackpass_player[playerid][BP_EXPERIENCE]);
            JSON_SetInt(json, "lc", g_blackpass_player[playerid][BP_SELECTED_LAYOUT]);
            JSON_SetInt(json, "is", g_blackpass_claimed_standard[playerid][BlackPass_GetCurrentLevel(playerid)] ? 0 : 1);
            JSON_SetInt(json, "ps", g_blackpass_claimed_premium[playerid][BlackPass_GetCurrentLevel(playerid)] ? 0 : 1);

            switch(ty)
            {
                case -1:
                {

                    switch(latype)
                    {
                        case 0:
                        {
                            g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 0;

                            JSON_SetInt(json, "t", -1);
                            JSON_SetInt(json, "ty", -1);
                            JSON_SetInt(json, "la", 0);
                            JSON_SetString(json, "sn", BLACKPASS_SEASON_NAME);
                            JSON_SetString(json, "ln", GetPlayerNameEx(playerid));
                            JSON_SetInt(json, "lv", g_blackpass_player[playerid][BP_LEVEL]);
                            JSON_SetInt(json, "td", BLACKPASS_SEASON_DAYS * 86400);
                            JSON_SetInt(json, "ec", g_blackpass_player[playerid][BP_EXPERIENCE] % BLACKPASS_LEVEL_EXP);
                            JSON_SetInt(json, "a", BlackPass_GetClientPremiumStatus(g_blackpass_player[playerid][BP_PREMIUM_STATUS]));
                            JSON_SetInt(json, "sp", 0);
                            JSON_SetInt(json, "is", g_blackpass_claimed_standard[playerid][BlackPass_GetCurrentLevel(playerid)] ? 0 : 1);
                            JSON_SetInt(json, "ps", g_blackpass_claimed_premium[playerid][BlackPass_GetCurrentLevel(playerid)] ? 0 : 1);

                            SendPacketToClient(playerid, 22, json);
                            return 1;
                        }
                    }

                    return 0;
                }

                case 0:
                {
                    switch(latype)
                    {
                        case -1:
                        {
                            g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 0;
                            return BlackPass_SendMainPacket(playerid, json, 0);
                        }

                        case 0:
                        {
                            g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 0;
                            return BlackPass_SendMainPacket(playerid, json, 0);
                        }

                        case 1:
                        {
                            g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 1;
                            new task_id;
                            JSON_GetInt(json, "id", task_id);
                            if(task_id > 0)
                            {
                                return BlackPass_HandleTaskPress(playerid, json);
                            }
                            return BlackPass_SendMainPacket(playerid, json, 1);
                        }

                        case 2:
                        {
                            g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 2;
                            return BlackPass_SendMainPacket(playerid, json, 2);
                        }

                        case 3:
                        {
                            return BlackPass_HandleRefreshRating(playerid, json);
                        }

                        case 4:
                        {
                            g_blackpass_player[playerid][BP_SELECTED_LAYOUT] = 4;
                            return BlackPass_SendMainPacket(playerid, json, 4);
                        }
                    }

                    return 0;
                }

                case 1:
                {
                    JSON_SetInt(json, "t", -1);
                    JSON_SetInt(json, "ty", 1);

                    switch(latype)
                    {
                        case 0: return BlackPass_HandleBuyLevels(playerid, json);
                        case 1: return BlackPass_HandleTaskExchange(playerid, json);
                        case 3: return BlackPass_HandleRefreshRating(playerid, json);
                        case 4: return BlackPass_HandlePurchasePremium(playerid, json);
                    }

                    return 1;
                }

                case 2:
                {

                    switch(latype)
                    {
                        case 0: return BlackPass_HandleGetPrize(playerid, json);
                    }

                    return 1;
                }
            }

            return 0;
        }
    }

    return 0;
}


CMD:blackpass(playerid)
{
    new Node:bp_json = JSON_Object();
    JSON_SetInt(bp_json, "t", -2);
    new result = BlackPass_HandlePacket(playerid, bp_json);
    JSON_Cleanup(bp_json);
    return result;
}

CMD:clearbp(playerid, params[])
{
    #pragma unused params
    if(GetPlayerAdminEx(playerid) < 12) return ShowNotificationNew(playerid, 2, 3, 0, 0, "У вас нет доступа к использованию данной команды", "");

    mysql_query(mysql, "TRUNCATE TABLE blackpass_players", false);
    mysql_query(mysql, "TRUNCATE TABLE blackpass_tasks", false);
    mysql_query(mysql, "TRUNCATE TABLE blackpass_logs", false);

    // Сброс в памяти у всех, кто сейчас на сервере
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;

        g_blackpass_player[i][BP_DATA_LOADED] = false;
        g_blackpass_player[i][BP_ACCOUNT_ID] = 0;
        g_blackpass_player[i][BP_EXPERIENCE] = 0;
        g_blackpass_player[i][BP_LEVEL] = 0;
        g_blackpass_player[i][BP_PREMIUM_STATUS] = BLACKPASS_STATUS_NONE;
        g_blackpass_player[i][BP_DUST] = 0;
        g_blackpass_player[i][BP_SELECTED_LAYOUT] = 0;
        g_blackpass_player[i][BP_DELUXE_REWARDS_CLAIMED] = false;

        for(new lvl = 0; lvl <= BLACKPASS_MAX_LEVELS; lvl++)
        {
            g_blackpass_claimed_standard[i][lvl] = false;
            g_blackpass_claimed_premium[i][lvl] = false;
        }

        g_blackpass_tasks_loaded[i] = false;
        for(new task_idx = 0; task_idx < BLACKPASS_TASK_SLOT_COUNT; task_idx++)
        {
            g_blackpass_tasks[i][task_idx][BP_TASK_ROW_ID] = 0;
            g_blackpass_tasks[i][task_idx][BP_TASK_ID] = 0;
            g_blackpass_tasks[i][task_idx][BP_TASK_PROGRESS] = 0;
            g_blackpass_tasks[i][task_idx][BP_TASK_STORED_STATUS] = BLACKPASS_STATUS_NONE;
            g_blackpass_tasks[i][task_idx][BP_TASK_TRACKED] = false;
            g_blackpass_tasks[i][task_idx][BP_TASK_COMPLETE_NOTIFIED] = false;
        }
    }

    SendClientMessageToAll(-1, "[BlackPass] Администратор полностью сбросил прогресс BlackPass у всех игроков.");
    return 1;
}