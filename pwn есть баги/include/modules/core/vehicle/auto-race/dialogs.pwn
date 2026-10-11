/*
	Dialogs
*/

Dialog_Create:P_AUTORACE(playerid)
{
	Dialog_Open(playerid, Dialog:P_AUTORACE, DIALOG_STYLE_MSGBOX, "Регистрация на гонку", "{FFFFFF}Вы действительно хотите зарегистрироваться на гонку?", "Выбрать", "Выход");
	return 1;
}

Dialog_Response:P_AUTORACE(playerid, response, listitem)
{
	if (!response) {
		return 1;
	}
	/*if (!IsPlayerInRangeOfPoint(playerid, 1.5, AUTORACE_MAIN_POS)) {
		return 1;
	}*/

	new
		AutoRaceType:ar_type = s_autorace_Server_Type;

	if (ar_type == t_AutoRaceNone) {
		SendClientMessage(playerid, 0xCECECEFF, "Регистрация закрыта");
		return 1;
	}
	if (s_autorace_Server_Stage == s_AutoRaceNone) {
		SendClientMessage(playerid, 0xCECECEFF, "Вы опоздали на гонку");
		return 1;
	}
	if (s_autorace_Server_Count[_:ar_type] >= s_autorace_Vehicle_Amount[_:ar_type]) {
		SendClientMessage(playerid, 0xCECECEFF, "Слишком много участников");
		return 1;
	}
	if ((p_autorace_Player_Type[playerid] == t_AutoRaceNone)
		&& (p_autorace_Player_State[playerid] == AUTORACE_STATE_NONE)) {

		new
			ar_count = s_autorace_Server_Count[_:ar_type]++;

		s_autorace_Server_PlayerID[_:ar_type][ar_count] = playerid;
		p_autorace_Player_Type[playerid] = s_autorace_Server_Type;
		p_autorace_Player_State[playerid] = AUTORACE_STATE_ONFOOT;
		p_autorace_Player_Count{playerid} = ar_count;
		SendClientMessage(playerid, 0xFFFFFFFF, "Вы зарегестрировались на гонку");
		return 1;
	}
	return 1;
}
