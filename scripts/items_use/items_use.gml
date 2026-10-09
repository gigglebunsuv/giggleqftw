//The rest of the items: bottles, lantern, fire/ice/lightning rods, flute, hammer, shovel,
//cape and magic mirror. Also pickups (hearts, money, magic) and torches.
//The item list, names and icons are in the items script.
//Every item_use_* function is run by obj_link and returns true if the item was used.

enum BOTTLE {
	EMPTY,
	RED,	//refills health
	GREEN,	//refills magic
	BLUE,	//refills both
	FAIRY,	//heals FAIRY_HEAL, or brings Link back when he'd die
	COUNT
}

enum SHOT {
	LANTERN,	//small flame in front of Link: lights torches, burns bushes
	FIRE,		//fireball: damage, lights torches, burns bushes
	ICE,		//freezes enemies
	LIGHTNING	//fast bolt that goes through enemies
}

enum PICKUP {
	HEART,
	MONEY1,
	MONEY5,
	MONEY20,
	MAGIC
}

#macro BOTTLES 5
#macro FAIRY_HEAL 14			//health (2 per heart)
#macro MAGIC_LANTERN 1
#macro MAGIC_FIRE_ROD 4
#macro MAGIC_ICE_ROD 4
#macro MAGIC_LIGHTNING_ROD 4
#macro ICE_FREEZE_TIME 150		//steps an enemy stays frozen (30 steps = 1 second)
#macro FLUTE_SONG_TIME 45		//steps the song plays before the warp menu opens
#macro PICKUP_LIFE 300			//steps before a pickup disappears

///item_magic_spend(amount);
function item_magic_spend(argument0) {
	//Takes the magic if there's enough. If there isn't, takes nothing and returns false.
	if (global.pMagic < argument0) return false;
	player_add_magic(-argument0);
	return true;


}

///item_pause(steps);
function item_pause(argument0) {
	//Run by obj_link: holds still for a moment after using an item (like the bow)
	state = "shoot";
	cnt = 0;
	dur = argument0;
	spr_prev = sprite_index;
	image_speed = 0;


}

///item_front_x(dist); item_front_y(dist);
function item_front_x(argument0) {return x + lengthdir_x(argument0, player_face_angle(dir))}
function item_front_y(argument0) {return y + lengthdir_y(argument0, player_face_angle(dir))}

//================================================================ bottles

///bottle_is(item);
function bottle_is(argument0) {
	return argument0 >= ITEM.BOTTLE_1 && argument0 <= ITEM.BOTTLE_5;


}

///bottle_get_name(contents);
function bottle_get_name(argument0) {
	switch (argument0) {
		case BOTTLE.RED: return "RED POTION";
		case BOTTLE.GREEN: return "GREEN POTION";
		case BOTTLE.BLUE: return "BLUE POTION";
		case BOTTLE.FAIRY: return "FAIRY";
	}
	return "BOTTLE";


}

///bottle_give(contents);
function bottle_give(argument0) {
	//For shops, caves and side quests: the next bottle Link doesn't have yet, holding contents.
	//Returns false if he already has all of them.
	for (var i = 0; i < BOTTLES; i++) {
		if (!global.item_have[ITEM.BOTTLE_1 + i]) {
			global.bottles[i] = argument0;
			item_give(ITEM.BOTTLE_1 + i);
			return true;
		}
	}
	return false;


}

///bottle_fill(contents);
function bottle_fill(argument0) {
	//Puts contents in the first empty bottle (buying a potion, catching a fairy).
	//Returns false if there's no empty bottle.
	for (var i = 0; i < BOTTLES; i++) {
		if (global.item_have[ITEM.BOTTLE_1 + i] && global.bottles[i] == BOTTLE.EMPTY) {
			global.bottles[i] = argument0;
			return true;
		}
	}
	return false;


}

///item_use_bottle(item);
function item_use_bottle(argument0) {
	//Drinks the potion or lets the fairy out. An empty bottle does nothing yet.
	var b = argument0 - ITEM.BOTTLE_1;
	switch (global.bottles[b]) {
		case BOTTLE.RED: player_add_health(global.pHealthMax); break;
		case BOTTLE.GREEN: player_add_magic(global.pMagicMax); break;
		case BOTTLE.BLUE:
			player_add_health(global.pHealthMax);
			player_add_magic(global.pMagicMax);
			break;
		case BOTTLE.FAIRY: player_add_health(FAIRY_HEAL); break;
		default: return false;
	}
	global.bottles[b] = BOTTLE.EMPTY;
	sfx_play(SFX_DRINK);
	item_pause(20);
	return true;


}

///bottle_use_fairy();
function bottle_use_fairy() {
	//Run by player_die: a bottled fairy brings Link back instead. Returns true if it did.
	for (var i = 0; i < BOTTLES; i++) {
		if (global.item_have[ITEM.BOTTLE_1 + i] && global.bottles[i] == BOTTLE.FAIRY) {
			global.bottles[i] = BOTTLE.EMPTY;
			global.pHealth = min(FAIRY_HEAL, global.pHealthMax);
			hurt_timer = 60;
			sfx_play(SFX_DRINK);
			return true;
		}
	}
	return false;


}

//================================================================ lantern and rods

///magic_shot_create(kind, x, y, direction);
function magic_shot_create(argument0, argument1, argument2, argument3) {
	//Run by obj_link. The flame, fireball, ice or lightning (obj_magic_shot).
	var shot = instance_create_depth(argument1, argument2, depth - 1, obj_magic_shot);
	shot.kind = argument0;
	shot.level = level;
	shot.direction = argument3;
	with (shot) {
		switch (kind) {
			case SHOT.LANTERN: sprite_index = spr_lantern_flame; speed = 0; life = 15; break;
			case SHOT.FIRE: sprite_index = spr_fireball; speed = 3; life = 75; break;
			case SHOT.ICE: sprite_index = spr_iceball; speed = 3; life = 75; break;
			case SHOT.LIGHTNING:
				sprite_index = spr_lightning_bolt;
				image_angle = direction;
				speed = 6;
				life = 45;
				break;
		}
	}
	return shot;


}

///item_use_lantern();
function item_use_lantern() {
	if (!item_magic_spend(MAGIC_LANTERN)) return false;
	magic_shot_create(SHOT.LANTERN, item_front_x(12), item_front_y(12), player_face_angle(dir));
	sfx_play(SFX_LANTERN);
	item_pause(8);
	return true;


}

///item_use_rod(kind, magic);
function item_use_rod(argument0, argument1) {
	//Fire, ice and lightning rods: a shot the way Link is facing
	if (!item_magic_spend(argument1)) return false;
	magic_shot_create(argument0, item_front_x(8), item_front_y(8), player_face_angle(dir));
	switch (argument0) {
		case SHOT.FIRE: sfx_play(SFX_FIRE_ROD); break;
		case SHOT.ICE: sfx_play(SFX_ICE_ROD); break;
		case SHOT.LIGHTNING: sfx_play(SFX_LIGHTNING_ROD); break;
	}
	item_pause(10);
	return true;


}

///torch_light(torch);
function torch_light(argument0) {
	with (argument0) {
		if (!lit) {
			lit = true;
			burn_timer = burn_time;
			sfx_play(SFX_TORCH);
		}
	}


}

///torches_all_lit();
function torches_all_lit() {
	//For puzzles: true when every obj_torch in the room is lit (and there's at least one)
	if (!instance_exists(obj_torch)) return false;
	var all_lit = true;
	with (obj_torch) {
		if (!lit) {all_lit = false}
	}
	return all_lit;


}

//================================================================ flute

///item_use_flute();
function item_use_flute() {
	//Plays the song. In rooms with obj_flute_spot markers, a warp menu opens after it (obj_flute_menu).
	if (instance_exists(obj_flute_menu)) return false;
	sfx_play(SFX_FLUTE);
	instance_create_depth(0, 0, -1000, obj_flute_menu);
	state = "flute";
	spr_prev = sprite_index;
	image_speed = 0;
	return true;


}

///camera_snap();
function camera_snap() {
	//After moving Link a long way (flute, mirror): jump the camera to him instead of sliding
	with (obj_camera) {event_perform(ev_other, ev_room_start)}


}

//================================================================ hammer and shovel

///item_use_hammer();
function item_use_hammer() {
	//obj_hammer does the hit a moment later (and moves Link's arms)
	instance_create_depth(x, y, depth - 1, obj_hammer);
	item_pause(16);
	pose = LINK_FRAME_RAISE;
	return true;


}

///peg_pound(peg);
function peg_pound(argument0) {
	//Hammered flat: the peg goes, a flat one (obj_decal) is left in its place
	with (argument0) {
		var flat = instance_create_depth(x, y, depth, obj_decal);
		flat.sprite_index = spr_peg;
		flat.image_index = 1;
		instance_destroy();
	}


}

///item_use_shovel();
function item_use_shovel() {
	//Digs the tile in front of Link: finds what's buried there (obj_dig_spot),
	//otherwise sometimes a heart or some money. Can't dig walls, water or the same hole twice.
	var dx = (item_front_x(12) div 16) * 16 + 8;
	var dy = (item_front_y(12) div 16) * 16 + 8;
	item_pause(14);
	if (position_meeting(dx, dy, obj_wall) || position_meeting(dx, dy, obj_water) || position_meeting(dx, dy, obj_decal)) {
		sfx_play(SFX_HOOK_HIT);
		return true;
	}
	sfx_play(SFX_DIG);
	var hole = instance_create_depth(dx, dy, depth + 1, obj_decal);
	hole.sprite_index = spr_dig_hole;

	var spot = instance_position(dx, dy, obj_dig_spot);
	if (spot != noone) {
		if (spot.item != ITEM.NONE) {item_give(spot.item)}
		else {pickup_create(spot.reward, dx, dy)}
		with (spot) {instance_destroy()}
	} else if (irandom(5) == 0) {
		pickup_create(choose(PICKUP.HEART, PICKUP.MONEY1, PICKUP.MONEY5), dx, dy);
	}
	return true;


}

//================================================================ cape and mirror

///item_use_cape();
function item_use_cape() {
	//A jump over a one-tile pit (see player_jump_start in the player_moves script)
	return player_jump_start();


}

///item_use_mirror();
function item_use_mirror() {
	//Back to where Link came into this room (a dungeon's entrance when in a dungeon)
	if (point_distance(x, y, entry_x, entry_y) < 16) return false;
	sfx_play(SFX_MIRROR);
	x = entry_x;
	y = entry_y;
	if (level_room_uses_levels()) {level_set(0)}
	camera_snap();
	item_pause(10);
	return true;


}

//================================================================ pickups

///pickup_create(kind, x, y);
function pickup_create(argument0, argument1, argument2) {
	var p = instance_create_depth(argument1, argument2, -10, obj_pickup);
	if (instance_exists(obj_link)) {p.depth = obj_link.depth}
	p.kind = argument0;
	p.image_index = argument0;
	return p;


}

///pickup_collect(kind);
function pickup_collect(argument0) {
	switch (argument0) {
		case PICKUP.HEART: player_add_health(2); break;
		case PICKUP.MONEY1: player_add_money(1); break;
		case PICKUP.MONEY5: player_add_money(5); break;
		case PICKUP.MONEY20: player_add_money(20); break;
		case PICKUP.MAGIC: player_add_magic(8); break;
	}
	switch (argument0) {
		case PICKUP.HEART: sfx_play(SFX_HEART); break;
		case PICKUP.MAGIC: sfx_play(SFX_MAGIC); break;
		default: sfx_play(SFX_MONEY); break;
	}


}

//================================================================ treasure (pickups on pedestals)

///treasure_collect();
function treasure_collect() {
	//Run by obj_treasure when Link touches it (and obj_item_get, for chests): gives Link what it holds
	if (item != ITEM.NONE) {
		if (item == ITEM.SHIELD) {shield_set_tier(max(global.shieldTier + 1, tier))}
		else {item_give(item)}
		if (item == ITEM.BOMBS) {global.pBombs = global.pBombsMax}
		if (item == ITEM.BOW) {global.pArrows = global.pArrowsMax}
	} else {
		switch (equip) {
			case "bottle":
				if (!bottle_give(contents)) {bottle_fill(contents)}
				break;
			case "sword": global.swordTier = clamp(max(global.swordTier, tier), 0, SWORD_TIER_MAX); break;
			case "shield": shield_set_tier(max(global.shieldTier, tier)); break;
			case "armor": global.armorTier = clamp(max(global.armorTier, tier), 1, ARMOR_TIER_MAX); break;
			case "gloves": global.hasGloves = true; break;
			case "flippers": global.hasFlippers = true; break;
			case "boots": global.hasBoots = true; break;
			case "bomb_bag": player_upgrade_bombs(); break;
			case "quiver": player_upgrade_arrows(); break;
			case "heart": player_add_heart(); break;
			case "heart_piece": heart_piece_collect(); break;
			case "ore": global.swordOre += amount; break;
			case "bun":
				var piece = 0;
				while (piece < BUN_PIECES && global.bunPieces[piece]) {piece++}
				if (piece < BUN_PIECES) {bun_collect(piece)}
				break;
			case "refill":
				global.pHealth = global.pHealthMax;
				global.pMagic = global.pMagicMax;
				global.pBombs = global.pBombsMax;
				global.pArrows = global.pArrowsMax;
				break;
			case "money": player_add_money(amount); break;
			case "key": player_add_keys(amount); break;
			case "map": global.dungeonMap[global.dungeon] = true; break;
			case "compass": global.dungeonCompass[global.dungeon] = true; break;
			case "boss_key": global.bossKey[global.dungeon] = true; break;
		}
	}
	sfx_play(treasure_fanfare());


}

///treasure_fanfare();
function treasure_fanfare() {
	//Run by obj_treasure / obj_item_get: which sound plays for what it holds (see the sfx script)
	if (item != ITEM.NONE) return SFX_FANFARE_ITEM;
	switch (equip) {
		case "heart": case "heart_piece": return SFX_HEART_CONTAINER;
		case "bun": return SFX_FANFARE_BUN;
		case "sword": case "shield": case "armor": case "gloves": case "flippers": case "boots":
		case "bomb_bag": case "quiver": case "boss_key": case "ore":
			return SFX_FANFARE_ITEM;
	}
	return SFX_ITEM_GET;


}

///treasure_icon();
function treasure_icon() {
	//Run by obj_treasure: [sprite, frame] to show for what it holds ([-1, 0] for nothing)
	if (item == ITEM.SHIELD) {return [spr_menu_shield, clamp(tier, 1, SHIELD_TIER_MAX) - 1]}
	if (item != ITEM.NONE) {return [item_get_sprite(item), 0]}
	switch (equip) {
		case "bottle": return [spr_item_bottle, contents];
		case "sword": return [spr_menu_sword, clamp(tier, 1, SWORD_TIER_MAX) - 1];
		case "shield": return [spr_menu_shield, clamp(tier, 1, SHIELD_TIER_MAX) - 1];
		case "armor": return [spr_menu_armor, clamp(tier, 1, ARMOR_TIER_MAX) - 1];
		case "gloves": return [spr_menu_gloves, 0];
		case "flippers": return [spr_menu_flippers, 0];
		case "boots": return [spr_menu_boots, 0];
		case "bomb_bag": return [spr_item_bombs, 0];
		case "quiver": return [spr_item_bow, 0];
		case "heart": return [spr_heart_container, 0];
		case "heart_piece": return [spr_heart_piece, 0];
		case "ore": return [spr_star_iron, 0];
		case "bun": return [spr_menu_bun, 1];
		case "refill": return [spr_pickup, PICKUP.MAGIC];
		case "money": return [spr_pickup, PICKUP.MONEY20];
		case "key": return [spr_key_small, 0];
		case "map": return [spr_dungeon_map, 0];
		case "compass": return [spr_dungeon_compass, 0];
		case "boss_key": return [spr_boss_key, 0];
	}
	return [-1, 0];


}
