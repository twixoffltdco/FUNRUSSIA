#include "json.inc" //плагин для json


//by KBAS's  t.me/kbasstudio 
#define BrDialogVoice 						0
#define BrDialogPlates 						1
#define BrDialogFuelFill 					2
#define BrDialogDiner 						3
#define BrDialogHack 						4
#define BrDialogRobbery 					5
#define BrDialogRent 						6
#define BrDialogWires 						7
#define BrDialogPipes 						8
#define BrAudioDialog 						9
#define BrDialogWindow 						10
#define BrChooseServerDialog 				11
#define BrFingerPrintDialog 				12
#define BrNotification 						13
#define BrDialogMenu 						14
#define BrDialogDance 						15
#define BrDialogTaxi 						16
#define BrDialogTaxiOrder 					17
#define BrDialogTaxiRating 					18
#define BrDialogGraphicsSetting 			19
#define BrCaptcha 							20
#define BrDialogMap 						21
#define GUIDonate 							22
#define BrDialogSawmill 					23
#define GUISmiEditor 						24
#define GUIPlayersList 						25
#define BrNewCaptcha 						26
#define GUIRadialMenuForCar 				27
#define GUITuning 							28
#define GUIHalloween 						30
#define GUIHalloweenGame 					31
#define HudManager 							32
#define GUIUsersInventory 					33
#define GUICarsTrunkOrCloset 				34
#define GUIBlackPassBanner 					35
#define GUISocialInteraction 				36
#define GUIDrivingSchool 					37
#define GUIRegistration 					38
#define GUITutorial 						39
#define GUIWoundSystem 						40
#define GUIVipAccount 						41
#define GUIEntertainmentSystem 				42
#define GUIEntertainmentSystemFinalWindow 	43
#define GUIFamilySystem 					45
#define GUIFractionSystem 					46
#define GUISpawnLocation 					50
#define GUIOpenURL							51 
#define GUISocialNetworkLink 				52	
#define GUIInviteBanner 					55

#define PACKET_BLACKRRPC					252



//by KBAS's  t.me/kbasstudio 

stock ShowPlayerGUI(playerid, guiid, Node:json)
{
	JSON_SetInt(json, "o", 1);
	OnPacketIncoming(playerid, guiid, json);
}
stock HidePlayerGUI(playerid, guiid) //, Node:json)
{
	new Node:json = JSON_Object(); 
	JSON_SetInt(json, "c", 1);
	OnPacketIncoming(playerid, guiid, json);
}

stock OnPacketIncoming(playerid, guiid, Node:json)
{
	new BitStream:bitstream = BS_New();
	BS_WriteValue(bitstream, PR_UINT8, PACKET_BLACKRRPC);
	
	BS_WriteValue(bitstream, PR_UINT16, guiid);
	
	new data[1024]; //4294967295
    JSON_Stringify(json, data); 
	
    BS_WriteValue(bitstream, PR_UINT32, strlen(data));
    BS_WriteValue(bitstream, PR_STRING, data);

	PR_SendPacket(bitstream, playerid, PR_HIGH_PRIORITY, PR_RELIABLE);
	BS_Delete(bitstream);
}



IPacket:251(playerid, BitStream:bitstream)
{
 	new header, guiid;
 	BS_ReadValue(bitstream, PR_UINT8, header);
 	BS_ReadValue(bitstream, PR_UINT16, guiid);
 	
	new lenght, data[256];
	BS_ReadValue(bitstream, PR_UINT32, lenght);
	BS_ReadValue(bitstream, PR_STRING, data, lenght);

	new Node:JSONObject = JSON_Object();
    JSON_Parse(data, JSONObject);
 	
	switch(guiid)
	{ 
	}
}