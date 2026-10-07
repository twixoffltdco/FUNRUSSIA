#if defined _SYSTEM_FIRESYSTEM_INCLUDED
    #endinput
#endif
#define _SYSTEM_FIRESYSTEM_INCLUDED

#define FIRE_DIALOG_WARDROBE_MENU        (32980)
#define FIRE_DIALOG_HIRE_INFO            (32981)
#define FIRE_DIALOG_FIRE_CONFIRM         (32982)
#define FIRE_DIALOG_PERSONAL_CARD        (32983)
#define FIRE_DIALOG_CADET_MENU           (32984)
#define FIRE_DIALOG_CADET_TOPIC          (32985)
#define FIRE_DIALOG_INVENTORY            (32986)
#define FIRE_DIALOG_GAZEL_RENT           (32987)
#define FIRE_DIALOG_CALLS_LIST           (32988)
#define FIRE_DIALOG_VEHICLE_SELECT       (32989)

#if !defined GUITutorial
    #define GUITutorial                 (39)
#endif

#define FIRE_SERVICE_VEHICLE_COUNT       (2)
#define FIRE_DUTY_SKIN_ID                (19276)
#define FIRE_NEXT_CLASS_EXPERIENCE       (3000)
#define FIRE_INVENTORY_PICKUP_MODEL      (1239)
#define FIRE_WEAPON_EXTINGUISHER         (42)
#define FIRE_WEAPON_SHOVEL               (6)
#define FIRE_WEAPON_CROWBAR              (15)
#define FIRE_GAZEL_MODEL                 (499)
#define FIRE_EXTINGUISHER_LIMIT          (15000)
#define FIRE_EXTINGUISHER_STEP           (5000)
#define FIRE_TOOL_LIMIT                  (2)
#define FIRE_RETURN_VEHICLE_TIME         (60)
#define FIRE_MAX_CALLS                   (29)
#define FIRE_CALL_MAIN_FIRE_COUNT        (13)
#define FIRE_CALL_ADDITIONAL_COUNT       (2)
#define FIRE_CALL_OBJECT_COUNT           (FIRE_CALL_MAIN_FIRE_COUNT + FIRE_CALL_ADDITIONAL_COUNT)
#define FIRE_CALL_OBJECT_HEALTH          (15)
#define FIRE_CALL_USE_DISTANCE           (6.0)
#define FIRE_CALL_PROGRESS_DELAY         (350)
#define FIRE_CALL_TIME_LIMIT             (600)
#define FIRE_CALL_REACTIVATE_TIME        (300000)
#define FIRE_CALL_FLAME_MODEL            (18688)
#define FIRE_CALL_FLAME_Z_OFFSET         (1.05)
#define FIRE_PARTNER_INVITE_TIMEOUT      (15)
#define FIRE_PARTNER_INVITE_RANGE        (10.0)

new fire_enter_sphere;
new fire_exit_sphere;
new fire_wardrobe_sphere;
new fire_instructor_sphere;
new fire_inventory_sphere;
new fire_vehicle_sphere;

new fire_instructor_actor;
new fire_service_vehicles[FIRE_SERVICE_VEHICLE_COUNT];
new fire_player_experience[MAX_PLAYERS];

new bool:fire_player_employed[MAX_PLAYERS];
new bool:fire_player_on_duty[MAX_PLAYERS];
new bool:fire_player_data_loaded[MAX_PLAYERS];

new fire_player_extinguisher_count[MAX_PLAYERS];
new fire_player_shovel_count[MAX_PLAYERS];
new fire_player_crowbar_count[MAX_PLAYERS];

new fire_player_gazel_vehicle[MAX_PLAYERS];
new fire_player_driver_vehicle[MAX_PLAYERS];
new fire_player_last_ext_ammo[MAX_PLAYERS];
new bool:fire_player_inventory_dirty[MAX_PLAYERS];
new fire_player_last_save_tick[MAX_PLAYERS];
new fire_player_return_timer[MAX_PLAYERS];
new fire_player_return_time[MAX_PLAYERS];
new fire_player_call_timer[MAX_PLAYERS];
new fire_player_call_time_left[MAX_PLAYERS];
new PlayerText:fire_player_return_textdraw[MAX_PLAYERS];
new bool:fire_player_return_textdraw_created[MAX_PLAYERS];
new PlayerText:overTime_TD[MAX_PLAYERS][2];
new bool:fire_player_overtime_created[MAX_PLAYERS];
new fire_player_call_total_progress[MAX_PLAYERS];
new fire_player_call_progress_slot[MAX_PLAYERS];
new PlayerText:fire_player_call_prog_td[MAX_PLAYERS];
new bool:fire_player_call_prog_td_created[MAX_PLAYERS];
new fire_player_partner[MAX_PLAYERS];
new fire_player_partner_invite_from[MAX_PLAYERS];
new fire_player_partner_invite_time[MAX_PLAYERS];
new bool:fire_db_ready;

new fire_call_owner[FIRE_MAX_CALLS];
new fire_call_partner[FIRE_MAX_CALLS];
new bool:fire_call_enabled[FIRE_MAX_CALLS];
new fire_call_menu_map[MAX_PLAYERS][FIRE_MAX_CALLS];
new fire_call_menu_count[MAX_PLAYERS];
new fire_player_active_call[MAX_PLAYERS];
new fire_player_call_last_tick[MAX_PLAYERS];
new fire_player_call_main_progress[MAX_PLAYERS];
new bool:fire_player_call_additional_done[MAX_PLAYERS][FIRE_CALL_ADDITIONAL_COUNT];
new fire_call_main_progress[FIRE_MAX_CALLS];
new fire_call_total_progress[FIRE_MAX_CALLS];
new bool:fire_call_additional_done[FIRE_MAX_CALLS][FIRE_CALL_ADDITIONAL_COUNT];
new fire_call_object_health[FIRE_MAX_CALLS][FIRE_CALL_OBJECT_COUNT];
new bool:fire_call_object_done[FIRE_MAX_CALLS][FIRE_CALL_OBJECT_COUNT];
new STREAMER_TAG_OBJECT:fire_call_object[FIRE_MAX_CALLS][FIRE_CALL_OBJECT_COUNT];
new STREAMER_TAG_OBJECT:fire_call_flame[FIRE_MAX_CALLS][FIRE_CALL_OBJECT_COUNT];

new const fire_service_vehicle_model[FIRE_SERVICE_VEHICLE_COUNT] =
{
    407,
    499
};

new const Float:fire_service_vehicle_pos[FIRE_SERVICE_VEHICLE_COUNT][4] =
{
    {-2618.372802, -276.754333, 1246.271240, 0.458376},
    {-2626.099853, -276.465240, 1246.040405, 357.663269}
};

new const fire_service_vehicle_vinyl[FIRE_SERVICE_VEHICLE_COUNT][] =
{
    "remapfbody10",
    "remapfbody11"
};

new const fire_call_name[FIRE_MAX_CALLS][] =
{
    "Мусорные баки во дворе Арзамаса",
    "Возгорание у канала Южного",
    "Пожар возле гаражей Южного",
    "Складской мусор в Батырево",
    "Пожар в промышленной зоне Батырево",
    "Завал и огонь на окраине Лыткарино",
    "Возгорание во дворе Лыткарино",
    "Пожар на прибрежной дороге",
    "Горящий склад у трассы",
    "Огонь на стоянке у порта",
    "Возгорание у железной дороги",
    "Пожар на контейнерной площадке",
    "Свалка возле карьера",
    "Пожар у берега Лос-Сантоса",
    "Возгорание во дворах центра",
    "Пожар на ферме за городом",
    "Горящий двор у фермерского шоссе",
    "Пожар на перевале",
    "Возгорание возле мотеля",
    "Горящий объект у заправки",
    "Пожар на пустыре",
    "Складские отходы у дамбы",
    "Возгорание на грунтовой дороге",
    "Пожар возле лесополосы",
    "Горящий двор у трассы",
    "Возгорание возле больницы",
    "Пожар в квартале Лас-Вентураса",
    "Горящий участок на трассе",
    "Пожар возле пригородного дома"
};

new const Float:fire_call_pos[FIRE_MAX_CALLS][4] =
{
    {2107.288330, -2243.512451, 18.122322, 281.151367},
    {2194.892333, -187.452865, 2.274280, 176.496002},
    {2150.218994, -233.178726, 2.619399, 136.537246},
    {853.214477, -813.769348, 40.457416, 353.689361},
    {804.323303, -1423.716796, 42.590209, 0.876968},
    {-717.547973, -1928.795532, 40.438980, 277.796386},
    {-707.833557, -1982.660644, 40.563438, 189.591552},
    {-1681.489624, -1422.897949, 51.543590, 198.351699},
    {-2149.521728, -1131.508666, 47.851764, 174.439926},
    {-2263.141113, -1509.765625, 42.420783, 260.247131},
    {274.958312, -2183.749511, 37.983413, 260.247131},
    {2083.802246, -2538.167236, 14.609574, 292.985565},
    {-414.264343, 852.265747, 12.115101, 292.985565},
    {-2623.608398, -365.370300, 28.023803, 14.948587},
    {-2094.249755, -257.045532, 26.084312, 177.732589},
    {-2265.818115, 2099.138671, 9.753068, 348.127655},
    {-2379.090576, 2102.642333, 9.610684, 78.481948},
    {-2074.222656, 2925.770019, 18.372653, 336.333099},
    {-2238.534667, 2385.117675, 57.522891, 67.806182},
    {-2772.475830, 2773.407470, 9.614872, 284.644073},
    {-2798.645263, 2737.267333, 9.863211, 144.947845},
    {-1304.951049, 2654.506347, 10.631821, 159.554687},
    {-1312.432617, 2702.928222, 10.144181, 15.242391},
    {-1399.249267, 2732.160400, 11.100152, 177.279632},
    {-1355.229248, 2497.303710, 12.244269, 345.484191},
    {-259.753967, 344.079803, 11.670038, 341.839813},
    {2263.723632, 1310.337768, 17.391242, 276.953704},
    {2013.891357, 2085.688964, 12.159370, 68.921279},
    {854.950866, 458.207550, 12.068985, 177.204330}
};

new const Float:fire_call_main_offsets[FIRE_CALL_MAIN_FIRE_COUNT][4] =
{
    {0.0, 0.0, 0.0, 0.0},
    {5.5, 0.8, 0.0, 18.0},
    {-5.5, -0.8, 0.0, 34.0},
    {0.8, 5.8, 0.0, 57.0},
    {-0.8, -5.8, 0.0, 78.0},
    {4.6, 4.1, 0.0, 99.0},
    {-4.6, 4.1, 0.0, 121.0},
    {4.6, -4.1, 0.0, 144.0},
    {-4.6, -4.1, 0.0, 166.0},
    {8.2, 1.9, 0.0, 188.0},
    {-8.2, -1.9, 0.0, 209.0},
    {2.1, 8.0, 0.0, 234.0},
    {-2.1, -8.0, 0.0, 262.0}
};

new const Float:fire_call_additional_offsets[FIRE_CALL_ADDITIONAL_COUNT][4] =
{
    {9.0, 4.6, 0.0, 90.0},
    {-9.0, -4.6, 0.0, 270.0}
};

stock Float:FireSystemGetDistance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
    return floatsqroot(floatpower(x1 - x2, 2.0) + floatpower(y1 - y2, 2.0) + floatpower(z1 - z2, 2.0));
}

stock FireSystemGetPlayerRank(playerid)
{
    new rank = (fire_player_experience[playerid] / FIRE_NEXT_CLASS_EXPERIENCE) + 1;
    if(rank < 1) rank = 1;
    if(rank > 3) rank = 3;
    return rank;
}

stock FireSystemGetCallRequiredRank(callid)
{
    if(callid < 10) return 1;
    if(callid < 20) return 2;
    return 3;
}

stock FireSystemGetCallMainModel(callid, slot)
{
    new rank = FireSystemGetCallRequiredRank(callid);
    if(rank == 1)
    {
        return (slot % 2) ? 13924 : 13925;
    }
    if(rank == 2)
    {
        return (slot % 3 == 0) ? 13924 : 13925;
    }
    return (slot % 2) ? 13924 : 13925;
}

stock FireSystemHideOverTimeTD(playerid)
{
    if(!fire_player_overtime_created[playerid])
        return 1;

    PlayerTextDrawHide(playerid, overTime_TD[playerid][0]);
    PlayerTextDrawDestroy(playerid, overTime_TD[playerid][0]);
    PlayerTextDrawHide(playerid, overTime_TD[playerid][1]);
    PlayerTextDrawDestroy(playerid, overTime_TD[playerid][1]);
    fire_player_overtime_created[playerid] = false;
    return 1;
}

stock CreateOverTimeTD(playerid)
{
    if(fire_player_overtime_created[playerid])
        return 1;

    overTime_TD[playerid][0] = CreatePlayerTextDraw(playerid, 3.6666, 302.2593, "txd:otherbrtime");
    PlayerTextDrawTextSize(playerid, overTime_TD[playerid][0], 97.0000, 72.0000);
    PlayerTextDrawAlignment(playerid, overTime_TD[playerid][0], 1);
    PlayerTextDrawColor(playerid, overTime_TD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, overTime_TD[playerid][0], 255);
    PlayerTextDrawFont(playerid, overTime_TD[playerid][0], 4);

    overTime_TD[playerid][1] = CreatePlayerTextDraw(playerid, 52.6667, 337.6740, "");
    PlayerTextDrawLetterSize(playerid, overTime_TD[playerid][1], 0.4096, 2.0438);
    PlayerTextDrawFont(playerid, overTime_TD[playerid][1], 1);
    PlayerTextDrawColor(playerid, overTime_TD[playerid][1], -1523963137);
    PlayerTextDrawBackgroundColor(playerid, overTime_TD[playerid][1], 255);
    PlayerTextDrawSetShadow(playerid, overTime_TD[playerid][1], 0);
    PlayerTextDrawAlignment(playerid, overTime_TD[playerid][1], 2);

    fire_player_overtime_created[playerid] = true;
    return 1;
}

stock FireSystemUpdateOverTimeTD(playerid)
{
    if(fire_player_active_call[playerid] == -1)
        return FireSystemHideOverTimeTD(playerid);

    CreateOverTimeTD(playerid);

    new string[32];
    format(string, sizeof string, "%02d:%02d", fire_player_call_time_left[playerid] / 60, fire_player_call_time_left[playerid] % 60);
    PlayerTextDrawSetString(playerid, overTime_TD[playerid][1], string);
    PlayerTextDrawShow(playerid, overTime_TD[playerid][0]);
    PlayerTextDrawShow(playerid, overTime_TD[playerid][1]);
    return 1;
}

stock FireSystemHideCallProgressText(playerid)
{
    if(fire_player_call_prog_td_created[playerid])
    {
        PlayerTextDrawHide(playerid, fire_player_call_prog_td[playerid]);
        PlayerTextDrawDestroy(playerid, fire_player_call_prog_td[playerid]);
        fire_player_call_prog_td_created[playerid] = false;
    }
    fire_player_call_progress_slot[playerid] = -1;
    return 1;
}

stock FireSystemShowCallProgressText(playerid, progress)
{
    if(!fire_player_call_prog_td_created[playerid])
    {
        fire_player_call_prog_td[playerid] = CreatePlayerTextDraw(playerid, 320.0, 214.0, "Прогресс 0/15");
        PlayerTextDrawLetterSize(playerid, fire_player_call_prog_td[playerid], 0.270000, 1.450000);
        PlayerTextDrawAlignment(playerid, fire_player_call_prog_td[playerid], 2);
        PlayerTextDrawColor(playerid, fire_player_call_prog_td[playerid], -1);
        PlayerTextDrawSetShadow(playerid, fire_player_call_prog_td[playerid], 0);
        PlayerTextDrawSetOutline(playerid, fire_player_call_prog_td[playerid], 1);
        PlayerTextDrawBackgroundColor(playerid, fire_player_call_prog_td[playerid], 255);
        PlayerTextDrawFont(playerid, fire_player_call_prog_td[playerid], 1);
        PlayerTextDrawSetProportional(playerid, fire_player_call_prog_td[playerid], 1);
        fire_player_call_prog_td_created[playerid] = true;
    }

    new string[32];
    format(string, sizeof string, "Прогресс %d/%d", progress, FIRE_CALL_OBJECT_HEALTH);
    PlayerTextDrawSetString(playerid, fire_player_call_prog_td[playerid], string);
    PlayerTextDrawShow(playerid, fire_player_call_prog_td[playerid]);
    return 1;
}

stock FireSystemClearCallTimer(playerid)
{
    if(fire_player_call_timer[playerid])
    {
        KillTimer(fire_player_call_timer[playerid]);
        fire_player_call_timer[playerid] = 0;
    }
    return 1;
}

stock FireSystemShowCallNotify(playerid, type, text[])
{
    return ShowNotificationNew(playerid, type, 4, -1, 0, text, "");
}

stock FireSystemGetCallPayout(callid, bool:coop = false)
{
    new rank = FireSystemGetCallRequiredRank(callid);
    new payout = 50000 + ((rank - 1) * 25000);
    if(coop)
    {
        payout *= 2;
    }
    return payout;
}

stock FireSystemGetCallExperience(callid)
{
    return 48 + ((FireSystemGetCallRequiredRank(callid) - 1) * 24);
}

stock FireSystemResetPartnerInvite(playerid)
{
    fire_player_partner_invite_from[playerid] = INVALID_PLAYER_ID;
    fire_player_partner_invite_time[playerid] = 0;
    return 1;
}

stock FireSystemBreakPartnerLink(playerid)
{
    new partnerid = fire_player_partner[playerid];
    if(partnerid != INVALID_PLAYER_ID && IsPlayerConnected(partnerid) && fire_player_partner[partnerid] == playerid)
    {
        fire_player_partner[partnerid] = INVALID_PLAYER_ID;
    }
    fire_player_partner[playerid] = INVALID_PLAYER_ID;
    return 1;
}

stock FireSystemSyncPlayerCallState(playerid)
{
    new callid = fire_player_active_call[playerid];
    if(callid < 0 || callid >= FIRE_MAX_CALLS)
    {
        fire_player_call_main_progress[playerid] = 0;
        fire_player_call_total_progress[playerid] = 0;
        fire_player_call_additional_done[playerid][0] = false;
        fire_player_call_additional_done[playerid][1] = false;
        return 0;
    }

    fire_player_call_main_progress[playerid] = fire_call_main_progress[callid];
    fire_player_call_total_progress[playerid] = fire_call_total_progress[callid];
    fire_player_call_additional_done[playerid][0] = fire_call_additional_done[callid][0];
    fire_player_call_additional_done[playerid][1] = fire_call_additional_done[callid][1];
    return 1;
}

stock FireSystemRefreshCallParticipants(callid)
{
    if(callid < 0 || callid >= FIRE_MAX_CALLS)
    {
        return 0;
    }

    new owner = fire_call_owner[callid];
    new partner = fire_call_partner[callid];

    if(owner != INVALID_PLAYER_ID && IsPlayerConnected(owner))
    {
        FireSystemSyncPlayerCallState(owner);
        FireSystemRefreshCallTutorial(owner);
        FireSystemUpdateOverTimeTD(owner);
    }

    if(partner != INVALID_PLAYER_ID && IsPlayerConnected(partner))
    {
        FireSystemSyncPlayerCallState(partner);
        FireSystemRefreshCallTutorial(partner);
        FireSystemUpdateOverTimeTD(partner);
    }
    return 1;
}

stock FireSystemSendCallAcceptedMessages(playerid, callid)
{
    new text[192];
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    format(text, sizeof text, "{FFFF00}{FFFFFF}Вы приняли вызов {FFFF00}%s{FFFFFF}.", fire_call_name[callid]);
    SendClientMessage(playerid, -1, text);

    format
    (
        text,
        sizeof text,
        "{FFFF00}{FFFFFF}Уровень: {FFFF00}%d{FFFFFF}. Расстояние: {FFFF00}%.1f {FFFFFF}метров.",
        FireSystemGetCallRequiredRank(callid),
        FireSystemGetDistance(px, py, pz, fire_call_pos[callid][0], fire_call_pos[callid][1], fire_call_pos[callid][2])
    );
    SendClientMessage(playerid, -1, text);
    return 1;
}

stock FireSystemSendRewardMessages(playerid, payout, experience)
{
    new text[192];

    format(text, sizeof text, "{FFFF00}{FFFFFF}Вы получили выплату в размере {FFFF00}%d {FFFFFF}рублей, за основное задание.", payout);
    SendClientMessage(playerid, -1, text);

    format(text, sizeof text, "{FFFF00}{FFFFFF}Вам было начислено {FFFF00}%d {FFFFFF}опыта пожарного.", experience);
    SendClientMessage(playerid, -1, text);
    return 1;
}

stock FireSystemDestroyCallObjects(callid)
{
    for(new slot; slot < FIRE_CALL_OBJECT_COUNT; slot++)
    {
        if(fire_call_object[callid][slot] != STREAMER_TAG_OBJECT:INVALID_STREAMER_ID)
        {
            DestroyDynamicObject(fire_call_object[callid][slot]);
            fire_call_object[callid][slot] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
        }

        if(fire_call_flame[callid][slot] != STREAMER_TAG_OBJECT:INVALID_STREAMER_ID)
        {
            DestroyDynamicObject(fire_call_flame[callid][slot]);
            fire_call_flame[callid][slot] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
        }

        fire_call_object_health[callid][slot] = FIRE_CALL_OBJECT_HEALTH;
        fire_call_object_done[callid][slot] = false;
    }
    return 1;
}

stock FireSystemRefreshCallTutorial(playerid)
{
    HidePlayerGUI(playerid, GUITutorial);
    FireSystemShowCallTutorial(playerid);
    return 1;
}

stock FireSystemCloseTutorialGUI(playerid)
{
    HidePlayerGUI(playerid, GUITutorial);

    new Node:close = JSON_Object();
    JSON_SetInt(close, "c", 1);
    OnPacketIncoming(playerid, GUITutorial, close);
    JSON_Cleanup(close);
    return 1;
}

stock FireSystemSendAdditionalProgress(playerid)
{
    return FireSystemRefreshCallTutorial(playerid);
}

stock FireSystemUpdateMainTutorial(playerid)
{
    return FireSystemRefreshCallTutorial(playerid);
}

stock FireSystemShowCallTutorial(playerid)
{
    new callid = fire_player_active_call[playerid];
    if(callid == -1)
    {
        HidePlayerGUI(playerid, GUITutorial);
        return 0;
    }

    FireSystemSyncPlayerCallState(playerid);

    new Node:tutorial = JSON_Object();
    new Node:aq = JSON_Array();
    new Node:at = JSON_Array();
    new Node:aa = JSON_Array();
    new Node:ac = JSON_Array();

    JSON_SetInt(tutorial, "m", 4);
    JSON_SetInt(tutorial, "t", 4);
    JSON_SetString(tutorial, "mq", "Устранить пожар");
    JSON_SetInt(tutorial, "mt", fire_call_main_progress[callid]);
    JSON_SetInt(tutorial, "ma", FIRE_CALL_MAIN_FIRE_COUNT);
    JSON_SetString(tutorial, "mc", "#0BDA51");

    JSON_Append(aq, JSON_String("Газовый баллон"));
    JSON_Append(aq, JSON_String("Горючее вещество"));
    JSON_Append(at, JSON_Int(fire_call_additional_done[callid][0] ? 1 : 0));
    JSON_Append(at, JSON_Int(fire_call_additional_done[callid][1] ? 1 : 0));
    JSON_Append(aa, JSON_Int(1));
    JSON_Append(aa, JSON_Int(1));
    JSON_Append(ac, JSON_String("#0BDA51"));
    JSON_Append(ac, JSON_String("#0BDA51"));

    JSON_SetArray(tutorial, "aq", aq);
    JSON_SetArray(tutorial, "at", at);
    JSON_SetArray(tutorial, "aa", aa);
    JSON_SetArray(tutorial, "ac", ac);
    ShowPlayerGUI(playerid, GUITutorial, tutorial);
    return 1;
}

stock FireSystemSpawnCallObjects(callid)
{
    FireSystemDestroyCallObjects(callid);
    fire_call_main_progress[callid] = 0;
    fire_call_total_progress[callid] = 0;
    fire_call_additional_done[callid][0] = false;
    fire_call_additional_done[callid][1] = false;

    new Float:base_x = fire_call_pos[callid][0];
    new Float:base_y = fire_call_pos[callid][1];
    new Float:base_z = fire_call_pos[callid][2];
    new Float:base_a = fire_call_pos[callid][3];

    for(new slot; slot < FIRE_CALL_MAIN_FIRE_COUNT; slot++)
    {
        new Float:x = base_x + fire_call_main_offsets[slot][0];
        new Float:y = base_y + fire_call_main_offsets[slot][1];
        new Float:z = base_z + fire_call_main_offsets[slot][2];
        new Float:r = base_a + fire_call_main_offsets[slot][3];

        fire_call_object[callid][slot] = CreateDynamicObject
        (
            FireSystemGetCallMainModel(callid, slot),
            x,
            y,
            z - 1.0,
            0.0,
            0.0,
            r,
            -1,
            -1,
            -1,
            200.0,
            200.0
        );
        fire_call_flame[callid][slot] = CreateDynamicObject
        (
            FIRE_CALL_FLAME_MODEL,
            x,
            y,
            z + FIRE_CALL_FLAME_Z_OFFSET,
            0.0,
            0.0,
            r,
            -1,
            -1,
            -1,
            200.0,
            200.0
        );
        fire_call_object_health[callid][slot] = FIRE_CALL_OBJECT_HEALTH;
        fire_call_object_done[callid][slot] = false;
    }

    fire_call_object[callid][FIRE_CALL_MAIN_FIRE_COUNT] = CreateDynamicObject
    (
        18578,
        base_x + fire_call_additional_offsets[0][0],
        base_y + fire_call_additional_offsets[0][1],
        base_z - 1.0,
        0.0,
        0.0,
        base_a + fire_call_additional_offsets[0][3],
        -1,
        -1,
        -1,
        200.0,
        200.0
    );
    fire_call_flame[callid][FIRE_CALL_MAIN_FIRE_COUNT] = CreateDynamicObject
    (
        FIRE_CALL_FLAME_MODEL,
        base_x + fire_call_additional_offsets[0][0],
        base_y + fire_call_additional_offsets[0][1],
        base_z + FIRE_CALL_FLAME_Z_OFFSET,
        0.0,
        0.0,
        base_a + fire_call_additional_offsets[0][3],
        -1,
        -1,
        -1,
        200.0,
        200.0
    );
    fire_call_object_health[callid][FIRE_CALL_MAIN_FIRE_COUNT] = FIRE_CALL_OBJECT_HEALTH;
    fire_call_object_done[callid][FIRE_CALL_MAIN_FIRE_COUNT] = false;

    fire_call_object[callid][FIRE_CALL_MAIN_FIRE_COUNT + 1] = CreateDynamicObject
    (
        (callid % 2) ? 18579 : 18580,
        base_x + fire_call_additional_offsets[1][0],
        base_y + fire_call_additional_offsets[1][1],
        base_z - 1.0,
        0.0,
        0.0,
        base_a + fire_call_additional_offsets[1][3],
        -1,
        -1,
        -1,
        200.0,
        200.0
    );
    fire_call_flame[callid][FIRE_CALL_MAIN_FIRE_COUNT + 1] = CreateDynamicObject
    (
        FIRE_CALL_FLAME_MODEL,
        base_x + fire_call_additional_offsets[1][0],
        base_y + fire_call_additional_offsets[1][1],
        base_z + FIRE_CALL_FLAME_Z_OFFSET,
        0.0,
        0.0,
        base_a + fire_call_additional_offsets[1][3],
        -1,
        -1,
        -1,
        200.0,
        200.0
    );
    fire_call_object_health[callid][FIRE_CALL_MAIN_FIRE_COUNT + 1] = FIRE_CALL_OBJECT_HEALTH;
    fire_call_object_done[callid][FIRE_CALL_MAIN_FIRE_COUNT + 1] = false;
    return 1;
}

forward FireSystemCallTimer(playerid);
public FireSystemCallTimer(playerid)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    if(fire_player_active_call[playerid] == -1)
    {
        FireSystemClearCallTimer(playerid);
        return 0;
    }

    fire_player_call_time_left[playerid]--;

    if(fire_player_call_time_left[playerid] <= 0)
    {
        FireSystemClearCallTimer(playerid);
        FireSystemAbortActiveCall(playerid, false);
        FireSystemShowCallNotify(playerid, 2, "Время на вызов истекло.");
        return 1;
    }

    FireSystemUpdateOverTimeTD(playerid);
    return 1;
}

stock FireSystemReactivateCallNow(callid)
{
    if(callid < 0 || callid >= FIRE_MAX_CALLS)
        return 0;

    fire_call_enabled[callid] = true;
    fire_call_owner[callid] = INVALID_PLAYER_ID;
    fire_call_partner[callid] = INVALID_PLAYER_ID;
    FireSystemSpawnCallObjects(callid);
    return 1;
}

forward FireSystemReactivateCall(callid);
public FireSystemReactivateCall(callid)
{
    return FireSystemReactivateCallNow(callid);
}

stock FireSystemResetPlayerCallState(playerid)
{
    FireSystemClearCallTimer(playerid);
    FireSystemCloseTutorialGUI(playerid);
    FireSystemHideOverTimeTD(playerid);
    FireSystemHideCallProgressText(playerid);
    DisablePlayerGPS(playerid);

    fire_player_active_call[playerid] = -1;
    fire_player_call_main_progress[playerid] = 0;
    fire_player_call_total_progress[playerid] = 0;
    fire_player_call_progress_slot[playerid] = -1;
    fire_player_call_last_tick[playerid] = 0;
    fire_player_call_time_left[playerid] = 0;
    fire_player_call_additional_done[playerid][0] = false;
    fire_player_call_additional_done[playerid][1] = false;
    return 1;
}

stock FireSystemStartCallTimerForPlayer(playerid, time_left = FIRE_CALL_TIME_LIMIT)
{
    FireSystemClearCallTimer(playerid);
    fire_player_call_time_left[playerid] = time_left;
    fire_player_call_timer[playerid] = SetTimerEx("FireSystemCallTimer", 1000, true, "i", playerid);
    FireSystemUpdateOverTimeTD(playerid);
    return 1;
}

stock FireSystemAttachPartnerToCall(ownerid, partnerid, callid)
{
    if(partnerid == INVALID_PLAYER_ID || !IsPlayerConnected(partnerid) || !IsPlayerLogged(partnerid))
        return 0;

    if(fire_player_active_call[partnerid] != -1)
        return 0;

    fire_call_partner[callid] = partnerid;
    fire_player_active_call[partnerid] = callid;
    fire_player_call_progress_slot[partnerid] = -1;
    fire_player_call_last_tick[partnerid] = 0;
    FireSystemSyncPlayerCallState(partnerid);

    FireSystemClearVehicleReturnTimer(partnerid);
    FireSystemShowCallTutorial(partnerid);
    FireSystemStartCallTimerForPlayer(partnerid, fire_player_call_time_left[ownerid]);
    EnablePlayerGPS(partnerid, 55, fire_call_pos[callid][0], fire_call_pos[callid][1], fire_call_pos[callid][2], "");
    FireSystemSendCallAcceptedMessages(partnerid, callid);
    FireSystemShowCallNotify(ownerid, 3, "Напарник автоматически присоединился к вызову.");
    FireSystemShowCallNotify(partnerid, 3, "Вы автоматически присоединились к вызову напарника.");
    return 1;
}

stock FireSystemFinishCall(playerid, bool:success = true)
{
    new callid = fire_player_active_call[playerid];
    if(callid == -1)
        return 0;

    new owner = fire_call_owner[callid];
    new partner = fire_call_partner[callid];
    new experience = FireSystemGetCallExperience(callid);
    new payout = FireSystemGetCallPayout(callid, partner != INVALID_PLAYER_ID);

    if(success)
    {
        fire_call_enabled[callid] = false;
        FireSystemDestroyCallObjects(callid);
        SetTimerEx("FireSystemReactivateCall", FIRE_CALL_REACTIVATE_TIME, false, "i", callid);

        if(owner != INVALID_PLAYER_ID && IsPlayerConnected(owner))
        {
            GivePlayerMoneyEx(owner, payout, "МЧС: основное задание", true, true);
            fire_player_experience[owner] += experience;
            fire_player_inventory_dirty[owner] = true;
            FireSystemSavePlayerData(owner);
            FireSystemSendRewardMessages(owner, payout, experience);
            FireSystemShowCallNotify(owner, 3, "Вызов выполнен. Вы устранили пожар.");
        }

        if(partner != INVALID_PLAYER_ID && IsPlayerConnected(partner))
        {
            GivePlayerMoneyEx(partner, payout, "МЧС: основное задание", true, true);
            fire_player_experience[partner] += experience;
            fire_player_inventory_dirty[partner] = true;
            FireSystemSavePlayerData(partner);
            FireSystemSendRewardMessages(partner, payout, experience);
            FireSystemShowCallNotify(partner, 3, "Вызов выполнен. Вы устранили пожар.");
        }
    }
    else
    {
        fire_call_enabled[callid] = true;
        FireSystemSpawnCallObjects(callid);
    }

    fire_call_owner[callid] = INVALID_PLAYER_ID;
    fire_call_partner[callid] = INVALID_PLAYER_ID;

    if(owner != INVALID_PLAYER_ID)
    {
        FireSystemResetPlayerCallState(owner);
    }

    if(partner != INVALID_PLAYER_ID)
    {
        FireSystemResetPlayerCallState(partner);
    }
    return 1;
}

stock FireSystemAbortActiveCall(playerid, bool:cooldown = false)
{
    new callid = fire_player_active_call[playerid];
    if(callid == -1)
        return 0;

    new owner = fire_call_owner[callid];
    new partner = fire_call_partner[callid];

    FireSystemResetPlayerCallState(playerid);

    fire_call_owner[callid] = INVALID_PLAYER_ID;
    fire_call_partner[callid] = INVALID_PLAYER_ID;
    fire_call_enabled[callid] = !cooldown;
    FireSystemSpawnCallObjects(callid);

    if(owner != INVALID_PLAYER_ID && owner != playerid && IsPlayerConnected(owner))
    {
        FireSystemResetPlayerCallState(owner);
        FireSystemShowCallNotify(owner, 2, "Вызов был отменен.");
    }

    if(partner != INVALID_PLAYER_ID && partner != playerid && IsPlayerConnected(partner))
    {
        FireSystemResetPlayerCallState(partner);
        FireSystemShowCallNotify(partner, 2, "Вызов был отменен.");
    }
    return 1;
}

stock FireSystemStartCall(playerid, callid)
{
    if(callid < 0 || callid >= FIRE_MAX_CALLS)
        return 0;

    if(!fire_player_employed[playerid] || !fire_player_on_duty[playerid])
        return FireSystemSendNotEmployedNotify(playerid), 1;

    if(!fire_call_enabled[callid] || (fire_call_owner[callid] != INVALID_PLAYER_ID && fire_call_owner[callid] != playerid))
    {
        FireSystemShowCallNotify(playerid, 2, "Этот вызов уже неактивен.");
        return 1;
    }

    new need_rank = FireSystemGetCallRequiredRank(callid);
    new player_rank = FireSystemGetPlayerRank(playerid);
    if(player_rank < need_rank)
    {
        new text[128];
        format(text, sizeof text, "Вы не можете взять этот вызов, нужен {FFFF00}%d {FFFFFF}ранг.", need_rank);
        FireSystemShowCallNotify(playerid, 2, text);
        return 1;
    }

    if(fire_player_active_call[playerid] != -1)
    {
        FireSystemAbortActiveCall(playerid, false);
    }

    new partnerid = fire_player_partner[playerid];
    if(partnerid != INVALID_PLAYER_ID)
    {
        if(!IsPlayerConnected(partnerid) || !IsPlayerLogged(partnerid) || !fire_player_employed[partnerid] || !fire_player_on_duty[partnerid])
        {
            FireSystemBreakPartnerLink(playerid);
            partnerid = INVALID_PLAYER_ID;
        }
        else if(fire_player_active_call[partnerid] != -1)
        {
            return FireSystemShowCallNotify(playerid, 2, "Ваш напарник уже занят другим вызовом."), 1;
        }
        else if(FireSystemGetPlayerRank(partnerid) < need_rank)
        {
            return FireSystemShowCallNotify(playerid, 2, "У Вашего напарника недостаточный ранг для этого вызова."), 1;
        }
    }

    fire_call_owner[callid] = playerid;
    fire_call_partner[callid] = INVALID_PLAYER_ID;
    fire_player_active_call[playerid] = callid;
    fire_player_call_progress_slot[playerid] = -1;
    fire_player_call_last_tick[playerid] = 0;
    FireSystemSyncPlayerCallState(playerid);

    FireSystemClearVehicleReturnTimer(playerid);
    FireSystemShowCallTutorial(playerid);
    FireSystemStartCallTimerForPlayer(playerid, FIRE_CALL_TIME_LIMIT);
    EnablePlayerGPS(playerid, 55, fire_call_pos[callid][0], fire_call_pos[callid][1], fire_call_pos[callid][2], "");
    FireSystemShowCallNotify(playerid, 3, "Точка отмечена у Вас на GPS.");
    FireSystemSendCallAcceptedMessages(playerid, callid);

    if(partnerid != INVALID_PLAYER_ID)
    {
        FireSystemAttachPartnerToCall(playerid, partnerid, callid);
    }
    return 1;
}

stock FireSystemShowCallsMenu(playerid)
{
    if(!fire_player_employed[playerid] || !fire_player_on_duty[playerid])
        return FireSystemSendNotEmployedNotify(playerid), 1;

    new body[4096];
    strcat(body, "{FFFF00}##\t{FFFF00}Имя вызова\t{FFFF00}Уровень\t{FFFF00}Расстояние\n");

    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    fire_call_menu_count[playerid] = 0;

    for(new callid; callid < FIRE_MAX_CALLS; callid++)
    {
        if(!fire_call_enabled[callid] || (fire_call_owner[callid] != INVALID_PLAYER_ID && fire_call_owner[callid] != playerid))
            continue;

        fire_call_menu_map[playerid][fire_call_menu_count[playerid]] = callid;
        fire_call_menu_count[playerid]++;

        new row[192];
        format
        (
            row,
            sizeof row,
            "{AFAFAF}#%d\t{FFFFFF}%s\t%d\t{AFAFAF}%.1f\n",
            callid + 1,
            fire_call_name[callid],
            FireSystemGetCallRequiredRank(callid),
            FireSystemGetDistance(px, py, pz, fire_call_pos[callid][0], fire_call_pos[callid][1], fire_call_pos[callid][2])
        );
        strcat(body, row);
    }

    if(!fire_call_menu_count[playerid])
    {
        strcat(body, "{AFAFAF}#-\t{FFFFFF}Активных вызовов сейчас нет\t-\t-\n");
    }

    ShowPlayerDialog
    (
        playerid,
        FIRE_DIALOG_CALLS_LIST,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{E0584B}Black Russia {555555}RolePlay {FFFFFF}-> МЧС | Список вызовов",
        body,
        "Принять",
        "Выход"
    );
    return 1;
}

stock FireSystemProcessCallDialog(playerid, response, listitem)
{
    if(!response || !fire_call_menu_count[playerid])
        return 1;

    if(listitem < 0 || listitem >= fire_call_menu_count[playerid])
        return 1;

    return FireSystemStartCall(playerid, fire_call_menu_map[playerid][listitem]);
}

stock FireSystemTryExtinguish(playerid)
{
    new callid = fire_player_active_call[playerid];
    if(callid == -1)
        return 0;

    if(GetPlayerWeapon(playerid) != FIRE_WEAPON_EXTINGUISHER)
        return FireSystemHideCallProgressText(playerid), 0;

    new keys, ud, lr;
    GetPlayerKeys(playerid, keys, ud, lr);
    if(!(keys & KEY_FIRE))
        return FireSystemHideCallProgressText(playerid), 0;

    new tick = GetTickCount();
    if(tick - fire_player_call_last_tick[playerid] < FIRE_CALL_PROGRESS_DELAY)
        return 0;

    fire_player_call_last_tick[playerid] = tick;

    new Float:px, Float:py, Float:pz;
    new object_progress;
    GetPlayerPos(playerid, px, py, pz);

    for(new slot; slot < FIRE_CALL_OBJECT_COUNT; slot++)
    {
        if(fire_call_object_done[callid][slot])
            continue;
        if(fire_call_object[callid][slot] == STREAMER_TAG_OBJECT:INVALID_STREAMER_ID)
            continue;

        new Float:ox, Float:oy, Float:oz;
        GetDynamicObjectPos(fire_call_object[callid][slot], ox, oy, oz);

        if(FireSystemGetDistance(px, py, pz, ox, oy, oz + 1.0) > FIRE_CALL_USE_DISTANCE)
            continue;

        if(fire_player_call_progress_slot[playerid] != slot)
        {
            fire_player_call_progress_slot[playerid] = slot;
            FireSystemShowCallProgressText(playerid, FIRE_CALL_OBJECT_HEALTH - fire_call_object_health[callid][slot]);
        }

        fire_call_object_health[callid][slot]--;

        object_progress = FIRE_CALL_OBJECT_HEALTH - fire_call_object_health[callid][slot];
        if(object_progress < 0) object_progress = 0;
        if(object_progress > FIRE_CALL_OBJECT_HEALTH) object_progress = FIRE_CALL_OBJECT_HEALTH;
        FireSystemShowCallProgressText(playerid, object_progress);

        if(fire_call_object_health[callid][slot] > 0)
            return 1;

        if(fire_call_flame[callid][slot] != STREAMER_TAG_OBJECT:INVALID_STREAMER_ID)
        {
            DestroyDynamicObject(fire_call_flame[callid][slot]);
            fire_call_flame[callid][slot] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
        }
        fire_call_object_done[callid][slot] = true;
        fire_call_total_progress[callid]++;

        if(slot < FIRE_CALL_MAIN_FIRE_COUNT)
        {
            fire_call_main_progress[callid]++;
        }
        else
        {
            fire_call_additional_done[callid][slot - FIRE_CALL_MAIN_FIRE_COUNT] = true;
        }

        FireSystemRefreshCallParticipants(callid);

        ShowNotificationNew(playerid, 3, 5, -1, 0, "Очаг успешно потушен.", "");

        if(fire_call_total_progress[callid] >= FIRE_CALL_OBJECT_COUNT)
        {
            FireSystemFinishCall(playerid, true);
        }
        else
        {
            FireSystemHideCallProgressText(playerid);
        }
        return 1;
    }

    FireSystemHideCallProgressText(playerid);
    return 0;
}

stock FireSystemInitCalls()
{
    for(new callid; callid < FIRE_MAX_CALLS; callid++)
    {
        fire_call_owner[callid] = INVALID_PLAYER_ID;
        fire_call_partner[callid] = INVALID_PLAYER_ID;
        fire_call_enabled[callid] = true;
        fire_call_main_progress[callid] = 0;
        fire_call_total_progress[callid] = 0;
        fire_call_additional_done[callid][0] = false;
        fire_call_additional_done[callid][1] = false;

        for(new slot; slot < FIRE_CALL_OBJECT_COUNT; slot++)
        {
            fire_call_object[callid][slot] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
            fire_call_flame[callid][slot] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
            fire_call_object_health[callid][slot] = FIRE_CALL_OBJECT_HEALTH;
            fire_call_object_done[callid][slot] = false;
        }
    }

    for(new playerid; playerid < MAX_PLAYERS; playerid++)
    {
        fire_player_active_call[playerid] = -1;
        fire_player_partner[playerid] = INVALID_PLAYER_ID;
        fire_player_partner_invite_from[playerid] = INVALID_PLAYER_ID;
        fire_player_partner_invite_time[playerid] = 0;
        fire_player_call_last_tick[playerid] = 0;
        fire_player_call_main_progress[playerid] = 0;
        fire_player_call_total_progress[playerid] = 0;
        fire_player_call_progress_slot[playerid] = -1;
        fire_player_call_additional_done[playerid][0] = false;
        fire_player_call_additional_done[playerid][1] = false;
        fire_player_call_timer[playerid] = 0;
        fire_player_call_time_left[playerid] = 0;
        fire_player_overtime_created[playerid] = false;
        fire_player_call_prog_td_created[playerid] = false;
    }
    return 1;
}

stock FireSystemHideVehicleReturnText(playerid)
{
    if(fire_player_return_textdraw_created[playerid])
    {
        PlayerTextDrawHide(playerid, fire_player_return_textdraw[playerid]);
        PlayerTextDrawDestroy(playerid, fire_player_return_textdraw[playerid]);
        fire_player_return_textdraw_created[playerid] = false;
    }
    return 1;
}

stock FireSystemShowVehicleReturnText(playerid)
{
    if(!fire_player_return_textdraw_created[playerid])
    {
        fire_player_return_textdraw[playerid] = CreatePlayerTextDraw(playerid, 320.0, 214.0, "60");
        PlayerTextDrawLetterSize(playerid, fire_player_return_textdraw[playerid], 0.650000, 3.000000);
        PlayerTextDrawAlignment(playerid, fire_player_return_textdraw[playerid], 2);
        PlayerTextDrawColor(playerid, fire_player_return_textdraw[playerid], -1);
        PlayerTextDrawSetShadow(playerid, fire_player_return_textdraw[playerid], 0);
        PlayerTextDrawSetOutline(playerid, fire_player_return_textdraw[playerid], 1);
        PlayerTextDrawBackgroundColor(playerid, fire_player_return_textdraw[playerid], 255);
        PlayerTextDrawFont(playerid, fire_player_return_textdraw[playerid], 3);
        PlayerTextDrawSetProportional(playerid, fire_player_return_textdraw[playerid], 1);
        fire_player_return_textdraw_created[playerid] = true;
    }

    new string[16];
    format(string, sizeof string, "%d", fire_player_return_time[playerid]);
    PlayerTextDrawSetString(playerid, fire_player_return_textdraw[playerid], string);
    PlayerTextDrawShow(playerid, fire_player_return_textdraw[playerid]);
    return 1;
}

stock FireSystemClearVehicleReturnTimer(playerid)
{
    if(fire_player_return_timer[playerid])
    {
        KillTimer(fire_player_return_timer[playerid]);
        fire_player_return_timer[playerid] = 0;
    }

    fire_player_return_time[playerid] = 0;
    FireSystemHideVehicleReturnText(playerid);
    return 1;
}

stock FireSystemDestroyPlayerVehicle(playerid)
{
    new vehicleid = fire_player_gazel_vehicle[playerid];
    if(vehicleid != INVALID_VEHICLE_ID && IsValidVehicle(vehicleid))
    {
        DestroyVehicle(vehicleid);
    }

    fire_player_gazel_vehicle[playerid] = INVALID_VEHICLE_ID;
    fire_player_driver_vehicle[playerid] = INVALID_VEHICLE_ID;
    FireSystemClearVehicleReturnTimer(playerid);
    return 1;
}


stock FireSystemClearCallProgressText(playerid)
{
    fire_player_call_total_progress[playerid] = 0;
    fire_player_call_progress_slot[playerid] = -1;
    FireSystemHideCallProgressText(playerid);
    return 1;
}

stock FireSystemResetPlayer(playerid)
{
    FireSystemAbortActiveCall(playerid, false);
    FireSystemBreakPartnerLink(playerid);
    fire_player_employed[playerid] = false;
    fire_player_on_duty[playerid] = false;
    fire_player_data_loaded[playerid] = false;
    fire_player_experience[playerid] = 0;
    fire_player_extinguisher_count[playerid] = 0;
    fire_player_shovel_count[playerid] = 0;
    fire_player_crowbar_count[playerid] = 0;
    FireSystemDestroyPlayerVehicle(playerid);
    fire_player_last_ext_ammo[playerid] = 0;
    fire_player_inventory_dirty[playerid] = false;
    fire_player_last_save_tick[playerid] = 0;
    FireSystemClearVehicleReturnTimer(playerid);
    FireSystemClearCallProgressText(playerid);
    fire_player_return_textdraw_created[playerid] = false;
    fire_player_overtime_created[playerid] = false;
    fire_player_call_prog_td_created[playerid] = false;
    fire_player_active_call[playerid] = -1;
    fire_player_call_last_tick[playerid] = 0;
    fire_player_call_main_progress[playerid] = 0;
    fire_player_call_total_progress[playerid] = 0;
    fire_player_call_progress_slot[playerid] = -1;
    fire_player_call_additional_done[playerid][0] = false;
    fire_player_call_additional_done[playerid][1] = false;
    fire_player_partner[playerid] = INVALID_PLAYER_ID;
    FireSystemResetPartnerInvite(playerid);
    DeletePVar(playerid, "fire_cadet_topic");
    DeletePVar(playerid, "fire_rent_vehicleid");
    return 1;
}

stock FireSystemEnsureDBColumn(column_name[], column_definition[])
{
    new query[256];
    format(query, sizeof query, "SHOW COLUMNS FROM `mhcwork` LIKE '%s'", column_name);

    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        printf("[FIRESYSTEM] Не удалось проверить колонку mhcwork.%s, errno=%d", column_name, mysql_errno());
        cache_delete(result);
        return 0;
    }

    new rows = cache_num_rows();
    cache_delete(result);

    if(rows > 0)
        return 1;

    format(query, sizeof query, "ALTER TABLE `mhcwork` ADD COLUMN `%s` %s", column_name, column_definition);
    mysql_query(mysql, query, false);

    if(mysql_errno())
    {
        printf("[FIRESYSTEM] Не удалось добавить колонку mhcwork.%s, errno=%d", column_name, mysql_errno());
        return 0;
    }
    return 1;
}

stock FireSystemCreateDatabase()
{
    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS `mhcwork` (`account_id` INT NOT NULL, `employed` TINYINT(1) NOT NULL DEFAULT 0, `experience` INT NOT NULL DEFAULT 0, `extinguisher_count` INT NOT NULL DEFAULT 0, `shovel_count` INT NOT NULL DEFAULT 0, `crowbar_count` INT NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);

    if(mysql_errno())
    {
        printf("[FIRESYSTEM] Не удалось создать таблицу mhcwork, errno=%d", mysql_errno());
    }

    FireSystemEnsureDBColumn("employed", "TINYINT(1) NOT NULL DEFAULT 0");
    FireSystemEnsureDBColumn("experience", "INT NOT NULL DEFAULT 0");
    FireSystemEnsureDBColumn("extinguisher_count", "INT NOT NULL DEFAULT 0");
    FireSystemEnsureDBColumn("shovel_count", "INT NOT NULL DEFAULT 0");
    FireSystemEnsureDBColumn("crowbar_count", "INT NOT NULL DEFAULT 0");
    fire_db_ready = true;
    return 1;
}

stock FireSystemSavePlayerData(playerid)
{
    if(!fire_player_data_loaded[playerid])
        return 0;

    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0)
        return 0;

    if(!fire_db_ready)
    {
        FireSystemCreateDatabase();
    }

    new query[768];
    for(new attempt; attempt < 2; attempt++)
    {
        mysql_format
        (
            mysql,
            query,
            sizeof query,
            "INSERT INTO `mhcwork` (`account_id`, `employed`, `experience`, `extinguisher_count`, `shovel_count`, `crowbar_count`) VALUES (%d, %d, %d, %d, %d, %d) ON DUPLICATE KEY UPDATE `employed` = VALUES(`employed`), `experience` = VALUES(`experience`), `extinguisher_count` = VALUES(`extinguisher_count`), `shovel_count` = VALUES(`shovel_count`), `crowbar_count` = VALUES(`crowbar_count`)",
            account_id,
            fire_player_employed[playerid] ? 1 : 0,
            fire_player_experience[playerid],
            fire_player_extinguisher_count[playerid],
            fire_player_shovel_count[playerid],
            fire_player_crowbar_count[playerid]
        );
        mysql_query(mysql, query, false);

        if(!mysql_errno())
        {
            fire_player_inventory_dirty[playerid] = false;
            fire_player_last_save_tick[playerid] = GetTickCount();
            return 1;
        }

        if(mysql_errno() == 1054 && attempt == 0)
        {
            FireSystemCreateDatabase();
            continue;
        }

        printf("[FIRESYSTEM] Не удалось сохранить mhcwork для account_id=%d, errno=%d", account_id, mysql_errno());
        return 0;
    }

    return 0;
}

stock FireSystemLoadPlayerData(playerid)
{
    if(fire_player_data_loaded[playerid])
        return 1;

    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0)
        return 0;

    if(!fire_db_ready)
    {
        FireSystemCreateDatabase();
    }

    new query[256];
    new Cache:result;
    new bool:query_loaded = false;

    for(new attempt; attempt < 2; attempt++)
    {
        mysql_format(mysql, query, sizeof query, "SELECT `employed`, `experience`, `extinguisher_count`, `shovel_count`, `crowbar_count` FROM `mhcwork` WHERE `account_id`=%d LIMIT 1", account_id);

        result = mysql_query(mysql, query, true);
        if(!mysql_errno())
        {
            query_loaded = true;
            break;
        }

        if(result)
        {
            cache_delete(result);
        }

        if(mysql_errno() == 1054 && attempt == 0)
        {
            FireSystemCreateDatabase();
            continue;
        }

        printf("[FIRESYSTEM] Не удалось загрузить mhcwork для account_id=%d, errno=%d", account_id, mysql_errno());
        return 0;
    }

    if(!query_loaded)
        return 0;

    if(cache_num_rows())
    {
        fire_player_employed[playerid] = (cache_get_row_int(0, 0) != 0);
        fire_player_experience[playerid] = cache_get_row_int(0, 1);
        fire_player_extinguisher_count[playerid] = cache_get_row_int(0, 2);
        fire_player_shovel_count[playerid] = cache_get_row_int(0, 3);
        fire_player_crowbar_count[playerid] = cache_get_row_int(0, 4);
    }
    else
    {
        mysql_format(mysql, query, sizeof query, "INSERT INTO `mhcwork` (`account_id`, `employed`) VALUES (%d, 0)", account_id);
        mysql_query(mysql, query, false);
    }

    cache_delete(result);

    if(fire_player_extinguisher_count[playerid] < 0) fire_player_extinguisher_count[playerid] = 0;
    if(fire_player_extinguisher_count[playerid] > FIRE_EXTINGUISHER_LIMIT) fire_player_extinguisher_count[playerid] = FIRE_EXTINGUISHER_LIMIT;
    if(fire_player_shovel_count[playerid] < 0) fire_player_shovel_count[playerid] = 0;
    if(fire_player_shovel_count[playerid] > FIRE_TOOL_LIMIT) fire_player_shovel_count[playerid] = FIRE_TOOL_LIMIT;
    if(fire_player_crowbar_count[playerid] < 0) fire_player_crowbar_count[playerid] = 0;
    if(fire_player_crowbar_count[playerid] > FIRE_TOOL_LIMIT) fire_player_crowbar_count[playerid] = FIRE_TOOL_LIMIT;

    fire_player_data_loaded[playerid] = true;
    fire_player_last_ext_ammo[playerid] = fire_player_extinguisher_count[playerid];
    fire_player_inventory_dirty[playerid] = false;
    return 1;
}

stock FireSystemSyncExtData(playerid, bool:save_changes = true)
{
    if(!fire_player_data_loaded[playerid] || !fire_player_on_duty[playerid])
        return 0;

    new current_ammo = FireSystemGetWeaponAmmo(playerid, FIRE_WEAPON_EXTINGUISHER);
    new current_weapon = GetPlayerWeapon(playerid);

    if(current_ammo < 0)
        current_ammo = 0;
    if(current_ammo > FIRE_EXTINGUISHER_LIMIT)
        current_ammo = FIRE_EXTINGUISHER_LIMIT;

    if(fire_player_extinguisher_count[playerid] <= 0)
    {
        if(current_ammo > 0 || current_weapon == FIRE_WEAPON_EXTINGUISHER)
        {
            SetPlayerAmmo(playerid, FIRE_WEAPON_EXTINGUISHER, 0);
        }
        fire_player_last_ext_ammo[playerid] = 0;
        return 1;
    }

    if(current_ammo < fire_player_last_ext_ammo[playerid])
    {
        fire_player_extinguisher_count[playerid] -= (fire_player_last_ext_ammo[playerid] - current_ammo);
        if(fire_player_extinguisher_count[playerid] < 0)
            fire_player_extinguisher_count[playerid] = 0;
        fire_player_inventory_dirty[playerid] = true;
    }
    else if(current_ammo == 0 && current_weapon == FIRE_WEAPON_EXTINGUISHER)
    {
        fire_player_extinguisher_count[playerid] = 0;
        fire_player_inventory_dirty[playerid] = true;
    }

    if(current_ammo != fire_player_extinguisher_count[playerid])
    {
        FireSystemApplyExtinguisherAmmo(playerid);
    }
    else
    {
        fire_player_last_ext_ammo[playerid] = current_ammo;
    }

    if(save_changes && fire_player_inventory_dirty[playerid])
    {
        new tick = GetTickCount();
        if(tick - fire_player_last_save_tick[playerid] >= 2500)
        {
            FireSystemSavePlayerData(playerid);
        }
    }
    return 1;
}

stock FireSystemRestoreInventoryWeapons(playerid)
{
    FireSystemApplyExtinguisherAmmo(playerid);

    if(fire_player_shovel_count[playerid] > 0 && !FireSystemGetWeaponAmmo(playerid, FIRE_WEAPON_SHOVEL))
    {
        GivePlayerWeapon(playerid, FIRE_WEAPON_SHOVEL, 1);
    }

    if(fire_player_crowbar_count[playerid] > 0 && !FireSystemGetWeaponAmmo(playerid, FIRE_WEAPON_CROWBAR))
    {
        GivePlayerWeapon(playerid, FIRE_WEAPON_CROWBAR, 1);
    }

    fire_player_last_ext_ammo[playerid] = fire_player_extinguisher_count[playerid];
    return 1;
}

stock FireSystemGetWorkVehicleOwner(vehicleid)
{
    if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid))
        return INVALID_PLAYER_ID;

    foreach(new playerid : Player)
    {
        if(fire_player_gazel_vehicle[playerid] == vehicleid)
            return playerid;
    }
    return INVALID_PLAYER_ID;
}

stock bool:FireSystemIsGazelleVehicle(vehicleid)
{
    return FireSystemGetWorkVehicleOwner(vehicleid) != INVALID_PLAYER_ID;
}

stock FireSystemGetVehicleConfigIndex(modelid)
{
    for(new idx; idx < FIRE_SERVICE_VEHICLE_COUNT; idx++)
    {
        if(fire_service_vehicle_model[idx] == modelid)
            return idx;
    }
    return -1;
}



CMD:meslist(playerid)
{
 return FireSystemShowCallsMenu(playerid);
}

stock FireSystemInvitePartner(playerid, targetid)
{
    if(!fire_player_employed[playerid] || !fire_player_on_duty[playerid])
        return FireSystemSendNotEmployedNotify(playerid), 1;

    if(targetid == playerid)
        return FireSystemShowCallNotify(playerid, 2, "Нельзя пригласить самого себя."), 1;

    if(!IsPlayerConnected(targetid) || !IsPlayerLogged(targetid))
        return FireSystemShowCallNotify(playerid, 2, "Такого игрока нет."), 1;

    if(!IsPlayerInRangeOfPlayer(playerid, targetid, FIRE_PARTNER_INVITE_RANGE))
        return FireSystemShowCallNotify(playerid, 2, "Игрок находится слишком далеко."), 1;

    if(fire_player_partner[playerid] != INVALID_PLAYER_ID)
        return FireSystemShowCallNotify(playerid, 2, "У Вас уже есть напарник."), 1;

    if(!fire_player_employed[targetid] || !fire_player_on_duty[targetid])
        return FireSystemShowCallNotify(playerid, 2, "Игрок не находится на смене в МЧС."), 1;

    if(fire_player_partner[targetid] != INVALID_PLAYER_ID)
        return FireSystemShowCallNotify(playerid, 2, "У игрока уже есть напарник."), 1;

    fire_player_partner_invite_from[targetid] = playerid;
    fire_player_partner_invite_time[targetid] = gettime();

    new text[144];
    format(text, sizeof text, "Вы предложили %s стать Вашим напарником в МЧС.", GetPlayerNameEx(targetid));
    FireSystemShowCallNotify(playerid, 3, text);

    format(text, sizeof text, "Игрок %s предлагает Вам стать напарником в МЧС.", GetPlayerNameEx(playerid));
    FireSystemShowCallNotify(targetid, 3, text);

    format(text, sizeof text, "Предложение от %s", GetPlayerNameEx(playerid));
    ShowNotificationNew(targetid, 4, 6, playerid, 0, text, ">>");
    return 1;
}

CMD:mesinvite(playerid, params[])
{
    new targetid;
    if(sscanf(params, "i", targetid))
        return SendClientMessage(playerid, 0xCECECEFF, "Используйте: /mesinvite [id игрока]");

    return FireSystemInvitePartner(playerid, targetid);
}

stock FireSystem_HandleNotifyClick(playerid, notify_type, notify_id, notify_sub_id)
{
    new inviter = fire_player_partner_invite_from[playerid];
    if(inviter == INVALID_PLAYER_ID) return 0;
    if(inviter != notify_id && inviter != notify_sub_id) return 0;
    if(notify_type != 0) return 1;

    if(!IsPlayerConnected(inviter) || !IsPlayerLogged(inviter))
    {
        FireSystemResetPartnerInvite(playerid);
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Игрок недоступен", " ");
        return 1;
    }

    if(gettime() - fire_player_partner_invite_time[playerid] > FIRE_PARTNER_INVITE_TIMEOUT)
    {
        FireSystemResetPartnerInvite(playerid);
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Предложение устарело", " ");
        return 1;
    }

    if(!IsPlayerInRangeOfPlayer(playerid, inviter, FIRE_PARTNER_INVITE_RANGE))
    {
        FireSystemResetPartnerInvite(playerid);
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Игрок находится слишком далеко", " ");
        return 1;
    }

    if(!fire_player_employed[playerid] || !fire_player_on_duty[playerid])
    {
        FireSystemResetPartnerInvite(playerid);
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Сначала начните рабочий день МЧС", " ");
        return 1;
    }

    if(fire_player_active_call[playerid] != -1 || fire_player_partner[playerid] != INVALID_PLAYER_ID)
    {
        FireSystemResetPartnerInvite(playerid);
        ShowNotificationNew(playerid, 2, 6, 0, 0, "У Вас уже есть активный вызов или напарник", " ");
        return 1;
    }

    new callid = fire_player_active_call[inviter];
    fire_player_partner[playerid] = inviter;
    fire_player_partner[inviter] = playerid;
    FireSystemResetPartnerInvite(playerid);

    new text[160];
    format(text, sizeof text, "%s стал Вашим напарником в МЧС.", GetPlayerNameEx(playerid));
    SendClientMessage(inviter, -1, text);

    format(text, sizeof text, "Вы стали напарником %s в МЧС.", GetPlayerNameEx(inviter));
    SendClientMessage(playerid, -1, text);

    if(callid != -1 && fire_call_owner[callid] == inviter)
    {
        if(fire_call_partner[callid] != INVALID_PLAYER_ID)
        {
            FireSystemBreakPartnerLink(playerid);
            ShowNotificationNew(playerid, 2, 6, 0, 0, "У игрока уже есть напарник", " ");
            return 1;
        }

        if(FireSystemGetPlayerRank(playerid) < FireSystemGetCallRequiredRank(callid))
        {
            FireSystemBreakPartnerLink(playerid);
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Ваш ранг слишком мал для этого вызова", " ");
            return 1;
        }

        FireSystemAttachPartnerToCall(inviter, playerid, callid);
    }
    else
    {
        FireSystemShowCallNotify(inviter, 3, "Напарник успешно добавлен.");
        FireSystemShowCallNotify(playerid, 3, "Вы успешно стали напарником.");
    }
    return 1;
}


forward FireSystemMoveFromVeh(playerid, vehicleid);
public FireSystemMoveFromVeh(playerid, vehicleid)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    new Float:x, Float:y, Float:z, Float:a;
    if(vehicleid != INVALID_VEHICLE_ID && FireSystemIsGazelleVehicle(vehicleid))
    {
        GetVehiclePos(vehicleid, x, y, z);
        GetVehicleZAngle(vehicleid, a);

        if(z > 1000.0)
        {
            SetPlayerPosEx(playerid, x + 2.5, y + 1.5, z + 0.6, a, 1, 0);
        }
        else
        {
            SetPlayerPosEx(playerid, x + 2.5, y + 1.5, z + 0.6, a, 0, 0);
        }
    }
    else
    {
        GetPlayerPos(playerid, x, y, z);
        SetPlayerPosEx(playerid, x + 2.0, y + 2.0, z + 0.5, 0.0, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
    }
    return 1;
}

stock FireSystemEjectFromVehicle(playerid, vehicleid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER || GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
    {
        RemovePlayerFromVehicle(playerid);
    }

    SetTimerEx("FireSystemMoveFromVeh", 150, false, "ii", playerid, vehicleid);
    return 1;
}

stock FireSystemApplyVehiclesForPlayer(playerid)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    foreach(new ownerid : Player)
    {
        new vehicleid = fire_player_gazel_vehicle[ownerid];
        if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid))
            continue;

        new idx = FireSystemGetVehicleConfigIndex(GetVehicleModel(vehicleid));
        if(idx == -1)
            continue;

        SetVehicleVinylForPlayer(playerid, vehicleid, fire_service_vehicle_vinyl[idx]);
    }

    return 1;
}

forward FireSystemApplyVehiclesTimer(playerid);
public FireSystemApplyVehiclesTimer(playerid)
{
    return FireSystemApplyVehiclesForPlayer(playerid);
}

stock FireSystemScheduleVehicleSync(playerid)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    SetTimerEx("FireSystemApplyVehiclesTimer", 750, false, "i", playerid);
    return 1;
}

stock FireSystemSendEnterHint(playerid)
{
    SendClientMessage(playerid, -1, "{FFFFFF}Для {FFFF00}устройства {FFFFFF}или {FFFF00}начала рабочего дня {FFFFFF}отправляйтесь в гардероб, расположенный на {FFFF00}2-м этаже{FFFFFF}.");
    SendClientMessage(playerid, -1, "{FFFFFF}Для более подробной информации по МЧС отправляйтесь в {FFFF00}учебный класс{FFFFFF}, находящийся на {FFFF00}2-м этаже{FFFFFF}.");
    return 1;
}

stock FireSystemShowHireInfo(playerid)
{
    ShowPlayerDialog
    (
        playerid,
        FIRE_DIALOG_HIRE_INFO,
        DIALOG_STYLE_MSGBOX,
        "{E0584B}МЧС {FFFFFF}-> Информация при устройстве",
        "{FFFFFF}Вы успешно устроились на работу {FFFF00}МЧС{FFFFFF}.\n\
{FFFFFF}Для начала рабочего дня нажмите кнопку {FFFF00}'Далее' {FFFFFF}и выберите раздел {FFFF00}'Начать / Завершить рабочий день'{FFFFFF}.\n\
\n\
{FFFFFF}Более подробную информацию о работе вы сможете узнать в {FFFF00}'Кадетском корпусе' {FFFFFF}у инструктора.\n\
{FFFFFF}Инструктора вы сможете найти в {FFFF00}учебном кабинете здания МЧС{FFFFFF}.\n\
\n\
{FFFFFF}Для выполнения совместных вызовов используй радиальное меню, чтобы добавить другого игрока в группу.",
        "Далее",
        "Закрыть"
    );
    return 1;
}

stock FireSystemHirePlayer(playerid)
{
    FireSystemLoadPlayerData(playerid);
    fire_player_employed[playerid] = true;
    fire_player_on_duty[playerid] = false;
    FireSystemSavePlayerData(playerid);

    FireSystemShowHireInfo(playerid);
    SendClientMessage(playerid, -1, "{FFFF00}{FFFFFF}Вы успешно устроились на работу: {FFFF00}\"МЧС\"{FFFFFF}.");
    return 1;
}

stock FireSystemStartWorkDay(playerid)
{
    FireSystemLoadPlayerData(playerid);
    fire_player_on_duty[playerid] = true;
    SetPlayerSkin(playerid, FIRE_DUTY_SKIN_ID);
    FireSystemRestoreInventoryWeapons(playerid);

    SendClientMessage(playerid, -1, "{FFFF00}Рабочий ранг {FFFFFF}вы сможете посмотреть в разделе \"{FFFF00}Личная карточка{FFFFFF}\".");
    SendClientMessage(playerid, -1, "{FFFFFF}Для начала работы введите команду {FFFF00}/meslist {FFFFFF}и выберите {FFFF00}вызов {FFFFFF}из списка.");
    SendClientMessage(playerid, -1, "{FFFFFF}Для выполнения совместных вызовов используй радиальное меню, чтобы добавить другого игрока в группу.");
    return 1;
}

stock FireSystemEndWorkDay(playerid)
{
    FireSystemAbortActiveCall(playerid, false);
    FireSystemSyncExtData(playerid, true);
    fire_player_on_duty[playerid] = false;
    FireSystemDestroyPlayerVehicle(playerid);
    fire_player_return_textdraw_created[playerid] = false;
    SetPlayerSkinInit(playerid);
    FireSystemSavePlayerData(playerid);
    SendClientMessage(playerid, -1, "{FFFFFF}Вы завершили рабочий день {FFFF00}МЧС{FFFFFF}.");
    return 1;
}

stock FireSystemDismissPlayer(playerid)
{
    FireSystemAbortActiveCall(playerid, false);
    FireSystemSyncExtData(playerid, true);
    fire_player_employed[playerid] = false;
    fire_player_on_duty[playerid] = false;
    FireSystemDestroyPlayerVehicle(playerid);
    fire_player_return_textdraw_created[playerid] = false;
    SetPlayerSkinInit(playerid);
    FireSystemSavePlayerData(playerid);
    SendClientMessage(playerid, -1, "{FFFFFF}Вы успешно уволились с работы {FFFF00}МЧС{FFFFFF}.");
    return 1;
}
stock FireSystemShowWardrobeMenu(playerid)
{
    ShowPlayerDialog
    (
        playerid,
        FIRE_DIALOG_WARDROBE_MENU,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{E0584B}RAGE RUSSIA {FFFFFF}-> МЧС",
        "{E0584B}##\t{E0584B}Наименование\t{AFAFAF}Доступное действие\n\
{E0584B}#1.\t{FFFFFF}Устроиться/уволиться с работы\t{AFAFAF}нажмите для взаимодействия\n\
{E0584B}#2.\t{FFFFFF}Начать/закончить рабочий день\t{AFAFAF}нажмите для взаимодействия\n\
{E0584B}#3.\t{FFFFFF}Личная карточка пожарного\t{AFAFAF}нажмите для взаимодействия",
        "Выбрать",
        "Отмена"
    );
    return 1;
}

stock FireSystemGetWeaponAmmo(playerid, weaponid)
{
    new slot_weapon, slot_ammo;
    for(new slot; slot < 13; slot++)
    {
        GetPlayerWeaponData(playerid, slot, slot_weapon, slot_ammo);
        if(slot_weapon == weaponid) return slot_ammo;
    }
    return 0;
}

stock FireSystemApplyExtinguisherAmmo(playerid)
{
    if(fire_player_extinguisher_count[playerid] <= 0)
    {
        SetPlayerAmmo(playerid, FIRE_WEAPON_EXTINGUISHER, 0);
        fire_player_last_ext_ammo[playerid] = 0;
        return 1;
    }

    if(!FireSystemGetWeaponAmmo(playerid, FIRE_WEAPON_EXTINGUISHER))
    {
        GivePlayerWeapon(playerid, FIRE_WEAPON_EXTINGUISHER, 1);
    }

    SetPlayerAmmo(playerid, FIRE_WEAPON_EXTINGUISHER, fire_player_extinguisher_count[playerid]);
    return 1;
}

stock FireSystemSendInventoryNotify(playerid, type, text[], button = 0)
{
    return ShowNotificationNew(playerid, type, 4, -1, button, text, "");
}

stock FireSystemSendNotEmployedNotify(playerid)
{
    return ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не работаете в МЧС.", "");
}

stock FireSystemShowVehicleSelect(playerid)
{
    if(!fire_player_employed[playerid])
        return FireSystemSendNotEmployedNotify(playerid), 1;

    if(!fire_player_on_duty[playerid])
    {
        ShowNotificationNew(playerid, 2, 5, -1, 0, "Сначала начните рабочий день МЧС.", "");
        return 1;
    }

    ShowPlayerDialog
    (
        playerid,
        FIRE_DIALOG_VEHICLE_SELECT,
        DIALOG_STYLE_LIST,
        "{E0584B}Black Russia {555555}RolePlay {FFFFFF}-> Транспорт МЧС",
        "Пожарная машина\nГазель МЧС",
        "Выбрать",
        "Закрыть"
    );
    return 1;
}

stock FireSystemSpawnSelectedVehicle(playerid, listitem)
{
    if(!fire_player_employed[playerid])
        return FireSystemSendNotEmployedNotify(playerid), 1;

    if(!fire_player_on_duty[playerid])
    {
        ShowNotificationNew(playerid, 2, 5, -1, 0, "Сначала начните рабочий день МЧС.", "");
        return 1;
    }

    if(listitem < 0 || listitem >= FIRE_SERVICE_VEHICLE_COUNT)
        return 1;

    FireSystemDestroyPlayerVehicle(playerid);

    new Float:x, Float:y, Float:z, Float:a;
    if(fire_service_vehicle_model[listitem] == 407)
    {
        x = -2544.760253;
        y = -298.006347;
        z = 27.252866;
        a = 272.136657;
    }
    else
    {
        x = -2555.097412;
        y = -296.718231;
        z = 27.292865;
        a = 270.034210;
    }

    new vehicleid = CreateVehicle
    (
        fire_service_vehicle_model[listitem],
        x, y, z, a,
        1, 3, -1
    );

    if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid))
    {
        ShowNotificationNew(playerid, 2, 5, -1, 0, "Не удалось создать рабочий транспорт МЧС.", "");
        return 1;
    }

    LinkVehicleToInterior(vehicleid, 0);
    SetVehicleVirtualWorld(vehicleid, 0);
    fire_player_gazel_vehicle[playerid] = vehicleid;
    fire_player_driver_vehicle[playerid] = vehicleid;

    foreach(new viewerid : Player)
    {
        SetVehicleVinylForPlayer(viewerid, vehicleid, fire_service_vehicle_vinyl[listitem]);
    }

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    PutPlayerInVehicle(playerid, vehicleid, 0);
    FireSystemClearVehicleReturnTimer(playerid);

    if(fire_service_vehicle_model[listitem] == 407)
        ShowNotificationNew(playerid, 3, 5, -1, 0, "Вы получили пожарную машину МЧС.", "");
    else
        ShowNotificationNew(playerid, 3, 5, -1, 0, "Вы получили Газель МЧС.", "");

    SendClientMessage(playerid, -1, "{FFFF00}|{FFFFFF} Используйте {FFFF00}/meslist {FFFFFF}для просмотра активных вызовов.");
    return 1;
}


stock FireSystemShowInventoryMenu(playerid, bool:sync_weapons = true)
{
    FireSystemLoadPlayerData(playerid);
    if(sync_weapons)
    {
        FireSystemSyncExtData(playerid);
    }
    new Float:armour;
    new body[512];
    GetPlayerArmour(playerid, armour);

    new extinguisher = fire_player_extinguisher_count[playerid];

    format
    (
        body,
        sizeof body,
        "{E0584B}##\t{E0584B}Наименование\t{AFAFAF}Количество\n\
{E0584B}#1.\t{FFFFFF}Огнетушитель\t{FFFFFF}%d/%d\n\
{E0584B}#2.\t{FFFFFF}Лопата\t{FFFFFF}%d/%d\n\
{E0584B}#3.\t{FFFFFF}Лом\t{FFFFFF}%d/%d\n\
{E0584B}-\t{FFFFFF}Восстановить костюм\t{FFFFFF}%d/100",
        extinguisher,
        FIRE_EXTINGUISHER_LIMIT,
        fire_player_shovel_count[playerid],
        FIRE_TOOL_LIMIT,
        fire_player_crowbar_count[playerid],
        FIRE_TOOL_LIMIT,
        floatround(armour)
    );

    ShowPlayerDialog
    (
        playerid,
        FIRE_DIALOG_INVENTORY,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{E0584B}RAGE RUSSIA {FFFFFF}-> МЧС инвентарь",
        body,
        "Выбрать",
        "Отмена"
    );
    return 1;
}

stock FireSystemTakeInventoryItem(playerid, item)
{
    if(!fire_player_employed[playerid]) return FireSystemSendNotEmployedNotify(playerid), 1;
    FireSystemLoadPlayerData(playerid);

    switch(item)
    {
        case 0:
        {
            if(fire_player_extinguisher_count[playerid] >= FIRE_EXTINGUISHER_LIMIT)
            {
                FireSystemSendInventoryNotify(playerid, 2, "У Вас максимальное количество огнетушителя.");
                FireSystemShowInventoryMenu(playerid, false);
                return 1;
            }

            new add_ammo = FIRE_EXTINGUISHER_STEP;
            if(fire_player_extinguisher_count[playerid] + add_ammo > FIRE_EXTINGUISHER_LIMIT)
            {
                add_ammo = FIRE_EXTINGUISHER_LIMIT - fire_player_extinguisher_count[playerid];
            }

            fire_player_extinguisher_count[playerid] += add_ammo;
            fire_player_inventory_dirty[playerid] = true;
            FireSystemApplyExtinguisherAmmo(playerid);
            FireSystemSavePlayerData(playerid);
            FireSystemSendInventoryNotify(playerid, 3, "Вы взяли Огнетушитель.");
            FireSystemShowInventoryMenu(playerid, false);
            return 1;
        }
        case 1:
        {
            if(fire_player_shovel_count[playerid] >= FIRE_TOOL_LIMIT)
            {
                FireSystemSendInventoryNotify(playerid, 2, "У Вас максимальное количество.");
                FireSystemShowInventoryMenu(playerid, false);
                return 1;
            }

            fire_player_shovel_count[playerid]++;
            fire_player_inventory_dirty[playerid] = true;
            GivePlayerWeapon(playerid, FIRE_WEAPON_SHOVEL, 1);
            FireSystemSavePlayerData(playerid);
            FireSystemSendInventoryNotify(playerid, 3, "Вы взяли Лопата.", 1);
            FireSystemShowInventoryMenu(playerid, false);
            return 1;
        }
        case 2:
        {
            if(fire_player_crowbar_count[playerid] >= FIRE_TOOL_LIMIT)
            {
                FireSystemSendInventoryNotify(playerid, 2, "У Вас максимальное количество.");
                FireSystemShowInventoryMenu(playerid, false);
                return 1;
            }

            fire_player_crowbar_count[playerid]++;
            fire_player_inventory_dirty[playerid] = true;
            GivePlayerWeapon(playerid, FIRE_WEAPON_CROWBAR, 1);
            FireSystemSavePlayerData(playerid);
            FireSystemSendInventoryNotify(playerid, 3, "Вы взяли Лом.");
            FireSystemShowInventoryMenu(playerid, false);
            return 1;
        }
        case 3:
        {
            new Float:armour;
            GetPlayerArmour(playerid, armour);
            if(armour >= 99.5)
            {
                FireSystemSendInventoryNotify(playerid, 2, "Вам не требуется восстановление костюма.");
                FireSystemShowInventoryMenu(playerid, false);
                return 1;
            }

            SetPlayerArmour(playerid, 100.0);
            FireSystemSendInventoryNotify(playerid, 3, "Вы восстановили костюм.");
            FireSystemShowInventoryMenu(playerid, false);
            return 1;
        }
    }
    return 1;
}
stock FireSystemShowPersonalCard(playerid)
{
    FireSystemLoadPlayerData(playerid);
    new title[128];
    new body[256];
    new rank = FireSystemGetPlayerRank(playerid);
    new next_need = rank >= 3 ? FIRE_NEXT_CLASS_EXPERIENCE * 3 : FIRE_NEXT_CLASS_EXPERIENCE * rank;
    new current_exp = fire_player_experience[playerid];
    if(rank >= 3 && current_exp > next_need) current_exp = next_need;

    format(title, sizeof title, "{E0584B}RAGE RUSSIA {FFFFFF}-> Личная карточка пожарного %s", GetPlayerNameEx(playerid));
    format
    (
        body,
        sizeof body,
        "{FFFF00}1. {FFFFFF}Занимаемая должность: {FFFF00}Курсант (%d)\n\
{FFFF00}2. {FFFFFF}Необходимое количество навыков для открытия следующего класса: {FFFF00}%d/{FFFFFF}%d",
        rank,
        current_exp,
        next_need
    );

    ShowPlayerDialog(playerid, FIRE_DIALOG_PERSONAL_CARD, DIALOG_STYLE_MSGBOX, title, body, "Закрыть", "");
    return 1;
}

stock FireSystemShowCadetMenu(playerid)
{
    ShowPlayerDialog
    (
        playerid,
        FIRE_DIALOG_CADET_MENU,
        DIALOG_STYLE_LIST,
        "{E0584B}МЧС {FFFFFF}-> Кадетский корпус",
        "{E0584B}1. {FFFFFF}Общая информация\n\
{E0584B}2. {FFFFFF}Рабочий инвентарь\n\
{E0584B}3. {FFFFFF}Рабочий опыт\n\
{E0584B}4. {FFFFFF}Список вызовов\n\
{E0584B}5. {FFFFFF}Задания\n\
{E0584B}6. {FFFFFF}Уровни пожаров\n\
{E0584B}7. {FFFFFF}Кооперативная игра\n\
{E0584B}8. {FFFFFF}Игровой процесс",
        "Выбрать",
        "Закрыть"
    );
    return 1;
}

stock FireSystemShowCadetTopic(playerid, topic)
{
    new title[96];
    new body[2048];

    switch(topic)
    {
        case 0:
        {
            format(title, sizeof title, "{E0584B}МЧС {FFFFFF}-> Общая информация");
            format
            (
                body,
                sizeof body,
                "{FFFF00}Устройство на работу\n\
{FFFFFF}Для трудоустройства на работу МЧС Вам необязательно посещать мэрию.\n\
Теперь вы сможете устроиться прямо на самой работе!\n\
Устройство на работу доступно {FFFF00}с 5 уровня.\n\
\n\
Начало рабочего дня\n\
{FFFFFF}Начать рабочий день можно после трудоустройства на работу. Для этого найдите пикап {FFFF00}гардероба {FFFFFF}и переоденьтесь в костюм пожарного.\n\
\n\
{FFFF00}Завершение рабочего дня\n\
{FFFFFF}Для завершения рабочего дня, встаньте на пикап {FFFF00}гардероба {FFFFFF}и переоденьтесь.\n\
\n\
{FFFF00}Зарплаты\n\
{FFFFFF}Денежные средства начисляются за каждый успешно или неуспешно завершенный вызов в зависимости от вашего рабочего ранга.\n\
Также вы сможете {FFFF00}увеличить свою зарплату{FFFFFF}, выполняя дополнительные задания на вызовах."
            );
        }
        case 1:
        {
            format(title, sizeof title, "{E0584B}МЧС {FFFFFF}-> Рабочий инвентарь");
            format
            (
                body,
                sizeof body,
                "{FFFF00}Рабочий инвентарь игрока.\n\
{FFFFFF}Состоит из 3-х предметов.\n\
\n\
{FFFF00}Огнетушитель {FFFFFF}- используется для тушения очагов возгорания 1 и 2 уровня.\n\
Очаг возгорания 3 уровня можно затушить только при помощи пожарной машины.\n\
\n\
{FFFF00}Саперная лопата {FFFFFF}- используется для расчистки завалов в зонах возгорания.\n\
Одной лопатой можно расчистить 10 завалов, после чего предмет будет удален.\n\
\n\
{FFFF00}Лом {FFFFFF}- используется для вскрытия заблокированных дверей в зонах возгорания.\n\
Одним ломом можно вскрыть 10 дверей, после чего предмет будет удален.\n\
\n\
{FFFF00}Рабочий инвентарь можно взять на складе.\n\
{FFFFFF}После выдачи рабочий инвентарь сохраняется у игрока до завершения рабочего дня.\n\
{FFFF00}Состояние костюма\n\
{FFFFFF}Если ваш костюм был поврежден, то вы также сможете восстановить его на складе."
            );
        }
        case 2:
        {
            format(title, sizeof title, "{E0584B}МЧС {FFFFFF}-> Рабочий опыт");
            format
            (
                body,
                sizeof body,
                "{FFFF00}Рабочий опыт {FFFFFF}начисляется за успешно выполненные вызовы.\n\
Количество получаемых очков зависит от уровня вызовов, а также сложности и опасности горящего объекта.\n\
Выполняйте {FFFF00}дополнительные задания{FFFFFF}, чтобы получать {FFFF00}дополнительные очки рабочего опыта."
            );
        }
        case 3:
        {
            format(title, sizeof title, "{E0584B}МЧС {FFFFFF}-> Список вызовов");
            format
            (
                body,
                sizeof body,
                "{FFFF00}Список вызовов {FFFFFF}формируется автоматически.\n\
После завершения задания вызов пропадает из списка на определенное время, а потом вновь появляется в списке вызовов."
            );
        }
        case 4:
        {
            format(title, sizeof title, "{E0584B}МЧС {FFFFFF}-> Задания");
            format
            (
                body,
                sizeof body,
                "{FFFF00}Задания {FFFFFF}подразделяются на {FFFF00}основные {FFFFFF}и {FFFF00}дополнительные.\n\
\n\
{FFFF00}Цель основного задания {FFFFFF}- затушить все очаги возгорания на горящем объекте.\n\
\n\
{FFFF00}Цель дополнительного задания {FFFFFF}- побочные активности. Например, спасти пострадавшего или расчистить завал.\n\
{FFFF00}Цель дополнительных заданий {FFFFFF}- получить больше очков рабочего опыта по завершению основного задания.\n\
Дополнительное задание засчитывается в том случае, если игрок его выполнил, а очки начисляются индивидуально за каждое выполненное задание.\n\
\n\
Выполнив все {FFFF00}основные задания, {FFFFFF}вызов будет завершенным, а оставшиеся {FFFF00}дополнительные задания {FFFFFF}будут считаться не выполненными!"
            );
        }
        case 5:
        {
            format(title, sizeof title, "{E0584B}МЧС {FFFFFF}-> Уровни пожаров");
            format
            (
                body,
                sizeof body,
                "{FFFFFF}Пожары подразделяются на 3 уровня:\n\
\n\
{FFFF00}Очаг возгорания 1 уровня.\n\
{FFFFFF}Имеет небольшой размер. Можно тушить из огнетушителя.\n\
Он не так опасен, но если подойти слишком близко в незащищенном костюме, то можно получить урон от огня.\n\
Также данный очаг нельзя тушить при помощи пожарной машины.\n\
\n\
{FFFF00}Очаг возгорания 2 уровня.\n\
{FFFFFF}Более опасен и имеет средний размер, близко подходить к такому огню опасно, а тушить можно также из огнетушителя.\n\
Также данный очаг нельзя тушить при помощи пожарной машины.\n\
\n\
{FFFF00}Очаг возгорания 3 уровня.\n\
{FFFFFF}Является самым большим и самым опасным. Подходить к нему близко категорически запрещено, а тушить можно только при помощи пожарного автомобиля.\n\
Как правило такие очаги располагаются на открытых участках с доступным подъездом для тушения.\n\
\n\
{FFFF00}Примечание: {FFFFFF}Очаги 1 и 2 уровня можно тушить только при помощи огнетушителя. Из пожарного автомобиля очаги не потушить!"
            );
        }
        case 6:
        {
            format(title, sizeof title, "{E0584B}МЧС {FFFFFF}-> Кооперативная игра");
            format
            (
                body,
                sizeof body,
                "{FFFFFF}Играйте совместно с другими игроками и получайте {FFFF00}в 2 раза больше выплат{FFFFFF}, чем в одиночной игре.\n\
Для выполнения совместных вызовов используй радиальное меню, чтобы добавить другого игрока в группу.\n\
{FFFFFF}В команду можно пригласить только 1 напарника!"
            );
        }
        case 7:
        {
            format(title, sizeof title, "{E0584B}МЧС {FFFFFF}-> Игровой процесс");
            format
            (
                body,
                sizeof body,
                "{FFFFFF}Устраняя пожар - будь аккуратен! Так как огонь очень горячий, он распространяет {FFFF00}тепловую зону.\n\
{FFFFFF}Попав в тепловую зону - ты превратишься в пепел!\n\
В процессе выполнения основного задания, связанного с тушением очагов возгорания, к выполнению тебе будут доступны {FFFF00}дополнительные задания.\n\
{FFFFFF}За дополнительные задания ты сможешь получить {FFFF00}дополнительные награды.\n\
{FFFFFF}Также в процессе тушения тебе может потребоваться {FFFF00}пожарная машина {FFFFFF}с\n\
ручным управлением для устранения огромных очагов, встречающихся {FFFF00}на 3 уровне сложности.\n\
{FFFFFF}Будь внимателен, так как вода в транспорте может закончиться.\n\
Если вода закончится - отправляйся к ближайшей водонапорной вышке или пожарному гидранту, чтобы пополнить запасы, и продолжай работу!\n\
\n\
Теперь ты полностью готов к работе. Успешной службы!"
            );
        }
    }

    SetPVarInt(playerid, "fire_cadet_topic", topic);
    ShowPlayerDialog(playerid, FIRE_DIALOG_CADET_TOPIC, DIALOG_STYLE_MSGBOX, title, body, "Назад", "");
    return 1;
}

stock FireSystemCreateVehicles()
{
    // V11 MCHS garage fix: work vehicles are no longer spawned inside the garage.
    // The employee selects one at the garage marker and receives it outside.
    for(new idx; idx < FIRE_SERVICE_VEHICLE_COUNT; idx++)
    {
        fire_service_vehicles[idx] = INVALID_VEHICLE_ID;
    }
    return 1;
}

public OnPlayerConnect(playerid)
{
    FireSystemResetPlayer(playerid);
    FireSystemScheduleVehicleSync(playerid);

    #if defined firesys_OnPlayerConnect
        return firesys_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect firesys_OnPlayerConnect
#if defined firesys_OnPlayerConnect
    forward firesys_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
    FireSystemAbortActiveCall(playerid, false);
    FireSystemSyncExtData(playerid, true);
    FireSystemSavePlayerData(playerid);
    FireSystemResetPlayer(playerid);

    #if defined firesys_OnPlayerDisconnect
        return firesys_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect firesys_OnPlayerDisconnect
#if defined firesys_OnPlayerDisconnect
    forward firesys_OnPlayerDisconnect(playerid, reason);
#endif

public OnPlayerSpawn(playerid)
{
    FireSystemLoadPlayerData(playerid);
    if(fire_player_on_duty[playerid])
    {
        SetPlayerSkin(playerid, FIRE_DUTY_SKIN_ID);
        FireSystemRestoreInventoryWeapons(playerid);

        if(fire_player_active_call[playerid] != -1)
        {
            FireSystemShowCallTutorial(playerid);
            FireSystemUpdateOverTimeTD(playerid);
            EnablePlayerGPS
            (
                playerid,
                55,
                fire_call_pos[fire_player_active_call[playerid]][0],
                fire_call_pos[fire_player_active_call[playerid]][1],
                fire_call_pos[fire_player_active_call[playerid]][2],
                ""
            );
        }
    }

    FireSystemScheduleVehicleSync(playerid);

    #if defined firesys_OnPlayerSpawn
        return firesys_OnPlayerSpawn(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn firesys_OnPlayerSpawn
#if defined firesys_OnPlayerSpawn
    forward firesys_OnPlayerSpawn(playerid);
#endif

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == FIRE_DIALOG_CALLS_LIST)
    {
        return FireSystemProcessCallDialog(playerid, response, listitem);
    }

    if(dialogid == FIRE_DIALOG_GAZEL_RENT)
    {
        // Legacy enter-the-vehicle rental path is disabled.
        DeletePVar(playerid, "fire_rent_vehicleid");
        return 1;
    }

    if(dialogid == FIRE_DIALOG_VEHICLE_SELECT)
    {
        if(!response) return 1;
        return FireSystemSpawnSelectedVehicle(playerid, listitem);
    }

    if(dialogid == FIRE_DIALOG_WARDROBE_MENU)
    {
        if(!response) return 1;

        switch(listitem)
        {
            case 0:
            {
                if(!fire_player_employed[playerid])
                {
                    FireSystemHirePlayer(playerid);
                }
                else
                {
                    ShowPlayerDialog
                    (
                        playerid,
                        FIRE_DIALOG_FIRE_CONFIRM,
                        DIALOG_STYLE_MSGBOX,
                        "{E0584B}МЧС {FFFFFF}-> Увольнение",
                        "{FFFFFF}Вы действительно хотите уволиться с работы {FFFF00}МЧС{FFFFFF}?",
                        "Да",
                        "Нет"
                    );
                }
            }
            case 1:
            {
                if(!fire_player_employed[playerid])
                    return SendClientMessage(playerid, -1, "{FFFFFF}Сначала устройтесь на работу {FFFF00}МЧС{FFFFFF}."), 1;

                if(!fire_player_on_duty[playerid])
                {
                    FireSystemStartWorkDay(playerid);
                }
                else
                {
                    FireSystemEndWorkDay(playerid);
                }
            }
            case 2:
            {
                if(!fire_player_employed[playerid])
                    return SendClientMessage(playerid, -1, "{FFFFFF}Сначала устройтесь на работу {FFFF00}МЧС{FFFFFF}."), 1;

                FireSystemShowPersonalCard(playerid);
            }
        }
        return 1;
    }

    if(dialogid == FIRE_DIALOG_INVENTORY)
    {
        if(response) FireSystemTakeInventoryItem(playerid, listitem);
        return 1;
    }

    if(dialogid == FIRE_DIALOG_FIRE_CONFIRM)
    {
        if(response)
        {
            FireSystemDismissPlayer(playerid);
        }
        return 1;
    }

    if(dialogid == FIRE_DIALOG_CADET_MENU)
    {
        if(response)
        {
            FireSystemShowCadetTopic(playerid, listitem);
        }
        return 1;
    }

    if(dialogid == FIRE_DIALOG_CADET_TOPIC)
    {
        if(response)
        {
            FireSystemShowCadetMenu(playerid);
        }
        return 1;
    }

    #if defined firesys_OnDialogResponse
        return firesys_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    #else
        return 0;
    #endif
}
#if defined _ALS_OnDialogResponse
    #undef OnDialogResponse
#else
    #define _ALS_OnDialogResponse
#endif
#define OnDialogResponse firesys_OnDialogResponse
#if defined firesys_OnDialogResponse
    forward firesys_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

forward FireSystemVehicleReturnTimer(playerid);
public FireSystemVehicleReturnTimer(playerid)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    new vehicleid = fire_player_gazel_vehicle[playerid];
    if(vehicleid == INVALID_VEHICLE_ID || !FireSystemIsGazelleVehicle(vehicleid))
    {
        FireSystemClearVehicleReturnTimer(playerid);
        return 0;
    }

    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) == vehicleid)
    {
        FireSystemClearVehicleReturnTimer(playerid);
        return 1;
    }

    fire_player_return_time[playerid]--;

    if(fire_player_return_time[playerid] <= 0)
    {
        FireSystemClearVehicleReturnTimer(playerid);
        fire_player_gazel_vehicle[playerid] = INVALID_VEHICLE_ID;
        fire_player_driver_vehicle[playerid] = INVALID_VEHICLE_ID;
        if(IsValidVehicle(vehicleid)) DestroyVehicle(vehicleid);
        ShowNotificationNew(playerid, 2, 5, -1, 0, "Вы не вернулись в автомобиль МЧС. Транспорт возвращен в автопарк.", "");
        return 1;
    }

    FireSystemShowVehicleReturnText(playerid);
    return 1;
}

stock FireSystemStartRetTimer(playerid, vehicleid)
{
    if(fire_player_on_duty[playerid])
        return 0;

    if(fire_player_active_call[playerid] != -1)
        return 0;

    if(vehicleid == INVALID_VEHICLE_ID || !FireSystemIsGazelleVehicle(vehicleid))
        return 0;

    if(fire_player_gazel_vehicle[playerid] != vehicleid)
        return 0;

    if(fire_player_return_timer[playerid])
        return 1;

    fire_player_return_time[playerid] = FIRE_RETURN_VEHICLE_TIME;

    SendClientMessage(playerid, -1, "{FFFF00}{FFFFFF}У вас есть {FFFF00}60{FFFFFF} секунд чтобы вернуться в автомобиль.");
    FireSystemShowVehicleReturnText(playerid);

    fire_player_return_timer[playerid] = SetTimerEx("FireSystemVehicleReturnTimer", 1000, true, "i", playerid);
    return 1;
}

stock FireSystemQueueRetCheck(playerid, vehicleid)
{
    if(fire_player_on_duty[playerid])
        return 0;

    if(fire_player_active_call[playerid] != -1)
        return 0;

    if(vehicleid == INVALID_VEHICLE_ID || !FireSystemIsGazelleVehicle(vehicleid))
        return 0;

    if(fire_player_gazel_vehicle[playerid] != vehicleid)
        return 0;

    if(fire_player_return_timer[playerid])
        return 1;

    SetTimerEx("FireSystemReturnDelay", 250, false, "ii", playerid, vehicleid);
    return 1;
}

forward FireSystemReturnDelay(playerid, vehicleid);
public FireSystemReturnDelay(playerid, vehicleid)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    if(fire_player_on_duty[playerid])
        return 0;

    if(fire_player_active_call[playerid] != -1)
        return 0;

    if(vehicleid == INVALID_VEHICLE_ID || !FireSystemIsGazelleVehicle(vehicleid))
        return 0;

    if(fire_player_gazel_vehicle[playerid] != vehicleid)
        return 0;

    if(fire_player_return_timer[playerid])
        return 1;

    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) == vehicleid)
        return 1;

    return FireSystemStartRetTimer(playerid, vehicleid);
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(oldstate == PLAYER_STATE_DRIVER && newstate != PLAYER_STATE_DRIVER)
    {
        new old_vehicleid = fire_player_driver_vehicle[playerid];
        if(old_vehicleid != INVALID_VEHICLE_ID && FireSystemIsGazelleVehicle(old_vehicleid) && fire_player_gazel_vehicle[playerid] == old_vehicleid)
        {
            if(fire_player_active_call[playerid] == -1)
            {
                FireSystemQueueRetCheck(playerid, old_vehicleid);
            }
        }
        fire_player_driver_vehicle[playerid] = INVALID_VEHICLE_ID;
    }

    if(newstate == PLAYER_STATE_DRIVER && oldstate != PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        fire_player_driver_vehicle[playerid] = vehicleid;

        if(FireSystemIsGazelleVehicle(vehicleid))
        {
            if(!fire_player_employed[playerid] || !fire_player_on_duty[playerid])
            {
                ShowNotificationNew(playerid, 2, 5, -1, 0, "Транспорт доступен только сотрудникам МЧС на смене.", "");
                FireSystemEjectFromVehicle(playerid, vehicleid);
                fire_player_driver_vehicle[playerid] = INVALID_VEHICLE_ID;
                return 1;
            }

            if(fire_player_gazel_vehicle[playerid] != vehicleid)
            {
                ShowNotificationNew(playerid, 2, 5, -1, 0, "Этот рабочий транспорт уже закреплен за другим сотрудником МЧС.", "");
                FireSystemEjectFromVehicle(playerid, vehicleid);
                fire_player_driver_vehicle[playerid] = INVALID_VEHICLE_ID;
                return 1;
            }

            FireSystemClearVehicleReturnTimer(playerid);
            return 1;
        }
    }

    #if defined firesys_OnPlayerStateChange
        return firesys_OnPlayerStateChange(playerid, newstate, oldstate);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerStateChange
    #undef OnPlayerStateChange
#else
    #define _ALS_OnPlayerStateChange
#endif
#define OnPlayerStateChange firesys_OnPlayerStateChange
#if defined firesys_OnPlayerStateChange
    forward firesys_OnPlayerStateChange(playerid, newstate, oldstate);
#endif

public OnPlayerExitVehicle(playerid, vehicleid)
{
    if(FireSystemIsGazelleVehicle(vehicleid) && fire_player_gazel_vehicle[playerid] == vehicleid && fire_player_active_call[playerid] == -1)
    {
        FireSystemQueueRetCheck(playerid, vehicleid);
    }

    #if defined firesys_OnPlayerExitVehicle
        return firesys_OnPlayerExitVehicle(playerid, vehicleid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerExitVehicle
    #undef OnPlayerExitVehicle
#else
    #define _ALS_OnPlayerExitVehicle
#endif
#define OnPlayerExitVehicle firesys_OnPlayerExitVehicle
#if defined firesys_OnPlayerExitVehicle
    forward firesys_OnPlayerExitVehicle(playerid, vehicleid);
#endif

public OnPlayerUpdate(playerid)
{
    FireSystemSyncExtData(playerid, true);
    FireSystemTryExtinguish(playerid);

    #if defined firesys_OnPlayerUpdate
        return firesys_OnPlayerUpdate(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerUpdate
    #undef OnPlayerUpdate
#else
    #define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate firesys_OnPlayerUpdate
#if defined firesys_OnPlayerUpdate
    forward firesys_OnPlayerUpdate(playerid);
#endif
public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(areaid == fire_enter_sphere)
    {
        SetPlayerPosEx(playerid, -2600.038330, -280.123840, 1246.720458, 358.409942, 1, 0);
        FireSystemSendEnterHint(playerid);
        FireSystemScheduleVehicleSync(playerid);
        return 1;
    }

    if(areaid == fire_exit_sphere)
    {
        SetPlayerPosEx(playerid, -2552.739990, -284.766265, 27.394428, 270.055450, 0, 0);
        return 1;
    }

    if(areaid == fire_wardrobe_sphere)
    {
        FireSystemShowWardrobeMenu(playerid);
        return 1;
    }

    if(areaid == fire_inventory_sphere)
    {
        if(!fire_player_employed[playerid]) return FireSystemSendNotEmployedNotify(playerid), 1;
        FireSystemShowInventoryMenu(playerid);
        return 1;
    }

    if(areaid == fire_vehicle_sphere)
    {
        FireSystemShowVehicleSelect(playerid);
        return 1;
    }

    if(areaid == fire_instructor_sphere)
    {
        FireSystemShowCadetMenu(playerid);
        return 1;
    }

    #if defined firesys_OnPlayerEnterDynamicArea
        return firesys_OnPlayerEnterDynamicArea(playerid, areaid);
    #else
        return 0;
    #endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea firesys_OnPlayerEnterDynamicArea
#if defined firesys_OnPlayerEnterDynamicArea
    forward firesys_OnPlayerEnterDynamicArea(playerid, areaid);
#endif

public OnGameModeInit()
{
	#if defined firesys_OnGameModeInit
		firesys_OnGameModeInit();
	#endif

    FireSystemCreateDatabase();
    FireSystemInitCalls();

    for(new callid; callid < FIRE_MAX_CALLS; callid++)
    {
        FireSystemSpawnCallObjects(callid);
    }

    CreateDynamicPickup(19132, 23, -2557.969238, -284.699520, 27.394428, 0, 0);
    fire_enter_sphere = CreateDynamicSphere(-2557.969238, -284.699520, 27.394428, 1.2, 0, 0);
    CreateDynamic3DTextLabel("{FFFF00}Вход в здание МЧС\n\n{FFFFFF}Подойдите чтобы {FFFF00}войти.", -1, -2557.969238, -284.699520, 27.394428, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0);

    CreateDynamicPickup(19132, 23, -2600.051757, -283.558868, 1246.720458, 0, 1);
    fire_exit_sphere = CreateDynamicSphere(-2600.051757, -283.558868, 1246.720458, 1.2, 0, 1);
    CreateDynamic3DTextLabel("{FFFF00}Выход из здания МЧС\n\n{FFFFFF}Подойдите чтобы {FFFF00}выйти.", -1, -2600.051757, -283.558868, 1246.720458, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 1);

    CreateDynamicPickup(1275, 23, -2615.686523, -282.474395, 1252.083862, 0, 1);
    fire_wardrobe_sphere = CreateDynamicSphere(-2615.686523, -282.474395, 1252.083862, 1.5, 0, 1);
    CreateDynamic3DTextLabel("{FFFF00}Гардероб МЧС\n\n{FFFFFF}Подойдите для {FFFF00}взаимодействия.", -1, -2615.686523, -282.474395, 1252.083862, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 1);

    CreateDynamicPickup(1239, 23, -2622.180175, -276.620086, 1246.723144, 0, 1);
    fire_vehicle_sphere = CreateDynamicSphere(-2622.180175, -276.620086, 1246.723144, 1.8, 0, 1);
    CreateDynamic3DTextLabel("{FFFF00}Рабочий транспорт МЧС\n\n{FFFFFF}Подойдите, чтобы {FFFF00}выбрать автомобиль.", -1, -2622.180175, -276.620086, 1247.623144, 7.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 1);

    CreateDynamicPickup(FIRE_INVENTORY_PICKUP_MODEL, 23, -2605.152832, -281.472106, 1252.083862, 0, 1);
    fire_inventory_sphere = CreateDynamicSphere(-2605.152832, -281.472106, 1252.083862, 1.5, 0, 1);
    CreateDynamic3DTextLabel("{FFFF00}Склад МЧС\n\n{FFFFFF}Подойдите для {FFFF00}взаимодействия.{FFFF00}", -1, -2605.152832, -281.472106, 1252.083862, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 1);

    fire_instructor_actor = CreateActorEx("{FFFF00}Инструктор МЧС", "{FFFFFF}Подойдите для {FFFF00}взаимодействия.", 19275, -2623.872802, -270.104125, 1252.083862, 168.477981, 0, 1);
    fire_instructor_sphere = CreateDynamicSphere(-2623.872802, -270.104125, 1252.083862, 2.0, 0, 1);

    FireSystemCreateVehicles();
	return 1;
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit firesys_OnGameModeInit
#if defined firesys_OnGameModeInit
    forward firesys_OnGameModeInit();
#endif
