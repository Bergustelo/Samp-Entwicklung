#include <a_samp>
#include <a_mysql>
#include <sscanf2.inc>
#include <ocmd>
#include <streamer>


#define MYSQL_HOST "localhost"
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
	Float:c_r,
	Schaden,
	kennzeichen,
	tank
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
Float:v_r,
v_s,
v_k,
v_t
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
	AddPlayerClass(29,1159.6151,-1381.1644,13.6522,357.9040,0,0,0,0,0,0);
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
	taxiint= CreateObject(19377, 1180.13745, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
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
	taxiint=CreateObject(19377, 1169.63660, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint=CreateObject(19377, 1159.13745, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint=CreateObject(19377, 1106.63696, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint=CreateObject(19377, 1148.63745, -1379.69824, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint=CreateObject(19377, 1127.63757, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint=CreateObject(19377, 1138.13684, -1379.69824, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint=CreateObject(19377, 1117.13843, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint=CreateObject(19377, 1096.13538, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint=CreateObject(19377, 1085.63525, -1379.70532, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint=CreateObject(19377, 1085.63525, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint=CreateObject(19377, 1096.13550, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
	taxiint=CreateObject(19377, 1106.63696, -1370.07214, 12.56630,   0.00000, 90.00000, 0.00000);
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
	taxiint = CreateObject(19377, 1117.13843, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1117.13843, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1117.13843, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1127.63757, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1127.63757, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1127.63757, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1127.63757, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1117.13843, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1138.13684, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1138.13684, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1138.13684, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1138.13684, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1148.63745, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1148.63745, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1148.63745, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1148.63745, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1159.13855, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1159.13855, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1159.13855, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1159.13855, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1169.63660, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1169.63660, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1169.63660, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1169.63660, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1180.13745, -1360.44287, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1180.13745, -1350.80713, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1180.13745, -1341.17334, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1180.13745, -1331.53906, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
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
	taxiint = CreateObject(19377, 1106.63696, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1117.13843, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1127.63757, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1138.13684, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1148.63745, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1159.13855, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1169.63660, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1180.13745, -1321.90332, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1106.63696, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1117.13843, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1127.63757, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1138.13684, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1148.63745, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1159.13855, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1169.63660, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1180.13745, -1312.27014, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1106.63696, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1117.13843, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1127.63757, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1138.13684, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1148.63745, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1159.13855, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1169.63660, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19377, 1180.13745, -1302.63623, 12.56630,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(taxiint, 0, 8390, "vegasemulticar", "gnhotelwall02_128", 0xFFFFFFFF);
	taxiint = CreateObject(19452, 1107.06995, -1296.06982, 12.56630,   0.00000, 90.00000, 90.00000);
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
	
	
	
	   // ---------> Expert Gas in Idlewood
	new objekt;
    objekt = CreateDynamicObject(5811, 1951.56433, -1763.01941, 16.72081,   0.0, 0.0, 35.64,-1,-1,-1,400.0,400.0);
    SetDynamicObjectMaterial(objekt,0,1676, "wshxrefpump", "black64", 0xFFFFFFFF);
    SetDynamicObjectMaterialText(objekt, 1,"Unsere Öffnungszeiten:\n_____________________\nMontag - Sonntag: 05.00 - 00.00 Uhr\nFeiertage: 08.00 - 00.00 Uhr\n____________",  90, "Arial", 16, 1, 0xFF000000, 0xFFFFFFFF, 1);
    SetDynamicObjectMaterialText(objekt, 2,"Benzin                    1,05$\nSuper 95                 1,05$", 90, "Times New Roman", 25, 1, 0xFF000000, 0xFFFFFFFF, 1);
    SetDynamicObjectMaterialText(objekt, 3,"Diesel                    1,05$\nDiesel Premium     1,05$", 90, "Times New Roman", 25, 1, 0xFF000000, 0xFFFFFFFF, 1);
    SetDynamicObjectMaterialText(objekt, 4,"\n\n/// Expert Gas", 130, "Comic Sans MS", 70, 1, 0xFF000000, 0xFFFFFFFF, 1);
    SetDynamicObjectMaterial(objekt,5,3924, "rc_warhoose", "white", 0xFFFFFFFF);
   
    SetDynamicObjectMaterial(CreateDynamicObject(19380, 1923.07471, -1770.91504, 17.27400,   0.0, 90.0, 0.0,-1,-1,-1,300.0,300.0), 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_floor_hangar", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(19380, 1923.07471, -1780.54761, 17.27400,   0.0, 90.0, 0.0,-1,-1,-1,300.0,300.0), 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_floor_hangar", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(19380, 1923.07471, -1782.47876, 17.27700,   0.0, 90.0, 0.0,-1,-1,-1,300.0,300.0), 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_floor_hangar", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(19380, 1918.89429, -1782.47876, 17.27200,   0.0, 90.0, 0.0,-1,-1,-1,300.0,300.0), 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_floor_hangar", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(19380, 1918.89429, -1770.91504, 17.27000,   0.0, 90.0, 0.0,-1,-1,-1,300.0,300.0), 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_floor_hangar", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(19380, 1918.89429, -1780.54761, 17.27000,   0.0, 90.0, 0.0,-1,-1,-1,300.0,300.0), 0, 18250, "cw_junkbuildcs_t", "Was_scrpyd_floor_hangar", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(19377, 1923.07471, -1770.91504, 12.48220,   0.0, 90.0, 0.0,-1,-1,-1,140.0,140.0), 0, 16150, "ufo_bar", "dinerfloor01_128", 0xFFFFFFFF); // Boden Shop
    SetDynamicObjectMaterial(CreateDynamicObject(19377, 1923.07471, -1782.43848, 12.48220,   0.0, 90.0, 0.0,-1,-1,-1,140.0,140.0), 0, 16150, "ufo_bar", "dinerfloor01_128", 0xFFFFFFFF); // Boden Shop
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1926.57568, -1776.66565, 12.48920,   0.0, 90.0, 0.0,-1,-1,-1,140.0,140.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Boden Shop Mitte
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1923.08972, -1776.66565, 12.48920,   0.0, 90.0, 0.0,-1,-1,-1,140.0,140.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Boden Shop Mitte
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1919.59814, -1776.66565, 12.48920,   0.0, 90.0, 0.0,-1,-1,-1,140.0,140.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Boden Shop Mitte
    SetDynamicObjectMaterial(CreateDynamicObject(19378, 1923.07471, -1770.91504, 17.18090,   0.0, 90.0, 0.0,-1,-1,-1,140.0,140.0), 0, 6102, "gazlaw1", "law_gazwhitefloor", 0xFFFFFFFF); // Dach Shop
    SetDynamicObjectMaterial(CreateDynamicObject(19378, 1923.07471, -1782.43848, 17.18090,   0.0, 90.0, 0.0,-1,-1,-1,140.0,140.0), 0, 6102, "gazlaw1", "law_gazwhitefloor", 0xFFFFFFFF); // Dach Shop
    SetDynamicObjectMaterial(CreateDynamicObject(19366, 1926.57568, -1776.66565, 17.18390,   0.0, 90.0, 0.0,-1,-1,-1,140.0,140.0), 0, 6102, "gazlaw1", "law_gazwhitefloor", 0xFFFFFFFF); // Dach Shop
    SetDynamicObjectMaterial(CreateDynamicObject(19366, 1923.08972, -1776.66565, 17.18390,   0.0, 90.0, 0.0,-1,-1,-1,140.0,140.0), 0, 6102, "gazlaw1", "law_gazwhitefloor", 0xFFFFFFFF); // Dach Shop
    SetDynamicObjectMaterial(CreateDynamicObject(19366, 1919.59814, -1776.66565, 17.18390,   0.0, 90.0, 0.0,-1,-1,-1,140.0,140.0), 0, 6102, "gazlaw1", "law_gazwhitefloor", 0xFFFFFFFF); // Dach Shop
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.83972, -1778.74866, 14.83900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls vorne gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.83972, -1774.59412, 14.83900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls vorne gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.83972, -1766.59094, 14.83900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls vorne gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.83972, -1773.59412, 14.83900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls vorne gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.83972, -1779.74866, 14.83900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls vorne gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.83972, -1786.80005, 14.81900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls vorne gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1926.83972, -1766.59094, 14.83900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1920.48950, -1766.55225, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1919.49329, -1766.55225, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.07922, -1766.55225, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1918.50586, -1766.55225, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1917.50610, -1766.55225, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1916.50916, -1766.55225, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1915.52271, -1766.55225, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.83972, -1766.55615, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1920.48950, -1786.80005, 14.81900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1926.83972, -1786.80005, 14.81900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09924, -1786.80005, 14.81900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls seitlich gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09924, -1779.74866, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09924, -1778.76025, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09924, -1777.77869, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09924, -1776.78003, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09924, -1775.79846, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09924, -1774.81775, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09924, -1773.81702, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09924, -1772.81677, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09924, -1771.83667, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09424, -1771.61694, 14.85900,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten gerade
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.07996, -1779.81824, 12.37060,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls unten
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.84375, -1780.73022, 12.37060,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls unten
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.84778, -1784.73425, 12.37460,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls unten
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1916.09644, -1786.81445, 12.37060,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls unten
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1921.07495, -1786.81750, 12.37060,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls unten
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1925.84375, -1786.81445, 12.37460,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls unten
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.07996, -1784.81006, 12.37060,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls unten
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1921.05762, -1766.56409, 12.37060,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls unten
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1925.84631, -1766.56006, 12.37460,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls unten
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.84375, -1772.59790, 12.37060,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls unten
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.84778, -1768.56873, 12.37460,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls unten
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.09082, -1784.79651, 16.85560,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.10730, -1779.82971, 16.85560,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1914.10730, -1769.09631, 16.84370,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls hinten oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1925.84375, -1786.81445, 16.85560,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls links oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1920.85315, -1786.81055, 16.85560,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls links oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1916.11609, -1786.80310, 16.85560,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Walls links oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.84778, -1778.57068, 16.85560,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete Walls Oben / Schwarz Vorne und rechts
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.84778, -1783.56567, 16.85560,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete Walls Oben / Schwarz Vorne und rechts
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.85278, -1784.80615, 16.85560,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete Walls Oben / Schwarz Vorne und rechts
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.84778, -1773.57739, 16.85560,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete Walls Oben / Schwarz Vorne und rechts
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1927.84778, -1768.58875, 16.85560,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete Walls Oben / Schwarz Vorne und rechts
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1921.12585, -1766.57471, 16.85560,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete Walls Oben / Schwarz Vorne und rechts
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1925.82959, -1766.57971, 16.85560,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete Walls Oben / Schwarz Vorne und rechts
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1946.27332, -1781.11975, 17.53640,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF);// Concrete bei den Zapfsäulen / Schwarz oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1946.27332, -1776.12097, 17.53640,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF);// Concrete bei den Zapfsäulen / Schwarz oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1946.27332, -1771.12988, 17.53640,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF);// Concrete bei den Zapfsäulen / Schwarz oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1946.27332, -1766.14429, 17.53640,   0.0, 90.0, 90.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF);// Concrete bei den Zapfsäulen / Schwarz oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1944.27087, -1764.01050, 17.53440,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF);// Concrete bei den Zapfsäulen / Schwarz oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1939.28992, -1764.01050, 17.53440,   0.0, 90.0, 0.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF);// Concrete bei den Zapfsäulen / Schwarz oben
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1941.57727, -1775.88062, 12.26272,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete bei den Zapfsäulen
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1941.57727, -1767.32898, 14.56269,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete bei den Zapfsäulen
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1941.57727, -1779.88171, 14.56270,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete bei den Zapfsäulen
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1941.57727, -1771.29956, 12.26270,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete bei den Zapfsäulen
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1941.57727, -1778.88147, 10.32300,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete bei den Zapfsäulen
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1941.57727, -1777.88135, 10.32300,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete bei den Zapfsäulen
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1941.57727, -1776.88062, 10.32300,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete bei den Zapfsäulen
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1941.57727, -1768.30554, 10.32300,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete bei den Zapfsäulen
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1941.57727, -1769.30603, 10.32300,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete bei den Zapfsäulen
    SetDynamicObjectMaterial(CreateDynamicObject(18762, 1941.57727, -1770.30188, 10.32300,   0.0, 0.0, 0.0,-1,-1,-1,400.0,400.0), 0, 1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Concrete bei den Zapfsäulen
    SetDynamicObjectMaterial(CreateDynamicObject(18766, 1944.15894, -1778.62500, 17.53240,   90.0, 0.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Zapfsäulen Dach
    SetDynamicObjectMaterial(CreateDynamicObject(18766, 1944.15894, -1768.64087, 17.53240,   90.0, 0.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Zapfsäulen Dach
    SetDynamicObjectMaterial(CreateDynamicObject(18766, 1939.16479, -1778.62500, 17.53240,   90.0, 0.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Zapfsäulen Dach
    SetDynamicObjectMaterial(CreateDynamicObject(18766, 1939.16479, -1768.64087, 17.53240,   90.0, 0.0, 90.0,-1,-1,-1,400.0,400.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Concrete Zapfsäulen Dach
    CreateDynamicObject(19325, 1928.30920, -1770.01794, 14.65770,   0.0, 0.0, 0.0,-1,-1,-1,140.0,140.0); // Fenster
    CreateDynamicObject(19325, 1928.30920, -1783.23047, 14.65770,   0.0, 0.0, 0.0,-1,-1,-1,140.0,140.0); // Fenster
    CreateDynamicObject(19325, 1923.64478, -1766.10181, 14.65770,   0.0, 0.0, 90.0,-1,-1,-1,140.0,140.0); // Fenster
    CreateDynamicObject(19325, 1923.82971, -1787.24353, 14.65770,   0.0, 0.0, 270.0,-1,-1,-1,140.0,140.0); // Fenster
    CreateDynamicObject(19325, 1917.44983, -1787.24353, 14.65770,   0.0, 0.0, 270.0,-1,-1,-1,140.0,140.0); // Fenster
    CreateDynamicObject(19325, 1913.66248, -1783.23047, 14.65770,   0.0, 0.0, 0.0,-1,-1,-1,140.0,140.0); // Fenster
    SetDynamicObjectMaterial(CreateDynamicObject(19428, 1917.79211, -1784.57178, 16.51710,   90.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Mauern im Shop
    SetDynamicObjectMaterial(CreateDynamicObject(19428, 1917.79211, -1781.09656, 16.51710,   90.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Mauern im Shop
    SetDynamicObjectMaterial(CreateDynamicObject(19428, 1917.79211, -1777.59937, 16.51710,   90.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Mauern im Shop
    SetDynamicObjectMaterial(CreateDynamicObject(19428, 1917.79211, -1774.11353, 16.51710,   90.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Mauern im Shop
    SetDynamicObjectMaterial(CreateDynamicObject(19428, 1917.79211, -1770.62976, 16.51710,   90.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Mauern im Shop
    SetDynamicObjectMaterial(CreateDynamicObject(19428, 1917.79504, -1768.39746, 16.51710,   90.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 8399, "vgs_shops", "vgsclubwall05_128", 0xFFFFFFFF); // Mauern im Shop
    CreateDynamicObject(1523, 1917.84534, -1777.43042, 12.55730,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0); // Tür zum Büro
    CreateDynamicObject(1523, 1916.94922, -1777.45581, 12.55730,   0.0, 0.0, 180.0,-1,-1,-1,50.0,50.0); // Tür
    CreateDynamicObject(1506, 1915.41956, -1775.01062, 12.53740,   0.0, 0.0, 114.84000,-1,-1,-1,50.0,50.0); // Tür später bewegen lassen
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1916.11316, -1776.66565, 12.48920,   0.0, 90.0, 0.0,-1,-1,-1,50.0,50.0),0, 5772, "stationtunnel", "mp_apt1_bathfloor1", 0xFFFFFFFF); // Boden '' Büro ''
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1916.11316, -1773.46326, 12.48920,   0.0, 90.0, 0.0,-1,-1,-1,50.0,50.0),0, 5772, "stationtunnel", "mp_apt1_bathfloor1", 0xFFFFFFFF); // Boden '' Büro ''
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1916.11316, -1770.26050, 12.48920,   0.0, 90.0, 0.0,-1,-1,-1,50.0,50.0),0, 5772, "stationtunnel", "mp_apt1_bathfloor1", 0xFFFFFFFF); // Boden '' Büro ''
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1916.11316, -1767.68030, 12.48520,   0.0, 90.0, 0.0,-1,-1,-1,50.0,50.0),0, 5772, "stationtunnel", "mp_apt1_bathfloor1", 0xFFFFFFFF); // Boden '' Büro ''
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1916.11316, -1779.86072, 12.48920,   0.0, 90.0, 0.0,-1,-1,-1,50.0,50.0),0, 5772, "stationtunnel", "mp_apt1_bathfloor1", 0xFFFFFFFF); // Boden '' Büro ''
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1916.11316, -1783.05945, 12.48920,   0.0, 90.0, 0.0,-1,-1,-1,50.0,50.0),0, 5772, "stationtunnel", "mp_apt1_bathfloor1", 0xFFFFFFFF); // Boden '' Büro ''
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1916.11316, -1785.65857, 12.48520,   0.0, 90.0, 0.0,-1,-1,-1,50.0,50.0),0, 5772, "stationtunnel", "mp_apt1_bathfloor1", 0xFFFFFFFF); // Boden '' Büro ''
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1915.41272, -1771.71252, 12.33390,   0.0, 90.0, 0.0,-1,-1,-1,50.0,50.0),0, 5772, "stationtunnel", "mp_apt1_bathfloor1", 0xFFFFFFFF); // Boden '' Büro ''
    SetDynamicObjectMaterial(CreateDynamicObject(19360, 1915.41272, -1768.52136, 12.33390,   0.0, 90.0, 0.0,-1,-1,-1,50.0,50.0),0, 5772, "stationtunnel", "mp_apt1_bathfloor1", 0xFFFFFFFF); // Boden '' Büro ''
    SetDynamicObjectMaterial(CreateDynamicObject(19362, 1914.44800, -1768.62219, 10.82320,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0),0, 5772, "stationtunnel", "mp_apt1_bathfloor1", 0xFFFFFFFF); // Boden '' Büro ''
    SetDynamicObjectMaterial(CreateDynamicObject(19362, 1914.44800, -1771.83020, 10.82320,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0),0, 5772, "stationtunnel", "mp_apt1_bathfloor1", 0xFFFFFFFF); // Boden '' Büro ''
    SetDynamicObjectMaterial(CreateDynamicObject(19387, 1916.19885, -1774.98572, 14.29140,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19357, 1917.78223, -1773.46741, 14.29140,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19357, 1917.78223, -1770.25745, 14.29140,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19357, 1917.78516, -1767.97925, 14.29140,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19387, 1917.78223, -1776.67407, 14.29140,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19430, 1917.78223, -1779.06152, 14.29140,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19357, 1916.19885, -1779.78516, 14.29140,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19387, 1916.19678, -1777.50012, 14.29140,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19357, 1914.51758, -1778.22095, 14.29140,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19357, 1914.51758, -1775.03113, 14.29140,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19357, 1914.51794, -1772.72412, 14.29140,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19357, 1916.18262, -1766.98145, 14.29140,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0), 0, 10932, "station_sfse", "ws_stationfloor", 0xFFFFFFFF); // Mauer Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19429, 1916.04504, -1779.05615, 12.49220,   0.0, 90.0, 0.0,-1,-1,-1,20.0,20.0), 0, 5815, "lawngrnd", "man_cellarfloor128", 0xFFFFFFFF); // Boden Toilette
    SetDynamicObjectMaterial(CreateDynamicObject(19429, 1916.04504, -1778.26086, 12.49620,   0.0, 90.0, 0.0,-1,-1,-1,20.0,20.0), 0, 5815, "lawngrnd", "man_cellarfloor128", 0xFFFFFFFF); // Boden Toilette
    SetDynamicObjectMaterial(CreateDynamicObject(19370, 1916.11316, -1778.24561, 15.96360,   0.0, 90.0, 0.0,-1,-1,-1,20.0,20.0), 0, 5461, "glenpark6d_lae", "man_cellarfloor128", 0xFFFFFFFF); // Dach Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19370, 1916.11316, -1775.04822, 15.96360,   0.0, 90.0, 0.0,-1,-1,-1,20.0,20.0), 0, 5461, "glenpark6d_lae", "man_cellarfloor128", 0xFFFFFFFF); // Dach Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19370, 1916.11316, -1771.84814, 15.96360,   0.0, 90.0, 0.0,-1,-1,-1,20.0,20.0), 0, 5461, "glenpark6d_lae", "man_cellarfloor128", 0xFFFFFFFF); // Dach Büro
    SetDynamicObjectMaterial(CreateDynamicObject(19370, 1916.11316, -1768.64355, 15.96360,   0.0, 90.0, 0.0,-1,-1,-1,20.0,20.0), 0, 5461, "glenpark6d_lae", "man_cellarfloor128", 0xFFFFFFFF); // Dach Büro
    CreateDynamicObject(5302, 1913.65735, -1769.08069, 14.30610,   0.0, 0.0, 0.0); // Garagentor Später bewegen lassen
    SetDynamicObjectMaterial(CreateDynamicObject(1676, 1941.59021, -1777.89355, 14.25450,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0),1,1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Zapfsäulen
    SetDynamicObjectMaterial(CreateDynamicObject(1676, 1941.59021, -1769.29187, 14.25450,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0),1,1676, "wshxrefpump", "black64", 0xFFFFFFFF); // Zapfsäulen
    // Boden / Straßenbezeichnungen Tankstelle
    SetDynamicObjectMaterialText(CreateDynamicObject(19353, 1933.3037, -1771.3005, 12.3110, 0.0, -90.0, -88.4253),0,"è",100,"Webdings",255,0,0xFFFFFFFF,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(19353, 1933.3433, -1773.5294, 12.3063, 0.0, -90.0, -90.2878),0,"Kundenparkplatz",140,"Arial",50,1,0xFFFFFFFF,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(19353, 1933.3005, -1778.1109, 12.3103, 0.0, -90.0, -89.5596),0,"è",100,"Webdings",255,0,0xFFFFFFFF,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(19353, 1933.3889, -1780.2275, 12.3088, 0.0, -90.0, -90.3083),0,"Kundenparkplatz",140,"Arial",50,1,0xFFFFFFFF,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(19353, 1933.3348, -1784.9746, 12.3060, 0.0, -90.0, -89.5784),0,"è",100,"Webdings",255,0,0xFFFFFFFF,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(19353, 1933.4359, -1787.1375, 12.3102, 0.0, -90.0, -89.7006),0,"Kundenparkplatz",140,"Arial",50,1,0xFFFFFFFF,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(19329, 1917.8814, -1776.6209, 15.5051, 0.0000, 0.0000, 89.9350),0,"\n\n\nKunden WC",90,"Arial",30,0,0xFF000000,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(11710, 1917.8243, -1777.2864, 15.2251, 0.0000, 0.0000, -90.6017),0,"\nƒ",100,"Webdings",130,0,0xFF000000,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(11710, 1917.8298, -1775.9776, 15.2351, 0.0000, 0.0000, 92.8182),0,"\n€",100,"Webdings",130,0,0xFF000000,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(19353, 1925.5650, -1766.1588, 16.8428, 0.0000, 0.0000, 90.2257),0,"Expert Gas",140,"Comic Sans MS",120,1,0xFFFFFFFF,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(19353, 1927.7054, -1766.1210, 16.8028, 0.0000, -0.1000, 90.1279),0,"///",140,"Comic Sans MS",120,1,0xFFFFFFFF,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(19353, 1928.2727, -1776.2196, 16.8828, 0.0000, 0.0000, 0.1738),0,"Expert Gas",140,"Comic Sans MS",120,1,0xFFFFFFFF,0,1);
    SetDynamicObjectMaterialText(CreateDynamicObject(19353, 1928.2647, -1778.3273, 16.8506, 0.0000, 0.0000, -0.1083),0,"///",140,"Comic Sans MS",120,1,0xFFFFFFFF,0,1);
   
    CreateDynamicObject(8843, 1944.39734, -1773.49512, 12.38870,   0.0, 0.0, 180.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(8843, 1938.55737, -1773.60864, 12.38870,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(8843, 1911.26318, -1771.12158, 12.39820,   0.0, 0.0, 180.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1933.27356, -1767.33594, 10.63420,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1933.27356, -1787.38318, 10.63420,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1925.58215, -1795.78088, 10.63420,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1919.48132, -1795.78088, 10.63420,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1913.93481, -1796.94824, 10.63420,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1951.58508, -1785.79321, 10.63550,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1951.58508, -1782.60120, 10.63550,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1946.84814, -1792.23071, 10.63550,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1946.68823, -1787.30518, 10.63550,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1937.24377, -1792.23071, 10.63550,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1931.70325, -1793.74121, 10.63420,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1931.70325, -1796.94019, 10.63420,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19426, 1932.41443, -1792.23071, 10.63250,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1926.83801, -1797.22937, 10.64350,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1918.67053, -1797.22937, 10.63750,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19426, 1942.27612, -1787.30518, 10.63250,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1931.73938, -1782.54956, 10.63350,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1931.73938, -1772.92078, 10.63350,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19426, 1941.54626, -1786.57874, 10.63550,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19426, 1941.54626, -1784.41284, 10.63550,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19426, 1941.54626, -1782.23523, 10.63550,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1909.20569, -1792.24707, 10.63250,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1913.93481, -1793.76331, 10.63420,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1908.90552, -1787.46960, 10.63250,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1908.90552, -1777.83691, 10.63250,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1908.90552, -1768.23254, 10.63250,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19426, 1908.90552, -1762.94995, 10.63550,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1914.30029, -1763.85815, 10.63550,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19426, 1914.30029, -1766.25586, 10.63550,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19426, 1914.38916, -1765.99829, 10.63250,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1913.50293, -1770.72498, 10.63250,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1913.50293, -1780.34741, 10.63250,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1913.50293, -1785.86658, 10.63520,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1918.25232, -1787.37183, 10.63250,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1926.86487, -1787.38318, 10.63550,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1910.19946, -1762.20386, 10.63250,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1910.19946, -1762.04395, 10.63250,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1931.73938, -1766.50781, 10.63420,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1933.27356, -1773.75610, 10.63420,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1933.27356, -1780.47583, 10.63420,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1936.63989, -1763.90662, 10.63420,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1941.54626, -1763.90662, 10.63420,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1940.03308, -1762.38721, 10.63420,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1936.83057, -1762.38721, 10.63420,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1941.54626, -1767.07568, 10.63420,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1946.60669, -1767.13501, 10.63350,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19445, 1946.60669, -1776.76282, 10.63350,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1950.05286, -1782.24158, 10.63550,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19426, 1947.66333, -1782.24158, 10.63550,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19426, 1946.60669, -1781.51733, 10.63550,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19426, 1947.32312, -1782.24158, 10.63250,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1935.12988, -1767.33594, 10.63120,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(19353, 1936.63989, -1765.82446, 10.63120,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0);
    CreateDynamicObject(957, 1937.71570, -1763.98450, 17.03180,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0); // Licher draussen
    CreateDynamicObject(957, 1939.71570, -1763.98450, 17.03180,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0); // Licher draussen
    CreateDynamicObject(957, 1941.71570, -1763.98450, 17.03180,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0); // Licher draussen
    CreateDynamicObject(957, 1943.71570, -1763.98450, 17.03180,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0); // Licher draussen
    CreateDynamicObject(957, 1945.71570, -1763.98450, 17.03180,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0); // Licher draussen
    CreateDynamicObject(957, 1945.71570, -1783.07739, 17.03180,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0); // Licher draussen
    CreateDynamicObject(957, 1943.71570, -1783.07739, 17.03180,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0); // Licher draussen
    CreateDynamicObject(957, 1941.71570, -1783.07739, 17.03180,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0); // Licher draussen
    CreateDynamicObject(957, 1939.71570, -1783.07739, 17.03180,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0); // Licher draussen
    CreateDynamicObject(957, 1937.71570, -1783.07739, 17.03180,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0); // Licher draussen
   
    // Objekte im Shop und Büro
    objekt = CreateDynamicObject(2737, 1914.64758, -1778.40796, 14.42510,   0.0, 0.0, 90.0,-1,-1,-1,20.0,20.0); // Objekt zum Texturieren
    SetDynamicObjectMaterial(objekt, 0,1676, "wshxrefpump", "black64", 0xFFFFFFFF);
    SetDynamicObjectMaterial(objekt, 1, 2520, "cj_bathroom" , "CJ_FRAME_Glass", 0xFFFFFFFF);
    CreateDynamicObject(1744, 1917.83264, -1773.09583, 13.65670,   0.0, 0.0, 270.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1744, 1917.83264, -1773.41577, 14.45670,   0.0, 0.0, 270.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1744, 1915.10840, -1779.70142, 13.65670,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1744, 1915.10840, -1779.70142, 14.60954,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(2855, 1917.51611, -1774.14465, 13.95616,   0.0, 0.0, 1.98000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(2855, 1917.51611, -1774.14465, 14.13565,   0.0, 0.0, 1.98000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(2855, 1916.23877, -1780.07422, 13.99426,   0.0, 0.0, 95.88000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1917.47302, -1773.32715, 14.33420,   0.0, 0.0, 55.98000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1917.47546, -1773.63354, 14.33420,   0.0, 0.0, 55.98000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1917.49695, -1773.08386, 15.10367,   0.0, 0.0, 55.97999,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1917.49170, -1773.38269, 15.10370,   0.0, 0.0, 55.98000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1927.94556, -1768.24097, 13.25104,   0.0, 0.0, -36.48000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1927.55457, -1768.83215, 13.25104,   0.0, 0.0, -36.48000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1927.96863, -1769.44153, 13.25104,   0.0, 0.0, -36.48000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1927.51343, -1769.87415, 13.25104,   0.0, 0.0, -36.48000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1927.97449, -1770.57239, 13.25104,   0.0, 0.0, -36.48000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1928.09680, -1784.31519, 13.16330,   0.0, 0.0, -51.66000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1927.71619, -1784.83655, 13.16330,   0.0, 0.0, -51.66000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1928.09192, -1780.72278, 13.16330,   0.0, 0.0, -51.66000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1927.72681, -1781.29382, 13.16330,   0.0, 0.0, -51.66000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1928.11987, -1781.90112, 13.16330,   0.0, 0.0, -51.66000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1927.74390, -1782.44373, 13.16330,   0.0, 0.0, -51.66000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1915.86694, -1780.05054, 15.24247,   0.0, 0.0, -27.18000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1919.61243, -1786.60144, 13.19178,   0.0, 0.0, -44.94000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1919.20020, -1786.60144, 13.19180,   0.0, 0.0, -44.94000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1917.51233, -1774.63562, 15.10370,   0.0, 0.0, 55.98000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1917.49805, -1774.43213, 15.10370,   0.0, 0.0, 55.98000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1916.62305, -1767.34521, 15.13657,   0.0, 0.0, -41.52000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1916.90894, -1767.33447, 15.13657,   0.0, 0.0, -41.52000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1918.82410, -1786.60144, 13.19180,   0.0, 0.0, -44.94000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1916.28772, -1780.04822, 15.24247,   0.0, 0.0, -27.18000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1915.46692, -1780.05225, 15.24247,   0.0, 0.0, -27.18000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1650, 1928.09766, -1785.38232, 13.16330,   0.0, 0.0, -51.66000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1928.12268, -1783.26343, 12.99252,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1927.91650, -1783.42236, 12.99252,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1927.72839, -1783.55994, 12.99252,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1927.56030, -1783.69580, 12.99252,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1914.80212, -1780.00757, 14.09020,   0.0, 0.0, 64.56000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1915.10278, -1780.00366, 14.09020,   0.0, 0.0, 64.56000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1915.40332, -1779.99988, 14.09020,   0.0, 0.0, 64.56000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1919.67944, -1786.96997, 12.97441,   0.0, 0.0, 40.20000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1919.31616, -1786.96997, 12.97440,   0.0, 0.0, 40.20000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1918.93738, -1786.96997, 12.97440,   0.0, 0.0, 40.20000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1918.53613, -1786.96997, 12.97440,   0.0, 0.0, 40.20000,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1927.54749, -1772.59351, 12.99252,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1927.76563, -1772.39380, 12.99252,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1928.00928, -1772.18213, 12.99252,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1927.82300, -1771.92615, 12.99252,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1927.56592, -1771.75183, 12.99252,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1927.75269, -1771.52039, 12.99252,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(19621, 1927.97058, -1771.32080, 12.99252,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(2248, 1927.81555, -1785.92407, 13.32750,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(2249, 1927.71558, -1785.92407, 14.00730,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(2248, 1927.84045, -1767.48425, 13.32750,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(2249, 1927.76062, -1767.49280, 14.02506,   0.0, 0.0, 0.0,-1,-1,-1,25.0,25.0);
    CreateDynamicObject(1893, 1915.54382, -1778.68774, 15.99020,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1915.50623, -1776.82837, 15.99020,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1917.00562, -1776.82837, 15.99020,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1915.49133, -1768.33813, 15.99020,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1915.49133, -1771.25488, 15.99020,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1915.49133, -1774.08765, 15.99020,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1923.71716, -1784.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1923.71716, -1781.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1923.71716, -1778.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1923.71716, -1775.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1923.71716, -1772.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1923.71716, -1769.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1918.71716, -1784.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1918.71716, -1781.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1918.71716, -1778.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1918.71716, -1775.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1918.71716, -1772.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1918.71716, -1769.35425, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1915.68542, -1780.67444, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1893, 1915.68542, -1784.98816, 17.12200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2475, 1916.54224, -1767.07910, 13.30130,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2365, 1916.94153, -1767.21558, 12.55874,   0.0, 0.0, 38.34,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2365, 1916.33533, -1767.30969, 12.55874,   0.0, 0.0, 38.34,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19618, 1915.37427, -1767.31226, 13.94360,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19618, 1915.37427, -1767.31226, 13.02886,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19619, 1914.94714, -1767.55005, 13.94360,   0.0, 0.0, 0.0,-1,-1,-1,30.0,30.0); // Safe Tür
    CreateDynamicObject(19619, 1914.94714, -1767.55005, 13.02890,   0.0, 0.0, 0.0,-1,-1,-1,30.0,30.0); // Safe Tür
    CreateDynamicObject(2005, 1915.37427, -1767.23218, 13.94360,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2495, 1917.70825, -1768.35168, 14.06890,   0.0, 0.0, 270.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2495, 1917.70825, -1768.35168, 14.84320,   0.0, 0.0, 270.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2495, 1917.70825, -1768.35168, 14.46780,   0.0, 0.0, 270.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2369, 1916.13831, -1767.52991, 13.43200,   0.0, 0.0, -179.94000,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2369, 1917.02649, -1767.52991, 13.43200,   0.0, 0.0, -179.94000,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19996, 1914.94775, -1771.51282, 12.57728,   0.0, 0.0, -272.45999,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19172, 1914.60962, -1772.55347, 14.72610,   0.0, 0.0, 90.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(1221, 1917.23071, -1771.20483, 13.05619,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(1221, 1917.27075, -1770.18640, 13.05619,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(1221, 1917.22156, -1769.18079, 13.05619,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(1221, 1917.21838, -1769.66113, 13.96230,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(1221, 1917.18958, -1770.68250, 13.96230,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2480, 1917.49805, -1772.51050, 13.18240,   0.0, 0.0, -84.3,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(11706, 1916.99963, -1768.17810, 12.49513,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(11705, 1917.47107, -1772.84827, 13.98367,   0.0, 0.0, -366.41998,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(11712, 1915.39063, -1767.09827, 15.12260,   0.0, 0.0, 90.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19996, 1914.88647, -1772.27661, 12.57728,   0.0, 0.0, -241.74,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19814, 1914.61584, -1773.04700, 12.99480,   0.0, 0.0, 90.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19814, 1917.14307, -1774.89624, 12.99480,   0.0, 0.0, 180.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2738, 1917.29077, -1779.23816, 13.18360,   0.0, 0.0, -90.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2524, 1915.10071, -1779.07898, 12.52410,   0.0, 0.0, 90.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2742, 1914.71741, -1779.23315, 13.64417,   0.0, 0.0, 90.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2741, 1914.66345, -1778.08569, 13.60420,   0.0, 0.0, 90.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(1778, 1914.97388, -1777.23584, 12.58850,   0.0, 0.0, 241.2,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(1778, 1914.91724, -1776.79761, 12.58850,   0.0, 0.0, 241.2,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2609, 1917.47229, -1773.55542, 12.59700,   0.0, 0.0, 270.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2609, 1917.47229, -1774.00610, 12.59700,   0.0, 0.0, 270.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2613, 1915.10156, -1778.64270, 12.51195,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19827, 1915.33105, -1777.58655, 13.91802,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19827, 1917.05969, -1774.90222, 14.00710,   0.0, 0.0, 180.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19873, 1917.56982, -1777.73584, 12.64390,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19873, 1917.44067, -1777.69946, 12.64390,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19873, 1917.61829, -1777.86060, 12.64390,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19873, 1917.46106, -1777.82581, 12.64390,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19873, 1917.50000, -1777.75330, 12.75139,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19873, 1917.58887, -1777.83386, 12.75139,   0.0, 0.0, 0.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19825, 1914.64868, -1776.34302, 14.44371,   0.0, 0.0, 90.0,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19874, 1914.66394, -1778.00696, 13.95675,   0.0, 0.0, -99.53999,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19874, 1914.66699, -1779.05579, 13.95675,   0.0, 0.0, -99.53999,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(1808, 1914.92944, -1775.33350, 12.54045,   0.0, 0.0, 61.98000,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19622, 1914.74634, -1776.15332, 13.27687,   -9.60000, 1.56000, 87.71999,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(19622, 1914.71667, -1775.81189, 13.27687,   -9.60000, 1.56000, 87.71999,-1,-1,-1,20.0,20.0);
    CreateDynamicObject(2412, 1927.60950, -1774.85913, 12.57580,   0.0, 0.0, 90.0,-1,-1,-1,80.0,80.0);
    CreateDynamicObject(2412, 1927.60950, -1777.77539, 12.57580,   0.0, 0.0, 90.0,-1,-1,-1,80.0,80.0);
    CreateDynamicObject(2412, 1927.60950, -1776.41919, 12.57580,   0.0, 0.0, 90.0,-1,-1,-1,80.0,80.0);
    CreateDynamicObject(2412, 1927.60950, -1776.21545, 12.57580,   0.0, 0.0, 90.0,-1,-1,-1,80.0,80.0);
    CreateDynamicObject(2365, 1927.34167, -1774.21362, 12.55330,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2443, 1920.38965, -1766.79932, 12.54410,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19441, 1919.78564, -1766.98022, 13.11610,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19441, 1920.03052, -1766.98425, 13.11610,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2443, 1919.45862, -1766.79932, 12.54410,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1996, 1920.36072, -1770.95325, 12.43050,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1981, 1920.36072, -1771.94775, 12.43050,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1991, 1920.36072, -1772.94299, 12.43050,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1983, 1920.26135, -1774.08423, 12.56850,   0.0, 0.0, 270.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1983, 1920.25745, -1774.44922, 12.56450,   0.0, 0.0, 270.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1513, 1926.61426, -1767.22083, 12.85980,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1513, 1927.08972, -1767.22083, 12.85980,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1994, 1921.27783, -1774.46228, 12.40537,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1993, 1922.27563, -1774.46228, 12.40540,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1995, 1923.25684, -1774.46228, 12.40540,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2545, 1918.32312, -1767.63379, 12.49980,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2545, 1918.32312, -1768.50854, 12.49980,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2545, 1918.32312, -1769.36865, 12.49980,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2540, 1925.32263, -1774.42664, 12.43050,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2539, 1925.32263, -1773.45410, 12.43050,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2539, 1925.32263, -1772.47778, 12.43050,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2547, 1925.32263, -1771.49304, 12.43050,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2543, 1924.28125, -1774.64856, 12.53594,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2534, 1925.30396, -1770.43848, 12.54410,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2534, 1925.30396, -1769.45593, 12.54410,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2365, 1927.34167, -1774.21362, 12.95411,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19326, 1917.88135, -1774.82996, 13.87160,   0.0, -30.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19327, 1917.88330, -1772.15234, 15.06190,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2541, 1920.29663, -1769.93689, 12.48462,   0.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1847, 1924.24463, -1771.39600, 12.57000,   0.0, 0.0, 270.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2435, 1917.50989, -1782.17004, 12.48490,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2435, 1917.50586, -1783.00024, 12.48890,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2435, 1917.50586, -1781.31128, 12.48890,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2433, 1917.43799, -1784.95068, 12.56920,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2435, 1917.50586, -1785.85950, 12.48890,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2369, 1917.14001, -1780.97522, 13.42560,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2369, 1917.14001, -1782.95752, 13.42560,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2365, 1918.43274, -1779.30872, 12.55330,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2427, 1920.44995, -1786.39941, 13.52320,   0.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2366, 1920.22754, -1784.58020, 12.53197,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2366, 1920.22754, -1781.88159, 12.53200,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2422, 1917.17688, -1781.73254, 13.54350,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2422, 1917.17688, -1782.15161, 13.54350,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1847, 1925.31641, -1780.89014, 12.57000,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1991, 1924.25354, -1778.85779, 12.43050,   0.0, 0.0, 270.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1981, 1924.25354, -1779.84180, 12.43050,   0.0, 0.0, 270.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1996, 1924.25354, -1780.82178, 12.43050,   0.0, 0.0, 270.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2533, 1924.25806, -1781.82397, 12.53050,   0.0, 0.0, 270.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2533, 1924.25806, -1782.82397, 12.53050,   0.0, 0.0, 270.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2453, 1917.49536, -1785.88391, 13.92199,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(2342, 1920.51379, -1784.24548, 13.90337,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19835, 1920.83496, -1781.43909, 13.91030,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19835, 1920.82825, -1784.01746, 13.91030,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19824, 1920.96790, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19824, 1921.10791, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19824, 1921.24792, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19822, 1921.38794, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19822, 1921.52795, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19822, 1921.66797, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19821, 1921.82800, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19821, 1921.98816, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19821, 1922.14807, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19821, 1922.30811, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19820, 1922.46814, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19820, 1922.62805, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19820, 1922.78809, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19820, 1922.94812, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19823, 1923.14819, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19823, 1923.32813, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19823, 1923.50818, -1774.81079, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19823, 1923.14819, -1774.45081, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19823, 1923.32825, -1774.45081, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19823, 1923.50818, -1774.45081, 13.28660,   90.0, 0.0, 180.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(11722, 1918.28394, -1769.66565, 13.72570,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(11722, 1918.44385, -1769.66565, 13.72570,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(11722, 1918.44385, -1769.50562, 13.72570,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(11722, 1918.44385, -1769.34558, 13.72570,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(11722, 1918.44385, -1769.18555, 13.72570,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(11722, 1918.44385, -1769.02551, 13.72570,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(11723, 1918.44385, -1768.76550, 13.72570,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(11723, 1918.44385, -1768.60547, 13.72570,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(11723, 1918.44385, -1768.44556, 13.72570,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(11723, 1918.44385, -1768.28552, 13.72570,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(11723, 1918.44385, -1768.12549, 13.72570,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19897, 1918.40857, -1767.92749, 13.23251,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19897, 1918.42651, -1767.84949, 13.23251,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19897, 1918.44458, -1767.77136, 13.23251,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19897, 1918.44751, -1767.66931, 13.23251,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19897, 1918.40686, -1767.57800, 13.23251,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19897, 1918.44885, -1767.48499, 13.23251,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19897, 1918.45166, -1767.38306, 13.23251,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19897, 1918.32849, -1767.29309, 13.23251,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19897, 1918.43469, -1767.27637, 13.23251,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19896, 1918.34460, -1767.39941, 13.23250,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19896, 1918.36572, -1767.48645, 13.23250,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19896, 1918.31030, -1767.63794, 13.23250,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19896, 1918.35083, -1767.72937, 13.23250,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19896, 1918.33313, -1767.80713, 13.23250,   0.0, 0.0, -98.70000,-1,-1,-1,15.0,15.0);
    CreateDynamicObject(19640, 1921.41321, -1779.30078, 12.56980,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19640, 1920.40771, -1779.30078, 12.56980,   0.0, 0.0, 270.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19563, 1921.15625, -1780.05652, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19563, 1921.29626, -1780.05652, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19563, 1921.43628, -1780.05652, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19563, 1921.55627, -1780.05652, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19563, 1921.69629, -1780.05652, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19563, 1921.69629, -1779.79651, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19563, 1921.55627, -1779.79651, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19564, 1921.69629, -1779.45654, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19564, 1921.55627, -1779.45654, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19564, 1921.41626, -1779.45654, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19564, 1921.41626, -1779.25647, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19564, 1921.55627, -1779.25647, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19564, 1921.69629, -1779.25647, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19564, 1921.69629, -1779.05652, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19569, 1921.69629, -1778.75647, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19569, 1921.69629, -1778.57654, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19569, 1921.49634, -1778.57654, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19569, 1921.29626, -1778.57654, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19569, 1921.49634, -1778.75647, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19569, 1921.29626, -1778.75647, 13.23100,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19637, 1920.31885, -1778.90906, 13.13530,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19638, 1920.31885, -1779.72717, 13.13530,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    SetDynamicObjectMaterial(CreateDynamicObject(19327, 1914.53369, -1783.11353, 15.12157,   0.0, 0.0, 90.0,-1,-1,-1,50.0,50.0),0,3924, "rc_warhoose", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(19087, 1914.53125, -1784.28064, 16.95870,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0),0,1676, "wshxrefpump", "black64", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(19087, 1914.53125, -1781.96179, 16.95870,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0),0,1676, "wshxrefpump", "black64", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(19327, 1914.51367, -1783.11353, 15.12160,   0.0, 0.0, 270.0,-1,-1,-1,50.0,50.0),0,3924, "rc_warhoose", "white", 0xFFFFFFFF);
    CreateDynamicObject(638, 1914.19263, -1784.59204, 13.20610,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(638, 1914.19263, -1781.92957, 13.20610,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(19835, 1920.55786, -1781.70276, 13.91030,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    SetDynamicObjectMaterial(CreateDynamicObject(19449, 1951.62280, -1773.47229, 12.93970,   0.0, 90.0, 0.0,-1,-1,-1,100.0,100.0), 0, 8678, "wddngchplgrnd01", "Grass", 0xFFFFFFFF); // Gras
    SetDynamicObjectMaterial(CreateDynamicObject(19449, 1951.62280, -1766.09778, 12.93567,   0.0, 90.0, 0.0,-1,-1,-1,100.0,100.0), 0, 8678, "wddngchplgrnd01", "Grass", 0xFFFFFFFF); // Gras
    SetDynamicObjectMaterial(CreateDynamicObject(19448, 1953.30396, -1766.10144, 11.26130,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 18202, "w_towncs_t", "concretebig4256128", 0xFFFFFFFF); // Mauer Gras
    SetDynamicObjectMaterial(CreateDynamicObject(19448, 1953.30078, -1773.48328, 11.26130,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 18202, "w_towncs_t", "concretebig4256128", 0xFFFFFFFF); // Mauer Gras
    SetDynamicObjectMaterial(CreateDynamicObject(19448, 1949.94995, -1773.45288, 11.26130,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 18202, "w_towncs_t", "concretebig4256128", 0xFFFFFFFF); // Mauer Gras
    SetDynamicObjectMaterial(CreateDynamicObject(19448, 1949.94604, -1766.09485, 11.26130,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 18202, "w_towncs_t", "concretebig4256128", 0xFFFFFFFF); // Mauer Gras
    SetDynamicObjectMaterial(CreateDynamicObject(19448, 1951.62671, -1761.36206, 8.18580,   90.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 18202, "w_towncs_t", "concretebig4256128", 0xFFFFFFFF); // Mauer Gras
    SetDynamicObjectMaterial(CreateDynamicObject(19448, 1951.61609, -1778.20532, 8.18580,   90.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 18202, "w_towncs_t", "concretebig4256128", 0xFFFFFFFF); // Mauer Gras
    CreateDynamicObject(895, 1952.17175, -1769.41565, 12.78634,   0.0, 0.0, 27.18000,-1,-1,-1,150.0,150.0); // Bäume
    CreateDynamicObject(895, 1952.04590, -1775.72119, 12.78634,   0.0, 0.0, 27.18000,-1,-1,-1,150.0,150.0); // Bäume
    CreateDynamicObject(895, 1951.16309, -1765.77100, 12.78634,   0.0, 0.0, 27.18000,-1,-1,-1,150.0,150.0); // Bäume
    CreateDynamicObject(895, 1951.96155, -1772.73218, 12.78634,   0.0, 0.0, 27.18000,-1,-1,-1,150.0,150.0); // Bäume
    CreateDynamicObject(905, 1952.65540, -1776.67175, 13.52325,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(905, 1950.86877, -1774.42810, 13.52325,   0.0, 0.0, 27.18000,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(905, 1951.39026, -1772.80078, 13.52325,   0.0, 0.0, 27.18000,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(871, 1952.09680, -1773.81592, 13.36589,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(871, 1951.78467, -1771.75244, 13.36589,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(871, 1951.16956, -1769.69189, 13.36589,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(905, 1952.57178, -1770.45508, 13.52325,   0.0, 0.0, 27.18000,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(871, 1951.64734, -1775.96106, 13.36589,   0.0, 0.0, -22.98000,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(905, 1950.65051, -1767.81897, 13.52325,   0.0, 0.0, 27.18000,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(905, 1953.04834, -1766.42542, 13.52325,   0.0, 0.0, 27.18000,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(871, 1952.18567, -1767.50342, 13.36589,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(871, 1951.44788, -1766.16211, 13.36589,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(871, 1952.14087, -1764.73254, 13.36589,   0.0, 0.0, 0.0,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1886, 1918.49146, -1785.82458, 17.14590,   21.78000, 1.98000, 128.34000,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1886, 1927.03320, -1785.73401, 17.26011,   17.16000, 0.0, 196.44000,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1886, 1926.88855, -1767.52771, 17.17015,   21.48000, -7.26000, -56.22001,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1886, 1918.29871, -1767.58020, 17.19663,   21.90000, -1.62000, 34.38000,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1886, 1917.30212, -1774.42480, 15.93127,   19.08000, 1.62000, -147.84000,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1886, 1936.83728, -1783.31860, 17.19031,   21.36000, -6.48000, 171.95999,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1886, 1946.63757, -1763.74414, 17.24905,   20.34000, 3.42000, -19.14000,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1886, 1928.33655, -1786.99866, 17.32130,   3.90000, 22.56000, 175.3201,-1,-1,-1,50.0,50.0);
    CreateDynamicObject(1886, 1913.64001, -1787.16907, 17.33175,   -0.06000, -28.62000, -167.7,-1,-1,-1,50.0,50.0);
    // ---------> Verkehrsobjekte in Idlewood
    //     ---------> Zebrastreifen
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1806.88489, 12.30711,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1807.68494, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1808.48486, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1809.28491, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1810.08496, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1810.88501, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1811.68506, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1812.48511, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1813.28516, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1814.08521, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1814.88525, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1815.68530, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1816.48535, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1817.28540, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1969.29224, -1818.08545, 12.30710,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1792.61719, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1791.81726, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1791.01733, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1790.21729, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1789.41736, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1788.61743, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1787.81738, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1787.01746, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1786.21753, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1785.41748, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1784.61755, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1783.81763, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1783.01758, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1782.21765, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1781.41772, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1954.20642, -1793.41724, 12.30800,   0.0, 0.0, 0.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1908.40540, -1759.73193, 12.30890,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1909.20544, -1759.73193, 12.30890,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1910.00537, -1759.73193, 12.30890,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1910.80542, -1759.73193, 12.30890,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1911.60535, -1759.73193, 12.30890,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1912.40527, -1759.73193, 12.30890,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1913.20520, -1759.73193, 12.30890,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1914.02515, -1759.73193, 12.30890,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1914.84521, -1759.73193, 12.30890,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1947.26575, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1946.46570, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1945.66565, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1944.86560, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1944.06555, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1943.26563, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1942.46558, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1941.66565, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1940.86560, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1940.06555, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1939.26563, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1938.46558, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1937.66565, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1936.86560, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1936.06555, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1956.00781, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1956.80774, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1957.60767, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1958.40771, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1959.20764, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1960.00757, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1960.80762, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1961.60754, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1962.40747, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1963.20752, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1964.00745, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1964.80737, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1965.60742, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1966.40735, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1967.20728, -1759.72266, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1936.06555, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1936.86560, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1937.66565, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1938.46558, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1939.26563, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1940.06555, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1940.86560, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1941.66565, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1942.46558, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1943.26563, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1944.06555, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1944.86560, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1945.66565, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1946.46570, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    SetDynamicObjectMaterial(CreateDynamicObject(2960, 1947.26575, -1744.78503, 12.30580,   0.0, 0.0, 90.0,-1,-1,-1,100.0,100.0), 0, 11085, "crack_intkb", "white", 0xFFFFFFFF);
    
	//Die Map:
	
	new g_Object[859];
	//new g_Vehicle[2];
	g_Object[0] = CreateObject(19378, 1806.8204, -1717.0852, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[0], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[1] = CreateObject(19378, 1797.1905, -1717.0852, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[1], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[2] = CreateObject(19378, 1787.5710, -1717.0852, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[2], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[3] = CreateObject(19378, 1777.9511, -1717.0852, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[3], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[4] = CreateObject(19378, 1768.3304, -1717.0852, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[4], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[5] = CreateObject(19378, 1759.3695, -1717.0852, 12.4523, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[5], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[6] = CreateObject(19378, 1759.3695, -1706.6057, 12.4523, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[6], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[7] = CreateObject(19378, 1759.3695, -1696.1242, 12.4422, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[7], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[8] = CreateObject(19378, 1759.3695, -1687.5224, 12.4523, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[8], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[9] = CreateObject(19378, 1768.3304, -1706.5932, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[9], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[10] = CreateObject(19378, 1768.3304, -1696.1228, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[10], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[11] = CreateObject(19378, 1768.3304, -1685.6302, 12.4422, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[11], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[12] = CreateObject(19378, 1777.9504, -1685.6302, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[12], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[13] = CreateObject(19378, 1777.9511, -1706.6040, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[13], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[14] = CreateObject(19378, 1777.9511, -1696.1225, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[14], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[15] = CreateObject(19378, 1787.5710, -1706.6231, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[15], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[16] = CreateObject(19378, 1787.5710, -1696.1611, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[16], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[17] = CreateObject(19378, 1787.5710, -1685.6794, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[17], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[18] = CreateObject(19378, 1797.1905, -1706.6541, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[18], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[19] = CreateObject(19378, 1797.1905, -1696.1748, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[19], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[20] = CreateObject(19378, 1797.2004, -1685.7342, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[20], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[21] = CreateObject(19378, 1806.8204, -1706.6440, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[21], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[22] = CreateObject(19378, 1806.8204, -1696.1629, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[22], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[23] = CreateObject(19378, 1806.8304, -1685.9133, 12.4623, 0.0000, 90.0000, -90.0000); //wall026
	SetObjectMaterial(g_Object[23], 0, 9514, "711_sfw", "ws_carpark2", 0xFFFFFFFF);
	g_Object[24] = CreateObject(19459, 1763.1595, -1690.6148, 14.2669, 0.0000, 0.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[24], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[25] = CreateObject(19459, 1763.1595, -1690.6148, 17.7068, 0.0000, 0.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[25], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[26] = CreateObject(19459, 1767.8997, -1685.8851, 14.2669, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[26], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[27] = CreateObject(19459, 1777.4798, -1685.8851, 14.2669, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[27], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[28] = CreateObject(19459, 1791.8121, -1690.6148, 14.2669, 0.0000, 0.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[28], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[29] = CreateObject(19459, 1787.0808, -1685.8851, 14.2769, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[29], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[30] = CreateObject(19459, 1791.8121, -1690.6148, 17.7169, 0.0000, 0.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[30], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[31] = CreateObject(19459, 1787.0808, -1685.8851, 17.7369, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[31], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[32] = CreateObject(19459, 1777.4798, -1685.8851, 17.7369, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[32], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[33] = CreateObject(19459, 1767.9096, -1685.8851, 17.7369, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[33], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[34] = CreateObject(19459, 1767.9091, -1695.3371, 12.4069, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[34], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[35] = CreateObject(19459, 1777.4589, -1695.3371, 12.4069, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[35], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[36] = CreateObject(19459, 1782.2906, -1695.3371, 12.4069, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[36], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[37] = CreateObject(19459, 1767.8890, -1695.3471, 17.7070, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[37], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[38] = CreateObject(19459, 1777.4687, -1695.3471, 17.7069, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[38], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[39] = CreateObject(19459, 1787.0808, -1695.3471, 17.7069, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[39], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[40] = CreateObject(19459, 1789.9813, -1690.6148, 19.3670, 0.0000, -90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[40], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFBDBEC6);
	g_Object[41] = CreateObject(19459, 1786.4897, -1690.6148, 19.3670, 0.0000, -90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[41], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFBDBEC6);
	g_Object[42] = CreateObject(19459, 1783.0101, -1690.6148, 19.3670, 0.0000, -90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[42], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFBDBEC6);
	g_Object[43] = CreateObject(19459, 1779.5107, -1690.6148, 19.3670, 0.0000, -90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[43], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFBDBEC6);
	g_Object[44] = CreateObject(19459, 1776.0118, -1690.6148, 19.3670, 0.0000, -90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[44], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFBDBEC6);
	g_Object[45] = CreateObject(19459, 1772.5222, -1690.6148, 19.3670, 0.0000, -90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[45], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFBDBEC6);
	g_Object[46] = CreateObject(19459, 1769.0516, -1690.6148, 19.3670, 0.0000, -90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[46], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFBDBEC6);
	g_Object[47] = CreateObject(19459, 1764.9608, -1690.6148, 19.3670, 0.0000, -90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[47], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFBDBEC6);
	g_Object[48] = CreateObject(19459, 1766.7514, -1690.6148, 19.3670, 0.0000, -90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[48], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFBDBEC6);
	g_Object[49] = CreateObject(19329, 1763.0632, -1694.3770, 19.0237, 0.0000, 0.0000, -90.0000); //7_11_sign04
	SetObjectMaterial(g_Object[49], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[50] = CreateObject(19329, 1763.0632, -1692.2772, 19.0237, 0.0000, 0.0000, -90.0000); //7_11_sign04
	SetObjectMaterial(g_Object[50], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[51] = CreateObject(19329, 1763.0632, -1690.2071, 19.0237, 0.0000, 0.0000, -90.0000); //7_11_sign04
	SetObjectMaterial(g_Object[51], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[52] = CreateObject(19329, 1763.0632, -1688.1075, 19.0237, 0.0000, 0.0000, -90.0000); //7_11_sign04
	SetObjectMaterial(g_Object[52], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[53] = CreateObject(19329, 1763.0632, -1686.8568, 19.0237, 0.0000, 0.0000, -90.0000); //7_11_sign04
	SetObjectMaterial(g_Object[53], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[54] = CreateObject(19329, 1764.1335, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[54], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[55] = CreateObject(19329, 1766.2641, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[55], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[56] = CreateObject(19329, 1768.3747, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[56], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[57] = CreateObject(19329, 1770.4962, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[57], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[58] = CreateObject(19329, 1772.5964, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[58], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[59] = CreateObject(19329, 1774.7066, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[59], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[60] = CreateObject(19329, 1776.8177, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[60], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[61] = CreateObject(19329, 1778.9281, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[61], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[62] = CreateObject(19329, 1781.0190, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[62], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[63] = CreateObject(19329, 1783.1192, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[63], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[64] = CreateObject(19329, 1785.2296, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[64], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[65] = CreateObject(19329, 1787.3199, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[65], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[66] = CreateObject(19329, 1789.4403, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[66], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[67] = CreateObject(19329, 1790.8299, -1685.7956, 19.0438, 0.0000, 0.0000, 180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[67], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[68] = CreateObject(19329, 1791.9011, -1686.8464, 19.0438, 0.0000, 0.0000, -90.0000); //7_11_sign04
	SetObjectMaterial(g_Object[68], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[69] = CreateObject(19329, 1791.9011, -1688.9768, 19.0438, 0.0000, 0.0000, -90.0000); //7_11_sign04
	SetObjectMaterial(g_Object[69], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[70] = CreateObject(19329, 1791.9011, -1691.0866, 19.0438, 0.0000, 0.0000, -90.0000); //7_11_sign04
	SetObjectMaterial(g_Object[70], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[71] = CreateObject(19329, 1791.9011, -1693.1661, 19.0438, 0.0000, 0.0000, -90.0000); //7_11_sign04
	SetObjectMaterial(g_Object[71], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[72] = CreateObject(19329, 1791.9011, -1694.3664, 19.0438, 0.0000, 0.0000, -90.0000); //7_11_sign04
	SetObjectMaterial(g_Object[72], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[73] = CreateObject(19329, 1790.8508, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[73], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[74] = CreateObject(19329, 1788.7603, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[74], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[75] = CreateObject(19329, 1786.6706, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[75], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[76] = CreateObject(19329, 1784.5509, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[76], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[77] = CreateObject(19329, 1782.4708, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[77], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[78] = CreateObject(19329, 1780.3808, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[78], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[79] = CreateObject(19329, 1778.2811, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[79], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[80] = CreateObject(19329, 1776.2008, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[80], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[81] = CreateObject(19329, 1774.1209, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[81], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[82] = CreateObject(19329, 1772.0207, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[82], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[83] = CreateObject(19329, 1769.9101, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[83], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[84] = CreateObject(19329, 1767.8000, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[84], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[85] = CreateObject(19329, 1765.6895, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[85], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[86] = CreateObject(19329, 1764.1291, -1695.4375, 19.0438, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[86], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[87] = CreateObject(19466, 1766.0545, -1695.3555, 15.0487, 0.0000, 0.0000, -90.0000); //window001
	g_Object[88] = CreateObject(19565, 1777.7620, -1695.4172, 19.7986, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[88], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[89] = CreateObject(19325, 1770.4963, -1695.3520, 14.6917, 0.0000, 0.0000, 90.0000); //lsmall_window01
	SetObjectMaterial(g_Object[89], 0, 3781, "lan2office", "glass_office6", 0xFFFFFFFF);
	g_Object[90] = CreateObject(19362, 1809.2166, -1696.3074, 10.8103, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[90], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[91] = CreateObject(19565, 1777.7620, -1695.4172, 19.5386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[91], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[92] = CreateObject(19565, 1777.7620, -1695.4172, 19.2986, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[92], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[93] = CreateObject(19565, 1777.7620, -1695.4172, 19.0786, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[93], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[94] = CreateObject(19565, 1777.7620, -1695.4172, 18.8386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[94], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[95] = CreateObject(19565, 1777.7620, -1695.4172, 18.5786, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[95], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[96] = CreateObject(19565, 1777.7620, -1695.4172, 18.3286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[96], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[97] = CreateObject(19565, 1777.3216, -1695.4172, 18.3286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[97], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[98] = CreateObject(19565, 1776.8612, -1695.4172, 18.3286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[98], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[99] = CreateObject(19565, 1776.4107, -1695.4172, 18.3286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[99], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[100] = CreateObject(19565, 1775.9603, -1695.4172, 18.3286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[100], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[101] = CreateObject(19565, 1775.9603, -1695.4172, 18.5786, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[101], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[102] = CreateObject(19565, 1775.9603, -1695.4172, 18.8286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[102], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[103] = CreateObject(19565, 1775.9603, -1695.4172, 19.0886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[103], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[104] = CreateObject(19565, 1775.9603, -1695.4172, 19.3386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[104], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[105] = CreateObject(19565, 1775.9603, -1695.4172, 19.5886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[105], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[106] = CreateObject(19565, 1775.9603, -1695.4172, 19.7886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[106], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[107] = CreateObject(19565, 1776.4007, -1695.4172, 19.7886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[107], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[108] = CreateObject(19565, 1776.8511, -1695.4172, 19.7886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[108], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[109] = CreateObject(19565, 1777.3016, -1695.4172, 19.7886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[109], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[110] = CreateObject(19565, 1777.3016, -1695.4172, 19.5586, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[110], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[111] = CreateObject(19565, 1777.3016, -1695.4172, 19.3386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[111], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[112] = CreateObject(19565, 1777.3016, -1695.4172, 19.1286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[112], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[113] = CreateObject(19565, 1777.3016, -1695.4172, 18.8986, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[113], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[114] = CreateObject(19565, 1777.3016, -1695.4172, 18.6786, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[114], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[115] = CreateObject(19565, 1777.3016, -1695.4172, 18.4986, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[115], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[116] = CreateObject(19565, 1776.8411, -1695.4172, 18.5986, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[116], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[117] = CreateObject(19565, 1776.8411, -1695.4172, 18.8086, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[117], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[118] = CreateObject(19565, 1776.8411, -1695.4172, 19.0586, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[118], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[119] = CreateObject(19565, 1776.8411, -1695.4172, 19.2986, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[119], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[120] = CreateObject(19565, 1776.8411, -1695.4172, 19.5386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[120], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[121] = CreateObject(19327, 1777.1171, -1695.5715, 19.1156, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[121], "ARAL", 0, 90, "Arial", 90, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[122] = CreateObject(9131, 1772.5633, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[122], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[123] = CreateObject(9131, 1770.3537, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[123], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[124] = CreateObject(9131, 1774.7530, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[124], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[125] = CreateObject(9131, 1776.9625, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[125], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[126] = CreateObject(9131, 1779.1717, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[126], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[127] = CreateObject(9131, 1781.3006, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[127], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[128] = CreateObject(9131, 1783.3707, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[128], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[129] = CreateObject(9131, 1785.5301, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[129], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[130] = CreateObject(9131, 1787.7298, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[130], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[131] = CreateObject(9131, 1789.8996, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[131], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[132] = CreateObject(9131, 1792.0704, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[132], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[133] = CreateObject(9131, 1794.1898, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[133], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[134] = CreateObject(9131, 1796.3802, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[134], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[135] = CreateObject(9131, 1798.5799, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[135], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[136] = CreateObject(9131, 1800.8004, -1721.9680, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[136], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[137] = CreateObject(9131, 1768.1031, -1721.9580, 12.8699, 0.0000, 90.0000, -180.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[137], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[138] = CreateObject(9131, 1755.6927, -1721.9580, 12.8699, 0.0000, 90.0000, -180.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[138], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[139] = CreateObject(9131, 1755.6805, -1721.9680, 12.8500, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[139], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[140] = CreateObject(9131, 1754.9331, -1720.4572, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[140], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[141] = CreateObject(9131, 1754.9331, -1718.2165, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[141], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[142] = CreateObject(9131, 1754.9331, -1716.0061, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[142], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[143] = CreateObject(9131, 1754.9331, -1713.7854, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[143], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[144] = CreateObject(9131, 1754.9331, -1711.5551, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[144], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[145] = CreateObject(9131, 1754.9331, -1709.3752, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[145], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[146] = CreateObject(9131, 1754.9331, -1707.1745, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[146], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[147] = CreateObject(9131, 1754.9331, -1704.9641, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[147], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[148] = CreateObject(9131, 1754.9331, -1702.7442, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[148], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[149] = CreateObject(9131, 1754.9331, -1700.4935, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[149], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[150] = CreateObject(9131, 1754.9331, -1698.2534, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[150], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[151] = CreateObject(9131, 1754.9331, -1696.0633, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[151], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[152] = CreateObject(9131, 1754.9331, -1693.8327, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[152], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[153] = CreateObject(9131, 1754.9331, -1691.6030, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[153], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[154] = CreateObject(9131, 1754.9331, -1689.3924, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[154], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[155] = CreateObject(9131, 1754.9331, -1687.1519, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[155], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[156] = CreateObject(9131, 1754.9331, -1684.9118, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[156], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[157] = CreateObject(9131, 1754.9331, -1683.4012, 12.8699, 0.0000, 90.0000, 90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[157], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[158] = CreateObject(9131, 1756.4240, -1682.6405, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[158], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[159] = CreateObject(9131, 1758.6541, -1682.6405, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[159], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[160] = CreateObject(9131, 1760.8739, -1682.6405, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[160], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[161] = CreateObject(9131, 1762.9447, -1682.6405, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[161], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[162] = CreateObject(19325, 1783.7784, -1695.3520, 14.6917, 0.0000, 0.0000, 90.0000); //lsmall_window01
	SetObjectMaterial(g_Object[162], 0, 3781, "lan2office", "glass_office1", 0xFFFFFFFF);
	g_Object[163] = CreateObject(9131, 1811.2701, -1721.1772, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[163], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[164] = CreateObject(9131, 1811.2701, -1718.9266, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[164], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[165] = CreateObject(9131, 1811.2701, -1716.6656, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[165], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[166] = CreateObject(9131, 1811.2701, -1714.4151, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[166], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[167] = CreateObject(9131, 1811.2701, -1712.2054, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[167], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[168] = CreateObject(9131, 1811.2701, -1709.9852, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[168], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[169] = CreateObject(9131, 1811.2701, -1707.7644, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[169], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[170] = CreateObject(9131, 1811.2701, -1705.5444, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[170], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[171] = CreateObject(9131, 1811.2701, -1703.3442, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[171], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[172] = CreateObject(9131, 1811.2701, -1701.0943, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[172], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[173] = CreateObject(9131, 1811.2701, -1698.8734, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[173], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[174] = CreateObject(9131, 1811.2701, -1696.6234, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[174], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[175] = CreateObject(9131, 1811.2701, -1694.3835, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[175], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[176] = CreateObject(9131, 1811.2701, -1692.1429, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[176], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[177] = CreateObject(9131, 1811.2701, -1689.9127, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[177], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[178] = CreateObject(9131, 1811.2701, -1687.6622, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[178], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[179] = CreateObject(9131, 1811.2701, -1685.4216, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[179], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[180] = CreateObject(9131, 1811.2701, -1683.1809, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[180], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[181] = CreateObject(9131, 1811.2701, -1681.7596, 12.8699, 0.0000, 90.0000, -90.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[181], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[182] = CreateObject(9131, 1810.5092, -1680.2893, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[182], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[183] = CreateObject(9131, 1808.2690, -1680.2893, 12.8699, 0.0000, 90.0000, 0.0000); //shbbyhswall13_lvs
	SetObjectMaterial(g_Object[183], 0, 16093, "a51_ext", "ws_whitewall2_top", 0xFFFFFFFF);
	g_Object[184] = CreateObject(7312, 1796.0374, -1690.9448, 14.6830, 0.0000, 0.0000, -90.0000); //vgsN_carwash01
	g_Object[185] = CreateObject(19459, 1793.5622, -1690.6148, 16.9470, 0.0000, 90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[185], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[186] = CreateObject(19459, 1796.8923, -1690.6148, 16.9470, 0.0000, 90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[186], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[187] = CreateObject(19459, 1798.3526, -1690.6148, 16.9370, 0.0000, 90.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[187], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[188] = CreateObject(19459, 1800.0428, -1690.6146, 15.2770, 0.0000, 0.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[188], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[189] = CreateObject(19459, 1800.0428, -1690.6146, 11.8769, 0.0000, 0.0000, 0.0000); //wall099
	SetObjectMaterial(g_Object[189], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[190] = CreateObject(19329, 1796.2623, -1695.4273, 16.8237, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[190], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[191] = CreateObject(19327, 1796.4892, -1695.4411, 16.4755, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[191], "SuperWash", 0, 90, "Arial", 45, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[192] = CreateObject(19459, 1795.3214, -1685.8950, 15.2069, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[192], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[193] = CreateObject(19459, 1795.3214, -1685.8850, 12.1969, 0.0000, 0.0000, -90.0000); //wall099
	SetObjectMaterial(g_Object[193], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[194] = CreateObject(19327, 1763.0548, -1688.2110, 17.0228, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterial(g_Object[194], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[195] = CreateObject(19327, 1763.0548, -1690.5416, 17.0228, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterial(g_Object[195], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[196] = CreateObject(19327, 1763.0548, -1692.8719, 17.0228, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterial(g_Object[196], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[197] = CreateObject(1227, 1773.8272, -1685.1187, 13.3816, 0.0000, 0.0000, -180.0000); //dump1
	g_Object[198] = CreateObject(1331, 1777.0655, -1685.1335, 13.4252, 0.0000, 0.0000, 0.0000); //BinNt01_LA
	g_Object[199] = CreateObject(1334, 1780.1538, -1685.0295, 13.6269, 0.0000, 0.0000, 0.0000); //BinNt04_LA
	g_Object[200] = CreateObject(1372, 1782.8088, -1685.1981, 12.6470, 0.0000, 0.0000, 180.0000); //CJ_Dump2_LOW
	g_Object[201] = CreateObject(11547, 1788.3520, -1710.9283, 15.4636, 0.0000, 0.0000, 0.0000); //desn_tscanopy
	SetObjectMaterial(g_Object[201], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[201], 1, 10765, "airportgnd_sfse", "white", 0xFF103250);
	SetObjectMaterial(g_Object[201], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[202] = CreateObject(11547, 1774.2020, -1710.9283, 15.4636, 0.0000, 0.0000, 0.0000); //desn_tscanopy
	SetObjectMaterial(g_Object[202], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[202], 1, 10765, "airportgnd_sfse", "white", 0xFF103250);
	SetObjectMaterial(g_Object[202], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[203] = CreateObject(1676, 1788.3424, -1713.7398, 14.2367, 0.0000, 0.0000, 0.0000); //washgaspump
	SetObjectMaterial(g_Object[203], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[203], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[203], 3, 3629, "arprtxxref_las", "metaldoor_128", 0xFFFFFFFF);
	g_Object[204] = CreateObject(1676, 1788.3424, -1719.2204, 14.2367, 0.0000, 0.0000, 0.0000); //washgaspump
	SetObjectMaterial(g_Object[204], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[204], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[204], 3, 3629, "arprtxxref_las", "metaldoor_128", 0xFFFFFFFF);
	g_Object[205] = CreateObject(1676, 1788.3424, -1708.2290, 14.2367, 0.0000, 0.0000, 0.0000); //washgaspump
	SetObjectMaterial(g_Object[205], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[205], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[205], 3, 3629, "arprtxxref_las", "metaldoor_128", 0xFFFFFFFF);
	g_Object[206] = CreateObject(1676, 1788.3424, -1702.7271, 14.2367, 0.0000, 0.0000, 0.0000); //washgaspump
	SetObjectMaterial(g_Object[206], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[206], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[206], 3, 3629, "arprtxxref_las", "metaldoor_128", 0xFFFFFFFF);
	g_Object[207] = CreateObject(1676, 1774.2915, -1702.7271, 14.2367, 0.0000, 0.0000, 0.0000); //washgaspump
	SetObjectMaterial(g_Object[207], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[207], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[207], 3, 3629, "arprtxxref_las", "metaldoor_128", 0xFFFFFFFF);
	g_Object[208] = CreateObject(1676, 1774.2915, -1708.2166, 14.2367, 0.0000, 0.0000, 0.0000); //washgaspump
	SetObjectMaterial(g_Object[208], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[208], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[208], 3, 3629, "arprtxxref_las", "metaldoor_128", 0xFFFFFFFF);
	g_Object[209] = CreateObject(1676, 1774.2915, -1713.7268, 14.2367, 0.0000, 0.0000, 0.0000); //washgaspump
	SetObjectMaterial(g_Object[209], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[209], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[209], 3, 3629, "arprtxxref_las", "metaldoor_128", 0xFFFFFFFF);
	g_Object[210] = CreateObject(1676, 1774.2915, -1719.1977, 14.2367, 0.0000, 0.0000, 0.0000); //washgaspump
	SetObjectMaterial(g_Object[210], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[210], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	SetObjectMaterial(g_Object[210], 3, 3629, "arprtxxref_las", "metaldoor_128", 0xFFFFFFFF);
	g_Object[211] = CreateObject(2741, 1791.1496, -1719.1767, 14.5911, 0.0000, 0.0000, 90.0000); //CJ_SOAP_DISP
	g_Object[212] = CreateObject(2741, 1791.1496, -1713.6756, 14.5911, 0.0000, 0.0000, 90.0000); //CJ_SOAP_DISP
	g_Object[213] = CreateObject(2741, 1791.1496, -1708.1744, 14.5911, 0.0000, 0.0000, 90.0000); //CJ_SOAP_DISP
	g_Object[214] = CreateObject(2741, 1791.1496, -1702.6827, 14.5911, 0.0000, 0.0000, 90.0000); //CJ_SOAP_DISP
	g_Object[215] = CreateObject(2741, 1776.9973, -1702.6728, 14.5911, 0.0000, 0.0000, 90.0000); //CJ_SOAP_DISP
	g_Object[216] = CreateObject(2741, 1776.9973, -1708.1740, 14.5911, 0.0000, 0.0000, 90.0000); //CJ_SOAP_DISP
	g_Object[217] = CreateObject(2741, 1776.9973, -1713.6733, 14.5911, 0.0000, 0.0000, 90.0000); //CJ_SOAP_DISP
	g_Object[218] = CreateObject(2741, 1776.9973, -1719.1749, 14.5911, 0.0000, 0.0000, 90.0000); //CJ_SOAP_DISP
	g_Object[219] = CreateObject(19621, 1775.4100, -1708.1135, 12.8177, 0.0000, 0.0000, 0.0000); //OilCan1
	g_Object[220] = CreateObject(19621, 1775.4100, -1713.5852, 12.8177, 0.0000, 0.0000, 0.0000); //OilCan1
	g_Object[221] = CreateObject(19621, 1775.4100, -1719.1063, 12.8177, 0.0000, 0.0000, 0.0000); //OilCan1
	g_Object[222] = CreateObject(19621, 1775.4100, -1702.6157, 12.8177, 0.0000, 0.0000, 0.0000); //OilCan1
	g_Object[223] = CreateObject(19621, 1786.7103, -1702.6157, 12.8177, 0.0000, 0.0000, 0.0000); //OilCan1
	g_Object[224] = CreateObject(19621, 1786.7103, -1708.1269, 12.8177, 0.0000, 0.0000, 0.0000); //OilCan1
	g_Object[225] = CreateObject(19621, 1786.7103, -1713.6262, 12.8177, 0.0000, 0.0000, 0.0000); //OilCan1
	g_Object[226] = CreateObject(19621, 1786.7103, -1719.0371, 12.8177, 0.0000, 0.0000, 0.0000); //OilCan1
	g_Object[227] = CreateObject(1650, 1787.0511, -1719.1351, 13.0208, 0.0000, 0.0000, -90.0000); //petrolcanm
	g_Object[228] = CreateObject(1650, 1787.0511, -1713.7038, 13.0208, 0.0000, 0.0000, -90.0000); //petrolcanm
	g_Object[229] = CreateObject(1650, 1787.0511, -1708.2126, 13.0208, 0.0000, 0.0000, -90.0000); //petrolcanm
	g_Object[230] = CreateObject(1650, 1787.0511, -1702.7103, 13.0208, 0.0000, 0.0000, -90.0000); //petrolcanm
	g_Object[231] = CreateObject(1650, 1775.8802, -1702.7103, 13.0208, 0.0000, 0.0000, -90.0000); //petrolcanm
	g_Object[232] = CreateObject(1650, 1775.8802, -1708.2125, 13.0208, 0.0000, 0.0000, -90.0000); //petrolcanm
	g_Object[233] = CreateObject(1650, 1775.8802, -1713.6822, 13.0208, 0.0000, 0.0000, -90.0000); //petrolcanm
	g_Object[234] = CreateObject(1650, 1775.8802, -1719.1861, 13.0208, 0.0000, 0.0000, -90.0000); //petrolcanm
	g_Object[235] = CreateObject(19565, 1791.0898, -1719.3077, 15.4079, 0.0000, 90.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[235], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[236] = CreateObject(19565, 1791.0898, -1713.8078, 15.4079, 0.0000, 90.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[236], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[237] = CreateObject(19565, 1791.0898, -1708.3172, 15.4079, 0.0000, 90.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[237], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[238] = CreateObject(19565, 1791.0898, -1702.8155, 15.4079, 0.0000, 90.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[238], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[239] = CreateObject(19565, 1776.9394, -1702.8155, 15.4079, 0.0000, 90.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[239], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[240] = CreateObject(19565, 1776.9394, -1708.3171, 15.4079, 0.0000, 90.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[240], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[241] = CreateObject(19565, 1776.9394, -1713.8081, 15.4079, 0.0000, 90.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[241], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[242] = CreateObject(19565, 1776.9394, -1719.3094, 15.4079, 0.0000, 90.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[242], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[243] = CreateObject(19327, 1776.9848, -1718.0770, 14.9752, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[243], "1", 0, 90, "Arial", 35, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[244] = CreateObject(1215, 1757.0919, -1721.9636, 13.0706, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[245] = CreateObject(19327, 1776.9848, -1712.5758, 14.9752, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[245], "2", 0, 90, "Arial", 35, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[246] = CreateObject(19327, 1776.9848, -1707.0849, 14.9752, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[246], "3", 0, 90, "Arial", 35, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[247] = CreateObject(19327, 1776.9848, -1701.5843, 14.9752, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[247], "4", 0, 90, "Arial", 35, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[248] = CreateObject(19327, 1791.1560, -1718.0766, 14.9652, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[248], "5", 0, 90, "Arial", 35, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[249] = CreateObject(19327, 1791.1560, -1712.5765, 14.9652, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[249], "6", 0, 90, "Arial", 35, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[250] = CreateObject(19327, 1791.1560, -1707.0853, 14.9652, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[250], "7", 0, 90, "Arial", 35, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[251] = CreateObject(19327, 1791.1560, -1701.5841, 14.9652, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[251], "8", 0, 90, "Arial", 35, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[252] = CreateObject(1215, 1766.6928, -1721.9636, 13.0706, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[253] = CreateObject(1215, 1802.1844, -1721.9636, 13.0706, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[254] = CreateObject(1215, 1810.6059, -1721.9636, 13.0706, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[255] = CreateObject(1893, 1788.4903, -1717.0810, 17.7374, 0.0000, 0.0000, 90.0000); //shoplight1
	g_Object[256] = CreateObject(1893, 1788.4903, -1711.4101, 17.7374, 0.0000, 0.0000, 90.0000); //shoplight1
	g_Object[257] = CreateObject(1893, 1788.4903, -1705.8392, 17.7374, 0.0000, 0.0000, 90.0000); //shoplight1
	g_Object[258] = CreateObject(1893, 1774.3073, -1705.8392, 17.7374, 0.0000, 0.0000, 90.0000); //shoplight1
	g_Object[259] = CreateObject(1893, 1774.3073, -1711.4116, 17.7374, 0.0000, 0.0000, 90.0000); //shoplight1
	g_Object[260] = CreateObject(1893, 1774.3073, -1717.1125, 17.7374, 0.0000, 0.0000, 90.0000); //shoplight1
	g_Object[261] = CreateObject(7312, 1796.3968, -1690.9448, 13.6531, -90.0000, 0.0000, -90.0000); //vgsN_carwash01
	g_Object[262] = CreateObject(19967, 1756.8927, -1721.9428, 12.4225, 0.0000, 0.0000, 0.0000); //SAMPRoadSign20
	g_Object[263] = CreateObject(19459, 1786.9217, -1690.0651, 12.4768, 0.0000, -90.0000, 90.0000); //wall099
	SetObjectMaterial(g_Object[263], 0, 14581, "ab_mafiasuitea", "cof_wood2", 0xFFFFFFFF);
	g_Object[264] = CreateObject(19327, 1765.8254, -1685.7911, 17.0228, 0.0000, 0.0000, -180.0000); //7_11_sign02
	SetObjectMaterial(g_Object[264], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[265] = CreateObject(19327, 1768.1456, -1685.7911, 17.0228, 0.0000, 0.0000, -180.0000); //7_11_sign02
	SetObjectMaterial(g_Object[265], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[266] = CreateObject(19327, 1770.4655, -1685.7911, 17.0228, 0.0000, 0.0000, -180.0000); //7_11_sign02
	SetObjectMaterial(g_Object[266], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[267] = CreateObject(19327, 1772.7960, -1685.7911, 17.0228, 0.0000, 0.0000, -180.0000); //7_11_sign02
	SetObjectMaterial(g_Object[267], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[268] = CreateObject(19327, 1775.1251, -1685.7911, 17.0228, 0.0000, 0.0000, -180.0000); //7_11_sign02
	SetObjectMaterial(g_Object[268], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[269] = CreateObject(19327, 1777.4544, -1685.7911, 17.0228, 0.0000, 0.0000, -180.0000); //7_11_sign02
	SetObjectMaterial(g_Object[269], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[270] = CreateObject(19327, 1779.7855, -1685.7911, 17.0228, 0.0000, 0.0000, -180.0000); //7_11_sign02
	SetObjectMaterial(g_Object[270], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[271] = CreateObject(19325, 1777.1353, -1695.3520, 14.6917, 0.0000, 0.0000, 90.0000); //lsmall_window01
	SetObjectMaterial(g_Object[271], 0, 3781, "lan2office", "glass_office1", 0xFFFFFFFF);
	g_Object[272] = CreateObject(19436, 1786.3088, -1695.3337, 14.2817, 0.0000, 0.0000, 90.0000); //wall076
	SetObjectMaterial(g_Object[272], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[273] = CreateObject(19466, 1764.6058, -1695.3255, 15.0487, 0.0000, 0.0000, -90.0000); //window001
	g_Object[274] = CreateObject(19329, 1764.5495, -1695.4375, 16.5737, 0.0000, 0.0000, -180.0000); //7_11_sign04
	SetObjectMaterial(g_Object[274], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[275] = CreateObject(19565, 1763.5120, -1695.6940, 14.0674, -90.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[275], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[276] = CreateObject(19327, 1764.8221, -1695.4453, 16.1485, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[276], "Nachtschalter", 0, 90, "Arial", 35, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[277] = CreateObject(19565, 1763.9725, -1695.6940, 14.0674, -90.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[277], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[278] = CreateObject(19565, 1764.4228, -1695.6940, 14.0674, -90.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[278], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[279] = CreateObject(19565, 1764.8732, -1695.6940, 14.0674, -90.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[279], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[280] = CreateObject(19565, 1764.8732, -1695.2536, 14.0674, -90.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[280], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[281] = CreateObject(19565, 1764.4230, -1695.2536, 14.0674, -90.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[281], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[282] = CreateObject(19565, 1763.9726, -1695.2536, 14.0674, -90.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[282], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[283] = CreateObject(19565, 1763.5122, -1695.2536, 14.0674, -90.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[283], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[284] = CreateObject(19459, 1786.9217, -1693.5657, 12.4768, 0.0000, -90.0000, 90.0000); //wall099
	SetObjectMaterial(g_Object[284], 0, 14581, "ab_mafiasuitea", "cof_wood2", 0xFFFFFFFF);
	g_Object[285] = CreateObject(19459, 1786.9217, -1687.7132, 12.4868, 0.0000, -90.0000, 90.0000); //wall099
	SetObjectMaterial(g_Object[285], 0, 14581, "ab_mafiasuitea", "cof_wood2", 0xFFFFFFFF);
	g_Object[286] = CreateObject(19459, 1777.2999, -1687.7132, 12.4868, 0.0000, -90.0000, 90.0000); //wall099
	SetObjectMaterial(g_Object[286], 0, 14581, "ab_mafiasuitea", "cof_wood2", 0xFFFFFFFF);
	g_Object[287] = CreateObject(19459, 1777.2890, -1690.0651, 12.4768, 0.0000, -90.0000, 90.0000); //wall099
	SetObjectMaterial(g_Object[287], 0, 14581, "ab_mafiasuitea", "cof_wood2", 0xFFFFFFFF);
	g_Object[288] = CreateObject(19459, 1777.2897, -1693.5657, 12.4768, 0.0000, -90.0000, 90.0000); //wall099
	SetObjectMaterial(g_Object[288], 0, 14581, "ab_mafiasuitea", "cof_wood2", 0xFFFFFFFF);
	g_Object[289] = CreateObject(19459, 1767.9084, -1693.5657, 12.4868, 0.0000, -90.0000, 90.0000); //wall099
	SetObjectMaterial(g_Object[289], 0, 14581, "ab_mafiasuitea", "cof_wood2", 0xFFFFFFFF);
	g_Object[290] = CreateObject(19459, 1767.9084, -1690.0649, 12.4868, 0.0000, -90.0000, 90.0000); //wall099
	SetObjectMaterial(g_Object[290], 0, 14581, "ab_mafiasuitea", "cof_wood2", 0xFFFFFFFF);
	g_Object[291] = CreateObject(19459, 1767.9084, -1687.6833, 12.4768, 0.0000, -90.0000, 90.0000); //wall099
	SetObjectMaterial(g_Object[291], 0, 14581, "ab_mafiasuitea", "cof_wood2", 0xFFFFFFFF);
	g_Object[292] = CreateObject(1890, 1782.2663, -1691.0240, 12.5584, 0.0000, 0.0000, 0.0000); //shop_dblshlf02
	g_Object[293] = CreateObject(2632, 1774.2934, -1693.2730, 12.5679, 0.0000, 0.0000, 0.0000); //gym_mat02
	SetObjectMaterial(g_Object[293], 0, 14569, "traidman", "darkgrey_carpet_256", 0xFFFFFFFF);
	g_Object[294] = CreateObject(2632, 1782.1473, -1693.2730, 12.5679, 0.0000, 0.0000, 0.0000); //gym_mat02
	SetObjectMaterial(g_Object[294], 0, 14569, "traidman", "darkgrey_carpet_256", 0xFFFFFFFF);
	g_Object[295] = CreateObject(2632, 1774.2934, -1688.7927, 12.5679, 0.0000, 0.0000, 0.0000); //gym_mat02
	SetObjectMaterial(g_Object[295], 0, 14569, "traidman", "darkgrey_carpet_256", 0xFFFFFFFF);
	g_Object[296] = CreateObject(2632, 1782.1055, -1688.7927, 12.5679, 0.0000, 0.0000, 0.0000); //gym_mat02
	SetObjectMaterial(g_Object[296], 0, 14569, "traidman", "darkgrey_carpet_256", 0xFFFFFFFF);
	g_Object[297] = CreateObject(1891, 1778.1903, -1691.0250, 12.5545, 0.0000, 0.0000, 0.0000); //shop_dblshlf03
	g_Object[298] = CreateObject(1890, 1774.1363, -1691.0240, 12.5584, 0.0000, 0.0000, 0.0000); //shop_dblshlf02
	g_Object[299] = CreateObject(1847, 1783.8428, -1686.5009, 12.5500, 0.0000, 0.0000, 0.0000); //shop_shelf06
	g_Object[300] = CreateObject(1847, 1778.1634, -1686.5009, 12.5500, 0.0000, 0.0000, 0.0000); //shop_shelf06
	g_Object[301] = CreateObject(19329, 1791.7202, -1690.4479, 16.3537, 0.0000, 0.0000, 90.0000); //7_11_sign04
	SetObjectMaterial(g_Object[301], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF105082);
	g_Object[302] = CreateObject(2400, 1791.6248, -1687.0838, 12.6677, 0.0000, 0.0000, -90.0000); //CJ_SPORTS_WALL01
	SetObjectMaterial(g_Object[302], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[302], 1, 3440, "airportpillar", "metalic_64", 0xFFFFFFFF);
	g_Object[303] = CreateObject(2400, 1791.6248, -1691.1936, 12.6677, 0.0000, 0.0000, -90.0000); //CJ_SPORTS_WALL01
	SetObjectMaterial(g_Object[303], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[303], 1, 3440, "airportpillar", "metalic_64", 0xFFFFFFFF);
	g_Object[304] = CreateObject(11435, 1796.2252, -1721.4814, 17.0720, 0.0000, 0.0000, 90.0000); //des_indsign1
	SetObjectMaterial(g_Object[304], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[304], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[304], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[305] = CreateObject(19327, 1791.7084, -1690.9293, 15.9468, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[305], "Autoteile", 0, 90, "Arial", 40, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[306] = CreateObject(19327, 1796.3748, -1721.6564, 18.8549, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[306], "ARAL", 0, 90, "Arial", 80, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[307] = CreateObject(19327, 1796.0742, -1722.2270, 18.8549, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[307], "ARAL", 0, 90, "Arial", 80, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[308] = CreateObject(19436, 1790.9604, -1695.3437, 14.2817, 0.0000, 0.0000, 90.0000); //wall076
	SetObjectMaterial(g_Object[308], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[309] = CreateObject(1075, 1791.4459, -1687.2285, 15.0858, 0.0000, 0.0000, 180.0000); //wheel_sr2
	g_Object[310] = CreateObject(1080, 1791.4440, -1688.5266, 15.0977, 0.0000, 0.0000, 180.0000); //wheel_sr5
	g_Object[311] = CreateObject(1085, 1791.4293, -1689.8013, 15.0777, 0.0000, 0.0000, 180.0000); //wheel_gn2
	g_Object[312] = CreateObject(1104, 1792.2215, -1691.0241, 14.6720, 0.0000, 0.0000, -90.0999); //exh_lr_bl1
	g_Object[313] = CreateObject(1116, 1791.4729, -1691.3789, 14.0415, 0.0000, 0.0000, 90.0000); //fbb_lr_slv2
	g_Object[314] = CreateObject(1163, 1791.3708, -1691.6533, 13.5502, 0.0000, 0.0000, 90.0000); //spl_c_u_b
	g_Object[315] = CreateObject(1181, 1791.2985, -1694.0898, 14.4252, 0.0000, 0.0000, 90.0000); //fbmp_lr_bl2
	g_Object[316] = CreateObject(1115, 1791.5913, -1693.4877, 13.3302, 0.0000, 0.0000, 90.0000); //fbb_lr_slv1
	g_Object[317] = CreateObject(1090, 1791.3237, -1687.9301, 13.6572, 0.0000, 0.0000, 0.0000); //wg_l_a_u
	g_Object[318] = CreateObject(1650, 1791.4359, -1692.1845, 14.9216, 0.0000, 0.0000, 90.0000); //petrolcanm
	g_Object[319] = CreateObject(1650, 1791.4359, -1692.5847, 14.9216, 0.1999, 0.0000, 90.0000); //petrolcanm
	g_Object[320] = CreateObject(1650, 1791.4359, -1692.9946, 14.9216, 0.1999, 0.0000, 90.0000); //petrolcanm
	g_Object[321] = CreateObject(1650, 1791.4359, -1693.4449, 14.9216, 0.1999, 0.0000, 90.0000); //petrolcanm
	g_Object[322] = CreateObject(1650, 1791.4359, -1693.8853, 14.9216, 0.1999, 0.0000, 90.0000); //petrolcanm
	g_Object[323] = CreateObject(18075, 1769.7360, -1690.7602, 19.3497, 0.0000, 0.0000, 90.0000); //lightD
	g_Object[324] = CreateObject(18075, 1783.6472, -1690.7602, 19.3497, 0.0000, 0.0000, 90.0000); //lightD
	g_Object[325] = CreateObject(1024, 1791.6601, -1691.7025, 15.1801, 0.0000, 0.0000, 90.0000); //lgt_b_sspt
	g_Object[326] = CreateObject(1014, 1791.4335, -1688.7216, 14.3683, 0.0000, 0.0000, 90.0000); //spl_b_bar_l
	g_Object[327] = CreateObject(2621, 1783.0755, -1694.8041, 13.3312, 0.0000, 0.0000, 0.0000); //CJ_TRAINER_HEAT
	g_Object[328] = CreateObject(2621, 1778.3449, -1694.8041, 13.3312, 0.0000, 0.0000, 0.0000); //CJ_TRAINER_HEAT
	g_Object[329] = CreateObject(2621, 1774.0253, -1694.8041, 13.3312, 0.0000, 0.0000, 0.0000); //CJ_TRAINER_HEAT
	g_Object[330] = CreateObject(2622, 1776.1975, -1694.7969, 13.3656, 0.0000, 0.0000, 0.0000); //CJ_TRAINER_PRO
	g_Object[331] = CreateObject(2622, 1780.7485, -1694.7969, 13.3656, 0.0000, 0.0000, 0.0000); //CJ_TRAINER_PRO
	g_Object[332] = CreateObject(19327, 1763.2548, -1692.8719, 17.0228, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterial(g_Object[332], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[333] = CreateObject(19327, 1763.2548, -1690.5411, 17.0228, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterial(g_Object[333], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[334] = CreateObject(19327, 1763.2548, -1688.2098, 17.0228, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterial(g_Object[334], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[335] = CreateObject(1847, 1772.4227, -1686.5009, 12.5500, 0.0000, 0.0000, 0.0000); //shop_shelf06
	g_Object[336] = CreateObject(1775, 1787.3529, -1686.5451, 13.6639, 0.0000, 0.0000, 0.0000); //CJ_SPRUNK1
	SetObjectMaterial(g_Object[336], 0, 2212, "burger_tray", "sprunk_cb", 0xFFFFFFFF);
	g_Object[337] = CreateObject(19327, 1779.7855, -1685.9813, 17.0228, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterial(g_Object[337], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[338] = CreateObject(19327, 1777.4552, -1685.9813, 17.0228, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterial(g_Object[338], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[339] = CreateObject(19327, 1775.1347, -1685.9813, 17.0228, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterial(g_Object[339], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[340] = CreateObject(19327, 1772.8050, -1685.9813, 17.0228, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterial(g_Object[340], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[341] = CreateObject(19327, 1770.4744, -1685.9813, 17.0228, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterial(g_Object[341], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[342] = CreateObject(19327, 1768.1640, -1685.9813, 17.0228, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterial(g_Object[342], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[343] = CreateObject(19327, 1765.8342, -1685.9813, 17.0228, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterial(g_Object[343], 0, 8395, "pyramid", "luxorwindow01_128", 0xFFFFFFFF);
	g_Object[344] = CreateObject(19362, 1767.1668, -1690.5330, 12.3320, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[344], 0, 10765, "airportgnd_sfse", "white", 0xFF103250);
	g_Object[345] = CreateObject(19362, 1767.1668, -1693.6834, 12.3320, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[345], 0, 10765, "airportgnd_sfse", "white", 0xFF103250);
	g_Object[346] = CreateObject(19362, 1767.1668, -1688.9133, 12.3320, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[346], 0, 10765, "airportgnd_sfse", "white", 0xFF103250);
	g_Object[347] = CreateObject(19439, 1767.1545, -1693.0361, 13.5376, 0.0000, 90.0000, 90.0000); //wall079
	SetObjectMaterial(g_Object[347], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[348] = CreateObject(19439, 1767.1545, -1689.2961, 13.5376, 0.0000, 90.0000, 90.0000); //wall079
	SetObjectMaterial(g_Object[348], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[349] = CreateObject(2941, 1766.7510, -1694.1713, 13.9743, 0.0000, 0.0000, 90.0000); //temp_till
	g_Object[350] = CreateObject(2941, 1766.7510, -1692.1816, 13.9743, 0.0000, 0.0000, 90.0000); //temp_till
	g_Object[351] = CreateObject(2941, 1766.7510, -1690.2106, 13.9743, 0.0000, 0.0000, 90.0000); //temp_till
	g_Object[352] = CreateObject(2941, 1766.7510, -1688.3505, 13.9743, 0.0000, 0.0000, 90.0000); //temp_till
	g_Object[353] = CreateObject(19565, 1767.3074, -1695.3498, 15.7455, 0.0000, -90.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[353], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[354] = CreateObject(1892, 1788.1481, -1694.4703, 12.5569, 0.0000, 0.0000, 0.0000); //security_gatsh
	SetObjectMaterial(g_Object[354], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[355] = CreateObject(19565, 1767.3074, -1695.3498, 15.2854, 0.0000, -90.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[355], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[356] = CreateObject(19565, 1767.3074, -1695.3498, 14.8355, 0.0000, -90.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[356], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[357] = CreateObject(19565, 1767.3074, -1695.3498, 14.3754, 0.0000, -90.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[357], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[358] = CreateObject(19565, 1766.5932, -1689.2792, 13.6247, 90.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[358], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF000000);
	g_Object[359] = CreateObject(2996, 1763.5747, -1695.2845, 14.8100, 0.0000, 0.0000, 0.0000); //k_poolballstp02
	SetObjectMaterial(g_Object[359], 0, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0xFFFFFFFF);
	g_Object[360] = CreateObject(2601, 1766.7572, -1689.2937, 13.7304, 0.0000, 0.0000, 0.0000); //CJ_JUICE_CAN
	SetObjectMaterial(g_Object[360], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF000000);
	g_Object[361] = CreateObject(2269, 1766.2818, -1689.1115, 13.7868, 0.0000, 0.0000, -107.6999); //Frame_WOOD_4
	SetObjectMaterial(g_Object[361], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	SetObjectMaterial(g_Object[361], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF000000);
	g_Object[362] = CreateObject(2269, 1767.1673, -1689.4268, 13.7868, 0.0000, 0.0000, 71.7000); //Frame_WOOD_4
	SetObjectMaterial(g_Object[362], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF000000);
	SetObjectMaterial(g_Object[362], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF000000);
	g_Object[363] = CreateObject(2269, 1766.2832, -1693.5070, 13.7868, 0.0000, 0.0000, -58.5999); //Frame_WOOD_4
	SetObjectMaterial(g_Object[363], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	SetObjectMaterial(g_Object[363], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF000000);
	g_Object[364] = CreateObject(2269, 1767.0931, -1693.0318, 13.7868, 0.0000, 0.0000, 121.9000); //Frame_WOOD_4
	SetObjectMaterial(g_Object[364], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF000000);
	SetObjectMaterial(g_Object[364], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF000000);
	g_Object[365] = CreateObject(2601, 1766.7572, -1693.2745, 13.7304, 0.0000, 0.0000, 0.0000); //CJ_JUICE_CAN
	SetObjectMaterial(g_Object[365], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF000000);
	g_Object[366] = CreateObject(19565, 1766.6129, -1693.2700, 13.6247, 90.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[366], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF000000);
	g_Object[367] = CreateObject(19327, 1766.4425, -1690.1558, 13.6484, 0.0000, 0.0000, -107.6000); //7_11_sign02
	SetObjectMaterialText(g_Object[367], "ARAL", 0, 90, "Arial", 24, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[368] = CreateObject(19327, 1767.1879, -1694.0568, 13.6484, 0.0000, 0.0000, -57.8000); //7_11_sign02
	SetObjectMaterialText(g_Object[368], "ARAL", 0, 90, "Arial", 24, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[369] = CreateObject(2632, 1788.6477, -1691.5021, 12.5679, 0.0000, 0.0000, -90.0000); //gym_mat02
	SetObjectMaterial(g_Object[369], 0, 14569, "traidman", "darkgrey_carpet_256", 0xFFFFFFFF);
	g_Object[370] = CreateObject(1775, 1789.0135, -1686.5451, 13.6639, 0.0000, 0.0000, 0.0000); //CJ_SPRUNK1
	SetObjectMaterial(g_Object[370], 0, 2221, "donut_tray", "rustycoffeerap_rb", 0xFFFFFFFF);
	g_Object[371] = CreateObject(19825, 1791.6826, -1690.4481, 17.7265, 0.0000, 0.0000, -90.0000); //SprunkClock1
	SetObjectMaterial(g_Object[371], 0, 1654, "dynamite", "clock64", 0xFFFFFFFF);
	g_Object[372] = CreateObject(2632, 1764.9176, -1691.4621, 12.5679, 0.0000, 0.0000, 90.0000); //gym_mat02
	SetObjectMaterial(g_Object[372], 0, 14569, "traidman", "darkgrey_carpet_256", 0xFFFFFFFF);
	g_Object[373] = CreateObject(2585, 1763.3791, -1693.1320, 14.2737, 0.0000, 0.0000, 90.0000); //CJ_SEX_SHELF_3
	SetObjectMaterial(g_Object[373], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[373], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[374] = CreateObject(2585, 1763.3791, -1691.7714, 14.2737, 0.0000, 0.0000, 90.0000); //CJ_SEX_SHELF_3
	SetObjectMaterial(g_Object[374], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[374], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[375] = CreateObject(2585, 1763.3791, -1690.3311, 14.2737, 0.0000, 0.0000, 90.0000); //CJ_SEX_SHELF_3
	SetObjectMaterial(g_Object[375], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[375], 1, 6282, "beafron2_law2", "ws_ed_shop11", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[375], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[376] = CreateObject(2585, 1763.3791, -1688.9305, 14.2737, 0.0000, 0.0000, 90.0000); //CJ_SEX_SHELF_3
	SetObjectMaterial(g_Object[376], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[376], 1, 6282, "beafron2_law2", "ws_ed_shop11", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[376], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[377] = CreateObject(19466, 1787.0932, -1695.3171, 13.1527, 0.0000, 0.0000, -90.0000); //window001
	g_Object[378] = CreateObject(19466, 1787.0932, -1695.3171, 15.0828, 0.0000, 0.0000, -90.0000); //window001
	g_Object[379] = CreateObject(19466, 1790.6634, -1695.3171, 15.0828, 0.0000, 0.0000, -90.0000); //window001
	g_Object[380] = CreateObject(19466, 1790.6634, -1695.3171, 13.1527, 0.0000, 0.0000, -90.0000); //window001
	g_Object[381] = CreateObject(19565, 1776.4007, -1695.4172, 19.5386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[381], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[382] = CreateObject(19565, 1776.4007, -1695.4172, 19.3286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[382], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[383] = CreateObject(19565, 1776.4007, -1695.4172, 19.1086, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[383], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[384] = CreateObject(19565, 1776.4007, -1695.4172, 18.8686, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[384], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[385] = CreateObject(19565, 1776.4007, -1695.4172, 18.5986, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[385], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[386] = CreateObject(19565, 1775.9603, -1695.4172, 20.0386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[386], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[387] = CreateObject(19565, 1776.4307, -1695.4172, 20.0386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[387], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[388] = CreateObject(19565, 1776.8812, -1695.4172, 20.0386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[388], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[389] = CreateObject(19565, 1777.3316, -1695.4172, 20.0386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[389], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[390] = CreateObject(19565, 1777.7620, -1695.4172, 20.0386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[390], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[391] = CreateObject(19565, 1777.7220, -1695.4672, 19.9886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[391], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[392] = CreateObject(19565, 1777.7220, -1695.4672, 19.7386, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[392], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[393] = CreateObject(19565, 1777.7220, -1695.4672, 19.4886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[393], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[394] = CreateObject(19565, 1777.7220, -1695.4672, 19.2186, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[394], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[395] = CreateObject(19565, 1777.7220, -1695.4672, 18.9486, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[395], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[396] = CreateObject(19565, 1777.7220, -1695.4672, 18.6986, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[396], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[397] = CreateObject(19565, 1777.7220, -1695.4672, 18.4086, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[397], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[398] = CreateObject(19565, 1777.2615, -1695.4672, 18.4086, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[398], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[399] = CreateObject(19565, 1776.8013, -1695.4672, 18.4086, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[399], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[400] = CreateObject(19565, 1776.3509, -1695.4672, 18.4086, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[400], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[401] = CreateObject(19565, 1776.0106, -1695.4672, 18.4086, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[401], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[402] = CreateObject(19565, 1776.0106, -1695.4672, 18.6486, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[402], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[403] = CreateObject(19565, 1776.0106, -1695.4672, 18.8886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[403], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[404] = CreateObject(19565, 1776.0106, -1695.4672, 19.0986, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[404], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[405] = CreateObject(19565, 1776.0106, -1695.4672, 19.3186, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[405], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[406] = CreateObject(19565, 1776.0106, -1695.4672, 19.5586, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[406], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[407] = CreateObject(19565, 1776.0106, -1695.4672, 19.7886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[407], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[408] = CreateObject(19565, 1776.0106, -1695.4672, 19.9886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[408], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[409] = CreateObject(19565, 1776.4710, -1695.4672, 19.9886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[409], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[410] = CreateObject(19565, 1776.9215, -1695.4672, 19.9886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[410], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[411] = CreateObject(19565, 1777.2818, -1695.4672, 19.9886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[411], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[412] = CreateObject(19565, 1777.2818, -1695.4672, 19.7286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[412], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[413] = CreateObject(19565, 1777.2818, -1695.4672, 19.4686, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[413], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[414] = CreateObject(19565, 1777.2818, -1695.4672, 19.1986, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[414], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[415] = CreateObject(19565, 1777.2818, -1695.4672, 18.9186, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[415], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[416] = CreateObject(19565, 1777.2818, -1695.4672, 18.6686, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[416], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[417] = CreateObject(19565, 1776.8314, -1695.4672, 18.6686, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[417], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[418] = CreateObject(19565, 1776.8314, -1695.4672, 18.9286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[418], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[419] = CreateObject(19565, 1776.8314, -1695.4672, 19.1786, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[419], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[420] = CreateObject(19565, 1776.8314, -1695.4672, 19.4286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[420], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[421] = CreateObject(19565, 1776.8314, -1695.4672, 19.6786, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[421], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[422] = CreateObject(19565, 1776.8314, -1695.4672, 19.8286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[422], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[423] = CreateObject(19565, 1776.4212, -1695.4672, 19.8286, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[423], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[424] = CreateObject(19565, 1776.4212, -1695.4672, 19.5886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[424], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[425] = CreateObject(19565, 1776.4212, -1695.4672, 19.3086, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[425], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[426] = CreateObject(19565, 1776.4212, -1695.4672, 19.0486, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[426], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[427] = CreateObject(19565, 1776.4212, -1695.4672, 18.7886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[427], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[428] = CreateObject(19565, 1776.4212, -1695.4672, 18.5886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[428], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[429] = CreateObject(19565, 1777.7222, -1695.4672, 18.5886, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[429], 0, 10765, "airportgnd_sfse", "white", 0xFF15426C);
	g_Object[430] = CreateObject(19362, 1809.2166, -1698.9288, 10.8103, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[430], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[431] = CreateObject(19362, 1809.2166, -1701.5694, 10.8103, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[431], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[432] = CreateObject(19362, 1809.2166, -1704.1704, 10.8103, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[432], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[433] = CreateObject(19362, 1809.2166, -1707.0010, 10.8103, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[433], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[434] = CreateObject(1622, 1763.8173, -1686.3388, 19.0653, 5.0000, -15.4000, 119.7998); //nt_securecam2_01
	g_Object[435] = CreateObject(1622, 1763.4776, -1695.8552, 19.2337, 5.0000, -15.4000, 99.4999); //nt_securecam2_01
	g_Object[436] = CreateObject(1622, 1790.8626, -1685.4239, 18.5040, 5.0000, -15.4000, -51.9999); //nt_securecam2_01
	g_Object[437] = CreateObject(1622, 1799.9038, -1695.8137, 17.5392, 8.1000, -14.6000, 62.8000); //nt_securecam2_01
	g_Object[438] = CreateObject(19565, 1764.9125, -1695.4132, 18.7811, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[438], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[439] = CreateObject(19565, 1764.9125, -1695.4132, 18.9311, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[439], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[440] = CreateObject(19565, 1765.3530, -1695.4132, 18.7811, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[440], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[441] = CreateObject(19565, 1765.3530, -1695.4132, 18.9311, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[441], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[442] = CreateObject(19565, 1766.2332, -1695.4132, 18.9311, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[442], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[443] = CreateObject(19565, 1766.2332, -1695.4132, 18.7711, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[443], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[444] = CreateObject(19565, 1766.6835, -1695.4132, 18.7711, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[444], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[445] = CreateObject(19565, 1766.6835, -1695.4132, 18.9311, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[445], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[446] = CreateObject(19565, 1767.5543, -1695.4132, 18.9311, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[446], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[447] = CreateObject(19565, 1767.5543, -1695.4132, 18.7611, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[447], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[448] = CreateObject(19565, 1768.0047, -1695.4132, 18.7611, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[448], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[449] = CreateObject(19565, 1768.0047, -1695.4132, 18.9311, 0.0000, 0.0000, 0.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[449], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF103250);
	g_Object[450] = CreateObject(19327, 1765.8753, -1695.4597, 18.4588, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[450], "Benzin: 0 99", 0, 90, "Arial", 19, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[451] = CreateObject(19327, 1768.5578, -1695.4597, 18.4588, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[451], "Diesel: 1 48", 0, 90, "Arial", 19, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[452] = CreateObject(19565, 1796.2111, -1722.7775, 14.6025, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[452], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[453] = CreateObject(19327, 1767.2266, -1695.4597, 18.4588, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[453], "Super: 2 59", 0, 90, "Arial", 19, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[454] = CreateObject(19565, 1796.2111, -1722.3179, 14.6025, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[454], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[455] = CreateObject(19565, 1796.2111, -1723.2276, 14.6025, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[455], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[456] = CreateObject(19565, 1796.2111, -1723.2276, 14.8125, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[456], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[457] = CreateObject(19565, 1796.2111, -1723.2276, 15.0425, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[457], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[458] = CreateObject(19565, 1796.2111, -1723.2276, 15.2825, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[458], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[459] = CreateObject(19565, 1796.2111, -1723.2276, 15.5025, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[459], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[460] = CreateObject(19565, 1796.2111, -1723.2276, 15.7225, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[460], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[461] = CreateObject(19565, 1796.2111, -1723.2276, 15.9325, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[461], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[462] = CreateObject(19565, 1796.2111, -1722.7673, 15.9325, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[462], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[463] = CreateObject(19565, 1796.2111, -1722.3168, 15.9325, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[463], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[464] = CreateObject(19565, 1796.2111, -1722.3168, 15.6825, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[464], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[465] = CreateObject(19565, 1796.2111, -1722.7772, 15.6825, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[465], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[466] = CreateObject(19565, 1796.2111, -1722.7772, 15.4125, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[466], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[467] = CreateObject(19565, 1796.2111, -1722.7772, 15.1625, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[467], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[468] = CreateObject(19565, 1796.2111, -1722.7772, 14.9325, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[468], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[469] = CreateObject(19565, 1796.2111, -1722.7772, 14.7325, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[469], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[470] = CreateObject(19565, 1796.2111, -1722.3067, 14.8025, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[470], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[471] = CreateObject(19565, 1796.2111, -1722.3067, 15.0125, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[471], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[472] = CreateObject(19565, 1796.2111, -1722.3067, 15.2125, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[472], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[473] = CreateObject(19565, 1796.2111, -1722.3067, 15.4525, 0.0000, 0.0000, 90.0000); //IceCreamBarsBox1
	SetObjectMaterial(g_Object[473], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF15426C);
	g_Object[474] = CreateObject(19327, 1796.2781, -1722.1414, 14.5566, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[474], "Super: 2.44", 0, 90, "Arial", 24, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[475] = CreateObject(19327, 1796.2781, -1722.1414, 15.2766, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[475], "Benzin: 0.99", 0, 90, "Arial", 24, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[476] = CreateObject(19327, 1796.2781, -1722.1414, 14.9066, 0.0000, 0.0000, 90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[476], "Diesel: 1.48", 0, 90, "Arial", 24, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[477] = CreateObject(19327, 1796.1584, -1723.4221, 14.5766, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[477], "Super: 2.44", 0, 90, "Arial", 24, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[478] = CreateObject(2942, 1791.0749, -1695.7684, 13.1757, 0.0000, 0.0000, 0.0000); //kmb_atm1
	SetObjectMaterial(g_Object[478], 0, 2942, "kmb_atmx", "kmb_atm", 0xFFFFFFFF);
	g_Object[479] = CreateObject(19327, 1796.1584, -1723.4221, 14.9666, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[479], "Diesel: 1.48", 0, 90, "Arial", 24, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[480] = CreateObject(19327, 1796.1584, -1723.4221, 15.3266, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[480], "Benzin: 0 99", 0, 90, "Arial", 24, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[0] = CreateObject(19377, 2522.1325, -2128.4392, 14.2089, 0.0000, 0.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[0], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[1] = CreateObject(19325, 2518.8432, -2114.1394, 14.1314, 0.0000, 0.0000, 90.0000); //lsmall_window01
	g_Object[2] = CreateObject(19377, 2517.4084, -2133.3017, 14.2089, 0.0000, 0.0000, -90.0000); //wall025
	SetObjectMaterial(g_Object[2], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[3] = CreateObject(19377, 2507.7775, -2133.3017, 14.2089, 0.0000, 0.0000, -90.0000); //wall025
	SetObjectMaterial(g_Object[3], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[4] = CreateObject(19377, 2498.1870, -2133.3017, 14.2089, 0.0000, 0.0000, -90.0000); //wall025
	SetObjectMaterial(g_Object[4], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[5] = CreateObject(19377, 2488.5654, -2133.3017, 14.2089, 0.0000, 0.0000, -90.0000); //wall025
	SetObjectMaterial(g_Object[5], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[6] = CreateObject(19377, 2478.9536, -2133.3017, 14.2089, 0.0000, 0.0000, -90.0000); //wall025
	SetObjectMaterial(g_Object[6], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[7] = CreateObject(19377, 2474.2204, -2128.4406, 14.2089, 0.0000, 0.0000, -180.0000); //wall025
	SetObjectMaterial(g_Object[7], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[8] = CreateObject(19377, 2474.2104, -2118.8303, 14.2089, 0.0000, 0.0000, -180.0000); //wall025
	SetObjectMaterial(g_Object[8], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[9] = CreateObject(19446, 2507.7805, -2114.0981, 17.7112, 0.0000, 0.0000, -90.0000); //wall086
	SetObjectMaterial(g_Object[9], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[10] = CreateObject(19446, 2517.4008, -2114.0981, 17.7112, 0.0000, 0.0000, -90.0000); //wall086
	SetObjectMaterial(g_Object[10], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[11] = CreateObject(19446, 2498.1594, -2114.0981, 17.7112, 0.0000, 0.0000, -90.0000); //wall086
	SetObjectMaterial(g_Object[11], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[12] = CreateObject(19446, 2488.5397, -2114.0981, 17.7112, 0.0000, 0.0000, -90.0000); //wall086
	SetObjectMaterial(g_Object[12], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[13] = CreateObject(19446, 2478.9475, -2114.0981, 17.7112, 0.0000, 0.0000, -90.0000); //wall086
	SetObjectMaterial(g_Object[13], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[14] = CreateObject(19377, 2516.9306, -2118.8269, 19.3691, 0.0000, -90.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[14], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF96918C);
	g_Object[15] = CreateObject(11008, 2449.3576, -2124.2734, 19.4057, 0.0000, 0.0000, 90.0000); //firehouse_SFS
	SetObjectMaterial(g_Object[15], 0, 1569, "adam_v_doort", "ws_guardhousedoor", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[15], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	SetObjectMaterial(g_Object[15], 4, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	SetObjectMaterial(g_Object[15], 5, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[15], 6, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[16] = CreateObject(19426, 2516.0512, -2114.0971, 14.2370, 0.0000, 0.0000, -90.0000); //wall066
	SetObjectMaterial(g_Object[16], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[17] = CreateObject(19325, 2512.9345, -2114.1394, 14.1314, 0.0000, 0.0000, 90.0000); //lsmall_window01
	g_Object[18] = CreateObject(19426, 2508.8398, -2114.0971, 14.2370, 0.0000, 0.0000, -90.0000); //wall066
	SetObjectMaterial(g_Object[18], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[19] = CreateObject(19325, 2505.4641, -2114.1394, 14.1314, 0.0000, 0.0000, 90.0000); //lsmall_window01
	g_Object[20] = CreateObject(19426, 2501.5688, -2114.0971, 14.2370, 0.0000, 0.0000, -90.0000); //wall066
	SetObjectMaterial(g_Object[20], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[21] = CreateObject(19325, 2498.2421, -2114.1394, 14.1314, 0.0000, 0.0000, 90.0000); //lsmall_window01
	g_Object[22] = CreateObject(19426, 2494.2153, -2114.0971, 14.2370, 0.0000, 0.0000, -90.0000); //wall066
	SetObjectMaterial(g_Object[22], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[23] = CreateObject(19325, 2490.7421, -2114.1394, 14.1314, 0.0000, 0.0000, 90.0000); //lsmall_window01
	g_Object[24] = CreateObject(19426, 2486.8027, -2114.0971, 14.2370, 0.0000, 0.0000, -90.0000); //wall066
	SetObjectMaterial(g_Object[24], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[25] = CreateObject(19325, 2483.5927, -2114.1394, 14.1314, 0.0000, 0.0000, 90.0000); //lsmall_window01
	g_Object[26] = CreateObject(19426, 2480.0314, -2114.0971, 14.2370, 0.0000, 0.0000, -90.0000); //wall066
	SetObjectMaterial(g_Object[26], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[27] = CreateObject(19325, 2477.4714, -2114.1394, 14.1314, 0.0000, 0.0000, 90.0000); //lsmall_window01
	g_Object[28] = CreateObject(19362, 2517.7416, -2111.9521, 19.3840, 0.0000, 90.5998, 90.3000); //wall010
	g_Object[29] = CreateObject(19377, 2522.1325, -2118.8271, 14.2089, 0.0000, 0.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[29], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[30] = CreateObject(19377, 2516.9306, -2128.4311, 19.3691, 0.0000, -90.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[30], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF96918C);
	g_Object[31] = CreateObject(19377, 2506.4821, -2128.4311, 19.3691, 0.0000, -90.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[31], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF96918C);
	g_Object[32] = CreateObject(19377, 2506.4787, -2118.8269, 19.3691, 0.0000, -90.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[32], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF96918C);
	g_Object[33] = CreateObject(19377, 2495.9909, -2118.8269, 19.3691, 0.0000, -90.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[33], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF96918C);
	g_Object[34] = CreateObject(19377, 2495.9990, -2128.4311, 19.3691, 0.0000, -90.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[34], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF96918C);
	g_Object[35] = CreateObject(19377, 2485.5270, -2128.4311, 19.3691, 0.0000, -90.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[35], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF96918C);
	g_Object[36] = CreateObject(19377, 2485.5095, -2118.8269, 19.3691, 0.0000, -90.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[36], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF96918C);
	g_Object[37] = CreateObject(19377, 2479.4978, -2118.8269, 19.3791, -0.0996, -90.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[37], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF96918C);
	g_Object[38] = CreateObject(19377, 2479.4978, -2128.3942, 19.3857, -0.0996, -90.0000, 0.0000); //wall025
	SetObjectMaterial(g_Object[38], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFF96918C);
	g_Object[39] = CreateObject(18075, 2514.2902, -2124.8786, 19.2360, 0.0000, 0.0000, 0.0000); //lightD
	g_Object[40] = CreateObject(18075, 2503.9702, -2124.8786, 19.2360, 0.0000, 0.0000, 0.0000); //lightD
	g_Object[41] = CreateObject(18075, 2493.3466, -2124.8786, 19.2360, 0.0000, 0.0000, 0.0000); //lightD
	g_Object[42] = CreateObject(18075, 2482.9443, -2124.8786, 19.2360, 0.0000, 0.0000, 0.0000); //lightD
	g_Object[43] = CreateObject(19377, 2454.0405, -2134.9018, 14.2089, 0.0000, 0.0000, -90.0000); //wall025
	SetObjectMaterial(g_Object[43], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[44] = CreateObject(19377, 2444.5104, -2134.9018, 14.2089, 0.0000, 0.0000, -90.0000); //wall025
	SetObjectMaterial(g_Object[44], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[45] = CreateObject(19377, 2437.2985, -2134.9018, 14.2089, 0.0000, 0.0000, -90.0000); //wall025
	SetObjectMaterial(g_Object[45], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[46] = CreateObject(19377, 2437.1284, -2113.1481, 14.2089, 0.0000, 0.0000, -90.0000); //wall025
	SetObjectMaterial(g_Object[46], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[47] = CreateObject(19377, 2446.7082, -2113.1481, 14.2089, 0.0000, 0.0000, -90.0000); //wall025
	SetObjectMaterial(g_Object[47], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[48] = CreateObject(19377, 2456.2438, -2113.1481, 14.2089, 0.0000, 0.0000, -90.0000); //wall025
	SetObjectMaterial(g_Object[48], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[49] = CreateObject(1508, 2458.3769, -2134.9443, 13.8809, 0.0000, 0.0000, -90.0000); //DYN_GARAGE_DOOR
	SetObjectMaterial(g_Object[49], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[50] = CreateObject(1569, 2461.5244, -2134.8937, 12.9224, 0.0000, 0.0000, 0.0000); //ADAM_V_DOOR
	g_Object[51] = CreateObject(1508, 2463.4082, -2134.9343, 13.8809, 0.0000, 0.0000, -90.0000); //DYN_GARAGE_DOOR
	SetObjectMaterial(g_Object[51], 0, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[52] = CreateObject(19362, 2450.6596, -2113.1467, 17.8843, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[52], 0, 17533, "eastbeach7_lae2", "shopwindowlow2_256", 0xFFFFFFFF);
	g_Object[53] = CreateObject(19362, 2436.1938, -2134.9157, 21.0543, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[53], 0, 17533, "eastbeach7_lae2", "shopwindowlow2_256", 0xFFFFFFFF);
	g_Object[54] = CreateObject(19362, 2439.4282, -2113.1467, 17.8843, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[54], 0, 17533, "eastbeach7_lae2", "shopwindowlow2_256", 0xFFFFFFFF);
	g_Object[55] = CreateObject(19362, 2453.6860, -2134.9157, 21.0543, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[55], 0, 17533, "eastbeach7_lae2", "shopwindowlow2_256", 0xFFFFFFFF);
	g_Object[56] = CreateObject(19362, 2445.2441, -2134.9157, 21.0543, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[56], 0, 17533, "eastbeach7_lae2", "shopwindowlow2_256", 0xFFFFFFFF);
	g_Object[57] = CreateObject(19327, 2447.9799, -2112.6279, 21.6625, 0.0000, 0.0000, -180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[57], "LOS", 0, 90, "Arial", 70, 0, 0xFFFFFFFF, 0x0, 0);
	g_Object[58] = CreateObject(19327, 2443.4575, -2112.6279, 21.6625, 0.0000, 0.0000, -180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[58], "FIRE", 0, 90, "Arial", 70, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[59] = CreateObject(19327, 2446.5720, -2112.6279, 21.6625, 0.0000, 0.0000, -180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[59], "SANTOS", 0, 90, "Arial", 71, 0, 0xFFFFFFFF, 0x0, 0);
	g_Object[60] = CreateObject(19327, 2441.8659, -2112.6279, 21.6625, 0.0000, 0.0000, -180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[60], "DEP.", 0, 90, "Arial", 70, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[61] = CreateObject(19377, 2512.5229, -2079.6381, 12.4889, 0.0000, 90.0000, -180.0000); //wall025
	SetObjectMaterial(g_Object[61], 0, 16640, "a51", "plaintarmac1", 0xFFFFFFFF);
	g_Object[62] = CreateObject(19327, 2461.6635, -2112.9340, 16.1772, 0.0000, -4.3000, -180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[62], "Eingang", 0, 90, "Arial", 50, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[63] = CreateObject(19377, 2512.5229, -2070.1635, 12.4687, 0.0000, 90.0000, -180.0000); //wall025
	SetObjectMaterial(g_Object[63], 0, 16640, "a51", "plaintarmac1", 0xFFFFFFFF);
	g_Object[64] = CreateObject(19377, 2533.4670, -2070.1635, 12.4687, 0.0000, 90.0000, -180.0000); //wall025
	SetObjectMaterial(g_Object[64], 0, 16640, "a51", "plaintarmac1", 0xFFFFFFFF);
	g_Object[65] = CreateObject(19377, 2522.9948, -2079.6381, 12.4787, 0.0000, 90.0000, -180.0000); //wall025
	SetObjectMaterial(g_Object[65], 0, 16640, "a51", "plaintarmac1", 0xFFFFFFFF);
	g_Object[66] = CreateObject(19377, 2533.4682, -2079.6381, 12.4787, 0.0000, 90.0000, -180.0000); //wall025
	SetObjectMaterial(g_Object[66], 0, 16640, "a51", "plaintarmac1", 0xFFFFFFFF);
	g_Object[67] = CreateObject(2114, 2502.6887, -2076.2358, 12.7075, 0.0000, 0.0000, 0.0000); //basketball
	g_Object[68] = CreateObject(19377, 2522.9943, -2070.1635, 12.4687, 0.0000, 90.0000, -180.0000); //wall025
	SetObjectMaterial(g_Object[68], 0, 16640, "a51", "plaintarmac1", 0xFFFFFFFF);
	g_Object[69] = CreateObject(970, 2494.7089, -2068.4389, 13.0652, 0.0000, 0.0000, 0.0000); //fencesmallb
	g_Object[70] = CreateObject(967, 2424.6635, -2082.0556, 12.5176, 0.0000, 0.0000, 180.0000); //bar_gatebox01
	g_Object[71] = CreateObject(19313, 2517.8110, -2084.3903, 12.5523, 0.0000, 0.0000, 0.0000); //a51fensin
	g_Object[72] = CreateObject(19313, 2531.7436, -2084.3903, 12.5523, 0.0000, 0.0000, 0.0000); //a51fensin
	g_Object[73] = CreateObject(19313, 2538.6530, -2077.3605, 12.5523, 0.0000, 0.0000, 90.0000); //a51fensin
	g_Object[74] = CreateObject(19313, 2496.8889, -2077.3605, 12.5523, 0.0000, 0.0000, 90.0000); //a51fensin
	g_Object[75] = CreateObject(738, 2428.7805, -2083.6569, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[76] = CreateObject(738, 2428.7805, -2095.2077, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[77] = CreateObject(738, 2439.5739, -2083.6569, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[78] = CreateObject(738, 2449.6767, -2083.6569, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[79] = CreateObject(738, 2458.3889, -2083.6569, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[80] = CreateObject(738, 2467.3007, -2083.6569, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[81] = CreateObject(738, 2462.3972, -2095.2270, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[82] = CreateObject(19362, 2432.3901, -2118.7521, 21.0743, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[82], 0, 17533, "eastbeach7_lae2", "shopwindowlow2_256", 0xFFFFFFFF);
	g_Object[83] = CreateObject(19362, 2432.3901, -2130.1218, 21.0743, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[83], 0, 17533, "eastbeach7_lae2", "shopwindowlow2_256", 0xFFFFFFFF);
	g_Object[84] = CreateObject(19446, 2442.6445, -2103.5683, 12.4610, 0.0000, 90.0000, 180.0000); //wall086
	SetObjectMaterial(g_Object[84], 0, 4829, "airport_las", "Grass_128HV", 0xFFFFFFFF);
	g_Object[85] = CreateObject(19446, 2439.1643, -2103.5683, 12.4610, 0.0000, 90.0000, 180.0000); //wall086
	SetObjectMaterial(g_Object[85], 0, 4829, "airport_las", "Grass_128HV", 0xFFFFFFFF);
	g_Object[86] = CreateObject(19446, 2446.1350, -2103.5683, 12.4610, 0.0000, 90.0000, 180.0000); //wall086
	SetObjectMaterial(g_Object[86], 0, 4829, "airport_las", "Grass_128HV", 0xFFFFFFFF);
	g_Object[87] = CreateObject(19446, 2449.6166, -2103.5683, 12.4610, 0.0000, 90.0000, 180.0000); //wall086
	SetObjectMaterial(g_Object[87], 0, 4829, "airport_las", "Grass_128HV", 0xFFFFFFFF);
	g_Object[88] = CreateObject(19446, 2453.1062, -2103.5683, 12.4610, 0.0000, 90.0000, 180.0000); //wall086
	SetObjectMaterial(g_Object[88], 0, 4829, "airport_las", "Grass_128HV", 0xFFFFFFFF);
	g_Object[89] = CreateObject(19446, 2456.5874, -2103.5683, 12.4610, 0.0000, 90.0000, 180.0000); //wall086
	SetObjectMaterial(g_Object[89], 0, 4829, "airport_las", "Grass_128HV", 0xFFFFFFFF);
	g_Object[90] = CreateObject(1226, 2432.4592, -2093.8388, 16.4050, 0.0000, 0.0000, -90.0000); //lamppost3
	g_Object[91] = CreateObject(11453, 2447.8642, -2103.6799, 13.2466, 13.2999, 0.0000, 0.0000); //des_sherrifsgn1
	SetObjectMaterial(g_Object[91], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	g_Object[92] = CreateObject(638, 2437.7607, -2100.1059, 13.2355, 0.0000, 0.0000, 0.0000); //kb_planter+bush
	g_Object[93] = CreateObject(638, 2437.7607, -2107.0578, 13.2355, 0.0000, 0.0000, 0.0000); //kb_planter+bush
	g_Object[94] = CreateObject(638, 2437.7607, -2103.6672, 13.2355, 0.0000, 0.0000, 0.0000); //kb_planter+bush
	g_Object[95] = CreateObject(638, 2457.9604, -2103.6672, 13.2355, 0.0000, 0.0000, 0.0000); //kb_planter+bush
	g_Object[96] = CreateObject(638, 2457.9604, -2100.1044, 13.2355, 0.0000, 0.0000, 0.0000); //kb_planter+bush
	g_Object[97] = CreateObject(638, 2457.9604, -2107.0566, 13.2355, 0.0000, 0.0000, 0.0000); //kb_planter+bush
	g_Object[98] = CreateObject(640, 2454.3444, -2099.1179, 13.2389, 0.0000, 0.0000, -90.0000); //kb_planter+bush2
	g_Object[99] = CreateObject(640, 2441.3610, -2099.1179, 13.2389, 0.0000, 0.0000, -90.0000); //kb_planter+bush2
	g_Object[100] = CreateObject(640, 2441.3610, -2108.0266, 13.2389, 0.0000, 0.0000, -90.0000); //kb_planter+bush2
	g_Object[101] = CreateObject(640, 2454.3457, -2108.0266, 13.2389, 0.0000, 0.0000, -90.0000); //kb_planter+bush2
	g_Object[102] = CreateObject(970, 2433.3591, -2106.2167, 13.0705, 0.0000, 0.0000, -90.0000); //fencesmallb
	g_Object[103] = CreateObject(970, 2433.3591, -2102.0947, 13.0705, 0.0000, 0.0000, -90.0000); //fencesmallb
	g_Object[104] = CreateObject(970, 2433.3591, -2097.9731, 13.0705, 0.0000, 0.0000, -90.0000); //fencesmallb
	g_Object[105] = CreateObject(970, 2436.9226, -2095.8718, 13.0705, 0.0000, 0.0000, -180.0000); //fencesmallb
	g_Object[106] = CreateObject(970, 2441.0437, -2095.8718, 13.0705, 0.0000, 0.0000, -180.0000); //fencesmallb
	g_Object[107] = CreateObject(970, 2445.1640, -2095.8718, 13.0705, 0.0000, 0.0000, -180.0000); //fencesmallb
	g_Object[108] = CreateObject(970, 2449.2954, -2095.8718, 13.0705, 0.0000, 0.0000, -180.0000); //fencesmallb
	g_Object[109] = CreateObject(970, 2453.4177, -2095.8718, 13.0705, 0.0000, 0.0000, -180.0000); //fencesmallb
	g_Object[110] = CreateObject(970, 2457.5485, -2095.8718, 13.0705, 0.0000, 0.0000, -180.0000); //fencesmallb
	g_Object[111] = CreateObject(970, 2459.6196, -2099.2751, 13.0705, 0.0000, 0.0000, -90.0000); //fencesmallb
	g_Object[112] = CreateObject(970, 2459.6196, -2103.3955, 13.0705, 0.0000, 0.0000, -90.0000); //fencesmallb
	g_Object[113] = CreateObject(970, 2459.6196, -2107.5166, 13.0705, 0.0000, 0.0000, -90.0000); //fencesmallb
	g_Object[114] = CreateObject(970, 2457.5283, -2111.2966, 13.0705, 0.0000, 0.0000, 180.0000); //fencesmallb
	g_Object[115] = CreateObject(970, 2453.3969, -2111.2966, 13.0705, 0.0000, 0.0000, 180.0000); //fencesmallb
	g_Object[116] = CreateObject(970, 2449.2763, -2111.2966, 13.0705, 0.0000, 0.0000, 180.0000); //fencesmallb
	g_Object[117] = CreateObject(970, 2445.1547, -2111.2966, 13.0705, 0.0000, 0.0000, 180.0000); //fencesmallb
	g_Object[118] = CreateObject(970, 2441.0236, -2111.2966, 13.0705, 0.0000, 0.0000, 180.0000); //fencesmallb
	g_Object[119] = CreateObject(970, 2436.9030, -2111.2966, 13.0705, 0.0000, 0.0000, 180.0000); //fencesmallb
	g_Object[120] = CreateObject(1280, 2443.4846, -2110.7751, 12.9274, 0.0000, 0.0000, -90.0000); //parkbench1
	SetObjectMaterial(g_Object[120], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[120], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[121] = CreateObject(1280, 2438.5434, -2110.7751, 12.9274, 0.0000, 0.0000, -90.0000); //parkbench1
	SetObjectMaterial(g_Object[121], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[121], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[122] = CreateObject(1280, 2448.5441, -2110.7751, 12.9274, 0.0000, 0.0000, -90.0000); //parkbench1
	SetObjectMaterial(g_Object[122], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[122], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[123] = CreateObject(1280, 2453.5146, -2110.7751, 12.9274, 0.0000, 0.0000, -90.0000); //parkbench1
	SetObjectMaterial(g_Object[123], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[123], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[124] = CreateObject(1280, 2433.9638, -2106.0444, 12.9274, 0.0000, 0.0000, -180.0000); //parkbench1
	SetObjectMaterial(g_Object[124], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[124], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[125] = CreateObject(1280, 2433.9638, -2102.0319, 12.9274, 0.0000, 0.0000, -180.0000); //parkbench1
	SetObjectMaterial(g_Object[125], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[125], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[126] = CreateObject(1280, 2433.9638, -2098.2612, 12.9274, 0.0000, 0.0000, -180.0000); //parkbench1
	SetObjectMaterial(g_Object[126], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[126], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[127] = CreateObject(1280, 2437.6245, -2096.4799, 12.9274, 0.0000, 0.0000, 90.0000); //parkbench1
	SetObjectMaterial(g_Object[127], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[127], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[128] = CreateObject(1280, 2441.9658, -2096.4799, 12.9274, 0.0000, 0.0000, 90.0000); //parkbench1
	SetObjectMaterial(g_Object[128], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[128], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[129] = CreateObject(1280, 2446.2377, -2096.4799, 12.9274, 0.0000, 0.0000, 90.0000); //parkbench1
	SetObjectMaterial(g_Object[129], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[129], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[130] = CreateObject(1280, 2450.6286, -2096.4799, 12.9274, 0.0000, 0.0000, 90.0000); //parkbench1
	SetObjectMaterial(g_Object[130], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[130], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[131] = CreateObject(1280, 2455.0397, -2096.4799, 12.9274, 0.0000, 0.0000, 90.0000); //parkbench1
	SetObjectMaterial(g_Object[131], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[131], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[132] = CreateObject(869, 2440.8469, -2101.6437, 12.9657, 0.0000, 0.0000, 0.0000); //veg_Pflowerswee
	g_Object[133] = CreateObject(869, 2454.8168, -2105.1154, 12.9657, 0.0000, 0.0000, 0.0000); //veg_Pflowerswee
	g_Object[134] = CreateObject(817, 2449.9387, -2100.6582, 12.9770, 0.0000, 0.0000, 0.0000); //veg_Pflowers01
	g_Object[135] = CreateObject(817, 2446.3256, -2100.2731, 12.9770, 0.0000, 0.0000, -76.4999); //veg_Pflowers01
	g_Object[136] = CreateObject(870, 2440.7651, -2104.9091, 12.7763, 0.0000, 0.0000, 0.0000); //veg_Pflowers2wee
	g_Object[137] = CreateObject(870, 2454.6770, -2101.4189, 12.7763, 0.0000, 0.0000, 0.0000); //veg_Pflowers2wee
	g_Object[138] = CreateObject(869, 2447.7182, -2105.8518, 12.9713, 0.0000, 0.0000, 0.0000); //veg_Pflowerswee
	g_Object[139] = CreateObject(19327, 2447.8068, -2103.4208, 13.0762, -13.7999, -0.0997, 180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[139], "FIRE DEPARTMENT", 0, 90, "Arial", 31, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[140] = CreateObject(19327, 2519.2055, -2113.9863, 16.2210, 0.0000, 0.0000, 180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[140], "GATE 01", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[141] = CreateObject(19327, 2447.5371, -2103.3510, 12.7952, -13.7999, -0.0997, 180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[141], "LOS SANTOS", 0, 90, "Arial", 35, 0, 0xFFFFFFFF, 0x0, 0);
	g_Object[142] = CreateObject(750, 2454.2077, -2103.6928, 12.5745, 0.0000, 0.0000, 0.0000); //sm_scrb_column2
	g_Object[143] = CreateObject(19327, 2512.1645, -2113.9863, 16.2210, 0.0000, 0.0000, 180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[143], "GATE 02", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[144] = CreateObject(19327, 2504.9626, -2113.9863, 16.2210, 0.0000, 0.0000, 180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[144], "GATE 03", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[145] = CreateObject(19327, 2497.6489, -2113.9863, 16.2210, 0.0000, 0.0000, 180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[145], "GATE 04", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[146] = CreateObject(19327, 2490.3256, -2113.9863, 16.2210, 0.0000, 0.0000, 180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[146], "GATE 05", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[147] = CreateObject(19327, 2483.2136, -2113.9863, 16.2210, 0.0000, 0.0000, 180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[147], "GATE 06", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[148] = CreateObject(19327, 2476.3503, -2113.9863, 16.2210, 0.0000, 0.0000, 180.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[148], "GATE 07", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[149] = CreateObject(751, 2441.0712, -2103.1860, 12.2089, 0.0000, 0.0000, 0.0000); //sm_scrb_column1
	g_Object[150] = CreateObject(738, 2471.2180, -2095.2270, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[151] = CreateObject(19313, 2503.8403, -2084.3903, 12.5523, 0.0000, 0.0000, 0.0000); //a51fensin
	g_Object[152] = CreateObject(738, 2474.9819, -2083.6569, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[153] = CreateObject(738, 2481.9316, -2083.6569, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[154] = CreateObject(738, 2489.2939, -2083.6569, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[155] = CreateObject(1280, 2504.5764, -2083.7558, 12.9274, 0.0000, 0.0000, -90.0000); //parkbench1
	SetObjectMaterial(g_Object[155], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[155], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[156] = CreateObject(19279, 2445.9135, -2101.9614, 12.7545, 0.0000, 0.0000, -162.9998); //LCSmallLight1
	SetObjectMaterial(g_Object[156], 0, 16640, "a51", "ws_metalpanel1", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[156], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF9F9D94);
	g_Object[157] = CreateObject(19279, 2449.9953, -2102.2629, 12.7587, 0.3998, 0.0000, 141.7998); //LCSmallLight1
	SetObjectMaterial(g_Object[157], 0, 16640, "a51", "ws_metalpanel1", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[157], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF9F9D94);
	g_Object[158] = CreateObject(1226, 2432.4592, -2085.1870, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[159] = CreateObject(1226, 2444.8718, -2085.1870, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[160] = CreateObject(1226, 2463.2951, -2085.1870, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[161] = CreateObject(1226, 2471.4887, -2085.1870, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[162] = CreateObject(1226, 2478.8688, -2085.1870, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[163] = CreateObject(1226, 2486.0197, -2085.1870, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[164] = CreateObject(1226, 2493.7517, -2085.1870, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[165] = CreateObject(1226, 2500.9726, -2082.7561, 16.4050, 0.0000, 0.0000, -90.0000); //lamppost3
	g_Object[166] = CreateObject(1226, 2508.4140, -2082.7561, 16.4050, 0.0000, 0.0000, -90.0000); //lamppost3
	g_Object[167] = CreateObject(1226, 2515.5749, -2082.7561, 16.4050, 0.0000, 0.0000, -90.0000); //lamppost3
	g_Object[168] = CreateObject(1226, 2522.3566, -2082.7561, 16.4050, 0.0000, 0.0000, -90.0000); //lamppost3
	g_Object[169] = CreateObject(1226, 2529.4685, -2082.7561, 16.4050, 0.0000, 0.0000, -90.0000); //lamppost3
	g_Object[170] = CreateObject(738, 2479.8112, -2095.2270, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[171] = CreateObject(738, 2487.4262, -2095.2270, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[172] = CreateObject(738, 2494.7800, -2095.2270, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[173] = CreateObject(738, 2501.6523, -2095.2270, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[174] = CreateObject(738, 2509.3046, -2095.2270, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[175] = CreateObject(738, 2516.9172, -2095.2270, 12.9420, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[176] = CreateObject(738, 2529.6225, -2095.2270, 12.9519, 0.0000, 0.0000, 0.0000); //aw_streettree2
	g_Object[177] = CreateObject(19279, 2447.9682, -2101.5590, 12.7545, 0.3998, 0.0000, 179.3999); //LCSmallLight1
	SetObjectMaterial(g_Object[177], 0, 16640, "a51", "ws_metalpanel1", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[177], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF9F9D94);
	g_Object[178] = CreateObject(1280, 2512.2353, -2083.7558, 12.9274, 0.0000, 0.0000, -90.0000); //parkbench1
	SetObjectMaterial(g_Object[178], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[178], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[179] = CreateObject(1280, 2519.0644, -2083.7558, 12.9274, 0.0000, 0.0000, -90.0000); //parkbench1
	SetObjectMaterial(g_Object[179], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[179], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[180] = CreateObject(1280, 2526.0856, -2083.7558, 12.9274, 0.0000, 0.0000, -90.0000); //parkbench1
	SetObjectMaterial(g_Object[180], 0, 1560, "7_11_door", "cj_sheetmetal2", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[180], 1, 14650, "ab_trukstpc", "sa_wood08_128", 0xFFFFFFFF);
	g_Object[181] = CreateObject(19313, 2540.8950, -2116.8461, 12.6323, 0.0000, 0.0000, -90.0000); //a51fensin
	SetObjectMaterial(g_Object[181], 0, 16322, "a51_stores", "fence_64", 0xFFFFFFFF);
	g_Object[182] = CreateObject(1226, 2444.5522, -2093.8388, 16.4050, 0.0000, 0.0000, -90.0000); //lamppost3
	g_Object[183] = CreateObject(1226, 2454.1645, -2093.8388, 16.4050, 0.0000, 0.0000, -90.0000); //lamppost3
	g_Object[184] = CreateObject(1226, 2466.6860, -2093.8388, 16.4050, 0.0000, 0.0000, -90.0000); //lamppost3
	g_Object[185] = CreateObject(19327, 2450.9162, -2085.3637, 14.7860, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[185], "P", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[186] = CreateObject(1233, 2450.9533, -2084.3425, 14.0726, 0.0000, 0.0000, -90.0000); //noparkingsign1
	SetObjectMaterial(g_Object[186], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF1E4C99);
	SetObjectMaterial(g_Object[186], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF223457);
	g_Object[187] = CreateObject(19327, 2450.9162, -2085.3137, 14.2159, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[187], "<<<", 0, 90, "Arial", 30, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[188] = CreateObject(19362, 2466.7026, -2068.9248, 10.8028, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[188], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[189] = CreateObject(19362, 2470.4995, -2068.9248, 10.8028, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[189], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[190] = CreateObject(19362, 2474.4301, -2068.9248, 10.8028, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[190], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[191] = CreateObject(1226, 2468.7280, -2116.1003, 16.4050, 0.0000, 0.0000, 180.0000); //lamppost3
	g_Object[192] = CreateObject(19362, 2443.3381, -2068.9248, 10.8028, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[192], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[193] = CreateObject(19362, 2447.2092, -2068.9248, 10.8028, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[193], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[194] = CreateObject(19362, 2451.0895, -2068.9248, 10.8028, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[194], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[195] = CreateObject(19362, 2455.1008, -2068.9248, 10.8028, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[195], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[196] = CreateObject(19362, 2459.0908, -2068.9248, 10.8028, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[196], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[197] = CreateObject(19362, 2462.9599, -2068.9248, 10.8028, 0.0000, 0.0000, 0.0000); //wall010
	SetObjectMaterial(g_Object[197], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[198] = CreateObject(1226, 2468.7280, -2124.8823, 16.4050, 0.0000, 0.0000, 180.0000); //lamppost3
	g_Object[199] = CreateObject(1226, 2468.7280, -2133.1335, 16.4050, 0.0000, 0.0000, 180.0000); //lamppost3
	g_Object[200] = CreateObject(19817, 2519.1892, -2119.4863, 11.6766, 0.0000, 0.0000, -180.0000); //CarFixerRamp1
	g_Object[201] = CreateObject(19899, 2520.1479, -2132.7153, 12.5012, 0.0000, 0.0000, 90.0000); //ToolCabinet1
	g_Object[202] = CreateObject(19900, 2517.1203, -2123.1198, 12.5355, 0.0000, 0.0000, 0.0000); //ToolCabinet2
	g_Object[203] = CreateObject(1025, 2521.8996, -2123.6716, 15.2558, 0.0000, 0.0000, 180.0000); //wheel_or1
	g_Object[204] = CreateObject(1025, 2521.8996, -2124.6623, 14.3758, 0.0000, 0.0000, 180.0000); //wheel_or1
	g_Object[205] = CreateObject(1025, 2521.8996, -2125.6032, 13.4558, 0.0000, 0.0000, 180.0000); //wheel_or1
	g_Object[206] = CreateObject(1689, 2511.8383, -2124.0610, 20.6415, 0.0000, 0.0000, 0.0000); //gen_roofbit3
	g_Object[207] = CreateObject(1689, 2482.1579, -2124.0610, 20.6415, 0.0000, 0.0000, 0.0000); //gen_roofbit3
	g_Object[208] = CreateObject(1366, 2527.1938, -2095.0966, 13.1583, 0.0000, 0.0000, 0.0000); //CJ_FIREHYDRANT
	g_Object[209] = CreateObject(11245, 2452.8789, -2112.2360, 21.5186, 0.0000, 0.0000, 90.0000); //sfsefirehseflag
	g_Object[210] = CreateObject(11245, 2437.4328, -2112.2360, 21.5186, 0.0000, 0.0000, 90.0000); //sfsefirehseflag
	g_Object[211] = CreateObject(19815, 2522.0388, -2129.6242, 14.1514, 0.0000, 0.0000, -90.0000); //ToolBoard1
	g_Object[212] = CreateObject(19921, 2517.2087, -2122.9323, 13.5043, 0.0000, 0.0000, 155.8999); //CutsceneToolBox1
	g_Object[213] = CreateObject(19903, 2517.0493, -2120.7233, 12.5390, 0.0000, 0.0000, 90.0000); //MechanicComputer1
	g_Object[214] = CreateObject(19893, 2517.1035, -2123.1679, 13.6007, 0.0000, 0.0000, 178.6999); //LaptopSAMP1
	SetObjectMaterial(g_Object[214], 1, 10101, "2notherbuildsfe", "ferry_build14", 0xFF515459);
	g_Object[215] = CreateObject(19872, 2519.1923, -2126.7900, 11.6801, 0.0000, 0.0000, 180.0000); //CarFixerRamp2
	g_Object[216] = CreateObject(2114, 2534.9936, -2077.1857, 12.7075, 0.0000, 0.0000, 0.0000); //basketball
	g_Object[217] = CreateObject(11711, 2462.2878, -2134.9362, 15.6989, 0.0000, 0.0000, 0.0000); //ExitSign1
	g_Object[218] = CreateObject(19966, 2430.1196, -2084.0861, 12.4786, 0.0000, 0.0000, 90.0000); //SAMPRoadSign19
	g_Object[219] = CreateObject(19983, 2425.6733, -2094.9067, 12.4581, 0.0000, 0.0000, -90.0000); //SAMPRoadSign36
	g_Object[220] = CreateObject(10829, 2431.2648, -2074.7429, 12.4856, 0.0000, 0.0000, 90.0000); //gatehouse1_SFSe
	SetObjectMaterial(g_Object[220], 0, 3292, "cxrf_payspray", "newindow4", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[220], 1, 16011, "des_ntown", "des_ntwndoor3", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[220], 2, 3820, "boxhses_sfsx", "stonewall_la", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[220], 3, 10101, "2notherbuildsfe", "Bow_Abpave_Gen", 0xFFFFFFFF);
	SetObjectMaterial(g_Object[220], 4, 10101, "2notherbuildsfe", "ferry_build14", 0xFFFFFFFF);
	g_Object[221] = CreateObject(19377, 2502.0617, -2070.1635, 12.4687, 0.0000, 90.0000, -180.0000); //wall025
	SetObjectMaterial(g_Object[221], 0, 16640, "a51", "plaintarmac1", 0xFFFFFFFF);
	g_Object[222] = CreateObject(1233, 2445.2727, -2066.6928, 14.0726, 0.0000, 0.0000, 0.0000); //noparkingsign1
	SetObjectMaterial(g_Object[222], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF1E4C99);
	SetObjectMaterial(g_Object[222], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF223457);
	g_Object[223] = CreateObject(1233, 2449.2749, -2066.6928, 14.0726, 0.0000, 0.0000, 0.0000); //noparkingsign1
	SetObjectMaterial(g_Object[223], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF1E4C99);
	SetObjectMaterial(g_Object[223], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF223457);
	g_Object[224] = CreateObject(1233, 2453.1162, -2066.6928, 14.0726, 0.0000, 0.0000, 0.0000); //noparkingsign1
	SetObjectMaterial(g_Object[224], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF1E4C99);
	SetObjectMaterial(g_Object[224], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF223457);
	g_Object[225] = CreateObject(1233, 2457.1586, -2066.6928, 14.0726, 0.0000, 0.0000, 0.0000); //noparkingsign1
	SetObjectMaterial(g_Object[225], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF1E4C99);
	SetObjectMaterial(g_Object[225], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF223457);
	g_Object[226] = CreateObject(1233, 2461.0895, -2066.6928, 14.0726, 0.0000, 0.0000, 0.0000); //noparkingsign1
	SetObjectMaterial(g_Object[226], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF1E4C99);
	SetObjectMaterial(g_Object[226], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF223457);
	g_Object[227] = CreateObject(1233, 2464.8508, -2066.6928, 14.0726, 0.0000, 0.0000, 0.0000); //noparkingsign1
	SetObjectMaterial(g_Object[227], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF1E4C99);
	SetObjectMaterial(g_Object[227], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF223457);
	g_Object[228] = CreateObject(1233, 2468.6628, -2066.6928, 14.0726, 0.0000, 0.0000, 0.0000); //noparkingsign1
	SetObjectMaterial(g_Object[228], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF1E4C99);
	SetObjectMaterial(g_Object[228], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF223457);
	g_Object[229] = CreateObject(1233, 2472.5864, -2066.6928, 14.0726, 0.0000, 0.0000, 0.0000); //noparkingsign1
	SetObjectMaterial(g_Object[229], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF1E4C99);
	SetObjectMaterial(g_Object[229], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF223457);
	g_Object[230] = CreateObject(19327, 2450.2956, -2066.7517, 14.7860, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[230], "P", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[231] = CreateObject(19327, 2446.2944, -2066.7517, 14.7860, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[231], "P", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[232] = CreateObject(19327, 2454.1269, -2066.7517, 14.7860, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[232], "P", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[233] = CreateObject(19327, 2458.1799, -2066.7517, 14.7860, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[233], "P", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[234] = CreateObject(19327, 2462.1108, -2066.7517, 14.7860, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[234], "P", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[235] = CreateObject(19327, 2465.8713, -2066.7517, 14.7860, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[235], "P", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[236] = CreateObject(19327, 2469.6833, -2066.7517, 14.7860, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[236], "P", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[237] = CreateObject(19327, 2473.6044, -2066.7517, 14.7860, 0.0000, 0.0000, 0.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[237], "P", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[238] = CreateObject(1215, 2492.3439, -2068.4616, 13.1003, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[239] = CreateObject(19446, 2482.3684, -2068.1679, 12.4710, 0.0000, 90.0000, -90.0000); //wall086
	SetObjectMaterial(g_Object[239], 0, 4829, "airport_las", "Grass_128HV", 0xFFFFFFFF);
	g_Object[240] = CreateObject(19446, 2482.3684, -2071.6291, 12.4710, 0.0000, 90.0000, -90.0000); //wall086
	SetObjectMaterial(g_Object[240], 0, 4829, "airport_las", "Grass_128HV", 0xFFFFFFFF);
	g_Object[241] = CreateObject(19446, 2482.3684, -2073.9011, 12.4811, 0.0000, 90.0000, -90.0000); //wall086
	SetObjectMaterial(g_Object[241], 0, 4829, "airport_las", "Grass_128HV", 0xFFFFFFFF);
	g_Object[242] = CreateObject(715, 2481.8774, -2069.3911, 20.9284, 0.0000, 0.0000, 145.8000); //veg_bevtree3
	g_Object[243] = CreateObject(869, 2482.5014, -2070.6540, 12.9863, 0.0000, 0.0000, 0.0000); //veg_Pflowerswee
	g_Object[244] = CreateObject(817, 2484.4609, -2068.0180, 12.9907, 0.0000, 0.0000, 0.0000); //veg_Pflowers01
	g_Object[245] = CreateObject(817, 2479.4877, -2073.0688, 12.9907, 0.0000, 0.0000, 0.0000); //veg_Pflowers01
	g_Object[246] = CreateObject(870, 2479.7055, -2068.4721, 12.7910, 0.0000, 0.0000, -26.7000); //veg_Pflowers2wee
	g_Object[247] = CreateObject(19831, 2483.2163, -2072.9279, 12.5531, 0.0000, 0.0000, 44.2999); //Barbeque1
	g_Object[248] = CreateObject(970, 2479.6323, -2075.6462, 13.0867, 0.0000, 0.0000, 0.0000); //fencesmallb
	g_Object[249] = CreateObject(970, 2485.1044, -2075.6462, 13.0867, 0.0000, 0.0000, 0.0000); //fencesmallb
	g_Object[250] = CreateObject(970, 2487.1762, -2073.5654, 13.0867, 0.0000, 0.0000, 90.0000); //fencesmallb
	g_Object[251] = CreateObject(970, 2487.1762, -2068.5134, 13.0867, 0.0000, 0.0000, 90.0000); //fencesmallb
	g_Object[252] = CreateObject(970, 2477.5629, -2068.5134, 13.0867, 0.0000, 0.0000, 90.0000); //fencesmallb
	g_Object[253] = CreateObject(970, 2477.5629, -2073.5759, 13.0867, 0.0000, 0.0000, 90.0000); //fencesmallb
	g_Object[254] = CreateObject(1372, 2454.0927, -2135.5280, 12.6331, 0.0000, 0.0000, 0.0000); //CJ_Dump2_LOW
	g_Object[255] = CreateObject(1372, 2451.8618, -2135.5280, 12.6331, 0.0000, 0.0000, 0.0000); //CJ_Dump2_LOW
	g_Object[256] = CreateObject(1372, 2449.4819, -2135.5280, 12.6331, 0.0000, 0.0000, 0.0000); //CJ_Dump2_LOW
	g_Object[257] = CreateObject(1440, 2446.8681, -2135.6909, 13.0672, 0.0000, 0.0000, -180.0000); //DYN_BOX_PILE_3
	g_Object[258] = CreateObject(1886, 2466.5485, -2112.8330, 17.5970, 0.0000, 0.0000, -130.5000); //shop_sec_cam
	g_Object[259] = CreateObject(1886, 2474.0952, -2113.9157, 19.3470, 0.0000, 0.0000, 147.0997); //shop_sec_cam
	g_Object[260] = CreateObject(1886, 2522.4365, -2114.2382, 19.2670, 0.0000, 0.0000, 148.1999); //shop_sec_cam
	g_Object[261] = CreateObject(1886, 2521.7917, -2133.5234, 19.2870, 0.0000, 0.0000, -77.8000); //shop_sec_cam
	g_Object[262] = CreateObject(1886, 2436.1086, -2077.4672, 16.0669, 0.0000, 0.0000, 61.8998); //shop_sec_cam
	g_Object[263] = CreateObject(1216, 2465.6992, -2112.7062, 13.1999, 0.0000, 0.0000, 180.0000); //phonebooth1
	g_Object[264] = CreateObject(3407, 2463.5349, -2112.7763, 12.5037, 0.0000, 0.0000, 180.0000); //CE_mailbox1
	g_Object[265] = CreateObject(1367, 2447.8818, -2083.6689, 13.1697, 0.0000, 0.0000, -90.0000); //CJ_POSTBOX
	g_Object[266] = CreateObject(1367, 2469.1757, -2083.6689, 13.1697, 0.0000, 0.0000, -90.0000); //CJ_POSTBOX
	g_Object[267] = CreateObject(1367, 2491.7001, -2083.6689, 13.1697, 0.0000, 0.0000, -90.0000); //CJ_POSTBOX
	g_Object[268] = CreateObject(1367, 2528.2912, -2095.0705, 13.1697, 0.0000, 0.0000, -90.0000); //CJ_POSTBOX
	g_Object[269] = CreateObject(1367, 2452.8977, -2096.4694, 13.1697, 0.0000, 0.0000, 0.0000); //CJ_POSTBOX
	g_Object[270] = CreateObject(1367, 2439.7446, -2096.4694, 13.1697, 0.0000, 0.0000, 0.0000); //CJ_POSTBOX
	g_Object[271] = CreateObject(1367, 2433.9716, -2104.0202, 13.1697, 0.0000, 0.0000, 90.0000); //CJ_POSTBOX
	g_Object[272] = CreateObject(1367, 2441.0144, -2110.7224, 13.1697, 0.0000, 0.0000, -180.0000); //CJ_POSTBOX
	g_Object[273] = CreateObject(1367, 2456.0075, -2110.7224, 13.1697, 0.0000, 0.0000, -180.0000); //CJ_POSTBOX
	g_Object[274] = CreateObject(1341, 2437.0622, -2083.4140, 13.5544, 0.0000, 0.0000, -90.0000); //icescart_prop
	g_Object[275] = CreateObject(19362, 2469.7089, -2089.5290, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[275], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[276] = CreateObject(19362, 2459.2258, -2089.5290, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[276], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[277] = CreateObject(19362, 2450.2460, -2089.5290, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[277], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[278] = CreateObject(19362, 2441.2333, -2089.5290, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[278], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[279] = CreateObject(19362, 2432.3774, -2089.5290, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[279], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[280] = CreateObject(19362, 2480.2463, -2089.5290, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[280], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[281] = CreateObject(19362, 2490.3398, -2089.5290, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[281], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[282] = CreateObject(19362, 2501.7534, -2089.5290, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[282], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[283] = CreateObject(19362, 2512.1574, -2089.5290, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[283], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[284] = CreateObject(19362, 2522.8498, -2089.5290, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[284], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[285] = CreateObject(19950, 2431.0202, -2094.9040, 12.4504, 0.0000, 0.0000, -90.0000); //SAMPRoadSign3
	g_Object[286] = CreateObject(19948, 2526.1948, -2095.0864, 12.4812, 0.0000, 0.0000, -90.0000); //SAMPRoadSign1
	g_Object[287] = CreateObject(1226, 2476.5012, -2067.5678, 16.4050, 0.0000, 0.0000, 41.5000); //lamppost3
	g_Object[288] = CreateObject(1226, 2538.6323, -2087.2917, 16.4050, 0.0000, 0.0000, 0.0000); //lamppost3
	g_Object[289] = CreateObject(1226, 2538.6323, -2091.7626, 16.4050, 0.0000, 0.0000, 0.0000); //lamppost3
	g_Object[290] = CreateObject(1226, 2525.3811, -2094.1533, 16.4050, 0.0000, 0.0000, -90.0000); //lamppost3
	g_Object[291] = CreateObject(1226, 2524.1101, -2115.8017, 16.4050, 0.0000, 0.0000, -180.0000); //lamppost3
	g_Object[292] = CreateObject(1226, 2524.1101, -2124.0832, 16.4050, 0.0000, 0.0000, -180.0000); //lamppost3
	g_Object[293] = CreateObject(1226, 2524.1101, -2131.7355, 16.4050, 0.0000, 0.0000, -180.0000); //lamppost3
	g_Object[294] = CreateObject(1226, 2519.8583, -2135.1564, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[295] = CreateObject(1226, 2510.4074, -2135.1564, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[296] = CreateObject(1226, 2501.8859, -2135.1564, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[297] = CreateObject(1226, 2492.7463, -2135.1564, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[298] = CreateObject(1226, 2484.2683, -2135.1564, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[299] = CreateObject(1226, 2475.3764, -2135.1564, 16.4050, 0.0000, 0.0000, 90.0000); //lamppost3
	g_Object[300] = CreateObject(1215, 2456.7976, -2096.4853, 13.1020, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[301] = CreateObject(1215, 2448.3857, -2096.4853, 13.1020, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[302] = CreateObject(1215, 2444.0764, -2096.4853, 13.1020, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[303] = CreateObject(1215, 2435.6960, -2096.4853, 13.1020, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[304] = CreateObject(1215, 2433.9458, -2100.1464, 13.1020, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[305] = CreateObject(1215, 2433.9458, -2107.9377, 13.1020, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[306] = CreateObject(1215, 2436.6459, -2110.7084, 13.1020, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[307] = CreateObject(1215, 2446.1003, -2110.7084, 13.1020, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[308] = CreateObject(1215, 2451.0700, -2110.7084, 13.1020, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[309] = CreateObject(1215, 2457.6896, -2110.7084, 13.1020, 0.0000, 0.0000, 0.0000); //bollardlight
	g_Object[310] = CreateObject(1226, 2426.8283, -2135.1818, 16.4050, 0.0000, 0.0000, -180.0000); //lamppost3
	g_Object[311] = CreateObject(1226, 2426.8283, -2124.0373, 16.4050, 0.0000, 0.0000, -180.0000); //lamppost3
	g_Object[312] = CreateObject(1226, 2426.8283, -2115.2646, 16.4050, 0.0000, 0.0000, -180.0000); //lamppost3
	g_Object[313] = CreateObject(19362, 2539.1511, -2100.4990, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[313], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[314] = CreateObject(19362, 2539.1511, -2103.7094, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[314], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[315] = CreateObject(19362, 2539.1511, -2107.1291, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[315], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[316] = CreateObject(19362, 2539.1511, -2110.9096, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[316], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[317] = CreateObject(19362, 2539.1511, -2114.8300, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[317], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[318] = CreateObject(19362, 2539.1511, -2118.5305, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[318], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[319] = CreateObject(19362, 2539.1511, -2122.3610, 10.8028, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[319], 0, 10765, "airportgnd_sfse", "white", 0xFFFFFFFF);
	g_Object[320] = CreateObject(1233, 2540.7446, -2105.4562, 14.0726, 0.0000, 0.0000, -90.0000); //noparkingsign1
	SetObjectMaterial(g_Object[320], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	SetObjectMaterial(g_Object[320], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF5F0A15);
	g_Object[321] = CreateObject(1233, 2540.7446, -2102.0656, 14.0726, 0.0000, 0.0000, -90.0000); //noparkingsign1
	SetObjectMaterial(g_Object[321], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	SetObjectMaterial(g_Object[321], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF5F0A15);
	g_Object[322] = CreateObject(1233, 2540.7446, -2109.0371, 14.0726, 0.0000, 0.0000, -90.0000); //noparkingsign1
	SetObjectMaterial(g_Object[322], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	SetObjectMaterial(g_Object[322], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF5F0A15);
	g_Object[323] = CreateObject(1233, 2540.7446, -2112.8889, 14.0726, 0.0000, 0.0000, -90.0000); //noparkingsign1
	SetObjectMaterial(g_Object[323], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	SetObjectMaterial(g_Object[323], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF5F0A15);
	g_Object[324] = CreateObject(1233, 2540.7446, -2116.7207, 14.0726, 0.0000, 0.0000, -90.0000); //noparkingsign1
	SetObjectMaterial(g_Object[324], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	SetObjectMaterial(g_Object[324], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF5F0A15);
	g_Object[325] = CreateObject(1233, 2540.7446, -2120.4318, 14.0726, 0.0000, 0.0000, -90.0000); //noparkingsign1
	SetObjectMaterial(g_Object[325], 2, 10101, "2notherbuildsfe", "ferry_build14", 0xFF840410);
	SetObjectMaterial(g_Object[325], 3, 10101, "2notherbuildsfe", "ferry_build14", 0xFF5F0A15);
	g_Object[326] = CreateObject(19327, 2540.7021, -2106.4934, 14.7860, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[326], "F", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[327] = CreateObject(19327, 2540.7021, -2103.1030, 14.7860, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[327], "F", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[328] = CreateObject(19327, 2540.7021, -2110.0742, 14.7860, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[328], "F", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[329] = CreateObject(19327, 2540.7021, -2113.9248, 14.7860, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[329], "F", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[330] = CreateObject(19327, 2540.7021, -2117.7551, 14.7860, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[330], "F", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[331] = CreateObject(19327, 2540.7021, -2121.4653, 14.7860, 0.0000, 0.0000, -90.0000); //7_11_sign02
	SetObjectMaterialText(g_Object[331], "F", 0, 90, "Arial", 60, 1, 0xFFFFFFFF, 0x0, 0);
	g_Object[332] = CreateObject(19362, 2455.9667, -2113.1467, 22.1142, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[332], 0, 17533, "eastbeach7_lae2", "shopwindowlow2_256", 0xFFFFFFFF);
	g_Object[333] = CreateObject(19362, 2434.4660, -2113.1467, 22.1142, 0.0000, 0.0000, -90.0000); //wall010
	SetObjectMaterial(g_Object[333], 0, 17533, "eastbeach7_lae2", "shopwindowlow2_256", 0xFFFFFFFF);
	g_Object[334] = CreateObject(947, 2498.0424, -2077.1000, 14.7355, 0.0000, 0.0000, -90.0000); //bskballhub_lax01
	g_Object[335] = CreateObject(947, 2537.5856, -2077.1000, 14.7355, 0.0000, 0.0000, 90.0000); //bskballhub_lax01
	g_Object[336] = CreateObject(19377, 2502.0617, -2079.6423, 12.4889, 0.0000, 90.0000, -180.0000); //wall025
	SetObjectMaterial(g_Object[336], 0, 16640, "a51", "plaintarmac1", 0xFFFFFFFF);
	g_Object[337] = CreateObject(11713, 2497.6896, -2133.1730, 17.4970, 0.0000, 0.0000, 90.0000); //FireExtPanel1
	g_Object[338] = CreateObject(2200, 2498.7275, -2133.0571, 12.5470, 0.0000, 0.0000, 180.0000); //MED_OFFICE5_UNIT_1
	SetObjectMaterial(g_Object[338], 0, 14391, "dr_gsmix", "chromecabinet01side_128", 0xFFFFFFFF);
	g_Object[339] = CreateObject(2200, 2494.2878, -2133.0571, 12.5470, 0.0000, 0.0000, 180.0000); //MED_OFFICE5_UNIT_1
	SetObjectMaterial(g_Object[339], 0, 14391, "dr_gsmix", "chromecabinet01side_128", 0xFFFFFFFF);
	g_Object[340] = CreateObject(2200, 2496.5085, -2133.0571, 12.5470, 0.0000, 0.0000, 180.0000); //MED_OFFICE5_UNIT_1
	SetObjectMaterial(g_Object[340], 0, 14391, "dr_gsmix", "chromecabinet01side_128", 0xFFFFFFFF);
	g_Object[341] = CreateObject(2400, 2486.8562, -2133.1223, 12.7258, 0.0000, 0.0000, -180.0000); //CJ_SPORTS_WALL01
	SetObjectMaterial(g_Object[341], 1, 3881, "apsecurity_sfxrf", "CJ_WOOD1", 0xFFFFFFFF);
	g_Object[342] = CreateObject(2400, 2490.5764, -2133.1223, 12.7258, 0.0000, 0.0000, -180.0000); //CJ_SPORTS_WALL01
	SetObjectMaterial(g_Object[342], 1, 3881, "apsecurity_sfxrf", "CJ_WOOD1", 0xFFFFFFFF);
	g_Object[343] = CreateObject(11729, 2501.3466, -2132.9660, 12.5191, 0.0000, 0.0000, 180.0000); //GymLockerClosed1
	g_Object[344] = CreateObject(11729, 2502.0673, -2132.9660, 12.5191, 0.0000, 0.0000, 180.0000); //GymLockerClosed1
	g_Object[345] = CreateObject(11729, 2502.7780, -2132.9660, 12.5191, 0.0000, 0.0000, 180.0000); //GymLockerClosed1
	g_Object[346] = CreateObject(11729, 2503.4885, -2132.9660, 12.5191, 0.0000, 0.0000, 180.0000); //GymLockerClosed1
	g_Object[347] = CreateObject(11729, 2504.1992, -2132.9660, 12.5191, 0.0000, 0.0000, 180.0000); //GymLockerClosed1
	g_Object[348] = CreateObject(11729, 2504.9094, -2132.9660, 12.5191, 0.0000, 0.0000, 180.0000); //GymLockerClosed1
	g_Object[349] = CreateObject(11729, 2505.6101, -2132.9660, 12.5191, 0.0000, 0.0000, 180.0000); //GymLockerClosed1
	g_Object[350] = CreateObject(19330, 2490.7495, -2132.8723, 14.7783, 0.0000, -90.0000, 0.0000); //fire_hat01
	g_Object[351] = CreateObject(19330, 2490.2690, -2132.8723, 14.7783, 0.0000, -90.0000, 0.0000); //fire_hat01
	g_Object[352] = CreateObject(19330, 2489.7485, -2132.8723, 14.7783, 0.0000, -90.0000, 0.0000); //fire_hat01
	g_Object[353] = CreateObject(19330, 2489.2180, -2132.8723, 14.7783, 0.0000, -90.0000, 0.0000); //fire_hat01
	g_Object[354] = CreateObject(19330, 2488.6374, -2132.8723, 14.7783, 0.0000, -90.0000, 0.0000); //fire_hat01
	g_Object[355] = CreateObject(19331, 2487.8627, -2132.8383, 14.7855, 0.0000, -90.0000, 0.0000); //fire_hat02
	g_Object[356] = CreateObject(19331, 2487.1726, -2132.8383, 14.7855, 0.0000, -90.0000, 0.0000); //fire_hat02
	g_Object[357] = CreateObject(19331, 2486.4018, -2132.8383, 14.7855, 0.0000, -90.0000, 0.0000); //fire_hat02
	g_Object[358] = CreateObject(19331, 2485.6311, -2132.8383, 14.7855, 0.0000, -90.0000, 0.0000); //fire_hat02
	g_Object[359] = CreateObject(19331, 2484.7104, -2132.8383, 14.7855, 0.0000, -90.0000, 0.0000); //fire_hat02
	g_Object[360] = CreateObject(19942, 2501.3347, -2132.9096, 14.6692, 0.0000, 0.0000, -43.4999); //PoliceRadio1
	g_Object[361] = CreateObject(19942, 2503.4858, -2132.9514, 14.6692, 0.0000, 0.0000, -43.4999); //PoliceRadio1
	g_Object[362] = CreateObject(19797, 2497.8933, -2114.2026, 16.4169, 0.0000, 0.0000, 0.0000); //PoliceVisorStrobe1
	g_Object[363] = CreateObject(19797, 2490.5217, -2114.2026, 16.4169, 0.0000, 0.0000, 0.0000); //PoliceVisorStrobe1
	g_Object[364] = CreateObject(19797, 2483.4008, -2114.2026, 16.4169, 0.0000, 0.0000, 0.0000); //PoliceVisorStrobe1
	g_Object[365] = CreateObject(19797, 2476.7817, -2114.2026, 16.4169, 0.0000, 0.0000, 0.0000); //PoliceVisorStrobe1
	g_Object[366] = CreateObject(19797, 2505.2226, -2114.2026, 16.4169, 0.0000, 0.0000, 0.0000); //PoliceVisorStrobe1
	g_Object[367] = CreateObject(19797, 2512.5432, -2114.2026, 16.4169, 0.0000, 0.0000, 0.0000); //PoliceVisorStrobe1
	g_Object[368] = CreateObject(2309, 2507.3332, -2133.0546, 12.5246, 0.0000, 0.0000, 0.0000); //MED_OFFICE_CHAIR2
	g_Object[369] = CreateObject(2309, 2508.1135, -2133.0546, 12.5246, 0.0000, 0.0000, 0.0000); //MED_OFFICE_CHAIR2
	g_Object[370] = CreateObject(2309, 2508.9243, -2133.0546, 12.5246, 0.0000, 0.0000, 0.0000); //MED_OFFICE_CHAIR2
	g_Object[371] = CreateObject(2309, 2509.6845, -2133.0546, 12.5246, 0.0000, 0.0000, 0.0000); //MED_OFFICE_CHAIR2
	g_Object[372] = CreateObject(2309, 2510.4650, -2133.0546, 12.5246, 0.0000, 0.0000, 0.0000); //MED_OFFICE_CHAIR2
	g_Object[373] = CreateObject(2309, 2511.2358, -2133.0546, 12.5246, 0.0000, 0.0000, 0.0000); //MED_OFFICE_CHAIR2
	g_Object[374] = CreateObject(1808, 2500.1379, -2133.0292, 12.5247, 0.0000, 0.0000, -180.0000); //CJ_WATERCOOLER2
	g_Object[375] = CreateObject(2167, 2482.5769, -2133.1906, 12.5387, 0.0000, 0.0000, 180.0000); //MED_OFFICE_UNIT_7
	SetObjectMaterial(g_Object[375], 1, 14391, "dr_gsmix", "chromecabinet01side_128", 0xFFFFFFFF);
	g_Object[376] = CreateObject(2167, 2481.6662, -2133.1906, 12.5387, 0.0000, 0.0000, 180.0000); //MED_OFFICE_UNIT_7
	SetObjectMaterial(g_Object[376], 1, 14391, "dr_gsmix", "chromecabinet01side_128", 0xFFFFFFFF);
	g_Object[377] = CreateObject(19978, 2469.9108, -2094.7812, 12.5016, 0.0000, 0.0000, -90.0000); //SAMPRoadSign31
	CreateDynamicObject(19461, 2260.97290, -1369.53699, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2256.07690, -1374.26697, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2246.45093, -1374.26697, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2236.82910, -1374.26697, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2227.20703, -1374.26697, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2217.57690, -1374.26697, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2207.95801, -1374.26697, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2198.32202, -1374.26697, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2188.68896, -1374.26697, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2181.61890, -1374.28699, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2260.97290, -1359.91296, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2260.97705, -1350.55798, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2260.97290, -1315.50305, 21.25100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2260.97290, -1325.12695, 21.25100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19369, 2260.97290, -1336.63403, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2256.07690, -1310.78503, 21.25100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2246.45093, -1310.78503, 21.25100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2236.82910, -1310.78503, 21.25100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2227.20703, -1310.78503, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2217.57690, -1310.78503, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2207.93921, -1310.77832, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2198.32202, -1310.78503, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2188.68896, -1310.78503, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2181.60498, -1310.79102, 24.51700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2176.84912, -1315.50305, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2176.84912, -1325.12695, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2176.84912, -1369.55798, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2176.84912, -1360.00195, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2176.84912, -1334.75305, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19369, 2176.84912, -1353.58301, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19369, 2176.84912, -1350.37598, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2184.02808, -1318.09204, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2184.02808, -1327.72302, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2191.97583, -1313.31567, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19458, 2201.61011, -1313.31567, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2208.03271, -1313.31567, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2211.24585, -1313.31567, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2256.25098, -1334.83997, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2185.55591, -1313.31567, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2232.11304, -1315.49902, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2246.62891, -1334.83997, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2232.11304, -1325.12000, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19369, 2232.11304, -1331.52905, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19442, 2232.11304, -1333.92798, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3498, 2232.03589, -1334.84399, 23.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3498, 2238.58398, -1334.87305, 23.34000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19369, 2240.21191, -1334.83997, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3498, 2260.94189, -1345.87097, 26.76600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3498, 2260.93408, -1338.20203, 26.76600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19435, 2233.59497, -1334.86401, 27.02200,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19435, 2237.07007, -1334.87805, 27.02200,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2260.92505, -1343.88000, 29.66000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2260.92505, -1340.19995, 29.66000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2219.12671, -1327.72302, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2228.75171, -1327.72302, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2224.02710, -1313.31567, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19458, 2224.02710, -1313.31567, 28.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19458, 2228.75171, -1327.72302, 28.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19375, 2223.92212, -1318.11108, 29.83600,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19375, 2223.92212, -1327.72607, 29.83600,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19461, 2256.15698, -1349.42200, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2260.99292, -1333.45898, 21.24100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3660, 2217.99390, -1364.51794, 24.99500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19435, 2219.96094, -1356.44495, 23.50300,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19441, 2219.96094, -1354.78406, 21.83700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19435, 2219.96094, -1359.94104, 23.50300,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19435, 2219.96094, -1363.43201, 23.50300,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19435, 2219.96094, -1366.92603, 23.50300,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19435, 2219.96094, -1370.41895, 23.50300,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19435, 2219.96094, -1372.53296, 23.49900,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(3660, 2222.00806, -1364.50806, 24.99500,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(19439, 2205.68896, -1360.73303, 22.32400,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19439, 2205.68896, -1360.55298, 22.32400,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19439, 2205.68896, -1360.37305, 22.32400,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19439, 2205.68896, -1360.19299, 22.32400,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19439, 2205.68896, -1360.01294, 22.32400,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(1251, 2227.13599, -1370.81604, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2231.76904, -1370.81604, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2236.29492, -1370.81604, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2240.53906, -1370.81604, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2244.74097, -1370.81604, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2248.67505, -1370.81604, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2252.74805, -1370.81604, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2257.03589, -1370.81604, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2257.13306, -1352.82703, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2252.64697, -1352.82703, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2248.32397, -1352.82703, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19461, 2246.52393, -1349.42200, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1251, 2244.21191, -1352.82703, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19369, 2240.10693, -1349.42200, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1251, 2239.89893, -1352.82703, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19463, 2256.21606, -1347.60095, 22.87900,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19463, 2246.58691, -1347.60095, 22.87900,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19371, 2240.16992, -1347.60095, 22.87900,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19461, 2246.45093, -1345.77405, 21.25100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2256.07690, -1345.77405, 21.25100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19369, 2240.03101, -1345.77405, 21.25100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19369, 2238.51196, -1347.44299, 21.25100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3498, 2238.58594, -1349.30505, 23.57100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19371, 2240.16992, -1336.58496, 22.87900,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19463, 2246.58691, -1336.58496, 22.87900,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19463, 2256.21606, -1336.58496, 22.87900,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19369, 2240.03101, -1338.32397, 21.25100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2246.45093, -1338.32397, 21.25100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19461, 2256.07690, -1338.32397, 21.25100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19369, 2238.51196, -1336.64001, 21.25100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3498, 2260.94507, -1334.97302, 22.91600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3498, 2232.13403, -1310.85095, 23.67600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3660, 2259.84912, -1324.91394, 24.99500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3660, 2251.34302, -1311.43506, 24.99500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3660, 2259.86499, -1322.03601, 24.99000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1251, 2255.37793, -1315.65100, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2251.44995, -1315.65100, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2247.67700, -1315.65100, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2243.86792, -1315.65100, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2255.51904, -1332.34204, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3498, 2241.77100, -1310.85999, 23.67600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1251, 2252.03296, -1332.34204, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2248.48999, -1332.34204, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2245.02100, -1332.34204, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1251, 2241.45703, -1332.34204, 22.76100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19461, 2176.85205, -1344.13000, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2960, 2199.29004, -1324.31006, 23.52000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(2960, 2195.05298, -1324.31006, 23.52000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(2960, 2195.05298, -1319.97400, 23.52000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19438, 2195.84302, -1322.90405, 23.69000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19438, 2195.84497, -1321.66394, 23.68900,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19438, 2198.47900, -1322.90405, 23.69000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19438, 2198.47803, -1321.66394, 23.68900,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19438, 2206.48511, -1322.90405, 23.69000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19438, 2206.48389, -1321.66394, 23.68900,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19438, 2209.31299, -1322.90405, 23.69000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19438, 2209.31396, -1321.66394, 23.68900,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19438, 2206.47803, -1326.25403, 23.21000,   0.00000, 74.00000, 90.00000);
	CreateDynamicObject(19438, 2209.31006, -1326.25403, 23.21000,   0.00000, 74.00000, 90.00000);
	CreateDynamicObject(19438, 2198.48999, -1326.25403, 23.21000,   0.00000, 74.00000, 90.00000);
	CreateDynamicObject(19438, 2195.84399, -1326.25403, 23.21000,   0.00000, 74.00000, 90.00000);
	CreateDynamicObject(2314, 2192.63696, -1321.53601, 22.78500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2314, 2203.02002, -1321.53601, 22.78500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2960, 2199.29004, -1319.97595, 23.52000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(2960, 2205.67700, -1319.97595, 23.52000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(2960, 2205.67700, -1324.31006, 23.52000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(2960, 2210.15991, -1324.31006, 23.52000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(2960, 2210.15991, -1319.97595, 23.52000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19482, 2225.90137, -1338.96558, 26.20100,   0.00000, 0.00000, -89.60000);
	CreateDynamicObject(19482, 2236.97705, -1334.99097, 25.92600,   0.00000, 0.00000, -90.59900);
	CreateDynamicObject(19482, 2233.83911, -1334.76697, 25.90600,   0.00000, 0.00000, 89.90000);
	CreateDynamicObject(19482, 2261.10596, -1341.84998, 29.36400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19482, 2261.04590, -1341.19104, 27.99800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(10558, 2186.98633, -1356.55518, 24.23300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(985, 2260.96704, -1342.05200, 24.55900,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(19362, 2260.92212, -1340.54004, 29.66000,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2260.87793, -1342.51904, 21.21100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19461, 2259.09204, -1342.29602, 22.57000,   0.00000, 80.00000, 0.00000);
	CreateDynamicObject(6959, 2251.65356, -1329.37500, 22.83700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(7891, 2207.62891, -1332.33325, 24.01100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(13027, 2187.01294, -1365.24402, 26.00600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19375, 2187.26196, -1368.30396, 29.70000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19375, 2187.26904, -1361.36511, 29.68000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19435, 2219.35596, -1311.64697, 22.70000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19435, 2222.84106, -1311.65295, 22.70000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19435, 2226.33691, -1311.65295, 22.70000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19435, 2229.83203, -1311.65295, 22.70000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(11392, 2199.99487, -1324.41064, 22.80800,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(16360, 2206.65601, -1370.80603, 22.79400,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(17037, 2198.29395, -1371.89294, 25.21300,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(700, 2219.68799, -1371.71399, 23.11700,   356.85800, 0.00000, 3.14100);
	CreateDynamicObject(736, 2220.21802, -1364.53406, 33.73700,   357.00000, 0.00000, -84.00000);
	CreateDynamicObject(700, 2220.02490, -1357.06702, 23.11700,   357.00000, 0.00000, 229.00000);
	CreateDynamicObject(1686, 2204.82593, -1360.37500, 23.04500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1686, 2206.50903, -1360.37500, 23.05500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(700, 2257.84204, -1347.27197, 23.11700,   357.00000, 0.00000, 229.00000);
	CreateDynamicObject(700, 2252.60010, -1347.27197, 23.11700,   357.00000, 0.00000, 229.00000);
	CreateDynamicObject(700, 2247.08911, -1347.27197, 23.11700,   357.00000, 0.00000, 229.00000);
	CreateDynamicObject(700, 2241.59106, -1347.27197, 23.11700,   357.00000, 0.00000, 229.00000);
	CreateDynamicObject(700, 2241.59106, -1336.37500, 23.11700,   357.00000, 0.00000, 229.00000);
	CreateDynamicObject(700, 2247.08911, -1336.37500, 23.11700,   357.00000, 0.00000, 229.00000);
	CreateDynamicObject(700, 2252.60010, -1336.37500, 23.11700,   357.00000, 0.00000, 229.00000);
	CreateDynamicObject(700, 2257.84204, -1336.37500, 23.11700,   357.00000, 0.00000, 229.00000);
	CreateDynamicObject(19121, 2233.77197, -1334.87097, 23.31700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19124, 2235.34912, -1334.85095, 23.31700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19122, 2236.88599, -1334.87097, 23.31700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3286, 2213.71606, -1370.45703, 27.52000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14826, 2182.14404, -1318.15198, 23.35400,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14826, 2181.69995, -1324.68799, 23.35400,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14826, 2179.11694, -1320.55603, 23.35400,   0.00000, 0.00000, 990.00000);
	CreateDynamicObject(14826, 2178.98804, -1328.86206, 23.35400,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19393, 2190.78003, -1315.06201, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 2189.09106, -1319.77795, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 2190.78003, -1318.26404, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 2185.88794, -1319.77795, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2189.10693, -1318.24304, 26.18900,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2186.00000, -1318.24304, 26.19900,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2189.10693, -1315.04602, 26.19900,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2186.00000, -1315.04199, 26.18900,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3577, 2178.92603, -1314.29102, 23.52500,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3576, 2186.39209, -1315.01099, 27.75100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3633, 2185.03003, -1317.44995, 26.76200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3633, 2184.96191, -1319.01599, 26.76200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3800, 2189.97192, -1314.50598, 26.27500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3798, 2186.98999, -1318.34595, 26.27500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3800, 2189.64111, -1316.03198, 26.27500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3800, 2190.00098, -1317.68396, 26.27500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3800, 2188.99902, -1318.98303, 26.27500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1348, 2185.29712, -1320.33704, 23.44500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1348, 2186.99097, -1320.30603, 23.44500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2040, 2192.57690, -1319.85901, 23.37600,   0.00000, 0.00000, 40.00000);
	CreateDynamicObject(939, 2185.47705, -1324.96301, 25.10800,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(935, 2188.33105, -1320.34497, 23.37100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(910, 2191.33105, -1331.47705, 24.05300,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2040, 2202.90991, -1321.39294, 23.37600,   0.00000, 0.00000, 122.00000);
	CreateDynamicObject(935, 2212.36499, -1329.48145, 23.37100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(935, 2212.36499, -1315.36572, 23.37100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(935, 2212.36499, -1321.97021, 23.37100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18635, 2192.46191, -1320.91895, 23.28800,   90.00000, 90.00000, -72.00000);
	CreateDynamicObject(18644, 2192.64697, -1321.53406, 23.28800,   90.00000, 90.00000, -44.00000);
	CreateDynamicObject(18644, 2192.85693, -1320.06604, 23.28800,   90.00000, 90.00000, 109.00000);
	CreateDynamicObject(18644, 2192.58203, -1320.56006, 23.28800,   90.00000, 90.00000, -18.00000);
	CreateDynamicObject(18644, 2202.94409, -1320.15906, 23.28800,   90.00000, 90.00000, -18.00000);
	CreateDynamicObject(18635, 2202.68188, -1320.76099, 23.28800,   90.00000, 90.00000, -72.00000);
	CreateDynamicObject(18635, 2203.09009, -1321.65698, 23.28800,   90.00000, 90.00000, 25.00000);
	CreateDynamicObject(18644, 2203.31396, -1320.83606, 23.28800,   90.00000, 90.00000, 47.00000);
	CreateDynamicObject(2040, 2203.03589, -1319.93298, 23.37600,   0.00000, 0.00000, 33.00000);
	CreateDynamicObject(2040, 2192.62988, -1321.76404, 23.37600,   0.00000, 0.00000, 78.00000);
	CreateDynamicObject(1000, 2194.73901, -1313.46204, 27.93100,   -90.00000, 180.00000, 0.00000);
	CreateDynamicObject(1001, 2194.72192, -1313.31995, 27.42500,   -90.00000, 180.00000, 0.00000);
	CreateDynamicObject(1002, 2194.73901, -1313.45996, 26.76400,   -90.00000, 180.00000, 0.00000);
	CreateDynamicObject(1003, 2194.82300, -1313.44104, 26.22300,   -90.00000, 180.00000, 0.00000);
	CreateDynamicObject(1014, 2194.82300, -1313.46106, 25.45100,   -90.00000, 180.00000, 0.00000);
	CreateDynamicObject(1138, 2194.82300, -1313.66101, 24.90000,   -90.00000, 180.00000, 0.00000);
	CreateDynamicObject(1023, 2194.82300, -1313.42102, 24.32300,   -90.00000, 180.00000, 0.00000);
	CreateDynamicObject(1073, 2197.67212, -1313.53894, 27.68200,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1074, 2197.67212, -1313.53894, 26.18500,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1075, 2197.67212, -1313.53894, 24.71600,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1076, 2199.41699, -1313.52100, 24.68900,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1077, 2199.41699, -1313.52100, 26.16900,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1078, 2199.41699, -1313.52100, 27.71800,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1079, 2201.30103, -1313.53601, 27.71800,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1080, 2201.30103, -1313.53601, 26.14500,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1081, 2201.30103, -1313.53601, 24.67300,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1082, 2203.10107, -1313.56201, 24.67300,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1083, 2203.10107, -1313.54199, 26.12400,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1084, 2203.10107, -1313.54199, 27.77700,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1085, 2204.84302, -1313.56897, 27.77700,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1098, 2204.84302, -1313.56897, 26.06700,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1025, 2204.89111, -1313.56604, 24.64000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1008, 2207.42993, -1313.51404, 24.52600,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(1008, 2206.68701, -1313.58496, 24.72000,   0.00000, 90.00000, -90.00000);
	CreateDynamicObject(1010, 2208.75488, -1313.50696, 24.63000,   0.00000, 90.00000, -90.00000);
	CreateDynamicObject(1010, 2209.42603, -1313.45898, 24.58700,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(1009, 2211.04907, -1313.48303, 24.57500,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(1009, 2211.04907, -1313.48303, 24.25400,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(1009, 2210.45898, -1313.50696, 24.57500,   0.00000, 90.00000, -90.00000);
	CreateDynamicObject(1140, 2206.41211, -1313.78003, 25.59100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1141, 2206.35205, -1313.78003, 26.64700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1148, 2207.92017, -1313.78003, 27.67900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1152, 2210.55811, -1313.78003, 27.67300,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1153, 2209.21899, -1313.78003, 26.70700,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1155, 2209.77393, -1313.78174, 25.60000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1114, 2212.06006, -1313.47302, 28.12900,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(1104, 2212.06006, -1313.47302, 27.31600,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(1105, 2212.41309, -1313.48206, 27.31600,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(1034, 2212.06494, -1313.92102, 26.91500,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(1113, 2212.44092, -1313.44800, 28.12700,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(1999, 2186.48389, -1317.79797, 22.80600,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1810, 2185.64990, -1318.00500, 22.80600,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2186, 2184.98608, -1313.92700, 22.80600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14604, 2190.20898, -1319.01697, 23.78200,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2065, 2184.68408, -1316.29395, 22.80600,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3017, 2184.38696, -1315.97498, 23.35500,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(2000, 2184.61499, -1319.20203, 22.80600,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2002, 2187.73706, -1319.23596, 22.80600,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1502, 2190.82007, -1315.80798, 22.78600,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19482, 2226.71069, -1338.03796, 26.20100,   0.00000, 0.00000, -89.60000);
	CreateDynamicObject(1569, 2223.35303, -1332.56091, 22.77100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(6959, 2210.30811, -1329.37500, 22.83700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(6959, 2168.99707, -1329.37939, 22.83700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(6959, 2251.64258, -1369.36584, 22.83700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(6959, 2210.31616, -1369.36584, 22.83700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(6959, 2168.99707, -1369.36584, 22.83700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19387, 2188.80957, -1332.46094, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(7891, 2197.20728, -1332.33325, 24.01100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2192.01880, -1332.39697, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2188.80957, -1332.41626, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2185.59912, -1332.41626, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2195.23071, -1332.41626, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2198.44165, -1332.41626, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2201.64722, -1332.41626, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2204.84375, -1332.41626, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2208.04199, -1332.41626, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2211.25732, -1332.41626, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2212.94531, -1330.89612, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2212.94531, -1327.68420, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2212.94531, -1324.47754, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2212.94531, -1321.27576, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2212.96533, -1318.07971, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2212.94531, -1314.89441, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2211.24390, -1313.37805, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2208.03467, -1313.37805, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2204.82861, -1313.37805, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2201.62402, -1313.37805, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2198.42212, -1313.37805, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2195.20728, -1313.37805, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2191.99561, -1313.37805, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2188.79761, -1313.37805, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2185.60083, -1313.37805, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2212.94531, -1330.89612, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2211.25732, -1332.41626, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2202.00000, 4260.00000, -1332.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2192.01880, -1332.39697, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2185.59912, -1332.41626, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2202.44678, -1332.41626, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2212.94531, -1327.68420, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2212.94531, -1324.46753, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2212.94629, -1321.25574, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2212.94434, -1318.09998, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2212.94531, -1314.89441, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2211.24976, -1313.37805, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2208.03467, -1313.37805, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2204.82861, -1313.37805, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2201.62402, -1313.37805, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2198.42212, -1313.37805, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2195.20728, -1313.37805, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2191.99561, -1313.37805, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2188.78906, -1313.37805, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2185.58496, -1313.37805, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2184.09204, -1314.89441, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2184.09204, -1318.07971, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2184.09204, -1321.27576, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2184.09204, -1324.47754, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2184.09204, -1327.68420, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2184.09204, -1330.89612, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2184.09204, -1330.89612, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2184.09204, -1327.68420, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2184.09204, -1324.47754, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2184.09204, -1321.27576, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2184.09204, -1318.09998, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2184.09204, -1314.89441, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2184.02808, -1327.72302, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2184.02808, -1318.09204, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 2185.55591, -1313.31567, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19458, 2191.97583, -1313.31567, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19458, 2201.61011, -1313.31567, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2208.03271, -1313.31567, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2211.24585, -1313.31567, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19458, 2213.07422, -1318.09204, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2213.07422, -1327.72302, 28.01300,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2213.07422, -1327.72302, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2213.04834, -1318.09204, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2191.97168, -1332.46094, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2185.59912, -1332.46094, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19458, 2201.60620, -1332.46094, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2208.02661, -1332.46094, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2211.23779, -1332.46094, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3498, 2212.95996, -1332.63538, 25.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3498, 2182.02197, -1332.11377, 25.25600,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19366, 2202.44678, -1332.46094, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2192.01880, -1332.46094, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2185.59912, -1332.46094, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19366, 2211.23779, -1332.46094, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3498, 2213.13037, -1313.29639, 25.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3498, 2182.02197, -1313.54175, 25.21400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19387, 2188.81152, -1332.41626, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19375, 2207.90234, -1327.72205, 29.84500,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19375, 2207.90234, -1318.08337, 29.84500,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19375, 2197.39819, -1318.08337, 29.84500,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19375, 2197.41968, -1327.72205, 29.84500,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19375, 2186.91626, -1327.72205, 29.84500,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19375, 2186.91626, -1318.08337, 29.84500,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 2182.64478, -1370.96924, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2182.64478, -1358.16064, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2182.64478, -1361.36218, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2182.64478, -1364.55713, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2182.64478, -1367.76526, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2182.64478, -1358.16064, 27.99700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2182.64478, -1361.36218, 27.99700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2182.64478, -1364.55713, 27.99700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2182.64478, -1367.76526, 27.99700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2182.64478, -1370.96924, 27.99700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2191.34937, -1358.16064, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2191.34937, -1361.36218, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2191.34937, -1364.55713, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2191.34937, -1367.76526, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2191.34937, -1370.96924, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2191.34937, -1370.96924, 27.99700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2191.34937, -1367.76526, 27.99700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2191.34937, -1364.55713, 27.99700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2191.34937, -1361.36218, 27.99700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2191.34937, -1358.16064, 27.99700,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19362, 2189.80908, -1356.65967, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2186.60522, -1356.65967, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2184.23193, -1356.65771, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2189.80908, -1372.48987, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2186.60522, -1372.48987, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2184.20532, -1372.48792, 28.01300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2189.80908, -1372.48987, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2186.60522, -1372.48987, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19362, 2184.22534, -1372.48792, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19458, 2191.38330, -1364.58264, 26.22900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2182.62915, -1364.58264, 26.22900,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1491, 2188.02319, -1332.46558, 22.79820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2219.12671, -1318.09204, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2219.12671, -1327.72302, 28.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2219.12671, -1318.09204, 28.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2228.75171, -1318.09204, 24.51200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2228.75171, -1318.09204, 28.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19458, 2224.02710, -1332.46094, 28.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19458, 2224.02710, -1332.46094, 24.51200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(4100, 2219.64331, -1332.29517, 22.80130,   0.00000, 0.00000, 140.00395);
	CreateDynamicObject(4100, 2219.64331, -1313.62598, 22.80130,   0.00000, 0.00000, 140.00400);
	CreateDynamicObject(869, 2216.02734, -1329.31348, 22.80128,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(869, 2216.02734, -1315.22961, 22.80130,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(869, 2216.02734, -1317.29041, 22.80130,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(869, 2216.02734, -1327.05334, 22.80130,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(700, 2215.42725, -1322.83252, 23.11700,   357.00000, 0.00000, 229.00000);
	CreateDynamicObject(870, 2215.52588, -1324.13062, 22.79796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(870, 2216.72412, -1322.06885, 22.79796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(870, 2214.06372, -1322.25256, 22.79796,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19435, 2233.79346, -1310.81604, 27.38400,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19435, 2237.25269, -1310.81604, 27.38400,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19435, 2240.26929, -1310.81604, 27.38400,   90.00000, 0.00000, 90.00000);
	return 1;
}

public OnGameModeExit()
{
	mysql_close(handle);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SpawnPlayer(playerid);
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
	RemoveBuildingForPlayer(playerid, 4075, 1791.7969, -1716.9844, 12.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 4076, 1783.1016, -1702.3047, 14.3516, 0.25);
	RemoveBuildingForPlayer(playerid, 1531, 1799.1328, -1708.7656, 14.1016, 0.25);
	RemoveBuildingForPlayer(playerid, 1266, 1805.0234, -1692.4453, 25.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 1283, 1750.2656, -1719.6328, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 4018, 1791.7969, -1716.9844, 12.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 4027, 1783.1016, -1702.3047, 14.3516, 0.25);
	RemoveBuildingForPlayer(playerid, 1260, 1805.0234, -1692.4453, 25.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 3563, 2184.9766, -1359.7891, 27.2266, 0.25);
	RemoveBuildingForPlayer(playerid, 3562, 2202.5781, -1359.1328, 27.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 5584, 2218.8906, -1342.5547, 25.2422, 0.25);
	RemoveBuildingForPlayer(playerid, 1527, 2233.9531, -1367.6172, 24.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 714, 2217.0234, -1320.8047, 22.5078, 0.25);
	RemoveBuildingForPlayer(playerid, 1308, 2176.6484, -1349.8672, 22.8594, 0.25);
	RemoveBuildingForPlayer(playerid, 1264, 2177.0938, -1345.1875, 23.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1264, 2177.9844, -1345.1719, 23.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1308, 2176.9297, -1322.2344, 22.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 3555, 2184.9766, -1359.7891, 27.2266, 0.25);
	RemoveBuildingForPlayer(playerid, 3582, 2202.5781, -1359.1328, 27.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 2226.8750, -1371.2109, 22.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 2233.3359, -1371.2109, 22.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 2258.1484, -1371.2109, 22.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 5635, 2182.2891, -1324.7500, 28.6016, 0.25);
	RemoveBuildingForPlayer(playerid, 1308, 2204.3828, -1310.7031, 22.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 5426, 2218.8906, -1342.5547, 25.2422, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 2258.1484, -1352.6328, 22.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 1308, 2261.0859, -1329.5156, 23.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 5654, 2263.5234, -1312.6250, 37.0781, 0.25);
	RemoveBuildingForPlayer(playerid, 3244, 2532.0313, -2074.6250, 12.9922, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 2484.4141, -2141.0078, 12.1875, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 2496.0625, -2141.0078, 12.1875, 0.25);
	RemoveBuildingForPlayer(playerid, 3290, 2503.1250, -2073.3750, 12.4297, 0.25);
	RemoveBuildingForPlayer(playerid, 3290, 2515.4219, -2073.3750, 12.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3288, 2432.7266, -2133.0234, 12.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 3686, 2448.1328, -2075.6328, 16.0469, 0.25);
	RemoveBuildingForPlayer(playerid, 3745, 2475.1016, -2073.4766, 17.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 3745, 2482.0234, -2073.4766, 17.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 3745, 2489.1016, -2073.4766, 17.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 3745, 2496.0938, -2073.4766, 17.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 3290, 2452.9609, -2129.0156, 25.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 3756, 2484.2344, -2118.5547, 17.7031, 0.25);
	RemoveBuildingForPlayer(playerid, 3755, 2484.2344, -2118.5547, 17.7031, 0.25);
	RemoveBuildingForPlayer(playerid, 3257, 2432.7266, -2133.0234, 12.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 2484.4141, -2141.0078, 12.1875, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 2496.0625, -2141.0078, 12.1875, 0.25);
	RemoveBuildingForPlayer(playerid, 3256, 2452.9609, -2129.0156, 25.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 3567, 2446.8281, -2075.8438, 13.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 3567, 2438.3594, -2075.8438, 13.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 3627, 2448.1328, -2075.6328, 16.0469, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, 2489.1016, -2073.4766, 17.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, 2482.0234, -2073.4766, 17.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, 2475.1016, -2073.4766, 17.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, 2496.0938, -2073.4766, 17.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 3256, 2515.4219, -2073.3750, 12.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3256, 2503.1250, -2073.3750, 12.4297, 0.25);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	SaveUserStats(playerid);
	
	return 1;
}
public spielerfahrzeug(carid)
{
	 cInfo[carid][faid]=cache_insert_id();
	 return 1;
}

 carinDB(playerid,carid)
 {
	new query[128];
	format(query,sizeof(query),"INSERT INTO spielerfahrzeuge(besitzer,model,x,y,z,r,Schaden,kennzeichen,tank) VALUES('%i','%i','%f','%f','%f','%f','%i' ,'%i' ,'%i')",PlayerInfo[playerid][p_id],cInfo[carid][model],cInfo[carid][c_x],cInfo[carid][c_y],cInfo[carid][c_z],cInfo[carid][c_r],cInfo[carid][Schaden],cInfo[carid][kennzeichen],cInfo[carid][tank]);
	mysql_pquery(handle,query, "spielerfahrzeug", "d", carid);
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

PlayerCar(playerid,modelid,Float:x,Float:y,Float:z,Float:r,vschaden,vkenn,vtank)
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
		cInfo[i][Schaden] = vschaden;
		cInfo[i][kennzeichen] =vkenn;
		cInfo[i][tank] =vtank;
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
    if(GeldID<1||GeldID>999999999)return SendClientMessage(playerid,rot,"Falscher Geldwert!");
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
	if(fID<1||fID>11) return SendClientMessage(playerid,rot,"Diese Fraktion gibt es nicht");
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
	PlayerCar(pID,mID,xc,yc,zc,rc,Schaden,kennzeichen,tank);
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
			PlayerCar(playerid,ahCars[id][model],ahInfo[ahCars[id][ah_id]][v_x],ahInfo[ahCars[id][ah_id]][v_y],ahInfo[ahCars[id][ah_id]][v_z],ahInfo[ahCars[id][ah_id]][v_r],ahInfo[ahCars[id][ah_id]][v_s],ahInfo[ahCars[id][ah_id]][v_k],ahInfo[ahCars[id][ah_id]][v_t]);
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