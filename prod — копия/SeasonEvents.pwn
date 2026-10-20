#define FILTERSCRIPT

#include <a_samp>

/*
    FunRasha Online - Seasonal Events FilterScript
    Standalone base inspired by the autumn-event logic in the supplied mod.
    Custom per-player TextDraw GUI using the correct CreatePlayerTextDraw native; reward is bridged to EuroSystem.
    Commands are routed through EuroSystem's existing dot-command dispatcher: .event near an NPC; .eventinfo shows active progress anywhere; Y near NPC/objective.
*/

#define SEASON_COUNT             (9)
#define EVENT_SPAWN_COUNT        (5)
#define EVENT_MAP_ICON_ID        (99) // Reserved map icon slot for this filterscript.
#define EVENT_INTERACT_DISTANCE  (4.5)
#define EVENT_TARGET_DISTANCE    (5.0)

#define SEASON_FEB23             (0)
#define SEASON_MAR8              (1)
#define SEASON_SPRING            (2)
#define SEASON_MAY9              (3)
#define SEASON_SUMMER            (4)
#define SEASON_SCHOOL            (5)
#define SEASON_AUTUMN            (6)
#define SEASON_HALLOWEEN         (7)
#define SEASON_NEWYEAR           (8)

#define EVENT_STAGE_NONE         (0)
#define EVENT_STAGE_FIRST_ROUTE  (1)
#define EVENT_STAGE_SECOND_ROUTE (2)
#define EVENT_STAGE_THIRD_ROUTE (3)
#define EVENT_STAGE_RETURN       (4)
#define EVENT_STAGE_COMPLETED    (5)

#define GUI_COUNT                (5)

new const gMonthDays[12] = {31,28,31,30,31,30,31,31,30,31,30,31};

new const Float:gEventSpawnPos[EVENT_SPAWN_COUNT][4] =
{
    {844.824829, 794.637268, 13.381684, 69.833580},
    {1802.542968, 2517.302490, 14.498353, 128.900222},
    {2740.715820, -2441.796142, 21.781099, 289.500274},
    {-2430.725341, 204.739364, 26.095102, 171.770828},
    {-2667.526611, 2006.567016, 11.197804, 180.000000}
};



// Coordinates and city labels are taken from the supplied Kashon CRMP gamemode spawn data.
new const gEventSpawnCity[EVENT_SPAWN_COUNT][24] =
{
    "\xC0\xF0\xE7\xE0\xEC\xE0\xF1",       // Арзамас
    "\xC1\xE0\xF2\xFB\xF0\xE5\xE2\xEE", // Батырево
    "\xDE\xE6\xED\xFB\xE9",                   // Южный
    "\xCB\xFB\xF2\xEA\xE0\xF0\xE8\xED\xEE", // Лыткарино
    "\xCD\xE8\xE6\xE5\xE3\xEE\xF0\xEE\xE4\xF1\xEA" // Нижегородск
};

new const gSeasonTitle[SEASON_COUNT][64] =
{
    "23 ФЕВРАЛЯ — ОПЕРАЦИЯ «ЩИТ»",
    "8 МАРТА — ДЕЛО ЦВЕТОЧНОГО КУРЬЕРА",
    "ВЕСНА — ТАЙНА ПРОБУЖДЕНИЯ",
    "9 МАЯ — ПАМЯТЬ ПОКОЛЕНИЙ",
    "ЛЕТО — ЭКСПЕДИЦИЯ НА БЕРЕГ",
    "ШКОЛЬНЫЙ СЕЗОН — ПРОПАВШИЙ ДНЕВНИК",
    "ОСЕНЬ — ЗОЛОТОЙ СЛЕД",
    "ХЭЛЛОУИН — ПОСЛЕДНЯЯ МАСКА",
    "НОВЫЙ ГОД — ПРОПАВШИЕ ПОДАРКИ"
};

new const gSeasonDescription[SEASON_COUNT][192] =
{
    "Военный архив потерял важный пакет документов. Найди связистов, восстанови маршрут и верни документы командованию.",
    "Перед праздничным концертом пропала доставка цветов. Помоги организаторам собрать подсказки и найти отправление.",
    "После первой оттепели в парке обнаружили странные следы. Поговори с хранителями и помоги вернуть весенний архив.",
    "Ветераны готовят памятную выставку, но часть писем не дошла до музея. Восстанови путь посылок и доставь их хранителю.",
    "Экспедиция потеряла оборудование на маршруте. Помоги команде найти две точки снабжения и вернуться к капитану.",
    "Из школьного архива пропал дневник выпускника. Собери сведения у сотрудников и верни находку в библиотеку.",
    "Старый тракт хранит следы пропавшего груза. Найди две контрольные точки и вернись к следопыту.",
    "В городе появились загадочные маски. Разузнай, кто оставил их на маршруте, и доложи следователю.",
    "Почтовые мешки с подарками перепутали по дороге. Найди две точки доставки и вернись к праздничной команде."
};

new const gSeasonQuestStep[SEASON_COUNT][3][96] =
{
    {"\xCD\xE0\xE9\xE4\xE8\x20\xEB\xE8\xF1\xF2\x20\xF1\x20\xF7\xE0\xF1\xF2\xEE\xF2\xEE\xE9\x20\xE2\xEE\xE5\xED\xED\xEE\xE9\x20\xF0\xE0\xE4\xE8\xEE\xF1\xE2\xFF\xE7\xE8\x2E", "\xCF\xE5\xF0\xE5\xE4\xE0\xE9\x20\xE7\xE0\xF8\xE8\xF4\xF0\xEE\xE2\xE0\xED\xED\xEE\xE5\x20\xF1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xE5\x20\xEA\xEE\xEC\xE0\xED\xE4\xEE\xE2\xE0\xED\xE8\xFE\x2E", "\xC2\xE5\xF0\xED\xE8\x20\xED\xE0\xE9\xE4\xE5\xED\xED\xFB\xE5\x20\xE4\xEE\xEA\xF3\xEC\xE5\xED\xF2\xFB\x20\xF1\xE5\xF0\xE6\xE0\xED\xF2\xF3\x2E"},
    {"\xCD\xE0\xE9\xE4\xE8\x20\xEF\xF0\xEE\xEF\xE0\xE2\xF8\xE8\xE9\x20\xE7\xE0\xEA\xE0\xE7\x20\xED\xE0\x20\xF6\xE2\xE5\xF2\xFB\x2E", "\xC7\xE0\xE1\xE5\xF0\xE8\x20\xF1\xEE\xE1\xF0\xE0\xED\xED\xFB\xE9\x20\xE1\xF3\xEA\xE5\xF2\x20\xF3\x20\xF4\xEB\xEE\xF0\xE8\xF1\xF2\xE0\x2E", "\xC4\xEE\xF1\xF2\xE0\xE2\xFC\x20\xF6\xE2\xE5\xF2\xFB\x20\xEE\xF0\xE3\xE0\xED\xE8\xE7\xE0\xF2\xEE\xF0\xF3\x20\xEA\xEE\xED\xF6\xE5\xF0\xF2\xE0\x2E"},
    {"\xCE\xF1\xEC\xEE\xF2\xF0\xE8\x20\xEF\xE5\xF0\xE2\xF3\xFE\x20\xF1\xF2\xF0\xE0\xED\xED\xF3\xFE\x20\xEE\xF2\xEC\xE5\xF2\xEA\xF3\x20\xED\xE0\x20\xE7\xE5\xEC\xEB\xE5\x2E", "\xD1\xE2\xE5\xF0\xFC\x20\xF1\xEB\xE5\xE4\xFB\x20\xF1\x20\xE7\xE0\xEF\xE8\xF1\xFF\xEC\xE8\x20\xF1\xEC\xEE\xF2\xF0\xE8\xF2\xE5\xEB\xFF\x20\xEF\xE0\xF0\xEA\xE0\x2E", "\xC2\xE5\xF0\xED\xE8\x20\xE2\xE5\xF1\xE5\xED\xED\xE8\xE9\x20\xE0\xF0\xF5\xE8\xE2\x20\xEB\xE5\xF1\xED\xE8\xEA\xF3\x2E"},
    {"\xCD\xE0\xE9\xE4\xE8\x20\xEF\xE5\xF0\xE2\xEE\xE5\x20\xEF\xF0\xEE\xEF\xE0\xE2\xF8\xE5\xE5\x20\xEF\xE0\xEC\xFF\xF2\xED\xEE\xE5\x20\xEF\xE8\xF1\xFC\xEC\xEE\x2E", "\xCE\xF2\xED\xE5\xF1\xE8\x20\xEA\xEE\xEF\xE8\xFE\x20\xEF\xE8\xF1\xFC\xEC\xE0\x20\xEF\xEE\xEB\xE5\xE2\xEE\xEC\xF3\x20\xEC\xE5\xE4\xE8\xEA\xF3\x2E", "\xCF\xE5\xF0\xE5\xE4\xE0\xE9\x20\xE2\xEE\xF1\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED\xED\xFB\xE5\x20\xEF\xE8\xF1\xFC\xEC\xE0\x20\xE2\xE5\xF2\xE5\xF0\xE0\xED\xF3\x2E"},
    {"\xCD\xE0\xE9\xE4\xE8\x20\xEF\xEE\xF2\xE5\xF0\xFF\xED\xED\xFB\xE9\x20\xFF\xF9\xE8\xEA\x20\xFD\xEA\xF1\xEF\xE5\xE4\xE8\xF6\xE8\xE8\x2E", "\xCF\xF0\xEE\xE2\xE5\xF0\xFC\x20\xE2\xF2\xEE\xF0\xF3\xFE\x20\xF2\xEE\xF7\xEA\xF3\x20\xF1\xED\xE0\xE1\xE6\xE5\xED\xE8\xFF\x2E", "\xC4\xEE\xEB\xEE\xE6\xE8\x20\xEA\xE0\xEF\xE8\xF2\xE0\xED\xF3\x20\xEE\x20\xED\xE0\xE9\xE4\xE5\xED\xED\xFB\xF5\x20\xEF\xF0\xE8\xEF\xE0\xF1\xE0\xF5\x2E"},
    {"\xCD\xE0\xE9\xE4\xE8\x20\xEF\xF0\xEE\xEF\xE0\xE2\xF8\xF3\xFE\x20\xF1\xF2\xF0\xE0\xED\xE8\xF6\xF3\x20\xF8\xEA\xEE\xEB\xFC\xED\xEE\xE3\xEE\x20\xE4\xED\xE5\xE2\xED\xE8\xEA\xE0\x2E", "\xCF\xEE\xEF\xF0\xEE\xF1\xE8\x20\xE1\xE8\xE1\xEB\xE8\xEE\xF2\xE5\xEA\xE0\xF0\xFF\x20\xEF\xF0\xEE\xE2\xE5\xF0\xE8\xF2\xFC\x20\xEF\xEE\xE4\xF1\xEA\xE0\xE7\xEA\xF3\x2E", "\xC2\xE5\xF0\xED\xE8\x20\xE2\xEE\xF1\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED\xED\xFB\xE9\x20\xE4\xED\xE5\xE2\xED\xE8\xEA\x20\xE4\xE8\xF0\xE5\xEA\xF2\xEE\xF0\xF3\x2E"},
    {"\xCE\xF1\xEC\xEE\xF2\xF0\xE8\x20\xF1\xF2\xE0\xF0\xF3\xFE\x20\xEE\xF2\xEC\xE5\xF2\xEA\xF3\x20\xED\xE0\x20\xEB\xE5\xF1\xED\xEE\xE9\x20\xF2\xF0\xEE\xEF\xE5\x2E", "\xCD\xE0\xE9\xE4\xE8\x20\xE2\xF2\xEE\xF0\xEE\xE9\x20\xE7\xED\xE0\xEA\x20\xF3\x20\xE7\xE0\xE1\xF0\xEE\xF8\xE5\xED\xED\xEE\xE3\xEE\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xE0\x2E", "\xCE\xF2\xED\xE5\xF1\xE8\x20\xEE\xF2\xF7\xB8\xF2\x20\xEE\x20\xF1\xEB\xE5\xE4\xE0\xF5\x20\xEE\xF5\xEE\xF2\xED\xE8\xEA\xF3\x2E"},
    {"\xCE\xF1\xEC\xEE\xF2\xF0\xE8\x20\xEF\xE5\xF0\xE2\xF3\xFE\x20\xE1\xF0\xEE\xF8\xE5\xED\xED\xF3\xFE\x20\xEC\xE0\xF1\xEA\xF3\x2E", "\xCD\xE0\xE9\xE4\xE8\x20\xE2\xF2\xEE\xF0\xF3\xFE\x20\xEC\xE0\xF1\xEA\xF3\x20\xEF\xEE\x20\xEE\xF1\xF2\xE0\xE2\xEB\xE5\xED\xED\xEE\xE9\x20\xEF\xEE\xE4\xF1\xEA\xE0\xE7\xEA\xE5\x2E", "\xCF\xE5\xF0\xE5\xE4\xE0\xE9\x20\xF3\xEB\xE8\xEA\xE8\x20\xF1\xEB\xE5\xE4\xEE\xE2\xE0\xF2\xE5\xEB\xFE\x2E"},
    {"\xCD\xE0\xE9\xE4\xE8\x20\xEF\xE5\xF0\xE2\xFB\xE9\x20\xEC\xE5\xF8\xEE\xEA\x20\xF1\x20\xEF\xE5\xF0\xE5\xEF\xF3\xF2\xE0\xED\xED\xFB\xEC\xE8\x20\xEF\xEE\xE4\xE0\xF0\xEA\xE0\xEC\xE8\x2E", "\xCF\xF0\xEE\xE2\xE5\xF0\xFC\x20\xE2\xF2\xEE\xF0\xF3\xFE\x20\xF2\xEE\xF7\xEA\xF3\x20\xE4\xEE\xF1\xF2\xE0\xE2\xEA\xE8\x2E", "\xC2\xE5\xF0\xED\xE8\x20\xF1\xEF\xE8\xF1\xEE\xEA\x20\xEF\xEE\xF1\xFB\xEB\xEE\xEA\x20\xC4\xE5\xE4\xF3\x20\xCC\xEE\xF0\xEE\xE7\xF3\x2E"}
};

new const gSeasonNpcName[SEASON_COUNT][EVENT_SPAWN_COUNT][32] =
{
    {"Сержант Волков", "Майор Громов", "Связист Орлов", "Медик Светлова", "Интендант Крылов"},
    {"Организатор Марта", "Флорист Лилия", "Кондитер Алина", "Музыкант Ева", "Ведущая Софья"},
    {"Лесник Григорий", "Алиса Следопытка", "Механик Марк", "Смотритель парка", "Архивариус"},
    {"Ветеран Николай", "Связист Петров", "Медик Зорина", "Хранитель архива", "Командир Орлов"},
    {"Капитан Летун", "Гид Марина", "Механик Борис", "Рыбак Степан", "Фотограф Лев"},
    {"Директор Савельев", "Учительница Ирина", "Библиотекарь", "Староста Денис", "Архивариус"},
    {"Лесник Григорий", "Алиса Следопытка", "Механик Марк", "Охотник Филиппыч", "Хозяин таверны"},
    {"Ворон", "Медиум Агата", "Сторож кладбища", "Масочник", "Следователь"},
    {"Дед Мороз", "Снегурочка", "Почтальон", "Игрушечник", "Хранитель ёлки"}
};

new const gSeasonNpcModel[SEASON_COUNT][EVENT_SPAWN_COUNT] =
{
    {287, 287, 287, 191, 287},
    {172, 193, 211, 211, 192},
    {158, 162, 170, 161, 155},
    {287, 191, 190, 61, 287},
    {158, 156, 161, 153, 146},
    {147, 150, 155, 170, 171},
    {161, 162, 171, 163, 155},
    {268, 169, 170, 268, 189},
    {160, 172, 155, 171, 157}
};

new const gSeasonReward[SEASON_COUNT] =
{
    600, 550, 500, 750, 500, 500, 600, 650, 800
};

new gActiveSeason = -1;
new gSeasonEndYear, gSeasonEndMonth, gSeasonEndDay;
new gNpcActor[EVENT_SPAWN_COUNT];
new Text3D:gNpcLabel[EVENT_SPAWN_COUNT];
new bool:gWorldCreated;

new bool:gPlayerLoaded[MAX_PLAYERS];
new gPlayerSeason[MAX_PLAYERS];
new gPlayerEventStage[MAX_PLAYERS];
new gTargetSpawnOne[MAX_PLAYERS];
new gTargetSpawnTwo[MAX_PLAYERS];
new gTargetSpawnThree[MAX_PLAYERS];
new gStartSpawn[MAX_PLAYERS];
new bool:gGuiOpen[MAX_PLAYERS];
// Uses five per-player TextDraws. The creation native in this include is CreatePlayerTextDraw.
new PlayerText:gGuiPanel[MAX_PLAYERS];
new PlayerText:gGuiTitle[MAX_PLAYERS];
new PlayerText:gGuiBody[MAX_PLAYERS];
new PlayerText:gGuiAction[MAX_PLAYERS];
new PlayerText:gGuiClose[MAX_PLAYERS];


forward Event_UpdateTimer();

stock Event_IsLeapYear(year)
{
    return ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0));
}

stock Event_DateSerial(year, month, day)
{
    new days = day;
    for(new y = 1; y < year; y++)
    {
        days += Event_IsLeapYear(y) ? 366 : 365;
    }

    for(new m = 1; m < month; m++)
    {
        days += gMonthDays[m - 1];
        if(m == 2 && Event_IsLeapYear(year)) days++;
    }
    return days;
}

stock Event_GetActiveSeason(&endYear, &endMonth, &endDay)
{
    new year, month, day;
    getdate(year, month, day);

    endYear = year;
    endMonth = month;
    endDay = day;

    if(month == 12 || (month == 1 && day <= 15))
    {
        if(month == 12)
        {
            endYear = year + 1;
            endMonth = 1;
        }
        else endMonth = 1;
        endDay = 15;
        return SEASON_NEWYEAR;
    }

    if(month == 1 || (month == 2 && day <= 25))
    {
        endMonth = 2;
        endDay = 25;
        return SEASON_FEB23;
    }

    if(month == 2)
    {
        endMonth = 3;
        endDay = 1;
        return SEASON_SPRING;
    }

    if(month == 3 && day <= 10)
    {
        endMonth = 3;
        endDay = 10;
        return SEASON_MAR8;
    }

    if((month == 3 && day > 10) || month == 4)
    {
        endMonth = 5;
        endDay = 8;
        return SEASON_SPRING;
    }

    if(month == 5 && day <= 12)
    {
        endMonth = 5;
        endDay = 12;
        return SEASON_MAY9;
    }

    if(month == 5)
    {
        endMonth = 5;
        endDay = 31;
        return SEASON_SPRING;
    }

    if(month == 6 || month == 7 || (month == 8 && day < 25))
    {
        endMonth = 8;
        endDay = 31;
        return SEASON_SUMMER;
    }

    if((month == 8 && day >= 25) || (month == 9 && day <= 10))
    {
        endMonth = 9;
        endDay = 10;
        return SEASON_SCHOOL;
    }

    if(month == 9 || (month == 10 && day <= 24))
    {
        endMonth = 10;
        endDay = 24;
        return SEASON_AUTUMN;
    }

    if((month == 10 && day >= 25) || (month == 11 && day <= 2))
    {
        endMonth = 11;
        endDay = 2;
        return SEASON_HALLOWEEN;
    }

    if(month == 11)
    {
        endMonth = 11;
        endDay = 30;
        return SEASON_AUTUMN;
    }

    endYear = year + 1;
    endMonth = 1;
    endDay = 15;
    return SEASON_NEWYEAR;
}

stock Event_GetTimeLeft(dest[], size)
{
    new year, month, day, hour, minute, second;
    getdate(year, month, day);
    gettime(hour, minute, second);

    new daysLeft = Event_DateSerial(gSeasonEndYear, gSeasonEndMonth, gSeasonEndDay)
        - Event_DateSerial(year, month, day);
    if(daysLeft < 0) daysLeft = 0;

    new secondsLeft = daysLeft * 86400
        + (23 - hour) * 3600
        + (59 - minute) * 60
        + (59 - second);

    if(secondsLeft < 0) secondsLeft = 0;

    new d = secondsLeft / 86400;
    new h = (secondsLeft % 86400) / 3600;
    new m = (secondsLeft % 3600) / 60;
    format(dest, size, "%d дн. %02d:%02d", d, h, m);
    return 1;
}

stock Event_GetPlayerFile(playerid, dest[], size)
{
    new name[MAX_PLAYER_NAME + 1], safeName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof(name));

    for(new i = 0; i < strlen(name); i++)
    {
        if((name[i] >= 'a' && name[i] <= 'z')
        || (name[i] >= 'A' && name[i] <= 'Z')
        || (name[i] >= '0' && name[i] <= '9')
        || name[i] == '_')
            safeName[i] = name[i];
        else
            safeName[i] = '_';
    }
    safeName[strlen(name)] = '\0';
    format(dest, size, "SeasonEvent_%s.ini", safeName);
    return 1;
}

stock Event_SavePlayer(playerid)
{
    if(!gPlayerLoaded[playerid]) return 0;

    new path[64], line[64];
    Event_GetPlayerFile(playerid, path, sizeof(path));

    new File:file = fopen(path, io_write);
    if(!file) return 0;

    format(line, sizeof(line), "%d|%d\r\n", gPlayerSeason[playerid], gPlayerEventStage[playerid]);
    fwrite(file, line);
    fclose(file);
    return 1;
}

stock Event_LoadPlayer(playerid)
{
    new path[64], line[64], part[16];
    Event_GetPlayerFile(playerid, path, sizeof(path));

    gPlayerSeason[playerid] = gActiveSeason;
    gPlayerEventStage[playerid] = EVENT_STAGE_NONE;
    gPlayerLoaded[playerid] = true;

    if(fexist(path))
    {
        new File:file = fopen(path, io_read);
        if(file)
        {
            fread(file, line, sizeof(line));
            fclose(file);

            new split = strfind(line, "|", false);
            if(split != -1)
            {
                strmid(part, line, 0, split, sizeof(part));
                gPlayerSeason[playerid] = strval(part);
                strmid(part, line, split + 1, strlen(line), sizeof(part));
                gPlayerEventStage[playerid] = strval(part);
            }
        }
    }

    if(gPlayerSeason[playerid] != gActiveSeason
    || gPlayerEventStage[playerid] < EVENT_STAGE_NONE
    || gPlayerEventStage[playerid] > EVENT_STAGE_COMPLETED)
    {
        gPlayerSeason[playerid] = gActiveSeason;
        gPlayerEventStage[playerid] = EVENT_STAGE_NONE;
        Event_SavePlayer(playerid);
    }
    return 1;
}

stock Event_IsNearNpc(playerid)
{
    if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return 0;

    for(new i = 0; i < EVENT_SPAWN_COUNT; i++)
    {
        if(IsPlayerInRangeOfPoint(playerid, EVENT_INTERACT_DISTANCE,
            gEventSpawnPos[i][0], gEventSpawnPos[i][1], gEventSpawnPos[i][2]))
            return 1;
    }
    return 0;
}

stock Event_FindNearestSpawn(playerid)
{
    new nearest = 0;
    new Float:bestDistance = 1000000.0;

    for(new i = 0; i < EVENT_SPAWN_COUNT; i++)
    {
        new Float:distance = GetPlayerDistanceFromPoint(playerid,
            gEventSpawnPos[i][0], gEventSpawnPos[i][1], gEventSpawnPos[i][2]);
        if(distance < bestDistance)
        {
            bestDistance = distance;
            nearest = i;
        }
    }
    return nearest;
}

stock Event_ClearRoute(playerid)
{
    RemovePlayerMapIcon(playerid, EVENT_MAP_ICON_ID);
    DisablePlayerRaceCheckpoint(playerid);
    return 1;
}

stock Event_SetRoute(playerid)
{
    if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0)
    {
        Event_ClearRoute(playerid);
        return 0;
    }

    new nearest = gStartSpawn[playerid];
    if(nearest < 0 || nearest >= EVENT_SPAWN_COUNT) nearest = Event_FindNearestSpawn(playerid);
    gTargetSpawnOne[playerid] = (nearest + 1 + (gActiveSeason % 3)) % EVENT_SPAWN_COUNT;
    gTargetSpawnTwo[playerid] = (nearest + 2 + (gActiveSeason % 2)) % EVENT_SPAWN_COUNT;
    if(gTargetSpawnTwo[playerid] == gTargetSpawnOne[playerid] || gTargetSpawnTwo[playerid] == nearest)
        gTargetSpawnTwo[playerid] = (gTargetSpawnOne[playerid] + 1) % EVENT_SPAWN_COUNT;
    gTargetSpawnThree[playerid] = (nearest + 4) % EVENT_SPAWN_COUNT;
    if(gTargetSpawnThree[playerid] == gTargetSpawnOne[playerid] || gTargetSpawnThree[playerid] == gTargetSpawnTwo[playerid] || gTargetSpawnThree[playerid] == nearest)
    {
        for(new i = 0; i < EVENT_SPAWN_COUNT; i++)
        {
            if(i != nearest && i != gTargetSpawnOne[playerid] && i != gTargetSpawnTwo[playerid])
            {
                gTargetSpawnThree[playerid] = i;
                break;
            }
        }
    }

    new target = gTargetSpawnOne[playerid];
    if(gPlayerEventStage[playerid] == EVENT_STAGE_SECOND_ROUTE) target = gTargetSpawnTwo[playerid];
    else if(gPlayerEventStage[playerid] == EVENT_STAGE_THIRD_ROUTE) target = gTargetSpawnThree[playerid];
    else if(gPlayerEventStage[playerid] == EVENT_STAGE_RETURN) target = gStartSpawn[playerid];
    else if(gPlayerEventStage[playerid] == EVENT_STAGE_COMPLETED || gPlayerEventStage[playerid] == EVENT_STAGE_NONE)
    {
        Event_ClearRoute(playerid);
        return 1;
    }

    // Show both a map icon and a visible checkpoint for the active objective.
    SetPlayerMapIcon(playerid, EVENT_MAP_ICON_ID,
        gEventSpawnPos[target][0], gEventSpawnPos[target][1], gEventSpawnPos[target][2],
        0, 0xFFE08AFF, MAPICON_GLOBAL_CHECKPOINT);
    SetPlayerRaceCheckpoint(playerid, 0,
        gEventSpawnPos[target][0], gEventSpawnPos[target][1], gEventSpawnPos[target][2],
        0.0, 0.0, 0.0, 5.0);
    return 1;
}

stock Event_CreateGui(playerid)
{
    // Five per-player TextDraws; this avoids global TextDraw limits and cross-player text changes.
    gGuiPanel[playerid] = CreatePlayerTextDraw(playerid, 135.0, 105.0, " ");
    PlayerTextDrawLetterSize(playerid, gGuiPanel[playerid], 0.0, 31.0);
    PlayerTextDrawTextSize(playerid, gGuiPanel[playerid], 505.0, 0.0);
    PlayerTextDrawUseBox(playerid, gGuiPanel[playerid], 1);
    PlayerTextDrawBoxColor(playerid, gGuiPanel[playerid], 0x101923EE);
    PlayerTextDrawColor(playerid, gGuiPanel[playerid], 0xFFFFFFFF);
    PlayerTextDrawSetOutline(playerid, gGuiPanel[playerid], 0);
    PlayerTextDrawSetShadow(playerid, gGuiPanel[playerid], 0);
    PlayerTextDrawFont(playerid, gGuiPanel[playerid], 1);

    gGuiTitle[playerid] = CreatePlayerTextDraw(playerid, 153.0, 117.0, "\xD1\xC5\xC7\xCE\xCD\xCD\xCE\xC5\x20\xD1\xCE\xC1\xDB\xD2\xC8\xC5");
    PlayerTextDrawLetterSize(playerid, gGuiTitle[playerid], 0.32, 1.35);
    PlayerTextDrawTextSize(playerid, gGuiTitle[playerid], 490.0, 18.0);
    PlayerTextDrawColor(playerid, gGuiTitle[playerid], 0xFFD36AFF);
    PlayerTextDrawUseBox(playerid, gGuiTitle[playerid], 1);
    PlayerTextDrawBoxColor(playerid, gGuiTitle[playerid], 0x263747FF);
    PlayerTextDrawSetOutline(playerid, gGuiTitle[playerid], 0);
    PlayerTextDrawSetShadow(playerid, gGuiTitle[playerid], 0);
    PlayerTextDrawFont(playerid, gGuiTitle[playerid], 1);

    gGuiBody[playerid] = CreatePlayerTextDraw(playerid, 154.0, 151.0, "\xC7\xE0\xE3\xF0\xF3\xE7\xEA\xE0\x20\xF1\xEE\xE1\xFB\xF2\xE8\xFF\x2E\x2E\x2E");
    PlayerTextDrawLetterSize(playerid, gGuiBody[playerid], 0.235, 1.12);
    PlayerTextDrawTextSize(playerid, gGuiBody[playerid], 485.0, 0.0);
    PlayerTextDrawColor(playerid, gGuiBody[playerid], 0xEAF1F7FF);
    PlayerTextDrawSetOutline(playerid, gGuiBody[playerid], 0);
    PlayerTextDrawSetShadow(playerid, gGuiBody[playerid], 0);
    PlayerTextDrawFont(playerid, gGuiBody[playerid], 1);

    gGuiAction[playerid] = CreatePlayerTextDraw(playerid, 158.0, 366.0, "\x5B\x20\xCD\xC0\xD7\xC0\xD2\xDC\x20\x5D");
    PlayerTextDrawLetterSize(playerid, gGuiAction[playerid], 0.27, 1.25);
    PlayerTextDrawTextSize(playerid, gGuiAction[playerid], 305.0, 18.0);
    PlayerTextDrawColor(playerid, gGuiAction[playerid], 0x101923FF);
    PlayerTextDrawUseBox(playerid, gGuiAction[playerid], 1);
    PlayerTextDrawBoxColor(playerid, gGuiAction[playerid], 0xFFD36AFF);
    PlayerTextDrawSetOutline(playerid, gGuiAction[playerid], 0);
    PlayerTextDrawSetShadow(playerid, gGuiAction[playerid], 0);
    PlayerTextDrawFont(playerid, gGuiAction[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, gGuiAction[playerid], 1);

    gGuiClose[playerid] = CreatePlayerTextDraw(playerid, 370.0, 366.0, "\x5B\x20\xC7\xC0\xCA\xD0\xDB\xD2\xDC\x20\x5D");
    PlayerTextDrawLetterSize(playerid, gGuiClose[playerid], 0.27, 1.25);
    PlayerTextDrawTextSize(playerid, gGuiClose[playerid], 490.0, 18.0);
    PlayerTextDrawColor(playerid, gGuiClose[playerid], 0xFFFFFFFF);
    PlayerTextDrawUseBox(playerid, gGuiClose[playerid], 1);
    PlayerTextDrawBoxColor(playerid, gGuiClose[playerid], 0x43505FFF);
    PlayerTextDrawSetOutline(playerid, gGuiClose[playerid], 0);
    PlayerTextDrawSetShadow(playerid, gGuiClose[playerid], 0);
    PlayerTextDrawFont(playerid, gGuiClose[playerid], 1);
    PlayerTextDrawSetSelectable(playerid, gGuiClose[playerid], 1);
    return 1;
}

stock Event_CloseGui(playerid)
{
    if(gGuiOpen[playerid])
    {
        gGuiOpen[playerid] = false;
        PlayerTextDrawHide(playerid, gGuiPanel[playerid]);
        PlayerTextDrawHide(playerid, gGuiTitle[playerid]);
        PlayerTextDrawHide(playerid, gGuiBody[playerid]);
        PlayerTextDrawHide(playerid, gGuiAction[playerid]);
        PlayerTextDrawHide(playerid, gGuiClose[playerid]);
        PlayerTextDrawDestroy(playerid, gGuiPanel[playerid]);
        PlayerTextDrawDestroy(playerid, gGuiTitle[playerid]);
        PlayerTextDrawDestroy(playerid, gGuiBody[playerid]);
        PlayerTextDrawDestroy(playerid, gGuiAction[playerid]);
        PlayerTextDrawDestroy(playerid, gGuiClose[playerid]);
    }
    return 1;
}

stock Event_ShowGui(playerid)
{
    if(!gPlayerLoaded[playerid]) Event_LoadPlayer(playerid);
    Event_CloseGui(playerid);
    Event_CreateGui(playerid);

    new timeLeft[32], body[512], title[128], action[48];
    Event_GetTimeLeft(timeLeft, sizeof(timeLeft));
    format(title, sizeof(title), "%s", gSeasonTitle[gActiveSeason]);

    switch(gPlayerEventStage[playerid])
    {
        case EVENT_STAGE_NONE:
        {
            format(body, sizeof(body), "\x25\x73\x0A\x0A\xC7\xC0\xC4\xC0\xCD\xC8\xC5\x3A\x20\x25\x73\x0A\x0A\xCD\xC0\xC3\xD0\xC0\xC4\xC0\x3A\x20\x25\x64\x20\xC5\xC2\xD0\xCE\x0A\xC4\xEE\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE5\xED\xE8\xFF\x3A\x20\x25\x73\x0A\x0A\xCF\xEE\xE4\xEE\xE9\xE4\xE8\x20\xEA\x20\xF1\xE5\xE7\xEE\xED\xED\xEE\xEC\xF3\x20\x4E\x50\x43\x20\xE8\x20\xED\xE0\xF7\xED\xE8\x20\xE8\xF1\xF2\xEE\xF0\xE8\xFE\x2E",
                gSeasonDescription[gActiveSeason], gSeasonQuestStep[gActiveSeason][0], gSeasonReward[gActiveSeason], timeLeft);
            format(action, sizeof(action), "\x5B\x20\xCD\xC0\xD7\xC0\xD2\xDC\x20\xCA\xC2\xC5\xD1\xD2\x20\x5D");
        }
        case EVENT_STAGE_FIRST_ROUTE, EVENT_STAGE_SECOND_ROUTE, EVENT_STAGE_THIRD_ROUTE:
        {
            new step = gPlayerEventStage[playerid] - EVENT_STAGE_FIRST_ROUTE;
            new target = gTargetSpawnOne[playerid];
            if(gPlayerEventStage[playerid] == EVENT_STAGE_SECOND_ROUTE) target = gTargetSpawnTwo[playerid];
            else if(gPlayerEventStage[playerid] == EVENT_STAGE_THIRD_ROUTE) target = gTargetSpawnThree[playerid];
            format(body, sizeof(body), "\x25\x73\x0A\x0A\xD6\xC5\xCB\xDC\x20\x25\x64\x20\xC8\xC7\x20\x33\x0A\x25\x73\x0A\x0A\xC3\xCE\xD0\xCE\xC4\x3A\x20\x25\x73\x0A\xD0\xC0\xC9\xCE\xCD\x3A\x20\x25\x73\x0A\x58\x3A\x20\x25\x2E\x31\x66\x20\x20\x59\x3A\x20\x25\x2E\x31\x66\x0A\x0A\xCF\xEE\xE4\xEE\xE9\xE4\xE8\x20\xEA\x20\xEE\xF2\xEC\xE5\xF2\xEA\xE5\x20\xED\xE0\x20\xEA\xE0\xF0\xF2\xE5\x2E\x20\xCF\xEE\x20\xEF\xF0\xE8\xE1\xFB\xF2\xE8\xFE\x20\xED\xE0\xE6\xEC\xE8\x20\xEA\xED\xEE\xEF\xEA\xF3\x20\xE2\x20\xEC\xE5\xED\xFE\x2E\x0A\xC4\xEE\x20\xEA\xEE\xED\xF6\xE0\x3A\x20\x25\x73",
                gSeasonDescription[gActiveSeason], step + 1, gSeasonQuestStep[gActiveSeason][step],
                gEventSpawnCity[target], gSeasonNpcName[gActiveSeason][target],
                gEventSpawnPos[target][0], gEventSpawnPos[target][1], timeLeft);
            format(action, sizeof(action), "\x5B\x20\xCF\xCE\xC4\xD2\xC2\xC5\xD0\xC4\xC8\xD2\xDC\x20\xD6\xC5\xCB\xDC\x20\x5D");
        }
        case EVENT_STAGE_RETURN:
        {
            new home = gStartSpawn[playerid];
            format(body, sizeof(body), "\xC2\xD1\xC5\x20\xD6\xC5\xCB\xC8\x20\xC2\xDB\xCF\xCE\xCB\xCD\xC5\xCD\xDB\x0A\x0A\x25\x73\x0A\x0A\xC2\xE5\xF0\xED\xE8\xF1\xFC\x20\xE2\x20\xE3\xEE\xF0\xEE\xE4\x3A\x20\x25\x73\x0A\xC2\xE5\xF0\xED\xE8\xF1\xFC\x20\xEA\x20\x25\x73\x0A\x58\x3A\x20\x25\x2E\x31\x66\x20\x20\x59\x3A\x20\x25\x2E\x31\x66\x0A\x0A\xCD\xE0\xE3\xF0\xE0\xE4\xE0\x3A\x20\x25\x64\x20\xE5\xE2\xF0\xEE\x2E\x0A\xC4\xEE\x20\xEA\xEE\xED\xF6\xE0\x3A\x20\x25\x73",
                gSeasonQuestStep[gActiveSeason][2], gEventSpawnCity[home], gSeasonNpcName[gActiveSeason][home],
                gEventSpawnPos[home][0], gEventSpawnPos[home][1], gSeasonReward[gActiveSeason], timeLeft);
            format(action, sizeof(action), "\x5B\x20\xC7\xC0\xC1\xD0\xC0\xD2\xDC\x20\xCD\xC0\xC3\xD0\xC0\xC4\xD3\x20\x5D");
        }
        default:
        {
            format(body, sizeof(body), "\xCA\xC2\xC5\xD1\xD2\x20\xC7\xC0\xC2\xC5\xD0\xD8\xA8\xCD\x0A\x0A\xD2\xFB\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\x20\xE8\xF1\xF2\xEE\xF0\xE8\xFE\x20\xFD\xF2\xEE\xE3\xEE\x20\xF1\xE5\xE7\xEE\xED\xE0\x2E\x0A\xD1\xEB\xE5\xE4\xF3\xFE\xF9\xE5\xE5\x20\xF1\xEE\xE1\xFB\xF2\xE8\xE5\x20\xEF\xF0\xE8\xED\xE5\xF1\xB8\xF2\x20\xED\xEE\xE2\xF3\xFE\x20\xE8\xF1\xF2\xEE\xF0\xE8\xFE\x20\xE8\x20\xE7\xE0\xE4\xE0\xED\xE8\xFF\x2E\x0A\xC4\xEE\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE5\xED\xE8\xFF\x3A\x20\x25\x73", timeLeft);
            format(action, sizeof(action), "\x5B\x20\xC2\xDB\xCF\xCE\xCB\xCD\xC5\xCD\xCE\x20\x5D");
        }
    }

    PlayerTextDrawSetString(playerid, gGuiTitle[playerid], title);
    PlayerTextDrawSetString(playerid, gGuiBody[playerid], body);
    PlayerTextDrawSetString(playerid, gGuiAction[playerid], action);
    PlayerTextDrawShow(playerid, gGuiPanel[playerid]);
    PlayerTextDrawShow(playerid, gGuiTitle[playerid]);
    PlayerTextDrawShow(playerid, gGuiBody[playerid]);
    PlayerTextDrawShow(playerid, gGuiAction[playerid]);
    PlayerTextDrawShow(playerid, gGuiClose[playerid]);
    SelectTextDraw(playerid, 0xFFD36AFF);
    gGuiOpen[playerid] = true;
    return 1;
}

stock Event_Action(playerid)
{
    if(gPlayerEventStage[playerid] == EVENT_STAGE_NONE)
    {
        if(!Event_IsNearNpc(playerid))
        {
            SendClientMessage(playerid, 0xFFE08AFF, "\x5B\xD1\xCE\xC1\xDB\xD2\xC8\xC5\x5D\x20\xCF\xEE\xE4\xEE\xE9\xE4\xE8\x20\xEA\x20\xF1\xE5\xE7\xEE\xED\xED\xEE\xEC\xF3\x20\x4E\x50\x43\x2C\x20\xF7\xF2\xEE\xE1\xFB\x20\xED\xE0\xF7\xE0\xF2\xFC\x20\xEA\xE2\xE5\xF1\xF2\x2E");
            return 1;
        }
        gStartSpawn[playerid] = Event_FindNearestSpawn(playerid);
        gPlayerEventStage[playerid] = EVENT_STAGE_FIRST_ROUTE;
        Event_SetRoute(playerid);
        Event_SavePlayer(playerid);
        SendClientMessage(playerid, 0xFFE08AFF, "\x5B\xD1\xCE\xC1\xDB\xD2\xC8\xC5\x5D\x20\xCA\xE2\xE5\xF1\xF2\x20\xED\xE0\xF7\xE0\xF2\x2E\x20\xD1\xEB\xE5\xE4\xF3\xE9\x20\xE7\xE0\x20\xEE\xF2\xEC\xE5\xF2\xEA\xEE\xE9\x20\xED\xE0\x20\xEA\xE0\xF0\xF2\xE5\x20\xE8\x20\xEF\xEE\xE4\xF2\xE2\xE5\xF0\xE6\xE4\xE0\xE9\x20\xEA\xE0\xE6\xE4\xF3\xFE\x20\xF6\xE5\xEB\xFC\x20\xEA\xEB\xE0\xE2\xE8\xF8\xE5\xE9\x20\x59\x20\xE8\xEB\xE8\x20\xF7\xE5\xF0\xE5\xE7\x20\x2E\x65\x76\x65\x6E\x74\x2E");
        return 1;
    }

    if(gPlayerEventStage[playerid] >= EVENT_STAGE_FIRST_ROUTE && gPlayerEventStage[playerid] <= EVENT_STAGE_THIRD_ROUTE)
    {
        new target = gTargetSpawnOne[playerid];
        if(gPlayerEventStage[playerid] == EVENT_STAGE_SECOND_ROUTE) target = gTargetSpawnTwo[playerid];
        else if(gPlayerEventStage[playerid] == EVENT_STAGE_THIRD_ROUTE) target = gTargetSpawnThree[playerid];

        if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0
        || !IsPlayerInRangeOfPoint(playerid, EVENT_TARGET_DISTANCE,
            gEventSpawnPos[target][0], gEventSpawnPos[target][1], gEventSpawnPos[target][2]))
        {
            SendClientMessage(playerid, 0xFFE08AFF, "\x5B\xD1\xCE\xC1\xDB\xD2\xC8\xC5\x5D\x20\xD2\xFB\x20\xE5\xF9\xB8\x20\xED\xE5\x20\xE4\xEE\xE1\xF0\xE0\xEB\xF1\xFF\x20\xE4\xEE\x20\xEE\xF2\xEC\xE5\xF7\xE5\xED\xED\xEE\xE9\x20\xF6\xE5\xEB\xE8\x2E");
            return 1;
        }

        if(gPlayerEventStage[playerid] == EVENT_STAGE_FIRST_ROUTE)
        {
            gPlayerEventStage[playerid] = EVENT_STAGE_SECOND_ROUTE;
            SendClientMessage(playerid, 0x80FF80FF, "\x5B\xD1\xCE\xC1\xDB\xD2\xC8\xC5\x5D\x20\xD6\xE5\xEB\xFC\x20\x31\x2F\x33\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xE0\x2E\x20\xD1\xEB\xE5\xE4\xF3\xE9\x20\xEA\x20\xF1\xEB\xE5\xE4\xF3\xFE\xF9\xE5\xE9\x20\xEE\xF2\xEC\xE5\xF2\xEA\xE5\x2E");
        }
        else if(gPlayerEventStage[playerid] == EVENT_STAGE_SECOND_ROUTE)
        {
            gPlayerEventStage[playerid] = EVENT_STAGE_THIRD_ROUTE;
            SendClientMessage(playerid, 0x80FF80FF, "\x5B\xD1\xCE\xC1\xDB\xD2\xC8\xC5\x5D\x20\xD6\xE5\xEB\xFC\x20\x32\x2F\x33\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xE0\x2E\x20\xCE\xF1\xF2\xE0\xEB\xEE\xF1\xFC\x20\xEF\xEE\xF1\xEB\xE5\xE4\xED\xE5\xE5\x20\xE7\xE0\xE4\xE0\xED\xE8\xE5\x2E");
        }
        else
        {
            gPlayerEventStage[playerid] = EVENT_STAGE_RETURN;
            SendClientMessage(playerid, 0x80FF80FF, "\x5B\xD1\xCE\xC1\xDB\xD2\xC8\xC5\x5D\x20\xC2\xF1\xE5\x20\xF6\xE5\xEB\xE8\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xFB\x2E\x20\xC2\xE5\xF0\xED\xE8\xF1\xFC\x20\xEA\x20\xF1\xE5\xE7\xEE\xED\xED\xEE\xEC\xF3\x20\x4E\x50\x43\x20\xE7\xE0\x20\xED\xE0\xE3\xF0\xE0\xE4\xEE\xE9\x2E");
        }
        Event_SetRoute(playerid);
        Event_SavePlayer(playerid);
        return 1;
    }

    if(gPlayerEventStage[playerid] == EVENT_STAGE_RETURN)
    {
        if(!Event_IsNearNpc(playerid))
        {
            SendClientMessage(playerid, 0xFFE08AFF, "\x5B\xD1\xCE\xC1\xDB\xD2\xC8\xC5\x5D\x20\xC2\xE5\xF0\xED\xE8\xF1\xFC\x20\xEA\x20\xEB\xFE\xE1\xEE\xEC\xF3\x20\xF1\xE5\xE7\xEE\xED\xED\xEE\xEC\xF3\x20\x4E\x50\x43\x2C\x20\xF7\xF2\xEE\xE1\xFB\x20\xE7\xE0\xE1\xF0\xE0\xF2\xFC\x20\xED\xE0\xE3\xF0\xE0\xE4\xF3\x2E");
            return 1;
        }
        if(!CallRemoteFunction("SeasonEvent_AddEuro", "ii", playerid, gSeasonReward[gActiveSeason]))
        {
            SendClientMessage(playerid, 0xFF6347FF, "\x5B\xD1\xCE\xC1\xDB\xD2\xC8\xC5\x5D\x20\x45\x75\x72\x6F\x53\x79\x73\x74\x65\x6D\x20\xED\xE5\xE4\xEE\xF1\xF2\xF3\xEF\xE5\xED\x20\xE8\xEB\xE8\x20\xE1\xE0\xEB\xE0\xED\xF1\x20\xE5\xF9\xB8\x20\xED\xE5\x20\xE7\xE0\xE3\xF0\xF3\xE6\xE5\xED\x2E\x20\xCD\xE0\xE3\xF0\xE0\xE4\xE0\x20\xEF\xEE\xEA\xE0\x20\xED\xE5\x20\xE2\xFB\xE4\xE0\xED\xE0\x2E");
            return 1;
        }
        gPlayerEventStage[playerid] = EVENT_STAGE_COMPLETED;
        Event_ClearRoute(playerid);
        Event_SavePlayer(playerid);
        new message[128];
        format(message, sizeof(message), "\x5B\xD1\xCE\xC1\xDB\xD2\xC8\xC5\x5D\x20\xCD\xE0\xE3\xF0\xE0\xE4\xE0\x20\xEF\xEE\xEB\xF3\xF7\xE5\xED\xE0\x3A\x20\x25\x64\x20\xE5\xE2\xF0\xEE\x2E", gSeasonReward[gActiveSeason]);
        SendClientMessage(playerid, 0x80FF80FF, message);
        return 1;
    }

    SendClientMessage(playerid, 0xFFE08AFF, "\x5B\xD1\xCE\xC1\xDB\xD2\xC8\xC5\x5D\x20\xD2\xFB\x20\xF3\xE6\xE5\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\x20\xF1\xE5\xE7\xEE\xED\xED\xFB\xE9\x20\xEA\xE2\xE5\xF1\xF2\x2E");
    return 1;
}

stock Event_RefreshWorldLabels()
{
    if(!gWorldCreated) return 1;

    new timeLeft[32], text[256];
    Event_GetTimeLeft(timeLeft, sizeof(timeLeft));

    for(new i = 0; i < EVENT_SPAWN_COUNT; i++)
    {
        format(text, sizeof(text), "{E0B85C}%s\n{FFFFFF}%s\nДо конца: %s\n{A9C4E4}Нажми Y или введи .event",
            gSeasonTitle[gActiveSeason],
            gSeasonNpcName[gActiveSeason][i],
            timeLeft);
        Update3DTextLabelText(gNpcLabel[i], 0xE0B85CFF, text);
    }
    return 1;
}

stock Event_DestroyWorld()
{
    if(!gWorldCreated) return 1;

    for(new i = 0; i < EVENT_SPAWN_COUNT; i++)
    {
        if(gNpcActor[i] != INVALID_ACTOR_ID)
            DestroyActor(gNpcActor[i]);
        Delete3DTextLabel(gNpcLabel[i]);
        gNpcActor[i] = INVALID_ACTOR_ID;
    }
    gWorldCreated = false;
    return 1;
}

stock Event_CreateWorld()
{
    Event_DestroyWorld();

    new text[256];
    new timeLeft[32];
    Event_GetTimeLeft(timeLeft, sizeof(timeLeft));

    for(new i = 0; i < EVENT_SPAWN_COUNT; i++)
    {
        gNpcActor[i] = CreateActor(gSeasonNpcModel[gActiveSeason][i],
            gEventSpawnPos[i][0], gEventSpawnPos[i][1], gEventSpawnPos[i][2],
            gEventSpawnPos[i][3]);

        format(text, sizeof(text), "{E0B85C}%s\n{FFFFFF}%s\nДо конца: %s\n{A9C4E4}Нажми Y или введи .event",
            gSeasonTitle[gActiveSeason],
            gSeasonNpcName[gActiveSeason][i],
            timeLeft);

        gNpcLabel[i] = Create3DTextLabel(text, 0xE0B85CFF,
            gEventSpawnPos[i][0], gEventSpawnPos[i][1], gEventSpawnPos[i][2] + 1.0,
            25.0, 0, 1);
    }

    gWorldCreated = true;
    return 1;
}

stock Event_UpdateSeason()
{
    new endYear, endMonth, endDay;
    new season = Event_GetActiveSeason(endYear, endMonth, endDay);

    gSeasonEndYear = endYear;
    gSeasonEndMonth = endMonth;
    gSeasonEndDay = endDay;

    if(season != gActiveSeason)
    {
        gActiveSeason = season;
        Event_CreateWorld();

        for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
        {
            if(IsPlayerConnected(playerid))
                Event_LoadPlayer(playerid);
        }
    }
    else
    {
        Event_RefreshWorldLabels();
    }
    return 1;
}

public Event_UpdateTimer()
{
    Event_UpdateSeason();
    return 1;
}


public OnFilterScriptInit()
{
    print(" [SeasonEvents] Seasonal GUI filterscript starting...");

    for(new i = 0; i < EVENT_SPAWN_COUNT; i++)
        gNpcActor[i] = INVALID_ACTOR_ID;

    Event_UpdateSeason();
    SetTimer("Event_UpdateTimer", 60000, true);
    

    for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if(IsPlayerConnected(playerid))
        {
            Event_LoadPlayer(playerid);
            gStartSpawn[playerid] = Event_FindNearestSpawn(playerid);
        }
    }

    print(" [SeasonEvents] Загружен. Используй .event рядом с NPC или .eventinfo для просмотра активной цели издалека. Нажми Y рядом с NPC или целью.");
    return 1;
}

public OnFilterScriptExit()
{
    Event_DestroyWorld();

    for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        Event_CloseGui(playerid);
        Event_ClearRoute(playerid);
    }
    print(" [SeasonEvents] Unloaded.");
    return 1;
}

public OnPlayerConnect(playerid)
{
    if(gActiveSeason == -1) Event_UpdateSeason();
    Event_LoadPlayer(playerid);
    gStartSpawn[playerid] = Event_FindNearestSpawn(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason

    Event_SavePlayer(playerid);
    Event_CloseGui(playerid);
    gGuiOpen[playerid] = false;
    gPlayerLoaded[playerid] = false;
    Event_ClearRoute(playerid);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if(gPlayerLoaded[playerid]
    && (gPlayerEventStage[playerid] == EVENT_STAGE_FIRST_ROUTE
    || gPlayerEventStage[playerid] == EVENT_STAGE_SECOND_ROUTE
    || gPlayerEventStage[playerid] == EVENT_STAGE_THIRD_ROUTE
    || gPlayerEventStage[playerid] == EVENT_STAGE_RETURN))
        Event_SetRoute(playerid);

    return 1;
}

stock Event_HandleOpenCommand(playerid, allowProgressAnywhere)
{
    if(!gPlayerLoaded[playerid]) Event_LoadPlayer(playerid);

    // Avoid destroying/recreating the same TextDraws when the player spams the command.
    if(gGuiOpen[playerid]) return 1;

    if(!Event_IsNearNpc(playerid))
    {
        // .eventinfo is a read-only progress command; it never starts or restarts a quest.
        if(allowProgressAnywhere
        && gPlayerEventStage[playerid] >= EVENT_STAGE_FIRST_ROUTE
        && gPlayerEventStage[playerid] <= EVENT_STAGE_RETURN)
        {
            Event_ShowGui(playerid);
            return 1;
        }
        SendClientMessage(playerid, 0xFFE08AFF, "[SEASON] \xCF\xEE\xE4\xEE\xE9\xE4\xE8 \xEA \xF1\xE5\xE7\xEE\xED\xED\xEE\xEC\xF3 NPC. \xC4\xEB\xFF \xEF\xF0\xEE\xE2\xE5\xF0\xEA\xE8 \xF6\xE5\xEB\xE8 \xE2\xE2\xE5\xE4\xE8 .eventinfo.");
        return 1;
    }
    Event_ShowGui(playerid);
    return 1;
}

// Called by EuroSystem's existing dot-command dispatcher, so event commands
// use the same special command path as the rest of this server's dot commands.
public SeasonEvent_Command(playerid, command[])
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(!strcmp(command, "event", true))
    {
        Event_HandleOpenCommand(playerid, 0);
        return 1;
    }
    if(!strcmp(command, "eventinfo", true))
    {
        Event_HandleOpenCommand(playerid, 1);
        return 1;
    }
    return 0;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if((newkeys & KEY_YES) && !(oldkeys & KEY_YES))
    {
        if(Event_IsNearNpc(playerid))
        {
            Event_ShowGui(playerid);
            return 1;
        }
        if(gPlayerEventStage[playerid] >= EVENT_STAGE_FIRST_ROUTE && gPlayerEventStage[playerid] <= EVENT_STAGE_THIRD_ROUTE)
        {
            new target = gTargetSpawnOne[playerid];
            if(gPlayerEventStage[playerid] == EVENT_STAGE_SECOND_ROUTE) target = gTargetSpawnTwo[playerid];
            else if(gPlayerEventStage[playerid] == EVENT_STAGE_THIRD_ROUTE) target = gTargetSpawnThree[playerid];
            if(IsPlayerInRangeOfPoint(playerid, EVENT_TARGET_DISTANCE,
                gEventSpawnPos[target][0], gEventSpawnPos[target][1], gEventSpawnPos[target][2]))
                Event_Action(playerid);
        }
    }
    return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == Text:INVALID_TEXT_DRAW)
    {
        Event_CloseGui(playerid);
        return 1;
    }
    return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(!gGuiOpen[playerid]) return 0;
    if(playertextid == gGuiClose[playerid])
    {
        CancelSelectTextDraw(playerid);
        Event_CloseGui(playerid);
        return 1;
    }
    if(playertextid == gGuiAction[playerid])
    {
        CancelSelectTextDraw(playerid);
        Event_CloseGui(playerid);
        Event_Action(playerid);
        Event_ShowGui(playerid);
        return 1;
    }
    return 0;
}
