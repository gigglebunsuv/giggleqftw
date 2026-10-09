//Tower guards (obj_guard): patrol, spot Link in front of them, then charge him with a short
//sword held at their side (their right hand), pointing the way they face.
//The sword hurts Link; his shield blocks it and knocks the guard back.
//States: "patrol", "alert" (the moment it spots him), "charge", "recover" (catching its breath).

#macro GUARD_SIGHT 128			//how far a guard sees
#macro GUARD_HEAR 40			//this close it notices Link even behind it
#macro GUARD_CONE 60			//degrees either side of the way it faces
#macro GUARD_ALERT_TIME 24
#macro GUARD_CHARGE_TIME 70
#macro GUARD_RECOVER_TIME 40
#macro GUARD_SWORD_FORWARD 3	//the sword's middle: this far ahead of the guard's middle...
#macro GUARD_SWORD_SIDE 7		//...and this far out to its right-hand side
#macro GUARD_BLADE 3			//the part that hurts: this far past the sword's middle, toward the tip
#macro GUARD_BLADE_SIZE 4		//half the size of the square that hurts (was 5, further out)
#macro GUARD_SWORD_DAMAGE 2

///guard_sees_link();
function guard_sees_link() {
	//Run by obj_guard: Link is in sight in front of it (or very close)
	if (!enemy_can_see_link(GUARD_SIGHT)) return false;
	var d = point_distance(x, y, obj_link.x, obj_link.y);
	if (d <= GUARD_HEAR) return true;
	return abs(angle_difference(face, point_direction(x, y, obj_link.x, obj_link.y))) <= GUARD_CONE;


}

///guard_sword_x(); guard_sword_y();
//Where the sword is drawn: a little ahead, out at the guard's right-hand side
function guard_sword_x() {return x + lengthdir_x(GUARD_SWORD_FORWARD, face) + lengthdir_x(GUARD_SWORD_SIDE, face - 90)}
function guard_sword_y() {return y + lengthdir_y(GUARD_SWORD_FORWARD, face) + lengthdir_y(GUARD_SWORD_SIDE, face - 90)}

///guard_sword_check();
function guard_sword_check() {
	//Run by obj_guard: the sword touching Link hurts him, unless his shield faces it.
	//Blocked: the guard is knocked back and has to recover.
	if (!instance_exists(obj_link) || !enemy_same_level(obj_link.level)) return;
	var sx = guard_sword_x() + lengthdir_x(GUARD_BLADE, face);
	var sy = guard_sword_y() + lengthdir_y(GUARD_BLADE, face);
	var b = GUARD_BLADE_SIZE;
	if (collision_rectangle(sx - b, sy - b, sx + b, sy + b, obj_link, false, true) == noone) return;

	if (shield_blocks(point_direction(obj_link.x, obj_link.y, sx, sy), 1)) {
		kb_timer = 8;
		kb_dir = point_direction(obj_link.x, obj_link.y, x, y);
		state = "recover";
		timer = GUARD_RECOVER_TIME;
		sfx_play(SFX_SHIELD);
	} else {
		player_hurt(GUARD_SWORD_DAMAGE, x, y);
	}


}

///guard_turn();
function guard_turn() {
	//Patrolling into a wall (or for long enough): turn left or right, sometimes around
	face = (face + choose(90, 270, 180) + 360) mod 360;
	move_timer = irandom_range(50, 110);


}

///guard_step();
function guard_step() {
	//Run by obj_guard's Step after the shared enemy logic
	walking = false;
	switch (state) {
		case "patrol":
			walking = true;
			if (level_move(lengthdir_x(spd, face), lengthdir_y(spd, face), level)) {guard_turn()}
			move_timer--;
			if (move_timer <= 0) {guard_turn()}
			if (guard_sees_link()) {
				state = "alert";
				timer = GUARD_ALERT_TIME;
				sfx_play(SFX_GUARD_ALERT);
				face = enemy_dir4(point_direction(x, y, obj_link.x, obj_link.y));
			}
			break;

		case "alert":
			timer--;
			if (timer <= 0 && instance_exists(obj_link)) {
				state = "charge";
				timer = GUARD_CHARGE_TIME;
				charge_dir = point_direction(x, y, obj_link.x, obj_link.y);
				face = enemy_dir4(charge_dir);
			}
			break;

		case "charge":
			walking = true;
			timer--;
			if (level_move(lengthdir_x(charge_spd, charge_dir), lengthdir_y(charge_spd, charge_dir), level) || timer <= 0) {
				state = "recover";
				timer = GUARD_RECOVER_TIME;
			}
			break;

		case "recover":
			timer--;
			if (timer <= 0) {
				if (guard_sees_link()) {
					state = "alert";
					timer = GUARD_ALERT_TIME div 2;
					face = enemy_dir4(point_direction(x, y, obj_link.x, obj_link.y));
				} else {
					state = "patrol";
					move_timer = irandom_range(50, 110);
				}
			}
			break;
	}

	guard_sword_check();


}

///guard_animate();
function guard_animate() {
	//Walking frames for the way it faces (faster while charging)
	if (walking) {anim_t += (state == "charge") ? 0.3 : 0.12}
	image_index = enemy_face_frame(face, floor(anim_t));


}
