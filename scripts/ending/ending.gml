//The ending (rm_ending, obj_ending): after the Evil King is beaten (obj_king_defeat calls ending_start).
//	1 The story's end, a few lines at a time, fading in and out
//	2 The cast: everyone Sir Gigglebuns met, walking past with their names, then the Sapphire Order
//	  and the guardians of the towers
//	3 His file: name, play time, deaths, pieces of heart, then THE END
//The file is saved first with GAME_CLEAR_FLAG (the file select shows a star), Link back in front of his
//house, so the game can go on afterwards (the optional rooms, the heart pieces).
//A / Start / Enter hurries the story along; at THE END it goes back to the title.

#macro ENDING_FADE 30			//steps to fade a page in (and out)
#macro ENDING_PAGE 150			//steps a story page stays up
#macro ENDING_CAST_TIME 110		//steps each of the cast is on screen
#macro ENDING_MUSIC EndingTheme

///ending_start();
function ending_start() {
	//Run when the Evil King's defeat is over: save the file as cleared, then the ending
	flag_set(GAME_CLEAR_FLAG, true);
	if (hero_mode()) {flag_set(HERO_CLEAR_FLAG, true)}	//the red star (see the hero_mode script)
	global.dungeon = 0;
	global.pKeys = global.dungeonKeys[0];
	with (obj_link) {
		x = WORLD_START_X;
		y = WORLD_START_Y;
		state = "idle";
		pose = -1;
	}
	save_current_game();
	with (obj_link) {
		state = "scene";
		visible = false;
	}
	global.hud_hidden = true;
	room_goto(rm_ending);


}

///ending_create();
function ending_create() {
	audio_stop_all();
	options_volume_apply();
	audio_play_sound(ENDING_MUSIC, 1, true);
	global.hud_hidden = true;
	with (obj_link) {
		state = "scene";
		visible = false;
	}
	menu_font = font_add_sprite_ext(spr_menu_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
	small_font = font_add_sprite_ext(spr_font_small, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
	part = "story";
	page = 0;
	timer = 0;
	leaving = false;
	leave_timer = 0;
	story = [
		["THE EVIL KING HAD FALLEN.", "AND WITH HIM, THE SAPPHIRE ORDER", "SCATTERED LIKE MIST IN THE MORNING SUN."],
		["THE THREE PIECES OF THE BUN,", "JOINED ONCE MORE IN THE SWORD,", "FILLED BUNSRIEL WITH THEIR WARM LIGHT."],
		["THE PEOPLE OF HAVEN CAME HOME", "TO OLD CASTLE TOWN,", "AND THE BELLS RANG FOR THREE DAYS."],
		["AND SIR GIGGLEBUNS III,", "THE LAST LITTLE KNIGHT OF HAVEN,", "WENT HOME... AND TOOK A VERY LONG NAP."]
	];
	cast = ending_cast_list();


}

///ending_cast_list();
function ending_cast_list() {
	//[sprite, frame, other frame (they swap, a little walk), name]. Missing sprites are skipped.
	//(The villagers' sprites have a frame per way they face: 3 is facing down.)
	var list = [
		["spr_npc_elder", 3, 3, "THE ELDER"],
		["spr_npc_knight", 3, 3, "THE KNIGHT OF THE NORTH GATE"],
		["spr_npc_smith", 3, 3, "THE SMITH"],
		["spr_npc_armorer", 3, 3, "THE ARMORER"],
		["spr_npc_merchant", 3, 3, "THE MERCHANTS OF HAVEN"],
		["spr_npc_librarian", 3, 3, "THE LIBRARIAN"],
		["spr_npc_lamplighter", 3, 3, "THE LAMPLIGHTER"],
		["spr_npc_fortune", 3, 3, "THE FORTUNE TELLER"],
		["spr_npc_mason", 3, 3, "THE DESERT MASON"],
		["spr_npc_collector", 3, 3, "THE COLLECTOR"],
		["spr_npc_farmwife", 3, 3, "THE FARMER'S WIFE"],
		["spr_npc_kid", 3, 3, "THE CHILDREN OF HAVEN"],
		["spr_guard", 6, 7, "THE SAPPHIRE GUARD"],
		["spr_knight", 6, 7, "THE ROYAL KNIGHT"],
		["spr_wizard_adept", 0, 1, "THE SAPPHIRE ORDER"],
		["spr_gargoyle", 0, 1, "THE GARGOYLE OF THE SOUTHERN TOWER"],
		["spr_bog_boss", 0, 1, "THE BOG TOWER'S BEAST"],
		["spr_sphinx", 0, 0, "SAHRAN, THE MIRAGE SPHINX"],
		["spr_archmage", 0, 1, "VELRUNE, ARCHMAGE OF THE ORDER"],
		["spr_king_boss", 0, 1, "THE EVIL KING"],
		["spr_link_down", 0, 1, "AND SIR GIGGLEBUNS III"]
	];
	var out = [];
	for (var i = 0; i < array_length(list); i++) {
		var spr = asset_get_index(list[i][0]);
		if (spr != -1 && sprite_exists(spr)) {array_push(out, [spr, list[i][1], list[i][2], list[i][3]])}
	}
	return out;


}

///ending_step();
function ending_step() {
	timer++;
	input_get();
	var press = act_a || act_start || pad_accept;
	switch (part) {
		case "story":
			if (press && timer > ENDING_FADE) {timer = max(timer, ENDING_PAGE - ENDING_FADE)}
			if (timer >= ENDING_PAGE) {
				timer = 0;
				page++;
				if (page >= array_length(story)) {
					part = "cast";
					page = 0;
				}
			}
			break;
		case "cast":
			if (press && timer > 10) {timer = max(timer, ENDING_CAST_TIME - 10)}
			if (timer >= ENDING_CAST_TIME) {
				timer = 0;
				page++;
				if (page >= array_length(cast)) {
					part = "file";
					page = 0;
				}
			}
			break;
		case "file":
			if (!leaving && timer >= 90 && press) {
				leaving = true;
				audio_play_sound(menu_select, 3, false);
			}
			if (leaving) {
				leave_timer++;
				if (leave_timer >= ENDING_FADE) {game_restart()}
			}
			break;
	}


}

///ending_draw();
function ending_draw() {
	var gw = display_get_gui_width();
	var gh = display_get_gui_height();
	menu_draw_rect(0, 0, gw, gh, c_black);
	draw_set_valign(fa_top);
	draw_set_halign(fa_center);

	switch (part) {
		case "story":
			var a = min(1, timer / ENDING_FADE, (ENDING_PAGE - timer) / ENDING_FADE);
			var lines = story[page];
			draw_set_font(small_font);
			for (var i = 0; i < array_length(lines); i++) {
				menu_draw_text_colour(gw div 2, gh div 2 - 16 + i * 12, lines[i], merge_colour(c_black, c_white, a));
			}
			//The Bun, whole again, over the last pages
			if (page >= 1) {
				var bob = round(sin(current_time / 300) * 2);
				for (var b = 0; b < BUN_PIECES; b++) {
					draw_sprite_ext(spr_menu_bun, b + 1, gw div 2 - 28 + b * 20, gh div 2 - 64 + bob, 1, 1, 0, c_white, a);
				}
			}
			break;
		case "cast":
			var c = cast[page];
			var a2 = min(1, timer / 20, (ENDING_CAST_TIME - timer) / 20);
			var walk = ((timer div 12) mod 2 == 0) ? c[1] : c[2];
			walk = min(walk, sprite_get_number(c[0]) - 1);
			var sx = gw div 2 - sprite_get_width(c[0]) + sprite_get_xoffset(c[0]) * 2;
			var sy = gh div 2 - 24 - sprite_get_height(c[0]) + sprite_get_yoffset(c[0]) * 2;
			draw_sprite_ext(c[0], walk, sx, sy, 2, 2, 0, c_white, a2);
			draw_set_font(small_font);
			menu_draw_text_colour(gw div 2, gh div 2 + 24, c[3], merge_colour(c_black, c_white, a2));
			break;
		case "file":
			var a3 = min(1, timer / ENDING_FADE);
			draw_set_font(menu_font);
			menu_draw_text_colour(gw div 2, 40, "THE END", merge_colour(c_black, MENU_COL_CURSOR, a3));
			draw_set_font(small_font);
			var col = merge_colour(c_black, c_ltgray, a3);
			var secs = floor(global.playTime);
			var hrs = secs div 3600;
			var mins = (secs div 60) mod 60;
			var time_text = string(hrs) + ":" + ((mins < 10) ? "0" : "") + string(mins);
			menu_draw_text_colour(gw div 2, 70, global.player_name, col);
			menu_draw_text_colour(gw div 2, 84, "PLAY TIME " + time_text, col);
			menu_draw_text_colour(gw div 2, 96, "DEATHS " + string(global.deaths), col);
			menu_draw_text_colour(gw div 2, 108, "HEARTS " + string(global.pHealthMax div 2), col);
			menu_draw_text_colour(gw div 2, 134, "THANK YOU FOR PLAYING!", merge_colour(c_black, c_white, a3));
			menu_draw_text_colour(gw div 2, gh - 12, "UNKNOWN VENGEANCE STUDIOS", col);
			if (timer >= 90 && (timer div 30) mod 2 == 0) {
				menu_draw_text_colour(gw div 2, 160, global.input_using_pad ? "PRESS A" : "PRESS ENTER", c_white);
			}
			break;
	}
	draw_set_halign(fa_left);
	if (leaving) {draw_sprite_ext(spr_pixel, 0, 0, 0, gw, gh, 0, c_black, min(1, leave_timer / ENDING_FADE))}


}

///ending_cleanup();
function ending_cleanup() {
	font_delete(menu_font);
	font_delete(small_font);


}
