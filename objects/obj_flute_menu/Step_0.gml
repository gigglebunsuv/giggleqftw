/// @description Song, then pick a spot

if (!menu) {
	timer--;
	if (timer > 0) exit;

	with (obj_flute_spot) {
		array_push(other.spot_name, spot_name);
		array_push(other.spot_x, x);
		array_push(other.spot_y, y);
	}
	//No spots here: it was just the song
	if (array_length(spot_name) == 0) {
		with (obj_link) {state = "idle"}
		instance_destroy();
		exit;
	}

	snap = hud_snapshot();	//the view only, not the HUD bar
	instance_deactivate_all(true);
	menu_font = font_add_sprite_ext(spr_menu_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
	menu = true;
	exit;	//the button that started the flute still counts as pressed this step
}

input_get();
var n = array_length(spot_name);
var move = menu_move + menu_move_h;
if (move != 0) {
	cursor = (cursor + sign(move) + n) mod n;
	audio_play_sound(menu_switch, 2, false);
}

if (act_b || act_a || act_start) {
	instance_activate_all();
	with (obj_link) {state = "idle"}
	if (!act_b) {
		audio_play_sound(menu_select, 3, false);
		obj_link.x = spot_x[cursor];
		obj_link.y = spot_y[cursor];
		camera_snap();
	}
	global.pause_block = true;	//so Link ignores this button press
	instance_destroy();
}
