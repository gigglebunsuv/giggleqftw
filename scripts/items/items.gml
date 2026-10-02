//Items, equipment and The Bun.
//
//Items go on the A button and are picked on the pause screen.
//An item's number is also its slot in the pause screen grid (left to right, top to bottom),
//so new items go at the end of the enum, before COUNT.
//The sword is equipment, not an item: it is always on B and its tier is global.swordTier.

enum ITEM {
	NONE = -1,
	BOW,
	COUNT
}

#macro BUN_PIECES 3
#macro SWORD_TIER_MAX 4
#macro SHIELD_TIER_MAX 3
#macro ARMOR_TIER_MAX 3

///item_get_name(item);
function item_get_name(argument0) {
	switch (argument0) {
		case ITEM.BOW: return "BOW";
	}
	return "";


}

///item_get_sprite(item);
function item_get_sprite(argument0) {
	//Icon used on the HUD and the pause screen, -1 for none
	switch (argument0) {
		case ITEM.BOW: return spr_item_bow;
	}
	return -1;


}

///item_use(item);
function item_use(argument0) {
	//Run by obj_link when A is pressed. Returns true if the item was used.
	switch (argument0) {
		case ITEM.BOW: return item_use_bow();
	}
	return false;


}

///item_use_bow();
function item_use_bow() {
	//Run by obj_link. Shoots one arrow the way Link is facing.
	if (global.pArrows <= 0) return false;
	player_add_arrows(-1);

	var ang = 0;
	switch (dir) {
		case "up": ang = 90; break;
		case "down": ang = 270; break;
		case "left": ang = 180; break;
		case "right": ang = 0; break;
	}

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

///item_give(item);
function item_give(argument0) {
	//For chests and pickups. Equips it on A if A is empty.
	global.item_have[argument0] = true;
	if (global.itemA == ITEM.NONE) {global.itemA = argument0}


}

///bun_collect(piece);
function bun_collect(argument0) {
	//piece: 0, 1 or 2 (one per dungeon)
	global.bunPieces[argument0] = true;


}
