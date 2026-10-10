//The Sword of Bun's pedestal in the hidden forest (obj_bun_pedestal, placed by make_overworld_room.py).
//
//Link walks up to it (facing it) with every piece of the Bun. The scene:
//	1 He raises his arms and the three pieces fly out of him, one at a time, into the sockets on its face.
//	2 The pedestal fills with light, a column of light comes down, the ground shakes.
//	3 A white flash, and he pulls the sword out and holds it up ("YOU GOT THE SWORD OF BUN!").
//The pieces stay in the pedestal afterwards (they still count as Link's: the HUD and the gate need them).
//Link is in state "scene" until he holds the sword up (then the usual item-get takes over).

#macro PEDESTAL_FLAG "sword_of_bun"	//the same flag the old pickup used, so files that already have the sword skip it
#macro PEDESTAL_SOCKET_Y 37			//the sockets' middles on the sprite (make_feel_art.py)
#macro PEDESTAL_START 24			//steps before the first piece flies
#macro PEDESTAL_PIECE_TIME 36		//steps between pieces
#macro PEDESTAL_FLY 24				//steps a piece takes to fly into its socket
#macro PEDESTAL_GLOW_TIME 60		//steps the light builds up
#macro PEDESTAL_FLASH_TIME 24		//steps the white flash fades
#macro SFX_BUN_SOCKET "snd_bun_socket"		//a piece of the Bun settling into the pedestal
#macro SFX_PEDESTAL_GLOW "snd_pedestal_glow"	//the pedestal filling with light
#macro SFX_PEDESTAL_FLASH "snd_pedestal_flash"	//the flash as the sword comes free

///pedestal_create();
function pedestal_create() {
	depth = DEPTH_DECOR;
	image_speed = 0;
	state = "wait";
	timer = 0;
	glow = 0;
	flash = 0;
	placed = array_create(BUN_PIECES, false);
	socket_flash = array_create(BUN_PIECES, 0);
	sockets_x = [16, 32, 48];
	//What Link gets (read by treasure_hold_up / obj_item_get, like an obj_treasure)
	item = ITEM.NONE;
	equip = "sword";
	tier = SWORD_TIER_BUN;
	contents = BOTTLE.EMPTY;
	amount = 1;
	message = "THE SWORD OF BUN! ITS LIGHT CAN BREAK ANY SEAL. WITH FULL HEALTH, ITS SWING SENDS OUT A BEAM.";
	if (flag_get(PEDESTAL_FLAG)) {pedestal_set_done()}


}

///pedestal_set_done();
function pedestal_set_done() {
	state = "done";
	image_index = 1;
	for (var i = 0; i < BUN_PIECES; i++) {placed[i] = true}


}

///pedestal_link_at();
function pedestal_link_at() {
	//Link is standing at the pedestal's front, facing it and walking into it
	if (!instance_exists(obj_link)) return false;
	var p = id;
	with (obj_link) {
		if (state != "idle" || dir != "up" || carrying || swimming) return false;
		return place_meeting(x, y - 2, p) && x > p.bbox_left + 4 && x < p.bbox_right - 4;
	}
	return false;


}

///pedestal_step();
function pedestal_step() {
	switch (state) {
		case "wait":
			if (bun_count() >= BUN_PIECES && pedestal_link_at()) {pedestal_scene_start()}
			break;
		case "scene":
			pedestal_scene_step();
			break;
		case "done":
			glow = max(0, glow - 0.02);
			break;
	}
	for (var i = 0; i < BUN_PIECES; i++) {
		if (socket_flash[i] > 0) {socket_flash[i]--}
	}


}

///pedestal_scene_start();
function pedestal_scene_start() {
	state = "scene";
	timer = 0;
	depth = DEPTH_FLYING - 10;	//the pieces and the light are drawn over Link
	var cx = x + sprite_width / 2;
	var by = bbox_bottom;
	with (obj_link) {
		state = "scene";
		shielding = false;
		x = round(cx);
		y = by + 10;
		dir = "up";
		sprite_index = player_get_sprite(dir);
		pose = -1;
		image_index = 0;
		image_speed = 0;
	}
	//The music goes quiet for the moment
	if (variable_global_exists("world_music") && audio_exists(global.world_music)) {audio_sound_gain(global.world_music, 0.25, 800)}


}

///pedestal_scene_step();
function pedestal_scene_step() {
	timer++;
	var all_in = PEDESTAL_START + PEDESTAL_PIECE_TIME * (BUN_PIECES - 1) + PEDESTAL_FLY;
	var glow_end = all_in + PEDESTAL_GLOW_TIME;

	//Arms up while the pieces leave him
	if (instance_exists(obj_link)) {
		var up = (timer >= PEDESTAL_START - 6 && timer < all_in);
		with (obj_link) {
			pose = up ? LINK_FRAME_RAISE : -1;
			image_index = up ? LINK_FRAME_RAISE : 0;	//(his Step doesn't run during the scene)
		}
	}

	//Each piece lands in its socket
	for (var i = 0; i < BUN_PIECES; i++) {
		if (timer == PEDESTAL_START + PEDESTAL_PIECE_TIME * i) {sfx_play(SFX_ITEM_GET)}
		if (timer == PEDESTAL_START + PEDESTAL_PIECE_TIME * i + PEDESTAL_FLY) {
			placed[i] = true;
			socket_flash[i] = 12;
			sfx_play(SFX_BUN_SOCKET);
			feel_shake(1, 6);
		}
	}

	//The light builds, the ground rumbles
	if (timer == all_in + 10) {sfx_play(SFX_PEDESTAL_GLOW)}
	if (timer > all_in + 10 && timer <= glow_end) {
		glow = min(1, (timer - all_in - 10) / (PEDESTAL_GLOW_TIME - 10));
		if (timer mod 10 == 0) {feel_shake(1 + floor(glow * 2), 8)}
	}

	//The flash: the sword comes free
	if (timer == glow_end) {
		flash = 1;
		sfx_play(SFX_PEDESTAL_FLASH);
		image_index = 1;
	}
	if (timer > glow_end) {flash = max(0, 1 - (timer - glow_end) / PEDESTAL_FLASH_TIME)}

	//He holds it up, the text box, done
	if (timer == glow_end + 8) {
		var p = id;
		with (obj_link) {
			state = "idle";
			treasure_hold_up(p);
		}
		flag_set(PEDESTAL_FLAG, true);
		if (variable_global_exists("world_music") && audio_exists(global.world_music)) {audio_sound_gain(global.world_music, 1, 1500)}
	}
	if (timer >= glow_end + PEDESTAL_FLASH_TIME) {
		state = "done";
		flash = 0;
		depth = DEPTH_DECOR;
	}


}

///pedestal_piece_pos(piece);
function pedestal_piece_pos(argument0) {
	//[x, y] of a flying piece (an arc from over Link's head to its socket), or undefined if it isn't flying
	var t0 = PEDESTAL_START + PEDESTAL_PIECE_TIME * argument0;
	if (state != "scene" || timer < t0 || placed[argument0] || !instance_exists(obj_link)) return undefined;
	var t = clamp((timer - t0) / PEDESTAL_FLY, 0, 1);
	var fx = obj_link.x;
	var fy = obj_link.y - 18;
	var tx = x + sockets_x[argument0];
	var ty = y + PEDESTAL_SOCKET_Y;
	var e = t * t * (3 - 2 * t);	//eases in and out
	return [lerp(fx, tx, e), lerp(fy, ty, e) - sin(t * pi) * 22];


}

///pedestal_draw();
function pedestal_draw() {
	draw_sprite(sprite_index, image_index, x, y);

	//The pieces in their sockets (a white flash as each one lands)
	for (var i = 0; i < BUN_PIECES; i++) {
		if (!placed[i]) continue;
		var sx = x + sockets_x[i] - 8;
		var sy = y + PEDESTAL_SOCKET_Y - 8;
		draw_sprite(spr_menu_bun, i + 1, sx, sy);
		if (socket_flash[i] > 0) {
			gpu_set_blendmode(bm_add);
			draw_sprite_ext(spr_menu_bun, i + 1, sx, sy, 1, 1, 0, c_white, socket_flash[i] / 12);
			gpu_set_blendmode(bm_normal);
		}
	}

	//A piece on its way
	for (var i = 0; i < BUN_PIECES; i++) {
		var pos = pedestal_piece_pos(i);
		if (is_undefined(pos)) continue;
		draw_sprite(spr_menu_bun, i + 1, round(pos[0]) - 8, round(pos[1]) - 8);
	}

	//The glow over the stone, and the column of light coming down onto the sword
	if (glow > 0) {
		var cx = x + sprite_width / 2;
		var cam = view_camera[0];
		var top = camera_get_view_y(cam) - 4;
		gpu_set_blendmode(bm_add);
		draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, make_colour_rgb(255, 230, 140), glow * 0.5);
		var w = 3 + round(glow * 8) + ((current_time div 60) mod 2);
		draw_set_alpha(glow * 0.55);
		draw_set_colour(make_colour_rgb(255, 240, 170));
		draw_rectangle(cx - w, top, cx + w - 1, y + 24, false);
		draw_set_alpha(glow * 0.35);
		draw_rectangle(cx - w - 4, top, cx + w + 3, y + 24, false);
		gpu_set_blendmode(bm_normal);
		draw_set_alpha(1);
	}

	//The white flash over the whole view (drawn here, not in Draw GUI, so the text box's frozen picture has it)
	if (flash > 0) {
		var cam = view_camera[0];
		var vx = camera_get_view_x(cam);
		var vy = camera_get_view_y(cam);
		draw_set_alpha(flash);
		draw_set_colour(c_white);
		draw_rectangle(vx - 4, vy - 4, vx + camera_get_view_width(cam) + 4, vy + camera_get_view_height(cam) + 4, false);
		draw_set_alpha(1);
	}
	draw_set_colour(c_white);


}
