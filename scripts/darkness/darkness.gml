//Dark rooms. A camera zone (obj_cam_zone) with dark = true in its Creation Code is drawn
//nearly black, except for light around Link (a bigger circle once he has the lantern) and
//around lit torches. Lighting every torch in a dark room lights the whole room.
//The room needs one obj_darkness (it draws all of this, over everything but the HUD).

#macro DARK_ALPHA 0.94			//how black a dark room is
#macro LIGHT_LANTERN 40			//light around Link with the lantern (pixels)
#macro LIGHT_NONE 12			//without it: just enough to see himself
#macro LIGHT_TORCH 34			//around a lit torch
#macro LIGHT_EDGE 10			//the half-lit ring outside each light

///darkness_zone_is_dark(zone);
function darkness_zone_is_dark(argument0) {
	//A dark zone that hasn't been lit up by its torches
	var z = argument0;
	if (!z.dark) return false;
	return !zone_torches_lit(z);


}

///darkness_light(x, y, radius);
function darkness_light(argument0, argument1, argument2) {
	//Run by obj_darkness with the subtract blend mode set: cuts a light out of the dark,
	//a solid circle and a half-lit ring around it (surface coordinates)
	draw_set_alpha(0.5);
	draw_circle(argument0, argument1, argument2 + LIGHT_EDGE, false);
	draw_set_alpha(1);
	draw_circle(argument0, argument1, argument2, false);


}

///darkness_draw();
function darkness_draw() {
	//Run by obj_darkness's Draw: the dark zones on screen, with the lights cut out
	var cam = view_camera[0];
	var vx = camera_get_view_x(cam);
	var vy = camera_get_view_y(cam);
	var vw = camera_get_view_width(cam);
	var vh = camera_get_view_height(cam);

	//Any dark zone on screen?
	var dark_zones = [];
	with (obj_cam_zone) {
		if (bbox_right >= vx && bbox_left < vx + vw && bbox_bottom >= vy && bbox_top < vy + vh) {
			if (darkness_zone_is_dark(id)) {array_push(dark_zones, id)}
		}
	}
	if (array_length(dark_zones) == 0) return;

	if (!surface_exists(surf)) {surf = surface_create(vw, vh)}
	surface_set_target(surf);
	draw_clear_alpha(c_black, 0);
	draw_set_colour(c_black);
	for (var i = 0; i < array_length(dark_zones); i++) {
		var z = dark_zones[i];
		draw_rectangle(z.bbox_left - vx, z.bbox_top - vy, z.bbox_right - vx, z.bbox_bottom - vy, false);
	}

	//Lights: Link, lit torches
	gpu_set_blendmode(bm_subtract);
	draw_set_colour(c_white);
	draw_set_circle_precision(48);
	if (instance_exists(obj_link)) {
		var r = LIGHT_NONE;
		if (global.item_have[ITEM.LANTERN]) {r = LIGHT_LANTERN}
		darkness_light(obj_link.x - vx, obj_link.y - vy - round(obj_link.z), r);
	}
	with (obj_torch) {
		if (lit) {darkness_light(x + 8 - vx, y + 8 - vy, LIGHT_TORCH)}
	}
	draw_set_circle_precision(24);
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
	draw_set_colour(c_white);
	surface_reset_target();

	draw_surface_ext(surf, vx, vy, 1, 1, 0, c_white, DARK_ALPHA);


}
