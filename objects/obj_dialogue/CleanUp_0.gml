/// @description Free the snapshot and font, let Link move again

if (snap != -1 && sprite_exists(snap)) {sprite_delete(snap)}
font_delete(menu_font);
font_delete(small_font);
//Also covers the box closing because of a room change
with (obj_link) {
	if (state == "talk") {state = "idle"}
}
