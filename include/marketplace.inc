#if defined _KRANIN_MARKETPLACE_INC
    #endinput
#endif
#define _KRANIN_MARKETPLACE_INC

// Compatibility layer for the current Inventory11 implementation.
#define MAX_INVENTORY_SLOTS (INVENTORY11_MAX_SLOTS + 1)
#define MAX_ACTIVE_SLOTS (1)
#define SIM_SLOT (0)
#define SKIN_SLOT (0)
#define ITEM_TYPE_SKIN (3)
#define ShowNotificationSile ShowNotificationNew

// V13: accessory_inventory stores a 0-based acs_id. Encode it in marketplace
// storage so it can never collide with ordinary inventory ids (22/58/134/etc).
#define MARKET_ENCODED_ACCESSORY_BASE (2000000)
#define MARKET_ENCODED_ACCESSORY_LIMIT (MARKET_ENCODED_ACCESSORY_BASE + 100000)

stock Market_IsEncodedAccessoryItem(item_id)
{
    return item_id >= MARKET_ENCODED_ACCESSORY_BASE && item_id < MARKET_ENCODED_ACCESSORY_LIMIT;
}

stock Market_EncodeAccessoryItem(acs_id)
{
    if(acs_id < 0 || acs_id >= sizeof(accessory)) return 0;
    return MARKET_ENCODED_ACCESSORY_BASE + acs_id;
}

stock Market_DecodeAccessoryItem(item_id)
{
    if(!Market_IsEncodedAccessoryItem(item_id)) return -1;
    new acs_id = item_id - MARKET_ENCODED_ACCESSORY_BASE;
    if(acs_id < 0 || acs_id >= sizeof(accessory)) return -1;
    return acs_id;
}

stock Market_GetClientDisplayItem(item_id)
{
    if(Market_IsEncodedAccessoryItem(item_id))
    {
        new acs_id = Market_DecodeAccessoryItem(item_id);
        return (acs_id >= 0) ? (acs_id + 1) : 0;
    }
    if(item_id == 134) return 134;
    return item_id;
}

enum E_MARKET_LEGACY_ITEM
{
    inv_itemId,
    inv_itemCount,
    inv_itemSlot,
    inv_itemPlate[32],
    inv_itemType,
    inv_itemWeight,
    inv_itemName[64],
    bool:inv_itemActive,
    inv_activeSlot
}

new g_PlayerInventory[MAX_PLAYERS][MAX_INVENTORY_SLOTS][E_MARKET_LEGACY_ITEM];
new g_PlayerActiveSlots[MAX_PLAYERS][MAX_ACTIVE_SLOTS][E_MARKET_LEGACY_ITEM];

stock Accessory_GetItemIdByModel(modelid)
{
    return Inv11_GetAccItemByModel(modelid);
}

stock GetItemNameById(item_id, output[], output_size)
{
    if(Market_IsEncodedAccessoryItem(item_id))
    {
        new acs_id = Market_DecodeAccessoryItem(item_id);
        if(acs_id >= 0)
        {
            format(output, output_size, "%s", accessory[acs_id][NAME_ACCESSORY]);
            return 1;
        }
    }

    new modelid = Inv11_GetAccModelByItem(item_id);
    if(modelid <= 0) modelid = item_id;

    for(new i = 0; i < sizeof(accessory); i++)
    {
        if(accessory[i][ID_ACCESSORY] != modelid) continue;
        format(output, output_size, "%s", accessory[i][NAME_ACCESSORY]);
        return 1;
    }

    format(output, output_size, "Аксессуар #%d", item_id);
    return 1;
}

stock GetItemName(item_id, output[], output_size)
{
    switch(item_id)
    {
        case 22: format(output, output_size, "Аптечка");
        case 23: format(output, output_size, "Ремонтный комплект");
        case 58: format(output, output_size, "SIM-карта");
        case 59: format(output, output_size, "Гос. номер РФ");
        case 81: format(output, output_size, "Гос. номер Украины");
        case 82: format(output, output_size, "Гос. номер Беларуси");
        case 83: format(output, output_size, "Гос. номер Казахстана");
        case 134: format(output, output_size, "Скин");
        default:
        {
            if(Market_IsEncodedAccessoryItem(item_id) || Inventory11_IsAccessoryItem(item_id))
                return GetItemNameById(item_id, output, output_size);
            format(output, output_size, "Предмет #%d", item_id);
        }
    }
    return 1;
}

stock Market_ClearInventoryCache(playerid)
{
    for(new slot = 0; slot < MAX_INVENTORY_SLOTS; slot++)
    {
        g_PlayerInventory[playerid][slot][inv_itemId] = 0;
        g_PlayerInventory[playerid][slot][inv_itemCount] = 0;
        g_PlayerInventory[playerid][slot][inv_itemSlot] = slot;
        g_PlayerInventory[playerid][slot][inv_itemPlate][0] = EOS;
        g_PlayerInventory[playerid][slot][inv_itemType] = 0;
        g_PlayerInventory[playerid][slot][inv_itemWeight] = 0;
        g_PlayerInventory[playerid][slot][inv_itemName][0] = EOS;
        g_PlayerInventory[playerid][slot][inv_itemActive] = false;
        g_PlayerInventory[playerid][slot][inv_activeSlot] = -1;
    }
    return 1;
}

stock Inventory_GetFreeSlot(playerid)
{
    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0) return -1;

    new bool:used[MAX_INVENTORY_SLOTS];
    new query[160];
    mysql_format(mysql, query, sizeof(query),
        "SELECT `slot` FROM `inventory` WHERE `account_id`=%d", account_id);
    new Cache:result = mysql_query(mysql, query, true);

    if(mysql_errno())
    {
        cache_delete(result);
        return -1;
    }

    new rows = cache_num_rows();
    for(new i = 0; i < rows; i++)
    {
        new slot = cache_get_field_content_int(i, "slot", mysql);
        if(slot > 0 && slot < MAX_INVENTORY_SLOTS) used[slot] = true;
    }
    cache_delete(result);

    new max_slots = Inventory11_GetMaxSlots(playerid);
    if(max_slots >= MAX_INVENTORY_SLOTS) max_slots = MAX_INVENTORY_SLOTS - 1;
    for(new slot = 1; slot <= max_slots; slot++)
    {
        if(!used[slot]) return slot;
    }
    return -1;
}

stock Inventory_AddItem(playerid, item_id, slot, item_count, const item_plate[])
{
    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0 || item_id <= 0) return 0;
    if(slot <= 0 || slot > Inventory11_GetMaxSlots(playerid)) return 0;
    if(item_count <= 0) item_count = 1;

    new weight_count = (item_id == 58 || item_id == 59 || item_id == 81 || item_id == 82 || item_id == 83 || item_id == 134 || Inventory11_IsAccessoryItem(item_id)) ? 1 : item_count;
    if(!Inventory11_CanAddItemWeight(playerid, item_id, weight_count))
        return 0;

    new model_id = item_id;
    new amount = item_count;
    new extra_1 = 0;
    new extra_2 = 0;
    new source_internal_id = 0;
    new old_skin = 0;
    new sim_value = 0;
    new oldsim_value = 0;

    if(item_id == 134)
    {
        if(!IsValidSkinModel(item_count)) return 0;
        model_id = item_count;
        amount = 1;
        source_internal_id = item_count;
    }
    else if(item_id == 22)
    {
        model_id = item_count;
        amount = item_count;
    }
    else if(item_id == 58)
    {
        model_id = item_count;
        amount = 1;
        extra_1 = item_count;
        sim_value = GetPlayerPhone(playerid);
        oldsim_value = item_count;
    }
    else if(Inventory11_IsAccessoryItem(item_id))
    {
        new accessory_model = Inv11_GetAccModelByItem(item_id);
        if(accessory_model <= 0) return 0;
        model_id = 1;
        amount = 1;
        extra_1 = accessory_model;
    }
    else if(Inventory11_IsPlateItem(item_id))
    {
        model_id = PlateItemIdToModel(item_id);
        amount = 1;
    }

    new query[512];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `inventory` (`account_id`,`item_id`,`model_id`,`slot`,`amount`,`extra_1`,`extra_2`,`source_internal_id`,`old_skin`,`sim`,`oldsim`) SELECT %d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `inventory` WHERE `account_id`=%d AND `slot`=%d LIMIT 1)",
        account_id, item_id, model_id, slot, amount, extra_1, extra_2, source_internal_id, old_skin, sim_value, oldsim_value,
        account_id, slot);
    new Cache:result = mysql_query(mysql, query, true);
    new inserted = cache_affected_rows(mysql);
    cache_delete(result);
    if(!inserted) return 0;

    if(Inventory11_IsPlateItem(item_id))
    {
        new plate_type = PlateCountryToType(PlateItemIdToCountry(item_id));
        new plate[16], region[8], stored_plate[32];
        format(stored_plate, sizeof(stored_plate), "%s", item_plate);
        if(!ParseStoredPlateValue(stored_plate, plate_type, plate, sizeof(plate), region, sizeof(region)) ||
            !Inventory11_SavePlateData(playerid, slot, plate_type, plate, region))
        {
            Inventory11_DeleteSlotFromDatabase(playerid, slot);
            return 0;
        }
    }

    if(item_id == 134) Inventory11_SetSkinModelByPos(playerid, slot, model_id);
    return 1;
}

stock Inventory_DeleteItem(playerid, slot)
{
    if(slot <= 0 || slot >= MAX_INVENTORY_SLOTS) return 0;
    if(g_PlayerInventory[playerid][slot][inv_itemId] <= 0) return 0;
    if(!Inventory11_DeleteSlotFromDatabase(playerid, slot)) return 0;
    g_PlayerInventory[playerid][slot][inv_itemId] = 0;
    g_PlayerInventory[playerid][slot][inv_itemCount] = 0;
    return 1;
}

stock Inventory_RemoveItem(playerid, slot, amount)
{
    if(slot <= 0 || slot >= MAX_INVENTORY_SLOTS || amount <= 0) return 0;

    new item_id = g_PlayerInventory[playerid][slot][inv_itemId];
    new current = g_PlayerInventory[playerid][slot][inv_itemCount];
    if(item_id <= 0 || current < amount) return 0;
    if(current == amount) return Inventory_DeleteItem(playerid, slot);

    new query[192];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE `inventory` SET `amount`=`amount`-%d WHERE `account_id`=%d AND `slot`=%d AND `item_id`=%d AND `amount`>=%d LIMIT 1",
        amount, GetPlayerAccountID(playerid), slot, item_id, amount);
    new Cache:result = mysql_query(mysql, query, true);
    new updated = cache_affected_rows(mysql);
    cache_delete(result);
    if(!updated) return 0;

    g_PlayerInventory[playerid][slot][inv_itemCount] -= amount;
    return 1;
}

#define MARKET_SOURCE_ACTIVE_BASE              (1000)
#define MARKET_SOURCE_ACCESSORY_BASE           (2000)
#define MARKET_SOURCE_ACCESSORY_SLOTS          (10)
#define MARKET_SOURCE_OWNED_ACCESSORY_BASE     (3000)
#define MARKET_SOURCE_OWNED_ACCESSORY_MAX      (256)
#define MARKET_SOURCE_OWNED_SKIN_BASE          (4000)
#define MARKET_SOURCE_OWNED_SKIN_MAX           (256)

#define MARKET_SKIN_SOURCE_NONE                (0)
#define MARKET_SKIN_SOURCE_INVSKINS            (1)
#define MARKET_SKIN_SOURCE_INVENTORY_SKINS     (2)

new const g_MarketAccessoryItemModels[][2] =
{
    {1, 907}, {2, 908}, {3, 909}, {4, 912}, {5, 916}, {6, 926},
    {7, 918}, {8, 910}, {9, 914}, {10, 919}, {11, 921}, {12, 923},
    {13, 915}, {14, 917}, {15, 922}, {16, 924}, {17, 925}, {18, 911},
    {19, 913}, {20, 920}, {30, 985}, {31, 986}, {32, 990}, {33, 994},
    {34, 995}, {35, 967}, {36, 968}, {37, 969}, {38, 979}, {39, 980},
    {40, 981}, {41, 982}, {42, 984}, {43, 987}, {44, 988}, {45, 989},
    {46, 992}, {47, 993}, {48, 970}, {49, 971}, {50, 972}, {51, 973},
    {52, 974}, {53, 975}, {54, 976}, {55, 977}, {56, 978}, {57, 983},
    {60, 1194}, {61, 1195}, {62, 1196}, {63, 1197}, {64, 1198}, {65, 1199},
    {66, 2646}, {67, 1716}, {68, 1699}, {69, 1701}, {70, 1702}, {71, 1703},
    {72, 1704}, {73, 1705}, {74, 1706}, {75, 1707}, {76, 1708}, {77, 1709},
    {78, 1710}, {79, 1711}, {84, 1720}, {85, 1721}, {86, 1722}, {87, 1723},
    {88, 1724}, {89, 1725}, {90, 1726}, {91, 1747}, {92, 1748}, {93, 1749},
    {94, 1750}, {95, 1751}, {96, 1727}, {97, 1728}, {98, 1729}, {99, 1730},
    {100, 1731}, {101, 1732}, {102, 1743}, {103, 1744}, {104, 1745}, {105, 1746},
    {106, 1733}, {107, 1734}, {108, 1735}, {109, 1736}, {110, 1737}, {111, 1783},
    {112, 1779}, {113, 1778}, {114, 1777}, {115, 1776}, {135, 15134}, {136, 15135},
    {137, 15136}, {138, 15137}, {139, 15138}, {140, 15139}, {141, 15140}, {142, 15141},
    {143, 15142}, {144, 15143}, {145, 15144}, {146, 15145}, {147, 15146}, {148, 15147},
    {149, 15148}, {150, 15149}, {151, 15152}, {152, 15153}, {153, 15154}, {154, 15155},
    {155, 15150}, {156, 15160}, {157, 15161}, {158, 15159}, {159, 15151}, {160, 15157},
    {161, 15158}, {162, 1212}, {163, 18226}, {164, 18227}, {165, 18228}, {166, 18229},
    {167, 18230}, {168, 18231}, {169, 18232}, {170, 18233}, {171, 18234}, {172, 18235},
    {173, 18236}, {174, 18237}, {175, 18238}, {176, 18239}, {177, 18240}, {178, 18241},
    {179, 18242}, {180, 18243}, {181, 18244}, {182, 18245}, {183, 18246}, {184, 18247},
    {185, 18248}, {186, 18249}, {187, 18250}, {188, 18251}, {189, 18252}, {190, 18253},
    {191, 18254}, {192, 18255}, {193, 18256}, {194, 18257}, {195, 18258}, {196, 18259},
    {197, 18260}, {198, 18261}, {199, 18262}, {200, 18263}, {201, 18264}, {202, 18265},
    {203, 18266}, {204, 18267}, {205, 18268}, {206, 18269}, {207, 18270}, {208, 18271},
    {209, 18272}, {210, 18273}, {211, 18274}, {212, 18275}, {213, 18276}, {214, 18277},
    {215, 18278}, {216, 18279}, {217, 18282}, {218, 18283}, {219, 18284}, {220, 18285},
    {221, 18286}, {222, 18287}, {223, 18288}, {224, 18289}, {225, 18290}, {226, 18291},
    {227, 18292}, {228, 18293}, {229, 18294}, {230, 18295}, {231, 18296}, {232, 18298},
    {233, 18300}, {234, 18301}, {235, 18302}, {236, 18306}, {237, 18307}, {238, 18310},
    {239, 18312}, {240, 18313}, {241, 18318}, {242, 18315}, {243, 18319}, {244, 18322},
    {245, 18328}, {246, 18329}, {247, 18330}, {248, 18331}, {249, 18332}, {250, 18333},
    {251, 18334}, {252, 18335}, {253, 18336}, {254, 18337}, {255, 18338}, {256, 18339},
    {257, 18340}, {258, 18341}, {259, 18342}, {260, 18343}, {261, 18344}, {262, 18345},
    {263, 18346}, {264, 18347}, {265, 18348}, {266, 18349}, {267, 18350}, {268, 18351},
    {269, 18352}, {270, 18353}, {271, 18354}, {272, 18355}, {273, 18356}, {274, 18357},
    {275, 18358}, {276, 18366}, {277, 18364}, {278, 18365}, {279, 18367}, {280, 18368},
    {281, 18369}, {282, 18370}, {283, 18371}, {284, 18372}, {285, 18373}, {286, 18374},
    {287, 18375}, {288, 18376}, {289, 18377}, {290, 18378}, {291, 18379}, {292, 18380},
    {293, 18381}, {294, 18382}, {295, 18383}, {296, 18384}, {297, 18385}, {298, 18386},
    {299, 18387}, {300, 18388}, {301, 18389}, {302, 18390}, {303, 18391}, {304, 18392},
    {305, 18393}, {306, 18394}, {307, 18395}, {308, 18396}, {309, 18397}, {310, 18398},
    {311, 18399}, {312, 18400}, {313, 18401}, {314, 18402}, {315, 18403}, {316, 18404},
    {317, 18405}, {318, 18406}, {319, 18407}, {320, 18408}, {321, 18409}, {322, 18410},
    {323, 18411}, {324, 18412}, {325, 18413}, {326, 18414}, {327, 18415}, {328, 17983},
    {329, 17984}, {330, 17985}, {331, 17986}, {332, 17987}, {333, 17988}, {334, 17989},
    {335, 17990}, {336, 17991}, {337, 17992}, {338, 17993}, {339, 17994}, {340, 17995},
    {341, 17996}, {342, 17997}, {343, 17998}, {344, 17999}, {345, 13628}, {346, 1210},
    {347, 18497}, {348, 18498}, {349, 18499}, {350, 18500}, {351, 18501}, {352, 18502},
    {353, 18503}, {354, 18504}, {355, 18505}, {356, 18506}, {357, 18507}, {358, 18508},
    {359, 18509}, {360, 18510}, {361, 18511}, {362, 18512}, {363, 18513}, {364, 18514},
    {365, 18515}, {366, 18516}, {367, 18517}, {368, 18518}, {369, 18519}, {370, 18520},
    {371, 18521}, {372, 18522}, {373, 18523}, {374, 18524}, {375, 18525}, {376, 18526},
    {377, 18527}, {378, 18528}, {379, 18529}, {380, 18530}, {381, 18567}, {382, 18568},
    {383, 18569}, {384, 18570}, {385, 18571}, {386, 18572}, {387, 18573}, {388, 18574},
    {389, 18575}, {390, 18576}, {391, 7327}, {392, 7328}, {393, 7329}, {394, 7330},
    {395, 7331}, {396, 7332}, {397, 7333}, {398, 7334}, {399, 7335}, {400, 7336},
    {401, 7337}, {402, 7338}, {403, 7339}, {404, 7340}, {405, 7341}, {406, 7342},
    {407, 7343}, {408, 7344}, {409, 7345}, {410, 7346}, {411, 7347}, {412, 7348},
    {413, 7349}, {414, 7350}, {415, 7351}, {416, 7352}, {417, 7353}, {418, 7354},
    {419, 7355}, {420, 7356}, {421, 7357}, {422, 7358}, {423, 7359}, {424, 7360},
    {425, 7361}, {426, 7362}, {427, 7363}, {428, 7364}, {429, 7365}, {430, 7366},
    {431, 7367}, {432, 7368}, {433, 7369}, {434, 7370}, {435, 7371}, {436, 7372},
    {437, 7373}, {438, 7374}, {439, 7375}, {440, 7376}, {441, 7377}, {442, 7378},
    {443, 7379}, {444, 7380}, {445, 7381}, {446, 7382}, {447, 7383}, {448, 7384},
    {449, 7385}, {450, 7386}, {451, 7387}, {452, 7388}, {453, 7389}, {454, 7390},
    {455, 7391}, {456, 7392}, {457, 7393}, {458, 7394}, {459, 7395}, {460, 7396},
    {461, 7397}, {463, 5371}, {464, 5372}, {465, 5373}, {466, 5374}, {467, 5375},
    {468, 5376}, {469, 5377}, {470, 5378}, {471, 5379}, {472, 5380}, {473, 5381},
    {474, 5382}, {475, 5383}, {476, 5384}, {477, 4231}, {478, 4242}, {479, 4243},
    {480, 4241}, {481, 4240}, {482, 4239}, {483, 4238}, {484, 4237}, {485, 4232},
    {486, 4236}, {487, 4234}, {488, 4233}, {489, 4235}, {490, 4196}, {491, 4197},
    {492, 4198}, {493, 4199}, {494, 4200}, {495, 4201}, {496, 4202}, {497, 4203},
    {498, 4204}, {499, 4205}, {500, 4206}, {501, 4207}, {502, 4208}, {503, 13908},
    {504, 13879}, {505, 13880}, {506, 13881}, {507, 13882}, {508, 13883}, {509, 14574},
    {510, 13884}, {511, 14575}, {512, 13885}, {513, 14589}, {514, 14590}, {515, 14591},
    {516, 14592}, {517, 14593}, {518, 14594}, {519, 14595}, {520, 14596}, {521, 14597},
    {522, 14598}, {523, 14599}, {524, 14600}, {525, 14601}, {526, 14602}, {527, 14603},
    {528, 14604}, {529, 4158}, {530, 4159}, {531, 4160}, {532, 4161}, {533, 4162},
    {534, 4163}, {535, 4164}, {536, 4165}, {537, 4166}, {538, 13761}, {539, 13762},
    {540, 13746}, {541, 13747}, {542, 13748}, {543, 13749}, {544, 13750}, {545, 13751},
    {546, 13752}, {547, 13753}, {548, 13754}, {549, 13755}, {550, 13735}, {551, 13736},
    {552, 13737}, {553, 13738}, {554, 13739}, {555, 13740}, {556, 13741}, {557, 13742},
    {558, 13743}, {559, 13744}, {560, 13745}, {561, 13266}, {562, 13897}, {563, 13804},
    {564, 13805}, {565, 13806}, {566, 13807}, {567, 13808}, {568, 13809}, {569, 13810},
    {570, 13811}, {571, 13812}, {572, 13813}, {573, 13814}, {574, 13815}, {575, 13816},
    {576, 13801}, {577, 13802}, {578, 13803}, {579, 11919}, {580, 11920}, {581, 11921},
    {582, 11922}, {583, 11923}, {584, 11924}, {585, 11925}, {586, 1377}, {587, 1378},
    {588, 1379}, {589, 1380}, {590, 1381}, {591, 1382}, {592, 1383}, {593, 1384},
    {594, 1385}, {595, 1386}, {596, 1387}, {597, 1388}, {598, 1389}, {599, 1390},
    {600, 9794}, {601, 9795}, {602, 9796}, {603, 9797}, {604, 9798}, {605, 9799},
    {606, 9800}, {607, 9801}, {608, 9802}, {609, 9803}, {610, 9804}, {611, 9805},
    {612, 9806}, {613, 4103}, {614, 4112}, {615, 4105}, {616, 4109}, {617, 4110},
    {618, 4098}, {619, 4097}, {620, 4102}, {621, 4096}, {622, 4119}, {623, 4100},
    {624, 4101}, {625, 4107}, {626, 4108}, {627, 4099}, {628, 4104}, {629, 4106},
    {630, 4111}, {631, 4085}, {632, 4084}, {633, 4087}, {634, 4089}, {635, 4086},
    {636, 4088}, {637, 4094}, {638, 4090}, {639, 4092}, {640, 4091}, {641, 4093},
    {642, 4117}, {643, 4116}, {644, 4114}, {645, 4113}, {646, 4115}, {647, 9376},
    {648, 9377}, {649, 9378}, {650, 9379}, {651, 9380}, {652, 9381}, {653, 9382},
    {654, 9383}, {655, 9384}, {656, 9385}, {657, 9386}, {658, 9387}, {659, 9388},
    {660, 9824}, {661, 9825}, {662, 9826}, {663, 9827}, {664, 9828}, {665, 19211},
    {666, 19212}, {667, 19213}, {668, 6169}, {669, 6170}, {670, 6171}, {671, 6172},
    {672, 6173}, {673, 6174}, {674, 6175}, {675, 6176}, {676, 6177}, {677, 6178},
    {678, 6179}, {679, 6180}, {680, 6181}, {681, 786}, {682, 787}, {683, 788},
    {684, 789}, {685, 790}, {686, 662}, {687, 663}, {688, 9406}, {689, 9407},
    {690, 9408}, {691, 9409}, {692, 9410}, {693, 15446}, {694, 15447}, {695, 15448},
    {696, 15449}, {697, 1094}, {698, 1095}, {699, 1205}, {700, 1206}, {701, 781},
    {702, 780}, {703, 1231}, {704, 1230}, {705, 4359}, {706, 4360}, {707, 4361},
    {708, 16045}, {709, 16055}, {710, 4784}, {711, 4785}, {712, 4786}, {713, 4787},
    {714, 4788}, {715, 4789}, {716, 4790}, {717, 4791}, {718, 4792}, {719, 4793},
    {720, 4794}, {721, 4795}, {722, 14672}, {723, 14671}, {724, 1328}, {725, 1329},
    {726, 1330}, {727, 3154}, {728, 3153}, {729, 1997}, {730, 1991}, {731, 2001},
    {732, 1984}, {733, 1992}, {734, 2005}, {735, 1986}, {736, 2006}, {737, 1982},
    {738, 1998}, {739, 1987}, {740, 2003}, {741, 1999}, {742, 1980}, {743, 1995},
    {744, 1996}, {745, 1979}, {746, 1990}, {747, 1985}, {748, 2007}, {749, 1978},
    {750, 1981}, {751, 1993}, {752, 1983}, {753, 2002}, {754, 2008}, {755, 32423},
    {756, 32405}, {757, 1988}, {758, 2004}, {759, 1989}, {760, 9960}, {761, 5283},
    {762, 5286}, {763, 9966}, {764, 5275}, {765, 5284}, {766, 5287}, {767, 5291},
    {768, 10001}, {769, 5289}, {770, 9972}, {771, 5826}, {772, 5828}, {773, 9999},
    {774, 5285}, {775, 9990}, {776, 9975}, {777, 9984}, {778, 5822}, {779, 5283},
    {780, 2649}, {781, 5280}, {782, 9994}, {783, 9998}, {784, 9993}, {785, 10002},
    {786, 5828}, {787, 5281}, {788, 5273}, {789, 9992}, {790, 9969}, {791, 5830},
    {792, 10000}, {793, 9964}, {794, 9974}, {795, 9997}, {796, 5274}, {797, 5270},
    {798, 5272}, {799, 5292}, {800, 5278}, {801, 5288}, {802, 5271}, {803, 9980},
    {804, 9973}, {805, 9973}, {806, 9973}, {807, 9973}, {808, 9973}, {809, 9973},
    {810, 9973}, {811, 9973}, {812, 9973}, {813, 9973}, {814, 9973}, {815, 9973},
    {816, 9973}, {817, 9973}, {818, 9973}, {819, 9973}, {820, 9973}, {821, 9973},
    {822, 9973}, {823, 9973}, {824, 9973}, {825, 9973}, {826, 9973}, {827, 9973},
    {828, 9973}, {829, 9973}, {830, 9973}, {831, 9973}, {832, 9973}, {833, 9973},
    {834, 9973}, {835, 9973}, {836, 9973}, {837, 9973}, {838, 9973}, {839, 9973},
    {840, 9973}, {841, 9973}, {842, 9973}, {843, 9973}, {844, 9973}, {845, 9973},
    {846, 9973}, {847, 9973}, {848, 9973}, {849, 9973}, {850, 9973}, {851, 9973},
    {852, 9973}, {853, 9973}, {854, 9973}, {855, 9973}, {856, 9973}, {857, 9973},
    {858, 9973}, {859, 9973}, {860, 9973}, {861, 9973}, {862, 9973}, {863, 9973},
    {864, 9973}, {865, 9973}, {866, 9973}, {867, 9973}, {868, 9973}, {869, 9973},
    {870, 9973}, {871, 9973}, {872, 9973}, {873, 9973}, {874, 9973}, {875, 9973},
    {876, 9973}, {877, 16026}, {878, 16027}, {879, 16028}, {880, 16029}, {881, 16030},
    {882, 16031}, {883, 16032}, {884, 16033}, {885, 16034}, {886, 16035}, {887, 6101},
    {888, 6102}, {889, 6103}, {890, 1652}, {891, 1651}, {892, 1653}, {893, 9973},
    {894, 9973}, {895, 9973}, {896, 9973}, {897, 9973}, {898, 9973}, {899, 9973},
    {900, 9973}, {901, 9973}, {902, 9973}, {903, 9973}, {904, 9973}, {905, 12302},
    {906, 12308}, {907, 12304}, {908, 12306}, {909, 12303}, {910, 12301}, {911, 12307},
    {912, 791}, {913, 792}, {914, 2655}, {915, 2656}, {916, 2657}, {917, 676},
    {918, 677}, {919, 4859}, {920, 4862}, {921, 1975}, {922, 4861}, {923, 4863},
    {924, 4864}, {925, 4860}, {926, 4550}, {927, 4372}, {928, 4542}, {929, 4543},
    {930, 10493}, {931, 10494}, {932, 7712}, {933, 4544}, {934, 4548}, {935, 4545},
    {936, 7727}, {937, 7729}, {938, 4546}, {939, 10492}, {940, 4547}, {941, 4549},
    {942, 14641}, {943, 10488}, {944, 14647}, {945, 14643}, {946, 4702}, {947, 14645},
    {948, 14790}, {949, 14791}, {950, 14648}, {951, 14644}, {952, 14646}, {953, 4699},
    {954, 4700}, {955, 14630}, {956, 14642}, {957, 4701}, {958, 11292}, {959, 15056},
    {960, 14266}, {961, 14265}, {962, 11328}, {963, 15057}, {964, 10916}, {965, 11304},
    {966, 15055}, {967, 15058}, {968, 17510}, {969, 17509}, {970, 16699}, {971, 15630},
    {972, 15631}, {973, 15632}, {974, 15633}, {975, 15634}, {976, 15626}, {977, 15627},
    {978, 15635}, {979, 15636}, {980, 15638}, {981, 15628}, {982, 15629}, {983, 31949},
    {984, 31963}, {985, 31962}, {986, 31967}, {987, 31970}, {988, 31969}, {989, 31966},
    {990, 31965}, {991, 31961}, {992, 31964}, {993, 32154}, {994, 32131}, {995, 32132},
    {996, 32133}, {997, 32134}, {998, 32135}, {999, 32129}, {1000, 32136}, {1001, 32130},
    {1002, 32137}, {1003, 32138}, {1004, 32139}, {1005, 32144}, {1006, 32154}, {1007, 32404},
    {1008, 32171}, {1009, 100006}, {1010, 100007}, {1011, 9973}, {1012, 9973}, {1013, 32414},
    {1014, 32415}, {1015, 32416}, {1016, 32417}, {1017, 32418}, {1018, 32419}, {1019, 32420},
    {1020, 32421}, {1021, 100035}, {1022, 100034}, {1023, 100065}, {1024, 100066}, {1025, 100067},
    {1026, 100068}, {1027, 100069}, {1028, 100070}, {1029, 100071}, {1030, 100072}, {1031, 100073},
    {1032, 100074}, {1033, 100075}, {1034, 100076}, {1035, 9973}, {1036, 9973}, {1037, 9973},
    {1038, 9974}, {1039, 0}, {1040, 0}, {1041, 0}, {1042, 0}, {1043, 100077},
    {1044, 100078}, {1045, 100079}, {1046, 100101}, {1047, 100102}, {1048, 100103}, {1049, 100104},
    {1050, 100105}, {1051, 100106}, {1052, 100107}, {1053, 100108}, {1054, 100109}, {1055, 100110},
    {1056, 100111}, {1057, 100112}, {1058, 100113}, {1059, 9973}, {1060, 9973}, {1061, 9974},
    {1062, 100162}, {1063, 100163}, {1064, 100164}, {1065, 100165}, {1066, 100166}, {1067, 100167},
    {1068, 100170}, {1069, 100171}, {1070, 9973}, {1071, 9973}, {1072, 9974}, {1073, 100169},
    {1074, 9974}, {1075, 100189}, {1076, 9973}, {1085, 9974}
};

stock Market_GetAccessoryModelByCanonicalItem(item_id)
{
    for(new i = 0; i < sizeof(g_MarketAccessoryItemModels); i++)
    {
        if(g_MarketAccessoryItemModels[i][0] == item_id)
            return g_MarketAccessoryItemModels[i][1];
    }
    return -1;
}

stock Market_GetAccessoryCanonicalItemByStoredId(stored_item_id)
{
    if(stored_item_id <= 0 || stored_item_id == 22 || stored_item_id == 58 || stored_item_id == 134 || Inventory11_IsPlateItem(stored_item_id)) return -1;

    if(Inventory11_IsAccessoryItem(stored_item_id))
        return stored_item_id;

    if(Market_GetAccessoryModelByCanonicalItem(stored_item_id) > 0)
        return stored_item_id;

    for(new i = 0; i < sizeof(g_MarketAccessoryItemModels); i++)
    {
        if(g_MarketAccessoryItemModels[i][1] == stored_item_id)
            return g_MarketAccessoryItemModels[i][0];
    }
    return -1;
}

stock Market_GetAccessoryModelByStoredId(stored_item_id)
{
    if(Market_IsEncodedAccessoryItem(stored_item_id))
    {
        new acs_id = Market_DecodeAccessoryItem(stored_item_id);
        if(acs_id >= 0) return accessory[acs_id][ID_ACCESSORY];
        return -1;
    }

    new inventory_model = Inv11_GetAccModelByItem(stored_item_id);
    if(inventory_model > 0) return inventory_model;

    new model_id = Market_GetAccessoryModelByCanonicalItem(stored_item_id);
    if(model_id > 0) return model_id;

    if(Market_GetAccessoryCanonicalItemByStoredId(stored_item_id) > 0)
        return stored_item_id;

    return -1;
}

stock Market_GetSkinModelByStoredId(stored_count)
{
    if(stored_count > 0 && IsValidSkinModel(stored_count))
        return stored_count;

    for(new i = 0; i < sizeof(SkinMapping); i++)
    {
        if(SkinMapping[i][0] == stored_count)
            return SkinMapping[i][1];
        if(SkinMapping[i][1] == stored_count)
            return SkinMapping[i][1];
    }
    return -1;
}

stock Market_ResolveInventorySkinModel(playerid, slot, model_id, old_skin, source_internal_id)
{
    if(old_skin > 0 && IsValidSkinModel(old_skin))
        return old_skin;

    if(model_id > 0 && model_id != 134 && IsValidSkinModel(model_id))
        return model_id;

    for(new i = 0; i < sizeof(SkinMapping); i++)
    {
        if(SkinMapping[i][0] == source_internal_id)
            return SkinMapping[i][1];
        if(SkinMapping[i][1] == source_internal_id)
            return SkinMapping[i][1];
    }

    if(model_id > 0 && IsValidSkinModel(model_id))
        return model_id;

    if(source_internal_id > 0 && IsValidSkinModel(source_internal_id))
        return source_internal_id;

    new pvar_model = GetInventory11SkinModelByPos(playerid, slot);
    if(pvar_model > 0 && IsValidSkinModel(pvar_model))
        return pvar_model;

    return -1;
}

new g_MarketAccessoryItem[MAX_PLAYERS][MARKET_SOURCE_ACCESSORY_SLOTS];
new g_MarketAccessoryModel[MAX_PLAYERS][MARKET_SOURCE_ACCESSORY_SLOTS];
new g_MarketAccessoryBone[MAX_PLAYERS][MARKET_SOURCE_ACCESSORY_SLOTS];

new g_MarketOwnedAccessoryDbId[MAX_PLAYERS][MARKET_SOURCE_OWNED_ACCESSORY_MAX];
new g_MarketOwnedAccessoryAcsId[MAX_PLAYERS][MARKET_SOURCE_OWNED_ACCESSORY_MAX];
new g_MarketOwnedAccessoryItem[MAX_PLAYERS][MARKET_SOURCE_OWNED_ACCESSORY_MAX];
new g_MarketOwnedAccessoryModel[MAX_PLAYERS][MARKET_SOURCE_OWNED_ACCESSORY_MAX];
new g_MarketOwnedAccessoryUse[MAX_PLAYERS][MARKET_SOURCE_OWNED_ACCESSORY_MAX];

new g_MarketOwnedSkinKind[MAX_PLAYERS][MARKET_SOURCE_OWNED_SKIN_MAX];
new g_MarketOwnedSkinKey[MAX_PLAYERS][MARKET_SOURCE_OWNED_SKIN_MAX];
new g_MarketOwnedSkinModel[MAX_PLAYERS][MARKET_SOURCE_OWNED_SKIN_MAX];

stock Market_IsAccessoryInventoryItem(item_id)
{
    return Market_IsEncodedAccessoryItem(item_id) || Inventory11_IsAccessoryItem(item_id);
}

stock Market_TableExists(const table_name[])
{
    new query[128];
    mysql_format(mysql, query, sizeof(query), "SHOW TABLES LIKE '%e'", table_name);
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        printf("[MARKET][ERROR] table check failed table=%s errno=%d", table_name, mysql_errno());
        cache_delete(result);
        return 0;
    }
    new exists = cache_num_rows() > 0;
    cache_delete(result);
    return exists;
}

stock Market_HasInventorySkinModel(playerid, modelid)
{
    if(modelid <= 0) return 0;
    for(new slot = 0; slot < MAX_INVENTORY_SLOTS; slot++)
    {
        if(g_PlayerInventory[playerid][slot][inv_itemId] == 134 &&
            g_PlayerInventory[playerid][slot][inv_itemCount] == modelid) return 1;
    }
    return 0;
}

stock Market_HasOwnedSkinModel(playerid, modelid)
{
    if(modelid <= 0) return 0;
    for(new i = 0; i < MARKET_SOURCE_OWNED_SKIN_MAX; i++)
    {
        if(g_MarketOwnedSkinKind[playerid][i] != MARKET_SKIN_SOURCE_NONE &&
            g_MarketOwnedSkinModel[playerid][i] == modelid) return 1;
    }
    return 0;
}

stock Market_HasOwnedEquippedAccessory(playerid, acs_id)
{
    for(new i = 0; i < MARKET_SOURCE_OWNED_ACCESSORY_MAX; i++)
    {
        if(g_MarketOwnedAccessoryDbId[playerid][i] > 0 &&
            g_MarketOwnedAccessoryAcsId[playerid][i] == acs_id) return 1;
    }
    return 0;
}

stock Market_ClearAccessoryCache(playerid)
{
    Market_ClearInventoryCache(playerid);
    for(new i = 0; i < MARKET_SOURCE_ACCESSORY_SLOTS; i++)
    {
        g_MarketAccessoryItem[playerid][i] = 0;
        g_MarketAccessoryModel[playerid][i] = 0;
        g_MarketAccessoryBone[playerid][i] = 0;
    }
    for(new i = 0; i < MARKET_SOURCE_OWNED_ACCESSORY_MAX; i++)
    {
        g_MarketOwnedAccessoryDbId[playerid][i] = 0;
        g_MarketOwnedAccessoryAcsId[playerid][i] = -1;
        g_MarketOwnedAccessoryItem[playerid][i] = 0;
        g_MarketOwnedAccessoryModel[playerid][i] = 0;
        g_MarketOwnedAccessoryUse[playerid][i] = 0;
    }
    for(new i = 0; i < MARKET_SOURCE_OWNED_SKIN_MAX; i++)
    {
        g_MarketOwnedSkinKind[playerid][i] = MARKET_SKIN_SOURCE_NONE;
        g_MarketOwnedSkinKey[playerid][i] = 0;
        g_MarketOwnedSkinModel[playerid][i] = 0;
    }
    return 1;
}

stock Market_RefreshAccessoryCache(playerid)
{
    Market_ClearAccessoryCache(playerid);
    if(!IsPlayerLogged(playerid)) return 0;

    new account_id = GetPlayerAccountID(playerid);
    new query[384];
    mysql_format(mysql, query, sizeof(query),
        "SELECT `slot`,`item_id`,`model_id`,`amount`,`extra_1`,`source_internal_id`,`old_skin`,`sim`,`oldsim` FROM `inventory` WHERE `account_id`=%d ORDER BY `slot` ASC",
        account_id);

    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        printf("[MARKET][ERROR] inventory SELECT failed player=%d account=%d errno=%d query=%s",
            playerid, account_id, mysql_errno(), query);
        cache_delete(result);
        return 0;
    }
    new rows = cache_num_rows();

    for(new i = 0; i < rows; i++)
    {
        new slot = cache_get_field_content_int(i, "slot", mysql);
        if(slot <= 0 || slot >= MAX_INVENTORY_SLOTS) continue;

        new item_id = cache_get_field_content_int(i, "item_id", mysql);
        new model_id = cache_get_field_content_int(i, "model_id", mysql);
        new amount = cache_get_field_content_int(i, "amount", mysql);
        new extra_1 = cache_get_field_content_int(i, "extra_1", mysql);
        new source_internal_id = cache_get_field_content_int(i, "source_internal_id", mysql);
        new old_skin = cache_get_field_content_int(i, "old_skin", mysql);
        new sim = cache_get_field_content_int(i, "sim", mysql);
        new oldsim = cache_get_field_content_int(i, "oldsim", mysql);

        if(item_id == 134)
        {
            amount = Market_ResolveInventorySkinModel(playerid, slot, model_id, old_skin, source_internal_id);
            if(amount <= 0)
            {
                printf("[MARKET][WARN] unresolved skin player=%d account=%d slot=%d model=%d old_skin=%d source=%d",
                    playerid, account_id, slot, model_id, old_skin, source_internal_id);
                continue;
            }
        }
        else if(item_id == 58)
        {
            if(oldsim > 0) amount = oldsim;
            else if(sim > 0) amount = sim;
            else if(extra_1 > 0) amount = extra_1;
            else if(model_id > 0 && model_id != 58) amount = model_id;
            else if(amount <= 1) amount = 0;
        }
        else if(Inventory11_IsAccessoryItem(item_id))
            amount = 1;

        g_PlayerInventory[playerid][slot][inv_itemId] = item_id;
        g_PlayerInventory[playerid][slot][inv_itemCount] = amount > 0 ? amount : 1;
        g_PlayerInventory[playerid][slot][inv_itemSlot] = slot;
        g_PlayerInventory[playerid][slot][inv_itemActive] = false;
        GetItemName(item_id, g_PlayerInventory[playerid][slot][inv_itemName], 64);
        if(item_id == 58 && amount > 0)
            format(g_PlayerInventory[playerid][slot][inv_itemPlate], 32, "%d", amount);
        else if(Inventory11_IsPlateItem(item_id))
        {
            new plate_type = PlateCountryToType(PlateItemIdToCountry(item_id));
            new plate[16], region[8];
            if(Inventory11_GetPlateData(playerid, slot, plate_type, plate, sizeof(plate), region, sizeof(region)))
                BuildStoredPlateValue(plate_type, plate, region, g_PlayerInventory[playerid][slot][inv_itemPlate], 32);
        }
    }
    cache_delete(result);

    mysql_format(mysql, query, sizeof(query),
        "SELECT `id`,`acs_id`,`use` FROM `accessory_inventory` WHERE `player_id`=%d ORDER BY `id` ASC LIMIT %d",
        account_id, MARKET_SOURCE_OWNED_ACCESSORY_MAX);
    result = mysql_query(mysql, query, true);
    if(!mysql_errno())
    {
        rows = cache_num_rows();
        new owned_index = 0;
        for(new i = 0; i < rows && owned_index < MARKET_SOURCE_OWNED_ACCESSORY_MAX; i++)
        {
            new db_id = cache_get_field_content_int(i, "id", mysql);
            new acs_id = cache_get_field_content_int(i, "acs_id", mysql);
            new use_flag = cache_get_field_content_int(i, "use", mysql);
            if(db_id <= 0 || acs_id < 0 || acs_id >= sizeof(accessory)) continue;

            new model_id = accessory[acs_id][ID_ACCESSORY];
            new item_id = Market_EncodeAccessoryItem(acs_id);
            if(item_id <= 0 || model_id <= 0)
            {
                printf("[MARKET][WARN] invalid donate accessory player=%d db=%d acs=%d model=%d", playerid, db_id, acs_id, model_id);
                continue;
            }

            g_MarketOwnedAccessoryDbId[playerid][owned_index] = db_id;
            g_MarketOwnedAccessoryAcsId[playerid][owned_index] = acs_id;
            g_MarketOwnedAccessoryItem[playerid][owned_index] = item_id;
            g_MarketOwnedAccessoryModel[playerid][owned_index] = model_id;
            g_MarketOwnedAccessoryUse[playerid][owned_index] = use_flag;
            owned_index++;
        }
    }
    else
    {
        printf("[MARKET][ERROR] accessory_inventory SELECT failed player=%d account=%d errno=%d", playerid, account_id, mysql_errno());
    }
    cache_delete(result);

    mysql_format(mysql, query, sizeof(query),
        "SELECT `slot`,`acs_id`,`bone` FROM `accessories_players` WHERE `player_id`=%d AND `bone`>0 ORDER BY `slot` ASC",
        account_id);

    result = mysql_query(mysql, query, true);
    if(!mysql_errno())
    {
        rows = cache_num_rows();
        for(new i = 0; i < rows; i++)
        {
            new slot = cache_get_field_content_int(i, "slot", mysql);
            new acs_id = cache_get_field_content_int(i, "acs_id", mysql);
            new bone = cache_get_field_content_int(i, "bone", mysql);
            if(slot < 0 || slot >= MARKET_SOURCE_ACCESSORY_SLOTS) continue;
            if(acs_id < 0 || acs_id >= sizeof(accessory)) continue;
            if(Market_HasOwnedEquippedAccessory(playerid, acs_id)) continue;

            new model_id = accessory[acs_id][ID_ACCESSORY];
            new item_id = Market_EncodeAccessoryItem(acs_id);
            if(item_id <= 0 || model_id <= 0) continue;

            g_MarketAccessoryItem[playerid][slot] = item_id;
            g_MarketAccessoryModel[playerid][slot] = model_id;
            g_MarketAccessoryBone[playerid][slot] = bone;
        }
    }
    else
    {
        printf("[MARKET][ERROR] accessories_players SELECT failed player=%d account=%d errno=%d", playerid, account_id, mysql_errno());
    }
    cache_delete(result);

    if(Market_TableExists("invskins"))
    {
        mysql_format(mysql, query, sizeof(query),
            "SELECT `internal_id`,`modelid` FROM `invskins` WHERE `account_id`=%d ORDER BY `purchased_at` DESC LIMIT %d",
            account_id, MARKET_SOURCE_OWNED_SKIN_MAX);
        result = mysql_query(mysql, query, true);
        if(!mysql_errno())
        {
            rows = cache_num_rows();
            new skin_index = 0;
            for(new i = 0; i < rows && skin_index < MARKET_SOURCE_OWNED_SKIN_MAX; i++)
            {
                new internal_id = cache_get_field_content_int(i, "internal_id", mysql);
                new modelid = cache_get_field_content_int(i, "modelid", mysql);
                if(modelid <= 0 || !IsValidSkinModel(modelid)) continue;
                if(Market_HasInventorySkinModel(playerid, modelid) || Market_HasOwnedSkinModel(playerid, modelid)) continue;

                g_MarketOwnedSkinKind[playerid][skin_index] = MARKET_SKIN_SOURCE_INVSKINS;
                g_MarketOwnedSkinKey[playerid][skin_index] = internal_id;
                g_MarketOwnedSkinModel[playerid][skin_index] = modelid;
                skin_index++;
            }
        }
        else printf("[MARKET][ERROR] invskins SELECT failed player=%d account=%d errno=%d", playerid, account_id, mysql_errno());
        cache_delete(result);
    }

    if(Market_TableExists("inventory_skins"))
    {
        mysql_format(mysql, query, sizeof(query),
            "SELECT `id`,`skin_id` FROM `inventory_skins` WHERE `owner_skin`=%d ORDER BY `id` ASC LIMIT %d",
            account_id, MARKET_SOURCE_OWNED_SKIN_MAX);
        result = mysql_query(mysql, query, true);
        if(!mysql_errno())
        {
            rows = cache_num_rows();
            for(new i = 0; i < rows; i++)
            {
                new db_id = cache_get_field_content_int(i, "id", mysql);
                new modelid = cache_get_field_content_int(i, "skin_id", mysql);
                if(db_id <= 0 || modelid <= 0 || !IsValidSkinModel(modelid)) continue;
                if(Market_HasInventorySkinModel(playerid, modelid) || Market_HasOwnedSkinModel(playerid, modelid)) continue;

                for(new skin_index = 0; skin_index < MARKET_SOURCE_OWNED_SKIN_MAX; skin_index++)
                {
                    if(g_MarketOwnedSkinKind[playerid][skin_index] != MARKET_SKIN_SOURCE_NONE) continue;
                    g_MarketOwnedSkinKind[playerid][skin_index] = MARKET_SKIN_SOURCE_INVENTORY_SKINS;
                    g_MarketOwnedSkinKey[playerid][skin_index] = db_id;
                    g_MarketOwnedSkinModel[playerid][skin_index] = modelid;
                    break;
                }
            }
        }
        else printf("[MARKET][ERROR] inventory_skins SELECT failed player=%d account=%d errno=%d", playerid, account_id, mysql_errno());
        cache_delete(result);
    }

    return 1;
}

stock Market_IsAccessorySource(source_id)
{
    return source_id >= MARKET_SOURCE_ACCESSORY_BASE && source_id < (MARKET_SOURCE_ACCESSORY_BASE + MARKET_SOURCE_ACCESSORY_SLOTS);
}

stock Market_MakeAccessorySource(accessory_slot)
{
    return MARKET_SOURCE_ACCESSORY_BASE + accessory_slot;
}

stock Market_GetAccessorySlotFromSource(source_id)
{
    if(!Market_IsAccessorySource(source_id)) return -1;
    return source_id - MARKET_SOURCE_ACCESSORY_BASE;
}

stock Market_IsOwnedAccessorySource(source_id)
{
    return source_id >= MARKET_SOURCE_OWNED_ACCESSORY_BASE && source_id < (MARKET_SOURCE_OWNED_ACCESSORY_BASE + MARKET_SOURCE_OWNED_ACCESSORY_MAX);
}

stock Market_MakeOwnedAccessorySource(index)
{
    return MARKET_SOURCE_OWNED_ACCESSORY_BASE + index;
}

stock Market_GetOwnedAccessoryIndex(source_id)
{
    if(!Market_IsOwnedAccessorySource(source_id)) return -1;
    return source_id - MARKET_SOURCE_OWNED_ACCESSORY_BASE;
}

stock Market_IsOwnedSkinSource(source_id)
{
    return source_id >= MARKET_SOURCE_OWNED_SKIN_BASE && source_id < (MARKET_SOURCE_OWNED_SKIN_BASE + MARKET_SOURCE_OWNED_SKIN_MAX);
}

stock Market_MakeOwnedSkinSource(index)
{
    return MARKET_SOURCE_OWNED_SKIN_BASE + index;
}

stock Market_GetOwnedSkinIndex(source_id)
{
    if(!Market_IsOwnedSkinSource(source_id)) return -1;
    return source_id - MARKET_SOURCE_OWNED_SKIN_BASE;
}

stock Market_GetAccessoryModelFromSource(playerid, source_id)
{
    if(Market_IsOwnedAccessorySource(source_id))
    {
        new index = Market_GetOwnedAccessoryIndex(source_id);
        return g_MarketOwnedAccessoryModel[playerid][index];
    }

    if(Market_IsAccessorySource(source_id))
    {
        new accessory_slot = Market_GetAccessorySlotFromSource(source_id);
        return g_MarketAccessoryModel[playerid][accessory_slot];
    }

    if(source_id < 0 || source_id >= MAX_INVENTORY_SLOTS) return -1;
    new item_id = g_PlayerInventory[playerid][source_id][inv_itemId];
    new model_id = Market_GetAccessoryModelByStoredId(item_id);
    if(model_id <= 0) model_id = Inv11_GetAccModelByItem(item_id);
    return model_id;
}

stock Market_IsSingleInventoryEntity(item_id)
{
    switch(item_id)
    {
        case 58, 59, 81, 82, 83, 134: return 1;
    }
    return Market_IsEncodedAccessoryItem(item_id) || Inventory11_IsAccessoryItem(item_id);
}

stock Market_IsSellableInventoryItem(item_id)
{
    if(item_id == 22 || item_id == 58 || item_id == 134) return 1;
    if(Inventory11_IsPlateItem(item_id)) return 1;
    return Market_IsAccessoryInventoryItem(item_id);
}

stock Market_IsActiveSource(source_id)
{
    return source_id >= MARKET_SOURCE_ACTIVE_BASE && source_id < (MARKET_SOURCE_ACTIVE_BASE + MAX_ACTIVE_SLOTS);
}

stock Market_MakeActiveSource(active_slot)
{
    return MARKET_SOURCE_ACTIVE_BASE + active_slot;
}

stock Market_GetActiveSlotFromSource(source_id)
{
    if(!Market_IsActiveSource(source_id)) return -1;
    return source_id - MARKET_SOURCE_ACTIVE_BASE;
}

stock Market_GetSourceItemId(playerid, source_id)
{
    if(Market_IsOwnedAccessorySource(source_id))
    {
        new index = Market_GetOwnedAccessoryIndex(source_id);
        return g_MarketOwnedAccessoryItem[playerid][index];
    }

    if(Market_IsOwnedSkinSource(source_id))
    {
        new index = Market_GetOwnedSkinIndex(source_id);
        return (g_MarketOwnedSkinKind[playerid][index] != MARKET_SKIN_SOURCE_NONE) ? 134 : 0;
    }

    if(Market_IsAccessorySource(source_id))
    {
        new accessory_slot = Market_GetAccessorySlotFromSource(source_id);
        return g_MarketAccessoryItem[playerid][accessory_slot];
    }

    if(Market_IsActiveSource(source_id))
    {
        new active_slot = Market_GetActiveSlotFromSource(source_id);
        new item_id = g_PlayerActiveSlots[playerid][active_slot][inv_itemId];

        if(active_slot == SIM_SLOT && item_id != 58 && GetPlayerData(playerid, P_PHONE) > 0)
            return 58;

        if(active_slot == SKIN_SLOT && item_id != 58)
            return 0;

        return item_id;
    }

    if(source_id < 0 || source_id >= MAX_INVENTORY_SLOTS) return 0;

    new stored_item_id = g_PlayerInventory[playerid][source_id][inv_itemId];
    return stored_item_id;
}

stock Market_GetSourceItemCount(playerid, source_id)
{
    if(Market_IsOwnedAccessorySource(source_id)) return 1;
    if(Market_IsOwnedSkinSource(source_id))
    {
        new index = Market_GetOwnedSkinIndex(source_id);
        return g_MarketOwnedSkinModel[playerid][index];
    }
    if(Market_IsAccessorySource(source_id)) return 1;

    if(Market_IsActiveSource(source_id))
    {
        new active_slot = Market_GetActiveSlotFromSource(source_id);
        new item_id = Market_GetSourceItemId(playerid, source_id);
        new stored_count = g_PlayerActiveSlots[playerid][active_slot][inv_itemCount];

        if(item_id == 58 && stored_count <= 0) return GetPlayerData(playerid, P_PHONE);
        if(item_id == 134)
        {
            stored_count = GetPlayerData(playerid, P_SKIN);
            if(stored_count <= 0 || !IsValidSkinModel(stored_count)) stored_count = GetPlayerSkin(playerid);
        }
        return stored_count;
    }

    if(source_id < 0 || source_id >= MAX_INVENTORY_SLOTS) return 0;
    return g_PlayerInventory[playerid][source_id][inv_itemCount];
}

stock Market_GetSourcePlate(playerid, source_id, plate[], plate_size)
{
    plate[0] = EOS;

    if(Market_IsOwnedAccessorySource(source_id) || Market_IsOwnedSkinSource(source_id) || Market_IsAccessorySource(source_id)) return 1;

    if(Market_IsActiveSource(source_id))
    {
        new active_slot = Market_GetActiveSlotFromSource(source_id);
        format(plate, plate_size, "%s", g_PlayerActiveSlots[playerid][active_slot][inv_itemPlate]);

        if(active_slot == SIM_SLOT && !strlen(plate) && GetPlayerData(playerid, P_PHONE) > 0)
            format(plate, plate_size, "%d", GetPlayerData(playerid, P_PHONE));
        return 1;
    }

    if(source_id < 0 || source_id >= MAX_INVENTORY_SLOTS) return 0;
    format(plate, plate_size, "%s", g_PlayerInventory[playerid][source_id][inv_itemPlate]);
    return 1;
}

stock Market_FindReplacementSkinSlot(playerid)
{
    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
    {
        if(g_PlayerInventory[playerid][i][inv_itemId] == 134 && g_PlayerInventory[playerid][i][inv_itemCount] > 0)
            return i;
    }
    return -1;
}

stock Market_CanSellSource(playerid, source_id)
{
    if(Market_IsOwnedAccessorySource(source_id))
    {
        new index = Market_GetOwnedAccessoryIndex(source_id);
        return g_MarketOwnedAccessoryDbId[playerid][index] > 0 &&
               g_MarketOwnedAccessoryItem[playerid][index] > 0 &&
               g_MarketOwnedAccessoryModel[playerid][index] > 0;
    }

    if(Market_IsOwnedSkinSource(source_id))
    {
        new index = Market_GetOwnedSkinIndex(source_id);
        new modelid = g_MarketOwnedSkinModel[playerid][index];
        if(g_MarketOwnedSkinKind[playerid][index] == MARKET_SKIN_SOURCE_NONE || modelid <= 0 || !IsValidSkinModel(modelid)) return 0;

        new current_skin = GetPlayerData(playerid, P_SKIN);
        if(current_skin <= 0) current_skin = GetPlayerSkin(playerid);
        if(modelid == current_skin) return 0;
        return 1;
    }

    new item_id = Market_GetSourceItemId(playerid, source_id);
    if(!Market_IsSellableInventoryItem(item_id)) return 0;

    if(item_id == 134)
    {
        new source_model = Market_GetSourceItemCount(playerid, source_id);
        new current_skin = GetPlayerData(playerid, P_SKIN);
        if(current_skin <= 0) current_skin = GetPlayerSkin(playerid);
        if(source_model > 0 && source_model == current_skin) return 0;
    }

    if(item_id == 58 && Market_GetSourceItemCount(playerid, source_id) <= 0)
        return 0;

    if(Inventory11_IsPlateItem(item_id))
    {
        new stored_plate[32];
        Market_GetSourcePlate(playerid, source_id, stored_plate, sizeof(stored_plate));
        new plate_type, plate_number[16], plate_region[8];
        if(!ParseStoredPlateValue(stored_plate, plate_type, plate_number, sizeof(plate_number), plate_region, sizeof(plate_region)))
            return 0;
    }

    if(Market_IsAccessorySource(source_id))
        return Market_GetAccessoryModelFromSource(playerid, source_id) > 0;

    if(Market_IsActiveSource(source_id))
    {
        if(item_id != 58) return 0;
    }

    return 1;
}

stock Market_ClearActiveSlotData(playerid, active_slot)
{
    g_PlayerActiveSlots[playerid][active_slot][inv_itemId] = 0;
    g_PlayerActiveSlots[playerid][active_slot][inv_itemCount] = 0;
    g_PlayerActiveSlots[playerid][active_slot][inv_itemSlot] = active_slot;
    g_PlayerActiveSlots[playerid][active_slot][inv_itemPlate][0] = EOS;
    g_PlayerActiveSlots[playerid][active_slot][inv_itemType] = 0;
    g_PlayerActiveSlots[playerid][active_slot][inv_itemWeight] = 0;
    g_PlayerActiveSlots[playerid][active_slot][inv_itemName][0] = EOS;
    g_PlayerActiveSlots[playerid][active_slot][inv_itemActive] = false;
    g_PlayerActiveSlots[playerid][active_slot][inv_activeSlot] = -1;
    return 1;
}

stock Market_DeleteInventorySlot(playerid, slot)
{
    if(slot < 0 || slot >= MAX_INVENTORY_SLOTS) return 0;
    if(g_PlayerInventory[playerid][slot][inv_itemId] <= 0) return 0;

    new original_item_id = g_PlayerInventory[playerid][slot][inv_itemId];
    new original_count = g_PlayerInventory[playerid][slot][inv_itemCount];
    new stored_count = original_count;
    if(Market_IsSingleInventoryEntity(original_item_id))
        g_PlayerInventory[playerid][slot][inv_itemCount] = 1;

    new result = Inventory_DeleteItem(playerid, slot);
    if(!result)
    {
        g_PlayerInventory[playerid][slot][inv_itemCount] = stored_count;
        return 0;
    }

    if(original_item_id == 134 && original_count > 0 && Market_TableExists("invskins"))
    {
        new query[256];
        mysql_format(mysql, query, sizeof(query),
            "DELETE FROM `invskins` WHERE `account_id`=%d AND `modelid`=%d LIMIT 1",
            GetPlayerAccountID(playerid), original_count);
        mysql_query(mysql, query, false);
        if(mysql_errno())
            printf("[MARKET][WARN] mirrored invskins cleanup failed player=%d model=%d errno=%d", playerid, original_count, mysql_errno());
    }
    return 1;
}

stock Market_DeleteActiveSource(playerid, active_slot)
{
    if(active_slot < 0 || active_slot >= MAX_ACTIVE_SLOTS) return 0;

    new source_id = Market_MakeActiveSource(active_slot);
    new item_id = Market_GetSourceItemId(playerid, source_id);
    if(item_id != 58 && item_id != 134) return 0;

    new query[320];

    if(item_id == 134)
    {
        new replacement_slot = Market_FindReplacementSkinSlot(playerid);
        if(replacement_slot == -1) return 0;

        new replacement_model = g_PlayerInventory[playerid][replacement_slot][inv_itemCount];
        if(replacement_model <= 0 || !IsValidSkinModel(replacement_model)) return 0;
        if(!Market_DeleteInventorySlot(playerid, replacement_slot)) return 0;

        g_PlayerActiveSlots[playerid][active_slot][inv_itemId] = 134;
        g_PlayerActiveSlots[playerid][active_slot][inv_itemCount] = replacement_model;
        g_PlayerActiveSlots[playerid][active_slot][inv_itemType] = ITEM_TYPE_SKIN;
        g_PlayerActiveSlots[playerid][active_slot][inv_itemWeight] = GetItemWeight(134);
        GetItemName(134, g_PlayerActiveSlots[playerid][active_slot][inv_itemName], 64);
        g_PlayerActiveSlots[playerid][active_slot][inv_itemActive] = true;
        g_PlayerActiveSlots[playerid][active_slot][inv_activeSlot] = active_slot;

        SetPlayerSkin(playerid, replacement_model);
        SetPlayerData(playerid, P_SKIN, replacement_model);
        UpdatePlayerDatabaseInt(playerid, "skin", replacement_model);

        mysql_format(mysql, query, sizeof(query),
            "DELETE FROM `player_inventory` WHERE `player_id`=%d AND `is_active`=1 AND `active_slot`=%d",
            GetPlayerAccountID(playerid), active_slot);
        mysql_tquery(mysql, query);

        mysql_format(mysql, query, sizeof(query),
            "INSERT INTO `player_inventory` (`player_id`,`slot`,`item_id`,`item_count`,`item_plate`,`is_active`,`active_slot`) VALUES (%d,%d,134,%d,'',1,%d)",
            GetPlayerAccountID(playerid), active_slot, replacement_model, active_slot);
        mysql_tquery(mysql, query);
        return 1;
    }

    if(item_id == 58)
    {
        if(g_PlayerActiveSlots[playerid][active_slot][inv_itemId] == 58)
            Market_ClearActiveSlotData(playerid, active_slot);

        SetPlayerData(playerid, P_PHONE, 0);
        UpdatePlayerDatabaseInt(playerid, "phone", 0);

        mysql_format(mysql, query, sizeof(query),
            "DELETE FROM `player_inventory` WHERE `player_id`=%d AND `is_active`=1 AND `active_slot`=%d AND `item_id`=58",
            GetPlayerAccountID(playerid), active_slot);
        mysql_tquery(mysql, query);
        return 1;
    }


    return 0;
}

stock Market_DeleteAccessorySource(playerid, accessory_slot)
{
    if(accessory_slot < 0 || accessory_slot >= MARKET_SOURCE_ACCESSORY_SLOTS) return 0;
    if(g_MarketAccessoryItem[playerid][accessory_slot] <= 0) return 0;

    RemovePlayerAttachedObject(playerid, accessory_slot);
    new accessory_item_id = g_MarketAccessoryItem[playerid][accessory_slot];
    if(accessory_slot < MAX_ACTIVE_SLOTS && g_PlayerActiveSlots[playerid][accessory_slot][inv_itemId] == accessory_item_id)
        Market_ClearActiveSlotData(playerid, accessory_slot);

    new query[320];
    mysql_format(mysql, query, sizeof(query),
        "DELETE FROM `accessories_players` WHERE `player_id`=%d AND `slot`=%d LIMIT 1",
        GetPlayerAccountID(playerid), accessory_slot);
    new Cache:delete_result = mysql_query(mysql, query, true);
    new deleted = cache_affected_rows(mysql);
    cache_delete(delete_result);
    if(!deleted) return 0;

    g_MarketAccessoryItem[playerid][accessory_slot] = 0;
    g_MarketAccessoryModel[playerid][accessory_slot] = 0;
    g_MarketAccessoryBone[playerid][accessory_slot] = 0;
    return 1;
}

stock Market_DeleteOwnedAccessorySource(playerid, index)
{
    if(index < 0 || index >= MARKET_SOURCE_OWNED_ACCESSORY_MAX) return 0;
    new db_id = g_MarketOwnedAccessoryDbId[playerid][index];
    new acs_id = g_MarketOwnedAccessoryAcsId[playerid][index];
    new use_flag = g_MarketOwnedAccessoryUse[playerid][index];
    if(db_id <= 0 || acs_id < 0) return 0;

    new query[320];
    mysql_format(mysql, query, sizeof(query),
        "DELETE FROM `accessory_inventory` WHERE `id`=%d AND `player_id`=%d LIMIT 1",
        db_id, GetPlayerAccountID(playerid));
    new Cache:delete_result = mysql_query(mysql, query, true);
    new deleted = cache_affected_rows(mysql);
    new delete_errno = mysql_errno();
    cache_delete(delete_result);
    if(delete_errno || !deleted)
    {
        printf("[MARKET][ERROR] owned accessory delete failed player=%d db=%d errno=%d", playerid, db_id, delete_errno);
        return 0;
    }

    if(use_flag > 0)
    {
        mysql_format(mysql, query, sizeof(query),
            "SELECT `slot` FROM `accessories_players` WHERE `player_id`=%d AND `acs_id`=%d",
            GetPlayerAccountID(playerid), acs_id);
        new Cache:equipped = mysql_query(mysql, query, true);
        if(!mysql_errno())
        {
            new rows = cache_num_rows();
            for(new i = 0; i < rows; i++)
            {
                new slot = cache_get_field_content_int(i, "slot", mysql);
                if(slot >= 0 && slot < MARKET_SOURCE_ACCESSORY_SLOTS) RemovePlayerAttachedObject(playerid, slot);
            }
        }
        cache_delete(equipped);

        mysql_format(mysql, query, sizeof(query),
            "DELETE FROM `accessories_players` WHERE `player_id`=%d AND `acs_id`=%d",
            GetPlayerAccountID(playerid), acs_id);
        mysql_query(mysql, query, false);
    }

    g_MarketOwnedAccessoryDbId[playerid][index] = 0;
    g_MarketOwnedAccessoryAcsId[playerid][index] = -1;
    g_MarketOwnedAccessoryItem[playerid][index] = 0;
    g_MarketOwnedAccessoryModel[playerid][index] = 0;
    g_MarketOwnedAccessoryUse[playerid][index] = 0;
    return 1;
}

stock Market_DeleteOwnedSkinSource(playerid, index)
{
    if(index < 0 || index >= MARKET_SOURCE_OWNED_SKIN_MAX) return 0;
    new kind = g_MarketOwnedSkinKind[playerid][index];
    new key = g_MarketOwnedSkinKey[playerid][index];
    new modelid = g_MarketOwnedSkinModel[playerid][index];
    if(kind == MARKET_SKIN_SOURCE_NONE || modelid <= 0) return 0;

    new current_skin = GetPlayerData(playerid, P_SKIN);
    if(current_skin <= 0) current_skin = GetPlayerSkin(playerid);
    if(modelid == current_skin) return 0;

    new query[320];
    if(kind == MARKET_SKIN_SOURCE_INVSKINS)
    {
        mysql_format(mysql, query, sizeof(query),
            "DELETE FROM `invskins` WHERE `account_id`=%d AND `internal_id`=%d LIMIT 1",
            GetPlayerAccountID(playerid), key);
    }
    else if(kind == MARKET_SKIN_SOURCE_INVENTORY_SKINS)
    {
        mysql_format(mysql, query, sizeof(query),
            "DELETE FROM `inventory_skins` WHERE `id`=%d AND `owner_skin`=%d LIMIT 1",
            key, GetPlayerAccountID(playerid));
    }
    else return 0;

    new Cache:delete_result = mysql_query(mysql, query, true);
    new deleted = cache_affected_rows(mysql);
    new delete_errno = mysql_errno();
    cache_delete(delete_result);
    if(delete_errno || !deleted)
    {
        printf("[MARKET][ERROR] owned skin delete failed player=%d kind=%d key=%d model=%d errno=%d", playerid, kind, key, modelid, delete_errno);
        return 0;
    }

    g_MarketOwnedSkinKind[playerid][index] = MARKET_SKIN_SOURCE_NONE;
    g_MarketOwnedSkinKey[playerid][index] = 0;
    g_MarketOwnedSkinModel[playerid][index] = 0;
    return 1;
}

stock Market_DeleteSource(playerid, source_id)
{
    if(Market_IsOwnedAccessorySource(source_id))
        return Market_DeleteOwnedAccessorySource(playerid, Market_GetOwnedAccessoryIndex(source_id));

    if(Market_IsOwnedSkinSource(source_id))
        return Market_DeleteOwnedSkinSource(playerid, Market_GetOwnedSkinIndex(source_id));

    if(Market_IsAccessorySource(source_id))
        return Market_DeleteAccessorySource(playerid, Market_GetAccessorySlotFromSource(source_id));

    if(Market_IsActiveSource(source_id))
        return Market_DeleteActiveSource(playerid, Market_GetActiveSlotFromSource(source_id));

    return Market_DeleteInventorySlot(playerid, source_id);
}

#define MARKET_GUI_ID MARKETPLACE_GUI_ID

stock Marketplace_Init()
{
    return Marketplace_OnGameModeInit();
}

stock Market_ResetPlayer(playerid)
{
    Market_ClearAccessoryCache(playerid);
    Marketplace_ResetPlayer(playerid);
    MPReward_ResetPlayer(playerid);
    return 1;
}

stock Market_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    return Marketplace_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
}

stock Market_OnPacket(playerid, Node:json)
{
    return Marketplace_OnPacket(playerid, json);
}

stock Market_Open(playerid)
{
    return Marketplace_OpenGUI(playerid);
}


#if defined _sander_marketplace_reward_included
    #endinput
#endif
#define _sander_marketplace_reward_included

#define MARKETPLACE_REWARD_CASE_ID       (100)
#define MP_REWARD_GUI_ID                  (74)
#define MP_REWARD_PAGE_SIZE               (12)

#define REWARD_GUI_MODE_NONE                 (0)
#define REWARD_GUI_MODE_BPR                  (1)
#define REWARD_GUI_MODE_MARKETPLACE          (2)
#define REWARD_GUI_MODE_PVAR                 "reward_gui_mode"

forward MPReward_OnGuiListLoaded(playerid, packet_type, offset);

stock MPReward_ResetPlayer(playerid)
{
    SetPVarInt(playerid, "mpreward_offset", 0);
    SetPVarInt(playerid, REWARD_GUI_MODE_PVAR, REWARD_GUI_MODE_NONE);
    return 1;
}

stock MPReward_CreateTables()
{
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `marketplace_reward_items` (`id` INT NOT NULL AUTO_INCREMENT, `account_id` INT NOT NULL, `item_id` INT NOT NULL, `item_count` INT NOT NULL DEFAULT 1, `item_plate` VARCHAR(32) NOT NULL DEFAULT '', `item_name` VARCHAR(64) NOT NULL DEFAULT '', `source_lot` INT NOT NULL DEFAULT 0, `created_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`), KEY `account_id` (`account_id`), KEY `source_lot` (`source_lot`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `rewards` (`id` INT NOT NULL AUTO_INCREMENT, `uid` INT NOT NULL, `award_id` INT NOT NULL, `case_id` INT NOT NULL, PRIMARY KEY (`id`), KEY `uid_idx` (`uid`), KEY `case_idx` (`case_id`,`award_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    return 1;
}

stock Market_GiveEncodedAccessory(playerid, item_id)
{
    if(!IsPlayerLogged(playerid) || !Market_IsEncodedAccessoryItem(item_id)) return 0;

    new acs_id = Market_DecodeAccessoryItem(item_id);
    if(acs_id < 0 || accessory[acs_id][ID_ACCESSORY] <= 0) return 0;

    new query[224];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `accessory_inventory` (`player_id`,`acs_id`) VALUES (%d,%d)",
        GetPlayerAccountID(playerid), acs_id);

    new Cache:result = mysql_query(mysql, query, true);
    new insert_errno = mysql_errno();
    new inserted_id = cache_insert_id();
    cache_delete(result);

    if(insert_errno || inserted_id <= 0)
    {
        printf("[MARKET][ERROR] exact accessory give failed player=%d item=%d acs=%d errno=%d",
            playerid, item_id, acs_id, insert_errno);
        return 0;
    }

    Market_RefreshAccessoryCache(playerid);
    return inserted_id;
}

stock Market_DeleteGivenEncodedAccessory(playerid, db_id)
{
    if(db_id <= 0) return 0;
    new query[192];
    mysql_format(mysql, query, sizeof(query),
        "DELETE FROM `accessory_inventory` WHERE `id`=%d AND `player_id`=%d LIMIT 1",
        db_id, GetPlayerAccountID(playerid));
    new Cache:result = mysql_query(mysql, query, true);
    new affected = cache_affected_rows(mysql);
    cache_delete(result);
    Market_RefreshAccessoryCache(playerid);
    return affected > 0;
}

stock MPReward_QueueInvItem(account_id, item_id, item_count, const item_plate[], const item_name[], source_lot = 0)
{
    if(account_id <= 0 || item_id <= 0) return 0;
    if(item_count <= 0) item_count = 1;

    new query[768];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `marketplace_reward_items` (`account_id`,`item_id`,`item_count`,`item_plate`,`item_name`,`source_lot`,`created_at`) VALUES (%d,%d,%d,'%e','%e',%d,%d)",
        account_id, item_id, item_count, item_plate, item_name, source_lot, gettime());

    new Cache:insert_cache = mysql_query(mysql, query, true);
    new reward_item_id = cache_insert_id();
    cache_delete(insert_cache);
    if(reward_item_id <= 0) return 0;

    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `rewards` (`uid`,`award_id`,`case_id`) VALUES (%d,%d,%d)",
        account_id, reward_item_id, MARKETPLACE_REWARD_CASE_ID);

    new Cache:reward_cache = mysql_query(mysql, query, true);
    new reward_db_id = cache_insert_id();
    cache_delete(reward_cache);

    if(reward_db_id <= 0)
    {
        mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_reward_items` WHERE `id`=%d LIMIT 1", reward_item_id);
        mysql_tquery(mysql, query);
        return 0;
    }
    return reward_item_id;
}

stock MPReward_GetInvItemData(reward_item_id, &item_id, &item_count, item_plate[], plate_len, item_name[], name_len)
{
    if(reward_item_id <= 0) return 0;

    new query[192];
    mysql_format(mysql, query, sizeof(query),
        "SELECT `item_id`,`item_count`,`item_plate`,`item_name` FROM `marketplace_reward_items` WHERE `id`=%d LIMIT 1",
        reward_item_id);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        return 0;
    }

    item_id = cache_get_field_content_int(0, "item_id", mysql);
    item_count = cache_get_field_content_int(0, "item_count", mysql);
    cache_get_field_content(0, "item_plate", item_plate, mysql, plate_len);
    cache_get_field_content(0, "item_name", item_name, mysql, name_len);
    cache_delete(result);

    if(item_count <= 0) item_count = 1;
    if(item_name[0] == EOS) GetItemName(item_id, item_name, name_len);
    return 1;
}

stock MPReward_DelInvItemData(reward_item_id)
{
    if(reward_item_id <= 0) return 0;

    new query[256];
    mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_reward_items` WHERE `id`=%d LIMIT 1", reward_item_id);
    new Cache:item_result = mysql_query(mysql, query, true);
    new removed = cache_affected_rows(mysql);
    cache_delete(item_result);
    if(!removed) return 0;

    mysql_format(mysql, query, sizeof(query), "DELETE FROM `rewards` WHERE `award_id`=%d AND `case_id`=%d", reward_item_id, MARKETPLACE_REWARD_CASE_ID);
    mysql_tquery(mysql, query);
    return 1;
}

stock bool:MPReward_GetCaseAwardData(award_index, &award_type, &internal_id, &award_count, award_name[], name_size, &spray_price)
{
    new plate[32];
    if(!MPReward_GetInvItemData(award_index, internal_id, award_count, plate, sizeof(plate), award_name, name_size)) return false;

    award_type = 11;
    spray_price = 0;
    return true;
}

stock MPReward_GiveToPlayer(playerid, reward_item_id)
{
    if(!IsPlayerLogged(playerid) || reward_item_id <= 0) return 0;

    new query[256];
    mysql_format(mysql, query, sizeof(query),
        "SELECT `item_id`,`item_count`,`item_plate`,`item_name` FROM `marketplace_reward_items` WHERE `id`=%d AND `account_id`=%d LIMIT 1",
        reward_item_id, GetPlayerAccountID(playerid));

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        return 0;
    }

    new item_id = cache_get_field_content_int(0, "item_id", mysql);
    new item_count = cache_get_field_content_int(0, "item_count", mysql);
    new item_plate[32], item_name[64];
    cache_get_field_content(0, "item_plate", item_plate, mysql, sizeof(item_plate));
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));
    cache_delete(result);

    if(item_count <= 0) item_count = 1;

    new free_slot = -1;
    new exact_accessory_db = 0;

    if(Market_IsEncodedAccessoryItem(item_id))
    {
        exact_accessory_db = Market_GiveEncodedAccessory(playerid, item_id);
        if(exact_accessory_db <= 0)
        {
            ShowNotificationSile(playerid, 2, 5, -1, -1, "Не удалось вернуть аксессуар. Награда осталась в /reward.", "");
            return 0;
        }
    }
    else
    {
        free_slot = Inventory_GetFreeSlot(playerid);
        if(free_slot == -1)
        {
            ShowNotificationSile(playerid, 2, 5, -1, -1, "Нет свободного места в инвентаре. Награда осталась в /reward.", "");
            return 0;
        }

        if(!Inventory_AddItem(playerid, item_id, free_slot, item_count, item_plate))
        {
            ShowNotificationSile(playerid, 2, 5, -1, -1, "Не удалось добавить предмет в инвентарь.", "");
            return 0;
        }
    }

    if(!MPReward_DelInvItemData(reward_item_id))
    {
        if(exact_accessory_db > 0) Market_DeleteGivenEncodedAccessory(playerid, exact_accessory_db);
        else if(free_slot > 0) Market_DeleteInventorySlot(playerid, free_slot);
        ShowNotificationSile(playerid, 2, 5, -1, -1, "Не удалось подтвердить получение. Повторите позже.", "");
        return 0;
    }

    new notify_text[144];
    format(notify_text, sizeof(notify_text), "Marketplace: \xef\xf0\xe5\xe4\xec\xe5\xf2 \xef\xee\xeb\xf3\xf7\xe5\xed: %s x%d.", item_name, Market_IsSingleInventoryEntity(item_id) ? 1 : item_count);
    ShowNotificationSile(playerid, 1, 5, -1, -1, notify_text, "");
    return 1;
}

stock MPReward_SendPage(playerid, packet_type, offset)
{
    if(!IsPlayerLogged(playerid)) return 0;
    if(offset < 0) offset = 0;

    SetPVarInt(playerid, REWARD_GUI_MODE_PVAR, REWARD_GUI_MODE_MARKETPLACE);
    SetPVarInt(playerid, "mpreward_offset", offset);

    new query[640];
    mysql_format(mysql, query, sizeof(query),
        "SELECT r.`id` AS `reward_db_id`,m.`id` AS `reward_item_id`,m.`item_id`,m.`item_count`,m.`item_plate`,m.`item_name` FROM `rewards` r INNER JOIN `marketplace_reward_items` m ON m.`id`=r.`award_id` AND m.`account_id`=r.`uid` WHERE r.`uid`=%d AND r.`case_id`=%d ORDER BY r.`id` DESC LIMIT %d,%d",
        GetPlayerAccountID(playerid), MARKETPLACE_REWARD_CASE_ID, offset, MP_REWARD_PAGE_SIZE + 1);
    mysql_tquery(mysql, query, "MPReward_OnGuiListLoaded", "iii", playerid, packet_type, offset);
    return 1;
}

public MPReward_OnGuiListLoaded(playerid, packet_type, offset)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;
    if(GetPVarInt(playerid, REWARD_GUI_MODE_PVAR) != REWARD_GUI_MODE_MARKETPLACE)
        return 0;

    new rows = cache_num_rows();
    new display_rows = rows;
    if(display_rows > MP_REWARD_PAGE_SIZE) display_rows = MP_REWARD_PAGE_SIZE;

    new Node:reward_array = JSON_Array();
    new skin_count, item_count_total;

    for(new i = 0; i < display_rows; i++)
    {
        new reward_db_id = cache_get_field_content_int(i, "reward_db_id", mysql);
        new item_id = cache_get_field_content_int(i, "item_id", mysql);
        new stored_count = cache_get_field_content_int(i, "item_count", mysql);
        new item_name[64], item_plate[32];
        cache_get_field_content(i, "item_name", item_name, mysql, sizeof(item_name));
        cache_get_field_content(i, "item_plate", item_plate, mysql, sizeof(item_plate));
        if(!strlen(item_name)) GetItemName(item_id, item_name, sizeof(item_name));

        new display_count = Market_IsSingleInventoryEntity(item_id) ? 1 : stored_count;
        if(display_count < 1) display_count = 1;

        new rarity = 1;
        if(item_id == 134) rarity = 3;
        else if(item_id == 58 || item_id == 59 || item_id == 81 || item_id == 82 || item_id == 83 || Market_IsAccessoryInventoryItem(item_id)) rarity = 2;

        new Node:item = JSON_Object();
        JSON_SetInt(item, "id", reward_db_id);
        JSON_SetString(item, "n", item_name, sizeof(item_name));
        JSON_SetInt(item, "td", 11);
        JSON_SetInt(item, "st", 1);
        JSON_SetInt(item, "el", Market_GetClientDisplayItem(item_id));
        JSON_SetInt(item, "c", item_id == 134 ? stored_count : -1);
        JSON_SetInt(item, "ds", 0);
        JSON_SetInt(item, "sp", 0);
        JSON_SetInt(item, "r", rarity);
        JSON_SetInt(item, "ct", display_count);

        new Node:plates = JSON_Array();
        if(strlen(item_plate))
        {
            plates = JSON_Append(plates, JSON_Array(JSON_String(item_plate)));
        }
        JSON_SetArray(item, "els", plates);

        reward_array = JSON_Append(reward_array, JSON_Array(item));
        if(item_id == 134) skin_count++;
        else item_count_total++;
    }

    new Node:json = JSON_Object();
    if(packet_type == 0) JSON_SetInt(json, "o", 1);
    JSON_SetInt(json, "t", packet_type);
    JSON_SetInt(json, "tn", 0);
    JSON_SetArray(json, "pr", reward_array);

    new Node:alarms = JSON_Array(
        JSON_Int(display_rows),
        JSON_Int(skin_count),
        JSON_Int(0),
        JSON_Int(item_count_total),
        JSON_Int(0),
        JSON_Int(0),
        JSON_Int(0)
    );
    JSON_SetArray(json, "fl", alarms);

    if(rows <= MP_REWARD_PAGE_SIZE && packet_type == 2) JSON_SetInt(json, "s", -1);
    OnPacketIncoming(playerid, MP_REWARD_GUI_ID, json);
    JSON_Cleanup(json);

    #pragma unused offset
    return 1;
}

stock MPReward_OpenGUI(playerid)
{
    if(!IsPlayerLogged(playerid))
        return ShowNotificationSile(playerid, 2, 5, -1, -1, "\xd1\xed\xe0\xf7\xe0\xeb\xe0 \xe0\xe2\xf2\xee\xf0\xe8\xe7\xf3\xe9\xf2\xe5\xf1\xfc.", "");

    SetPVarInt(playerid, "mpreward_offset", 0);
    return MPReward_SendPage(playerid, 0, 0);
}

stock MPReward_GiveByDatabaseId(playerid, reward_db_id)
{
    if(reward_db_id <= 0) return 0;

    new query[256];
    mysql_format(mysql, query, sizeof(query),
        "SELECT `award_id` FROM `rewards` WHERE `id`=%d AND `uid`=%d AND `case_id`=%d LIMIT 1",
        reward_db_id, GetPlayerAccountID(playerid), MARKETPLACE_REWARD_CASE_ID);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        return 0;
    }

    new reward_item_id = cache_get_field_content_int(0, "award_id", mysql);
    cache_delete(result);
    return MPReward_GiveToPlayer(playerid, reward_item_id);
}

stock MPReward_OnPacket(playerid, Node:json)
{
    new close_gui;
    JSON_GetInt(json, "c", close_gui);
    if(close_gui == 1)
    {
        SetPVarInt(playerid, REWARD_GUI_MODE_PVAR, REWARD_GUI_MODE_NONE);
        HidePlayerGUI(playerid, MP_REWARD_GUI_ID);
        return 1;
    }

    new type;
    JSON_GetInt(json, "t", type);

    switch(type)
    {
        case 1:
        {
            SetPVarInt(playerid, "mpreward_offset", 0);
            MPReward_SendPage(playerid, 1, 0);
        }
        case 2:
        {
            new offset = GetPVarInt(playerid, "mpreward_offset") + MP_REWARD_PAGE_SIZE;
            MPReward_SendPage(playerid, 2, offset);
        }
        case 4:
        {
            new reward_db_id, reward_action;
            JSON_GetInt(json, "id", reward_db_id);
            JSON_GetInt(json, "s", reward_action);

            new success = 0;
            if(reward_action == 1) success = MPReward_GiveByDatabaseId(playerid, reward_db_id);

            new Node:response = JSON_Object();
            JSON_SetInt(response, "t", 4);
            JSON_SetInt(response, "s", success ? 1 : 0);
            JSON_SetInt(response, "id", reward_db_id);
            OnPacketIncoming(playerid, MP_REWARD_GUI_ID, response);
            JSON_Cleanup(response);
        }
        default:
        {
            MPReward_OpenGUI(playerid);
        }
    }
    return 1;
}


CMD:mpreward(playerid, params[])
{
    #pragma unused params
    MPReward_OpenGUI(playerid);
    return 1;
}



#if defined _sander_marketplace_gui_included
    #endinput
#endif
#define _sander_marketplace_gui_included

#define MARKETPLACE_GUI_ID                    (77)
#define MARKETPLACE_FIX_REVISION              (14)
#define MARKETPLACE_MAX_PAGE_LOTS             (10)
#define MARKETPLACE_DEFAULT_EXPIRE            (604800) // Ровно 7 суток
#define MARKETPLACE_SELL_TAX                  (5)
#define MARKETPLACE_MIN_PRICE                 (1)
#define MARKETPLACE_MAX_PRICE                 (999999999)
#define MARKETPLACE_MAX_TOTAL                 (2000000000)
#define MARKETPLACE_MAX_ACCOUNT_MONEY         (2100000000)
#define MP_LOT_ACTIVE                         (0)
#define MP_LOT_SOLD                           (1)
#define MP_LOT_WITHDRAWN                      (2)
#define MP_LOT_RESERVED                       (3)

#define MP_TAB_PROFILE                        (1)
#define MP_TAB_MAIN                           (2)
#define MP_TAB_INVENTORY                      (3)
#define MP_TAB_HISTORY                        (4)
#define MP_TAB_MY_STORE                       (5)
#define MP_TAB_FAVORITES                      (98)

#define MP_ACT_PAGE                           (6)
#define MP_ACT_DONATE                         (7)
#define MP_ACT_FILTER                         (8)
#define MP_ACT_CREATE_LOT                     (9)
#define MP_ACT_SELECT_INV_ITEM                (10)
#define MP_ACT_PUBLISH_LOT                    (11)
#define MP_ACT_BUY_CLICK                      (12)
#define MP_ACT_CONFIRM_BUY                    (13)
#define MP_ACT_LIKE                           (14)
#define MP_ACT_EDIT_LOT                       (15)
#define MP_ACT_CONFIRM_EDIT                   (16)
#define MP_ACT_DELETE_LOT                     (17)
#define MP_ACT_HISTORY_CARD                   (18)
#define MP_ACT_SEARCH                         (19)
#define MP_ACT_BUY_VIP                        (20)
#define MP_ACT_SORT                           (21)
#define MP_ACT_DOTS_UPDATE                    (22)
#define MP_ACT_LIKED_ARRAY                    (24)
#define MP_ACT_NOTIFY_VIP                     (25)
#define MP_ACT_MONEY_UPDATE                   (26)

#define MP_DIALOG_MAIN                        (28770)
#define MP_DIALOG_LOTS                        (28771)
#define MP_DIALOG_LOT_ACTION                  (28772)
#define MP_DIALOG_INV                         (28773)
#define MP_DIALOG_SELL_COUNT                  (28774)
#define MP_DIALOG_SELL_PRICE                  (28775)
#define MP_DIALOG_MYLOTS                      (28776)
#define MP_DIALOG_MYLOT_ACTION                (28777)
#define MP_DIALOG_SEARCH                      (28778)
#define MP_DIALOG_EDIT_PRICE                  (28779)

new g_MP_SelectedSlot[MAX_PLAYERS] = {-1, ...};
new g_MP_SelectedLot[MAX_PLAYERS] = {-1, ...};
new g_MP_SelectedSellCount[MAX_PLAYERS] = {1, ...};
new g_MP_CurrentTab[MAX_PLAYERS] = {2, ...};
new g_MP_CurrentPage[MAX_PLAYERS] = {0, ...};
new g_MP_Sort[MAX_PLAYERS] = {0, ...};
new g_MP_Search[MAX_PLAYERS][64];

forward Marketplace_OnLotsLoaded(playerid, response_type, tab);
forward Marketplace_OnProfileLoaded(playerid);
forward Marketplace_OnHistoryLoaded(playerid);
forward Marketplace_OnBuyInfoLoaded(playerid, lot_id);
forward Marketplace_OnDialogLots(playerid, my_lots);
forward Marketplace_SendHistory(playerid);

stock Marketplace_ResetPlayer(playerid)
{
    g_MP_SelectedSlot[playerid] = -1;
    g_MP_SelectedLot[playerid] = -1;
    g_MP_SelectedSellCount[playerid] = 1;
    g_MP_CurrentTab[playerid] = MP_TAB_MAIN;
    g_MP_CurrentPage[playerid] = 0;
    g_MP_Sort[playerid] = 0;
    g_MP_Search[playerid][0] = EOS;
    return 1;
}

stock Marketplace_EnsureLotColumn(const column_name[], const definition[])
{
    new query[512];
    mysql_format(mysql, query, sizeof(query), "SHOW COLUMNS FROM `marketplace_lots` LIKE '%e'", column_name);
    new Cache:result = mysql_query(mysql, query, true);
    if(mysql_errno())
    {
        printf("[MARKET][SCHEMA][ERROR] SHOW COLUMN %s errno=%d", column_name, mysql_errno());
        cache_delete(result);
        return 0;
    }
    new exists = cache_num_rows() > 0;
    cache_delete(result);
    if(exists) return 1;

    format(query, sizeof(query), "ALTER TABLE `marketplace_lots` ADD COLUMN `%s` %s", column_name, definition);
    mysql_query(mysql, query, false);
    if(mysql_errno())
    {
        printf("[MARKET][SCHEMA][ERROR] ADD COLUMN %s errno=%d query=%s", column_name, mysql_errno(), query);
        return 0;
    }
    printf("[MARKET][SCHEMA] added marketplace_lots.%s", column_name);
    return 1;
}

stock Marketplace_SendHistory(playerid)
{
    new query[384];
    mysql_format(mysql, query, sizeof(query), "SELECT * FROM `marketplace_history` WHERE `account_id`=%d ORDER BY `id` DESC LIMIT %d", GetPlayerAccountID(playerid), MARKETPLACE_MAX_PAGE_LOTS);
    mysql_tquery(mysql, query, "Marketplace_OnHistoryLoaded", "i", playerid);
    return 1;
}

stock Marketplace_EnsureLotSchema()
{
    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS `marketplace_lots` (`id` INT NOT NULL AUTO_INCREMENT, `seller_id` INT NOT NULL, `seller_name` VARCHAR(24) NOT NULL, `item_id` INT NOT NULL, `item_count` INT NOT NULL, `amount` INT NOT NULL DEFAULT 1, `item_plate` VARCHAR(32) NOT NULL DEFAULT '', `item_name` VARCHAR(64) NOT NULL DEFAULT '', `item_type` INT NOT NULL DEFAULT 0, `rarity` INT NOT NULL DEFAULT 1, `price` INT NOT NULL, `is_hot` TINYINT NOT NULL DEFAULT 0, `status` TINYINT NOT NULL DEFAULT 0, `created_at` INT NOT NULL, `expires_at` INT NOT NULL, `buyer_id` INT NOT NULL DEFAULT 0, PRIMARY KEY (`id`), KEY `seller_id` (`seller_id`), KEY `status` (`status`), KEY `item_id` (`item_id`), KEY `expires_at` (`expires_at`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);
    if(mysql_errno())
    {
        printf("[MARKET][SCHEMA][ERROR] CREATE marketplace_lots errno=%d", mysql_errno());
        return 0;
    }

    Marketplace_EnsureLotColumn("seller_id", "INT NOT NULL DEFAULT 0");
    Marketplace_EnsureLotColumn("seller_name", "VARCHAR(24) NOT NULL DEFAULT ''");
    Marketplace_EnsureLotColumn("item_id", "INT NOT NULL DEFAULT 0");
    Marketplace_EnsureLotColumn("item_count", "INT NOT NULL DEFAULT 1");
    Marketplace_EnsureLotColumn("amount", "INT NOT NULL DEFAULT 1");
    Marketplace_EnsureLotColumn("item_plate", "VARCHAR(32) NOT NULL DEFAULT ''");
    Marketplace_EnsureLotColumn("item_name", "VARCHAR(64) NOT NULL DEFAULT ''");
    Marketplace_EnsureLotColumn("item_type", "INT NOT NULL DEFAULT 0");
    Marketplace_EnsureLotColumn("rarity", "INT NOT NULL DEFAULT 1");
    Marketplace_EnsureLotColumn("price", "INT NOT NULL DEFAULT 0");
    Marketplace_EnsureLotColumn("is_hot", "TINYINT NOT NULL DEFAULT 0");
    Marketplace_EnsureLotColumn("status", "TINYINT NOT NULL DEFAULT 0");
    Marketplace_EnsureLotColumn("created_at", "INT NOT NULL DEFAULT 0");
    Marketplace_EnsureLotColumn("expires_at", "INT NOT NULL DEFAULT 0");
    Marketplace_EnsureLotColumn("buyer_id", "INT NOT NULL DEFAULT 0");
    return 1;
}

stock Marketplace_EnsureHistorySchema()
{
    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS `marketplace_history` (`id` INT NOT NULL AUTO_INCREMENT, `account_id` INT NOT NULL, `lot_id` INT NOT NULL DEFAULT 0, `item_id` INT NOT NULL, `item_count` INT NOT NULL DEFAULT 1, `amount` INT NOT NULL DEFAULT 1, `price` INT NOT NULL DEFAULT 0, `status` TINYINT NOT NULL DEFAULT 0, `seller_name` VARCHAR(24) NOT NULL DEFAULT '', `buyer_name` VARCHAR(24) NOT NULL DEFAULT '', `item_name` VARCHAR(64) NOT NULL DEFAULT '', `created_at` INT NOT NULL, PRIMARY KEY (`id`), KEY `account_id` (`account_id`), KEY `lot_id` (`lot_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251", false);
    if(mysql_errno())
    {
        printf("[MARKET][SCHEMA][ERROR] CREATE marketplace_history errno=%d", mysql_errno());
        return 0;
    }

    new query[384];
    new Cache:result = mysql_query(mysql, "SHOW COLUMNS FROM `marketplace_history` LIKE 'item_count'", true);
    if(mysql_errno())
    {
        printf("[MARKET][SCHEMA][ERROR] SHOW marketplace_history.item_count errno=%d", mysql_errno());
        cache_delete(result);
        return 0;
    }
    new exists = cache_num_rows() > 0;
    cache_delete(result);
    if(!exists)
    {
        format(query, sizeof(query), "ALTER TABLE `marketplace_history` ADD COLUMN `item_count` INT NOT NULL DEFAULT 1 AFTER `item_id`");
        mysql_query(mysql, query, false);
        if(mysql_errno())
        {
            printf("[MARKET][SCHEMA][ERROR] ADD marketplace_history.item_count errno=%d", mysql_errno());
            return 0;
        }
        printf("[MARKET][SCHEMA] added marketplace_history.item_count");
    }
    return 1;
}

stock Marketplace_OnGameModeInit()
{
    MPReward_CreateTables();

    Marketplace_EnsureLotSchema();
    Marketplace_EnsureHistorySchema();
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `marketplace_favorites` (`account_id` INT NOT NULL, `lot_id` INT NOT NULL, `created_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`,`lot_id`), KEY `lot_id` (`lot_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
    mysql_tquery(mysql, "CREATE TABLE IF NOT EXISTS `marketplace_wallet` (`account_id` INT NOT NULL, `balance` BIGINT NOT NULL DEFAULT 0, `updated_at` INT NOT NULL DEFAULT 0, PRIMARY KEY (`account_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");

    mysql_tquery(mysql, "UPDATE `marketplace_lots` SET `status`=0 WHERE `status`=3");
    mysql_tquery(mysql, "UPDATE `marketplace_lots` SET `expires_at`=`created_at`+604800 WHERE `status`=0 AND `expires_at`<>`created_at`+604800");
    return 1;
}

stock Marketplace_IsSpecialItem(item_id)
{
    return Market_IsSingleInventoryEntity(item_id);
}

stock Marketplace_GetSlotSellAmount(playerid, source_id)
{
    if(!Market_CanSellSource(playerid, source_id)) return 0;

    new item_id = Market_GetSourceItemId(playerid, source_id);
    if(Marketplace_IsSpecialItem(item_id)) return 1;

    new amount = Market_GetSourceItemCount(playerid, source_id);
    return amount > 0 ? amount : 1;
}

stock Marketplace_GetProductType(item_id)
{
    if(item_id == 134) return 3;
    if(item_id == 58 || Inventory11_IsPlateItem(item_id)) return 2;
    if(Market_IsAccessoryInventoryItem(item_id)) return 1;
    return 0;
}

stock Marketplace_GetLotClientModel(item_id, item_count)
{
    if(item_id == 134)
    {
        new skin_model = Market_GetSkinModelByStoredId(item_count);
        return (skin_model > 0) ? skin_model : -1;
    }
    return Market_GetClientDisplayItem(item_id);
}

stock Marketplace_GetRarity(item_id)
{
    if(item_id == 134) return 3;
    if(item_id == 58 || Market_IsAccessoryInventoryItem(item_id)) return 2;
    return 1;
}

stock Marketplace_GetClientVariant(playerid, source_id)
{
    new item_id = Market_GetSourceItemId(playerid, source_id);
    new stored_count = Market_GetSourceItemCount(playerid, source_id);

    if(item_id == 134)
    {
        new skin_model = Market_GetSkinModelByStoredId(stored_count);
        return (skin_model > 0) ? skin_model : -1;
    }

    if(item_id == 58)
    {
        new plate[32];
        Market_GetSourcePlate(playerid, source_id, plate, sizeof(plate));
        if(strlen(plate)) return strval(plate);
        return stored_count;
    }

    if(Market_IsAccessoryInventoryItem(item_id))
        return Market_GetAccessoryModelFromSource(playerid, source_id);

    return -1;
}

stock Marketplace_GetInventoryName(playerid, source_id, name[], len = sizeof(name))
{
    name[0] = EOS;
    if(!Market_CanSellSource(playerid, source_id)) return 0;

    new item_id = Market_GetSourceItemId(playerid, source_id);
    new stored_count = Market_GetSourceItemCount(playerid, source_id);
    new base_name[64], plate[32];
    Market_GetSourcePlate(playerid, source_id, plate, sizeof(plate));

    if(Market_IsAccessoryInventoryItem(item_id))
        GetItemNameById(item_id, base_name, sizeof(base_name));
    else
        GetItemName(item_id, base_name, sizeof(base_name));

    if(!strlen(base_name)) format(base_name, sizeof(base_name), "Item #%d", item_id);

    if(item_id == 134)
    {
        format(name, len, "%s #%d", base_name, stored_count);
    }
    else if(item_id == 58)
    {
        new sim_number = strlen(plate) ? strval(plate) : stored_count;
        if(sim_number > 0) format(name, len, "%s %d", base_name, sim_number);
        else format(name, len, "%s", base_name);
    }
    else if(Inventory11_IsPlateItem(item_id))
    {
        new plate_type, plate_number[16], plate_region[8], plate_view[32];
        if(ParseStoredPlateValue(plate, plate_type, plate_number, sizeof(plate_number), plate_region, sizeof(plate_region)))
        {
            Inv11Trade_BuildPlateText(plate_type, plate_number, plate_region, plate_view, sizeof(plate_view));
            format(name, len, "%s %s", base_name, plate_view);
        }
        else format(name, len, "%s", base_name);
    }
    else
    {
        format(name, len, "%s", base_name);
    }
    return 1;
}

stock Marketplace_FindPlayerByAccountID(account_id)
{
    foreach(new i: Player)
    {
        if(IsPlayerConnected(i) && IsPlayerLogged(i) && GetPlayerAccountID(i) == account_id) return i;
    }
    return INVALID_PLAYER_ID;
}

stock Marketplace_QueueMoney(account_id, money)
{
    if(account_id <= 0 || money <= 0) return 0;

    new query[320];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `marketplace_wallet` (`account_id`,`balance`,`updated_at`) VALUES (%d,%d,%d) ON DUPLICATE KEY UPDATE `balance`=`balance`+VALUES(`balance`),`updated_at`=VALUES(`updated_at`)",
        account_id, money, gettime());

    new Cache:result = mysql_query(mysql, query, true);
    new affected = cache_affected_rows(mysql);
    cache_delete(result);
    return affected > 0;
}

stock Marketplace_AddMoneyToAccount(account_id, money)
{
    if(account_id <= 0 || money <= 0) return 0;

    new current_money;
    new online = Marketplace_FindPlayerByAccountID(account_id);

    if(online != INVALID_PLAYER_ID)
    {
        current_money = GetPlayerMoneyEx(online);
    }
    else
    {
        new query[192];
        mysql_format(mysql, query, sizeof(query), "SELECT `money` FROM `accounts` WHERE `id`=%d LIMIT 1", account_id);
        new Cache:result = mysql_query(mysql, query, true);
        if(!cache_num_rows())
        {
            cache_delete(result);
            return Marketplace_QueueMoney(account_id, money);
        }
        current_money = cache_get_field_content_int(0, "money", mysql);
        cache_delete(result);
    }

    if(current_money < 0) current_money = 0;
    new capacity = MARKETPLACE_MAX_ACCOUNT_MONEY - current_money;
    if(capacity < 0) capacity = 0;

    new direct_money = money;
    if(direct_money > capacity) direct_money = capacity;
    new pending_money = money - direct_money;

    if(pending_money > 0 && !Marketplace_QueueMoney(account_id, pending_money)) return 0;

    if(direct_money > 0)
    {
        if(online != INVALID_PLAYER_ID)
        {
            if(!GivePlayerMoneyEx(online, direct_money, "Marketplace sale", true, true))
            {
                if(!Marketplace_QueueMoney(account_id, direct_money)) return 0;
            }
        }
        else
        {
            new query[256];
            mysql_format(mysql, query, sizeof(query),
                "UPDATE `accounts` SET `money`=`money`+%d WHERE `id`=%d AND `money`<=%d LIMIT 1",
                direct_money, account_id, MARKETPLACE_MAX_ACCOUNT_MONEY - direct_money);
            new Cache:update_result = mysql_query(mysql, query, true);
            new updated = cache_affected_rows(mysql);
            cache_delete(update_result);

            if(!updated && !Marketplace_QueueMoney(account_id, direct_money)) return 0;
        }
    }

    if(online != INVALID_PLAYER_ID && pending_money > 0)
    {
        ShowNotificationSile(online, 1, 6, -1, -1, "     .  /marketmoney.", "");
    }
    return 1;
}

stock Marketplace_ClaimMoney(playerid, notify = 1)
{
    if(!IsPlayerLogged(playerid)) return 0;

    new current_money = GetPlayerMoneyEx(playerid);
    new capacity = MARKETPLACE_MAX_ACCOUNT_MONEY - current_money;
    if(capacity <= 0)
    {
        if(notify) ShowNotificationSile(playerid, 2, 5, -1, -1, "       .", "");
        return 0;
    }

    new query[256];
    mysql_format(mysql, query, sizeof(query),
        "SELECT LEAST(`balance`,%d) AS `available` FROM `marketplace_wallet` WHERE `account_id`=%d LIMIT 1",
        MARKETPLACE_MAX_ACCOUNT_MONEY, GetPlayerAccountID(playerid));

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        if(notify) ShowNotificationSile(playerid, 2, 5, -1, -1, "    .", "");
        return 0;
    }

    new claim = cache_get_field_content_int(0, "available", mysql);
    cache_delete(result);
    if(claim > capacity) claim = capacity;
    if(claim <= 0) return 0;

    mysql_format(mysql, query, sizeof(query),
        "UPDATE `marketplace_wallet` SET `balance`=`balance`-%d,`updated_at`=%d WHERE `account_id`=%d AND `balance`>=%d LIMIT 1",
        claim, gettime(), GetPlayerAccountID(playerid), claim);
    new Cache:update_result = mysql_query(mysql, query, true);
    new updated = cache_affected_rows(mysql);
    cache_delete(update_result);
    if(!updated) return 0;

    if(!GivePlayerMoneyEx(playerid, claim, "Marketplace wallet", true, true))
    {
        Marketplace_QueueMoney(GetPlayerAccountID(playerid), claim);
        return 0;
    }

    mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_wallet` WHERE `account_id`=%d AND `balance`<=0 LIMIT 1", GetPlayerAccountID(playerid));
    mysql_tquery(mysql, query);

    if(notify) ShowNotificationSile(playerid, 1, 5, -1, -1, "    .", "");
    return 1;
}

stock Marketplace_Send(Node:json, playerid)
{
    JSON_SetString(json, "nm", GetPlayerNameEx(playerid));
    JSON_SetString(json, "pn", GetPlayerNameEx(playerid));
    JSON_ToggleGC(json, false);
    OnPacketIncoming(playerid, MARKETPLACE_GUI_ID, json);
    return 1;
}

stock Marketplace_SendActionResult(playerid, action, success)
{
    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", action);
    JSON_SetInt(json, "err", success ? 1 : 0);
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

// "ti" — это ОСТАВШАЯСЯ длительность в секундах до истечения лота (клиент
// делит на 86400 и показывает как дни), а НЕ абсолютный unix-timestamp.
// "tb" — время создания лота.
stock Node:Marketplace_MakeProductNode(lot_id, item_id, item_count, amount, price, item_name[], item_type, rarity, seller_id, seller_name[], created_at, remain_seconds, hot, liked = 0)
{
    new Node:item = JSON_Object();
    JSON_ToggleGC(item, false);
    JSON_SetInt(item, "id", lot_id);
    JSON_SetInt(item, "tp", 0);
    JSON_SetInt(item, "tm", hot);
    JSON_SetInt(item, "ti", (remain_seconds > 0) ? remain_seconds : 0);
    new client_model = Marketplace_GetLotClientModel(item_id, item_count);
    JSON_SetInt(item, "md", client_model);
    JSON_SetInt(item, "pt", item_type);
    JSON_SetInt(item, "cs", price);
    JSON_SetInt(item, "ct", amount);
    JSON_SetString(item, "dm", item_name, 64);
    JSON_SetInt(item, "r", rarity);
    JSON_SetInt(item, "rt", rarity);
    JSON_SetString(item, "nm", seller_name, 24);
    JSON_SetInt(item, "sl", seller_id);
    JSON_SetInt(item, "l", liked ? 1 : 0);
    JSON_SetInt(item, "tb", created_at);

    return item;
}

stock Node:Marketplace_MakeInventoryProductNode(playerid, source_id)
{
    new item_id = Market_GetSourceItemId(playerid, source_id);
    new amount = Marketplace_GetSlotSellAmount(playerid, source_id);
    new rarity = Marketplace_GetRarity(item_id);
    new item_name[64];
    Marketplace_GetInventoryName(playerid, source_id, item_name, sizeof(item_name));

    new Node:item = JSON_Object();
    JSON_ToggleGC(item, false);
    JSON_SetInt(item, "id", source_id);
    JSON_SetInt(item, "tp", 0);
    JSON_SetInt(item, "tm", 0);
    JSON_SetInt(item, "ti", MARKETPLACE_DEFAULT_EXPIRE);
    new client_model = Marketplace_GetClientVariant(playerid, source_id);
    if(client_model <= 0) client_model = Market_GetClientDisplayItem(item_id);
    JSON_SetInt(item, "md", client_model);
    JSON_SetInt(item, "pt", Marketplace_GetProductType(item_id));
    JSON_SetInt(item, "cs", 0);
    JSON_SetInt(item, "ct", amount);
    JSON_SetString(item, "dm", item_name, sizeof(item_name));
    JSON_SetInt(item, "r", rarity);
    JSON_SetInt(item, "rt", rarity);

    new seller_buf[MAX_PLAYER_NAME];
    format(seller_buf, sizeof(seller_buf), "%s", GetPlayerNameEx(playerid));
    JSON_SetString(item, "nm", seller_buf, sizeof(seller_buf));
    JSON_SetInt(item, "sl", GetPlayerAccountID(playerid));
    JSON_SetInt(item, "l", 0);
    JSON_SetInt(item, "tb", gettime());

    return item;
}

stock Node:Marketplace_BuildInventoryArray(playerid)
{
    new Node:products = JSON_Array();

    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
    {
        if(!Market_CanSellSource(playerid, i)) continue;
        new Node:item = Marketplace_MakeInventoryProductNode(playerid, i);
        JSON_ToggleGC(item, true);
        products = JSON_Append(products, JSON_Array(item));
    }

    for(new active_slot = 0; active_slot < MAX_ACTIVE_SLOTS; active_slot++)
    {
        new source_id = Market_MakeActiveSource(active_slot);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new Node:item = Marketplace_MakeInventoryProductNode(playerid, source_id);
        JSON_ToggleGC(item, true);
        products = JSON_Append(products, JSON_Array(item));
    }

    for(new accessory_slot = 0; accessory_slot < MARKET_SOURCE_ACCESSORY_SLOTS; accessory_slot++)
    {
        new source_id = Market_MakeAccessorySource(accessory_slot);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new Node:item = Marketplace_MakeInventoryProductNode(playerid, source_id);
        JSON_ToggleGC(item, true);
        products = JSON_Append(products, JSON_Array(item));
    }

    for(new owned_accessory = 0; owned_accessory < MARKET_SOURCE_OWNED_ACCESSORY_MAX; owned_accessory++)
    {
        new source_id = Market_MakeOwnedAccessorySource(owned_accessory);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new Node:item = Marketplace_MakeInventoryProductNode(playerid, source_id);
        JSON_ToggleGC(item, true);
        products = JSON_Append(products, JSON_Array(item));
    }

    for(new owned_skin = 0; owned_skin < MARKET_SOURCE_OWNED_SKIN_MAX; owned_skin++)
    {
        new source_id = Market_MakeOwnedSkinSource(owned_skin);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new Node:item = Marketplace_MakeInventoryProductNode(playerid, source_id);
        JSON_ToggleGC(item, true);
        products = JSON_Append(products, JSON_Array(item));
    }

    JSON_ToggleGC(products, false);
    return products;
}

stock Marketplace_CountInventoryProducts(playerid)
{
    new count;

    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
        if(Market_CanSellSource(playerid, i)) count++;

    for(new active_slot = 0; active_slot < MAX_ACTIVE_SLOTS; active_slot++)
        if(Market_CanSellSource(playerid, Market_MakeActiveSource(active_slot))) count++;

    for(new accessory_slot = 0; accessory_slot < MARKET_SOURCE_ACCESSORY_SLOTS; accessory_slot++)
        if(Market_CanSellSource(playerid, Market_MakeAccessorySource(accessory_slot))) count++;

    for(new owned_accessory = 0; owned_accessory < MARKET_SOURCE_OWNED_ACCESSORY_MAX; owned_accessory++)
        if(Market_CanSellSource(playerid, Market_MakeOwnedAccessorySource(owned_accessory))) count++;

    for(new owned_skin = 0; owned_skin < MARKET_SOURCE_OWNED_SKIN_MAX; owned_skin++)
        if(Market_CanSellSource(playerid, Market_MakeOwnedSkinSource(owned_skin))) count++;

    return count;
}

stock Marketplace_SendInventoryProducts(playerid, response_type = MP_ACT_CREATE_LOT)
{
    Market_RefreshAccessoryCache(playerid);

    new sell_sources[MAX_INVENTORY_SLOTS + MAX_ACTIVE_SLOTS + MARKET_SOURCE_ACCESSORY_SLOTS + MARKET_SOURCE_OWNED_ACCESSORY_MAX + MARKET_SOURCE_OWNED_SKIN_MAX];
    new source_count = 0;

    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
    {
        if(Market_CanSellSource(playerid, i))
            sell_sources[source_count++] = i;
    }

    for(new active_slot = 0; active_slot < MAX_ACTIVE_SLOTS; active_slot++)
    {
        new source_id = Market_MakeActiveSource(active_slot);
        if(Market_CanSellSource(playerid, source_id))
            sell_sources[source_count++] = source_id;
    }

    for(new accessory_slot = 0; accessory_slot < MARKET_SOURCE_ACCESSORY_SLOTS; accessory_slot++)
    {
        new source_id = Market_MakeAccessorySource(accessory_slot);
        if(Market_CanSellSource(playerid, source_id))
            sell_sources[source_count++] = source_id;
    }

    for(new owned_accessory = 0; owned_accessory < MARKET_SOURCE_OWNED_ACCESSORY_MAX; owned_accessory++)
    {
        new source_id = Market_MakeOwnedAccessorySource(owned_accessory);
        if(Market_CanSellSource(playerid, source_id))
            sell_sources[source_count++] = source_id;
    }

    for(new owned_skin = 0; owned_skin < MARKET_SOURCE_OWNED_SKIN_MAX; owned_skin++)
    {
        new source_id = Market_MakeOwnedSkinSource(owned_skin);
        if(Market_CanSellSource(playerid, source_id))
            sell_sources[source_count++] = source_id;
    }

    new Node:json = JSON_Object();
    new Node:products = JSON_Array();
    new seller_name[MAX_PLAYER_NAME];
    format(seller_name, sizeof(seller_name), "%s", GetPlayerNameEx(playerid));

    new appended = 0;
    for(new index = 0; index < source_count; index++)
    {
        new source_id = sell_sources[index];
        new item_id = Market_GetSourceItemId(playerid, source_id);
        new amount = Marketplace_GetSlotSellAmount(playerid, source_id);
        if(item_id <= 0 || amount <= 0) continue;

        new rarity = Marketplace_GetRarity(item_id);
        new item_name[64];
        Marketplace_GetInventoryName(playerid, source_id, item_name, sizeof(item_name));

        new Node:item = JSON_Object();
        JSON_SetInt(item, "id", source_id);
        JSON_SetInt(item, "tp", 0);
        JSON_SetInt(item, "tm", 0);
        JSON_SetInt(item, "ti", MARKETPLACE_DEFAULT_EXPIRE);
        JSON_SetInt(item, "tb", gettime());
        new client_model = Marketplace_GetClientVariant(playerid, source_id);
        if(client_model <= 0) client_model = Market_GetClientDisplayItem(item_id);
        JSON_SetInt(item, "md", client_model);
        JSON_SetInt(item, "cs", MARKETPLACE_MIN_PRICE);
        JSON_SetInt(item, "ct", amount);
        JSON_SetString(item, "dm", item_name, sizeof(item_name));
        JSON_SetInt(item, "r", rarity);
        JSON_SetInt(item, "rt", rarity);
        JSON_SetInt(item, "pt", Marketplace_GetProductType(item_id));
        JSON_SetString(item, "nm", seller_name, sizeof(seller_name));
        JSON_SetInt(item, "sl", GetPlayerAccountID(playerid));
        JSON_SetInt(item, "l", 0);

        products = JSON_Append(products, JSON_Array(item));
        appended++;
    }

    new json_count = 0;
    JSON_ArrayLength(products, json_count);
    if(json_count < 0) json_count = appended;

    JSON_SetInt(json, "t", response_type);
    JSON_SetInt(json, "m", GetPlayerMoneyEx(playerid));
    JSON_SetInt(json, "lp", appended);
    JSON_SetInt(json, "ls", 1);
    JSON_SetArray(json, "n", products);

    printf("[MARKET] fix=%d player=%d eligible=%d appended=%d json_count=%d (inventory+active+equipped+owned accessories+owned skins)",
        MARKETPLACE_FIX_REVISION, playerid, source_count, appended, json_count);

    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_SendLotsRequest(playerid, response_type, tab)
{
    if(!IsPlayerLogged(playerid)) return 0;

    mysql_tquery(mysql, "DELETE f FROM `marketplace_favorites` f LEFT JOIN `marketplace_lots` l ON l.`id`=f.`lot_id` WHERE l.`id` IS NULL OR l.`status`<>0 OR l.`expires_at`<=UNIX_TIMESTAMP()");

    new where[512], order[128], query[1400], escaped[128], offset;
    new account_id = GetPlayerAccountID(playerid);
    offset = g_MP_CurrentPage[playerid] * MARKETPLACE_MAX_PAGE_LOTS;

    if(tab == MP_TAB_MY_STORE)
    {
        mysql_format(mysql, where, sizeof(where),
            "WHERE l.`status`=%d AND l.`seller_id`=%d",
            MP_LOT_ACTIVE, account_id);
    }
    else
    {
        mysql_format(mysql, where, sizeof(where),
            "WHERE l.`status`=%d AND l.`expires_at`>%d",
            MP_LOT_ACTIVE, gettime());

        if(tab == MP_TAB_FAVORITES)
        {
            strcat(where, " AND f.`account_id` IS NOT NULL", sizeof(where));
        }
    }

    if(strlen(g_MP_Search[playerid]))
    {
        new where_base[512];
        format(where_base, sizeof(where_base), "%s", where);
        mysql_escape_string(g_MP_Search[playerid], escaped, mysql, sizeof(escaped));
        format(where, sizeof(where), "%s AND l.`item_name` LIKE '%%%s%%'", where_base, escaped);
    }

    switch(g_MP_Sort[playerid])
    {
        case 1: format(order, sizeof(order), "ORDER BY l.`price` ASC, l.`id` DESC");
        case 2: format(order, sizeof(order), "ORDER BY l.`price` DESC, l.`id` DESC");
        default: format(order, sizeof(order), "ORDER BY l.`is_hot` DESC, l.`id` DESC");
    }

    mysql_format(mysql, query, sizeof(query),
        "SELECT l.*,IF(f.`account_id` IS NULL,0,1) AS `is_liked` FROM `marketplace_lots` l LEFT JOIN `marketplace_favorites` f ON f.`lot_id`=l.`id` AND f.`account_id`=%d AND l.`status`=%d AND l.`expires_at`>UNIX_TIMESTAMP() %s %s LIMIT %d,%d",
        account_id, MP_LOT_ACTIVE, where, order, offset, MARKETPLACE_MAX_PAGE_LOTS);

    mysql_tquery(mysql, query, "Marketplace_OnLotsLoaded", "iii", playerid, response_type, tab);
    return 1;
}

public Marketplace_OnLotsLoaded(playerid, response_type, tab)
{
    if(!IsPlayerConnected(playerid)) return 0;

    new rows, fields;
    cache_get_data(rows, fields, mysql);

    new Node:json = JSON_Object();
    new Node:products = JSON_Array();
    new pages = (rows >= MARKETPLACE_MAX_PAGE_LOTS) ? (g_MP_CurrentPage[playerid] + 2) : (g_MP_CurrentPage[playerid] + 1);

    for(new i = 0; i < rows; i++)
    {
        new item_name[64], seller_name[24];
        cache_get_field_content(i, "item_name", item_name, mysql, sizeof(item_name));
        cache_get_field_content(i, "seller_name", seller_name, mysql, sizeof(seller_name));

        new Node:item = Marketplace_MakeProductNode(
            cache_get_field_content_int(i, "id", mysql),
            cache_get_field_content_int(i, "item_id", mysql),
            cache_get_field_content_int(i, "item_count", mysql),
            cache_get_field_content_int(i, "amount", mysql),
            cache_get_field_content_int(i, "price", mysql),
            item_name,
            Marketplace_GetProductType(cache_get_field_content_int(i, "item_id", mysql)),
            cache_get_field_content_int(i, "rarity", mysql),
            cache_get_field_content_int(i, "seller_id", mysql),
            seller_name,
            cache_get_field_content_int(i, "created_at", mysql),
            cache_get_field_content_int(i, "expires_at", mysql) - gettime(),
            cache_get_field_content_int(i, "is_hot", mysql),
            cache_get_field_content_int(i, "is_liked", mysql)
        );
        JSON_ToggleGC(item, true);
        products = JSON_Append(products, JSON_Array(item));
    }

    if(response_type > 0) JSON_SetInt(json, "t", response_type);
    else
    {
        JSON_SetInt(json, "o", 1);
        JSON_SetInt(json, "t", MP_TAB_MAIN);
    }

    JSON_SetInt(json, "m", GetPlayerMoneyEx(playerid));
    JSON_SetInt(json, "v", 0);
    JSON_SetInt(json, "vm", 1000);
    JSON_SetInt(json, "lp", 0);
    JSON_SetInt(json, "ls", pages);
    JSON_SetInt(json, "lt", g_MP_CurrentPage[playerid] + 1);
    JSON_SetArray(json, "n", products);
    #pragma unused tab

    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_OpenGUI(playerid)
{
    if(!IsPlayerLogged(playerid)) return ShowNotificationSile(playerid, 2, 5, -1, -1, "\xc2\xfb\x20\xe4\xee\xeb\xe6\xed\xfb\x20\xe0\xe2\xf2\xee\xf0\xe8\xe7\xee\xe2\xe0\xf2\xfc\xf1\xff\x2e", "");
    Marketplace_ClaimMoney(playerid, 0);
    g_MP_CurrentTab[playerid] = MP_TAB_MAIN;
    g_MP_CurrentPage[playerid] = 0;
    g_MP_Search[playerid][0] = EOS;

    new Node:open_json = JSON_Object();
    new Node:open_products = JSON_Array();
    JSON_SetInt(open_json, "t", MP_TAB_MAIN);
    JSON_SetInt(open_json, "m", GetPlayerMoneyEx(playerid));
    JSON_SetInt(open_json, "v", 0);
    JSON_SetInt(open_json, "vm", 1000);
    JSON_SetInt(open_json, "lp", 0);
    JSON_SetInt(open_json, "ls", 1);
    JSON_SetInt(open_json, "lt", 1);
    JSON_SetString(open_json, "nm", GetPlayerNameEx(playerid));
    JSON_SetString(open_json, "pn", GetPlayerNameEx(playerid));
    JSON_SetArray(open_json, "n", open_products);
    ShowPlayerGUI(playerid, MARKETPLACE_GUI_ID, open_json);
    JSON_Cleanup(open_json);

    Marketplace_SendLotsRequest(playerid, 0, MP_TAB_MAIN);
    return 1;
}

stock Marketplace_SendProfile(playerid)
{
    new query[384];
    mysql_format(mysql, query, sizeof(query), "SELECT COUNT(*) AS active_count, LEAST(IFNULL(SUM((`price`*`amount`)),0),%d) AS active_sum FROM `marketplace_lots` WHERE `seller_id`=%d AND `status`=%d", MARKETPLACE_MAX_TOTAL, GetPlayerAccountID(playerid), MP_LOT_ACTIVE);
    mysql_tquery(mysql, query, "Marketplace_OnProfileLoaded", "i", playerid);
    return 1;
}

public Marketplace_OnProfileLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new rows, fields;
    cache_get_data(rows, fields, mysql);
    new active_count, active_sum;
    if(rows)
    {
        active_count = cache_get_field_content_int(0, "active_count", mysql);
        active_sum = cache_get_field_content_int(0, "active_sum", mysql);
    }

    new seller_buf[MAX_PLAYER_NAME];
    format(seller_buf, sizeof seller_buf, "%s", GetPlayerNameEx(playerid));

    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", MP_TAB_PROFILE);
    JSON_SetInt(json, "m", GetPlayerMoneyEx(playerid));
    JSON_SetInt(json, "ct", active_count);      // Всего продано товаров
    JSON_SetInt(json, "cs", active_sum);        // Выручка за все время
    JSON_SetString(json, "nm", seller_buf, sizeof(seller_buf));
    JSON_SetString(json, "pn", seller_buf, sizeof(seller_buf));
    // Массив "n" НЕ отправляем для профиля
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

public Marketplace_OnHistoryLoaded(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new rows, fields;
    cache_get_data(rows, fields, mysql);
    new Node:json = JSON_Object();
    new Node:history = JSON_Array();
    for(new i = 0; i < rows; i++)
    {
        new item_name[64], seller_name[24];
        cache_get_field_content(i, "item_name", item_name, mysql, sizeof(item_name));
        cache_get_field_content(i, "seller_name", seller_name, mysql, sizeof(seller_name));
        new Node:item = Marketplace_MakeProductNode(
            cache_get_field_content_int(i, "lot_id", mysql),
            cache_get_field_content_int(i, "item_id", mysql),
            cache_get_field_content_int(i, "item_count", mysql),
            cache_get_field_content_int(i, "amount", mysql),
            cache_get_field_content_int(i, "price", mysql),
            item_name,
            Marketplace_GetProductType(cache_get_field_content_int(i, "item_id", mysql)),
            Marketplace_GetRarity(cache_get_field_content_int(i, "item_id", mysql)),
            0,
            seller_name,
            cache_get_field_content_int(i, "created_at", mysql),
            0,
            0
        );
        JSON_ToggleGC(item, true);
        history = JSON_Append(history, JSON_Array(item));
    }
    JSON_SetInt(json, "t", MP_TAB_HISTORY);
    JSON_SetInt(json, "ls", 1);
    JSON_SetArray(json, "n", history);
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_SelectInventorySlot(playerid, source_id)
{
    if(!Market_CanSellSource(playerid, source_id))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_SELECT_INV_ITEM, 0);
        return 0;
    }

    new item_id = Market_GetSourceItemId(playerid, source_id);
    g_MP_SelectedSlot[playerid] = source_id;
    g_MP_SelectedSellCount[playerid] = 1;

    new Node:json = JSON_Object();
    new Node:item = Marketplace_MakeInventoryProductNode(playerid, source_id);
    JSON_ToggleGC(item, true);
    JSON_SetInt(json, "t", MP_ACT_SELECT_INV_ITEM);
    JSON_SetInt(json, "err", 1);
    JSON_SetInt(json, "rk", Marketplace_GetRarity(item_id));
    JSON_SetInt(json, "id", source_id);
    JSON_SetInt(json, "pt", Marketplace_GetProductType(item_id));
    new client_model = Marketplace_GetClientVariant(playerid, source_id);
    if(client_model <= 0) client_model = Market_GetClientDisplayItem(item_id);
    JSON_SetInt(json, "md", client_model);
    JSON_SetInt(json, "ct", Marketplace_GetSlotSellAmount(playerid, source_id));
    JSON_SetInt(json, "cs", 0);

    new item_name[64];
    Marketplace_GetInventoryName(playerid, source_id, item_name, sizeof(item_name));
    JSON_SetString(json, "dm", item_name, sizeof(item_name));

    new Node:arr = JSON_Array(item);
    JSON_SetArray(json, "n", arr);
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_PublishSelected(playerid, amount, price, hot)
{
    new source_id = g_MP_SelectedSlot[playerid];
    if(!Market_CanSellSource(playerid, source_id))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 0);
        return 0;
    }

    if(price < MARKETPLACE_MIN_PRICE || price > MARKETPLACE_MAX_PRICE)
    {
        Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 0);
        ShowNotificationSile(playerid, 2, 5, -1, -1, "\xd3\xea\xe0\xe6\xe8\xf2\xe5 \xea\xee\xf0\xf0\xe5\xea\xf2\xed\xf3\xfe \xf6\xe5\xed\xf3.", "");
        return 0;
    }

    new item_id = Market_GetSourceItemId(playerid, source_id);
    new max_amount = Marketplace_GetSlotSellAmount(playerid, source_id);
    if(amount < 1) amount = 1;
    if(amount > max_amount) amount = max_amount;
    if(Marketplace_IsSpecialItem(item_id)) amount = 1;

    if(amount > 0 && price > (MARKETPLACE_MAX_TOTAL / amount))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 0);
        ShowNotificationSile(playerid, 2, 5, -1, -1, "\xce\xe1\xf9\xe0\xff \xf1\xf2\xee\xe8\xec\xee\xf1\xf2\xfc \xeb\xee\xf2\xe0 \xf1\xeb\xe8\xf8\xea\xee\xec \xe2\xe5\xeb\xe8\xea\xe0.", "");
        return 0;
    }

    new inv_count = Market_GetSourceItemCount(playerid, source_id);
    if(Market_IsAccessoryInventoryItem(item_id)) inv_count = 1;

    new item_plate[32], item_name[64], seller_name[MAX_PLAYER_NAME];
    Market_GetSourcePlate(playerid, source_id, item_plate, sizeof(item_plate));
    Marketplace_GetInventoryName(playerid, source_id, item_name, sizeof(item_name));
    format(seller_name, sizeof(seller_name), "%s", GetPlayerNameEx(playerid));

    new item_type = Marketplace_GetProductType(item_id);
    new rarity = Marketplace_GetRarity(item_id);
    new created = gettime();
    new expires = created + MARKETPLACE_DEFAULT_EXPIRE;
    hot = 0;

    new query[1200];
    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `marketplace_lots` (`seller_id`,`seller_name`,`item_id`,`item_count`,`amount`,`item_plate`,`item_name`,`item_type`,`rarity`,`price`,`is_hot`,`status`,`created_at`,`expires_at`) VALUES (%d,'%e',%d,%d,%d,'%e','%e',%d,%d,%d,%d,%d,%d,%d)",
        GetPlayerAccountID(playerid), seller_name, item_id, inv_count, amount, item_plate, item_name,
        item_type, rarity, price, hot, MP_LOT_ACTIVE, created, expires);

    new Cache:insert_result = mysql_query(mysql, query, true);
    new insert_errno = mysql_errno();
    new inserted_lot_id = cache_insert_id();
    cache_delete(insert_result);

    if(inserted_lot_id <= 0)
    {
        printf("[MARKET][ERROR] lot INSERT failed rev=%d player=%d account=%d source=%d item=%d count=%d amount=%d price=%d errno=%d query=%s",
            MARKETPLACE_FIX_REVISION, playerid, GetPlayerAccountID(playerid), source_id, item_id, inv_count, amount, price, insert_errno, query);

        Marketplace_EnsureLotSchema();
        insert_result = mysql_query(mysql, query, true);
        insert_errno = mysql_errno();
        inserted_lot_id = cache_insert_id();
        cache_delete(insert_result);
    }

    if(inserted_lot_id <= 0)
    {
        printf("[MARKET][ERROR] lot INSERT retry failed player=%d source=%d item=%d errno=%d", playerid, source_id, item_id, insert_errno);
        Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 0);
        ShowNotificationSile(playerid, 2, 5, -1, -1, "\xcb\xee\xf2 \xed\xe5 \xe2\xfb\xf1\xf2\xe0\xe2\xeb\xe5\xed. \xcf\xf0\xe5\xe4\xec\xe5\xf2 \xee\xf1\xf2\xe0\xeb\xf1\xff \xe2 \xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xe5.", "");
        return 0;
    }

    new removed;
    if(Marketplace_IsSpecialItem(item_id) || amount >= max_amount)
        removed = Market_DeleteSource(playerid, source_id);
    else
        removed = Inventory_RemoveItem(playerid, source_id, amount);

    if(!removed)
    {
        mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_lots` WHERE `id`=%d LIMIT 1", inserted_lot_id);
        mysql_tquery(mysql, query);
        Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 0);
        ShowNotificationSile(playerid, 2, 5, -1, -1, "\xcb\xee\xf2 \xee\xf2\xec\xe5\xed\xb8\xed: \xef\xf0\xe5\xe4\xec\xe5\xf2 \xed\xe5 \xf3\xe4\xe0\xeb\xee\xf1\xfc \xf3\xe4\xe0\xeb\xe8\xf2\xfc \xe8\xe7 \xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xff.", "");
        return 0;
    }

    g_MP_SelectedSlot[playerid] = -1;
    g_MP_SelectedSellCount[playerid] = 1;

    Marketplace_SendActionResult(playerid, MP_ACT_PUBLISH_LOT, 1);
    Marketplace_SendInventoryProducts(playerid, MP_ACT_CREATE_LOT);
    ShowNotificationSile(playerid, 1, 5, -1, -1, "\xcb\xee\xf2 \xe2\xfb\xf1\xf2\xe0\xe2\xeb\xe5\xed \xed\xe0 \xef\xf0\xee\xe4\xe0\xe6\xf3.", "");
    return 1;
}

stock Marketplace_RequestBuy(playerid, lot_id)
{
    new query[256];
    mysql_format(mysql, query, sizeof(query), "SELECT * FROM `marketplace_lots` WHERE `id`=%d AND `status`=0 AND `expires_at`>%d LIMIT 1", lot_id, gettime());
    mysql_tquery(mysql, query, "Marketplace_OnBuyInfoLoaded", "ii", playerid, lot_id);
    return 1;
}

public Marketplace_OnBuyInfoLoaded(playerid, lot_id)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new rows, fields;
    cache_get_data(rows, fields, mysql);
    if(!rows)
    {
        Marketplace_SendActionResult(playerid, MP_ACT_BUY_CLICK, 0);
        return 0;
    }
    new item_name[64];
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));
    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", MP_ACT_BUY_CLICK);
    JSON_SetInt(json, "id", lot_id);
    new buy_item_id = cache_get_field_content_int(0, "item_id", mysql);
    new buy_item_count = cache_get_field_content_int(0, "item_count", mysql);
    JSON_SetInt(json, "pt", Marketplace_GetProductType(buy_item_id));
    JSON_SetInt(json, "md", Marketplace_GetLotClientModel(buy_item_id, buy_item_count));
    JSON_SetInt(json, "cs", cache_get_field_content_int(0, "price", mysql));
    JSON_SetInt(json, "sl", cache_get_field_content_int(0, "seller_id", mysql));
    JSON_SetInt(json, "ct", cache_get_field_content_int(0, "amount", mysql));
    JSON_SetString(json, "dm", item_name, sizeof(item_name));
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_ReserveLot(lot_id, seller_id = 0, check_expire = 1)
{
    new query[320];

    if(seller_id > 0)
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `seller_id`=%d AND `status`=%d LIMIT 1",
            MP_LOT_RESERVED, lot_id, seller_id, MP_LOT_ACTIVE);
    }
    else if(check_expire)
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `status`=%d AND `expires_at`>%d LIMIT 1",
            MP_LOT_RESERVED, lot_id, MP_LOT_ACTIVE, gettime());
    }
    else
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1",
            MP_LOT_RESERVED, lot_id, MP_LOT_ACTIVE);
    }

    new Cache:result = mysql_query(mysql, query, true);
    new affected = cache_affected_rows(mysql);
    cache_delete(result);
    return affected > 0;
}

stock Marketplace_ReleaseLot(lot_id)
{
    new query[160];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1",
        MP_LOT_ACTIVE, lot_id, MP_LOT_RESERVED);
    mysql_tquery(mysql, query);
    return 1;
}

stock Marketplace_ConfirmBuy(playerid, lot_id, amount)
{
    if(!IsPlayerLogged(playerid)) return 0;
    if(amount < 1) amount = 1;

    if(!Marketplace_ReserveLot(lot_id))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        ShowNotificationSile(playerid, 2, 5, -1, -1, "  .", "");
        return 0;
    }

    new query[1200];
    mysql_format(mysql, query, sizeof(query),
        "SELECT * FROM `marketplace_lots` WHERE `id`=%d AND `status`=%d LIMIT 1",
        lot_id, MP_LOT_RESERVED);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        return 0;
    }

    new seller_id = cache_get_field_content_int(0, "seller_id", mysql);
    new lot_amount = cache_get_field_content_int(0, "amount", mysql);
    new price = cache_get_field_content_int(0, "price", mysql);
    new item_id = cache_get_field_content_int(0, "item_id", mysql);
    new inv_count = cache_get_field_content_int(0, "item_count", mysql);
    new plate[32], item_name[64], seller_name[24], buyer_name[24];

    cache_get_field_content(0, "item_plate", plate, mysql, sizeof(plate));
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));
    cache_get_field_content(0, "seller_name", seller_name, mysql, sizeof(seller_name));
    cache_delete(result);

    if(seller_id == GetPlayerAccountID(playerid))
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        ShowNotificationSile(playerid, 2, 5, -1, -1, "   .", "");
        return 0;
    }

    if(lot_amount < 1 || price < MARKETPLACE_MIN_PRICE || price > MARKETPLACE_MAX_PRICE)
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        return 0;
    }

    if(amount > lot_amount) amount = lot_amount;
    if(amount < 1) amount = 1;

    if(amount > (MARKETPLACE_MAX_TOTAL / price))
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        return 0;
    }

    new total_price = price * amount;
    if(GetPlayerMoneyEx(playerid) < total_price)
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        ShowNotificationSile(playerid, 2, 5, -1, -1, " .", "");
        return 0;
    }

    if(!Marketplace_IsSpecialItem(item_id)) inv_count = amount;

    new bool:queued_to_reward = false;
    new bool:exact_legacy_accessory = Market_IsEncodedAccessoryItem(item_id);
    new freeSlot = exact_legacy_accessory ? -2 : Inventory_GetFreeSlot(playerid);

    if(amount >= lot_amount)
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `status`=%d,`buyer_id`=%d WHERE `id`=%d AND `status`=%d LIMIT 1",
            MP_LOT_SOLD, GetPlayerAccountID(playerid), lot_id, MP_LOT_RESERVED);
    }
    else
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `amount`=`amount`-%d WHERE `id`=%d AND `status`=%d LIMIT 1",
            amount, lot_id, MP_LOT_RESERVED);
    }

    new Cache:update_result = mysql_query(mysql, query, true);
    new updated = cache_affected_rows(mysql);
    cache_delete(update_result);

    if(!updated)
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        return 0;
    }

    if(exact_legacy_accessory)
    {
        if(Market_GiveEncodedAccessory(playerid, item_id) <= 0)
        {
            if(amount >= lot_amount)
                mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `status`=%d,`buyer_id`=0 WHERE `id`=%d LIMIT 1", MP_LOT_ACTIVE, lot_id);
            else
                mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `amount`=`amount`+%d,`status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1", amount, MP_LOT_ACTIVE, lot_id, MP_LOT_RESERVED);
            mysql_tquery(mysql, query);
            Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
            return 0;
        }
    }
    else if(freeSlot == -1)
    {
        if(MPReward_QueueInvItem(GetPlayerAccountID(playerid), item_id, inv_count, plate, item_name, lot_id) <= 0)
        {
            if(amount >= lot_amount)
                mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `status`=%d,`buyer_id`=0 WHERE `id`=%d LIMIT 1", MP_LOT_ACTIVE, lot_id);
            else
                mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `amount`=`amount`+%d,`status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1", amount, MP_LOT_ACTIVE, lot_id, MP_LOT_RESERVED);

            mysql_tquery(mysql, query);
            Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
            ShowNotificationSile(playerid, 2, 5, -1, -1, "     /reward.", "");
            return 0;
        }
        queued_to_reward = true;
    }
    else if(!Inventory_AddItem(playerid, item_id, freeSlot, inv_count, plate))
    {
        if(amount >= lot_amount)
            mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `status`=%d,`buyer_id`=0 WHERE `id`=%d LIMIT 1", MP_LOT_ACTIVE, lot_id);
        else
            mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `amount`=`amount`+%d,`status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1", amount, MP_LOT_ACTIVE, lot_id, MP_LOT_RESERVED);

        mysql_tquery(mysql, query);
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 0);
        return 0;
    }

    if(amount < lot_amount)
    {
        mysql_format(mysql, query, sizeof(query),
            "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1",
            MP_LOT_ACTIVE, lot_id, MP_LOT_RESERVED);
        new Cache:release_result = mysql_query(mysql, query, true);
        new released = cache_affected_rows(mysql);
        cache_delete(release_result);

        if(!released)
        {
            ShowNotificationSile(playerid, 2, 5, -1, -1, " ,    .", "");
        }
    }

    GivePlayerMoneyEx(playerid, -total_price, "Marketplace buy", true, true);

    new seller_tax = ((total_price / 100) * MARKETPLACE_SELL_TAX) + (((total_price % 100) * MARKETPLACE_SELL_TAX) / 100);
    new seller_money = total_price - seller_tax;
    Marketplace_AddMoneyToAccount(seller_id, seller_money);

    format(buyer_name, sizeof(buyer_name), "%s", GetPlayerNameEx(playerid));

    mysql_format(mysql, query, sizeof(query),
        "INSERT INTO `marketplace_history` (`account_id`,`lot_id`,`item_id`,`item_count`,`amount`,`price`,`status`,`seller_name`,`buyer_name`,`item_name`,`created_at`) VALUES (%d,%d,%d,%d,%d,%d,1,'%e','%e','%e',%d),(%d,%d,%d,%d,%d,%d,2,'%e','%e','%e',%d)",
        GetPlayerAccountID(playerid), lot_id, item_id, inv_count, amount, total_price, seller_name, buyer_name, item_name, gettime(),
        seller_id, lot_id, item_id, inv_count, amount, total_price, seller_name, buyer_name, item_name, gettime());
    mysql_tquery(mysql, query);

    mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_favorites` WHERE `lot_id`=%d", lot_id);
    mysql_query(mysql, query);

    new Node:money_json = JSON_Object();
    JSON_SetInt(money_json, "t", MP_ACT_MONEY_UPDATE);
    new synced_money = GetPlayerMoneyEx(playerid);
    if(synced_money > 0)
    {
        JSON_SetInt(money_json, "m", synced_money);
        Marketplace_Send(money_json, playerid);
    }
    JSON_Cleanup(money_json);

    Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_BUY, 1);
    Marketplace_SendLotsRequest(playerid, MP_TAB_MAIN, MP_TAB_MAIN);
    Marketplace_SendLotsRequest(playerid, MP_TAB_FAVORITES, MP_TAB_FAVORITES);

    if(queued_to_reward)
        ShowNotificationSile(playerid, 1, 5, -1, -1, "     /reward:  .", "");
    else
        ShowNotificationSile(playerid, 1, 5, -1, -1, " .  .", "");

    return 1;
}

public Marketplace_OnConfirmBuyLoaded(playerid, lot_id, amount)
{
    #pragma unused playerid
    #pragma unused lot_id
    #pragma unused amount
    return 1;
}

stock Marketplace_DeleteOrWithdrawLot(playerid, lot_id)
{
    if(!IsPlayerLogged(playerid)) return 0;

    if(!Marketplace_ReserveLot(lot_id, GetPlayerAccountID(playerid), 0))
    {
        Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 0);
        return 0;
    }

    new query[384];
    mysql_format(mysql, query, sizeof(query),
        "SELECT * FROM `marketplace_lots` WHERE `id`=%d AND `seller_id`=%d AND `status`=%d LIMIT 1",
        lot_id, GetPlayerAccountID(playerid), MP_LOT_RESERVED);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 0);
        return 0;
    }

    new item_id = cache_get_field_content_int(0, "item_id", mysql);
    new inv_count = cache_get_field_content_int(0, "item_count", mysql);
    new amount = cache_get_field_content_int(0, "amount", mysql);
    new plate[32], item_name[64];

    cache_get_field_content(0, "item_plate", plate, mysql, sizeof(plate));
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));
    cache_delete(result);

    if(!Marketplace_IsSpecialItem(item_id)) inv_count = amount;

    mysql_format(mysql, query, sizeof(query),
        "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d AND `status`=%d LIMIT 1",
        MP_LOT_WITHDRAWN, lot_id, MP_LOT_RESERVED);

    new Cache:update_result = mysql_query(mysql, query, true);
    new updated = cache_affected_rows(mysql);
    cache_delete(update_result);

    if(!updated)
    {
        Marketplace_ReleaseLot(lot_id);
        Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 0);
        return 0;
    }

    new bool:returned_to_reward = false;
    new bool:exact_legacy_accessory = Market_IsEncodedAccessoryItem(item_id);
    new freeSlot = exact_legacy_accessory ? -2 : Inventory_GetFreeSlot(playerid);

    if(exact_legacy_accessory)
    {
        if(Market_GiveEncodedAccessory(playerid, item_id) <= 0)
        {
            mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d LIMIT 1", MP_LOT_ACTIVE, lot_id);
            mysql_tquery(mysql, query);
            Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 0);
            return 0;
        }
    }
    else if(freeSlot == -1)
    {
        if(MPReward_QueueInvItem(GetPlayerAccountID(playerid), item_id, inv_count, plate, item_name, lot_id) <= 0)
        {
            mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d LIMIT 1", MP_LOT_ACTIVE, lot_id);
            mysql_tquery(mysql, query);
            Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 0);
            ShowNotificationSile(playerid, 2, 5, -1, -1, "     /reward.", "");
            return 0;
        }
        returned_to_reward = true;
    }
    else if(!Inventory_AddItem(playerid, item_id, freeSlot, inv_count, plate))
    {
        mysql_format(mysql, query, sizeof(query), "UPDATE `marketplace_lots` SET `status`=%d WHERE `id`=%d LIMIT 1", MP_LOT_ACTIVE, lot_id);
        mysql_tquery(mysql, query);
        Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 0);
        return 0;
    }

    mysql_format(mysql, query, sizeof(query), "DELETE FROM `marketplace_favorites` WHERE `lot_id`=%d", lot_id);
    mysql_query(mysql, query);

    Marketplace_SendActionResult(playerid, MP_ACT_DELETE_LOT, 1);
    Marketplace_SendLotsRequest(playerid, MP_TAB_MY_STORE, MP_TAB_MY_STORE);

    if(returned_to_reward)
        ShowNotificationSile(playerid, 1, 5, -1, -1, " ,    /reward.", "");
    else
        ShowNotificationSile(playerid, 1, 5, -1, -1, "     .", "");

    return 1;
}

public Marketplace_OnWithdrawLoaded(playerid, lot_id)
{
    #pragma unused playerid
    #pragma unused lot_id
    return 1;
}

stock Marketplace_EditLot(playerid, lot_id, price)
{
    if(price < MARKETPLACE_MIN_PRICE || price > MARKETPLACE_MAX_PRICE)
    {
        Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_EDIT, 0);
        return 0;
    }

    new query[320];
    mysql_format(mysql, query, sizeof(query),
        "UPDATE `marketplace_lots` SET `price`=%d WHERE `id`=%d AND `seller_id`=%d AND `status`=%d AND `amount`<=%d LIMIT 1",
        price, lot_id, GetPlayerAccountID(playerid), MP_LOT_ACTIVE, MARKETPLACE_MAX_TOTAL / price);

    new Cache:result = mysql_query(mysql, query, true);
    new affected = cache_affected_rows(mysql);
    cache_delete(result);

    Marketplace_SendActionResult(playerid, MP_ACT_CONFIRM_EDIT, affected > 0);
    if(affected > 0)
        Marketplace_SendLotsRequest(playerid, MP_TAB_MY_STORE, MP_TAB_MY_STORE);
    else
        ShowNotificationSile(playerid, 2, 5, -1, -1, "  :     .", "");
    return affected > 0;
}

stock Marketplace_RequestEdit(playerid, lot_id)
{
    new query[384];
    mysql_format(mysql, query, sizeof(query),
        "SELECT * FROM `marketplace_lots` WHERE `id`=%d AND `seller_id`=%d AND `status`=%d LIMIT 1",
        lot_id, GetPlayerAccountID(playerid), MP_LOT_ACTIVE);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        Marketplace_SendActionResult(playerid, MP_ACT_EDIT_LOT, 0);
        return 0;
    }

    new item_name[64];
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));

    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", MP_ACT_EDIT_LOT);
    JSON_SetInt(json, "err", 1);
    JSON_SetInt(json, "id", lot_id);
    new edit_item_id = cache_get_field_content_int(0, "item_id", mysql);
    new edit_item_count = cache_get_field_content_int(0, "item_count", mysql);
    JSON_SetInt(json, "pt", Marketplace_GetProductType(edit_item_id));
    JSON_SetInt(json, "md", Marketplace_GetLotClientModel(edit_item_id, edit_item_count));
    JSON_SetInt(json, "cs", cache_get_field_content_int(0, "price", mysql));
    JSON_SetInt(json, "ct", cache_get_field_content_int(0, "amount", mysql));
    JSON_SetInt(json, "rs", cache_get_field_content_int(0, "is_hot", mysql));
    JSON_SetString(json, "dm", item_name, sizeof(item_name));
    cache_delete(result);

    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_ToggleLike(playerid, lot_id)
{
    if(lot_id <= 0 || !IsPlayerLogged(playerid)) return 0;

    new query[384];
    mysql_format(mysql, query, sizeof(query),
        "SELECT `lot_id` FROM `marketplace_favorites` WHERE `account_id`=%d AND `lot_id`=%d LIMIT 1",
        GetPlayerAccountID(playerid), lot_id);

    new Cache:result = mysql_query(mysql, query, true);
    new liked = cache_num_rows() > 0;
    cache_delete(result);

    if(liked)
    {
        mysql_format(mysql, query, sizeof(query),
            "DELETE FROM `marketplace_favorites` WHERE `account_id`=%d AND `lot_id`=%d LIMIT 1",
            GetPlayerAccountID(playerid), lot_id);

        new Cache:delete_result = mysql_query(mysql, query, true);
        new changed = cache_affected_rows(mysql);
        cache_delete(delete_result);
        if(!changed) return Marketplace_SendActionResult(playerid, MP_ACT_LIKE, 0);
        liked = 0;
    }
    else
    {
        mysql_format(mysql, query, sizeof(query),
            "INSERT IGNORE INTO `marketplace_favorites` (`account_id`,`lot_id`,`created_at`) SELECT %d,`id`,%d FROM `marketplace_lots` WHERE `id`=%d AND `status`=%d AND `expires_at`>%d LIMIT 1",
            GetPlayerAccountID(playerid), gettime(), lot_id, MP_LOT_ACTIVE, gettime());

        new Cache:insert_result = mysql_query(mysql, query, true);
        new changed = cache_affected_rows(mysql);
        cache_delete(insert_result);
        if(!changed) return Marketplace_SendActionResult(playerid, MP_ACT_LIKE, 0);
        liked = 1;
    }

    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", MP_ACT_LIKE);
    JSON_SetInt(json, "err", 1);
    JSON_SetInt(json, "id", lot_id);
    JSON_SetInt(json, "l", liked);
    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);

    if(g_MP_CurrentTab[playerid] == MP_TAB_FAVORITES && !liked)
        Marketplace_SendLotsRequest(playerid, MP_TAB_FAVORITES, MP_TAB_FAVORITES);

    return 1;
}

stock Marketplace_RequestHistoryInfo(playerid, lot_id)
{
    new query[384];
    mysql_format(mysql, query, sizeof(query),
        "SELECT * FROM `marketplace_history` WHERE `account_id`=%d AND `lot_id`=%d ORDER BY `id` DESC LIMIT 1",
        GetPlayerAccountID(playerid), lot_id);

    new Cache:result = mysql_query(mysql, query, true);
    if(!cache_num_rows())
    {
        cache_delete(result);
        Marketplace_SendActionResult(playerid, MP_ACT_HISTORY_CARD, 0);
        return 0;
    }

    new item_name[64], seller_name[24];
    cache_get_field_content(0, "item_name", item_name, mysql, sizeof(item_name));
    cache_get_field_content(0, "seller_name", seller_name, mysql, sizeof(seller_name));

    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", MP_ACT_HISTORY_CARD);
    JSON_SetInt(json, "err", 1);
    JSON_SetInt(json, "id", lot_id);
    new history_item_id = cache_get_field_content_int(0, "item_id", mysql);
    new history_item_count = cache_get_field_content_int(0, "item_count", mysql);
    JSON_SetInt(json, "pt", Marketplace_GetProductType(history_item_id));
    JSON_SetInt(json, "md", Marketplace_GetLotClientModel(history_item_id, history_item_count));
    JSON_SetInt(json, "cs", cache_get_field_content_int(0, "price", mysql));
    JSON_SetInt(json, "ct", cache_get_field_content_int(0, "amount", mysql));
    JSON_SetInt(json, "st", cache_get_field_content_int(0, "status", mysql));
    JSON_SetString(json, "dm", item_name, sizeof(item_name));
    JSON_SetString(json, "nm", seller_name, sizeof(seller_name));
    cache_delete(result);

    Marketplace_Send(json, playerid);
    JSON_Cleanup(json);
    return 1;
}

stock Marketplace_OnPacket(playerid, Node:json)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid)) return 0;

    new type;
    JSON_GetInt(json, "t", type);

    switch(type)
    {
        case MP_TAB_PROFILE:
        {
            Marketplace_SendProfile(playerid);
        }
        case MP_TAB_MAIN:
        {
            g_MP_CurrentTab[playerid] = MP_TAB_MAIN;
            g_MP_CurrentPage[playerid] = 0;
            g_MP_Search[playerid][0] = EOS;
            Marketplace_SendLotsRequest(playerid, MP_TAB_MAIN, MP_TAB_MAIN);
        }
        case MP_TAB_HISTORY:
        {
            g_MP_CurrentTab[playerid] = MP_TAB_HISTORY;
            Marketplace_SendHistory(playerid);
        }
        case MP_TAB_FAVORITES:
        {
            g_MP_CurrentTab[playerid] = MP_TAB_FAVORITES;
            g_MP_CurrentPage[playerid] = 0;
            Marketplace_SendLotsRequest(playerid, MP_TAB_FAVORITES, MP_TAB_FAVORITES);
        }
        case MP_TAB_MY_STORE:
        {
            g_MP_CurrentTab[playerid] = MP_TAB_MY_STORE;
            g_MP_CurrentPage[playerid] = 0;
            Marketplace_SendLotsRequest(playerid, MP_TAB_MY_STORE, MP_TAB_MY_STORE);
        }
        case MP_TAB_INVENTORY:
        {
            g_MP_CurrentTab[playerid] = MP_TAB_INVENTORY;
            Marketplace_SendInventoryProducts(playerid, MP_TAB_INVENTORY);
        }
        case MP_ACT_PAGE:
        {
            new page;
            JSON_GetInt(json, "lt", page);
            if(page < 0) page = 0;
            g_MP_CurrentPage[playerid] = page;
            Marketplace_SendLotsRequest(playerid, MP_ACT_PAGE, g_MP_CurrentTab[playerid]);
        }
        case MP_ACT_CREATE_LOT:
        {
            Marketplace_SendInventoryProducts(playerid, MP_ACT_CREATE_LOT);
        }
        case MP_ACT_SELECT_INV_ITEM:
        {
            new slot;
            JSON_GetInt(json, "id", slot);
            Marketplace_SelectInventorySlot(playerid, slot);
        }
        case MP_ACT_PUBLISH_LOT:
        {
            new amount, price, hot;
            JSON_GetInt(json, "ct", amount);
            JSON_GetInt(json, "cs", price);
            JSON_GetInt(json, "rs", hot);
            Marketplace_PublishSelected(playerid, amount, price, hot);
        }
        case MP_ACT_BUY_CLICK:
        {
            new lot_id;
            JSON_GetInt(json, "id", lot_id);
            g_MP_SelectedLot[playerid] = lot_id;
            Marketplace_RequestBuy(playerid, lot_id);
        }
        case MP_ACT_CONFIRM_BUY:
        {
            new lot_id, amount;
            JSON_GetInt(json, "id", lot_id);
            JSON_GetInt(json, "ct", amount);
            if(lot_id <= 0) lot_id = g_MP_SelectedLot[playerid];
            Marketplace_ConfirmBuy(playerid, lot_id, amount);
        }
        case MP_ACT_EDIT_LOT:
        {
            new lot_id;
            JSON_GetInt(json, "id", lot_id);
            g_MP_SelectedLot[playerid] = lot_id;
            Marketplace_RequestEdit(playerid, lot_id);
        }
        case MP_ACT_CONFIRM_EDIT:
        {
            new lot_id, price;
            JSON_GetInt(json, "id", lot_id);
            JSON_GetInt(json, "cs", price);
            if(lot_id <= 0) lot_id = g_MP_SelectedLot[playerid];
            Marketplace_EditLot(playerid, lot_id, price);
        }
        case MP_ACT_DELETE_LOT:
        {
            new lot_id;
            JSON_GetInt(json, "id", lot_id);
            if(lot_id <= 0) lot_id = g_MP_SelectedLot[playerid];
            Marketplace_DeleteOrWithdrawLot(playerid, lot_id);
        }
        case MP_ACT_HISTORY_CARD:
        {
            new lot_id;
            JSON_GetInt(json, "id", lot_id);
            Marketplace_RequestHistoryInfo(playerid, lot_id);
        }
        case MP_ACT_SEARCH:
        {
            JSON_GetString(json, "s", g_MP_Search[playerid], 64);
            g_MP_CurrentPage[playerid] = 0;
            Marketplace_SendLotsRequest(playerid, MP_ACT_SEARCH, g_MP_CurrentTab[playerid]);
        }
        case MP_ACT_SORT:
        {
            new sort;
            JSON_GetInt(json, "st", sort);
            if(sort < 0 || sort > 2) sort = 0;
            g_MP_Sort[playerid] = sort;
            Marketplace_SendLotsRequest(playerid, MP_ACT_SORT, g_MP_CurrentTab[playerid]);
        }
        case MP_ACT_LIKE:
        {
            new lot_id;
            JSON_GetInt(json, "id", lot_id);
            Marketplace_ToggleLike(playerid, lot_id);
        }
        case MP_ACT_FILTER, MP_ACT_DOTS_UPDATE, MP_ACT_LIKED_ARRAY:
        {
            Marketplace_SendLotsRequest(playerid, type, g_MP_CurrentTab[playerid]);
        }
        case MP_ACT_MONEY_UPDATE:
        {
            new Node:response = JSON_Object();
            JSON_SetInt(response, "t", MP_ACT_MONEY_UPDATE);
            JSON_SetInt(response, "m", GetPlayerMoneyEx(playerid));
            Marketplace_Send(response, playerid);
            JSON_Cleanup(response);
        }
        case MP_ACT_BUY_VIP, MP_ACT_DONATE, MP_ACT_NOTIFY_VIP:
        {
            Marketplace_SendActionResult(playerid, type, 0);
        }
        default:
        {
            Marketplace_SendLotsRequest(playerid, MP_TAB_MAIN, MP_TAB_MAIN);
        }
    }
    return 1;
}

CMD:marketplace(playerid, params[])
{
    #pragma unused params
    Marketplace_OpenGUI(playerid);
    return 1;
}

CMD:market(playerid, params[])
{
    #pragma unused params
    Marketplace_OpenGUI(playerid);
    return 1;
}

CMD:marketmoney(playerid, params[])
{
    #pragma unused params
    Marketplace_ClaimMoney(playerid, 1);
    return 1;
}

stock Marketplace_ShowDialogMain(playerid)
{
    ShowPlayerDialog(playerid, MP_DIALOG_MAIN, DIALOG_STYLE_LIST, "\xcc\xe0\xf0\xea\xe5\xf2\xef\xeb\xe5\xe9\xf1", "\xce\xf2\xea\xf0\xfb\xf2\xfc\x20\x47\x55\x49\n\xca\xf3\xef\xe8\xf2\xfc\x20\xef\xf0\xe5\xe4\xec\xe5\xf2\xfb\n\xcf\xf0\xee\xe4\xe0\xf2\xfc\x20\xef\xf0\xe5\xe4\xec\xe5\xf2\x20\xe8\xe7\x20\xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xff\n\xcc\xee\xe8\x20\xeb\xee\xf2\xfb\n\xcf\xee\xe8\xf1\xea", "\xc2\xfb\xe1\xf0\xe0\xf2\xfc", "\xc7\xe0\xea\xf0\xfb\xf2\xfc");
    return 1;
}

CMD:marketd(playerid, params[])
{
    #pragma unused params
    if(!IsPlayerLogged(playerid)) return SendClientMessage(playerid, 0xCECECEFF, "\xc2\xfb\x20\xe4\xee\xeb\xe6\xed\xfb\x20\xe0\xe2\xf2\xee\xf0\xe8\xe7\xee\xe2\xe0\xf2\xfc\xf1\xff\x2e");
    Marketplace_ShowDialogMain(playerid);
    return 1;
}

stock Marketplace_ShowDialogLots(playerid, my_lots = 0)
{
    new query[384];
    if(my_lots)
    {
        mysql_format(mysql, query, sizeof(query), "SELECT * FROM `marketplace_lots` WHERE `seller_id`=%d AND `status`=0 ORDER BY `id` DESC LIMIT 30", GetPlayerAccountID(playerid));
        mysql_tquery(mysql, query, "Marketplace_OnDialogLots", "ii", playerid, 1);
    }
    else
    {
        mysql_format(mysql, query, sizeof(query), "SELECT * FROM `marketplace_lots` WHERE `status`=0 AND `expires_at`>%d ORDER BY `is_hot` DESC, `id` DESC LIMIT 30", gettime());
        mysql_tquery(mysql, query, "Marketplace_OnDialogLots", "ii", playerid, 0);
    }
    return 1;
}

public Marketplace_OnDialogLots(playerid, my_lots)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new rows, fields;
    cache_get_data(rows, fields, mysql);
    new list[2048];
    list[0] = EOS;
    if(!rows) strcat(list, "\xcb\xee\xf2\xee\xe2\x20\xed\xe5\xf2\n", sizeof(list));
    for(new i = 0; i < rows && i < 30; i++)
    {
        new lot_id = cache_get_field_content_int(i, "id", mysql);
        new amount = cache_get_field_content_int(i, "amount", mysql);
        new price = cache_get_field_content_int(i, "price", mysql);
        new item_name[64], lot_line[128];
        cache_get_field_content(i, "item_name", item_name, mysql, sizeof item_name);
        format(lot_line, sizeof lot_line, "#%d %s x%d - %d rub\n", lot_id, item_name, amount, price);
        strcat(list, lot_line, sizeof list);
    }
    ShowPlayerDialog(playerid, my_lots ? MP_DIALOG_MYLOTS : MP_DIALOG_LOTS, DIALOG_STYLE_LIST, my_lots ? "\xcc\xee\xe8\x20\xeb\xee\xf2\xfb" : "\xcb\xee\xf2\xfb\x20\xec\xe0\xf0\xea\xe5\xf2\xef\xeb\xe5\xe9\xf1\xe0", list, "\xc2\xfb\xe1\xf0\xe0\xf2\xfc", "\xcd\xe0\xe7\xe0\xe4");
    return 1;
}

stock Marketplace_ShowInventoryDialog(playerid)
{
    Market_RefreshAccessoryCache(playerid);

    new list[2048];
    list[0] = EOS;

    for(new i = 0; i < MAX_INVENTORY_SLOTS; i++)
    {
        if(!Market_CanSellSource(playerid, i)) continue;
        new mp_inv_line[128], mp_inv_name[64];
        Marketplace_GetInventoryName(playerid, i, mp_inv_name, sizeof(mp_inv_name));
        format(mp_inv_line, sizeof(mp_inv_line), "slot %d: %s\n", i, mp_inv_name);
        strcat(list, mp_inv_line, sizeof(list));
    }

    for(new active_slot = 0; active_slot < MAX_ACTIVE_SLOTS; active_slot++)
    {
        new source_id = Market_MakeActiveSource(active_slot);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new mp_inv_line[128], mp_inv_name[64];
        Marketplace_GetInventoryName(playerid, source_id, mp_inv_name, sizeof(mp_inv_name));
        format(mp_inv_line, sizeof(mp_inv_line), "slot %d: %s [active]\n", source_id, mp_inv_name);
        strcat(list, mp_inv_line, sizeof(list));
    }

    for(new accessory_slot = 0; accessory_slot < MARKET_SOURCE_ACCESSORY_SLOTS; accessory_slot++)
    {
        new source_id = Market_MakeAccessorySource(accessory_slot);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new mp_inv_line[128], mp_inv_name[64];
        Marketplace_GetInventoryName(playerid, source_id, mp_inv_name, sizeof(mp_inv_name));
        format(mp_inv_line, sizeof(mp_inv_line), "slot %d: %s [equipped accessory]\n", source_id, mp_inv_name);
        strcat(list, mp_inv_line, sizeof(list));
    }

    for(new owned_accessory = 0; owned_accessory < MARKET_SOURCE_OWNED_ACCESSORY_MAX; owned_accessory++)
    {
        new source_id = Market_MakeOwnedAccessorySource(owned_accessory);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new mp_inv_line[128], mp_inv_name[64];
        Marketplace_GetInventoryName(playerid, source_id, mp_inv_name, sizeof(mp_inv_name));
        format(mp_inv_line, sizeof(mp_inv_line), "slot %d: %s [owned accessory]\n", source_id, mp_inv_name);
        strcat(list, mp_inv_line, sizeof(list));
    }

    for(new owned_skin = 0; owned_skin < MARKET_SOURCE_OWNED_SKIN_MAX; owned_skin++)
    {
        new source_id = Market_MakeOwnedSkinSource(owned_skin);
        if(!Market_CanSellSource(playerid, source_id)) continue;
        new mp_inv_line[128], mp_inv_name[64];
        Marketplace_GetInventoryName(playerid, source_id, mp_inv_name, sizeof(mp_inv_name));
        format(mp_inv_line, sizeof(mp_inv_line), "slot %d: %s [owned skin]\n", source_id, mp_inv_name);
        strcat(list, mp_inv_line, sizeof(list));
    }

    if(!strlen(list)) strcat(list, "No accessories, skins or SIM cards\n", sizeof(list));
    ShowPlayerDialog(playerid, MP_DIALOG_INV, DIALOG_STYLE_LIST, "Marketplace inventory", list, "Sell", "Back");
    return 1;
}

stock Marketplace_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == MP_DIALOG_MAIN)
    {
        if(!response) return 1;
        switch(listitem)
        {
            case 0: Marketplace_OpenGUI(playerid);
            case 1: Marketplace_ShowDialogLots(playerid, 0);
            case 2: Marketplace_ShowInventoryDialog(playerid);
            case 3: Marketplace_ShowDialogLots(playerid, 1);
            case 4: ShowPlayerDialog(playerid, MP_DIALOG_SEARCH, DIALOG_STYLE_INPUT, "\xcf\xee\xe8\xf1\xea\x20\xe2\x20\xec\xe0\xf0\xea\xe5\xf2\xef\xeb\xe5\xe9\xf1\xe5", "\xc2\xe2\xe5\xe4\xe8\xf2\xe5\x20\xed\xe0\xe7\xe2\xe0\xed\xe8\xe5\x20\xef\xf0\xe5\xe4\xec\xe5\xf2\xe0\x3a", "\xcf\xee\xe8\xf1\xea", "\xcd\xe0\xe7\xe0\xe4");
        }
        return 1;
    }
    if(dialogid == MP_DIALOG_LOTS)
    {
        if(!response) return Marketplace_ShowDialogMain(playerid);
        new lot_id;
        if(sscanf(inputtext, "p<#>i", lot_id)) return 1;
        g_MP_SelectedLot[playerid] = lot_id;
        ShowPlayerDialog(playerid, MP_DIALOG_LOT_ACTION, DIALOG_STYLE_INPUT, "\xcf\xee\xea\xf3\xef\xea\xe0\x20\xeb\xee\xf2\xe0", "\xc2\xe2\xe5\xe4\xe8\xf2\xe5\x20\xea\xee\xeb\xe8\xf7\xe5\xf1\xf2\xe2\xee\x20\xe4\xeb\xff\x20\xef\xee\xea\xf3\xef\xea\xe8\x3a", "\xca\xf3\xef\xe8\xf2\xfc", "\xcd\xe0\xe7\xe0\xe4");
        return 1;
    }
    if(dialogid == MP_DIALOG_LOT_ACTION)
    {
        if(!response) return Marketplace_ShowDialogLots(playerid, 0);
        new amount = strval(inputtext);
        if(amount < 1) amount = 1;
        Marketplace_ConfirmBuy(playerid, g_MP_SelectedLot[playerid], amount);
        return 1;
    }
    if(dialogid == MP_DIALOG_INV)
    {
        if(!response) return Marketplace_ShowDialogMain(playerid);
        new slot = -1;
        if(strfind(inputtext, "slot ", true) == 0)
        {
            new colon = strfind(inputtext, ":", true), tmp[12];
            if(colon != -1)
            {
                strmid(tmp, inputtext, 5, colon, sizeof(tmp));
                slot = strval(tmp);
            }
        }
        if(!Market_CanSellSource(playerid, slot)) return 1;
        g_MP_SelectedSlot[playerid] = slot;
        ShowPlayerDialog(playerid, MP_DIALOG_SELL_COUNT, DIALOG_STYLE_INPUT, "\xca\xee\xeb\xe8\xf7\xe5\xf1\xf2\xe2\xee\x20\xe4\xeb\xff\x20\xef\xf0\xee\xe4\xe0\xe6\xe8", "\xc2\xe2\xe5\xe4\xe8\xf2\xe5\x20\xea\xee\xeb\xe8\xf7\xe5\xf1\xf2\xe2\xee\x3a", "\xc4\xe0\xeb\xe5\xe5", "\xcd\xe0\xe7\xe0\xe4");
        return 1;
    }
    if(dialogid == MP_DIALOG_SELL_COUNT)
    {
        if(!response) return Marketplace_ShowInventoryDialog(playerid);
        new amount = strval(inputtext), max_amount = Marketplace_GetSlotSellAmount(playerid, g_MP_SelectedSlot[playerid]);
        if(amount < 1) amount = 1;
        if(amount > max_amount) amount = max_amount;
        g_MP_SelectedSellCount[playerid] = amount;
        ShowPlayerDialog(playerid, MP_DIALOG_SELL_PRICE, DIALOG_STYLE_INPUT, "\xd6\xe5\xed\xe0\x20\xef\xf0\xee\xe4\xe0\xe6\xe8", "\xc2\xe2\xe5\xe4\xe8\xf2\xe5\x20\xf6\xe5\xed\xf3\x20\xe7\xe0\x20\x31\x20\xef\xf0\xe5\xe4\xec\xe5\xf2\x3a", "\xc2\xfb\xf1\xf2\xe0\xe2\xe8\xf2\xfc", "\xcd\xe0\xe7\xe0\xe4");
        return 1;
    }
    if(dialogid == MP_DIALOG_SELL_PRICE)
    {
        if(!response) return Marketplace_ShowInventoryDialog(playerid);
        new price = strval(inputtext);
        Marketplace_PublishSelected(playerid, g_MP_SelectedSellCount[playerid], price, 0);
        return 1;
    }
    if(dialogid == MP_DIALOG_MYLOTS)
    {
        if(!response) return Marketplace_ShowDialogMain(playerid);
        new lot_id;
        if(sscanf(inputtext, "p<#>i", lot_id)) return 1;
        g_MP_SelectedLot[playerid] = lot_id;
        ShowPlayerDialog(playerid, MP_DIALOG_MYLOT_ACTION, DIALOG_STYLE_LIST, "\xcc\xee\xe9\x20\xeb\xee\xf2", "\xd1\xed\xff\xf2\xfc\x20\xe2\x20\xe8\xed\xe2\xe5\xed\xf2\xe0\xf0\xfc\n\xc8\xe7\xec\xe5\xed\xe8\xf2\xfc\x20\xf6\xe5\xed\xf3", "\xc2\xfb\xe1\xf0\xe0\xf2\xfc", "\xcd\xe0\xe7\xe0\xe4");
        return 1;
    }
    if(dialogid == MP_DIALOG_MYLOT_ACTION)
    {
        if(!response) return Marketplace_ShowDialogLots(playerid, 1);
        if(listitem == 0) Marketplace_DeleteOrWithdrawLot(playerid, g_MP_SelectedLot[playerid]);
        else ShowPlayerDialog(playerid, MP_DIALOG_EDIT_PRICE, DIALOG_STYLE_INPUT, "\xcd\xee\xe2\xe0\xff\x20\xf6\xe5\xed\xe0", "\xc2\xe2\xe5\xe4\xe8\xf2\xe5\x20\xed\xee\xe2\xf3\xfe\x20\xf6\xe5\xed\xf3\x3a", "\xd1\xee\xf5\xf0\xe0\xed\xe8\xf2\xfc", "\xcd\xe0\xe7\xe0\xe4");
        return 1;
    }
    if(dialogid == MP_DIALOG_EDIT_PRICE)
    {
        if(!response) return Marketplace_ShowDialogLots(playerid, 1);
        new price = strval(inputtext);
        Marketplace_EditLot(playerid, g_MP_SelectedLot[playerid], price);
        return 1;
    }
    if(dialogid == MP_DIALOG_SEARCH)
    {
        if(!response) return Marketplace_ShowDialogMain(playerid);
        format(g_MP_Search[playerid], 64, "%s", inputtext);
        Marketplace_SendLotsRequest(playerid, MP_ACT_SEARCH, MP_TAB_MAIN);
        Marketplace_ShowDialogLots(playerid, 0);
        return 1;
    }
    return 0;
}