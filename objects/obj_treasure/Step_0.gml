/// @description Picked up when Link touches it

if (instance_exists(obj_link) && place_meeting(x, y, obj_link)) {
	treasure_collect();
	instance_destroy();
}
