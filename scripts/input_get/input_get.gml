//Keyboard + XInput gamepad input.
//Keyboard: arrows move, Z = A button, X = B button, C = Y button, V = X button (the third item), S = run (boots), Enter = menu confirm / pause,
//          [ and ] = previous / next pause screen page, F1 = the debug menu.
//Gamepad:  d-pad or left stick move, A/B/Y/X buttons, right trigger = run, Start or A = menu confirm, Start = pause,
//          LB / RB = previous / next pause screen page, Select (Back / View) = the debug menu.
//The list shown on the Options screen (Controls, see options_menu) is input_bind_list(): update it when these change.

//Runs once at game start
global.input_pad = -1;			//XInput slot (0-3) in use, -1 = none connected
global.input_using_pad = false;	//true if the gamepad was used last (HUD shows pad glyphs)

#macro INPUT_STICK_DEADZONE 0.3
#macro INPUT_STICK_PRESS 0.5	//how far the stick must be pushed to count as a direction

///input_get();
function input_get() {
	//Sets on the calling instance:
	//move_up, move_down, move_left, move_right (held)
	//act_a, act_b, act_y, act_x, act_start (pressed), menu_page (-1 previous, 1 next page), hold_a, hold_b, hold_y, hold_x, hold_run (held), menu_move (-1 up, 1 down), menu_move_h (-1 left, 1 right),
	//pad_accept (gamepad confirm only), act_debug (pressed: the debug menu)
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
	act_y = keyboard_check_pressed(ord("C"));
	act_x = keyboard_check_pressed(ord("V"));
	hold_a = keyboard_check(ord("Z"));
	hold_b = keyboard_check(ord("X"));
	hold_y = keyboard_check(ord("C"));
	hold_x = keyboard_check(ord("V"));
	hold_run = keyboard_check(ord("S"));
	act_start = keyboard_check_pressed(vk_enter);
	act_debug = keyboard_check_pressed(vk_f1);
	menu_page = keyboard_check_pressed(221) - keyboard_check_pressed(219);	//] and [ (Windows key codes)
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
		act_y = act_y || gamepad_button_check_pressed(pad, gp_face4);
		act_x = act_x || gamepad_button_check_pressed(pad, gp_face3);
		hold_a = hold_a || gamepad_button_check(pad, gp_face1);
		hold_b = hold_b || gamepad_button_check(pad, gp_face2);
		hold_y = hold_y || gamepad_button_check(pad, gp_face4);
		hold_x = hold_x || gamepad_button_check(pad, gp_face3);
		hold_run = hold_run || gamepad_button_check(pad, gp_shoulderrb);
		menu_move += gamepad_button_check_pressed(pad, gp_padd) - gamepad_button_check_pressed(pad, gp_padu);
		menu_move = clamp(menu_move, -1, 1);
		menu_move_h += gamepad_button_check_pressed(pad, gp_padr) - gamepad_button_check_pressed(pad, gp_padl);
		menu_move_h = clamp(menu_move_h, -1, 1);
		act_start = act_start || gamepad_button_check_pressed(pad, gp_start);
		act_debug = act_debug || gamepad_button_check_pressed(pad, gp_select);
		menu_page += gamepad_button_check_pressed(pad, gp_shoulderr) - gamepad_button_check_pressed(pad, gp_shoulderl);
		menu_page = clamp(menu_page, -1, 1);
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

///input_bind_list();
function input_bind_list() {
	//What the Options screen's Controls list shows (title screen and pause Settings page). Each row is [type, ...]:
	//	[0, title]						section heading
	//	[1, action, keyboard, gamepad]	a control
	//	[2, key, what it does]			a key that does one thing (keyboard only; none at the moment)
	//	[3, text]						a note
	//Only capital letters, numbers and - : ! ? . ' / (the menu font). Keep it in step with
	//input_get() and the debug keys in obj_link's Step event.
	return [
		[0, "CONTROLS"],
		[1, "", "KEYBOARD", "PAD"],
		[1, "MOVE", "ARROWS", "DPAD"],
		[1, "SWORD", "X", "B"],
		[1, "ITEM ON A", "Z", "A"],
		[1, "ITEM ON Y", "C", "Y"],
		[1, "ITEM ON X", "V", "X"],
		[1, "RUN - BOOTS", "S", "RT"],
		[1, "PAUSE", "ENTER", "START"],
		[1, "MENU PAGE", "BRACKETS", "LB RB"],
		[1, "MENU BACK", "X", "B"],
		[3, "SHIELD: HOLD ITS BUTTON."],
		[3, "DASH: HOLD RUN AND STEER."],
		[3, "LET GO TO STOP."],
		[3, "TALK: FACE THEM AND PRESS A."],
		[3, "SIGNS AND CHESTS TOO."]
	];	//dungeon demo: no debug menu row


}
