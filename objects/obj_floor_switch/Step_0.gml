/// @description Pressed earlier? Link stepping on it presses it

if (!checked) {
	checked = true;
	pressed = flag_get(door_flag());
}
image_index = pressed;
if (pressed || !instance_exists(obj_link)) exit;
//Swimming over it (a flooded basin) doesn't press it
if (position_meeting(obj_link.x, obj_link.y, id) && obj_link.z == 0 && !obj_link.swimming) {
	pressed = true;
	flag_set(door_flag(), true);
	sfx_play(SFX_SWITCH);
}
