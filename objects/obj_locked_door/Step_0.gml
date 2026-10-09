/// @description Opened before? Link walking into it with a key opens it

if (!checked) {
	checked = true;
	if (flag_get(door_flag())) {
		instance_destroy();
		exit;
	}
}

if (door_link_pushing() && door_can_open()) {
	door_use_key();
	door_open();
}
