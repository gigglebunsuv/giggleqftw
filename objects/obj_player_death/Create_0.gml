/// @description Link ran out of health: spin, fade to black, game over choices

//Freeze everything except Link (he spins) and the HUD (shows the empty hearts)
instance_deactivate_all(true);
instance_activate_object(obj_link);
instance_activate_object(obj_hud_main);

audio_stop_all();
sfx_play(SFX_PLAYER_DIE);
global.deaths++;	//shown on the file select

menu_font = font_add_sprite_ext(spr_menu_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);

phase = "spin";		//spin, then fade, then menu
timer = 0;
spin_time = 48;		//steps (the game runs at 30 steps a second)
spin_every = 3;		//steps per quarter turn
fade_time = 30;
fade = 0;			//black overlay, 0 to 1
spin_sprites = [player_get_sprite("down"), player_get_sprite("left"), player_get_sprite("up"), player_get_sprite("right")];

//CONTINUE, SAVE AND QUIT (only when this game has a save file, see save_files), QUIT
choices = ["CONTINUE", "SAVE AND QUIT", "QUIT"];
if (global.save_slot < 0) {choices = ["CONTINUE", "QUIT"]}
cursor = 0;
continue_hearts = 3;	//hearts after continuing (never more than the max)
