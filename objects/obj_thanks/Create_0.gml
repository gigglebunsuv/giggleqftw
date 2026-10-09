/// @description Thank-you screen at the end of the dungeon demo (rm_thanks)
//Reached once Link has the Southern Tower's piece of the Bun (obj_boss_arena). Fades in from
//black; after a moment A / Start / Enter goes back to the title (a fresh game).

//Link and the HUD aren't needed here (the HUD only draws while Link exists)
with (obj_link) {instance_destroy()}
audio_stop_all();
options_volume_apply();
audio_play_sound(Title, 1, true);

menu_font = font_add_sprite_ext(spr_menu_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
small_font = font_add_sprite_ext(spr_font_small, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
timer = 0;
leaving = false;
leave_timer = 0;
