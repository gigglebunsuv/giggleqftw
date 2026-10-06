/// @description The item: out of the chest, then up over Link's head

if (icon_sprite == -1 || !sprite_exists(icon_sprite) || !instance_exists(obj_link)) exit;

//First half: straight up out of the chest. Second half: over to Link's raised hands.
var hx = obj_link.x;
var hy = obj_link.y - ITEMGET_HEIGHT;
var t = min(1, timer / ITEMGET_RISE);
var cx, cy;
if (t < 0.5) {
	cx = from_x;
	cy = from_y - 10 * (t / 0.5);
} else {
	var u = (t - 0.5) / 0.5;
	cx = lerp(from_x, hx, u);
	cy = lerp(from_y - 10, hy, u);
}
//Centred on that spot, whatever the sprite's size and origin
draw_sprite(icon_sprite, icon_frame, round(cx - sprite_get_width(icon_sprite) / 2 + sprite_get_xoffset(icon_sprite)),
	round(cy - sprite_get_height(icon_sprite) / 2 + sprite_get_yoffset(icon_sprite)));
