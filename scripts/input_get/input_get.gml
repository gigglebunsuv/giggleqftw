///input_get(device);
function input_get(argument0) {
	dvc = argument0;

	move_up = keyboard_check(vk_up);
	move_down = keyboard_check(vk_down);
	move_left = keyboard_check(vk_left);
	move_right = keyboard_check(vk_right);
	act_attack=keyboard_check(vk_space);

	if(gamepad_is_connected(dvc)){
		move_up = gamepad_button_check(dvc,gp_padu)
		move_down = gamepad_button_check(dvc,gp_padd)
		move_left = gamepad_button_check(dvc,gp_padl)
		move_right = gamepad_button_check(dvc,gp_padr)
		act_attack = gamepad_button_check_pressed(dvc,gp_face1)
		menu_move = gamepad_button_check_pressed(dvc,gp_padd) - gamepad_button_check_pressed(dvc,gp_padu);
	}


}
