/// @description Fly out, reel back in, or pull Link to the grapple point

if (global.cam_transition) exit;
if (!instance_exists(obj_link)) {
	instance_destroy();
	exit;
}

//Link got hurt while it was out: just reel it in
if (state == "out" && obj_link.state != "hook") {state = "back"}

if (state == "out") {
	//A pixel at a time, so it can't skip past anything
	repeat (spd_out) {
		x += lengthdir_x(1, direction);
		y += lengthdir_y(1, direction);
		dist++;

		//Grapple points are walls too, so check them first
		var point = instance_place(x, y, obj_grapple_point);
		if (point != noone) {
			target = point;
			state = "pull";
			obj_link.state = "pull";
			sfx_play(SFX_HOOK_HIT);
			break;
		}
		//Grabs a small key and brings it back to Link
		var key = instance_place(x, y, obj_key);
		if (key != noone && key.shown) {
			carry = key;
			state = "back";
			break;
		}
		var hit = instance_place(x, y, obj_enemy);
		if (hit != noone && (hit.level == -1 || hit.level == level)) {
			enemy_stun(hit, ITEM_STUN_TIME);
			state = "back";
			break;
		}
		if (level_wall_at(x, y, level)) {
			sfx_play(SFX_HOOK_HIT);
			state = "back";
			break;
		}
		if (dist >= max_dist) {
			state = "back";
			break;
		}
	}
} else if (state == "back") {
	var ang = point_direction(x, y, obj_link.x, obj_link.y);
	x += lengthdir_x(spd_back, ang);
	y += lengthdir_y(spd_back, ang);
	if (instance_exists(carry)) {
		carry.x = x;
		carry.y = y;
	}
	if (point_distance(x, y, obj_link.x, obj_link.y) <= spd_back) {
		if (obj_link.state == "hook") {obj_link.state = "idle"}
		instance_destroy();
		exit;
	}
} else if (state == "pull") {
	//Link flies to the hook over anything in the way and stops up against the grapple point
	var done = !instance_exists(target);
	var hx = x;
	var hy = y;
	if (!done) {
		with (obj_link) {
			var pull_ang = point_direction(x, y, hx, hy);
			repeat (other.spd_pull) {
				var nx = x + lengthdir_x(1, pull_ang);
				var ny = y + lengthdir_y(1, pull_ang);
				if (place_meeting(nx, ny, other.target) || point_distance(x, y, hx, hy) < 1) {
					done = true;
					break;
				}
				x = nx;
				y = ny;
			}
		}
	}
	if (done) {
		obj_link.x = round(obj_link.x);
		obj_link.y = round(obj_link.y);
		obj_link.state = "idle";
		instance_destroy();
		exit;
	}
}

//Behind Link while it points up, in front of him otherwise
depth = obj_link.depth - 1;
if (direction == 90) {depth = obj_link.depth + 1}
