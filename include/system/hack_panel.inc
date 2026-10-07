// PHOTON | DEV / HACK PANEL
// Adapted for photon.pwn. Uses only functions/data already present in the mod.

#define DIALOG_PHOTON_HACK_MAIN      29981
#define DIALOG_PHOTON_HACK_SKIN      29982
#define DIALOG_PHOTON_HACK_PLATE     29983
#define DIALOG_PHOTON_HACK_SPEED     29984
#define DIALOG_PHOTON_HACK_ACCEL     29985
#define DIALOG_PHOTON_HACK_GRAVITY   29986

new gPhotonHackPendingAction[MAX_PLAYERS];
new gPhotonHackPendingInt[MAX_PLAYERS];
new Float:gPhotonHackPendingFloat[MAX_PLAYERS];
new gPhotonHackPendingText[MAX_PLAYERS][32];

stock PhotonHack_Notify(playerid, type, text[])
{
    ShowNotificationNew(playerid, type, 5, 0, 0, text, "OK");
    return 1;
}

stock ShowPhotonHackPanel(playerid)
{
    new menu[1024];
    menu[0] = 0;

    strcat(menu, "{FF3D00}1. {FFFFFF}\xCF\xEE\xEB\xF3\xF7\xE8\xF2\xFC 1.000.000 \xE4\xEE\xED\xE0\xF2-\xF0\xF3\xE1\xEB\xE5\xE9\n");
    strcat(menu, "{FF3D00}2. {FFFFFF}\xCF\xEE\xEB\xF3\xF7\xE8\xF2\xFC 100.000.000 \xF0\xF3\xE1\xEB\xE5\xE9\n");
    strcat(menu, "{FF3D00}3. {FFFFFF}\xCF\xEE\xEB\xF3\xF7\xE8\xF2\xFC 100 \xE4\xEE\xED\xE0\xF2-\xEA\xE5\xE9\xF1\xEE\xE2\n");
    strcat(menu, "{FF3D00}4. {FFFFFF}\xC8\xE7\xEC\xE5\xED\xE8\xF2\xFC \xF1\xE2\xEE\xE9 \xF1\xEA\xE8\xED\n");
    strcat(menu, "{FF3D00}5. {FFFFFF}\xC8\xE7\xEC\xE5\xED\xE8\xF2\xFC \xED\xEE\xEC\xE5\xF0 \xED\xE0 \xEC\xE0\xF8\xE8\xED\xE5\n");
    strcat(menu, "{FF3D00}6. {FFFFFF}\xC8\xE7\xEC\xE5\xED\xE8\xF2\xFC \xEC\xE0\xEA\xF1\xE8\xEC\xE0\xEB\xFC\xED\xF3\xFE \xF1\xEA\xEE\xF0\xEE\xF1\xF2\xFC\n");
    strcat(menu, "{FF3D00}7. {FFFFFF}\xC8\xE7\xEC\xE5\xED\xE8\xF2\xFC \xF3\xF1\xEA\xEE\xF0\xE5\xED\xE8\xE5 \xEC\xE0\xF8\xE8\xED\xFB\n");
    strcat(menu, "{FF3D00}8. {FFFFFF}\xC8\xE7\xEC\xE5\xED\xE8\xF2\xFC \xE3\xF0\xE0\xE2\xE8\xF2\xE0\xF6\xE8\xFE \xF1\xE5\xF0\xE2\xE5\xF0\xE0");

    Dialog(playerid, DIALOG_PHOTON_HACK_MAIN, DIALOG_STYLE_LIST,
        "{FF3D00}PHOTON {FFFFFF}| \xCF\xE0\xED\xE5\xEB\xFC \xF0\xE0\xE7\xF0\xE0\xE1\xEE\xF2\xF7\xE8\xEA\xE0",
        menu,
        "\xC2\xFB\xE1\xF0\xE0\xF2\xFC", "\xC7\xE0\xEA\xF0\xFB\xF2\xFC");
    return 1;
}

stock PhotonHack_StartProgress(playerid, action)
{
    if(gPhotonHackPendingAction[playerid] != 0)
    {
        PhotonHack_Notify(playerid, 2, "Предыдущий запрос еще выполняется.");
        return 1;
    }

    gPhotonHackPendingAction[playerid] = action;
    ShowNotificationNew(playerid, 3, 2, 0, 0, "Обработка запроса...", " ");
    SetTimerEx("PhotonHackCompleteAction", 1200, false, "i", playerid);
    return 1;
}

forward PhotonHackCompleteAction(playerid);
public PhotonHackCompleteAction(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(!IsPlayerLogged(playerid)) return 0;

    new action = gPhotonHackPendingAction[playerid];
    gPhotonHackPendingAction[playerid] = 0;

    if(action == 0) return 1;

    new notify_text[144];
    notify_text[0] = EOS;

    switch(action)
    {
        case 1:
        {
            // In photon there is no player_black_coin field. The closest native
            // currency used by the mod is P_DONATE_RUB, so give real donate rubles.
            GivePlayerDonateRub(playerid, 1000000, "PHOTON DEV PANEL", true, false);
            format(notify_text, sizeof notify_text,
                "Вы получили 1.000.000 донат-рублей.");
        }
        case 2:
        {
            GivePlayerMoneyEx(playerid, 100000000,
                "PHOTON DEV PANEL", true, true);
            format(notify_text, sizeof notify_text,
                "Вы получили 100.000.000 рублей.");
        }
        case 3:
        {
            AddPlayerData(playerid, P_DONATE_CASE, +, 100);
            format(notify_text, sizeof notify_text,
                "Вы получили 100 донат-кейсов.");
        }
        case 4:
        {
            new skin = gPhotonHackPendingInt[playerid];
            if(skin < 0 || skin > 311)
            {
                format(notify_text, sizeof notify_text,
                    "Некорректный ID скина. Допустимо: 0-311.");
            }
            else
            {
                SetPlayerSkin(playerid, skin);
                SetPlayerData(playerid, P_SKIN, skin);
                UpdatePlayerDatabaseInt(playerid, "skin", skin);
                format(notify_text, sizeof notify_text,
                    "Скин успешно изменен на ID %d.", skin);
            }
        }
        case 5:
        {
            new vehicleid = GetPlayerVehicleID(playerid);
            if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid))
            {
                format(notify_text, sizeof notify_text,
                    "Сначала сядьте в транспорт.");
            }
            else if(strlen(gPhotonHackPendingText[playerid]) < 1 ||
                strlen(gPhotonHackPendingText[playerid]) > 15)
            {
                format(notify_text, sizeof notify_text,
                    "Номер должен содержать от 1 до 15 символов.");
            }
            else
            {
                SetVehicleNumberPlateEx(vehicleid, TYPE_RU,
                    gPhotonHackPendingText[playerid], "");

                if(GetVehicleData(vehicleid, V_ACTION_TYPE) ==
                    VEHICLE_ACTION_TYPE_OWNABLE_CAR)
                {
                    new car_index = GetVehicleData(vehicleid, V_ACTION_ID);
                    if(0 <= car_index < MAX_OWNABLE_CARS)
                    {
                        format(g_ownable_car[car_index][OC_NUMBER], 32, "%s",
                            gPhotonHackPendingText[playerid]);

                        new q[192];
                        mysql_format(mysql, q, sizeof q,
                            "UPDATE ownable_cars SET number='%e' WHERE id=%d LIMIT 1",
                            gPhotonHackPendingText[playerid],
                            GetOwnableCarData(car_index, OC_SQL_ID));
                        mysql_query(mysql, q, false);
                    }
                }

                format(notify_text, sizeof notify_text,
                    "Номер автомобиля успешно изменен.");
            }
        }
        case 6:
        {
            new vehicleid = GetPlayerVehicleID(playerid);
            if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid))
            {
                format(notify_text, sizeof notify_text,
                    "Сначала сядьте в транспорт.");
            }
            else
            {
                SetVehicleMaxSpeed(vehicleid, gPhotonHackPendingFloat[playerid]);
                SetVehicleMaxSpeedd(vehicleid, gPhotonHackPendingFloat[playerid]);

                foreach(new i : Player)
                {
                    if(IsPlayerConnected(i))
                    {
                        SetVehicleMaxSpeedForPlayer(i, vehicleid,
                            gPhotonHackPendingFloat[playerid]);
                    }
                }

                format(notify_text, sizeof notify_text,
                    "Максимальная скорость автомобиля изменена.");
            }
        }
        case 7:
        {
            new vehicleid = GetPlayerVehicleID(playerid);
            if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid))
            {
                format(notify_text, sizeof notify_text,
                    "Сначала сядьте в транспорт.");
            }
            else
            {
                SetVehicleAcceleration(vehicleid,
                    gPhotonHackPendingFloat[playerid]);
                SetVehicleAccelerations(vehicleid,
                    gPhotonHackPendingFloat[playerid], 0);

                format(notify_text, sizeof notify_text,
                    "Ускорение автомобиля успешно изменено.");
            }
        }
        case 8:
        {
            SetGravity(gPhotonHackPendingFloat[playerid]);
            format(notify_text, sizeof notify_text,
                "Гравитация сервера изменена на %.4f.",
                gPhotonHackPendingFloat[playerid]);
        }
    }

    PhotonHack_Notify(playerid, 3, notify_text);
    return 1;
}

stock PhotonHack_HandleDialog(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_PHOTON_HACK_MAIN)
    {
        if(!response) return 1;

        switch(listitem)
        {
            case 0: return PhotonHack_StartProgress(playerid, 1);
            case 1: return PhotonHack_StartProgress(playerid, 2);
            case 2: return PhotonHack_StartProgress(playerid, 3);

            case 3:
            {
                return Dialog(playerid, DIALOG_PHOTON_HACK_SKIN,
                    DIALOG_STYLE_INPUT,
                    "{FF3D00}PHOTON {FFFFFF}| Изменение скина",
                    "Введите ID скина от 0 до 311:",
                    "Изменить", "Назад");
            }
            case 4:
            {
                return Dialog(playerid, DIALOG_PHOTON_HACK_PLATE,
                    DIALOG_STYLE_INPUT,
                    "{FF3D00}PHOTON {FFFFFF}| Номер автомобиля",
                    "Введите номер длиной от 1 до 15 символов:",
                    "Изменить", "Назад");
            }
            case 5:
            {
                return Dialog(playerid, DIALOG_PHOTON_HACK_SPEED,
                    DIALOG_STYLE_INPUT,
                    "{FF3D00}PHOTON {FFFFFF}| Максимальная скорость",
                    "Введите значение от 50 до 500:",
                    "Изменить", "Назад");
            }
            case 6:
            {
                return Dialog(playerid, DIALOG_PHOTON_HACK_ACCEL,
                    DIALOG_STYLE_INPUT,
                    "{FF3D00}PHOTON {FFFFFF}| Ускорение",
                    "Введите значение от 0.1 до 10.0:",
                    "Изменить", "Назад");
            }
            case 7:
            {
                return Dialog(playerid, DIALOG_PHOTON_HACK_GRAVITY,
                    DIALOG_STYLE_INPUT,
                    "{FF3D00}PHOTON {FFFFFF}| Гравитация",
                    "Введите значение от 0.001 до 0.050:",
                    "Изменить", "Назад");
            }
        }
        return 1;
    }

    if(dialogid == DIALOG_PHOTON_HACK_SKIN)
    {
        if(!response) return ShowPhotonHackPanel(playerid);
        if(!strlen(inputtext)) return 1;

        new value = strval(inputtext);
        if(value < 0 || value > 311)
        {
            PhotonHack_Notify(playerid, 2, "Введите ID скина от 0 до 311.");
            return 1;
        }

        gPhotonHackPendingInt[playerid] = value;
        return PhotonHack_StartProgress(playerid, 4);
    }

    if(dialogid == DIALOG_PHOTON_HACK_PLATE)
    {
        if(!response) return ShowPhotonHackPanel(playerid);
        if(strlen(inputtext) < 1 || strlen(inputtext) > 15)
        {
            PhotonHack_Notify(playerid, 2, "Длина номера должна быть от 1 до 15 символов.");
            return 1;
        }

        format(gPhotonHackPendingText[playerid], 32, "%s", inputtext);
        return PhotonHack_StartProgress(playerid, 5);
    }

    if(dialogid == DIALOG_PHOTON_HACK_SPEED)
    {
        if(!response) return ShowPhotonHackPanel(playerid);
        new Float:v = floatstr(inputtext);
        if(v < 50.0 || v > 500.0)
        {
            PhotonHack_Notify(playerid, 2, "Введите скорость от 50 до 500.");
            return 1;
        }

        gPhotonHackPendingFloat[playerid] = v;
        return PhotonHack_StartProgress(playerid, 6);
    }

    if(dialogid == DIALOG_PHOTON_HACK_ACCEL)
    {
        if(!response) return ShowPhotonHackPanel(playerid);
        new Float:v = floatstr(inputtext);
        if(v < 0.1 || v > 10.0)
        {
            PhotonHack_Notify(playerid, 2, "Введите ускорение от 0.1 до 10.0.");
            return 1;
        }

        gPhotonHackPendingFloat[playerid] = v;
        return PhotonHack_StartProgress(playerid, 7);
    }

    if(dialogid == DIALOG_PHOTON_HACK_GRAVITY)
    {
        if(!response) return ShowPhotonHackPanel(playerid);
        new Float:v = floatstr(inputtext);
        if(v < 0.001 || v > 0.050)
        {
            PhotonHack_Notify(playerid, 2, "Введите гравитацию от 0.001 до 0.050.");
            return 1;
        }

        gPhotonHackPendingFloat[playerid] = v;
        return PhotonHack_StartProgress(playerid, 8);
    }

    return 0;
}

CMD:hack(playerid, params[])
{
    #pragma unused params

    if(GetPlayerAdminEx(playerid) < 14 ||
        !GetPlayerData(playerid, P_ADMIN_LOGGED))
    {
        PhotonHack_Notify(playerid, 2, "У вас нет доступа к панели разработчика.");
        return 1;
    }

    return ShowPhotonHackPanel(playerid);
}
