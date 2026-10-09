//Things in dungeon rooms: pots (obj_pot) that break and drop things, floor spikes (obj_spikes),
//blade traps (obj_blade_trap) and rats (obj_rat, an enemy).

#macro SPIKE_DAMAGE 2			//half hearts (before armor)
#macro BLADE_DAMAGE 2
#macro BLADE_RANGE 176			//how far down a row or column a blade trap notices Link
#macro BLADE_SPEED 3.5			//sliding out
#macro BLADE_RETURN 1			//sliding back home

///pot_break();
function pot_break() {
	//Run by obj_pot when the sword hits it: it smashes, maybe leaving something behind
	//(drop = a PICKUP, -1 = random, -2 = nothing, -3 = a few arrows once Link has the bow)
	var cx = x + 8;
	var cy = y + 8;
	rock_break(cx, cy);
	sfx_play(SFX_POT);
	var d = drop;
	if (d == -1) {
		var roll = irandom(9);
		if (roll <= 2) {d = PICKUP.HEART}
		else if (roll == 3) {d = PICKUP.MAGIC}
		else if (roll <= 5) {d = PICKUP.MONEY1}
		else if (roll == 6) {d = PICKUP.MONEY5}
		else if (roll == 7 && global.item_have[ITEM.BOW]) {d = -3}	//so arrows never run out for good
		else {d = -2}
	}
	if (d == -3 && !global.item_have[ITEM.BOW]) {d = -2}
	if (d == -3) {instance_create_depth(cx, cy, DEPTH_DECOR, obj_arrow_bundle)}
	if (d >= 0) {pickup_create(d, cx, cy)}
	instance_destroy();


}

///spikes_step();
function spikes_step() {
	//Run by obj_spikes: Link standing on them (not in the air) gets hurt and pushed back
	//the way he came
	if (!instance_exists(obj_link)) return;
	var s = id;
	with (obj_link) {
		if (z > 0 || state == "jump" || state == "pull" || state == "fall" || state == "land") return;
		if (!position_meeting(x, y + 4, s)) return;
		var ang = player_face_angle(dir);
		player_hurt(SPIKE_DAMAGE, x + lengthdir_x(8, ang), y + lengthdir_y(8, ang));
	}


}

///blade_trap_step();
function blade_trap_step() {
	//Run by obj_blade_trap: waits until Link is lined up with it (same row or column, nothing in
	//the way), slides at him until it hits a wall or another trap, then slides slowly back.
	//It can't be hurt and doesn't count as an enemy (shutter doors don't wait for it).
	if (!enemy_is_active() || !instance_exists(obj_link)) return;

	switch (state) {
		case "wait":
			var lx = obj_link.x;
			var ly = obj_link.y;
			if (obj_link.level != level) break;
			var d = -1;
			if (abs(ly - y) < 8 && abs(lx - x) <= BLADE_RANGE) {d = (lx > x) ? 0 : 180}
			else if (abs(lx - x) < 8 && abs(ly - y) <= BLADE_RANGE) {d = (ly > y) ? 270 : 90}
			if (d != -1 && level_line_clear(x, y, lx, ly, level)) {
				move_dir = d;
				state = "out";
				sfx_play(SFX_BLADE);
			}
			break;

		case "out":
			var nx = x + lengthdir_x(BLADE_SPEED, move_dir);
			var ny = y + lengthdir_y(BLADE_SPEED, move_dir);
			if (place_meeting(nx, ny, obj_wall) || place_meeting(nx, ny, obj_blade_trap)
				|| point_distance(home_x, home_y, nx, ny) > BLADE_RANGE) {
				state = "back";
				sfx_play(SFX_HOOK_HIT);
			} else {
				x = nx;
				y = ny;
			}
			break;

		case "back":
			var dist = point_distance(x, y, home_x, home_y);
			if (dist <= BLADE_RETURN) {
				x = home_x;
				y = home_y;
				state = "wait";
			} else {
				var ang = point_direction(x, y, home_x, home_y);
				x += lengthdir_x(BLADE_RETURN, ang);
				y += lengthdir_y(BLADE_RETURN, ang);
			}
			break;
	}

	if (place_meeting(x, y, obj_link) && obj_link.level == level && obj_link.z == 0) {
		player_hurt(BLADE_DAMAGE, x, y);
	}
	image_index = (state == "wait") ? 0 : (current_time div 60) mod 2;


}

///rat_step();
function rat_step() {
	//Run by obj_rat after the shared enemy logic: short fast dashes, pausing in between,
	//toward Link when he's close
	timer--;
	if (state == "pause") {
		if (timer <= 0) {
			state = "run";
			timer = irandom_range(20, 40);
			move_dir = choose(0, 90, 180, 270);
			if (instance_exists(obj_link) && point_distance(x, y, obj_link.x, obj_link.y) < 72 && enemy_can_see_link(72)) {
				move_dir = enemy_dir4(point_direction(x, y, obj_link.x, obj_link.y));
			}
		}
	} else {
		anim_t += 0.3;
		if (level_move(lengthdir_x(spd, move_dir), lengthdir_y(spd, move_dir), level) || timer <= 0) {
			state = "pause";
			timer = irandom_range(15, 45);
		}
	}
	image_index = enemy_face_frame(move_dir, floor(anim_t));


}
