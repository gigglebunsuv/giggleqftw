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
#macro SFX_PICKUP "snd_pickup"
#macro SFX_DASH "snd_dash"
#macro SFX_BONK "snd_bonk"
#macro SFX_SPLASH "snd_splash"
#macro SFX_ROCK "snd_rock"
#macro SFX_JUMP "snd_jump"	//the cape
#macro SFX_FALL "snd_fall"	//into a pit
#macro SFX_LIFT "snd_lift"
#macro SFX_THROW "snd_throw"
#macro SFX_ITEM_GET "snd_item_get"
#macro SFX_CHEST "snd_chest"	//a chest opening
#macro SFX_TEXT "snd_text"	//text box letters typing out

///sfx_play(name);
function sfx_play(argument0) {
	//Plays the sound with this name once. Returns the sound instance, or -1 if there's no such sound.
	if (asset_get_type(argument0) != asset_sound) return -1;
	return audio_play_sound(asset_get_index(argument0), 5, false);


}
