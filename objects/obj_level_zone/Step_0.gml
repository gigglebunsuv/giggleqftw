/// @description Set Link's level

if (!instance_exists(obj_link)) exit;
if (point_in_rectangle(obj_link.x, obj_link.y, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
	if (obj_link.level != set_level) {
		with (obj_link) {level_set(other.set_level)}
	}
}
