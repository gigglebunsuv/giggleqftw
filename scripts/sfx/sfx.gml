//Sound effects, looked up by name.
//To add or replace one, import a sound into the Sounds folder with one of these names.
//A sound that hasn't been imported yet is simply skipped, so the game never breaks.

#macro SFX_PLAYER_HURT "snd_player_hurt"
#macro SFX_PLAYER_DIE "snd_player_die"
#macro SFX_ENEMY_HIT "snd_enemy_hit"
#macro SFX_ENEMY_DIE "snd_enemy_die"
#macro SFX_SHIELD "snd_shield"
#macro SFX_ENEMY_STUN "snd_enemy_stun"
#macro SFX_BOMB "snd_bomb"
#macro SFX_HOOK_HIT "snd_hook_hit"
#macro SFX_DRINK "snd_drink"
#macro SFX_LANTERN "snd_lantern"
#macro SFX_FIRE_ROD "snd_fire_rod"
#macro SFX_ICE_ROD "snd_ice_rod"
#macro SFX_LIGHTNING_ROD "snd_lightning_rod"
#macro SFX_TORCH "snd_torch"
#macro SFX_FLUTE "snd_flute"
#macro SFX_HAMMER "snd_hammer"
#macro SFX_DIG "snd_dig"
#macro SFX_CAPE "snd_cape"
#macro SFX_MIRROR "snd_mirror"
#macro SFX_HEART "snd_heart"	//picking up a heart
#macro SFX_MONEY "snd_money"	//picking up money
#macro SFX_MAGIC "snd_magic"	//picking up a magic jar
#macro SFX_DASH "snd_dash"
#macro SFX_BONK "snd_bonk"
#macro SFX_SPLASH "snd_splash"
#macro SFX_ROCK "snd_rock"
#macro SFX_JUMP "snd_jump"	//the cape
#macro SFX_FALL "snd_fall"	//into a pit
#macro SFX_LIFT "snd_lift"
#macro SFX_THROW "snd_throw"
#macro SFX_ITEM_GET "snd_item_get"	//small things: map, compass, keys, money, refills, bottles
#macro SFX_FANFARE_ITEM "snd_fanfare_item"	//a big item: a dungeon's treasure, boss key, sword, shield...
#macro SFX_HEART_CONTAINER "snd_heart_container"	//a heart container
#macro SFX_FANFARE_BUN "snd_fanfare_bun"	//a piece of the Bun
#macro SFX_CHEST "snd_chest"	//a chest opening
#macro SFX_TEXT "snd_text"	//text box letters typing out
#macro SFX_STAIRS "move_room"	//the stairs between floors in a dungeon
#macro SFX_LAND "snd_land"	//dropping down from the floor above
#macro SFX_DOOR "snd_door"	//a locked or boss door opening
#macro SFX_SHUTTER "snd_shutter"	//a shutter door opening or closing
#macro SFX_SWITCH "snd_switch"	//a floor switch pressed
#macro SFX_KEY "snd_key"	//a small key appearing (a room cleared)
#macro SFX_BOSS_ROAR "snd_boss_roar"	//the boss waking up, getting pulled down
#macro SFX_WIND "snd_wind"	//the boss's wing gusts
#macro SFX_SWORD "sword"	//swinging the sword
#macro SFX_ARROW "snd_arrow"	//shooting an arrow
#macro SFX_BOOMERANG "snd_boomerang"	//throwing the boomerang
#macro SFX_POT "snd_pot_break"	//a pot smashing
#macro SFX_HOP "snd_hop"	//hopping down off a ledge
#macro SFX_SECRET "snd_secret"	//a puzzle solved: torches all lit, a switch opening a door
#macro SFX_GUARD_ALERT "snd_guard_alert"	//a guard spotting Link
#macro SFX_BLADE "snd_blade_trap"	//a blade trap sliding out
#macro SFX_FIREBALL "snd_fireball"	//the Gargoyle spitting a fireball
#macro SFX_BOSS_DEFEAT "snd_boss_defeat"	//the boss beaten (before it blows apart)
#macro SFX_WARP "snd_warp"	//stepping into a warp
#macro SFX_PAUSE "snd_pause"	//opening the pause screen
#macro SFX_BUSH "snd_bush"	//cutting a bush

///sfx_play(name);
function sfx_play(argument0) {
	//Plays the sound with this name once. Returns the sound instance, or -1 if there's no such sound.
	if (asset_get_type(argument0) != asset_sound) return -1;
	return audio_play_sound(asset_get_index(argument0), 5, false);


}
