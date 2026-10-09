/// @description Fade in, then a button goes back to the title

timer++;
input_get();
if (!leaving && timer >= THANKS_WAIT && (act_a || act_start || pad_accept)) {
	leaving = true;
	audio_play_sound(menu_select, 3, false);
}
if (leaving) {
	leave_timer++;
	if (leave_timer >= THANKS_FADE) {game_restart()}	//the title screen is the first room
}
