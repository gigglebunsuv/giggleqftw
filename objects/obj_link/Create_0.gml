//Only one Link. obj_link is persistent, so a copy placed in a room
//gets removed when the player walks back in.
if (instance_number(obj_link) > 1) {
	instance_destroy();
	exit;
}

//Always collide as a 16x16 body, even when the attack sprites are bigger
mask_index = spr_link_down;

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
global.pArrows = 10;
global.pArrowsMax = 30;

//Items (see the items script). Starts with the bow on A for now.
global.item_have = array_create(ITEM.COUNT, false);
global.itemA = ITEM.NONE;
item_give(ITEM.BOW);

//Equipment tiers (0 = none). The sword is always on B.
global.swordTier = 1;
global.shieldTier = 0;
global.armorTier = 1;

//The Bun, one piece per dungeon
global.bunPieces = array_create(BUN_PIECES, false);

//Set by the pause screen when it closes, so Link ignores that button press
global.pause_block = false;

//Dungeon camera (see cam_zones): the zone Link is in, and whether it's sliding to a new one
global.cam_zone = noone;
global.cam_transition = false;

//Getting hurt (see player_hurt)
hurt_timer = 0;
kb_dir = 0;

//Upper/lower floor in dungeons (see the levels script).
//base_depth is the normal draw depth, used in rooms without levels.
level = 0;
base_depth = depth;

//Where Link entered the current room: CONTINUE on the game over screen starts him here
entry_x = x;
entry_y = y;

//HUD
if (!instance_exists(obj_hud_main)) {
	instance_create_depth(0,0,-100,obj_hud_main);
}
