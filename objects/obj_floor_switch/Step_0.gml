/// @description Pressed earlier? Link stepping on it presses it

if (!checked) {
	checked = true;
	pressed = flag_get(door_flag());
}
image_index = pressed;
if (pressed || !instance_exists(obj_link)) exit;
if (position_meeting(obj_link.x, obj_link.y, id) && obj_link.z == 0) {
	pressed = true;
	flag_set(door_flag(), true);
	sfx_play(SFX_SWITCH);
}
