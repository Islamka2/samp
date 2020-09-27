#include <a_samp>
#include <fix>
#include <a_mysql>
#include <streamer>
#include <Pawn.CMD>
#include <sscanf2>
#include <foreach>
#include <Pawn.Regex>
#include <crashdetect>

#define MYSQL_HOST "127.0.0.1"
#define MYSQL_USER "root"
#define MYSQL_PASS "root"
#define MYSQL_BASE "project"

#define SCM SendClientMessage
#define SCMTA SendClientMessageToAll
#define SPD  ShowPlayerDialog
//================================= COLORS ====================================
#define COLOR_BLACK         0x00000000
#define COLOR_RED			0xAA3333AA
#define COLOR_GREY          0xAFAFAFAA
#define COLOR_YELLOW        0xFFFF00AA
#define COLOR_PINK          0xFF66FFAA
#define COLOR_BLUE          0x0000BBAA
#define COLOR_WHITE         0xFFFFFFAA
#define COLOR_DARKRED         0x660000AA
#define COLOR_ORANGE         0xFF9900AA
#define COLOR_DARKGREEN     0x12900BBF
#define COLOR_LIGHTGREEN     0x24FF0AB9
#define COLOR_DARKBLUE         0x300FFAAB
#define COLOR_PINK            0xFF66FFAA
#define COLOR_LIGHTBLUE     0x33CCFFAA
#define COLOR_DARKRED         0x660000AA
#define COLOR_PURPLE         0x800080AA
#define COLOR_GREEN         0x33AA33AA
#define COLOR_BROWN         0x993300AA
//================================== END COLOR ================================
main()
{
	print("\n----------------------------------");
	print("Montana RolePlay");
	print("----------------------------------\n");
} 
//=================================== ���������� =============================

//----------------------------------- ������� --------------------------------
new MySQL:dbHandle;
//----------------------------------------------------------------------------

//============================================================================

enum player
{
	ID,
	NAME[MAX_PLAYER_NAME],
	PASSWORD[65],
	SALT[11],
	EMAIL[64],
	REF,
	SEX,
	RACE,
	AGE,
	SKIN,
	REGDATA[13],
	REGIP[16],
}

new player_info[MAX_PLAYERS][player];

enum dialogs
{
	DLG_NONE,
	DLG_REG,
	DLG_LOG,
    DLG_TP,
    DLG_REGEMAIL,
	DLG_REGREF,
	DLG_REGSEX,
	DLG_REGRACE,
	DLG_REGAGE,
}

public OnGameModeInit()
{
	CreateVehicles();
	CreateMapping();
	SetGameModeText("Montana RolePlay");
	AddPlayerClass(293, 1958.3783, 1343.1572, 18.3746, 269.1425, 15,150,0,0,0,0);
	ConnectMySQL();
	return 1;
}

stock ConnectMySQL()
{
	dbHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_BASE);
 	switch(mysql_errno())
    {
		case 0: print("mySQL worked!");
		default: print("MySQL dead!");
	}
	mysql_log(ERROR | WARNING);
	mysql_set_charset("cp1251");
}

stock CreateVehicles()
{
	AddStaticVehicle(490,1787.0465,-1931.9026,13.4981,359.5601,0,0); // 
	AddStaticVehicle(481,1783.5933,-1933.2482,12.8692,4.9400,0,0); // bmx x1
	AddStaticVehicle(481,1779.6682,-1933.1578,12.8688,356.2378,0,0); // bmx x2
	AddStaticVehicle(481,1776.0828,-1933.6763,12.8452,355.6268,255,255); // bmx x3

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
	GetPlayerName(playerid, player_info[playerid][NAME], MAX_PLAYER_NAME);
	SCM(playerid,COLOR_WHITE,"Welcome to Montana RolePlay");

	TogglePlayerSpectating(playerid, 0);
	InterpolateCameraPos(playerid, 1285.6528, -2037.6846, 100.6408, 13.4005, -2087.5444, 35.9909, 25000);
	InterpolateCameraLookAt(playerid, 446.5704, -2036.8873, 45.9909, 367.5072, -1855.5072, 11.2946, 25000);

	static const fmt_query[] = "SELECT `password`, `salt` FROM `users` WHERE `name` = '%s'";
	new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)];
	format(query, sizeof(query), fmt_query, player_info[playerid][NAME]);
	mysql_tquery(dbHandle, query, "CheckRegistration", "id", playerid);
	return 1;
}

forward CheckRegistration(playerid);

public CheckRegistration(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows) 
	{
		cache_get_value_name(0, "password", player_info[playerid][PASSWORD], 64);
		cache_get_value_name(0, "salt", player_info[playerid][SALT], 64);
		ShowLogin(playerid);
	}
	else ShowRegistration(playerid);
}

stock ShowLogin(playerid)
{
	new dialog[171+(-2+MAX_PLAYER_NAME)];
	format(dialog, sizeof(dialog),
	"{FFFFFF} Dear {0089ff}%s{FFFFFF}, welcome back to {0089ff}Montana RolePlay!{FFFFFF}\nWe glad to see you back!\nFor continue enter your password in box below:",
	player_info[playerid][NAME]);
	SPD(playerid, DLG_LOG, DIALOG_STYLE_INPUT, "{ffd100}Authorization{FFFFFF}", dialog, "Next","Exit");
}

stock ShowRegistration(playerid)
{
	new dialog[403+(-2+MAX_PLAYER_NAME)];
	format(dialog, sizeof(dialog),
	    "{FFFFFF}Dear {0089ff}%s{FFFFFF}, we are happy to see you in {0089ff}Montana RolePlay!{FFFFFF}\n\
		Account with this nickname is not registered\n\
		to play on the server, you must register\n\n\
		create a complex password for your account and press \"Next\"\n\
		{ff9300}\t* Password must be 8-32 symbols long\n\
		\t* Passwword must contain only numbers and Latin characters",
		player_info[playerid][NAME]
	);
	SPD(playerid, DLG_REG, DIALOG_STYLE_INPUT, "{ffd100}Registration{FFFFFF} *Enter password*", dialog, "Enter","Exit");
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	// 1757.2987,-1896.4974,13.5610,269.7200
	SetPlayerPos(playerid, 1757.2987,-1896.4974,13.5610);
	SetPlayerFacingAngle(playerid, 269.7200);
	SetCameraBehindPlayer(playerid);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
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
	if (strcmp("/tp", cmdtext,true,10) == 0)
 	{
 	    SCM(playerid,COLOR_WHITE,"����");
		ShowPlayerDialog(playerid,DLG_TP,DIALOG_STYLE_LIST,"���� �����","LS\nSF\nLV","�����","�����");
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
	switch(dialogid)
	{
	    case DLG_TP:
	    {
			switch(listitem)
			{
				case 0:
				{
					SetPlayerPos(playerid, 1757.2987,-1896.4974,13.5610,269.7200);
					SCM(playerid, COLOR_WHITE, "You have been teleported in Los-Santos");
				}
	  			case 1:
				{
     				SetPlayerPos(playerid, -1965.9000000,105.2000000,27.5000000);
					SCM(playerid, COLOR_WHITE, "You have been teleported in San-Fierro");
				}
	 			case 2:
				{
					SetPlayerPos(playerid, 1964.0826,-1145.1964, 25.9823);
					SCM(playerid, COLOR_WHITE, "You have been teleported in Las-Venturas");
				}
			}
		}
  		case DLG_REG:
  		{
  		    if(response)
  		    {
				if(!strlen(inputtext))
				{
				    ShowRegistration(playerid);
				    return SCM(playerid,COLOR_RED, "[Error] {FFFFFF}Enter correct paswword");
				}
				if(!(8 <= strlen(inputtext) <= 32))
				{
					ShowRegistration(playerid);
				    return SCM(playerid,COLOR_RED, "[Error] {FFFFFF}Password must be 8 - 32 symbols!");
				}
				new regex:rg_passwordcheck = regex_new("^[a-zA-Z0-9]{1,}$");
				if(regex_check(inputtext,rg_passwordcheck))
				{	
					
					new salt[11];
					for(new i; i < 10; i++)
					{
						salt[i] = random(79)+(47);
					}
					salt[10] = 0;
					SHA256_PassHash(inputtext,salt,player_info[playerid][PASSWORD],65);
					strmid(player_info[playerid][SALT], salt, 0, 11, 11);
					SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,"{ff9300}Registration{FFFFFF} * Enter Email",
					"{FFFFFF}\t\t\tEnter your real email\n\
					If you loss access to your account, you can restore it by your email\n\
					\t\tEnter your email in box below and press \"Next\"",
					"Next", "");
				}
				else
				{
					ShowRegistration(playerid);
					regex_delete(rg_passwordcheck);
	    			return SCM(playerid,COLOR_RED, "[Error] {FFFFFF}Password can contain only latin characters and numbers!");
				}
				regex_delete(rg_passwordcheck);
			}
			else
			{
			    SCM(playerid, COLOR_RED,"Use \"/q\", to leave server");
			    SPD(playerid,-1,0, " ", " ", " ", "");
			    return Kick(playerid);
			}
  		}
  		case DLG_REGEMAIL:
  		{
  		    if(!strlen(inputtext))
  		    {
					SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT, "{ff9300}Registration{FFFFFF} * Enter Email",
					"{FFFFFF}\t\t\tEnter your real email\n\
					If you loss access to your account, you can restore it by your email\n\
					\t\tEnter your email in box below and press \"Next\"",
					"Next", "");
                    return SCM(playerid,COLOR_RED, "[Error] {FFFFFF}Enter your email in box below and press \"Next\"");
			}
			new regex:rg_emailcheck = regex_new("^[a-zA-Z0-9.-_]{1,43}@[a-zA-Z]{1,12}.[a-zA-Z]{1,8}$");
	  	    if(regex_check(inputtext,rg_emailcheck))
	  	    {
	  	        strmid(player_info[playerid][EMAIL], inputtext, 0, strlen(inputtext), 64);
	  	        SPD(playerid,  DLG_REGREF, DIALOG_STYLE_INPUT, "{ff9300}Registration{FFFFFF} * Enter invite",
				"{FFFFFF}If you joined server by invite, then\n\
				you can specify nickname who invited you in box below:",
				"Next", "Skip"
				);
	  	    }
	  	    else
			{
				SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,"{ff9300}Registration{FFFFFF} * Enter Email",
				"{FFFFFF}\t\t\tEnter your real email\n\
				If you loss access to your account, you can restore it by your email\n\
				\t\tEnter your email in box below and press \"Next\"",
				"Next", "");
				regex_delete(rg_emailcheck);
    			return SCM(playerid,COLOR_RED, "[Error] {FFFFFF}Enter correct email");
			}
			regex_delete(rg_emailcheck);
		}
		case DLG_REGREF:
		{
			if(response)
			{
				static const fmt_query[] = "SELECT * FROM `users` WHERE `nick` = '%s'";
				new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)];
				format(query, sizeof(query), fmt_query, inputtext);
				mysql_tquery(dbHandle, query, "CheckReferal", "is", playerid, inputtext);
			}
			else
			{
				SPD(playerid, DLG_REGSEX, DIALOG_STYLE_MSGBOX, "����������� - ����� ����", "����� ���� ������ ���������", "�������", "�������");
			}
		}
		case DLG_REGSEX:
		{
			player_info[playerid][SEX] = (response) ? (1) : (2);
			SPD(playerid,DLG_REGRACE, DIALOG_STYLE_LIST, "����������� - ����� ���� ���������", "����������\n������������\n���������", "�����", "");
		}
		case DLG_REGRACE:
		{
		    player_info[playerid][RACE] = listitem + 1;
			SPD(playerid,DLG_REGAGE, DIALOG_STYLE_INPUT, "����������� - ����� �������� ���������","������� ������� ���������", "�����", "");
		}
		case DLG_REGAGE:
		{
			if(!strlen(inputtext))
			{
				SPD(playerid,DLG_REGAGE, DIALOG_STYLE_INPUT, "����������� - ����� �������� ���������","������� ������� ���������", "�����", "");
				return SCM(playerid, COLOR_RED, "[������] �� �� ����� ��� �������!");
			}
			if (!(18 <= strval(inputtext) <= 60))
			{
				SPD(playerid,DLG_REGAGE, DIALOG_STYLE_INPUT, "����������� - ����� �������� ���������","������� ������� ���������", "�����", "");
				return SCM(playerid, COLOR_RED, "[������] ������� ������� �� 18 �� 60 ��� �������!");
			}
			player_info[playerid][AGE] = strval(inputtext);

			new regmaleskins[9][4] = 
			{
				{19,21,22,28}, // Negro 18-29
				{24,25,36,67}, // Negro 30-45
				{14,142,182,183}, // Negro 46-60
				{29,96,101,26}, // Europian 18-29
				{2,37,72,202}, // Europian 30-45
				{1,3,234,290}, // Europian 46-60
				{23,60,170,180}, // Asian 18-29
				{20,47,48,206}, // Asian 30-45
				{44,58,132,229} // Asian 46-60
			};
			new regfemaleskins[9][2] =
			{
				{13,69}, // Negro 18-29
				{9,160}, // Negro 30-45
				{10,218}, // Negro 46-60
				{41,59}, // Europian 18-29
				{31,151}, // Europian 30-45
				{39,89}, // Europian 46-60
				{169,193}, // Asian 18-29
				{207,225}, // Asian 30-45
				{54,130} // Asian 46-60
			};
			new newskinindex;
			switch(player_info[playerid][RACE])
			{
				case 1: {}
				case 2: newskinindex+=3;
				case 3: newskinindex+=6;
			}
			switch(player_info[playerid][AGE])
			{
				case 18..29: {}
				case 30..45: newskinindex++;
				case 46..60: newskinindex+=2;
			}
			if(player_info[playerid][SEX] == 1) player_info[playerid][SKIN] = regmaleskins[newskinindex][random(4)];
			else player_info[playerid][SKIN] = regfemaleskins[newskinindex][random(2)];
			new Year, Month, Day;
			getdate(Year, Month, Day);
			SCM(playerid,COLOR_BLUE,"аллооооооо ���������, �������� ����");
			new date[13];
			format(date, sizeof(date),"%02d.%02d.%02d", Day, Month, Year);
			new ip[16];
			GetPlayerIp(playerid, ip,sizeof(ip));

			static const fmt_query[] = "INSERT INTO `users` (`nick`,`password`,`salt`,`email`,`ref`,`sex`,`race`,`age`,`skin`,`regdata`,`regip`) VALUES ('%s','%s','%s','%s','%d','%d','%d','%d','%d','%s','%s')";
			new query[sizeof(fmt_query)+(2-MAX_PLAYER_NAME)+(-2+64)+(2+10)+(-2+64)+(-2+8)+(-2+1)+(-2+1)+(-2+2)+(-2+3)+(-2+12)+(-2+15)];
			format(query, sizeof(query), fmt_query, player_info[playerid][NAME],player_info[playerid][PASSWORD],player_info[playerid][SALT],player_info[playerid][EMAIL], player_info[playerid][REF], player_info[playerid][SEX],player_info[playerid][RACE],player_info[playerid][AGE],player_info[playerid][SKIN],date, ip);
			mysql_query(dbHandle, query);

			static const fmt_query2[] = " SELECT * FROM `users` WHERE `name` = '%s' AND `password` = '%s'";
			format(query, sizeof(query), fmt_query2, player_info[playerid][NAME],player_info[playerid][PASSWORD]);
			mysql_tquery(dbHandle, query, "PlayerLogin", "id", playerid);
		}
		case DLG_LOG:
		{
			if (response)
			{
				new checkpass[65];
				SHA256_PassHash(inputtext,player_info[playerid][SALT], checkpass, 65);
				if (!strcmp(player_info[playerid][PASSWORD], checkpass))
				{
					SCM(playerid, COLOR_BLUE, "CORRECT PASSWORD");
				}
				else
				{
					SCM(playerid, COLOR_BLUE, "INCORRECT PASSWORD");
					ShowLogin(playerid);
				}
			}
			else
			{
			    SCM(playerid, COLOR_RED,"Use \"/q\", to leave server");
			    SPD(playerid,-1,0, " ", " ", " ", "");
			    return Kick(playerid);
			}
		}
	}
	return 1;
}

forward PlayerLogin(playerid);
public PlayerLogin(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if (rows)
	{
	    cache_get_value_name_int(0, "id", player_info[playerid][ID]);
	    cache_get_value_name(0, "email", player_info[playerid][EMAIL], 64);
	    cache_get_value_name_int(0, "ref", player_info[playerid][REF]);
	    cache_get_value_name_int(0, "sex", player_info[playerid][SEX]);
	    cache_get_value_name_int(0, "race", player_info[playerid][RACE]);
	    cache_get_value_name_int(0, "age", player_info[playerid][AGE]);
	    cache_get_value_name_int(0, "skin", player_info[playerid][SKIN]);
	    cache_get_value_name(0, "regdata", player_info[playerid][REGDATA], 12);
	    cache_get_value_name(0, "regip", player_info[playerid][REGIP], 15);

	    TogglePlayerSpectating(playerid, 0);
		SetPVarInt(playerid, "logged", 1);
		SetSpawnInfo(playerid, 0, 1757.1808,-1896.0137,13.5563, 0, 0, 0, 0, 0, 0, 0, 0);
		SpawnPlayer(playerid);
	}
	return 1;
}

forward CheckReferal(playerid,referal[]);
public CheckReferal(playerid,referal[])
{
	new rows;
	cache_get_row_count(rows);
	if(rows)
	{
		cache_get_value_name_int(0, "id", player_info[playerid][REF]);
		SPD(playerid, DLG_REGSEX, DIALOG_STYLE_MSGBOX, "����������� - ����� ����", "����� ���� ������ ���������", "�������", "�������");
	}
	else
	{
		SPD(playerid,  DLG_REGREF, DIALOG_STYLE_INPUT, "����������� - ���� �������������",
		"���� ��� ���������� ������� ��� ������������� � ���� �����:",
		"�����", "����������"
		);
	    return SCM(playerid, COLOR_RED, "[������] {FFFFFF}������ ������ �� ����������! ");
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ) {
	SetPlayerPos(playerid, fX, fY, fZ);
	return 1;
}

CMD:spawn(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	SetPVarInt(playerid, "logged", 1);
	SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
}


//----------------------------------------------------------------------------------
//----------------------------------------------------------------------------------
stock CreateMapping(){
	//RemoveBuildingForPlayer(playerid, 1226, 1774.760, -1901.540, 16.375, 0.250);

	//------------------ SPAWN
	new tmpobjid, object_world = -1, object_int = -1;
	tmpobjid = CreateObject(19866, 1793.992431, -1889.548583, 12.349825, 0.000000, 0.000000, 90.000000, 300.00); 
	SetObjectMaterial(tmpobjid, 0, 4552, "ammu_lan2", "sl_lavicdtwall1", 0x00000000);
	tmpobjid = CreateObject(19866, 1789.029541, -1889.548583, 12.349825, 0.000000, 0.000000, 90.000000, 300.00); 
	SetObjectMaterial(tmpobjid, 0, 4552, "ammu_lan2", "sl_lavicdtwall1", 0x00000000);
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	tmpobjid = CreateDynamicObject(3850, 1774.066650, -1903.396972, 13.076414, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1774.066650, -1907.067749, 13.076414, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1774.066650, -1910.718261, 13.076414, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1774.066650, -1914.569091, 13.076414, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1774.066650, -1918.309692, 13.076414, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1774.066650, -1922.010742, 13.076414, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1774.066650, -1925.703125, 13.076414, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1774.066650, -1929.413818, 13.076414, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1774.066650, -1933.104248, 13.076414, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1776.050903, -1935.853515, 13.095973, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1779.651123, -1935.853515, 13.095973, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1783.290039, -1935.853515, 13.095973, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1786.973510, -1935.853515, 13.095973, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1790.665283, -1935.853515, 13.095973, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1794.296508, -1935.853515, 13.095973, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1797.946777, -1935.853515, 13.095973, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1801.597412, -1935.853515, 13.095973, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1805.269165, -1935.853515, 13.095973, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1806.944702, -1933.856079, 13.075716, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1806.944702, -1930.224609, 13.075716, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1806.944702, -1926.603637, 13.075716, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1806.944702, -1922.902465, 13.075716, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1806.944702, -1919.292236, 13.075716, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1806.944702, -1915.711303, 13.075716, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1806.944702, -1912.070678, 13.075716, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1806.944702, -1908.489868, 13.075716, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1806.944702, -1904.778442, 13.075716, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1806.944702, -1901.097045, 13.075716, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1570, 1770.702148, -1909.392089, 13.777422, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(717, 1773.250976, -1935.776489, 12.735418, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(792, 1773.509887, -1900.599853, 12.716081, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(792, 1773.509887, -1892.670410, 12.716081, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1774.066650, -1890.261962, 13.076414, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1774.066650, -1886.511596, 13.076414, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1346, 1768.717407, -1906.507446, 13.897356, 0.000000, 0.000000, 180.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1215, 1772.402465, -1900.655151, 13.106122, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1215, 1772.402465, -1892.864379, 13.106122, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(968, 1811.271728, -1885.769653, 13.304050, 0.000000, -90.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(966, 1811.247192, -1885.859985, 12.394067, 0.000000, 0.000000, 450.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3850, 1811.419799, -1897.692016, 13.127448, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1346, 1767.296752, -1906.507446, 13.897356, 0.000000, 0.000000, 180.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1777.767578, -1932.970092, 11.606529, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1781.467529, -1932.970092, 11.606529, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1785.140869, -1932.970092, 11.606529, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1788.814453, -1932.970092, 11.606529, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1792.477905, -1932.970092, 11.606529, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1796.110839, -1932.970092, 11.606529, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1799.762573, -1932.970092, 11.606529, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1803.454467, -1932.970092, 11.606529, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1770.109375, -1893.315429, 13.203907, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(956, 1764.474487, -1906.616333, 12.966359, 0.000000, 0.000000, 180.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1770.109375, -1892.374633, 13.203907, 0.000000, 0.000000, 270.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1215, 1767.929077, -1892.864379, 13.106122, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1765.698242, -1892.374633, 13.203907, 0.000000, 0.000000, 270.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1765.710937, -1893.315429, 13.203907, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1215, 1763.668334, -1892.864379, 13.106122, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1761.649658, -1893.315429, 13.203907, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1761.656738, -1892.374633, 13.203907, 0.000000, 0.000000, 270.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(792, 1759.073974, -1892.670410, 12.716081, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2671, 1769.027343, -1897.271118, 12.600325, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1770.109375, -1900.138183, 13.203907, 0.000000, 0.000000, 270.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1770.109375, -1901.129272, 13.203907, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1215, 1767.929077, -1900.665527, 13.106122, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2673, 1769.770874, -1896.034912, 12.564339, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2673, 1760.643188, -1895.227905, 12.560855, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1765.587768, -1900.138183, 13.203907, 0.000000, 0.000000, 270.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2673, 1760.109985, -1899.672241, 12.563353, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1215, 1763.528198, -1900.665527, 13.106122, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1765.598022, -1901.129272, 13.203907, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1761.678588, -1901.129272, 13.203907, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1256, 1761.656738, -1900.145263, 13.203907, 0.000000, 0.000000, 270.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1372, 1757.943847, -1908.738647, 12.738270, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(792, 1759.073974, -1900.673828, 12.716081, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1415, 1760.167968, -1908.671386, 12.568595, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1211, 1809.598999, -1897.750732, 13.078122, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(4642, 1809.642333, -1883.146118, 14.227702, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1237, 1811.525390, -1894.497924, 12.358116, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1257, 1791.579833, -1883.477661, 13.828002, 0.000000, 0.000000, 90.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1215, 1796.458251, -1889.556274, 12.921508, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1215, 1786.567504, -1889.556274, 12.921508, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1786.565063, -1887.756469, 11.616507, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1786.565063, -1884.254638, 11.606508, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1796.477783, -1884.254638, 11.606508, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(19430, 1796.473999, -1887.756469, 11.616507, 90.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 

	
	// *******************************************GETTO
	tmpobjid = CreateDynamicObject(1450, 1850.557006, -1888.608276, 13.014596, 0.000000, 0.000000, 157.599914, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2677, 1836.421752, -1882.046020, 12.711181, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2677, 1847.898193, -1885.630615, 12.701185, 0.000000, 0.000000, 81.999992, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3005, 1839.846679, -1887.420898, 12.455517, 0.000000, 0.000000, 38.799995, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1264, 1838.180175, -1888.564697, 12.784630, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(910, 1854.640869, -1888.813964, 13.658405, 0.000000, 0.000000, 180.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3496, 1863.662597, -1888.378417, 12.230747, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2114, 1863.336914, -1887.512695, 15.325038, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(910, 1880.932861, -1888.813964, 13.658405, 0.000000, 0.000000, 180.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3005, 1871.998413, -1888.445922, 12.455517, 0.000000, 0.000000, 98.799995, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1478, 1862.252685, -1880.288208, 12.503467, 0.000000, 88.300025, -34.099998, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1448, 1857.608398, -1888.627075, 12.511466, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(911, 1891.742797, -1888.577758, 13.050415, 0.000000, 0.000000, -158.199890, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3119, 1892.182373, -1889.470581, 13.921296, 0.000000, 0.000000, -20.399995, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(3119, 1892.182373, -1889.470581, 13.921296, 0.000000, 0.000000, -20.399995, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(924, 1878.750122, -1880.272094, 12.802047, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(924, 1879.729370, -1880.772460, 12.802047, 0.000000, 0.000000, 29.900001, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(924, 1878.099853, -1880.584594, 12.802047, 0.000000, 0.000000, -40.899993, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2673, 1871.655395, -1883.752807, 12.565493, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2672, 1891.119018, -1886.319458, 12.778179, 0.000000, 0.000000, 80.099983, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2672, 1891.119018, -1886.319458, 12.778179, 0.000000, 0.000000, 80.099983, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2675, 1881.281738, -1888.172729, 12.536482, 0.000000, 0.000000, 82.999870, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1441, 1903.344848, -1888.943969, 13.217306, 0.000000, 0.000000, -174.600021, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1349, 1913.981689, -1887.218383, 13.031640, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1442, 1867.935058, -1880.072143, 13.012593, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2900, 1881.073364, -1880.788940, 12.464941, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2674, 1845.422729, -1883.675415, 12.431713, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2674, 1861.085815, -1883.347778, 12.445068, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2674, 1874.369995, -1887.765380, 12.473694, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2674, 1889.149658, -1881.566406, 12.472494, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2673, 1866.597290, -1884.225830, 12.452395, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2673, 1850.566406, -1886.289428, 12.436694, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2673, 1837.202636, -1887.174682, 12.423648, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2673, 1855.653808, -1888.769653, 12.457224, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2673, 1908.636596, -1886.373168, 12.508777, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1344, 1929.936401, -1887.948364, 13.316290, 0.000000, 0.000000, 270.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(2670, 1928.533935, -1885.405395, 12.606737, 0.000000, 0.000000, 0.000000, object_world, object_int, -1, 300.00, 300.00); 
	tmpobjid = CreateDynamicObject(1428, 1938.701538, -1887.633422, 13.906238, 0.000000, 0.000000, 90.300010, object_world, object_int, -1, 300.00, 300.00); 


}


