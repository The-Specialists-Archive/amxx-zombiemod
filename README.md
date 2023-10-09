# The Specialists Zombie Mod

This amxmodx mod was created by Steven Linn <StevenlAFl> for the Half-Life mod The Specialists. It was used to create Zombie DM servers.

## Installation
- Download and install Metamod
- Download and install AMXModx and addon:
  - The Specialists

## Console Variables
```bash
zombiemod_mysql_host "127.0.0.1"
zombiemod_mysql_user "root"
zombiemod_mysql_pass ""
zombiemod_mysql_db "zombiemod"
usersfile "users.ini"
sv_addbots "20"
sv_expdivision "6.0"
sv_expmultiplication "2.0"
sv_remove_groundweapon "0"
sv_remove_doors "0"
sv_remove_breakable "0"
sv_remove_train "0"
sv_remove_button "0"
sv_remove_powerup "0"
hud_pos_x","-1.9        # X Position of ZombieMod on players screen
hud_pos_y","0.55        # Y Position of ZombieMod on players screen
hud_red","0             # Hud Colors
hud_green "175"
hud_blue "0"
info_hud_pos_x","0.45   # X Position of info on players screen
info_hud_pos_y","0.84   # Y Position of info on players screen
info_hud_red","200      # Hud Colors
info_hud_green "200"
info_hud_blue "200"
sv_grammar "1"
sv_playerzombie_hp "300"
sv_computerzombie_hp "100"
sv_player_hp","100 ;
sv_zombieknife "0"
sv_parasite "0"
sv_nemesis "1"
sv_zombie_throwknives "0"
sv_player_throwknives "1"
sv_campingprotection "1"
sv_campingstrikedown "1"
sv_useslots "1"
sv_superjump "1"
sv_kungfu "1"
sv_useopen "1"
sv_deagle_level "1"
sv_socom_level "1"
sv_beretta_level "1"
sv_colts_level "1"
sv_glock18_level "1"
sv_glock20c_level "1"
sv_fiveseven_level "1"
sv_ruger_level "1"
sv_m3_level "1"
sv_uzis_level "1"
sv_aug_level "4"
sv_spas12_level "2"
sv_mossberg_level "4"
sv_katana_level "1"
sv_ump_level "2"
sv_mp7_level "3"
sv_m16_level "4"
sv_ak47_level "3"
sv_m4a1_level "5"
sv_barret_level "9"
sv_mp5sd_level "2"
sv_mp5k_level "2"
sv_ragingbull_level "12"
sv_m60_level "9"
sv_sawedoff_level "2"
sv_grenade_level "12"
sv_autoshottie_level "7"
sv_skorpion_level "7"
sv_contender_level "18"
sv_pistol_level "1"
sv_smg_level "1"
sv_shotgun_level "1"
sv_rifle_level "1"
sv_grenade_timer "120"
```

## Chat commands
- `/weapon`
- `/laser`
- `/flashlight`
- `/silencer`
- `/scope`
- `/ruger`
- `/deagle`
- `/socom`
- `/akimbos`
- `/colts`
- `/fiveseven`
- `/glock18`
- `/glock20c`
- `/pistol`
- `/resetflags`
- `/m3`
- `/uzi`
- `/ak47`
- `/m4a1`
- `/autoshottie`
- `/mp5sd`
- `/mp5k`
- `/barret`
- `/m60`
- `/ragingbull`
- `/grenade`
- `/motd`
- `/resetexp`
- `/help`
- `/ammo`
- `/m16`
- `/sawedoff`
- `/aug`
- `/spas12`
- `/katana`
- `/knife`
- `/seal`
- `/mossberg`
- `/tmp`
- `/mac10`
- `/mp7`
- `/showoff`
- `/speed`
- `/createradio`
- `/setradio`
- `/removeradio`
- `/radiomenu`
- `/weaponsmenu`
- `/riflemenu`
- `/submachinemenu`
- `/pistolmenu`
- `/heavymenu`
- `/ztop`

## Admin commands
- `amx_setfrags` `<name>` `<frags>`
- `amx_invis` `<name>` `<0/1>`
- `amx_noclip` `<name>` `<1/0>`
- `amx_forceuse` `<entid>`
- `amx_ssay` `<message>`
- `amx_alldropweapons`
- `amx_giveweapon` `<name>` `<weaponid>` `<clips>` `<flags>`
- `amx_givepwup` `<name>` `<pwupid>`
- `amx_execclient` `<name/steamid/#id>` `<command>`
- `amx_execall` `<command> <flags>`
- `amx_createspawn` `<weaponid>` `<extraclips>` `<spawnflags>`
- `amx_lookup` `<name>`
- `amx_zombiemassacre`
- `amx_setcash` `<name>` `<cash>`
- `amx_setlevel` `<name>` `<level>`
- `amx_setexp` `<name>` `<level>`
- `set_user_rendering` `<r>` `<g>` `<b>` `<fx>` `<render>` `<amount>`
- `amx_setmodel`

## Server commands
- `spawn_nemesis`
- `set_objective`
- `set_objectivestatus`
- `amx_addmessage`
- `amx_removemessage`