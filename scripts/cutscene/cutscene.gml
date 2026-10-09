//The opening (obj_cutscene): plays once, the first time a new file starts.
//	1 The dream: the screen is dark, the Evil King's shadow fades in and speaks.
//	2 Lightning, and Gigglebuns is asleep in his bed (rm_interiors, his house).
//	3 A knock. He gets up. The elder walks in and tells him about the attack in the night,
//	  the shield in his cellar and the knight at the north gate. The elder walks out.
//Start skips it (between boxes, or while a box is open: see obj_dialogue's Step).
//Where it happens comes from the interior_spots script (written by make_interiors_room.py).
//When it's over the story flag INTRO_FLAG is set and the game is saved.
//
//While obj_cutscene is here Link stands still (obj_link's Step), and the HUD bar hides during
//the dream (global.hud_hidden, see obj_hud_main's Draw GUI).

#macro INTRO_FLAG "intro_done"
#macro INTRO_FADE_TIME 50		//steps for the dream to fade in, and for the house to fade in after it
#macro INTRO_FLASH_TIME 12		//steps of lightning
#macro INTRO_SLEEP_TIME 60		//steps of snoring before the knock
#macro INTRO_WALK_SPEED 1		//pixels per step the elder walks

global.cutscene_on = false;		//true while the opening plays
global.cutscene_skip = false;	//Start was pressed during a text box
global.hud_hidden = false;
global.intro_pending = false;	//a new file was just started: play the opening when rm_interiors starts

///intro_start();
function intro_start() {
	//Run by obj_cutscene's Create
	phase = "dream";
	timer = 0;
	elder = noone;
	path = [];
	dream_alpha = 1;		//the dark over the house
	king_alpha = 0;
	flash = 0;
	global.cutscene_on = true;
	global.cutscene_skip = false;
	global.hud_hidden = true;
	audio_stop_all();
	options_volume_apply();
	with (obj_link) {
		x = HOME_GETUP_X;
		y = HOME_GETUP_Y;
		visible = false;
		state = "idle";
		dir = "down";
		sprite_index = player_get_sprite(dir);
	}


}

///intro_step();
function intro_step() {
	//Run by obj_cutscene every step
	if (instance_exists(obj_dialogue)) return;
	if (global.cutscene_skip) {
		intro_finish();
		return;
	}
	if (instance_exists(obj_link)) {
		with (obj_link) {
			input_get();
			if (act_start) {global.cutscene_skip = true}
		}
		if (global.cutscene_skip) {
			intro_finish();
			return;
		}
	}
	timer++;
	switch (phase) {
		case "dream":
			//The Evil King's shadow fades in out of the dark
			king_alpha = min(1, timer / INTRO_FADE_TIME);
			if (timer == 1) {sfx_play(SFX_THUNDER)}
			if (timer >= INTRO_FADE_TIME + 20) {
				dialogue_start(dlg_intro_dream);
				phase = "dream_talk";
				timer = 0;
			}
			break;
		case "dream_talk":
			//(the text box is over) lightning, and the dream is gone
			phase = "flash";
			timer = 0;
			flash = 1;
			sfx_play(SFX_THUNDER);
			break;
		case "flash":
			flash = max(0, 1 - timer / INTRO_FLASH_TIME);
			king_alpha = 0;
			if (timer >= INTRO_FLASH_TIME) {
				phase = "wake";
				timer = 0;
			}
			break;
		case "wake":
			//The house fades in: he's asleep in bed
			dream_alpha = max(0, 1 - timer / INTRO_FADE_TIME);
			if (timer >= INTRO_FADE_TIME) {
				global.hud_hidden = false;
				world_music_play(House);
				phase = "sleep";
				timer = 0;
			}
			break;
		case "sleep":
			if (timer == INTRO_SLEEP_TIME) {sfx_play(SFX_KNOCK)}
			if (timer >= INTRO_SLEEP_TIME + 20) {
				dialogue_start(dlg_intro_knock);
				phase = "getup";
				timer = 0;
			}
			break;
		case "getup":
			//Out of bed, and the elder comes in
			with (obj_link) {
				visible = true;
				dir = "right";
				sprite_index = player_get_sprite(dir);
				image_index = 0;
			}
			sfx_play(SFX_DOOR);
			elder = instance_create_layer(HOME_DOOR_X, HOME_DOOR_Y, "Instances", obj_npc);
			with (elder) {
				sprite_index = spr_npc_elder;
				dialogue = dlg_intro_elder;
				facing = 1;
				face_player = false;
				look_range = 0;
				depth = other.depth + 1;
			}
			path = [[HOME_DOOR_X, HOME_ELDER_TURN_Y], [HOME_ELDER_X, HOME_ELDER_TURN_Y], [HOME_ELDER_X, HOME_ELDER_Y]];
			phase = "elder_in";
			timer = 0;
			break;
		case "elder_in":
			if (intro_walk()) {
				with (elder) {facing = 2}
				dialogue_start(dlg_intro_elder);
				phase = "elder_out";
				timer = 0;
			}
			break;
		case "elder_out":
			if (timer == 1) {
				path = [[HOME_ELDER_X, HOME_ELDER_TURN_Y], [HOME_DOOR_X, HOME_ELDER_TURN_Y], [HOME_DOOR_X, HOME_DOOR_Y]];
			}
			if (intro_walk()) {
				sfx_play(SFX_DOOR);
				intro_finish();
			}
			break;
	}


}

///intro_walk();
function intro_walk() {
	//Moves the elder along path, one point at a time. True once he's at the end.
	if (!instance_exists(elder)) return true;
	if (array_length(path) == 0) return true;
	var p = path[0];
	var dx = p[0] - elder.x;
	var dy = p[1] - elder.y;
	if (dx == 0 && dy == 0) {
		array_delete(path, 0, 1);
		return array_length(path) == 0;
	}
	with (elder) {
		x += clamp(dx, -INTRO_WALK_SPEED, INTRO_WALK_SPEED);
		y += clamp(dy, -INTRO_WALK_SPEED, INTRO_WALK_SPEED);
		if (dx != 0) {facing = (dx > 0) ? 0 : 2}
		else {facing = (dy > 0) ? 3 : 1}
	}
	return false;


}

///intro_finish();
function intro_finish() {
	//The end of the opening (or Start skipped it): Link up and ready, the elder gone, the game saved
	if (instance_exists(elder)) {instance_destroy(elder)}
	with (obj_link) {
		x = HOME_GETUP_X;
		y = HOME_GETUP_Y;
		visible = true;
		state = "idle";
		dir = "down";
		sprite_index = player_get_sprite(dir);
		image_index = 0;
	}
	global.hud_hidden = false;
	global.cutscene_on = false;
	global.cutscene_skip = false;
	flag_set(INTRO_FLAG, true);
	world_music_play(House);
	save_current_game();
	global.pause_block = true;
	instance_destroy();


}

///intro_draw();
function intro_draw() {
	//Run by obj_cutscene's Draw (not Draw GUI: text boxes freeze the game from a picture of the view,
	//and that picture has to have the dream in it)
	var cam = view_camera[0];
	var vx = camera_get_view_x(cam);
	var vy = camera_get_view_y(cam);
	var vw = camera_get_view_width(cam);
	var vh = camera_get_view_height(cam);
	//Asleep in bed (until he gets up)
	if (phase == "dream" || phase == "dream_talk" || phase == "flash" || phase == "wake" || phase == "sleep") {
		draw_sprite(spr_link_sleep, (current_time div 700) mod 2, HOME_BED_X, HOME_BED_Y);
		if (phase == "sleep") {
			//Z's drifting up
			var t = (current_time div 40) mod 40;
			draw_set_alpha(1 - t / 40);
			draw_set_colour(c_white);
			draw_text_transformed(HOME_BED_X + 12 + t div 8, HOME_BED_Y - 4 - t div 2, "z", 0.5, 0.5, 0);
			draw_set_alpha(1);
		}
	}
	if (dream_alpha > 0) {
		draw_set_alpha(dream_alpha);
		draw_set_colour(c_black);
		draw_rectangle(vx - 1, vy - 1, vx + vw + 1, vy + vh + 1, false);
		draw_set_alpha(1);
	}
	if (king_alpha > 0) {
		var frame = ((current_time div 300) mod 2);
		draw_sprite_ext(spr_evil_king, frame, vx + vw / 2, vy + vh / 2 - 16, 1, 1, 0, c_white, king_alpha);
	}
	if (flash > 0) {
		draw_set_alpha(flash);
		draw_set_colour(c_white);
		draw_rectangle(vx - 1, vy - 1, vx + vw + 1, vy + vh + 1, false);
		draw_set_alpha(1);
	}
	draw_set_colour(c_white);


}

///intro_room_start();
function intro_room_start() {
	//Run at Room Start in rm_interiors (world_room_start): a new file plays the opening
	if (!global.intro_pending) return;
	global.intro_pending = false;
	if (flag_get(INTRO_FLAG)) return;
	if (!instance_exists(obj_cutscene)) {instance_create_depth(0, 0, -9000, obj_cutscene)}


}

//================================================================ what's said

///dlg_intro_dream();
function dlg_intro_dream() {
	return [
		"...SIR GIGGLEBUNS...",
		"THE LAST LITTLE KNIGHT OF HAVEN, SNORING IN HIS BED.",
		"WHILE YOU SLEPT, MY SAPPHIRE ORDER TOOK THE THREE TOWERS. THE PIECES OF THE BUN ARE MINE.",
		"SLEEP ON, LITTLE KNIGHT. SLEEP... WHILE BUNSRIEL FALLS."
	];


}

///dlg_intro_knock();
function dlg_intro_knock() {
	return [
		"KNOCK KNOCK KNOCK!",
		"SIR GIGGLEBUNS! WAKE UP! IT'S ME, THE ELDER!"
	];


}

///dlg_intro_elder();
function dlg_intro_elder() {
	return [
		"THANK THE BUN, YOU'RE ALL RIGHT!",
		"THE SAPPHIRE ORDER CAME IN THE NIGHT. THEY'VE TAKEN THE SOUTHERN TOWER, THE BOG TOWER AND THE TOWER OF LADHELLIN.",
		"THE THREE PIECES OF THE BUN WERE IN THOSE TOWERS. WITH THEM, THEIR EVIL KING GETS STRONGER EVERY DAY.",
		"YOU HAD THE DREAM TOO? THEN THERE'S NO TIME TO LOSE.",
		"YOU'RE THE LAST GIGGLEBUNS KNIGHT, SON. YOUR FATHER WOULD HAVE GONE. NOW IT'S YOUR TURN.",
		"HIS OLD SHIELD IS DOWN IN YOUR CELLAR. TAKE IT WITH YOU.",
		"THEN GO TO THE KNIGHT AT THE VILLAGE'S NORTH GATE. HE'LL SEE ABOUT A SWORD.",
		"I'LL BE IN THE SQUARE. BUN BLESS YOU, SIR GIGGLEBUNS!"
	];


}
