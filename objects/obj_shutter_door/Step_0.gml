/// @description Open or shut (never shut on top of Link)

if (!ready) {
	ready = true;
	zones = door_zones();
	if (open_when != "clear" && flag_get(door_flag())) {open_when = ""}	//opened for good earlier
}

var want_open = shutter_should_open();
if (!want_open && is_open) {
	//Wait until Link is clear of the doorway
	if (instance_exists(obj_link) && collision_rectangle(bbox_left - 2, bbox_top - 2, bbox_right + 2, bbox_bottom + 2, obj_link, false, true) != noone) exit;
	is_open = false;
	block = instance_create_depth(bbox_left, bbox_top, depth, obj_wall);
	block.image_xscale = (bbox_right + 1 - bbox_left) / sprite_get_width(block.sprite_index);
	block.image_yscale = (bbox_bottom + 1 - bbox_top) / sprite_get_height(block.sprite_index);
	sfx_play(SFX_SHUTTER);
} else if (want_open && !is_open) {
	is_open = true;
	if (instance_exists(block)) {with (block) {instance_destroy()}}
	block = noone;
	sfx_play(SFX_SHUTTER);
	if (open_when == "torches" || open_when == "switch") {
		sfx_play(SFX_SECRET);
		flag_set(door_flag(), true);
		open_when = "";
	}
}
