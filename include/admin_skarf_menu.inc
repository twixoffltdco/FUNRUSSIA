// Donor admin chat/list and teleport flow, adapted to the current server's locations.
#if defined _sr_admin_menu_included
    #endinput
#endif
#define _sr_admin_menu_included

stock SRAdmin_WriteLog(playerid, log_type, text[])
{
    new query[1024];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO action_log (acc_id,uip,type,description,time) VALUES (%d,'%e',%d,'%e',%d)",
        GetPlayerAccountID(playerid), GetPlayerIpEx(playerid), log_type, text, gettime());
    mysql_query(mysql, query, false);
    if(mysql_errno(mysql))
    {
        printf("[ADMIN] LOG_FAILED player=%d account=%d type=%d errno=%d", playerid, GetPlayerAccountID(playerid), log_type, mysql_errno(mysql));
        return 0;
    }
    return 1;
}

stock SRAdmin_TeleportAllowed(playerid)
{
    if(!IsPlayerLogged(playerid)) return 0;
    // Donor permits YouTube staff as well. An account that is also an admin must enter its PIN.
    if(GetPlayerAdminEx(playerid) > 0) return SRAdmin_Require(playerid, 1);
    if(GetPlayerYouTubeEx(playerid) > 0) return 1;
    SendClientMessage(playerid, 0xFF5533FF, "Недостаточно прав для телепортации.");
    return 0;
}

stock SRAdmin_ViewerAuthorized(playerid)
{
    if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
    if(GetPlayerAdminEx(playerid) > 0) return SRAdmin_Level(playerid) >= 1 && GetPlayerData(playerid, P_ADMIN_LOGGED);
    return GetPlayerYouTubeEx(playerid) >= 1;
}

stock SRAdmin_ShowTeleports(playerid)
{
    DeletePVar(playerid, "SRTeleportPending");
    if(!SRAdmin_TeleportAllowed(playerid)) return 1;
    new list_text[64 * sizeof(g_teleport_list)], sr_tp_row[64];
    for(new i; i < sizeof(g_teleport_list); i++)
    {
        format(sr_tp_row, sizeof sr_tp_row, "%d. %s\n", i + 1, GetTeleportListData(i, TL_NAME));
        strcat(list_text, sr_tp_row, sizeof list_text);
    }
    SetPVarInt(playerid, "SRTeleportPending", 1);
    return Dialog(playerid, DIALOG_TELEPORT_LIST, DIALOG_STYLE_LIST,
        "Важные места", list_text, "Выбрать", "Назад");
}

stock SRAdmin_TeleportResponse(playerid, response, listitem)
{
    if(!GetPVarInt(playerid, "SRTeleportPending")) return 1;
    DeletePVar(playerid, "SRTeleportPending");
    if(!response) return 1;
    if(!SRAdmin_TeleportAllowed(playerid)) return 1;
    if(listitem < 0 || listitem >= sizeof(g_teleport_list)) return 1;
    // Donor teleports the player, not the vehicle. All listed destinations are in world/interior 0.
    if(GetPlayerSpectateData(playerid, S_PLAYER) != -1) StopSpectate(playerid);
    SetPlayerPosEx(playerid,
        GetTeleportListData(listitem, TL_POS_X), GetTeleportListData(listitem, TL_POS_Y),
        GetTeleportListData(listitem, TL_POS_Z), 0.0, 0, 0, false);
    SetPlayerInHouse(playerid, -1);
    SetPlayerInBiz(playerid, -1);
    TogglePlayerControllable(playerid, true);
    new description[128];
    format(description, sizeof description, "Teleport: index=%d name=%s", listitem, GetTeleportListData(listitem, TL_NAME));
    SRAdmin_WriteLog(playerid, LOG_TYPE_ADMIN_ACTION, description);
    printf("[ADMIN] TELEPORT player=%d account=%d destination=%d", playerid, GetPlayerAccountID(playerid), listitem);
    SendClientMessage(playerid, 0x66CC00FF, "Вы успешно телепортировались.");
    return 1;
}

stock SRAdmin_GetChatRankName(level, dest[], size)
{
    if(size <= 0) return 0;
    dest[0] = EOS;

    switch(level)
    {
        case 1: format(dest, size, "%s", ADM_LVL1_NAME);
        case 2: format(dest, size, "%s", ADM_LVL2_NAME);
        case 3: format(dest, size, "%s", ADM_LVL3_NAME);
        case 4: format(dest, size, "%s", ADM_LVL4_NAME);
        case 5: format(dest, size, "%s", ADM_LVL5_NAME);
        case 6: format(dest, size, "%s", ADM_LVL6_NAME);
        case 7: format(dest, size, "%s", ADM_LVL7_NAME);
        case 8: format(dest, size, "%s", ADM_LVL8_NAME);
        case 9: format(dest, size, "%s", ADM_LVL9_NAME);
        case 10: format(dest, size, "%s", ADM_LVL10_NAME);
        case 11: format(dest, size, "%s", ADM_LVL11_NAME);
        case 12: format(dest, size, "%s", ADM_LVL12_NAME);
        case 13: format(dest, size, "%s", ADM_LVL13_NAME);
        default: return 0;
    }
    return 1;
}

stock SRAdmin_Chat(playerid, params[])
{
    // /a доступен только реальному администратору с валидным уровнем и после входа в админ-панель.
    if(!SRAdmin_Require(playerid, 1)) return 1;

    new admin_level = SRAdmin_Level(playerid);
    if(admin_level < 1 || admin_level > SR_ADMIN_MAX_LEVEL)
        return SendClientMessage(playerid, 0xFF5533FF, "Некорректный уровень администратора. Доступ к /a запрещён."), 1;

    if(!strlen(params)) return SendClientMessage(playerid, -1, "Используйте: /a [текст]");
    // Reject overlong input instead of silently cutting a moderation message.
    if(strlen(params) > 80) return SendClientMessage(playerid, -1, "Сообщение админ-чата: не более 80 символов.");

    new rank_name[48], message[192];
    if(!SRAdmin_GetChatRankName(admin_level, rank_name, sizeof rank_name))
        return SendClientMessage(playerid, 0xFF5533FF, "Не удалось определить должность администратора."), 1;

    // Пользовательский P_PREFIX здесь намеренно не используется: /a всегда показывает должность фактического admin lvl.
    format(message, sizeof message, "[%s] %s[%d]: %s", rank_name, GetPlayerNameEx(playerid), playerid, params);

    foreach(new targetid : Player)
    {
        if(!IsPlayerLogged(targetid)) continue;
        if(!GetPlayerData(targetid, P_ADMIN_LOGGED)) continue;
        new target_level = SRAdmin_Level(targetid);
        if(target_level < 1 || target_level > SR_ADMIN_MAX_LEVEL) continue;
        SendClientMessage(targetid, 0x40E0D0FF, message);
    }

    SRAdmin_WriteLog(playerid, LOG_TYPE_ADMIN_CHAT, message);
    return 1;
}

stock SRAdmin_CanSeeList(playerid)
{
    if(!IsPlayerLogged(playerid)) return 0;
    if(GetPlayerAdminEx(playerid) > 0 && !SRAdmin_Require(playerid, 1)) return 0;
    // This VIP restriction is present in the donor's /admins, including for admin accounts.
    new vip = GetPlayerPremium(playerid);
    if(vip < 1 || vip > 3)
    {
        SendClientMessage(playerid, 0xCECECEFF, "У Вас нет VIP аккаунта.");
        return 0;
    }
    return 1;
}

stock SRAdmin_ShowList(playerid, page)
{
    DeletePVar(playerid, "SRAdminsPending");
    if(!SRAdmin_CanSeeList(playerid)) return 1;
    if(page < 0 || page > MAX_PLAYERS / 20) return 1;
    new total;
    foreach(new i : Player)
        if(IsPlayerLogged(i) && (SRAdmin_Level(i) > 0 || GetPlayerYouTubeEx(i) > 0)) total++;
    new last_page = total > 0 ? (total - 1) / 20 : 0;
    if(page > last_page) page = last_page;
    new list[4096] = "Никнейм\tДолжность\tИнформация\n", row[160], rank_name[32];
    new position, shown, from = page * 20;
    foreach(new i : Player)
    {
        if(!IsPlayerLogged(i)) continue;
        new level = SRAdmin_Level(i);
        if(!level && GetPlayerYouTubeEx(i) == 0) continue;
        if(position++ < from) continue;
        if(shown == 20) break;
        if(level > 0) format(rank_name, sizeof rank_name, "%s", g_SRAdminRank[level]);
        else format(rank_name, sizeof rank_name, "Ютубер");
        format(row, sizeof row, "%s[%d]\t%s\tв игре\n", GetPlayerNameEx(i), i, rank_name);
        strcat(list, row, sizeof list);
        shown++;
    }
    new previous = -1, next = -1;
    if(total == 0)
    {
        strcat(list, "Администрация не найдена\t-\t-\n", sizeof list);
        shown = 1;
    }
    if(page > 0)
    {
        previous = shown++;
        strcat(list, "Предыдущая страница\t\t\n", sizeof list);
    }
    if(page < last_page)
    {
        next = shown;
        strcat(list, "Следующая страница\t\t\n", sizeof list);
    }
    SetPVarInt(playerid, "SRAdminsPage", page);
    SetPVarInt(playerid, "SRAdminsPrevious", previous);
    SetPVarInt(playerid, "SRAdminsNext", next);
    SetPVarInt(playerid, "SRAdminsPending", 1);
    new title[64];
    format(title, sizeof title, "Администрация в сети (стр. %d)", page + 1);
    return Dialog(playerid, DIALOG_ADMINS, DIALOG_STYLE_TABLIST_HEADERS, title, list, "Выбрать", "Закрыть");
}

stock SRAdmin_ListResponse(playerid, response, listitem)
{
    if(!GetPVarInt(playerid, "SRAdminsPending")) return 0;
    DeletePVar(playerid, "SRAdminsPending");
    if(!response) return 1;
    if(!SRAdmin_CanSeeList(playerid)) return 1;
    if(listitem < 0) return 1;
    new page = GetPVarInt(playerid, "SRAdminsPage");
    if(listitem == GetPVarInt(playerid, "SRAdminsPrevious")) SRAdmin_ShowList(playerid, page - 1);
    else if(listitem == GetPVarInt(playerid, "SRAdminsNext")) SRAdmin_ShowList(playerid, page + 1);
    return 1;
}

stock SRAdmin_TeleportTarget(playerid, targetid)
{
    if(!SRAdmin_TeleportAllowed(playerid)) return 0;
    if(targetid < 0 || targetid >= MAX_PLAYERS || targetid == playerid || !IsPlayerConnected(targetid) || !IsPlayerLogged(targetid))
    {
        SendClientMessage(playerid, -1, "Укажите другого игрока, который уже вошёл в игру.");
        return 0;
    }
    if(GetPlayerSecretEx(targetid) >= 1)
    {
        SendClientMessage(playerid, -1, "У игрока включена привилегия скрытности.");
        return 0;
    }
    return 1;
}

// Internal movement primitive; commands/offer callbacks validate rights before calling it.
stock SRAdmin_MoveNear(actorid, movingid, anchorid)
{
    if(GetPlayerSpectateData(movingid, S_PLAYER) != -1) StopSpectate(movingid);
    new Float:x, Float:y, Float:z;
    GetPlayerPos(anchorid, x, y, z);
    SetPlayerPosEx(movingid, x + 1.0, y + 1.0, z, 0.0, GetPlayerInterior(anchorid), GetPlayerVirtualWorld(anchorid), false);
    SetPlayerInHouse(movingid, GetPlayerInHouse(anchorid));
    SetPlayerInBiz(movingid, GetPlayerInBiz(anchorid));
    TogglePlayerControllable(movingid, true);
    new message[192];
    format(message, sizeof message, "[A] %s[%d] телепортировал %s[%d] к %s[%d]", GetPlayerNameEx(actorid), actorid, GetPlayerNameEx(movingid), movingid, GetPlayerNameEx(anchorid), anchorid);
    SendMessageToAdmins(message, 0x999999FF);
    SRAdmin_WriteLog(actorid, LOG_TYPE_ADMIN_ACTION, message);
    SendClientMessage(actorid, 0x66CC00FF, "Телепортация выполнена.");
    if(movingid != actorid) SendClientMessage(movingid, 0x66CC00FF, "Вы телепортированы администратором.");
    else SendClientMessage(anchorid, 0x66CC00FF, "К вам телепортировался администратор.");
    printf("[ADMIN] TELEPORT actor=%d account=%d moving=%d anchor=%d", actorid, GetPlayerAccountID(actorid), movingid, anchorid);
    return 1;
}
