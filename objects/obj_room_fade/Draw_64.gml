/// @description Cover the play area (not the HUD bar)

var p = hud_play_area();
draw_sprite_ext(spr_pixel, 0, p[0], p[1], p[2], p[3], 0, colour, room_fade_alpha());
