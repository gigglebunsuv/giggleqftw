

input_get();

//Gamepad A / Start runs the same code as Enter
if (pad_accept) {event_perform(ev_keypress, vk_enter)}

menu_index += menu_move;
if (menu_index < 0) menu_index = buttons - 1;
if (menu_index > buttons -1) menu_index = 0;

if (menu_index != last_selected) audio_play_sound(menu_switch,2,false);

last_selected = menu_index;
