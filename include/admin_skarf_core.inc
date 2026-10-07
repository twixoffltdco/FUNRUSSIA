// Administrative identity and PIN flow adapted from skarf/ryzen.
// This is a staging module, not the completed administrative-system replacement.
#if defined _sr_admin_core_included
    #endinput
#endif
#define _sr_admin_core_included

#define SR_ADMIN_MAX_LEVEL (13)

new g_SRAdminSession[MAX_PLAYERS];
new const g_SRAdminRank[][32] =
{
    "Игрок", "Младший модератор", "Модератор", "Старший модератор",
    "Администратор", "Старший администратор", "ГС/ЗГС",
    "Куратор администрации", "Технический специалист",
    "Зам. главного администратора", "Главный администратор",
    "Команда проекта", "Заместитель основателя", "Основатель"
};

stock SRAdmin_Level(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 0;
    new level = GetPlayerAdminEx(playerid);
    // v57 has a named founder role at level 14. No other unknown levels are granted access.
    if(level == 14) return SR_ADMIN_MAX_LEVEL;
    if(level < 0 || level > SR_ADMIN_MAX_LEVEL) return 0;
    return level;
}

stock SRAdmin_Session(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return -1;
    return g_SRAdminSession[playerid];
}

stock SRAdmin_ClearTarget(playerid)
{
    DeletePVar(playerid, "SRAdmTarget");
    DeletePVar(playerid, "SRAdmTargetAccount");
    DeletePVar(playerid, "SRAdmTargetSession");
    DeletePVar(playerid, "SRAdmTargetPending");
    return 1;
}

stock SRAdmin_Reset(playerid)
{
    g_SRAdminSession[playerid]++;
    SRAdmin_ClearTarget(playerid);
    DeletePVar(playerid, "SRAdmPinStep");
    DeletePVar(playerid, "SRAdmPinAttempts");
    DeletePVar(playerid, "SRAdmPinBlocked");
    DeletePVar(playerid, "AdminLoginAttempts");
    DeletePVar(playerid, "AdminPass");
    DeletePVar(playerid, "SRTeleportPending");
    DeletePVar(playerid, "SRAdminsPending");
    DeletePVar(playerid, "SRAdminsPage");
    DeletePVar(playerid, "SRAdminsPrevious");
    DeletePVar(playerid, "SRAdminsNext");
    DeletePVar(playerid, "SRSpecTargetSession");
    DeletePVar(playerid, "SRSpecStartHouse");
    DeletePVar(playerid, "SRSpecStartBiz");
    DeletePVar(playerid, "SRHelpPending");
    DeletePVar(playerid, "SRHelpLevel");
    DeletePVar(playerid, "SRHelpPage");
    DeletePVar(playerid, "SRHelpMore");
    SetPlayerData(playerid, P_ADMIN_LOGGED, 0);
    return 1;
}

stock SRAdmin_ShowLogin(playerid)
{
    if(!IsPlayerLogged(playerid) || !SRAdmin_Level(playerid)) return 0;
    if(GetPlayerData(playerid, P_ADMIN_LOGGED)) return 1;
    if(GetPVarInt(playerid, "SRAdmPinBlocked")) return 0;
    new registration = GetPlayerData(playerid, P_APASS) == 0;
    SetPVarInt(playerid, "SRAdmPinStep", registration ? 1 : 2);
    if(registration)
        return Dialog(playerid, DIALOG_ADMIN_REG, DIALOG_STYLE_PASSWORD,
            "Регистрация админ-панели", "Придумайте отдельный пароль администратора: 4 цифры, от 1000 до 9999.", "Готово", "Отмена");
    return Dialog(playerid, DIALOG_ADMIN_LOGIN, DIALOG_STYLE_PASSWORD,
        "Вход в админ-панель", "Введите свой административный пароль.", "Войти", "Отмена");
}

stock SRAdmin_Require(playerid, min_level)
{
    if(!IsPlayerLogged(playerid) || SRAdmin_Level(playerid) < min_level)
    {
        SendClientMessage(playerid, 0xFF5533FF, "Недостаточно административных прав.");
        return 0;
    }
    if(!GetPlayerData(playerid, P_ADMIN_LOGGED))
    {
        SRAdmin_ShowLogin(playerid);
        return 0;
    }
    return 1;
}

stock SRAdmin_PinResponse(playerid, dialogid, response, const inputtext[])
{
    if(!IsPlayerLogged(playerid) || !SRAdmin_Level(playerid)) return 1;
    if(GetPlayerData(playerid, P_ADMIN_LOGGED) || GetPVarInt(playerid, "SRAdmPinBlocked")) return 1;
    new expected = (dialogid == DIALOG_ADMIN_REG) ? 1 : 2;
    if(GetPVarInt(playerid, "SRAdmPinStep") != expected) return 1;
    DeletePVar(playerid, "SRAdmPinStep");
    if(!response) return 1;
    new length = strlen(inputtext), numeric = length == 4;
    for(new i; i < length; i++)
        if(inputtext[i] < '0' || inputtext[i] > '9') numeric = 0;

    if(expected == 1)
    {
        if(GetPlayerData(playerid, P_APASS) != 0) return 1;
        if(!numeric || length != 4 || strval(inputtext) < 1000)
        {
            SendClientMessage(playerid, 0xFF5533FF, "Пароль должен состоять из четырёх цифр, от 1000 до 9999.");
            return SRAdmin_ShowLogin(playerid);
        }
        new query[192];
        mysql_format(mysql, query, sizeof query,
            "UPDATE accounts SET AdminPass=%d WHERE id=%d AND AdminPass=0 AND admin=%d LIMIT 1",
            strval(inputtext), GetPlayerAccountID(playerid), GetPlayerAdminEx(playerid));
        new Cache:result = mysql_query(mysql, query);
        new error = mysql_errno(mysql);
        new affected = error ? 0 : cache_affected_rows(mysql);
        if(result != Cache:0) cache_delete(result, mysql);
        if(error || affected != 1)
        {
            printf("[ADMIN] PIN_SAVE_FAILED player=%d account=%d errno=%d affected=%d", playerid, GetPlayerAccountID(playerid), error, affected);
            SendClientMessage(playerid, 0xFF5533FF, "Не удалось сохранить административный пароль. Повторите вход позже.");
            return 1;
        }
        SetPlayerData(playerid, P_APASS, strval(inputtext));
        return SRAdmin_ShowLogin(playerid);
    }

    if(!numeric || GetPlayerData(playerid, P_APASS) == 0 || strval(inputtext) != GetPlayerData(playerid, P_APASS))
    {
        new attempts = GetPVarInt(playerid, "SRAdmPinAttempts") + 1;
        SetPVarInt(playerid, "SRAdmPinAttempts", attempts);
        printf("[ADMIN] LOGIN_FAILED player=%d account=%d attempt=%d", playerid, GetPlayerAccountID(playerid), attempts);
        if(attempts >= 3)
        {
            SetPVarInt(playerid, "SRAdmPinBlocked", 1);
            return FixKick(playerid);
        }
        SendClientMessage(playerid, 0xFF5533FF, "Неверный административный пароль.");
        return SRAdmin_ShowLogin(playerid);
    }

    DeletePVar(playerid, "SRAdmPinAttempts");
    SetPlayerData(playerid, P_ADMIN_LOGGED, 1);
    RefreshAdminBadge(playerid);
    new message[160], level = SRAdmin_Level(playerid);
    format(message, sizeof message, "[A] %s[%d] вошёл в админ-панель: %s", GetPlayerNameEx(playerid), playerid, g_SRAdminRank[level]);
    SendMessageToAdmins(message, 0x33CC33FF);
    printf("[ADMIN] LOGIN_SUCCESS player=%d account=%d level=%d", playerid, GetPlayerAccountID(playerid), level);
    return 1;
}

stock SRAdmin_ApplyLevel(playerid, targetid, level, min_level, strict_hierarchy = 0)
{
    if(!SRAdmin_Require(playerid, min_level)) return 1;
    if(targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !IsPlayerLogged(targetid) || targetid == playerid)
        return SendClientMessage(playerid, 0xFF5533FF, "Недопустимый игрок.");
    new actor_level = SRAdmin_Level(playerid), target_level = SRAdmin_Level(targetid);
    if(level < 0 || level > SR_ADMIN_MAX_LEVEL || level > actor_level || target_level > actor_level || (strict_hierarchy && target_level >= actor_level))
        return SendClientMessage(playerid, 0xFF5533FF, "Недопустимый уровень или нарушение иерархии администрации.");
    if(GetPlayerAdminEx(targetid) != 0 && target_level == 0)
        return SendClientMessage(playerid, 0xFF5533FF, "Неизвестный текущий уровень цели. Требуется проверка владельцем.");
    new old_level = GetPlayerAdminEx(targetid);
    if(old_level == level) return SendClientMessage(playerid, -1, "У игрока уже установлен этот уровень.");
    new query[320], rank_name[32];
    if(level > 0) format(rank_name, sizeof rank_name, "%s", g_SRAdminRank[level]);
    mysql_format(mysql, query, sizeof query,
        "UPDATE accounts SET admin=%d,prefix='%e' WHERE id=%d AND admin=%d LIMIT 1",
        level, rank_name, GetPlayerAccountID(targetid), old_level);
    new Cache:result = mysql_query(mysql, query);
    new error = mysql_errno(mysql);
    new affected = error ? 0 : cache_affected_rows(mysql);
    if(result != Cache:0) cache_delete(result, mysql);
    if(error || affected != 1)
    {
        printf("[ADMIN] LEVEL_SAVE_FAILED actor=%d target=%d account=%d errno=%d affected=%d", playerid, targetid, GetPlayerAccountID(targetid), error, affected);
        return SendClientMessage(playerid, 0xFF5533FF, "Не удалось сохранить уровень. Изменение в игре не применено.");
    }
    // End observation while the old permission is still available to its cleanup function.
    if(GetPlayerSpectateData(targetid, S_PLAYER) != -1) StopSpectate(targetid);
    SetPlayerData(targetid, P_ADMIN, level);
    SetPlayerData(targetid, P_ADMIN_LOGGED, 0);
    format(GetPlayerData(targetid, P_PREFIX), 32, "%s", rank_name);
    SRAdmin_ClearTarget(targetid);
    DeletePVar(targetid, "SRAdmPinStep");
    new message[192];
    format(message, sizeof message, "[A] %s[%d] изменил уровень %s[%d]: %d -> %d", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(targetid), targetid, old_level, level);
    SendMessageToAdmins(message, 0xFF5533FF);
    SendClientMessage(targetid, 0xFF5533FF, message);
    printf("[ADMIN] LEVEL_CHANGED actor=%d actor_account=%d target=%d target_account=%d old=%d new=%d", playerid, GetPlayerAccountID(playerid), targetid, GetPlayerAccountID(targetid), old_level, level);
    new description[144], log_query[512];
    format(description, sizeof description, "Admin level: target=%s account=%d old=%d new=%d", GetPlayerNameEx(targetid), GetPlayerAccountID(targetid), old_level, level);
    mysql_format(mysql, log_query, sizeof log_query,
        "INSERT INTO action_log (acc_id,uip,type,description,time) VALUES (%d,'%e',%d,'%e',%d)",
        GetPlayerAccountID(playerid), GetPlayerIpEx(playerid), LOG_TYPE_SET_ADMIN, description, gettime());
    mysql_query(mysql, log_query, false);
    if(mysql_errno(mysql)) printf("[ADMIN] LEVEL_LOG_FAILED actor_account=%d target_account=%d errno=%d", GetPlayerAccountID(playerid), GetPlayerAccountID(targetid), mysql_errno(mysql));
    if(level > 0) SRAdmin_ShowLogin(targetid);
    return 1;
}

stock SRAdmin_OpenAssignment(playerid, targetid)
{
    SRAdmin_ClearTarget(playerid);
    if(!SRAdmin_Require(playerid, 9)) return 1;
    if(targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !IsPlayerLogged(targetid) || targetid == playerid)
        return SendClientMessage(playerid, 0xFF5533FF, "Недопустимый игрок.");
    if(SRAdmin_Level(targetid) > SRAdmin_Level(playerid)) return SendClientMessage(playerid, 0xFF5533FF, "У цели уровень выше вашего.");
    SetPVarInt(playerid, "SRAdmTargetPending", 1);
    SetPVarInt(playerid, "SRAdmTarget", targetid);
    SetPVarInt(playerid, "SRAdmTargetAccount", GetPlayerAccountID(targetid));
    SetPVarInt(playerid, "SRAdmTargetSession", g_SRAdminSession[targetid]);
    new list[640];
    for(new level = 1; level <= SR_ADMIN_MAX_LEVEL; level++)
    {
        strcat(list, g_SRAdminRank[level], sizeof list);
        if(level != SR_ADMIN_MAX_LEVEL) strcat(list, "\n", sizeof list);
    }
    return Dialog(playerid, DIALOG_SETADMINS, DIALOG_STYLE_LIST, "Назначение администратора", list, "Выбрать", "Отмена");
}

stock SRAdmin_AssignmentResponse(playerid, response, listitem)
{
    if(!GetPVarInt(playerid, "SRAdmTargetPending")) return 1;
    new targetid = GetPVarInt(playerid, "SRAdmTarget");
    new account = GetPVarInt(playerid, "SRAdmTargetAccount");
    new session = GetPVarInt(playerid, "SRAdmTargetSession");
    SRAdmin_ClearTarget(playerid);
    if(!response) return 1;
    if(!SRAdmin_Require(playerid, 9)) return 1;
    if(listitem < 0 || listitem >= SR_ADMIN_MAX_LEVEL) return 1;
    if(targetid < 0 || targetid >= MAX_PLAYERS || !IsPlayerConnected(targetid) || !IsPlayerLogged(targetid)) return 1;
    if(GetPlayerAccountID(targetid) != account || g_SRAdminSession[targetid] != session)
        return SendClientMessage(playerid, 0xFF5533FF, "Игрок переподключился. Выберите его заново.");
    return SRAdmin_ApplyLevel(playerid, targetid, listitem + 1, 9);
}
