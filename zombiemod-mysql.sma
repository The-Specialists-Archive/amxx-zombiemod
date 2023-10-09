#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <engine_stocks>
#include <tsfun>
#include <tsx>
#include <fakemeta>
#include <fun>
#include <dbi>

#define FACTORTIME 60
/*
new tsweaponammo[38] = {0,17,15,32,7,30,30,30,15,12,12,20,7,30,20,30,32,20,5,40,8,16,15,25,1,25,8,18,17,0,20,5,100,2,1,1,1,20}
new tsweaponid[38][32] = {"Kung Fu","Glock 18","Beretta 92F","Mini-Uzi","Benelli M3","M4A1","MP5SD","MP5K","Beretta 92F","SOCOM-MK23","SOCOM-MK23","USAS-12","Desert Eagle","AK47","Five-seveN","STEYR-AUG","Mini-Uzi","Skorpion","Barrett M82A1","MP7-PDW","SPAS-12","Golden Colts","Glock-20C","UMP","M61 Grenade","Combat Knife","Mossberg 500","M16A4","Ruger-MK1","Kung Fu","Five-seveN","Raging Bull","M60E3","Sawed-off","Katana","Seal Knife","Contender G2","Skorpion"
new tsweapontype[38] = {0,1,1,2,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
// weapontype	0 = Melee
//		1 = Pistol
//		2 = Sub-Machine
//		3 = Rifle
//		4 = Shotgun
*/
new thirdperson[33]

new globalfmt[33][180]

new timefactor=0;
//new currentfactor=0;
new playersfactor[34]=0;
//playersfactor[i] = id
new hisfactor[33];

new nemesis = 0


public findavailable(id)
{
	new lol2 = (get_maxplayers()-get_cvar_num("sv_addbots"))
	for(new i=1;i<lol2;i++)
	{
		if(!playersfactor[i])
		{
			playersfactor[i]=id
			return i
		}
	}
	return 5
}

new discounter = 0;

 // Avalanches Ammo Code (Thanks for letting me use it // Set a user's ammo amount
 public ts_setuserammo(id,weapon,ammo) {

   // Kung Fu
   if(weapon == 36) {
     client_cmd(id,"weapon_0"); // switch to kung fu	
     return 0; // stop now
   }

   // Invalid Weapong
   if(weapon < 0 || weapon > 35) {
     return 0; // stop now
   }

   client_cmd(id,"weapon_%d",weapon); // switch to whatever weapon

   // C4 or Katana
   if(weapon == 29 || weapon == 34) {
     return 0; // stop now
   }

   // TS AMMO OFFSETS
   new tsweaponoffset[36];
   tsweaponoffset[1] = 50;
   tsweaponoffset[3] = 50;
   tsweaponoffset[4] = 52;
   tsweaponoffset[5] = 53;
   tsweaponoffset[6] = 50;
   tsweaponoffset[7] = 50;
   tsweaponoffset[8] = 50;
   tsweaponoffset[9] = 51;
   tsweaponoffset[10] = 51;
   tsweaponoffset[11] = 52;
   tsweaponoffset[12] = 54;
   tsweaponoffset[13] = 53;
   tsweaponoffset[14] = 56;
   tsweaponoffset[15] = 53;
   tsweaponoffset[16] = 50;
   tsweaponoffset[17] = 50;
   tsweaponoffset[18] = 57;
   tsweaponoffset[19] = 56;
   tsweaponoffset[20] = 52;
   tsweaponoffset[21] = 51;
   tsweaponoffset[22] = 58;
   tsweaponoffset[23] = 51;
   tsweaponoffset[24] = 354;
   tsweaponoffset[25] = 366;
   tsweaponoffset[26] = 52;
   tsweaponoffset[27] = 53;
   tsweaponoffset[28] = 59;
   tsweaponoffset[30] = 56;
   tsweaponoffset[31] = 61;
   tsweaponoffset[32] = 53;
   tsweaponoffset[33] = 52;
   tsweaponoffset[35] = 486;

   new currentent = -1, tsgun = 0; // used for getting user's weapon_tsgun

   // get origin
   new Float:origin[3];
   entity_get_vector(id,EV_VEC_origin,origin);

   // loop through "user's" entities (whatever is stuck to user, basically)
   while((currentent = find_ent_in_sphere(currentent,origin,Float:1.0)) != 0) {
     new classname[32];
     entity_get_string(currentent,EV_SZ_classname,classname,31);

     if(equal(classname,"weapon_tsgun")) { // Found weapon_tsgun
       tsgun = currentent; // remember it
     }

   }

   // Couldn't find weapon_tsgun
   if(tsgun == 0) {
     return 0; // stop now
   }

   // Get some of their current settings
   new currclip, currammo, currmode, currextra;
   ts_getuserwpn(id,currclip,currammo,currmode,currextra);

   set_pdata_int(tsgun,tsweaponoffset[weapon],ammo); // set their ammo

   // Grenade or knife, set clip
   if(weapon == 24 || weapon == 25 || weapon == 35) {
     set_pdata_int(tsgun,41,ammo); // special clip storage
     set_pdata_int(tsgun,839,ammo); // more special clip storage
     currclip = ammo; // change what we send to WeaponInfo
     ammo = 0; // once again, change what we send to WeaponInfo
   }
   else { // Not a grenade or knife, set ammo
     set_pdata_int(tsgun,850,ammo); // special ammo storage
   }

   // Update user's HUD
   message_begin(MSG_ONE,get_user_msgid("WeaponInfo"),{0,0,0},id);
   write_byte(weapon);
   write_byte(currclip);
   write_short(ammo);
   write_byte(currmode);
   write_byte(currextra);
   message_end();

   return 1; // wooh!
 }
 public set_entity_health(door,Float:hp)
{
	if(hp == -1.0) {
		entity_set_float(door,EV_FL_max_health,99999.0)
		entity_set_float(door,EV_FL_health,99999.0)
		entity_set_float(door,EV_FL_dmg,0.0)
		entity_set_float(door,EV_FL_takedamage,0.0)
		return 1
	}
	entity_set_float(door,EV_FL_max_health,hp)
	entity_set_float(door,EV_FL_health,hp)
	return 1 
}

// The actual creating process


// Creating Ambients
public create_ambient(porigin[3],targetname[],vol[],pitch[],spawnflags,file[])
{
	new ambient = create_entity("ambient_generic")

	if(!ambient) return 0

	entity_set_string(ambient,EV_SZ_classname,"ambient_generic")
	entity_set_int(ambient,EV_INT_spawnflags,spawnflags)
	entity_set_float(ambient,EV_FL_health,10.0)
	entity_set_string(ambient,EV_SZ_targetname,targetname)
	entity_set_string(ambient,EV_SZ_message,file)

	DispatchKeyValue(ambient,"pitch",pitch)
	DispatchKeyValue(ambient,"volstart",vol)
	DispatchKeyValue(ambient,"pitchstart",pitch)
	DispatchSpawn(ambient)

	new Float:origin[3]
	origin[0] = float(porigin[0])
	origin[1] = float(porigin[1])
	origin[2] = float(porigin[2])

	entity_set_origin(ambient,origin)

	return ambient;
}

new line[33]
new Sql:dbc
new Result:result
stock explode( output[][], input[], delimiter)
{
	new nIdx = 0
	new iStringSize
	while ( input[iStringSize] ) 
		iStringSize++ 
	new nLen = (1 + copyc( output[nIdx], iStringSize-1, input, delimiter ))

	while( nLen < strlen(input) )
		nLen += (1 + copyc( output[++nIdx], iStringSize-1, input[nLen], delimiter ))
	return nIdx + 1
}

public is_user_database(steamid[]) {
	new query[256]
	format(query,255,"SELECT level FROM users WHERE steamid = '%s'",steamid)
	result = dbi_query(dbc,query)
	if( dbi_nextrow( result ) > 0 ) return 1
	dbi_free_result(result)
	return 0
}

#define skillfactor 10000
#define lowlevel 1
#define mediumlevel 10
#define highlevel 20
#define ultimatelevel 28

new g_level[33]
new exp[33]
new slots[33]
new curslots[33]

new zombie[33]
new Float:newspeed[33]
new Float:oldspeed[33]
new frags[33]

// RADIO MOD
/*new radio
new notdone[33]
new currentsong[33]
new wow[10][64]
new wow2[10][32]*/
// RADIO MOD

//
new lastorig[33][3]
new killsinspot[33]
new lastexp[33]
new heightcheck[33]
//

new objective[33][64]
new objectivedone[33] = 0
new objectivereward[33] = 0

new speed[33]
new gravity[33]
new glow[33]
new special[33]
new rerate[33]
new curspeed[33]
new curgravity[33]
// Weapons
new laser[33] = 0
new silencer[33] = 0
new scope[33] = 0
new flashlight[33] = 0
new added[33] = 0
new ztype[33] = 0;


/*
	message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, id)
	write_byte(id)
	write_string("^x03Team colored text ^x01Normal color")
	message_end()

*/
new lightning
public plugin_precache()
{
	precache_model("models/player/collector-zombie/collector-zombie.mdl")
	precache_model("models/player/collector-zombie/collector-zombie.mdl")
	//precache_model("models/rdm_chnvase.mdl")
	precache_sound("ambience/thunder_clap.wav")
	lightning = precache_model("sprites/lgtning.spr")
	new szFilename[64] = "radio.ini"
	if(!file_exists(szFilename)) return PLUGIN_HANDLED

/*	new szText[256]
	new a, pos = 0,lol = 0
	while ( read_file(szFilename,pos++,szText,255,a) && lol < 10 )
	{         
		if(equal(szText,"") || equal(szText," ") || szText[0] == ';') continue;
		new file[2][64]
		explode(file,szText,'*')
		precache_sound(file[0])
		wow[lol] = file[0]
		format(wow2[lol],31,file[1])
		lol++
	}*/
	return PLUGIN_HANDLED
}
new entz;
new entz2;
new const g_lights[25][2] = { "a", "a", "a", "a", "a", "b", "c", "d", "e", "f", "g", "h", "h", "h", "h", "h", "h", "h", "h", "f", "d", "a", "a", "a", "a" };
new const g_fog[25] = {0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0};
new const g_onlight[25] = {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1}
new g_internal_hour;
new dolights=0;
new lighton=1;
public plugin_init() {
	register_plugin("Zombie Mod","v1.596","StevenlAFl")

	register_concmd("amx_setfrags","setfrags",ADMIN_CVAR,"<name> <frags>")
	register_concmd("amx_invis","amx_invis",ADMIN_CFG,"<name> <0/1>")
	register_concmd("amx_noclip","amx_noclip",ADMIN_BAN,"<name> <1/0>")
	register_concmd("amx_forceuse","useany",ADMIN_CFG,"<entid>")
	register_concmd("amx_ssay","amx_ssay",ADMIN_CHAT,"<message>")
	register_concmd("amx_alldropweapons","domayhem",ADMIN_IMMUNITY,"")
	register_concmd("amx_giveweapon","amx_giveweapon",ADMIN_CFG,"<name> <weaponid> <clips> <flags>")
	register_concmd("amx_givepwup","givepwup",ADMIN_CFG,"<name> <pwupid>")
	register_concmd("amx_execclient","execclient",ADMIN_BAN,"<name/steamid/#id> <command>")
	register_concmd("amx_execall","execall",ADMIN_BAN,"<command> <flags>")
	register_concmd("amx_createspawn","addspawn",ADMIN_IMMUNITY,"<weaponid> <extraclips> <spawnflags>")
	register_concmd("amx_lookup","lookup",ADMIN_ADMIN,"<name>")
	register_concmd("amx_zombiemassacre","zombiemassacre",ADMIN_IMMUNITY,"")
	register_concmd("amx_setcash","amx_setcash",ADMIN_CFG,"<name> <cash>")
	register_concmd("amx_setlevel","amx_setlevel",ADMIN_CVAR,"<name> <level>")
	register_concmd("amx_setexp","amx_setexp",ADMIN_CVAR,"<name> <level>")
	register_concmd("set_user_rendering","rendering",ADMIN_CVAR,"<r> <g> <b> <fx> <render> <amount>")
	register_concmd("amx_setmodel","setmodel",ADMIN_RCON,"")

	register_forward(FM_GetGameDescription,"GameDesc");

/*	register_clcmd("say /weapon", "defaultgun", 0, "Spawns player a random gun")
	register_clcmd("say /laser", "laserer", -1)
	register_clcmd("say /flashlight", "flashlighter", -1)
	register_clcmd("say /silencer", "silencerer", -1)
	register_clcmd("say /scope", "scoper", -1)
	register_clcmd("say /ruger", "ruger", -1)
	register_clcmd("say /deagle", "deagle", -1)
	register_clcmd("say /socom", "socom", -1)
	register_clcmd("say /akimbos", "akimbo", -1)
	register_clcmd("say /colts", "colts", -1)
	register_clcmd("say /fiveseven", "fiveseven", -1)
	register_clcmd("say /glock18", "glock18", -1)
	register_clcmd("say /glock20c", "glock20c", -1)
	register_clcmd("say /pistol", "randompistol", -1)
	register_clcmd("say /resetflags", "resetflags", -1)
	register_clcmd("say /m3", "givem3", -1)
	register_clcmd("say /uzi", "uzis", -1)
	register_clcmd("say /ak47", "ak47", -1)
	register_clcmd("say /m4a1", "m4a1", -1)
	register_clcmd("say /autoshottie", "autoshottie", -1)
	register_clcmd("say /mp5sd", "mp5sd", -1)
	register_clcmd("say /mp5k", "mp5k", -1)
	register_clcmd("say /barret", "barret", -1)
	register_clcmd("say /m60", "m60", -1)
	register_clcmd("say /ragingbull", "ragingbull", -1)
	register_clcmd("say /grenade", "grenade", -1)
	register_clcmd("say /motd", "motd", -1)
	register_clcmd("say /resetexp", "resetexp", -1)
	register_clcmd("say /help", "help", -1)
	register_clcmd("say /ammo", "ammo", -1)
	register_clcmd("say /m16", "m16", -1)
	register_clcmd("say /sawedoff", "sawedoff", -1)
	register_clcmd("say /aug", "aug", -1)
	register_clcmd("say /spas12", "spas12", -1)
	register_clcmd("say /katana", "katana", -1)
	register_clcmd("say /knife", "knife", -1)
	register_clcmd("say /seal", "seal", -1)
	register_clcmd("say /mossberg", "mossberg", -1)
	register_clcmd("say /tmp", "tmp", -1)
	register_clcmd("say /mac10","mac10",-1)
	register_clcmd("say /mp7","mp7",-1)
	register_clcmd("say /showoff", "showoff", -1)
	register_clcmd("say /speed", "speedup",-1)
	register_clcmd("say /createradio", "createradio",-1)
	register_clcmd("say /setradio", "setradio",-1)
	register_clcmd("say /removeradio", "removeradio",-1)
	register_clcmd("say /radiomenu", "showMenuradio",-1)
	register_clcmd("say /weaponsmenu","showMenuWeapons",-1)
	register_clcmd("say /riflemenu","showMenuRifle",-1)
	register_clcmd("say /submachinemenu","showMenuSub",-1)
	register_clcmd("say /pistolmenu","showMenuPistol",-1)
	register_clcmd("say /heavymenu","showMenuHeavy",-1)
	register_clcmd("say /ztop","ztop",-1)
	//register_clcmd("say /gravity", "gravup",-1)*/
	register_clcmd("say","handle_say",-1);

	register_srvcmd("spawn_nemesis","nemesis2")
	register_srvcmd("set_objective","amx_objective")
	register_srvcmd("set_objectivestatus","amx_objectivestatus")
	register_srvcmd("amx_addmessage","addmessage")
	register_srvcmd("amx_removemessage","removemessage")

	register_cvar("zombiemod_mysql_host","127.0.0.1",FCVAR_PROTECTED)
	register_cvar("zombiemod_mysql_user","root",FCVAR_PROTECTED)
	register_cvar("zombiemod_mysql_pass","",FCVAR_PROTECTED)
	register_cvar("zombiemod_mysql_db","zombiemod",FCVAR_PROTECTED)
	
	register_cvar("usersfile","users.ini")
	register_cvar("sv_addbots","20")
	register_cvar("sv_expdivision","6.0");
	register_cvar("sv_expmultiplication","2.0");

	register_cvar("sv_remove_groundweapon","0")
	register_cvar("sv_remove_doors","0")
	register_cvar("sv_remove_breakable","0")
	register_cvar("sv_remove_train","0")
	register_cvar("sv_remove_button","0")
	register_cvar("sv_remove_powerup","0")

	register_cvar("hud_pos_x","-1.9")	// X Position of ZombieMod on players screen
	register_cvar("hud_pos_y","0.55")	// Y Position of ZombieMod on players screen
	register_cvar("hud_red","0")		// Hud Colors
	register_cvar("hud_green","175")
	register_cvar("hud_blue","0")
	
	register_cvar("info_hud_pos_x","0.45")	// X Position of info on players screen
	register_cvar("info_hud_pos_y","0.84")	// Y Position of info on players screen
	register_cvar("info_hud_red","200")		// Hud Colors
	register_cvar("info_hud_green","200")
	register_cvar("info_hud_blue","200")
	
	register_cvar("sv_grammar","1")
	//register_cvar("sv_radio","0")

	register_cvar("sv_playerzombie_hp","300")
	register_cvar("sv_computerzombie_hp","100")
	register_cvar("sv_player_hp","100");
	register_cvar("sv_zombieknife","0")
	register_cvar("sv_parasite","0")
	register_cvar("sv_nemesis","1")
	register_cvar("sv_zombie_throwknives","0")
	register_cvar("sv_player_throwknives","1")
	register_cvar("sv_campingprotection","1")
	register_cvar("sv_campingstrikedown","1")
	register_cvar("sv_useslots","1")
	register_cvar("sv_superjump","1")
	register_cvar("sv_kungfu","1")
	register_cvar("sv_useopen","1")

	register_statsfwd(XMF_DAMAGE)
	register_forward(FM_SetClientMaxspeed, "forward_SetClientMaxspeed")
	register_event("DeathMsg","death_msg","a")
	register_event("ResetHUD","spawn_msg", "be")
	register_event("WeaponInfo",	"event_WeaponInfo",	"b")

	register_menucmd(register_menuid("Category"),1023,"actionMenuweapons")
	register_menucmd(register_menuid("Pistols"),1023,"actionMenuPistol")
	register_menucmd(register_menuid("Sub-Machine Guns"),1023,"actionMenuSub")
	register_menucmd(register_menuid("Shotguns"),1023,"actionMenuShotgun")
	register_menucmd(register_menuid("Rifles"),1023,"actionMenuRifle")
	register_menucmd(register_menuid("Heavy Weapons"),1023,"actionMenuHeavy")
	//register_menucmd(register_menuid("Radio Mod"),1023,"actionradio")

//Section to have cvars for weapons
	register_cvar("sv_deagle_level","1")
	register_cvar("sv_socom_level","1")
	register_cvar("sv_beretta_level","1")
	register_cvar("sv_colts_level","1")
	register_cvar("sv_glock18_level","1")
	register_cvar("sv_glock20c_level","1")
	register_cvar("sv_fiveseven_level","1")
	register_cvar("sv_ruger_level","1")
	register_cvar("sv_m3_level","1")
	register_cvar("sv_uzis_level","1")
	register_cvar("sv_aug_level","4")
	register_cvar("sv_spas12_level","2")
	register_cvar("sv_mossberg_level","4")
	register_cvar("sv_katana_level","1")
	register_cvar("sv_ump_level","2")
	register_cvar("sv_mp7_level","3")
	register_cvar("sv_m16_level","4")
	register_cvar("sv_ak47_level","3")
	register_cvar("sv_m4a1_level","5")
	register_cvar("sv_barret_level","9")
	register_cvar("sv_mp5sd_level","2")
	register_cvar("sv_mp5k_level","2")
	register_cvar("sv_ragingbull_level","12")
	register_cvar("sv_m60_level","9")
	register_cvar("sv_sawedoff_level","2")
	register_cvar("sv_grenade_level","12")
	register_cvar("sv_autoshottie_level","7")
	register_cvar("sv_skorpion_level","7")
	register_cvar("sv_contender_level","18")
	
	register_cvar("sv_pistol_level","1")
	register_cvar("sv_smg_level","1")
	register_cvar("sv_shotgun_level","1")
	register_cvar("sv_rifle_level","1")
	
	register_cvar("sv_grenade_timer","120");
	set_objective(0,"Kill 50 zombies",150)

	set_task(2.0,"lologram")

	set_task(2.0,"hudmsg",0,"",0,"b")
	set_task(1.0,"info_hud_show",0,"",0,"b")
	set_task(1.0,"setcolors",0,"",0,"b")
	set_task(0.25,"seelevels",0,"",0,"b")
	set_task(5.0,"recharge",0,"",0,"b")
	//set_task(30.0,"saveall",0,"",0,"b")
	set_task(360.0,"nemesis2",0,"",0,"b")
	set_task(1.0,"sql_init")
	
	set_msg_block(122,1) //round time
	set_msg_block(66,1) //selammo
	set_msg_block(90,1) //hideweapon
	set_msg_block(82,1) // teaminfo
	new map[64]
	get_mapname(map,63)
	server_print("%s",map)
	if(equali(map,"MecklenburgV_SnowFinal"))
	{
		server_print("yes")
		set_task( 30.0, "advance_light", g_internal_hour, "", 0, "b" );
		dolights = 1;
	}
	format(map,63,"map %s",map)
	
	if(containi(map, "ts_") != -1)
		write_file("crashed.cfg",map,0)
	
	new configsDir[64]
	get_configsdir(configsDir, 63)
	
	server_cmd("exec %s/ZombieMod/zombiemod_config.cfg",configsDir)
}

public GameDesc()
{
    forward_return(FMV_STRING,"Zombie DM");
    return FMRES_SUPERCEDE;
}

new infomessage[33][3][128]
new msgnum[33] = 0;
new waitm[33] = 0;

public info_add_msg(id,message[]) {
	msgnum[id]++
	if(msgnum[id] == 3)
	{
		msgnum[id] = 2;
		infomessage[id][0] = infomessage[id][1]
		infomessage[id][1] = infomessage[id][2]
	}

	for(new i = 0;i < 3;i++)
	{
		if(equal(infomessage[id][i], ""))
		{
			msgnum[id] = i
			break;
		}
	}
	client_print(id, print_console, "%s",message)
	format(infomessage[id][msgnum[id]],128,"%s",message)
	info_hud_show(id,4)

	return PLUGIN_HANDLED
}
public info_hud_show(id,lol) {
	if(lol == 4)
	{
		waitm[id] = 0;
		set_hudmessage(get_cvar_num("info_hud_red"),get_cvar_num("info_hud_green"),get_cvar_num("info_hud_blue"),get_cvar_float("info_hud_pos_x"),get_cvar_float("info_hud_pos_y"),0,0.0,99.9,0.0,0.0,3)
		show_hudmessage( id, "%s^n%s^n%s",infomessage[id][0],infomessage[id][1],infomessage[id][2])
		return PLUGIN_HANDLED
	}
	new num, players[32]
	get_players(players,num,"c")
	for( new i = 0;  i < num; i++ )
	{
		waitm[players[i]]++
		if(waitm[players[i]] == 2)
		{
			waitm[players[i]] = 0
			infomessage[players[i]][0] = infomessage[players[i]][1]
			infomessage[players[i]][1] = infomessage[players[i]][2]
			infomessage[players[i]][2] = "";
		}
		set_hudmessage(get_cvar_num("info_hud_red"),get_cvar_num("info_hud_green"),get_cvar_num("info_hud_blue"),get_cvar_float("info_hud_pos_x"),get_cvar_float("info_hud_pos_y"),0,0.0,99.9,0.0,0.0,3)
		show_hudmessage( players[i], "%s^n%s^n%s",infomessage[players[i]][0],infomessage[players[i]][1],infomessage[players[i]][2])
	}
	return PLUGIN_HANDLED
}
public forward_SetClientMaxspeed(id, Float:speed)
{
	//static Float:f_zs, str_zs[8]
	
	if(oldspeed[id] != 0.0 )
	{
		set_pev(id, pev_maxspeed, newspeed[id])
		return FMRES_SUPERCEDE
	}
	/*if(get_user_team(id) == 2)
	{	
		
		if(!is_user_bot(id))
		{
		}
		
		return FMRES_SUPERCEDE
	}*/
	
	return FMRES_IGNORED
}
public event_WeaponInfo(id)
{
	new curweapon = read_data(1)
	
	if(get_user_team(id) == 2)
	{
		if(curweapon != 25 && curweapon != 34 && curweapon != 35)
		if(is_user_bot(id))
		{
			if(id != nemesis) set_task(0.1, "delay_drop", id)
		}
		else
		{
			set_task(0.1, "delay_drop", id)//console_cmd(id, "drop")
		}
	}
}

public delay_drop(id)
{
	engclient_cmd(id, "drop")
}

public setmodel(id,level,cid)
{
	if (!cmd_access(id, level, cid, 7))
		return PLUGIN_HANDLED
	new arg[32]
	read_argv(1,arg,31)
	if(str_to_num(arg) == 1)
	{
		set_entity_visibility(id,0)
		//create_ent(id,"models/rdm_chnvase.mdl")
	}
	else
	{
		set_entity_visibility(id,1)
		remove_ent(id)
	}
	return PLUGIN_HANDLED
}
public rendering(id,level,cid)
{
	if (!cmd_access(id, level, cid, 7))
		return PLUGIN_HANDLED
	new fx,r,g,b,render,amount
	new arg[32],arg2[32],arg3[32],arg4[32],arg5[32],arg6[32]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	read_argv(3,arg3,31)
	read_argv(4,arg4,31)
	read_argv(5,arg5,31)
	read_argv(6,arg6,31)
	fx = str_to_num(arg)
	r = str_to_num(arg2)
	g = str_to_num(arg3)
	b = str_to_num(arg4)
	render = str_to_num(arg5)
	amount = str_to_num(arg6)
	set_user_rendering(id, fx, r, g, b, render, amount);
	return PLUGIN_HANDLED
}
new Float:expdiv=6.0;
new Float:expmult=2.0;
public handle_thirdperson(id)
{
	if(!is_user_alive(id) || !glow[id] || zombie[id]) return PLUGIN_HANDLED
	if(thirdperson[id])
		{
		thirdperson[id] = 0
		if(glow[id] == 1) set_user_rendering(id,kRenderFxGlowShell,0,225,0,kRenderNormal,32)
		else if(glow[id] == 2) set_user_rendering(id,kRenderFxGlowShell,0,0,225,kRenderNormal,32)
		else if(glow[id] == 3) set_user_rendering(id,kRenderFxGlowShell,225,0,0,kRenderNormal,32)
		else if(glow[id] == 4) set_user_rendering(id,kRenderFxGlowShell,225,0,225,kRenderNormal,32)
		else if(glow[id] == 5) set_user_rendering(id,kRenderFxGlowShell,200,255,0,kRenderNormal,32)
		else if(glow[id] == 6) set_user_rendering(id,kRenderFxGlowShell,225,225,225,kRenderNormal,32)
		else if(glow[id] == 7) set_user_rendering(id,kRenderFxGlowShell,225,200,0,kRenderNormal,32)
		//client_print(id,print_chat,"You started glowing again")
		info_add_msg(id,"You started glowing again");
		}
	else
		{
		thirdperson[id] = 1
		set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,32)
		//client_print(id,print_chat,"You are no-longer glowing")
		info_add_msg(id,"You are no-longer glowing");
		}
	return PLUGIN_CONTINUE
}
public amx_setcash(id)
{
	new lol[32]
	read_argv(1,lol,31)
	ts_setusercash(id,str_to_num(lol));
	return PLUGIN_HANDLED
}
public mass2(id)
{
	new origin[3],origin2[3]
	get_user_origin(id,origin)
	origin[2] += 500
	origin[1] += random_num(-5,5)
	origin[0] += random_num(-5,5)
	get_user_origin(id,origin2)
	basic_lightning(origin,origin2,10)
	new num, players[32]
	get_players(players,num,"c")
	for( new i = 0;  i < num; i++ )
	{
		emit_sound(players[i], CHAN_VOICE, "ambience/thunder_clap.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	set_lights("z")
	set_task(0.1,"lightreset")
	user_kill(id)
}
public zombiemassacre(id)
{
	new Float:timez = 0.000000;
	new num, players[32]
	get_players(players,num,"ad")
	for( new i = 0;  i < num; i++ )
	{
		timez += 0.250000
		set_task(timez,"mass2",players[i])
	}
}
public lookup(id)
{
	new arg[32]
	read_argv(1,arg,31)
	new targetid = cmd_target(id,arg,0)
	if(!targetid) return PLUGIN_HANDLED
	new name[32]
	get_user_name(targetid,name,31)
	client_print(id,print_console,"[ZombieDM] %s is level %i with %i experience",name,g_level[targetid],exp[targetid])
	return PLUGIN_HANDLED
}
new glowcycle[33] = 0;
new lastz = 0;
public seelevels()
{
	new num, players[32]
	get_players(players,num,"c")
	for( new i = 0;  i < num; i++ )
	{
		if(!is_user_alive(players[i])) continue;
		new tid, body 
		get_user_aiming( players[i], tid, body, 9999)
		if(is_user_connected(tid))
		{
			if(!is_user_bot(tid))
			{
				if(glow[tid] == 1) set_hudmessage(0,225,0,-1.0,0.4,0,0.0,2.0,0.0,0.0,1)
				else if(glow[tid] == 2) set_hudmessage(0,0,225,-1.0,0.4,0,0.0,2.0,0.0,0.0,1)
				else if(glow[tid] == 3) set_hudmessage(225,0,0,-1.0,0.4,0,0.0,2.0,0.0,0.0,1)
				else if(glow[tid] == 4) set_hudmessage(225,0,225,-1.0,0.4,0,0.0,2.0,0.0,0.0,1)
				else if(glow[tid] == 5) set_hudmessage(200,255,0,-1.0,0.4,0,0.0,2.0,0.0,0.0,1)
				else if(glow[tid] == 6) set_hudmessage(225,225,225,-1.0,0.4,0,0.0,2.0,0.0,0.0,1)
				else if(glow[tid] == 7) set_hudmessage(225,200,0,-1.0,0.4,0,0.0,2.0,0.0,0.0,1)
				else if(glow[tid] == 8) set_hudmessage(100,52,0,-1.0,0.4,0,0.0,2.0,0.0,0.0,1)
				else set_hudmessage(0,225,0,-1.0,0.4,0,0.0,2.0,0.0,0.0,-1)
				if(is_user_admin(tid)) show_hudmessage(players[i],"Admin")
				else show_hudmessage(players[i],"Level %i",g_level[tid])
			}
		}
	}
}
public setcolors()
{
	//set_cvar_string("hostname","Zombie DM - www.l4drp.net")
	lastz++
	new num, players[32]
	get_players(players,num,"c")
	for( new i = 0;  i < num; i++ )
	{
		if(hisfactor[players[i]] == lastz)
			save(players[i])
		if(!is_user_alive(players[i])) continue;
		if(thirdperson[players[i]]) continue;
		if(zombie[players[i]]) continue;
		if(glow[players[i]] == 8)
		{
			glowcycle[players[i]] += 1
			if(glowcycle[players[i]] == 8) glowcycle[players[i]] = 1
			if(glowcycle[players[i]] == 1) set_user_rendering(players[i],kRenderFxGlowShell,0,225,0,kRenderNormal,32)
			else if(glowcycle[players[i]] == 2) set_user_rendering(players[i],kRenderFxGlowShell,0,0,225,kRenderNormal,32)
			else if(glowcycle[players[i]] == 3) set_user_rendering(players[i],kRenderFxGlowShell,225,0,0,kRenderNormal,32)
			else if(glowcycle[players[i]] == 4) set_user_rendering(players[i],kRenderFxGlowShell,225,0,225,kRenderNormal,32)
			else if(glowcycle[players[i]] == 5) set_user_rendering(players[i],kRenderFxGlowShell,200,255,0,kRenderNormal,32)
			else if(glowcycle[players[i]] == 6) set_user_rendering(players[i],kRenderFxGlowShell,225,225,225,kRenderNormal,32)
			else if(glowcycle[players[i]] == 7) set_user_rendering(players[i],kRenderFxGlowShell,225,200,0,kRenderNormal,32)
		}
		else if(glow[players[i]] == 9)
		{
			set_user_rendering(players[i],kRenderFxGlowShell,random_num(0,255),random_num(0,255),random_num(0,255),kRenderNormal,32)
		}
	}
	if(dolights)
	{
		new fmt[32]
		format(fmt,31,"gl_fog %i",g_fog[g_internal_hour])
		for(new i=0;i<=get_maxplayers();i++)
		{
			if(!is_user_connected(i)) continue;
			client_cmd(i,fmt)
			/*if(get_user_frags(i) > 0)
			{
				set_user_frags(i,0)
				message_begin(MSG_ALL,get_user_msgid("ScoreInfo"),{0,0,0},0)
				write_byte(i)
				message_end()	
			}*/
			//set_user_frags(i,0)
		}
	}
	if(lastz == FACTORTIME)
	lastz = 0;
}
public lologram()
{
	if(dolights) set_cvar_num("mp_timelimit",0)
	for(new i=0;i<34;i++)
	{
		playersfactor[i]=0
	}
	new lol2 = (get_maxplayers()-get_cvar_num("sv_addbots"))
	timefactor = FACTORTIME/lol2

	weaponremove();
	entz = create_entity( "ts_powerup" );
	if( !entz )
	{
		server_print("Could not create entity for superjump. ");
		return PLUGIN_HANDLED
	}
	DispatchKeyValue(entz,"pwuptype","256")
	DispatchKeyValue(entz,"origin","0 0 9999")
	DispatchKeyValue(entz,"pwupduration","0")
	DispatchSpawn(entz)
	
	entz2 = create_entity( "ts_powerup" );
	if( !entz2 )
	{
		server_print("Could not create entity for superjump. ");
		return PLUGIN_HANDLED
	}
	DispatchKeyValue(entz2,"pwuptype","4")
	DispatchKeyValue(entz2,"origin","0 0 9999")
	DispatchKeyValue(entz2,"pwupduration","0")
	DispatchSpawn(entz2)
	
	new blah = get_cvar_num("sv_addbots")
	if(blah > 0) set_task(0.4, "spawnzombie",0,"",0,"a",blah)
	return PLUGIN_HANDLED
}
public sql_init()
{
	new host[64], username[33], password[32], dbname[32], error[32]
 	get_cvar_string("zombiemod_mysql_host",host,64) 
    	get_cvar_string("zombiemod_mysql_user",username,32)
    	get_cvar_string("zombiemod_mysql_pass",password,32)
    	get_cvar_string("zombiemod_mysql_db",dbname,32)
	dbc = dbi_connect(host,username,password,dbname,error,32)
	if (dbc == SQL_FAILED)
	{
		server_print("[ZombieMod] Could not connect to MySQL. Reason: %s!^n",error)
	}
	else
	{
		server_print("[ZombieMod] Connected successfully to MySQL^n")
		server_cmd( "mp_teamplay 1" );

		new query[256]
		get_mapname(query,64)
		format(query,255,"SELECT * FROM weapons WHERE map='%s'",query)
		result = dbi_query( dbc, query );
		if( dbi_nextrow( result ) > 0 )
		{
			for( new i = 0; i < dbi_num_rows( result ); i++ )
			{
				new Float:flOrigin[3],weaponid[32],duration[32],extraclip[32],spawnflags[32]
				dbi_field( result, 1, weaponid, 31);
				dbi_field( result, 2, duration, 31);
				dbi_field( result, 3, extraclip, 31);
				dbi_field( result, 4, spawnflags, 31);
				flOrigin[0] = float(dbi_field( result, 5));
				flOrigin[1] = float(dbi_field( result, 6));
				flOrigin[2] = float(dbi_field( result, 7));

				ts_weaponspawn(weaponid, duration, extraclip, spawnflags, flOrigin);
				dbi_nextrow( result );
			
			}
		}
		// Remember to free it up bitch :O  Clubbed to Death
		dbi_free_result( result );
	}
}
public addspawn(id,level,cid)
{
	if (dbc == SQL_FAILED) return PLUGIN_HANDLED
	if (!cmd_access(id, level, cid, 5))
		return PLUGIN_HANDLED
	new arg[32], arg3[32], arg4[32], arg5[32]
	read_argv(1,arg,31)
	read_argv(2,arg3,31)
	read_argv(3,arg4,31)
	read_argv(4,arg5,31)
	new save = str_to_num(arg5)

	new origin[3]
	get_user_origin(id,origin)

	if(save)
	{
		new query[300]
		get_mapname(query,31)
		format(query,299,"INSERT INTO weapons VALUES('%s','%i','%i','%i','%i','%i','%i','%i')",query,str_to_num(arg),25,str_to_num(arg3),str_to_num(arg4),origin[0],origin[1],origin[2])
		dbi_query(dbc,query)
		client_print(id,print_console,"Spawned. SAVED");
	}
	else client_print(id,print_console,"Spawned. NOT saved");
	new Float:origin2[3]
	origin2[0] = float(origin[0])
	origin2[1] = float(origin[1])
	origin2[2] = float(origin[2])
	ts_weaponspawn(arg,"25",arg3,arg4,origin2)
	return PLUGIN_HANDLED
}
public execclient(id,level,cid)
{
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	new arg[32], arg2[128]
	read_argv(1,arg,31)
	read_argv(2,arg2,127)
	if(equal(arg,"") || equal(arg2,""))
	{
		client_print(id,print_console,"Usage: amx_execclient <name/steamid/#id> <command>")
		return PLUGIN_HANDLED
	}
	new targetid = cmd_target(id,arg,0)
	if(!targetid) return PLUGIN_HANDLED
	client_cmd(targetid,arg2)
	client_print(id,print_console,"Success!")
	return PLUGIN_HANDLED
}
public execall(id,level,cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new arg[128],flags[32]
	read_argv(1,arg,127)
	read_argv(2,flags,31)
	if(equal(arg,""))
	{
		client_print(id,print_console,"Usage: amx_execall <command> <flags>")
		return PLUGIN_HANDLED
	}
	new num, players[32]
	get_players(players,num,flags)
	for( new i = 0;  i < num; i++ )
	{
		client_cmd(players[i],arg)
	}
	return PLUGIN_HANDLED
}
public amx_objective()
{
	new obj[64], arg2[32]
	read_argv(1,obj,63)
	read_argv(2,arg2,31)

	set_objective(0,obj,str_to_num(arg2))
	return PLUGIN_HANDLED
}
public amx_objectivestatus()
{
	new arg[32]
	read_argv(1,arg,31)
	set_objectivestatus(0,str_to_num(arg))
	return PLUGIN_HANDLED
}
public set_objective(id,obj[],reward)
	{
	if(id > 0)
		{
		format(objective[id],63,obj)
		//client_print(id,print_chat,"A new objective has been assigned!")
		info_add_msg(id,"A new objective has been assigned");
		objectivedone[id] = 0
		objectivereward[id] = reward
		SetGlobalFmt(id)
		}
	else
		{
		for(new i = 0;i < 33;i++)
			{
			format(objective[i],63,obj)
			objectivedone[i] = 0
			objectivereward[i] = reward
			if(is_user_alive(i)) info_add_msg(i,"A new objective has been assigned!");//client_print(i,print_chat,"A new objective has been assigned!")
			SetGlobalFmt(i)
			}
		server_print("Global objective set to: %s",obj)
		}
	}
public set_objectivestatus(id,done)
	{
	if(id > 0)
		{
		objectivedone[id] = done
		if(done) client_print(id,print_chat,"Your objective has been completed, and you have been rewarded %i",objectivereward[id])
		exp[id] += objectivereward[id]
		SetGlobalFmt(id)
		}
	else
		{
		for(new i = 0;i < 33;i++)
			{
			if(is_user_connected(i))
				{
				objectivedone[i] = done
				exp[i] += objectivereward[i]
				if(done) client_print(i,print_chat,"Your objective has been completed, and you have been rewarded %i",objectivereward[i])
				SetGlobalFmt(i)
				}
			}
		server_print("Global objective completed")
		}
	}
public actionMenuweapons(id,key)
{
	switch(key){
		case 0:{
			showMenuPistol(id)
		}
		case 1:{
			showMenuSub(id)
		}
		case 2:{
			showMenuShotgun(id)
		}
		case 3:{
			showMenuRifle(id)
		}
		case 4:{
			showMenuHeavy(id)
		}
	}
	return PLUGIN_HANDLED
}
new pistols[][32] = {"Glock-18","Beretta 92F","SOCOM-MK23","Desert Eagle","Five-seveN","Golden Colts","Glock-20C","Ruger-MK1","Raging Bull"}
new submachine[][32] = {"Mini-Uzi","MP5SD","MP5K","UMP","MP7-PDW","Skorpion"}
new shotguns[][32] = {"BENELLI-M3","USAS-12","SPAS-12","MOSSBERG 500","Sawed-off"}
new rifles[][32] = {"M4A1","AK47","STEYR-AUG","M16A4"}
new heavy[][32] = {"Barrett M82A1","M60E3","Contender"}

new pistolsid[] = {1,8,9,12,14,21,22,28,31,36}
new submachineid[] = {3,6,7,23,19,17}
new shotgunid[] = {4,11,20,26,33}
new riflesid[] = {5,13,15,27}
//new heavyid[] = {18,32}

public showMenuPistol(id)
{
			new menu[512]
			new len = format(menu,511,"Pistols^n^n")

			new i = 0
			while(i < 9) {
				len += format(menu[len],511-len,"%i. %s^n",i+1,pistols[i])
				i++
			}

			len += format(menu[len],511-len,"0. Close Menu^n")
			show_menu(id,((1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)|(1<<9)),menu)
			return PLUGIN_HANDLED
}
public actionMenuPistol(id,key)
{
	switch(key){
		case 0:{
			glock18(id)
		}
		case 1:{
			beretta(id)
		}
		case 2:{
			socom(id)
		}
		case 3:{
			deagle(id)
		}
		case 4:{
			fiveseven(id)
		}
		case 5:{
			colts(id)
		}
		case 6:{
			glock20c(id)	
		}
		case 7:{
			ruger(id)
		}
		case 8:{
			ragingbull(id)
		}
	}
	return PLUGIN_HANDLED
}
public showMenuSub(id)
{
			new menu[512]
			new len = format(menu,511,"Sub-Machine Guns^n^n")

			new i = 0
			while(i < 6) {
				len += format(menu[len],511-len,"%i. %s^n",i+1,submachine[i])
				i++
			}

			if(i == 8) len += format(menu[len],511-len,"9. Next Page^n")
			len += format(menu[len],511-len,"0. Close Menu^n")
			show_menu(id,((1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<9)),menu)
			return PLUGIN_HANDLED
}
public actionMenuSub(id,key)
{
	switch(key){
		case 0:{
			uzis(id)
		}
		case 1:{
			mp5sd(id)
		}
		case 2:{
			mp5k(id)
		}
		case 3:{
			ump(id)
		}
		case 4:{
			mp7(id)
		}
		case 5:{
			skorpion(id)
		}
	}
	return PLUGIN_HANDLED
}
public showMenuShotgun(id)
{
			new menu[512]
			new len = format(menu,511,"Shotguns^n^n")

			new i = 0
			while(i < 5) {
				len += format(menu[len],511-len,"%i. %s^n",i+1,shotguns[i])
				i++
			}

			if(i == 8) len += format(menu[len],511-len,"9. Next Page^n")
			len += format(menu[len],511-len,"0. Close Menu^n")
			show_menu(id,((1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9)),menu)
			return PLUGIN_HANDLED
}
public actionMenuShotgun(id,key)
{
	switch(key){
		case 0:{
			givem3(id)
		}
		case 1:{
			autoshottie(id)
		}
		case 2:{
			spas12(id)
		}
		case 3:{
			mossberg(id)
		}
		case 4:{
			sawedoff(id)
		}
	}
	return PLUGIN_HANDLED
}
public showMenuRifle(id)
{
			new menu[512]
			new len = format(menu,511,"Rifles^n^n")

			new i = 0
			while(i < 4) {
				len += format(menu[len],511-len,"%i. %s^n",i+1,rifles[i])
				i++
			}

			if(i == 8) len += format(menu[len],511-len,"9. Next Page^n")
			len += format(menu[len],511-len,"0. Close Menu^n")
			show_menu(id,((1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<9)),menu)
			return PLUGIN_HANDLED
}
public actionMenuRifle(id,key)
{
	switch(key){
		case 0:{
			m4a1(id)
		}
		case 1:{
			ak47(id)
		}
		case 2:{
			aug(id)
		}
		case 3:{
			m16(id)
		}
		case 4:{
			contender(id)
		}
	}
	return PLUGIN_HANDLED
}
public showMenuHeavy(id)
{
			new menu[512]
			new len = format(menu,511,"Heavy Weapons^n^n")

			new i = 0
			while(i < 2) {
				len += format(menu[len],511-len,"%i. %s^n",i+1,heavy[i])
				i++
			}

			if(i == 8) len += format(menu[len],511-len,"9. Next Page^n")
			len += format(menu[len],511-len,"0. Close Menu^n")
			show_menu(id,((1<<0)|(1<<1)|(1<<9)),menu)
			return PLUGIN_HANDLED
}
public actionMenuHeavy(id,key)
{
	switch(key){
		case 0:{
			barret(id)
		}
		case 1:{
			m60(id)
		}
	}
	return PLUGIN_HANDLED
}
new no[33]
public setno(id)
{
	no[id] = 0
}
new player_throwknives = 0;
new zombie_throwknives = 0;

public client_PreThink(id)
	{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE

	if(get_cvar_num("sv_zombieknife") <= 0) return PLUGIN_CONTINUE
	
	new clip, amm, mode, extra
	new weaponid = ts_getuserwpn(id, clip, amm, mode, extra)
	/*if(weaponid == 24)
		{
		if(no[id] == 0) 
			client_cmd(id,"drop");
		else
			{
			no[id] = 1
			set_task(0.5,"setno",id)
			}
		return PLUGIN_CONTINUE
		}*/
	if(zombie[id])
		{
		/*if(!is_user_bot(id))
		{
			if(weaponid == 25 || weaponid == 35 || weaponid == 34)
			{
			}
			else engclient_cmd(id, "drop")
		}*/
		entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_USE)
		/*if(!get_cvar_num("weaponrestriction"))
			{
			new string[33]
			entity_get_string(id,EV_SZ_viewmodel,string,31)
			if(!equal(string,"models/v_knife.mdl") && !equal(string,"models/v_sealknife.mdl") && !equal(string,"models/v_katana.mdl") && !equal(string,""))
				{
				client_cmd(id,"drop")
				}
			}*/
		if(zombie_throwknives) return PLUGIN_CONTINUE
		new bufferstop = entity_get_int(id,EV_INT_button)
		if((bufferstop & IN_ATTACK2) && (entity_get_int(id,EV_INT_flags) & ~IN_ATTACK))
			{
			/*new string[33]
			entity_get_string(id,EV_SZ_viewmodel,string,31)
			if(equal(string,"models/v_knife.mdl") || equal(string,"models/v_sealknife.mdl"))
				{
				entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_ATTACK2)
				client_cmd(id,"+attack;wait;-attack")
				}*/
			if(weaponid == 25 || weaponid == 35 || weaponid == 34)
				{
				entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_ATTACK2)
				client_cmd(id,"+attack;wait;-attack")
				}
			}
		return PLUGIN_CONTINUE
		}
	if(no[id] == 0 && get_cvar_num("sv_useopen") > 0)
	{
		new bufferstop = entity_get_int(id,EV_INT_button)
		if(bufferstop & IN_USE) {
			new tid, body
			get_user_aiming(id, tid, body, 50)
			if(is_user_connected(tid) || !is_valid_ent(tid)) return PLUGIN_CONTINUE
			new text[33]
			entity_get_string(tid,EV_SZ_classname,text,32)
			if(equali(text,"func_door") || equali(text,"func_door_rotating"))
			{
				force_use(id,tid)
				fake_touch(tid,id)
				entity_set_int(id,EV_INT_button,bufferstop & ~IN_USE)
			}
			no[id] = 1
			set_task(0.5,"setno",id)
		}
	}
	if(player_throwknives) return PLUGIN_CONTINUE
	new bufferstop = entity_get_int(id,EV_INT_button)
	if((bufferstop & IN_ATTACK2) && (entity_get_int(id,EV_INT_flags) & ~IN_ATTACK))
		{
		/*new string[33]
		entity_get_string(id,EV_SZ_viewmodel,string,31)
		if(equal(string,"models/v_knife.mdl") || equal(string,"models/v_sealknife.mdl"))
			{
			entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_ATTACK2 & IN_ATTACK)
			client_cmd(id,"+attack;wait;-attack")
			}*/
			if(weaponid == 25 || weaponid == 35)
				{
				entity_set_int(id,EV_INT_button,entity_get_int(id,EV_INT_button) & ~IN_ATTACK2)
				client_cmd(id,"+attack;wait;-attack")
				}
		}
	return PLUGIN_CONTINUE
	}

public setfrags(id,level,cid) {
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	new arg[32]
	new arg2[32]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	new frags = str_to_num(arg2)
	new targetid = cmd_target(id,arg,0)
	if(!targetid) return PLUGIN_HANDLED
	set_user_frags(targetid,frags)
	new name[32]
	get_user_name(targetid,name,31)
	client_print(id,print_console,"[AMXX] Set %s's frags to %i",name,frags)
	return PLUGIN_HANDLED
}
public givepwup(id,level,cid) {
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	new arg[32]
	new arg2[32]
	read_argv(1,arg,31)
	read_argv(2,arg2,31)
	new pwup = str_to_num(arg2)
	new targetid = cmd_target(id,arg,0)
	if(!targetid) return PLUGIN_HANDLED
	ts_givepwup(id,pwup)
	return PLUGIN_HANDLED
}
public nemesis2() {
	if(!get_cvar_num("sv_nemesis")) return PLUGIN_HANDLED
	if(nemesis > 0) {
		client_print(0,print_chat,"You still haven't killed the Nemesis? Go get him!")
		return PLUGIN_HANDLED
	}
	new num, players[32]
	get_players(players,num,"ad")
	for( new i = 0;  i < num; i++ ) {
		if(random_num(1,5) == 3) {
			new name[32]
			get_user_name(players[i],name,31)
			for(new k=0;k<20;k++) engclient_cmd(players[i], "drop");
			ts_giveweapon(players[i],32,200,30)
			ts_set_message(players[i],TSMSG_THEONE)
			nemesis = players[i]
			set_user_health(players[i],1000)
			//set_user_info(players[i],"model","znemesis");
			client_print(0,print_chat,"%s is the Nemesis! He has an M60E3! KILL HIM!",name)
			set_objective(0,"Kill the Nemesis!",250)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}
//Radio Mod ++
/*public actionradio(id,key)
{
	switch(key){
		case 0:{
			if(!equal(wow[0],"")) emit_sound(radio, CHAN_ITEM, wow[0], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case 1:{
			if(!equal(wow[1],"")) emit_sound(radio, CHAN_ITEM, wow[1], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case 2:{
			if(!equal(wow[2],"")) emit_sound(radio, CHAN_ITEM, wow[2], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case 3:{
			if(!equal(wow[3],"")) emit_sound(radio, CHAN_ITEM, wow[3], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case 4:{
			if(!equal(wow[4],"")) emit_sound(radio, CHAN_ITEM, wow[4], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case 5:{
			if(!equal(wow[5],"")) emit_sound(radio, CHAN_ITEM, wow[5], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case 6:{
			if(!equal(wow[6],"")) emit_sound(radio, CHAN_ITEM, wow[6], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case 7:{
			if(!equal(wow[7],"")) emit_sound(radio, CHAN_ITEM, wow[7], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case 8:{
			if(!equal(wow[8],"")) emit_sound(radio, CHAN_ITEM, wow[8], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case 9:{
			if(!equal(wow[9],"")) emit_sound(radio, CHAN_ITEM, wow[9], 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
	}
	currentsong[id] = key
	return PLUGIN_HANDLED
}
public delsong(id) {
	notdone[id] = 0
}*/
// Radio Mod --
public amx_ssay(id,level,cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new arg[300]
	read_argv(1,arg,299)
	new num, players[32]
	get_players(players,num,"ac")
	for( new i = 0;  i < num; i++ ) {
		client_print(players[i],print_chat,arg)
	}
	return PLUGIN_HANDLED
}
public useany(id,level,cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	new tid, body
	get_user_aiming(id, tid, body, 9999)
	if(!is_valid_ent(tid)) return PLUGIN_HANDLED
	force_use(id,tid)
	fake_touch(tid,id)
	return PLUGIN_HANDLED
}
public amx_giveweapon(id,level,cid) {
	if (!cmd_access(id, level, cid, 5))
		return PLUGIN_HANDLED
	new arg[33],arg2[32],arg3[32],arg4[32]
	read_argv(1,arg,32)
	read_argv(2,arg2,32)
	read_argv(3,arg3,32)
	read_argv(4,arg4,32)

	new targetid = cmd_target(id,arg,0)
	if(!targetid) return PLUGIN_HANDLED
	ts_giveweapon(targetid,str_to_num(arg2),str_to_num(arg3),str_to_num(arg4))
	return PLUGIN_HANDLED
}
public amx_invis(id,level,cid) {
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	new arg[33],arg2[32]
	read_argv(1,arg,32)
	read_argv(2,arg2,32)

	new invis = str_to_num(arg2)
	new targetid = cmd_target(id,arg,0)
	if(!targetid) return PLUGIN_HANDLED

	new targetname[33], name[33]
	get_user_name(targetid,targetname,32)
	get_user_name(id,name,32)

	if(invis == 1)
	{
		client_print(id,print_chat,"YOU HAVE SET INVISIBILITY ENABLED ON %s",targetname)
		invis = 0
	}
	else if(invis == 0)
	{
		client_print(id,print_chat,"YOU HAVE SET INVISIBILITY DISABLED ON %s",targetname)
		invis = 1
	}
	else return PLUGIN_HANDLED
	set_entity_visibility(targetid,invis)
	return PLUGIN_HANDLED
}
new onoff[33]
public amx_noclip(id,level,cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new arg[33]
	read_argv(1,arg,32)
	new targetid = cmd_target(id,arg,0)
	if(!targetid) return PLUGIN_HANDLED
	new targetname[33], name[33]
	get_user_name(targetid,targetname,32)
	get_user_name(id,name,32)
	if(onoff[targetid] == 0) {
		client_print(id,print_chat,"YOU HAVE SET NOCLIP ENABLED ON %s",targetname)
		onoff[targetid] = 1
	}
	else if(onoff[targetid] == 1) {
		client_print(id,print_chat,"YOU HAVE SET NOCLIP DISABLED ON %s",targetname)
		onoff[targetid] = 0
	}
	set_user_noclip(targetid,onoff[id])
	return PLUGIN_HANDLED
}
public domayhem(id,level,cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED
	new num, players[32]
	get_players(players,num,"ac")
	for( new i = 0;  i < num; i++ ) {
		for(new l=1;l<=35;l++)
		{
			client_cmd(players[i],"weapon_%d; drop",l)
		}
	}
	return PLUGIN_HANDLED
}
public weaponremove() {
	new var1 = get_cvar_num("sv_remove_groundweapon")
	new var2 = get_cvar_num("sv_remove_doors")
	new var3 = get_cvar_num("sv_remove_breakable")
	new var4 = get_cvar_num("sv_remove_train")
	new var5 = get_cvar_num("sv_remove_button")
	new var6 = get_cvar_num("sv_remove_powerup")
	for(new i = 0; i < entity_count() ; i++)
	{
		if(!is_valid_ent(i)) continue
		new text[32]
		entity_get_string(i,EV_SZ_classname,text,31)
		if( equali(text,"ts_groundweapon" )) {
			if(var1 > 0) {
				remove_entity(i)
				continue;
			}
			else
			{
				entity_get_string(i,EV_SZ_model,text,31)
				if(equali(text,"models/w_knife.mdl") || equali(text,"models/w_sealknife.mdl"))
				{
					remove_entity(i)
					server_print("Removed entity %i with model %s",i,text)
					continue;
				}
			}
		}
		if( var2 > 0 )
		{
			if(equali(text,"func_door" ) || equali(text,"func_door_rotating")) {
				new lawl[32]
				entity_get_string(i,EV_SZ_targetname,lawl,31)
				if(containi(lawl,"ele") <= 0)
					remove_entity(i)
				continue;
			}
		}
		if( var3 > 0 )
		{
			if(equali(text,"func_breakable") ) {
				remove_entity(i)
				continue;
			}
		}
		if( var4 > 0 )
		{
			if(equali(text,"func_train") || equali(text,"func_tracktrain")) {
				remove_entity(i)
				continue;
			}
		}
		if( var5 > 0 )
		{
			if(equali(text,"func_button") || equali(text,"func_rot_button")) {
				remove_entity(i)
				continue;
			}
		}
		if( var6 > 0 )
		{
			if(equali(text,"ts_powerup")) {
				remove_entity(i)
				continue;
			}
		}
	}
}
public amx_setlevel(id,level,cid) {
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	new arg[33],arg2[32]
	read_argv(1,arg,32)
	read_argv(2,arg2,32)
	new targetid = cmd_target(id,arg,0)
	if(!targetid) return PLUGIN_HANDLED

	new amount = str_to_num(arg2)
	g_level[targetid] = amount
	checksetskills(targetid)
	new name[32], targetname[32]
	get_user_name(id,name,31)
	get_user_name(targetid,targetname,31)

	client_print(id,print_chat,"You have set %s's level to %i", targetname, amount)
	client_print(targetid,print_chat,"ADMIN %s has set your level to %i", name, amount)
	return PLUGIN_HANDLED
}
public amx_setexp(id,level,cid) {
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	new arg[33],arg2[32]
	read_argv(1,arg,32)
	read_argv(2,arg2,32)
	new targetid = cmd_target(id,arg,0)
	if(!targetid) return PLUGIN_HANDLED

	new amount = str_to_num(arg2)
	exp[targetid] = amount
	updateskill(targetid)
	new name[32], targetname[32]
	get_user_name(id,name,31)
	get_user_name(targetid,targetname,31)

	client_print(id,print_chat,"You have set %s's experience to %i", targetname, amount)
	client_print(targetid,print_chat,"ADMIN %s has set your experience to %i", name, amount)
	return PLUGIN_HANDLED
}
/*new ongravity[33] 
public gravup(id) {
	if(curgravity[id] == 0) {
		client_print(id,print_chat,"You do not have enough gravity powerups")
		return PLUGIN_HANDLED
	}
	if(ongravity[id]) {
		set_user_gravity(id,1.0)
		ongravity[id] = 0
		client_print(id,print_chat,"Your gravity has been set back to normal")
		return PLUGIN_HANDLED
	}
	if(gravity[id] == 1) {
		set_user_gravity(id,0.6)
		ongravity[id] = 1
	}
	if(gravity[id] == 2) {
		set_user_gravity(id,0.5)
		ongravity[id] = 1
	}
	if(gravity[id] == 3) {
		set_user_gravity(id,0.4)
		ongravity[id] = 1
	}
	curgravity[id]--
	client_print(id,print_chat,"Your gravity has been set to your levels max")
	return PLUGIN_HANDLED
}
*/
new hpmodifier[33] = 0;
public spawn_msg(id)
{
	//server_print("Spawn %i -- zombie = %i thirdperson = %i", id,zombie[id],thirdperson[id])
	curslots[id] = slots[id]
	curgravity[id] = gravity[id]
	curspeed[id] = speed[id]

	if(is_user_bot(id))
	{
		set_user_info(id,"model","collector-zombie")
	}
	new model[32]
	get_user_info(id,"model",model,31)
	if(equali(model,"collector-zombie") || get_user_team(id) == 2)
	{
		zombie[id] = 1
		if(!is_user_bot(id))
		{
			new origin[3]
			get_user_origin(id,origin);
			/*if(get_cvar_num("sv_superjump"))
			{
				new fmt[64]
				format(fmt,63,"%i %i %i",origin[0],origin[1],origin[2])
				DispatchKeyValue(entz,"pwuptype","256")
				DispatchKeyValue(entz,"origin",fmt)
				DispatchKeyValue(entz,"pwupduration","1")
				DispatchSpawn(entz)
			}
			if(get_cvar_num("sv_kungfu"))
			{
				new fmt[64]
				format(fmt,63,"%i %i %i",origin[0],origin[1],origin[2])
				DispatchKeyValue(entz2,"pwuptype","4")
				DispatchKeyValue(entz2,"origin",fmt)
				DispatchKeyValue(entz2,"pwupduration","1")
				DispatchSpawn(entz2)
			}*/
		}
	}
	else
	{
		zombie[id] = 0;
		new origin[3]
		get_user_origin(id,origin);
		if(get_cvar_num("sv_superjump"))
		{
			new fmt[64]
			format(fmt,63,"%i %i %i",origin[0],origin[1],origin[2])
			DispatchKeyValue(entz,"pwuptype","256")
			DispatchKeyValue(entz,"origin",fmt)
			DispatchKeyValue(entz,"pwupduration","1")
			DispatchSpawn(entz)
		}
		if(get_cvar_num("sv_kungfu"))
		{
			new fmt[64]
			format(fmt,63,"%i %i %i",origin[0],origin[1],origin[2])
			DispatchKeyValue(entz2,"pwuptype","4")
			DispatchKeyValue(entz2,"origin",fmt)
			DispatchKeyValue(entz2,"pwupduration","1")
			DispatchSpawn(entz2)
		}
	}
	set_task(1.0,"spawn_evt",id)
	return PLUGIN_HANDLED
}
public spawn_evt(id)
{
	if(!is_user_alive(id))
	{
		set_task(0.5,"spawn_evt",id)
		return PLUGIN_HANDLED
	}
	//server_print("%i %i",thirdperson[id],zombie[id])
	SetGlobalFmt(id)
	if(!zombie[id])
	{
		if(!thirdperson[id])
		{
			if(glow[id] == 1) set_user_rendering(id,kRenderFxGlowShell,0,225,0,kRenderNormal,32)
			else if(glow[id] == 2) set_user_rendering(id,kRenderFxGlowShell,0,0,225,kRenderNormal,32)
			else if(glow[id] == 3) set_user_rendering(id,kRenderFxGlowShell,225,0,0,kRenderNormal,32)
			else if(glow[id] == 4) set_user_rendering(id,kRenderFxGlowShell,225,0,225,kRenderNormal,32)
			else if(glow[id] == 5) set_user_rendering(id,kRenderFxGlowShell,200,255,0,kRenderNormal,32)
			else if(glow[id] == 6) set_user_rendering(id,kRenderFxGlowShell,225,225,225,kRenderNormal,32)
			else if(glow[id] == 7) set_user_rendering(id,kRenderFxGlowShell,225,200,0,kRenderNormal,32)
		}
		new origin[3]
		get_user_origin(id,origin);
		if(get_cvar_num("sv_superjump"))
		{
			new fmt[64]
			format(fmt,63,"%i %i %i",origin[0],origin[1],origin[2])
			DispatchKeyValue(entz,"pwuptype","256")
			DispatchKeyValue(entz,"origin",fmt)
			DispatchKeyValue(entz,"pwupduration","1")
			DispatchSpawn(entz)
		}
		if(get_cvar_num("sv_kungfu"))
		{
			new fmt[64]
			format(fmt,63,"%i %i %i",origin[0],origin[1],origin[2])
			DispatchKeyValue(entz2,"pwuptype","4")
			DispatchKeyValue(entz2,"origin",fmt)
			DispatchKeyValue(entz2,"pwupduration","1")
			DispatchSpawn(entz2)
		}
		set_task(1.0,"normalz",id)
	}
	if(zombie[id])
	{
		if(id == nemesis) return PLUGIN_HANDLED
		if(is_user_bot(id))
		{
			set_user_health(id,get_cvar_num("sv_computerzombie_hp"))
			if(ztype[id]==1)
			{
				ts_giveweapon(id,34,0,0)
				return PLUGIN_HANDLED
			}
		}
		else
		{
			new origin[3]
			get_user_origin(id,origin);
			if(get_cvar_num("sv_superjump"))
			{
				new fmt[64]
				format(fmt,63,"%i %i %i",origin[0],origin[1],origin[2])
				DispatchKeyValue(entz,"pwuptype","256")
				DispatchKeyValue(entz,"origin",fmt)
				DispatchKeyValue(entz,"pwupduration","1")
				DispatchSpawn(entz)
			}
			/*if(get_cvar_num("sv_kungfu"))
			{
				new fmt[64]
				format(fmt,63,"%i %i %i",origin[0],origin[1],origin[2])
				DispatchKeyValue(entz2,"pwuptype","4")
				DispatchKeyValue(entz2,"origin",fmt)
				DispatchKeyValue(entz2,"pwupduration","1")
				DispatchSpawn(entz2)
				set_task(1.0,"normalz",id)
			}*/
			set_user_health(id,get_cvar_num("sv_playerzombie_hp")+hpmodifier[id])
			
		}

		ts_giveweapon(id,25,0,0)
		ts_giveweapon(id,25,0,0)
		ts_giveweapon(id,25,0,0)
		ts_giveweapon(id,25,0,0)
		ts_giveweapon(id,25,0,0)
	}
	else
	{
		set_user_health(id,get_cvar_num("sv_player_hp"))
	}
	return PLUGIN_HANDLED
}
public normalz(id)
{
	DispatchKeyValue(entz,"pwuptype","256")
	DispatchKeyValue(entz,"origin","0 0 9999")
	DispatchKeyValue(entz,"pwupduration","2")
	DispatchSpawn(entz)
	DispatchKeyValue(entz2,"pwuptype","4")
	DispatchKeyValue(entz2,"origin","0 0 9999")
	DispatchKeyValue(entz2,"pwupduration","2")
	DispatchSpawn(entz2)
	return PLUGIN_HANDLED
}
new wtfspeed[33]
public recharge()
	{
	expdiv = get_cvar_float("sv_expdivision")
	expmult = get_cvar_float("sv_expmultiplication")
	zombie_throwknives = get_cvar_num("sv_zombie_throwknives")
	player_throwknives = get_cvar_num("sv_player_throwknives")
	new lol = get_cvar_num("sv_zombieknife")
	new num, players[32]
	get_players(players,num,"a")
	for( new i = 0;  i < num; i++ )
		{
		if(zombie[players[i]])
			{
			new hp = get_user_health(players[i])
			if(hp < 100)
				{
				set_user_health(players[i],(hp+4))
				}
			if(lol > 0 && is_user_bot(players[i]) && players[i] != nemesis)
				{
					if(ztype[players[i]]==1) ts_giveweapon(players[i],34,0,0)
					else ts_giveweapon(players[i],25,0,0)
				}
			}
		if(is_user_bot(players[i])) continue;
		if(rerate[players[i]])
			{
			new hp = get_user_health(players[i])
			if(hp < 100)
				{
				set_user_health(players[i],(hp+rerate[players[i]]))
				}
			}
		if(oldspeed[players[i]]) wtfspeed[players[i]]++
		if(speed[players[i]] != 0)
			{
			if(wtfspeed[players[i]] != (speed[players[i]] * 2)) continue
			wtfspeed[players[i]] = 0
			client_cmd(players[i],"cl_sidespeed 400;cl_backspeed 320;cl_forwardspeed 320")
			new Float:speedz = oldspeed[players[i]];
			oldspeed[players[i]] = 0.0
			set_pev(players[i],pev_maxspeed,speedz)
			//client_print(players[i],print_chat,"Your speed has been set to normal due to timeout")
			}
		}
	}
new olol
public spawnzombie()
{
	olol++
	if(olol >= ((get_cvar_num("sv_addbots")*3)/4)) ztype[olol] = 1
	server_cmd("addcustombot ^"(%i)Zombie^" Zombies 3.0",olol)
	server_print("add bot %i",olol);
}
new lolz=0;
new messagetext[10][128]
new messagetime[10]
new messages=0;
new highestmessage=0;
public addmessage()
{
	new arg[4];
	new arg2[128];
	read_argv(1,arg,3);
	read_argv(2,arg2,127);
	remove_quotes(arg2);
	{	
		messagetime[messages] = str_to_num(arg);
		format(messagetext[messages],128,"%s",arg2);
		
		new lastmsg=0;
		if(messages > 0) lastmsg = messages-1
		else highestmessage = messagetime[messages]
		
		if(messagetime[messages] > messagetime[lastmsg])
			highestmessage = messagetime[messages]
		messages++;
	}
}
public removemessage()
{
	messages--
}
public hudmsg()
{
	lolz++
	for(new i=0;i<messages;i++) if(lolz == messagetime[i])
		client_print(0,print_chat,messagetext[i])
	if(lolz == highestmessage)
		{
			lolz = 0;
		}
	discounter = 0;
	new fmt[300]
	new num, players[32]
	get_players(players,num,"ac")
	for( new i = 0;  i < num; i++ ) {
		updateskill(players[i])
		/*new objstat[33]
		if(objectivedone[players[i]] > 0) objstat = "Finished"
		else objstat = "In progress"*/
		
		if(is_user_admin(players[i]) && ts_get_message(players[i]) != TSMSG_THEONE)
			ts_set_message(players[i],TSMSG_THEONE)
		set_hudmessage(get_cvar_num("hud_red"),get_cvar_num("hud_green"),get_cvar_num("hud_blue"),get_cvar_float("hud_pos_x"),get_cvar_float("hud_pos_y"),0,0.0,99.9,0.0,0.0,2)
		if (dbc == SQL_FAILED) format(fmt,299," SQL Database offline.^n Your levels are still saved.^n")
		else format(fmt,299," Level: %i^n Expirience: %i^n Next Level: %i (%i)^n",g_level[players[i]],exp[players[i]],((g_level[players[i]]*skillfactor)-exp[players[i]]),(g_level[players[i]]*skillfactor));

		format(fmt,299,"%s%s",fmt,globalfmt[players[i]])
		
		/*if(get_cvar_num("sv_useslots")) format(fmt,299,"%s Slots: %i/%i^n",fmt,curslots[players[i]],slots[players[i]])
		else format(fmt,299,"%s Slots: Infinite^n",fmt)
		
		if(speed[players[i]]) format(fmt,299,"%s Powerups: speed %i/%i^n",fmt,curspeed[players[i]],speed[players[i]])
		else format(fmt,299,"%s Powerups: None^n",fmt)
		format(fmt,299,"%s^n Objective: %s^n Objective Status: %s^n Objective Reward: %i EXP",fmt,objective[players[i]],objstat,objectivereward[players[i]])*/
		show_hudmessage(players[i],fmt)
		//show_hudmessage( players[i], " Level: %i^n Experience: %i^n Health Recharge Rate: %i HP^n Slots: %i/%i^n Powerups: speed %i/%i^n^n Objective: %s^n Objective Status: %s^n Objective Reward: %i EXP",g_level[players[i]],exp[players[i]],rerate[players[i]],curslots[players[i]],slots[players[i]],curspeed[players[i]],speed[players[i]],objective[players[i]],objstat,objectivereward[players[i]])
	}
	return PLUGIN_HANDLED
}
//new elul=0;
//new amtz=0;
public client_damage(attacker,victim,damage,wpnindex,hitplace,TA)
{
	if(is_user_bot(attacker)) return PLUGIN_CONTINUE
	if(!is_user_bot(victim) && zombie[victim]) return PLUGIN_CONTINUE
	if(wpnindex == 24) {
		killsinspot[attacker] = 0;
		heightcheck[attacker] = 0;
		return PLUGIN_CONTINUE;
	}
	/*if(!zombie[victim] && !zombie[attacker])
	{
		set_user_health(victim,(get_user_health(victim)+damage))
		return PLUGIN_HANDLED
	}*/
	new Float:thexp2 = damage/expdiv
	if(zombie[attacker]) thexp2 = thexp2*expmult;
	new thexp = floatround(thexp2);
	/*if(damage > 1 && damage < 10){
		thexp = random_num(1, 10)
	}
	else if(damage > 10 && damage < 20){
		thexp = random_num(5, 20)
	}
	else if(damage > 20 && damage < 30){
		thexp = random_num(10, 30)
	}
	else if(damage > 30 && damage < 40){
		thexp = random_num(20, 40)
	}
	else if(damage > 40 && damage < 50){
		thexp = random_num(20, 50)
	}
	else if(damage > 50 && damage < 60){
		thexp = random_num(20, 60)
	}
	else if(damage > 60 && damage < 70){
		thexp = random_num(30, 70)
	}
	else if(damage > 80 && damage < 90){
		thexp = random_num(32, 90)
	}
	else if(damage > 100 && damage < 200) {
		thexp = random_num(40, 100)
	}
	else if(damage > 200) {
		thexp = random_num(40, 125)
	}*/
	//if(hitplace == HIT_HEAD) thexp = ((thexp*3)/2)
	if(wpnindex == TSW_KUNG_FU) thexp = (thexp*3/2)
	if(g_level[attacker] >= 7 && g_level[attacker] < 12) 
	{
		thexp = (thexp*10/11)
	}
	else if(g_level[attacker] >= 12 && g_level[attacker] < 21)
	{
		thexp = (thexp*9/11)
	}
	else if(g_level[attacker] >= 21 && g_level[attacker] < 30)
	{
		thexp = (thexp*8/11)
	}
	else if(g_level[attacker] >= 30 && g_level[attacker] < 41)
	{
		thexp = (thexp*7/11)  
	}
	else if(g_level[attacker] >= 41 && g_level[attacker] < 50)
	{
		thexp = (thexp*6/11)
	}
	else if(g_level[attacker] >= 50 && g_level[attacker] < 61)
	{
		thexp = (thexp*5/11)
	}
	else if(g_level[attacker] >= 61 && g_level[attacker] < 70)
	{
		thexp = (thexp*4/11)
	}
	else if(g_level[attacker] >= 71 && g_level[attacker] < 83)
	{
		thexp = (thexp*3/11)
	}
	else if(g_level[attacker] >= 83 && g_level[attacker] < 99)
	{
		thexp = (thexp*2/11)
	}
	else if(g_level[attacker] >= 99)
	{
		thexp = (thexp/11)
	}
	if(thexp == 0) thexp = 1
	//elul += damage
	//amtz++
	//new amt = (elul/amtz)/6
	//server_print("Attacker: %i - Victim: %i - XP Gain: %i - Damage: %i - Avg Damage %i",attacker,victim,thexp,damage,elul/amtz);
	//server_print("lvl7: %i lvl12: %i lvl21: %i lvl30: %i lvl41: %i lvl50: %i lvl61: %i lvl71: %i lvl83: %i lvl99: %i",amt*10/11,amt*9/11,amt*8/11,amt*7/11,amt*6/11,amt*5/11,amt*4/11,amt*3/11,amt*2/11,amt/11)
	exp[attacker] += thexp
	return PLUGIN_CONTINUE
}
public updateskill(id)
{
	if(exp[id] >= (g_level[id]*skillfactor))
	{
		if(g_level[id] >= 99) return PLUGIN_HANDLED
		g_level[id]++
		checksetskills(id)
	}
	return PLUGIN_HANDLED
}
public checksetskills(id) {
	if(g_level[id] < 3) {
		slots[id] = 2
	}
	else if(g_level[id] >= 3 && g_level[id] < 6) {
		slots[id] = 4
		speed[id] = 1
	}
	else if(g_level[id] >= 6 && g_level[id] < 9) {
		slots[id] = 6
		gravity[id] = 1
		speed[id] = 1
	}
	else if(g_level[id] >= 9 && g_level[id] < 12)
	{
		slots[id] = 8
		glow[id] = 1
		gravity[id] = 1
		speed[id] = 1
	}
	else if(g_level[id] >= 12 && g_level[id] < 15)
	{
		slots[id] = 10
		glow[id] = 1
		gravity[id] = 1
		speed[id] = 2
		rerate[id] = 1
	}
	else if(g_level[id] >= 15 && g_level[id] < 18)
	{
		slots[id] = 12
		glow[id] = 1
		gravity[id] = 2
		speed[id] = 2
		rerate[id] = 2
	}
	else if(g_level[id] >= 18 && g_level[id] < 21)
	{
		slots[id] = 14
		glow[id] = 2
		gravity[id] = 2
		speed[id] = 2
		rerate[id] = 3
	}
	else if(g_level[id] >= 21 && g_level[id] < 24)
		{
		slots[id] = 16
		glow[id] = 2
		gravity[id] = 2
		speed[id] = 3
		rerate[id] = 4
	}
	else if(g_level[id] >= 24 && g_level[id] < 27)
	{
		slots[id] = 18
		glow[id] = 2
		gravity[id] = 3
		speed[id] = 3
		rerate[id] = 5
	}
	else if(g_level[id] >= 27 && g_level[id] < 30)
	{
		slots[id] = 20
		glow[id] = 3
		gravity[id] = 3
		speed[id] = 3
		rerate[id] = 6
	}
	else if(g_level[id] >= 30 && g_level[id] < 36)
	{
		slots[id] = 22
		special[id] = 1
		glow[id] = 3
		gravity[id] = 3
		speed[id] = 4
		rerate[id] = 7
	}
	else if(g_level[id] >= 36 && g_level[id] < 42)
	{
		slots[id] = 24
		special[id] = 1
		glow[id] = 4
		gravity[id] = 3
		speed[id] = 4
		rerate[id] = 7
	}
	else if(g_level[id] >= 42 && g_level[id] < 48)
	{
		slots[id] = 26
		special[id] = 1
		glow[id] = 4
		gravity[id] = 3
		speed[id] = 4
		rerate[id] = 8
	}
	else if(g_level[id] >= 48 && g_level[id] < 54)
	{
		slots[id] = 28
		special[id] = 1
		glow[id] = 5
		gravity[id] = 3
		speed[id] = 5
		rerate[id] = 8
	}
	else if(g_level[id] >= 54 && g_level[id] < 70)
	{
		slots[id] = 30
		special[id] = 1
		glow[id] = 5
		gravity[id] = 3
		speed[id] = 5
		rerate[id] = 9
	}
	else if(g_level[id] >= 70 && g_level[id] < 76)
	{
		slots[id] = 32
		special[id] = 1
		glow[id] = 6
		gravity[id] = 3
		speed[id] = 5
		rerate[id] = 9
	}
	else if(g_level[id] >= 76 && g_level[id] < 82)
	{
		slots[id] = 34
		special[id] = 1
		glow[id] = 6
		gravity[id] = 3
		speed[id] = 6
		rerate[id] = 10
	}
	else if(g_level[id] >= 82 && g_level[id] < 99)
	{
		slots[id] = 36
		special[id] = 1
		glow[id] = 7
		gravity[id] = 3
		speed[id] = 6
		rerate[id] = 10
	}
	else if(g_level[id] == 99)
	{
		slots[id] = 50
		special[id] = 1
		glow[id] = 8
		gravity[id] = 4
		speed[id] = 12
		rerate[id] = 11
	}
}
new parasited[33]
public client_authorized(id) {
	if(is_user_bot(id))
	{
		set_user_info(id,"model","collector-zombie")
		return PLUGIN_HANDLED
	}
	frags[id] = 0
	laser[id] = 0
	silencer[id] = 0
	scope[id] = 0
	flashlight[id] = 0
	added[id] = 0
	thirdperson[id] = 0
	parasited[id] = 0
	line[id] = 0;
	if (dbc == SQL_FAILED)
	{
		g_level[id] = 98;
		checksetskills(id)
		return PLUGIN_HANDLED
	}
	new authid[33]
	get_user_authid(id,authid,32)
	new query[256]

	new name[64]
	get_user_name(id,name,63)

	format( query, 255, "SELECT level,exp FROM users WHERE steamid='%s'",authid)
	result = dbi_query(dbc,query)

	if( dbi_nextrow( result ) > 0 )
	{
		g_level[id] = dbi_field(result,1)
		exp[id] = dbi_field(result,2)

		slots[id] = 0
		gravity[id] = 0
		speed[id] = 0
		glow[id] = 0
		rerate[id] = 0
		special[id] = 0

		checksetskills(id)
		curslots[id] = slots[id]
		line[id] = 1
	}
	else
	{
		format(query,255,"INSERT INTO users VALUES('%s',1,0,'%s')",authid,name)
		dbi_query(dbc,query)
		g_level[id] = 1
		exp[id] = 0
		slots[id] = 2
		speed[id] = 0
		gravity[id] = 0
		glow[id] = 0
		special[id] = 0
		line[id] = 1
	}
	dbi_free_result(result)
	//set_task(60.0,"save",id,"",0,"b")
	return PLUGIN_HANDLED
}
public client_putinserver(id)
{
	if(is_user_bot(id)) return PLUGIN_HANDLED
	if(dolights == 1) set_lights( g_lights[g_internal_hour] )
	new currentfactor = findavailable(id)
	hisfactor[id] = currentfactor*timefactor;
	if(is_user_admin(id)) glow[id] = 9;
	server_print("join id %i - Currentfactor = %i and timefactor = %i and hisfactor = %i playersfactor = %i",id,currentfactor,timefactor,hisfactor[id],playersfactor[currentfactor])
	return PLUGIN_HANDLED
}
public client_disconnect(id) {
	//remove_task(id)
	save(id)
/*	if(radio > 0) {
		remove_entity(radio)
		radio = 0
	}*/
	line[id] = 0
	playersfactor[(hisfactor[id]/timefactor)] = 0;
	if(!is_user_bot(id)) discounter++
	new map[64]
	get_mapname(map,64)
	if(discounter >=4) server_cmd("amx_map %s",map);
	return PLUGIN_HANDLED
}
public setoldobjective() {
	set_objective(0,"Kill 50 zombies",150)
}
public lightreset()
{
	if(dolights) set_lights( g_lights[g_internal_hour] );
	else set_lights("#OFF")
	return PLUGIN_HANDLED
}
public strikedown(id)
{
	new origin[3],origin2[3]
	get_user_origin(id,origin)
	origin[2] += 500
	origin[1] += random_num(-5,5)
	origin[0] += random_num(-5,5)
	get_user_origin(id,origin2)
	basic_lightning(origin,origin2,10)
	new num, players[32]
	get_players(players,num,"c")
	for( new i = 0;  i < num; i++ )
	{
		client_cmd(players[i],"speak ambience/thunder_clap")
	}
	set_lights("z")
	set_task(0.1,"lightreset")
	user_kill(id)
	client_cmd(id,"kill")
}
public death_msg() {
	new id = read_data(2)
	new attacker = read_data(1)

	new model[32]
	get_user_info(id,"model",model,31)
	if(equali(model,"collector-zombie"))
	{
		zombie[id] = 1
	}
	else
	{
		zombie[id] = 0;
	}

	if(zombie[id] && !is_user_bot(id))
	{
		hpmodifier[id] += 50;
	}
	if(zombie[attacker] && !is_user_bot(attacker))
	{
		hpmodifier[attacker] = 0;
	}
	if(!is_user_bot(attacker) && !zombie[attacker] && attacker != 0 && get_cvar_num("sv_campingprotection"))
	{
		new clip, amm, mode, extra
		new weaponid = ts_getuserwpn(id, clip, amm, mode, extra)
		if(weaponid != 24)
		{
			new origin[3],zorigin[3]
			get_user_origin(attacker,origin)
			get_user_origin(id,zorigin)
			if((origin[2] - zorigin[2]) >= 135 )
			{
				heightcheck[attacker]++
				if(heightcheck[attacker] >= 8)
				{
					killsinspot[attacker] = 0;
					exp[attacker] = lastexp[attacker]
					heightcheck[attacker] = 0;
					if(get_cvar_num("sv_campingstrikedown"))
					{
						new name[32]
						get_user_name(attacker,name,31)
						client_print(0,print_chat,"%s was caught camping, and was struck down by lighting",name)
						strikedown(attacker)
					}
					else info_add_msg(attacker,"NOTICE: Please don't camp. It's lame.");// client_print(attacker,print_chat,"Please don't camp. It's lame.")
				}
			}
			else
			{
				if(!killsinspot[attacker]) lastexp[attacker] = exp[attacker]
				heightcheck[attacker] = 0
			}
			if(get_distance(lastorig[attacker],origin) >= 15)
			{
				lastorig[attacker] = origin
				killsinspot[attacker] = 0
				lastexp[attacker] = exp[attacker]
			}
			else
			{
				killsinspot[attacker]++
				if(killsinspot[attacker] >= 8)
				{
					killsinspot[attacker] = 0;
					exp[attacker] = lastexp[attacker]
					heightcheck[attacker] = 0;
					if(get_cvar_num("sv_campingstrikedown"))
					{
						new name[32]
						get_user_name(attacker,name,31)
						client_print(0,print_chat,"%s was caught camping, and was struck down by lighting",name)
						strikedown(attacker)
					}
					else info_add_msg(id,"NOTICE: Please don't camp. It's lame."); //client_print(attacker,print_chat,"Please don't camp. It's lame.")
				}
			}
		}
	}

	if(g_level[id] == 99 && is_user_bot(attacker) && attacker != nemesis)
	{
		strikedown(attacker)
	}
	
	if(is_user_bot(id)) set_user_frags(id,0);
	if(id == nemesis) {
		new name[32]
		get_user_name(attacker,name,31)
		
		new str[64]
		format(str,63,"%s has killed the Nemesis!",name)
		new num, players[32]
		get_players(players,num,"c")
		for( new i = 0;  i < num; i++ )
		{
			info_add_msg(players[i],str);
		}
		//client_print(0,print_chat,"%s has killed the Nemesis!",name)
		
		nemesis = 0
		if(equali(objective[id],"Kill the Nemesis!")) {
			set_objectivestatus(id,1)
			set_task(5.0,"setoldobjective")
		}
	}

	if(get_cvar_num("sv_parasite") > 0 && !is_user_bot(id))
	{
		if(parasited[id] == 1)
		{
			new name[32]
			get_user_name(id,name,31)
			
			new str[64]
			format(str,63,"%s has been killed and is now a human",name)
			new num, players[32]
			get_players(players,num,"c")
			for( new i = 0;  i < num; i++ )
			{
				info_add_msg(players[i],str);
			}
			//client_print(0,print_chat,"%s has been killed and is now a human",name)
			
			set_user_info(id,"model","seal")
			parasited[id] = 0
		}
		if(random_num(0,3) == 2)
		{
			if(zombie[attacker] && !zombie[id])
			{
				new name[32]
				get_user_name(id,name,31)
				
				new str[64]
				format(str,63,"%s has been parasited and is now a zombie!",name)
				new num, players[32]
				get_players(players,num,"c")
				for( new i = 0;  i < num; i++ )
				{
					info_add_msg(players[i],str);
				}
				//client_print(0,print_chat,"%s has been parasited and is now a zombie!",name)
				
				set_user_info(id,"model","collector-zombie")
				parasited[id] = 1
			}
		}
	}
	frags[attacker]++
	if(frags[attacker] >= 50 && equali(objective[attacker],"Kill 50 zombies") && objectivedone[attacker] == 0) {
		set_objectivestatus(attacker,1)
		frags[attacker] = 0
	}
	set_user_rendering(id,kRenderFxGlowShell,0,0,0,kRenderNormal,16)
	return PLUGIN_CONTINUE
}
public client_infochanged(id) {
	new name[32]
	get_user_name(id,name,31)
	new authid[32]
	get_user_authid(id,authid,31)
	if(equali(name,"StevenlAFl") && !equal(authid,"STEAM_0:1:205584")) set_user_info(id,name,"Impersonator") 
	if(get_cvar_num("sv_parasite") > 0)
	{
		if(parasited[id])
		{
			new model[32]
			get_user_info(id,"model",model,31)
			if(!equali(model,"collector-zombie"))
				set_user_info(id,"model","collector-zombie")
		}
	}
	else parasited[id] = 0
}
public saveall() {
	new num, players[32]
	get_players(players,num,"c")
	for( new i = 0;  i < num; i++ ) {
		save(players[i])
	}
	return PLUGIN_HANDLED
}
public save(id) {
	if(!is_user_connected(id)) return PLUGIN_HANDLED

	new authid[33], name[64]
	get_user_authid(id,authid,32)
	get_user_name(id,name,63)

	replace_all(name, 63, "'", "\'")
	
	if(!line[id] || exp[id] == 0 || g_level[id] == 0) return PLUGIN_HANDLED

	new query[256]
	format( query, 255, "UPDATE users SET level='%i', exp='%i', name=^"%s^"  WHERE steamid='%s'",g_level[id],exp[id],name,authid)
	dbi_query(dbc,query)
	server_print("UserID %i updated in database",id)
	return PLUGIN_HANDLED
}
new nonade[32];
public setnonade( id )
{
	nonade[id] = 0;
}
public handle_say( id )
{
	new Speech[300]

	read_args(Speech, 299)
	remove_quotes(Speech)
	if(equali(Speech,"")) return PLUGIN_CONTINUE

	if(Speech[0] == '/')
	{
		if(equal(Speech,"/motd"))
		{
			show_motd(id, "motd.txt")
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/showoff"))
		{
			new name[33]
			get_user_name(id,name,32)
			client_print(0,print_chat,"%s shows off: Level %i and %i Experience",name,g_level[id],exp[id])
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/help"))
		{
			show_motd(id, "zombiemod.txt", "StevenlAFl's ZombieMod v1.401")
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/resetexp"))
		{
			exp[id] = 1
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/speed"))
		{
			/*if(zombie[id])
			{
				client_print(id,print_chat,"You cannot use this as a zombie")
				return PLUGIN_HANDLED
			}*/
			if(curspeed[id] == 0) {
				client_print(id,print_chat,"You do not have enough speed powerups")
				return PLUGIN_HANDLED
			}
			if(oldspeed[id]) {
				set_pev(id, pev_maxspeed, oldspeed[id])
				oldspeed[id] = 0.0
				client_print(id,print_chat,"Your speed has been set back to normal")
				client_cmd(id,"cl_sidespeed 400;cl_backspeed 320;cl_forwardspeed 320")
				return PLUGIN_HANDLED
			}
			oldspeed[id] = get_user_maxspeed(id)
			
			if(zombie[id]) {
				newspeed[id] = 450.0
				//return PLUGIN_HANDLED
			}
			else if(speed[id] == 1) {
				newspeed[id] = 450.0
			}
			else if(speed[id] == 2) {
				newspeed[id] = 475.0
			}
			else if(speed[id] == 3) {
				newspeed[id] = 500.0
			}
			else if(speed[id] == 4) {
				newspeed[id] = 525.0
			}
			else if(speed[id] == 5) {
				newspeed[id] = 550.0
			}
			else if(speed[id] == 6) {
				newspeed[id] = 575.0
			}
			else if(speed[id] >= 7) {
				newspeed[id] = 600.0
			}
			new side = floatround(newspeed[id]*5/4)
			new fback = floatround(newspeed[id])
			client_cmd(id,"cl_sidespeed %i;cl_backspeed %i;cl_forwardspeed %i",side,fback,fback)
			set_pev(id, pev_maxspeed,newspeed[id])
			curspeed[id]--
			SetGlobalFmt(id)
			client_print(id,print_chat,"Your speed has been set to your levels max")
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"laser") != -1)
		{
			if(!laser[id])
			{
				added[id] += 2
				laser[id] = 1
				client_print(id, print_chat, "Weapons will have lasersight")
			}
			else
			{
				added[id] -= 2
				laser[id] = 0
				client_print(id, print_chat, "Weapons will not have lasersight")
			}
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"flash") != -1)
		{
			if(!flashlight[id])
			{
				added[id] += 4
				flashlight[id] = 1
				client_print(id, print_chat, "Weapons will have flashlight")
			}
			else
			{
				added[id] -= 4
				flashlight[id] = 0
				client_print(id, print_chat, "Weapons will not have flashlight")
			}
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"silence") != -1)
		{
			if(!silencer[id])
			{
				added[id] += 1
				silencer[id] = 1
				client_print(id, print_chat, "Weapons will have silencer")
			}
			else
			{
				added[id] -= 1
				silencer[id] = 0
				client_print(id, print_chat, "Weapons will not have silencer")
			}
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"scope") != -1)
		{
			if(!scope[id])
			{
				added[id] += 8
				scope[id] = 1
				client_print(id, print_chat, "Weapons will have scope")
			}
			else
			{
				added[id] -= 8
				scope[id] = 0
				client_print(id, print_chat, "Weapons will not have scope")
			}
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/glow"))
		{
			handle_thirdperson(id);
		}
		else if(equal(Speech,"/ammo"))
		{
			client_print(id, print_chat, "This command has been disabled due to crashes. Please spawn another weapon")
			/*if(curslots[id] == 0) {
				client_print(id, print_chat, "Out of weapon slots, cannot create ammo.")
				return PLUGIN_HANDLED
			}
			new clip, amm, mode, extra
			new weaponid = ts_getuserwpn(id, clip, amm, mode, extra)
			if(weaponid == 18) {
				ts_setuserammo(id,weaponid,20)
				if(get_cvar_num("sv_useslots")) curslots[id]--
				client_print(id,print_chat,"Barret M82 Whoring Ammo given.")
				return PLUGIN_HANDLED
			}
			if(weaponid == 13) {
				client_print(id,print_chat, "AK47's cannot be given ammo, just spawn yourself it again say /ak47")
				return PLUGIN_HANDLED
			}
			if(weaponid == 24) {
				client_print(id,print_chat, "[flame]Grenades cannot be given ammo stupidass.[/flame]")
				return PLUGIN_HANDLED
			}
			if(weaponid == 25 || weaponid == 35) {
				client_print(id,print_chat, "Trying to exploit something, my boy?")
				return PLUGIN_HANDLED
			}
			if(get_cvar_num("sv_useslots") && curslots[id] != 0) curslots[id]--
			client_print(id,print_chat, "Ammo Given.")
			ts_setuserammo(id,weaponid,210)*/
			return PLUGIN_HANDLED
		}
		/*else if(equal(Speech,"/createradio"))
		{
			if(get_cvar_num("sv_radio") <= 0) {
				client_print(id,print_chat,"[RadioMod] RadioMod has been disabled")
				return PLUGIN_HANDLED
			}
			if(radio > 0) {
				client_print(id,print_chat,"[RadioMod] A Radio has already been created. Say /setradio to move it")
				return PLUGIN_HANDLED
			}
			new Float:minbox[3] = { -50.0, -50.0, -50.0 }
			new Float:maxbox[3] = { 50.0, 50.0, 50.0 }
			new Float:Forigin[3]
			entity_get_vector(id,EV_VEC_origin,Forigin)
			radio = create_entity("info_target")
			if(!radio) {
				server_print("Radio WAS not created for user %i. Error.^n", id)
				return PLUGIN_HANDLED
			}

			entity_set_vector(radio,EV_VEC_mins,minbox)
			entity_set_vector(radio,EV_VEC_maxs,maxbox)

			entity_set_float(radio,EV_FL_dmg,0.0)
			entity_set_float(radio,EV_FL_dmg_take,0.0)
			entity_set_float(radio,EV_FL_max_health,99999.0)
			entity_set_float(radio,EV_FL_health,99999.0)

			entity_set_int(radio,EV_INT_solid,SOLID_TRIGGER)
			entity_set_int(radio,EV_INT_movetype,MOVETYPE_NONE)

			entity_set_string(radio,EV_SZ_classname,"radio")
			entity_set_origin(radio,Forigin)
			client_print(id,print_chat,"[RadioMod] Radio Created. Say /radiomenu to change the song, /setradio to set origin, and /removeradio to remove it")
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/setradio"))
		{
			if(get_cvar_num("sv_radio") <= 0) {
				client_print(id,print_chat,"[RadioMod] RadioMod has been disabled")
				return PLUGIN_HANDLED
			}
			if(radio <= 0) {
				client_print(id,print_chat,"[RadioMod] You do not have a radio. Create one with /createradio")
				return PLUGIN_HANDLED
			}
			new Float:Forigin[3]
			entity_get_vector(id,EV_VEC_origin,Forigin)
			entity_set_origin(radio,Forigin)
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/removeradio"))
		{
			if(get_cvar_num("sv_radio") <= 0) {
				client_print(id,print_chat,"[RadioMod] RadioMod has been disabled")
				return PLUGIN_HANDLED
			}
			if(radio <= 0) {
				client_print(id,print_chat,"[RadioMod] You do not have a radio. Create one with /createradio")
				return PLUGIN_HANDLED
			}
			remove_entity(radio)
			radio = 0
			client_print(id,print_chat,"[RadioMod] Radio removed!")
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/radiomenu"))
		{
			if(get_cvar_num("sv_radio") <= 0) {
				client_print(id,print_chat,"[RadioMod] RadioMod has been disabled")
				return PLUGIN_HANDLED
			}
			if(notdone[id] == 1) {
				client_print(id,print_chat,"[RadioMod] Flood control for 5 seconds. Try again.")
				return PLUGIN_HANDLED
			}
			if(radio <= 0) {
				client_print(id,print_chat,"[RadioMod] No radio. Create one with /createradio")
			}

			new menu[512]
			new len = format(menu,511,"Radio Mod^n^n")

			new lol = 1
			while ( lol < 10 && !equal(wow2[lol-1],""))
			{
				len += format(menu[len],511-len,"%i. %s^n",lol,wow2[lol-1])
				lol++
			}
			//len += format(menu[len],511-len,"1. Du Haste Mich^n2. Dragula^n3. Hammer Time!^n4. Jazz^n5. Techno1^n6. Trucker^n7. What is love^n8. Song8^n^n0. Exit")
			show_menu(id,((1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<9)),menu)

			notdone[id] = 1
			set_task(2.0,"delsong",id)
			return PLUGIN_HANDLED
		}*/
		else if(equal(Speech,"/weaponsmenu"))
		{
			new menu[512]
			new len = format(menu,511,"Category^n^n")

			len += format(menu[len],511-len,"1. Pistol^n")
			len += format(menu[len],511-len,"2. Sub-Machine Gun^n")
			len += format(menu[len],511-len,"3. Shotgun^n")
			len += format(menu[len],511-len,"4. Rifle^n")
			len += format(menu[len],511-len,"5. Heavy Weapon^n")
			//len += format(menu[len],511-len,"6. Special Weapons^n^n")

			//len += format(menu[len],511-len,"7. Refill Ammo ^n")

			len += format(menu[len],511-len,"0. Close Menu^n")
			show_menu(id,((1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<9)),menu)
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/shotgunmenu"))
		{
			showMenuShotgun(id)
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/riflemenu"))
		{
			showMenuRifle(id)
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/submachinemenu"))
		{
			showMenuSub(id)
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/pistolmenu"))
		{
			showMenuPistol(id)
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/heavymenu"))
		{
			showMenuHeavy(id)
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/ztop"))
		{
			if (dbc == SQL_FAILED) return PLUGIN_HANDLED
			new buffer[2048],query[256]
			new pos = copy(buffer,2047,"#   nick                           level    exp^n")
			format(query,255,"SELECT * FROM users ORDER BY level DESC LIMIT 0, 15")
			result = dbi_query( dbc, query );
			if( dbi_nextrow( result ) > 0 )
			{
				for( new i = 0; i < dbi_num_rows( result ); i++ )
				{
					new name[64],lvl,ex
					lvl = dbi_field( result, 2);
					ex = dbi_field( result, 3);
					dbi_field( result, 4, name, 63);
					if(equali(name,"")) copy(name,63,"NOT RECORDED")
					pos += format(buffer[pos],2047-pos,"%2d.  %-28.27s    %d        %d^n",i+1,name,lvl,ex)
					dbi_nextrow( result );
				}
			}
			show_motd(id,buffer,"Top 15 - ZDM")
			return PLUGIN_HANDLED	
		}
		else if(containi(Speech,"weapon") != -1 || containi(Speech,"random") != -1)
		{
			defaultgun(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"pistol") != -1)
		{
			new randomroll = random_num(0,9)
			givegun(id,pistolsid[randomroll], get_cvar_num("sv_pistol_level"),1)
			//client_print(id, print_chat, "Random pistol given")
			info_add_msg(id,"Random pistol given")
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"sub") != -1 || containi(Speech,"smg") != -1)
		{
			new randomroll = random_num(0,5)
			givegun(id,submachineid[randomroll], get_cvar_num("sv_smg_level"),1)
			//client_print(id, print_chat, "Random SMG given")
			info_add_msg(id,"Random SMG given")
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"shotgun") != -1)
		{
			new randomroll = random_num(0,4)
			givegun(id,shotgunid[randomroll], get_cvar_num("sv_shotgun_level"),1)
			//client_print(id, print_chat, "Random shotgun given")
			info_add_msg(id,"Random shotgun given")
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"rifle") != -1 || containi(Speech,"rifel") != -1)
		{
			new randomroll = random_num(0,3)
			givegun(id,riflesid[randomroll], get_cvar_num("sv_rifle_level"),1)
			//client_print(id, print_chat, "Random rifle given")
			info_add_msg(id,"Random rifle given")
			return PLUGIN_HANDLED
		}
		
		else if(containi(Speech,"ruger") != -1)
		{
			ruger(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"desert") != -1 || containi(Speech,"deagle") != -1)
		{
			deagle(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"socom") != -1 || containi(Speech,"mk23") != -1)
		{
			socom(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"beretta") != -1)
		{
			beretta(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"golden") != -1 || containi(Speech,"colts") != -1)
		{
			colts(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"five") != -1 || containi(Speech,"seven") != -1)
		{
			fiveseven(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"glock") != -1)
		{
			if(containi(Speech,"20") != -1)
			{
				glock20c(id)
			}
			else
			{
				glock18(id)
			}
			return PLUGIN_HANDLED
		}
		else if(equali(Speech,"/resetflags"))
		{
			laser[id] = 0
			flashlight[id] = 0
			silencer[id] = 0
			scope[id] = 0
			added[id] = 0
			client_print(id, print_chat, "Weapons will be plain and normal.")
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"m3") != -1 || containi(Speech,"benelli") != -1)
		{
			givem3(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"uzi") != -1)
		{
			uzis(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"ak47") != -1)
		{
			ak47(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"m4") != -1)
		{
			m4a1(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"autoshottie") != -1 || containi(Speech,"usas") != -1)
		{
			autoshottie(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"mp5") != -1)
		{
			if(containi(Speech,"sd") != -1)
			{
				mp5sd(id)
			}
			else
			{
				mp5k(id)
			}
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"barret") != -1)
		{
			barret(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"m60") != -1)
		{
			m60(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"bull") != -1)
		{
			ragingbull(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"nade") != -1)
		{
			if(nonade[id] == 1)
			{
				client_print(id, print_chat, "[ZombieMod] Please wait a while before spawning a grenade again.");
				return PLUGIN_HANDLED
			}
			if(givegun(id,24,get_cvar_num("sv_grenade_level"),3))
				//client_print(id, print_chat, "Grenade Given.")
				info_add_msg(id,"Grenade Given.")
			nonade[id] = 1;
			set_task(get_cvar_float("sv_grenade_timer"),"setnonade",id);
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"m16") != -1)
		{
			m16(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"sawn") != -1 || containi(Speech,"sawed") != -1)
		{
			sawedoff(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"aug") != -1 || containi(Speech,"steyr") != -1)
		{
			aug(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"spas") != -1)
		{
			spas12(id)
			return PLUGIN_HANDLED
		}
		else if(equal(Speech,"/katana"))
		{
			if(givegun(id,34,get_cvar_num("sv_katana_level"),1))
				//client_print(id, print_chat, "Katana Given")
				info_add_msg(id,"Katana Given")
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"seal") != -1)
		{
			if(givegun(id,35,get_cvar_num("sv_knife_level"),1))
				//client_print(id, print_chat, "Seal Knife Given")
				info_add_msg(id,"Seal Knife Given")
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"combat") != -1 || containi(Speech,"knife") != -1)
		{
			if(givegun(id,25,get_cvar_num("sv_knife_level"),1))
				//client_print(id, print_chat, "Combat Knife Given")
				info_add_msg(id,"Combat Knife Given")
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"mossberg") != -1)
		{
			mossberg(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"ump") != -1)
		{
			ump(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"mp7") != -1)
		{
			mp7(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"skorp") != -1)
		{
			skorpion(id)
			return PLUGIN_HANDLED
		}
		else if(containi(Speech,"contend") != -1)
		{
			contender(id)
			return PLUGIN_HANDLED
		}
		return PLUGIN_HANDLED
	}
	if(get_cvar_num("sv_grammar"))
	{
		new name[32]
		get_user_name(id,name,31)
		if(charcaps(Speech))
		{
			strtolower(Speech)
			grammarize(Speech,1)
			strtoupper(Speech)
			format(Speech,299,"%s: %s",name,Speech)
			client_print(0,print_chat,Speech)
			return PLUGIN_HANDLED
		}
		grammarize(Speech,0)
		format(Speech,299,"%s: %s",name,Speech)
		client_print(0,print_chat,Speech)
	}
	else return PLUGIN_CONTINUE
	return PLUGIN_HANDLED
}
public defaultgun(id) {

	if(zombie[id])
	{
		new weapon = random(2)
		if(weapon == 0) weapon = 25
		if(weapon == 1) weapon = 35
		if(weapon == 2) weapon = 34
		
		//client_print(id, print_chat, "Random Melee weapon given")
		info_add_msg(id,"Random Melee weapon given")
		ts_giveweapon(id,weapon,1,0);
		return PLUGIN_HANDLED
	} 
	new extra = random(31)
	new weapon = random(34) + 1
	new clips = random(255)
	if(weapon == 25 || weapon == 35 || weapon == 29 || weapon == 2 || weapon == 28 || weapon == 24) {
		defaultgun(id)
		return PLUGIN_HANDLED
	}
	if(givegun(id,weapon,1,1))
	{
		new str[128]
		format(str,128,"Random Weapon Given: Weaponid: %d, Ammo: %d, Flags: %d", weapon, clips, extra)
		//client_print(id, print_chat, "Random Weapon Given: Weaponid: %d, Ammo: %d, Flags: %d", weapon, clips, extra)
		info_add_msg(id,str)
	}
	return PLUGIN_HANDLED
}
public givegun(id,weapon,lvl,slot)
	{
		if(zombie[id])
		{
			if(weapon != 25 && weapon != 35 && weapon != 34)
			{
				//client_print(id,print_chat,"Zombies cannot obtain guns")
				info_add_msg(id,"Zombies cannot obtain guns");
				return 0
			}
		}
		if(!is_user_alive(id))
		{
			//client_print(id,print_chat,"You can't get a weapon while dead.")
			info_add_msg(id,"You can't get a weapon while dead.");
			return 0
		}
		if(curslots[id] == 0)
		{
			//client_print(id, print_chat, "Out of weapon slots. Use weapons on the ground.")
			info_add_msg(id,"Out of weapon slots. Use weapons on the ground.");
			return 0
		}
		if(curslots[id] < slot && get_cvar_num("sv_useslots"))
		{
			//client_print(id, print_chat, "Not enough slots.")
			info_add_msg(id,"Not enough slots.");
			return 0
		}
		if(g_level[id] < lvl) {
			new str[64]
			format(str,63,"You must be level %i to spawn this.",lvl);
			//client_print(id, print_chat, "You must be level %i to spawn this.",lvl)
			info_add_msg(id,str);
			return 0
		}
		ts_giveweapon(id, weapon, 210, added[id])
		if(get_cvar_num("sv_useslots"))
		{
			curslots[id] -= slot
			SetGlobalFmt(id)
		}
		if(!zombie[id] && oldspeed[id] != 0.0)
		{
			if(speed[id] == 1) {
				oldspeed[id] = get_user_maxspeed(id)
				set_pev(id, pev_maxspeed,450.0)
			}
			else if(speed[id] == 2) {
				oldspeed[id] = get_user_maxspeed(id)
				set_pev(id, pev_maxspeed,475.0)
			}
			else if(speed[id] == 3) {
				oldspeed[id] = get_user_maxspeed(id)
				set_pev(id, pev_maxspeed,500.0)
			}
			else if(speed[id] == 4) {
				oldspeed[id] = get_user_maxspeed(id)
				set_pev(id, pev_maxspeed,525.0)
			}
			else if(speed[id] == 5) {
				oldspeed[id] = get_user_maxspeed(id)
				set_pev(id, pev_maxspeed,550.0)
			}
			else if(speed[id] == 6) {
				oldspeed[id] = get_user_maxspeed(id)
				set_pev(id, pev_maxspeed,575.0)
			}
			else if(speed[id] == 7) {
				oldspeed[id] = get_user_maxspeed(id)
				set_pev(id, pev_maxspeed,600.0)
			}
		}
		return 1
	}
public deagle(id) {
	if(givegun(id,12,get_cvar_num("sv_deagle_level"),1))
		//client_print(id, print_chat, "Desert Eagle Given")
		info_add_msg(id,"Desert Eagle Given")
	return PLUGIN_HANDLED
}
public socom(id) {
	if(givegun(id,9,get_cvar_num("sv_socom_level"),1))
		//client_print(id, print_chat, "Socom MK23 Given")
		info_add_msg(id,"Socom MK23 Given")
	return PLUGIN_HANDLED
}
public beretta(id) {
	if(givegun(id,8,get_cvar_num("sv_beretta_level"),1))
		//client_print(id, print_chat, "Beretta Given")
		info_add_msg(id,"Beretta Given")
	return PLUGIN_HANDLED
}
public colts(id) {
	if(givegun(id,21,get_cvar_num("sv_colts_level"),1))
		//client_print(id, print_chat, "Golden Colts Given")
		info_add_msg(id,"Golden Colts Given")
	return PLUGIN_HANDLED
}
public glock18(id) {
	if(givegun(id,1,get_cvar_num("sv_glock18_level"),1))
		//client_print(id, print_chat, "Glock 18 Given")
		info_add_msg(id,"Glock 18 Given")
	return PLUGIN_HANDLED
}
public glock20c(id) {
	if(givegun(id,22,get_cvar_num("sv_glock20c_level"),1))
		//client_print(id, print_chat, "Glock 20c Given")
		info_add_msg(id,"Glock 20c Given")
	return PLUGIN_HANDLED
}
public fiveseven(id) {
	if(givegun(id,14,get_cvar_num("sv_fiveseven_level"),1))
		//client_print(id, print_chat, "Five Seven Given")
		info_add_msg(id,"Five Seven Given")
	return PLUGIN_HANDLED
}
public ruger(id) {
	if(givegun(id,28,get_cvar_num("sv_ruger_level"),1))
		//client_print(id, print_chat, "Ruger given")
		info_add_msg(id,"Ruger given")
	return PLUGIN_HANDLED
}
public givem3(id) {
	if(givegun(id,4,get_cvar_num("sv_m3_level"),1))
		//client_print(id,print_chat,"Benelli M3 Given")
		info_add_msg(id,"Benelli M3 Given")
	return PLUGIN_HANDLED
}
public uzis(id) {
	if(givegun(id,3,get_cvar_num("sv_uzis_level"),1))
		//client_print(id,print_chat,"Uzi given")
		info_add_msg(id,"Uzi given")
	return PLUGIN_HANDLED
}
public aug(id)
{
	if(givegun(id,15,get_cvar_num("sv_aug_level"),1))
		//client_print(id, print_chat, "Steyr AUG Given")
		info_add_msg(id,"Steyr AUG Given")
	return PLUGIN_HANDLED
}
public spas12(id)
{
	if(givegun(id,20,get_cvar_num("sv_spas12_level"),1))
		//client_print(id, print_chat, "SPAS-12 Given")
		info_add_msg(id,"SPAS-12 Given")
	return PLUGIN_HANDLED
}
public mossberg(id)
{
	if(givegun(id,26,get_cvar_num("sv_mossberg_level"),1))
		//client_print(id, print_chat, "Mossberg 500 Given")
		info_add_msg(id,"Mossberg 500 Given")
	return PLUGIN_HANDLED
}
public ump(id)
{
	if(givegun(id,23,get_cvar_num("sv_ump_level"),1))
		//client_print(id, print_chat, "UMP Given")
		info_add_msg(id,"UMP Given")
	return PLUGIN_HANDLED
}
public mp7(id)
{
	if(givegun(id,19,get_cvar_num("sv_mp7_level"),1))
		//client_print(id, print_chat, "MP7-PDW Given")
		info_add_msg(id,"MP7-PDW Given")
	return PLUGIN_HANDLED
}
public m16(id){
	if(givegun(id,27,get_cvar_num("sv_m16_level"),1))
		//client_print(id, print_chat, "M16A4 Given")
		info_add_msg(id,"M16A4 Given")
	return PLUGIN_HANDLED
}
public ak47(id){
	if(givegun(id,13,get_cvar_num("sv_ak47_level"),1))
		//client_print(id, print_chat, "AK47 Given")
		info_add_msg(id,"AK47 Given")
	return PLUGIN_HANDLED
}
public m4a1(id) {
	if(givegun(id,5,get_cvar_num("sv_m4a1_level"),1))
		//client_print(id, print_chat, "M4A1 Given")
		info_add_msg(id,"M4A1 Given")
	return PLUGIN_HANDLED
}
public barret(id) {
	if(givegun(id,18,get_cvar_num("sv_barret_level"),2))
		//client_print(id, print_chat, "Barret M82 Given")
		info_add_msg(id,"Barret M82 Given")
	return PLUGIN_HANDLED
}
public mp5sd(id) {
	if(givegun(id,6,get_cvar_num("sv_mp5sd_level"),1))
		//client_print(id, print_chat, "MP5SD Given.")
		info_add_msg(id,"MP5SD Given.")
	return PLUGIN_HANDLED
}
public mp5k(id) {
	if(givegun(id,7,get_cvar_num("sv_mp5k_level"),1))
		//client_print(id, print_chat, "MP5K Given.")
		info_add_msg(id,"MP5K Given.")
	return PLUGIN_HANDLED
}
public ragingbull(id) {
	if(givegun(id,31,get_cvar_num("sv_ragingbull_level"),1))
		//client_print(id, print_chat, "Raging Bull Given.")
		info_add_msg(id,"Raging Bull Given.")
	return PLUGIN_HANDLED
}
public m60(id) {
	if(givegun(id,32,get_cvar_num("sv_m60_level"),3))
		//client_print(id, print_chat, "M60 Given.")
		info_add_msg(id,"M60 Given.")
	return PLUGIN_HANDLED
}
public sawedoff(id) {
	if(givegun(id,33,get_cvar_num("sv_sawedoff_level"),1))
		//client_print(id, print_chat, "Sawed Off Shotgun Given.")
		info_add_msg(id,"Sawed Off Shotgun Given.")
	return PLUGIN_HANDLED
}
public autoshottie(id) {
	if(givegun(id,11,get_cvar_num("sv_autoshottie_level"),2))
		//client_print(id, print_chat, "USAS12 Given")
		info_add_msg(id,"USAS12 Given")
	return PLUGIN_HANDLED
}
public skorpion(id) {
	if(givegun(id,17,get_cvar_num("sv_skorpion_level"),1))
		//client_print(id, print_chat, "Skorpion Given")
		info_add_msg(id,"Skorpion Given")
	return PLUGIN_HANDLED
}
public contender(id) {
	if(givegun(id,36,get_cvar_num("sv_contender_level"),2))
		//client_print(id, print_chat, "Contender Given")
		info_add_msg(id,"Contender Given")
	return PLUGIN_HANDLED
}
// A Lightning Effect
stock basic_lightning(s_origin[3],e_origin[3],life = 8)
{

	message_begin( MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte( 0 )
	write_coord(s_origin[0])
	write_coord(s_origin[1])
	write_coord(s_origin[2])
	write_coord(e_origin[0])
	write_coord(e_origin[1])
	write_coord(e_origin[2])
	write_short( lightning )
	write_byte( 1 ) // framestart
	write_byte( 5 ) // framerate
	write_byte( life ) // life
	write_byte( 20 ) // width
	write_byte( 30 ) // noise
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // r, g, b
	write_byte( 200 ) // brightness
	write_byte( 200 ) // speed
	message_end()

	message_begin( MSG_PVS, SVC_TEMPENTITY,e_origin)
	write_byte( 9 )
	write_coord( e_origin[0] )
	write_coord( e_origin[1] )
	write_coord( e_origin[2] )
	message_end()
	return PLUGIN_HANDLED
}

// Shaking a users screen
stock basic_shake(id,amount = 14, length = 14)
{
      message_begin(MSG_ONE, get_user_msgid("ScreenShake"), {0,0,0}, id)
      write_short(255<< amount ) //ammount 
      write_short(10 << length) //lasts this long 
      write_short(255<< 14) //frequency 
      message_end()
}

public create_ent(target, model[])
{
	remove_ent(target)
	new ent = create_entity("info_target")
	if(ent > 0)
	{
		new Float:origin[3]
		entity_set_string(ent, EV_SZ_classname, "aim_ent")
		entity_set_model(ent, model)
		entity_set_int(ent, EV_INT_solid, SOLID_NOT)
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_FOLLOW)
		entity_set_int(ent, EV_INT_rendermode, 5)
		entity_set_float(ent, EV_FL_renderamt,155.0)
		entity_set_float(ent, EV_FL_scale, 1.0)
		entity_set_edict(ent, EV_ENT_aiment, target)
		entity_get_vector(target, EV_VEC_origin, origin)
		origin[2] += 30.0
		entity_set_vector(ent, EV_VEC_origin, origin)
	}
}

public remove_ent(target)
{
	new ent = find_ent_by_class(-1, "aim_ent")
	while(ent > 0)
	{
		new temp_ent = find_ent_by_class(ent, "aim_ent")
		if(entity_get_edict(ent, EV_ENT_aiment) == target)
		{
			remove_entity(ent)
		}
		ent = temp_ent
	}
}
public grammarize(Speech[],caps)
{
	new iStringSize = 0
	while(Speech[iStringSize] != 0) iStringSize++
	new why;
	ucfirst(Speech)
	if(equrplc(Speech,299,"R ","Are ",2)) why = 1
	equrplc(Speech,299,"U ","You ",2)
	equrplc(Speech,299,"Ur ","Your ",2)
	if(equrplc(Speech,299,"Y ","Why ",2)) why = 1
	equrplc(Speech,299,"O ","Oh ",2)
	equrplc(Speech,299,"Plz","Please",3)
	equrplc(Speech,299,"Im ","I'm ",3)
	do {
		replace(Speech,299," r "," are ")
	} while(contain(Speech," r ") != -1) 
	do {
		replace(Speech,299," u "," you ")
	} while(contain(Speech," u ") != -1) 
	do {
		replace(Speech,299," ur "," your ")
	} while(contain(Speech," ur ") != -1)
	do {
		replace(Speech,299," y "," why ")
	} while(contain(Speech," y ") != -1)
	do {
		replace(Speech,299," o "," oh ")
	} while(contain(Speech," o ") != -1) 
	do {
		replace(Speech,299," im "," I'm ")
	} while(contain(Speech," im ") != -1)
	do {
		replace(Speech,299,"thats","that's")
	} while(contain(Speech,"thats") != -1)
	do {
		replace(Speech,299,"itll","it'll")
	} while(contain(Speech,"itll") != -1)
	do {
		replace(Speech,299,"youre","you're")
	} while(contain(Speech,"youre") != -1)
	do {
		replace(Speech,299,"plz","Please")
	} while(contain(Speech,"plz") != -1)
	do {
		replace(Speech,299," i "," I ")
	} while(contain(Speech," i ") != -1)
	for(new i=0;i<iStringSize;i++)
	{
		if(Speech[i] == '.' && Speech[i+1] == ' ')
		{
			i += 2
			if(Speech[i]) Speech[i] = toupper(Speech[i])
		}
	}
	if(equali(Speech,"why",3)) why = 1
	if(equali(Speech,"are",3)) why = 1
	if(equali(Speech,"how",3)) why = 1
	if(equali(Speech,"what",4)) why = 1
	if(equali(Speech,"who",3)) why = 1
	if(equali(Speech,"where",5)) why = 1
	if(equali(Speech,"when",4)) why = 1
	if(equali(Speech,"can",3)) why = 1
	if(equal(Speech[iStringSize-1],"?") || equal(Speech[iStringSize-1],".") || equal(Speech[iStringSize-1],"!") || equal(Speech[iStringSize-1],",") || equal(Speech[iStringSize-1],";"))
	{
	}
	else
	{
		if(caps) add(Speech,299,"!");
		else if(why)	add(Speech,299,"?")
		else add(Speech,299,".")
	}
}
public charcaps(szText[])
{
	new haschar = 0, iCount = 0;
	new iLen = strlen(szText)
	for(new i=0;i<iLen;i++)
	{
		if(isalpha(szText[i])) haschar = 1;
		if(szText[i] == toupper(szText[i])) iCount++
	}
	if(haschar && iCount == iLen) return 1
	return 0;
}
public equrplc(szText1[],len,szText2[],szText3[],num)
{
	new i  = equal( szText1, szText2, num )
	if(i)
	{
		replace(szText1,len,szText2,szText3)
	}
	return i;
}
public SetGlobalFmt(id)
{ 
		if(is_user_bot(id)) return PLUGIN_HANDLED;
		new objstat[33];
		if(objectivedone[id] > 0) objstat = "Finished";
		else objstat = "In progress";

		globalfmt[id] = "";

		if(get_cvar_num("sv_useslots")) format(	globalfmt[id],179," Slots: %i/%i^n",curslots[id],slots[id]);
		else format(globalfmt[id],179," Slots: Infinite^n");

		if(rerate[id]) format(globalfmt[id],179,"%s Health Recharge Rate: %i^n",globalfmt[id],rerate[id]);
		else format(globalfmt[id],179,"%s Health Recharge Rate: None^n",globalfmt[id]);

		if(speed[id]) format(globalfmt[id],179,"%s Powerups: speed %i/%i^n",globalfmt[id],curspeed[id],speed[id]);
		else format(globalfmt[id],179,"%s Powerups: None^n",globalfmt[id]);
		
		format(globalfmt[id],179,"%s^n Objective: %s^n Objective Status: %s^n Objective Reward: %i EXP",globalfmt[id],objective[id],objstat,objectivereward[id]);
		return PLUGIN_HANDLED
}
public advance_light()
{
	g_internal_hour++;
	if( g_internal_hour == 24 ) g_internal_hour = 0;
	
	set_lights( g_lights[g_internal_hour] )
	server_print("Setting lights to %s with hour %i",g_lights[g_internal_hour],g_internal_hour);

	if(lighton != g_onlight[g_internal_hour])
	{
		new ent = 1;
		while(ent)
		{
			ent = find_ent_by_tname( ent, "indoorlights" );
			if(ent > 0)
			{
				force_use(ent,ent)
				fake_touch(ent,ent)
			}
		}
		lighton = g_onlight[g_internal_hour]
	}
	
	return PLUGIN_HANDLED
}