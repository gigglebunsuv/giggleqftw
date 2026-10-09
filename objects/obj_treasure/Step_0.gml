/// @description Picked up when Link touches it

if (flag != "" && flag_get(flag)) {
	instance_destroy();
	exit;
}
if (instance_exists(obj_link) && place_meeting(x, y, obj_link)) {
	if (hold_up) {
		if (obj_link.state != "idle") exit;
		with (obj_link) {treasure_hold_up(other.id)}
	} else {
		treasure_collect();
	}
	if (flag != "") {flag_set(flag, true)}
	instance_destroy();
}
