
#if defined _school_event_gui_included
    #endinput
#endif
#define _school_event_gui_included

#include <a_samp>

/*------------------------------- ЦВЕТА / ЛЭЙАУТ -------------------------------*/

#define SEG_COLOR_BG        0x101014E6
#define SEG_COLOR_PANEL     0x1C1C22F0
#define SEG_COLOR_ACCENT    0x2ECC71FF
#define SEG_COLOR_ACCENT2   0xF1C40FFF
#define SEG_COLOR_TEXT      0xFFFFFFFF
#define SEG_COLOR_DIM       0xAAAAAAFF
#define SEG_COLOR_TAB_OFF   0x2A2A32FF
#define SEG_COLOR_TAB_ON    0x2ECC71FF

enum E_SEG_TAB
{
    SEG_TAB_STORY = 0,
    SEG_TAB_LESSONS,
    SEG_TAB_TOP,
    SEG_TAB_GRAFFITI,
    SEG_TAB_CATACOMBS,
    SEG_TAB_MARKET,
    SEG_TAB_COUNT
};

new const g_TabNames[SEG_TAB_COUNT][] = {
    "СЮЖЕТ", "УРОКИ", "ТОП", "ГРАФФИТИ", "КАТАКОМБЫ", "БАЗАР"
};

/*------------------------------- ГЛОБАЛЬНЫЕ TEXTDRAW --------------------------*/
// Общие для всех игроков (фон, заголовок, вкладки) — создаются один раз

new Text:g_TD_Background;
new Text:g_TD_HeaderBar;
new Text:g_TD_Title;
new Text:g_TD_CloseHint;
new Text:g_TD_Tab[SEG_TAB_COUNT];
new Text:g_TD_TabBg[SEG_TAB_COUNT];

new Text:g_TD_HeaderIcon;

/*------------------------------- ИГРОВЫЕ (PlayerText) TEXTDRAW ----------------*/

#define SEG_MAX_CONTENT_LINES (10)

new PlayerText:pTD_ContentPanel[MAX_PLAYERS];
new PlayerText:pTD_ContentLine[MAX_PLAYERS][SEG_MAX_CONTENT_LINES];
new PlayerText:pTD_ActionBtn[MAX_PLAYERS][3]; // до 3 кнопок действия на вкладке
new PlayerText:pTD_StatsBar[MAX_PLAYERS];     // жетоны / прогресс сверху

new g_CurrentTab[MAX_PLAYERS] = {SEG_TAB_STORY, ...};
new bool:g_GUIOpen[MAX_PLAYERS] = {false, ...};


stock SchoolGUI_OnGameModeInit()
{
    // Фон окна
    g_TD_Background = TextDrawCreate(140.0, 120.0, "_");
    TextDrawUseBox(g_TD_Background, 1);
    TextDrawBoxColor(g_TD_Background, SEG_COLOR_BG);
    TextDrawLetterSize(g_TD_Background, 0.0, 12.0);
    TextDrawTextSize(g_TD_Background, 500.0, 0.0);
    TextDrawFont(g_TD_Background, 0);

    // Верхняя плашка-хедер
    g_TD_HeaderBar = TextDrawCreate(140.0, 120.0, "_");
    TextDrawUseBox(g_TD_HeaderBar, 1);
    TextDrawBoxColor(g_TD_HeaderBar, SEG_COLOR_PANEL);
    TextDrawLetterSize(g_TD_HeaderBar, 0.0, 1.4);
    TextDrawTextSize(g_TD_HeaderBar, 500.0, 0.0);

    // Заголовок
    g_TD_Title = TextDrawCreate(150.0, 124.0, "СНОВА В ШКОЛУ");
    TextDrawFont(g_TD_Title, 2);
    TextDrawLetterSize(g_TD_Title, 0.35, 1.6);
    TextDrawColor(g_TD_Title, SEG_COLOR_ACCENT2);
    TextDrawSetOutline(g_TD_Title, 1);
    TextDrawSetShadow(g_TD_Title, 0);

    g_TD_HeaderIcon = TextDrawCreate(470.0, 124.0, "[ЛОГО]");
    TextDrawFont(g_TD_HeaderIcon, 1);
    TextDrawLetterSize(g_TD_HeaderIcon, 0.25, 1.0);
    TextDrawColor(g_TD_HeaderIcon, SEG_COLOR_DIM);

    g_TD_CloseHint = TextDrawCreate(150.0, 330.0, "ESC или клик по кнопке — закрыть");
    TextDrawFont(g_TD_CloseHint, 1);
    TextDrawLetterSize(g_TD_CloseHint, 0.2, 1.0);
    TextDrawColor(g_TD_CloseHint, SEG_COLOR_DIM);

    // Вкладки
    new Float:tabX = 150.0;
    new Float:tabW = 55.0;
    for (new i = 0; i < SEG_TAB_COUNT; i++)
    {
        g_TD_TabBg[i] = TextDrawCreate(tabX, 148.0, "_");
        TextDrawUseBox(g_TD_TabBg[i], 1);
        TextDrawBoxColor(g_TD_TabBg[i], SEG_COLOR_TAB_OFF);
        TextDrawLetterSize(g_TD_TabBg[i], 0.0, 1.1);
        TextDrawTextSize(g_TD_TabBg[i], tabX + tabW, 0.0);

        g_TD_Tab[i] = TextDrawCreate(tabX + 4.0, 150.0, g_TabNames[i]);
        TextDrawFont(g_TD_Tab[i], 1);
        TextDrawLetterSize(g_TD_Tab[i], 0.18, 1.0);
        TextDrawColor(g_TD_Tab[i], SEG_COLOR_TEXT);

        tabX += tabW + 3.0;
    }

    print("[SCHOOL_EVENT_GUI] Textdraw-интерфейс инициализирован.");
    return 1;
}

stock SchoolGUI_OnPlayerConnect(playerid)
{
    g_GUIOpen[playerid] = false;
    g_CurrentTab[playerid] = SEG_TAB_STORY;

    pTD_ContentPanel[playerid] = PlayerText:INVALID_TEXT_DRAW;
    pTD_StatsBar[playerid] = PlayerText:INVALID_TEXT_DRAW;
    for (new i = 0; i < SEG_MAX_CONTENT_LINES; i++) pTD_ContentLine[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    for (new i = 0; i < 3; i++) pTD_ActionBtn[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
    return 1;
}

/*------------------------------------------------------------------------------
    ОТКРЫТИЕ / ЗАКРЫТИЕ GUI
------------------------------------------------------------------------------*/

stock SchoolGUI_Open(playerid)
{
    if (!SchoolData[playerid][seLoaded])
        return SendClientMessage(playerid, 0xFF5555FF, "Данные ивента ещё загружаются, подожди секунду.");

    g_GUIOpen[playerid] = true;

    TextDrawShowForPlayer(playerid, g_TD_Background);
    TextDrawShowForPlayer(playerid, g_TD_HeaderBar);
    TextDrawShowForPlayer(playerid, g_TD_Title);
    TextDrawShowForPlayer(playerid, g_TD_HeaderIcon);
    TextDrawShowForPlayer(playerid, g_TD_CloseHint);

    for (new i = 0; i < SEG_TAB_COUNT; i++)
    {
        TextDrawShowForPlayer(playerid, g_TD_TabBg[i]);
        TextDrawShowForPlayer(playerid, g_TD_Tab[i]);
        TextDrawSetSelectable(g_TD_TabBg[i], true);
        TextDrawSetSelectable(g_TD_Tab[i], true);
    }

    SelectTextDraw(playerid, SEG_COLOR_ACCENT2);

    SchoolGUI_RenderStats(playerid);
    SchoolGUI_RenderTab(playerid, g_CurrentTab[playerid]);
    return 1;
}

stock SchoolGUI_Close(playerid)
{
    g_GUIOpen[playerid] = false;

    TextDrawHideForPlayer(playerid, g_TD_Background);
    TextDrawHideForPlayer(playerid, g_TD_HeaderBar);
    TextDrawHideForPlayer(playerid, g_TD_Title);
    TextDrawHideForPlayer(playerid, g_TD_HeaderIcon);
    TextDrawHideForPlayer(playerid, g_TD_CloseHint);

    for (new i = 0; i < SEG_TAB_COUNT; i++)
    {
        TextDrawHideForPlayer(playerid, g_TD_TabBg[i]);
        TextDrawHideForPlayer(playerid, g_TD_Tab[i]);
    }

    SchoolGUI_ClearContent(playerid);
    CancelSelectTextDraw(playerid);
    return 1;
}

stock SchoolGUI_ClearContent(playerid)
{
    if (pTD_ContentPanel[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, pTD_ContentPanel[playerid]);
        pTD_ContentPanel[playerid] = PlayerText:INVALID_TEXT_DRAW;
    }
    if (pTD_StatsBar[playerid] != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawDestroy(playerid, pTD_StatsBar[playerid]);
        pTD_StatsBar[playerid] = PlayerText:INVALID_TEXT_DRAW;
    }
    for (new i = 0; i < SEG_MAX_CONTENT_LINES; i++)
    {
        if (pTD_ContentLine[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid, pTD_ContentLine[playerid][i]);
            pTD_ContentLine[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }
    for (new i = 0; i < 3; i++)
    {
        if (pTD_ActionBtn[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid, pTD_ActionBtn[playerid][i]);
            pTD_ActionBtn[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
        }
    }
    return 1;
}

stock SchoolGUI_RenderStats(playerid)
{
    if (pTD_StatsBar[playerid] != PlayerText:INVALID_TEXT_DRAW)
        PlayerTextDrawDestroy(playerid, pTD_StatsBar[playerid]);

    new txt[128];
    format(txt, sizeof(txt), "Жетоны: %d~n~Уроков сегодня: %d/%d~n~Сумма оценок: %d",
        SchoolData[playerid][seJetons],
        SchoolData[playerid][seLessonsToday], SE_MAX_LESSONS_DAY,
        SchoolData[playerid][seGradesSum]);

    pTD_StatsBar[playerid] = CreatePlayerTextDraw(playerid, 150.0, 168.0, txt);
    PlayerTextDrawFont(playerid, pTD_StatsBar[playerid], 1);
    PlayerTextDrawLetterSize(playerid, pTD_StatsBar[playerid], 0.19, 1.1);
    PlayerTextDrawColor(playerid, pTD_StatsBar[playerid], SEG_COLOR_ACCENT);
    PlayerTextDrawShow(playerid, pTD_StatsBar[playerid]);
    return 1;
}

stock SchoolGUI_RenderTab(playerid, tab)
{
    SchoolGUI_ClearContent(playerid);
    g_CurrentTab[playerid] = tab;

    // подсветка активной вкладки
    for (new i = 0; i < SEG_TAB_COUNT; i++)
        TextDrawBoxColor(g_TD_TabBg[i], (i == tab) ? SEG_COLOR_TAB_ON : SEG_COLOR_TAB_OFF);

    SchoolGUI_RenderStats(playerid);

    // фон-панель под контент
    pTD_ContentPanel[playerid] = CreatePlayerTextDraw(playerid, 150.0, 220.0, "_");
    PlayerTextDrawUseBox(playerid, pTD_ContentPanel[playerid], 1);
    PlayerTextDrawBoxColor(playerid, pTD_ContentPanel[playerid], SEG_COLOR_PANEL);
    PlayerTextDrawLetterSize(playerid, pTD_ContentPanel[playerid], 0.0, 5.5);
    PlayerTextDrawTextSize(playerid, pTD_ContentPanel[playerid], 480.0, 0.0);
    PlayerTextDrawShow(playerid, pTD_ContentPanel[playerid]);

    new lines[SEG_MAX_CONTENT_LINES][128];
    new btnLabels[3][32];
    new btnCount = 0;
    new lineCount = 0;

    switch (tab)
    {
        case SEG_TAB_STORY:
        {
            if (!SchoolData[playerid][seStoryDone])
            {
                new step = SchoolData[playerid][seStoryStep];
                format(lines[lineCount++], 128, "Шаг %d/%d", step + 1, sizeof(g_StorySteps));
                format(lines[lineCount++], 128, "%s", (step < sizeof(g_StorySteps)) ? g_StorySteps[step] : "Готово!");
                format(btnLabels[btnCount++], 32, "Выполнить шаг");
            }
            else
            {
                format(lines[lineCount++], 128, "Школьная история пройдена.");
                format(lines[lineCount++], 128, "Открыты: Уроки, Топ, Граффити, Катакомбы, Базар.");
            }
        }
        case SEG_TAB_LESSONS:
        {
            if (SchoolData[playerid][seLessonsToday] >= SE_MAX_LESSONS_DAY)
                format(lines[lineCount++], 128, "На сегодня уроки закончились.");
            else
                format(lines[lineCount++], 128, "Урок %d/%d доступен.", SchoolData[playerid][seLessonsToday] + 1, SE_MAX_LESSONS_DAY);

            format(lines[lineCount++], 128, "Последняя оценка: %d", SchoolData[playerid][seLastGrade]);
            format(btnLabels[btnCount++], 32, "Пройти урок");
            if (SchoolData[playerid][seLastGrade] == 2 && !SchoolData[playerid][seRetakeUsed])
                format(btnLabels[btnCount++], 32, "Пересдать");
        }
        case SEG_TAB_TOP:
        {
            format(lines[lineCount++], 128, "Топ учеников загружается...");
            format(btnLabels[btnCount++], 32, "Обновить топ");
            // Реальный список подставляется через SE_OnTopLoaded -> SchoolGUI_RenderTopList()
        }
        case SEG_TAB_GRAFFITI:
        {
            format(lines[lineCount++], 128, "Этап граффити: %d/%d", g_GraffitiStageGlobal, SE_GRAFFITI_STAGES);
            new now = gettime();
            if (SchoolData[playerid][seGraffitiCooldown] > now)
                format(lines[lineCount++], 128, "Доступно через %d мин.", (SchoolData[playerid][seGraffitiCooldown]-now)/60);
            else
                format(btnLabels[btnCount++], 32, "Закрасить (+50)");
        }
        case SEG_TAB_CATACOMBS:
        {
            format(lines[lineCount++], 128, "Комнат: %d. Победи Хозяина Печати.", SE_CATACOMBS_ROOMS);
            new now = gettime();
            if (SchoolData[playerid][seCatacombsCooldown] > now)
                format(lines[lineCount++], 128, "Доступно через %d мин.", (SchoolData[playerid][seCatacombsCooldown]-now)/60);
            else
            {
                if (SchoolData[playerid][seCatacombsUnlocked] & 1) format(btnLabels[btnCount++], 32, "Лёгкий");
                if (btnCount < 3 && SchoolData[playerid][seCatacombsUnlocked] & 2) format(btnLabels[btnCount++], 32, "Средний");
                if (btnCount < 3 && SchoolData[playerid][seCatacombsUnlocked] & 4) format(btnLabels[btnCount++], 32, "Сложный");
            }
        }
        case SEG_TAB_MARKET:
        {
            for (new i = 0; i < sizeof(g_MarketItems) && lineCount < SEG_MAX_CONTENT_LINES; i++)
                format(lines[lineCount++], 128, "%s — %d жетонов", g_MarketItems[i][E_MARKET_NAME], g_MarketItems[i][E_MARKET_PRICE]);
            format(btnLabels[btnCount++], 32, "Открыть покупку (/schoolbuy)");
        }
    }

    // Рисуем строки текста
    new Float:ly = 232.0;
    for (new i = 0; i < lineCount; i++)
    {
        pTD_ContentLine[playerid][i] = CreatePlayerTextDraw(playerid, 158.0, ly, lines[i]);
        PlayerTextDrawFont(playerid, pTD_ContentLine[playerid][i], 1);
        PlayerTextDrawLetterSize(playerid, pTD_ContentLine[playerid][i], 0.21, 1.1);
        PlayerTextDrawColor(playerid, pTD_ContentLine[playerid][i], SEG_COLOR_TEXT);
        PlayerTextDrawShow(playerid, pTD_ContentLine[playerid][i]);
        ly += 16.0;
    }

    // Рисуем кнопки действий (кликабельные textdraw)
    new Float:by = 300.0;
    for (new i = 0; i < btnCount; i++)
    {
        pTD_ActionBtn[playerid][i] = CreatePlayerTextDraw(playerid, 158.0, by, btnLabels[i]);
        PlayerTextDrawFont(playerid, pTD_ActionBtn[playerid][i], 1);
        PlayerTextDrawLetterSize(playerid, pTD_ActionBtn[playerid][i], 0.22, 1.2);
        PlayerTextDrawColor(playerid, pTD_ActionBtn[playerid][i], SEG_COLOR_ACCENT2);
        PlayerTextDrawUseBox(playerid, pTD_ActionBtn[playerid][i], 1);
        PlayerTextDrawBoxColor(playerid, pTD_ActionBtn[playerid][i], 0x2A2A32FF);
        PlayerTextDrawSetSelectable(playerid, pTD_ActionBtn[playerid][i], true);
        PlayerTextDrawShow(playerid, pTD_ActionBtn[playerid][i]);
        by += 20.0;
    }

    return 1;
}

stock SchoolGUI_RenderTopList(playerid, names[][32], scores[], count)
{
    if (!g_GUIOpen[playerid] || g_CurrentTab[playerid] != SEG_TAB_TOP) return 0;

    SchoolGUI_ClearContent(playerid);
    SchoolGUI_RenderStats(playerid);

    pTD_ContentPanel[playerid] = CreatePlayerTextDraw(playerid, 150.0, 220.0, "_");
    PlayerTextDrawUseBox(playerid, pTD_ContentPanel[playerid], 1);
    PlayerTextDrawBoxColor(playerid, pTD_ContentPanel[playerid], SEG_COLOR_PANEL);
    PlayerTextDrawLetterSize(playerid, pTD_ContentPanel[playerid], 0.0, 5.5);
    PlayerTextDrawTextSize(playerid, pTD_ContentPanel[playerid], 480.0, 0.0);
    PlayerTextDrawShow(playerid, pTD_ContentPanel[playerid]);

    new Float:ly = 232.0;
    new max = (count < SEG_MAX_CONTENT_LINES) ? count : SEG_MAX_CONTENT_LINES;
    for (new i = 0; i < max; i++)
    {
        new line[64];
        format(line, sizeof(line), "%d. %s — %d", i + 1, names[i], scores[i]);
        pTD_ContentLine[playerid][i] = CreatePlayerTextDraw(playerid, 158.0, ly, line);
        PlayerTextDrawFont(playerid, pTD_ContentLine[playerid][i], 1);
        PlayerTextDrawLetterSize(playerid, pTD_ContentLine[playerid][i], 0.21, 1.1);
        PlayerTextDrawColor(playerid, pTD_ContentLine[playerid][i], SEG_COLOR_TEXT);
        PlayerTextDrawShow(playerid, pTD_ContentLine[playerid][i]);
        ly += 16.0;
    }
    return 1;
}

/*------------------------------------------------------------------------------
    ОБРАБОТКА КЛИКОВ
------------------------------------------------------------------------------*/

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if (!g_GUIOpen[playerid]) return 0;

    if (clickedid == Text:INVALID_TEXT_DRAW)
    {
        SchoolGUI_Close(playerid);
        return 1;
    }

    for (new i = 0; i < SEG_TAB_COUNT; i++)
    {
        if (clickedid == g_TD_TabBg[i] || clickedid == g_TD_Tab[i])
        {
            SchoolGUI_RenderTab(playerid, i);
            return 1;
        }
    }
    return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if (!g_GUIOpen[playerid]) return 0;

    new tab = g_CurrentTab[playerid];
    for (new i = 0; i < 3; i++)
    {
        if (playertextid == pTD_ActionBtn[playerid][i])
        {
            SchoolGUI_HandleAction(playerid, tab, i);
            return 1;
        }
    }
    return 0;
}

// Связывает клик по кнопке GUI с реальной логикой из school_event.pwn
stock SchoolGUI_HandleAction(playerid, tab, btnIndex)
{
    switch (tab)
    {
        case SEG_TAB_STORY:
        {
            SchoolEvent_AdvanceStory(playerid);
        }
        case SEG_TAB_LESSONS:
        {
            SE_DoLesson(playerid, btnIndex); // 0 = обычный урок, 1 = пересдача
        }
        case SEG_TAB_TOP:
        {
            CMD_schooltop(playerid, ""); // дёргаем запрос топа заново (см. примечание ниже)
        }
        case SEG_TAB_GRAFFITI:
        {
            SE_PaintGraffiti(playerid);
        }
        case SEG_TAB_CATACOMBS:
        {
            SE_StartCatacombs(playerid, btnIndex);
        }
        case SEG_TAB_MARKET:
        {
            SendClientMessage(playerid, SEG_COLOR_DIM, "Открой /schoolbuy [номер], чтобы купить предмет из списка.");
        }
    }
    SchoolGUI_RenderTab(playerid, tab); // перерисовать вкладку с обновлёнными данными
    return 1;
}

stock SchoolEvent_AdvanceStory(playerid)
{
    if (SchoolData[playerid][seStoryDone])
    {
        SendClientMessage(playerid, 0xFF5555FF, "Ты уже прошёл школьную историю.");
        return 0;
    }
    SchoolData[playerid][seStoryStep]++;
    SE_ShowStoryStep(playerid); // выдаёт награду и шлёт текст в чат при завершении
    return 1;
}

CMD:event(playerid, params[])
{
    SchoolGUI_Open(playerid);
    return 1;
}

CMD:schoolclose(playerid, params[])
{
    SchoolGUI_Close(playerid);
    return 1;
}
