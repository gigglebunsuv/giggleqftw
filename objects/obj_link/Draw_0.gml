/// @description Link (just his top half while swimming), his shield while it's up, the rock he's carrying

//In the air (the cape): his shadow stays on the ground, he's drawn z pixels up
var dy = -round(z);
if (z > 0) {
	draw_sprite_ext(spr_pixel, 0, x - 4, y + 5, 8, 3, 0, c_black, 0.4);
	draw_sprite_ext(spr_pixel, 0, x - 5, y + 6, 10, 1, 0, c_black, 0.4);
}

//Picking up a rock while facing up: it's in front of him, so behind him on screen
var rock_behind = (carrying && state == "lift" && dir == "up");
if (rock_behind) {draw_sprite(spr_heavy_rock, 0, x - 8, y - 12)}

if (swimming) {
	draw_sprite_part_ext(sprite_index, image_index, 0, 0, sprite_width, 9, x - sprite_xoffset, y - sprite_yoffset, image_xscale, image_yscale, c_white, image_alpha);
	draw_sprite_ext(spr_pixel, 0, x - 7, y + 1, 14, 1, 0, c_white, 0.8);
} else {
	draw_sprite_ext(sprite_index, image_index, x, y + dy, image_xscale, image_yscale, 0, c_white, image_alpha);
}

//Frames: 0 right, 1 up, 2 left, 3 down
if (shielding) {
	draw_sprite_ext(shield_get_sprite(), player_face_angle(dir) div 90, x, y + dy, image_xscale, image_yscale, 0, c_white, image_alpha);
}

//Heavy rock (spr_heavy_rock's origin is its top left): low in his hands while he picks it up,
//then over his head
if (carrying && !rock_behind) {
	if (state == "lift") {
		var ang = player_face_angle(dir);
		draw_sprite(spr_heavy_rock, 0, x - 8 + lengthdir_x(7, ang), y - 6 + lengthdir_y(6, ang));
	} else {
		draw_sprite(spr_heavy_rock, 0, x - 8, y - 23 + dy);
	}
}
