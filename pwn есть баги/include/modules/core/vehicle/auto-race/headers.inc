/*
	Defines const
*/

#define MAX_AUTORACES 2
#define MAX_AUTORACE_VEHICLES 8
#define MAX_AUTORACE_RACECPS 23

#define MIN_AUTORACE_PLAYERS 3

#define AUTORACE_STATE_NONE 0
#define AUTORACE_STATE_ONFOOT 1
#define AUTORACE_STATE_DRIVER 2

#define AUTORACE_ENTER_POS 151.0777,776.6240,11.9847
#define AUTORACE_ENTER_F_ANGLE 270.0000

#define AUTORACE_EXIT_WORLD 2
#define AUTORACE_EXIT_INTERIOR 3
#define AUTORACE_EXIT_POS 834.4015,7.3917,1004.1870
#define AUTORACE_EXIT_F_ANGLE 90.0000

#define AUTORACE_MAIN_POS 822.3505,1.9393,1004.1797

/*
	Enums
*/

enum AutoRaceType {
	t_AutoRaceNone = -1,
	t_AutoRaceMotorbike,
	t_AutoRaceCar
};

enum AutoRaceStage {
	s_AutoRaceNone = -1,
	s_AutoRaceStart,
	s_AutoRaceGogogo
};

/*
	Vars
*/




new
	s_autorace_Pos_PickupID[2],
	s_autorace_Main_CPID,

	AutoRaceType:s_autorace_Server_Type = t_AutoRaceNone,
	AutoRaceStage:s_autorace_Server_Stage = s_AutoRaceNone,
	s_autorace_Server_Time[MAX_AUTORACES],

	s_autorace_Server_Count[MAX_AUTORACES],
	s_autorace_Server_Places[MAX_AUTORACES],
	
	s_autorace_Server_Countdown[MAX_AUTORACES] = {3, ...},
	s_autorace_Server_TimerID[MAX_AUTORACES] = {-1, ...},
	s_autorace_Server_PlayerID[MAX_AUTORACES][MAX_AUTORACE_VEHICLES] = {{INVALID_PLAYER_ID, ...}, ...},

	p_autorace_Player_VehicleID[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...},
	p_autorace_Player_RaceCP[MAX_PLAYERS char],//
	p_autorace_Player_RaceCPID[MAX_PLAYERS] = {INVALID_STREAMER_ID, ...},
	AutoRaceType:p_autorace_Player_Type[MAX_PLAYERS] = {t_AutoRaceNone, ...},
	p_autorace_Player_State[MAX_PLAYERS],
	p_autorace_Player_Count[MAX_PLAYERS char];

new stock const
	Float:s_autorace_Player_Spawn[][] = {
	{831.9385,3.4936,1004.1797,356.9391},
	{827.0280,3.9326,1004.1870,304.6120},
	{829.0396,2.9339,1004.1797,335.6323}
};

new const
	s_autorace_Vehicle_World[MAX_AUTORACES] = {
	1,
	2
};

new const
	s_autorace_Vehicle_Model[MAX_AUTORACES] = {
	522,
	411
};

new const
	Float:s_autorace_Vehicle_PosS[MAX_AUTORACES][MAX_AUTORACE_VEHICLES][] = {
	{
		{-372.2530,615.5450,11.5698,0.2185},
		{-376.9331,616.7925,11.5698,358.4086},
		{-381.6756,617.2730,11.5620,358.3142},
		{-385.3571,616.8952,11.5620,358.2442},
		{-371.4467,607.4794,11.5727,3.1729},
		{-376.6445,606.3828,11.5727,2.2245},
		{-381.5201,606.3536,11.5771,2.7633},
		{-386.1741,607.3423,11.5748,357.4647}
	},
	{
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0}
	}
};

new const
	s_autorace_Vehicle_Amount[MAX_AUTORACES] = {
	8,
	0
};

new const
	Float:s_autorace_RaceCP_PosS[MAX_AUTORACES][MAX_AUTORACE_RACECPS][] = {
	{
		{-378.4844,669.8198,11.5698,0.8957},
		{-373.7729,895.9207,11.5667,359.4984},
		{-374.5611,965.2382,11.5690,0.6851},
		{-241.0387,965.7828,11.5690,267.5107},
		{15.3386,870.0539,11.5619,248.4219},
		{215.3168,792.4866,11.5780,245.3635},
		{376.1424,729.3776,11.5684,248.8958},
		{518.0406,675.4227,11.5683,262.1276},
		{592.3163,874.2281,11.5642,342.3498},
		{665.7521,1114.4795,11.5678,12.3556},
		{453.4799,1144.4496,11.5669,83.1981},
		{285.1059,1152.7725,11.5704,173.7227},
		{253.9835,905.5776,11.5668,170.2720},
		{201.2947,766.1030,11.5681,160.3263},
		{132.4278,588.5276,11.5668,158.9919},
		{110.4336,531.2282,11.5659,159.0101},
		{26.8952,386.5162,9.7287,171.3019},
		{213.6859,301.0175,11.4241,296.4958},
		{281.2166,478.6393,11.5714,337.2653},
		{139.2835,539.1445,11.5816,69.9312},
		{25.3656,569.9199,11.5899,83.4921},
		{-171.4706,592.3875,11.5846,84.6959},
		{-368.5535,610.5667,11.5698,90.0309}
	},
	{
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0},
		{0.0,0.0,0.0,0.0}
	}
};

new const
	s_autorace_RaceCP_Amount[MAX_AUTORACES] = {
	23,
	0
};
