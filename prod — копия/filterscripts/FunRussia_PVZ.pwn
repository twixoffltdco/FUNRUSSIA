#define FILTERSCRIPT
#include <a_samp>

/* Fun Russia PVZ FilterScript
 * Standalone visual PVZ points + custom GUI entry to marketplace rewards.
 * Dot commands: .pvz, .reward
 * Actual marketplace rewards are opened through public bridge FR_OpenMarketplaceRewards
 * that must be compiled into the gamemode (patch included in Integration/).
 */
#define PVZ_POINT_COUNT (9)
#define PVZ_REWARD_PICKUP_MODEL (1239)
#define PVZ_POINT_PICKUP_MODEL (19132)
#define PVZ_INTERACT_DISTANCE (3.0)
#define PVZ_TP_COOLDOWN (1500)
#define PVZ_GUI_BG_COLOR (0x101C2CEE)
#define PVZ_GUI_TEXT_COLOR (0xFFFFFFFF)
#define PVZ_GUI_ACCENT (0x35C7FFFF)

new const Float:gPvzPoints[PVZ_POINT_COUNT][8] =
{
    // entry x,y,z, world; interior exit x,y,z, world (interior is 1)
    {1803.149047, 2037.017944, 16.008436, 0.0, 2283.669921, 1836.158691, 1519.743286, 1.0},
    {292.996765, 1541.501220, 12.156729, 0.0, 2283.669921, 1836.158691, 1519.743286, 1.0},
    {614.631835, 579.856567, 12.188437, 0.0, 2283.669921, 1836.158691, 1519.743286, 1.0},
    {2566.409179, -2516.000488, 22.119831, 0.0, 2283.669921, 1836.158691, 1519.743286, 1.0},
    {2386.718017, -1708.890747, 22.084220, 0.0, 2283.669921, 1836.158691, 1519.743286, 1.0},
    {-528.563598, -1788.569946, 41.065799, 0.0, 2283.669921, 1836.158691, 1519.743286, 1.0},
    {-2265.864746, -322.510284, 28.101448, 0.0, 2283.669921, 1836.158691, 1519.743286, 1.0},
    {-2457.938476, 1134.409301, 10.855109, 0.0, 2283.669921, 1836.158691, 1519.743286, 1.0},
    {-1824.447631, 2717.559814, 57.766563, 0.0, 2283.669921, 1836.158691, 1519.743286, 1.0}
};
new gPvzEnterPickup[PVZ_POINT_COUNT];
new gPvzExitPickup = -1;
new gPvzRewardPickup = -1;
new bool:gPvzGuiCreated[MAX_PLAYERS];
new bool:gPvzGuiOpen[MAX_PLAYERS];
new PlayerText:gPvzGui[MAX_PLAYERS][5];
new gPvzLastTp[MAX_PLAYERS];

stock Pvz_CreateGui(playerid)
{
    gPvzGui[playerid][0] = CreatePlayerTextDraw(playerid, 320.0, 150.0, "FUN RUSSIA ~ PVZ REWARDS");
    PlayerTextDrawAlignment(playerid, gPvzGui[playerid][0], 2);
    PlayerTextDrawBackgroundColor(playerid, gPvzGui[playerid][0], 0x000000FF);
    PlayerTextDrawFont(playerid, gPvzGui[playerid][0], 2);
    PlayerTextDrawLetterSize(playerid, gPvzGui[playerid][0], 0.32, 1.6);
    PlayerTextDrawColor(playerid, gPvzGui[playerid][0], PVZ_GUI_ACCENT);
    PlayerTextDrawSetOutline(playerid, gPvzGui[playerid][0], 1);
    PlayerTextDrawUseBox(playerid, gPvzGui[playerid][0], 1);
    PlayerTextDrawBoxColor(playerid, gPvzGui[playerid][0], PVZ_GUI_BG_COLOR);
    PlayerTextDrawTextSize(playerid, gPvzGui[playerid][0], 260.0, 0.0);

    gPvzGui[playerid][1] = CreatePlayerTextDraw(playerid, 320.0, 190.0, "Your marketplace rewards are waiting here.");
    PlayerTextDrawAlignment(playerid, gPvzGui[playerid][1], 2);
    PlayerTextDrawFont(playerid, gPvzGui[playerid][1], 1);
    PlayerTextDrawLetterSize(playerid, gPvzGui[playerid][1], 0.25, 1.2);
    PlayerTextDrawColor(playerid, gPvzGui[playerid][1], PVZ_GUI_TEXT_COLOR);
    PlayerTextDrawSetOutline(playerid, gPvzGui[playerid][1], 1);

    gPvzGui[playerid][2] = CreatePlayerTextDraw(playerid, 320.0, 235.0, "OPEN REWARDS");
    PlayerTextDrawAlignment(playerid, gPvzGui[playerid][2], 2);
    PlayerTextDrawFont(playerid, gPvzGui[playerid][2], 2);
    PlayerTextDrawLetterSize(playerid, gPvzGui[playerid][2], 0.30, 1.5);
    PlayerTextDrawColor(playerid, gPvzGui[playerid][2], 0xFFFFFFFF);
    PlayerTextDrawUseBox(playerid, gPvzGui[playerid][2], 1);
    PlayerTextDrawBoxColor(playerid, gPvzGui[playerid][2], 0x176A46EE);
    PlayerTextDrawTextSize(playerid, gPvzGui[playerid][2], 100.0, 210.0);
    PlayerTextDrawSetSelectable(playerid, gPvzGui[playerid][2], 1);

    gPvzGui[playerid][3] = CreatePlayerTextDraw(playerid, 320.0, 275.0, "CLOSE");
    PlayerTextDrawAlignment(playerid, gPvzGui[playerid][3], 2);
    PlayerTextDrawFont(playerid, gPvzGui[playerid][3], 2);
    PlayerTextDrawLetterSize(playerid, gPvzGui[playerid][3], 0.27, 1.3);
    PlayerTextDrawColor(playerid, gPvzGui[playerid][3], 0xFFFFFFFF);
    PlayerTextDrawUseBox(playerid, gPvzGui[playerid][3], 1);
    PlayerTextDrawBoxColor(playerid, gPvzGui[playerid][3], 0x873232EE);
    PlayerTextDrawTextSize(playerid, gPvzGui[playerid][3], 70.0, 160.0);
    PlayerTextDrawSetSelectable(playerid, gPvzGui[playerid][3], 1);

    gPvzGui[playerid][4] = CreatePlayerTextDraw(playerid, 320.0, 315.0, "Reward items come from the existing marketplace system.");
    PlayerTextDrawAlignment(playerid, gPvzGui[playerid][4], 2);
    PlayerTextDrawFont(playerid, gPvzGui[playerid][4], 1);
    PlayerTextDrawLetterSize(playerid, gPvzGui[playerid][4], 0.20, 1.0);
    PlayerTextDrawColor(playerid, gPvzGui[playerid][4], 0xB8C5D6FF);
    PlayerTextDrawSetOutline(playerid, gPvzGui[playerid][4], 1);
    gPvzGuiCreated[playerid] = true;
    return 1;
}

stock Pvz_OpenRewardGui(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(!gPvzGuiCreated[playerid]) Pvz_CreateGui(playerid);
    for(new i = 0; i < 5; i++) PlayerTextDrawShow(playerid, gPvzGui[playerid][i]);
    SelectTextDraw(playerid, 0x35C7FFFF);
    gPvzGuiOpen[playerid] = true;
    return 1;
}

stock Pvz_CloseRewardGui(playerid)
{
    if(!gPvzGuiOpen[playerid]) return 0;
    for(new i = 0; i < 5; i++) PlayerTextDrawHide(playerid, gPvzGui[playerid][i]);
    CancelSelectTextDraw(playerid);
    gPvzGuiOpen[playerid] = false;
    return 1;
}

stock Pvz_OpenActualRewards(playerid)
{
    Pvz_CloseRewardGui(playerid);
    // Implemented by the optional public bridge in the gamemode/include patch.
    CallRemoteFunction("FR_OpenMarketplaceRewards", "i", playerid);
    SendClientMessage(playerid, 0x35C7FFFF, "[PVZ] Запрос отправлен системе наград маркетплейса.");
    return 1;
}

stock Pvz_HandleDotCommand(playerid, text[])
{
    if(text[0] != '.') return 0;
    new cmd[32]; format(cmd, sizeof cmd, "%s", text[1]);
    new pos = strfind(cmd, " "); if(pos != -1) cmd[pos] = '\0';
    if(!strcmp(cmd, "pvz", true))
    {
        SendClientMessage(playerid, 0x35C7FFFF, "[PVZ] Точки выдачи отмечены на карте. На точке наград откройте GUI.");
        return 1;
    }
    if(!strcmp(cmd, "reward", true) || !strcmp(cmd, "rewards", true))
    {
        Pvz_OpenRewardGui(playerid);
        return 1;
    }
    return 0;
}

public OnFilterScriptInit()
{
    print("[FunRussia_PVZ] Loaded. Dot commands: .pvz, .reward");
    for(new i = 0; i < PVZ_POINT_COUNT; i++)
    {
        gPvzEnterPickup[i] = CreatePickup(PVZ_POINT_PICKUP_MODEL, 23, gPvzPoints[i][0], gPvzPoints[i][1], gPvzPoints[i][2], floatround(gPvzPoints[i][3]));
        new label[128]; format(label, sizeof label, "{35C7FF}PVZ DELIVERY POINT\n{FFFFFF}Point %d\n{66FF99}ENTER", i + 1);
        Create3DTextLabel(label, 0xFFFFFFFF, gPvzPoints[i][0], gPvzPoints[i][1], gPvzPoints[i][2] + 0.8, 20.0, floatround(gPvzPoints[i][3]), 1);
    }
    gPvzExitPickup = CreatePickup(PVZ_POINT_PICKUP_MODEL, 23, 2282.679199, 1836.778442, 1519.743286, 1);
    gPvzRewardPickup = CreatePickup(PVZ_REWARD_PICKUP_MODEL, 23, 2287.283691, 1834.868408, 1519.743286, 1);
    Create3DTextLabel("{35C7FF}PVZ REWARDS\n{FFFFFF}Collect marketplace rewards\n{66FF99}Use .reward", 0xFFFFFFFF, 2287.283691, 1834.868408, 1520.7, 18.0, 1, 1);
    return 1;
}

public OnPlayerText(playerid, text[])
{
    if(Pvz_HandleDotCommand(playerid, text)) return 0;
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    new tick = GetTickCount();
    if(tick - gPvzLastTp[playerid] < PVZ_TP_COOLDOWN) return 1;
    if(pickupid == gPvzRewardPickup)
    {
        Pvz_OpenRewardGui(playerid);
        return 1;
    }
    for(new i = 0; i < PVZ_POINT_COUNT; i++)
    {
        if(pickupid == gPvzEnterPickup[i])
        {
            SetPlayerInterior(playerid, 1);
            SetPlayerVirtualWorld(playerid, 1);
            SetPlayerPos(playerid, 2283.669921, 1836.158691, 1519.743286);
            SetPlayerFacingAngle(playerid, 180.0);
            SetPVarInt(playerid, "pvz_current_point", i);
            gPvzLastTp[playerid] = tick;
            return 1;
        }
    }
    if(pickupid == gPvzExitPickup)
    {
        new point = GetPVarInt(playerid, "pvz_current_point");
        if(point < 0 || point >= PVZ_POINT_COUNT) point = 0;
        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid, gPvzPoints[point][0], gPvzPoints[point][1], gPvzPoints[point][2]);
        gPvzLastTp[playerid] = tick;
        return 1;
    }
    return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(!gPvzGuiOpen[playerid]) return 0;
    if(playertextid == gPvzGui[playerid][2]) return Pvz_OpenActualRewards(playerid);
    if(playertextid == gPvzGui[playerid][3]) return Pvz_CloseRewardGui(playerid);
    return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid == INVALID_TEXT_DRAW && gPvzGuiOpen[playerid]) Pvz_CloseRewardGui(playerid);
    return 0;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason
    if(gPvzGuiOpen[playerid]) Pvz_CloseRewardGui(playerid);
    for(new i = 0; i < 5; i++)
    {
        if(gPvzGui[playerid][i]) { PlayerTextDrawDestroy(playerid, gPvzGui[playerid][i]); gPvzGui[playerid][i] = PlayerText:INVALID_TEXT_DRAW; }
    }
    gPvzGuiOpen[playerid] = false;
    gPvzGuiCreated[playerid] = false;
    gPvzLastTp[playerid] = 0;
    DeletePVar(playerid, "pvz_current_point");
    return 1;
}
