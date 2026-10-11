#if defined _inc_contnewsystem
    #endinput
#endif
#define _inc_contnewsystem

// BEGIN INLINED: contnewsystem_data.inc
#if defined _inc_contnewsystem_data
    #endinput
#endif
#define _inc_contnewsystem_data

#define CONT_NEW_SLOT_COUNT (15)
#define CONT_NEW_TYPE_COUNT (7)
#define CONT_NEW_AWARD_COUNT (247)
#define CONT_NEW_MAX_TYPE_AWARDS (55)

enum E_CONT_NEW_SLOT_DATA
{
    Float:CNS_POS_X,
    Float:CNS_POS_Y,
    Float:CNS_POS_Z,
    Float:CNS_POS_RX,
    Float:CNS_POS_RY,
    Float:CNS_POS_RZ,
    Float:CNS_LC_X,
    Float:CNS_LC_Y,
    Float:CNS_LC_Z,
    Float:CNS_LC_RX,
    Float:CNS_LC_RY,
    Float:CNS_LC_RZ,
    Float:CNS_RC_X,
    Float:CNS_RC_Y,
    Float:CNS_RC_Z,
    Float:CNS_RC_RX,
    Float:CNS_RC_RY,
    Float:CNS_RC_RZ,
    Float:CNS_LO_X,
    Float:CNS_LO_Y,
    Float:CNS_LO_Z,
    Float:CNS_LO_RX,
    Float:CNS_LO_RY,
    Float:CNS_LO_RZ,
    Float:CNS_RO_X,
    Float:CNS_RO_Y,
    Float:CNS_RO_Z,
    Float:CNS_RO_RX,
    Float:CNS_RO_RY,
    Float:CNS_RO_RZ
};

new const Float:g_cont_new_slots[CONT_NEW_SLOT_COUNT][E_CONT_NEW_SLOT_DATA] =
{
    {655.039, 1670.02, 11.125, 0.0, 0.0, -90.0, 650.171, 1671.6, 11.5034, 0.0, 0.0, -90.0, 650.171, 1668.44, 11.5034, 0.0, 0.0, -90.0, 650.171, 1671.6, 11.5034, 0.0, 0.0, -235.0, 650.171, 1668.44, 11.5034, 0.0, 0.0, 55.0},
    {655.12, 1675.81, 11.125, 0.0, 0.0, -96.0, 650.444, 1677.89, 11.5034, 0.0, 0.0, -96.0, 650.113, 1674.74, 11.5034, 0.0, 0.0, -96.0, 650.444, 1677.89, 11.5034, 0.0, 0.0, -241.0, 650.113, 1674.74, 11.5034, 0.0, 0.0, 49.0},
    {655.705, 1682.56, 11.125, 0.0, 0.0, -90.0, 650.837, 1684.14, 11.5034, 0.0, 0.0, -90.0, 650.837, 1680.98, 11.5034, 0.0, 0.0, -90.0, 650.837, 1684.14, 11.5034, 0.0, 0.0, -240.0, 650.837, 1680.98, 11.5034, 0.0, 0.0, 55.0},
    {655.605, 1689.03, 11.125, 0.0, 0.0, -91.0, 650.764, 1690.69, 11.5034, 0.0, 0.0, -91.0, 650.711, 1687.53, 11.5034, 0.0, 0.0, -91.0, 650.764, 1690.69, 11.5034, 0.0, 0.0, -240.0, 650.711, 1687.53, 11.5034, 0.0, 0.0, 54.0},
    {655.114, 1696.25, 11.125, 0.0, 0.0, -82.0, 650.073, 1697.14, 11.5034, 0.0, 0.0, -82.0, 650.513, 1694.01, 11.5034, 0.0, 0.0, -82.0, 650.073, 1697.14, 11.5034, 0.0, 0.0, -240.0, 650.513, 1694.01, 11.5034, 0.0, 0.0, 63.0},
    {655.424, 1703.58, 11.125, 0.0, 0.0, -89.0, 650.529, 1705.07, 11.5034, 0.0, 0.0, -89.0, 650.584, 1701.91, 11.5034, 0.0, 0.0, -89.0, 650.529, 1705.07, 11.5034, 0.0, 0.0, -240.0, 650.584, 1701.91, 11.5034, 0.0, 0.0, 56.0},
    {654.753, 1712.07, 11.125, 0.0, 0.0, -75.0, 649.641, 1712.34, 11.5034, 0.0, 0.0, -75.0, 650.46, 1709.29, 11.5034, 0.0, 0.0, -75.0, 649.641, 1712.34, 11.5034, 0.0, 0.0, -240.0, 650.46, 1709.29, 11.5034, 0.0, 0.0, 70.0},
    {634.29, 1671.35, 11.125, 0.0, 0.0, 94.0, 639.256, 1670.11, 11.5034, 0.0, 0.0, 94.0, 639.035, 1673.27, 11.5034, 0.0, 0.0, 94.0, 639.256, 1670.11, 11.5034, 0.0, 0.0, -51.0, 639.035, 1673.27, 11.5034, 0.0, 0.0, 240.0},
    {633.882, 1677.97, 11.125, 0.0, 0.0, 95.0, 638.869, 1676.82, 11.5034, 0.0, 0.0, 95.0, 638.593, 1679.97, 11.5034, 0.0, 0.0, 95.0, 638.869, 1676.82, 11.5034, 0.0, 0.0, -50.0, 638.593, 1679.97, 11.5034, 0.0, 0.0, 240.0},
    {634.889, 1685.26, 11.125, 0.0, 0.0, 90.0, 639.757, 1683.68, 11.5034, 0.0, 0.0, 90.0, 639.757, 1686.85, 11.5034, 0.0, 0.0, 90.0, 639.757, 1683.68, 11.5034, 0.0, 0.0, -55.0, 639.757, 1686.85, 11.5034, 0.0, 0.0, 240.0},
    {634.264, 1691.22, 11.125, 0.0, 0.0, 89.0, 639.103, 1689.55, 11.5034, 0.0, 0.0, 89.0, 639.159, 1692.72, 11.5034, 0.0, 0.0, 89.0, 639.103, 1689.55, 11.5034, 0.0, 0.0, -56.0, 639.159, 1692.72, 11.5034, 0.0, 0.0, 240.0},
    {633.583, 1696.95, 11.125, 0.0, 0.0, 92.0, 638.504, 1695.54, 11.5034, 0.0, 0.0, 92.0, 638.393, 1698.7, 11.5034, 0.0, 0.0, 92.0, 638.504, 1695.54, 11.5034, 0.0, 0.0, -53.0, 638.393, 1698.7, 11.5034, 0.0, 0.0, 240.0},
    {634.567, 1703.73, 11.125, 0.0, 0.0, 85.0, 639.279, 1701.73, 11.5034, 0.0, 0.0, 85.0, 639.554, 1704.88, 11.5034, 0.0, 0.0, 85.0, 639.279, 1701.73, 11.5034, 0.0, 0.0, -60.0, 639.554, 1704.88, 11.5034, 0.0, 0.0, 240.0},
    {634.476, 1710.03, 11.125, 0.0, 0.0, 88.0, 639.286, 1708.28, 11.5034, 0.0, 0.0, 88.0, 639.396, 1711.44, 11.5034, 0.0, 0.0, 88.0, 639.286, 1708.28, 11.5034, 0.0, 0.0, -57.0, 639.396, 1711.44, 11.5034, 0.0, 0.0, 240.0},
    {644.17, 1662.19, 11.1249, 0.0, 0.0, 180.0, 645.751, 1667.06, 11.5033, 0.0, 0.0, -180.0, 642.586, 1667.06, 11.5033, 0.0, 0.0, -180.0, 645.751, 1667.06, 11.5033, 0.0, 0.0, -325.0, 642.586, 1667.06, 11.5033, 0.0, 0.0, -35.0}
};

enum E_CONT_NEW_TYPE_DATA
{
    CNT_GUI_ID,
    CNT_OBJ_MODEL,
    CNT_DOOR_MODEL_L,
    CNT_DOOR_MODEL_R,
    CNT_START_PRICE,
    CNT_IS_SPECIAL,
    CNT_NAME[32]
};

new const g_cont_new_types[CONT_NEW_TYPE_COUNT][E_CONT_NEW_TYPE_DATA] =
{
    // Используем штатные модели контейнеров из этого мода. Удалённые
    // кастомные модели отсутствовали в клиенте и засоряли чат до регистрации.
    {0, 934, 933, 933, 25000, 0, "Indiya"},
    {1, 954, 953, 953, 150000, 0, "Rossiya"},
    {2, 956, 955, 955, 1000000, 0, "Kitay"},
    {3, 958, 957, 957, 2500000, 0, "Germaniya"},
    {4, 954, 953, 953, 10000000, 0, "Dubay"},
    {5, 956, 955, 955, 30000000, 0, "Italiya"},
    {6, 958, 957, 957, 10000000, 1, "Diplomaticheskiy_gruz"}
};

enum E_CONT_NEW_AWARD_DATA
{
    CNA_AWARD_ID,
    CNA_TYPE,
    CNA_INTERNAL_ID,
    CNA_COST,
    CNA_RARITY
};

new const g_cont_new_awards[CONT_NEW_AWARD_COUNT][E_CONT_NEW_AWARD_DATA] =
{
    {0, 0, 1, 0, 4},
    {1, 0, 2, 0, 1},
    {2, 0, 3, 0, 4},
    {3, 0, 5, 0, 1},
    {4, 0, 6, 0, 4},
    {5, 0, 11, 0, 4},
    {6, 0, 12, 0, 5},
    {7, 0, 16, 0, 5},
    {8, 0, 22, 0, 2},
    {9, 0, 27, 0, 2},
    {10, 0, 30, 0, 5},
    {11, 0, 37, 0, 3},
    {12, 0, 59, 0, 1},
    {13, 0, 62, 0, 3},
    {14, 0, 67, 0, 4},
    {15, 0, 76, 0, 4},
    {16, 0, 78, 0, 3},
    {17, 0, 80, 0, 1},
    {18, 0, 81, 0, 4},
    {19, 0, 90, 0, 4},
    {20, 0, 91, 0, 5},
    {21, 0, 95, 0, 5},
    {22, 0, 96, 0, 4},
    {23, 0, 97, 0, 1},
    {24, 0, 101, 0, 4},
    {25, 0, 103, 0, 4},
    {26, 0, 104, 0, 4},
    {27, 0, 106, 0, 4},
    {28, 0, 108, 0, 2},
    {29, 0, 117, 0, 2},
    {30, 0, 122, 0, 4},
    {31, 0, 123, 0, 5},
    {32, 0, 124, 0, 4},
    {33, 0, 127, 0, 4},
    {34, 0, 128, 0, 3},
    {35, 0, 130, 0, 2},
    {36, 0, 134, 0, 5},
    {37, 0, 135, 0, 2},
    {38, 0, 137, 0, 1},
    {39, 0, 141, 0, 2},
    {40, 0, 142, 0, 5},
    {41, 0, 143, 0, 2},
    {42, 0, 146, 0, 3},
    {43, 0, 150, 0, 1},
    {44, 0, 151, 0, 3},
    {45, 0, 152, 0, 4},
    {46, 0, 156, 0, 1},
    {47, 0, 159, 0, 4},
    {48, 0, 160, 0, 2},
    {49, 0, 161, 0, 3},
    {50, 0, 163, 0, 2},
    {51, 0, 166, 0, 3},
    {52, 0, 180, 0, 5},
    {53, 0, 182, 0, 4},
    {54, 0, 186, 0, 1},
    {55, 0, 187, 0, 4},
    {56, 0, 188, 0, 3},
    {57, 0, 197, 0, 5},
    {58, 0, 204, 0, 3},
    {59, 0, 205, 0, 4},
    {60, 0, 213, 0, 5},
    {61, 0, 214, 0, 5},
    {62, 0, 215, 0, 4},
    {63, 0, 216, 0, 5},
    {64, 0, 217, 0, 4},
    {65, 0, 219, 0, 5},
    {66, 0, 220, 0, 4},
    {67, 0, 221, 0, 5},
    {68, 0, 225, 0, 2},
    {69, 0, 227, 0, 2},
    {70, 0, 228, 0, 5},
    {71, 0, 229, 0, 5},
    {72, 0, 231, 0, 3},
    {73, 0, 233, 0, 5},
    {74, 0, 234, 0, 5},
    {75, 0, 237, 0, 3},
    {76, 0, 238, 0, 3},
    {77, 0, 243, 0, 5},
    {78, 0, 244, 0, 5},
    {79, 0, 245, 0, 5},
    {80, 0, 247, 0, 4},
    {81, 0, 248, 0, 5},
    {82, 0, 249, 0, 5},
    {83, 0, 251, 0, 5},
    {84, 0, 252, 0, 5},
    {85, 0, 253, 0, 5},
    {86, 0, 254, 0, 3},
    {87, 0, 260, 0, 5},
    {88, 0, 261, 0, 5},
    {89, 0, 270, 0, 5},
    {90, 0, 271, 0, 5},
    {91, 0, 277, 0, 5},
    {92, 0, 289, 0, 5},
    {93, 0, 303, 0, 3},
    {94, 0, 338, 0, 3},
    {95, 0, 340, 0, 3},
    {96, 0, 342, 0, 2},
    {97, 0, 344, 0, 5},
    {98, 0, 345, 0, 5},
    {99, 0, 355, 0, 5},
    {100, 0, 376, 0, 1},
    {101, 0, 381, 0, 4},
    {102, 0, 382, 0, 4},
    {103, 0, 379, 0, 4},
    {104, 0, 402, 0, 3},
    {105, 0, 240, 0, 5},
    {106, 0, 425, 0, 5},
    {107, 0, 435, 0, 3},
    {108, 0, 436, 0, 2},
    {109, 0, 437, 0, 4},
    {110, 0, 439, 0, 5},
    {111, 0, 446, 0, 5},
    {112, 0, 455, 0, 5},
    {113, 0, 466, 0, 5},
    {114, 0, 468, 0, 5},
    {115, 0, 471, 0, 1},
    {116, 0, 472, 0, 3},
    {117, 0, 473, 0, 5},
    {118, 0, 475, 0, 5},
    {119, 0, 476, 0, 5},
    {120, 0, 477, 0, 5},
    {121, 0, 483, 0, 5},
    {122, 0, 498, 0, 5},
    {123, 0, 499, 0, 5},
    {124, 0, 500, 0, 5},
    {125, 0, 502, 0, 5},
    {126, 0, 510, 0, 5},
    {127, 0, 513, 0, 5},
    {128, 0, 517, 0, 5},
    {129, 0, 525, 0, 5},
    {130, 0, 532, 0, 5},
    {131, 0, 543, 0, 5},
    {132, 0, 545, 0, 5},
    {133, 0, 546, 0, 5},
    {134, 1, 11, 5000000, 4},
    {135, 1, 12, 6000000, 4},
    {136, 1, 13, 23000, 1},
    {137, 1, 31, 14625, 1},
    {138, 1, 34, 9750, 1},
    {139, 1, 38, 19500, 1},
    {140, 1, 44, 23400, 1},
    {141, 1, 45, 29250, 1},
    {142, 1, 46, 31200, 1},
    {143, 1, 48, 35100, 1},
    {144, 1, 56, 9750, 1},
    {145, 1, 57, 117000, 1},
    {146, 1, 61, 39000, 1},
    {147, 1, 80, 6100000, 4},
    {148, 1, 81, 6500000, 4},
    {149, 1, 83, 6600000, 4},
    {150, 1, 84, 6700000, 4},
    {151, 1, 85, 40000, 1},
    {152, 1, 87, 40000, 1},
    {153, 1, 94, 15000000, 5},
    {154, 1, 96, 40000, 1},
    {155, 1, 98, 6900000, 4},
    {156, 1, 101, 107250, 1},
    {157, 1, 120, 6400000, 4},
    {158, 1, 122, 30000000, 5},
    {159, 1, 128, 100000, 1},
    {160, 1, 152, 263000, 1},
    {161, 1, 270, 15000000, 5},
    {162, 1, 153, 6300000, 4},
    {163, 1, 154, 62400, 1},
    {164, 1, 156, 64350, 1},
    {165, 1, 169, 292000, 1},
    {166, 1, 177, 130000, 1},
    {167, 1, 178, 1365000, 3},
    {168, 1, 181, 175500, 1},
    {169, 1, 182, 195000, 1},
    {170, 1, 185, 234000, 1},
    {171, 1, 194, 156000, 1},
    {172, 1, 203, 7000000, 4},
    {173, 1, 216, 1755000, 3},
    {174, 1, 217, 1365000, 3},
    {175, 1, 219, 975000, 2},
    {176, 1, 221, 1755000, 3},
    {177, 1, 223, 2535000, 3},
    {178, 1, 226, 2535000, 3},
    {179, 1, 237, 2730000, 3},
    {180, 1, 238, 2925000, 3},
    {181, 1, 240, 97500, 1},
    {182, 1, 241, 780000, 2},
    {183, 1, 242, 682500, 2},
    {184, 1, 246, 1000000, 3},
    {185, 1, 247, 292000, 1},
    {186, 1, 248, 975000, 2},
    {187, 1, 250, 1267500, 3},
    {188, 1, 277, 20000, 1},
    {189, 1, 278, 20000, 1},
    {190, 1, 289, 1000000, 3},
    {191, 1, 290, 2730000, 3},
    {192, 1, 291, 2925000, 3},
    {193, 1, 293, 5850000, 4},
    {194, 1, 294, 6000000, 4},
    {195, 1, 295, 100000, 1},
    {196, 1, 297, 35000, 1},
    {197, 1, 411, 5900000, 4},
    {198, 1, 413, 12000000, 5},
    {199, 1, 479, 600000, 2},
    {200, 1, 481, 600000, 2},
    {201, 1, 482, 90000, 1},
    {202, 1, 486, 30000, 1},
    {203, 1, 487, 25000, 1},
    {204, 1, 534, 13500000, 5},
    {205, 1, 536, 14000000, 5},
    {206, 1, 557, 22000000, 4},
    {207, 1, 566, 1200000, 3},
    {208, 1, 567, 1200000, 3},
    {209, 2, 10, 20000, 1},
    {210, 2, 12, 20000, 1},
    {211, 2, 13, 15000, 1},
    {212, 2, 14, 10000, 1},
    {213, 2, 16, 10000, 1},
    {214, 2, 40, 100000, 1},
    {215, 2, 42, 100000, 1},
    {216, 2, 43, 100000, 1},
    {217, 2, 44, 100000, 1},
    {218, 2, 45, 100000, 1},
    {219, 2, 46, 100000, 1},
    {220, 2, 47, 100000, 1},
    {221, 2, 51, 70000, 1},
    {222, 2, 52, 70000, 1},
    {223, 2, 53, 70000, 1},
    {224, 2, 140, 1500000, 3},
    {225, 2, 141, 1500000, 3},
    {226, 2, 210, 400000, 2},
    {227, 2, 295, 400000, 2},
    {228, 2, 296, 400000, 2},
    {229, 2, 356, 400000, 2},
    {230, 2, 364, 400000, 2},
    {231, 2, 388, 700000, 2},
    {232, 2, 389, 700000, 2},
    {233, 2, 433, 1000000, 3},
    {234, 2, 434, 1000000, 3},
    {235, 2, 435, 1000000, 3},
    {236, 2, 439, 2000000, 3},
    {237, 2, 440, 2000000, 3},
    {238, 2, 442, 2000000, 3},
    {239, 2, 447, 2000000, 3},
    {240, 2, 449, 2000000, 3},
    {241, 2, 914, 600000, 2},
    {242, 2, 915, 800000, 2},
    {243, 2, 916, 600000, 2},
    {244, 2, 580, 50000, 1},
    {245, 2, 398, 50000, 1},
    {246, 2, 441, 2000000, 3}
};

new const g_cont_new_type_award_count[CONT_NEW_TYPE_COUNT] = {30, 49, 54, 49, 55, 23, 19};

new const g_cont_new_type_award_ids[CONT_NEW_TYPE_COUNT][CONT_NEW_MAX_TYPE_AWARDS] =
{
    {138, 144, 212, 213, 137, 211, 139, 46, 188, 189, 136, 140, 203, 141, 43, 202, 142, 196, 143, 146, 151, 152, 154, 244, 245, 1, 17, 100, 23, 96, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {3, 8, 9, 12, 17, 35, 37, 38, 39, 41, 48, 50, 54, 56, 68, 69, 108, 115, 145, 156, 159, 160, 163, 164, 165, 166, 168, 169, 170, 171, 181, 185, 195, 201, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 227, 228, 231, 232, 242, -1, -1, -1, -1, -1, -1},
    {0, 9, 11, 13, 16, 19, 28, 29, 33, 34, 42, 44, 45, 49, 51, 55, 56, 58, 72, 75, 76, 86, 93, 94, 95, 104, 167, 173, 174, 175, 176, 177, 178, 179, 180, 182, 183, 184, 186, 187, 190, 191, 192, 199, 200, 229, 230, 233, 234, 235, 241, 242, 243, 246, -1},
    {0, 11, 13, 15, 16, 19, 22, 26, 27, 32, 33, 34, 44, 45, 49, 51, 55, 58, 66, 72, 75, 76, 77, 99, 101, 102, 103, 107, 116, 135, 167, 173, 174, 175, 176, 177, 178, 179, 180, 184, 186, 187, 190, 191, 192, 193, 197, 207, 208, -1, -1, -1, -1, -1, -1},
    {2, 4, 5, 6, 7, 10, 14, 18, 20, 21, 24, 25, 30, 31, 36, 40, 47, 52, 53, 59, 60, 61, 62, 63, 64, 65, 66, 67, 70, 71, 73, 74, 77, 78, 79, 80, 81, 82, 83, 84, 85, 91, 109, 134, 147, 148, 149, 150, 155, 157, 162, 172, 194, 204, 205},
    {204, 205, 153, 7, 87, 118, 119, 120, 70, 85, 74, 124, 117, 98, 73, 57, 73, 133, 88, 91, 127, 89, 90, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
    {198, 204, 204, 205, 153, 161, 206, 87, 118, 119, 120, 158, 85, 74, 124, 117, 89, 90, 105, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}
};

new const g_cont_new_type_award_weights[CONT_NEW_TYPE_COUNT][CONT_NEW_MAX_TYPE_AWARDS] =
{
    {4000, 4000, 10000, 10000, 40000, 40000, 50000, 50000, 50000, 50000, 71000, 122000, 122000, 60000, 60000, 60000, 60000, 30000, 30000, 20000, 10000, 10000, 10000, 7000, 7000, 3000, 3000, 3000, 3000, 1000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {60000, 5000, 2000, 16000, 20000, 10000, 9000, 15000, 8000, 8000, 5000, 2000, 15000, 1000, 8000, 2000, 2000, 60000, 50000, 50000, 30000, 12000, 5000, 5000, 10000, 50000, 60000, 16000, 15000, 91000, 30000, 10000, 30000, 20000, 30000, 30000, 30000, 30000, 30000, 30000, 30000, 12000, 12000, 15000, 8000, 5000, 2000, 2000, 2000, 0, 0, 0, 0, 0, 0},
    {1000, 25000, 3000, 3000, 70000, 1000, 25000, 40000, 2000, 70000, 10000, 2000, 2000, 3000, 2000, 1000, 3000, 4000, 10000, 3000, 8000, 2000, 10000, 10000, 10000, 70000, 8000, 5000, 8000, 50000, 5000, 2000, 2000, 2000, 2000, 25000, 12000, 70000, 50000, 10000, 70000, 2000, 2000, 2000, 2000, 10000, 10000, 70000, 70000, 70000, 12000, 25000, 12000, 2000, 0},
    {2000, 30000, 30000, 3000, 10000, 30000, 4000, 3000, 3000, 25000, 30000, 12000, 50000, 30000, 30000, 30000, 25000, 60000, 2000, 12000, 30000, 12000, 1000, 1000, 3000, 2000, 28000, 30000, 60000, 4000, 12000, 30000, 12000, 10000, 30000, 60000, 60000, 30000, 30000, 10000, 10000, 12000, 10000, 30000, 30000, 4000, 4000, 12000, 12000, 0, 0, 0, 0, 0, 0},
    {6000, 10000, 3000, 2000, 1000, 7000, 80000, 2000, 80000, 7000, 10000, 6000, 6000, 80000, 80000, 2000, 3000, 5000, 6000, 10000, 1000, 7000, 80000, 80000, 6000, 7000, 10000, 7000, 1000, 80000, 1000, 1000, 1000, 80000, 80000, 2000, 2000, 2000, 2000, 80000, 1000, 1000, 10000, 3000, 3000, 6000, 6000, 6000, 6000, 5000, 5000, 6000, 2000, 2000, 2000},
    {60000, 60000, 60000, 60000, 60000, 60000, 60000, 60000, 70000, 113000, 110000, 40000, 30000, 30000, 20000, 20000, 20000, 20000, 20000, 15000, 6000, 3000, 3000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {831000, 40000, 40000, 40000, 10000, 1000, 4000, 4000, 4000, 4000, 4000, 4000, 3000, 3000, 3000, 2000, 1000, 1000, 1000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
};

#define CONT_NEW_REGULAR_TYPE_COUNT (6)
new const g_cont_new_regular_ids[CONT_NEW_REGULAR_TYPE_COUNT] = {0, 1, 2, 3, 4, 5};
new const g_cont_new_regular_weights[CONT_NEW_REGULAR_TYPE_COUNT] = {50000, 200000, 200000, 200000, 250000, 100000};
#define CONT_NEW_SPECIAL_TYPE_COUNT (1)
new const g_cont_new_special_ids[CONT_NEW_SPECIAL_TYPE_COUNT] = {6};
new const g_cont_new_special_weights[CONT_NEW_SPECIAL_TYPE_COUNT] = {1000000};
// END INLINED: contnewsystem_data.inc
// BEGIN INLINED: contnewsystem_carids.inc
#if defined _inc_contnewsystem_carids
    #endinput
#endif
#define _inc_contnewsystem_carids

new const g_cont_new_car_game_ids[][2] = {
{5, 555},
{6, 549},
{7, 401},
{8, 479},
{9, 496},
{10, 404},
{11, 458},
{12, 585},
{13, 536},
{14, 529},
{15, 534},
{16, 542},
{17, 540},
{18, 559},
{19, 421},
{20, 2554},
{21, 2548},
{22, 419},
{23, 562},
{24, 507},
{25, 426},
{26, 516},
{27, 467},
{347, 2580},
{28, 527},
{29, 445},
{30, 589},
{31, 587},
{32, 436},
{33, 560},
{34, 550},
{348, 2584},
{35, 603},
{36, 2552},
{37, 565},
{38, 551},
{39, 526},
{40, 442},
{41, 489},
{42, 543},
{43, 480},
{44, 558},
{45, 495},
{46, 475},
{47, 503},
{48, 410},
{49, 402},
{50, 2553},
{51, 505},
{52, 2547},
{53, 502},
{54, 400},
{55, 604},
{56, 405},
{57, 506},
{58, 2550},
{59, 466},
{60, 2545},
{61, 490},
{62, 420},
{349, 2582},
{63, 533},
{64, 2546},
{65, 494},
{66, 429},
{67, 451},
{68, 2544},
{69, 2551},
{70, 2549},
{71, 579},
{351, 2578},
{72, 541},
{352, 2581},
{73, 411},
{350, 2579},
{74, 415},
{75, 2543},
{76, 462},
{77, 468},
{78, 461},
{79, 463},
{80, 523},
{81, 586},
{82, 521},
{83, 581},
{84, 522},
{85, 582},
{86, 529},
{87, 470},
{88, 416},
{89, 516},
{90, 466},
{201, 413},
{202, 418},
{195, 440},
{211, 2555},
{212, 2557},
{213, 2565},
{214, 2566},
{215, 2560},
{216, 2561},
{217, 2568},
{218, 2567},
{219, 2559},
{220, 2558},
{353, 2583},
{221, 2564},
{222, 2563},
{223, 2570},
{224, 2569},
{275, 2571},
{276, 2572},
{327, 2574},
{328, 2575},
{329, 2573},
{330, 2577},
{331, 2576},
{366, 2586},
{367, 2585},
{400, 412},
{401, 439},
{402, 492},
{403, 547},
{404, 491},
{405, 546},
{406, 2589},
{407, 2588},
{408, 2587},
{409, 483},
{410, 2590},
{411, 2591},
{413, 452},
{414, 453},
{415, 454},
{416, 472},
{417, 473},
{418, 493},
{424, 2592},
{426, 2594},
{427, 2596},
{428, 2595},
{429, 2593},
{444, 2597},
{445, 2598},
{446, 2599},
{447, 2600},
{448, 2601},
{449, 2602},
{450, 2603},
{451, 2604},
{452, 2607},
{453, 2608},
{454, 2609},
{455, 2610},
{456, 2611},
{459, 448},
{460, 2616},
{461, 2617},
{465, 2618},
{466, 2619},
{467, 2620},
{468, 2621},
{469, 2622},
{470, 2623},
{471, 2624},
{472, 2625},
{473, 2626},
{474, 2627},
{484, 434},
{485, 2377},
{498, 2380},
{499, 2381},
{500, 2385},
{501, 2386},
{502, 2387},
{503, 2388},
{504, 2389},
{505, 2390},
{506, 2391},
{507, 2392},
{508, 2393},
{509, 2394},
{510, 2382},
{511, 2383},
{512, 2384},
{522, 614},
{523, 613},
{524, 622},
{543, 762},
{544, 763},
{545, 760},
{546, 759},
{547, 761},
{551, 28669},
{552, 28670},
{553, 28671},
{554, 28672},
{555, 28689},
{556, 28693},
{557, 28694},
{558, 28695},
{559, 28696},
{560, 28697}
};
// END INLINED: contnewsystem_carids.inc
// BEGIN INLINED: contnewsystem_ru.inc
#if defined _inc_contnewsystem_ru
    #endinput
#endif
#define _inc_contnewsystem_ru

new const CONT_NEW_LABEL_NO_BID[] = "{FFC700}Контейнер #%d\n\n{FFC700}Страна: {FFFFFF}%s\n{FFC700}Содержимое: {FFFFFF}%s\n{FFC700}Статус: {FFFFFF}Торги открыты\n{FFC700}Начальная ставка: {FFFFFF}%s";
new const CONT_NEW_LABEL_BID[] = "{FFC700}Контейнер #%d\n\n{FFC700}Страна: {FFFFFF}%s\n{FFC700}Содержимое: {FFFFFF}%s\n{FFC700}Статус: {FFFFFF}Активные торги\n{FFC700}Последняя ставка: {FFFFFF}%s\n{FFC700}Начальная ставка: {FFFFFF}%s\n{FFC700}Ставка сделана от: {FFFFFF}%s";
new const CONT_NEW_LABEL_TIMER[] = "{FFC700}До конца торгов: {009900}%d секунд";
new const CONT_NEW_LABEL_WIN[] = "{FFC700}Контейнер #%d\n\n{FFC700}Страна: {FFFFFF}%s\n{FFC700}Содержимое: {FFFFFF}%s\n{FFC700}Статус: {FFFFFF}Торги завершены\n{FFC700}Победная ставка: {FFFFFF}%s\n{FFC700}Начальная ставка: {FFFFFF}%s\n{FFC700}Победитель: {FFFFFF}%s";

new const CONT_NEW_MSG_CONTAINER_NOT_FOUND[] = "Контейнер не найден";
new const CONT_NEW_MSG_AUCTION_CLOSED[] = "Торги за этот контейнер уже завершены";
new const CONT_NEW_MSG_ALREADY_LEADER[] = "Вы уже лидируете в торгах за этот контейнер";
new const CONT_NEW_MSG_MIN_BID_FMT[] = "Минимальная ставка на контейнер #%d: %s";
new const CONT_NEW_MSG_NOT_ENOUGH_MONEY[] = "Недостаточно денег для ставки на контейнер";
new const CONT_NEW_MSG_REWARD_UNAVAILABLE[] = "Награда из контейнера сейчас недоступна";
new const CONT_NEW_MSG_CLOSER[] = "Подойди ближе к контейнеру";
new const CONT_NEW_MSG_REWARD_FAILED[] = "Не удалось выдать награду из контейнера";
new const CONT_NEW_MSG_CONTGUI_USAGE[] = "Используйте /contgui [id] рядом с контейнером";

new const CONT_NEW_CHAT_BID_SUCCESS[] = "Ты успешно сделал {FFC700}ставку на контейнер #%d на сумму %s";
new const CONT_NEW_CHAT_BID_OVERBID[] = "Твоя ставка за контейнер #%d {FFC700}была перебита!";
new const CONT_NEW_CHAT_BID_WIN[] = "{FFC700}Ты победил в торгах за контейнер #%d на сумму %s";
new const CONT_NEW_CHAT_BID_RESERVED[] = "Зарезервировано {FFC700}%s рублей за ставку на контейнер #%d";
new const CONT_NEW_HINT_REWARD_TAKE[] = "Ты получил %s из контейнера, проверь добычу";
new const CONT_NEW_HINT_REWARD_SELL[] = "Ты получил %s рублей за продажу %s из контейнера";

new const g_cont_new_type_names_ru[CONT_NEW_TYPE_COUNT][] =
{
    "Индия",
    "Россия",
    "Китай",
    "Германия",
    "Дубай",
    "Италия",
    "Дипломатический груз"
};

new const g_cont_new_award_type_names_ru[3][] =
{
    "Транспорт",
    "Одежда",
    "Аксессуары"
};
enum E_CONT_CLOTHES_REWARD
{
    CCR_MODEL_ID,
    CCR_NAME[32],
    CCR_SELL_PRICE
};

new const g_cont_clothes_35[][E_CONT_CLOTHES_REWARD] =
{
    {18613, "Дора", 6000000},
    {6872, "INSTASAMKA", 6000000},
    {5896, "aarne", 6000000},
    {5897, "bushido zho", 6000000},
    {249, "пыпа", 6000000},
    {149, "шеф", 6000000}
};

new const g_cont_clothes_50[][E_CONT_CLOTHES_REWARD] =
{
    {5500075, "Боряпро", 3000000},
    {200, "Бубстер", 3000000},
    {6864, "Хиш Миш", 3000000},
    {202, "Казанфарович", 3000000},
    {234, "Ким-Чен-Ын", 3000000},
    {6863, "Кумихо", 3000000},
    {266, "скелетон", 3000000}
};

new const g_cont_clothes_100[][E_CONT_CLOTHES_REWARD] =
{
    {79, "бомж", 500000},
    {6862, "Полина", 500000},
    {5882, "Ника Добытчица", 500000},
    {11, "Off-White", 500000},
    {222, "Лошок", 500000},
    {36, "Лысый хуй", 500000},
    {6877, "Петр Тренер", 500000},
    {5892, "Колян Мажор", 500000},
    {29, "Адидас", 500000}
};

enum E_CONT_CAR_REWARD
{
    CVC_MODEL_ID,
    CVC_NAME[40],
    CVC_SELL_PRICE
};

new const g_cont_cars_3[][E_CONT_CAR_REWARD] =
{
    {432, "Танк", 0},
    {2577, "Morris Minor", 0},
    {772, "BMW M5 CS", 0},
    {470, "Gaz Tigr", 0}
};

new const g_cont_cars_15[][E_CONT_CAR_REWARD] =
{
    {28713, "BMW Competition 8", 13000000},
    {28708, "Veneo 2013", 13000000},
    {28689, "Centodia", 13000000},
    {28688, "Boomer E28 Alpa", 13000000},
    {28690, "International 1700 School bus", 13000000},
    {28672, "Gelik 63 Grabus", 13000000},
    {2582, "Mercedes-Benz CLS63 AMG", 13000000},
    {765, "Mersedes Benz 6x6", 13000000},
    {545, "Daevoo Matiz", 13000000}
};

new const g_cont_cars_25[][E_CONT_CAR_REWARD] =
{
    {466, "BMW M5 F90", 9000000},
    {617, "BMW M4 GT3", 9000000},
    {521, "BMW S 1000 RR", 9000000}
};

new const g_cont_cars_60[][E_CONT_CAR_REWARD] =
{
    {603, "Ford Mustang GT", 2000000},
    {551, "Alfa Romeo Guilia", 2000000},
    {28683, "Syberia Preza II WinR", 2000000},
    {28698, "Fer Deeno 246", 2000000},
    {507, "Audi A4", 2000000},
    {445, "Acura TSX", 2000000},
    {436, "Mitsubishi Lancer Evo X", 2000000},
    {2598, "BMW M4 G82", 2000000},
    {405, "Audi RS6", 2000000},
    {2559, "Cadillac Escalade", 2000000}
};

new const g_cont_cars_100[][E_CONT_CAR_REWARD] =
{
    {555, "ZAZ 968", 500000},
    {549, "VAZ 1111", 500000},
    {2557, "Lada Vesta SW Cross", 500000},
    {2565, "Renault logan", 500000},
    {534, "BMW M3 E30", 500000},
    {542, "Niva Urban", 500000},
    {2555, "Lada Granta", 500000},
    {2624, "Audi A6 C5", 500000},
    {2566, "Kia Rio", 500000},
    {546, "Hyundai Solaris 2021", 500000},
    {516, "Volkswagen Polo", 500000},
    {489, "Volvo XC90", 500000},
    {543, "Chevrolet Camaro ZL1", 500000}
};
// END INLINED: contnewsystem_ru.inc

#define CONT_NEW_GUI_ID (125)
#define CONT_NEW_WIN_TIMER (30)
#define CONT_NEW_RESPAWN_MS (10000)
#define CONT_NEW_CLOSE_IGNORE_MS (2500)
#define CONT_NEW_CLOTHES_START_PRICE (500000)
#define CONT_NEW_VEHICLE_START_PRICE (1500000)

#if !defined HUD_ELEMENT_CHAT
    #define HUD_ELEMENT_CHAT (0)
#endif

#if !defined HUD_ELEMENT_SHOW
    #define HUD_ELEMENT_SHOW (1)
#endif

#if CONT_NEW_SLOT_COUNT > MAX_CONT
    #error CONT_NEW_SLOT_COUNT is bigger than MAX_CONT
#endif

new g_cont_gui_current[MAX_PLAYERS];
new bool:g_cont_gui_open[MAX_PLAYERS];
new bool:g_cont_gui_reward_view[MAX_PLAYERS];
new g_cont_gui_ignore_close_until[MAX_PLAYERS];

new g_cont_runtime_type[MAX_CONT + 1];
new g_cont_runtime_award_id[MAX_CONT + 1];
new g_cont_runtime_award_type[MAX_CONT + 1];
new g_cont_runtime_award_internal[MAX_CONT + 1];
new g_cont_runtime_award_cost[MAX_CONT + 1];
new g_cont_runtime_award_rarity[MAX_CONT + 1];
new g_cont_runtime_vehicle_model[MAX_CONT + 1];
new bool:g_cont_runtime_can_sell[MAX_CONT + 1];

stock bool:ContNewSystem_IsValidContainer(contid)
{
    return contid >= 1 && contid <= CONT_NEW_SLOT_COUNT;
}

stock bool:ContNewSystem_IsSpecialSlot(contid)
{
    return contid == CONT_NEW_SLOT_COUNT;
}

stock ContNewSystem_ResetContainerRuntime(contid)
{
    if(contid < 1 || contid > MAX_CONT) return 0;

    g_cont_runtime_type[contid] = -1;
    g_cont_runtime_award_id[contid] = -1;
    g_cont_runtime_award_type[contid] = -1;
    g_cont_runtime_award_internal[contid] = 0;
    g_cont_runtime_award_cost[contid] = 0;
    g_cont_runtime_award_rarity[contid] = 0;
    g_cont_runtime_vehicle_model[contid] = 0;
    g_cont_runtime_can_sell[contid] = true;
    return 1;
}

stock ContNewSystem_ResetPlayer(playerid)
{
    g_cont_gui_current[playerid] = 0;
    g_cont_gui_open[playerid] = false;
    g_cont_gui_reward_view[playerid] = false;
    g_cont_gui_ignore_close_until[playerid] = 0;
    return 1;
}

stock ContNewSystem_CloseLegacyTextdraw(playerid)
{
    TogglePlayerHudElement(playerid, HUD_ELEMENT_CHAT, HUD_ELEMENT_SHOW);

    TextDrawHideForPlayer(playerid, cont_fon);
    TextDrawHideForPlayer(playerid, cont_take);
    TextDrawHideForPlayer(playerid, cont_sell);
    TextDrawHideForPlayer(playerid, cont_close);
    CancelSelectTextDraw(playerid);

    for(new cont = 1; cont <= MAX_CONT; cont++)
    {
        TextDrawHideForPlayer(playerid, cont_name[cont]);
        TextDrawHideForPlayer(playerid, cont_price[cont]);
        TextDrawHideForPlayer(playerid, cont_model[cont]);
    }
    return 1;
}

stock ContNewSystem_Close(playerid, bool:hide_gui = true)
{
    ContNewSystem_CloseLegacyTextdraw(playerid);

    g_cont_gui_current[playerid] = 0;
    g_cont_gui_open[playerid] = false;
    g_cont_gui_reward_view[playerid] = false;
    g_cont_gui_ignore_close_until[playerid] = 0;

    if(hide_gui)
    {
        HidePlayerGUI(playerid, CONT_NEW_GUI_ID);
    }
    return 1;
}

stock ContNewSystem_GetTypeName(type_id, out[], size = sizeof(out))
{
    if(type_id < 0 || type_id >= CONT_NEW_TYPE_COUNT)
    {
        format(out, size, "Неизвестно");
        return 0;
    }

    format(out, size, "%s", g_cont_new_type_names_ru[type_id]);
    return 1;
}

stock ContNewSystem_GetTypeNameRu(type_id, out[], size = sizeof(out))
{
    if(type_id < 0 || type_id >= CONT_NEW_TYPE_COUNT)
    {
        format(out, size, "Неизвестно");
        return 0;
    }

    format(out, size, "%s", g_cont_new_type_names_ru[type_id]);
    return 1;
}

stock ContNewSystem_GetRewardTypeNameRu(contid, out[], size = sizeof(out))
{
    if(!ContNewSystem_IsValidContainer(contid))
    {
        format(out, size, "Неизвестно");
        return 0;
    }

    if(g_cont_runtime_award_type[contid] >= 0
        && g_cont_runtime_award_type[contid] < sizeof(g_cont_new_award_type_names_ru))
    {
        format(out, size, "%s", g_cont_new_award_type_names_ru[g_cont_runtime_award_type[contid]]);
        return 1;
    }

    format(out, size, "Неизвестно");
    return 0;
}

stock bool:ContNewSystem_GetClothesName(model_id, out[], size = sizeof(out))
{
    for(new i; i < sizeof(g_cont_clothes_35); i++)
        if(g_cont_clothes_35[i][CCR_MODEL_ID] == model_id)
            return format(out, size, "%s", g_cont_clothes_35[i][CCR_NAME]), true;

    for(new i; i < sizeof(g_cont_clothes_50); i++)
        if(g_cont_clothes_50[i][CCR_MODEL_ID] == model_id)
            return format(out, size, "%s", g_cont_clothes_50[i][CCR_NAME]), true;

    for(new i; i < sizeof(g_cont_clothes_100); i++)
        if(g_cont_clothes_100[i][CCR_MODEL_ID] == model_id)
            return format(out, size, "%s", g_cont_clothes_100[i][CCR_NAME]), true;

    return false;
}

stock ContNewSystem_PickClothesReward(contid)
{
    new roll = random(100) + 1;
    new index;

    if(roll <= 35)
    {
        index = random(sizeof(g_cont_clothes_35));
        g_cont_runtime_award_internal[contid] = g_cont_clothes_35[index][CCR_MODEL_ID];
        g_cont_runtime_award_cost[contid] = g_cont_clothes_35[index][CCR_SELL_PRICE];
    }
    else if(roll <= 50)
    {
        index = random(sizeof(g_cont_clothes_50));
        g_cont_runtime_award_internal[contid] = g_cont_clothes_50[index][CCR_MODEL_ID];
        g_cont_runtime_award_cost[contid] = g_cont_clothes_50[index][CCR_SELL_PRICE];
    }
    else
    {
        index = random(sizeof(g_cont_clothes_100));
        g_cont_runtime_award_internal[contid] = g_cont_clothes_100[index][CCR_MODEL_ID];
        g_cont_runtime_award_cost[contid] = g_cont_clothes_100[index][CCR_SELL_PRICE];
    }

    g_cont_runtime_award_id[contid] = g_cont_runtime_award_internal[contid];
    g_cont_runtime_award_type[contid] = 1;
    return 1;
}

stock bool:ContNewSystem_GetCarName(model_id, out[], size = sizeof(out))
{
    for(new i; i < sizeof(g_cont_cars_3); i++) if(g_cont_cars_3[i][CVC_MODEL_ID] == model_id) return format(out, size, "%s", g_cont_cars_3[i][CVC_NAME]), true;
    for(new i; i < sizeof(g_cont_cars_15); i++) if(g_cont_cars_15[i][CVC_MODEL_ID] == model_id) return format(out, size, "%s", g_cont_cars_15[i][CVC_NAME]), true;
    for(new i; i < sizeof(g_cont_cars_25); i++) if(g_cont_cars_25[i][CVC_MODEL_ID] == model_id) return format(out, size, "%s", g_cont_cars_25[i][CVC_NAME]), true;
    for(new i; i < sizeof(g_cont_cars_60); i++) if(g_cont_cars_60[i][CVC_MODEL_ID] == model_id) return format(out, size, "%s", g_cont_cars_60[i][CVC_NAME]), true;
    for(new i; i < sizeof(g_cont_cars_100); i++) if(g_cont_cars_100[i][CVC_MODEL_ID] == model_id) return format(out, size, "%s", g_cont_cars_100[i][CVC_NAME]), true;
    return false;
}

stock ContNewSystem_GetRewardVehicleModel(contid)
{
    if(g_cont_runtime_vehicle_model[contid] > 0) return g_cont_runtime_vehicle_model[contid];
    return ContNewSystem_GetVehicleGameId(g_cont_runtime_award_internal[contid]);
}

stock ContNewSystem_PickCarReward(contid)
{
    new roll = random(100) + 1;
    new index;

    g_cont_runtime_can_sell[contid] = true;
    if(roll <= 3)
    {
        index = random(sizeof(g_cont_cars_3));
        g_cont_runtime_vehicle_model[contid] = g_cont_cars_3[index][CVC_MODEL_ID];
        g_cont_runtime_award_cost[contid] = 0;
        g_cont_runtime_can_sell[contid] = false;
    }
    else if(roll <= 15)
    {
        index = random(sizeof(g_cont_cars_15));
        g_cont_runtime_vehicle_model[contid] = g_cont_cars_15[index][CVC_MODEL_ID];
        g_cont_runtime_award_cost[contid] = g_cont_cars_15[index][CVC_SELL_PRICE];
    }
    else if(roll <= 25)
    {
        index = random(sizeof(g_cont_cars_25));
        g_cont_runtime_vehicle_model[contid] = g_cont_cars_25[index][CVC_MODEL_ID];
        g_cont_runtime_award_cost[contid] = g_cont_cars_25[index][CVC_SELL_PRICE];
    }
    else if(roll <= 60)
    {
        index = random(sizeof(g_cont_cars_60));
        g_cont_runtime_vehicle_model[contid] = g_cont_cars_60[index][CVC_MODEL_ID];
        g_cont_runtime_award_cost[contid] = g_cont_cars_60[index][CVC_SELL_PRICE];
    }
    else
    {
        index = random(sizeof(g_cont_cars_100));
        g_cont_runtime_vehicle_model[contid] = g_cont_cars_100[index][CVC_MODEL_ID];
        g_cont_runtime_award_cost[contid] = g_cont_cars_100[index][CVC_SELL_PRICE];
    }

    g_cont_runtime_award_id[contid] = g_cont_runtime_vehicle_model[contid];
    g_cont_runtime_award_internal[contid] = g_cont_runtime_vehicle_model[contid];
    g_cont_runtime_award_type[contid] = 0;
    return 1;
}

stock ContNewSystem_GetRewardName(contid, out[], size = sizeof(out))
{
    if(!ContNewSystem_IsValidContainer(contid))
    {
        format(out, size, "Неизвестно");
        return 0;
    }

    switch(g_cont_runtime_award_type[contid])
    {
        case 0:
        {
            if(!ContNewSystem_GetCarName(ContNewSystem_GetRewardVehicleModel(contid), out, size))
            {
                new vehicle_name[32];
                GetVehicleModelName(ContNewSystem_GetRewardVehicleModel(contid), vehicle_name, sizeof(vehicle_name));
                format(out, size, "%s", vehicle_name);
            }
        }
        case 1:
        {
            if(!ContNewSystem_GetClothesName(g_cont_runtime_award_internal[contid], out, size))
                format(out, size, "Одежда #%d", g_cont_runtime_award_internal[contid]);
        }
        case 2: format(out, size, "Аксессуар #%d", g_cont_runtime_award_internal[contid]);
        default: format(out, size, "Награда #%d", g_cont_runtime_award_internal[contid]);
    }
    return 1;
}

stock ContNewSystem_GetVisualRewardModel(contid)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 959;

    switch(g_cont_runtime_award_type[contid])
    {
        case 1:
        {
            if(g_cont_runtime_award_rarity[contid] >= 5) return 100418;
            if(g_cont_runtime_award_rarity[contid] >= 3) return 100416;
            return 100414;
        }
        case 2:
        {
            if(g_cont_runtime_award_rarity[contid] >= 5) return 100412;
            if(g_cont_runtime_award_rarity[contid] >= 3) return 100410;
            return 100408;
        }
    }
    return 959;
}

stock ContNewSystem_GetVehicleGameId(internal_id)
{
    for(new i = 0; i < sizeof(g_cont_new_car_game_ids); i++)
    {
        if(g_cont_new_car_game_ids[i][0] == internal_id)
        {
            return g_cont_new_car_game_ids[i][1];
        }
    }
    return internal_id;
}

stock ContNewSystem_GetContainerTimer(contid)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;
    if(cInfo[contid][SaleTime] > 0) return cInfo[contid][SaleTime];
    if(cInfo[contid][Saled]) return CONT_NEW_WIN_TIMER;
    return 0;
}

stock Float:ContNewSystem_GetInteractRange()
{
    // V11 container realfix: use the original small interaction radius.
    // The previous 7m spheres overlapped neighbouring container slots and
    // made the mobile interaction button select/hide against the wrong slot.
    return 4.0;
}

stock ContNewSystem_GetStep(contid)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    new step = floatround(float(cInfo[contid][BetPrice]) * 0.05);
    if(step < 1) step = 1;
    return step;
}

stock ContNewSystem_GetMinimumBid(contid)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;
    if(cInfo[contid][BetedId] == INVALID_PLAYER_ID) return cInfo[contid][ContPrice];
    return cInfo[contid][BetPrice] + ContNewSystem_GetStep(contid);
}

stock ContNewSystem_GetNearestContainer(playerid)
{
    if(!g_container_session_active) return 0;

    // V11 container realfix: choose the physically nearest BUY/interaction
    // point from the original map layout instead of returning the first
    // overlapping 7m area.
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    new nearest = 0;
    new Float:best_dist_sq = 999999.0;
    new Float:max_range = ContNewSystem_GetInteractRange();
    new Float:max_dist_sq = max_range * max_range;

    for(new cont = 1; cont <= CONT_NEW_SLOT_COUNT; cont++)
    {
        new Float:dx = px - ContBuyTextPos[cont - 1][0];
        new Float:dy = py - ContBuyTextPos[cont - 1][1];
        new Float:dz = pz - ContBuyTextPos[cont - 1][2];
        new Float:dist_sq = dx * dx + dy * dy + dz * dz;

        if(dist_sq <= max_dist_sq && dist_sq < best_dist_sq)
        {
            best_dist_sq = dist_sq;
            nearest = cont;
        }
    }
    return nearest;
}

stock ContNewSystem_WeightedPick(const ids[], const weights[], count)
{
    new total = 0;

    for(new i = 0; i < count; i++)
    {
        if(ids[i] < 0 || weights[i] <= 0) continue;
        total += weights[i];
    }

    if(total <= 0)
    {
        return ids[0];
    }

    new roll = random(total);
    new cursor = 0;

    for(new i = 0; i < count; i++)
    {
        if(ids[i] < 0 || weights[i] <= 0) continue;

        cursor += weights[i];
        if(roll < cursor)
        {
            return ids[i];
        }
    }
    return ids[0];
}

stock ContNewSystem_PickTypeForSlot(contid)
{
    if(ContNewSystem_IsSpecialSlot(contid))
    {
        return ContNewSystem_WeightedPick(
            g_cont_new_special_ids,
            g_cont_new_special_weights,
            CONT_NEW_SPECIAL_TYPE_COUNT
        );
    }

    return ContNewSystem_WeightedPick(
        g_cont_new_regular_ids,
        g_cont_new_regular_weights,
        CONT_NEW_REGULAR_TYPE_COUNT
    );
}

stock ContNewSystem_FindAwardIndexById(award_id)
{
    for(new i = 0; i < CONT_NEW_AWARD_COUNT; i++)
    {
        if(g_cont_new_awards[i][CNA_AWARD_ID] == award_id) return i;
    }
    return -1;
}

stock ContNewSystem_PickAwardForType(type_id, &award_index)
{
    award_index = -1;
    if(type_id < 0 || type_id >= CONT_NEW_TYPE_COUNT) return 0;

    new picked_award_id = ContNewSystem_WeightedPick(
        g_cont_new_type_award_ids[type_id],
        g_cont_new_type_award_weights[type_id],
        g_cont_new_type_award_count[type_id]
    );

    award_index = ContNewSystem_FindAwardIndexById(picked_award_id);
    return award_index != -1;
}

stock ContNewSystem_UpdateLabel(contid, status, winner_name[] = "")
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    new type_name[32];
    new reward_type_name[32];
    new base_price[32];
    new last_bid[32];
    new label[320];
    new timer_line[64];

    ContNewSystem_GetTypeNameRu(g_cont_runtime_type[contid], type_name, sizeof(type_name));
    ContNewSystem_GetRewardTypeNameRu(contid, reward_type_name, sizeof(reward_type_name));
    ConvertMoney(cInfo[contid][ContPrice], base_price);
    ConvertMoney(cInfo[contid][BetPrice], last_bid);
    timer_line[0] = '\0';

    switch(status)
    {
        case 0:
        {
            format(label, sizeof(label),
                CONT_NEW_LABEL_NO_BID,
                contid, type_name, reward_type_name, base_price);
        }
        case 1:
        {
            format(label, sizeof(label),
                CONT_NEW_LABEL_BID,
                contid, type_name, reward_type_name, last_bid, base_price, cInfo[contid][BetedName]);
            format(timer_line, sizeof(timer_line), CONT_NEW_LABEL_TIMER, cInfo[contid][SaleTime]);
            strcat(label, "\n");
            strcat(label, timer_line);
        }
        case 2:
        {
            format(label, sizeof(label),
                CONT_NEW_LABEL_WIN,
                contid, type_name, reward_type_name, last_bid, base_price, winner_name);
        }
        default:
        {
            format(label, sizeof(label),
                CONT_NEW_LABEL_NO_BID,
                contid, type_name, reward_type_name, base_price);
        }
    }

    if(ContsText[contid] == Dynamic3DTextLabel:INVALID_3DTEXT_ID)
    {
        ContsText[contid] = CreateDynamic3DTextLabel(
            label,
            -1,
            cContsPos[contid - 1][0],
            cContsPos[contid - 1][1],
            cContsPos[contid - 1][2] + 1.0,
            10.0,
            INVALID_PLAYER_ID,
            INVALID_VEHICLE_ID,
            false,
            -1
        );
    }
    else
    {
        UpdateDynamic3DTextLabelText(ContsText[contid], -1, label);
    }
    return 1;
}

stock ContNewSystem_SendPacket(playerid, Node:json, bool:open_gui)
{
    new payload[512];
    JSON_Stringify(json, payload, sizeof(payload), false);
    printf("[CONTGUI] outgoing player=%d open=%d payload=%s", playerid, open_gui, payload);

    if(open_gui) ShowPlayerGUI(playerid, CONT_NEW_GUI_ID, json);
    else UpdatePlayerGUI(playerid, CONT_NEW_GUI_ID, json);

    JSON_Cleanup(json);
    return 1;
}

stock ContNewSystem_SendReset(playerid)
{
    new Node:json = JSON_Object();
    JSON_SetInt(json, "cmd", 5);
    OnPacketIncoming(playerid, CONT_NEW_GUI_ID, json);
    JSON_Cleanup(json);
    return 1;
}

stock ContNewSystem_SendActionStatus(playerid, status)
{
    new Node:json = JSON_Object();
    JSON_SetInt(json, "cmd", 4);
    JSON_SetInt(json, "status", status);
    OnPacketIncoming(playerid, CONT_NEW_GUI_ID, json);
    JSON_Cleanup(json);
    return 1;
}

stock ContNewSystem_SendAuctionState(playerid, contid, bool:open_gui)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    new bidder_name[MAX_PLAYER_NAME];
    bidder_name[0] = '\0';

    if(cInfo[contid][BetedId] != INVALID_PLAYER_ID)
    {
        if(IsPlayerConnected(cInfo[contid][BetedId]))
        {
            GetPlayerName(cInfo[contid][BetedId], bidder_name, sizeof(bidder_name));
        }
        else
        {
            format(bidder_name, sizeof(bidder_name), "%s", cInfo[contid][BetedName]);
        }
    }

    if(!strlen(bidder_name))
    {
        GetPlayerName(playerid, bidder_name, sizeof(bidder_name));
    }

    new step = ContNewSystem_GetStep(contid);
    new Node:json = JSON_Object();

    JSON_SetInt(json, "cmd", 0);
    JSON_SetInt(json, "aid", cInfo[contid][BetedId] == playerid ? 1 : 0);
    JSON_SetInt(json, "bc", cInfo[contid][BetPrice]);
    JSON_SetInt(json, "bhz", step);
    JSON_SetInt(json, "bi", cInfo[contid][ContPrice]);
    JSON_SetInt(json, "bm", ContNewSystem_GetMinimumBid(contid));
    JSON_SetString(json, "bp", bidder_name);
    JSON_SetInt(json, "bs", step);
    JSON_SetInt(json, "bx", GetPlayerMoney(playerid));
    JSON_SetInt(json, "id", g_cont_runtime_type[contid]);
    JSON_SetInt(json, "o", 1);
    JSON_SetInt(json, "tm", ContNewSystem_GetContainerTimer(contid));
    JSON_SetInt(json, "type", 1);

    return ContNewSystem_SendPacket(playerid, json, open_gui);
}

stock ContNewSystem_SendRewardState(playerid, contid, bool:open_gui)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    new reward_name[64];
    ContNewSystem_GetRewardName(contid, reward_name, sizeof(reward_name));

    new Node:json = JSON_Object();
    JSON_SetInt(json, "cmd", 2);
    JSON_SetInt(json, "id", g_cont_runtime_award_id[contid]);
    JSON_SetString(json, "n", reward_name);
    JSON_SetInt(json, "o", 1);
    JSON_SetInt(json, "p", g_cont_runtime_award_cost[contid]);
    JSON_SetInt(json, "pr", g_cont_runtime_award_type[contid]);

    return ContNewSystem_SendPacket(playerid, json, open_gui);
}

stock ContNewSystem_RefreshPlayer(playerid)
{
    if(!g_cont_gui_open[playerid]) return 0;

    new contid = g_cont_gui_current[playerid];
    if(!ContNewSystem_IsValidContainer(contid))
    {
        ContNewSystem_Close(playerid);
        return 0;
    }

    if(!cInfo[contid][Saled] && cInfo[contid][BetedId] == playerid)
    {
        g_cont_gui_reward_view[playerid] = true;
        return ContNewSystem_SendRewardState(playerid, contid, false);
    }

    g_cont_gui_reward_view[playerid] = false;
    return ContNewSystem_SendAuctionState(playerid, contid, false);
}

stock ContNewSystem_RefreshViewers(contid)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(!g_cont_gui_open[i]) continue;
        if(g_cont_gui_current[i] != contid) continue;

        ContNewSystem_RefreshPlayer(i);
    }
    return 1;
}

stock ContNewSystem_Open(playerid, contid)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    ContNewSystem_CloseLegacyTextdraw(playerid);

    g_cont_gui_current[playerid] = contid;
    g_cont_gui_open[playerid] = true;
    g_cont_gui_ignore_close_until[playerid] = GetTickCount() + CONT_NEW_CLOSE_IGNORE_MS;

    printf("[CONTGUI] open player=%d cont=%d type=%d saled=%d bidder=%d price=%d tm=%d",
        playerid,
        contid,
        g_cont_runtime_type[contid],
        cInfo[contid][Saled],
        cInfo[contid][BetedId],
        cInfo[contid][BetPrice],
        ContNewSystem_GetContainerTimer(contid));

    if(!cInfo[contid][Saled] && cInfo[contid][BetedId] == playerid)
    {
        g_cont_gui_reward_view[playerid] = true;
        ContNewSystem_SendReset(playerid);
        return ContNewSystem_SendRewardState(playerid, contid, true);
    }

    g_cont_gui_reward_view[playerid] = false;
    return ContNewSystem_SendAuctionState(playerid, contid, true);
}

stock ContNewSystem_OpenNearby(playerid)
{
    new contid = ContNewSystem_GetNearestContainer(playerid);
    if(!contid) return 0;
    return ContNewSystem_Open(playerid, contid);
}

stock ContNewSystem_ReadBidAmount(Node:json, &amount)
{
    amount = 0;

    if(JSON_GetInt(json, "b", amount)) return 1;
    if(JSON_GetInt(json, "sum", amount)) return 1;
    if(JSON_GetInt(json, "money", amount)) return 1;
    if(JSON_GetInt(json, "bet", amount)) return 1;
    if(JSON_GetInt(json, "bid", amount)) return 1;
    if(JSON_GetInt(json, "value", amount)) return 1;
    if(JSON_GetInt(json, "v", amount)) return 1;
    if(JSON_GetInt(json, "m", amount)) return 1;
    if(JSON_GetInt(json, "bc", amount)) return 1;
    if(JSON_GetInt(json, "bm", amount)) return 1;

    new raw_value[32];

    JSON_GetString(json, "b", raw_value, sizeof(raw_value));
    if(strlen(raw_value))
    {
        amount = strval(raw_value);
        return 1;
    }

    JSON_GetString(json, "sum", raw_value, sizeof(raw_value));
    if(strlen(raw_value))
    {
        amount = strval(raw_value);
        return 1;
    }

    JSON_GetString(json, "money", raw_value, sizeof(raw_value));
    if(strlen(raw_value))
    {
        amount = strval(raw_value);
        return 1;
    }

    JSON_GetString(json, "bet", raw_value, sizeof(raw_value));
    if(strlen(raw_value))
    {
        amount = strval(raw_value);
        return 1;
    }

    JSON_GetString(json, "bid", raw_value, sizeof(raw_value));
    if(strlen(raw_value))
    {
        amount = strval(raw_value);
        return 1;
    }

    return 0;
}

stock ContNewSystem_OpenNative(playerid, contid)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    if(!IsPlayerInRangeOfPoint(playerid, ContNewSystem_GetInteractRange(),
        ContBuyTextPos[contid - 1][0],
        ContBuyTextPos[contid - 1][1],
        ContBuyTextPos[contid - 1][2]))
    {
        SendClientMessage(playerid, CLR_RED, "Подойдите ближе к контейнеру.");
        return 1;
    }

    // V11 container interaction realfix: the user's mobile client does not
    // expose the custom GUI 125 used by ContNewSystem_Open(). Use ordinary
    // SA-MP dialogs here so interaction works on every launcher build.
    g_cont_gui_current[playerid] = 0;
    g_cont_gui_open[playerid] = false;
    g_cont_gui_reward_view[playerid] = false;
    pInfo[playerid][BetUseCont] = contid;
    pInfo[playerid][BuyUseCont] = contid;

    if(!cInfo[contid][Saled])
    {
        if(cInfo[contid][BetedId] != playerid)
        {
            ShowNotificationNew(playerid, 2, 6, 0, 0, "Торги по этому контейнеру завершены", " ");
            return 1;
        }

        new reward_name[64], reward_price[32], reward_body[192], reward_title[64];
        ContNewSystem_GetRewardName(contid, reward_name, sizeof(reward_name));
        ConvertMoney(g_cont_runtime_award_cost[contid], reward_price);
        format(reward_title, sizeof(reward_title), "Контейнер #%d | Награда", contid);
        if(g_cont_runtime_can_sell[contid])
            format(reward_body, sizeof(reward_body), "Забрать: %s\nПродать за %s руб.", reward_name, reward_price);
        else
            format(reward_body, sizeof(reward_body), "Забрать: %s\n{FF6347}Продажа редкого транспорта запрещена", reward_name);
        return ShowPlayerDialog(playerid, DIALOG_CONT_NATIVE_REWARD, DIALOG_STYLE_LIST, reward_title, reward_body, "Выбрать", "Закрыть");
    }

    new current_bid[32], min_bid_str[32], start_price[32], bidder_name[MAX_PLAYER_NAME];
    new bid_title[64], bid_body[512];
    ConvertMoney(cInfo[contid][BetPrice], current_bid);
    ConvertMoney(ContNewSystem_GetMinimumBid(contid), min_bid_str);
    ConvertMoney(cInfo[contid][ContPrice], start_price);

    if(cInfo[contid][BetedId] != INVALID_PLAYER_ID)
    {
        if(IsPlayerConnected(cInfo[contid][BetedId])) GetPlayerName(cInfo[contid][BetedId], bidder_name, sizeof(bidder_name));
        else format(bidder_name, sizeof(bidder_name), "%s", cInfo[contid][BetedName]);
    }
    else format(bidder_name, sizeof(bidder_name), "Нет");

    format(bid_title, sizeof(bid_title), "Контейнер #%d | Торги", contid);
    format(bid_body, sizeof(bid_body),
        "Начальная ставка: %s руб.\nТекущая ставка: %s руб.\nЛидер: %s\nМинимальная новая ставка: %s руб.\nДо конца торгов: %d сек.\n\nВведите сумму ставки:",
        start_price, current_bid, bidder_name, min_bid_str, ContNewSystem_GetContainerTimer(contid));
    return ShowPlayerDialog(playerid, DIALOG_CONT_NATIVE_BID, DIALOG_STYLE_INPUT, bid_title, bid_body, "Ставка", "Закрыть");
}

stock ContNewSystem_TryBid(playerid, contid, bid_amount)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    if(!g_container_session_active)
    {
        SendClientMessage(playerid, CLR_YELLOW, "Сейчас торги за контейнеры не проводятся. Они начинаются каждый час в xx:30.");
        ContNewSystem_Close(playerid);
        return 1;
    }

    new notify_msg[144];

    if(!cInfo[contid][Saled])
    {
        format(notify_msg, sizeof(notify_msg), "%s", CONT_NEW_MSG_AUCTION_CLOSED);
        ShowNotificationNew(playerid, 2, 6, 0, 0, notify_msg, " ");
        ContNewSystem_RefreshPlayer(playerid);
        return 1;
    }

    if(cInfo[contid][BetedId] == playerid)
    {
        format(notify_msg, sizeof(notify_msg), "%s", CONT_NEW_MSG_ALREADY_LEADER);
        ShowNotificationNew(playerid, 2, 6, 0, 0, notify_msg, " ");
        ContNewSystem_RefreshPlayer(playerid);
        return 1;
    }

    new min_bid = ContNewSystem_GetMinimumBid(contid);
    if(bid_amount < min_bid)
    {
        new error_msg[96], moneystr[32];
        ConvertMoney(min_bid, moneystr);
        format(error_msg, sizeof(error_msg), CONT_NEW_MSG_MIN_BID_FMT, contid, moneystr);
        ShowNotificationNew(playerid, 2, 6, 0, 0, error_msg, " ");
        ContNewSystem_RefreshPlayer(playerid);
        return 1;
    }

    if(GetPlayerMoney(playerid) < bid_amount)
    {
        format(notify_msg, sizeof(notify_msg), "%s", CONT_NEW_MSG_NOT_ENOUGH_MONEY);
        ShowNotificationNew(playerid, 2, 6, 0, 0, notify_msg, " ");
        ContNewSystem_RefreshPlayer(playerid);
        return 1;
    }

    if(cInfo[contid][BetedId] != INVALID_PLAYER_ID)
    {
        new old_bidder = cInfo[contid][BetedId];
        if(IsPlayerConnected(old_bidder))
        {
            new overbid_msg[144];
            GivePlayerMoneyEx(old_bidder, cInfo[contid][BetPrice]);
            format(overbid_msg, sizeof(overbid_msg), CONT_NEW_CHAT_BID_OVERBID, contid);
            ShowNotificationNew(old_bidder, 2, 6, 0, 0, overbid_msg, " ");
            SendClientMessage(old_bidder, -1, overbid_msg);
        }
    }

    new player_name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, player_name, sizeof(player_name));

    cInfo[contid][BetPrice] = bid_amount;
    cInfo[contid][BetedId] = playerid;
    format(cInfo[contid][BetedName], MAX_PLAYER_NAME, "%s", player_name);

    GivePlayerMoneyEx(playerid, -bid_amount, "Container GUI bid", true, true);
    StartContBidding(contid);

    printf("[CONTGUI] bid success player=%d cont=%d bid=%d step=%d type=%d",
        playerid, contid, bid_amount, ContNewSystem_GetStep(contid), g_cont_runtime_type[contid]);

    new bid_money[32], bid_success_msg[144], reserve_msg[144];
    ConvertMoney(bid_amount, bid_money);
    format(bid_success_msg, sizeof(bid_success_msg), CONT_NEW_CHAT_BID_SUCCESS, contid, bid_money);
    format(reserve_msg, sizeof(reserve_msg), CONT_NEW_CHAT_BID_RESERVED, bid_money, contid);
    ShowNotificationNew(playerid, 3, 6, 0, 0, bid_success_msg, " ");
    SendClientMessage(playerid, -1, bid_success_msg);
    SendClientMessage(playerid, -1, reserve_msg);

    ContNewSystem_RefreshViewers(contid);
    return 1;
}

stock bool:ContNewSystem_GiveReward(playerid, contid)
{
    switch(g_cont_runtime_award_type[contid])
    {
        case 0:
        {
            new internal_id = g_cont_runtime_award_internal[contid];
            new game_id = ContNewSystem_GetRewardVehicleModel(contid);
            SetPVarInt(playerid, "BUY_CAR_COLOR", cInfo[contid][ContVehicleColor]);
            if(BuyPlayerCar(playerid, internal_id, game_id, cInfo[contid][ContVehicleColor]) == -1)
            {
                DeletePVar(playerid, "BUY_CAR_COLOR");
                printf("[CONTGUI] reward vehicle failed player=%d cont=%d internal=%d game=%d color=%d",
                    playerid, contid, internal_id, game_id, cInfo[contid][ContVehicleColor]);
                return false;
            }
            return true;
        }
        case 1:
        {
            if(!GivePlayerOwnableSkinEx(playerid, g_cont_runtime_award_internal[contid]))
            {
                return false;
            }
            return true;
        }
        case 2:
        {
            new inv_item_id, acc_modelid;
            if(!Inv11_ResolveAccessoryReward(g_cont_runtime_award_internal[contid], inv_item_id, acc_modelid))
            {
                printf("[CONTGUI] reward accessory unresolved player=%d cont=%d internal=%d",
                    playerid, contid, g_cont_runtime_award_internal[contid]);
                return false;
            }

            if(Inventory11_AddItemToDatabase(playerid, inv_item_id, acc_modelid, 1, 0, 0) == -1)
            {
                printf("[CONTGUI] reward accessory add failed player=%d cont=%d item=%d model=%d",
                    playerid, contid, inv_item_id, acc_modelid);
                return false;
            }
            return true;
        }
    }
    return false;
}

stock ContNewSystem_ProcessRewardAction(playerid, contid, bool:sell_reward)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    new notify_msg[160];

    if(cInfo[contid][Saled] || cInfo[contid][BetedId] != playerid)
    {
        format(notify_msg, sizeof(notify_msg), "%s", CONT_NEW_MSG_REWARD_UNAVAILABLE);
        ShowNotificationNew(playerid, 2, 6, 0, 0, notify_msg, " ");
        ContNewSystem_RefreshPlayer(playerid);
        return 1;
    }

    if(!IsPlayerInRangeOfPoint(playerid, ContNewSystem_GetInteractRange(),
        ContBuyTextPos[contid - 1][0],
        ContBuyTextPos[contid - 1][1],
        ContBuyTextPos[contid - 1][2]))
    {
        format(notify_msg, sizeof(notify_msg), "%s", CONT_NEW_MSG_CLOSER);
        ShowNotificationNew(playerid, 2, 6, 0, 0, notify_msg, " ");
        return 1;
    }

    new reward_name[64], moneystr[32], reward_msg[160];
    ContNewSystem_GetRewardName(contid, reward_name, sizeof(reward_name));

    if(sell_reward && !g_cont_runtime_can_sell[contid])
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Этот редкий транспорт нельзя продать", " ");
        SendClientMessage(playerid, CLR_RED, "Этот транспорт можно только забрать");
        return 1;
    }

    if(sell_reward)
    {
        GivePlayerMoneyEx(playerid, g_cont_runtime_award_cost[contid]);
        ConvertMoney(g_cont_runtime_award_cost[contid], moneystr);
        format(reward_msg, sizeof(reward_msg), CONT_NEW_HINT_REWARD_SELL, moneystr, reward_name);
        ShowNotificationNew(playerid, 1, 6, 0, 0, reward_msg, " ");
        SendClientMessage(playerid, -1, reward_msg);
    }
    else
    {
        if(!ContNewSystem_GiveReward(playerid, contid))
        {
            format(notify_msg, sizeof(notify_msg), "%s", CONT_NEW_MSG_REWARD_FAILED);
            ShowNotificationNew(playerid, 2, 6, 0, 0, notify_msg, " ");
            return 1;
        }

        switch(g_cont_runtime_award_type[contid])
        {
            case 0: format(reward_msg, sizeof(reward_msg), "Автомобиль %s (ID: %d) успешно добавлен в /car", reward_name, ContNewSystem_GetRewardVehicleModel(contid));
            case 1: format(reward_msg, sizeof(reward_msg), "Скин %s (ID: %d) добавлен вам в инвентарь", reward_name, g_cont_runtime_award_internal[contid]);
            default: format(reward_msg, sizeof(reward_msg), CONT_NEW_HINT_REWARD_TAKE, reward_name);
        }
        ShowNotificationNew(playerid, 3, 6, 0, 0, reward_msg, " ");
        SendClientMessage(playerid, -1, reward_msg);
    }

    DestroyObject(cInfo[contid][ContObjectId]);
    DestroyObject(cInfo[contid][ContObjectDoorLId]);
    DestroyObject(cInfo[contid][ContObjectDoorRId]);
    DestroyObject(cInfo[contid][ContObjectOdejdaId]);
    DestroyVehicle(cInfo[contid][ContVehicleId]);
    KillTimer(ContsTimer[contid]);
    ResetContInfo(contid);
    ContNewSystem_ResetContainerRuntime(contid);
    pInfo[playerid][BuyUseCont] = 0;
    pInfo[playerid][BetUseCont] = 0;

    if(ContsRespawnTimer[contid] != 0) KillTimer(ContsRespawnTimer[contid]);
    ContsRespawnTimer[contid] = SetTimerEx("SpawnNewCont", CONT_NEW_RESPAWN_MS, false, "i", contid);

    // Native-dialog users never opened GUI 125, so do not send unknown
    // GUI packets back to their client after taking/selling the reward.
    if(g_cont_gui_open[playerid])
    {
        ContNewSystem_SendActionStatus(playerid, 1);
        ContNewSystem_Close(playerid);
    }
    else
    {
        ContNewSystem_Close(playerid, false);
    }
    ContNewSystem_RefreshViewers(contid);

    printf("[CONTGUI] reward action player=%d cont=%d sell=%d award=%d type=%d",
        playerid, contid, sell_reward, g_cont_runtime_award_id[contid], g_cont_runtime_award_type[contid]);
    return 1;
}

stock bool:ContNewSystem_IsClosePayload(payload[])
{
    if(strfind(payload, "\"c\":1", true) != -1) return true;
    if(strfind(payload, "\"c\": 1", true) != -1) return true;
    return false;
}

stock ContNewSystem_HandlePacket(playerid, Node:json)
{
    new payload[512];
    JSON_Stringify(json, payload, sizeof(payload), false);
    printf("[CONTGUI] incoming player=%d payload=%s", playerid, payload);

    new cmd = -1;
    JSON_GetInt(json, "cmd", cmd);

    new contid = g_cont_gui_current[playerid];
    if(!ContNewSystem_IsValidContainer(contid))
    {
        contid = ContNewSystem_GetNearestContainer(playerid);
        if(contid) g_cont_gui_current[playerid] = contid;
    }

    if(cmd == 5 || (cmd == -1 && ContNewSystem_IsClosePayload(payload)))
    {
        if(GetTickCount() < g_cont_gui_ignore_close_until[playerid])
        {
            printf("[CONTGUI] ignore close player=%d cont=%d payload=%s", playerid, contid, payload);
            return ContNewSystem_RefreshPlayer(playerid);
        }

        printf("[CONTGUI] close player=%d cont=%d", playerid, contid);
        return ContNewSystem_Close(playerid, false);
    }

    if(!ContNewSystem_IsValidContainer(contid))
    {
        new cont_error[64];
        format(cont_error, sizeof(cont_error), "%s", CONT_NEW_MSG_CONTAINER_NOT_FOUND);
        ShowNotificationNew(playerid, 2, 6, 0, 0, cont_error, " ");
        return 1;
    }

    switch(cmd)
    {
        case 0, 1:
        {
            new bid_amount;
            if(ContNewSystem_ReadBidAmount(json, bid_amount) && bid_amount > 0)
            {
                return ContNewSystem_TryBid(playerid, contid, bid_amount);
            }
            return ContNewSystem_SendAuctionState(playerid, contid, false);
        }
        case 2:
        {
            if(!cInfo[contid][Saled] && cInfo[contid][BetedId] == playerid)
            {
                return ContNewSystem_SendRewardState(playerid, contid, false);
            }
            return ContNewSystem_SendAuctionState(playerid, contid, false);
        }
        case 3:
        {
            return ContNewSystem_ProcessRewardAction(playerid, contid, false);
        }
        case 4:
        {
            return ContNewSystem_ProcessRewardAction(playerid, contid, true);
        }
    }

    printf("[CONTGUI] unknown cmd player=%d cont=%d cmd=%d", playerid, contid, cmd);
    ContNewSystem_RefreshPlayer(playerid);
    return 1;
}

stock ContNewSystem_SpawnContainer(contid)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    new type_id = ContNewSystem_PickTypeForSlot(contid);
    new award_index;
    if(!ContNewSystem_PickAwardForType(type_id, award_index))
    {
        printf("[CONTGUI] spawn failed cont=%d type=%d: no award", contid, type_id);
        return 1;
    }

    g_cont_runtime_type[contid] = type_id;
    g_cont_runtime_award_id[contid] = g_cont_new_awards[award_index][CNA_AWARD_ID];
    g_cont_runtime_award_type[contid] = g_cont_new_awards[award_index][CNA_TYPE];
    g_cont_runtime_award_internal[contid] = g_cont_new_awards[award_index][CNA_INTERNAL_ID];
    g_cont_runtime_award_rarity[contid] = g_cont_new_awards[award_index][CNA_RARITY];
    g_cont_runtime_award_cost[contid] = g_cont_new_awards[award_index][CNA_COST];
    if(g_cont_runtime_award_type[contid] == 0)
    {
        ContNewSystem_PickCarReward(contid);
    }
    else if(g_cont_runtime_award_type[contid] == 1)
    {
        ContNewSystem_PickClothesReward(contid);
    }
    if(g_cont_runtime_award_cost[contid] <= 0 && g_cont_runtime_can_sell[contid])
    {
        g_cont_runtime_award_cost[contid] = g_cont_new_types[type_id][CNT_START_PRICE];
    }

    cInfo[contid][ContRegion] = 0;
    cInfo[contid][ItemType] = g_cont_runtime_award_type[contid];
    cInfo[contid][Item] = g_cont_runtime_award_internal[contid];
    cInfo[contid][ContPrice] = (g_cont_runtime_award_type[contid] == 0) ? CONT_NEW_VEHICLE_START_PRICE : ((g_cont_runtime_award_type[contid] == 1) ? CONT_NEW_CLOTHES_START_PRICE : g_cont_new_types[type_id][CNT_START_PRICE]);
    cInfo[contid][BetPrice] = cInfo[contid][ContPrice];
    cInfo[contid][ItemPrice] = g_cont_runtime_award_cost[contid];
    cInfo[contid][Saled] = true;
    cInfo[contid][SaleTime] = 0;
    cInfo[contid][BetedId] = INVALID_PLAYER_ID;
    cInfo[contid][BetedName][0] = '\0';
    cInfo[contid][ContVehicleColor] = 1 + random(126);

    // V11 container realfix: use the original map geometry. The custom
    // g_cont_new_slots coordinates placed bodies too low / too close and
    // doors at mismatched offsets, which caused visible intersections.
    cInfo[contid][ContObjectId] = CreateObject(
        g_cont_new_types[type_id][CNT_OBJ_MODEL],
        cContsPos[contid - 1][0],
        cContsPos[contid - 1][1],
        cContsPos[contid - 1][2],
        0.0,
        0.0,
        cContsPos[contid - 1][3]
    );

    cInfo[contid][ContObjectDoorLId] = CreateObject(
        g_cont_new_types[type_id][CNT_DOOR_MODEL_L],
        cContsPos[contid - 1][4],
        cContsPos[contid - 1][5],
        cContsPos[contid - 1][6],
        0.0,
        0.0,
        cContsPos[contid - 1][7]
    );

    cInfo[contid][ContObjectDoorRId] = CreateObject(
        g_cont_new_types[type_id][CNT_DOOR_MODEL_R],
        cContsPos[contid - 1][8],
        cContsPos[contid - 1][9],
        cContsPos[contid - 1][10],
        0.0,
        0.0,
        cContsPos[contid - 1][11]
    );

    if(ContsText[contid] != Dynamic3DTextLabel:INVALID_3DTEXT_ID)
    {
        DestroyDynamic3DTextLabel(ContsText[contid]);
        ContsText[contid] = Dynamic3DTextLabel:INVALID_3DTEXT_ID;
    }

    if(ContArea[contid] != 0)
    {
        DestroyDynamicArea(ContArea[contid]);
    }
    ContArea[contid] = CreateDynamicSphere(
        ContBuyTextPos[contid - 1][0],
        ContBuyTextPos[contid - 1][1],
        ContBuyTextPos[contid - 1][2],
        ContNewSystem_GetInteractRange()
    );

    ContNewSystem_UpdateLabel(contid, 0);
    ContNewSystem_RefreshViewers(contid);

    printf("[CONTGUI] spawn cont=%d type=%d award=%d reward_type=%d internal=%d cost=%d",
        contid,
        type_id,
        g_cont_runtime_award_id[contid],
        g_cont_runtime_award_type[contid],
        g_cont_runtime_award_internal[contid],
        g_cont_runtime_award_cost[contid]);
    return 1;
}

stock ContNewSystem_StartBidding(contid)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    new moneystr[32];
    ConvertMoney(cInfo[contid][ContPrice], moneystr);

    cInfo[contid][Saled] = true;
    cInfo[contid][SaleTime] = CONT_NEW_WIN_TIMER;
    KillTimer(ContsTimer[contid]);
    ContsTimer[contid] = SetTimerEx("TimerSecondUpdateCont", 1000, true, "ds", contid, moneystr);

    ContNewSystem_UpdateLabel(contid, cInfo[contid][BetedId] != INVALID_PLAYER_ID ? 1 : 0);
    ContNewSystem_RefreshViewers(contid);
    return 1;
}

stock ContNewSystem_OpenRewardPreview(contid)
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    if(g_cont_runtime_award_type[contid] == 0)
    {
        new vehicle_model = ContNewSystem_GetRewardVehicleModel(contid);
        cInfo[contid][ContVehicleId] = CreateVehicle(
            vehicle_model,
            cContsPos[contid - 1][0],
            cContsPos[contid - 1][1],
            cContsPos[contid - 1][2] + 0.6,
            cContsPos[contid - 1][3] + 90.0,
            cInfo[contid][ContVehicleColor],
            1,
            0
        );
        SetVehicleParamsEx(cInfo[contid][ContVehicleId], false, false, false, true, false, false, false);
        ChangeVehicleColor(cInfo[contid][ContVehicleId], cInfo[contid][ContVehicleColor], 0);
        return 1;
    }

    cInfo[contid][ContObjectOdejdaId] = CreateObject(
        ContNewSystem_GetVisualRewardModel(contid),
        cContsPos[contid - 1][0],
        cContsPos[contid - 1][1],
        cContsPos[contid - 1][2],
        0.0,
        0.0,
        cContsPos[contid - 1][3]
    );
    return 1;
}

stock ContNewSystem_TimerSecondUpdate(contid, moneystart[])
{
    if(!ContNewSystem_IsValidContainer(contid)) return 0;

    if(cInfo[contid][SaleTime] > 0)
    {
        cInfo[contid][SaleTime]--;
        ContNewSystem_UpdateLabel(contid, cInfo[contid][BetedId] != INVALID_PLAYER_ID ? 1 : 0);
        ContNewSystem_RefreshViewers(contid);
        return 1;
    }

    KillTimer(ContsTimer[contid]);
    ContsTimer[contid] = 0;
    cInfo[contid][Saled] = false;

    if(cInfo[contid][BetedId] != INVALID_PLAYER_ID)
    {
        new winnerid = cInfo[contid][BetedId];
        new winner_name[MAX_PLAYER_NAME];
        GetPlayerName(winnerid, winner_name, sizeof(winner_name));

        // V11 container realfix: keep the original hinge position and use
        // the original +/-128 degree door swing. The custom open coordinates
        // visibly detached / crossed the doors on several slots.
        MoveObject(
            cInfo[contid][ContObjectDoorLId],
            cContsPos[contid - 1][4],
            cContsPos[contid - 1][5],
            cContsPos[contid - 1][6],
            8.5,
            0.0,
            0.0,
            cContsPos[contid - 1][7] + 128.0
        );

        MoveObject(
            cInfo[contid][ContObjectDoorRId],
            cContsPos[contid - 1][8],
            cContsPos[contid - 1][9],
            cContsPos[contid - 1][10],
            8.5,
            0.0,
            0.0,
            cContsPos[contid - 1][11] - 128.0
        );

        ContNewSystem_OpenRewardPreview(contid);
        ContNewSystem_UpdateLabel(contid, 2, winner_name);

        new win_money[32], win_msg[144];
        ConvertMoney(cInfo[contid][BetPrice], win_money);
        format(win_msg, sizeof(win_msg), CONT_NEW_CHAT_BID_WIN, contid, win_money);
        ShowNotificationNew(winnerid, 3, 6, 0, 0, win_msg, " ");
        SendClientMessage(winnerid, -1, win_msg);

        printf("[CONTGUI] winner cont=%d player=%d award=%d type=%d internal=%d",
            contid, winnerid, g_cont_runtime_award_id[contid], g_cont_runtime_award_type[contid], g_cont_runtime_award_internal[contid]);

        if(ContsRespawnTimer[contid] != 0) KillTimer(ContsRespawnTimer[contid]);
        ContsRespawnTimer[contid] = SetTimerEx("SpawnNewCont", 60000, false, "i", contid);
    }
    else
    {
        printf("[CONTGUI] no bids cont=%d respawn=%d", contid, CONT_NEW_RESPAWN_MS);
        if(ContsRespawnTimer[contid] != 0) KillTimer(ContsRespawnTimer[contid]);
        ContsRespawnTimer[contid] = SetTimerEx("SpawnNewCont", CONT_NEW_RESPAWN_MS, false, "i", contid);
    }

    ContNewSystem_RefreshViewers(contid);
    return 1;
}

CMD:contgui(playerid, params[])
{
    new contid = 0;
    if(strlen(params)) contid = strval(params);
    else contid = ContNewSystem_GetNearestContainer(playerid);

    if(!ContNewSystem_IsValidContainer(contid))
    {
        SendClientMessage(playerid, CLR_RED, CONT_NEW_MSG_CONTGUI_USAGE);
        return 1;
    }

    return ContNewSystem_Open(playerid, contid);
}
