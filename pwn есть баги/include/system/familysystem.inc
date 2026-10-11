#if defined _INC_FAMILY_SYSTEM
    #endinput
#endif
#define _INC_FAMILY_SYSTEM

#define FAMILY_SYSTEM_MAX_CARS (1000)

enum E_FAMILY_SYSTEM_CAR
{
    FS_SQL_ID,
    FS_FAMILY_ID,
    FS_OWNABLE_CAR_ID,
    FS_MODEL_ID,
    FS_OWNER_ID,
    FS_ACCESS_RANK,
    FS_STATUS
}

new g_family_system_car[FAMILY_SYSTEM_MAX_CARS][E_FAMILY_SYSTEM_CAR];
new g_family_system_loaded;

stock FamilySystemGetPlayerFamily(playerid)
{
    new family_id = GetPlayerData(playerid, P_FAMILY);

    if(family_id > 0)
    {
        return family_id;
    }

    if(family_id == 0 && GetPlayerData(playerid, P_FAMILY_RANK) >= 10)
    {
        new fam_name[64];
        format(fam_name, sizeof fam_name, "%s", GetFamilyData(0, F_NAME));
        if(strlen(fam_name) > 0)
        {
            return 0;
        }
    }

    if(GetPlayerIdFamily(playerid) != -1)
    {
        return GetPlayerIdFamily(playerid);
    }

    return -1;
}

stock FamilySystemResetSlot(slot)
{
    g_family_system_car[slot][FS_SQL_ID] = 0;
    g_family_system_car[slot][FS_FAMILY_ID] = 0;
    g_family_system_car[slot][FS_OWNABLE_CAR_ID] = 0;
    g_family_system_car[slot][FS_MODEL_ID] = 0;
    g_family_system_car[slot][FS_OWNER_ID] = 0;
    g_family_system_car[slot][FS_ACCESS_RANK] = 1;
    g_family_system_car[slot][FS_STATUS] = 0;
    return 1;
}

stock FamilySystemGetFreeSlot()
{
    for(new i; i < FAMILY_SYSTEM_MAX_CARS; i++)
    {
        if(g_family_system_car[i][FS_SQL_ID] == 0)
        {
            return i;
        }
    }
    return -1;
}

stock FamilySystemFindBySql(sql_id)
{
    for(new i; i < FAMILY_SYSTEM_MAX_CARS; i++)
    {
        if(g_family_system_car[i][FS_SQL_ID] == sql_id)
        {
            return i;
        }
    }
    return -1;
}

stock FamilySystemFindByFamilyOwnable(family_id, ownable_car_id)
{
    for(new i; i < FAMILY_SYSTEM_MAX_CARS; i++)
    {
        if(g_family_system_car[i][FS_SQL_ID] == 0) continue;
        if(g_family_system_car[i][FS_FAMILY_ID] != family_id) continue;
        if(g_family_system_car[i][FS_OWNABLE_CAR_ID] != ownable_car_id) continue;
        return i;
    }
    return -1;
}

stock FamilySystemCreateTable()
{
    mysql_query(mysql,
        "CREATE TABLE IF NOT EXISTS `familysystem` (\
        `id` INT NOT NULL AUTO_INCREMENT,\
        `family_id` INT NOT NULL,\
        `owner_id` INT NOT NULL,\
        `ownable_car_id` INT NOT NULL,\
        `model_id` INT NOT NULL,\
        `access_rank` INT NOT NULL DEFAULT 1,\
        `status` TINYINT NOT NULL DEFAULT 0,\
        `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\
        PRIMARY KEY (`id`),\
        UNIQUE KEY `idx_family_ownable` (`family_id`, `ownable_car_id`),\
        KEY `idx_family` (`family_id`),\
        KEY `idx_owner` (`owner_id`),\
        KEY `idx_ownable` (`ownable_car_id`)\
    ) ENGINE=InnoDB DEFAULT CHARSET=cp1251;",
    false);
    return 1;
}

stock FamilySystemLoad()
{
    for(new i; i < FAMILY_SYSTEM_MAX_CARS; i++)
    {
        FamilySystemResetSlot(i);
    }

    new Cache:result = mysql_query(mysql,
        "SELECT id, family_id, owner_id, ownable_car_id, model_id, access_rank, status FROM familysystem",
    true);

    new rows = cache_num_rows();
    if(rows > FAMILY_SYSTEM_MAX_CARS)
    {
        printf("[FamilySystem] rows (%d) > FAMILY_SYSTEM_MAX_CARS (%d)", rows, FAMILY_SYSTEM_MAX_CARS);
        rows = FAMILY_SYSTEM_MAX_CARS;
    }

    for(new i; i < rows; i++)
    {
        g_family_system_car[i][FS_SQL_ID] = cache_get_field_content_int(i, "id");
        g_family_system_car[i][FS_FAMILY_ID] = cache_get_field_content_int(i, "family_id");
        g_family_system_car[i][FS_OWNER_ID] = cache_get_field_content_int(i, "owner_id");
        g_family_system_car[i][FS_OWNABLE_CAR_ID] = cache_get_field_content_int(i, "ownable_car_id");
        g_family_system_car[i][FS_MODEL_ID] = cache_get_field_content_int(i, "model_id");
        g_family_system_car[i][FS_ACCESS_RANK] = cache_get_field_content_int(i, "access_rank");
        g_family_system_car[i][FS_STATUS] = cache_get_field_content_int(i, "status");
    }

    g_family_system_loaded = rows;
    cache_delete(result);

    printf("[FamilySystem] Loaded cars: %d", g_family_system_loaded);
    return rows;
}

stock FamilySystemInit()
{
    FamilySystemCreateTable();
    FamilySystemLoad();
    return 1;
}

stock FamilySystemAddOwnableCarToFamily(playerid, ownable_car_id, model_id)
{
    new family_id = FamilySystemGetPlayerFamily(playerid);
    if(family_id == -1)
    {
        SendClientMessage(playerid, 0xCECECEFF, "You are not in a family");
        return 0;
    }

    if(GetPlayerData(playerid, P_FAMILY_RANK) < 10 && GetPlayerRangFamily(playerid) != 5)
    {
        SendClientMessage(playerid, 0xCECECEFF, "Only family leader can add cars");
        return 0;
    }

    if(ownable_car_id <= 0 || model_id <= 0)
    {
        SendClientMessage(playerid, 0xCECECEFF, "Invalid vehicle data");
        return 0;
    }

    if(FamilySystemFindByFamilyOwnable(family_id, ownable_car_id) != -1)
    {
        SendClientMessage(playerid, 0xCECECEFF, "This car is already in family car park");
        return 0;
    }

    new slot = FamilySystemGetFreeSlot();
    if(slot == -1)
    {
        SendClientMessage(playerid, 0xCECECEFF, "Family car park limit reached");
        return 0;
    }

    new query[256];
    mysql_format(mysql, query, sizeof query,
        "INSERT INTO familysystem (family_id, owner_id, ownable_car_id, model_id, access_rank, status) VALUES (%d, %d, %d, %d, 1, 0)",
        family_id,
        GetPlayerAccountID(playerid),
        ownable_car_id,
        model_id);

    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno() != 0)
    {
        cache_delete(result);
        SendClientMessage(playerid, 0xCECECEFF, "SQL error while adding car to family");
        return 0;
    }

    new insert_id = cache_insert_id();
    cache_delete(result);

    if(insert_id <= 0)
    {
        SendClientMessage(playerid, 0xCECECEFF, "Failed to get new family car ID");
        return 0;
    }

    g_family_system_car[slot][FS_SQL_ID] = insert_id;
    g_family_system_car[slot][FS_FAMILY_ID] = family_id;
    g_family_system_car[slot][FS_OWNER_ID] = GetPlayerAccountID(playerid);
    g_family_system_car[slot][FS_OWNABLE_CAR_ID] = ownable_car_id;
    g_family_system_car[slot][FS_MODEL_ID] = model_id;
    g_family_system_car[slot][FS_ACCESS_RANK] = 1;
    g_family_system_car[slot][FS_STATUS] = 0;
    g_family_system_loaded++;

    SendClientMessage(playerid, 0x66CC00FF, "Car added to family car park");
    return 1;
}

stock FamilySystemAddOwnableCarBySql(playerid, ownable_car_id)
{
    if(ownable_car_id <= 0)
    {
        SendClientMessage(playerid, 0xCECECEFF, "Usage: /testfamilybuy [ownable_cars id]");
        return 0;
    }

    new query[144];
    mysql_format(mysql, query, sizeof query,
        "SELECT owner_id, model_id FROM ownable_cars WHERE id = %d LIMIT 1",
        ownable_car_id);

    new Cache:result = mysql_query(mysql, query, true);
    if(cache_num_rows() == 0)
    {
        cache_delete(result);
        SendClientMessage(playerid, 0xCECECEFF, "Car with this ID was not found");
        return 0;
    }

    new owner_id = cache_get_field_content_int(0, "owner_id");
    new model_id = cache_get_field_content_int(0, "model_id");
    cache_delete(result);

    if(owner_id != GetPlayerAccountID(playerid))
    {
        SendClientMessage(playerid, 0xCECECEFF, "You can add only your own personal car");
        return 0;
    }

    return FamilySystemAddOwnableCarToFamily(playerid, ownable_car_id, model_id);
}

stock FamilySystemSendCarList(playerid, Node:json)
{
    new family_id = FamilySystemGetPlayerFamily(playerid);

    JSON_SetInt(json, "t", 2);
    JSON_SetInt(json, "g", 1);

    new Node:nArray = JSON_Array();
    new Node:idArray = JSON_Array();

    if(family_id != -1)
    {
        new model_name[32];
        for(new i; i < FAMILY_SYSTEM_MAX_CARS; i++)
        {
            if(g_family_system_car[i][FS_SQL_ID] == 0) continue;
            if(g_family_system_car[i][FS_FAMILY_ID] != family_id) continue;

            model_name[0] = EOS;
            if(g_family_system_car[i][FS_MODEL_ID] >= 400 && g_family_system_car[i][FS_MODEL_ID] <= 611)
                GetVehicleModelName(g_family_system_car[i][FS_MODEL_ID], model_name);
            else
                format(model_name, sizeof model_name, "Model %d", g_family_system_car[i][FS_MODEL_ID]);

            nArray = JSON_Append(nArray, JSON_Array(JSON_String(model_name)));
            idArray = JSON_Append(idArray, JSON_Array(JSON_Int(g_family_system_car[i][FS_SQL_ID])));
        }
    }

    JSON_SetArray(json, "n", nArray);
    JSON_SetArray(json, "id", idArray);

    OnPacketIncoming(playerid, 45, json);
    return 1;
}

stock FamilySystemSendCarInfo(playerid, Node:json)
{
    new family_id = FamilySystemGetPlayerFamily(playerid);

    new sql_id;
    if(!JSON_GetInt(json, "id", sql_id))
    {
        JSON_SetInt(json, "t", 2);
        JSON_SetInt(json, "s", 1);
        JSON_SetInt(json, "r", 1);
        JSON_SetInt(json, "d", 0);
        OnPacketIncoming(playerid, 45, json);
        return 0;
    }

    new idx = FamilySystemFindBySql(sql_id);
    if(idx == -1 || family_id == -1 || g_family_system_car[idx][FS_FAMILY_ID] != family_id)
    {
        JSON_SetInt(json, "t", 2);
        JSON_SetInt(json, "s", 1);
        JSON_SetInt(json, "r", 1);
        JSON_SetInt(json, "d", 0);
        OnPacketIncoming(playerid, 45, json);
        return 0;
    }

    JSON_SetInt(json, "t", 2);
    JSON_SetInt(json, "s", 1);
    JSON_SetInt(json, "r", g_family_system_car[idx][FS_ACCESS_RANK]);
    JSON_SetInt(json, "d", g_family_system_car[idx][FS_STATUS]);
    OnPacketIncoming(playerid, 45, json);
    return 1;
}

stock FamilySystemSendActionResult(playerid, Node:json, success)
{
    JSON_SetInt(json, "t", 2);
    JSON_SetInt(json, "s", 2);
    JSON_SetInt(json, "d", success ? 1 : 0);
    OnPacketIncoming(playerid, 45, json);
    return 1;
}

stock FamilySystemHandleCarAction(playerid, Node:json)
{
    new family_id = FamilySystemGetPlayerFamily(playerid);

    new sql_id, action_id;
    if(!JSON_GetInt(json, "m", sql_id) || !JSON_GetInt(json, "id", action_id))
    {
        return FamilySystemSendActionResult(playerid, json, 0);
    }

    new idx = FamilySystemFindBySql(sql_id);
    if(idx == -1 || family_id == -1 || g_family_system_car[idx][FS_FAMILY_ID] != family_id)
    {
        return FamilySystemSendActionResult(playerid, json, 0);
    }

    new query[160];

    switch(action_id)
    {
        case 1, 5, 6:
        {
            g_family_system_car[idx][FS_STATUS] = 1;
            mysql_format(mysql, query, sizeof query,
                "UPDATE familysystem SET status = 1 WHERE id = %d LIMIT 1",
                g_family_system_car[idx][FS_SQL_ID]);
            mysql_query(mysql, query, false);
        }
        case 4:
        {
            g_family_system_car[idx][FS_STATUS] = 0;
            mysql_format(mysql, query, sizeof query,
                "UPDATE familysystem SET status = 0 WHERE id = %d LIMIT 1",
                g_family_system_car[idx][FS_SQL_ID]);
            mysql_query(mysql, query, false);
        }
        case 2:
        {
            mysql_format(mysql, query, sizeof query,
                "DELETE FROM familysystem WHERE id = %d LIMIT 1",
                g_family_system_car[idx][FS_SQL_ID]);
            mysql_query(mysql, query, false);
            FamilySystemResetSlot(idx);
            if(g_family_system_loaded > 0) g_family_system_loaded--;
        }
        case 3:
        {
            new access;
            if(JSON_GetInt(json, "r", access))
            {
                if(access == 0 && g_family_system_car[idx][FS_ACCESS_RANK] > 1)
                    g_family_system_car[idx][FS_ACCESS_RANK]--;
                else if(access == 1 && g_family_system_car[idx][FS_ACCESS_RANK] < 10)
                    g_family_system_car[idx][FS_ACCESS_RANK]++;
            }

            mysql_format(mysql, query, sizeof query,
                "UPDATE familysystem SET access_rank = %d WHERE id = %d LIMIT 1",
                g_family_system_car[idx][FS_ACCESS_RANK],
                g_family_system_car[idx][FS_SQL_ID]);
            mysql_query(mysql, query, false);
        }
        case 0, 7:
        {
        }
        default:
        {
            return FamilySystemSendActionResult(playerid, json, 0);
        }
    }

    return FamilySystemSendActionResult(playerid, json, 1);
}

CMD:testfamilybuy(playerid, params[])
{
    if(FamilySystemGetPlayerFamily(playerid) == -1)
        return SendClientMessage(playerid, 0xCECECEFF, "You are not in a family");

    if(GetPlayerData(playerid, P_FAMILY_RANK) < 10 && GetPlayerRangFamily(playerid) != 5)
        return SendClientMessage(playerid, 0xCECECEFF, "Only family leader can use /testfamilybuy");

    new ownable_car_id;
    if(sscanf(params, "d", ownable_car_id))
        ownable_car_id = 0;

    if(ownable_car_id > 0)
        return FamilySystemAddOwnableCarBySql(playerid, ownable_car_id);

    new vehicleid = GetPlayerOwnableCar(playerid);
    if(vehicleid == INVALID_VEHICLE_ID)
        return SendClientMessage(playerid, 0xCECECEFF, "Sit in your own car or use: /testfamilybuy [id]");

    new index = GetVehicleData(vehicleid, V_ACTION_ID);
    return FamilySystemAddOwnableCarToFamily(
        playerid,
        GetOwnableCarData(index, OC_SQL_ID),
        GetOwnableCarData(index, OC_MODEL_ID)
    );
}
