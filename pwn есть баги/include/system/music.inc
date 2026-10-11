#if defined _simple_music_system_included
    #endinput
#endif
#define _simple_music_system_included

#define GUI_MUSIC_AUDIO                 9
#define MUSIC_PAGE_SIZE                 4
#define MUSIC_ALBUM_PRICE               249
#define MUSIC_ALBUM_COUNT               0
#define MUSIC_FREE_TRACK_COUNT          51
#define MUSIC_PAID_TRACKS_PER_ALBUM     5
#define MUSIC_TAB_FREE                  0
#define MUSIC_TAB_PREMIUM               1
#define MUSIC_BTN_ITEM_0                0
#define MUSIC_BTN_ITEM_1                1
#define MUSIC_BTN_ITEM_2                2
#define MUSIC_BTN_ITEM_3                3
#define MUSIC_BTN_SEARCH                4
#define MUSIC_BTN_NEXT                  6
#define MUSIC_BTN_PREV                  5
#define MUSIC_BTN_BACK                  7
#define MUSIC_BTN_SEARCH_SEND           8

new musicOn[MAX_PLAYERS];
new g_music_gui_page[MAX_PLAYERS][2];
new g_music_selected_album[MAX_PLAYERS];
new bool:g_music_premium_tracks[MAX_PLAYERS];
new g_music_active_tab[MAX_PLAYERS];
new g_music_active_name[MAX_PLAYERS][96];
new bool:g_music_active_premium[MAX_PLAYERS];
new bool:g_music_db_inited;
new g_music_exit_check_seq[MAX_PLAYERS];
new g_music_search[MAX_PLAYERS][96];
new g_music_visible_track[MAX_PLAYERS][MUSIC_PAGE_SIZE];

stock Music_InitDatabase()
{
    if(g_music_db_inited) return 1;

    mysql_query(mysql, "CREATE TABLE IF NOT EXISTS `music_albums` (`id` INT(11) NOT NULL AUTO_INCREMENT, `uid` INT(11) NOT NULL, `album_id` INT(11) NOT NULL, `created_at` INT(11) NOT NULL DEFAULT 0, PRIMARY KEY (`id`), UNIQUE KEY `uid_album` (`uid`, `album_id`)) ENGINE=InnoDB DEFAULT CHARSET=cp1251;", false);

    g_music_db_inited = true;
    return 1;
}

stock Music_CountPages(total)
{
    if(total <= 0) return 1;
    return (total + MUSIC_PAGE_SIZE - 1) / MUSIC_PAGE_SIZE;
}

stock Music_GetPaidTrackCount(albumid)
{
    #pragma unused albumid
    return 0;
}
stock Music_GetButtonMask(page, max_pages, bool:back_button = false)
{
    new mask = 0;
    if(page < max_pages) mask |= 1;
    if(page > 1) mask |= 2;
    if(back_button) mask |= 4;
    return mask;
}

// Порядок отображения библиотеки отделён от album_id в БД.
// Это сохраняет уже купленные старые альбомы (id 0..5), а новые артисты
stock Music_GetAlbumByDisplayIndex(display_index)
{
    #pragma unused display_index
    return -1;
}
stock Music_GetFreeTrackName(trackid, name[], size = sizeof(name))
{
    switch(trackid)
    {
        case 0: format(name, size, "CMH - прикольььььно");
        case 1: format(name, size, "Lovv66, uglystephan, Nasty Stonem - Трап Трап х Снова обогнал их");
        case 2: format(name, size, "unki - дерьмо (розовое вино remix)");
        case 3: format(name, size, "GENE, Евгений Пищалев - БРИЛЛИАНТЫ");
        case 4: format(name, size, "borya74k - На фуре");
        case 5: format(name, size, "Шайни - Много");
        case 6: format(name, size, "Шайни - Goat (Remix)");
        case 7: format(name, size, "The Limba - Ча Ща");
        case 8: format(name, size, "KRANIN, d3xyy - every day!");
        case 9: format(name, size, "gravis - JUGG (prodhyzxr darkraisocool)");
        case 10: format(name, size, "БОРИК - ТЫЦН-ДЫЦН");
        case 11: format(name, size, "Kagramanov - Танцуй, пантера (Remix, Bass, Slowed)");
        case 12: format(name, size, "BENZIN - Big Baby Tape, Молодой Платон");
        case 13: format(name, size, "dior armani - I love Пикси");
        case 14: format(name, size, "GENE, Евгений Пищалев - ВАСАП");
        case 15: format(name, size, "Пошлая Молли - Беспечный рыцарь тьмы");
        case 16: format(name, size, "gravis, sowhat - barbie!! V2");
        case 17: format(name, size, "JDFLAG - МИША МАERS + БYDY REZATЬ");
        case 18: format(name, size, "Индикция - Коч коч братан");
        case 19: format(name, size, "JDFLAG - TRAFIK - TOASTER");
        case 20: format(name, size, "Lil Tecca, Juice WRLD - Ransom");
        case 21: format(name, size, "Voskresenskii - Стиралка");
        case 22: format(name, size, "Post Malone, Swae Lee - Sunflower (Spider-Man: Into the Spider-Verse)");
        case 23: format(name, size, "Big Baby Tape, kizaru - So Icy Nihao");
        case 24: format(name, size, "huzzy b - любовь война");
        case 25: format(name, size, "kizaru - BABY DRAC");
        case 26: format(name, size, "madk1d - дырки в штанах");
        case 27: format(name, size, "mafanya, дмитрий уткин - face app");
        case 28: format(name, size, "SEREBRO, DJ Sava - Мало Тебя (Savage Remix)");
        case 29: format(name, size, "Ицык Цыпер, Игорь Цыба - Дымок");
        case 30: format(name, size, "Нурминский - Белый 500");
        case 31: format(name, size, "GENE, Евгений Пищалев - ВАСАП");
        case 32: format(name, size, "CMH - RAVE MODE");
        case 33: format(name, size, "White Punk, FRIENDLY THUG 52 NGG - Багажник");
        case 34: format(name, size, "CMH, Молодой Платон - room service");
        case 35: format(name, size, "Big Baby Tape, kizaru - DUO");
        case 36: format(name, size, "42Spinna, Edo Hunnidz - Vip Qazaq");
        case 37: format(name, size, "главный герой, RMW - БРАТИШКА АЗЕР");
        case 38: format(name, size, "Мэйби Бэйби, ЛСП - Клуб");
        case 39: format(name, size, "CMH - FPV FLOW 2029");
        case 40: format(name, size, "madk1d, СМН - ШИПЫ");
        case 41: format(name, size, "JDFLAG - RИLИ ЭМVИПИ");
        case 42: format(name, size, "ПОШЛАЯ МОЛЛИ - Все хотят меня поцеловать");
        case 43: format(name, size, "beksultan - ВАТ ИЗ ЛАВ-Junior");
        case 44: format(name, size, "Guram D, Toxi$ - Забудь");
        case 45: format(name, size, "9mice - ALASKA");
        case 46: format(name, size, "CMH - HYPER LUV");
        case 47: format(name, size, "JDFLAG - RИП RЭП");
        case 48: format(name, size, "6arelyhuman - Faster n Harder");
        case 49: format(name, size, "slayr - Sloppy Joe");
        case 50: format(name, size, "tewiq - снайпер");
        default: format(name, size, "");
    }
    return 1;
}
stock Music_GetFreeTrackUrl(trackid, url[], size = sizeof(url))
{
    switch(trackid)
    {
        case 0: format(url, size, "https://api.kraninshop.ru/music/track-01.mp3");
        case 1: format(url, size, "https://api.kraninshop.ru/music/track-02.mp3");
        case 2: format(url, size, "https://api.kraninshop.ru/music/track-03.mp3");
        case 3: format(url, size, "https://api.kraninshop.ru/music/track-04.mp3");
        case 4: format(url, size, "https://api.kraninshop.ru/music/track-33.mp3");
        case 5: format(url, size, "https://api.kraninshop.ru/music/track-05.mp3");
        case 6: format(url, size, "https://api.kraninshop.ru/music/track-06.mp3");
        case 7: format(url, size, "https://api.kraninshop.ru/music/track-07.mp3");
        case 8: format(url, size, "https://api.kraninshop.ru/music/track-08.mp3");
        case 9: format(url, size, "https://api.kraninshop.ru/music/track-09.mp3");
        case 10: format(url, size, "https://api.kraninshop.ru/music/track-10.mp3");
        case 11: format(url, size, "https://api.kraninshop.ru/music/track-11.mp3");
        case 12: format(url, size, "https://api.kraninshop.ru/music/track-12.mp3");
        case 13: format(url, size, "https://api.kraninshop.ru/music/track-13.mp3");
        case 14: format(url, size, "https://api.kraninshop.ru/music/track-14.mp3");
        case 15: format(url, size, "https://api.kraninshop.ru/music/track-15.mp3");
        case 16: format(url, size, "https://api.kraninshop.ru/music/track-16.mp3");
        case 17: format(url, size, "https://api.kraninshop.ru/music/track-17.mp3");
        case 18: format(url, size, "https://api.kraninshop.ru/music/track-18.mp3");
        case 19: format(url, size, "https://api.kraninshop.ru/music/track-19.mp3");
        case 20: format(url, size, "https://api.kraninshop.ru/music/track-20.mp3");
        case 21: format(url, size, "https://api.kraninshop.ru/music/track-21.mp3");
        case 22: format(url, size, "https://api.kraninshop.ru/music/track-22.mp3");
        case 23: format(url, size, "https://api.kraninshop.ru/music/track-23.mp3");
        case 24: format(url, size, "https://api.kraninshop.ru/music/track-24.mp3");
        case 25: format(url, size, "https://api.kraninshop.ru/music/track-25.mp3");
        case 26: format(url, size, "https://api.kraninshop.ru/music/track-26.mp3");
        case 27: format(url, size, "https://api.kraninshop.ru/music/track-27.mp3");
        case 28: format(url, size, "https://api.kraninshop.ru/music/track-28.mp3");
        case 29: format(url, size, "https://api.kraninshop.ru/music/track-29.mp3");
        case 30: format(url, size, "https://api.kraninshop.ru/music/track-30.mp3");
        case 31: format(url, size, "https://api.kraninshop.ru/music/track-31.mp3");
        case 32: format(url, size, "https://api.kraninshop.ru/music/track-32.mp3");
        case 33: format(url, size, "https://api.kraninshop.ru/music/track-34.mp3");
        case 34: format(url, size, "https://api.kraninshop.ru/music/track-35.mp3");
        case 35: format(url, size, "https://api.kraninshop.ru/music/track-36.mp3");
        case 36: format(url, size, "https://api.kraninshop.ru/music/track-37.mp3");
        case 37: format(url, size, "https://api.kraninshop.ru/music/track-38.mp3");
        case 38: format(url, size, "https://api.kraninshop.ru/music/track-39.mp3");
        case 39: format(url, size, "https://api.kraninshop.ru/music/track-40.mp3");
        case 40: format(url, size, "https://api.kraninshop.ru/music/track-41.mp3");
        case 41: format(url, size, "https://api.kraninshop.ru/music/track-42.mp3");
        case 42: format(url, size, "https://api.kraninshop.ru/music/track-43.mp3");
        case 43: format(url, size, "https://api.kraninshop.ru/music/track-44.mp3");
        case 44: format(url, size, "https://api.kraninshop.ru/music/track-45.mp3");
        case 45: format(url, size, "https://api.kraninshop.ru/music/track-46.mp3");
        case 46: format(url, size, "https://api.kraninshop.ru/music/track-47.mp3");
        case 47: format(url, size, "https://api.kraninshop.ru/music/track-48.mp3");
        case 48: format(url, size, "https://api.kraninshop.ru/music/track-49.mp3");
        case 49: format(url, size, "https://api.kraninshop.ru/music/track-50.mp3");
        case 50: format(url, size, "https://api.kraninshop.ru/music/track-51.mp3");
        default: format(url, size, "");
    }
    return 1;
}
stock Music_GetAlbumName(albumid, name[], size = sizeof(name))
{
    #pragma unused albumid
    format(name, size, "");
    return 1;
}
stock Music_GetPaidTrackName(albumid, trackid, name[], size = sizeof(name))
{
    #pragma unused albumid
    #pragma unused trackid
    format(name, size, "");
    return 1;
}
stock Music_GetPaidTrackUrl(albumid, trackid, url[], size = sizeof(url))
{
    #pragma unused albumid
    #pragma unused trackid
    format(url, size, "");
    return 1;
}
stock bool:Music_PlayerHasAlbum(playerid, albumid)
{
    if(albumid < 0 || albumid >= MUSIC_ALBUM_COUNT) return false;
    if(GetPlayerAccountID(playerid) <= 0) return false;
    Music_InitDatabase();

    new query[160];
    mysql_format(mysql, query, sizeof query,
        "SELECT `id` FROM `music_albums` WHERE `uid`=%d AND `album_id`=%d LIMIT 1",
        GetPlayerAccountID(playerid), albumid);

    new Cache:result = mysql_query(mysql, query, true);
    new bool:owned = (cache_num_rows() > 0);
    cache_delete(result);
    return owned;
}

stock Music_SaveAlbum(playerid, albumid)
{
    if(albumid < 0 || albumid >= MUSIC_ALBUM_COUNT) return 0;
    if(GetPlayerAccountID(playerid) <= 0) return 0;
    Music_InitDatabase();

    new query[192];
    mysql_format(mysql, query, sizeof query,
        "INSERT IGNORE INTO `music_albums` (`uid`, `album_id`, `created_at`) VALUES (%d, %d, %d)",
        GetPlayerAccountID(playerid), albumid, gettime());
    mysql_query(mysql, query, false);
    return 1;
}

stock Music_TakeDonate(playerid, amount)
{
    if(GetPlayerDonateRub(playerid) < amount) return 0;
    GivePlayerDonateRub(playerid, -amount, "Покупка музыкального альбома", true, true);
    return 1;
}


stock Music_ReplaceUrlPart(url[], const search[], const replace[], size)
{
    #pragma unused url
    #pragma unused search
    #pragma unused replace
    #pragma unused size
    return 0;
}
stock Music_NormalizeUrl(const source[], url[], size)
{
    format(url, size, "%s", source);
    return 1;
}
stock Music_Play(playerid, tabid, bool:premium, const track_name[], const url[])
{
    if(strlen(url) < 8)
    {
        SendClientMessage(playerid, -1, ""SC"Ссылка на этот трек не настроена.");
        return 1;
    }

    musicOn[playerid] = 1;
    g_music_active_tab[playerid] = tabid;
    g_music_active_premium[playerid] = premium;
    format(g_music_active_name[playerid], 96, "%s", track_name);

    new stream_url[384];
    Music_NormalizeUrl(url, stream_url, sizeof stream_url);
    PlayAudioStreamURL(playerid, stream_url);

    Action(playerid, "Включил(-а) музыку в транспортном средстве", _, false);

    Music_ShowCurrentTab(playerid);
    return 1;
}

stock Music_PlayFreeTrack(playerid, trackid)
{
    if(trackid < 0 || trackid >= MUSIC_FREE_TRACK_COUNT) return 1;

    new name[96], url[384];
    Music_GetFreeTrackName(trackid, name, sizeof name);
    Music_GetFreeTrackUrl(trackid, url, sizeof url);
    return Music_Play(playerid, MUSIC_TAB_FREE, false, name, url);
}

stock Music_PlayPaidTrack(playerid, albumid, trackid)
{
    if(albumid < 0 || albumid >= MUSIC_ALBUM_COUNT) return 1;
    if(trackid < 0 || trackid >= Music_GetPaidTrackCount(albumid)) return 1;

    if(!Music_PlayerHasAlbum(playerid, albumid))
    {
        new msg[144];
        format(msg, sizeof msg, ""SC"Сначала купите этот альбом/плейлист за {FFFF00}%d доната{FFFFFF}.", MUSIC_ALBUM_PRICE);
        SendClientMessage(playerid, -1, msg);
        g_music_premium_tracks[playerid] = false;
        return Music_ShowPremiumAlbums(playerid);
    }

    new track_name[96], url[384];
    Music_GetPaidTrackName(albumid, trackid, track_name, sizeof track_name);
    Music_GetPaidTrackUrl(albumid, trackid, url, sizeof url);
    return Music_Play(playerid, MUSIC_TAB_PREMIUM, true, track_name, url);
}


stock Music_SendAudioPacket(playerid, Node:json, bool:open_gui = false)
{
    if(open_gui)
    {
        ShowPlayerGUI(playerid, GUI_MUSIC_AUDIO, json);
    }
    else
    {
        OnPacketIncoming(playerid, GUI_MUSIC_AUDIO, json);
    }
    return 1;
}

stock Music_ResendCurrentTab(playerid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(!IsPlayerInAnyVehicle(playerid)) return 1;
    return Music_ShowCurrentTab(playerid, false);
}

forward Music_ResendCurrentTabTimer(playerid);
public Music_ResendCurrentTabTimer(playerid)
{
    return Music_ResendCurrentTab(playerid);
}

stock Music_CountSearchResults(playerid)
{
    new total = 0, name[96];
    for(new trackid = 0; trackid < MUSIC_FREE_TRACK_COUNT; trackid++)
    {
        Music_GetFreeTrackName(trackid, name, sizeof name);
        if(!strlen(g_music_search[playerid]) || strfind(name, g_music_search[playerid], true) != -1) total++;
    }
    return total;
}

stock Music_GetSearchTrack(playerid, index)
{
    new found = 0, name[96];
    for(new trackid = 0; trackid < MUSIC_FREE_TRACK_COUNT; trackid++)
    {
        Music_GetFreeTrackName(trackid, name, sizeof name);
        if(strlen(g_music_search[playerid]) && strfind(name, g_music_search[playerid], true) == -1) continue;
        if(found++ == index) return trackid;
    }
    return -1;
}

stock Music_ShowFreePlaylist(playerid, bool:open_gui = false)
{
    g_music_active_tab[playerid] = MUSIC_TAB_FREE;
    g_music_premium_tracks[playerid] = false;

    new total_tracks = Music_CountSearchResults(playerid);
    new page = g_music_gui_page[playerid][MUSIC_TAB_FREE];
    new max_pages = Music_CountPages(total_tracks);
    if(page < 1) page = 1;
    if(page > max_pages) page = max_pages;
    g_music_gui_page[playerid][MUSIC_TAB_FREE] = page;

    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", 0);
    JSON_SetInt(json, "p", page);
    JSON_SetInt(json, "b", Music_GetButtonMask(page, max_pages, false));
    JSON_SetInt(json, "s", 0);
    JSON_SetString(json, "q", g_music_search[playerid], 96);
    JSON_SetInt(json, "a", g_music_active_tab[playerid]);
    JSON_SetInt(json, "e", g_music_active_premium[playerid] ? 1 : 0);
    JSON_SetString(json, "n", g_music_active_name[playerid], 96);

    new start = (page - 1) * MUSIC_PAGE_SIZE;
    new count = total_tracks - start;
    if(count > MUSIC_PAGE_SIZE) count = MUSIC_PAGE_SIZE;
    if(count < 0) count = 0;
    JSON_SetInt(json, "nu", count);
    JSON_SetInt(json, "c", count);

    new key[8], name[96];
    for(new i = 0; i < MUSIC_PAGE_SIZE; i++) g_music_visible_track[playerid][i] = -1;
    for(new i = 0; i < count; i++)
    {
        new trackid = Music_GetSearchTrack(playerid, start + i);
        g_music_visible_track[playerid][i] = trackid;
        Music_GetFreeTrackName(trackid, name, sizeof name);
        format(key, sizeof key, "r%d", i);
        JSON_SetString(json, key, name, sizeof name);
        format(key, sizeof key, "m%d", i);
        JSON_SetString(json, key, name, sizeof name);
        format(key, sizeof key, "p%d", i);
        JSON_SetInt(json, key, 0);
    }

    Music_SendAudioPacket(playerid, json, open_gui);
    JSON_Cleanup(json);
    return 1;
}
stock Music_ShowPremiumAlbums(playerid, bool:open_gui = false)
{
    // Library root: only albums are shown here. Every album is purchased separately.
    g_music_active_tab[playerid] = MUSIC_TAB_PREMIUM;
    g_music_premium_tracks[playerid] = false;

    new page = g_music_gui_page[playerid][MUSIC_TAB_PREMIUM];
    new max_pages = Music_CountPages(MUSIC_ALBUM_COUNT);
    if(page < 1) page = 1;
    if(page > max_pages) page = max_pages;
    g_music_gui_page[playerid][MUSIC_TAB_PREMIUM] = page;

    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", 1);
    JSON_SetInt(json, "p", page);
    JSON_SetInt(json, "b", Music_GetButtonMask(page, max_pages, false));
    JSON_SetInt(json, "s", 0);
    JSON_SetString(json, "q", g_music_search[playerid], 96);
    JSON_SetInt(json, "a", g_music_active_tab[playerid]);
    JSON_SetInt(json, "e", g_music_active_premium[playerid] ? 1 : 0);
    JSON_SetString(json, "n", g_music_active_name[playerid], 96);

    new start = (page - 1) * MUSIC_PAGE_SIZE;
    new count = MUSIC_ALBUM_COUNT - start;
    if(count > MUSIC_PAGE_SIZE) count = MUSIC_PAGE_SIZE;
    if(count < 0) count = 0;
    JSON_SetInt(json, "nu", count);
    JSON_SetInt(json, "c", count);

    new key[8], album_name[96], item_text[128];
    for(new i = 0; i < count; i++)
    {
        new display_index = start + i;
        new albumid = Music_GetAlbumByDisplayIndex(display_index);
        if(albumid < 0) continue;
        Music_GetAlbumName(albumid, album_name, sizeof album_name);

        if(Music_PlayerHasAlbum(playerid, albumid))
        {
            format(item_text, sizeof item_text, "%s [Куплено]", album_name);
        }
        else
        {
            format(item_text, sizeof item_text, "%s", album_name);
        }

        format(key, sizeof key, "m%d", i);
        JSON_SetString(json, key, item_text, sizeof item_text);

        format(key, sizeof key, "r%d", i);
        JSON_SetInt(json, key, Music_PlayerHasAlbum(playerid, albumid) ? 0 : MUSIC_ALBUM_PRICE);
    }

    Music_SendAudioPacket(playerid, json, open_gui);
    JSON_Cleanup(json);
    return 1;
}

stock Music_ShowPremiumTracks(playerid, albumid, bool:open_gui = false)
{
    if(albumid < 0 || albumid >= MUSIC_ALBUM_COUNT) return Music_ShowPremiumAlbums(playerid);

    // Album view: tracks are visible only after buying this exact album.
    g_music_active_tab[playerid] = MUSIC_TAB_PREMIUM;
    g_music_premium_tracks[playerid] = true;
    g_music_selected_album[playerid] = albumid;

    new page = g_music_gui_page[playerid][MUSIC_TAB_PREMIUM];
    new track_count = Music_GetPaidTrackCount(albumid);
    new max_pages = Music_CountPages(track_count);
    if(page < 1) page = 1;
    if(page > max_pages) page = max_pages;
    g_music_gui_page[playerid][MUSIC_TAB_PREMIUM] = page;

    new album_name[96];
    Music_GetAlbumName(albumid, album_name, sizeof album_name);

    new Node:json = JSON_Object();
    JSON_SetInt(json, "t", 1);
    JSON_SetInt(json, "p", page);
    JSON_SetInt(json, "b", Music_GetButtonMask(page, max_pages, true));
    JSON_SetInt(json, "s", 0);
    JSON_SetString(json, "q", g_music_search[playerid], 96);
    JSON_SetInt(json, "a", g_music_active_tab[playerid]);
    JSON_SetInt(json, "e", g_music_active_premium[playerid] ? 1 : 0);
    JSON_SetString(json, "n", g_music_active_name[playerid], 96);

    new start = (page - 1) * MUSIC_PAGE_SIZE;
    new count = track_count - start;
    if(count > MUSIC_PAGE_SIZE) count = MUSIC_PAGE_SIZE;
    if(count < 0) count = 0;
    JSON_SetInt(json, "nu", count);
    JSON_SetInt(json, "c", count);

    new key[8], track_name[96], item_text[128];
    for(new i = 0; i < count; i++)
    {
        Music_GetPaidTrackName(albumid, start + i, track_name, sizeof track_name);
        format(item_text, sizeof item_text, "%s", track_name);

        format(key, sizeof key, "m%d", i);
        JSON_SetString(json, key, item_text, sizeof item_text);

        format(key, sizeof key, "r%d", i);
        JSON_SetInt(json, key, 0);
    }

    Music_SendAudioPacket(playerid, json, open_gui);
    JSON_Cleanup(json);
    return 1;
}

stock Music_ShowCurrentTab(playerid, bool:open_gui = false)
{
    if(g_music_gui_page[playerid][MUSIC_TAB_FREE] < 1) g_music_gui_page[playerid][MUSIC_TAB_FREE] = 1;
    if(g_music_gui_page[playerid][MUSIC_TAB_PREMIUM] < 1) g_music_gui_page[playerid][MUSIC_TAB_PREMIUM] = 1;

    if(g_music_active_tab[playerid] == MUSIC_TAB_PREMIUM)
    {
        if(g_music_premium_tracks[playerid]) return Music_ShowPremiumTracks(playerid, g_music_selected_album[playerid], open_gui);
        return Music_ShowPremiumAlbums(playerid, open_gui);
    }
    return Music_ShowFreePlaylist(playerid, open_gui);
}

stock Music_OpenGUI(playerid)
{
    Music_InitDatabase();

    if(!IsPlayerInAnyVehicle(playerid))
    {
        SendClientMessage(playerid, -1, ""SC"Включение {FFFF00}музыки {FFFFFF}доступно только в {FFFF00}транспорте");
        return 1;
    }

    g_music_gui_page[playerid][MUSIC_TAB_FREE] = 1;
    g_music_gui_page[playerid][MUSIC_TAB_PREMIUM] = 1;
    g_music_premium_tracks[playerid] = false;
    g_music_selected_album[playerid] = 0;
    g_music_active_tab[playerid] = MUSIC_TAB_FREE;

    Music_ShowFreePlaylist(playerid, true);

    // GUI case 9 иногда создаётся на клиенте чуть позже, чем приходит первый пакет.
    // Поэтому отправляем список повторно уже без флага открытия окна.
    SetTimerEx("Music_ResendCurrentTabTimer", 350, false, "i", playerid);
    SetTimerEx("Music_ResendCurrentTabTimer", 1000, false, "i", playerid);
    return 1;
}

stock Music_Stop(playerid)
{
    if(musicOn[playerid] == 0)
    {
        ShowNotificationNew(playerid, 2, 6, 0, 0, "Музыка не включена", "");
        return 1;
    }

    StopAudioStream(playerid);
    musicOn[playerid] = 0;
    g_music_active_tab[playerid] = MUSIC_TAB_FREE;
    g_music_active_premium[playerid] = false;
    g_music_active_name[playerid][0] = EOS;
    ShowNotificationNew(playerid, 3, 6, 0, 0, "Музыка выключена", "");
    Action(playerid, "Выключил(-а) музыку в транспортном средстве", _, false);
    return Music_ShowCurrentTab(playerid);
}

stock Music_HandlePremiumAlbumClick(playerid, albumid)
{
    if(albumid < 0 || albumid >= MUSIC_ALBUM_COUNT) return 1;

    if(Music_PlayerHasAlbum(playerid, albumid))
    {
        g_music_gui_page[playerid][MUSIC_TAB_PREMIUM] = 1;
        return Music_ShowPremiumTracks(playerid, albumid);
    }

    if(!Music_TakeDonate(playerid, MUSIC_ALBUM_PRICE))
    {
        new msg[144];
        format(msg, sizeof msg, ""SC"Недостаточно доната. Нужно {FFFF00}%d доната{FFFFFF}, у вас {FFFF00}%d{FFFFFF}.", MUSIC_ALBUM_PRICE, GetPlayerDonateRub(playerid));
        SendClientMessage(playerid, -1, msg);
        return Music_ShowPremiumAlbums(playerid);
    }

    Music_SaveAlbum(playerid, albumid);

    new album_name[96], msg[160];
    Music_GetAlbumName(albumid, album_name, sizeof album_name);
    format(msg, sizeof msg, ""SC"Вы купили альбом/плейлист {FFFF00}%s {FFFFFF}за {FFFF00}%d доната{FFFFFF}.", album_name, MUSIC_ALBUM_PRICE);
    SendClientMessage(playerid, -1, msg);

    g_music_gui_page[playerid][MUSIC_TAB_PREMIUM] = 1;
    return Music_ShowPremiumTracks(playerid, albumid);
}

stock Music_OnAudioGuiPacket(playerid, Node:json)
{
    new action;
    JSON_GetInt(json, "t", action);

    switch(action)
    {
        case 0:
        {
            // Закрытие GUI клиентом. Музыку не выключаем, чтобы она продолжала играть.
            return 1;
        }
        case 1:
        {
            new tab;
            JSON_GetInt(json, "b", tab);

            if(tab == MUSIC_TAB_PREMIUM)
            {
                g_music_active_tab[playerid] = MUSIC_TAB_PREMIUM;
                g_music_premium_tracks[playerid] = false;
                g_music_gui_page[playerid][MUSIC_TAB_PREMIUM] = 1;
                return Music_ShowPremiumAlbums(playerid);
            }

            g_music_active_tab[playerid] = MUSIC_TAB_FREE;
            g_music_premium_tracks[playerid] = false;
            return Music_ShowFreePlaylist(playerid);
        }
        case 2:
        {
            new tab, button;
            JSON_GetInt(json, "a", tab);
            JSON_GetInt(json, "b", button);

            // Do not trust tab value from client for item clicks/navigation.
            // This prevents radio buttons from being treated as paid library albums.
            tab = g_music_active_tab[playerid];

            if(button == MUSIC_BTN_NEXT)
            {
                if(tab == MUSIC_TAB_PREMIUM) g_music_gui_page[playerid][MUSIC_TAB_PREMIUM]++;
                else g_music_gui_page[playerid][MUSIC_TAB_FREE]++;

                if(tab == MUSIC_TAB_PREMIUM)
                {
                    if(g_music_premium_tracks[playerid]) return Music_ShowPremiumTracks(playerid, g_music_selected_album[playerid]);
                    return Music_ShowPremiumAlbums(playerid);
                }
                return Music_ShowFreePlaylist(playerid);
            }

            if(button == MUSIC_BTN_PREV)
            {
                if(tab == MUSIC_TAB_PREMIUM && g_music_gui_page[playerid][MUSIC_TAB_PREMIUM] > 1) g_music_gui_page[playerid][MUSIC_TAB_PREMIUM]--;
                else if(tab == MUSIC_TAB_FREE && g_music_gui_page[playerid][MUSIC_TAB_FREE] > 1) g_music_gui_page[playerid][MUSIC_TAB_FREE]--;

                if(tab == MUSIC_TAB_PREMIUM)
                {
                    if(g_music_premium_tracks[playerid]) return Music_ShowPremiumTracks(playerid, g_music_selected_album[playerid]);
                    return Music_ShowPremiumAlbums(playerid);
                }
                return Music_ShowFreePlaylist(playerid);
            }

            if(button == MUSIC_BTN_BACK)
            {
                if(tab == MUSIC_TAB_PREMIUM)
                {
                    g_music_premium_tracks[playerid] = false;
                    g_music_gui_page[playerid][MUSIC_TAB_PREMIUM] = 1;
                    return Music_ShowPremiumAlbums(playerid);
                }
                return Music_ShowFreePlaylist(playerid);
            }

            if(button == MUSIC_BTN_SEARCH || button == MUSIC_BTN_SEARCH_SEND)
            {
                if(tab == MUSIC_TAB_FREE)
                {
                    new search[96];
                    JSON_GetString(json, "s", search, sizeof search);
                    if(!strlen(search)) JSON_GetString(json, "q", search, sizeof search);
                    if(!strlen(search)) JSON_GetString(json, "text", search, sizeof search);
                    format(g_music_search[playerid], sizeof g_music_search[], "%s", search);
                    g_music_gui_page[playerid][MUSIC_TAB_FREE] = 1;
                    return Music_ShowFreePlaylist(playerid);
                }
                if(g_music_premium_tracks[playerid]) return Music_ShowPremiumTracks(playerid, g_music_selected_album[playerid]);
                return Music_ShowPremiumAlbums(playerid);
            }
            if(button >= 0 && button < MUSIC_PAGE_SIZE)
            {
                if(tab == MUSIC_TAB_PREMIUM)
                {
                    new offset = (g_music_gui_page[playerid][MUSIC_TAB_PREMIUM] - 1) * MUSIC_PAGE_SIZE + button;

                    if(g_music_premium_tracks[playerid])
                    {
                        return Music_PlayPaidTrack(playerid, g_music_selected_album[playerid], offset);
                    }

                    new albumid = Music_GetAlbumByDisplayIndex(offset);
                    if(albumid < 0) return Music_ShowPremiumAlbums(playerid);
                    return Music_HandlePremiumAlbumClick(playerid, albumid);
                }

                new trackid = g_music_visible_track[playerid][button];
                return Music_PlayFreeTrack(playerid, trackid);
            }
        }
    }
    return 1;
}






public Music_OnVehicleExit(playerid)
{
    if(musicOn[playerid] == 0) return 1;
    StopAudioStream(playerid);
    musicOn[playerid] = 0;
    g_music_active_tab[playerid] = MUSIC_TAB_FREE;
    g_music_active_premium[playerid] = false;
    g_music_active_name[playerid][0] = EOS;
    return 1;
}

