//Only one Link. obj_link is persistent, so a copy placed in a room
//gets removed when the player walks back in.
if (instance_number(obj_link) > 1) {
	instance_destroy();
	exit;
}

//Always collide as a 16x16 body, even when the attack sprites are bigger
mask_index = spr_link_down;

//Vars
spd = WALK_SPEED;	//see the player_moves script
move_frac_x = 0;	//leftover fractions of a pixel (see player_move)
move_frac_y = 0;
grd=sprite_width;
xx = 0;	//d-pad this step (set in Step, read by doors)
yy = 0;
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
global.pArrowsMax = 20;
global.bombLevel = 0;	//capacity upgrades, see player_upgrade_bombs/arrows
global.arrowLevel = 0;

//Items (see the items script). Starts with the bow on A for now.
global.item_have = array_create(ITEM.COUNT, false);
global.itemA = ITEM.NONE;
global.itemY = ITEM.NONE;
global.shieldTier = 0;	//the shield is an item, see shield_set_tier
global.bottles = array_create(BOTTLES, BOTTLE.EMPTY);	//what's in each bottle
item_give(ITEM.BOW);
item_give(ITEM.FLUTE);	//Link starts with the flute

//Equipment tiers (0 = none). The sword is always on B.
global.swordTier = 1;
global.armorTier = 1;

//Equipment you have or don't
global.hasBoots = false;	//preassigned
global.hasGloves = false;	//passive
global.hasFlippers = false;	//passive

//The Bun, one piece per dungeon
global.bunPieces = array_create(BUN_PIECES, false);

//Dungeons: keys, boss keys, maps, compasses (see the dungeon script), and the floor Link's on
dungeon_init();
cur_floor = noone;

//Story flags set by conversations (see the dialogue_system script), cleared for a new game
global.flags = {};

//Set by the pause screen when it closes, so Link ignores that button press
global.pause_block = false;

//Dungeon camera (see cam_zones): the zone Link is in, and whether it's sliding to a new one
global.cam_zone = noone;
global.cam_transition = false;

//Shield raised (holding the shield's button), and how fast Link walks with it up
shielding = false;
shield_spd = 0.5;

//Equipment moves (see the player_moves script)
swimming = false;	//in deep water with the flippers
lift_timer = 0;		//walking into a heavy rock with the strength gloves
carrying = false;	//holding a heavy rock over his head

//Animation (see player_animate): frame timer, 0/1/2 standing/walking/running, and the
//sword/hammer/rock pose frame (-1 = none)
anim_timer = 0;
anim_rate = 0;
pose = -1;

//The cape's jump (see player_jump_step): steps in the air, height off the ground,
//and the speed he's carried along at
jump_t = 0;
z = 0;
air_h = 0;
air_v = 0;
hspd = 0;
vspd = 0;

//Pits (see player_pit_check): steps over the edge, steps falling, last safe spot
fall_grace = 0;
fall_t = 0;
safe_x = x;
safe_y = y;
safe_level = 0;

//Hopping down off a ledge (see ledge_hop_check): where the hop starts and lands
hop_y0 = y;
hop_y1 = y;
hop_level = 0;

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
