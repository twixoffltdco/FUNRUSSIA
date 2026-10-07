/*
Поменяйте диолог DIALOG_BIZ_CLOTHING_BUY на новый (сниху)

			case DIALOG_BIZ_CLOTHING_BUY:
			{
				new businessid = GetPlayerInBiz(playerid);
				print("ч");
				if(businessid != -1)
				{
						if(response)
						{
							new select_skin = GetPlayerSelectSkin(playerid);
							if(select_skin != -1)
							{
								new price = g_business_clothing_skins[GetPlayerSex(playerid)][select_skin][1];
								new skinid = g_business_clothing_skins[GetPlayerSex(playerid)][select_skin][0];

								new take_prods = random(8) + 6;
								new biz_price = price * 20 / 100;

								if(GetPlayerMoneyEx(playerid) >= price)
								{
									new query[255];
									if(GetBusinessData(businessid, B_PRODS) >= take_prods)
									{
										format(query, sizeof query, "UPDATE accounts a,business b SET a.skin=%d,a.money=%d,b.products=%d,b.balance=%d WHERE a.id=%d AND b.id=%d", skinid, GetPlayerMoneyEx(playerid)-price, GetBusinessData(businessid, B_PRODS)-take_prods, GetBusinessData(businessid, B_BALANCE)+biz_price, GetPlayerAccountID(playerid), GetBusinessData(businessid, B_SQL_ID));
									}
									else format(query, sizeof query, "UPDATE accounts SET money=%d WHERE id=%d LIMIT 1", GetPlayerMoneyEx(playerid)-price, GetPlayerAccountID(playerid));
									mysql_query(mysql, query, false);

									if(!mysql_errno())
									{
										if(GetBusinessData(businessid, B_PRODS) >= take_prods)
										{
											AddBusinessData(businessid, B_PRODS, -, take_prods);
											AddBusinessData(businessid, B_BALANCE, +, biz_price);
										}
										GivePlayerMoneyEx(playerid, -price, "Покупка скина (магазин одежды)", false, true);
										//SetPlayerData(playerid, P_SKIN, skinid);

										GivePlayerOwnableSkin(playerid, skinid);


										ExitPlayerClothingShopPanel(playerid);
										SendClientMessage(playerid, 0x66CC00FF, "Поздравляем с покупкой новой одежды!");

										mysql_format(mysql, query, sizeof query, "INSERT INTO business_profit (bid,uid,uip,time,money,view) VALUES (%d,%d,'%e',%d,%d,%d)", GetBusinessData(businessid, B_SQL_ID), GetPlayerAccountID(playerid), GetPlayerIpEx(playerid), gettime(), price, IsBusinessOwned(businessid));
										mysql_query(mysql, query, false);

										AddPlayerData(playerid, P_QUEST_EXP_6, +, 1);
										UpdatePlayerDatabaseInt(playerid, "quest_exp_6", GetPlayerData(playerid, P_QUEST_EXP_6));

										if(GetPlayerData(playerid, P_QUEST_EXP_6) == 1)
										{
										    SendClientMessage(playerid, COR_SERVER, "[Квесты]: "c_b"Вы успешно выполнили квест "c_i"'Пора приодеться'. "c_b"Награда: "c_m"5000 руб");
										    GivePlayerMoneyEx(playerid, 5000, "Выполнение квеста");

										    SetPlayerData(playerid, P_QUEST_6, 1);
										    UpdatePlayerDatabaseInt(playerid, "quest_6", 1);
										    
										    AddPlayerData(playerid, P_TOP_5, +, 1);
											UpdatePlayerDatabaseInt(playerid, "TOP_Quest", GetPlayerData(playerid, P_TOP_5));
										}
									}
									else SendClientMessage(playerid, 0xFF6600FF, "Ошибка сохранения, повторите попытку {FF0000}(equ-code 36)");
								}
								else SendClientMessage(playerid, 0x999999FF, "Недостаточно денег");
							}
						}
				}
			}



*/




#define GetSkinInfo(%0,%1)		g_skin_info[%0][%1]
#define GetSkinName(%0)			GetSkinInfo(%0, S_NAME)

enum E_SKIN_INFO_STRUCT
{
    S_NAME[64],    //имя
    S_PRICE        //гос стоимость
}
new g_skin_data[E_VEHICLE_STRUCT];
new const
    g_skin_info[300][E_SKIN_INFO_STRUCT] =
{
    {"Скин (0)", 0},
    {"Скин (1)", 0},
    {"Скин (2)", 0},
    {"Скин (3)", 0},
    {"Скин (4)", 0},
    {"Скин (5)", 0},
    {"Скин (6)", 0},
    {"Скин (7)", 0},
    {"Скин (8)", 0},
    {"Скин (9)", 0},
    {"Скин (10)", 0},
    {"Скин (11)", 0},
    {"Скин (12)", 0},
    {"Скин (13)", 0},
    {"Скин (14)", 0},
    {"Скин (15)", 0},
    {"Скин (16)", 0},
    {"Скин (17)", 0},
    {"Скин (18)", 0},
    {"Скин (19)", 0},
    {"Скин (20)", 0},
    {"Скин (21)", 0},
    {"Скин (22)", 0},
    {"Скин (23)", 0},
    {"Скин (24)", 0},
    {"Скин (25)", 0},
    {"Скин (26)", 0},
    {"Скин (27)", 0},
    {"Скин (28)", 0},
    {"Скин (29)", 0},
    {"Скин (30)", 0},
    {"Скин (31)", 0},
    {"Скин (32)", 0},
    {"Скин (33)", 0},
    {"Скин (34)", 0},
    {"Скин (35)", 0},
    {"Скин (36)", 0},
    {"Скин (37)", 0},
    {"Скин (38)", 0},
    {"Скин (39)", 0},
    {"Скин (40)", 0},
    {"Скин (41)", 0},
    {"Скин (42)", 0},
    {"Скин (43)", 0},
    {"Скин (44)", 0},
    {"Скин (45)", 0},
    {"Скин (46)", 0},
    {"Скин (47)", 0},
    {"Скин (48)", 0},
    {"Скин (49)", 0},
    {"Скин (50)", 0},
    {"Скин (51)", 0},
    {"Скин (52)", 0},
    {"Скин (53)", 0},
    {"Скин (54)", 0},
    {"Скин (55)", 0},
    {"Скин (56)", 0},
    {"Скин (57)", 0},
    {"Скин (58)", 0},
    {"Скин (59)", 0},
    {"Скин (60)", 0},
    {"Скин (61)", 0},
    {"Скин (62)", 0},
    {"Скин (63)", 0},
    {"Скин (64)", 0},
    {"Скин (65)", 0},
    {"Скин (66)", 0},
    {"Скин (67)", 0},
    {"Скин (68)", 0},
    {"Скин (69)", 0},
    {"Скин (70)", 0},
    {"Скин (71)", 0},
    {"Скин (72)", 0},
    {"Скин (73)", 0},
    {"Скин (74)", 0},
    {"Скин (75)", 0},
    {"Скин (76)", 0},
    {"Скин (77)", 0},
    {"Скин (78)", 0},
    {"Скин (79)", 0},
    {"Скин (80)", 0},
    {"Скин (81)", 0},
    {"Скин (82)", 0},
    {"Скин (83)", 0},
    {"Скин (84)", 0},
    {"Скин (85)", 0},
    {"Скин (86)", 0},
    {"Скин (87)", 0},
    {"Скин (88)", 0},
    {"Скин (89)", 0},
    {"Скин (90)", 0},
    {"Скин (91)", 0},
    {"Скин (92)", 0},
    {"Скин (93)", 0},
    {"Скин (94)", 0},
    {"Скин (95)", 0},
    {"Скин (96)", 0},
    {"Скин (97)", 0},
    {"Скин (98)", 0},
    {"Скин (99)", 0},
    {"Скин (100)", 0},
    {"Скин (101)", 0},
    {"Скин (102)", 0},
    {"Скин (103)", 0},
    {"Скин (104)", 0},
    {"Скин (105)", 0},
    {"Скин (106)", 0},
    {"Скин (107)", 0},
    {"Скин (108)", 0},
    {"Скин (109)", 0},
    {"Скин (110)", 0},
    {"Скин (111)", 0},
    {"Скин (112)", 0},
    {"Скин (113)", 0},
    {"Скин (114)", 0},
    {"Скин (115)", 0},
    {"Скин (116)", 0},
    {"Скин (117)", 0},
    {"Скин (118)", 0},
    {"Скин (119)", 0},
    {"Скин (120)", 0},
    {"Скин (121)", 0},
    {"Скин (122)", 0},
    {"Скин (123)", 0},
    {"Скин (124)", 0},
    {"Скин (125)", 0},
    {"Скин (126)", 0},
    {"Скин (127)", 0},
    {"Скин (128)", 0},
    {"Скин (129)", 0},
    {"Скин (130)", 0},
    {"Скин (131)", 0},
    {"Скин (132)", 0},
    {"Скин (133)", 0},
    {"Скин (134)", 0},
    {"Скин (135)", 0},
    {"Скин (136)", 0},
    {"Скин (137)", 0},
    {"Скин (138)", 0},
    {"Скин (139)", 0},
    {"Скин (140)", 0},
    {"Скин (141)", 0},
    {"Скин (142)", 0},
    {"Скин (143)", 0},
    {"Скин (144)", 0},
    {"Скин (145)", 0},
    {"Скин (146)", 0},
    {"Скин (147)", 0},
    {"Скин (148)", 0},
    {"Скин (149)", 0},
    {"Скин (150)", 0},
    {"Скин (151)", 0},
    {"Скин (152)", 0},
    {"Скин (153)", 0},
    {"Скин (154)", 0},
    {"Скин (155)", 0},
    {"Скин (156)", 0},
    {"Скин (157)", 0},
    {"Скин (158)", 0},
    {"Скин (159)", 0},
    {"Скин (160)", 0},
    {"Скин (161)", 0},
    {"Скин (162)", 0},
    {"Скин (163)", 0},
    {"Скин (164)", 0},
    {"Скин (165)", 0},
    {"Скин (166)", 0},
    {"Скин (167)", 0},
    {"Скин (168)", 0},
    {"Скин (169)", 0},
    {"Скин (170)", 0},
    {"Скин (171)", 0},
    {"Скин (172)", 0},
    {"Скин (173)", 0},
    {"Скин (174)", 0},
    {"Скин (175)", 0},
    {"Скин (176)", 0},
    {"Скин (177)", 0},
    {"Скин (178)", 0},
    {"Скин (179)", 0},
    {"Скин (180)", 0},
    {"Скин (181)", 0},
    {"Скин (182)", 0},
    {"Скин (183)", 0},
    {"Скин (184)", 0},
    {"Скин (185)", 0},
    {"Скин (186)", 0},
    {"Скин (187)", 0},
    {"Скин (188)", 0},
    {"Скин (189)", 0},
    {"Скин (190)", 0},
    {"Скин (191)", 0},
    {"Скин (192)", 0},
    {"Скин (193)", 0},
    {"Скин (194)", 0},
    {"Скин (195)", 0},
    {"Скин (196)", 0},
    {"Скин (197)", 0},
    {"Скин (198)", 0},
    {"Скин (199)", 0},
    {"Скин (200)", 0},
    {"Скин (201)", 0},
    {"Скин (202)", 0},
    {"Скин (203)", 0},
    {"Скин (204)", 0},
    {"Скин (205)", 0},
    {"Скин (206)", 0},
    {"Скин (207)", 0},
    {"Скин (208)", 0},
    {"Скин (209)", 0},
    {"Скин (210)", 0},
    {"Скин (211)", 0},
    {"Скин (212)", 0},
    {"Скин (213)", 0},
    {"Скин (214)", 0},
    {"Скин (215)", 0},
    {"Скин (216)", 0},
    {"Скин (217)", 0},
    {"Скин (218)", 0},
    {"Скин (219)", 0},
    {"Скин (220)", 0},
    {"Скин (221)", 0},
    {"Скин (222)", 0},
    {"Скин (223)", 0},
    {"Скин (224)", 0},
    {"Скин (225)", 0},
    {"Скин (226)", 0},
    {"Скин (227)", 0},
    {"Скин (228)", 0},
    {"Скин (229)", 0},
    {"Скин (230)", 0},
    {"Скин (231)", 0},
    {"Скин (232)", 0},
    {"Скин (233)", 0},
    {"Скин (234)", 0},
    {"Скин (235)", 0},
    {"Скин (236)", 0},
    {"Скин (237)", 0},
    {"Скин (238)", 0},
    {"Скин (239)", 0},
    {"Скин (240)", 0},
    {"Скин (241)", 0},
    {"Скин (242)", 0},
    {"Скин (243)", 0},
    {"Скин (244)", 0},
    {"Скин (245)", 0},
    {"Скин (246)", 0},
    {"Скин (247)", 0},
    {"Скин (248)", 0},
    {"Скин (249)", 0},
    {"Скин (250)", 0},
    {"Скин (251)", 0},
    {"Скин (252)", 0},
    {"Скин (253)", 0},
    {"Скин (254)", 0},
    {"Скин (255)", 0},
    {"Скин (256)", 0},
    {"Скин (257)", 0},
    {"Скин (258)", 0},
    {"Скин (259)", 0},
    {"Скин (260)", 0},
    {"Скин (261)", 0},
    {"Скин (262)", 0},
    {"Скин (263)", 0},
    {"Скин (264)", 0},
    {"Скин (265)", 0},
    {"Скин (266)", 0},
    {"Скин (267)", 0},
    {"Скин (268)", 0},
    {"Скин (269)", 0},
    {"Скин (270)", 0},
    {"Скин (271)", 0},
    {"Скин (272)", 0},
    {"Скин (273)", 0},
    {"Скин (274)", 0},
    {"Скин (275)", 0},
    {"Скин (276)", 0},
    {"Скин (277)", 0},
    {"Скин (278)", 0},
    {"Скин (279)", 0},
    {"Скин (280)", 0},
    {"Скин (281)", 0},
    {"Скин (282)", 0},
    {"Скин (283)", 0},
    {"Скин (284)", 0},
    {"Скин (285)", 0},
    {"Скин (286)", 0},
    {"Скин (287)", 0},
    {"Скин (288)", 0},
    {"Скин (289)", 0},
    {"Скин (290)", 0},
    {"Скин (291)", 0},
    {"Скин (292)", 0},
    {"Скин (293)", 0},
    {"Скин (294)", 0},
    {"Скин (295)", 0},
    {"Скин (296)", 0},
    {"Скин (297)", 0},
    {"Скин (298)", 0},
    {"Скин (299)", 0}
};


CMD:myskinsz(playerid)
{
			new fmt_text[640],
			Cache: result,
			id;

		mysql_format(mysql, fmt_text, sizeof fmt_text, "SELECT * FROM inventory_skins WHERE owner_skin='%d'", GetPlayerAccountID(playerid));
		result = mysql_query(mysql, fmt_text, true);

		new rows = cache_num_rows();

		if(!rows)
		{
			SendClientMessage(playerid, 0x999999FF, "У Вас нет личного скина");
			CheckSkinPlayer(playerid);
		}
		else
		{	

				new query[60],
					skin_id, use, skin_use[24];

				format(fmt_text, sizeof fmt_text, "");

				for(new i = 0; i < rows; i ++)
				{
					id = cache_get_field_content_int(i, "id");
					skin_id = cache_get_field_content_int(i, "skin_id");
					use = cache_get_field_content_int(i, "use_skin");

					if(use > 0) skin_use = "{636363}[используется]";
					else  skin_use = "";

					format
					(
						query,
						sizeof query,
						"{FFFFFF}%d. %s %s\n",
					    i + 1, 
				 	  	GetSkinInfo(skin_id, S_NAME), skin_use
					);
					strcat(fmt_text, query);
					SetPlayerListitemValue(playerid, i, id);
				}

				Dialog
				(
					playerid, 1789, DIALOG_STYLE_LIST,
					"{FFCD00}Выберите скин",
					fmt_text,
					"Выбрать", "Закрыть"
				);
		}

		cache_delete(result);

	return 1;
}
stock CheckSkinPlayer(playerid)
{
	new query[144], Cache:result;
	mysql_format(mysql, query, sizeof query, "SELECT * FROM inventory_skins WHERE owner_skin = %d", GetPlayerAccountID(playerid));
	result = mysql_query(mysql, query, true);

	new rows = cache_num_rows();
	cache_delete(result);

	if(!rows)
	{
		mysql_format(mysql, query, sizeof query, "INSERT INTO inventory_skins (owner_skin,skin_id,use_skin) VALUES (%d,%d,1)", GetPlayerAccountID(playerid), GetPlayerSkinEx(playerid));
		mysql_query(mysql, query, false);
		if(mysql_errno()) return SCM(playerid, -1, "CheckSkinPlayer | SQL ERROR 1");
		SendClientMessage(playerid, -1, ""SC"Добавлена одежда в инвентарь");
		
		return 1;
	}
	return 0;
}
stock GivePlayerOwnableSkin(playerid, skinid)
{
		new fmt_text[144],
		Cache: result,
		query[64];

		mysql_format(mysql, query, sizeof query, "INSERT INTO inventory_skins (owner_skin,skin_id) VALUES (%d,%d)", GetPlayerAccountID(playerid), skinid);
		result = mysql_query(mysql, query, true);
		cache_delete(result);
		
		format(fmt_text, sizeof(fmt_text), "Позравляем! Вы получили новую одежду %s. Чтобы использовать /myskins", GetSkinInfo(skinid, S_NAME));
		SCM(playerid, -1, fmt_text);
}

stock ShowOwnableSkinLoadDialog(playerid, id)
{
	SetPVarInt(playerid, "ownableskin_id", id);

	Dialog
	(
		playerid, 1790, DIALOG_STYLE_LIST,
		"{FFCD00}Система управление скином",
		"1. Использавать\n"\
		"{888888}2. Удалить",
		"Выбрать", "Закрыть"
	);
}


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == 1789)
    {
        if(response)
        {
            new idx = GetPlayerListitemValue(playerid, listitem);

            ShowOwnableSkinLoadDialog(playerid, idx);
        }
    }
    if(dialogid == 1790)
    {
        if(response)
        {
            new idx = GetPVarInt(playerid, "ownableskin_id");
            
            new query[164], skin_id, use, use_skin_id,
            Cache:result;
            mysql_format(mysql, query, sizeof query, "SELECT skin_id, use_skin FROM inventory_skins WHERE id = %d ", idx);
            result = mysql_query(mysql, query, true);
            skin_id = cache_get_row_int(0, 0);
            use = cache_get_row_int(0, 1);
            cache_delete(result);

            mysql_format(mysql, query, sizeof query, "SELECT id FROM inventory_skins WHERE `use_skin` = 1 LIMIT 1");
            result = mysql_query(mysql, query, true);
            use_skin_id = cache_get_row_int(0, 0);
            cache_delete(result);

            switch(listitem + 1)
            {
                case 1:
                {
                    new team_id = GetPlayerTeamEx(playerid);
                    if((team_id > 0) &&
                        (GetPVarInt(playerid, "Form") == 1 ||
                        (GetPlayerData(playerid, P_OSKIN) > 0 && GetPlayerData(playerid, P_OSKIN) != GetPlayerData(playerid, P_SKIN) && GetPlayerSkin(playerid) == GetPlayerData(playerid, P_OSKIN))))
                    {
                        SendClientMessage(playerid, 0x999999FF, "Сначала закончите рабочий день в раздевалке.");
                        return 1;
                    }

                    if(use)
                    {
                        SendClientMessage(playerid, 0x999999FF, "Одежда используется.");
                        return 1;
                    }
                    new fmt_str[12];
                    SetPlayerData(playerid, P_SKIN, skin_id);
                    UpdatePlayerDatabaseInt(playerid, "skin", skin_id);

                    mysql_format(mysql, query, sizeof query, "UPDATE inventory_skins SET `use_skin` = 0 WHERE `id` = %d", use_skin_id);
                    mysql_query(mysql, query, false);

                    mysql_format(mysql, query, sizeof query, "UPDATE inventory_skins SET `use_skin` = 1 WHERE `id` = %d", idx);
                    mysql_query(mysql, query, false);

                    SetPlayerSkinInit(playerid);

                    SendClientMessage(playerid, 0x66CC33FF, ""SC" Вы надели одежду!");
                }
                case 2:
                {	
                    if(use)
                    {
                        SendClientMessage(playerid, 0x999999FF, ""USC"Нельзя удалить одежду которая используется.");
                        return 1;
                    }
                    mysql_format(mysql, query, sizeof query, "DELETE FROM inventory_skins WHERE id=%d", idx);
                    mysql_query(mysql, query, false);

                }
            }
        }
        
        return 1;
    }
    #if defined skin_OnDialogResponse
        return skin_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    #else
        return 0;
    #endif
}
#if defined _ALS_OnDialogResponse
#undef OnDialogResponse
#else
#define _ALS_OnDialogResponse
#endif
#define OnDialogResponse skin_OnDialogResponse
#if defined skin_OnDialogResponse
forward skin_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif
