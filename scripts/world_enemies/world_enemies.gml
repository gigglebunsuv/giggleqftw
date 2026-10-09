//Overworld enemies (children of obj_enemy, see the enemies script for what they share).
//	obj_slime		hops about, hops at Link when he's close (spr_slime_bog for the marsh's ones)
//	obj_wolf		prowls, spots Link, crouches, then lunges at him in a straight line
//	obj_scorpion	walks in straight lines, dashes at Link when he's lined up on its row or column
//	obj_spitter		a plant that never moves: turns to Link and spits seeds (obj_seed) at him
//	obj_crow		perches until Link comes close, then keeps swooping at him (flying)
//Each one's Step runs the shared enemy logic first, then its function here.
//Creation Code can put them on raised ground (level = 1; depth = DEPTH_UPPER;) and the slime
//can be given another look (sprite_index = spr_slime_bog;).

#macro SLIME_SIGHT 80			//hops at Link from this close
#macro SLIME_HOP_TIME 16		//steps in the air
#macro SLIME_HOP_SPEED 1.4
#macro SLIME_HOP_HEIGHT 6		//pixels at the top of the hop (only drawn)

#macro WOLF_SIGHT 104
#macro WOLF_CROUCH_TIME 15		//the warning before it lunges
#macro WOLF_LUNGE_TIME 40
#macro WOLF_LUNGE_SPEED 3
#macro WOLF_RECOVER_TIME 30

#macro SCORPION_RANGE 112		//how far down its row or column it notices Link
#macro SCORPION_LINE 8			//how close to its row or column Link has to be
#macro SCORPION_DASH_SPEED 3
#macro SCORPION_DASH_TIME 45		//longest dash, in steps
#macro SCORPION_REST_TIME 40	//steps it sits after a dash

#macro SPITTER_RANGE 128
#macro SPITTER_RELOAD 70		//steps between seeds
#macro SPITTER_MOUTH_TIME 10	//steps its mouth stays open after spitting

#macro CROW_WAKE 72				//Link this close wakes it up
#macro CROW_SWOOP_SPEED 2.6
#macro CROW_SWOOP_TIME 30
#macro CROW_FLUTTER_TIME 24		//circling about between swoops

///slime_step();
function slime_step() {
	//Run by obj_slime: squish on the spot, then hop (at Link if he's close and in sight)
	timer--;
	if (state == "sit") {
		anim_t += 0.08;
		z = 0;
		if (timer <= 0) {
			state = "hop";
			timer = SLIME_HOP_TIME;
			move_dir = random(360);
			if (enemy_can_see_link(SLIME_SIGHT)) {
				move_dir = point_direction(x, y, obj_link.x, obj_link.y) + random_range(-15, 15);
			}
		}
	} else {
		level_move(lengthdir_x(SLIME_HOP_SPEED, move_dir), lengthdir_y(SLIME_HOP_SPEED, move_dir), level);
		z = SLIME_HOP_HEIGHT * sin(pi * (1 - timer / SLIME_HOP_TIME));
		if (timer <= 0) {
			state = "sit";
			z = 0;
			timer = irandom_range(25, 60);
		}
	}
	image_index = (state == "hop") ? 2 : floor(anim_t) mod 2;


}

///wolf_step();
function wolf_step() {
	//Run by obj_wolf: prowl, spot Link, crouch, lunge, catch its breath
	walking = false;
	timer--;
	switch (state) {
		case "prowl":
			walking = true;
			if (level_move(lengthdir_x(spd, face), lengthdir_y(spd, face), level) || timer <= 0) {
				face = (face + choose(90, 270, 180)) mod 360;
				timer = irandom_range(40, 100);
			}
			if (enemy_can_see_link(WOLF_SIGHT)) {
				state = "crouch";
				timer = WOLF_CROUCH_TIME;
				face = enemy_dir4(point_direction(x, y, obj_link.x, obj_link.y));
			}
			break;

		case "crouch":
			if (timer <= 0 && instance_exists(obj_link)) {
				state = "lunge";
				timer = WOLF_LUNGE_TIME;
				lunge_dir = point_direction(x, y, obj_link.x, obj_link.y);
				face = enemy_dir4(lunge_dir);
			}
			break;

		case "lunge":
			walking = true;
			if (level_move(lengthdir_x(WOLF_LUNGE_SPEED, lunge_dir), lengthdir_y(WOLF_LUNGE_SPEED, lunge_dir), level) || timer <= 0) {
				state = "recover";
				timer = WOLF_RECOVER_TIME;
			}
			break;

		case "recover":
			if (timer <= 0) {
				state = "prowl";
				timer = irandom_range(40, 100);
			}
			break;
	}

	//Walking frames (faster in a lunge); crouching it holds still, nose down
	if (walking) {anim_t += (state == "lunge") ? 0.35 : 0.12}
	image_index = enemy_face_frame(face, floor(anim_t));


}

///scorpion_step();
function scorpion_step() {
	//Run by obj_scorpion: walk in straight lines, dash down its row or column at Link
	timer--;
	switch (state) {
		case "walk":
			anim_t += 0.15;
			if (level_move(lengthdir_x(spd, face), lengthdir_y(spd, face), level) || timer <= 0) {
				face = choose(0, 90, 180, 270);
				timer = irandom_range(30, 80);
			}
			var d = scorpion_lined_up();
			if (d != -1) {
				state = "dash";
				timer = SCORPION_DASH_TIME;
				face = d;
				sfx_play(SFX_BLADE);
			}
			break;

		case "dash":
			anim_t += 0.4;
			if (level_move(lengthdir_x(SCORPION_DASH_SPEED, face), lengthdir_y(SCORPION_DASH_SPEED, face), level) || timer <= 0) {
				state = "rest";
				timer = SCORPION_REST_TIME;
			}
			break;

		case "rest":
			if (timer <= 0) {
				state = "walk";
				timer = irandom_range(30, 80);
			}
			break;
	}
	image_index = enemy_face_frame(face, floor(anim_t));


}

///scorpion_lined_up();
function scorpion_lined_up() {
	//Run by obj_scorpion: the way to dash (0, 90, 180, 270) if Link is on its row or column,
	//in range and in sight, otherwise -1
	if (!enemy_can_see_link(SCORPION_RANGE)) return -1;
	var dx = obj_link.x - x;
	var dy = obj_link.y - y;
	if (abs(dy) <= SCORPION_LINE) {return (dx > 0) ? 0 : 180}
	if (abs(dx) <= SCORPION_LINE) {return (dy > 0) ? 270 : 90}
	return -1;


}

///spitter_step();
function spitter_step() {
	//Run by obj_spitter: rooted to the spot, spits a seed at Link every so often
	if (reload > 0) {reload--}
	if (mouth > 0) {mouth--}
	if (reload <= 0 && enemy_can_see_link(SPITTER_RANGE)) {
		var seed = instance_create_depth(x, y - 2, depth - 1, obj_seed);
		seed.direction = point_direction(x, y, obj_link.x, obj_link.y);
		seed.level = level;
		reload = SPITTER_RELOAD;
		mouth = SPITTER_MOUTH_TIME;
	}
	//It turns to face Link (its sprite only looks one way, so it flips)
	if (instance_exists(obj_link) && abs(obj_link.x - x) > 4) {image_xscale = sign(obj_link.x - x)}
	image_index = (mouth > 0) ? 1 : 0;


}

///crow_step();
function crow_step() {
	//Run by obj_crow: perched until Link comes close, then swoop at him, flutter, swoop again
	if (zone == noone) {zone = cam_zone_at(x, y)}
	timer--;
	switch (state) {
		case "perch":
			image_index = 0;
			if (instance_exists(obj_link) && point_distance(x, y, obj_link.x, obj_link.y) < CROW_WAKE) {crow_swoop()}
			break;

		case "swoop":
			image_index = 1 + (timer div 3) mod 2;
			x += lengthdir_x(CROW_SWOOP_SPEED, move_dir);
			y += lengthdir_y(CROW_SWOOP_SPEED, move_dir);
			if (timer <= 0) {
				state = "flutter";
				timer = CROW_FLUTTER_TIME;
				move_dir += choose(-120, 120);
			}
			break;

		case "flutter":
			image_index = 1 + (timer div 5) mod 2;
			move_dir += 6;
			x += lengthdir_x(1, move_dir);
			y += lengthdir_y(1, move_dir);
			if (timer <= 0) {crow_swoop()}
			break;
	}
	if (state != "perch" && instance_exists(obj_link)) {image_xscale = (obj_link.x < x) ? -1 : 1}

	//Turn back before leaving its zone
	if (state != "perch" && zone != noone && instance_exists(zone)) {
		if (x < zone.bbox_left + 16 || x > zone.bbox_right - 16 || y < zone.bbox_top + 16 || y > zone.bbox_bottom - 16) {
			move_dir = point_direction(x, y, (zone.bbox_left + zone.bbox_right) / 2, (zone.bbox_top + zone.bbox_bottom) / 2);
		}
	}


}

///crow_swoop();
function crow_swoop() {
	//Run by obj_crow: dive at where Link is now
	state = "swoop";
	timer = CROW_SWOOP_TIME;
	if (instance_exists(obj_link)) {move_dir = point_direction(x, y, obj_link.x, obj_link.y)}


}
