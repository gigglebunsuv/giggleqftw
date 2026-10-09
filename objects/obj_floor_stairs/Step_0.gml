/// @description Picture, then Link walking up into them takes them (not walking across them)

if (!ready) {
	ready = true;
	sprite_index = up ? spr_tower_stairs_up : spr_tower_stairs_down;
}
if (!instance_exists(obj_link) || instance_exists(obj_floor_fade) || global.cam_transition) exit;
//Not while a boss is awake nearby
with (obj_gargoyle) {
	if (state != "dormant" && point_distance(x, y, other.x, other.y) < 400) exit;
}
var s = id;
with (obj_link) {
	if (state == "idle" && dir == "up" && point_in_rectangle(x, y, s.bbox_left + 4, s.bbox_top, s.bbox_right - 4, s.bbox_bottom - 10)) {
		floor_stairs_take(s);
	}
}
