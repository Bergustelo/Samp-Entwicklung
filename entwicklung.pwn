#include <a_samp>
#include <a_mysql>
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
//


//Diagloge definierungsbereich
#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
//
//Spieler Information

enum pDataEnum
{
	spielerid,
	bool:eingeloggt,
	pname[MAX_PLAYER_NAME],
	level,
	admin,
	pmoney,
	fraktion,
	frank,
	spawn,
	pdeaths
}
new PlayerInfo[MAX_PLAYER_NAME][pDataEnum];
//
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
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
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
	PlayerInfo[playerid][spielerid] =0;
	PlayerInfo[playerid][eingeloggt] = false;
	PlayerInfo[playerid][level] = 0;
	PlayerInfo[playerid][admin] = 0;
	PlayerInfo[playerid][pmoney] = 0;
	PlayerInfo[playerid][fraktion] = 0;
	PlayerInfo[playerid][frank] = 0;
	PlayerInfo[playerid][spawn] = 0;
	GetPlayerName(playerid,PlayerInfo[playerid][pname],MAX_PLAYER_NAME);
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
		if(strlen(inputtext) < 5)return ShowPlayerDialog(playerid,DIALOG_REGISTER,DIALOG_STYLE_PASSWORD,"Registration","Bitte registriere dich; \n{0x008E00FF}Mindestens 5 Zeichen!","Registrieren","Abbrechen");
		
		//wenn alles passt wird spieler angelegt
		new query[256];
		mysql_format(handle,query,sizeof(query), "INSERT INTO account(name,passwort)VALUES('%e',MD5(#%e))",PlayerInfo[playerid][pname],inputtext);
		
		//Das Query wird abgesendet und die playerid an OnUserRegister übergeben
		mysql_pquery(handle,query,"OnUserRegister","d",playerid);
		return 1;
	}
	if(dialogid == DIALOG_LOGIN)
	{
		//spieler hat abbrechen gewählt
		if(!response)return Kick(playerid);
		
		//Wenn der spieler kein, oder ein zu kurzes Passwort eingegeben hat
		if(strlen(inputtext) < 5)return ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Anmeldung","Bitte logge dich ein:\n{0x008E00FF}Mindestens 5 Zeichen!","Anmelden","Abbrechen");
		
		//Wenn alles Passt wird die Datenbank ausgelsen
		new query[256];
		mysql_format(handle,query,sizeof(query),"SELECT * FROM account WHERE name = '%e' AND passwort = MD5('%e')",PlayerInfo[playerid][pname],inputtext);
		mysql_pquery(handle,query,"OnUserLogin","d",playerid);
		return 1;
	}
	return 0;
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
	PlayerInfo[playerid][spielerid] = cache_insert_id();
	SendClientMessage(playerid,green,"[KONTO]Registration erfolgreich");
	return 1;
}

public OnUserLogin(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows == 0)
	{
		ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Anmeldung","Bitte logge dich ein:\n{0x008E00FF}Falsches Passwort","Einloggen","Abbrechen");		
	}
	else
	{
			cache_get_value_name_int(0,"id",PlayerInfo[playerid][spielerid]);
			cache_get_value_name_int(0,"level",PlayerInfo[playerid][level]);
			cache_get_value_name_int(0,"admin",PlayerInfo[playerid][admin]);
			cache_get_value_name_int(0,"money",PlayerInfo[playerid][pmoney]);
			cache_get_value_name_int(0,"fraktion",PlayerInfo[playerid][fraktion]);
			cache_get_value_name_int(0,"frank",PlayerInfo[playerid][frank]);
			cache_get_value_name_int(0,"spawn",PlayerInfo[playerid][spawn]);
			PlayerInfo[playerid][eingeloggt] = true;
			SendClientMessage(playerid,green,"[KONTO]Eingeloggt.");
			GivePlayerMoney(playerid,PlayerInfo[playerid][pmoney]);
	}
	return 1;
}
stock SaveUserStats(playerid)
{
	if(!PlayerInfo[playerid][eingeloggt])return 1;
	
	new query[256];
	mysql_format(handle,query,sizeof(query),"UPADTE account SET level = '%d',admin = '%d',money = '%d',fraktion = '%d',frank = '%d',spawn = '%d'WHERE id = '%d'",PlayerInfo[playerid][level],PlayerInfo[playerid][admin],PlayerInfo[playerid][pmoney],PlayerInfo[playerid][fraktion],PlayerInfo[playerid][frank],PlayerInfo[playerid][spawn]);
	
	mysql_pquery(handle,query);
	return 1;
}