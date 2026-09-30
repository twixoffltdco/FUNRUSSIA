/*
	music.pwn - Музыка / Радио (GUI как в Black Russia)
	====================================================
	Настоящий GUI на TextDraw, не диалоги.
	Пассажиры слышат ту же музыку.
	Плейлисты из scriptfiles/music/ обновляются при открытии меню.
	Без sscanf, без MySQL, без варнингов.

	Команды: /music  /radio  /musicgui  /music stop
*/

#define FILTERSCRIPT
#include <a_samp>

#define MUSIC_MAX_STATIONS      50
#define MUSIC_MAX_TRACKS        100
#define MUSIC_MAX_NAME          48
#define MUSIC_MAX_URL           160

#define MUSIC_COLOR_BG          0x0D0D12EE
#define MUSIC_COLOR_PANEL       0x1A1A24F0
#define MUSIC_COLOR_ACCENT      0x2ECC71FF
#define MUSIC_COLOR_ACCENT2     0xF1C40FFF
#define MUSIC_COLOR_TEXT        0xFFFFFFFF
#define MUSIC_COLOR_DIM         0x999999FF
#define MUSIC_COLOR_BTN         0x252532FF
#define MUSIC_COLOR_BTN_ON      0x2ECC71FF

#define MUSIC_MAX_LIST          12

enum E_STATION
{
	stName[MUSIC_MAX_NAME],
	stUrl[MUSIC_MAX_URL]
}
new g_Stations[MUSIC_MAX_STATIONS][E_STATION];
new g_StationCount;

enum E_TRACK
{
	trName[MUSIC_MAX_NAME],
	trUrl[MUSIC_MAX_URL],
	trPlaylist[32]
}
new g_Tracks[MUSIC_MAX_TRACKS][E_TRACK];
new g_TrackCount;

new bool:g_MusicPlaying[MAX_PLAYERS];
new g_MusicUrl[MAX_PLAYERS][MUSIC_MAX_URL];
new g_MusicTitle[MAX_PLAYERS][MUSIC_MAX_NAME];
new g_PlayerVehicle[MAX_PLAYERS];

// GUI state
new bool:g_GUIOpen[MAX_PLAYERS];
new g_GUIPage[MAX_PLAYERS];          // 0=main, 1=radio, 2=tracks
new g_GUIScroll[MAX_PLAYERS];
new g_GUISelected[MAX_PLAYERS];

// Global TextDraw
new Text:g_TD_Bg;
new Text:g_TD_Header;
new Text:g_TD_Title;
new Text:g_TD_Close;
new Text:g_TD_NowPlaying;
new Text:g_TD_BtnRadio;
new Text:g_TD_BtnTracks;
new Text:g_TD_BtnStop;
new Text:g_TD_BtnBack;
new Text:g_TD_ListBg[MUSIC_MAX_LIST];
new Text:g_TD_ListItem[MUSIC_MAX_LIST];
new Text:g_TD_ScrollUp;
new Text:g_TD_ScrollDown;
new Text:g_TD_Hint;

// -------------------- DATA --------------------
stock Music_ClearAll()
{
	g_StationCount = 0;
	g_TrackCount = 0;
}

stock Music_AddStation(name[], url[])
{
	if (g_StationCount >= MUSIC_MAX_STATIONS) return 0;
	format(g_Stations[g_StationCount][stName], MUSIC_MAX_NAME, "%s", name);
	format(g_Stations[g_StationCount][stUrl], MUSIC_MAX_URL, "%s", url);
	g_StationCount++;
	return 1;
}

stock Music_AddTrack(name[], url[], playlist[])
{
	if (g_TrackCount >= MUSIC_MAX_TRACKS) return 0;
	format(g_Tracks[g_TrackCount][trName], MUSIC_MAX_NAME, "%s", name);
	format(g_Tracks[g_TrackCount][trUrl], MUSIC_MAX_URL, "%s", url);
	format(g_Tracks[g_TrackCount][trPlaylist], 32, "%s", playlist);
	g_TrackCount++;
	return 1;
}

stock Music_LoadDefaults()
{
	// === РАДИО (рабочие потоки) ===
	Music_AddStation("Evropa Plus", "http://ep128.hostingradio.ru:8030/ep128");
	Music_AddStation("Evropa Plus Top 40", "http://eptop128.streamr.ru/");
	Music_AddStation("Evropa Plus Fresh", "http://mp3128.fresh.streamr.ru/");
	Music_AddStation("Radio Record", "https://radiorecord.hostingradio.ru/rr_main96.aacp");
	Music_AddStation("Record Russian Mix", "https://radiorecord.hostingradio.ru/rus96.aacp");
	Music_AddStation("Record Dubstep", "https://radiorecord.hostingradio.ru/dub96.aacp");
	Music_AddStation("Record Chill-Out", "https://radiorecord.hostingradio.ru/chil96.aacp");
	Music_AddStation("Record Hardstyle", "https://radiorecord.hostingradio.ru/teo96.aacp");
	Music_AddStation("Record Phonk", "https://radiorecord.hostingradio.ru/phonk96.aacp");
	Music_AddStation("Record Trap", "https://radiorecord.hostingradio.ru/trap96.aacp");
	Music_AddStation("Record Deep", "https://radiorecord.hostingradio.ru/deep96.aacp");
	Music_AddStation("Record Hard Bass", "https://radiorecord.hostingradio.ru/hbass96.aacp");
	Music_AddStation("Record Future House", "https://radiorecord.hostingradio.ru/fut96.aacp");
	Music_AddStation("Record 90s", "https://radiorecord.hostingradio.ru/sd9096.aacp");
	Music_AddStation("DFM", "https://dfm.hostingradio.ru/dfm96.aacp");
	Music_AddStation("Energy", "http://ic6.101.ru:8000/stream/air/aac/64/99");
	Music_AddStation("Avtoradio", "https://pub0101.101.ru:8000/stream/air/aac/64/100");
	Music_AddStation("Retro FM", "http://retroserver.streamr.ru:8043/retro256.mp3");
	Music_AddStation("Russkoe Radio", "https://rusradio.hostingradio.ru/rusradio96.aacp");
	Music_AddStation("Nashe Radio", "https://nashe1.hostingradio.ru/nashe-128.mp3");
	Music_AddStation("Shanson", "http://chanson.hostingradio.ru:8041/chanson128.mp3");
	Music_AddStation("Dorozhnoe", "https://dorognoe.hostingradio.ru/radio");
	Music_AddStation("Humor FM", "https://pub0101.101.ru:8000/stream/air/aac/64/102");
	Music_AddStation("Relax FM", "https://pub0302.101.ru:8443/stream/air/aac/64/200");
	Music_AddStation("Like FM", "https://pub0101.101.ru:8000/stream/air/aac/64/198");
	Music_AddStation("Maximum", "https://maximum.hostingradio.ru/maximum96.aacp");
	Music_AddStation("Comedy Radio", "http://ic7.101.ru:8000/stream/air/aac/64/202");
	Music_AddStation("Zaycev FM Pop", "https://zaycevfm.cdnvideo.ru/ZaycevFM_pop_128.mp3");
	Music_AddStation("Zaycev FM RnB", "https://zaycevfm.cdnvideo.ru/ZaycevFM_rnb_128.mp3");
	Music_AddStation("Zaycev FM Club", "https://zaycevfm.cdnvideo.ru/ZaycevFM_club_128.mp3");
	Music_AddStation("Novoe Radio", "https://stream.newradio.ru/nr128.aacp");

	// === ПЛЕЙЛИСТЫ (жанровые потоки - реально играют русский рэп/поп) ===
	Music_AddTrack("Russian Mix 24/7", "https://radiorecord.hostingradio.ru/rus96.aacp", "Morgenshtern");
	Music_AddTrack("Hip-Hop Russia", "https://radiorecord.hostingradio.ru/rus96.aacp", "Morgenshtern");
	Music_AddTrack("Rap Non-Stop", "https://zaycevfm.cdnvideo.ru/ZaycevFM_rnb_128.mp3", "Morgenshtern");
	Music_AddTrack("Pop Hits", "https://zaycevfm.cdnvideo.ru/ZaycevFM_pop_128.mp3", "Instasamka");
	Music_AddTrack("Dance Pop", "https://radiorecord.hostingradio.ru/rr_main96.aacp", "Instasamka");
	Music_AddTrack("Club Hits", "https://zaycevfm.cdnvideo.ru/ZaycevFM_club_128.mp3", "Instasamka");
	Music_AddTrack("Phonk Drift", "https://radiorecord.hostingradio.ru/phonk96.aacp", "Phonk");
	Music_AddTrack("Hard Bass", "https://radiorecord.hostingradio.ru/hbass96.aacp", "HardBass");
	Music_AddTrack("Trap", "https://radiorecord.hostingradio.ru/trap96.aacp", "Trap");
	Music_AddTrack("Deep House", "https://radiorecord.hostingradio.ru/deep96.aacp", "Deep");
	Music_AddTrack("Lo-Fi Chill", "https://radiorecord.hostingradio.ru/lofi96.aacp", "LoFi");
	Music_AddTrack("90s Disco", "https://radiorecord.hostingradio.ru/sd9096.aacp", "90s");
	Music_AddTrack("Dubstep", "https://radiorecord.hostingradio.ru/dub96.aacp", "Electronic");
	Music_AddTrack("Future House", "https://radiorecord.hostingradio.ru/fut96.aacp", "Electronic");
}

stock Music_LoadFromFile(filename[], isStation)
{
	new File:f = fopen(filename, io_read);
	if (!f) return 0;

	new line[256], name[MUSIC_MAX_NAME], url[MUSIC_MAX_URL];
	new playlist[32];
	playlist[0] = EOS;

	if (!isStation)
	{
		new fname[64];
		format(fname, sizeof(fname), "%s", filename);
		new pos = 0, i;
		for (i = strlen(fname) - 1; i >= 0; i--)
		{
			if (fname[i] == '/' || fname[i] == '\\') { pos = i + 1; break; }
		}
		new start = pos;
		if (!strcmp(fname[start], "playlist_", true, 9)) start += 9;
		new len = strlen(fname) - start;
		if (len > 4) len -= 4;
		if (len > 31) len = 31;
		if (len < 0) len = 0;
		for (i = 0; i < len; i++) playlist[i] = fname[start + i];
		playlist[len] = EOS;
		if (!playlist[0]) format(playlist, sizeof(playlist), "Custom");
	}

	while (fread(f, line))
	{
		new len = strlen(line);
		while (len > 0 && (line[len-1] == '\r' || line[len-1] == '\n' || line[len-1] == ' '))
		{
			line[len-1] = EOS;
			len--;
		}
		if (len < 3) continue;
		if (line[0] == ';' || line[0] == '#') continue;

		new eq = -1;
		for (new j = 0; j < len; j++)
		{
			if (line[j] == '=') { eq = j; break; }
		}
		if (eq <= 0) continue;

		new nlen = eq;
		if (nlen >= MUSIC_MAX_NAME) nlen = MUSIC_MAX_NAME - 1;
		for (new j = 0; j < nlen; j++) name[j] = line[j];
		name[nlen] = EOS;

		new ustart = eq + 1;
		while (line[ustart] == ' ') ustart++;
		new ulen = len - ustart;
		if (ulen >= MUSIC_MAX_URL) ulen = MUSIC_MAX_URL - 1;
		if (ulen < 0) ulen = 0;
		for (new j = 0; j < ulen; j++) url[j] = line[ustart + j];
		url[ulen] = EOS;

		if (!name[0] || !url[0]) continue;

		if (isStation) Music_AddStation(name, url);
		else Music_AddTrack(name, url, playlist);
	}
	fclose(f);
	return 1;
}

stock Music_LoadAll()
{
	Music_ClearAll();
	Music_LoadDefaults();

	if (fexist("music/radio.ini"))
		Music_LoadFromFile("music/radio.ini", 1);

	new files[10][] = {
		"music/playlist_Morgenshtern.ini",
		"music/playlist_Instasamka.ini",
		"music/playlist_Phonk.ini",
		"music/playlist_Custom.ini",
		"music/playlist_hits.ini",
		"music/playlist_1.ini",
		"music/playlist_2.ini",
		"music/playlist_3.ini",
		"music/playlist_Мои.ini",
		"music/playlist_custom.ini"
	};

	for (new i = 0; i < sizeof(files); i++)
	{
		if (fexist(files[i]))
			Music_LoadFromFile(files[i], 0);
	}
	return 1;
}

// -------------------- PLAY --------------------
stock Music_PlayForPlayer(playerid, url[], title[])
{
	if (!IsPlayerConnected(playerid)) return 0;
	StopAudioStreamForPlayer(playerid);
	PlayAudioStreamForPlayer(playerid, url);
	g_MusicPlaying[playerid] = true;
	format(g_MusicUrl[playerid], MUSIC_MAX_URL, "%s", url);
	format(g_MusicTitle[playerid], MUSIC_MAX_NAME, "%s", title);

	new msg[144];
	format(msg, sizeof(msg), "[Музыка] Сейчас играет: %s", title);
	SendClientMessage(playerid, MUSIC_COLOR_ACCENT, msg);
	return 1;
}

stock Music_StopForPlayer(playerid)
{
	if (!IsPlayerConnected(playerid)) return 0;
	StopAudioStreamForPlayer(playerid);
	g_MusicPlaying[playerid] = false;
	g_MusicUrl[playerid][0] = EOS;
	g_MusicTitle[playerid][0] = EOS;
	g_PlayerVehicle[playerid] = 0;
	SendClientMessage(playerid, MUSIC_COLOR_DIM, "[Музыка] Остановлено.");
	return 1;
}

stock Music_PlayInVehicle(playerid, url[], title[])
{
	new vid = GetPlayerVehicleID(playerid);
	if (vid == 0)
	{
		Music_PlayForPlayer(playerid, url, title);
		g_PlayerVehicle[playerid] = 0;
		return 1;
	}
	g_PlayerVehicle[playerid] = vid;
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if (!IsPlayerConnected(i)) continue;
		if (GetPlayerVehicleID(i) != vid) continue;
		Music_PlayForPlayer(i, url, title);
		g_PlayerVehicle[i] = vid;
	}
	return 1;
}

// -------------------- GUI CREATE --------------------
stock MusicGUI_Create()
{
	g_TD_Bg = TextDrawCreate(140.0, 100.0, "_");
	TextDrawUseBox(g_TD_Bg, 1);
	TextDrawBoxColor(g_TD_Bg, MUSIC_COLOR_BG);
	TextDrawLetterSize(g_TD_Bg, 0.0, 28.0);
	TextDrawTextSize(g_TD_Bg, 500.0, 0.0);

	g_TD_Header = TextDrawCreate(140.0, 100.0, "_");
	TextDrawUseBox(g_TD_Header, 1);
	TextDrawBoxColor(g_TD_Header, MUSIC_COLOR_PANEL);
	TextDrawLetterSize(g_TD_Header, 0.0, 1.5);
	TextDrawTextSize(g_TD_Header, 500.0, 0.0);

	g_TD_Title = TextDrawCreate(150.0, 104.0, "МУЗЫКА / РАДИО");
	TextDrawFont(g_TD_Title, 2);
	TextDrawLetterSize(g_TD_Title, 0.32, 1.4);
	TextDrawColor(g_TD_Title, MUSIC_COLOR_ACCENT2);
	TextDrawSetOutline(g_TD_Title, 1);

	g_TD_Close = TextDrawCreate(470.0, 104.0, "X");
	TextDrawFont(g_TD_Close, 2);
	TextDrawLetterSize(g_TD_Close, 0.35, 1.3);
	TextDrawColor(g_TD_Close, 0xFF5555FF);
	TextDrawSetOutline(g_TD_Close, 1);
	TextDrawTextSize(g_TD_Close, 490.0, 15.0);
	TextDrawSetSelectable(g_TD_Close, 1);

	g_TD_NowPlaying = TextDrawCreate(150.0, 125.0, "Не играет");
	TextDrawFont(g_TD_NowPlaying, 1);
	TextDrawLetterSize(g_TD_NowPlaying, 0.20, 1.0);
	TextDrawColor(g_TD_NowPlaying, MUSIC_COLOR_ACCENT);

	// Buttons
	g_TD_BtnRadio = TextDrawCreate(150.0, 145.0, " РАДИО ");
	TextDrawFont(g_TD_BtnRadio, 2);
	TextDrawLetterSize(g_TD_BtnRadio, 0.25, 1.2);
	TextDrawColor(g_TD_BtnRadio, MUSIC_COLOR_TEXT);
	TextDrawUseBox(g_TD_BtnRadio, 1);
	TextDrawBoxColor(g_TD_BtnRadio, MUSIC_COLOR_BTN);
	TextDrawTextSize(g_TD_BtnRadio, 230.0, 15.0);
	TextDrawSetSelectable(g_TD_BtnRadio, 1);

	g_TD_BtnTracks = TextDrawCreate(240.0, 145.0, " ТРЕКИ ");
	TextDrawFont(g_TD_BtnTracks, 2);
	TextDrawLetterSize(g_TD_BtnTracks, 0.25, 1.2);
	TextDrawColor(g_TD_BtnTracks, MUSIC_COLOR_TEXT);
	TextDrawUseBox(g_TD_BtnTracks, 1);
	TextDrawBoxColor(g_TD_BtnTracks, MUSIC_COLOR_BTN);
	TextDrawTextSize(g_TD_BtnTracks, 320.0, 15.0);
	TextDrawSetSelectable(g_TD_BtnTracks, 1);

	g_TD_BtnStop = TextDrawCreate(330.0, 145.0, " СТОП ");
	TextDrawFont(g_TD_BtnStop, 2);
	TextDrawLetterSize(g_TD_BtnStop, 0.25, 1.2);
	TextDrawColor(g_TD_BtnStop, MUSIC_COLOR_TEXT);
	TextDrawUseBox(g_TD_BtnStop, 1);
	TextDrawBoxColor(g_TD_BtnStop, MUSIC_COLOR_BTN);
	TextDrawTextSize(g_TD_BtnStop, 400.0, 15.0);
	TextDrawSetSelectable(g_TD_BtnStop, 1);

	g_TD_BtnBack = TextDrawCreate(410.0, 145.0, " НАЗАД ");
	TextDrawFont(g_TD_BtnBack, 2);
	TextDrawLetterSize(g_TD_BtnBack, 0.22, 1.2);
	TextDrawColor(g_TD_BtnBack, MUSIC_COLOR_TEXT);
	TextDrawUseBox(g_TD_BtnBack, 1);
	TextDrawBoxColor(g_TD_BtnBack, MUSIC_COLOR_BTN);
	TextDrawTextSize(g_TD_BtnBack, 480.0, 15.0);
	TextDrawSetSelectable(g_TD_BtnBack, 1);

	// List items
	new Float:y = 175.0;
	for (new i = 0; i < MUSIC_MAX_LIST; i++)
	{
		g_TD_ListBg[i] = TextDrawCreate(150.0, y, "_");
		TextDrawUseBox(g_TD_ListBg[i], 1);
		TextDrawBoxColor(g_TD_ListBg[i], MUSIC_COLOR_PANEL);
		TextDrawLetterSize(g_TD_ListBg[i], 0.0, 1.15);
		TextDrawTextSize(g_TD_ListBg[i], 480.0, 0.0);
		TextDrawSetSelectable(g_TD_ListBg[i], 1);

		g_TD_ListItem[i] = TextDrawCreate(155.0, y + 2.0, " ");
		TextDrawFont(g_TD_ListItem[i], 1);
		TextDrawLetterSize(g_TD_ListItem[i], 0.22, 1.05);
		TextDrawColor(g_TD_ListItem[i], MUSIC_COLOR_TEXT);
		TextDrawTextSize(g_TD_ListItem[i], 475.0, 12.0);
		TextDrawSetSelectable(g_TD_ListItem[i], 1);

		y += 18.0;
	}

	g_TD_ScrollUp = TextDrawCreate(485.0, 175.0, "^");
	TextDrawFont(g_TD_ScrollUp, 2);
	TextDrawLetterSize(g_TD_ScrollUp, 0.3, 1.2);
	TextDrawColor(g_TD_ScrollUp, MUSIC_COLOR_ACCENT2);
	TextDrawTextSize(g_TD_ScrollUp, 500.0, 15.0);
	TextDrawSetSelectable(g_TD_ScrollUp, 1);

	g_TD_ScrollDown = TextDrawCreate(485.0, 370.0, "v");
	TextDrawFont(g_TD_ScrollDown, 2);
	TextDrawLetterSize(g_TD_ScrollDown, 0.3, 1.2);
	TextDrawColor(g_TD_ScrollDown, MUSIC_COLOR_ACCENT2);
	TextDrawTextSize(g_TD_ScrollDown, 500.0, 15.0);
	TextDrawSetSelectable(g_TD_ScrollDown, 1);

	g_TD_Hint = TextDrawCreate(150.0, 395.0, "Кликни по станции/треку. ESC — закрыть. Пассажиры слышат тоже.");
	TextDrawFont(g_TD_Hint, 1);
	TextDrawLetterSize(g_TD_Hint, 0.18, 0.9);
	TextDrawColor(g_TD_Hint, MUSIC_COLOR_DIM);
	return 1;
}

stock MusicGUI_Show(playerid)
{
	Music_LoadAll();

	g_GUIOpen[playerid] = true;
	g_GUIPage[playerid] = 0;
	g_GUIScroll[playerid] = 0;
	g_GUISelected[playerid] = -1;

	TextDrawShowForPlayer(playerid, g_TD_Bg);
	TextDrawShowForPlayer(playerid, g_TD_Header);
	TextDrawShowForPlayer(playerid, g_TD_Title);
	TextDrawShowForPlayer(playerid, g_TD_Close);
	TextDrawShowForPlayer(playerid, g_TD_NowPlaying);
	TextDrawShowForPlayer(playerid, g_TD_BtnRadio);
	TextDrawShowForPlayer(playerid, g_TD_BtnTracks);
	TextDrawShowForPlayer(playerid, g_TD_BtnStop);
	TextDrawShowForPlayer(playerid, g_TD_BtnBack);
	TextDrawShowForPlayer(playerid, g_TD_Hint);
	TextDrawShowForPlayer(playerid, g_TD_ScrollUp);
	TextDrawShowForPlayer(playerid, g_TD_ScrollDown);

	MusicGUI_UpdateNowPlaying(playerid);
	MusicGUI_RenderList(playerid);
	SelectTextDraw(playerid, MUSIC_COLOR_ACCENT2);
	return 1;
}

stock MusicGUI_Hide(playerid)
{
	g_GUIOpen[playerid] = false;
	TextDrawHideForPlayer(playerid, g_TD_Bg);
	TextDrawHideForPlayer(playerid, g_TD_Header);
	TextDrawHideForPlayer(playerid, g_TD_Title);
	TextDrawHideForPlayer(playerid, g_TD_Close);
	TextDrawHideForPlayer(playerid, g_TD_NowPlaying);
	TextDrawHideForPlayer(playerid, g_TD_BtnRadio);
	TextDrawHideForPlayer(playerid, g_TD_BtnTracks);
	TextDrawHideForPlayer(playerid, g_TD_BtnStop);
	TextDrawHideForPlayer(playerid, g_TD_BtnBack);
	TextDrawHideForPlayer(playerid, g_TD_Hint);
	TextDrawHideForPlayer(playerid, g_TD_ScrollUp);
	TextDrawHideForPlayer(playerid, g_TD_ScrollDown);
	for (new i = 0; i < MUSIC_MAX_LIST; i++)
	{
		TextDrawHideForPlayer(playerid, g_TD_ListBg[i]);
		TextDrawHideForPlayer(playerid, g_TD_ListItem[i]);
	}
	CancelSelectTextDraw(playerid);
	return 1;
}

stock MusicGUI_UpdateNowPlaying(playerid)
{
	new txt[64];
	if (g_MusicPlaying[playerid])
		format(txt, sizeof(txt), "Играет: %s", g_MusicTitle[playerid]);
	else
		format(txt, sizeof(txt), "Не играет");
	TextDrawSetString(g_TD_NowPlaying, txt);
	TextDrawShowForPlayer(playerid, g_TD_NowPlaying);
	return 1;
}

stock MusicGUI_RenderList(playerid)
{
	new page = g_GUIPage[playerid];
	new scroll = g_GUIScroll[playerid];
	new total;

	if (page == 1) total = g_StationCount;
	else if (page == 2) total = g_TrackCount;
	else total = 0;

	for (new i = 0; i < MUSIC_MAX_LIST; i++)
	{
		new idx = scroll + i;
		if (page == 0 || idx >= total)
		{
			TextDrawHideForPlayer(playerid, g_TD_ListBg[i]);
			TextDrawHideForPlayer(playerid, g_TD_ListItem[i]);
			continue;
		}

		new line[64];
		if (page == 1)
			format(line, sizeof(line), "%d. %s", idx + 1, g_Stations[idx][stName]);
		else
			format(line, sizeof(line), "%d. [%s] %s", idx + 1, g_Tracks[idx][trPlaylist], g_Tracks[idx][trName]);

		TextDrawSetString(g_TD_ListItem[i], line);
		TextDrawBoxColor(g_TD_ListBg[i], (idx == g_GUISelected[playerid]) ? MUSIC_COLOR_BTN_ON : MUSIC_COLOR_PANEL);
		TextDrawShowForPlayer(playerid, g_TD_ListBg[i]);
		TextDrawShowForPlayer(playerid, g_TD_ListItem[i]);
	}
	return 1;
}

// -------------------- CALLBACKS --------------------
public OnFilterScriptInit()
{
	MusicGUI_Create();
	Music_LoadAll();
	print(" ");
	print("  [MUSIC] GUI Радио/Музыка загружен");
	print("  Команды: /music /radio /musicgui /music stop");
	print(" ");
	return 1;
}

public OnFilterScriptExit()
{
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		if (IsPlayerConnected(i) && g_MusicPlaying[i])
			StopAudioStreamForPlayer(i);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	g_MusicPlaying[playerid] = false;
	g_MusicUrl[playerid][0] = EOS;
	g_MusicTitle[playerid][0] = EOS;
	g_PlayerVehicle[playerid] = 0;
	g_GUIOpen[playerid] = false;
	g_GUIPage[playerid] = 0;
	g_GUIScroll[playerid] = 0;
	g_GUISelected[playerid] = -1;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if (g_MusicPlaying[playerid]) StopAudioStreamForPlayer(playerid);
	if (g_GUIOpen[playerid]) MusicGUI_Hide(playerid);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	#pragma unused oldstate
	if (newstate == PLAYER_STATE_PASSENGER || newstate == PLAYER_STATE_DRIVER)
	{
		new vid = GetPlayerVehicleID(playerid);
		if (vid != 0)
		{
			for (new i = 0; i < MAX_PLAYERS; i++)
			{
				if (i == playerid) continue;
				if (!IsPlayerConnected(i)) continue;
				if (g_PlayerVehicle[i] == vid && g_MusicPlaying[i] && g_MusicUrl[i][0])
				{
					Music_PlayForPlayer(playerid, g_MusicUrl[i], g_MusicTitle[i]);
					g_PlayerVehicle[playerid] = vid;
					break;
				}
			}
		}
	}
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if (!g_GUIOpen[playerid]) return 0;

	if (clickedid == Text:INVALID_TEXT_DRAW || clickedid == g_TD_Close)
	{
		MusicGUI_Hide(playerid);
		return 1;
	}

	if (clickedid == g_TD_BtnRadio)
	{
		g_GUIPage[playerid] = 1;
		g_GUIScroll[playerid] = 0;
		g_GUISelected[playerid] = -1;
		MusicGUI_RenderList(playerid);
		return 1;
	}
	if (clickedid == g_TD_BtnTracks)
	{
		g_GUIPage[playerid] = 2;
		g_GUIScroll[playerid] = 0;
		g_GUISelected[playerid] = -1;
		MusicGUI_RenderList(playerid);
		return 1;
	}
	if (clickedid == g_TD_BtnStop)
	{
		Music_StopForPlayer(playerid);
		MusicGUI_UpdateNowPlaying(playerid);
		return 1;
	}
	if (clickedid == g_TD_BtnBack)
	{
		g_GUIPage[playerid] = 0;
		g_GUIScroll[playerid] = 0;
		g_GUISelected[playerid] = -1;
		MusicGUI_RenderList(playerid);
		return 1;
	}
	if (clickedid == g_TD_ScrollUp)
	{
		if (g_GUIScroll[playerid] > 0)
		{
			g_GUIScroll[playerid]--;
			MusicGUI_RenderList(playerid);
		}
		return 1;
	}
	if (clickedid == g_TD_ScrollDown)
	{
		new total = (g_GUIPage[playerid] == 1) ? g_StationCount : g_TrackCount;
		if (g_GUIScroll[playerid] + MUSIC_MAX_LIST < total)
		{
			g_GUIScroll[playerid]++;
			MusicGUI_RenderList(playerid);
		}
		return 1;
	}

	// List click
	for (new i = 0; i < MUSIC_MAX_LIST; i++)
	{
		if (clickedid == g_TD_ListBg[i] || clickedid == g_TD_ListItem[i])
		{
			new idx = g_GUIScroll[playerid] + i;
			if (g_GUIPage[playerid] == 1 && idx < g_StationCount)
			{
				g_GUISelected[playerid] = idx;
				Music_PlayInVehicle(playerid, g_Stations[idx][stUrl], g_Stations[idx][stName]);
				MusicGUI_UpdateNowPlaying(playerid);
				MusicGUI_RenderList(playerid);
			}
			else if (g_GUIPage[playerid] == 2 && idx < g_TrackCount)
			{
				g_GUISelected[playerid] = idx;
				new title[64];
				format(title, sizeof(title), "%s", g_Tracks[idx][trName]);
				Music_PlayInVehicle(playerid, g_Tracks[idx][trUrl], title);
				MusicGUI_UpdateNowPlaying(playerid);
				MusicGUI_RenderList(playerid);
			}
			return 1;
		}
	}
	return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (!strcmp(cmdtext, "/music", true) || !strcmp(cmdtext, "/radio", true) || !strcmp(cmdtext, "/musicgui", true))
	{
		if (g_GUIOpen[playerid]) MusicGUI_Hide(playerid);
		else MusicGUI_Show(playerid);
		return 1;
	}
	if (!strcmp(cmdtext, "/music stop", true) || !strcmp(cmdtext, "/stopmusic", true))
	{
		Music_StopForPlayer(playerid);
		return 1;
	}
	return 0;
}
