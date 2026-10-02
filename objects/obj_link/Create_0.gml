//Only one Link. obj_link is persistent, so a copy placed in a room
//gets removed when the player walks back in.
if (instance_number(obj_link) > 1) {
	instance_destroy();
	exit;
}

//Vars
spd = (sprite_width/8);
ani = (spd*0.1)*image_number;
grd=sprite_width;
dir="right";
state="idle";
global.pHealth = 6;
global.pHealthMax = 6;	//2 health per heart
global.pMagic = 32;
global.pMagicMax = 32;

//Counters (Zelda 1 style, max 3 digits on the HUD)
global.pMoney = 0;
global.pMoneyMax = 999;
global.pKeys = 0;
global.pKeysMax = 99;
global.pBombs = 0;
global.pBombsMax = 8;
global.pArrows = 0;
global.pArrowsMax = 30;

//Equipped items (sprite shown on the HUD button, -1 = empty)
global.itemB = spr_hud_item_sword;
global.itemA = -1;

//HUD
if (!instance_exists(obj_hud_main)) {
	instance_create_depth(0,0,-100,obj_hud_main);
}
