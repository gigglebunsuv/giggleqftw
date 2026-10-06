/// @description The frozen game, from the picture taken when the box opened

if (!frozen) exit;	//still the live game for the first frame
if (view_enabled) {
	var cam = view_camera[0];
	draw_sprite_stretched(snap, 0, camera_get_view_x(cam), camera_get_view_y(cam), camera_get_view_width(cam), camera_get_view_height(cam));
} else {
	draw_sprite_stretched(snap, 0, 0, 0, room_width, room_height);
}
