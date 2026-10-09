/// @description Change Link's level as he climbs

if (!instance_exists(obj_link)) exit;
if (point_in_rectangle(obj_link.x, obj_link.y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
	var new_level = low_level;
	if (obj_link.y < (bbox_top + bbox_bottom) / 2) {new_level = low_level + 1}
	if (obj_link.level != new_level) {
		with (obj_link) {level_set(new_level)}
	}
}
