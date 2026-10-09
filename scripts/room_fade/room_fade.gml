//Fades between rooms: obj_warp (doors, caves, wells) fades to black, the blue warp out of a
//beaten dungeon (obj_warp_portal) spins Link and fades to white. obj_room_fade is persistent:
//it fades out, changes room once the screen is covered, then fades back in over the new room.
//Link and enemies wait while it's here.

#macro ROOM_FADE_TIME 14		//steps to fade to black (and back in) through a door or cave
#macro ROOM_FADE_HOLD 4			//steps the screen stays black in the new room
#macro WARP_FADE_TIME 40		//steps the blue warp spins Link and fades to white
#macro WARP_FADE_IN 30			//steps to fade back in from white
#macro WARP_FADE_HOLD 10
#macro WARP_SPIN_SPEED 3		//steps per quarter turn while he spins

///room_fade_start(room, x, y, warp);
function room_fade_start(argument0, argument1, argument2, argument3) {
	//Run by obj_warp when Link walks into it. warp = true for the blue warp out of a dungeon.
	if (instance_exists(obj_room_fade)) return noone;
	var f = instance_create_depth(0, 0, -900, obj_room_fade);
	f.target_room = argument0;
	f.target_x = argument1;
	f.target_y = argument2;
	f.warp = argument3;
	if (argument3) {
		f.out_time = WARP_FADE_TIME;
		f.hold_time = WARP_FADE_HOLD;
		f.in_time = WARP_FADE_IN;
		f.colour = c_white;
	}
	return f;


}

///room_fade_step();
function room_fade_step() {
	//Run by obj_room_fade: fade out (spinning Link for the warp), change room, fade in
	timer++;
	if (!arrived) {
		if (warp && instance_exists(obj_link)) {
			//Spin faster and faster as the screen goes white
			var turns = ["down", "left", "up", "right"];
			var spd = max(1, WARP_SPIN_SPEED - (timer * WARP_SPIN_SPEED) div out_time);
			spin += 1 / spd;
			with (obj_link) {
				dir = turns[floor(other.spin) mod 4];
				sprite_index = player_get_sprite(dir);
				image_index = 0;
			}
		}
		if (timer >= out_time) {
			arrived = true;
			timer = 0;
			room_goto(target_room);
			var tx = target_x;
			var ty = target_y;
			with (obj_link) {
				x = tx;
				y = ty;
				dir = "down";
				sprite_index = player_get_sprite(dir);
				image_index = 0;
			}
		}
		return;
	}
	if (timer >= hold_time + in_time) {instance_destroy()}


}

///room_fade_alpha();
function room_fade_alpha() {
	//How covered the screen is, 0 to 1
	if (!arrived) {return clamp(timer / out_time, 0, 1)}
	return clamp(1 - (timer - hold_time) / in_time, 0, 1);


}
