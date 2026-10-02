//Dungeon camera: rooms are marked with obj_cam_zone rectangles (any size).
//Inside a zone the camera follows Link but never shows past the zone's edges.
//Walking into another zone slides the camera over, and the game waits until it arrives.
//Rooms without any obj_cam_zone use the flip-screen camera instead.

///cam_zone_at(x, y);
function cam_zone_at(argument0, argument1) {
	//The zone containing the point, or noone
	var found = noone;
	with (obj_cam_zone) {
		if (point_in_rectangle(argument0, argument1, bbox_left, bbox_top, bbox_right, bbox_bottom)) {found = id}
	}
	return found;


}

///cam_zone_target(camera, zone);
function cam_zone_target(argument0, argument1) {
	//Sets target_x/target_y: centred on Link, kept inside the zone.
	//A zone smaller than the view is centred instead.
	var cam = argument0;
	var z = argument1;
	var w = camera_get_view_width(cam);
	var h = camera_get_view_height(cam);
	var zx = z.bbox_left;
	var zy = z.bbox_top;
	var zw = z.bbox_right + 1 - zx;
	var zh = z.bbox_bottom + 1 - zy;

	if (zw <= w) {target_x = zx + (zw - w) / 2}
	else {target_x = clamp(obj_link.x - w / 2, zx, zx + zw - w)}
	if (zh <= h) {target_y = zy + (zh - h) / 2}
	else {target_y = clamp(obj_link.y - h / 2, zy, zy + zh - h)}

	target_x = round(target_x);
	target_y = round(target_y);


}

///cam_zone_snap(camera);
function cam_zone_snap(argument0) {
	//Run by obj_camera at room start: jump straight to Link's zone
	global.cam_zone = cam_zone_at(obj_link.x, obj_link.y);
	global.cam_transition = false;
	if (global.cam_zone == noone) return;

	cam_zone_target(argument0, global.cam_zone);
	x = target_x;
	y = target_y;
	camera_set_view_pos(argument0, x, y);


}

///cam_zone_step(camera);
function cam_zone_step(argument0) {
	//Run by obj_camera every End Step
	var cam = argument0;
	var z = cam_zone_at(obj_link.x, obj_link.y);
	if (z != noone && z != global.cam_zone) {
		global.cam_zone = z;
		global.cam_transition = true;
	}
	if (global.cam_zone == noone) return;

	cam_zone_target(cam, global.cam_zone);
	if (global.cam_transition) {
		x += clamp(target_x - x, -camspd, camspd);
		y += clamp(target_y - y, -camspd, camspd);
		if (x == target_x && y == target_y) {global.cam_transition = false}
	} else {
		x = target_x;
		y = target_y;
	}
	camera_set_view_pos(cam, x, y);


}
