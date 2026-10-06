/// @description Pedestal, with the thing floating over it

draw_self();
var icon = treasure_icon();
if (icon[0] != -1) {
	var bob = round(sin(current_time / 250) * 1.5);
	var cx = bbox_left + (bbox_right + 1 - bbox_left) / 2;
	draw_sprite(icon[0], icon[1], cx - sprite_get_width(icon[0]) / 2 + sprite_get_xoffset(icon[0]),
		y - 10 + bob - sprite_get_height(icon[0]) / 2 + sprite_get_yoffset(icon[0]));
}
