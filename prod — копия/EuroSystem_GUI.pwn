/*
	EuroSystem.pwn - Euro + Bit + Memecoin (Alabuga)
	.euro .bit .meme
	ASCII UI (no encoding break)
*/

#define FILTERSCRIPT
#include <a_samp>
#include <a_mysql>
#include <a_http>

#if !defined MYSQL_INVALID_HANDLE
	#define MYSQL_INVALID_HANDLE (0)
#endif

#define MYSQL_FILE			"bykranin_mysql_settings.ini"
#define EURO_PAYDAY			10
#define BIT_PAYDAY			5
#define EURO_FAMILY_PRICE	100000
#define BIT_FEE_PCT			5
#define EURO_TO_BIT_FEE_PCT	20
#define BIT_TRANSFER_FEE_PCT	20
#define MEME_FEE_PCT			50
#define MEME_GROW_PCT_DAY		2
#define MEME_OFFLINE_DAYS		30
#define MEME_ANNOUNCE_MS		300000
#define MEME_FLY_PRICE			10
#define MEME_FLY_SECONDS		90
#define MEME_RAND_BASE			5000
#define UAH_ADMIN_PRICE			200000
#define UAH_LEADER_PRICE		200000
#define KZT_FEE_PCT				70
#define UAH_FEE_PCT				90
#define KZT_TRANSFER_FEE_PCT	20
#define UAH_TRANSFER_FEE_PCT	20
#define EURO_TUNE_PRICE			10000
#define PLAY_HOURS_REWARD		12

#define MEME_NAME			"Алабуга"
#define MEME_END_YEAR		2028
#define MEME_END_MONTH		12
#define MEME_END_DAY		31
#define MEME_END_HOUR		23
#define MEME_END_MIN		59

#define COLOR_EURO			0xFFD700FF
#define COLOR_BIT			0x00BFFFFF
#define COLOR_MEME			0xFF69B4FF
#define COLOR_ERR			0xFF6347FF

#define D_EURO_MENU			29510
#define D_EURO_GIVE			29511
#define D_EURO_GIVE_AMT		29512
#define D_EURO_TOP			29514
#define D_EURO_EX			29515
#define D_EURO_EX_AMT		29516
#define D_EURO_BUY_AMT		29518
#define D_EURO_SKIN			29520
#define D_EURO_ACS			29521
#define D_EURO_CAR			29522
#define D_EURO_FAM_NAME		29523
#define D_EURO_FAM_OK		29524
#define D_BIT_MENU			29530
#define D_BIT_GIVE			29531
#define D_BIT_GIVE_AMT		29532
#define D_BIT_EX			29533
#define D_BIT_EX_AMT		29534
#define D_BIT_TOP			29535
#define D_E2B_AMT			29536
#define D_B2E_AMT			29537
#define D_MEME_MENU			29540
#define D_MEME_EX_AMT		29542
#define D_MEME_GIVE			29543
#define D_MEME_GIVE_AMT		29544
#define D_MEME_TOP			29545
#define D_MEME_DONATE		29546
#define D_MEME_FROM_EUR		29547
#define D_MEME_FROM_BIT		29548
#define D_UAH_MENU			29550
#define D_KZT_MENU			29551
#define D_KZT_EX			29552
#define D_KZT_EX_AMT		29553
#define D_MEME_FLY_OK		29554
#define D_MEME_RAND_OK		29555
#define D_UAH_TOP			29556
#define D_KZT_TOP			29557
#define D_UAH_GIVE			29558
#define D_UAH_GIVE_AMT		29559
#define D_KZT_GIVE			29560
#define D_KZT_GIVE_AMT		29561
#define D_UAH_EX_AMT		29562
#define D_EURO_TUNE			29563
#define D_MEME_SEASON_REW	29564
#define D_FUN_MENU			29570
#define D_FUN_GIVE			29571
#define D_FUN_GIVE_AMT		29572
#define D_FUN_EX_AMT		29573
#define D_FUN_CODE_NICK		29574
#define D_FUN_CODE_DAYS		29575
#define D_FUN_CODE_LIST		29576
#define D_FUN_ACTIVATE		29577
#define D_FUN_TOP			29578
#define D_FUN_PROP_TYPE		29579
#define D_FUN_PROP_LIST		29580
#define D_FUN_PROP_DAYS		29581
#define FUN_RENT_PER_DAY		10
#define FUN_RESTART_PRICE		500000
#define FUN_TROLL_CHAT_PRICE	5
#define FUN_TROLL_FREEZE_PRICE	15
#define FUN_TROLL_SLAP_PRICE	10
#define FUN_TROLL_MSG_PRICE		5
#define FUN_CONTROL_PRICE		5000
#define FUN_CONTROL_SEC			60
#define D_FUN_CONTROL			29589
#define D_FUN_CONTROL_CMD		29590
#define D_FUN_CONTROL_SKIN		29591
#define D_FUN_CONTROL_SAY		29592
#define D_FUN_CONTROL_VEHICLE	29593
#define D_FUN_RESTART			29582
#define D_FUN_RESTART_MIN		29583
#define D_FUN_STREAM_MENU		29584
#define D_FUN_STREAM_ID			29585
#define D_FUN_STREAM_ACT		29586
#define D_FUN_STREAM_CHAT		29587
#define D_FUN_STREAM_MSG		29588

#define FUN_HOUR_REWARD		200
#define FUN_CODE_PRICE		500
#define FUN_FEE_PCT			99
#define FUN_DAYS_30			30
#define FUN_DAYS_365		365

#define ITEM_SKIN			134

new Float:gEuroRate = 94.97;
new Float:gBitRate = 6500000.0;
new Float:gMemeRate = 100.0;
new Float:gUahRate = 2.5;   // RUB per 1 UAH approx
new Float:gKztRate = 0.18;  // RUB per 1 KZT approx
new gSQL, gSQLOk;
new SQL_Host[64], SQL_User[64], SQL_Pass[128], SQL_DB[64];
new PlayerEuro[MAX_PLAYERS], PlayerEuroEx[MAX_PLAYERS], PlayerAccID[MAX_PLAYERS];
new PlayerBit[MAX_PLAYERS], PlayerMeme[MAX_PLAYERS], PlayerDonate[MAX_PLAYERS];
new PlayerUAH[MAX_PLAYERS], PlayerKZT[MAX_PLAYERS], PlayerFun[MAX_PLAYERS];
new FunGiveTarget[MAX_PLAYERS];
new FunCodeNick[MAX_PLAYERS][MAX_PLAYER_NAME];
new FunCodeDays[MAX_PLAYERS];
new FunListIds[MAX_PLAYERS][12]; // code row ids for revoke menu
new FunListCount[MAX_PLAYERS];
new EuroMenuTick[MAX_PLAYERS];
new FunPropIds[MAX_PLAYERS][20];
new FunPropCount[MAX_PLAYERS];
new FunPropType[MAX_PLAYERS]; // 0 house 1 biz 2 azs 3 garage 4 hotel 5 bought 6 br_garage
new FunPropSel[MAX_PLAYERS];
new bool:StreamerMode[MAX_PLAYERS];
new StreamTarget[MAX_PLAYERS];
new gRestartTimer;
new gRestartLeft; // seconds
new gRestartBy[MAX_PLAYER_NAME];
new gRestartByAcc;
new bool:gRestartActive;
new ControlTarget[MAX_PLAYERS]; // кого контролит playerid
new ControlUntil[MAX_PLAYERS];  // gettime() конец сессии
new ControlledBy[MAX_PLAYERS];  // кто контролит этого стримера
new PlayerPlaySec[MAX_PLAYERS], PlayerRandBuys[MAX_PLAYERS];
new PlayerFlyTimer[MAX_PLAYERS];
new KztExMode[MAX_PLAYERS];
new PlayerLastLogin[MAX_PLAYERS];
new bool:PlayerLoaded[MAX_PLAYERS];
new EuroGiveTarget[MAX_PLAYERS], EuroExMode[MAX_PLAYERS], EuroBuyMode[MAX_PLAYERS];
new BitGiveTarget[MAX_PLAYERS], BitExMode[MAX_PLAYERS];
new MemeGiveTarget[MAX_PLAYERS], MemeExMode[MAX_PLAYERS];
new UahGiveTarget[MAX_PLAYERS], UahExMode[MAX_PLAYERS];
new KztGiveTarget[MAX_PLAYERS];
new PlayerFlyActive[MAX_PLAYERS];
new LastPaydayHour = -1;
new FamilyNamePending[MAX_PLAYERS][32];
new bool:gMemeSeasonEnded = false;
new gMemeName[32];              // текущий сезон (из БД)
new gMemeEndY, gMemeEndMo, gMemeEndD, gMemeEndH, gMemeEndMi;
new bool:gMemeSeasonLoaded = false;



// -----------------------------------------------------------------------------
// EuroSystem Fullscreen PlayerTextDraw dialog skin.
// Presentation only: every selection is forwarded to the original OnDialogResponse.
// Economy, SQL, prices, balances and transaction functions below remain unchanged.
// -----------------------------------------------------------------------------
enum E_EURO_GUI_DLG
{
    EGD_BG, EGD_PANEL, EGD_TITLE, EGD_BODY,
    EGD_ROW0, EGD_ROW1, EGD_ROW2, EGD_ROW3, EGD_ROW4, EGD_ROW5, EGD_ROW6, EGD_ROW7,
    EGD_PREV, EGD_NEXT, EGD_OK, EGD_INFO, EGD_CANCEL, EGD_CLOSE, EGD_COUNT
};
#define EURO_GUI_ROWS (8)
#define EURO_GUI_ITEMS (64)
#define EURO_GUI_TEXT (2048)
#define EURO_GUI_ITEM_TEXT (160)
#define EURO_GUI_INFO_DIALOG (29998)
new PlayerText:gEuroGuiDlg[MAX_PLAYERS][EGD_COUNT];
new bool:gEuroGuiDlgCreated[MAX_PLAYERS];
new bool:gEuroGuiDlgActive[MAX_PLAYERS];
new bool:gEuroGuiInputActive[MAX_PLAYERS];
new gEuroGuiDlgId[MAX_PLAYERS], gEuroGuiDlgStyle[MAX_PLAYERS];
new gEuroGuiDlgPage[MAX_PLAYERS], gEuroGuiDlgItems[MAX_PLAYERS], gEuroGuiDlgStart[MAX_PLAYERS];
new gEuroGuiDlgTitle[MAX_PLAYERS][128];
new gEuroGuiDlgBody[MAX_PLAYERS][EURO_GUI_TEXT];
new gEuroGuiDlgButton1[MAX_PLAYERS][32], gEuroGuiDlgButton2[MAX_PLAYERS][32];
new bool:gEuroGuiInfoMode[MAX_PLAYERS];
new bool:gEuroGuiSavedInputActive[MAX_PLAYERS];
new gEuroGuiSavedId[MAX_PLAYERS], gEuroGuiSavedStyle[MAX_PLAYERS];
new gEuroGuiSavedPage[MAX_PLAYERS], gEuroGuiSavedItems[MAX_PLAYERS], gEuroGuiSavedStart[MAX_PLAYERS];
new gEuroGuiSavedTitle[MAX_PLAYERS][128], gEuroGuiSavedBody[MAX_PLAYERS][EURO_GUI_TEXT];
new gEuroGuiSavedButton1[MAX_PLAYERS][32], gEuroGuiSavedButton2[MAX_PLAYERS][32];

stock EuroGuiDlgHide(playerid)
{
    if(!gEuroGuiDlgCreated[playerid]) return 1;
    for(new i = 0; i < EGD_COUNT; i++) PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][i]);
    gEuroGuiDlgActive[playerid] = false;
    gEuroGuiInputActive[playerid] = false;
    CancelSelectTextDraw(playerid);
    return 1;
}

stock EuroGuiDlgDestroy(playerid)
{
    if(!gEuroGuiDlgCreated[playerid]) return 1;
    EuroGuiDlgHide(playerid);
    for(new i = 0; i < EGD_COUNT; i++) PlayerTextDrawDestroy(playerid, gEuroGuiDlg[playerid][i]);
    gEuroGuiDlgCreated[playerid] = false;
    return 1;
}

stock EuroGuiDlgCreate(playerid)
{
    if(gEuroGuiDlgCreated[playerid]) return 1;
    gEuroGuiDlgCreated[playerid] = true;

    // Full-screen event-style skin: one continuous background, no per-row bars.
    gEuroGuiDlg[playerid][EGD_BG] = CreatePlayerTextDraw(playerid, 0.0, 0.0, "_");
    PlayerTextDrawFont(playerid, gEuroGuiDlg[playerid][EGD_BG], 1);
    PlayerTextDrawLetterSize(playerid, gEuroGuiDlg[playerid][EGD_BG], 0.0, 44.0);
    PlayerTextDrawUseBox(playerid, gEuroGuiDlg[playerid][EGD_BG], 1);
    PlayerTextDrawBoxColor(playerid, gEuroGuiDlg[playerid][EGD_BG], 0x05080DCC);
    PlayerTextDrawColor(playerid, gEuroGuiDlg[playerid][EGD_BG], 0xFFFFFFFF);
    PlayerTextDrawSetOutline(playerid, gEuroGuiDlg[playerid][EGD_BG], 0);
    PlayerTextDrawSetShadow(playerid, gEuroGuiDlg[playerid][EGD_BG], 0);
    PlayerTextDrawTextSize(playerid, gEuroGuiDlg[playerid][EGD_BG], 640.0, 0.0);

    // The panel itself fills the screen, as requested.
    gEuroGuiDlg[playerid][EGD_PANEL] = CreatePlayerTextDraw(playerid, 0.0, 0.0, "_");
    PlayerTextDrawFont(playerid, gEuroGuiDlg[playerid][EGD_PANEL], 1);
    PlayerTextDrawLetterSize(playerid, gEuroGuiDlg[playerid][EGD_PANEL], 0.0, 44.0);
    PlayerTextDrawUseBox(playerid, gEuroGuiDlg[playerid][EGD_PANEL], 1);
    PlayerTextDrawBoxColor(playerid, gEuroGuiDlg[playerid][EGD_PANEL], 0x101923F0);
    PlayerTextDrawColor(playerid, gEuroGuiDlg[playerid][EGD_PANEL], 0xFFFFFFFF);
    PlayerTextDrawSetOutline(playerid, gEuroGuiDlg[playerid][EGD_PANEL], 0);
    PlayerTextDrawSetShadow(playerid, gEuroGuiDlg[playerid][EGD_PANEL], 0);
    PlayerTextDrawTextSize(playerid, gEuroGuiDlg[playerid][EGD_PANEL], 640.0, 0.0);

    // Event-like accent header, stretched across the screen.
    gEuroGuiDlg[playerid][EGD_TITLE] = CreatePlayerTextDraw(playerid, 18.0, 12.0, "EUROSYSTEM");
    PlayerTextDrawFont(playerid, gEuroGuiDlg[playerid][EGD_TITLE], 1);
    PlayerTextDrawLetterSize(playerid, gEuroGuiDlg[playerid][EGD_TITLE], 0.36, 1.55);
    PlayerTextDrawColor(playerid, gEuroGuiDlg[playerid][EGD_TITLE], 0xFFD36AFF);
    PlayerTextDrawUseBox(playerid, gEuroGuiDlg[playerid][EGD_TITLE], 1);
    PlayerTextDrawBoxColor(playerid, gEuroGuiDlg[playerid][EGD_TITLE], 0x263747FF);
    PlayerTextDrawSetOutline(playerid, gEuroGuiDlg[playerid][EGD_TITLE], 0);
    PlayerTextDrawSetShadow(playerid, gEuroGuiDlg[playerid][EGD_TITLE], 0);
    PlayerTextDrawTextSize(playerid, gEuroGuiDlg[playerid][EGD_TITLE], 604.0, 42.0);

    gEuroGuiDlg[playerid][EGD_BODY] = CreatePlayerTextDraw(playerid, 24.0, 58.0, "");
    PlayerTextDrawFont(playerid, gEuroGuiDlg[playerid][EGD_BODY], 1);
    PlayerTextDrawLetterSize(playerid, gEuroGuiDlg[playerid][EGD_BODY], 0.27, 1.25);
    PlayerTextDrawColor(playerid, gEuroGuiDlg[playerid][EGD_BODY], 0xEAF1F7FF);
    PlayerTextDrawSetOutline(playerid, gEuroGuiDlg[playerid][EGD_BODY], 0);
    PlayerTextDrawSetShadow(playerid, gEuroGuiDlg[playerid][EGD_BODY], 0);
    PlayerTextDrawTextSize(playerid, gEuroGuiDlg[playerid][EGD_BODY], 612.0, 386.0);

    // Menu entries remain individually clickable, but their backgrounds are transparent.
    for(new r = 0; r < EURO_GUI_ROWS; r++)
    {
        new idx = EGD_ROW0 + r;
        new Float:y = 62.0 + (float(r) * 39.0);
        gEuroGuiDlg[playerid][idx] = CreatePlayerTextDraw(playerid, 27.0, y, "");
        PlayerTextDrawFont(playerid, gEuroGuiDlg[playerid][idx], 1);
        PlayerTextDrawLetterSize(playerid, gEuroGuiDlg[playerid][idx], 0.31, 1.55);
        PlayerTextDrawColor(playerid, gEuroGuiDlg[playerid][idx], 0xEAF1F7FF);
        PlayerTextDrawUseBox(playerid, gEuroGuiDlg[playerid][idx], 0);
        PlayerTextDrawSetOutline(playerid, gEuroGuiDlg[playerid][idx], 0);
        PlayerTextDrawSetShadow(playerid, gEuroGuiDlg[playerid][idx], 0);
        PlayerTextDrawTextSize(playerid, gEuroGuiDlg[playerid][idx], 616.0, y + 34.0);
        PlayerTextDrawSetSelectable(playerid, gEuroGuiDlg[playerid][idx], 1);
    }

    // Controls use the same restrained accent/button style as the event GUI.
    gEuroGuiDlg[playerid][EGD_PREV] = CreatePlayerTextDraw(playerid, 12.0, 382.0, "[  НАЗАД  ]");
    gEuroGuiDlg[playerid][EGD_NEXT] = CreatePlayerTextDraw(playerid, 136.0, 382.0, "[  ДАЛЕЕ  ]");
    gEuroGuiDlg[playerid][EGD_OK] = CreatePlayerTextDraw(playerid, 260.0, 382.0, "[  ВЫБРАТЬ  ]");
    gEuroGuiDlg[playerid][EGD_INFO] = CreatePlayerTextDraw(playerid, 384.0, 382.0, "[  ИНФО  ]");
    gEuroGuiDlg[playerid][EGD_CANCEL] = CreatePlayerTextDraw(playerid, 508.0, 382.0, "[  ВЫЙТИ  ]");
    gEuroGuiDlg[playerid][EGD_CLOSE] = CreatePlayerTextDraw(playerid, 554.0, 12.0, "[  ЗАКРЫТЬ  ]");
    for(new j = EGD_PREV; j <= EGD_CLOSE; j++)
    {
        PlayerTextDrawFont(playerid, gEuroGuiDlg[playerid][j], 1);
        PlayerTextDrawLetterSize(playerid, gEuroGuiDlg[playerid][j], 0.28, 1.55);
        PlayerTextDrawColor(playerid, gEuroGuiDlg[playerid][j], 0xFFD36AFF);
        PlayerTextDrawUseBox(playerid, gEuroGuiDlg[playerid][j], 1);
        PlayerTextDrawBoxColor(playerid, gEuroGuiDlg[playerid][j], 0x263747FF);
        PlayerTextDrawSetOutline(playerid, gEuroGuiDlg[playerid][j], 0);
        PlayerTextDrawSetShadow(playerid, gEuroGuiDlg[playerid][j], 0);
        PlayerTextDrawSetSelectable(playerid, gEuroGuiDlg[playerid][j], 1);
    }
    PlayerTextDrawTextSize(playerid, gEuroGuiDlg[playerid][EGD_PREV], 112.0, 438.0);
    PlayerTextDrawTextSize(playerid, gEuroGuiDlg[playerid][EGD_NEXT], 236.0, 438.0);
    PlayerTextDrawTextSize(playerid, gEuroGuiDlg[playerid][EGD_OK], 360.0, 438.0);
    PlayerTextDrawTextSize(playerid, gEuroGuiDlg[playerid][EGD_INFO], 484.0, 438.0);
    PlayerTextDrawTextSize(playerid, gEuroGuiDlg[playerid][EGD_CANCEL], 632.0, 438.0);
    PlayerTextDrawTextSize(playerid, gEuroGuiDlg[playerid][EGD_CLOSE], 632.0, 44.0);
    return 1;
}

stock EuroGuiDlgGetLine(playerid, target, dest[])
{
    new len = strlen(gEuroGuiDlgBody[playerid]);
    new start = gEuroGuiDlgStart[playerid], finish, idx = 0;
    while(start <= len)
    {
        finish = strfind(gEuroGuiDlgBody[playerid], "\n", false, start);
        if(finish == -1) finish = len;
        if(idx == target)
        {
            strmid(dest, gEuroGuiDlgBody[playerid], start, finish, EURO_GUI_ITEM_TEXT);
            trim(dest);
            return 1;
        }
        idx++;
        if(finish >= len) break;
        start = finish + 1;
    }
    dest[0] = 0;
    return 0;
}

stock EuroGuiStripColors(const input[], output[], output_size)
{
    new i, o, len = strlen(input);
    while(i < len && o < output_size - 1)
    {
        if(input[i] == '{' && i + 7 < len && input[i + 7] == '}')
        {
            i += 8;
            continue;
        }
        output[o++] = input[i++];
    }
    output[o] = 0;
    return 1;
}

stock bool:EuroGuiIsTopDialog(dialogid)
{
    return (dialogid == D_EURO_TOP || dialogid == D_BIT_TOP || dialogid == D_MEME_TOP || dialogid == D_UAH_TOP || dialogid == D_KZT_TOP || dialogid == D_FUN_TOP);
}

stock EuroGuiBuildInfo(playerid, output[], output_size)
{
    new did = gEuroGuiDlgId[playerid];
    switch(did)
    {
        case D_EURO_MENU: format(output, output_size, "\xC5\xC2\xD0\xCE — основная игровая валюта EuroSystem.\n\xCE\xC1\xCC\xC5\xCD: обмен между наличными, банком и евро.\n\xCF\xC5\xD0\xC5\xC4\xC0\xD7\xC0: отправка евро другому игроку.\n\xD1\xCA\xC8\xCD / аксессуар / машина: доступные игровые покупки.\n\xD2\xCE\xCF: рейтинг игроков по балансу евро.\n\xC8\xCD\xD4\xCE открывает справку по этому разделу.");
        case D_BIT_MENU: format(output, output_size, "\xC1\xC8\xD2\xCA\xCE\xC8\xCD — отдельный баланс криптовалюты сервера.\nКурс BTC отображается в меню.\nОбмены учитывают комиссию, указанную в названии операции.\nПередача отправляет биткоины другому игроку.\nТоп битка показывает игроков с наибольшим балансом.");
        case D_MEME_MENU: format(output, output_size, "\xCC\xC5\xCC\xCA\xCE\xC8\xCD — отдельная сезонная валюта сервера.\nКурс и срок сезона показаны вверху меню.\nПункты обмена переводят мемкоины в другие валюты и обратно.\nПолёт и случайная покупка списывают указанную сумму.\nПеред отправкой проверяй комиссию и итоговую сумму.");
        case D_UAH_MENU: format(output, output_size, "\xC3\xD0\xC8\xC2\xCD\xC0 (UAH) — отдельный валютный баланс.\nКурс и комиссия обмена показаны в меню.\nОбмен переводит гривны в выбранную валюту по курсу системы.\nПередача отправляет гривны другому игроку с комиссией.\nТоп гривны показывает лидеров по балансу.");
        case D_KZT_MENU: format(output, output_size, "\xD2\xC5\xCD\xC3\xC5 (KZT) — отдельный валютный баланс.\nКурс и комиссия обмена показаны в меню.\nВыбирай направление обмена внимательно: операция может списать комиссию.\nПередача отправляет тенге другому игроку.\nТоп тенге показывает лидеров по балансу.");
        case D_FUN_MENU: format(output, output_size, "\xD4\xC0\xCD\xCA\xCE\xC8\xCD\xDB (FC) — внутренняя валюта дополнительных функций.\nВ меню указаны цены покупок, переводов и услуг.\nИмущество позволяет оплатить срок владения объектом.\nКоды доступа создаются и отзываются в соответствующих пунктах.\nТоп FC показывает игроков с наибольшим балансом.");
        case D_EURO_TOP, D_BIT_TOP, D_MEME_TOP, D_UAH_TOP, D_KZT_TOP, D_FUN_TOP: format(output, output_size, "Это рейтинг игроков по балансу выбранной валюты.\nЗаписи отсортированы от большего баланса к меньшему.\nКнопки «Назад» и «Далее» переключают страницы рейтинга.\nНажатие на строку не переводит валюту и не меняет баланс.");
        case D_EURO_EX, D_BIT_EX, D_KZT_EX: format(output, output_size, "Выбери направление обмена.\nПеред подтверждением проверь валюту списания и получения.\nКомиссия зависит от конкретной операции и указана в меню валюты.\nЕсли не хочешь продолжать, нажми X.");
        case D_EURO_GIVE, D_EURO_GIVE_AMT, D_BIT_GIVE, D_BIT_GIVE_AMT, D_UAH_GIVE, D_UAH_GIVE_AMT, D_KZT_GIVE, D_KZT_GIVE_AMT, D_MEME_GIVE, D_MEME_GIVE_AMT, D_FUN_GIVE, D_FUN_GIVE_AMT: format(output, output_size, "Передача валюты другому игроку.\nУкажи ID получателя, затем сумму.\nПроверь ID и сумму до подтверждения.\nКомиссия, если она предусмотрена, рассчитывается системой автоматически.");
        case D_EURO_SKIN, D_EURO_ACS, D_EURO_CAR, D_EURO_TUNE: format(output, output_size, "Этот пункт запускает игровую покупку или настройку.\nПроверь ID и требования перед вводом.\nСтоимость и условия определяются штатной логикой EuroSystem.");
        case D_FUN_PROP_TYPE, D_FUN_PROP_LIST, D_FUN_PROP_DAYS: format(output, output_size, "Раздел оплаты имущества за FC.\nВыбери тип объекта, затем объект и срок оплаты.\nПеред подтверждением проверь объект и количество дней.");
        case D_FUN_CODE_NICK, D_FUN_CODE_DAYS:
        {
            format(output, output_size, "\xCA\xEE\xE4 \xE4\xEE\xF1\xF2\xF3\xEF\xE0 \xE4\xE0\xE5\xF2 \xE2\xF0\xE5\xEC\xE5\xED\xED\xFB\xE9 \xE4\xEE\xF1\xF2\xF3\xEF \xF7\xE5\xF0\xE5\xE7 AccessGate.");
            strcat(output, "\n\xD1\xF0\xEE\xEA \xE2\xFB\xE1\xE8\xF0\xE0\xE5\xF2\xF1\xFF \xE8\xE7 \xE3\xEE\xF2\xEE\xE2\xFB\xF5 \xE2\xE0\xF0\xE8\xE0\xED\xF2\xEE\xE2: \xEE\xF2 15 \xE4\xEE 2000 \xE4\xED\xE5\xE9.", output_size);
            strcat(output, "\n\xD6\xE5\xED\xE0 \xE7\xE0\xE2\xE8\xF1\xE8\xF2 \xEE\xF2 \xF1\xF0\xEE\xEA\xE0: 500 FC \xE7\xE0 \xEA\xE0\xE6\xE4\xFB\xE5 30 \xE4\xED\xE5\xE9.", output_size);
            strcat(output, "\n\xCA\xEE\xE4 \xE4\xE5\xE9\xF1\xF2\xE2\xF3\xE5\xF2 \xF2\xEE\xEB\xFC\xEA\xEE \xE4\xEB\xFF \xF3\xEA\xE0\xE7\xE0\xED\xED\xEE\xE3\xEE \xED\xE8\xEA.", output_size);
        }
        default: format(output, output_size, "Информация по текущему разделу EuroSystem.\nИспользуй кнопки меню для выбора действия.\nX закрывает окно без подтверждения операции.\nБаланс и операции выполняются штатной логикой системы.");
    }
    return 1;
}

stock EuroGuiDlgRender(playerid)
{
    if(!gEuroGuiDlgCreated[playerid]) EuroGuiDlgCreate(playerid);
    gEuroGuiDlgActive[playerid] = true;
    new cleanTitle[128];
    EuroGuiStripColors(gEuroGuiDlgTitle[playerid], cleanTitle, sizeof cleanTitle);
    PlayerTextDrawSetString(playerid, gEuroGuiDlg[playerid][EGD_TITLE], cleanTitle);
    PlayerTextDrawSetString(playerid, gEuroGuiDlg[playerid][EGD_BODY], gEuroGuiDlgBody[playerid]);
    if(gEuroGuiDlgButton1[playerid][0]) PlayerTextDrawSetString(playerid, gEuroGuiDlg[playerid][EGD_OK], gEuroGuiDlgButton1[playerid]);
    else PlayerTextDrawSetString(playerid, gEuroGuiDlg[playerid][EGD_OK], "OK");
    if(gEuroGuiDlgButton2[playerid][0]) PlayerTextDrawSetString(playerid, gEuroGuiDlg[playerid][EGD_CANCEL], gEuroGuiDlgButton2[playerid]);
    else PlayerTextDrawSetString(playerid, gEuroGuiDlg[playerid][EGD_CANCEL], "\xC7\xC0\xCA\xD0\xDB\xD2\xDC");
    for(new i = 0; i < EGD_COUNT; i++) PlayerTextDrawShow(playerid, gEuroGuiDlg[playerid][i]);

    if(gEuroGuiDlgStyle[playerid] == DIALOG_STYLE_LIST || gEuroGuiDlgStyle[playerid] == DIALOG_STYLE_TABLIST || gEuroGuiDlgStyle[playerid] == DIALOG_STYLE_TABLIST_HEADERS)
    {
        PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][EGD_BODY]);
        for(new r = 0; r < EURO_GUI_ROWS; r++)
        {
            new idx = EGD_ROW0 + r;
            new item = gEuroGuiDlgPage[playerid] * EURO_GUI_ROWS + r;
            if(item < gEuroGuiDlgItems[playerid])
            {
                new itemText[EURO_GUI_ITEM_TEXT];
                new cleanItem[EURO_GUI_ITEM_TEXT];
                EuroGuiDlgGetLine(playerid, item, itemText);
                EuroGuiStripColors(itemText, cleanItem, sizeof cleanItem);
                PlayerTextDrawSetString(playerid, gEuroGuiDlg[playerid][idx], cleanItem);
                if(EuroGuiIsTopDialog(gEuroGuiDlgId[playerid]) && item == 0) PlayerTextDrawColor(playerid, gEuroGuiDlg[playerid][idx], 0xFFD700FF);
                else if(EuroGuiIsTopDialog(gEuroGuiDlgId[playerid]) && item == 1) PlayerTextDrawColor(playerid, gEuroGuiDlg[playerid][idx], 0xC0C0C0FF);
                else if(EuroGuiIsTopDialog(gEuroGuiDlgId[playerid]) && item == 2) PlayerTextDrawColor(playerid, gEuroGuiDlg[playerid][idx], 0xCD7F32FF);
                else PlayerTextDrawColor(playerid, gEuroGuiDlg[playerid][idx], 0xF0F4FAFF);
                PlayerTextDrawShow(playerid, gEuroGuiDlg[playerid][idx]);
            }
            else PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][idx]);
        }
        if(gEuroGuiDlgPage[playerid] > 0) PlayerTextDrawShow(playerid, gEuroGuiDlg[playerid][EGD_PREV]);
        else PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][EGD_PREV]);
        if((gEuroGuiDlgPage[playerid] + 1) * EURO_GUI_ROWS < gEuroGuiDlgItems[playerid]) PlayerTextDrawShow(playerid, gEuroGuiDlg[playerid][EGD_NEXT]);
        else PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][EGD_NEXT]);
        PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][EGD_OK]);
    }
    else
    {
        for(new r = 0; r < EURO_GUI_ROWS; r++) PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][EGD_ROW0 + r]);
        PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][EGD_PREV]);
        PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][EGD_NEXT]);
        if(gEuroGuiDlgStyle[playerid] == DIALOG_STYLE_INPUT)
        {
            PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][EGD_OK]);
            gEuroGuiInputActive[playerid] = true;
        }
        else PlayerTextDrawShow(playerid, gEuroGuiDlg[playerid][EGD_OK]);
    }
    if(gEuroGuiDlgId[playerid] == EURO_GUI_INFO_DIALOG) PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][EGD_INFO]);
    else PlayerTextDrawShow(playerid, gEuroGuiDlg[playerid][EGD_INFO]);
    if(gEuroGuiDlgButton2[playerid][0]) PlayerTextDrawShow(playerid, gEuroGuiDlg[playerid][EGD_CANCEL]);
    else PlayerTextDrawHide(playerid, gEuroGuiDlg[playerid][EGD_CANCEL]);
    SelectTextDraw(playerid, 0xFFD700FF);
    return 1;
}

stock EuroShowPlayerDialog(playerid, dialogid, style, caption[], info[], button1[], button2[])
{
    if(style != DIALOG_STYLE_LIST && style != DIALOG_STYLE_MSGBOX && style != DIALOG_STYLE_TABLIST && style != DIALOG_STYLE_TABLIST_HEADERS && style != DIALOG_STYLE_INPUT)
        return ShowPlayerDialog(playerid, dialogid, style, caption, info, button1, button2);
    if(gEuroGuiDlgActive[playerid]) EuroGuiDlgHide(playerid);
    gEuroGuiInputActive[playerid] = false;
    gEuroGuiDlgId[playerid] = dialogid;
    gEuroGuiDlgStyle[playerid] = style;
    gEuroGuiDlgPage[playerid] = 0;
    gEuroGuiDlgItems[playerid] = 0;
    gEuroGuiDlgStart[playerid] = 0;
    format(gEuroGuiDlgTitle[playerid], sizeof gEuroGuiDlgTitle[], "%s", caption);
    if(style == DIALOG_STYLE_INPUT)
        format(gEuroGuiDlgBody[playerid], sizeof gEuroGuiDlgBody[], "%s\n\n\xC2\xE2\xE5\xE4\xE8\xF2\xE5 \xEE\xF2\xE2\xE5\xF2 \xF1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xE5\xEC \xE2 \xF7\xE0\xF2. \xC4\xEB\xFF \xEE\xF2\xEC\xE5\xED\xFB \xED\xE0\xE6\xEC\xE8\xF2\xE5 X.", info);
    else format(gEuroGuiDlgBody[playerid], sizeof gEuroGuiDlgBody[], "%s", info);
    format(gEuroGuiDlgButton1[playerid], sizeof gEuroGuiDlgButton1[], "%s", button1);
    format(gEuroGuiDlgButton2[playerid], sizeof gEuroGuiDlgButton2[], "%s", button2);
    if(style == DIALOG_STYLE_LIST || style == DIALOG_STYLE_TABLIST || style == DIALOG_STYLE_TABLIST_HEADERS)
    {
        new len = strlen(info), start = 0, finish;
        if(style == DIALOG_STYLE_TABLIST_HEADERS)
        {
            new headerEnd = strfind(info, "\n", false, 0);
            if(headerEnd != -1) start = headerEnd + 1;
        }
        gEuroGuiDlgStart[playerid] = start;
        while(start < len && gEuroGuiDlgItems[playerid] < EURO_GUI_ITEMS)
        {
            finish = strfind(info, "\n", false, start);
            if(finish == start) { start++; continue; }
            gEuroGuiDlgItems[playerid]++;
            if(finish == -1 || finish >= len) break;
            start = finish + 1;
        }
    }
    return EuroGuiDlgRender(playerid);
}

stock EuroGuiShowInfo(playerid)
{
    if(!gEuroGuiInfoMode[playerid])
    {
        gEuroGuiSavedId[playerid] = gEuroGuiDlgId[playerid];
        gEuroGuiSavedStyle[playerid] = gEuroGuiDlgStyle[playerid];
        gEuroGuiSavedPage[playerid] = gEuroGuiDlgPage[playerid];
        gEuroGuiSavedItems[playerid] = gEuroGuiDlgItems[playerid];
        gEuroGuiSavedStart[playerid] = gEuroGuiDlgStart[playerid];
        gEuroGuiSavedInputActive[playerid] = gEuroGuiInputActive[playerid];
        format(gEuroGuiSavedTitle[playerid], sizeof gEuroGuiSavedTitle[], "%s", gEuroGuiDlgTitle[playerid]);
        format(gEuroGuiSavedBody[playerid], sizeof gEuroGuiSavedBody[], "%s", gEuroGuiDlgBody[playerid]);
        format(gEuroGuiSavedButton1[playerid], sizeof gEuroGuiSavedButton1[], "%s", gEuroGuiDlgButton1[playerid]);
        format(gEuroGuiSavedButton2[playerid], sizeof gEuroGuiSavedButton2[], "%s", gEuroGuiDlgButton2[playerid]);
        gEuroGuiInfoMode[playerid] = true;
    }
    new info[EURO_GUI_TEXT];
    EuroGuiBuildInfo(playerid, info, sizeof info);
    EuroShowPlayerDialog(playerid, EURO_GUI_INFO_DIALOG, DIALOG_STYLE_MSGBOX, "\xC8\xCD\xD4\xCE\xD0\xCC\xC0\xD6\xC8\xDF", info, "OK", "X");
    return 1;
}


stock EuroGuiRestoreAfterInfo(playerid)
{
    gEuroGuiDlgId[playerid] = gEuroGuiSavedId[playerid];
    gEuroGuiDlgStyle[playerid] = gEuroGuiSavedStyle[playerid];
    gEuroGuiDlgPage[playerid] = gEuroGuiSavedPage[playerid];
    gEuroGuiDlgItems[playerid] = gEuroGuiSavedItems[playerid];
    gEuroGuiDlgStart[playerid] = gEuroGuiSavedStart[playerid];
    format(gEuroGuiDlgTitle[playerid], sizeof gEuroGuiDlgTitle[], "%s", gEuroGuiSavedTitle[playerid]);
    format(gEuroGuiDlgBody[playerid], sizeof gEuroGuiDlgBody[], "%s", gEuroGuiSavedBody[playerid]);
    format(gEuroGuiDlgButton1[playerid], sizeof gEuroGuiDlgButton1[], "%s", gEuroGuiSavedButton1[playerid]);
    format(gEuroGuiDlgButton2[playerid], sizeof gEuroGuiDlgButton2[], "%s", gEuroGuiSavedButton2[playerid]);
    gEuroGuiInfoMode[playerid] = false;
    gEuroGuiInputActive[playerid] = gEuroGuiSavedInputActive[playerid];
    return EuroGuiDlgRender(playerid);
}


stock trim(s[])
{
	new a, b = strlen(s);
	while(a < b && s[a] <= ' ') a++;
	while(b > a && s[b - 1] <= ' ') b--;
	strdel(s, b, strlen(s));
	if(a) strdel(s, 0, a);
}

stock bool:MemeSeasonActive()
{
	if(!gMemeSeasonLoaded) return false;
	new y, mo, d, h, mi, s;
	getdate(y, mo, d);
	gettime(h, mi, s);
	#pragma unused s
	if(y > gMemeEndY) return false;
	if(y < gMemeEndY) return true;
	if(mo > gMemeEndMo) return false;
	if(mo < gMemeEndMo) return true;
	if(d > gMemeEndD) return false;
	if(d < gMemeEndD) return true;
	if(h > gMemeEndH) return false;
	if(h < gMemeEndH) return true;
	if(mi > gMemeEndMi) return false;
	return true;
}

// Записать текущий сезон в БД
stock MemeSaveSeasonToDB()
{
	if(!gSQLOk) return 0;
	new q[320];
	mysql_format(gSQL, q, sizeof q,
		"CREATE TABLE IF NOT EXISTS `memecoin_season` (`id` INT NOT NULL PRIMARY KEY, `name` VARCHAR(32) NOT NULL, `end_y` INT NOT NULL, `end_mo` INT NOT NULL, `end_d` INT NOT NULL, `end_h` INT NOT NULL, `end_mi` INT NOT NULL)");
	mysql_tquery(gSQL, q);
	mysql_format(gSQL, q, sizeof q,
		"INSERT INTO `memecoin_season` (`id`,`name`,`end_y`,`end_mo`,`end_d`,`end_h`,`end_mi`) VALUES (1,'%e',%d,%d,%d,%d,%d) ON DUPLICATE KEY UPDATE `name`='%e',`end_y`=%d,`end_mo`=%d,`end_d`=%d,`end_h`=%d,`end_mi`=%d",
		gMemeName, gMemeEndY, gMemeEndMo, gMemeEndD, gMemeEndH, gMemeEndMi,
		gMemeName, gMemeEndY, gMemeEndMo, gMemeEndD, gMemeEndH, gMemeEndMi);
	mysql_tquery(gSQL, q);
	return 1;
}

// Применить сезон из #define (новый сезон)
stock MemeApplyDefinesAsSeason()
{
	format(gMemeName, sizeof gMemeName, "%s", MEME_NAME);
	gMemeEndY = MEME_END_YEAR;
	gMemeEndMo = MEME_END_MONTH;
	gMemeEndD = MEME_END_DAY;
	gMemeEndH = MEME_END_HOUR;
	gMemeEndMi = MEME_END_MIN;
	gMemeSeasonLoaded = true;
	gMemeSeasonEnded = false;
	MemeSaveSeasonToDB();
	printf("[Euro] New memecoin season from code: %s until %02d.%02d.%04d %02d:%02d",
		gMemeName, gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi);
	return 1;
}

forward OnMemeSeasonLoad();
public OnMemeSeasonLoad()
{
	if(cache_get_row_count(gSQL) < 1)
	{
		// В БД нет сезона — стартуем из кода
		MemeApplyDefinesAsSeason();
		return 1;
	}
	cache_get_field_content(0, "name", gMemeName, gSQL, sizeof gMemeName);
	gMemeEndY = cache_get_field_content_int(0, "end_y", gSQL);
	gMemeEndMo = cache_get_field_content_int(0, "end_mo", gSQL);
	gMemeEndD = cache_get_field_content_int(0, "end_d", gSQL);
	gMemeEndH = cache_get_field_content_int(0, "end_h", gSQL);
	gMemeEndMi = cache_get_field_content_int(0, "end_mi", gSQL);
	// защита от ??? из БД: если имя битое — всегда MEME_NAME
	{
		new qi, qcnt, bad;
		bad = !gMemeName[0];
		for(qi = 0; gMemeName[qi] && qi < 31; qi++)
		{
			if(gMemeName[qi] == '?') qcnt++;
		}
		if(qcnt >= 2) bad = 1;
		if(bad)
		{
			format(gMemeName, sizeof gMemeName, "%s", MEME_NAME);
			MemeSaveSeasonToDB();
		}
	}
	gMemeSeasonLoaded = true;

	printf("[Euro] Season from DB: %s until %02d.%02d.%04d %02d:%02d",
		gMemeName, gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi);

	// Если сезон в БД уже закончился — включаем новый из #define
	if(!MemeSeasonActive())
	{
		printf("[Euro] DB season ended -> apply #define as new season");
		MemeApplyDefinesAsSeason();
		new str[144];
		format(str, sizeof str, "{FF69B4}[Мемкоин] Новый сезон: %s до %02d.%02d.%04d %02d:%02d",
			gMemeName, gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi);
		SendClientMessageToAll(-1, str);
	}
	else
	{
		// Сезон ещё идёт: #define (другое имя) ждёт окончания
		if(strcmp(gMemeName, MEME_NAME, true) != 0)
			printf("[Euro] Code name pending until DB season ends: code=%s db=%s", MEME_NAME, gMemeName);
	}
	return 1;
}

stock MemeLoadSeasonFromDB()
{
	if(!gSQLOk) return 0;
	new q[280];
	mysql_format(gSQL, q, sizeof q,
		"CREATE TABLE IF NOT EXISTS `memecoin_season` (`id` INT NOT NULL PRIMARY KEY, `name` VARCHAR(32) NOT NULL, `end_y` INT NOT NULL, `end_mo` INT NOT NULL, `end_d` INT NOT NULL, `end_h` INT NOT NULL, `end_mi` INT NOT NULL)");
	mysql_tquery(gSQL, q);
	mysql_tquery(gSQL, "SELECT `id`,`name`,`end_y`,`end_mo`,`end_d`,`end_h`,`end_mi` FROM `memecoin_season` WHERE `id`=1 LIMIT 1", "OnMemeSeasonLoad", "");
	return 1;
}

forward MemeCheckSeasonTick();
public MemeCheckSeasonTick() { return MemeCheckSeason(); }

stock MemeCheckSeason()
{
	if(!gMemeSeasonLoaded) return 1;
	new bool:active = MemeSeasonActive();
	if(!active && !gMemeSeasonEnded)
	{
		gMemeSeasonEnded = true;
		new str[128];
		format(str, sizeof str, "[Мемкоин] Сезон %s ОКОНЧЕН.", gMemeName);
		SendClientMessageToAll(COLOR_MEME, str);
		// Сразу стартуем новый сезон из #define (если уже прописали другое имя/даты)
		MemeApplyDefinesAsSeason();
		format(str, sizeof str, "{FF69B4}[Мемкоин] Новый сезон: %s до %02d.%02d.%04d %02d:%02d",
			gMemeName, gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi);
		SendClientMessageToAll(-1, str);
	}
	else if(active)
		gMemeSeasonEnded = false;
	return 1;
}


stock MemeFixName()
{
	new qi, qcnt, bad;
	bad = !gMemeName[0];
	for(qi = 0; gMemeName[qi] && qi < 31; qi++)
	{
		if(gMemeName[qi] == '?') qcnt++;
	}
	if(qcnt >= 2) bad = 1;
	if(bad)
	{
		format(gMemeName, sizeof gMemeName, "%s", MEME_NAME);
		if(gSQLOk) MemeSaveSeasonToDB();
	}
	return 1;
}

stock bool:MemeRequireActive(playerid)
{
	MemeCheckSeason();
	if(!MemeSeasonActive())
	{
		SendClientMessage(playerid, COLOR_ERR, "Мемкоин сезона окончен. Дождитесь нового сезона.");
		return false;
	}
	return true;
}

stock LoadIni()
{
	format(SQL_Host, sizeof SQL_Host, "127.0.0.1");
	SQL_User[0] = SQL_Pass[0] = SQL_DB[0] = 0;
	if(!fexist(MYSQL_FILE)) { print("[Euro] нет ini"); return 0; }
	new File:f = fopen(MYSQL_FILE, io_read), line[256];
	if(!f) return 0;
	while(fread(f, line))
	{
		for(new i; line[i]; i++) if(line[i] == '\r' || line[i] == '\n') { line[i] = 0; break; }
		trim(line);
		if(!line[0] || line[0] == ';' || line[0] == '#' || line[0] == '[') continue;
		new eq = strfind(line, "="); if(eq < 1) continue;
		new key[64], val[128];
		strmid(key, line, 0, eq); strmid(val, line, eq + 1, strlen(line));
		trim(key); trim(val);
		if(!strcmp(key, "host", true) || !strcmp(key, "hostname", true) || !strcmp(key, "server", true))
			format(SQL_Host, sizeof SQL_Host, "%s", val);
		else if(!strcmp(key, "username", true) || !strcmp(key, "user", true) || !strcmp(key, "login", true))
			format(SQL_User, sizeof SQL_User, "%s", val);
		else if(!strcmp(key, "password", true) || !strcmp(key, "pass", true))
			format(SQL_Pass, sizeof SQL_Pass, "%s", val);
		else if(!strcmp(key, "database", true) || !strcmp(key, "db", true) || !strcmp(key, "dbname", true))
			format(SQL_DB, sizeof SQL_DB, "%s", val);
	}
	fclose(f);
	printf("[Euro] %s@%s / %s", SQL_User, SQL_Host, SQL_DB);
	return (SQL_User[0] && SQL_DB[0]);
}

stock ConnectSQL()
{
	gSQL = mysql_connect(SQL_Host, SQL_User, SQL_DB, SQL_Pass);
	if(gSQL && mysql_errno(gSQL) == 0)
	{
		mysql_tquery(gSQL, "SET NAMES 'cp1251'");
		mysql_tquery(gSQL, "SET CHARACTER SET cp1251");
		return 1;
	}
	gSQL = mysql_connect(SQL_Host, SQL_User, SQL_Pass, SQL_DB);
	if(gSQL && mysql_errno(gSQL) == 0)
	{
		mysql_tquery(gSQL, "SET NAMES 'cp1251'");
		mysql_tquery(gSQL, "SET CHARACTER SET cp1251");
		return 1;
	}
	gSQL = 0;
	return 0;
}

stock SaveEuro(playerid)
{
	// async — mysql_query на leave/PayDay клал поток сервера
	if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
	if(!gSQLOk || !PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
	new q[400];
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` SET `evro`=%d,`evro_exchanged`=%d,`bitok`=%d,`memecoin`=%d,`meme_last`=%d,`uah`=%d,`kzt`=%d,`play_sec`=%d,`meme_rand`=%d,`funcoin`=%d WHERE `id`=%d LIMIT 1",
		PlayerEuro[playerid], PlayerEuroEx[playerid], PlayerBit[playerid],
		PlayerMeme[playerid], PlayerLastLogin[playerid],
		PlayerUAH[playerid], PlayerKZT[playerid], PlayerPlaySec[playerid], PlayerRandBuys[playerid],
		PlayerFun[playerid], PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	return 1;
}

// Safe PVZ payout queue shared through player PVars; no CallRemoteFunction is used.
stock FR_PVZ_ProcessPendingEuro(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new amount = GetPVarInt(playerid, "FR_PVZ_PENDING_EURO");
    if(amount <= 0 || amount > 10000) return 0;
    if(!gSQLOk || !PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
    if(PlayerEuro[playerid] > 2147483647 - amount)
    {
        DeletePVar(playerid, "FR_PVZ_PENDING_EURO");
        SendClientMessage(playerid, COLOR_ERR, "[ПВЗ] Выплата отменена: достигнут предел баланса евро.");
        return 0;
    }
    DeletePVar(playerid, "FR_PVZ_PENDING_EURO");
    PlayerEuro[playerid] += amount;
    SaveEuro(playerid);
    new msg[96];
    format(msg, sizeof msg, "[ПВЗ] Начислено %d евро за доставку.", amount);
    SendClientMessage(playerid, COLOR_EURO, msg);
    return 1;
}
forward FR_PVZ_ProcessPendingEuroTimer();
public FR_PVZ_ProcessPendingEuroTimer()
{
    for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
        if(IsPlayerConnected(playerid))
        {
            FR_PVZ_ProcessPendingEuro(playerid);
            FR_PVZ_ProcessPendingFC(playerid);
            FR_PVZ_ProcessPendingBit(playerid);
        }
    return 1;
}

// Safe PVZ FunCoin payout queue. The filterscript only queues the amount in a PVar;
// this code updates the existing FunCoin balance and saves it through EuroSystem.
stock FR_PVZ_ProcessPendingFC(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new amount = GetPVarInt(playerid, "FR_PVZ_PENDING_FC");
    if(amount <= 0 || amount > 10000) return 0;
    if(!gSQLOk || !PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
    if(PlayerFun[playerid] > 2147483647 - amount)
    {
        DeletePVar(playerid, "FR_PVZ_PENDING_FC");
        SendClientMessage(playerid, COLOR_ERR, "[ПВЗ] Выплата FunCoin отменена: достигнут предел баланса.");
        return 0;
    }
    DeletePVar(playerid, "FR_PVZ_PENDING_FC");
    PlayerFun[playerid] += amount;
    SaveEuro(playerid);
    new msg[96];
    format(msg, sizeof msg, "[ПВЗ] Начислено %d FunCoin за доставку.", amount);
    SendClientMessage(playerid, 0xFFD700FF, msg);
    return 1;
}


// Safe PVZ bitcoin payout queue; uses the existing PlayerBit balance and accounts.bitok.
stock FR_PVZ_ProcessPendingBit(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    new amount = GetPVarInt(playerid, "FR_PVZ_PENDING_BIT");
    if(amount <= 0 || amount > 10000) return 0;
    if(!gSQLOk || !PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
    if(PlayerBit[playerid] > 2147483647 - amount)
    {
        DeletePVar(playerid, "FR_PVZ_PENDING_BIT");
        SendClientMessage(playerid, COLOR_ERR, "[ПВЗ] Выплата битков отменена: достигнут предел баланса.");
        return 0;
    }
    DeletePVar(playerid, "FR_PVZ_PENDING_BIT");
    PlayerBit[playerid] += amount;
    SaveEuro(playerid);
    new msg[96];
    format(msg, sizeof msg, "[ПВЗ] Начислено %d битков за доставку.", amount);
    SendClientMessage(playerid, 0x00BFFFFF, msg);
    return 1;
}

// Timer callback must be public: stock functions cannot be called by SetTimerEx.
forward LoadEuro(playerid);
public LoadEuro(playerid)
{
	if(!gSQLOk) return 0;
	new name[24], q[280];
	GetPlayerName(playerid, name, sizeof name);
	mysql_format(gSQL, q, sizeof q,
		"SELECT `id`, IFNULL(`evro`,0), IFNULL(`evro_exchanged`,0), IFNULL(`bitok`,0), IFNULL(`memecoin`,0), IFNULL(`meme_last`,0), IFNULL(`uah`,0), IFNULL(`kzt`,0), IFNULL(`play_sec`,0), IFNULL(`meme_rand`,0), IFNULL(`funcoin`,0) FROM `accounts` WHERE `name`='%e' LIMIT 1",
		name);
	mysql_tquery(gSQL, q, "OnEuroLoad", "i", playerid);
	return 1;
}

forward OnEuroLoad(playerid);
public OnEuroLoad(playerid)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL);
	if(rows < 1)
	{
		// retry without meme cols (first start before ALTER finishes)
		new name[24], q[200];
		GetPlayerName(playerid, name, sizeof name);
		mysql_format(gSQL, q, sizeof q,
			"SELECT `id`, IFNULL(`evro`,0), IFNULL(`evro_exchanged`,0) FROM `accounts` WHERE `name`='%e' LIMIT 1", name);
		mysql_tquery(gSQL, q, "OnEuroLoadSimple", "i", playerid);
		return 1;
	}
	PlayerAccID[playerid] = cache_get_row_int(0, 0, gSQL);
	PlayerEuro[playerid] = cache_get_row_int(0, 1, gSQL);
	PlayerEuroEx[playerid] = cache_get_row_int(0, 2, gSQL);
	PlayerBit[playerid] = cache_get_row_int(0, 3, gSQL);
	PlayerMeme[playerid] = cache_get_row_int(0, 4, gSQL);
	PlayerLastLogin[playerid] = cache_get_row_int(0, 5, gSQL);
	PlayerUAH[playerid] = cache_get_row_int(0, 6, gSQL);
	PlayerKZT[playerid] = cache_get_row_int(0, 7, gSQL);
	PlayerPlaySec[playerid] = cache_get_row_int(0, 8, gSQL);
	PlayerRandBuys[playerid] = cache_get_row_int(0, 9, gSQL);
	PlayerFun[playerid] = cache_get_row_int(0, 10, gSQL);
	PlayerLoaded[playerid] = true;
	MemeOnLogin(playerid);
	printf("[Euro] загружен %d acc=%d евро=%d бит=%d мем=%d", playerid, PlayerAccID[playerid], PlayerEuro[playerid], PlayerBit[playerid], PlayerMeme[playerid]);
	return 1;
}

forward OnEuroLoadSimple(playerid);
public OnEuroLoadSimple(playerid)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid)) return 1;
	if(cache_get_row_count(gSQL) < 1)
	{
		PlayerLoaded[playerid] = false;
		print("[Euro] аккаунт не найден в БД");
		return 1;
	}
	PlayerAccID[playerid] = cache_get_row_int(0, 0, gSQL);
	PlayerEuro[playerid] = cache_get_row_int(0, 1, gSQL);
	PlayerEuroEx[playerid] = cache_get_row_int(0, 2, gSQL);
	PlayerBit[playerid] = 0;
	PlayerMeme[playerid] = 0;
	PlayerFun[playerid] = 0;
	PlayerLastLogin[playerid] = gettime();
	PlayerLoaded[playerid] = true;
	printf("[Euro] простая загрузка %d acc=%d евро=%d", playerid, PlayerAccID[playerid], PlayerEuro[playerid]);
	return 1;
}

stock MemeOnLogin(playerid)
{
	if(!PlayerLoaded[playerid]) return 0;
	new nowt = gettime();
	new last = PlayerLastLogin[playerid];
	if(last <= 0)
	{
		PlayerLastLogin[playerid] = nowt;
		SaveEuro(playerid);
		return 1;
	}
	new delta = nowt - last;
	if(delta < 0) delta = 0;
	new days = delta / 86400;

	if(days >= MEME_OFFLINE_DAYS && PlayerMeme[playerid] > 0)
	{
		new old = PlayerMeme[playerid];
		PlayerMeme[playerid] = 0;
		PlayerLastLogin[playerid] = nowt;
		SaveEuro(playerid);
		new str[144];
		format(str, sizeof str, "{FF69B4}[Мемкоин] Ваш %s (%d шт.) расформирован: нет входа %d+ дней.", gMemeName, old, MEME_OFFLINE_DAYS);
		SendClientMessage(playerid, -1, str);
		return 1;
	}
	if(days >= 1 && PlayerMeme[playerid] > 0 && MemeSeasonActive())
	{
		new add = (PlayerMeme[playerid] * MEME_GROW_PCT_DAY * days) / 100;
		if(add < 1) add = 1;
		PlayerMeme[playerid] += add;
		new str[128];
		format(str, sizeof str, "{FF69B4}[Мемкоин] %s вырос на +%d (%d дн.). Итого: %d", gMemeName, add, days, PlayerMeme[playerid]);
		SendClientMessage(playerid, -1, str);
	}
	PlayerLastLogin[playerid] = nowt;
	SaveEuro(playerid);
	return 1;
}

forward UpdateRate();
public UpdateRate()
{
	HTTP(9911, HTTP_GET, "www.cbr.ru/scripts/XML_daily.asp", "", "OnRateHTTP");
	HTTP(9912, HTTP_GET, "api.coindesk.com/v1/bpi/currentprice/RUB.json", "", "OnBitRateHTTP");
	new h, mi, s; gettime(h, mi, s);
	gMemeRate = 50.0 + float(h) * 3.5 + float(mi) * 0.1;
	if(gMemeRate < 10.0) gMemeRate = 10.0;
	MemeCheckSeason();
	return 1;
}

stock Float:CBRParseVal(data[], code[])
{
	new p = strfind(data, code, true);
	if(p == -1) return 0.0;
	new v = strfind(data, "<Value>", true, p);
	if(v == -1) return 0.0;
	v += 7;
	new buf[24], i;
	while(data[v] && data[v] != '<' && i < 20) { buf[i++] = (data[v] == ',') ? '.' : data[v]; v++; }
	buf[i] = 0;
	return floatstr(buf);
}

forward OnRateHTTP(index, response_code, data[]);
public OnRateHTTP(index, response_code, data[])
{
	#pragma unused index
	if(response_code != 200 || strlen(data) < 40) return 1;
	new Float:r;
	r = CBRParseVal(data, "EUR");
	if(r > 20.0 && r < 250.0) gEuroRate = r;
	// UAH: ЦБ даёт за 10 гривен — делим на 10
	r = CBRParseVal(data, "UAH");
	if(r > 5.0 && r < 100.0) gUahRate = r / 10.0;
	else if(r > 0.5 && r < 20.0) gUahRate = r;
	// KZT: ЦБ даёт за 100 тенге — делим на 100
	r = CBRParseVal(data, "KZT");
	if(r > 5.0 && r < 50.0) gKztRate = r / 100.0;
	else if(r > 0.05 && r < 2.0) gKztRate = r;
	return 1;
}

forward OnBitRateHTTP(index, response_code, data[]);
public OnBitRateHTTP(index, response_code, data[])
{
	#pragma unused index
	if(response_code != 200 || strlen(data) < 20) return 1;
	new p = strfind(data, "rate_float", true); if(p == -1) return 1;
	p = strfind(data, ":", true, p); if(p == -1) return 1; p++;
	while(data[p] == ' ') p++;
	new buf[32], i;
	while(data[p] && ((data[p] >= '0' && data[p] <= '9') || data[p] == '.') && i < 30) { buf[i++] = data[p]; p++; }
	buf[i] = 0;
	new Float:r = floatstr(buf);
	if(r > 100000.0 && r < 500000000.0) gBitRate = r;
	return 1;
}

forward MemeAnnounce();
public MemeAnnounce()
{
	MemeCheckSeason();
	MemeFixName();
	new str[160];
	if(MemeSeasonActive())
		format(str, sizeof str, "{FF69B4}[Мемкоин] Сейчас: %s | до %02d.%02d.%04d %02d:%02d | курс %.1f | .meme",
			gMemeName, gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi, gMemeRate);
	else
		format(str, sizeof str, "{FF69B4}[Мемкоин] Сезон %s завершён.", gMemeName);
	SendClientMessageToAll(-1, str);
	return 1;
}

stock DoExchange(playerid, amount, toBank)
{
	if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Евро не загружены"), 0;
	if(amount <= 0 || PlayerEuro[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new rub = floatround(float(amount) * gEuroRate, floatround_floor); if(rub < 1) rub = 1;
	PlayerEuro[playerid] -= amount; PlayerEuroEx[playerid] += amount; SaveEuro(playerid);
	new q[280];
	if(toBank)
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `bank`=IFNULL(`bank`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
	else
	{
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `money`=IFNULL(`money`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
		GivePlayerMoney(playerid, rub);
	}
	mysql_tquery(gSQL, q);
	new str[128]; format(str, sizeof str, "{FFD700}Евро->руб: -%d = +%d (%s)", amount, rub, toBank ? "банк" : "нал");
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BuyEuroFromRub(playerid, rub_amount, fromBank)
{
	if(!PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return SendClientMessage(playerid, COLOR_ERR, "Евро не загружены"), 0;
	if(rub_amount < 1) return SendClientMessage(playerid, COLOR_ERR, "Сумма"), 0;
	if(gEuroRate < 1.0) return SendClientMessage(playerid, COLOR_ERR, "Курс ещё не загружен"), 0;
	new euro = floatround(float(rub_amount) / gEuroRate, floatround_floor);
	if(euro < 1) return SendClientMessage(playerid, COLOR_ERR, "Мало на 1 евро"), 0;
	new cost = floatround(float(euro) * gEuroRate, floatround_ceil); if(cost < 1) cost = 1;
	EuroBuyMode[playerid] = fromBank ? 1 : 0;
	new q[200];
	if(fromBank)
		mysql_format(gSQL, q, sizeof q, "SELECT IFNULL(`bank`,0) FROM `accounts` WHERE `id`=%d LIMIT 1", PlayerAccID[playerid]);
	else
		mysql_format(gSQL, q, sizeof q, "SELECT IFNULL(`money`,0) FROM `accounts` WHERE `id`=%d LIMIT 1", PlayerAccID[playerid]);
	mysql_tquery(gSQL, q, "OnBuyEuroCheck", "iii", playerid, euro, cost);
	return 1;
}

forward OnBuyEuroCheck(playerid, euro, cost);
public OnBuyEuroCheck(playerid, euro, cost)
{
	if(!IsPlayerConnected(playerid) || !PlayerLoaded[playerid]) return 1;
	new have = 0;
	if(cache_get_row_count(gSQL) > 0) have = cache_get_row_int(0, 0, gSQL);
	new fromBank = EuroBuyMode[playerid];
	if(!fromBank) { new pm = GetPlayerMoney(playerid); if(pm > have) have = pm; }
	if(have < cost) { SendClientMessage(playerid, COLOR_ERR, "Не хватает рублей"); return 1; }
	new q[260];
	if(fromBank)
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `bank`=IFNULL(`bank`,0)-%d WHERE `id`=%d AND IFNULL(`bank`,0)>=%d LIMIT 1", cost, PlayerAccID[playerid], cost);
	else
	{
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `money`=IFNULL(`money`,0)-%d WHERE `id`=%d LIMIT 1", cost, PlayerAccID[playerid]);
		if(GetPlayerMoney(playerid) >= cost) GivePlayerMoney(playerid, -cost);
	}
	mysql_tquery(gSQL, q);
	PlayerEuro[playerid] += euro; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FFD700}Руб->евро: -%d = +%d евро", cost, euro);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BitToRub(playerid, bit_amount, toBank)
{
	if(!PlayerLoaded[playerid]) return 0;
	if(bit_amount <= 0 || PlayerBit[playerid] < bit_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало битка"), 0;
	new Float:gross = float(bit_amount) * gBitRate;
	new fee = floatround(gross * float(BIT_FEE_PCT) / 100.0, floatround_ceil);
	new rub = floatround(gross, floatround_floor) - fee; if(rub < 1) rub = 1;
	PlayerBit[playerid] -= bit_amount; SaveEuro(playerid);
	new q[260];
	if(toBank)
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `bank`=IFNULL(`bank`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
	else
	{
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `money`=IFNULL(`money`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
		GivePlayerMoney(playerid, rub);
	}
	mysql_tquery(gSQL, q);
	new str[120]; format(str, sizeof str, "{00BFFF}Бит->руб: -%d = +%d (комиссия %d%%)", bit_amount, rub, BIT_FEE_PCT);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BitToEuro(playerid, bit_amount)
{
	if(!PlayerLoaded[playerid]) return 0;
	if(bit_amount <= 0 || PlayerBit[playerid] < bit_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало битка"), 0;
	new Float:rub_value = float(bit_amount) * gBitRate * (1.0 - float(BIT_FEE_PCT) / 100.0);
	new euro = floatround(rub_value / gEuroRate, floatround_floor);
	if(euro < 1) return SendClientMessage(playerid, COLOR_ERR, "Мало после комиссии"), 0;
	PlayerBit[playerid] -= bit_amount; PlayerEuro[playerid] += euro; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{00BFFF}Бит->евро: -%d = +%d евро", bit_amount, euro);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock EuroToBit(playerid, euro_amount)
{
	if(!PlayerLoaded[playerid]) return 0;
	if(euro_amount <= 0 || PlayerEuro[playerid] < euro_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new Float:rub_value = float(euro_amount) * gEuroRate * (1.0 - float(EURO_TO_BIT_FEE_PCT) / 100.0);
	new bit = floatround(rub_value / gBitRate, floatround_floor);
	if(bit < 1) return SendClientMessage(playerid, COLOR_ERR, "Мало после 20%"), 0;
	PlayerEuro[playerid] -= euro_amount; PlayerBit[playerid] += bit; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FFD700}Евро->бит: -%d = +%d бит", euro_amount, bit);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock MemeToRub(playerid, amount, toBank)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerMeme[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало мемкоина"), 0;
	new Float:gross = float(amount) * gMemeRate;
	new fee = floatround(gross * float(MEME_FEE_PCT) / 100.0, floatround_ceil);
	new rub = floatround(gross, floatround_floor) - fee;
	if(rub < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% ничего"), 0;
	PlayerMeme[playerid] -= amount; SaveEuro(playerid);
	new q[260];
	if(toBank)
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `bank`=IFNULL(`bank`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
	else
	{
		mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `money`=IFNULL(`money`,0)+%d WHERE `id`=%d LIMIT 1", rub, PlayerAccID[playerid]);
		GivePlayerMoney(playerid, rub);
	}
	mysql_tquery(gSQL, q);
	new str[120]; format(str, sizeof str, "{FF69B4}%s->руб: -%d = +%d (комиссия 50%%)", gMemeName, amount, rub);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock MemeToEuro(playerid, amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerMeme[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало мемкоина"), 0;
	new Float:rub_value = float(amount) * gMemeRate * (1.0 - float(MEME_FEE_PCT) / 100.0);
	new euro = floatround(rub_value / gEuroRate, floatround_floor);
	if(euro < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% мало"), 0;
	PlayerMeme[playerid] -= amount; PlayerEuro[playerid] += euro; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FF69B4}%s->евро: -%d = +%d", gMemeName, amount, euro);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock MemeToBit(playerid, amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerMeme[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало мемкоина"), 0;
	new Float:rub_value = float(amount) * gMemeRate * (1.0 - float(MEME_FEE_PCT) / 100.0);
	new bit = floatround(rub_value / gBitRate, floatround_floor);
	if(bit < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% мало"), 0;
	PlayerMeme[playerid] -= amount; PlayerBit[playerid] += bit; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FF69B4}%s->бит: -%d = +%d", gMemeName, amount, bit);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock EuroToMeme(playerid, euro_amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || euro_amount <= 0 || PlayerEuro[playerid] < euro_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new Float:rub_value = float(euro_amount) * gEuroRate * (1.0 - float(MEME_FEE_PCT) / 100.0);
	new meme = floatround(rub_value / gMemeRate, floatround_floor);
	if(meme < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% мало"), 0;
	PlayerEuro[playerid] -= euro_amount; PlayerMeme[playerid] += meme; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FF69B4}Евро->%s: -%d = +%d", gMemeName, euro_amount, meme);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BitToMeme(playerid, bit_amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || bit_amount <= 0 || PlayerBit[playerid] < bit_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало битка"), 0;
	new Float:rub_value = float(bit_amount) * gBitRate * (1.0 - float(MEME_FEE_PCT) / 100.0);
	new meme = floatround(rub_value / gMemeRate, floatround_floor);
	if(meme < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% мало"), 0;
	PlayerBit[playerid] -= bit_amount; PlayerMeme[playerid] += meme; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "{FF69B4}Бит->%s: -%d = +%d", gMemeName, bit_amount, meme);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock DonateToMeme(playerid, don_amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || don_amount <= 0) return 0;
	if(PlayerAccID[playerid] < 1) return 0;
	// БЦ / BlackCoin в этой БД = поле `rub` (у новичков 333333, у топов миллиарды)
	new q[220];
	mysql_format(gSQL, q, sizeof q,
		"SELECT IFNULL(`rub`,0) FROM `accounts` WHERE `id`=%d LIMIT 1",
		PlayerAccID[playerid]);
	mysql_tquery(gSQL, q, "OnDonateToMemeCheck", "ii", playerid, don_amount);
	return 1;
}

forward OnDonateToMemeCheck(playerid, don_amount);
public OnDonateToMemeCheck(playerid, don_amount)
{
	if(!IsPlayerConnected(playerid) || !PlayerLoaded[playerid]) return 1;
	new have = 0;
	if(cache_get_row_count(gSQL) > 0)
		have = cache_get_row_int(0, 0, gSQL);

	if(have < don_amount)
	{
		new str[120];
		format(str, sizeof str, "Мало БЦ (rub). Нужно %d, на счету %d", don_amount, have);
		SendClientMessage(playerid, COLOR_ERR, str);
		return 1;
	}

	new after = don_amount - (don_amount * MEME_FEE_PCT) / 100;
	if(after < 1)
	{
		SendClientMessage(playerid, COLOR_ERR, "После 50% ничего");
		return 1;
	}
	new meme = floatround(float(after) / gMemeRate, floatround_floor);
	if(meme < 1) meme = after;

	new q[280];
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` SET `rub`=IFNULL(`rub`,0)-%d WHERE `id`=%d AND IFNULL(`rub`,0)>=%d LIMIT 1",
		don_amount, PlayerAccID[playerid], don_amount);
	mysql_tquery(gSQL, q);

	PlayerMeme[playerid] += meme;
	PlayerDonate[playerid] = have - don_amount;
	SaveEuro(playerid);

	new str[160];
	format(str, sizeof str, "{FF69B4}БЦ(rub)->%s: -%d = +%d мем (комиссия 50%%). Остаток БЦ в БД: %d",
		gMemeName, don_amount, meme, PlayerDonate[playerid]);
	SendClientMessage(playerid, -1, str);
	SendClientMessage(playerid, COLOR_EURO, "GUI обновится после релога (мод кэширует rub).");
	printf("[Euro] BC(rub)->meme player=%d -%d left=%d meme+=%d", playerid, don_amount, PlayerDonate[playerid], meme);
	return 1;
}

stock MemeToDonate(playerid, amount)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerMeme[playerid] < amount)
		return SendClientMessage(playerid, COLOR_ERR, "Мало мемкоина"), 0;
	new Float:rub_value = float(amount) * gMemeRate;
	new fee = floatround(rub_value * float(MEME_FEE_PCT) / 100.0, floatround_ceil);
	new don = floatround(rub_value, floatround_floor) - fee;
	if(don < 1) return SendClientMessage(playerid, COLOR_ERR, "После 50% доната нет"), 0;

	PlayerMeme[playerid] -= amount;
	new q[260];
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` SET `rub`=IFNULL(`rub`,0)+%d WHERE `id`=%d LIMIT 1",
		don, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SaveEuro(playerid);

	new str[140];
	format(str, sizeof str, "{FF69B4}%s->БЦ(rub): -%d = +%d (комиссия 50%%)", gMemeName, amount, don);
	SendClientMessage(playerid, -1, str);
	SendClientMessage(playerid, COLOR_EURO, "БЦ записаны в rub. Релог если GUI не обновился.");
	printf("[Euro] meme->BC(rub) player=%d meme=-%d rub+=%d", playerid, amount, don);
	return 1;
}

stock BuySkin(playerid, modelid)
{
	if(modelid < 1 || !PlayerLoaded[playerid]) return 0;
	new price = 25 + (modelid % 80); if(modelid > 1000) price = 100 + (modelid % 120);
	if(PlayerEuro[playerid] < price) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	PlayerEuro[playerid] -= price; SaveEuro(playerid);
	new acc = PlayerAccID[playerid], q[380];
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `invskins` (`account_id`,`internal_id`,`modelid`) VALUES (%d,%d,%d)", acc, modelid, modelid);
	mysql_tquery(gSQL, q);
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `inventory` (`account_id`,`item_id`,`model_id`,`old_skin`,`slot`,`amount`,`extra_1`,`extra_2`,`sim`,`oldsim`,`source_internal_id`) SELECT %d,%d,%d,0,IFNULL(MAX(`slot`),0)+1,1,0,0,0,0,%d FROM `inventory` WHERE `account_id`=%d", acc, ITEM_SKIN, modelid, modelid, acc);
	mysql_tquery(gSQL, q);
	SetPlayerSkin(playerid, modelid);
	new str[64]; format(str, sizeof str, "{FFD700}Скин %d за %d евро", modelid, price);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BuyAcs(playerid, modelid)
{
	if(modelid < 1 || !PlayerLoaded[playerid]) return 0;
	new price = 35 + (modelid % 90); if(modelid > 10000) price = 80 + (modelid % 100);
	if(PlayerEuro[playerid] < price) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	PlayerEuro[playerid] -= price; SaveEuro(playerid);
	new acc = PlayerAccID[playerid], q[380];
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `accessory_inventory` (`player_id`,`acs_id`,`use`) VALUES (%d,%d,0)", acc, modelid);
	mysql_tquery(gSQL, q);
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `inventory` (`account_id`,`item_id`,`model_id`,`old_skin`,`slot`,`amount`,`extra_1`,`extra_2`,`sim`,`oldsim`,`source_internal_id`) SELECT %d,%d,%d,0,IFNULL(MAX(`slot`),0)+1,1,0,0,0,0,0 FROM `inventory` WHERE `account_id`=%d", acc, modelid, modelid, acc);
	mysql_tquery(gSQL, q);
	new str[64]; format(str, sizeof str, "{FFD700}Акс %d за %d евро", modelid, price);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock BuyCar(playerid, modelid)
{
	if(modelid < 1 || !PlayerLoaded[playerid]) return 0;
	new price = 150 + (modelid % 250);
	if(PlayerEuro[playerid] < price) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z); GetPlayerFacingAngle(playerid, a);
	x += floatsin(-a, degrees) * 5.0; y += floatcos(-a, degrees) * 5.0;
	PlayerEuro[playerid] -= price; SaveEuro(playerid);
	new q[400];
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `ownable_cars` (`owner_id`,`model_id`,`color_1`,`color_2`,`pos_x`,`pos_y`,`pos_z`,`angle`,`create_time`,`alarm`,`key_in`,`mileage`,`fuel`,`health`,`vinilcar`,`pt_engine`,`pt_brake`,`pt_stability`,`nitro`,`launch`,`fars`) VALUES (%d,%d,1,1,%f,%f,%f,%f,%d,0,0,0.0,40.0,1000.0,0,0,0,0,0,0,0)",
		PlayerAccID[playerid], modelid, x, y, z, a, gettime());
	mysql_tquery(gSQL, q);
	new v = CreateVehicle(modelid, x, y, z + 0.3, a, 1, 1, -1);
	if(v != INVALID_VEHICLE_ID) PutPlayerInVehicle(playerid, v, 0);
	new str[64]; format(str, sizeof str, "{FFD700}Машина %d за %d евро", modelid, price);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock StartFamilyBuy(playerid)
{
	if(!PlayerLoaded[playerid]) return 0;
	if(PlayerEuro[playerid] < EURO_FAMILY_PRICE) return SendClientMessage(playerid, COLOR_ERR, "Нужно 100000 евро"), 0;
	EuroShowPlayerDialog(playerid, D_EURO_FAM_NAME, DIALOG_STYLE_INPUT, "Семья", "Название (2-30):", "OK", "X");
	return 1;
}

stock ConfirmFamily(playerid)
{
	new q[140];
	mysql_format(gSQL, q, sizeof q, "SELECT `family_id` FROM `accounts` WHERE `id`=%d LIMIT 1", PlayerAccID[playerid]);
	mysql_tquery(gSQL, q, "OnFamCheck", "i", playerid);
	return 1;
}

forward OnFamCheck(playerid);
public OnFamCheck(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new fid = 0;
	if(cache_get_row_count(gSQL) > 0) fid = cache_get_row_int(0, 0, gSQL);
	if(fid > 0) return SendClientMessage(playerid, COLOR_ERR, "Уже в семье"), 1;
	if(PlayerEuro[playerid] < EURO_FAMILY_PRICE) return 1;
	PlayerEuro[playerid] -= EURO_FAMILY_PRICE; SaveEuro(playerid);
	new q[650];
	mysql_format(gSQL, q, sizeof q, "INSERT INTO `familynew` (`owner`,`name`,`color`,`chatcolor`,`slot_veh`,`reputation`,`zaxvati`,`moneti`,`syndicate`,`patron`,`material`,`heath_kit`,`armour`,`money`,`mask`,`level_storage`,`level_weapon`,`level_compound`,`house`,`notif`,`notif_seq`,`rang_1`,`rang_2`,`rang_3`,`rang_4`,`rang_5`,`last_active`) VALUES (%d,'%e',0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,-1,'',0,'1 rang,1,0,0,0,1','2 rang,1,0,0,0,1','3 rang,1,0,0,0,1','4 rang,1,1,1,1,1','5 rang,1,1,1,1,1',%d)",
		PlayerAccID[playerid], FamilyNamePending[playerid], gettime());
	mysql_tquery(gSQL, q, "OnFamIns", "i", playerid);
	return 1;
}

forward OnFamIns(playerid);
public OnFamIns(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new id = cache_insert_id(gSQL);
	if(id < 1) { mysql_tquery(gSQL, "SELECT MAX(`id`) FROM `familynew`", "OnFamMax", "i", playerid); return 1; }
	new q[160];
	mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `family_id`=%d,`family_rang`=5 WHERE `id`=%d LIMIT 1", id, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SendClientMessage(playerid, COLOR_EURO, "Семья создана. Релог!");
	return 1;
}

forward OnFamMax(playerid);
public OnFamMax(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new id = 0;
	if(cache_get_row_count(gSQL) > 0) id = cache_get_row_int(0, 0, gSQL);
	if(id < 1) { PlayerEuro[playerid] += EURO_FAMILY_PRICE; SaveEuro(playerid); return 1; }
	new q[160];
	mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `family_id`=%d,`family_rang`=5 WHERE `id`=%d LIMIT 1", id, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SendClientMessage(playerid, COLOR_EURO, "Семья создана. Релог!");
	return 1;
}

forward PayDay();
public PayDay()
{
	if(!gSQLOk) return 1;
	new h, m, s; gettime(h, m, s);
	if(m != 0 || LastPaydayHour == h) return 1;
	LastPaydayHour = h;
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i) || !PlayerLoaded[i] || PlayerAccID[i] < 1) continue;
		PlayerEuro[i] += EURO_PAYDAY;
		PlayerBit[i] += BIT_PAYDAY;
		PlayerFun[i] += FUN_HOUR_REWARD;
		// НЕ трогаем PlayerLastLogin — иначе рост мемкоина не считает дни оффлайна
		SaveEuro(i);
		SendClientMessage(i, COLOR_EURO, "PayDay +10 евро");
		SendClientMessage(i, COLOR_BIT, "PayDay +5 биток");
	}
	return 1;
}

stock ShowTop(playerid)
{
	mysql_tquery(gSQL, "SELECT `name`,IFNULL(`evro`,0) AS e FROM `accounts` ORDER BY IFNULL(`evro`,0) DESC LIMIT 50", "OnTop", "i", playerid);
	return 1;
}
stock ShowBitTop(playerid)
{
	mysql_tquery(gSQL, "SELECT `name`,IFNULL(`bitok`,0) AS b FROM `accounts` ORDER BY IFNULL(`bitok`,0) DESC LIMIT 50", "OnBitTop", "i", playerid);
	return 1;
}
stock ShowMemeTop(playerid)
{
	mysql_tquery(gSQL, "SELECT `name`,IFNULL(`memecoin`,0) AS m FROM `accounts` ORDER BY IFNULL(`memecoin`,0) DESC LIMIT 50", "OnMemeTop", "i", playerid);
	return 1;
}

forward OnTop(playerid);
public OnTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[90], name[24], e;
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_field_content(i, "name", name, gSQL, sizeof name);
		e = cache_get_field_content_int(i, "e", gSQL);
		if(i == 0) format(line, sizeof line, "{FFD700}1. %s - %d\n", name, e);
		else if(i == 1) format(line, sizeof line, "{C0C0C0}2. %s - %d\n", name, e);
		else if(i == 2) format(line, sizeof line, "{CD7F32}3. %s - %d\n", name, e);
		else format(line, sizeof line, "%d. %s - %d\n", i + 1, name, e);
		if(strlen(body) + strlen(line) >= sizeof body - 2) break;
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	EuroShowPlayerDialog(playerid, D_EURO_TOP, DIALOG_STYLE_LIST, "{FFD700}Топ евро", body, "OK", "");
	return 1;
}

forward OnBitTop(playerid);
public OnBitTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[90], name[24], b;
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_field_content(i, "name", name, gSQL, sizeof name);
		b = cache_get_field_content_int(i, "b", gSQL);
		if(i == 0) format(line, sizeof line, "{00BFFF}1. %s - %d\n", name, b);
		else if(i == 1) format(line, sizeof line, "{C0C0C0}2. %s - %d\n", name, b);
		else if(i == 2) format(line, sizeof line, "{CD7F32}3. %s - %d\n", name, b);
		else format(line, sizeof line, "%d. %s - %d\n", i + 1, name, b);
		if(strlen(body) + strlen(line) >= sizeof body - 2) break;
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	EuroShowPlayerDialog(playerid, D_BIT_TOP, DIALOG_STYLE_LIST, "{00BFFF}Топ битка", body, "OK", "");
	return 1;
}

forward OnMemeTop(playerid);
public OnMemeTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[90], name[24], m;
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_field_content(i, "name", name, gSQL, sizeof name);
		m = cache_get_field_content_int(i, "m", gSQL);
		if(i == 0) format(line, sizeof line, "{FF69B4}1. %s - %d\n", name, m);
		else if(i == 1) format(line, sizeof line, "{C0C0C0}2. %s - %d\n", name, m);
		else if(i == 2) format(line, sizeof line, "{CD7F32}3. %s - %d\n", name, m);
		else format(line, sizeof line, "%d. %s - %d\n", i + 1, name, m);
		if(strlen(body) + strlen(line) >= sizeof body - 2) break;
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	new mt[56];
	format(mt, sizeof mt, "{FF69B4}Топ %s", gMemeName);
	EuroShowPlayerDialog(playerid, D_MEME_TOP, DIALOG_STYLE_LIST, mt, body, "OK", "");
	return 1;
}


// ===== MEME: полёт =====
stock MemeBuyFly(playerid)
{
	if(!MemeRequireActive(playerid)) return 0;
	if(PlayerMeme[playerid] < MEME_FLY_PRICE)
		return SendClientMessage(playerid, COLOR_ERR, "Нужно 10 мемкоинов"), 0;
	if(PlayerFlyActive[playerid])
		return SendClientMessage(playerid, COLOR_ERR, "Полёт уже активен"), 0;
	PlayerMeme[playerid] -= MEME_FLY_PRICE;
	SaveEuro(playerid);
	PlayerFlyActive[playerid] = 1;
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	if(PlayerFlyTimer[playerid]) KillTimer(PlayerFlyTimer[playerid]);
	// тик полёта каждые 200мс + авто-конец
	PlayerFlyTimer[playerid] = SetTimerEx("MemeFlyTick", 200, true, "i", playerid);
	SetTimerEx("MemeFlyEnd", MEME_FLY_SECONDS * 1000, false, "i", playerid);
	new str[96];
	format(str, sizeof str, "{FF69B4}Полёт на %d сек. Списано %d мемкоинов. W/A/S/D + Space", MEME_FLY_SECONDS, MEME_FLY_PRICE);
	SendClientMessage(playerid, -1, str);
	return 1;
}

forward MemeFlyTick(playerid);
public MemeFlyTick(playerid)
{
	if(!IsPlayerConnected(playerid) || !PlayerFlyActive[playerid])
	{
		if(PlayerFlyTimer[playerid]) { KillTimer(PlayerFlyTimer[playerid]); PlayerFlyTimer[playerid] = 0; }
		return 0;
	}
	// если джетпак сняли (AC/смерть) — поднимаем velocity-полётом
	if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_USEJETPACK)
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	new keys, ud, lr;
	GetPlayerKeys(playerid, keys, ud, lr);
	new Float:vx, Float:vy, Float:vz;
	GetPlayerVelocity(playerid, vx, vy, vz);
	new Float:a;
	GetPlayerFacingAngle(playerid, a);
	if(keys & KEY_SPRINT) // space up
		vz = 0.35;
	else if(keys & KEY_CROUCH)
		vz = -0.25;
	else
		vz = 0.05;
	if(ud < 0) // forward
	{
		vx = floatsin(-a, degrees) * 0.6;
		vy = floatcos(-a, degrees) * 0.6;
	}
	else if(ud > 0)
	{
		vx = floatsin(-a, degrees) * -0.4;
		vy = floatcos(-a, degrees) * -0.4;
	}
	SetPlayerVelocity(playerid, vx, vy, vz);
	return 1;
}

forward MemeFlyEnd(playerid);
public MemeFlyEnd(playerid)
{
	PlayerFlyActive[playerid] = 0;
	if(PlayerFlyTimer[playerid]) { KillTimer(PlayerFlyTimer[playerid]); PlayerFlyTimer[playerid] = 0; }
	if(!IsPlayerConnected(playerid)) return 1;
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	SendClientMessage(playerid, COLOR_MEME, "Полёт окончен.");
	return 1;
}

// ===== MEME: рандом скин/тачка/акс =====
stock MemeRandPrice(playerid)
{
	new n = PlayerRandBuys[playerid];
	// 5000, 6000, 10000, 20000, 30000...
	if(n <= 0) return MEME_RAND_BASE;
	if(n == 1) return 6000;
	if(n == 2) return 10000;
	if(n == 3) return 20000;
	return 20000 + (n - 3) * 10000;
}

stock MemeBuyRandom(playerid)
{
	if(!MemeRequireActive(playerid)) return 0;
	new price = MemeRandPrice(playerid);
	if(PlayerMeme[playerid] < price)
	{
		new str[80];
		format(str, sizeof str, "Мало мемкоинов. Нужно %d", price);
		return SendClientMessage(playerid, COLOR_ERR, str), 0;
	}
	PlayerMeme[playerid] -= price;
	PlayerRandBuys[playerid]++;
	SaveEuro(playerid);

	new kind = random(3); // 0 skin 1 car 2 acs
	new str[144];
	if(kind == 0)
	{
		new model = 1 + random(300);
		if(model < 1) model = 1;
		BuySkin(playerid, model); // may charge euro - bad
		// direct give without euro charge - inline
		PlayerEuro[playerid] += 0;
		new acc = PlayerAccID[playerid], q[380];
		// refund if BuySkin took euro - don't use BuySkin
		format(str, sizeof str, "{FF69B4}Рандом: скин ID %d (цена была %d мем)", model, price);
		SetPlayerSkin(playerid, model);
		mysql_format(gSQL, q, sizeof q, "INSERT INTO `invskins` (`account_id`,`internal_id`,`modelid`) VALUES (%d,%d,%d)", acc, model, model);
		mysql_tquery(gSQL, q);
	}
	else if(kind == 1)
	{
		new model = 400 + random(212);
		if(model > 611) model = 411;
		new Float:x, Float:y, Float:z, Float:a;
		GetPlayerPos(playerid,x,y,z); GetPlayerFacingAngle(playerid,a);
		x += floatsin(-a, degrees)*5.0; y += floatcos(-a, degrees)*5.0;
		new acc = PlayerAccID[playerid], q[400];
		mysql_format(gSQL, q, sizeof q, "INSERT INTO `ownable_cars` (`owner_id`,`model_id`,`color_1`,`color_2`,`pos_x`,`pos_y`,`pos_z`,`angle`,`create_time`,`alarm`,`key_in`,`mileage`,`fuel`,`health`,`vinilcar`,`pt_engine`,`pt_brake`,`pt_stability`,`nitro`,`launch`,`fars`) VALUES (%d,%d,1,1,%f,%f,%f,%f,%d,0,0,0.0,40.0,1000.0,0,0,0,0,0,0,0)",
			acc, model, x, y, z, a, gettime());
		mysql_tquery(gSQL, q);
		new v = CreateVehicle(model, x, y, z+0.3, a, 1, 1, -1);
		if(v != INVALID_VEHICLE_ID) PutPlayerInVehicle(playerid, v, 0);
		format(str, sizeof str, "{FF69B4}Рандом: машина ID %d (цена %d мем)", model, price);
	}
	else
	{
		new model = 1000 + random(5000);
		new acc = PlayerAccID[playerid], q[300];
		mysql_format(gSQL, q, sizeof q, "INSERT INTO `accessory_inventory` (`player_id`,`acs_id`,`use`) VALUES (%d,%d,0)", acc, model);
		mysql_tquery(gSQL, q);
		format(str, sizeof str, "{FF69B4}Рандом: акс ID %d (цена %d мем)", model, price);
	}
	SendClientMessage(playerid, -1, str);
	format(str, sizeof str, "Следующий рандом будет стоить %d мемкоинов", MemeRandPrice(playerid));
	SendClientMessage(playerid, COLOR_MEME, str);
	return 1;
}

// ===== Playtime -> UAH/KZT =====
forward PlaytimeTick();
public PlaytimeTick()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i) || !PlayerLoaded[i]) continue;
		PlayerPlaySec[i]++;
		if(PlayerPlaySec[i] >= PLAY_HOURS_REWARD * 3600)
		{
			PlayerPlaySec[i] -= PLAY_HOURS_REWARD * 3600;
			PlayerUAH[i]++;
			PlayerKZT[i]++;
			SaveEuro(i);
			SendClientMessage(i, 0x0057B8FF, "Награда за 12 ч игры: +1 гривна, +1 тенге (не обмениваются).");
		}
	}
	return 1;
}


// ===== UAH exchange (90%) + transfer =====
stock UahToEuro(playerid, amount)
{
	if(amount <= 0 || PlayerUAH[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало гривен"), 0;
	new Float:rub = float(amount) * gUahRate * (1.0 - float(UAH_FEE_PCT) / 100.0);
	new euro = floatround(rub / gEuroRate, floatround_floor);
	if(euro < 1) return SendClientMessage(playerid, COLOR_ERR, "После 90% мало"), 0;
	PlayerUAH[playerid] -= amount; PlayerEuro[playerid] += euro; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Гривна->евро: -%d = +%d (комиссия 90%%)", amount, euro);
	SendClientMessage(playerid, 0x0057B8FF, str);
	return 1;
}

stock UahToBit(playerid, amount)
{
	if(amount <= 0 || PlayerUAH[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало гривен"), 0;
	new Float:rub = float(amount) * gUahRate * (1.0 - float(UAH_FEE_PCT) / 100.0);
	new bit = floatround(rub / gBitRate, floatround_floor);
	if(bit < 1) return SendClientMessage(playerid, COLOR_ERR, "После 90% мало"), 0;
	PlayerUAH[playerid] -= amount; PlayerBit[playerid] += bit; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Гривна->бит: -%d = +%d (комиссия 90%%)", amount, bit);
	SendClientMessage(playerid, 0x0057B8FF, str);
	return 1;
}

stock EuroToUah(playerid, amount)
{
	if(amount <= 0 || PlayerEuro[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new Float:rub = float(amount) * gEuroRate * (1.0 - float(UAH_FEE_PCT) / 100.0);
	new uah = floatround(rub / gUahRate, floatround_floor);
	if(uah < 1) return SendClientMessage(playerid, COLOR_ERR, "После 90% мало"), 0;
	PlayerEuro[playerid] -= amount; PlayerUAH[playerid] += uah; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Евро->гривна: -%d = +%d (комиссия 90%%)", amount, uah);
	SendClientMessage(playerid, 0x0057B8FF, str);
	return 1;
}

stock BitToUah(playerid, amount)
{
	if(amount <= 0 || PlayerBit[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало битка"), 0;
	new Float:rub = float(amount) * gBitRate * (1.0 - float(UAH_FEE_PCT) / 100.0);
	new uah = floatround(rub / gUahRate, floatround_floor);
	if(uah < 1) return SendClientMessage(playerid, COLOR_ERR, "После 90% мало"), 0;
	PlayerBit[playerid] -= amount; PlayerUAH[playerid] += uah; SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Бит->гривна: -%d = +%d (комиссия 90%%)", amount, uah);
	SendClientMessage(playerid, 0x0057B8FF, str);
	return 1;
}

stock DonateToUah(playerid, don_amount)
{
	if(!PlayerLoaded[playerid] || don_amount <= 0 || PlayerAccID[playerid] < 1) return 0;
	new q[220];
	mysql_format(gSQL, q, sizeof q, "SELECT IFNULL(`rub`,0) FROM `accounts` WHERE `id`=%d LIMIT 1", PlayerAccID[playerid]);
	mysql_tquery(gSQL, q, "OnDonateToUahCheck", "ii", playerid, don_amount);
	return 1;
}

forward OnDonateToUahCheck(playerid, don_amount);
public OnDonateToUahCheck(playerid, don_amount)
{
	if(!IsPlayerConnected(playerid) || !PlayerLoaded[playerid]) return 1;
	new have = 0;
	if(cache_get_row_count(gSQL) > 0) have = cache_get_row_int(0, 0, gSQL);
	if(have < don_amount)
	{
		new str[100]; format(str, sizeof str, "Мало БЦ (rub). Нужно %d, есть %d", don_amount, have);
		return SendClientMessage(playerid, COLOR_ERR, str), 1;
	}
	new after = don_amount - (don_amount * UAH_FEE_PCT) / 100;
	if(after < 1) return SendClientMessage(playerid, COLOR_ERR, "После 90% ничего"), 1;
	new uah = floatround(float(after) / gUahRate, floatround_floor);
	if(uah < 1) uah = after;
	new q[280];
	mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `rub`=IFNULL(`rub`,0)-%d WHERE `id`=%d AND IFNULL(`rub`,0)>=%d LIMIT 1", don_amount, PlayerAccID[playerid], don_amount);
	mysql_tquery(gSQL, q);
	PlayerUAH[playerid] += uah; SaveEuro(playerid);
	new str[120]; format(str, sizeof str, "{0057B8}БЦ->гривна: -%d = +%d (комиссия 90%%)", don_amount, uah);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock ShowUahTop(playerid)
{
	mysql_tquery(gSQL, "SELECT `name`,IFNULL(`uah`,0) AS u FROM `accounts` ORDER BY IFNULL(`uah`,0) DESC LIMIT 50", "OnUahTop", "i", playerid);
	return 1;
}
forward OnUahTop(playerid);
public OnUahTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[90], name[24], u;
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_field_content(i, "name", name, gSQL, sizeof name);
		u = cache_get_field_content_int(i, "u", gSQL);
		if(i == 0) format(line, sizeof line, "{0057B8}1. %s - %d\n", name, u);
		else if(i == 1) format(line, sizeof line, "{C0C0C0}2. %s - %d\n", name, u);
		else if(i == 2) format(line, sizeof line, "{CD7F32}3. %s - %d\n", name, u);
		else format(line, sizeof line, "%d. %s - %d\n", i + 1, name, u);
		if(strlen(body) + strlen(line) >= sizeof body - 2) break;
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	EuroShowPlayerDialog(playerid, D_UAH_TOP, DIALOG_STYLE_LIST, "{0057B8}Топ гривны", body, "OK", "");
	return 1;
}

stock ShowKztTop(playerid)
{
	mysql_tquery(gSQL, "SELECT `name`,IFNULL(`kzt`,0) AS k FROM `accounts` ORDER BY IFNULL(`kzt`,0) DESC LIMIT 50", "OnKztTop", "i", playerid);
	return 1;
}
forward OnKztTop(playerid);
public OnKztTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[90], name[24], k;
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_field_content(i, "name", name, gSQL, sizeof name);
		k = cache_get_field_content_int(i, "k", gSQL);
		if(i == 0) format(line, sizeof line, "{00AFCA}1. %s - %d\n", name, k);
		else if(i == 1) format(line, sizeof line, "{C0C0C0}2. %s - %d\n", name, k);
		else if(i == 2) format(line, sizeof line, "{CD7F32}3. %s - %d\n", name, k);
		else format(line, sizeof line, "%d. %s - %d\n", i + 1, name, k);
		if(strlen(body) + strlen(line) >= sizeof body - 2) break;
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	EuroShowPlayerDialog(playerid, D_KZT_TOP, DIALOG_STYLE_LIST, "{00AFCA}Топ тенге", body, "OK", "");
	return 1;
}

stock ShowUahMenu(playerid)
{
	if(!PlayerLoaded[playerid]) return 1;
	new body[700];
	format(body, sizeof body,
		"Гривна (UAH): %d\nКурс ~%.2f руб\nКомиссия обмена 90%%\nГривна -> евро\nГривна -> бит\nЕвро -> гривна\nБит -> гривна\nБЦ(донат) -> гривна\nПередать гривну (20%%)\nТоп гривны\nКупить админку (%d)\nКупить лидерку семьи (%d)\nНазад",
		PlayerUAH[playerid], gUahRate, UAH_ADMIN_PRICE, UAH_LEADER_PRICE);
	EuroShowPlayerDialog(playerid, D_UAH_MENU, DIALOG_STYLE_LIST, "{0057B8}Гривна", body, "OK", "X");
	return 1;
}

stock ShowKztMenu(playerid)
{
	if(!PlayerLoaded[playerid]) return 1;
	new body[700];
	format(body, sizeof body,
		"Тенге (KZT): %d\nКурс ~%.3f руб\nКомиссия обмена 70%%\nТенге -> евро\nТенге -> бит\nЕвро -> тенге\nБит -> тенге\nПередать тенге (20%%)\nТоп тенге\nНазад",
		PlayerKZT[playerid], gKztRate);
	EuroShowPlayerDialog(playerid, D_KZT_MENU, DIALOG_STYLE_LIST, "{00AFCA}Тенге", body, "OK", "X");
	return 1;
}

// ===================== FUNCOIN =====================
stock FunFeeReceive(amount)
{
	new fee = (amount * FUN_FEE_PCT) / 100;
	if(fee < 1 && amount >= 1) fee = amount; // 99% — почти всё
	new recv = amount - fee;
	if(recv < 1) recv = 0;
	return recv;
}

stock ShowFunMenu(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(!gSQLOk || !PlayerLoaded[playerid])
	{
		LoadEuro(playerid);
		SendClientMessage(playerid, COLOR_ERR, "Загрузка...");
		return 1;
	}
	new body[1400];
	format(body, sizeof body,
		"Баланс FC: %d\n+200 каждый час\nКупить код (\xEE\xF2 500 FC)\nМои коды\nПередать FC (99%%)\nFC в евро (99%%)\nFC в бит (99%%)\nЕвро в FC (99%%)\nБит в FC (99%%)\nМем в FC (99%%)\nГривна в FC (99%%)\nТенге в FC (99%%)\nОплатить имущество (10 FC/день)\nРестарт сервера (500000 FC)\nРежим стримера\nТоп FC\nНазад\n\xC0\xEA\xF2\xE8\xE2\xE8\xF0\xEE\xE2\xE0\xF2\xFC \xF1\xEF\xE5\xF6\xEA\xEE\xE4",
		PlayerFun[playerid]);
	EuroShowPlayerDialog(playerid, D_FUN_MENU, DIALOG_STYLE_LIST, "{7CFC00}Фанкоины", body, "OK", "X");
	return 1;
}

stock FunBuyCodeStart(playerid)
{
	if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "\xcd\xe5 \xe7\xe0\xe3\xf0\xf3\xe6\xe5\xed\xee"), 0;
	if(PlayerFun[playerid] < FUN_CODE_PRICE) return SendClientMessage(playerid, COLOR_ERR, "\xcd\xf3\xe6\xed\xee \xEC\xE8\xED\xE8\xEC\xF3\xEC 500 FC"), 0;
	EuroShowPlayerDialog(playerid, D_FUN_CODE_NICK, DIALOG_STYLE_INPUT, "\xca\xee\xe4 \xe4\xeb\xff \xed\xe8\xea\xe0", "\xcd\xe8\xea \xe8\xe3\xf0\xee\xea\xe0 (\xea\xe0\xea \xe2 \xe8\xe3\xf0\xe5), \xea\xee\xf2\xee\xf0\xee\xec\xf3 \xe4\xe0\xb8\xf8\xfc \xe4\xee\xf1\xf2\xf3\xef:", "\xc4\xe0\xeb\xe5\xe5", "X");
	return 1;
}

stock FunGenCode(dest[])
{
	static const c[] = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
	for(new i; i < 8; i++) dest[i] = c[random(sizeof(c) - 1)];
	dest[8] = 0;
}



forward OnFunCodeShow(playerid, days);
public OnFunCodeShow(playerid, days)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new code[16];
	if(cache_get_row_count(gSQL) < 1) return SendClientMessage(playerid, COLOR_ERR, "Ошибка кода"), 1;
	cache_get_row(0, 0, code, gSQL, sizeof code);
	new str[160];
	format(str, sizeof str, "{7CFC00}Код для {FFFFFF}%s{7CFC00}: {FFFF00}%s{7CFC00} (%d дн.). Передай никy этот код.", FunCodeNick[playerid], code, days);
	SendClientMessage(playerid, -1, str);
	SendClientMessage(playerid, 0xFFD700FF, "Получатель вводит этот код как спецкод при входе (AccessGate).");
	return 1;
}

stock FunCreateCode(playerid, days)
{
	if(!PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
	if(days < 1 || days > 2000) return SendClientMessage(playerid, COLOR_ERR, "\xcd\xe5\xe2\xe5\xf0\xed\xfb\xe9 \xf1\xf0\xee\xea: \xe4\xee 2000 \xe4\xed\xe5\xe9."), 0;
	new cost = ((days + 29) / 30) * FUN_CODE_PRICE;
	if(PlayerFun[playerid] < cost)
	{
		new err[96];
		format(err, sizeof err, "\xcc\xe0\xeb\xee FC. \xcd\xf3\xe6\xed\xee: %d FC.", cost);
		SendClientMessage(playerid, COLOR_ERR, err);
		return 0;
	}
	if(!FunCodeNick[playerid][0]) return SendClientMessage(playerid, COLOR_ERR, "\xcd\xe5\xf2 \xed\xe8\xea\xe0"), 0;

	PlayerFun[playerid] -= cost;
	SaveEuro(playerid);

	new code[16], fromname[MAX_PLAYER_NAME];
	FunGenCode(code);
	GetPlayerName(playerid, fromname, sizeof fromname);

	new q[360];
	mysql_format(gSQL, q, sizeof q,
		"INSERT INTO `fun_codes` (`code`,`from_acc`,`from_name`,`to_name`,`days`,`active`,`used`) VALUES ('%e',%d,'%e','%e',%d,1,0)",
		code, PlayerAccID[playerid], fromname, FunCodeNick[playerid], days);
	mysql_tquery(gSQL, q);

	// Do not overwrite the recipient's existing access_code.
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` SET `access_code`='%e' WHERE `name`='%e' AND (`access_code`='' OR `access_code` IS NULL) AND IFNULL(`access_ok`,0)=0 LIMIT 1",
		code, FunCodeNick[playerid]);
	mysql_tquery(gSQL, q);

	new str[200];
	format(str, sizeof str, "{7CFC00}-%d FC. \xca\xee\xe4 \xe4\xeb\xff %s: {FFFF00}%s{7CFC00} | %d \xe4\xed. \xc8\xe3\xf0\xee\xea \xe2\xe2\xee\xe4\xe8\xf2 \xe5\xe3\xee \xea\xe0\xea \xd1\xcf\xc5\xc6\xca\xce\xc4 (AccessGate).", cost, FunCodeNick[playerid], code, days);
	SendClientMessage(playerid, -1, str);
	printf("[Fun] code %s from %d to %s days=%d cost=%d", code, PlayerAccID[playerid], FunCodeNick[playerid], days, cost);
	return 1;
}

stock FunShowMyCodes(playerid)
{
	if(!PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
	new q[200];
	mysql_format(gSQL, q, sizeof q,
		"SELECT `id`,`code`,`to_name`,`days`,`active`,`used` FROM `fun_codes` WHERE `from_acc`=%d ORDER BY `id` DESC LIMIT 12",
		PlayerAccID[playerid]);
	mysql_tquery(gSQL, q, "OnFunList", "i", playerid);
	return 1;
}

forward OnFunList(playerid);
public OnFunList(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL);
	if(rows < 1) return SendClientMessage(playerid, COLOR_ERR, "Нет выданных кодов"), 1;
	new body[1400], line[96], code[16], ton[24];
	body[0] = 0;
	FunListCount[playerid] = 0;
	for(new i; i < rows && i < 12; i++)
	{
		new id = cache_get_row_int(i, 0, gSQL);
		cache_get_row(i, 1, code, gSQL, sizeof code);
		cache_get_row(i, 2, ton, gSQL, sizeof ton);
		new days = cache_get_row_int(i, 3, gSQL);
		new act = cache_get_row_int(i, 4, gSQL);
		new used = cache_get_row_int(i, 5, gSQL);
		FunListIds[playerid][FunListCount[playerid]++] = id;
		format(line, sizeof line, "%s -> %s | %dд | %s%s\n",
			code, ton, days,
			act ? "" : "[ОТОЗВАН] ",
			used ? "использован" : "ждёт");
		strcat(body, line);
	}
	strcat(body, "Назад");
	EuroShowPlayerDialog(playerid, D_FUN_CODE_LIST, DIALOG_STYLE_LIST, "Мои коды (выбери = отозвать)", body, "Отозвать", "X");
	return 1;
}

stock FunRevokeCode(playerid, listitem)
{
	if(listitem < 0 || listitem >= FunListCount[playerid]) return ShowFunMenu(playerid);
	new id = FunListIds[playerid][listitem];
	new q[280];
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `fun_codes` SET `active`=0 WHERE `id`=%d AND `from_acc`=%d LIMIT 1",
		id, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	// снять доступ у получателя если код был активен
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` a INNER JOIN `fun_codes` f ON a.`name`=f.`to_name` SET a.`access_ok`=0 WHERE f.`id`=%d AND f.`from_acc`=%d",
		id, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SendClientMessage(playerid, 0xFF4444FF, "Код отозван. Он больше не действует.");
	ShowFunMenu(playerid);
	return 1;
}

stock FunActivateCode(playerid, code[])
{
	if(!PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
	new q[200];
	mysql_format(gSQL, q, sizeof q,
		"SELECT `id`,`to_name`,`days`,`active`,`used` FROM `fun_codes` WHERE `code`='%e' LIMIT 1", code);
	mysql_tquery(gSQL, q, "OnFunActivate", "is", playerid, code);
	return 1;
}

forward OnFunActivate(playerid, code[]);
public OnFunActivate(playerid, code[])
{
	if(!IsPlayerConnected(playerid) || !PlayerLoaded[playerid]) return 1;
	if(cache_get_row_count(gSQL) < 1) return SendClientMessage(playerid, COLOR_ERR, "Код не найден"), 1;
	new id = cache_get_row_int(0, 0, gSQL);
	new ton[24];
	cache_get_row(0, 1, ton, gSQL, sizeof ton);
	new days = cache_get_row_int(0, 2, gSQL);
	new act = cache_get_row_int(0, 3, gSQL);
	new used = cache_get_row_int(0, 4, gSQL);
	if(!act) return SendClientMessage(playerid, COLOR_ERR, "Код отозван отправителем"), 1;
	if(used) return SendClientMessage(playerid, COLOR_ERR, "Код уже использован"), 1;

	new myname[MAX_PLAYER_NAME];
	GetPlayerName(playerid, myname, sizeof myname);
	if(strcmp(myname, ton, true) != 0)
		return SendClientMessage(playerid, COLOR_ERR, "Этот код выписан на другой ник"), 1;

	// дата до
	new y, m, d, ey, em, ed;
	getdate(y, m, d);
	if(days == 0) { ey = 9999; em = 12; ed = 31; }
	else { ey = y; em = m; ed = d; }
	// reuse AccessGate-style add days inline
	new left = (days == 0) ? 0 : days;
	while(left > 0)
	{
		new dim, leap;
		static const dima[] = {0,31,28,31,30,31,30,31,31,30,31,30,31};
		leap = ((ey % 4 == 0 && ey % 100 != 0) || (ey % 400 == 0));
		dim = (em == 2) ? (leap ? 29 : 28) : dima[em];
		new room = dim - ed;
		if(left <= room) { ed += left; left = 0; }
		else { left -= (room + 1); ed = 1; em++; if(em > 12) { em = 1; ey++; } }
	}

	new q[320];
	mysql_format(gSQL, q, sizeof q, "UPDATE `fun_codes` SET `used`=1, `to_acc`=%d WHERE `id`=%d LIMIT 1", PlayerAccID[playerid], id);
	mysql_tquery(gSQL, q);
	mysql_format(gSQL, q, sizeof q,
		"UPDATE `accounts` SET `access_ok`=1, `access_code`='%e', `access_until_y`=%d, `access_until_m`=%d, `access_until_d`=%d WHERE `id`=%d LIMIT 1",
		code, ey, em, ed, PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);

	new str[96];
	if(days == 0) format(str, sizeof str, "{7CFC00}\xCA\xEE\xE4 \xEF\xF0\xE8\xED\xFF\xF2! \xC4\xEE\xF1\xF2\xF3\xEF \xED\xE0\xE2\xF1\xE5\xE3\xE4\xE0.");
	else format(str, sizeof str, "{7CFC00}\xCA\xEE\xE4 \xEF\xF0\xE8\xED\xFF\xF2! Access \xE4\xEE %02d.%02d.%04d (%d \xE4\xED.)", ed, em, ey, days);
	SendClientMessage(playerid, -1, str);
	SendClientMessage(playerid, 0xFFD700FF, "Перезайди или подожди — AccessGate подхватит доступ.");
	return 1;
}

stock FunToEuro(playerid, amount)
{
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerFun[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало FC"), 0;
	new recv = FunFeeReceive(amount);
	if(recv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 99% ничего не остаётся (нужна большая сумма)"), 0;
	// грубо: 1 FC ~ как мелкий бонус в евро
	new euro = recv; // 1:1 после комиссии
	PlayerFun[playerid] -= amount;
	PlayerEuro[playerid] += euro;
	SaveEuro(playerid);
	new str[96];
	format(str, sizeof str, "FC->евро: -%d FC = +%d евро (комиссия 99%%)", amount, euro);
	SendClientMessage(playerid, 0x7CFC00FF, str);
	return 1;
}

stock FunToBit(playerid, amount)
{
	if(!PlayerLoaded[playerid] || amount <= 0 || PlayerFun[playerid] < amount) return SendClientMessage(playerid, COLOR_ERR, "Мало FC"), 0;
	new recv = FunFeeReceive(amount);
	if(recv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 99% пусто"), 0;
	PlayerFun[playerid] -= amount;
	PlayerBit[playerid] += recv;
	SaveEuro(playerid);
	new str[96];
	format(str, sizeof str, "FC->бит: -%d FC = +%d бит (комиссия 99%%)", amount, recv);
	SendClientMessage(playerid, 0x7CFC00FF, str);
	return 1;
}

stock CurrencyToFun(playerid, amount, ctype)
{
	// ctype: 1 euro 2 bit 3 meme 4 uah 5 kzt  | комиссия 99%
	if(!PlayerLoaded[playerid] || amount <= 0) return SendClientMessage(playerid, COLOR_ERR, "Неверная сумма"), 0;
	new bal;
	if(ctype == 1) bal = PlayerEuro[playerid];
	else if(ctype == 2) bal = PlayerBit[playerid];
	else if(ctype == 3) bal = PlayerMeme[playerid];
	else if(ctype == 4) bal = PlayerUAH[playerid];
	else if(ctype == 5) bal = PlayerKZT[playerid];
	else return 0;
	if(bal < amount) return SendClientMessage(playerid, COLOR_ERR, "Недостаточно средств"), 0;
	new recv = FunFeeReceive(amount);
	if(recv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 99% комиссии FC = 0 (нужна большая сумма)"), 0;
	if(ctype == 1) PlayerEuro[playerid] -= amount;
	else if(ctype == 2) PlayerBit[playerid] -= amount;
	else if(ctype == 3) PlayerMeme[playerid] -= amount;
	else if(ctype == 4) PlayerUAH[playerid] -= amount;
	else if(ctype == 5) PlayerKZT[playerid] -= amount;
	PlayerFun[playerid] += recv;
	SaveEuro(playerid);
	new str[120], cname[16];
	if(ctype == 1) format(cname, sizeof cname, "евро");
	else if(ctype == 2) format(cname, sizeof cname, "бит");
	else if(ctype == 3) format(cname, sizeof cname, "мем");
	else if(ctype == 4) format(cname, sizeof cname, "гривен");
	else format(cname, sizeof cname, "тенге");
	format(str, sizeof str, "{7CFC00}-%d %s = +%d FC (комиссия 99%%). FC: %d", amount, cname, recv, PlayerFun[playerid]);
	SendClientMessage(playerid, -1, str);
	return 1;
}



stock KztFromEuro(playerid, euro_amount)
{
	if(euro_amount <= 0 || PlayerEuro[playerid] < euro_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало евро"), 0;
	new getv = euro_amount - (euro_amount * KZT_FEE_PCT) / 100;
	if(getv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 70% ничего"), 0;
	PlayerEuro[playerid] -= euro_amount;
	PlayerKZT[playerid] += getv;
	SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Евро->тенге: -%d = +%d (комиссия 70%%)", euro_amount, getv);
	SendClientMessage(playerid, 0x00AFCAFF, str);
	return 1;
}

stock KztFromBit(playerid, bit_amount)
{
	if(bit_amount <= 0 || PlayerBit[playerid] < bit_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало битка"), 0;
	new getv = bit_amount - (bit_amount * KZT_FEE_PCT) / 100;
	if(getv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 70% ничего"), 0;
	PlayerBit[playerid] -= bit_amount;
	PlayerKZT[playerid] += getv;
	SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Бит->тенге: -%d = +%d (комиссия 70%%)", bit_amount, getv);
	SendClientMessage(playerid, 0x00AFCAFF, str);
	return 1;
}

stock KztToEuro(playerid, kzt_amount)
{
	if(kzt_amount <= 0 || PlayerKZT[playerid] < kzt_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало тенге"), 0;
	new getv = kzt_amount - (kzt_amount * KZT_FEE_PCT) / 100;
	if(getv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 70% ничего"), 0;
	PlayerKZT[playerid] -= kzt_amount;
	PlayerEuro[playerid] += getv;
	SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Тенге->евро: -%d = +%d (комиссия 70%%)", kzt_amount, getv);
	SendClientMessage(playerid, 0x00AFCAFF, str);
	return 1;
}

stock KztToBit(playerid, kzt_amount)
{
	if(kzt_amount <= 0 || PlayerKZT[playerid] < kzt_amount) return SendClientMessage(playerid, COLOR_ERR, "Мало тенге"), 0;
	new getv = kzt_amount - (kzt_amount * KZT_FEE_PCT) / 100;
	if(getv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 70% ничего"), 0;
	PlayerKZT[playerid] -= kzt_amount;
	PlayerBit[playerid] += getv;
	SaveEuro(playerid);
	new str[100]; format(str, sizeof str, "Тенге->бит: -%d = +%d (комиссия 70%%)", kzt_amount, getv);
	SendClientMessage(playerid, 0x00AFCAFF, str);
	return 1;
}

stock UahBuyAdmin(playerid)
{
	if(PlayerUAH[playerid] < UAH_ADMIN_PRICE)
		return SendClientMessage(playerid, COLOR_ERR, "Нужно 200000 гривен"), 0;
	PlayerUAH[playerid] -= UAH_ADMIN_PRICE;
	SaveEuro(playerid);
	new q[160];
	mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `admin`=1 WHERE `id`=%d LIMIT 1", PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SendClientMessage(playerid, 0x0057B8FF, "Куплена админка (admin=1). Релог!");
	return 1;
}

stock UahBuyLeader(playerid)
{
	if(PlayerUAH[playerid] < UAH_LEADER_PRICE)
		return SendClientMessage(playerid, COLOR_ERR, "Нужно 200000 гривен"), 0;
	PlayerUAH[playerid] -= UAH_LEADER_PRICE;
	SaveEuro(playerid);
	new q[180];
	mysql_format(gSQL, q, sizeof q, "UPDATE `accounts` SET `family_rang`=5 WHERE `id`=%d AND `family_id`>0 LIMIT 1", PlayerAccID[playerid]);
	mysql_tquery(gSQL, q);
	SendClientMessage(playerid, 0x0057B8FF, "Лидерка семьи (rang 5), если ты уже в семье. Релог!");
	return 1;
}


stock ShowMenu(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(!gSQLOk) return SendClientMessage(playerid, COLOR_ERR, "БД offline"), 1;
	if(!PlayerLoaded[playerid])
	{
		LoadEuro(playerid);
		SendClientMessage(playerid, COLOR_ERR, "Загрузка... напиши .euro ещё раз через 2 сек");
		return 1;
	}
	// анти-спам .euro (двойной вызов иногда роняет диалоги)
	new now = GetTickCount();
	if(EuroMenuTick[playerid] && now - EuroMenuTick[playerid] < 400) return 1;
	EuroMenuTick[playerid] = now;
	UpdateRate();
	MemeFixName();
	new body[1400];
	format(body, sizeof body,
		"Евро: %d | Бит: %d | %s: %d\nГривна: %d | Тенге: %d | FC: %d\nКурс евро %.2f | BTC %.0f\nЕвро -> нал\nЕвро -> банк\nНал -> евро\nБанк -> евро\nЕвро -> бит (20%%)\nПередать евро\nСкин\nАкс\nМашина\nТюнинг (10000, в авто)\nСемья\nТоп евро\nМеню битка\nМеню мемкоина\nГривна\nТенге\nФанкоины\nОбновить",
		PlayerEuro[playerid], PlayerBit[playerid], gMemeName, PlayerMeme[playerid],
		PlayerUAH[playerid], PlayerKZT[playerid], PlayerFun[playerid], gEuroRate, gBitRate);
	EuroShowPlayerDialog(playerid, D_EURO_MENU, DIALOG_STYLE_LIST, "{FFD700}Евро", body, "OK", "X");
	return 1;
}

stock ShowBitMenu(playerid)
{
	if(!gSQLOk || !PlayerLoaded[playerid]) { LoadEuro(playerid); return SendClientMessage(playerid, COLOR_ERR, "Загрузка..."), 1; }
	new body[600];
	format(body, sizeof body,
		"Биток: %d\nКурс BTC %.0f\nБит -> нал (5%%)\nБит -> банк (5%%)\nБит -> евро (5%%)\nПередать бит (20%%)\nТоп битка\nEuro\nMeme\nRefresh",
		PlayerBit[playerid], gBitRate);
	EuroShowPlayerDialog(playerid, D_BIT_MENU, DIALOG_STYLE_LIST, "{00BFFF}Биток", body, "OK", "X");
	return 1;
}

stock ShowMemeMenu(playerid)
{
	if(!gSQLOk || !PlayerLoaded[playerid]) { LoadEuro(playerid); return SendClientMessage(playerid, COLOR_ERR, "Загрузка..."), 1; }
	MemeFixName();
	new body[800], status[16];
	if(MemeSeasonActive()) format(status, sizeof status, "активен");
	else format(status, sizeof status, "ОКОНЧЕН");
	format(body, sizeof body,
		"%s: %d (%s)\nДо %02d.%02d.%04d %02d:%02d | курс %.1f\nМем -> нал\nМем -> банк\nМем -> евро\nМем -> бит\nЕвро -> мем\nБит -> мем\nДонат(БЦ) -> мем\nМем -> донат(БЦ)\nПередать мем (50%%)\nПолёт (10 мем)\nРандом скин/тачка/акс (%d)\nТоп мемкоина\nГривна\nТенге\nЕвро | Биток\nОбновить",
		gMemeName, PlayerMeme[playerid], status,
		gMemeEndD, gMemeEndMo, gMemeEndY, gMemeEndH, gMemeEndMi, gMemeRate,
		MemeRandPrice(playerid));
	new mt[48];
	format(mt, sizeof mt, "{FF69B4}%s", gMemeName);
	EuroShowPlayerDialog(playerid, D_MEME_MENU, DIALOG_STYLE_LIST, mt, body, "OK", "X");
	return 1;
}





stock Cmd(playerid, cmd[])
{
	if(!strcmp(cmd, "euro", true) || !strcmp(cmd, "eurobal", true)) return ShowMenu(playerid);
	if(!strcmp(cmd, "bit", true) || !strcmp(cmd, "bitok", true)) return ShowBitMenu(playerid);
	if(!strcmp(cmd, "meme", true) || !strcmp(cmd, "memecoin", true) || !strcmp(cmd, "mm", true)) return ShowMemeMenu(playerid);
	if(!strcmp(cmd, "uah", true) || !strcmp(cmd, "grivna", true)) return ShowUahMenu(playerid);
	if(!strcmp(cmd, "kzt", true) || !strcmp(cmd, "tenge", true)) return ShowKztMenu(playerid);
	if(!strcmp(cmd, "fun", true) || !strcmp(cmd, "funcoin", true) || !strcmp(cmd, "fc", true)) return ShowFunMenu(playerid);
	if(!strcmp(cmd, "fullcontrol", true) || !strcmp(cmd, "fccontrol", true)) return FunControlReopen(playerid);
	if(!strcmp(cmd, "streamer", true) || !strcmp(cmd, "streammode", true)) return FunStreamMenu(playerid);
	if(!strcmp(cmd, "eurotop", true)) return ShowTop(playerid);
	if(!strcmp(cmd, "bittop", true)) return ShowBitTop(playerid);
	if(!strcmp(cmd, "memetop", true)) return ShowMemeTop(playerid);
	if(!strcmp(cmd, "euroex", true))
	{
		EuroShowPlayerDialog(playerid, D_EURO_EX, DIALOG_STYLE_LIST, "{FFD700}Обмен", "Евро->нал\nЕвро->банк\nНал->евро\nБанк->евро\nЕвро->бит", "OK", "X");
		return 1;
	}
	if(!strcmp(cmd, "bitex", true))
	{
		EuroShowPlayerDialog(playerid, D_BIT_EX, DIALOG_STYLE_LIST, "{00BFFF}Обмен", "Бит->нал\nБит->банк\nБит->евро", "OK", "X");
		return 1;
	}
	if(!strcmp(cmd, "euroskin", true)) { EuroShowPlayerDialog(playerid, D_EURO_SKIN, DIALOG_STYLE_INPUT, "Скин", "ID:", "OK", "X"); return 1; }
	if(!strcmp(cmd, "euroacs", true)) { EuroShowPlayerDialog(playerid, D_EURO_ACS, DIALOG_STYLE_INPUT, "Акс", "ID:", "OK", "X"); return 1; }
	if(!strcmp(cmd, "eurocar", true)) { EuroShowPlayerDialog(playerid, D_EURO_CAR, DIALOG_STYLE_INPUT, "Машина", "ID:", "OK", "X"); return 1; }
	if(!strcmp(cmd, "eurofamily", true)) return StartFamilyBuy(playerid);
	return 0;
}



stock FunPropOpen(playerid)
{
	if(!PlayerLoaded[playerid] || PlayerAccID[playerid] < 1)
		return SendClientMessage(playerid, COLOR_ERR, "Баланс не загружен"), 0;
	EuroShowPlayerDialog(playerid, D_FUN_PROP_TYPE, DIALOG_STYLE_LIST, "Имущество FC",
		"Дом (houses)\nБизнес\nАЗС\nГараж\nОтель\nКупленный дом\nBR гараж\nВвести ID вручную\nНазад",
		"OK", "X");
	return 1;
}

stock FunPropLoad(playerid, ptype)
{
	if(!gSQLOk || !PlayerLoaded[playerid]) return 0;
	FunPropType[playerid] = ptype;
	FunPropCount[playerid] = 0;
	new q[420], acc = PlayerAccID[playerid], nick[MAX_PLAYER_NAME];
	GetPlayerName(playerid, nick, sizeof nick);

	// основной поиск: JOIN по нику (надёжнее, чем только owner_id)
	if(ptype == 0)
		mysql_format(gSQL, q, sizeof q,
			"SELECT h.`id`, h.`name`, h.`rent_time` FROM `houses` h INNER JOIN `accounts` a ON a.`id`=h.`owner_id` WHERE a.`name`='%e' OR h.`owner_id`=%d LIMIT 20",
			nick, acc);
	else if(ptype == 1)
		mysql_format(gSQL, q, sizeof q,
			"SELECT b.`id`, b.`name`, b.`rent_time` FROM `business` b INNER JOIN `accounts` a ON a.`id`=b.`owner_id` WHERE a.`name`='%e' OR b.`owner_id`=%d LIMIT 20",
			nick, acc);
	else if(ptype == 2)
		mysql_format(gSQL, q, sizeof q,
			"SELECT f.`id`, f.`name`, f.`rent_time` FROM `fuel_stations` f INNER JOIN `accounts` a ON a.`id`=f.`owner_id` WHERE a.`name`='%e' OR f.`owner_id`=%d LIMIT 20",
			nick, acc);
	else if(ptype == 3)
		mysql_format(gSQL, q, sizeof q,
			"SELECT g.`id`, 'garage', g.`rent_time` FROM `garages` g INNER JOIN `accounts` a ON a.`id`=g.`owner_id` WHERE a.`name`='%e' OR g.`owner_id`=%d LIMIT 20",
			nick, acc);
	else if(ptype == 4)
		mysql_format(gSQL, q, sizeof q,
			"SELECT h.`id`, 'hotel', h.`rent_time` FROM `hotels` h INNER JOIN `accounts` a ON a.`id`=h.`owner_id` WHERE a.`name`='%e' OR h.`owner_id`=%d LIMIT 20",
			nick, acc);
	else if(ptype == 5)
		mysql_format(gSQL, q, sizeof q,
			"SELECT `house_id`, IFNULL(`owner_name`,''), `rent_time` FROM `bought_houses` WHERE `account_id`=%d OR `owner_name`='%e' LIMIT 20",
			acc, nick);
	else if(ptype == 6)
		mysql_format(gSQL, q, sizeof q,
			"SELECT `id`, IFNULL(`owner_name`,''), `rent_time` FROM `br_garages` WHERE `owner_id`=%d OR `owner_name`='%e' LIMIT 20",
			acc, nick);
	else return 0;

	printf("[Fun] PROP list type=%d acc=%d nick=%s", ptype, acc, nick);
	mysql_tquery(gSQL, q, "OnFunPropList", "i", playerid);
	return 1;
}

forward OnFunPropList(playerid);
public OnFunPropList(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL);
	if(rows < 1)
	{
		SendClientMessage(playerid, COLOR_ERR, "Список пуст. Попробуй: Имущество -> Ввести ID вручную (ID смотри в /business или маркере).");
		printf("[Fun] PROP empty acc=%d type=%d", PlayerAccID[playerid], FunPropType[playerid]);
		return FunPropOpen(playerid);
	}
	new body[1400], line[96], nm[32];
	body[0] = 0;
	FunPropCount[playerid] = 0;
	new nowt = gettime();
	for(new i; i < rows && i < 20; i++)
	{
		new id = cache_get_row_int(i, 0, gSQL);
		cache_get_row(i, 1, nm, gSQL, sizeof nm);
		new rt = cache_get_row_int(i, 2, gSQL);
		FunPropIds[playerid][FunPropCount[playerid]++] = id;
		new left = 0;
		if(rt > nowt) left = (rt - nowt) / 86400;
		format(line, sizeof line, "ID %d %s | ~%d дн.\n", id, nm, left);
		strcat(body, line);
	}
	strcat(body, "Назад");
	EuroShowPlayerDialog(playerid, D_FUN_PROP_LIST, DIALOG_STYLE_LIST, "Ваш объект", body, "OK", "X");
	return 1;
}

stock FunPropAskDays(playerid, listitem)
{
	if(listitem < 0 || listitem >= FunPropCount[playerid]) return FunPropOpen(playerid);
	FunPropSel[playerid] = FunPropIds[playerid][listitem];
	EuroShowPlayerDialog(playerid, D_FUN_PROP_DAYS, DIALOG_STYLE_LIST, "Срок оплаты",
		"30 дней (300 FC)\n90 дней (900 FC)\n1 год (3650 FC)\n2 года (7300 FC)\n3 года (10950 FC)\n5 лет (18250 FC)\nНазад",
		"OK", "X");
	return 1;
}

stock FunPropPay(playerid, days)
{
	if(!PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
	if(days != 30 && days != 90 && days != 365 && days != 730 && days != 1095 && days != 1825)
		return 0;
	new cost = days * FUN_RENT_PER_DAY;
	if(PlayerFun[playerid] < cost)
	{
		new str[96];
		format(str, sizeof str, "Нужно %d FC (есть %d).", cost, PlayerFun[playerid]);
		return SendClientMessage(playerid, COLOR_ERR, str), 0;
	}
	new pid = FunPropSel[playerid];
	new ptype = FunPropType[playerid];
	new acc = PlayerAccID[playerid];
	new nowt = gettime();
	new q[400];
	if(ptype == 0)
		mysql_format(gSQL, q, sizeof q,
			"UPDATE `houses` SET `rent_time`=IF(`rent_time`>%d,`rent_time`,%d)+%d WHERE `id`=%d AND `owner_id`=%d LIMIT 1",
			nowt, nowt, days * 86400, pid, acc);
	else if(ptype == 1)
		mysql_format(gSQL, q, sizeof q,
			"UPDATE `business` SET `rent_time`=IF(`rent_time`>%d,`rent_time`,%d)+%d WHERE `id`=%d AND `owner_id`=%d LIMIT 1",
			nowt, nowt, days * 86400, pid, acc);
	else if(ptype == 2)
		mysql_format(gSQL, q, sizeof q,
			"UPDATE `fuel_stations` SET `rent_time`=IF(`rent_time`>%d,`rent_time`,%d)+%d WHERE `id`=%d AND `owner_id`=%d LIMIT 1",
			nowt, nowt, days * 86400, pid, acc);
	else if(ptype == 3)
		mysql_format(gSQL, q, sizeof q,
			"UPDATE `garages` SET `rent_time`=IF(`rent_time`>%d,`rent_time`,%d)+%d WHERE `id`=%d AND `owner_id`=%d LIMIT 1",
			nowt, nowt, days * 86400, pid, acc);
	else if(ptype == 4)
		mysql_format(gSQL, q, sizeof q,
			"UPDATE `hotels` SET `rent_time`=IF(`rent_time`>%d,`rent_time`,%d)+%d WHERE `id`=%d AND `owner_id`=%d LIMIT 1",
			nowt, nowt, days * 86400, pid, acc);
	else if(ptype == 5)
		mysql_format(gSQL, q, sizeof q,
			"UPDATE `bought_houses` SET `rent_time`=IF(`rent_time`>%d,`rent_time`,%d)+%d WHERE `house_id`=%d AND `account_id`=%d LIMIT 1",
			nowt, nowt, days * 86400, pid, acc);
	else if(ptype == 6)
		mysql_format(gSQL, q, sizeof q,
			"UPDATE `br_garages` SET `rent_time`=IF(`rent_time`>%d,`rent_time`,%d)+%d WHERE `id`=%d AND `owner_id`=%d LIMIT 1",
			nowt, nowt, days * 86400, pid, acc);
	else return 0;

	PlayerFun[playerid] -= cost;
	SaveEuro(playerid);
	mysql_tquery(gSQL, q);

	new str[140];
	format(str, sizeof str, "{7CFC00}Оплата: +%d дн., -%d FC. ID %d. Если в игре срок не обновился — рестарт/релог или ждать тик GM.", days, cost, pid);
	SendClientMessage(playerid, -1, str);
	printf("[Fun] PROP pay acc=%d type=%d id=%d days=%d cost=%d", acc, ptype, pid, days, cost);
	return 1;
}



stock FunRestartMenu(playerid)
{
	if(!PlayerLoaded[playerid]) return 0;
	if(gRestartActive)
	{
		new str[128];
		format(str, sizeof str, "Рестарт уже идёт: ~%d мин. Заказал: %s", (gRestartLeft + 59) / 60, gRestartBy);
		return SendClientMessage(playerid, COLOR_ERR, str), 1;
	}
	EuroShowPlayerDialog(playerid, D_FUN_RESTART_MIN, DIALOG_STYLE_LIST, "Рестарт сервера",
		"Через 15 минут (500000 FC)\nЧерез 30 минут (500000 FC)\nОтмена",
		"OK", "X");
	return 1;
}

stock FunRestartBuy(playerid, minutes)
{
	if(!PlayerLoaded[playerid] || PlayerAccID[playerid] < 1) return 0;
	if(gRestartActive) return SendClientMessage(playerid, COLOR_ERR, "Рестарт уже запланирован"), 0;
	if(minutes != 15 && minutes != 30) return 0;
	if(PlayerFun[playerid] < FUN_RESTART_PRICE)
		return SendClientMessage(playerid, COLOR_ERR, "Нужно 500000 FC"), 0;

	PlayerFun[playerid] -= FUN_RESTART_PRICE;
	SaveEuro(playerid);

	gRestartActive = true;
	gRestartLeft = minutes * 60;
	gRestartByAcc = PlayerAccID[playerid];
	GetPlayerName(playerid, gRestartBy, sizeof gRestartBy);

	if(gRestartTimer) KillTimer(gRestartTimer);
	gRestartTimer = SetTimer("FunRestartTick", 60000, true);

	new str[180];
	format(str, sizeof str, "{FF4500}[RESTART] {FFFFFF}%s {FF4500}оплатил рестарт за FC. Через {FFFFFF}%d {FF4500}мин. сервер перезапустится!", gRestartBy, minutes);
	SendClientMessageToAll(-1, str);
	printf("[Fun] RESTART by %s acc=%d in %d min", gRestartBy, gRestartByAcc, minutes);
	return 1;
}

forward FunRestartTick();
public FunRestartTick()
{
	if(!gRestartActive) return 1;
	gRestartLeft -= 60;
	if(gRestartLeft < 0) gRestartLeft = 0;

	new mins = (gRestartLeft + 59) / 60;
	new str[180];
	if(gRestartLeft <= 0)
	{
		format(str, sizeof str, "{FF0000}[RESTART] Рестарт СЕЙЧАС! Заказал: %s", gRestartBy);
		SendClientMessageToAll(-1, str);
		if(gRestartTimer) { KillTimer(gRestartTimer); gRestartTimer = 0; }
		gRestartActive = false;
		if(gSQLOk && gRestartByAcc > 0)
		{
			new q[180];
			mysql_format(gSQL, q, sizeof q,
				"UPDATE `accounts` SET `fun_restart_cd`=%d, `fun_play_after_rst`=0 WHERE `id`=%d LIMIT 1",
				gettime() + 3600, gRestartByAcc);
			mysql_tquery(gSQL, q);
		}
		SetTimer("FunDoRestart", 3000, false);
		return 1;
	}
	format(str, sizeof str, "{FF4500}[RESTART] Через {FFFFFF}%d {FF4500}мин. рестарт (заказал {FFFFFF}%s{FF4500}).", mins, gRestartBy);
	SendClientMessageToAll(-1, str);
	return 1;
}

forward FunDoRestart();
public FunDoRestart()
{
	print("[Fun] RESTART SendRconCommand gmx");
	SendRconCommand("gmx");
	return 1;
}

stock FunRestartOnConnect(playerid)
{
	if(!gRestartActive) return 0;
	new str[140];
	format(str, sizeof str, "{FF4500}[RESTART] Через ~%d мин. рестарт (заказал %s).", (gRestartLeft + 59) / 60, gRestartBy);
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock FunStreamMenu(playerid)
{
	if(!PlayerLoaded[playerid]) return 0;
	new body[400];
	format(body, sizeof body,
		"Статус: %s\nВключить режим стримера (бесплатно)\nВыключить режим\nПриколоться над стримером\nНазад",
		StreamerMode[playerid] ? "ВКЛ" : "ВЫКЛ");
	EuroShowPlayerDialog(playerid, D_FUN_STREAM_MENU, DIALOG_STYLE_LIST, "Режим стримера", body, "OK", "X");
	return 1;
}

stock FunStreamEnable(playerid)
{
	if(StreamerMode[playerid]) return SendClientMessage(playerid, 0x7CFC00FF, "Режим стримера уже включён"), 1;
	StreamerMode[playerid] = true;
	SendClientMessage(playerid, 0x7CFC00FF, "Режим стримера включён бесплатно.");
	new n[24], str[100];
	GetPlayerName(playerid, n, sizeof n);
	format(str, sizeof str, "{7CFC00}[STREAM] {FFFFFF}%s {7CFC00}включил режим стримера!", n);
	SendClientMessageToAll(-1, str);
	return 1;
}

stock FunStreamDisable(playerid)
{
    // End sessions immediately when streamer mode is switched off.
    new controller = ControlledBy[playerid];
    if(controller >= 0 && controller < MAX_PLAYERS)
    {
        if(IsPlayerConnected(controller))
        {
            ControlTarget[controller] = INVALID_PLAYER_ID;
            ControlUntil[controller] = 0;
            SendClientMessage(controller, COLOR_ERR, "Streamer mode is off; Full Control ended.");
        }
        ControlledBy[playerid] = INVALID_PLAYER_ID;
    }
    new target = ControlTarget[playerid];
    if(target >= 0 && target < MAX_PLAYERS)
    {
        if(ControlledBy[target] == playerid) ControlledBy[target] = INVALID_PLAYER_ID;
        if(IsPlayerConnected(target)) SendClientMessage(target, COLOR_ERR, "Streamer mode is off; Full Control ended.");
    }
    ControlTarget[playerid] = INVALID_PLAYER_ID;
    ControlUntil[playerid] = 0;
    StreamerMode[playerid] = false;
    SendClientMessage(playerid, COLOR_ERR, "Streamer mode is off.");
    return 1;
}

stock FunTrollPick(playerid)
{
	EuroShowPlayerDialog(playerid, D_FUN_STREAM_ID, DIALOG_STYLE_INPUT, "ID стримера",
		"ID игрока с ВКЛ режимом стримера:", "OK", "X");
	return 1;
}

stock FunTrollMenu(playerid, tid)
{
	if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid))
		return SendClientMessage(playerid, COLOR_ERR, "Игрок офф"), 0;
	if(!StreamerMode[tid])
		return SendClientMessage(playerid, COLOR_ERR, "У него выключен режим стримера"), 0;
	StreamTarget[playerid] = tid;
	EuroShowPlayerDialog(playerid, D_FUN_STREAM_ACT, DIALOG_STYLE_LIST, "Тролл-меню",
		"Чат от его имени (бесплатно)\nСообщение на экран (бесплатно)\nПодбросить (бесплатно)\nЗаморозить 3 сек (бесплатно)\nФУЛЛ-КОНТРОЛЬ 60 сек (бесплатно)\nНазад",
		"OK", "X");
	return 1;
}

stock FunCompensateStreamer(streamerid, amount)
{
	#pragma unused streamerid, amount
	// Режим стримера бесплатный: валюту не списываем и не начисляем.
	return 1;
}

stock FunTrollChat(playerid, text[])
{
	new tid = StreamTarget[playerid];
	if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid || !StreamerMode[tid])
		return SendClientMessage(playerid, COLOR_ERR, "Стример недоступен"), 0;
	new n[24], str[144], bubble[96];
	GetPlayerName(tid, n, sizeof n);
	format(str, sizeof str, "%s: %s", n, text);
	format(bubble, sizeof bubble, "%s", text);
	if(strlen(bubble) > 64) bubble[64] = 0;
	// локально ~10м + над головой
	new Float:x, Float:y, Float:z;
	GetPlayerPos(tid, x, y, z);
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		if(IsPlayerInRangeOfPoint(i, 10.0, x, y, z))
			SendClientMessage(i, 0xFFFFFFFF, str);
	}
	new Text3D:lab = Create3DTextLabel(bubble, 0xFFFFFFFF, x, y, z + 1.0, 15.0, GetPlayerVirtualWorld(tid), 0);
	Attach3DTextLabelToPlayer(lab, tid, 0.0, 0.0, 0.35);
	SetTimerEx("FunDestroyLabel", 4000, false, "i", _:lab);
	SendClientMessage(playerid, 0x7CFC00FF, "Локальный чат + текст над головой (10м), бесплатно.");
	return 1;
}

forward FunDestroyLabel(labelid);
public FunDestroyLabel(labelid)
{
	Delete3DTextLabel(Text3D:labelid);
	return 1;
}

stock FunTrollMsg(playerid, text[])
{
	new tid = StreamTarget[playerid];
	if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !StreamerMode[tid])
		return SendClientMessage(playerid, COLOR_ERR, "Стример недоступен"), 0;
	new str[144];
	format(str, sizeof str, "{FF69B4}[STREAM] {FFFFFF}%s", text);
	SendClientMessage(tid, -1, str);
	GameTextForPlayer(tid, text, 4000, 3);
	SendClientMessage(playerid, 0x7CFC00FF, "Сообщение показано стримеру бесплатно.");
	return 1;
}

stock FunTrollSlap(playerid)
{
	new tid = StreamTarget[playerid];
	if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !StreamerMode[tid])
		return SendClientMessage(playerid, COLOR_ERR, "Стример недоступен"), 0;
	ClearAnimations(tid);
	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(tid, x, y, z);
	GetPlayerFacingAngle(tid, a);
	SetPlayerVelocity(tid, floatsin(-a, degrees) * 0.4, floatcos(-a, degrees) * 0.4, 0.55);
	ApplyAnimation(tid, "PED", "FALL_spin", 4.1, 0, 1, 1, 0, 0, 1);
	PlayerPlaySound(tid, 1130, 0.0, 0.0, 0.0);
	SendClientMessage(tid, 0xFF69B4FF, "[STREAM] Slap!");
	SendClientMessage(playerid, 0x7CFC00FF, "Slap бесплатно.");
	return 1;
}

stock FunTrollFreeze(playerid)
{
	new tid = StreamTarget[playerid];
	if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !StreamerMode[tid])
		return SendClientMessage(playerid, COLOR_ERR, "Стример недоступен"), 0;
	TogglePlayerControllable(tid, 0);
	SetTimerEx("FunTrollUnfreeze", 3000, false, "i", tid);
	SendClientMessage(tid, 0xFF69B4FF, "[STREAM] Заморозка 3 сек!");
	SendClientMessage(playerid, 0x7CFC00FF, "Заморозка бесплатно.");
	return 1;
}


forward bool:FunControlActive(playerid);

stock bool:FunControlActive(playerid)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS) return false;
	if(ControlUntil[playerid] <= gettime()) return false;
	new tid = ControlTarget[playerid];
	if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid)) return false;
	if(!StreamerMode[tid]) return false;
	if(ControlledBy[tid] != playerid) return false;
	return true;
}

stock FunControlBuy(playerid)
{
	new tid = StreamTarget[playerid];
	if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid || !StreamerMode[tid])
		return SendClientMessage(playerid, COLOR_ERR, "Стример недоступен / режим выкл"), 0;
	if(ControlledBy[tid] != INVALID_PLAYER_ID && IsPlayerConnected(ControlledBy[tid]) && ControlUntil[ControlledBy[tid]] >= gettime())
		return SendClientMessage(playerid, COLOR_ERR, "Им уже кто-то управляет"), 0;

	ControlTarget[playerid] = tid;
	ControlUntil[playerid] = gettime() + FUN_CONTROL_SEC;
	ControlledBy[tid] = playerid;
	StreamTarget[playerid] = tid;

	new n[24], str[140];
	GetPlayerName(playerid, n, sizeof n);
	format(str, sizeof str, "{FF69B4}[STREAM] {FFFFFF}%s {FF69B4}купил ФУЛЛ-контроль над тобой на 60 сек!", n);
	SendClientMessage(tid, -1, str);
	GetPlayerName(tid, n, sizeof n);
	format(str, sizeof str, "{7CFC00}ФУЛЛ-контроль над %s на 60 секунд. Открываю меню.", n);
	SendClientMessage(playerid, -1, str);
	SendClientMessage(playerid, 0x7CFC00FF, "[Full Control] Бесплатно. Для повторного открытия введи .fullcontrol");

	SetTimerEx("FunControlEnd", FUN_CONTROL_SEC * 1000, false, "ii", playerid, ControlUntil[playerid]);
	FunControlMenu(playerid);
	return 1;
}

stock FunControlReopen(playerid)
{
	if(!FunControlActive(playerid))
		return SendClientMessage(playerid, COLOR_ERR, "\xD3\xE5\xF1\xF1\xE8\xFF \xD4\xD3\xCB\xCB-\xEA\xEE\xED\xF2\xF0\xEE\xEB\xFF \xED\xE5 \xE0\xEA\xF2\xE8\xE2\xED\xE0"), 0;
	return FunControlMenu(playerid);
}

stock FunControlMenu(playerid)
{
	if(!FunControlActive(playerid))
		return SendClientMessage(playerid, COLOR_ERR, "Контроль закончился"), 0;
	new left = ControlUntil[playerid] - gettime();
	if(left < 0) left = 0;
	new title[48];
	format(title, sizeof title, "Контроль (%d сек)", left);
	EuroShowPlayerDialog(playerid, D_FUN_CONTROL, DIALOG_STYLE_LIST, title,
		"1 Чат от него\n2 Команда от него\n3 Подбросить\n4 Заморозить\n5 ТП к себе\n6 HP 10\n7 Хил 100\n8 Джетпак\n9 Из авто\n10 Пьяный\n11 Танец\n12 Скин\n13 TROLLED\n14 Фейк-бан\n15 Фейк-кик\n16 Слепота\n17 Огонь\n18 Рандом аним\n19 Разворот 180\n20 Мини-бум\n21 Сесть\n22 Руки вверх\n23 Звук\n24 Фейк-донат чат\n25 Фейк-варн\n26 Фейк +лвл\n27 Буст скорость\n28 Медленно\n29 Невидимость on\n30 Невидимость off\n31 Камера тряска\n32 Оружие desert\n33 Разоружить\n34 В воду (Z-5)\n35 На небо (Z+20)\n36 Сесть на байк-аним\n37 Лежать\n38 Смех-аним\n39 Обновить меню\n40 Врем. машина (60 с)\n41 Аномалия (5 с)",
		"OK", "X");
	return 1;
}

stock FunControlCmd(playerid, cmdtext[])
{
	if(!FunControlActive(playerid)) return 0;
	new tid = ControlTarget[playerid];
	new cmd[128];
	format(cmd, sizeof cmd, "%s", cmdtext);
	// убрать ведущий /
	if(cmd[0] == '/') strdel(cmd, 0, 1);

	// чат-команды точки/слэша мода — пробуем как текст от стримера
	new line[144], n[24];
	GetPlayerName(tid, n, sizeof n);

	// .cmd или /cmd вид для игроков
	if(strfind(cmd, "me ") == 0 || strfind(cmd, "do ") == 0)
	{
		format(line, sizeof line, "* %s %s", n, cmd[3]);
		SendClientMessageToAll(0xC2A2DAFF, line);
	}
	else
	{
		format(line, sizeof line, "%s: /%s", n, cmd);
		SendClientMessageToAll(0xAAAAAAAA, line);
		// попытка вызвать команду у стримера (если GM слушает OnPlayerCommandText)
		// дубль с слэшем
		new withslash[132];
		format(withslash, sizeof withslash, "/%s", cmd);
		CallRemoteFunction("OnPlayerCommandText", "is", tid, withslash);
	}
	SendClientMessage(playerid, 0x7CFC00FF, "Команда отправлена от лица стримера.");
	return 1;
}

forward FunControlEnd(playerid, expectedUntil);
public FunControlEnd(playerid, expectedUntil)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS) return 1;
	if(ControlUntil[playerid] != expectedUntil || expectedUntil == 0) return 1;
	new tid = ControlTarget[playerid];
	if(tid >= 0 && tid < MAX_PLAYERS)
	{
		if(ControlledBy[tid] == playerid) ControlledBy[tid] = INVALID_PLAYER_ID;
		if(IsPlayerConnected(tid))
			SendClientMessage(tid, 0x7CFC00FF, "[STREAM] Фулл-контроль над тобой закончился.");
	}
	ControlTarget[playerid] = INVALID_PLAYER_ID;
	ControlUntil[playerid] = 0;
	if(IsPlayerConnected(playerid))
		SendClientMessage(playerid, COLOR_ERR, "Твоя сессия контроля (60 сек) закончилась.");
	return 1;
}


forward FunControlDestroyVehicle(vehicleid);
public FunControlDestroyVehicle(vehicleid)
{
	if(vehicleid >= 1 && vehicleid < MAX_VEHICLES) DestroyVehicle(vehicleid);
	return 1;
}

forward FunTrollUnfreeze(playerid);
public FunTrollUnfreeze(playerid)
{
	if(IsPlayerConnected(playerid)) TogglePlayerControllable(playerid, 1);
	return 1;
}


forward OnFunTop(playerid);
public OnFunTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_get_row_count(gSQL), body[1800], line[64], name[24];
	body[0] = 0;
	for(new i; i < rows && i < 50; i++)
	{
		cache_get_row(i, 0, name, gSQL, sizeof name);
		new v = cache_get_row_int(i, 1, gSQL);
		format(line, sizeof line, "%d. %s - %d FC\n", i + 1, name, v);
		strcat(body, line);
	}
	if(!body[0]) format(body, sizeof body, "Пусто");
	EuroShowPlayerDialog(playerid, D_FUN_TOP, DIALOG_STYLE_LIST, "Топ фанкоинов", body, "OK", "");
	return 1;
}

public OnFilterScriptInit()
{
	print("  [Euro+Bit+Meme] Алабуга загрузка");
	gSQLOk = 0; gSQL = 0; gMemeSeasonEnded = false;
	if(!LoadIni()) { print("[Euro] нет ini"); return 1; }
	if(!ConnectSQL()) { print("[Euro] MySQL ошибка"); return 1; }
	gSQLOk = 1;
	mysql_tquery(gSQL, "SET NAMES 'cp1251'");
	mysql_tquery(gSQL, "SET CHARACTER SET cp1251");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `evro` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `evro_exchanged` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `bitok` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `memecoin` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `meme_last` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `uah` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `kzt` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `play_sec` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `meme_rand` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `funcoin` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `fun_restart_cd` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `accounts` ADD COLUMN `fun_play_after_rst` INT NOT NULL DEFAULT 0");

	mysql_tquery(gSQL, "ALTER TABLE `houses` MODIFY `rent_time` BIGINT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `business` MODIFY `rent_time` BIGINT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `fuel_stations` MODIFY `rent_time` BIGINT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `garages` MODIFY `rent_time` BIGINT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `hotels` MODIFY `rent_time` BIGINT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `bought_houses` MODIFY `rent_time` BIGINT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "ALTER TABLE `br_garages` MODIFY `rent_time` BIGINT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL, "CREATE TABLE IF NOT EXISTS `fun_codes` (`id` INT AUTO_INCREMENT PRIMARY KEY, `code` VARCHAR(16) NOT NULL, `from_acc` INT NOT NULL, `from_name` VARCHAR(24) NOT NULL, `to_name` VARCHAR(24) NOT NULL, `days` INT NOT NULL DEFAULT 30, `active` TINYINT NOT NULL DEFAULT 1, `used` TINYINT NOT NULL DEFAULT 0, `to_acc` INT NOT NULL DEFAULT 0, UNIQUE KEY `uk_code` (`code`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251");
	MemeLoadSeasonFromDB();
	UpdateRate();
	SetTimer("UpdateRate", 300000, true);
	SetTimer("PayDay", 30000, true);
	SetTimer("MemeAnnounce", MEME_ANNOUNCE_MS, true);
	SetTimer("MemeCheckSeasonTick", 60000, true);
	SetTimer("PlaytimeTick", 1000, true);
	SetTimer("FR_PVZ_ProcessPendingEuroTimer", 1000, true);
	print("[Euro+Bit+Meme] OK");
	return 1;
}

public OnFilterScriptExit()
{
	if(gSQLOk) mysql_close(gSQL);
	return 1;
}

public OnPlayerConnect(playerid)
{
	EuroGuiDlgDestroy(playerid);
	gEuroGuiDlgActive[playerid] = false;
	gEuroGuiInputActive[playerid] = false;
	PlayerEuro[playerid] = 0; PlayerEuroEx[playerid] = 0; PlayerAccID[playerid] = 0;
	PlayerBit[playerid] = 0; PlayerMeme[playerid] = 0; PlayerDonate[playerid] = 0;
	PlayerUAH[playerid] = 0; PlayerKZT[playerid] = 0; PlayerFun[playerid] = 0; PlayerPlaySec[playerid] = 0; StreamerMode[playerid] = false; StreamTarget[playerid] = INVALID_PLAYER_ID; ControlTarget[playerid] = INVALID_PLAYER_ID; ControlUntil[playerid] = 0; ControlledBy[playerid] = INVALID_PLAYER_ID;
	PlayerRandBuys[playerid] = 0; PlayerFlyTimer[playerid] = 0; PlayerFlyActive[playerid] = 0; KztExMode[playerid] = 0;
	UahGiveTarget[playerid] = KztGiveTarget[playerid] = INVALID_PLAYER_ID; UahExMode[playerid] = 0;
	PlayerLastLogin[playerid] = 0; PlayerLoaded[playerid] = false;
	EuroGiveTarget[playerid] = BitGiveTarget[playerid] = MemeGiveTarget[playerid] = INVALID_PLAYER_ID;
	EuroExMode[playerid] = EuroBuyMode[playerid] = BitExMode[playerid] = MemeExMode[playerid] = 0;
	FamilyNamePending[playerid][0] = 0;
	SetTimerEx("LoadEuro", 5000, false, "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(playerid >= 0 && playerid < MAX_PLAYERS) FR_PVZ_ProcessPendingEuro(playerid);
	EuroGuiDlgDestroy(playerid);
	#pragma unused reason
	if(playerid < 0 || playerid >= MAX_PLAYERS) return 1;
	StreamerMode[playerid] = false;
	if(ControlledBy[playerid] != INVALID_PLAYER_ID)
	{
		new c = ControlledBy[playerid];
		if(c >= 0 && c < MAX_PLAYERS)
		{
			ControlTarget[c] = INVALID_PLAYER_ID;
			ControlUntil[c] = 0;
		}
		ControlledBy[playerid] = INVALID_PLAYER_ID;
	}
	ControlTarget[playerid] = INVALID_PLAYER_ID;
	ControlUntil[playerid] = 0;

	// остановить полёт — таймер иначе дергает GetPlayerKeys после leave
	if(PlayerFlyTimer[playerid])
	{
		KillTimer(PlayerFlyTimer[playerid]);
		PlayerFlyTimer[playerid] = 0;
	}
	PlayerFlyActive[playerid] = 0;

	if(PlayerLoaded[playerid] && PlayerAccID[playerid] > 0)
	{
		PlayerLastLogin[playerid] = gettime();
		SaveEuro(playerid); // async
	}
	PlayerLoaded[playerid] = false;
	PlayerAccID[playerid] = 0;
	EuroGiveTarget[playerid] = BitGiveTarget[playerid] = MemeGiveTarget[playerid] = INVALID_PLAYER_ID;
	UahGiveTarget[playerid] = KztGiveTarget[playerid] = INVALID_PLAYER_ID;
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(gEuroGuiInputActive[playerid])
	{
		new did = gEuroGuiDlgId[playerid];
		gEuroGuiInputActive[playerid] = false;
		EuroGuiDlgHide(playerid);
		if(!strcmp(text, "cancel", true) || !strcmp(text, "\xEE\xF2\xEC\xE5\xED\xE0", true)) OnDialogResponse(playerid, did, 0, -1, "");
		else OnDialogResponse(playerid, did, 1, 0, text);
		return 0;
	}
	if(text[0] != '.') return 1;
	new cmd[40]; format(cmd, sizeof cmd, "%s", text[1]);
	new sp = strfind(cmd, " "); if(sp != -1) cmd[sp] = 0;
	if(Cmd(playerid, cmd)) return 0;
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(cmdtext[0] != '/') return 0;
	new cmd[40]; format(cmd, sizeof cmd, "%s", cmdtext[1]);
	new sp = strfind(cmd, " "); if(sp != -1) cmd[sp] = 0;
	if(!strcmp(cmd, "streamer", true) || !strcmp(cmd, "streammode", true) || !strcmp(cmd, "fullcontrol", true) || !strcmp(cmd, "fccontrol", true)) return 0;
	if(Cmd(playerid, cmd)) return 1;
	return 0;
}


public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(!gEuroGuiDlgActive[playerid]) return 0;
    if(playertextid == gEuroGuiDlg[playerid][EGD_INFO]) return EuroGuiShowInfo(playerid);
    if(playertextid == gEuroGuiDlg[playerid][EGD_CLOSE] || playertextid == gEuroGuiDlg[playerid][EGD_CANCEL])
    {
        new did = gEuroGuiDlgId[playerid];
        EuroGuiDlgHide(playerid);
        if(did == EURO_GUI_INFO_DIALOG && gEuroGuiInfoMode[playerid]) return EuroGuiRestoreAfterInfo(playerid);
        OnDialogResponse(playerid, did, 0, -1, "");
        return 1;
    }
    if(playertextid == gEuroGuiDlg[playerid][EGD_PREV])
    {
        if(gEuroGuiDlgPage[playerid] > 0) gEuroGuiDlgPage[playerid]--;
        return EuroGuiDlgRender(playerid);
    }
    if(playertextid == gEuroGuiDlg[playerid][EGD_NEXT])
    {
        if((gEuroGuiDlgPage[playerid] + 1) * EURO_GUI_ROWS < gEuroGuiDlgItems[playerid]) gEuroGuiDlgPage[playerid]++;
        return EuroGuiDlgRender(playerid);
    }
    if(playertextid == gEuroGuiDlg[playerid][EGD_OK])
    {
        new did = gEuroGuiDlgId[playerid];
        EuroGuiDlgHide(playerid);
        if(did == EURO_GUI_INFO_DIALOG && gEuroGuiInfoMode[playerid]) return EuroGuiRestoreAfterInfo(playerid);
        OnDialogResponse(playerid, did, 1, 0, "");
        return 1;
    }
    for(new r = 0; r < EURO_GUI_ROWS; r++)
    {
        if(playertextid == gEuroGuiDlg[playerid][EGD_ROW0 + r])
        {
            new item = gEuroGuiDlgPage[playerid] * EURO_GUI_ROWS + r;
            if(item >= gEuroGuiDlgItems[playerid]) return 1;
            new did = gEuroGuiDlgId[playerid];
            if(EuroGuiIsTopDialog(did)) return 1;
            EuroGuiDlgHide(playerid);
            OnDialogResponse(playerid, did, 1, item, "");
            return 1;
        }
    }
    return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(gEuroGuiDlgActive[playerid] && clickedid == Text:INVALID_TEXT_DRAW)
    {
        new did = gEuroGuiDlgId[playerid];
        EuroGuiDlgHide(playerid);
        if(did == EURO_GUI_INFO_DIALOG && gEuroGuiInfoMode[playerid]) return EuroGuiRestoreAfterInfo(playerid);
        OnDialogResponse(playerid, did, 0, -1, "");
        return 1;
    }
    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == D_EURO_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1, 2: ShowMenu(playerid);
			case 3: { EuroExMode[playerid] = 0; EuroShowPlayerDialog(playerid, D_EURO_EX_AMT, DIALOG_STYLE_INPUT, "Евро->нал", "Сколько евро?", "OK", "X"); }
			case 4: { EuroExMode[playerid] = 1; EuroShowPlayerDialog(playerid, D_EURO_EX_AMT, DIALOG_STYLE_INPUT, "Евро->банк", "Сколько евро?", "OK", "X"); }
			case 5: { EuroBuyMode[playerid] = 0; EuroShowPlayerDialog(playerid, D_EURO_BUY_AMT, DIALOG_STYLE_INPUT, "Нал->евро", "Сколько руб?", "OK", "X"); }
			case 6: { EuroBuyMode[playerid] = 1; EuroShowPlayerDialog(playerid, D_EURO_BUY_AMT, DIALOG_STYLE_INPUT, "Банк->евро", "Сколько руб?", "OK", "X"); }
			case 7: EuroShowPlayerDialog(playerid, D_E2B_AMT, DIALOG_STYLE_INPUT, "Евро->бит", "Сколько евро?", "OK", "X");
			case 8: EuroShowPlayerDialog(playerid, D_EURO_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "ID:", "OK", "X");
			case 9: EuroShowPlayerDialog(playerid, D_EURO_SKIN, DIALOG_STYLE_INPUT, "Скин", "ID:", "OK", "X");
			case 10: EuroShowPlayerDialog(playerid, D_EURO_ACS, DIALOG_STYLE_INPUT, "Акс", "ID:", "OK", "X");
			case 11: EuroShowPlayerDialog(playerid, D_EURO_CAR, DIALOG_STYLE_INPUT, "Машина", "ID:", "OK", "X");
			case 12: // тюнинг
			{
				if(!IsPlayerInAnyVehicle(playerid)) SendClientMessage(playerid, COLOR_ERR, "Сядь в машину для тюнинга");
				else if(PlayerEuro[playerid] < EURO_TUNE_PRICE) SendClientMessage(playerid, COLOR_ERR, "Нужно 10000 евро");
				else EuroShowPlayerDialog(playerid, D_EURO_TUNE, DIALOG_STYLE_LIST, "{FFD700}Тюнинг 10000 евро",
					"Нитро\nГидравлика\nСпойлер 1\nСпойлер 2\nГлушитель 1\nГлушитель 2\nГлушитель 3\nГлушитель 4\nГлушитель 5\nСпойлер 3\nСпойлер 4\nСпойлер 5\nСпойлер 6\nКапот 1\nКапот 2\nКапот 3\nПороги 1\nПороги 2\nПороги 3\nФары\nВоздухозаборник 1\nВоздухозаборник 2\nВоздухозаборник 3\nВоздухозаборник 4\nСпойлер 7\nАнтенна\nКолёса Offroad\nКолёса Shadow\nКолёса Mega\nКолёса Rimshine\nКолёса Wires\nКолёса Classic\nКолёса Twist\nКолёса Cutter\nКолёса Shift\nКолёса Dollar\nКолёса Trance\nКолёса Atomic\nКолёса Ahab\nКолёса Virtual\nКолёса Access\nКолёса Import\nКолёса Grove\nКолёса Vista\nPaintjob 0\nPaintjob 1\nPaintjob 2\nPaintjob 3\nНомер EURO\nРемонт",
					"OK", "X");
			}
			case 13: StartFamilyBuy(playerid);
			case 14: ShowTop(playerid);
			case 15: ShowBitMenu(playerid);
			case 16: ShowMemeMenu(playerid);
			case 17: ShowUahMenu(playerid);
			case 18: ShowKztMenu(playerid);
			case 19: ShowFunMenu(playerid);
			case 20: { SaveEuro(playerid); ShowMenu(playerid); }
		}
		return 1;
	}
	if(dialogid == D_BIT_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1: ShowBitMenu(playerid);
			case 2: { BitExMode[playerid] = 0; EuroShowPlayerDialog(playerid, D_BIT_EX_AMT, DIALOG_STYLE_INPUT, "Бит->нал", "Сколько?", "OK", "X"); }
			case 3: { BitExMode[playerid] = 1; EuroShowPlayerDialog(playerid, D_BIT_EX_AMT, DIALOG_STYLE_INPUT, "Бит->банк", "Сколько?", "OK", "X"); }
			case 4: EuroShowPlayerDialog(playerid, D_B2E_AMT, DIALOG_STYLE_INPUT, "Бит->евро", "Сколько?", "OK", "X");
			case 5: EuroShowPlayerDialog(playerid, D_BIT_GIVE, DIALOG_STYLE_INPUT, "ID", "ID игрока:", "OK", "X");
			case 6: ShowBitTop(playerid);
			case 7: ShowMenu(playerid);
			case 8: ShowMemeMenu(playerid);
			case 9: { SaveEuro(playerid); ShowBitMenu(playerid); }
		}
		return 1;
	}
	if(dialogid == D_MEME_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1: ShowMemeMenu(playerid);
			case 2: { MemeExMode[playerid] = 0; EuroShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->нал", "Сколько?", "OK", "X"); }
			case 3: { MemeExMode[playerid] = 1; EuroShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->банк", "Сколько?", "OK", "X"); }
			case 4: { MemeExMode[playerid] = 2; EuroShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->евро", "Сколько?", "OK", "X"); }
			case 5: { MemeExMode[playerid] = 3; EuroShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->бит", "Сколько?", "OK", "X"); }
			case 6: EuroShowPlayerDialog(playerid, D_MEME_FROM_EUR, DIALOG_STYLE_INPUT, "Евро->мем", "Сколько евро?", "OK", "X");
			case 7: EuroShowPlayerDialog(playerid, D_MEME_FROM_BIT, DIALOG_STYLE_INPUT, "Бит->мем", "Сколько бит?", "OK", "X");
			case 8: EuroShowPlayerDialog(playerid, D_MEME_DONATE, DIALOG_STYLE_INPUT, "Донат->мем", "Сколько БЦ?", "OK", "X");
			case 9: { MemeExMode[playerid] = 4; EuroShowPlayerDialog(playerid, D_MEME_EX_AMT, DIALOG_STYLE_INPUT, "Мем->донат", "Сколько?", "OK", "X"); }
			case 10: EuroShowPlayerDialog(playerid, D_MEME_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "ID:", "OK", "X");
			case 11: MemeBuyFly(playerid);
			case 12: MemeBuyRandom(playerid);
			case 13: ShowMemeTop(playerid);
			case 14: ShowUahMenu(playerid);
			case 15: ShowKztMenu(playerid);
			case 16: ShowMenu(playerid);
			case 17: { SaveEuro(playerid); ShowMemeMenu(playerid); }
		}
		return 1;
	}
	if(dialogid == D_EURO_EX)
	{
		if(!response) return 1;
		if(listitem <= 1) { EuroExMode[playerid] = listitem; EuroShowPlayerDialog(playerid, D_EURO_EX_AMT, DIALOG_STYLE_INPUT, "Евро", "Сколько?", "OK", "X"); }
		else if(listitem <= 3) { EuroBuyMode[playerid] = (listitem == 3); EuroShowPlayerDialog(playerid, D_EURO_BUY_AMT, DIALOG_STYLE_INPUT, "Руб", "Сколько?", "OK", "X"); }
		else EuroShowPlayerDialog(playerid, D_E2B_AMT, DIALOG_STYLE_INPUT, "Евро->бит", "Сколько?", "OK", "X");
		return 1;
	}
	if(dialogid == D_BIT_EX)
	{
		if(!response) return 1;
		if(listitem <= 1) { BitExMode[playerid] = listitem; EuroShowPlayerDialog(playerid, D_BIT_EX_AMT, DIALOG_STYLE_INPUT, "Бит", "Сколько?", "OK", "X"); }
		else EuroShowPlayerDialog(playerid, D_B2E_AMT, DIALOG_STYLE_INPUT, "Бит->евро", "Сколько?", "OK", "X");
		return 1;
	}
	if(dialogid == D_EURO_EX_AMT) { if(response) DoExchange(playerid, strval(inputtext), EuroExMode[playerid] == 1); return 1; }
	if(dialogid == D_EURO_BUY_AMT) { if(response) BuyEuroFromRub(playerid, strval(inputtext), EuroBuyMode[playerid] == 1); return 1; }
	if(dialogid == D_BIT_EX_AMT) { if(response) BitToRub(playerid, strval(inputtext), BitExMode[playerid] == 1); return 1; }
	if(dialogid == D_E2B_AMT) { if(response) EuroToBit(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_B2E_AMT) { if(response) BitToEuro(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_MEME_EX_AMT)
	{
		if(!response) return 1;
		new a = strval(inputtext);
		switch(MemeExMode[playerid])
		{
			case 0: MemeToRub(playerid, a, 0);
			case 1: MemeToRub(playerid, a, 1);
			case 2: MemeToEuro(playerid, a);
			case 3: MemeToBit(playerid, a);
			case 4: MemeToDonate(playerid, a);
		}
		return 1;
	}
	if(dialogid == D_MEME_FROM_EUR) { if(response) EuroToMeme(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_MEME_FROM_BIT) { if(response) BitToMeme(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_MEME_DONATE) { if(response) DonateToMeme(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_EURO_SKIN) { if(response) BuySkin(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_EURO_ACS) { if(response) BuyAcs(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_EURO_CAR) { if(response) BuyCar(playerid, strval(inputtext)); return 1; }
	if(dialogid == D_EURO_FAM_NAME)
	{
		if(!response) return 1;
		if(strlen(inputtext) < 2 || strlen(inputtext) > 30) return SendClientMessage(playerid, COLOR_ERR, "2-30 символов"), 1;
		format(FamilyNamePending[playerid], 32, "%s", inputtext);
		EuroShowPlayerDialog(playerid, D_EURO_FAM_OK, DIALOG_STYLE_MSGBOX, "Семья", "Купить за 100000 евро?", "OK", "X");
		return 1;
	}
	if(dialogid == D_EURO_FAM_OK) { if(response) ConfirmFamily(playerid); return 1; }
	if(dialogid == D_EURO_GIVE)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Евро ещё не загружены"), 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID игрока"), 1;
		if(!PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "У игрока ещё не загружен баланс, подождите 2-5 сек"), 1;
		EuroGiveTarget[playerid] = tid;
		EuroShowPlayerDialog(playerid, D_EURO_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать евро", "Сколько евро отправить?", "OK", "X");
		return 1;
	}
	if(dialogid == D_EURO_GIVE_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Евро не загружены"), 1;
		new amt = strval(inputtext), tid = EuroGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "Игрок оффлайн или баланс не загружен"), 1;
		if(amt <= 0) return SendClientMessage(playerid, COLOR_ERR, "Сумма должна быть больше 0"), 1;
		if(PlayerEuro[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Недостаточно евро"), 1;
		PlayerEuro[playerid] -= amt;
		PlayerEuro[tid] += amt;
		SaveEuro(playerid);
		SaveEuro(tid);
		new str[96], n1[24], n2[24];
		GetPlayerName(playerid, n1, sizeof n1);
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{FFD700}Вы передали %d евро игроку %s [%d]", amt, n2, tid);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{FFD700}%s [%d] передал вам %d евро. Баланс: %d", n1, playerid, amt, PlayerEuro[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}
	if(dialogid == D_BIT_GIVE)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс ещё не загружен"), 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID игрока"), 1;
		if(!PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "У игрока ещё не загружен баланс, подождите 2-5 сек"), 1;
		BitGiveTarget[playerid] = tid;
		EuroShowPlayerDialog(playerid, D_BIT_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать бит", "Сколько бит? (комиссия 20%)", "OK", "X");
		return 1;
	}
	if(dialogid == D_BIT_GIVE_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс не загружен"), 1;
		new amt = strval(inputtext), tid = BitGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "Игрок оффлайн или баланс не загружен"), 1;
		if(amt <= 0) return SendClientMessage(playerid, COLOR_ERR, "Сумма должна быть больше 0"), 1;
		new fee = (amt * BIT_TRANSFER_FEE_PCT) / 100; if(fee < 1 && amt >= 5) fee = 1;
		new receive = amt - fee;
		if(receive < 1 || PlayerBit[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало битка / комиссия"), 1;
		PlayerBit[playerid] -= amt; PlayerBit[tid] += receive; SaveEuro(playerid); SaveEuro(tid);
		new str[112], n2[24];
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{00BFFF}-%d бит (комиссия %d), %s получил +%d", amt, fee, n2, receive);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{00BFFF}Вам пришло %d бит (с учётом комиссии). Баланс: %d", receive, PlayerBit[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}
	if(dialogid == D_MEME_GIVE)
	{
		if(!response) return 1;
		if(!MemeRequireActive(playerid)) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс ещё не загружен"), 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID игрока"), 1;
		if(!PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "У игрока ещё не загружен баланс, подождите 2-5 сек"), 1;
		MemeGiveTarget[playerid] = tid;
		EuroShowPlayerDialog(playerid, D_MEME_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать мем (50%)", "Сколько?", "OK", "X");
		return 1;
	}
	if(dialogid == D_MEME_GIVE_AMT)
	{
		if(!response) return 1;
		if(!MemeRequireActive(playerid)) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс не загружен"), 1;
		new amt = strval(inputtext), tid = MemeGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "Игрок оффлайн или баланс не загружен"), 1;
		if(amt <= 0) return SendClientMessage(playerid, COLOR_ERR, "Сумма должна быть больше 0"), 1;
		new fee = (amt * MEME_FEE_PCT) / 100; if(fee < 1 && amt >= 2) fee = 1;
		new receive = amt - fee;
		if(receive < 1 || PlayerMeme[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало мемкоина / комиссия 50%"), 1;
		PlayerMeme[playerid] -= amt; PlayerMeme[tid] += receive; SaveEuro(playerid); SaveEuro(tid);
		new str[112], n2[24];
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{FF69B4}-%d (комиссия 50%%=%d), %s получил +%d", amt, fee, n2, receive);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{FF69B4}+%d %s. Баланс: %d", receive, gMemeName, PlayerMeme[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}
	
	if(dialogid == D_UAH_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1, 2: ShowUahMenu(playerid);
			case 3: { UahExMode[playerid]=0; EuroShowPlayerDialog(playerid, D_UAH_EX_AMT, DIALOG_STYLE_INPUT, "Гривна->евро", "Сколько гривен?", "OK", "X"); }
			case 4: { UahExMode[playerid]=1; EuroShowPlayerDialog(playerid, D_UAH_EX_AMT, DIALOG_STYLE_INPUT, "Гривна->бит", "Сколько гривен?", "OK", "X"); }
			case 5: { UahExMode[playerid]=2; EuroShowPlayerDialog(playerid, D_UAH_EX_AMT, DIALOG_STYLE_INPUT, "Евро->гривна", "Сколько евро?", "OK", "X"); }
			case 6: { UahExMode[playerid]=3; EuroShowPlayerDialog(playerid, D_UAH_EX_AMT, DIALOG_STYLE_INPUT, "Бит->гривна", "Сколько бит?", "OK", "X"); }
			case 7: { UahExMode[playerid]=4; EuroShowPlayerDialog(playerid, D_UAH_EX_AMT, DIALOG_STYLE_INPUT, "БЦ->гривна", "Сколько БЦ?", "OK", "X"); }
			case 8: EuroShowPlayerDialog(playerid, D_UAH_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "ID:", "OK", "X");
			case 9: ShowUahTop(playerid);
			case 10: UahBuyAdmin(playerid);
			case 11: UahBuyLeader(playerid);
			case 12: ShowMenu(playerid);
		}
		return 1;
	}
	if(dialogid == D_KZT_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1, 2: ShowKztMenu(playerid);
			case 3: { KztExMode[playerid]=0; EuroShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Тенге->евро", "Сколько тенге?", "OK", "X"); }
			case 4: { KztExMode[playerid]=1; EuroShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Тенге->бит", "Сколько тенге?", "OK", "X"); }
			case 5: { KztExMode[playerid]=2; EuroShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Евро->тенге", "Сколько евро?", "OK", "X"); }
			case 6: { KztExMode[playerid]=3; EuroShowPlayerDialog(playerid, D_KZT_EX_AMT, DIALOG_STYLE_INPUT, "Бит->тенге", "Сколько бит?", "OK", "X"); }
			case 7: EuroShowPlayerDialog(playerid, D_KZT_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "ID:", "OK", "X");
			case 8: ShowKztTop(playerid);
			case 9: ShowMenu(playerid);
		}
		return 1;
	}
	if(dialogid == D_KZT_EX_AMT)
	{
		if(!response) return 1;
		new a = strval(inputtext);
		switch(KztExMode[playerid])
		{
			case 0: KztToEuro(playerid, a);
			case 1: KztToBit(playerid, a);
			case 2: KztFromEuro(playerid, a);
			case 3: KztFromBit(playerid, a);
		}
		return 1;
	}

	if(dialogid == D_UAH_EX_AMT)
	{
		if(!response) return 1;
		new a = strval(inputtext);
		switch(UahExMode[playerid])
		{
			case 0: UahToEuro(playerid, a);
			case 1: UahToBit(playerid, a);
			case 2: EuroToUah(playerid, a);
			case 3: BitToUah(playerid, a);
			case 4: DonateToUah(playerid, a);
		}
		return 1;
	}
	if(dialogid == D_UAH_GIVE)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс ещё не загружен"), 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID игрока"), 1;
		if(!PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "У игрока ещё не загружен баланс, подождите 2-5 сек"), 1;
		UahGiveTarget[playerid] = tid;
		EuroShowPlayerDialog(playerid, D_UAH_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать гривну", "Сколько? (комиссия 20%)", "OK", "X");
		return 1;
	}
	if(dialogid == D_UAH_GIVE_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс не загружен"), 1;
		new amt = strval(inputtext), tid = UahGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "Игрок оффлайн или баланс не загружен"), 1;
		if(amt <= 0) return SendClientMessage(playerid, COLOR_ERR, "Сумма должна быть больше 0"), 1;
		new fee = (amt * UAH_TRANSFER_FEE_PCT) / 100; if(fee < 1 && amt >= 5) fee = 1;
		new receive = amt - fee;
		if(receive < 1 || PlayerUAH[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало гривен / комиссия"), 1;
		PlayerUAH[playerid] -= amt; PlayerUAH[tid] += receive; SaveEuro(playerid); SaveEuro(tid);
		new str[112], n2[24];
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{0057B8}-%d гривен (комиссия %d), %s получил +%d", amt, fee, n2, receive);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{0057B8}Вам пришло %d гривен. Баланс: %d", receive, PlayerUAH[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}
	if(dialogid == D_KZT_GIVE)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс ещё не загружен"), 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID игрока"), 1;
		if(!PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "У игрока ещё не загружен баланс, подождите 2-5 сек"), 1;
		KztGiveTarget[playerid] = tid;
		EuroShowPlayerDialog(playerid, D_KZT_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать тенге", "Сколько? (комиссия 20%)", "OK", "X");
		return 1;
	}
	if(dialogid == D_KZT_GIVE_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return SendClientMessage(playerid, COLOR_ERR, "Баланс не загружен"), 1;
		new amt = strval(inputtext), tid = KztGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid])
			return SendClientMessage(playerid, COLOR_ERR, "Игрок оффлайн или баланс не загружен"), 1;
		if(amt <= 0) return SendClientMessage(playerid, COLOR_ERR, "Сумма должна быть больше 0"), 1;
		new fee = (amt * KZT_TRANSFER_FEE_PCT) / 100; if(fee < 1 && amt >= 5) fee = 1;
		new receive = amt - fee;
		if(receive < 1 || PlayerKZT[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало тенге / комиссия"), 1;
		PlayerKZT[playerid] -= amt; PlayerKZT[tid] += receive; SaveEuro(playerid); SaveEuro(tid);
		new str[112], n2[24];
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{00AFCA}-%d тенге (комиссия %d), %s получил +%d", amt, fee, n2, receive);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{00AFCA}Вам пришло %d тенге. Баланс: %d", receive, PlayerKZT[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}

	// ===== FUNCOIN dialogs =====

	if(dialogid == D_FUN_PROP_TYPE)
	{
		if(!response) return ShowFunMenu(playerid);
		if(listitem >= 0 && listitem <= 6) FunPropLoad(playerid, listitem);
		else if(listitem == 7)
		{
			EuroShowPlayerDialog(playerid, D_FUN_PROP_LIST, DIALOG_STYLE_INPUT, "Оплата по ID",
				"Формат: ТИП ID\nТип: 0 дом, 1 бизнес, 2 АЗС, 3 гараж, 4 отель, 5 bought, 6 BR-гараж\nПример для бизнеса 66: 1 66",
				"OK", "X");
			FunPropCount[playerid] = -1;
		}
		else ShowFunMenu(playerid);
		return 1;
	}
	if(dialogid == D_FUN_PROP_LIST)
	{
		if(!response) return FunPropOpen(playerid);
		if(FunPropCount[playerid] == -1)
		{
			new sp = strfind(inputtext, " ");
			if(sp < 1)
			{
				SendClientMessage(playerid, COLOR_ERR, "Формат: тип id  (пример бизнес 66: 1 66)");
				return FunPropOpen(playerid);
			}
			new t = strval(inputtext);
			new id = strval(inputtext[sp + 1]);
			if(t < 0 || t > 6 || id < 1)
			{
				SendClientMessage(playerid, COLOR_ERR, "Неверный тип или ID");
				return FunPropOpen(playerid);
			}
			FunPropType[playerid] = t;
			FunPropSel[playerid] = id;
			FunPropCount[playerid] = 1;
			FunPropIds[playerid][0] = id;
			FunPropAskDays(playerid, 0);
			return 1;
		}
		if(listitem < 0 || listitem >= FunPropCount[playerid]) return FunPropOpen(playerid);
		FunPropAskDays(playerid, listitem);
		return 1;
	}
	if(dialogid == D_FUN_PROP_DAYS)
	{
		if(!response) return FunPropOpen(playerid);
		new days = 0;
		if(listitem == 0) days = 30;
		else if(listitem == 1) days = 90;
		else if(listitem == 2) days = 365;
		else if(listitem == 3) days = 730;
		else if(listitem == 4) days = 1095;
		else if(listitem == 5) days = 1825;
		else return FunPropOpen(playerid);
		FunPropPay(playerid, days);
		return 1;
	}


	if(dialogid == D_FUN_RESTART_MIN)
	{
		if(!response) return ShowFunMenu(playerid);
		if(listitem == 0) FunRestartBuy(playerid, 15);
		else if(listitem == 1) FunRestartBuy(playerid, 30);
		else ShowFunMenu(playerid);
		return 1;
	}
	if(dialogid == D_FUN_STREAM_MENU)
	{
		if(!response) return ShowFunMenu(playerid);
		if(listitem == 0) FunStreamMenu(playerid);
		else if(listitem == 1) FunStreamEnable(playerid);
		else if(listitem == 2) FunStreamDisable(playerid);
		else if(listitem == 3) FunTrollPick(playerid);
		else ShowFunMenu(playerid);
		return 1;
	}
	if(dialogid == D_FUN_STREAM_ID)
	{
		if(!response) return FunStreamMenu(playerid);
		FunTrollMenu(playerid, strval(inputtext));
		return 1;
	}
	if(dialogid == D_FUN_STREAM_ACT)
	{
		if(!response) return FunStreamMenu(playerid);
		if(listitem == 0)
			EuroShowPlayerDialog(playerid, D_FUN_STREAM_CHAT, DIALOG_STYLE_INPUT, "Чат от имени", "Текст (как будто пишет стример):", "OK", "X");
		else if(listitem == 1)
			EuroShowPlayerDialog(playerid, D_FUN_STREAM_MSG, DIALOG_STYLE_INPUT, "Сообщение стримеру", "Текст на его экран:", "OK", "X");
		else if(listitem == 2) FunTrollSlap(playerid);
		else if(listitem == 3) FunTrollFreeze(playerid);
		else if(listitem == 4) FunControlBuy(playerid);
		else FunStreamMenu(playerid);
		return 1;
	}
	if(dialogid == D_FUN_CONTROL)
	{
		if(!response) return 1;
		if(!FunControlActive(playerid)) return SendClientMessage(playerid, COLOR_ERR, "Сессия контроля истекла"), 1;
		new tid = ControlTarget[playerid];
		switch(listitem)
		{
			case 0: EuroShowPlayerDialog(playerid, D_FUN_CONTROL_SAY, DIALOG_STYLE_INPUT, "Чат от стримера", "Текст:", "OK", "X");
			case 1: EuroShowPlayerDialog(playerid, D_FUN_CONTROL_CMD, DIALOG_STYLE_INPUT, "Команда от стримера", "Команда без /, например: euro", "OK", "X");
			case 2:
			{
				ClearAnimations(tid);
				new Float:a;
				GetPlayerFacingAngle(tid, a);
				SetPlayerVelocity(tid, floatsin(-a, degrees) * 0.45, floatcos(-a, degrees) * 0.45, 0.6);
				ApplyAnimation(tid, "PED", "FALL_spin", 4.1, 0, 1, 1, 0, 0, 1);
				PlayerPlaySound(tid, 1130, 0.0, 0.0, 0.0);
			}
			case 3:
			{
				TogglePlayerControllable(tid, 0);
				SetTimerEx("FunTrollUnfreeze", 3000, false, "i", tid);
			}
			case 4:
			{
				new Float:x,Float:y,Float:z;
				GetPlayerPos(playerid, x, y, z);
				SetPlayerPos(tid, x + 1.0, y, z);
			}
			case 5: SetPlayerHealth(tid, 10.0);
			case 6: { SetPlayerHealth(tid, 100.0); SetPlayerArmour(tid, 100.0); }
			case 7: SetPlayerSpecialAction(tid, SPECIAL_ACTION_USEJETPACK);
			case 8: if(IsPlayerInAnyVehicle(tid)) RemovePlayerFromVehicle(tid);
			case 9: SetPlayerDrunkLevel(tid, 5000);
			case 10: ApplyAnimation(tid, "DANCING", "dnce_M_a", 4.1, 1, 0, 0, 0, 0, 1);
			case 11: EuroShowPlayerDialog(playerid, D_FUN_CONTROL_SKIN, DIALOG_STYLE_INPUT, "Скин", "ID скина:", "OK", "X");
			case 12: GameTextForPlayer(tid, "~r~TROLLED", 3000, 3);
			case 13:
			{
				GameTextForPlayer(tid, "~r~BANNED~n~~w~1 day (FAKE)", 6000, 3);
				SendClientMessage(tid, 0xFF0000FF, "ФЕЙК-БАН. Это тролл стрима, не бан.");
			}
			case 14:
			{
				GameTextForPlayer(tid, "~r~KICKED (FAKE)", 4000, 3);
				SendClientMessage(tid, 0xFF0000FF, "ФЕЙК-КИК.");
			}
			case 15:
			{
				SetPlayerTime(tid, 0, 0);
				SetPlayerWeather(tid, 150);
				SetTimerEx("FunTrollClearWeather", 5000, false, "i", tid);
			}
			case 16:
			{
				new Float:x,Float:y,Float:z;
				GetPlayerPos(tid, x, y, z);
				CreateExplosion(x, y, z - 0.5, 1, 0.3);
			}
			case 17:
			{
				switch(random(4))
				{
					case 0: ApplyAnimation(tid, "PED", "HANDSUP", 4.1, 0, 0, 0, 0, 0, 1);
					case 1: ApplyAnimation(tid, "PED", "WALK_DRUNK", 4.1, 1, 1, 1, 1, 0, 1);
					case 2: ApplyAnimation(tid, "CRACK", "crckdeth2", 4.1, 0, 0, 0, 0, 0, 1);
					case 3: ApplyAnimation(tid, "GANGS", "hndshkaa", 4.1, 0, 0, 0, 0, 0, 1);
				}
			}
			case 18:
			{
				new Float:a;
				GetPlayerFacingAngle(tid, a);
				SetPlayerFacingAngle(tid, a + 180.0);
			}
			case 19:
			{
				new Float:x,Float:y,Float:z;
				GetPlayerPos(tid, x, y, z);
				CreateExplosion(x + 2.0, y, z, 12, 0.2);
			}
			case 20: ApplyAnimation(tid, "PED", "SEAT_down", 4.1, 0, 0, 0, 1, 0, 1);
			case 21: ApplyAnimation(tid, "PED", "HANDSUP", 4.1, 0, 0, 0, 1, 0, 1);
			case 22:
			{
				PlayerPlaySound(tid, 1130, 0.0, 0.0, 0.0);
				PlayerPlaySound(tid, 5201, 0.0, 0.0, 0.0);
			}
			case 23: // fake donate
			{
				new n[24], str[120];
				GetPlayerName(tid, n, sizeof n);
				format(str, sizeof str, "{00FF00}[DONATE] {FFFFFF}%s пополнил счёт на {00FF00}9999{FFFFFF} руб. (ФЕЙК)", n);
				SendClientMessageToAll(-1, str);
			}
			case 24: // fake warn
			{
				SendClientMessage(tid, 0xFF0000FF, "Администратор: предупреждение 1/3 (ФЕЙК-ВАРН)");
				GameTextForPlayer(tid, "~r~WARN 1/3", 4000, 3);
			}
			case 25: // fake level
			{
				new n[24], str[100];
				GetPlayerName(tid, n, sizeof n);
				format(str, sizeof str, "{FFD700}%s получил новый уровень! (ФЕЙК)", n);
				SendClientMessageToAll(-1, str);
			}
			case 26: SetPlayerVelocity(tid, 0.0, 0.0, 0.5); // boost up
			case 27: // slow - freeze style walk via drunk high
			{
				SetPlayerDrunkLevel(tid, 40000);
				SetTimerEx("FunTrollClearDrunk", 8000, false, "i", tid);
			}
			case 28: SetPlayerColor(tid, 0xFFFFFF00); // invisible nametag-ish transparent
			case 29: SetPlayerColor(tid, 0xFFFFFFFF);
			case 30: // camera shake via interpolate
			{
				new Float:x,Float:y,Float:z;
				GetPlayerPos(tid, x, y, z);
				SetPlayerCameraPos(tid, x + 1.0, y + 1.0, z + 2.0);
				SetPlayerCameraLookAt(tid, x, y, z);
				SetTimerEx("FunTrollClearCam", 2000, false, "i", tid);
			}
			case 31:
			{
				GivePlayerWeapon(tid, 24, 30); // desert eagle
				SendClientMessage(tid, 0xFF69B4FF, "[STREAM] Desert Eagle (тролл)");
			}
			case 32: ResetPlayerWeapons(tid);
			case 33:
			{
				new Float:x,Float:y,Float:z;
				GetPlayerPos(tid, x, y, z);
				SetPlayerPos(tid, x, y, z - 5.0);
			}
			case 34:
			{
				new Float:x,Float:y,Float:z;
				GetPlayerPos(tid, x, y, z);
				SetPlayerPos(tid, x, y, z + 20.0);
			}
			case 35: ApplyAnimation(tid, "BIKE", "BIKEfall_rgt", 4.1, 0, 1, 1, 0, 0, 1);
			case 36: ApplyAnimation(tid, "CRACK", "crckidle2", 4.1, 1, 0, 0, 0, 0, 1);
			case 37: ApplyAnimation(tid, "RAPPING", "Laugh_01", 4.1, 0, 0, 0, 0, 0, 1);
			case 38: FunControlMenu(playerid);
			case 39: EuroShowPlayerDialog(playerid, D_FUN_CONTROL_VEHICLE, DIALOG_STYLE_INPUT, "Временный авто", "ID машины (400-611):", "OK", "X");
			case 40:
			{
				GameTextForPlayer(tid, "~p~ANOMALY!", 3000, 3);
				PlayerPlaySound(tid, 1130, 0.0, 0.0, 0.0);
				switch(random(4))
				{
					case 0: { SetPlayerTime(tid, 0, 0); SetPlayerWeather(tid, 150); SetTimerEx("FunTrollClearWeather", 5000, false, "i", tid); }
					case 1: { SetPlayerDrunkLevel(tid, 40000); SetTimerEx("FunTrollClearDrunk", 5000, false, "i", tid); }
					case 2: { ApplyAnimation(tid, "PED", "FALL_spin", 4.1, 0, 1, 1, 0, 0, 1); }
					case 3: { new Float:ax, Float:ay, Float:az; GetPlayerPos(tid, ax, ay, az); SetPlayerCameraPos(tid, ax + 1.5, ay + 1.5, az + 2.0); SetPlayerCameraLookAt(tid, ax, ay, az); SetTimerEx("FunTrollClearCam", 2000, false, "i", tid); }
				}
			}
		}
		if(listitem != 0 && listitem != 1 && listitem != 11 && listitem != 38 && listitem != 39 && FunControlActive(playerid))
			FunControlMenu(playerid);
		return 1;
	}
	if(dialogid == D_FUN_CONTROL_SAY)
	{
		if(!response) { if(FunControlActive(playerid)) FunControlMenu(playerid); return 1; }
		if(FunControlActive(playerid)) { FunTrollChat(playerid, inputtext); if(FunControlActive(playerid)) FunControlMenu(playerid); }
		return 1;
	}
	if(dialogid == D_FUN_CONTROL_CMD)
	{
		if(!response) { if(FunControlActive(playerid)) FunControlMenu(playerid); return 1; }
		if(FunControlActive(playerid)) { FunControlCmd(playerid, inputtext); if(FunControlActive(playerid)) FunControlMenu(playerid); }
		return 1;
	}
	if(dialogid == D_FUN_CONTROL_SKIN)
	{
		if(!response) { if(FunControlActive(playerid)) FunControlMenu(playerid); return 1; }
		if(!FunControlActive(playerid)) return 1;
		new skin = strval(inputtext);
		if(skin < 0 || skin > 311) return SendClientMessage(playerid, COLOR_ERR, "\xCD\xE5\xE2\xE5\xF0\xED\xFB\xE9 ID \xF1\xEA\xE8\xED\xE0"), 1;
		SetPlayerSkin(ControlTarget[playerid], skin);
		SendClientMessage(playerid, 0x7CFC00FF, "Скин сменён");
		FunControlMenu(playerid);
		return 1;
	}
	if(dialogid == D_FUN_CONTROL_VEHICLE)
	{
		if(!response) { if(FunControlActive(playerid)) FunControlMenu(playerid); return 1; }
		if(!FunControlActive(playerid)) return 1;
		new modelid = strval(inputtext), tid = ControlTarget[playerid];
		if(modelid < 400 || modelid > 611) { SendClientMessage(playerid, COLOR_ERR, "Неверный ID. Укажи 400-611."); FunControlMenu(playerid); return 1; }
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid)) return 1;
		new Float:x, Float:y, Float:z, Float:a;
		GetPlayerPos(tid, x, y, z); GetPlayerFacingAngle(tid, a);
		new vehicleid = CreateVehicle(modelid, x + 3.0, y, z, a, -1, -1, 60);
		if(vehicleid == INVALID_VEHICLE_ID) SendClientMessage(playerid, COLOR_ERR, "Не удалось создать машину.");
		else { PutPlayerInVehicle(tid, vehicleid, 0); SetTimerEx("FunControlDestroyVehicle", 60000, false, "i", vehicleid); SendClientMessage(tid, 0xFF69B4FF, "[STREAM] Темповая машина на 60 секунд!"); }
		if(FunControlActive(playerid)) FunControlMenu(playerid);
		return 1;
	}
	if(dialogid == D_FUN_STREAM_CHAT)
	{
		if(!response) return 1;
		if(strlen(inputtext) < 1) return 1;
		FunTrollChat(playerid, inputtext);
		return 1;
	}
	if(dialogid == D_FUN_STREAM_MSG)
	{
		if(!response) return 1;
		if(strlen(inputtext) < 1) return 1;
		FunTrollMsg(playerid, inputtext);
		return 1;
	}

	if(dialogid == D_FUN_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0, 1: ShowFunMenu(playerid);
			case 2: FunBuyCodeStart(playerid);
			case 3: FunShowMyCodes(playerid);
			case 4: EuroShowPlayerDialog(playerid, D_FUN_GIVE, DIALOG_STYLE_INPUT, "ID игрока", "Кому передать FC (комиссия 99%):", "OK", "X");
			case 5:
			{
				FunCodeDays[playerid] = 0;
				EuroShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "FC -> евро", "Сколько FC? (комиссия 99%)", "OK", "X");
			}
			case 6:
			{
				FunCodeDays[playerid] = 1;
				EuroShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "FC -> бит", "Сколько FC? (комиссия 99%)", "OK", "X");
			}
			case 7:
			{
				FunCodeDays[playerid] = 10;
				EuroShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "Евро -> FC", "Сколько евро? (комиссия 99%)", "OK", "X");
			}
			case 8:
			{
				FunCodeDays[playerid] = 11;
				EuroShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "Бит -> FC", "Сколько бит? (комиссия 99%)", "OK", "X");
			}
			case 9:
			{
				FunCodeDays[playerid] = 12;
				EuroShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "Мем -> FC", "Сколько мемкоинов? (комиссия 99%)", "OK", "X");
			}
			case 10:
			{
				FunCodeDays[playerid] = 13;
				EuroShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "Гривна -> FC", "Сколько гривен? (комиссия 99%)", "OK", "X");
			}
			case 11:
			{
				FunCodeDays[playerid] = 14;
				EuroShowPlayerDialog(playerid, D_FUN_EX_AMT, DIALOG_STYLE_INPUT, "Тенге -> FC", "Сколько тенге? (комиссия 99%)", "OK", "X");
			}
			case 12: FunPropOpen(playerid);
			case 13: FunRestartMenu(playerid);
			case 14: FunStreamMenu(playerid);
			case 15:
			{
				mysql_tquery(gSQL, "SELECT `name`,IFNULL(`funcoin`,0) AS f FROM `accounts` ORDER BY IFNULL(`funcoin`,0) DESC LIMIT 50", "OnFunTop", "i", playerid);
			}
			case 16: ShowMenu(playerid);
			case 17: EuroShowPlayerDialog(playerid, D_FUN_ACTIVATE, DIALOG_STYLE_INPUT, "\xC0\xEA\xF2\xE8\xE2\xE0\xF6\xE8\xFF \xF1\xEF\xE5\xF6\xEA\xEE\xE4\xE0", "\xC2\xE2\xE5\xE4\xE8\xF2\xE5 \xEF\xEE\xEB\xF3\xF7\xE5\xED\xED\xFB\xE9 \xEA\xEE\xE4 \xE4\xEE\xF1\xF2\xF3\xEF\xE0:", "\xC0\xEA\xF2\xE8\xE2\xE8\xF0\xEE\xE2\xE0\xF2\xFC", "\xCD\xE0\xE7\xE0\xE4");
		}
		return 1;
	}
	if(dialogid == D_FUN_CODE_NICK)
	{
		if(!response) return ShowFunMenu(playerid);
		if(!PlayerLoaded[playerid]) return 1;
		new nick[MAX_PLAYER_NAME];
		format(nick, sizeof nick, "%s", inputtext);
		for(new i = strlen(nick) - 1; i >= 0; i--) if(nick[i] <= ' ') nick[i] = 0; else break;
		if(strlen(nick) < 3) return SendClientMessage(playerid, COLOR_ERR, "\xCA\xEE\xF0\xEE\xF2\xEA\xE8\xE9 \xED\xE8\xEA"), ShowFunMenu(playerid);
		format(FunCodeNick[playerid], MAX_PLAYER_NAME, "%s", nick);
		new daysList[1000];
		format(daysList, sizeof daysList,
			"15 \xE4\xED\xE5\xE9 (500 FC)\n20 \xE4\xED\xE5\xE9 (500 FC)\n30 \xE4\xED\xE5\xE9 (500 FC)\n40 \xE4\xED\xE5\xE9 (1000 FC)\n60 \xE4\xED\xE5\xE9 (1000 FC)\n90 \xE4\xED\xE5\xE9 (1500 FC)\n100 \xE4\xED\xE5\xE9 (2000 FC)\n120 \xE4\xED\xE5\xE9 (2000 FC)\n180 \xE4\xED\xE5\xE9 (3000 FC)\n200 \xE4\xED\xE5\xE9 (3500 FC)\n300 \xE4\xED\xE5\xE9 (5000 FC)\n365 \xE4\xED\xE5\xE9 (6500 FC)\n366 \xE4\xED\xE5\xE9 (6500 FC)\n500 \xE4\xED\xE5\xE9 (8500 FC)\n730 \xE4\xED\xE5\xE9 (12500 FC)\n1000 \xE4\xED\xE5\xE9 (17000 FC)\n1095 \xE4\xED\xE5\xE9 (18500 FC)\n1500 \xE4\xED\xE5\xE9 (25000 FC)\n2000 \xE4\xED\xE5\xE9 (33500 FC)");
		EuroShowPlayerDialog(playerid, D_FUN_CODE_DAYS, DIALOG_STYLE_LIST, "\xD1\xF0\xEE\xEA \xEA\xEE\xE4\xE0", daysList, "\xC2\xFB\xE1\xF0\xE0\xF2\xFC", "X");
		return 1;
	}
	if(dialogid == D_FUN_CODE_DAYS)
	{
		if(!response) return ShowFunMenu(playerid);
		new days;
		switch(listitem)
		{
			case 0: days = 15;
			case 1: days = 20;
			case 2: days = 30;
			case 3: days = 40;
			case 4: days = 60;
			case 5: days = 90;
			case 6: days = 100;
			case 7: days = 120;
			case 8: days = 180;
			case 9: days = 200;
			case 10: days = 300;
			case 11: days = 365;
			case 12: days = 366;
			case 13: days = 500;
			case 14: days = 730;
			case 15: days = 1000;
			case 16: days = 1095;
			case 17: days = 1500;
			case 18: days = 2000;
			default: return ShowFunMenu(playerid);
		}
		FunCreateCode(playerid, days);
		return 1;
	}

	if(dialogid == D_FUN_CODE_LIST)
	{
		if(!response) return ShowFunMenu(playerid);
		if(listitem >= FunListCount[playerid]) return ShowFunMenu(playerid);
		FunRevokeCode(playerid, listitem);
		return 1;
	}
	if(dialogid == D_FUN_ACTIVATE)
	{
		if(!response) return ShowFunMenu(playerid);
		new code[32];
		format(code, sizeof code, "%s", inputtext);
		for(new i = strlen(code) - 1; i >= 0; i--) if(code[i] <= ' ') code[i] = 0; else break;
		if(strlen(code) < 4) return SendClientMessage(playerid, COLOR_ERR, "Короткий код"), 1;
		FunActivateCode(playerid, code);
		return 1;
	}
	if(dialogid == D_FUN_GIVE)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return 1;
		new tid = strval(inputtext);
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || tid == playerid)
			return SendClientMessage(playerid, COLOR_ERR, "Неверный ID"), 1;
		if(!PlayerLoaded[tid]) return SendClientMessage(playerid, COLOR_ERR, "У игрока баланс не загружен"), 1;
		FunGiveTarget[playerid] = tid;
		EuroShowPlayerDialog(playerid, D_FUN_GIVE_AMT, DIALOG_STYLE_INPUT, "Передать FC", "Сумма (комиссия 99%):", "OK", "X");
		return 1;
	}
	if(dialogid == D_FUN_GIVE_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return 1;
		new amt = strval(inputtext), tid = FunGiveTarget[playerid];
		if(tid < 0 || tid >= MAX_PLAYERS || !IsPlayerConnected(tid) || !PlayerLoaded[tid]) return SendClientMessage(playerid, COLOR_ERR, "Игрок офф"), 1;
		if(amt <= 0 || PlayerFun[playerid] < amt) return SendClientMessage(playerid, COLOR_ERR, "Мало FC"), 1;
		new recv = FunFeeReceive(amt);
		if(recv < 1) return SendClientMessage(playerid, COLOR_ERR, "После 99% получателю 0"), 1;
		PlayerFun[playerid] -= amt;
		PlayerFun[tid] += recv;
		SaveEuro(playerid); SaveEuro(tid);
		new str[112], n2[24];
		GetPlayerName(tid, n2, sizeof n2);
		format(str, sizeof str, "{7CFC00}-%d FC (99%% комиссия), %s получил +%d", amt, n2, recv);
		SendClientMessage(playerid, -1, str);
		format(str, sizeof str, "{7CFC00}Вам пришло %d FC (с комиссией 99%%). Баланс: %d", recv, PlayerFun[tid]);
		SendClientMessage(tid, -1, str);
		return 1;
	}
	if(dialogid == D_FUN_EX_AMT)
	{
		if(!response) return 1;
		if(!PlayerLoaded[playerid]) return 1;
		new amt = strval(inputtext);
		new mode = FunCodeDays[playerid];
		FunCodeDays[playerid] = 0;
		if(mode == 1) FunToBit(playerid, amt);
		else if(mode == 10) CurrencyToFun(playerid, amt, 1); // euro
		else if(mode == 11) CurrencyToFun(playerid, amt, 2); // bit
		else if(mode == 12) CurrencyToFun(playerid, amt, 3); // meme
		else if(mode == 13) CurrencyToFun(playerid, amt, 4); // uah
		else if(mode == 14) CurrencyToFun(playerid, amt, 5); // kzt
		else FunToEuro(playerid, amt);
		return 1;
	}
	if(dialogid == D_FUN_TOP)
	{
		return 1;
	}

	if(dialogid == D_EURO_TUNE)
	{
		if(!response) return 1;
		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_ERR, "Сядь в машину"), 1;
		if(PlayerEuro[playerid] < EURO_TUNE_PRICE) return SendClientMessage(playerid, COLOR_ERR, "Нужно 10000 евро"), 1;
		new vid = GetPlayerVehicleID(playerid);
		PlayerEuro[playerid] -= EURO_TUNE_PRICE; SaveEuro(playerid);
		switch(listitem)
		{
			case 0: AddVehicleComponent(vid, 1010); // nitro
			case 1: AddVehicleComponent(vid, 1087); // hydraulics
			case 2: AddVehicleComponent(vid, 1008); // spoiler
			case 3: AddVehicleComponent(vid, 1009);
			case 4: AddVehicleComponent(vid, 1018); // exhaust
			case 5: AddVehicleComponent(vid, 1019);
			case 6: AddVehicleComponent(vid, 1020);
			case 7: AddVehicleComponent(vid, 1021);
			case 8: AddVehicleComponent(vid, 1022);
			case 9: AddVehicleComponent(vid, 1000); // spoiler
			case 10: AddVehicleComponent(vid, 1001);
			case 11: AddVehicleComponent(vid, 1002);
			case 12: AddVehicleComponent(vid, 1003);
			case 13: AddVehicleComponent(vid, 1004); // hood
			case 14: AddVehicleComponent(vid, 1005);
			case 15: AddVehicleComponent(vid, 1006);
			case 16: AddVehicleComponent(vid, 1007); // sideskirt
			case 17: AddVehicleComponent(vid, 1011);
			case 18: AddVehicleComponent(vid, 1012);
			case 19: AddVehicleComponent(vid, 1013); // lamps
			case 20: AddVehicleComponent(vid, 1014);
			case 21: AddVehicleComponent(vid, 1015);
			case 22: AddVehicleComponent(vid, 1016);
			case 23: AddVehicleComponent(vid, 1017);
			case 24: AddVehicleComponent(vid, 1023);
			case 25: AddVehicleComponent(vid, 1024);
			case 26: AddVehicleComponent(vid, 1025); // wheels
			case 27: AddVehicleComponent(vid, 1073);
			case 28: AddVehicleComponent(vid, 1074);
			case 29: AddVehicleComponent(vid, 1075);
			case 30: AddVehicleComponent(vid, 1076);
			case 31: AddVehicleComponent(vid, 1077);
			case 32: AddVehicleComponent(vid, 1078);
			case 33: AddVehicleComponent(vid, 1079);
			case 34: AddVehicleComponent(vid, 1080);
			case 35: AddVehicleComponent(vid, 1081);
			case 36: AddVehicleComponent(vid, 1082);
			case 37: AddVehicleComponent(vid, 1083);
			case 38: AddVehicleComponent(vid, 1084);
			case 39: AddVehicleComponent(vid, 1085);
			case 40: AddVehicleComponent(vid, 1086);
			case 41: AddVehicleComponent(vid, 1096);
			case 42: AddVehicleComponent(vid, 1097);
			case 43: AddVehicleComponent(vid, 1098);
			case 44: ChangeVehiclePaintjob(vid, 0);
			case 45: ChangeVehiclePaintjob(vid, 1);
			case 46: ChangeVehiclePaintjob(vid, 2);
			case 47: ChangeVehiclePaintjob(vid, 3);
			case 48: SetVehicleNumberPlate(vid, "EURO");
			case 49: RepairVehicle(vid);
		}
		SendClientMessage(playerid, COLOR_EURO, "Тюнинг установлен (-10000 евро)");
		return 1;
	}
	if(dialogid == D_EURO_TOP || dialogid == D_BIT_TOP || dialogid == D_MEME_TOP || dialogid == D_UAH_TOP || dialogid == D_KZT_TOP) return 1;
	return 0;
}

