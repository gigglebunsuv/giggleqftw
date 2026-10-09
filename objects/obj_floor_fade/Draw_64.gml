/// @description Black over the play area (not the HUD bar)

var a;
if (timer < FLOOR_FADE_TIME) {a = timer / FLOOR_FADE_TIME}
else {a = 1 - max(0, timer - FLOOR_FADE_TIME - 4) / FLOOR_FADE_TIME}
var p = hud_play_area();
draw_sprite_ext(spr_pixel, 0, p[0], p[1], p[2], p[3], 0, c_black, clamp(a, 0, 1));
