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
//=================================== Переменные =============================

//----------------------------------- Мусорка --------------------------------
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
		case 0: print("mySQL запущен!");
		default: print("MySQL не запущен!");
	}
	mysql_log(ERROR | WARNING);
	mysql_set_charset("cp1251");
}

stock CreateVehicles()
{
	AddStaticVehicleEx(420,-1969.9000000,105.1000000,27.5000000,151.9960000,6,142,15); //Taxi
	AddStaticVehicleEx(420,-1977.4000000,104.9000000,27.5000000,151.9960000,6,142,15); //Taxi
	AddStaticVehicleEx(420,-1973.7998000,105.0000000,27.5000000,151.9960000,6,142,15); //Taxi
	AddStaticVehicleEx(420,-1965.9000000,105.2000000,27.5000000,151.9960000,6,142,15); //Taxi

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
	SCM(playerid,COLOR_WHITE,"Добро Пожаловать на Montana RolePlay");
	TogglePlayerSpectating(playerid, 1);

	InterpolateCameraPos(playerid, 1280.6528, -2037.6846, 75.6408+5.0, 13.4005, -2087.5444, 35.9909, 25000)
	InterpolateCameraLookAt(playerid, 446.5704, -2036.8873, 35.9909-5.0, 367.5072, -1855.5072, 11.2946, 25000)

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
	new dialog(171(-2+MAX_PLAYER_NAME));
	format(dialog, sizeof(dialog),
	"{FFFFFF} Уважаемый {0089ff}%s{FFFFFF}, с возвращением на {0089ff}Montana RolePlay!{FFFFFF}\n\
	\tМы рады снова видеть вас!\n\n\
	Для продолжения введите свой пароль в поле ниже:",
	player_info[playerid][NAME]
	);
	SPD(playerid, DLG_LOG, DIALOG_STYLE_INPUT, "{ffd100}Авторизация{FFFFFF}", dialog, "далее","отмена");
}

stock ShowRegistration(playerid)
{
	SCM(playerid, COLOR_WHITE, "Такого пользователя нет");
	new dialog[403+(-2+MAX_PLAYER_NAME)];
	format(dialog, sizeof(dialog),
	    "{FFFFFF}Салам ворам! И тебе, {0089ff}%s{FFFFFF}!\nДобро пожаловать на {0089ff}Montana RolePlay!{FFFFFF}\nАккаунт с таким ником не зарегистрирован\nДля игры на серевере, Вы должны пройти регистрацию",
		player_info[playerid][NAME]
	);
	SPD(playerid, DLG_REG, DIALOG_STYLE_INPUT, "{ffd100}Регистрация{FFFFFF} *Введите ваш пароль*", dialog, "далее","отмена");
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
	if (strcmp("/tp", cmdtext,true,10) == 0)
 	{
 	    SCM(playerid,COLOR_WHITE,"Тест");
		ShowPlayerDialog(playerid,DLG_TP,DIALOG_STYLE_LIST,"Куда летим","LS\nSF\nLV","Далее","Выйти");
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
					SetPlayerPos(playerid, 1964.0826,-1145.1964, 25.9823);
					SCM(playerid, COLOR_WHITE, "Вы были телепортированы в LS");
				}
	  			case 1:
				{
     				SetPlayerPos(playerid, -1965.9000000,105.2000000,27.5000000);
					SCM(playerid, COLOR_WHITE, "Вы были телепортированы в SF");
				}
	 			case 2:
				{
					SetPlayerPos(playerid, 1964.0826,-1145.1964, 25.9823);
					SCM(playerid, COLOR_WHITE, "Вы были телепортированы в LS");
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
				    return SCM(playerid,COLOR_RED, "[Ошибка] {FFFFFF}Введите ваш пароль");
				}
				if(!(8 <= strlen(inputtext) <= 32))
				{
					ShowRegistration(playerid);
				    return SCM(playerid,COLOR_RED, "[Ошибка] {FFFFFF}Пароль должен быть от 8 до 32 символов!");
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
					SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,"Регистрация - Ваш Email",
					"Введите ваш email",
					"Далее","");
				}
				else
				{
					ShowRegistration(playerid);
					regex_delete(rg_passwordcheck);
	    			return SCM(playerid,COLOR_RED, "[Ошибка] {FFFFFF}Пароль должен состоять из чисел и латинских букв!");
				}
				regex_delete(rg_passwordcheck);
			}
			else
			{
			    SCM(playerid, COLOR_RED,"Пока");
			    SPD(playerid,-1,0, " ", " ", " ", "");
			    return Kick(playerid);
			}
  		}
  		case DLG_REGEMAIL:
  		{
  		    if(!strlen(inputtext))
  		    {
					SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT, "Регистрация - Ввод Email",
					"Введиет email",
					"Далее","");
                    return SCM(playerid,COLOR_RED, "[Ошибка] {FFFFFF}Введите Ваш email");
			}
			new regex:rg_emailcheck = regex_new("^[a-zA-Z0-9.-_]{1,43}@[a-zA-Z]{1,12}.[a-zA-Z]{1,8}$");
	  	    if(regex_check(inputtext,rg_emailcheck))
	  	    {
	  	        strmid(player_info[playerid][EMAIL], inputtext, 0, strlen(inputtext), 64);
	  	        SPD(playerid,  DLG_REGREF, DIALOG_STYLE_INPUT, "Регистрация - Ввод пригласившего",
				"Если вас пригласили введите ник пригласившего в поле снизу:",
				"Далее", "Пропустить"
				);
	  	    }
	  	    else
			{
				SPD(playerid, DLG_REGEMAIL, DIALOG_STYLE_INPUT,"Регистрация - Введите Email",
				"Введите настоящий Email",
				"Далее","");
				regex_delete(rg_emailcheck);
    			return SCM(playerid,COLOR_RED, "[Ошибка] {FFFFFF}Укажите правильно email");
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
				SPD(playerid, DLG_REGSEX, DIALOG_STYLE_MSGBOX, "Регистрация - Выбор пола", "Выбор пола вашего персонажа", "Мужской", "Женский");
			}
		}
		case DLG_REGSEX:
		{
			player_info[playerid][SEX] = (response) ? (1) : (2);
			SPD(playerid,DLG_REGRACE, DIALOG_STYLE_LIST, "Регистрация - Выбор расы персонажа", "Негроидная\nЕвропеоидная\nАзиатская", "Далее", "");
		}
		case DLG_REGRACE:
		{
		    player_info[playerid][RACE] = listitem + 1;
			SPD(playerid,DLG_REGAGE, DIALOG_STYLE_INPUT, "Регистрация - Выбор возраста персонажа","Введите возраст персонажа", "Далее", "");
		}
		case DLG_REGAGE:
		{
			if(!strlen(inputtext))
			{
				SPD(playerid,DLG_REGAGE, DIALOG_STYLE_INPUT, "Регистрация - Выбор возраста персонажа","Введите возраст персонажа", "Далее", "");
				return SCM(playerid, COLOR_RED, "[Ошибка] Вы не ввели Ваш возраст!");
			}
			if (!(18 <= strval(inputtext) <= 60))
			{
				SPD(playerid,DLG_REGAGE, DIALOG_STYLE_INPUT, "Регистрация - Выбор возраста персонажа","Введите возраст персонажа", "Далее", "");
				return SCM(playerid, COLOR_RED, "[Ошибка] Введите возраст от 18 до 60 Ваш возраст!");
			}
			player_info[playerid][AGE] = strval(inputtext);

			new regmaleskins[9][4] = 
			{
				{19,21,22,28}, // НЕГРОИДНАЯ 18-29
				{24,25,36,67}, // НЕГРОИДНАЯ 30-45
				{14,142,182,183}, // НЕГРОИДНАЯ 46-60
				{29,96,101,26}, // ЕВРОПЕОИДНАЯ 18-29
				{2,37,72,202}, // ЕВРОПЕОИДНАЯ 30-45
				{1,3,234,290}, // ЕВРОПЕОИДНАЯ 46-60
				{23,60,170,180}, // МОНГОЛОИДНАЯ 18-29
				{20,47,48,206}, // МОНГОЛОИДНАЯ 30-45
				{44,58,132,229} // МОНГОЛОИДНАЯ 46-60
			};
			new regfemaleskins[9][2] =
			{
				{13,69}, // НЕГРОИДНАЯ 18-29
				{9,160}, // НЕГРОИДНАЯ 30-45
				{10,218}, // НЕГРОИДНАЯ 46-60
				{41,59}, // ЕВРОПЕОИДНАЯ 18-29
				{31,151}, // ЕВРОПЕОИДНАЯ 30-45
				{39,89}, // ЕВРОПЕОИДНАЯ 46-60
				{169,193}, // МОНГОЛОИДНАЯ 18-29
				{207,225}, // МОНГОЛОИДНАЯ 30-45
				{54,130} // МОНГОЛОИДНАЯ 46-60
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
			SCM(playerid,COLOR_BLUE,"Регистрация завершена, приятной игры");
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
		SetSpawnInfo(playerid, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,)
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
		SPD(playerid, DLG_REGSEX, DIALOG_STYLE_MSGBOX, "Регистрация - Выбор пола", "Выбор пола вашего персонажа", "Мужской", "Женский");
	}
	else
	{
		SPD(playerid,  DLG_REGREF, DIALOG_STYLE_INPUT, "Регистрация - Ввод пригласившего",
		"Если вас пригласили введите ник пригласившего в поле снизу:",
		"Далее", "Пропустить"
		);
	    return SCM(playerid, COLOR_RED, "[Ошибка] {FFFFFF}Такого игрока не существует! ");
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
