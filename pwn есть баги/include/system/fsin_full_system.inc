// ============================================================================
// SIME RUSSIA — FSIN FULL SYSTEM EXPORT
// Extracted/assembled from SIME_RUSSIA_MECHANIC_CENTER_V5_ACTIONS_FULL_FINAL
// Encoding of fsin_full_system.inc: Windows-1251 (CP1251)
//
// Scope:
// - TEAM_FSIN runtime module (team id 11)
// - full exterior FSIN scene found in source (8 objects)
// - 2 controlled gates + horn/Y/notification interaction + autoclose
// - FSIN HR actor + requirements + 6 RP questions + rank 1 recruitment
// - wardrobe / workday / uniform switching
// - 6-car FSIN fleet, rank limits, exact 2 parking slots, vinyls, RU plates 52,
//   siren, stroboscope and tint
// - armory with original 9 items/cooldowns
// - lazaret/camera/sawmill portal pickups
// - FSIN jail storage/helpers/tick hooks
// - original visual NPC "Igla" and common-stash label present in FSIN scene
//
// IMPORTANT: the donor SIME base owns account/org enums and vehicle wrappers.
// Apply integration/BASE_PATCHES_SIME_RUSSIA.pwn and callback hooks once.
// ============================================================================

#if defined _SIME_FSIN_FULL_SYSTEM_INCLUDED
    #endinput
#endif
#define _SIME_FSIN_FULL_SYSTEM_INCLUDED

#define FSIN_FULL_TEAM_ID             (11)
#define FSIN_FULL_HR_MIN_LEVEL        (3)
#define FSIN_FULL_HR_MAX_ERRORS       (2)
#define FSIN_FULL_HR_RETRY_SECONDS    (180)
#define FSIN_FULL_HR_NOTIFY_ID        (9321)
#define FSIN_FULL_GATE_NOTIFY_ID      (9322)
#define FSIN_FULL_FLEET_COUNT         (6)
#define FSIN_FULL_NUMBER_REGION       "52"
#define FSIN_FULL_SAWMILL_COUNT       (10)
#define FSIN_FULL_SAWMILL_BOARDS      (6)
#define FSIN_FULL_SAWMILL_REWARD      (200)
#define FSIN_FULL_SAWMILL_TIME_REWARD (30)

#define DIALOG_FSIN_FULL_HR_INFO      (30410)
#define DIALOG_FSIN_FULL_HR_Q1        (30411)
#define DIALOG_FSIN_FULL_HR_Q2        (30412)
#define DIALOG_FSIN_FULL_HR_Q3        (30413)
#define DIALOG_FSIN_FULL_HR_Q4        (30414)
#define DIALOG_FSIN_FULL_HR_Q5        (30415)
#define DIALOG_FSIN_FULL_HR_Q6        (30416)
#define DIALOG_FSIN_FULL_HR_RESULT    (30417)
#define DIALOG_FSIN_FULL_FLEET        (30430)
#define DIALOG_FSIN_FULL_WORK_START   (30431)
#define DIALOG_FSIN_FULL_WORK_END     (30432)
#define DIALOG_FSIN_FULL_ARMORY       (30433)

forward ShowNotificationNew(playerid, type, duration, id, subId, caption[], btnCaption[]);

stock FsinFull_ShowSimpleNotification(playerid,const message[])
{
    return SendClientMessage(playerid,0xCECECEFF,message);
}

// Organization data copied from the donor base. The main organization table must
// still contain the FSIN row from BASE_PATCHES_SIME_RUSSIA.pwn.
new const g_FsinFullMaleSkins[10] = {32,4,26,26,26,26,26,26,26,26};
#define FSIN_FULL_WOMAN_SKIN (64)
new const Float:g_FsinFullSpawn[4] = {-1876.63,-2727.15,8.58,227.22};
new const g_FsinFullRankNames[10][60] =
{
    "Рядовой", "Ефрейтор", "Сержант", "Старшина", "Прапорщик",
    "Лейтенант", "Капитан", "Майор", "Подполковник", "Полковник"
};
new const g_FsinFullRankWages[10] = {1950,2540,4500,5700,6325,7950,8700,10550,12000,16000};

// Current FSIN fleet — exact six-car configuration from fraction_gui_adapter.pwn.
new const g_FsinFullFleetModels[FSIN_FULL_FLEET_COUNT] =
{
    456, 413, 2555, 2547, 28664, 2562
};
new const g_FsinFullFleetMinRank[FSIN_FULL_FLEET_COUNT] =
{
    1, 2, 3, 8, 9, 5
};
new const g_FsinFullFleetNames[FSIN_FULL_FLEET_COUNT][48] =
{
    "Автозак",
    "ГАЗ 3221",
    "Гранта",
    "LC 200",
    "Hyundai Grandeur",
    "UAZ Patriot"
};
new const g_FsinFullFleetVinyls[FSIN_FULL_FLEET_COUNT][32] =
{
    "remapfbody29",
    "remapfbody28",
    "remapfbody28",
    "remapfbody28",
    "remapfbody29",
    "remapfbody28"
};
new const Float:g_FsinFullFleetParking[2][4] =
{
    {-1849.768554,-2775.762207,6.923953,184.878997},
    {-1859.290893,-2768.127685,6.929805,184.878997}
};

new const Float:g_FsinFullJailPositions[4][4] =
{
    {-1699.121582,-2702.468261,1499.500000,180.0},
    {-1699.900756,-2700.589355,1499.500000,180.0},
    {-1698.703979,-2698.262695,1499.500000,180.0},
    {-1697.900000,-2701.500000,1499.500000,180.0}
};

new g_FsinFullGateKpp1 = -1;
new g_FsinFullGateKpp2 = -1;
new g_FsinFullGateInner = -1;
new g_FsinFullGateStatic = -1;
new g_FsinFullGateArea[2] = {-1,-1};
new bool:g_FsinFullGateOpen[2];
new g_FsinFullGateCloseTimer[2] = {-1,-1};

new g_FsinFullHrActor = -1;
new g_FsinFullIglaActor = -1;
new g_FsinFullHrHint[MAX_PLAYERS];

new g_FsinFullWardrobePickup = -1;
new g_FsinFullFleetPickup = -1;
new g_FsinFullArmoryPickup = -1;
new g_FsinFullEntrancePickup = -1;
new g_FsinFullExitPickup = -1;
new g_FsinFullBedArea[4] = {-1,...};
new g_FsinFullLazaretIn = -1;
new g_FsinFullLazaretOut = -1;
new g_FsinFullCameraIn = -1;
new g_FsinFullCameraOut = -1;
new g_FsinFullSawmillIn = -1;
new g_FsinFullSawmillOut = -1;
new const Float:g_FsinFullSawmillPos[FSIN_FULL_SAWMILL_COUNT][4] =
{
    {-1901.070800,-2597.180175,1501.040039,2.086538}, {-1898.064697,-2594.016845,1501.040039,351.237060},
    {-1904.850708,-2593.897949,1501.040039,2.610430}, {-1904.083251,-2600.031982,1501.040039,359.043304},
    {-1907.864868,-2597.151367,1501.040039,355.212921}, {-1910.035156,-2601.674316,1501.040039,9.400522},
    {-1913.193481,-2598.299804,1501.040039,4.191907}, {-1911.217285,-2593.904541,1501.040039,355.832550},
    {-1916.375122,-2594.287841,1501.040039,356.896240}, {-1917.415893,-2600.928466,1501.040039,4.236432}
};
new Text3D:g_FsinFullSawmillLabel[FSIN_FULL_SAWMILL_COUNT];
new g_FsinFullSawmillArea[FSIN_FULL_SAWMILL_COUNT];
new g_FsinFullSawmillUser[FSIN_FULL_SAWMILL_COUNT];
new g_FsinFullSawmillStation[MAX_PLAYERS];
new g_FsinFullSawmillDone[MAX_PLAYERS];
new PlayerText:g_FsinFullSawmillTD[MAX_PLAYERS][FSIN_FULL_SAWMILL_BOARDS + 4];
new bool:g_FsinFullSawmillTDReady[MAX_PLAYERS];

// --------------------------------------------------------------------------
// Initialization / scene
// --------------------------------------------------------------------------
stock FsinFull_CreateScene()
{
    CreateDynamic3DTextLabel("{FF5252}«\t{ffffff}Ворота ФCИН\t{FF5252}»\n{ffffff}Заезжайте для открытия{FF5252}", 0xFF5252FF, -1823.55,-2633.54,10.38, 15.0);
    CreateDynamic3DTextLabel("{FF5252}«\t{ffffff}Ворота ФCИН\t{FF5252}»\n{ffffff}Заезжайте для открытия{FF5252}", 0xFF5252FF, -1820.60,-2650.97,12.70, 10.0);

    g_FsinFullGateArea[0] = CreateDynamicSphere(-1823.66,-2633.54,8.58,10.0);
    g_FsinFullGateArea[1] = CreateDynamicSphere(-1820.49,-2651.36,10.90,15.0);

    g_FsinFullGateKpp1 = CreateObject(11611,-1827.21,-2634.129,8.58,0.0,0.0,99.4);
    g_FsinFullGateKpp2 = CreateObject(11612,-1820.11,-2632.95,8.58,0.0,0.0,-80.5);
    g_FsinFullGateInner = CreateObject(11615,-1820.49,-2651.36,10.9,0.0,0.0,99.5);
    g_FsinFullGateStatic = CreateObject(11614,-1778.2,-2709.2,10.9,0.0,0.0,142.0);

    // All four boundary objects found inside the FSIN exterior bbox in the donor.
    CreateObject(11781,-1776.81,-2731.33,7.5,0.0,0.0,233.0);
    CreateObject(11781,-1764.28,-2795.48,7.5,0.0,0.0,233.0);
    CreateObject(11781,-1683.55,-2812.77,7.5,0.0,0.0,51.0);
    CreateObject(11781,-1681.68,-2737.23,7.5,0.0,0.0,143.0);

    // Visible FSIN lazaret shell. The supplied coordinates are a custom interior,
    // so the room must be streamed explicitly in virtual world 6 / interior 1.
    CreateDynamicObject(19379,-2004.500000,-1492.000000,1750.850000,0.0,90.0,0.0,6,1);
    CreateDynamicObject(19379,-2004.500000,-1501.500000,1750.850000,0.0,90.0,0.0,6,1);
    CreateDynamicObject(19379,-2009.350000,-1492.000000,1753.250000,0.0,0.0,0.0,6,1);
    CreateDynamicObject(19379,-1999.650000,-1492.000000,1753.250000,0.0,0.0,0.0,6,1);
    CreateDynamicObject(19379,-2004.500000,-1486.750000,1753.250000,0.0,0.0,90.0,6,1);
    CreateDynamicObject(19379,-2004.500000,-1506.250000,1753.250000,0.0,0.0,90.0,6,1);
    CreateDynamicObject(19379,-2004.500000,-1492.000000,1755.650000,0.0,90.0,0.0,6,1);
    CreateDynamicObject(1800,-2005.465087,-1493.152709,1751.000000,0.0,0.0,50.449573,6,1);
    CreateDynamicObject(1800,-2005.371337,-1490.781982,1751.000000,0.0,0.0,327.187438,6,1);
    CreateDynamicObject(1800,-2005.318237,-1488.515625,1751.000000,0.0,0.0,86.815521,6,1);
    CreateDynamicObject(1800,-2001.401367,-1493.826416,1751.000000,0.0,0.0,265.736175,6,1);
    CreateDynamic3DTextLabel("{66CCFF}Лазарет ФСИН\n{FFFFFF}Подойдите к койке для лечения",0xFFFFFFFF,-2004.620239,-1492.151245,1752.200000,15.0,6,1);
    g_FsinFullHrActor = CreateActor(81,-1817.008300,-2631.807617,7.590855,2.969990);
    Create3DTextLabel("{ffff00}« Отдел кадров ФСИН »\n{ffffff}Подойдите для взаимодействия", -1, -1817.008300,-2631.807617,7.590855, 15.0, 0);

    // Visual NPC/label present in the donor FSIN scene. No separate interaction
    // implementation for this actor was found in the source, so it is preserved as-is.
    g_FsinFullIglaActor = CreateActor(57,-1721.147827,-2815.024169,7.582671,132.815338);
    Create3DTextLabel("{ffff00}« Игла »\n{ffffff}Подойдите ближе\nдля взоимодействия", -1, -1721.147827,-2815.024169,7.582671, 15.0, 0);
    Create3DTextLabel("{ffff00}Общий тайник\n{ffffff}Подойдите ближе для взоимодействия", -1, -1698.703979,-2698.262695,1499.500000, 15.0, 6);
    return 1;
}

stock FsinFull_CreatePickups()
{
    // Wardrobe / workday.
    g_FsinFullWardrobePickup = CreatePickup(1275,23,-1875.208618,-2722.175048,8.624625,0);
    CreateDynamic3DTextLabel("{FF5252}<<<Раздевалка>>>\n{FFFFFF}Подойдите для взаимодействия", 0x3399FFFF, -1875.208618,-2722.175048,9.424625,10.0);

    // Fleet/autopark.
    g_FsinFullFleetPickup = CreatePickup(19131,23,-1857.56,-2776.02,7.58,0);
    CreateDynamic3DTextLabel("{fcd000}(ФСИН)\n\n{FFFFFF}Подойдите для взаимодействия\nс автопарком организации", -1, -1857.56,-2776.02,7.58,15.0);

    // Armory — exact donor position.
    g_FsinFullArmoryPickup = CreatePickup(1239,23,-1877.71,-2735.64,7.58,0);
    CreateDynamic3DTextLabel("{3399FF}- Оружейный склад -\n{FFFFFF}ФСИН", 0x3399FFFF, -1877.71,-2735.64,9.08,8.0);

    // FSIN lazaret beds use the common hospital interaction/healing system.
    g_FsinFullBedArea[0] = CreateDynamicSphere(-2005.465087,-1493.152709,1751.548583,2.0,6,1);
    g_FsinFullBedArea[1] = CreateDynamicSphere(-2005.371337,-1490.781982,1751.814208,2.0,6,1);
    g_FsinFullBedArea[2] = CreateDynamicSphere(-2005.318237,-1488.515625,1751.548583,2.0,6,1);
    g_FsinFullBedArea[3] = CreateDynamicSphere(-2001.401367,-1493.826416,1751.548583,2.0,6,1);

    // Main entrance: exterior world 0 <-> FSIN interior 1, virtual world 6.
    g_FsinFullEntrancePickup = CreatePickup(1318,23,-1747.629028,-2835.377197,8.033645,0);
    Create3DTextLabel("{FF5252}« Вход во ФСИН »",-1,-1747.629028,-2835.377197,9.033645,15.0,0);
    g_FsinFullExitPickup = CreatePickup(1318,23,-1816.255615,-2735.155273,1501.040039,6);
    Create3DTextLabel("{FF5252}« Выход из ФСИН »",-1,-1816.255615,-2735.155273,1502.040039,15.0,6);

    // Prison/lazaret/sawmill portals — exact donor pickups and labels.
    g_FsinFullLazaretIn = CreatePickup(1318,23,-1801.931030,-2757.826660,1501.000000,-1);
    g_FsinFullLazaretOut = CreatePickup(1318,23,-2003.557861,-1506.610107,1751.005249,-1);
    CreateDynamic3DTextLabel("Выход из лазарета",0xFFFF00FF,-2003.557861,-1506.610107,1752.005249,10.0);

    g_FsinFullCameraIn = CreatePickup(19132,23,-1801.861206,-2766.176757,1501.000000,-1);
    CreateDynamic3DTextLabel("Вход в камеру",0xFFFF00FF,-1801.861206,-2766.176757,1502.000000,10.0);
    g_FsinFullCameraOut = CreatePickup(19132,23,-1697.535400,-2702.098876,1499.500000,-1);
    CreateDynamic3DTextLabel("Выход из камеры",0xFFFF00FF,-1697.535400,-2702.098876,1500.500000,10.0);

    g_FsinFullSawmillIn = CreatePickup(1318,23,-1798.070190,-2759.390869,1501.000000,-1);
    CreateDynamic3DTextLabel("Вход в комнату лесопильни",0xFFFF00FF,-1798.070190,-2759.390869,1502.000000,10.0);
    g_FsinFullSawmillOut = CreatePickup(1318,23,-1887.860717,-2609.774902,1501.233764,-1);
    CreateDynamic3DTextLabel("Выход из комнаты лесопильни",0xFFFF00FF,-1887.860717,-2609.774902,1502.233764,10.0);
    for(new i; i < FSIN_FULL_SAWMILL_COUNT; i++)
    {
        g_FsinFullSawmillUser[i] = INVALID_PLAYER_ID;
        g_FsinFullSawmillArea[i] = CreateDynamicSphere(g_FsinFullSawmillPos[i][0],g_FsinFullSawmillPos[i][1],g_FsinFullSawmillPos[i][2],2.5,6,1);
        g_FsinFullSawmillLabel[i] = CreateDynamic3DTextLabel("{D99B45}ЛЕСОПИЛЬНЫЙ СТАНОК\n{FFFFFF}Используйте кнопку взаимодействия",-1,g_FsinFullSawmillPos[i][0],g_FsinFullSawmillPos[i][1],g_FsinFullSawmillPos[i][2]+0.65,12.0,INVALID_PLAYER_ID,INVALID_VEHICLE_ID,0,6,1);
    }
    return 1;
}

forward FsinFull_ProximityTick();
public FsinFull_ProximityTick()
{
    foreach(new playerid : Player)
    {
        if(!IsPlayerLogged(playerid)) continue;

        new bool:hr_near = false;
        if(GetPlayerTeamEx(playerid) == TEAM_NONE && !IsPlayerInAnyVehicle(playerid) && !GetPVarInt(playerid,"fsin_full_hr_busy"))
        {
            if(GetPlayerVirtualWorld(playerid) == 0 && IsPlayerInRangeOfPoint(playerid,4.5,-1817.008300,-2631.807617,7.590855)) hr_near = true;
        }

        if(hr_near)
        {
            ToggleInteractionWindow(playerid,true);
            SetPVarInt(playerid,"sime_context_hint",1);
            if(!g_FsinFullHrHint[playerid])
            {
                g_FsinFullHrHint[playerid] = 1;
            }
        }
        else if(g_FsinFullHrHint[playerid])
        {
            g_FsinFullHrHint[playerid] = 0;
            if(GetPVarInt(playerid,"sime_context_hint") == 1) DeletePVar(playerid,"sime_context_hint");
            ToggleInteractionWindow(playerid,false);
        }

        if(GetPlayerTeamEx(playerid) == FSIN_FULL_TEAM_ID && !IsPlayerInAnyVehicle(playerid) && FsinFull_GateGetNearby(playerid,14.0) != -1)
        {
            SetPVarInt(playerid,"sime_context_hint",3);
            ToggleInteractionWindow(playerid,true);
        }
    }
    return 1;
}

stock FsinFull_Init()
{
    for(new i; i < MAX_PLAYERS; i++)
    {
        g_FsinFullHrHint[i] = 0;
        g_FsinFullSawmillStation[i] = -1;
        g_FsinFullSawmillDone[i] = 0;
        g_FsinFullSawmillTDReady[i] = false;
    }
    new Cache:column_check = mysql_query(mysql,
        "SELECT COUNT(*) AS amount FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='accounts' AND COLUMN_NAME='jail_fsin'", true);
    new has_column = cache_get_field_content_int(0,"amount");
    cache_delete(column_check);
    if(!has_column)
        mysql_query(mysql,"ALTER TABLE accounts ADD COLUMN jail_fsin INT NOT NULL DEFAULT 0",false);
    new Cache:wanted_column_check = mysql_query(mysql,
        "SELECT COUNT(*) AS amount FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='accounts' AND COLUMN_NAME='jail_wanted_level'", true);
    new has_wanted_column = cache_get_field_content_int(0,"amount");
    cache_delete(wanted_column_check);
    if(!has_wanted_column)
        mysql_query(mysql,"ALTER TABLE accounts ADD COLUMN jail_wanted_level TINYINT UNSIGNED NOT NULL DEFAULT 0",false);
    FsinFull_CreateScene();
    FsinFull_CreatePickups();
    SetTimer("FsinFull_ProximityTick",500,true);
    return 1;
}

// --------------------------------------------------------------------------
// Gates
// --------------------------------------------------------------------------
stock FsinFull_GateGetNearby(playerid, Float:radius = 13.0)
{
    if(IsPlayerInRangeOfPoint(playerid,radius,-1823.66,-2633.54,8.58)) return 0;
    if(IsPlayerInRangeOfPoint(playerid,radius,-1820.49,-2651.36,10.90)) return 1;
    return -1;
}

forward FsinFull_GateClose(gate);
public FsinFull_GateClose(gate)
{
    if(gate < 0 || gate > 1) return 0;
    g_FsinFullGateCloseTimer[gate] = -1;
    g_FsinFullGateOpen[gate] = false;
    if(gate == 0)
    {
        MoveObject(g_FsinFullGateKpp2,-1820.11,-2632.95,8.58,2.0,0.0,0.0,-80.5);
        MoveObject(g_FsinFullGateKpp1,-1827.21,-2634.129,8.58,2.0,0.0,0.0,99.4);
    }
    else MoveObject(g_FsinFullGateInner,-1820.49,-2651.36,10.9,5.0,0.0,0.0,99.5);
    return 1;
}

stock FsinFull_GateOpen(playerid, gate)
{
    if(gate < 0 || gate > 1) return 0;
    if(GetPlayerTeamEx(playerid) != FSIN_FULL_TEAM_ID)
    {
        ShowNotificationNew(playerid,2,5,-1,-1,"Доступ к воротам разрешён только сотрудникам ФСИН.","");
        return 1;
    }
    if(g_FsinFullGateCloseTimer[gate] != -1)
    {
        KillTimer(g_FsinFullGateCloseTimer[gate]);
        g_FsinFullGateCloseTimer[gate] = -1;
    }
    if(gate == 0)
    {
        MoveObject(g_FsinFullGateKpp2,-1820.11,-2632.95,8.58,3.0,0.0,0.0,15.0);
        MoveObject(g_FsinFullGateKpp1,-1827.21,-2634.129,8.58,3.0,0.0,0.0,15.0);
    }
    else MoveObject(g_FsinFullGateInner,-1828.0,-2652.7,10.9,5.0,0.0,0.0,99.5);

    g_FsinFullGateOpen[gate] = true;
    g_FsinFullGateCloseTimer[gate] = SetTimerEx("FsinFull_GateClose",7000,false,"i",gate);
    ShowNotificationNew(playerid,3,4,-1,-1,"Ворота ФСИН открыты.","");
    return 1;
}

stock FsinFull_OnEnterDynamicArea(playerid, areaid)
{
    for(new sawmill; sawmill < FSIN_FULL_SAWMILL_COUNT; sawmill++) if(areaid == g_FsinFullSawmillArea[sawmill])
    {
        if(GetPlayerData(playerid,P_JAILFSIN) > 0 && !IsPlayerInAnyVehicle(playerid))
        {
            SetPVarInt(playerid,"sime_context_hint",4);
            ToggleInteractionWindow(playerid,true);
        }
        return 1;
    }
    new gate = -1;
    if(areaid == g_FsinFullGateArea[0]) gate = 0;
    else if(areaid == g_FsinFullGateArea[1]) gate = 1;
    else return 0;

    if(GetPlayerTeamEx(playerid) != FSIN_FULL_TEAM_ID)
    {
        ShowNotificationNew(playerid,2,5,-1,-1,"Вы не сотрудник ФСИН.","");
        return 1;
    }
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        ShowNotificationNew(playerid,4,6,-1,-1,"Посигнальте, чтобы открыть ворота ФСИН.","");
    else
    {
        SetPVarInt(playerid,"sime_context_hint",3);
        ToggleInteractionWindow(playerid,true);
        ShowNotificationNew(playerid,4,6,FSIN_FULL_GATE_NOTIFY_ID,gate,"Ворота ФСИН","Открыть");
    }
    return 1;
}

stock FsinFull_OnLeaveDynamicArea(playerid, areaid)
{
    for(new sawmill; sawmill < FSIN_FULL_SAWMILL_COUNT; sawmill++) if(areaid == g_FsinFullSawmillArea[sawmill])
    {
        if(GetPVarInt(playerid,"sime_context_hint") == 4) DeletePVar(playerid,"sime_context_hint");
        ToggleInteractionWindow(playerid,false);
        if(g_FsinFullSawmillStation[playerid] == sawmill) FsinFull_StopSawmill(playerid,true);
        return 1;
    }
    if(areaid != g_FsinFullGateArea[0] && areaid != g_FsinFullGateArea[1]) return 0;
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
    {
        if(GetPVarInt(playerid,"sime_context_hint") == 3) DeletePVar(playerid,"sime_context_hint");
        ToggleInteractionWindow(playerid,false);
    }
    return 1;
}

stock FsinFull_GateInteraction(playerid)
{
    if(!IsPlayerConnected(playerid) || GetPlayerTeamEx(playerid) != FSIN_FULL_TEAM_ID) return 0;
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return 0;
    new gate = FsinFull_GateGetNearby(playerid);
    if(gate == -1) return 0;
    if(GetPVarInt(playerid,"sime_context_hint") == 3) DeletePVar(playerid,"sime_context_hint");
    ToggleInteractionWindow(playerid,false);
    return FsinFull_GateOpen(playerid,gate);
}

stock FsinFull_GateHandleKeys(playerid,newkeys,oldkeys)
{
    if(!IsPlayerConnected(playerid) || GetPlayerTeamEx(playerid) != FSIN_FULL_TEAM_ID) return 0;
    new gate = FsinFull_GateGetNearby(playerid);
    if(gate == -1) return 0;
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        if((newkeys & KEY_CROUCH) && !(oldkeys & KEY_CROUCH)) return FsinFull_GateOpen(playerid,gate);
    }
    else if((newkeys & KEY_YES) && !(oldkeys & KEY_YES)) return FsinFull_GateOpen(playerid,gate);
    return 0;
}

// --------------------------------------------------------------------------
// HR / recruitment
// --------------------------------------------------------------------------
stock bool:FsinFull_HRIsNear(playerid, Float:radius = 7.0)
{
    if(GetPlayerVirtualWorld(playerid) != 0) return false;
    return IsPlayerInRangeOfPoint(playerid,radius,-1817.008300,-2631.807617,7.590855);
}

stock FsinFull_HRCheckRequirements(playerid,bool:notify=false)
{
    new bool:level_ok = (GetPlayerLevel(playerid) >= FSIN_FULL_HR_MIN_LEVEL);
    new bool:med_ok = (GetPlayerData(playerid,P_MEDKA) > 0);
    new bool:weapon_ok = (GetPlayerData(playerid,P_WEAPON_LIC) > 0);
    new bool:drive_ok = (GetPlayerData(playerid,P_DRIVING_LIC) > 0);
    if(level_ok && med_ok && weapon_ok && drive_ok) return 1;

    if(notify)
    {
        new body[420];
        format(body,sizeof body,
            "{FFFFFF}Для прохождения собеседования необходимы:\n\n"\
            "%s {FFFFFF}Игровой уровень: %d+\n"\
            "%s {FFFFFF}Медицинская карта\n"\
            "%s {FFFFFF}Водительские права\n"\
            "%s {FFFFFF}Лицензия на оружие\n\n"\
            "{CECECE}Получите недостающие документы и вернитесь в отдел кадров.\n"\
            "Военный билет не требуется.",
            level_ok ? "{55CC55}[OK]" : "{FF6666}[X]", FSIN_FULL_HR_MIN_LEVEL,
            med_ok ? "{55CC55}[OK]" : "{FF6666}[X]",
            drive_ok ? "{55CC55}[OK]" : "{FF6666}[X]",
            weapon_ok ? "{55CC55}[OK]" : "{FF6666}[X]");
        ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_HR_RESULT,DIALOG_STYLE_MSGBOX,"{3399FF}ФСИН {FFFFFF}| Отдел кадров",body,"Закрыть","");
    }
    return 0;
}

stock FsinFull_HRShowInfo(playerid)
{
    if(GetPlayerTeamEx(playerid) != TEAM_NONE)
    {
        DeletePVar(playerid,"fsin_full_hr_busy");
        ShowNotificationNew(playerid,2,6,-1,-1,"Вы уже состоите в организации.","");
        return 1;
    }
    new cooldown = GetPVarInt(playerid,"fsin_full_hr_retry_until");
    if(cooldown > gettime())
    {
        new msg[144];
        format(msg,sizeof msg,"Повторное собеседование будет доступно через %d сек.",cooldown-gettime());
        ShowNotificationNew(playerid,2,6,-1,-1,msg,"");
        DeletePVar(playerid,"fsin_full_hr_busy");
        return 1;
    }
    new info[640];
    format(info,sizeof info,
        "{FFFFFF}Здравствуйте, %s.\n\n"\
        "Вы проходите собеседование в организацию {3399FF}ФСИН{FFFFFF}.\n"\
        "Перед началом будут проверены необходимые документы.\n\n"\
        "{3399FF}Требования:{FFFFFF}\n"\
        "1. Игровой уровень: %d+\n"\
        "2. Медицинская карта\n"\
        "3. Водительские права\n"\
        "4. Лицензия на оружие\n\n"\
        "Собеседование состоит из 6 RP-вопросов.\n"\
        "Допускается не более двух ошибок.\n\n"\
        "{CECECE}Военный билет для этого собеседования не требуется.",
        GetPlayerNameEx(playerid),FSIN_FULL_HR_MIN_LEVEL);
    ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_HR_INFO,DIALOG_STYLE_MSGBOX,"{3399FF}ФСИН {FFFFFF}| Отдел кадров",info,"Начать","Закрыть");
    return 1;
}

stock FsinFull_HRShowQuestion(playerid,question)
{
    switch(question)
    {
        case 0: ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_HR_Q1,DIALOG_STYLE_LIST,"{3399FF}Вопрос 1/6 {FFFFFF}| Что означает IC-информация?","Информация вне игрового процесса\nИнформация только от администрации\nИнформация, относящаяся к игровому миру и персонажу\nЛюбая информация из Discord","Ответить","Закрыть");
        case 1: ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_HR_Q2,DIALOG_STYLE_LIST,"{3399FF}Вопрос 2/6 {FFFFFF}| Что означает OOC-информация?","Служебная информация организации\nИнформация о действиях персонажа\nИнформация только из рации\nИнформация вне игрового процесса","Ответить","Закрыть");
        case 2: ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_HR_Q3,DIALOG_STYLE_LIST,"{3399FF}Вопрос 3/6 {FFFFFF}| Можно ли убивать без IC-причины?","Да, если игрок мешает\nДа, если рядом нет администрации\nНет, это DM\nДа, сотрудникам организаций","Ответить","Закрыть");
        case 3: ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_HR_Q4,DIALOG_STYLE_LIST,"{3399FF}Вопрос 4/6 {FFFFFF}| Можно ли использовать OOC в IC?","Да, всегда\nНет, это MetaGaming\nМожно только во фракции\nМожно, если информация полезная","Ответить","Закрыть");
        case 4: ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_HR_Q5,DIALOG_STYLE_LIST,"{3399FF}Вопрос 5/6 {FFFFFF}| Можно ли вернуться и мстить после смерти?","Да, если запомнил убийцу\nНет, это нарушение RK\nМожно через одну минуту\nМожно сотрудникам госорганизаций","Ответить","Закрыть");
        case 5: ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_HR_Q6,DIALOG_STYLE_LIST,"{3399FF}Вопрос 6/6 {FFFFFF}| Как правильно общаться с гражданами?","Грубо, чтобы показать полномочия\nНе отвечать гражданам\nВежливо, соблюдать RP и субординацию\nТолько через OOC-чат","Ответить","Закрыть");
    }
    return 1;
}

stock FsinFull_HRFail(playerid,const reason[])
{
    SetPVarInt(playerid,"fsin_full_hr_retry_until",gettime()+FSIN_FULL_HR_RETRY_SECONDS);
    DeletePVar(playerid,"fsin_full_hr_question");
    DeletePVar(playerid,"fsin_full_hr_errors");
    new body[300];
    format(body,sizeof body,"{FF6666}Собеседование не пройдено.{FFFFFF}\n\n%s\n\nПовторная попытка будет доступна через 3 минуты.",reason);
    ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_HR_RESULT,DIALOG_STYLE_MSGBOX,"{3399FF}ФСИН {FFFFFF}| Отдел кадров",body,"Закрыть","");
    return 1;
}

stock FsinFull_HRPass(playerid)
{
    if(GetPlayerTeamEx(playerid) != TEAM_NONE) return 1;
    if(!FsinFull_HRCheckRequirements(playerid,true)) return 1;
    DeletePVar(playerid,"fsin_full_hr_question");
    DeletePVar(playerid,"fsin_full_hr_errors");
    DeletePVar(playerid,"fsin_full_hr_retry_until");
    DeletePVar(playerid,"fsin_portal_cooldown");
    DeletePVar(playerid,"fsin_court_wanted");
    DeletePVar(playerid,"fsin_died_in_custody");
    InvitePlayer(playerid,FSIN_FULL_TEAM_ID,1,true);

    new body[360],rank_name[60];
    format(rank_name,sizeof rank_name,"%s",GetTeamRankName(FSIN_FULL_TEAM_ID,1));
    format(body,sizeof body,"{55CC55}Собеседование пройдено.{FFFFFF}\n\nВы приняты в организацию {3399FF}ФСИН{FFFFFF}.\nНачальная должность: %s.\n\nСоблюдайте устав организации и субординацию.",rank_name);
    ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_HR_RESULT,DIALOG_STYLE_MSGBOX,"{3399FF}ФСИН {FFFFFF}| Отдел кадров",body,"Хорошо","");
    return 1;
}

stock FsinFull_HRProcessAnswer(playerid,question,answer)
{
    static const correct[6] = {2,3,2,1,1,2};
    if(question < 0 || question >= sizeof(correct)) return FsinFull_HRFail(playerid,"Состояние теста было сброшено.");
    if(answer != correct[question])
    {
        new errors = GetPVarInt(playerid,"fsin_full_hr_errors")+1;
        SetPVarInt(playerid,"fsin_full_hr_errors",errors);
        if(errors > FSIN_FULL_HR_MAX_ERRORS) return FsinFull_HRFail(playerid,"Вы допустили больше двух ошибок в RP-тесте.");
        new msg[112];
        format(msg,sizeof msg,"Неверный ответ. Допустимых ошибок осталось: %d",FSIN_FULL_HR_MAX_ERRORS-errors);
        ShowNotificationNew(playerid,2,4,-1,-1,msg,"");
    }
    else ShowNotificationNew(playerid,3,3,-1,-1,"Ответ принят.","");

    question++;
    SetPVarInt(playerid,"fsin_full_hr_question",question);
    if(question >= sizeof(correct)) return FsinFull_HRPass(playerid);
    return FsinFull_HRShowQuestion(playerid,question);
}

stock FsinFull_HRInteraction(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
    if(GetPlayerTeamEx(playerid) != TEAM_NONE || IsPlayerInAnyVehicle(playerid)) return 0;
    if(!FsinFull_HRIsNear(playerid,7.0)) return 0;
    ToggleInteractionWindow(playerid,false);
    g_FsinFullHrHint[playerid] = 0;
    DeletePVar(playerid,"sime_context_hint");
    SetPVarInt(playerid,"fsin_full_hr_busy",1);
    return FsinFull_HRShowInfo(playerid);
}

// --------------------------------------------------------------------------
// Fleet/autopark
// --------------------------------------------------------------------------
stock FsinFull_FindFleetSlotByModel(modelid)
{
    for(new i; i < FSIN_FULL_FLEET_COUNT; i++) if(g_FsinFullFleetModels[i] == modelid) return i;
    return -1;
}

stock bool:FsinFull_IsParkingOccupied(slot)
{
    if(slot < 0 || slot >= sizeof(g_FsinFullFleetParking)) return true;
    new max_vehicle = GetVehiclePoolSize();
    for(new vehicleid=1; vehicleid<=max_vehicle; vehicleid++)
    {
        if(!IsValidVehicle(vehicleid)) continue;
        if(GetVehicleData(vehicleid,V_ACTION_TYPE) != VEHICLE_ACTION_ORG_CAR) continue;
        if(GetVehicleData(vehicleid,V_ACTION_ID) != FSIN_FULL_TEAM_ID) continue;
        if(GetVehicleDistanceFromPoint(vehicleid,g_FsinFullFleetParking[slot][0],g_FsinFullFleetParking[slot][1],g_FsinFullFleetParking[slot][2]) < 3.2) return true;
    }
    return false;
}

stock FsinFull_FindFreeParking()
{
    for(new i; i < sizeof(g_FsinFullFleetParking); i++) if(!FsinFull_IsParkingOccupied(i)) return i;
    return -1;
}

stock FsinFull_PlaceVehicleExact(vehicleid,slot)
{
    if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid)) return 0;
    if(slot < 0 || slot >= sizeof(g_FsinFullFleetParking)) return 0;
    SetVehicleVirtualWorld(vehicleid,0);
    SetVehiclePos(vehicleid,g_FsinFullFleetParking[slot][0],g_FsinFullFleetParking[slot][1],g_FsinFullFleetParking[slot][2]);
    SetVehicleZAngle(vehicleid,g_FsinFullFleetParking[slot][3]);
    return 1;
}

stock FsinFull_ApplyFleetVinylForPlayer(playerid,vehicleid)
{
    if(!IsPlayerConnected(playerid) || vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid)) return 0;
    if(GetVehicleData(vehicleid,V_ACTION_TYPE) != VEHICLE_ACTION_ORG_CAR || GetVehicleData(vehicleid,V_ACTION_ID) != FSIN_FULL_TEAM_ID) return 0;

    new slot = FsinFull_FindFleetSlotByModel(GetVehicleModel(vehicleid));
    if(slot < 0 || slot >= FSIN_FULL_FLEET_COUNT) return 0;

    SetVehicleVinylForPlayer(playerid,vehicleid,g_FsinFullFleetVinyls[slot]);
    return 1;
}
stock FsinFull_ApplyFleetStyle(vehicleid,slot)
{
    if(vehicleid == INVALID_VEHICLE_ID || !IsValidVehicle(vehicleid)) return 0;
    if(slot < 0 || slot >= FSIN_FULL_FLEET_COUNT) return 0;
    // The donor stored vinyls by texture name, while this base stores a numeric
    // vinyl id. Do not write a string into vehicle data; the faction paint,
    // strobes, siren, tint and plate are still applied below.
    new plate[12];
    RandomNumberPlateByType(TYPE_RU,plate,sizeof plate);
    SetVehicleNumberPlateEx(vehicleid,TYPE_RU,plate,FSIN_FULL_NUMBER_REGION);
    SetVehicleSiren(vehicleid,1,1);
    SetVehicleStroboscope(vehicleid,2,1);
    SetVehicleTint(vehicleid,1,1);
    return 1;
}

stock FsinFull_ShowFleet(playerid)
{
    if(GetPlayerTeamEx(playerid) != FSIN_FULL_TEAM_ID) return SendClientMessage(playerid,-1,"{808080}Ошибка:{FFFFFF} Вам не доступен данный раздел");
    if(!GetPVarInt(playerid,"Form"))
    {
        ShowNotificationNew(playerid,2,4,0,0,"Вы не в форме организации.","");
        return 1;
    }
    if(GetPlayerData(playerid,P_FRACTION_CAR) != INVALID_VEHICLE_ID)
        return SendClientMessage(playerid,-1,"{808080}Ошибка:{FFFFFF} Вы уже взяли транспорт. Используйте /unfcar");

    new text[1400],row[192];
    text[0] = EOS;
    strcat(text,"{E94B35}№\t{E94B35}Служебный транспорт\t{E94B35}Доступ\t{E94B35}Статус\n");
    new rank = GetPlayerJob(playerid);
    for(new i; i < FSIN_FULL_FLEET_COUNT; i++)
    {
        if(rank >= g_FsinFullFleetMinRank[i])
            format(row,sizeof row,"{FFFFFF}#%d\t{FFFFFF}%s\t{D7D7D7}с %d ранга\t{42D66B}доступен\n",i+1,g_FsinFullFleetNames[i],g_FsinFullFleetMinRank[i]);
        else
            format(row,sizeof row,"{FFFFFF}#%d\t{FFFFFF}%s\t{D7D7D7}с %d ранга\t{E85D5D}не доступен\n",i+1,g_FsinFullFleetNames[i],g_FsinFullFleetMinRank[i]);
        strcat(text,row);
    }
    ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_FLEET,DIALOG_STYLE_TABLIST_HEADERS,"{E94B35}SIME RUSSIA {FFFFFF}| Фракционный транспорт",text,"Выбрать","Отмена");
    return 1;
}

stock FsinFull_SpawnFleetVehicle(playerid,slot)
{
    if(slot < 0 || slot >= FSIN_FULL_FLEET_COUNT) return 1;
    if(GetPlayerTeamEx(playerid) != FSIN_FULL_TEAM_ID) return 1;
    if(!GetPVarInt(playerid,"Form")) return 1;
    if(GetPlayerData(playerid,P_FRACTION_CAR) != INVALID_VEHICLE_ID) return 1;
    if(GetPlayerJob(playerid) < g_FsinFullFleetMinRank[slot])
    {
        new deny[128];
        format(deny,sizeof deny,"ФСИН | Этот транспорт доступен с %d ранга",g_FsinFullFleetMinRank[slot]);
        FsinFull_ShowSimpleNotification(playerid,deny);
        return FsinFull_ShowFleet(playerid);
    }

    new park = FsinFull_FindFreeParking();
    if(park == -1)
    {
        FsinFull_ShowSimpleNotification(playerid,"Обе парковки ФСИН сейчас заняты. Верните одну из служебных машин.");
        return 1;
    }

    new vehicleid = CreateVehicle(
        g_FsinFullFleetModels[slot],
        g_FsinFullFleetParking[park][0],g_FsinFullFleetParking[park][1],g_FsinFullFleetParking[park][2],g_FsinFullFleetParking[park][3],
        1,1,120,0,VEHICLE_ACTION_ORG_CAR,FSIN_FULL_TEAM_ID
    );
    if(vehicleid == INVALID_VEHICLE_ID) return SendClientMessage(playerid,-1,"{808080}Ошибка:{FFFFFF} Не удалось создать транспорт ФСИН");

    FsinFull_PlaceVehicleExact(vehicleid,park);
    FsinFull_ApplyFleetStyle(vehicleid,slot);
    SetVehicleData(vehicleid,V_ACTION_OWNER,playerid);
    foreach(new viewerid : Player) FsinFull_ApplyFleetVinylForPlayer(viewerid,vehicleid);
    SetPlayerData(playerid,P_FRACTION_CAR,vehicleid);
    PutPlayerInVehicle(playerid,vehicleid,0);
    FsinFull_PlaceVehicleExact(vehicleid,park);

    new msg[128];
    format(msg,sizeof msg,"{3399FF}Вы взяли транспорт: %s",g_FsinFullFleetNames[slot]);
    SendClientMessage(playerid,-1,msg);
    return 1;
}

stock FsinFull_ReturnFactionVehicle(playerid)
{
    new vehicleid = GetPlayerData(playerid,P_FRACTION_CAR);
    if(vehicleid == INVALID_VEHICLE_ID) return SendClientMessage(playerid,-1,"{808080}Ошибка:{FFFFFF} У вас нет фракционного транспорта");
    SetPlayerData(playerid,P_FRACTION_CAR,INVALID_VEHICLE_ID);
    if(IsValidVehicle(vehicleid) && GetVehicleData(vehicleid,V_ACTION_TYPE) == VEHICLE_ACTION_ORG_CAR) DestroyVehicle(vehicleid);
    SendClientMessage(playerid,0x66CC00FF,"Служебный транспорт ФСИН возвращён.");
    return 1;
}

stock FsinFull_ValidateVehicleAccess(playerid,vehicleid)
{
    if(!IsValidVehicle(vehicleid)) return 0;
    if(GetVehicleData(vehicleid,V_ACTION_TYPE) != VEHICLE_ACTION_ORG_CAR || GetVehicleData(vehicleid,V_ACTION_ID) != FSIN_FULL_TEAM_ID) return 0;
    if(GetPlayerTeamEx(playerid) != FSIN_FULL_TEAM_ID)
    {
        FsinFull_ShowSimpleNotification(playerid,"Вам не доступен данный транспорт");
        RemovePlayerFromVehicle(playerid);
        return 1;
    }
    new slot = FsinFull_FindFleetSlotByModel(GetVehicleData(vehicleid,V_MODELID));
    if(slot != -1 && GetPlayerJob(playerid) < g_FsinFullFleetMinRank[slot])
    {
        new deny[128];
        format(deny,sizeof deny,"Данный транспорт ФСИН доступен с %d ранга",g_FsinFullFleetMinRank[slot]);
        FsinFull_ShowSimpleNotification(playerid,deny);
        RemovePlayerFromVehicle(playerid);
        return 1;
    }
    return 0;
}

stock FsinFull_OnVehicleSpawn(vehicleid)
{
    if(!IsValidVehicle(vehicleid)) return 0;
    if(GetVehicleData(vehicleid,V_ACTION_TYPE) != VEHICLE_ACTION_ORG_CAR || GetVehicleData(vehicleid,V_ACTION_ID) != FSIN_FULL_TEAM_ID) return 0;
    new owner = GetVehicleData(vehicleid,V_ACTION_OWNER);
    if(owner >= 0 && owner < MAX_PLAYERS && IsPlayerConnected(owner))
    {
        if(GetPlayerData(owner,P_FRACTION_CAR) == vehicleid) SetPlayerData(owner,P_FRACTION_CAR,INVALID_VEHICLE_ID);
    }
    DestroyVehicle(vehicleid);
    return 1;
}

// --------------------------------------------------------------------------
// Wardrobe / workday
// --------------------------------------------------------------------------
stock FsinFull_OpenWardrobe(playerid)
{
    if(GetPlayerTeamEx(playerid) != FSIN_FULL_TEAM_ID) return SendClientMessage(playerid,0x999999FF,"Вам не доступен данный раздел");
    if(!GetPVarInt(playerid,"Form"))
        ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_WORK_START,DIALOG_STYLE_MSGBOX,"{FF5252}SIME RUSSIA {FFFFFF}| Рабочий день","{FFFFFF}Вы действительно хотите начать свой рабочий день?","Да","Нет");
    else
        ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_WORK_END,DIALOG_STYLE_MSGBOX,"{FF5252}SIME RUSSIA {FFFFFF}| Рабочий день","{FFFFFF}Вы действительно хотите закончить свой рабочий день?","Да","Нет");
    return 1;
}

// --------------------------------------------------------------------------
// Armory — exact donor item list/amounts/cooldowns
// --------------------------------------------------------------------------
stock FsinFull_OpenArmory(playerid)
{
    if(GetPlayerTeamEx(playerid) != FSIN_FULL_TEAM_ID) return SendClientMessage(playerid,0x999999FF,"У Вас нет доступа к этому");
    if(!GetPVarInt(playerid,"Form")) return SendClientMessage(playerid,0x999999FF,"Сначала начните рабочий день в раздевалке");
    ShowPlayerDialog(playerid,DIALOG_FSIN_FULL_ARMORY,DIALOG_STYLE_LIST,"{FFCD00}Оружейный склад",
        "1. Взять дубинку\n2. Взять маску\n3. Взять бронежилет\n4. Взять пистолет с глушителем\n5. Взять Desert Eagle\n6. Взять MP5\n7. Взять дробовик\n8. Взять AK47\n9. Взять винтовку",
        "Взять","Отмена");
    return 1;
}

stock FsinFull_HandleArmoryItem(playerid,listitem)
{
    if(GetPlayerTeamEx(playerid) != FSIN_FULL_TEAM_ID) return 1;
    if(!GetPVarInt(playerid,"Form")) return SendClientMessage(playerid,0x999999FF,"Сначала начните рабочий день в раздевалке");
    static const min_rank[9] = {1,1,1,2,3,4,4,5,7};
    if(listitem < 0 || listitem >= sizeof min_rank) return 1;
    if(GetPlayerJob(playerid) < min_rank[listitem])
    {
        new rank_error[96];
        format(rank_error,sizeof rank_error,"Этот предмет доступен с %d ранга ФСИН",min_rank[listitem]);
        return SendClientMessage(playerid,0x999999FF,rank_error);
    }
    switch(listitem+1)
    {
        case 1:
        {
            if(GetPVarInt(playerid,"took_nitestick") > gettime()) return SendClientMessage(playerid,0x999999FF,"Вы уже недавно брали дубинку");
            GivePlayerWeapon(playerid,3,1); SendClientMessage(playerid,0x3399FFFF,"Вы взяли дубинку"); SetPVarInt(playerid,"took_nitestick",gettime()+300);
        }
        case 2:
        {
            if(GetPVarInt(playerid,"took_mask") > gettime()) return SendClientMessage(playerid,0x999999FF,"Вы уже недавно брали маску");
            if(GetPlayerData(playerid,P_MASK) == 1) return SendClientMessage(playerid,0x999999FF,"У Вас уже есть маска");
            SetPlayerData(playerid,P_MASK,1); SendClientMessage(playerid,0x3399FFFF,"Вы взяли маску"); SetPVarInt(playerid,"took_mask",gettime()+300);
        }
        case 3:
        {
            new Float:armour; GetPlayerArmour(playerid,armour);
            if(armour > 20.0) return SendClientMessage(playerid,0x999999FF,"У Вас уже есть бронежилет");
            SetPlayerArmour(playerid,100.0); SendClientMessage(playerid,0x3399FFFF,"Вы надели бронежилет");
        }
        case 4:
        {
            if(GetPVarInt(playerid,"took_sdpistol") > gettime()) return SendClientMessage(playerid,0x999999FF,"Вы уже недавно брали пистолет с глушителем");
            GivePlayerWeapon(playerid,23,60); SendClientMessage(playerid,0x3399FFFF,"Вы взяли пистолет с глушителем"); SetPVarInt(playerid,"took_sdpistol",gettime()+300);
        }
        case 5:
        {
            if(GetPVarInt(playerid,"took_deagle") > gettime()) return SendClientMessage(playerid,0x999999FF,"Вы уже недавно брали Desert Eagle");
            GivePlayerWeapon(playerid,24,120); SendClientMessage(playerid,0x3399FFFF,"Вы взяли Desert Eagle"); SetPVarInt(playerid,"took_deagle",gettime()+300);
        }
        case 6:
        {
            if(GetPVarInt(playerid,"took_mp5") > gettime()) return SendClientMessage(playerid,0x999999FF,"Вы уже недавно брали MP5");
            GivePlayerWeapon(playerid,29,180); SendClientMessage(playerid,0x3399FFFF,"Вы взяли MP5"); SetPVarInt(playerid,"took_mp5",gettime()+300);
        }
        case 7:
        {
            if(GetPVarInt(playerid,"took_shotgun") > gettime()) return SendClientMessage(playerid,0x999999FF,"Вы уже недавно брали дробовик");
            GivePlayerWeapon(playerid,25,30); SendClientMessage(playerid,0x3399FFFF,"Вы взяли дробовик"); SetPVarInt(playerid,"took_shotgun",gettime()+300);
        }
        case 8:
        {
            if(GetPVarInt(playerid,"took_ak47") > gettime()) return SendClientMessage(playerid,0x999999FF,"Вы уже недавно брали АК47");
            GivePlayerWeapon(playerid,30,230); SendClientMessage(playerid,0x3399FFFF,"Вы взяли АК47"); SetPVarInt(playerid,"took_ak47",gettime()+300);
        }
        case 9:
        {
            if(GetPlayerJob(playerid) < 4) return SendClientMessage(playerid,0x999999FF,"Винтовку можно брать только с 4 ранга");
            if(GetPVarInt(playerid,"took_rifle") > gettime()) return SendClientMessage(playerid,0x999999FF,"Вы уже недавно брали винтовку");
            GivePlayerWeapon(playerid,34,40); SendClientMessage(playerid,0x3399FFFF,"Вы взяли винтовку"); SetPVarInt(playerid,"took_rifle",gettime()+300);
        }
    }
    return 1;
}

// --------------------------------------------------------------------------
// Prison portals / jail
// --------------------------------------------------------------------------
stock bool:FsinFull_IsLazaretBedArea(areaid)
{
    for(new i; i < sizeof g_FsinFullBedArea; i++)
        if(areaid == g_FsinFullBedArea[i]) return true;
    return false;
}

stock bool:FsinFull_IsPlayerInLazaret(playerid)
{
    if(GetPlayerInterior(playerid) != 1 || GetPlayerVirtualWorld(playerid) != 6) return false;
    return IsPlayerInRangeOfPoint(playerid,35.0,-2004.620239,-1492.151245,1751.045288);
}

stock FsinFull_GetNearbySawmill(playerid,Float:range = 2.5)
{
    if(GetPlayerVirtualWorld(playerid) != 6 || GetPlayerInterior(playerid) != 1) return -1;
    for(new i; i < FSIN_FULL_SAWMILL_COUNT; i++) if(IsPlayerInRangeOfPoint(playerid,range,g_FsinFullSawmillPos[i][0],g_FsinFullSawmillPos[i][1],g_FsinFullSawmillPos[i][2])) return i;
    return -1;
}

stock FsinFull_CreateSawmillTD(playerid)
{
    if(g_FsinFullSawmillTDReady[playerid]) return 1;
    g_FsinFullSawmillTD[playerid][0] = CreatePlayerTextDraw(playerid,145.0,92.0,"_");
    PlayerTextDrawTextSize(playerid,g_FsinFullSawmillTD[playerid][0],495.0,0.0); PlayerTextDrawLetterSize(playerid,g_FsinFullSawmillTD[playerid][0],0.0,29.0); PlayerTextDrawUseBox(playerid,g_FsinFullSawmillTD[playerid][0],1); PlayerTextDrawBoxColor(playerid,g_FsinFullSawmillTD[playerid][0],0x17130FF2);
    g_FsinFullSawmillTD[playerid][1] = CreatePlayerTextDraw(playerid,320.0,108.0,"ЛЕСОПИЛКА ФСИН");
    PlayerTextDrawAlignment(playerid,g_FsinFullSawmillTD[playerid][1],2); PlayerTextDrawLetterSize(playerid,g_FsinFullSawmillTD[playerid][1],0.34,1.55); PlayerTextDrawColor(playerid,g_FsinFullSawmillTD[playerid][1],0xE0A34BFF); PlayerTextDrawSetOutline(playerid,g_FsinFullSawmillTD[playerid][1],1);
    g_FsinFullSawmillTD[playerid][2] = CreatePlayerTextDraw(playerid,320.0,132.0,"НАЖМИТЕ НА ВСЕ ДЕРЕВЬЯ | 0/6");
    PlayerTextDrawAlignment(playerid,g_FsinFullSawmillTD[playerid][2],2); PlayerTextDrawLetterSize(playerid,g_FsinFullSawmillTD[playerid][2],0.20,1.0); PlayerTextDrawColor(playerid,g_FsinFullSawmillTD[playerid][2],0xFFFFFFFF);
    g_FsinFullSawmillTD[playerid][3] = CreatePlayerTextDraw(playerid,320.0,327.0,"ЗАКРЫТЬ");
    PlayerTextDrawAlignment(playerid,g_FsinFullSawmillTD[playerid][3],2); PlayerTextDrawLetterSize(playerid,g_FsinFullSawmillTD[playerid][3],0.25,1.1); PlayerTextDrawTextSize(playerid,g_FsinFullSawmillTD[playerid][3],18.0,112.0); PlayerTextDrawUseBox(playerid,g_FsinFullSawmillTD[playerid][3],1); PlayerTextDrawBoxColor(playerid,g_FsinFullSawmillTD[playerid][3],0xA83232FF); PlayerTextDrawSetSelectable(playerid,g_FsinFullSawmillTD[playerid][3],1);
    new const Float:bx[FSIN_FULL_SAWMILL_BOARDS] = {180.0,285.0,390.0,180.0,285.0,390.0};
    new const Float:by[FSIN_FULL_SAWMILL_BOARDS] = {154.0,154.0,154.0,234.0,234.0,234.0};
    for(new i; i < FSIN_FULL_SAWMILL_BOARDS; i++)
    {
	        // Do not use font 5 preview models here: several mobile builds crash
	        // when six selectable object previews are created at once.  This is a
	        // lightweight text-drawn tree with a normal selectable hitbox.
	        g_FsinFullSawmillTD[playerid][i+4] = CreatePlayerTextDraw(playerid,bx[i],by[i],"~g~/\\~n~/__\\~n~~y~ ||");
	        PlayerTextDrawFont(playerid,g_FsinFullSawmillTD[playerid][i+4],1);
	        PlayerTextDrawLetterSize(playerid,g_FsinFullSawmillTD[playerid][i+4],0.42,1.35);
	        PlayerTextDrawTextSize(playerid,g_FsinFullSawmillTD[playerid][i+4],bx[i]+68.0,4.2);
	        PlayerTextDrawUseBox(playerid,g_FsinFullSawmillTD[playerid][i+4],1);
	        PlayerTextDrawBoxColor(playerid,g_FsinFullSawmillTD[playerid][i+4],0x2B2118CC);
	        PlayerTextDrawSetOutline(playerid,g_FsinFullSawmillTD[playerid][i+4],1);
	        PlayerTextDrawSetSelectable(playerid,g_FsinFullSawmillTD[playerid][i+4],1);
    }
    g_FsinFullSawmillTDReady[playerid] = true; return 1;
}

stock FsinFull_StopSawmill(playerid,bool:message=false)
{
    new station = g_FsinFullSawmillStation[playerid];
    if(station >= 0 && station < FSIN_FULL_SAWMILL_COUNT && g_FsinFullSawmillUser[station] == playerid) g_FsinFullSawmillUser[station] = INVALID_PLAYER_ID;
    if(g_FsinFullSawmillTDReady[playerid]) for(new i; i < FSIN_FULL_SAWMILL_BOARDS + 4; i++) PlayerTextDrawHide(playerid,g_FsinFullSawmillTD[playerid][i]);
    CancelSelectTextDraw(playerid); g_FsinFullSawmillStation[playerid] = -1; g_FsinFullSawmillDone[playerid] = 0; ClearAnimations(playerid,1);
    if(message) SendClientMessage(playerid,0xCCCCCCFF,"Работа на лесопилке прекращена"); return 1;
}

stock FsinFull_StartSawmill(playerid,station)
{
    if(GetPlayerData(playerid,P_JAILFSIN) <= 0) return SendClientMessage(playerid,0x999999FF,"На станках могут работать только заключённые ФСИН");
    if(station < 0 || station >= FSIN_FULL_SAWMILL_COUNT) return 0;
    if(g_FsinFullSawmillUser[station] != INVALID_PLAYER_ID && g_FsinFullSawmillUser[station] != playerid) return SendClientMessage(playerid,0xFF7777FF,"Этот станок уже занят другим заключённым");
    FsinFull_CreateSawmillTD(playerid); g_FsinFullSawmillUser[station] = playerid; g_FsinFullSawmillStation[playerid] = station; g_FsinFullSawmillDone[playerid] = 0;
    PlayerTextDrawSetString(playerid,g_FsinFullSawmillTD[playerid][2],"НАЖМИТЕ НА ВСЕ ДЕРЕВЬЯ | 0/6");
    SetPlayerFacingAngle(playerid,g_FsinFullSawmillPos[station][3]); ApplyAnimation(playerid,"CHAINSAW","WEAPON_csaw",4.0,1,0,0,0,0,1);
    for(new i; i < FSIN_FULL_SAWMILL_BOARDS + 4; i++) { if(i >= 4) PlayerTextDrawSetSelectable(playerid,g_FsinFullSawmillTD[playerid][i],1); PlayerTextDrawShow(playerid,g_FsinFullSawmillTD[playerid][i]); }
    SelectTextDraw(playerid,0xE0A34BFF); return 1;
}

stock FsinFull_OnPlayerClickPlayerTextDraw(playerid,PlayerText:playertextid)
{
    new jail_time;
    if(g_FsinFullSawmillStation[playerid] < 0) return 0;
    if(playertextid == PlayerText:INVALID_TEXT_DRAW || playertextid == g_FsinFullSawmillTD[playerid][3]) return FsinFull_StopSawmill(playerid,true);
    for(new i; i < FSIN_FULL_SAWMILL_BOARDS; i++) if(playertextid == g_FsinFullSawmillTD[playerid][i+4])
    {
        PlayerTextDrawHide(playerid,g_FsinFullSawmillTD[playerid][i+4]); PlayerTextDrawSetSelectable(playerid,g_FsinFullSawmillTD[playerid][i+4],0); g_FsinFullSawmillDone[playerid]++;
        new progress[64]; format(progress,sizeof progress,"НАЖМИТЕ НА ВСЕ ДЕРЕВЬЯ | %d/%d",g_FsinFullSawmillDone[playerid],FSIN_FULL_SAWMILL_BOARDS); PlayerTextDrawSetString(playerid,g_FsinFullSawmillTD[playerid][2],progress);
        if(g_FsinFullSawmillDone[playerid] >= FSIN_FULL_SAWMILL_BOARDS)
        {
            GivePlayerMoneyEx(playerid,FSIN_FULL_SAWMILL_REWARD,"FSIN sawmill work",true,true);
            jail_time = GetPlayerData(playerid,P_JAILFSIN)-FSIN_FULL_SAWMILL_TIME_REWARD; if(jail_time < 0) jail_time = 0; SetPlayerData(playerid,P_JAILFSIN,jail_time); UpdatePlayerDatabaseInt(playerid,"jail_fsin",jail_time);
            FsinFull_StopSawmill(playerid); SendClientMessage(playerid,0x66CC00FF,"Смена завершена: +200 рублей, срок сокращён на 30 секунд");
            if(jail_time <= 0) { SendClientMessage(playerid,0x66CC00FF,"Ваш срок окончен, вы свободны"); FsinFull_UnjailPlayer(playerid); }
        }
        return 1;
    }
    return 1;
}

stock FsinFull_HandlePortalPickup(playerid,pickupid)
{
    if(pickupid != g_FsinFullLazaretIn && pickupid != g_FsinFullLazaretOut &&
        pickupid != g_FsinFullCameraIn && pickupid != g_FsinFullCameraOut &&
        pickupid != g_FsinFullSawmillIn && pickupid != g_FsinFullSawmillOut) return 0;
    if(GetPlayerTeamEx(playerid) != FSIN_FULL_TEAM_ID && GetPlayerData(playerid,P_JAILFSIN) <= 0)
        return SendClientMessage(playerid,0x999999FF,"Доступ разрешён только сотрудникам и заключённым ФСИН"), 1;
    if(pickupid == g_FsinFullLazaretIn)
    {
        SetPlayerPos(playerid,-2002.991333,-1504.858642,1751.005249); SetPlayerFacingAngle(playerid,270.0); SetPlayerInterior(playerid,1); return 1;
    }
    if(pickupid == g_FsinFullLazaretOut)
    {
        SetPlayerPos(playerid,-1800.220703,-2757.756591,1501.000000); SetPlayerFacingAngle(playerid,270.0); SetPlayerInterior(playerid,1); return 1;
    }
    if(pickupid == g_FsinFullCameraIn)
    {
        SetPlayerPos(playerid,-1699.121582,-2702.468261,1499.500000); SetPlayerFacingAngle(playerid,270.0); SetPlayerInterior(playerid,1); return 1;
    }
    if(pickupid == g_FsinFullCameraOut)
    {
        SetPlayerPos(playerid,-1800.229248,-2766.166015,1501.000000); SetPlayerFacingAngle(playerid,270.0); SetPlayerInterior(playerid,1); return 1;
    }
    if(pickupid == g_FsinFullSawmillIn)
    {
        SetPlayerPos(playerid,-1887.554321,-2608.276611,1501.000000); SetPlayerFacingAngle(playerid,270.0); SetPlayerInterior(playerid,1); return 1;
    }
    if(pickupid == g_FsinFullSawmillOut)
    {
        SetPlayerPos(playerid,-1799.559448,-2759.095947,1501.000000); SetPlayerFacingAngle(playerid,270.0); SetPlayerInterior(playerid,1); return 1;
    }
    return 0;
}

stock FsinFull_ClearCourtWanted(playerid)
{
    DeletePVar(playerid,"fsin_court_wanted");
    DeletePVar(playerid,"fsin_died_in_custody");
    UpdatePlayerDatabaseInt(playerid,"jail_wanted_level",0);
    return 1;
}

stock FsinFull_TryTransferFromJail(playerid)
{
    new wanted = GetPVarInt(playerid,"fsin_court_wanted");
    new chance, minutes;

    switch(wanted)
    {
        case 2: { chance = 20; minutes = 15; }
        case 3: { chance = 30; minutes = 25; }
        case 4: { chance = 60; minutes = 40; }
        case 5: { chance = 75; minutes = 50; }
        case 6: { chance = 85; minutes = 60; }
        default: return 0;
    }

    FsinFull_ClearCourtWanted(playerid);
    if(random(100) >= chance) return 0;

    SetPlayerData(playerid,P_JAIL,0);
    UpdatePlayerDatabaseInt(playerid,"jail",0);
    FsinFull_JailPlayer(playerid,minutes);
    SendClientMessage(playerid,0xFFCC00FF,"Вы были конвоированы в ФСИН по решению суда");
    return 1;
}

stock FsinFull_GetPrisonerSkin(playerid)
{
    return GetPlayerSex(playerid) ? 63 : 48;
}

stock FsinFull_ApplyPrisonerSkin(playerid)
{
    if(GetPlayerData(playerid,P_JAILFSIN) <= 0) return 0;
    if(GetPlayerState(playerid) == PLAYER_STATE_WASTED) return 0;

    new prison_skin = FsinFull_GetPrisonerSkin(playerid);
    if(GetPlayerSkin(playerid) != prison_skin) SetPlayerSkin(playerid,prison_skin);
    return 1;
}
stock FsinFull_JailPlayer(playerid,jail_minutes)
{
    if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
    SetPlayerInBiz(playerid,-1);
    SetPlayerInHouse(playerid,-1);
    SetPlayerInEntrance(playerid,-1);
    SetPlayerInEntranceFloor(playerid,-1);
    SetPlayerData(playerid,P_IN_HOTEL_ROOM,-1);
    SetPlayerData(playerid,P_IN_HOTEL_FLOOR,-1);
    SetPlayerData(playerid,P_JAILFSIN,jail_minutes*60);
    FsinFull_ApplyPrisonerSkin(playerid);
    new pos = random(sizeof(g_FsinFullJailPositions));
    SetPlayerPosEx(playerid,g_FsinFullJailPositions[pos][0],g_FsinFullJailPositions[pos][1],g_FsinFullJailPositions[pos][2],g_FsinFullJailPositions[pos][3],1,6);
    UpdatePlayerDatabaseInt(playerid,"jail_fsin",jail_minutes*60);
    return 1;
}

stock FsinFull_UnjailPlayer(playerid)
{
    SetPlayerPosEx(playerid,-1806.124389,-2629.567871,7.686372,14.429187,0,0);
    SetPlayerData(playerid,P_JAILFSIN,0);
    UpdatePlayerDatabaseInt(playerid,"jail_fsin",0);
    SetPlayerSkinInit(playerid);
    return 1;
}

stock FsinFull_TickSecond(playerid)
{
    if(GetPlayerData(playerid,P_JAILFSIN) <= 0) return 0;
    FsinFull_ApplyPrisonerSkin(playerid);
    AddPlayerData(playerid,P_JAILFSIN,-,1);
    // Persist in batches instead of issuing one SQL UPDATE per prisoner every second.
    if(GetPlayerData(playerid,P_JAILFSIN) % 30 == 0)
        UpdatePlayerDatabaseInt(playerid,"jail_fsin",GetPlayerData(playerid,P_JAILFSIN));
    if(GetPlayerData(playerid,P_JAILFSIN) <= 0)
    {
        SendClientMessage(playerid,0x66CC00FF,"Ваш срок окончен, вы свободны");
        FsinFull_UnjailPlayer(playerid);
    }
    return 1;
}

stock FsinFull_LoadAccountFromCurrentCache(playerid)
{
    SetPlayerData(playerid,P_JAILFSIN,cache_get_field_content_int(0,"jail_fsin"));
    new court_wanted = cache_get_field_content_int(0,"jail_wanted_level");
    if(court_wanted >= 2 && court_wanted <= 6) SetPVarInt(playerid,"fsin_court_wanted",court_wanted);
    else DeletePVar(playerid,"fsin_court_wanted");
    return 1;
}

forward FsinFull_RestoreLazaretSpawn(playerid);
public FsinFull_RestoreLazaretSpawn(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid) || GetPlayerData(playerid,P_JAILFSIN) <= 0) return 0;
    DeletePVar(playerid,"fsin_died_in_custody");
    SetPlayerPosEx(playerid,-2004.620239,-1492.151245,1751.045288,271.377044,1,6);
    FsinFull_ApplyPrisonerSkin(playerid);
    SetPlayerHealthEx(playerid,25.0);
    SendClientMessage(playerid,0xFFCC00FF,"После смерти Вы были доставлены в лазарет ФСИН");
    return 1;
}

forward FsinFull_RestoreJailSpawn(playerid);
public FsinFull_RestoreJailSpawn(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid) || GetPlayerData(playerid,P_JAILFSIN) <= 0) return 0;
    new pos = random(sizeof(g_FsinFullJailPositions));
    SetPlayerPosEx(playerid,g_FsinFullJailPositions[pos][0],g_FsinFullJailPositions[pos][1],g_FsinFullJailPositions[pos][2],g_FsinFullJailPositions[pos][3],1,6);
    FsinFull_ApplyPrisonerSkin(playerid);
    SendClientMessage(playerid,0xFFFF00FF,"Вы продолжаете отбывать наказание в учреждении ФСИН");
    return 1;
}

stock FsinFull_OnPlayerDeath(playerid)
{
    if(GetPlayerData(playerid,P_JAILFSIN) <= 0) return 0;
    SetPVarInt(playerid,"fsin_died_in_custody",1);
    return 1;
}

stock FsinFull_OnPlayerSpawn(playerid)
{
    if(GetPlayerData(playerid,P_JAILFSIN) <= 0) return 0;
    if(GetPVarInt(playerid,"fsin_died_in_custody"))
        return FsinFull_RestoreLazaretSpawn(playerid);
    return FsinFull_RestoreJailSpawn(playerid);
}

// Optional helper to put a current FSIN member at the exact organization spawn.
stock FsinFull_ApplyOrganizationSpawn(playerid)
{
    SetPlayerPosEx(playerid,g_FsinFullSpawn[0],g_FsinFullSpawn[1],g_FsinFullSpawn[2],g_FsinFullSpawn[3],0,0);
    return 1;
}

// --------------------------------------------------------------------------
// Main pickup/dialog/callback bridge functions
// --------------------------------------------------------------------------
stock FsinFull_OnPlayerPickUpPickup(playerid,pickupid)
{
    if(pickupid == g_FsinFullEntrancePickup || pickupid == g_FsinFullExitPickup)
    {
        new tick = GetTickCount();
        if(GetPVarInt(playerid,"fsin_portal_cooldown") > tick) return 1;
        SetPVarInt(playerid,"fsin_portal_cooldown",tick + 1500);

        if(pickupid == g_FsinFullEntrancePickup)
            SetPlayerPosEx(playerid,-1816.255615,-2735.155273,1501.040039,269.850280,1,6);
        else
            SetPlayerPosEx(playerid,-1747.629028,-2835.377197,8.033645,317.939544,0,0);
        return 1;
    }
    if(pickupid == g_FsinFullWardrobePickup) return FsinFull_OpenWardrobe(playerid);
    if(pickupid == g_FsinFullFleetPickup) return FsinFull_ShowFleet(playerid);
    if(pickupid == g_FsinFullArmoryPickup) return FsinFull_OpenArmory(playerid);
    if(FsinFull_HandlePortalPickup(playerid,pickupid)) return 1;
    return 0;
}

stock FsinFull_OnDialogResponse(playerid,dialogid,response,listitem,inputtext[])
{
    #pragma unused inputtext
    if(dialogid == DIALOG_FSIN_FULL_HR_INFO)
    {
        if(!response) { DeletePVar(playerid,"fsin_full_hr_busy"); return 1; }
        if(GetPlayerTeamEx(playerid) != TEAM_NONE) { DeletePVar(playerid,"fsin_full_hr_busy"); return 1; }
        if(!FsinFull_HRCheckRequirements(playerid,true)) { DeletePVar(playerid,"fsin_full_hr_busy"); return 1; }
        SetPVarInt(playerid,"fsin_full_hr_question",0); SetPVarInt(playerid,"fsin_full_hr_errors",0); return FsinFull_HRShowQuestion(playerid,0);
    }
    if(dialogid >= DIALOG_FSIN_FULL_HR_Q1 && dialogid <= DIALOG_FSIN_FULL_HR_Q6)
    {
        if(!response) return FsinFull_HRFail(playerid,"Вы прервали собеседование.");
        new question = dialogid-DIALOG_FSIN_FULL_HR_Q1;
        if(GetPVarInt(playerid,"fsin_full_hr_question") != question) return FsinFull_HRFail(playerid,"Последовательность вопросов была нарушена.");
        return FsinFull_HRProcessAnswer(playerid,question,listitem);
    }
    if(dialogid == DIALOG_FSIN_FULL_HR_RESULT) { DeletePVar(playerid,"fsin_full_hr_busy"); return 1; }
    if(dialogid == DIALOG_FSIN_FULL_FLEET) { if(response) return FsinFull_SpawnFleetVehicle(playerid,listitem); return 1; }
    if(dialogid == DIALOG_FSIN_FULL_WORK_START)
    {
        if(response) { SetPVarInt(playerid,"Form",1); SetPlayerSkin(playerid,GetPlayerData(playerid,P_OSKIN)); ShowNotificationNew(playerid,3,5,0,0,"Рабочий день начат.",""); }
        return 1;
    }
    if(dialogid == DIALOG_FSIN_FULL_WORK_END)
    {
        if(response) { DeletePVar(playerid,"Form"); SetPlayerSkin(playerid,GetPlayerData(playerid,P_SKIN)); ShowNotificationNew(playerid,3,5,0,0,"Рабочий день закончен.",""); }
        return 1;
    }
    if(dialogid == DIALOG_FSIN_FULL_ARMORY) { if(response) return FsinFull_HandleArmoryItem(playerid,listitem); return 1; }
    return 0;
}

stock FsinFull_OnPlayerKeyStateChange(playerid,newkeys,oldkeys)
{
    if(FsinFull_GateHandleKeys(playerid,newkeys,oldkeys)) return 1;
    if((newkeys & KEY_YES) && !(oldkeys & KEY_YES) && FsinFull_HRInteraction(playerid)) return 1;
    return 0;
}

stock FsinFull_OnPlayerStateChange(playerid,newstate,oldstate)
{
    #pragma unused oldstate
    if(newstate == PLAYER_STATE_DRIVER)
    {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(FsinFull_ValidateVehicleAccess(playerid,vehicleid)) return 1;
    }
    return 0;
}

stock FsinFull_OnNotificationClick(playerid,notify_id,notify_sub_id)
{
    if(notify_id == FSIN_FULL_GATE_NOTIFY_ID || notify_sub_id == FSIN_FULL_GATE_NOTIFY_ID) { FsinFull_GateInteraction(playerid); return 1; }
    return 0;
}

stock FsinFull_OnContextInteraction(playerid)
{
    new sawmill = FsinFull_GetNearbySawmill(playerid);
    if(sawmill != -1)
    {
        ToggleInteractionWindow(playerid,false);
        DeletePVar(playerid,"sime_context_hint");
        return FsinFull_StartSawmill(playerid,sawmill);
    }
    if(FsinFull_HRInteraction(playerid) || FsinFull_GateInteraction(playerid)) return 1;
    return 0;
}

stock FsinFull_OnDisconnect(playerid)
{
    FsinFull_StopSawmill(playerid);
    if(g_FsinFullSawmillTDReady[playerid])
    {
        for(new i; i < FSIN_FULL_SAWMILL_BOARDS + 4; i++)
        {
            PlayerTextDrawDestroy(playerid,g_FsinFullSawmillTD[playerid][i]);
            g_FsinFullSawmillTD[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
        g_FsinFullSawmillTDReady[playerid] = false;
    }
    g_FsinFullSawmillStation[playerid] = -1;
    g_FsinFullSawmillDone[playerid] = 0;
    if(IsPlayerLogged(playerid) && GetPlayerData(playerid,P_JAILFSIN) > 0)
        UpdatePlayerDatabaseInt(playerid,"jail_fsin",GetPlayerData(playerid,P_JAILFSIN));
    g_FsinFullHrHint[playerid] = 0;
    DeletePVar(playerid,"fsin_full_hr_busy");
    DeletePVar(playerid,"fsin_full_hr_question");
    DeletePVar(playerid,"fsin_full_hr_errors");
    DeletePVar(playerid,"fsin_full_hr_retry_until");
    DeletePVar(playerid,"fsin_portal_cooldown");
    DeletePVar(playerid,"fsin_court_wanted");
    DeletePVar(playerid,"fsin_died_in_custody");
    DeletePVar(playerid,"sime_context_hint");
    return 1;
}

// --------------------------------------------------------------------------
// Commands included for a donor-equivalent build.
// If the target already has /unfcar, keep its existing command and call
// FsinFull_ReturnFactionVehicle() from the TEAM_FSIN branch instead.
// --------------------------------------------------------------------------
CMD:fsinready(playerid,params[])
{
    if(GetPlayerAdminEx(playerid) < 13) return 1;
    new target;
    if(sscanf(params,"d",target)) return SendClientMessage(playerid,0xCECECEFF,"Используйте: /fsinready [id игрока]");
    if(!IsPlayerConnected(target) || !IsPlayerLogged(target)) return SendClientMessage(playerid,0x999999FF,"Такого игрока нет");
    if(GetPlayerLevel(target) < FSIN_FULL_HR_MIN_LEVEL)
    {
        SetPlayerData(target,P_LEVEL,FSIN_FULL_HR_MIN_LEVEL);
        UpdatePlayerDatabaseInt(target,"level",FSIN_FULL_HR_MIN_LEVEL);
        SetPlayerLevelInit(target);
    }
    SetPlayerData(target,P_MEDKA,1); SetPlayerData(target,P_DRIVING_LIC,2); SetPlayerData(target,P_WEAPON_LIC,1);
    UpdatePlayerDatabaseInt(target,"med",1); UpdatePlayerDatabaseInt(target,"driving_lic",2); UpdatePlayerDatabaseInt(target,"weapon_lic",1);
    DeletePVar(target,"fsin_full_hr_retry_until"); DeletePVar(target,"fsin_full_hr_errors"); DeletePVar(target,"fsin_full_hr_question");
    SendClientMessage(playerid,0x66CC00FF,"Документы для отдела кадров выданы.");
    SendClientMessage(target,0x3399FFFF,"Администратор выдал Вам медкарту, водительские права и лицензию на оружие.");
    return 1;
}
alias:fsinready("hrready","fsindocs","orgready")

CMD:fsinjail(playerid,params[])
{
    if(GetPlayerAdminEx(playerid) < 13) return 1;
    new target,minutes;
    if(sscanf(params,"dd",target,minutes)) return SendClientMessage(playerid,0xCECECEFF,"Используйте: /fsinjail [id] [минуты]");
    if(!IsPlayerConnected(target) || !IsPlayerLogged(target)) return SendClientMessage(playerid,0x999999FF,"Такого игрока нет");
    if(minutes < 1 || minutes > 1440) return SendClientMessage(playerid,0x999999FF,"Срок: от 1 до 1440 минут");
    FsinFull_JailPlayer(target,minutes);
    return 1;
}

CMD:fsinunjail(playerid,params[])
{
    if(GetPlayerAdminEx(playerid) < 13) return 1;
    new target;
    if(sscanf(params,"d",target)) return SendClientMessage(playerid,0xCECECEFF,"Используйте: /fsinunjail [id]");
    if(!IsPlayerConnected(target) || !IsPlayerLogged(target)) return SendClientMessage(playerid,0x999999FF,"Такого игрока нет");
    FsinFull_UnjailPlayer(target);
    return 1;
}
