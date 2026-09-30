/*
	host_keepalive.pwn
	BEZ NPC (HostGTA zapreshchaet).

	Tolko OnSendPlayerCount - dlya SA-MP query / brauzera.
	Panel HostGTA chasto pokazyvaet REAL online - bez NPC
	ee nelzya nacrutit. Togda:
	  - derzhi 1 realnogo igroka
	  - ili plugin FakeOnline.esli host chitaet query
	  - ili platnyy tarif

	Cfg: scriptfiles/host_keepalive.ini
*/

#define FILTERSCRIPT
#include <a_samp>

#define HK_CFG "host_keepalive.ini"

new gEnabled = 1;
new gMinOnline = 5;
new gFakeOnline = 25;
new gRandomRange = 5;
new gTimer = -1;

stock HK_Trim(str[])
{
	new len = strlen(str);
	while(len > 0 && (str[len-1] == '\r' || str[len-1] == '\n' || str[len-1] == ' ' || str[len-1] == '\t'))
	{ str[len-1] = 0; len--; }
	new st = 0;
	while(str[st] == ' ' || str[st] == '\t') st++;
	if(st > 0)
	{
		new i;
		for(i = 0; str[st+i]; i++) str[i] = str[st+i];
		str[i] = 0;
	}
	return 1;
}

stock HK_LoadCfg()
{
	if(!fexist(HK_CFG))
	{
		new File:fw = fopen(HK_CFG, io_write);
		if(fw)
		{
			fwrite(fw, "Enabled=1\r\nMinOnline=5\r\nFakeOnline=25\r\nRandomRange=5\r\n");
			fclose(fw);
		}
	}
	new File:f = fopen(HK_CFG, io_read);
	if(!f) return 0;
	new line[128];
	while(fread(f, line))
	{
		HK_Trim(line);
		if(!line[0] || line[0] == ';' || line[0] == '#') continue;
		new eq = -1, i;
		for(i = 0; line[i]; i++) if(line[i] == '=') { eq = i; break; }
		if(eq <= 0) continue;
		new key[32], val[32], k = eq;
		if(k > 31) k = 31;
		for(i = 0; i < k; i++) key[i] = line[i];
		key[k] = 0; HK_Trim(key);
		new v = 0; i = eq + 1;
		while(line[i] && v < 31) { val[v] = line[i]; v++; i++; }
		val[v] = 0; HK_Trim(val);
		if(!strcmp(key, "Enabled", true)) gEnabled = strval(val);
		else if(!strcmp(key, "MinOnline", true)) gMinOnline = strval(val);
		else if(!strcmp(key, "FakeOnline", true)) gFakeOnline = strval(val);
		else if(!strcmp(key, "RandomRange", true)) gRandomRange = strval(val);
	}
	fclose(f);
	if(gMinOnline < 1) gMinOnline = 1;
	if(gFakeOnline < gMinOnline) gFakeOnline = gMinOnline;
	return 1;
}

forward OnSendPlayerCount(count);
public OnSendPlayerCount(count)
{
	#pragma unused count
	if(!gEnabled) return count;
	new show = gFakeOnline;
	if(gRandomRange > 0)
		show += random(gRandomRange * 2 + 1) - gRandomRange;
	if(show < gMinOnline) show = gMinOnline;

	// esli realnyh bolshe - ne zanizhat
	new realc, i;
	for(i = 0; i < MAX_PLAYERS; i++)
		if(IsPlayerConnected(i) && !IsPlayerNPC(i)) realc++;
	if(realc > show) show = realc;
	return show;
}

// sovmestimost so starym FakeOnline pluginom (esli est)
forward FakeOnline_Reload();
public FakeOnline_Reload()
{
	HK_LoadCfg();
	return 1;
}

forward HK_Tick();
public HK_Tick()
{
	HK_LoadCfg();
	return 1;
}

public OnFilterScriptInit()
{
	HK_LoadCfg();
	gTimer = SetTimer("HK_Tick", 60000, true);
	print(" ");
	print("  [HOST_KEEPALIVE] BEZ NPC (HostGTA ban)");
	print("  [HOST_KEEPALIVE] Tolko SA-MP query fake online");
	printf("  [HOST_KEEPALIVE] FakeOnline=%d Min=%d", gFakeOnline, gMinOnline);
	print("  [HOST_KEEPALIVE] Esli panel hosta = 0, nuzhen plugin FakeOnline");
	print("  [HOST_KEEPALIVE] ili 1 zhivoy igrok / platnyy tarif");
	print(" ");
	return 1;
}

public OnFilterScriptExit()
{
	if(gTimer != -1) KillTimer(gTimer);
	return 1;
}
