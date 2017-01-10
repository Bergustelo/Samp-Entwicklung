#include <a_samp>
#include <streamer>
#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	CreateDynamicObject(19360, 227.73849, 126.68120, 1004.48309,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 227.73849, 126.68120, 1000.98328,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19325, 239.73425, 113.19443, 1003.41492,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19325, 253.15411, 116.88120, 1003.41492,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19325, 249.65680, 119.44370, 1004.84113,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19325, 243.01511, 119.44370, 1004.84113,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 236.82150, 119.20070, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1495, 233.11760, 119.20070, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1495, 237.92329, 115.87730, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1495, 236.42371, 115.87730, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 228.00101, 122.30500, 1003.96863,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 230.59950, 122.31100, 1000.98328,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 230.59950, 122.31100, 1004.48309,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 227.39011, 122.31100, 1007.46667,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 227.23390, 122.30800, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 254.86411, 112.88980, 1007.04657,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 254.86411, 112.88980, 1003.54938,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 258.07471, 112.88980, 1007.04657,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 258.07471, 112.88980, 1003.54742,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 254.09509, 112.88680, 1002.04779,   0.00000, 0.00000, 0.00000);
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else

main()
{

}

#endif

public OnGameModeInit()
{

	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{

	return 1;
}

public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
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
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
