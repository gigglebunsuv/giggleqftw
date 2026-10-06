/// @description Flute: the song, then the warp menu
//Made by item_use_flute(). Link holds still while the song plays. Then, if the room has
//obj_flute_spot markers, the game freezes (like the pause screen) and a spot can be picked.

timer = FLUTE_SONG_TIME;
menu = false;
cursor = 0;
spot_name = [];
spot_x = [];
spot_y = [];
snap = -1;
menu_font = -1;
