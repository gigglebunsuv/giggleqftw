//The debug menu: F1 (keyboard) or Select / Back (gamepad) while walking around, or while paused.
//It's obj_pause_menu with debug = true (the game is frozen the same way), so it works anywhere the
//pause screen does. Set DEBUG_MENU to false for a release build.
//	LB RB / [ ]		switch pages (CHEATS, PLAYER, EQUIPMENT, ITEMS, DUNGEONS, SIDE QUESTS, FLAGS, WARP)
//	up / down		pick a row
//	left / right	change it (numbers, on/off, choices)
//	A				toggle it, or do it (the rows with no value on the right)
//	Y / X			change a number by 10 at a time
//	B, Start, F1	back to the game
//Each row is [label, kind, id, arg]: kind is "head" (a heading, skipped), "bool", "num", "choice",
//"act" (A does it), "warp" (A goes there: arg is [room, x, y]) or "info" (shown, not changed).
//debug_get / debug_put read and change a row's value by its id; debug_num_range gives a number's limits.

#macro DEBUG_MENU false	//dungeon demo: no debug menu
#macro DEBUG_PAGES 8
#macro DEBUG_ROWS_SHOWN 14

//The cheats, kept for the whole session (see obj_link's Step, player_move, enemy_hurt)
global.debug_menu_request = false;	//obj_link sets it just before making obj_pause_menu: open on the debug menu
global.dbg_god = false;			//health stays full
global.dbg_magic = false;		//magic stays full
global.dbg_ammo = false;		//bombs and arrows stay full
global.dbg_money = false;		//money stays full
global.dbg_onehit = false;		//every hit kills (not armoured bosses)
global.dbg_noclip = false;		//walk through walls, over pits
global.dbg_speed = 1;			//times walking speed
global.dbg_hitboxes = false;	//outlines every instance's collision box

///debug_page_name(page);
function debug_page_name(argument0) {
	switch (argument0) {
		case 0: return "CHEATS";
		case 1: return "PLAYER";
		case 2: return "EQUIPMENT";
		case 3: return "ITEMS";
		case 4: return "DUNGEONS";
		case 5: return "SIDE QUESTS";
		case 6: return "FLAGS";
		case 7: return "WARP";
	}
	return "";


}

///debug_dungeon_name(dungeon);
function debug_dungeon_name(argument0) {
	switch (argument0) {
		case 1: return "SOUTHERN TOWER";
		case 2: return "BOG TOWER";
		case 3: return "TOWER OF LADHELLIN";
		case 4: return "CASTLE OF BUNSRIEL";
		case 5: return "THE ARCANUM";
	}
	return "";


}

///debug_warp_statues();
function debug_warp_statues() {
	//The warp statues out in the world (their spot_name, see make_overworld_room.py)
	return ["VILLAGE", "WEST FIELDS", "SOUTHERN FIELDS", "SOUTH ROAD", "FOREST", "CASTLE TOWN",
		"MARSHLANDS", "DESERT", "NE CLIFFS", "ARCANUM"];


}

///debug_text(string);
function debug_text(argument0) {
	//Capitals, and anything the menu font doesn't have as a space
	var s = string_upper(argument0);
	var ok = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/";
	var out = "";
	for (var i = 1; i <= string_length(s); i++) {
		var c = string_char_at(s, i);
		out += (string_pos(c, ok) > 0) ? c : " ";
	}
	return out;


}

///debug_rows(page);
function debug_rows(argument0) {
	var r = [];
	switch (argument0) {
		case 0:
			array_push(r, ["GOD MODE", "bool", "god", 0]);
			array_push(r, ["INFINITE MAGIC", "bool", "inf_magic", 0]);
			array_push(r, ["INFINITE BOMBS ARROWS", "bool", "inf_ammo", 0]);
			array_push(r, ["INFINITE MONEY", "bool", "inf_money", 0]);
			array_push(r, ["ONE HIT KILLS", "bool", "onehit", 0]);
			array_push(r, ["NO CLIP", "bool", "noclip", 0]);
			array_push(r, ["WALK SPEED", "num", "speed", 0]);
			array_push(r, ["SHOW HITBOXES", "bool", "hitboxes", 0]);
			array_push(r, ["", "head", "", 0]);
			array_push(r, ["FILL HEALTH AND MAGIC", "act", "fill", 0]);
			array_push(r, ["TAKE HALF A HEART", "act", "hurt", 0]);
			array_push(r, ["KILL ENEMIES HERE", "act", "kill", 0]);
			array_push(r, ["GET EVERYTHING", "act", "everything", 0]);
			break;
		case 1:
			array_push(r, ["HEARTS", "num", "hearts", 0]);
			array_push(r, ["HEALTH - HALVES", "num", "health", 0]);
			array_push(r, ["MAGIC UPGRADE", "bool", "magic_up", 0]);
			array_push(r, ["MAGIC", "num", "magic", 0]);
			array_push(r, ["MONEY", "num", "money", 0]);
			array_push(r, ["SMALL KEYS HERE", "num", "keys", 0]);
			array_push(r, ["BOMB BAG", "num", "bomb_level", 0]);
			array_push(r, ["BOMBS", "num", "bombs", 0]);
			array_push(r, ["QUIVER", "num", "arrow_level", 0]);
			array_push(r, ["ARROWS", "num", "arrows", 0]);
			array_push(r, ["STAR IRON", "num", "ore", 0]);
			array_push(r, ["DEATHS", "num", "deaths", 0]);
			break;
		case 2:
			array_push(r, ["SWORD", "num", "sword", 0]);
			array_push(r, ["SHIELD", "num", "shield", 0]);
			array_push(r, ["ARMOR", "num", "armor", 0]);
			array_push(r, ["RUNNING BOOTS", "bool", "boots", 0]);
			array_push(r, ["STRENGTH GLOVES", "bool", "gloves", 0]);
			array_push(r, ["FLIPPERS", "bool", "flippers", 0]);
			array_push(r, ["BUN PIECES", "num", "bun", 0]);
			array_push(r, ["BUNNY TUNIC", "choice", "tunic", 0]);
			array_push(r, ["ECHO CHARM", "bool", "flag", ECHO_CHARM_FLAG]);
			array_push(r, ["KNIGHT'S MEDAL", "bool", "flag", QUEST_MEDAL_FLAG]);
			break;
		case 3:
			for (var i = 0; i < ITEM.COUNT; i++) {
				if (i >= ITEM.BOTTLE_1 && i <= ITEM.BOTTLE_5) continue;
				var nm = item_get_name(i);
				if (i == ITEM.SHIELD) {nm = "SHIELD ITEM"}
				array_push(r, [nm, "bool", "item", i]);
			}
			for (var i = 0; i < BOTTLES; i++) {
				array_push(r, ["BOTTLE " + string(i + 1), "choice", "bottle", i]);
			}
			array_push(r, ["", "head", "", 0]);
			array_push(r, ["GET EVERY ITEM", "act", "all_items", 0]);
			array_push(r, ["TAKE EVERY ITEM", "act", "no_items", 0]);
			break;
		case 4:
			for (var d = 1; d < DUNGEON_COUNT; d++) {
				array_push(r, [debug_dungeon_name(d), "head", "", 0]);
				array_push(r, ["  BOSS BEATEN", "bool", "flag", boss_flag(d)]);
				array_push(r, ["  BOSS KEY", "bool", "boss_key", d]);
				array_push(r, ["  MAP", "bool", "map", d]);
				array_push(r, ["  COMPASS", "bool", "compass", d]);
				array_push(r, ["  SMALL KEYS", "num", "dkeys", d]);
			}
			array_push(r, ["THE END", "head", "", 0]);
			array_push(r, ["  GAME CLEAR", "bool", "flag", GAME_CLEAR_FLAG]);
			array_push(r, ["  HERO MODE CLEAR", "bool", "flag", HERO_CLEAR_FLAG]);
			break;
		case 5:
			array_push(r, ["BUNLINGS FOUND", "num", "bunlings", 0]);
			array_push(r, ["  5 REWARD GIVEN", "bool", "flag", "bunreward_5"]);
			array_push(r, ["  10 REWARD GIVEN", "bool", "flag", "bunreward_10"]);
			array_push(r, ["  15 REWARD GIVEN", "bool", "flag", "bunreward_15"]);
			array_push(r, ["BUNNY TUNIC", "choice", "tunic", 0]);
			array_push(r, ["WARP STATUES AWAKE", "num", "statues", 0]);
			array_push(r, ["HALL OF ECHOES CLEAR", "bool", "flag", ECHOES_FLAG]);
			array_push(r, ["ECHO CHARM", "bool", "flag", ECHO_CHARM_FLAG]);
			array_push(r, ["HERO MODE", "bool", "flag", HERO_FLAG]);
			array_push(r, ["GALLERY WON", "bool", "flag", GALLERY_FLAG]);
			array_push(r, ["FISHING LEGEND", "bool", "flag", FISHING_FLAG]);
			array_push(r, ["HAMMER TRADE STEP", "num", "trade", 0]);
			array_push(r, ["FISHER'S ROCK LIFTED", "bool", "flag", TRADE_ROCK_FLAG]);
			array_push(r, ["KNIGHT'S MEDAL", "bool", "flag", QUEST_MEDAL_FLAG]);
			array_push(r, ["CAT BACK HOME", "bool", "flag", CAT_HOME_FLAG]);
			array_push(r, ["CAT REWARD GIVEN", "bool", "flag", CAT_REWARD_FLAG]);
			array_push(r, ["OPENING SEEN", "bool", "flag", INTRO_FLAG]);
			break;
		case 6:
			//Every story flag set so far (a flag that was never set isn't in the list yet)
			var names = variable_struct_get_names(global.flags);
			array_sort(names, true);
			if (array_length(names) == 0) {array_push(r, ["NO FLAGS SET YET", "head", "", 0])}
			for (var i = 0; i < array_length(names); i++) {
				var v = global.flags[$ names[i]];
				var kind = "info";
				if (is_bool(v)) {kind = "bool"}
				else if (is_real(v)) {kind = "num"}
				array_push(r, [debug_text(names[i]), kind, "flag", names[i]]);
			}
			break;
		case 7:
			array_push(r, ["LINK'S HOUSE", "warp", "", [rm_interiors, HOME_GETUP_X, HOME_GETUP_Y]]);
			array_push(r, ["OVERWORLD", "warp", "", [rm_overworld, WORLD_START_X, WORLD_START_Y]]);
			array_push(r, ["SOUTHERN TOWER", "warp", "", [rm_southern_tower, TOWER_START_X, TOWER_START_Y]]);
			array_push(r, ["BOG TOWER", "warp", "", [rm_bog_tower, BOG_START_X, BOG_START_Y]]);
			array_push(r, ["TOWER OF LADHELLIN", "warp", "", [rm_ladhellin_tower, LADHELLIN_START_X, LADHELLIN_START_Y]]);
			array_push(r, ["CASTLE OF BUNSRIEL", "warp", "", [rm_castle, CASTLE_START_X, CASTLE_START_Y]]);
			array_push(r, ["THE ARCANUM", "warp", "", [rm_arcanum, ARCANUM_START_X, ARCANUM_START_Y]]);
			array_push(r, ["HALL OF ECHOES", "warp", "", [rm_interiors, ECHOES_X, ECHOES_Y]]);
			array_push(r, ["TEST DUNGEON", "warp", "", [rm_test_dungeon, 384, 640]]);
			array_push(r, ["DEBUG ROOM", "warp", "", [rm_debug, DEBUG_START_X, DEBUG_START_Y]]);
			array_push(r, ["ITEM TEST ROOM", "warp", "", [rm_item_test, 264, 184]]);
			array_push(r, ["HAVEN", "warp", "", [rm_haven, 792, 840]]);
			break;
	}
	return r;


}

///debug_num_range(id, arg);
function debug_num_range(argument0, argument1) {
	//[lowest, highest, step] for a "num" row
	switch (argument0) {
		case "speed": return [1, 4, 1];
		case "hearts": return [1, PLAYER_HEARTS_MAX, 1];
		case "health": return [1, global.pHealthMax, 1];
		case "magic": return [0, global.pMagicMax, 4];
		case "money": return [0, global.pMoneyMax, 10];
		case "keys": return [0, global.pKeysMax, 1];
		case "dkeys": return [0, global.pKeysMax, 1];
		case "bomb_level": return [0, 3, 1];
		case "bombs": return [0, global.pBombsMax, 1];
		case "arrow_level": return [0, 3, 1];
		case "arrows": return [0, global.pArrowsMax, 1];
		case "ore": return [0, 9, 1];
		case "deaths": return [0, 999, 1];
		case "sword": return [0, SWORD_TIER_MAX, 1];
		case "shield": return [0, SHIELD_TIER_MAX, 1];
		case "armor": return [1, ARMOR_TIER_MAX, 1];
		case "bun": return [0, BUN_PIECES, 1];
		case "bunlings": return [0, BUNLINGS_TOTAL, 1];
		case "statues": return [0, array_length(debug_warp_statues()), 1];
		case "trade": return [0, TRADE_DONE, 1];
	}
	return [0, 999, 1];


}

///debug_choice_names(id);
function debug_choice_names(argument0) {
	//The names of a "choice" row's values (0, 1, 2...)
	switch (argument0) {
		case "tunic": return ["NO", "HAVE IT", "WEARING"];
		case "bottle": return ["NO BOTTLE", "EMPTY", "RED POTION", "GREEN POTION", "BLUE POTION", "FAIRY"];
	}
	return [""];


}

///debug_get(id, arg);
function debug_get(argument0, argument1) {
	var a = argument1;
	switch (argument0) {
		case "god": return global.dbg_god;
		case "inf_magic": return global.dbg_magic;
		case "inf_ammo": return global.dbg_ammo;
		case "inf_money": return global.dbg_money;
		case "onehit": return global.dbg_onehit;
		case "noclip": return global.dbg_noclip;
		case "speed": return global.dbg_speed;
		case "hitboxes": return global.dbg_hitboxes;
		case "hearts": return global.pHealthMax div 2;
		case "health": return global.pHealth;
		case "magic_up": return magic_upgraded();
		case "magic": return global.pMagic;
		case "money": return global.pMoney;
		case "keys": return global.pKeys;
		case "bomb_level": return global.bombLevel;
		case "bombs": return global.pBombs;
		case "arrow_level": return global.arrowLevel;
		case "arrows": return global.pArrows;
		case "ore": return global.swordOre;
		case "deaths": return global.deaths;
		case "sword": return global.swordTier;
		case "shield": return global.shieldTier;
		case "armor": return global.armorTier;
		case "boots": return global.hasBoots;
		case "gloves": return global.hasGloves;
		case "flippers": return global.hasFlippers;
		case "bun": return bun_count();
		case "tunic": return flag_get(TUNIC_FLAG) ? (flag_get(TUNIC_ON_FLAG) ? 2 : 1) : 0;
		case "item": return global.item_have[a];
		case "bottle": return global.item_have[ITEM.BOTTLE_1 + a] ? global.bottles[a] + 1 : 0;
		case "boss_key": return global.bossKey[a];
		case "map": return global.dungeonMap[a];
		case "compass": return global.dungeonCompass[a];
		case "dkeys": return (a == global.dungeon) ? global.pKeys : global.dungeonKeys[a];
		case "bunlings": return bunlings_found();
		case "statues":
			var s = debug_warp_statues();
			var n = 0;
			for (var i = 0; i < array_length(s); i++) {
				if (flag_get("warp_statue_" + s[i])) {n++}
			}
			return n;
		case "trade":
			var t = flag_get(TRADE_FLAG);
			return is_real(t) ? t : 0;
		case "flag": return flag_get(a);
	}
	return 0;


}

///debug_put(id, arg, value);
function debug_put(argument0, argument1, argument2) {
	var a = argument1;
	var v = argument2;
	switch (argument0) {
		case "god": global.dbg_god = v; break;
		case "inf_magic": global.dbg_magic = v; break;
		case "inf_ammo": global.dbg_ammo = v; break;
		case "inf_money": global.dbg_money = v; break;
		case "onehit": global.dbg_onehit = v; break;
		case "noclip": global.dbg_noclip = v; break;
		case "speed": global.dbg_speed = v; break;
		case "hitboxes": global.dbg_hitboxes = v; break;
		case "hearts":
			global.pHealthMax = v * 2;
			global.pHealth = min(global.pHealth, global.pHealthMax);
			break;
		case "health": global.pHealth = v; break;
		case "magic_up":
			global.pMagicMax = v ? MAGIC_UPGRADED : MAGIC_BASE;
			global.pMagic = global.pMagicMax;
			break;
		case "magic": global.pMagic = v; break;
		case "money": global.pMoney = v; break;
		case "keys": global.pKeys = v; break;
		case "bomb_level":
			var bag = [8, 16, 64, 99];		//as player_upgrade_bombs
			global.bombLevel = v;
			global.pBombsMax = bag[v];
			global.pBombs = min(global.pBombs, global.pBombsMax);
			break;
		case "bombs": global.pBombs = v; break;
		case "arrow_level":
			var quiver = [20, 40, 80, 99];	//as player_upgrade_arrows
			global.arrowLevel = v;
			global.pArrowsMax = quiver[v];
			global.pArrows = min(global.pArrows, global.pArrowsMax);
			break;
		case "arrows": global.pArrows = v; break;
		case "ore": global.swordOre = v; break;
		case "deaths": global.deaths = v; break;
		case "sword": global.swordTier = v; break;
		case "shield": shield_set_tier(v); break;
		case "armor": global.armorTier = v; break;
		case "boots": global.hasBoots = v; break;
		case "gloves": global.hasGloves = v; break;
		case "flippers": global.hasFlippers = v; break;
		case "bun":
			for (var i = 0; i < BUN_PIECES; i++) {global.bunPieces[i] = (i < v)}
			break;
		case "tunic":
			flag_set(TUNIC_FLAG, v > 0);
			flag_set(TUNIC_ON_FLAG, v == 2);
			break;
		case "item":
			if (v) {item_give(a)}
			else {item_take(a)}
			break;
		case "bottle":
			if (v == 0) {item_take(ITEM.BOTTLE_1 + a)}
			else {
				item_give(ITEM.BOTTLE_1 + a);
				global.bottles[a] = v - 1;
			}
			break;
		case "boss_key": global.bossKey[a] = v; break;
		case "map": global.dungeonMap[a] = v; break;
		case "compass": global.dungeonCompass[a] = v; break;
		case "dkeys":
			if (a == global.dungeon) {global.pKeys = v}
			else {global.dungeonKeys[a] = v}
			break;
		case "bunlings":
			//The first v of them found, the rest lost again (the room shows them again after a reload)
			var ids = bunling_ids();
			for (var i = 0; i < array_length(ids); i++) {flag_set(bunling_flag(ids[i]), i < v)}
			flag_set("bunlings_found", v);
			break;
		case "statues":
			var s = debug_warp_statues();
			for (var i = 0; i < array_length(s); i++) {flag_set("warp_statue_" + s[i], i < v)}
			break;
		case "trade": flag_set(TRADE_FLAG, v); break;
		case "flag": flag_set(a, v); break;
	}


}

///debug_act(id);
function debug_act(argument0) {
	//The "act" rows. Ones that touch the room (enemies) close the menu first, so everything is
	//active again. Returns true if the menu was closed.
	switch (argument0) {
		case "fill":
			global.pHealth = global.pHealthMax;
			global.pMagic = global.pMagicMax;
			break;
		case "hurt":
			player_add_health(-1);
			break;
		case "kill":
			pause_close();
			with (obj_enemy) {
				if (!is_boss) {
					instance_create_depth(x, y, depth - 1, obj_enemy_death);
					instance_destroy();
				}
			}
			return true;
		case "all_items":
			for (var i = 0; i < ITEM.COUNT; i++) {
				if (i < ITEM.BOTTLE_1 || i > ITEM.BOTTLE_5) {item_give(i)}
			}
			break;
		case "no_items":
			for (var i = 0; i < ITEM.COUNT; i++) {item_take(i)}
			break;
		case "everything":
			//Every item, full bottles, the best equipment, the biggest bags, full everything
			for (var i = 0; i < ITEM.COUNT; i++) {item_give(i)}
			global.bottles = [BOTTLE.RED, BOTTLE.GREEN, BOTTLE.BLUE, BOTTLE.FAIRY, BOTTLE.EMPTY];
			global.swordTier = SWORD_TIER_MAX;
			shield_set_tier(SHIELD_TIER_MAX);
			global.armorTier = ARMOR_TIER_MAX;
			global.hasBoots = true;
			global.hasGloves = true;
			global.hasFlippers = true;
			debug_put("bomb_level", 0, 3);
			debug_put("arrow_level", 0, 3);
			global.pHealthMax = PLAYER_HEARTS_MAX * 2;
			global.pMagicMax = MAGIC_UPGRADED;
			global.pHealth = global.pHealthMax;
			global.pMagic = global.pMagicMax;
			global.pBombs = global.pBombsMax;
			global.pArrows = global.pArrowsMax;
			global.pMoney = global.pMoneyMax;
			break;
	}
	return false;


}

///debug_menu_open();
function debug_menu_open() {
	//Run by obj_pause_menu (its Create, or F1 / Select while paused)
	debug = true;
	dbg_page = 0;
	dbg_cursor = 0;
	dbg_top = 0;	//first row shown
	dbg_rows = debug_rows(dbg_page);
	dbg_cursor = debug_next_row(-1, 1);


}

///debug_next_row(from, step);
function debug_next_row(argument0, argument1) {
	//The next row from 'from' going 'step' (1 or -1) that can be picked (not a heading), wrapping round
	var n = array_length(dbg_rows);
	if (n == 0) return 0;
	var i = argument0;
	repeat (n) {
		i = (i + argument1 + n) mod n;
		if (dbg_rows[i][1] != "head") return i;
	}
	return 0;


}

///debug_menu_step();
function debug_menu_step() {
	//Run by obj_pause_menu's Step while debug is on
	if (act_start || act_b || act_debug) {
		pause_close();
		return;
	}

	//Pages
	if (menu_page != 0) {
		dbg_page = (dbg_page + menu_page + DEBUG_PAGES) mod DEBUG_PAGES;
		dbg_rows = debug_rows(dbg_page);
		dbg_top = 0;
		dbg_cursor = debug_next_row(-1, 1);
		audio_play_sound(menu_switch, 2, false);
		return;
	}
	dbg_rows = debug_rows(dbg_page);	//names and flags change as things are set
	if (array_length(dbg_rows) == 0) return;
	dbg_cursor = min(dbg_cursor, array_length(dbg_rows) - 1);

	//Rows (the list scrolls to keep the cursor in view)
	if (menu_move != 0) {
		dbg_cursor = debug_next_row(dbg_cursor, menu_move);
		audio_play_sound(menu_switch, 2, false);
	}
	if (dbg_cursor < dbg_top) {dbg_top = dbg_cursor}
	if (dbg_cursor >= dbg_top + DEBUG_ROWS_SHOWN) {dbg_top = dbg_cursor - DEBUG_ROWS_SHOWN + 1}
	if (dbg_top > 0 && dbg_rows[dbg_top - 1][1] == "head" && dbg_cursor - (dbg_top - 1) < DEBUG_ROWS_SHOWN) {dbg_top--}

	var row = dbg_rows[dbg_cursor];
	var kind = row[1];
	var rid = row[2];
	var arg = row[3];
	var changed = false;
	switch (kind) {
		case "bool":
			if (act_a || menu_move_h != 0) {
				debug_put(rid, arg, !debug_get(rid, arg));
				changed = true;
			}
			break;
		case "num":
			var delta = menu_move_h;
			if (act_x) {delta = 10}
			if (act_y) {delta = -10}
			if (delta != 0) {
				var lim = debug_num_range(rid, arg);
				var v = debug_get(rid, arg);
				if (!is_real(v)) {v = 0}
				var nv = clamp(v + delta * lim[2], lim[0], lim[1]);
				if (nv != v) {
					debug_put(rid, arg, nv);
					changed = true;
				}
			}
			break;
		case "choice":
			var step = menu_move_h;
			if (act_a) {step = 1}
			if (step != 0) {
				var n = array_length(debug_choice_names(rid));
				debug_put(rid, arg, (debug_get(rid, arg) + step + n) mod n);
				changed = true;
			}
			break;
		case "act":
			if (act_a) {
				audio_play_sound(menu_select, 3, false);
				debug_act(rid);
				return;
			}
			break;
		case "warp":
			if (act_a) {
				audio_play_sound(menu_select, 3, false);
				pause_close();
				room_fade_start(arg[0], arg[1], arg[2], false);
				return;
			}
			break;
	}
	if (changed) {audio_play_sound(menu_select, 3, false)}


}

///debug_value_text(row);
function debug_value_text(argument0) {
	//What a row shows on the right
	var row = argument0;
	switch (row[1]) {
		case "bool": return debug_get(row[2], row[3]) ? "ON" : "OFF";
		case "num":
			var v = debug_get(row[2], row[3]);
			return is_real(v) ? string(v) : "0";
		case "choice":
			var c = debug_choice_names(row[2]);
			var i = clamp(debug_get(row[2], row[3]), 0, array_length(c) - 1);
			return c[i];
		case "act":
		case "warp": return "";	//nothing to show: A does it
		case "info": return debug_text(string(debug_get(row[2], row[3])));
	}
	return "";


}

///debug_menu_draw();
function debug_menu_draw() {
	//Run by obj_pause_menu's Draw GUI while debug is on (the screen is already black)
	var gw = display_get_gui_width();
	var gh = display_get_gui_height();

	//The page's name along the top, [ ] (LB RB) at the ends
	menu_draw_box(4, 4, gw - 8, 16);
	draw_set_halign(fa_center);
	menu_draw_text_colour(gw div 2, 8, "DEBUG: " + debug_page_name(dbg_page), MENU_COL_CURSOR);
	if (global.input_using_pad) {
		draw_set_halign(fa_left);
		menu_draw_text(9, 8, "LB");
		draw_set_halign(fa_right);
		menu_draw_text(gw - 9, 8, "RB");
	} else {
		menu_draw_bracket(10, 8, false, c_white);
		menu_draw_bracket(gw - 14, 8, true, c_white);
	}
	draw_set_halign(fa_left);

	//Where Link is
	var bx = 4;
	var by = 24;
	var bw = gw - 8;
	var bh = gh - by - 4;
	menu_draw_box(bx, by, bw, bh);
	var here = debug_text(string_replace(room_get_name(room), "rm_", ""));
	here += "  X " + string(round(link_x)) + " Y " + string(round(link_y));
	menu_draw_text_colour(bx + 8, by + 6, here, MENU_COL_DIM);

	//The rows
	var top = by + 20;
	var n = array_length(dbg_rows);
	for (var i = dbg_top; i < min(n, dbg_top + DEBUG_ROWS_SHOWN); i++) {
		var row = dbg_rows[i];
		var yy = top + (i - dbg_top) * 10;
		var sel = (i == dbg_cursor);
		if (row[1] == "head") {
			menu_draw_text_colour(bx + 8, yy, row[0], MENU_COL_BORDER);
			continue;
		}
		var col = sel ? MENU_COL_CURSOR : c_white;
		if (sel && (current_time div 250) mod 2 == 0) {menu_draw_rect(bx + 6, yy + 2, 4, 4, MENU_COL_CURSOR)}
		var label = row[0];
		var value = debug_value_text(row);
		var room_left = 28 - string_length(value) - 1;	//letters across, less the value
		if (string_length(label) > room_left) {label = string_copy(label, 1, room_left)}
		menu_draw_text_colour(bx + 14, yy, label, col);
		draw_set_halign(fa_right);
		menu_draw_text_colour(bx + bw - 8, yy, value, (row[1] == "bool" && value == "OFF") ? MENU_COL_DIM : col);
		draw_set_halign(fa_left);
	}

	//More above / below
	if (dbg_top > 0) {menu_draw_text_colour(bx + bw - 16, by + 6, "-", MENU_COL_DIM)}
	if (dbg_top + DEBUG_ROWS_SHOWN < n) {menu_draw_text_colour(bx + bw - 16, top + DEBUG_ROWS_SHOWN * 10 - 2, "-", MENU_COL_DIM)}

	//Controls
	var foot = by + bh - 14;
	var hint = global.input_using_pad ? "DPAD  A: SET  B: CLOSE" : "ARROWS  Z: SET  X: CLOSE";
	menu_draw_text_colour(bx + 8, foot, hint, MENU_COL_DIM);


}

///debug_cheats_step();
function debug_cheats_step() {
	//Run by obj_link every step (before he can die): the cheats that keep things full
	if (!DEBUG_MENU) return;
	if (global.dbg_god) {global.pHealth = global.pHealthMax}
	if (global.dbg_magic) {global.pMagic = global.pMagicMax}
	if (global.dbg_ammo) {
		global.pBombs = global.pBombsMax;
		global.pArrows = global.pArrowsMax;
	}
	if (global.dbg_money) {global.pMoney = global.pMoneyMax}


}

///debug_draw_hitboxes();
function debug_draw_hitboxes() {
	//Run by obj_link's Draw: every instance's collision box, Link's in green
	if (!DEBUG_MENU || !global.dbg_hitboxes) return;
	with (all) {
		if (sprite_index == -1 && mask_index == -1) continue;
		draw_set_colour((object_index == obj_link) ? c_lime : c_red);
		draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
	}
	draw_set_colour(c_white);


}
