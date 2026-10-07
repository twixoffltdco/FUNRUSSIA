#define MAX_INV_SLOTS 20
#define MAX_ITEM_STACK 5

enum p_inv_info {
    invID,
    invItem,
    invCount,
    invValue
}
new PlayerInventory[MAX_PLAYERS][MAX_INV_SLOTS][p_inv_info];

forward LoadPlayerInventory(playerid);
public LoadPlayerInventory(playerid)
{
    new rows = cache_num_rows();
    for(new i = 0; i < MAX_INV_SLOTS; i++)
    {
        PlayerInventory[playerid][i][invID] = 0;
        PlayerInventory[playerid][i][invItem] = 0;
        PlayerInventory[playerid][i][invCount] = 0;
    }
    for(new i = 0; i < rows; i++)
    {
        new slot = cache_get_field_content_int(i, "slot");
        if(slot >= 0 && slot < MAX_INV_SLOTS)
        {
            PlayerInventory[playerid][slot][invID] = cache_get_field_content_int(i, "id");
            PlayerInventory[playerid][slot][invItem] = cache_get_field_content_int(i, "item_id");
            PlayerInventory[playerid][slot][invCount] = cache_get_field_content_int(i, "count");
            PlayerInventory[playerid][slot][invValue] = cache_get_field_content_int(i, "value");
        }
    }
    return 1;
}

forward OnItemInserted(playerid, slot);
public OnItemInserted(playerid, slot)
{
    PlayerInventory[playerid][slot][invID] = cache_insert_id();
    return 1;
}

stock GivePlayerItem(playerid, itemid, amount)
{
    if(itemid == 22 || itemid == 23)
    {
        for(new i = 0; i < MAX_INV_SLOTS; i++)
        {
            if(PlayerInventory[playerid][i][invItem] == itemid && PlayerInventory[playerid][i][invCount] < MAX_ITEM_STACK)
            {
                new can_add = MAX_ITEM_STACK - PlayerInventory[playerid][i][invCount];
                new to_add = (amount > can_add) ? can_add : amount;
                
                PlayerInventory[playerid][i][invCount] += to_add;
                amount -= to_add;
                
                new query[128];
                mysql_format(db_handle, query, sizeof(query), "UPDATE `inventory` SET `count` = %d WHERE `id` = %d", PlayerInventory[playerid][i][invCount], PlayerInventory[playerid][i][invID]);
                mysql_tquery(db_handle, query);
                
                if(amount <= 0) return 1;
            }
        }
    }

    while(amount > 0)
    {
        new slot = -1;
        for(new i = 0; i < MAX_INV_SLOTS; i++)
        {
            if(PlayerInventory[playerid][i][invItem] == 0) { slot = i; break; }
        }

        if(slot == -1) return 0;

        new to_add;
        if(itemid == 22 || itemid == 23) {
            to_add = (amount > MAX_ITEM_STACK) ? MAX_ITEM_STACK : amount;
        } else {
            to_add = 1; 
        }

        PlayerInventory[playerid][slot][invItem] = itemid;
        PlayerInventory[playerid][slot][invCount] = to_add;
        PlayerInventory[playerid][slot][invValue] = 0;
        amount -= to_add;

        new query[256];
        mysql_format(db_handle, query, sizeof(query), "INSERT INTO `inventory` (`uid`, `item_id`, `count`, `slot`, `value`) VALUES (%d, %d, %d, %d, 0)", GetPlayerAccountID(playerid), itemid, to_add, slot);
        mysql_tquery(db_handle, query, "OnItemInserted", "ii", playerid, slot);
    }
    return 1;
}

CMD:giveitem(playerid, params[])
{
    new targetid, item, count;
    if(sscanf(params, "uii", targetid, item, count)) return SendClientMessage(playerid, -1, "use: /giveitem [id] [item_id] [count]");
    if(targetid == INVALID_PLAYER_ID) return 1;

    if(!GivePlayerItem(targetid, item, count)) return SendClientMessage(playerid, -1, "gived");
    return 1;
}

stock GivePlayerSkin(playerid, skinid)
{
    new slot = -1;
    for(new i = 0; i < MAX_INV_SLOTS; i++)
    {
        if(PlayerInventory[playerid][i][invItem] == 0) { slot = i; break; }
    }

    if(slot == -1) return 0;

    PlayerInventory[playerid][slot][invItem] = 134;
    PlayerInventory[playerid][slot][invCount] = 1;
    PlayerInventory[playerid][slot][invValue] = skinid;

    new query[256];
    mysql_format(db_handle, query, sizeof(query), "INSERT INTO `inventory` (`uid`, `item_id`, `count`, `slot`, `value`) VALUES (%d, 134, 1, %d, %d)", GetPlayerAccountID(playerid), slot, skinid);
    mysql_tquery(db_handle, query, "OnItemInserted", "ii", playerid, slot);
    return 1;
}

CMD:addskin(playerid, params[])
{
    new targetid, skin;
    if(sscanf(params, "ui", targetid, skin)) return SendClientMessage(playerid, -1, "use: /addskin [id] [skin_id]");
    if(targetid == INVALID_PLAYER_ID) return 1;

    if(!GivePlayerSkin(targetid, skin)) return SendClientMessage(playerid, -1, "Failed to give skin.");
    
    return 1;
}

stock Inventory(playerid)
{
    new Node:JSONObject = JSON_Object();
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    
    JSON_SetInt(JSONObject, "o", 1);
    JSON_SetInt(JSONObject, "i", 0);
    JSON_SetInt(JSONObject, "nm", GetPlayerSimCard(playerid));
    JSON_SetString(JSONObject, "n", name); 
    JSON_SetInt(JSONObject, "lv", Player[playerid][pLevel]);
    JSON_SetInt(JSONObject, "id", playerid);
    JSON_SetInt(JSONObject, "w", 5); 
    JSON_SetInt(JSONObject, "mw", 50);
    JSON_SetInt(JSONObject, "s", 100);
    JSON_SetInt(JSONObject, "v", Player[playerid][pVipType]);
    JSON_SetInt(JSONObject, "ps", GetPlayerSkin(playerid));
    JSON_SetInt(JSONObject, "m", GetPlayerMoneyEx(playerid));  
    JSON_SetInt(JSONObject, "sl", MAX_INV_SLOTS);

    new Node:itArray = JSON_Array();

    for(new i = 0; i < MAX_INV_SLOTS; i++)
    {
        if(PlayerInventory[playerid][i][invItem] <= 0) continue;

        new item_id = PlayerInventory[playerid][i][invItem];
        new item_value = PlayerInventory[playerid][i][invCount];
        if(item_value <= 0) item_value = 1;
        if(item_id == 134) item_value = PlayerInventory[playerid][i][invValue];

        itArray = JSON_Append(itArray, JSON_Int(item_id));
        itArray = JSON_Append(itArray, JSON_Int(item_value));
        itArray = JSON_Append(itArray, JSON_Int(i));
        itArray = JSON_Append(itArray, JSON_Int(0));
    }

    JSON_SetArray(JSONObject, "it", itArray);

    // Legacy fallback: skin only. SIM is injected from `nm`.
    // Never synthesize the backpack cell (old fake item id 2).
    new Node:aiArray = JSON_Array(
        JSON_Int(134), JSON_Int(Player[playerid][pSkin]), JSON_Int(6), JSON_Int(0)
    );
    JSON_SetArray(JSONObject, "ai", aiArray);

    OnPacketIncoming(playerid, 33, JSONObject);
    
    JSON_Cleanup(JSONObject);
    return 1;
}

CMD:invtest(playerid, params[])
{
    Inventory(playerid);
    return 1;
}