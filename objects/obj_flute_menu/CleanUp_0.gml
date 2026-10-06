/// @description Free the snapshot and font

if (snap != -1 && sprite_exists(snap)) {sprite_delete(snap)}
if (menu_font != -1) {font_delete(menu_font)}
