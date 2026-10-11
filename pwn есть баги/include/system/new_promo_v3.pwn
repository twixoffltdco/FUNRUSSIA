// Максимальная длина промокода
#define MAX_PROMO_CODE_LENGTH 32
// Максимальное количество промокодов, загружаемых в память
#define MAX_PROMO_CODES_ARRAY_SIZE 100
// Максимальное количество одновременно активных временных призов для одного игрока
#define MAX_CONCURRENT_PLAYER_PROMO_PRIZES 5

// ТУТ МОЖЕТЕ МЕНЯТЬ НАСТРОЙКИ КАЖДОГО ЛВЛ ПРОМОКОДА

new PROMO_LEVEL_DATA[11][5] = {
// {уровень промокода, кол-во активаций чтобы повыситься до этого уровня, кол-во призов, кол-во доната для улучшения, кол-во денег которые будет получать владелец промокода за активацию}
    {0, 0, 0, 0, 0},
    {1, 20, 1, 0, 10000},
    {2, 20, 2, 250, 15000},
    {3, 100, 3, 500, 20000},
    {4, 500, 3, 1000, 25000},
    {5, 1000, 3, 1500, 30000},
    {6, 1500, 3, 2000, 37000},
    {7, 2000, 4, 2500, 43000},
    {8, 2700, 4, 3200, 50000},
    {9, 4000, 5, 5500, 65000},
    {10, 5000, 5, 50000, 100000}
};

// {тип приза (0-деньги, 1-донат, 2-машина, 3-EXP), количество приза или айди авто, время действия в часах если 0 то это навсегда}
new PromoLevelPrizes_1[1][3] = {
    {0, 15000, 0}
};

new PromoLevelPrizes_2[2][3] = {
    {3, 3, 0},
    {0, 30000, 0}
};

new PromoLevelPrizes_3[3][3] = {
    {3, 5, 0},
    {0, 30000, 0},
    {2, 489, 3}
};

new PromoLevelPrizes_4[3][3] = {
    {3, 5, 0},
    {0, 45000, 0},
    {2, 466, 6}
};

new PromoLevelPrizes_5[3][3] = {
    {3, 7, 0},
    {0, 50000, 0},
    {2, 494, 6}
};

new PromoLevelPrizes_6[3][3] = {
    {3, 10, 0},
    {0, 55000, 0},
    {2, 451, 8}
};

new PromoLevelPrizes_7[4][3] = {
    {3, 10, 0},
    {0, 55000, 0},
    {2, 451, 10},
    {2, 503, 8}
};

new PromoLevelPrizes_8[4][3] = {
    {3, 12, 0},
    {0, 62000, 0},
    {2, 541, 12},
    {2, 502, 8}
};

new PromoLevelPrizes_9[5][3] = {
    {3, 14, 0},
    {0, 65000, 0},
    {2, 505, 16},
    {2, 402, 10},
    {2, 400, 6}
};

new PromoLevelPrizes_10[5][3] = {
    {3, 20, 0},
    {0, 75000, 0},
    {2, 415, 24},
    {2, 579, 14},
    {2, 505, 10}
};

new PlayerDialogPromoData[MAX_PLAYERS];

#define DIALOG_PROMO_PRIZE_INFO         12345 // Для отображения результата активации
#define DIALOG_ADDPROMO_CODE            12346 // Ввод названия промокода
#define DIALOG_ADDPROMO_USES_LIMIT      12347 // Ввод лимита использований промокода (общий)
#define DIALOG_ADDPROMO_PRIZE_COUNT     12348 // Ввод количества призов (1-5)
#define DIALOG_ADDPROMO_SINGLE_PRIZE_TYPE 12349 // Выбор типа отдельного приза (деньги, донат, авто)
#define DIALOG_ADDPROMO_SINGLE_PRIZE_VALUE 12350 // Ввод значения отдельного приза (сумма/модель)
#define DIALOG_ADDPROMO_SINGLE_PRIZE_DURATION 12351 // Выбор длительности отдельного приза (временный/постоянный)
#define DIALOG_ADDPROMO_SINGLE_PRIZE_DURATION_HOURS 12352 // Ввод часов для временного приза
#define DIALOG_APPLY_PROMO_CODE         12353 // Ввод промокода для активации
#define DIALOG_CONFIRM_PROMO_CREATION   12354 // Подтверждение создания промокода
#define DIALOG_ACT_PROMO                12355 // Главный диалог промокодов
#define DIALOG_ADDPROMO_CODE_BY_PLAYER  12356 // Диалог создания промокода игроком
// #define DIALOG_ADDPROMO_PRIZE_MONEY_BY_PLAYER 12357 // ОЛД СИСТЕМО ДЛЯ ввода суммы денежного приза при создании промокода игроком
#define DIALOG_ACT_PROMO_PRIZES         12358 // Диалог для отображения активных призов игрока
#define DIALOG_PROMO_INFO               12359 // Диалог с информацией о промокодах
#define DIALOG_PROMO_MANAGEMENT         12360 // Диалог управления своим промокодом
// #define DIALOG_PROMO_PRIZE_SETTINGS  12361 // ТОЖЕ ОЛД ЗОЛУПО ДЛЯ для настройки призов
#define DIALOG_PROMO_UPGRADE_LEVELS     12362 // Диалог для выбора уровня для улучшения
#define DIALOG_PROMO_UPGRADE_CONFIRM    12363 // Диалог для подтверждения улучшения
#define DIALOG_PROMO_STATS              12364 // Диалог для информации о балансе и всякой хуйни

enum E_PRIZE_TYPE
{
    PRIZE_TYPE_MONEY,
    PRIZE_TYPE_DONATE,
    PRIZE_TYPE_CAR,
    PRIZE_TYPE_EXP
}

enum E_PROMO_DATA
{
    PromoID,            // ID промокода в БД (promocodes.id)
    String:PromoCode[MAX_PROMO_CODE_LENGTH], // Сам промокод
    PromoUses,          // Сколько раз промокод может быть использован (общий лимит)
    UsesLeft,           // Оставшееся количество использований (общий лимит)
    NumPrizes,          // Количество призов в этом промокоде
    _E_PROMO_DATA_SIZE
}
#define PROMO_DATA_SIZE _E_PROMO_DATA_SIZE

new PromoCodes[MAX_PROMO_CODES_ARRAY_SIZE][E_PROMO_DATA];
new g_iLoadedPromoCodes = 0;

enum E_NEW_PROMO_CREATION_DATA
{
    String:NewPromoCodeString[MAX_PROMO_CODE_LENGTH],
    NewPromoPrizeCount,        // Выбранное количество призов для текущего создаваемого промокода
    NewPromoCurrentPrizeIndex, // Индекс текущего настраиваемого приза (0 до 4)
    NewPromoUsesLimit,         // Лимит использований для главного промокода
}
new PlayerPromoCreationData[MAX_PLAYERS][E_NEW_PROMO_CREATION_DATA];

enum E_TEMP_PRIZE_DATA
{
    TempPrizeType,     // Тип приза (PRIZE_TYPE_MONEY, etc.)
    TempPrizeValue,    // Значение приза (сумма денег/доната, ID модели авто)
    TempPrizeDuration, // Длительность в часах (0 для постоянного)
}
new PlayerTempPrizes[MAX_PLAYERS][5][E_TEMP_PRIZE_DATA];

enum E_PLAYER_PROMO_TIMER_DATA
{
    pPromoTimerID,      // ID SA:MP таймера
    pPlayerPromoSQLID,  // ID записи из таблицы player_promos (primary key)
}
new PlayerPromoTimers[MAX_PLAYERS][MAX_CONCURRENT_PLAYER_PROMO_PRIZES][E_PLAYER_PROMO_TIMER_DATA];
new g_iPlayerPromoTimersCount[MAX_PLAYERS]; 

// Прототипы функций, вертон не поленился (я мог не все ебануть, а так это для моего удобства)
forward CheckAndCreatePromoTables();
forward LoadPromoCodesFromDatabase();
forward CheckUsePromoCode(playerid, accountId, promoSqlId);
forward OnPromoCodeCheckComplete(playerid, const promoCode[]);
forward HasPlayerCreatedPromo(playerid); // Функция для проверки, есть ли у игрока промокод



forward OnPromoTimerTick(playerPromoSQLID); // Изменено: теперь принимает player_promos.id












forward AddPlayerActivatedPromo(account_id, promo_id); // записывает какой промокод и кем активирован (доп решение вертона)

public OnGameModeInit()
{
    print("[WERTON_SYSTEM] Система промокодов загружена.");
    SetTimer("CheckAndCreatePromoTables", 1500, false);
    SetTimer("LoadPromoCodesFromDatabase", 3000, false);
    #if defined prom_OnGameModeInit
        return prom_OnGameModeInit();
    #else
        return 1;
    #endif
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit prom_OnGameModeInit
#if defined prom_OnGameModeInit
    forward prom_OnGameModeInit();
#endif

public OnPromoTimerTick(playerPromoSQLID)
{
    new query[256];
    new Cache:result;
    new accountId, prizeType, prizeValue, promoIdForCarRevoke = 0;
    new playerid = INVALID_PLAYER_ID;

    mysql_format(mysql, query, sizeof(query), "SELECT pp.account_id, pp.start_time, pp.remaining_time, ppz.prize_type, ppz.prize_value, ppz.prize_duration, ppz.promo_id FROM player_promos pp JOIN promo_prizes ppz ON pp.promo_prize_sql_id = ppz.id WHERE pp.id = %d", playerPromoSQLID);
    result = mysql_query(mysql, query, true);

    if(mysql_errno() != 0 || cache_num_rows(result) == 0)
    {
        printf("[WERTON_PROMO] Ошибка: Не удалось найти данные player_promos (SQL ID: %d) для таймера. errno: %d", playerPromoSQLID, mysql_errno());
       
        for(new p = 0; p < MAX_PLAYERS; p++)
        {
            if(!IsPlayerConnected(p)) continue;
            for(new i = 0; i < g_iPlayerPromoTimersCount[p]; i++)
            {
                if(PlayerPromoTimers[p][i][pPlayerPromoSQLID] == playerPromoSQLID)
                {
                    KillTimer(PlayerPromoTimers[p][i][pPromoTimerID]);
                    for(new j = i; j < g_iPlayerPromoTimersCount[p] - 1; j++)
                    {
                        PlayerPromoTimers[p][j][pPromoTimerID] = PlayerPromoTimers[p][j+1][pPromoTimerID];
                        PlayerPromoTimers[p][j][pPlayerPromoSQLID] = PlayerPromoTimers[p][j+1][pPlayerPromoSQLID];
                    }
                    g_iPlayerPromoTimersCount[p]--;
                    break;
                }
            }
        }
        cache_delete(result);
        return 0;
    }

    accountId = cache_get_field_content_int(0, "account_id");
    new startTime = cache_get_field_content_int(0, "start_time");
    prizeType = cache_get_field_content_int(0, "prize_type");
    prizeValue = cache_get_field_content_int(0, "prize_value");
    new prizeDurationHours = cache_get_field_content_int(0, "prize_duration");
    promoIdForCarRevoke = cache_get_field_content_int(0, "promo_id"); 

    new remainingTime = prizeDurationHours * 3600 - (gettime() - startTime);

    if(remainingTime <= 0)
    {
        playerid = GetPlayerIDFromAccountID(accountId);
        if(playerid != INVALID_PLAYER_ID)
        {
            RevokePromoPrize(accountId, prizeType, prizeValue, promoIdForCarRevoke); 
            SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Срок действия вашего временного приза истек!");
        }

        mysql_format(mysql, query, sizeof(query), "DELETE FROM player_promos WHERE id = %d", playerPromoSQLID);
        mysql_query(mysql, query, false);

        for(new p = 0; p < MAX_PLAYERS; p++)
        {
            if(!IsPlayerConnected(p)) continue;
            for(new i = 0; i < g_iPlayerPromoTimersCount[p]; i++)
            {
                if(PlayerPromoTimers[p][i][pPlayerPromoSQLID] == playerPromoSQLID)
                {
                    KillTimer(PlayerPromoTimers[p][i][pPromoTimerID]);
                    for(new j = i; j < g_iPlayerPromoTimersCount[p] - 1; j++)
                    {
                        PlayerPromoTimers[p][j][pPromoTimerID] = PlayerPromoTimers[p][j+1][pPromoTimerID];
                        PlayerPromoTimers[p][j][pPlayerPromoSQLID] = PlayerPromoTimers[p][j+1][pPlayerPromoSQLID];
                    }
                    g_iPlayerPromoTimersCount[p]--;
                    break;
                }
            }
        }
    }
    else
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE player_promos SET remaining_time = %d WHERE id = %d",
            remainingTime, playerPromoSQLID);
        mysql_query(mysql, query, false);
    }
    cache_delete(result);
    return 1;
}

public CheckAndCreatePromoTables()
{
    new Cache:cache;
    new query[512];

    mysql_format(mysql, query, sizeof(query), "SELECT * FROM promocodes LIMIT 1");
    cache = mysql_query(mysql, query, true);
    if(mysql_errno() != 0)
    {
        printf("[WERTON_PROMO] Таблица 'promocodes' не найдена. Создаем новую структуру...");
        mysql_format(mysql, query, sizeof(query), "CREATE TABLE `promocodes` (`id` INT NOT NULL AUTO_INCREMENT,`code` VARCHAR(%d) NOT NULL UNIQUE,`uses_limit` INT NOT NULL DEFAULT 1,`uses_left` INT NOT NULL DEFAULT 1,`num_prizes` TINYINT(1) NOT NULL DEFAULT 1,`activations` INT NOT NULL DEFAULT 0, `promo_level` INT NOT NULL DEFAULT -1, `promo_balance` INT NOT NULL DEFAULT 0,`creator_account_id` INT NOT NULL DEFAULT 0,`creation_cost` INT NOT NULL DEFAULT 0,`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`id`)) ENGINE = InnoDB", MAX_PROMO_CODE_LENGTH);
        mysql_query(mysql, query, false);
        if(mysql_errno() != 0)
        {
            printf("[WERTON_PROMO] Ошибка при создании таблицы 'promocodes': %d", mysql_errno());
        }
        else
        {
            printf("[WERTON_PROMO] Таблица 'promocodes' успешно создана с новой структурой.");
        }
    }
    cache_delete(cache);

    mysql_format(mysql, query, sizeof(query), "SELECT * FROM `activated_promos` LIMIT 1");
    cache = mysql_query(mysql, query, true);

    if(mysql_errno() != 0)
    {
        printf("[WERTON_PROMO] Таблица 'activated_promos' не найдена. Создаем новую структуру...");
        mysql_format(mysql, query, sizeof(query), "CREATE TABLE IF NOT EXISTS `activated_promos` (`id` INT(11) NOT NULL AUTO_INCREMENT, `account_id` INT(11) NOT NULL, `promo_id` INT(11) NOT NULL, `activated_at` DATETIME NOT NULL, PRIMARY KEY (`id`), UNIQUE KEY `account_promo` (`account_id`, `promo_id`)) ENGINE=InnoDB;");
        mysql_query(mysql, query, false);

        if(mysql_errno() != 0)
        {
            printf("[WERTON_PROMO] Ошибка при создании таблицы 'activated_promos': %d", mysql_errno());
        }
        else
        {
            printf("[WERTON_PROMO] Таблица 'activated_promos' успешно создана.");
        }
    }
    cache_delete(cache);

    mysql_format(mysql, query, sizeof(query), "SELECT * FROM promo_prizes LIMIT 1");
    cache = mysql_query(mysql, query, true);
    if(mysql_errno() != 0)
    {
        printf("[WERTON_PROMO] Таблица 'promo_prizes' не найдена. Создаем...");
        mysql_format(mysql, query, sizeof(query), "CREATE TABLE `promo_prizes` (`id` INT NOT NULL AUTO_INCREMENT,`promo_id` INT NOT NULL,`prize_index` TINYINT(1) NOT NULL,`prize_type` TINYINT(1) NOT NULL DEFAULT '0',`prize_value` INT NOT NULL DEFAULT '0',`prize_duration` INT NOT NULL DEFAULT '0', PRIMARY KEY (`id`), UNIQUE KEY `promo_prize_unique` (`promo_id`, `prize_index`), FOREIGN KEY (`promo_id`) REFERENCES `promocodes`(`id`) ON DELETE CASCADE) ENGINE = InnoDB");
        mysql_query(mysql, query, false);
        if(mysql_errno() != 0)
        {
            printf("[WERTON_PROMO] Ошибка при создании таблицы 'promo_prizes': %d", mysql_errno());
        }
        else
        {
            printf("[WERTON_PROMO] Таблица 'promo_prizes' успешно создана.");
        }
    }
    cache_delete(cache);

    mysql_format(mysql, query, sizeof(query), "SELECT * FROM player_promos LIMIT 1");
    cache = mysql_query(mysql, query, true);

    if(mysql_errno() != 0 || cache_num_fields(cache) != 5)
    {
        printf("[WERTON_PROMO] Таблица 'player_promos' не найдена или имеет старую структуру. Создаем новую...");
       
        if(mysql_errno() == 0) {
            mysql_query(mysql, "DROP TABLE IF EXISTS `player_promos`", false);
            printf("[WERTON_PROMO] Старая таблица 'player_promos' удалена.");
        }
        mysql_format(mysql, query, sizeof(query), "CREATE TABLE `player_promos` (`id` INT NOT NULL AUTO_INCREMENT,`account_id` INT NOT NULL,`promo_prize_sql_id` INT NOT NULL, `start_time` INT NOT NULL, `remaining_time` INT NOT NULL, PRIMARY KEY (`id`), UNIQUE KEY `account_promo_prize_unique` (`account_id`, `promo_prize_sql_id`), FOREIGN KEY (`promo_prize_sql_id`) REFERENCES `promo_prizes`(`id`) ON DELETE CASCADE) ENGINE = InnoDB");
        mysql_query(mysql, query, false);
        if(mysql_errno() != 0)
        {
            printf("[WERTON_PROMO] Ошибка при создании таблицы 'player_promos': %d", mysql_errno());
        }
        else
        {
            printf("[WERTON_PROMO] Таблица 'player_promos' успешно создана с новой структурой.");
        }
    }
    cache_delete(cache);

    mysql_format(mysql, query, sizeof(query), "SHOW COLUMNS FROM `ownable_cars` LIKE 'promo_id'");
    cache = mysql_query(mysql, query, true);
    if(cache_num_rows() == 0)
    {
        printf("[WERTON_PROMO] Столбец 'promo_id' в 'ownable_cars' не найден. Добавляем...");
        mysql_format(mysql, query, sizeof(query), "ALTER TABLE `ownable_cars` ADD `promo_id` INT NOT NULL DEFAULT '0' AFTER `create_time`");
        mysql_query(mysql, query, false);
        if(mysql_errno() != 0)
        {
            printf("[WERTON_PROMO] Ошибка при добавлении столбца 'promo_id': %d", mysql_errno());
        }
        else
        {
            printf("[WERTON_PROMO] Столбец 'promo_id' успешно добавлен.");
        }
    }
    cache_delete(cache);

    mysql_format(mysql, query, sizeof(query), "SHOW COLUMNS FROM `ownable_cars` LIKE 'promo_status_car'");
    cache = mysql_query(mysql, query, true);
    if(cache_num_rows() == 0)
    {
        printf("[WERTON_PROMO] Столбец 'promo_status_car' в 'ownable_cars' не найден. Добавляем...");
        mysql_format(mysql, query, sizeof(query), "ALTER TABLE `ownable_cars` ADD `promo_status_car` TINYINT(1) NOT NULL DEFAULT '0' AFTER `promo_id`");
        mysql_query(mysql, query, false);
        if(mysql_errno() != 0)
        {
            printf("[WERTON_PROMO] Ошибка при добавлении столбца 'promo_status_car': %d", mysql_errno());
        }
        else
        {
            printf("[WERTON_PROMO] Столбец 'promo_status_car' успешно добавлен.");
        }
    }
    cache_delete(cache);
}

public LoadPromoCodesFromDatabase()
{
    printf("[DEBUG] --- НАЧАЛО LoadPromoCodesFromDatabase ---");
    new Cache:result;
    new query[128];

    mysql_format(mysql, query, sizeof(query), "SELECT id, code, uses_limit, uses_left, num_prizes FROM promocodes");
    printf("[DEBUG] Выполняем SQL запрос: %s", query);

    result = mysql_query(mysql, query, true);
    printf("[DEBUG] SQL запрос выполнен. errno: %d", mysql_errno());

    if(mysql_errno() != 0) {
        printf("[DEBUG] ОШИБКА MySQL при загрузке промокодов: %d", mysql_errno());
        cache_delete(result);
        return 0;
    }

    g_iLoadedPromoCodes = cache_num_rows(result);
    printf("[DEBUG] Количество строк в результате (cache_num_rows): %d", g_iLoadedPromoCodes);

    if(g_iLoadedPromoCodes > MAX_PROMO_CODES_ARRAY_SIZE)
    {
        printf("[WERTON_PROMO] ВНИМАНИЕ: Количество промокодов (%d) превышает размер массива (%d). Загружено только %d.", g_iLoadedPromoCodes, MAX_PROMO_CODES_ARRAY_SIZE, MAX_PROMO_CODES_ARRAY_SIZE);
        g_iLoadedPromoCodes = MAX_PROMO_CODES_ARRAY_SIZE;
    }
    else if(g_iLoadedPromoCodes == 0) {
        printf("[WERTON_PROMO] В базе данных нет промокодов для загрузки.");
    }

    for(new i = 0; i < g_iLoadedPromoCodes; i++)
    {
        PromoCodes[i][PromoID] = cache_get_field_content_int(i, "id");
        cache_get_field_content(i, "code", PromoCodes[i][PromoCode], MAX_PROMO_CODE_LENGTH);
        PromoCodes[i][PromoUses] = cache_get_field_content_int(i, "uses_limit");
        PromoCodes[i][UsesLeft] = cache_get_field_content_int(i, "uses_left");
        PromoCodes[i][NumPrizes] = cache_get_field_content_int(i, "num_prizes");
    }
    cache_delete(result);
    printf("[WERTON_PROMO] Все промокоды успешно загружены. Загружено: %d", g_iLoadedPromoCodes);
    printf("[DEBUG] --- КОНЕЦ LoadPromoCodesFromDatabase ---");
    return 1;
}

public OnPlayerConnect(playerid)
{
    g_iPlayerPromoTimersCount[playerid] = 0;
    for(new i = 0; i < MAX_CONCURRENT_PLAYER_PROMO_PRIZES; i++)
    {
        PlayerPromoTimers[playerid][i][pPromoTimerID] = 0;
        PlayerPromoTimers[playerid][i][pPlayerPromoSQLID] = 0;
    }
    OnPlayerLogin(playerid);
    #if defined prom_OnPlayerConnect
        return prom_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect prom_OnPlayerConnect
#if defined prom_OnPlayerConnect
    forward prom_OnPlayerConnect(playerid);
#endif

public OnPlayerLogin(playerid)
{
    new accountId = GetPlayerAccountID(playerid);
    new Cache:result;
    new query[256];

    mysql_format(mysql, query, sizeof(query), "SELECT pp.id, pp.start_time, pp.remaining_time, ppz.prize_duration, ppz.prize_type, ppz.prize_value, ppz.promo_id FROM player_promos pp JOIN promo_prizes ppz ON pp.promo_prize_sql_id = ppz.id WHERE pp.account_id = %d AND ppz.prize_duration > 0", accountId);
    result = mysql_query(mysql, query, true);

    new rows = cache_num_rows();
    if(rows > 0)
    {
        for(new i = 0; i < rows; i++)
        {
            new playerPromoSQLID = cache_get_field_content_int(i, "id");
            new startTime = cache_get_field_content_int(i, "start_time");
            new remainingTimeFromDB = cache_get_field_content_int(i, "remaining_time");
            new prizeDurationHours = cache_get_field_content_int(i, "prize_duration");
            new prizeType = cache_get_field_content_int(i, "prize_type");
            new prizeValue = cache_get_field_content_int(i, "prize_value");
            new promoIdForCarRevoke = cache_get_field_content_int(i, "promo_id");

            new actualRemainingTime = prizeDurationHours * 3600 - (gettime() - startTime);

            if(actualRemainingTime > 0)
            {
                mysql_format(mysql, query, sizeof(query), "UPDATE player_promos SET remaining_time = %d WHERE id = %d", actualRemainingTime, playerPromoSQLID);
                mysql_query(mysql, query, false);

                SetPlayerPromoTimer(playerid, playerPromoSQLID, prizeDurationHours);
            }
            else
            {
                RevokePromoPrize(accountId, prizeType, prizeValue, promoIdForCarRevoke);

                mysql_format(mysql, query, sizeof(query), "DELETE FROM player_promos WHERE id = %d", playerPromoSQLID);
                mysql_query(mysql, query, false);
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Срок действия вашего временного приза истек!");
            }
        }
    }
    cache_delete(result);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    StopPlayerPromoTimer(playerid);
    #if defined prom_OnPlayerDisconnect
        return prom_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect prom_OnPlayerDisconnect
#if defined prom_OnPlayerDisconnect
    forward prom_OnPlayerDisconnect(playerid, reason);
#endif

stock GetPlayerIDFromAccountID(accountId)
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && GetPlayerAccountID(i) == accountId)
        {
            return i;
        }
    }
    return INVALID_PLAYER_ID;
}

stock SetPlayerPromoTimer(playerid, playerPromoSQLID, durationHours)
{
    if(g_iPlayerPromoTimersCount[playerid] >= MAX_CONCURRENT_PLAYER_PROMO_PRIZES)
    {
        printf("[WERTON_PROMO] Игрок %s (ID: %d) достиг лимита активных временных призов (%d). Таймер для приза %d не установлен.",
            GetPlayerNameEx(playerid), GetPlayerAccountID(playerid), MAX_CONCURRENT_PLAYER_PROMO_PRIZES, playerPromoSQLID);
        return 0;
    }

    new index = g_iPlayerPromoTimersCount[playerid];
    PlayerPromoTimers[playerid][index][pPlayerPromoSQLID] = playerPromoSQLID;
    PlayerPromoTimers[playerid][index][pPromoTimerID] = SetTimerEx("OnPromoTimerTick", 60000, true, "i", playerPromoSQLID);
    g_iPlayerPromoTimersCount[playerid]++;

    printf("[WERTON_PROMO] Игроку %s (ID: %d) установлен таймер для приза из player_promos.id: %d на %d часов.",
        GetPlayerNameEx(playerid), GetPlayerAccountID(playerid), playerPromoSQLID, durationHours);
    return 1;
}

stock StopPlayerPromoTimer(playerid)
{
    new query[256];
    new Cache:result;
    new accountId = GetPlayerAccountID(playerid);

    for(new i = 0; i < g_iPlayerPromoTimersCount[playerid]; i++)
    {
        new playerPromoSQLID = PlayerPromoTimers[playerid][i][pPlayerPromoSQLID];
        new timerId = PlayerPromoTimers[playerid][i][pPromoTimerID];

        KillTimer(timerId);

        mysql_format(mysql, query, sizeof(query), "SELECT start_time, remaining_time FROM player_promos WHERE id = %d", playerPromoSQLID);
        result = mysql_query(mysql, query, true);

        if(mysql_errno() == 0 && cache_num_rows(result) > 0)
        {
            new startTime = cache_get_field_content_int(0, "start_time");
            new remainingTimeFromDB = cache_get_field_content_int(0, "remaining_time");

            new prizeDurationHours = 0;
            new Cache:prizeResult;
            new query2[128];
            mysql_format(mysql, query2, sizeof(query2), "SELECT ppz.prize_duration FROM player_promos pp JOIN promo_prizes ppz ON pp.promo_prize_sql_id = ppz.id WHERE pp.id = %d", playerPromoSQLID);
            prizeResult = mysql_query(mysql, query2, true);
            if(mysql_errno() == 0 && cache_num_rows(prizeResult) > 0)
            {
                prizeDurationHours = cache_get_field_content_int(0, "prize_duration");
            }
            cache_delete(prizeResult);

            new calculatedRemainingTime = prizeDurationHours * 3600 - (gettime() - startTime);
            if(calculatedRemainingTime < 0) calculatedRemainingTime = 0;

            new finalRemainingTime = min(remainingTimeFromDB, calculatedRemainingTime);
            if(finalRemainingTime < 0) finalRemainingTime = 0;

            mysql_format(mysql, query, sizeof(query),
                "UPDATE player_promos SET remaining_time = %d WHERE id = %d",
                finalRemainingTime, playerPromoSQLID);
            mysql_query(mysql, query, false);
            printf("[WERTON_PROMO] Таймер для приза (player_promos.id: %d) игрока %s (ID: %d) остановлен и время сохранено. Осталось: %d секунд.",
                playerPromoSQLID, GetPlayerNameEx(playerid), accountId, finalRemainingTime);
        }
        cache_delete(result);
    }
    g_iPlayerPromoTimersCount[playerid] = 0;
}

stock RevokePromoPrize(accountId, prizeType, prizeValue, promoIdForCarRevoke)
{
    new playerid = GetPlayerIDFromAccountID(accountId);
    if(playerid == INVALID_PLAYER_ID) return 0;

    new query[256];
    new Cache:result;

    switch(prizeType)
    {
        case PRIZE_TYPE_MONEY:
        {
            new playerMoney = GetPlayerData(playerid, P_MONEY);
            new newMoney = playerMoney - prizeValue;

            if(newMoney < 0)
            {
                SetPlayerData(playerid, P_MONEY, 0);
                UpdatePlayerDatabaseInt(playerid, "money", 0);
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}У вас было отозвано {ff2400}%d${ffffff} за истечение срока действия приза. Ваш баланс установлен на 0$.", prizeValue);
            }
            else
            {
                GivePlayerMoneyEx(playerid, -prizeValue);
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}У вас было отозвано {ff2400}%d${ffffff} за истечение срока действия приза.", prizeValue);
            }
        }
        case PRIZE_TYPE_DONATE:
        {
            new playerDonate = GetPlayerData(playerid, P_DONATE_RUB);
            new newDonate = playerDonate - prizeValue;

            if(newDonate < 0)
            {
                GivePlayerDonateRub(playerid, -GetPlayerData(playerid, P_DONATE_RUB));
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}У вас было отозвано {ff2400}%d доната{ffffff} за истечение срока действия приза. Ваш баланс доната установлен на 0.", prizeValue);
            }
            else
            {
                GivePlayerDonateRub(playerid, -prizeValue);
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}У вас было отозвано {ff2400}%d доната{ffffff} за истечение срока действия приза.", prizeValue);
            }
        }
        case PRIZE_TYPE_CAR:
        {
            mysql_format(mysql, query, sizeof(query),
                "SELECT id, vehicle_id FROM ownable_cars WHERE owner_id = %d AND promo_status_car = 1 AND promo_id = %d AND model_id = %d",
                accountId, promoIdForCarRevoke, prizeValue);
            result = mysql_query(mysql, query, true);

            new rows = cache_num_rows();
            if(rows > 0)
            {
                new carSqlId = cache_get_field_content_int(0, "id");
                new vehicleIdInGame = cache_get_field_content_int(0, "vehicle_id");

                mysql_format(mysql, query, sizeof(query), "DELETE FROM ownable_cars WHERE id = %d", carSqlId);
                mysql_query(mysql, query, false);

                if(IsValidVehicle(vehicleIdInGame))
                {
                    DestroyVehicle(vehicleIdInGame);
                }
                else
                {
                    #if defined MAX_OWNABLE_CARS && defined g_ownable_car && defined OC_SQL_ID && defined OC_VEHICLE_ID
                    for(new j = 0; j < MAX_OWNABLE_CARS; j++)
                    {
                        if(g_ownable_car[j][OC_SQL_ID] == carSqlId && IsValidVehicle(g_ownable_car[j][OC_VEHICLE_ID]))
                        {
                            DestroyVehicle(g_ownable_car[j][OC_VEHICLE_ID]);
                            break;
                        }
                    }
                    #endif
                }
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ваш автомобиль, полученный по промокоду, был отозван.");
                printf("[WERTON_PROMO] Автомобиль (SQL ID: %d, Model: %d) отозван у игрока %s (ID: %d) из-за истечения срока действия приза.",
                    carSqlId, prizeValue, GetPlayerNameEx(playerid), accountId);
            }
            cache_delete(result);
        }
        case PRIZE_TYPE_EXP:
        {
            return 1; // ну нахуя EXP отнимать
        }
    }
    printf("[WERTON_PROMO] Приз типа %d (value %d) отозван у игрока %s (ID: %d).", prizeType, prizeValue, GetPlayerNameEx(playerid), accountId);
    return 1;
}

stock GetPromoCodeDataByID(promoId, promoData[E_PROMO_DATA])
{
    for(new i = 0; i < g_iLoadedPromoCodes; i++)
    {
        if(PromoCodes[i][PromoID] == promoId)
        {
            promoData[PromoID] = PromoCodes[i][PromoID];
            strmid(promoData[PromoCode], PromoCodes[i][PromoCode], 0, MAX_PROMO_CODE_LENGTH);
            promoData[PromoUses] = PromoCodes[i][PromoUses];
            promoData[UsesLeft] = PromoCodes[i][UsesLeft];
            promoData[NumPrizes] = PromoCodes[i][NumPrizes];
            return 1;
        }
    }
    return 0;
}

stock GetPromoCodeDataByString(const promoCode[], promoData[E_PROMO_DATA])
{
    for(new i = 0; i < g_iLoadedPromoCodes; i++)
    {
        if(strcmp(PromoCodes[i][PromoCode], promoCode, true) == 0)
        {
            promoData[PromoID] = PromoCodes[i][PromoID];
            strmid(promoData[PromoCode], PromoCodes[i][PromoCode], 0, MAX_PROMO_CODE_LENGTH);
            promoData[PromoUses] = PromoCodes[i][PromoUses];
            promoData[UsesLeft] = PromoCodes[i][UsesLeft];
            promoData[NumPrizes] = PromoCodes[i][NumPrizes];
            return 1;
        }
    }
    return 0;
}

stock GetPromoCodeIndexByString(const promoCode[])
{
    for(new i = 0; i < g_iLoadedPromoCodes; i++)
    {
        if(strcmp(PromoCodes[i][PromoCode], promoCode, true) == 0)
        {
            return i;
        }
    }
    return -1;
}

stock GivePromoCar(playerid, modelid, promoSqlId)
{
    new color_1 = 0, color_2 = 0;
    new Float:POS[3];
    GetPlayerPos(playerid, POS[0],POS[1],POS[2]);
    new Float: pos_x = POS[0];
    new Float: pos_y = POS[1];
    new Float: pos_z = POS[2];
    new Float: angle = 356.7986;
    new query[256], Cache: result, idx;
    /*idx = GetFreeOwnableCarID();

    SetOwnableCarData(idx, OC_OWNER_ID,  GetPlayerAccountID(playerid));
    SetOwnableCarData(idx, OC_MODEL_ID,  modelid);
    SetOwnableCarData(idx, OC_COLOR_1,   color_1);
    SetOwnableCarData(idx, OC_COLOR_2,   color_2);
    SetOwnableCarData(idx, OC_POS_X,     pos_x);
    SetOwnableCarData(idx, OC_POS_Y,     pos_y);
    SetOwnableCarData(idx, OC_POS_Z,     pos_z);
    SetOwnableCarData(idx, OC_ANGLE,     angle);
    strmid(g_ownable_car[idx][OC_NUMBER], "------", 0, 8, 8);
    SetOwnableCarData(idx, OC_ALARM,     false);
    SetOwnableCarData(idx, OC_KEY_IN,    false);
    SetOwnableCarData(idx, OC_CREATE,    gettime());
    format(g_ownable_car[idx][OC_OWNER_NAME], 21, GetPlayerNameEx(playerid));

    SetOwnableCarData(idx, OC_PROMO_STATUS_CAR, 1);
    SetOwnableCarData(idx, OC_PROMO_ID, promoSqlId);

    new vehicleid = CreateVehicle ( GetOwnableCarData(idx, OC_MODEL_ID), GetOwnableCarData(idx, OC_POS_X), GetOwnableCarData(idx, OC_POS_Y), GetOwnableCarData(idx, OC_POS_Z), GetOwnableCarData(idx, OC_ANGLE), GetOwnableCarData(idx, OC_COLOR_1), GetOwnableCarData(idx, OC_COLOR_2), -1, 0, VEHICLE_ACTION_TYPE_OWNABLE_CAR, idx ); // Assuming VEHICLE_ACTION_TYPE_OWNABLE_CAR exists

    if(vehicleid != INVALID_VEHICLE_ID)
    {
        format(g_ownable_car[idx][OC_NUMBER], 12, g_ownable_car[idx][OC_NUMBER]); 
        SetVehicleRuNumberPlate(vehicleid, g_ownable_car[idx][OC_NUMBER], "17");
        SetVehicleParam(vehicleid, V_LOCK, false); 
        SetVehicleData(vehicleid, V_MILEAGE, 0.0);
        PutPlayerInVehicle(playerid, vehicleid, 0);
    }
    SetPlayerData(playerid, P_OWNABLE_CAR, vehicleid);*/

    format ( query, sizeof query, "INSERT INTO ownable_cars \
    (owner_id,model_id,color_1,color_2,pos_x,pos_y,pos_z,angle,create_time,promo_status_car,promo_id) \
    VALUES \
    ('%d','%d','%d','%d','%f','%f','%f','%f','%d','%d','%d')",
    GetPlayerAccountID(playerid), modelid, color_1, color_2, pos_x, pos_y, pos_z, angle, gettime(), 1, promoSqlId );

    result = mysql_query(mysql, query, true);
    //SetOwnableCarData(idx, OC_SQL_ID, cache_insert_id(result));
    cache_delete(result);
    return 1;
}

stock ShowPromoCreationConfirmation(playerid)
{
    new szMessage[1024];
    new szTemp[256];
    new promoCode[MAX_PROMO_CODE_LENGTH];
    strmid(promoCode, PlayerPromoCreationData[playerid][NewPromoCodeString], 0, MAX_PROMO_CODE_LENGTH);
    new prizeCount = PlayerPromoCreationData[playerid][NewPromoPrizeCount];
    new usesLimit = PlayerPromoCreationData[playerid][NewPromoUsesLimit];

    format(szMessage, sizeof(szMessage), "{FF6347}"SERVER_NAME" {FFFFFF}| Подтверждение создания промокода:\n\n");
    format(szTemp, sizeof(szTemp), "{ffffff}Промокод: {ffff00}%s\n", promoCode);
    strcat(szMessage, szTemp);

    new szUsesLimitText[32];
    if(usesLimit == 0) {
        format(szUsesLimitText, sizeof(szUsesLimitText), "Безлимитно");
    } else {
        format(szUsesLimitText, sizeof(szUsesLimitText), "%d", usesLimit);
    }
    format(szTemp, sizeof(szTemp), "{ffffff}Лимит использований: {ffff00}%s\n\n", szUsesLimitText);

    strcat(szMessage, szTemp);

    strcat(szMessage, "{ffffff}Настроенные призы:\n");
    for(new i = 0; i < prizeCount; i++)
    {
        new prizeType = PlayerTempPrizes[playerid][i][TempPrizeType];
        new prizeValue = PlayerTempPrizes[playerid][i][TempPrizeValue];
        new prizeDuration = PlayerTempPrizes[playerid][i][TempPrizeDuration];

        new szPrizeDetails[128];
        new szDurationText[64];

        if(prizeDuration == 0)
        {
            format(szDurationText, sizeof(szDurationText), "навсегда");
        }
        else
        {
            format(szDurationText, sizeof(szDurationText), "на %d ч.", prizeDuration);
        }

        switch (prizeType)
        {
            case PRIZE_TYPE_MONEY:
            {
                format(szPrizeDetails, sizeof(szPrizeDetails), "{ffffff}%d. Деньги: {ffff00}%d руб. {888888}(%s)\n", i + 1, prizeValue, szDurationText);
            }
            case PRIZE_TYPE_DONATE:
            {
                format(szPrizeDetails, sizeof(szPrizeDetails), "{ffffff}%d. Донат: {ffff00}%d доната {888888}(%s)\n", i + 1, prizeValue, szDurationText);
            }
            case PRIZE_TYPE_CAR:
            {   
                format(szPrizeDetails, sizeof(szPrizeDetails), "{ffffff}%d. Автомобиль: {ffff00}%s (модель ID: %d) {888888}(%s)\n", i + 1, GetVehicleInfo(prizeValue - 400, VI_NAME), prizeValue, szDurationText);
            }
        }
        strcat(szMessage, szPrizeDetails);
    }

    ShowPlayerDialog(playerid, DIALOG_CONFIRM_PROMO_CREATION, DIALOG_STYLE_MSGBOX,
        "{FF6347}"SERVER_NAME" {FFFFFF}| Подтверждение создания промокода", szMessage, "Создать", "Отмена"
    );
}

stock CreatePromoCodeInDatabase(playerid)
{
    new query[1024];
    new promoCode[MAX_PROMO_CODE_LENGTH];
    strmid(promoCode, PlayerPromoCreationData[playerid][NewPromoCodeString], 0, MAX_PROMO_CODE_LENGTH);
    new prizeCount = PlayerPromoCreationData[playerid][NewPromoPrizeCount];
    new usesLimit = PlayerPromoCreationData[playerid][NewPromoUsesLimit];
    new promoId;
    new Cache:result;
    new szMsg[256];

    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `promocodes` (`code`, `uses_limit`, `uses_left`, `num_prizes`) VALUES ('%e', %d, %d, %d)",
        promoCode, usesLimit, usesLimit, prizeCount);

    result = mysql_query(mysql, query, true);
    if(mysql_errno() != 0)
    {
        format(szMsg, sizeof(szMsg), "{ff2400}| {ffffff}Ошибка при создании промокода (основная запись): %d", mysql_errno());
        SendClientMessage(playerid, -1, szMsg);
        printf("[WERTON_PROMO] Ошибка создания промокода (promocodes table): %d", mysql_errno());
        cache_delete(result);
        return 0;
    }
    promoId = cache_insert_id(result);
    cache_delete(result);

    if(promoId == 0)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ошибка: Не удалось получить ID нового промокода.");
        printf("[WERTON_PROMO] Ошибка: cache_insert_id вернул 0 для промокода '%s'.", promoCode);
        return 0;
    }

    for(new i = 0; i < prizeCount; i++)
    {
        new prizeType = PlayerTempPrizes[playerid][i][TempPrizeType];
        new prizeValue = PlayerTempPrizes[playerid][i][TempPrizeValue];
        new prizeDuration = PlayerTempPrizes[playerid][i][TempPrizeDuration];

        mysql_format(mysql, query, sizeof(query),
            "INSERT INTO `promo_prizes` (`promo_id`, `prize_index`, `prize_type`, `prize_value`, `prize_duration`) VALUES (%d, %d, %d, %d, %d)",
            promoId, i, prizeType, prizeValue, prizeDuration);

        mysql_query(mysql, query, false);
        if(mysql_errno() != 0)
        {
            format(szMsg, sizeof(szMsg), "{ff2400}| {ffffff}Ошибка при добавлении приза %d для промокода: %d", i + 1, mysql_errno());
            SendClientMessage(playerid, -1, szMsg);
            printf("[WERTON_PROMO] Ошибка добавления приза (promo_prizes table) для промокода ID %d, приз %d: %d", promoId, i, mysql_errno());
        }
    }
    
    format(szMsg, sizeof(szMsg), "{00FF00}| {ffffff}Промокод '%s' успешно создан с %d призами!", promoCode, prizeCount);
    SendClientMessage(playerid, -1, szMsg);
    LoadPromoCodesFromDatabase();

    PlayerPromoCreationData[playerid][NewPromoPrizeCount] = 0;
    PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex] = 0;
    PlayerPromoCreationData[playerid][NewPromoUsesLimit] = 0;

    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_PROMO_MANAGEMENT:
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0:
                    {
                        callcmd::mypromo(playerid, "");
                    }
                    /*case 1:
                    {
                        new level_text[500];
                        new current_level = GetPromoLevelForOwner(playerid);
                        new level_status[11][32];

                        for(new i = 0; i < 11; i++)
                        {
                            if(i <= current_level - 1)
                            {
                                format(level_status[i], sizeof(level_status[]), "{66CC33}открыт");
                            }
                            else
                            {
                                format(level_status[i], sizeof(level_status[]), "{FF6347}закрыт");
                            }
                        }


                        format(level_text, sizeof(level_text), "{EB4C42} #1.\t\t\t\t{FFFFFF}Первый уровень %s\n"\
                        "{EB4C42} #2.\t\t\t\t{FFFFFF}Вторрой уровень %s\n"\
                        "{EB4C42} #3.\t\t\t\t{FFFFFF}Третий уровень %s\n"\
                        "{EB4C42} #4.\t\t\t\t{FFFFFF}Четвертый уровень %s\n"\
                        "{EB4C42} #5.\t\t\t\t{FFFFFF}Пятый уровень %s\n"\
                        "{EB4C42} #6.\t\t\t\t{FFFFFF}Шестой уровень %s\n"\
                        "{EB4C42} #7.\t\t\t\t{FFFFFF}Седьмой уровень %s\n"\
                        "{EB4C42} #8.\t\t\t\t{FFFFFF}Восьмой уровень %s\n"\
                        "{EB4C42} #9.\t\t\t\t{FFFFFF}Девятый уровень %s\n"\
                        "{EB4C42} #10.\t\t\t\t{FFFFFF}Десятый уровень %s",
                        level_status[0], level_status[1], level_status[2], level_status[3], level_status[4], level_status[5], level_status[6], level_status[7], level_status[8], level_status[9]);

                        ShowPlayerDialog(playerid, DIALOG_PROMO_UPGRADE_LEVELS, DIALOG_STYLE_LIST, "{FF0000} Уровни", level_text, "Повысить", "Назад");
                    }*/
                    case 1:
                    {
                        new level_text[1024];
                        new current_level = GetPromoLevelForOwner(playerid);
                        new level_status[32];
                        new level_name[10][32] = {
                            "Первый уровень", "Второй уровень", "Третий уровень", "Четвертый уровень", "Пятый уровень",
                            "Шестой уровень", "Седьмой уровень", "Восьмой уровень", "Девятый уровень", "Десятый уровень"
                        };

                        level_text[0] = EOS; 

                        for(new i = 0; i < 10; i++)
                        {
                            if(i <= current_level - 1)
                            {
                                format(level_status, sizeof(level_status), "{66CC33}открыт");
                            }
                            else
                            {
                                format(level_status, sizeof(level_status), "{FF6347}закрыт");
                            }
                            format(level_text, sizeof(level_text), "%s{EB4C42} #%d.\t\t\t\t{FFFFFF}%s %s\n", level_text, i + 1, level_name[i], level_status);
                        }
    
                        if(strlen(level_text) > 0)
                        {
                            level_text[strlen(level_text) - 1] = EOS;
                        }
    
                        ShowPlayerDialog(playerid, DIALOG_PROMO_UPGRADE_LEVELS, DIALOG_STYLE_LIST, "{FF0000} Уровни", level_text, "Повысить", "Назад");
                    }
                    case 2:
                    {
                        ShowPlayerDialog(playerid, DIALOG_PROMO_INFO, DIALOG_STYLE_MSGBOX,
                            "{FF0000} Промокод",
                            "{ffff00}Промо-код{ffffff} - уникальный набор символов, позволяющий пользователям использовать его при регистрации и получать бонусы\nПромо-код разделен на 10 уровней, на каждом из которых Вы будете получать {ffff00}увеличенный бонус {ffffff}за регистрацию игрока,\nа также {ffff00}увеличенный проц. доната{ffffff}, за донат игрока. Повысить свой уровень можно за активацию промо-кода или за донат в управлении промокодом.\nДля получения наград используйте {FF6347}/checkpromo{FFFFFF} и {FF6347}/mypromo {FFFFFF} для управления промокодом",
                            "Назад", ""
                        );
                    }
                    case 3:
                    {
                        callcmd::mypromo(playerid, "");
                    }
                }
            }
        }
        case DIALOG_PROMO_UPGRADE_LEVELS:
        {
            if(response)
            {
                new target_level = listitem + 1;
                new current_level = GetPromoLevelForOwner(playerid);
                new promo_activations, promo_donat_balance, promo_sql_id;
                new query[256];
        
                mysql_format(mysql, query, sizeof(query), "SELECT `id`, `activations`, `promo_balance` FROM `promocodes` WHERE `creator_account_id` = %d LIMIT 1", GetPlayerAccountID(playerid));
                new Cache:result = mysql_query(mysql, query);
                if(cache_num_rows(result) == 0)
                {
                    SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Промокод не найден.");
                    cache_delete(result);
                    return 1;
                }
                promo_sql_id = cache_get_field_content_int(0, "id");
                promo_activations = cache_get_field_content_int(0, "activations");
                promo_donat_balance = cache_get_field_content_int(0, "promo_balance");
                cache_delete(result);
        
                if(target_level > current_level + 1)
                {
                    SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Вы не можете пропустить уровни. Повышайте по порядку.");
                    callcmd::mypromo(playerid, "");
                    return 1;
                }

                if(target_level > 10)
                {
                    SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Вы уже достигли максимального уровня.");
                    callcmd::mypromo(playerid, "");
                    return 1;
                }

                new needed_activations = PROMO_LEVEL_DATA[target_level][1];
                new needed_donat = PROMO_LEVEL_DATA[target_level][3]; 
                new promo_money_bonus = PROMO_LEVEL_DATA[target_level][4];
                new dialog_text[512];

                if(promo_activations >= needed_activations)
                {
                    format(dialog_text, sizeof(dialog_text), "Вы действительно желаете повысить уровень промокода за {ffff00}%d {ffffff}активаций?\nПри повышении Вы получите новые условия: {ffff00}%d{ffffff} проц. от доната игрока, {ffff00}%d{ffffff} рублей\nЗа приглашенного игрока в виде бонуса", needed_activations, (target_level == 1 ? 0 : PROMO_LEVEL_DATA[target_level][2]), promo_money_bonus);
                }
                else if(promo_donat_balance >= needed_donat)
                {
                    format(dialog_text, sizeof(dialog_text), "Вы действительно желаете повысить уровень промокода за {ffff00}%d {ffffff}доната?\nПри повышении Вы получите новые условия: {ffff00}%d{ffffff} проц. от доната игрока, {ffff00}%d{ffffff} рублей\nЗа приглашенного игрока в виде бонуса", needed_donat, (target_level == 1 ? 0 : PROMO_LEVEL_DATA[target_level][2]), promo_money_bonus);
                }
                else
                {
                    SendClientMessage(playerid, -1, "{ff2400}| {ffffff}У Вас не хватает активаций или доната для повышения уровня.");
                    callcmd::mypromo(playerid, "");
                    return 1;
                }

                ShowPlayerDialog(playerid, DIALOG_PROMO_UPGRADE_CONFIRM, DIALOG_STYLE_MSGBOX, "{FF0000} Повышение уровня промокода", dialog_text, "Далее", "Назад");
                PlayerDialogPromoData[playerid] = target_level;
            }
            else
            {
                callcmd::mypromo(playerid, "");
            }
        }
        case DIALOG_PROMO_UPGRADE_CONFIRM:
        {
            if(response)
            {
                new target_level = PlayerDialogPromoData[playerid];
                new promo_activations, promo_donat_balance, promo_sql_id;
                new query[256];
        
                mysql_format(mysql, query, sizeof(query), "SELECT `id`, `activations`, `promo_balance` FROM `promocodes` WHERE `creator_account_id` = %d LIMIT 1", GetPlayerAccountID(playerid));
                new Cache:result = mysql_query(mysql, query);
                if(cache_num_rows(result) == 0)
                {
                     SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Промокод не найден.");
                     cache_delete(result);
                     return 1;
                }
                promo_sql_id = cache_get_field_content_int(0, "id");
                promo_activations = cache_get_field_content_int(0, "activations");
                promo_donat_balance = cache_get_field_content_int(0, "promo_balance");
                cache_delete(result);

                new needed_activations = PROMO_LEVEL_DATA[target_level][1];
                new needed_donat = PROMO_LEVEL_DATA[target_level][3]; 
        
                if(promo_activations >= needed_activations)
                {
                    mysql_format(mysql, query, sizeof(query), "UPDATE `promocodes` SET `promo_level` = %d WHERE `id` = %d", target_level, promo_sql_id);
                    mysql_query(mysql, query, false);
                    SavePromoLevelPrizes(playerid, promo_sql_id, target_level);
                    SendClientMessage(playerid, -1, "{66CC33}| {FFFFFF}Вы успешно повысили уровень промокода за активации!");
                }
                else if(promo_donat_balance >= needed_donat)
                {
                    mysql_format(mysql, query, sizeof(query), "UPDATE `promocodes` SET `promo_level` = %d, `promo_balance` = `promo_balance` - %d WHERE `id` = %d", target_level, needed_donat, promo_sql_id);
                    mysql_query(mysql, query, false);
                    SavePromoLevelPrizes(playerid, promo_sql_id, target_level);
                    SendClientMessage(playerid, -1, "{66CC33}| {FFFFFF}Вы успешно повысили уровень промокода за донат!");
                }
                else
                {
                    SendClientMessage(playerid, -1, "{ff2400}| {ffffff}У Вас не хватает активаций или доната для повышения уровня.");
                }
                callcmd::mypromo(playerid, "");
            }
            else
            {
                callcmd::mypromo(playerid, "");
            }
        }
        case DIALOG_PROMO_INFO:
        {
            if(response)
            {
                callcmd::mypromo(playerid, "");
            }
        }
        case DIALOG_ACT_PROMO:
        {
            if(!response)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Вы вышли из меню промокодов.");
                return 1;
            }

            switch (listitem)
            {
                case 0:
                {
                    callcmd::bcode(playerid, "");
                }
                case 1:
                {
                    SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Вы не вводили ютуберский промо.");
                    callcmd::promo(playerid, "");
                }
                case 2:
                    {
                        if(HasPlayerCreatedPromo(playerid))
                        {
                            callcmd::mypromo(playerid, "");
                        }
                        else
                        {
                            ShowPlayerDialog
                            (
                                playerid, DIALOG_ADDPROMO_CODE_BY_PLAYER, DIALOG_STYLE_INPUT,
                                "{ff0000}Создание промокода",
                                "{ffff00}Промокод {FFFFFF}- уникальный набор симлов, позволяющий Вам и человеку, использующему Ваш промокод получить вознограждение\n"\
                                "Вы можете самостоятельно создать {ffff00}свой промокод{FFFFFF}, при условии что он свободен.\n\n"\
                                "\n"\
                                "Однако стоит помнить что количество символов а промокоде определяют его {ffff00}стоимость\n"\
                                "{ffff00}От 3 символов - {FFFFFF}10.000.000 рублей или 2.000 ВС\n"\
                                "{ffff00}От 5 символов до 7 символов - {FFFFFF}5.000.000 рублей.\n"\
                                "{ffff00}От 7 символов - {FFFFFF}3.000.000 рублей.\n"\
                                "Вы можете использовать {ffff00}латиницу и кирилицу, # и цифры.\n\n"\
                                "{FF6347}Примечание! {FFFFFF}Первый символ промокода должен быть - {FF6347}@\n\n"\
                                "\n"\
                                "{FFFFFF}Для создания промокода введите в поле ниже желаемый набор симлов.\n",
                                "Далее", "Отмена"
                            );
                        }
                    }
                case 3:
                {
                    new query[256];
                    new Cache:result;
                    new dialog_string[1024];
                    new accountId = GetPlayerAccountID(playerid);
                    new total_promos = 0;

                    mysql_format(mysql, query, sizeof(query),
                        "SELECT pr.code FROM player_promos pp JOIN promo_prizes ppz ON pp.promo_prize_sql_id = ppz.id JOIN promocodes pr ON ppz.promo_id = pr.id WHERE pp.account_id = %d",
                        accountId
                    );
                    result = mysql_query(mysql, query, true);

                    if(cache_num_rows(result) > 0)
                    {
                        total_promos = cache_num_rows(result);
                        format(dialog_string, sizeof(dialog_string), "{ffffff} #%s\t\t\t\tПриз забран", cache_get_field_content(0, "code"));
                        for(new i = 1; i < total_promos; i++)
                        {
                            new temp_code[MAX_PROMO_CODE_LENGTH];
                            cache_get_field_content(i, "code", temp_code, sizeof(temp_code));
                            format(dialog_string, sizeof(dialog_string), "%s\n{ffffff} #%s\t\t\t\tПриз забран", dialog_string, temp_code);
                        }
                    }
                    else
                    {
                        format(dialog_string, sizeof(dialog_string), "{ffffff}У вас пока нет использованных промокодов.");
                    }
                    cache_delete(result);

                    new title[128];
                    format(title, sizeof(title), "{FF0000} Количество промокодов: %d", total_promos);
                    ShowPlayerDialog(playerid, DIALOG_ACT_PROMO_PRIZES, DIALOG_STYLE_LIST, title, dialog_string, "Ок", "");
                }
            }
        }
        case DIALOG_ADDPROMO_CODE_BY_PLAYER:
        {
            if(!response)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Создание промокода отменено.");
                return 1;
            }

            if(strlen(inputtext) == 0)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Вы не ввели промокод. Пожалуйста, попробуйте снова.");

                ShowPlayerDialog
                (
                    playerid, DIALOG_ADDPROMO_CODE_BY_PLAYER, DIALOG_STYLE_INPUT,
                    "{ff0000}Создание промокода",
                    "{ffff00}Промокод {FFFFFF}- уникальный набор симлов, позволяющий Вам и человеку, использующему Ваш промокод получить вознограждение\n"\
                    "Вы можете самостоятельно создать {ffff00}свой промокод{FFFFFF}, при условии что он свободен.\n\n"\
                    "\n"\
                    "Однако стоит помнить что количество символов а промокоде определяют его {ffff00}стоимость\n"\
                    "{ffff00}От 3 символов - {FFFFFF}10.000.000 рублей или 2.000 ВС\n"\
                    "{ffff00}От 5 символов до 7 символов - {FFFFFF}5.000.000 рублей.\n"\
                    "{ffff00}От 7 символов - {FFFFFF}3.000.000 рублей.\n"\
                    "Вы можете использовать {ffff00}латиницу и кирилицу, # и цифры.\n\n"\
                    "{FF6347}Примечание! {FFFFFF}Первый символ промокода должен быть - {FF6347}@\n\n"\
                    "\n"\
                    "{FFFFFF}Для создания промокода введите в поле ниже желаемый набор симлов.\n",
                    "Далее", "Отмена"
                );
                return 1;
            }

            new len = strlen(inputtext);
            if(inputtext[0] != '@')
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ошибка: Промокод должен начинаться с символа '@'.");
                callcmd::promo(playerid, "");
                return 1;
            }

            if(len < 3)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ошибка: Промокод должен содержать минимум 3 символа.");
                callcmd::promo(playerid, "");
                return 1;
            }

            // Проверка на допустимые символы (латиница, кириллица, # и цифры)
            for(new i = 1; i < len; i++) // Начинаем с 1, так как первый символ уже проверен ('@')
            {
                new current_char = inputtext[i]; // Исправлено: изменено 'char' на 'current_char'
                // Проверка на латиницу (строчные и заглавные)
                if(!((current_char >= 'a' && current_char <= 'z') || (current_char >= 'A' && current_char <= 'Z') ||
                // Проверка на кириллицу (упрощенно, для полного соответствия Unicode нужны расширенные проверки)
                      (current_char >= 0x410 && current_char <= 0x44F) || (current_char >= 0x400 && current_char <= 0x40F) ||
                // Проверка на цифры
                      (current_char >= '0' && current_char <= '9') ||
                // Проверка на хуету #
                      (current_char == '#')))
                {
                    SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ошибка: Промокод содержит недопустимые символы. Разрешены латиница, кириллица, цифры и '#'.");
                    callcmd::promo(playerid, "");
                    return 1;
                }
            }
            OnPromoCodeCheckComplete(playerid, inputtext);
            return 1;
        }
        case DIALOG_ADDPROMO_CODE:
        {
            if(!response)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Создание промокода отменено.");
                return 1;
            }
            if(strlen(inputtext) == 0)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Название промокода не может быть пустым.");
                callcmd::addcpromo(playerid, "");
                return 1;
            }
            if(strfind(inputtext, " ", true) != -1)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Название промокода не должно содержать пробелов.");
                callcmd::addcpromo(playerid, "");
                return 1;
            }
            if(strlen(inputtext) > MAX_PROMO_CODE_LENGTH)
            {
                new szMsg[128];
                format(szMsg, sizeof(szMsg), "{ff2400}| {ffffff}Название промокода слишком длинное (макс. %d символов).", MAX_PROMO_CODE_LENGTH);
                SendClientMessage(playerid, -1, szMsg);
                callcmd::addcpromo(playerid, "");
                return 1;
            }

            if(GetPromoCodeIndexByString(inputtext) != -1)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Промокод с таким названием уже существует.");
                callcmd::addcpromo(playerid, "");
                return 1;
            }

            strmid(PlayerPromoCreationData[playerid][NewPromoCodeString], inputtext, 0, MAX_PROMO_CODE_LENGTH);
            PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex] = 0;

            ShowPlayerDialog(playerid, DIALOG_ADDPROMO_PRIZE_COUNT, DIALOG_STYLE_INPUT, "{FF6347}"SERVER_NAME" {FFFFFF}| Создание промокода", "Введите количество призов (1-5):", "Далее", "Отмена");
            return 1;
        }
        case DIALOG_ADDPROMO_PRIZE_COUNT:
        {
            if(!response)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Создание промокода отменено.");
                return 1;
            }
            new prizeCount = strval(inputtext);
            if(prizeCount < 1 || prizeCount > 5)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Количество призов должно быть от 1 до 5.");
                ShowPlayerDialog(playerid, DIALOG_ADDPROMO_PRIZE_COUNT, DIALOG_STYLE_INPUT, "{FF6347}"SERVER_NAME" {FFFFFF}| Создание промокода", "Введите количество призов (1-5):", "Далее", "Отмена");
                return 1;
            }
            PlayerPromoCreationData[playerid][NewPromoPrizeCount] = prizeCount;

            ShowPlayerDialog(playerid, DIALOG_ADDPROMO_USES_LIMIT, DIALOG_STYLE_INPUT, "{FF6347}"SERVER_NAME" {FFFFFF}| Создание промокода", "Введите лимит использований промокода (0 - безлимитно):", "Далее", "Отмена");
            return 1;
        }

        case DIALOG_ADDPROMO_USES_LIMIT:
        {
            if(!response)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Создание промокода отменено.");
                return 1;
            }
            new usesLimit = strval(inputtext);
            if(usesLimit < 0)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Лимит использований не может быть отрицательным.");
                ShowPlayerDialog(playerid, DIALOG_ADDPROMO_USES_LIMIT, DIALOG_STYLE_INPUT, "{FF6347}"SERVER_NAME" {FFFFFF}| Создание промокода", "Введите лимит использований промокода (0 - безлимитно):", "Далее", "Отмена");
                return 1;
            }
            PlayerPromoCreationData[playerid][NewPromoUsesLimit] = usesLimit;

            new szDialogTitle[128];
            format(szDialogTitle, sizeof(szDialogTitle), "{FF6347}"SERVER_NAME" {FFFFFF}| Настройка приза %d/%d (Тип)",
                PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex] + 1,
                PlayerPromoCreationData[playerid][NewPromoPrizeCount]);

            ShowPlayerDialog(playerid, DIALOG_ADDPROMO_SINGLE_PRIZE_TYPE, DIALOG_STYLE_LIST,
                szDialogTitle, 
                "1. {669900}Деньги\n2. {669900}Донат\n3. {669900}Автомобиль\n4. {669900}EXP",
                "Выбрать", "Отмена"
            );
            return 1;
        }

        case DIALOG_ADDPROMO_SINGLE_PRIZE_TYPE:
        {
            if(!response)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Создание промокода отменено.");
                return 1;
            }
            new currentPrizeIndex = PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex];
            PlayerTempPrizes[playerid][currentPrizeIndex][TempPrizeType] = listitem;

            new szDialogText[256];
            switch (listitem)
            {
                case PRIZE_TYPE_MONEY: format(szDialogText, sizeof(szDialogText), "Введите количество денег:");
                case PRIZE_TYPE_DONATE: format(szDialogText, sizeof(szDialogText), "Введите количество доната:");
                case PRIZE_TYPE_CAR: format(szDialogText, sizeof(szDialogText), "Введите ID модели автомобиля (например, 411 для Cheetah):");
                case PRIZE_TYPE_EXP: format(szDialogText, sizeof(szDialogText), "Введите количество EXP:"); 
            }
    
            new szDialogTitle[128]; 
            format(szDialogTitle, sizeof(szDialogTitle), "{FF6347}"SERVER_NAME" {FFFFFF}| Настройка приза %d/%d",
                currentPrizeIndex + 1,
                PlayerPromoCreationData[playerid][NewPromoPrizeCount]);

            ShowPlayerDialog(playerid, DIALOG_ADDPROMO_SINGLE_PRIZE_VALUE, DIALOG_STYLE_INPUT,
                szDialogTitle,
                szDialogText, "Далее", "Отмена"
            );
            return 1;
        }

        case DIALOG_ADDPROMO_SINGLE_PRIZE_VALUE:
        {
            if(!response)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Создание промокода отменено.");
                return 1;
            }
            new currentPrizeIndex = PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex];
            new prizeValue = strval(inputtext);
            new prizeType = PlayerTempPrizes[playerid][currentPrizeIndex][TempPrizeType];

            new szDialogTitle[128];
            format(szDialogTitle, sizeof(szDialogTitle), "{FF6347}"SERVER_NAME" {FFFFFF}| Настройка приза %d/%d (Тип длительности)",
                currentPrizeIndex + 1,
                PlayerPromoCreationData[playerid][NewPromoPrizeCount]);

            if(prizeValue <= 0)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Значение приза должно быть положительным числом.");
                new szDialogText[256];
                switch (prizeType)
                {
                    case PRIZE_TYPE_MONEY: format(szDialogText, sizeof(szDialogText), "Введите количество денег:");
                    case PRIZE_TYPE_DONATE: format(szDialogText, sizeof(szDialogText), "Введите количество доната:");
                    case PRIZE_TYPE_CAR: format(szDialogText, sizeof(szDialogText), "Введите ID модели автомобиля (например, 411 для Cheetah):");
                    case PRIZE_TYPE_EXP: format(szDialogText, sizeof(szDialogText), "Введите количество EXP:");
                }
                ShowPlayerDialog(playerid, DIALOG_ADDPROMO_SINGLE_PRIZE_VALUE, DIALOG_STYLE_INPUT,
                    szDialogTitle,
                    szDialogText, "Далее", "Отмена"
                );
                return 1;
            }

            PlayerTempPrizes[playerid][currentPrizeIndex][TempPrizeValue] = prizeValue;

            if(prizeType == PRIZE_TYPE_EXP)
            {
                PlayerTempPrizes[playerid][currentPrizeIndex][TempPrizeDuration] = 0;
                PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex]++;
        
                if(PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex] < PlayerPromoCreationData[playerid][NewPromoPrizeCount])
                {
                    format(szDialogTitle, sizeof(szDialogTitle), "{FF6347}"SERVER_NAME" {FFFFFF}| Настройка приза %d/%d (Тип)",
                        PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex] + 1,
                        PlayerPromoCreationData[playerid][NewPromoPrizeCount]);
                    ShowPlayerDialog(playerid, DIALOG_ADDPROMO_SINGLE_PRIZE_TYPE, DIALOG_STYLE_LIST,
                        szDialogTitle,
                        "1. {669900}Деньги\n2. {669900}Донат\n3. {669900}Автомобиль\n4. {669900}EXP",
                        "Выбрать", "Отмена"
                    );
                }
                else
                {
                    ShowPromoCreationConfirmation(playerid);
                }
                return 1;
            }

            ShowPlayerDialog(playerid, DIALOG_ADDPROMO_SINGLE_PRIZE_DURATION, DIALOG_STYLE_LIST,
                szDialogTitle,
                "1. {669900}Временный (указать часы)\n2. {669900}Постоянный (навсегда)",
                "Выбрать", "Отмена"
            );
            return 1;
        }

        case DIALOG_ADDPROMO_SINGLE_PRIZE_DURATION:
        {
            if(!response)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Создание промокода отменено.");
                return 1;
            }
            new currentPrizeIndex = PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex];
            new durationType = listitem; 

            new szDialogTitle[128];

            if(durationType == 0) 
            {
                format(szDialogTitle, sizeof(szDialogTitle), "{FF6347}"SERVER_NAME" {FFFFFF}| Настройка приза %d/%d (Длительность)",
                    currentPrizeIndex + 1,
                    PlayerPromoCreationData[playerid][NewPromoPrizeCount]);
        
                ShowPlayerDialog(playerid, DIALOG_ADDPROMO_SINGLE_PRIZE_DURATION_HOURS, DIALOG_STYLE_INPUT,
                    szDialogTitle,
                    "Введите длительность приза в часах:", "Далее", "Отмена"
                );
                return 1;
            }
            else 
            {
                PlayerTempPrizes[playerid][currentPrizeIndex][TempPrizeDuration] = 0; 

                PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex]++;
                if(PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex] < PlayerPromoCreationData[playerid][NewPromoPrizeCount])
                {
                    format(szDialogTitle, sizeof(szDialogTitle), "{FF6347}"SERVER_NAME" {FFFFFF}| Настройка приза %d/%d (Тип)",
                        PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex] + 1,
                        PlayerPromoCreationData[playerid][NewPromoPrizeCount]);

                    ShowPlayerDialog(playerid, DIALOG_ADDPROMO_SINGLE_PRIZE_TYPE, DIALOG_STYLE_LIST,
                        szDialogTitle,
                        "1. {669900}Деньги\n2. {669900}Донат\n3. {669900}Автомобиль\n4. {669900}EXP",
                        "Выбрать", "Отмена"
                    );
                }
                else
                {
                    ShowPromoCreationConfirmation(playerid);
                }
                return 1;
            }
        }

        case DIALOG_ADDPROMO_SINGLE_PRIZE_DURATION_HOURS:
        {
            if(!response)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Создание промокода отменено.");
                return 1;
            }
            new currentPrizeIndex = PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex];
            new durationHours = strval(inputtext);

            new szDialogTitle[128];

            if(durationHours <= 0)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Длительность в часах должна быть положительным числом.");

                format(szDialogTitle, sizeof(szDialogTitle), "{FF6347}"SERVER_NAME" {FFFFFF}| Настройка приза %d/%d (Длительность)",
                    currentPrizeIndex + 1,
                    PlayerPromoCreationData[playerid][NewPromoPrizeCount]);

                ShowPlayerDialog(playerid, DIALOG_ADDPROMO_SINGLE_PRIZE_DURATION_HOURS, DIALOG_STYLE_INPUT,
                    szDialogTitle,
                    "Введите длительность приза в часах:", "Далее", "Отмена"
                );
                return 1;
            }
            PlayerTempPrizes[playerid][currentPrizeIndex][TempPrizeDuration] = durationHours;

            PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex]++;
            if(PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex] < PlayerPromoCreationData[playerid][NewPromoPrizeCount])
            {
                format(szDialogTitle, sizeof(szDialogTitle), "{FF6347}"SERVER_NAME" {FFFFFF}| Настройка приза %d/%d",
                    PlayerPromoCreationData[playerid][NewPromoCurrentPrizeIndex] + 1,
                    PlayerPromoCreationData[playerid][NewPromoPrizeCount]);

                ShowPlayerDialog(playerid, DIALOG_ADDPROMO_SINGLE_PRIZE_TYPE, DIALOG_STYLE_LIST,
                    szDialogTitle,
                    "1. {669900}Деньги\n2. {669900}Донат\n3. {669900}Автомобиль\n4. {669900}EXP",
                    "Выбрать", "Отмена"
                );
            }
            else
            {
                ShowPromoCreationConfirmation(playerid);
            }
            return 1;
        }

        case DIALOG_CONFIRM_PROMO_CREATION:
        {
            if(response)
            {
                CreatePromoCodeInDatabase(playerid);
            }
            else
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Создание промокода отменено.");
            }
            return 1;
        }

case DIALOG_APPLY_PROMO_CODE:
{
    if(!response)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Вы отменили ввод промокода.");
        return 1;
    }
    if(strlen(inputtext) == 0)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Вы не ввели промокод. Пожалуйста, попробуйте снова.");
        callcmd::bcode(playerid, ""); 
        return 1;
    }
    new promoData[E_PROMO_DATA]; 

    new accountId = GetPlayerAccountID(playerid);
    //new promoSqlId = promoData[PromoID]; перестало работать + сложна Werton
    new query[286];
    new Cache:result;

    mysql_format(mysql, query, sizeof(query), "SELECT * FROM `promocodes` WHERE `code` = '%s' LIMIT 1", inputtext);
    result = mysql_query(mysql, query, true);

    if(mysql_errno() != 0)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ошибка: MySql errno");
        return 1;
    }

    if(cache_num_rows(result) == 0)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ошибка: Промокод не найден.");
        cache_delete(result);
        callcmd::bcode(playerid, "");
    }

    new promoSqlId = cache_get_field_content_int(0, "id");
    new ownerAccountId = cache_get_field_content_int(0, "creator_account_id");
    new level = cache_get_field_content_int(0, "promo_level");
    new activations = cache_get_field_content_int(0, "activations");
    new promo_balance = cache_get_field_content_int(0, "promo_balance");

    cache_delete(result);

    if(level == 0) 
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Данный промокод нельзя использовать, так как он не настроен и его уровень равен 0.");
        return 1;
    }

    if(ownerAccountId == accountId)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Вы не можете использовать свой промокод.");
        callcmd::bcode(playerid, "");
        return 1;
    }

    // result already deleted above.

    if(GetPromoCodeDataByString(inputtext, promoData))
    {
        if(promoData[UsesLeft] > 0 || promoData[PromoUses] == 0) 
        {
            mysql_format(mysql, query, sizeof(query), "SELECT 1 FROM player_promos pp JOIN promo_prizes ppz ON pp.promo_prize_sql_id = ppz.id WHERE pp.account_id = %d AND ppz.promo_id = %d LIMIT 1", accountId, promoSqlId);
            result = mysql_query(mysql, query, true);

            if(cache_num_rows(result) > 0)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Вы уже использовали этот промокод.");
                cache_delete(result);
                return 1;
            }
            cache_delete(result);

            // доп проверка на всякий случай, вертон беспокоится о базе
            mysql_format(mysql, query, sizeof(query), "SELECT 1 FROM `activated_promos` WHERE `account_id` = %d AND `promo_id` = %d LIMIT 1", accountId, promoSqlId);
            result = mysql_query(mysql, query);

            if(cache_num_rows(result) > 0)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Вы уже использовали этот промокод.");
                cache_delete(result);
                return 1;
            }
            cache_delete(result);

            new szActivationMessage[1024];
            format(szActivationMessage, sizeof(szActivationMessage), "{ffffff}Поздравляем!\n\n{ffffff}Вы активировали промокод: {ffff00}%s\n\n", inputtext);
            strcat(szActivationMessage, "{ffffff}Вы получили:\n");

            mysql_format(mysql, query, sizeof(query), "SELECT id, prize_type, prize_value, prize_duration FROM promo_prizes WHERE promo_id = %d ORDER BY prize_index ASC", promoSqlId);
            result = mysql_query(mysql, query, true);

            if(mysql_errno() != 0 || cache_num_rows(result) == 0)
            {
                SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ошибка: Не удалось загрузить призы для этого промокода. Сообщите администрации.");
                printf("[WERTON_PROMO] Ошибка загрузки призов для промокода ID %d: %d", promoSqlId, mysql_errno());
                cache_delete(result);
                return 1;
            }

            new rows = cache_num_rows(result);
            new szDurationText[64];

            new prizeSqlId = 0;
            new prizeType = 0;
            new prizeValue = 0;
            new prizeDuration = 0;

            new prizeSqlId2 = 0;
            new prizeType2 = 0;
            new prizeValue2 = 0;
            new prizeDuration2 = 0;

            new prizeSqlId3 = 0;
            new prizeType3 = 0;
            new prizeValue3 = 0;
            new prizeDuration3 = 0;

            new prizeSqlId4 = 0;
            new prizeType4 = 0;
            new prizeValue4 = 0;
            new prizeDuration4 = 0;

            new prizeSqlId5 = 0;
            new prizeType5 = 0;
            new prizeValue5 = 0;
            new prizeDuration5 = 0;

            if(rows == 1)
            {
                prizeSqlId = cache_get_field_content_int(0, "id");
                prizeType = cache_get_field_content_int(0, "prize_type");
                prizeValue = cache_get_field_content_int(0, "prize_value");
                prizeDuration = cache_get_field_content_int(0, "prize_duration");

                new currentPrizeMsg[256];
                new carName[64];

                if(prizeDuration == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration);
                }

                switch (prizeType)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue, promoSqlId);
                        new model_name[128], msg[512];
                        GetVehicleModelName(prizeValue, model_name, sizeof(model_name)); 
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", model_name, prizeValue, szDurationText);
                        format(msg, sizeof(msg), "и получили %s", model_name);
                        //ShowPlayerPrizeGUI(playerid, prizeValue, msg, "Вы активировали промокод", 7, 30.0, 180.0, 15.0, 0.750);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                new Cache:insertResult;
                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId, gettime(), prizeDuration * 3600);
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);

                    if(prizeDuration > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration);
                    }
                }
                cache_delete(insertResult);
            }
            else if(rows == 2)
            {
                prizeSqlId = cache_get_field_content_int(0, "id");
                prizeType = cache_get_field_content_int(0, "prize_type");
                prizeValue = cache_get_field_content_int(0, "prize_value");
                prizeDuration = cache_get_field_content_int(0, "prize_duration");

                prizeSqlId2 = cache_get_field_content_int(1, "id"); 
                prizeType2 = cache_get_field_content_int(1, "prize_type");
                prizeValue2 = cache_get_field_content_int(1, "prize_value");
                prizeDuration2 = cache_get_field_content_int(1, "prize_duration"); 

                new currentPrizeMsg[256];

                if(prizeDuration == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration);
                }

                switch (prizeType)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue - 400, VI_NAME), prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                new Cache:insertResult;
                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId, gettime(), prizeDuration * 3600);
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration);
                    }
                }
                cache_delete(insertResult);
                //приз 2

                if(prizeDuration2 == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration2);
                }

                switch (prizeType2)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue2);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue2);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue2, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue2 - 400, VI_NAME), prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId2, gettime(), prizeDuration2 * 3600); 
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId2, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration2 > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration2);
                    }
                }
                cache_delete(insertResult);
            }
            else if(rows == 3)
            {
                prizeSqlId = cache_get_field_content_int(0, "id"); 
                prizeType = cache_get_field_content_int(0, "prize_type");
                prizeValue = cache_get_field_content_int(0, "prize_value");
                prizeDuration = cache_get_field_content_int(0, "prize_duration");

                prizeSqlId2 = cache_get_field_content_int(1, "id"); 
                prizeType2 = cache_get_field_content_int(1, "prize_type");
                prizeValue2 = cache_get_field_content_int(1, "prize_value");
                prizeDuration2 = cache_get_field_content_int(1, "prize_duration");

                prizeSqlId3 = cache_get_field_content_int(2, "id"); 
                prizeType3 = cache_get_field_content_int(2, "prize_type");
                prizeValue3 = cache_get_field_content_int(2, "prize_value");
                prizeDuration3 = cache_get_field_content_int(2, "prize_duration");

                new currentPrizeMsg[256];

                if(prizeDuration == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration);
                }

                switch (prizeType)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue - 400, VI_NAME), prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                new Cache:insertResult;
                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId, gettime(), prizeDuration * 3600);
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration);
                    }
                }
                cache_delete(insertResult);
                //приз 2

                if(prizeDuration2 == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration2);
                }

                switch (prizeType2)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue2);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue2);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue2, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue2 - 400, VI_NAME), prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId2, gettime(), prizeDuration2 * 3600); 
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId2, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration2 > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration2);
                    }
                }
                cache_delete(insertResult);

                //приз 3

                if(prizeDuration3 == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration3);
                }

                switch (prizeType3)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue3);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue3, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue3);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue3, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue3, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue3 - 400, VI_NAME), prizeValue3, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId3, gettime(), prizeDuration3 * 3600); 
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId3, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration3 > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration3);
                    }
                }
                cache_delete(insertResult);
            }
            else if(rows == 4)
            {
                prizeSqlId = cache_get_field_content_int(0, "id");
                prizeType = cache_get_field_content_int(0, "prize_type");
                prizeValue = cache_get_field_content_int(0, "prize_value");
                prizeDuration = cache_get_field_content_int(0, "prize_duration");

                prizeSqlId2 = cache_get_field_content_int(1, "id");
                prizeType2 = cache_get_field_content_int(1, "prize_type");
                prizeValue2 = cache_get_field_content_int(1, "prize_value");
                prizeDuration2 = cache_get_field_content_int(1, "prize_duration");

                prizeSqlId3 = cache_get_field_content_int(2, "id");
                prizeType3 = cache_get_field_content_int(2, "prize_type");
                prizeValue3 = cache_get_field_content_int(2, "prize_value");
                prizeDuration3 = cache_get_field_content_int(2, "prize_duration");

                prizeSqlId4 = cache_get_field_content_int(3, "id");
                prizeType4 = cache_get_field_content_int(3, "prize_type");
                prizeValue4 = cache_get_field_content_int(3, "prize_value");
                prizeDuration4 = cache_get_field_content_int(3, "prize_duration");

                prizeSqlId = cache_get_field_content_int(0, "id");
                prizeType = cache_get_field_content_int(0, "prize_type");
                prizeValue = cache_get_field_content_int(0, "prize_value");
                prizeDuration = cache_get_field_content_int(0, "prize_duration");

                prizeSqlId2 = cache_get_field_content_int(1, "id");
                prizeType2 = cache_get_field_content_int(1, "prize_type");
                prizeValue2 = cache_get_field_content_int(1, "prize_value");
                prizeDuration2 = cache_get_field_content_int(1, "prize_duration");

                prizeSqlId3 = cache_get_field_content_int(2, "id");
                prizeType3 = cache_get_field_content_int(2, "prize_type");
                prizeValue3 = cache_get_field_content_int(2, "prize_value");
                prizeDuration3 = cache_get_field_content_int(2, "prize_duration");

                new currentPrizeMsg[256];

                if(prizeDuration == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration);
                }

                switch (prizeType)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue - 400, VI_NAME), prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                new Cache:insertResult;
                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId, gettime(), prizeDuration * 3600);
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration);
                    }
                }
                cache_delete(insertResult);
                //приз 2

                if(prizeDuration2 == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration2);
                }

                switch (prizeType2)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue2);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue2);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue2, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue2 - 400, VI_NAME), prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId2, gettime(), prizeDuration2 * 3600); 
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId2, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration2 > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration2);
                    }
                }
                cache_delete(insertResult);

                //приз 3

                if(prizeDuration3 == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration3);
                }

                switch (prizeType3)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue3);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue3, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue3);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue3, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue3, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue3 - 400, VI_NAME), prizeValue3, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId3, gettime(), prizeDuration3 * 3600); 
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId3, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration3 > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration3);
                    }
                }
                cache_delete(insertResult);

                //приз 4

                if(prizeDuration4 == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration4);
                }

                switch (prizeType4)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue4);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue4, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue4);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue4, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue4, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue4 - 400, VI_NAME), prizeValue4, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId4, gettime(), prizeDuration4 * 3600); 
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId4, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration4 > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration4);
                    }
                }
                cache_delete(insertResult);
            }
            else if(rows == 5)
            {
                prizeSqlId = cache_get_field_content_int(0, "id"); 
                prizeType = cache_get_field_content_int(0, "prize_type");
                prizeValue = cache_get_field_content_int(0, "prize_value");
                prizeDuration = cache_get_field_content_int(0, "prize_duration");

                prizeSqlId2 = cache_get_field_content_int(1, "id");
                prizeType2 = cache_get_field_content_int(1, "prize_type");
                prizeValue2 = cache_get_field_content_int(1, "prize_value");
                prizeDuration2 = cache_get_field_content_int(1, "prize_duration");

                prizeSqlId3 = cache_get_field_content_int(2, "id");
                prizeType3 = cache_get_field_content_int(2, "prize_type");
                prizeValue3 = cache_get_field_content_int(2, "prize_value");
                prizeDuration3 = cache_get_field_content_int(2, "prize_duration");

                prizeSqlId4 = cache_get_field_content_int(3, "id");
                prizeType4 = cache_get_field_content_int(3, "prize_type");
                prizeValue4 = cache_get_field_content_int(3, "prize_value");
                prizeDuration4 = cache_get_field_content_int(3, "prize_duration");

                prizeSqlId5 = cache_get_field_content_int(4, "id");
                prizeType5 = cache_get_field_content_int(4, "prize_type");
                prizeValue5 = cache_get_field_content_int(4, "prize_value");
                prizeDuration5 = cache_get_field_content_int(4, "prize_duration");

                new currentPrizeMsg[256];

                if(prizeDuration == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration);
                }

                switch (prizeType)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue - 400, VI_NAME), prizeValue, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                new Cache:insertResult;
                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId, gettime(), prizeDuration * 3600);
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration);
                    }
                }
                cache_delete(insertResult);
                //приз 2

                if(prizeDuration2 == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration2);
                }

                switch (prizeType2)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue2);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue2);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue2, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue2 - 400, VI_NAME), prizeValue2, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId2, gettime(), prizeDuration2 * 3600); 
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId2, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration2 > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration2);
                    }
                }
                cache_delete(insertResult);

                //приз 3

                if(prizeDuration3 == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration3);
                }

                switch (prizeType3)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue3);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue3, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue3);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue3, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue3, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue3 - 400, VI_NAME), prizeValue3, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId3, gettime(), prizeDuration3 * 3600); 
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId3, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration3 > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration3);
                    }
                }
                cache_delete(insertResult);

                //приз 4

                if(prizeDuration4 == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration4);
                }

                switch (prizeType4)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue4);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue4, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue4);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue4, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue4, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue4 - 400, VI_NAME), prizeValue4, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId4, gettime(), prizeDuration4 * 3600); 
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId4, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration4 > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration4);
                    }
                }
                cache_delete(insertResult);

                //приз 5

                if(prizeDuration4 == 0) {
                    format(szDurationText, sizeof(szDurationText), " (навсегда)");
                } else {
                    format(szDurationText, sizeof(szDurationText), " {ffffff}на {ffff00}%d {ffffff}ч.", prizeDuration5);
                }

                switch (prizeType5)
                {
                    case PRIZE_TYPE_MONEY:
                    {
                        GivePlayerMoneyEx(playerid, prizeValue5);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d руб.%s\n", prizeValue5, szDurationText);
                    }
                    case PRIZE_TYPE_DONATE:
                    {
                        GivePlayerDonateRub(playerid, prizeValue5);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d доната%s\n", prizeValue5, szDurationText);
                    }
                    case PRIZE_TYPE_CAR:
                    {
                        GivePromoCar(playerid, prizeValue5, promoSqlId);
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- Автомобиль: {ffff00}%s (модель ID: %d)%s\n", GetVehicleInfo(prizeValue5 - 400, VI_NAME), prizeValue5, szDurationText);
                    }
                    case PRIZE_TYPE_EXP:
                    {
                        AddPlayerData(playerid, P_EXP, +, prizeValue);
                        UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));
                        format(currentPrizeMsg, sizeof(currentPrizeMsg), "{ffffff}- {ffff00}%d EXP\n", prizeValue);
                    }
                }
                strcat(szActivationMessage, currentPrizeMsg);

                mysql_format(mysql, query, sizeof(query),
                    "INSERT INTO `player_promos` (`account_id`, `promo_prize_sql_id`, `start_time`, `remaining_time`) VALUES (%d, %d, %d, %d)",
                    accountId, prizeSqlId5, gettime(), prizeDuration5 * 3600); 
                insertResult = mysql_query(mysql, query, true);
                if(mysql_errno() != 0)
                {
                    printf("[WERTON_PROMO] Ошибка записи активации приза %d для игрока %d: %d", prizeSqlId5, accountId, mysql_errno());
                }
                else
                {
                    new playerPromoEntryID = cache_insert_id(insertResult);
                    if(prizeDuration5 > 0)
                    {
                        SetPlayerPromoTimer(playerid, playerPromoEntryID, prizeDuration5);
                    }
                }
                cache_delete(insertResult);
            }
            cache_delete(result);

            if(promoData[PromoUses] != 0)
            {
                mysql_format(mysql, query, sizeof(query), "UPDATE promocodes SET uses_left = uses_left - 1 WHERE id = %d", promoSqlId);
                mysql_query(mysql, query, false);

                new index = GetPromoCodeIndexByString(inputtext);
                if(index != -1)
                {
                    PromoCodes[index][UsesLeft]--;
                }
            }

        new money_bonus = 0;
    
        if(level >= 0 && level <= 10)
        {
            money_bonus = PROMO_LEVEL_DATA[level][4];
        }

        mysql_format(mysql, query, sizeof(query), "UPDATE `promocodes` SET `activations` = `activations` + 1, `promo_balance` = `promo_balance` + %d WHERE `id` = %d", money_bonus, promoSqlId);
        mysql_query(mysql, query);
    
        new creator_playerid = GetPlayerIDFromAccountID(ownerAccountId);

        if(creator_playerid != -1)
        {
            new message[256];
            format(message, sizeof(message), "{66CC33}| {FFFFFF}Ваш промокод только что активировали! Начислено {66CC33}%d{FFFFFF} руб. на баланс.", money_bonus);
            SendClientMessage(creator_playerid, -1, message);
        }

            ShowPlayerDialog(playerid, DIALOG_PROMO_PRIZE_INFO, DIALOG_STYLE_MSGBOX, "{FF6347}"SERVER_NAME"{ffffff} | Активация промокода", szActivationMessage, "Ок", "");
            ShowNotificationNew(playerid, 4, 7, 0, 0, "Вы получили приз по промокоду!", ">>");
            AddPlayerActivatedPromo(GetPlayerAccountID(playerid), promoSqlId);
            return 1;
        }
        else
        {
            SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Этот промокод больше недоступен (использований: 0).");
            return 1;
        }
    }
    else
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Неверный промокод.");
        return 1;
    }
}
    }
    #if defined prom_OnDialogResponse
    return prom_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#else
    return 1;
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse prom_OnDialogResponse
#if defined prom_OnDialogResponse
forward prom_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

// мб надо кому, не ибу
public CheckUsePromoCode(playerid, accountId, promoSqlId)
{
    new query_test[156];

    mysql_format(mysql, query_test, sizeof(query_test), "SELECT 1 FROM player_promos pp JOIN promo_prizes ppz ON pp.promo_prize_sql_id = ppz.id WHERE pp.account_id = %d AND ppz.promo_id = %d LIMIT 1", accountId, promoSqlId);
    new Cache:result_test = mysql_query(mysql, query_test, false);

    if(cache_num_rows(result_test) > 0)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Вы уже использовали этот промокод.");
        cache_delete(result_test);
        return 0;
    }
    cache_delete(result_test);
    return 1;
}

public OnPromoCodeCheckComplete(playerid, const promoCode[])
{
    if(!IsPlayerConnected(playerid))
    {
        return 0;
    }

    new query[258];
    new accountId = GetPlayerAccountID(playerid);
    new player_money = GetPlayerMoneyEx(playerid);
    new temp_promoCode[MAX_PROMO_CODE_LENGTH];
    new message[256];
    new Cache:result;

    mysql_format(mysql, query, sizeof(query), "SELECT 1 FROM promocodes WHERE code = '%s' LIMIT 1", promoCode);
    result = mysql_query(mysql, query, false);

    if(mysql_errno() != 0)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ошибка базы данных при проверке промокода. Попробуйте позже.");
        callcmd::promo(playerid, "");
        cache_delete(result);
        return 1;
    }

    if(cache_num_rows(result) > 0)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ошибка: Промокод с таким названием уже существует. Выберите другой.");
        callcmd::promo(playerid, "");
        cache_delete(result);
        return 1;
    }
    cache_delete(result);

    new len = strlen(promoCode);
    new cost = 0; // Стоимость создания промокода в рублях
    new vc_cost = 0; // Стоимость создания промокода в донате

    if(len >= 3 && len <= 4) // От 3 до 4 символов
    {
        cost = 10000000;
        vc_cost = 2000;
    }
    else if(len >= 5 && len <= 7)
    {
        cost = 5000000;
    }
    else if(len >= 8) // От 7 символов, то есть 8 и более
    {
        cost = 3000000;
    }

    new i = 0;
    while (i < MAX_PROMO_CODE_LENGTH - 1 && promoCode[i] != EOS)
    {
        temp_promoCode[i] = promoCode[i];
        i++;
    }
    temp_promoCode[i] = EOS;

    new cost_text[64];
    if(vc_cost > 0) {
        format(cost_text, sizeof(cost_text), "%d рублей или %d ВС", cost, vc_cost);
    } else {
        format(cost_text, sizeof(cost_text), "%d рублей", cost);
    }

    // DIALOG_ADDPROMO_PRIZE_MONEY_BY_PLAYER было золупко

    mysql_format(mysql, query, sizeof(query), "INSERT INTO promocodes (code, uses_limit, promo_level, creator_account_id, created_at, creation_cost) VALUES ('%s', '0', '0', %d, NOW(), %d)", promoCode, accountId, cost);
    result = mysql_query(mysql, query, false);

    if(mysql_errno() != 0)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ошибка: Промокод с таким названием уже существует. Выберите другой.");
        callcmd::promo(playerid, "");
        cache_delete(result);
        return 1;
    }
    cache_delete(result);

    if(player_money < (cost))
    {    
        if(player_money < (vc_cost))
        {   
            format(message, sizeof(message), "{ff2400}| {ffffff}Ошибка: Недостаточно средств. Вам требуется %d рублей или %d доната.", cost, vc_cost);
            SendClientMessage(playerid, -1, message);
            callcmd::promo(playerid, "");
            return 1;
        }
        else
        {
            GivePlayerDonateRub(playerid, -vc_cost);
            format(message, sizeof(message), "{FFFF00}| {FFFFFF}Промокод '{FFFF00}%s{FFFFFF}' успешно создан! С Вашего баланса было списано {FFFF00}%d доната.", promoCode, vc_cost);
            SendClientMessage(playerid, -1, message);
            callcmd::mypromo(playerid, "");
            LoadPromoCodesFromDatabase();
        }
    }
    else 
    {
        GivePlayerMoneyEx(playerid, -cost);
        format(message, sizeof(message), "{FFFF00}| {FFFFFF}Промокод '{FFFF00}%s{FFFFFF}' успешно создан! С Вашего баланса было списано {FFFF00}%d руб.", promoCode, cost);
        SendClientMessage(playerid, -1, message);
        callcmd::mypromo(playerid, "");
        LoadPromoCodesFromDatabase();
    }

    return 1;
}

public HasPlayerCreatedPromo(playerid)
{
    new query[128];
    mysql_format(mysql, query, sizeof(query), "SELECT `id` FROM `promocodes` WHERE `creator_account_id` = %d LIMIT 1", GetPlayerAccountID(playerid));
    new Cache:result = mysql_query(mysql, query);
    new hasPromo = cache_num_rows(result) > 0;
    cache_delete(result);
    return hasPromo;
}

public AddPlayerActivatedPromo(account_id, promo_id)
{
    new query[256];
    mysql_format(mysql, query, sizeof(query), "INSERT INTO `activated_promos` (`account_id`, `promo_id`, `activated_at`) VALUES (%d, %d, NOW())", account_id, promo_id);
    mysql_query(mysql, query);
}

stock SavePromoLevelPrizes(playerid, promoId, level)
{
    new prizeCount;
    new query[256];
    
    new prizes[5][3];

    mysql_format(mysql, query, sizeof(query), "DELETE FROM `promo_prizes` WHERE `promo_id` = %d", promoId);
    mysql_query(mysql, query, false);

    prizeCount = PROMO_LEVEL_DATA[level][2];
    
    switch(level)
    {
        case 1:
        {
            for(new i = 0; i < prizeCount; i++) {
                prizes[i][0] = PromoLevelPrizes_1[i][0];
                prizes[i][1] = PromoLevelPrizes_1[i][1];
                prizes[i][2] = PromoLevelPrizes_1[i][2];
            }
        }
        case 2:
        {
            for(new i = 0; i < prizeCount; i++) {
                prizes[i][0] = PromoLevelPrizes_2[i][0];
                prizes[i][1] = PromoLevelPrizes_2[i][1];
                prizes[i][2] = PromoLevelPrizes_2[i][2];
            }
        }
        case 3:
        {
            for(new i = 0; i < prizeCount; i++) {
                prizes[i][0] = PromoLevelPrizes_3[i][0];
                prizes[i][1] = PromoLevelPrizes_3[i][1];
                prizes[i][2] = PromoLevelPrizes_3[i][2];
            }
        }
        case 4:
        {
            for(new i = 0; i < prizeCount; i++) {
                prizes[i][0] = PromoLevelPrizes_4[i][0];
                prizes[i][1] = PromoLevelPrizes_4[i][1];
                prizes[i][2] = PromoLevelPrizes_4[i][2];
            }
        }
        case 5:
        {
            for(new i = 0; i < prizeCount; i++) {
                prizes[i][0] = PromoLevelPrizes_5[i][0];
                prizes[i][1] = PromoLevelPrizes_5[i][1];
                prizes[i][2] = PromoLevelPrizes_5[i][2];
            }
        }
        case 6:
        {
            for(new i = 0; i < prizeCount; i++) {
                prizes[i][0] = PromoLevelPrizes_6[i][0];
                prizes[i][1] = PromoLevelPrizes_6[i][1];
                prizes[i][2] = PromoLevelPrizes_6[i][2];
            }
        }
        case 7:
        {
            for(new i = 0; i < prizeCount; i++) {
                prizes[i][0] = PromoLevelPrizes_7[i][0];
                prizes[i][1] = PromoLevelPrizes_7[i][1];
                prizes[i][2] = PromoLevelPrizes_7[i][2];
            }
        }
        case 8:
        {
            for(new i = 0; i < prizeCount; i++) {
                prizes[i][0] = PromoLevelPrizes_8[i][0];
                prizes[i][1] = PromoLevelPrizes_8[i][1];
                prizes[i][2] = PromoLevelPrizes_8[i][2];
            }
        }
        case 9:
        {
            for(new i = 0; i < prizeCount; i++) {
                prizes[i][0] = PromoLevelPrizes_9[i][0];
                prizes[i][1] = PromoLevelPrizes_9[i][1];
                prizes[i][2] = PromoLevelPrizes_9[i][2];
            }
        }
        case 10:
        {
            for(new i = 0; i < prizeCount; i++) {
                prizes[i][0] = PromoLevelPrizes_10[i][0];
                prizes[i][1] = PromoLevelPrizes_10[i][1];
                prizes[i][2] = PromoLevelPrizes_10[i][2];
            }
        }
    }
    
    for(new i = 0; i < prizeCount; i++)
    {
        new prizeType = prizes[i][0];
        new prizeValue = prizes[i][1];
        new prizeDuration = prizes[i][2];
        
        mysql_format(mysql, query, sizeof(query),
            "INSERT INTO `promo_prizes` (`promo_id`, `prize_index`, `prize_type`, `prize_value`, `prize_duration`) VALUES (%d, %d, %d, %d, %d)",
            promoId, i, prizeType, prizeValue, prizeDuration);
            
        mysql_query(mysql, query, false);
        
        if(mysql_errno() != 0)
        {
            printf("[WERTON_PROMO] Ошибка добавления приза (promo_prizes table) для промокода ID %d, приз %d: %d", promoId, i, mysql_errno());
        }
    }
}

stock GetPromoLevel(playerid, promoSQL_id)
{
    new query[128];
    new level = -1;

    mysql_format(mysql, query, sizeof(query), "SELECT `promo_level` FROM `promocodes` WHERE `id` = %d LIMIT 1", promoSQL_id);
    new Cache:result = mysql_query(mysql, query);

    if(cache_num_rows(result) > 0)
    {
        level = cache_get_field_content_int(0, "promo_level");
    }

    cache_delete(result);
    return level;
}

stock GetPromoLevelForOwner(playerid)
{
    new query[128];
    new level = -1;

    mysql_format(mysql, query, sizeof(query), "SELECT `promo_level` FROM `promocodes` WHERE `creator_account_id` = %d LIMIT 1", GetPlayerAccountID(playerid));
    new Cache:result = mysql_query(mysql, query);

    if(cache_num_rows(result) > 0)
    {
        level = cache_get_field_content_int(0, "promo_level");
    }

    cache_delete(result);
    return level;
}

CMD:createpromo(playerid)
{
    callcmd::addcpromo(playerid, "");
}

CMD:createytpromo(playerid)
{
    callcmd::addcpromo(playerid, "");
}

// меня просили сделать команды с радика, ну а я слушаю папищеков
CMD:addcpromo(playerid)
{
    if(GetPlayerAdminEx(playerid) < 13) return SendClientMessage(playerid, -1, "{ff2400}| {ffffff}У вас недостаточно прав для использования этой команды.");

    ShowPlayerDialog(playerid, DIALOG_ADDPROMO_CODE, DIALOG_STYLE_INPUT, "{FF6347}"SERVER_NAME" {FFFFFF}| Создание промокода", "Введите название промокода (без пробелов):", "Далее", "Отмена");
    return 1;
}

CMD:promo(playerid)
{
    new dialog_text[512];
    new list_item_3_text[96];
    
    if(HasPlayerCreatedPromo(playerid))
    {
        format(list_item_3_text, sizeof(list_item_3_text), "{EB4C42} #3. {FFFFFF}Управление промокодом\t\t\t\t {888888}нажмите");
    }
    else
    {
        format(list_item_3_text, sizeof(list_item_3_text), "{EB4C42} #3. {FFFFFF}Создать промокод\t\t\t\t\t {888888}нажмите");
    }

    format(dialog_text, sizeof(dialog_text), "{EB4C42} #1. {FFFFFF}Активировать промокод\t\t\t\t\t {888888}нажмите\n{EB4C42} #2. {FFFFFF}Подарок ютуберу\t\t\t\t\t\t {888888}нажмите\n%s\n{EB4C42} #4. {FFFFFF}Забрать призы\t\t\t\t\t\t\t {888888}нажмите", list_item_3_text);

    ShowPlayerDialog(playerid, DIALOG_ACT_PROMO, DIALOG_STYLE_LIST,
        "{FF0000} Промокод",
        dialog_text,
        "Далее", "Выйти"
    );
    return 1;
}
alias:promo("promocode")

CMD:mypromo(playerid)
{
    new query[256];
    new dialog_text[512];
    new promo_code[MAX_PROMO_CODE_LENGTH];
    new promo_level, activations, nextLevelActivations;

    mysql_format(mysql, query, sizeof(query), "SELECT `code`, `promo_level`, `activations` FROM `promocodes` WHERE `creator_account_id` = %d LIMIT 1", GetPlayerAccountID(playerid));
    new Cache:result = mysql_query(mysql, query);

    if(cache_num_rows(result) == 0)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}У Вас нет личного промокода.");
        cache_delete(result);
        return 1;
    }

    cache_get_field_content(0, "code", promo_code, sizeof(promo_code));
    promo_level = cache_get_field_content_int(0, "promo_level");
    activations = cache_get_field_content_int(0, "activations");
    
    if(promo_level >= 0 && promo_level < sizeof(PROMO_LEVEL_DATA))
    {
        nextLevelActivations = PROMO_LEVEL_DATA[promo_level + 1][1];
    }
    else
    {
        nextLevelActivations = 0;
    }

    format(dialog_text, sizeof(dialog_text), "{EB4C42} #1. {FFFFFF}Ваш промокод: {ff0000}%s\n{EB4C42} #2. {FFFFFF}Уровень промокода: {ff0000}%d\n{EB4C42} #3. {FFFFFF}Информация о промокодах\n{EB4C42} #4. {FFFFFF}Промокод активирован {ff0000}%d{ffffff} из {ff0000}%d{ffffff} раз.", promo_code, promo_level, activations, nextLevelActivations);

    ShowPlayerDialog(playerid, DIALOG_PROMO_MANAGEMENT, DIALOG_STYLE_LIST,
        "{FF0000} Промокод",
        dialog_text,
        "Далее", "Выйти"
    );

    cache_delete(result);
    return 1;
}
alias:mypromo("mypromocode")

CMD:checkpromo(playerid)
{
    new query[256];
    new dialog_text[512];
    new dialog_title[152];
    new Cache:result;

    mysql_format(mysql, query, sizeof(query), "SELECT `id`, `code`, `promo_level`, `activations`, `promo_balance` FROM `promocodes` WHERE `creator_account_id` = %d LIMIT 1", GetPlayerAccountID(playerid));
    result = mysql_query(mysql, query);

    if(cache_num_rows(result) == 0)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}У Вас нет личного промокода.");
        cache_delete(result);
        return 1;
    }

    new promo_code[MAX_PROMO_CODE_LENGTH];
    new promo_level, promo_activations, promo_balance, promo_id;

    promo_id = cache_get_field_content_int(0, "id");
    cache_get_field_content(0, "code", promo_code, sizeof(promo_code));
    promo_level = cache_get_field_content_int(0, "promo_level");
    promo_activations = cache_get_field_content_int(0, "activations");
    promo_balance = cache_get_field_content_int(0, "promo_balance");
    cache_delete(result);
    
    if(promo_level == 0)
    {
        SendClientMessage(playerid, -1, "{ff2400}| {ffffff}Ваш промокод не настроен. Используйте /promo для настройки уровня.");
        return 1;
    }

    format(dialog_title, sizeof(dialog_title), "{FF0000} %s", promo_code);

    format(dialog_text, sizeof(dialog_text), "Статистика промокода: {ff0000}%s\n\n{ffffff}Ваш промокод ввели {FF0000}%d{ffffff} раз и вы получили {ff0000}%d{ffffff} рублей!", promo_code, promo_activations, promo_balance);

    ShowPlayerDialog(playerid, DIALOG_PROMO_STATS, DIALOG_STYLE_MSGBOX, dialog_title, dialog_text, "Выйти", "");
 
    if(promo_balance == 0) return 1;

    GivePlayerMoneyEx(playerid, promo_balance);

    mysql_format(mysql, query, sizeof(query), "UPDATE `promocodes` SET `promo_balance` = 0 WHERE `id` = %d", promo_id);
    mysql_query(mysql, query);

    return 1;
}

CMD:bcode(playerid)
{
    ShowPlayerDialog(playerid, DIALOG_APPLY_PROMO_CODE, DIALOG_STYLE_INPUT, "{FF0000}Промокод", "Введите промокод для того чтобы получить приз:", "Ввести", "Выйти");
    return 1;
}
