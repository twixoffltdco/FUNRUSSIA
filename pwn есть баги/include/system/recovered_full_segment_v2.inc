CMD:donat(playerid, params[])
{
  new fmt_str[500];
 
 format
 (
   fmt_str, sizeof(fmt_str),
   "{FFFFFF}? ???? ??????? ?? ?????? ???????????? ??????????????\n"\
   "??????????? ???????. ????? ???????? ? ??? ??????,\n"\
   "?????????? ????????? ???? ??????? ????. ???????? ????\n"\
   "?????????????? ????????????, ? ????? ? ????????\n"\
   "?????????? ????? ?? ?????? ?????? ?? ????? ?????:\n"\
   "{32CD32}"SERVER_SITE" (?????? ?????)\n\n"\
   "{1E90FF}??????????:\n"\
   "{FFFFFF}????? ????????:  %d\n"\
   "{FFFFFF}??????? ????????? ?????:  %d BC\n"\
   "{FFFFFF}????????? ??????????: %d BC\n"\
   "{FFFFFF}????? ????? ??????????: %d BC\n",
   GetPlayerAccountID(playerid),
   GetPlayerDonateRub(playerid),
   GetPlayerLastDonation(playerid),
   GetPlayerTotalDonate(playerid)
  );
  return Dialog(playerid, DIALOG_DINFO, DIALOG_STYLE_MSGBOX, "{FF0000}??????????", fmt_str, "?????", "?????");
}


CMD:donatee(playerid)
{
	ShowPlayerDonateMenu(playerid);
	return true;
}

CMD:setspawn(playerid, params[])

{
    Dialog
    (
        playerid, DIALOG_SET_SPAWN, DIALOG_STYLE_LIST,
        "{FFCC00}????????? ????? ????????? ? ????",
        "1. ?? ?/? ??????? ??? ???????????\n\
        2. ? ??????????? ????\n\
        3. ? ??????????? ??????\n\
        4. ?? ???? ???????????\n\
        5. ? ?????? (?????????? ??????????)\n\
        6. ?? ???? ?????",
        "???????", "??????"
    );
    return 1;
}

alias:setspawn("spawnchange")

CMD:setspawnpos(playerid)
{
    if(GetPlayerData(playerid, P_FAMILY) && GetPlayerData(playerid, P_FAMILY_RANK) == 10)
    {
        Dialog
        (
            playerid, DIALOG_FAMILY_SPAWN_SET, DIALOG_STYLE_MSGBOX,
            "????????? ?????",
            "?? ????????????? ?????? ?????????? ????? ?????? ????? ?????\n\
            ?? ?? ????? ??? ?? ???????????",
            "?????", "??????"
        );
    }
    return 1;
}

CMD:fleave(playerid, params[])
{
    //if(GetPlayerData(playerid, P_IMPROVEMENTS) < 2) return SendClientMessage(playerid, 0xCECECEFF, "??????????? ????????? \"?????????????\", ????? ????????? ?? ???????????? ???????");

    if(!GetPlayerData(playerid, P_FAMILY)) return SendClientMessage(playerid, 0xCECECEFF, "?? ?? ???????? ? ?????");

    new fmt_text[210];

    format
    (
        fmt_text, sizeof fmt_text,
        "{FFFFFF}?? ???????? ? ????? {ffff00} \"%s\".\n"\
        "{FFFFFF}???? ?? ?????????, ?? ????????? ??? ???? ?????????? ? ???, ????? ??? ????.\n\n"\
        "?? ???????, ??? ?????? ???????? ??????",
        GetFamilyData(GetPlayerData(playerid, P_FAMILY), F_NAME)
    );

    Dialog(playerid, DIALOG_FAMILY_LEAVE, DIALOG_STYLE_MSGBOX, "{FF0000}????? ?? ?????.", fmt_text, "????", "??????");

    return 1;
}

CMD:fm(playerid, params[])
{
    return ShowFamilyGui(playerid);
}


/*CMD:settint(playerid, params[])
{
	extract params -> new tint_id, tint_color; else return SendClientMessage(playerid, 0xCECECEFF, "???????????: /settint [id ?????????] [id ?????]");

	if(!(0 <= tint_id <= MAX_WEAPON_TINTS - 1)) return SendClientMessage(playerid, 0x999999FF, "???????????? ????????????? ?????????");

	if(!(0 <= tint_color <= sizeof weapon_tints)) return SendClientMessage(playerid, 0x999999FF, "???????????? ????????????? ?????");

	g_player[playerid][P_WEAPON_TINT][tint_id] = tint_color;

	SendClientMessage(playerid, -1, "??????? ????????");

	return 1;
}*/

CMD:dice(playerid, params[])
{
	if(!PlayerTotalOnline(playerid, 1))
	return SendClientMessage(playerid, 0x999999FF, ""USC"??? ???? ? ?????? ?????????? ???????? 1 ????");

	if(GetPlayerInBiz(playerid) == -1)
		return SendClientMessage(playerid, 0x999999FF, "?? ?????? ?????????? ? ??????");

	if(GetBusinessData(GetPlayerInBiz(playerid), B_TYPE) != BUSINESS_TYPE_CASINO)
		return SendClientMessage(playerid, 0x999999FF, "?? ?????? ?????????? ? ??????");

	if(!IsPlayerInRangeOfAnyCasinoTable(playerid)) return SendClientMessage(playerid, 0x999999FF, "?? ?????? ?????????? ????? ?????????? ?????");

	/*if(!PlayerTotalOnline(playerid, 10))
		return SendClientMessage(playerid, 0x999999FF, "??? ???? ? ????? ?????????? ???????? 10 ?????");*/

	extract params -> new to_player, money; else return SendClientMessage(playerid, 0xCECECEFF, "???????????: /dice [id ??????] [?????]");

	if(!IsPlayerConnected(to_player) || !IsPlayerLogged(to_player) || to_player == playerid)
		return SendClientMessage(playerid, 0x999999FF, "?????? ?????? ???");

	if(!IsPlayerInRangeOfPlayer(playerid, to_player, 4.0))
		return SendClientMessage(playerid, 0x999999FF, "????? ????????? ??????? ??????");

	if(!(1 <= money <= 1_000_000))
		return SendClientMessage(playerid, 0x999999FF, "????? ?????? ???? ?? ????? 1.000.000 ??????");

	if(GetPlayerMoneyEx(playerid) < money)
		return SendClientMessage(playerid, 0x999999FF, "? ??? ??? ?????? ?????????? ?????");

	if(GetPlayerMoneyEx(to_player) < money)
		return SendClientMessage(playerid, 0x999999FF, "? ?????? ??? ?????? ?????????? ?????");

	SendPlayerOffer(playerid, to_player, OFFER_TYPE_CASINO_DICE, money);

	return 1;
}

CMD:ad(playerid, params[])
{
	if(!GetPlayerPhone(playerid))
		return SendClientMessage(playerid, 0x999999FF, "? ??? ??? ????????, ?? ???????? ????? ? ???? ?????????");

	new fmt_text[144];

	if(IsAIP(params))
	{
   		SendClientMessage(playerid, -1, "?????????? ? ???????!");
       	return false;
    }

	for(new idx = g_advert_created - 1; idx >= 0; idx --)
	{
		if(GetAdvertData(idx, A_CREATOR) != playerid) continue;

		format(fmt_text, sizeof fmt_text, "???? ?????????? ??? ????????? ? ??????? ??? {00CC99}??????? %d", GetAdvertIndexInQueue(idx));
		SendClientMessage(playerid, 0xCECECEFF, fmt_text);

		/*
		if(idx)
			SendClientMessage(playerid, 0xCECECEFF, "?? ?????? ???????? ??? ?????????? {FF9900}? ??????? ??????? /up. {CECECE}?????? ????? {33CCFF}2000 ???");
		*/

		return 1;
	}

	if(!strlen(params))
		return SendClientMessage(playerid, 0xCECECEFF, "???????????: /ad [????? ??????????]");

	if(GetPlayerMoneyEx(playerid) < ADVERT_SEND_PRICE)
		return SendClientMessage(playerid, 0x999999FF, "??? ???????? ?????????? ?????????? ????? 250 ???");

	SendAdvert(playerid, params);

	GivePlayerMoneyEx(playerid, -250, "???????? ??????????", true, true);
	BlackPass_OnAdvertSent(playerid);

	format(fmt_text, sizeof fmt_text, "?????: %s", params);
	SendClientMessage(playerid, 0x00CC99FF, fmt_text);

	SendClientMessage(playerid, -1, "???? ?????????? ???? ????????? ? ??????? ??? ??????????");
	SendClientMessage(playerid, -1, "??????????? ?? ?????, ? ????????? ?????? ?????????? ????? ??????? ?? ???????");
	// SendClientMessage(playerid, -1, "?? ?????? ???????? ??? ?????????? {FF9900}? ??????? ??????? /up. {FFFFFF}?????? ????? {33CCFF}2000 ???");

	return 1;
}

CMD:edit(playerid, params[])
{
	if(GetPlayerTeamEx(playerid) != TEAM_RADIO) return SendClientMessage(playerid, 0x999999FF, "??? ?????????? ?????? ???????");

	if(!g_advert_created) return SendClientMessage(playerid, 0xCECECEFF, "??? ?????????? ??? ??????????????");

	new fmt_text[360],
		bool: ad_is_found;

	for(new idx = g_advert_created - 1; idx >= 0; idx --)
	{
		if(GetAdvertData(idx, A_EDIT) || GetAdvertData(idx, A_CREATOR) == INVALID_PLAYER_ID) continue;

		format
		(
			fmt_text, sizeof fmt_text,
			"{FFFFFF}???????????: %s\n\n?????:\n{FFCD00}%s\n\n"\
			"{FFFFFF}??? ?????????????? ?????????? ??????? ????? ????? ? ??????? '?????????'.\n"\
			"???? ?????????????? ?????????? ?? ?????, ???????? ???? ??????.",
			GetPlayerNameEx(GetAdvertData(idx, A_CREATOR)), GetAdvertData(idx, A_TEXT)
		);

		Dialog(playerid, DIALOG_ADVERT_EDIT, DIALOG_STYLE_INPUT, "{00CC00}?????????? ??????????", fmt_text, "?????????", "?????????");

		SetAdvertData(idx, A_EDIT, true);

		SetPVarInt(playerid, "advert_id", idx);

		ad_is_found = true;

		break;
	}

	if(!ad_is_found) return SendClientMessage(playerid, 0xCECECEFF, "??? ?????????? ??? ??????????????");

	return 1;
}

CMD:t(playerid, params[])
{
	if(GetPlayerTeamEx(playerid) != TEAM_RADIO) return SendClientMessage(playerid, 0x999999FF, "??? ?????????? ?????? ???????");

	if(!strlen(params)) return SendClientMessage(playerid, 0xCECECEFF, "???????????: /t [?????]");

	new fmt_text[144];

	format(fmt_text, sizeof fmt_text, "[???] %s: %s", GetPlayerNameEx(playerid), params);
	SendClientMessageToAll(0x6666FFFF, fmt_text);

	return 1;
}

CMD:u(playerid, params[])
{
	if(!GetPVarInt(playerid, "radio_mic")) return SendClientMessage(playerid, 0x999999FF, "?? ?? ?????????? ? ?????-?????");

	if(!strlen(params)) return SendClientMessage(playerid, 0xCECECEFF, "???????????: /u [?????]");

	new fmt_text[144];

	format(fmt_text, sizeof fmt_text, "[???] ????? %s: %s", GetPlayerNameEx(playerid), params);
	SendClientMessageToAll(0x6666FFFF, fmt_text);

	return 1;
}

CMD:givemic(playerid, params[])
{
	if(GetPlayerTeamEx(playerid) != TEAM_RADIO) return SendClientMessage(playerid, 0x999999FF, "??? ?????????? ?????? ???????");

	extract params -> new to_player; else return SendClientMessage(playerid, 0xCECECEFF, "???????????: /givemic [id ??????]");

	if(!IsPlayerConnected(to_player) || !IsPlayerLogged(to_player) || to_player == playerid)
		return SendClientMessage(playerid, 0x999999FF, "?????? ?????? ???");

	if(!GetPVarInt(to_player, "radio_mic"))
		SendPlayerOffer(playerid, to_player, OFFER_TYPE_GIVE_MIC);

	else
	{
		new fmt_text[128];

		format(fmt_text, sizeof fmt_text, "%s %s[%d] ???????? ??? ?? ?????-?????",
		GetPlayerJobAndRankName(playerid), GetPlayerNameEx(playerid), playerid);

		SendClientMessage(to_player, 0xFF5533FF, fmt_text);

		format(fmt_text, sizeof fmt_text, "?? ????????? %s[%d] ?? ?????-?????", GetPlayerNameEx(to_player), to_player);
		SendClientMessage(playerid, 0xFFFF00FF, fmt_text);

		format(fmt_text, sizeof fmt_text, "[???] %s %s[%d] ???????? %s[%d] ?? ?????-?????",
		GetPlayerJobAndRankName(playerid), GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(to_player), to_player);

		SendMessageToTeam(GetPlayerTeamEx(playerid), fmt_text, 0x99CC99FF, playerid);

		SetPVarInt(to_player, "radio_mic", 0);
	}

	return 1;
}

/*CMD:gangzonegovnozhopa(playerid, params[])
{
	new gang_zone[100][4] =
	{
		{-2667, 149, -2567, 249},
		{-2567, 149, -2467, 249},
		{-2467, 149, -2367, 249},
		{-2367, 149, -2267, 249},
		{-2267, 149, -2167, 249},
		{-2167, 149, -2067, 249},
		{-2167, 49, -2067, 149},
		{-2267, 49, -2167, 149},
		{-2367, 49, -2267, 149},
		{-2467, 49, -2367, 149},
		{-2567, 49, -2467, 149},
		{-2667, 49, -2567, 149},
		{-2667, -51, -2567, 49},
		{-2567, -51, -2467, 49},
		{-2467, -51, -2367, 49},
		{-2367, -51, -2267, 49},
		{-2267, -51, -2167, 49},
		{-2167, -51, -2067, 49},
		{-2167, -151, -2067, -51},
		{-2267, -151, -2167, -51},
		{-2367, -151, -2267, -51},
		{-2467, -151, -2367, -51},
		{-2567, -151, -2467, -51},
		{-2667, -151, -2567, -51},
		{-2667, -251, -2567, -151},
		{-2567, -251, -2467, -151},
		{-2467, -251, -2367, -151},
		{-2367, -251, -2267, -151},
		{-2267, -251, -2167, -151},
		{-2167, -251, -2067, -151},
		{1974, 2007, 2074, 2107},
		{1874, 2007, 1974, 2107},
		{1774, 2007, 1874, 2107},
		{1674, 2007, 1774, 2107},
		{1574, 2007, 1674, 2107},
		{1574, 2107, 1674, 2207},
		{1674, 2107, 1774, 2207},
		{1774, 2107, 1874, 2207},
		{1874, 2107, 1974, 2207},
		{1974, 2107, 2074, 2207},
		{1974, 2207, 2074, 2307},
		{1874, 2207, 1974, 2307},
		{1774, 2207, 1874, 2307},
		{1674, 2207, 1774, 2307},
		{1574, 2207, 1674, 2307},
		{1574, 2307, 1674, 2407},
		{1674, 2307, 1774, 2407},
		{1774, 2307, 1874, 2407},
		{1874, 2307, 1974, 2407},
		{1974, 2307, 2074, 2407},
		{1974, 2407, 2074, 2507},
		{1874, 2407, 1974, 2507},
		{1774, 2407, 1874, 2507},
		{1674, 2407, 1774, 2507},
		{1574, 2407, 1674, 2507},
		{1574, 2507, 1674, 2607},
		{1674, 2507, 1774, 2607},
		{1774, 2507, 1874, 2607},
		{1874, 2507, 1974, 2607},
		{1974, 2507, 2074, 2607},
		{1751, -311, 1851, -211},
		{1751, -411, 1851, -311},
		{1651, -411, 1751, -311},
		{1651, -311, 1751, -211},
		{1551, -311, 1651, -211},
		{1551, -411, 1651, -311},
		{1451, -411, 1551, -311},
		{1451, -311, 1551, -211},
		{981, -265, 1081, -165},
		{981, -365, 1081, -265},
		{981, -465, 1081, -365},
		{881, -465, 981, -365},
		{881, -365, 981, -265},
		{881, -265, 981, -165},
		{781, -265, 881, -165},
		{781, -365, 881, -265},
		{781, -465, 881, -365},
		{681, -465, 781, -365},
		{681, -365, 781, -265},
		{681, -265, 781, -165},
		{581, -265, 681, -165},
		{581, -365, 681, -265},
		{581, -465, 681, -365},
		{481, -465, 581, -365},
		{481, -365, 581, -265},
		{481, -265, 581, -165},
		{381, -265, 481, -165},
		{381, -365, 481, -265},
		{381, -465, 481, -365},
		{281, -365, 381, -265},
		{2401, -330, 2501, -230},
		{2501, -330, 2601, -230},
		{2501, -230, 2601, -130},
		{2501, -130, 2601, -30},
		{2401, -230, 2501, -130},
		{2401, -130, 2501, -30},
		{2301, -230, 2401, -130},
		{2601, -330, 2701, -230},
		{2601, -230, 2701, -130},
		{2201, -230, 2301, -130}
	};

	for(new i; i < sizeof gang_zone; i ++)
	{
		new query[110];

		mysql_format(mysql, query, sizeof query, "INSERT INTO gang_zones (min_x, min_y, max_x, max_y) VALUES (%d, %d, %d, %d)", gang_zone[i][0], gang_zone[i][1], gang_zone[i][2], gang_zone[i][3]);
		mysql_query(mysql, query, false);
	}

	LoadGangZones();

	ShowGangZonesForPlayer(playerid);

	return 1;
}*/

/*stock KickForSoft(playerid)
{
	new fmt_text[80];

	format(fmt_text, sizeof fmt_text, "[A] %s[%d] ???????? ???????????? ? ??????????? ??????", GetPlayerNameEx(playerid), playerid);
	SendMessageToAdmins(fmt_text, 0xFF5533FF);

	SendClientMessage(playerid, 0xFF5533FF, "?? ??????????? ??????????? ??????????? ???????????");
	SendClientMessage(playerid, 0xFF6600FF, "?????? ? ??????? ??????????. ?????????????? ???? ? ???????????? ?????");
	SendClientMessage(playerid, 0xFFFFFFFF, "");

	printf("%s[%d] kicked. Reason: Forbidden software");

	Kick:(playerid, _, 1000);

	return 1;
}*/

stock CreateGreenZones()
{
	for(new idx; idx < g_green_zones_loaded; idx ++)
	{
		if(g_green_zones[idx][GZ_SIZE] <= 0.0)
		{
			continue;
		}

		new old_area = g_green_zones[idx][GZ_AREA];
		if(g_green_zones[idx][GZ_AREA] != -1)
		{
			DestroyDynamicArea(g_green_zones[idx][GZ_AREA]);
			g_green_zones[idx][GZ_AREA] = -1;
		}

		g_green_zones[idx][GZ_AREA] = CreateDynamicSphere
		(
			g_green_zones[idx][GZ_X], g_green_zones[idx][GZ_Y],
			g_green_zones[idx][GZ_Z], g_green_zones[idx][GZ_SIZE]
		);
	}
	return 1;
}

stock AddGreenZoneToMemory(Float:x, Float:y, Float:z, Float:radius, name[], bool:allow_park = false, bool:no_weapon = true)
{
	if(g_green_zones_loaded >= MAX_GREEN_ZONES)
	{
		return -1;
	}

	new idx = g_green_zones_loaded;
	g_green_zones[idx][GZ_X] = x;
	g_green_zones[idx][GZ_Y] = y;
	g_green_zones[idx][GZ_Z] = z;
	g_green_zones[idx][GZ_SIZE] = radius;
	format(g_green_zones[idx][GZ_NAME], 32, "%s", name);
	g_green_zones[idx][GZ_AREA] = CreateDynamicSphere(x, y, z, radius);
	g_green_zones[idx][GZ_ALLOW_PARK] = allow_park;
	g_green_zones[idx][GZ_NO_WEAPON] = no_weapon;

	g_green_zones_loaded ++;
	return idx;
}
stock GetGreenZoneByArea(areaid)
{
	for(new idx; idx < g_green_zones_loaded; idx ++)
	{
		if(g_green_zones[idx][GZ_AREA] == areaid) return idx;
	}

	return -1;
}

stock GetPlayerGreenZoneVehicle(playerid)
{
	if(IsPlayerInAnyVehicle(playerid)) return GetPlayerVehicleID(playerid);
	return 0;
}

stock GreenZoneBrBonus(playerid, vehicleid, value)
{
	new pvar_value = GetPVarInt(playerid, "player_in_green_zone");

	if(IsPlayerConnected(playerid))
	{
		new fmt_text[128];
	}

	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, 6);

	BS_WriteValue(bitstream, PR_UINT16, vehicleid);
	BS_WriteValue(bitstream, PR_UINT8, value);

	PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
	BS_Delete(bitstream);
	return 1;
}

forward GreenZoneBrBonusOnTimer(playerid, vehicleid);
public GreenZoneBrBonusOnTimer(playerid, vehicleid)
{
	if(!IsPlayerConnected(playerid))
	{
		return 1;
	}

	new pvar_value = GetPVarInt(playerid, "player_in_green_zone");
	if(!pvar_value)
	{
		return 1;
	}

	new current_vehicleid = GetPlayerGreenZoneVehicle(playerid);
	GreenZoneBrBonus(playerid, current_vehicleid, 1);
	if(vehicleid != current_vehicleid) GreenZoneBrBonus(playerid, vehicleid, 1);
	return 1;
}

forward GreenZoneBrBonusOffTimer(playerid, vehicleid);
public GreenZoneBrBonusOffTimer(playerid, vehicleid)
{
	if(!IsPlayerConnected(playerid))
	{
		return 1;
	}

	new pvar_value = GetPVarInt(playerid, "player_in_green_zone");
	if(pvar_value)
	{
		return 1;
	}
	GreenZoneBrBonus(playerid, vehicleid, 0);
	GreenZoneBrBonus(playerid, GetPlayerGreenZoneVehicle(playerid), 0);
	GreenZoneBrBonus(playerid, 0, 0);
	return 1;
}

stock SetPlayerGreenZoneBrBonus(playerid, bool:enabled)
{
	new vehicleid = GetPlayerGreenZoneVehicle(playerid);
	new pvar_value = GetPVarInt(playerid, "player_in_green_zone");
	new stored_vehicleid = GetPVarInt(playerid, "player_green_zone_vehicle");

	if(enabled)
	{
		SetPVarInt(playerid, "player_green_zone_vehicle", vehicleid);
		GreenZoneBrBonus(playerid, vehicleid, 1);
		SetTimerEx("GreenZoneBrBonusOnTimer", 150, false, "ii", playerid, vehicleid);
		SetTimerEx("GreenZoneBrBonusOnTimer", 500, false, "ii", playerid, vehicleid);
		return 1;
	}

	GreenZoneBrBonus(playerid, vehicleid, 0);
	if(stored_vehicleid != vehicleid) GreenZoneBrBonus(playerid, stored_vehicleid, 0);
	if(vehicleid != 0 || stored_vehicleid != 0) GreenZoneBrBonus(playerid, 0, 0);

	SetTimerEx("GreenZoneBrBonusOffTimer", 250, false, "ii", playerid, stored_vehicleid);
	DeletePVar(playerid, "player_green_zone_vehicle");
	return 1;
}

stock ShowAntiDmGreenZonesDialog(playerid)
{
	new fmt_text[4096], item[80], count;
	fmt_text[0] = EOS;

	for(new idx; idx < g_green_zones_loaded; idx ++)
	{
		if(g_green_zones[idx][GZ_SIZE] <= 0.0) continue;

		format(item, sizeof item, "%d. %s\n", idx, g_green_zones[idx][GZ_NAME]);
		strcat(fmt_text, item);
		SetPlayerListitemValue(playerid, count, idx);
		count ++;
	}

	if(!count) strcat(fmt_text, "Зеленые зоны не загружены");
	Dialog(playerid, DIALOG_ANTIDM_ZONES, DIALOG_STYLE_LIST, "{SERVER_NAME} | Зеленые зоны", fmt_text, "Выбрать", "Закрыть");
	return 1;
}

stock ShowAntiDmGreenZoneInfo(playerid, green_zone_id)
{
	if(green_zone_id < 0 || green_zone_id >= g_green_zones_loaded)
	{
		return SendClientMessage(playerid, -1, "Зеленая зона не найдена");
	}

	new fmt_text[256];
	fmt_text[0] = EOS;
	strcat(fmt_text, "{FF0000}Зеленая зона\\n\\n");
	format(fmt_text, sizeof fmt_text, "%s{FFFFFF}Зеленая зона: %s\\n", fmt_text, g_green_zones[green_zone_id][GZ_NAME]);
	format(fmt_text, sizeof fmt_text, "%s{FFFFFF}Координаты: %.2f, %.2f, %.2f\\n", fmt_text, g_green_zones[green_zone_id][GZ_X], g_green_zones[green_zone_id][GZ_Y], g_green_zones[green_zone_id][GZ_Z]);
	format(fmt_text, sizeof fmt_text, "%s{FFFFFF}Радиус: %.2f", fmt_text, g_green_zones[green_zone_id][GZ_SIZE]);

	Dialog(playerid, DIALOG_ANTIDM_INFO, DIALOG_STYLE_MSGBOX, "{FF0000}Зеленая зона", fmt_text, "Назад", "Закрыть");
	return 1;
}

stock LoadGreenZonesFromDB()
{
	new query[128];
	format(query, sizeof query, "SELECT name,x,y,z,radius,allow_park,no_weapon FROM greenzone ORDER BY id ASC");

	new Cache:result = mysql_query(mysql, query, true);
	new mysql_error_code = mysql_errno();
	if(mysql_error_code)
	{
		print("[GreenZone] Failed to load greenzone table");
		cache_delete(result);
		return 0;
	}

	new rows = cache_num_rows(result);
	new loaded;
	for(new row; row < rows && g_green_zones_loaded < MAX_GREEN_ZONES; row ++)
	{
		new name[32];
		new bool:allow_park = false;
		new bool:no_weapon = true;
		new Float:x, Float:y, Float:z, Float:radius;

		cache_get_field_content(row, "name", name, mysql, sizeof name);
		if(cache_get_field_content_int(row, "allow_park")) allow_park = true;
		if(!cache_get_field_content_int(row, "no_weapon")) no_weapon = false;

		x = cache_get_field_content_float(row, "x");
		y = cache_get_field_content_float(row, "y");
		z = cache_get_field_content_float(row, "z");
		radius = cache_get_field_content_float(row, "radius");

		new added_id = AddGreenZoneToMemory(x, y, z, radius, name, allow_park, no_weapon);

		if(added_id != -1) loaded ++;
	}

	if(rows > loaded && g_green_zones_loaded >= MAX_GREEN_ZONES)
	{
	}

	cache_delete(result);
	printf("[GreenZone] Loaded from greenzone: %d", loaded);
	return 1;
}

stock ShowPlayerGreenZoneText(playerid)
{
	new fmt_text[96];

    // -- this is old real russia & fuss rp
	//TextDrawShowForPlayer(playerid, green_zone_TD[0]);
	
	// -- this is new client (fix) zone
	ShowZona(playerid);
	return 1;
}

stock HidePlayerGreenZoneText(playerid)
{
	new fmt_text[96];

    // -- this is old real russia & fuss rp
	//TextDrawHideForPlayer(playerid, green_zone_TD[0]);

	// -- this is new client (fix) zone
	HideZona(playerid);
	return 1;
}
/*public OnPlayerCheat(playerid,code)
{
	new fmt_text[80];

	format(fmt_text, sizeof fmt_text, "[A] Подозрение на читерство: %s[%d] (код: #%d)", GetPlayerNameEx(playerid), playerid, code);
	SendMessageToAdmins(fmt_text, 0xFF5533FF);

	return 1;
}*/

stock IsPlayerUseForbiddenSoftware(playerid)
{
	static const forbidden_soft_keys[][43 + 1] =
	{
		"5E1C1837D2C54B24EAAED18C3F96D9EA51A2A481003", // RakSAMP v0.5-0.3c
		"381356A6B4349449E8F818B06B405A4FBBE9F8DDDAB", // RakSAMP v0.5-0.3d
		"354A1F8D95B8384F9C365E2D7418C7EC06CD6EE2928", // RakSAMP v0.5-0.3eR2
		"38E4952825700FE3B8476C3F72D976E7447905BA45D" // BabaShura 2.6/2.7 (0.3e)
	};

	new player_key[64 + 1];

	gpci(playerid, player_key, sizeof(player_key));

	for(new i = 0; i < sizeof(forbidden_soft_keys); i++)
	{
		if(strcmp(player_key, forbidden_soft_keys[i]) == 0)
		{
			return 1;
		}
	}

	return 0;
}

CMD:setlights(playerid, params[])
{
	if(GetPlayerAdminEx(playerid) != 6) return 1;

	new Float: x,
		Float: y;

	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		if(player_test_label[playerid][0] == Text3D: INVALID_3DTEXT_ID)
		{
			for(new idx; idx < 4; idx ++)
			{
				GetVehicleTurnSignalPos(vehicleid, idx + 1, x, y);

				player_test_label[playerid][idx] = CreateDynamic3DTextLabel(IntToString(idx), 0xFFCC33FF, x, y, 0.0, 10.0, _, vehicleid);
			}
		}
					else
		{
			for(new idx; idx < 4; idx ++)
			{
				DestroyDynamic3DTextLabel(player_test_label[playerid][idx]);

				player_test_label[playerid][idx] = Text3D: INVALID_3DTEXT_ID;
			}
		}
	}
					else SendClientMessage(playerid, -1, "u r not in a vehicle");

	return 1;
}

CMD:setspeed(playerid, params[])
{
	if(GetPlayerAdminEx(playerid) < 5) return 1;

	if(!IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, -1, "u have to be in a vehicle");

	extract params -> new Float: speed; else return SendClientMessage(playerid, -1, "/setspeed [speed]");

	new vehicleid = GetPlayerVehicleID(playerid);

	SetVehicleSpeed(vehicleid, speed);

	return 1;
}

CMD:supercarblya(playerid, params[])
{
	if(GetPlayerAdminEx(playerid) != 6) return 1;

	new supercar = GetPVarInt(playerid, "supercar");

	supercar = supercar ^ 1;

	SetPVarInt(playerid, "supercar", supercar);

	new fmt_text[2][32] =
	{
		"supercar off",
		"supercar on"
	};

	SendClientMessage(playerid, -1, fmt_text[supercar]);

	return 1;
}

CMD:setmultiplier(playerid, params[])
{
	if(GetPlayerAdminEx(playerid) != 6) return 1;

	extract params -> new multiplier; else return SendClientMessage(playerid, -1, "/setmultiplier [mult]");

	SetPVarInt(playerid, "supercar_multiplier", multiplier);

	SendClientMessage(playerid, -1, "multiplier changed");

	return 1;
}

CMD:getvehspeed(playerid, params[])
{
	if(GetPlayerAdminEx(playerid) < 3) return 1;

	extract params -> new vehicleid; else return SendClientMessage(playerid, -1, "/getvehspeed [vehicleid]");

	new Float: speed = GetVehicleSpeed(vehicleid);

	new fmt_text[24];

	format(fmt_text, sizeof fmt_text, "vehicle speed: %f", speed);
	SendClientMessage(playerid, 0xFF5533FF, fmt_text);

	return 1;
}

CMD:pedaltype(playerid, params[])
{
	if(GetPlayerAdminEx(playerid) != 6) return 1;

	new pedal_name[3][] = {"none", "gas", "brake"};

	new pedal_type = player_press_pedal[playerid];

	SendClientMessage(playerid, -1, pedal_name[pedal_type]);

	return 1;
}

CMD:ytpromo(playerid, params[])
{
    if(GetPlayerData(playerid, P_YTPROMO_ACTIVATE) == 1) return Send(playerid, COR_RED, "[Ошибка]: "c_b"Ютуберский промокод можно активировать только один раз!");
    
	Dialog
	(
		playerid, DIALOG_YTPROMO_ACTIVATE, DIALOG_STYLE_INPUT,
		"{FF0000}Промокод",
		"{FFFFFF}Введите промокод для того чтобы получить приз:",
		"Ввести", "Выйти"
	);

	return 1;
}
CMD:promos(playerid, params[])
{
	Dialog
	(
		playerid, DIALOG_PROMO_ACTIVATE, DIALOG_STYLE_INPUT,
		"{FF0000}Промокод",
		"{FFFFFF}Введите промокод для того чтобы получить приз:",
		"Далее", "Отмена"
	);

	return 1;
}
stock ShowPlayerBuyLeadDialog(playerid)
{
//	if(GetPlayerTeamEx(playerid) && GetPlayerJob(playerid) == 10 || GetPlayerData(playerid, P_ADMIN))
//		return SendClientMessage(playerid, -1, "Вы не можете купить лидерку потому что вы уже лидер или администратор!");

    new count, fmt_str[256];
    for(new i = 1; i < MAX_ORG; i++)
    {
    	if(g_organization[i][O_PRICE] != 0 && !strlen(g_organization[i][O_LEADER]))
    	{
    		SetPlayerListitemValue(playerid, count, i);
    		count++;
    		format(fmt_str, sizeof(fmt_str), "%s%s\t{FFFF00}%d {FFFFFF}рублей\n", fmt_str, g_organization[i][O_NAME], g_organization[i][O_PRICE]);
    	}
    }
    if(count == 0) return SendClientMessage(playerid, -1, ""USC"В данный момент нет свободных лидерок.");
    return Dialog(playerid, DIALOG_DRUB_BUYLEAD, DIALOG_STYLE_LIST, "{FFFF00}Список свободных постов лидерства", fmt_str, "Купить", "Назад");

}
stock ShowPlayerBuyZamDialog(playerid)
{
	if(GetPlayerTeamEx(playerid) && GetPlayerJob(playerid) == 10 || GetPlayerData(playerid, P_ADMIN))
		return SendClientMessage(playerid, -1, ""USC"Вы не можете купить 9 ранг потому что вы уже лидер или администратор!");

    new count, fmt_str[256];
    for(new i = 1; i < MAX_ORG; i++)
    {
		SetPlayerListitemValue(playerid, count, i);
		count++;
		format(fmt_str, sizeof(fmt_str), "%s%s\t{FFFF00}%d {FFFFFF}рублей\n", fmt_str, g_organization[i][O_NAME], GetDonatePrice(DONATE_PRICE_ZAM));

		Dialog(playerid, DIALOG_DRUB_BUYZAM, DIALOG_STYLE_LIST, "{FFFF00}Покупка заместителя", fmt_str, "Купить", "Назад");
    }
    return 1;
}
stock ShowPlayerBuyAdminDialog(playerid)
{
	if(GetPlayerAdminEx(playerid) >= 6)
		return SendClientMessage(playerid, -1, ""USC"У вас уже максимальный уровень админ прав");

	new fmt_str[256];

	for(new i = GetPlayerAdminEx(playerid); i < 11; i++)
    {
        format(fmt_str, sizeof(fmt_str), "%s{ffffff}%i уровень\t{FFFF00}%i {FFFFFF}рублей\n",fmt_str, i + 1, ((i + 1) - GetPlayerAdminEx(playerid)) * Config[admin_price]);
    }
    strcat(fmt_str, "12 уровень\t{FFFF00} 2500{FFFFFF} рублей");

    return Dialog(playerid, DIALOG_DRUB_BUYADMIN, DIALOG_STYLE_LIST, "{FFFF00}Покупка админ прав", fmt_str, "Купить", "Назад");
    

}
stock ShowAdminLoginPasswordDialog(playerid)
{
    return SRAdmin_ShowLogin(playerid);
}

stock AdminAuthorization(playerid)
{
    return SRAdmin_ShowLogin(playerid);
}
stock GiveFamilyMoneyEx(fam_id, money)
{

    new fmt_str[185];
    AddFamilyData(fam_id, F_MONEY, +, money);

    format(fmt_str, sizeof fmt_str, "UPDATE family SET money=%d WHERE id=%d LIMIT 1", GetFamilyData(fam_id, F_MONEY), fam_id);
    mysql_query(mysql, fmt_str, false);
    return 1;
}
stock FInvitePlayer(playerid, fam_id, give_rang = 1, bool: save = false)
{
    if(!(1 <= give_rang <= 10))
        give_rang = 1;


    SetPlayerData(playerid, P_FAMILY, fam_id);
    SetPlayerData(playerid, P_FAMILY_RANK, give_rang);

    if(save)
    {
        new query[80];

        format(query, sizeof query, "UPDATE accounts SET family=%d,family_rank=%d WHERE id=%d",\
            GetPlayerData(playerid, P_FAMILY), GetPlayerData(playerid, P_FAMILY_RANK), GetPlayerAccountID(playerid));
        mysql_query(mysql, query, false);
    }

    return 1;
}
stock FUnInvite(playerid, to_player, reason[] = "")
{
    new fmt_msg[110];

    if(playerid != to_player)
    {
        format(fmt_msg, sizeof fmt_msg, "%s[%d] уволил Вас из семьи \"%s\"", GetPlayerNameEx(playerid), playerid, GetFamilyData(GetPlayerData(to_player, P_FAMILY), F_NAME));
        SendClientMessage(to_player, 0xCECECEFF, fmt_msg);

        if(GetPlayerTeamEx(playerid) == GetPlayerTeamEx(to_player))
        {
            format(fmt_msg, sizeof fmt_msg, "Вы уволили %s[%d] из своей семьи", GetPlayerNameEx(to_player), to_player);
            SendClientMessage(playerid, 0x1E90FFFF, fmt_msg);
        }
					else
        {
            format(fmt_msg, sizeof fmt_msg, "Вы уволили %s[%d] из семьи \"%s\"", GetPlayerNameEx(to_player), to_player, GetFamilyData(GetPlayerData(to_player, P_FAMILY), F_NAME));
            SendClientMessage(playerid, 0x1E90FFFF, fmt_msg);
        }

        format(fmt_msg, sizeof fmt_msg, "Уволил %s[acc:%d] из семьи %s. Причина: %s",
        GetPlayerNameEx(to_player), GetPlayerAccountID(to_player), GetFamilyData(GetPlayerData(to_player, P_FAMILY), F_NAME), reason);

        SendLog(playerid, LOG_TYPE_FRACTION, fmt_msg);
    }
					else
    {
        format(fmt_msg, sizeof fmt_msg, "Покинул семью %s по собственному желанию", GetPlayerTeamName(to_player));
        SendLog(to_player, LOG_TYPE_FRACTION, fmt_msg);
    }

    FInvitePlayer(to_player, 0, 0, true);

    return 1;
}
public: LoadFamily()
{
    new idx;
    //new query[85];
    new Cache: result, rows;

    result = mysql_query(mysql, "SELECT * FROM family", true);
    rows = cache_num_rows(result);

    if(rows >= sizeof(g_family))
    {
        rows = sizeof(g_family) - 1;
        printf("[MYSQL][FAMILY] Rows exceeded family pool, capped to %d", rows);
    }


    for(idx = 0; idx < rows; idx ++)
    {
        SetFamilyData(idx+1, F_SQL_ID,        cache_get_field_content_int(idx, "id"));

        cache_get_field_content(idx, "name", g_family[idx+1][F_NAME], mysql, 64);

        SetFamilyData(idx+1, F_USER_ID,       cache_get_field_content_int(idx, "u_id"));
        SetFamilyData(idx+1, F_TIME,          cache_get_field_content_int(idx, "time"));
        SetFamilyData(idx+1, F_COLOR,         cache_get_field_content_int(idx, "color"));
        SetFamilyData(idx+1, F_LEVEL,         cache_get_field_content_int(idx, "level"));
        SetFamilyData(idx+1, F_EXP,           cache_get_field_content_int(idx, "exp"));


        cache_get_field_content(idx, "rank1", g_family[idx+1][F_RANK1], mysql, 32);
        cache_get_field_content(idx, "rank2", g_family[idx+1][F_RANK2], mysql, 32);
        cache_get_field_content(idx, "rank3", g_family[idx+1][F_RANK3], mysql, 32);
        cache_get_field_content(idx, "rank4", g_family[idx+1][F_RANK4], mysql, 32);
        cache_get_field_content(idx, "rank5", g_family[idx+1][F_RANK5], mysql, 32);
        cache_get_field_content(idx, "rank6", g_family[idx+1][F_RANK6], mysql, 32);
        cache_get_field_content(idx, "rank7", g_family[idx+1][F_RANK7], mysql, 32);
        cache_get_field_content(idx, "rank8", g_family[idx+1][F_RANK8], mysql, 32);
        cache_get_field_content(idx, "rank9", g_family[idx+1][F_RANK9], mysql, 32);
        cache_get_field_content(idx, "rank10", g_family[idx+1][F_RANK10], mysql, 32);

        g_family[idx+1][F_SPAWN_POSITION][0] = cache_get_field_content_float(idx, "pos_x");
        g_family[idx+1][F_SPAWN_POSITION][1] = cache_get_field_content_float(idx, "pos_y");
        g_family[idx+1][F_SPAWN_POSITION][2] = cache_get_field_content_float(idx, "pos_z");
        g_family[idx+1][F_SPAWN_POSITION][3] = cache_get_field_content_float(idx, "pos_fa");

        g_family[idx+1][F_SPAWN_IV][0] =    cache_get_field_content_int(idx, "inter");
        g_family[idx+1][F_SPAWN_IV][1] =    cache_get_field_content_int(idx, "world");

        SetFamilyData(idx+1, F_MONEY,         cache_get_field_content_int(idx, "money"));
        SetFamilyData(idx+1, F_DRUGS,         cache_get_field_content_int(idx, "drugs"));
        SetFamilyData(idx+1, F_TREE,          cache_get_field_content_int(idx, "tree"));
        SetFamilyData(idx+1, F_METAL,         cache_get_field_content_int(idx, "metal"));
        SetFamilyData(idx+1, F_AMMO,          cache_get_field_content_int(idx, "ammo"));
        SetFamilyData(idx+1, F_HOUSE_ID,      cache_get_field_content_int(idx, "house_id"));
        SetFamilyData(idx+1, F_OCKIFARMA,          cache_get_field_content_int(idx, "ochki"));
        SetFamilyData(idx+1, F_OCZAVOD,          cache_get_field_content_int(idx, "ochki1"));
        SetFamilyData(idx+1, F_VISHARZ,          cache_get_field_content_int(idx, "ochki2"));
        SetFamilyData(idx+1, F_VISHKAR,          cache_get_field_content_int(idx, "ochki3"));
        SetFamilyData(idx+1, F_VISBUS,          cache_get_field_content_int(idx, "ochki4"));
        
        SetFamilyData(idx+1, F_TAKE_MONEY,	cache_get_field_content_int(idx, "r_TakeMoney"));
		SetFamilyData(idx+1, F_TAKE_DRUGS,	cache_get_field_content_int(idx, "r_TakeDrugs"));
		SetFamilyData(idx+1, F_TAKE_METALL,	cache_get_field_content_int(idx, "r_TakeMetall"));
		SetFamilyData(idx+1, F_TAKE_AMMO,		cache_get_field_content_int(idx, "r_TakeAmmo"));
		SetFamilyData(idx+1, F_RANG_INV,		cache_get_field_content_int(idx, "r_Inv"));
		SetFamilyData(idx+1, F_RANG_UNINV,		cache_get_field_content_int(idx, "r_UnInv"));
		SetFamilyData(idx+1, F_RANG_MUTE,		cache_get_field_content_int(idx, "r_Mute"));
		SetFamilyData(idx+1, F_RANG_UNMUTE,		cache_get_field_content_int(idx, "r_UnMute"));
		SetFamilyData(idx+1, F_RANG_WARN,		cache_get_field_content_int(idx, "r_Warn"));
		SetFamilyData(idx+1, F_RANG_UNWARN,		cache_get_field_content_int(idx, "r_UnWarn"));
		SetFamilyData(idx+1, F_RANG_GIVER,		cache_get_field_content_int(idx, "r_GiveRang"));
		
		SetFamilyData(idx+1, F_FAMILY_CARS,		cache_get_field_content_int(idx, "family_cars"));

        // -------------------------
    }
    g_family_loaded = rows;
    cache_delete(result);

    printf("[Family]: Семьи : %d", g_family_loaded);
	//LoadFamilyCars();
}
stock GetFamilyRang(fam_id, rang_id)
{
    new fmt_rank[32];

    switch(rang_id)
    {
        case 1: format(fmt_rank, sizeof fmt_rank, "%s", g_family[fam_id][F_RANK1]);
        case 2: format(fmt_rank, sizeof fmt_rank, "%s", g_family[fam_id][F_RANK2]);
        case 3: format(fmt_rank, sizeof fmt_rank, "%s", g_family[fam_id][F_RANK3]);
        case 4: format(fmt_rank, sizeof fmt_rank, "%s", g_family[fam_id][F_RANK4]);
        case 5: format(fmt_rank, sizeof fmt_rank, "%s", g_family[fam_id][F_RANK5]);
        case 6: format(fmt_rank, sizeof fmt_rank, "%s", g_family[fam_id][F_RANK6]);
        case 7: format(fmt_rank, sizeof fmt_rank, "%s", g_family[fam_id][F_RANK7]);
        case 8: format(fmt_rank, sizeof fmt_rank, "%s", g_family[fam_id][F_RANK8]);
        case 9: format(fmt_rank, sizeof fmt_rank, "%s", g_family[fam_id][F_RANK9]);
        case 10: format(fmt_rank, sizeof fmt_rank, "%s", g_family[fam_id][F_RANK10]);
        default: format(fmt_rank, sizeof fmt_rank, "%s", g_family[fam_id][F_RANK1]);
    }

    return fmt_rank;
}

stock ShowPayFamilyDialog(playerid)
{
    Dialog
    (
        playerid, DIALOG_PAY_FAMILY, DIALOG_STYLE_INPUT,
        "Банк семьи",
        "{FFFFFF} Введите сумму которую хотите снять с банка семьи",
        "Снять", "Назад"
    );
    return 1;
}

stock ShowChangeRangDialog(playerid)
{
    new fmt_text[1086],
        query[1086],
        fam_id = GetPlayerData(playerid, P_FAMILY);

    format(fmt_text, sizeof fmt_text, "");

    format(query, sizeof query, "{%s}1. %s\n", !strcmp(g_family[fam_id][F_RANK1], "Пусто") ? ("FFFFFF") : ("32a44b"), g_family[fam_id][F_RANK1]);
    strcat(fmt_text, query);
    format(query, sizeof query, "{%s}2. %s\n", !strcmp(g_family[fam_id][F_RANK2], "Пусто") ? ("FFFFFF") : ("32a44b"),g_family[fam_id][F_RANK2]);
    strcat(fmt_text, query);
    format(query, sizeof query, "{%s}3. %s\n", !strcmp(g_family[fam_id][F_RANK3], "Пусто") ? ("FFFFFF") : ("32a44b"),g_family[fam_id][F_RANK3]);
    strcat(fmt_text, query);
    format(query, sizeof query, "{%s}4. %s\n", !strcmp(g_family[fam_id][F_RANK4], "Пусто") ? ("FFFFFF") : ("32a44b"),g_family[fam_id][F_RANK4]);
    strcat(fmt_text, query);
    format(query, sizeof query, "{%s}5. %s\n", !strcmp(g_family[fam_id][F_RANK5], "Пусто") ? ("FFFFFF") : ("32a44b"),g_family[fam_id][F_RANK5]);
    strcat(fmt_text, query);
    format(query, sizeof query, "{%s}6. %s\n", !strcmp(g_family[fam_id][F_RANK6], "Пусто") ? ("FFFFFF") : ("32a44b"),g_family[fam_id][F_RANK6]);
    strcat(fmt_text, query);
    format(query, sizeof query, "{%s}7. %s\n", !strcmp(g_family[fam_id][F_RANK7], "Пусто") ? ("FFFFFF") : ("32a44b"),g_family[fam_id][F_RANK7]);
    strcat(fmt_text, query);
    format(query, sizeof query, "{%s}8. %s\n", !strcmp(g_family[fam_id][F_RANK8], "Пусто") ? ("FFFFFF") : ("32a44b"),g_family[fam_id][F_RANK8]);
    strcat(fmt_text, query);
    format(query, sizeof query, "{%s}9. %s\n", !strcmp(g_family[fam_id][F_RANK9], "Пусто") ? ("FFFFFF") : ("32a44b"),g_family[fam_id][F_RANK9]);
    strcat(fmt_text, query);
    format(query, sizeof query, "{%s}10. %s\n", !strcmp(g_family[fam_id][F_RANK10], "Пусто") ? ("FFFFFF") : ("32a44b"),g_family[fam_id][F_RANK10]);
    strcat(fmt_text, query);

    Dialog
    (
        playerid, DIALOG_FAMILY_RANG, DIALOG_STYLE_LIST,
        "Выберите номер ранга",
        fmt_text,
        "Выбрать", "Отмена"
    );
}
public: ShowFamilyAllPlayers(playerid)
{
    new rows = cache_num_rows();

    new p_name[21];
    new lvl, family_rank;

    new fmt_str[33];
    new text[1290] = "Уровень\tРанг\tИмя\n\n{FFFFFF}";

    new idx, j = rows;
    if(j > 45)
        j = 45;

    for(idx = 0; idx < j; idx ++)
    {
        cache_get_row(idx, 0, p_name);
        lvl = cache_get_row_int(idx, 1);
        family_rank = cache_get_row_int(idx,2);

        format(fmt_str, sizeof fmt_str, "%d\t%d\t%s\n", lvl, family_rank, p_name);
        strcat(text, fmt_str);
    }

    format(fmt_str, sizeof fmt_str, "Показаны %d/%d игроков", idx, rows);
    Dialog(playerid, INVALID_DIALOG_ID, DIALOG_STYLE_MSGBOX, fmt_str, text, "Закрыть", "");
    return 1;
}
stock ShowFamilyInfo(playerid)
{
    new fmt_text[450],
        fam_id = GetPlayerData(playerid, P_FAMILY);

    format(fmt_text, sizeof fmt_text,
    "{FFFFFF}Название: [%s]\n\
    Лидер семьи: %d\n\
     Репутация: [%d (%d/500)]\n\
     Количество людей: скоро\n\
     \t\t\t\n\
      Улучшение склада: скоро\n\
      Улучшение оружья: скоро\n\
      Улучшение состава: скоро\n\
      \t\t\t\n\
      Денег: %s/20000000 рублей\n\
      Материалов: %d кг.\n\
      Масок: скоро\n\
      Канистр с бензином: скоро\n\
      Бронежилеты: скоро\n\
      Патронов:  %f/20000", 
     GetFamilyData(fam_id, F_NAME),
     GetFamilyData(fam_id, F_USER_ID),
     GetFamilyData(fam_id, F_LEVEL),
     GetFamilyData(fam_id, F_MONEY),
     GetFamilyData(fam_id, F_METAL),
     GetFamilyData(fam_id, F_AMMO));
      

    Dialog(playerid, INVALID_DIALOG_ID, DIALOG_STYLE_MSGBOX, "Информация семьи", fmt_text, "Закрыть", "");
}
stock CreateRentZone(Float:pickup_x, Float:pickup_y, Float:pickup_z, const Float:parking[][4], parking_count)
{
    if(TotalRentZones >= MAX_RENT_ZONES)
        return 0;

    if(parking_count < 0)
        return 0;

    if(parking_count > MAX_RENT_ZONE_SLOTS)
        parking_count = MAX_RENT_ZONE_SLOTS;

    new zone_id = TotalRentZones;
    gRentZoneSlotCount[zone_id] = parking_count;

    for(new i; i < parking_count; i++)
    {
        gRentZoneParking[zone_id][i][0] = parking[i][0];
        gRentZoneParking[zone_id][i][1] = parking[i][1];
        gRentZoneParking[zone_id][i][2] = parking[i][2];
        gRentZoneParking[zone_id][i][3] = parking[i][3];
    }

    CreatePickup(19131, 23, pickup_x, pickup_y, pickup_z, -1, PICKUP_ACTION_RENT_BIKE, zone_id);
    CreateDynamic3DTextLabel("{FFFF00}Управление транспортом\n{FFFFFF}Подойдите для взаимодействия", 0x3399FFFF, pickup_x, pickup_y, pickup_z + 0.7, 10.0);

    TotalRentZones++;
    return 1;
}

stock CreateAllRentZones()
{
    TotalRentZones = 0;

    for(new i; i < MAX_RENT_ZONES; i++)
    {
        gRentZoneSlotCount[i] = 0;
    }

    // Зона 0: напротив арз банк
    new Float:zone0_parking[][4] = {
        {357.025543, 545.339538, 11.356398, 320.066497},
        {361.987945, 544.327514, 11.359775, 320.066497},
        {363.969116, 542.170898, 11.362200, 320.066497}
    };
    CreateRentZone(350.904693, 549.723999, 12.048586, zone0_parking, 3);
    
    // Зона 1: дм зона
    new Float:zone1_parking[][4] = {
        {-432.996093, 986.589843, 11.345612, 0.0},
        {-435.928955, 986.341064, 11.346754, 0.0},
        {-438.628448, 986.667846, 11.346678, 0.0}
    };
    CreateRentZone(-367.965332, 1034.463378, 12.188437, zone1_parking, 3);
    
    // Зона 2: болька арз
    new Float:zone2_parking[][4] = {
        {-137.543579, 602.434631, 11.489293, 0.019895},
        {-134.332641, 602.416564, 11.486521, 0.019895},
        {-130.680877, 601.794006, 11.487222, 0.019895}
    };
    CreateRentZone(-307.0077, 582.7009, 12.1576, zone2_parking, 3);
    
    // Зона 3: центр арз около старого спавна
    new Float:zone3_parking[][4] = {
        {-1.598561, 894.797302, 11.354683, 0.0},
        {-6.073462, 896.483886, 11.343715, 0.0},
        {-13.410627, 899.447753, 11.342835, 0.0}
    };
    CreateRentZone(9.033346, 905.089904, 12.039999, zone3_parking, 3);
    
    // Зона 4: жк видный рядом с вкус азбуки
    new Float:zone4_parking[][4] = {
        {75.783210, 523.733886, 7.272441, 0.0},
        {80.630790, 520.062805, 7.270133, 0.0}
    };
    CreateRentZone(65.289085, 484.648803, 12.247041, zone4_parking, 2);
    
    // Зона 5
    new Float:zone5_parking[][4] = {
        {168.183334, 802.838134, 11.190988, 0.0},
        {162.926177, 804.701232, 11.183354, 0.0},
        {156.757934, 808.425292, 11.186182, 0.0}
    };
    CreateRentZone(153.533462, 786.960754, 12.022645, zone5_parking, 3);
    
    // Зона 6
    new Float:zone6_parking[][4] = {
        {425.439147, 1961.223632, 6.991607, 0.0},
        {420.543548, 1950.214477, 7.177172, 0.0}
    };
    CreateRentZone(407.295715, 1953.973388, 8.02815, zone6_parking, 2);
    
    // Зона 7 арз спавн
    new Float:zone7_parking[][4] = {
        {876.830688,853.349975,13.078831, 160.0},
        {881.334594,851.017028,13.078831, 160.0},
        {886.334594,851.017028,13.078831, 160.0}
    };
    CreateRentZone(854.067993, 829.035583, 13.355622, zone7_parking, 3);
    
    // Зона 8
    new Float:zone8_parking[][4] = {
        {915.679626, 1183.514770, 11.166908, 0.0},
        {915.982055, 1187.216186, 11.167666, 0.0}
    };
    CreateRentZone(916.078491, 1175.549072, 12.03999, zone8_parking, 2);
    
    // Зона 9
    new Float:zone9_parking[][4] = {
        {1763.118530, 1319.959350, 9.269132, 0.0},
        {1782.754028, 1319.928344, 9.334574, 0.0},
        {1755.383178, 1326.696899, 9.162875, 0.0}
    };
    CreateRentZone(1751.131347, 1318.834106, 9.884426, zone9_parking, 3);
    
    // Зона 10 батка спавн
    new Float:zone10_parking[][4] = {
        {1783.465454,2506.364013,13.898434, 300.0},
        {1785.862670,2502.969970,13.897919, 300.0},
        {1788.862670,2502.969970,13.897919, 300.0}
    };
    CreateRentZone(1797.571289,2537.010253,14.715876, zone10_parking, 2);
    
    // Зона 11
    new Float:zone11_parking[][4] = {
        {1850.299926, 2241.403320, 14.596689, 270.0},
        {1863.748046,2275.195800,14.503218, 180.0},
        {1869.019775,2276.453125,14.503181, 180.0}
    };
    CreateRentZone(1864.6604, 2236.214355, 15.2938575, zone11_parking, 3);
    
    // Зона 12
    new Float:zone12_parking[][4] = {
        {1830.937133, 2047.242919, 15.049649, 288.557647},
        {1834.393432, 2047.282226, 15.049706, 288.557647}
    };
    CreateRentZone(1913.484619, 2105.423583, 15.748558, zone12_parking, 2);
    
    // Зона 13
    new Float:zone13_parking[][4] = {
        {2356.459472, 1662.968383, 12.900827, 0.0},
        {2355.457031, 1650.754028, 12.904356, 0.0},
        {2355.659912, 1668.685302, 12.906824, 0.0}
    };
    CreateRentZone(2364.12, 1672.38, 13.782, zone13_parking, 3);
    
    // Зона 14
    new Float:zone14_parking[][4] = {
        {-490.892425, -1583.407714, 40.514724, 219.036087},
        {-501.808410, -1561.977661, 40.514705, 219.036087}
    };
    CreateRentZone(-514.327453, -1553.45874, 41.212211, zone14_parking, 2);
    
    // Зона 15
    new Float:zone15_parking[][4] = {
        {-563.179809, 1317.238403, 20.085031, 356.598632},
        {-561.508911, 1319.621215, 20.085033, 356.598632},
        {-560.516296, 1325.389160, 20.085031, 356.598632}
    };
    CreateRentZone(-543.079162, 1336.69519, 20.782188, zone15_parking, 3);
    
    // Зона 16
    new Float:zone16_parking[][4] = {
        {1019.988891, -762.202026, 40.466941, 0.0},
        {1017.283691, -762.834045, 40.467838, 0.0}
    };
    CreateRentZone(1049.339843, -805.09027, 40.926376, zone16_parking, 2);
    
    // Зона 17
    new Float:zone17_parking[][4] = {
        {-2546.535888, 25.292654, 26.669635, 0.0},
        {-2546.662597, 21.648101, 26.645689, 0.0},
        {-2547.009765, 18.444276, 26.643451, 0.0}
    };
    CreateRentZone(-2548.217, 31.2292, 27.8272, zone17_parking, 3);
    
    // Зона 18
    new Float:zone18_parking[][4] = {
        {-2552.967041, -688.004577, 28.923328, 0.0},
        {-2553.080566, -690.658508, 28.923719, 0.0}
    };
    CreateRentZone(-2504.451904, -670.136779, 29.615753, zone18_parking, 2);
    
    // Зона 19 лыт спавн
    new Float:zone19_parking[][4] = {
        {-2460.680419,197.035476,25.712846, 180.0},
        {-2464.192626,197.035476,25.705907, 180.0},
        {-2468.192626,197.035476,25.705907, 180.0}
    };
    CreateRentZone(-2453.884033,193.858535,26.083225, zone19_parking, 3);
    
    // Зона 20
    new Float:zone20_parking[][4] = {
        {-2410.787353, -381.626892, 28.530744, 0.0},
        {-2419.377197, -381.910034, 28.525011, 0.0}
    };
    CreateRentZone(-2388.9938, -380.9628, 29.3748, zone20_parking, 2);
    
    // Зона 21
    new Float:zone21_parking[][4] = {
        {-2383.342041, -15.365154, 25.748033, 0.0},
        {-2383.260009, -24.571958, 25.744874, 0.0},
        {-2383.586425, -36.124206, 25.742206, 0.0}
    };
    CreateRentZone(-2384.036132, -11.653975, 26.452415, zone21_parking, 3);
    
    // Зона 22
    new Float:zone22_parking[][4] = {
        {-2364.098632, -143.050170, 26.108285, 290.806884},
        {-2355.572509, -150.594818, 26.107324, 290.806884}
    };
    CreateRentZone(-2327.6042, -179.3791, 26.8143, zone22_parking, 2);
    
    // Зона 23
    new Float:zone23_parking[][4] = {
        {-2295.674072, -315.473419, 27.073474, 0.0},
        {-2295.323486, -312.022308, 27.065620, 0.0},
        {-2295.929199, -308.219268, 27.050706, 0.0}
    };
    CreateRentZone(-2324.281005, -334.211608, 29.489013, zone23_parking, 3);
    
    // Зона 24
    new Float:zone24_parking[][4] = {
        {-2156.193115, -415.343658, 31.014778, 336.822326},
        {-2157.134033, -407.500213, 30.220062, 336.822326}
    };
    CreateRentZone(-2318.1296, -25.7541, 26.6386, zone24_parking, 2);
    
    // Зона 25
    new Float:zone25_parking[][4] = {
        {-2175.570800, -390.045379, 28.952068, 336.822326},
        {-2160.0, -387.0, 29.2, 0.0},
        {-2164.0, -387.0, 29.2, 0.0}
    };
    CreateRentZone(-2160.4855, -387.0060, 29.1799, zone25_parking, 3);
    
    // Зона 26
    new Float:zone26_parking[][4] = {
        {-879.267028, 2114.925537, 43.905345, 22.277534},
        {-880.287963, 2117.479492, 43.905479, 22.277534}
    };
    CreateRentZone(-900.108, 2116.64, 44.603, zone26_parking, 2);
    
    // Зона 27
    new Float:zone27_parking[][4] = {
        {17.0, 2595.0, 11.0, 180.0},
        {13.0, 2595.0, 11.0, 180.0},
        {9.0, 2595.0, 11.0, 180.0}
    };
    CreateRentZone(13.202734, 2595.515625, 11.033349, zone27_parking, 3);
    
    // Зона 28
    new Float:zone28_parking[][4] = {
        {1404.463134, 434.217254, 12.310567, 45.684692},
        {1407.468505, 432.200012, 12.310555, 45.684692}
    };
    CreateRentZone(1418.231201, 451.798553, 13.203024, zone28_parking, 2);
    
    // Зона 29
    new Float:zone29_parking[][4] = {
        {1588.703857, 2912.960205, 11.345902, 0.0},
        {1583.757812, 2912.573242, 11.345902, 0.0},
        {1581.240844, 2913.660888, 11.345912, 0.0}
    };
    CreateRentZone(1625.361816, 2862.738037, 12.043074, zone29_parking, 3);
    
    // Зона 30
    new Float:zone30_parking[][4] = {
        {2270.945800, -754.690185, 12.721534, 0.0},
        {2273.291748, -755.025024, 12.719165, 0.0}
    };
    CreateRentZone(2250.244384, -704.999145, 13.418662, zone30_parking, 2);
    
    // Зона 31
    new Float:zone31_parking[][4] = {
        {2470.591308, -760.622802, 11.455402, 134.194519},
        {2474.174072, -759.263427, 11.452219, 134.194519},
        {2491.477294, -758.669616, 11.452203, 134.194519}
    };
    CreateRentZone(2488.971679, -721.851867, 12.371512, zone31_parking, 3);
    
    // Зона 32
    new Float:zone32_parking[][4] = {
        {2654.535400, 2605.385009, 15.735348, 0.0},
        {2653.489746, 2607.912109, 15.734820, 0.0}
    };
    CreateRentZone(2611.892578, 2556.426513, 16.431976, zone32_parking, 2);
    
    // Зона 33
    new Float:zone33_parking[][4] = {
        {2781.264648, 773.012817, 30.329101, 0.0},
        {2778.602294, 777.086547, 30.328676, 0.0},
        {2776.735595, 778.949401, 30.328681, 0.0}
    };
    CreateRentZone(2759.591064, 710.692626, 31.025836, zone33_parking, 3);
    
    // Зона 34
    new Float:zone34_parking[][4] = {
        {-1773.123657, 770.681457, 34.765785, 0.0},
        {-1772.729614, 768.228027, 34.757644, 0.0}
    };
    CreateRentZone(-1773.633056, 775.751831, 35.478054, zone34_parking, 2);
    
    // Зона 35
    new Float:zone35_parking[][4] = {
        {2338.077636, -1895.388916, 20.979974, 0.0},
        {2338.409912, -1899.194335, 20.980085, 0.0},
        {2338.178466, -1902.569091, 20.980058, 0.0}
    };
    CreateRentZone(2307.967773, -1902.230468, 21.857826, zone35_parking, 3);
    
    // Зона 36
    new Float:zone36_parking[][4] = {
        {2443.117187, -1957.293090, 21.342844, 0.0},
        {2430.619384, -1937.354980, 21.342802, 0.0}
    };
    CreateRentZone(2454.20581, -1895.52185, 22.00489, zone36_parking, 2);
    
    // Зона 37
    new Float:zone37_parking[][4] = {
        {2585.434082, -2352.081298, 21.220623, 0.0},
        {2585.196289, -2365.320556, 21.220603, 0.0},
        {2584.933349, -2380.011962, 21.220607, 0.0}
    };
    CreateRentZone(2579.350341, -2356.141113, 22.018295, zone37_parking, 3);
    
    // Зона 38
    new Float:zone38_parking[][4] = {
        {2127.541748, -1851.526000, 18.176073, 0.0},
        {2130.666259, -1850.492919, 18.172531, 0.0}
    };
    CreateRentZone(2130.0945, -1821.1962, 18.8213, zone38_parking, 2);
    
    // Зона 39
    new Float:zone39_parking[][4] = {
        {2181.583740, -2066.504150, 18.155315, 200.438858},
        {2181.648437, -2057.434570, 18.155338, 200.438858},
        {2181.670898, -2046.688598, 18.156263, 200.438858}
    };
    CreateRentZone(2181.008056, -2075.055664, 18.8525, zone39_parking, 3);
    
    // Зона 40
    new Float:zone40_parking[][4] = {
        {2201.277587, -1785.879394, 21.106515, 0.0},
        {2201.712402, -1779.130493, 21.135684, 0.0}
    };
    CreateRentZone(2199.051757, -1794.122314, 21.750938, zone40_parking, 2);
    
    // Зона 41
    new Float:zone41_parking[][4] = {
        {2746.754150, -2419.480224, 20.937760, 327.0},
        {2750.877685, -2419.395751, 20.937682, 326.0},
        {2754.877685, -2419.395751, 20.937682, 0.0}
    };
    CreateRentZone(2747.9453, -2424.0908, 21.7732, zone41_parking, 3);
    
    // Зона 42
    new Float:zone42_parking[][4] = {
        {-448.761138, -131.110610, 26.318861, 0.0},
        {-447.428161, -127.819625, 26.269556, 0.0}
    };
    CreateRentZone(-412.289, -131.41, 26.16, zone42_parking, 2);
    
    // Зона 43
    new Float:zone43_parking[][4] = {
        {-2594.225097, 2020.469360, 8.752414, 0.0},
        {-2590.045410, 2020.071655, 8.752386, 0.0},
        {-2585.343261, 2019.603027, 8.764433, 0.0}
    };
    CreateRentZone(-2601.825927,2011.767578,9.544275, zone43_parking, 3);
    
    // Зона 44
    new Float:zone44_parking[][4] = {
        {-2878.079589, 2296.942626, 8.775015, 0.0},
        {-2878.118896, 2299.601318, 8.775834, 0.0}
    };
    CreateRentZone(-2878.04, 2289.915, 9.56, zone44_parking, 2);
    
    // Зона 45
    new Float:zone45_parking[][4] = {
        {-1838.910766, 2722.912841, 56.901092, 0.0},
        {-1840.552490, 2720.644775, 56.901100, 0.0},
        {-1842.819946, 2718.795166, 56.901126, 0.0}
    };
    CreateRentZone(-1834.84, 2718.86, 57.83, zone45_parking, 3);
    
    // Зона 46
    new Float:zone46_parking[][4] = {
        {-1554.268676, 2475.304199, 59.142314, 0.0},
        {-1551.589111, 2476.970703, 59.141750, 0.0}
    };
    CreateRentZone(-1550.06, 2464.37, 59.42, zone46_parking, 2);
    
    // Зона 47
    new Float:zone47_parking[][4] = {
        {-2554.663574, 2252.855468, 57.397514, 0.0},
        {-2554.778564, 2249.854492, 57.397529, 0.0},
        {-2554.719482, 2247.043212, 57.397533, 0.0}
    };
    CreateRentZone(-2569.83, 2256.72, 58.22, zone47_parking, 3);
    
    // Зона 48
    new Float:zone48_parking[][4] = {
        {-2103.520263, 2158.794921, 57.173290, 0.0},
        {-2101.084472, 2158.779785, 57.180633, 0.0}
    };
    CreateRentZone(-2105.49, 2154.61, 57.90, zone48_parking, 2);
    
    // Зона 49
    new Float:zone49_parking[][4] = {
        {-2413.170654, 2621.194091, 57.170944, 0.0},
        {-2410.554931, 2621.178466, 57.170898, 0.0},
        {-2404.241699, 2622.967285, 57.170940, 0.0}
    };
    CreateRentZone(-2389.49, 2628.56, 57.90, zone49_parking, 3);
    
    // Зона 50
    new Float:zone50_parking[][4] = {
        {-2008.375610, 2656.134765, 57.104827, 24.146446},
        {-2011.127563, 2655.294677, 57.105098, 24.146446}
    };
    CreateRentZone(-2002.36, 2654.46, 58.02, zone50_parking, 2);
    
    // Зона 51
    new Float:zone51_parking[][4] = {
        {-1734.476440, 2101.119628, 8.864362, 255.029815},
        {-1734.432128, 2098.407714, 8.858454, 255.029815},
        {-1734.406372, 2095.682617, 8.858474, 255.029815}
    };
    CreateRentZone(-1745.32, 2096.92, 9.55, zone51_parking, 3);
    
    // Зона 52
    new Float:zone52_parking[][4] = {
        {-2159.550048, 1582.649291, 9.782187, 70.876327},
        {-2158.532226, 1585.831420, 9.782187, 74.833435},
        {-2158.093017, 1588.405883, 9.782187, 76.726173}
    };
    CreateRentZone(-2167.869873, 1580.577636, 9.883749, zone52_parking, 3);
    
    // Зона 53
    new Float:zone53_parking[][4] = {
        {-2456.491210, 1311.961791, 9.789999, 82.499603},
        {-2457.640625, 1308.793457, 9.789999, 91.306594},
        {-2457.703857, 1305.706542, 9.790231, 88.293670}
    };
    CreateRentZone(-2448.043457, 1310.810913, 9.891562, zone53_parking, 3);

    // Зона 54
    new Float:zone54_parking[][4] = {
        {-2483.823242, 1099.234008, 9.790249, 260.467468},
        {-2484.591308, 1095.991088, 9.791307, 270.133300},
        {-2482.976806, 1093.219482, 9.792210, 256.167907}
    };
    CreateRentZone(-2492.600097, 1101.740478, 9.901719, zone54_parking, 3);

    // Зона 55
    new Float:zone55_parking[][4] = {
        {-2688.812744, 990.339538, 9.789999, 91.971702},
        {-2688.836914, 992.661132, 9.789999, 96.573570},
        {-2689.408691, 995.231323, 9.789999, 80.640022}
    };
    CreateRentZone(-2667.100097, 991.680297, 9.891562, zone55_parking, 3);

    // Зона 56 (без парковочных мест)
    new Float:zone56_parking[][4] = {
        {432.369201, -1349.224243, 41.149383, 277.061187}
    };
    CreateRentZone(432.369201, -1349.224243, 41.149383, zone56_parking, 0);
    
    // Зона 57: контейнерная парковка
    new Float:zone57_parking[][4] = {
        {611.675292, 1691.160766, 12.162509, 89.072891},
        {612.117675, 1694.490356, 12.162509, 88.153366},
        {612.053833, 1698.455200, 12.162509, 92.536682}
    };
    CreateRentZone(g_cont_reward_park_pickup[0], g_cont_reward_park_pickup[1], g_cont_reward_park_pickup[2], zone57_parking, 3);

    // generated
    new Float:zone58_parking[][4] = {
        {38.708045, 2588.327636, 35.165847, 247.051559},
        {37.937194, 2581.910644, 34.286849, 245.394180},
        {37.184906, 2575.190917, 33.805759, 262.028808}
    };
    CreateRentZone(19.377328, 2595.885742, 38.969520, zone58_parking, 3);

    // generated
    new Float:zone59_parking[][4] = {
        {586.863769, 2674.143798, 13.399374, 230.560195},
        {584.790588, 2670.223144, 13.399374, 235.414367},
        {582.401428, 2666.781738, 13.399374, 235.701980},
        {580.373657, 2662.939697, 13.399374, 234.020217},
        {591.043090, 2680.746337, 13.399374, 246.089462}
    };
    CreateRentZone(646.049072, 2668.893310, 13.516562, zone59_parking, 5);
printf("[Parking] Создано %d зон с парковками", TotalRentZones);
    return 1;
}
stock CreateRentBike()
{
    return CreateAllRentZones();
}
stock ShowPlayerBuyCommandDialog(playerid)
{
	if(GetPlayerAdminEx(playerid) < 9)
		return SendClientMessage(playerid, -1, "Покупка платных команд доступна с 9-ого уровня администратора");

	new big_fmt[568], description[64];
	for(new i; i < sizeof(g_admin_cmd_buy); i ++)
	{
		if(g_player[playerid][CMD_ACCESS][i] != '1') description = "{dd2e13}Не куплено";
            else description = "{23dc1b}Куплено";

		format(big_fmt, sizeof(big_fmt), "%s[%d] %s\t\t%s\t%d Руб\n",big_fmt, i+1, g_admin_cmd_buy[i][CMD_NAME], description, g_admin_cmd_buy[i][CMD_PRICE]);
	}
	Dialog
	(
		playerid, DIALOG_BUY_CMD, DIALOG_STYLE_LIST,
		"Покупка платных комманд",
		big_fmt,
		"Далее", "Отмена"
	);
	return 1;
}
stock GetPlayerAdminCMDAllow(playerid, CMD_id)
{
	if(GetPlayerAdminEx(playerid) < 1) return false;
	
    return (g_player[playerid][CMD_ACCESS][CMD_id]  == '1');
}

/*CMD:aprav(playerid, params[])
{
    if(!GetPlayerAdminEx(playerid)) return 1;

    new fmt_str[2000];

    format
	(
		fmt_str,sizeof fmt_str,
	    "{ffffff}Администраторам сервера запрещается:\n\
	    1. Ненормативная лексика в чат, а особенно в сторону игрока(ов) {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    2. Угрозы игрокам {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    3. Банить/Кикать/Сажать игрока(ов) из личной неприязни {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    4. Банить/Кикать/Сажать игрока(ов) не проследив за ним и не сделав скриншота {FF6600}(Наказание: Предупреждение){ffffff} \n\
	    5. Выдавать игроку(ам) запрещённое оружие {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    6. Игнорить репорт {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    7. Оскорбление других модераторов/администраторов {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    8. Допускать мат/оффтоп/metagaming в /ad,/vipad,/s {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    9. Позволять игрокам оскорбление других игроков {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    10. Просить повышение {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    11. Находиться АФК больше 30 минут {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    12. Флуди или оффтоп в /a {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    13. Флуд или оффтоп в КФ ВК {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    14. Помеха другим администраторам. {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    15. Реклама {FF6600}(Наказание: Лишение админских прав){ffffff} \n\
	    16. ТП или помеха основателям {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    17. Блат кого-то из игроков {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    18. Использавание адм.в личных целях {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    19. Помеха РП процессу {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    20. Влезать в РП процесс {FF6600}(Наказание: ВЫГОВОР!){ffffff} \n\
	    21. Читерить, если ваш админ-лвл ниже 5{FF6600}(Наказание: ВЫГОВОР!){ffffff}"
	);

    Dialog(playerid,INVALID_DIALOG_ID,DIALOG_STYLE_MSGBOX,"{65c8ff}Правила Администраторов:",fmt_str,"Принять","");
    return true;
}
CMD:anak(playerid, params[])
{
    if(!GetPlayerAdminEx(playerid)) return 1;

	new fmt_str[2000];

    format
	(
		fmt_str,sizeof fmt_str,
		"{ffffff}Наказания для правонарушителей:\n\
	    1. Читы - {FF6600}(Наказание: Деморган до 30 мин.){ffffff} \n\
	    2. Оффтоп в любой чат - {FF6600}(Наказание: Мут до 10 мин.){ffffff} \n\
	    3. Metagaming - {FF6600}(Наказание: Мут до 10 мин.){ffffff} \n\
	    4. Powergaming - {FF6600}(Наказание: КПЗ до 15 мин.){ffffff} \n\
	    5. DM - {FF6600}(Наказание: КПЗ до 10 мин.){ffffff} \n\
	    6. DB - {FF6600}(Наказание: КПЗ до 10 мин.){ffffff} \n\
	    7. Реклама сторонних ресурсов - {FF6600}(Наказание: МУТ/БАН!){ffffff} \n\
	    8. Багоюз - {FF6600}(Наказание: КПЗ до 10 мин.){ffffff} \n\
	    9. Попрошайничество - {FF6600}(Наказание: Мут до 10 мин.){ffffff} \n\
	    10. Оскорбления игроков - {FF6600}(Наказание: Мут до 20 мин.){ffffff} \n\
	    11. Оскорбления администраторов - {FF6600}(Наказание: Мут на 60 минут, после бан если не успокоится..){ffffff} \n\
	    12. Оскорбления родителей игрока - {FF6600}(Наказание: Мут > Бан){ffffff} \n\
	    13. Мат в /ad, /vipad, /r, /d, /s, /me, обычный чат - {FF6600}(Наказание: Мут до 10 мин.){ffffff} \n\
	    14. DM в ЗЗ - {FF6600}(Наказание: /warn или КПЗ до 15 мин.){ffffff}\n\
	    15. Срыв Мероприятия - {FF6600}(Наказание: КПЗ до 10 мин.){ffffff}"
	);

    Dialog(playerid, INVALID_DIALOG_ID, DIALOG_STYLE_MSGBOX, "{65c8ff}Нормы наказаний | Команды:",fmt_str,"Принять","");
    return true;
}
CMD:licsog(playerid, params[])
{
    if(!GetPlayerAdminEx(playerid)) return 1;

    new fmt_str[2000];

    format
	(
		fmt_str,sizeof fmt_str,
	    "{ffffff}Лицензионное соглашение:\n\
	    1. Пользуясь административными правами вы полностью потдверждаете то, что вы прочитали лиц.соглашение.. \n\
	    правила проекта,и нормы наказаний и соглашаетесь соблюдать правила/ \n\
	    2. Не соблюдая правила, либо давая наказания не по нормам, вы будете получать выговоры, и будете сняты.. \n\
	    без единого возврата средств. \n\
	    3. Повышения происходит как повторной оплатой, так и отличной работой на админке. (Онлайн +5 стабильно) \n\
	    4. Повышение, или пополнение донат-счета возможно через сайт, либо через основателя проекта [vk.com/id568918059].. \n\
	    если вас кто-то обманул, выдавая себя за основателей проекта. Средства возвращены не будут, а то что вы покупали.. \n\
	    вам предоставлено не будет ! \n\
	    5. Официальный сайт проекта > RUSSIA-MOBILE.RU | Владелец проекта - Alekseevich \n\
	    6. Официальное сообщество проекта > VK.COM/blackrussia.online | Директор проекта - Gromov \n\
	    7. Техническое сообщество проекта > VK.COM/TRUEE.HELP | Разработчик проекта - Oscar\n\
	    8. Если вы не работаете, не отвечаете на репорты, или не отыгрываете норму будьте готовы к снятию.. \n\
	    9. После оплаты всегда сохраняйте чеки, чтобы избежать проблем с получением донат-рублей и прочих услуг \n\
	    10. Если пополнить аккаунт не получается, пишите владельцу проекта. Либо в тех.раздел \n\
	    11. Также, вам запрещено превышать свои полномочия, точнее > Продавать донат-рубли, админ-права..\n\
	    и.т.д | За это вы будете сняты, и добавлены в ЧС проекта, все проданное вами будет удалено."
	);

    Dialog(playerid, INVALID_DIALOG_ID, DIALOG_STYLE_MSGBOX,"{65c8ff}Лицензионное соглашение:",fmt_str,"Принять","");
    return true;
}*/
stock IsBusinessNoEnter(action_id) //автосалоны
{
if(GetBusinessData(action_id, B_TYPE) == 20) return 1;
	switch(GetBusinessData(action_id, B_TYPE))
	{
		case BUSINESS_TYPE_STYLING_CENTER,
		     BUSINESS_TYPE_TECH_CENTER,
		     BUSINESS_TYPE_TIRE_CENTER:
			return 1;
	}
	switch(GetBusinessData(action_id, B_SQL_ID))
	{
		case 31, 32, 33:/*, 34, 35: //34, 35, 36, 37:*/
		{
			return 1;
		}
	}
	return 0;
}

stock IsBusinessNoBuy(action_id) // гостиницы
{

	if(GetBusinessData(action_id, B_TYPE) == BUSINESS_TYPE_CAR_MARKET) return 1;
	switch(GetBusinessData(action_id, B_SQL_ID))
	{
		case 31,32,33:
		{
			return 1;
		}
	}
	return 0;
}


CMD:drugs(playerid, params[])
{
	if(!strlen(params)) return SendClientMessage(playerid, 0xCECECEFF, "Используйте: /drugs [кол-во грамм]");
	
	extract params -> new drugs;
	
	if(!(1 <= drugs <= 3)) return SendClientMessage(playerid, 0xCECECEFF, "Количество грамм от 1 до 3");

	new fmt_msg[256];

	if(GetPlayerData(playerid, P_DRUGS) < drugs) return SendClientMessage(playerid, 0xCECECEFF, "У Вас нет столько наркотиков");

	AddPlayerData(playerid, P_DRUGS, -, drugs);

	new Float:health;
    ApplyAnimation(playerid,"SMOKING","M_smk_drag",4.1,0,0,0,0,0);
	GetPlayerHealth(playerid, health);
	SetPlayerHealthEx(playerid, health + (drugs*20.0));

	SetPlayerWeather(playerid, -68);

	SetTimerEx("DrugEffectGone", 40000, false, "i", playerid);

	Action(playerid, "использовал наркотики", _, false);

	format(fmt_msg, sizeof fmt_msg, "Вы использовали %d грамм(а) наркотиков. Ваше здоровье (%d)", drugs, GetPlayerData(playerid, P_HEALTH));
	SendClientMessage(playerid, 0x32a44bFF, fmt_msg);

	format(fmt_msg, sizeof fmt_msg, "UPDATE accounts SET drugs=%d WHERE id=%d", GetPlayerData(playerid, P_DRUGS), GetPlayerAccountID(playerid));
	mysql_query(mysql, fmt_msg, false);

	return 1;
}
forward FTIMERSEC(playerid);
public FTIMERSEC(playerid)
{
if(GetPVarInt(playerid, "FermaGarelpva")==1)
{
if(minferma>=0)
{
new fmt_text[120];
sicferma--;

TextDrawHideForPlayer(playerid, zakaz3_TD[2]);
format(fmt_text, sizeof(fmt_text), "%d",sicferma);
TextDrawSetString(zakaz3_TD[2], fmt_text); 
TextDrawShowForPlayer(playerid, zakaz3_TD[2]); 

if(sicferma==1)
{
minferma--;
sicferma=59;
if(GetPVarInt(playerid, "FermaGarelpva")==1)
{
TextDrawHideForPlayer(playerid, zakaz3_TD[3]);
format(fmt_text, sizeof(fmt_text), "%d:",minferma);
TextDrawSetString(zakaz3_TD[3], fmt_text); 
TextDrawShowForPlayer(playerid, zakaz3_TD[3]); 
}
}
if(minferma==0 && sicferma==0)
{
KillTimer(timersecfer);
}
}
}
}
forward FTIMERSECVI(playerid);
public FTIMERSECVI(playerid)
{
if(GetPVarInt(playerid, "Zavodpva")==1)
{
if(minzavod>=0)
{
new fmt_text[120];
siczavod--;

TextDrawHideForPlayer(playerid, zakaz3_TD[2]);
format(fmt_text, sizeof(fmt_text), "%d",siczavod);
TextDrawSetString(zakaz3_TD[2], fmt_text); 
TextDrawShowForPlayer(playerid, zakaz3_TD[2]); 

if(siczavod==1)
{
minzavod--;
siczavod=59;
TextDrawHideForPlayer(playerid, zakaz3_TD[3]);
format(fmt_text, sizeof(fmt_text), "%d:",minzavod);
TextDrawSetString(zakaz3_TD[3], fmt_text); 
TextDrawShowForPlayer(playerid, zakaz3_TD[3]); 

}
if(minzavod==0 && siczavod==0)
{
KillTimer(timerzavod);
}
}
}
}
forward ARZERSECVI(playerid);
public ARZERSECVI(playerid)
{
if(GetPVarInt(playerid, "Arzpva")==1)
{
if(minvish>=0)
{
new fmt_text[120];
sicvish--;

TextDrawHideForPlayer(playerid, zakaz3_TD[2]);
format(fmt_text, sizeof(fmt_text), "%d",sicvish);
TextDrawSetString(zakaz3_TD[2], fmt_text); 
TextDrawShowForPlayer(playerid, zakaz3_TD[2]); 

if(sicvish==1)
{
minvish--;
sicvish=59;
TextDrawHideForPlayer(playerid, zakaz3_TD[3]);
format(fmt_text, sizeof(fmt_text), "%d:",minvish);
TextDrawSetString(zakaz3_TD[3], fmt_text); 
TextDrawShowForPlayer(playerid, zakaz3_TD[3]); 
}
if(minvish==0 && sicvish==0)
{
KillTimer(timerarz);
}
}
}
}
//Обновление очков в базе данных
//forward FERMAGAREL();
//Хелпани последний раз


forward FERMAGAREL();
public FERMAGAREL()
{
for(new i=0;i<MAX_PLAYERS;i++)
{
new playerid=i;
if(GetPVarInt(playerid, "FermaGarelpva")==1)
{
    new query[128];
    new fmt_text[128];
    new fam_id = GetPlayerData(playerid, P_FAMILY) + 1;
    
    // Обновление очков игрока и базы данных
    SetPlayerData(playerid, P_OHFAM, GetPlayerData(playerid, P_OHFAM) + 1);
    UpdatePlayerDatabaseInt(playerid, "ocfam", GetPlayerData(playerid, P_OHFAM));
    AddFamilyData(fam_id, F_OCKIFARMA, +, 1);
  
  format(fmt_text, sizeof(fmt_text), "UPDATE family SET ochki=%d WHERE id=%d LIMIT 1", GetFamilyData(fam_id, F_OCKIFARMA), fam_id);
    mysql_query(mysql, fmt_text, false);
    
    // Получение очков семьи игрока
    new Cache: result;
    mysql_format(mysql, query, sizeof query, "SELECT ochki FROM family WHERE id=%d LIMIT 1", fam_id);
    result = mysql_query(mysql, query, true);
    
    if (cache_num_rows(result))
    {
        new ochki = cache_get_field_content_int(0, "ochki");
        cache_delete(result);

        // Обновление текст-драва для очков семьи
        PlayerTextDrawHide(playerid, zakaz3_PTD[playerid][0]);
        format(fmt_text, sizeof(fmt_text), "%d", ochki);
        PlayerTextDrawSetString(playerid, zakaz3_PTD[playerid][0], fmt_text);
        PlayerTextDrawShow(playerid, zakaz3_PTD[playerid][0]);
    }
					else
    {
        cache_delete(result);
    }
    
    // Получение очков лидера
    mysql_format(mysql, query, sizeof query, "SELECT ochki FROM family ORDER BY ochki DESC LIMIT 1");
    result = mysql_query(mysql, query, true);
    
    if (cache_num_rows(result))
    {
        new lider_ochki = cache_get_field_content_int(0, "ochki");
        cache_delete(result);

        // Обновление текст-драва для очков лидера
        TextDrawHideForPlayer(playerid, zakaz3_TD[1]);
        format(fmt_text, sizeof(fmt_text), "%d", lider_ochki);
        TextDrawSetString(zakaz3_TD[1], fmt_text);
        TextDrawShowForPlayer(playerid, zakaz3_TD[1]);
    }
					else
    {
        cache_delete(result);
    }
    }
    }
    }
    forward ZAVODBUSAEVO();
public ZAVODBUSAEVO()
{
for(new i=0;i<MAX_PLAYERS;i++)
{
new playerid=i;
if(GetPVarInt(playerid, "Zavodpva")==1)
{
    new query[128];
    new fmt_text[128];
    new fam_id = GetPlayerData(playerid, P_FAMILY) + 1;
    
    // Обновление очков игрока и базы данных
    SetPlayerData(playerid, P_OHZAVOD, GetPlayerData(playerid, P_OHZAVOD) + 1);
    UpdatePlayerDatabaseInt(playerid, "oczav", GetPlayerData(playerid, P_OHZAVOD));
    AddFamilyData(fam_id, F_OCZAVOD, +, 1);
  
  format(fmt_text, sizeof(fmt_text), "UPDATE family SET ochki1=%d WHERE id=%d LIMIT 1", GetFamilyData(fam_id, F_OCZAVOD), fam_id);
    mysql_query(mysql, fmt_text, false);
    
    // Получение очков семьи игрока
    new Cache: result;
    mysql_format(mysql, query, sizeof query, "SELECT ochki1 FROM family WHERE id=%d LIMIT 1", fam_id);
    result = mysql_query(mysql, query, true);
    
    if (cache_num_rows(result))
    {
        new ochki = cache_get_field_content_int(0, "ochki1");
        cache_delete(result);

        // Обновление текст-драва для очков семьи
        PlayerTextDrawHide(playerid, zakaz3_PTD[playerid][0]);
        format(fmt_text, sizeof(fmt_text), "%d", ochki);
        PlayerTextDrawSetString(playerid, zakaz3_PTD[playerid][0], fmt_text);
        PlayerTextDrawShow(playerid, zakaz3_PTD[playerid][0]);
    }
					else
    {
        cache_delete(result);
    }
    
    // Получение очков лидера
    mysql_format(mysql, query, sizeof query, "SELECT ochki1 FROM family ORDER BY ochki1 DESC LIMIT 1");
    result = mysql_query(mysql, query, true);
    
    if (cache_num_rows(result))
    {
        new lider_ochki = cache_get_field_content_int(0, "ochki1");
        cache_delete(result);

        // Обновление текст-драва для очков лидера
        TextDrawHideForPlayer(playerid, zakaz3_TD[1]);
        format(fmt_text, sizeof(fmt_text), "%d", lider_ochki);
        TextDrawSetString(zakaz3_TD[1], fmt_text);
        TextDrawShowForPlayer(playerid, zakaz3_TD[1]);
    }
					else
    {
        cache_delete(result);
    }
    }
    }
    }
    forward ARZVISHKA();
public ARZVISHKA()
{
for(new i=0;i<MAX_PLAYERS;i++)
{
new playerid=i;
if(GetPVarInt(playerid, "Arzpva")==1)
{
    new query[128];
    new fmt_text[128];
    new fam_id = GetPlayerData(playerid, P_FAMILY) + 1;
    
    // Обновление очков игрока и базы данных
    SetPlayerData(playerid, P_OHARZ, GetPlayerData(playerid, P_OHARZ) + 1);
    UpdatePlayerDatabaseInt(playerid, "ocarz", GetPlayerData(playerid, P_OHARZ));
    AddFamilyData(fam_id, F_VISHARZ, +, 1);
  
  format(fmt_text, sizeof(fmt_text), "UPDATE family SET ochki2=%d WHERE id=%d LIMIT 1", GetFamilyData(fam_id, F_VISHARZ), fam_id);
    mysql_query(mysql, fmt_text, false);
    
    // Получение очков семьи игрока
    new Cache: result;
    mysql_format(mysql, query, sizeof query, "SELECT ochki2 FROM family WHERE id=%d LIMIT 1", fam_id);
    result = mysql_query(mysql, query, true);
    
    if (cache_num_rows(result))
    {
        new ochki = cache_get_field_content_int(0, "ochki2");
        cache_delete(result);

        // Обновление текст-драва для очков семьи
        PlayerTextDrawHide(playerid, zakaz3_PTD[playerid][0]);
        format(fmt_text, sizeof(fmt_text), "%d", ochki);
        PlayerTextDrawSetString(playerid, zakaz3_PTD[playerid][0], fmt_text);
        PlayerTextDrawShow(playerid, zakaz3_PTD[playerid][0]);
    }
					else
    {
        cache_delete(result);
    }
    
    // Получение очков лидера
    mysql_format(mysql, query, sizeof query, "SELECT ochki2 FROM family ORDER BY ochki2 DESC LIMIT 1");
    result = mysql_query(mysql, query, true);
    
    if (cache_num_rows(result))
    {
        new lider_ochki = cache_get_field_content_int(0, "ochki1");
        cache_delete(result);

        // Обновление текст-драва для очков лидера
        TextDrawHideForPlayer(playerid, zakaz3_TD[1]);
        format(fmt_text, sizeof(fmt_text), "%d", lider_ochki);
        TextDrawSetString(zakaz3_TD[1], fmt_text);
        TextDrawShowForPlayer(playerid, zakaz3_TD[1]);
    }
					else
    {
        cache_delete(result);
    }
    }
    }
    }
    forward KARAKVISHKA();
public KARAKVISHKA()
{
for(new i=0;i<MAX_PLAYERS;i++)
{
new playerid=i;
if(GetPVarInt(playerid, "Karakpva")==1)
{
    new query[128];
    new fmt_text[128];
    new fam_id = GetPlayerData(playerid, P_FAMILY) + 1;
    
    // Обновление очков игрока и базы данных
    SetPlayerData(playerid, P_OHKAR, GetPlayerData(playerid, P_OHKAR) + 1);
    UpdatePlayerDatabaseInt(playerid, "ockar", GetPlayerData(playerid, P_OHKAR));
    AddFamilyData(fam_id, F_OCKIFARMA, +, 1);
  
  format(fmt_text, sizeof(fmt_text), "UPDATE family SET ochki3=%d WHERE id=%d LIMIT 1", GetFamilyData(fam_id, F_VISHKAR), fam_id);
    mysql_query(mysql, fmt_text, false);
    
    // Получение очков семьи игрока
    new Cache: result;
    mysql_format(mysql, query, sizeof query, "SELECT ochki3 FROM family WHERE id=%d LIMIT 1", fam_id);
    result = mysql_query(mysql, query, true);
    
    if (cache_num_rows(result))
    {
        new ochki = cache_get_field_content_int(0, "ochki3");
        cache_delete(result);

        // Обновление текст-драва для очков семьи
        PlayerTextDrawHide(playerid, zakaz3_PTD[playerid][0]);
        format(fmt_text, sizeof(fmt_text), "%d", ochki);
        PlayerTextDrawSetString(playerid, zakaz3_PTD[playerid][0], fmt_text);
        PlayerTextDrawShow(playerid, zakaz3_PTD[playerid][0]);
    }
					else
    {
        cache_delete(result);
    }
    
    // Получение очков лидера
    mysql_format(mysql, query, sizeof query, "SELECT ochki3 FROM family ORDER BY ochki3 DESC LIMIT 1");
    result = mysql_query(mysql, query, true);
    
    if (cache_num_rows(result))
    {
        new lider_ochki = cache_get_field_content_int(0, "ochki3");
        cache_delete(result);

        // Обновление текст-драва для очков лидера
        TextDrawHideForPlayer(playerid, zakaz3_TD[1]);
        format(fmt_text, sizeof(fmt_text), "%d", lider_ochki);
        TextDrawSetString(zakaz3_TD[1], fmt_text);
        TextDrawShowForPlayer(playerid, zakaz3_TD[1]);
    }
					else
    {
        cache_delete(result);
    }
    }
    }
    }
    forward GARELVISHKA();
public GARELVISHKA()
{
for(new i=0;i<MAX_PLAYERS;i++)
{
new playerid=i;
if(GetPVarInt(playerid, "Garelpva")==1)
{
    new query[128];
    new fmt_text[128];
    new fam_id = GetPlayerData(playerid, P_FAMILY) + 1;
    
    // Обновление очков игрока и базы данных
    SetPlayerData(playerid, P_OHBUS, GetPlayerData(playerid, P_OHBUS) + 1);
    UpdatePlayerDatabaseInt(playerid, "ocbus", GetPlayerData(playerid, P_OHBUS));
    AddFamilyData(fam_id, F_VISBUS, +, 1);
  
  format(fmt_text, sizeof(fmt_text), "UPDATE family SET ochki4=%d WHERE id=%d LIMIT 1", GetFamilyData(fam_id, F_VISBUS), fam_id);
    mysql_query(mysql, fmt_text, false);
    
    // Получение очков семьи игрока
    new Cache: result;
    mysql_format(mysql, query, sizeof query, "SELECT ochki4 FROM family WHERE id=%d LIMIT 1", fam_id);
    result = mysql_query(mysql, query, true);
    
    if (cache_num_rows(result))
    {
        new ochki = cache_get_field_content_int(0, "ochki4");
        cache_delete(result);

        // Обновление текст-драва для очков семьи
        PlayerTextDrawHide(playerid, zakaz3_PTD[playerid][0]);
        format(fmt_text, sizeof(fmt_text), "%d", ochki);
        PlayerTextDrawSetString(playerid, zakaz3_PTD[playerid][0], fmt_text);
        PlayerTextDrawShow(playerid, zakaz3_PTD[playerid][0]);
    }
					else
    {
        cache_delete(result);
    }
    
    // Получение очков лидера
    mysql_format(mysql, query, sizeof query, "SELECT ochki4 FROM family ORDER BY ochki4 DESC LIMIT 1");
    result = mysql_query(mysql, query, true);
    
    if (cache_num_rows(result))
    {
        new lider_ochki = cache_get_field_content_int(0, "ochki4");
        cache_delete(result);

        // Обновление текст-драва для очков лидера
        TextDrawHideForPlayer(playerid, zakaz3_TD[1]);
        format(fmt_text, sizeof(fmt_text), "%d", lider_ochki);
        TextDrawSetString(zakaz3_TD[1], fmt_text);
        TextDrawShowForPlayer(playerid, zakaz3_TD[1]);
    }
					else
    {
        cache_delete(result);
    }
    }
    }
    }
forward DrugEffectGone(playerid);
public DrugEffectGone(playerid)
{
    new time[3];
    new pogoda;

    gettime(time[0], time[1], time[2]);
    SetPlayerTime(playerid, time[0], time[1]);
    SetPlayerWeather(playerid, pogoda);
    SetPlayerDrunkLevel(playerid, 0);
    return 1;
}

stock CreateQuestPickup()
{
	for(new idx; idx < sizeof quest_pos; idx ++)
	{
		CreatePickup(1276, 23, quest_pos[idx][0], quest_pos[idx][1], quest_pos[idx][2], -1, PICKUP_ACTION_QUEST_MENU, idx);
		CreateDynamic3DTextLabel(""c_i"Квесты", COR_SERVER, quest_pos[idx][0], quest_pos[idx][1], quest_pos[idx][2] + 0.7, 9.5);
	}
}
stock GromovLohAndPidr(playerid)
{
	Dialog(playerid,0,DIALOG_STYLE_MSGBOX,"","Пусть удача не подводит,\nЗа тобою следом ходит,\nНе теряй в глазах огня!\nС 23 Февраля!","Принять","");
	return 1;
}
stock ShowPlayerQuest23(playerid)
{
	Dialog(playerid,0,DIALOG_STYLE_MSGBOX,"","Здравия желаю боец,\nУ меня для тебя есть пару вопросов для проверки твоих знаний.\n\nЕсли ответишь на них правильно то получишь приз\nНаграда: 15 DRUB","Принять","Отмена");
	return 1;
}

stock ShowPlayerQuestMenuFrac(playerid)
{
	new fmt_text[700];

	format
	(
		fmt_text,
		sizeof fmt_text,
		""c_server"[1] "c_b"Невиновные люди должный быть на свободе| %s\n"\
		""c_server"[2] "c_b"Мы лучще всех | %s\n"\
		""c_server"[3] "c_b"Преступники должный быть в тюрьме | %s\n"\
		""c_server"[4] "c_b"Радиостанция на связи | %s\n"\
		""c_server"[5] "c_b"Люди должный жить | %s",
		GetPlayerData(playerid, P_F_QUEST_1) ? ("{32CD32}Выполнено") : ("{F81414}Не выполнено"),
		GetPlayerData(playerid, P_F_QUEST_2) ? ("{32CD32}Выполнено") : ("{F81414}Не выполнено"),
		GetPlayerData(playerid, P_F_QUEST_3) ? ("{32CD32}Выполнено") : ("{F81414}Не выполнено"),
		GetPlayerData(playerid, P_F_QUEST_4) ? ("{32CD32}Выполнено") : ("{F81414}Не выполнено"),
		GetPlayerData(playerid, P_F_QUEST_5) ? ("{32CD32}Выполнено") : ("{F81414}Не выполнено")
	);

	Dialog
	(
		playerid, DIALOG_ACTION_F_QUEST, DIALOG_STYLE_LIST,
		"Квесты",
		fmt_text,
		"Выбрать", "Закрыть"
	);

	return 1;
}
stock ShowPlayerQuestMenu(playerid)
{
    new fmt_text[1024];

    format(
        fmt_text, sizeof fmt_text,
        ""c_server"1. "c_b"Первые деньги\t\t\t\t%s\n"\
        ""c_server"2. "c_b"Получить водительские права\t\t\t\t%s\n"\
        ""c_server"3. "c_b"Приобрести телефон\t\t\t\t%s\n"\
        ""c_server"4. "c_b"Тяжелая профессия\t\t\t\t%s\n"\
        ""c_server"5. "c_b"Устроиться на официальную работу\t\t\t\t%s\n"\
        ""c_server"6. "c_b"Вступить во фракцию\t\t\t\t%s\n"\
        ""c_server"7. "c_b"Вступить в семью\t\t\t\t%s\n"\
        ""c_server"8. "c_b"Приобрести первый автомобиль\t\t\t\t%s\n",
        GetPlayerData(playerid, P_QUEST_1) ? "{FFFF00}Выполнено" : "{32CD32}Доступно",
        GetPlayerData(playerid, P_QUEST_2) ? "{FFFF00}Выполнено" : "{32CD32}Доступно",
        GetPlayerData(playerid, P_QUEST_3) ? "{FFFF00}Выполнено" : "{32CD32}Доступно",
        GetPlayerData(playerid, P_QUEST_4) ? "{FFFF00}Выполнено" : "{32CD32}Доступно",
        GetPlayerData(playerid, P_QUEST_5) ? "{FFFF00}Выполнено" : "{32CD32}Доступно",
        GetPlayerData(playerid, P_QUEST_6) ? "{FFFF00}Выполнено" : "{32CD32}Доступно",
        GetPlayerData(playerid, P_QUEST_7) ? "{FFFF00}Выполнено" : "{32CD32}Доступно",
        GetPlayerData(playerid, P_QUEST_8) ? "{FFFF00}Выполнено" : "{32CD32}Доступно"
    );

    Dialog(
        playerid, DIALOG_ACTION_QUEST, DIALOG_STYLE_LIST,
        "{FFFF00}" SERVER_NAME "{ffffff} | Квесты",
        fmt_text,
        "Выбрать", "Закрыть"
    );

    return 1;
}

CMD:quest(playerid)
{
	ShowPlayerQuestMenu(playerid);
}

CMD:vleave(playerid, params[])
{
	if(GetPlayerData(playerid, P_IMPROVEMENTS) < 2) return SendClientMessage(playerid, 0x999999FF, "Приобретите улучшение \"Решительность\", чтобы уволиться по собственному желанию");

	if(!GetPlayerTeamEx(playerid)) return ShowNotificationNew(playerid, 2, 3, 0, 0, "Вы не состоите в организации", "");

	new fmt_text[999];

	format
	(
		fmt_text, sizeof fmt_text,
		""SC"Ваша организация{ffff00}: \"%s\".\n\n"\
		"{ffffff}Вы действительно хотите покинуть данную организацию по\n"\
		"{ffffff}собственному желанию?",
		GetTeamName(GetPlayerTeamEx(playerid))
	);

	Dialog(playerid, DIALOG_TEAM_LEAVE, DIALOG_STYLE_MSGBOX, "{00FFFF}"SERVER_NAME" {ffffff}| Подтверждение", fmt_text, "Далее", "Отмена");

	return 1;
}

CMD:unj(playerid)
{
	if(!GetPlayerPremium(playerid) || GetPlayerData(playerid, P_UNJ)) return SendClientMessage(playerid, 0xCECECEFF, "У Вас нет VIP, или вы уже воспользовались командой ранее");
    if(GetPlayerPremium(playerid) == 2)
	{
		SetPlayerData(playerid, P_JAIL ,GetPlayerData(playerid, P_JAIL) / 2);
	}
					else if(GetPlayerPremium(playerid) == 3)
	{
		SetPlayerData(playerid, P_JAIL ,GetPlayerData(playerid, P_JAIL) / 3);
	}
    SetPlayerData(playerid, P_UNJ, 1);
    UpdatePlayerDatabaseInt(playerid, "unj", GetPlayerData(playerid, P_UNJ));
    SendClientMessage(playerid, 0xCECECEFF, "Вы уменьшили срок тюрьмы!");
	return 1;
}

CMD:setpremium(playerid, params[])
{
	if(GetPlayerAdminEx(playerid) < 6) return 1;

	extract params -> new to_player, premium; else return SendClientMessage(playerid, 0xCECECEFF, "Используйте: /setpremium [id игрока] [время (в днях)]");

	if(!IsPlayerConnected(to_player) || !IsPlayerLogged(to_player))
		return SendClientMessage(playerid, 0xCECECEFF, "Такого игрока нет");

	if(!(0 <= premium <= 30)) return SendClientMessage(playerid, 0xCECECEFF, "Количество дней от 0 до 30");

	new fmt_msg[100];

	SetPlayerData(to_player, P_PREMIUM, gettime() + premium * 86400);

	UpdatePlayerDatabaseInt(to_player, "premium", GetPlayerData(to_player, P_PREMIUM));

	format(fmt_msg, sizeof fmt_msg, "%s выдал Вам подписку "SERVER_NAME"+ на %d дн.", GetPlayerNameEx(playerid), premium);
	SendClientMessage(to_player, 0x1E90FFFF, fmt_msg);

	format(fmt_msg, sizeof fmt_msg, "Вы выдали %s подписку "SERVER_NAME"+ на %d дн.", GetPlayerNameEx(to_player), premium);
	SendClientMessage(playerid, 0x1E90FFFF, fmt_msg);

	format(fmt_msg, sizeof fmt_msg, "Установил %s[acc:%d] подписку "SERVER_NAME"+ на %d дн.", GetPlayerNameEx(to_player), GetPlayerAccountID(to_player), premium);
	SendLog(playerid, LOG_TYPE_ADMIN_ACTION, fmt_msg);

	return 1;
}

CMD:togphone(playerid, params[])
{
	if(!GetPlayerPhone(playerid))
		return SendClientMessage(playerid, 0xCECECEFF, "У Вас нет телефона. Его можно купить в 24/7");
	if(!GetPlayerPremium(playerid))
	    return   SendClientMessage(playerid, 0xCECECEFF, "У Вас нет VIP аккаунта.");

	if(GetPlayerPhoneCall(playerid, PC_INCOMING_PLAYER) != INVALID_PLAYER_ID || GetPlayerPhoneCall(playerid, PC_OUTCOMING_PLAYER) != INVALID_PLAYER_ID)
		return SendClientMessage(playerid, 0xCECECEFF, "Закончите текущий разговор");

	if(GetPlayerPhoneCall(playerid, PC_ENABLED))
	{
		SetPlayerPhoneCall(playerid, PC_ENABLED, false);
		SendClientMessage(playerid, 0xCECECEFF, "Телефон отключен");
	}
					else
	{
		SetPlayerPhoneCall(playerid, PC_ENABLED, true);
		SendClientMessage(playerid, 0x32a44bFF, "Телефон включен");
	}
	return 1;
}

stock bool:IsPlayerVipActive(playerid)
{
    if(!IsPlayerConnected(playerid)) return false;
    if(GetPlayerPremium(playerid) < 1) return false;

    new premium_date = GetPlayerData(playerid, P_PREMIUM_DATE);
    new premium_time = GetPlayerData(playerid, P_PREMIUM_TIME);

    if(premium_date <= 0 && premium_time <= 0) return true;
    if(premium_date > gettime()) return true;
    if(premium_time > gettime()) return true;

    return false;
}
CMD:v(playerid, params[])
{
    if(GetPlayerPremium(playerid) < 1)
        return SendClientMessage(playerid, 0xCECECEFF, "У Вас нет VIP аккаунта ");
    else if(IsPlayerMuted(playerid) > 0)
        return SendClientMessage(playerid, 0xCECECEFF, "Доступ в чат заблокирован. Время до разблокировки: {66CC33}/time");
    else if(!strlen(params))
        return SendClientMessage(playerid, 0xCECECEFF, "Используйте: /v [текст]");

    new fmt_msg[144];
    new prefix[32];

    switch(GetPlayerPremium(playerid))
    {
        case 1: format(prefix, sizeof prefix, "[VIP Silver]");
        case 2: format(prefix, sizeof prefix, "[VIP Gold]");
        case 3: format(prefix, sizeof prefix, "[VIP Platinum]");
        default: format(prefix, sizeof prefix, "[VIP]");
    }

    format(fmt_msg, sizeof fmt_msg, "%s %s[%d]: %s", prefix, GetPlayerNameEx(playerid), playerid, params);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        if(!IsPlayerLogged(i)) continue;
        if(!GetPlayerPremium(i)) continue;
        if(!GetPlayerData(i, P_PREMIUM_CHAT)) continue;

        SendClientMessage(i, COLOR_YELLOW, fmt_msg);
    }
    return 1;
}

CMD:voff(playerid, params[])
{
	if(!IsPlayerVipActive(playerid)) return SendClientMessage(playerid, 0xCECECEFF, "У Вас нет VIP аккаунта ");
	if(GetPlayerData(playerid, P_PREMIUM_CHAT))
	{
		SendClientMessage(playerid,-1,"Вы отключили VIP чат");
		SetPlayerData(playerid, P_PREMIUM_CHAT, 0);
		return 1;
	}
	if(!GetPlayerData(playerid, P_PREMIUM_CHAT))
	{
		SendClientMessage(playerid,-1,"Вы включили VIP чат");
		SetPlayerData(playerid, P_PREMIUM_CHAT, 1);
		return 1;
	}
	return 1;
}

/*public AntiBH(playerid)
{
	ApplyAnimation(playerid,"PED","getup_front",4.0,0,0,0,0,0);
	times[playerid] = false;

	SetTimerEx("AntiBH1",1500,false,"i",playerid);

	return 1;
}
public AntiBH1(playerid)
{
	times[playerid] = true;
}
*/

CMD:rub(playerid)
{
	if(!GetPlayerAdminEx(playerid))
	{
		new status;
		status = (GetPlayerData(playerid, P_GET_RUB) ^ VEHICLE_PARAM_ON);

		SetPlayerData(playerid, P_GET_RUB, status);

		format(stringer, sizeof(stringer), "{FF9A30}Вы успешно %s функцию '+%d руб каждый час'", GetPlayerData(playerid, P_GET_RUB) ? ("{32CD32}включили{FFFFFF}") : ("{FF0000}выключили{FFFFFF}"), Config[sDistRub]);
        SendClientMessage(playerid, 0xB8FF1AFF, stringer);
        return 1;
	}
	return SendClientMessage(playerid, -1, "Данная функция недоступна администраторам!");
}

stock FD(playerid)
{
    mysql_format(mysql, str, 250, "SELECT * FROM `full_dostup` WHERE name = '%s'", GetPlayerNameEx(playerid));
    mysql_query(mysql, str, true);

    if(cache_num_rows(result))
    	return 1;
    else
    	return 0;
}

CMD:so(playerid, params[])
{
	if(GetPlayerHelperEx(playerid) >= 1)
	{
		if(!strlen(params))
			return SendClientMessage(playerid, 0xCECECEFF, "Используйте: /so [текст]");

		new fmt_str[128];

		format(fmt_str, sizeof fmt_str, "[S] Хелпер %s[%d]: %s", GetPlayerNameEx(playerid), playerid, params);
		SendMessageToHelpers(fmt_str, 0x99CC00FF);

	}

	return 1;
}

stock ShowPlayerReportMenuDialog(playerid)
{
    if(AntiTimerReport(playerid)) return true;
    Dialog(playerid, DIALOG_ADMINCALL_MENU, DIALOG_STYLE_LIST,
        "{6666CC}Связь с администрацией и поддержкой",
        "1 - Обращение к администрации\n2 - Вопрос агентам поддержки",
        "Выбрать", "Закрыть");
    return 1;
    new fmt_text[50];

    format
    (
        fmt_text,
        sizeof fmt_text,
        "{B5A8FF}Отправить жалобу\n"\
        "{B5A8FF}Отправить вопрос\n"
    );

    Dialog
    (
        playerid, DIALOG_ADMINCALL_MENU, DIALOG_STYLE_LIST,
        "{6666CC}Связь с администрацией",
        fmt_text,
        "Выбрать", "Закрыть"
    );

    return 1;
}

CMD:vipad(playerid, params[])
{
    if(GetPlayerPremium(playerid) < 1) return Send(playerid,-1,"У вас нет VIP Аккаунта");
    

    if(AntiTimerVipad(playerid)) return true;

    if(GetPlayerPhone(playerid) != 0)
	{
		if(GetPlayerMoneyEx(playerid) >= 50000)
		{
			if(!strlen(params))
				return SendClientMessage(playerid, 0xCECECEFF, "Используйте: /vipad [текст]");

			extract params -> new string: message[144 + 1];

			if(IsAIP(message))
			{
	       		SendClientMessage(playerid, -1, "Подозрения в рекламе!");
	        	return false;
	    	}

			new fmt_str[128];

			GivePlayerMoneyEx(playerid, -50000, "vip объява", true, true);

			format(fmt_str, sizeof fmt_str, "Truee Russia | "c_b"%s[%d]: %s Тел: %d", GetPlayerNameEx(playerid), playerid, message, GetPlayerPhone(playerid));
			SendClientMessageToAll(0xFF9945FF, fmt_str);
			PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);



		}
					else
			return SendClientMessage(playerid, -1, "У Вас недостаточно денег, нужно 50.000$");
		
    }
					else SendClientMessage(playerid, 0x999999FF, "У Вас нет телефона. Его можно купить в 24/7");

	return 1;
}

stock SellDebtorsHome()
{
	new query[800];
	for(new i; i < g_house_loaded; i ++)
	{
		new house_owner_id = GetHouseData(i, H_OWNER_ID);
		if(house_owner_id > 0)
		{
			new cur_time = gettime();
			new rent_time = (cur_time - (cur_time % 86400)) + (30 * 86400);

			if(GetHouseData(i, H_RENT_DATE) != rent_time)
			{
				SetHouseData(i, H_RENT_DATE, rent_time);
				format(query, sizeof query, "UPDATE houses SET rent_time=%d WHERE id=%d LIMIT 1", rent_time, GetHouseData(i, H_SQL_ID));
				mysql_query(mysql, query, false);
			}
			continue;
		}

		if(GetHouseData(i, H_RENT_DATE) < gettime())
		{
		    new owner_id = GetHouseData(i, H_OWNER_ID);

			if(owner_id == 0) continue;


			format(query, sizeof query, "UPDATE accounts a,houses h SET `house`=-1,`house_room`=-1,`house_type`=-1, h.owner_id='0', h.lock='0', h.rent_time='0' WHERE a.id=h.owner_id AND h.id='%d'", GetHouseData(i, H_SQL_ID));
			mysql_query(mysql, query, false);

			new Cache: result, owner_name[21];

			mysql_format(mysql, query, sizeof query, "SELECT * FROM accounts WHERE id=%d LIMIT 1", owner_id);
			result = mysql_query(mysql, query);

			if(cache_num_rows(result))
				cache_get_field_content(0, "name", owner_name, mysql, 21);
			cache_delete(result);

			new owner_player = GetPlayerIDBySqlID(owner_id);
			if(IsPlayerConnected(owner_player) && IsPlayerLogged(owner_player)) {
                SetPlayerData(owner_player, P_HOUSE, -1);
                SetPlayerData(owner_player, P_HOUSE_ROOM, -1);
                SetPlayerData(owner_player, P_HOUSE_TYPE, -1);
                mysql_format(mysql, query, sizeof query, "UPDATE accounts SET `house`=-1,`house_room`=-1,`house_type`=-1 WHERE `id`=%d LIMIT 1", GetPlayerAccountID(owner_player));
				mysql_query(mysql, query, false);
			}
					else {
				mysql_format(mysql, query, sizeof query, "UPDATE accounts SET `house`=-1,`house_room`=-1,`house_type`=-1 WHERE `id`=%d LIMIT 1", owner_id);
				mysql_query(mysql, query, false);
			}
			SetHouseData(i, H_OWNER_ID, 0);
			SetHouseData(i, H_IMPROVEMENTS,		0);

			SetHouseData(i, H_RENT_DATE,		0);
			SetHouseData(i, H_LOCK_STATUS,		false);

			format(query, sizeof query, "UPDATE houses SET `owner_id`=0,`store_x`=0.0,`store_y`=0.0,`store_z`=0.0,`store_metall`=0,`store_drugs`=0,`store_weapon`=0,`store_ammo`=0,`store_skin`=0,`lock`=0 WHERE id=%d", GetHouseData(i, H_SQL_ID));
			mysql_query(mysql, query, false);

			
			UpdateHouse(i);

			HouseHealthInit(i);
			HouseStoreInit(i);

			new fmt_text[256];

			new description[64];

			description = "слет дома";

			format
			(
				fmt_text, sizeof fmt_text,
				"INSERT INTO return_money \
				(uid, money, description, status)\
				VALUES ('%d', '%d', '%s', 0)",
				owner_id,
				GetHouseData(i, H_PRICE) / 2,
				description
			);

			mysql_query(mysql, fmt_text, true);
		}
	}
//	return 1;
}

stock SellDebtorsBusiness()
{
	new query[400];
	for(new i; i < g_business_loaded; i ++)
	{
		if(GetBusinessData(i, B_RENT_DATE) < gettime())
		{
		    new owner_id = GetBusinessData(i, B_OWNER_ID);
		    if(owner_id == 0) continue;

			format(query, sizeof query, "UPDATE accounts a,business b SET a.business=-1,b.owner_id=0,b.products=0,b.prod_price=0,b.lock=0,b.rent_time=0 WHERE a.id=b.owner_id AND b.id=%d", GetBusinessData(i, B_SQL_ID));
			mysql_query(mysql, query, false);

			format(query, sizeof query, "DELETE FROM `business_gps` WHERE id = '%d'", i);
			mysql_query(mysql, query, false);
			new Cache: result, owner_name[21];

			mysql_format(mysql, query, sizeof query, "SELECT * FROM accounts WHERE id=%d LIMIT 1", owner_id);
			result = mysql_query(mysql, query);

			if(cache_num_rows(result))
				cache_get_field_content(0, "name", owner_name, mysql, 21);
			cache_delete(result);

			format(query, sizeof query, "UPDATE accounts a,business b SET a.business=-1,b.owner_id=0,b.name='',b.products=0,b.prod_price=0,b.lock=0 WHERE a.id=%d AND b.id=%d", owner_id, GetBusinessData(i, B_SQL_ID));
			mysql_query(mysql, query, false);
			new owner_player = GetPlayerIDBySqlID(owner_id);
			if(IsPlayerConnected(owner_player) && IsPlayerLogged(owner_player)) {
				SetPlayerData(owner_player, P_BUSINESS, -1);
                mysql_format(mysql, query, sizeof query, "UPDATE accounts SET `business`=-1 WHERE `id`=%d LIMIT 1", GetPlayerAccountID(owner_player));
				mysql_query(mysql, query, false);
			}
					else {
			    mysql_format(mysql, query, sizeof query, "UPDATE accounts SET `business`=-1 WHERE `id`=%d LIMIT 1", owner_id);
				mysql_query(mysql, query, false);
			}
			SetBusinessData(i, B_OWNER_ID, 0);
			SetBusinessData(i, B_IMPROVEMENTS, 		0);

			SetBusinessData(i, B_PRODS, 			0);
			SetBusinessData(i, B_PROD_PRICE,		0);

			SetBusinessData(i, B_BALANCE,			0);
			SetBusinessData(i, B_RENT_DATE,			0);
			SetBusinessData(i, B_ENTER_MUSIC,		0);
			SetBusinessData(i, B_LOCK_STATUS,		false);

			BusinessHealthPickupInit(i);

			format(query, sizeof query, "DELETE FROM business_gps WHERE bid=%d", i);
			mysql_query(mysql, query, false);

			g_business_gps_init = false;

			CallLocalFunction("UpdateBusinessLabel", "i", i);

			new fmt_text[256];

			new description[64];

			description = "слет бизнеса";

			format
			(
				fmt_text, sizeof fmt_text,
				"INSERT INTO return_money \
				(uid, money, description, status)\
				VALUES ('%d', '%d', '%s', 0)",
				owner_id,
				GetBusinessData(i, B_PRICE) / 2,
				description
			);

			mysql_query(mysql, fmt_text, true);
		}
	}
//	return 1;
}
stock SellDebtorsFuel()
{
	new query[400];
	for(new i; i < g_fuel_station_loaded; i ++)
	{

		if(GetFuelStationData(i, FS_RENT_DATE) < gettime())
		{
			new owner_id = GetFuelStationData(i, FS_OWNER_ID);

			if(owner_id == 0) continue;

			format(query, sizeof query, "UPDATE accounts a,fuel_stations f SET a.fuel_st=-1,f.owner_id=0,f.fuels=1000,f.fuel_price=3,f.lock=0,f.rent_time=0 WHERE a.id=f.owner_id AND f.id=%d", GetFuelStationData(i, FS_SQL_ID));
			mysql_query(mysql, query, false);

			new Cache: result, owner_name[21];

			mysql_format(mysql, query, sizeof query, "SELECT * FROM accounts WHERE id=%d LIMIT 1", owner_id);
			result = mysql_query(mysql, query);

			if(cache_num_rows(result))
				cache_get_field_content(0, "name", owner_name, mysql, 21);
			cache_delete(result);

			new owner_player = GetPlayerIDBySqlID(owner_id);
			if(IsPlayerConnected(owner_player) && IsPlayerLogged(owner_player)) {
	            SetPlayerData(owner_player, P_FUEL_ST, -1);
				format(query, sizeof query, "UPDATE accounts SET `fuel_st`=-1 WHERE `id`=%d LIMIT 1", GetPlayerAccountID(owner_player));
				mysql_query(mysql, query, false);
			}
					else {
				format(query, sizeof query, "UPDATE accounts SET `fuel_st`=-1 WHERE `id`=%d LIMIT 1", owner_id);
				mysql_query(mysql, query, false);
			}

			SetFuelStationData(i, FS_OWNER_ID, 0);
			SetFuelStationData(i, FS_IMPROVEMENTS, 0);

			SetFuelStationData(i, FS_FUELS, 		1000);
			SetFuelStationData(i, FS_FUEL_PRICE,	3);
			SetFuelStationData(i, FS_BUY_FUEL_PRICE,0);

			SetFuelStationData(i, FS_BALANCE,		0);
			SetFuelStationData(i, FS_RENT_DATE,		0);
			SetFuelStationData(i, FS_LOCK_STATUS,	false);

			CallLocalFunction("UpdateFuelStationLabel", "i", i);

			new fmt_text[256];

			new description[64];

			description = "слет АЗС";

			format
			(
				fmt_text, sizeof fmt_text,
				"INSERT INTO return_money \
				(uid, money, description, status)\
				VALUES ('%d', '%d', '%s', 0)",
				owner_id,
				GetFuelStationData(i, FS_PRICE) / 10,
				description
			);

			mysql_query(mysql, fmt_text, true);
		}
	}
//	return 1;
}

CMD:slethouse(playerid)
{
    
	if(GetPlayerAdminEx(playerid) < 6) return 1;

	//SendClientMessageToAll(-1,"тест слет всего!");
	SellDebtorsHome();

	return 1;
}

CMD:slet(playerid)
{
    
	if(GetPlayerAdminEx(playerid) < 6) return 1;

	//SendClientMessageToAll(-1,"тест слет всего!");
	SellDebtorsHome();
    SellDebtorsFuel();
	SellDebtorsBusiness();

	return 1;
}

stock CreateFractionCar()
{
	for(new i = 0; i < sizeof(g_org_car); i++)
    {
        format(sctring, sizeof(sctring), "{fcd000}(%s) \n\n Подойдите для взаимодействия \n с авторпарком организации", g_org_car[i][O_NAME]);
        CreateDynamic3DTextLabel(sctring, -1, g_org_car[i][O_PICKUP][0], g_org_car[i][O_PICKUP][1], g_org_car[i][O_PICKUP][2], 15.0);
        g_org_car[i][O_PICKUP_ID] = CreatePickup(19131, 23, g_org_car[i][O_PICKUP][0], g_org_car[i][O_PICKUP][1], g_org_car[i][O_PICKUP][2], 0, PICKUP_ACTION_TYPE_ORG_CAR, i);
    }
    printf("Загружено  пикапов авто %d штук", sizeof(g_org_car));
}

stock IsAIP(const text[])
{
    new numbers;
    for(new i = 0; i < strlen(text); i++) if('0' <= text[i] <= '9') if(!('0' <= text[i+1] <= '9')) numbers ++;
    if(numbers >= 4) return 1;
    return 0;
}

stock AntiTimerAdminNakaz(playerid)
{
    if(use_commad_time[playerid][adm_nakaz] > gettime())
        return SendClientMessage(playerid, -1, "Команду можно использовать раз в 60 секунд");

    use_commad_time[playerid][adm_nakaz] = gettime()+60;
    
    return false;
}

stock AntiTimerVipad(playerid)
{
    if(use_commad_time[playerid][vipad] > gettime())
        return SendClientMessage(playerid, -1, "Команду можно использовать раз в 5 минут");

    use_commad_time[playerid][adm_nakaz] = gettime()+300;

    return false;
}

stock AntiTimerReport(playerid)
{
    if(use_commad_time[playerid][report] > gettime())
        return SendClientMessage(playerid, -1, "Команду можно использовать раз в минуту");

    use_commad_time[playerid][adm_nakaz] = gettime()+60;

    return false;
}

stock AntiSliv(playerid, action[])
{
    if(GetPlayerData(playerid, P_ANTISLIV) > gettime())
    {
        SendClientMessage(playerid, -1, "{FFFF00}[!]{FFFFFF} Ошибка, ваши админ действия заблокированы!");

      	format(sctring, sizeof(sctring), "{FFFF00}[!]{FFFFFF} %s [%d] Подозрение на слив аккаунта (действие %s)", GetPlayerNameEx(playerid), playerid, action);
      	SendMessageToAdmins(sctring, 0x999999FF);
        return true;
    }
    g_player[playerid][P_ANTISLIV] = gettime() + 15;
    UpdatePlayerDatabaseInt(playerid, "antisliv", GetPlayerData(playerid, P_ANTISLIV));
    return false;
}

public: DonateQiwi(playerid, response_code, data[])
{
    if(response_code == 200)
    {
        SendClientMessage(playerid, -1, "Донат найден!");
        if(strfind(data, "success", true) != -1)
        {
            SendClientMessage(playerid, -1, "Донат оплачен!");

            new Cache:result;
            mysql_format(mysql, sctring, sizeof(sctring), "SELECT * FROM `payments` WHERE `user_id` = '%d' AND `status` = 1 LIMIT 1", GetPlayerAccountID(playerid));
            result = mysql_query(mysql, sctring, true);
            if(cache_num_rows(result))
            {

                new sum,id_pay;
                id_pay = cache_get_field_content_int(0, "id");
                sum = cache_get_field_content_int(0, "sum");

                mysql_format(mysql, sctring, sizeof(sctring), "UPDATE `payments` SET `status` = 2 WHERE `id` = '%d'", id_pay);
                mysql_query(mysql, sctring, false);

                format(sctring, sizeof(sctring), "{0099CC}Ваш баланс успешно пополнен на {FFD700}%i рублей! (QIWI)", sum);
                SendClientMessage(playerid, -1, sctring);

                if(Config[sDonPower] != 1)
                {
                    format(sctring, sizeof(sctring), "{0099CC}С учетом акции (X%d) на аккаунт зачислено {FFD700}%i рублей!",Config[sDonPower], sum*Config[sDonPower]);
                    SendClientMessage(playerid, -1, sctring);
                }
                GivePlayerDonateRub(playerid, sum*Config[sDonPower], "Донат QIWI");
                cache_delete(result);
                return 1;
            }
        }
    }
					else
    {
    	format(sctring, sizeof(sctring), "Пополнения по QIWI не найдены: (code: %d)", response_code);
        SendClientMessage(playerid, 0x999999FF, sctring);
    }
    return 1;
}


