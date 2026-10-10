//Items, equipment and The Bun.
//
//Items go on the A, Y or X button and are picked on the pause screen.
//Where each item sits on the pause screen grid is set in item_grid().
//Using the newer items (bottles, lantern, rods, flute, hammer, shovel, cape, mirror) is in
//the items_use script. The Sun Lens is in the sun_lens script.
//The shield is an item (put it on A or Y). Hold its button to raise it (see shield_is_held).
//Its tier is global.shieldTier, see shield_set_tier.
//
//Equipment is not on the grid:
//	Preassigned (fixed button): sword (always on B, global.swordTier), running boots (global.hasBoots)
//	Passive (always on): strength gloves (global.hasGloves), armor (global.armorTier), flippers (global.hasFlippers)

enum ITEM {
	NONE = -1,
	BOW,
	SHIELD,
	BOMBS,
	BOOMERANG,
	GRAPPLE,
	LANTERN,
	FIRE_ROD,
	ICE_ROD,
	LIGHTNING_ROD,
	FLUTE,
	HAMMER,
	SHOVEL,
	CAPE,
	MIRROR,
	BOTTLE_1,	//the five bottles; what's in each is global.bottles[0-4] (see the items_use script)
	BOTTLE_2,
	BOTTLE_3,
	BOTTLE_4,
	BOTTLE_5,
	LENS,		//the Sun Lens (after the bottles, so older save files still line up)
	COUNT
}

#macro BUN_PIECES 3
#macro SWORD_TIER_MAX 4			//1 iron, 2-3 forged by the smith with Star Iron (optional), 4 the Sword of Bun
#macro SWORD_TIER_BUN 4
#macro SHIELD_TIER_MAX 3
#macro SHIELD_ARC 60			//degrees either side of where Link faces that the wooden shield covers
#macro SHIELD_ARC_BIG 80		//...the big and mirror shields
#macro ARMOR_TIER_MAX 3

#macro ITEM_STUN_TIME 120		//how long the boomerang and grapple hook stun enemies
#macro BOMB_FUSE 80
#macro BOMB_RADIUS 20
#macro BOMB_DAMAGE_PLAYER 2	//half hearts (before armor)
#macro BOMB_DAMAGE_ENEMY 4
#macro BOMBS_OUT_MAX 2			//bombs on the ground at once

///item_grid();
function item_grid() {
	//The pause screen grid, left to right, top to bottom (5 x 4). ITEM.NONE = empty slot.
	return [
		ITEM.BOW,		ITEM.BOOMERANG,	ITEM.GRAPPLE,		ITEM.BOMBS,		ITEM.SHIELD,
		ITEM.FIRE_ROD,	ITEM.ICE_ROD,	ITEM.LIGHTNING_ROD,	ITEM.LANTERN,	ITEM.HAMMER,
		ITEM.SHOVEL,	ITEM.FLUTE,		ITEM.CAPE,			ITEM.MIRROR,	ITEM.LENS,
		ITEM.BOTTLE_1,	ITEM.BOTTLE_2,	ITEM.BOTTLE_3,		ITEM.BOTTLE_4,	ITEM.BOTTLE_5
	];


}

///item_grid_slot(item);
function item_grid_slot(argument0) {
	//Where an item is on the pause screen grid, -1 if it isn't
	var grid = item_grid();
	for (var i = 0; i < array_length(grid); i++) {
		if (grid[i] == argument0) {return i}
	}
	return -1;


}

///item_get_name(item);
function item_get_name(argument0) {
	switch (argument0) {
		case ITEM.BOW: return "BOW";
		case ITEM.SHIELD:
			switch (global.shieldTier) {
				case 1: return "WOODEN SHIELD";
				case 2: return "BIG SHIELD";
				case 3: return "MIRROR SHIELD";
			}
			return "SHIELD";
		case ITEM.BOMBS: return "BOMBS";
		case ITEM.BOOMERANG: return "BOOMERANG";
		case ITEM.GRAPPLE: return "GRAPPLE HOOK";
		case ITEM.LANTERN: return "LANTERN";
		case ITEM.FIRE_ROD: return "FIRE ROD";
		case ITEM.ICE_ROD: return "ICE ROD";
		case ITEM.LIGHTNING_ROD: return "LIGHTNING ROD";
		case ITEM.FLUTE: return "FLUTE";
		case ITEM.HAMMER: return "HAMMER";
		case ITEM.SHOVEL: return "SHOVEL";
		case ITEM.CAPE: return "CAPE";
		case ITEM.MIRROR: return "MAGIC MIRROR";
		case ITEM.LENS: return "SUN LENS";
	}
	if (bottle_is(argument0)) {return bottle_get_name(global.bottles[argument0 - ITEM.BOTTLE_1])}
	return "";


}

///item_get_sprite(item);
function item_get_sprite(argument0) {
	//Icon used on the HUD and the pause screen, -1 for none
	switch (argument0) {
		case ITEM.BOW: return spr_item_bow;
		case ITEM.SHIELD: return spr_menu_shield;
		case ITEM.BOMBS: return spr_item_bombs;
		case ITEM.BOOMERANG: return spr_item_boomerang;
		case ITEM.GRAPPLE: return spr_item_grapple;
		case ITEM.LANTERN: return spr_item_lantern;
		case ITEM.FIRE_ROD: return spr_item_fire_rod;
		case ITEM.ICE_ROD: return spr_item_ice_rod;
		case ITEM.LIGHTNING_ROD: return spr_item_lightning_rod;
		case ITEM.FLUTE: return spr_item_flute;
		case ITEM.HAMMER: return spr_item_hammer;
		case ITEM.SHOVEL: return spr_item_shovel;
		case ITEM.CAPE: return spr_item_cape;
		case ITEM.MIRROR: return spr_item_mirror;
		case ITEM.LENS: return spr_item_lens;
	}
	if (bottle_is(argument0)) {return spr_item_bottle}
	return -1;


}

///item_get_frame(item);
function item_get_frame(argument0) {
	//Frame of the item's icon (the shield shows its tier, a bottle what's in it)
	switch (argument0) {
		case ITEM.SHIELD: return max(0, global.shieldTier - 1);
	}
	if (bottle_is(argument0)) {return global.bottles[argument0 - ITEM.BOTTLE_1]}
	return 0;


}

///item_use(item);
function item_use(argument0) {
	//Run by obj_link when A is pressed. Returns true if the item was used.
	switch (argument0) {
		case ITEM.BOW: return item_use_bow();
		case ITEM.SHIELD: return false;	//held, not pressed: see shield_is_held
		case ITEM.BOMBS: return item_use_bombs();
		case ITEM.BOOMERANG: return item_use_boomerang();
		case ITEM.GRAPPLE: return item_use_grapple();
		case ITEM.LANTERN: return item_use_lantern();
		case ITEM.FIRE_ROD: return item_use_rod(SHOT.FIRE, MAGIC_FIRE_ROD);
		case ITEM.ICE_ROD: return item_use_rod(SHOT.ICE, MAGIC_ICE_ROD);
		case ITEM.LIGHTNING_ROD: return item_use_rod(SHOT.LIGHTNING, MAGIC_LIGHTNING_ROD);
		case ITEM.FLUTE: return item_use_flute();
		case ITEM.HAMMER: return item_use_hammer();
		case ITEM.SHOVEL: return item_use_shovel();
		case ITEM.CAPE: return item_use_cape();
		case ITEM.MIRROR: return item_use_mirror();
		case ITEM.LENS: return item_use_lens();
	}
	if (bottle_is(argument0)) {return item_use_bottle(argument0)}
	return false;


}

///item_use_bow();
function item_use_bow() {
	//Run by obj_link. Shoots one arrow the way Link is facing.
	if (global.pArrows <= 0) return false;
	player_add_arrows(-1);

	var ang = player_face_angle(dir);

	var arrow = instance_create_depth(x + lengthdir_x(8, ang), y + lengthdir_y(8, ang), depth, obj_arrow);
	arrow.direction = ang;
	arrow.image_angle = ang;
	arrow.level = level;

	//Short pause while shooting, like the sword
	state = "shoot";
	cnt = 0;
	dur = 10;
	spr_prev = sprite_index;
	image_speed = 0;
	return true;


}

///item_use_bombs();
function item_use_bombs() {
	//Run by obj_link. Sets a bomb down in front of him (under him if there's a wall there).
	if (global.pBombs <= 0 || instance_number(obj_bomb) >= BOMBS_OUT_MAX) return false;
	player_add_bombs(-1);

	var ang = player_face_angle(dir);
	var bx = x + lengthdir_x(10, ang);
	var by = y + lengthdir_y(10, ang);
	if (level_wall_at(bx, by, level)) {
		bx = x;
		by = y;
	}

	var bomb = instance_create_depth(bx, by, depth + 1, obj_bomb);
	bomb.level = level;
	return true;


}

///item_use_boomerang();
function item_use_boomerang() {
	//Run by obj_link. Throws the boomerang the way he's facing, or diagonally
	//if a diagonal is held. Only one at a time.
	if (instance_exists(obj_boomerang)) return false;

	var ang = player_face_angle(dir);
	var mx = move_right - move_left;
	var my = move_down - move_up;
	if (mx != 0 || my != 0) {ang = point_direction(0, 0, mx, my)}

	var boom = instance_create_depth(x, y, depth - 1, obj_boomerang);
	boom.direction = ang;
	boom.level = level;

	//Short pause while throwing, like the bow
	state = "shoot";
	cnt = 0;
	dur = 8;
	spr_prev = sprite_index;
	image_speed = 0;
	return true;


}

///item_use_grapple();
function item_use_grapple() {
	//Run by obj_link. Fires the grapple hook the way he's facing.
	//Link stands still (state "hook") until obj_hookshot is done with him.
	if (instance_exists(obj_hookshot)) return false;

	var hook = instance_create_depth(x, y, depth - 1, obj_hookshot);
	hook.direction = player_face_angle(dir);
	hook.image_angle = hook.direction;
	hook.level = level;

	state = "hook";
	spr_prev = sprite_index;
	image_speed = 0;
	return true;


}

///bomb_explode();
function bomb_explode() {
	//Run by obj_bomb. Hurts Link and enemies in range, breaks obj_bomb_wall,
	//sets off other bombs, then plays the explosion.
	var bx = x;
	var by = y;
	var lvl = level;
	exploded = true;
	sprite_index = spr_bomb_explosion;
	image_index = 0;
	image_speed = 0.3;
	sfx_play(SFX_BOMB);
	feel_shake(SHAKE_BOMB, SHAKE_BOMB_TIME);

	//Link: armor helps, the shield doesn't
	with (obj_link) {
		if (level == lvl && collision_circle(bx, by, BOMB_RADIUS, id, false, false)) {
			player_hurt(BOMB_DAMAGE_PLAYER, bx, by);
		}
	}
	with (obj_enemy) {
		if ((level == -1 || level == lvl) && collision_circle(bx, by, BOMB_RADIUS, id, false, false)) {
			enemy_hurt(id, BOMB_DAMAGE_ENEMY, bx, by);
		}
	}
	with (obj_bomb_wall) {
		if (collision_circle(bx, by, BOMB_RADIUS, id, false, false)) {
			flag_set(door_flag(), true);	//stays broken
			sfx_play(SFX_SECRET);
			instance_destroy();
		}
	}
	with (obj_bomb) {
		if (!exploded && level == lvl && collision_circle(bx, by, BOMB_RADIUS, id, false, false)) {
			timer = min(timer, 6);
		}
	}


}

///item_give(item);
function item_give(argument0) {
	//For chests and pickups. Equips it on A if A is empty, otherwise on Y, otherwise on X.
	if (global.item_have[argument0]) return;
	global.item_have[argument0] = true;
	if (global.itemA == ITEM.NONE) {global.itemA = argument0}
	else if (global.itemY == ITEM.NONE) {global.itemY = argument0}
	else if (global.itemX == ITEM.NONE) {global.itemX = argument0}


}

///item_take(item);
function item_take(argument0) {
	//Removes an item and takes it off A/Y/X
	global.item_have[argument0] = false;
	if (global.itemA == argument0) {global.itemA = ITEM.NONE}
	if (global.itemY == argument0) {global.itemY = ITEM.NONE}
	if (global.itemX == argument0) {global.itemX = ITEM.NONE}


}

///item_equip(item, button);
function item_equip(argument0, argument1) {
	//Puts an item on button 0 = A, 1 = Y or 2 = X.
	//If it's already on another button, the two buttons swap.
	var item = argument0;
	var slots = [global.itemA, global.itemY, global.itemX];
	var b = clamp(argument1, 0, 2);
	for (var i = 0; i < 3; i++) {
		if (i != b && slots[i] == item) {slots[i] = slots[b]}
	}
	slots[b] = item;
	global.itemA = slots[0];
	global.itemY = slots[1];
	global.itemX = slots[2];


}

///shield_set_tier(tier);
function shield_set_tier(argument0) {
	//0 = no shield, 1-3 = wooden, big, mirror. Gives or takes the shield item.
	global.shieldTier = clamp(argument0, 0, SHIELD_TIER_MAX);
	if (global.shieldTier > 0) {item_give(ITEM.SHIELD)}
	else {item_take(ITEM.SHIELD)}


}

///shield_is_held();
function shield_is_held() {
	//Run by obj_link after input_get: is the button the shield is on being held?
	if (global.shieldTier <= 0) return false;
	return item_button_held(ITEM.SHIELD);


}

///shield_get_sprite();
function shield_get_sprite() {
	//Shield Link holds up, by tier. Frames: 0 right, 1 up, 2 left, 3 down. Origin matches Link's.
	switch (global.shieldTier) {
		case 1: return spr_link_shield_wood;
		case 2: return spr_link_shield_iron;
		case 3: return spr_link_shield_gold;
	}
	return -1;


}

///shield_blocks(from_dir, tier_needed);
function shield_blocks(argument0, argument1) {
	//true if Link has his shield up, facing within SHIELD_ARC degrees of from_dir
	//(the direction from Link towards the attack) and the shield is at least tier_needed.
	//Weak attacks use 1, so any shield blocks them. The wizards' spells need the big shield (2),
	//and the mirror shield (3) bounces them back (see the castle_enemies script).
	//The big and mirror shields cover a wider angle.
	if (!instance_exists(obj_link)) return false;
	if (!obj_link.shielding || global.shieldTier < argument1) return false;
	var arc = (global.shieldTier >= 2) ? SHIELD_ARC_BIG : SHIELD_ARC;
	return abs(angle_difference(player_face_angle(obj_link.dir), argument0)) <= arc;


}

///item_button_held(item);
function item_button_held(argument0) {
	//Run by obj_link after input_get: is the button this item is on (A, Y or X) being held?
	return (global.itemA == argument0 && hold_a) || (global.itemY == argument0 && hold_y) || (global.itemX == argument0 && hold_x);


}

///bun_collect(piece);
function bun_collect(argument0) {
	//piece: 0, 1 or 2 (one per dungeon)
	global.bunPieces[argument0] = true;


}

///bun_count();
function bun_count() {
	//How many Bun pieces Link has (BUN_PIECES = all of them)
	var n = 0;
	for (var i = 0; i < BUN_PIECES; i++) {
		if (global.bunPieces[i]) {n++}
	}
	return n;


}
