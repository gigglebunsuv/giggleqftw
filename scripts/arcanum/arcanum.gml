//The Arcanum (rm_arcanum): the optional dungeon of the three magic rods, behind the old gate in the
//Northeastern Cliffs. All puzzles, no boss. rm_arcanum is built by dungeon_placeholders/make_arcanum_room.py
//(close GameMaker and re-run it after changing the layout); its puzzle pieces are in the puzzles script.
//
//The lobby has three stairways, each behind a seal (obj_rod_seal) that breaks once Link comes near it
//with what it asks for:
//	the Hall of Flame (the fire rod)		after the Southern Tower's boss
//	the Hall of Frost (the ice rod)		after the Bog Tower's boss, with the fire rod
//	the Hall of Storms (the lightning rod,	after the Tower of Ladhellin's boss, with the ice rod
//	and the magic upgrade at the very end)
//So the floors can only be done in order, and each floor's puzzles can use the rods before it.
//Loading a game saved in here starts in the lobby (the dungeon's entrance).

#macro DUNGEON_ARCANUM 5
#macro ARCANUM_START_X 512		//the lobby, inside the front door (printed by make_arcanum_room.py)
#macro ARCANUM_START_Y 680
#macro WORLD_ARCANUM_X 2800		//in front of the Arcanum's gate in the Northeastern Cliffs (rm_overworld)
#macro WORLD_ARCANUM_Y 154

///rod_seal_create();
function rod_seal_create() {
	//Run by obj_rod_seal's Create (after obj_npc's). Creation Code sets hall (1, 2 or 3).
	face_player = false;
	look_range = 0;
	facing = 0;
	hall = 1;
	dialogue = method(id, rod_seal_steps);
	image_speed = 0;


}

///rod_seal_flag();
function rod_seal_flag() {
	//Run by obj_rod_seal: the story flag set once it's broken
	return "arcanum_seal_" + string(hall);


}

///rod_seal_ready();
function rod_seal_ready() {
	//Run by obj_rod_seal: has Link got what it asks for?
	switch (hall) {
		case 1: return flag_get(boss_flag(1));
		case 2: return flag_get(boss_flag(2)) && global.item_have[ITEM.FIRE_ROD];
		case 3: return flag_get(boss_flag(3)) && global.item_have[ITEM.ICE_ROD];
	}
	return false;


}

///rod_seal_step();
function rod_seal_step() {
	//Run by obj_rod_seal: broken before? Breaks when Link comes close with what it asks for
	if (flag_get(rod_seal_flag())) {
		instance_destroy();
		return;
	}
	image_index = hall - 1;
	if (!instance_exists(obj_link) || instance_exists(obj_dialogue)) return;
	if (point_distance(x + 16, y + 8, obj_link.x, obj_link.y) > 40) return;
	if (!rod_seal_ready()) return;
	flag_set(rod_seal_flag(), true);
	sfx_play(SFX_SECRET);
	feel_shake(2, 10);
	instance_create_depth(x - 4, y - 8, depth - 1, obj_enemy_death);
	instance_create_depth(x + 12, y - 8, depth - 1, obj_enemy_death);
	instance_destroy();


}

///rod_seal_steps();
function rod_seal_steps() {
	//Run as obj_rod_seal's dialogue (bound to it): what it's waiting for
	var names = ["", "THE HALL OF FLAME", "THE HALL OF FROST", "THE HALL OF STORMS"];
	var line = "";
	switch (hall) {
		case 1: line = "IT WILL OPEN WHEN THE GARGOYLE OF THE SOUTHERN TOWER IS BEATEN."; break;
		case 2:
			line = "IT WILL OPEN FOR ONE WHO HAS BEATEN THE BOG TOWER'S GUARDIAN AND CARRIES THE FIRE ROD.";
			break;
		case 3:
			line = "IT WILL OPEN FOR ONE WHO HAS BEATEN THE SPHINX OF LADHELLIN AND CARRIES THE ICE ROD.";
			break;
	}
	return ["A SEAL OF OLD MAGIC BARS THE STAIRS TO " + names[clamp(hall, 1, 3)] + ".", line];


}

///arcanum_music();
function arcanum_music() {
	//Run by Menu_Arcanum when rm_arcanum starts
	audio_stop_all();
	options_volume_apply();
	audio_play_sound(ArcanumTheme, 1, true);
	global.world_music = ArcanumTheme;


}

///dungeon_start_arcanum(hall);
function dungeon_start_arcanum(argument0) {
	//Level select: Link starts in the Arcanum's lobby with what he'd have when that hall opens
	//(1: after the Southern Tower, 2: after the Bog Tower, 3: after the Tower of Ladhellin),
	//the seals before it already broken
	var h = argument0;
	global.pHealthMax = 6 + h * 2;
	global.pHealth = global.pHealthMax;
	global.pMagicMax = MAGIC_BASE;
	global.pMagic = global.pMagicMax;
	global.pMoney = 100 * h;
	global.swordTier = 1 + h;
	global.armorTier = (h >= 2) ? 2 : 1;
	for (var i = 0; i < ITEM.COUNT; i++) {item_take(i)}
	shield_set_tier(1);
	item_give(ITEM.LANTERN);
	item_give(ITEM.GRAPPLE);
	item_give(ITEM.BOOMERANG);
	item_give(ITEM.BOMBS);
	global.pBombs = global.pBombsMax;
	global.hasBoots = true;
	global.hasFlippers = true;
	global.hasGloves = (h >= 2);
	flag_set(boss_flag(1), true);
	if (h >= 2) {
		item_give(ITEM.BOW);
		global.pArrows = global.pArrowsMax;
		item_give(ITEM.FIRE_ROD);
		flag_set(boss_flag(2), true);
		flag_set("arcanum_seal_1", true);
	}
	if (h >= 3) {
		item_give(ITEM.HAMMER);
		item_give(ITEM.CAPE);
		item_give(ITEM.LENS);
		item_give(ITEM.ICE_ROD);
		flag_set(boss_flag(3), true);
		flag_set("arcanum_seal_2", true);
		flag_set(TRADE_FLAG, TRADE_DONE);
	}


}
