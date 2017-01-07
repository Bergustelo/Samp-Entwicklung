#include <a_samp>
#include <a_mysql>
#include <sscanf2.inc>
#include <ocmd>


#define MYSQL_HOST "127.0.0.1"
#define MYSQL_USER "root"
#define MYSQL_PASS ""
#define MYSQL_DBSE "entwicklung"
new MySQL:handle;

//Forward definierungsbereich
forward OnUserCheck(playerid);
forward OnUserRegister(playerid);
forward OnUserLogin(playerid);

//

//Farben

#define green 0x008E00FF
#define rot 0xFF0000FF
#define blau 0x0000FFFF
#define braun 0x7E3918FF
#define gelb 0xFFDD00FF
#define weiß 0xFFFFFFFF
//


//Diagloge definierungsbereich
#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
#define DIALOG_Motorsystem 3
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
enum fahrzeugEnum
{
	faid,
	besitzer[MAX_PLAYER_NAME],
	Float:c_x,
	Float:c_y,
	Float:c_z,
	Float:c_r
}
new cInfo[50][fahrzeugEnum];

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
	mysql_setupconnection();
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
	SetPlayerCameraPos(playerid,1159.3171,-1377.4707,13.6522);
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
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SaveUserStats(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
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
		cInfo[i][faid] = CreateVehicle(modelid,x,y,z,r,-1,-1,-1);
		new string[128];
		format(string,sizeof(string),"Das Fahrzeug cInfo[%i] wurde erstellt");
		SendClientMessageToAll(rot,string);
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
// Befehle
ocmd:deltecar(playerid,params[])
{
	if(!isAdmin(playerid,2))
	if(!IsPlayerInAnyVehicle(playerid))return SendClientMessage(playerid,green,"Du bist in kein Fahrzeug");
	DestroyVehicle(GetPlayerVehicleID(playerid));
	return 1;
}
ocmd:createcar(playerid,params[])
{
	new mID,pID;
	if(!isAdmin(playerid,2))
	if(sscanf(params,"i",mID))return SendClientMessage(playerid,rot,"INFO: /createcar[model]");
	if(mID<400 ||mID>611)return SendClientMessage(playerid,rot,"Ungültiges Model");
	new Float:xc,Float:yc,Float:zc,Float:rc;
	GetPlayerPos(pID,xc,yc,zc);
	GetPlayerFacingAngle(pID,rc);
	PlayerCar(pID,mID,xc,yc,zc,rc);
	return 1;
}
ocmd:autosystem(playerid,params)
{
	if(GetPlayerState(playerid)!=PLAYER_STATE_DRIVER) return SendClientMessage(playerid, rot, "Das kann nur der Fahrer!");
	ShowPlayerDialog(playerid,DIALOG_Motorsystem,DIALOG_STYLE_TABLIST,     "Autobordcomputer","Motor\tstarten\tauschalten\nlicht\tanschalten\tausschalten\ntüren\töffnen\tschliessen\nAutoparken\tparken","benutzen","abbrechen");
	SendClientMessage(playerid,green,"Sie haben den Bordcomputer Ihres Fahrzeuges aufgerufen!");
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
	SendClientMessage(playerid,green,"[KONTO]Registration erfolgreich");
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
			SendClientMessage(playerid,green,"[KONTO]Eingeloggt.");
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