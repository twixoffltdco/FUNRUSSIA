/*
	EuroSystem FULL � ��� ���������
	.euro .euromusic .eurofamily .eurocar .euroskin .euroacs .euroex .eurotop
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
#define EURO_FAMILY_PRICE	100000
#define COLOR_EURO			0xFFD700FF
#define COLOR_ERR			0xFF6347FF

#define D_EURO_MENU			29510
#define D_EURO_GIVE			29511
#define D_EURO_GIVE_AMT		29512
#define D_EURO_TOP			29514
#define D_EURO_EX			29515
#define D_EURO_EX_AMT		29516
#define D_EURO_SKIN			29520
#define D_EURO_ACS			29521
#define D_EURO_CAR			29522
#define D_EURO_FAM_NAME		29523
#define D_EURO_FAM_OK		29524
#define D_EURO_MUSIC_BUY	29525
#define D_EURO_MUSIC_PAGE	29526

#define ITEM_SKIN			134
#define MUSIC_PAGE_SIZE		4
#define MUSIC_TOTAL			60
#define MUSIC_DIST			10.0

new Float:gEuroRate = 94.97;
new gSQL, gSQLOk;
new SQL_Host[64], SQL_User[64], SQL_Pass[128], SQL_DB[64];
new PlayerEuro[MAX_PLAYERS], PlayerEuroEx[MAX_PLAYERS], PlayerAccID[MAX_PLAYERS];
new bool:PlayerLoaded[MAX_PLAYERS];
new EuroGiveTarget[MAX_PLAYERS], EuroExMode[MAX_PLAYERS];
new LastPaydayHour = -1;
new FamilyNamePending[MAX_PLAYERS][32];
new MusicBuys[MAX_PLAYERS];
new bool:MusicSession[MAX_PLAYERS];
new bool:MusicOn[MAX_PLAYERS];
new MusicPage[MAX_PLAYERS];

stock trim(s[])
{
	new a,b=strlen(s);
	while(a<b&&s[a]<=' ')a++;
	while(b>a&&s[b-1]<=' ')b--;
	strdel(s,b,strlen(s));
	if(a) strdel(s,0,a);
}

stock LoadIni()
{
	format(SQL_Host,sizeof SQL_Host,"127.0.0.1");
	SQL_User[0]=SQL_Pass[0]=SQL_DB[0]=0;
	if(!fexist(MYSQL_FILE)){ print("[Euro] NET ini"); return 0; }
	new File:f=fopen(MYSQL_FILE,io_read), line[256];
	if(!f) return 0;
	while(fread(f,line))
	{
		for(new i;line[i];i++) if(line[i]=='\r'||line[i]=='\n'){line[i]=0;break;}
		trim(line);
		if(!line[0]||line[0]==';'||line[0]=='#'||line[0]=='[') continue;
		new eq=strfind(line,"="); if(eq<1) continue;
		new key[64],val[128];
		strmid(key,line,0,eq); strmid(val,line,eq+1,strlen(line));
		trim(key); trim(val);
		if(!strcmp(key,"host",true)||!strcmp(key,"hostname",true)||!strcmp(key,"server",true)) format(SQL_Host,sizeof SQL_Host,"%s",val);
		else if(!strcmp(key,"username",true)||!strcmp(key,"user",true)||!strcmp(key,"login",true)) format(SQL_User,sizeof SQL_User,"%s",val);
		else if(!strcmp(key,"password",true)||!strcmp(key,"pass",true)) format(SQL_Pass,sizeof SQL_Pass,"%s",val);
		else if(!strcmp(key,"database",true)||!strcmp(key,"db",true)||!strcmp(key,"dbname",true)) format(SQL_DB,sizeof SQL_DB,"%s",val);
	}
	fclose(f);
	printf("[Euro] %s@%s / %s",SQL_User,SQL_Host,SQL_DB);
	return (SQL_User[0]&&SQL_DB[0]);
}

stock ConnectSQL()
{
	gSQL=mysql_connect(SQL_Host,SQL_User,SQL_DB,SQL_Pass);
	if(gSQL&&mysql_errno(gSQL)==0) return 1;
	gSQL=mysql_connect(SQL_Host,SQL_User,SQL_Pass,SQL_DB);
	if(gSQL&&mysql_errno(gSQL)==0) return 1;
	gSQL=0; return 0;
}

stock SaveEuro(playerid)
{
	if(!gSQLOk||!PlayerLoaded[playerid]||PlayerAccID[playerid]<1) return 0;
	new q[200];
	mysql_format(gSQL,q,sizeof q,"UPDATE `accounts` SET `evro`=%d,`evro_exchanged`=%d WHERE `id`=%d LIMIT 1",
		PlayerEuro[playerid],PlayerEuroEx[playerid],PlayerAccID[playerid]);
	mysql_tquery(gSQL,q);
	return 1;
}

stock LoadEuro(playerid)
{
	if(!gSQLOk) return 0;
	new name[24],q[200];
	GetPlayerName(playerid,name,sizeof name);
	mysql_format(gSQL,q,sizeof q,"SELECT `id`,IFNULL(`evro`,0),IFNULL(`evro_exchanged`,0) FROM `accounts` WHERE `name`='%e' LIMIT 1",name);
	mysql_tquery(gSQL,q,"OnEuroLoad","i",playerid);
	return 1;
}

forward OnEuroLoad(playerid);
public OnEuroLoad(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(cache_get_row_count(gSQL)<1){ PlayerLoaded[playerid]=false; return 1; }
	PlayerAccID[playerid]=cache_get_row_int(0,0,gSQL);
	PlayerEuro[playerid]=cache_get_row_int(0,1,gSQL);
	PlayerEuroEx[playerid]=cache_get_row_int(0,2,gSQL);
	PlayerLoaded[playerid]=true;
	return 1;
}

forward UpdateRate();
public UpdateRate()
{
	HTTP(9911,HTTP_GET,"www.cbr.ru/scripts/XML_daily.asp","","OnRateHTTP");
	return 1;
}

forward OnRateHTTP(index, response_code, data[]);
public OnRateHTTP(index, response_code, data[])
{
	#pragma unused index
	if(response_code!=200||strlen(data)<40) return 1;
	new p=strfind(data,"EUR",true); if(p==-1) return 1;
	new v=strfind(data,"<Value>",true,p); if(v==-1) return 1; v+=7;
	new buf[24],i;
	while(data[v]&&data[v]!='<'&&i<20){ buf[i++]=(data[v]==',')?'.':data[v]; v++; }
	buf[i]=0;
	new Float:r=floatstr(buf);
	if(r>20.0&&r<250.0){ gEuroRate=r; printf("[Euro] CBR %.4f",gEuroRate); }
	return 1;
}

stock DoExchange(playerid, amount, toBank)
{
	if(!PlayerLoaded[playerid]) return SendClientMessage(playerid,COLOR_ERR,"���� �� ���������"),0;
	if(amount<=0||PlayerEuro[playerid]<amount) return SendClientMessage(playerid,COLOR_ERR,"���� ����"),0;
	new rub=floatround(float(amount)*gEuroRate,floatround_floor);
	if(rub<1) rub=1;
	PlayerEuro[playerid]-=amount; PlayerEuroEx[playerid]+=amount; SaveEuro(playerid);
	new q[300];
	if(toBank)
		mysql_format(gSQL,q,sizeof q,"UPDATE `accounts` SET `bank`=IFNULL(`bank`,0)+%d WHERE `id`=%d LIMIT 1",rub,PlayerAccID[playerid]);
	else
	{
		mysql_format(gSQL,q,sizeof q,"UPDATE `accounts` SET `money`=IFNULL(`money`,0)+%d WHERE `id`=%d LIMIT 1",rub,PlayerAccID[playerid]);
		GivePlayerMoney(playerid,rub);
	}
	mysql_tquery(gSQL,q);
	new str[160];
	format(str,sizeof str,"{FFD700}�����: -%d ���� = +%d ��� (%s) | �� %.2f | ����: %d",amount,rub,toBank?"����":"���",gEuroRate,PlayerEuro[playerid]);
	SendClientMessage(playerid,-1,str);
	return 1;
}

stock BuySkin(playerid, modelid)
{
	if(modelid<1) return SendClientMessage(playerid,COLOR_ERR,"�������� ID"),0;
	if(!PlayerLoaded[playerid]) return 0;
	new price=25+(modelid%80); if(modelid>1000) price=100+(modelid%120);
	if(PlayerEuro[playerid]<price) return SendClientMessage(playerid,COLOR_ERR,"���� ����"),0;
	PlayerEuro[playerid]-=price; SaveEuro(playerid);
	new acc=PlayerAccID[playerid],q[400];
	mysql_format(gSQL,q,sizeof q,"INSERT INTO `invskins` (`account_id`,`internal_id`,`modelid`) VALUES (%d,%d,%d)",acc,modelid,modelid);
	mysql_tquery(gSQL,q);
	mysql_format(gSQL,q,sizeof q,"INSERT INTO `inventory` (`account_id`,`item_id`,`model_id`,`old_skin`,`slot`,`amount`,`extra_1`,`extra_2`,`sim`,`oldsim`,`source_internal_id`) SELECT %d,%d,%d,0,IFNULL(MAX(`slot`),0)+1,1,0,0,0,0,%d FROM `inventory` WHERE `account_id`=%d",acc,ITEM_SKIN,modelid,modelid,acc);
	mysql_tquery(gSQL,q);
	SetPlayerSkin(playerid,modelid);
	new str[96]; format(str,sizeof str,"{FFD700}���� %d �� %d ����",modelid,price);
	SendClientMessage(playerid,-1,str);
	return 1;
}

stock BuyAcs(playerid, modelid)
{
	if(modelid<1) return SendClientMessage(playerid,COLOR_ERR,"�������� ID"),0;
	if(!PlayerLoaded[playerid]) return 0;
	new price=35+(modelid%90); if(modelid>10000) price=80+(modelid%100);
	if(PlayerEuro[playerid]<price) return SendClientMessage(playerid,COLOR_ERR,"���� ����"),0;
	PlayerEuro[playerid]-=price; SaveEuro(playerid);
	new acc=PlayerAccID[playerid],q[400];
	mysql_format(gSQL,q,sizeof q,"INSERT INTO `accessory_inventory` (`player_id`,`acs_id`,`use`) VALUES (%d,%d,0)",acc,modelid);
	mysql_tquery(gSQL,q);
	mysql_format(gSQL,q,sizeof q,"INSERT INTO `inventory` (`account_id`,`item_id`,`model_id`,`old_skin`,`slot`,`amount`,`extra_1`,`extra_2`,`sim`,`oldsim`,`source_internal_id`) SELECT %d,%d,%d,0,IFNULL(MAX(`slot`),0)+1,1,0,0,0,0,0 FROM `inventory` WHERE `account_id`=%d",acc,modelid,modelid,acc);
	mysql_tquery(gSQL,q);
	new str[96]; format(str,sizeof str,"{FFD700}��� %d �� %d ����",modelid,price);
	SendClientMessage(playerid,-1,str);
	return 1;
}

stock BuyCar(playerid, modelid)
{
	if(modelid<1) return SendClientMessage(playerid,COLOR_ERR,"�������� ID"),0;
	if(!PlayerLoaded[playerid]) return 0;
	new price=150+(modelid%250);
	if(PlayerEuro[playerid]<price) return SendClientMessage(playerid,COLOR_ERR,"���� ����"),0;
	new Float:x,Float:y,Float:z,Float:a;
	GetPlayerPos(playerid,x,y,z); GetPlayerFacingAngle(playerid,a);
	x+=floatsin(-a,degrees)*5.0; y+=floatcos(-a,degrees)*5.0;
	PlayerEuro[playerid]-=price; SaveEuro(playerid);
	new q[420];
	mysql_format(gSQL,q,sizeof q,"INSERT INTO `ownable_cars` (`owner_id`,`model_id`,`color_1`,`color_2`,`pos_x`,`pos_y`,`pos_z`,`angle`,`create_time`,`alarm`,`key_in`,`mileage`,`fuel`,`health`,`vinilcar`,`pt_engine`,`pt_brake`,`pt_stability`,`nitro`,`launch`,`fars`) VALUES (%d,%d,1,1,%f,%f,%f,%f,%d,0,0,0.0,40.0,1000.0,0,0,0,0,0,0,0)",
		PlayerAccID[playerid],modelid,x,y,z,a,gettime());
	mysql_tquery(gSQL,q);
	new veh=CreateVehicle(modelid,x,y,z+0.3,a,1,1,-1);
	if(veh!=INVALID_VEHICLE_ID) PutPlayerInVehicle(playerid,veh,0);
	new str[112]; format(str,sizeof str,"{FFD700}������ %d �� %d ����",modelid,price);
	SendClientMessage(playerid,-1,str);
	return 1;
}

stock StartFamilyBuy(playerid)
{
	if(!PlayerLoaded[playerid]) return 0;
	if(PlayerEuro[playerid]<EURO_FAMILY_PRICE) return SendClientMessage(playerid,COLOR_ERR,"����� 100000 ����"),0;
	ShowPlayerDialog(playerid,D_EURO_FAM_NAME,DIALOG_STYLE_INPUT,"{FFD700}�����","�������� ����� (2-30):","�����","������");
	return 1;
}

stock ConfirmFamily(playerid)
{
	new q[160];
	mysql_format(gSQL,q,sizeof q,"SELECT `family_id` FROM `accounts` WHERE `id`=%d LIMIT 1",PlayerAccID[playerid]);
	mysql_tquery(gSQL,q,"OnFamCheck","i",playerid);
	return 1;
}

forward OnFamCheck(playerid);
public OnFamCheck(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new fid=0; if(cache_get_row_count(gSQL)>0) fid=cache_get_row_int(0,0,gSQL);
	if(fid>0) return SendClientMessage(playerid,COLOR_ERR,"��� � �����"),1;
	if(PlayerEuro[playerid]<EURO_FAMILY_PRICE) return 1;
	PlayerEuro[playerid]-=EURO_FAMILY_PRICE; SaveEuro(playerid);
	new q[700];
	mysql_format(gSQL,q,sizeof q,"INSERT INTO `familynew` (`owner`,`name`,`color`,`chatcolor`,`slot_veh`,`reputation`,`zaxvati`,`moneti`,`syndicate`,`patron`,`material`,`heath_kit`,`armour`,`money`,`mask`,`level_storage`,`level_weapon`,`level_compound`,`house`,`notif`,`notif_seq`,`rang_1`,`rang_2`,`rang_3`,`rang_4`,`rang_5`,`last_active`) VALUES (%d,'%e',0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,-1,'',0,'1 rang,1,0,0,0,1','2 rang,1,0,0,0,1','3 rang,1,0,0,0,1','4 rang,1,1,1,1,1','5 rang,1,1,1,1,1',%d)",
		PlayerAccID[playerid],FamilyNamePending[playerid],gettime());
	mysql_tquery(gSQL,q,"OnFamIns","i",playerid);
	return 1;
}

forward OnFamIns(playerid);
public OnFamIns(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new id=cache_insert_id(gSQL);
	if(id<1){ mysql_tquery(gSQL,"SELECT MAX(`id`) FROM `familynew`","OnFamMax","i",playerid); return 1; }
	new q[180];
	mysql_format(gSQL,q,sizeof q,"UPDATE `accounts` SET `family_id`=%d,`family_rang`=5 WHERE `id`=%d LIMIT 1",id,PlayerAccID[playerid]);
	mysql_tquery(gSQL,q);
	new str[120]; format(str,sizeof str,"{FFD700}����� �%s� id %d, �����. �����!",FamilyNamePending[playerid],id);
	SendClientMessage(playerid,-1,str);
	return 1;
}

forward OnFamMax(playerid);
public OnFamMax(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new id=0; if(cache_get_row_count(gSQL)>0) id=cache_get_row_int(0,0,gSQL);
	if(id<1){ PlayerEuro[playerid]+=EURO_FAMILY_PRICE; SaveEuro(playerid); return 1; }
	new q[180];
	mysql_format(gSQL,q,sizeof q,"UPDATE `accounts` SET `family_id`=%d,`family_rang`=5 WHERE `id`=%d LIMIT 1",id,PlayerAccID[playerid]);
	mysql_tquery(gSQL,q);
	SendClientMessage(playerid,COLOR_EURO,"����� �������. �����!");
	return 1;
}

stock TrackName(id, dest[], len)
{
	switch(id)
	{
		case 0: format(dest,len,"01 CMH");
		case 1: format(dest,len,"02 Lovv66");
		case 2: format(dest,len,"03 unki remix");
		case 3: format(dest,len,"04 GENE");
		case 4: format(dest,len,"05 borya74k");
		case 5: format(dest,len,"06 Pharaoh");
		case 6: format(dest,len,"07 Pharaoh Goat");
		case 7: format(dest,len,"08 The Limba");
		case 8: format(dest,len,"09 KRANIN every day");
		case 9: format(dest,len,"10 gravis JUGG");
		case 10: format(dest,len,"11 Pharaoh 2");
		case 11: format(dest,len,"12 Kagramanov");
		case 12: format(dest,len,"13 BENZIN / BBT");
		case 13: format(dest,len,"14 dior armani");
		case 14: format(dest,len,"15 GENE 2");
		case 15: format(dest,len,"16 RU vibe");
		case 16: format(dest,len,"17 gravis barbie");
		case 17: format(dest,len,"18 JDFLAG");
		case 18: format(dest,len,"19 Instasamka style");
		case 19: format(dest,len,"20 JDFLAG TOASTER");
		case 20: format(dest,len,"21 Lil Tecca");
		case 21: format(dest,len,"22 Voskresenskii");
		case 22: format(dest,len,"23 Sunflower");
		case 23: format(dest,len,"24 BBT / kizaru");
		case 24: format(dest,len,"25 huzzy b");
		case 25: format(dest,len,"26 kizaru BABY DRAC");
		case 26: format(dest,len,"27 madk1d");
		case 27: format(dest,len,"28 mafanya");
		case 28: format(dest,len,"29 SEREBRO");
		case 29: format(dest,len,"30 Mia Boyka style");
		case 30: format(dest,len,"31 Morgen style");
		case 31: format(dest,len,"32 GENE 3");
		case 32: format(dest,len,"33 CMH RAVE");
		case 33: format(dest,len,"34 Track 34");
		case 34: format(dest,len,"35 Track 35");
		case 35: format(dest,len,"36 Track 36");
		case 36: format(dest,len,"37 Track 37");
		case 37: format(dest,len,"38 Track 38");
		case 38: format(dest,len,"39 Track 39");
		case 39: format(dest,len,"40 Track 40");
		case 40: format(dest,len,"41 Track 41");
		case 41: format(dest,len,"42 Track 42");
		case 42: format(dest,len,"43 Track 43");
		case 43: format(dest,len,"44 Track 44");
		case 44: format(dest,len,"45 Track 45");
		case 45: format(dest,len,"46 Track 46");
		case 46: format(dest,len,"47 Track 47");
		case 47: format(dest,len,"48 Track 48");
		case 48: format(dest,len,"49 Track 49");
		case 49: format(dest,len,"50 Track 50");
		case 50: format(dest,len,"51 Track 51");
		case 51: format(dest,len,"[Radio] Record");
		case 52: format(dest,len,"[Radio] Europa Plus");
		case 53: format(dest,len,"[Radio] Energy");
		case 54: format(dest,len,"[Radio] DFM");
		case 55: format(dest,len,"[Radio] Retro FM");
		case 56: format(dest,len,"[Radio] Record Russian");
		case 57: format(dest,len,"[Radio] Record Rap");
		case 58: format(dest,len,"[Radio] Record Techno");
		case 59: format(dest,len,">> ����");
		default: format(dest,len,"Track %d",id);
	}
	return 1;
}

stock TrackUrl(id, dest[], len)
{
	switch(id)
	{
		case 0: format(dest,len,"https://api.kraninshop.ru/music/track-01.mp3");
		case 1: format(dest,len,"https://api.kraninshop.ru/music/track-02.mp3");
		case 2: format(dest,len,"https://api.kraninshop.ru/music/track-03.mp3");
		case 3: format(dest,len,"https://api.kraninshop.ru/music/track-04.mp3");
		case 4: format(dest,len,"https://api.kraninshop.ru/music/track-33.mp3");
		case 5: format(dest,len,"https://api.kraninshop.ru/music/track-05.mp3");
		case 6: format(dest,len,"https://api.kraninshop.ru/music/track-06.mp3");
		case 7: format(dest,len,"https://api.kraninshop.ru/music/track-07.mp3");
		case 8: format(dest,len,"https://api.kraninshop.ru/music/track-08.mp3");
		case 9: format(dest,len,"https://api.kraninshop.ru/music/track-09.mp3");
		case 10: format(dest,len,"https://api.kraninshop.ru/music/track-10.mp3");
		case 11: format(dest,len,"https://api.kraninshop.ru/music/track-11.mp3");
		case 12: format(dest,len,"https://api.kraninshop.ru/music/track-12.mp3");
		case 13: format(dest,len,"https://api.kraninshop.ru/music/track-13.mp3");
		case 14: format(dest,len,"https://api.kraninshop.ru/music/track-14.mp3");
		case 15: format(dest,len,"https://api.kraninshop.ru/music/track-15.mp3");
		case 16: format(dest,len,"https://api.kraninshop.ru/music/track-16.mp3");
		case 17: format(dest,len,"https://api.kraninshop.ru/music/track-17.mp3");
		case 18: format(dest,len,"https://api.kraninshop.ru/music/track-18.mp3");
		case 19: format(dest,len,"https://api.kraninshop.ru/music/track-19.mp3");
		case 20: format(dest,len,"https://api.kraninshop.ru/music/track-20.mp3");
		case 21: format(dest,len,"https://api.kraninshop.ru/music/track-21.mp3");
		case 22: format(dest,len,"https://api.kraninshop.ru/music/track-22.mp3");
		case 23: format(dest,len,"https://api.kraninshop.ru/music/track-23.mp3");
		case 24: format(dest,len,"https://api.kraninshop.ru/music/track-24.mp3");
		case 25: format(dest,len,"https://api.kraninshop.ru/music/track-25.mp3");
		case 26: format(dest,len,"https://api.kraninshop.ru/music/track-26.mp3");
		case 27: format(dest,len,"https://api.kraninshop.ru/music/track-27.mp3");
		case 28: format(dest,len,"https://api.kraninshop.ru/music/track-28.mp3");
		case 29: format(dest,len,"https://api.kraninshop.ru/music/track-29.mp3");
		case 30: format(dest,len,"https://api.kraninshop.ru/music/track-30.mp3");
		case 31: format(dest,len,"https://api.kraninshop.ru/music/track-31.mp3");
		case 32: format(dest,len,"https://api.kraninshop.ru/music/track-32.mp3");
		case 33: format(dest,len,"https://api.kraninshop.ru/music/track-34.mp3");
		case 34: format(dest,len,"https://api.kraninshop.ru/music/track-35.mp3");
		case 35: format(dest,len,"https://api.kraninshop.ru/music/track-36.mp3");
		case 36: format(dest,len,"https://api.kraninshop.ru/music/track-37.mp3");
		case 37: format(dest,len,"https://api.kraninshop.ru/music/track-38.mp3");
		case 38: format(dest,len,"https://api.kraninshop.ru/music/track-39.mp3");
		case 39: format(dest,len,"https://api.kraninshop.ru/music/track-40.mp3");
		case 40: format(dest,len,"https://api.kraninshop.ru/music/track-41.mp3");
		case 41: format(dest,len,"https://api.kraninshop.ru/music/track-42.mp3");
		case 42: format(dest,len,"https://api.kraninshop.ru/music/track-43.mp3");
		case 43: format(dest,len,"https://api.kraninshop.ru/music/track-44.mp3");
		case 44: format(dest,len,"https://api.kraninshop.ru/music/track-45.mp3");
		case 45: format(dest,len,"https://api.kraninshop.ru/music/track-46.mp3");
		case 46: format(dest,len,"https://api.kraninshop.ru/music/track-47.mp3");
		case 47: format(dest,len,"https://api.kraninshop.ru/music/track-48.mp3");
		case 48: format(dest,len,"https://api.kraninshop.ru/music/track-49.mp3");
		case 49: format(dest,len,"https://api.kraninshop.ru/music/track-50.mp3");
		case 50: format(dest,len,"https://api.kraninshop.ru/music/track-51.mp3");
		case 51: format(dest,len,"https://radiorecord.hostingradio.ru/rr_main96.aacp");
		case 52: format(dest,len,"https://ep256.hostingradio.ru:8052/europaplus256.mp3");
		case 53: format(dest,len,"https://pub0302.101.ru:8000/stream/trust/mp3/128/99");
		case 54: format(dest,len,"https://dfm.hostingradio.ru/dfm96.aacp");
		case 55: format(dest,len,"https://retro.hostingradio.ru:8043/retro256.mp3");
		case 56: format(dest,len,"https://radiorecord.hostingradio.ru/russianhits96.aacp");
		case 57: format(dest,len,"https://radiorecord.hostingradio.ru/rap96.aacp");
		case 58: format(dest,len,"https://radiorecord.hostingradio.ru/techno96.aacp");
		default: dest[0]=0;
	}
	return 1;
}

stock Float:Dist3(Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2)
	return floatsqroot((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));

new bool:MusicBusy[MAX_PLAYERS];
new MusicPendingTrack[MAX_PLAYERS];
new MusicPendingVeh[MAX_PLAYERS];

stock MusicStop(playerid)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
	if(MusicOn[playerid])
	{
		StopAudioStreamForPlayer(playerid);
		MusicOn[playerid] = false;
	}
	return 1;
}

stock MusicStopRadius(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid))
	{
		MusicStop(playerid);
		return 1;
	}
	new veh = GetPlayerVehicleID(playerid);
	if(veh == INVALID_VEHICLE_ID)
	{
		MusicStop(playerid);
		return 1;
	}
	new Float:x, Float:y, Float:z;
	GetVehiclePos(veh, x, y, z);
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		new Float:px, Float:py, Float:pz;
		GetPlayerPos(i, px, py, pz);
		if(Dist3(x, y, z, px, py, pz) <= MUSIC_DIST)
			MusicStop(i);
	}
	return 1;
}

stock MusicPlay(playerid, trackid)
{
	if(playerid < 0 || playerid >= MAX_PLAYERS) return 0;
	if(MusicBusy[playerid]) return 1;

	if(trackid == 59)
	{
		MusicStopRadius(playerid);
		SendClientMessage(playerid, COLOR_EURO, "����");
		return 1;
	}
	if(trackid < 0 || trackid >= 59)
		return SendClientMessage(playerid, COLOR_ERR, "�������� ����"), 0;

	if(!IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, COLOR_ERR, "������ � ����������"), 0;

	new veh = GetPlayerVehicleID(playerid);
	if(veh == INVALID_VEHICLE_ID)
		return SendClientMessage(playerid, COLOR_ERR, "��� ������"), 0;

	new url[200], name[48];
	TrackUrl(trackid, url, sizeof url);
	TrackName(trackid, name, sizeof name);
	if(!url[0] || strlen(url) < 10)
		return SendClientMessage(playerid, COLOR_ERR, "��� ������"), 0;

	// ������� ������ Stop � Play �� � ��� �� ���� (������ ���� BR mobile)
	MusicStopRadius(playerid);

	MusicBusy[playerid] = true;
	MusicPendingTrack[playerid] = trackid;
	MusicPendingVeh[playerid] = veh;

	new str[96];
	format(str, sizeof str, "{FFD700}? %s", name);
	SendClientMessage(playerid, -1, str);

	SetTimerEx("MusicPlayDelayed", 200, false, "i", playerid);
	return 1;
}

forward MusicPlayDelayed(playerid);
public MusicPlayDelayed(playerid)
{
	if(!IsPlayerConnected(playerid))
	{
		if(playerid >= 0 && playerid < MAX_PLAYERS) MusicBusy[playerid] = false;
		return 1;
	}

	new trackid = MusicPendingTrack[playerid];
	new veh = MusicPendingVeh[playerid];
	MusicBusy[playerid] = false;

	if(!IsPlayerInAnyVehicle(playerid)) return 1;
	if(GetPlayerVehicleID(playerid) != veh) return 1;
	if(trackid < 0 || trackid >= 59) return 1;

	new url[200];
	TrackUrl(trackid, url, sizeof url);
	if(!url[0]) return 1;

	new Float:x, Float:y, Float:z;
	GetVehiclePos(veh, x, y, z);

	// ������ ����������: 10�, 3D usepos, ��� ������, ����� + �����
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
		new Float:px, Float:py, Float:pz;
		GetPlayerPos(i, px, py, pz);
		if(Dist3(x, y, z, px, py, pz) > MUSIC_DIST) continue;
		PlayAudioStreamForPlayer(i, url, x, y, z, MUSIC_DIST, 1);
		MusicOn[i] = true;
	}
	return 1;
}

stock MusicPrice(playerid) return 10*(MusicBuys[playerid]+1);
stock MusicPages() return (MUSIC_TOTAL+MUSIC_PAGE_SIZE-1)/MUSIC_PAGE_SIZE;

stock ShowMusicPage(playerid)
{
	new page=MusicPage[playerid];
	if(page<1) page=1;
	new maxp=MusicPages(); if(page>maxp) page=maxp;
	MusicPage[playerid]=page;
	new start=(page-1)*MUSIC_PAGE_SIZE, list[400]; list[0]=0;
	for(new i;i<MUSIC_PAGE_SIZE;i++)
	{
		new id=start+i; if(id>=MUSIC_TOTAL) break;
		new name[48],line[56]; TrackName(id,name,sizeof name);
		format(line,sizeof line,"%s\n",name); strcat(list,line);
	}
	strcat(list,">> �����\n<< �����");
	new title[48]; format(title,sizeof title,"{FFD700}������ %d/%d",page,maxp);
	ShowPlayerDialog(playerid,D_EURO_MUSIC_PAGE,DIALOG_STYLE_LIST,title,list,"OK","X");
	return 1;
}

stock OpenMusic(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,COLOR_ERR,"���� � ������"),1;
	if(!PlayerLoaded[playerid]){ LoadEuro(playerid); return SendClientMessage(playerid,COLOR_ERR,"������� �������� ����"),1; }
	if(!MusicSession[playerid])
	{
		new p=MusicPrice(playerid), body[200];
		format(body,sizeof body,"������ ������: %d ����\n(����� 20, 30...)\n����� ������ � �����.",p);
		ShowPlayerDialog(playerid,D_EURO_MUSIC_BUY,DIALOG_STYLE_MSGBOX,"{FFD700}������",body,"������","���");
		return 1;
	}
	MusicPage[playerid]=1; ShowMusicPage(playerid);
	return 1;
}

stock BuyMusic(playerid)
{
	new p=MusicPrice(playerid);
	if(PlayerEuro[playerid]<p) return SendClientMessage(playerid,COLOR_ERR,"���� ����"),0;
	PlayerEuro[playerid]-=p; MusicBuys[playerid]++; MusicSession[playerid]=true; SaveEuro(playerid);
	new str[72]; format(str,sizeof str,"{FFD700}������ ������� (-%d ����)",p);
	SendClientMessage(playerid,-1,str);
	MusicPage[playerid]=1; ShowMusicPage(playerid);
	return 1;
}

forward PayDay();
public PayDay()
{
	if(!gSQLOk) return 1;
	new h,m,s; gettime(h,m,s);
	if(m!=0||LastPaydayHour==h) return 1;
	LastPaydayHour=h;
	mysql_tquery(gSQL,"UPDATE `accounts` SET `evro`=IFNULL(`evro`,0)+10");
	for(new i;i<MAX_PLAYERS;i++) if(IsPlayerConnected(i)&&PlayerLoaded[i])
	{ PlayerEuro[i]+=EURO_PAYDAY; SendClientMessage(i,COLOR_EURO,"PayDay +10 ����"); }
	return 1;
}

stock ShowTop(playerid)
{
	mysql_tquery(gSQL,"SELECT `name`,IFNULL(`evro`,0) AS e FROM `accounts` ORDER BY IFNULL(`evro`,0) DESC LIMIT 50","OnTop","i",playerid);
	return 1;
}

forward OnTop(playerid);
public OnTop(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows=cache_get_row_count(gSQL), body[2000], line[96], name[24], e;
	body[0]=0;
	for(new i;i<rows&&i<50;i++)
	{
		cache_get_field_content(i,"name",name,gSQL,sizeof name);
		e=cache_get_field_content_int(i,"e",gSQL);
		if(i==0) format(line,sizeof line,"{FFD700}1. %s � %d (������)\n",name,e);
		else if(i==1) format(line,sizeof line,"{C0C0C0}2. %s � %d (�������)\n",name,e);
		else if(i==2) format(line,sizeof line,"{CD7F32}3. %s � %d (������)\n",name,e);
		else format(line,sizeof line,"{FFFFFF}%d. %s � %d\n",i+1,name,e);
		if(strlen(body)+strlen(line)>=sizeof body-2) break;
		strcat(body,line);
	}
	if(!body[0]) format(body,sizeof body,"�����");
	ShowPlayerDialog(playerid,D_EURO_TOP,DIALOG_STYLE_MSGBOX,"{FFD700}���-50",body,"OK","");
	return 1;
}

stock ShowMenu(playerid)
{
	if(!gSQLOk) return SendClientMessage(playerid,COLOR_ERR,"�� offline"),1;
	if(!PlayerLoaded[playerid]){ LoadEuro(playerid); return SendClientMessage(playerid,COLOR_ERR,"��������..."),1; }
	UpdateRate();
	new body[900];
	format(body,sizeof body,
		"������: %d ����\n���� ��: %.2f ���.\n�������� �� ��������\n�������� �� ����\n�������� ������\n���� (ID)\n��������� (ID)\n������ (����� ID)\n����� (100000)\n������\n���-50\n��������",
		PlayerEuro[playerid],gEuroRate);
	ShowPlayerDialog(playerid,D_EURO_MENU,DIALOG_STYLE_LIST,"{FFD700}����",body,"OK","X");
	return 1;
}

stock Cmd(playerid, cmd[])
{
	if(!strcmp(cmd,"euro",true)||!strcmp(cmd,"eurobal",true)) return ShowMenu(playerid);
	if(!strcmp(cmd,"eurotop",true)) return ShowTop(playerid);
	if(!strcmp(cmd,"euroex",true)){ ShowPlayerDialog(playerid,D_EURO_EX,DIALOG_STYLE_LIST,"{FFD700}�����","���\n����","OK","X"); return 1; }
	if(!strcmp(cmd,"euroskin",true)){ ShowPlayerDialog(playerid,D_EURO_SKIN,DIALOG_STYLE_INPUT,"{FFD700}����","ID:","������","X"); return 1; }
	if(!strcmp(cmd,"euroacs",true)){ ShowPlayerDialog(playerid,D_EURO_ACS,DIALOG_STYLE_INPUT,"{FFD700}���","ID:","������","X"); return 1; }
	if(!strcmp(cmd,"eurocar",true)){ ShowPlayerDialog(playerid,D_EURO_CAR,DIALOG_STYLE_INPUT,"{FFD700}������","����� ID:","������","X"); return 1; }
	if(!strcmp(cmd,"eurofamily",true)) return StartFamilyBuy(playerid);
	if(!strcmp(cmd,"euromusic",true)) return OpenMusic(playerid);
	return 0;
}

public OnFilterScriptInit()
{
	print("  [Euro] FULL | ��� ��������� | .euro .euromusic");
	gSQLOk=0; gSQL=0;
	if(!LoadIni()) return 1;
	if(!ConnectSQL()){ print("[Euro] MySQL FAIL"); return 1; }
	gSQLOk=1;
	mysql_tquery(gSQL,"ALTER TABLE `accounts` ADD COLUMN `evro` INT NOT NULL DEFAULT 0");
	mysql_tquery(gSQL,"ALTER TABLE `accounts` ADD COLUMN `evro_exchanged` INT NOT NULL DEFAULT 0");
	UpdateRate();
	SetTimer("UpdateRate",300000,true);
	SetTimer("PayDay",30000,true);
	print("[Euro] OK");
	return 1;
}
public OnFilterScriptExit(){ if(gSQLOk) mysql_close(gSQL); return 1; }

public OnPlayerConnect(playerid)
{
	PlayerEuro[playerid]=0; PlayerEuroEx[playerid]=0; PlayerAccID[playerid]=0;
	PlayerLoaded[playerid]=false; EuroGiveTarget[playerid]=INVALID_PLAYER_ID;
	MusicBuys[playerid]=0; MusicSession[playerid]=false; MusicOn[playerid]=false; MusicPage[playerid]=1; MusicBusy[playerid]=false; MusicPendingTrack[playerid]=0; MusicPendingVeh[playerid]=0; MusicBusy[playerid]=false; MusicPendingTrack[playerid]=0; MusicPendingVeh[playerid]=0;
	FamilyNamePending[playerid][0]=0;
	SetTimerEx("LoadEuro",4000,false,"i",playerid);
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if(PlayerLoaded[playerid]) SaveEuro(playerid);
	MusicStop(playerid); MusicSession[playerid]=false;
	return 1;
}
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if((oldstate==PLAYER_STATE_DRIVER||oldstate==PLAYER_STATE_PASSENGER) && newstate!=PLAYER_STATE_DRIVER && newstate!=PLAYER_STATE_PASSENGER)
		MusicStop(playerid);
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(text[0]!='.') return 1;
	new cmd[40]; format(cmd,sizeof cmd,"%s",text[1]);
	new sp=strfind(cmd," "); if(sp!=-1) cmd[sp]=0;
	if(Cmd(playerid,cmd)) return 0;
	return 1;
}
public OnPlayerCommandText(playerid, cmdtext[])
{
	if(cmdtext[0]!='/') return 0;
	new cmd[40]; format(cmd,sizeof cmd,"%s",cmdtext[1]);
	new sp=strfind(cmd," "); if(sp!=-1) cmd[sp]=0;
	if(Cmd(playerid,cmd)) return 1;
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid==D_EURO_MENU)
	{
		if(!response) return 1;
		switch(listitem)
		{
			case 0,1: ShowMenu(playerid);
			case 2: { EuroExMode[playerid]=0; ShowPlayerDialog(playerid,D_EURO_EX_AMT,DIALOG_STYLE_INPUT,"{FFD700}���","������� ����?","OK","X"); }
			case 3: { EuroExMode[playerid]=1; ShowPlayerDialog(playerid,D_EURO_EX_AMT,DIALOG_STYLE_INPUT,"{FFD700}����","������� ����?","OK","X"); }
			case 4: ShowPlayerDialog(playerid,D_EURO_GIVE,DIALOG_STYLE_INPUT,"{FFD700}ID","ID ������:","OK","X");
			case 5: ShowPlayerDialog(playerid,D_EURO_SKIN,DIALOG_STYLE_INPUT,"{FFD700}����","ID:","OK","X");
			case 6: ShowPlayerDialog(playerid,D_EURO_ACS,DIALOG_STYLE_INPUT,"{FFD700}���","ID:","OK","X");
			case 7: ShowPlayerDialog(playerid,D_EURO_CAR,DIALOG_STYLE_INPUT,"{FFD700}������","ID:","OK","X");
			case 8: StartFamilyBuy(playerid);
			case 9: OpenMusic(playerid);
			case 10: ShowTop(playerid);
			case 11: LoadEuro(playerid);
		}
		return 1;
	}
	if(dialogid==D_EURO_EX){ if(response){ EuroExMode[playerid]=listitem; ShowPlayerDialog(playerid,D_EURO_EX_AMT,DIALOG_STYLE_INPUT,"{FFD700}�����","����:","OK","X"); } return 1; }
	if(dialogid==D_EURO_EX_AMT){ if(response) DoExchange(playerid,strval(inputtext),EuroExMode[playerid]==1); return 1; }
	if(dialogid==D_EURO_SKIN){ if(response) BuySkin(playerid,strval(inputtext)); return 1; }
	if(dialogid==D_EURO_ACS){ if(response) BuyAcs(playerid,strval(inputtext)); return 1; }
	if(dialogid==D_EURO_CAR){ if(response) BuyCar(playerid,strval(inputtext)); return 1; }
	if(dialogid==D_EURO_FAM_NAME)
	{
		if(!response) return 1;
		if(strlen(inputtext)<2||strlen(inputtext)>30) return SendClientMessage(playerid,COLOR_ERR,"2-30 ��������"),1;
		format(FamilyNamePending[playerid],32,"%s",inputtext);
		new b[120]; format(b,sizeof b,"����� �%s� �� 100000?",FamilyNamePending[playerid]);
		ShowPlayerDialog(playerid,D_EURO_FAM_OK,DIALOG_STYLE_MSGBOX,"{FFD700}�����",b,"������","X");
		return 1;
	}
	if(dialogid==D_EURO_FAM_OK){ if(response) ConfirmFamily(playerid); return 1; }
	if(dialogid==D_EURO_MUSIC_BUY){ if(response) BuyMusic(playerid); return 1; }
	if(dialogid==D_EURO_MUSIC_PAGE)
	{
		if(!response) return 1;
		new start=(MusicPage[playerid]-1)*MUSIC_PAGE_SIZE, n;
		for(new i;i<MUSIC_PAGE_SIZE;i++) if(start+i<MUSIC_TOTAL) n++;
		if(listitem<n){ MusicPlay(playerid,start+listitem); return 1; }
		if(listitem==n){ if(MusicPage[playerid]<MusicPages()) MusicPage[playerid]++; ShowMusicPage(playerid); return 1; }
		if(listitem==n+1){ if(MusicPage[playerid]>1) MusicPage[playerid]--; ShowMusicPage(playerid); return 1; }
		return 1;
	}
	if(dialogid==D_EURO_GIVE)
	{
		if(!response) return 1;
		new tid=strval(inputtext);
		if(!IsPlayerConnected(tid)||tid==playerid) return SendClientMessage(playerid,COLOR_ERR,"ID"),1;
		EuroGiveTarget[playerid]=tid;
		ShowPlayerDialog(playerid,D_EURO_GIVE_AMT,DIALOG_STYLE_INPUT,"{FFD700}�����","����:","OK","X");
		return 1;
	}
	if(dialogid==D_EURO_GIVE_AMT)
	{
		if(!response) return 1;
		new amt=strval(inputtext),tid=EuroGiveTarget[playerid];
		if(amt<=0||!IsPlayerConnected(tid)||PlayerEuro[playerid]<amt) return SendClientMessage(playerid,COLOR_ERR,"������"),1;
		PlayerEuro[playerid]-=amt; PlayerEuro[tid]+=amt; PlayerEuroEx[playerid]+=amt;
		SaveEuro(playerid); SaveEuro(tid);
		SendClientMessage(playerid,COLOR_EURO,"����������"); SendClientMessage(tid,COLOR_EURO,"�������� ����");
		return 1;
	}
	if(dialogid==D_EURO_TOP) return 1;
	return 0;
}
