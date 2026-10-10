//The three save files (Zelda style). Each is a JSON file in the game's save area
//(%LOCALAPPDATA%\Giggle_DX__2_3_\save1.json, save2.json, save3.json).
//
//A file holds the player's name and everything that counts as progress: hearts, money, equipment,
//items, bottles, ammo, the Bun, story flags (chests opened, bosses beaten, doors...), dungeon keys,
//maps and compasses, and the play time and deaths (shown on the file select). Loading puts Link back
//at a safe spot, like A Link to the Past: the dungeon's entrance if he saved inside a dungeon,
//otherwise in front of his house. A brand new file starts in his bed, with the opening (see the
//cutscene script); a file saved before the opening was over plays it again.
//
//global.save_slot is the file being played (0-2), or -1 for games started from the DEBUG menu
//(they can't be saved). Saving: the pause screen's SAVE AND CONTINUE / SAVE AND QUIT, and SAVE AND
//QUIT on the game over screen.
//
//Adding something new that should be kept between sessions? Add it to save_collect, save_apply
//and save_reset_progress.

#macro SAVE_SLOTS 3
#macro SAVE_NAME_MAX 8			//letters in a player's name
#macro SAVE_VERSION 1
#macro SAVE_LOAD_HEARTS 3		//hearts Link has after loading, if he saved with fewer
#macro SAVE_DEFAULT_NAME "GIGGLE"	//the name used if the player ends name entry with nothing typed

global.save_slot = -1;
global.player_name = "";
global.playTime = 0;	//seconds played on this file (obj_link counts them)
global.deaths = 0;		//times Link has died on this file (obj_player_death counts them)

///save_file_name(slot);
function save_file_name(argument0) {
	return "save" + string(argument0 + 1) + ".json";


}

///save_read(slot);
function save_read(argument0) {
	//The file's contents as a struct, or undefined if there's no file (or it can't be read)
	var fname = save_file_name(argument0);
	if (!file_exists(fname)) return undefined;
	var buf = buffer_load(fname);
	if (buf == -1) return undefined;
	var text = buffer_read(buf, buffer_string);
	buffer_delete(buf);
	var data = undefined;
	try {
		data = json_parse(text);
	} catch (e) {
		data = undefined;
	}
	if (!is_struct(data)) return undefined;
	return data;


}

///save_summary(slot);
function save_summary(argument0) {
	//What the file select shows for a slot: {used, name, hearts, bun (array of 3 true/false),
	//sword (tier, 0 = none yet), time (seconds played), deaths, cleared (the Evil King beaten)}
	var data = save_read(argument0);
	var s = {used: false, name: "", hearts: 0, bun: array_create(BUN_PIECES, false), sword: 0, time: 0, deaths: 0, cleared: false,
		hero: false, hero_clear: false, echoes: false, done: 0};
	if (data == undefined) return s;
	s.used = true;
	s.name = save_get(data, "name", "");
	s.hearts = ceil(save_get(data, "health_max", 6) / 2);
	s.bun = save_array_fit(save_get(data, "bun", []), BUN_PIECES, false);
	s.sword = save_get(data, "sword", 0);
	s.time = save_get(data, "play_time", 0);
	s.deaths = save_get(data, "deaths", 0);
	var flags = save_get(data, "flags", {});
	if (is_struct(flags)) {
		s.cleared = save_get(flags, GAME_CLEAR_FLAG, false);
		s.hero = save_get(flags, HERO_FLAG, false);
		s.hero_clear = save_get(flags, HERO_CLEAR_FLAG, false);
		s.echoes = save_get(flags, ECHOES_FLAG, false);
	}
	s.done = completion_percent(data);
	return s;


}

///save_get(struct, key, default);
function save_get(argument0, argument1, argument2) {
	//A value from a loaded file, or the default if it isn't there (older files)
	if (!variable_struct_exists(argument0, argument1)) return argument2;
	var v = variable_struct_get(argument0, argument1);
	if (is_undefined(v)) return argument2;
	return v;


}

///save_array_fit(array, length, default);
function save_array_fit(argument0, argument1, argument2) {
	//A copy of the array, exactly length long (padded with default), so files from before
	//something new was added still load
	var out = array_create(argument1, argument2);
	if (!is_array(argument0)) return out;
	var n = min(array_length(argument0), argument1);
	for (var i = 0; i < n; i++) {out[i] = argument0[i]}
	return out;


}

///save_collect();
function save_collect() {
	//Everything that's saved, as a struct (written out as JSON by save_write)
	//This dungeon's small keys live in global.pKeys while Link is in it: put them back in the list
	var keys = save_array_fit(global.dungeonKeys, DUNGEON_COUNT, 0);
	keys[global.dungeon] = global.pKeys;
	var ore = 0;
	if (variable_global_exists("swordOre")) {ore = global.swordOre}
	return {
		version: SAVE_VERSION,
		name: global.player_name,
		dungeon: global.dungeon,			//where he was: a dungeon number, 0 = outside
		health: global.pHealth,
		health_max: global.pHealthMax,
		magic: global.pMagic,
		magic_max: global.pMagicMax,
		money: global.pMoney,
		bombs: global.pBombs,
		bombs_max: global.pBombsMax,
		bomb_level: global.bombLevel,
		arrows: global.pArrows,
		arrows_max: global.pArrowsMax,
		arrow_level: global.arrowLevel,
		item_have: save_array_fit(global.item_have, ITEM.COUNT, false),
		item_a: global.itemA,
		item_y: global.itemY,
		item_x: global.itemX,
		bottles: save_array_fit(global.bottles, array_length(global.bottles), BOTTLE.EMPTY),
		sword: global.swordTier,
		shield: global.shieldTier,
		armor: global.armorTier,
		sword_ore: ore,
		boots: global.hasBoots,
		gloves: global.hasGloves,
		flippers: global.hasFlippers,
		bun: save_array_fit(global.bunPieces, BUN_PIECES, false),
		heart_pieces: global.heartPieces,
		dungeon_keys: keys,
		boss_key: save_array_fit(global.bossKey, DUNGEON_COUNT, false),
		dungeon_map: save_array_fit(global.dungeonMap, DUNGEON_COUNT, false),
		dungeon_compass: save_array_fit(global.dungeonCompass, DUNGEON_COUNT, false),
		flags: global.flags,
		play_time: floor(global.playTime),
		deaths: global.deaths
	};


}

///save_write(slot);
function save_write(argument0) {
	//Writes the game in progress to this file. Returns true if it worked.
	var text = json_stringify(save_collect());
	var buf = buffer_create(string_byte_length(text) + 1, buffer_fixed, 1);
	buffer_write(buf, buffer_string, text);
	buffer_save(buf, save_file_name(argument0));
	buffer_delete(buf);
	return file_exists(save_file_name(argument0));


}

///save_current_game();
function save_current_game() {
	//Saves to the file being played. False if this game has no file (started from DEBUG).
	if (global.save_slot < 0) return false;
	return save_write(global.save_slot);


}

///save_erase(slot);
function save_erase(argument0) {
	var fname = save_file_name(argument0);
	if (file_exists(fname)) {file_delete(fname)}


}

///save_reset_progress();
function save_reset_progress() {
	//Back to a brand new game's state (the same as obj_link's Create and world_start_new_game),
	//so nothing from a game played earlier this session carries over
	global.pHealthMax = 6;
	global.pHealth = 6;
	global.pMagicMax = MAGIC_BASE;
	global.pMagic = global.pMagicMax;
	global.pMoney = 0;
	global.pKeys = 0;
	global.pBombs = 0;
	global.pBombsMax = 8;
	global.bombLevel = 0;
	global.pArrows = 0;
	global.pArrowsMax = 20;
	global.arrowLevel = 0;
	global.item_have = array_create(ITEM.COUNT, false);
	global.itemA = ITEM.NONE;
	global.itemY = ITEM.NONE;
	global.itemX = ITEM.NONE;
	global.bottles = array_create(array_length(global.bottles), BOTTLE.EMPTY);
	global.swordTier = 0;
	global.shieldTier = 0;
	global.armorTier = 1;
	global.swordOre = 0;
	global.hasBoots = false;
	global.hasGloves = false;
	global.hasFlippers = false;
	global.bunPieces = array_create(BUN_PIECES, false);
	global.heartPieces = 0;
	global.flags = {};
	global.playTime = 0;
	global.deaths = 0;
	//A Hall of Echoes rush left running (quit mid-rush: game_restart keeps globals) is over
	global.rush_stage = 0;
	with (obj_echo_rush) {instance_destroy()}
	//...and so is anything the ending or the opening left on (the HUD hidden after the credits)
	global.hud_hidden = false;
	global.cutscene_on = false;
	global.cutscene_skip = false;
	dungeon_init();


}

///save_apply(data);
function save_apply(argument0) {
	//Puts a loaded file's progress into the game (call save_reset_progress first)
	var d = argument0;
	global.player_name = save_get(d, "name", SAVE_DEFAULT_NAME);
	global.pHealthMax = save_get(d, "health_max", 6);
	global.pHealth = clamp(max(save_get(d, "health", 6), SAVE_LOAD_HEARTS * 2), 1, global.pHealthMax);
	global.pMagicMax = save_get(d, "magic_max", 32);
	global.pMagic = clamp(save_get(d, "magic", global.pMagicMax), 0, global.pMagicMax);
	global.pMoney = save_get(d, "money", 0);
	global.pBombsMax = save_get(d, "bombs_max", 8);
	global.pBombs = save_get(d, "bombs", 0);
	global.bombLevel = save_get(d, "bomb_level", 0);
	global.pArrowsMax = save_get(d, "arrows_max", 20);
	global.pArrows = save_get(d, "arrows", 0);
	global.arrowLevel = save_get(d, "arrow_level", 0);
	global.item_have = save_array_fit(save_get(d, "item_have", []), ITEM.COUNT, false);
	global.itemA = save_get(d, "item_a", ITEM.NONE);
	global.itemY = save_get(d, "item_y", ITEM.NONE);
	global.itemX = save_get(d, "item_x", ITEM.NONE);
	global.bottles = save_array_fit(save_get(d, "bottles", []), array_length(global.bottles), BOTTLE.EMPTY);
	global.swordTier = save_get(d, "sword", 0);
	global.shieldTier = save_get(d, "shield", 0);
	global.armorTier = save_get(d, "armor", 1);
	global.swordOre = save_get(d, "sword_ore", 0);
	global.hasBoots = save_get(d, "boots", false);
	global.hasGloves = save_get(d, "gloves", false);
	global.hasFlippers = save_get(d, "flippers", false);
	global.bunPieces = save_array_fit(save_get(d, "bun", []), BUN_PIECES, false);
	global.heartPieces = save_get(d, "heart_pieces", 0);
	global.dungeonKeys = save_array_fit(save_get(d, "dungeon_keys", []), DUNGEON_COUNT, 0);
	global.bossKey = save_array_fit(save_get(d, "boss_key", []), DUNGEON_COUNT, false);
	global.dungeonMap = save_array_fit(save_get(d, "dungeon_map", []), DUNGEON_COUNT, false);
	global.dungeonCompass = save_array_fit(save_get(d, "dungeon_compass", []), DUNGEON_COUNT, false);
	var flags = save_get(d, "flags", {});
	if (!is_struct(flags)) {flags = {}}
	global.flags = flags;
	global.playTime = save_get(d, "play_time", 0);
	global.deaths = save_get(d, "deaths", 0);
	//Outside every dungeon for now: walking into one swaps its keys in (dungeon_room_start)
	global.dungeon = 0;
	global.pKeys = global.dungeonKeys[0];


}

///save_respawn(dungeon);
function save_respawn(argument0) {
	//Where a loaded game starts: [room, x, y]. Inside a dungeon: its entrance.
	//Anywhere else: in front of Link's house.
	if (argument0 > 0) {
		var e = dungeon_entrance(argument0);
		if (e[0] != noone) return e;
	}
	return [rm_overworld, WORLD_START_X, WORLD_START_Y];


}

///save_start_link(x, y);
function save_start_link(argument0, argument1) {
	//Makes Link (persistent) if he isn't there yet and puts him here
	if (!instance_exists(obj_link)) {instance_create_depth(argument0, argument1, 0, obj_link)}
	obj_link.x = argument0;
	obj_link.y = argument1;


}

///save_new_game(slot, name, hero);
function save_new_game(argument0, argument1, argument2) {
	//PLAY on an empty file: a brand new game with this name, saved straight away,
	//starting in Link's bed with the opening (see the cutscene script). hero: a Hero Mode file.
	save_start_link(HOME_GETUP_X, HOME_GETUP_Y);
	save_reset_progress();
	world_start_new_game();
	if (argument2 == true) {flag_set(HERO_FLAG, true)}
	global.player_name = argument1;
	global.save_slot = argument0;
	save_write(argument0);
	global.pause_block = true;	//so Link ignores the button that started the game
	global.intro_pending = true;
	room_goto(rm_interiors);


}

///save_load_game(slot);
function save_load_game(argument0) {
	//PLAY on a used file: load it and start at the safe spot (see save_respawn)
	var data = save_read(argument0);
	if (data == undefined) return false;
	//Make Link first: his Create event sets up a fresh game's gear (sword, bow, flute, 3 hearts),
	//which would wipe out the file's progress if he were made after it was loaded
	save_start_link(0, 0);
	save_reset_progress();
	save_apply(data);
	var at = save_respawn(save_get(data, "dungeon", 0));
	//Saved before the opening was over (quit during it): back in bed, and it plays again
	if (!flag_get(INTRO_FLAG)) {
		at = [rm_interiors, HOME_GETUP_X, HOME_GETUP_Y];
		global.intro_pending = true;
	}
	save_start_link(at[1], at[2]);
	global.save_slot = argument0;
	global.pause_block = true;
	room_goto(at[0]);
	return true;


}

///save_debug_game();
function save_debug_game() {
	//Games started from the DEBUG menu have no file
	global.save_slot = -1;
	global.player_name = "";


}
