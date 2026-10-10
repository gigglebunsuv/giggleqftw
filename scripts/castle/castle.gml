//The Castle of Bunsriel (rm_castle, dungeon 4): the last dungeon, taken by the Sapphire Order.
//rm_castle is built by dungeon_placeholders/make_castle_room.py (close GameMaker and re-run it after
//changing the layout). Its enemies are in castle_enemies, the mini-boss in boss_archmage, the Evil
//King in boss_evil_king, the ending in the ending script.
//
//The castle's own things:
//	obj_crystal_switch	a crystal orb: the boomerang (or the sword) strikes it and it turns orange for
//						good. A shutter door with open_when = "crystal" opens once every crystal in
//						one of its rooms has been struck.
//	obj_rubble			a heap of fallen masonry (a wall): only a dash with the running boots smashes it.
//	obj_bomb_wall		cracked wall (sprite_index = spr_castle_crack in the castle). Bombs break it, and
//						now it stays broken (its flag) everywhere in the game.
//	deep water			the sewers (the room's "Water" layer): the flippers.

#macro CASTLE_START_X 1984		//the castle's gatehouse, inside the front door (printed by make_castle_room.py)
#macro CASTLE_START_Y 776
#macro WORLD_CASTLE_X 1760		//in front of the castle's door (rm_overworld)
#macro WORLD_CASTLE_Y 200
#macro GAME_CLEAR_FLAG "game_clear"

///crystal_switch_step();
function crystal_switch_step() {
	//Run by obj_crystal_switch: the boomerang or the sword strikes it
	if (!checked) {
		checked = true;
		on = flag_get(door_flag());
	}
	image_index = on;
	if (on) return;
	var b = collision_rectangle(bbox_left - 3, bbox_top - 3, bbox_right + 3, bbox_bottom + 3, obj_boomerang, false, true);
	var s = (instance_exists(obj_sword) && place_meeting(x, y, obj_sword));
	if (b != noone || s) {
		on = true;
		image_index = 1;
		flag_set(door_flag(), true);
		sfx_play(SFX_SWITCH);
		instance_create_depth(x - 4, y - 4, depth - 1, obj_enemy_death);
		if (b != noone) {with (b) {state = "back"}}
	}


}

///zone_crystals_on(zone);
function zone_crystals_on(argument0) {
	//True when every obj_crystal_switch in a camera zone has been struck (and it has at least one)
	var z = argument0;
	var n = 0;
	var on_n = 0;
	with (obj_crystal_switch) {
		if (point_in_rectangle(x + 8, y + 8, z.bbox_left, z.bbox_top, z.bbox_right, z.bbox_bottom)) {
			n++;
			if (on || flag_get(door_flag())) {on_n++}
		}
	}
	return n > 0 && on_n == n;


}

///rubble_dash_check(x, y);
function rubble_dash_check(argument0, argument1) {
	//Run by obj_link while dashing: rubble in the way is smashed (instead of bonking). True if it was.
	var rb = instance_place(argument0, argument1, obj_rubble);
	if (rb == noone) return false;
	with (rb) {
		flag_set(door_flag(), true);
		rock_break(x + 8, y + 8);
		instance_destroy();
	}
	feel_shake(2, 6);
	return true;


}

///castle_music();
function castle_music() {
	//Run by Menu_Castle when rm_castle starts
	audio_stop_all();
	options_volume_apply();
	audio_play_sound(CastleTheme, 1, true);
	global.world_music = CastleTheme;


}
