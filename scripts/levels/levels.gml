//Dungeon helpers: upper/lower levels, level-aware collision, tiled drawing.
//
//Level 0 = lower floor, level 1 = upper floor (ledges, bridges), level 2 = the third level
//(raised floor on top of raised floor).
//	obj_wall		blocks every level (obj_dungeon_wall is a visible child)
//	obj_water		deep water: Link needs the flippers, walking enemies can't go in
//	obj_pit			a hole: Link falls in (the cape jumps over it), walking enemies can't go in
//	obj_quicksand	slows Link down and swallows him if he stays (see the ladhellin script)
//	obj_wall_low	blocks only the lower level (obj_ledge is a visible child: a cliff from below)
//	obj_wall_high	blocks only the upper level (railings on ledges and bridges)
//	obj_wall_top	blocks only the third level (its railings)
//	obj_stairs		changes Link's level as he climbs (low_level and the one above it),
//					obj_level_zone sets it in doorways
//	obj_ledge_drop	a cliff with no railing: blocks the level above land_level, and walking down
//					into it from there hops Link down to land_level (ledge_hop_check)

//Draw depths in rooms that use levels (lower number = drawn on top)
#macro DEPTH_DECOR 150	//floor details: walls, ledges, stairs
#macro DEPTH_LOWER 100	//Link and enemies on the lower floor
#macro DEPTH_BRIDGE 50	//bridges: above the lower floor, below the upper floor
#macro DEPTH_UPPER 0	//Link on the upper floor
#macro DEPTH_TOP -10	//Link on the third level
#macro DEPTH_FLYING -50	//bats

//Rooms can have tile layers with these names: any tile painted on them is a wall / deep water
//(see collision_tiles_make)
#macro COLLISION_LAYER "Collision"
#macro WATER_LAYER "Water"
#macro PIT_LAYER "Pits"
#macro PIT_ART_LAYER "Pits_Art"	//pits too, but the layer stays visible: its tiles are the holes' pictures
#macro WALL_LOW_LAYER "Wall_Low"	//obj_wall_low: raised floor and its cliffs (blocks the lower level)
#macro WALL_HIGH_LAYER "Wall_High"	//obj_wall_high: the edges of raised floor (blocks the upper level)
#macro WALL_TOP_LAYER "Wall_Top"	//obj_wall_top: the edges of the third level (blocks it)

//Hopping down off a ledge
#macro HOP_TIME 14			//steps in the air
#macro HOP_HEIGHT 8			//pixels at the top of the hop
#macro HOP_REACH 48			//furthest down Link looks for somewhere to land

///level_wall_at(x, y, level);
function level_wall_at(argument0, argument1, argument2) {
	//True if the calling instance would hit a wall for this level at (x, y)
	if (place_meeting(argument0, argument1, obj_wall)) return true;
	//Deep water: Link needs the flippers (or the ice rod's floes), walking enemies can't go in,
	//everything else flies over
	if (place_meeting(argument0, argument1, obj_water)) {
		if (object_index == obj_link) {
			if (!global.hasFlippers && water_open_at(argument0, argument1)) return true;
		} else if (object_is_ancestor(object_index, obj_enemy) && level != -1) {
			return true;
		}
	}
	//Pits: walking enemies don't walk in (Link does, and falls, see player_pit_check)
	if (object_is_ancestor(object_index, obj_enemy) && level != -1 && place_meeting(argument0, argument1, obj_pit)) return true;
	//A cliff Link can hop down: a wall for the level above where he'd land
	if (argument2 >= 1) {
		var drop = instance_place(argument0, argument1, obj_ledge_drop);
		if (drop != noone && drop.land_level + 1 == argument2) return true;
	}
	if (argument2 == 2) return place_meeting(argument0, argument1, obj_wall_top);
	if (argument2 == 1) return place_meeting(argument0, argument1, obj_wall_high);
	return place_meeting(argument0, argument1, obj_wall_low);


}

///level_line_clear(x1, y1, x2, y2, level);
function level_line_clear(argument0, argument1, argument2, argument3, argument4) {
	//True if nothing blocks a straight line on this level (used for line of sight)
	if (collision_line(argument0, argument1, argument2, argument3, obj_wall, false, true) != noone) return false;
	var other_wall = obj_wall_low;
	if (argument4 == 1) {other_wall = obj_wall_high}
	if (argument4 == 2) {other_wall = obj_wall_top}
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
	if (level == 2) {depth = DEPTH_TOP}
	else if (level == 1) {depth = DEPTH_UPPER}
	else {depth = DEPTH_LOWER}


}

///ledge_hop_check();
function ledge_hop_check() {
	//Run by obj_link: walking down into an obj_ledge_drop (a cliff without a railing) from the
	//level above its land_level hops him off it, down to the first clear spot on land_level
	//past the cliff
	if (state != "idle" || level < 1 || swimming || carrying || yy <= 0) return;
	var drop = instance_place(x, y + 2, obj_ledge_drop);
	if (drop == noone || drop.land_level + 1 != level) return;
	var to = drop.land_level;
	for (var d = 8; d <= HOP_REACH; d++) {
		if (!level_wall_at(x, y + d, to) && !position_meeting(x, y + d, obj_pit)) {
			hop_y0 = y;
			hop_y1 = y + d;
			hop_level = to;
			state = "hop";
			cnt = 0;
			dur = HOP_TIME;
			shielding = false;
			pose = -1;
			dir = "down";
			sprite_index = player_get_sprite(dir);
			sfx_play(SFX_HOP);
			return;
		}
	}


}

///ledge_hop_step();
function ledge_hop_step() {
	//Run by obj_link: in the air over the cliff (state "hop"), then he's on the level below
	if (state != "hop") return;
	cnt++;
	var t = min(1, cnt / dur);
	y = round(lerp(hop_y0, hop_y1, t));
	z = HOP_HEIGHT * sin(pi * t);
	if (t >= 1) {
		z = 0;
		state = "idle";
		level_set(hop_level);
		move_frac_x = 0;
		move_frac_y = 0;
		sfx_play(SFX_LAND);
	}


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

///collision_tiles_make();
function collision_tiles_make() {
	//Run at Room Start. Tiles painted on the room's COLLISION_LAYER become obj_wall and tiles on
	//its WATER_LAYER become obj_water (deep water), tiles on its PIT_LAYER become obj_pit (holes),
	//and the layers are hidden. Tiles on its PIT_ART_LAYER become obj_pit too, but that layer
	//stays visible (the tiles are the holes' pictures) and the placeholder holes aren't drawn.
	//Tiles on its WALL_LOW_LAYER / WALL_HIGH_LAYER / WALL_TOP_LAYER become obj_wall_low /
	//obj_wall_high / obj_wall_top (the levels).
	//Paint or erase tiles on them in the room editor to change where Link can walk and swim.
	layer_tiles_to_instances(COLLISION_LAYER, obj_wall);
	layer_tiles_to_instances(WATER_LAYER, obj_water);
	layer_tiles_to_instances(PIT_LAYER, obj_pit);
	layer_tiles_to_instances(WALL_LOW_LAYER, obj_wall_low);
	layer_tiles_to_instances(WALL_HIGH_LAYER, obj_wall_high);
	layer_tiles_to_instances(WALL_TOP_LAYER, obj_wall_top);
	layer_tiles_to_instances(QUICKSAND_LAYER, obj_quicksand);

	//The Sun Lens's mirage layers start out showing the mirages (see the sun_lens script)
	lens_layers_set(false);

	//Holes painted with real tiles: no placeholder drawing for those
	var made = layer_tiles_to_instances(PIT_ART_LAYER, obj_pit);
	if (layer_get_id(PIT_ART_LAYER) != -1) {layer_set_visible(PIT_ART_LAYER, true)}
	for (var i = 0; i < array_length(made); i++) {made[i].visible = false}


}

///layer_tiles_to_instances(layer_name, object);
function layer_tiles_to_instances(argument0, argument1) {
	//Turns every tile on a tile layer into instances of object, merged into as few
	//rectangles as possible, and hides the layer. Does nothing if the room has no such layer.
	//Returns the instances it made.
	var made = [];
	var lay = layer_get_id(argument0);
	if (lay == -1) return made;
	var map = layer_tilemap_get_id(lay);
	if (map == -1) return made;
	layer_set_visible(lay, false);

	var cols = tilemap_get_width(map);
	var rows = tilemap_get_height(map);
	var tw = tilemap_get_tile_width(map);
	var th = tilemap_get_tile_height(map);
	var used = ds_grid_create(cols, rows);
	ds_grid_clear(used, false);

	for (var cy = 0; cy < rows; cy++) {
		for (var cx = 0; cx < cols; cx++) {
			if (used[# cx, cy] || tile_get_index(tilemap_get(map, cx, cy)) == 0) continue;

			//Widest run to the right, then as many rows down as have the same run
			var w = 0;
			while (cx + w < cols && !used[# cx + w, cy] && tile_get_index(tilemap_get(map, cx + w, cy)) != 0) {w++}
			var h = 1;
			var grow = true;
			while (grow && cy + h < rows) {
				for (var i = 0; i < w; i++) {
					if (used[# cx + i, cy + h] || tile_get_index(tilemap_get(map, cx + i, cy + h)) == 0) {
						grow = false;
						break;
					}
				}
				if (grow) {h++}
			}
			ds_grid_set_region(used, cx, cy, cx + w - 1, cy + h - 1, true);

			var inst = instance_create_depth(cx * tw, cy * th, 0, argument1);
			inst.image_xscale = w * tw / sprite_get_width(inst.sprite_index);
			inst.image_yscale = h * th / sprite_get_height(inst.sprite_index);
			array_push(made, inst);
		}
	}
	ds_grid_destroy(used);
	return made;


}
