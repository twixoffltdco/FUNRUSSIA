/*
	EuroSystem.pwn — Fun Russia / Kranin
	.euro .euroex .eurotop .euroskin .euroacs .eurocar .eurofamily
	Евро <-> рубли (нал/банк) по курсу ЦБ
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
#define D_EURO_BUY			29517
#define D_EURO_BUY_AMT		29518
#define D_EURO_SKIN			29520
#define D_EURO_ACS			29521
#define D_EURO_CAR			29522
#define D_EURO_FAM_NAME		29523
#define D_EURO_FAM_OK		29524

#define ITEM_SKIN			134

new Float:gEuroRate = 94.97;
new gSQL, gSQLOk;
new SQL_Host[64], SQL_User[64], SQL_Pass[128], SQL_DB[64];
new PlayerEuro[MAX_PLAYERS], PlayerEuroEx[MAX_PLAYERS], PlayerAccID[MAX_PLAYERS];
new bool:PlayerLoaded[MAX_PLAYERS];
new EuroGiveTarget[MAX_PLAYERS], EuroExMode[MAX_PLAYERS], EuroBuyMode[MAX_PLAYERS];
new LastPaydayHour = -1;
new FamilyNamePending[MAX_PLAYERS][32];

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

// Евро -> рубли
stock DoExchange(playerid, amount, toBank)
{
	if(!PlayerLoaded[playerid]) return SendClientMessage(playerid,COLOR_ERR,"Евро не загружены"),0;
	if(amount<=0||PlayerEuro[playerid]<amount) return SendClientMessage(playerid,COLOR_ERR,"Мало евро"),0;
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
	format(str,sizeof str,"{FFD700}Евровруб: -%d евро = +%d руб (%s) | ЦБ %.2f | евро: %d",
		amount,rub,toBank?"банк":"нал",gEuroRate,PlayerEuro[playerid]);
	SendClientMessage(playerid,-1,str);
	return 1;
}

// Рубли -> евро (списываем money или bank, начисляем euro)
stock BuyEuroFromRub(playerid, rub_amount, fromBank)
{
	if(!PlayerLoaded[playerid]||PlayerAccID[playerid]<1)
		return SendClientMessage(playerid,COLOR_ERR,"Евро не загружены"),0;
	if(rub_amount < 1)
		return SendClientMessage(playerid,COLOR_ERR,"Сумма в рублях"),0;
	if(gEuroRate < 1.0)
		return SendClientMessage(playerid,COLOR_ERR,"Курс ещё не загружен"),0;

	new euro = floatround(float(rub_amount) / gEuroRate, floatround_floor);
	if(euro < 1)
	{
		new need = floatround(gEuroRate, floatround_ceil);
		new str[120];
		format(str,sizeof str,"Мало: на 1 евро нужно ~%d руб. (курс %.2f)",need,gEuroRate);
		return SendClientMessage(playerid,COLOR_ERR,str),0;
	}
	// фактические рубли за целое число евро
	new cost = floatround(float(euro) * gEuroRate, floatround_ceil);
	if(cost < 1) cost = 1;

	EuroBuyMode[playerid] = fromBank ? 1 : 0;
	new q[280];
	if(fromBank)
	{
		mysql_format(gSQL,q,sizeof q,
			"SELECT IFNULL(`bank`,0) FROM `accounts` WHERE `id`=%d LIMIT 1",PlayerAccID[playerid]);
		mysql_tquery(gSQL,q,"OnBuyEuroCheck","iii",playerid,euro,cost);
	}
	else
	{
		// нал: проверяем GetPlayerMoney + money в БД
		mysql_format(gSQL,q,sizeof q,
			"SELECT IFNULL(`money`,0) FROM `accounts` WHERE `id`=%d LIMIT 1",PlayerAccID[playerid]);
		mysql_tquery(gSQL,q,"OnBuyEuroCheck","iii",playerid,euro,cost);
	}
	return 1;
}

forward OnBuyEuroCheck(playerid, euro, cost);
public OnBuyEuroCheck(playerid, euro, cost)
{
	if(!IsPlayerConnected(playerid)||!PlayerLoaded[playerid]) return 1;
	new have = 0;
	if(cache_get_row_count(gSQL) > 0)
		have = cache_get_row_int(0, 0, gSQL);

	new fromBank = EuroBuyMode[playerid];
	if(!fromBank)
	{
		new pm = GetPlayerMoney(playerid);
		if(pm > have) have = pm;
	}

	if(have < cost)
	{
		new str[128];
		format(str,sizeof str,"Нужно %d руб. (%s), есть %d. За %d евро.",
			cost, fromBank?"банк":"нал", have, euro);
		SendClientMessage(playerid,COLOR_ERR,str);
		return 1;
	}

	new q[300];
	if(fromBank)
	{
		mysql_format(gSQL,q,sizeof q,
			"UPDATE `accounts` SET `bank`=IFNULL(`bank`,0)-%d WHERE `id`=%d AND IFNULL(`bank`,0)>=%d LIMIT 1",
			cost, PlayerAccID[playerid], cost);
		mysql_tquery(gSQL,q);
	}
	else
	{
		mysql_format(gSQL,q,sizeof q,
			"UPDATE `accounts` SET `money`=IFNULL(`money`,0)-%d WHERE `id`=%d LIMIT 1",
			cost, PlayerAccID[playerid]);
		mysql_tquery(gSQL,q);
		if(GetPlayerMoney(playerid) >= cost)
			GivePlayerMoney(playerid, -cost);
	}

	PlayerEuro[playerid] += euro;
	SaveEuro(playerid);

	new str[160];
	format(str,sizeof str,"{FFD700}Руб = евро: -%d руб (%s) = +%d евро | ЦБ %.2f | евро: %d",
		cost, fromBank?"банк":"нал", euro, gEuroRate, PlayerEuro[playerid]);
	SendClientMessage(playerid,-1,str);
	if(fromBank)
		SendClientMessage(playerid,COLOR_EURO,"Банк списан в БД. Если в игре не обновилось — зайди в банк/релог.");
	return 1;
}

stock BuySkin(playerid, modelid)
{
	if(modelid<1) return SendClientMessage(playerid,COLOR_ERR,"Неверный ID"),0;
	if(!PlayerLoaded[playerid]) return 0;
	new price=25+(modelid%80); if(modelid>1000) price=100+(modelid%120);
	if(PlayerEuro[playerid]<price) return SendClientMessage(playerid,COLOR_ERR,"Мало евро"),0;
	PlayerEuro[playerid]-=price; SaveEuro(playerid);
	new acc=PlayerAccID[playerid],q[400];
	mysql_format(gSQL,q,sizeof q,"INSERT INTO `invskins` (`account_id`,`internal_id`,`modelid`) VALUES (%d,%d,%d)",acc,modelid,modelid);
	mysql_tquery(gSQL,q);
	mysql_format(gSQL,q,sizeof q,"INSERT INTO `inventory` (`account_id`,`item_id`,`model_id`,`old_skin`,`slot`,`amount`,`extra_1`,`extra_2`,`sim`,`oldsim`,`source_internal_id`) SELECT %d,%d,%d,0,IFNULL(MAX(`slot`),0)+1,1,0,0,0,0,%d FROM `inventory` WHERE `account_id`=%d",acc,ITEM_SKIN,modelid,modelid,acc);
	mysql_tquery(gSQL,q);
	SetPlayerSkin(playerid,modelid);
	new str[96]; format(str,sizeof str,"{FFD700}Скин %d за %d евро",modelid,price);
	SendClientMessage(playerid,-1,str);
	return 1;
}

stock BuyAcs(playerid, modelid)
{
	if(modelid<1) return SendClientMessage(playerid,COLOR_ERR,"Неверный ID"),0;
	if(!PlayerLoaded[playerid]) return 0;
	new price=35+(modelid%90); if(modelid>10000) price=80+(modelid%100);
	if(PlayerEuro[playerid]<price) return SendClientMessage(playerid,COLOR_ERR,"Мало евро"),0;
	PlayerEuro[playerid]-=price; SaveEuro(playerid);
	new acc=PlayerAccID[playerid],q[400];
	mysql_format(gSQL,q,sizeof q,"INSERT INTO `accessory_inventory` (`player_id`,`acs_id`,`use`) VALUES (%d,%d,0)",acc,modelid);
	mysql_tquery(gSQL,q);
	mysql_format(gSQL,q,sizeof q,"INSERT INTO `inventory` (`account_id`,`item_id`,`model_id`,`old_skin`,`slot`,`amount`,`extra_1`,`extra_2`,`sim`,`oldsim`,`source_internal_id`) SELECT %d,%d,%d,0,IFNULL(MAX(`slot`),0)+1,1,0,0,0,0,0 FROM `inventory` WHERE `account_id`=%d",acc,modelid,modelid,acc);
	mysql_tquery(gSQL,q);
	new str[96]; format(str,sizeof str,"{FFD700}Акс %d за %d евро",modelid,price);
	SendClientMessage(playerid,-1,str);
	return 1;
}

stock BuyCar(playerid, modelid)
{
	if(modelid<1) return SendClientMessage(playerid,COLOR_ERR,"Неверный ID"),0;
	if(!PlayerLoaded[playerid]) return 0;
	new price=150+(modelid%250);
	if(PlayerEuro[playerid]<price) return SendClientMessage(playerid,COLOR_ERR,"Мало евро"),0;
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
	new str[112]; format(str,sizeof str,"{FFD700}Машина %d за %d евро",modelid,price);
	SendClientMessage(playerid,-1,str);
	return 1;
}

stock StartFamilyBuy(playerid)
{
	if(!PlayerLoaded[playerid]) return 0;
	if(PlayerEuro[playerid]<EURO_FAMILY_PRICE) return SendClientMessage(playerid,COLOR_ERR,"Нужно 100000 евро"),0;
	ShowPlayerDialog(playerid,D_EURO_FAM_NAME,DIALOG_STYLE_INPUT,"{FFD700}Семья","Название семьи (2-30):","Далее","Отмена");
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
	if(fid>0) return SendClientMessage(playerid,COLOR_ERR,"Уже в семье"),1;
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
	new str[120]; format(str,sizeof str,"{FFD700}Семья «%s» id %d, лидер. Релог!",FamilyNamePending[playerid],id);
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
	SendClientMessage(playerid,COLOR_EURO,"Семья создана. Релог!");
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
	{ PlayerEuro[i]+=EURO_PAYDAY; SendClientMessage(i,COLOR_EURO,"PayDay +10 евро"); }
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
		if(i==0) format(line,sizeof line,"{FFD700}1. %s — %d (золото)\n",name,e);
		else if(i==1) format(line,sizeof line,"{C0C0C0}2. %s — %d (серебро)\n",name,e);
		else if(i==2) format(line,sizeof line,"{CD7F32}3. %s — %d (бронза)\n",name,e);
		else format(line,sizeof line,"{FFFFFF}%d. %s — %d\n",i+1,name,e);
		if(strlen(body)+strlen(line)>=sizeof body-2) break;
		strcat(body,line);
	}
	if(!body[0]) format(body,sizeof body,"Пусто");
	ShowPlayerDialog(playerid,D_EURO_TOP,DIALOG_STYLE_MSGBOX,"{FFD700}Топ-50",body,"OK","");
	return 1;
}

stock ShowMenu(playerid)
{
	if(!gSQLOk) return SendClientMessage(playerid,COLOR_ERR,"БД offline"),1;
	if(!PlayerLoaded[playerid]){ LoadEuro(playerid); return SendClientMessage(playerid,COLOR_ERR,"Загрузка..."),1; }
	UpdateRate();
	new body[1000];
	format(body,sizeof body,
		"Баланс: %d евро\n\
		Курс ЦБ: 1 евро = %.2f руб.\n\
		Евро через наличные\n\
		Евро через банк\n\
		Рубли (нал) в евро\n\
		Банк в евро\n\
		Передать игроку\n\
		Скин (ID)\n\
		Аксессуар (ID)\n\
		Машина (любой ID)\n\
		Семья (100000)\n\
		Топ-50\n\
		Обновить",
		PlayerEuro[playerid],gEuroRate);
	ShowPlayerDialog(playerid,D_EURO_MENU,DIALOG_STYLE_LIST,"{FFD700}Евро",body,"OK","X");
	return 1;
}

stock Cmd(playerid, cmd[])
{
	if(!strcmp(cmd,"euro",true)||!strcmp(cmd,"eurobal",true)) return ShowMenu(playerid);
	if(!strcmp(cmd,"eurotop",true)) return ShowTop(playerid);
	if(!strcmp(cmd,"euroex",true))
	{
		ShowPlayerDialog(playerid,D_EURO_EX,DIALOG_STYLE_LIST,"{FFD700}Обмен",
			"Евро в нал\nЕвро в банк\nНал в евро\nБанк в евро","OK","X");
		return 1;
	}
	if(!strcmp(cmd,"euroskin",true)){ ShowPlayerDialog(playerid,D_EURO_SKIN,DIALOG_STYLE_INPUT,"{FFD700}Скин","ID:","Купить","X"); return 1; }
	if(!strcmp(cmd,"euroacs",true)){ ShowPlayerDialog(playerid,D_EURO_ACS,DIALOG_STYLE_INPUT,"{FFD700}Акс","ID:","Купить","X"); return 1; }
	if(!strcmp(cmd,"eurocar",true)){ ShowPlayerDialog(playerid,D_EURO_CAR,DIALOG_STYLE_INPUT,"{FFD700}Машина","Любой ID:","Купить","X"); return 1; }
	if(!strcmp(cmd,"eurofamily",true)) return StartFamilyBuy(playerid);
	return 0;
}

public OnFilterScriptInit()
{
	print("  [Euro] без музыки | руб<->евро | .euro .euroex");
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
	EuroExMode[playerid]=0; EuroBuyMode[playerid]=0;
	FamilyNamePending[playerid][0]=0;
	SetTimerEx("LoadEuro",4000,false,"i",playerid);
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if(PlayerLoaded[playerid]) SaveEuro(playerid);
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
			case 2: // euro -> cash
			{
				EuroExMode[playerid]=0;
				ShowPlayerDialog(playerid,D_EURO_EX_AMT,DIALOG_STYLE_INPUT,"{FFD700}Евро?нал","Сколько ЕВРО обменять?","OK","X");
			}
			case 3: // euro -> bank
			{
				EuroExMode[playerid]=1;
				ShowPlayerDialog(playerid,D_EURO_EX_AMT,DIALOG_STYLE_INPUT,"{FFD700}Евро?банк","Сколько ЕВРО обменять?","OK","X");
			}
			case 4: // cash -> euro
			{
				EuroBuyMode[playerid]=0;
				ShowPlayerDialog(playerid,D_EURO_BUY_AMT,DIALOG_STYLE_INPUT,"{FFD700}Нал?евро","Сколько РУБЛЕЙ потратить?","OK","X");
			}
			case 5: // bank -> euro
			{
				EuroBuyMode[playerid]=1;
				ShowPlayerDialog(playerid,D_EURO_BUY_AMT,DIALOG_STYLE_INPUT,"{FFD700}Банк?евро","Сколько РУБЛЕЙ с банка?","OK","X");
			}
			case 6: ShowPlayerDialog(playerid,D_EURO_GIVE,DIALOG_STYLE_INPUT,"{FFD700}ID","ID игрока:","OK","X");
			case 7: ShowPlayerDialog(playerid,D_EURO_SKIN,DIALOG_STYLE_INPUT,"{FFD700}Скин","ID:","OK","X");
			case 8: ShowPlayerDialog(playerid,D_EURO_ACS,DIALOG_STYLE_INPUT,"{FFD700}Акс","ID:","OK","X");
			case 9: ShowPlayerDialog(playerid,D_EURO_CAR,DIALOG_STYLE_INPUT,"{FFD700}Машина","ID:","OK","X");
			case 10: StartFamilyBuy(playerid);
			case 11: ShowTop(playerid);
			case 12: LoadEuro(playerid);
		}
		return 1;
	}
	if(dialogid==D_EURO_EX)
	{
		if(!response) return 1;
		if(listitem==0||listitem==1)
		{
			EuroExMode[playerid]=listitem;
			ShowPlayerDialog(playerid,D_EURO_EX_AMT,DIALOG_STYLE_INPUT,"{FFD700}Евро?руб","Сколько ЕВРО?","OK","X");
		}
		else
		{
			EuroBuyMode[playerid]=(listitem==3)?1:0;
			ShowPlayerDialog(playerid,D_EURO_BUY_AMT,DIALOG_STYLE_INPUT,"{FFD700}Руб?евро","Сколько РУБЛЕЙ?","OK","X");
		}
		return 1;
	}
	if(dialogid==D_EURO_EX_AMT)
	{
		if(response) DoExchange(playerid,strval(inputtext),EuroExMode[playerid]==1);
		return 1;
	}
	if(dialogid==D_EURO_BUY_AMT)
	{
		if(response) BuyEuroFromRub(playerid,strval(inputtext),EuroBuyMode[playerid]==1);
		return 1;
	}
	if(dialogid==D_EURO_SKIN){ if(response) BuySkin(playerid,strval(inputtext)); return 1; }
	if(dialogid==D_EURO_ACS){ if(response) BuyAcs(playerid,strval(inputtext)); return 1; }
	if(dialogid==D_EURO_CAR){ if(response) BuyCar(playerid,strval(inputtext)); return 1; }
	if(dialogid==D_EURO_FAM_NAME)
	{
		if(!response) return 1;
		if(strlen(inputtext)<2||strlen(inputtext)>30) return SendClientMessage(playerid,COLOR_ERR,"2-30 символов"),1;
		format(FamilyNamePending[playerid],32,"%s",inputtext);
		new b[120]; format(b,sizeof b,"Семья «%s» за 100000?",FamilyNamePending[playerid]);
		ShowPlayerDialog(playerid,D_EURO_FAM_OK,DIALOG_STYLE_MSGBOX,"{FFD700}Семья",b,"Купить","X");
		return 1;
	}
	if(dialogid==D_EURO_FAM_OK){ if(response) ConfirmFamily(playerid); return 1; }
	if(dialogid==D_EURO_GIVE)
	{
		if(!response) return 1;
		new tid=strval(inputtext);
		if(!IsPlayerConnected(tid)||tid==playerid) return SendClientMessage(playerid,COLOR_ERR,"ID"),1;
		EuroGiveTarget[playerid]=tid;
		ShowPlayerDialog(playerid,D_EURO_GIVE_AMT,DIALOG_STYLE_INPUT,"{FFD700}Сумма","Евро:","OK","X");
		return 1;
	}
	if(dialogid==D_EURO_GIVE_AMT)
	{
		if(!response) return 1;
		new amt=strval(inputtext),tid=EuroGiveTarget[playerid];
		if(amt<=0||!IsPlayerConnected(tid)||PlayerEuro[playerid]<amt) return SendClientMessage(playerid,COLOR_ERR,"Нельзя"),1;
		PlayerEuro[playerid]-=amt; PlayerEuro[tid]+=amt; PlayerEuroEx[playerid]+=amt;
		SaveEuro(playerid); SaveEuro(tid);
		SendClientMessage(playerid,COLOR_EURO,"Отправлено"); SendClientMessage(tid,COLOR_EURO,"Получили евро");
		return 1;
	}
	if(dialogid==D_EURO_TOP) return 1;
	return 0;
}
