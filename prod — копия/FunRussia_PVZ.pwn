#define FILTERSCRIPT
#include <a_samp>

/*
    Fun Russia - PVZ visual filterscript
    PVZ points and coordinates are copied from include/system/pvz.inc; all branches share one interior and virtual world.
    Russian labels use the same CP1251 hex escapes as the supplied mod.
    Standalone filterscript. Reward pickup asks the player to use existing /reward.
    Euro payout is queued through PVars and processed by the existing EuroSystem source.

    Dot commands: .pvz (start job), .pvzcancel (cancel job).
*/
#define PVZ_POINT_COUNT (9)
#define PVZ_REWARD_PICKUP_MODEL (1239)
#define PVZ_PICKUP_MODEL (19132)
#define PVZ_TP_COOLDOWN_MS (1500)
#define PVZ_MAPICON_JOB (49)
#define PVZ_MAPICON_VEHICLE (50)
#define PVZ_ROUTE_CHECK_MS (250)

// Branch entry coordinates. All players share one interior; each player retains their own entry branch for exit.
new const gPvzPointName[PVZ_POINT_COUNT][32] =
{
    "\xC1\xE0\xF2\xFB\xF0\xE5\xE2\xEE", // Батырево
    "\xC0\xF0\xE7\xE0\xEC\xE0\xF1", // Арзамас
    "\xC0\xF0\xE7\xE0\xEC\xE0\xF1", // Арзамас
    "\xDE\xE6\xED\xFB\xE9", // Южный
    "\xDE\xE6\xED\xFB\xE9", // Южный
    "\xC1\xF3\xF1\xE0\xE5\xE2\xEE", // Бусаево
    "\xCB\xFB\xF2\xEA\xE0\xF0\xE8\xED\xEE", // Алтыкарьино
    "\xCD\xE8\xE6\xE5\xE3\xEE\xF0\xEE\xE4\xF1\xEA", // Нижегородск
    "\xCD\xE8\xE6\xE5\xE3\xEE\xF0\xEE\xE4\xF1\xEA" // Нижегородск
};
new const Float:gPvzPoint[PVZ_POINT_COUNT][4] =
{
    {1803.149047, 2037.017944, 16.008436, 0.0},
    {292.996765, 1541.501220, 12.156729, 0.0},
    {614.631835, 579.856567, 12.188437, 0.0},
    {2566.409179, -2516.000488, 22.119831, 0.0},
    {2386.718017, -1708.890747, 22.084220, 0.0},
    {-528.563598, -1788.569946, 41.065799, 0.0},
    {-2265.864746, -322.510284, 28.101448, 0.0},
    {-2457.938476, 1134.409301, 10.855109, 0.0},
    {-1824.447631, 2717.559814, 57.766563, 0.0}
};
#define PVZ_EXIT_X (2283.669921)
#define PVZ_EXIT_Y (1836.158691)
#define PVZ_EXIT_Z (1519.743286)
#define PVZ_EXIT_VW (0)
#define PVZ_EXIT_INT (1)
#define PVZ_INSIDE_X (2282.679199)
#define PVZ_INSIDE_Y (1836.778442)
#define PVZ_INSIDE_Z (1519.743286)
#define PVZ_REWARD_X (2287.283691)
#define PVZ_REWARD_Y (1834.868408)
#define PVZ_REWARD_Z (1519.743286)
#define PVZ_REWARD_VW (0)

new gPvzEnterPickup[PVZ_POINT_COUNT];
new gPvzExitPickup = -1;
new gPvzRewardPickup = -1;
new gPvzBossPickup = -1;
new gPvzBossActor = INVALID_ACTOR_ID;
new gPvzCargoPickup = -1;
new gPvzLastTp[MAX_PLAYERS];
new gPvzLastPoint[MAX_PLAYERS];
new bool:gPvzInsideReady[MAX_PLAYERS];
new gPvzJobLastCheck[MAX_PLAYERS];
new bool:gPvzJobLoading[MAX_PLAYERS];
new gPvzJobLoadTimer[MAX_PLAYERS];
new Text3D:gPvzCargoLabel = Text3D:INVALID_3DTEXT_ID;

stock Pvz_ShowHelp(playerid)
{
    SendClientMessage(playerid, -1, "{33CCFF}| {FFFFFF}ПВЗ: точки выдачи заказов расположены по карте.");
    SendClientMessage(playerid, -1, "{33CCFF}| {FFFFFF}На точке наград внутри ПВЗ откройте интерфейс наград маркетплейса.");
    SendClientMessage(playerid, -1, "{33CCFF}| {FFFFFF}Команды: .pvz (начать работу у начальника), .pvzcancel (отменить работу).");
    SendClientMessage(playerid, -1, "{33CCFF}| {FFFFFF}Награды: используйте существующую команду /reward или подойдите к пикапу наград.");
    return 1;
}

stock Pvz_OpenRewardsWithFallback(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    SendClientMessage(playerid, -1, "[ПВЗ] Для получения наград используйте существующую команду /reward.");
    return 1;
}

// ---------------- PVZ truck delivery job (Fun Russia adaptation) ----------------
// The supplied original pvz.inc contains a hand-carried cargo job, not a truck job.
// This standalone adaptation adds the requested vehicle-based distance/delivery job loop.
#define PVZ_JOB_TRUCK_MODEL (498)
#define PVZ_DELIVERY_POINT_COUNT (471)
new const Float:gPvzDeliveryPoints[PVZ_DELIVERY_POINT_COUNT][3] =
{
    {-681.871, 909.614, 13.081},
    {-722.573, 910.056, 13.125},
    {1838.180, 1338.240, 9.756},
    {1813.150, 1333.200, 9.756},
    {1800.640, 1337.810, 9.756},
    {1784.260, 1338.180, 9.756},
    {1764.040, 1334.300, 9.756},
    {1865.300, 1358.190, 9.756},
    {1865.870, 1337.140, 9.756},
    {1859.470, 1404.840, 9.756},
    {1865.040, 1419.270, 10.228},
    {1866.210, 1439.860, 9.756},
    {2038.900, 1339.880, 26.143},
    {2060.480, 1339.870, 26.143},
    {2204.580, -231.381, 2.067},
    {2240.530, -197.184, 2.389},
    {2261.310, -230.600, 2.071},
    {2329.970, -205.210, 2.433},
    {2381.840, -202.405, 2.763},
    {2422.070, -206.157, 2.352},
    {2414.870, -230.591, 2.065},
    {2466.450, -201.208, 2.145},
    {2487.490, -252.622, 1.842},
    {2513.720, -230.512, 2.566},
    {-785.534, 915.499, 13.079},
    {-829.380, 909.598, 13.081},
    {-870.147, 910.056, 13.125},
    {-933.410, 915.487, 13.079},
    {-975.353, 909.615, 13.081},
    {-968.533, 851.711, 13.079},
    {-973.983, 790.814, 13.125},
    {-974.458, 753.127, 13.081},
    {-848.743, 753.141, 13.081},
    {-848.094, 790.744, 13.125},
    {-842.646, 851.644, 13.079},
    {-791.782, 841.270, 13.081},
    {-792.192, 803.566, 13.125},
    {-797.588, 742.829, 13.079},
    {-730.554, 753.198, 13.081},
    {-730.225, 790.771, 13.131},
    {-724.671, 851.594, 13.079},
    {-674.694, 841.237, 13.081},
    {-675.142, 803.555, 13.125},
    {-680.573, 742.795, 13.079},
    {2685.600, -231.553, 3.975},
    {2627.620, -232.800, 3.975},
    {2608.460, -200.931, 6.834},
    {2590.710, -230.937, 4.036},
    {2524.480, -198.869, 3.723},
    {2250.710, 1363.360, 11.361},
    {2207.510, 1363.420, 11.361},
    {465.347, -1249.770, 41.897},
    {531.188, -1275.490, 40.734},
    {525.155, -1305.000, 40.734},
    {579.831, -1289.010, 40.734},
    {622.280, -1250.170, 41.820},
    {641.989, -1265.940, 41.885},
    {629.064, -1320.470, 41.509},
    {680.528, -1284.150, 41.885},
    {733.133, -1308.760, 40.672},
    {720.156, -1351.020, 40.717},
    {778.244, -1315.230, 40.717},
    {785.178, -1319.980, 41.819},
    {826.264, -1339.170, 40.717},
    {826.275, -1387.150, 40.717},
    {811.911, -1371.200, 40.717},
    {778.237, -1369.940, 40.717},
    {1749.920, 2188.990, 15.920},
    {1745.970, 2115.040, 16.009},
    {1911.980, 2266.080, 15.722},
    {1945.360, 1845.480, 15.420},
    {1943.500, 1806.870, 15.507},
    {1989.220, 1793.930, 15.444},
    {1994.830, 1746.200, 15.699},
    {1944.010, 1753.150, 15.342},
    {-425.162, 1440.380, 20.984},
    {-423.341, 1464.190, 21.391},
    {-410.581, 1441.880, 21.391},
    {-397.837, 1463.920, 21.197},
    {-391.905, 1441.380, 21.492},
    {-376.115, 1464.680, 21.492},
    {-364.914, 1465.680, 20.984},
    {-351.675, 1441.130, 21.391},
    {-329.338, 1427.340, 21.492},
    {-328.339, 1415.810, 20.984},
    {-351.864, 1421.120, 21.197},
    {-292.945, 1442.340, 21.390},
    {-289.770, 1465.660, 20.984},
    {-300.876, 1463.930, 21.197},
    {-260.416, 1464.190, 21.390},
    {-272.757, 1441.400, 21.492},
    {-232.337, 1419.830, 21.492},
    {-254.872, 1413.500, 21.198},
    {-260.536, 1374.170, 21.390},
    {-289.840, 1375.680, 20.984},
    {-272.877, 1351.380, 21.492},
    {-231.349, 1386.350, 20.984},
    {-232.859, 1401.010, 21.390},
    {-293.169, 1352.340, 21.390},
    {-353.632, 1302.690, 20.984},
    {-329.851, 1300.970, 21.390},
    {-351.674, 1289.530, 21.391},
    {-328.337, 1286.250, 20.984},
    {-373.511, 1250.880, 21.391},
    {-388.083, 1249.400, 20.984},
    {-417.614, 1250.880, 21.391},
    {-404.945, 1272.930, 21.197},
    {-383.128, 1273.640, 21.492},
    {-451.967, 1274.530, 20.984},
    {-441.686, 1309.500, 21.391},
    {-419.830, 1298.920, 21.391},
    {-444.682, 1282.470, 20.992},
    {-410.085, 1352.130, 21.197},
    {-419.428, 1374.190, 21.390},
    {-394.199, 1374.670, 21.492},
    {-233.292, 1483.730, 21.390},
    {-260.507, 1526.680, 21.390},
    {-272.927, 1503.900, 21.492},
    {-278.894, 1526.390, 21.197},
    {-301.195, 1527.180, 21.492},
    {-306.239, 1502.890, 20.984},
    {-293.000, 1505.090, 21.390},
    {-355.886, 1526.230, 21.391},
    {-369.969, 1504.650, 21.198},
    {-376.125, 1527.180, 21.492},
    {-388.513, 1504.380, 21.390},
    {-408.831, 1528.180, 20.984},
    {-411.941, 1504.840, 21.390},
    {-419.916, 1526.430, 21.197},
    {-435.795, 1503.890, 21.492},
    {-460.632, 1490.120, 20.984},
    {-458.685, 1476.960, 21.391},
    {-458.885, 1437.560, 21.198},
    {-459.635, 1415.450, 21.492},
    {-437.298, 1401.410, 21.391},
    {-460.636, 1378.190, 20.984},
    {394.404, 701.187, 12.802},
    {473.250, 673.052, 12.152},
    {485.676, 672.548, 12.131},
    {504.005, 662.206, 12.464},
    {-915.642, 742.634, 13.079},
    {-2.835, 595.115, 13.094},
    {8.780, 594.240, 13.100},
    {-910.200, 803.403, 13.125},
    {-909.759, 841.158, 13.081},
    {836.383, -1332.920, 40.717},
    {-286.996, 1249.530, 20.984},
    {-316.422, 1251.690, 21.391},
    {-306.522, 488.966, 13.223},
    {2290.850, -191.040, 2.143},
    {2355.030, -261.294, 2.796},
    {2625.760, -180.869, 7.208},
    {-303.150, 516.448, 13.229},
    {-232.118, 1335.000, 20.984},
    {-232.829, 1305.510, 21.391},
    {-232.333, 1290.930, 20.984},
    {-272.323, 1250.880, 21.391},
    {669.086, -1283.810, 41.885},
    {1787.550, 2409.340, 15.308},
    {-2210.360, -95.159, 26.125},
    {1911.180, 1086.440, 28.769},
    {772.416, -1273.580, 40.711},
    {-2812.330, -670.784, 8.625},
    {-2201.140, -107.546, 26.125},
    {668.764, -1363.100, 40.734},
    {734.808, -1392.200, 40.713},
    {760.230, -1402.050, 40.717},
    {791.408, -1407.550, 40.717},
    {829.752, -1413.330, 40.709},
    {729.248, -1254.390, 40.985},
    {700.420, -1250.330, 40.838},
    {-1543.250, 1584.090, 36.777},
    {656.188, -1232.200, 40.734},
    {644.801, -1244.290, 40.734},
    {570.416, -1316.850, 40.734},
    {548.990, -1312.380, 40.734},
    {474.123, -1281.210, 40.734},
    {468.885, -1254.200, 41.865},
    {2223.520, -179.206, 2.470},
    {2238.360, -168.020, 2.812},
    {2253.290, -167.950, 2.819},
    {2251.190, -200.520, 2.143},
    {2409.290, -260.755, 1.668},
    {2474.370, -264.483, 1.552},
    {2533.490, -190.739, 3.199},
    {2609.070, -169.404, 7.323},
    {2205.320, -261.845, 1.618},
    {2602.490, -243.833, 3.979},
    {2684.000, -260.958, 3.975},
    {-2198.260, -97.493, 26.125},
    {-2212.510, -107.581, 26.118},
    {-2195.930, -94.781, 26.118},
    {-2181.970, -140.857, 26.125},
    {-2188.790, -139.533, 26.125},
    {-2195.910, -138.144, 26.125},
    {-2790.450, -709.893, 7.261},
    {1894.060, 1086.170, 28.769},
    {1909.750, 1066.220, 28.820},
    {1894.910, 1186.520, 30.328},
    {1633.860, 1294.770, 12.221},
    {838.705, -1323.030, 40.710},
    {834.799, -1391.520, 41.704},
    {623.878, -1243.930, 40.734},
    {2196.630, -172.736, 2.453},
    {263.994, 822.082, 12.626},
    {-169.506, 847.773, 15.529},
    {-451.807, 1274.260, 21.032},
    {-417.538, 1250.880, 21.431},
    {-460.005, 1378.240, 21.032},
    {-404.923, 1272.740, 21.241},
    {-383.160, 1273.680, 21.532},
    {-459.351, 1415.410, 21.532},
    {-388.116, 1249.790, 21.032},
    {-329.839, 1300.930, 21.431},
    {-351.687, 1289.650, 21.431},
    {-458.532, 1477.070, 21.431},
    {-293.131, 1352.330, 21.431},
    {-460.155, 1490.200, 21.032},
    {-272.821, 1351.380, 21.532},
    {-435.782, 1504.300, 21.532},
    {-231.391, 1386.390, 21.032},
    {-419.954, 1525.990, 21.241},
    {-232.835, 1401.080, 21.431},
    {-408.793, 1527.610, 21.032},
    {-232.336, 1419.580, 21.532},
    {-412.047, 1505.060, 21.431},
    {-260.468, 1464.180, 21.431},
    {-388.581, 1504.810, 21.431},
    {-370.072, 1504.850, 21.241},
    {-293.087, 1442.370, 21.431},
    {-355.977, 1526.040, 21.431},
    {-300.998, 1463.930, 21.242},
    {-351.686, 1441.160, 21.431},
    {-351.885, 1421.040, 21.242},
    {-328.336, 1415.870, 21.032},
    {-397.938, 1463.930, 21.241},
    {-329.341, 1427.170, 21.532},
    {-437.286, 1401.450, 21.431},
    {-410.520, 1441.880, 21.431},
    {-391.760, 1441.380, 21.532},
    {-376.264, 1464.680, 21.532},
    {-353.108, 1302.730, 21.032},
    {-364.819, 1465.680, 21.032},
    {-328.967, 1286.410, 21.032},
    {-373.478, 1251.530, 21.431},
    {-316.476, 1251.710, 21.431},
    {-289.743, 1375.680, 21.032},
    {-287.183, 1249.750, 21.032},
    {-272.453, 1251.560, 21.431},
    {-231.336, 1334.870, 21.032},
    {-260.249, 1273.120, 21.532},
    {-232.004, 1290.900, 21.032},
    {-232.835, 1305.570, 21.431},
    {-254.431, 1318.090, 21.241},
    {-283.953, 1272.730, 21.431},
    {-254.347, 1413.500, 21.240},
    {-233.345, 1483.810, 21.431},
    {-423.443, 1464.180, 21.431},
    {-260.354, 1526.130, 21.431},
    {-272.735, 1504.530, 21.532},
    {-279.019, 1526.270, 21.242},
    {-293.045, 1504.830, 21.431},
    {-301.187, 1526.700, 21.532},
    {-376.180, 1527.180, 21.532},
    {696.762, -928.019, 41.248},
    {298.975, 322.002, 12.493},
    {300.062, 304.103, 12.540},
    {299.947, 341.076, 12.540},
    {653.016, -940.314, 41.247},
    {326.218, 347.118, 12.493},
    {351.058, 328.866, 12.743},
    {618.689, -946.057, 41.038},
    {371.064, 328.790, 12.743},
    {570.112, -966.074, 41.491},
    {390.131, 344.414, 12.493},
    {519.534, -980.535, 41.563},
    {427.178, 296.836, 12.493},
    {459.637, -981.843, 41.490},
    {428.434, 278.721, 12.540},
    {446.442, 334.000, 12.493},
    {471.325, 315.775, 12.743},
    {434.731, -1010.850, 41.490},
    {491.322, 315.669, 12.743},
    {510.416, 331.293, 12.493},
    {553.492, 296.866, 12.493},
    {389.292, -1015.770, 41.490},
    {554.754, 278.748, 12.540},
    {374.111, 285.152, 12.583},
    {304.901, -1042.910, 41.038},
    {333.070, 285.152, 12.583},
    {343.709, 285.154, 12.583},
    {313.010, -1129.620, 41.038},
    {384.675, 285.155, 12.583},
    {353.751, -1119.060, 41.247},
    {457.773, 273.782, 12.583},
    {468.416, 273.779, 12.583},
    {497.754, 273.786, 12.583},
    {397.119, -1109.180, 41.248},
    {508.379, 273.783, 12.583},
    {440.079, -1102.070, 41.490},
    {470.644, -1070.530, 41.490},
    {-746.822, -1863.030, 41.087},
    {533.502, -1078.730, 41.362},
    {-715.792, -1882.270, 41.087},
    {580.210, -1072.130, 41.491},
    {-671.025, -1907.840, 42.235},
    {-790.197, -1950.080, 41.267},
    {625.550, -1056.330, 41.038},
    {-797.468, -1958.300, 41.267},
    {667.088, -1048.050, 41.247},
    {-800.621, -2032.300, 41.267},
    {-939.086, -1908.510, 39.540},
    {-792.335, -2054.880, 42.139},
    {711.102, -1040.010, 41.248},
    {686.989, -1094.850, 41.247},
    {-928.915, -2175.420, 40.711},
    {645.290, -1103.830, 41.248},
    {599.744, -1107.230, 41.490},
    {566.830, -1136.060, 41.490},
    {509.184, -1130.090, 41.565},
    {1743.310, 2180.510, 16.255},
    {462.978, -1134.960, 41.491},
    {419.679, -1155.110, 41.038},
    {335.882, -1175.900, 41.248},
    {-793.206, -2081.530, 42.320},
    {-804.743, -2116.910, 41.221},
    {-930.745, -1878.020, 39.489},
    {-799.952, -2151.820, 42.319},
    {-838.463, -2222.220, 42.025},
    {-929.444, -1829.580, 40.482},
    {-981.921, -2179.400, 40.478},
    {-923.208, -2141.360, 40.796},
    {-933.646, -1811.310, 39.497},
    {-970.256, -2141.680, 39.500},
    {-930.019, -2119.150, 39.500},
    {-982.494, -2093.450, 39.493},
    {-932.246, -2077.570, 39.500},
    {-977.213, -1802.280, 39.497},
    {-983.973, -2048.470, 40.659},
    {-922.642, -2030.710, 40.328},
    {-933.770, -2014.250, 39.500},
    {-981.718, -1857.090, 40.593},
    {-981.563, -2003.980, 40.659},
    {-931.214, -1920.630, 40.033},
    {-985.005, -1988.460, 40.672},
    {-988.787, -1892.210, 40.595},
    {-978.196, -1956.360, 39.500},
    {-1022.880, -1699.070, 42.204},
    {-988.449, -1923.180, 40.595},
    {-1044.930, -1713.280, 42.397},
    {-1073.240, -1724.030, 41.230},
    {-1100.170, -1735.560, 42.385},
    {-1126.690, -1744.190, 41.223},
    {-1156.930, -1749.550, 41.223},
    {-1175.050, -1778.130, 42.321},
    {-2692.800, -1164.760, 10.562},
    {-2761.830, -1149.220, 8.662},
    {-2707.060, -1103.870, 10.163},
    {-2776.090, -1088.310, 9.062},
    {-2692.800, -1054.720, 10.562},
    {-2761.830, -1039.100, 8.662},
    {-2707.060, -893.883, 10.162},
    {-2776.090, -878.431, 9.062},
    {-2692.800, -844.746, 10.562},
    {-2761.830, -829.169, 8.662},
    {-2707.060, -783.869, 10.162},
    {-2776.100, -768.276, 9.062},
    {-2679.160, -707.299, 10.562},
    {-2748.200, -691.655, 8.662},
    {-2693.430, -646.427, 10.162},
    {-2762.460, -630.875, 9.062},
    {-2679.170, -597.413, 10.562},
    {-2748.200, -581.773, 8.662},
    {-2717.800, 1160.990, 9.870},
    {-2763.550, 1182.950, 10.230},
    {-2801.460, 1167.660, 10.210},
    {-2739.580, 1110.150, 10.100},
    {-2679.590, 1071.590, 10.230},
    {-2738.500, 948.470, 10.230},
    {-2800.480, 938.020, 9.980},
    {-2818.540, 893.830, 10.130},
    {-2841.900, 851.010, 10.230},
    {-2729.890, 823.680, 10.230},
    {-2763.550, 802.620, 9.980},
    {-2873.030, 1189.560, 9.980},
    {-2862.060, 1154.380, 9.980},
    {-2854.370, 1109.490, 10.230},
    {-2852.680, 1055.980, 10.230},
    {-2864.080, 1014.130, 9.980},
    {-2879.080, 930.630, 9.980},
    {-2881.780, 891.530, 9.980},
    {-2810.230, 1013.720, 10.233},
    {-2737.060, 999.634, 9.732},
    {-2785.060, 1065.780, 10.232},
    {-2785.830, 1102.930, 9.732},
    {728.802, -1212.540, 41.490},
    {692.448, -1189.480, 41.490},
    {637.548, -1191.390, 41.566},
    {595.375, -1201.410, 41.490},
    {458.589, -1230.060, 41.248},
    {416.863, -1230.810, 41.492},
    {378.541, -1274.470, 41.490},
    {-956.458, 193.496, 24.825},
    {-1031.190, 183.211, 26.400},
    {-964.359, 315.154, 26.013},
    {-1087.380, 252.760, 24.962},
    {-1064.430, 322.243, 25.564},
    {-1233.440, 260.167, 33.651},
    {-1284.650, 395.686, 33.187},
    {-1317.280, 261.257, 33.433},
    {-1360.920, 348.367, 33.516},
    {-1329.420, 448.855, 31.925},
    {-1405.780, 401.087, 32.550},
    {-1349.430, 511.382, 31.315},
    {-1412.950, 588.520, 31.715},
    {-1463.520, 527.937, 31.185},
    {-1445.370, 659.272, 31.599},
    {-1524.610, 617.907, 32.189},
    {-1560.010, 669.493, 32.018},
    {-1666.260, 722.095, 33.306},
    {-1920.530, 650.288, 29.730},
    {-2000.740, 613.745, 29.507},
    {-1911.920, 577.268, 29.839},
    {-1975.770, 544.926, 28.910},
    {-1878.340, 492.539, 28.980},
    {-1959.270, 450.643, 30.421},
    {-1449.950, 464.936, 31.491},
    {2198.430, -240.100, 2.500},
    {2262.730, -258.020, 2.800},
    {2297.090, -185.500, 2.560},
    {2338.820, -168.770, 2.550},
    {2386.960, -258.880, 3.480},
    {2418.690, -186.480, 2.690},
    {2420.180, -244.990, 2.450},
    {2480.820, -249.440, 3.620},
    {2459.720, -189.220, 3.100},
    {2514.550, -240.120, 2.590},
    {2539.300, -186.300, 3.580},
    {2590.410, -243.490, 4.580},
    {2597.590, -173.190, 3.650},
    {2658.990, -164.000, 3.800},
    {1859.430, 1405.130, 9.798},
    {1866.000, 1439.840, 9.798},
    {1989.360, 1794.080, 15.476},
    {1945.140, 1845.340, 15.467},
    {1943.580, 1806.770, 15.547},
    {1943.520, 1752.980, 15.391},
    {1995.000, 1746.240, 15.739},
    {1764.070, 1334.140, 9.798},
    {1837.510, 2150.630, 16.046},
    {1732.270, 2197.250, 17.145},
    {1741.570, 2116.970, 16.240},
    {1800.690, 1337.780, 9.798},
    {1941.950, 1703.340, 22.263},
    {588.095, 1762.660, 12.712},
    {-169.354, 846.714, 15.529},
    {-987.281, -1999.240, 39.540},
    {-1617.600, 688.659, 32.543},
    {127.363, 438.840, 202.952},
    {1851.940, 1475.390, 9.933},
    {2229.900, -185.633, 2.599},
    {-746.644, -1863.150, 41.087},
    {353.404, 800.074, 12.000},
    {354.905, 804.006, 12.000},
    {356.451, 808.065, 12.007},
    {357.905, 811.891, 12.007},
    {359.422, 815.865, 12.000},
    {360.909, 819.765, 12.000},
    {362.431, 823.763, 12.000},
    {363.940, 827.730, 12.000},
    {365.421, 831.631, 12.008}
};

#define PVZ_DELIVERY_COUNT (10)
#define PVZ_ADDRESS_WAIT_MS (30000)
#define PVZ_PAY_FC (5)
#define PVZ_PAY_EURO (25)
#define PVZ_PAY_BIT (5)

#define PVZ_JOB_PAY (PVZ_PAY_FC)
#define PVZ_JOB_BOSS_X (2284.598144)
#define PVZ_JOB_BOSS_Y (1832.220703)
#define PVZ_JOB_BOSS_Z (1519.743286)
#define PVZ_JOB_BOSS_A (342.522583)
#define PVZ_JOB_BUTTON_X (2285.099121)
#define PVZ_JOB_BUTTON_Y (1834.363037)
#define PVZ_JOB_BUTTON_Z (1519.743286)
#define PVZ_JOB_BOSS_RADIUS (4.0)
#define PVZ_JOB_VEHICLE_SPAWN_OFFSET (4.0)

new gPvzJobPhase[MAX_PLAYERS]; // 0 idle, 1 distance run, 3 return, 4 address approach, 5 address wait
new gPvzJobVehicle[MAX_PLAYERS];
new Float:gPvzJobReturn[MAX_PLAYERS][4];
new gPvzJobType[MAX_PLAYERS]; // 0 = distance, 1 = 10 deliveries, 2 = mixed
new gPvzJobRoute[MAX_PLAYERS][PVZ_DELIVERY_COUNT];
new gPvzJobRouteIndex[MAX_PLAYERS];
new gPvzJobStopsDone[MAX_PLAYERS];
new gPvzJobDistanceTargetKm[MAX_PLAYERS];
new gPvzJobDistanceLastMsg[MAX_PLAYERS];
new Float:gPvzJobDistanceTravelled[MAX_PLAYERS];
new Float:gPvzJobLastX[MAX_PLAYERS];
new Float:gPvzJobLastY[MAX_PLAYERS];
new Float:gPvzJobLastZ[MAX_PLAYERS];

forward Pvz_SetDeliveryCheckpoint(playerid);
stock Pvz_JobStart(playerid)
{
    if(gPvzJobPhase[playerid] != 0)
    {
        SendClientMessage(playerid, 0xFF6666FF, "[ПВЗ] У вас уже есть активное задание.");
        return 1;
    }
    if(GetPlayerInterior(playerid) != PVZ_EXIT_INT || GetPlayerVirtualWorld(playerid) != PVZ_EXIT_VW ||
        !IsPlayerInRangeOfPoint(playerid, PVZ_JOB_BOSS_RADIUS, PVZ_JOB_BOSS_X, PVZ_JOB_BOSS_Y, PVZ_JOB_BOSS_Z))
    {
        SendClientMessage(playerid, 0xBBBBBBFF, "[ПВЗ] Подойдите к начальнику в помещении ПВЗ или используйте .pvz.");
        return 1;
    }

    new point = gPvzLastPoint[playerid];
    if(point < 0 || point >= PVZ_POINT_COUNT) point = 0;

    // Remember the branch where the player entered the shared PVZ interior.
    // Return the player to this same branch after the delivery shift.
    gPvzJobReturn[playerid][0] = gPvzPoint[point][0];
    gPvzJobReturn[playerid][1] = gPvzPoint[point][1];
    gPvzJobReturn[playerid][2] = gPvzPoint[point][2];
    gPvzJobReturn[playerid][3] = gPvzPoint[point][3];

    new Float:x = gPvzJobReturn[playerid][0] + PVZ_JOB_VEHICLE_SPAWN_OFFSET;
    new Float:y = gPvzJobReturn[playerid][1] + PVZ_JOB_VEHICLE_SPAWN_OFFSET;
    new Float:z = gPvzJobReturn[playerid][2] + 0.3;
    new vehicleid = CreateVehicle(PVZ_JOB_TRUCK_MODEL, x, y, z, gPvzJobReturn[playerid][3], -1, -1, 300);
    if(vehicleid == INVALID_VEHICLE_ID)
    {
        SendClientMessage(playerid, 0xFF6666FF, "[ПВЗ] Не удалось создать рабочий автомобиль. Попробуйте начать работу ещё раз.");
        return 1;
    }

    SetVehicleVirtualWorld(vehicleid, 0);

    // The job vehicle is created outside at the player's remembered branch.
    // Move the player out of the shared PVZ interior and seat them in that vehicle;
    // otherwise the truck exists outside while the player remains trapped inside.
    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerPos(playerid, x, y, z + 1.0);
    SetCameraBehindPlayer(playerid);
    PutPlayerInVehicle(playerid, vehicleid, 0);
    SendClientMessage(playerid, 0x33CCFFFF, "[PVZ] Машина создана у вашего филиала. Вы доставлены к рабочему автомобилю.");

    gPvzJobVehicle[playerid] = vehicleid;
    gPvzJobType[playerid] = random(3); // 0 = distance, 1 = 10 deliveries, 2 = mixed
    gPvzJobRouteIndex[playerid] = 0;
    gPvzJobStopsDone[playerid] = 0;
    gPvzJobDistanceTravelled[playerid] = 0.0;
    gPvzJobDistanceLastMsg[playerid] = GetTickCount();
    new distanceOptions[5] = {20, 40, 100, 200, 300};
    gPvzJobDistanceTargetKm[playerid] = distanceOptions[random(sizeof(distanceOptions))];
    GetPlayerPos(playerid, gPvzJobLastX[playerid], gPvzJobLastY[playerid], gPvzJobLastZ[playerid]);
    DisablePlayerCheckpoint(playerid);
    SetPlayerMapIcon(playerid, PVZ_MAPICON_VEHICLE, x, y, z, 0, 0xFFD700FF, 0);
    gPvzLastTp[playerid] = GetTickCount();

    if(gPvzJobType[playerid] == 0 || gPvzJobType[playerid] == 2)
    {
        gPvzJobPhase[playerid] = 1;
        // No destination/pickup: the player completes the requested distance by driving.
        // Keep the map marker on the original PVZ branch for the return leg.
        SetPlayerMapIcon(playerid, PVZ_MAPICON_JOB, gPvzJobReturn[playerid][0], gPvzJobReturn[playerid][1], gPvzJobReturn[playerid][2], 0, 0x33CCFFFF, 0);
        new msg[144];
        format(msg, sizeof msg, "[PVZ] \xE5\xE9\xF1: \xED\xE0\xEA\xE0\xF2\xE0\xE9\xF2\xE5 %d \xEA\xEC \xEF\xEE \xE4\xEE\xF0\xEE\xE3\xE0\xEC, \xE7\xE0\xF2\xE5\xEC \xE2\xEE\xE7\xE2\xF0\xE0\xF9\xE0\xE9\xF2\xE5\xF1\xFC \xE2 \xF4\xE8\xEB\xE8\xE0\xEB.", gPvzJobDistanceTargetKm[playerid]);
        SendClientMessage(playerid, 0x33CCFFFF, msg);
        SendClientMessage(playerid, -1, "[PVZ] \xCA\xE8\xEB\xEE\xEC\xE5\xF2\xF0\xFB \xF1\xF7\xE8\xF2\xE0\xFE\xF2\xF1\xFF \xEF\xEE \xF4\xE0\xEA\xF2\xE8\xF7\xE5\xF1\xEA\xEE\xEC\xF3 \xEF\xF3\xF2\xE8 \xED\xE0 \xF0\xE0\xE1\xEE\xF7\xE5\xE9 \xEC\xE0\xF8\xE8\xED\xE5.");
        if(gPvzJobType[playerid] == 2)
            SendClientMessage(playerid, -1, "[PVZ] \xCF\xEE\xF1\xEB\xE5 \xF0\xE5\xE9\xF1\xE0 \xED\xF3\xE6\xED\xEE \xE1\xF3\xE4\xE5\xF2 \xE2\xFB\xEF\xEE\xEB\xED\xE8\xF2\xFC 10 \xE4\xEE\xF1\xF2\xE0\xE2\xEE\xEA.");
    }
    else
    {
        for(new i = 0; i < PVZ_DELIVERY_COUNT; i++)
        {
            new pick, duplicate;
            do
            {
                pick = random(PVZ_DELIVERY_POINT_COUNT);
                duplicate = 0;
                for(new j = 0; j < i; j++)
                    if(gPvzJobRoute[playerid][j] == pick) duplicate = 1;
            }
            while(duplicate);
            gPvzJobRoute[playerid][i] = pick;
        }
        gPvzJobPhase[playerid] = 4;
        Pvz_SetDeliveryCheckpoint(playerid);
        SendClientMessage(playerid, 0x33CCFFFF, "[PVZ] \xD2\xE8\xEF \xE7\xE0\xEA\xE0\xE7\xE0: \xE4\xEE\xF1\xF2\xE0\xE2\xEA\xE0. \xCD\xF3\xE6\xED\xEE \xEF\xEE\xF1\xE5\xF2\xE8\xF2\xFC 10 \xF0\xE0\xE7\xED\xFB\xF5 \xE4\xEE\xEC\xEE\xE2, \xEA\xE2\xE0\xF0\xF2\xE8\xF0 \xE8\xEB\xE8 \xE3\xE0\xF0\xE0\xE6\xE5\xE9.");
    }
    return 1;
}


stock Pvz_JobFinish(playerid, bool:pay)
{
    if(gPvzJobLoadTimer[playerid] != 0) KillTimer(gPvzJobLoadTimer[playerid]);
    gPvzJobLoadTimer[playerid] = 0;
    gPvzJobLoading[playerid] = false;
    DisablePlayerCheckpoint(playerid);
    RemovePlayerMapIcon(playerid, PVZ_MAPICON_JOB);
    RemovePlayerMapIcon(playerid, PVZ_MAPICON_VEHICLE);
    if(gPvzJobVehicle[playerid] != INVALID_VEHICLE_ID)
    {
        if(IsPlayerInVehicle(playerid, gPvzJobVehicle[playerid])) RemovePlayerFromVehicle(playerid);
        DestroyVehicle(gPvzJobVehicle[playerid]);
    }
    gPvzJobVehicle[playerid] = INVALID_VEHICLE_ID;
    gPvzJobPhase[playerid] = 0;
    gPvzJobLastCheck[playerid] = 0;
    gPvzJobLoading[playerid] = false;

    if(pay)
    {
        // Store pending rewards in PVars for the existing EuroSystem integration.
        SetPVarInt(playerid, "FR_PVZ_PENDING_FC", GetPVarInt(playerid, "FR_PVZ_PENDING_FC") + PVZ_PAY_FC);
        SetPVarInt(playerid, "FR_PVZ_PENDING_EURO", GetPVarInt(playerid, "FR_PVZ_PENDING_EURO") + PVZ_PAY_EURO);
        SetPVarInt(playerid, "FR_PVZ_PENDING_BIT", GetPVarInt(playerid, "FR_PVZ_PENDING_BIT") + PVZ_PAY_BIT);
        SendClientMessage(playerid, 0xFFCC33FF, "[ПВЗ] Задание завершено: начислено 25 FunCoin, 5 Euro и 5 Bitcoin в ожидающие награды.");
    }
    return 1;
}

stock Pvz_SetDeliveryCheckpoint(playerid)
{
    new routeIndex = gPvzJobRouteIndex[playerid];
    if(routeIndex < 0 || routeIndex >= PVZ_DELIVERY_COUNT) return 0;
    new pointIndex = gPvzJobRoute[playerid][routeIndex];
    if(pointIndex < 0 || pointIndex >= PVZ_DELIVERY_POINT_COUNT) return 0;
    new Float:x = gPvzDeliveryPoints[pointIndex][0];
    new Float:y = gPvzDeliveryPoints[pointIndex][1];
    new Float:z = gPvzDeliveryPoints[pointIndex][2];
    DisablePlayerCheckpoint(playerid);
    SetPlayerCheckpoint(playerid, x, y, z, 7.0);
    RemovePlayerMapIcon(playerid, PVZ_MAPICON_JOB);
    SetPlayerMapIcon(playerid, PVZ_MAPICON_JOB, x, y, z, 0, 0x33CCFFFF, 0);
    new msg[112];
    format(msg, sizeof msg, "[ПВЗ] Точка %d/10: X=%.1f, Y=%.1f. Следуйте к месту доставки.", routeIndex + 1, x, y);
    SendClientMessage(playerid, 0xFFFFFFFF, msg);
    return 1;
}

stock Pvz_JobProgress(playerid)
{
    if(gPvzJobPhase[playerid] == 0) return 0;
    if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return 0;
    if(!IsPlayerInVehicle(playerid, gPvzJobVehicle[playerid])) return 0;

    if(gPvzJobPhase[playerid] == 1)
    {
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        new Float:dx = x - gPvzJobLastX[playerid];
        new Float:dy = y - gPvzJobLastY[playerid];
        new Float:dz = z - gPvzJobLastZ[playerid];
        new Float:step = floatsqroot(dx * dx + dy * dy + dz * dz);
        // Ignore teleports/large coordinate jumps so they cannot complete the distance task.
        if(step <= 120.0) gPvzJobDistanceTravelled[playerid] += step;
        gPvzJobLastX[playerid] = x;
        gPvzJobLastY[playerid] = y;
        gPvzJobLastZ[playerid] = z;
        new now = GetTickCount();
        if(now - gPvzJobDistanceLastMsg[playerid] >= 10000)
        {
            gPvzJobDistanceLastMsg[playerid] = now;
            new progress[96];
            format(progress, sizeof progress, "[PVZ] \xCF\xF0\xEE\xE5\xE4\xE5\xED\xEE: %.1f / %d \xEA\xEC.", gPvzJobDistanceTravelled[playerid] / 1000.0, gPvzJobDistanceTargetKm[playerid]);
            SendClientMessage(playerid, 0xFFD700FF, progress);
        }
        new Float:targetUnits = float(gPvzJobDistanceTargetKm[playerid]) * 1000.0;
        if(gPvzJobDistanceTravelled[playerid] >= targetUnits)
        {
            if(gPvzJobType[playerid] == 2)
            {
                for(new i = 0; i < PVZ_DELIVERY_COUNT; i++)
                {
                    new pick, duplicate;
                    do
                    {
                        pick = random(PVZ_DELIVERY_POINT_COUNT);
                        duplicate = 0;
                        for(new j = 0; j < i; j++) if(gPvzJobRoute[playerid][j] == pick) duplicate = 1;
                    }
                    while(duplicate);
                    gPvzJobRoute[playerid][i] = pick;
                }
                gPvzJobPhase[playerid] = 4;
                gPvzJobRouteIndex[playerid] = 0;
                gPvzJobStopsDone[playerid] = 0;
                Pvz_SetDeliveryCheckpoint(playerid);
                SendClientMessage(playerid, 0x33CCFFFF, "[PVZ] \xD0\xE5\xE9\xF1 \xE7\xE0\xE2\xE5\xF0\xF8\xB8\xED. \xCD\xE0\xF7\xE8\xED\xE0\xE9\xF2\xE5 10 \xE4\xEE\xF1\xF2\xE0\xE2\xEE\xEA.");
            }
            else
            {
                gPvzJobPhase[playerid] = 3;
                DisablePlayerCheckpoint(playerid);
                SetPlayerCheckpoint(playerid, gPvzJobReturn[playerid][0], gPvzJobReturn[playerid][1], gPvzJobReturn[playerid][2], 8.0);
                new msg[128];
                format(msg, sizeof msg, "[PVZ] \xC4\xE8\xF1\xF2\xE0\xED\xF6\xE8\xFF %d \xEA\xEC \xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xE0. \xC2\xEE\xE7\xE2\xF0\xE0\xF9\xE0\xE9\xF2\xE5\xF1\xFC \xE2 \xF4\xE8\xEB\xE8\xE0\xEB.", gPvzJobDistanceTargetKm[playerid]);
                SendClientMessage(playerid, 0x33CCFFFF, msg);
            }
            return 1;
        }
        return 1;
    }
    if(gPvzJobPhase[playerid] == 3 &&
        IsPlayerInRangeOfPoint(playerid, 12.0, gPvzJobReturn[playerid][0], gPvzJobReturn[playerid][1], gPvzJobReturn[playerid][2]))
    {
        Pvz_JobFinish(playerid, true);
        return 1;
    }
    if(gPvzJobPhase[playerid] == 4)
    {
        new routeIndex = gPvzJobRouteIndex[playerid];
        new pointIndex = gPvzJobRoute[playerid][routeIndex];
        if(IsPlayerInRangeOfPoint(playerid, 7.0, gPvzDeliveryPoints[pointIndex][0], gPvzDeliveryPoints[pointIndex][1], gPvzDeliveryPoints[pointIndex][2]))
        {
            if(!gPvzJobLoading[playerid])
            {
                gPvzJobLoading[playerid] = true;
                gPvzJobPhase[playerid] = 5;
                SendClientMessage(playerid, 0x33CCFFFF, "[ПВЗ] Вы на месте. Ожидайте завершения доставки 30 секунд.");
                gPvzJobLoadTimer[playerid] = SetTimerEx("Pvz_JobFinishDelivery", PVZ_ADDRESS_WAIT_MS, false, "i", playerid);
            }
            return 1;
        }
    }
    return 0;
}

forward Pvz_JobFinishDelivery(playerid);
public Pvz_JobFinishDelivery(playerid)
{
    gPvzJobLoadTimer[playerid] = 0;
    if(!IsPlayerConnected(playerid) || gPvzJobPhase[playerid] != 5) return 1;
    new routeIndex = gPvzJobRouteIndex[playerid];
    new pointIndex = gPvzJobRoute[playerid][routeIndex];
    if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0 ||
        !IsPlayerInVehicle(playerid, gPvzJobVehicle[playerid]) ||
        !IsPlayerInRangeOfPoint(playerid, 7.0, gPvzDeliveryPoints[pointIndex][0], gPvzDeliveryPoints[pointIndex][1], gPvzDeliveryPoints[pointIndex][2]))
    {
        gPvzJobLoading[playerid] = false;
        gPvzJobPhase[playerid] = 4;
        SendClientMessage(playerid, 0xFFCC33FF, "[ПВЗ] Доставка не засчитана: оставайтесь в машине на точке все 30 секунд.");
        return 1;
    }
    gPvzJobLoading[playerid] = false;
    gPvzJobStopsDone[playerid]++;
    gPvzJobRouteIndex[playerid]++;
    new msg[96];
    format(msg, sizeof msg, "[ПВЗ] Доставок выполнено: %d из %d.", gPvzJobStopsDone[playerid], PVZ_DELIVERY_COUNT);
    SendClientMessage(playerid, 0x33CCFFFF, msg);
    if(gPvzJobStopsDone[playerid] >= PVZ_DELIVERY_COUNT)
    {
        gPvzJobPhase[playerid] = 3;
        DisablePlayerCheckpoint(playerid);
        SetPlayerCheckpoint(playerid, gPvzJobReturn[playerid][0], gPvzJobReturn[playerid][1], gPvzJobReturn[playerid][2], 8.0);
        RemovePlayerMapIcon(playerid, PVZ_MAPICON_JOB);
        SetPlayerMapIcon(playerid, PVZ_MAPICON_JOB, gPvzJobReturn[playerid][0], gPvzJobReturn[playerid][1], gPvzJobReturn[playerid][2], 0, 0x33CCFFFF, 0);
        SendClientMessage(playerid, 0x33CCFFFF, "[ПВЗ] Все 10 доставок выполнены. Возвращайтесь в свой филиал для завершения смены.");
        return 1;
    }
    gPvzJobPhase[playerid] = 4;
    Pvz_SetDeliveryCheckpoint(playerid);
    return 1;
}

stock Pvz_JobCancel(playerid)
{
    if(gPvzJobPhase[playerid] == 0) return 0;
    Pvz_JobFinish(playerid, false);
    SendClientMessage(playerid, 0xFF6666FF, "[ПВЗ] Работа отменена. Вы можете начать заново.");
    return 1;
}

stock Pvz_HandleDotCommand(playerid, text[])
{
    if(text[0] != '.') return 0;
    new cmd[24];
    format(cmd, sizeof(cmd), "%s", text[1]);
    new space = strfind(cmd, " ");
    if(space != -1) cmd[space] = '\0';
    if(!strcmp(cmd, "pvz", true))
    {
        if(GetPlayerInterior(playerid) == PVZ_EXIT_INT &&
            GetPlayerVirtualWorld(playerid) == PVZ_EXIT_VW &&
            IsPlayerInRangeOfPoint(playerid, 5.0, PVZ_JOB_BUTTON_X, PVZ_JOB_BUTTON_Y, PVZ_JOB_BUTTON_Z))
            return Pvz_JobStart(playerid);
        Pvz_ShowHelp(playerid);
        return 1;
    }
    if(!strcmp(cmd, "pvzcancel", true))
    {
        Pvz_JobCancel(playerid);
        return 1;
    }
    return 0;
}

stock Pvz_SetEntranceMapIcons(playerid)
{
    for(new i = 0; i < PVZ_POINT_COUNT; i++)
        SetPlayerMapIcon(playerid, 40 + i, gPvzPoint[i][0], gPvzPoint[i][1], gPvzPoint[i][2], 0, 0x33CCFFFF, 0);
    return 1;
}

public OnPlayerConnect(playerid)
{
    Pvz_SetEntranceMapIcons(playerid);
    return 1;
}

public OnFilterScriptInit()
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        gPvzJobVehicle[i] = INVALID_VEHICLE_ID;
        if(IsPlayerConnected(i)) Pvz_SetEntranceMapIcons(i);
    }
    print("[FunRussia_PVZ] Loaded: distance, delivery and mixed routes; old cargo pickup removed.");
    for(new i = 0; i < PVZ_POINT_COUNT; i++)
    {
        gPvzEnterPickup[i] = CreatePickup(PVZ_PICKUP_MODEL, 1,
            gPvzPoint[i][0], gPvzPoint[i][1], gPvzPoint[i][2], 0);

        new label[160];
        format(label, sizeof(label), "{33CCFF}\xCF\xF3\xED\xEA\xF2 \xE2\xFB\xE4\xE0\xF7\xE8 \xE7\xE0\xEA\xE0\xE7\xEE\xE2\n{FFFFFF}%s\n{66FF66}\xC2\xF5\xEE\xE4", gPvzPointName[i]);
        Create3DTextLabel(label, -1, gPvzPoint[i][0], gPvzPoint[i][1], gPvzPoint[i][2] + 1.0, 20.0, 0, 0);
    }

    gPvzExitPickup = CreatePickup(PVZ_PICKUP_MODEL, 1, PVZ_INSIDE_X, PVZ_INSIDE_Y, PVZ_INSIDE_Z, PVZ_EXIT_VW);
    Create3DTextLabel("{33CCFF}\xCF\xF3\xED\xEA\xF2 \xE2\xFB\xE4\xE0\xF7\xE8 \xE7\xE0\xEA\xE0\xE7\xEE\xE2\n{FFFFFF}\xC2\xFB\xF5\xEE\xE4 \xE8\xE7 \xCF\xC2\xC7", -1, PVZ_INSIDE_X, PVZ_INSIDE_Y, PVZ_INSIDE_Z + 1.0, 12.0, 0, PVZ_EXIT_VW);
    gPvzRewardPickup = CreatePickup(PVZ_REWARD_PICKUP_MODEL, 1, PVZ_REWARD_X, PVZ_REWARD_Y, PVZ_REWARD_Z, PVZ_REWARD_VW);
    Create3DTextLabel("{33CCFF}\xCF\xF3\xED\xEA\xF2 \xE2\xFB\xE4\xE0\xF7\xE8 \xE7\xE0\xEA\xE0\xE7\xEE\xE2\n{FFFFFF}\xC7\xE0\xE1\xF0\xE0\xF2\xFC \xE3\xEE\xF2\xEE\xE2\xFB\xE9 \xE7\xE0\xEA\xE0\xE7\n{66FF66}\xC2\xF1\xF2\xE0\xED\xFC\xF2\xE5 \xED\xE0 \xEF\xE8\xEA\xE0\xEF, \xF7\xF2\xEE\xE1\xFB \xEE\xF2\xEA\xF0\xFB\xF2\xFC \xE2\xFB\xE4\xE0\xF7\xF3", -1,
        PVZ_REWARD_X, PVZ_REWARD_Y, PVZ_REWARD_Z + 0.9, 20.0, 0, PVZ_REWARD_VW);

    // Pickup and marker for leaving the shared interior.

    // Counter NPC and a real, always-active pickup at the job interaction point.
    gPvzBossActor = CreateActor(31, PVZ_JOB_BOSS_X, PVZ_JOB_BOSS_Y, PVZ_JOB_BOSS_Z, PVZ_JOB_BOSS_A);
    if(gPvzBossActor != INVALID_ACTOR_ID)
    {
        SetActorVirtualWorld(gPvzBossActor, PVZ_EXIT_VW);
        SetActorInvulnerable(gPvzBossActor, true);
    }
    Create3DTextLabel("{FFD700}\xC4\xE5\xE2\xF3\xF8\xEA\xE0 \xCF\xC2\xC7\n{FFFFFF}.pvz - \xED\xE0\xF7\xE0\xF2\xFC \xF0\xE0\xE1\xEE\xF2\xF3", -1,
        PVZ_JOB_BOSS_X, PVZ_JOB_BOSS_Y, PVZ_JOB_BOSS_Z + 0.9, 15.0, 0, PVZ_EXIT_VW);
    gPvzBossPickup = CreatePickup(PVZ_PICKUP_MODEL, 1, PVZ_JOB_BUTTON_X, PVZ_JOB_BUTTON_Y, PVZ_JOB_BUTTON_Z, PVZ_EXIT_VW);
    Create3DTextLabel("{FFD700}\xD1\xF2\xE0\xF0\xF2 \xE7\xE0\xEA\xE0\xE7\xE0\n{FFFFFF}\xCF\xEE\xE4\xEE\xE9\xE4\xE8\xF2\xE5 \xE8 \xED\xE0\xEF\xE8\xF8\xE8\xF2\xE5 .pvz", -1,
        PVZ_JOB_BUTTON_X, PVZ_JOB_BUTTON_Y, PVZ_JOB_BUTTON_Z + 0.8, 12.0, 0, PVZ_EXIT_VW);
    return 1;
}

public OnPlayerText(playerid, text[])
{
    if(Pvz_HandleDotCommand(playerid, text)) return 0;
    return 1;
}

// Reliable proximity fallback for entrances/exits if pickup callback is swallowed.
public OnPlayerUpdate(playerid)
{
    new tick = GetTickCount();

    if(gPvzJobPhase[playerid] != 0 && tick - gPvzJobLastCheck[playerid] >= PVZ_ROUTE_CHECK_MS)
    {
        gPvzJobLastCheck[playerid] = tick;
        Pvz_JobProgress(playerid);
    }

    if(tick - gPvzLastTp[playerid] < PVZ_TP_COOLDOWN_MS) return 1;

    // Shared PVZ room: arm exit only after the player has moved away from the entry spawn.
    // The exit pickup is close to the spawn point, so without this guard entry instantly bounces out.
    if(GetPlayerInterior(playerid) == PVZ_EXIT_INT &&
       GetPlayerVirtualWorld(playerid) == PVZ_EXIT_VW &&
       !gPvzInsideReady[playerid] &&
       !IsPlayerInRangeOfPoint(playerid, 2.5, PVZ_EXIT_X, PVZ_EXIT_Y, PVZ_EXIT_Z))
    {
        gPvzInsideReady[playerid] = true;
    }

    if(GetPlayerInterior(playerid) == PVZ_EXIT_INT &&
       GetPlayerVirtualWorld(playerid) == PVZ_EXIT_VW &&
       gPvzInsideReady[playerid] &&
       IsPlayerInRangeOfPoint(playerid, 2.0, PVZ_INSIDE_X, PVZ_INSIDE_Y, PVZ_INSIDE_Z))
    {
        new point = gPvzLastPoint[playerid];
        if(point < 0 || point >= PVZ_POINT_COUNT) point = 0;
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, gPvzPoint[point][0], gPvzPoint[point][1], gPvzPoint[point][2] + 1.0);
        gPvzInsideReady[playerid] = false;
        SetCameraBehindPlayer(playerid);
        gPvzLastTp[playerid] = tick;
        return 1;
    }

    // Outside: enter the shared room and remember this player's branch.
    if(GetPlayerInterior(playerid) == 0 && GetPlayerVirtualWorld(playerid) == 0 &&
       gPvzJobPhase[playerid] == 0 && !IsPlayerInAnyVehicle(playerid))
    {
        for(new i = 0; i < PVZ_POINT_COUNT; i++)
        {
            if(IsPlayerInRangeOfPoint(playerid, 2.0, gPvzPoint[i][0], gPvzPoint[i][1], gPvzPoint[i][2]))
            {
                gPvzLastPoint[playerid] = i;
                SetPlayerInterior(playerid, PVZ_EXIT_INT);
                SetPlayerVirtualWorld(playerid, PVZ_EXIT_VW);
                SetPlayerPos(playerid, PVZ_EXIT_X, PVZ_EXIT_Y, PVZ_EXIT_Z + 0.5);
                gPvzInsideReady[playerid] = false;
                SetCameraBehindPlayer(playerid);
                SetPlayerFacingAngle(playerid, 0.0);
                gPvzLastTp[playerid] = tick;
                SendClientMessage(playerid, -1, "[PVZ] \xC2\xF5\xEE\xE4 \xE2 \xF4\xE8\xEB\xE8\xE0\xEB \xE0\xEA\xF2\xE8\xE2\xE8\xF0\xEE\xE2\xE0\xED.");
                return 1;
            }
        }
    }
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    new tick = GetTickCount();

    // Job/reward pickups must not be blocked by the teleport cooldown after entering PVZ.
    if(pickupid == gPvzBossPickup)
    {
        if(GetPlayerInterior(playerid) == PVZ_EXIT_INT && GetPlayerVirtualWorld(playerid) == PVZ_EXIT_VW)
            return Pvz_JobStart(playerid);
        return 1;
    }
    if(pickupid == gPvzRewardPickup)
    {
        Pvz_OpenRewardsWithFallback(playerid);
        return 1;
    }
    if(pickupid == gPvzExitPickup)
    {
        if(tick - gPvzLastTp[playerid] < PVZ_TP_COOLDOWN_MS) return 1;
        new i = gPvzLastPoint[playerid];
        if(i < 0 || i >= PVZ_POINT_COUNT) i = 0;
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, gPvzPoint[i][0], gPvzPoint[i][1], gPvzPoint[i][2] + 1.0);
        SetCameraBehindPlayer(playerid);
        gPvzLastTp[playerid] = tick;
        new msg[128];
        format(msg, sizeof(msg), "{33aa33}| {FFFFFF}\xC2\xFB \xE2\xFB\xF8\xEB\xE8 \xE8\xE7 \xCF\xC2\xC7 \"%s\".", gPvzPointName[i]);
        SendClientMessage(playerid, -1, msg);
        return 1;
    }
    for(new i = 0; i < PVZ_POINT_COUNT; i++)
    {
        if(pickupid == gPvzEnterPickup[i])
        {
            if(gPvzJobPhase[playerid] != 0 || IsPlayerInAnyVehicle(playerid)) return 1;
            if(tick - gPvzLastTp[playerid] < PVZ_TP_COOLDOWN_MS) return 1;
            SetPlayerInterior(playerid, PVZ_EXIT_INT);
            SetPlayerVirtualWorld(playerid, PVZ_EXIT_VW);
            SetPlayerPos(playerid, PVZ_EXIT_X, PVZ_EXIT_Y, PVZ_EXIT_Z + 0.5);
            gPvzInsideReady[playerid] = false;
            SetCameraBehindPlayer(playerid);
            SetPlayerFacingAngle(playerid, 0.0);
            gPvzLastPoint[playerid] = i;
            gPvzLastTp[playerid] = tick;
            new msg[128];
            format(msg, sizeof(msg), "{33aa33}| {FFFFFF}\xC2\xFB \xE2\xEE\xF8\xEB\xE8 \xE2 \xCF\xC2\xC7 \"%s\".", gPvzPointName[i]);
            SendClientMessage(playerid, -1, msg);
            return 1;
        }
    }
    return 0;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if(gPvzJobPhase[playerid] == 0) return 1;
    if(!IsPlayerInVehicle(playerid, gPvzJobVehicle[playerid]))
    {
        SendClientMessage(playerid, 0xFF6666FF, "[ПВЗ] Для выполнения задания необходимо находиться в рабочем автомобиле.");
        return 1;
    }
    Pvz_JobProgress(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason
    if(gPvzJobVehicle[playerid] != INVALID_VEHICLE_ID)
        DestroyVehicle(gPvzJobVehicle[playerid]);
    gPvzJobVehicle[playerid] = INVALID_VEHICLE_ID;
    gPvzJobPhase[playerid] = 0;
    gPvzLastTp[playerid] = 0;
    gPvzLastPoint[playerid] = 0;
    gPvzInsideReady[playerid] = false;
    gPvzJobLastCheck[playerid] = 0;
    gPvzJobDistanceTravelled[playerid] = 0.0;
    gPvzJobDistanceTargetKm[playerid] = 0;
    gPvzJobDistanceLastMsg[playerid] = 0;
    if(gPvzJobLoadTimer[playerid] != 0) KillTimer(gPvzJobLoadTimer[playerid]);
    gPvzJobLoadTimer[playerid] = 0;
    gPvzJobLoading[playerid] = false;
    for(new i = 0; i < PVZ_POINT_COUNT; i++) RemovePlayerMapIcon(playerid, 40 + i);
    RemovePlayerMapIcon(playerid, PVZ_MAPICON_JOB);
    RemovePlayerMapIcon(playerid, PVZ_MAPICON_VEHICLE);
    return 1;
}

public OnFilterScriptExit()
{
    for(new i = 0; i < PVZ_POINT_COUNT; i++)
        if(gPvzEnterPickup[i] != 0) DestroyPickup(gPvzEnterPickup[i]);
    if(gPvzExitPickup != -1) DestroyPickup(gPvzExitPickup);
    if(gPvzRewardPickup != -1) DestroyPickup(gPvzRewardPickup);
    if(gPvzBossPickup != -1) DestroyPickup(gPvzBossPickup);
    if(gPvzCargoLabel != Text3D:INVALID_3DTEXT_ID) Delete3DTextLabel(gPvzCargoLabel);
    if(gPvzCargoPickup != -1) DestroyPickup(gPvzCargoPickup);
    if(gPvzBossActor != INVALID_ACTOR_ID) DestroyActor(gPvzBossActor);
    for(new p = 0; p < MAX_PLAYERS; p++)
    {
        if(gPvzJobVehicle[p] != INVALID_VEHICLE_ID) DestroyVehicle(gPvzJobVehicle[p]);
        gPvzJobVehicle[p] = INVALID_VEHICLE_ID;
        gPvzJobPhase[p] = 0;
    }
    return 1;
}
