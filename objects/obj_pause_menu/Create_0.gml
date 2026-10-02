/// @description Pause screen (A Link to the Past style)

//Freeze the game. Deactivated instances stop drawing too,
//so keep a picture of the last frame to draw underneath the menu.
snap = sprite_create_from_surface(application_surface, 0, 0, surface_get_width(application_surface), surface_get_height(application_surface), false, false, 0, 0);
instance_deactivate_all(true);

menu_font = font_add_sprite_ext(spr_menu_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);

//Skip input on the first step: the button that opened the menu still counts as pressed
opened = false;

//Item grid (slot number = item number, see the items script)
grid_cols = 5;
grid_rows = 4;
cell = 28;
cursor = max(0, global.itemA);	//start on the equipped item

//Layout (GUI is the size of the view, 256x176)
items_x = 4;	//left: items
items_y = 4;
items_w = 148;
items_h = 168;
grid_x = items_x + (items_w - grid_cols * cell) div 2;
grid_y = items_y + 18;

side_x = 156;	//right column
side_w = 96;
sel_y = 4;		//selected item
sel_h = 44;
bun_y = 52;		//The Bun
bun_h = 52;
equip_y = 108;	//equipment
equip_h = 64;
