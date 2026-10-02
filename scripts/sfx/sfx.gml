//Sound effects, looked up by name.
//To add or replace one, import a sound into the Sounds folder with one of these names.
//A sound that hasn't been imported yet is simply skipped, so the game never breaks.

#macro SFX_PLAYER_HURT "snd_player_hurt"
#macro SFX_PLAYER_DIE "snd_player_die"
#macro SFX_ENEMY_HIT "snd_enemy_hit"
#macro SFX_ENEMY_DIE "snd_enemy_die"

///sfx_play(name);
function sfx_play(argument0) {
	//Plays the sound with this name once. Returns the sound instance, or -1 if there's no such sound.
	if (asset_get_type(argument0) != asset_sound) return -1;
	return audio_play_sound(asset_get_index(argument0), 5, false);


}
