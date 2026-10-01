

switch(menu_index) {

	case 0:
	audio_play_sound(menu_select,3,0);
		room_goto(YourHouse);
		break;
		
		case 2:
	audio_play_sound(menu_select,3,0);
		game_end();
		break;
		
}