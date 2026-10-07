// Purchase into an existing free company slot, preserving the TC architecture.
#define TC56_PRICE 5000000
#define TC56_INTERIOR 2
#define TC56_WORLD 1
new const Float:TC56_Position[4] = {1.005925, 2508.604003, 2011.045166, 353.655731};
new STREAMER_TAG_PICKUP:g_TC56_Pickup[3];
new g_TC56_Step[MAX_PLAYERS];
new g_TC57_Office[MAX_PLAYERS];
new g_TC57_Interior[MAX_PLAYERS];
new g_TC56_Name[MAX_PLAYERS][33];
new bool:g_TC56_StorageReady;

stock TC56_Reset(playerid)
{
    g_TC56_Step[playerid] = 0;
    g_TC57_Office[playerid] = -1;
    g_TC57_Interior[playerid] = -1;
    g_TC56_Name[playerid][0] = EOS;
    return 1;
}

stock TC56_CreateMarker()
{
    for(new office; office < sizeof g_tc_interior_vw; office++)
    {
        g_TC56_Pickup[office] = CreateDynamicPickup(1274, 23, TC56_Position[0], TC56_Position[1], TC56_Position[2], g_tc_interior_vw[office], g_tc_interior_id);
        CreateDynamic3DTextLabel("{FFFF24}Покупка транспортной компании\n{FFFFFF}Цена: 5 000 000 руб.\nПодойдите, чтобы выбрать название", -1,
            TC56_Position[0], TC56_Position[1], TC56_Position[2] + 0.6, 12.0,
            INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, g_tc_interior_vw[office], g_tc_interior_id);
    }
    // Keep the explicit Interior=2/VW=1 point supplied for v56 as well.
    g_TC56_Pickup[2] = CreateDynamicPickup(1274, 23, TC56_Position[0], TC56_Position[1], TC56_Position[2], TC56_WORLD, TC56_INTERIOR);
    CreateDynamic3DTextLabel("{FFFF24}Покупка транспортной компании\n{FFFFFF}Цена: 5 000 000 руб.\nПодойдите, чтобы выбрать название", -1,
        TC56_Position[0], TC56_Position[1], TC56_Position[2] + 0.6, 12.0,
        INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, TC56_WORLD, TC56_INTERIOR);
    return 1;
}

stock bool:TC56_AtMarker(playerid)
{
    return IsPlayerConnected(playerid) && IsPlayerLogged(playerid) &&
        GetPlayerState(playerid) == PLAYER_STATE_ONFOOT &&
        TC57_GetOffice(playerid) != -1 &&
        IsPlayerInRangeOfPoint(playerid, 2.5, TC56_Position[0], TC56_Position[1], TC56_Position[2]);
}

stock TC57_GetOffice(playerid)
{
    new interior = GetPlayerInterior(playerid), world = GetPlayerVirtualWorld(playerid);
    if(interior == TC56_INTERIOR && world == TC56_WORLD) return TC_OFFICE_BATUREVO;
    if(interior != g_tc_interior_id) return -1;
    for(new office; office < sizeof g_tc_interior_vw; office++)
        if(world == g_tc_interior_vw[office]) return office;
    return -1;
}

stock TC56_Open(playerid)
{
    if(!TC56_AtMarker(playerid) || g_TC56_Step[playerid]) return 1;
    if(!g_tc_companies_loaded) return SendClientMessage(playerid, -1, "Транспортные компании ещё загружаются.");
    if(GetPlayerLevel(playerid) < TC_JOIN_MIN_LEVEL) return SendClientMessage(playerid, -1, "Покупка ТК доступна со 2 уровня.");
    if(TC_PlayerHasTcCompany(playerid)) return SendClientMessage(playerid, -1, "Вы уже состоите в ТК. Сначала покиньте её; вторую компанию купить нельзя.");
    if(GetPlayerMoneyEx(playerid) < TC56_PRICE) return SendClientMessage(playerid, -1, "Для покупки ТК требуется 5 000 000 руб.");
    g_TC56_Step[playerid] = 1;
    g_TC57_Office[playerid] = TC57_GetOffice(playerid);
    g_TC57_Interior[playerid] = GetPlayerInterior(playerid);
    Dialog(playerid, DIALOG_TC_PURCHASE_NAME, DIALOG_STYLE_INPUT, "Покупка транспортной компании",
        "Цена: 5 000 000 руб.\nВведите название: 2-32 символа.\nАнглийские буквы, цифры, пробел и _.", "Далее", "Отмена");
    return 1;
}

stock bool:TC56_Exec(query[])
{
    mysql_query(mysql, query, false);
    if(!mysql_errno()) return true;
    printf("[TC_PURCHASE][SQL_ERROR] errno=%d", mysql_errno());
    return false;
}

stock TC56_Abort(playerid, reason[])
{
    TC56_Exec("ROLLBACK");
    printf("[TC_PURCHASE][FAILED] player=%d account=%d", playerid, GetPlayerAccountID(playerid));
    SendClientMessage(playerid, -1, reason);
    return 0;
}

stock bool:TC56_UpdateOne(query[])
{
    new Cache:result = mysql_query(mysql, query, true);
    new valid = !mysql_errno() && cache_affected_rows() == 1;
    cache_delete(result);
    return valid != 0;
}

stock TC56_Buy(playerid)
{
    // Caller consumes the confirmation state before any SQL or money mutation.
    if(!TC56_AtMarker(playerid) || TC57_GetOffice(playerid) != g_TC57_Office[playerid] ||
        GetPlayerInterior(playerid) != g_TC57_Interior[playerid] || GetPlayerLevel(playerid) < TC_JOIN_MIN_LEVEL ||
        TC_PlayerHasTcCompany(playerid) || !TC_IsValidCompanyName(g_TC56_Name[playerid])) return 0;
    new money = GetPlayerMoneyEx(playerid), account = GetPlayerAccountID(playerid);
    if(money < TC56_PRICE) return SendClientMessage(playerid, -1, "Недостаточно денег: требуется 5 000 000 руб.");
    if(!g_TC56_StorageReady)
    {
        new Cache:engine_cache = mysql_query(mysql, "SELECT COUNT(*) AS n FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME IN ('accounts','tc_companies','tc_employees') AND ENGINE='InnoDB'", true);
        new supported = !mysql_errno() && cache_num_rows() && cache_get_field_content_int(0, "n") == 3;
        cache_delete(engine_cache);
        if(!supported) return SendClientMessage(playerid, -1, "Покупка недоступна: для сохранения нужны таблицы InnoDB. Сообщите администратору.");
        g_TC56_StorageReady = true;
    }
    if(!TC56_Exec("START TRANSACTION")) return 0;
    new query[768];
    mysql_format(mysql, query, sizeof query, "SELECT money,tc_company_id FROM accounts WHERE id=%d FOR UPDATE", account);
    new Cache:result = mysql_query(mysql, query, true);
    new valid = !mysql_errno() && cache_num_rows() == 1;
    if(valid) valid = cache_get_field_content_int(0, "money") == money && cache_get_field_content_int(0, "tc_company_id") == 0;
    cache_delete(result);
    if(!valid) return TC56_Abort(playerid, "Данные счёта изменились или вы уже состоите в ТК. Покупка отменена.");

    // Lock the same ordered company set for every buyer (including other names).
    result = mysql_query(mysql, "SELECT id,office,owner_id,name,balance,upgrade_office,upgrade_garage,upgrade_licenses FROM tc_companies ORDER BY id FOR UPDATE", true);
    if(mysql_errno()) { cache_delete(result); return TC56_Abort(playerid, "Не удалось загрузить компании."); }
    new company = -1, company_idx = -1, conflict;
    for(new row; row < cache_num_rows(); row++)
    {
        new owner = cache_get_field_content_int(row, "owner_id"), name[49];
        cache_get_field_content(row, "name", name, mysql, sizeof name);
        if(owner == account || (owner != -1 && !strcmp(name, g_TC56_Name[playerid], true))) conflict = 1;
        if(company != -1 || owner != -1 || cache_get_field_content_int(row, "office") != g_TC57_Office[playerid]) continue;
        if(cache_get_field_content_int(row, "balance") || cache_get_field_content_int(row, "upgrade_office") ||
            cache_get_field_content_int(row, "upgrade_garage") || cache_get_field_content_int(row, "upgrade_licenses")) continue;
        new sqlid = cache_get_field_content_int(row, "id"), idx = TC_GetCompanyIndexBySqlId(sqlid);
        if(idx < 0 || idx >= g_tc_companies_loaded) continue;
        company = sqlid; company_idx = idx;
    }
    cache_delete(result);
    if(conflict) return TC56_Abort(playerid, "Название уже занято или у вас уже есть ТК. Выберите другое название.");
    if(company == -1) return TC56_Abort(playerid, "В этом офисе нет свободных компаний. Деньги не списаны.");
    mysql_format(mysql, query, sizeof query, "SELECT (SELECT COUNT(*) FROM tc_fleet WHERE company_id=%d)+(SELECT COUNT(*) FROM tc_employees WHERE company_id=%d OR account_id=%d) AS n", company, company, account);
    result = mysql_query(mysql, query, true);
    valid = !mysql_errno() && cache_num_rows() && cache_get_field_content_int(0, "n") == 0;
    cache_delete(result);
    if(!valid) return TC56_Abort(playerid, "Свободный слот требует проверки администратором. Покупка отменена.");

    mysql_format(mysql, query, sizeof query, "UPDATE tc_companies SET owner_id=%d,name='%e',last_rename=%d,created_at=%d,commission=10 WHERE id=%d AND owner_id=-1", account, g_TC56_Name[playerid], gettime(), gettime(), company);
    if(!TC56_UpdateOne(query)) return TC56_Abort(playerid, "Не удалось сохранить компанию.");
    mysql_format(mysql, query, sizeof query, "UPDATE accounts SET money=money-%d,tc_company_id=%d WHERE id=%d AND money=%d AND tc_company_id=0", TC56_PRICE, company, account, money);
    if(!TC56_UpdateOne(query)) return TC56_Abort(playerid, "Не удалось сохранить оплату.");
    mysql_format(mysql, query, sizeof query, "INSERT INTO tc_employees (company_id,account_id,hired_at) VALUES (%d,%d,%d)", company, account, gettime());
    if(!TC56_Exec(query)) return TC56_Abort(playerid, "Не удалось сохранить владельца компании.");
    if(!TC56_Exec("COMMIT"))
    {
        printf("[TC_PURCHASE][COMMIT_CHECK_REQUIRED] account=%d company=%d", account, company);
        return TC56_Abort(playerid, "Ошибка подтверждения БД. Не повторяйте покупку; сообщите администратору.");
    }
    // SQL already persisted the debit atomically. Keep the existing runtime/HUD/log API,
    // with save=false so the same money is not written or charged a second time.
    GivePlayerMoneyEx(playerid, -TC56_PRICE, "Покупка транспортной компании", false, true);
    g_tc_companies[company_idx][TC_OWNER_ID] = account;
    g_tc_companies[company_idx][TC_COMMISSION] = 10;
    g_tc_companies[company_idx][TC_LAST_RENAME] = gettime();
    g_tc_company_rating[company_idx] = 0;
    format(g_tc_company_name[company_idx], 48, "%s", g_TC56_Name[playerid]);
    GetPlayerName(playerid, g_tc_owner_name[company_idx], 24);
    p_tc_company[playerid] = company_idx;
    SetPlayerData(playerid, P_TC_COMPANY_ID, company);
    printf("[TC_PURCHASE][SUCCESS] account=%d company=%d price=%d", account, company, TC56_PRICE);
    SendClientMessage(playerid, TC_COLOR_GOOD, "Вы купили транспортную компанию за 5 000 000 руб. Управление: /company");
    return 1;
}

stock TC56_Dialog(playerid, dialogid, response, inputtext[])
{
    if(dialogid != DIALOG_TC_PURCHASE_NAME && dialogid != DIALOG_TC_PURCHASE_CONFIRM) return 0;
    if(!response || !TC56_AtMarker(playerid) || TC57_GetOffice(playerid) != g_TC57_Office[playerid] ||
       GetPlayerInterior(playerid) != g_TC57_Interior[playerid]) { TC56_Reset(playerid); return 1; }
    if(dialogid == DIALOG_TC_PURCHASE_NAME)
    {
        if(g_TC56_Step[playerid] != 1) return 1;
        new length = strlen(inputtext);
        if(length < 2 || length > 32 || !TC_IsValidCompanyName(inputtext) || inputtext[0] == ' ' || inputtext[length - 1] == ' ')
        {
            TC56_Reset(playerid);
            SendClientMessage(playerid, -1, "Название: 2-32 символа A-Z, цифры и _. Не ставьте пробелы по краям.");
            return TC56_Open(playerid);
        }
        format(g_TC56_Name[playerid], 33, "%s", inputtext);
        g_TC56_Step[playerid] = 2;
        new body[192];
        format(body, sizeof body, "Название: %s\nЦена: 5 000 000 руб.\nВы станете владельцем компании. Подтвердить покупку?", g_TC56_Name[playerid]);
        Dialog(playerid, DIALOG_TC_PURCHASE_CONFIRM, DIALOG_STYLE_MSGBOX, "Подтверждение покупки ТК", body, "Купить", "Отмена");
    }
    else if(g_TC56_Step[playerid] == 2)
    {
        g_TC56_Step[playerid] = 0;
        TC56_Buy(playerid);
        TC56_Reset(playerid);
    }
    return 1;
}
