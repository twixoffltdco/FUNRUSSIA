#if defined _auth_brpro_included
    #endinput
#endif
#define _auth_brpro_included

// Br pro GUI 38, adapted to the current account API and lram.apk.
// DEX UILayoutRegistrationSex$3: r = isMaleActive XOR 1.
// DEX UILayoutRegistrationPerson: i/r contain MODEL IDs, not array indices.
new const g_BRAuthMaleSkins[] = {78,79,134,136,230,158,159,71,161};
new const g_BRAuthFemaleSkins[] = {77,135,137,212,239,218};

forward BRAuth_KickStaleSafe(playerid, auth_epoch);
public BRAuth_KickStaleSafe(playerid, auth_epoch)
{
    if(IsPlayerConnected(playerid) && auth_epoch == g_BRAuthEpoch[playerid]) Kick(playerid);
    return 1;
}

stock BRAuth_Reset(playerid)
{
    g_BRAuthStage[playerid] = BR_AUTH_CHECK;
    g_BRAuthVerified[playerid] = false;
    g_BRAuthNewAccount[playerid] = false;
    g_BRAuthPreview[playerid] = -1;
    g_BRAuthEpoch[playerid]++;
    CheckPass[playerid][0] = EOS;
    DeletePVar(playerid, "registration_sex");
    return 1;
}

// Mobile clients keep GUI 38 state across an automatic reconnect.  Always
// close the previous authorization instance before creating a new session.
stock BRAuth_ResetClient(playerid)
{
    HidePlayerGUI(playerid, 38);
    return 1;
}

stock BRAuth_Error(playerid, const stage[], message[])
{
    printf("[AUTH][ERROR] stage=%s player=%d account=%d errno=%d", stage, playerid, GetPlayerAccountID(playerid), mysql_errno(mysql));
    ShowNotificationNew(playerid, 2, 5, -1, -1, message, "");
    return 0;
}

stock BRAuth_Ack(playerid)
{
    new Node:reply = JSON_Object();
    JSON_SetInt(reply, "t", 0);
    OnPacketIncoming(playerid, 38, reply);
    JSON_Cleanup(reply);
    return 1;
}

stock BRAuth_Open(playerid, bool:login)
{
    new Node:reply = JSON_Object();
    JSON_SetInt(reply, "o", 1);
    JSON_SetInt(reply, "r", login ? 1 : 0);
    ShowPlayerGUI(playerid, 38, reply);
    JSON_Cleanup(reply);
    printf("[AUTH][OPEN] player=%d account=%d login=%d", playerid, GetPlayerAccountID(playerid), login);
    return 1;
}

stock bool:BRAuth_AllowedSkin(sex, skin)
{
    if(sex == 0)
    {
        for(new i; i < sizeof g_BRAuthMaleSkins; i++)
            if(g_BRAuthMaleSkins[i] == skin) return true;
    }
    else if(sex == 1)
    {
        for(new i; i < sizeof g_BRAuthFemaleSkins; i++)
            if(g_BRAuthFemaleSkins[i] == skin) return true;
    }
    return false;
}

stock BRAuth_Camera(playerid)
{
    if(!IsPlayerConnected(playerid) || IsPlayerLogged(playerid) || g_BRAuthStage[playerid] != BR_AUTH_SKIN) return 0;
    SetPlayerVirtualWorld(playerid, playerid + 0xFF);
    SetPlayerInterior(playerid, 1);
    SetPlayerPos(playerid, 1200.399902, 607.876281, 1349.309448);
    SetPlayerFacingAngle(playerid, 184.824386);
    SetPlayerCameraPos(playerid, 1201.510253, 604.738281, 1350.530395);
    SetPlayerCameraLookAt(playerid, 1193.910253, 630.0, 1342.530395);
    if(BRAuth_AllowedSkin(GetPlayerSex(playerid), g_BRAuthPreview[playerid]))
        SetPlayerSkin(playerid, g_BRAuthPreview[playerid]);
    TogglePlayerControllable(playerid, false);
    return 1;
}

stock bool:BRAuth_CheckBan(playerid)
{
    new query[144];
    mysql_format(mysql, query, sizeof query, "SELECT unban_time FROM listban WHERE acc_id=%d LIMIT 1", GetPlayerAccountID(playerid));
    new Cache:result = mysql_query(mysql, query);
    if(mysql_errno(mysql))
    {
        if(result) cache_delete(result);
        BRAuth_Error(playerid, "BAN_CHECK", "Не удалось проверить аккаунт. Повторите вход позже.");
        return false;
    }
    new bool:blocked = false;
    if(cache_num_rows(result))
    {
        new expires = cache_get_field_content_int(0, "unban_time");
        blocked = (expires <= 0 || expires > gettime());
    }
    cache_delete(result);
    if(blocked)
    {
        g_BRAuthStage[playerid] = BR_AUTH_BLOCKED;
        ShowNotificationNew(playerid, 2, 10, -1, -1, "Ваш аккаунт заблокирован администрацией.", "");
        printf("[AUTH][DENIED] player=%d account=%d reason=ban", playerid, GetPlayerAccountID(playerid));
        Kick:(playerid);
        return false;
    }
    return true;
}

stock BRAuth_Login(playerid, password[])
{
    if(!IsPlayerConnected(playerid) || IsPlayerLogged(playerid) || g_BRAuthStage[playerid] != BR_AUTH_LOGIN) return 0;
    if(GetPlayerData(playerid, P_ACCOUNT_STATE) != ACCOUNT_STATE_LOGIN || GetPlayerAccountID(playerid) <= 0) return 0;
    new hash[65], length = strlen(password);
    // Old accounts may have passwords shorter than the new registration minimum.
    if(length > 0 && length <= 64)
        SHA256_PassHash(password, GetPlayerData(playerid, P_SALT), hash, sizeof hash);
    if(!length || length > 64 || !hash[0] || strcmp(hash, GetPlayerData(playerid, P_PASSWORD), false))
    {
        AddPlayerData(playerid, P_PASS_ATTEMPS, -, 1);
        printf("[AUTH][DENIED] player=%d reason=password attempts_left=%d", playerid, GetPlayerData(playerid, P_PASS_ATTEMPS));
        ShowNotificationNew(playerid, 2, 5, -1, -1, "Неверный пароль!", "");
        if(GetPlayerData(playerid, P_PASS_ATTEMPS) <= 0)
        {
            g_BRAuthStage[playerid] = BR_AUTH_BLOCKED;
            Kick:(playerid);
        }
        return 0;
    }
    if(!BRAuth_CheckBan(playerid)) return 0;
    g_BRAuthVerified[playerid] = true;
    g_BRAuthStage[playerid] = BR_AUTH_LOADING;
    CheckPass[playerid][0] = EOS;
    // Keep this project's optional phone/PIN checks and post-login loader.
    BRAuth_Ack(playerid);
    StopAudioStream(playerid);
    return ShowPlayerLoginDialog(playerid, LOGIN_STATE_PHONE, false);
}

stock BRAuth_InsertAccount(playerid)
{
    if(!IsPlayerConnected(playerid) || IsPlayerLogged(playerid) || g_BRAuthStage[playerid] != BR_AUTH_LOADING) return 0;
    if(GetPlayerAccountID(playerid) > 0 || !BRAuth_AllowedSkin(GetPlayerSex(playerid), GetPlayerData(playerid, P_SKIN))) return 0;
    new length = strlen(CheckPass[playerid]);
    if(length < 6 || length > 32) return 0;
    new query[1536], lock_name[48], Cache:result;
    format(lock_name, sizeof lock_name, "br_auth_%s", GetPlayerNameEx(playerid));
    // accounts.name is not UNIQUE in this dump. Serialize same-name creation
    // without altering the schema or deleting any historical duplicate rows.
    mysql_format(mysql, query, sizeof query, "SELECT GET_LOCK('%e',0) AS acquired", lock_name);
    result = mysql_query(mysql, query);
    new acquired;
    if(!mysql_errno(mysql) && cache_num_rows(result)) acquired = cache_get_field_content_int(0, "acquired");
    if(result) cache_delete(result);
    if(acquired != 1) return BRAuth_Error(playerid, "CREATE_LOCK", "Регистрация сейчас недоступна. Переподключитесь.");

    new now = gettime();
    for(new i; i < 10; i++) g_player[playerid][P_SALT][i] = random(79) + 47;
    g_player[playerid][P_SALT][10] = EOS;
    SHA256_PassHash(CheckPass[playerid], GetPlayerData(playerid, P_SALT), GetPlayerData(playerid, P_PASSWORD), 65);
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO accounts (name,password,salt,email,refer,sex,skin,reg_time,reg_ip,last_ip,last_login,money,rub,level,premium,premium_date,car_slots,driving_lic,weapon_lic,case_rewards,case_bonus_rewards) " \
        "SELECT '%e','%e','%e','%e',%d,%d,%d,%d,'%e','%e',%d,%d,%d,%d,%d,%d,20,1,1,'','' FROM DUAL WHERE NOT EXISTS (SELECT id FROM accounts WHERE name='%e')",
        GetPlayerNameEx(playerid), GetPlayerData(playerid, P_PASSWORD), GetPlayerData(playerid, P_SALT), GetPlayerData(playerid, P_EMAIL),
        GetPlayerData(playerid, P_REFER), GetPlayerSex(playerid), GetPlayerData(playerid, P_SKIN), now,
        GetPlayerIpEx(playerid), GetPlayerIpEx(playerid), now, bonus_money, bonus_donate, bonus_lvl, vip_type, now + 30 * 86400, GetPlayerNameEx(playerid));
    printf("[AUTH][CREATE] player=%d sex=%d skin=%d", playerid, GetPlayerSex(playerid), GetPlayerData(playerid, P_SKIN));
    result = mysql_query(mysql, query);
    new error = mysql_errno(mysql), account_id;
    if(!error && cache_affected_rows() == 1) account_id = cache_insert_id();
    if(result) cache_delete(result);
    mysql_format(mysql, query, sizeof query, "SELECT RELEASE_LOCK('%e')", lock_name);
    result = mysql_query(mysql, query);
    if(result) cache_delete(result);
    CheckPass[playerid][0] = EOS;
    if(error || account_id <= 0)
    {
        printf("[AUTH][ERROR] stage=INSERT player=%d errno=%d inserted_id=%d", playerid, error, account_id);
        return 0;
    }
    SetPlayerData(playerid, P_ACCOUNT_ID, account_id);
    SetPlayerData(playerid, P_REG_TIME, now);
    SetPlayerData(playerid, P_LAST_LOGIN_TIME, now);
    g_BRAuthVerified[playerid] = true;
    g_BRAuthNewAccount[playerid] = true;
    printf("[AUTH][CREATED] player=%d account=%d", playerid, account_id);
    return account_id;
}

stock BRAuth_FinishSkin(playerid, skin)
{
    if(!IsPlayerConnected(playerid) || IsPlayerLogged(playerid) || g_BRAuthStage[playerid] != BR_AUTH_SKIN) return 0;
    if(!BRAuth_AllowedSkin(GetPlayerSex(playerid), skin))
    {
        printf("[AUTH][SKIN_REJECT] player=%d sex=%d model=%d", playerid, GetPlayerSex(playerid), skin);
        return BRAuth_Error(playerid, "SKIN", "Выбранная внешность не поддерживается. Повторите вход.");
    }
    g_BRAuthStage[playerid] = BR_AUTH_LOADING;
    SetPlayerData(playerid, P_SKIN, skin);
    if(GetPlayerAccountID(playerid) <= 0)
    {
        if(!CreatePlayerAccount(playerid))
        {
            g_BRAuthStage[playerid] = BR_AUTH_BLOCKED;
            return BRAuth_Error(playerid, "CREATE", "Не удалось создать аккаунт. Переподключитесь и проверьте вход.");
        }
    }
    else
    {
        if(!g_BRAuthVerified[playerid]) return 0;
        // Complete an old interrupted registration; never award bonuses twice.
        new query[160];
        mysql_format(mysql, query, sizeof query, "UPDATE accounts SET sex=%d,skin=%d WHERE id=%d AND skin=0 LIMIT 1", GetPlayerSex(playerid), skin, GetPlayerAccountID(playerid));
        mysql_query(mysql, query, false);
        if(mysql_errno(mysql))
        {
            g_BRAuthStage[playerid] = BR_AUTH_BLOCKED;
            return BRAuth_Error(playerid, "SKIN_SAVE", "Не удалось сохранить внешность. Переподключитесь.");
        }
    }
    SetPlayerData(playerid, P_SELECT_SKIN, -1);
    SetPlayerData(playerid, P_ACCOUNT_STATE, ACCOUNT_STATE_LOGIN);
    SetPlayerData(playerid, P_AUTH_TIME, -1);
    HidePlayerSelectPanel(playerid);
    HidePlayerSelectPanelPrice(playerid);
    HidePlayerGUI(playerid, 38);
    StopAudioStream(playerid);
    TogglePlayerControllable(playerid, true);
    SetCameraBehindPlayer(playerid);
    // Uses the ORIGINAL loader and spawn-choice GUI, including all game data.
    return LoadPlayerData(playerid);
}

stock PacketIncomingAuthReg(playerid, Node:json)
{
    if(!IsPlayerConnected(playerid) || IsPlayerLogged(playerid) || g_BRAuthStage[playerid] == BR_AUTH_BLOCKED) return 1;
    if(JSON_GetType(json, "t") != JSON_NODE_NUMBER) return 0;
    new action = -999;
    JSON_GetInt(json, "t", action);
    switch(action)
    {
        case 1:
        {
            if(g_BRAuthStage[playerid] != BR_AUTH_PASSWORD) return 1;
            if(JSON_GetType(json, "p") != JSON_NODE_STRING) return 0;
            new password[66], email[62];
            JSON_GetString(json, "p", password, sizeof password);
            JSON_GetString(json, "s", email, sizeof email);
            new length = strlen(password);
            if(length < 6 || length > 32) return BRAuth_Error(playerid, "PASSWORD", "Пароль должен быть от 6 до 32 символов.");
            if(strlen(email) > 60) return BRAuth_Error(playerid, "EMAIL", "Email слишком длинный.");
            format(CheckPass[playerid], sizeof CheckPass[], "%s", password);
            if(email[0]) format(g_player[playerid][P_EMAIL], 61, "%s", email);
            g_BRAuthStage[playerid] = BR_AUTH_SEX;
            printf("[AUTH][PASSWORD_RECEIVED] player=%d", playerid);
            return BRAuth_Ack(playerid);
        }
        case 2:
        {
            // Client fingerprint step: acknowledge navigation, do not enable
            // passwordless login or trust a client-side authentication flag.
            if(g_BRAuthStage[playerid] != BR_AUTH_SEX) return 1;
            return BRAuth_Ack(playerid);
        }
        case 3:
        {
            if(g_BRAuthStage[playerid] != BR_AUTH_SEX) return 1;
            new sex = -1;
            if(JSON_GetType(json, "r") != JSON_NODE_NUMBER) return BRAuth_Error(playerid, "SEX", "Не получен выбор пола.");
            JSON_GetInt(json, "r", sex);
            if(sex != 0 && sex != 1) return BRAuth_Error(playerid, "SEX", "Некорректный выбор пола.");
            SetPlayerData(playerid, P_SEX, sex);
            g_BRAuthPreview[playerid] = sex ? g_BRAuthFemaleSkins[0] : g_BRAuthMaleSkins[0];
            g_BRAuthStage[playerid] = BR_AUTH_SKIN;
            SetPlayerData(playerid, P_ACCOUNT_STATE, ACCOUNT_STATE_REG_SKIN);
            printf("[AUTH][SEX] player=%d raw=%d stored=%d", playerid, sex, GetPlayerSex(playerid));
            SetSpawnInfo(playerid, 0, g_BRAuthPreview[playerid], 1200.399902,607.876281,1349.309448,184.824386,0,0,0,0,0,0);
            SpawnPlayer(playerid);
            BRAuth_Camera(playerid);
            return BRAuth_Ack(playerid);
        }
        case -1:
        {
            if(g_BRAuthStage[playerid] != BR_AUTH_SKIN) return 1;
            new skin = -1;
            if(JSON_GetType(json, "i") != JSON_NODE_NUMBER) return 0;
            JSON_GetInt(json, "i", skin);
            if(!BRAuth_AllowedSkin(GetPlayerSex(playerid), skin)) return BRAuth_Error(playerid, "PREVIEW", "Недопустимая внешность персонажа.");
            g_BRAuthPreview[playerid] = skin;
            BRAuth_Camera(playerid);
            printf("[AUTH][PREVIEW] player=%d sex=%d skin=%d", playerid, GetPlayerSex(playerid), skin);
        }
        case 4:
        {
            if(g_BRAuthStage[playerid] != BR_AUTH_SEX && g_BRAuthStage[playerid] != BR_AUTH_SKIN) return 1;
            new nickname[MAX_PLAYER_NAME + 1], query[144], refer;
            JSON_GetString(json, "s", nickname, sizeof nickname);
            if(nickname[0])
            {
                if(strlen(nickname) >= MAX_PLAYER_NAME) return BRAuth_Error(playerid, "REFER", "Некорректный ник пригласившего игрока.");
                mysql_format(mysql, query, sizeof query, "SELECT id FROM accounts WHERE name='%e' LIMIT 1", nickname);
                new Cache:result = mysql_query(mysql, query);
                new error = mysql_errno(mysql);
                if(!error && cache_num_rows(result)) refer = cache_get_field_content_int(0, "id");
                if(result) cache_delete(result);
                if(error || !refer) return BRAuth_Error(playerid, "REFER", "Не удалось найти пригласившего игрока.");
            }
            SetPlayerData(playerid, P_REFER, refer);
            return BRAuth_Ack(playerid);
        }
        case 5:
        {
            if(g_BRAuthStage[playerid] != BR_AUTH_SKIN) return 1;
            new skin = -1;
            if(JSON_GetType(json, "r") != JSON_NODE_NUMBER) return BRAuth_Error(playerid, "SKIN", "Не получен выбранный скин.");
            JSON_GetInt(json, "r", skin);
            return BRAuth_FinishSkin(playerid, skin);
        }
        case 6:
        {
            if(JSON_GetType(json, "s") != JSON_NODE_STRING) return 0;
            new password[66];
            JSON_GetString(json, "s", password, sizeof password);
            return BRAuth_Login(playerid, password);
        }
    }
    return 1;
}
