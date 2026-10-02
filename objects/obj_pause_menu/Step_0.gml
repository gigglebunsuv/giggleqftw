/// @description Move the cursor, equip, close

input_get();

if (!opened) {
	opened = true;
	exit;
}

//Close with Start/Enter or B
if (act_start || act_b) {
	instance_activate_all();
	global.pause_block = true;	//so Link ignores this button press
	instance_destroy();
	exit;
}

//Move around the grid (wraps at the edges)
if (menu_move_h != 0 || menu_move != 0) {
	var cx = ((cursor mod grid_cols) + menu_move_h + grid_cols) mod grid_cols;
	var cy = ((cursor div grid_cols) + menu_move + grid_rows) mod grid_rows;
	cursor = cy * grid_cols + cx;
	audio_play_sound(menu_switch, 2, false);
}

//Put the item under the cursor on A
if (act_a && cursor < ITEM.COUNT && global.item_have[cursor]) {
	global.itemA = cursor;
	audio_play_sound(menu_select, 3, false);
}
