//Link's moves: walking (speed, corner sliding, animation frames), running boots (dash),
//flippers (swimming), the cape (jumping over pits), and the strength gloves (lifting,
//carrying and throwing heavy rocks). All run by obj_link.

#macro WALK_SPEED 2.5		//pixels per step (was 2)
#macro WALK_FRAME_TIME 5	//steps per walking frame
#macro CORNER_SLIP 6		//pixels Link slides around a wall corner he walks into
#macro DASH_CHARGE 10		//steps running on the spot before the dash starts
#macro DASH_SPEED 4
#macro DASH_BONK_TIME 6		//steps bounced back after running into a wall
#macro SWIM_SPEED 0.75		//times normal speed
#macro LIFT_TIME 15			//steps of walking into a heavy rock to lift it
#macro LIFT_POSE_TIME 8		//steps Link crouches while picking it up
#macro THROW_POSE_TIME 8	//steps Link holds still after throwing it
#macro ROCK_DAMAGE 4		//a thrown rock (the hammer does 3)

//The cape: a jump over a one-tile pit. With WALK_SPEED 2.5 a jump carries Link 30 pixels,
//so a 16 pixel pit can be cleared from anywhere within about a tile of its edge.
#macro JUMP_TIME 12			//steps in the air
#macro JUMP_HEIGHT 10		//pixels at the top of the jump (only drawn, the shadow stays on the ground)
#macro JUMP_ASSIST 4		//landing this close to a pit's edge puts Link on the ground instead
#macro FALL_GRACE 2			//steps Link can stand over a pit's edge before he falls (still time to jump)
#macro FALL_TIME 20			//steps shrinking away into the pit
#macro FALL_DAMAGE 1		//half a heart, then back to the last safe spot

//Frames in Link's walking sprites (spr_link_down etc., 8 frames each)
#macro LINK_FRAME_WALK 0	//0-1 walking
#macro LINK_FRAME_SWORD 2	//arm out, swinging the sword
#macro LINK_FRAME_RAISE 3	//both arms up (hammer raised)
#macro LINK_FRAME_STRIKE 4	//both arms forward (hammer down, throwing)
#macro LINK_FRAME_LIFT 5	//crouched, picking up a rock
#macro LINK_FRAME_CARRY 6	//6-7 walking with a rock over his head

///player_can_use(item);
function player_can_use(argument0) {
	//Items can't be used while swimming or carrying a rock
	return argument0 != ITEM.NONE && !swimming && !carrying;


}

///player_move(hspd, vspd);
function player_move(argument0, argument1) {
	//Moves Link by whole pixels: the fractions are kept for the next step, so 2.5 a step
	//is 2, 3, 2, 3... and he's always drawn on the pixel grid. Slides him around wall corners
	//he only clips by a few pixels. Returns true if he bumped into something.
	move_frac_x += argument0;
	move_frac_y += argument1;
	if (argument0 == 0) {move_frac_x = 0}
	if (argument1 == 0) {move_frac_y = 0}
	var hs = sign(move_frac_x) * floor(abs(move_frac_x) + 0.0001);
	var vs = sign(move_frac_y) * floor(abs(move_frac_y) + 0.0001);
	move_frac_x -= hs;
	move_frac_y -= vs;

	player_corner_slip(hs, vs);
	return level_move(hs, vs, level);


}

///player_corner_slip(hspd, vspd);
function player_corner_slip(argument0, argument1) {
	//Walking straight into a wall's corner: if stepping up to CORNER_SLIP pixels to the side
	//clears it, Link slides that way (so doorways and gaps between blocks are easy to hit)
	var hs = argument0;
	var vs = argument1;
	var n = max(1, abs(hs) + abs(vs));
	if (hs != 0 && vs == 0 && level_wall_at(x + hs, y, level)) {
		for (var i = 1; i <= CORNER_SLIP; i++) {
			if (!level_wall_at(x + hs, y - i, level)) {level_move(0, -min(i, n), level); return}
			if (!level_wall_at(x + hs, y + i, level)) {level_move(0, min(i, n), level); return}
		}
	}
	if (vs != 0 && hs == 0 && level_wall_at(x, y + vs, level)) {
		for (var i = 1; i <= CORNER_SLIP; i++) {
			if (!level_wall_at(x - i, y + vs, level)) {level_move(-min(i, n), 0, level); return}
			if (!level_wall_at(x + i, y + vs, level)) {level_move(min(i, n), 0, level); return}
		}
	}


}

///player_face_input();
function player_face_input() {
	//Turns Link the way he's walking (xx, yy). On a diagonal he keeps facing one of the two
	//ways held, so he doesn't flicker between them.
	if (xx == 0 && yy == 0) return;
	var hd = (xx > 0) ? "right" : "left";
	var vd = (yy > 0) ? "down" : "up";
	if (yy == 0) {dir = hd}
	else if (xx == 0) {dir = vd}
	else if (dir != hd && dir != vd) {dir = hd}


}

///player_animate();
function player_animate() {
	//Run at the end of obj_link's Step: picks the frame. pose (one of the LINK_FRAME_ macros)
	//is set by the sword, hammer and rocks and cleared when Link goes back to "idle".
	//anim_rate: 0 standing, 1 walking, 2 running.
	image_speed = 0;
	if (pose >= 0) {
		image_index = pose;
		return;
	}
	var base = carrying ? LINK_FRAME_CARRY : LINK_FRAME_WALK;
	if (state == "jump") {
		image_index = base + 1;
		return;
	}
	if (anim_rate > 0) {
		anim_timer += anim_rate;
		image_index = base + (anim_timer div WALK_FRAME_TIME) mod 2;
	} else {
		anim_timer = WALK_FRAME_TIME - 1;	//the next step he takes changes the frame straight away
		image_index = base;
	}


}

///player_dash_step();
function player_dash_step() {
	//Running boots: hold the run button (S / right trigger). Link runs on the spot for a moment,
	//then dashes. Steer with the d-pad, let go to stop. Running into a wall bounces him back.
	//Enemies in the way get hit (sword damage, or stunned without a sword).
	if (state == "idle" && hold_run && global.hasBoots && !swimming && !carrying) {
		state = "charge";
		cnt = 0;
		sfx_play(SFX_DASH);
	}

	if (state == "charge") {
		if (!hold_run) {
			state = "idle";
			return;
		}
		sprite_index = player_get_sprite(dir);
		anim_rate = 2;
		cnt++;
		if (cnt >= DASH_CHARGE) {state = "dash"}
		return;
	}

	if (state != "dash") return;
	if (!hold_run || swimming) {
		state = "idle";
		return;
	}

	//Steer
	if (xx != 0 && yy == 0) {dir = (xx > 0) ? "right" : "left"}
	if (yy != 0 && xx == 0) {dir = (yy > 0) ? "down" : "up"}
	sprite_index = player_get_sprite(dir);
	anim_rate = 2;

	var ang = player_face_angle(dir);
	if (player_move(lengthdir_x(DASH_SPEED, ang), lengthdir_y(DASH_SPEED, ang))) {
		//Bonk: knocked back like getting hurt, but no damage
		state = "hurt";
		cnt = 0;
		dur = DASH_BONK_TIME;
		kb_dir = ang + 180;
		spr_prev = sprite_index;
		sfx_play(SFX_BONK);
		return;
	}

	var hit = instance_place(x + lengthdir_x(6, ang), y + lengthdir_y(6, ang), obj_enemy);
	if (hit != noone && (hit.level == -1 || hit.level == level)) {
		if (global.swordTier > 0) {enemy_hurt(hit, global.swordTier, x, y)}
		else {enemy_stun(hit, ITEM_STUN_TIME)}
	}


}

///player_swim_check();
function player_swim_check() {
	//Swimming when Link's middle is over deep water (obj_water, needs the flippers to get in).
	//Not while he's in the air. A rock he's carrying breaks when he goes in.
	if (state == "jump") return;
	var was = swimming;
	swimming = position_meeting(x, y, obj_water);
	if (swimming && !was) {
		sfx_play(SFX_SPLASH);
		if (carrying) {
			carrying = false;
			rock_break(x, y);
		}
	}


}

//================================================================ cape: jumping and pits

///player_jump_start();
function player_jump_start() {
	//The cape. Link hops, keeping the speed he had, and can steer in the air.
	//Returns false if he can't jump right now.
	if (state != "idle" || swimming || carrying) return false;
	state = "jump";
	jump_t = 0;
	z = 0;
	shielding = false;
	air_h = hspd;
	air_v = vspd;
	fall_grace = 0;
	sfx_play(SFX_JUMP);
	return true;


}

///player_jump_step();
function player_jump_step() {
	//In the air: steer with the d-pad. Let go and he keeps going the way he jumped,
	//so letting go of the d-pad halfway over a pit doesn't drop him in.
	if (state != "jump") return;
	jump_t++;
	if (xx != 0 || yy != 0) {
		air_h = hspd;
		air_v = vspd;
		player_face_input();
	}
	player_move(air_h, air_v);
	sprite_index = player_get_sprite(dir);

	var t = jump_t / JUMP_TIME;
	z = JUMP_HEIGHT * 4 * t * (1 - t);
	if (jump_t >= JUMP_TIME) {
		z = 0;
		state = "idle";
		player_land_assist();
	}


}

///player_land_assist();
function player_land_assist() {
	//Landed with his middle just over a pit's edge: put him on the ground next to it
	//(trying forward first), so the jump doesn't have to be exact
	if (!position_meeting(x, y, obj_pit)) return;
	var ang = 270;
	if (air_h != 0 || air_v != 0) {ang = point_direction(0, 0, air_h, air_v)}
	var tries = [ang, ang + 90, ang - 90, ang + 180];
	for (var d = 1; d <= JUMP_ASSIST; d++) {
		for (var i = 0; i < 4; i++) {
			var px = x + round(lengthdir_x(d, tries[i]));
			var py = y + round(lengthdir_y(d, tries[i]));
			if (!position_meeting(px, py, obj_pit) && !level_wall_at(px, py, level)) {
				x = px;
				y = py;
				return;
			}
		}
	}


}

///player_pit_check();
function player_pit_check() {
	//Link falls in when his middle has been over a pit (obj_pit) for more than FALL_GRACE steps.
	//On solid ground away from pits, remembers where he is to come back to after falling.
	if (state == "jump" || state == "fall" || state == "pull" || state == "dead") return;
	if (position_meeting(x, y, obj_pit)) {
		fall_grace++;
		if (fall_grace > FALL_GRACE) {player_fall_start()}
		return;
	}
	fall_grace = 0;
	if (state == "idle" && !swimming && collision_rectangle(x - 8, y - 8, x + 8, y + 8, obj_pit, false, true) == noone) {
		safe_x = x;
		safe_y = y;
	}


}

///player_fall_start();
function player_fall_start() {
	//A rock he's carrying goes down with him
	state = "fall";
	fall_t = 0;
	pose = -1;
	shielding = false;
	carrying = false;
	sfx_play(SFX_FALL);


}

///player_fall_step();
function player_fall_step() {
	//Shrinks away into the middle of the pit's tile, then comes back where he last stood safely
	if (state != "fall") return;
	fall_t++;
	x += ((x div 16) * 16 + 8 - x) * 0.25;
	y += ((y div 16) * 16 + 8 - y) * 0.25;
	var s = max(0, 1 - fall_t / FALL_TIME);
	image_xscale = s;
	image_yscale = s;
	if (fall_t >= FALL_TIME) {
		image_xscale = 1;
		image_yscale = 1;
		x = safe_x;
		y = safe_y;
		move_frac_x = 0;
		move_frac_y = 0;
		fall_grace = 0;
		state = "idle";
		player_add_health(-FALL_DAMAGE);
		if (global.pHealth > 0) {sfx_play(SFX_PLAYER_HURT)}
		hurt_timer = 60;
	}


}

//================================================================ strength gloves: heavy rocks

///player_lift_rocks();
function player_lift_rocks() {
	//Strength gloves: keep walking into a heavy rock (the way Link faces) to pick it up.
	//He holds it over his head (carrying) until he throws it, see player_throw_rock.
	var pushing = false;
	if (global.hasGloves && state == "idle" && !swimming && !carrying) {
		var ang = player_face_angle(dir);
		var rock = instance_place(x + lengthdir_x(2, ang), y + lengthdir_y(2, ang), obj_heavy_rock);
		if (rock != noone && xx == round(lengthdir_x(1, ang)) && yy == round(lengthdir_y(1, ang))) {
			pushing = true;
			lift_timer++;
			if (lift_timer >= LIFT_TIME) {
				with (rock) {instance_destroy()}
				carrying = true;
				state = "lift";
				cnt = 0;
				dur = LIFT_POSE_TIME;
				spr_prev = sprite_index;
				pose = LINK_FRAME_LIFT;
				sfx_play(SFX_LIFT);
				pushing = false;
			}
		}
	}
	if (!pushing) {lift_timer = 0}


}

///player_throw_rock();
function player_throw_rock() {
	//Throws the rock Link is carrying the way he faces (obj_thrown_rock)
	carrying = false;
	var rock = instance_create_depth(x, y, depth - 1, obj_thrown_rock);
	rock.direction = player_face_angle(dir);
	rock.level = level;
	item_pause(THROW_POSE_TIME);
	pose = LINK_FRAME_STRIKE;
	sfx_play(SFX_THROW);


}

///rock_break(x, y);
function rock_break(argument0, argument1) {
	//A heavy rock smashing (thrown, dropped): the puff and the sound
	instance_create_depth(argument0 - 12, argument1 - 12, depth - 1, obj_enemy_death);
	sfx_play(SFX_ROCK);


}
