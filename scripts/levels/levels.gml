//Dungeon helpers: upper/lower levels, level-aware collision, tiled drawing.
//
//Level 0 = lower floor, level 1 = upper floor (ledges, bridges).
//	obj_wall		blocks both levels (obj_dungeon_wall is a visible child)
//	obj_wall_low	blocks only the lower level (obj_ledge is a visible child: a cliff from below)
//	obj_wall_high	blocks only the upper level (railings on ledges and bridges)
//	obj_stairs		changes Link's level as he climbs, obj_level_zone sets it in doorways

//Draw depths in rooms that use levels (lower number = drawn on top)
#macro DEPTH_DECOR 150	//floor details: walls, ledges, stairs
#macro DEPTH_LOWER 100	//Link and enemies on the lower floor
#macro DEPTH_BRIDGE 50	//bridges: above the lower floor, below the upper floor
#macro DEPTH_UPPER 0	//Link on the upper floor
#macro DEPTH_FLYING -50	//bats

///level_wall_at(x, y, level);
function level_wall_at(argument0, argument1, argument2) {
	//True if the calling instance would hit a wall for this level at (x, y)
	if (place_meeting(argument0, argument1, obj_wall)) return true;
	if (argument2 == 1) return place_meeting(argument0, argument1, obj_wall_high);
	return place_meeting(argument0, argument1, obj_wall_low);


}

///level_line_clear(x1, y1, x2, y2, level);
function level_line_clear(argument0, argument1, argument2, argument3, argument4) {
	//True if nothing blocks a straight line on this level (used for line of sight)
	if (collision_line(argument0, argument1, argument2, argument3, obj_wall, false, true) != noone) return false;
	var other_wall = obj_wall_low;
	if (argument4 == 1) {other_wall = obj_wall_high}
	return collision_line(argument0, argument1, argument2, argument3, other_wall, false, true) == noone;


}

///level_move(hspd, vspd, level);
function level_move(argument0, argument1, argument2) {
	//Moves the calling instance, sliding up against walls for this level.
	//Returns true if it bumped into something.
	var hs = argument0;
	var vs = argument1;
	var lvl = argument2;
	var hit = false;

	if (hs != 0 && level_wall_at(x + hs, y, lvl)) {
		repeat (ceil(abs(hs))) {
			if (level_wall_at(x + sign(hs), y, lvl)) break;
			x += sign(hs);
		}
		hit = true;
	} else {
		x += hs;
	}

	if (vs != 0 && level_wall_at(x, y + vs, lvl)) {
		repeat (ceil(abs(vs))) {
			if (level_wall_at(x, y + sign(vs), lvl)) break;
			y += sign(vs);
		}
		hit = true;
	} else {
		y += vs;
	}

	return hit;


}

///level_set(level);
function level_set(argument0) {
	//Run by obj_link. Moves him to a level and draws him above or below bridges.
	level = argument0;
	if (level == 1) {depth = DEPTH_UPPER}
	else {depth = DEPTH_LOWER}


}

///level_room_uses_levels();
function level_room_uses_levels() {
	return instance_exists(obj_stairs) || instance_exists(obj_bridge) || instance_exists(obj_level_zone);


}

///dungeon_draw_tiles(sprite, x, y, w, h);
function dungeon_draw_tiles(argument0, argument1, argument2, argument3, argument4) {
	//Repeats frame 0 of a sprite to fill a w x h area (no stretching)
	var spr = argument0;
	var sw = sprite_get_width(spr);
	var sh = sprite_get_height(spr);
	for (var yy = 0; yy < argument4; yy += sh) {
		for (var xx = 0; xx < argument3; xx += sw) {
			draw_sprite_part(spr, 0, 0, 0, min(sw, argument3 - xx), min(sh, argument4 - yy), argument1 + xx, argument2 + yy);
		}
	}


}
