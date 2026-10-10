//Hero Mode and how much of the game a file has done.
//
//HERO MODE: once any file has seen the ending (the gold star), a NEW file can be started in Hero Mode
//(the file select asks after the name). Enemies (and everything else) do double damage, and no hearts
//ever drop: they turn into money (pickup_create). Fairies, potions and heart containers still work.
//Beating the Evil King in Hero Mode puts a red star next to the gold one on the file select.
//The file's flag HERO_FLAG says it's a Hero Mode file; HERO_CLEAR_FLAG is set by ending_start.
//
//COMPLETION: completion_percent(file) adds up what a saved file has found (items, equipment, hearts,
//the Bun, bosses, the magic upgrade, bunlings, warp statues, the Great Fairy's blessings, the Hall of
//Echoes), shown on the file select as DONE n%.

#macro HERO_FLAG "hero_mode"
#macro HERO_CLEAR_FLAG "hero_clear"
#macro HERO_DAMAGE 2				//times the damage Link takes
#macro WARP_STATUES_TOTAL 10		//warp statues in the world (make_overworld_room.py puts them out)

///hero_mode();
function hero_mode() {
	return flag_get(HERO_FLAG);


}

///player_damage_taken(amount);
function player_damage_taken(argument0) {
	//What a hit takes off Link: doubled in Hero Mode, then armor, then halved by the Echo Charm
	var amount = argument0;
	if (hero_mode()) {amount *= HERO_DAMAGE}
	amount = player_armor_damage(amount);
	if (flag_get(ECHO_CHARM_FLAG)) {amount = max(1, ceil(amount / 2))}
	return amount;


}

///completion_percent(file);
function completion_percent(argument0) {
	//How much of the game a saved file (a struct from save_read) has done, 0-100
	var d = argument0;
	var flags = save_get(d, "flags", {});
	if (!is_struct(flags)) {flags = {}}
	var got = 0;
	var total = 0;
	//Every item on the grid (the bottles too)
	var have = save_get(d, "item_have", []);
	for (var i = 0; i < ITEM.COUNT; i++) {
		total++;
		if (i < array_length(have) && have[i]) {got++}
	}
	//Equipment
	got += clamp(save_get(d, "sword", 0), 0, SWORD_TIER_MAX); total += SWORD_TIER_MAX;
	got += clamp(save_get(d, "shield", 0), 0, SHIELD_TIER_MAX); total += SHIELD_TIER_MAX;
	got += clamp(save_get(d, "armor", 1) - 1, 0, ARMOR_TIER_MAX - 1); total += ARMOR_TIER_MAX - 1;
	got += save_get(d, "gloves", false) + save_get(d, "flippers", false) + save_get(d, "boots", false); total += 3;
	//Hearts past the first three
	got += clamp(ceil(save_get(d, "health_max", 6) / 2) - 3, 0, PLAYER_HEARTS_MAX - 3); total += PLAYER_HEARTS_MAX - 3;
	//The Bun
	var bun = save_get(d, "bun", []);
	for (var b = 0; b < BUN_PIECES; b++) {
		total++;
		if (b < array_length(bun) && bun[b]) {got++}
	}
	//The bosses, the ending
	for (var k = 1; k <= 3; k++) {
		total++;
		if (save_get(flags, boss_flag(k), false)) {got++}
	}
	total++;
	if (save_get(flags, GAME_CLEAR_FLAG, false)) {got++}
	//The magic upgrade, the bunlings, the warp statues
	total++;
	if (save_get(d, "magic_max", MAGIC_BASE) > MAGIC_BASE) {got++}
	var bn = save_get(flags, "bunlings_found", 0);
	got += is_real(bn) ? clamp(bn, 0, BUNLINGS_TOTAL) : 0;
	total += BUNLINGS_TOTAL;
	var names = variable_struct_get_names(flags);
	var statues = 0;
	for (var n = 0; n < array_length(names); n++) {
		if (string_pos("warp_statue_", names[n]) == 1 && variable_struct_get(flags, names[n])) {statues++}
	}
	got += min(statues, WARP_STATUES_TOTAL);
	total += WARP_STATUES_TOTAL;
	//The Great Fairy's blessings, the Hall of Echoes
	got += (save_get(d, "bomb_level", 0) >= 3) + (save_get(d, "arrow_level", 0) >= 3);
	total += 2;
	total++;
	if (save_get(flags, ECHOES_FLAG, false)) {got++}
	return floor(100 * got / max(1, total));


}

///file_select_star_colour(x, y, colour);
function file_select_star_colour(argument0, argument1, argument2) {
	//A little star (7x7) in this colour (the Hero Mode star is red)
	var col = argument2;
	var sx = argument0;
	var sy = argument1;
	menu_draw_rect(sx + 3, sy, 1, 7, col);
	menu_draw_rect(sx, sy + 2, 7, 1, col);
	menu_draw_rect(sx + 1, sy + 3, 5, 1, col);
	menu_draw_rect(sx + 2, sy + 1, 3, 4, col);
	menu_draw_rect(sx + 1, sy + 5, 1, 2, col);
	menu_draw_rect(sx + 5, sy + 5, 1, 2, col);


}

///file_select_trophy(x, y);
function file_select_trophy(argument0, argument1) {
	//A little silver cup (7x7): the Hall of Echoes beaten
	var col = make_colour_rgb(169, 169, 169);
	var hi = c_white;
	var sx = argument0;
	var sy = argument1;
	menu_draw_rect(sx, sy, 7, 1, col);
	menu_draw_rect(sx + 1, sy + 1, 5, 2, col);
	menu_draw_rect(sx + 2, sy + 1, 1, 2, hi);
	menu_draw_rect(sx + 2, sy + 3, 3, 1, col);
	menu_draw_rect(sx + 3, sy + 4, 1, 1, col);
	menu_draw_rect(sx + 1, sy + 5, 5, 2, col);


}
