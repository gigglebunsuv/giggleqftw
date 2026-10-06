/// @description Chain from Link to the hook, then the hook

if (instance_exists(obj_link)) {
	var ang = point_direction(obj_link.x, obj_link.y, x, y);
	var len = point_distance(obj_link.x, obj_link.y, x, y);
	for (var i = 6; i < len - 3; i += 6) {
		draw_sprite(spr_hookshot_chain, 0, obj_link.x + lengthdir_x(i, ang), obj_link.y + lengthdir_y(i, ang));
	}
}
draw_self();
