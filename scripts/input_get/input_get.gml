//Keyboard + XInput gamepad input.
//Keyboard: arrows move, Z = A button, X = B button, Enter = menu confirm / pause.
//Gamepad:  d-pad or left stick move, A/B buttons, Start or A = menu confirm, Start = pause.

//Runs once at game start
global.input_pad = -1;			//XInput slot (0-3) in use, -1 = none connected
global.input_using_pad = false;	//true if the gamepad was used last (HUD shows pad glyphs)

#macro INPUT_STICK_DEADZONE 0.3
#macro INPUT_STICK_PRESS 0.5	//how far the stick must be pushed to count as a direction

///input_get();
function input_get() {
	//Sets on the calling instance:
	//move_up, move_down, move_left, move_right (held)
	//act_a, act_b, act_start (pressed), menu_move (-1 up, 1 down), menu_move_h (-1 left, 1 right),
	//pad_accept (gamepad confirm only)
	var pad = input_find_pad();

	//Swap HUD glyphs to whichever device was touched last
	if (keyboard_check_pressed(vk_anykey)) {global.input_using_pad = false}
	if (pad != -1 && input_pad_any(pad)) {global.input_using_pad = true}

	move_up = keyboard_check(vk_up);
	move_down = keyboard_check(vk_down);
	move_left = keyboard_check(vk_left);
	move_right = keyboard_check(vk_right);
	act_a = keyboard_check_pressed(ord("Z"));
	act_b = keyboard_check_pressed(ord("X"));
	act_start = keyboard_check_pressed(vk_enter);
	menu_move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
	menu_move_h = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
	pad_accept = false;

	if (pad != -1) {
		var lh = gamepad_axis_value(pad, gp_axislh);
		var lv = gamepad_axis_value(pad, gp_axislv);

		move_up = move_up || gamepad_button_check(pad, gp_padu) || lv < -INPUT_STICK_PRESS;
		move_down = move_down || gamepad_button_check(pad, gp_padd) || lv > INPUT_STICK_PRESS;
		move_left = move_left || gamepad_button_check(pad, gp_padl) || lh < -INPUT_STICK_PRESS;
		move_right = move_right || gamepad_button_check(pad, gp_padr) || lh > INPUT_STICK_PRESS;
		act_a = act_a || gamepad_button_check_pressed(pad, gp_face1);
		act_b = act_b || gamepad_button_check_pressed(pad, gp_face2);
		menu_move += gamepad_button_check_pressed(pad, gp_padd) - gamepad_button_check_pressed(pad, gp_padu);
		menu_move = clamp(menu_move, -1, 1);
		menu_move_h += gamepad_button_check_pressed(pad, gp_padr) - gamepad_button_check_pressed(pad, gp_padl);
		menu_move_h = clamp(menu_move_h, -1, 1);
		act_start = act_start || gamepad_button_check_pressed(pad, gp_start);
		pad_accept = gamepad_button_check_pressed(pad, gp_face1) || gamepad_button_check_pressed(pad, gp_start);
	}


}

///input_find_pad();
function input_find_pad() {
	//Keeps using the same pad while it stays connected, otherwise picks the
	//first connected XInput slot (0-3). Returns -1 if there is none.
	var pad = global.input_pad;

	if (pad != -1 && !gamepad_is_connected(pad)) {
		pad = -1;
		global.input_using_pad = false;
	}

	if (pad == -1) {
		for (var i = 0; i < 4; i++) {
			if (gamepad_is_connected(i)) {
				pad = i;
				gamepad_set_axis_deadzone(pad, INPUT_STICK_DEADZONE);
				break;
			}
		}
	}

	global.input_pad = pad;
	return pad;


}

///input_pad_any(pad);
function input_pad_any(argument0) {
	//true if any button was pressed or the left stick was pushed this step
	var pad = argument0;
	var buttons = [gp_face1, gp_face2, gp_face3, gp_face4, gp_shoulderl, gp_shoulderr,
		gp_shoulderlb, gp_shoulderrb, gp_start, gp_select, gp_stickl, gp_stickr,
		gp_padu, gp_padd, gp_padl, gp_padr];

	for (var i = 0; i < array_length(buttons); i++) {
		if (gamepad_button_check_pressed(pad, buttons[i])) {return true}
	}

	return abs(gamepad_axis_value(pad, gp_axislh)) > INPUT_STICK_PRESS
		|| abs(gamepad_axis_value(pad, gp_axislv)) > INPUT_STICK_PRESS;


}
