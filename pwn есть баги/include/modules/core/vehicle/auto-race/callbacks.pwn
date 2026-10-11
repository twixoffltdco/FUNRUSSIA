/*
	@__OnServerTimerAutoRace
*/

forward @__OnServerTimerAutoRace();
@__OnServerTimerAutoRace()
{
	new
		ar_playerid,
		AutoRaceType:ar_type = s_autorace_Server_Type;

	if (--s_autorace_Server_Countdown[_:ar_type] == 0) {
		for (new i = s_autorace_Server_Count[_:ar_type] - 1; i >= 0; i--) {
			ar_playerid = s_autorace_Server_PlayerID[_:ar_type][i];
			if ((ar_playerid != INVALID_PLAYER_ID)
				&& ((p_autorace_Player_Type[ar_playerid] == ar_type) && (p_autorace_Player_State[ar_playerid] == AUTORACE_STATE_DRIVER))) {
				PlayerPlaySound(ar_playerid, 3201, 0.0, 0.0, 0.0);
				GameTextForPlayer(ar_playerid, "~g~Go! Go! Go!", 5000, 3);
				TogglePlayerControllable(ar_playerid, true);
			}
		}
		s_autorace_Server_TimerID[_:ar_type] = -1;
		SendClientMessageToAll(0xFFFFFFFF, "Внимание! Гонка началась");
		return 1;
	}

	new
		string[5 + 1];

	format(string, sizeof(string), "~y~%i", s_autorace_Server_Countdown[_:ar_type]);
	for (new i = s_autorace_Server_Count[_:ar_type] - 1; i >= 0; i--) {
		ar_playerid = s_autorace_Server_PlayerID[_:ar_type][i];
		if ((ar_playerid != INVALID_PLAYER_ID)
			&& ((p_autorace_Player_Type[ar_playerid] == ar_type) && (p_autorace_Player_State[ar_playerid] == AUTORACE_STATE_DRIVER))) {
			GameTextForPlayer(ar_playerid, string, 5000, 3);
		}
	}
	s_autorace_Server_TimerID[_:ar_type] = SetTimer("@__OnServerTimerAutoRace", 1000, false);
	return 1;
}
