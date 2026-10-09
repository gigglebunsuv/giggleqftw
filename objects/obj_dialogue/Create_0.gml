/// @description Text box (see the dialogue_system script)
//Made by dialogue_start(). Freezes the game like the pause screen, but Link and the HUD stay
//awake so the HUD still shows. Everything else is drawn from a picture of the game.
//The freeze waits until one frame has been drawn (see the Step event), so the picture
//shows the NPC already turned to look at Link.

snap = -1;
drawn = false;	//a frame has been drawn since the box opened (set in Draw GUI)
frozen = false;
with (obj_link) {
	state = "talk";
	image_speed = 0;
}

menu_font = font_add_sprite_ext(spr_menu_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);

stack = [];		//the conversation, plus the steps of any answer or dlg_if being played
pages = [];		//the text being shown, split into boxes of lines (see dialogue_show)
page = 0;
shown = 0;		//letters typed out so far in this box
page_len = 0;
choices = [];	//answers, when this text ends in a choice box
cursor = 0;

//A shop's counter (see the shop script): open, which shop, what's on the shelf, the one picked,
//and -1 or the YES / NO being asked
small_font = font_add_sprite_ext(spr_font_small, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
shop_on = false;
shop_name = "";
shop_list = [];
shop_cursor = 0;
shop_confirm = -1;

//Box at the bottom of the screen, or at the top when Link is in the bottom part
box_top = false;
if (instance_exists(obj_link) && view_enabled) {
	var cam = view_camera[0];
	box_top = (obj_link.y - camera_get_view_y(cam) > camera_get_view_height(cam) * 0.6);
}
