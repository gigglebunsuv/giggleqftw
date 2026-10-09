//The Tower of Ladhellin (rm_ladhellin_tower): quicksand and crumbling floors.
//
//rm_ladhellin_tower is built by dungeon_placeholders/make_ladhellin_room.py (close GameMaker and
//re-run it rather than editing the room by hand). Its mirages (hidden paths, false floors and walls)
//are tile layers the Sun Lens shows through, see the sun_lens script.
//
//Quicksand: tiles painted on a "Quicksand" tile layer become obj_quicksand (any room can have one,
//see collision_tiles_make). Link wades through it slowly and sinks if he stays in too long
//(player_quicksand_check): the cape's jump gets him out. An antlion (obj_antlion) at the middle of
//a patch drags him towards its jaws.
//
//obj_crumble: a cracked floor tile. A moment after Link steps on it, it falls away into a hole
//(an obj_pit), and comes back once he's left the room. The boss's quake drops them on its own
//(crumble_now) and they come back by themselves after a while.

#macro QUICKSAND_LAYER "Quicksand"
#macro QUICKSAND_SLOW 0.45		//times normal speed wading through it
#macro QUICKSAND_SINK_TIME 50	//steps in it before Link goes under (back to the last safe spot)
#macro QUICKSAND_DRAW_SINK 9	//pixels of Link hidden in the sand when he's about to go under
#macro CRUMBLE_TIME 16			//steps from stepping on a cracked tile until it falls away
#macro CRUMBLE_QUAKE_BACK 300	//steps a tile the boss's quake dropped stays a hole

///player_quicksand_check();
function player_quicksand_check() {
	//Run by obj_link before he moves: in quicksand he's slow (see the Step event) and slowly sinks.
	//Jumping out with the cape (or anything that lifts him off the ground) starts the count again.
	in_sand = false;
	if (state == "jump" || state == "fall" || state == "hop" || state == "land" || state == "pull" || state == "dead" || z > 0 || swimming) {
		sink_t = 0;
		return;
	}
	if (!position_meeting(x, y, obj_quicksand)) {
		sink_t = max(0, sink_t - 2);
		return;
	}
	in_sand = true;
	sink_t++;
	if (sink_t >= QUICKSAND_SINK_TIME) {
		//Under he goes: like a pit, but never down to the floor below
		sink_t = 0;
		fall_no_drop = true;
		player_fall_start();
	}


}

///player_quicksand_depth();
function player_quicksand_depth() {
	//Pixels of Link hidden in the sand (for his Draw event)
	if (!in_sand) return 0;
	return 2 + round((QUICKSAND_DRAW_SINK - 2) * sink_t / QUICKSAND_SINK_TIME);


}

//================================================================ crumbling floors

///crumble_step();
function crumble_step() {
	//Run by obj_crumble every step
	if (zone == noone) {zone = cam_zone_at(x + 8, y + 8)}
	switch (state) {
		case "whole":
			if (instance_exists(obj_link) && obj_link.z == 0 && obj_link.level == 0
				&& obj_link.state != "jump" && obj_link.state != "fall" && position_meeting(obj_link.x, obj_link.y, id)) {
				crumble_now(-1);
			}
			break;

		case "shake":
			timer--;
			if (timer <= 0) {
				//Gone: a hole in its place
				state = "gone";
				hole = instance_create_depth(x, y, DEPTH_DECOR, obj_pit);
				hole.image_xscale = 16 / sprite_get_width(hole.sprite_index);
				hole.image_yscale = 16 / sprite_get_height(hole.sprite_index);
				hole.visible = false;
				sfx_play(SFX_CRUMBLE);
			}
			break;

		case "gone":
			//Back once Link has left the room (or, after the boss's quake, after a while),
			//but never right under him
			var back = false;
			if (back_timer > 0) {
				back_timer--;
				back = (back_timer <= 0);
			} else {
				back = (global.cam_zone != zone);
			}
			if (back && !(instance_exists(obj_link) && position_meeting(obj_link.x, obj_link.y, id))) {
				if (instance_exists(hole)) {with (hole) {instance_destroy()}}
				hole = noone;
				state = "whole";
			} else if (back) {
				back_timer = 10;
			}
			break;
	}
	image_index = (state == "whole") ? 0 : ((state == "shake") ? 1 : 2);


}

///crumble_now(back_after);
function crumble_now(argument0) {
	//Run by obj_crumble: starts falling away. back_after: steps until it comes back by itself
	//(-1 = when Link leaves the room)
	if (state != "whole") return;
	state = "shake";
	timer = CRUMBLE_TIME;
	back_timer = (argument0 > 0) ? argument0 : 0;
	sfx_play(SFX_CRUMBLE_START);


}

///crumble_draw();
function crumble_draw() {
	//Run by obj_crumble's Draw: shaking just before it goes
	var dx = 0;
	if (state == "shake") {dx = ((timer div 2) mod 2 == 0) ? 1 : -1}
	draw_sprite(sprite_index, image_index, x + dx, y);


}
