//Zone camera (dungeons and the overworld): rooms are marked with obj_cam_zone rectangles (any size).
//Inside a zone the camera follows Link but never shows past the zone's edges.
//Walking into another zone slides the camera over, and the game waits until it arrives.
//Zones can sit inside bigger ones: the smallest zone Link is in wins. In the overworld
//one zone covers the whole map (the fields) and each area has its own zone on top.
//Rooms without any obj_cam_zone use the flip-screen camera instead.

///cam_zone_at(x, y);
function cam_zone_at(argument0, argument1) {
	//The smallest zone containing the point, or noone
	var found = noone;
	var found_size = infinity;
	with (obj_cam_zone) {
		if (point_in_rectangle(argument0, argument1, bbox_left, bbox_top, bbox_right, bbox_bottom)) {
			var size = (bbox_right - bbox_left) * (bbox_bottom - bbox_top);
			if (size < found_size) {
				found = id;
				found_size = size;
			}
		}
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

	cam_zone_avoid_inner(z, w, h);

	target_x = round(target_x);
	target_y = round(target_y);


}

///cam_zone_avoid_inner(zone, view_w, view_h);
function cam_zone_avoid_inner(argument0, argument1, argument2) {
	//Keeps zones that sit inside this one (overworld areas inside the fields) off screen,
	//so the camera stops at their edges. Each one pushes target_x/target_y off it the
	//shortest way, towards Link's side. In a gap narrower than the screen there's no room,
	//so on that axis the camera just follows Link.
	var z = argument0;
	var w = argument1;
	var h = argument2;
	var inner = [];
	with (obj_cam_zone) {
		if (id != z && bbox_left >= z.bbox_left && bbox_right <= z.bbox_right
			&& bbox_top >= z.bbox_top && bbox_bottom <= z.bbox_bottom) {array_push(inner, id)}
	}
	if (array_length(inner) == 0) return;

	var zl = z.bbox_left;
	var zt = z.bbox_top;
	var zw = z.bbox_right + 1 - zl;
	var zh = z.bbox_bottom + 1 - zt;
	var lx = obj_link.x;
	var ly = obj_link.y;
	var follow_x = target_x;
	var follow_y = target_y;
	var push_l = false;
	var push_r = false;
	var push_u = false;
	var push_d = false;

	repeat (3) {
		for (var i = 0; i < array_length(inner); i++) {
			var a = inner[i];
			var al = a.bbox_left;
			var ar = a.bbox_right + 1;
			var at = a.bbox_top;
			var ab = a.bbox_bottom + 1;
			if (target_x >= ar || target_x + w <= al || target_y >= ab || target_y + h <= at) continue;

			var best = infinity;
			var mx = 0;
			var my = 0;
			if (lx >= ar && ar - target_x < best) {best = ar - target_x; mx = ar - target_x; my = 0}
			if (lx < al && target_x + w - al < best) {best = target_x + w - al; mx = al - (target_x + w); my = 0}
			if (ly >= ab && ab - target_y < best) {best = ab - target_y; mx = 0; my = ab - target_y}
			if (ly < at && target_y + h - at < best) {best = target_y + h - at; mx = 0; my = at - (target_y + h)}
			target_x += mx;
			target_y += my;
			if (mx > 0) {push_r = true}
			if (mx < 0) {push_l = true}
			if (my > 0) {push_d = true}
			if (my < 0) {push_u = true}
		}
		if (zw > w) {target_x = clamp(target_x, zl, zl + zw - w)}
		if (zh > h) {target_y = clamp(target_y, zt, zt + zh - h)}
	}

	if (push_l && push_r) {target_x = follow_x}
	if (push_u && push_d) {target_y = follow_y}


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
		//Following: Link is slower than camspd, so this only smooths sudden jumps
		//(the camera switching sides around a corner of an area)
		x += clamp(target_x - x, -camspd, camspd);
		y += clamp(target_y - y, -camspd, camspd);
	}
	camera_set_view_pos(cam, x, y);


}
