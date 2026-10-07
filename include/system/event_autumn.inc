// ============================================================================
// SAME RUSSIA - Autumn Event 2026
// "Золотой след: Тайна старого тракта"
// Standalone event logic for client build 1621.
// GUI: 63 (NPC conversation), 31 (progress), GPS/waypoint from current gamemode.
// ============================================================================

#if defined _AUTUMN_EVENT_INCLUDED
    #endinput
#endif
#define _AUTUMN_EVENT_INCLUDED

#define AUTUMN_EVENT_NAME                 "Золотой след: Тайна старого тракта"
#define AUTUMN_EVENT_SHORT                "Золотой след"
#define AUTUMN_EVENT_DATE                 "30.11.2026"
#define AUTUMN_EVENT_MAX_NPCS             (32)
#define AUTUMN_EVENT_ROLE_COUNT           (6)
#define AUTUMN_EVENT_START_NPCS           (6)
#define AUTUMN_EVENT_START_MODEL 6840
#define AUTUMN_EVENT_CLUES                (3)
#define AUTUMN_EVENT_DELIVERY_POINTS      (3)
#define AUTUMN_EVENT_PROGRESS_TIME        (5000)
#define AUTUMN_EVENT_INTERACTION_RADIUS   (3.2)
#define AUTUMN_EVENT_ADMIN_LEVEL          (13)
#define AUTUMN_EVENT_FINAL_MONEY          (15000000)
#define AUTUMN_EVENT_FINAL_BC             (15000)
#define AUTUMN_EVENT_FINAL_EXP            (15)
#define AUTUMN_EVENT_STAGE_MONEY          (1000000)
#define AUTUMN_EVENT_STAGE_BC             (300)

#define AUTUMN_STAGE_NOT_STARTED          (0)
#define AUTUMN_STAGE_CLUES                (1)
#define AUTUMN_STAGE_ALICE                (2)
#define AUTUMN_STAGE_MECHANIC             (3)
#define AUTUMN_STAGE_HUNTER               (4)
#define AUTUMN_STAGE_DELIVERY             (5)
#define AUTUMN_STAGE_TERMINAL              (6)
#define AUTUMN_STAGE_FINAL                (7)
#define AUTUMN_STAGE_COMPLETED            (8)

#define AUTUMN_PROGRESS_NONE              (0)
#define AUTUMN_PROGRESS_CLUE              (1)
#define AUTUMN_PROGRESS_MECHANIC          (2)
#define AUTUMN_PROGRESS_NODE              (3)
#define AUTUMN_PROGRESS_FINALPOINT        (4)
#define AUTUMN_PROGRESS_TERMINAL_REPAIR    (5)
#define AUTUMN_PROGRESS_TERMINAL_BOOT      (6)

#define AUTUMN_GUI_CLOSE                  (7199)
#define AUTUMN_GUI_INTRO_ROUTE            (7090)
#define AUTUMN_GUI_START                  (7100)
#define AUTUMN_GUI_ABOUT                  (7101)
#define AUTUMN_GUI_ALICE_CONTINUE         (7110)
#define AUTUMN_GUI_MECHANIC_INSPECT       (7120)
#define AUTUMN_GUI_HUNTER_START           (7130)
#define AUTUMN_GUI_HOST_CONTINUE          (7135)
#define AUTUMN_GUI_FINAL_REWARD           (7140)
#define AUTUMN_GUI_REFRESH_ROUTE          (7150)
#define AUTUMN_GUI_REWARD_CLOSE           (7160)
#define DIALOG_AUTUMN_STAGE_REWARD        (51850)
#define DIALOG_AUTUMN_FINAL_REWARD        (51851)
#define DIALOG_AUTUMN_CASE_FILE           (51852)

#define AUTUMN_ROLE_FORESTER              (0)
#define AUTUMN_ROLE_SCOUT                 (1)
#define AUTUMN_ROLE_MECHANIC              (2)
#define AUTUMN_ROLE_HUNTER                (3)
#define AUTUMN_ROLE_HOST                  (4)
#define AUTUMN_ROLE_FINAL                 (5)

enum E_AUTUMN_DEFAULT_NPC
{
    AUTUMN_DEF_MODEL,
    Float:AUTUMN_DEF_X,
    Float:AUTUMN_DEF_Y,
    Float:AUTUMN_DEF_Z,
    Float:AUTUMN_DEF_A
};

// Models selected from the user-provided Zomenko skin list.
// 5890 = Лесник
// 5888 = Алиса Следопытка
// 6859 = Механик Марк
// 5889 = Охотник Филиппыч
// 6792 = Хозяин таверны
// 5902 = Следователь Ловцова (отдельный финальный NPC)
new const gAutumnDefaultNpc[AUTUMN_EVENT_ROLE_COUNT][E_AUTUMN_DEFAULT_NPC] =
{
    {5890, -793.9675, -1935.7618, 41.2665, 15.5333},
    {5888, -938.5748, -2122.7368, 39.5400, 78.9297},
    {6859, -702.8070, -1529.1878, 41.3718, 104.4955},
    {5889, 1815.402465, 2324.652099, 14.825111, 270.0},
    {6792, 1937.021362, 2065.335693, 15.188584, 90.0},
    {5902, 1950.021362, 2065.335693, 15.188584, 270.0}
};

new const gAutumnRoleName[AUTUMN_EVENT_ROLE_COUNT][32] =
{
    "Лесник Григорий",
    "Алиса Следопытка",
    "Механик Марк",
    "Охотник Филиппыч",
    "Хозяин таверны",
    "Следователь Ловцова"
};

new const gAutumnRoleTitle[AUTUMN_EVENT_ROLE_COUNT][32] =
{
    "Лесник",
    "Следопыт",
    "Механик",
    "Охотник",
    "Хозяин таверны",
    "Следователь"
};

// Safe ground points reused from existing world locations in the current gamemode.
new Float:gAutumnCluePos[AUTUMN_EVENT_CLUES][3] =
{
    {-581.6979, -1610.6356, 41.2900},
    {-445.4335, -1677.1719, 41.0381},
    {-1476.5983, -2146.3217, 28.9757}
};

new const gAutumnClueName[AUTUMN_EVENT_CLUES][48] =
{
    "\xd1\xeb\xe5\xe4\xfb\x20\xf2\xff\xe6\xb8\xeb\xfb\xf5\x20\xf8\xe8\xed",
    "\xd4\xf0\xe0\xe3\xec\xe5\xed\xf2\x20\xf1\xf2\xe0\xf0\xee\xe9\x20\xed\xe0\xea\xeb\xe0\xe4\xed\xee\xe9",
    "\xce\xe1\xeb\xee\xec\xee\xea\x20\xf0\xe0\xe4\xe8\xee\xec\xee\xe4\xf3\xeb\xff"
};

new Float:gAutumnNodePos[4] = {-703.6402, -1587.9587, 41.2507, 338.1237};
new Float:gAutumnCar1Pos[4] = {-707.2949, -1528.6346, 41.2509, 139.5972};
new Float:gAutumnCar2Pos[4];
new Float:gAutumnCar3Pos[4];
new Float:gAutumnFinalPoint[4];
new Float:gAutumnRewardCarPoint[4];

new const Float:gAutumnStartNpcPos[AUTUMN_EVENT_START_NPCS][4] =
{
    {-2418.8815, 188.3195, 26.1351, 37.1877},
    {2749.6889, -2436.1113, 21.8134, 91.9344},
    {1784.6998, 2533.2114, 14.7193, 256.9798},
    {831.9531, 800.8373, 13.1689, 260.9307},
    {-2162.3217, 1568.3009, 9.8772, 187.7203},
    {-2660.2487, 1998.3587, 9.5556, 37.3381}
};

new gAutumnStartNpcActor[AUTUMN_EVENT_START_NPCS];
new STREAMER_TAG_3D_TEXT_LABEL:gAutumnStartNpcLabel[AUTUMN_EVENT_START_NPCS];
new STREAMER_TAG_3D_TEXT_LABEL:gAutumnNodeLabel;
new STREAMER_TAG_3D_TEXT_LABEL:gAutumnDeliveryLabel[AUTUMN_EVENT_DELIVERY_POINTS];

new Float:gAutumnDeliveryPos[AUTUMN_EVENT_DELIVERY_POINTS][3] =
{
    {1766.675781, 2066.703857, 15.511064},
    {1852.659179, 2195.323242, 15.558606},
    {1819.393310, 2133.784667, 15.332145}
};

new Float:gAutumnTerminalPos[3] = {1842.838745, 2171.448730, 15.300410};

// Temporary event vehicles selected from the user-provided vehicle table.
// Preferred: 425 Hunter, 422 UAZ Bukhanka, 413 Gazelle 3221, 414 Gaz Vector Next.
// Fallbacks are also from that table and are used only if the preferred model cannot be created.
// Use vehicle models that are already created elsewhere in this gamemode/client build.
// This avoids the mobile client error "Vehicle Model Id ... is null!" caused by unavailable replacement models.
// 466 Glendale -> first story car, 440 Rumpo -> delivery van, 428 Securicar -> final transport, 411 Infernus -> reward.
new const gAutumnStageVehicleModel[4] = {466, 440, 428, 411};
// Fallbacks are also models already used by the current gamemode.
new const gAutumnStageVehicleFallback[4] = {411, 462, 471, 407};

new bool:gAutumnEventEnabled = true;
new bool:gAutumnLoaded[MAX_PLAYERS];
new gAutumnLoadedAccountId[MAX_PLAYERS];
new gAutumnStage[MAX_PLAYERS];
new gAutumnSubStage[MAX_PLAYERS];
new gAutumnClueMask[MAX_PLAYERS];
new bool:gAutumnCompleted[MAX_PLAYERS];
new bool:gAutumnRewardReceived[MAX_PLAYERS];
new bool:gAutumnGuiOpen[MAX_PLAYERS];
new gAutumnCurrentNpc[MAX_PLAYERS];
new gAutumnEventVehicle[MAX_PLAYERS];
new gAutumnProgressTimer[MAX_PLAYERS];
new gAutumnProgressKind[MAX_PLAYERS];
new gAutumnProgressArg[MAX_PLAYERS];
new Float:gAutumnProgressPos[MAX_PLAYERS][3];
new bool:gAutumnInteractionVisible[MAX_PLAYERS];
new gAutumnLastInteractionTick[MAX_PLAYERS];
new bool:gAutumnAdminTestMode[MAX_PLAYERS];
new gAutumnNpcCount;
new gAutumnNpcDbId[AUTUMN_EVENT_MAX_NPCS];
new gAutumnNpcRole[AUTUMN_EVENT_MAX_NPCS];
new gAutumnNpcModel[AUTUMN_EVENT_MAX_NPCS];
new gAutumnNpcName[AUTUMN_EVENT_MAX_NPCS][32];
new Float:gAutumnNpcPos[AUTUMN_EVENT_MAX_NPCS][4];
new gAutumnNpcActor[AUTUMN_EVENT_MAX_NPCS];
new STREAMER_TAG_3D_TEXT_LABEL:gAutumnNpcLabel[AUTUMN_EVENT_MAX_NPCS];

new STREAMER_TAG_3D_TEXT_LABEL:gAutumnClueLabel[AUTUMN_EVENT_CLUES];
new STREAMER_TAG_3D_TEXT_LABEL:gAutumnTerminalLabel;
new STREAMER_TAG_3D_TEXT_LABEL:gAutumnFinalPointLabel;

stock AutumnEvent_IsAdmin(playerid)
{
    return GetPlayerAdminEx(playerid) >= AUTUMN_EVENT_ADMIN_LEVEL;
}

stock AutumnEvent_IsActiveForPlayer(playerid)
{
    if(!gAutumnEventEnabled) return 0;

    // Admin test checkpoints include checkpoint 1, where the persistent stage is
    // still NOT_STARTED. Keep map teleport blocked there as well.
    if(gAutumnAdminTestMode[playerid]) return 1;

    if(gAutumnStage[playerid] > AUTUMN_STAGE_NOT_STARTED &&
       gAutumnStage[playerid] < AUTUMN_STAGE_COMPLETED) return 1;

    // Also cover the short transition windows while an event GUI/progress action
    // is open, even if DB state has not yet been written.
    if(gAutumnGuiOpen[playerid]) return 1;
    if(gAutumnProgressKind[playerid] != AUTUMN_PROGRESS_NONE) return 1;
    if(gAutumnInteractionVisible[playerid] && gAutumnStage[playerid] != AUTUMN_STAGE_COMPLETED) return 1;
    return 0;
}

stock AutumnEvent_GetVehicleOwner(vehicleid)
{
    if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid)) return INVALID_PLAYER_ID;

    for(new owner = 0; owner < MAX_PLAYERS; owner++)
    {
        if(!IsPlayerConnected(owner)) continue;
        if(gAutumnEventVehicle[owner] == vehicleid) return owner;
    }
    return INVALID_PLAYER_ID;
}

stock AutumnEvent_BlockForeignVehicleEntry(playerid, vehicleid)
{
    new owner = AutumnEvent_GetVehicleOwner(vehicleid);
    if(owner == INVALID_PLAYER_ID || owner == playerid) return 0;

    ClearAnimations(playerid);
    ShowNotificationNew(playerid, 2, 5, 0, 0,
        "Этот транспорт используется другим участником события.", " ");
    return 1;
}

stock AutumnEvent_EnforceVehicleOwnerState(playerid, newstate)
{
    if(newstate != PLAYER_STATE_DRIVER && newstate != PLAYER_STATE_PASSENGER) return 0;

    new vehicleid = GetPlayerVehicleID(playerid);
    new owner = AutumnEvent_GetVehicleOwner(vehicleid);
    if(owner == INVALID_PLAYER_ID || owner == playerid) return 0;

    RemovePlayerFromVehicle(playerid);
    ClearAnimations(playerid);
    ShowNotificationNew(playerid, 2, 5, 0, 0,
        "Квестовая машина закреплена за другим игроком.", " ");
    return 1;
}

stock AutumnEvent_ResetPlayer(playerid)
{
    // Event state is usable immediately; DB sync never blocks GUI.
    gAutumnLoaded[playerid] = true;
    gAutumnLoadedAccountId[playerid] = 0;
    gAutumnStage[playerid] = AUTUMN_STAGE_NOT_STARTED;
    gAutumnSubStage[playerid] = 0;
    gAutumnClueMask[playerid] = 0;
    gAutumnCompleted[playerid] = false;
    gAutumnRewardReceived[playerid] = false;
    gAutumnGuiOpen[playerid] = false;
    gAutumnCurrentNpc[playerid] = -1;
    gAutumnEventVehicle[playerid] = INVALID_VEHICLE_ID;
    gAutumnProgressTimer[playerid] = -1;
    gAutumnProgressKind[playerid] = AUTUMN_PROGRESS_NONE;
    gAutumnProgressArg[playerid] = -1;
    gAutumnProgressPos[playerid][0] = 0.0;
    gAutumnProgressPos[playerid][1] = 0.0;
    gAutumnProgressPos[playerid][2] = 0.0;
    gAutumnInteractionVisible[playerid] = false;
    gAutumnLastInteractionTick[playerid] = 0;
    gAutumnAdminTestMode[playerid] = false;
    return 1;
}

stock AutumnEvent_SanitizeProgress(playerid)
{
    // Keep old or partially written saves from deadlocking the quest after updates.
    gAutumnClueMask[playerid] &= 7;

    if(gAutumnStage[playerid] < AUTUMN_STAGE_NOT_STARTED ||
       gAutumnStage[playerid] > AUTUMN_STAGE_COMPLETED)
    {
        gAutumnStage[playerid] = AUTUMN_STAGE_NOT_STARTED;
        gAutumnSubStage[playerid] = 0;
        gAutumnClueMask[playerid] = 0;
        gAutumnCompleted[playerid] = false;
        gAutumnRewardReceived[playerid] = false;
        return 1;
    }

    // Legacy stage from an older build: Alice is now stage CLUES/sub-stage 1.
    if(gAutumnStage[playerid] == AUTUMN_STAGE_ALICE)
    {
        gAutumnStage[playerid] = AUTUMN_STAGE_CLUES;
        gAutumnSubStage[playerid] = 1;
    }

    // A recorded final reward always wins over stale stage fields.
    if(gAutumnRewardReceived[playerid])
    {
        gAutumnStage[playerid] = AUTUMN_STAGE_COMPLETED;
        gAutumnSubStage[playerid] = 0;
        gAutumnCompleted[playerid] = true;
        return 1;
    }

    // If a completed flag was written but the reward flag was not, return the
    // player to Lovtsova so the reward can be claimed normally instead of lost.
    if(gAutumnStage[playerid] == AUTUMN_STAGE_COMPLETED || gAutumnCompleted[playerid])
    {
        gAutumnStage[playerid] = AUTUMN_STAGE_FINAL;
        gAutumnSubStage[playerid] = 2;
        gAutumnCompleted[playerid] = false;
        return 1;
    }

    switch(gAutumnStage[playerid])
    {
        case AUTUMN_STAGE_NOT_STARTED:
        {
            gAutumnSubStage[playerid] = 0;
            gAutumnClueMask[playerid] = 0;
        }
        case AUTUMN_STAGE_CLUES:
        {
            if(gAutumnClueMask[playerid] == 7)
            {
                gAutumnStage[playerid] = AUTUMN_STAGE_MECHANIC;
                gAutumnSubStage[playerid] = 0;
            }
            else
            {
                if(gAutumnSubStage[playerid] < 0) gAutumnSubStage[playerid] = 0;
                if(gAutumnSubStage[playerid] > 2) gAutumnSubStage[playerid] = 2;
            }
        }
        case AUTUMN_STAGE_MECHANIC, AUTUMN_STAGE_HUNTER:
        {
            gAutumnSubStage[playerid] = 0;
        }
        case AUTUMN_STAGE_DELIVERY:
        {
            if(gAutumnSubStage[playerid] < 0) gAutumnSubStage[playerid] = 0;
            if(gAutumnSubStage[playerid] >= AUTUMN_EVENT_DELIVERY_POINTS)
            {
                gAutumnStage[playerid] = AUTUMN_STAGE_TERMINAL;
                gAutumnSubStage[playerid] = 0;
            }
        }
        case AUTUMN_STAGE_TERMINAL:
        {
            if(gAutumnSubStage[playerid] < 0) gAutumnSubStage[playerid] = 0;
            if(gAutumnSubStage[playerid] > 1) gAutumnSubStage[playerid] = 1;
        }
        case AUTUMN_STAGE_FINAL:
        {
            if(gAutumnSubStage[playerid] < 0) gAutumnSubStage[playerid] = 0;
            if(gAutumnSubStage[playerid] > 2) gAutumnSubStage[playerid] = 2;
        }
    }
    return 1;
}

stock AutumnEvent_CreateTables()
{
    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `autumn_event_progress` ("\
        "`account_id` INT NOT NULL,"\
        "`stage` INT NOT NULL DEFAULT 0,"\
        "`sub_stage` INT NOT NULL DEFAULT 0,"\
        "`clue_mask` INT NOT NULL DEFAULT 0,"\
        "`completed` TINYINT NOT NULL DEFAULT 0,"\
        "`reward_received` TINYINT NOT NULL DEFAULT 0,"\
        "`updated_at` INT NOT NULL DEFAULT 0,"\
        "PRIMARY KEY (`account_id`)"\
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;",
        false);

    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `autumn_event_npcs` ("\
        "`id` INT NOT NULL AUTO_INCREMENT,"\
        "`role` INT NOT NULL DEFAULT 0,"\
        "`model` INT NOT NULL DEFAULT 0,"\
        "`name` VARCHAR(32) NOT NULL DEFAULT '',"\
        "`x` FLOAT NOT NULL DEFAULT 0,"\
        "`y` FLOAT NOT NULL DEFAULT 0,"\
        "`z` FLOAT NOT NULL DEFAULT 0,"\
        "`a` FLOAT NOT NULL DEFAULT 0,"\
        "`active` TINYINT NOT NULL DEFAULT 1,"\
        "PRIMARY KEY (`id`)"\
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;",
        false);

    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `autumn_event_config` ("\
        "`id` INT NOT NULL,"\
        "`enabled` TINYINT NOT NULL DEFAULT 1,"\
        "PRIMARY KEY (`id`)"\
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;",
        false);

    mysql_query(mysql,
        "INSERT IGNORE INTO `autumn_event_config` (`id`,`enabled`) VALUES (1,1);",
        false);

    return 1;
}

stock AutumnEvent_DestroyNpcRuntime()
{
    for(new i; i < AUTUMN_EVENT_MAX_NPCS; i++)
    {
        if(gAutumnNpcActor[i] != INVALID_ACTOR_ID && IsValidActor(gAutumnNpcActor[i]))
            DestroyActor(gAutumnNpcActor[i]);

        if(IsValidDynamic3DTextLabel(gAutumnNpcLabel[i]))
            DestroyDynamic3DTextLabel(gAutumnNpcLabel[i]);

        gAutumnNpcActor[i] = INVALID_ACTOR_ID;
        gAutumnNpcLabel[i] = STREAMER_TAG_3D_TEXT_LABEL:-1;
        gAutumnNpcDbId[i] = 0;
        gAutumnNpcRole[i] = -1;
        gAutumnNpcModel[i] = 0;
        gAutumnNpcName[i][0] = '\0';
        gAutumnNpcPos[i][0] = 0.0;
        gAutumnNpcPos[i][1] = 0.0;
        gAutumnNpcPos[i][2] = 0.0;
        gAutumnNpcPos[i][3] = 0.0;
    }
    gAutumnNpcCount = 0;
    return 1;
}

stock AutumnEvent_CreateNpcRuntime(slot)
{
    if(slot < 0 || slot >= gAutumnNpcCount) return 0;
    if(gAutumnNpcModel[slot] <= 0) return 0;

    // Idempotent runtime creation: one actor/label per event NPC slot.
    if(gAutumnNpcActor[slot] != INVALID_ACTOR_ID && IsValidActor(gAutumnNpcActor[slot]))
        DestroyActor(gAutumnNpcActor[slot]);
    if(IsValidDynamic3DTextLabel(gAutumnNpcLabel[slot]))
        DestroyDynamic3DTextLabel(gAutumnNpcLabel[slot]);
    gAutumnNpcActor[slot] = INVALID_ACTOR_ID;
    gAutumnNpcLabel[slot] = STREAMER_TAG_3D_TEXT_LABEL:-1;

    // Use CreateActor: current client supports these custom event skin IDs.
    gAutumnNpcActor[slot] = CreateActor(
        gAutumnNpcModel[slot],
        gAutumnNpcPos[slot][0],
        gAutumnNpcPos[slot][1],
        gAutumnNpcPos[slot][2],
        gAutumnNpcPos[slot][3]
    );

    if(gAutumnNpcActor[slot] == INVALID_ACTOR_ID)
    {
        printf("[AutumnEvent] ERROR: cannot create NPC slot=%d role=%d skin=%d", slot, gAutumnNpcRole[slot], gAutumnNpcModel[slot]);
        return 0;
    }

    SetActorVirtualWorld(gAutumnNpcActor[slot], 0);
    SetActorInvulnerable(gAutumnNpcActor[slot], true);

    new text[256];
    format(text, sizeof text,
        "{FFD429}%s\n"\
        "{FFFFFF}До {FFD429}%s\n"\
        "{FFFFFF}Подойдите для {FFD429}взаимодействия",
        gAutumnRoleTitle[gAutumnNpcRole[slot]],
        AUTUMN_EVENT_DATE);

    gAutumnNpcLabel[slot] = CreateDynamic3DTextLabel(
        text,
        0xFFFFFFFF,
        gAutumnNpcPos[slot][0],
        gAutumnNpcPos[slot][1],
        gAutumnNpcPos[slot][2] + 0.85,
        18.0,
        INVALID_PLAYER_ID,
        INVALID_VEHICLE_ID,
        0,
        0,
        0
    );
    return 1;
}

stock AutumnEvent_InsertDefaultNpcs()
{
    new query[512];
    for(new role; role < AUTUMN_EVENT_ROLE_COUNT; role++)
    {
        mysql_format(mysql, query, sizeof query,
            "INSERT INTO `autumn_event_npcs` "\
            "(`role`,`model`,`name`,`x`,`y`,`z`,`a`,`active`) "\
            "VALUES (%d,%d,'%e',%.6f,%.6f,%.6f,%.6f,1)",
            role,
            gAutumnDefaultNpc[role][AUTUMN_DEF_MODEL],
            gAutumnRoleName[role],
            gAutumnDefaultNpc[role][AUTUMN_DEF_X],
            gAutumnDefaultNpc[role][AUTUMN_DEF_Y],
            gAutumnDefaultNpc[role][AUTUMN_DEF_Z],
            gAutumnDefaultNpc[role][AUTUMN_DEF_A]);
        mysql_query(mysql, query, false);
    }
    return 1;
}

stock AutumnEvent_LoadNpcs()
{
    // Runtime NPCs are built directly from verified defaults.
    // This intentionally does not depend on MySQL so NPCs always exist after GM start.
    AutumnEvent_DestroyNpcRuntime();

    gAutumnNpcCount = AUTUMN_EVENT_ROLE_COUNT;
    for(new role; role < AUTUMN_EVENT_ROLE_COUNT; role++)
    {
        gAutumnNpcDbId[role] = role + 1;
        gAutumnNpcRole[role] = role;
        gAutumnNpcModel[role] = gAutumnDefaultNpc[role][AUTUMN_DEF_MODEL];
        format(gAutumnNpcName[role], sizeof(gAutumnNpcName[]), "%s", gAutumnRoleName[role]);
        gAutumnNpcPos[role][0] = gAutumnDefaultNpc[role][AUTUMN_DEF_X];
        gAutumnNpcPos[role][1] = gAutumnDefaultNpc[role][AUTUMN_DEF_Y];
        gAutumnNpcPos[role][2] = gAutumnDefaultNpc[role][AUTUMN_DEF_Z];
        gAutumnNpcPos[role][3] = gAutumnDefaultNpc[role][AUTUMN_DEF_A];

        if(!AutumnEvent_CreateNpcRuntime(role))
            printf("[AutumnEvent] FATAL NPC create failed: role=%d skin=%d", role, gAutumnNpcModel[role]);
    }

    printf("[AutumnEvent] Runtime NPCs created: %d", gAutumnNpcCount);
    return 1;
}

stock AutumnEvent_LoadPointFile(const key[])
{
    new filename[64];
    format(filename, sizeof filename, "autumn_point_%s.txt", key);
    new File:file_ptr;
    file_ptr = fopen(filename, filemode:io_read);
    if(!file_ptr) return 0;

    new point_line[128];
    new Float:x, Float:y, Float:z, Float:a;
    if(fread(file_ptr, point_line, sizeof point_line) > 0)
    {
        if(!sscanf(point_line, "ffff", x, y, z, a))
            AutumnEvent_SetCreatedPoint(key, x, y, z, a);
    }
    fclose(file_ptr);
    return 1;
}

stock AutumnEvent_EnsureFinalNpcSeparation()
{
    new host = -1, finalnpc = -1;
    for(new i; i < gAutumnNpcCount; i++)
    {
        if(gAutumnNpcRole[i] == AUTUMN_ROLE_HOST) host = i;
        else if(gAutumnNpcRole[i] == AUTUMN_ROLE_FINAL) finalnpc = i;
    }
    if(host == -1 || finalnpc == -1) return 0;

    new Float:dx = gAutumnNpcPos[finalnpc][0] - gAutumnNpcPos[host][0];
    new Float:dy = gAutumnNpcPos[finalnpc][1] - gAutumnNpcPos[host][1];
    new Float:dz = gAutumnNpcPos[finalnpc][2] - gAutumnNpcPos[host][2];
    new Float:distance = floatsqroot(dx*dx + dy*dy + dz*dz);
    if(distance >= 5.0) return 1;

    gAutumnNpcPos[finalnpc][0] = gAutumnDefaultNpc[AUTUMN_ROLE_FINAL][AUTUMN_DEF_X];
    gAutumnNpcPos[finalnpc][1] = gAutumnDefaultNpc[AUTUMN_ROLE_FINAL][AUTUMN_DEF_Y];
    gAutumnNpcPos[finalnpc][2] = gAutumnDefaultNpc[AUTUMN_ROLE_FINAL][AUTUMN_DEF_Z];
    gAutumnNpcPos[finalnpc][3] = gAutumnDefaultNpc[AUTUMN_ROLE_FINAL][AUTUMN_DEF_A];

    dx = gAutumnNpcPos[finalnpc][0] - gAutumnNpcPos[host][0];
    dy = gAutumnNpcPos[finalnpc][1] - gAutumnNpcPos[host][1];
    dz = gAutumnNpcPos[finalnpc][2] - gAutumnNpcPos[host][2];
    distance = floatsqroot(dx*dx + dy*dy + dz*dz);
    if(distance < 5.0)
    {
        gAutumnNpcPos[finalnpc][0] = gAutumnNpcPos[host][0] + 8.0;
        gAutumnNpcPos[finalnpc][1] = gAutumnNpcPos[host][1] + 1.5;
        gAutumnNpcPos[finalnpc][2] = gAutumnNpcPos[host][2];
        gAutumnNpcPos[finalnpc][3] = gAutumnNpcPos[host][3] + 180.0;
        if(gAutumnNpcPos[finalnpc][3] >= 360.0) gAutumnNpcPos[finalnpc][3] -= 360.0;
    }
    return AutumnEvent_RecreateNpcSlot(finalnpc);
}

stock AutumnEvent_LoadCreatedPoints()
{
    AutumnEvent_LoadPointFile("start3");
    AutumnEvent_LoadPointFile("car2");
    AutumnEvent_LoadPointFile("delivery1");
    AutumnEvent_LoadPointFile("delivery2");
    AutumnEvent_LoadPointFile("delivery3");
    AutumnEvent_LoadPointFile("terminal");
    AutumnEvent_LoadPointFile("start4");
    AutumnEvent_LoadPointFile("car3");
    AutumnEvent_LoadPointFile("finalpoint");
    AutumnEvent_LoadPointFile("finalnpc");
    AutumnEvent_LoadPointFile("rewardcar");
    AutumnEvent_EnsureFinalNpcSeparation();
    return 1;
}

stock AutumnEvent_DestroyStartNpcs()
{
    for(new i; i < AUTUMN_EVENT_START_NPCS; i++)
    {
        if(gAutumnStartNpcActor[i] != INVALID_ACTOR_ID && IsValidActor(gAutumnStartNpcActor[i])) DestroyActor(gAutumnStartNpcActor[i]);
        if(IsValidDynamic3DTextLabel(gAutumnStartNpcLabel[i])) DestroyDynamic3DTextLabel(gAutumnStartNpcLabel[i]);
        gAutumnStartNpcActor[i] = INVALID_ACTOR_ID;
        gAutumnStartNpcLabel[i] = STREAMER_TAG_3D_TEXT_LABEL:-1;
    }
    return 1;
}

stock AutumnEvent_CreateStartNpcs()
{
    AutumnEvent_DestroyStartNpcs();
    for(new i; i < AUTUMN_EVENT_START_NPCS; i++)
    {
        if(gAutumnStartNpcActor[i] != INVALID_ACTOR_ID && IsValidActor(gAutumnStartNpcActor[i]))
            DestroyActor(gAutumnStartNpcActor[i]);
        if(IsValidDynamic3DTextLabel(gAutumnStartNpcLabel[i]))
            DestroyDynamic3DTextLabel(gAutumnStartNpcLabel[i]);
        gAutumnStartNpcActor[i] = INVALID_ACTOR_ID;
        gAutumnStartNpcLabel[i] = STREAMER_TAG_3D_TEXT_LABEL:-1;

        gAutumnStartNpcActor[i] = CreateActor(AUTUMN_EVENT_START_MODEL, gAutumnStartNpcPos[i][0], gAutumnStartNpcPos[i][1], gAutumnStartNpcPos[i][2], gAutumnStartNpcPos[i][3]);
        if(gAutumnStartNpcActor[i] != INVALID_ACTOR_ID)
        {
            SetActorVirtualWorld(gAutumnStartNpcActor[i], 0);
            SetActorInvulnerable(gAutumnStartNpcActor[i], true);
        }
        gAutumnStartNpcLabel[i] = CreateDynamic3DTextLabel(
            "{FFD429}Проводник осеннего события\n{FFFFFF}Доступно до {FFD429}30.11.2026\n{FFFFFF}Подойдите, чтобы {FFD429}начать историю",
            0xFFFFFFFF, gAutumnStartNpcPos[i][0], gAutumnStartNpcPos[i][1], gAutumnStartNpcPos[i][2] + 0.85, 18.0,
            INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    }
    printf("[AutumnEvent] starter NPCs created: %d", AUTUMN_EVENT_START_NPCS);
    return 1;
}

stock AutumnEvent_FindNearestStartNpc(playerid, Float:radius = AUTUMN_EVENT_INTERACTION_RADIUS)
{
    if(IsPlayerInAnyVehicle(playerid)) return -1;
    for(new i; i < AUTUMN_EVENT_START_NPCS; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, radius, gAutumnStartNpcPos[i][0], gAutumnStartNpcPos[i][1], gAutumnStartNpcPos[i][2])) return i;
    }
    return -1;
}

stock AutumnEvent_ShowStartGui(playerid, starter)
{
    if(starter < 0 || starter >= AUTUMN_EVENT_START_NPCS) return 0;

    new Node:json = JSON_Object();
    JSON_SetInt(json, "o", 1);
    JSON_SetInt(json, "m", AUTUMN_EVENT_START_MODEL);
    JSON_SetString(json, "n", "Проводник 'Золотого следа'");
    JSON_SetInt(json, "ts", 3);
    JSON_SetString(json, "d",
        "Старый тракт редко бывает тихим, но после последней грозы там произошло что-то странное. "\
        "Связь пропала, на дороге остались свежие следы, а несколько человек слышали машину глубокой ночью.\n\n"\
        "Я не знаю, что именно случилось. Лесник Григорий был рядом одним из первых. Если хотите разобраться - поговорите с ним и решайте сами, каким следам верить.");

    new Node:b1 = JSON_Object();
    new Node:b2 = JSON_Object();
    new Node:b3 = JSON_Object();
    JSON_SetString(b1, "bn", "НАЧАТЬ ПОИСК"); JSON_SetInt(b1, "bt", 1); JSON_SetInt(b1, "bk", AUTUMN_GUI_INTRO_ROUTE);
    JSON_SetString(b2, "bn", "ЧТО ИЗВЕСТНО?"); JSON_SetInt(b2, "bt", 2); JSON_SetInt(b2, "bk", AUTUMN_GUI_ABOUT);
    JSON_SetString(b3, "bn", "ПОЗЖЕ"); JSON_SetInt(b3, "bt", 3); JSON_SetInt(b3, "bk", AUTUMN_GUI_CLOSE);
    new Node:buttons = JSON_Array(b1,b2,b3);
    JSON_SetArray(json, "b", buttons);

    JSON_Cleanup(b1);
    JSON_Cleanup(b2);
    JSON_Cleanup(b3);
    JSON_Cleanup(buttons);

    gAutumnCurrentNpc[playerid] = -100 - starter;
    gAutumnGuiOpen[playerid] = true;
    ShowPlayerGUI(playerid, 63, json);
    JSON_Cleanup(json);
    return 1;
}


stock AutumnEvent_RecreateNpcSlot(slot)
{
    if(slot < 0 || slot >= gAutumnNpcCount) return 0;
    if(gAutumnNpcActor[slot] != INVALID_ACTOR_ID && IsValidActor(gAutumnNpcActor[slot])) DestroyActor(gAutumnNpcActor[slot]);
    if(IsValidDynamic3DTextLabel(gAutumnNpcLabel[slot])) DestroyDynamic3DTextLabel(gAutumnNpcLabel[slot]);
    gAutumnNpcActor[slot] = INVALID_ACTOR_ID;
    gAutumnNpcLabel[slot] = STREAMER_TAG_3D_TEXT_LABEL:-1;
    return AutumnEvent_CreateNpcRuntime(slot);
}

stock AutumnEvent_SetCreatedPoint(const key[], Float:x, Float:y, Float:z, Float:a)
{
    if(!strcmp(key, "start3", true))
    {
        new slot = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_HUNTER);
        if(slot == -1) return 0;
        gAutumnNpcPos[slot][0]=x; gAutumnNpcPos[slot][1]=y; gAutumnNpcPos[slot][2]=z; gAutumnNpcPos[slot][3]=a;
        return AutumnEvent_RecreateNpcSlot(slot);
    }
    if(!strcmp(key, "start4", true))
    {
        new slot = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_HOST);
        if(slot == -1) return 0;
        gAutumnNpcPos[slot][0]=x; gAutumnNpcPos[slot][1]=y; gAutumnNpcPos[slot][2]=z; gAutumnNpcPos[slot][3]=a;
        return AutumnEvent_RecreateNpcSlot(slot);
    }
    if(!strcmp(key, "finalnpc", true))
    {
        new slot = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_FINAL);
        if(slot == -1) return 0;
        gAutumnNpcPos[slot][0]=x; gAutumnNpcPos[slot][1]=y; gAutumnNpcPos[slot][2]=z; gAutumnNpcPos[slot][3]=a;
        return AutumnEvent_RecreateNpcSlot(slot);
    }
    if(!strcmp(key, "delivery1", true)) { gAutumnDeliveryPos[0][0]=x; gAutumnDeliveryPos[0][1]=y; gAutumnDeliveryPos[0][2]=z; AutumnEvent_CreateStaticLabels(); return 1; }
    if(!strcmp(key, "delivery2", true)) { gAutumnDeliveryPos[1][0]=x; gAutumnDeliveryPos[1][1]=y; gAutumnDeliveryPos[1][2]=z; AutumnEvent_CreateStaticLabels(); return 1; }
    if(!strcmp(key, "delivery3", true)) { gAutumnDeliveryPos[2][0]=x; gAutumnDeliveryPos[2][1]=y; gAutumnDeliveryPos[2][2]=z; AutumnEvent_CreateStaticLabels(); return 1; }
    if(!strcmp(key, "terminal", true)) { gAutumnTerminalPos[0]=x; gAutumnTerminalPos[1]=y; gAutumnTerminalPos[2]=z; AutumnEvent_CreateStaticLabels(); return 1; }
    if(!strcmp(key, "car2", true)) { gAutumnCar2Pos[0]=x; gAutumnCar2Pos[1]=y; gAutumnCar2Pos[2]=z; gAutumnCar2Pos[3]=a; return 1; }
    if(!strcmp(key, "car3", true)) { gAutumnCar3Pos[0]=x; gAutumnCar3Pos[1]=y; gAutumnCar3Pos[2]=z; gAutumnCar3Pos[3]=a; return 1; }
    if(!strcmp(key, "finalpoint", true)) { gAutumnFinalPoint[0]=x; gAutumnFinalPoint[1]=y; gAutumnFinalPoint[2]=z; gAutumnFinalPoint[3]=a; AutumnEvent_CreateStaticLabels(); return 1; }
    if(!strcmp(key, "rewardcar", true)) { gAutumnRewardCarPoint[0]=x; gAutumnRewardCarPoint[1]=y; gAutumnRewardCarPoint[2]=z; gAutumnRewardCarPoint[3]=a; return 1; }
    return 0;
}

stock AutumnEvent_SaveCreatedPoint(playerid, const key[])
{
    if(GetPlayerAdminEx(playerid) < AUTUMN_EVENT_ADMIN_LEVEL || !GetPlayerData(playerid, P_ADMIN_LOGGED))
        return SendClientMessage(playerid, 0xFF5555FF, "{FF5555}[EVENT] {FFFFFF}Команда доступна администраторам 13-14 уровня.");

    new Float:x, Float:y, Float:z, Float:a;
    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        GetVehiclePos(vehicleid,x,y,z);
        GetVehicleZAngle(vehicleid,a);
    }
    else
    {
        GetPlayerPos(playerid,x,y,z);
        GetPlayerFacingAngle(playerid,a);
    }

    if(!AutumnEvent_SetCreatedPoint(key,x,y,z,a))
        return SendClientMessage(playerid, 0xFFD54FFF, "{FFD54F}[EVENT] {FFFFFF}Названия: start3, car2, delivery1, delivery2, delivery3, terminal, start4, car3, finalpoint, finalnpc, rewardcar.");

    new point_filename[64];
    format(point_filename, sizeof point_filename, "autumn_point_%s.txt", key);
    new File:point_file = fopen(point_filename, io_write);
    if(!point_file) return SendClientMessage(playerid, 0xFF5555FF, "{FF5555}[EVENT] {FFFFFF}Не удалось сохранить точку в scriptfiles.");
    new point_data[128];
    format(point_data, sizeof point_data, "%.4f %.4f %.4f %.4f\r\n", x, y, z, a);
    fwrite(point_file, point_data);
    fclose(point_file);

    new File:file = fopen("autumn_event_points.txt", io_append);
    if(!file) file = fopen("autumn_event_points.txt", io_write);
    if(!file) return SendClientMessage(playerid, 0xFF5555FF, "{FF5555}[EVENT] {FFFFFF}Не удалось открыть scriptfiles/autumn_event_points.txt.");

    new save_line[192];
    new keybuf[32];
    format(keybuf, sizeof keybuf, "%s", key);
    format(save_line,sizeof save_line,"%s | %.4f, %.4f, %.4f, %.4f | VW:%d INT:%d\r\n",keybuf,x,y,z,a,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid));
    fwrite(file,save_line);
    fclose(file);

    new msg[220];
    format(msg,sizeof msg,"{FFD54F}[EVENT] {FFFFFF}%s создана и сохранена: %.4f, %.4f, %.4f, %.4f",key,x,y,z,a);
    SendClientMessage(playerid,-1,msg);
    return 1;
}

stock AutumnEvent_IsNearNode(playerid, Float:radius = 3.4)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;
    if(gAutumnStage[playerid] != AUTUMN_STAGE_CLUES || gAutumnSubStage[playerid] != 0) return 0;
    if(IsPlayerInAnyVehicle(playerid)) return 0;
    return IsPlayerInRangeOfPoint(playerid, radius, gAutumnNodePos[0], gAutumnNodePos[1], gAutumnNodePos[2]);
}

stock AutumnEvent_CreateStaticLabels()
{
    if(IsValidDynamic3DTextLabel(gAutumnNodeLabel)) DestroyDynamic3DTextLabel(gAutumnNodeLabel);
    gAutumnNodeLabel = CreateDynamic3DTextLabel("{FFD429}Поврежденный узел связи\n{FFFFFF}Осмотрите оборудование", 0xFFFFFFFF, gAutumnNodePos[0], gAutumnNodePos[1], gAutumnNodePos[2] + 0.35, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);

    for(new i; i < AUTUMN_EVENT_CLUES; i++)
    {
        if(IsValidDynamic3DTextLabel(gAutumnClueLabel[i]))
            DestroyDynamic3DTextLabel(gAutumnClueLabel[i]);

        new text[128];
        format(text, sizeof text,
            "{FFD429}След на старом тракте #%d\n"\
            "{FFFFFF}Осмотрите место и соберите улику",
            i + 1);

        gAutumnClueLabel[i] = CreateDynamic3DTextLabel(
            text,
            0xFFFFFFFF,
            gAutumnCluePos[i][0],
            gAutumnCluePos[i][1],
            gAutumnCluePos[i][2] + 0.35,
            10.0,
            INVALID_PLAYER_ID,
            INVALID_VEHICLE_ID,
            0,
            0,
            0);
    }

    for(new i; i < AUTUMN_EVENT_DELIVERY_POINTS; i++)
    {
        if(IsValidDynamic3DTextLabel(gAutumnDeliveryLabel[i]))
            DestroyDynamic3DTextLabel(gAutumnDeliveryLabel[i]);
        gAutumnDeliveryLabel[i] = STREAMER_TAG_3D_TEXT_LABEL:-1;

        if(gAutumnDeliveryPos[i][0] != 0.0 || gAutumnDeliveryPos[i][1] != 0.0)
        {
            new delivery_text[160];
            format(delivery_text, sizeof delivery_text,
                "{FFD429}Точка снабжения #%d\n"\
                "{FFFFFF}Припаркуйте квестовую машину рядом\n"\
                "{FFFFFF}Передайте припасы {FFD429}пешком",
                i + 1);

            gAutumnDeliveryLabel[i] = CreateDynamic3DTextLabel(
                delivery_text, 0xFFFFFFFF,
                gAutumnDeliveryPos[i][0], gAutumnDeliveryPos[i][1], gAutumnDeliveryPos[i][2] + 0.45,
                18.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
        }
    }

    if(IsValidDynamic3DTextLabel(gAutumnTerminalLabel))
        DestroyDynamic3DTextLabel(gAutumnTerminalLabel);

    gAutumnTerminalLabel = CreateDynamic3DTextLabel(
        "{FFD429}\xd1\xf2\xe0\xf0\xfb\xe9\x20\xf0\xe5\xf2\xf0\xe0\xed\xf1\xeb\xff\xf2\xee\xf0\n"\
        "{FFFFFF}\xce\xf1\xec\xee\xf2\xf0\xe8\xf2\xe5\x20\xf9\xe8\xf2\xee\xea\x20\xe8\x20\xe2\xee\xf1\xf1\xf2\xe0\xed\xee\xe2\xe8\xf2\xe5\x20\xeb\xe8\xed\xe8\xfe\x20\xef\xe8\xf2\xe0\xed\xe8\xff",
        0xFFFFFFFF,
        gAutumnTerminalPos[0],
        gAutumnTerminalPos[1],
        gAutumnTerminalPos[2] + 0.4,
        12.0,
        INVALID_PLAYER_ID,
        INVALID_VEHICLE_ID,
        0,
        0,
        0);

    if(IsValidDynamic3DTextLabel(gAutumnFinalPointLabel))
        DestroyDynamic3DTextLabel(gAutumnFinalPointLabel);
    gAutumnFinalPointLabel = STREAMER_TAG_3D_TEXT_LABEL:-1;
    if(gAutumnFinalPoint[0] != 0.0 || gAutumnFinalPoint[1] != 0.0)
    {
        gAutumnFinalPointLabel = CreateDynamic3DTextLabel(
            "{FFD429}Тайник старого тракта\n{FFFFFF}Найдите оставленные документы",
            0xFFFFFFFF,
            gAutumnFinalPoint[0], gAutumnFinalPoint[1], gAutumnFinalPoint[2] + 0.35,
            10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 0, 0);
    }

    return 1;
}

stock AutumnEvent_LoadConfig()
{
    new Cache:result = mysql_query(mysql,
        "SELECT `enabled` FROM `autumn_event_config` WHERE `id`=1 LIMIT 1",
        true);

    if(result)
    {
        if(cache_num_rows() > 0)
            gAutumnEventEnabled = cache_get_field_content_int(0, "enabled") != 0;
        cache_delete(result);
    }
    return 1;
}

stock AutumnEvent_SaveConfig()
{
    new query[128];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO `autumn_event_config` (`id`,`enabled`) VALUES (1,%d) "\
        "ON DUPLICATE KEY UPDATE `enabled`=VALUES(`enabled`)",
        gAutumnEventEnabled ? 1 : 0);
    mysql_query(mysql, query, false);
    return 1;
}

stock AutumnEvent_Init()
{
    for(new i; i < AUTUMN_EVENT_MAX_NPCS; i++)
    {
        gAutumnNpcActor[i] = INVALID_ACTOR_ID;
        gAutumnNpcLabel[i] = STREAMER_TAG_3D_TEXT_LABEL:-1;
    }

    for(new i; i < AUTUMN_EVENT_CLUES; i++)
        gAutumnClueLabel[i] = STREAMER_TAG_3D_TEXT_LABEL:-1;

    for(new i; i < AUTUMN_EVENT_DELIVERY_POINTS; i++)
        gAutumnDeliveryLabel[i] = STREAMER_TAG_3D_TEXT_LABEL:-1;

    gAutumnTerminalLabel = STREAMER_TAG_3D_TEXT_LABEL:-1;
    gAutumnNodeLabel = STREAMER_TAG_3D_TEXT_LABEL:-1;

    for(new i; i < AUTUMN_EVENT_START_NPCS; i++)
    {
        gAutumnStartNpcActor[i] = INVALID_ACTOR_ID;
        gAutumnStartNpcLabel[i] = STREAMER_TAG_3D_TEXT_LABEL:-1;
    }

    for(new playerid; playerid < MAX_PLAYERS; playerid++)
        AutumnEvent_ResetPlayer(playerid);

    AutumnEvent_CreateTables();
    // The event is active immediately after gamemode load. No DB/config loading gate.
    gAutumnEventEnabled = true;
    AutumnEvent_LoadNpcs();
    AutumnEvent_LoadCreatedPoints();
    AutumnEvent_CreateStartNpcs();
    AutumnEvent_CreateStaticLabels();

    SetTimer("AutumnEvent_ProximityTick", 500, true);

    printf("[AutumnEvent] %s initialized. Enabled=%d", AUTUMN_EVENT_NAME, gAutumnEventEnabled ? 1 : 0);
    return 1;
}

stock AutumnEvent_EnsureLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;

    // The event NEVER has a loading state. Defaults are always usable immediately.
    gAutumnLoaded[playerid] = true;

    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0) return 1;

    // Already synchronized for this exact account.
    if(gAutumnLoadedAccountId[playerid] == account_id) return 1;

    new query[256];
    mysql_format(mysql, query, sizeof query,
        "SELECT `stage`,`sub_stage`,`clue_mask`,`completed`,`reward_received` "\
        "FROM `autumn_event_progress` WHERE `account_id`=%d LIMIT 1",
        account_id);

    new Cache:result = mysql_query(mysql, query, true);
    if(result)
    {
        if(cache_num_rows() > 0)
        {
            gAutumnStage[playerid] = cache_get_field_content_int(0, "stage");
            gAutumnSubStage[playerid] = cache_get_field_content_int(0, "sub_stage");
            gAutumnClueMask[playerid] = cache_get_field_content_int(0, "clue_mask");
            gAutumnCompleted[playerid] = cache_get_field_content_int(0, "completed") != 0;
            gAutumnRewardReceived[playerid] = cache_get_field_content_int(0, "reward_received") != 0;
        }
        cache_delete(result);
    }

    AutumnEvent_SanitizeProgress(playerid);

    gAutumnLoadedAccountId[playerid] = account_id;
    return 1;
}

stock AutumnEvent_OnAccountReady(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    // Account ID is known now: sync once, without ever blocking interaction/GUI.
    gAutumnLoadedAccountId[playerid] = 0;
    return AutumnEvent_EnsureLoaded(playerid);
}

stock AutumnEvent_SavePlayer(playerid)
{
    if(GetPlayerAccountID(playerid) <= 0) return 0;

    new query[640];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO `autumn_event_progress` "\
        "(`account_id`,`stage`,`sub_stage`,`clue_mask`,`completed`,`reward_received`,`updated_at`) "\
        "VALUES (%d,%d,%d,%d,%d,%d,%d) "\
        "ON DUPLICATE KEY UPDATE "\
        "`stage`=VALUES(`stage`),"\
        "`sub_stage`=VALUES(`sub_stage`),"\
        "`clue_mask`=VALUES(`clue_mask`),"\
        "`completed`=VALUES(`completed`),"\
        "`reward_received`=VALUES(`reward_received`),"\
        "`updated_at`=VALUES(`updated_at`)",
        GetPlayerAccountID(playerid),
        gAutumnStage[playerid],
        gAutumnSubStage[playerid],
        gAutumnClueMask[playerid],
        gAutumnCompleted[playerid] ? 1 : 0,
        gAutumnRewardReceived[playerid] ? 1 : 0,
        gettime());

    mysql_query(mysql, query, false);
    return 1;
}

stock AutumnEvent_CloseGui(playerid)
{
    gAutumnGuiOpen[playerid] = false;
    gAutumnCurrentNpc[playerid] = -1;
    HidePlayerGUI(playerid, 63);
    return 1;
}

stock AutumnEvent_ClearRoute(playerid)
{
    DisablePlayerCheckpoint(playerid);
    DisablePlayerGPS(playerid);
    return 1;
}

stock AutumnEvent_SetPointRoute(playerid, Float:x, Float:y, Float:z, Float:size, text[])
{
    AutumnEvent_ClearRoute(playerid);
    EnablePlayerGPS(playerid, 55, x, y, z, text);
    SetPlayerCheckpoint(playerid, x, y, z, size);
    return 1;
}

stock AutumnEvent_FindNpcByRole(role)
{
    for(new i; i < gAutumnNpcCount; i++)
    {
        if(gAutumnNpcRole[i] == role)
            return i;
    }
    return -1;
}

stock AutumnEvent_FindNpcByDbId(dbid)
{
    for(new i; i < gAutumnNpcCount; i++)
    {
        if(gAutumnNpcDbId[i] == dbid)
            return i;
    }
    return -1;
}

stock AutumnEvent_FindNearestNpc(playerid, Float:radius = AUTUMN_EVENT_INTERACTION_RADIUS)
{
    new best = -1;
    new Float:bestDist = radius + 0.01;

    for(new i; i < gAutumnNpcCount; i++)
    {
        if(gAutumnNpcDbId[i] <= 0) continue;
        if(GetPlayerVirtualWorld(playerid) != 0 || GetPlayerInterior(playerid) != 0) continue;

        new Float:d = GetPlayerDistanceFromPoint(
            playerid,
            gAutumnNpcPos[i][0],
            gAutumnNpcPos[i][1],
            gAutumnNpcPos[i][2]);

        if(d <= radius && d < bestDist)
        {
            best = i;
            bestDist = d;
        }
    }
    return best;
}

stock AutumnEvent_GetNextMissingClue(playerid)
{
    for(new i; i < AUTUMN_EVENT_CLUES; i++)
    {
        if(!(gAutumnClueMask[playerid] & (1 << i)))
            return i;
    }
    return -1;
}

stock AutumnEvent_GetNearbyClue(playerid, Float:radius = 3.0)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return -1;
    if(gAutumnStage[playerid] != AUTUMN_STAGE_CLUES || gAutumnSubStage[playerid] < 2) return -1;
    if(IsPlayerInAnyVehicle(playerid)) return -1;

    for(new i; i < AUTUMN_EVENT_CLUES; i++)
    {
        if(gAutumnClueMask[playerid] & (1 << i)) continue;
        if(IsPlayerInRangeOfPoint(playerid, radius,
            gAutumnCluePos[i][0],
            gAutumnCluePos[i][1],
            gAutumnCluePos[i][2]))
            return i;
    }
    return -1;
}

stock AutumnEvent_CountClues(playerid)
{
    new count = 0;
    if(gAutumnClueMask[playerid] & 1) count++;
    if(gAutumnClueMask[playerid] & 2) count++;
    if(gAutumnClueMask[playerid] & 4) count++;
    return count;
}

stock AutumnEvent_ShowCaseFile(playerid)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;

    new title[96];
    format(title, sizeof title, "{E0584B}\xc7\xce\xcb\xce\xd2\xce\xc9\x20\xd1\xcb\xc5\xc4{FFFFFF} | \xcc\xc0\xd2\xc5\xd0\xc8\xc0\xcb\xdb\x20\xc4\xc5\xcb\xc0");

    new body[1100], case_line[160];
    format(body, sizeof body,
        "{FFFFFF}\xd1\xee\xe1\xf0\xe0\xed\xee\x20\xf3\xeb\xe8\xea\x3a {FFE066}%d/3{FFFFFF}\n\n",
        AutumnEvent_CountClues(playerid));

    for(new i; i < AUTUMN_EVENT_CLUES; i++)
    {
        if(gAutumnClueMask[playerid] & (1 << i))
            format(case_line, sizeof case_line, "{E0584B}%d. {FFFFFF}%s\n", i + 1, gAutumnClueName[i]);
        else
            format(case_line, sizeof case_line, "{666666}%d. \xcd\xe5\xe8\xe7\xf3\xf7\xe5\xed\xed\xfb\xe9\x20\xec\xe0\xf2\xe5\xf0\xe8\xe0\xeb\n", i + 1);
        strcat(body, case_line, sizeof body);
    }

    strcat(body, "\n", sizeof body);
    if(gAutumnStage[playerid] == AUTUMN_STAGE_COMPLETED)
        strcat(body, "{FFE066}\xd1\xf2\xe0\xf2\xf3\xf1\x3a\x20\xf0\xe0\xf1\xf1\xeb\xe5\xe4\xee\xe2\xe0\xed\xe8\xe5\x20\xe7\xe0\xe2\xe5\xf0\xf8\xe5\xed\xee\x2e{FFFFFF}", sizeof body);
    else if(gAutumnStage[playerid] == AUTUMN_STAGE_NOT_STARTED)
        strcat(body, "{BFC6CF}\xcc\xe0\xf2\xe5\xf0\xe8\xe0\xeb\xfb\x20\xef\xee\x20\xe4\xe5\xeb\xf3\x20\xef\xee\xea\xe0\x20\xed\xe5\x20\xf1\xee\xe1\xf0\xe0\xed\xfb\x2e{FFFFFF}", sizeof body);
    else
        strcat(body, "{BFC6CF}\xd1\xf2\xe0\xf2\xf3\xf1\x3a\x20\xf0\xe0\xf1\xf1\xeb\xe5\xe4\xee\xe2\xe0\xed\xe8\xe5\x20\xef\xf0\xee\xe4\xee\xeb\xe6\xe0\xe5\xf2\xf1\xff\x2e{FFFFFF}", sizeof body);

    ShowPlayerDialog(playerid, DIALOG_AUTUMN_CASE_FILE, DIALOG_STYLE_MSGBOX,
        title, body, "\xc7\xe0\xea\xf0\xfb\xf2\xfc", "");
    return 1;
}

stock AutumnEvent_IsNearTerminal(playerid, Float:radius = 3.4)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;
    if(gAutumnStage[playerid] != AUTUMN_STAGE_TERMINAL) return 0;
    if(IsPlayerInAnyVehicle(playerid)) return 0;

    return IsPlayerInRangeOfPoint(playerid, radius,
        gAutumnTerminalPos[0],
        gAutumnTerminalPos[1],
        gAutumnTerminalPos[2]);
}

stock AutumnEvent_IsNearFinalPoint(playerid, Float:radius = 3.4)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;
    if(gAutumnStage[playerid] != AUTUMN_STAGE_FINAL || gAutumnSubStage[playerid] != 1) return 0;
    if(IsPlayerInAnyVehicle(playerid)) return 0;
    if(gAutumnFinalPoint[0] == 0.0 && gAutumnFinalPoint[1] == 0.0) return 0;

    return IsPlayerInRangeOfPoint(playerid, radius,
        gAutumnFinalPoint[0], gAutumnFinalPoint[1], gAutumnFinalPoint[2]);
}

stock AutumnEvent_SetRoute(playerid)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;

    switch(gAutumnStage[playerid])
    {
        case AUTUMN_STAGE_NOT_STARTED:
        {
            new npc = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_FORESTER);
            if(npc != -1)
                return AutumnEvent_SetPointRoute(playerid,
                    gAutumnNpcPos[npc][0], gAutumnNpcPos[npc][1], gAutumnNpcPos[npc][2],
                    4.0,
                    "Лесник Григорий отмечен на карте.");
        }
        case AUTUMN_STAGE_CLUES:
        {
            if(gAutumnSubStage[playerid] == 0)
                return AutumnEvent_SetPointRoute(playerid, gAutumnNodePos[0], gAutumnNodePos[1], gAutumnNodePos[2], 3.2, "Осмотрите поврежденный узел связи.");

            if(gAutumnSubStage[playerid] == 1)
            {
                new npc = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_SCOUT);
                if(npc != -1) return AutumnEvent_SetPointRoute(playerid, gAutumnNpcPos[npc][0], gAutumnNpcPos[npc][1], gAutumnNpcPos[npc][2], 4.0, "Найдите Алису Следопытку.");
            }

            new clue = AutumnEvent_GetNextMissingClue(playerid);
            if(clue != -1)
                return AutumnEvent_SetPointRoute(playerid, gAutumnCluePos[clue][0], gAutumnCluePos[clue][1], gAutumnCluePos[clue][2], 3.2, "Следующая улика отмечена на GPS.");

            gAutumnStage[playerid] = AUTUMN_STAGE_MECHANIC;
            gAutumnSubStage[playerid] = 0;
            AutumnEvent_SavePlayer(playerid);
            return AutumnEvent_SetRoute(playerid);
        }
        case AUTUMN_STAGE_ALICE:
        {
            new npc = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_SCOUT);
            if(npc != -1)
                return AutumnEvent_SetPointRoute(playerid,
                    gAutumnNpcPos[npc][0], gAutumnNpcPos[npc][1], gAutumnNpcPos[npc][2],
                    4.0,
                    "Алиса Следопытка ждёт Вас.");
        }
        case AUTUMN_STAGE_MECHANIC:
        {
            new npc = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_MECHANIC);
            if(npc != -1)
                return AutumnEvent_SetPointRoute(playerid,
                    gAutumnNpcPos[npc][0], gAutumnNpcPos[npc][1], gAutumnNpcPos[npc][2],
                    4.0,
                    "Механик Марк отмечен на карте.");
        }
        case AUTUMN_STAGE_HUNTER:
        {
            new npc = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_HUNTER);
            if(npc != -1)
                return AutumnEvent_SetPointRoute(playerid,
                    gAutumnNpcPos[npc][0], gAutumnNpcPos[npc][1], gAutumnNpcPos[npc][2],
                    4.0,
                    "Охотник Филиппыч ждёт Вас.");
        }
        case AUTUMN_STAGE_DELIVERY:
        {
            new point = gAutumnSubStage[playerid];
            if(point < 0) point = 0;
            if(point >= AUTUMN_EVENT_DELIVERY_POINTS) point = AUTUMN_EVENT_DELIVERY_POINTS - 1;

            return AutumnEvent_SetPointRoute(playerid,
                gAutumnDeliveryPos[point][0],
                gAutumnDeliveryPos[point][1],
                gAutumnDeliveryPos[point][2],
                5.5,
                "Доставьте осенние припасы в отмеченную точку.");
        }
        case AUTUMN_STAGE_TERMINAL:
        {
            if(gAutumnSubStage[playerid] == 0)
                return AutumnEvent_SetPointRoute(playerid,
                    gAutumnTerminalPos[0],
                    gAutumnTerminalPos[1],
                    gAutumnTerminalPos[2],
                    4.0,
                    "Осмотрите повреждённый распределительный щит ретранслятора.");

            return AutumnEvent_SetPointRoute(playerid,
                gAutumnTerminalPos[0],
                gAutumnTerminalPos[1],
                gAutumnTerminalPos[2],
                4.0,
                "Аварийный контур восстановлен. Ретранслятор готов к запуску.");
        }
        case AUTUMN_STAGE_FINAL:
        {
            if(gAutumnSubStage[playerid] == 0)
            {
                new host = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_HOST);
                if(host != -1)
                    return AutumnEvent_SetPointRoute(playerid,
                        gAutumnNpcPos[host][0], gAutumnNpcPos[host][1], gAutumnNpcPos[host][2],
                        4.0,
                        "Хозяин таверны ждёт Вас. Он знает, где искать последнюю часть истории.");
            }
            if(gAutumnSubStage[playerid] == 1 && (gAutumnFinalPoint[0] != 0.0 || gAutumnFinalPoint[1] != 0.0))
                return AutumnEvent_SetPointRoute(playerid,
                    gAutumnFinalPoint[0], gAutumnFinalPoint[1], gAutumnFinalPoint[2],
                    3.4,
                    "Последний тайник старого тракта отмечен на GPS.");

            new finalnpc = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_FINAL);
            if(finalnpc != -1)
                return AutumnEvent_SetPointRoute(playerid,
                    gAutumnNpcPos[finalnpc][0], gAutumnNpcPos[finalnpc][1], gAutumnNpcPos[finalnpc][2],
                    4.0,
                    "Следователь Ловцова ждёт Вас для завершения расследования.");
        }
        case AUTUMN_STAGE_COMPLETED:
        {
            AutumnEvent_ClearRoute(playerid);
            return 1;
        }
    }
    return 0;
}

stock AutumnEvent_DestroyVehicle(playerid)
{
    if(gAutumnEventVehicle[playerid] != INVALID_VEHICLE_ID &&
       IsValidVehicle(gAutumnEventVehicle[playerid]))
    {
        DestroyVehicle(gAutumnEventVehicle[playerid]);
    }
    gAutumnEventVehicle[playerid] = INVALID_VEHICLE_ID;
    return 1;
}

stock AutumnEvent_GiveStageVehicle(playerid, vehicle_index)
{
    if(vehicle_index < 0 || vehicle_index >= sizeof(gAutumnStageVehicleModel))
        return 0;

    AutumnEvent_DestroyVehicle(playerid);

    new Float:x, Float:y, Float:z, Float:a;
    if(vehicle_index == 0)
    {
        x = gAutumnCar1Pos[0]; y = gAutumnCar1Pos[1]; z = gAutumnCar1Pos[2]; a = gAutumnCar1Pos[3];
    }
    else if(vehicle_index == 1 && (gAutumnCar2Pos[0] != 0.0 || gAutumnCar2Pos[1] != 0.0))
    {
        x = gAutumnCar2Pos[0]; y = gAutumnCar2Pos[1]; z = gAutumnCar2Pos[2]; a = gAutumnCar2Pos[3];
    }
    else if(vehicle_index == 2 && (gAutumnCar3Pos[0] != 0.0 || gAutumnCar3Pos[1] != 0.0))
    {
        x = gAutumnCar3Pos[0]; y = gAutumnCar3Pos[1]; z = gAutumnCar3Pos[2]; a = gAutumnCar3Pos[3];
    }
    else if(vehicle_index == 3 && (gAutumnRewardCarPoint[0] != 0.0 || gAutumnRewardCarPoint[1] != 0.0))
    {
        x = gAutumnRewardCarPoint[0]; y = gAutumnRewardCarPoint[1]; z = gAutumnRewardCarPoint[2]; a = gAutumnRewardCarPoint[3];
    }
    else
    {
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
        x += 3.0; y += 1.5; z += 0.4;
    }

    if(IsPlayerInAnyVehicle(playerid))
        RemovePlayerFromVehicle(playerid);

    new used_model = gAutumnStageVehicleModel[vehicle_index];
    new vehicleid = CreateVehicle(used_model, x, y, z, a, 1, 1, -1);

    // A second model from the same supplied vehicle list prevents a quest deadlock
    // if a particular replacement model is unavailable on the running client/server build.
    if(vehicleid == INVALID_VEHICLE_ID || vehicleid <= 0)
    {
        used_model = gAutumnStageVehicleFallback[vehicle_index];
        vehicleid = CreateVehicle(used_model, x, y, z, a, 1, 1, -1);
    }

    if(vehicleid == INVALID_VEHICLE_ID || vehicleid <= 0)
    {
        printf("[AutumnEvent] VEHICLE CREATE FAILED: player=%d stageIndex=%d primary=%d fallback=%d", playerid, vehicle_index, gAutumnStageVehicleModel[vehicle_index], gAutumnStageVehicleFallback[vehicle_index]);
        ShowNotificationNew(playerid, 2, 8, 0, 0,
            "Транспорт не удалось создать: серверный пул транспорта заполнен. Освободите место и повторите действие позже.",
            " ");
        return 0;
    }

    gAutumnEventVehicle[playerid] = vehicleid;
    SetVehicleHealth(vehicleid, 1000.0);
    SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
    LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));

    new text[192];
    format(text, sizeof text,
        "Ключи и документы от транспорта переданы. Машина подготовлена к поездке.");
    ShowNotificationNew(playerid, 3, 7, 0, 0, text, " ");
    return 1;
}

stock AutumnEvent_ShowStageRewardGui(playerid, stage_number, stage_name[])
{
    AutumnEvent_CloseGui(playerid);

    new title[96];
    format(title, sizeof title, "{E0584B}\xc7\xce\xcb\xce\xd2\xce\xc9\x20\xd1\xcb\xc5\xc4{FFFFFF} | \xcd\xc0\xc3\xd0\xc0\xc4\xc0\x20\xc7\xc0\x20\xdd\xd2\xc0\xcf");

    new text[900];
    format(text, sizeof text,
        "{FFFFFF}\xcf\xee\xe7\xe4\xf0\xe0\xe2\xeb\xff\xe5\xec\x21\n"        "{FFFFFF}\xc2\xfb\x20\xf3\xf1\xef\xe5\xf8\xed\xee\x20\xe7\xe0\xe2\xe5\xf0\xf8\xe8\xeb\xe8\x20\xfd\xf2\xe0\xef\x20\xee\xf1\xe5\xed\xed\xe5\xe3\xee\x20\xe8\xe2\xe5\xed\xf2\xe0 {E0584B}#%d{FFFFFF}.\n\n"        "{FFFFFF}%s\n\n"        "{FFFFFF}\xc2\xfb\x20\xef\xee\xeb\xf3\xf7\xe8\xeb\xe8\x20\xed\xe0\xe3\xf0\xe0\xe4\xfb\x3a\n"        "{E0584B}1. {FFE066}1 000 000 \xf0\xf3\xe1\x2e{FFFFFF}\n"        "{E0584B}2. {FFE066}300 BC{FFFFFF}\n\n"        "{FFFFFF}\xcf\xf0\xe8\xff\xf2\xed\xee\xe9\x20\xe8\xe3\xf0\xfb\x20\xed\xe0\x20{FFE066}\x53\x41\x4d\x45\x20\x52\x55\x53\x53\x49\x41{FFFFFF}",
        stage_number, stage_name);

    ShowPlayerDialog(playerid, DIALOG_AUTUMN_STAGE_REWARD, DIALOG_STYLE_MSGBOX,
        title, text, "\xd5\xee\xf0\xee\xf8\xee", "");
    return 1;
}

stock AutumnEvent_GiveStageReward(playerid, stage_number, reason[])
{
    GivePlayerMoneyEx(playerid, AUTUMN_EVENT_STAGE_MONEY, reason, true, true);
    GivePlayerDonateRub(playerid, AUTUMN_EVENT_STAGE_BC, reason, true, true);

    new stage_name[96];
    switch(stage_number)
    {
        case 1: format(stage_name, sizeof stage_name, "Следы сложились в одну картину");
        case 2: format(stage_name, sizeof stage_name, "Маршрут снабжения восстановлен");
        case 3: format(stage_name, sizeof stage_name, "Ретранслятор снова вышел на связь");
        default: format(stage_name, sizeof stage_name, "Часть расследования завершена");
    }
    return AutumnEvent_ShowStageRewardGui(playerid, stage_number, stage_name);
}


stock AutumnEvent_SetStage(playerid, stage, sub_stage = 0)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;

    gAutumnStage[playerid] = stage;
    gAutumnSubStage[playerid] = sub_stage;

    if(stage != AUTUMN_STAGE_CLUES)
        gAutumnProgressArg[playerid] = -1;

    AutumnEvent_SavePlayer(playerid);
    AutumnEvent_SetRoute(playerid);
    return 1;
}


// --------------------------------------------------------------------------
// Admin quest checkpoint jumper.
// Human-friendly checkpoints deliberately do not grant money/BC/EXP: they only
// prepare the same state that a real player would have at that point, save it,
// set the route and teleport the tester close enough to interact immediately.
// /setstage event [0-15|next|prev|reset]
// --------------------------------------------------------------------------
stock AutumnEvent_AdminGetCheckpoint(playerid)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;

    switch(gAutumnStage[playerid])
    {
        case AUTUMN_STAGE_NOT_STARTED: return 1;
        case AUTUMN_STAGE_CLUES:
        {
            if(gAutumnSubStage[playerid] <= 0) return 2;
            if(gAutumnSubStage[playerid] == 1) return 3;
            return 4;
        }
        case AUTUMN_STAGE_ALICE: return 3;
        case AUTUMN_STAGE_MECHANIC: return 5;
        case AUTUMN_STAGE_HUNTER: return 6;
        case AUTUMN_STAGE_DELIVERY:
        {
            new point = gAutumnSubStage[playerid];
            if(point < 0) point = 0;
            if(point > 2) point = 2;
            return 7 + point;
        }
        case AUTUMN_STAGE_TERMINAL:
        {
            return (gAutumnSubStage[playerid] <= 0) ? 10 : 11;
        }
        case AUTUMN_STAGE_FINAL:
        {
            if(gAutumnSubStage[playerid] <= 0) return 12;
            if(gAutumnSubStage[playerid] == 1) return 13;
            return 14;
        }
        case AUTUMN_STAGE_COMPLETED: return 15;
    }
    return 1;
}

stock AutumnEvent_AdminTeleportToRole(playerid, role, Float:offset_x = 1.15, Float:offset_y = 1.15)
{
    new Float:x, Float:y, Float:z, Float:a;
    new npc = AutumnEvent_FindNpcByRole(role);

    if(npc != -1)
    {
        x = gAutumnNpcPos[npc][0];
        y = gAutumnNpcPos[npc][1];
        z = gAutumnNpcPos[npc][2];
        a = gAutumnNpcPos[npc][3];
    }
    else
    {
        x = gAutumnDefaultNpc[role][AUTUMN_DEF_X];
        y = gAutumnDefaultNpc[role][AUTUMN_DEF_Y];
        z = gAutumnDefaultNpc[role][AUTUMN_DEF_Z];
        a = gAutumnDefaultNpc[role][AUTUMN_DEF_A];
    }

    SetPlayerPosEx(playerid, x + offset_x, y + offset_y, z + 0.15, a, 0, 0, false);
    return 1;
}

stock AutumnEvent_AdminJump(playerid, checkpoint)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;
    if(checkpoint < 0 || checkpoint > 15) return 0;

    // Cancel every transient action before changing the persistent quest state.
    if(gAutumnProgressTimer[playerid] != -1)
    {
        KillTimer(gAutumnProgressTimer[playerid]);
        gAutumnProgressTimer[playerid] = -1;
    }
    gAutumnProgressKind[playerid] = AUTUMN_PROGRESS_NONE;
    gAutumnProgressArg[playerid] = -1;
    HidePlayerGUI(playerid, 31);
    ClearAnimations(playerid);

    if(gAutumnGuiOpen[playerid])
        AutumnEvent_CloseGui(playerid);

    if(gAutumnInteractionVisible[playerid])
    {
        ToggleInteractionWindow(playerid, false);
        gAutumnInteractionVisible[playerid] = false;
    }

    if(IsPlayerInAnyVehicle(playerid))
        RemovePlayerFromVehicle(playerid);

    AutumnEvent_DestroyVehicle(playerid);
    AutumnEvent_ClearRoute(playerid);

    gAutumnCompleted[playerid] = false;
    gAutumnRewardReceived[playerid] = false;
    gAutumnClueMask[playerid] = 0;

    new stage = AUTUMN_STAGE_NOT_STARTED;
    new sub_stage = 0;
    new Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, Float:a = 0.0;
    new role = -1;
    new vehicle_index = -1;
    new stage_name[96];

    switch(checkpoint)
    {
        case 0, 1:
        {
            stage = AUTUMN_STAGE_NOT_STARTED;
            role = AUTUMN_ROLE_FORESTER;
            format(stage_name, sizeof stage_name, "Старт события / лесник Григорий");
        }
        case 2:
        {
            stage = AUTUMN_STAGE_CLUES;
            sub_stage = 0;
            x = gAutumnNodePos[0]; y = gAutumnNodePos[1]; z = gAutumnNodePos[2]; a = gAutumnNodePos[3];
            format(stage_name, sizeof stage_name, "Поврежденный узел связи");
        }
        case 3:
        {
            stage = AUTUMN_STAGE_CLUES;
            sub_stage = 1;
            role = AUTUMN_ROLE_SCOUT;
            format(stage_name, sizeof stage_name, "Разговор с Алисой");
        }
        case 4:
        {
            stage = AUTUMN_STAGE_CLUES;
            sub_stage = 2;
            x = gAutumnCluePos[0][0]; y = gAutumnCluePos[0][1]; z = gAutumnCluePos[0][2];
            format(stage_name, sizeof stage_name, "Поиск трех улик");
        }
        case 5:
        {
            stage = AUTUMN_STAGE_MECHANIC;
            gAutumnClueMask[playerid] = 7;
            role = AUTUMN_ROLE_MECHANIC;
            format(stage_name, sizeof stage_name, "Механик Марк / анализ деталей");
        }
        case 6:
        {
            stage = AUTUMN_STAGE_HUNTER;
            gAutumnClueMask[playerid] = 7;
            role = AUTUMN_ROLE_HUNTER;
            format(stage_name, sizeof stage_name, "Охотник Филиппыч");
        }
        case 7, 8, 9:
        {
            stage = AUTUMN_STAGE_DELIVERY;
            sub_stage = checkpoint - 7;
            gAutumnClueMask[playerid] = 7;
            x = gAutumnDeliveryPos[sub_stage][0];
            y = gAutumnDeliveryPos[sub_stage][1];
            z = gAutumnDeliveryPos[sub_stage][2];
            vehicle_index = 1;
            format(stage_name, sizeof stage_name, "Доставка припасов %d/3", sub_stage + 1);
        }
        case 10:
        {
            stage = AUTUMN_STAGE_TERMINAL;
            sub_stage = 0;
            gAutumnClueMask[playerid] = 7;
            x = gAutumnTerminalPos[0]; y = gAutumnTerminalPos[1]; z = gAutumnTerminalPos[2];
            format(stage_name, sizeof stage_name, "Ремонт ретранслятора");
        }
        case 11:
        {
            stage = AUTUMN_STAGE_TERMINAL;
            sub_stage = 1;
            gAutumnClueMask[playerid] = 7;
            x = gAutumnTerminalPos[0]; y = gAutumnTerminalPos[1]; z = gAutumnTerminalPos[2];
            format(stage_name, sizeof stage_name, "Запуск питания ретранслятора");
        }
        case 12:
        {
            stage = AUTUMN_STAGE_FINAL;
            sub_stage = 0;
            gAutumnClueMask[playerid] = 7;
            role = AUTUMN_ROLE_HOST;
            vehicle_index = 2;
            format(stage_name, sizeof stage_name, "Хозяин таверны");
        }
        case 13:
        {
            gAutumnClueMask[playerid] = 7;
            if(gAutumnFinalPoint[0] != 0.0 || gAutumnFinalPoint[1] != 0.0)
            {
                stage = AUTUMN_STAGE_FINAL;
                sub_stage = 1;
                x = gAutumnFinalPoint[0]; y = gAutumnFinalPoint[1]; z = gAutumnFinalPoint[2]; a = gAutumnFinalPoint[3];
                vehicle_index = 2;
                format(stage_name, sizeof stage_name, "Последний тайник");
            }
            else
            {
                stage = AUTUMN_STAGE_FINAL;
                sub_stage = 2;
                role = AUTUMN_ROLE_FINAL;
                format(stage_name, sizeof stage_name, "Финальный следователь (тайник не настроен)");
            }
        }
        case 14:
        {
            stage = AUTUMN_STAGE_FINAL;
            sub_stage = 2;
            gAutumnClueMask[playerid] = 7;
            role = AUTUMN_ROLE_FINAL;
            format(stage_name, sizeof stage_name, "Финальный диалог и награда");
        }
        case 15:
        {
            stage = AUTUMN_STAGE_COMPLETED;
            sub_stage = 0;
            gAutumnClueMask[playerid] = 7;
            gAutumnCompleted[playerid] = true;
            gAutumnRewardReceived[playerid] = true;
            role = AUTUMN_ROLE_FINAL;
            format(stage_name, sizeof stage_name, "Событие завершено (тестовое состояние)");
        }
    }

    gAutumnStage[playerid] = stage;
    gAutumnSubStage[playerid] = sub_stage;
    AutumnEvent_SavePlayer(playerid);

    if(role != -1)
    {
        AutumnEvent_AdminTeleportToRole(playerid, role);
    }
    else
    {
        // A small offset keeps the tester inside the interaction radius without
        // placing the ped exactly inside the marker/object.
        SetPlayerPosEx(playerid, x + 1.15, y + 1.15, z + 0.20, a, 0, 0, false);
    }

    if(vehicle_index != -1)
    {
        AutumnEvent_GiveStageVehicle(playerid, vehicle_index);

        // Delivery checkpoints validate that the quest van is nearby. Keep it
        // beside the tester even when a configured vehicle spawn is far away.
        if(stage == AUTUMN_STAGE_DELIVERY &&
           gAutumnEventVehicle[playerid] != INVALID_VEHICLE_ID &&
           IsValidVehicle(gAutumnEventVehicle[playerid]))
        {
            SetVehiclePos(gAutumnEventVehicle[playerid], x + 4.0, y + 1.0, z + 0.35);
        }
    }

    AutumnEvent_SetRoute(playerid);

    new message[196];
    format(message, sizeof message,
        "[EVENT TEST] Точка %d/15: %s. Прогресс сохранен. /setstage event next - следующая.",
        checkpoint, stage_name);
    SendClientMessage(playerid, 0x66CCFFFF, message);
    return 1;
}

stock AutumnEvent_AdminJumpCommand(playerid, const value[])
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;

    if(isnull(value))
    {
        SendClientMessage(playerid, 0xFFD54FFF, "Использование: /setstage event [0-15 | next | prev | reset]");
        SendClientMessage(playerid, 0xCECECEFF, "1 старт, 2 узел, 3 Алиса, 4 улики, 5 Марк, 6 Филиппыч, 7-9 доставка.");
        SendClientMessage(playerid, 0xCECECEFF, "10 ремонт ретранслятора, 11 запуск питания, 12 таверна, 13 тайник, 14 финал/награда, 15 завершено.");
        return 1;
    }

    new checkpoint;
    if(!strcmp(value, "next", true))
    {
        checkpoint = AutumnEvent_AdminGetCheckpoint(playerid) + 1;
        if(checkpoint > 15) checkpoint = 15;
    }
    else if(!strcmp(value, "prev", true) || !strcmp(value, "back", true))
    {
        checkpoint = AutumnEvent_AdminGetCheckpoint(playerid) - 1;
        if(checkpoint < 1) checkpoint = 1;
    }
    else if(!strcmp(value, "reset", true))
    {
        checkpoint = 0;
    }
    else
    {
        if(sscanf(value, "i", checkpoint) || checkpoint < 0 || checkpoint > 15)
        {
            SendClientMessage(playerid, 0xFF5555FF, "[EVENT TEST] Укажите точку 0-15, next, prev или reset.");
            return 1;
        }
    }

    // Numeric 0/reset exits admin event-test mode; every other checkpoint keeps
    // map teleport disabled so test admins follow the same route as players.
    gAutumnAdminTestMode[playerid] = (checkpoint != 0);
    return AutumnEvent_AdminJump(playerid, checkpoint);
}

stock AutumnEvent_Start(playerid)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;
    if(AutumnEvent_IsAdmin(playerid)) gAutumnAdminTestMode[playerid] = true;
    if(!gAutumnEventEnabled)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0,
            "Осенняя квестовая линия сейчас отключена администрацией.",
            " ");
        return 0;
    }

    if(gAutumnStage[playerid] != AUTUMN_STAGE_NOT_STARTED)
    {
        AutumnEvent_SetRoute(playerid);
        return 1;
    }

    gAutumnClueMask[playerid] = 0;
    gAutumnCompleted[playerid] = false;
    gAutumnRewardReceived[playerid] = false;
    AutumnEvent_SetStage(playerid, AUTUMN_STAGE_CLUES, 0);

    ShowNotificationNew(playerid, 3, 8, 0, 0,
        "История 'Золотой след' началась. Теперь всё зависит от того, какие детали вы заметите и каким словам поверите.",
        " ");
    return 1;
}

stock AutumnEvent_GetNpcDescription(playerid, npc, dest[], size)
{
    if(npc < 0 || npc >= gAutumnNpcCount)
    {
        format(dest, size, "Сейчас здесь никого нет. Возможно, стоит вернуться позже.");
        return 0;
    }

    new role = gAutumnNpcRole[npc];
    AutumnEvent_EnsureLoaded(playerid);

    switch(role)
    {
        case AUTUMN_ROLE_FORESTER:
        {
            if(gAutumnStage[playerid] == AUTUMN_STAGE_NOT_STARTED)
                format(dest, size,
                    "Гроза прошла быстро, а вот следы после неё остались. На старом тракте оборвалась связь, возле опоры лежали осколки пластика и металла. "\
                    "Чуть дальше я заметил свежую колею - тяжёлая машина ушла с дороги и снова вернулась на неё.\n\n"\
                    "Если хотите понять, что произошло, начните не с чужих рассказов, а с самого места. Там ещё можно найти то, что не успели смыть дождь и грязь.");
            else if(gAutumnStage[playerid] == AUTUMN_STAGE_COMPLETED)
                format(dest, size,
                    "Теперь на тракте снова спокойно. Связь работает, документы переданы, а история с ночной машиной наконец получила объяснение. Хорошая работа.");
            else
                format(dest, size,
                    "У каждого на тракте своя версия произошедшего. Не торопитесь верить первой. Смотрите на следы, сопоставляйте детали и разговаривайте с теми, кто действительно что-то видел.");
        }
        case AUTUMN_ROLE_SCOUT:
        {
            if(gAutumnStage[playerid] == AUTUMN_STAGE_CLUES && gAutumnSubStage[playerid] == 1)
                format(dest, size,
                    "Я прошла по колее от оборванного кабеля. Машина несколько раз съезжала к обочине, и в трёх местах осталось то, чего там раньше не было. "\
                    "Следы разные, но относятся к одной машине.\n\n"\
                    "Я запомнила эти места. Дальше решайте сами, какие находки действительно важны и что из них можно связать между собой.");
            else
                format(dest, size,
                    "Следы на мокрой земле быстро исчезают. Я уже собрала всё, что могла увидеть с первого взгляда. Остальное придётся складывать в одну картину по деталям.");
        }
        case AUTUMN_ROLE_MECHANIC:
        {
            if(gAutumnStage[playerid] == AUTUMN_STAGE_MECHANIC)
                format(dest, size,
                    "На таких деталях редко остаётся что-то полезное, но здесь повезло: маркировка читается, а характер повреждения слишком знакомый. "\
                    "Покажите всё, что нашли. Если номера совпадут, станет понятно, к какой машине это относилось.");
            else
                format(dest, size,
                    "По одной детали выводы делать рано. Когда картина будет полной, тогда и можно будет говорить о конкретной машине.");
        }
        case AUTUMN_ROLE_HUNTER:
        {
            if(gAutumnStage[playerid] == AUTUMN_STAGE_HUNTER)
                format(dest, size,
                    "Марк уже звонил. Машину, о которой вы спрашиваете, здесь знали: она возила снабжение и перед исчезновением прошла обычный рейс не совсем обычно.\n\n"\
                    "У меня остались ключи от похожего транспорта и старые накладные. Возьмите их. По дороге сами поймёте, что в этом рейсе не сходится.");
            else
                format(dest, size,
                    "На этих дорогах многое выглядит случайностью, пока не знаешь, куда смотреть. Если ваше расследование действительно связано с рейсами снабжения - ещё поговорим.");
        }
        case AUTUMN_ROLE_HOST:
        {
            if(gAutumnStage[playerid] == AUTUMN_STAGE_FINAL && gAutumnSubStage[playerid] == 0)
                format(dest, size,
                    "Раз связь снова появилась, значит, вы добрались до старого оборудования. Тогда вам стоит знать ещё одну вещь.\n\n"\
                    "Прежний смотритель не доверял журналам в конторе. Важные бумаги он держал отдельно - говорил, что однажды они кому-нибудь понадобятся. Где именно, он рассказывал только тем, кому доверял.");
            else
                format(dest, size,
                    "Здесь много историй про старый тракт. Половина выдумана, половину никто не хочет рассказывать вслух. Приходите, когда у вас будут вопросы по существу.");
        }
        case AUTUMN_ROLE_FINAL:
        {
            if(gAutumnStage[playerid] == AUTUMN_STAGE_FINAL && gAutumnSubStage[playerid] >= 2)
                format(dest, size,
                    "Теперь всё сходится: маркировка деталей, рейс машины, сбой ретранслятора и записи смотрителя. Эти документы закрывают последние пробелы.\n\n"\
                    "Я приму материалы и оформлю дело. После этого расследование можно считать завершённым.");
            else if(gAutumnStage[playerid] == AUTUMN_STAGE_COMPLETED)
                format(dest, size,
                    "Материалы уже в деле. История старого тракта закрыта, а ваши показания приложены к итоговому отчёту.");
            else
                format(dest, size,
                    "Пока это только отдельные факты. Мне нужен материал, который свяжет их в одну непротиворечивую версию.");
        }
    }
    return 1;
}


stock AutumnEvent_ShowNpcGui(playerid, npc, page = 0)
{
    if(npc < 0 || npc >= gAutumnNpcCount) return 0;

    new Node:json = JSON_Object();
    JSON_SetInt(json, "o", 1);
    JSON_SetInt(json, "m", gAutumnNpcModel[npc]);
    JSON_SetString(json, "n", gAutumnNpcName[npc]);
    JSON_SetInt(json, "ts", 3);

    new desc[900];
    AutumnEvent_GetNpcDescription(playerid, npc, desc, sizeof desc);
    JSON_SetString(json, "d", desc);

    new Node:button1 = JSON_Object();
    new Node:button2 = JSON_Object();
    new Node:button3 = JSON_Object();

    new role = gAutumnNpcRole[npc];

    if(!gAutumnEventEnabled)
    {
        JSON_SetString(button1, "bn", "ПОНЯЛ");
        JSON_SetInt(button1, "bt", 0);
        JSON_SetInt(button1, "bk", AUTUMN_GUI_CLOSE);

        JSON_SetString(button2, "bn", "ЗАКРЫТЬ");
        JSON_SetInt(button2, "bt", 3);
        JSON_SetInt(button2, "bk", AUTUMN_GUI_CLOSE);

        JSON_SetString(button3, "bn", "ПОЗЖЕ");
        JSON_SetInt(button3, "bt", 2);
        JSON_SetInt(button3, "bk", AUTUMN_GUI_CLOSE);
    }
    else if(role == AUTUMN_ROLE_FORESTER &&
            gAutumnStage[playerid] == AUTUMN_STAGE_NOT_STARTED)
    {
        JSON_SetString(button1, "bn", "НАЧАТЬ ИСТОРИЮ");
        JSON_SetInt(button1, "bt", 1);
        JSON_SetInt(button1, "bk", AUTUMN_GUI_START);

        JSON_SetString(button2, "bn", "ЧТО ПРОИЗОШЛО?");
        JSON_SetInt(button2, "bt", 2);
        JSON_SetInt(button2, "bk", AUTUMN_GUI_ABOUT);

        JSON_SetString(button3, "bn", "ПОЗЖЕ");
        JSON_SetInt(button3, "bt", 3);
        JSON_SetInt(button3, "bk", AUTUMN_GUI_CLOSE);
    }
    else if(role == AUTUMN_ROLE_SCOUT &&
            gAutumnStage[playerid] == AUTUMN_STAGE_CLUES && gAutumnSubStage[playerid] == 1)
    {
        JSON_SetString(button1, "bn", "РАССКАЗАТЬ О СЛЕДАХ");
        JSON_SetInt(button1, "bt", 1);
        JSON_SetInt(button1, "bk", AUTUMN_GUI_ALICE_CONTINUE);

        JSON_SetString(button2, "bn", "ВСПОМНИТЬ ДЕТАЛИ");
        JSON_SetInt(button2, "bt", 2);
        JSON_SetInt(button2, "bk", AUTUMN_GUI_REFRESH_ROUTE);

        JSON_SetString(button3, "bn", "ЗАКРЫТЬ");
        JSON_SetInt(button3, "bt", 3);
        JSON_SetInt(button3, "bk", AUTUMN_GUI_CLOSE);
    }
    else if(role == AUTUMN_ROLE_MECHANIC &&
            gAutumnStage[playerid] == AUTUMN_STAGE_MECHANIC)
    {
        JSON_SetString(button1, "bn", "ОТДАТЬ ДЕТАЛИ");
        JSON_SetInt(button1, "bt", 1);
        JSON_SetInt(button1, "bk", AUTUMN_GUI_MECHANIC_INSPECT);

        JSON_SetString(button2, "bn", "ВСПОМНИТЬ ДЕТАЛИ");
        JSON_SetInt(button2, "bt", 2);
        JSON_SetInt(button2, "bk", AUTUMN_GUI_REFRESH_ROUTE);

        JSON_SetString(button3, "bn", "ЗАКРЫТЬ");
        JSON_SetInt(button3, "bt", 3);
        JSON_SetInt(button3, "bk", AUTUMN_GUI_CLOSE);
    }
    else if(role == AUTUMN_ROLE_HUNTER &&
            gAutumnStage[playerid] == AUTUMN_STAGE_HUNTER)
    {
        JSON_SetString(button1, "bn", "ВЗЯТЬ КЛЮЧИ");
        JSON_SetInt(button1, "bt", 1);
        JSON_SetInt(button1, "bk", AUTUMN_GUI_HUNTER_START);

        JSON_SetString(button2, "bn", "ВСПОМНИТЬ ДЕТАЛИ");
        JSON_SetInt(button2, "bt", 2);
        JSON_SetInt(button2, "bk", AUTUMN_GUI_REFRESH_ROUTE);

        JSON_SetString(button3, "bn", "ЗАКРЫТЬ");
        JSON_SetInt(button3, "bt", 3);
        JSON_SetInt(button3, "bk", AUTUMN_GUI_CLOSE);
    }
    else if(role == AUTUMN_ROLE_HOST &&
            gAutumnStage[playerid] == AUTUMN_STAGE_FINAL && gAutumnSubStage[playerid] == 0)
    {
        JSON_SetString(button1, "bn", "СПРОСИТЬ О БУМАГАХ");
        JSON_SetInt(button1, "bt", 1);
        JSON_SetInt(button1, "bk", AUTUMN_GUI_HOST_CONTINUE);

        JSON_SetString(button2, "bn", "ВСПОМНИТЬ ДЕТАЛИ");
        JSON_SetInt(button2, "bt", 2);
        JSON_SetInt(button2, "bk", AUTUMN_GUI_REFRESH_ROUTE);

        JSON_SetString(button3, "bn", "ПОЗЖЕ");
        JSON_SetInt(button3, "bt", 3);
        JSON_SetInt(button3, "bk", AUTUMN_GUI_CLOSE);
    }
    else if(role == AUTUMN_ROLE_FINAL &&
            gAutumnStage[playerid] == AUTUMN_STAGE_FINAL && gAutumnSubStage[playerid] >= 2)
    {
        JSON_SetString(button1, "bn", "ПЕРЕДАТЬ ДОКУМЕНТЫ");
        JSON_SetInt(button1, "bt", 1);
        JSON_SetInt(button1, "bk", AUTUMN_GUI_FINAL_REWARD);

        JSON_SetString(button2, "bn", "ВСПОМНИТЬ ДЕТАЛИ");
        JSON_SetInt(button2, "bt", 2);
        JSON_SetInt(button2, "bk", AUTUMN_GUI_REFRESH_ROUTE);

        JSON_SetString(button3, "bn", "ПОЗЖЕ");
        JSON_SetInt(button3, "bt", 3);
        JSON_SetInt(button3, "bk", AUTUMN_GUI_CLOSE);
    }
    else
    {
        JSON_SetString(button1, "bn", "ВСПОМНИТЬ ДЕТАЛИ");
        JSON_SetInt(button1, "bt", 1);
        JSON_SetInt(button1, "bk", AUTUMN_GUI_REFRESH_ROUTE);

        JSON_SetString(button2, "bn", "О СОБЫТИИ");
        JSON_SetInt(button2, "bt", 2);
        JSON_SetInt(button2, "bk", AUTUMN_GUI_ABOUT);

        JSON_SetString(button3, "bn", "ЗАКРЫТЬ");
        JSON_SetInt(button3, "bt", 3);
        JSON_SetInt(button3, "bk", AUTUMN_GUI_CLOSE);
    }

    new Node:buttons = JSON_Array(button1, button2, button3);
    JSON_SetArray(json, "b", buttons);

    JSON_Cleanup(button1);
    JSON_Cleanup(button2);
    JSON_Cleanup(button3);
    JSON_Cleanup(buttons);

    gAutumnGuiOpen[playerid] = true;
    gAutumnCurrentNpc[playerid] = npc;
    ShowPlayerGUI(playerid, 63, json);
    JSON_Cleanup(json);
    return 1;
}

stock AutumnEvent_ShowAbout(playerid)
{
    new npc = gAutumnCurrentNpc[playerid];
    if(npc < 0 || npc >= gAutumnNpcCount)
        npc = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_FORESTER);

    if(npc == -1) return 0;

    new desc[760];
    format(desc, sizeof desc,
        "'Золотой след' - история о старом тракте, на котором после осенней грозы пропала связь и появилась машина, которой там не должно было быть.\n\n"\
        "Здесь нет готового списка ответов. Слушайте персонажей, осматривайте места, запоминайте детали и сопоставляйте найденное. Некоторые слова могут оказаться важнее отметок на карте.\n\n"\
        "Прогресс расследования сохраняется автоматически.");

    new Node:json = JSON_Object();
    JSON_SetInt(json, "o", 1);
    JSON_SetInt(json, "m", gAutumnNpcModel[npc]);
    JSON_SetString(json, "n", "Золотой след | История");
    JSON_SetInt(json, "ts", 3);
    JSON_SetString(json, "d", desc);

    new Node:b1 = JSON_Object();
    new Node:b2 = JSON_Object();
    new Node:b3 = JSON_Object();

    JSON_SetString(b1, "bn", "Я ПОНЯЛ");
    JSON_SetInt(b1, "bt", 1);
    JSON_SetInt(b1, "bk", AUTUMN_GUI_CLOSE);

    JSON_SetString(b2, "bn", "ЗАКРЫТЬ");
    JSON_SetInt(b2, "bt", 2);
    JSON_SetInt(b2, "bk", AUTUMN_GUI_CLOSE);

    JSON_SetString(b3, "bn", "ПОЗЖЕ");
    JSON_SetInt(b3, "bt", 3);
    JSON_SetInt(b3, "bk", AUTUMN_GUI_CLOSE);

    new Node:buttons = JSON_Array(b1,b2,b3);
    JSON_SetArray(json, "b", buttons);
    JSON_Cleanup(b1);
    JSON_Cleanup(b2);
    JSON_Cleanup(b3);
    JSON_Cleanup(buttons);

    gAutumnGuiOpen[playerid] = true;
    ShowPlayerGUI(playerid,63,json);
    JSON_Cleanup(json);
    return 1;
}


// Compatibility progress GUI for photon: the donor event referenced a
// garbage-job helper which is not present in this gamemode. Keep the same
// signature and route it through the native mobile progress GUI (31).
stock GarbageSystem_ShowProgressGUI(playerid, start_value, end_value, progress_type, speed, title[])
{
    new Node:json = JSON_Object();
    JSON_SetInt(json, "o", 1);
    JSON_SetInt(json, "t", progress_type);
    JSON_SetInt(json, "s", start_value);
    JSON_SetInt(json, "e", end_value);
    JSON_SetInt(json, "sp", speed);
    JSON_SetString(json, "n", title);
    ShowPlayerGUI(playerid, 31, json);
    JSON_Cleanup(json);
    return 1;
}

forward AutumnEvent_ReapplyProgressAnimation(playerid, kind);
public AutumnEvent_ReapplyProgressAnimation(playerid, kind)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(gAutumnProgressTimer[playerid] == -1) return 0;
    if(gAutumnProgressKind[playerid] != kind) return 0;
    if(IsPlayerInAnyVehicle(playerid)) return 0;

    ApplyAnimationEx(playerid, "BOMBER", "BOM_Plant", 4.1, 1, 0, 0, 0, 0, 1);
    return 1;
}

stock AutumnEvent_StartProgress(playerid, kind, arg, Float:x, Float:y, Float:z, title[])
{
    if(gAutumnProgressTimer[playerid] != -1)
    {
        ShowNotificationNew(playerid, 2, 5, 0, 0,
            "Дождитесь завершения текущего действия.",
            " ");
        return 0;
    }

    if(IsPlayerInAnyVehicle(playerid)) return 0;
    if(!IsPlayerInRangeOfPoint(playerid, 3.8, x,y,z)) return 0;

    gAutumnProgressKind[playerid] = kind;
    gAutumnProgressArg[playerid] = arg;
    gAutumnProgressPos[playerid][0] = x;
    gAutumnProgressPos[playerid][1] = y;
    gAutumnProgressPos[playerid][2] = z;

    ApplyAnimationEx(playerid, "BOMBER", "BOM_Plant", 4.1, 1, 0, 0, 0, 0, 1);
    GarbageSystem_ShowProgressGUI(playerid, 0, 100, 1, 45, title);

    gAutumnProgressTimer[playerid] = SetTimerEx(
        "AutumnEvent_FinishProgress",
        AUTUMN_EVENT_PROGRESS_TIME,
        false,
        "i",
        playerid);

    SetTimerEx("AutumnEvent_ReapplyProgressAnimation", 180, false, "ii", playerid, kind);
    return 1;
}

forward AutumnEvent_FinishProgress(playerid);
public AutumnEvent_FinishProgress(playerid)
{
    if(gAutumnProgressTimer[playerid] != -1)
        gAutumnProgressTimer[playerid] = -1;

    HidePlayerGUI(playerid,31);
    ClearAnimations(playerid);

    if(!IsPlayerConnected(playerid)) return 0;
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;

    if(IsPlayerInAnyVehicle(playerid) ||
       !IsPlayerInRangeOfPoint(playerid, 4.2,
            gAutumnProgressPos[playerid][0],
            gAutumnProgressPos[playerid][1],
            gAutumnProgressPos[playerid][2]))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0,
            "Действие отменено: оставайтесь рядом с целью до заполнения шкалы.",
            " ");
        gAutumnProgressKind[playerid] = AUTUMN_PROGRESS_NONE;
        gAutumnProgressArg[playerid] = -1;
        return 1;
    }

    new kind = gAutumnProgressKind[playerid];
    new arg = gAutumnProgressArg[playerid];
    gAutumnProgressKind[playerid] = AUTUMN_PROGRESS_NONE;
    gAutumnProgressArg[playerid] = -1;

    if(kind == AUTUMN_PROGRESS_NODE)
    {
        if(gAutumnStage[playerid] != AUTUMN_STAGE_CLUES || gAutumnSubStage[playerid] != 0) return 1;
        gAutumnSubStage[playerid] = 1;
        AutumnEvent_SavePlayer(playerid);
        AutumnEvent_SetRoute(playerid);
        ShowNotificationNew(playerid, 3, 7, 0, 0, "На узле обнаружены следы повреждения. Найдите Алису Следопытку - она поможет разобраться.", " ");
        return 1;
    }

    if(kind == AUTUMN_PROGRESS_CLUE)
    {
        if(gAutumnStage[playerid] != AUTUMN_STAGE_CLUES) return 1;
        if(arg < 0 || arg >= AUTUMN_EVENT_CLUES) return 1;
        if(gAutumnClueMask[playerid] & (1 << arg)) return 1;

        gAutumnClueMask[playerid] |= (1 << arg);
        AutumnEvent_SavePlayer(playerid);

        new text[160];
        new found_count =
            ((gAutumnClueMask[playerid] & 1) ? 1 : 0) +
            ((gAutumnClueMask[playerid] & 2) ? 1 : 0) +
            ((gAutumnClueMask[playerid] & 4) ? 1 : 0);
        format(text,sizeof text,
            "\xcd\xe0\xe9\xe4\xe5\xed\xe0\x20\xf3\xeb\xe8\xea\xe0 {FFD429}%d/3{FFFFFF}: %s.",
            found_count, gAutumnClueName[arg]);
        ShowNotificationNew(playerid, 3, 6, 0, 0, text, " ");

        if(AutumnEvent_GetNextMissingClue(playerid) == -1)
        {
            gAutumnStage[playerid] = AUTUMN_STAGE_MECHANIC;
            gAutumnSubStage[playerid] = 0;
            AutumnEvent_SavePlayer(playerid);
            AutumnEvent_DestroyVehicle(playerid);
            AutumnEvent_SetRoute(playerid);
            ShowNotificationNew(playerid, 3, 8, 0, 0,
                "Все улики собраны. Передайте находки механику Марку.",
                " ");
            AutumnEvent_ShowCaseFile(playerid);
        }
        else AutumnEvent_SetRoute(playerid);

        return 1;
    }

    if(kind == AUTUMN_PROGRESS_FINALPOINT)
    {
        if(gAutumnStage[playerid] != AUTUMN_STAGE_FINAL || gAutumnSubStage[playerid] != 1) return 1;
        gAutumnSubStage[playerid] = 2;
        AutumnEvent_SavePlayer(playerid);
        AutumnEvent_SetRoute(playerid);
        ShowNotificationNew(playerid, 3, 8, 0, 0,
            "В тайнике найдены старые документы и журнал маршрутов. Передайте материалы следователю Ловцовой.", " ");
        return 1;
    }

    if(kind == AUTUMN_PROGRESS_MECHANIC)
    {
        if(gAutumnStage[playerid] != AUTUMN_STAGE_MECHANIC) return 1;

        gAutumnStage[playerid] = AUTUMN_STAGE_HUNTER;
        gAutumnSubStage[playerid] = 0;
        AutumnEvent_SavePlayer(playerid);
        AutumnEvent_GiveStageVehicle(playerid, 0);
        AutumnEvent_SetRoute(playerid);
        AutumnEvent_GiveStageReward(playerid, 1, "Осенний ивент: анализ детали");
        return 1;
    }

    if(kind == AUTUMN_PROGRESS_TERMINAL_REPAIR)
    {
        if(gAutumnStage[playerid] != AUTUMN_STAGE_TERMINAL || gAutumnSubStage[playerid] != 0) return 1;

        gAutumnSubStage[playerid] = 1;
        AutumnEvent_SavePlayer(playerid);
        AutumnEvent_SetRoute(playerid);
        ShowNotificationNew(playerid, 3, 6, 0, 0,
            "Повреждённая цепь восстановлена. Индикатор аварийного питания загорелся.",
            " ");
        return 1;
    }

    if(kind == AUTUMN_PROGRESS_TERMINAL_BOOT)
    {
        if(gAutumnStage[playerid] != AUTUMN_STAGE_TERMINAL || gAutumnSubStage[playerid] != 1) return 1;

        gAutumnStage[playerid] = AUTUMN_STAGE_FINAL;
        gAutumnSubStage[playerid] = 0;
        AutumnEvent_SavePlayer(playerid);
        AutumnEvent_GiveStageVehicle(playerid, 2);
        AutumnEvent_SetRoute(playerid);
        AutumnEvent_GiveStageReward(playerid, 3, "Осенний ивент: восстановление ретранслятора");
        return 1;
    }

    return 1;
}

stock AutumnEvent_GiveFinalReward(playerid)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;
    if(gAutumnStage[playerid] != AUTUMN_STAGE_FINAL || gAutumnSubStage[playerid] < 2) return 0;

    if(gAutumnRewardReceived[playerid])
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0,
            "\xd4\xe8\xed\xe0\xeb\xfc\xed\xe0\xff\x20\xed\xe0\xe3\xf0\xe0\xe4\xe0\x20\xf3\xe6\xe5\x20\xe1\xfb\xeb\xe0\x20\xef\xee\xeb\xf3\xf7\xe5\xed\xe0\x2e",
            " ");
        return 0;
    }

    gAutumnRewardReceived[playerid] = true;
    gAutumnCompleted[playerid] = true;
    gAutumnStage[playerid] = AUTUMN_STAGE_COMPLETED;
    gAutumnSubStage[playerid] = 0;
    gAutumnAdminTestMode[playerid] = false;

    GivePlayerMoneyEx(playerid, AUTUMN_EVENT_FINAL_MONEY,
        "\xce\xf1\xe5\xed\xed\xe8\xe9\x20\xe8\xe2\xe5\xed\xf2\x3a\x20\xf4\xe8\xed\xe0\xeb\xfc\xed\xe0\xff\x20\xed\xe0\xe3\xf0\xe0\xe4\xe0", true, true);
    GivePlayerDonateRub(playerid, AUTUMN_EVENT_FINAL_BC,
        "\xce\xf1\xe5\xed\xed\xe8\xe9\x20\xe8\xe2\xe5\xed\xf2\x3a\x20\xf4\xe8\xed\xe0\xeb\xfc\xed\xe0\xff\x20\xed\xe0\xe3\xf0\xe0\xe4\xe0", true, true);

    AddPlayerData(playerid, P_EXP, +, AUTUMN_EVENT_FINAL_EXP);
    UpdatePlayerDatabaseInt(playerid, "exp", GetPlayerData(playerid, P_EXP));

    AutumnEvent_SavePlayer(playerid);
    AutumnEvent_DestroyVehicle(playerid);
    AutumnEvent_ClearRoute(playerid);
    AutumnEvent_CloseGui(playerid);

    if(gAutumnRewardCarPoint[0] != 0.0 || gAutumnRewardCarPoint[1] != 0.0)
        AutumnEvent_GiveStageVehicle(playerid, 3);

    new title[96];
    format(title, sizeof title, "{E0584B}\xc7\xce\xcb\xce\xd2\xce\xc9\x20\xd1\xcb\xc5\xc4{FFFFFF} | \xd4\xc8\xcd\xc0\xcb\xdc\xcd\xc0\xdf\x20\xcd\xc0\xc3\xd0\xc0\xc4\xc0");

    new text[960];
    format(text, sizeof text,
        "{FFFFFF}\xcf\xee\xe7\xe4\xf0\xe0\xe2\xeb\xff\xe5\xec\x21\n"        "{FFFFFF}\xc2\xfb\x20\xf3\xf1\xef\xe5\xf8\xed\xee\x20\xe7\xe0\xe2\xe5\xf0\xf8\xe8\xeb\xe8\x20\xee\xf1\xe5\xed\xed\xe8\xe9\x20\xe8\xe2\xe5\xed\xf2\x2e\n\n"        "{FFFFFF}\xd0\xe0\xf1\xf1\xeb\xe5\xe4\xee\xe2\xe0\xed\xe8\xe5\x20\xe7\xe0\xe2\xe5\xf0\xf8\xe5\xed\xee\x2c\x20\xe4\xee\xea\xf3\xec\xe5\xed\xf2\xfb\x20\xef\xe5\xf0\xe5\xe4\xe0\xed\xfb\x20\xf1\xeb\xe5\xe4\xee\xe2\xe0\xf2\xe5\xeb\xfe\x2c\x20\xe0\x20\xf2\xe0\xe9\xed\xe0\x20\xf1\xf2\xe0\xf0\xee\xe3\xee\x20\xf2\xf0\xe0\xea\xf2\xe0\x20\xf0\xe0\xf1\xea\xf0\xfb\xf2\xe0\x2e\n\n"        "{FFFFFF}\xc2\xfb\x20\xef\xee\xeb\xf3\xf7\xe8\xeb\xe8\x20\xed\xe0\xe3\xf0\xe0\xe4\xfb\x3a\n"        "{E0584B}1. {FFE066}15 000 000 \xf0\xf3\xe1\x2e{FFFFFF}\n"        "{E0584B}2. {FFE066}15 000 BC{FFFFFF}\n"        "{E0584B}3. {FFE066}15 EXP{FFFFFF}\n\n"        "{FFFFFF}\xcf\xf0\xe8\xff\xf2\xed\xee\xe9\x20\xe8\xe3\xf0\xfb\x20\xed\xe0\x20{FFE066}\x53\x41\x4d\x45\x20\x52\x55\x53\x53\x49\x41{FFFFFF}");

    ShowPlayerDialog(playerid, DIALOG_AUTUMN_FINAL_REWARD, DIALOG_STYLE_MSGBOX,
        title, text, "\xd5\xee\xf0\xee\xf8\xee", "");

    return 1;
}

stock AutumnEvent_HandleDialog(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused listitem
    #pragma unused inputtext

    switch(dialogid)
    {
        case DIALOG_AUTUMN_STAGE_REWARD, DIALOG_AUTUMN_FINAL_REWARD, DIALOG_AUTUMN_CASE_FILE:
        {
            if(!response)
                ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, " ", " ", " ", "");
            return 1;
        }
    }
    return 0;
}

stock AutumnEvent_HandleNpcPacket(playerid, Node:json)
{
    if(!gAutumnGuiOpen[playerid]) return 0;

    new click = -1;
    // Different client builds use either bk or b for the pressed button.
    JSON_GetInt(json, "bk", click);
    if(click == -1) JSON_GetInt(json, "b", click);

    // Native close packet: t=1,c=1.
    new packet_type = 0;
    JSON_GetInt(json, "t", packet_type);
    if(packet_type == 1)
    {
        new close_flag = 0;
        JSON_GetInt(json, "c", close_flag);
        if(close_flag == 1)
        {
            AutumnEvent_CloseGui(playerid);
            return 1;
        }
    }

    if(click == -1) return 0;

    switch(click)
    {
        case AUTUMN_GUI_CLOSE, AUTUMN_GUI_REWARD_CLOSE:
        {
            AutumnEvent_CloseGui(playerid);
            return 1;
        }
        case AUTUMN_GUI_INTRO_ROUTE:
        {
            AutumnEvent_CloseGui(playerid);
            new npc = AutumnEvent_FindNpcByRole(AUTUMN_ROLE_FORESTER);
            if(npc != -1)
                AutumnEvent_SetPointRoute(playerid, gAutumnNpcPos[npc][0], gAutumnNpcPos[npc][1], gAutumnNpcPos[npc][2], 4.0, "Лесник Григорий отмечен на GPS.");
            return 1;
        }
        case AUTUMN_GUI_START:
        {
            AutumnEvent_CloseGui(playerid);
            return AutumnEvent_Start(playerid);
        }
        case AUTUMN_GUI_ABOUT:
        {
            return AutumnEvent_ShowAbout(playerid);
        }
        case AUTUMN_GUI_REFRESH_ROUTE:
        {
            AutumnEvent_CloseGui(playerid);
            AutumnEvent_SetRoute(playerid);
            ShowNotificationNew(playerid, 4, 5, 0, 0,
                "Текущая цель 'Золотого следа' обновлена на GPS.",
                " ");
            return 1;
        }
        case AUTUMN_GUI_ALICE_CONTINUE:
        {
            if(gAutumnStage[playerid] != AUTUMN_STAGE_CLUES || gAutumnSubStage[playerid] != 1) return 1;
            AutumnEvent_CloseGui(playerid);
            gAutumnSubStage[playerid] = 2;
            AutumnEvent_SavePlayer(playerid);
            AutumnEvent_SetRoute(playerid);
            ShowNotificationNew(playerid, 3, 7, 0, 0, "Алиса рассказала, где видела следы машины. Остальное придётся проверить самостоятельно.", " ");
            return 1;
        }
        case AUTUMN_GUI_MECHANIC_INSPECT:
        {
            if(gAutumnStage[playerid] != AUTUMN_STAGE_MECHANIC) return 1;
            new npc = gAutumnCurrentNpc[playerid];
            AutumnEvent_CloseGui(playerid);
            if(npc < 0 || npc >= gAutumnNpcCount) return 1;
            return AutumnEvent_StartProgress(playerid,
                AUTUMN_PROGRESS_MECHANIC,
                0,
                gAutumnNpcPos[npc][0],
                gAutumnNpcPos[npc][1],
                gAutumnNpcPos[npc][2],
                "Марк сверяет маркировку и повреждения...");
        }
        case AUTUMN_GUI_HUNTER_START:
        {
            if(gAutumnStage[playerid] != AUTUMN_STAGE_HUNTER) return 1;
            AutumnEvent_CloseGui(playerid);
            gAutumnStage[playerid] = AUTUMN_STAGE_DELIVERY;
            gAutumnSubStage[playerid] = 0;
            AutumnEvent_SavePlayer(playerid);
            AutumnEvent_GiveStageVehicle(playerid, 1);
            AutumnEvent_SetRoute(playerid);
            ShowNotificationNew(playerid, 3, 8, 0, 0,
                "Филиппыч передал старые накладные и ключи от транспорта.",
                " ");
            return 1;
        }
        case AUTUMN_GUI_HOST_CONTINUE:
        {
            if(gAutumnStage[playerid] != AUTUMN_STAGE_FINAL || gAutumnSubStage[playerid] != 0) return 1;
            AutumnEvent_CloseGui(playerid);
            if(gAutumnFinalPoint[0] != 0.0 || gAutumnFinalPoint[1] != 0.0)
                gAutumnSubStage[playerid] = 1;
            else
                gAutumnSubStage[playerid] = 2;
            AutumnEvent_SavePlayer(playerid);
            AutumnEvent_SetRoute(playerid);
            ShowNotificationNew(playerid, 3, 7, 0, 0,
                (gAutumnSubStage[playerid] == 1) ? "Хозяин таверны отметил последний тайник на GPS." : "Точка тайника ещё не расставлена. Следователь Ловцова отмечена на GPS.",
                " ");
            return 1;
        }
        case AUTUMN_GUI_FINAL_REWARD:
        {
            if(gAutumnCurrentNpc[playerid] < 0 || gAutumnCurrentNpc[playerid] >= gAutumnNpcCount || gAutumnNpcRole[gAutumnCurrentNpc[playerid]] != AUTUMN_ROLE_FINAL)
                return 1;
            return AutumnEvent_GiveFinalReward(playerid);
        }
    }
    return 0;
}

stock AutumnEvent_HandleInteraction(playerid)
{
    if(IsPlayerInAnyVehicle(playerid)) return 0;

    // Mobile clients may send the interaction twice on a fast tap. Debounce it
    // so a dialog/progress action can never be started twice in the same moment.
    new now_tick = GetTickCount();
    if(gAutumnLastInteractionTick[playerid] != 0 &&
       now_tick - gAutumnLastInteractionTick[playerid] < 750)
        return 1;
    gAutumnLastInteractionTick[playerid] = now_tick;

    new starter = AutumnEvent_FindNearestStartNpc(playerid);
    if(starter != -1)
    {
        AutumnEvent_EnsureLoaded(playerid);
        return AutumnEvent_ShowStartGui(playerid,starter);
    }

    if(AutumnEvent_IsNearNode(playerid))
        return AutumnEvent_StartProgress(playerid, AUTUMN_PROGRESS_NODE, 0, gAutumnNodePos[0], gAutumnNodePos[1], gAutumnNodePos[2], "Проверяем повреждённый узел связи...");

    new npc = AutumnEvent_FindNearestNpc(playerid);
    if(npc != -1)
    {
        AutumnEvent_EnsureLoaded(playerid);
        AutumnEvent_ShowNpcGui(playerid,npc,0);
        return 1;
    }

    new clue = AutumnEvent_GetNearbyClue(playerid);
    if(clue != -1)
    {
        return AutumnEvent_StartProgress(playerid,
            AUTUMN_PROGRESS_CLUE,
            clue,
            gAutumnCluePos[clue][0],
            gAutumnCluePos[clue][1],
            gAutumnCluePos[clue][2],
            "Осматриваем место и собираем улику...");
    }

    if(gAutumnStage[playerid] == AUTUMN_STAGE_DELIVERY &&
       gAutumnSubStage[playerid] >= 0 && gAutumnSubStage[playerid] < AUTUMN_EVENT_DELIVERY_POINTS &&
       IsPlayerInRangeOfPoint(playerid, 4.5,
           gAutumnDeliveryPos[gAutumnSubStage[playerid]][0],
           gAutumnDeliveryPos[gAutumnSubStage[playerid]][1],
           gAutumnDeliveryPos[gAutumnSubStage[playerid]][2]))
        return AutumnEvent_OnCheckpoint(playerid);

    if(AutumnEvent_IsNearTerminal(playerid))
    {
        if(gAutumnSubStage[playerid] == 0)
            return AutumnEvent_StartProgress(playerid,
                AUTUMN_PROGRESS_TERMINAL_REPAIR,
                0,
                gAutumnTerminalPos[0],
                gAutumnTerminalPos[1],
                gAutumnTerminalPos[2],
                "Восстанавливаем повреждённую цепь ретранслятора...");

        if(gAutumnSubStage[playerid] == 1)
            return AutumnEvent_StartProgress(playerid,
                AUTUMN_PROGRESS_TERMINAL_BOOT,
                0,
                gAutumnTerminalPos[0],
                gAutumnTerminalPos[1],
                gAutumnTerminalPos[2],
                "Запускаем питание и выполняем диагностику...");
    }

    if(AutumnEvent_IsNearFinalPoint(playerid))
        return AutumnEvent_StartProgress(playerid, AUTUMN_PROGRESS_FINALPOINT, 0,
            gAutumnFinalPoint[0], gAutumnFinalPoint[1], gAutumnFinalPoint[2],
            "Осматриваем тайник и забираем документы...");

    return 0;
}

public AutumnEvent_ProximityTick()
{
    for(new playerid; playerid < MAX_PLAYERS; playerid++)
    {
        if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) continue;

        // Delivery fail-safe for mobile clients: the player parks the issued quest vehicle
        // nearby, gets out and finishes the hand-off on foot at the 3D marker.
        if(gAutumnStage[playerid] == AUTUMN_STAGE_DELIVERY && !IsPlayerInAnyVehicle(playerid))
        {
            new delivery_point = gAutumnSubStage[playerid];
            if(delivery_point >= 0 && delivery_point < AUTUMN_EVENT_DELIVERY_POINTS &&
               IsPlayerInRangeOfPoint(playerid, 4.5,
                   gAutumnDeliveryPos[delivery_point][0],
                   gAutumnDeliveryPos[delivery_point][1],
                   gAutumnDeliveryPos[delivery_point][2]))
            {
                AutumnEvent_OnCheckpoint(playerid);
            }
        }

        new bool:nearEvent = false;

        if(!IsPlayerInAnyVehicle(playerid))
        {
            if(AutumnEvent_FindNearestStartNpc(playerid) != -1)
                nearEvent = true;
            else if(AutumnEvent_IsNearNode(playerid))
                nearEvent = true;
            else if(AutumnEvent_FindNearestNpc(playerid) != -1)
                nearEvent = true;
            else if(AutumnEvent_GetNearbyClue(playerid) != -1)
                nearEvent = true;
            else if(gAutumnStage[playerid] == AUTUMN_STAGE_DELIVERY &&
                    gAutumnSubStage[playerid] >= 0 && gAutumnSubStage[playerid] < AUTUMN_EVENT_DELIVERY_POINTS &&
                    IsPlayerInRangeOfPoint(playerid, 4.5,
                        gAutumnDeliveryPos[gAutumnSubStage[playerid]][0],
                        gAutumnDeliveryPos[gAutumnSubStage[playerid]][1],
                        gAutumnDeliveryPos[gAutumnSubStage[playerid]][2]))
                nearEvent = true;
            else if(AutumnEvent_IsNearTerminal(playerid))
                nearEvent = true;
            else if(AutumnEvent_IsNearFinalPoint(playerid))
                nearEvent = true;
        }

        if(nearEvent && !gAutumnInteractionVisible[playerid])
        {
            ToggleInteractionWindow(playerid, true);
            gAutumnInteractionVisible[playerid] = true;
        }
        else if(!nearEvent && gAutumnInteractionVisible[playerid])
        {
            ToggleInteractionWindow(playerid, false);
            gAutumnInteractionVisible[playerid] = false;
        }
    }
    return 1;
}

stock AutumnEvent_OnCheckpoint(playerid)
{
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;
    if(gAutumnStage[playerid] != AUTUMN_STAGE_DELIVERY) return 0;

    new point = gAutumnSubStage[playerid];
    if(point < 0 || point >= AUTUMN_EVENT_DELIVERY_POINTS) return 0;

    if(!IsPlayerInRangeOfPoint(playerid, 7.0,
        gAutumnDeliveryPos[point][0],
        gAutumnDeliveryPos[point][1],
        gAutumnDeliveryPos[point][2]))
        return 0;

    if(IsPlayerInAnyVehicle(playerid))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0,
            "Припаркуйте квестовую машину рядом, выйдите из неё и подойдите к точке передачи пешком.",
            " ");
        return 1;
    }

    // The cargo vehicle must still exist and be parked nearby, but the actual hand-off is on foot.
    if(gAutumnEventVehicle[playerid] == INVALID_VEHICLE_ID ||
       !IsValidVehicle(gAutumnEventVehicle[playerid]))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0,
            "Квестовая машина не найдена. Вернитесь к Охотнику и обновите маршрут, чтобы получить транспорт.",
            " ");
        return 1;
    }

    new Float:veh_x, Float:veh_y, Float:veh_z;
    GetVehiclePos(gAutumnEventVehicle[playerid], veh_x, veh_y, veh_z);
    if(VectorSize(veh_x - gAutumnDeliveryPos[point][0],
                  veh_y - gAutumnDeliveryPos[point][1],
                  veh_z - gAutumnDeliveryPos[point][2]) > 80.0)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0,
            "Сначала подгоните квестовую машину ближе к месту доставки, припаркуйтесь и подойдите сюда пешком.",
            " ");
        return 1;
    }

    gAutumnSubStage[playerid]++;

    if(gAutumnSubStage[playerid] < AUTUMN_EVENT_DELIVERY_POINTS)
    {
        AutumnEvent_SavePlayer(playerid);
        AutumnEvent_SetRoute(playerid);

        new text[128];
        format(text,sizeof text,
            "Одна из записей в накладной подтверждена: %d/3.",
            gAutumnSubStage[playerid]);
        ShowNotificationNew(playerid, 3, 6, 0, 0, text, " ");
        return 1;
    }

    gAutumnStage[playerid] = AUTUMN_STAGE_TERMINAL;
    gAutumnSubStage[playerid] = 0;
    AutumnEvent_SavePlayer(playerid);
    AutumnEvent_DestroyVehicle(playerid);
    AutumnEvent_SetRoute(playerid);
    AutumnEvent_GiveStageReward(playerid, 2, "Осенний ивент: доставка припасов");
    return 1;
}

forward AutumnEvent_RestoreAfterSpawn(playerid);
public AutumnEvent_RestoreAfterSpawn(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(!gAutumnEventEnabled) return 0;
    if(!AutumnEvent_EnsureLoaded(playerid)) return 0;

    if(gAutumnStage[playerid] <= AUTUMN_STAGE_NOT_STARTED ||
       gAutumnStage[playerid] >= AUTUMN_STAGE_COMPLETED)
        return 1;

    // Temporary event transport is not persistent by design. Recreate the
    // correct stage vehicle after reconnect/death so the quest cannot deadlock.
    if(gAutumnEventVehicle[playerid] == INVALID_VEHICLE_ID ||
       !IsValidVehicle(gAutumnEventVehicle[playerid]))
    {
        switch(gAutumnStage[playerid])
        {
            case AUTUMN_STAGE_HUNTER:
                AutumnEvent_GiveStageVehicle(playerid, 0);
            case AUTUMN_STAGE_DELIVERY:
                AutumnEvent_GiveStageVehicle(playerid, 1);
            case AUTUMN_STAGE_FINAL:
            {
                if(gAutumnSubStage[playerid] < 2)
                    AutumnEvent_GiveStageVehicle(playerid, 2);
            }
        }
    }

    AutumnEvent_SetRoute(playerid);
    return 1;
}

stock AutumnEvent_OnSpawn(playerid)
{
    SetTimerEx("AutumnEvent_RestoreAfterSpawn", 1800, false, "i", playerid);
    return 1;
}

stock AutumnEvent_OnDeath(playerid)
{
    if(gAutumnProgressTimer[playerid] != -1)
    {
        KillTimer(gAutumnProgressTimer[playerid]);
        gAutumnProgressTimer[playerid] = -1;
        gAutumnProgressKind[playerid] = AUTUMN_PROGRESS_NONE;
        gAutumnProgressArg[playerid] = -1;
        HidePlayerGUI(playerid,31);
        ClearAnimations(playerid);
    }

    if(gAutumnGuiOpen[playerid])
        AutumnEvent_CloseGui(playerid);

    AutumnEvent_DestroyVehicle(playerid);

    if(gAutumnInteractionVisible[playerid])
    {
        ToggleInteractionWindow(playerid,false);
        gAutumnInteractionVisible[playerid] = false;
    }

    return 1;
}

stock AutumnEvent_OnDisconnect(playerid)
{
    if(GetPlayerAccountID(playerid) > 0)
        AutumnEvent_SavePlayer(playerid);

    if(gAutumnProgressTimer[playerid] != -1)
    {
        KillTimer(gAutumnProgressTimer[playerid]);
        gAutumnProgressTimer[playerid] = -1;
    }

    AutumnEvent_DestroyVehicle(playerid);
    AutumnEvent_ResetPlayer(playerid);
    return 1;
}

stock AutumnEvent_GetStageText(playerid, dest[], size)
{
    AutumnEvent_EnsureLoaded(playerid);

    switch(gAutumnStage[playerid])
    {
        case AUTUMN_STAGE_NOT_STARTED: format(dest,size,"Квест не начат");
        case AUTUMN_STAGE_CLUES: format(dest,size,"Поиск осенних улик (%d/3)",
            ((gAutumnClueMask[playerid] & 1) ? 1 : 0) +
            ((gAutumnClueMask[playerid] & 2) ? 1 : 0) +
            ((gAutumnClueMask[playerid] & 4) ? 1 : 0));
        case AUTUMN_STAGE_ALICE: format(dest,size,"Разговор с Алисой Следопыткой");
        case AUTUMN_STAGE_MECHANIC: format(dest,size,"Проверка детали у механика Марка");
        case AUTUMN_STAGE_HUNTER: format(dest,size,"Встреча с охотником Филиппычем");
        case AUTUMN_STAGE_DELIVERY: format(dest,size,"Доставка припасов (%d/3)",gAutumnSubStage[playerid]);
        case AUTUMN_STAGE_TERMINAL: format(dest,size,"Восстановление старого ретранслятора");
        case AUTUMN_STAGE_FINAL:
        {
            if(gAutumnSubStage[playerid] == 0) format(dest,size,"Встреча с Хозяином таверны");
            else if(gAutumnSubStage[playerid] == 1) format(dest,size,"Осмотр последнего тайника");
            else format(dest,size,"Передать доказательства Следователю Ловцовой");
        }
        case AUTUMN_STAGE_COMPLETED: format(dest,size,"Квестовая линия завершена");
        default: format(dest,size,"Неизвестный этап");
    }
    return 1;
}

// ============================================================================
// Admin NPC management
// ============================================================================

// Admin/debug NPC placement commands were intentionally removed.
// NPCs are placed automatically by AutumnEvent_LoadNpcs().

// ============================================================================
// End Autumn Event
// ============================================================================
