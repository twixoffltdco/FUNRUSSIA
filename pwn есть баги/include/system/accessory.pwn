#if !defined create_player_btn
new bool:create_player_btn[MAX_PLAYERS];
#endif
// Global textdraws
new Text:acsmagaz_button_TD[5];
new Text: acss_fix_TD[28];
new PlayerText: acss_coords_fix_PTD[MAX_PLAYERS][1];
// Player textdraws
new PlayerText:acsmagaz_price_PTD[MAX_PLAYERS][1];
new PlayerText:acsmagaz_name_PTD[MAX_PLAYERS][1];

stock AccessoryEdit_DestroyCoordsTextdraw(playerid)
{
    if(GetPVarInt(playerid, "acss_coords_td_created"))
    {
        PlayerTextDrawHide(playerid, acss_coords_fix_PTD[playerid][0]);
        PlayerTextDrawDestroy(playerid, acss_coords_fix_PTD[playerid][0]);
        DeletePVar(playerid, "acss_coords_td_created");
    }

    acss_coords_fix_PTD[playerid][0] = PlayerText:-1;
    return 1;
}

stock bool:AccessoryIsHandCase(acs_id)
{
    if(acs_id < 0 || acs_id >= sizeof(accessory)) return false;
    return strfind(accessory[acs_id][NAME_ACCESSORY], "Кейс", true) != -1;
}

stock bool:AccessoryIsHeadWear(acs_id)
{
    if(acs_id < 0 || acs_id >= sizeof(accessory)) return false;

    new name[64];
    format(name, sizeof name, "%s", accessory[acs_id][NAME_ACCESSORY]);

    if(strfind(name, "Шап", true) != -1) return true;
    if(strfind(name, "Кеп", true) != -1) return true;
    if(strfind(name, "Панам", true) != -1) return true;
    if(strfind(name, "Шляп", true) != -1) return true;
    if(strfind(name, "Очк", true) != -1) return true;
    if(strfind(name, "Авиатор", true) != -1) return true;
    if(strfind(name, "Маск", true) != -1) return true;
    if(strfind(name, "Шлем", true) != -1) return true;
    if(strfind(name, "Каск", true) != -1) return true;
    if(strfind(name, "Пакет", true) != -1) return true;
    if(strfind(name, "Корона", true) != -1) return true;
    if(strfind(name, "Венок", true) != -1) return true;
    if(strfind(name, "Ушки", true) != -1) return true;
    if(strfind(name, "Рога", true) != -1) return true;
    if(strfind(name, "Нимб", true) != -1) return true;
    return false;
}

stock AccessoryResolveBone(acs_id, stored_bone)
{
    // Cases must follow the animated right hand instead of the torso.
    if(AccessoryIsHandCase(acs_id)) return A_OBJECT_BONE_RIGHT_HAND;
    // Headwear follows head rotation instead of remaining attached to the torso.
    if(AccessoryIsHeadWear(acs_id)) return A_OBJECT_BONE_HEAD;
    return stored_bone;
}

stock AccessorySyncTempData(playerid, slot, modelid, bone, Float:x, Float:y, Float:z, Float:rX, Float:rY, Float:rZ, Float:scale)
{
    if(slot < 0 || slot >= MAX_PLAYER_ATTACHED_OBJECTS || modelid <= 0)
    {
        return 0;
    }

    gPlayerTempAccData[playerid][slot][0] = float(modelid);
    gPlayerTempAccData[playerid][slot][1] = float(bone);
    gPlayerTempAccData[playerid][slot][2] = x;
    gPlayerTempAccData[playerid][slot][3] = y;
    gPlayerTempAccData[playerid][slot][4] = z;
    gPlayerTempAccData[playerid][slot][5] = rX;
    gPlayerTempAccData[playerid][slot][6] = rY;
    gPlayerTempAccData[playerid][slot][7] = rZ;
    gPlayerTempAccData[playerid][slot][8] = scale;
    gPlayerTempAccData[playerid][slot][9] = scale;
    gPlayerTempAccData[playerid][slot][10] = scale;
    return 1;
}

stock AccessorySyncTempDataFromEditor(playerid)
{
    return AccessorySyncTempData
    (
        playerid,
        GetPVarInt(playerid, "slot"),
        GetPVarInt(playerid, "edit_modelid"),
        GetPVarInt(playerid, "bone"),
        GetPVarFloat(playerid, "edit_x"),
        GetPVarFloat(playerid, "edit_y"),
        GetPVarFloat(playerid, "edit_z"),
        GetPVarFloat(playerid, "edit_rX"),
        GetPVarFloat(playerid, "edit_rY"),
        GetPVarFloat(playerid, "edit_rZ"),
        GetPVarFloat(playerid, "edit_scale")
    );
}

#if !defined player_select_accessory
new player_select_accessory[MAX_PLAYERS];
#endif
#if !defined ID_ACCESSORY
enum ACCESSORY_M_STRCT
{
    ID_ACCESSORY,
    BONE_ACCESSORY,
    NAME_ACCESSORY[32],
    PRICE_ACCESSORY,
};
#endif
#if !defined pl_accessory
new pl_accessory[MAX_PLAYERS];
#endif
#if !defined pl_id_accessory
new pl_id_accessory[MAX_PLAYERS];
#endif
//1 - Спина 
//2 - Голова 
//3 - Плечо левой руки 
//4 - Плечо правой руки 
//5 - Левая рука 
//6 - Правая рука 
//7 - Левое бедро 
//8 - Правое бедро 
//9 - Левая нога 
//10 - Правая нога 
//11 - Правая голень
//12 - Левая голень
//13 - Левое предплечье 
//14 - Правое предплечье 
//15 - Левая ключица 
//16 - Правая ключица 
//17 - Шея 
//18 - Челюстьщас


#if !defined accessory_shop_data
new accessory_shop_data[][ACCESSORY_M_STRCT] =
{
    {4196 , 1,"Крылья бабочки"                        ,15000000},
    {4197 , 2,"Маска пчелы"                           ,10000000},
    {4198 , 2,"Кленовая корона"                       ,7000000},
    {4199 , 1,"Рюкзак - реактивный ранец"             ,5000000},
    {4200 , 1,"Кленовая сумка"                        ,5000000},
    {4201 , 1,"Метла"                                 ,1000000},
    {4203 , 1,"Рюкзак с овощами"                      ,3000000},
    {4204 , 1,"Школьный рюкзак"                       ,3000000},
    {4205 , 2,"Шапка - подсолнух"                     ,2500000},
    {4206 , 1,"Черный зонт"                           ,1500000},
    {4207 , 1,"Зонт с листьями"                       ,1000000},
    {4208 , 1,"Розовый зонт"                          ,900000},
    {14574, 1,"Крылья демона"                         ,15000000},
    {14575, 1,"Крылья ангела"                         ,15000000},
    {14593, 1,"Карамельные крылья"                    ,15000000},
    {15134, 1,"Рюкзак инопланетянин"                  ,12000000},
    {15135, 2,"Шляпа ведьмы"                          ,2000000},
    {15136, 2,"Шляпа ведьмы"                          ,2000000},
    {15137, 2,"Шляпа ведьмы"                          ,2000000},
    {15138, 2,"Шляпа звезды"                          ,2000000},
    {15139, 2,"Красная шляпа ведьмы"                  ,2500000}, 
    {15140, 2,"Шляпа ведьмы"                          ,2000000},
    {15141, 2,"Шляпа ведьмы"                          ,2000000},
    {15142, 1,"Железная коса"                         ,2000000},
    {15143, 1,"Металлическая коса"                    ,1500000},
    {15144, 2,"Светящиеся красная маска"              ,500000},
    {15145, 2,"Маска маньяка"                         ,500000},
    {15146, 2,"Плачущая маска"                        ,500000},
    {15147, 2,"Страшная маска"                        ,700000},
    {15149, 1,"Метла"                                 ,1000000},
    {15150, 1,"Рюкзак FnaF"                           ,1500000},
    {15151, 2,"Маска ведущего"                        ,3000000},
    {15152, 2,"Светящиеся синяя маска"                ,500000},
    {15153, 2,"Светящиеся фиолетовая маска"           ,500000},
    {7329 , 2,"Красная повязка"                       ,300000},
    {7330 , 2,"Красная повязка"                       ,300000},
    {7331 , 2,"Военная каска 2"                       ,500000},
    {7332 , 2,"Черная шапка"                          ,300000},
    {7333 , 2,"Белая шапка"                           ,300000},
    {7334 , 2,"Синяя шапка"                           ,300000},
    {7336 , 2,"Синяя кепка 2"                         ,300000},
    {7337 , 2,"Синяя кепка 3"                         ,300000},
    {7338 , 2,"Разноцветная кепка"                    ,300000},
    {7339 , 2,"Черная кепка"                          ,300000},
    {7341 , 2,"Кепка (NY)"                            ,400000},
    {7342 , 2,"Шапка (Шерлок)"                        ,400000},
    {7343 , 2,"Панама №1 супе"                        ,300000},
    {7344 , 2,"Панама №2 (StoneIS)"                   ,300000},
    {7345 , 2,"Панама №3"                             ,300000},
    {7346 , 2,"Панана №4"                             ,300000},
    {7347 , 2,"Панама №5"                             ,300000},
    {7348 , 2,"Панама №6"                             ,300000},
    {7349 , 2,"Панама №7"                             ,300000},
    {7350 , 2,"Панама №8 (БП)"                        ,300000},
    {18377, 2,"Очки сердечки"                         ,7000000},
    {18386, 2,"Очки глаза"                            ,7000000},
    {18389, 2,"Шапочка с оленьями рожками"            ,300000},
    {18390, 2,"Очки матрица"                          ,6000000},
    {18391, 2,"Очки огонь"                            ,7000000},
    {18392, 2,"Очки огонь прямые"                     ,8000000},
    {18396, 2,"Маска гнома"                           ,2500000},
    {18397, 2,"Маска гринча"                          ,2000000},
    {18399, 2,"Рожки"                                 ,1000000},
    {18400, 2,"Рожки 2"                               ,100000},
    {18401, 2,"Очки салют"                            ,7000000},
    {18402, 2,"Маска котика"                          ,3000000},
    {18403, 2,"Маска тигра"                           ,3000000},
    {18404, 2,"Очки глюки"                            ,7000000},
    {18409, 2,"Очки снежинки"                         ,7000000},
    {7351 , 2,"Кепка"                                 ,300000},
    {7352 , 2,"Кепка 2"                               ,300000},
    {7353 , 2,"Кепка"                                 ,300000},
    {7354 , 2,"Кепка"                                 ,300000},
    {7355 , 2,"Шляпа №1"                              ,400000},
    {7356 , 2,"Шляпа №2"                              ,450000},
    {7357 , 2,"Шляпа №3 (New)"                        ,450000},
    {7358 , 2,"Шляпа №4"                              ,500000},
    {7359 , 2,"Шляпа №5"                              ,500000},
    {7360 , 2,"Шляпа №6"                              ,500000},
    {7362 , 2,"Синяя шапка"                           ,350000},
    {7364 , 1,"Зонт (Разноцветный)"                   ,8000000},
    {7367 , 6,"Кожаный кейс"                          ,5000000},
    {7368 , 6,"Кейс (2)"                              ,10000000},
    {7369 , 6,"Черный кейс"                           ,12000000},
    {7370 , 2,"Маска петуха"                          ,5000000},
    {7371 , 2,"Маска голубя"                          ,5000000},
    {7372 , 2,"Маска зелёная"                         ,3000000},
    {7374 , 2,"Маска медведя"                         ,4000000},
    {7375 , 2,"Маска самурай"                         ,5000000},
    {7376 , 2,"Маска самурай"                         ,5000000},
    {7377 , 1,"Катана"                                ,1000000},
    {7378 , 1,"Катана"                                ,1000000},
    {7379 , 2,"Шляпа самурая №1"                      ,1500000},
    {7380 , 2,"Шляпа самурая №2"                      ,1500000},
    {7381 , 2,"Шляпа самурая №3"                      ,1500000},
    {7382 , 2,"Шляпа индейца"                         ,1500000},
    {7383 , 1,"Доска для серфинга №1"                 ,500000},
    {7384 , 1,"Доска для серфинга №2"                 ,500000},
    {7385 , 1,"Доска для серфинга №3"                 ,500000},
    {7386 , 1,"Доска для серфинга №4"                 ,500000},
    {7387 , 1,"Акула"                                 ,750000},
    {7390 , 1,"Гитара №1"                             ,700000},
    {7391 , 1,"Гитара №2"                             ,700000},
    {7392 , 1,"Гитара №3"                             ,700000},
    {7393 , 1,"Гитара №4"                             ,700000},
    {7394 , 1,"Скейт №1"                              ,750000},
    {7395 , 1,"Скейт №2"                              ,750000},
    {790 ,  1,"Новогодний Дракон"                     ,4000000},
    {787 ,  2,"Маска Дракона"                         ,7000000},
    {9824 , 1,"Весёлая тыква"                         ,5000000},
    {9825 , 1,"Хеллоуинские ночи"                     ,3000000},
    {9827 , 1,"Кукла Вуду"                            ,5000000},
    {9828 , 1,"Призрачный портал"                     ,4000000},
    {11919, 2,"Акула на голову"                       ,6000000},
    {11923, 1,"Рюкзак Мопс на спину"                  ,5000000},
    {14589, 1,"Маска Оленя"                           ,6000000},
    {31949, 6,"Берет 80"                              ,13800000},
    {677  , 1,"Советская"                             ,100000},
    {676  , 2,"Очки"                                  ,13000000},
    {2655 , 1,"Шлем"                                  ,200000},
    {2656 , 1,"Надувной"                              ,11400000},
    {2657 , 2,"Очки"                                  ,6200000},
    {16055, 2,"Лапка"                                 ,700000},
    {9826 , 2,"Маска"                                 ,6600000},
    {11922, 1,"ГеймБой"                               ,7200000},
    {11925, 6,"Летняя доска"                          ,2800000},
    {13801, 6,"Катюша"                                ,4200000},
    {13803, 1,"Рюкзак"                                ,5200000},
    {14591, 2,"Белые рога"                            ,200000},
    {14592, 6,"Уши эльфа"                             ,1300000},
    {14596, 2,"Маска елочки"                          ,800000},
    {14597, 2,"Рождественские рога"                   ,2900000},
    {14598, 2,"Маска Деда Мороза"                     ,600000},
    {14603, 6,"Шапка-Ушанка"                          ,2900000},
    {4160 , 6,"Новогодний кекс"                       ,3100000},
    {4161 , 6,"Новогодний мишка"                      ,1100000},
    {4162 , 2,"Маска Снегурочка"                      ,6500000},
    {4163 , 2,"Маска Снеговика"                       ,200000},
    {4165 , 1,"Сумка Снеговика"                       ,12900000},
    {13883, 2,"Корона демона"                         ,100000},
    {18509, 6,"Кейс"                                  ,100000},
    {18510, 6,"Кейс черный"                           ,800000},
    {18511, 6,"Кейс серый"                            ,600000},
    {18512, 2,"Золотая корона"                        ,12300000},
    {18513, 2,"Корона короля"                         ,300000},
    {18514, 2,"Серебряная корона"                     ,4600000},
    {18515, 6,"Лавровый венец"                        ,800000},
    {18516, 2,"Диадема"                               ,500000},
    {18517, 2,"Очки Доллар"                           ,600000},
    {18518, 2,"Очки День рождения"                    ,300000},
    {18519, 2,"Праздничный колпак"                    ,600000},
    {18520, 2,"Неоновые очки"                         ,11200000},
    {18521, 2,"Неоновые очки"                         ,1500000},
    {18522, 2,"Неоновые очки"                         ,12300000},
    {18523, 2,"Неоновые очки"                         ,12100000},
    {18524, 2,"Неоновые очки"                         ,2200000},
    {18525, 2,"Неоновые очки"                         ,1300000},
    {18526, 2,"Очки пиксели"                          ,4900000},
    {18527, 2,"Шар"                                   ,3300000},
    {18528, 1,"Шар"                                   ,2900000},
    {18529, 1,"Шар"                                   ,8500000},
    {18530, 2,"Шар"                                   ,6200000},
    {18497, 2,"Шарик"                                 ,800000},
    {18498, 2,"Очки 'Выпуклые глаза'"                 ,600000},
    {18499, 2,"Очки 'Обычные глаза'"                  ,100000},
    {18500, 2,"Маска клоуна"                          ,1600000},
    {18501, 2,"Маска клоуна"                          ,3300000},
    {18502, 2,"Лицо тролля"                           ,2400000},
    {18503, 6,"Инопланетянин"                         ,4500000},
    {18504, 2,"Тролль с париком"                      ,14300000},
    {18505, 6,"Инопланетянин с париком"               ,14500000},
    {18506, 2,"Очки с носом"                          ,100000},
    {18507, 1,"Нос клоуна"                            ,10700000},
    {18508, 1,"Парик клоуна"                          ,100000},
    {18233, 1,"Деревянный"                            ,1600000},
    {18232, 6,"Берет"                                 ,900000},
    {18243, 2,"Карамельная конфета"                   ,600000},
    {18250, 1,"Белая панама"                          ,6900000},
    {18383, 6,"Черная панама"                         ,6900000},
    {18384, 6,"Серая панама"                          ,2500000},
    {18385, 2,"Темная панама"                         ,3000000},
    {18263, 6,"Белая панама"                          ,5500000},
    {18264, 6,"Черная панама"                         ,13000000},
    {18273, 2,"Высокая панама"                        ,600000},
    {18279, 2,"Черная шапка"                          ,100000},
    {18285, 6,"Посох-зонт"                            ,1800000},
    {18286, 2,"Кандибобер"                            ,1600000},
    {18346, 6,"Синий посох"                           ,10400000},
    {18347, 6,"Синий посох"                           ,2300000},
    {18348, 6,"Голубой посох"                         ,7100000},
    {18369, 2,"Новогодний топорик"                    ,1300000},
    {18375, 6,"Новогодняя палочка"                    ,2100000},
    {18378, 1,"Рюкзак 'Котик'"                        ,5300000},
    {18379, 1,"Рюкзак 'Санта-Клауса'"                 ,11800000},
    {18410, 2,"Очки"                                  ,1500000},
    {18411, 6,"Голубой посох"                         ,100000},
    {18412, 2,"Очки"                                  ,1000000},
    {18414, 2,"Прямые очки"                           ,4200000},
    {15158, 6,"Кепка"                                 ,2800000},
    {15154, 2,"Неоновая маска"                        ,9900000},
    {15155, 2,"Неоновая маска"                        ,2200000},
    {15157, 1,"Рюкзак"                                ,6500000},
    {15148, 2,"Маска Дали"                            ,900000},
    {15160, 2,"Маска круга"                           ,9300000},
    {15161, 2,"Маска треугольника"                    ,200000},
    {15159, 2,"Маска квадрата"                        ,8400000}
};
#endif

#if !defined _ACCESSORY_SHOP_INVENTORY_MAP
    #define _ACCESSORY_SHOP_INVENTORY_MAP
new const AccessoryShopInventoryMap[][2] =
{
    { 4196, 490 },
    { 4197, 491 },
    { 4198, 492 },
    { 4199, 493 },
    { 4200, 494 },
    { 4201, 495 },
    { 4203, 497 },
    { 4204, 498 },
    { 4205, 499 },
    { 4206, 500 },
    { 4207, 501 },
    { 4208, 502 },
    { 14574, 509 },
    { 14575, 511 },
    { 14593, 517 },
    { 15134, 135 },
    { 15135, 136 },
    { 15136, 137 },
    { 15137, 138 },
    { 15138, 139 },
    { 15139, 140 },
    { 15140, 141 },
    { 15141, 142 },
    { 15142, 143 },
    { 15143, 144 },
    { 15144, 145 },
    { 15145, 146 },
    { 15146, 147 },
    { 15147, 148 },
    { 15149, 150 },
    { 15150, 155 },
    { 15151, 159 },
    { 15152, 151 },
    { 15153, 152 },
    { 7329, 393 },
    { 7330, 394 },
    { 7331, 395 },
    { 7332, 396 },
    { 7333, 397 },
    { 7334, 398 },
    { 7336, 400 },
    { 7337, 401 },
    { 7338, 402 },
    { 7339, 403 },
    { 7341, 405 },
    { 7342, 406 },
    { 7343, 407 },
    { 7344, 408 },
    { 7345, 409 },
    { 7346, 410 },
    { 7347, 411 },
    { 7348, 412 },
    { 7349, 413 },
    { 7350, 414 },
    { 18377, 289 },
    { 18386, 298 },
    { 18389, 301 },
    { 18390, 302 },
    { 18391, 303 },
    { 18392, 304 },
    { 18396, 308 },
    { 18397, 309 },
    { 18399, 311 },
    { 18400, 312 },
    { 18401, 313 },
    { 18402, 314 },
    { 18403, 315 },
    { 18404, 316 },
    { 18409, 321 },
    { 7351, 415 },
    { 7352, 416 },
    { 7353, 417 },
    { 7354, 418 },
    { 7355, 419 },
    { 7356, 420 },
    { 7357, 421 },
    { 7358, 422 },
    { 7359, 423 },
    { 7360, 424 },
    { 7362, 426 },
    { 7364, 428 },
    { 7367, 431 },
    { 7368, 432 },
    { 7369, 433 },
    { 7370, 434 },
    { 7371, 435 },
    { 7372, 436 },
    { 7374, 438 },
    { 7375, 439 },
    { 7376, 440 },
    { 7377, 441 },
    { 7378, 442 },
    { 7379, 443 },
    { 7380, 444 },
    { 7381, 445 },
    { 7382, 446 },
    { 7383, 447 },
    { 7384, 448 },
    { 7385, 449 },
    { 7386, 450 },
    { 7387, 451 },
    { 7390, 454 },
    { 7391, 455 },
    { 7392, 456 },
    { 7393, 457 },
    { 7394, 458 },
    { 7395, 459 },
    { 7397, 461 },
    { 790, 685 },
    { 787, 682 },
    { 9824, 660 },
    { 9825, 661 },
    { 9827, 663 },
    { 9828, 664 },
    { 11919, 579 },
    { 11923, 583 },
    { 14589, 513 },
    { 31949, 983 },
    { 677, 918 },
    { 676, 917 },
    { 2655, 914 },
    { 2656, 915 },
    { 2657, 916 },
    { 16055, 709 },
    { 9826, 662 },
    { 11922, 582 },
    { 11925, 585 },
    { 13801, 576 },
    { 13803, 578 },
    { 14591, 515 },
    { 14592, 516 },
    { 14596, 520 },
    { 14597, 521 },
    { 14598, 522 },
    { 14603, 527 },
    { 4160, 531 },
    { 4161, 532 },
    { 4162, 533 },
    { 4163, 534 },
    { 4165, 536 },
    { 13883, 508 },
    { 18509, 359 },
    { 18510, 360 },
    { 18511, 361 },
    { 18512, 362 },
    { 18513, 363 },
    { 18514, 364 },
    { 18515, 365 },
    { 18516, 366 },
    { 18517, 367 },
    { 18518, 368 },
    { 18519, 369 },
    { 18520, 370 },
    { 18521, 371 },
    { 18522, 372 },
    { 18523, 373 },
    { 18524, 374 },
    { 18525, 375 },
    { 18526, 376 },
    { 18527, 377 },
    { 18528, 378 },
    { 18529, 379 },
    { 18530, 380 },
    { 18497, 347 },
    { 18498, 348 },
    { 18499, 349 },
    { 18500, 350 },
    { 18501, 351 },
    { 18502, 352 },
    { 18503, 353 },
    { 18504, 354 },
    { 18505, 355 },
    { 18506, 356 },
    { 18507, 357 },
    { 18508, 358 },
    { 18233, 170 },
    { 18232, 169 },
    { 18243, 180 },
    { 18250, 187 },
    { 18383, 295 },
    { 18384, 296 },
    { 18385, 297 },
    { 18263, 200 },
    { 18264, 201 },
    { 18273, 210 },
    { 18279, 216 },
    { 18285, 220 },
    { 18286, 221 },
    { 18346, 263 },
    { 18347, 264 },
    { 18348, 265 },
    { 18369, 281 },
    { 18375, 287 },
    { 18378, 290 },
    { 18379, 291 },
    { 18410, 322 },
    { 18411, 323 },
    { 18412, 324 },
    { 18414, 326 },
    { 15158, 161 },
    { 15154, 153 },
    { 15155, 154 },
    { 15157, 160 },
    { 15148, 149 },
    { 15160, 156 },
    { 15161, 157 },
    { 15159, 158 }
};
#endif
#if !defined accessory
    #define accessory accessory_shop_data
#endif

stock ConvertMoneyACS(money, string[], length = sizeof string)
{
    format(string, length, "%d", money < 0 ? -money : money);
    for(new i = strlen(string); (i -= 3) > 0;)
    {
        if(string[i] != '\0' && '0' <= string[i] <= '9')
        {
            strins(string, ".", i, length);
        }
        else
        {
            return;
        }
    }
    if(money < 0)
    {
        strins(string, "-", 0, length);
    }
}


stock bool:AccessoryShop_IsValidIndex(index)
{
    return (0 <= index < sizeof(accessory_shop_data));
}

stock AccessoryShop_GetPriceByIndex(index)
{
    if(!AccessoryShop_IsValidIndex(index))
    {
        return 0;
    }
    return accessory_shop_data[index][PRICE_ACCESSORY];
}

stock AccessoryShop_GetModelByIndex(index)
{
    if(!AccessoryShop_IsValidIndex(index))
    {
        return 0;
    }
    return accessory_shop_data[index][ID_ACCESSORY];
}

stock AccessoryShop_GetInventoryItemByModel(modelid)
{
    for(new i = 0; i < sizeof(AccessoryShopInventoryMap); i++)
    {
        if(AccessoryShopInventoryMap[i][0] == modelid)
        {
            return AccessoryShopInventoryMap[i][1];
        }
    }

    return Inv11_GetAccItemByModel(modelid);
}
stock bool:AccessoryShop_GiveInventoryItem(playerid, index)
{
    if(!AccessoryShop_IsValidIndex(index))
    {
        return false;
    }

    new modelid = AccessoryShop_GetModelByIndex(index);
    new inv_item_id = AccessoryShop_GetInventoryItemByModel(modelid);
    if(inv_item_id <= 0)
    {
        printf("[ACS][SHOP][ERROR] cannot map model to inventory item: player=%d idx=%d model=%d", playerid, index, modelid);
        return false;
    }

    // Canonical accessory row: model_id is the inventory stack model,
    // while extra_1 contains the actual attached-object model.
    new slot = Inventory11_AddItemToDatabase(playerid, inv_item_id, 1, 1, modelid, 0);
    if(slot == -1)
    {
        printf("[ACS][SHOP][ERROR] Inventory11_AddItem failed: player=%d idx=%d model=%d item=%d", playerid, index, modelid, inv_item_id);
        return false;
    }

    new verify_query[224];
    mysql_format(mysql, verify_query, sizeof verify_query,
        "SELECT 1 FROM inventory WHERE account_id=%d AND slot=%d AND item_id=%d AND model_id=1 AND amount=1 AND extra_1=%d LIMIT 1",
        GetPlayerAccountID(playerid), slot, inv_item_id, modelid);
    new Cache:verify_result = mysql_query(mysql, verify_query, true);
    new bool:saved = (!mysql_errno() && cache_num_rows(verify_result) > 0);
    cache_delete(verify_result);
    if(!saved)
    {
        printf("[ACS][SHOP][ERROR] purchase row verification failed: player=%d account=%d slot=%d item=%d model=%d errno=%d",
            playerid, GetPlayerAccountID(playerid), slot, inv_item_id, modelid, mysql_errno());
        Inventory11_DeleteSlotFromDatabase(playerid, slot);
        return false;
    }

    printf("[ACS][SHOP][SAVE] player=%d account=%d slot=%d item=%d model=%d",
        playerid, GetPlayerAccountID(playerid), slot, inv_item_id, modelid);
    return true;
}

stock bool:AccessoryShop_IsOpen(playerid)
{
    return GetPVarInt(playerid, "acs_shop_open") == 1;
}

stock AccessoryShop_DestroyPreview(playerid)
{
    if(pl_id_accessory[playerid] != -1 && IsValidPlayerObject(playerid, pl_id_accessory[playerid]))
    {
        DestroyPlayerObject(playerid, pl_id_accessory[playerid]);
    }

    pl_id_accessory[playerid] = -1;
    return 1;
}

stock AccessoryShop_UpdateText(playerid, acs)
{
    if(!AccessoryShop_IsValidIndex(acs))
    {
        return 0;
    }

    new price_text[32], money_text[20], name_text[72];

    ConvertMoney(AccessoryShop_GetPriceByIndex(acs), money_text);
    format(price_text, sizeof price_text, "%s RUB", money_text);
    format(name_text, sizeof name_text, "%s [%d/%d]",
        accessory_shop_data[acs][NAME_ACCESSORY],
        acs + 1,
        sizeof(accessory_shop_data));

    PlayerTextDrawSetString(playerid, acsmagaz_price_PTD[playerid][0], price_text);
    PlayerTextDrawSetString(playerid, acsmagaz_name_PTD[playerid][0], name_text);
    return 1;
}

stock AccessoryShop_ShowIndex(playerid, acs)
{
    if(!AccessoryShop_IsOpen(playerid) || !AccessoryShop_IsValidIndex(acs))
    {
        return 0;
    }

    new modelid = AccessoryShop_GetModelByIndex(acs);
    if(modelid <= 0)
    {
        printf("[ACS][SHOP][ERROR] invalid preview model: player=%d idx=%d model=%d", playerid, acs, modelid);
        return 0;
    }

    AccessoryShop_DestroyPreview(playerid);

    pl_accessory[playerid] = acs;
    pl_id_accessory[playerid] = CreatePlayerObject(
        playerid,
        modelid,
        2899.104980, 1503.386230, 2499.062500,
        0.0, 0.0, 0.0
    );

    AccessoryShop_UpdateText(playerid, acs);
    return 1;
}

stock AccessoryShop_Close(playerid, bool:restore_position = true)
{
    AccessoryShop_DestroyPreview(playerid);

    for(new i; i < sizeof acsmagaz_button_TD; i++)
        TextDrawHideForPlayer(playerid, acsmagaz_button_TD[i]);

    if(GetPVarInt(playerid, "acs_shop_td_created"))
    {
        PlayerTextDrawHide(playerid, acsmagaz_price_PTD[playerid][0]);
        PlayerTextDrawHide(playerid, acsmagaz_name_PTD[playerid][0]);
    }

    CancelSelectTextDraw(playerid);
    TogglePlayerControllable(playerid, true);
    ShowHud(playerid);
    TogglePlayerHudElement(playerid, HUD_ELEMENT_CHAT, HUD_ELEMENT_SHOW);

    if(restore_position && GetPVarInt(playerid, "acs_market_exit_saved"))
    {
        SetPlayerPosEx(
            playerid,
            GetPVarFloat(playerid, "acs_market_exit_x"),
            GetPVarFloat(playerid, "acs_market_exit_y"),
            GetPVarFloat(playerid, "acs_market_exit_z"),
            GetPVarFloat(playerid, "acs_market_exit_a"),
            GetPVarInt(playerid, "acs_market_exit_int"),
            GetPVarInt(playerid, "acs_market_exit_vw")
        );
    }

    SetCameraBehindPlayer(playerid);
    SetPlayerInBiz(playerid, -1);
    pl_accessory[playerid] = -1;

    DeletePVar(playerid, "acs_shop_open");
    DeletePVar(playerid, "acs_market_exit_saved");
    DeletePVar(playerid, "acs_market_exit_x");
    DeletePVar(playerid, "acs_market_exit_y");
    DeletePVar(playerid, "acs_market_exit_z");
    DeletePVar(playerid, "acs_market_exit_a");
    DeletePVar(playerid, "acs_market_exit_int");
    DeletePVar(playerid, "acs_market_exit_vw");
    return 1;
}

stock CreatePlTDButtonBR(playerid)
{
    // PlayerTextDraws are kept for the whole connection and reused on every shop open.
    // This prevents leaking a new PlayerTextDraw pair on every visit.
    if(GetPVarInt(playerid, "acs_shop_td_created"))
    {
        return 1;
    }

    acsmagaz_name_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 319.7778, 356.5000, "Accessory");
    PlayerTextDrawLetterSize(playerid, acsmagaz_name_PTD[playerid][0], 0.2300, 1.1500);
    PlayerTextDrawTextSize(playerid, acsmagaz_name_PTD[playerid][0], 0.0000, 220.0000);
    PlayerTextDrawAlignment(playerid, acsmagaz_name_PTD[playerid][0], 2);
    PlayerTextDrawColor(playerid, acsmagaz_name_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, acsmagaz_name_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, acsmagaz_name_PTD[playerid][0], 1);
    PlayerTextDrawSetProportional(playerid, acsmagaz_name_PTD[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, acsmagaz_name_PTD[playerid][0], 1);

    acsmagaz_price_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 319.7778, 373.6799, "0 RUB");
    PlayerTextDrawLetterSize(playerid, acsmagaz_price_PTD[playerid][0], 0.2531, 1.3509);
    PlayerTextDrawTextSize(playerid, acsmagaz_price_PTD[playerid][0], 0.0000, -17.0000);
    PlayerTextDrawAlignment(playerid, acsmagaz_price_PTD[playerid][0], 2);
    PlayerTextDrawColor(playerid, acsmagaz_price_PTD[playerid][0], -1);
    PlayerTextDrawBackgroundColor(playerid, acsmagaz_price_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, acsmagaz_price_PTD[playerid][0], 1);
    PlayerTextDrawSetProportional(playerid, acsmagaz_price_PTD[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, acsmagaz_price_PTD[playerid][0], 1);

    SetPVarInt(playerid, "acs_shop_td_created", 1);
    create_player_btn[playerid] = true;
    return 1;
}

stock CreateTextDrawButtonBR()
{
    acsmagaz_button_TD[0] = TextDrawCreate(69.0000, 202.0000, "txd:brrainleft"); // влево
    TextDrawTextSize(acsmagaz_button_TD[0], 27.0000, 43.0000);
    TextDrawAlignment(acsmagaz_button_TD[0], 1);
    TextDrawColor(acsmagaz_button_TD[0], -1);
    TextDrawBackgroundColor(acsmagaz_button_TD[0], 255);
    TextDrawFont(acsmagaz_button_TD[0], 4);
    TextDrawSetProportional(acsmagaz_button_TD[0], 0);
    TextDrawSetShadow(acsmagaz_button_TD[0], 0);
    TextDrawSetSelectable(acsmagaz_button_TD[0], true);

    acsmagaz_button_TD[1] = TextDrawCreate(542.0000, 202.0000, "txd:brrainright"); // вправо
    TextDrawTextSize(acsmagaz_button_TD[1], 27.0000, 43.0000);
    TextDrawAlignment(acsmagaz_button_TD[1], 1);
    TextDrawColor(acsmagaz_button_TD[1], -1);
    TextDrawBackgroundColor(acsmagaz_button_TD[1], 255);
    TextDrawFont(acsmagaz_button_TD[1], 4);
    TextDrawSetProportional(acsmagaz_button_TD[1], 0);
    TextDrawSetShadow(acsmagaz_button_TD[1], 0);
    TextDrawSetSelectable(acsmagaz_button_TD[1], true);

    acsmagaz_button_TD[2] = TextDrawCreate(234.7776, 371.0354, "txd:brtuning4nstage2"); // фон для текста
    TextDrawTextSize(acsmagaz_button_TD[2], 171.0000, 21.0000);
    TextDrawAlignment(acsmagaz_button_TD[2], 1);
    TextDrawColor(acsmagaz_button_TD[2], -12705281);
    TextDrawBackgroundColor(acsmagaz_button_TD[2], 255);
    TextDrawFont(acsmagaz_button_TD[2], 4);
    TextDrawSetProportional(acsmagaz_button_TD[2], 0);
    TextDrawSetShadow(acsmagaz_button_TD[2], 0);

    acsmagaz_button_TD[3] = TextDrawCreate(240.4443, 384.0000, "txd:braucubuy"); // купить
    TextDrawTextSize(acsmagaz_button_TD[3], 78.0000, 58.0000);
    TextDrawAlignment(acsmagaz_button_TD[3], 1);
    TextDrawColor(acsmagaz_button_TD[3], -1);
    TextDrawBackgroundColor(acsmagaz_button_TD[3], 255);
    TextDrawFont(acsmagaz_button_TD[3], 4);
    TextDrawSetProportional(acsmagaz_button_TD[3], 0);
    TextDrawSetShadow(acsmagaz_button_TD[3], 0);
    TextDrawSetSelectable(acsmagaz_button_TD[3], true);

    acsmagaz_button_TD[4] = TextDrawCreate(320.2221, 382.5065, "txd:braucexit"); // выход
    TextDrawTextSize(acsmagaz_button_TD[4], 83.0000, 60.0000);
    TextDrawAlignment(acsmagaz_button_TD[4], 1);
    TextDrawColor(acsmagaz_button_TD[4], -1);
    TextDrawBackgroundColor(acsmagaz_button_TD[4], 255);
    TextDrawFont(acsmagaz_button_TD[4], 4);
    TextDrawSetProportional(acsmagaz_button_TD[4], 0);
    TextDrawSetShadow(acsmagaz_button_TD[4], 0);
    TextDrawSetSelectable(acsmagaz_button_TD[4], true);

    return 1;
}


public OnPlayerSpawn(playerid)
{
    if(AccessoryShop_IsOpen(playerid))
        AccessoryShop_Close(playerid, false);

    LoadAccessory(playerid);
    AccessoryEditSetMovementLock(playerid, false);
    #if defined name_OnPlayerSpawn
        return name_OnPlayerSpawn(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerSpawn
    #undef OnPlayerSpawn
#else
    #define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn name_OnPlayerSpawn
#if defined name_OnPlayerSpawn
    forward name_OnPlayerSpawn(playerid);
#endif


stock AccessoryEditSetMovementLock(playerid, bool:enable)
{
    DeletePVar(playerid, "acs_edit_freeze");
    DeletePVar(playerid, "acs_edit_frz_x");
    DeletePVar(playerid, "acs_edit_frz_y");
    DeletePVar(playerid, "acs_edit_frz_z");

    SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
    TogglePlayerControllable(playerid, true);

    if(enable)
    {
        new Float:angle;
        GetPlayerFacingAngle(playerid, angle);
        SetPVarFloat(playerid, "acs_edit_cam_angle", angle + 180.0);
        AccessoryEditUpdateCamera(playerid);
        printf("[ACS][FREEZE] skipped: player=%d", playerid);
    }
    else
    {
        DeletePVar(playerid, "acs_edit_cam_angle");
        SetCameraBehindPlayer(playerid);
        printf("[ACS][FREEZE] disabled: player=%d", playerid);
    }

    return 1;
}

stock AccessoryEditUpdateCamera(playerid)
{
    new Float:px, Float:py, Float:pz;
    new Float:angle = GetPVarFloat(playerid, "acs_edit_cam_angle");
    GetPlayerPos(playerid, px, py, pz);

    SetPlayerCameraPos(playerid,
        px + (4.0 * floatsin(-angle, degrees)),
        py + (4.0 * floatcos(-angle, degrees)),
        pz + 1.15);
    SetPlayerCameraLookAt(playerid, px, py, pz + 0.65, CAMERA_CUT);
    return 1;
}

public OnPlayerUpdate(playerid)
{
    if(GetPVarInt(playerid, "acs_edit_freeze") == 1)
    {
        new Float:lock_x = GetPVarFloat(playerid, "acs_edit_frz_x");
        new Float:lock_y = GetPVarFloat(playerid, "acs_edit_frz_y");
        new Float:lock_z = GetPVarFloat(playerid, "acs_edit_frz_z");

        new Float:cur_x, Float:cur_y, Float:cur_z;
        GetPlayerPos(playerid, cur_x, cur_y, cur_z);

        if(floatabs(cur_x - lock_x) > 0.35 || floatabs(cur_y - lock_y) > 0.35 || floatabs(cur_z - lock_z) > 0.20)
        {
            SetPlayerPos(playerid, lock_x, lock_y, lock_z);
        }

    }

    #if defined acsedit_OnPlayerUpdate
        return acsedit_OnPlayerUpdate(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerUpdate
    #undef OnPlayerUpdate
#else
    #define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate acsedit_OnPlayerUpdate
#if defined acsedit_OnPlayerUpdate
    forward acsedit_OnPlayerUpdate(playerid);
#endif
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(AccessoryShop_IsOpen(playerid))
    {
        if(clickedid == acsmagaz_button_TD[1]) // next
        {
            new acs = pl_accessory[playerid] + 1;
            if(acs >= sizeof(accessory_shop_data)) acs = 0;
            AccessoryShop_ShowIndex(playerid, acs);
            return 1;
        }

        if(clickedid == acsmagaz_button_TD[0]) // previous
        {
            new acs = pl_accessory[playerid] - 1;
            if(acs < 0) acs = sizeof(accessory_shop_data) - 1;
            AccessoryShop_ShowIndex(playerid, acs);
            return 1;
        }

        if(clickedid == acsmagaz_button_TD[4]) // exit
        {
            return AccessoryShop_Close(playerid, true);
        }

        if(clickedid == acsmagaz_button_TD[3]) // buy
        {
            new acs = pl_accessory[playerid];
            if(!AccessoryShop_IsValidIndex(acs))
            {
                SendClientMessage(playerid, 0xCECECEFF, "Accessory shop: invalid item.");
                return 1;
            }

            new price = AccessoryShop_GetPriceByIndex(acs);
            if(price <= 0)
            {
                printf("[ACS][SHOP][ERROR] invalid price: player=%d idx=%d price=%d", playerid, acs, price);
                return SendClientMessage(playerid, 0xCECECEFF, "Accessory shop: invalid price.");
            }

            if(GetPlayerMoneyEx(playerid) < price)
            {
                return SendClientMessage(playerid, -1, "You do not have enough money.");
            }

            new businessid = GetPlayerInBiz(playerid);
            new take_prods = random(4) + 6;

            if(businessid != -1 && businessid < MAX_BUSINESS &&
               GetBusinessData(businessid, B_TYPE) == BUSINESS_TYPE_ACCESSORY_SHOP &&
               IsBusinessOwned(businessid) &&
               GetBusinessData(businessid, B_PRODS) < take_prods)
            {
                return ShowNotificationNew(playerid, 2, 6, 0, 0, "No products in stock", " ");
            }

            if(!AccessoryShop_GiveInventoryItem(playerid, acs))
            {
                ShowNotificationNew(playerid, 2, 6, 0, 0, "Inventory is full", " ");
                return 1;
            }

            new query[192];
            new biz_price = price * 20 / 100;

            if(businessid != -1 && businessid < MAX_BUSINESS &&
               GetBusinessData(businessid, B_TYPE) == BUSINESS_TYPE_ACCESSORY_SHOP &&
               IsBusinessOwned(businessid))
            {
                format(query, sizeof query,
                    "UPDATE business SET products=%d, balance=%d WHERE id=%d",
                    GetBusinessData(businessid, B_PRODS) - take_prods,
                    GetBusinessData(businessid, B_BALANCE) + biz_price,
                    GetBusinessData(businessid, B_SQL_ID));
                mysql_query(mysql, query, false);

                if(!mysql_errno())
                {
                    AddBusinessData(businessid, B_PRODS, -, take_prods);
                    AddBusinessData(businessid, B_BALANCE, +, biz_price);
                }

                mysql_format(mysql, query, sizeof query,
                    "INSERT INTO business_profit (bid,uid,uip,time,money,view) VALUES (%d,%d,'%e',%d,%d,%d)",
                    GetBusinessData(businessid, B_SQL_ID),
                    GetPlayerAccountID(playerid),
                    GetPlayerIpEx(playerid),
                    gettime(),
                    price,
                    IsBusinessOwned(businessid));
                mysql_query(mysql, query, false);
            }

            GivePlayerMoneyEx(playerid, -price);

            new notify_text[128];
            format(notify_text, sizeof notify_text, "Received {FFFF00}?%s?",
                accessory_shop_data[acs][NAME_ACCESSORY]);
            ShowNotificationNew(playerid, 3, 6, 0, 0, notify_text, "");
            return 1;
        }
    }

	if(clickedid == acss_fix_TD[1])
	{
	    for(new i; i < sizeof acss_fix_TD; i++)
	    {
	    	TextDrawHideForPlayer(playerid, acss_fix_TD[i]);
		}

        TogglePlayerHudElement(playerid, HUD_ELEMENT_CHAT, HUD_ELEMENT_SHOW);

		DeletePVar(playerid, "acs_use");
		DeletePVar(playerid, "acss_fix_TD_use");
		DeletePVar(playerid, "slot");
		DeletePVar(playerid, "acs_id");
        DeletePVar(playerid, "bone");
        DeletePVar(playerid, "inv_acs_db_id");
        DeletePVar(playerid, "edit_modelid");
        DeletePVar(playerid, "khatib_edit_mode");

		DeletePVar(playerid, "edit_y");
		DeletePVar(playerid, "edit_z");
		DeletePVar(playerid, "edit_x");
		DeletePVar(playerid, "edit_rX");
		DeletePVar(playerid, "edit_rY");
		DeletePVar(playerid, "edit_rZ");
		DeletePVar(playerid, "edit_scale");

		AccessoryEdit_DestroyCoordsTextdraw(playerid);
        CancelSelectTextDraw(playerid);
        
		AccessoryEditSetMovementLock(playerid, false);
		TogglePlayerAllHudElements(playerid, HUD_ELEMENT_SHOW);
	}
	if(clickedid == acss_fix_TD[2])
	{
		for(new i; i < sizeof acss_fix_TD; i++)
	    {
	    	TextDrawHideForPlayer(playerid, acss_fix_TD[i]);
		}

        TogglePlayerHudElement(playerid, HUD_ELEMENT_CHAT, HUD_ELEMENT_SHOW);
        if(GetPVarInt(playerid, "khatib_edit_mode") == 1)
        {
            new query_khatib[512];

            mysql_format(mysql, query_khatib, sizeof query_khatib,
                "DELETE FROM accessories WHERE id=%d AND slot=%d",
                GetPlayerAccountID(playerid),
                GetPVarInt(playerid, "slot")
            );
            mysql_query(mysql, query_khatib, false);

            mysql_format(mysql, query_khatib, sizeof query_khatib,
                "INSERT INTO accessories (id, slot, modelid, bone, x, y, z, rX, rY, rZ, scale) VALUES (%d, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f)",
                GetPlayerAccountID(playerid),
                GetPVarInt(playerid, "slot"),
                GetPVarInt(playerid, "edit_modelid"),
                GetPVarInt(playerid, "bone"),
                GetPVarFloat(playerid, "edit_x"),
                GetPVarFloat(playerid, "edit_y"),
                GetPVarFloat(playerid, "edit_z"),
                GetPVarFloat(playerid, "edit_rX"),
                GetPVarFloat(playerid, "edit_rY"),
                GetPVarFloat(playerid, "edit_rZ"),
                GetPVarFloat(playerid, "edit_scale")
            );
            mysql_query(mysql, query_khatib, false);

            DeletePVar(playerid, "acs_use");
            DeletePVar(playerid, "acss_fix_TD_use");
            DeletePVar(playerid, "slot");
            DeletePVar(playerid, "acs_id");
            DeletePVar(playerid, "bone");
            DeletePVar(playerid, "inv_acs_db_id");
            DeletePVar(playerid, "edit_modelid");
            DeletePVar(playerid, "khatib_edit_mode");
            DeletePVar(playerid, "edit_y");
            DeletePVar(playerid, "edit_z");
            DeletePVar(playerid, "edit_x");
            DeletePVar(playerid, "edit_rX");
            DeletePVar(playerid, "edit_rY");
            DeletePVar(playerid, "edit_rZ");
            DeletePVar(playerid, "edit_scale");

            AccessoryEdit_DestroyCoordsTextdraw(playerid);
            CancelSelectTextDraw(playerid);

            AccessoryEditSetMovementLock(playerid, false);
            TogglePlayerAllHudElements(playerid, HUD_ELEMENT_SHOW);
            ShowHud(playerid);
            SendClientMessage(playerid, -1, "Аксессуар успешно сохранен.");
            return 1;
        }

		new query[512], Cache: result, inv_db_id = GetPVarInt(playerid, "inv_acs_db_id");
        printf("[ACS][SAVE][START] player=%d account=%d inv_db_id=%d slot=%d model=%d bone=%d x=%.4f y=%.4f z=%.4f rx=%.2f ry=%.2f rz=%.2f scale=%.4f", playerid, GetPlayerAccountID(playerid), inv_db_id, GetPVarInt(playerid, "slot"), GetPVarInt(playerid, "edit_modelid"), GetPVarInt(playerid, "bone"), GetPVarFloat(playerid, "edit_x"), GetPVarFloat(playerid, "edit_y"), GetPVarFloat(playerid, "edit_z"), GetPVarFloat(playerid, "edit_rX"), GetPVarFloat(playerid, "edit_rY"), GetPVarFloat(playerid, "edit_rZ"), GetPVarFloat(playerid, "edit_scale"));

        if(inv_db_id > 0)
        {
            mysql_format
            (
                mysql, query, sizeof query,
                "UPDATE inventory_accessories SET bone=%d, pos_x=%f, pos_y=%f, pos_z=%f, rot_x=%f, rot_y=%f, rot_z=%f, scale_x=%f, scale_y=%f, scale_z=%f WHERE id=%d AND account_id=%d",
                GetPVarInt(playerid, "bone"),
                GetPVarFloat(playerid, "edit_x"),
                GetPVarFloat(playerid, "edit_y"),
                GetPVarFloat(playerid, "edit_z"),
                GetPVarFloat(playerid, "edit_rX"),
                GetPVarFloat(playerid, "edit_rY"),
                GetPVarFloat(playerid, "edit_rZ"),
                GetPVarFloat(playerid, "edit_scale"),
                GetPVarFloat(playerid, "edit_scale"),
                GetPVarFloat(playerid, "edit_scale"),
                inv_db_id,
                GetPlayerAccountID(playerid)
            );
            mysql_query(mysql, query, false);
            if(mysql_errno())
            {
                printf("[ACS][SAVE][ERROR] inventory_accessories update failed: player=%d account=%d inv_db_id=%d errno=%d query=%s", playerid, GetPlayerAccountID(playerid), inv_db_id, mysql_errno(), query);
            }
            else
            {
                printf("[ACS][SAVE] inventory_accessories updated: player=%d account=%d inv_db_id=%d", playerid, GetPlayerAccountID(playerid), inv_db_id);
            }
            LoadPlayerAccessories(playerid);
        }
        else
        {
            format
            (
                query, sizeof query,
                "UPDATE accessories_players SET acs_id=%d, bone=%d, x=%f, y=%f, z=%f, rX=%f, rY=%f, rZ=%f, scale=%f WHERE player_id=%d AND slot=%d",
                GetPVarInt(playerid, "acs_id"),
                GetPVarInt(playerid, "bone"),
                GetPVarFloat(playerid, "edit_x"),
                GetPVarFloat(playerid, "edit_y"),
                GetPVarFloat(playerid, "edit_z"),
                GetPVarFloat(playerid, "edit_rX"),
                GetPVarFloat(playerid, "edit_rY"),
                GetPVarFloat(playerid, "edit_rZ"),
                GetPVarFloat(playerid, "edit_scale"),
                GetPlayerAccountID(playerid),
                GetPVarInt(playerid, "slot")
            );

            result = mysql_query(mysql, query, true);
            if(mysql_errno())
            {
                printf("[ACS][SAVE][ERROR] accessories_players update failed: player=%d account=%d slot=%d errno=%d query=%s", playerid, GetPlayerAccountID(playerid), GetPVarInt(playerid, "slot"), mysql_errno(), query);
            }
            else
            {
                printf("[ACS][SAVE] accessories_players updated: player=%d account=%d slot=%d", playerid, GetPlayerAccountID(playerid), GetPVarInt(playerid, "slot"));
            }
            cache_delete(result);
        }

        // Sync to accessories_players so accessory keeps exact transform after relog/auth.
        // IMPORTANT: do not write a row if the editor state was reset/zeroed.
        // That exact case created slot=0,bone=0,scale=0 rows and crashed the mobile client on spawn.
        new sync_slot = GetPVarInt(playerid, "slot");
        new sync_bone = GetPVarInt(playerid, "bone");
        new sync_acs_id = GetPVarInt(playerid, "acs_id");
        new sync_modelid = GetPVarInt(playerid, "edit_modelid");
        new Float:sync_scale = GetPVarFloat(playerid, "edit_scale");

        if(sync_acs_id < 0 || sync_acs_id >= sizeof(accessory))
        {
            sync_acs_id = AccessoryGetIndexByModel(sync_modelid);
        }

        if(sync_acs_id >= 0 && sync_acs_id < sizeof(accessory) &&
           sync_slot >= 1 && sync_slot <= 9 &&
           sync_bone >= 1 && sync_bone <= 18 &&
           sync_scale > 0.0 && accessory[sync_acs_id][ID_ACCESSORY] > 0)
        {
            mysql_format(mysql, query, sizeof query, "DELETE FROM accessories_players WHERE player_id=%d AND slot=%d", GetPlayerAccountID(playerid), sync_slot);
            mysql_query(mysql, query, false);
            if(mysql_errno())
            {
                printf("[ACS][SYNC][ERROR] delete accessories_players failed: player=%d account=%d slot=%d errno=%d query=%s", playerid, GetPlayerAccountID(playerid), sync_slot, mysql_errno(), query);
            }

            mysql_format
            (
                mysql, query, sizeof query,
                "INSERT INTO accessories_players (player_id, slot, bone, acs_id, x, y, z, rX, rY, rZ, scale) VALUES (%d, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f)",
                GetPlayerAccountID(playerid),
                sync_slot,
                sync_bone,
                sync_acs_id,
                GetPVarFloat(playerid, "edit_x"),
                GetPVarFloat(playerid, "edit_y"),
                GetPVarFloat(playerid, "edit_z"),
                GetPVarFloat(playerid, "edit_rX"),
                GetPVarFloat(playerid, "edit_rY"),
                GetPVarFloat(playerid, "edit_rZ"),
                sync_scale
            );
            mysql_query(mysql, query, false);
            if(mysql_errno())
            {
                printf("[ACS][SYNC][ERROR] insert accessories_players failed: player=%d account=%d slot=%d acs_id=%d errno=%d query=%s", playerid, GetPlayerAccountID(playerid), sync_slot, sync_acs_id, mysql_errno(), query);
            }
            else
            {
                printf("[ACS][SYNC] accessories_players synced: player=%d account=%d slot=%d acs_id=%d", playerid, GetPlayerAccountID(playerid), sync_slot, sync_acs_id);
            }
        }
        else
        {
            printf("[ACS][SYNC][BLOCKED] invalid editor state player=%d account=%d slot=%d bone=%d acs_id=%d model=%d scale=%.4f",
                playerid, GetPlayerAccountID(playerid), sync_slot, sync_bone, sync_acs_id, sync_modelid, sync_scale);
        }

        AccessorySyncTempDataFromEditor(playerid);

		DeletePVar(playerid, "acs_use");
		DeletePVar(playerid, "acss_fix_TD_use");
		DeletePVar(playerid, "slot");
		DeletePVar(playerid, "acs_id");
        DeletePVar(playerid, "bone");
        DeletePVar(playerid, "inv_acs_db_id");
        DeletePVar(playerid, "edit_modelid");
        DeletePVar(playerid, "khatib_edit_mode");

		DeletePVar(playerid, "edit_y");
		DeletePVar(playerid, "edit_z");
		DeletePVar(playerid, "edit_x");
		DeletePVar(playerid, "edit_rX");
		DeletePVar(playerid, "edit_rY");
		DeletePVar(playerid, "edit_rZ");
		DeletePVar(playerid, "edit_scale");

		AccessoryEdit_DestroyCoordsTextdraw(playerid);
        CancelSelectTextDraw(playerid);

		AccessoryEditSetMovementLock(playerid, false);
		TogglePlayerAllHudElements(playerid, HUD_ELEMENT_SHOW);
		SendClientMessage(playerid, -1, "Аксессуар успешно сохранен.");
		ShowHud(playerid);
	}
    if(clickedid == acss_fix_TD[26] || clickedid == acss_fix_TD[27])
    {
        new Float:angle = GetPVarFloat(playerid, "acs_edit_cam_angle");
        angle += (clickedid == acss_fix_TD[26]) ? -15.0 : 15.0;
        if(angle < 0.0) angle += 360.0;
        if(angle >= 360.0) angle -= 360.0;
        SetPVarFloat(playerid, "acs_edit_cam_angle", angle);
        AccessoryEditUpdateCamera(playerid);
        return 1;
    }
    new TD = -1;
    for(new i = 3; i < 10; i++)
    {
        if(clickedid == acss_fix_TD[i])
        {
            TD = i;
            break;
        }
    }

    if(TD != -1)
    {
        new td_use = GetPVarInt(playerid, "acss_fix_TD_use");
        if(td_use < 1 || td_use > 7) td_use = 1;

        new count_TD = TD - 3;

        TextDrawHideForPlayer(playerid, acss_fix_TD[10 + (td_use - 1)]);
        TextDrawShowForPlayer(playerid, acss_fix_TD[3 + (td_use - 1)]);
        TextDrawHideForPlayer(playerid, acss_fix_TD[17 + (td_use - 1)]);

        TextDrawHideForPlayer(playerid, acss_fix_TD[3 + count_TD]);
        TextDrawShowForPlayer(playerid, acss_fix_TD[10 + count_TD]);
        TextDrawShowForPlayer(playerid, acss_fix_TD[17 + count_TD]);

        SetPVarInt(playerid, "acss_fix_TD_use", count_TD + 1);

        new Float:v;
        switch(count_TD + 1)
        {
            case 1: v = GetPVarFloat(playerid, "edit_y");
            case 2: v = GetPVarFloat(playerid, "edit_z");
            case 3: v = GetPVarFloat(playerid, "edit_x");
            case 4: v = GetPVarFloat(playerid, "edit_scale");
            case 5: v = GetPVarFloat(playerid, "edit_rX");
            case 6: v = GetPVarFloat(playerid, "edit_rY");
            case 7: v = GetPVarFloat(playerid, "edit_rZ");
        }

        new acs_coords[32];
        format(acs_coords, sizeof acs_coords, "%.6f", v);
        PlayerTextDrawSetString(playerid, acss_coords_fix_PTD[playerid][0], acs_coords);
        return 1;
    }

    if(clickedid == acss_fix_TD[24] || clickedid == acss_fix_TD[25])
    {
        new Float:val = (clickedid == acss_fix_TD[24]) ? (1.0) : (-1.0);
        new type = GetPVarInt(playerid, "acss_fix_TD_use");
        new acs_coords[32];

        switch(type)
        {
            case 1:
            {
                SetPVarFloat(playerid, "edit_y", GetPVarFloat(playerid, "edit_y") + (val * 0.005));
                format(acs_coords, sizeof acs_coords, "%.6f", GetPVarFloat(playerid, "edit_y"));
            }
            case 2:
            {
                SetPVarFloat(playerid, "edit_z", GetPVarFloat(playerid, "edit_z") + (val * 0.005));
                format(acs_coords, sizeof acs_coords, "%.6f", GetPVarFloat(playerid, "edit_z"));
            }
            case 3:
            {
                SetPVarFloat(playerid, "edit_x", GetPVarFloat(playerid, "edit_x") + (val * 0.005));
                format(acs_coords, sizeof acs_coords, "%.6f", GetPVarFloat(playerid, "edit_x"));
            }
            case 4:
            {
                SetPVarFloat(playerid, "edit_scale", GetPVarFloat(playerid, "edit_scale") + (val * 0.02));
                format(acs_coords, sizeof acs_coords, "%.6f", GetPVarFloat(playerid, "edit_scale"));
            }
            case 5:
            {
                SetPVarFloat(playerid, "edit_rX", GetPVarFloat(playerid, "edit_rX") + (val * 2.0));
                format(acs_coords, sizeof acs_coords, "%.6f", GetPVarFloat(playerid, "edit_rX"));
            }
            case 6:
            {
                SetPVarFloat(playerid, "edit_rY", GetPVarFloat(playerid, "edit_rY") + (val * 2.0));
                format(acs_coords, sizeof acs_coords, "%.6f", GetPVarFloat(playerid, "edit_rY"));
            }
            case 7:
            {
                SetPVarFloat(playerid, "edit_rZ", GetPVarFloat(playerid, "edit_rZ") + (val * 2.0));
                format(acs_coords, sizeof acs_coords, "%.6f", GetPVarFloat(playerid, "edit_rZ"));
            }
            default:
            {
                return 1;
            }
        }

        PlayerTextDrawSetString(playerid, acss_coords_fix_PTD[playerid][0], acs_coords);

        SetPlayerAttachedObject
        (
            playerid,
            GetPVarInt(playerid, "slot"),
            (GetPVarInt(playerid, "edit_modelid") > 0 ? GetPVarInt(playerid, "edit_modelid") : accessory[GetPVarInt(playerid, "acs_id")][ID_ACCESSORY]),
            GetPVarInt(playerid, "bone"),
            GetPVarFloat(playerid, "edit_x"),
            GetPVarFloat(playerid, "edit_y"),
            GetPVarFloat(playerid, "edit_z"),
            GetPVarFloat(playerid, "edit_rX"),
            GetPVarFloat(playerid, "edit_rY"),
            GetPVarFloat(playerid, "edit_rZ"),
            GetPVarFloat(playerid, "edit_scale"),
            GetPVarFloat(playerid, "edit_scale"),
            GetPVarFloat(playerid, "edit_scale")
        );
        AccessorySyncTempDataFromEditor(playerid);
        return 1;
    }
    #if defined btn_OnPlayerClickTextDraw
        return btn_OnPlayerClickTextDraw(playerid, clickedid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerClickTextDraw
    #undef OnPlayerClickTextDraw
#else
    #define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw btn_OnPlayerClickTextDraw
#if defined btn_OnPlayerClickTextDraw
    forward btn_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif

public OnGameModeInit()
{
    print("[W_SYSTEM] Система аксессуаров загружена.");
    CreateTextDrawButtonBR();
	CreateEditAccessoryTD_AccessorySystem();
	SetTimer("CREATE_TABLIST_ACCESSORY", 4500, false);
    #if defined acs_OnGameModeInit
        return acs_OnGameModeInit();
    #else
        return 1;
    #endif
}
   #if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit acs_OnGameModeInit
#if defined acs_OnGameModeInit
    forward acs_OnGameModeInit();
#endif

stock EntryAccessoryMarket(playerid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerLogged(playerid))
        return 0;

    // Reject a duplicate open request instead of stacking cameras/textdraws/player objects.
    if(AccessoryShop_IsOpen(playerid))
        return 1;

    new Float:exit_x, Float:exit_y, Float:exit_z, Float:exit_a;
    GetPlayerPos(playerid, exit_x, exit_y, exit_z);
    GetPlayerFacingAngle(playerid, exit_a);

    SetPVarFloat(playerid, "acs_market_exit_x", exit_x);
    SetPVarFloat(playerid, "acs_market_exit_y", exit_y);
    SetPVarFloat(playerid, "acs_market_exit_z", exit_z);
    SetPVarFloat(playerid, "acs_market_exit_a", exit_a);
    SetPVarInt(playerid, "acs_market_exit_int", GetPlayerInterior(playerid));
    SetPVarInt(playerid, "acs_market_exit_vw", GetPlayerVirtualWorld(playerid));
    SetPVarInt(playerid, "acs_market_exit_saved", 1);
    SetPVarInt(playerid, "acs_shop_open", 1);

    pl_accessory[playerid] = 0;
    AccessoryShop_DestroyPreview(playerid);

    SetPlayerPosEx(playerid, 2896.610839,1496.067871,2499.343750,355.015014, 1, playerid + 1);
    HideHud(playerid);
    TogglePlayerHudElement(playerid, HUD_ELEMENT_CHAT, HUD_ELEMENT_HIDE);
    TogglePlayerControllable(playerid, false);

    InterpolateCameraPos(playerid,
        2901.951660,1498.124877,2499.343750,
        2900.450927,1500.220703,2499.363750,
        2000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid,
        2903.739257,1499.161499,2499.343750,
        2899.104980,1503.386230,2499.562500,
        2000, CAMERA_MOVE);

    CreatePlTDButtonBR(playerid);
    AccessoryShop_ShowIndex(playerid, 0);

    SelectTextDraw(playerid, 0xFF5252FF);
    for(new i; i < sizeof acsmagaz_button_TD; i++)
        TextDrawShowForPlayer(playerid, acsmagaz_button_TD[i]);

    PlayerTextDrawShow(playerid, acsmagaz_name_PTD[playerid][0]);
    PlayerTextDrawShow(playerid, acsmagaz_price_PTD[playerid][0]);
    return 1;
}

stock SetPriceAccesory(playerid, acs)
{
    return AccessoryShop_UpdateText(playerid, acs);
}


CMD:testacs(playerid, params[])
{
    #pragma unused params

    new query[128], Cache:result;
    new const TEST_ACS_ID = 0; // model 4196 (first item in accessory array)

    mysql_format(mysql, query, sizeof(query), "SELECT id FROM accessory_inventory WHERE player_id=%d AND acs_id=%d LIMIT 1", GetPlayerAccountID(playerid), TEST_ACS_ID);
    result = mysql_query(mysql, query, true);

    if(!cache_num_rows())
    {
        cache_delete(result);
        mysql_format(mysql, query, sizeof(query), "INSERT INTO accessory_inventory (player_id, acs_id) VALUES (%d, %d)", GetPlayerAccountID(playerid), TEST_ACS_ID);
        mysql_query(mysql, query, false);
        SendClientMessage(playerid, 0x66CC66FF, "Test accessory added: 4196 Butterfly Wings.");
    }
    else
    {
        cache_delete(result);
        SendClientMessage(playerid, 0xCECECEFF, "Test accessory already exists in inventory.");
    }

    return AccessoryShowInventory(playerid);
}


CMD:myacs(playerid, params[])
{
    #pragma unused params
    return AccessoryShowInventory(playerid);
}

stock AccessoryShowInventory(playerid)
{
    new fmt_text[4096],
        Cache:result,
        id;

    mysql_format(mysql, fmt_text, sizeof(fmt_text), "SELECT * FROM accessory_inventory WHERE player_id='%d'", GetPlayerAccountID(playerid));
    result = mysql_query(mysql, fmt_text, true);

    new rows = cache_num_rows();

    if(!rows)
    {
        SendClientMessage(playerid, 0x999999FF, "You have no accessories.");
        ShowNotificationNew(playerid, 2, 6, 0, 0, "You have no accessories.", "");
        cache_delete(result);
        return 1;
    }

    new query[160],
        acs, use, acs_use[70], shown;

    format(fmt_text, sizeof(fmt_text), "#\tName\tStatus\n");

    for(new i = 0; i < rows; i++)
    {
        id = cache_get_field_content_int(i, "id");
        acs = cache_get_field_content_int(i, "acs_id");
        use = cache_get_field_content_int(i, "use");

        if(!(0 <= acs < sizeof accessory)) continue;

        if(use > 0)
            format(acs_use, sizeof(acs_use), "{8EF674}[ equipped ]");
        else
            format(acs_use, sizeof(acs_use), "{BEBEBE}[ available ]");

        format(query, sizeof(query), "{CA5757}%d\t{FFD700}%s\t%s\n",
            shown + 1,
            accessory[acs][NAME_ACCESSORY],
            acs_use
        );
        strcat(fmt_text, query);

        SetPlayerListitemValue(playerid, shown, id);

        format(query, sizeof(query), "acsuse%d", shown);
        SetPVarInt(playerid, query, use);
        shown++;
    }

    if(!shown)
    {
        SendClientMessage(playerid, 0xCECECEFF, "Accessory records are invalid (bad IDs).");
        cache_delete(result);
        return 1;
    }

    Dialog(playerid, 1190, DIALOG_STYLE_TABLIST_HEADERS,
        "{CA5757}BEST RUSSIA {FFFFFF}| Select an accessory",
        fmt_text,
        "Select", "Close"
    );

    cache_delete(result);

    return 1;
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
if(dialogid == 1190)
{
    if(response)
    {
        new idx = GetPlayerListitemValue(playerid, listitem), string[24];
        SetPVarInt(playerid, "acs_id_sql", idx);

        format(string, sizeof string, "acsuse%d", listitem);

        if(!GetPVarInt(playerid, string))
        {
            Dialog
            (
                playerid, 1191, DIALOG_STYLE_TABLIST_HEADERS,
                "{CA5757}Управление аксессуаром {FFFFFF}| Выберите действие",
                "№\tДействие\tТип\tСтатус\n"\
                "{CA5757}1\t{FFFFFF}Использовать\t{FFFFFF}Надеть\t{8EF674}Доступно\n"\
                "{CA5757}2\t{FFFFFF}Продать игроку\t{FFFFFF}Обмен\t{8EF674}Доступно\n"\
                "{CA5757}3\t{FFFFFF}Удалить\t{FFFFFF}Выбросить\t{CA5757}Не вернуть",
                "Выбрать", "Закрыть"
            );
            SetPVarInt(playerid, "acs_use", 0);
        }
        else
        {
            Dialog
            (
                playerid, 1191, DIALOG_STYLE_TABLIST_HEADERS,
                "{CA5757}Управление аксессуаром {FFFFFF}| Выберите действие",
                "№\tДействие\tТип\tСтатус\n"\
                "{CA5757}1\t{FFFFFF}Снять\t{FFFFFF}Снятие\t{8EF674}Доступно\n"\
                "{CA5757}1\t{FFFFFF}Редактировать\t{FFFFFF}Настройки\t{FFD700}Изменить",
                "Выбрать", "Закрыть"
            );
            SetPVarInt(playerid, "acs_use", 1);
        }
    }
}
    if(dialogid == 1191)
    {
        if(response)
        {
            new id = GetPVarInt(playerid, "acs_id_sql");
           if(!GetPVarInt(playerid, "acs_use"))
            {
                switch(listitem)
                {
                    case 0:UseAccessory(playerid, id);
                    case 1:SellAccessory(playerid, id);
                    case 2:DeleteAccessory(playerid, id);
                }
            } else{
                switch(listitem)
                {
                    case 0:TakeOffAccessory(playerid, id);
                    case 1:EditAccessory(playerid, id);
                }      
            }
        }
    }
    if(dialogid == 1192)
    {
        if(response)
        {
            new player, price;
            if(sscanf(inputtext, "P<,>dd", player, price)) return SendClientMessage(playerid, -1, "Вы не правильно ввели данные.");

            if(player == playerid || !IsPlayerLogged(player) || !IsPlayerConnected(player))
                return SendClientMessage(playerid, -1, "Данного игрока не существует.");

			if(price >= 1_000_000_000 || price <= -1) return SendClientMessage(playerid, -1, "Цена должна быть меньше 1.000.000.000 руб.");


            SetPVarInt(playerid, "owner_accept_acs_sql", GetPVarInt(playerid, "acs_id_sql"));
            SetPVarInt(playerid, "owner_accept_price", price);
            
            SendPlayerOffer(playerid, player, OFFER_TYPE_ACCESSORY);
        }
    }
    #if defined acs_OnDialogResponse
return acs_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
#endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse acs_OnDialogResponse
#if defined acs_OnDialogResponse
forward acs_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif



stock UseAccessory(playerid, database)
{
    new string[220], Cache:cache;

    mysql_format(mysql, string, sizeof string, "SELECT acs_id FROM accessory_inventory WHERE id = %d AND player_id = %d LIMIT 1", database, GetPlayerAccountID(playerid));
    cache = mysql_query(mysql, string, true);

    if(!cache_num_rows())
    {
        cache_delete(cache);
        SCM(playerid, -1, "Ошибка: аксессуар не найден.");
        return 1;
    }

    new id_acs = cache_get_field_content_int(0, "acs_id");
    cache_delete(cache);

    if(!(0 <= id_acs < sizeof accessory))
    {
        SCM(playerid, -1, "Ошибка: неверный ID аксессуара.");
        return 1;
    }

    new bone = AccessoryResolveBone(id_acs, accessory[id_acs][BONE_ACCESSORY]);
    new modelid = accessory[id_acs][ID_ACCESSORY];
    new slot = 0;
    new slot_state = Inventory11_GetFreeActiveAccessorySlot(playerid, modelid, slot);

    if(slot_state == 2)
    {
        SCM(playerid, -1, "Этот аксессуар уже надет.");
        return 1;
    }

    if(slot_state == 0 || slot < 1 || slot > INVENTORY11_MAX_ACTIVE_ACCESSORIES)
    {
        SCM(playerid, -1, "Можно надеть только 4 аксессуара.");
        return 1;
    }

    new Float:x = 0.01, Float:y = 0.01, Float:z = 0.01;
    new Float:rX = 0.01, Float:rY = 0.01, Float:rZ = 0.01, Float:scale = 1.01;

    if(floatround(gPlayerTempAccData[playerid][slot][0]) == modelid && gPlayerTempAccData[playerid][slot][8] > 0.0)
    {
        x = gPlayerTempAccData[playerid][slot][2];
        y = gPlayerTempAccData[playerid][slot][3];
        z = gPlayerTempAccData[playerid][slot][4];
        rX = gPlayerTempAccData[playerid][slot][5];
        rY = gPlayerTempAccData[playerid][slot][6];
        rZ = gPlayerTempAccData[playerid][slot][7];
        scale = gPlayerTempAccData[playerid][slot][8];
    }
    mysql_format(mysql, string, sizeof string, "SELECT acs_id FROM accessories_players WHERE player_id = %d AND slot = %d LIMIT 1", GetPlayerAccountID(playerid), slot);
    cache = mysql_query(mysql, string, true);

    if(cache_num_rows())
    {
        new old_acs_id = cache_get_field_content_int(0, "acs_id");
        cache_delete(cache);

        mysql_format(mysql, string, sizeof string, "DELETE FROM accessories_players WHERE player_id = %d AND slot = %d", GetPlayerAccountID(playerid), slot);
        mysql_query(mysql, string, false);

        mysql_format(mysql, string, sizeof string, "UPDATE accessory_inventory SET `use` = 0 WHERE player_id = %d AND acs_id = %d", GetPlayerAccountID(playerid), old_acs_id);
        mysql_query(mysql, string, false);

        if(IsPlayerAttachedObjectSlotUsed(playerid, slot))
        {
            RemovePlayerAttachedObject(playerid, slot);
        }
    }
    else
    {
        cache_delete(cache);
    }

    mysql_format(mysql, string, sizeof string, "INSERT INTO accessories_players (player_id,slot,bone,acs_id,x,y,z,rX,rY,rZ,scale) VALUES (%d,%d,%d,%d,%f,%f,%f,%f,%f,%f,%f)", GetPlayerAccountID(playerid), slot, bone, id_acs, x, y, z, rX, rY, rZ, scale);
    mysql_query(mysql, string, false);

    mysql_format(mysql, string, sizeof string, "UPDATE accessory_inventory SET `use` = 0 WHERE player_id = %d", GetPlayerAccountID(playerid));
    mysql_query(mysql, string, false);

    mysql_format(mysql, string, sizeof string, "UPDATE accessory_inventory SET `use` = 1 WHERE `id` = %d", database);
    mysql_query(mysql, string, false);

    SetPlayerAttachedObject(playerid, slot, modelid, bone, x, y, z, rX, rY, rZ, scale, scale, scale);
    gPlayerTempAccData[playerid][slot][0] = float(modelid);
    gPlayerTempAccData[playerid][slot][1] = float(bone);
    gPlayerTempAccData[playerid][slot][2] = x;
    gPlayerTempAccData[playerid][slot][3] = y;
    gPlayerTempAccData[playerid][slot][4] = z;
    gPlayerTempAccData[playerid][slot][5] = rX;
    gPlayerTempAccData[playerid][slot][6] = rY;
    gPlayerTempAccData[playerid][slot][7] = rZ;
    gPlayerTempAccData[playerid][slot][8] = scale;
    gPlayerTempAccData[playerid][slot][9] = scale;
    gPlayerTempAccData[playerid][slot][10] = scale;
    SCM(playerid, -1, "Вы успешно надели аксессуар");
    return 1;
}

stock TakeOffAccessory(playerid, database)
{
    new slot = -1, string[184];
	mysql_format(mysql, string, sizeof string, "SELECT * FROM accessory_inventory WHERE id = %d",database);
	new Cache:cache = mysql_query(mysql, string, true);

	new acs_id = cache_get_field_content_int(0, "acs_id");

	cache_delete(cache);
    if(!mysql_errno())
    {
        mysql_format(mysql, string, sizeof string, "SELECT slot,bone,x,y,z,rX,rY,rZ,scale FROM accessories_players WHERE player_id = %d AND acs_id = %d", GetPlayerAccountID(playerid), acs_id);
        cache = mysql_query(mysql, string, true);

        if(cache_num_rows())
        {
            slot = cache_get_field_content_int(0, "slot");

            if(acs_id >= 0 && acs_id < sizeof(accessory))
            {
                AccessorySyncTempData
                (
                    playerid,
                    slot,
                    accessory[acs_id][ID_ACCESSORY],
                    cache_get_field_content_int(0, "bone"),
                    cache_get_field_content_float(0, "x"),
                    cache_get_field_content_float(0, "y"),
                    cache_get_field_content_float(0, "z"),
                    cache_get_field_content_float(0, "rX"),
                    cache_get_field_content_float(0, "rY"),
                    cache_get_field_content_float(0, "rZ"),
                    cache_get_field_content_float(0, "scale")
                );
            }
        }

        cache_delete(cache);

        mysql_format(mysql, string, sizeof string, "DELETE FROM accessories_players WHERE player_id = %d AND acs_id = %d", GetPlayerAccountID(playerid), acs_id);
        mysql_query(mysql, string, false);

		mysql_format(mysql, string, sizeof string, "UPDATE accessory_inventory SET `use` = 0 WHERE `id`=%d", database);
    	mysql_query(mysql, string, false);


        if(slot != -1)
        {           
            RemovePlayerAttachedObject(playerid, slot);
            ShowNotificationNew(playerid, 3, 6, 0, 0, "Аксессуар снят", "");
        }
    }

    return 1;
}

stock SellAccessory(playerid, database)
{
    new string[124], Cache:cache;

    mysql_format(mysql,string, sizeof string, "SELECT acs_id FROM accessory_inventory WHERE id = %d", database);
    cache = mysql_query(mysql, string);

    SetPVarInt(playerid, "acs_id", cache_get_row_int(0, 0));

    cache_delete(cache);

    Dialog(
        playerid, 1192, DIALOG_STYLE_INPUT, 
        "{FF0000}Введите данные",
        "Напишите ID-игрока и цену за аксессуар\n"\
        "Пример: 0, 100000 (id, цена)\n"\
        "\nЕсли вы хотите передать — пишите цену «0»",
        "Далее", "Выйти"
    );
    
    return 1;
}

stock DeleteAccessory(playerid, database)
{
    new string[124], Cache:cache;

    mysql_format(mysql,string, sizeof string, "DELETE FROM accessory_inventory WHERE id = %d", database);
    mysql_query(mysql, string, false);

    if(!mysql_errno()) SendClientMessage(playerid, -1, "Аксессуар удалён.");
    else SendClientMessage(playerid, -1, "Ошибка в удалении аксессуара");

    return 1;
}

stock EditAccessory(playerid, database)
{
    new query[220], rows, Cache: result;

    for(new a;a < 12;a++)  SendClientMessage(playerid, 0xFFFFFFFF, "");
    TogglePlayerHudElement(playerid, HUD_ELEMENT_CHAT, HUD_ELEMENT_HIDE);

    new acs_id;
    if(database < 0)
    {
        new physical_slot = -database;
        format(query, sizeof query, "SELECT * FROM accessories_players WHERE player_id=%d AND slot=%d LIMIT 1", GetPlayerAccountID(playerid), physical_slot);
        result = mysql_query(mysql, query, true);
        if(!cache_num_rows()) { cache_delete(result); return 0; }
        acs_id = cache_get_field_content_int(0, "acs_id");
    }
    else
    {
        format(query, sizeof query, "SELECT acs_id FROM accessory_inventory WHERE id=%d", database);
        result = mysql_query(mysql, query, true);
        if(!cache_num_rows()) { cache_delete(result); return 0; }
        acs_id = cache_get_row_int(0, 0);
        cache_delete(result);
        format(query, sizeof query, "SELECT * FROM accessories_players WHERE player_id=%d AND acs_id=%d", GetPlayerAccountID(playerid), acs_id);
        result = mysql_query(mysql, query, true);
    }

	rows = cache_num_rows();

	if(rows)
	{
		new 
		bone = cache_get_field_content_int(0, "bone"),
		slot = cache_get_field_content_int(0, "slot"),
		Float: x =  cache_get_field_content_float(0, "x"),
		Float: y =  cache_get_field_content_float(0, "y"),
		Float: z =  cache_get_field_content_float(0, "z"),
		Float: rX = cache_get_field_content_float(0, "rX"),
		Float: rY = cache_get_field_content_float(0, "rY"),
		Float: rZ = cache_get_field_content_float(0, "rZ"),
		Float: scale =  cache_get_field_content_float(0, "scale");

       	SetPVarInt(playerid, "slot", slot);
		SetPVarInt(playerid, "acs_id", acs_id);
        DeletePVar(playerid, "inv_acs_db_id");
        SetPVarInt(playerid, "edit_modelid", accessory[acs_id][ID_ACCESSORY]);
		SetPVarInt(playerid, "bone", bone);
		SetPVarFloat(playerid, "edit_y", y);
		SetPVarFloat(playerid, "edit_z", z);
		SetPVarFloat(playerid, "edit_x", x);
		SetPVarFloat(playerid, "edit_rX", rX);
		SetPVarFloat(playerid, "edit_rY", rY);
		SetPVarFloat(playerid, "edit_rZ", rZ);
		SetPVarFloat(playerid, "edit_scale", scale);

		RemovePlayerAttachedObject(playerid, slot);

		SetPlayerAttachedObject
		(
			playerid,
			GetPVarInt(playerid, "slot"),
			(GetPVarInt(playerid, "edit_modelid") > 0 ? GetPVarInt(playerid, "edit_modelid") : accessory[GetPVarInt(playerid, "acs_id")][ID_ACCESSORY]),
			GetPVarInt(playerid, "bone"),
			GetPVarFloat(playerid, "edit_x"),
			GetPVarFloat(playerid, "edit_y"),
   			GetPVarFloat(playerid, "edit_z"),
      		GetPVarFloat(playerid, "edit_rX"),
			GetPVarFloat(playerid, "edit_rY"),
			GetPVarFloat(playerid, "edit_rZ"),
			GetPVarFloat(playerid, "edit_scale"),
			GetPVarFloat(playerid, "edit_scale"),
			GetPVarFloat(playerid, "edit_scale")
		);

		HideHud(playerid);
		SelectTextDraw(playerid, 0xFF5252FF);

		for(new i; i < 11; i ++) TextDrawShowForPlayer(playerid, acss_fix_TD[i]);
		TextDrawShowForPlayer(playerid, acss_fix_TD[17]);
		TextDrawShowForPlayer(playerid, acss_fix_TD[24]);
		TextDrawShowForPlayer(playerid, acss_fix_TD[25]);
		TextDrawShowForPlayer(playerid, acss_fix_TD[26]);
		TextDrawShowForPlayer(playerid, acss_fix_TD[27]);

		new acs_coords[18];
		format(acs_coords, sizeof acs_coords, "%f", GetPVarFloat(playerid, "edit_x"));

		AccessoryEdit_DestroyCoordsTextdraw(playerid);
    acss_coords_fix_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 521.3996, 292.8998, acs_coords);
		PlayerTextDrawLetterSize(playerid, acss_coords_fix_PTD[playerid][0], 0.3000, 1.6000);
		PlayerTextDrawAlignment(playerid, acss_coords_fix_PTD[playerid][0], 2);
		PlayerTextDrawColor(playerid, acss_coords_fix_PTD[playerid][0], 0xFFFFFFFF);
		PlayerTextDrawBackgroundColor(playerid, acss_coords_fix_PTD[playerid][0], 255);
		PlayerTextDrawFont(playerid, acss_coords_fix_PTD[playerid][0], 1);
		PlayerTextDrawSetProportional(playerid, acss_coords_fix_PTD[playerid][0], 1);
		PlayerTextDrawSetShadow(playerid, acss_coords_fix_PTD[playerid][0], 0);

		PlayerTextDrawShow(playerid, acss_coords_fix_PTD[playerid][0]);
    SetPVarInt(playerid, "acss_coords_td_created", 1);

		SetPVarInt(playerid, "acss_fix_TD_use", 1);
		// TogglePlayerControllable(playerid, false); фу не удобно ыелси жепете кодер
		TogglePlayerAllHudElements(playerid, HUD_ELEMENT_HIDE);
    AccessoryEditSetMovementLock(playerid, true);
        //SetPlayerFrozen(playerid, true);
	}

	cache_delete(result);
}


stock AccessoryGetIndexByModel(modelid)
{
    for(new i; i < sizeof accessory; i++)
    {
        if(accessory[i][ID_ACCESSORY] == modelid)
        {
            return i;
        }
    }
    return -1;
}

stock bool:AccessoryUseAndEditByModel(playerid, modelid)
{
    printf("[ACS][USE] start: player=%d account=%d model=%d", playerid, GetPlayerAccountID(playerid), modelid);
    new acs_id = AccessoryGetIndexByModel(modelid);
    if(acs_id < 0)
    {
        SendClientMessage(playerid, -1, "{FF0000}Ошибка: модель аксессуара не найдена.");
        return false;
    }

    new bone = AccessoryResolveBone(acs_id, accessory[acs_id][BONE_ACCESSORY]), slot = -1;
    switch(bone)
    {
        case 1:  slot = 1;
        case 2:  slot = 2;
        case 3:  slot = 3;
        case 4:  slot = 4;
        case 5:  slot = 5;
        case 6:  slot = 6;
        case 7:  slot = 6;
        case 8:  slot = 7;
        case 9:  slot = 7;
        case 10: slot = 8;
        case 11: slot = 8;
        case 12: slot = 9;
        case 13: slot = 9;
    }

    if(slot == -1)
    {
        SendClientMessage(playerid, -1, "{FF0000}Ошибка: не удалось определить слот аксессуара.");
        return false;
    }

    new Float:x = 0.01, Float:y = 0.01, Float:z = 0.01;
    new Float:rX = 0.01, Float:rY = 0.01, Float:rZ = 0.01, Float:scale = 1.01;

    if(floatround(gPlayerTempAccData[playerid][slot][0]) == modelid && gPlayerTempAccData[playerid][slot][8] > 0.0)
    {
        x = gPlayerTempAccData[playerid][slot][2];
        y = gPlayerTempAccData[playerid][slot][3];
        z = gPlayerTempAccData[playerid][slot][4];
        rX = gPlayerTempAccData[playerid][slot][5];
        rY = gPlayerTempAccData[playerid][slot][6];
        rZ = gPlayerTempAccData[playerid][slot][7];
        scale = gPlayerTempAccData[playerid][slot][8];
    }

    new query[320];
    mysql_format(mysql, query, sizeof query, "DELETE FROM accessories_players WHERE player_id = %d AND slot = %d", GetPlayerAccountID(playerid), slot);
    mysql_query(mysql, query, false);
    if(mysql_errno())
    {
        printf("[ACS][USE][ERROR] delete old slot failed: player=%d account=%d slot=%d errno=%d query=%s", playerid, GetPlayerAccountID(playerid), slot, mysql_errno(), query);
    }

    mysql_format(mysql, query, sizeof query,
        "INSERT INTO accessories_players (player_id, slot, bone, acs_id, x, y, z, rX, rY, rZ, scale) VALUES (%d, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f)",
        GetPlayerAccountID(playerid), slot, bone, acs_id, x, y, z, rX, rY, rZ, scale);
    mysql_query(mysql, query, false);
    if(mysql_errno())
    {
        printf("[ACS][USE][ERROR] insert slot failed: player=%d account=%d slot=%d acs_id=%d errno=%d query=%s", playerid, GetPlayerAccountID(playerid), slot, acs_id, mysql_errno(), query);
    }
    else
    {
        printf("[ACS][USE] saved: player=%d account=%d slot=%d acs_id=%d model=%d bone=%d x=%.4f y=%.4f z=%.4f rx=%.2f ry=%.2f rz=%.2f scale=%.4f", playerid, GetPlayerAccountID(playerid), slot, acs_id, modelid, bone, x, y, z, rX, rY, rZ, scale);
    }

    if(IsPlayerAttachedObjectSlotUsed(playerid, slot)) RemovePlayerAttachedObject(playerid, slot);

    SetPlayerAttachedObject(playerid, slot, modelid, bone, x, y, z, rX, rY, rZ, scale, scale, scale);

    gPlayerTempAccData[playerid][slot][0] = float(modelid);
    gPlayerTempAccData[playerid][slot][1] = float(bone);
    gPlayerTempAccData[playerid][slot][2] = x;
    gPlayerTempAccData[playerid][slot][3] = y;
    gPlayerTempAccData[playerid][slot][4] = z;
    gPlayerTempAccData[playerid][slot][5] = rX;
    gPlayerTempAccData[playerid][slot][6] = rY;
    gPlayerTempAccData[playerid][slot][7] = rZ;
    gPlayerTempAccData[playerid][slot][8] = scale;
    gPlayerTempAccData[playerid][slot][9] = scale;
    gPlayerTempAccData[playerid][slot][10] = scale;

    for(new a; a < 12; a++) SendClientMessage(playerid, 0xFFFFFFFF, "");
    TogglePlayerHudElement(playerid, HUD_ELEMENT_CHAT, HUD_ELEMENT_HIDE);

    SetPVarInt(playerid, "slot", slot);
    SetPVarInt(playerid, "acs_id", acs_id);
    SetPVarInt(playerid, "bone", bone);
    DeletePVar(playerid, "inv_acs_db_id");
    SetPVarInt(playerid, "edit_modelid", modelid);

    SetPVarFloat(playerid, "edit_x", x);
    SetPVarFloat(playerid, "edit_y", y);
    SetPVarFloat(playerid, "edit_z", z);
    SetPVarFloat(playerid, "edit_rX", rX);
    SetPVarFloat(playerid, "edit_rY", rY);
    SetPVarFloat(playerid, "edit_rZ", rZ);
    SetPVarFloat(playerid, "edit_scale", scale);

    HideHud(playerid);
    SelectTextDraw(playerid, 0xFF5252FF);

    for(new i; i < 11; i++) TextDrawShowForPlayer(playerid, acss_fix_TD[i]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[17]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[24]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[25]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[26]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[27]);

    new acs_coords[18];
    format(acs_coords, sizeof acs_coords, "%f", GetPVarFloat(playerid, "edit_x"));

    AccessoryEdit_DestroyCoordsTextdraw(playerid);
    acss_coords_fix_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 521.3996, 292.8998, acs_coords);
    PlayerTextDrawLetterSize(playerid, acss_coords_fix_PTD[playerid][0], 0.3000, 1.6000);
    PlayerTextDrawAlignment(playerid, acss_coords_fix_PTD[playerid][0], 2);
    PlayerTextDrawColor(playerid, acss_coords_fix_PTD[playerid][0], 0xFFFFFFFF);
    PlayerTextDrawBackgroundColor(playerid, acss_coords_fix_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, acss_coords_fix_PTD[playerid][0], 1);
    PlayerTextDrawSetProportional(playerid, acss_coords_fix_PTD[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, acss_coords_fix_PTD[playerid][0], 0);
    PlayerTextDrawShow(playerid, acss_coords_fix_PTD[playerid][0]);
    SetPVarInt(playerid, "acss_coords_td_created", 1);

    SetPVarInt(playerid, "acss_fix_TD_use", 1);
    TogglePlayerAllHudElements(playerid, HUD_ELEMENT_HIDE);
    AccessoryEditSetMovementLock(playerid, true);

    return true;
}

stock bool:AccessoryStartKhatibEdit(playerid, modelid)
{
    if(modelid <= 0)
    {
        return false;
    }

    new slot = -1;
    for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
    {
        if(!IsPlayerAttachedObjectSlotUsed(playerid, i))
        {
            slot = i;
            break;
        }
    }

    if(slot == -1)
    {
        SendClientMessage(playerid, 0xCECECEFF, "{ffff00}|{ffffff} Все слоты аксессуаров заняты");
        return false;
    }

    new bone = A_OBJECT_BONE_SPINE;
    new Float:x = 0.0, Float:y = 0.30, Float:z = 0.0;
    new Float:rX = 0.0, Float:rY = 0.0, Float:rZ = 0.0, Float:scale = 1.0;
    new acs_id = AccessoryGetIndexByModel(modelid);

    SetPlayerAttachedObject(playerid, slot, modelid, bone, x, y, z, rX, rY, rZ, scale, scale, scale);

    for(new a; a < 12; a++) SendClientMessage(playerid, 0xFFFFFFFF, "");
    TogglePlayerHudElement(playerid, HUD_ELEMENT_CHAT, HUD_ELEMENT_HIDE);

    SetPVarInt(playerid, "slot", slot);
    SetPVarInt(playerid, "acs_id", acs_id >= 0 ? acs_id : 0);
    SetPVarInt(playerid, "bone", bone);
    SetPVarInt(playerid, "khatib_edit_mode", 1);
    DeletePVar(playerid, "inv_acs_db_id");
    SetPVarInt(playerid, "edit_modelid", modelid);

    SetPVarFloat(playerid, "edit_x", x);
    SetPVarFloat(playerid, "edit_y", y);
    SetPVarFloat(playerid, "edit_z", z);
    SetPVarFloat(playerid, "edit_rX", rX);
    SetPVarFloat(playerid, "edit_rY", rY);
    SetPVarFloat(playerid, "edit_rZ", rZ);
    SetPVarFloat(playerid, "edit_scale", scale);

    HideHud(playerid);
    SelectTextDraw(playerid, 0xFF5252FF);

    for(new i; i < 11; i++) TextDrawShowForPlayer(playerid, acss_fix_TD[i]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[17]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[24]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[25]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[26]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[27]);

    new acs_coords[18];
    format(acs_coords, sizeof acs_coords, "%f", GetPVarFloat(playerid, "edit_x"));

    AccessoryEdit_DestroyCoordsTextdraw(playerid);
    acss_coords_fix_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 521.3996, 292.8998, acs_coords);
    PlayerTextDrawLetterSize(playerid, acss_coords_fix_PTD[playerid][0], 0.3000, 1.6000);
    PlayerTextDrawAlignment(playerid, acss_coords_fix_PTD[playerid][0], 2);
    PlayerTextDrawColor(playerid, acss_coords_fix_PTD[playerid][0], 0xFFFFFFFF);
    PlayerTextDrawBackgroundColor(playerid, acss_coords_fix_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, acss_coords_fix_PTD[playerid][0], 1);
    PlayerTextDrawSetProportional(playerid, acss_coords_fix_PTD[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, acss_coords_fix_PTD[playerid][0], 0);
    PlayerTextDrawShow(playerid, acss_coords_fix_PTD[playerid][0]);
    SetPVarInt(playerid, "acss_coords_td_created", 1);

    SetPVarInt(playerid, "acss_fix_TD_use", 1);
    TogglePlayerAllHudElements(playerid, HUD_ELEMENT_HIDE);
    AccessoryEditSetMovementLock(playerid, true);
    return true;
}
stock AccessoryEditFromInventory(playerid, database)
{
    new query[320], Cache:result;

    mysql_format(mysql, query, sizeof query,
        "SELECT id, modelid, bone, pos_x, pos_y, pos_z, rot_x, rot_y, rot_z, scale_x, slot, in_use FROM inventory_accessories WHERE id=%d AND account_id=%d LIMIT 1",
        database, GetPlayerAccountID(playerid));
    result = mysql_query(mysql, query, true);

    if(!cache_num_rows())
    {
        cache_delete(result);
        SendClientMessage(playerid, -1, "{FF0000}Ошибка: аксессуар не найден в инвентаре.");
        return 1;
    }

    new modelid = cache_get_field_content_int(0, "modelid");
    new bone = cache_get_field_content_int(0, "bone");
    new slot = cache_get_field_content_int(0, "slot");
    new in_use = cache_get_field_content_int(0, "in_use");
    new Float:x = cache_get_field_content_float(0, "pos_x");
    new Float:y = cache_get_field_content_float(0, "pos_y");
    new Float:z = cache_get_field_content_float(0, "pos_z");
    new Float:rX = cache_get_field_content_float(0, "rot_x");
    new Float:rY = cache_get_field_content_float(0, "rot_y");
    new Float:rZ = cache_get_field_content_float(0, "rot_z");
    new Float:scale = cache_get_field_content_float(0, "scale_x");
    printf("[ACS][EDIT] load from inventory_accessories: player=%d account=%d db_id=%d model=%d bone=%d slot=%d in_use=%d x=%.4f y=%.4f z=%.4f rx=%.2f ry=%.2f rz=%.2f scale=%.4f", playerid, GetPlayerAccountID(playerid), database, modelid, bone, slot, in_use, x, y, z, rX, rY, rZ, scale);
    cache_delete(result);

    if(!in_use)
    {
        SendClientMessage(playerid, -1, "{FF0000}Сначала наденьте аксессуар.");
        return 1;
    }

    if(!(0 <= slot < MAX_PLAYER_ATTACHED_OBJECTS))
    {
        for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
        {
            if(IsPlayerAttachedObjectSlotUsed(playerid, i) && floatround(gPlayerTempAccData[playerid][i][0]) == modelid)
            {
                slot = i;
                break;
            }
        }
    }

    if(!(0 <= slot < MAX_PLAYER_ATTACHED_OBJECTS))
    {
        SendClientMessage(playerid, -1, "{FF0000}Ошибка: не найден слот аксессуара для редактирования.");
        return 1;
    }

    for(new a; a < 12; a++) SendClientMessage(playerid, 0xFFFFFFFF, "");
    TogglePlayerHudElement(playerid, HUD_ELEMENT_CHAT, HUD_ELEMENT_HIDE);

    SetPVarInt(playerid, "slot", slot);
    SetPVarInt(playerid, "bone", bone);
    SetPVarInt(playerid, "inv_acs_db_id", database);
    SetPVarInt(playerid, "edit_modelid", modelid);

    new acs_id = AccessoryGetIndexByModel(modelid);
    if(acs_id >= 0)
    {
        SetPVarInt(playerid, "acs_id", acs_id);
        bone = AccessoryResolveBone(acs_id, bone);
        SetPVarInt(playerid, "bone", bone);
    }
    else SetPVarInt(playerid, "acs_id", 0);

    SetPVarFloat(playerid, "edit_y", y);
    SetPVarFloat(playerid, "edit_z", z);
    SetPVarFloat(playerid, "edit_x", x);
    SetPVarFloat(playerid, "edit_rX", rX);
    SetPVarFloat(playerid, "edit_rY", rY);
    SetPVarFloat(playerid, "edit_rZ", rZ);
    SetPVarFloat(playerid, "edit_scale", scale);

    if(IsPlayerAttachedObjectSlotUsed(playerid, slot)) RemovePlayerAttachedObject(playerid, slot);

    SetPlayerAttachedObject(playerid, slot, modelid, bone,
        GetPVarFloat(playerid, "edit_x"),
        GetPVarFloat(playerid, "edit_y"),
        GetPVarFloat(playerid, "edit_z"),
        GetPVarFloat(playerid, "edit_rX"),
        GetPVarFloat(playerid, "edit_rY"),
        GetPVarFloat(playerid, "edit_rZ"),
        GetPVarFloat(playerid, "edit_scale"),
        GetPVarFloat(playerid, "edit_scale"),
        GetPVarFloat(playerid, "edit_scale")
    );

    HideHud(playerid);
    SelectTextDraw(playerid, 0xFF5252FF);

    for(new i; i < 11; i++) TextDrawShowForPlayer(playerid, acss_fix_TD[i]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[17]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[24]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[25]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[26]);
    TextDrawShowForPlayer(playerid, acss_fix_TD[27]);

    new acs_coords[18];
    format(acs_coords, sizeof acs_coords, "%f", GetPVarFloat(playerid, "edit_x"));

    AccessoryEdit_DestroyCoordsTextdraw(playerid);
    acss_coords_fix_PTD[playerid][0] = CreatePlayerTextDraw(playerid, 521.3996, 292.8998, acs_coords);
    PlayerTextDrawLetterSize(playerid, acss_coords_fix_PTD[playerid][0], 0.3000, 1.6000);
    PlayerTextDrawAlignment(playerid, acss_coords_fix_PTD[playerid][0], 2);
    PlayerTextDrawColor(playerid, acss_coords_fix_PTD[playerid][0], 0xFFFFFFFF);
    PlayerTextDrawBackgroundColor(playerid, acss_coords_fix_PTD[playerid][0], 255);
    PlayerTextDrawFont(playerid, acss_coords_fix_PTD[playerid][0], 1);
    PlayerTextDrawSetProportional(playerid, acss_coords_fix_PTD[playerid][0], 1);
    PlayerTextDrawSetShadow(playerid, acss_coords_fix_PTD[playerid][0], 0);
    PlayerTextDrawShow(playerid, acss_coords_fix_PTD[playerid][0]);
    SetPVarInt(playerid, "acss_coords_td_created", 1);

    SetPVarInt(playerid, "acss_fix_TD_use", 1);
    TogglePlayerAllHudElements(playerid, HUD_ELEMENT_HIDE);
    AccessoryEditSetMovementLock(playerid, true);

    return 1;
}
stock GiveAccessory(playerid, acs)
{
    new string[178];

    mysql_format(mysql, string, sizeof string, "INSERT INTO accessory_inventory (player_id, acs_id) VALUES (%d, %d)", GetPlayerAccountID(playerid), acs);
    mysql_query(mysql, string, false);
    
    if(!mysql_errno())
    {
        format(string, sizeof string, "Получен {FFFF00}«%s»", accessory[acs][NAME_ACCESSORY]);
        ShowNotificationNew(playerid, 3, 6, 0, 0, string, "");
    }
    return 1;
}

public:LoadAccessory(playerid)
{
    new account_id = GetPlayerAccountID(playerid);
    if(account_id <= 0) return 0;

    new query[320], rows, Cache:result;

    // Never send malformed attached-object data to the mobile client.
    // acs_id = 0 is VALID (it is accessory[0], model 907), therefore we only
    // remove rows with an invalid slot/bone/scale or an out-of-range index.
    mysql_format(mysql, query, sizeof query,
        "DELETE FROM accessories_players WHERE player_id=%d AND (slot < 1 OR slot > 9 OR bone < 1 OR bone > 18 OR scale <= 0.0 OR acs_id < 0 OR acs_id >= %d)",
        account_id, sizeof(accessory));
    mysql_query(mysql, query, false);

    mysql_format(mysql, query, sizeof query,
        "SELECT * FROM accessories_players WHERE player_id=%d AND slot BETWEEN 1 AND 9 AND bone BETWEEN 1 AND 18 AND scale > 0.0 AND acs_id >= 0 AND acs_id < %d",
        account_id, sizeof(accessory));
    result = mysql_query(mysql, query, true);

    rows = cache_num_rows();
    printf("[ACS][LOAD] safe load: player=%d account=%d rows=%d", playerid, account_id, rows);

    if(rows)
    {
        new slot, acs, bone, row_id, modelid;
        new Float:x, Float:y, Float:z, Float:rZ, Float:rY, Float:rX, Float:scale;

        for(new i; i < rows; i++)
        {
            row_id = cache_get_field_content_int(i, "id");
            slot = cache_get_field_content_int(i, "slot");
            acs = cache_get_field_content_int(i, "acs_id");
            bone = cache_get_field_content_int(i, "bone");
            x = cache_get_field_content_float(i, "x");
            y = cache_get_field_content_float(i, "y");
            z = cache_get_field_content_float(i, "z");
            rX = cache_get_field_content_float(i, "rX");
            rY = cache_get_field_content_float(i, "rY");
            rZ = cache_get_field_content_float(i, "rZ");
            scale = cache_get_field_content_float(i, "scale");

            if(acs < 0 || acs >= sizeof(accessory))
            {
                printf("[ACS][LOAD][SKIP] row=%d invalid acs_id=%d player=%d", row_id, acs, playerid);
                continue;
            }

            modelid = accessory[acs][ID_ACCESSORY];
            new resolved_bone = AccessoryResolveBone(acs, bone);
            if(resolved_bone != bone)
            {
                bone = resolved_bone;
                if(AccessoryIsHandCase(acs))
                {
                    // Old torso offsets are meaningless on the animated hand bone.
                    x = 0.08;
                    y = 0.02;
                    z = -0.05;
                    rX = 0.0;
                    rY = 90.0;
                    rZ = 0.0;
                }
                new fix_query[160];
                mysql_format(mysql, fix_query, sizeof fix_query,
                    "UPDATE accessories_players SET bone=%d,x=%f,y=%f,z=%f,rX=%f,rY=%f,rZ=%f WHERE id=%d AND player_id=%d LIMIT 1",
                    bone, x, y, z, rX, rY, rZ, row_id, account_id);
                mysql_query(mysql, fix_query, false);
            }
            if(modelid <= 0 || slot < 1 || slot > 9 || bone < 1 || bone > 18 || scale <= 0.0)
            {
                printf("[ACS][LOAD][DROP] row=%d player=%d slot=%d acs_id=%d model=%d bone=%d scale=%.4f", row_id, playerid, slot, acs, modelid, bone, scale);
                continue;
            }

            SetPlayerAttachedObject(playerid, slot, modelid, bone, x, y, z, rX, rY, rZ, scale, scale, scale);
            AccessorySyncTempData(playerid, slot, modelid, bone, x, y, z, rX, rY, rZ, scale);
            printf("[ACS][LOAD] apply row=%d player=%d slot=%d acs_id=%d model=%d bone=%d x=%.4f y=%.4f z=%.4f rx=%.2f ry=%.2f rz=%.2f scale=%.4f", i, playerid, slot, acs, modelid, bone, x, y, z, rX, rY, rZ, scale);
        }
    }

    cache_delete(result);
    return 1;
}


stock CreateEditAccessoryTD_AccessorySystem()//автор редактора не welsi
{
    	//ТЕКСТ  "РЕЖИМ КАСТОМИЗАЦИЙ"
	acss_fix_TD[0] = TextDrawCreate(35.0000, 18.0000, "txd:bracstext");
	TextDrawTextSize(acss_fix_TD[0], 127.0000, 45.0000);
	TextDrawAlignment(acss_fix_TD[0], 1);
	TextDrawColor(acss_fix_TD[0], -1);
	TextDrawBackgroundColor(acss_fix_TD[0], 255);
	TextDrawFont(acss_fix_TD[0], 4);

	//КНОПКА "ВЫХОД"
	acss_fix_TD[1] = TextDrawCreate(600.0000, 0.1, "txd:bracsbtnexit");
	TextDrawTextSize(acss_fix_TD[1], 45.0000, 50.0000);
	TextDrawAlignment(acss_fix_TD[1], 1);
	TextDrawColor(acss_fix_TD[1], -1);
	TextDrawBackgroundColor(acss_fix_TD[1], 255);
	TextDrawFont(acss_fix_TD[1], 4);
	TextDrawSetSelectable(acss_fix_TD[1], true);

	//КНОПКА "СОХРАНИТЬ"
	acss_fix_TD[2] = TextDrawCreate(453.0000, 355.0000, "txd:bracssave");
	TextDrawTextSize(acss_fix_TD[2], 130.0000, 40.0000);
	TextDrawAlignment(acss_fix_TD[2], 1);
	TextDrawColor(acss_fix_TD[2], -1);
	TextDrawBackgroundColor(acss_fix_TD[2], 255);
	TextDrawFont(acss_fix_TD[2], 4);
	TextDrawSetSelectable(acss_fix_TD[2], true);

//-НЕ НАЖАТЫЕ КНОПКИ
   	//КНОПКА "ВЛЕВО/ВПРАВО"
	acss_fix_TD[3] = TextDrawCreate(35.0000, 65.0000, "txd:bracsn1");
	TextDrawTextSize(acss_fix_TD[3], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[3], 1);
	TextDrawColor(acss_fix_TD[3], -1);
	TextDrawBackgroundColor(acss_fix_TD[3], 255);
	TextDrawFont(acss_fix_TD[3], 4);
	TextDrawSetSelectable(acss_fix_TD[3], true);

	//КНОПКА "ВВЕРХ/ВНИЗ"
	acss_fix_TD[4] = TextDrawCreate(35.0000, 110.0000, "txd:bracsn2");
	TextDrawTextSize(acss_fix_TD[4], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[4], 1);
	TextDrawColor(acss_fix_TD[4], -1);
	TextDrawBackgroundColor(acss_fix_TD[4], 255);
	TextDrawFont(acss_fix_TD[4], 4);
	TextDrawSetSelectable(acss_fix_TD[4], true);

	//КНОПКА "ОТ СЕБЯ/НА СЕБЯ"
	acss_fix_TD[5] = TextDrawCreate(35.0000, 155.0000, "txd:bracsn3");
	TextDrawTextSize(acss_fix_TD[5], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[5], 1);
	TextDrawColor(acss_fix_TD[5], -1);
	TextDrawBackgroundColor(acss_fix_TD[5], 255);
	TextDrawFont(acss_fix_TD[5], 4);
	TextDrawSetSelectable(acss_fix_TD[5], true);

	//КНОПКА "МАСШТАБ"
	acss_fix_TD[6] = TextDrawCreate(35.0000, 200.0000, "txd:bracsn4");
	TextDrawTextSize(acss_fix_TD[6], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[6], 1);
	TextDrawColor(acss_fix_TD[6], -1);
	TextDrawBackgroundColor(acss_fix_TD[6], 255);
	TextDrawFont(acss_fix_TD[6], 4);
	TextDrawSetSelectable(acss_fix_TD[6], true);

	//КНОПКА "ПОВОРОТ ПО ОСИ X"
	acss_fix_TD[7] = TextDrawCreate(35.0000, 245.0000, "txd:bracsn5");
	TextDrawTextSize(acss_fix_TD[7], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[7], 1);
	TextDrawColor(acss_fix_TD[7], -1);
	TextDrawBackgroundColor(acss_fix_TD[7], 255);
	TextDrawFont(acss_fix_TD[7], 4);
	TextDrawSetSelectable(acss_fix_TD[7], true);

	//КНОПКА "ПОВОРОТ ПО ОСИ Y"
	acss_fix_TD[8] = TextDrawCreate(35.0000, 290.0000, "txd:bracsn6");
	TextDrawTextSize(acss_fix_TD[8], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[8], 1);
	TextDrawColor(acss_fix_TD[8], -1);
	TextDrawBackgroundColor(acss_fix_TD[8], 255);
	TextDrawFont(acss_fix_TD[8], 4);
	TextDrawSetSelectable(acss_fix_TD[8], true);

	//КНОПКА "ПОВОРОТ ПО ОСИ Z"
	acss_fix_TD[9] = TextDrawCreate(35.0000, 335.0000, "txd:bracsn7");
	TextDrawTextSize(acss_fix_TD[9], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[9], 1);
	TextDrawColor(acss_fix_TD[9], -1);
	TextDrawBackgroundColor(acss_fix_TD[9], 255);
	TextDrawFont(acss_fix_TD[9], 4);
	TextDrawSetSelectable(acss_fix_TD[9], true);

//-НАЖАТЫЕ КНОПКИ
	//КНОПКА "ВЛЕВО/ВПРАВО"
	acss_fix_TD[10] = TextDrawCreate(35.0000, 65.0000, "txd:bracsa1");
	TextDrawTextSize(acss_fix_TD[10], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[10], 1);
	TextDrawColor(acss_fix_TD[10], -1);
	TextDrawBackgroundColor(acss_fix_TD[10], 255);
	TextDrawFont(acss_fix_TD[10], 4);

	//КНОПКА "ВВЕРХ/ВНИЗ"
	acss_fix_TD[11] = TextDrawCreate(35.0000, 110.0000, "txd:bracsa2");
	TextDrawTextSize(acss_fix_TD[11], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[11], 1);
	TextDrawColor(acss_fix_TD[11], -1);
	TextDrawBackgroundColor(acss_fix_TD[11], 255);
	TextDrawFont(acss_fix_TD[11], 4);

	//КНОПКА "ОТ СЕБЯ/НА СЕБЯ"
	acss_fix_TD[12] = TextDrawCreate(35.0000, 155.0000, "txd:bracsa3");
	TextDrawTextSize(acss_fix_TD[12], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[12], 1);
	TextDrawColor(acss_fix_TD[12], -1);
	TextDrawBackgroundColor(acss_fix_TD[12], 255);
	TextDrawFont(acss_fix_TD[12], 4);

	//КНОПКА "МАСШТАБ"
	acss_fix_TD[13] = TextDrawCreate(35.0000, 200.0000, "txd:bracsa4");
	TextDrawTextSize(acss_fix_TD[13], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[13], 1);
	TextDrawColor(acss_fix_TD[13], -1);
	TextDrawBackgroundColor(acss_fix_TD[13], 255);
	TextDrawFont(acss_fix_TD[13], 4);

	//КНОПКА "ПОВОРОТ ПО ОСИ X"
	acss_fix_TD[14] = TextDrawCreate(35.0000, 245.0000, "txd:bracsa5");
	TextDrawTextSize(acss_fix_TD[14], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[14], 1);
	TextDrawColor(acss_fix_TD[14], -1);
	TextDrawBackgroundColor(acss_fix_TD[14], 255);
	TextDrawFont(acss_fix_TD[14], 4);

	//КНОПКА "ПОВОРОТ ПО ОСИ Y"
	acss_fix_TD[15] = TextDrawCreate(35.0000, 290.0000, "txd:bracsa6");
	TextDrawTextSize(acss_fix_TD[15], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[15], 1);
	TextDrawColor(acss_fix_TD[15], -1);
	TextDrawBackgroundColor(acss_fix_TD[15], 255);
	TextDrawFont(acss_fix_TD[15], 4);

	//КНОПКА "ПОВОРОТ ПО ОСИ Z"
	acss_fix_TD[16] = TextDrawCreate(35.0000, 335.0000, "txd:bracsa7");
	TextDrawTextSize(acss_fix_TD[16], 117.0000, 42.0000);
	TextDrawAlignment(acss_fix_TD[16], 1);
	TextDrawColor(acss_fix_TD[16], -1);
	TextDrawBackgroundColor(acss_fix_TD[16], 255);
	TextDrawFont(acss_fix_TD[16], 4);

	//РЕДАКТОР "ВЛЕВО/ВПРАВО"
	acss_fix_TD[17] = TextDrawCreate(430.0000, 100.0000, "txd:bracsm1");
	TextDrawTextSize(acss_fix_TD[17], 180.0000, 230.0000);
	TextDrawAlignment(acss_fix_TD[17], 1);
	TextDrawColor(acss_fix_TD[17], -1);
	TextDrawBackgroundColor(acss_fix_TD[17], 255);
	TextDrawFont(acss_fix_TD[17], 4);
	TextDrawSetProportional(acss_fix_TD[17], 0);
	TextDrawSetShadow(acss_fix_TD[17], 0);

	//РЕДАКТОР "ВВЕРХ/ВНИЗ"
	acss_fix_TD[18] = TextDrawCreate(430.0000, 100.0000, "txd:bracsm2");
	TextDrawTextSize(acss_fix_TD[18], 180.0000, 230.0000);
	TextDrawAlignment(acss_fix_TD[18], 1);
	TextDrawColor(acss_fix_TD[18], -1);
	TextDrawBackgroundColor(acss_fix_TD[18], 255);
	TextDrawFont(acss_fix_TD[18], 4);
	TextDrawSetProportional(acss_fix_TD[18], 0);
	TextDrawSetShadow(acss_fix_TD[18], 0);

	//РЕДАКТОР "ОТ СЕБЯ/НА СЕБЯ"
	acss_fix_TD[19] = TextDrawCreate(430.0000, 100.0000, "txd:bracsm3");
	TextDrawTextSize(acss_fix_TD[19], 180.0000, 230.0000);
	TextDrawAlignment(acss_fix_TD[19], 1);
	TextDrawColor(acss_fix_TD[19], -1);
	TextDrawBackgroundColor(acss_fix_TD[19], 255);
	TextDrawFont(acss_fix_TD[19], 4);
	TextDrawSetProportional(acss_fix_TD[19], 0);
	TextDrawSetShadow(acss_fix_TD[19], 0);

	//РЕДАКТОР "МАСШТАБ"
	acss_fix_TD[20] = TextDrawCreate(430.0000, 100.0000, "txd:bracsm4");
	TextDrawTextSize(acss_fix_TD[20], 180.0000, 230.0000);
	TextDrawAlignment(acss_fix_TD[20], 1);
	TextDrawColor(acss_fix_TD[20], -1);
	TextDrawBackgroundColor(acss_fix_TD[20], 255);
	TextDrawFont(acss_fix_TD[20], 4);
	TextDrawSetProportional(acss_fix_TD[20], 0);
	TextDrawSetShadow(acss_fix_TD[20], 0);

	//РЕДАКТОР "ПОВОРОТ ПО ОСИ X"
	acss_fix_TD[21] = TextDrawCreate(430.0000, 100.0000, "txd:bracsm5");
	TextDrawTextSize(acss_fix_TD[21], 180.0000, 230.0000);
	TextDrawAlignment(acss_fix_TD[21], 1);
	TextDrawColor(acss_fix_TD[21], -1);
	TextDrawBackgroundColor(acss_fix_TD[21], 255);
	TextDrawFont(acss_fix_TD[21], 4);
	TextDrawSetProportional(acss_fix_TD[21], 0);
	TextDrawSetShadow(acss_fix_TD[21], 0);

	//РЕДАКТОР "ПОВОРОТ ПО ОСИ Y"
	acss_fix_TD[22] = TextDrawCreate(430.0000, 100.0000, "txd:bracsm6");
	TextDrawTextSize(acss_fix_TD[22], 180.0000, 230.0000);
	TextDrawAlignment(acss_fix_TD[22], 1);
	TextDrawColor(acss_fix_TD[22], -1);
	TextDrawBackgroundColor(acss_fix_TD[22], 255);
	TextDrawFont(acss_fix_TD[22], 4);
	TextDrawSetProportional(acss_fix_TD[22], 0);
	TextDrawSetShadow(acss_fix_TD[22], 0);

	//РЕДАКТОР "ПОВОРОТ ПО ОСИ Z"
	acss_fix_TD[23] = TextDrawCreate(430.0000, 100.0000, "txd:bracsm7");
	TextDrawTextSize(acss_fix_TD[23], 180.0000, 230.0000);
	TextDrawAlignment(acss_fix_TD[23], 1);
	TextDrawColor(acss_fix_TD[23], -1);
	TextDrawBackgroundColor(acss_fix_TD[23], 255);
	TextDrawFont(acss_fix_TD[23], 4);
	TextDrawSetProportional(acss_fix_TD[23], 0);
	TextDrawSetShadow(acss_fix_TD[23], 0);

	acss_fix_TD[24] = TextDrawCreate(460.0000, 205.0000, "txd:transparent");
	TextDrawTextSize(acss_fix_TD[24], 50.0000, 50.0000);
	TextDrawAlignment(acss_fix_TD[24], 1);
	TextDrawColor(acss_fix_TD[24], 0x00000000);
	TextDrawBackgroundColor(acss_fix_TD[24], 255);
	TextDrawFont(acss_fix_TD[24], 4);
	TextDrawSetProportional(acss_fix_TD[23], 0);
	TextDrawSetShadow(acss_fix_TD[24], 0);
	TextDrawSetSelectable(acss_fix_TD[24], true);

	acss_fix_TD[25] = TextDrawCreate(530.0000, 205.0000, "txd:transparent");
	TextDrawTextSize(acss_fix_TD[25], 50.0000, 50.0000);
	TextDrawAlignment(acss_fix_TD[25], 1);
	TextDrawColor(acss_fix_TD[25], 0x00000000);
	TextDrawBackgroundColor(acss_fix_TD[23], 255);
	TextDrawFont(acss_fix_TD[25], 4);
	TextDrawSetProportional(acss_fix_TD[23], 0);
	TextDrawSetShadow(acss_fix_TD[25], 0);
	TextDrawSetSelectable(acss_fix_TD[25], true);

    acss_fix_TD[26] = TextDrawCreate(250.0000, 360.0000, "<");
    TextDrawLetterSize(acss_fix_TD[26], 0.7500, 2.5000);
    TextDrawTextSize(acss_fix_TD[26], 295.0000, 42.0000);
    TextDrawAlignment(acss_fix_TD[26], 1);
    TextDrawColor(acss_fix_TD[26], 0xFFFFFFFF);
    TextDrawUseBox(acss_fix_TD[26], true);
    TextDrawBoxColor(acss_fix_TD[26], 0x202020CC);
    TextDrawSetSelectable(acss_fix_TD[26], true);

    acss_fix_TD[27] = TextDrawCreate(365.0000, 360.0000, ">");
    TextDrawLetterSize(acss_fix_TD[27], 0.7500, 2.5000);
    TextDrawTextSize(acss_fix_TD[27], 410.0000, 42.0000);
    TextDrawAlignment(acss_fix_TD[27], 1);
    TextDrawColor(acss_fix_TD[27], 0xFFFFFFFF);
    TextDrawUseBox(acss_fix_TD[27], true);
    TextDrawBoxColor(acss_fix_TD[27], 0x202020CC);
    TextDrawSetSelectable(acss_fix_TD[27], true);
}

public: CREATE_TABLIST_ACCESSORY()
{
	mysql_query(mysql, "SELECT * FROM accessories_players");

	if(mysql_errno())
	{
		mysql_query(mysql, 
			"CREATE TABLE `accessories_players` (\
		`id` INT NOT NULL AUTO_INCREMENT , PRIMARY KEY (`id`),\
		`player_id` int(11) NOT NULL,\
		`slot` int(11) NOT NULL,\
		`bone` int(11) NOT NULL,\
		`acs_id` int(11) NOT NULL,\
		`x` float NOT NULL DEFAULT 0.01,\
		`y` float NOT NULL DEFAULT 0.01,\
		`z` float NOT NULL DEFAULT 0.01,\
		`rX` float NOT NULL DEFAULT 0.01,\
		`rY` float NOT NULL DEFAULT 0.01,\
		`rZ` float NOT NULL DEFAULT 0.01,\
		`scale` float NOT NULL DEFAULT 1.01) ENGINE=InnoDB DEFAULT CHARSET=utf8;", false);

		if(mysql_errno()) return printf("ERROR CREATE TABLE accessories_players");
	}

	mysql_query(mysql, "SELECT * FROM accessory_inventory");

	if(mysql_errno())
	{
		mysql_query(mysql, 
			"CREATE TABLE `accessory_inventory` ( `id` INT NOT NULL AUTO_INCREMENT , \
			`player_id` INT NOT NULL , \
			`acs_id` INT NOT NULL , \
			`use` INT NOT NULL , PRIMARY KEY (`id`)) ENGINE = InnoDB;", false);

		if(mysql_errno()) return printf("ERROR CREATE TABLE accessory_inventory");
	}

	return 1;
}








