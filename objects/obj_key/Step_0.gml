/// @description Picked up earlier? Appear, get picked up

if (!checked) {
	checked = true;
	if (flag_get(door_flag())) {
		instance_destroy();
		exit;
	}
}
if (!shown) {
	var zone = cam_zone_at(x, y);
	if (appear != "clear" || zone == noone || zone_enemies_left(zone) == 0) {
		shown = true;
		if (appear != "") {sfx_play(SFX_KEY)}
	}
}
visible = shown;
if (shown && instance_exists(obj_link) && place_meeting(x, y, obj_link)) {
	flag_set(door_flag(), true);
	player_add_keys(1);
	sfx_play(SFX_ITEM_GET);
	instance_destroy();
}
