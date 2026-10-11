enum s_family_player
{
    ID_FAMILY,
    ID_SQL_FAMILY,
    STREAMER_TAG_3D_TEXT_LABEL:TEXT_FAMILY,
    RANG_FAMILY,

    MUTE_FAMILY,
    VIG_FAMILY,

    ACCESS_GIVE,
    ACCESS_MONEY,
    ACCESS_ARMOUR,
    ACCESS_MATERIAL,
    ACCESS_HEATH_KIT,
    ACCESS_PATRON,
    ACCESS_MASK,
};

//family log
#define type_log_money  3
#define type_log_material 4
#define type_log_armour  8
#define type_log_heath_kit 6
#define type_log_patron  7
#define type_log_mask  5

#define type_log_kick 2
#define type_log_invite 1

#define type_log_car 9
#define type_log_dostup 11
#define type_log_rang 10

#define DIALOG_FAMILY_GUI_LOG_MENU 2372
#define DIALOG_FAMILY_GUI_LOG_LIST 2373
#define FAMILY_GUI_LOGS_PER_PAGE 15

new player_family[MAX_PLAYERS][s_family_player];

#define GetPlayerFamily(%0,%1)  player_family[%0][%1]
#define SetPlayerFamily(%0,%1,%2)  player_family[%0][%1]=%2
#define AddPlayerFamily(%0,%1,%2,%3)  player_family[%0][%1]%2=%3
#define GetPlayerRangFamily(%0)  player_family[%0][RANG_FAMILY]
#define GetPlayerIdFamily(%0)  player_family[%0][ID_FAMILY]

new price_up_sklad[7] = {0, 100000, 200000, 500000, 800000, 1000000, 2000000};
new price_up_weapon[7] = {0, 700000, 1000000, 1200000, 1350000, 1500000, 2000000};
new price_up_compound[7] = {0, 700000, 1000000, 1500000, 2000000, 2500000, 3000000};

new count_money_level[7] = {200000, 500000, 2000000, 4000000, 8000000, 15000000, 30000000};
new count_material_level[7] = {250, 500, 1500, 3000, 6000, 12000, 15000};
new count_heath_kit_level[7] = {20, 40, 120, 240, 480, 960, 1300};
new count_mask_level[7] = {25, 50, 150, 300, 600, 1200, 1500};
new count_armour_level[7] = {150, 300, 500, 700, 900, 1000, 1500};

new count_weapon_level[7] = {24, 30, 29, 25, 33, 34, 31};
new count_patron_level[7] = {100000, 300000, 400000, 500000, 600000, 700000, 1000000};

new count_compound_level[7] = {100, 250, 500, 1500, 2000, 3000, 3500};

new const FAMILY_GUI_LOG_MENU_NAMES[11][] =
{
    "Принятие новых членов семьи",
    "Увольнение членов семьи",
    "Взаимодействие с деньгами склада",
    "Взаимодействие с материалами склада",
    "Взаимодействие с масками склада",
    "Взаимодействие с канистрами склада",
    "Взаимодействие с оружием склада",
    "Взаимодействие с бронежилетами склада",
    "Взаимодействие с семейным автопарком",
    "Выдача доступов",
    "Взаимодействие со складом"
};

new name_weapon_family[7][24] =
{
    {"Desert Eagle"},
    {"AK-47"},
    {"MP5"},
    {"Shotgun"},
    {"Country Rifle"},
    {"Sniper Rifle"},
    {"M4"}
};

#define FSendClientMessage(%0,%1,%2,%3,%4)	format(%0, sizeof(%0),%3,%4) && SendClientMessage(%1, %2, %0)
#define BackSendClientMessage(%0,%1,%2)	SendClientMessage(%0, %1, %2) && callcmd::familymenuinternal(%0)

enum s_family
{
    family_database,
    family_color,
    family_reputation,
    family_zaxvati,
    family_moneti,
    family_syndicate,
    family_name[32],
    family_owner,
    family_slot_veh,
    family_count_veh,
    family_count_people,
    family_status_storage,
    family_money,
    family_armour,
    family_material,
    family_heath_kit,
    family_patron,
    family_mask,
    family_lvl_storage,
    family_lvl_weapon,
    family_lvl_compound,
    family_house
};

new family_type_color[18][9]=
{
    {"{AF9A5B}"},
    {"{B1B7F1}"},
    {"{5BA8A4}"},
    {"{B9378F}"},
    {"{1028F4}"},
    {"{5054EC}"},
    {"{01FF23}"},
    {"{F29527}"},
    {"{6C4559}"},
    {"{F2DAFE}"},
    {"{7EADFF}"},
    {"{C95EEC}"},
    {"{852048}"},
    {"{76B3F2}"},
    {"{DCB72B}"},
    {"{31D166}"},
    {"{3969CD}"},
    {"{C9E8F2}"}
};

#define MAX_FAM  100
new family[MAX_FAM][s_family];
new family_rang_name[MAX_FAM][5][24];
new family_rang_dostup[MAX_FAM][5][5];

#define GetFamily(%0,%1)  family[%0][%1]
#define SetFamily(%0,%1,%2)  family[%0][%1]=%2
#define AddFamily(%0,%1,%2,%3)  family[%0][%1]%2=%3

#define c_f "{D9FF00}[Семья]{FFFFFF} "
#define c_f_g "{1EFF00}[Семья]{FFFFFF} "
#define c_f_r "{FF0000}[Семья]{FFFFFF} "

#define STATUS_UNLOADED 0
#define STATUS_LOADED 1

forward bool:ParseStoredPlateValue(stored[], &plate_type, plate[], plate_size, region[], region_size);
forward BuildStoredPlateValue(plate_type, plate[], region[], dest[], size);
forward SetVehicleNumberPlateEx(vehicleid, type, number[], region[]);

enum s_family_vehicle
{
    OW_F_database,
    OW_F_server,
    CAR_F_database,
    V_F_NUMBER[32],
    V_F_VINYL_NAME[32],
    V_F_MODEL,
    V_F_COLOR_1,
    V_F_COLOR_2,
    V_F_RANG,
    Float:V_F_SPAWN_X,
    Float:V_F_SPAWN_Y,
    Float:V_F_SPAWN_Z,
    Float:V_F_SPAWN_A,
    V_F_WORLD,
    V_F_INT,
    V_F_FSTATE,
    V_F_NITRO,
    V_F_LAUNCH,
    V_F_PDVRADAR,
    V_F_LIGHTS_COLOR,
    V_F_UNDERLIGHT_COLOR,
    V_F_UNDERLIGHT_COLOR_LF,
    V_F_UNDERLIGHT_COLOR_RT,
    V_F_IS_FAR_LIGHT_ACTIVE,
    V_F_SELECTED_PNEVMO,
    V_F_PERCENT_CLR,
    V_F_PERCENT_CLR_Z,
    V_F_IS_HYDRO_ACTIVE,

    //addition (покупай дополнение с каптами и контами фамы)
    V_F_COUNT_BOX,
    STREAMER_TAG_3D_TEXT_LABEL:V_F_TEXT_CONT,
    V_F_AREA_CONT,
    bool:V_F_STATUS_CONT
};

new vehicle_family[MAX_OWNABLE_CARS][s_family_vehicle];

#define GetCarFamily(%0,%1)  vehicle_family[%0][%1]
#define SetCarFamily(%0,%1,%2)  vehicle_family[%0][%1]=%2
#define AddCarFamily(%0,%1,%2,%3)  vehicle_family[%0][%1]%2=%3

new f_string144[144];
new f_string64[64];
new f_string184[184];
new f_string32[32];

public OnGameModeInit()
{
    for(new i;i < MAX_PLAYERS;i++) SetPlayerFamily(i, ID_FAMILY, -1);
    for(new i;i < MAX_FAM;i++) SetFamily(i, family_database, -1);
    for(new i;i < MAX_OWNABLE_CARS;i++) SetCarFamily(i, CAR_F_database, -1);

    SetTimer("CREATE_ACCOUNTS_TABLE", 500, false);
    SetTimer("welsi_LoadFamily", 1400, false);
    SetTimer("CheckMutePlayer", 1000, true);
    #if defined fam_OnGameModeInit
        return fam_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit fam_OnGameModeInit
#if defined fam_OnGameModeInit
    forward fam_OnGameModeInit();
#endif

public:CREATE_ACCOUNTS_TABLE()
{
    // Проверяем, существует ли колонка family_id
    new Cache:cache = mysql_query(mysql, "SHOW COLUMNS FROM `accounts` LIKE 'family_id'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `accounts` ADD `family_id` INT NOT NULL DEFAULT '-1' AFTER `admin`, ADD `family_rang` INT NOT NULL DEFAULT '1' AFTER `family_id`, ADD `family_mute` INT NOT NULL DEFAULT '0' AFTER `family_rang`, ADD `family_vig` INT NOT NULL DEFAULT '0' AFTER `family_mute`, ADD `family_access` VARCHAR(24) NOT NULL DEFAULT '0,0,0,0,0,0,0' AFTER `family_vig`", false);

        if(mysql_errno()) printf("%d error create ALTER TABLE `accounts` ADD `family_id`", mysql_errno());
    }
    cache_delete(cache);

    cache = mysql_query(mysql, "SHOW COLUMNS FROM `accounts` LIKE 'family_vig'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `accounts` ADD `family_vig` INT NOT NULL DEFAULT '0' AFTER `family_mute`", false);

        if(mysql_errno()) printf("%d error create ALTER TABLE `accounts` ADD `family_vig`", mysql_errno());
    }
    cache_delete(cache);

    cache = mysql_query(mysql, "SHOW COLUMNS FROM `accounts` LIKE 'moneti'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `accounts` ADD `moneti` INT NOT NULL DEFAULT '0' AFTER `coins`", false);

        if(mysql_errno()) printf("%d error create ALTER TABLE `accounts` ADD `moneti`", mysql_errno());
    }
    cache_delete(cache);

    cache = mysql_query(mysql, "SHOW COLUMNS FROM `family_cars` LIKE 'plate_type'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `family_cars` ADD `plate_type` INT NOT NULL DEFAULT '1' AFTER `number`, ADD `plate_number` VARCHAR(16) NOT NULL DEFAULT '' AFTER `plate_type`, ADD `plate_region` VARCHAR(8) NOT NULL DEFAULT '' AFTER `plate_number`", false);

        if(mysql_errno()) printf("%d error create ALTER TABLE `family_cars` ADD `plate_type`", mysql_errno());
    }
    cache_delete(cache);
    cache = mysql_query(mysql, "SHOW COLUMNS FROM `family_cars` LIKE 'vynil_name'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `family_cars` ADD `vynil_name` VARCHAR(32) NOT NULL DEFAULT '' AFTER `plate_region`", false);

        if(mysql_errno()) printf("%d error create ALTER TABLE `family_cars` ADD `vynil_name`", mysql_errno());
    }
    cache_delete(cache);

    cache = mysql_query(mysql, "SHOW COLUMNS FROM `family_cars` LIKE 'f_state'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `family_cars` ADD `f_state` INT NOT NULL DEFAULT '0' AFTER `vynil_name`, ADD `nitro_level` INT NOT NULL DEFAULT '0' AFTER `f_state`, ADD `launch` INT NOT NULL DEFAULT '0' AFTER `nitro_level`, ADD `pdvradar` INT NOT NULL DEFAULT '0' AFTER `launch`, ADD `lights_color` INT NOT NULL DEFAULT '0' AFTER `pdvradar`, ADD `underlights_color` INT NOT NULL DEFAULT '0' AFTER `lights_color`, ADD `underlights_color_lf` INT NOT NULL DEFAULT '0' AFTER `underlights_color`, ADD `underlights_color_rt` INT NOT NULL DEFAULT '0' AFTER `underlights_color_lf`, ADD `is_FarLight_active` INT NOT NULL DEFAULT '0' AFTER `underlights_color_rt`, ADD `pnevmo_selected` INT NOT NULL DEFAULT '0' AFTER `is_FarLight_active`, ADD `percentofclirness` INT NOT NULL DEFAULT '0' AFTER `pnevmo_selected`, ADD `percentofclirnessZ` INT NOT NULL DEFAULT '0' AFTER `percentofclirness`, ADD `is_hydro_active` INT NOT NULL DEFAULT '0' AFTER `percentofclirnessZ`", false);

        if(mysql_errno()) printf("%d error create ALTER TABLE `family_cars` ADD tuning fields", mysql_errno());
    }
    cache_delete(cache);


    cache = mysql_query(mysql, "SHOW COLUMNS FROM `accounts` LIKE 'family_notif_seen'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `accounts` ADD `family_notif_seen` INT NOT NULL DEFAULT '0' AFTER `moneti`", false);

        if(mysql_errno()) printf("%d error create ALTER TABLE `accounts` ADD `family_notif_seen`", mysql_errno());
    }
    cache_delete(cache);

    cache = mysql_query(mysql, "SHOW COLUMNS FROM `accounts` LIKE 'family_notif_seen_family'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `accounts` ADD `family_notif_seen_family` INT NOT NULL DEFAULT '0' AFTER `family_notif_seen`", false);

        if(mysql_errno()) printf("%d error create ALTER TABLE `accounts` ADD `family_notif_seen_family`", mysql_errno());
    }
    cache_delete(cache);

    cache = mysql_query(mysql, "SHOW COLUMNS FROM `familynew` LIKE 'chatcolor'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `familynew` ADD `chatcolor` INT NOT NULL DEFAULT '0' AFTER `color`", false);
        if(!mysql_errno())
            mysql_query(mysql, "UPDATE `familynew` SET `chatcolor` = `color`", false);
        else printf("%d error create ALTER TABLE `familynew` ADD `chatcolor`", mysql_errno());
    }
    cache_delete(cache);

    cache = mysql_query(mysql, "SHOW COLUMNS FROM `familynew` LIKE 'zaxvati'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `familynew` ADD `zaxvati` INT NOT NULL DEFAULT '0' AFTER `reputation`", false);
        if(mysql_errno())
            printf("%d error create ALTER TABLE `familynew` ADD `zaxvati`", mysql_errno());
    }
    cache_delete(cache);

    cache = mysql_query(mysql, "SHOW COLUMNS FROM `familynew` LIKE 'moneti'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `familynew` ADD `moneti` INT NOT NULL DEFAULT '0' AFTER `zaxvati`", false);
        if(mysql_errno())
            printf("%d error create ALTER TABLE `familynew` ADD `moneti`", mysql_errno());
    }
    cache_delete(cache);

    cache = mysql_query(mysql, "SHOW COLUMNS FROM `familynew` LIKE 'syndicate'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `familynew` ADD `syndicate` INT NOT NULL DEFAULT '0' AFTER `moneti`", false);
        if(mysql_errno())
            printf("%d error create ALTER TABLE `familynew` ADD `syndicate`", mysql_errno());
    }
    cache_delete(cache);

    cache = mysql_query(mysql, "SHOW COLUMNS FROM `familynew` LIKE 'notif_seq'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "ALTER TABLE `familynew` ADD `notif_seq` INT NOT NULL DEFAULT '0' AFTER `notif`", false);
        if(mysql_errno())
            printf("%d error create ALTER TABLE `familynew` ADD `notif_seq`", mysql_errno());
    }
    cache_delete(cache);

    cache = mysql_query(mysql, "SHOW TABLES LIKE 'familyblack'", true);
    if(!cache_num_rows())
    {
        mysql_query(mysql, "CREATE TABLE `familyblack` (`family_id` INT NOT NULL, `account_id` INT NOT NULL, `reason` VARCHAR(64) NOT NULL DEFAULT '', `created_at` INT NOT NULL DEFAULT '0', PRIMARY KEY (`family_id`, `account_id`), KEY `idx_familyblack_account_id` (`account_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", false);
        if(mysql_errno())
            printf("%d error create TABLE `familyblack`", mysql_errno());
    }
    cache_delete(cache);
    return 1;
}

public OnPlayerConnect(playerid)
{
    SetTimerEx("LoadPlayerFamily", 3000, false, "i", playerid);
    #if defined fam_OnPlayerConnect
        return fam_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect fam_OnPlayerConnect
#if defined fam_OnPlayerConnect
    forward fam_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
    SetTimerEx("UnLoadPlayerFamily", 1000, false, "i", playerid);
    #if defined fam_OnPlayerDisconnect
        return fam_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect fam_OnPlayerDisconnect
#if defined fam_OnPlayerDisconnect
    forward fam_OnPlayerDisconnect(playerid, reason);
#endif

public: welsi_LoadFamily()
{
    new Cache:cache=mysql_query(mysql, "SELECT * FROM familynew");

    if(mysql_errno())
        return printf("[FAMILY SQL #1] LoadFamily %d", mysql_errno());

    if(!cache_num_rows())
        return print("None Cache | Query load Family");

    new rows = cache_num_rows();

    if(rows > 300)
    {
        rows = 300;
        printf("count family (%d) > 300", rows);
    } 

    for(new i; i < rows; i ++)
    {
        SetFamily(i, family_database, cache_get_field_content_int(i, "id"));
        SetFamily(i, family_owner, cache_get_field_content_int(i, "owner"));
        SetFamily(i, family_color, cache_get_field_content_int(i, "chatcolor"));
        SetFamily(i, family_count_veh, cache_get_field_content_int(i, "slot_veh"));
        SetFamily(i, family_reputation, cache_get_field_content_int(i, "reputation"));
        SetFamily(i, family_zaxvati, cache_get_field_content_int(i, "zaxvati"));
        SetFamily(i, family_moneti, cache_get_field_content_int(i, "moneti"));
        SetFamily(i, family_syndicate, cache_get_field_content_int(i, "syndicate"));
        SetFamily(i, family_slot_veh, cache_get_field_content_int(i, "slot_veh"));
        cache_get_field_content(i, "name", GetFamily(i, family_name), mysql, 32);

        SetFamily(i, family_patron, cache_get_field_content_int(i, "patron"));
        SetFamily(i, family_material, cache_get_field_content_int(i, "material"));
        SetFamily(i, family_heath_kit, cache_get_field_content_int(i, "heath_kit"));
        SetFamily(i, family_armour, cache_get_field_content_int(i, "armour"));
        SetFamily(i, family_money, cache_get_field_content_int(i, "money"));

        SetFamily(i, family_lvl_storage, cache_get_field_content_int(i, "level_storage"));
        SetFamily(i, family_lvl_weapon, cache_get_field_content_int(i, "level_weapon"));
        SetFamily(i, family_lvl_compound, cache_get_field_content_int(i, "level_compound"));
        SetFamily(i, family_house, cache_get_field_content_int(i, "house"));

        new rang[5][24], name[12], setting_1,
        setting_2, setting_3, setting_4, setting_5;

        cache_get_field_content(i, "rang_1", rang[0], mysql, 24);
        cache_get_field_content(i, "rang_2", rang[1], mysql, 24);
        cache_get_field_content(i, "rang_3", rang[2], mysql, 24);
        cache_get_field_content(i, "rang_4", rang[3], mysql, 24);
        cache_get_field_content(i, "rang_5", rang[4], mysql, 24);

        for(new l;l < 5;l++)
        {
            sscanf(rang[l], "P<,>s[12]ddddd", name, setting_1, setting_2, setting_3, setting_4, setting_5);
            format(family_rang_name[i][l], 24, name);
            family_rang_dostup[i][l][0] = setting_1;
            family_rang_dostup[i][l][1] = setting_2;
            family_rang_dostup[i][l][2] = setting_3;
            family_rang_dostup[i][l][3] = setting_4;
            family_rang_dostup[i][l][4] = setting_5;
        }
    }

    for(new i; i < MAX_FAM;i++)
    {
        if(GetFamily(i, family_database) == -1) continue;

        mysql_format(mysql, f_string184, sizeof f_string184, "SELECT"\
        "(SELECT COUNT(*) FROM accounts WHERE family_id = %d) AS accounts_count,"\
        "(SELECT COUNT(*) FROM family_cars WHERE family_owner = %d) AS cars_count", GetFamily(i, family_database), GetFamily(i, family_database)); //спасибо Grok
        new Cache:ccache = mysql_query(mysql, f_string184);

        if(cache_num_rows())
        {
            new count_people = cache_get_row_int(0,0),
            count_auto = cache_get_row_int(0, 1);

            SetFamily(i, family_count_veh, count_auto);
            SetFamily(i, family_count_people, count_people);
            //printf("%d | people = %d car = %d", mysql_errno(), count_people, count_auto);
        }

        cache_delete(ccache);
    }


    return 1;
}

public: UnLoadPlayerFamily(playerid)
{
    if(GetPlayerFamily(playerid, ID_FAMILY) == -1) return 1;

    UpdatePlayerDatabaseInt(playerid, "family_id", GetPlayerFamily(playerid, ID_SQL_FAMILY));
    UpdatePlayerDatabaseInt(playerid, "family_rang", GetPlayerFamily(playerid, RANG_FAMILY));
    UpdatePlayerDatabaseInt(playerid, "family_mute", GetPlayerFamily(playerid, MUTE_FAMILY));
    UpdateAccessPlayerFamily(playerid);

    SetPlayerFamily(playerid, ID_FAMILY, -1);
    SetPlayerFamily(playerid, ID_SQL_FAMILY, -1);
    
    DestroyDynamic3DTextLabel(GetPlayerFamily(playerid, TEXT_FAMILY));
    SetPlayerFamily(playerid, TEXT_FAMILY, STREAMER_TAG_3D_TEXT_LABEL:-1);

    SetPlayerFamily(playerid, RANG_FAMILY, 0);
    SetPlayerFamily(playerid, MUTE_FAMILY, 0);
    SetPlayerFamily(playerid, VIG_FAMILY, 0);

    SetPlayerFamily(playerid, ACCESS_GIVE, 0);
    SetPlayerFamily(playerid, ACCESS_MONEY, 0);
    SetPlayerFamily(playerid, ACCESS_ARMOUR, 0);
    SetPlayerFamily(playerid, ACCESS_MATERIAL, 0);
    SetPlayerFamily(playerid, ACCESS_HEATH_KIT, 0);
    SetPlayerFamily(playerid, ACCESS_PATRON, 0);
    SetPlayerFamily(playerid, ACCESS_MASK, 0);

    return 1;
}

/*

ALTER TABLE `accounts` ADD `family_id` INT NOT NULL DEFAULT '-1' AFTER `admin`, ADD `family_rang` INT NOT NULL DEFAULT '1' AFTER `family_id`, ADD `family_mute` INT NOT NULL AFTER `family_rang`, ADD `family_access` VARCHAR(24) NOT NULL DEFAULT '0,0,0,0,0,0,0' AFTER `family_mute`;

*/
public:LoadPlayerFamily(playerid)
{
    mysql_format(mysql, f_string64, sizeof(f_string64), "SELECT * FROM accounts WHERE id=%d LIMIT 1", GetPlayerAccountID(playerid));
    new Cache:cache=mysql_query(mysql, f_string64);

    if(mysql_errno())
        return print("[FAMILY SQL #2] LoadPlayerFamily");

    if(!cache_num_rows()) return printf("%d - none accounts", cache_num_rows());

    new access_c[7], access[24];

    new id = cache_get_field_content_int(0, "family_id");
    if(id == -1) return 1;

    for(new i; i <MAX_FAM;i++)
    {
        if(GetFamily(i, family_database) != id) continue;

        SetPlayerFamily(playerid, ID_FAMILY, i);
        break;
    }

    if(GetPlayerFamily(playerid, ID_FAMILY) == -1) return printf("None fAmily - %d", id);

    SetPlayerFamily(playerid, ID_SQL_FAMILY, id);

    SetPlayerFamily(playerid, RANG_FAMILY, cache_get_field_content_int(0, "family_rang"));
    SetPlayerFamily(playerid, MUTE_FAMILY, cache_get_field_content_int(0, "family_mute"));
    SetPlayerFamily(playerid, VIG_FAMILY, cache_get_field_content_int(0, "family_vig"));

    cache_get_field_content(0, "family_access", access, mysql, 24);
    sscanf(access, "P<,>ddddddd", access_c[0], access_c[1], access_c[2], access_c[3], access_c[4], 
    access_c[5], access_c[6]);

    SetPlayerFamily(playerid, ACCESS_GIVE,      access_c[0]);
    SetPlayerFamily(playerid, ACCESS_MONEY,     access_c[1]);
    SetPlayerFamily(playerid, ACCESS_ARMOUR,    access_c[2]);
    SetPlayerFamily(playerid, ACCESS_MATERIAL,  access_c[3]);
    SetPlayerFamily(playerid, ACCESS_HEATH_KIT, access_c[4]);
    SetPlayerFamily(playerid, ACCESS_PATRON,    access_c[5]);
    SetPlayerFamily(playerid, ACCESS_MASK,      access_c[6]);

	new familyName[64];
	format(familyName, sizeof familyName, "%s", GetFamily(GetPlayerIdFamily(playerid), family_name));
	utf8_to_cp1251(familyName); // преобразуем в cp1251

    format(f_string144, sizeof f_string144, "%sСемья: %s", family_type_color[GetFamily(GetPlayerIdFamily(playerid), family_color)], GetFamily(GetPlayerIdFamily(playerid), family_name));
    printf("%s    color %s  name %s ", f_string144, family_type_color[GetFamily(GetPlayerIdFamily(playerid), family_color)], GetFamily(GetPlayerIdFamily(playerid), family_name));
    
    if(IsValidDynamic3DTextLabel(GetPlayerFamily(playerid, TEXT_FAMILY))) DestroyDynamic3DTextLabel(GetPlayerFamily(playerid, TEXT_FAMILY));
    SetPlayerFamily(playerid, TEXT_FAMILY, CreateDynamic3DTextLabel(f_string144, -1, 0.0, 0.0, 0.8, 7.8, playerid));

    cache_delete(cache);
    return 1;   
}

public:CheckMutePlayer()
{
    foreach(new i : Player)
    {
        if(GetPlayerIdFamily(i) == -1) continue;
        else if(!GetPlayerFamily(i, MUTE_FAMILY)) continue;

        player_family[i][MUTE_FAMILY]--;

        if(!player_family[i][MUTE_FAMILY]) SendClientMessage(i, -1, ""c_f_r" Ваш мут в чате семьи истек. Не нарушайте больше!");
    }    

    return 1;
}

stock bool:FamilyIsAllowedNameChar(ch)
{
    if(ch == ' ' || ch == '#' || ch == '-' || ch == '{' || ch == '}' || ch == '[' || ch == ']')
        return true;
    if('0' <= ch <= '9' || 'A' <= ch <= 'Z' || 'a' <= ch <= 'z')
        return true;
    if((0xC0 <= ch <= 0xFF) || ch == 0xA8 || ch == 0xB8)
        return true;
    return false;
}
stock bool:FamilyIsValidName(const source[])
{
    new cp_name[32];
    format(cp_name, sizeof cp_name, "%s", source);
    utf8_to_cp1251(cp_name);
    if(!(4 <= strlen(cp_name) <= 31))
        return false;
    for(new i; cp_name[i] != '\0'; i++)
    {
        if(!FamilyIsAllowedNameChar(cp_name[i]))
            return false;
    }
    return true;
}
stock FamilyShowInvalidNameNotification(playerid)
{
    return ShowNotificationNew(playerid, 2, 6, 0, 0, "Допущены ошибки в символах, используйте А-я, 0-9, #, {], -", " ");
}
stock FamilyCreate(playerid, const source_name[])
{
    new fam_name[32], fam_name_cp[32], free_id = -1;
    format(fam_name, sizeof fam_name, "%s", source_name);
    if(!FamilyIsValidName(fam_name))
        return FamilyShowInvalidNameNotification(playerid);
    for(new i; i < MAX_FAM; i++)
    {
        if(GetFamily(i, family_database) != -1) continue;
        free_id = i;
        break;
    }
    if(free_id == -1)
        return SendClientMessage(playerid, -1, ""c_f_r"На данный момент создать семью нельзя.");
    if(GetPlayerIdFamily(playerid) != -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Вы уже состоите в семье.", " ");
    if(GetPlayerMoneyEx(playerid) < 3_000_000)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Для создания семьи у Вас должно быть 3.000.000 рублей.", " ");
    format(fam_name_cp, sizeof fam_name_cp, "%s", fam_name);
    utf8_to_cp1251(fam_name_cp);
    mysql_format(mysql, f_string144, sizeof f_string144, "SELECT id FROM familynew WHERE name='%e' LIMIT 1", fam_name_cp);
    new Cache:dup_cache = mysql_query(mysql, f_string144, true);
    if(mysql_errno())
    {
        cache_delete(dup_cache);
        return SendClientMessage(playerid, -1, ""c_f_r"Ошибка в SQL-запросе / Code: Check Family Name");
    }
    if(cache_num_rows())
    {
        cache_delete(dup_cache);
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Данное название семьи уже занято.", " ");
    }
    cache_delete(dup_cache);
    mysql_format(mysql, f_string144, sizeof f_string144, "INSERT INTO familynew (owner,name) VALUES ('%d','%e')", GetPlayerAccountID(playerid), fam_name_cp);
    mysql_query(mysql, f_string144, false);
    if(mysql_errno())
        return SendClientMessage(playerid, -1, ""c_f_r"Ошибка в SQL-запросе / Code: Create Family");
    mysql_format(mysql, f_string144, sizeof f_string144, "SELECT * FROM familynew WHERE owner=%d ORDER BY id DESC LIMIT 1", GetPlayerAccountID(playerid));
    new Cache:cache = mysql_query(mysql, f_string144);
    if(mysql_errno())
    {
        cache_delete(cache);
        return printf("[FAMILY SQL #1] LoadFamily %d", mysql_errno());
    }
    if(!cache_num_rows())
    {
        cache_delete(cache);
        return print("None Cache | Query load Family");
    }
    SetFamily(free_id, family_database, cache_get_field_content_int(0, "id"));
    mysql_format(mysql, f_string184, sizeof f_string184, "UPDATE accounts SET family_access = '1,1,1,1,1,1,1',family_id = %d,family_rang = 5 WHERE id= %d", GetFamily(free_id, family_database), GetPlayerAccountID(playerid));
    mysql_query(mysql, f_string184, false);
    if(mysql_errno())
    {
        cache_delete(cache);
        return SendClientMessage(playerid,-1,""c_f_r"Ошибка в SQL-запросе / Code: Update Account Owner Family");
    }
    SetFamily(free_id, family_owner, cache_get_field_content_int(0, "owner"));
    SetFamily(free_id, family_color, cache_get_field_content_int(0, "chatcolor"));
    SetFamily(free_id, family_count_veh, cache_get_field_content_int(0, "slot_veh"));
    SetFamily(free_id, family_reputation, cache_get_field_content_int(0, "reputation"));
    SetFamily(free_id, family_zaxvati, cache_get_field_content_int(0, "zaxvati"));
    SetFamily(free_id, family_moneti, cache_get_field_content_int(0, "moneti"));
    SetFamily(free_id, family_syndicate, cache_get_field_content_int(0, "syndicate"));
    cache_get_field_content(0, "name", GetFamily(free_id, family_name), mysql, 32);
    SetFamily(free_id, family_patron, cache_get_field_content_int(0, "patron"));
    SetFamily(free_id, family_material, cache_get_field_content_int(0, "material"));
    SetFamily(free_id, family_heath_kit, cache_get_field_content_int(0, "heath_kit"));
    SetFamily(free_id, family_armour, cache_get_field_content_int(0, "armour"));
    SetFamily(free_id, family_money, cache_get_field_content_int(0, "money"));
    SetFamily(free_id, family_lvl_storage, cache_get_field_content_int(0, "level_storage"));
    SetFamily(free_id, family_lvl_weapon, cache_get_field_content_int(0, "level_weapon"));
    SetFamily(free_id, family_lvl_compound, cache_get_field_content_int(0, "level_compound"));
    SetFamily(free_id, family_slot_veh, cache_get_field_content_int(0, "slot_veh"));
    new rang[5][24], name[12], setting_1,
    setting_2, setting_3, setting_4, setting_5;
    cache_get_field_content(0, "rang_1", rang[0], mysql, 24);
    cache_get_field_content(0, "rang_2", rang[1], mysql, 24);
    cache_get_field_content(0, "rang_3", rang[2], mysql, 24);
    cache_get_field_content(0, "rang_4", rang[3], mysql, 24);
    cache_get_field_content(0, "rang_5", rang[4], mysql, 24);
    for(new l; l < 5; l++)
    {
        sscanf(rang[l], "P<,>s[12]ddddd", name, setting_1, setting_2, setting_3, setting_4, setting_5);
        format(family_rang_name[free_id][l], 24, name);
        family_rang_dostup[free_id][l][0] = setting_1;
        family_rang_dostup[free_id][l][1] = setting_2;
        family_rang_dostup[free_id][l][2] = setting_3;
        family_rang_dostup[free_id][l][3] = setting_4;
        family_rang_dostup[free_id][l][4] = setting_5;
    }
    cache_delete(cache);
    for(new l; l < 5; l++)
    {
        format(family_rang_name[free_id][l], 24, "%d ранг", l + 1);
        UpdateDostupFamily(free_id, l);
    }
    mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM accounts WHERE family_id=%d", GetFamily(free_id, family_database));
    cache = mysql_query(mysql, f_string64);
    SetFamily(free_id, family_count_people, cache_num_rows());
    cache_delete(cache);
    LoadPlayerFamily(playerid);
    GivePlayerMoneyEx(playerid, -3_000_000);
    // Dialog input arrives as UTF-8, while the server chat and family tables use
    // CP1251. Output the normalized value; printing source_name produces mojibake
    // such as "?..." for Russian family names.
    format(f_string144, sizeof f_string144, "{FFFF00}| {FFFFFF}Вы успешно создали семью: {FFFF00}%s", fam_name_cp);
    SendClientMessage(playerid, -1, f_string144);
    SendClientMessage(playerid, -1, "{FFFF00}| {FFFFFF}Для управление семьей используйте: {FFFF00}/fm");
    ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы потратили 3000000 рублей", " ");
    return 1;
}

// BEGIN INLINED: include/system/family_storage_adapter.pwn
#define FAM_DIALOG_STORAGE_MAIN             (22940)
#define FAM_DIALOG_STORAGE_SAFE             (22942)
#define FAM_DIALOG_STORAGE_SAFE_TAKE        (22943)
#define FAM_DIALOG_STORAGE_SAFE_PUT         (22944)
#define FAM_DIALOG_STORAGE_SAFE_MONEY       (22945)
#define FAM_DIALOG_STORAGE_SAFE_AMMO        (22946)
#define FAM_DIALOG_STORAGE_SAFE_WEAPON      (22947)
#define FAM_DIALOG_STORAGE_SAFE_ARMOUR      (22948)
#define FAM_DIALOG_STORAGE_SAFE_AMMO_INPUT  (22949)

#define FAMILY_SAFE_ACTION_TAKE             (1)
#define FAMILY_SAFE_ACTION_PUT              (2)

#define FAMILY_WAREHOUSE_MAX_SLOTS          (60)
#define FAMILY_WAREHOUSE_MAX_WEIGHT_KG      (1500)
#define FAMILY_SAFE_MAX_MONEY_AMOUNT        (1000000)
#define FAMILY_AMMO_TYPE_COUNT              (7)

#define PVAR_FAMILY_SAFE_MONEY_ACTION       "family_safe_money_action"
#define PVAR_FAMILY_SAFE_AMMO_ACTION        "family_safe_ammo_action"
#define PVAR_FAMILY_SAFE_WEAPON_INDEX       "family_safe_weapon_index"

#define PVAR_FAMILY_WAREHOUSE_GUI           "family_warehouse_gui"
#define PVAR_FAMILY_WAREHOUSE_ID            "family_warehouse_id"

enum E_FAMILY_WAREHOUSE_SLOT
{
    FWS_SQL_ID,
    FWS_ITEM_ID,
    FWS_ITEM_AMOUNT,
    FWS_ITEM_VALUE
};

new g_family_warehouse[MAX_FAM][FAMILY_WAREHOUSE_MAX_SLOTS][E_FAMILY_WAREHOUSE_SLOT];
new g_family_warehouse_item_value[MAX_FAM][FAMILY_WAREHOUSE_MAX_SLOTS];
new bool:g_family_ammo_schema_ready;

#define GetFamilyWarehouseData(%0,%1,%2)   g_family_warehouse[%0][%1][%2]
#define SetFamilyWarehouseData(%0,%1,%2,%3) g_family_warehouse[%0][%1][%2] = %3
#define AddFamilyWarehouseData(%0,%1,%2,%3,%4) g_family_warehouse[%0][%1][%2] %3= %4
#define IsFamilyWarehouseFreeSlot(%0,%1)   !GetFamilyWarehouseData(%0, %1, FWS_SQL_ID)

stock FamilyStorageResetState(playerid)
{
    DeletePVar(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION);
    DeletePVar(playerid, PVAR_FAMILY_SAFE_AMMO_ACTION);
    DeletePVar(playerid, PVAR_FAMILY_SAFE_WEAPON_INDEX);
    return 1;
}

stock FamilyStorageResetWarehouseGui(playerid)
{
    DeletePVar(playerid, PVAR_FAMILY_WAREHOUSE_GUI);
    DeletePVar(playerid, PVAR_FAMILY_WAREHOUSE_ID);
    return 1;
}

stock FamilyStorageIsWarehouseGui(playerid)
{
    return GetPVarInt(playerid, PVAR_FAMILY_WAREHOUSE_GUI) == 1;
}

stock FamilyStorageGetWarehouseFamilyId(playerid)
{
    return GetPVarInt(playerid, PVAR_FAMILY_WAREHOUSE_ID);
}

stock FamilyStorageShowAccessDenied(playerid)
{
    return ShowNotificationNew(playerid, 2, 6, 0, 0, "Вам недоступна данная функция", " ");
}

stock FamilyStorageShowClosed(playerid)
{
    return ShowNotificationNew(playerid, 2, 6, 0, 0, "Сейф закрыт", " ");
}

stock FamilyStorageClampLevel(level)
{
    if(level < 1) return 1;
    if(level > 7) return 7;
    return level;
}

stock FamilyStorageIsValidFamilyId(family_id)
{
    return (family_id >= 0 && family_id < MAX_FAM && GetFamily(family_id, family_database) != -1);
}

stock FamilyStorageEnsureAmmoSchema()
{
    if(g_family_ammo_schema_ready) return 1;

    new Cache:result = mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS family_ammo_storage (family_id INT NOT NULL,weapon_id INT NOT NULL,amount INT NOT NULL DEFAULT 0,PRIMARY KEY(family_id,weapon_id))",
        true);
    if(mysql_errno())
    {
        printf("[FAMILY_STORAGE][AMMO] schema error=%d", mysql_errno());
        cache_delete(result);
        return 0;
    }
    cache_delete(result);
    g_family_ammo_schema_ready = true;
    return 1;
}

stock FamilyStorageGetAmmoTypeByWeapon(weapon_id)
{
    for(new index; index < FAMILY_AMMO_TYPE_COUNT; index++)
        if(count_weapon_level[index] == weapon_id) return index;
    return -1;
}

stock FamilyStorageGetTypedAmmo(family_id, weapon_index)
{
    if(!FamilyStorageIsValidFamilyId(family_id)
        || weapon_index < 0 || weapon_index >= FAMILY_AMMO_TYPE_COUNT
        || !FamilyStorageEnsureAmmoSchema()) return 0;

    new query[192];
    mysql_format(mysql, query, sizeof query,
        "SELECT amount FROM family_ammo_storage WHERE family_id=%d AND weapon_id=%d LIMIT 1",
        GetFamily(family_id, family_database), count_weapon_level[weapon_index]);
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno() || !cache_num_rows())
    {
        cache_delete(result);
        return 0;
    }
    new amount = cache_get_field_content_int(0, "amount");
    cache_delete(result);
    return amount;
}

stock FamilyStorageGetTypedAmmoTotal(family_id)
{
    if(!FamilyStorageIsValidFamilyId(family_id) || !FamilyStorageEnsureAmmoSchema()) return 0;

    new query[160];
    mysql_format(mysql, query, sizeof query,
        "SELECT COALESCE(SUM(amount),0) AS total FROM family_ammo_storage WHERE family_id=%d",
        GetFamily(family_id, family_database));
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno() || !cache_num_rows())
    {
        cache_delete(result);
        return 0;
    }
    new total = cache_get_field_content_int(0, "total");
    cache_delete(result);
    return total;
}

stock FamilyStorageSyncTypedAmmoTotal(family_id)
{
    new total = FamilyStorageGetTypedAmmoTotal(family_id);
    SetFamily(family_id, family_patron, total);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "patron", total);
    return total;
}

stock bool:FamilyStorageAddTypedAmmo(family_id, weapon_index, amount)
{
    if(!FamilyStorageIsValidFamilyId(family_id)
        || weapon_index < 0 || weapon_index >= FAMILY_AMMO_TYPE_COUNT
        || amount <= 0 || !FamilyStorageEnsureAmmoSchema()) return false;

    new query[256];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO family_ammo_storage (family_id,weapon_id,amount) VALUES (%d,%d,%d) ON DUPLICATE KEY UPDATE amount=amount+%d",
        GetFamily(family_id, family_database), count_weapon_level[weapon_index], amount, amount);
    new Cache:result = mysql_query(mysql, query, true);
    new bool:success = mysql_errno() == 0;
    cache_delete(result);
    return success;
}

stock bool:FamilyStorageTakeTypedAmmo(family_id, weapon_index, amount)
{
    if(!FamilyStorageIsValidFamilyId(family_id)
        || weapon_index < 0 || weapon_index >= FAMILY_AMMO_TYPE_COUNT
        || amount <= 0 || !FamilyStorageEnsureAmmoSchema()) return false;

    new query[256];
    mysql_format(mysql, query, sizeof query,
        "UPDATE family_ammo_storage SET amount=amount-%d WHERE family_id=%d AND weapon_id=%d AND amount>=%d",
        amount, GetFamily(family_id, family_database), count_weapon_level[weapon_index], amount);
    new Cache:result = mysql_query(mysql, query, true);
    new bool:success = mysql_errno() == 0 && cache_affected_rows() == 1;
    cache_delete(result);
    return success;
}

stock FamilyStorageGetRankName(playerid, dest[], size)
{
    new family_id = GetPlayerIdFamily(playerid);
    new rank = GetPlayerRangFamily(playerid);

    if(FamilyStorageIsValidFamilyId(family_id) && rank >= 1 && rank <= 5)
        format(dest, size, "%s", family_rang_name[family_id][rank - 1]);
    else
        format(dest, size, "%d ранг", rank);

    return 1;
}

stock FamilyStorageBuildChatText(playerid, action_text[], dest[], size)
{
    new family_id = GetPlayerIdFamily(playerid);
    new rank_name[24];

    FamilyStorageGetRankName(playerid, rank_name, sizeof(rank_name));
    format(dest, size, "%s %s[%d] %s", rank_name, GetPlayerNameEx(playerid), playerid, action_text);
    return 1;
}

stock FamilyStorageGetWarehouseSqlId(family_id)
{
    if(!FamilyStorageIsValidFamilyId(family_id))
        return -1;

    return GetFamily(family_id, family_database);
}

stock FamilyStorageGetPlatePseudoSlot(family_id, slot)
{
    new family_sql_id = FamilyStorageGetWarehouseSqlId(family_id);

    if(family_sql_id <= 0 || slot < 0 || slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return -1;

    return 300000000 + (family_sql_id * 100) + slot;
}

stock FamilyStorageSetWarehouseSlotValue(family_id, slot, value)
{
    g_family_warehouse_item_value[family_id][slot] = value;
    return 1;
}

stock FamilyStorageGetWarehouseSlotValue(family_id, slot)
{
    return g_family_warehouse_item_value[family_id][slot];
}

stock FamilyStorageClearWarehouseCache(family_id)
{
    for(new slot = 0; slot < FAMILY_WAREHOUSE_MAX_SLOTS; slot++)
    {
        SetFamilyWarehouseData(family_id, slot, FWS_SQL_ID, 0);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID, 0);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT, 0);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_VALUE, 0);
        FamilyStorageSetWarehouseSlotValue(family_id, slot, 0);
    }
    return 1;
}

stock FamilyStorageRemoveWarehouseItem(family_id, slot)
{
    if(!FamilyStorageIsValidFamilyId(family_id) || slot < 0 || slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return 0;

    SetFamilyWarehouseData(family_id, slot, FWS_SQL_ID, 0);
    SetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID, 0);
    SetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT, 0);
    SetFamilyWarehouseData(family_id, slot, FWS_ITEM_VALUE, 0);
    FamilyStorageSetWarehouseSlotValue(family_id, slot, 0);
    return 1;
}

stock bool:FamilyStorageIsWarehouseAllowedItem(item_id)
{
    if(item_id == 22 || item_id == INV_ITEM_REPAIR_KIT || item_id == 58 || item_id == 134)
        return true;

    if(Inventory11_IsAccessoryItem(item_id) || Inventory11_IsPlateItem(item_id))
        return true;

    return false;
}

stock bool:FamilyStorageIsStackableItem(item_id)
{
    return (item_id == 22);
}

stock FamilyStorageFindBusySlot(family_id, item_id)
{
    for(new slot = 0; slot < FAMILY_WAREHOUSE_MAX_SLOTS; slot++)
    {
        if(IsFamilyWarehouseFreeSlot(family_id, slot))
            continue;

        if(GetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID) == item_id)
            return slot;
    }
    return -1;
}

stock FamilyStorageLoadWarehouse(playerid, family_id)
{
    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    new family_sql_id = FamilyStorageGetWarehouseSqlId(family_id);
    if(family_sql_id <= 0)
        return 0;

    FamilyStorageClearWarehouseCache(family_id);

    new query[196];
    mysql_format(mysql, query, sizeof(query), "SELECT slot, item_id, amount, value FROM family_storage_items WHERE family_id = %d ORDER BY slot ASC", family_sql_id);
    new Cache:result = mysql_query(mysql, query, true);

    if(mysql_errno())
    {
        printf("[FAMILY_STORAGE][ERROR] load failed: player=%d family=%d sql=%d errno=%d query=%s", playerid, family_id, family_sql_id, mysql_errno(), query);
        cache_delete(result);
        return 0;
    }

    new rows = cache_num_rows();
    for(new i = 0; i < rows; i++)
    {
        new slot = cache_get_field_content_int(i, "slot");
        if(slot < 0 || slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
            continue;

        new item_id = cache_get_field_content_int(i, "item_id");
        new amount = cache_get_field_content_int(i, "amount");
        new value = cache_get_field_content_int(i, "value");

        if(!FamilyStorageIsWarehouseAllowedItem(item_id))
            continue;

        if(amount <= 0)
            amount = 1;

        SetFamilyWarehouseData(family_id, slot, FWS_SQL_ID, 1);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID, item_id);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT, amount);
        SetFamilyWarehouseData(family_id, slot, FWS_ITEM_VALUE, value);
        FamilyStorageSetWarehouseSlotValue(family_id, slot, value);
    }

    cache_delete(result);
    return 1;
}

stock bool:FamilyStorageSaveWarehouseSlot(playerid, family_id, slot)
{
    if(!FamilyStorageIsValidFamilyId(family_id) || slot < 0 || slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return false;

    new family_sql_id = FamilyStorageGetWarehouseSqlId(family_id);
    if(family_sql_id <= 0)
        return false;

    new plate_pseudo_slot = FamilyStorageGetPlatePseudoSlot(family_id, slot);
    new query[320];

    if(IsFamilyWarehouseFreeSlot(family_id, slot))
    {
        mysql_format(mysql, query, sizeof(query), "DELETE FROM family_storage_items WHERE family_id = %d AND slot = %d", family_sql_id, slot);
        mysql_query(mysql, query, true);

        if(mysql_errno())
        {
            printf("[FAMILY_STORAGE][ERROR] delete failed: player=%d family=%d slot=%d errno=%d query=%s", playerid, family_id, slot, mysql_errno(), query);
            return false;
        }

        if(plate_pseudo_slot > 0)
            Inventory11_DeletePlateData(playerid, plate_pseudo_slot);

        return true;
    }

    new item_id = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID);
    new amount = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT);
    new value = FamilyStorageGetWarehouseSlotValue(family_id, slot);

    if(amount <= 0)
        amount = 1;

    if(!Inventory11_IsPlateItem(item_id) && plate_pseudo_slot > 0)
        Inventory11_DeletePlateData(playerid, plate_pseudo_slot);

    mysql_format
    (
        mysql,
        query,
        sizeof(query),
        "INSERT INTO family_storage_items (family_id, slot, item_id, amount, value) VALUES (%d, %d, %d, %d, %d) ON DUPLICATE KEY UPDATE item_id = VALUES(item_id), amount = VALUES(amount), value = VALUES(value)",
        family_sql_id,
        slot,
        item_id,
        amount,
        value
    );
    mysql_query(mysql, query, true);

    if(mysql_errno())
    {
        printf("[FAMILY_STORAGE][ERROR] upsert failed: player=%d family=%d slot=%d errno=%d query=%s", playerid, family_id, slot, mysql_errno(), query);
        return false;
    }

    return true;
}

stock FamilyStorageWhWeightX10(family_id)
{
    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    new total_weight_x10 = 0;

    for(new slot = 0; slot < FAMILY_WAREHOUSE_MAX_SLOTS; slot++)
    {
        if(IsFamilyWarehouseFreeSlot(family_id, slot))
            continue;

        new item_id = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID);
        new amount = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT);

        if(amount <= 0)
            amount = 1;

        new item_weight_x10 = InventoryCfg_GetItemWeightX10(item_id);
        if(item_weight_x10 <= 0)
            item_weight_x10 = 10;

        if(FamilyStorageIsStackableItem(item_id))
            total_weight_x10 += item_weight_x10 * amount;
        else
            total_weight_x10 += item_weight_x10;
    }

    return total_weight_x10;
}

stock FamilyStorageWhWeightKg(family_id)
{
    return (FamilyStorageWhWeightX10(family_id) + 9) / 10;
}

stock FamilyStorageBuildWarehouseJson(playerid, family_id, out_json[], out_size)
{
    format(out_json, out_size, "[");

    new loaded = 0;

    for(new slot = 0; slot < FAMILY_WAREHOUSE_MAX_SLOTS; slot++)
    {
        if(IsFamilyWarehouseFreeSlot(family_id, slot))
            continue;

        new item_id = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_ID);
        new amount = GetFamilyWarehouseData(family_id, slot, FWS_ITEM_AMOUNT);
        new value = FamilyStorageGetWarehouseSlotValue(family_id, slot);

        if(amount <= 0 || !FamilyStorageIsWarehouseAllowedItem(item_id))
            continue;

        new model_id = TrunkTest_GetDisplayModelForTrunkItem(item_id, amount, value);
        new extra_1 = 0;
        new extra_2 = 0;

        if(Inventory11_IsPlateItem(item_id))
        {
            new plate_slot_key = FamilyStorageGetPlatePseudoSlot(family_id, slot);
            new plate_type = PlateCountryToType(PlateItemIdToCountry(item_id));
            new plate[16], region[8], plate_text[32];

            if(plate_slot_key > 0 && Inventory11_GetPlateData(playerid, plate_slot_key, plate_type, plate, sizeof(plate), region, sizeof(region)))
            {
                Inv11Trade_BuildPlateText(plate_type, plate, region, plate_text, sizeof(plate_text));
                Inventory11_AppendPlateItemToJson(out_json, out_size, PlateTypeToItemId(plate_type), plate_text, slot);
                loaded++;
                continue;
            }
        }

        if(Inventory11_IsAccessoryItem(item_id))
        {
            extra_1 = (value > 0) ? value : Inv11_GetAccModelByItem(item_id);
            if(extra_1 <= 0) extra_1 = item_id;
            model_id = 1;
        }
        else if(item_id == 58)
        {
            extra_1 = (value > 0) ? value : model_id;
        }

        Inventory11_AppendItemToJson(out_json, out_size, item_id, model_id, slot, extra_1, extra_2);
        loaded++;
    }

    new len = strlen(out_json);
    if(len > 1 && out_json[len - 1] == ',')
        out_json[len - 1] = '\0';

    strcat(out_json, "]", out_size);
    return loaded;
}

stock FamilyStorageOpenWarehouseGui(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    if(GetPlayerRangFamily(playerid) != 5)
        return FamilyStorageShowAccessDenied(playerid);

    if(!FamilyStorageLoadWarehouse(playerid, family_id))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Не удалось открыть склад семьи", " ");

    new Node:JSONObject = JSON_Object();
    new it_json[8192];
    new ic_json[4096];

    TrunkTest_BuildInventoryJson(playerid, it_json, sizeof(it_json));
    FamilyStorageBuildWarehouseJson(playerid, family_id, ic_json, sizeof(ic_json));

    new Node:itArray = JSON_Array();
    JSON_Parse(it_json, itArray);
    JSON_SetArray(JSONObject, "it", itArray);

    new Node:icArray = JSON_Array();
    JSON_Parse(ic_json, icArray);
    JSON_SetArray(JSONObject, "ic", icArray);

    JSON_SetInt(JSONObject, "tb", 2);
    JSON_SetInt(JSONObject, "w", Inventory11_GetCurrentWeightKg(playerid));
    JSON_SetInt(JSONObject, "mw", Inventory11_GetMaxWeightKg(playerid));
    JSON_SetInt(JSONObject, "bw", FamilyStorageWhWeightKg(family_id));
    JSON_SetInt(JSONObject, "cw", FAMILY_WAREHOUSE_MAX_WEIGHT_KG);
    JSON_SetInt(JSONObject, "sl", Inventory11_GetMaxSlots(playerid));
    JSON_SetInt(JSONObject, "sb", FAMILY_WAREHOUSE_MAX_SLOTS);
    JSON_SetInt(JSONObject, "nm", GetPlayerPhone(playerid));

    Inventory11_SetAiArrayOnJson(playerid, JSONObject);

    SetPVarInt(playerid, PVAR_FAMILY_WAREHOUSE_GUI, 1);
    SetPVarInt(playerid, PVAR_FAMILY_WAREHOUSE_ID, family_id);

    DeletePVar(playerid, PVAR_TRUNKTEST_VEHICLE);
    ShowPlayerGUI(playerid, GUICarsTrunkOrCloset, JSONObject);
    JSON_Cleanup(JSONObject);
    return 1;
}

stock bool:FamilyStorageMoveInventoryToWarehouse(playerid, family_id, req_item_id, old_slot, new_slot, req_value)
{
    if(new_slot < 0 || new_slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return false;

    if(!FamilyStorageLoadWarehouse(playerid, family_id))
        return false;

    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0)
        return false;

    new query[320];
    mysql_format(mysql, query, sizeof(query), "SELECT item_id, model_id, amount, extra_1, extra_2, old_skin FROM inventory WHERE account_id = %d AND slot = %d LIMIT 1", account_id, old_slot);
    new Cache:result = mysql_query(mysql, query, true);

    if(mysql_errno())
    {
        printf("[FAMILY_STORAGE][ERROR] inv->storage select failed: player=%d slot=%d errno=%d query=%s", playerid, old_slot, mysql_errno(), query);
        cache_delete(result);
        return false;
    }

    if(cache_num_rows() <= 0)
    {
        cache_delete(result);
        return false;
    }

    new item_id = cache_get_field_content_int(0, "item_id");
    new model_id = cache_get_field_content_int(0, "model_id");
    new amount = cache_get_field_content_int(0, "amount");
    new extra_1 = cache_get_field_content_int(0, "extra_1");
    new extra_2 = cache_get_field_content_int(0, "extra_2");
    new old_skin = cache_get_field_content_int(0, "old_skin");
    cache_delete(result);

    if(req_item_id > 0 && req_item_id != item_id)
        printf("[FAMILY_STORAGE][WARN] inv->storage item mismatch: player=%d req=%d db=%d slot=%d", playerid, req_item_id, item_id, old_slot);

    if(!FamilyStorageIsWarehouseAllowedItem(item_id))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Этот предмет нельзя положить на склад семьи", " ");
        return false;
    }

    if(amount <= 0)
        amount = 1;

    new bool:is_stackable = FamilyStorageIsStackableItem(item_id);
    new move_amount = req_value;

    if(!is_stackable)
    {
        move_amount = 1;
    }
    else
    {
        if(move_amount <= 0) move_amount = 1;
        if(move_amount > amount) move_amount = amount;
        if(move_amount <= 0) return false;
    }

    new item_weight_x10 = InventoryCfg_GetItemWeightX10(item_id);
    if(item_weight_x10 <= 0) item_weight_x10 = 10;

    new add_weight_x10 = item_weight_x10 * (is_stackable ? move_amount : 1);
    if(FamilyStorageWhWeightX10(family_id) + add_weight_x10 > (FAMILY_WAREHOUSE_MAX_WEIGHT_KG * 10))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Недостаточно места на складе семьи", " ");
        return false;
    }

    new item_value = TrunkTest_GetItemValueFromInventoryData(item_id, model_id, amount, extra_1, old_skin);
    new target_slot = new_slot;

    new storage_plate_slot = -1;
    new storage_plate_type = TYPE_RU;
    new storage_plate[16], storage_region[8];
    storage_plate[0] = '\0';
    storage_region[0] = '\0';
    new bool:has_storage_plate = false;

    if(Inventory11_IsPlateItem(item_id))
    {
        storage_plate_slot = FamilyStorageGetPlatePseudoSlot(family_id, target_slot);
        has_storage_plate = Inventory11_GetPlateData(playerid, old_slot, storage_plate_type, storage_plate, sizeof(storage_plate), storage_region, sizeof(storage_region));
    }

    if(is_stackable)
    {
        new busy_slot = FamilyStorageFindBusySlot(family_id, item_id);

        if(busy_slot != -1 && busy_slot != new_slot)
        {
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Выберите другой слот склада", " ");
            return false;
        }

        if(busy_slot == -1 && !IsFamilyWarehouseFreeSlot(family_id, new_slot))
        {
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Слот склада уже занят", " ");
            return false;
        }

        if(busy_slot != -1)
        {
            target_slot = busy_slot;
            AddFamilyWarehouseData(family_id, target_slot, FWS_ITEM_AMOUNT, +, move_amount);

            if(FamilyStorageGetWarehouseSlotValue(family_id, target_slot) <= 0 && item_value > 0)
            {
                FamilyStorageSetWarehouseSlotValue(family_id, target_slot, item_value);
                SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_VALUE, item_value);
            }
        }
        else
        {
            SetFamilyWarehouseData(family_id, target_slot, FWS_SQL_ID, 1);
            SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_ID, item_id);
            SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_AMOUNT, move_amount);
            SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_VALUE, item_value);
            FamilyStorageSetWarehouseSlotValue(family_id, target_slot, item_value);
        }
    }
    else
    {
        if(!IsFamilyWarehouseFreeSlot(family_id, target_slot))
        {
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Слот склада уже занят", " ");
            return false;
        }

        SetFamilyWarehouseData(family_id, target_slot, FWS_SQL_ID, 1);
        SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_ID, item_id);
        SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_AMOUNT, 1);
        SetFamilyWarehouseData(family_id, target_slot, FWS_ITEM_VALUE, item_value);
        FamilyStorageSetWarehouseSlotValue(family_id, target_slot, item_value);
    }

    if(!FamilyStorageSaveWarehouseSlot(playerid, family_id, target_slot))
        return false;

    if(Inventory11_IsPlateItem(item_id) && storage_plate_slot > 0 && has_storage_plate)
    {
        if(!Inventory11_SavePlateData(playerid, storage_plate_slot, storage_plate_type, storage_plate, storage_region))
        {
            printf("[FAMILY_STORAGE][ERROR] inv->storage save plate failed: player=%d family=%d slot=%d", playerid, family_id, target_slot);
            return false;
        }
    }

    if(is_stackable && amount > move_amount)
    {
        new left_amount = amount - move_amount;
        if(left_amount < 1) left_amount = 1;

        mysql_format(mysql, query, sizeof(query), "UPDATE inventory SET amount = %d, model_id = %d WHERE account_id = %d AND slot = %d LIMIT 1", left_amount, left_amount, account_id, old_slot);
        mysql_query(mysql, query, true);

        if(mysql_errno())
        {
            printf("[FAMILY_STORAGE][ERROR] inv->storage update inventory amount failed: player=%d slot=%d errno=%d query=%s", playerid, old_slot, mysql_errno(), query);
            return false;
        }
    }
    else if(!Inventory11_DeleteSlotFromDatabase(playerid, old_slot))
    {
        printf("[FAMILY_STORAGE][ERROR] inv->storage delete inventory slot failed: player=%d slot=%d", playerid, old_slot);
        return false;
    }

    return true;
}

stock bool:FamilyStorageMoveWarehouseToInventory(playerid, family_id, old_slot, new_slot, req_item_id, req_value)
{
    if(old_slot < 0 || old_slot >= FAMILY_WAREHOUSE_MAX_SLOTS)
        return false;

    if(new_slot < 1 || new_slot > Inventory11_GetMaxSlots(playerid))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Нету мест в инвентаре", " ");
        return false;
    }

    if(!FamilyStorageLoadWarehouse(playerid, family_id))
        return false;

    if(IsFamilyWarehouseFreeSlot(family_id, old_slot))
        return false;

    if(TrunkTest_IsInventorySlotBusy(playerid, new_slot))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Выберите другой слот в инвентаре", " ");
        return false;
    }

    new item_id = GetFamilyWarehouseData(family_id, old_slot, FWS_ITEM_ID);
    if(!FamilyStorageIsWarehouseAllowedItem(item_id))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Этот предмет нельзя взять со склада семьи", " ");
        return false;
    }

    if(req_item_id > 0 && req_item_id != item_id)
        printf("[FAMILY_STORAGE][WARN] storage->inv item mismatch: player=%d req=%d db=%d slot=%d", playerid, req_item_id, item_id, old_slot);

    new amount = GetFamilyWarehouseData(family_id, old_slot, FWS_ITEM_AMOUNT);
    if(amount <= 0)
        return false;

    new bool:is_stackable = FamilyStorageIsStackableItem(item_id);
    new move_amount = req_value;

    if(!is_stackable)
    {
        move_amount = 1;
    }
    else
    {
        if(move_amount <= 0) move_amount = 1;
        if(move_amount > amount) move_amount = amount;
        if(move_amount <= 0) return false;
    }

    new item_value = FamilyStorageGetWarehouseSlotValue(family_id, old_slot);
    if(item_value <= 0)
        item_value = GetFamilyWarehouseData(family_id, old_slot, FWS_ITEM_VALUE);

    new storage_plate_slot = -1;
    new storage_plate_type = TYPE_RU;
    new storage_plate[16], storage_region[8];
    storage_plate[0] = '\0';
    storage_region[0] = '\0';
    new bool:has_storage_plate = false;

    if(Inventory11_IsPlateItem(item_id))
    {
        storage_plate_slot = FamilyStorageGetPlatePseudoSlot(family_id, old_slot);
        if(storage_plate_slot > 0)
            has_storage_plate = Inventory11_GetPlateData(playerid, storage_plate_slot, storage_plate_type, storage_plate, sizeof(storage_plate), storage_region, sizeof(storage_region));
    }

    new model_id = TrunkTest_GetDisplayModelForTrunkItem(item_id, move_amount, item_value);
    new extra_1 = 0;
    new old_skin = 0;

    if(Inventory11_IsAccessoryItem(item_id))
    {
        extra_1 = (item_value > 0) ? item_value : Inv11_GetAccModelByItem(item_id);
        if(extra_1 <= 0) extra_1 = item_id;
        model_id = 1;
        move_amount = 1;
    }
    else if(item_id == 58)
    {
        model_id = (item_value > 0) ? item_value : model_id;
        if(model_id <= 0) model_id = 1;
        extra_1 = model_id;
        move_amount = 1;
    }
    else if(item_id == 134)
    {
        old_skin = (item_value > 0) ? item_value : model_id;
        if(old_skin <= 0) old_skin = model_id;
        if(model_id <= 0) model_id = old_skin;
        move_amount = 1;
    }
    else if(Inventory11_IsPlateItem(item_id))
    {
        if(model_id <= 0) model_id = PlateItemIdToModel(item_id);
        move_amount = 1;
    }

    if(!Inventory11_CanAddItemWeight(playerid, item_id, move_amount))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Нету мест в инвентаре", " ");
        return false;
    }

    if(!TrunkTest_InsertInventoryItemAtSlot(playerid, new_slot, item_id, model_id, move_amount, extra_1, 0, old_skin))
        return false;

    if(Inventory11_IsPlateItem(item_id) && has_storage_plate)
    {
        if(!Inventory11_SavePlateData(playerid, new_slot, storage_plate_type, storage_plate, storage_region))
        {
            printf("[FAMILY_STORAGE][ERROR] storage->inv save plate failed: player=%d family=%d slot=%d", playerid, family_id, old_slot);
            return false;
        }
    }

    new left_amount = amount - move_amount;
    if(left_amount <= 0)
    {
        FamilyStorageRemoveWarehouseItem(family_id, old_slot);

        if(Inventory11_IsPlateItem(item_id) && storage_plate_slot > 0)
            Inventory11_DeletePlateData(playerid, storage_plate_slot);
    }
    else
    {
        SetFamilyWarehouseData(family_id, old_slot, FWS_ITEM_AMOUNT, left_amount);
    }

    if(!FamilyStorageSaveWarehouseSlot(playerid, family_id, old_slot))
        return false;

    return true;
}

stock FamilyStorageHandleWarehouseSlotToInventory(playerid, type, ga, os, ns, family_id, Node:resp)
{
    new slot_item = ga;
    new active_slot = os;
    new target_slot = ns;
    new bool:ok = false;

    if(slot_item == 134 || slot_item == 122)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Нельзя снять одежду", " ");
    }
    else if(!Inventory11_IsAccessoryItem(slot_item))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Неверный аксессуар", " ");
    }
    else
    {
        if(active_slot == 0)
            active_slot = 1;

        if(active_slot < 1 || active_slot > INVENTORY11_MAX_ACTIVE_ACCESSORIES)
            active_slot = 1;

        if(target_slot < 1 || target_slot > Inventory11_GetMaxSlots(playerid))
            target_slot = TrunkTest_GetFreeInventorySlot(playerid);

        if(target_slot == -1)
        {
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Нету мест в инвентаре", " ");
        }
        else
        {
            new item_weight_x10 = InventoryCfg_GetItemWeightX10(slot_item);
            if(item_weight_x10 <= 0) item_weight_x10 = 10;

            if(Inventory11_GetCurrentWeightX10(playerid) + item_weight_x10 > (Inventory11_GetMaxWeightKg(playerid) * 10))
            {
                ShowNotificationNew(playerid, 2, 6, 0, 0, "Нету мест в инвентаре", " ");
            }
            else
            {
                new moved_model = 0;
                new used_slot = active_slot;

                if(Inventory11_MoveActiveAccessoryToInventorySlot(playerid, slot_item, used_slot, target_slot, moved_model))
                {
                    ok = true;
                }
                else
                {
                    for(new candidate_slot = 1; candidate_slot <= INVENTORY11_MAX_ACTIVE_ACCESSORIES; candidate_slot++)
                    {
                        if(candidate_slot == used_slot) continue;
                        if(!Inventory11_MoveActiveAccessoryToInventorySlot(playerid, slot_item, candidate_slot, target_slot, moved_model)) continue;
                        used_slot = candidate_slot;
                        ok = true;
                        break;
                    }

                    if(!ok)
                        ShowNotificationNew(playerid, 2, 6, 0, 0, "Аксессуар не надет", " ");
                }
            }
        }
    }

    JSON_SetInt(resp, "t", type);
    JSON_SetInt(resp, "s", ok ? 1 : 0);

    if(ok)
    {
        JSON_SetInt(resp, "w", Inventory11_GetCurrentWeightKg(playerid));
        JSON_SetInt(resp, "bw", FamilyStorageWhWeightKg(family_id));
    }

    OnPacketIncoming(playerid, 34, resp);
    return ok;
}

stock FamilyStorageHandleInventoryPacket(playerid, Node:json)
{
    if(!FamilyStorageIsWarehouseGui(playerid))
        return 0;

    new family_id = FamilyStorageGetWarehouseFamilyId(playerid);
    if(!FamilyStorageIsValidFamilyId(family_id))
    {
        FamilyStorageResetWarehouseGui(playerid);
        return 1;
    }

    if(GetPlayerRangFamily(playerid) != 5)
    {
        HidePlayerGUI(playerid, GUICarsTrunkOrCloset);
        FamilyStorageResetWarehouseGui(playerid);
        FamilyStorageShowAccessDenied(playerid);
        return 1;
    }

    new type = -1;
    JSON_GetInt(json, "t", type);

    if(type == 8)
    {
        // Client can send t=8 during internal GUI refresh; keep family warehouse context.
        return 1;
    }

    if(type == 3 || type == 4 || type == 5 || type == 6 || type == 7)
        return 1;

    new ga = 0, os = -1, ns = -1, value = 0;
    JSON_GetInt(json, "ga", ga);
    JSON_GetInt(json, "os", os);
    JSON_GetInt(json, "ns", ns);
    JSON_GetInt(json, "v", value);

    if(ns == -1)
        JSON_GetInt(json, "s", ns);

    new bool:ok = false;
    new Node:resp = JSON_Object();

    switch(type)
    {
        case 0: ok = FamilyStorageMoveInventoryToWarehouse(playerid, family_id, ga, os, ns, value);
        case 1: ok = FamilyStorageMoveWarehouseToInventory(playerid, family_id, os, ns, ga, value);
        case 2, 9:
        {
            ok = FamilyStorageHandleWarehouseSlotToInventory(playerid, type, ga, os, ns, family_id, resp);
            JSON_Cleanup(resp);

            if(ok)
                FamilyStorageOpenWarehouseGui(playerid);

            return 1;
        }
        default:
        {
            JSON_SetInt(resp, "t", type);
            JSON_SetInt(resp, "s", 0);
            OnPacketIncoming(playerid, 34, resp);
            JSON_Cleanup(resp);
            return 1;
        }
    }

    JSON_SetInt(resp, "t", type);
    JSON_SetInt(resp, "s", ok ? 1 : 0);

    if(ok)
    {
        JSON_SetInt(resp, "w", Inventory11_GetCurrentWeightKg(playerid));
        JSON_SetInt(resp, "bw", FamilyStorageWhWeightKg(family_id));
    }

    OnPacketIncoming(playerid, 34, resp);
    JSON_Cleanup(resp);

    if(ok)
        FamilyStorageOpenWarehouseGui(playerid);

    return 1;
}

stock FamilyStorageShowSettingsDialog(playerid)
{
    DeletePVar(playerid, "select_get_dostup");

    ShowPlayerDialog
    (
        playerid, 2230, DIALOG_STYLE_LIST,
        "{E0584B}Настройки склада",
        "1. Выдать доступ\n"\
        "2. Забрать доступ\n"\
        "3. Просмотр доступов",
        "Далее", "Назад"
    );
    return 1;
}

stock FamilyStorageShowAccessInfo(playerid)
{
    new text[512];

    if(GetPlayerRangFamily(playerid) == 5)
    {
        format(text, sizeof(text), "{FFFFFF}Как лидеру семьи Вам доступны все действия со складом и сейфом без ограничений.");
    }
    else
    {
        format
        (
            text, sizeof(text),
            "{FFFFFF}Изменение доступов: %s\n"\
            "{FFFFFF}Деньги: %d\n"\
            "{FFFFFF}Патроны: %d\n"\
            "{FFFFFF}Бронежилеты: %d\n"\
            "{FFFFFF}Материалы: %d\n"\
            "{FFFFFF}Аптечки: %d\n"\
            "{FFFFFF}Маски: %d",
            GetPlayerFamily(playerid, ACCESS_GIVE) ? ("{66CC66}Доступно") : ("{FF6666}Недоступно"),
            GetPlayerFamily(playerid, ACCESS_MONEY),
            GetPlayerFamily(playerid, ACCESS_PATRON),
            GetPlayerFamily(playerid, ACCESS_ARMOUR),
            GetPlayerFamily(playerid, ACCESS_MATERIAL),
            GetPlayerFamily(playerid, ACCESS_HEATH_KIT),
            GetPlayerFamily(playerid, ACCESS_MASK)
        );
    }

    ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, "{E0584B}Мои доступы на складе", text, "Закрыть", "");
    return 1;
}

stock FamilyStorageShowMainDialog(playerid)
{
    new text[256];

    FamilyStorageResetState(playerid);

    if(GetPlayerRangFamily(playerid) == 5)
    {
        format
        (
            text, sizeof(text),
            "1. Склад\n"\
            "2. Сейф\n"\
            "3. Мои доступы на складе\n"\
            "4. Настройки склада"
        );
    }
    else
    {
        format
        (
            text, sizeof(text),
            "1. Склад\n"\
            "2. Сейф\n"\
            "3. Мои доступы на складе"
        );
    }

    ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_MAIN, DIALOG_STYLE_LIST, "{E0584B}Хранилище семьи", text, "Далее", "Выйти");
    return 1;
}

stock FamilyStorageShowSafeDialog(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new text[256];

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    format
    (
        text, sizeof(text),
        "%s\n"\
        "1. Взять\n"\
        "2. Положить\n"\
        "3. Доступы",
        GetFamily(family_id, family_status_storage) ? ("{33CC66}| {FFFFFF}Сейф {33CC66}Открыть") : ("{E0584B}| {FFFFFF}Сейф {E0584B}Закрыть")
    );

    ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE, DIALOG_STYLE_LIST, "{E0584B}Сейф", text, "Далее", "Выйти");
    return 1;
}

stock FamilyStorageShowSafeTakeDialog(playerid)
{
    ShowPlayerDialog
    (
        playerid, FAM_DIALOG_STORAGE_SAFE_TAKE, DIALOG_STYLE_LIST,
        "{E0584B}Взять предмет из сейфа",
        "{FFFF00}|{FFFF00} {FFFFFF}Деньги\n"\
        "{FFFF00}|{FFFF00} {FFFFFF}Патроны\n"\
        "{FFFF00}|{FFFF00} {FFFFFF}Бронежилет",
        "Далее", "Отмена"
    );
    return 1;
}

stock FamilyStorageShowSafePutDialog(playerid)
{
    ShowPlayerDialog
    (
        playerid, FAM_DIALOG_STORAGE_SAFE_PUT, DIALOG_STYLE_LIST,
        "{E0584B}Положить предмет в сейф",
        "{FFFF00}|{FFFF00} {FFFFFF}Деньги\n"\
        "{FFFF00}|{FFFF00} {FFFFFF}Патроны\n"\
        "{FFFF00}|{FFFF00} {FFFFFF}Бронежилет",
        "Далее", "Отмена"
    );
    return 1;
}

stock FamilyStorageShowAmmoActionDialog(playerid, action_type)
{
    SetPVarInt(playerid, PVAR_FAMILY_SAFE_AMMO_ACTION, action_type);

    ShowPlayerDialog
    (
        playerid, FAM_DIALOG_STORAGE_SAFE_AMMO, DIALOG_STYLE_LIST,
        action_type == FAMILY_SAFE_ACTION_TAKE ? "{E0584B}Взять оружие" : "{E0584B}Положить оружие",
        action_type == FAMILY_SAFE_ACTION_TAKE ?
        ("{FFFFFF}1. Информация\n{FFFFFF}2. Взять") :
        ("{FFFFFF}1. Информация\n{FFFFFF}2. Положить"),
        "Далее", "Выйти"
    );
    return 1;
}

stock FamilyStorageShowAmmoInfo(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new text[512], row[64];

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    format(text, sizeof(text), "{FFFFFF}Боеприпасы хранятся отдельно по типам:\n\n");
    for(new index; index < FAMILY_AMMO_TYPE_COUNT; index++)
    {
        format(row, sizeof row, "%s: {FFFF00}%d ??.{FFFFFF}\n",
            name_weapon_family[index], FamilyStorageGetTypedAmmo(family_id, index));
        strcat(text, row);
    }

    ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, "{E0584B}Информация о патронах", text, "Закрыть", "");
    return 1;
}

stock FamilyStorageShowWeaponDialog(playerid)
{
    ShowPlayerDialog
    (
        playerid, FAM_DIALOG_STORAGE_SAFE_WEAPON, DIALOG_STYLE_LIST,
        "{E0584B}Выберите оружие",
        "1. Desert Eagle\n"\
        "2. AK-47\n"\
        "3. MP5\n"\
        "4. Shotgun\n"\
        "5. Country Rifle\n"\
        "6. Sniper Rifle\n"\
        "7. M4",
        "Выбрать", "Отмена"
    );
    return 1;
}

stock FamilyStorageHasTakeAccess(playerid, access_type, amount)
{
    if(GetPlayerRangFamily(playerid) == 5)
        return 1;

    switch(access_type)
    {
        case ACCESS_MONEY:  return GetPlayerFamily(playerid, ACCESS_MONEY) >= amount;
        case ACCESS_PATRON: return GetPlayerFamily(playerid, ACCESS_PATRON) >= amount;
        case ACCESS_ARMOUR: return GetPlayerFamily(playerid, ACCESS_ARMOUR) >= amount;
    }

    return 0;
}

stock FamilyStorageConsumeAccess(playerid, access_type, amount)
{
    if(GetPlayerRangFamily(playerid) == 5)
        return 1;

    AddPlayerFamily(playerid, access_type, -, amount);
    UpdateAccessPlayerFamily(playerid);
    return 1;
}

stock FamilyStorageHandleTakeMoney(playerid, amount)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200], action_text[96], notif_text[96];

    if(!FamilyStorageIsValidFamilyId(family_id) || amount <= 0)
        return 0;

    if(amount > FAMILY_SAFE_MAX_MONEY_AMOUNT)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Можно взять от 1 до 1000000 рублей.", " ");

    if(GetFamily(family_id, family_money) < amount)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "В сейфе недостаточно денег", " ");

    if(!FamilyStorageHasTakeAccess(playerid, ACCESS_MONEY, amount))
        return FamilyStorageShowAccessDenied(playerid);

    FamilyStorageConsumeAccess(playerid, ACCESS_MONEY, amount);
    AddFamily(family_id, family_money, -, amount);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "money", GetFamily(family_id, family_money));
    GivePlayerMoneyEx(playerid, amount, "Сейф семьи", true, true);

    format(action_text, sizeof(action_text), "взял %d рублей.", amount);
    FamilyStorageBuildChatText(playerid, action_text, chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_money, playerid, -1, chat_text);

    format(notif_text, sizeof(notif_text), "Вы получили %d рублей", amount);
    ShowNotificationNew(playerid, 3, 6, 0, 0, notif_text, " ");
    return 1;
}

stock FamilyStorageHandlePutMoney(playerid, amount)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200], action_text[96], notif_text[96];
    new limit, limit_text[96];

    if(!FamilyStorageIsValidFamilyId(family_id) || amount <= 0)
        return 0;

    if(amount > FAMILY_SAFE_MAX_MONEY_AMOUNT)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Можно положить от 1 до 1000000 рублей.", " ");

    if(GetPlayerMoneyEx(playerid) < amount)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас недостаточно денег", " ");

    limit = count_money_level[FamilyStorageClampLevel(GetFamily(family_id, family_lvl_storage)) - 1];
    if((GetFamily(family_id, family_money) + amount) > limit)
    {
        format(limit_text, sizeof(limit_text), "Сейф переполнен, можно хранить %d рублей", limit);
        return ShowNotificationNew(playerid, 2, 6, 0, 0, limit_text, " ");
    }

    AddFamily(family_id, family_money, +, amount);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "money", GetFamily(family_id, family_money));
    GivePlayerMoneyEx(playerid, -amount, "Пополнение сейфа семьи", true, true);

    format(action_text, sizeof(action_text), "положил %d рублей.", amount);
    FamilyStorageBuildChatText(playerid, action_text, chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_money, playerid, -1, chat_text);

    format(notif_text, sizeof(notif_text), "Вы положили %d рублей", amount);
    ShowNotificationNew(playerid, 2, 6, 0, 0, notif_text, " ");
    return 1;
}

stock FamilyStorageHandleTakeArmour(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200];

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    if(GetFamily(family_id, family_armour) < 1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "В сейфе нет бронежилетов", " ");

    if(!FamilyStorageHasTakeAccess(playerid, ACCESS_ARMOUR, 1))
        return FamilyStorageShowAccessDenied(playerid);

    FamilyStorageConsumeAccess(playerid, ACCESS_ARMOUR, 1);
    AddFamily(family_id, family_armour, -, 1);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "armour", GetFamily(family_id, family_armour));
    SetPlayerArmour(playerid, 100.0);

    FamilyStorageBuildChatText(playerid, "взял бронежилет.", chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_armour, playerid, -1, chat_text);
    ShowNotificationNew(playerid, 3, 6, 0, 0, "Вы получили бронежилет", " ");
    return 1;
}

stock FamilyStorageHandlePutArmour(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200];
    new limit;
    new Float:armour;

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    GetPlayerArmour(playerid, armour);
    if(armour < 20.0)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет бронежилета", " ");

    limit = count_armour_level[FamilyStorageClampLevel(GetFamily(family_id, family_lvl_storage)) - 1];
    if((GetFamily(family_id, family_armour) + 1) > limit)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Превышен лимит сейфа", " ");

    AddFamily(family_id, family_armour, +, 1);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "armour", GetFamily(family_id, family_armour));
    SetPlayerArmour(playerid, 0.0);

    FamilyStorageBuildChatText(playerid, "положил бронежилет.", chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_armour, playerid, -1, chat_text);
    ShowNotificationNew(playerid, 3, 6, 0, 0, "Вы положили бронежилет", " ");
    return 1;
}

stock FamilyStorageHandleTakeAmmo(playerid, weapon_index, ammo_count)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200], action_text[96], notif_text[96];

    if(!FamilyStorageIsValidFamilyId(family_id) || weapon_index < 0 || weapon_index >= sizeof(count_weapon_level) || ammo_count <= 0)
        return 0;

    if(FamilyStorageGetTypedAmmo(family_id, weapon_index) < ammo_count)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Недостаточно патронов выбранного типа", " ");

    if(!FamilyStorageHasTakeAccess(playerid, ACCESS_PATRON, ammo_count))
        return FamilyStorageShowAccessDenied(playerid);

    if(!FamilyStorageTakeTypedAmmo(family_id, weapon_index, ammo_count))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Патроны уже были взяты другим игроком", " ");

    FamilyStorageConsumeAccess(playerid, ACCESS_PATRON, ammo_count);
    FamilyStorageSyncTypedAmmoTotal(family_id);
    GivePlayerWeapon(playerid, count_weapon_level[weapon_index], ammo_count);

    format(action_text, sizeof(action_text), "взял %d патронов для %s.", ammo_count, name_weapon_family[weapon_index]);
    FamilyStorageBuildChatText(playerid, action_text, chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_patron, playerid, -1, chat_text);

    format(notif_text, sizeof(notif_text), "Вы получили %d патронов", ammo_count);
    ShowNotificationNew(playerid, 3, 6, 0, 0, notif_text, " ");
    return 1;
}

stock FamilyStorageHandlePutAmmo(playerid, ammo_count)
{
    new family_id = GetPlayerIdFamily(playerid);
    new chat_text[200], action_text[96], notif_text[96];
    new weapon = GetPlayerWeapon(playerid);
    new ammo = GetPlayerAmmo(playerid);
    new limit;
    new slot_weapon_native = 0, slot_ammo_native = 0;
    new slot_ammo_found = -1;
    new weapon_index;

    if(!FamilyStorageIsValidFamilyId(family_id) || ammo_count <= 0)
        return 0;

    weapon_index = FamilyStorageGetAmmoTypeByWeapon(weapon);
    if(weapon_index == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Возьмите подходящее оружие в руки", " ");

    printf("[FAMILY_STORAGE][PUT_AMMO] player=%d current_weapon=%d current_ammo=%d request=%d", playerid, weapon, ammo, ammo_count);

    for(new i = 0; i < 12; i++)
    {
        GetPlayerWeaponData(playerid, i, slot_weapon_native, slot_ammo_native);

        if(slot_weapon_native == weapon && slot_ammo_native > slot_ammo_found)
            slot_ammo_found = slot_ammo_native;
    }

    new weapon_slot = GetWeaponSlot(weapon);
    if(weapon_slot >= 0 && weapon_slot < MAX_WEAPON_SLOTS)
    {
        new tracked_ammo = GetPlayerWeaponInfo(playerid, weapon_slot, TRACK_W_AMMO);
        if(tracked_ammo > slot_ammo_found) slot_ammo_found = tracked_ammo;
    }

    if(slot_ammo_found > ammo)
        ammo = slot_ammo_found;

    printf("[FAMILY_STORAGE][PUT_AMMO] player=%d final_weapon=%d final_ammo=%d request=%d family=%d", playerid, weapon, ammo, ammo_count, family_id);

    if(ammo < ammo_count)
    {
        printf("[FAMILY_STORAGE][PUT_AMMO] player=%d insufficient ammo: final_ammo=%d request=%d", playerid, ammo, ammo_count);
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас недостаточно патронов", " ");
    }

    limit = count_patron_level[FamilyStorageClampLevel(GetFamily(family_id, family_lvl_weapon)) - 1];
    if((FamilyStorageGetTypedAmmoTotal(family_id) + ammo_count) > limit)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Превышен лимит сейфа", " ");

    new remaining_ammo = ammo - ammo_count;
    SetPlayerAmmo(playerid, weapon, remaining_ammo);
    if(weapon_slot >= 0 && weapon_slot < MAX_WEAPON_SLOTS)
    {
        SetPlayerWeaponInfo(playerid, weapon_slot, TRACK_W_ID, weapon);
        SetPlayerWeaponInfo(playerid, weapon_slot, TRACK_W_AMMO, remaining_ammo);
    }

    if(!FamilyStorageAddTypedAmmo(family_id, weapon_index, ammo_count))
    {
        SetPlayerAmmo(playerid, weapon, ammo);
        if(weapon_slot >= 0 && weapon_slot < MAX_WEAPON_SLOTS)
        {
            SetPlayerWeaponInfo(playerid, weapon_slot, TRACK_W_ID, weapon);
            SetPlayerWeaponInfo(playerid, weapon_slot, TRACK_W_AMMO, ammo);
        }
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Не удалось сохранить патроны", " ");
    }

    FamilyStorageSyncTypedAmmoTotal(family_id);

    format(action_text, sizeof(action_text), "положил %d патронов для %s.", ammo_count, name_weapon_family[weapon_index]);
    FamilyStorageBuildChatText(playerid, action_text, chat_text, sizeof(chat_text));
    SendFamilyMessage(family_id, chat_text);
    SendFamilyLog(type_log_patron, playerid, -1, chat_text);

    format(notif_text, sizeof(notif_text), "Вы положили %d патронов для %s", ammo_count, name_weapon_family[weapon_index]);
    ShowNotificationNew(playerid, 3, 6, 0, 0, notif_text, " ");
    return 1;
}
stock FamilyStorageHandleGuiAction(playerid, Node:request)
{
    new selected = -1;

    if(JSON_GetType(request, "r") != JSON_NODE_NUMBER)
    {
        HidePlayerGUI(playerid, 45);
        return FamilyStorageShowMainDialog(playerid);
    }

    JSON_GetInt(request, "r", selected);

    if(selected == 0)
    {
        HidePlayerGUI(playerid, 45);
        return FamilyStorageShowSafeDialog(playerid);
    }

    if(selected == 1)
    {
        if(GetPlayerRangFamily(playerid) != 5)
            return FamilyStorageShowAccessDenied(playerid);

        HidePlayerGUI(playerid, 45);
        return FamilyStorageOpenWarehouseGui(playerid);
    }

    HidePlayerGUI(playerid, 45);
    return FamilyStorageShowMainDialog(playerid);
}

stock FamilyStorage_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new family_id = GetPlayerIdFamily(playerid);
    new amount = 0;
    new chat_text[200];

    if(!FamilyStorageIsValidFamilyId(family_id))
        return 0;

    switch(dialogid)
    {
        case FAM_DIALOG_STORAGE_MAIN:
        {
            if(!response) return 1;

            switch(listitem)
            {
                case 0:
                {
                    if(GetPlayerRangFamily(playerid) != 5)
                        return FamilyStorageShowAccessDenied(playerid);

                    return FamilyStorageOpenWarehouseGui(playerid);
                }
                case 1: return FamilyStorageShowSafeDialog(playerid);
                case 2: return FamilyStorageShowAccessInfo(playerid);
                case 3:
                {
                    if(GetPlayerRangFamily(playerid) != 5)
                        return FamilyStorageShowAccessDenied(playerid);

                    return FamilyStorageShowSettingsDialog(playerid);
                }
            }
            return 1;
        }
        case FAM_DIALOG_STORAGE_SAFE:
        {
            if(!response) return 1;

            switch(listitem)
            {
                case 0:
                {
                    if(GetPlayerRangFamily(playerid) != 5)
                        return FamilyStorageShowAccessDenied(playerid);

                    SetFamily(family_id, family_status_storage, GetFamily(family_id, family_status_storage) ? 0 : 1);
                    FamilyStorageBuildChatText(playerid, GetFamily(family_id, family_status_storage) ? "открыл сейф." : "закрыл сейф.", chat_text, sizeof(chat_text));
                    SendFamilyMessage(family_id, chat_text);
                    return 1;
                }
                case 1:
                {
                    if(!GetFamily(family_id, family_status_storage) && GetPlayerRangFamily(playerid) != 5)
                        return FamilyStorageShowClosed(playerid);

                    return FamilyStorageShowSafeTakeDialog(playerid);
                }
                case 2:
                {
                    if(!GetFamily(family_id, family_status_storage) && GetPlayerRangFamily(playerid) != 5)
                        return FamilyStorageShowClosed(playerid);

                    return FamilyStorageShowSafePutDialog(playerid);
                }
                case 3:
                {
                    if(GetPlayerRangFamily(playerid) == 5)
                        return FamilyStorageShowSettingsDialog(playerid);

                    return FamilyStorageShowAccessInfo(playerid);
                }
            }
            return 1;
        }
        case FAM_DIALOG_STORAGE_SAFE_TAKE:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            switch(listitem)
            {
                case 0:
                {
                    SetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION, FAMILY_SAFE_ACTION_TAKE);
                    return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_MONEY, DIALOG_STYLE_INPUT, "{E0584B}Взять деньги", "{FFFFFF}Введите кол-во денег:", "Далее", "Отмена");
                }
                case 1: return FamilyStorageShowAmmoActionDialog(playerid, FAMILY_SAFE_ACTION_TAKE);
                case 2:
                {
                    SetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION, FAMILY_SAFE_ACTION_TAKE);
                    return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_ARMOUR, DIALOG_STYLE_MSGBOX, "{E0584B}Взять бронежилет", "{FFFFFF}Вы хотите взять бронежилет из сейфа?", "Далее", "Отмена");
                }
            }
            return 1;
        }
        case FAM_DIALOG_STORAGE_SAFE_PUT:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            switch(listitem)
            {
                case 0:
                {
                    SetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION, FAMILY_SAFE_ACTION_PUT);
                    return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_MONEY, DIALOG_STYLE_INPUT, "{E0584B}Положить деньги", "{FFFFFF}Введите кол-во денег:", "Далее", "Отмена");
                }
                case 1: return FamilyStorageShowAmmoActionDialog(playerid, FAMILY_SAFE_ACTION_PUT);
                case 2:
                {
                    SetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION, FAMILY_SAFE_ACTION_PUT);
                    return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_ARMOUR, DIALOG_STYLE_MSGBOX, "{E0584B}Положить бронежилет", "{FFFFFF}Вы хотите положить бронежилет в сейф?", "Далее", "Отмена");
                }
            }
            return 1;
        }
        case FAM_DIALOG_STORAGE_SAFE_MONEY:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            amount = strval(inputtext);
            if(amount <= 0)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите корректное количество", " ");

            if(amount > FAMILY_SAFE_MAX_MONEY_AMOUNT)
            {
                if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION) == FAMILY_SAFE_ACTION_PUT)
                    return ShowNotificationNew(playerid, 2, 6, 0, 0, "Можно положить от 1 до 1000000 рублей.", " ");

                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Можно взять от 1 до 1000000 рублей.", " ");
            }

            if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION) == FAMILY_SAFE_ACTION_PUT)
                return FamilyStorageHandlePutMoney(playerid, amount);

            return FamilyStorageHandleTakeMoney(playerid, amount);
        }
        case FAM_DIALOG_STORAGE_SAFE_AMMO:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            if(listitem == 0)
                return FamilyStorageShowAmmoInfo(playerid);

            if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_AMMO_ACTION) == FAMILY_SAFE_ACTION_PUT)
                return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_AMMO_INPUT, DIALOG_STYLE_INPUT, "{E0584B}Введите патроны", "{FFFFFF}Введите кол-во патронов, которое хотите положить:", "Далее", "Назад");

            return FamilyStorageShowWeaponDialog(playerid);
        }
        case FAM_DIALOG_STORAGE_SAFE_WEAPON:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            SetPVarInt(playerid, PVAR_FAMILY_SAFE_WEAPON_INDEX, listitem);
            format(chat_text, sizeof(chat_text), "{FFFFFF}Введите нужное кол-во патронов, доступно %d",
                FamilyStorageGetTypedAmmo(family_id, listitem));
            return ShowPlayerDialog(playerid, FAM_DIALOG_STORAGE_SAFE_AMMO_INPUT, DIALOG_STYLE_INPUT, "{E0584B}Введите патроны", chat_text, "Далее", "Назад");
        }
        case FAM_DIALOG_STORAGE_SAFE_AMMO_INPUT:
        {
            if(!response)
            {
                if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_AMMO_ACTION) == FAMILY_SAFE_ACTION_PUT)
                    return FamilyStorageShowAmmoActionDialog(playerid, FAMILY_SAFE_ACTION_PUT);

                return FamilyStorageShowWeaponDialog(playerid);
            }

            amount = strval(inputtext);
            if(amount <= 0)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите корректное количество", " ");

            if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_AMMO_ACTION) == FAMILY_SAFE_ACTION_PUT)
                return FamilyStorageHandlePutAmmo(playerid, amount);

            return FamilyStorageHandleTakeAmmo(playerid, GetPVarInt(playerid, PVAR_FAMILY_SAFE_WEAPON_INDEX), amount);
        }
        case FAM_DIALOG_STORAGE_SAFE_ARMOUR:
        {
            if(!response) return FamilyStorageShowSafeDialog(playerid);

            if(GetPVarInt(playerid, PVAR_FAMILY_SAFE_MONEY_ACTION) == FAMILY_SAFE_ACTION_PUT)
                return FamilyStorageHandlePutArmour(playerid);

            return FamilyStorageHandleTakeArmour(playerid);
        }
    }

    return 0;
}

// END INLINED: include/system/family_storage_adapter.pwn

// FAMILY_GUI_ADAPTER_EMBED_BEGIN
// Family notifications are stored in familynew.notif as rows:
// id<TAB>text<TAB>author<LF>
#define FAMILY_GUI_NOTIF_LIMIT (5)
#define FAMILY_GUI_NOTIF_TEXT_LEN (128)
#define FAMILY_GUI_NOTIF_AUTHOR_LEN (32)
#define FAMILY_GUI_NOTIF_RAW_LEN (1024)
#define FAMILY_GUI_TOKEN_BC_PRICE (10)

enum E_FAMILY_GUI_SHOP_ITEM
{
    FAMILY_GUI_SHOP_ID,
    FAMILY_GUI_SHOP_OBJECT_ID,
    FAMILY_GUI_SHOP_PRICE,
    FAMILY_GUI_SHOP_SERVER_ID,
    FAMILY_GUI_SHOP_TYPE,
    FAMILY_GUI_SHOP_TYPE_ID
};

new const FamilyGuiShopItems[][E_FAMILY_GUI_SHOP_ITEM] =
{
    {0, 18526, 80, 389, 0, 3},
    {1, 7378, 100, 442, 0, 0},
    {2, 7344, 60, 408, 0, 0},
    {3, 7374, 100, 438, 0, 0},
    {4, 7387, 100, 451, 0, 0},
    {5, 7385, 100, 449, 0, 0},
    {6, 7397, 50, 461, 0, 0},
    {7, 7390, 60, 454, 0, 0},
    {8, 2641, 100, 0, 1, 4}
};

stock FamilyGuiClampLevel(level)
{
    if(level < 1) return 1;
    if(level > 7) return 7;
    return level;
}

stock FamilyGuiGetVehicleName(model_id, dest[], size = sizeof dest)
{
    GetVehicleModelName(model_id, dest, size);
    return 0;
}

stock FamilyGuiGetSqlFamilyId(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return -1;

    return GetFamily(GetPlayerIdFamily(playerid), family_database);
}

stock FamilyGuiGetNotificationMaxId(ids[FAMILY_GUI_NOTIF_LIMIT], count)
{
    new max_id = 0;

    for(new i; i < count; i++)
    {
        if(ids[i] > max_id)
            max_id = ids[i];
    }

    return max_id;
}

stock FamilyGuiSetNotificationReadState(playerid, family_sql_id, seen_id)
{
    if(family_sql_id == -1)
        return 0;

    SetPlayerData(playerid, P_FAMILY_NOTIF_SEEN, seen_id);
    SetPlayerData(playerid, P_FAMILY_NOTIF_SEEN_FAMILY, family_sql_id);
    UpdatePlayerDatabaseInt(playerid, "family_notif_seen", seen_id);
    UpdatePlayerDatabaseInt(playerid, "family_notif_seen_family", family_sql_id);
    return 1;
}

stock FamilyGuiReserveNotificationId(playerid, current_max_id)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new query[144];
    new seq_id = 0;

    if(family_sql_id == -1)
        return current_max_id + 1;

    mysql_format(mysql, query, sizeof query, "SELECT notif_seq FROM familynew WHERE id = %d LIMIT 1", family_sql_id);
    new Cache:cache = mysql_query(mysql, query, true);

    if(cache_num_rows())
        seq_id = cache_get_field_content_int(0, "notif_seq");

    cache_delete(cache);

    if(seq_id < current_max_id)
        seq_id = current_max_id;

    seq_id++;

    mysql_format(mysql, query, sizeof query, "UPDATE familynew SET notif_seq = %d WHERE id = %d LIMIT 1", seq_id, family_sql_id);
    mysql_query(mysql, query, false);
    return seq_id;
}

stock FamilyGuiIsNumericString(const value[])
{
    if(!strlen(value))
        return 0;

    for(new i; value[i] != '\0'; i++)
    {
        if(value[i] < '0' || value[i] > '9')
            return 0;
    }

    return 1;
}

stock FamilyGuiTrimString(const source[], dest[], size = sizeof dest)
{
    new start = 0;
    new finish = strlen(source);
    new pos = 0;

    while(source[start] == ' ' || source[start] == '\t')
        start++;

    while(finish > start && (source[finish - 1] == ' ' || source[finish - 1] == '\t'))
        finish--;

    for(new i = start; i < finish && pos < (size - 1); i++)
        dest[pos++] = source[i];

    dest[pos] = '\0';
    return 1;
}

stock FamilyGuiFormatDateTime(timestamp, dest[], size = sizeof dest)
{
    format(dest, size, "%d", timestamp);
    return 1;
}
stock FamilyGuiGetActualMemberCount(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new query[96];
    new count = 0;

    if(family_id == -1 || family_sql_id == -1)
        return 0;

    mysql_format(mysql, query, sizeof query, "SELECT COUNT(*) AS cnt FROM accounts WHERE family_id = %d", family_sql_id);
    new Cache:cache = mysql_query(mysql, query, true);

    if(cache_num_rows())
        count = cache_get_field_content_int(0, "cnt");

    cache_delete(cache);
    SetFamily(family_id, family_count_people, count);
    return count;
}

stock FamilyGuiFindOnlinePlayerByAccount(account_id)
{
    foreach(new targetid : Player)
    {
        if(GetPlayerAccountID(targetid) != account_id) continue;
        return targetid;
    }

    return INVALID_PLAYER_ID;
}

stock FamilyGuiFindShopItemIndex(shop_id)
{
    for(new i; i < sizeof(FamilyGuiShopItems); i++)
    {
        if(FamilyGuiShopItems[i][FAMILY_GUI_SHOP_ID] == shop_id)
            return i;
    }

    return -1;
}

stock FamilyGuiResolveRewardShopItemIndex(item_index)
{
    if(item_index < 0 || item_index >= sizeof(FamilyGuiShopItems))
        return -1;

    if(FamilyGuiShopItems[item_index][FAMILY_GUI_SHOP_ID] != 0)
        return item_index;

    new reward_indexes[sizeof(FamilyGuiShopItems)];
    new reward_count = 0;

    for(new i; i < sizeof(FamilyGuiShopItems); i++)
    {
        if(i == item_index)
            continue;

        reward_indexes[reward_count++] = i;
    }

    if(!reward_count)
        return -1;

    return reward_indexes[random(reward_count)];
}

stock FamilyGuiSendShopPurchaseResult(playerid, success, currency_type = 1, new_amount = 0)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 3);
    JSON_SetInt(response, "s", success ? 1 : 0);

    if(success)
    {
        JSON_SetInt(response, "tp", currency_type);
        JSON_SetInt(response, "na", new_amount);
    }

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendTokenPreview(playerid, preview_cost)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 9);
    JSON_SetInt(response, "s", 1);
    JSON_SetInt(response, "m", preview_cost);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendTokenPurchaseResult(playerid, success, money_value)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 9);
    JSON_SetInt(response, "s", 2);
    JSON_SetInt(response, "r", success ? 1 : 0);
    JSON_SetInt(response, "m", money_value);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiHandleShopPurchase(playerid, shop_id)
{
    new family_id = GetPlayerIdFamily(playerid);
    new item_index = FamilyGuiFindShopItemIndex(shop_id);
    new reward_item_index = -1;
    new item_price = 0;

    if(family_id == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    if(item_index == -1)
        return FamilyGuiSendShopPurchaseResult(playerid, 0);

    item_price = FamilyGuiShopItems[item_index][FAMILY_GUI_SHOP_PRICE];
    if(GetPlayerMoneti(playerid) < item_price)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "У Вас недостаточно монет.", " ");
        return FamilyGuiSendShopPurchaseResult(playerid, 0);
    }

    reward_item_index = FamilyGuiResolveRewardShopItemIndex(item_index);
    if(reward_item_index == -1)
    {
        printf("[FAMILY_SHOP][ERROR] cannot resolve reward item player=%d shop_id=%d item_index=%d",
            playerid,
            shop_id,
            item_index);
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Предмет временно недоступен.", " ");
        return FamilyGuiSendShopPurchaseResult(playerid, 0);
    }

    switch(FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_TYPE])
    {
        case 0:
        {
            new modelid = FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_OBJECT_ID];
            new inv_item_id = AccessoryShop_GetInventoryItemByModel(modelid);

            if(inv_item_id <= 0)
            {
                new resolved_item_id = -1;
                new resolved_modelid = -1;

                if(Inv11_ResolveAccessoryReward(FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_SERVER_ID], resolved_item_id, resolved_modelid))
                {
                    inv_item_id = resolved_item_id;
                    modelid = resolved_modelid;
                }
            }

            if(inv_item_id <= 0 || modelid <= 0)
            {
                printf("[FAMILY_SHOP][ERROR] cannot resolve item player=%d shop_id=%d object=%d server_id=%d",
                    playerid,
                    shop_id,
                    FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_OBJECT_ID],
                    FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_SERVER_ID]);
                ShowNotificationNew(playerid, 2, 6, 0, 0, "Предмет временно недоступен.", " ");
                return FamilyGuiSendShopPurchaseResult(playerid, 0);
            }

            new inv_slot = Inventory11_AddItemToDatabase(playerid, inv_item_id, modelid, 1, modelid, 0);

            if(inv_slot == -1)
            {
                ShowNotificationNew(playerid, 2, 6, 0, 0, "В инвентаре недостаточно места.", " ");
                return FamilyGuiSendShopPurchaseResult(playerid, 0);
            }

            new db_item_id = 0;
            new db_model_id = 0;
            new db_amount = 0;
            new db_extra_1 = 0;
            new db_extra_2 = 0;
            new db_old_skin = 0;
            new db_sim = 0;
            new db_oldsim = 0;
            new resolved_acc_model = 0;
            new bool:db_loaded = Inv11Trade_GetInventorySlotData(playerid, inv_slot, db_item_id, db_model_id, db_amount, db_extra_1, db_extra_2, db_old_skin, db_sim, db_oldsim);
            new bool:model_loaded = Inv11_GetAccModelBySlot(playerid, inv_slot, inv_item_id, resolved_acc_model);

            printf("[FAMILY_SHOP] player=%d shop_id=%d reward_shop_id=%d item=%d model=%d slot=%d moneti_before=%d",
                playerid,
                shop_id,
                FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_ID],
                inv_item_id,
                modelid,
                inv_slot,
                GetPlayerMoneti(playerid));
            printf("[FAMILY_SHOP][VERIFY] player=%d slot=%d db_loaded=%d item=%d model=%d amount=%d extra_1=%d extra_2=%d old_skin=%d sim=%d oldsim=%d model_loaded=%d resolved_model=%d",
                playerid,
                inv_slot,
                db_loaded,
                db_item_id,
                db_model_id,
                db_amount,
                db_extra_1,
                db_extra_2,
                db_old_skin,
                db_sim,
                db_oldsim,
                model_loaded,
                resolved_acc_model);
        }
        case 1:
        {
            if(GetPlayerRangFamily(playerid) != 5)
            {
                ShowNotificationNew(playerid, 2, 6, 0, 0, "Данная покупка доступна только лидеру семьи.", " ");
                return FamilyGuiSendShopPurchaseResult(playerid, 0);
            }

            if(FamilyGuiShopItems[reward_item_index][FAMILY_GUI_SHOP_TYPE_ID] == 4)
            {
                if(GetFamily(family_id, family_syndicate))
                {
                    ShowNotificationNew(playerid, 2, 6, 0, 0, "Данное улучшение уже приобретено.", " ");
                    return FamilyGuiSendShopPurchaseResult(playerid, 0);
                }

                SetFamily(family_id, family_syndicate, 1);
                UpdateColumnFamilyInt(GetFamily(family_id, family_database), "syndicate", 1);
            }
        }
    }

    AddPlayerData(playerid, P_MONETI, -, item_price);
    UpdatePlayerDatabaseInt(playerid, "moneti", GetPlayerMoneti(playerid));

    ShowNotificationNew(playerid, 3, 6, 0, 0, "Товар был успешно приобретен.", " ");
    return FamilyGuiSendShopPurchaseResult(playerid, 1, 0, GetPlayerMoneti(playerid));
}

stock FamilyGuiHandleTokenAction(playerid, status, value)
{
    new family_id = GetPlayerIdFamily(playerid);
    new bc_price = 0;

    if(status == 1)
    {
        if(value < 0)
            value = 0;

        return FamilyGuiSendTokenPreview(playerid, value * FAMILY_GUI_TOKEN_BC_PRICE);
    }

    if(status != 2)
        return 1;

    if(family_id == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    if(value <= 0)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите корректное количество монет.", " ");
        return FamilyGuiSendTokenPurchaseResult(playerid, 0, GetPlayerMoneti(playerid));
    }

    bc_price = value * FAMILY_GUI_TOKEN_BC_PRICE;

    if(GetPlayerDonateRub(playerid) < bc_price)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Недостаточно BC.", " ");
        return FamilyGuiSendTokenPurchaseResult(playerid, 0, GetPlayerMoneti(playerid));
    }

    SetPlayerData(playerid, P_DONATE_RUB, GetPlayerDonateRub(playerid) - bc_price);
    UpdatePlayerDatabaseInt(playerid, "rub", GetPlayerDonateRub(playerid));
    AddPlayerData(playerid, P_MONETI, +, value);
    UpdatePlayerDatabaseInt(playerid, "moneti", GetPlayerMoneti(playerid));

    ShowNotificationNew(playerid, 3, 6, 0, 0, "Семейные монеты были успешно приобретены.", " ");
    FamilyGuiSendTokenPurchaseResult(playerid, 1, GetPlayerMoneti(playerid));
    return FamilyGuiSendShopPurchaseResult(playerid, 1, 1, GetFamily(family_id, family_zaxvati));
}

stock FamilyGuiSanitizeNotificationText(const source[], dest[], size = sizeof dest)
{
    new pos = 0;

    for(new i; source[i] != '\0'; i++)
    {
        new ch = source[i];

        if(ch == '\r' || ch == '\n' || ch == '\t')
            ch = ' ';

        if(pos < (size - 1))
            dest[pos++] = ch;
    }

    while(pos > 0 && dest[pos - 1] == ' ')
        pos--;

    dest[pos] = '\0';
    return 1;
}

stock FamilyGuiNotificationReadField(const source[], &offset, delimiter, dest[], size = sizeof dest)
{
    new pos = 0;

    while(source[offset] != '\0' && source[offset] != delimiter)
    {
        if(pos < (size - 1))
            dest[pos++] = source[offset];
        offset++;
    }

    dest[pos] = '\0';

    if(source[offset] == delimiter)
        offset++;

    return 1;
}

stock FamilyGuiCopySlice(const source[], start, length, dest[], size = sizeof dest)
{
    new pos = 0;

    while(pos < length && pos < (size - 1) && source[start + pos] != EOS)
    {
        dest[pos] = source[start + pos];
        pos++;
    }

    dest[pos] = EOS;
    return 1;
}

stock FamilyGuiParseNotifications(const raw[], family_sql_id, ids[FAMILY_GUI_NOTIF_LIMIT], values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN], authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN], &count, &rewritten)
{
    new offset = 0;
    new notif_line[256];
    new token_index[4];
    new token_length[4];
    new id_buffer[16];
    new text_buffer[FAMILY_GUI_NOTIF_TEXT_LEN];
    new author_buffer[FAMILY_GUI_NOTIF_AUTHOR_LEN];

    count = 0;
    rewritten = 0;

    while(raw[offset] != EOS && count < FAMILY_GUI_NOTIF_LIMIT)
    {
        new line_len = 0;
        new token_count = 0;
        new current_family_sql_id = family_sql_id;

        while(raw[offset] != EOS && raw[offset] != 10 && line_len < (sizeof(notif_line) - 1))
            notif_line[line_len++] = raw[offset++];

        if(raw[offset] == 10)
            offset++;

        notif_line[line_len] = EOS;

        if(!line_len)
            continue;

        token_index[0] = 0;
        for(new i; ; i++)
        {
            if(notif_line[i] == 9 || notif_line[i] == EOS)
            {
                token_length[token_count] = i - token_index[token_count];
                token_count++;

                if(notif_line[i] == EOS || token_count >= 4)
                    break;

                token_index[token_count] = i + 1;
            }
        }

        if(token_count < 3)
        {
            rewritten = 1;
            continue;
        }

        if(token_count >= 4)
        {
            new family_buffer[16];
            FamilyGuiCopySlice(notif_line, token_index[0], token_length[0], family_buffer, sizeof family_buffer);
            current_family_sql_id = strval(family_buffer);
            FamilyGuiCopySlice(notif_line, token_index[1], token_length[1], id_buffer, sizeof id_buffer);
            FamilyGuiCopySlice(notif_line, token_index[2], token_length[2], text_buffer, sizeof text_buffer);
            FamilyGuiCopySlice(notif_line, token_index[3], token_length[3], author_buffer, sizeof author_buffer);
        }
        else
        {
            FamilyGuiCopySlice(notif_line, token_index[0], token_length[0], id_buffer, sizeof id_buffer);
            FamilyGuiCopySlice(notif_line, token_index[1], token_length[1], text_buffer, sizeof text_buffer);
            FamilyGuiCopySlice(notif_line, token_index[2], token_length[2], author_buffer, sizeof author_buffer);
            rewritten = 1;
        }

        if(!strlen(id_buffer) || !strlen(text_buffer))
        {
            rewritten = 1;
            continue;
        }

        if(current_family_sql_id != family_sql_id)
        {
            rewritten = 1;
            continue;
        }

        ids[count] = strval(id_buffer);
        format(values[count], FAMILY_GUI_NOTIF_TEXT_LEN, "%s", text_buffer);
        format(authors[count], FAMILY_GUI_NOTIF_AUTHOR_LEN, "%s", author_buffer);
        count++;
    }

    return 1;
}

stock FamilyGuiBuildNotificationsRaw(family_sql_id, ids[FAMILY_GUI_NOTIF_LIMIT], values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN], authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN], count, dest[], size = sizeof dest)
{
    new family_text[16];
    new id_text[16];
    new value_text[FAMILY_GUI_NOTIF_TEXT_LEN];
    new author_text[FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new dest_len = 0;

    dest[0] = EOS;
    format(family_text, sizeof family_text, "%d", family_sql_id);

    for(new i; i < count && i < FAMILY_GUI_NOTIF_LIMIT; i++)
    {
        new value_len = 0;
        new author_len = 0;

        while(value_len < (FAMILY_GUI_NOTIF_TEXT_LEN - 1) && values[i][value_len] != EOS)
        {
            value_text[value_len] = values[i][value_len];
            value_len++;
        }
        value_text[value_len] = EOS;

        while(author_len < (FAMILY_GUI_NOTIF_AUTHOR_LEN - 1) && authors[i][author_len] != EOS)
        {
            author_text[author_len] = authors[i][author_len];
            author_len++;
        }
        author_text[author_len] = EOS;

        format(id_text, sizeof id_text, "%d", ids[i]);

        if((dest_len + strlen(family_text) + strlen(id_text) + strlen(value_text) + strlen(author_text) + 4) >= size)
            break;

        for(new j; family_text[j] != EOS && dest_len < (size - 1); j++)
            dest[dest_len++] = family_text[j];
        dest[dest_len++] = 9;

        for(new j; id_text[j] != EOS && dest_len < (size - 1); j++)
            dest[dest_len++] = id_text[j];
        dest[dest_len++] = 9;

        for(new j; value_text[j] != EOS && dest_len < (size - 1); j++)
            dest[dest_len++] = value_text[j];
        dest[dest_len++] = 9;

        for(new j; author_text[j] != EOS && dest_len < (size - 1); j++)
            dest[dest_len++] = author_text[j];
        dest[dest_len++] = 10;

        dest[dest_len] = EOS;
    }

    return 1;
}

stock FamilyGuiLoadNotifications(playerid, ids[FAMILY_GUI_NOTIF_LIMIT], values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN], authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN], &count)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new raw[FAMILY_GUI_NOTIF_RAW_LEN];
    new rewritten = 0;

    count = 0;
    raw[0] = EOS;

    if(family_sql_id == -1)
        return 0;

    mysql_format(mysql, f_string144, sizeof f_string144, "SELECT notif FROM familynew WHERE id = %d LIMIT 1", family_sql_id);
    new Cache:cache = mysql_query(mysql, f_string144, true);

    if(cache_num_rows())
        cache_get_field_content(0, "notif", raw, mysql, sizeof raw);

    cache_delete(cache);
    FamilyGuiParseNotifications(raw, family_sql_id, ids, values, authors, count, rewritten);

    if(rewritten)
        FamilyGuiSaveNotifications(playerid, ids, values, authors, count);

    return 1;
}

stock FamilyGuiSaveNotifications(playerid, ids[FAMILY_GUI_NOTIF_LIMIT], values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN], authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN], count)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new raw[FAMILY_GUI_NOTIF_RAW_LEN];

    if(family_sql_id == -1)
        return 0;

    FamilyGuiBuildNotificationsRaw(family_sql_id, ids, values, authors, count, raw, sizeof raw);

    mysql_format(mysql, f_string184, sizeof f_string184, "UPDATE familynew SET notif = '%e' WHERE id = %d LIMIT 1", raw, family_sql_id);
    mysql_query(mysql, f_string184, false);
    return !mysql_errno();
}

stock FamilyGuiGetNotificationCount(playerid)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new ids[FAMILY_GUI_NOTIF_LIMIT];
    new values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN];
    new authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new count = 0;
    new seen_id = 0;
    new seen_family_sql_id = 0;
    new unread_count = 0;

    if(family_sql_id == -1)
        return 0;

    FamilyGuiLoadNotifications(playerid, ids, values, authors, count);
    seen_id = GetPlayerData(playerid, P_FAMILY_NOTIF_SEEN);
    seen_family_sql_id = GetPlayerData(playerid, P_FAMILY_NOTIF_SEEN_FAMILY);

    if(seen_family_sql_id != family_sql_id)
        return count;

    for(new i; i < count; i++)
    {
        if(ids[i] > seen_id)
            unread_count++;
    }

    return unread_count;
}

stock ShowFamilyGui(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не состоите в семье.", " ");

    new Node:response = JSON_Object();
    new family_id = GetPlayerIdFamily(playerid);
    new family_name_text[96];
    new player_name[MAX_PLAYER_NAME + 1];

    format(player_name, sizeof player_name, "%s", GetPlayerNameEx(playerid));
    format(family_name_text, sizeof family_name_text, "%s", family[family_id][family_name]);

    JSON_SetString(response, "n", family_name_text);
    JSON_SetInt(response, "k", GetPlayerRangFamily(playerid) == 5 ? 1 : 0);
    JSON_SetInt(response, "m", GetPlayerMoneti(playerid));
    JSON_SetInt(response, "j", GetFamily(family_id, family_zaxvati));
    JSON_SetInt(response, "y", FamilyGuiGetNotificationCount(playerid));
    JSON_SetInt(response, "b", 0);
    JSON_SetString(response, "pn", player_name);
    JSON_SetInt(response, "pi", playerid);
    JSON_SetInt(response, "is", GetFamily(family_id, family_syndicate));

    ShowPlayerGUI(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendCarActionResult(playerid, success)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 2);
    JSON_SetInt(response, "s", 2);
    JSON_SetInt(response, "d", success ? 1 : 0);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendLeaveResult(playerid, success)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 10);
    JSON_SetInt(response, "s", success ? 1 : 0);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendNotificationAdded(playerid, text[], author[], notif_id)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 6);
    JSON_SetInt(response, "b", 1);
    JSON_SetString(response, "k", text, strlen(text) + 1);
    JSON_SetString(response, "n", author, strlen(author) + 1);
    JSON_SetInt(response, "x", notif_id);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendNotificationDeleted(playerid, deleted_id)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 6);
    JSON_SetInt(response, "b", 2);
    JSON_SetInt(response, "d", deleted_id);
    JSON_SetString(response, "k", "");
    JSON_SetString(response, "n", "");
    JSON_SetInt(response, "x", -1);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendCarList(playerid)
{
    new Node:response = JSON_Object();
    new Node:name_list = JSON_Array();
    new Node:id_list = JSON_Array();
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);

    JSON_SetInt(response, "t", 2);
    JSON_SetInt(response, "g", 0);

    if(family_sql_id != -1)
    {
        mysql_format(mysql, f_string144, sizeof f_string144, "SELECT id, model_id FROM family_cars WHERE family_owner = %d", family_sql_id);
        new Cache:cache = mysql_query(mysql, f_string144, true);
        new rows = cache_num_rows();

        if(!rows)
        {
            cache_delete(cache);
            JSON_Cleanup(response);
            return ShowNotificationNew(playerid, 2, 6, 0, 0, "В семье нет машин.", " ");
        }

        for(new i; i < rows; i++)
        {
            new sql_id = cache_get_field_content_int(i, "id");
            new model_id = cache_get_field_content_int(i, "model_id");
            new model_name[32];

            FamilyGuiGetVehicleName(model_id, model_name, sizeof model_name);

            name_list = JSON_Append(name_list, JSON_Array(JSON_String(model_name)));
            id_list = JSON_Append(id_list, JSON_Array(JSON_Int(sql_id)));
        }

        cache_delete(cache);
    }

    JSON_SetArray(response, "n", name_list);
    JSON_SetArray(response, "id", id_list);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendCarInfo(playerid, sql_id)
{
    new Node:response = JSON_Object();
    new car_rank = 1;
    new car_status = 0;
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);

    if(family_sql_id != -1)
    {
        mysql_format(mysql, f_string144, sizeof f_string144, "SELECT rang FROM family_cars WHERE id = %d AND family_owner = %d LIMIT 1", sql_id, family_sql_id);
        new Cache:cache = mysql_query(mysql, f_string144, true);

        if(cache_num_rows())
        {
            car_rank = cache_get_field_content_int(0, "rang");
            car_status = GetStatusFamilyCar(sql_id);
        }

        cache_delete(cache);
    }

    JSON_SetInt(response, "t", 2);
    JSON_SetInt(response, "s", 1);
    JSON_SetInt(response, "r", car_rank);
    JSON_SetInt(response, "d", car_status);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiHandleCarAction(playerid, Node:request)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return FamilyGuiSendCarActionResult(playerid, 0);

    new sql_id;
    new action_id;

    if(JSON_GetType(request, "m") != JSON_NODE_NUMBER || JSON_GetType(request, "id") != JSON_NODE_NUMBER)
        return FamilyGuiSendCarActionResult(playerid, 0);

    JSON_GetInt(request, "m", sql_id);
    JSON_GetInt(request, "id", action_id);

    new family_id = GetPlayerIdFamily(playerid);
    new bool:is_family_owner = GetFamily(family_id, family_owner) == GetPlayerAccountID(playerid);

    if(action_id == 0 && GetStatusFamilyCar(sql_id))
    {
        new vehicleid = GetVehicleFamilyCar(sql_id);
        if(vehicleid != INVALID_VEHICLE_ID)
        {
            new Float:x, Float:y, Float:z;
            GetVehiclePos(vehicleid, x, y, z);
            EnablePlayerGPS(playerid, 55, x, y, z, "");
            ShowNotificationNew(playerid, 3, 6, 0, 0, "Местоположение семейного транспорта отмечено на GPS", " ");
            return FamilyGuiSendCarActionResult(playerid, 1);
        }
    }

    mysql_format(mysql, f_string184, sizeof f_string184, "SELECT model_id, rang, pos_x, pos_y, pos_z, angle FROM family_cars WHERE id = %d AND family_owner = %d LIMIT 1", sql_id, FamilyGuiGetSqlFamilyId(playerid));
    new Cache:cache = mysql_query(mysql, f_string184, true);

    if(!cache_num_rows())
    {
        cache_delete(cache);
        return FamilyGuiSendCarActionResult(playerid, 0);
    }

    new model_id = cache_get_field_content_int(0, "model_id");
    new car_rank = cache_get_field_content_int(0, "rang");
    new success = 0;
    new player_rank = GetPlayerRangFamily(playerid);
    new rank_name[24];
    new vehicle_name[32];
    new family_text[200];

    if(player_rank >= 1 && player_rank <= 5)
        format(rank_name, sizeof rank_name, "%s", family_rang_name[family_id][player_rank - 1]);
    else
        format(rank_name, sizeof rank_name, "%d ранг", player_rank);

    FamilyGuiGetVehicleName(model_id, vehicle_name, sizeof vehicle_name);

    switch(action_id)
    {
        case 0:
        {
            new Float:x = cache_get_field_content_float(0, "pos_x");
            new Float:y = cache_get_field_content_float(0, "pos_y");
            new Float:z = cache_get_field_content_float(0, "pos_z");

            if(GetStatusFamilyCar(sql_id))
            {
                new vehicleid = GetVehicleFamilyCar(sql_id);
                if(vehicleid != INVALID_VEHICLE_ID) GetVehiclePos(vehicleid, x, y, z);
            }

            EnablePlayerGPS(playerid, 55, x, y, z, "");
            ShowNotificationNew(playerid, 3, 6, 0, 0, "Местоположение семейного транспорта отмечено на GPS", " ");
            success = 1;
        }
        case 1, 6:
        {
            if(GetPlayerRangFamily(playerid) < car_rank)
            {
                ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не можете загрузить данное ТС", " ");
            }
            else if(!GetStatusFamilyCar(sql_id))
            {
                success = LoadFamilyCar(sql_id);
                if(success)
                {
                    ShowNotificationNew(playerid, 3, 5, 0, 0, "Автомобиль успешно загружен.", " ");
                    format(family_text, sizeof family_text, "%s %s[%d] загрузил автомобиль %s", rank_name, GetPlayerNameEx(playerid), playerid, vehicle_name);
                    SendFamilyMessage(family_id, family_text);
                    SendFamilyLog(type_log_car, playerid, -1, family_text);
                }
            }
        }
        case 5:
        {
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Система гаражей временно недоступна.", " ");
        }
        case 2:
        {
            if(!is_family_owner)
            {
                ShowNotificationNew(playerid, 2, 5, 0, 0, "Ошибка, Вы не создатель семьи", " ");
            }
            else if((GetPlayerOwnableCars(playerid) + 1) <= GetPlayerCarSlots(playerid))
            {
                success = MoveFamilyCar(sql_id, playerid);
            }
        }
        case 3:
        {
            if(!is_family_owner)
            {
                ShowNotificationNew(playerid, 2, 6, 0, 0, "Ошибка, Вы не создатель семьи", " ");
            }
            else
            {
                new access_action = -1;
                new new_rank = car_rank;

                JSON_GetInt(request, "r", access_action);

                if(access_action == 0 && new_rank > 1) new_rank--;
                else if(access_action == 1 && new_rank < 5) new_rank++;

                if(new_rank != car_rank)
                {
                    mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE family_cars SET rang = %d WHERE id = %d LIMIT 1", new_rank, sql_id);
                    mysql_query(mysql, f_string144, false);

                    if(!mysql_errno())
                    {
                        new vehicleid = GetVehicleFamilyCar(sql_id);
                        if(vehicleid != INVALID_VEHICLE_ID)
                        {
                            SetCarFamily(GetVehicleData(vehicleid, V_ACTION_ID), V_F_RANG, new_rank);
                        }
                        ShowNotificationNew(playerid, 3, 6, 0, 0, "Ранг использования автомобиля был успешно изменен", " ");
                        success = 1;
                    }
                }
            }
        }
        case 4:
        {
            if(GetStatusFamilyCar(sql_id))
            {
                new vehicleid = GetVehicleFamilyCar(sql_id);
                if(vehicleid == INVALID_VEHICLE_ID)
                {
                    success = 0;
                }
                else if(GetVehicleDriver(vehicleid) != playerid && GetPlayerRangFamily(playerid) != 5)
                {
                    ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы должны быть за рулем данного автомобиля.", " ");
                }
                else
                {
                    success = UnLoadFamilyCar(sql_id) == 1;
                    if(success)
                    {
                        ShowNotificationNew(playerid, 3, 6, 0, 0, "Вы успешно выгрузили транспорт", " ");
                        format(family_text, sizeof family_text, "%s %s[%d] выгрузил транспорт \"%s\"", rank_name, GetPlayerNameEx(playerid), playerid, vehicle_name);
                        SendFamilyMessage(family_id, family_text);
                        SendFamilyLog(type_log_car, playerid, -1, family_text);
                    }
                }
            }
        }
        case 7:
        {
            if(!is_family_owner)
            {
                ShowNotificationNew(playerid, 2, 6, 0, 0, "Ошибка, Вы не создатель семьи", " ");
            }
            else
            {
                if(GetStatusFamilyCar(sql_id))
                {
                    new vehicleid = GetVehicleFamilyCar(sql_id);
                    if(vehicleid != INVALID_VEHICLE_ID)
                    {
                        new Float:x, Float:y, Float:z, Float:a;
                        GetVehiclePos(vehicleid, x, y, z);
                        GetVehicleZAngle(vehicleid, a);

                        mysql_format(mysql, f_string184, sizeof f_string184, "UPDATE family_cars SET pos_x = %f, pos_y = %f, pos_z = %f, angle = %f WHERE id = %d LIMIT 1", x, y, z, a, sql_id);
                        mysql_query(mysql, f_string184, false);
                        success = !mysql_errno();
                    }
                }
                else
                {
                    success = 1;
                }

                if(success)
                    ShowNotificationNew(playerid, 3, 6, 0, 0, "Парковка была успешно сброшена", " ");
            }
        }
    }

    cache_delete(cache);
    return FamilyGuiSendCarActionResult(playerid, success);
}
stock FamilyGuiGetSettingAccessMinRank(family_id, access_idx)
{
    for(new rank = 1; rank <= 5; rank++)
    {
        if(family_rang_dostup[family_id][rank - 1][access_idx])
            return rank;
    }

    return 5;
}

stock FamilyGuiSetSettingAccessMinRank(family_id, access_idx, min_rank)
{
    if(min_rank < 1) min_rank = 1;
    if(min_rank > 5) min_rank = 5;

    for(new rank = 1; rank <= 5; rank++)
    {
        family_rang_dostup[family_id][rank - 1][access_idx] = rank >= min_rank;
        UpdateDostupFamily(family_id, rank - 1);
    }

    return 1;
}

stock FamilyGuiGetChatColorUiId(color_idx)
{
    if(color_idx < 0 || color_idx >= sizeof(family_type_color))
        return 0;

    return color_idx;
}

stock FamilyGuiSendFamilySettings(playerid)
{
    new family_id = GetPlayerIdFamily(playerid);
    new Node:response = JSON_Object();
    new Node:rank_name_list = JSON_Array();
    new Node:rank_access_list = JSON_Array();

    if(family_id == -1)
    {
        JSON_Cleanup(response);
        return 0;
    }

    for(new i; i < 5; i++)
    {
        rank_name_list = JSON_Append(rank_name_list, JSON_Array(JSON_String(family_rang_name[family_id][i])));
        rank_access_list = JSON_Append(rank_access_list, JSON_Array(JSON_Int(FamilyGuiGetSettingAccessMinRank(family_id, i))));
    }

    rank_access_list = JSON_Append(rank_access_list, JSON_Array(JSON_Int(5)));

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 1);
    JSON_SetInt(response, "st", 1);
    JSON_SetInt(response, "l", FamilyGuiGetChatColorUiId(GetFamily(family_id, family_color)));
    JSON_SetInt(response, "cl", FamilyGuiGetChatColorUiId(GetFamily(family_id, family_color)));
    JSON_SetArray(response, "r", rank_name_list);
    JSON_SetArray(response, "rp", rank_access_list);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendFamilySettingRankUpdate(playerid, rank_pos)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 1);
    JSON_SetInt(response, "s", 1);
    JSON_SetInt(response, "n", 1);
    JSON_SetInt(response, "r", rank_pos);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendFamilySettingAccessUpdate(playerid, rank_pos, access_pos, access_state, bool:success)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 1);
    JSON_SetInt(response, "s", 2);
    JSON_SetInt(response, "n", success ? 1 : 0);
    JSON_SetInt(response, "k", access_pos);

    if(success)
    {
        JSON_SetInt(response, "r", rank_pos);
        JSON_SetInt(response, "b", access_state);
    }

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendFamilySettingColorUpdate(playerid, color_pos)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 1);
    JSON_SetInt(response, "s", 3);
    JSON_SetInt(response, "n", 1);
    JSON_SetInt(response, "r", color_pos);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiHandleFamilySettingRank(playerid, Node:request)
{
    new family_id = GetPlayerIdFamily(playerid);
    new rank_pos = 0;
    new new_name[24];

    if(family_id == -1 || GetPlayerRangFamily(playerid) != 5)
        return 0;

    if(JSON_GetType(request, "r") != JSON_NODE_NUMBER || JSON_GetType(request, "n") != JSON_NODE_STRING)
        return 0;

    JSON_GetInt(request, "r", rank_pos);
    JSON_GetString(request, "n", new_name, sizeof new_name);
    utf8_to_cp1251(new_name);

    if(rank_pos < 1 || rank_pos > 5)
        return 0;

    if(strlen(new_name) < 3 || strlen(new_name) > 23 || strfind(new_name, ",") != -1)
        return 0;

    format(family_rang_name[family_id][rank_pos - 1], 24, "%s", new_name);
    UpdateDostupFamily(family_id, rank_pos - 1);
    return FamilyGuiSendFamilySettingRankUpdate(playerid, rank_pos);
}

stock FamilyGuiHandleFamilySettingAccess(playerid, Node:request)
{
    new family_id = GetPlayerIdFamily(playerid);
    new rank_pos = 0;
    new access_pos = -1;
    new access_state = 0;

    if(family_id == -1 || GetPlayerRangFamily(playerid) != 5)
        return 0;

    if(JSON_GetType(request, "r") != JSON_NODE_NUMBER || JSON_GetType(request, "k") != JSON_NODE_NUMBER || JSON_GetType(request, "n") != JSON_NODE_NUMBER)
        return 0;

    JSON_GetInt(request, "r", rank_pos);
    JSON_GetInt(request, "k", access_pos);
    JSON_GetInt(request, "n", access_state);

    if(rank_pos < 1 || rank_pos > 5 || access_pos < 0 || access_pos > 5)
        return FamilyGuiSendFamilySettingAccessUpdate(playerid, rank_pos, access_pos, access_state, false);

    if(access_pos == 5)
        return FamilyGuiSendFamilySettingAccessUpdate(playerid, rank_pos, access_pos, access_state, false);

    FamilyGuiSetSettingAccessMinRank(family_id, access_pos, access_state ? rank_pos : 5);
    return FamilyGuiSendFamilySettingAccessUpdate(playerid, rank_pos, access_pos, access_state ? 1 : 0, true);
}

stock FamilyGuiHandleFamilySettingColor(playerid, Node:request)
{
    new family_id = GetPlayerIdFamily(playerid);
    new color_pos = 0;

    if(family_id == -1 || GetPlayerRangFamily(playerid) != 5)
        return 0;

    if(JSON_GetType(request, "r") != JSON_NODE_NUMBER)
        return 0;

    JSON_GetInt(request, "r", color_pos);

    if(color_pos < 0 || color_pos >= sizeof(family_type_color))
        return 0;

    SetFamily(family_id, family_color, color_pos);
    UpdateColumnFamilyInt(GetFamily(family_id, family_database), "chatcolor", GetFamily(family_id, family_color));

    ShowNotificationNew(playerid, 3, 6, 0, 0, "Цвет семьи успешно был изменен.", " ");
    return FamilyGuiSendFamilySettingColorUpdate(playerid, color_pos);
}
stock FamilyGuiSendPlayerActionResult(playerid, success)
{
    new Node:response = JSON_Object();

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 2);
    JSON_SetInt(response, "s", 2);
    JSON_SetInt(response, "r", success ? 1 : 0);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiResetPlayerState(playerid)
{
    DeletePVar(playerid, "family_gui_target_accid");
    return 1;
}

stock FamilyGuiSendPlayerList(playerid)
{
    new Node:response = JSON_Object();
    new Node:name_list = JSON_Array();
    new Node:rank_status_list = JSON_Array();
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new self_account_id = GetPlayerAccountID(playerid);
    new bool:self_added = false;

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 2);
    JSON_SetInt(response, "s", 0);
    FamilyGuiResetPlayerState(playerid);

    if(family_sql_id != -1)
    {
        mysql_format(mysql, f_string184, sizeof f_string184, "SELECT id, name, family_rang FROM accounts WHERE family_id = %d ORDER BY family_rang DESC, name ASC", family_sql_id);
        new Cache:cache = mysql_query(mysql, f_string184, true);

        for(new i, rows = cache_num_rows(); i < rows; i++)
        {
            new account_id = cache_get_field_content_int(i, "id");
            new name[24];
            new rank = cache_get_field_content_int(i, "family_rang");
            new online = 0;

            cache_get_field_content(i, "name", name, mysql, sizeof name);

            foreach(new targetid : Player)
            {
                if(GetPlayerAccountID(targetid) != account_id) continue;
                online = 1;
                break;
            }

            if(account_id == self_account_id)
                self_added = true;

            name_list = JSON_Append(name_list, JSON_Array(JSON_String(name)));
            rank_status_list = JSON_Append(rank_status_list, JSON_Array(JSON_Int(rank)));
            rank_status_list = JSON_Append(rank_status_list, JSON_Array(JSON_Int(online)));
        }

        cache_delete(cache);
    }

    if(!self_added && GetPlayerIdFamily(playerid) != -1)
    {
        name_list = JSON_Append(name_list, JSON_Array(JSON_String(GetPlayerNameEx(playerid))));
        rank_status_list = JSON_Append(rank_status_list, JSON_Array(JSON_Int(GetPlayerRangFamily(playerid))));
        rank_status_list = JSON_Append(rank_status_list, JSON_Array(JSON_Int(1)));
    }

    JSON_SetArray(response, "np", name_list);
    JSON_SetArray(response, "rs", rank_status_list);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendPlayerInfo(playerid, const selected_name[])
{
    new Node:response = JSON_Object();
    new family_id = GetPlayerIdFamily(playerid);
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new rank = 1;
    new mute_time = 0;
    new vig_count = 0;
    new level = 1;
    new phone = 0;
    new skin = 0;
    new account_id = -1;

    if(family_sql_id != -1)
    {
        mysql_format(mysql, f_string184, sizeof f_string184, "SELECT id, family_rang, family_mute, family_vig, level, phone, skin FROM accounts WHERE family_id = %d AND name = '%e' LIMIT 1", family_sql_id, selected_name);
        new Cache:cache = mysql_query(mysql, f_string184, true);

        if(cache_num_rows())
        {
            account_id = cache_get_field_content_int(0, "id");
            rank = cache_get_field_content_int(0, "family_rang");
            mute_time = cache_get_field_content_int(0, "family_mute");
            vig_count = cache_get_field_content_int(0, "family_vig");
            level = cache_get_field_content_int(0, "level");
            phone = cache_get_field_content_int(0, "phone");
            skin = cache_get_field_content_int(0, "skin");
        }

        cache_delete(cache);
    }

    if(account_id != -1)
    {
        SetPVarInt(playerid, "family_gui_target_accid", account_id);

        foreach(new targetid : Player)
        {
            if(GetPlayerAccountID(targetid) != account_id) continue;

            rank = GetPlayerRangFamily(targetid);
            mute_time = GetPlayerFamily(targetid, MUTE_FAMILY);
            vig_count = GetPlayerFamily(targetid, VIG_FAMILY);
            level = GetPlayerLevel(targetid);
            phone = GetPlayerPhone(targetid);
            skin = GetPlayerSkin(targetid);
            break;
        }
    }
    else
    {
        FamilyGuiResetPlayerState(playerid);
    }

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "id", 2);
    JSON_SetInt(response, "s", 1);
    JSON_SetInt(response, "sk", skin);
    JSON_SetInt(response, "rb", level);
    JSON_SetInt(response, "rv", vig_count);
    JSON_SetInt(response, "rp", phone);
    JSON_SetInt(response, "m", mute_time);
    if(family_id != -1 && rank >= 1 && rank <= 5)
        JSON_SetString(response, "rn", family_rang_name[family_id][rank - 1]);
    else
        JSON_SetString(response, "rn", "Участник");

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiRemoveMemberFromFamily(targetid, target_account_id)
{
    SetPlayerFamily(targetid, ID_FAMILY, -1);
    SetPlayerFamily(targetid, ID_SQL_FAMILY, -1);

    DestroyDynamic3DTextLabel(GetPlayerFamily(targetid, TEXT_FAMILY));
    SetPlayerFamily(targetid, TEXT_FAMILY, STREAMER_TAG_3D_TEXT_LABEL:-1);

    SetPlayerFamily(targetid, RANG_FAMILY, 0);
    SetPlayerFamily(targetid, MUTE_FAMILY, 0);
    SetPlayerFamily(targetid, VIG_FAMILY, 0);

    SetPlayerFamily(targetid, ACCESS_GIVE, 0);
    SetPlayerFamily(targetid, ACCESS_MONEY, 0);
    SetPlayerFamily(targetid, ACCESS_ARMOUR, 0);
    SetPlayerFamily(targetid, ACCESS_MATERIAL, 0);
    SetPlayerFamily(targetid, ACCESS_HEATH_KIT, 0);
    SetPlayerFamily(targetid, ACCESS_PATRON, 0);
    SetPlayerFamily(targetid, ACCESS_MASK, 0);

    mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE accounts SET family_id=-1, family_rang=0, family_mute=0, family_vig=0, family_access='0,0,0,0,0,0,0' WHERE id = %d LIMIT 1", target_account_id);
    mysql_query(mysql, f_string144, false);
    return !mysql_errno();
}

stock FamilyGuiHandlePlayerAction(playerid, Node:request)
{
    new f = GetPlayerIdFamily(playerid);
    new target_account_id = GetPVarInt(playerid, "family_gui_target_accid");
    new action_type = -1;
    new action_value = -1;
    new targetid;
    new success = 0;
    new new_rank;
    new mute_time;
    new new_mute;
    new vig_count;
    new new_vig;
    new player_name[MAX_PLAYER_NAME + 1];
    new target_name[MAX_PLAYER_NAME + 1];
    new notify_text[144];
    new family_text[200];
    new target_text[144];

    if(f == -1 || target_account_id <= 0)
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    if(JSON_GetType(request, "r") != JSON_NODE_NUMBER)
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    JSON_GetInt(request, "r", action_type);
    JSON_GetInt(request, "k", action_value);

    if(target_account_id == GetPlayerAccountID(playerid))
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Вы не можете взаимодействовать с собой.", " ");
        return FamilyGuiSendPlayerActionResult(playerid, 0);
    }

    targetid = FamilyGuiFindOnlinePlayerByAccount(target_account_id);
    if(targetid == INVALID_PLAYER_ID)
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    if(GetPlayerIdFamily(targetid) != f)
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    if(GetFamily(f, family_owner) == target_account_id)
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    if(GetPlayerRangFamily(targetid) >= GetPlayerRangFamily(playerid))
        return FamilyGuiSendPlayerActionResult(playerid, 0);

    format(player_name, sizeof player_name, "%s", GetPlayerNameEx(playerid));
    format(target_name, sizeof target_name, "%s", GetPlayerNameEx(targetid));

    switch(action_type)
    {
        case 0:
        {
            if((!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][2]) && GetPlayerRangFamily(playerid) != 5)
                return FamilyGuiSendPlayerActionResult(playerid, 0);

            new_rank = GetPlayerRangFamily(targetid);

            if(action_value == 0 && new_rank > 1)
                new_rank--;
            else if(action_value == 1 && (new_rank + 1) < GetPlayerRangFamily(playerid))
                new_rank++;

            if(new_rank != GetPlayerRangFamily(targetid))
            {
                SetPlayerFamily(targetid, RANG_FAMILY, new_rank);
                UpdatePlayerDatabaseInt(targetid, "family_rang", new_rank);

                format(notify_text, sizeof notify_text, "Вы установили %d ранг игроку %s", new_rank, target_name);
                ShowNotificationNew(playerid, 3, 6, 0, 0, notify_text, " ");

                format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s изменил Вам семейный ранг на %d", player_name, new_rank);
                SendClientMessage(targetid, -1, target_text);

                format(family_text, sizeof family_text, "%s[%d] изменил ранг на %d игроку %s", player_name, playerid, new_rank, target_name);
                SendFamilyMessage(f, family_text);
                SendFamilyLog(type_log_rang, playerid, targetid, family_text);
                success = 1;
            }
        }
        case 1:
        {
            if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][3])
                return FamilyGuiSendPlayerActionResult(playerid, 0);

            vig_count = GetPlayerFamily(targetid, VIG_FAMILY);
            new_vig = vig_count;

            if(action_value == 0 && new_vig > 0)
                new_vig--;
            else if(action_value == 1 && new_vig < 3)
                new_vig++;

            if(new_vig != vig_count)
            {
                SetPlayerFamily(targetid, VIG_FAMILY, new_vig);
                UpdatePlayerDatabaseInt(targetid, "family_vig", new_vig);

                if(action_value == 1)
                    format(notify_text, sizeof notify_text, "Вы увеличили выговоры %d/3 игроку %s", new_vig, target_name);
                else
                    format(notify_text, sizeof notify_text, "Вы уменьшили выговоры %d/3 игроку %s", new_vig, target_name);
                ShowNotificationNew(playerid, 3, 6, 0, 0, notify_text, " ");

                if(action_value == 1)
                    format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s выдал Вам семейный выговор, теперь у Вас %d/3", player_name, new_vig);
                else
                    format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s изменил Вам семейные выговоры, теперь у Вас %d/3", player_name, new_vig);
                SendClientMessage(targetid, -1, target_text);

                format(family_text, sizeof family_text, "%s[%d] изменил кол-во выговоров %s теперь %d/3", player_name, playerid, target_name, new_vig);
                SendFamilyMessage(f, family_text);

                if(new_vig >= 3)
                {
                    FamilyGuiRemoveMemberFromFamily(targetid, target_account_id);
                    AddFamily(f, family_count_people, -, 1);

                    format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s выгнал вас из семьи.", player_name);
                    SendClientMessage(targetid, -1, target_text);
                    format(notify_text, sizeof notify_text, "%s выгнал вас из семьи.", player_name);
                    ShowNotificationNew(targetid, 3, 6, 0, 0, notify_text, " ");

                    format(family_text, sizeof family_text, "%s[%d] выгнал игрока %s", player_name, playerid, target_name);
                    SendFamilyMessage(f, family_text);
                    SendFamilyLog(type_log_kick, playerid, targetid, family_text);
                    FamilyGuiResetPlayerState(playerid);
                }

                success = 1;
            }
        }
        case 2:
        {
            if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][3])
                return FamilyGuiSendPlayerActionResult(playerid, 0);

            mute_time = GetPlayerFamily(targetid, MUTE_FAMILY);
            new_mute = mute_time;

            if(action_value == 0)
            {
                if(mute_time > 0)
                {
                    if(mute_time < 600) new_mute = 0;
                    else new_mute = mute_time - 600;
                }
            }
            else if(action_value == 1)
            {
                if(mute_time > 3000) new_mute = 3600;
                else new_mute = mute_time + 600;
            }

            if(new_mute != mute_time)
            {
                SetPlayerFamily(targetid, MUTE_FAMILY, new_mute);
                UpdatePlayerDatabaseInt(targetid, "family_mute", new_mute);

                format(notify_text, sizeof notify_text, "Вы изменили время семейного мута на %d минут игроку %s", new_mute / 60, target_name);
                ShowNotificationNew(playerid, 3, 6, 0, 0, notify_text, " ");

                format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s изменил Вам время семейного мута на %d минут", player_name, new_mute / 60);
                SendClientMessage(targetid, -1, target_text);

                format(family_text, sizeof family_text, "%s[%d] изменил время мута игроку %s, осталось %d минут", player_name, playerid, target_name, new_mute / 60);
                SendFamilyMessage(f, family_text);
                success = 1;
            }
        }
        case 3:
        {
            if((!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][1]) && GetPlayerRangFamily(playerid) != 5)
                return FamilyGuiSendPlayerActionResult(playerid, 0);

            if(FamilyGuiRemoveMemberFromFamily(targetid, target_account_id))
            {
                AddFamily(f, family_count_people, -, 1);

                format(notify_text, sizeof notify_text, "Вы уволили игрока %s", target_name);
                ShowNotificationNew(playerid, 3, 6, 0, 0, notify_text, " ");

                format(target_text, sizeof target_text, "{FFFF00}{FFFFFF}%s выгнал вас из семьи.", player_name);
                SendClientMessage(targetid, -1, target_text);
                format(notify_text, sizeof notify_text, "%s выгнал вас из семьи.", player_name);
                ShowNotificationNew(targetid, 3, 6, 0, 0, notify_text, " ");

                format(family_text, sizeof family_text, "%s[%d] выгнал игрока %s", player_name, playerid, target_name);
                SendFamilyMessage(f, family_text);
                SendFamilyLog(type_log_kick, playerid, targetid, family_text);

                FamilyGuiResetPlayerState(playerid);
                success = 1;
            }
        }
    }

    return FamilyGuiSendPlayerActionResult(playerid, success);
}

stock FamilyGuiResolveBlacklistTarget(const target_input[], &account_id, player_name[], name_size = sizeof player_name, &target_family_sql_id)
{
    new query[144];
    new Cache:cache;

    account_id = -1;
    target_family_sql_id = -1;
    player_name[0] = '\0';

    if(!strlen(target_input))
        return 0;

    if(FamilyGuiIsNumericString(target_input))
    {
        new numeric_value = strval(target_input);

        if(numeric_value < 0)
            return 0;

        if(numeric_value < MAX_PLAYERS && IsPlayerConnected(numeric_value) && IsPlayerLogged(numeric_value))
        {
            account_id = GetPlayerAccountID(numeric_value);
            format(player_name, name_size, "%s", GetPlayerNameEx(numeric_value));
            target_family_sql_id = GetPlayerFamily(numeric_value, ID_SQL_FAMILY);
            return 1;
        }

        account_id = numeric_value;
        if(account_id <= 0)
            return 0;

        mysql_format(mysql, query, sizeof query, "SELECT id, name, family_id FROM accounts WHERE id = %d LIMIT 1", account_id);
        cache = mysql_query(mysql, query, true);

        if(cache_num_rows())
        {
            cache_get_field_content(0, "name", player_name, mysql, name_size);
            target_family_sql_id = cache_get_field_content_int(0, "family_id");
            cache_delete(cache);
            return 1;
        }

        cache_delete(cache);
        return 0;
    }

    foreach(new targetid : Player)
    {
        if(strcmp(target_input, GetPlayerNameEx(targetid), true))
            continue;

        account_id = GetPlayerAccountID(targetid);
        format(player_name, name_size, "%s", GetPlayerNameEx(targetid));
        target_family_sql_id = GetPlayerFamily(targetid, ID_SQL_FAMILY);
        return 1;
    }

    mysql_format(mysql, query, sizeof query, "SELECT id, name, family_id FROM accounts WHERE name = '%e' LIMIT 1", target_input);
    cache = mysql_query(mysql, query, true);

    if(!cache_num_rows())
    {
        cache_delete(cache);
        return 0;
    }

    account_id = cache_get_field_content_int(0, "id");
    target_family_sql_id = cache_get_field_content_int(0, "family_id");
    cache_get_field_content(0, "name", player_name, mysql, name_size);
    cache_delete(cache);
    return 1;
}

stock FamilyGuiIsBlacklisted(family_sql_id, account_id)
{
    new query[128];
    new Cache:cache;
    new found = 0;

    if(family_sql_id <= 0 || account_id <= 0)
        return 0;

    mysql_format(mysql, query, sizeof query, "SELECT account_id FROM familyblack WHERE family_id = %d AND account_id = %d LIMIT 1", family_sql_id, account_id);
    cache = mysql_query(mysql, query, true);
    found = cache_num_rows() > 0;
    cache_delete(cache);
    return found;
}

stock FamilyGuiShowBlacklistMenu(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    Dialog(
        playerid, 2368, DIALOG_STYLE_LIST,
        "{FF0000}Черный список",
        "{FFFFFF}1. Добавить в черный список\n"\
        "{FFFFFF}2. Удалить из черного списка\n"\
        "{FFFFFF}3. Просмотреть черный список",
        "Далее", "Назад"
    );
    return 1;
}

stock FamilyGuiShowBlacklistList(playerid, page, notify_if_empty = 0)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new query[256];
    new dialog[4096];
    new entry_text[160];
    new title[64];
    new date_text[32];
    new player_name[32];
    new total_rows = 0;
    new offset = 0;
    new rows = 0;

    if(family_sql_id == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    if(page < 0)
        page = 0;

    offset = page * 15;
    printf("[FAMILY_BLACKLIST][OPEN] player=%d family_sql_id=%d page=%d offset=%d", playerid, family_sql_id, page, offset);
    mysql_format(mysql, query, sizeof query, "SELECT COUNT(*) AS cnt FROM familyblack WHERE family_id = %d", family_sql_id);
    printf("[FAMILY_BLACKLIST][OPEN] count_query=%s", query);
    new Cache:count_cache = mysql_query(mysql, query, true);
    if(cache_num_rows())
        total_rows = cache_get_field_content_int(0, "cnt");
    printf("[FAMILY_BLACKLIST][OPEN] total_rows=%d errno=%d count_cache=%d", total_rows, mysql_errno(), _:count_cache);
    cache_delete(count_cache);

    if(!total_rows)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Игроки не найдены", " ");
        return 0;
    }

    if(offset >= total_rows)
    {
        if(notify_if_empty)
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Игроки не найдены", " ");
        return 0;
    }

    mysql_format(mysql, query, sizeof query, "SELECT fb.account_id, fb.created_at, DATE_FORMAT(FROM_UNIXTIME(fb.created_at), '%%Y-%%m-%%d %%H:%%i:%%s') AS created_text, a.name AS account_name FROM familyblack fb LEFT JOIN accounts a ON a.id = fb.account_id WHERE fb.family_id = %d ORDER BY fb.created_at DESC LIMIT 15 OFFSET %d", family_sql_id, offset);
    printf("[FAMILY_BLACKLIST][OPEN] list_query=%s", query);
    new Cache:cache = mysql_query(mysql, query, true);
    rows = cache_num_rows();
    printf("[FAMILY_BLACKLIST][OPEN] list_rows=%d errno=%d cache=%d", rows, mysql_errno(), _:cache);

    if(!rows)
    {
        cache_delete(cache);
        if(notify_if_empty || !page)
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Игроки не найдены", " ");
        return 0;
    }

    format(dialog, sizeof dialog, "{FFFFFF}Следующая страница\n{FFFFFF}Предыдущая страница\n");
    for(new i; i < rows; i++)
    {
        new account_id = cache_get_field_content_int(i, "account_id");

        cache_get_field_content(i, "account_name", player_name, mysql, sizeof player_name);
        if(!strlen(player_name))
            format(player_name, sizeof player_name, "ID %d", account_id);

        cache_get_field_content(i, "created_text", date_text, mysql, sizeof date_text);
        if(!strlen(date_text))
            FamilyGuiFormatDateTime(cache_get_field_content_int(i, "created_at"), date_text, sizeof date_text);

        printf("[FAMILY_BLACKLIST][OPEN] row=%d account_id=%d name=%s created_at=%d created_text=%s", i, account_id, player_name, cache_get_field_content_int(i, "created_at"), date_text);
        format(entry_text, sizeof entry_text, "%s %s\n", player_name, date_text);
        strcat(dialog, entry_text);
        SetPlayerListitemValue(playerid, i + 2, account_id);
    }
    cache_delete(cache);
    cache_set_active(Cache:0);

    SetPVarInt(playerid, "family_blacklist_page", page);
    format(title, sizeof title, "{FF0000}Список игроков: %d", page + 1);
    Dialog(playerid, 2371, DIALOG_STYLE_LIST, title, dialog, "Выбрать", "Назад");
    return 1;
}

stock FamilyGuiHandleBlacklistAdd(playerid, const inputtext[])
{
    new family_id = GetPlayerIdFamily(playerid);
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new raw_target[32];
    new raw_reason[64];
    new target_input[32];
    new reason[64];
    new target_name[32];
    new query[256];
    new comma_pos = strfind(inputtext, ",", true);
    new account_id = -1;
    new target_family_sql_id = -1;

    if(family_id == -1 || family_sql_id == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    if(GetPlayerRangFamily(playerid) != 5)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Только лидер семьи может управлять черным списком.", " ");

    if(comma_pos == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите никнейм или ID и причину через запятую.", " ");

    strmid(raw_target, inputtext, 0, comma_pos, sizeof raw_target);
    strmid(raw_reason, inputtext, comma_pos + 1, strlen(inputtext), sizeof raw_reason);
    FamilyGuiTrimString(raw_target, target_input, sizeof target_input);
    FamilyGuiTrimString(raw_reason, reason, sizeof reason);

    if(!strlen(target_input) || !strlen(reason))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите никнейм или ID и причину через запятую.", " ");

    if(!FamilyGuiResolveBlacklistTarget(target_input, account_id, target_name, sizeof target_name, target_family_sql_id))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Данный игрок не найден.", " ");

    if(target_family_sql_id == family_sql_id)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Игрок должен быть уволен из семьи.", " ");

    if(FamilyGuiIsBlacklisted(family_sql_id, account_id))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Данный игрок уже находиться в черном списке.", " ");

    mysql_format(mysql, query, sizeof query, "INSERT INTO familyblack (family_id, account_id, reason, created_at) VALUES (%d, %d, '%e', %d)", family_sql_id, account_id, reason, gettime());
    mysql_query(mysql, query, false);
    if(mysql_errno())
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Не удалось обновить черный список.", " ");

    format(f_string144, sizeof f_string144, "%s[%d] добавил в черный список %s. Причина: %s", GetPlayerNameEx(playerid), playerid, target_name, reason);
    SendFamilyMessage(family_id, f_string144);
    return ShowNotificationNew(playerid, 3, 6, 0, 0, "Игрок добавлен в черный список.", " ");
}

stock FamilyGuiHandleBlacklistRemove(playerid, const inputtext[])
{
    new family_id = GetPlayerIdFamily(playerid);
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new target_input[32];
    new target_name[32];
    new query[192];
    new account_id = -1;
    new target_family_sql_id = -1;

    if(family_id == -1 || family_sql_id == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", " ");

    if(GetPlayerRangFamily(playerid) != 5)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Только лидер семьи может управлять черным списком.", " ");

    FamilyGuiTrimString(inputtext, target_input, sizeof target_input);
    if(!strlen(target_input))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите никнейм или ID игрока.", " ");

    if(!FamilyGuiResolveBlacklistTarget(target_input, account_id, target_name, sizeof target_name, target_family_sql_id))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Данный игрок не найден.", " ");

    if(!FamilyGuiIsBlacklisted(family_sql_id, account_id))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Данного игрока нет в черном списке!", " ");

    mysql_format(mysql, query, sizeof query, "DELETE FROM familyblack WHERE family_id = %d AND account_id = %d", family_sql_id, account_id);
    mysql_query(mysql, query, false);
    if(mysql_errno())
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Не удалось обновить черный список.", " ");

    format(f_string144, sizeof f_string144, "%s[%d] удалил из черного списка %s.", GetPlayerNameEx(playerid), playerid, target_name);
    SendFamilyMessage(family_id, f_string144);
    return ShowNotificationNew(playerid, 3, 6, 0, 0, "Игрок удален из черного списка.", " ");
}

stock FamilyGuiSendUpgradeState(playerid)
{
    new Node:response = JSON_Object();
    new storage_level = 1;
    new weapon_level = 1;
    new compound_level = 1;
    new current_money = 0;

    if(GetPlayerIdFamily(playerid) != -1)
    {
        new f = GetPlayerIdFamily(playerid);
        storage_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_storage));
        weapon_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_weapon));
        compound_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_compound));
        current_money = GetFamily(f, family_money);
    }

    JSON_SetInt(response, "t", 4);
    JSON_SetInt(response, "m", current_money);
    JSON_SetArray(response, "y", JSON_Array(
        JSON_Int(storage_level),
        JSON_Int(weapon_level),
        JSON_Int(compound_level)
    ));
    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiHandleUpgradePurchase(playerid, upgrade_id)
{
    new f = GetPlayerIdFamily(playerid);
    new current_level = 0;
    new price = 0;
    new new_level = 0;
    new Node:response;

    if(f == -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "У вас нет семьи.", "OK");

    if(GetPlayerRangFamily(playerid) != 5)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Только лидер семьи может улучшать семью.", "OK");

    switch(upgrade_id)
    {
        case 0:
        {
            current_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_storage));
            if(current_level >= 7)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Улучшение уже максимального уровня.", "OK");
            price = price_up_sklad[current_level];
            if(GetFamily(f, family_money) < price)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "На складе недостаточно денег для улучшения.", "OK");
            new_level = current_level + 1;
            AddFamily(f, family_money, -, price);
            SetFamily(f, family_lvl_storage, new_level);
            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_storage", new_level);
            format(f_string144, sizeof f_string144, "%s улучшил склад до %d уровня.", GetPlayerNameEx(playerid), new_level);
        }
        case 1:
        {
            current_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_weapon));
            if(current_level >= 7)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Улучшение уже максимального уровня.", "OK");
            price = price_up_weapon[current_level];
            if(GetFamily(f, family_money) < price)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "На складе недостаточно денег для улучшения.", "OK");
            new_level = current_level + 1;
            AddFamily(f, family_money, -, price);
            SetFamily(f, family_lvl_weapon, new_level);
            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_weapon", new_level);
            format(f_string144, sizeof f_string144, "%s улучшил оружие до %d уровня.", GetPlayerNameEx(playerid), new_level);
        }
        case 2:
        {
            current_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_compound));
            if(current_level >= 7)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "Улучшение уже максимального уровня.", "OK");
            price = price_up_compound[current_level];
            if(GetFamily(f, family_money) < price)
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "На складе недостаточно денег для улучшения.", "OK");
            new_level = current_level + 1;
            AddFamily(f, family_money, -, price);
            SetFamily(f, family_lvl_compound, new_level);
            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_compound", new_level);
            format(f_string144, sizeof f_string144, "%s улучшил состав до %d уровня.", GetPlayerNameEx(playerid), new_level);
        }
        default: return ShowNotificationNew(playerid, 2, 6, 0, 0, "Неизвестное улучшение.", "OK");
    }

    UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));
    SendFamilyMessage(f, f_string144);

    response = JSON_Object();
    JSON_SetInt(response, "t", 4);
    JSON_SetInt(response, "s", 1);
    JSON_SetInt(response, "id", upgrade_id);
    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}
stock FamilyGuiSendMain(playerid)
{
    new Node:response = JSON_Object();
    new player_skin = GetPlayerSkin(playerid);

    JSON_SetInt(response, "t", 5);
    JSON_SetInt(response, "s", player_skin);

    if(GetPlayerIdFamily(playerid) != -1)
    {
        new f = GetPlayerIdFamily(playerid);
        new storage_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_storage));
        new weapon_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_weapon));
        new compound_level = FamilyGuiClampLevel(GetFamily(f, family_lvl_compound));

        JSON_SetInt(response, "r", GetFamily(f, family_reputation));
        JSON_SetInt(response, "am", FamilyGuiGetActualMemberCount(playerid));
        JSON_SetArray(response, "ug", JSON_Array(
            JSON_Int(storage_level),
            JSON_Int(7),
            JSON_Int(weapon_level),
            JSON_Int(7),
            JSON_Int(compound_level),
            JSON_Int(7)
        ));
        JSON_SetArray(response, "my", JSON_Array(
            JSON_Int(GetFamily(f, family_money)),
            JSON_Int(count_money_level[storage_level - 1])
        ));
        JSON_SetArray(response, "ms", JSON_Array(
            JSON_Int(GetFamily(f, family_material)),
            JSON_Int(count_material_level[storage_level - 1])
        ));
        JSON_SetArray(response, "mk", JSON_Array(
            JSON_Int(GetFamily(f, family_mask)),
            JSON_Int(count_mask_level[storage_level - 1])
        ));
        JSON_SetArray(response, "kb", JSON_Array(
            JSON_Int(GetFamily(f, family_heath_kit)),
            JSON_Int(count_heath_kit_level[storage_level - 1])
        ));
        JSON_SetArray(response, "pn", JSON_Array(
            JSON_Int(GetFamily(f, family_patron)),
            JSON_Int(count_patron_level[weapon_level - 1])
        ));
        JSON_SetArray(response, "bt", JSON_Array(
            JSON_Int(GetFamily(f, family_armour)),
            JSON_Int(count_armour_level[storage_level - 1])
        ));
    }
    else
    {
        JSON_SetInt(response, "r", 0);
        JSON_SetInt(response, "am", 0);
        JSON_SetArray(response, "ug", JSON_Array(JSON_Int(1), JSON_Int(7), JSON_Int(1), JSON_Int(7), JSON_Int(1), JSON_Int(7)));
        JSON_SetArray(response, "my", JSON_Array(JSON_Int(0), JSON_Int(count_money_level[0])));
        JSON_SetArray(response, "ms", JSON_Array(JSON_Int(0), JSON_Int(count_material_level[0])));
        JSON_SetArray(response, "mk", JSON_Array(JSON_Int(0), JSON_Int(count_mask_level[0])));
        JSON_SetArray(response, "kb", JSON_Array(JSON_Int(0), JSON_Int(count_heath_kit_level[0])));
        JSON_SetArray(response, "pn", JSON_Array(JSON_Int(0), JSON_Int(count_patron_level[0])));
        JSON_SetArray(response, "bt", JSON_Array(JSON_Int(0), JSON_Int(count_armour_level[0])));
    }

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiSendNotifications(playerid)
{
    new Node:response = JSON_Object();
    new Node:message_list = JSON_Array();
    new Node:id_list = JSON_Array();
    new ids[FAMILY_GUI_NOTIF_LIMIT];
    new values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN];
    new authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new count = 0;

    FamilyGuiLoadNotifications(playerid, ids, values, authors, count);

    for(new i; i < count; i++)
    {
        message_list = JSON_Append(message_list, JSON_Array(JSON_String(values[i])));
        message_list = JSON_Append(message_list, JSON_Array(JSON_String(authors[i])));
        id_list = JSON_Append(id_list, JSON_Array(JSON_Int(ids[i])));
    }

    JSON_SetInt(response, "t", 6);
    JSON_SetArray(response, "m", message_list);
    JSON_SetArray(response, "x", id_list);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    FamilyGuiSetNotificationReadState(playerid, FamilyGuiGetSqlFamilyId(playerid), FamilyGuiGetNotificationMaxId(ids, count));
    return 1;
}

stock FamilyGuiSendRating(playerid)
{
    new Node:response = JSON_Object();
    new Node:name_list = JSON_Array();
    new Node:value_list = JSON_Array();
    new my_position = 0;
    new my_type = 0;
    new my_reputation = 0;
    new my_zaxvati = 0;
    new my_family_sql_id = FamilyGuiGetSqlFamilyId(playerid);

    if(my_family_sql_id != -1)
    {
        mysql_format(mysql, f_string184, sizeof f_string184, "SELECT syndicate, reputation, zaxvati FROM familynew WHERE id = %d LIMIT 1", my_family_sql_id);
        new Cache:my_cache = mysql_query(mysql, f_string184, true);

        if(cache_num_rows())
        {
            my_type = cache_get_field_content_int(0, "syndicate");
            my_reputation = cache_get_field_content_int(0, "reputation");
            my_zaxvati = cache_get_field_content_int(0, "zaxvati");
        }

        cache_delete(my_cache);
    }

    mysql_format(mysql, f_string144, sizeof f_string144, "SELECT id, name, reputation, zaxvati, syndicate FROM familynew WHERE reputation >= 0 ORDER BY reputation DESC, zaxvati DESC LIMIT 10");
    new Cache:cache = mysql_query(mysql, f_string144, true);

    for(new i, rows = cache_num_rows(); i < rows; i++)
    {
        new family_sql_id = cache_get_field_content_int(i, "id");
        new family_name_sql[32];
        new family_type_sql = cache_get_field_content_int(i, "syndicate");
        new family_reputation_sql = cache_get_field_content_int(i, "reputation");
        new family_zaxvati_sql = cache_get_field_content_int(i, "zaxvati");

        cache_get_field_content(i, "name", family_name_sql, mysql, sizeof family_name_sql);

        if(my_family_sql_id != -1 && my_family_sql_id == family_sql_id)
        {
            my_position = i + 1;
        }

        name_list = JSON_Append(name_list, JSON_Array(JSON_String(family_name_sql)));
        value_list = JSON_Append(value_list, JSON_Array(JSON_Int(family_reputation_sql)));
        value_list = JSON_Append(value_list, JSON_Array(JSON_Int(family_zaxvati_sql)));
        value_list = JSON_Append(value_list, JSON_Array(JSON_Int(family_type_sql)));
    }

    cache_delete(cache);

    JSON_SetInt(response, "t", 7);
    JSON_SetInt(response, "p", my_position);
    JSON_SetInt(response, "tp", my_type);
    JSON_SetInt(response, "tr", my_reputation);
    JSON_SetInt(response, "tz", my_zaxvati);
    JSON_SetArray(response, "mn", name_list);
    JSON_SetArray(response, "m", value_list);

    OnPacketIncoming(playerid, 45, response);
    JSON_Cleanup(response);
    return 1;
}

stock FamilyGuiHandleNotificationCreate(playerid, Node:request)
{
    new family_sql_id = FamilyGuiGetSqlFamilyId(playerid);
    new ids[FAMILY_GUI_NOTIF_LIMIT];
    new values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN];
    new authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new count = 0;
    new input_text[FAMILY_GUI_NOTIF_TEXT_LEN];
    new clean_text[FAMILY_GUI_NOTIF_TEXT_LEN];
    new author[FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new new_id = 1;

    if(GetPlayerIdFamily(playerid) == -1)
        return 0;

    if(GetPlayerRangFamily(playerid) != 5)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Только лидер семьи может добавлять уведомления", "qq");

    if(JSON_GetType(request, "m") != JSON_NODE_STRING)
        return 0;

    JSON_GetString(request, "m", input_text, sizeof input_text);
    utf8_to_cp1251(input_text);
    FamilyGuiSanitizeNotificationText(input_text, clean_text, sizeof clean_text);

    if(!strlen(clean_text))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Введите текст в поле для ввода", "qq");

    FamilyGuiLoadNotifications(playerid, ids, values, authors, count);

    if(count >= FAMILY_GUI_NOTIF_LIMIT)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Можно добавить только 5 уведомлений", "qq");

    new_id = FamilyGuiReserveNotificationId(playerid, FamilyGuiGetNotificationMaxId(ids, count));

    for(new i = count; i > 0; i--)
    {
        ids[i] = ids[i - 1];
        format(values[i], FAMILY_GUI_NOTIF_TEXT_LEN, "%s", values[i - 1]);
        format(authors[i], FAMILY_GUI_NOTIF_AUTHOR_LEN, "%s", authors[i - 1]);
    }

    ids[0] = new_id;
    format(values[0], FAMILY_GUI_NOTIF_TEXT_LEN, "%s", clean_text);
    format(author, sizeof author, "%s", GetPlayerNameEx(playerid));
    format(authors[0], FAMILY_GUI_NOTIF_AUTHOR_LEN, "%s", author);
    count++;

    if(!FamilyGuiSaveNotifications(playerid, ids, values, authors, count))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Не удалось сохранить уведомление", "qq");

    FamilyGuiSetNotificationReadState(playerid, family_sql_id, ids[0]);
    return FamilyGuiSendNotificationAdded(playerid, values[0], authors[0], ids[0]);
}

stock FamilyGuiHandleNotificationDelete(playerid, Node:request)
{
    new ids[FAMILY_GUI_NOTIF_LIMIT];
    new values[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_TEXT_LEN];
    new authors[FAMILY_GUI_NOTIF_LIMIT][FAMILY_GUI_NOTIF_AUTHOR_LEN];
    new count = 0;
    new delete_id = -1;
    new delete_index = -1;

    if(GetPlayerIdFamily(playerid) == -1)
        return 0;

    if(GetPlayerRangFamily(playerid) != 5)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Только лидер семьи может удалять уведомления", "qq");

    if(JSON_GetType(request, "x") != JSON_NODE_NUMBER)
        return 0;

    JSON_GetInt(request, "x", delete_id);
    FamilyGuiLoadNotifications(playerid, ids, values, authors, count);

    for(new i; i < count; i++)
    {
        if(ids[i] == delete_id)
        {
            delete_index = i;
            break;
        }
    }

    if(delete_index == -1)
        return 0;

    for(new i = delete_index; i < (count - 1); i++)
    {
        ids[i] = ids[i + 1];
        format(values[i], FAMILY_GUI_NOTIF_TEXT_LEN, "%s", values[i + 1]);
        format(authors[i], FAMILY_GUI_NOTIF_AUTHOR_LEN, "%s", authors[i + 1]);
    }

    count--;

    if(!FamilyGuiSaveNotifications(playerid, ids, values, authors, count))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Не удалось удалить уведомление", "qq");

    return FamilyGuiSendNotificationDeleted(playerid, delete_id);
}

stock FamilyGuiHandleLeave(playerid)
{
    new f = GetPlayerIdFamily(playerid);

    if(f == -1)
        return FamilyGuiSendLeaveResult(playerid, 0);

    new f_sql = GetPlayerFamily(playerid, ID_SQL_FAMILY);

    if(GetPlayerRangFamily(playerid) != 5)
    {
        format(f_string144, sizeof f_string144, "Игрок %s покинул семью. Причина: GUI", GetPlayerNameEx(playerid));
        SendFamilyMessage(f, f_string144);
        ExitFromFamily(playerid);
        FamilyGuiResetPlayerState(playerid);
        return FamilyGuiSendLeaveResult(playerid, 1);
    }

    format(f_string144, sizeof f_string144, "Лидер %s[%d] ушел и семья закрыта. Причина: C/Ж", GetPlayerNameEx(playerid), playerid);
    SendFamilyMessage(f, f_string144);

    foreach(new i : Player)
    {
        if(GetPlayerFamily(i, ID_SQL_FAMILY) != f_sql) continue;

        ExitFromFamily(i);
        SendClientMessage(i, -1, "Ваша семья была распущена. Лидер покинул семью.");
        FamilyGuiResetPlayerState(i);
        FamilyGuiSendLeaveResult(i, 1);
    }

    mysql_format(mysql, f_string144, sizeof f_string144, "DELETE FROM family_cars WHERE family_owner = %d", f_sql);
    mysql_query(mysql, f_string144);

    mysql_format(mysql, f_string144, sizeof f_string144, "DELETE FROM family_log WHERE family = %d", f_sql);
    mysql_query(mysql, f_string144);

    mysql_format(mysql, f_string144, sizeof f_string144, "DELETE FROM family_ad WHERE family = %d", f_sql);
    mysql_query(mysql, f_string144);

    mysql_format(mysql, f_string144, sizeof f_string144, "DELETE FROM family_storage_items WHERE family_id = %d", f_sql);
    mysql_query(mysql, f_string144);

    mysql_format(mysql, f_string144, sizeof f_string144, "DELETE FROM family_ammo_storage WHERE family_id = %d", f_sql);
    mysql_query(mysql, f_string144);

    mysql_format(mysql, f_string144, sizeof f_string144, "DELETE FROM familyblack WHERE family_id = %d", f_sql);
    mysql_query(mysql, f_string144);
    mysql_format(mysql, f_string64, sizeof f_string64, "DELETE FROM familynew WHERE id = %d", f_sql);
    mysql_query(mysql, f_string64);

    mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE accounts SET family_id = -1 WHERE family_id = %d", f_sql);
    mysql_query(mysql, f_string144);

    for(new i; i < MAX_OWNABLE_CARS; i++)
    {
        if(GetCarFamily(i, OW_F_database) != f_sql) continue;
        UnLoadFamilyCar(GetCarFamily(i, CAR_F_database));
    }

    SetFamily(f, family_database, -1);
    SetFamily(f, family_color, 0);
    SetFamily(f, family_reputation, 0);
    SetFamily(f, family_zaxvati, 0);
    SetFamily(f, family_moneti, 0);
    SetFamily(f, family_syndicate, 0);
    format(family[f][family_name], 32, "");
    SetFamily(f, family_owner, 0);
    SetFamily(f, family_slot_veh, 0);
    SetFamily(f, family_count_veh, 0);
    SetFamily(f, family_count_people, 0);
    SetFamily(f, family_status_storage, 0);
    SetFamily(f, family_money, 0);
    SetFamily(f, family_armour, 0);
    SetFamily(f, family_material, 0);
    SetFamily(f, family_heath_kit, 0);
    SetFamily(f, family_patron, 0);
    SetFamily(f, family_mask, 0);
    SetFamily(f, family_lvl_storage, 0);
    SetFamily(f, family_lvl_weapon, 0);
    SetFamily(f, family_lvl_compound, 0);

    return 1;
}

stock FamilyGuiHandlePacket(playerid, Node:request)
{
    new type = 0;
    JSON_GetInt(request, "t", type);

    switch(type)
    {
        case 3:
        {
            new shop_id = -1;
            JSON_GetInt(request, "id", shop_id);
            return FamilyGuiHandleShopPurchase(playerid, shop_id);
        }
        case 2:
        {
            new status = 0;
            JSON_GetInt(request, "s", status);

            switch(status)
            {
                case 1:
                {
                    new sql_id = 0;
                    JSON_GetInt(request, "id", sql_id);
                    return FamilyGuiSendCarInfo(playerid, sql_id);
                }
                case 2:
                {
                    return FamilyGuiHandleCarAction(playerid, request);
                }
            }

            return FamilyGuiSendCarList(playerid);
        }
        case 4:
        {
            new status = 0;
            new upgrade_id = -1;
            JSON_GetInt(request, "s", status);
            JSON_GetInt(request, "id", upgrade_id);

            if(status == 1)
                return FamilyGuiHandleUpgradePurchase(playerid, upgrade_id);

            return FamilyGuiSendUpgradeState(playerid);
        }
        case 5:
        {
            new menu_id = 0;
            new status = 0;
            new selected_name[24];

            JSON_GetInt(request, "id", menu_id);
            JSON_GetInt(request, "s", status);
            JSON_GetString(request, "n", selected_name, sizeof selected_name);

            if(menu_id == 0)
                return FamilyGuiSendMain(playerid);

            if(menu_id == 1)
            {
                switch(status)
                {
                    case 1: return FamilyGuiHandleFamilySettingRank(playerid, request);
                    case 2: return FamilyGuiHandleFamilySettingAccess(playerid, request);
                    case 3: return FamilyGuiHandleFamilySettingColor(playerid, request);
                }

                return FamilyGuiSendFamilySettings(playerid);
            }

            if(menu_id == 2)
            {
                switch(status)
                {
                    case 1: return FamilyGuiSendPlayerInfo(playerid, selected_name);
                    case 2: return FamilyGuiHandlePlayerAction(playerid, request);
                }

                return FamilyGuiSendPlayerList(playerid);
            }

            if(menu_id == 3)
            {
                return FamilyStorageHandleGuiAction(playerid, request);
            }

            if(menu_id == 4)
            {
                return FamilyGuiShowLogsMenu(playerid);
            }

            if(menu_id == 5)
            {
                return FamilyGuiShowBlacklistMenu(playerid);
            }
            return ShowNotificationNew(playerid, 2, 6, 0, 0, "Раздел временно недоступен.", "OK");
        }
        case 6:
        { 
            new action = 0;
            JSON_GetInt(request, "b", action);

            if(action == 1)
                return FamilyGuiHandleNotificationCreate(playerid, request);

            if(action == 2)
                return FamilyGuiHandleNotificationDelete(playerid, request);

            return FamilyGuiSendNotifications(playerid);
        }
        case 7:
        {
            return FamilyGuiSendRating(playerid);
        }
        case 9:
        {
            new status = 0;
            new value = 0;

            JSON_GetInt(request, "s", status);
            JSON_GetInt(request, "v", value);
            return FamilyGuiHandleTokenAction(playerid, status, value);
        }
        case 10:
        {
            return FamilyGuiHandleLeave(playerid);
        }
    }

    return 1;
}
// FAMILY_GUI_ADAPTER_EMBED_END

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new f = GetPlayerIdFamily(playerid);

    if(FamilyStorage_OnDialogResponse(playerid, dialogid, response, listitem, inputtext))
        return 1;

    if(dialogid == 2220)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    if(GetPVarInt(playerid, "input_ad_family")) DeletePVar(playerid, "input_ad_family");

                    Dialog
                    (
                        playerid, 2228, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Объявления",
                        "Для того чтобы создавать объявление нажмите - 2\nЧтобы просмотреть текущие объявления нажмите - 1",
                        "2","1"
                    );
                }
                case 1:
                {
                    new string[424], name[24];

                    mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM accounts WHERE id=%d", GetFamily(f, family_owner));
                    new Cache:cache = mysql_query(mysql, f_string64);

                    if(mysql_errno())
                        return SendClientMessage(playerid,-1,""c_f_r"Ошибка в SQL-запросе / Code: Select Name Owner Family");

                    cache_get_field_content(0, "name", name, mysql, 24);                    
                    cache_delete(cache);

                    format
                    (
                        string, sizeof string, 
                        "Создатель семьи: %s\n"\
                        "Репутация: %d\n"\
                        "Количество людей: %d\n\n"\
                        "Улучшение склада: %d/7\n"\
                        "Улучшение оружия: %d/7\n"\
                        "Улучшение состава: %d/7\n\n"\
                        "Деньги: %d/%d рублей\n"\
                        "Материалов: %d/%d шт.\n"\
                        "Масок: %d/%d шт.\n"\
                        "Бронежилеты: %d/%d шт.\n"\
                        "Патрон: %d/%d шт.",
                        name,
                        GetFamily(f, family_reputation),
                        GetFamily(f, family_count_people),
                        GetFamily(f, family_lvl_storage),
                        GetFamily(f, family_lvl_weapon),
                        GetFamily(f, family_lvl_compound),
                        GetFamily(f, family_money), count_money_level[GetFamily(f, family_lvl_storage)-1],
                        GetFamily(f, family_material), count_material_level[GetFamily(f, family_lvl_weapon)-1],
                        GetFamily(f, family_mask), count_mask_level[GetFamily(f, family_lvl_storage)-1],
                        GetFamily(f, family_armour), count_armour_level[GetFamily(f, family_lvl_storage)-1],
                        GetFamily(f, family_patron), count_patron_level[GetFamily(f, family_lvl_weapon)-1]
                    );

                    Dialog(playerid, -1, DIALOG_STYLE_MSGBOX, "Информация", string, "Выйти", "");
                }
                case 2:
                {
                    if(GetPlayerRangFamily(playerid) != 5)
                        return SendClientMessage(playerid, -1, ""c_f_r"Доступно только лидеру.");
                    
                    DeletePVar(playerid, "select_color_chat");
                    DeletePVar(playerid, "select_setting_rang");
                    DeletePVar(playerid, "select_rang");
                    DeletePVar(playerid, "setting_select");
                    DeletePVar(playerid, "name_select");

                    Dialog
                    (
                        playerid, 2232, DIALOG_STYLE_LIST,
                        "{FF0000}Настройка семьи",
                        "1. Настройка рангов\n"\
                        "2. Настройка цвета чата",
                        "Далее", "Назад"
                    );
                }
                case 3:
                {
                    DeletePVar(playerid, "select_type_2236");

                    Dialog
                    (
                        playerid, 2236, DIALOG_STYLE_LIST,
                        "{FF0000}Управление семьей",
                        "1. Принять игрока\n"\
                        "2. Выгнать игрока\n"\
                        "3. Выдать мут игроку\n"\
                        "4. Снять мут игроку\n"\
                        "5. Изменить ранг игроку",
                        "Далее", "Назад"
                    );
                }
                case 4:
                {
                    format(f_string144, sizeof f_string144,
                    "| Склад: %s\n1. Взять со склада\n2. Положить на склад\n3. Доступы", GetFamily(GetPlayerIdFamily(playerid), family_status_storage) ? ("{00FF00}Открыт") : ("{FF0000}Закрыт"));

                    Dialog(playerid, 2223, DIALOG_STYLE_LIST, "{FF0000}Склад семьи", f_string144, "Далее", "Выйти");
                }
                case 5:
                {
                    mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family_cars WHERE family_owner = %d", GetPlayerFamily(playerid, ID_SQL_FAMILY));
                    new Cache:cache = mysql_query(mysql, f_string64);

                    if(mysql_errno())
                        return SendClientMessage(playerid,-1,""c_f_r" Ошибка в SQL-запросе / Code: DialogCarPark");

                    if(!cache_num_rows())
                        return SendClientMessage(playerid,-1,""c_f_r" Транспорт не найден.");

                    new rows = cache_num_rows();

                    if(rows > 10) rows = 10;

                    new model_id, id, status, dialog[4096];

                    for(new i;i< rows;i++)
                    {
                        id = cache_get_field_content_int(i, "id");
                        status = GetStatusFamilyCar(id);
                        model_id = cache_get_field_content_int(i, "model_id") - 400;

                        format(f_string144, sizeof f_string144, "{FFFFFF}%d. %s %s \n", i+1, GetVehicleInfo(model_id, VI_NAME), status ? ("{A1A1A1}[Загружена]") : ("{A1A1A1}[Выгружена]"));
                        strcat(dialog, f_string144);
                        SetPlayerListitemValue(playerid, i, id);
                    }

                    new buttom[21];
                    format(buttom, sizeof buttom, "Следующая страница");
                    strcat(dialog, buttom);
                    SetPVarInt(playerid, "count_list", 1);

                    SetPVarInt(playerid, "up_count", rows);
                    SetPVarInt(playerid, "down_count", rows+1);

                    Dialog(playerid, 2222, DIALOG_STYLE_LIST, "{FF0000}Выберите транспорт", dialog, "Далее", "Назад");
                }
                case 6:
                {
                    if(GetPlayerRangFamily(playerid) != 5)
                        return SendClientMessage(playerid, -1, ""c_f_r"Доступно только лидеру.");

                    format(f_string144, sizeof f_string144,
                    "Склад %d/7\nОружение %d/7\nСостав %d/7", GetFamily(f, family_lvl_storage), GetFamily(f, family_lvl_weapon), 
                    GetFamily(f, family_lvl_compound));

                    DeletePVar(playerid, "type_up_family");

                    Dialog(
                        playerid, 2234, DIALOG_STYLE_LIST,
                        "{FF0000}Улучшить",
                        f_string144,
                        "Далее", "Назад"
                    );
                }
                case 7:
                {
                    Dialog
                    (
                        playerid, 2245, DIALOG_STYLE_LIST,
                        "{FF0000}Рейтинг семей",
                        "1. Информация\n"\
                        "2. Список топ-семей",
                        "Далее", "Выйти"
                    );
                }
                case 8:
                {
                    if(GetPlayerRangFamily(playerid) != 5)
                        return SendClientMessage(playerid, -1, "Доступно только лидеру.");

                    DeletePVar(playerid, "select_type_log");

                    Dialog
                    (
                        playerid, 2237, DIALOG_STYLE_LIST,
                        "{FF0000}Выберите лог", 
                        "1. Принятие новых членов семьи\n"\
                        "2. Увольнение членов семьи\n"\
                        "3. Взаимодействие с деньгами склада\n"\
                        "4. Взаимодействие с материалами склада\n"\
                        "5. Взаимодействие с масками склада\n"\
                        "6. Взаимодействие с аптечкам склада\n"\
                        "7. Взаимодействие с оружием склада\n"\
                        "8. Взаимодействие с бронежилетами склада\n"\
                        "9. Взаимодействие с семейным автопарком\n"\
                        "10. Выдача рангов\n"\
                        "11. Выдача доступов",
                        "Далее", "Назад"
                    );
                }
                case 9:
                {
                    Dialog
                    (
                        playerid, 2235, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Покинуть семью",
                        "Вы уверены что хотите покинуть семью?\n"\
                        "Если вы лидер семья - удалиться.",
                        "Далее", "Назад"
                    );
                }
            }
        }
    }
    if(dialogid == 2222)
    {
        if(response)
        {
            new up = GetPVarInt(playerid, "up_count"),
            down = GetPVarInt(playerid, "down_count");

            if(listitem == up || listitem == down)
            {
                new list = GetPVarInt(playerid, "count_list");

                if(listitem == up)  list++;
                else if(listitem == down && list != 1) list--;
                SetPVarInt(playerid, "count_list", list);

                new fmt_text[4096],
                Cache: result,
                id;

                mysql_format(mysql, fmt_text, sizeof fmt_text, "SELECT * FROM family_cars WHERE family_owner='%d'", GetFamily(f, family_database));
                result = mysql_query(mysql, fmt_text, true);

                new rows = cache_num_rows();
                
                new count_rows, count = 10 * GetPVarInt(playerid, "count_list");

                if(rows >= count) count_rows = count;
                else count_rows = rows;

                format(fmt_text, sizeof fmt_text, "");

                new query[60],
                model_id,
                status;

                new count_list;
                for(new i = count-10, p; i < count_rows; i ++, p ++)
                {
                    count_list++;
                    id = cache_get_field_content_int(i, "id");
                    status = GetStatusFamilyCar(id);
                    model_id = cache_get_field_content_int(i, "model_id") - 400;

                    format(query, sizeof query, "{FFFFFF}%d. %s %s \n", i+1, GetVehicleInfo(model_id, VI_NAME), status ? ("{A1A1A1}[Загружена]") : ("{A1A1A1}[Выгружена]"));
                    strcat(fmt_text, query);
                    SetPlayerListitemValue(playerid, p, id);
                }

                new buttom[21];
                format(buttom, sizeof buttom, "Следующая страница\n");
                strcat(fmt_text, buttom);
                format(buttom, sizeof buttom, "Предыдущая страница");
                strcat(fmt_text, buttom);

                SetPVarInt(playerid, "up_count", count_list);
                SetPVarInt(playerid, "down_count", count_list+1);

                new len = strlen(fmt_text);
                printf("Длина строки: %d символов", len);
                printf("up = %d down = %d count = %d", GetPVarInt(playerid, "up_count"), GetPVarInt(playerid, "down_count"), count_rows);
                Dialog
                (
                    playerid, 2222, DIALOG_STYLE_LIST,
                    "{FF0000}Выберите транспорт",
                    fmt_text,
                    "Выбрать", "Закрыть"
                );

                cache_delete(result);

                return 1;
            }

            new id =  GetPlayerListitemValue(playerid, listitem);

            ShowDialogFamilyCar(playerid, id);
        }
    }
    if(dialogid == 2223)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    if(GetPlayerFamily(playerid, RANG_FAMILY) >= 4)
                    {
                        new status = GetFamily(f, family_status_storage);

                        SetFamily(f, family_status_storage, status^1);

                        format(f_string144, sizeof f_string144, "%s %s склад.", GetPlayerNameEx(playerid), status ? "закрыл" : "открыл");
                        SendFamilyMessage(f, f_string144);
                        callcmd::famsklad(playerid);
                    }
                    else SendClientMessage(playerid,-1,""c_f_r"Закрывать/открывать склад доступно только заместителю или лидеру семьи");
                }
                case 1:
                {
                    if(!GetFamily(f, family_status_storage) && GetPlayerFamily(playerid, RANG_FAMILY) < 5)
                        return SendClientMessage(playerid, -1,""c_f_r"Склад закрыт.");

                    ShowDialogFamilySklad(playerid, 1, false);
                }
                case 2:ShowDialogFamilySklad(playerid, 1, true);
                case 3:
                {
                    DeletePVar(playerid, "select_get_dostup");

                    if(GetPlayerFamily(playerid, ACCESS_GIVE) || GetPlayerRangFamily(playerid) == 5)
                    {
                        Dialog
                        (
                            playerid, 2230, DIALOG_STYLE_LIST,
                            "{FF000}Доступа",
                            "1. Выдать доступ\n"\
                            "2. Забрать доступ\n"\
                            "3. Просмотр доступов",
                            "Далее", "Назад"
                        );
                    }
                }
            }
        }
    }
    if(dialogid == 2225)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "type_sklad"))
            {
                new type_take_or_put;

                switch(GetPVarInt(playerid, "type_sklad"))
                {
                    case 1:type_take_or_put = false;
                    case 2:type_take_or_put = true;
                }

                SetPVarInt(playerid, "type_action_sklad", type_take_or_put+1);
                ShowDialogFamilySklad(playerid, listitem+2, type_take_or_put);
            }
        }
    }
    if(dialogid == 2224)
    {
        if(response)
        {
            new id = GetPVarInt(playerid, "select_fam_car");
            mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family_cars WHERE id=%d", id);
            new Cache:cache = mysql_query(mysql, f_string64);

            new status = GetStatusFamilyCar(id);
            new Float:x, Float:y, Float:z, rang;

            x = cache_get_field_content_float(0, "pos_x");
            y = cache_get_field_content_float(0, "pos_y");
            z = cache_get_field_content_float(0, "pos_z");
            rang = cache_get_field_content_int(0, "rang");

            new vehicle = GetVehicleFamilyCar(id), model = GetVehicleModel(vehicle);
            
            switch(listitem)
            {
                case 0:
                {
                    if(!status) EnablePlayerGPS(playerid, 55, x, y, z, "Местоположение семейного транспорта отмечено на карте.");
                    else
                    {
                        GetVehiclePos(vehicle, x, y, z);
                        EnablePlayerGPS(playerid, 55, x, y, z, "Местоположение семейного транспорта отмечено на карте.");
                    }
                }
                case 1:
                {
                    if(!status)
                    {
                       if(GetPlayerRangFamily(playerid) >= rang)
                       {
                            if(LoadFamilyCar(id))
                            {
                                ShowNotificationNew(playerid, 3, 6, 0, 0, "Автомобиль успешно загружен.", " ");
                                format(f_string144, sizeof f_string144,"%s загрузил %s.",
                                GetPlayerNameEx(playerid),
                                GetVehicleInfo(GetVehicleModel(GetVehicleFamilyCar(id))-400, VI_NAME));
                                SendFamilyMessage(GetPlayerIdFamily(playerid), f_string144);
                                SendFamilyLog(type_log_car, playerid, -1, f_string144);
                            }
                       }
                       else BackSendClientMessage(playerid, -1, ""c_f_r"Ваш ранг не позволяет загрузить этот транспорт.");
                    }
                    else
                    {
                        new vehicleid = GetVehicleFamilyCar(id);

                        if(GetVehicleDriver(vehicleid) != INVALID_PLAYER_ID && GetPlayerRangFamily(playerid) != 5)
                            return SendClientMessage(playerid, -1, ""c_f"Транспорт занят.");

                        
                        if(UnLoadFamilyCar(id))
                        {
                            ShowNotificationNew(playerid, 3, 6, 0, 0, "Вы успешно выгрузили транспорт", " ");
                            format(f_string144, sizeof f_string144, "%s выгрузил %s.",
                            GetPlayerNameEx(playerid),
                            GetVehicleInfo(model-400, VI_NAME));
                            SendFamilyMessage(GetPlayerIdFamily(playerid), f_string144);
                            SendFamilyLog(type_log_car, playerid, -1, f_string144);
                        }
                    }   
                }
                case 2:
                {
                    if((GetPlayerOwnableCars(playerid) + 1) > GetPlayerCarSlots(playerid))
						return SendClientMessage(playerid, 0x3399FFFF, ""USC"Все слоты для транспорта заняты.");

                    if(GetPlayerRangFamily(playerid) == 5) MoveFamilyCar(id, playerid);
                }
                case 3:
                {
                    if(GetPlayerRangFamily(playerid) != 5) return print("Error Family System #13423");

                    format(f_string144, sizeof f_string144, "Введите ранг для доступа к этой машине (Сейчас:%d)", rang);

                    Dialog(playerid, 2239, DIALOG_STYLE_INPUT, "{FF0000}Изменение ранга",
                    f_string144, "Далее", "Назад");
                }
            }
            cache_delete(cache);
        }
    }
    if(dialogid == 2226)
    {
        if(response)
        {
            new take_or_put = GetPVarInt(playerid, "type_action_sklad")-1, type = GetPVarInt(playerid, "select_type_sklad_use");

            switch(type)
            {
                case 2:
                {
                    new money = strval(inputtext);

                    if(!money)
                        return SendClientMessage(playerid, -1, ""c_f_r"Число должно быть больше 0");

                    if(!take_or_put)
                    {

                        if(money <= GetFamily(f, family_money))
                        {
                            if(!GetPlayerFamily(playerid, ACCESS_MONEY))
                                return SendClientMessage(playerid, -1, "У вас нет доступа.");

                            new money_access = GetPlayerFamily(playerid, ACCESS_MONEY)-money; 

                            if(money_access <= -1 && GetPlayerRangFamily(playerid) != 5) return FSendClientMessage(f_string144, playerid, -1, ""c_f_r"У вас не хватает доступа. Доступно:%d шт.", GetPlayerFamily(playerid, ACCESS_MONEY));

                            AddPlayerFamily(playerid, ACCESS_MONEY, -, money);
                            AddFamily(f, family_money, -, money);
                            GivePlayerMoneyEx(playerid, money);

                            SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склада семьи деньги.");
                            format(f_string144, sizeof f_string144, "%s взял из склада %d рублей.", GetPlayerNameEx(playerid), money);
                            SendFamilyMessage(f, f_string144);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));
                            SendFamilyLog(type_log_money, playerid, -1, f_string144);
                        }
                        else SendClientMessage(playerid, -1, ""c_f_r"У семьи нет предмета.");
                    }
                    else
                    {
                        if(!(GetFamily(f, family_money)+money <= count_money_level[GetFamily(f, family_lvl_storage)-1]))
                            return SendClientMessage(playerid, -1, ""c_f_r"Количество будет превышать максимальное доступное кол-во предмета.");

                        if(money <= GetPlayerMoneyEx(playerid))
                        {
                            AddFamily(f, family_money, +, money);
                            GivePlayerMoneyEx(playerid, -money);
                            SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи деньги.");
                            format(f_string144, sizeof f_string144, "%s положил на склад %d рублей.", GetPlayerNameEx(playerid), money);
                            SendFamilyMessage(f, f_string144);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));
                            SendFamilyLog(type_log_money, playerid, -1, f_string144);
                        }
                        else SendClientMessage(playerid, -1, ""c_f_r"У вас нет предмета.");
                    }
                }
                case 3:
                {
                    new material = strval(inputtext);

                    if(!material)
                        return SendClientMessage(playerid, -1, ""c_f_r"Число должно быть больше 0");

                    if(!take_or_put)
                    {
                        if(material <= GetFamily(f, family_material))
                        { 
                            if(!GetPlayerFamily(playerid, ACCESS_MATERIAL))
                                return SendClientMessage(playerid, -1, "У вас нет доступа.");

                            new material_access = GetPlayerFamily(playerid, ACCESS_MATERIAL)-material; 

                            if(material_access <= -1 && GetPlayerRangFamily(playerid) != 5) return FSendClientMessage(f_string144, playerid, -1, ""c_f_r"У вас не хватает доступа. Доступно:%d шт.", GetPlayerFamily(playerid, ACCESS_MATERIAL));

                            AddPlayerFamily(playerid, ACCESS_MATERIAL, -, 1);

                            AddFamily(f, family_material, -, material);
                            AddPlayerData(playerid, P_METALL, +, material);

                            SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склада семьи материалы.");
                            format(f_string144, sizeof f_string144, "%s взял из склада %d шт. материалов.", GetPlayerNameEx(playerid), material);
                            SendFamilyMessage(f, f_string144);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "material", GetFamily(f, family_material));
                            SendFamilyLog(type_log_material, playerid, -1, f_string144);
                        }
                        else SendClientMessage(playerid, -1, ""c_f_r"У семьи нет предмета.");
                    }
                    else
                    {
                        if(!(GetFamily(f, family_material)+material <= count_material_level[GetFamily(f, family_lvl_storage)-1]))
                            return SendClientMessage(playerid, -1, ""c_f_r"Количество будет превышать максимальное доступное кол-во предмета.");
                            
                        if(material <= GetPlayerData(playerid, P_METALL))
                        {
                            AddFamily(f, family_material, +, material);
                            AddPlayerData(playerid, P_METALL, -, material);

                            SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи материалы.");
                            format(f_string144, sizeof f_string144, "%s положил на склад %d шт. материалов.", GetPlayerNameEx(playerid), material);
                            SendFamilyMessage(f, f_string144);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "material", GetFamily(f, family_material));
                            SendFamilyLog(type_log_material, playerid, -1, f_string144);
                        }
                        else SendClientMessage(playerid, -1, ""c_f_r"У вас нет предмета.");
                    }
                }
                case 4:
                {
                    if(!take_or_put)
                    {
                        if(GetFamily(f, family_material))
                        {
                            if(!GetPlayerFamily(playerid, ACCESS_MASK) && GetPlayerRangFamily(playerid) != 5)
                                return SendClientMessage(playerid, -1, "У вас нет доступа.");
                            AddPlayerFamily(playerid, ACCESS_MASK, -, 1);

                            AddFamily(f, family_material, -, 1);
                            AddPlayerData(playerid, P_MASK, +, 1);

                            SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склада семьи маску.");
                            format(f_string144, sizeof f_string144, "%s взял из склада маску.", GetPlayerNameEx(playerid));
                            SendFamilyMessage(f, f_string144);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "mask", GetFamily(f, family_mask));
                            SendFamilyLog(type_log_mask, playerid, -1, f_string144);
                        }
                        else SendClientMessage(playerid, -1, ""c_f_r"У семьи нет предмета.");
                    }
                    else
                    {
                        if(!(GetFamily(f, family_mask)+1 <= count_material_level[GetFamily(f, family_lvl_storage)-1]))
                            return SendClientMessage(playerid, -1, ""c_f_r"Количество будет превышать максимальное доступное кол-во предмета.");

                        if(GetPlayerData(playerid, P_MASK))
                        {
                            AddFamily(f, family_mask, +, 1);
                            AddPlayerData(playerid, P_MASK, -, 1);

                            SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи маску.");
                            format(f_string144, sizeof f_string144, "%s положил на склад маску.", GetPlayerNameEx(playerid));
                            SendFamilyMessage(f, f_string144);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "mask", GetFamily(f, family_mask));
                            SendFamilyLog(type_log_mask, playerid, -1, f_string144);
                        }
                        else SendClientMessage(playerid, -1, ""c_f_r"У вас нет предмета.");
                    }
                }
                case 5:
                {
                    if(!take_or_put)
                    {
                        switch(listitem)
                        {
                            case 0:
                            {
                                Dialog
                                (
                                    playerid, -1, DIALOG_STYLE_MSGBOX, 
                                    "{FF0000}Информация",
                                    "На первом уровне улучшения оружия на складе доступен {FFFF00}Desert Eagle\n"\
                                    "{FFFFFF}На втором уровне {FFFF00}AK-47\n"\
                                    "{FFFFFF}На третьем уровне {FFFF00}MP5\n"\
                                    "{FFFFFF}На четветром уровне {FFFF00}Shotgun\n"\
                                    "{FFFFFF}На пятом уровне {FFFF00}Country Rifle\n"\
                                    "{FFFFFF}На шестом уровне {FFFF00}Sniper Rifle\n"\
                                    "{FFFFFF}На седьмом уровне {FFFF00}M4",
                                    "Выйти", ""
                                );
                            }
                            case 1:
                            {
                                if(!GetPlayerFamily(playerid, ACCESS_PATRON) && GetPlayerRangFamily(playerid) < 5)
                                    return SendClientMessage(playerid, -1, "У вас нет доступа.");

                                new dialog[234], weapon[26];

                                for(new i; i < GetFamily(f, family_lvl_weapon); i++)
                                {
                                    format(weapon, sizeof weapon, "%d. %s\n", i+1, name_weapon_family[i]);
                                    strcat(dialog, weapon);
                                }

                                Dialog(playerid, 2227, DIALOG_STYLE_LIST, "{FF0000}Выберите оружие", dialog, "Далее", "Выйти");

                                if(GetPVarInt(playerid, "select_weapon")) DeletePVar(playerid, "select_weapon");
                                if(GetPVarInt(playerid, "select_weapon_count")) DeletePVar(playerid, "select_weapon_count");
                                SetPVarInt(playerid, "select_weapon", 1);
                            }
                        }
                    }
                    else
                    {
                        switch(listitem)
                        {
                            case 0:
                            {
                                Dialog
                                (
                                    playerid, -1, DIALOG_STYLE_MSGBOX, 
                                    "{FF0000}Информация",
                                    "На первом уровне улучшения оружия на складе доступен {FFFF00}Desert Eagle\n"\
                                    "{FFFFFF}На втором уровне {FFFF00}AK-47\n"\
                                    "{FFFFFF}На третьем уровне {FFFF00}MP5\n"\
                                    "{FFFFFF}На четветром уровне {FFFF00}Shotgun\n"\
                                    "{FFFFFF}На пятом уровне {FFFF00}Country Rifle\n"\
                                    "{FFFFFF}На шестом уровне {FFFF00}Sniper Rifle\n"\
                                    "{FFFFFF}На седьмом уровне {FFFF00}M4",
                                    "Выйти", ""
                                );
                            }
                            case 1:
                            {

                                Dialog
                                (
                                    playerid, 2227, DIALOG_STYLE_INPUT, 
                                    "{FF0000}Введите количество",
                                    "Введите кол-во патронов которые хотите положить на склад",
                                    "Далее", "Назад"
                                );
                            }
                        }
                    }
                }
                case 6:
                {
                    if(!take_or_put)
                    {
                        if(GetFamily(f, family_armour))
                        {
                            if(!GetPlayerFamily(playerid, ACCESS_ARMOUR) && GetPlayerRangFamily(playerid) != 5)
                                return SendClientMessage(playerid, -1, "У вас нет доступа.");
                            AddPlayerFamily(playerid, ACCESS_ARMOUR, -, 1);

                            AddFamily(f, family_armour, -, 1);
                            SetPlayerArmour(playerid, 100.0);

                            SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склада семьи бронежилет.");
                            format(f_string144, sizeof f_string144, "%s взял из склада бронежилет.", GetPlayerNameEx(playerid));
                            SendFamilyMessage(f, f_string144);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "armour", GetFamily(f, family_armour));
                            SendFamilyLog(type_log_armour, playerid, -1, f_string144);
                        }
                        else SendClientMessage(playerid, -1, ""c_f_r"У семьи нет предмета.");
                    }
                    else
                    {
                        if(!(GetFamily(f, family_armour)+1 <= count_armour_level[GetFamily(f, family_lvl_storage)-1]))
                            return SendClientMessage(playerid, -1, ""c_f_r"Количество будет превышать максимальное доступное кол-во предмета.");

                        AddFamily(f, family_armour, +, 1);
                        SetPlayerArmour(playerid, 0.0);

                        SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи бронежилет.");
                        format(f_string144, sizeof f_string144, "%s положил на склад бронежилет.", GetPlayerNameEx(playerid));
                        SendFamilyMessage(f, f_string144);
                        UpdateColumnFamilyInt(GetFamily(f, family_database), "armour", GetFamily(f, family_armour));
                        SendFamilyLog(type_log_armour, playerid, -1, f_string144);
                    }
                    
                }
                case 7:
                {

                    if(!take_or_put)
                    {
                        if(GetFamily(f, family_heath_kit))
                        {
                            if(!GetPlayerFamily(playerid, ACCESS_HEATH_KIT) && GetPlayerRangFamily(playerid) != 5)
                                return SendClientMessage(playerid, -1, "У вас нет доступа.");
                            AddPlayerFamily(playerid, ACCESS_HEATH_KIT, -, 1);

                            AddFamily(f, family_heath_kit, -, 1);
                            AddPlayerData(playerid, P_MED_CHEST, +, 1);

                            SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склада семьи аптечку.");
                            format(f_string144, sizeof f_string144, "%s взял из склада аптечку.", GetPlayerNameEx(playerid));
                            SendFamilyMessage(f, f_string144);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "heath_kit", GetFamily(f, family_heath_kit));
                            SendFamilyLog(type_log_heath_kit, playerid, -1, f_string144);
                        }
                        else SendClientMessage(playerid, -1, ""c_f_r"У семьи нет предмета.");
                    }
                    else
                    {
                        if(!(GetFamily(f, family_heath_kit)+1 <= count_heath_kit_level[GetFamily(f, family_lvl_storage)-1]))
                            return SendClientMessage(playerid, -1, ""c_f_r"Количество будет превышать максимальное доступное кол-во предмета.");

                        if(GetPlayerData(playerid, P_MED_CHEST))
                        {
                            AddFamily(f, family_heath_kit, +, 1);
                            AddPlayerData(playerid, P_MED_CHEST, -, 1);

                            SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи аптечку.");
                            format(f_string144, sizeof f_string144, "%s положил на склад аптечку.", GetPlayerNameEx(playerid));
                            SendFamilyMessage(f, f_string144);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "heath_kit", GetFamily(f, family_heath_kit));
                            SendFamilyLog(type_log_heath_kit, playerid, -1, f_string144);
                        }
                        else SendClientMessage(playerid, -1, ""c_f_r"У вас нет предмета.");
                    }
                }
            }
        }
    }
    if(dialogid == 2227)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "select_weapon"))
            {
                if(!GetPVarInt(playerid, "select_weapon_count"))
                {
                    SetPVarInt(playerid, "weapon_select_id", listitem);

                    format(f_string144, sizeof f_string144, "Введите нужное кол-во патронов, доступно %d", GetFamily(f, family_patron));

                    Dialog
                    (
                        playerid, 2227, DIALOG_STYLE_INPUT, 
                        "{FF0000}Введите количество",
                        f_string144,
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "select_weapon_count", 1);
                    return 1;
                }

                new id = GetPVarInt(playerid, "weapon_select_id");

                new patron = strval(inputtext);

                if(!patron)
                    return SendClientMessage(playerid, -1, ""c_f_r"Число должно быть больше 0");

                if(patron > 1000)
                    return SendClientMessage(playerid, -1, ""c_f_r"Число должно быть меньше 1000");

                if(GetFamily(f, family_patron) >= patron)
                {
                    new patron_access = GetPlayerFamily(playerid, ACCESS_PATRON) - patron;

                    if(patron_access <= -1 && GetPlayerRangFamily(playerid) != 5) return FSendClientMessage(f_string144, playerid, -1, ""c_f_r"У вас не хватает доступа. Доступно:%d шт.", GetPlayerFamily(playerid, ACCESS_PATRON));
                    
                    AddPlayerFamily(playerid, ACCESS_PATRON, -, patron);

                    AddFamily(f, family_patron, -, patron);
                    //SetPlayerAmmo(playerid, count_weapon_level[listitem], patron);
                    GivePlayerWeapon(playerid, count_weapon_level[listitem], patron);

                    SendClientMessage(playerid, -1, ""c_f_g"Вы взяли из склад семьи оружие и патроны.");
                    format(f_string144, sizeof f_string144, "%s взял из склада %s и %d патрон.", GetPlayerNameEx(playerid), name_weapon_family[id], patron);
                    SendFamilyMessage(f, f_string144);
                    SendFamilyLog(type_log_patron, playerid, -1, f_string144);
                    UpdateColumnFamilyInt(GetFamily(f, family_database), "patron", GetFamily(f, family_patron));
                }

                return 1;
            }

            new patron = strval(inputtext);

            if(!patron)
                return SendClientMessage(playerid, -1, ""c_f_r"Число должно быть больше 0");

            new weapon = GetPlayerWeapon(playerid);
            
            switch(weapon)
            {
                case 0:return SendClientMessage(playerid, -1, ""c_f_r"Возьмите оружие в руки.");
                case 24, 30, 29, 25, 33, 34, 31:
                {
                    if((GetFamily(f, family_patron) + patron) > count_patron_level[FamilyStorageClampLevel(GetFamily(f, family_lvl_weapon)) - 1])
                        return SendClientMessage(playerid, -1, ""c_f_r"Количество будет превышать максимальное доступное кол-во предмета.");

                    new weapon_id = -1, ammo;

                    for(new i; i < 12;i++)
                    {
                        GetPlayerWeaponData(playerid, i, weapon_id, ammo);

                        if(weapon_id == weapon) break;
                    }    

                    if(weapon_id == -1) return 1;

                    if(ammo >= patron)
                    {
                        new ammo_new = ammo - patron;

                        AddFamily(f, family_patron, +, patron);
                        SetPlayerAmmo(playerid, weapon_id, ammo_new);

                        SendClientMessage(playerid, -1, ""c_f_g"Вы положили на склад семьи патроны.");
                        format(f_string144, sizeof f_string144, "%s положил на склад %d патрон.", GetPlayerNameEx(playerid), patron);
                        SendFamilyMessage(f, f_string144);
                        UpdateColumnFamilyInt(GetFamily(f, family_database), "patron", GetFamily(f, family_patron));
                    }
                    else SendClientMessage(playerid, -1, ""c_f_g"У вас нету такого кол-во патрон.");
                }
                default:return SendClientMessage(playerid, -1, ""c_f_r"Ваше оружие не подходит чтобы положить патроны на склад");
            }
        }
    }
    if(dialogid == 2228)
    {
        new Cache:cache;

        if(response)
        {
            if(GetPlayerFamily(playerid, RANG_FAMILY) != 5)
                return SendClientMessage(playerid, -1, ""c_f_r"Создавать объявления можно только лидеру.");
            
            if(GetPVarInt(playerid, "input_ad_family"))
            {
                if(strval(inputtext) > 62)  SendClientMessage(playerid, -1, ""c_f_r"Количество симолов не должно быть больше 62");
                else
                {
                    mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family_ad WHERE family = %d", GetPlayerFamily(playerid, ID_SQL_FAMILY));
                    cache = mysql_query(mysql, f_string64);

                    if(mysql_errno())
                        return SendClientMessage(playerid,-1,""c_f_r" Ошибка в SQL-запросе / Code: Dialog 2228 - Select AD FAMILY");

                    if(cache_num_rows() > 10) SendClientMessage(playerid, -1, ""c_f_r"У вас максимальное кол-во объявлений (Чтобы удалить нажмите на объявление).");
                    else
                    {
                        utf8_to_cp1251(inputtext);
                        mysql_format(mysql, f_string184, sizeof f_string184, "INSERT INTO family_ad (family, ad_text, create_id, create_name, time) VALUES ('%d', '%s', '%d', '%s', '%d')", GetPlayerFamily(playerid, ID_SQL_FAMILY),\
                        inputtext, GetPlayerAccountID(playerid), GetPlayerNameEx(playerid), gettime()+10800);
                        mysql_query(mysql, f_string184, false);

                       if(!mysql_errno()) FSendClientMessage(f_string144, playerid, -1, ""c_f_g"Вы успешно создали объявление: {FFFF00}%s", inputtext);
                    }
                    cache_delete(cache);
                }

                DeletePVar(playerid, "input_ad_family");
                return 1;
            }

            Dialog
            (
                playerid, 2228, DIALOG_STYLE_INPUT,
                "{FF0000}Создание объявления",
                "Напишите содержание вашего объявления.",
                "Создать", "Выйти"
            );

            SetPVarInt(playerid, "input_ad_family", 1);
        }
        else
        {
            if(GetPVarInt(playerid, "input_ad_family")) return 1;
            mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family_ad WHERE family = %d", GetPlayerFamily(playerid, ID_SQL_FAMILY));
            cache = mysql_query(mysql, f_string64);

            if(mysql_errno())
                return SendClientMessage(playerid,-1,""c_f_r" Ошибка в SQL-запросе / Code: Dialog 2228 (!response) - Select AD FAMILY");

            new rows = cache_num_rows();

            if(rows)
            {
                new dialog[140 * 10 + 42] = "{FFFFFF}Текст\t{FFFFFF}Дата\t{FFFFFF}Создатель\n", list[110], id, ad_text[62], time_data[24], time, create_name[24];

                for(new i; i < rows; i++)
                {
                    cache_get_field_content(i, "ad_text", ad_text, mysql, 62);
                    cache_get_field_content(i, "create_name", create_name, mysql, 24);
                    time = cache_get_field_content_int(i, "time");
                    id = cache_get_field_content_int(i, "id");

                    format(time_data, sizeof time_data, "%02d/%02d/%d [%02d:%02d:%02d]", 
                    ConvertUnixTime(time, CONVERT_TIME_TO_DAYS), ConvertUnixTime(time, CONVERT_TIME_TO_MONTHS), ConvertUnixTime(time, CONVERT_TIME_TO_YEARS),
                    ConvertUnixTime(time, CONVERT_TIME_TO_HOURS), ConvertUnixTime(time, CONVERT_TIME_TO_MINUTES), ConvertUnixTime(time, CONVERT_TIME_TO_SECONDS));


                    format(list, sizeof list, "{FFFFFF}%s\t{FFFFFF}%s\t{FFFFFF}%s\n", ad_text, time_data, create_name);
                    strcat(dialog, list);
                    SetPlayerListitemValue(playerid, i, id);
                }

                DialogFamily(playerid, 2229, DIALOG_STYLE_TABLIST_HEADERS, "{FF0000}Список объявлений", dialog, "Далее", "Выйти");

                if(GetPVarInt(playerid, "select_id_ad")) DeletePVar(playerid, "select_id_ad");
                cache_delete(cache);
            }
            else SendClientMessage(playerid, -1, ""c_f"Объявления не найдены.");
        }
    }
    if(dialogid == 2229)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "select_id_ad"))
            {
                if(GetPlayerFamily(playerid, RANG_FAMILY) == 5)
                {
                    new id = GetPVarInt(playerid, "select_id_ad")-1;

                    mysql_format(mysql, f_string64, sizeof f_string64, "DELETE FROM family_ad WHERE id = %d", id);
                    new Cache:cache = mysql_query(mysql, f_string64);

                    if(mysql_errno())
                        return SendClientMessage(playerid,-1,""c_f_r" Ошибка в SQL-запросе / Code: Dialog 2229 - Delete AD FAMILY");

                    FSendClientMessage(f_string64, playerid, -1, ""c_f_g"Вы успешно удалили объявление №%d", id);
                    return 1;
                }
            }

            new id = GetPlayerListitemValue(playerid, listitem);

            mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family_ad WHERE id = %d", id);
            new Cache:cache = mysql_query(mysql, f_string64);

            if(mysql_errno())
                return SendClientMessage(playerid,-1,""c_f_r" Ошибка в SQL-запросе / Code: Dialog 2229 - Select AD FAMILY");

            if(cache_num_rows())
            {
                new ad_text[62], time_data[24], dialog[356], time, create_name[24], text[24];

                cache_get_field_content(0, "ad_text", ad_text, mysql, 62);
                cache_get_field_content(0, "create_name", create_name, mysql, 24);
                time = cache_get_field_content_int(0, "time");


                format(time_data, sizeof time_data, "%02d/%02d/%d [%02d:%02d:%02d]", 
                ConvertUnixTime(time, CONVERT_TIME_TO_DAYS), ConvertUnixTime(time, CONVERT_TIME_TO_MONTHS), ConvertUnixTime(time, CONVERT_TIME_TO_YEARS),
                ConvertUnixTime(time, CONVERT_TIME_TO_HOURS), ConvertUnixTime(time, CONVERT_TIME_TO_MINUTES), ConvertUnixTime(time, CONVERT_TIME_TO_SECONDS));

                format(text, sizeof text, "{FF0000}Объявление №%d", id);
                
                format(dialog, sizeof dialog,
                "Содержание объявления:\n{FFFF00}%s{FFFFFF}\n\n"\
                "Создатель объявления: {FFFF00}%s{FFFFFF}\n\n"\
                "Время: {FFFF00}%s{FFFFFF}", ad_text, create_name, time_data
                );

                Dialog(playerid, 2229, DIALOG_STYLE_MSGBOX, text, dialog, "Удалить", "Выйти");
                SetPVarInt(playerid, "select_id_ad", id + 1);
            }
        }
        else callcmd::familymenuinternal(playerid);
    }

    if(dialogid == 2230)
    {
        if(GetPVarInt(playerid, "select_get_dostup"))
        {
            new Name[24], e, to_player = -1, string[234];

            if(sscanf(inputtext, "s[24]", Name))e++ ;
            else if(sscanf(inputtext, "d", to_player))e++;

            if(e == 2) return SendClientMessage(playerid, -1, ""c_f_r" Вы ввели не правильные данные.");

            if(to_player == -1)
            {
                if(!strcmp(Name, GetPlayerNameEx(playerid), true))
                    return 1;

                foreach(new i : Player)
                {
                    if(!strcmp(Name, GetPlayerNameEx(i), true))
                    {
                        if(GetFamily(GetPlayerIdFamily(playerid), family_owner) == GetPlayerAccountID(i)) continue;
                        to_player = i;
                        break;
                    }
                }
            }

            if(!IsPlayerConnected(to_player))
                return SendClientMessage(playerid, -1, ""c_f_r"Данный игрок не в сети.");

            format(string, sizeof string,
            "Никнейм:%s\n"\
            "Доступ на изменение доступов: %s\n"\
            "Доступ к деньгам: %d\n"\
            "Доступ к материалам: %d\n"\
            "Доступ к маскам: %d\n"\
            "Доступ к аптечкам: %d\n"\
            "Доступ к оружию: %d\n"\
            "Доступ к бронежилетам: %d",
            GetPlayerNameEx(to_player), GetPlayerFamily(to_player, ACCESS_GIVE) ? "Есть" : "Нет",
            GetPlayerFamily(to_player, ACCESS_MONEY),
            GetPlayerFamily(to_player, ACCESS_MATERIAL),
            GetPlayerFamily(to_player, ACCESS_MASK),
            GetPlayerFamily(to_player, ACCESS_HEATH_KIT),
            GetPlayerFamily(to_player, ACCESS_PATRON),
            GetPlayerFamily(to_player, ACCESS_ARMOUR));

            Dialog(playerid, -1, DIALOG_STYLE_LIST, "{FF0000}Информация доступов", string, "Выйти","");
            return 1;
        }

        DeletePVar(playerid, "status_dialog_access");
        DeletePVar(playerid, "type_dialog_access");
        if(response)
        {
            switch(listitem)
            {
                case 0:ShowDialogAccess(playerid, 1, true);
                case 1:ShowDialogAccess(playerid, 1, false);
                case 2:
                {
                    Dialog
                    (
                        playerid, 2230, DIALOG_STYLE_INPUT,
                        "Просмотр доступов",
                        "Введите имя или ID игрока для просмотра доступа",
                        "Далее",
                        "Назад"
                    );
                    
                    SetPVarInt(playerid, "select_get_dostup", 1);
                }
            }
        }
    }
    if(dialogid == 2231)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "status_dialog_access"))
            {
                new give = GetPVarInt(playerid, "status_dialog_access")-1;

                if(GetPVarInt(playerid, "type_dialog_access"))
                {
                    new Name[24], e, to_player = -1, count, give_text[10];

                    if(give) 
                    {
                        format(give_text, sizeof give_text, "выдал");
                        if(sscanf(inputtext, "P<,>s[24]d", Name, count)) e++;
                        else if(sscanf(inputtext, "P<,>dd", to_player, count))e++;
                    } 
                    else {
                        format(give_text, sizeof give_text, "забрал");
                        if(sscanf(inputtext, "s[24]", Name))e++ ;
                        else if(sscanf(inputtext, "d", to_player))e++;
                    } 

                    if(e == 2) return SendClientMessage(playerid, -1, ""c_f_r" Вы ввели не правильные данные.");

                    if(count > 200_000_000) return SendClientMessage(playerid, -1, ""c_f_r"Количество должно быть больше 200.000.000");

                    if(to_player == -1)
                    {
                        if(!strcmp(Name, GetPlayerNameEx(playerid), true)) return 1;

                        foreach(new i : Player)
                        {
                            if(!strcmp(Name, GetPlayerNameEx(i), true))
                            {
                                if(GetFamily(GetPlayerIdFamily(playerid), family_owner) == GetPlayerAccountID(i)) continue;

                                to_player = i;
                                break;
                            }
                        }
                    }

                    if(!IsPlayerConnected(to_player))
                        return SendClientMessage(playerid, -1, ""c_f_r"Данный игрок не в сети.");

                    new type = GetPVarInt(playerid, "type_dialog_access")-2;

                    switch(type)
                    {
                        case 0:
                        {
                            SetPlayerFamily(to_player, ACCESS_ARMOUR, count);
                            SetPlayerFamily(to_player, ACCESS_MONEY, count);
                            SetPlayerFamily(to_player, ACCESS_HEATH_KIT, count);
                            SetPlayerFamily(to_player, ACCESS_PATRON, count);
                            SetPlayerFamily(to_player, ACCESS_MASK, count);
                            SetPlayerFamily(to_player, ACCESS_MATERIAL, count);
                            SetPlayerFamily(to_player, ACCESS_GIVE, give);
                            format(f_string144, sizeof f_string144, "%s %s %s все доступа", GetPlayerNameEx(playerid), give_text,GetPlayerNameEx(to_player));
                        }
                        case 1:
                        {
                            SetPlayerFamily(to_player, ACCESS_GIVE, give);
                            format(f_string144, sizeof f_string144, "%s %s %s доступ на выдачу доступа", GetPlayerNameEx(playerid), give_text, GetPlayerNameEx(to_player));
                        }
                        case 2:SetPlayerFamily(to_player, ACCESS_MONEY, count);
                        case 3:SetPlayerFamily(to_player, ACCESS_MATERIAL, count);
                        case 4:SetPlayerFamily(to_player, ACCESS_MASK, count);
                        case 5:SetPlayerFamily(to_player, ACCESS_HEATH_KIT, count);
                        case 6:SetPlayerFamily(to_player, ACCESS_PATRON, count);
                        case 7:SetPlayerFamily(to_player, ACCESS_ARMOUR, count);
                    }

                    new dostup[8][24] = {"", "", "деньги", "материалы", "маски", "аптечки", "оружие", "бронижелет"};

                    if(2 <= type <= 7) format(f_string144, sizeof f_string144, "%s %s %s доступ на %s в кол-во %d", GetPlayerNameEx(playerid), give_text, GetPlayerNameEx(to_player), dostup[type], count);
                    SendFamilyLog(type_log_dostup, playerid, to_player, f_string144);

                    format(f_string144, sizeof f_string144, "%s[%d] изменил настройки доступа %s[%d]", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(to_player), to_player);
                    SendFamilyMessage(f, f_string144);

                    UpdateAccessPlayerFamily(to_player);
                }   
                else ShowDialogAccess(playerid, listitem+2, give);
            }
        }
    }
    if(dialogid == 2232)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "select_color_chat"))
            {
                SetFamily(f, family_color, listitem);
                UpdateColumnFamilyInt(GetFamily(f, family_database), "chatcolor", GetFamily(f, family_color));

                SendClientMessage(playerid, -1, ""c_f_g"Вы изменили цвет чата семьи.");

                format(f_string144, sizeof f_string144, "%s изменил цвет чата семьи.", GetPlayerNameEx(playerid));
                SendFamilyMessage(f, f_string144);
                return 1;
            }
            else if(GetPVarInt(playerid, "select_setting_rang"))
            {
                SetPVarInt(playerid, "select_rang", listitem+1);
                Dialog(playerid, 2233, DIALOG_STYLE_LIST, family_rang_name[f][listitem], "1. Название ранга\n2. Возможности ранга", "Далее", "Назад");
                return 1;
            }

            switch(listitem)
            {
                case 0:
                {
                    format(f_string184, sizeof f_string184, "");
                    for(new i;i < 5;i ++)
                    {
                        format(f_string32, sizeof f_string32, "{FFFFFF}%d. %s\n", i+1, family_rang_name[f][i]);
                        strcat(f_string184, f_string32);
                    }
                    
                    Dialog(playerid, 2232, DIALOG_STYLE_LIST, "{FF0000}Список рангов", f_string184, "Далее", "Назад");
                    SetPVarInt(playerid, "select_setting_rang", 1);
                }
                case 1:
                {
                    Dialog
                    (
                        playerid, 2232, DIALOG_STYLE_LIST,
                        "{FF0000}Выберите цвет",
                        "{FFFFFF} Белый\n"\
                        "{C3C3C3} Серый\n"\
                        "{F3FF02} Желтый\n"\
                        "{F81414} Красный\n"\
                        "{00FFEE} Голубой\n"\
                        "{FF00EA} Розовый\n"\
                        "{FFFFFF} Черный\n"\
                        "{C9FFAB} Салатовый\n"\
                        "{FFF1AF} Лимонный\n"\
                        "{FFAF00} Оранжевый\n"\
                        "{0049FF} Синий\n"\
                        "{AFE7FF} Светло-голубой",
                        "Выбрать", "Назад"
                    );

                    SetPVarInt(playerid, "select_color_chat", 1);
                }
            }
        }
    }
    if(dialogid == 2233)
    {
        if(response)
        {
            new f_sql = GetPlayerFamily(playerid, ID_SQL_FAMILY), rang = GetPVarInt(playerid, "select_rang")-1;

            if(GetPVarInt(playerid, "setting_select"))
            {
                new setting = family_rang_dostup[f][rang][listitem];

                family_rang_dostup[f][rang][listitem] = setting^1;
                UpdateDostupFamily(f, rang);

                SendClientMessage(playerid, -1, ""c_f_g"Вы изменили доступ.");
                format(f_string144, sizeof f_string144, "%s изменил доступ %s (%d ранг).", GetPlayerNameEx(playerid), family_rang_name[f][rang], rang+1);
                SendFamilyMessage(f, f_string144);
                return 1;
            }
            else if(GetPVarInt(playerid, "name_select"))
            {
                new familyName[64];
                format(familyName, sizeof familyName, "%s", GetFamily(GetPlayerIdFamily(playerid), family_name));
                utf8_to_cp1251(familyName); // преобразуем название семьи в cp1251

                utf8_to_cp1251(inputtext); // преобразуем ввод названия ранга в cp1251

                new count_symbol = 12;

                for(new i; i < strlen(inputtext); i++) 
                    if(inputtext[i] == '-' && inputtext[i+7] == '}')
                {
                    count_symbol += 8;
                    inputtext[i] = '{';
                }

                if(strfind(inputtext, ",") != -1)
                    return SendClientMessage(playerid, -1, ""c_f_r"В названии ранга не должна быть запятая.");

                if(!(3 <= strlen(inputtext) <= count_symbol))
                    return SendClientMessage(playerid,-1, ""c_f_r"Символов должно быть от 3 до 12");

                format(family_rang_name[f][rang], 24, inputtext);
                UpdateDostupFamily(f, rang);

                SendClientMessage(playerid, -1, ""c_f_g"Вы изменили название.");
                format(f_string144, sizeof f_string144, "%s изменил название %d ранга на %s", GetPlayerNameEx(playerid), rang+1, family_rang_name[f][rang]);
                SendFamilyMessage(f, f_string144);
                return 1;
            }


            switch(listitem)
            {
                case 0:
                {
                    Dialog
                    (
                        playerid, 2233, DIALOG_STYLE_INPUT,
                        "{ff0000}Смена названия ранга",
                        "Введите в строчку ниже будущее название ранга:",
                        "Далее",
                        "Назад"
                    );
                    SetPVarInt(playerid, "name_select", 1);
                }
                case 1:
                {
                    if(GetPVarInt(playerid, "select_rang") == 5)
                        return SendClientMessage(playerid, -1, "Изменять возможности лидера нельзя.");

                    format(f_string32, sizeof f_string32, "Настройка %s", family_rang_name[f][rang]);

                    new setting[254];
                    format(setting, sizeof setting,
                    "1. Возможность принимать игроков %s\n"\
                    "2. Возможность выгнать игрока %s\n"\
                    "3. Возможность изменить ранг игроку %s\n"\
                    "4. Возможность выдавать муты %s\n"\
                    "5. Возможность участвовать в войне семей %s", family_rang_dostup[f][rang][0] ? "{FF0000}[Нет]" : "{00FF00}[Да]",
                    family_rang_dostup[f][rang][1] ? "{FF0000}[Нет]" : "{00FF00}[Да]",
                    family_rang_dostup[f][rang][2] ? "{FF0000}[Нет]" : "{00FF00}[Да]",
                    family_rang_dostup[f][rang][3] ? "{FF0000}[Нет]" : "{00FF00}[Да]",
                    family_rang_dostup[f][rang][4] ? "{FF0000}[Нет]" : "{00FF00}[Да]");

                    
                    Dialog
                    (
                        playerid, 2233, DIALOG_STYLE_LIST,
                        f_string32,
                        setting,
                        "Далее",
                        "Выйти"
                    );

                    SetPVarInt(playerid, "setting_select", 1);
                }
            }
        }
    }
    if(dialogid == 2234)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "type_up_family"))
            {
                switch(GetPVarInt(playerid, "type_up_family"))
                {
                    case 1:
                    {
                        if(GetFamily(f, family_money) >= price_up_sklad[GetFamily(f, family_lvl_storage)])
                        {
                            AddFamily(f, family_money, -, price_up_sklad[GetFamily(f, family_lvl_storage)]);
                            SetFamily(f, family_lvl_storage, GetFamily(f, family_lvl_storage)+1);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_storage", GetFamily(f, family_lvl_storage));
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));

                            format(f_string144, sizeof f_string144, "%s улучшил склад до %d уровня.", GetPlayerNameEx(playerid), GetFamily(f, family_lvl_storage));
                            SendFamilyMessage(f, f_string144);
                        }
                        else FSendClientMessage(f_string144, playerid, -1, ""c_f_r"На складе не хватает %d.", price_up_sklad[GetFamily(f, family_lvl_storage)]-GetFamily(f, family_money));
                    }
                    case 2:
                    {
                        if(GetFamily(f, family_money) >= price_up_weapon[GetFamily(f, family_lvl_weapon)])
                        {
                            AddFamily(f, family_money, -, price_up_weapon[GetFamily(f, family_lvl_weapon)]);
                            SetFamily(f, family_lvl_weapon, GetFamily(f, family_lvl_weapon)+1);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_weapon", GetFamily(f, family_lvl_weapon));
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));

                            format(f_string144, sizeof f_string144, "%s улучшил оружие до %d уровня.", GetPlayerNameEx(playerid), GetFamily(f, family_lvl_weapon));
                            SendFamilyMessage(f, f_string144);
                        }
                        else FSendClientMessage(f_string144, playerid, -1, ""c_f_r"На складе не хватает %d.", price_up_weapon[GetFamily(f, family_lvl_weapon)]-GetFamily(f, family_money));
                    }
                    case 3:
                    {
                        if(GetFamily(f, family_money) >= price_up_compound[GetFamily(f, family_lvl_compound)])
                        {
                            AddFamily(f, family_money, -, price_up_compound[GetFamily(f, family_lvl_compound)]);
                            SetFamily(f, family_lvl_compound, GetFamily(f, family_lvl_compound)+1);
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "level_compound", GetFamily(f, family_lvl_compound));
                            UpdateColumnFamilyInt(GetFamily(f, family_database), "money", GetFamily(f, family_money));

                            format(f_string144, sizeof f_string144, "%s улучшил состав до %d уровня.", GetPlayerNameEx(playerid), GetFamily(f, family_lvl_compound));
                            SendFamilyMessage(f, f_string144);
                        }
                        else FSendClientMessage(f_string144, playerid, -1, ""c_f_r"На складе не хватает %d.", price_up_compound[GetFamily(f, family_lvl_compound)]-GetFamily(f, family_money));
                    }
                }
                
                return 1;
            }

            new level, level_up_text[525], name_level[7][12] = {"первом","втором", "третьим", "четвёртом", "пятом", "шестом", "седьмом"};

            switch(listitem)
            {
                case 0:
                {
                    if(GetFamily(f, family_lvl_storage) == 7)
                        return SendClientMessage(playerid, -1, ""c_f_r"Ваш склад на максимальном уровне.");

                    level = GetFamily(f, family_lvl_storage)-1;

                    format(level_up_text, sizeof level_up_text,
                    "На %s уровне склада:\n"\
                    "Максимально денег с %d до {FFFF00}%d{FFFFFF}\n"\
                    "Максимально материалов с %d до {FFFF00}%d{FFFFFF}\n"\
                    "Максимально аптечек с %d до {FFFF00}%d{FFFFFF}\n"\
                    "Максимально масок с %d до {FFFF00}%d{FFFFFF}\n"\
                    "Максимально бронежилетов с %d до {FFFF00}%d{FFFFFF}\n\n"\
                    "Вы уверены что хотите улучшить склад за %d рублей?\n"\
                    "Сумма должна лежать на складе семьи.",
                    name_level[level+1], count_money_level[level], count_money_level[level+1],
                    count_material_level[level], count_material_level[level+1],
                    count_heath_kit_level[level], count_heath_kit_level[level+1],
                    count_mask_level[level], count_mask_level[level+1],
                    count_armour_level[level], count_armour_level[level+1],
                    price_up_sklad[level+1]
                    );

                    Dialog
                    (
                        playerid, 2234, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Улучшение склада",
                        level_up_text,
                        "Далее", "Назад"
                    );

                    SetPVarInt(playerid, "type_up_family", 1);
                }
                case 1:
                {
                    if(GetFamily(f, family_lvl_weapon) == 7)
                        return SendClientMessage(playerid, -1, ""c_f_r"Ваше оружие на максимальном уровне.");

                    level = GetFamily(f, family_lvl_weapon)-1;

                    format(level_up_text, sizeof level_up_text,
                    "На %s уровне оружия:\n"\
                    "Максимально патронов с %d до {FFFF00}%d{FFFFFF}\n"\
                    "Новое оружие {FFFF00}%s{FFFFFF}\n\n"\
                    "Вы уверены что хотите улучшить склад за %d рублей?\n"\
                    "Сумма должна лежать на складе семьи.",
                    name_level[level+1], count_patron_level[level], count_patron_level[level+1],
                    name_weapon_family[level+1],
                    price_up_weapon[level+1]
                    );

                    Dialog
                    (
                        playerid, 2234, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Улучшение оружия",
                        level_up_text,
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "type_up_family", 2);
                }
                case 2:
                {
                    if(GetFamily(f, family_lvl_compound) == 7)
                        return SendClientMessage(playerid, -1, ""c_f_r"Ваш состав на максимальном уровне.");

                    level = GetFamily(f, family_lvl_compound)-1;

                    format(level_up_text, sizeof level_up_text,
                    "На %s уровне состава:\n"\
                    "Максимально человек с %d до {FFFF00}%d{FFFFFF}\n\n"\
                    "Вы уверены что хотите улучшить склад за %d рублей?\n"\
                    "Сумма должна лежать на складе семьи.",
                    name_level[level+1], count_compound_level[level], count_compound_level[level+1],
                    price_up_compound[level+1]
                    );

                    Dialog
                    (
                        playerid, 2234, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Улучшение состава",
                        level_up_text,
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "type_up_family", 3);
                }
            }
        }
    }
    if(dialogid == 2235)
    {
        if(response)
        {
            new f_sql = GetPlayerFamily(playerid, ID_SQL_FAMILY);

            if(GetPlayerRangFamily(playerid) != 5)
            {
                format(f_string144, sizeof f_string144, "Игрок %s покинул семью. Причина: С/Ж", GetPlayerNameEx(playerid));
                SendFamilyMessage(f, f_string144);
                ExitFromFamily(playerid);
            } 
            else
            {
                format(f_string144, sizeof f_string144, "Лидер %s[%d] ушел и семья закрыта. Причина: C/Ж", GetPlayerNameEx(playerid), playerid);
                SendFamilyMessage(f, f_string144);
                foreach(new i : Player)
                {
                    if(GetPlayerFamily(i, ID_SQL_FAMILY) == f_sql)
                    {
                        ExitFromFamily(i);
                        SendClientMessage(i, -1, "Лидер семьи вышел из семьи. Семья удалена.");
                    }                    
                }

                
                mysql_format(mysql, f_string144,sizeof f_string144, "DELETE FROM family_cars WHERE family_owner = %d", f_sql);
                mysql_query(mysql, f_string144);
                if(mysql_errno()) return printf("ERROR SQL (%s)", f_string144);

                mysql_format(mysql, f_string144,sizeof f_string144, "DELETE FROM family_log WHERE family = %d", f_sql);
                mysql_query(mysql, f_string144);
                if(mysql_errno()) return printf("ERROR SQL (%s)", f_string144);

                mysql_format(mysql, f_string144,sizeof f_string144, "DELETE FROM family_ad WHERE family = %d", f_sql);
                mysql_query(mysql, f_string144);
                if(mysql_errno()) return printf("ERROR SQL (%s)", f_string144);

                mysql_format(mysql, f_string144,sizeof f_string144, "DELETE FROM family_storage_items WHERE family_id = %d", f_sql);
                mysql_query(mysql, f_string144);
                if(mysql_errno()) return printf("ERROR SQL (%s)", f_string144);

                mysql_format(mysql, f_string144,sizeof f_string144, "DELETE FROM family_ammo_storage WHERE family_id = %d", f_sql);
                mysql_query(mysql, f_string144);
                if(mysql_errno()) return printf("ERROR SQL (%s)", f_string144);

                mysql_format(mysql, f_string144,sizeof f_string144, "DELETE FROM familyblack WHERE family_id = %d", f_sql);
                mysql_query(mysql, f_string144);
                if(mysql_errno()) return printf("ERROR SQL (%s)", f_string144);

                mysql_format(mysql, f_string64,sizeof f_string64, "DELETE FROM familynew WHERE id = %d", f_sql);
                mysql_query(mysql, f_string64);
                if(mysql_errno()) return printf("ERROR SQL (%s)", f_string64);

                mysql_format(mysql, f_string144,sizeof f_string144, "UPDATE accounts SET family_id = -1 WHERE family_id = %d", f_sql);
                mysql_query(mysql, f_string144);
                if(mysql_errno()) return printf("ERROR SQL (%s)", f_string144);

                for(new i; i < MAX_OWNABLE_CARS;i++)
                {
                    if(GetCarFamily(i, OW_F_database) != f_sql) continue;
                    UnLoadFamilyCar(GetCarFamily(i, CAR_F_database));
                }

                SetFamily(f, family_database,        -1);
                SetFamily(f, family_color, 0);
                SetFamily(f, family_reputation, 0);
                SetFamily(f, family_zaxvati, 0);
                SetFamily(f, family_moneti, 0);
                SetFamily(f, family_syndicate, 0);
                format(family[f][family_name], 32, "");
                SetFamily(f, family_owner, 0);
                SetFamily(f, family_slot_veh, 0);
                SetFamily(f, family_count_veh, 0);
                SetFamily(f, family_count_people, 0);
                SetFamily(f, family_status_storage, 0);
                SetFamily(f, family_money, 0);
                SetFamily(f, family_armour, 0);
                SetFamily(f, family_material, 0);
                SetFamily(f, family_heath_kit, 0);
                SetFamily(f, family_patron, 0);
                SetFamily(f, family_mask, 0);
                SetFamily(f, family_lvl_storage, 0);
                SetFamily(f, family_lvl_weapon, 0);
                SetFamily(f, family_lvl_compound, 0);
            }
        }
    }
    if(dialogid == 2236)
    {
        if(response)
        {
            if(GetPVarInt(playerid, "select_type_2236"))
            {
                new id_p, count, prichina[16];
                switch(GetPVarInt(playerid, "select_type_2236"))
                {
                    case 1:callcmd::faminvite(playerid, inputtext);
                    case 2:
                    {
                        if(0 <= listitem <= 1 && GetPVarInt(playerid, "prichina") == 0) return ShowMembersFamily(playerid, listitem);

                        new id = GetPlayerListitemValue(playerid, listitem), name[24];

                        format(f_string32, sizeof f_string32, "p_familyrang%d", listitem);
                    
                        if(GetPVarInt(playerid, f_string32) >= GetPlayerRangFamily(playerid))
                            return SendClientMessage(playerid, -1, ""c_f_r"Игрок выше вас рангом.");

                        //printf("rang = %d || rang = %d || id = %d ", GetPVarInt(playerid, f_string32), GetPlayerRangFamily(playerid))

                        format(f_string32, sizeof f_string32, "p_familyname%d", listitem);
                        GetPVarString(playerid, f_string32, name, 24);

                        if(!GetPVarInt(playerid, "prichina")) 
                        { 
                            Dialog(
                                playerid, 2236, DIALOG_STYLE_INPUT,
                                "{FF0000}Выгнать игрока",
                                "Напишите причину для того чтобы выгнать игрока",
                                "Далее","Назад"
                            );
                            SetPVarInt(playerid, "family_player_id", id);
                            SetPVarString(playerid, "family_playername", name);
                            SetPVarInt(playerid, "prichina", 1);
                            SetPVarInt(playerid, "select_type_2326", 2);  
                            return 1; 

                        }
                        else
                        {
                            if(sscanf(inputtext, "s[16]", prichina) || strlen(inputtext) < 5)
                            {
                                SendClientMessage(playerid, -1, ""c_f_r"Причина может быть от 5 до 16 символов");
                                return ShowMembersFamily(playerid, 1);
                            } 
                        }

                        new param[24];

                        id = GetPVarInt(playerid, "family_player_id");
                        GetPVarString(playerid, "family_playername", name, sizeof name);

                        foreach(new i : Player)
                        {
                            if(GetPlayerAccountID(i) != id) continue;
                            format(param, sizeof param, "%d %s", i, prichina);
                            callcmd::unfaminvite(playerid, param);
                            return 1;
                        }

                        mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE accounts SET family_id=-1 WHERE id = %d", id);
                        mysql_query(mysql, f_string144, false);

                        if(!mysql_errno())
                        {
                            format(f_string144, sizeof f_string144, "%s выгнал игрока %s. Причина: %s (оффлайн)", GetPlayerNameEx(playerid), name, prichina);
                            SendFamilyMessage(f, f_string144);
                            SendFamilyLog(type_log_kick, playerid, id, f_string144);
                        }
                    }
                    case 3:
                    {
                        if(sscanf(inputtext, "P<,>dds[12]", id_p, count, prichina))
                         return SendClientMessage(playerid, -1, ""c_f_g"Вы не правильно ввели параметры.");
                        
                        format(inputtext, 18, "%d %d %s", id_p, count, prichina);
                        callcmd::fammute(playerid, inputtext);
                    }
                    case 4:
                    {
                        if(sscanf(inputtext, "P<,>ds[12]", id_p, prichina))
                         return SendClientMessage(playerid, -1, ""c_f_g"Вы не правильно ввели параметры.");

                        format(inputtext, 16, "%d %s", id_p, prichina);
                        callcmd::unfammute(playerid, inputtext);
                    }
                    case 5:
                    {
                        new Name[24], e, to_player = -1, rang;

                        if(sscanf(inputtext, "P<,>s[24]d", Name, rang))e++ ;
                        else if(sscanf(inputtext, "P<,>dd", to_player, rang))e++;

                        if(e == 2) return SendClientMessage(playerid, -1, ""c_f_r" Вы ввели не правильные данные.");

                        if(to_player == -1)
                        {
                            if(!strcmp(Name, GetPlayerNameEx(playerid), true, sizeof Name)) return 1;

                            foreach(new i : Player)
                            {
                                if(!strcmp(Name, GetPlayerNameEx(i), true))
                                {
                                    if(GetFamily(GetPlayerIdFamily(playerid), family_owner) == GetPlayerAccountID(i)) continue;
                                    to_player = i;
                                    break;
                                }
                            }
                        }

                        if(!IsPlayerConnected(to_player) || to_player == playerid)
                            return SendClientMessage(playerid, -1, ""c_f_r"Данный игрок не в сети.");

                        if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][2])
                            return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу недоступно изменять ранги.");

                        if(rang >= GetPlayerRangFamily(playerid))
                            return SendClientMessage(playerid, -1, ""c_f_r"Невозможно выдать тот же ранг как у Вас или выше.");

                        if(GetPlayerIdFamily(to_player) != f)
                            return SendClientMessage(playerid, -1, ""c_f_r"Игрок не в вашей семье.");

                        SetPlayerFamily(to_player, RANG_FAMILY, rang);
                        UpdatePlayerDatabaseInt(to_player, "family_rang", rang);
                        
                        format(f_string144, sizeof f_string144, "%s выдал игроку %s - %s (%d ранг).", GetPlayerNameEx(playerid), GetPlayerNameEx(to_player),
                        family_rang_name[f][rang-1], rang);
                        SendFamilyMessage(f, f_string144);
                        SendFamilyLog(type_log_rang, playerid, to_player, f_string144);
                        return 1;
                    }
                }
                return 1;
            }

            switch(listitem)
            {
                case 0:
                {
                    if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][1] && GetPlayerRangFamily(playerid) != 5)
                        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу это не доступно.");
                    Dialog
                    (
                        playerid, 2236, DIALOG_STYLE_INPUT,
                        "{FF0000}Принять игрока",
                        "Введите ID игрока снизу чтобы принять игрока.",
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "select_type_2236", 1);
                }
                case 1:
                {
                    DeletePVar(playerid, "count_list");

                    if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][1] && GetPlayerRangFamily(playerid) != 5)
                        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу это не доступно.");


                    ShowMembersFamily(playerid, 0);
                }
                case 2:
                {
                    Dialog
                    (
                        playerid, 2236, DIALOG_STYLE_INPUT,
                        "{FF0000}Выдать мут",
                        "Введите ID игрока, кол-во минут, причину (до 12 симвл.), снизу \n"\
                        "чтобы выдать мут игроку.\n"\
                        "- Пример: 0, 25, Оск.",
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "select_type_2236", 3);
                }
                case 3:
                {
                    Dialog
                    (
                        playerid, 2236, DIALOG_STYLE_INPUT,
                        "{FF0000}Снять мут",
                        "Введите ID игрока, причину (до 12 симвл.) снизу чтобы снять мут игроку\n"\
                        "- Пример: 0, Заплатил",
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "select_type_2236", 4);
                }
                case 4:
                {
                    Dialog
                    (
                        playerid, 2236, DIALOG_STYLE_INPUT,
                        "{FF0000}Изменить ранг",
                        "Введите ID игрока или имя игрока и ранг через запятую\n"\
                        "- Ранг - это какой ранг выдать игроку.\n"\
                        "- Пример: Welsi_Developer, 2",
                        "Далее", "Назад"
                    );
                    SetPVarInt(playerid, "select_type_2236", 5);
                }
            }
        }
    }
    if(dialogid == 2368)
    {
        if(!response) return 1;

        switch(listitem)
        {
            case 0:
            {
                Dialog(
                    playerid, 2369, DIALOG_STYLE_INPUT,
                    "{FF0000}Добавить в черный список",
                    "{FFFFFF}Введите никнейм или ID игрока которого хотите добавить в черный список и причину через запятую\nПример: [1, неадекват]:",
                    "Добавить", "Назад"
                );
            }
            case 1:
            {
                Dialog(
                    playerid, 2370, DIALOG_STYLE_INPUT,
                    "{FF0000}Удалить из черного списка",
                    "{FFFFFF}Введите никнейм или ID игрока которого хотите удалить из черного списка",
                    "Удалить", "Назад"
                );
            }
            case 2: return FamilyGuiShowBlacklistList(playerid, 0);
        }
        return 1;
    }
    if(dialogid == 2369)
    {
        if(!response) return FamilyGuiShowBlacklistMenu(playerid);
        return FamilyGuiHandleBlacklistAdd(playerid, inputtext);
    }
    if(dialogid == 2370)
    {
        if(!response) return FamilyGuiShowBlacklistMenu(playerid);
        return FamilyGuiHandleBlacklistRemove(playerid, inputtext);
    }
    if(dialogid == 2371)
    {
        if(!response) return FamilyGuiShowBlacklistMenu(playerid);

        new page = GetPVarInt(playerid, "family_blacklist_page");
        if(listitem == 0)
        {
            if(!FamilyGuiShowBlacklistList(playerid, page + 1, 1))
                return FamilyGuiShowBlacklistList(playerid, page, 0);
            return 1;
        }

        if(listitem == 1)
        {
            if(page > 0)
                return FamilyGuiShowBlacklistList(playerid, page - 1, 0);

            return FamilyGuiShowBlacklistList(playerid, 0, 0);
        }

        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Данный игрок не найден.", " ");
    }
    if(dialogid == 2237)
    {
        if(!response) return 1;

        new type = GetPVarInt(playerid, "select_type_log");

        if(!type)
        {
            SetPVarInt(playerid, "select_type_log", listitem+1);

            type = GetPVarInt(playerid, "select_type_log");

            mysql_format(mysql, f_string184, sizeof f_string184, "SELECT * FROM family_log WHERE family ='%d' AND type = %d", GetFamily(GetPlayerIdFamily(playerid), family_database), type);
            new Cache:result = mysql_query(mysql, f_string184, true);

            new c = cache_num_rows();
            
            new r = c;

            if(!c) return SendClientMessage(playerid, -1, ""c_f_r"Логи не найдены.");

            new dialog[sizeof f_string184 * 10], text[124], time_data[24];

            if(c > 10) c = 10;

            for(new i, time; i < c; i++)
            {
                time = cache_get_field_content_int(i, "time");
                cache_get_field_content(i, "text", text);

                format(time_data, sizeof time_data, "%02d.%02d.%d %02d:%02d:%02d", 
                ConvertUnixTime(time, CONVERT_TIME_TO_DAYS), ConvertUnixTime(time, CONVERT_TIME_TO_MONTHS), ConvertUnixTime(time, CONVERT_TIME_TO_YEARS),
                ConvertUnixTime(time, CONVERT_TIME_TO_HOURS), ConvertUnixTime(time, CONVERT_TIME_TO_MINUTES), ConvertUnixTime(time, CONVERT_TIME_TO_SECONDS));

                format(f_string184, sizeof f_string184, "{FFFFFF}%d. %s %s\n", i + 1, text, time_data);
                strcat(dialog, f_string184);
            }

            if(r >= 11)
            {
                new buttom[21];
                format(buttom, sizeof buttom, "Следующая страница");
                strcat(dialog, buttom);
                SetPVarInt(playerid, "count_list", 1);

                SetPVarInt(playerid, "up_count", 10);
                SetPVarInt(playerid, "down_count", 11);
            } 

            Dialog
            (
                playerid, 2237, DIALOG_STYLE_LIST,
                "{FF0000} Логи",
                dialog,
                "Закрыть", ""
            );

            cache_delete(result);
            return 1;
        }

        new up = GetPVarInt(playerid, "up_count"),
        down = GetPVarInt(playerid, "down_count");

        if(listitem == up || listitem == down)
        {
            new list = GetPVarInt(playerid, "count_list");

            if(listitem == up)  list++;
            else if(listitem == down) list--;
            SetPVarInt(playerid, "count_list", list);

            new 
            Cache: result,
            id;

            mysql_format(mysql, f_string184, sizeof f_string184, "SELECT * FROM family_log WHERE family ='%d' AND type = %d", GetFamily(GetPlayerIdFamily(playerid), family_database), type);
            result = mysql_query(mysql, f_string184, true);

            new rows = cache_num_rows();
            
            if(!rows) return SendClientMessage(playerid, -1, ""c_f_r"Логи не найдены.");

            new count_rows, count = 10 * GetPVarInt(playerid, "count_list");

            if(rows >= count)
            {
                count_rows = count;
                SetPVarInt(playerid, "up_count", 10);
                SetPVarInt(playerid, "down_count", 11);
            }
            else
            {
                count_rows = rows;
                new p = count_rows - (count - 10);
                SetPVarInt(playerid, "down_count", p);
                SetPVarInt(playerid, "up_count", 10);
            }

            new dialog[sizeof f_string184 * 10], text[124], time_data[24];

            for(new i = count-10, time; i < count_rows; i++)
            {
                time = cache_get_field_content_int(i, "time");
                cache_get_field_content(i, "text", text);

                format(time_data, sizeof time_data, "%02d.%02d.%d %02d:%02d:%02d", 
                ConvertUnixTime(time, CONVERT_TIME_TO_DAYS), ConvertUnixTime(time, CONVERT_TIME_TO_MONTHS), ConvertUnixTime(time, CONVERT_TIME_TO_YEARS),
                ConvertUnixTime(time, CONVERT_TIME_TO_HOURS), ConvertUnixTime(time, CONVERT_TIME_TO_MINUTES), ConvertUnixTime(time, CONVERT_TIME_TO_SECONDS));

                format(f_string184, sizeof f_string184, "{FFFFFF}%d. %s %s\n", i + 1, text, time_data);
                strcat(dialog, f_string184);
            }

            if(rows >= count+1)
            {
                new buttom[21];
                format(buttom, sizeof buttom, "Следующая страница\n");
                strcat(dialog, buttom);

            }

            if(count >= 11)
            {
                new buttom_1[21];
                format(buttom_1, sizeof buttom_1, "Предыдущая страница");
                strcat(dialog, buttom_1);
            }

            Dialog
            (
                playerid, 2237, DIALOG_STYLE_LIST,
                "{FF0000} Логи",
                dialog,
                "Закрыть", ""
            );

            cache_delete(result);

            return 1;
        }
    }
    if(dialogid == DIALOG_FAMILY_GUI_LOG_MENU)
    {
        if(!response) return 1;

        if(listitem < 0 || listitem >= sizeof FAMILY_GUI_LOG_MENU_NAMES)
            return 1;

        return FamilyGuiShowLogList(playerid, listitem + 1, 0);
    }
    if(dialogid == DIALOG_FAMILY_GUI_LOG_LIST)
    {
        if(!response)
            return FamilyGuiShowLogsMenu(playerid);

        new log_menu_id = GetPVarInt(playerid, "family_gui_log_menu");
        new page = GetPVarInt(playerid, "family_gui_log_page");
        new row_count = GetPVarInt(playerid, "family_gui_log_row_count");
        new has_next = GetPVarInt(playerid, "family_gui_log_has_next");
        new has_prev = GetPVarInt(playerid, "family_gui_log_has_prev");

        if(has_next && listitem == row_count)
            return FamilyGuiShowLogList(playerid, log_menu_id, page + 1);

        if(has_prev && listitem == row_count + has_next)
            return FamilyGuiShowLogList(playerid, log_menu_id, page - 1);

        return FamilyGuiShowLogList(playerid, log_menu_id, page);
    }
    
    if(dialogid == 2238)
    {
        if(response)
        {
            return FamilyCreate(playerid, inputtext);
        }
    }
    if(dialogid == 2239)
    {
        if(response)
        {
            new rang = strval(inputtext);

            if(!(1 <= rang <= 5))
                return BackSendClientMessage(playerid, -1,  "Ранг должен быть от 1 до 5");

            new id = GetPVarInt(playerid, "select_fam_car");

            mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE family_cars SET rang=%d WHERE id=%d LIMIT 1", rang, id);
            mysql_query(mysql, f_string144, false);

            mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family_cars WHERE id=%d", id);
            new Cache:cache = mysql_query(mysql, f_string64);

            new model = cache_get_field_content_int(0, "model_id")-400, sql = cache_get_field_content_int(0, "id");

            cache_delete(cache);

            format(f_string144, sizeof f_string144, "%s[%d] изменил доступ к %s (%d) на %d ранг.", GetPlayerNameEx(playerid), playerid, GetVehicleInfo(model, VI_NAME), sql, rang);
            SendFamilyMessage(f,  f_string144);
        }
    }
    if(dialogid == 2240)
    {
        if(response)
        {
            if(GetPlayerDonateRub(playerid) >= 300)
            {
                GivePlayerDonateRub(playerid, -300);
                AddFamily(f, family_slot_veh, +, 1);
                UpdateColumnFamilyInt(GetFamily(f, family_database), "slot_veh", GetFamily(f, family_slot_veh));

                format(f_string144, sizeof f_string144, "%s[%d] купил слот для транспорта в семью. Всего: %d", 
                GetPlayerNameEx(playerid), playerid, GetFamily(f, family_slot_veh));
                SendFamilyMessage(f, f_string144);

                SendClientMessage(playerid, -1, ""c_f_g"Вы купили слот для транспорта в семью");
            }
            else FSendClientMessage(f_string144, playerid, -1, ""c_f_r"У вас не хватает %d донат-рублей", 300-GetPlayerDonateRub(playerid));
        }
    }
    if(dialogid == 2241)
    {
        if(response)
        {
            if(GetPlayerDonateRub(playerid) >= 100)
            {
                new to_player = strval(inputtext);

                if(!IsPlayerConnected(to_player) || to_player == playerid)
                    return SendClientMessage(playerid, -1, ""c_f_r"Данный игрок не в сети.");

                if(GetPlayerIdFamily(to_player) != -1)
                    return SendClientMessage(playerid, -1, ""c_f_r"Игрок уже состоит в семье.");

                if(!IsPlayerInRangeOfPlayer(playerid, to_player, 5.0))
                    return SendClientMessage(playerid, 0xCECECEFF, "Игрок слишком далеко");

                format(f_string144, sizeof f_string144, "{FFFF00}%s{FFFFFF}хочет передать полномочия семьи %s Вам.",
                GetPlayerNameEx(playerid), GetFamily(f, family_name));

                DeletePVar(to_player, "player_offer");
                Dialog
                (
                    to_player, 2242, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Передача семьи",
                    f_string144,
                    "Принять", "Отказать"
                );

                SetPVarInt(to_player, "player_offer", playerid);
            }
            else FSendClientMessage(f_string144, playerid, -1, ""c_f_r"У вас не хватает %d донат-рублей", 100-GetPlayerDonateRub(playerid));
        }
    }
    if(dialogid == 2242)
    {
        new player_offer = GetPVarInt(playerid, "player_offer"), ff = GetPlayerIdFamily(player_offer);

        if(!response)
        {
            SendClientMessage(player_offer, -1, ""c_f"Игрок отказался от вашего предложения.");
            SendClientMessage(playerid, -1, ""c_f"Вы отказались от предложения.");
            return 1;
        }

        if(!IsPlayerConnected(player_offer)) return SendClientMessage(playerid, -1, ""c_f_r"Игрок вышел из игры.");

        GivePlayerDonateRub(player_offer, -100);
        
        SetPlayerFamily(playerid, RANG_FAMILY, 5);
        SetPlayerFamily(playerid, ID_SQL_FAMILY, GetFamily(ff, family_database));
        SetPlayerFamily(playerid, ID_FAMILY, ff);
        UpdatePlayerDatabaseInt(playerid, "family_rang", GetPlayerFamily(playerid, RANG_FAMILY));
        UpdatePlayerDatabaseInt(playerid, "family_id", GetPlayerFamily(playerid, ID_SQL_FAMILY));

        SetPlayerFamily(player_offer, RANG_FAMILY, 1);
        UpdatePlayerDatabaseInt(player_offer, "family_rang", GetPlayerFamily(player_offer, RANG_FAMILY));

        SetFamily(ff, family_owner, GetPlayerAccountID(playerid));
        UpdateColumnFamilyInt(GetFamily(ff, family_database), "owner", GetFamily(ff, family_owner));

        format(f_string144, sizeof f_string144, "%s[%d] передал семью %s[%d]", 
        GetPlayerNameEx(player_offer), player_offer, GetPlayerNameEx(playerid), playerid);
        SendFamilyMessage(ff, f_string144);

        LoadPlayerFamily(playerid);
        LoadPlayerFamily(player_offer);

        FSendClientMessage(f_string144, player_offer, -1, ""c_f_g"Вы передали полномочия вашей семье игроку {FFFF00}%s", GetPlayerNameEx(playerid));
        FSendClientMessage(f_string144, playerid, -1, ""c_f_g"Вы получили полномочия семьи игрока {FFFF00}%s", GetPlayerNameEx(player_offer));
    }
    if(dialogid == 2243)
    {
        new player = GetPVarInt(playerid, "invite_player");

        if(response)
            return FamilyAcceptInvite(playerid, player);

        return FamilyDeclineInvite(playerid, player);
    }
    if(dialogid == 2244)
    {
        if(response)
        {
            new fam_name[32];

            if(sscanf(inputtext, "s[32]", fam_name) || strlen(inputtext) < 6)
                return SendClientMessage(playerid, -1, "Название семьи должно состоят от 6 до 32 символов");

            for(new i; i < strlen(fam_name); i++) if(fam_name[i] == '-' && fam_name[i+7] == '}') fam_name[i] = '{';

            format(family[f][family_name], 32, fam_name);
            mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE familynew SET name='%s' WHERE id = %d", GetFamily(f, family_name), GetFamily(f, family_database));
            mysql_query(mysql, f_string144, false);

            GivePlayerDonateRub(playerid, -100);

            FSendClientMessage(f_string144, playerid, -1, ""c_f_g"Вы изменили название вашей семьи на %s.", GetFamily(f, family_name));
            
            foreach(new i : Player)
            {
                if(GetPlayerIdFamily(i) != f) continue;
        
                UpdateDynamic3DTextLabelText(GetPlayerFamily(f, TEXT_FAMILY), -1, fam_name);
            }

            format(f_string144, sizeof f_string144, "Лидер семьи %s[%d] изменил название семьи на %s.", GetPlayerNameEx(playerid), playerid, fam_name);
            SendFamilyMessage(f, f_string144);
        }
    }
    if(dialogid == 2245)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0:
                {
                    Dialog
                    (
                        playerid, -1, DIALOG_STYLE_MSGBOX,
                        "{FF0000}Сезоны семьи",
                        "В сезонах семьи главное это репутации.\n"\
                        "Получать репутацию можно в сражениях за {FFFF00}разные предприятия {FFFFFF}и\n"\
                        "{FFFF00}семейных контейнерах.\n"\
                        "{FFFFFF}Конец сезона семьи происходит в {FFFF00}00:00 Четверга.\n\n"\
                        "{FFFFFF}Награда за {FFFF00}первое место{FFFFFF} в топе семей:\n"\
                        "90.000 рублей и 40 донат-рублей каждому игроку из семьи\n"\
                        "Два слота для транспорта в семью\n\n"\
                        "{FFFFFF}Награда за {FFFF00}второе место{FFFFFF} в топе семей:\n"\
                        "60.000 рублей и 30 донат-рублей каждому игроку из семьи\n"\
                        "Один слот для транспорта в семью\n\n"\
                        "{FFFFFF}Награда за {FFFF00}третье место{FFFFFF} в топе семей:\n"\
                        "30.000 рублей и 20 донат-рублей каждому игроку из семьи",
                        "Выйти", ""
                    );
                }
                case 1:
                {

                    mysql_format(mysql, f_string144, sizeof f_string144, "SELECT * FROM familynew WHERE reputation >= '0' ORDER BY reputation DESC");
                    new Cache:result = mysql_query(mysql, f_string144);

                    if(mysql_errno()) return print("[COLLECTOR_SYSTEM] Error Sql Query: ?1");

                    new rows = cache_num_rows();

                    new list[68], dialog[584];

                    new name[32], name_pl[32], rep_pl, reputation, mesto, id, select_family = true, database_family = GetFamily(GetPlayerIdFamily(playerid), family_database);

                    for(new i, count;i < rows;i++)
                    {
                        id = cache_get_field_content_int(i, "id");
                        cache_get_field_content(i, "name", name, mysql, 32);
                        reputation = cache_get_field_content_int(i, "reputation");

                        if(database_family == id)
                        {
                            format(name_pl, sizeof name_pl, name);
                            rep_pl = reputation;
                            mesto = i+1;
                        } 

                        if(count != 10)
                        {
                            format(list, sizeof list, "{FFFFFF} ?%d %s %d\n", i+1, name, reputation);
                            strcat(dialog, list);
                            count++;
                        }
                    }

                    format(list, sizeof list, "{FFFF00}- {FFFFFF}?%d %s %d", mesto, name_pl, rep_pl);
                    strcat(dialog, list);
                    
                    Dialog(playerid, -1, DIALOG_STYLE_LIST, "{FF0000}Рейтинг лучших семей", dialog, "Закрыть", "");
                }
            }
        }
    }
    #if defined fam_OnDialogResponse
    return fam_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
   #else
        return 1;
    #endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse fam_OnDialogResponse
#if defined fam_OnDialogResponse
forward fam_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

stock ShowDialogFamilyCar(playerid, id)
{
    SetPVarInt(playerid, "select_fam_car", id);

    new status = GetStatusFamilyCar(id);

    if(!status)
    {
        if(GetPlayerRangFamily(playerid) != 5)
        {
            Dialog
            (
                playerid, 2224, DIALOG_STYLE_LIST, 
                "{FF0000}Семейный транспорт",
                "1. Отметить транспорт на GPS\n"\
                "2. Загрузить транспорт\n"\
                "3. Удалить транспорт",
                "Далее", "Выйти"
            );
        }
        else
        {
            Dialog
            (
                playerid, 2224, DIALOG_STYLE_LIST, 
                "{FF0000}Семейный транспорт",
                "1. Отметить транспорт на GPS\n"\
                "2. Загрузить транспорт\n"\
                "3. Удалить транспорт\n"\
                "4. Изменить доступ к т/с",
                "Далее", "Выйти"
            );  
        }
    }
    else
    {
        Dialog
        (
            playerid, 2224, DIALOG_STYLE_LIST, 
            "{FF0000}Семейный транспорт",
            "1. Отметить транспорт на GPS\n"\
            "2. Выгрузить транспорт",
            "Далее", "Выйти"
        );     
    }
}

#include "../include/family_tuning_v55.inc"

stock FamilyCarApplyVehicleStoreComponents(vehicleid, family_car_sql_id, viewer = INVALID_PLAYER_ID)
{
    if(!IsValidVehicle(vehicleid) || family_car_sql_id <= 0)
        return 0;
    new idx = GetVehicleData(vehicleid, V_ACTION_ID);
    if(idx < 0 || idx >= MAX_OWNABLE_CARS) return 0;
    if(viewer != INVALID_PLAYER_ID)
        return PermanentTuning_ApplyComponentsForPlayer(viewer, vehicleid);
    new query[160];
    mysql_format(mysql, query, sizeof query, "SELECT componentid FROM %s WHERE vehicleid = %d AND state = 2",
        g_FT55_New[idx] ? "family_vehicle_components" : "vehicle_store_components", family_car_sql_id);

    new Cache:result = mysql_query(mysql, query, true);
    new rows = cache_num_rows();

    for(new i; i < rows; i++)
    {
        new componentid = cache_get_field_content_int(i, "componentid");
        if(componentid <= 0) continue; // GetTuneIdFromItem checks its own table bounds.
        if(!IsStoredTuneItemAllowedForModel(GetVehicleData(vehicleid, V_MODELID), componentid))
            continue;
        new tuneid = GetTuneIdFromItem(componentid);
        if(tuneid <= 0) continue;
        if(viewer != INVALID_PLAYER_ID)
            AddToVehicleComponentForPlayer(viewer, vehicleid, tuneid);
        else AddVehicleComponent(vehicleid, tuneid);
    }

    cache_delete(result);
    return 1;
}

stock MoveOwnableCar(playerid, database_car, fam)
{
    new fam_id = GetPlayerIdFamily(playerid);
    if(fam_id < 0 || fam_id >= MAX_FAM || GetPlayerRangFamily(playerid) != 5 || GetFamily(fam_id, family_database) != fam) return 0;
    if(!FT55_Init())
        return SendClientMessage(playerid, -1, "Не удалось подготовить сохранение тюнинга. Передача отменена.");

    //if(GetFamily(fam_id, family_count_veh)+1 > GetFamily(fam_id, family_slot_veh))
        //return SendClientMessage(playerid, -1, ""c_f_r"В семье не хватает слотов.");

    new select_query[160];
    mysql_format(mysql, select_query, sizeof select_query, "SELECT * FROM ownable_cars WHERE id=%d AND owner_id=%d", database_car, GetPlayerAccountID(playerid));
    new Cache:cache_sql = mysql_query(mysql, select_query);

    if(mysql_errno() || !cache_num_rows())
    {
        cache_delete(cache_sql);
        SendClientMessage(playerid, -1, "Личный автомобиль не найден или ошибка БД. Передача отменена.");
        return 0;
    }

    new model_id, color_1, color_2, number[32], family_vynil_name[32],
    f_state, nitro_level, launch_control, family_pdvradar, family_lights_color, family_underlights_color, family_underlights_color_lf, family_underlights_color_rt,
    is_far_light_active, pnevmo_selected, family_percentofclirness, family_percentofclirnessz, is_hydro_active,
    Float:pos_x, Float:pos_y, Float:pos_z, Float:angle;

    model_id = cache_get_field_content_int(0, "model_id");
    color_1 = cache_get_field_content_int(0, "color_1");
    color_2 = cache_get_field_content_int(0, "color_2");
    pos_x = cache_get_field_content_float(0, "pos_x");
    pos_y = cache_get_field_content_float(0, "pos_y");
    pos_z = cache_get_field_content_float(0, "pos_z");
    angle = cache_get_field_content_float(0, "angle");
    cache_get_field_content(0, "number", number, mysql, sizeof number);
    cache_get_field_content(0, "vynil_name", family_vynil_name, mysql, sizeof family_vynil_name);
    f_state = cache_get_field_content_int(0, "f_state");
    nitro_level = cache_get_field_content_int(0, "nitro_level");
    launch_control = cache_get_field_content_int(0, "launch");
    family_pdvradar = cache_get_field_content_int(0, "pdvradar");
    family_lights_color = cache_get_field_content_int(0, "lights_color");
    family_underlights_color = cache_get_field_content_int(0, "underlights_color");
    family_underlights_color_lf = cache_get_field_content_int(0, "underlights_color_lf");
    family_underlights_color_rt = cache_get_field_content_int(0, "underlights_color_rt");
    is_far_light_active = cache_get_field_content_int(0, "is_FarLight_active");
    pnevmo_selected = cache_get_field_content_int(0, "pnevmo_selected");
    family_percentofclirness = cache_get_field_content_int(0, "percentofclirness");
    family_percentofclirnessz = cache_get_field_content_int(0, "percentofclirnessZ");
    is_hydro_active = cache_get_field_content_int(0, "is_hydro_active");
    printf("[FAMILY CAR][MOVE TO FAMILY] ownable_id=%d family=%d vinyl=%s number=%s", database_car, fam, family_vynil_name, number);
    if(!strlen(family_vynil_name))
    {
        for(new vehicleid = 1; vehicleid < MAX_VEHICLES; vehicleid++)
        {
            if(!IsValidVehicle(vehicleid)) continue;
            if(GetVehicleData(vehicleid, V_ACTION_TYPE) != VEHICLE_ACTION_TYPE_OWNABLE_CAR) continue;

            new ownable_index = GetVehicleData(vehicleid, V_ACTION_ID);
            if(ownable_index < 0) continue;
            if(GetOwnableCarData(ownable_index, OC_SQL_ID) != database_car) continue;

            printf("[FAMILY CAR][MOVE TO FAMILY][SOURCE] ownable_id=%d vehicleid=%d ownable_index=%d db_vinyl=%s mem_vinyl=%s iscase=%d model=%d", database_car, vehicleid, ownable_index, family_vynil_name, vInfo[ownable_index][vynil_name], vInfo[ownable_index][iscase], GetOwnableCarData(ownable_index, OC_MODEL_ID));

            if(vInfo[ownable_index][vynil_name][0] != '\0')
            {
                format(family_vynil_name, sizeof family_vynil_name, "%s", vInfo[ownable_index][vynil_name]);
                printf("[FAMILY CAR][MOVE TO FAMILY][FALLBACK DBNAME] ownable_id=%d vehicleid=%d vinyl=%s", database_car, vehicleid, family_vynil_name);
                break;
            }

            if(vInfo[ownable_index][iscase] > 0)
            {
                new remap_name[64];
                remap_name[0] = '\0';
                GetRemapName(GetOwnableCarData(ownable_index, OC_MODEL_ID), remap_name, sizeof remap_name);
                printf("[FAMILY CAR][MOVE TO FAMILY][CASE LOOKUP] ownable_id=%d vehicleid=%d model=%d remap=%s", database_car, vehicleid, GetOwnableCarData(ownable_index, OC_MODEL_ID), remap_name);
                if(remap_name[0] != '\0')
                {
                    format(family_vynil_name, sizeof family_vynil_name, "%s", remap_name);
                    printf("[FAMILY CAR][MOVE TO FAMILY][FALLBACK CASE] ownable_id=%d vehicleid=%d vinyl=%s", database_car, vehicleid, family_vynil_name);
                    break;
                }
            }

            printf("[FAMILY CAR][MOVE TO FAMILY][NO VINYL SOURCE] ownable_id=%d vehicleid=%d ownable_index=%d", database_car, vehicleid, ownable_index);
            break;
        }
    }
    printf("[FAMILY CAR][MOVE TO FAMILY][FINAL] ownable_id=%d family=%d vinyl=%s number=%s", database_car, fam, family_vynil_name, number);
    if(!strlen(family_vynil_name) && cache_get_field_content_int(0, "iscase") > 0)
    {
        new remap_name[64];
        remap_name[0] = '\0';
        GetRemapName(model_id, remap_name, sizeof remap_name);
        printf("[FAMILY CAR][MOVE TO FAMILY][MODEL FALLBACK] ownable_id=%d model=%d remap=%s", database_car, model_id, remap_name);
        if(remap_name[0] != '\0')
        {
            format(family_vynil_name, sizeof family_vynil_name, "%s", remap_name);
        }
    }
    new plate_type = TYPE_RU;
    new plate[16], region[8];
    plate[0] = '\0';
    region[0] = '\0';

    if(!ParseStoredPlateValue(number, plate_type, plate, sizeof plate, region, sizeof region))
    {
        format(plate, sizeof plate, "%s", number);
        format(region, sizeof region, "");
    }

    new query[2048];
    mysql_format
    (
        mysql, query, sizeof query,
        "INSERT INTO family_cars \
        (family_owner,model_id,color_1,color_2,pos_x,pos_y,pos_z,angle,create_time,number,rang,plate_type,plate_number,plate_region,vynil_name,f_state,nitro_level,launch,pdvradar,lights_color,underlights_color,underlights_color_lf,underlights_color_rt,is_FarLight_active,pnevmo_selected,percentofclirness,percentofclirnessZ,is_hydro_active) \
        VALUES \
        ('%d','%d','%d','%d','%f','%f','%f','%f','%d','%e','5','%d','%e','%e','%e','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d')",
        fam,
        model_id,
        color_1,
        color_2,
        pos_x,
        pos_y,
        pos_z,
        angle,
        gettime(),
        number,
        plate_type,
        plate,
        region,
        family_vynil_name,
        f_state,
        nitro_level,
        launch_control,
        family_pdvradar,
        family_lights_color,
        family_underlights_color,
        family_underlights_color_lf,
        family_underlights_color_rt,
        is_far_light_active,
        pnevmo_selected,
        family_percentofclirness,
        family_percentofclirnessz,
        is_hydro_active
    );
    printf("[FAMILY CAR][SQL][INSERT FAMILY] %s", query);
    new Cache:insert_result = mysql_query(mysql, query, true);
    new family_car_sql_id = cache_insert_id();
    new insert_error = mysql_errno();
    cache_delete(insert_result);

    if(insert_error || family_car_sql_id <= 0 ||
       !FT55_CopyFields(database_car, family_car_sql_id, true) ||
       !FT55_CopyComponents(database_car, family_car_sql_id, true))
    {
        cache_delete(cache_sql);
        if(!insert_error) FT55_DiscardCopy(family_car_sql_id, true);
        SendClientMessage(playerid, -1, "Не удалось сохранить тюнинг. Машина оставлена владельцу.");
        return 0;
    }

    mysql_format(mysql, f_string64, sizeof f_string64, "DELETE FROM ownable_cars WHERE id=%d", database_car);
    printf("[FAMILY CAR][SQL][DELETE OWNABLE] %s", f_string64);
    if(!FT55_Query(f_string64))
    {
        cache_delete(cache_sql);
        printf("[FAMILY_TUNING][RECOVERY_REQUIRED] ownable=%d family=%d delete_source_uncertain", database_car, family_car_sql_id);
        SendClientMessage(playerid, -1, "Ошибка завершения передачи автомобиля.");
        return 0;
    }
    else
    {
        UnloadPlayerOwnableCar(playerid);
        ShowNotificationNew(playerid, 3, 6, 0, 0, "Вы добавили новое авто в семью", " ");
        AddFamily(fam_id, family_count_veh, +, 1);
    }
    cache_delete(cache_sql);
    return 1;
}

stock MoveFamilyCar(database_car, playerid)
{
    new fam = GetPlayerIdFamily(playerid);
    if(fam < 0 || fam >= MAX_FAM || GetPlayerRangFamily(playerid) != 5) return 0;
    if(!FT55_Init()) return 0;

    new select_query[160];
    mysql_format(mysql, select_query, sizeof select_query, "SELECT * FROM family_cars WHERE id=%d AND family_owner=%d", database_car, GetFamily(fam, family_database));
    new Cache:cache_sql = mysql_query(mysql, select_query);

    if(mysql_errno())
    {
        cache_delete(cache_sql);
        SendClientMessage(playerid,-1,""c_f_r" Ошибка в SQL-запросе / Code: MoveFamilyCar");
        return 0;
    }

    if(!cache_num_rows())
    {
        cache_delete(cache_sql);
        SendClientMessage(playerid,-1,""c_f_r" Транспорт не найден.");
        return 0;
    }

    new model_id, color_1, color_2, number[32], family_vynil_name[32],
    f_state, nitro_level, launch_control, family_pdvradar, family_lights_color, family_underlights_color, family_underlights_color_lf, family_underlights_color_rt,
    is_far_light_active, pnevmo_selected, family_percentofclirness, family_percentofclirnessz, is_hydro_active,
    Float:pos_x, Float:pos_y, Float:pos_z, Float:angle;

    model_id = cache_get_field_content_int(0, "model_id");
    color_1 = cache_get_field_content_int(0, "color_1");
    color_2 = cache_get_field_content_int(0, "color_2");
    pos_x = cache_get_field_content_float(0, "pos_x");
    pos_y = cache_get_field_content_float(0, "pos_y");
    pos_z = cache_get_field_content_float(0, "pos_z");
    angle = cache_get_field_content_float(0, "angle");
    cache_get_field_content(0, "number", number, mysql, sizeof number);
    cache_get_field_content(0, "vynil_name", family_vynil_name, mysql, sizeof family_vynil_name);
    f_state = cache_get_field_content_int(0, "f_state");
    nitro_level = cache_get_field_content_int(0, "nitro_level");
    launch_control = cache_get_field_content_int(0, "launch");
    family_pdvradar = cache_get_field_content_int(0, "pdvradar");
    family_lights_color = cache_get_field_content_int(0, "lights_color");
    family_underlights_color = cache_get_field_content_int(0, "underlights_color");
    family_underlights_color_lf = cache_get_field_content_int(0, "underlights_color_lf");
    family_underlights_color_rt = cache_get_field_content_int(0, "underlights_color_rt");
    is_far_light_active = cache_get_field_content_int(0, "is_FarLight_active");
    pnevmo_selected = cache_get_field_content_int(0, "pnevmo_selected");
    family_percentofclirness = cache_get_field_content_int(0, "percentofclirness");
    family_percentofclirnessz = cache_get_field_content_int(0, "percentofclirnessZ");
    is_hydro_active = cache_get_field_content_int(0, "is_hydro_active");
    printf("[FAMILY CAR][MOVE FROM FAMILY] family_car_id=%d player=%d vinyl=%s number=%s", database_car, playerid, family_vynil_name, number);

    new plate_type = cache_get_field_content_int(0, "plate_type");
    if(plate_type < TYPE_RU || plate_type > TYPE_KZ) plate_type = TYPE_RU;

    new plate[16], region[8], stored_number[32];
    cache_get_field_content(0, "plate_number", plate, mysql, sizeof plate);
    cache_get_field_content(0, "plate_region", region, mysql, sizeof region);

    if(strlen(plate))
        BuildStoredPlateValue(plate_type, plate, region, stored_number, sizeof stored_number);
    else
        format(stored_number, sizeof stored_number, "%s", number);

    new query[2048];
    mysql_format
    (
        mysql, query, sizeof query,
        "INSERT INTO ownable_cars \
        (owner_id,model_id,color_1,color_2,pos_x,pos_y,pos_z,angle,create_time,number,vynil_name,f_state,nitro_level,launch,pdvradar,lights_color,underlights_color,underlights_color_lf,underlights_color_rt,is_FarLight_active,pnevmo_selected,percentofclirness,percentofclirnessZ,is_hydro_active) \
        VALUES \
        ('%d','%d','%d','%d','%f','%f','%f','%f','%d','%e','%e','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d','%d')",
        GetPlayerAccountID(playerid),
        model_id,
        color_1,
        color_2,
        pos_x,
        pos_y,
        pos_z,
        angle,
        gettime(),
        stored_number,
        family_vynil_name,
        f_state,
        nitro_level,
        launch_control,
        family_pdvradar,
        family_lights_color,
        family_underlights_color,
        family_underlights_color_lf,
        family_underlights_color_rt,
        is_far_light_active,
        pnevmo_selected,
        family_percentofclirness,
        family_percentofclirnessz,
        is_hydro_active
    );
    printf("[FAMILY CAR][SQL][INSERT OWNABLE] %s", query);
    new Cache:insert_result = mysql_query(mysql, query, true);
    new ownable_car_sql_id = cache_insert_id();
    new insert_error = mysql_errno();
    cache_delete(insert_result);

    cache_set_active(cache_sql);
    new bool:modern_tuning = cache_get_field_content_int(0, "tuning_v55") != 0;
    if(insert_error || ownable_car_sql_id <= 0 ||
       (modern_tuning && !FT55_CopyFields(database_car, ownable_car_sql_id, false)) ||
       !FT55_CopyComponents(database_car, ownable_car_sql_id, false, modern_tuning))
    {
        cache_delete(cache_sql);
        if(!insert_error) FT55_DiscardCopy(ownable_car_sql_id, false);
        SendClientMessage(playerid, -1, "Не удалось перенести тюнинг. Автомобиль оставлен семье.");
        return 0;
    }

    mysql_format(mysql, f_string64, sizeof f_string64, "DELETE FROM family_cars WHERE id=%d", database_car);
    printf("[FAMILY CAR][SQL][DELETE FAMILY] %s", f_string64);
    if(!FT55_Query(f_string64))
    {
        cache_delete(cache_sql);
        printf("[FAMILY_TUNING][RECOVERY_REQUIRED] family=%d ownable=%d delete_source_uncertain", database_car, ownable_car_sql_id);
        SendClientMessage(playerid, -1, "Ошибка завершения возврата автомобиля.");
        return 0;
    }
    else
    {
        UnLoadFamilyCar(database_car);
        ShowNotificationNew(playerid, 3, 6, 0, 0, "Вы успешно удалили авто из семьи.", " ");
        new vehicle_name[48];
        GetVehicleModelName(model_id, vehicle_name, sizeof vehicle_name);
        format(f_string144, sizeof f_string144, "Владелец %s удалил из семьи автомобиль %s", GetPlayerNameEx(playerid), vehicle_name);
        SendFamilyLog(type_log_car, playerid, -1, f_string144);
        AddFamily(fam, family_count_veh, -, 1);
    }
    cache_delete(cache_sql);
    return 1;
}

stock LoadFamilyCar(database)
{
    if(!FT55_Init()) return 0;
    new rows, vehicleid;
    new Cache: result;

    mysql_format(mysql, f_string64, sizeof f_string64, "SELECT * FROM family_cars WHERE id=%d", database);
    printf("[FAMILY CAR][SQL][LOAD FAMILY] %s", f_string64);
    result = mysql_query(mysql, f_string64, true);
    rows = cache_num_rows();

    if(!rows) { cache_delete(result); return 0; }

    new free_id = GetFreeIDFamilyCar();
    if(free_id < 0 || free_id >= MAX_OWNABLE_CARS) { cache_delete(result); return 0; }
    FT55_ReadCache(free_id);
    SetCarFamily(free_id, CAR_F_database,       cache_get_field_content_int(0, "id"));

    SetCarFamily(free_id, OW_F_database,     cache_get_field_content_int(0, "family_owner"));
    SetCarFamily(free_id, OW_F_server,     GetFamilyIDSQL(GetCarFamily(free_id, OW_F_database)));

    SetCarFamily(free_id, V_F_MODEL,     cache_get_field_content_int(0, "model_id"));
    SetCarFamily(free_id, V_F_COLOR_1,      cache_get_field_content_int(0, "color_1"));
    SetCarFamily(free_id, V_F_COLOR_2,      cache_get_field_content_int(0, "color_2"));
    SetCarFamily(free_id, V_F_RANG,         cache_get_field_content_int(0, "rang"));

    SetCarFamily(free_id, V_F_SPAWN_X,        cache_get_field_content_float(0, "pos_x"));
    SetCarFamily(free_id, V_F_SPAWN_Y,        cache_get_field_content_float(0, "pos_y"));
    SetCarFamily(free_id, V_F_SPAWN_Z,        cache_get_field_content_float(0, "pos_z"));
    SetCarFamily(free_id, V_F_SPAWN_A,        cache_get_field_content_float(0, "angle"));
    SetCarFamily(free_id, V_F_FSTATE,         cache_get_field_content_int(0, "f_state"));
    SetCarFamily(free_id, V_F_NITRO,          cache_get_field_content_int(0, "nitro_level"));
    SetCarFamily(free_id, V_F_LAUNCH,         cache_get_field_content_int(0, "launch"));
    SetCarFamily(free_id, V_F_PDVRADAR,       cache_get_field_content_int(0, "pdvradar"));
    SetCarFamily(free_id, V_F_LIGHTS_COLOR,   cache_get_field_content_int(0, "lights_color"));
    SetCarFamily(free_id, V_F_UNDERLIGHT_COLOR,    cache_get_field_content_int(0, "underlights_color"));
    SetCarFamily(free_id, V_F_UNDERLIGHT_COLOR_LF, cache_get_field_content_int(0, "underlights_color_lf"));
    SetCarFamily(free_id, V_F_UNDERLIGHT_COLOR_RT, cache_get_field_content_int(0, "underlights_color_rt"));
    SetCarFamily(free_id, V_F_IS_FAR_LIGHT_ACTIVE, cache_get_field_content_int(0, "is_FarLight_active"));
    SetCarFamily(free_id, V_F_SELECTED_PNEVMO,     cache_get_field_content_int(0, "pnevmo_selected"));
    SetCarFamily(free_id, V_F_PERCENT_CLR,         cache_get_field_content_int(0, "percentofclirness"));
    SetCarFamily(free_id, V_F_PERCENT_CLR_Z,       cache_get_field_content_int(0, "percentofclirnessZ"));
    SetCarFamily(free_id, V_F_IS_HYDRO_ACTIVE,     cache_get_field_content_int(0, "is_hydro_active"));

    //addition (покупай дополнение с каптами и контами фамы)
    SetCarFamily(free_id, V_F_COUNT_BOX,        0);
    SetCarFamily(free_id, V_F_TEXT_CONT,        STREAMER_TAG_3D_TEXT_LABEL:-1);
    SetCarFamily(free_id, V_F_AREA_CONT,        -1);
    SetCarFamily(free_id, V_F_STATUS_CONT,      false);
    

    cache_get_field_content(0, "number", vehicle_family[free_id][V_F_NUMBER], mysql, 32);
    cache_get_field_content(0, "vynil_name", vehicle_family[free_id][V_F_VINYL_NAME], mysql, 32);
    printf("[FAMILY CAR][LOAD] family_car_id=%d free_id=%d model=%d vinyl=%s number=%s", database, free_id, GetCarFamily(free_id, V_F_MODEL), vehicle_family[free_id][V_F_VINYL_NAME], vehicle_family[free_id][V_F_NUMBER]);
    if(!ResolveFamilyCarVinylName(free_id, vehicle_family[free_id][V_F_VINYL_NAME], 32, true))
    {
        printf("[FAMILY CAR][LOAD][MODEL LOOKUP] family_car_id=%d free_id=%d model=%d remap=<empty>", database, free_id, GetCarFamily(free_id, V_F_MODEL));
    }
    else
    {
        printf("[FAMILY CAR][LOAD][VINYL READY] family_car_id=%d free_id=%d vinyl=%s", database, free_id, vehicle_family[free_id][V_F_VINYL_NAME]);
    }
    new plate_type = cache_get_field_content_int(0, "plate_type");
    new plate[16], region[8];
    plate[0] = '\0';
    region[0] = '\0';

    if(plate_type < TYPE_RU || plate_type > TYPE_KZ)
    {
        plate_type = TYPE_RU;
        ParseStoredPlateValue(vehicle_family[free_id][V_F_NUMBER], plate_type, plate, sizeof plate, region, sizeof region);
    }
    else
    {
        cache_get_field_content(0, "plate_number", plate, mysql, sizeof plate);
        cache_get_field_content(0, "plate_region", region, mysql, sizeof region);
    }
    //SetCarFamily(free_id, OC_FUEL,        cache_get_field_content_float(0, "fuel"));

    // ----------------------------------------------------------------------------------------
    vehicleid = CreateVehicle
    (
        GetCarFamily(free_id, V_F_MODEL),
        GetCarFamily(free_id, V_F_SPAWN_X),
        GetCarFamily(free_id, V_F_SPAWN_Y),
        GetCarFamily(free_id, V_F_SPAWN_Z),
        GetCarFamily(free_id, V_F_SPAWN_A),
        GetCarFamily(free_id, V_F_COLOR_1),
        GetCarFamily(free_id, V_F_COLOR_2),
        -1,
        0,
        VEHICLE_ACTION_TYPE_FAMILY_CAR,
        free_id
    );

    printf("%d, %f %f %f %f %d %d", GetCarFamily(free_id, V_F_MODEL), GetCarFamily(free_id, V_F_SPAWN_X), GetCarFamily(free_id, V_F_SPAWN_Y), GetCarFamily(free_id, V_F_SPAWN_Z), GetCarFamily(free_id, V_F_SPAWN_A), GetCarFamily(free_id, V_F_COLOR_1), GetCarFamily(free_id, V_F_COLOR_2));
    
    cache_delete(result);

    if(vehicleid != INVALID_VEHICLE_ID)
    {
        if(strlen(plate))
            SetVehicleNumberPlateEx(vehicleid, plate_type, plate, region);
        else
            SetVehicleNumberPlateEx(vehicleid, TYPE_RU, "", "");

		SetVehicleParam(vehicleid, V_LOCK, false);
        FamilyCarApplyVehicleStoreComponents(vehicleid, GetCarFamily(free_id, CAR_F_database));
        FT55_Queue(vehicleid);

		SetVehicleData(vehicleid, V_MILEAGE, 0.0);
        return 1;
    }

    return 0;
}

stock UnLoadFamilyCar(database)
{
	new vehicleid = GetVehicleFamilyCar(database);

	if(vehicleid == INVALID_VEHICLE_ID)
	{
		return -1;
	}

	new id = GetVehicleData(vehicleid, V_ACTION_ID);

	DestroyVehicleLabel(vehicleid);
	++g_FT55_Token[vehicleid];
	g_FT55_New[id] = false;

    SetCarFamily(id, CAR_F_database,       -1);

    SetCarFamily(id, OW_F_database,     -1);

    SetCarFamily(id, V_F_MODEL,     0);
    SetCarFamily(id, V_F_COLOR_1,   0);
    SetCarFamily(id, V_F_COLOR_2,   0);
    SetCarFamily(id, V_F_RANG,      0);

    SetCarFamily(id, V_F_SPAWN_X,        0.0);
    SetCarFamily(id, V_F_SPAWN_Y,        0.0);
    SetCarFamily(id, V_F_SPAWN_Z,        0.0);
    SetCarFamily(id, V_F_SPAWN_A,        0.0);
    SetCarFamily(id, V_F_FSTATE,         0);
    SetCarFamily(id, V_F_NITRO,          0);
    SetCarFamily(id, V_F_LAUNCH,         0);
    SetCarFamily(id, V_F_PDVRADAR,       0);
    SetCarFamily(id, V_F_LIGHTS_COLOR,   0);
    SetCarFamily(id, V_F_UNDERLIGHT_COLOR,    0);
    SetCarFamily(id, V_F_UNDERLIGHT_COLOR_LF, 0);
    SetCarFamily(id, V_F_UNDERLIGHT_COLOR_RT, 0);
    SetCarFamily(id, V_F_IS_FAR_LIGHT_ACTIVE, 0);
    SetCarFamily(id, V_F_SELECTED_PNEVMO,     0);
    SetCarFamily(id, V_F_PERCENT_CLR,         0);
    SetCarFamily(id, V_F_PERCENT_CLR_Z,       0);
    SetCarFamily(id, V_F_IS_HYDRO_ACTIVE,     0);

    if(IsValidDynamicArea(GetCarFamily(id, V_F_AREA_CONT))) DestroyDynamicArea(GetCarFamily(id, V_F_AREA_CONT));
    if(GetCarFamily(id, V_F_TEXT_CONT) != STREAMER_TAG_3D_TEXT_LABEL:-1)  Delete3DTextLabel(GetCarFamily(id, V_F_TEXT_CONT));

    SetCarFamily(id, V_F_TEXT_CONT,        STREAMER_TAG_3D_TEXT_LABEL:-1);
    SetCarFamily(id, V_F_AREA_CONT,        -1);
    SetCarFamily(id, V_F_STATUS_CONT,      false);
    SetCarFamily(id, V_F_COUNT_BOX,        0);

	
	DestroyVehicle(vehicleid);

	return 1;
}


stock SendFamilyMessage(fam, text[])
{
    new color[9], name[32];

    format(name, sizeof name, family[fam][family_name]);

    for(new i; i < strlen(name);i++)
    {
        if(name[i] == '{' && name[i+7] == '}') 
        {
            for(new d = 0;d < 8;d++) color[d] = name[i+d];
            break;
        }
    }

    if(!strlen(color)) format(color, sizeof color, family_type_color[GetFamily(fam, family_color)]);
    
    new string[384];
    format(string, sizeof string, "%s%s[%s] %s", color, color, GetFamily(fam, family_name), text);

    foreach(new i : Player)
    {
        if(!IsPlayerConnected(i)) continue;
        else if(GetPlayerFamily(i, ID_FAMILY) != fam) continue;

        SendClientMessage(i, -1, string);
    }

    return 1;

}

stock GetStatusFamilyCar(database_car)
{
    foreach(new i : Vehicle)
    {
        if(GetVehicleData(i, V_ACTION_TYPE) != VEHICLE_ACTION_TYPE_FAMILY_CAR) continue;
        else if(GetCarFamily(GetVehicleData(i, V_ACTION_ID), CAR_F_database) != database_car) continue;
        return 1;
    }
    return 0;
} 

stock GetVehicleFamilyCar(database_car)
{
    new id = -1;
    foreach(new i : Vehicle)
    {
        if(GetVehicleData(i, V_ACTION_TYPE) != VEHICLE_ACTION_TYPE_FAMILY_CAR) continue;

        id = GetVehicleData(i, V_ACTION_ID);
        if(GetCarFamily(id, CAR_F_database) != database_car) continue;
        return i;
    }
    return INVALID_VEHICLE_ID;
}

stock GetFreeIDFamilyCar()
{
    for(new i; i < MAX_OWNABLE_CARS;i++)
    {
        if(GetCarFamily(i, CAR_F_database) != -1) continue;
        return i;
    }
    return -1;
}

stock ResolveFamilyCarVinylName(family_index, dest[], size, bool:save_if_missing = false)
{
    if(size <= 0)
    {
        return 0;
    }

    if(!(0 <= family_index < MAX_OWNABLE_CARS))
    {
        dest[0] = '\0';
        return 0;
    }

    if(GetCarFamily(family_index, CAR_F_database) == -1)
    {
        dest[0] = '\0';
        return 0;
    }

    // dest may be the V_F_VINYL_NAME field itself during family-car loading.
    new stored_vinyl[32];
    format(stored_vinyl, sizeof stored_vinyl, "%s", GetCarFamily(family_index, V_F_VINYL_NAME));
    dest[0] = '\0';

    if(stored_vinyl[0] != '\0')
    {
        format(dest, size, "%s", stored_vinyl);
        return 1;
    }

    if(g_FT55_New[family_index] && !g_FT55[family_index][FT55_CASE]) return 0;
    GetRemapName(GetCarFamily(family_index, V_F_MODEL), dest, size);
    if(dest[0] == '\0')
    {
        return 0;
    }

    format(vehicle_family[family_index][V_F_VINYL_NAME], 32, "%s", dest);

    if(save_if_missing)
    {
        new query[160];
        mysql_format
        (
            mysql, query, sizeof query,
            "UPDATE family_cars SET vynil_name='%e' WHERE id=%d LIMIT 1",
            dest,
            GetCarFamily(family_index, CAR_F_database)
        );
        mysql_query(mysql, query, false);
    }

    return 1;
}

stock GetFamilyIDSQL(database)
{
    for(new i; i <MAX_FAM;i++) if(GetFamily(i, family_database) == database) return i;
    return -1;
}

stock ShowDialogFamilySklad(playerid, type, take_or_put = false)
{
    switch(type)
    {
        case 1:
        {
            if(!take_or_put)
            {
                Dialog
                (
                    playerid, 2225, DIALOG_STYLE_LIST,
                    "{FF0000}Взять предмет из склада",
                    "{FFFF00}|{FFFFFF} Деньги\n"\
                    "{FFFF00}|{FFFFFF} Материалы\n"\
                    "{FFFF00}|{FFFFFF} Маски\n"\
                    "{FFFF00}|{FFFFFF} Оружие\n"\
                    "{FFFF00}|{FFFFFF} Бронежилет\n"\
                    "{FFFF00}|{FFFFFF} Аптечка",
                    "Далее", "Назад"
                );
                SetPVarInt(playerid, "type_sklad", 1);
            }else{
                Dialog
                (
                    playerid, 2225, DIALOG_STYLE_LIST,
                    "{FF0000}Положить предмет на склад",
                    "{FFFF00}|{FFFFFF} Деньги\n"\
                    "{FFFF00}|{FFFFFF} Материалы\n"\
                    "{FFFF00}|{FFFFFF} Маски\n"\
                    "{FFFF00}|{FFFFFF} Оружие\n"\
                    "{FFFF00}|{FFFFFF} Бронежилет\n"\
                    "{FFFF00}|{FFFFFF} Аптечка",
                    "Далее", "Назад"
                );
                SetPVarInt(playerid, "type_sklad", 2);
            }
        }
        case 2:
        {
            if(!take_or_put)
            {
                format(f_string144, sizeof f_string144, "Напишите какое количество вы хотите взять (Доступно:%d)", GetFamily(GetPlayerIdFamily(playerid), family_money));
                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_INPUT,
                    "{FF0000}Взять деньги из склада",
                    f_string144,
                    "Взять", "Назад"
                );
            }
            else
            {
                if(!GetPlayerMoneyEx(playerid))
                    return SendClientMessage(playerid, -1, ""c_f_r"У вас нет денег.");

                format(f_string144, sizeof f_string144, "Напишите какое количество вы хотите положить (Доступно:%d)", GetPlayerMoneyEx(playerid));
                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_INPUT,
                    "{FF0000}Положить деньги на склад",
                    f_string144,
                    "Положить", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 2);
        }
        case 3:
        {
            if(!take_or_put)
            {
                format(f_string144, sizeof f_string144, "Напишите какое количество вы хотите взять (Доступно:%d)", GetFamily(GetPlayerIdFamily(playerid), family_material));
                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_INPUT,
                    "{FF0000}Взять материалы из склада",
                    f_string144,
                    "Взять", "Назад"
                );
            }
            else
            {
                if(!GetPlayerData(playerid, P_METALL))
                    return SendClientMessage(playerid, -1, ""c_f_r"У вас нет материалов.");

                format(f_string144, sizeof f_string144, "Напишите какое количество вы хотите положить (Доступно:%d)", GetPlayerData(playerid, P_METALL));
                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_INPUT,
                    "{FF0000}Положить материалы на склад",
                    f_string144,
                    "Положить", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 3);
        }
        case 4:
        {
            if(!take_or_put)
            {
                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Взять маску",
                    "Вы хотите взять маску из склада?",
                    "Взять", "Назад"
                );
            }
            else
            {
                if(!GetPlayerData(playerid, P_MASK))
                    return SendClientMessage(playerid, -1, ""c_f_r"У вас нет маски.");

                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Положить маску",
                    "Вы хотите положить маску на склад?",
                    "Положить", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 4);
        }
        case 5:
        {
            if(!take_or_put)
            {
                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_LIST,
                    "{FF0000}Взять оружие",
                    "Информация\n"\
                    "Взять",
                    "Далее", "Назад"
                );
            }
            else
            {
                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_LIST,
                    "{FF0000}Положить оружие",
                    "Информация\n"\
                    "Положить",
                    "Далее", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 5);
        }
        case 6:
        {
            if(!take_or_put)
            {
                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Взять бронежилет",
                    "Вы хотите взять бронежилет из склада?",
                    "Взять", "Назад"
                );
            }
            else
            {
                new Float:armour;
                
                GetPlayerArmour(playerid, armour);

                if(armour <= 19.9)
                    return SendClientMessage(playerid, -1, ""c_f_r"У вас нет бронежилета или его прочность меньше 20 процентов.");

                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Положить бронежилет",
                    "Вы хотите положить бронежилет на склад?",
                    "Положить", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 6);
        }
        case 7:
        {
            if(!take_or_put)
            {
                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Взять аптечку",
                    "Вы хотите взять аптечку из склада?",
                    "Взять", "Назад"
                );
            }
            else
            {
                if(!GetPlayerData(playerid, P_MED_CHEST))
                    return SendClientMessage(playerid, -1, ""c_f_r"У вас нет аптечки.");

                Dialog
                (
                    playerid, 2226, DIALOG_STYLE_MSGBOX,
                    "{FF0000}Положить аптечку",
                    "Вы хотите положить аптечку на склад?",
                    "Положить", "Назад"
                );
            }
            SetPVarInt(playerid, "select_type_sklad_use", 7);
        }
    }
    return 1;
}

stock UpdateColumnFamilyInt(f, column[], number)
{
	new query[256];

	mysql_format(mysql, query, sizeof query, "UPDATE familynew SET `%s`=%d WHERE `id`=%d LIMIT 1", column, number, f);
	mysql_query(mysql, query, false);
	return 1;
}

stock DialogFamily(playerid, dialogid, style, title[], text[], button[], button2[])
{
  if(style == 5)
  {
     ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, "...", "...", "...", ""); 
  }
  ShowPlayerDialog(playerid, dialogid, style, title, text, button, button2);
  return 1;
}

stock ShowDialogAccess(playerid, type, give)
{
    switch(type)
    {
        case 1:
        {
            if(give)
            {
                Dialog
                (
                    playerid, 2231, DIALOG_STYLE_LIST,
                    "{FF0000}Выдать доступ",
                    "1. Выдать доступ ко всему\n"\
                    "2. Доступ к изменению доступов\n"\
                    "3. Доступ к деньгам\n"\
                    "4. Доступ к материалам\n"\
                    "5. Доступ к маскам\n"\
                    "6. Доступ к аптечкам\n"\
                    "7. Доступ к оружию\n"\
                    "8. Доступ к бронежилетам",
                    "Далее", "Назад"
                );
                SetPVarInt(playerid, "status_dialog_access", 2);
            }
            else
            {
                Dialog
                (
                    playerid, 2231, DIALOG_STYLE_LIST,
                    "{FF0000}Забрать доступ",
                    "1. Забрать доступ ко всему\n"\
                    "2. Доступ к изменению доступов\n"\
                    "3. Доступ к деньгам\n"\
                    "4. Доступ к материалам\n"\
                    "5. Доступ к маскам\n"\
                    "6. Доступ к аптечкам\n"\
                    "7. Доступ к оружию\n"\
                    "8. Доступ к бронежилетам",
                    "Далее", "Назад"
                );
                SetPVarInt(playerid, "status_dialog_access", 1);
            }
        }
        case 3:
        {
            Dialog
            (
                playerid, 2231, DIALOG_STYLE_INPUT,
                "Настройка доступа",
                "Введите имя или ID игрока для редактирования доступа",
                "Далее",
                "Назад"
            );

            SetPVarInt(playerid, "type_dialog_access", type);
        }
        case 2,4..10:
        {
            if(give)
            {
                Dialog
                (
                    playerid, 2231, DIALOG_STYLE_INPUT,
                    "Настройка доступа",
                    "Введите имя или ID игрока и количество через запятую\n"\
                    "- Количество - это сколько игрок сможет взять того или иного предмета.\n"\
                    "- Пример: Welsi_Developer, 1000",
                    "Далее",
                    "Назад"
                );
            }else{
                Dialog
                (
                    playerid, 2231, DIALOG_STYLE_INPUT,
                    "Настройка доступа",
                    "Введите имя или ID игрока для редактирования доступа",
                    "Далее",
                    "Назад"
                );
            }

            SetPVarInt(playerid, "type_dialog_access", type);
        }
    }
}



stock UpdateDostupFamily(fam, rang)
{
    new setting[38];
    format(setting, sizeof setting, "%s,%d,%d,%d,%d,%d", family_rang_name[fam][rang], family_rang_dostup[fam][rang][0], 
    family_rang_dostup[fam][rang][1], family_rang_dostup[fam][rang][2], family_rang_dostup[fam][rang][3], 
    family_rang_dostup[fam][rang][4]);

    new rang_sql_name[5][7] = {"rang_1","rang_2", "rang_3", "rang_4", "rang_5"};

    mysql_format(mysql, f_string184, sizeof f_string184, "UPDATE familynew SET %s = '%s' WHERE id=%d", rang_sql_name[rang], setting, GetFamily(fam, family_database));
    mysql_query(mysql, f_string184, false);

    return 1;
} 

stock UpdateAccessPlayerFamily(playerid)
{
    new setting[30];
    format(setting, sizeof setting, "%d,%d,%d,%d,%d,%d,%d", GetPlayerFamily(playerid, ACCESS_GIVE),  GetPlayerFamily(playerid, ACCESS_MONEY), 
    GetPlayerFamily(playerid, ACCESS_ARMOUR),  GetPlayerFamily(playerid, ACCESS_MATERIAL),  GetPlayerFamily(playerid, ACCESS_HEATH_KIT), 
    GetPlayerFamily(playerid, ACCESS_PATRON),  GetPlayerFamily(playerid, ACCESS_MASK));

    mysql_format(mysql, f_string184, sizeof f_string184, "UPDATE accounts SET family_access = '%s' WHERE id=%d", setting, GetPlayerAccountID(playerid));
    mysql_query(mysql, f_string184, false);

    return 1;   
}

//FAMILY Commands

CMD:familymenuinternal(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не состоите в семье.", " ");

    Dialog
    (
        playerid, 2220, DIALOG_STYLE_LIST,
        "{FF0000}Панель семьи",
        "1. Объявления\n"\
        "2. Информация\n"\
        "3. Настройки семьи\n"\
        "4. Управление семьей\n"\
        "5. Склад\n"\
        "6. Автопарк\n"\
        "7. Улучшения\n"\
        "8. Рейтинг семей\n"\
        "9. Семейные логи\n"\
        "{FFFF00}10. Покинуть семью",
        "Далее", "Назад"
    );

    return 1;
}

alias:famsklad("fs", "fsklad")
CMD:famsklad(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не состоите в семье.", " ");

    return FamilyStorageShowMainDialog(playerid);
}

CMD:fam(playerid, params[])
{
    if(GetPlayerIdFamily(playerid) == -1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не состоите в семье.", " ");

    if(!strlen(params))
        return SendClientMessage(playerid, 0xFFFFFFFF, "{FFFF00}{FFFFFF}Используйте: /fam [Текст]");

    if(GetPlayerFamily(playerid, MUTE_FAMILY) > 0)
        return SendClientMessage(playerid, -1, ""c_f_r"У вас мут в семейном чате.");

    new message[254];
    format(message, sizeof message, "%s %s[%d]: %s", family_rang_name[GetPlayerIdFamily(playerid)][GetPlayerFamily(playerid, RANG_FAMILY)-1], GetPlayerNameEx(playerid), playerid, params);
    SendFamilyMessage(GetPlayerIdFamily(playerid), message);
    return 1;
}

CMD:fammute(playerid, params[])
{
    new f = GetPlayerIdFamily(playerid);

    if(f == -1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не состоите в семье.", " ");

    if(!strlen(params))
    {
        Dialog
        (
            playerid, 2236, DIALOG_STYLE_INPUT,
            "{FF0000}Выдача мута",
            "{FFFFFF}Выдача мута, введите ID игрока, время, причину через запятую.\n\n"\
            "{FFFF00}Например{FFFFFF}: 0, 30, Неадекват",
            "Выдать", "Отмена"
        );
        SetPVarInt(playerid, "select_type_2236", 3);
        return 1;
    }

    new to_player, count, prichina[32];
    if(sscanf(params, "dds[32]", to_player, count, prichina))
        return SendClientMessage(playerid, -1, ""c_f_r"/fammute [ID игрока] [Минуты] [Причина]");

    if(GetPlayerIdFamily(to_player) != f)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрок не состоит в вашей семье.");

    if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][3])
        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу недоступно выдавать муты.");

    if(!IsPlayerConnected(to_player) || to_player == playerid)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрока нет в сети.");

    if(GetPlayerRangFamily(to_player) >= GetPlayerRangFamily(playerid))
        return SendClientMessage(playerid, -1, ""c_f_r"Игрок такого же ранга или выше.");

    if(GetPlayerFamily(to_player, MUTE_FAMILY) >= 1)
        return SendClientMessage(playerid, -1, ""c_f_r"У игрока уже есть мут");

    if(count > 180 || !count)
        return SendClientMessage(playerid, -1, ""c_f_r"Количество мута не должно превышать 180 минут.");

    SetPlayerFamily(to_player, MUTE_FAMILY, 60 * count);

    format(f_string144, sizeof f_string144, "%s выдал мут %s на %d минут. Причина: %s", GetPlayerNameEx(playerid), GetPlayerNameEx(to_player), count, prichina);
    SendFamilyMessage(f, f_string144);

    return 1;
}

CMD:unfammute(playerid, params[])
{
    new f = GetPlayerIdFamily(playerid);

    if(f == -1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не состоите в семье.", " ");

    if(!strlen(params))
    {
        Dialog
        (
            playerid, 2236, DIALOG_STYLE_INPUT,
            "{FF0000}Снятие мута",
            "Снятие мута, введите {FFFF00}ID{FFFFFF} игрока для снятие молчанки",
            "Выдать", "Отмена"
        );
        SetPVarInt(playerid, "select_type_2236", 7);
        return 1;
    }

    new to_player;
    if(sscanf(params, "d", to_player))
        return SendClientMessage(playerid, -1, ""c_f_r"/unfammute [ID игрока]");

    if(GetPlayerIdFamily(to_player) != f)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрок не состоит в вашей семье.");

    if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][3])
        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу недоступно снимать муты.");

    if(!IsPlayerConnected(to_player) || to_player == playerid)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрока нет в сети.");

    if(GetPlayerRangFamily(to_player) >= GetPlayerRangFamily(playerid))
        return SendClientMessage(playerid, -1, ""c_f_r"Игрок такого же ранга или выше.");

    if(GetPlayerFamily(to_player, MUTE_FAMILY) == 0)
        return SendClientMessage(playerid, -1, ""c_f_r"У игрока нет мута");

    SetPlayerFamily(to_player, MUTE_FAMILY, 0);

    format(f_string144, sizeof f_string144, "%s снял мут %s", GetPlayerNameEx(playerid), GetPlayerNameEx(to_player));
    SendFamilyMessage(f, f_string144);

    return 1;
}

CMD:faminvite(playerid, params[])
{
    new f = GetPlayerIdFamily(playerid);

    if(f == -1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не состоите в семье!", " ");

    if(!strlen(params))
    {
        Dialog
        (
            playerid, 2236, DIALOG_STYLE_INPUT,
            "{FF0000}Приглашение в семью",
            "{FFFFFF}Приглашение в семью, введите {FFFF00}ID{FFFFFF} игрока",
            "Пригласить", "Отмена"
        );
        SetPVarInt(playerid, "select_type_2236", 1);
        return 1;
    }

    new to_player;
    if(sscanf(params, "d", to_player))
        return SendClientMessage(playerid, -1, ""c_f_r"/faminvite [ID игрока]");

    if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][0])
        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу недоступно принимать игроков.");

    if(!IsPlayerConnected(to_player) || to_player == playerid)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрока нет в сети.");

    if(GetPlayerIdFamily(to_player) != -1)
        return SendClientMessage(playerid, -1, ""c_f_r"У игрока уже есть семья.");


    if(FamilyGuiIsBlacklisted(GetPlayerFamily(playerid, ID_SQL_FAMILY), GetPlayerAccountID(to_player)))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Данный игрок находится в черном списке Вашей семьи.", " ");
    if(GetFamily(f, family_count_people) + 1 > count_compound_level[GetFamily(f, family_lvl_compound)-1])
        return SendClientMessage(playerid, -1, ""c_f_r"Состав семьи полон.");

    if(GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(to_player) || GetPlayerInterior(playerid) != GetPlayerInterior(to_player))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Вы слишком далеко от игрока", " ");

    if(!IsPlayerInRangeOfPlayer(playerid, to_player, 5.0))
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Вы слишком далеко от игрока", " ");

    format(f_string144, sizeof f_string144, "%s предлагает Вам вступить в семью", GetPlayerNameEx(playerid));
    SendClientMessage(to_player, 0x6DCFF6FF, f_string144);

    format(f_string144, sizeof f_string144, "Вы отправили приглашение %s для вступление в Вашу семью.", GetPlayerNameEx(to_player));
    SendClientMessage(playerid, 0x6DCFF6FF, f_string144);

    format(f_string144, sizeof f_string144, "Предложение от %s", GetPlayerNameEx(playerid));
    ShowNotificationNew(to_player, 4, 6, playerid, 0, f_string144, ">>");

    SetPVarInt(to_player, "invite_player", playerid);

    return 1;
}

CMD:unfaminvite(playerid, params[])
{
    new f = GetPlayerIdFamily(playerid);

    if(f == -1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не состоите в семье.", " ");

    if(!strlen(params))
    {
        Dialog
        (
            playerid, 2236, DIALOG_STYLE_INPUT,
            "{FF0000}Изгнание из семьи",
            "Изгнание из семьи, введите {FFFF00}ID{FFFFFF} игрока и через запятую причину\n\n"\
            "{FFFF00}Например{FFFFFF}: 0, По С/Ж",
            "Изгнать", "Отмена"
        );
        SetPVarInt(playerid, "select_type_2236", 6);
        return 1;
    }

    new to_player, prichinaept[32];
    if(sscanf(params, "ds[32]", to_player, prichinaept))
        return SendClientMessage(playerid, -1, ""c_f_r"/unfaminvite [ID игрока] [Причина]");

    if(!family_rang_dostup[f][GetPlayerRangFamily(playerid)-1][1] && GetPlayerRangFamily(playerid) != 5)
        return SendClientMessage(playerid, -1, ""c_f_r"Вашему рангу недоступно выгонять игроков.");

    if(!IsPlayerConnected(to_player) || to_player == playerid)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрока нет в сети.");

    if(GetPlayerIdFamily(to_player) != f)
        return SendClientMessage(playerid, -1, ""c_f_r"Игрок не из вашей семьи.");

    SetPlayerFamily(to_player, ID_FAMILY, -1);
    SetPlayerFamily(to_player, ID_SQL_FAMILY, -1);

    DestroyDynamic3DTextLabel(GetPlayerFamily(to_player, TEXT_FAMILY));
    SetPlayerFamily(to_player, TEXT_FAMILY, STREAMER_TAG_3D_TEXT_LABEL:-1);

    SetPlayerFamily(to_player, RANG_FAMILY, 0);
    SetPlayerFamily(to_player, MUTE_FAMILY, 0);

    SetPlayerFamily(to_player, ACCESS_GIVE, 0);
    SetPlayerFamily(to_player, ACCESS_MONEY, 0);
    SetPlayerFamily(to_player, ACCESS_ARMOUR, 0);
    SetPlayerFamily(to_player, ACCESS_MATERIAL, 0);
    SetPlayerFamily(to_player, ACCESS_HEATH_KIT, 0);
    SetPlayerFamily(to_player, ACCESS_PATRON, 0);
    SetPlayerFamily(to_player, ACCESS_MASK, 0);

    UpdatePlayerDatabaseInt(to_player, "family_id", GetPlayerFamily(to_player, ID_FAMILY));
    UpdatePlayerDatabaseInt(to_player, "family_rang", GetPlayerFamily(to_player, RANG_FAMILY));
    UpdatePlayerDatabaseInt(to_player, "family_mute", GetPlayerFamily(to_player, MUTE_FAMILY));
    UpdateAccessPlayerFamily(to_player);
    AddFamily(f, family_count_people, -, 1);

    format(f_string144, sizeof f_string144, "%s выгнал из семьи %s. Причина:%s", GetPlayerNameEx(playerid), GetPlayerNameEx(to_player), prichinaept);
    SendFamilyLog(type_log_kick, playerid, to_player, f_string144);
    SendFamilyMessage(f, f_string144);

    return 1;
}


CMD:familybuy(playerid)
{
    if(GetPlayerIdFamily(playerid) != -1)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Вы уже состоите в семье.", " ");

    if(GetPlayerMoneyEx(playerid) < 3_000_000)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Для создания семьи у Вас должно быть 3.000.000 рублей.", " ");

    Dialog
    (
        playerid, 2238, DIALOG_STYLE_INPUT,
        "{FF0000}Создание семьи",
        "{FFFFFF}Здесь Вы можете создать свою семью.\n"\
        "Цена: {FFFF00}3.000.000 рублей.\n\n"\
        "{FFFFFF}Напишите название Вашей будущей семьи:",
        "Далее", "Выйти"
    );
}

stock SendFamilyLog(type, playerid, to_player = -1, text[])
{
    new string[324], sql;

    if(to_player != -1) sql = GetPlayerAccountID(to_player);
    else sql = -1;

    mysql_format(mysql, string, sizeof string, "INSERT INTO family_log (family,player,to_player,text,time,type) VALUES (%d,%d,%d,'%s',%d,%d)", GetPlayerFamily(playerid, ID_SQL_FAMILY), GetPlayerAccountID(playerid),
    sql, text, gettime()+10800, type);
    mysql_query(mysql, string, false);

    if(mysql_errno()) return printf("error insert family_log");

    return 1;
}

stock FamilyGuiBuildLogWhere(log_menu_id, dest[], size = sizeof dest)
{
    switch(log_menu_id)
    {
        case 1: format(dest, size, "type = %d", type_log_invite);
        case 2: format(dest, size, "type = %d", type_log_kick);
        case 3: format(dest, size, "type = %d", type_log_money);
        case 4: format(dest, size, "type = %d", type_log_material);
        case 5: format(dest, size, "type = %d", type_log_mask);
        case 6: format(dest, size, "type = %d", type_log_heath_kit);
        case 7: format(dest, size, "type = %d", type_log_patron);
        case 8: format(dest, size, "type = %d", type_log_armour);
        case 9: format(dest, size, "(type = %d OR text LIKE '%% загрузил %%' OR text LIKE '%% выгрузил %%' OR text LIKE '%% удалил из семьи автомобиль %%')", type_log_car);
        case 10: format(dest, size, "type IN (%d,%d)", type_log_rang, type_log_dostup);
        case 11: format(dest, size, "type IN (%d,%d,%d,%d,%d,%d)", type_log_money, type_log_material, type_log_mask, type_log_heath_kit, type_log_patron, type_log_armour);
        default: format(dest, size, "type = -1");
    }
    return 1;
}

stock FamilyGuiShowLogsMenu(playerid)
{
    new dialog_text[2048];
    dialog_text[0] = EOS;

    strcat(dialog_text, "{E0584B}номер\t{E0584B}наименование лога\t{E0584B}доступное действие\n");
    for(new i; i < sizeof FAMILY_GUI_LOG_MENU_NAMES; i++)
    {
        format(f_string144, sizeof f_string144, "{E0584B}#%d\t{FFFFFF}%s\t{ACADAF}нажмите для просмотра\n", i + 1, FAMILY_GUI_LOG_MENU_NAMES[i]);
        strcat(dialog_text, f_string144);
    }

    Dialog(
        playerid,
        DIALOG_FAMILY_GUI_LOG_MENU,
        DIALOG_STYLE_TABLIST_HEADERS,
        "{E0584B}BR BONUS | {FFFFFF}Выберите лог",
        dialog_text,
        "Выбрать",
        "Назад"
    );
    return 1;
}

stock FamilyGuiTrimLeadingSpaces(text[])
{
    while(text[0] == ' ' || text[0] == '\t')
    {
        strdel(text, 0, 1);
    }
    return 1;
}

stock FamilyGuiUppercaseFirst(text[])
{
    if(!text[0]) return 1;

    if('a' <= text[0] <= 'z')
        text[0] -= 32;
    else if('?' <= text[0] <= '?')
        text[0] -= ('?' - '?');

    return 1;
}

stock FamilyGuiFormatLogContent(log_menu_id, actor_name[], source_text[], dest[], size = sizeof dest)
{
    format(dest, size, "%s", source_text);

    new actor_pos = strfind(dest, actor_name, true);
    if(actor_name[0] && actor_pos != -1 && actor_pos <= 32)
    {
        new skip_pos = actor_pos + strlen(actor_name);

        if(dest[skip_pos] == '[')
        {
            while(dest[skip_pos] && dest[skip_pos] != ']') skip_pos++;
            if(dest[skip_pos] == ']') skip_pos++;
        }

        strdel(dest, 0, skip_pos);
        FamilyGuiTrimLeadingSpaces(dest);
    }

    if(log_menu_id == 9)
    {
        if(strfind(dest, "загрузил автомобиль ", true) == 0)
        {
            format(dest, size, "Загрузил автомобиль: %s", dest[20]);
        }
        else if(strfind(dest, "загрузил ", true) == 0)
        {
            format(dest, size, "Загрузил автомобиль: %s", dest[9]);
        }
        else if(strfind(dest, "выгрузил транспорт ", true) == 0)
        {
            format(dest, size, "Выгрузил транспорт: %s", dest[19]);
        }
        else if(strfind(dest, "удалил из семьи автомобиль ", true) == 0)
        {
            format(dest, size, "Удалил авто из семьи: %s", dest[26]);
        }
    }

    new len = strlen(dest);
    while(len > 0 && (dest[len - 1] == '.' || dest[len - 1] == ' '))
    {
        dest[len - 1] = EOS;
        len--;
    }

    FamilyGuiUppercaseFirst(dest);
    return 1;
}

stock FamilyGuiShowLogList(playerid, log_menu_id, page)
{
    if(log_menu_id < 1 || log_menu_id > sizeof FAMILY_GUI_LOG_MENU_NAMES)
        return FamilyGuiShowLogsMenu(playerid);

    if(page < 0) page = 0;

    new family_sql_id = GetPlayerFamily(playerid, ID_SQL_FAMILY);
    if(family_sql_id == -1)
        family_sql_id = GetFamily(GetPlayerIdFamily(playerid), family_database);
    if(family_sql_id == -1)
        return 1;

    new where_clause[128];
    new count_query[256];
    new list_query[512];
    FamilyGuiBuildLogWhere(log_menu_id, where_clause, sizeof where_clause);
    printf("[FAMILY_LOGS][OPEN] player=%d family_id=%d menu=%d page=%d where=%s", playerid, family_sql_id, log_menu_id, page, where_clause);

    mysql_format(mysql, count_query, sizeof count_query, "SELECT COUNT(*) AS cnt FROM family_log WHERE family = %d AND %s", family_sql_id, where_clause);
    printf("[FAMILY_LOGS][COUNT_QUERY] %s", count_query);
    new Cache:count_cache = mysql_query(mysql, count_query, true);
    new total_rows = cache_num_rows() ? cache_get_field_content_int(0, "cnt") : 0;
    printf("[FAMILY_LOGS][COUNT_RESULT] player=%d family_id=%d menu=%d rows=%d errno=%d", playerid, family_sql_id, log_menu_id, total_rows, mysql_errno());
    cache_delete(count_cache);

    if(!total_rows)
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Логи не найдены.", " ");

    new offset = page * FAMILY_GUI_LOGS_PER_PAGE;
    if(offset >= total_rows)
    {
        if(page > 0)
            return ShowNotificationNew(playerid, 2, 6, 0, 0, "Логи не найдены.", " ");
        offset = 0;
    }

    mysql_format(mysql, list_query, sizeof list_query, "SELECT fl.player, fl.text, fl.time, IFNULL(a.name, 'Unknown') AS player_name FROM family_log fl LEFT JOIN accounts a ON a.id = fl.player WHERE fl.family = %d AND %s ORDER BY fl.time DESC LIMIT %d, %d", family_sql_id, where_clause, offset, FAMILY_GUI_LOGS_PER_PAGE);
    printf("[FAMILY_LOGS][LIST_QUERY] %s", list_query);
    new Cache:cache = mysql_query(mysql, list_query, true);
    new rows = cache_num_rows();
    printf("[FAMILY_LOGS][LIST_RESULT] player=%d family_id=%d menu=%d page=%d offset=%d rows=%d errno=%d", playerid, family_sql_id, log_menu_id, page, offset, rows, mysql_errno());

    if(!rows)
    {
        cache_delete(cache);
        return ShowNotificationNew(playerid, 2, 6, 0, 0, "Логи не найдены.", " ");
    }

    new dialog_text[4096];
    new player_name[32];
    new log_text[220];
    new log_content[220];
    new time_data[24];
    dialog_text[0] = EOS;

    strcat(dialog_text, "{E0584B}номер\t{E0584B}никнейм\t{E0584B}содержимое\t{E0584B}отметка времени\n");

    for(new i, time_value; i < rows; i++)
    {
        time_value = cache_get_field_content_int(i, "time");
        cache_get_field_content(i, "player_name", player_name, mysql, sizeof player_name);
        cache_get_field_content(i, "text", log_text, mysql, sizeof log_text);
        printf("[FAMILY_LOGS][ROW] idx=%d player_name=%s time=%d text=%s", i, player_name, time_value, log_text);
        FamilyGuiFormatLogContent(log_menu_id, player_name, log_text, log_content, sizeof log_content);
        printf("[FAMILY_LOGS][ROW_FORMATTED] idx=%d content=%s", i, log_content);

        format(time_data, sizeof time_data, "%02d.%02d.%d - %02d:%02d:%02d",
            ConvertUnixTime(time_value, CONVERT_TIME_TO_DAYS),
            ConvertUnixTime(time_value, CONVERT_TIME_TO_MONTHS),
            ConvertUnixTime(time_value, CONVERT_TIME_TO_YEARS),
            ConvertUnixTime(time_value, CONVERT_TIME_TO_HOURS),
            ConvertUnixTime(time_value, CONVERT_TIME_TO_MINUTES),
            ConvertUnixTime(time_value, CONVERT_TIME_TO_SECONDS));

        format(f_string184, sizeof f_string184, "{E0584B}#%d\t{FFFFFF}%s\t{FFFFFF}%s\t{E0584B}%s\n", offset + i + 1, player_name, log_content, time_data);
        strcat(dialog_text, f_string184);
    }

    new has_next = (offset + rows) < total_rows;
    new has_prev = page > 0;

    if(has_next)
        strcat(dialog_text, "{E0584B}#>\t{FFFFFF}Следующая страница\t{ACADAF}нажмите для просмотра\t{E0584B}-\n");
    if(has_prev)
        strcat(dialog_text, "{E0584B}#<\t{FFFFFF}Предыдущая страница\t{ACADAF}нажмите для просмотра\t{E0584B}-\n");

    SetPVarInt(playerid, "family_gui_log_menu", log_menu_id);
    SetPVarInt(playerid, "family_gui_log_page", page);
    SetPVarInt(playerid, "family_gui_log_row_count", rows);
    SetPVarInt(playerid, "family_gui_log_has_next", has_next);
    SetPVarInt(playerid, "family_gui_log_has_prev", has_prev);

    format(f_string144, sizeof f_string144, "{E0584B}BR BONUS {FFFFFF}| Логирование семьи (стр. %d)", page + 1);
    Dialog(
        playerid,
        DIALOG_FAMILY_GUI_LOG_LIST,
        DIALOG_STYLE_TABLIST_HEADERS,
        f_string144,
        dialog_text,
        "Выбрать",
        "Назад"
    );

    cache_delete(cache);
    return 1;
}

cmd:info(playerid)
{
    new f = GetPlayerIdFamily(playerid), string[424];

    format
    (
        string, sizeof string,
        "id =%d owner=%d color =%d count_veh=%d\n"\
        "reputation=%d zaxvati=%d name=%s patron=%d heath_kit=%d\n"\
        "money=%d material=%d lvl_storage=%d lvl_weapon=%d lvl_weapon=%d\n"\
        "rang_1: name = %s d_1 =%d d_2 =%d d_3 =%d d_4 =%d d_5 =%d\n"\
        "rang_2: name = %s d_1 =%d d_2 =%d d_3 =%d d_4 =%d d_5 =%d\n"\
        "rang_3: name = %s d_1 =%d d_2 =%d d_3 =%d d_4 =%d d_5 =%d\n"\
        "rang_4: name = %s d_1 =%d d_2 =%d d_3 =%d d_4 =%d d_5 =%d\n"\
        "rang_5: name = %s d_1 =%d d_2 =%d d_3 =%d d_4 =%d d_5 =%d\n"\
        "count_people=%d",
        GetFamily(f, family_database), GetFamily(f, family_owner),  GetFamily(f, family_color), GetFamily(f, family_count_veh),
        GetFamily(f, family_reputation),GetFamily(f, family_zaxvati),GetFamily(f, family_name),GetFamily(f, family_patron),GetFamily(f, family_heath_kit),
        GetFamily(f, family_money),GetFamily(f, family_material),GetFamily(f, family_lvl_storage), GetFamily(f, family_lvl_weapon), GetFamily(f, family_lvl_compound),
        family_rang_name[f][0], family_rang_dostup[f][0][0],  family_rang_dostup[f][0][1],  family_rang_dostup[f][0][2],  family_rang_dostup[f][0][3],  family_rang_dostup[f][0][4],
        family_rang_name[f][1], family_rang_dostup[f][1][0],  family_rang_dostup[f][1][1],  family_rang_dostup[f][1][2],  family_rang_dostup[f][1][3],  family_rang_dostup[f][1][4],
        family_rang_name[f][2], family_rang_dostup[f][2][0],  family_rang_dostup[f][2][1],  family_rang_dostup[f][2][2],  family_rang_dostup[f][2][3],  family_rang_dostup[f][2][4],
        family_rang_name[f][3], family_rang_dostup[f][3][0],  family_rang_dostup[f][3][1],  family_rang_dostup[f][3][2],  family_rang_dostup[f][3][3],  family_rang_dostup[f][3][4],
        family_rang_name[f][4], family_rang_dostup[f][4][0],  family_rang_dostup[f][4][1],  family_rang_dostup[f][4][2],  family_rang_dostup[f][4][3],  family_rang_dostup[f][4][4],
        GetFamily(f, family_count_people)
    );

    ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, "", string, "welsi", "");
    return 1;
}

stock ShowMembersFamily(playerid, listitem)
{
    new list = GetPVarInt(playerid, "count_list");

    if(listitem == 0)  list++;
    else if(listitem == 1 && list != 1) list--;
    SetPVarInt(playerid, "count_list", list);

    new Cache: result;

    mysql_format(mysql, f_string144, sizeof f_string144, "SELECT * FROM accounts WHERE family_id = %d", GetFamily(GetPlayerIdFamily(playerid), family_database));
    result = mysql_query(mysql, f_string144, true);
    if(mysql_errno()) return SendClientMessage(playerid, -1, "error");

    new rows = cache_num_rows();
    
    new count_rows, count = 10 * GetPVarInt(playerid, "count_list");

    if(rows >= count) count_rows = count;
    else count_rows = rows;

    new d_list[86], dialog[4096] = "Следующая страница\nПредыдущая страница\n", family_rang, bool:online, id, name[24], last_login, data[54];
    
    for(new i = count-10, da = 2; i < count_rows;i++, da++)
    {
        online = false;
        id = cache_get_field_content_int(i, "id");
        cache_get_field_content(i, "name", name, mysql, 24);
        last_login = cache_get_field_content_int(i, "last_login");
        family_rang = cache_get_field_content_int(i, "family_rang");

        format(f_string32, sizeof f_string32, "p_familyrang%d", da);
        SetPVarInt(playerid, f_string32, family_rang);
        format(f_string32, sizeof f_string32, "p_familyname%d", da);
        SetPVarString(playerid, f_string32, name);

        foreach(new yo : Player)
        {
            if(GetPlayerAccountID(yo) != id) continue;
            online = true;
            break;
        }

        if(!online)
        {
            format(data, sizeof data, "%02d.%02d.%d %02d:%02d:%02d", ConvertUnixTime(last_login, CONVERT_TIME_TO_DAYS), ConvertUnixTime(last_login, CONVERT_TIME_TO_MONTHS),
            ConvertUnixTime(last_login, CONVERT_TIME_TO_YEARS), ConvertUnixTime(last_login, CONVERT_TIME_TO_HOURS), ConvertUnixTime(last_login, CONVERT_TIME_TO_MINUTES), ConvertUnixTime(last_login, CONVERT_TIME_TO_SECONDS));
        }
        else format(data, sizeof data, "{00FF00}Онлайн{FFFFFF}");

        format(d_list, sizeof d_list, "%s %s\n", name, data);
        strcat(dialog, d_list);
        SetPlayerListitemValue(playerid, da, id);
    }


    Dialog
    (
        playerid, 2236, DIALOG_STYLE_LIST,
        "{FF0000}Выберите кого выгнать",
        dialog,
        "Выбрать", "Закрыть"
    );
    SetPVarInt(playerid, "prichina", 0);
    SetPVarInt(playerid, "select_type_2236", 2);
    cache_delete(result);
    return 1;
}

stock GetVehicleDriver(vehicleid)
{
    foreach(new i : Player)
    {
        if(GetPlayerVehicleID(i) == vehicleid) return i;
    }
    return INVALID_PLAYER_ID;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    if(GetVehicleData(vehicleid, V_ACTION_TYPE) == VEHICLE_ACTION_TYPE_FAMILY_CAR){
        new id = GetVehicleData(vehicleid, V_ACTION_ID);

        if(GetPlayerIdFamily(playerid) != GetCarFamily(id, OW_F_server))
        {
            ClearAnimations(playerid);
            return SendClientMessage(playerid, -1, ""c_f_r"Это семейная машина.");
        }
        else if(GetPlayerRangFamily(playerid) < GetCarFamily(id, V_F_RANG))
        {
            ClearAnimations(playerid);
            return SendClientMessage(playerid, -1, ""c_f_r"Ваш ранг меньше доступного ранга для этого транспорта.");
        }
    }
    #if defined fam_OnPlayerEnterVehicle
        return fam_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnPlayerEnterVehicle
    #undef OnPlayerEnterVehicle
#else
    #define _ALS_OnPlayerEnterVehicle
#endif
#define OnPlayerEnterVehicle fam_OnPlayerEnterVehicle
#if defined fam_OnPlayerEnterVehicle
    forward fam_OnPlayerEnterVehicle(playerid, vehicleid, ispassenger);
#endif

cmd:fhelp(playerid)
{
    Dialog
    (
        playerid, -1, DIALOG_STYLE_MSGBOX,
        "{FF0000}Список комманд семьи",
        "{FFFFFF}/familybuy - {FFB700}покупка семьи\n"\
        "{FFFFFF}/fam - {FFB700}написать в чат семьи\n"\
        "{FFFFFF}/famsklad - {FFB700}склад семьи\n"\
        "{FFFFFF}/exchangefam - {FFB700}передать полномочия семьи\n"\
        "{FFFFFF}/buyslotfam - {FFB700}купить слот на т/с в семью\n"\
        "{FFFFFF}/buynamefam - {FFB700}изменить название семьи\n"\
        "{FFFFFF}/fm (/fammenu) - {FFB700}меню семьи\n"\
        "{FFFFFF}/faminvite - {FFB700} принять в семью\n"\
        "{FFFFFF}/loadfamily - {FFB700}начать загрузку ящиков\n"\
        "{FFFFFF}/unfaminvite - {FFB700}выгнать из семьи\n"\
        "{FFFFFF}/fammute - {FFB700}выдать мут в семейном чате\n"\
        "{FFFFFF}/unfammute - {FFB700}снять мут в семейном чатек",
        "??", ""
    );
}

cmd:buyslotfam(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1)
        return ShowNotificationNew(playerid, 2, 5, 0, 0, "Вы не состоите в семье.", " ");

    Dialog
    (
        playerid, 2240, DIALOG_STYLE_MSGBOX,
        "{FF0000}Покупка слота т/с для семьи",
        "Вы действительно хотите купить слот для транспорта\n"\
        "в вашу семью? Стоимость слота - {FFFF00}300 донат-руб.",
        "Далее", "Выйти"
    );
    return 1;
}

cmd:exchangefam(playerid)
{
    if(GetPlayerIdFamily(playerid) == -1 || GetPlayerRangFamily(playerid) != 5)
        return SendClientMessage(playerid, -1, ""c_f_r"Вы не являетесь лидером семьи");

    Dialog
    (
        playerid, 2241, DIALOG_STYLE_INPUT,
        "{FF0000}Изменить владельца семьи",
        "Введите ID-игрока которому Вы хотите передать полномочие своей семьи:\n\n"\
        "Стоимость: {FFFF00} 100 донат-руб.",
        "Далее", "Выйти"
    );
    return 1;
}


stock ExitFromFamily(playerid)
{
    new f = GetPlayerIdFamily(playerid);

    AddFamily(f, family_count_people, -, 1);

    SetPlayerFamily(playerid, ID_FAMILY, -1);
    SetPlayerFamily(playerid, ID_SQL_FAMILY, -1);
    
    DestroyDynamic3DTextLabel(GetPlayerFamily(playerid, TEXT_FAMILY));
    SetPlayerFamily(playerid, TEXT_FAMILY, STREAMER_TAG_3D_TEXT_LABEL:-1);

    SetPlayerFamily(playerid, RANG_FAMILY, 0);
    SetPlayerFamily(playerid, MUTE_FAMILY, 0);
    SetPlayerFamily(playerid, VIG_FAMILY, 0);

    SetPlayerFamily(playerid, ACCESS_GIVE, 0);
    SetPlayerFamily(playerid, ACCESS_MONEY, 0);
    SetPlayerFamily(playerid, ACCESS_ARMOUR, 0);
    SetPlayerFamily(playerid, ACCESS_MATERIAL, 0);
    SetPlayerFamily(playerid, ACCESS_HEATH_KIT, 0);
    SetPlayerFamily(playerid, ACCESS_PATRON, 0);
    SetPlayerFamily(playerid, ACCESS_MASK, 0);

    mysql_format(mysql, f_string144, sizeof f_string144, "UPDATE accounts SET family_id=%d, family_rang=%d, family_mute=%d, family_vig=%d WHERE id = %d", 
    GetPlayerFamily(playerid, ID_SQL_FAMILY), GetPlayerRangFamily(playerid), GetPlayerFamily(playerid, MUTE_FAMILY), GetPlayerFamily(playerid, VIG_FAMILY), GetPlayerAccountID(playerid));
    mysql_query(mysql, f_string144, false);
    if(mysql_errno()) return printf("ERROR SQL (%s)", f_string144);
    UpdateAccessPlayerFamily(playerid);

    return 1;
}

stock bool:FamilyDeclineInvite(playerid, inviter)
{
    if(GetPVarType(playerid, "invite_player"))
        DeletePVar(playerid, "invite_player");

    if(IsPlayerConnected(inviter))
        SendClientMessage(inviter, -1, ""c_f"Игрок отказался от вашего предложения.");

    SendClientMessage(playerid, -1, ""c_f"Вы отказались от предложения.");
    return true;
}

stock bool:FamilyAcceptInvite(playerid, inviter)
{
    if(GetPVarType(playerid, "invite_player"))
        DeletePVar(playerid, "invite_player");

    if(inviter < 0 || inviter >= MAX_PLAYERS || !IsPlayerConnected(inviter) || !IsPlayerLogged(inviter))
    {
        SendClientMessage(playerid, -1, ""c_f_r"Игрок недоступен.");
        return true;
    }

    if(GetPlayerIdFamily(playerid) != -1)
    {
        SendClientMessage(playerid, -1, ""c_f_r"Вы уже состоите в семье.");
        return true;
    }

    new fff = GetPlayerIdFamily(inviter);
    if(fff == -1)
    {
        SendClientMessage(playerid, -1, ""c_f_r"Семья больше не существует.");
        return true;
    }

    if(GetFamily(fff, family_count_people) + 1 > count_compound_level[GetFamily(fff, family_lvl_compound)-1])
    {
        SendClientMessage(playerid, -1, ""c_f_r"Состав семьи полон.");
        return true;
    }

    if(FamilyGuiIsBlacklisted(GetPlayerFamily(inviter, ID_SQL_FAMILY), GetPlayerAccountID(playerid)))
    {
        ShowNotificationNew(inviter, 2, 6, 0, 0, "Данный игрок находится в черном списке Вашей семьи.", " ");
        SendClientMessage(playerid, -1, ""c_f_r"Семья не может принять вас в данный момент.");
        return true;
    }

    UpdatePlayerDatabaseInt(playerid, "family_id", GetPlayerFamily(inviter, ID_SQL_FAMILY));
    UpdatePlayerDatabaseInt(playerid, "family_rang", 1);
    UpdatePlayerDatabaseInt(playerid, "family_mute", 0);
    UpdatePlayerDatabaseInt(playerid, "family_vig", 0);

    LoadPlayerFamily(playerid);
    format(f_string144, sizeof f_string144, "%s[%d] пригласил игрока %s[%d] в семью", GetPlayerNameEx(inviter), inviter, GetPlayerNameEx(playerid), playerid);
    SendFamilyMessage(fff, f_string144);
    SendFamilyLog(type_log_invite, playerid, inviter, f_string144);
    return true;
}

stock bool:FamilyHandleInviteNotification(playerid, notify_type, notify_id, notify_sub_id)
{
    if(!GetPVarType(playerid, "invite_player"))
        return false;

    new inviter = GetPVarInt(playerid, "invite_player");
    if(inviter != notify_id && inviter != notify_sub_id)
        return false;

    if(notify_type == 0)
        return FamilyAcceptInvite(playerid, inviter);

    return FamilyDeclineInvite(playerid, inviter);
}

cmd:buynamefam(playerid)
{
    if(GetPlayerRangFamily(playerid) != 5 || GetPlayerIdFamily(playerid) == -1)
        return SendClientMessage(playerid, -1, ""c_f_r"Вы не лидер семьи или у вас нет семьи.");

    if(GetPlayerDonateRub(playerid) >= 100)
    {
        Dialog
        (
            playerid, 2244, DIALOG_STYLE_INPUT, 
            "{FF0000}Изменение название семьи",
            "Напишите название вашей семьи ниже.\n"\
            "Стоимость: {FFFF00}100 донат-рублей",
            "Далее", "Выйти"
        );
    }
    else FSendClientMessage(f_string144, playerid, -1, ""c_f_r"У вас не хватает %d донат-рублей", 100-GetPlayerDonateRub(playerid));

    return 1;
}

cmd:giveresurs(playerid)
{
    SetPlayerData(playerid, P_METALL, 1000);
    SetPlayerData(playerid, P_MASK, 10);
    SetPlayerData(playerid, P_MED_CHEST, 3);
    return 1;
}
