/// @description Spin, fade, then CONTINUE, SAVE AND QUIT or QUIT

timer++;

if (phase == "spin") {
	if (instance_exists(obj_link)) {
		obj_link.sprite_index = spin_sprites[(timer div spin_every) mod 4];
		obj_link.image_index = 0;
	}
	if (timer >= spin_time) {
		phase = "fade";
		timer = 0;
	}
} else if (phase == "fade") {
	fade = min(1, timer / fade_time);
	if (fade >= 1) {
		phase = "menu";
		timer = 0;
	}
} else {
	input_get();
	if (menu_move != 0) {
		cursor = (cursor + menu_move + array_length(choices)) mod array_length(choices);
		audio_play_sound(menu_switch, 2, false);
	}
	if (act_a || act_start || pad_accept) {
		audio_play_sound(menu_select, 3, false);
		var pick = choices[cursor];
		if (pick == "CONTINUE") {
			//CONTINUE: restart this room from where Link came in, with a few hearts
			global.pHealth = min(continue_hearts * 2, global.pHealthMax);
			with (obj_link) {
				state = "idle";
				hurt_timer = 0;
				image_alpha = 1;
				x = entry_x;
				y = entry_y;
				sprite_index = player_get_sprite("down");
				dir = "down";
			}
			instance_activate_all();
			room_restart();
		} else {
			//SAVE AND QUIT: save to this game's file first (save_files script). Loading it gives
			//Link SAVE_LOAD_HEARTS hearts back.
			if (pick == "SAVE AND QUIT") {save_current_game()}
			//QUIT: start the whole game again
			instance_activate_all();
			game_restart();
		}
	}
}
