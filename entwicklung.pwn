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
	{1310.1149,-1366.8008,13.5066,246.0798,107.5067,1003.2188,10},
	{1555.3151,-1675.8002,16.1953,1040.3652,1279.5161,798.7730,0}
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
new pdtuer1,pdtuer2,pdtuer3,pdtuer4,pdtuer5,pdtuer6,pdtuer7,pdtuer8,pdtuer9;


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


	//autohausladen:
	for(new i=0; i<sizeof(ahCars); i++)
	{
		ahCars[i][id_x]=AddStaticVehicle(ahCars[i][model],ahCars[i][ah_x],ahCars[i][ah_y],ahCars[i][ah_z],ahCars[i][ah_r],-1,-1);
	}
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
	//objekte:
	//ARBEITSAMT
	CreateObject(19360, 227.73849, 126.68120, 1004.48309,   0.00000, 0.00000, 0.00000);
	CreateObject(19360, 227.73849, 126.68120, 1000.98328,   0.00000, 0.00000, 0.00000);
	CreateObject(19325, 239.73425, 113.19443, 1003.41492,   0.00000, 0.00000, 0.00000);
	CreateObject(19325, 253.15411, 116.88120, 1003.41492,   0.00000, 0.00000, 0.00000);
	CreateObject(19325, 249.65680, 119.44370, 1004.84113,   0.00000, 0.00000, 90.00000);
	CreateObject(19325, 243.01511, 119.44370, 1004.84113,   0.00000, 0.00000, 90.00000);
	CreateObject(1495, 236.82150, 119.20070, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateObject(1495, 233.11760, 119.20070, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateObject(1495, 237.92329, 115.87730, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateObject(1495, 236.42371, 115.87730, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateObject(19393, 228.00101, 122.30500, 1003.96863,   0.00000, 0.00000, 90.00000);
	CreateObject(19360, 230.59950, 122.31100, 1000.98328,   0.00000, 0.00000, 90.00000);
	CreateObject(19360, 230.59950, 122.31100, 1004.48309,   0.00000, 0.00000, 90.00000);
	CreateObject(19360, 227.39011, 122.31100, 1007.46667,   0.00000, 0.00000, 90.00000);
	CreateObject(1495, 227.23390, 122.30800, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateObject(19360, 254.86411, 112.88980, 1007.04657,   0.00000, 0.00000, 90.00000);
	CreateObject(19393, 254.86411, 112.88980, 1003.54938,   0.00000, 0.00000, 90.00000);
	CreateObject(19360, 258.07471, 112.88980, 1007.04657,   0.00000, 0.00000, 90.00000);
	CreateObject(19360, 258.07471, 112.88980, 1003.54742,   0.00000, 0.00000, 90.00000);
	CreateObject(1495, 254.09509, 112.88680, 1002.04779,   0.00000, 0.00000, 0.00000);
	CreateObject(19360, 227.73849, 126.68120, 1004.48309,   0.00000, 0.00000, 0.00000);
	CreateObject(19360, 227.73849, 126.68120, 1000.98328,   0.00000, 0.00000, 0.00000);
	CreateObject(19325, 239.73425, 113.19443, 1003.41492,   0.00000, 0.00000, 0.00000);
	CreateObject(19325, 253.15411, 116.88120, 1003.41492,   0.00000, 0.00000, 0.00000);
	CreateObject(19325, 249.65680, 119.44370, 1004.84113,   0.00000, 0.00000, 90.00000);
	CreateObject(19325, 243.01511, 119.44370, 1004.84113,   0.00000, 0.00000, 90.00000);
	CreateObject(1495, 236.82150, 119.20070, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateObject(1495, 233.11760, 119.20070, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateObject(1495, 237.92329, 115.87730, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateObject(1495, 236.42371, 115.87730, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateObject(19393, 228.00101, 122.30500, 1003.96863,   0.00000, 0.00000, 90.00000);
	CreateObject(19360, 230.59950, 122.31100, 1000.98328,   0.00000, 0.00000, 90.00000);
	CreateObject(19360, 230.59950, 122.31100, 1004.48309,   0.00000, 0.00000, 90.00000);
	CreateObject(19360, 227.39011, 122.31100, 1007.46667,   0.00000, 0.00000, 90.00000);
	CreateObject(1495, 227.23390, 122.30800, 1002.21582,   0.00000, 0.00000, 0.00000);
	CreateObject(19360, 254.86411, 112.88980, 1007.04657,   0.00000, 0.00000, 90.00000);
	CreateObject(19393, 254.86411, 112.88980, 1003.54938,   0.00000, 0.00000, 90.00000);
	CreateObject(19360, 258.07471, 112.88980, 1007.04657,   0.00000, 0.00000, 90.00000);
	CreateObject(19360, 258.07471, 112.88980, 1003.54742,   0.00000, 0.00000, 90.00000);
	CreateObject(1495, 254.09509, 112.88680, 1002.04779,   0.00000, 0.00000, 0.00000);
	
	//lspd
	new pdint;
    pdint = CreateDynamicObject(19375, 1027.91443, 1256.25134, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1027.91443, 1265.83545, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1027.91443, 1275.35608, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1059.28503, 1275.36584, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19378, 1047.18359, 1265.81641, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19378, 1047.18359, 1256.24890, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19378, 1059.16260, 1256.26428, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19378, 1047.18359, 1275.43652, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19378, 1059.16260, 1275.43933, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19378, 1059.16260, 1265.81946, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19378, 1054.12256, 1.00000, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19439, 1053.22815, 1278.46582, 797.68707,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19439, 1053.22815, 1274.97620, 797.68707,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19439, 1053.22815, 1271.51819, 797.68707,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19439, 1053.22815, 1268.04321, 797.68707,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19439, 1053.22815, 1264.59277, 797.68707,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19439, 1053.22815, 1261.12463, 797.68707,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19439, 1053.22815, 1257.65881, 797.68707,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19439, 1053.22815, 1254.19031, 797.68707,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19439, 1053.22815, 1250.74756, 797.66711,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19378, 1055.24097, 1246.77808, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19378, 1055.24097, 1237.20337, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19378, 1044.74902, 1237.19775, 797.68707,   0.00000, -90.00000, 0.00000);//
    SetDynamicObjectMaterial(pdint,0, 6102, "gazlaw1", "law_gazwhitefloor",0);
    pdint = CreateDynamicObject(19378, 1034.25085, 1237.20337, 797.68707,   0.00000, -90.00000, 0.00000);//
    SetDynamicObjectMaterial(pdint,0, 6102, "gazlaw1", "law_gazwhitefloor",0);
    pdint = CreateDynamicObject(19378, 1044.74902, 1246.77808, 797.68707,   0.00000, -90.00000, 0.00000);//
    SetDynamicObjectMaterial(pdint,0, 6102, "gazlaw1", "law_gazwhitefloor",0);
    pdint = CreateDynamicObject(19378, 1034.25085, 1246.77808, 797.68707,   0.00000, -90.00000, 0.00000);//
    SetDynamicObjectMaterial(pdint,0, 6102, "gazlaw1", "law_gazwhitefloor",0);
    pdint = CreateDynamicObject(19378, 1065.08276, 1237.36572, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 6102, "gazlaw1", "law_gazwhitefloor",0);
    pdint = CreateDynamicObject(19375, 1059.28503, 1265.75647, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1059.28503, 1256.25964, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19325, 1053.90186, 1276.90271, 799.73962,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0,  -1, "none", "none", 0xFF9FF5FF);
    pdint = CreateDynamicObject(19386, 1053.98157, 1271.99438, 799.48767,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19325, 1053.90186, 1267.09619, 799.73962,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0,  -1, "none", "none", 0xFF9FF5FF);
    pdint = CreateDynamicObject(19386, 1053.98157, 1262.21582, 799.48767,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19325, 1053.90186, 1257.30029, 799.73962,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0,  -1, "none", "none", 0xFF9FF5FF);
    pdint = CreateDynamicObject(19375, 1053.98157, 1275.43030, 807.02972,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1053.98157, 1271.99438, 800.0415,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1053.98157, 1262.21582, 800.00415,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1053.98157, 1265.80811, 807.02972,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1053.98157, 1256.25964, 807.02972,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1053.98157, 1253.03198, 799.48767,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1053.98157, 1253.03198, 800.04150,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1058.83667, 1260.70435, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1058.83667, 1271.05884, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1058.72327, 1280.27625, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1058.83667, 1251.51501, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(1491, 1053.96985, 1271.24744, 797.77148,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1491, 1053.94812, 1261.46741, 797.77148,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1491, 1053.97485, 1252.29834, 797.77148,   0.00000, 0.00000, 90.00000);
    pdint = CreateDynamicObject(19375, 1049.11426, 1280.27625, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1039.54456, 1280.27625, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1029.96375, 1280.27625, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1050.61255, 1251.51318, 806.46271,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1048.71606, 1251.51318, 799.49762,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1041.00720, 1251.51318, 806.46271,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1031.46240, 1251.51318, 806.46271,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1039.67969, 1251.51318, 799.49762,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1031.37903, 1251.51318, 799.49762,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1055.10156, 1251.51318, 795.99689,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19448, 1025.02625, 1251.51318, 799.48523,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1045.54138, 1251.51318, 799.48523,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1042.37463, 1251.51318, 799.48523,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1036.49109, 1251.51318, 799.48523,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1028.99243, 1246.64172, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1028.99243, 1237.04517, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1059.85217, 1246.69104, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1059.85217, 1237.07959, 806.47083,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1064.70923, 1242.10925, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1069.11377, 1237.37805, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1054.77905, 1243.04114, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1054.83374, 1232.58911, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1064.39612, 1232.58911, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1050.02161, 1246.78198, 806.46820,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1050.02161, 1246.58435, 799.49762,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1050.02161, 1249.80786, 799.48523,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1050.02161, 1237.33606, 806.46820,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1050.02161, 1243.41064, 799.48523,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1050.02161, 1237.02783, 799.49762,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1050.02161, 1240.23071, 799.48523,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1064.30969, 1243.04114, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(1671, 1050.91138, 1245.29602, 798.23547,   0.00000, 0.00000, 360.25989);
    pdint = CreateDynamicObject(19356, 1059.85217, 1237.46643, 799.48523,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1059.85217, 1234.26160, 799.49762,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1059.85217, 1240.62805, 799.48523,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(2165, 1057.73682, 1275.22290, 797.73938,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2166, 1057.71997, 1277.14905, 797.73938,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2166, 1057.95679, 1277.15186, 797.73938,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2000, 1058.73108, 1278.88318, 797.77502,   0.00000, 0.00000, 271.15982);
    CreateDynamicObject(2000, 1058.73108, 1279.38672, 797.77502,   0.00000, 0.00000, 271.15979);
    CreateDynamicObject(2000, 1058.73108, 1279.87061, 797.77502,   0.00000, 0.00000, 271.15979);
    CreateDynamicObject(1806, 1058.86292, 1276.34619, 797.74982,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(19893, 1057.84558, 1276.55164, 798.53033,   0.00000, 0.00000, 89.99998);
    CreateDynamicObject(2894, 1057.73621, 1277.20654, 798.52869,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(14455, 1055.65381, 1271.32251, 799.23627,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2164, 1059.19995, 1273.81250, 797.76038,   0.00000, 0.00000, 269.95990);
    CreateDynamicObject(2164, 1059.19995, 1273.38208, 797.76038,   0.00000, 0.00000, 269.95990);
    CreateDynamicObject(1704, 1055.02393, 1277.32678, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1703, 1054.21704, 1279.66064, 797.76471,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1704, 1056.08398, 1277.32678, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1817, 1054.67175, 1278.00854, 797.76282,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1808, 1058.94287, 1274.54724, 797.77551,   0.00000, 0.00000, -90.42000);
    CreateDynamicObject(1721, 1056.97729, 1277.60413, 797.77533,   0.00000, 0.00000, -180.00000);
    CreateDynamicObject(1721, 1056.95020, 1276.00000, 797.77533,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19787, 1057.13123, 1280.16565, 800.01910,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2165, 1057.69678, 1267.58923, 797.73938,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2166, 1057.67310, 1269.53259, 797.73938,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2166, 1057.91309, 1269.53259, 797.73938,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2202, 1058.76013, 1265.55029, 797.75562,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(2202, 1058.76013, 1263.70422, 797.75562,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(2164, 1054.54077, 1270.85327, 797.76038,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2164, 1054.98108, 1270.86133, 797.76038,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(14455, 1055.56226, 1260.83582, 799.23633,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1703, 1054.28381, 1268.60266, 797.76471,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1817, 1054.85999, 1266.91748, 797.76282,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1703, 1056.38477, 1266.19873, 797.76471,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1806, 1058.85706, 1268.81177, 797.74982,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2894, 1058.75269, 1270.40479, 798.52869,   0.00000, 0.00000, -0.00001);
    CreateDynamicObject(19893, 1057.72864, 1268.73572, 798.53027,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(19894, 1057.72864, 1269.10229, 798.53027,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1808, 1056.53162, 1270.62000, 797.77551,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1721, 1054.06165, 1273.98535, 797.77533,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1721, 1054.06165, 1274.63464, 797.77533,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1721, 1054.06165, 1275.27625, 797.77533,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1721, 1054.06165, 1264.19531, 797.77533,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1721, 1054.06165, 1264.81531, 797.77533,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(2165, 1057.77930, 1253.59546, 797.73938,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2166, 1057.75916, 1255.54150, 797.73938,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2166, 1057.99915, 1255.53625, 797.73938,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1806, 1058.75769, 1254.82007, 797.74982,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2202, 1058.72717, 1259.63757, 797.75562,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(1721, 1054.07190, 1254.98096, 797.77533,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(1721, 1054.07190, 1255.60278, 797.77533,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(1721, 1054.07190, 1256.22803, 797.77533,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(1704, 1057.13147, 1254.00464, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1704, 1056.20654, 1256.90662, 797.77441,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1817, 1057.23987, 1254.96936, 797.76282,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(14455, 1055.56226, 1251.77844, 799.23633,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2164, 1054.54211, 1260.54407, 797.76038,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2164, 1054.94250, 1260.54028, 797.76038,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2164, 1056.28369, 1260.55444, 797.76038,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1808, 1059.01782, 1252.90149, 797.77551,   0.00000, 0.00000, -90.00000);
    CreateDynamicObject(19786, 1056.42114, 1260.66113, 800.55615,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19786, 1051.28113, 1251.45691, 799.53741,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19786, 1053.70569, 1251.45691, 799.53741,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19786, 1056.14929, 1251.45691, 799.53741,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19786, 1058.59021, 1251.45691, 799.53741,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19786, 1059.86816, 1249.69165, 799.53741,   0.00000, 0.00000, 269.72000);
    CreateDynamicObject(19786, 1059.86816, 1247.22949, 799.53741,   0.00000, 0.00000, 269.72000);
    CreateDynamicObject(19786, 1059.86816, 1244.78955, 799.53741,   0.00000, 0.00000, 269.72000);
    CreateDynamicObject(19786, 1058.01270, 1243.05969, 799.53741,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19786, 1055.55713, 1243.05969, 799.53741,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19786, 1053.09656, 1243.05969, 799.53741,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19786, 1050.10510, 1249.13953, 799.53741,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(19786, 1050.10510, 1244.46411, 799.53741,   0.00000, 0.00000, 90.00000);
    pdint = CreateDynamicObject(19428, 1051.82263, 1250.69214, 798.52301,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    pdint = CreateDynamicObject(19428, 1055.31152, 1250.69214, 798.52301,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    pdint = CreateDynamicObject(19428, 1058.76855, 1250.69214, 798.52301,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    pdint = CreateDynamicObject(19428, 1059.19666, 1248.15857, 798.52301,   0.00000, 90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    pdint = CreateDynamicObject(19428, 1059.19666, 1244.71765, 798.52301,   0.00000, 90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    pdint = CreateDynamicObject(19428, 1056.68347, 1243.88147, 798.52301,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    pdint = CreateDynamicObject(19428, 1053.22058, 1243.88147, 798.52301,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    pdint = CreateDynamicObject(19428, 1051.84119, 1243.88147, 798.52301,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    pdint = CreateDynamicObject(19428, 1050.87305, 1249.16675, 798.52301,   0.00000, 90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    CreateDynamicObject(19786, 1059.86816, 1249.69165, 800.95380,   0.00000, 0.00000, 269.72000);
    CreateDynamicObject(19786, 1059.86816, 1247.22949, 800.95380,   0.00000, 0.00000, 269.72000);
    CreateDynamicObject(19786, 1059.86816, 1244.78955, 800.95380,   0.00000, 0.00000, 269.72000);
    CreateDynamicObject(19786, 1058.01270, 1243.05969, 800.95380,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19786, 1055.55713, 1243.05969, 800.95380,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19786, 1053.09656, 1243.05969, 800.95380,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19786, 1050.10510, 1244.46411, 800.95380,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(19786, 1050.10510, 1249.13953, 800.95380,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(19786, 1051.28113, 1251.45691, 800.95380,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19786, 1053.70569, 1251.45691, 800.95380,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19786, 1056.14929, 1251.45691, 800.95380,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19786, 1058.59021, 1251.45691, 800.95380,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1671, 1052.37109, 1248.53369, 798.23547,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1671, 1052.37793, 1249.45959, 798.23547,   0.00000, 0.00000, 180.13997);
    CreateDynamicObject(1671, 1053.61841, 1249.45959, 798.23547,   0.00000, 0.00000, 180.14000);
    CreateDynamicObject(1671, 1054.93945, 1249.45959, 798.23547,   0.00000, 0.00000, 180.14000);
    CreateDynamicObject(1671, 1056.35913, 1249.45959, 798.23547,   0.00000, 0.00000, 180.14000);
    CreateDynamicObject(1671, 1057.64795, 1249.45959, 798.23547,   0.00000, 0.00000, 180.14000);
    CreateDynamicObject(1671, 1057.89429, 1248.42773, 798.23547,   0.00000, 0.00000, 89.12000);
    CreateDynamicObject(1671, 1057.89429, 1247.40698, 798.23547,   0.00000, 0.00000, 89.12000);
    CreateDynamicObject(1671, 1057.89429, 1246.36646, 798.23547,   0.00000, 0.00000, 89.12000);
    CreateDynamicObject(1671, 1057.89429, 1245.34619, 798.23547,   0.00000, 0.00000, 89.12000);
    CreateDynamicObject(1671, 1056.83887, 1245.29602, 798.23547,   0.00000, 0.00000, 360.25989);
    CreateDynamicObject(1671, 1055.64282, 1245.29602, 798.23547,   0.00000, 0.00000, 360.25989);
    CreateDynamicObject(1671, 1054.47302, 1245.29602, 798.23547,   0.00000, 0.00000, 360.25989);
    CreateDynamicObject(1671, 1053.25317, 1245.29602, 798.23547,   0.00000, 0.00000, 360.25989);
    CreateDynamicObject(1671, 1052.07874, 1245.29602, 798.23547,   0.00000, 0.00000, 360.25989);
    CreateDynamicObject(1671, 1050.91138, 1245.29602, 798.23547,   0.00000, 0.00000, 360.25989);
    pdint = CreateDynamicObject(19375, 1064.30969, 1243.04114, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(11729, 1059.41406, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1058.75049, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1058.08862, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1057.42700, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1056.78638, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1056.12573, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1055.46631, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1054.82581, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1054.16541, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1053.52490, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1052.21985, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1051.55859, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1050.91602, 1232.92847, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1050.39465, 1232.90845, 797.77441,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(11729, 1059.54175, 1235.62329, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(11729, 1059.54175, 1236.26587, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(11729, 1059.54175, 1236.90808, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(11729, 1059.54175, 1237.54834, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(11729, 1059.54175, 1238.18896, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(11729, 1059.54175, 1238.80969, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(11729, 1059.54175, 1239.43018, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(11729, 1059.54175, 1240.07068, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(11729, 1059.54175, 1240.71094, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(11729, 1059.54175, 1241.31140, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(11729, 1059.54175, 1241.97180, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(11729, 1059.54175, 1242.61230, 797.77441,   0.00000, 0.00000, -91.26000);
    CreateDynamicObject(19386, 1059.85217, 1234.26160, 799.49762,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19356, 1059.85217, 1237.46643, 799.48523,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19356, 1059.85217, 1240.62805, 799.48523,   0.00000, 0.00000, 0.00000);
    pdint = CreateDynamicObject(19378, 1065.08276, 1237.36572, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19375, 1069.11377, 1237.37805, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(14401, 1052.87720, 1240.53857, 798.07275,   0.00000, 0.00000, -90.00003);
    CreateDynamicObject(14401, 1056.54211, 1239.92737, 798.07281,   0.00000, 0.00000, -180.00011);
    CreateDynamicObject(2527, 1061.90381, 1240.50830, 797.74597,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2527, 1063.38757, 1240.50830, 797.74597,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2527, 1064.85010, 1240.50830, 797.74597,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2527, 1066.35022, 1240.50830, 797.74597,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2527, 1067.74976, 1240.50830, 797.74597,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2527, 1060.37988, 1240.50830, 797.74597,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2527, 1067.54272, 1238.72290, 797.74597,   0.00000, 0.00000, -90.00000);
    CreateDynamicObject(2527, 1067.54272, 1237.33765, 797.74597,   0.00000, 0.00000, -90.00000);
    CreateDynamicObject(2527, 1067.54272, 1235.87805, 797.74597,   0.00000, 0.00000, -90.00000);
    CreateDynamicObject(2527, 1067.54272, 1234.45569, 797.74597,   0.00000, 0.00000, -90.00000);
    pdint = CreateDynamicObject(19356, 1066.82703, 1233.00146, 799.48523,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(2738, 1066.09595, 1233.01880, 798.38080,   0.00000, 0.00000, -181.68001);
    CreateDynamicObject(2738, 1064.59875, 1233.01880, 798.38080,   0.00000, 0.00000, -181.67999);
    CreateDynamicObject(1502, 1065.24976, 1234.50842, 797.77417,   0.00000, 0.00000, 0.00000);
    pdint = CreateDynamicObject(19356, 1065.20654, 1232.99939, 799.48523,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(1502, 1063.60193, 1234.52917, 797.77417,   0.00000, 0.00000, 0.00000);
    pdint = CreateDynamicObject(19356, 1063.53870, 1233.01843, 799.48523,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(2380, 1054.99622, 1242.91211, 799.13538,   6.00000, 0.00000, 0.00000);
    CreateDynamicObject(2380, 1054.99622, 1242.91211, 798.26172,   6.00000, 0.00000, 0.00000);
    CreateDynamicObject(2389, 1052.43604, 1242.84998, 799.21057,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2389, 1053.03931, 1242.84998, 799.21057,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2389, 1051.83667, 1242.84998, 799.21057,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2384, 1056.34497, 1240.81079, 798.54193,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2384, 1057.70276, 1239.91345, 798.54193,   0.00000, 0.00000, 0.00000);
    pdint = CreateDynamicObject(19375, 1052.31384, 1232.44385, 802.68597,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1047.57080, 1230.92664, 799.48523,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(14411, 1045.71631, 1231.51038, 796.19788,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(14411, 1041.77795, 1229.49377, 794.56921,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(14411, 1041.90015, 1224.89380, 788.65637,   0.00000, 0.00000, 180.00000);
    pdint = CreateDynamicObject(19356, 1043.71143, 1227.87390, 796.05872,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1043.71143, 1230.92664, 796.05872,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1039.87573, 1230.92664, 796.05872,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1039.87573, 1230.92664, 799.48523,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1039.87573, 1227.79944, 796.05872,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1043.71143, 1224.71240, 797.52942,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1043.71143, 1224.71240, 794.05640,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1043.71143, 1227.87390, 792.57068,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19378, 1048.91211, 1224.85754, 799.31622,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19378, 1034.67688, 1225.20911, 799.31622,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19378, 1048.91211, 1215.23669, 799.31622,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19378, 1034.67688, 1215.58691, 799.31622,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19458, 1041.96863, 1221.64075, 799.31622,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    CreateDynamicObject(19458, 1041.61462, 1221.63440, 799.30621,   0.00000, 90.00000, 0.00000);
    CreateDynamicObject(2180, 1052.14417, 1227.24817, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1049.46863, 1227.24817, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1046.89600, 1227.24817, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1046.89600, 1225.21704, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1049.46863, 1225.21704, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1052.14417, 1225.21704, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1046.89600, 1223.16260, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1049.46863, 1223.16260, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1052.14417, 1223.16260, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1046.89600, 1221.24768, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1049.46863, 1221.24768, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1052.14417, 1221.24768, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1046.89600, 1219.48706, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1049.46863, 1219.48706, 799.38147,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2180, 1052.14417, 1219.48706, 799.38147,   0.00000, 0.00000, 0.00000);
    pdint = CreateDynamicObject(19375, 1054.07324, 1224.85962, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1054.07324, 1215.29443, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1048.49304, 1215.74976, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1058.10828, 1215.74976, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1043.74548, 1220.50525, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1043.74451, 1227.74402, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1047.57080, 1230.92664, 802.86597,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1047.57080, 1230.92664, 806.32068,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1028.74219, 1229.89832, 804.57770,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1041.42041, 1226.38562, 800.96143,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1042.08057, 1226.38562, 800.96143,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1042.08057, 1226.38562, 804.40753,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1041.42041, 1226.38562, 804.40747,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1039.87573, 1225.17126, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1039.87573, 1215.59583, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1029.41272, 1215.65747, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1029.41272, 1225.17664, 802.85101,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(16782, 1034.19836, 1211.03540, 802.52795,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(16662, 1033.44702, 1212.46008, 800.54346,   0.00000, 0.00000, 155.10014);
    pdint = CreateDynamicObject(19375, 1035.14355, 1210.85535, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1025.58167, 1210.85535, 802.85101,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(2611, 1029.59729, 1218.81885, 801.26831,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2737, 1029.59729, 1216.99219, 801.24835,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2616, 1049.53345, 1215.93115, 801.16229,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2616, 1051.40417, 1215.93115, 801.16229,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2615, 1048.09729, 1215.87524, 801.30139,   0.00000, 0.00000, -179.90005);
    CreateDynamicObject(1721, 1049.97546, 1228.46973, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1052.66370, 1228.46973, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1047.34827, 1228.46973, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1052.66370, 1226.54004, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1049.97546, 1226.54004, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1047.34827, 1226.54004, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1047.34827, 1224.46326, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1049.97546, 1224.46326, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1052.66370, 1224.46326, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1047.34827, 1222.48706, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1047.34827, 1220.66040, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1049.97546, 1222.48706, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1049.97546, 1220.66040, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1052.66370, 1222.48706, 799.39752,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1052.66370, 1220.66040, 799.39752,   0.00000, 0.00000, 180.00000);
    pdint = CreateDynamicObject(19375, 1052.30090, 1229.40613, 802.68597,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1039.87573, 1230.92664, 802.93903,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1039.87573, 1230.92664, 806.42285,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1034.97693, 1229.89832, 808.09369,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1045.42944, 1229.59045, 801.11938,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1048.59119, 1229.59045, 801.11938,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1048.58215, 1229.59045, 808.05212,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19429, 1037.27283, 1231.73303, 799.43878,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19429, 1037.26807, 1230.70813, 799.43878,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19429, 1037.27283, 1231.73303, 802.84601,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19429, 1037.26807, 1230.70813, 802.84601,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1032.54529, 1232.46387, 802.85876,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(14411, 1037.87329, 1231.77026, 796.18530,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(14411, 1038.47314, 1224.87073, 788.65637,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(14488, 1025.64624, 1213.13391, 794.26404,   0.00000, 0.00000, -269.33997);
    CreateDynamicObject(18049, 1050.11707, 1200.45227, 791.52844,   0.00000, 0.00000, 90.48001);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1041.20349, 1217.76111, 791.36029,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1036.36450, 1215.18005, 792.40033,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1043.71143, 1224.71240, 790.58636,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1043.71143, 1221.52771, 793.49902,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1043.71143, 1219.43372, 793.49902,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1043.71143, 1219.43372, 795.88043,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1043.71143, 1221.52771, 795.88037,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1036.36450, 1220.77502, 796.10504,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1039.87573, 1227.79944, 792.39374,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19458, 1041.61292, 1221.61450, 799.30371,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19375, 1041.20349, 1217.74109, 794.07727,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1036.36450, 1226.30664, 792.62811,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19458, 1038.20361, 1222.18115, 797.69629,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1054.12256, 1275.37256, 807.33716,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1043.62683, 1275.37256, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1033.22937, 1275.37256, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1033.22937, 1265.87256, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1043.66858, 1265.87256, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1054.11633, 1265.87256, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1033.22937, 1256.35425, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1043.68311, 1256.35425, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1053.97827, 1256.35425, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1033.78345, 1246.68079, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1044.21228, 1246.70032, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1054.54907, 1246.68079, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1054.54907, 1237.11292, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1044.21228, 1237.06311, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1033.79773, 1237.02368, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1034.63513, 1227.48999, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1045.18311, 1227.48999, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1055.49756, 1227.48999, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1048.96655, 1218.09570, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1034.62585, 1217.92371, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1034.63513, 1208.54529, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19377, 1064.80359, 1237.39197, 807.33722,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19356, 1041.42041, 1226.38562, 807.88092,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1042.08057, 1226.38562, 807.88092,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1050.02161, 1233.88635, 799.48523,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1032.54614, 1229.89832, 804.57770,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1035.00610, 1207.46570, 800.19641,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    pdint = CreateDynamicObject(19428, 1039.18091, 1213.30627, 800.19641,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    pdint = CreateDynamicObject(19428, 1029.08325, 1212.69714, 800.19641,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    pdint = CreateDynamicObject(19428, 1029.08325, 1211.79712, 800.19641,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 9818, "ship_brijsfw", "CJ_WOOD1",0);
    CreateDynamicObject(1535, 1037.89514, 1217.80493, 791.81451,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1985, 1021.67828, 1220.54492, 794.94110,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1535, 1043.66370, 1218.44250, 791.81451,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1985, 1021.63831, 1222.84363, 794.94110,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1985, 1018.60291, 1219.98230, 794.94110,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2627, 1029.66284, 1205.40308, 791.83252,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2627, 1027.99280, 1205.40308, 791.83252,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2627, 102.66280, 1205.40308, 791.83252,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2627, 1026.36804, 1205.40308, 791.83252,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2627, 1024.71191, 1205.40308, 791.83252,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2627, 1023.07147, 1205.40308, 791.83252,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2627, 1021.37152, 1205.40308, 791.83252,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2627, 1019.79248, 1205.40308, 791.83252,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2627, 1018.18573, 1205.40308, 791.83252,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2628, 1034.79114, 1213.42896, 791.83368,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(2628, 1034.79114, 1211.77820, 791.83368,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(2628, 1034.79114, 1210.44385, 791.83368,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(2628, 1034.79114, 1209.19385, 791.83368,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(2628, 1034.79114, 1214.61938, 791.83368,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(2628, 1034.79114, 1215.97083, 791.83368,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(2628, 1034.79114, 1217.40308, 791.83368,   0.00000, 0.00000, 269.99991);
    CreateDynamicObject(2629, 1028.04968, 1217.92346, 791.83368,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2629, 1026.41101, 1217.92346, 791.83368,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2629, 1024.41162, 1217.92346, 791.83368,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2629, 1022.67139, 1217.92346, 791.83368,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2629, 1020.78162, 1217.92346, 791.83368,   0.00000, 0.00000, 0.00000);
    pdint = CreateDynamicObject(19429, 1037.27283, 1231.73303, 806.30731,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19429, 1037.26807, 1230.70813, 806.30731,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1038.34949, 1229.89832, 801.11938,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(19447, 1050.75012, 1205.21765, 792.63763,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(18050, 1048.80298, 1200.37451, 794.68469,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(18051, 1048.33557, 1196.20520, 793.35394,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2049, 1050.14905, 1185.81165, 793.76801,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2049, 1046.97217, 1186.10864, 793.76801,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2049, 1048.69409, 1187.00732, 793.76801,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2050, 1053.23120, 1184.88708, 793.76801,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2050, 1052.11243, 1185.13013, 792.26874,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2050, 1058.93787, 1182.00562, 793.18127,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2050, 1048.85681, 1176.86548, 793.48199,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2050, 1043.04321, 1182.40039, 792.26874,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2050, 1043.04321, 1182.40039, 793.79041,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2050, 1046.95007, 1176.53979, 792.52338,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2050, 1051.74390, 1182.29211, 793.79041,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(3374, 1057.43347, 1184.15454, 791.49567,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3374, 1049.07739, 1178.84814, 791.92792,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2050, 1051.36792, 1177.20923, 792.52338,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(3374, 1054.74927, 1177.00952, 794.67078,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(3374, 1054.74927, 1177.00952, 791.28601,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2050, 1054.29944, 1176.34082, 792.70502,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2050, 1055.92810, 1176.71973, 792.70502,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2050, 1052.84973, 1178.19653, 792.70502,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(3374, 1042.85168, 1179.04150, 791.92792,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2050, 1044.11121, 1174.05957, 793.36090,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1551, 1044.54138, 1180.62451, 793.66296,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1043.04114, 1178.61682, 793.66296,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1042.59766, 1179.69727, 793.66296,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1048.30505, 1179.00146, 793.66296,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1051.11987, 1178.64392, 793.66296,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1049.88818, 1177.23730, 793.66296,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1050.18896, 1177.23926, 793.66296,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1050.54626, 1177.28564, 793.66296,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1050.84521, 1177.30762, 793.66296,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1049.56995, 1177.19421, 793.66296,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1054.16431, 1177.99231, 792.94513,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1055.13428, 1177.34143, 792.94513,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1053.36804, 1177.09131, 792.94513,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1056.46729, 1177.75964, 792.94513,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1055.16785, 1176.34094, 792.94513,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1058.92749, 1182.13403, 793.18530,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1057.23792, 1182.49792, 793.18530,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1058.92725, 1183.11255, 793.18530,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1058.10315, 1183.08740, 793.18530,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1055.57874, 1183.86609, 793.18530,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1049.67969, 1185.27844, 792.07739,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1048.11768, 1185.04114, 792.07739,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1056.18909, 1187.17468, 792.07739,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1042.92041, 1184.49683, 792.07739,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1551, 1045.11255, 1187.89905, 792.07739,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(14791, 1018.18561, 1212.69702, 792.44238,   0.00000, 0.00000, 0.00000);
    pdint = CreateDynamicObject(19375, 1030.62598, 1256.27832, 806.16138,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1030.62598, 1256.27832, 793.66791,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1030.61450, 1260.05627, 793.66791,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19325, 1030.70093, 1254.91138, 801.15198,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0,  -1, "none", "none", 0xFF9FF5FF);
    pdint = CreateDynamicObject(19325, 1030.70093, 1261.52783, 801.15198,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0,  -1, "none", "none", 0xFF9FF5FF);
    pdint = CreateDynamicObject(19375, 1030.62598, 1260.05627, 806.16138,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1025.88806, 1264.78638, 806.47974,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1029.08765, 1264.78638, 799.48767,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(1491, 1028.30103, 1264.78638, 797.77148,   0.00000, 0.00000, 0.00000);
    pdint = CreateDynamicObject(19386, 1029.08374, 1256.22900, 799.48767,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1029.08374, 1260.59326, 799.48767,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(1491, 1028.30371, 1260.59326, 797.77148,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1491, 1028.30371, 1256.22900, 797.77148,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2165, 1030.21814, 1253.13123, 797.73938,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(2165, 1030.21814, 1255.05286, 797.73938,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1806, 1029.04102, 1254.35571, 797.77509,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1806, 1029.04102, 1252.43591, 797.77509,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(2000, 1028.47168, 1251.84485, 797.74530,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2000, 1028.47168, 1252.34509, 797.74530,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2165, 1030.20886, 1258.48853, 797.73938,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(2000, 1030.01428, 1259.21973, 797.50330,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(2000, 1030.01428, 1259.69775, 797.50330,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1806, 1029.11511, 1257.94617, 797.77509,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(2165, 1030.15039, 1262.30835, 797.73938,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(2165, 1030.15039, 1264.23633, 797.73938,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1806, 1029.43616, 1261.60132, 797.77509,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1806, 1029.08472, 1263.38879, 797.77509,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(2000, 1028.35791, 1262.19958, 797.75201,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2000, 1028.35913, 1262.66138, 797.75201,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2000, 1028.35730, 1261.72009, 797.75201,   0.00000, 0.00000, 90.00000);
    pdint = CreateDynamicObject(19355, 1030.68506, 1253.78833, 801.13593,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterialText(pdint, 0, "Vehicle Registration", 60, "Ariel", 14, 1, -16777215, 0, 1);
    pdint = CreateDynamicObject(19355, 1030.68506, 1258.45874, 801.13593,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterialText(pdint, 0, "Legalization of Weapons", 60, "Ariel", 14, 1, -16777215, 0, 1);
    pdint = CreateDynamicObject(19355, 1030.68506, 1262.71021, 801.13593,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterialText(pdint, 0, "Passports", 60, "Ariel", 14, 1, -16777215, 0, 1);
    pdint = CreateDynamicObject(19375, 1036.36450, 1226.30664, 782.15393,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1036.36450, 1235.89795, 788.95386,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1044.60632, 1232.53979, 788.95392,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1039.87573, 1227.79944, 781.90955,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1041.23413, 1240.76917, 788.95392,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19375, 1045.63110, 1237.43372, 788.95392,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19378, 1041.51807, 1233.09985, 792.92017,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19378, 1041.51807, 1242.72839, 792.92023,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19378, 1041.51807, 1233.09985, 785.59680,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19378, 1041.51807, 1242.72681, 785.59680,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 14771, "int_brothelint3", "GB_nastybar12",0);
    pdint = CreateDynamicObject(19386, 1037.51245, 1236.26245, 787.40778,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(1649, 1040.55298, 1240.04456, 787.22858,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1502, 1040.62451, 1236.33252, 785.68445,   0.00000, 0.00000, 90.00000);
    pdint = CreateDynamicObject(19375, 1043.91785, 1236.26245, 788.95392,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(1649, 1042.82800, 1232.49084, 787.22858,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1502, 1042.86206, 1236.19543, 785.68439,   0.00000, 0.00000, 269.00000);
    pdint = CreateDynamicObject(19386, 1039.96729, 1234.58179, 787.40778,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19386, 1039.96729, 1231.37830, 787.40778,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19448, 1039.96729, 1231.38562, 790.89178,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19448, 1039.96729, 1231.52563, 792.69531,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19448, 1034.31445, 1236.26245, 794.35529,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19448, 1034.31445, 1236.26245, 790.89178,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19448, 1042.82800, 1231.40747, 792.68909,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19448, 1042.82800, 1231.40747, 789.91290,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19448, 1040.55298, 1241.15234, 789.91290,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19448, 1040.55298, 1241.15234, 793.32910,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(1721, 1044.30554, 1235.20764, 785.68542,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1516, 1044.15356, 1233.92749, 785.85492,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1721, 1045.45947, 1233.88306, 785.68542,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1721, 1044.19897, 1232.72607, 785.68542,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1721, 1041.90906, 1232.77271, 785.68542,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1721, 1041.29822, 1232.77271, 785.68542,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1721, 1040.67053, 1232.77271, 785.68542,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1516, 1043.84167, 1239.30774, 785.85492,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1721, 1043.89368, 1238.02930, 785.68237,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1721, 1045.16394, 1239.34888, 785.68237,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1721, 1043.98425, 1240.61450, 785.68237,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1045.07361, 1237.47034, 785.84113,   96.00000, 0.00000, 0.00000);
    CreateDynamicObject(1721, 1041.73059, 1239.89355, 786.32239,   -135.00000, 0.00000, 2.00000);
    CreateDynamicObject(1721, 1036.96472, 1240.47449, 785.68237,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1037.71191, 1240.48840, 785.68237,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1038.45117, 1240.45801, 785.68237,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19303, 1039.33850, 1232.62952, 786.93335,   0.00000, 0.00000, -60.00001);
    CreateDynamicObject(19303, 1037.32373, 1231.97192, 789.38269,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19303, 1037.32373, 1231.97192, 791.83527,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19303, 1037.32373, 1231.97192, 786.93335,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19303, 1039.00488, 1231.97192, 789.38269,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19303, 1039.00488, 1231.97192, 791.83533,   0.00000, 0.00000, 0.00000);
    pdint = CreateDynamicObject(19448, 1035.07373, 1228.35840, 794.60272,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19448, 1035.07373, 1228.35840, 797.22803,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19458, 1038.20361, 1213.86121, 797.69629,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19458, 1038.20361, 1223.48120, 797.69629,   0.00000, 90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    CreateDynamicObject(1502, 1038.89734, 1251.44043, 797.77222,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1557, 1039.17163, 1280.24231, 797.77332,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1557, 1042.15161, 1280.24231, 797.77332,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2614, 1041.16577, 1258.35742, 800.16669,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1044.52649, 1280.03687, 797.75317,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1045.18616, 1280.03687, 797.75317,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1045.86572, 1280.03687, 797.75317,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1046.54529, 1280.03687, 797.75317,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1047.20508, 1280.03687, 797.75317,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1047.90564, 1280.03687, 797.75317,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1048.62219, 1280.03687, 797.75317,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1721, 1049.32251, 1280.03687, 797.75317,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(638, 1038.77307, 1279.06592, 798.43951,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(638, 1042.48547, 1279.06592, 798.43951,   0.00000, 0.00000, 0.00000);
    pdint = CreateDynamicObject(19378, 1033.20435, 1275.36719, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19378, 1033.20435, 1256.24890, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    pdint = CreateDynamicObject(19378, 1033.20435, 1265.74719, 797.68707,   0.00000, -90.00000, 0.00000);
    SetDynamicObjectMaterial(pdint, 0, 4586, "pleas_dome", "club_floor2_sfwTEST", 0);
    CreateDynamicObject(1713, 1030.19226, 1278.82849, 797.73950,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1713, 1033.28271, 1278.82849, 797.73950,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1713, 1036.30383, 1278.82849, 797.73950,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1713, 1029.27063, 1275.34204, 797.73950,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1713, 1029.27063, 1272.42615, 797.73950,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1713, 1029.27063, 1269.43298, 797.73950,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1713, 1037.63953, 1277.00195, 797.73950,   0.00000, 0.00000, 270.00000);
    CreateDynamicObject(1713, 1037.63953, 1274.06458, 797.73950,   0.00000, 0.00000, 270.00000);
    CreateDynamicObject(1713, 1037.63953, 1271.06873, 797.73950,   0.00000, 0.00000, 270.00000);
    CreateDynamicObject(646, 1028.92773, 1278.94006, 799.1534,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19893, 1053.72437, 1250.31555, 798.59851,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19893, 1055.12903, 1250.31555, 798.59851,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19893, 1056.43250, 1250.31555, 798.59851,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19893, 1057.62219, 1250.27368, 798.59851,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19893, 1052.25098, 1250.31555, 798.59851,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19893, 1051.25122, 1248.68298, 798.59851,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(19893, 1050.86975, 1244.17603, 798.59851,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19893, 1052.25684, 1244.17603, 798.59851,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19893, 1054.64099, 1244.17603, 798.59851,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19893, 1053.34473, 1244.17603, 798.59851,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19893, 1055.64380, 1244.17603, 798.59851,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19893, 1056.77258, 1244.17603, 798.59851,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(19893, 1058.75684, 1245.37622, 798.59851,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(19893, 1058.75684, 1246.29407, 798.59851,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(19893, 1058.75684, 1247.41089, 798.59851,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(19893, 1058.75684, 1248.48999, 798.59851,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1649, 1042.82800, 1232.49084, 787.22858,   0.00000, 0.00000, 89.00000);
    CreateDynamicObject(1649, 1040.54553, 1240.02600, 787.22858,   0.00000, 0.00000, 89.00000);
    CreateDynamicObject(1523, 1059.85217, 1233.51575, 797.75568,   0.00000, 0.00000, 90.00000);
    pdint = CreateDynamicObject(19356, 1042.23706, 1232.48157, 807.88092,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1042.23706, 1232.48157, 804.38837,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1042.23706, 1232.48157, 802.96973,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1041.39709, 1232.48157, 802.96973,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1041.39709, 1232.48157, 804.38843,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1041.39709, 1232.48157, 807.88092,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    pdint = CreateDynamicObject(19356, 1042.08374, 1230.81628, 801.30762,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19356, 1042.08374, 1227.31628, 801.30762,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19356, 1041.54370, 1230.81628, 801.30762,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19356, 1041.54370, 1227.31628, 801.30762,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 11301, "carshow_sfse", "ws_officy_ceiling",0);
    pdint = CreateDynamicObject(19386, 1050.02161, 1246.62439, 799.49762,   0.00000, 0.00000, 0.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(2886, 1049.97876, 1238.09277, 799.14740,   0.00000, 0.00000, -90.00000);
    CreateDynamicObject(2886, 1044.25012, 1229.64380, 800.85760,   0.00000, 0.00000, -180.00000);
    CreateDynamicObject(2886, 1039.38123, 1230.04248, 800.85760,   0.00000, 0.00000, -180.00000);
    CreateDynamicObject(2886, 1036.40479, 1221.74072, 793.51788,   0.00000, 0.00000, -269.00000);
    CreateDynamicObject(2886, 1038.57166, 1236.17993, 787.46661,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2886, 1039.89868, 1235.61121, 787.46661,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(2886, 1049.99121, 1247.65295, 799.14740,   0.00000, 0.00000, -90.00000);
    CreateDynamicObject(2886, 1049.70593, 1251.44275, 799.14740,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2886, 1032.32104, 1251.41821, 799.14740,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2886, 1032.47339, 1251.59106, 799.14740,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2886, 1049.72546, 1251.57947, 799.14740,   0.00000, 0.00000, 180.00000);
    pdint = CreateDynamicObject(19356, 1034.47107, 1251.51318, 799.48523,   0.00000, 0.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    CreateDynamicObject(2165, 1045.94836, 1253.07312, 797.73938,   0.00000, 0.00000, -90.00000);
    CreateDynamicObject(1806, 1044.92773, 1252.47449, 797.77509,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1806, 1044.92773, 1254.29663, 797.77509,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(2165, 1045.94836, 1254.79517, 797.73938,   0.00000, 0.00000, -90.00000);
    CreateDynamicObject(2165, 1045.94836, 1256.70581, 797.73938,   0.00000, 0.00000, -90.00000);
    CreateDynamicObject(1806, 1044.92773, 1256.03516, 797.77509,   0.00000, 0.00000, 269.00000);
    CreateDynamicObject(1806, 1045.22778, 1256.93030, 797.77509,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2165, 1044.72839, 1257.58313, 797.73938,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2165, 1042.82837, 1257.58313, 797.73938,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1806, 1043.30786, 1256.55029, 797.77509,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2165, 1040.90845, 1257.58313, 797.73938,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2165, 1038.99011, 1257.58313, 797.73938,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(2165, 1037.07007, 1257.58313, 797.73938,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1806, 1039.55054, 1256.55029, 797.74689,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1806, 1041.56238, 1256.55029, 797.74689,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1806, 1037.41760, 1256.61951, 797.77509,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2165, 1036.20825, 1256.00244, 797.73938,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2165, 1036.20825, 1254.06250, 797.73938,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1806, 1037.25134, 1254.78186, 797.77509,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1806, 1037.25134, 1252.83606, 797.77509,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2165, 1036.20825, 1252.13257, 797.73938,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2164, 1038.40344, 1251.63586, 797.71857,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2000, 1041.64526, 1252.03320, 797.75781,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2000, 1042.13110, 1252.01624, 797.75781,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2000, 1042.63110, 1252.01624, 797.75781,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2000, 1043.13110, 1252.01624, 797.75781,   0.00000, 0.00000, 180.00000);
    pdint = CreateDynamicObject(19449, 1040.93567, 1256.35681, 800.25592,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 6038, "lawwhitebuilds", "brwall_128",0);
    pdint = CreateDynamicObject(19449, 1040.39929, 1253.18982, 800.25592,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 6038, "lawwhitebuilds", "brwall_128",0);
    pdint = CreateDynamicObject(19444, 1045.85718, 1253.21338, 800.25592,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 6038, "lawwhitebuilds", "brwall_128",0);
    pdint = CreateDynamicObject(19444, 1045.88721, 1255.96704, 800.25592,   0.00000, -90.00000, 90.00000);
    SetDynamicObjectMaterial(pdint,0, 6038, "lawwhitebuilds", "brwall_128",0);
    CreateDynamicObject(2435, 1046.30786, 1251.93152, 797.60931,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1046.30786, 1252.19153, 797.60931,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1046.30786, 1253.11292, 797.60931,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1046.30786, 1254.03650, 797.60931,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1046.30786, 1254.95776, 797.60931,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1046.30786, 1255.87805, 797.60931,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1046.30786, 1256.79773, 797.60931,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2434, 1046.30786, 1257.72119, 797.60931,   0.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1045.18481, 1257.90125, 797.60931,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2435, 1044.28235, 1257.90125, 797.60931,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2435, 1043.35852, 1257.90125, 797.60931,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2435, 1042.43848, 1257.90125, 797.60931,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2435, 1041.51880, 1257.90125, 797.60931,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2435, 1040.59875, 1257.90125, 797.60931,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2435, 1039.67310, 1257.90125, 797.60931,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2435, 1038.76770, 1257.90125, 797.60931,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2435, 1037.86707, 1257.90125, 797.60931,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2435, 1036.92383, 1257.90125, 797.60931,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2434, 1036.00220, 1257.89758, 797.60931,   0.00000, 0.00000, 180.00000);
    CreateDynamicObject(2435, 1035.84106, 1256.77429, 797.60931,   0.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1035.84106, 1255.87109, 797.60931,   0.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1035.84106, 1254.94226, 797.60931,   0.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1035.84106, 1254.01892, 797.60931,   0.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1035.84106, 1253.10999, 797.60931,   0.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1035.84106, 1252.00586, 797.60931,   0.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1035.84106, 1252.20837, 797.60931,   0.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1035.84106, 1251.91101, 800.6051,   180.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1035.84106, 1252.19104, 800.6051,   180.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1035.84106, 1253.11096, 800.6051,   180.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1035.84106, 1254.03101, 800.6051,   180.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1035.84106, 1254.95105, 800.6051,   180.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1035.84106, 1255.87109, 800.6051,   180.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1035.84106, 1256.79114, 800.6051,   180.00000, 0.00000, 90.00000);
    CreateDynamicObject(2434, 1035.84106, 1257.70117, 800.6051,   180.00000, 0.00000, 90.00000);
    CreateDynamicObject(2435, 1036.95850, 1257.88123, 800.6051,   180.00000, 0.00000, 0.00000);
    CreateDynamicObject(2435, 1037.11853, 1257.88123, 800.6051,   180.00000, 0.00000, 0.00000);
    CreateDynamicObject(2435, 1038.03857, 1257.88123, 800.6051,   180.00000, 0.00000, 0.00000);
    CreateDynamicObject(2435, 1038.95862, 1257.88123, 800.6051,   180.00000, 0.00000, 0.00000);
    CreateDynamicObject(2435, 1039.87854, 1257.88123, 800.6051,   180.00000, 0.00000, 0.00000);
    CreateDynamicObject(2435, 1040.79517, 1257.88123, 800.6051,   180.00000, 0.00000, 0.00000);
    CreateDynamicObject(2435, 1041.69885, 1257.88123, 800.6051,   180.00000, 0.00000, 0.00000);
    CreateDynamicObject(2435, 1043.54431, 1257.88123, 800.6051,   180.00000, 0.00000, 0.00000);
    CreateDynamicObject(2435, 1042.61877, 1257.88123, 800.6051,   180.00000, 0.00000, 0.00000);
    CreateDynamicObject(2435, 1045.38477, 1257.88123, 800.6051,   180.00000, 0.00000, 0.00000);
    CreateDynamicObject(2435, 1044.46826, 1257.88123, 800.6051,   180.00000, 0.00000, 0.00000);
    CreateDynamicObject(2434, 1046.28784, 1257.88123, 800.6051,   180.00000, 0.00000, -1.38000);
    CreateDynamicObject(2435, 1046.44495, 1256.75244, 800.6051,   180.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1046.44495, 1254.91235, 800.6051,   180.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1046.44495, 1255.83240, 800.6051,   180.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1046.44495, 1253.99243, 800.6051,   180.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1046.44495, 1253.07239, 800.6051,   180.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1046.44495, 1251.89246, 800.6051,   180.00000, 0.00000, 270.00000);
    CreateDynamicObject(2435, 1046.44495, 1252.15234, 800.6051,   180.00000, 0.00000, 270.00000);
    CreateDynamicObject(19370, 1040.19141, 1278.59595, 797.68707,   0.00000, -90.00000, 0.00000);
    CreateDynamicObject(19370, 1040.19141, 1275.41174, 797.68707,   0.00000, -90.00000, 0.00000);
    CreateDynamicObject(19370, 1040.19141, 1272.21631, 797.68707,   0.00000, -90.00000, 0.00000);
    CreateDynamicObject(19370, 1040.19141, 1269.05676, 797.68707,   0.00000, -90.00000, 0.00000);
    CreateDynamicObject(19370, 1040.19141, 1265.86096, 797.68707,   0.00000, -90.00000, 0.00000);
    CreateDynamicObject(19370, 1040.19141, 1262.67944, 797.68707,   0.00000, -90.00000, 0.00000);
    CreateDynamicObject(19370, 1040.19141, 1259.51892, 797.68707,   0.00000, -90.00000, 0.00000);
    CreateDynamicObject(19370, 1040.18811, 1256.36023, 797.68707,   0.00000, -90.00000, 0.00000);
    CreateDynamicObject(19370, 1040.18811, 1253.18018, 797.68707,   0.00000, -90.00000, 0.00000);
    CreateDynamicObject(19459, 1042.00037, 1282.18884, 796.04602,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19459, 1042.00037, 1272.56067, 796.04602,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19459, 1042.00037, 1262.95654, 796.04602,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19459, 1038.52039, 1272.53918, 796.04602,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19459, 1038.52039, 1262.93921, 796.04602,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(19459, 1038.52039, 1282.07471, 796.04602,   0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1535, 1029.06189, 1240.14001, 797.77368,   0.00000, 0.00000, 90.00000);
    pdtuer1 = CreateDynamicObject(1569, 1050.00244, 1236.30676, 797.77301,   0.00000, 0.00000, 90.00000);//door
    pdtuer2 = CreateDynamicObject(1569, 1046.16833, 1229.59045, 799.34991,   0.00000, 0.00000, 180.00000);//door
    pdtuer3 = CreateDynamicObject(1569, 1050.02161, 1245.85291, 797.77301,   0.00000, 0.00000, 90.00000);//door
    pdtuer4 = CreateDynamicObject(1569, 1047.95386, 1251.51318, 797.77301,   0.00000, 0.00000, 0.00000);//door
    pdtuer5 = CreateDynamicObject(1569, 1030.62195, 1251.51318, 797.77301,   0.00000, 0.00000, 0.00000);//door
    pdtuer6 = CreateDynamicObject(1569, 1037.58594, 1229.89832, 799.34991,   0.00000, 0.00000, 0.00000);//door
    pdtuer7 = CreateDynamicObject(1495, 1036.37781, 1219.99023, 791.83832,   0.00000, 0.00000, 90.00000);//door
    pdtuer8 = CreateDynamicObject(1495, 1039.95654, 1233.85657, 785.68457,   0.00000, 0.00000, 90.00000);//door
    pdtuer9 = CreateDynamicObject(1495, 1036.73132, 1236.22620, 785.68457,   0.00000, 0.00000, 0.00000);//door
    
    //taxibase:
    /*
    	pdint = CreateDynamicObject(19386, 1038.34949, 1229.89832, 801.11938,   0.00000, 0.00000, 90.00000);
    	SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    */
    new taxiint;
    CreateDynamicObject(18981, 1072.87830, -1373.01184, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18981, 1072.89819, -1348.01379, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18981, 1072.89819, -1323.01453, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1310.01550, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1304.02515, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1309.01733, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1303.02515, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1307.02063, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1296.03564, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1305.02405, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1308.01904, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1302.02527, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1306.02222, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1301.02551, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1292.04248, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1300.02649, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1295.03650, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1299.02905, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1298.03186, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1294.03882, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1293.04004, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1072.89819, -1297.03455, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1173.89368, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18981, 1085.89783, -1291.04346, 0.78320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18981, 1110.89685, -1291.04346, 0.78320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18981, 1135.89624, -1291.04346, 0.78320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18981, 1160.89490, -1291.04346, 0.78320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18980, 1072.89819, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1179.88464, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1174.89209, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1184.87744, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1177.88672, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1175.89075, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1183.87769, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1176.88867, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1182.87903, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1178.88696, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1181.88000, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1180.88245, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1291.04346, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1292.04248, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1293.04004, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1294.03882, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1295.03650, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1296.03564, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1297.03455, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1298.03186, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1299.02905, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1300.02649, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1301.02551, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1302.02527, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1303.02515, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1304.02515, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1305.02405, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1306.02222, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1307.02063, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1308.01904, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1309.01733, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1185.87708, -1310.01550, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18981, 1185.87708, -1323.01453, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18981, 1185.87708, -1348.01379, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18981, 1185.87708, -1373.01355, 0.78320,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18981, 1085.89783, -1385.01196, 0.78320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18981, 1110.89685, -1385.01196, 0.78320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18981, 1135.89624, -1385.01196, 1.65530,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18981, 1160.91394, -1385.00598, 0.78320,   0.00000, 0.00000, 90.00000);
	taxiint=CreateObject(19377, 1180.13745, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(CreateObject(19377, 1180.13745, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000), 0, 10789, "xenon_sfse", "crackedgroundb", 0xFFFFFFFF);
	
	
	 
    /*
    	pdint = CreateDynamicObject(19386, 1038.34949, 1229.89832, 801.11938,   0.00000, 0.00000, 90.00000);
    	SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    */
	
	
	CreateDynamicObject(18980, 1184.87744, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1183.87769, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1182.87903, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1181.88000, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1180.88245, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1179.88464, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1178.88696, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1177.88672, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1176.88867, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1175.89075, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1174.89209, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1173.89368, -1385.01196, 0.16120,   0.00000, 0.00000, 0.00000);
	CreateObject(19377, 1169.63660, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(CreateObject(19377, 1169.63660, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000), 0, 10789, "xenon_sfse", "crackedgroundb", 0xFFFFFFFF);
	
	 
    /*
    	pdint = CreateDynamicObject(19386, 1038.34949, 1229.89832, 801.11938,   0.00000, 0.00000, 90.00000);
    	SetDynamicObjectMaterial(pdint,0, 8460, "vgseland03_lvs", "ceaserwall06_128", 0);
    */
	
	CreateObject(19377, 1159.13745, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(CreateObject(19377, 1159.13745, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000), 0, 10789, "xenon_sfse", "crackedgroundb", 0xFFFFFFFF);
	CreateObject(19377, 1106.63696, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(CreateObject(19377, 1106.63696, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000), 0, 10789, "xenon_sfse", "crackedgroundb", 0xFFFFFFFF);
	CreateObject(19377, 1148.63745, -1379.69824, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(CreateObject(19377, 1148.63745, -1379.69824, 12.56630,   0.00000, 90.00000, 0.00000), 0, 10789, "xenon_sfse", "crackedgroundb", 0xFFFFFFFF);
	CreateObject(19377, 1127.63757, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(CreateObject(19377, 1127.63757, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000), 0, 10789, "xenon_sfse", "crackedgroundb", 0xFFFFFFFF);
	CreateObject(19377, 1138.13684, -1379.69824, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(CreateObject(19377, 1138.13684, -1379.69824, 12.56630,   0.00000, 90.00000, 0.00000), 0, 10789, "xenon_sfse", "crackedgroundb", 0xFFFFFFFF);
	CreateObject(19377, 1117.13843, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(CreateObject(19377, 1117.13843, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000), 0, 10789, "xenon_sfse", "crackedgroundb", 0xFFFFFFFF);
	CreateObject(19377, 1096.13538, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(CreateObject(19377, 1096.13538, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000), 0, 10789, "xenon_sfse", "crackedgroundb", 0xFFFFFFFF);
	CreateObject(19377, 1085.63525, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(CreateObject(19377, 1085.63525, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000), 0, 10789, "xenon_sfse", "crackedgroundb", 0xFFFFFFFF);
	CreateObject(19377, 1085.63525, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(CreateObject(19377, 1085.63525, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000), 0, 10789, "xenon_sfse", "crackedgroundb", 0xFFFFFFFF);
	CreateObject(19377, 1096.13550, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateObject(19377, 1106.63696, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	CreateObject(19377, 1117.13843, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	CreateObject(19377, 1127.63757, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1138.13684, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1148.63745, -1370.06506, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1159.13855, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1169.63660, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1180.13745, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1085.63525, -1360.43872, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1085.65442, -1302.64197, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1085.63525, -1350.80518, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1085.63525, -1341.17126, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1085.63525, -1331.53784, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1085.63525, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1085.63525, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1096.13550, -1360.43872, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1096.13550, -1350.80518, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1096.13550, -1341.17126, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1096.13550, -1331.53784, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1096.13550, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1096.13550, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1096.13550, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1106.63696, -1360.43872, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1106.63696, -1350.80518, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1106.63696, -1341.17126, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1106.63696, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	new obtext = CreateObject(2714, 1175.56165, -1360.59570, 14.86920,   0.00000, 0.00000, 90.00000);
	SetObjectMaterialText(obtext,"Mitarbeiter &\nKundenparkplatz",0,OBJECT_MATERIAL_SIZE_256x128,"Arial",28,0,0xFFFFFFFF,0x000000FF,OBJECT_MATERIAL_TEXT_ALIGN_CENTER);
	taxiint = CreateDynamicObject(19452, 1075.13696, -1360.43726, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1075.13696, -1350.80334, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1075.13696, -1341.16956, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
    taxiint = CreateDynamicObject(19452, 1075.13696, -1331.53564, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1075.13696, -1321.90271, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1075.13696, -1312.26929, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1075.13696, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1078.63489, -1360.43726, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1078.63489, -1350.80334, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1078.63489, -1341.16956, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1078.63489, -1331.53564, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1078.63489, -1321.90271, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1078.63489, -1312.26929, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1078.63489, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1078.17090, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1078.17090, -1292.57104, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1087.80432, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1097.43835, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1087.80432, -1292.57104, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1097.43835, -1292.57104, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	CreateDynamicObject(19377, 1117.13843, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1117.13843, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1117.13843, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1127.63757, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1127.63757, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1127.63757, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1127.63757, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1117.13843, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1138.13684, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1138.13684, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1138.13684, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1138.13684, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1148.63745, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1148.63745, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1148.63745, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1148.63745, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1159.13855, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1159.13855, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1159.13855, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1159.13855, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1169.63660, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1169.63660, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1169.63660, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1169.63660, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1180.13745, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1180.13745, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1180.13745, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1180.13745, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19364, 1175.38721, -1382.90796, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 1175.38721, -1379.69739, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 1175.38721, -1376.48621, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 1175.38721, -1373.27734, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 1175.38721, -1370.06665, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 1173.69446, -1384.42566, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19410, 1155.94507, -1379.69739, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 1155.94507, -1382.90796, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19393, 1155.94507, -1376.48621, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19410, 1155.94507, -1373.27734, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 1155.94507, -1370.06665, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19466, 1155.94238, -1373.21411, 14.64710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19466, 1155.94238, -1379.70142, 14.64710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19410, 1157.64026, -1368.55042, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 1160.85034, -1368.55042, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 1167.27258, -1368.55042, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19410, 1170.48413, -1368.55042, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 1164.06213, -1368.55042, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 1173.69446, -1368.55042, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19466, 1170.37341, -1368.56128, 14.64710,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19466, 1157.66467, -1368.56128, 14.64710,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1491, 1155.94556, -1377.23145, 12.64110,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19425, 1177.12268, -1378.87524, 12.65540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19425, 1180.42700, -1378.87524, 12.65540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19425, 1183.72864, -1378.87524, 12.65540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19410, 1170.48413, -1384.42566, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 1167.27258, -1384.42566, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 1164.06213, -1384.42566, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 1160.85034, -1384.42566, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19410, 1157.64026, -1384.42566, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19466, 1170.39465, -1384.40088, 14.64710,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19466, 1157.66858, -1384.40088, 14.64710,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1173.54822, -1382.73206, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1156.05591, -1382.73206, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1170.04919, -1382.73206, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1166.55066, -1382.73206, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1163.05151, -1382.73206, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1159.55444, -1382.73206, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1156.05591, -1379.52185, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1159.55444, -1379.52185, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1163.05151, -1379.52185, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1166.55066, -1379.52185, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1170.04919, -1379.52185, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1173.54822, -1379.52185, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1156.05591, -1376.31152, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1156.05591, -1373.10095, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1156.05591, -1369.89014, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1159.55444, -1376.31152, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1163.05151, -1376.31152, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1166.55066, -1376.31152, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1170.04919, -1376.31152, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1173.54822, -1376.31152, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1159.55444, -1373.10095, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1163.05151, -1373.10095, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1166.55066, -1373.10095, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1170.04919, -1373.10095, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1173.54822, -1373.10095, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1159.55444, -1369.89014, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1163.05151, -1369.89014, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1166.55066, -1369.89014, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1170.04919, -1369.89014, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1173.54822, -1369.89014, 16.22800,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19360, 1154.28406, -1376.55530, 12.57720,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19122, 1149.21912, -1378.04895, 13.16640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19122, 1149.21912, -1375.09363, 13.16640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 1153.78198, -1374.95313, 13.10710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 1150.78467, -1376.55530, 12.57720,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(970, 1153.78198, -1378.16174, 13.10710,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19122, 1151.61584, -1375.08765, 13.16640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19122, 1149.21912, -1375.08765, 13.16640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19122, 1151.61584, -1378.05298, 13.16640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3525, 1155.60486, -1377.87793, 13.99140,   16.43960, 0.00000, -90.00000);
	CreateDynamicObject(3525, 1155.60486, -1375.47241, 13.99140,   16.43960, 0.00000, -89.22000);
	CreateDynamicObject(18980, 1175.42468, -1361.51111, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19980, 1175.51672, -1360.59338, 12.22320,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(968, 1175.44006, -1361.39355, 13.68470,   0.00000, 90.00000, -90.00000);
	CreateDynamicObject(18980, 1175.42468, -1360.51074, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18981, 1162.42664, -1361.51111, 1.65530,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18980, 1150.42676, -1360.51221, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1150.42676, -1359.51355, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1150.42676, -1358.51514, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1150.42676, -1357.51563, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1150.42676, -1356.51697, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1150.42676, -1354.51843, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1150.42676, -1355.51855, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1150.42676, -1353.52002, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18981, 1137.42932, -1353.52002, 1.65530,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18981, 1124.43298, -1365.51941, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1124.43298, -1378.51697, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1124.43298, -1379.51526, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1124.43298, -1380.51208, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1124.43298, -1381.50757, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1124.43298, -1383.50696, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1124.43298, -1382.50696, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18980, 1124.43298, -1384.50647, 1.65530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 1145.37964, -1355.62122, 10.90700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 1139.49182, -1355.62122, 10.90700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 1133.84253, -1355.62122, 10.90700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 1127.63159, -1355.62122, 10.90700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 1127.63159, -1358.83252, 10.90700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 1133.84253, -1358.83252, 10.90700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 1139.49182, -1358.83252, 10.90700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 1145.37964, -1358.83252, 10.90700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 1126.53467, -1369.09229, 10.90700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1126.53467, -1374.04675, 10.90700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1126.53467, -1380.04858, 10.90700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1129.74438, -1369.09229, 10.90700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1129.74438, -1374.04675, 10.90700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1129.74438, -1380.04858, 10.90700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1139.07373, -1382.93396, 10.90700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19360, 1144.31628, -1382.93396, 10.90700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2008, 1164.72620, -1383.88965, 12.65470,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2008, 1164.72620, -1381.90417, 12.65470,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2008, 1164.72620, -1379.91711, 12.65470,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2008, 1164.72620, -1377.93091, 12.65470,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2008, 1164.72620, -1375.94434, 12.65470,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1164.99487, -1374.48901, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1164.99487, -1376.52930, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1164.99487, -1378.46606, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1164.99487, -1382.47888, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19360, 1164.99487, -1380.46521, 14.38960,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 1163.47913, -1373.28369, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19433, 1163.48303, -1375.62134, 15.34900,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19433, 1163.48303, -1379.11914, 15.34900,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19433, 1163.48303, -1382.61890, 15.34900,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 1163.47913, -1370.06885, 14.38960,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1495, 1163.49182, -1374.01440, 12.63940,   0.00000, 0.00000, 90.00000);
	taxiint = CreateDynamicObject(19452, 1078.63489, -1370.07129, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1075.13696, -1370.07129, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1078.63489, -1379.70435, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1075.13696, -1379.70435, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	CreateDynamicObject(19377, 1106.63696, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1117.13843, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1127.63757, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1138.13684, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1148.63745, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1159.13855, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1169.63660, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1180.13745, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1106.63696, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1117.13843, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1127.63757, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1138.13684, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1148.63745, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1159.13855, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1169.63660, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1180.13745, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1106.63696, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1117.13843, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1127.63757, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1138.13684, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1148.63745, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1159.13855, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1169.63660, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1180.13745, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	taxiint = CreateDynamicObject(19452, 1107.06995, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1116.70435, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1126.33789, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1135.97253, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1145.60547, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1155.23645, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1164.87390, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1174.50732, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1107.06995, -1292.57104, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1116.70435, -1292.57104, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1126.33789, -1292.57104, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1135.97253, -1292.57104, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1145.60547, -1292.57104, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1155.23645, -1292.57104, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1164.87390, -1292.57104, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19452, 1174.50732, -1292.57104, 12.56630,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19360, 1181.07373, -1296.21375, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19360, 1184.57214, -1296.21375, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateDynamicObject(19360, 1181.07373, -1293.00146, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	CreateDynamicObject(19360, 1184.57214, -1293.00146, 12.56630,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19425, 1177.12268, -1378.34009, 12.65540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19425, 1177.12268, -1377.80432, 12.65540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19425, 1180.42700, -1378.34009, 12.65540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19425, 1183.72864, -1378.34009, 12.65540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19425, 1180.42700, -1377.80432, 12.65540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19425, 1183.72864, -1377.80432, 12.65540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19425, 1177.12268, -1379.40967, 12.65540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19425, 1180.42700, -1379.40967, 12.65540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19425, 1183.72864, -1379.40967, 12.65540,   0.00000, 0.00000, 0.00000);
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
	mysql_pquery(handle,query);
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
ocmd:ptuerzu1(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer1,1050.00244, 1236.30676, 797.77301,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geschlossen!");
	return 1;
}
ocmd:pdtuerauf1(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer1,1050.00244, 1236.30676, 795.11652,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geöffnet!");
	return 1;
}
ocmd:ptuerzu2(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer2,1046.16833, 1229.59045, 799.34991,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geschlossen!");
	return 1;
}
ocmd:pdtuerauf2(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer2,1046.16833, 1229.59045, 795.60071,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geöffnet!");
	return 1;
}
ocmd:ptuerzu3(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer3,1050.02161, 1245.85291, 797.77301,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geschlossen!");
	return 1;
}
ocmd:pdtuerauf3(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer3,1050.02161, 1245.85291, 792.88458,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geöffnet!");
	return 1;
}
ocmd:ptuerzu4(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer4,1047.95386, 1251.51318, 797.77301,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geschlossen!");
	return 1;
}
ocmd:pdtuerauf4(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer4,1046.4379, 1251.5132, 797.7730,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geöffnet!");
	return 1;
}
ocmd:ptuerzu5(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer5,1030.62195, 1251.51318, 797.77301, 797.77301,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geschlossen!");
	return 1;
}
ocmd:pdtuerauf5(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer5,1030.62195, 1251.51318, 792.88458,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geöffnet!");
	return 1;
}
ocmd:ptuerzu6(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer6,1037.58594, 1229.89832, 799.34991,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geschlossen!");
	return 1;
}
ocmd:pdtuerauf6(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer6,1037.58594, 1229.89832, 795.18408,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geöffnet!");
	return 1;
}
ocmd:ptuerzu7(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer7,1036.37781, 1219.99023, 791.83832,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geschlossen!");
	return 1;
}
ocmd:pdtuerauf7(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer7,1036.37781, 1219.99023, 788.38922,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geöffnet!");
	return 1;
}
ocmd:ptuerzu8(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer8,1039.95654, 1233.85657, 785.68457,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geschlossen!");
	return 1;
}
ocmd:pdtuerauf8(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer8, 1039.95654, 1233.85657, 782.40894,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geöffnet!");
	return 1;
}
ocmd:ptuerzu9(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer9,1036.73132, 1236.22620, 785.68457,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geschlossen!");
	return 1;
}
ocmd:pdtuerauf9(playerid,params[])
{
	if(!isPlayerInFrakt(playerid,1))return SendClientMessage(playerid,rot,"Du bist nicht im SAPD!");
	MoveDynamicObject(pdtuer9,1036.73132, 1236.22620, 781.23401,5);
	SendClientMessage(playerid,türkis,"Sie haben die Tür geöffnet!");
	return 1;
}
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
	 SendClientMessage(playerid,grün,"/acpu");
	 return 1;
}
   ocmd:acpu(playerid,params)
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
		if(GetPlayerVirtualWorld(playerid)!=i)continue;
		if(!IsPlayerInRangeOfPoint(playerid,2,bInfo[i][bi_x],bInfo[i][bi_y],bInfo[i][bi_z]))continue;
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
	printf("Hallo");
	if(sscanf(params,"ui",pID,mID))return SendClientMessage(playerid,rot,"INFO: /createcar[playerid][model]");
	printf("börger");
	if(mID<400||mID>611)return SendClientMessage(playerid,rot,"Ungültiges Model");
	printf("teleropa");
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