/// @description Pressed earlier? Link (or a push block) on it presses it

if (!checked) {
	checked = true;
	if (!hold) {pressed = flag_get(door_flag())}
}
//Only down while something's on it
if (hold) {
	var was = pressed;
	pressed = switch_weighed();
	if (pressed && !was) {sfx_play(SFX_SWITCH)}
	image_index = pressed;
	exit;
}
image_index = pressed;
if (pressed) exit;
//Swimming over it (a flooded basin) doesn't press it (see switch_weighed)
if (switch_weighed()) {
	pressed = true;
	flag_set(door_flag(), true);
	sfx_play(SFX_SWITCH);
}
