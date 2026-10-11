#define MAX_BJ_LOBBY 6

#define BLACK_JACK 61 // для олд и нев движка

// если заменка ОЛД или НЕВ то нужно добавить в IPacket:ВАШ АЙДИ ПАКЕТА(playerid, BitStream:bs) 
// в case 13: (чаще всего он) добавить ко всем пхожим
/*
                    case BLACK_JACK:
					{
					    callcmd::blackjack(playerid);
					}
*/

#define SCM 	SendClientMessage
#define SCMTA   SendClientMessageToAll
#define SPD     ShowPlayerDialog
//------------------------------------------------------------------------------
#define	DSI	DIALOG_STYLE_INPUT
#define DSM	DIALOG_STYLE_MSGBOX
#define DSL	DIALOG_STYLE_LIST
#define DSP	DIALOG_STYLE_PASSWORD
#define DST	DIALOG_STYLE_TABLIST
//------------------------------------------------------------------------------
#define CWHITE 		0xFFFFFFFF
#define CYELLOW 	0xFFFF00FF
#define CLRED    	0xFF3030FF
//------------------------------------------------------------------------------
#define CW          "{FFFFFF}"
#define CR          "{FF0000}"
#define CP          "{FF00FF}"
#define CB          "{00FFFF}"
#define CY          "{FFFF00}"
#define CG	        "{00FF00}"
#define CO          "{FF8000}"
#define CLR         "{FF3030}"
//------------------------------------------------------------------------------

forward ShowNotificationNew(playerid, type, duration, id, subId, caption[], btnCaption[]);

// Оружейные системы подключаются после объявления g_player и необходимых forward.
#include "../include/weapon.inc"
#include "../include/weapon_shop.inc"
#include "../include/firesystem.inc"


// V11 extinguisher visual fallback: some mobile clients do not render the
// native white extinguisher stream.  This is visual-only and does not touch
// damage, fire progress, inventory, vehicle sync or tuning.
#define FIRE_EXT_VISUAL_MODEL (18687)
new STREAMER_TAG_OBJECT:g_fire_ext_visual[MAX_PLAYERS];
new bool:g_fire_ext_visual_active[MAX_PLAYERS];

stock FireExtVisual_Stop(playerid)
{
    if(g_fire_ext_visual_active[playerid])
    {
        if(IsValidDynamicObject(g_fire_ext_visual[playerid]))
        {
            DestroyDynamicObject(g_fire_ext_visual[playerid]);
        }
        g_fire_ext_visual[playerid] = STREAMER_TAG_OBJECT:INVALID_STREAMER_ID;
        g_fire_ext_visual_active[playerid] = false;
    }
    return 1;
}

stock FireExtVisual_Update(playerid)
{
    if(!IsPlayerConnected(playerid))
        return 0;

    new keys, updown, leftright;
    GetPlayerKeys(playerid, keys, updown, leftright);

    new bool:should_show =
        (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) &&
        (GetPlayerWeapon(playerid) == FIRE_WEAPON_EXTINGUISHER) &&
        ((keys & KEY_FIRE) != 0) &&
        (FireSystemGetWeaponAmmo(playerid, FIRE_WEAPON_EXTINGUISHER) > 0);

    if(!should_show)
    {
        if(g_fire_ext_visual_active[playerid])
            FireExtVisual_Stop(playerid);
        return 1;
    }

    if(!g_fire_ext_visual_active[playerid] || !IsValidDynamicObject(g_fire_ext_visual[playerid]))
    {
        FireExtVisual_Stop(playerid);

        g_fire_ext_visual[playerid] = CreateDynamicObject(
            FIRE_EXT_VISUAL_MODEL,
            0.0, 0.0, -1000.0,
            0.0, 0.0, 0.0,
            GetPlayerVirtualWorld(playerid),
            GetPlayerInterior(playerid),
            playerid,
            120.0
        );

        if(IsValidDynamicObject(g_fire_ext_visual[playerid]))
        {
            // Keep the particle slightly in front/right of the player's torso,
            // visually matching the extinguisher nozzle on mobile clients.
            AttachDynamicObjectToPlayer(
                g_fire_ext_visual[playerid],
                playerid,
                0.22, 0.62, 0.72,
                0.0, 0.0, 0.0
            );
            g_fire_ext_visual_active[playerid] = true;
        }
    }
    return 1;
}

stock BJSetPlayerCleanChat(playerid, clean)
{
    new BitStream:bitstream = BS_New();
    BS_WriteValue(bitstream, PR_UINT8, 0);
    BS_WriteValue(bitstream, PR_UINT8, clean);
    PR_SendRPC(bitstream, playerid, 168, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bitstream);
    return 1;
}

new Text:bj_fon;

new Text:bj_double;
new Text:bj_stop;
new Text:bj_play;
new Text:bj_take;
new Text:bj_exit;
new Text:bj_dealer_score;
new Text:bj_help;

new Text:bj_log_text[MAX_BJ_LOBBY][2];
new Text:bj_table_ready[MAX_BJ_LOBBY][5];

new Text:bj_text_bet[2];
new Text:bj_text_start_time;
new Text:bj_text_start_timer[MAX_BJ_LOBBY];

new Text:bj_text_bj_table[MAX_BJ_LOBBY][4];
new Text:bj_text_point_table[MAX_BJ_LOBBY][4];

new Text:bj_dealer_card[MAX_BJ_LOBBY][4];
new Text:bj_result_table[MAX_BJ_LOBBY][4];

new PlayerText:bj_bet[MAX_PLAYERS]; // Ставка
new PlayerText:bj_money[MAX_PLAYERS]; // Деньги игрока

new PlayerText:bj_dealer_point[MAX_PLAYERS];

new PlayerText:bj_members_name[MAX_PLAYERS][4]; // Ники игроков

new PlayerText:bj_card_table[MAX_PLAYERS][5][4]; // Карты игрока

new PlayerText:bj_panel_info[MAX_PLAYERS];

new Text3D: BlackJackText[MAX_BJ_LOBBY];

new Float:BlackJackPos[MAX_BJ_LOBBY][3] =
{
	{2508.235595,2464.847900,2500.593750},
	{2512.765136,2461.914306,2500.593750},
	{2509.275878,2455.723876,2500.593750},
	{2514.574462,2455.245849,2500.593750},
	{2512.811523,2448.583984,2500.593750},
	{2508.137207,2445.757812,2500.593750}
};

new BlackJackSphere[MAX_BJ_LOBBY]; // массив для ID сфер

enum BJ_Card_struct
{
	Pointscore,
	Cardtexture[32]
}

// взял у кбаса
new BlackJackCard[13][4][BJ_Card_struct] =
{
	{{2, "txd:cards2c"}, {2, "txd:cards2d"}, {2, "txd:cards2h"}, {2, "txd:cards2s"}}, //двойки
	{{3, "txd:cards3c"}, {3, "txd:cards3d"}, {3, "txd:cards3h"}, {3, "txd:cards3s"}}, //тройки
	{{4, "txd:cards4c"}, {4, "txd:cards4d"}, {4, "txd:cards4h"}, {4, "txd:cards4s"}}, //четверки
	{{5, "txd:cards5c"}, {5, "txd:cards5d"}, {5, "txd:cards5h"}, {5, "txd:cards5s"}}, //пятерки
	{{6, "txd:cards6c"}, {6, "txd:cards6d"}, {6, "txd:cards6h"}, {6, "txd:cards6s"}}, //шестерки
	{{7, "txd:cards7c"}, {7, "txd:cards7d"}, {7, "txd:cards7h"}, {7, "txd:cards7s"}}, //семерки
	{{8, "txd:cards8c"}, {8, "txd:cards8d"}, {8, "txd:cards8h"}, {8, "txd:cards8s"}}, //восьмерки
	{{9, "txd:cards9c"}, {9, "txd:cards9d"}, {9, "txd:cards9h"}, {9, "txd:cards9s"}}, //девятки
	{{10, "txd:cards10c"}, {10, "txd:cards10d"}, {10, "txd:cards10h"}, {10, "txd:cards10s"}}, //десятки

	{{10, "txd:cardsjc"}, {10, "txd:cardsjd"}, {10, "txd:cardsjh"}, {10, "txd:cardsjs"}}, //валет
	{{10, "txd:cardsqc"}, {10, "txd:cardsqd"}, {10, "txd:cardsqh"}, {10, "txd:cardsqs"}}, //дама
	{{10, "txd:cardskc"}, {10, "txd:cardskd"}, {10, "txd:cardskh"}, {10, "txd:cardsks"}}, //король
	{{11, "txd:cardsac"}, {11, "txd:cardsad"}, {11, "txd:cardsah"}, {11, "txd:cardsas"}}  //туз
};


enum BJ_Lobby
{
	bool:ActivedLobby,
	bool:StartedLobby,
	StartTimer,
	StageLobby,
	DealerPoint,

	DealerTurnGived,
	TableTurn,
	TableTurnTime,

	Table1Id,
	Table2Id,
	Table3Id,
	Table4Id,

	Table1Point,
	Table2Point,
	Table3Point,
	Table4Point,

	Table1Result,
	Table2Result,
	Table3Result,
	Table4Result,
}
new BlackJackLobby[MAX_BJ_LOBBY][BJ_Lobby];

enum P_BJ_Info
{
	bool:OnLobby,
	pBJLobby,
	pBJTable,
	pBJBet,

	pBJBehindSlot,

	pBJTakedCard,
}
new pBJInfo[MAX_PLAYERS][P_BJ_Info];

//==============================================================================

public OnPlayerDisconnect(playerid, reason)
{
	if(pBJInfo[playerid][OnLobby] == true)
	{
	    switch(pBJInfo[playerid][pBJTable])
	    {
	        case 1: { BlackJackLobby[pBJInfo[playerid][pBJLobby]][Table1Id] = -1; BlackJackLobby[pBJInfo[playerid][pBJLobby]][Table1Point] = 0; }
	        case 2: { BlackJackLobby[pBJInfo[playerid][pBJLobby]][Table2Id] = -1; BlackJackLobby[pBJInfo[playerid][pBJLobby]][Table2Point] = 0; }
	        case 3: { BlackJackLobby[pBJInfo[playerid][pBJLobby]][Table3Id] = -1; BlackJackLobby[pBJInfo[playerid][pBJLobby]][Table3Point] = 0; }
	        case 4: { BlackJackLobby[pBJInfo[playerid][pBJLobby]][Table4Id] = -1; BlackJackLobby[pBJInfo[playerid][pBJLobby]][Table4Point] = 0; }
	    }
	    pBJInfo[playerid][pBJTable] = 0;
	    pBJInfo[playerid][pBJLobby] = 10;
	    pBJInfo[playerid][OnLobby] = false;
	    

	}
	#if defined blackjack_OnPlayerDisconnect
        return blackjack_OnPlayerDisconnect(playerid, reason);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerDisconnect
    #undef OnPlayerDisconnect
#else
    #define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect blackjack_OnPlayerDisconnect
#if defined blackjack_OnPlayerDisconnect
    forward blackjack_OnPlayerDisconnect(playerid, reason);
#endif

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == bj_help)
    {
		SendClientMessage(playerid, 0xFFFFFFFF, "");
        CancelSelectTextDraw(playerid);

        new str[1024];
        format(str, sizeof str,
		  	"BLACKJACK (Черный Валет) - одна из самых популярных карточных игр.\n"\
			"Задача игрока - набрать большее количество очков чем дилер, но не больше 21.\n"\
			"Помните, что игрок, набравший больше 21 очка сразу проигрывает игру,\n"\
			"за исключением ничьи с дилером (Если у дилера тоже больше 21 очка).\n"\
			"Вначале игры каждому участнику будут выданы по 2 карты. В последствии игрок может решить,\n"\
			"брать ему карту или нет, воспользовавшись кнопками: 'Взять' или 'Хватит' соответственно.\n");

  		format(str, sizeof str, "%s"\
			"Если при раздаче двух карт игроку выпало 21 очко - он получил BLACKJACK, но не стоит радоваться,\n"\
			"ведь BLACKJACK может получить и дилер, а значит Вы сыграете вничью! \n"\
			"В зависимости от карт, Вы можете удвоить Вашу ставку. \n"\
			"В этом случае Вам будет выдана одна карта, а ставка будет увеличена в два раза. \n"\
			"Также, если первой картой Дилера будет ТУЗ, Вы можете застраховать свою ставку за половину суммы. \n", str);
		format(str, sizeof str, "%s"\
			"В случае, если у дилера будет BLАCKJАCK, Вы получите все деньги назад, но если у дилера не будет 21 очка - Вы проиграете всё.\n"\
			"Желаем Вам успехов в карточном деле! Играйте и выигрывайте!", str);

        SPD(playerid, 19998, DSM,"{FF6347}Помощь", str, "Закрыть", "");
        return 1;
    }
	if(clickedid == bj_play)
    {
		SendClientMessage(playerid, 0xFFFFFFFF, "");
        SPD(playerid, 19999, DSI, "{FF6347}BlackJack", "Введите сумму ставки: от 1000 до 500000000 рублей.", "Играть", "Закрыть");
        return 1;
    }

    if(clickedid == bj_double)
	{
		SendClientMessage(playerid, 0xFFFFFFFF, "");
	    new lobby = pBJInfo[playerid][pBJLobby];
	    if(BlackJackLobby[lobby][TableTurn] == pBJInfo[playerid][pBJTable])
	    {
	        if(GetPlayerMoneyEx(playerid) < pBJInfo[playerid][pBJBet])
			{
				0;
				ShowNotificationNew(playerid, 2, 5, 1, 1, "У Вас недостаточно средств чтобы удвоить ставку.", "");
				return 1;
			}

            new strTD[67];
            format(strTD, sizeof(strTD), "%s удвоил ставку", GetPlayerNameEx(playerid));

			TextDrawSetString(bj_log_text[lobby][0], strTD);
			TextDrawColor(bj_log_text[lobby][0], -65281);

			if(BlackJackLobby[lobby][Table1Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_log_text[lobby][0]);
			if(BlackJackLobby[lobby][Table2Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_log_text[lobby][0]);
			if(BlackJackLobby[lobby][Table3Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_log_text[lobby][0]);
			if(BlackJackLobby[lobby][Table4Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_log_text[lobby][0]);

			GivePlayerMoneyBjEx(playerid, -pBJInfo[playerid][pBJBet]);
			pBJInfo[playerid][pBJBet] = pBJInfo[playerid][pBJBet]*2;

			new str[15];
			format(str, sizeof str, "%d py?", pBJInfo[playerid][pBJBet]);
			PlayerTextDrawSetString(playerid, bj_bet[playerid], str);

			format(str, sizeof str, "%d py?", GetPlayerMoneyEx(playerid));
			PlayerTextDrawSetString(playerid, bj_money[playerid], str);


	        switch(pBJInfo[playerid][pBJTable])
			{
			    case 1:
			    {
					new suit = random(13);
					new type = random(4);

					BlackJackLobby[lobby][Table1Point] += BlackJackCard[suit][type][Pointscore];

					format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table1Point]);
					TextDrawSetString(bj_text_point_table[lobby][0], str);

					ShowMembersCardBJL(lobby, 1, 2+pBJInfo[playerid][pBJTakedCard], suit, type);

			    	pBJInfo[playerid][pBJTakedCard]++;
     				CheckTableBlackJack(lobby, 1);
			    }
			    case 2:
			    {
					new suit = random(13);
					new type = random(4);

					BlackJackLobby[lobby][Table2Point] += BlackJackCard[suit][type][Pointscore];

					format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table2Point]);
					TextDrawSetString(bj_text_point_table[lobby][1], str);

					ShowMembersCardBJL(lobby, 2, 2+pBJInfo[playerid][pBJTakedCard], suit, type);

			    	pBJInfo[playerid][pBJTakedCard]++;
     				CheckTableBlackJack(lobby, 2);
			    }
			    case 3:
			    {
					new suit = random(13);
					new type = random(4);

					BlackJackLobby[lobby][Table3Point] += BlackJackCard[suit][type][Pointscore];

					format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table3Point]);
					TextDrawSetString(bj_text_point_table[lobby][2], str);

					ShowMembersCardBJL(lobby, 3, 2+pBJInfo[playerid][pBJTakedCard], suit, type);

			    	pBJInfo[playerid][pBJTakedCard]++;
     				CheckTableBlackJack(lobby, 3);
			    }
			    case 4:
			    {
					new suit = random(13);
					new type = random(4);

					BlackJackLobby[lobby][Table4Point] += BlackJackCard[suit][type][Pointscore];

					format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table4Point]);
					TextDrawSetString(bj_text_point_table[lobby][3], str);

					ShowMembersCardBJL(lobby, 4, 2+pBJInfo[playerid][pBJTakedCard], suit, type);

			    	pBJInfo[playerid][pBJTakedCard]++;
     				CheckTableBlackJack(lobby, 4);
			    }
			}
	    }
	    else 
		{
			0;
			ShowNotificationNew(playerid, 2, 5, 1, 1, "Сейчас не ваш ход.", "");
		}

		BJAdvanceTurnIfCurrent(playerid, lobby);
		return 1;
	}
    if(clickedid == bj_take)
	{
		SendClientMessage(playerid, 0xFFFFFFFF, "");
	    new lobby = pBJInfo[playerid][pBJLobby];
	    if(BlackJackLobby[pBJInfo[playerid][pBJLobby]][TableTurn] == pBJInfo[playerid][pBJTable])
	    {
			new str[64];
            format(str, sizeof(str), "%s взял карту", GetPlayerNameEx(playerid));

			TextDrawSetString(bj_log_text[lobby][0], str);
			TextDrawColor(bj_log_text[lobby][0], -65281);

			if(BlackJackLobby[lobby][Table1Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_log_text[lobby][0]);
			if(BlackJackLobby[lobby][Table2Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_log_text[lobby][0]);
			if(BlackJackLobby[lobby][Table3Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_log_text[lobby][0]);
			if(BlackJackLobby[lobby][Table4Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_log_text[lobby][0]);

	        switch(pBJInfo[playerid][pBJTable])
			{
			    case 1:
			    {
			    	pBJInfo[playerid][pBJTakedCard]++;
					new suit = random(13);
					new type = random(4);

					BlackJackLobby[lobby][Table1Point] += BlackJackCard[suit][type][Pointscore];

					new str[10];
					format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table1Point]);
					TextDrawSetString(bj_text_point_table[lobby][0], str);

					ShowMembersCardBJL(lobby, 1, 2+pBJInfo[playerid][pBJTakedCard], suit, type);

     				CheckTableBlackJack(lobby, 1);
			    }
			    case 2:
			    {
			    	pBJInfo[playerid][pBJTakedCard]++;
					new suit = random(13);
					new type = random(4);

					BlackJackLobby[lobby][Table2Point] += BlackJackCard[suit][type][Pointscore];

					new str[10];
					format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table2Point]);
					TextDrawSetString(bj_text_point_table[lobby][1], str);

					ShowMembersCardBJL(lobby, 2, 2+pBJInfo[playerid][pBJTakedCard], suit, type);

     				CheckTableBlackJack(lobby, 2);
			    }
			    case 3:
			    {
			    	pBJInfo[playerid][pBJTakedCard]++;
					new suit = random(13);
					new type = random(4);

					BlackJackLobby[lobby][Table3Point] += BlackJackCard[suit][type][Pointscore];

					new str[10];
					format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table3Point]);
					TextDrawSetString(bj_text_point_table[lobby][2], str);

					ShowMembersCardBJL(lobby, 3, 2+pBJInfo[playerid][pBJTakedCard], suit, type);

     				CheckTableBlackJack(lobby, 3);
			    }
			    case 4:
			    {
			    	pBJInfo[playerid][pBJTakedCard]++;
					new suit = random(13);
					new type = random(4);

					BlackJackLobby[lobby][Table4Point] += BlackJackCard[suit][type][Pointscore];

					new str[10];
					format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table4Point]);
					TextDrawSetString(bj_text_point_table[lobby][3], str);

					ShowMembersCardBJL(lobby, 4, 2+pBJInfo[playerid][pBJTakedCard], suit, type);

     				CheckTableBlackJack(lobby, 4);
			    }
			}
	    }
	    else 
		{
			SendClientMessage(playerid, 0xFFFFFFFF, "");
			0;
			ShowNotificationNew(playerid, 2, 5, 1, 1, "Сейчас не ваш ход.", "");
		}

		BJAdvanceTurnIfCurrent(playerid, lobby);
		return 1;
	}
    if(clickedid == bj_stop)
	{
		SendClientMessage(playerid, 0xFFFFFFFF, "");
	    new lobby = pBJInfo[playerid][pBJLobby];
	    if(BlackJackLobby[lobby][TableTurn] == pBJInfo[playerid][pBJTable])
	    {
			new str[64];
            format(str, sizeof(str), "%s остановился", GetPlayerNameEx(playerid));

			TextDrawSetString(bj_log_text[lobby][0], str);
			TextDrawColor(bj_log_text[lobby][0], -65281);

			if(BlackJackLobby[lobby][Table1Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_log_text[lobby][0]);
			if(BlackJackLobby[lobby][Table2Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_log_text[lobby][0]);
			if(BlackJackLobby[lobby][Table3Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_log_text[lobby][0]);
			if(BlackJackLobby[lobby][Table4Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_log_text[lobby][0]);

	        BJAdvanceTurnIfCurrent(playerid, lobby);
	    }
	    else 
		{
			0;
			ShowNotificationNew(playerid, 2, 5, 1, 1, "Сейчас не ваш ход.", "");
		}
		return 1;
	}
	if(clickedid == bj_exit)
	{
		SendClientMessage(playerid, 0xFFFFFFFF, "");
   		new lobby = pBJInfo[playerid][pBJLobby];
   		new table = pBJInfo[playerid][pBJTable];
	    if(BlackJackLobby[lobby][StartedLobby]) 
		{
			0;
			ShowNotificationNew(playerid, 2, 5, 1, 1, "Дождитесь окончания игры.", "");
			return 1;
		}
	    else ExitPlayerLobby(playerid, lobby, table);
	    return 1;
	}

	#if defined blackjack_OnPlayerClickTextDraw
        return blackjack_OnPlayerClickTextDraw(playerid, clickedid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerClickTextDraw
    #undef OnPlayerClickTextDraw
#else
    #define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw blackjack_OnPlayerClickTextDraw
#if defined blackjack_OnPlayerClickTextDraw
    forward blackjack_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif


public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    new str[128];
    if(dialogid == 19998)
    {
        if(pBJInfo[playerid][OnLobby]) SelectTextDraw(playerid, 0x00000001);
        #if defined blackjack_OnDialogResponse
            return blackjack_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
        #else
            return 1;
        #endif
    }
    if(dialogid == 19999)
    {
		SendClientMessage(playerid, 0xFFFFFFFF, "");
        if(response)
        {
            if(pBJInfo[playerid][OnLobby])
            {
                new bet;
                if(sscanf(inputtext,"d",bet))
                {
					0;
			        ShowNotificationNew(playerid, 2, 5, 1, 1, "Введите ставку на которую хотите сыграть!", "");
                    SPD(playerid, 19999, DSI, "{FF6347}BlackJack", "Введите сумму на которую хотите сыграть: (Минимально 1000 рублей, Максимально 1000000000 рублей.)", "Играть", "Закрыть");
                    return 0;
                }
				if(!(1000 <= bet <= 500000000))
                {
					0;
					ShowNotificationNew(playerid, 2, 5, 1, 1, "Ставка должна быть от 1000 до 500000000 рублей.", "");
					SPD(playerid, 19999, DSI, "{FF6347}BlackJack", "Введите сумму ставки: от 1000 до 500000000 рублей.", "Играть", "Закрыть");
                    return 0;
                }
				if(GetPlayerMoneyEx(playerid) < bet)
                {
					0;
			        ShowNotificationNew(playerid, 2, 5, 1, 1, "У Вас недостаточно средств.", "");
                    SPD(playerid, 19999, DSI, "{FF6347}BlackJack", "Введите сумму на которую хотите сыграть: (Минимально 1000 рублей, Максимально 1000000000 рублей.)", "Играть", "Закрыть");
					return 0;
				}
				if(GetPlayerMoneyEx(playerid) > PLAYER_MONEY_SAFE_MAX - bet)
				{
					ShowNotificationNew(playerid, 2, 5, 1, 1, "С такой ставкой возможный выигрыш превысит лимит баланса.", "");
					return 0;
				}

                format(str, sizeof str, "%d py?", bet);
                PlayerTextDrawShow(playerid, bj_bet[playerid]);
                PlayerTextDrawSetString(playerid, bj_bet[playerid], str);
                pBJInfo[playerid][pBJBet] = bet;

                new lobby = pBJInfo[playerid][pBJLobby];
                new slot = pBJInfo[playerid][pBJBehindSlot];
				new apponent1 = BlackJackLobby[lobby][Table1Id];
				new apponent2 = BlackJackLobby[lobby][Table2Id];
				new apponent3 = BlackJackLobby[lobby][Table3Id];
				new apponent4 = BlackJackLobby[lobby][Table4Id];

                if(apponent1 != -1)
                {
                    TextDrawHideForPlayer(apponent1, bj_table_ready[lobby][slot]);
                    TextDrawSetString(bj_table_ready[lobby][slot], "ГОТОВ");
                    TextDrawColor(bj_table_ready[lobby][slot], 16711935);
                    TextDrawShowForPlayer(apponent1, bj_table_ready[lobby][slot]);
                }
				if(apponent2 != -1)
                {
                    TextDrawHideForPlayer(apponent2, bj_table_ready[lobby][slot]);
                    TextDrawSetString(bj_table_ready[lobby][slot], "ГОТОВ");
                    TextDrawColor(bj_table_ready[lobby][slot], 16711935);
                    TextDrawShowForPlayer(apponent2, bj_table_ready[lobby][slot]);
                }
				if(apponent3 != -1)
                {
                    TextDrawHideForPlayer(apponent3, bj_table_ready[lobby][slot]);
                    TextDrawSetString(bj_table_ready[lobby][slot], "ГОТОВ");
                    TextDrawColor(bj_table_ready[lobby][slot], 16711935);
                    TextDrawShowForPlayer(apponent3, bj_table_ready[lobby][slot]);
                }
				if(apponent4 != -1)
                {
                    TextDrawHideForPlayer(apponent4, bj_table_ready[lobby][slot]);
                    TextDrawSetString(bj_table_ready[lobby][slot], "ГОТОВ");
                    TextDrawColor(bj_table_ready[lobby][slot], 16711935);
                    TextDrawShowForPlayer(apponent4, bj_table_ready[lobby][slot]);
                }
                // ==========================

                TextDrawShowForPlayer(playerid, bj_text_bet[0]);
                TextDrawShowForPlayer(playerid, bj_text_bet[1]);
                SetTimerEx("TimerHideBetText", 3000, false, "d", playerid);
            }
        }
    }
    #if defined blackjack_OnDialogResponse
        return blackjack_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
    #endif
}
#if defined _ALS_OnDialogResponse
    #undef OnDialogResponse
#else
    #define _ALS_OnDialogResponse
#endif
#define OnDialogResponse blackjack_OnDialogResponse
#if defined blackjack_OnDialogResponse
    forward blackjack_OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]);
#endif

stock InitPlayerLobby(playerid, lobby, table)
{
    pBJInfo[playerid][pBJTable] = table;
    BJSetPlayerCleanChat(playerid, 1);

    for(new a;a < 12;a++)  SendClientMessage(playerid, 0xFFFFFFFF, "");

	TextDrawShowForPlayer(playerid, bj_fon);
	TextDrawShowForPlayer(playerid, bj_double);
	TextDrawShowForPlayer(playerid, bj_stop);
	TextDrawShowForPlayer(playerid, bj_play);
	TextDrawShowForPlayer(playerid, bj_take);
	TextDrawShowForPlayer(playerid, bj_exit);

	TextDrawShowForPlayer(playerid, bj_help);

	TextDrawShowForPlayer(playerid, bj_text_start_time);
	TextDrawShowForPlayer(playerid, bj_text_start_timer[lobby]);

	PlayerTextDrawShow(playerid, bj_bet[playerid]);
	PlayerTextDrawSetString(playerid, bj_bet[playerid], "0 py?");

	new money = GetPlayerMoneyEx(playerid);

	new str[24];
    format(str, sizeof str, "%d py?", money);
	PlayerTextDrawShow(playerid, bj_money[playerid]);
	PlayerTextDrawSetString(playerid, bj_money[playerid], str);

	TogglePlayerControllable(playerid, false);
	HideHud(playerid);

	foreach(new i : Player)
	{
	    ShowPlayerNameTagForPlayer(playerid, i, 0);
	}

	if(BlackJackLobby[lobby][Table1Id] != -1)
	{
	    new name[24];
		GetPlayerName(BlackJackLobby[lobby][Table1Id], name, 24);

		PlayerTextDrawShow(playerid, bj_members_name[playerid][0]);
		PlayerTextDrawSetString(playerid, bj_members_name[playerid][0], name);


		PlayerTextDrawShow(playerid, bj_card_table[playerid][1][0]); PlayerTextDrawShow(playerid, bj_card_table[playerid][1][1]); PlayerTextDrawShow(playerid, bj_card_table[playerid][1][2]); PlayerTextDrawShow(playerid, bj_card_table[playerid][1][3]);

		TextDrawShowForPlayer(playerid, bj_table_ready[lobby][1]);
		TextDrawSetString(bj_table_ready[lobby][1], "НЕ ГОТОВ");
		TextDrawColor(bj_table_ready[lobby][1], -16776961);

		new table1 = BlackJackLobby[lobby][Table1Id];

		GetPlayerName(playerid, name, 24);

		PlayerTextDrawShow(table1, bj_members_name[table1][table-1]);
		PlayerTextDrawSetString(table1, bj_members_name[table1][table-1], name);


		PlayerTextDrawShow(table1, bj_card_table[table1][table][0]); PlayerTextDrawShow(table1, bj_card_table[table1][table][1]); PlayerTextDrawShow(table1, bj_card_table[table1][table][2]); PlayerTextDrawShow(table1, bj_card_table[table1][table][3]);

		TextDrawShowForPlayer(table1, bj_table_ready[lobby][table]);
		TextDrawSetString(bj_table_ready[lobby][table], "НЕ ГОТОВ");
		TextDrawColor(bj_table_ready[lobby][table], -16776961);
	}
	if(BlackJackLobby[lobby][Table2Id] != -1)
	{
	    new name[24];
		GetPlayerName(BlackJackLobby[lobby][Table2Id], name, 24);

		PlayerTextDrawShow(playerid, bj_members_name[playerid][1]);
		PlayerTextDrawSetString(playerid, bj_members_name[playerid][1], name);


		PlayerTextDrawShow(playerid, bj_card_table[playerid][2][0]); PlayerTextDrawShow(playerid, bj_card_table[playerid][2][1]); PlayerTextDrawShow(playerid, bj_card_table[playerid][2][2]); PlayerTextDrawShow(playerid, bj_card_table[playerid][2][3]);

		TextDrawShowForPlayer(playerid, bj_table_ready[lobby][2]);
		TextDrawSetString(bj_table_ready[lobby][2], "НЕ ГОТОВ");
		TextDrawColor(bj_table_ready[lobby][2], -16776961);



		new table2 = BlackJackLobby[lobby][Table2Id];

		GetPlayerName(playerid, name, 24);

		PlayerTextDrawShow(table2, bj_members_name[table2][table-1]);
		PlayerTextDrawSetString(table2, bj_members_name[table2][table-1], name);


		PlayerTextDrawShow(table2, bj_card_table[table2][table][0]); PlayerTextDrawShow(table2, bj_card_table[table2][table][1]); PlayerTextDrawShow(table2, bj_card_table[table2][table][2]); PlayerTextDrawShow(table2, bj_card_table[table2][table][3]);

		TextDrawShowForPlayer(table2, bj_table_ready[lobby][table]);
		TextDrawSetString(bj_table_ready[lobby][table], "НЕ ГОТОВ");
		TextDrawColor(bj_table_ready[lobby][table], -16776961);
	}
	if(BlackJackLobby[lobby][Table3Id] != -1)
	{
	    new name[24];
		GetPlayerName(BlackJackLobby[lobby][Table3Id], name, 24);

		PlayerTextDrawShow(playerid, bj_members_name[playerid][2]);
		PlayerTextDrawSetString(playerid, bj_members_name[playerid][2], name);


		PlayerTextDrawShow(playerid, bj_card_table[playerid][3][0]); PlayerTextDrawShow(playerid, bj_card_table[playerid][3][1]); PlayerTextDrawShow(playerid, bj_card_table[playerid][3][2]); PlayerTextDrawShow(playerid, bj_card_table[playerid][3][3]);

		TextDrawShowForPlayer(playerid, bj_table_ready[lobby][3]);
		TextDrawSetString(bj_table_ready[lobby][3], "НЕ ГОТОВ");
		TextDrawColor(bj_table_ready[lobby][3], -16776961);



		new table3 = BlackJackLobby[lobby][Table3Id];

		GetPlayerName(playerid, name, 24);

		PlayerTextDrawShow(table3, bj_members_name[table3][table-1]);
		PlayerTextDrawSetString(table3, bj_members_name[table3][table-1], name);


		PlayerTextDrawShow(table3, bj_card_table[table3][table][0]); PlayerTextDrawShow(table3, bj_card_table[table3][table][1]); PlayerTextDrawShow(table3, bj_card_table[table3][table][2]); PlayerTextDrawShow(table3, bj_card_table[table3][table][3]);

		TextDrawShowForPlayer(table3, bj_table_ready[lobby][table]);
		TextDrawSetString(bj_table_ready[lobby][table], "НЕ ГОТОВ");
		TextDrawColor(bj_table_ready[lobby][table], -16776961);
	}
	if(BlackJackLobby[lobby][Table4Id] != -1)
	{
	    new name[24];
		GetPlayerName(BlackJackLobby[lobby][Table4Id], name, 24);

		PlayerTextDrawShow(playerid, bj_members_name[playerid][3]);
		PlayerTextDrawSetString(playerid, bj_members_name[playerid][3], name);


		PlayerTextDrawShow(playerid, bj_card_table[playerid][4][0]); PlayerTextDrawShow(playerid, bj_card_table[playerid][4][1]); PlayerTextDrawShow(playerid, bj_card_table[playerid][4][2]); PlayerTextDrawShow(playerid, bj_card_table[playerid][4][3]);

		TextDrawShowForPlayer(playerid, bj_table_ready[lobby][4]);
		TextDrawSetString(bj_table_ready[lobby][4], "НЕ ГОТОВ");
		TextDrawColor(bj_table_ready[lobby][4], -16776961);

		new table4 = BlackJackLobby[lobby][Table4Id];

		GetPlayerName(playerid, name, 24);

		PlayerTextDrawShow(table4, bj_members_name[table4][table-1]);
		PlayerTextDrawSetString(table4, bj_members_name[table4][table-1], name);


		PlayerTextDrawShow(table4, bj_card_table[table4][table][0]); PlayerTextDrawShow(table4, bj_card_table[table4][table][1]); PlayerTextDrawShow(table4, bj_card_table[table4][table][2]); PlayerTextDrawShow(table4, bj_card_table[table4][table][3]);

		TextDrawShowForPlayer(table4, bj_table_ready[lobby][table]);
		TextDrawSetString(bj_table_ready[lobby][table], "НЕ ГОТОВ");
		TextDrawColor(bj_table_ready[lobby][table], -16776961);
	}
	SelectTextDraw(playerid, 0x00000001);
	return 1;
}

stock BlackJack_ForceHideInterface(playerid)
{
    TextDrawHideForPlayer(playerid, bj_fon);
    TextDrawHideForPlayer(playerid, bj_double);
    TextDrawHideForPlayer(playerid, bj_stop);
    TextDrawHideForPlayer(playerid, bj_play);
    TextDrawHideForPlayer(playerid, bj_take);
    TextDrawHideForPlayer(playerid, bj_exit);
    TextDrawHideForPlayer(playerid, bj_dealer_score);
    TextDrawHideForPlayer(playerid, bj_help);
    TextDrawHideForPlayer(playerid, bj_text_bet[0]);
    TextDrawHideForPlayer(playerid, bj_text_bet[1]);
    TextDrawHideForPlayer(playerid, bj_text_start_time);
    PlayerTextDrawHide(playerid, bj_bet[playerid]);
    PlayerTextDrawHide(playerid, bj_money[playerid]);
    PlayerTextDrawHide(playerid, bj_dealer_point[playerid]);
    PlayerTextDrawHide(playerid, bj_panel_info[playerid]);

    for(new lobby_id; lobby_id < MAX_BJ_LOBBY; lobby_id++)
    {
        TextDrawHideForPlayer(playerid, bj_log_text[lobby_id][0]);
        TextDrawHideForPlayer(playerid, bj_log_text[lobby_id][1]);
        TextDrawHideForPlayer(playerid, bj_text_start_timer[lobby_id]);
        for(new slot = 0; slot < 4; slot++)
        {
            TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby_id][slot]);
            TextDrawHideForPlayer(playerid, bj_text_point_table[lobby_id][slot]);
            TextDrawHideForPlayer(playerid, bj_dealer_card[lobby_id][slot]);
            TextDrawHideForPlayer(playerid, bj_result_table[lobby_id][slot]);
        }
        for(new table_id = 1; table_id <= 4; table_id++)
            TextDrawHideForPlayer(playerid, bj_table_ready[lobby_id][table_id]);
    }

    for(new member = 0; member < 4; member++)
        PlayerTextDrawHide(playerid, bj_members_name[playerid][member]);
    for(new table_id = 0; table_id <= 4; table_id++)
        for(new card = 0; card < 4; card++)
            PlayerTextDrawHide(playerid, bj_card_table[playerid][table_id][card]);

    CancelSelectTextDraw(playerid);
    return 1;
}
stock ExitPlayerLobby(playerid, lobby, table)
{
	SetTimerEx("ExitPlayerLobbyTimer", 1000, false, "iii", playerid, lobby, table);

    switch(table)
	{
	    case 1: BlackJackLobby[lobby][Table1Id] = -1;
	    case 2: BlackJackLobby[lobby][Table2Id] = -1;
	    case 3: BlackJackLobby[lobby][Table3Id] = -1;
	    case 4: BlackJackLobby[lobby][Table4Id] = -1;
	}
	pBJInfo[playerid][OnLobby] = false;
	pBJInfo[playerid][pBJLobby] = 10;
	pBJInfo[playerid][pBJBet] = 0;
	pBJInfo[playerid][pBJTakedCard] = 0;
	pBJInfo[playerid][pBJBehindSlot] = 0;

    TextDrawHideForPlayer(playerid, bj_fon);
	TextDrawHideForPlayer(playerid, bj_double);
	TextDrawHideForPlayer(playerid, bj_stop);
	TextDrawHideForPlayer(playerid, bj_play);
	TextDrawHideForPlayer(playerid, bj_take);
	TextDrawHideForPlayer(playerid, bj_exit);
	TextDrawHideForPlayer(playerid, bj_dealer_score);
	PlayerTextDrawHide(playerid, bj_dealer_point[playerid]);
	TextDrawHideForPlayer(playerid, bj_help);
	TextDrawHideForPlayer(playerid, bj_log_text[lobby][0]);
	TextDrawHideForPlayer(playerid, bj_log_text[lobby][1]);

	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][1]);
	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][2]);
	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][3]);
	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][4]);

    PlayerTextDrawHide(playerid, bj_panel_info[playerid]);
    PlayerTextDrawSetString(playerid, bj_panel_info[playerid], "blackjack:brbjyouturn");

	TextDrawHideForPlayer(playerid, bj_dealer_card[lobby][1]);
	TextDrawHideForPlayer(playerid, bj_dealer_card[lobby][2]);
	TextDrawHideForPlayer(playerid, bj_dealer_card[lobby][3]);

	TextDrawHideForPlayer(playerid, bj_text_bet[0]);
	TextDrawHideForPlayer(playerid, bj_text_bet[1]);

	TextDrawHideForPlayer(playerid, bj_text_start_time);
	TextDrawHideForPlayer(playerid, bj_text_start_timer[lobby]);

	PlayerTextDrawHide(playerid, bj_bet[playerid]);
	PlayerTextDrawHide(playerid, bj_money[playerid]);

	PlayerTextDrawHide(playerid, bj_members_name[playerid][0]);
	PlayerTextDrawHide(playerid, bj_members_name[playerid][1]);
	PlayerTextDrawHide(playerid, bj_members_name[playerid][2]);
	PlayerTextDrawHide(playerid, bj_members_name[playerid][3]);

	TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][0]);
	TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][1]);
	TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][2]);
	TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][3]);

    TextDrawHideForPlayer(playerid, bj_result_table[lobby][0]);
    TextDrawHideForPlayer(playerid, bj_result_table[lobby][1]);
    TextDrawHideForPlayer(playerid, bj_result_table[lobby][2]);
    TextDrawHideForPlayer(playerid, bj_result_table[lobby][3]);

	for(new i = 1; i <= 4; i++)
	{
		PlayerTextDrawHide(playerid, bj_card_table[playerid][i][0]);
		PlayerTextDrawHide(playerid, bj_card_table[playerid][i][1]);
		PlayerTextDrawHide(playerid, bj_card_table[playerid][i][2]);
		PlayerTextDrawHide(playerid, bj_card_table[playerid][i][3]);

		PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][0], "blackjack:cardscard");
		PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][1], "blackjack:cardscard");
		PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][2], "blackjack:cardscard");
		PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][3], "blackjack:cardscard");

		new apponent;
	    switch(i)
	    {
	        case 1:
			{
				if(BlackJackLobby[lobby][Table1Id] != -1) apponent = BlackJackLobby[lobby][Table1Id];
				else apponent = -1;
			}
	        case 2:
			{
				if(BlackJackLobby[lobby][Table2Id] != -1) apponent = BlackJackLobby[lobby][Table2Id];
				else apponent = -1;
			}
	        case 3:
			{
				if(BlackJackLobby[lobby][Table3Id] != -1) apponent = BlackJackLobby[lobby][Table3Id];
				else apponent = -1;
			}
	        case 4:
			{
				if(BlackJackLobby[lobby][Table4Id] != -1) apponent = BlackJackLobby[lobby][Table4Id];
				else apponent = -1;
			}
		}
		if(apponent != -1)
		{
			PlayerTextDrawHide(apponent, bj_members_name[apponent][table-1]);
			PlayerTextDrawHide(apponent, bj_card_table[apponent][table][0]);
			PlayerTextDrawHide(apponent, bj_card_table[apponent][table][1]);
			PlayerTextDrawHide(apponent, bj_card_table[apponent][table][2]);
			PlayerTextDrawHide(apponent, bj_card_table[apponent][table][3]);

			TextDrawHideForPlayer(apponent, bj_text_point_table[lobby][0]);
			TextDrawHideForPlayer(apponent, bj_text_point_table[lobby][1]);
			TextDrawHideForPlayer(apponent, bj_text_point_table[lobby][2]);
			TextDrawHideForPlayer(apponent, bj_text_point_table[lobby][3]);
		}
	}

	TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][0]);
	TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][1]);
	TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][2]);
	TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][3]);

	/*TextDrawHideForPlayer(playerid, bj_text_start_time);
	TextDrawHideForPlayer(playerid, bj_text_start_timer[lobby]);

	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][1]);
	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][2]);
	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][3]);
	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][4]);*/

	BlackJack_ForceHideInterface(playerid);
	ClearAnimations(playerid);
	TogglePlayerControllable(playerid, true);
	ShowHud(playerid);

	foreach(new i : Player)
	{
	    ShowPlayerNameTagForPlayer(playerid, i, 1);
	}
	return 1;
}

public ExitPlayerLobbyTimer(playerid, lobby, table)
{
    switch(table)
	{
	    case 1: BlackJackLobby[lobby][Table1Id] = -1;
	    case 2: BlackJackLobby[lobby][Table2Id] = -1;
	    case 3: BlackJackLobby[lobby][Table3Id] = -1;
	    case 4: BlackJackLobby[lobby][Table4Id] = -1;
	}
	pBJInfo[playerid][OnLobby] = false;
	pBJInfo[playerid][pBJLobby] = 10;
	pBJInfo[playerid][pBJBet] = 0;
	pBJInfo[playerid][pBJTakedCard] = 0;
	pBJInfo[playerid][pBJBehindSlot] = 0;

    TextDrawHideForPlayer(playerid, bj_fon);
	TextDrawHideForPlayer(playerid, bj_double);
	TextDrawHideForPlayer(playerid, bj_stop);
	TextDrawHideForPlayer(playerid, bj_play);
	TextDrawHideForPlayer(playerid, bj_take);
	TextDrawHideForPlayer(playerid, bj_exit);
	TextDrawHideForPlayer(playerid, bj_dealer_score);
	PlayerTextDrawHide(playerid, bj_dealer_point[playerid]);
	TextDrawHideForPlayer(playerid, bj_help);
	TextDrawHideForPlayer(playerid, bj_log_text[lobby][0]);
	TextDrawHideForPlayer(playerid, bj_log_text[lobby][1]);

	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][1]);
	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][2]);
	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][3]);
	TextDrawHideForPlayer(playerid, bj_table_ready[lobby][4]);

    PlayerTextDrawHide(playerid, bj_panel_info[playerid]);
    PlayerTextDrawSetString(playerid, bj_panel_info[playerid], "blackjack:brbjyouturn");

	TextDrawHideForPlayer(playerid, bj_dealer_card[lobby][1]);
	TextDrawHideForPlayer(playerid, bj_dealer_card[lobby][2]);
	TextDrawHideForPlayer(playerid, bj_dealer_card[lobby][3]);

	TextDrawHideForPlayer(playerid, bj_text_bet[0]);
	TextDrawHideForPlayer(playerid, bj_text_bet[1]);

	TextDrawHideForPlayer(playerid, bj_text_start_time);
	TextDrawHideForPlayer(playerid, bj_text_start_timer[lobby]);

	PlayerTextDrawHide(playerid, bj_bet[playerid]);
	PlayerTextDrawHide(playerid, bj_money[playerid]);

	PlayerTextDrawHide(playerid, bj_members_name[playerid][0]);
	PlayerTextDrawHide(playerid, bj_members_name[playerid][1]);
	PlayerTextDrawHide(playerid, bj_members_name[playerid][2]);
	PlayerTextDrawHide(playerid, bj_members_name[playerid][3]);

	TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][0]);
	TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][1]);
	TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][2]);
	TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][3]);

    TextDrawHideForPlayer(playerid, bj_result_table[lobby][0]);
    TextDrawHideForPlayer(playerid, bj_result_table[lobby][1]);
    TextDrawHideForPlayer(playerid, bj_result_table[lobby][2]);
    TextDrawHideForPlayer(playerid, bj_result_table[lobby][3]);

	for(new i = 1; i <= 4; i++)
	{
		PlayerTextDrawHide(playerid, bj_card_table[playerid][i][0]);
		PlayerTextDrawHide(playerid, bj_card_table[playerid][i][1]);
		PlayerTextDrawHide(playerid, bj_card_table[playerid][i][2]);
		PlayerTextDrawHide(playerid, bj_card_table[playerid][i][3]);

		PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][0], "blackjack:cardscard");
		PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][1], "blackjack:cardscard");
		PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][2], "blackjack:cardscard");
		PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][3], "blackjack:cardscard");

		new apponent;
	    switch(i)
	    {
	        case 1:
			{
				if(BlackJackLobby[lobby][Table1Id] != -1) apponent = BlackJackLobby[lobby][Table1Id];
				else apponent = -1;
			}
	        case 2:
			{
				if(BlackJackLobby[lobby][Table2Id] != -1) apponent = BlackJackLobby[lobby][Table2Id];
				else apponent = -1;
			}
	        case 3:
			{
				if(BlackJackLobby[lobby][Table3Id] != -1) apponent = BlackJackLobby[lobby][Table3Id];
				else apponent = -1;
			}
	        case 4:
			{
				if(BlackJackLobby[lobby][Table4Id] != -1) apponent = BlackJackLobby[lobby][Table4Id];
				else apponent = -1;
			}
		}
		if(apponent != -1)
		{
			PlayerTextDrawHide(apponent, bj_members_name[apponent][table-1]);
			PlayerTextDrawHide(apponent, bj_card_table[apponent][table][0]);
			PlayerTextDrawHide(apponent, bj_card_table[apponent][table][1]);
			PlayerTextDrawHide(apponent, bj_card_table[apponent][table][2]);
			PlayerTextDrawHide(apponent, bj_card_table[apponent][table][3]);

			TextDrawHideForPlayer(apponent, bj_text_point_table[lobby][0]);
			TextDrawHideForPlayer(apponent, bj_text_point_table[lobby][1]);
			TextDrawHideForPlayer(apponent, bj_text_point_table[lobby][2]);
			TextDrawHideForPlayer(apponent, bj_text_point_table[lobby][3]);
		}
	}

	TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][0]);
	TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][1]);
	TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][2]);
	TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][3]);

	BlackJack_ForceHideInterface(playerid);
	ClearAnimations(playerid);
	TogglePlayerControllable(playerid, true);
	ShowHud(playerid);

	foreach(new i : Player)
	{
	    ShowPlayerNameTagForPlayer(playerid, i, 1);
	}
	return 1;
}

stock LoadBlackJack()
{

	new tabletext[128];

    for(new lobby; lobby < MAX_BJ_LOBBY; lobby++)
	{
	    format(tabletext, sizeof(tabletext), "{FFFF00}BlackJack Стол %d\n{FFFFFF}Подойдите для взаимодействия", lobby + 1);
        BlackJackText[lobby] = CreateDynamic3DTextLabel(tabletext, -1, BlackJackPos[lobby][0], BlackJackPos[lobby][1], BlackJackPos[lobby][2], 9.0);

		BlackJackSphere[lobby] = CreateDynamicSphere(BlackJackPos[lobby][0], BlackJackPos[lobby][1], BlackJackPos[lobby][2], 4.0);
		ReloadTable(lobby);
    	LoadBJLobbyTimer(lobby);
    	LoadBJLobbyPoint(lobby);
    	LoadBJLobbyReady(lobby);
    	LoadBJLobbyDealerCard(lobby);
    	LoadBJTextBlackJack(lobby);
    	LoadBJLobbyResult(lobby);

        LoadTextDrawBj();

		SetTimerEx("TimerSecondUpdateBJ", 1000, true, "d", lobby);

		TextDrawSetString(bj_text_point_table[lobby][0], "очки: 0");
		TextDrawSetString(bj_text_point_table[lobby][1], "очки: 0");
		TextDrawSetString(bj_text_point_table[lobby][2], "очки: 0");
		TextDrawSetString(bj_text_point_table[lobby][3], "очки: 0");

        bj_log_text[lobby][0] = TextDrawCreate(321.200073, 254.306640, "");
        TextDrawLetterSize(bj_log_text[lobby][0], 0.377198, 1.353598);
        TextDrawAlignment(bj_log_text[lobby][0], 2);
        TextDrawColor(bj_log_text[lobby][0], -1);
        TextDrawSetShadow(bj_log_text[lobby][0], 0);
        TextDrawSetOutline(bj_log_text[lobby][0], 1);
        TextDrawBackgroundColor(bj_log_text[lobby][0], 51);
        TextDrawFont(bj_log_text[lobby][0], 1);
        TextDrawSetProportional(bj_log_text[lobby][0], 1);

        bj_log_text[lobby][1] = TextDrawCreate(321.200073, 270.306640, "");

		TextDrawLetterSize(bj_log_text[lobby][1], 0.377198, 1.353598);
		TextDrawAlignment(bj_log_text[lobby][1], 2);
		TextDrawColor(bj_log_text[lobby][1], -65281);
		TextDrawSetShadow(bj_log_text[lobby][1], 0);
		TextDrawSetOutline(bj_log_text[lobby][1], 1);
		TextDrawBackgroundColor(bj_log_text[lobby][1], 51);
		TextDrawFont(bj_log_text[lobby][1], 1);
		TextDrawSetProportional(bj_log_text[lobby][1], 1);
	}
}
stock LoadBJLobbyTimer(lobby)
{
    BlackJackLobby[lobby][StartTimer] = 60;

    bj_text_start_timer[lobby] = TextDrawCreate(316.199981, 237.693496, "00:60");
	TextDrawLetterSize(bj_text_start_timer[lobby], 0.581197, 2.563199);
	TextDrawAlignment(bj_text_start_timer[lobby], 2);
	TextDrawColor(bj_text_start_timer[lobby], -1);
	TextDrawSetShadow(bj_text_start_timer[lobby], 0);
	TextDrawSetOutline(bj_text_start_timer[lobby], 1);
	TextDrawBackgroundColor(bj_text_start_timer[lobby], 51);
	TextDrawFont(bj_text_start_timer[lobby], 1);
	TextDrawSetProportional(bj_text_start_timer[lobby], 1);
}

stock LoadBJLobbyPoint(lobby)
{
	bj_text_point_table[lobby][0] = TextDrawCreate(76.000015, 306.879913, "Очки: 0");
	TextDrawLetterSize(bj_text_point_table[lobby][0], 0.356397, 1.174399);
	TextDrawAlignment(bj_text_point_table[lobby][0], 2);
	TextDrawColor(bj_text_point_table[lobby][0], -1);
	TextDrawSetShadow(bj_text_point_table[lobby][0], 0);
	TextDrawSetOutline(bj_text_point_table[lobby][0], 1);
	TextDrawBackgroundColor(bj_text_point_table[lobby][0], 51);
	TextDrawFont(bj_text_point_table[lobby][0], 1);
	TextDrawSetProportional(bj_text_point_table[lobby][0], 1);

	bj_text_point_table[lobby][1] = TextDrawCreate(205.799972, 146.599792, "Очки: 0");
	TextDrawLetterSize(bj_text_point_table[lobby][1], 0.356397, 1.174399);
	TextDrawAlignment(bj_text_point_table[lobby][1], 2);
	TextDrawColor(bj_text_point_table[lobby][1], -1);
	TextDrawSetShadow(bj_text_point_table[lobby][1], 0);
	TextDrawSetOutline(bj_text_point_table[lobby][1], 1);
	TextDrawBackgroundColor(bj_text_point_table[lobby][1], 51);
	TextDrawFont(bj_text_point_table[lobby][1], 1);
	TextDrawSetProportional(bj_text_point_table[lobby][1], 1);

	bj_text_point_table[lobby][2] = TextDrawCreate(457.200195, 146.853118, "Очки: 0");
	TextDrawLetterSize(bj_text_point_table[lobby][2], 0.356397, 1.174399);
	TextDrawAlignment(bj_text_point_table[lobby][2], 2);
	TextDrawColor(bj_text_point_table[lobby][2], -1);
	TextDrawSetShadow(bj_text_point_table[lobby][2], 0);
	TextDrawSetOutline(bj_text_point_table[lobby][2], 1);
	TextDrawBackgroundColor(bj_text_point_table[lobby][2], 51);
	TextDrawFont(bj_text_point_table[lobby][2], 1);
	TextDrawSetProportional(bj_text_point_table[lobby][2], 1);

	bj_text_point_table[lobby][3] = TextDrawCreate(560.200500, 307.133239, "Очки: 0");
	TextDrawLetterSize(bj_text_point_table[lobby][3], 0.356397, 1.174399);
	TextDrawAlignment(bj_text_point_table[lobby][3], 2);
	TextDrawColor(bj_text_point_table[lobby][3], -1);
	TextDrawSetShadow(bj_text_point_table[lobby][3], 0);
	TextDrawSetOutline(bj_text_point_table[lobby][3], 1);
	TextDrawBackgroundColor(bj_text_point_table[lobby][3], 51);
	TextDrawFont(bj_text_point_table[lobby][3], 1);
	TextDrawSetProportional(bj_text_point_table[lobby][3], 1);
}

stock LoadBJLobbyReady(lobby)
{
	bj_table_ready[lobby][1] = TextDrawCreate(77.600013, 320.319999, "НЕ ГОТОВ");
	TextDrawLetterSize(bj_table_ready[lobby][1], 0.365199, 1.219199);
	TextDrawAlignment(bj_table_ready[lobby][1], 2);
	TextDrawColor(bj_table_ready[lobby][1], -16776961);
	TextDrawSetShadow(bj_table_ready[lobby][1], 0);
	TextDrawSetOutline(bj_table_ready[lobby][1], 1);
	TextDrawBackgroundColor(bj_table_ready[lobby][1], 51);
	TextDrawFont(bj_table_ready[lobby][1], 1);
	TextDrawSetProportional(bj_table_ready[lobby][1], 1);

	bj_table_ready[lobby][2] = TextDrawCreate(206.800628, 160.293167, "НЕ ГОТОВ");
	TextDrawLetterSize(bj_table_ready[lobby][2], 0.365199, 1.219199);
	TextDrawAlignment(bj_table_ready[lobby][2], 2);
	TextDrawColor(bj_table_ready[lobby][2], -16776961);
	TextDrawSetShadow(bj_table_ready[lobby][2], 0);
	TextDrawSetOutline(bj_table_ready[lobby][2], 1);
	TextDrawBackgroundColor(bj_table_ready[lobby][2], 51);
	TextDrawFont(bj_table_ready[lobby][2], 1);
	TextDrawSetProportional(bj_table_ready[lobby][2], 1);

	bj_table_ready[lobby][3] = TextDrawCreate(458.200958, 160.293167, "НЕ ГОТОВ");
	TextDrawLetterSize(bj_table_ready[lobby][3], 0.365199, 1.219199);
	TextDrawAlignment(bj_table_ready[lobby][3], 2);
	TextDrawColor(bj_table_ready[lobby][3], -16776961);
	TextDrawSetShadow(bj_table_ready[lobby][3], 0);
	TextDrawSetOutline(bj_table_ready[lobby][3], 1);
	TextDrawBackgroundColor(bj_table_ready[lobby][3], 51);
	TextDrawFont(bj_table_ready[lobby][3], 1);
	TextDrawSetProportional(bj_table_ready[lobby][3], 1);

	bj_table_ready[lobby][4] = TextDrawCreate(561.800598, 320.319999, "НЕ ГОТОВ");
	TextDrawLetterSize(bj_table_ready[lobby][4], 0.365199, 1.219199);
	TextDrawAlignment(bj_table_ready[lobby][4], 2);
	TextDrawColor(bj_table_ready[lobby][4], -16776961);
	TextDrawSetShadow(bj_table_ready[lobby][4], 0);
	TextDrawSetOutline(bj_table_ready[lobby][4], 1);
	TextDrawBackgroundColor(bj_table_ready[lobby][4], 51);
	TextDrawFont(bj_table_ready[lobby][4], 1);
	TextDrawSetProportional(bj_table_ready[lobby][4], 1);
}

stock LoadBJLobbyDealerCard(lobby)
{
	bj_dealer_card[lobby][1] = TextDrawCreate(209.799957, 191.399993, "blackjack:cardsas");
	TextDrawLetterSize(bj_dealer_card[lobby][1], 0.000000, 0.000000);
	TextDrawTextSize(bj_dealer_card[lobby][1], 132.000015, 174.719879);
	TextDrawAlignment(bj_dealer_card[lobby][1], 1);
	TextDrawColor(bj_dealer_card[lobby][1], -1);
	TextDrawSetShadow(bj_dealer_card[lobby][1], 0);
	TextDrawSetOutline(bj_dealer_card[lobby][1], 0);
	TextDrawFont(bj_dealer_card[lobby][1], 4);

	bj_dealer_card[lobby][2] = TextDrawCreate(235.600021, 191.653320, "blackjack:cardsas");
	TextDrawLetterSize(bj_dealer_card[lobby][2], 0.000000, 0.000000);
	TextDrawTextSize(bj_dealer_card[lobby][2], 132.000015, 174.719879);
	TextDrawAlignment(bj_dealer_card[lobby][2], 1);
	TextDrawColor(bj_dealer_card[lobby][2], -1);
	TextDrawSetShadow(bj_dealer_card[lobby][2], 0);
	TextDrawSetOutline(bj_dealer_card[lobby][2], 0);
	TextDrawFont(bj_dealer_card[lobby][2], 4);

	bj_dealer_card[lobby][3] = TextDrawCreate(314.200042, 191.906646, "blackjack:cardskd");
	TextDrawLetterSize(bj_dealer_card[lobby][3], 0.000000, 0.000000);
	TextDrawTextSize(bj_dealer_card[lobby][3], 132.000015, 174.719879);
	TextDrawAlignment(bj_dealer_card[lobby][3], 1);
	TextDrawColor(bj_dealer_card[lobby][3], -1);
	TextDrawSetShadow(bj_dealer_card[lobby][3], 0);
	TextDrawSetOutline(bj_dealer_card[lobby][3], 0);
	TextDrawFont(bj_dealer_card[lobby][3], 4);
}

stock LoadBJTextBlackJack(lobby)
{
    bj_text_bj_table[lobby][0] = TextDrawCreate(31.200008, 312.106567, "blackjack:brbjblackjack");
	TextDrawLetterSize(bj_text_bj_table[lobby][0], 0.000000, 0.000000);
	TextDrawTextSize(bj_text_bj_table[lobby][0], 91.199974, 46.293384);
	TextDrawAlignment(bj_text_bj_table[lobby][0], 1);
	TextDrawColor(bj_text_bj_table[lobby][0], -1);
	TextDrawSetShadow(bj_text_bj_table[lobby][0], 0);
	TextDrawSetOutline(bj_text_bj_table[lobby][0], 0);
	TextDrawFont(bj_text_bj_table[lobby][0], 4);

	bj_text_bj_table[lobby][1] = TextDrawCreate(161.000030, 152.079727, "blackjack:brbjblackjack");
	TextDrawLetterSize(bj_text_bj_table[lobby][1], 0.000000, 0.000000);
	TextDrawTextSize(bj_text_bj_table[lobby][1], 91.199974, 46.293384);
	TextDrawAlignment(bj_text_bj_table[lobby][1], 1);
	TextDrawColor(bj_text_bj_table[lobby][1], -1);
	TextDrawSetShadow(bj_text_bj_table[lobby][1], 0);
	TextDrawSetOutline(bj_text_bj_table[lobby][1], 0);
	TextDrawFont(bj_text_bj_table[lobby][1], 4);

	bj_text_bj_table[lobby][2] = TextDrawCreate(412.400238, 152.079727, "blackjack:brbjblackjack");
	TextDrawLetterSize(bj_text_bj_table[lobby][2], 0.000000, 0.000000);
	TextDrawTextSize(bj_text_bj_table[lobby][2], 91.199974, 46.293384);
	TextDrawAlignment(bj_text_bj_table[lobby][2], 1);
	TextDrawColor(bj_text_bj_table[lobby][2], -1);
	TextDrawSetShadow(bj_text_bj_table[lobby][2], 0);
	TextDrawSetOutline(bj_text_bj_table[lobby][2], 0);
	TextDrawFont(bj_text_bj_table[lobby][2], 4);

	bj_text_bj_table[lobby][3] = TextDrawCreate(515.400390, 312.106567, "blackjack:brbjblackjack");
	TextDrawLetterSize(bj_text_bj_table[lobby][3], 0.000000, 0.000000);
	TextDrawTextSize(bj_text_bj_table[lobby][3], 91.199974, 46.293384);
	TextDrawAlignment(bj_text_bj_table[lobby][3], 1);
	TextDrawColor(bj_text_bj_table[lobby][3], -1);
	TextDrawSetShadow(bj_text_bj_table[lobby][3], 0);
	TextDrawSetOutline(bj_text_bj_table[lobby][3], 0);
	TextDrawFont(bj_text_bj_table[lobby][3], 4);
}

stock LoadBJLobbyResult(lobby)
{
//bj_result_table

	bj_result_table[lobby][0] = TextDrawCreate(88.800003, 187.666666, "blackjack:brbjwin");
 	TextDrawLetterSize(		bj_result_table[lobby][0], 0.000000, 0.000000);
	TextDrawTextSize( 		bj_result_table[lobby][0], 69.599975, 34.346652);
	TextDrawAlignment(		bj_result_table[lobby][0], 1);
	TextDrawColor(			bj_result_table[lobby][0], -1);
	TextDrawSetShadow(		bj_result_table[lobby][0], 0);
	TextDrawSetOutline(		bj_result_table[lobby][0], 0);
	TextDrawFont(			bj_result_table[lobby][0], 4);

	bj_result_table[lobby][1] = TextDrawCreate(215.400009, 27.133293, "blackjack:brbjlose");
 	TextDrawLetterSize(		bj_result_table[lobby][1], 0.000000, 0.000000);
	TextDrawTextSize(		bj_result_table[lobby][1], 69.599975, 34.346652);
	TextDrawAlignment(		bj_result_table[lobby][1], 1);
	TextDrawColor(			bj_result_table[lobby][1], -1);
	TextDrawSetShadow(		bj_result_table[lobby][1], 0);
	TextDrawSetOutline(		bj_result_table[lobby][1], 0);
	TextDrawFont(			bj_result_table[lobby][1], 4);

	bj_result_table[lobby][2] = TextDrawCreate(466.800170, 27.133293, "blackjack:brbjmydraw");
	TextDrawLetterSize(		bj_result_table[lobby][2], 0.000000, 0.000000);
	TextDrawTextSize(		bj_result_table[lobby][2], 69.599975, 34.346652);
	TextDrawAlignment(		bj_result_table[lobby][2], 1);
	TextDrawColor(			bj_result_table[lobby][2], -1);
	TextDrawSetShadow(		bj_result_table[lobby][2], 0);
	TextDrawSetOutline(		bj_result_table[lobby][2], 0);
	TextDrawFont(			bj_result_table[lobby][2], 4);

	bj_result_table[lobby][3] = TextDrawCreate(569.000610, 187.666666, "blackjack:brbjmydraw");
	TextDrawLetterSize(		bj_result_table[lobby][3], 0.000000, 0.000000);
	TextDrawTextSize(		bj_result_table[lobby][3], 69.599975, 34.346652);
	TextDrawAlignment(		bj_result_table[lobby][3], 1);
	TextDrawColor(			bj_result_table[lobby][3], -1);
	TextDrawSetShadow(		bj_result_table[lobby][3], 0);
	TextDrawSetOutline(		bj_result_table[lobby][3], 0);
	TextDrawFont(			bj_result_table[lobby][3], 4);


}

stock ReloadTable(lobby)
{
    BlackJackLobby[lobby][Table1Id] = -1;
    BlackJackLobby[lobby][Table2Id] = -1;
    BlackJackLobby[lobby][Table3Id] = -1;
    BlackJackLobby[lobby][Table4Id] = -1;
}


forward TimerSecondUpdateBJ(lobby);
public TimerSecondUpdateBJ(lobby)
{
	new bool:members;
	if(BlackJackLobby[lobby][Table1Id] != -1) members = true;
	else if(BlackJackLobby[lobby][Table2Id] != -1) members = true;
	else if(BlackJackLobby[lobby][Table3Id] != -1) members = true;
	else if(BlackJackLobby[lobby][Table4Id] != -1) members = true;

	if(members == true)
	{
		BlackJackLobby[lobby][ActivedLobby] = true;
	    if(BlackJackLobby[lobby][StartedLobby])
	    {
			switch(BlackJackLobby[lobby][StageLobby])
			{
			    case 1: //СКРЫТИЕ НАЧАЛЬНЫХ КАРТ, показ очков дилера, начало раздачи
			    {

		     		if(BlackJackLobby[lobby][Table1Id] != -1)
					{
						for(new table; table < 4; table++)
						{
							PlayerTextDrawHide(BlackJackLobby[lobby][Table1Id], bj_card_table[BlackJackLobby[lobby][Table1Id]][table][0]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table1Id], bj_card_table[BlackJackLobby[lobby][Table1Id]][table][1]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table1Id], bj_card_table[BlackJackLobby[lobby][Table1Id]][table][2]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table1Id], bj_card_table[BlackJackLobby[lobby][Table1Id]][table][3]);
						}
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table1Id], bj_play);
						TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_dealer_score);
						PlayerTextDrawShow(BlackJackLobby[lobby][Table1Id], bj_dealer_point[BlackJackLobby[lobby][Table1Id]]);
						PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_dealer_point[BlackJackLobby[lobby][Table1Id]], "0");

						TextDrawHideForPlayer(BlackJackLobby[lobby][Table1Id], bj_table_ready[lobby][1]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table1Id], bj_table_ready[lobby][2]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table1Id], bj_table_ready[lobby][3]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table1Id], bj_table_ready[lobby][4]);

						TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_log_text[lobby][0]);
						TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_log_text[lobby][1]);

						TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_text_point_table[lobby][0]);
						if(BlackJackLobby[lobby][Table2Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_text_point_table[lobby][1]);
						if(BlackJackLobby[lobby][Table3Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_text_point_table[lobby][2]);
						if(BlackJackLobby[lobby][Table4Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_text_point_table[lobby][3]);
					}
					if(BlackJackLobby[lobby][Table2Id] != -1)
					{
						for(new table; table < 4; table++)
						{
							PlayerTextDrawHide(BlackJackLobby[lobby][Table2Id], bj_card_table[BlackJackLobby[lobby][Table2Id]][table][0]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table2Id], bj_card_table[BlackJackLobby[lobby][Table2Id]][table][1]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table2Id], bj_card_table[BlackJackLobby[lobby][Table2Id]][table][2]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table2Id], bj_card_table[BlackJackLobby[lobby][Table2Id]][table][3]);
						}
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table2Id], bj_play);
						TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_dealer_score);
						PlayerTextDrawShow(BlackJackLobby[lobby][Table2Id], bj_dealer_point[BlackJackLobby[lobby][Table2Id]]);
						PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_dealer_point[BlackJackLobby[lobby][Table2Id]], "0");

						TextDrawHideForPlayer(BlackJackLobby[lobby][Table2Id], bj_table_ready[lobby][1]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table2Id], bj_table_ready[lobby][2]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table2Id], bj_table_ready[lobby][3]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table2Id], bj_table_ready[lobby][4]);

						TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_log_text[lobby][0]);
						TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_log_text[lobby][1]);

						if(BlackJackLobby[lobby][Table1Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_text_point_table[lobby][0]);
						TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_text_point_table[lobby][1]);
						if(BlackJackLobby[lobby][Table3Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_text_point_table[lobby][2]);
						if(BlackJackLobby[lobby][Table4Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_text_point_table[lobby][3]);
					}
					if(BlackJackLobby[lobby][Table3Id] != -1)
					{
						for(new table; table < 4; table++)
						{
							PlayerTextDrawHide(BlackJackLobby[lobby][Table3Id], bj_card_table[BlackJackLobby[lobby][Table3Id]][table][0]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table3Id], bj_card_table[BlackJackLobby[lobby][Table3Id]][table][1]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table3Id], bj_card_table[BlackJackLobby[lobby][Table3Id]][table][2]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table3Id], bj_card_table[BlackJackLobby[lobby][Table3Id]][table][3]);
						}
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table3Id], bj_play);
						TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_dealer_score);
						PlayerTextDrawShow(BlackJackLobby[lobby][Table3Id], bj_dealer_point[BlackJackLobby[lobby][Table3Id]]);
						PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_dealer_point[BlackJackLobby[lobby][Table3Id]], "0");

						TextDrawHideForPlayer(BlackJackLobby[lobby][Table3Id], bj_table_ready[lobby][1]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table3Id], bj_table_ready[lobby][2]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table3Id], bj_table_ready[lobby][3]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table3Id], bj_table_ready[lobby][4]);

						TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_log_text[lobby][0]);
						TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_log_text[lobby][1]);

						if(BlackJackLobby[lobby][Table1Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_text_point_table[lobby][0]);
						if(BlackJackLobby[lobby][Table2Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_text_point_table[lobby][1]);
						TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_text_point_table[lobby][2]);
						if(BlackJackLobby[lobby][Table4Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_text_point_table[lobby][3]);
					}
					if(BlackJackLobby[lobby][Table4Id] != -1)
					{
						for(new table; table < 4; table++)
						{
							PlayerTextDrawHide(BlackJackLobby[lobby][Table4Id], bj_card_table[BlackJackLobby[lobby][Table4Id]][table][0]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table4Id], bj_card_table[BlackJackLobby[lobby][Table4Id]][table][1]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table4Id], bj_card_table[BlackJackLobby[lobby][Table4Id]][table][2]);
							PlayerTextDrawHide(BlackJackLobby[lobby][Table4Id], bj_card_table[BlackJackLobby[lobby][Table4Id]][table][3]);
						}
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table4Id], bj_play);
						TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_dealer_score);
						PlayerTextDrawShow(BlackJackLobby[lobby][Table4Id], bj_dealer_point[BlackJackLobby[lobby][Table4Id]]);
						PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_dealer_point[BlackJackLobby[lobby][Table4Id]], "0");

						TextDrawHideForPlayer(BlackJackLobby[lobby][Table4Id], bj_table_ready[lobby][1]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table4Id], bj_table_ready[lobby][2]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table4Id], bj_table_ready[lobby][3]);
						TextDrawHideForPlayer(BlackJackLobby[lobby][Table4Id], bj_table_ready[lobby][4]);

						TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_log_text[lobby][0]);
						TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_log_text[lobby][1]);

						if(BlackJackLobby[lobby][Table1Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_text_point_table[lobby][0]);
						if(BlackJackLobby[lobby][Table2Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_text_point_table[lobby][1]);
						if(BlackJackLobby[lobby][Table3Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_text_point_table[lobby][2]);
						TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_text_point_table[lobby][3]);
					}

				 	BlackJackLobby[lobby][StageLobby]++; BlackJackLobby[lobby][DealerTurnGived]++; //+шаг
				}


				case 2: //Раздача первых карт участникам и дилеру //timerlobby
				{
				    switch(BlackJackLobby[lobby][DealerTurnGived])
				    {
				        case 1:
						{
							BlackJackLobby[lobby][DealerTurnGived] = 0; SetTimerEx("TimerDealerNext", 2000, false, "d", lobby);
							TextDrawSetString(bj_log_text[lobby][0], "Дилер выдал себе карту");
							TextDrawColor(bj_log_text[lobby][0], -1);
							TextDrawSetString(bj_log_text[lobby][1], "");
							TextDrawColor(bj_log_text[lobby][1], -65281);

					        new dealer_suit = random(13);
							new dealer_type = random(4);

							BlackJackLobby[lobby][DealerPoint] += BlackJackCard[dealer_suit][dealer_type][Pointscore];
							TextDrawSetString(bj_dealer_card[lobby][1], BlackJackCard[dealer_suit][dealer_type][Cardtexture]);

							if(BlackJackLobby[lobby][Table1Id] != -1)
							{
								new str[2];
								format(str, sizeof str, "%d", BlackJackLobby[lobby][DealerPoint]);
								PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_dealer_point[BlackJackLobby[lobby][Table1Id]], str);
								TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_dealer_card[lobby][1]);
							}
							if(BlackJackLobby[lobby][Table2Id] != -1)
							{
								new str[2];
								format(str, sizeof str, "%d", BlackJackLobby[lobby][DealerPoint]);
								PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_dealer_point[BlackJackLobby[lobby][Table2Id]], str);
								TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_dealer_card[lobby][1]);
							}
							if(BlackJackLobby[lobby][Table3Id] != -1)
							{
								new str[2];
								format(str, sizeof str, "%d", BlackJackLobby[lobby][DealerPoint]);
								PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_dealer_point[BlackJackLobby[lobby][Table3Id]], str);
								TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_dealer_card[lobby][1]);
							}
							if(BlackJackLobby[lobby][Table4Id] != -1)
							{
								new str[2];
								format(str, sizeof str, "%d", BlackJackLobby[lobby][DealerPoint]);
								PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_dealer_point[BlackJackLobby[lobby][Table4Id]], str);
								TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_dealer_card[lobby][1]);
							}
						}
						case 2: BlackJackLobby[lobby][DealerTurnGived]++;
						case 3:
						{
							if(BlackJackLobby[lobby][Table1Id] != -1)
							{
	                            BlackJackLobby[lobby][DealerTurnGived]++;
								new str[10];
								format(str, sizeof str, "%d", BlackJackLobby[lobby][DealerPoint]);
								PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_dealer_point[BlackJackLobby[lobby][Table1Id]], str);

								new suit = random(13);
								new type = random(4);

								BlackJackLobby[lobby][Table1Point] += BlackJackCard[suit][type][Pointscore];

								format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table1Point]);
								TextDrawSetString(bj_text_point_table[lobby][0], str);
								//BlackJackLobby[lobby][Table1Card][0] = class;
								//BlackJackLobby[lobby][Table1Card][1] = type;

								ShowMembersCardBJL(lobby, 1, 0, suit, type);

							}
							else BlackJackLobby[lobby][DealerTurnGived] = 5;
						}
						case 4: BlackJackLobby[lobby][DealerTurnGived]++;

						case 5:
						{
						    if(BlackJackLobby[lobby][Table2Id] != -1)
							{
		                      	BlackJackLobby[lobby][DealerTurnGived]++;
								new str[10];

								new suit = random(13);
								new type = random(4);

								BlackJackLobby[lobby][Table2Point] += BlackJackCard[suit][type][Pointscore];

								format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table2Point]);
								TextDrawSetString(bj_text_point_table[lobby][1], str);
								//BlackJackLobby[lobby][Table1Card][0] = class;
								//BlackJackLobby[lobby][Table1Card][1] = type;

								ShowMembersCardBJL(lobby, 2, 0, suit, type);

							}
							else BlackJackLobby[lobby][DealerTurnGived] = 7;

						}
						case 6: BlackJackLobby[lobby][DealerTurnGived]++;

						case 7:
						{
						    if(BlackJackLobby[lobby][Table3Id] != -1)
							{
	                            BlackJackLobby[lobby][DealerTurnGived]++;
								new str[10];

								new suit = random(13);
								new type = random(4);

								BlackJackLobby[lobby][Table3Point] += BlackJackCard[suit][type][Pointscore];

								format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table3Point]);
								TextDrawSetString(bj_text_point_table[lobby][2], str);
								//BlackJackLobby[lobby][Table1Card][0] = class;
								//BlackJackLobby[lobby][Table1Card][1] = type;

								ShowMembersCardBJL(lobby, 3, 0, suit, type);
							}
							else BlackJackLobby[lobby][DealerTurnGived] = 9;
						}
						case 8: BlackJackLobby[lobby][DealerTurnGived]++;

						case 9:
						{
							BlackJackLobby[lobby][DealerTurnGived] = 1; BlackJackLobby[lobby][StageLobby]++;
					 		if(BlackJackLobby[lobby][Table4Id] != -1)
							{
								new str[10];

								new suit = random(13);
								new type = random(4);

								BlackJackLobby[lobby][Table4Point] += BlackJackCard[suit][type][Pointscore];

								format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table4Point]);
								TextDrawSetString(bj_text_point_table[lobby][3], str);
								//BlackJackLobby[lobby][Table1Card][0] = class;
								//BlackJackLobby[lobby][Table1Card][1] = type;

								ShowMembersCardBJL(lobby, 4, 0, suit, type);
							}
						}
					}
				}


				case 3: //timerlobby
				{
				    switch(BlackJackLobby[lobby][DealerTurnGived])
				    {
				        case 1:
				        {

							//BlackJackLobby[lobby][DealerPoint] += BlackJackCard[dealer_suit][dealer_type][Pointscore];
							TextDrawSetString(bj_dealer_card[lobby][2], "blackjack:cardscard");

							BlackJackLobby[lobby][DealerTurnGived]++;

							if(BlackJackLobby[lobby][Table1Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_dealer_card[lobby][2]);
							if(BlackJackLobby[lobby][Table2Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_dealer_card[lobby][2]);
							if(BlackJackLobby[lobby][Table3Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_dealer_card[lobby][2]);
							if(BlackJackLobby[lobby][Table4Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_dealer_card[lobby][2]);
						}
						case 2: BlackJackLobby[lobby][DealerTurnGived]++;
						case 3:
						{
							if(BlackJackLobby[lobby][Table1Id] != -1)
							{
	                            BlackJackLobby[lobby][DealerTurnGived]++;
								new str[10];
								format(str, sizeof str, "%d", BlackJackLobby[lobby][DealerPoint]);
								PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_dealer_point[BlackJackLobby[lobby][Table1Id]], str);

								new suit = random(13);
								new type = random(4);

								BlackJackLobby[lobby][Table1Point] += BlackJackCard[suit][type][Pointscore];
								CheckTableBlackJack(lobby, 1);



								format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table1Point]);
								TextDrawSetString(bj_text_point_table[lobby][0], str);
								//BlackJackLobby[lobby][Table1Card][0] = class;
								//BlackJackLobby[lobby][Table1Card][1] = type;

								ShowMembersCardBJL(lobby, 1, 1, suit, type);
							}
							else BlackJackLobby[lobby][DealerTurnGived] = 5;
						}
						case 4: BlackJackLobby[lobby][DealerTurnGived]++;

						case 5:
						{
						    if(BlackJackLobby[lobby][Table2Id] != -1)
							{
	                            BlackJackLobby[lobby][DealerTurnGived]++;
								new str[10];
								format(str, sizeof str, "%d", BlackJackLobby[lobby][DealerPoint]);
								PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_dealer_point[BlackJackLobby[lobby][Table2Id]], str);

								new suit = random(13);
								new type = random(4);

								BlackJackLobby[lobby][Table2Point] += BlackJackCard[suit][type][Pointscore];
								CheckTableBlackJack(lobby, 2);

								format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table2Point]);
								TextDrawSetString(bj_text_point_table[lobby][1], str);
								//BlackJackLobby[lobby][Table1Card][0] = class;
								//BlackJackLobby[lobby][Table1Card][1] = type;

								ShowMembersCardBJL(lobby, 2, 1, suit, type);
							}
							else BlackJackLobby[lobby][DealerTurnGived] = 7;

						}
						case 6: BlackJackLobby[lobby][DealerTurnGived]++;

						case 7:
						{
						    if(BlackJackLobby[lobby][Table3Id] != -1)
							{
		                  		BlackJackLobby[lobby][DealerTurnGived]++;
								new str[10];
								format(str, sizeof str, "%d", BlackJackLobby[lobby][DealerPoint]);
								PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_dealer_point[BlackJackLobby[lobby][Table3Id]], str);

								new suit = random(13);
								new type = random(4);

								BlackJackLobby[lobby][Table3Point] += BlackJackCard[suit][type][Pointscore];
								CheckTableBlackJack(lobby, 3);

								format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table3Point]);
								TextDrawSetString(bj_text_point_table[lobby][2], str);
								//BlackJackLobby[lobby][Table1Card][0] = class;
								//BlackJackLobby[lobby][Table1Card][1] = type;

								ShowMembersCardBJL(lobby, 3, 1, suit, type);
							}
							else BlackJackLobby[lobby][DealerTurnGived] = 9;
						}
						case 8: BlackJackLobby[lobby][DealerTurnGived]++;

						case 9:
						{
							BlackJackLobby[lobby][DealerTurnGived] = 0; BlackJackLobby[lobby][StageLobby]++; BlackJackLobby[lobby][TableTurn]++; //очередь участников
					 		if(BlackJackLobby[lobby][Table4Id] != -1)
							{
		                      	BlackJackLobby[lobby][DealerTurnGived]++;
								new str[10];
								format(str, sizeof str, "%d", BlackJackLobby[lobby][DealerPoint]);
								PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_dealer_point[BlackJackLobby[lobby][Table4Id]], str);

								new suit = random(13);
								new type = random(4);

								BlackJackLobby[lobby][Table4Point] += BlackJackCard[suit][type][Pointscore];
								CheckTableBlackJack(lobby, 4);

								format(str, sizeof str, "Очки: %d", BlackJackLobby[lobby][Table4Point]);
								TextDrawSetString(bj_text_point_table[lobby][3], str);
								//BlackJackLobby[lobby][Table1Card][0] = class;
								//BlackJackLobby[lobby][Table1Card][1] = type;

								ShowMembersCardBJL(lobby, 4, 1, suit, type);
							}
						}
					}


				}

                case 4: //timerlobby
				{
    				switch(BlackJackLobby[lobby][TableTurn])
    				{
        				case 1:
        				{
        				    if(BlackJackLobby[lobby][Table1Id] != -1)
        				    {
            				    if(BlackJackLobby[lobby][Table1Point] == 21 || BlackJackLobby[lobby][Table1Point] > 21) return BlackJackLobby[lobby][TableTurnTime] = 0, BlackJackLobby[lobby][TableTurn]++;
            				    if(BlackJackLobby[lobby][TableTurnTime] == 0)
            				    {
            				        BlackJackLobby[lobby][TableTurnTime] = 15;
            				        PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]], "blackjack:brbjyouturn");
            				        PlayerTextDrawShow(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]]);
            				        SetTimerEx("TimerHideYouTurn", 2000, false, "d", BlackJackLobby[lobby][Table1Id]);

        				            new str[24];
        				            TextDrawSetString(bj_log_text[lobby][0], "Ваш ход 00:15");
        				            TextDrawColor(bj_log_text[lobby][0], -1);
        				            GetPlayerName(BlackJackLobby[lobby][Table1Id], str, 24);
        				            TextDrawSetString(bj_log_text[lobby][1], str);
        				            TextDrawColor(bj_log_text[lobby][1], -65281);
        				        }
        				        else if(BlackJackLobby[lobby][TableTurnTime] == 1)
        				        {
        				            BlackJackLobby[lobby][TableTurnTime]--;
       				                BlackJackLobby[lobby][TableTurn]++;

        				            TextDrawSetString(bj_log_text[lobby][0], "Время истекло");
        				            TextDrawColor(bj_log_text[lobby][0], -1);
        				        }
        				        else
        				        {
        				            BlackJackLobby[lobby][TableTurnTime]--;
        				            new str[24];
        				            format(str, sizeof str, "Ваш ход 00:%02d", BlackJackLobby[lobby][TableTurnTime]);
        				            TextDrawSetString(bj_log_text[lobby][0], str);
        				            TextDrawColor(bj_log_text[lobby][0], -1);
        				        }
        				    }
        				    else BlackJackLobby[lobby][TableTurn]++;
        				}
        				case 2:
        				{
        				    if(BlackJackLobby[lobby][Table2Id] != -1)
        				    {
        				        if(BlackJackLobby[lobby][Table2Point] == 21 || BlackJackLobby[lobby][Table2Point] > 21) return BlackJackLobby[lobby][TableTurnTime] = 0, BlackJackLobby[lobby][TableTurn]++;
        				        if(BlackJackLobby[lobby][TableTurnTime] == 0)
        				        {
            				        BlackJackLobby[lobby][TableTurnTime] = 15;
        				            PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]], "blackjack:brbjyouturn");
        				            PlayerTextDrawShow(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]]);
        				            SetTimerEx("TimerHideYouTurn", 2000, false, "d", BlackJackLobby[lobby][Table2Id]);

        				            new str[24];
        				            TextDrawSetString(bj_log_text[lobby][0], "Ваш ход 00:15");
        				            TextDrawColor(bj_log_text[lobby][0], -1);
        				            GetPlayerName(BlackJackLobby[lobby][Table2Id], str, 24);
        				            TextDrawSetString(bj_log_text[lobby][1], str);
        				            TextDrawColor(bj_log_text[lobby][1], -65281);
        				        }
        				        else if(BlackJackLobby[lobby][TableTurnTime] == 1)
        				        {
        				            BlackJackLobby[lobby][TableTurnTime]--;
        				            BlackJackLobby[lobby][TableTurn]++;

        				            TextDrawSetString(bj_log_text[lobby][0], "Время истекло");
        				            TextDrawColor(bj_log_text[lobby][0], -1);
        				        }
        				        else
        				        {
        				            BlackJackLobby[lobby][TableTurnTime]--;
        				            new str[24];
        				            format(str, sizeof str, "Ваш ход 00:%02d", BlackJackLobby[lobby][TableTurnTime]);
        				            TextDrawSetString(bj_log_text[lobby][0], str);
        				            TextDrawColor(bj_log_text[lobby][0], -1);
        				        }
        				    }
        				    else BlackJackLobby[lobby][TableTurn]++;
        				}
        				case 3:
        				{
        				    if(BlackJackLobby[lobby][Table3Id] != -1)
        				    {
        				        if(BlackJackLobby[lobby][Table3Point] == 21 || BlackJackLobby[lobby][Table3Point] > 21) return BlackJackLobby[lobby][TableTurnTime] = 0, BlackJackLobby[lobby][TableTurn]++;
        				        if(BlackJackLobby[lobby][TableTurnTime] == 0)
        				        {
        				            BlackJackLobby[lobby][TableTurnTime] = 15;
        				            PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]], "blackjack:brbjyouturn");
        				            PlayerTextDrawShow(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]]);
        				            SetTimerEx("TimerHideYouTurn", 2000, false, "d", BlackJackLobby[lobby][Table3Id]);

        				            new str[24];
        				            TextDrawSetString(bj_log_text[lobby][0], "Ваш ход 00:15");
        				            TextDrawColor(bj_log_text[lobby][0], -1);
        				            GetPlayerName(BlackJackLobby[lobby][Table3Id], str, 24);
        				            TextDrawSetString(bj_log_text[lobby][1], str);
        				            TextDrawColor(bj_log_text[lobby][1], -65281);
        				        }
        				        else if(BlackJackLobby[lobby][TableTurnTime] == 1)
        				        {
        				            BlackJackLobby[lobby][TableTurnTime]--;
        				            BlackJackLobby[lobby][TableTurn]++;

        				            TextDrawSetString(bj_log_text[lobby][0], "Время истекло");
        				            TextDrawColor(bj_log_text[lobby][0], -1);
        				        }
        				        else
        				        {
        				            BlackJackLobby[lobby][TableTurnTime]--;
        				            new str[24];
        				            format(str, sizeof str, "Ваш ход 00:%02d", BlackJackLobby[lobby][TableTurnTime]);
                    				TextDrawSetString(bj_log_text[lobby][0], str);
                    				TextDrawColor(bj_log_text[lobby][0], -1);
                				}
            				}
            				else BlackJackLobby[lobby][TableTurn]++;
				        }
      				     case 4:
        				{
            				if(BlackJackLobby[lobby][Table4Id] != -1)
            				{
                				if(BlackJackLobby[lobby][Table4Point] == 21 || BlackJackLobby[lobby][Table4Point] > 21) return BlackJackLobby[lobby][TableTurnTime] = 0, BlackJackLobby[lobby][TableTurn]++;
                				if(BlackJackLobby[lobby][TableTurnTime] == 0)
                				{
                    				BlackJackLobby[lobby][TableTurnTime] = 15;
                    				PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]], "blackjack:brbjyouturn");
                    				PlayerTextDrawShow(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]]);
                    				SetTimerEx("TimerHideYouTurn", 2000, false, "d", BlackJackLobby[lobby][Table4Id]);

                    				new str[24];
                    				TextDrawSetString(bj_log_text[lobby][0], "Ваш ход 00:15");
                    				TextDrawColor(bj_log_text[lobby][0], -1);
                    				GetPlayerName(BlackJackLobby[lobby][Table4Id], str, 24);
                    				TextDrawSetString(bj_log_text[lobby][1], str);
                    				TextDrawColor(bj_log_text[lobby][1], -65281);
                				}
                				else if(BlackJackLobby[lobby][TableTurnTime] == 1)
                				{
                    				BlackJackLobby[lobby][TableTurnTime]--;
                    				BlackJackLobby[lobby][TableTurn]++;

                    				TextDrawSetString(bj_log_text[lobby][0], "Время истекло");
                    				TextDrawColor(bj_log_text[lobby][0], -1);
                				}
                				else
                				{
                    				BlackJackLobby[lobby][TableTurnTime]--;
                    				new str[24];
                    				format(str, sizeof str, "Ваш ход 00:%02d", BlackJackLobby[lobby][TableTurnTime]);
                    				TextDrawSetString(bj_log_text[lobby][0], str);
                    				TextDrawColor(bj_log_text[lobby][0], -1);
                				}
            				}
            				else BlackJackLobby[lobby][TableTurn]++;
        				}
        				case 5: { BlackJackLobby[lobby][TableTurn] = 0; BlackJackLobby[lobby][TableTurnTime] = 0; BlackJackLobby[lobby][StageLobby]++; }
    				}
				}

				case 5: //timerlobby //раздача дилеру последней карты
				{
    				TextDrawSetString(bj_log_text[lobby][0], "Дилер открыл карту");
    				TextDrawColor(bj_log_text[lobby][0], -1);
    				TextDrawSetString(bj_log_text[lobby][1], "");
    				TextDrawColor(bj_log_text[lobby][1], -65281);

    				new dealer_suit = random(13);
    				new dealer_type = random(4);

    				BlackJackLobby[lobby][DealerPoint] += BlackJackCard[dealer_suit][dealer_type][Pointscore];

    				TextDrawSetString(bj_dealer_card[lobby][2], BlackJackCard[dealer_suit][dealer_type][Cardtexture]);

    				new str[10];
    				format(str, sizeof str, "%d", BlackJackLobby[lobby][DealerPoint]);

    				if(BlackJackLobby[lobby][Table1Id] != -1) PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_dealer_point[BlackJackLobby[lobby][Table1Id]], str); TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_dealer_card[lobby][2]);
    				if(BlackJackLobby[lobby][Table2Id] != -1) PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_dealer_point[BlackJackLobby[lobby][Table2Id]], str); TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_dealer_card[lobby][2]);
    				if(BlackJackLobby[lobby][Table3Id] != -1) PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_dealer_point[BlackJackLobby[lobby][Table3Id]], str); TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_dealer_card[lobby][2]);
    				if(BlackJackLobby[lobby][Table4Id] != -1) PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_dealer_point[BlackJackLobby[lobby][Table4Id]], str); TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_dealer_card[lobby][2]);

    				if(BlackJackLobby[lobby][DealerPoint] < 16) BlackJackLobby[lobby][StageLobby]++;
    				else BlackJackLobby[lobby][StageLobby] = 7;
				}
				case 6:
				{
    				new dealer_suit = random(13);
    				new dealer_type = random(4);

    				BlackJackLobby[lobby][DealerPoint] += BlackJackCard[dealer_suit][dealer_type][Pointscore];

    				TextDrawSetString(bj_dealer_card[lobby][3], BlackJackCard[dealer_suit][dealer_type][Cardtexture]);

    				TextDrawSetString(bj_log_text[lobby][0], "Дилер взял себе карту");
    				TextDrawColor(bj_log_text[lobby][0], -1);

    				new str[10];
    				format(str, sizeof str, "%d", BlackJackLobby[lobby][DealerPoint]);

    				if(BlackJackLobby[lobby][Table1Id] != -1) PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_dealer_point[BlackJackLobby[lobby][Table1Id]], str); TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_dealer_card[lobby][3]);
    				if(BlackJackLobby[lobby][Table2Id] != -1) PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_dealer_point[BlackJackLobby[lobby][Table2Id]], str); TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_dealer_card[lobby][3]);
    				if(BlackJackLobby[lobby][Table3Id] != -1) PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_dealer_point[BlackJackLobby[lobby][Table3Id]], str); TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_dealer_card[lobby][3]);
   				    if(BlackJackLobby[lobby][Table4Id] != -1) PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_dealer_point[BlackJackLobby[lobby][Table4Id]], str); TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_dealer_card[lobby][3]);

  				    BlackJackLobby[lobby][StageLobby]++;
				}
				case 7: //timerlobby //результаты result
				{
					if(BlackJackLobby[lobby][Table1Id] != -1)
					{
					    if(BlackJackLobby[lobby][DealerPoint] == BlackJackLobby[lobby][Table1Point] || (BlackJackLobby[lobby][DealerPoint] > 21 && BlackJackLobby[lobby][Table1Point] > 21))
					    {
				            PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]], "blackjack:brbjdraw");
					    	PlayerTextDrawShow(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]]);
				            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table1Id], pBJInfo[BlackJackLobby[lobby][Table1Id]][pBJBet]);

					       	TextDrawSetString(bj_result_table[lobby][0], "blackjack:brbjmydraw");
					    }
					    else if(BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table1Point] < 21)
					    {
							if(BlackJackLobby[lobby][DealerPoint] > BlackJackLobby[lobby][Table1Point])
							{
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]], "blackjack:brbjyoulose");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]]);

					            TextDrawSetString(bj_result_table[lobby][0], "blackjack:brbjlose");
							}
							else
							{
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]], "blackjack:brbjyouwin");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]]);
					            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table1Id], pBJInfo[BlackJackLobby[lobby][Table1Id]][pBJBet]*2);
                                BJNotifyWin(BlackJackLobby[lobby][Table1Id], pBJInfo[BlackJackLobby[lobby][Table1Id]][pBJBet]*2);

					            TextDrawSetString(bj_result_table[lobby][0], "blackjack:brbjwin");
							}
					    }

					    else if((BlackJackLobby[lobby][DealerPoint] == 21 && BlackJackLobby[lobby][Table1Point] < 21) || (BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table1Point] > 21))
					    {
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]], "blackjack:brbjyoulose");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]]);

					            TextDrawSetString(bj_result_table[lobby][0], "blackjack:brbjlose");
					    }
					    else if((BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table1Point] == 21) || (BlackJackLobby[lobby][DealerPoint] > 21 && BlackJackLobby[lobby][Table1Point] < 21))
					    {
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]], "blackjack:brbjyouwin");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table1Id], bj_panel_info[BlackJackLobby[lobby][Table1Id]]);
					            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table1Id], pBJInfo[BlackJackLobby[lobby][Table1Id]][pBJBet]*2);
                                BJNotifyWin(BlackJackLobby[lobby][Table1Id], pBJInfo[BlackJackLobby[lobby][Table1Id]][pBJBet]*2);

					            TextDrawSetString(bj_result_table[lobby][0], "blackjack:brbjwin");
					    }
					}

					if(BlackJackLobby[lobby][Table2Id] != -1)
					{
					    if(BlackJackLobby[lobby][DealerPoint] == BlackJackLobby[lobby][Table2Point] || (BlackJackLobby[lobby][DealerPoint] > 21 && BlackJackLobby[lobby][Table2Point] > 21))
					    {
				            PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]], "blackjack:brbjdraw");
					    	PlayerTextDrawShow(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]]);
				            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table2Id], pBJInfo[BlackJackLobby[lobby][Table2Id]][pBJBet]);

					       	TextDrawSetString(bj_result_table[lobby][1], "blackjack:brbjmydraw");
					    }
					    else if(BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table2Point] < 21)
					    {
							if(BlackJackLobby[lobby][DealerPoint] > BlackJackLobby[lobby][Table2Point])
							{
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]], "blackjack:brbjyoulose");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]]);

					            TextDrawSetString(bj_result_table[lobby][1], "blackjack:brbjlose");
							}
							else
							{
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]], "blackjack:brbjyouwin");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]]);
					            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table2Id], pBJInfo[BlackJackLobby[lobby][Table2Id]][pBJBet]*2);
                                BJNotifyWin(BlackJackLobby[lobby][Table2Id], pBJInfo[BlackJackLobby[lobby][Table2Id]][pBJBet]*2);

					            TextDrawSetString(bj_result_table[lobby][1], "blackjack:brbjwin");
							}
					    }

					    else if((BlackJackLobby[lobby][DealerPoint] == 21 && BlackJackLobby[lobby][Table2Point] < 21) || (BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table2Point] > 21))
					    {
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]], "blackjack:brbjyoulose");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]]);

					            TextDrawSetString(bj_result_table[lobby][1], "blackjack:brbjlose");
					    }
					    else if((BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table2Point] == 21) || (BlackJackLobby[lobby][DealerPoint] > 21 && BlackJackLobby[lobby][Table2Point] < 21))
					    {
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]], "blackjack:brbjyouwin");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table2Id], bj_panel_info[BlackJackLobby[lobby][Table2Id]]);
					            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table2Id], pBJInfo[BlackJackLobby[lobby][Table2Id]][pBJBet]*2);
                                BJNotifyWin(BlackJackLobby[lobby][Table2Id], pBJInfo[BlackJackLobby[lobby][Table2Id]][pBJBet]*2);

					            TextDrawSetString(bj_result_table[lobby][1], "blackjack:brbjwin");
					    }
					}


					if(BlackJackLobby[lobby][Table3Id] != -1)
					{
					    if(BlackJackLobby[lobby][DealerPoint] == BlackJackLobby[lobby][Table3Point] || (BlackJackLobby[lobby][DealerPoint] > 21 && BlackJackLobby[lobby][Table3Point] > 21))
					    {
				            PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]], "blackjack:brbjdraw");
					    	PlayerTextDrawShow(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]]);
				            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table3Id], pBJInfo[BlackJackLobby[lobby][Table3Id]][pBJBet]);

					       	TextDrawSetString(bj_result_table[lobby][2], "blackjack:brbjmydraw");
					    }
					    else if(BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table3Point] < 21)
					    {
							if(BlackJackLobby[lobby][DealerPoint] > BlackJackLobby[lobby][Table3Point])
							{
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]], "blackjack:brbjyoulose");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]]);

					            TextDrawSetString(bj_result_table[lobby][2], "blackjack:brbjlose");
							}
							else
							{
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]], "blackjack:brbjyouwin");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]]);
					            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table3Id], pBJInfo[BlackJackLobby[lobby][Table3Id]][pBJBet]*2);
                                BJNotifyWin(BlackJackLobby[lobby][Table3Id], pBJInfo[BlackJackLobby[lobby][Table3Id]][pBJBet]*2);

					            TextDrawSetString(bj_result_table[lobby][2], "blackjack:brbjwin");
							}
					    }

					    else if((BlackJackLobby[lobby][DealerPoint] == 21 && BlackJackLobby[lobby][Table3Point] < 21) || (BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table3Point] > 21))
					    {
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]], "blackjack:brbjyoulose");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]]);

					            TextDrawSetString(bj_result_table[lobby][2], "blackjack:brbjlose");
					    }
					    else if((BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table3Point] == 21) || (BlackJackLobby[lobby][DealerPoint] > 21 && BlackJackLobby[lobby][Table3Point] < 21))
					    {
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]], "blackjack:brbjyouwin");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table3Id], bj_panel_info[BlackJackLobby[lobby][Table3Id]]);
					            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table3Id], pBJInfo[BlackJackLobby[lobby][Table3Id]][pBJBet]*2);
                                BJNotifyWin(BlackJackLobby[lobby][Table3Id], pBJInfo[BlackJackLobby[lobby][Table3Id]][pBJBet]*2);

					            TextDrawSetString(bj_result_table[lobby][2], "blackjack:brbjwin");
					    }
					}

					if(BlackJackLobby[lobby][Table4Id] != -1)
					{
					    if(BlackJackLobby[lobby][DealerPoint] == BlackJackLobby[lobby][Table4Point] || (BlackJackLobby[lobby][DealerPoint] > 21 && BlackJackLobby[lobby][Table4Point] > 21))
					    {
				            PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]], "blackjack:brbjdraw");
					    	PlayerTextDrawShow(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]]);
				            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table4Id], pBJInfo[BlackJackLobby[lobby][Table4Id]][pBJBet]);

					       	TextDrawSetString(bj_result_table[lobby][3], "blackjack:brbjmydraw");
					    }
					    else if(BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table4Point] < 21)
					    {
							if(BlackJackLobby[lobby][DealerPoint] > BlackJackLobby[lobby][Table4Point])
							{
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]], "blackjack:brbjyoulose");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]]);

					            TextDrawSetString(bj_result_table[lobby][3], "blackjack:brbjlose");
							}
							else
							{
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]], "blackjack:brbjyouwin");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]]);
					            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table4Id], pBJInfo[BlackJackLobby[lobby][Table4Id]][pBJBet]*2);
                                BJNotifyWin(BlackJackLobby[lobby][Table4Id], pBJInfo[BlackJackLobby[lobby][Table4Id]][pBJBet]*2);

					            TextDrawSetString(bj_result_table[lobby][3], "blackjack:brbjwin");
							}
					    }

					    else if((BlackJackLobby[lobby][DealerPoint] == 21 && BlackJackLobby[lobby][Table4Point] < 21) || (BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table4Point] > 21))
					    {
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]], "blackjack:brbjyoulose");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]]);

					            TextDrawSetString(bj_result_table[lobby][3], "blackjack:brbjlose");
					    }
					    else if((BlackJackLobby[lobby][DealerPoint] < 21 && BlackJackLobby[lobby][Table4Point] == 21) || (BlackJackLobby[lobby][DealerPoint] > 21 && BlackJackLobby[lobby][Table4Point] < 21))
					    {
					            PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]], "blackjack:brbjyouwin");
						    	PlayerTextDrawShow(BlackJackLobby[lobby][Table4Id], bj_panel_info[BlackJackLobby[lobby][Table4Id]]);
					            GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table4Id], pBJInfo[BlackJackLobby[lobby][Table4Id]][pBJBet]*2);
                                BJNotifyWin(BlackJackLobby[lobby][Table4Id], pBJInfo[BlackJackLobby[lobby][Table4Id]][pBJBet]*2);

					            TextDrawSetString(bj_result_table[lobby][3], "blackjack:brbjwin");
					    }
     				}


                    if(BlackJackLobby[lobby][Table1Id] != -1) BJUpdateMoneyLabel(BlackJackLobby[lobby][Table1Id]);
                    if(BlackJackLobby[lobby][Table2Id] != -1) BJUpdateMoneyLabel(BlackJackLobby[lobby][Table2Id]);
                    if(BlackJackLobby[lobby][Table3Id] != -1) BJUpdateMoneyLabel(BlackJackLobby[lobby][Table3Id]);
                    if(BlackJackLobby[lobby][Table4Id] != -1) BJUpdateMoneyLabel(BlackJackLobby[lobby][Table4Id]);
					BlackJackLobby[lobby][StageLobby]++;
				}
				case 8:
				{
     				if(BlackJackLobby[lobby][Table1Id] != -1)
			 		{
					 	TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_result_table[lobby][0]);
					 	if(BlackJackLobby[lobby][Table2Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_result_table[lobby][1]);
					 	if(BlackJackLobby[lobby][Table3Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_result_table[lobby][2]);
					 	if(BlackJackLobby[lobby][Table4Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_result_table[lobby][3]);
				    }
     				if(BlackJackLobby[lobby][Table2Id] != -1)
			 		{
					 	if(BlackJackLobby[lobby][Table1Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_result_table[lobby][0]);
					 	TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_result_table[lobby][1]);
					 	if(BlackJackLobby[lobby][Table3Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_result_table[lobby][2]);
					 	if(BlackJackLobby[lobby][Table4Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_result_table[lobby][3]);
				    }
     				if(BlackJackLobby[lobby][Table3Id] != -1)
			 		{
					 	if(BlackJackLobby[lobby][Table1Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_result_table[lobby][0]);
					 	if(BlackJackLobby[lobby][Table2Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_result_table[lobby][1]);
					 	TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_result_table[lobby][2]);
					 	if(BlackJackLobby[lobby][Table4Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_result_table[lobby][3]);
				    }
     				if(BlackJackLobby[lobby][Table4Id] != -1)
			 		{
					 	if(BlackJackLobby[lobby][Table1Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_result_table[lobby][0]);
					 	if(BlackJackLobby[lobby][Table2Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_result_table[lobby][1]);
					 	if(BlackJackLobby[lobby][Table3Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_result_table[lobby][2]);
					 	TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_result_table[lobby][3]);
				    }
					BlackJackLobby[lobby][StageLobby]++;
				}
				case 9: BlackJackLobby[lobby][StageLobby]++;
				case 10: BlackJackLobby[lobby][StageLobby]++;
				case 11: //end
				{
	            	TextDrawSetString(bj_text_point_table[lobby][0], "Очки: 0");
					TextDrawSetString(bj_text_point_table[lobby][1], "Очки: 0");
					TextDrawSetString(bj_text_point_table[lobby][2], "Очки: 0");
					TextDrawSetString(bj_text_point_table[lobby][3], "Очки: 0");

					BlackJackLobby[lobby][Table1Result] = 0;
					BlackJackLobby[lobby][Table2Result] = 0;
					BlackJackLobby[lobby][Table3Result] = 0;
					BlackJackLobby[lobby][Table4Result] = 0;

                    BlackJackLobby[lobby][DealerPoint] = 0;
                    BlackJackLobby[lobby][Table1Point] = 0;
                    BlackJackLobby[lobby][Table2Point] = 0;
                    BlackJackLobby[lobby][Table3Point] = 0;
                    BlackJackLobby[lobby][Table4Point] = 0;
                    BlackJackLobby[lobby][TableTurn] = 0;
                    BlackJackLobby[lobby][TableTurnTime] = 0;
                    BlackJackLobby[lobby][DealerTurnGived] = 0;

					BlackJackLobby[lobby][StageLobby]++;
				}
				case 12:
				{
					BlackJackLobby[lobby][StageLobby]++;
					if(BlackJackLobby[lobby][Table1Id] != -1) BJResetRoundPlayer(BlackJackLobby[lobby][Table1Id], lobby);
				}
				case 13:
				{
					BlackJackLobby[lobby][StageLobby]++;
					if(BlackJackLobby[lobby][Table2Id] != -1) BJResetRoundPlayer(BlackJackLobby[lobby][Table2Id], lobby);
				}
				case 14:
				{
					BlackJackLobby[lobby][StageLobby]++;
					if(BlackJackLobby[lobby][Table3Id] != -1) BJResetRoundPlayer(BlackJackLobby[lobby][Table3Id], lobby);
				}
				case 15:
				{
    				BlackJackLobby[lobby][StageLobby] = 0;
					BlackJackLobby[lobby][StartedLobby] = false;
					if(BlackJackLobby[lobby][Table4Id] != -1) BJResetRoundPlayer(BlackJackLobby[lobby][Table4Id], lobby);
				}
			}
	    }
		else
	    {
	        if(BlackJackLobby[lobby][StartTimer]-1 == 0)
			{
				BlackJackLobby[lobby][StartedLobby] = true; BlackJackLobby[lobby][StageLobby] = 1; SnowNotificarionBJL(lobby, "Игра началась!", 3);

				printf("Стол 1: %d", BlackJackLobby[lobby][Table1Id]);
				printf("Стол 2: %d", BlackJackLobby[lobby][Table2Id]);
				printf("Стол 3: %d", BlackJackLobby[lobby][Table3Id]);
				printf("Стол 4: %d", BlackJackLobby[lobby][Table4Id]);

				for(new a;a < 12;a++)  SendClientMessage(BlackJackLobby[lobby][Table1Id], 0xFFFFFFFF, "");
				for(new a;a < 12;a++)  SendClientMessage(BlackJackLobby[lobby][Table2Id], 0xFFFFFFFF, "");
				for(new a;a < 12;a++)  SendClientMessage(BlackJackLobby[lobby][Table3Id], 0xFFFFFFFF, "");
				for(new a;a < 12;a++)  SendClientMessage(BlackJackLobby[lobby][Table4Id], 0xFFFFFFFF, "");

				new str[96];

                if(BlackJackLobby[lobby][Table1Id] != -1) {
					if(!pBJInfo[BlackJackLobby[lobby][Table1Id]][pBJBet]) { SCM(BlackJackLobby[lobby][Table1Id], CYELLOW, "| "CW"Продолжать играть могут только те кто поставил ставку"); ExitPlayerLobby(BlackJackLobby[lobby][Table1Id], lobby, 1); }
					else if(GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table1Id], -pBJInfo[BlackJackLobby[lobby][Table1Id]][pBJBet], "BlackJack Bet", true, false) != 1) { SCM(BlackJackLobby[lobby][Table1Id], CYELLOW, "Недостаточно средств для ставки"); ExitPlayerLobby(BlackJackLobby[lobby][Table1Id], lobby, 1); }
					else { format(str, sizeof str, "Вы потратили %d рублей", pBJInfo[BlackJackLobby[lobby][Table1Id]][pBJBet]); ShowNotificationNew(BlackJackLobby[lobby][Table1Id], 2, 6, 0, 0, str, "qq"); BJUpdateMoneyLabel(BlackJackLobby[lobby][Table1Id]); }
				}
			    if(BlackJackLobby[lobby][Table2Id] != -1) {
					if(!pBJInfo[BlackJackLobby[lobby][Table2Id]][pBJBet]) { SCM(BlackJackLobby[lobby][Table2Id], CYELLOW, "| "CW"Продолжать играть могут только те кто поставил ставку"); ExitPlayerLobby(BlackJackLobby[lobby][Table2Id], lobby, 2); }
					else if(GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table2Id], -pBJInfo[BlackJackLobby[lobby][Table2Id]][pBJBet], "BlackJack Bet", true, false) != 1) { SCM(BlackJackLobby[lobby][Table2Id], CYELLOW, "Недостаточно средств для ставки"); ExitPlayerLobby(BlackJackLobby[lobby][Table2Id], lobby, 2); }
					else { format(str, sizeof str, "Вы потратили %d рублей", pBJInfo[BlackJackLobby[lobby][Table2Id]][pBJBet]); ShowNotificationNew(BlackJackLobby[lobby][Table2Id], 2, 6, 0, 0, str, "qq"); BJUpdateMoneyLabel(BlackJackLobby[lobby][Table2Id]); }
				}
			    if(BlackJackLobby[lobby][Table3Id] != -1) {
					if(!pBJInfo[BlackJackLobby[lobby][Table3Id]][pBJBet]) { SCM(BlackJackLobby[lobby][Table3Id], CYELLOW, "| "CW"Продолжать играть могут только те кто поставил ставку"); ExitPlayerLobby(BlackJackLobby[lobby][Table3Id], lobby, 3); }
					else if(GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table3Id], -pBJInfo[BlackJackLobby[lobby][Table3Id]][pBJBet], "BlackJack Bet", true, false) != 1) { SCM(BlackJackLobby[lobby][Table3Id], CYELLOW, "Недостаточно средств для ставки"); ExitPlayerLobby(BlackJackLobby[lobby][Table3Id], lobby, 3); }
					else { format(str, sizeof str, "Вы потратили %d рублей", pBJInfo[BlackJackLobby[lobby][Table3Id]][pBJBet]); ShowNotificationNew(BlackJackLobby[lobby][Table3Id], 2, 6, 0, 0, str, "qq"); BJUpdateMoneyLabel(BlackJackLobby[lobby][Table3Id]); }
				}
			    if(BlackJackLobby[lobby][Table4Id] != -1) {
					if(!pBJInfo[BlackJackLobby[lobby][Table4Id]][pBJBet]) { SCM(BlackJackLobby[lobby][Table4Id], CYELLOW, "| "CW"Продолжать играть могут только те кто поставил ставку"); ExitPlayerLobby(BlackJackLobby[lobby][Table4Id], lobby, 4); }
					else if(GivePlayerMoneyBjEx(BlackJackLobby[lobby][Table4Id], -pBJInfo[BlackJackLobby[lobby][Table4Id]][pBJBet], "BlackJack Bet", true, false) != 1) { SCM(BlackJackLobby[lobby][Table4Id], CYELLOW, "Недостаточно средств для ставки"); ExitPlayerLobby(BlackJackLobby[lobby][Table4Id], lobby, 4); }
					else { format(str, sizeof str, "Вы потратили %d рублей", pBJInfo[BlackJackLobby[lobby][Table4Id]][pBJBet]); ShowNotificationNew(BlackJackLobby[lobby][Table4Id], 2, 6, 0, 0, str, "qq"); BJUpdateMoneyLabel(BlackJackLobby[lobby][Table4Id]); }
				}



				BlackJackLobby[lobby][StartTimer] = 60;

				if(BlackJackLobby[lobby][Table1Id] != -1) {
					TextDrawHideForPlayer(BlackJackLobby[lobby][Table1Id], bj_text_start_time);
					TextDrawHideForPlayer(BlackJackLobby[lobby][Table1Id], bj_text_start_timer[lobby]);
				}
				if(BlackJackLobby[lobby][Table2Id] != -1) {
					TextDrawHideForPlayer(BlackJackLobby[lobby][Table2Id], bj_text_start_time);
					TextDrawHideForPlayer(BlackJackLobby[lobby][Table2Id], bj_text_start_timer[lobby]);
				}
				if(BlackJackLobby[lobby][Table3Id] != -1) {
					TextDrawHideForPlayer(BlackJackLobby[lobby][Table3Id], bj_text_start_time);
					TextDrawHideForPlayer(BlackJackLobby[lobby][Table3Id], bj_text_start_timer[lobby]);
				}
				if(BlackJackLobby[lobby][Table4Id] != -1) {
					TextDrawHideForPlayer(BlackJackLobby[lobby][Table4Id], bj_text_start_time);
					TextDrawHideForPlayer(BlackJackLobby[lobby][Table4Id], bj_text_start_timer[lobby]);
				}
			}
		    else
			{
				BlackJackLobby[lobby][StartTimer]--;
			    new timer[6];
				format(timer, sizeof timer, "00:%02d", BlackJackLobby[lobby][StartTimer]);
				TextDrawSetString(bj_text_start_timer[lobby], timer);
			}
	    }
	}
	else
	{ //timerdeath
	    BlackJackLobby[lobby][ActivedLobby] = false;
		BlackJackLobby[lobby][StartedLobby] = false;
		BlackJackLobby[lobby][StartTimer] = 60;
		BlackJackLobby[lobby][StageLobby] = 0;
		BlackJackLobby[lobby][TableTurnTime] = 0;
		BlackJackLobby[lobby][TableTurn] = 0;
	    BlackJackLobby[lobby][DealerPoint] = 0;

		TextDrawSetString(bj_text_start_timer[lobby], "00:60");

		BlackJackLobby[lobby][Table1Point] = 0;
		BlackJackLobby[lobby][Table2Point] = 0;
		BlackJackLobby[lobby][Table3Point] = 0;
		BlackJackLobby[lobby][Table4Point] = 0;

		BlackJackLobby[lobby][Table1Result] = 0;
		BlackJackLobby[lobby][Table2Result] = 0;
		BlackJackLobby[lobby][Table3Result] = 0;
		BlackJackLobby[lobby][Table4Result] = 0;

        TextDrawSetString(bj_log_text[lobby][0], "");
        TextDrawSetString(bj_log_text[lobby][1], "");
	}
	return 1;
}

forward TimerDealerNext(lobby);
public TimerDealerNext(lobby)
{
	BlackJackLobby[lobby][DealerTurnGived] = 3;
}

forward TimerHideBetText(playerid);
public TimerHideBetText(playerid)
{
	TextDrawHideForPlayer(playerid, bj_text_bet[0]);
	TextDrawHideForPlayer(playerid, bj_text_bet[1]);
}
forward TimerHideYouTurn(playerid);
public TimerHideYouTurn(playerid) PlayerTextDrawHide(playerid, bj_panel_info[playerid]);



stock BJAdvanceTurnIfCurrent(playerid, lobby)
{
    if(BlackJackLobby[lobby][TableTurn] == pBJInfo[playerid][pBJTable])
    {
        PlayerTextDrawHide(playerid, bj_panel_info[playerid]);
        BlackJackLobby[lobby][TableTurnTime] = 0;
        BlackJackLobby[lobby][TableTurn]++;
    }
}
stock BJNotifyWin(playerid, amount)
{
    if(playerid == -1 || amount <= 0) return 1;
    new notify_str[96];
    format(notify_str, sizeof notify_str, "Вы получили %d рублей", amount);
    ShowNotificationNew(playerid, 3, 6, 0, 0, notify_str, " ");
    return 1;
}

stock BJUpdateMoneyLabel(playerid)
{
	if(playerid == -1) return 1;
	new str[24];
	format(str, sizeof str, "%d py?", GetPlayerMoneyEx(playerid));
	PlayerTextDrawSetString(playerid, bj_money[playerid], str);
	return 1;
}

stock BJResetRoundPlayer(playerid, lobby)
{
    if(playerid == -1) return 1;

    pBJInfo[playerid][pBJBet] = 0;
    pBJInfo[playerid][pBJTakedCard] = 0;

    PlayerTextDrawSetString(playerid, bj_bet[playerid], "0 py?");
    PlayerTextDrawSetString(playerid, bj_dealer_point[playerid], "0");
    BJUpdateMoneyLabel(playerid);

    PlayerTextDrawHide(playerid, bj_panel_info[playerid]);
    PlayerTextDrawSetString(playerid, bj_panel_info[playerid], "blackjack:brbjyouturn");

    TextDrawHideForPlayer(playerid, bj_dealer_score);
    TextDrawHideForPlayer(playerid, bj_log_text[lobby][0]);
    TextDrawHideForPlayer(playerid, bj_log_text[lobby][1]);

    TextDrawHideForPlayer(playerid, bj_dealer_card[lobby][1]);
    TextDrawHideForPlayer(playerid, bj_dealer_card[lobby][2]);
    TextDrawHideForPlayer(playerid, bj_dealer_card[lobby][3]);

    TextDrawHideForPlayer(playerid, bj_result_table[lobby][0]);
    TextDrawHideForPlayer(playerid, bj_result_table[lobby][1]);
    TextDrawHideForPlayer(playerid, bj_result_table[lobby][2]);
    TextDrawHideForPlayer(playerid, bj_result_table[lobby][3]);

    TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][0]);
    TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][1]);
    TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][2]);
    TextDrawHideForPlayer(playerid, bj_text_bj_table[lobby][3]);

    TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][0]);
    TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][1]);
    TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][2]);
    TextDrawHideForPlayer(playerid, bj_text_point_table[lobby][3]);

    for(new i = 1; i <= 4; i++)
    {
        PlayerTextDrawHide(playerid, bj_card_table[playerid][i][0]);
        PlayerTextDrawHide(playerid, bj_card_table[playerid][i][1]);
        PlayerTextDrawHide(playerid, bj_card_table[playerid][i][2]);
        PlayerTextDrawHide(playerid, bj_card_table[playerid][i][3]);

        PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][0], "blackjack:cardscard");
        PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][1], "blackjack:cardscard");
        PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][2], "blackjack:cardscard");
        PlayerTextDrawSetString(playerid, bj_card_table[playerid][i][3], "blackjack:cardscard");
    }

    InitPlayerLobby(playerid, lobby, pBJInfo[playerid][pBJTable]);
    return 1;
}

stock SCMBJL(lobby, color, message[])
{
	if(BlackJackLobby[lobby][Table1Id] != -1) SCM(BlackJackLobby[lobby][Table1Id], color, message);
	if(BlackJackLobby[lobby][Table2Id] != -1) SCM(BlackJackLobby[lobby][Table2Id], color, message);
	if(BlackJackLobby[lobby][Table3Id] != -1) SCM(BlackJackLobby[lobby][Table3Id], color, message);
	if(BlackJackLobby[lobby][Table4Id] != -1) SCM(BlackJackLobby[lobby][Table4Id], color, message);
}

stock SnowNotificarionBJL(lobby, message[], type)
{
	if(BlackJackLobby[lobby][Table1Id] != -1) ShowNotificationNew(BlackJackLobby[lobby][Table1Id], type, 5, 1, 1, message, ""), 0;
	if(BlackJackLobby[lobby][Table2Id] != -1) ShowNotificationNew(BlackJackLobby[lobby][Table2Id], type, 5, 1, 1, message, ""), 0;
	if(BlackJackLobby[lobby][Table3Id] != -1) ShowNotificationNew(BlackJackLobby[lobby][Table3Id], type, 5, 1, 1, message, ""), 0;
	if(BlackJackLobby[lobby][Table4Id] != -1) ShowNotificationNew(BlackJackLobby[lobby][Table4Id], type, 5, 1, 1, message, ""), 0;
}

stock CheckTableBlackJack(lobby, table)
{
	switch(table)
	{
	    case 1:
		{
			if(BlackJackLobby[lobby][Table1Point] == 21) GiveTableBlackJack(lobby, BlackJackLobby[lobby][Table1Id], table);
			else if(BlackJackLobby[lobby][Table1Point] > 21) GiveTableLose(lobby, BlackJackLobby[lobby][Table1Id]);
		}
	    case 2:
		{
			if(BlackJackLobby[lobby][Table2Point] == 21) GiveTableBlackJack(lobby, BlackJackLobby[lobby][Table2Id], table);
			else if(BlackJackLobby[lobby][Table2Point] > 21) GiveTableLose(lobby, BlackJackLobby[lobby][Table2Id]);
		}
	    case 3:
		{
			if(BlackJackLobby[lobby][Table3Point] == 21) GiveTableBlackJack(lobby, BlackJackLobby[lobby][Table3Id], table);
			else if(BlackJackLobby[lobby][Table3Point] > 21) GiveTableLose(lobby, BlackJackLobby[lobby][Table3Id]);
		}
	    case 4:
		{
			if(BlackJackLobby[lobby][Table4Point] == 21) GiveTableBlackJack(lobby, BlackJackLobby[lobby][Table4Id], table);
			else if(BlackJackLobby[lobby][Table4Point] > 21) GiveTableLose(lobby, BlackJackLobby[lobby][Table4Id]);
		}
	}

}

stock GiveTableBlackJack(lobby, playerid, table)
{
	if(BlackJackLobby[lobby][Table1Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_text_bj_table[lobby][table-1]);  TextDrawShowForPlayer(BlackJackLobby[lobby][Table1Id], bj_text_bj_table[lobby][table-1]);
	if(BlackJackLobby[lobby][Table2Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_text_bj_table[lobby][table-1]);  TextDrawShowForPlayer(BlackJackLobby[lobby][Table2Id], bj_text_bj_table[lobby][table-1]);
	if(BlackJackLobby[lobby][Table3Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_text_bj_table[lobby][table-1]);  TextDrawShowForPlayer(BlackJackLobby[lobby][Table3Id], bj_text_bj_table[lobby][table-1]);
	if(BlackJackLobby[lobby][Table4Id] != -1) TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_text_bj_table[lobby][table-1]);  TextDrawShowForPlayer(BlackJackLobby[lobby][Table4Id], bj_text_bj_table[lobby][table-1]);

    PlayerTextDrawSetString(playerid, bj_panel_info[playerid], "blackjack:brbjyoubj");//GivePlayerMoney(BlackJackLobby[lobby][Table1Id], pBJInfo[BlackJackLobby[lobby][Table1Id]][pBJBet]*2);
    PlayerTextDrawHide(playerid, bj_panel_info[playerid]);
    BlackJackLobby[lobby][TableTurnTime] = 0;
    BlackJackLobby[lobby][TableTurn]++;
}

stock GiveTableLose(lobby, player)
{
	new str[32];
	format(str, sizeof str, "%s проиграл", GetPlayerNameEx(player));
	SCMBJL(lobby, CWHITE, str);
}

stock ShowMembersCardBJL(lobby, table, card, suit, type)
{

	new apponent;
	switch(table)
	{
	    case 1: apponent = BlackJackLobby[lobby][Table1Id];
	    case 2: apponent = BlackJackLobby[lobby][Table2Id];
	    case 3: apponent = BlackJackLobby[lobby][Table3Id];
	    case 4: apponent = BlackJackLobby[lobby][Table4Id];
	}
    new give[96];
    format(give, sizeof give, "~w~Дилер выдал карту ~y~%s", GetPlayerNameEx(apponent));
    TextDrawSetString(bj_log_text[lobby][0], give);
    TextDrawColor(bj_log_text[lobby][0], -1);
    TextDrawSetString(bj_log_text[lobby][1], "");
    TextDrawColor(bj_log_text[lobby][1], -65281);

	if(BlackJackLobby[lobby][Table1Id] != -1)
	{
		PlayerTextDrawShow(BlackJackLobby[lobby][Table1Id], bj_card_table[BlackJackLobby[lobby][Table1Id]][table][card]);
        PlayerTextDrawSetString(BlackJackLobby[lobby][Table1Id], bj_card_table[BlackJackLobby[lobby][Table1Id]][table][card], BlackJackCard[suit][type][Cardtexture]);
		PlayerTextDrawShow(BlackJackLobby[lobby][Table1Id], bj_card_table[BlackJackLobby[lobby][Table1Id]][table][card]);
	}
	if(BlackJackLobby[lobby][Table2Id] != -1)
	{
		PlayerTextDrawShow(BlackJackLobby[lobby][Table2Id], bj_card_table[BlackJackLobby[lobby][Table2Id]][table][card]);
        PlayerTextDrawSetString(BlackJackLobby[lobby][Table2Id], bj_card_table[BlackJackLobby[lobby][Table2Id]][table][card], BlackJackCard[suit][type][Cardtexture]);
		PlayerTextDrawShow(BlackJackLobby[lobby][Table2Id], bj_card_table[BlackJackLobby[lobby][Table2Id]][table][card]);
	}
	if(BlackJackLobby[lobby][Table3Id] != -1)
	{
		PlayerTextDrawShow(BlackJackLobby[lobby][Table3Id], bj_card_table[BlackJackLobby[lobby][Table3Id]][table][card]);
        PlayerTextDrawSetString(BlackJackLobby[lobby][Table3Id], bj_card_table[BlackJackLobby[lobby][Table3Id]][table][card], BlackJackCard[suit][type][Cardtexture]);
		PlayerTextDrawShow(BlackJackLobby[lobby][Table3Id], bj_card_table[BlackJackLobby[lobby][Table3Id]][table][card]);
	}
	if(BlackJackLobby[lobby][Table4Id] != -1)
	{
		PlayerTextDrawShow(BlackJackLobby[lobby][Table4Id], bj_card_table[BlackJackLobby[lobby][Table4Id]][table][card]);
        PlayerTextDrawSetString(BlackJackLobby[lobby][Table4Id], bj_card_table[BlackJackLobby[lobby][Table4Id]][table][card], BlackJackCard[suit][type][Cardtexture]);
		PlayerTextDrawShow(BlackJackLobby[lobby][Table4Id], bj_card_table[BlackJackLobby[lobby][Table4Id]][table][card]);
	}
}

stock LoadTextDrawBj()
{
	bj_fon = TextDrawCreate(0.000000, 0.000000, "blackjack:brbj");
	TextDrawLetterSize(bj_fon, 0.000000, 0.000000);
	TextDrawTextSize(bj_fon, 640.000000, 448.000000);
	TextDrawAlignment(bj_fon, 1);
	TextDrawColor(bj_fon, -1);
	TextDrawSetShadow(bj_fon, 0);
	TextDrawSetOutline(bj_fon, 0);
	TextDrawFont(bj_fon, 4);

	bj_play = TextDrawCreate(268.399932, 389.773345, "blackjack:brbjplay");
	TextDrawLetterSize(bj_play, 0.000000, 0.000000);
	TextDrawTextSize(bj_play, 96.799949, 36.586669);
	TextDrawAlignment(bj_play, 1);
	TextDrawColor(bj_play, -1);
	TextDrawSetShadow(bj_play, 0);
	TextDrawSetOutline(bj_play, 0);
	TextDrawFont(bj_play, 4);
	TextDrawSetSelectable(bj_play, true);

	bj_double = TextDrawCreate(16.600013, 389.773345, "blackjack:brbjdouble");
	TextDrawLetterSize(bj_double, 0.000000, 0.000000);
	TextDrawTextSize(bj_double, 96.799949, 36.586669);
	TextDrawAlignment(bj_double, 1);
	TextDrawColor(bj_double, -1);
	TextDrawSetShadow(bj_double, 0);
	TextDrawSetOutline(bj_double, 0);
	TextDrawFont(bj_double, 4);
	TextDrawSetSelectable(bj_double, true);

	bj_stop = TextDrawCreate(121.600059, 389.773345, "blackjack:brbjstop");
	TextDrawLetterSize(bj_stop, 0.000000, 0.000000);
	TextDrawTextSize(bj_stop, 96.799949, 36.586669);
	TextDrawAlignment(bj_stop, 1);
	TextDrawColor(bj_stop, -1);
	TextDrawSetShadow(bj_stop, 0);
	TextDrawSetOutline(bj_stop, 0);
	TextDrawFont(bj_stop, 4);
	TextDrawSetSelectable(bj_stop, true);

	bj_take = TextDrawCreate(420.800231, 389.773345, "blackjack:brbjtake");
	TextDrawLetterSize(bj_take, 0.000000, 0.000000);
	TextDrawTextSize(bj_take, 96.799949, 36.586669);
	TextDrawAlignment(bj_take, 1);
	TextDrawColor(bj_take, -1);
	TextDrawSetShadow(bj_take, 0);
	TextDrawSetOutline(bj_take, 0);
	TextDrawFont(bj_take, 4);
	TextDrawSetSelectable(bj_take, true);

	bj_exit = TextDrawCreate(526.200256, 389.773345, "blackjack:brbjexit");
	TextDrawLetterSize(bj_exit, 0.000000, 0.000000);
	TextDrawTextSize(bj_exit, 96.799949, 36.586669);
	TextDrawAlignment(bj_exit, 1);
	TextDrawColor(bj_exit, -1);
	TextDrawSetShadow(bj_exit, 0);
	TextDrawSetOutline(bj_exit, 0);
	TextDrawFont(bj_exit, 4);
	TextDrawSetSelectable(bj_exit, true);

	bj_dealer_score = TextDrawCreate(259.000030, 388.280212, "blackjack:brbjscore");
	TextDrawLetterSize(bj_dealer_score, 0.000000, 0.000000);
	TextDrawTextSize(bj_dealer_score, 115.999938, 51.520008);
	TextDrawAlignment(bj_dealer_score, 1);
	TextDrawColor(bj_dealer_score, -1);
	TextDrawSetShadow(bj_dealer_score, 0);
	TextDrawSetOutline(bj_dealer_score, 0);
	TextDrawFont(bj_dealer_score, 4);


	bj_help = TextDrawCreate(16.799999, 123.200004, "textures:button");
    TextDrawLetterSize(bj_help, 0.000000, 0.000000);
    TextDrawTextSize(bj_help, 104.000000, 36.586654);
    TextDrawAlignment(bj_help, 1);
    TextDrawColor(bj_help, 0xFFFFFF00);
    TextDrawSetShadow(bj_help, 0);
    TextDrawSetOutline(bj_help, 0);
    TextDrawFont(bj_help, 4);
    TextDrawSetSelectable(bj_help, true);



	bj_text_bet[0] = TextDrawCreate(320.800018, 71.680015, "Вы успешно");
	TextDrawLetterSize(bj_text_bet[0], 0.405198, 1.458132);
	TextDrawAlignment(bj_text_bet[0], 2);
	TextDrawColor(bj_text_bet[0], -65281);
	TextDrawSetShadow(bj_text_bet[0], 0);
	TextDrawSetOutline(bj_text_bet[0], 1);
	TextDrawBackgroundColor(bj_text_bet[0], 51);
	TextDrawFont(bj_text_bet[0], 1);
	TextDrawSetProportional(bj_text_bet[0], 1);

	bj_text_bet[1] = TextDrawCreate(320.200042, 86.120002, "поставили ставку");
	TextDrawLetterSize(bj_text_bet[1], 0.405198, 1.458132);
	TextDrawAlignment(bj_text_bet[1], 2);
	TextDrawColor(bj_text_bet[1], -65281);
	TextDrawSetShadow(bj_text_bet[1], 0);
	TextDrawSetOutline(bj_text_bet[1], 1);
	TextDrawBackgroundColor(bj_text_bet[1], 51);
	TextDrawFont(bj_text_bet[1], 1);
	TextDrawSetProportional(bj_text_bet[1], 1);



	bj_text_start_time = TextDrawCreate(315.999969, 215.040039, "Времени до начала игры");
	TextDrawLetterSize(bj_text_start_time, 0.581197, 2.563199);
	TextDrawAlignment(bj_text_start_time, 2);
	TextDrawColor(bj_text_start_time, -1);
	TextDrawSetShadow(bj_text_start_time, 0);
	TextDrawSetOutline(bj_text_start_time, 1);
	TextDrawBackgroundColor(bj_text_start_time, 51);
	TextDrawFont(bj_text_start_time, 1);
	TextDrawSetProportional(bj_text_start_time, 1);

	//bj_text_start_timer в моде

}

stock LoadPlayerTextDraw(playerid)
{
    bj_bet[playerid] = CreatePlayerTextDraw(playerid, 19.200004, 58.240013, "0 руб");
	PlayerTextDrawLetterSize(playerid, bj_bet[playerid], 0.291599, 1.510398);
	PlayerTextDrawAlignment(playerid, bj_bet[playerid], 1);
	PlayerTextDrawColor(playerid, bj_bet[playerid], -1);
	PlayerTextDrawSetShadow(playerid, bj_bet[playerid], 0);
	PlayerTextDrawSetOutline(playerid, bj_bet[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, bj_bet[playerid], 51);
	PlayerTextDrawFont(playerid, bj_bet[playerid], 1);
	PlayerTextDrawSetProportional(playerid, bj_bet[playerid], 1);

	bj_money[playerid] = CreatePlayerTextDraw(playerid, 19.200004, 92.093315, "0 руб");
	PlayerTextDrawLetterSize(playerid, bj_money[playerid], 0.291599, 1.510398);
	PlayerTextDrawAlignment(playerid, bj_money[playerid], 1);
	PlayerTextDrawColor(playerid, bj_money[playerid], -1);
	PlayerTextDrawSetShadow(playerid, bj_money[playerid], 0);
	PlayerTextDrawSetOutline(playerid, bj_money[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, bj_money[playerid], 51);
	PlayerTextDrawFont(playerid, bj_money[playerid], 1);
	PlayerTextDrawSetProportional(playerid, bj_money[playerid], 1);


	bj_dealer_point[playerid] = CreatePlayerTextDraw(playerid, 317.599853, 405.440093, "21");
	PlayerTextDrawLetterSize(playerid, bj_dealer_point[playerid], 0.364398, 1.719465);
	PlayerTextDrawAlignment(playerid, bj_dealer_point[playerid], 2);
	PlayerTextDrawColor(playerid, bj_dealer_point[playerid], -1);
	PlayerTextDrawSetShadow(playerid, bj_dealer_point[playerid], 0);
	PlayerTextDrawSetOutline(playerid, bj_dealer_point[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, bj_dealer_point[playerid], 51);
	PlayerTextDrawFont(playerid, bj_dealer_point[playerid], 1);
	PlayerTextDrawSetProportional(playerid, bj_dealer_point[playerid], 1);


	bj_members_name[playerid][0] = CreatePlayerTextDraw(playerid, 19.600006, 197.626632, "Player");
	PlayerTextDrawLetterSize(playerid, 			bj_members_name[playerid][0], 0.286798, 1.390933);
	PlayerTextDrawAlignment(playerid, 			bj_members_name[playerid][0], 1);
	PlayerTextDrawColor(playerid, 				bj_members_name[playerid][0], -1);
	PlayerTextDrawSetShadow(playerid, 			bj_members_name[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, 			bj_members_name[playerid][0], 1);
	PlayerTextDrawBackgroundColor(playerid, 	bj_members_name[playerid][0], 51);
	PlayerTextDrawFont(playerid, 				bj_members_name[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, 	bj_members_name[playerid][0], 1);


	bj_members_name[playerid][1] = CreatePlayerTextDraw(playerid, 147.200286, 40.586555, "Player");
	PlayerTextDrawLetterSize(playerid, 			bj_members_name[playerid][1], 0.286798, 1.390933);
	PlayerTextDrawAlignment(playerid, 			bj_members_name[playerid][1], 1);
	PlayerTextDrawColor(playerid, 				bj_members_name[playerid][1], -1);
	PlayerTextDrawSetShadow(playerid, 			bj_members_name[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, 			bj_members_name[playerid][1], 1);
	PlayerTextDrawBackgroundColor(playerid, 	bj_members_name[playerid][1], 51);
	PlayerTextDrawFont(playerid, 				bj_members_name[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, 	bj_members_name[playerid][1], 1);

	bj_members_name[playerid][2] = CreatePlayerTextDraw(playerid, 397.800445, 40.586555, "Player");
	PlayerTextDrawLetterSize(playerid, 			bj_members_name[playerid][2], 0.286798, 1.390933);
	PlayerTextDrawAlignment(playerid, 			bj_members_name[playerid][2], 1);
	PlayerTextDrawColor(playerid, 				bj_members_name[playerid][2], -1);
	PlayerTextDrawSetShadow(playerid,		 	bj_members_name[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, 			bj_members_name[playerid][2], 1);
	PlayerTextDrawBackgroundColor(playerid, 	bj_members_name[playerid][2], 51);
	PlayerTextDrawFont(playerid, 				bj_members_name[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, 	bj_members_name[playerid][2], 1);

	bj_members_name[playerid][3] = CreatePlayerTextDraw(playerid, 496.600280, 197.626632, "Player");
	PlayerTextDrawLetterSize(playerid, 			bj_members_name[playerid][3], 0.286798, 1.390933);
	PlayerTextDrawAlignment(playerid, 			bj_members_name[playerid][3], 1);
	PlayerTextDrawColor(playerid, 				bj_members_name[playerid][3], -1);
	PlayerTextDrawSetShadow(playerid, 			bj_members_name[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, 			bj_members_name[playerid][3], 1);
	PlayerTextDrawBackgroundColor(playerid, 	bj_members_name[playerid][3], 51);
	PlayerTextDrawFont(playerid, 				bj_members_name[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, 	bj_members_name[playerid][3], 1);

	bj_card_table[playerid][1][0] = CreatePlayerTextDraw(playerid, 2.999999, 206.079971, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][1][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][1][0], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][1][0], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][1][0], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][1][0], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][1][0], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][1][0], 4);

	bj_card_table[playerid][1][1] = CreatePlayerTextDraw(playerid, 22.999999, 206.079971, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][1][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][1][1], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][1][1], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][1][1], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][1][1], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][1][1], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][1][1], 4);

	bj_card_table[playerid][1][2] = CreatePlayerTextDraw(playerid, 42.999999, 206.079971, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][1][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][1][2], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][1][2], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][1][2], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][1][2], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][1][2], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][1][2], 4);

	bj_card_table[playerid][1][3] = CreatePlayerTextDraw(playerid, 62.999999, 206.079971, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][1][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][1][3], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][1][3], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][1][3], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][1][3], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][1][3], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][1][3], 4);





	bj_card_table[playerid][2][0] = CreatePlayerTextDraw(playerid, 129.999999, 46.559913, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][2][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][2][0], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][2][0], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][2][0], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][2][0], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][2][0], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][2][0], 4);

	bj_card_table[playerid][2][1] = CreatePlayerTextDraw(playerid, 149.999999, 46.559913, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][2][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][2][1], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][2][1], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][2][1], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][2][1], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][2][1], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][2][1], 4);

	bj_card_table[playerid][2][2] = CreatePlayerTextDraw(playerid, 169.999999, 46.559913, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][2][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][2][2], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][2][2], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][2][2], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][2][2], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][2][2], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][2][2], 4);

	bj_card_table[playerid][2][3] = CreatePlayerTextDraw(playerid, 189.999999, 46.559913, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][2][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][2][3], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][2][3], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][2][3], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][2][3], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][2][3], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][2][3], 4);





	bj_card_table[playerid][3][0] = CreatePlayerTextDraw(playerid, 380.999999, 46.559913, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][3][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][3][0], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][3][0], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][3][0], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][3][0], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][3][0], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][3][0], 4);

	bj_card_table[playerid][3][1] = CreatePlayerTextDraw(playerid, 400.999999, 46.559913, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][3][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][3][1], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][3][1], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][3][1], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][3][1], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][3][1], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][3][1], 4);

	bj_card_table[playerid][3][2] = CreatePlayerTextDraw(playerid, 420.999999, 46.559913, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][3][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][3][2], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][3][2], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][3][2], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][3][2], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][3][2], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][3][2], 4);

	bj_card_table[playerid][3][3] = CreatePlayerTextDraw(playerid, 440.999999, 46.559913, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][3][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][3][3], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][3][3], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][3][3], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][3][3], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][3][3], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][3][3], 4);




	bj_card_table[playerid][4][0] = CreatePlayerTextDraw(playerid, 481.000000, 206.079971, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][4][0], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][4][0], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][4][0], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][4][0], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][4][0], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][4][0], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][4][0], 4);

	bj_card_table[playerid][4][1] = CreatePlayerTextDraw(playerid, 502.000000, 206.079971, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][4][1], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][4][1], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][4][1], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][4][1], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][4][1], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][4][1], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][4][1], 4);

	bj_card_table[playerid][4][2] = CreatePlayerTextDraw(playerid, 523.000000, 206.079971, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][4][2], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][4][2], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][4][2], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][4][2], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][4][2], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][4][2], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][4][2], 4);

	bj_card_table[playerid][4][3] = CreatePlayerTextDraw(playerid, 544.000000, 206.079971, "blackjack:cardscard");
	PlayerTextDrawLetterSize(playerid, bj_card_table[playerid][4][3], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_card_table[playerid][4][3], 90.400009, 117.226631);
	PlayerTextDrawAlignment(playerid, bj_card_table[playerid][4][3], 1);
	PlayerTextDrawColor(playerid, bj_card_table[playerid][4][3], -1);
	PlayerTextDrawSetShadow(playerid, bj_card_table[playerid][4][3], 0);
	PlayerTextDrawSetOutline(playerid, bj_card_table[playerid][4][3], 0);
	PlayerTextDrawFont(playerid, bj_card_table[playerid][4][3], 4);



	bj_panel_info[playerid] = CreatePlayerTextDraw(playerid, 155.146667, 249.386703, "blackjack:brbjyouturn");
	PlayerTextDrawLetterSize(playerid, bj_panel_info[playerid], 0.000000, 0.000000);
	PlayerTextDrawTextSize(playerid, bj_panel_info[playerid], 326.133239, 106.026657);
	PlayerTextDrawAlignment(playerid, bj_panel_info[playerid], 1);
	PlayerTextDrawColor(playerid, bj_panel_info[playerid], -1);
	PlayerTextDrawSetShadow(playerid, bj_panel_info[playerid], 0);
	PlayerTextDrawSetOutline(playerid, bj_panel_info[playerid], 0);
	PlayerTextDrawFont(playerid, bj_panel_info[playerid], 4);

}

stock GivePlayerMoneyBjEx(playerid, money, description[]="None", bool:save=true, bool:game_text=true)
{
	new current_money = GetPlayerMoneyEx(playerid);
	if(current_money < 0 || current_money > PLAYER_MONEY_SAFE_MAX) return -1;
	if(money < 0 && (money < -PLAYER_MONEY_SAFE_MAX || current_money < -money)) return -1;
	if(money > 0 && money > PLAYER_MONEY_SAFE_MAX - current_money) return -1;

	new fmt_str[185];
	AddPlayerData(playerid, P_MONEY, +, money);
	GivePlayerMoney(playerid, money);

	format(fmt_str, sizeof fmt_str, "INSERT INTO money_log (uid,uip,time,money,description) VALUES (%d,'%s',%d,%d,'%s')", GetPlayerAccountID(playerid), GetPlayerIpEx(playerid), gettime(), money, description);
	mysql_query(mysql, fmt_str, false);


	if(save)
	{
		format(fmt_str, sizeof fmt_str, "UPDATE accounts SET money=%d WHERE id=%d LIMIT 1", GetPlayerMoneyEx(playerid), GetPlayerAccountID(playerid));
		mysql_query(mysql, fmt_str, false);
	}
	if(game_text)
    {
        new notification_amount_text[32];

        if(money < 0)
        {
            format(notification_amount_text, sizeof notification_amount_text, "%d руб.", money);
            ShowNotificationNew(playerid, 0, 5, 1, 1, notification_amount_text, "");
			0;
        }
        else
        {
            format(notification_amount_text, sizeof notification_amount_text, "+%d руб.", money);
			ShowNotificationNew(playerid, 1, 5, 1, 1, notification_amount_text, "");
			0;
        }
    }

	return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
    for(new lobby = 0; lobby < MAX_BJ_LOBBY; lobby++)
    {
        if(areaid == BlackJackSphere[lobby])
        {
            0;
			ShowNotificationNew(playerid, 5, 5, BLACK_JACK, 1, "Взаимодействие", "");
            break;
        }
    }

    #if defined blackjack_OnPlayerEnterDynamicArea
        return blackjack_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerEnterDynamicArea
    #undef OnPlayerEnterDynamicArea
#else
    #define _ALS_OnPlayerEnterDynamicArea
#endif
#define OnPlayerEnterDynamicArea blackjack_OnPlayerEnterDynamicArea
#if defined blackjack_OnPlayerEnterDynamicArea
    forward blackjack_OnPlayerEnterDynamicArea(playerid, STREAMER_TAG_AREA:areaid);
#endif

public OnGameModeInit()
{
	LoadBlackJack();
    #if defined blackjack_OnGameModeInit
        return blackjack_OnGameModeInit();
    #else
        return 1;
    #endif
}
#if defined _ALS_OnGameModeInit
    #undef OnGameModeInit
#else
    #define _ALS_OnGameModeInit
#endif
#define OnGameModeInit blackjack_OnGameModeInit
#if defined blackjack_OnGameModeInit
    forward blackjack_OnGameModeInit();
#endif

public OnPlayerConnect(playerid)
{
	LoadPlayerTextDraw(playerid);
	for(new lobby; lobby < MAX_BJ_LOBBY; lobby++)
	{
		TextDrawHideForPlayer(playerid, bj_log_text[lobby][0]);
		TextDrawHideForPlayer(playerid, bj_log_text[lobby][1]);
	}
	#if defined blackjack_OnPlayerConnect
        return blackjack_OnPlayerConnect(playerid);
    #else
        return 1;
    #endif
}
#if defined _ALS_OnPlayerConnect
    #undef OnPlayerConnect
#else
    #define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect blackjack_OnPlayerConnect
#if defined blackjack_OnPlayerConnect
    forward blackjack_OnPlayerConnect(playerid);
#endif

CMD:blackjack(playerid)
{
	if(pBJInfo[playerid][OnLobby] == false)
	{
		new bool:distance;
		for(new i = 0; i < MAX_BJ_LOBBY; i++)
		{
			if(IsPlayerInRangeOfPoint(playerid, 5.0, BlackJackPos[i][0], BlackJackPos[i][1], BlackJackPos[i][2]))
		    {
	     		distance = true;
				if(BlackJackLobby[i][StartedLobby] == false)
				{
					if(BlackJackLobby[i][Table1Id] == -1) 	 { BlackJackLobby[i][Table1Id] = playerid; pBJInfo[playerid][OnLobby] = true; pBJInfo[playerid][pBJLobby] = i; pBJInfo[playerid][pBJBehindSlot] = 1; HideHud(playerid); InitPlayerLobby(playerid, i, 1);}
					else if(BlackJackLobby[i][Table2Id] == -1) { BlackJackLobby[i][Table2Id] = playerid; pBJInfo[playerid][OnLobby] = true; pBJInfo[playerid][pBJLobby] = i; pBJInfo[playerid][pBJBehindSlot] = 2; HideHud(playerid); InitPlayerLobby(playerid, i, 2);}
					else if(BlackJackLobby[i][Table3Id] == -1) { BlackJackLobby[i][Table3Id] = playerid; pBJInfo[playerid][OnLobby] = true; pBJInfo[playerid][pBJLobby] = i; pBJInfo[playerid][pBJBehindSlot] = 3; HideHud(playerid); InitPlayerLobby(playerid, i, 3);}
					else if(BlackJackLobby[i][Table4Id] == -1) { BlackJackLobby[i][Table4Id] = playerid; pBJInfo[playerid][OnLobby] = true; pBJInfo[playerid][pBJLobby] = i; pBJInfo[playerid][pBJBehindSlot] = 4; HideHud(playerid); InitPlayerLobby(playerid, i, 4);}
					else SCM(playerid, CLRED, "| "CW"Данный стол уже занят.");
				}
				else SCM(playerid, CLRED, "| "CW"На этом столе уже началась игра.");
		    }
		    else continue;
		}
		if(distance == false) SCM(playerid, CLRED, "| "CW"Вы находитесь слишком далеко от блек джека");
	}
	return 1;
}









