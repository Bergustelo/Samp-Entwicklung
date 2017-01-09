#include <a_samp>
#include <a_mysql>
#include <sscanf2.inc>
#include <ocmd>
#include <streamer>


#define MYSQL_HOST "127.0.0.1"
#define MYSQL_USER "root"
#define MYSQL_PASS ""
#define MYSQL_DBSE "entwicklung"
new MySQL:handle;

//Forward definierungsbereich
forward OnUserCheck(playerid);
forward OnUserRegister(playerid);
forward OnUserLogin(playerid);
forward spielerfahrzeug(carid);
forward Pfanddazu();

//Farben

#define rot 0xFF0000FF
#define grün 0x55FF00FF
#define helblau 0x00AEFFFF
#define dunkelblau 0x0009FFFF
#define hellgrün 0x00FF00FF
#define duneklhelblau 0x225DC8FF
#define gelb 0xE9D700D3
#define türkis 0x00938CD3
#define blau 0x2E4680FF
#define weiß 0xFFFFFFFF
#define pink 0xFF00FFBD
#define grau 0x0B000097
#define orange 0x9E2F00FF
//


//Diagloge definierungsbereich
#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
#define DIALOG_LADEN 3
#define DIALOG_AUTOHAUS 4
#define DIALOG_MOTORSYSTEM 5
//

//Spieler Information
enum pDataEnum
{
	p_id,
	bool:eingeloggt,
	pname[MAX_PLAYER_NAME],
	level,
	admin,
	pmoney,
	fraktion,
	frank,
	spawn
}
new PlayerInfo[MAX_PLAYER_NAME][pDataEnum];
//
enum frakteEnum{

	f_name[300],
	Float:f_x,
	Float:f_y,
	Float:f_z,
	Float:f_r,
	f_inter,
	f_world,
	f_color
}
new fInfo[][frakteEnum] ={
{"Zivilist",329.0244,-1513.3033,36.0391,225.8344,0,0,weiß},//Zivilist 0
{"SAPD",213.4162,162.7460,1003.0234,274.4569,3,1,blau},//SAPD 1
{"SWAT",2731.5903,-2450.0164,17.5937,272.4424,0,0,helblau},//SWAT2
{"FBI",2286.9651,2431.6011,10.8203,176.4887,0,0,duneklhelblau},//FBI3
{"ARMY",214.2768,1822.5925,6.4141,265.0869,0,0,hellgrün},//ARMY4
{"Medic/Feuerwehr",302.9467,-1505.8025,24.6007,231.6743,0,0,rot},//MEDIC5
{"Fahrschule",2124.3032,-2273.0491,20.6719,221.7338,0,0,orange},//Fahrschule6
{"Aztecas",2788.4141,-1944.7075,13.5469,87.2128,0,0,türkis},//AZTECAS7
{"Vagos",204.6566,39.7421,2.5781,260.2514,0,0,gelb},//Vagos8
{"Ballas",1084.8976,-1226.7927,15.8203,269.7700,0,0,pink},//Ballas9
{"Yakuza",-2188.6282,-2265.0452,30.6250,71.4091,0,0,grau}//Yakuza10
};
enum fahrzeugEnum
{
	faid,
	besitzer[MAX_PLAYER_NAME],
	model,
	Float:c_x,
	Float:c_y,
	Float:c_z,
	Float:c_r
}
new cInfo[50][fahrzeugEnum];
enum repairpoint{
	Float: r_x,
	Float:r_y,
	Float:r_z
}
new repair[][repairpoint]={
{2458.3711,1697.3431,18.3761},//repair1
{2453.4429,1697.5092,18.3761},//repair2
{2448.3379,1697.4446,18.3761},//repair3
{2443.7251,1697.3724,18.3761}//repair4
};
enum buildingsEnum
{
	Float:b_x,
	Float:b_y,
	Float:b_z,
	Float:bi_x,
	Float:bi_y,
	Float:bi_z,
	b_interior	
}
new bInfo[][buildingsEnum]=
{
	{1310.1149,-1366.8008,13.5066,246.0798,107.5067,1003.2188,10}
};

enum muellEnum
{
	pfand,
	Float:m_x,
	Float:m_y,
	Float:m_z,
	Float:m_rx,
	Float:m_ry,
	Float:m_rz
}
new muell[][muellEnum]= 
{
	{ 10,1166.94946, -1385.97058, 13.46930,   0.00000, 0.00000, 0.00000},
	{ 10,1164.48853, -1385.97058, 13.46930,   0.00000, 0.00000, 0.00000},
	{ 10,1162.02515, -1385.97058, 13.46930,   0.00000, 0.00000, 0.00000}
};
new Flaschen[MAX_PLAYERS];

new autosOhneMotor[] = {
	481,
	509,
	510

};
enum autohausEnum{
Float:v_x,
Float:v_y,
Float:v_z,
Float:v_r
}
enum autohauscarEnum{
	model,
	Float:ah_x,
	Float:ah_y,
	Float:ah_z,
	Float:ah_r,
	c_preis,
	ah_id,
	id_x
}
new ahCars[][autohauscarEnum] ={
{411,2516.8420,1698.8502,10.7281,89.2039,60000000,0},
{560,2516.0205,1694.6085,10.7244,89.9459,50000000,0},
{470,2516.0212,1687.2047,10.7218,90.9615,999999999,0},
{415,2507.2310,1688.0667,10.7222,358.2454,60000,0},
{429,2492.5933,1688.0917,10.7217,359.9845,50000,0},
{451,2485.9338,1679.5812,10.7278,0.4211,30000,0}
};
new ahInfo[][autohausEnum]={
{2481.2991,1671.2750,16.3001,95.0682}
};



main()
{
	print("\n----------------------------------");
	print(" Kraft und Ehre");
	print("----------------------------------\n");
}
public OnGameModeInit()
{
	// Don't use these lines if it's a filterscript
	SetGameModeText("Kraft und Ehre");
	AddPlayerClass(115,1159.6151,-1381.1644,13.6522,357.9040,0,0,0,0,0,0);
	AddPlayerClass(21,1159.6151,-1381.1644,13.6522,357.9040,0,0,0,0,0,0);
	AddPlayerClass(29,1159.6151,-1381.1644,13.6522,357.9040,0,0,0,0,0,0);
	AddPlayerClass(30,1159.6151,-1381.1644,13.6522,357.9040,0,0,0,0,0,0);
	AddPlayerClass(48,1159.6151,-1381.1644,13.6522,357.9040,0,0,0,0,0,0);
	SendRconCommand("mapname <Las Santos>");
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	ManualVehicleEngineAndLights();

	//Gebäude laden
	for(new i=0; i<sizeof(bInfo); i++)
	{
		CreatePickup(1239,1,bInfo[i][b_x],bInfo[i][b_y],bInfo[i][b_z]);
		Create3DTextLabel("Zum Betreten /enter",grün,bInfo[i][b_x],bInfo[i][b_y],bInfo[i][b_x],10,0,1);
	}
	//icon für Repair:
	for(new i=0; i<sizeof(repair); i++)
	{
		CreatePickup(1239,1,repair[i][r_x],repair[i][r_y],repair[i][r_z]);
		Create3DTextLabel("Um das Fahrzeug zu reparieren benutzen sie bitte /reparieren.\nDas Reparieren kostet dich nur 60$",duneklhelblau,repair[i][r_x],repair[i][r_y],repair[i][r_z],10,0,1);
	}
	mysql_setupconnection();
	for(new i=0; i<sizeof(muell); i++)
	{
		CreateDynamicObject(1344,muell[i][m_x],muell[i][m_y],muell[i][m_z],muell[i][m_rx],muell[i][m_ry],muell[i][m_rz]);
	}
	SetTimer("Pfanddazu",3000,false);
	return 1;
}

public OnGameModeExit()
{
	mysql_close(handle);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	//AddPlayerClass(115,1158.9497,-1372.6090,13.6522,180.2423,0,0,0,0,0,0); // facingangel
	SetPlayerPos(playerid,1159.6151,-1381.1644,13.6522);
	SetPlayerCameraPos(playerid,1159.6006,-1378.7272,13.6522);
	SetPlayerCameraLookAt(playerid,1159.6151,-1381.1644,13.6522);
	SetPlayerFacingAngle(playerid,357.9040);
	
	//Wenn der Spieler die Class-Selection betritt prüfe ob er bereits eingeloggt ist
	if(!PlayerInfo[playerid][eingeloggt])
	{
		//Wenn nicht, dann prüfe ob der Spieler ein Konto hat
		new query[128];
		mysql_format(handle,query,sizeof(query),"SELECT id FROM account WHERE name = '%e'",PlayerInfo[playerid][pname]);
		
		//Das Query wird abgesendet und die Playerid an OnUserCheck übergeben
		mysql_pquery(handle,query,"OnUserCheck","d",playerid);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	PlayerInfo[playerid][p_id] =0;
	PlayerInfo[playerid][eingeloggt] = false;
	PlayerInfo[playerid][level] = 1;
	PlayerInfo[playerid][admin] = 0;
	PlayerInfo[playerid][pmoney] = 0;
	PlayerInfo[playerid][fraktion] = 0;
	PlayerInfo[playerid][frank] = 0;
	PlayerInfo[playerid][spawn] = 0;
	GetPlayerName(playerid,PlayerInfo[playerid][pname],MAX_PLAYER_NAME);
	SetPlayerColor(playerid,weiß);
	SetPlayerScore(playerid,PlayerInfo[playerid][level]);
	RemoveBuildingForPlayer(playerid, 1529, 1098.8125, -1292.5469, 17.1406, 0.25);
	RemoveBuildingForPlayer(playerid, 5930, 1134.2500, -1338.0781, 23.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 5931, 1114.3125, -1348.1016, 17.9844, 0.25);
	RemoveBuildingForPlayer(playerid, 5934, 1076.7109, -1358.0938, 15.4453, 0.25);
	RemoveBuildingForPlayer(playerid, 5935, 1120.1563, -1303.4531, 18.5703, 0.25);
	RemoveBuildingForPlayer(playerid, 5936, 1090.0547, -1310.5313, 17.5469, 0.25);
	RemoveBuildingForPlayer(playerid, 1440, 1085.7031, -1361.0234, 13.2656, 0.25);
	RemoveBuildingForPlayer(playerid, 5731, 1076.7109, -1358.0938, 15.4453, 0.25);
	RemoveBuildingForPlayer(playerid, 5788, 1080.9844, -1305.5234, 16.3594, 0.25);
	RemoveBuildingForPlayer(playerid, 5787, 1090.0547, -1310.5313, 17.5469, 0.25);
	RemoveBuildingForPlayer(playerid, 5764, 1065.1406, -1270.5781, 25.7109, 0.25);
	RemoveBuildingForPlayer(playerid, 5810, 1114.3125, -1348.1016, 17.9844, 0.25);
	RemoveBuildingForPlayer(playerid, 5993, 1110.8984, -1328.8125, 13.8516, 0.25);
	RemoveBuildingForPlayer(playerid, 5811, 1131.1953, -1380.4219, 17.0703, 0.25);
	RemoveBuildingForPlayer(playerid, 5708, 1134.2500, -1338.0781, 23.1563, 0.25);
	RemoveBuildingForPlayer(playerid, 1440, 1141.9844, -1346.1094, 13.2656, 0.25);
	RemoveBuildingForPlayer(playerid, 1440, 1148.6797, -1385.1875, 13.2656, 0.25);
	RemoveBuildingForPlayer(playerid, 617, 1178.6016, -1332.0703, 12.8906, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1184.0078, -1353.5000, 12.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1184.0078, -1343.2656, 12.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 5737, 1120.1563, -1303.4531, 18.5703, 0.25);
	RemoveBuildingForPlayer(playerid, 618, 1177.7344, -1315.6641, 13.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1184.8125, -1292.9141, 12.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1184.8125, -1303.1484, 12.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 14851, 246.2500, 118.1484, 1005.9063, 0.25);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SaveUserStats(playerid);
	
	return 1;
}
public spielerfahrzeug(carid)
{
	 cInfo[carid][faid]=cache_insert_id(handle);
	 return 1;
}

 carinDB(playerid,carid)
 {
	new query[128];
	format(query,sizeof(query),"INSERT INTO spielerfahrzeuge(besitzer,model,x,y,z,r) VALUES('%i','%i','%f','%f','%f','%f')",PlayerInfo[playerid][p_id],cInfo[carid][model],cInfo[carid][c_x],cInfo[carid][c_y],cInfo[carid][c_z],cInfo[carid][c_r]);
	return 1;
}
public Pfanddazu()
{
	for(new i=0; i<sizeof(muell); i++)
	{
		muell[i][pfand]+=1;
	}
	new randomsekunden[]=
	{
		30,
		60,
		90,
		180,
		240,
		300
	};
	new randomtime = random(sizeof(randomsekunden));
	SetTimer("Pfanddazu",1000*randomsekunden[randomtime],false);
	return 1;
}
public OnPlayerSpawn(playerid)
{
	if(!isPlayerInFrakt(playerid,0))
	{
		if(PlayerInfo[playerid][spawn]==1)
		{


			new fID;
			fID= PlayerInfo[playerid][fraktion];
			SetPlayerPos(playerid,fInfo[fID][f_x],fInfo[fID][f_y],fInfo[fID][f_z]);
			SetPlayerFacingAngle(playerid,fInfo[fID][f_r]);
			SetPlayerInterior(playerid,fInfo[fID][f_inter]);
			SetPlayerVirtualWorld(playerid,fInfo[fID][f_world]);
			SetPlayerColor(playerid,fInfo[fID][f_color]);
		}
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

PlayerCar(playerid,modelid,Float:x,Float:y,Float:z,Float:r)
{
	for(new i=0; i<sizeof(cInfo); i++)
	{
		if(cInfo[i][faid]!=0)continue;
		
		GetPlayerName(playerid,cInfo[i][besitzer],MAX_PLAYER_NAME);
		cInfo[i][c_x] =x;
		cInfo[i][c_y] =y;
		cInfo[i][c_z] =z;
		cInfo[i][c_r] =r;
		cInfo[i][model]=modelid;
		cInfo[i][faid] = CreateVehicle(modelid,x,y,z,r,-1,-1,-1);
		new string[128];
		format(string,sizeof(string),"Das Fahrzeug cInfo[%i] wurde erstellt",i);
		SendClientMessageToAll(rot,string);
		carinDB(playerid,i);
		return 1;
	}
	return 1;
}
public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate==PLAYER_STATE_DRIVER)
	{
		new vID=GetPlayerVehicleID(playerid);
		new vModel=GetVehicleModel(vID);

		for(new i=0; i<sizeof(autosOhneMotor); i++)
		{
			if(autosOhneMotor[i]!=vModel)continue;
			new motor,
			licht,
			alarm,
			tueren,
			bonnet,
			boot,
			objective;

			//Motor an/ausschalten:
			GetVehicleParamsEx(vID,motor,licht,alarm,tueren,bonnet,boot,objective);
			SetVehicleParamsEx(vID,1,licht,alarm,tueren,bonnet,boot,objective);
				}

		for(new i=0; i<sizeof(ahCars); i++)
		{
			if(ahCars[i][id_x] !=vID)continue;
			//Verkaufsprozess:
			SetPVarInt(playerid,"buyCarID",i);
			new string[500];
			format(string,sizeof(string),"Möchten sie das Fahrzeug für %i$ kaufen?",ahCars[i][c_preis]);
			ShowPlayerDialog(playerid,DIALOG_AUTOHAUS,DIALOG_STYLE_MSGBOX,"Autoverkauf",string,"Kaufen","Nicht kaufen");
			break;
		}
		return 1;
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}
isAdmin(playerid,a_level)
{
	if(PlayerInfo[playerid][admin]>=a_level)return 1;
	return 0;
}
isPlayerInFrakt(playerid,f_id){
	if(PlayerInfo[playerid][fraktion]==f_id)return 1;
	return 0;
}
// Befehle
ocmd:pfandsuchen(playerid,params[])
{
	for(new i=0; i<sizeof(muell); i++)
	{
	    if(IsPlayerInRangeOfPoint(playerid,3,muell[i][m_x], muell[i][m_y], muell[i][m_z]))
	    {
			if(muell[i][pfand]>=1)//kann man verändern z.b da man erst ab 5 flaschen diese findet
			{
				Flaschen[playerid]+=muell[i][pfand];
				new string[150];
				format(string,sizeof(string), "~w~Du hast ~g~%i ~w~Pfandflschen gefunden", muell[i][pfand]);
				GameTextForPlayer(playerid, string, 3000, 4);
				muell[i][pfand]=0;
				// mann kann noch eine Animation hinzufügen
				return 1;
			}
		        else
		        {
		          SendClientMessage(playerid,rot,"Die Mülltonne ist leer");// müsst ihr selber anpassen
		          return 1;
		        } 
	    }
	}
	return SendClientMessage(playerid,rot,"Du bist bei keiner Mülltonne");//falls alle i durch sind kommt dass man an keiner mülltonne ist
}

ocmd:verbrechen(playerid,params[])
{
  if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
  {
  	new pID,wLevel;
  	if(sscanf(params,"ii",pID,wLevel))return SendClientMessage(playerid,duneklhelblau,"Info: /Fandungslevel[playerid][fandungslevel]");
  	if(wLevel<0||wLevel>6)return SendClientMessage(playerid,rot,"Falsche Fandungslevel!");
  	SetPlayerWantedLevel(pID,wLevel);
  	return 1;
  }  
}
ocmd:hilfe(playerid,params[])
{
	SendClientMessage(playerid,grün,"/fraktionshilfe");
	SendClientMessage(playerid,grün,"/fahrzeughilfe");
	
}
ocmd:fahrzeughilfe(playerid,params[])
{
	 SendClientMessage(playerid,grün,"/motorsystem");
	 return 1;
}
   ocmd:motorsystem(playerid,params)
{
	if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER) return SendClientMessage(playerid, rot, "Das kann nur der Fahrer!");
	ShowPlayerDialog(playerid,DIALOG_MOTORSYSTEM,DIALOG_STYLE_TABLIST,     "Autobordcomputer","Motor\tstarten\tauschalten\nlicht\tanschalten\tausschalten\ntüren\töffnen\tschliessen\nAutoparken\tparken","benutzen","abbrechen");
	SendClientMessage(playerid,grün,"Sie haben den Bordcomputer Ihres Fahrzeuges aufgerufen!");
	return 1;
}
ocmd:geldgeben(playerid,params[])
{
    if(!isAdmin(playerid,6)) return SendClientMessage(playerid,grün,"Dein Adminrang ist nicht hochgenug!");
    new pID,GeldID;
    if(sscanf(params,"ui",pID,GeldID))return SendClientMessage(playerid,rot,"INFO: /geldgeben [playerid],[geldhöhe]");
    if(GeldID<1||GeldID>9000000)return SendClientMessage(playerid,rot,"Falscher Geldwert!");
    GivePlayerMoney(pID, GeldID);
    SendClientMessage(playerid,rot,"Dir wurden soeben Geldgegeben!");
    return 1;
}
ocmd:waffengeben(playerid,params[])
{
	if(!isAdmin(playerid,5))return SendClientMessage(playerid,grün,"Du hast keine Berechtigung dazu!");
	new pID,wID,amo;
	if(sscanf(params,"uii",pID,wID,amo))
	return SendClientMessage(playerid,duneklhelblau,"INFO: /waffengeben [playerid][waffenid][munition]");
	if(wID<1||wID>46)return SendClientMessage(playerid,rot,"Falsche Waffenid!");
	if(amo<1||amo>1000)return SendClientMessage(playerid,rot,"Die anzahl an Munition kannst nicht wählen.");
	GivePlayerWeapon(pID,wID,amo);
	return 1;
}

ocmd:fraktionshilfe(playerid,params[])
{
	if(isPlayerInFrakt(playerid,0))return SendClientMessage(playerid,rot,"Du bist in keiner Fraktion");
	SendClientMessage(playerid,grün,"/fc");
	SendClientMessage(playerid,rot,"/einladen");
	SendClientMessage(playerid,grün,"/annehmen");
	SendClientMessage(playerid,rot,"/spawnchange");
	SendClientMessage(playerid,grün,"/einladen");
	return 1;
}
ocmd:fc(playerid,params[])
{
	if(isPlayerInFrakt(playerid, 0))return SendClientMessage(
	    playerid, rot, "Du bist in keiner Fraktion.");
	new string[128];
	if(sscanf(params, "s[128]", string))return SendClientMessage(
	    playerid, rot, "INFO: /f [nachricht]");
	new fID = PlayerInfo[playerid][fraktion];
	format(string,sizeof(string), "**(( %s: %s ))**",string);
	for(new i=0; i<MAX_PLAYERS; i++)
	{
	    if(!IsPlayerConnected(i))continue;
	    if(!isPlayerInFrakt(i, fID))continue;
	    SendClientMessage(i, helblau, string);
	}
	return 1;
}
ocmd:einladen(playerid,params[])
{
    if(isPlayerInFrakt(playerid, 0))return SendClientMessage(
		playerid, helblau, "Du bist in keiner Fraktion.");
	if(PlayerInfo[playerid][frank] < 6)return SendClientMessage(
	    playerid, helblau, "Dein Rang ist zu niedrig.");
	new pID, fID;
	fID = PlayerInfo[playerid][fraktion];
	if(sscanf(params, "u", pID))return SendClientMessage(
	    playerid, gelb, "INFO: /invite [playerid]");
	if(!isPlayerInFrakt(pID, 0))return SendClientMessage(
	    playerid, gelb, "Spieler ist kein Zivilist.");
	new string[128];
	format(string,sizeof(string), "%s hat dich in die Fraktion %s eingeladen.",fInfo[fID][f_name]);
	SendClientMessage(pID, gelb, string);
	SendClientMessage(pID, gelb,
		"Zum akzeptieren /accept invite eingeben.");
	SetPVarInt(pID, "inv_fraktid", fID);
	SetPVarInt(pID, "inv_inviter", playerid);
	return 1;
}
ocmd:annehmen(playerid, params[])
{
	new item[64];
	if(sscanf(params,"s[64]",item))return SendClientMessage(
	    playerid, gelb, "INFO: /accept [invite]");
	if(!strcmp(item, "invite", false))
	{
	    if(GetPVarInt(playerid, "inv_fraktid") == 0)return SendClientMessage(
	        playerid, grün, "Du wurdest in keine Fraktion eingeladen.");
		new fID = GetPVarInt(playerid, "inv_fraktid");
		PlayerInfo[playerid][fraktion] = fID;
		PlayerInfo[playerid][frank] = 1;
		new string[128];
		format(string,sizeof(string), "Du bist der Fraktion %s beigetreten.",
		    fInfo[fID][f_name]);
		SendClientMessage(playerid, grün, string);
		format(string,sizeof(string), "%s ist der Fraktion beigetreten.");
		SendClientMessage(GetPVarInt(playerid, "inv_inviter"), grün,
		    string);
		SetPVarInt(playerid, "inv_fraktid", 0);
		return 1;
	}
	return 1;
}
  ocmd:spawnchange(playerid,params[])
{
	if(isPlayerInFrakt(playerid,0)) return SendClientMessage(playerid,rot,"Du bist in keiner Fraktion.");
	if(PlayerInfo[playerid][spawn] == 0)
	{
		PlayerInfo[playerid][spawn] = 1;
	}
	else
	{
		PlayerInfo[playerid][spawn] = 0;
	}
	SendClientMessage(playerid,grün,"Spawn geändert");
	return 1;
}
  ocmd:Leadererstellen(playerid,params[])
{
	if(!isAdmin(playerid,6))return SendClientMessage(playerid,grün,"Du hast keine Berechtigung dazu!");
	new pID, fID;
	if(sscanf(params,"ui",pID,fID))return SendClientMessage(playerid,rot,"INFO: /Leadererstellen[playerid][fraktid]");
	if(fID>= sizeof(fInfo))return SendClientMessage(playerid,rot,"Fraktion existiert nicht.");
	PlayerInfo[pID][fraktion] = fID;
	PlayerInfo[pID][frank] = 6;
	new string[128];
	format(string,sizeof(string),"%s hat dich zum Leader der Fraktion %s gemacht",fInfo[fID][f_name]);
	SendClientMessage(pID,gelb,string);
	SendClientMessage(playerid,grün,"Du hast einen Spieler zum Leader gemacht.");

	return 1;
}
ocmd:spielerkicken(playerid,params[])
 {
  	if(!isAdmin(playerid,6)) return SendClientMessage(playerid,helblau,"Du hast nicht die passende Rechte dafür!");
  	new pID;
  	if(sscanf(params,"d",pID))return SendClientMessage(playerid,helblau,"Benutze: /kick [playerid]");
   	Kick(pID);
   	TogglePlayerControllable(pID,1);
   	SendClientMessage(playerid,blau,"Sie wurden gekickt");
 	return 1;
 }
 ocmd:spielerbannen(playerid,params[])
 {
 	if(!isAdmin(playerid,6)) return SendClientMessage(playerid,helblau,"Du hast nicht die passende Rechte dafür!");
  	new pID;
  	if(sscanf(params,"d",pID))return SendClientMessage(playerid,helblau,"Benutze: /spielerbannen [playerid]");
   	BanEx(pID,"AdminBAN");
   	TogglePlayerControllable(pID,1);
   	SendClientMessage(playerid,blau,"Sie wurden gebannt");
 	return 1;
}
ocmd:reparieren(playerid,params[])
{
	if(!IsPlayerInAnyVehicle(playerid))
		return 1;
	new istimpunkt=false;
	for(new i=0; i<sizeof(repair); i++)
	{
		if(!IsPlayerInRangeOfPoint(playerid,2,repair[i][r_x],repair[i][r_y],repair[i][r_z]))
			continue;

		istimpunkt=true;
	}

	if(istimpunkt)
	{
		new vID= GetPlayerVehicleID(playerid);
		SetVehicleHealth(vID,1000);
		RepairVehicle(vID);
		GivePlayerMoney(playerid,-60);
		SendClientMessage(playerid,hellgrün,"Du hast dein Fahrzeug für 60$Repariert!");
	}
	else
	{
		SendClientMessage(playerid,hellgrün,"Du bist nicht im Reparier-Punkt.");
	}

	return 1;
}
ocmd:restart(playerid,params[])
{
	if(!isAdmin(playerid,6))return SendClientMessage(playerid,rot,"Dein Admingrang ist zu niedrig.");
	SendRconCommand("gmx");
	return 1;
}
ocmd:setadmin(playerid,params[])
{
    if(!isAdmin(playerid,6))return SendClientMessage(playerid,orange,"Dein Adminrang ist zu niedrig.");
	new pID,a_level;
	if(sscanf(params,"ui",pID,a_level))return SendClientMessage(playerid,orange,"INFO: /setadmin [playerid] [adminlevel]");
	PlayerInfo[playerid][admin]=a_level;
	SaveUserStats(pID);
	SendClientMessage(pID,orange,"Dein Adminrang wurde geändert.");
	SendClientMessage(playerid,orange,"Du hast den Adminrang geändert.");
	return 1;
}
ocmd:enter(playerid,params[])
{
	for(new i=0; i<sizeof(bInfo); i++)
	{
		if(GetPlayerVirtualWorld(playerid)!=i)continue;
		if(!IsPlayerInRangeOfPoint(playerid,1,bInfo[i][b_x],bInfo[i][b_y],bInfo[i][b_z]))continue;
		SetPlayerPos(playerid,bInfo[i][bi_x],bInfo[i][bi_y],bInfo[i][bi_z]);
		SetPlayerInterior(playerid,bInfo[i][b_interior]);
		SetPlayerVirtualWorld(playerid,i);
		return 1;
	}
	return 1;
}
ocmd:exit(playerid,params[])
{
	for(new i=0; i<sizeof(bInfo); i++)
	{
		if(!IsPlayerInRangeOfPoint(playerid,1,bInfo[i][bi_x],bInfo[i][bi_y],bInfo[i][bi_z]))continue;
		SetPlayerPos(playerid,bInfo[i][b_x],bInfo[i][b_y],bInfo[i][b_z]);
		SetPlayerInterior(playerid,0);
		SetPlayerVirtualWorld(playerid,0);
		return 1;
	}
	return 1;
}
ocmd:deletcar(playerid,params[])
{
	if(!isAdmin(playerid,6))return SendClientMessage(playerid,rot,"Dein Admingrang ist zu niedrig.");
	if(!IsPlayerInAnyVehicle(playerid))return SendClientMessage(playerid,türkis,"Du bist in kein Fahrzeug");
	DestroyVehicle(GetPlayerVehicleID(playerid));
	return 1;
}
ocmd:createcar(playerid,params[])
{
	if(!isAdmin(playerid,6))return SendClientMessage(playerid,rot,"Dein Admingrang ist zu niedrig.");
	new mID,pID;
	print("Hallo");
	if(sscanf(params,"ui",pID,mID))return SendClientMessage(playerid,rot,"INFO: /createcar[playerid][model]");
	print("börger");
	if(mID<400||mID>611)return SendClientMessage(playerid,rot,"Ungültiges Model");
	print("teleropa");
	new Float:xc,Float:yc,Float:zc,Float:rc;
	GetPlayerPos(pID,xc,yc,zc);
	GetPlayerFacingAngle(pID,rc);
	PlayerCar(pID,mID,xc,yc,zc,rc);
	return 1;
}
ocmd:pm(playerid,params[])
{
    new sender[MAX_PLAYER_NAME+1];
    GetPlayerName(playerid,sender,sizeof(sender));
    new pID,text[128];
    if(sscanf(params,"us[128]",pID,text))return SendClientMessage(playerid,türkis,"Server: /pm [Playerid] [Text]&quot!");
    format(text,200,"(([%s]:  %s))",sender,text);
 	SendClientMessage(pID,rot,text);
    return 1;
}
public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if(newkeys & KEY_SECONDARY_ATTACK)
    {
        ocmd_exit(playerid,"");
        ocmd_enter(playerid,"");
        return 1;
    }
    return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_REGISTER)
	{
		//spieler hat abbrechen gewählt
		if(!response)return Kick(playerid);
		
		//Wenn der Spieler kein oder ein zu kurzes, Passwort eingegeben hat
		if(strlen(inputtext) < 5)return ShowPlayerDialog(playerid,DIALOG_REGISTER,DIALOG_STYLE_PASSWORD,"Registration","Bitte registriere dich; \n{FF0000}Mindestens 5 Zeichen!","Registrieren","Abbrechen");
		
		//wenn alles passt wird spieler angelegt
		new query[256];
		mysql_format(handle,query,sizeof(query), "INSERT INTO account(name,passwort)VALUES('%e',MD5('%e'))",PlayerInfo[playerid][pname],inputtext);
		
		//Das Query wird abgesendet und die playerid an OnUserRegister übergeben
		mysql_pquery(handle,query,"OnUserRegister","d",playerid);
		return 1;
	}
	if(dialogid == DIALOG_LOGIN)
	{
		//spieler hat abbrechen gewählt
		if(!response)return Kick(playerid);
		
		//Wenn der spieler kein, oder ein zu kurzes Passwort eingegeben hat
		if(strlen(inputtext) < 5)return ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Anmeldung","Bitte logge dich ein:\n{FF0000}Mindestens 5 Zeichen!","Anmelden","Abbrechen");
		
		//Wenn alles Passt wird die Datenbank ausgelsen
		new query[256];
		mysql_format(handle,query,sizeof(query),"SELECT * FROM account WHERE name = '%e' AND passwort = MD5('%e')",PlayerInfo[playerid][pname],inputtext);
		mysql_pquery(handle,query,"OnUserLogin","d",playerid);
		return 1;
	}
	if(dialogid==DIALOG_LADEN)
	{
		if(response)
		{
			if(listitem==0)//bei pfand
			{
				if(Flaschen[playerid]>=1)
				{
					new string[256];
					new pfandgeld=Flaschen[playerid]*5;
					PlayerInfo[playerid][pmoney]+=pfandgeld;
					format(string,sizeof(string),"--------------Kassenbong---------------");
					SendClientMessage(playerid,orange,"string");
					format(string,sizeof(string),"{0x0009FFFF}Du hast %d Flaschen für %d{0x0009FFFF}& {0x0009FFFF}verkauft",Flaschen[playerid],pfandgeld);
					SendClientMessage(playerid,0x0009FFFF,string);
					Flaschen[playerid]=0;
				}
				else
				{
					SendClientMessage(playerid,rot,"Du hast keine Pfandflaschen!");
				}
				
			}
		}
	}
	if(dialogid==DIALOG_AUTOHAUS)
	{
		if(response)
		{
			new id=GetPVarInt(playerid,"buyCarID");
			if(GetPlayerMoney(playerid)<ahCars[id][c_preis])
			{
				SendClientMessage(playerid,orange,"Du besitzt nicht das benötige Geld für das Fahrzeug!");
				RemovePlayerFromVehicle(playerid);
			}
			GivePlayerMoney(playerid,-ahCars[id][c_preis]);
			PlayerCar(playerid,ahCars[id][model],ahInfo[ahCars[id][ah_id]][v_x],ahInfo[ahCars[id][ah_id]][v_y],ahInfo[ahCars[id][ah_id]][v_z],ahInfo[ahCars[id][ah_id]][v_r]);
			SendClientMessage(playerid,türkis,"Sie haben sich ein Autogekauft");
			RemovePlayerFromVehicle(playerid);
		}
		else
		{
			RemovePlayerFromVehicle(playerid);
			SendClientMessage(playerid,türkis,"Du hast den Kaufvorgang abgebrochen!");
		}
	}
	if(dialogid==DIALOG_MOTORSYSTEM)
	{
		if(response)
		{
			if(listitem==0)
			{
				if(!IsPlayerInAnyVehicle(playerid))
				return SendClientMessage(playerid,rot,"Sie sind nicht im Fahrzeug!");
				if(GetPlayerState(playerid) !=PLAYER_STATE_DRIVER)
				{
					SendClientMessage(playerid,blau,"Sie sind nicht der Fahrer dieses Fahrzeuges!");
				}
				new vID=GetPlayerVehicleID(playerid),motor,licht,alarm,tueren,bonnet,boot,objective;
				GetVehicleParamsEx(vID,motor,licht,alarm,tueren,bonnet,boot,objective);
				if(motor== 1) motor = 0;
				else motor = 1;
				SetVehicleParamsEx(vID,motor,licht,alarm,tueren,bonnet,boot,objective);
				SendClientMessage(playerid,blau,"Sie haben den Motor ihres Fahrzeuges gestartet/ausgeschaltet!");
			}
		}
		if(listitem==1)
		{
			if(!IsPlayerInAnyVehicle(playerid))return 
				SendClientMessage(playerid,rot,"Sie sind nicht im Fahrzeug!");
			if(GetPlayerState(playerid) !=PLAYER_STATE_DRIVER)
			return SendClientMessage(playerid,blau,"Sie befinden sich nicht in ihr Fahrzeug!");
			new vID= GetPlayerVehicleID(playerid),motor,licht,alarm,tueren,bonnet,boot,objective;
			GetVehicleParamsEx(vID,motor,licht,alarm,tueren,bonnet,boot,objective);
			if(licht==1)
			{
				licht = 0;
			}
			else
			{
				licht = 1;
			}
			SetVehicleParamsEx(vID,motor,licht,alarm,tueren,bonnet,boot,objective);
			SendClientMessage(playerid,blau,"Du hast das Licht eingeschaltet/ausgeschaltet!");
		}
		if(listitem==2)
		{
			new motor,licht,alarm,tueren,bonnet,boot,objective;
			new vID = INVALID_VEHICLE_ID;
			if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
			{
				new Float:POS[3];
				for(new i=0;i<MAX_VEHICLES; i++)
				{
					GetVehiclePos(i, POS[0], POS[1], POS[2]);
					if(IsPlayerInRangeOfPoint(playerid,5.0,POS[0], POS[1], POS[2]))
					{
						vID = i;
						break;
					}
				}
			}
			else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			{
				vID = GetPlayerVehicleID(playerid);
			}
			if(vID == INVALID_VEHICLE_ID)
			{
				SendClientMessage(playerid,rot,"ERROR: Nicht nahe oder in einem Fahrzeug!");
			}
			GetVehicleParamsEx(vID,motor,licht,alarm,tueren,bonnet,boot,objective);
			if(tueren==1)
			{
				tueren = 0;
			}
			else
			{
				tueren = 1;
			}
			SetVehicleParamsEx(vID,motor,licht,alarm,tueren,bonnet,boot,objective);
			SendClientMessage(playerid,blau,"Sie haben die Türen ihres Fahrzuges abgeschlossen/aufgeschlossen!");
		}
		if(listitem==3)
		{
			new vID = GetPlayerVehicleID(playerid);
			if(!IsPlayerInAnyVehicle(playerid))
			return SendClientMessage(playerid,hellgrün,"Du bist in keinem Fahrzeug!");
			for(new i = 0; i< sizeof(cInfo); i++)
			{
				if(vID == cInfo[i][faid])
				{
					if(cInfo[i][besitzer] == PlayerInfo[playerid][p_id])
					{
						new query[256];
						GetVehiclePos(vID,cInfo[i][c_x],cInfo[i][c_y],cInfo[i][c_z]);
						GetVehicleZAngle(vID,cInfo[i][c_r]);
						format(query,sizeof(query),"UPDATE spielerfahrzeuge SET x='%f',y='%f',z='%f',r='%f' WHERE id='%i'",cInfo[i][c_x],cInfo[i][c_y],cInfo[i][c_z],cInfo[i] [faid]);
						mysql_pquery(handle,query);
						SendClientMessage(playerid,hellgrün,"Du hast dein Fahrzeug geparkt!");
						return 1;
					}
					break;
				}
			}
			return SendClientMessage(playerid,hellgrün,"Sie sitzen nicht in ihr Fahrzeg!");
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
stock mysql_setupconnection(ttl = 3)
{
	print("[MYSQL] Verbindungsaufbau........");
	mysql_log();
	handle = mysql_connect(MYSQL_HOST,MYSQL_USER,MYSQL_PASS,MYSQL_DBSE);
	
	//prüfen und gegebenfalls wiederholen
	if(mysql_errno(handle) !=0)
	{
		//Fehler beim Verbindungsaufbau,prüfe ob eine weiterer Versuch gestartet werden soll
		if(ttl > 1)
		{
			//versuche erneut eine verbindung herzustellen
			print("[MYSQL] Es konnte keine Verbindung zur Datenbank hergestellt werden.");
			printf("[MYSQL] Starte neuen Verbindung versuch (ttl: %d).",ttl-1);
			return mysql_setupconnection(ttl-1);
		}
		else
		{
			//Abbrechen und Server Schließen
			print("[MYSQL] Es konnte keine Verbindung zur Datenbank hergestellt werden.");
			print("[MYSQL] Bitte prüfe die Verbindungsdaten");
			print("[MYSQL] Der Server wird heruntergefahren");
			return SendRconCommand("exit");			
		}		
	}
	printf("[MySQL] Die Verbindung zur Datenbank wurde erfolgreich hergestellt! Handle: %d", _:handle);
	return 1;
}
public OnUserCheck(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows == 0)
	{
		//Der Spieler konnte nicht gefunden werden, er muss sich registrieren
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,"Registration","Bitte registriere dich","Registrieren","Abbrechen");
	}
	else
	{
		//Es existiert ein Ergbins, das heißt der Spieler ist registriert und muss sich einloggen
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,"Anmeldung","Bitte logge dich ein","Einloggen","Abbrechen");
	}
	return 1;
}
public OnUserRegister(playerid)
{
	PlayerInfo[playerid][p_id] = cache_insert_id();
	SendClientMessage(playerid,türkis,"[KONTO]Registration erfolgreich");
	return 1;
}

public OnUserLogin(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows == 0)
	{
		ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Anmeldung","Bitte logge dich ein:\n{FF0000}Falsches Passwort","Einloggen","Abbrechen");		
	}
	else
	{
			cache_get_value_name_int(0,"id",PlayerInfo[playerid][p_id]);
			cache_get_value_name_int(0,"level",PlayerInfo[playerid][level]);
			SetPlayerScore(playerid,PlayerInfo[playerid][level]);
			cache_get_value_name_int(0,"admin",PlayerInfo[playerid][admin]);
			cache_get_value_name_int(0,"money",PlayerInfo[playerid][pmoney]);
			GivePlayerMoney(playerid,PlayerInfo[playerid][pmoney]);
			cache_get_value_name_int(0,"fraktion",PlayerInfo[playerid][fraktion]);
			cache_get_value_name_int(0,"frank",PlayerInfo[playerid][frank]);
			cache_get_value_name_int(0,"spawn",PlayerInfo[playerid][spawn]);
			PlayerInfo[playerid][eingeloggt] = true;
			SendClientMessage(playerid,grün,"[KONTO]Eingeloggt.");
	}
	return 1;
}
stock SaveUserStats(playerid)
{
	if(!PlayerInfo[playerid][eingeloggt])return 1;
	PlayerInfo[playerid][pmoney] = GetPlayerMoney(playerid);
	new query[256];
	mysql_format(handle,query,sizeof(query),"UPDATE account SET level = '%d',admin = '%d',money = '%d',fraktion = '%d',frank = '%d',spawn = '%d' WHERE id = '%d'",PlayerInfo[playerid][level],PlayerInfo[playerid][admin],PlayerInfo[playerid][pmoney],PlayerInfo[playerid][fraktion],PlayerInfo[playerid][frank],PlayerInfo[playerid][spawn],PlayerInfo[playerid][p_id]);
	mysql_pquery(handle,query);
	return 1;
}