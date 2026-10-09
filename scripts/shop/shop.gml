//Shops: what's for sale, at what price, and from which dungeon on. A shopkeeper is an obj_npc with
//dialogue = dlg_shop_goods; (or dlg_shop_bombs, dlg_armorer) in its Creation Code. Talking to them
//opens the shop's counter (shop_ui_*, drawn by obj_dialogue): what they have in stock right now on
//a shelf, with its price and what it does. Left and right pick, A buys (after a YES / NO), B leaves.
//
//Stock grows as dungeons are beaten (their boss_flag): put the dungeon number in an entry's
//"after" (0 = from the start). Things Link already has drop off the list by themselves.
//When the shop interiors are built, just move the shopkeepers inside.

#macro SHOP_MAX_CHOICES 5		//things on the shelf at once
#macro SHOP_W 240				//the counter's box (GUI pixels)
#macro SHOP_H 140
#macro SHOP_COL_PRICE make_colour_rgb(232, 208, 170)	//prices (#e8d0aa)
#macro SHOP_COL_TOO_DEAR make_colour_rgb(222, 124, 112)	//prices Link can't pay (#de7c70)

///shop_dungeons_done();
function shop_dungeons_done() {
	//How many dungeons' bosses are beaten (1 Southern Tower, 2 Bog Tower, 3 Ladhellin, 4 the castle)
	var n = 0;
	for (var d = 1; d <= 4; d++) {
		if (flag_get(boss_flag(d))) {n++}
	}
	return n;


}

///shop_title(shop);
function shop_title(argument0) {
	switch (argument0) {
		case "goods": return "GENERAL STORE";
		case "bombs": return "BOMB SHOP";
		case "armor": return "ARMORER";
	}
	return "SHOP";


}

///shop_goods_list(shop);
function shop_goods_list(argument0) {
	//Everything a shop ever sells. Each: name, price, what it gives (obj_treasure's variables),
	//the dungeon it comes after, when it's sold out (a function, true = don't show it), and a line
	//on what it does (desc)
	switch (argument0) {
		case "goods":
			return [
				{name: "SHOVEL", price: 80, give: {item: ITEM.SHOVEL}, after: 0,
					desc: "DIG UP WHAT'S BURIED. TRY SOFT GROUND!",
					sold: function() {return global.item_have[ITEM.SHOVEL]}},
				{name: "BOTTLE", price: 100, give: {equip: "bottle", contents: BOTTLE.EMPTY}, after: 0,
					desc: "AN EMPTY BOTTLE, FOR POTIONS.",
					sold: function() {return flag_get("shop_goods_bottle")}, flag: "shop_goods_bottle"},
				{name: "RUNNING BOOTS", price: 250, give: {equip: "boots"}, after: 1,
					desc: "HOLD THE RUN BUTTON TO DASH.",
					sold: function() {return global.hasBoots}},
				{name: "BOOMERANG", price: 150, give: {item: ITEM.BOOMERANG}, after: 1,
					desc: "THROW IT TO STUN ENEMIES.",
					sold: function() {return global.item_have[ITEM.BOOMERANG]}},
				{name: "RED POTION", price: 60, give: {equip: "potion", contents: BOTTLE.RED}, after: 0,
					desc: "FILLS YOUR HEARTS. NEEDS AN EMPTY BOTTLE.",
					sold: function() {return !shop_has_empty_bottle()}},
			];
		case "bombs":
			return [
				{name: "BOMBS", price: 50, give: {item: ITEM.BOMBS}, after: 0,
					desc: "A BAG OF BOMBS. BREAKS CRACKED WALLS.",
					sold: function() {return global.item_have[ITEM.BOMBS]}},
				{name: "BOMB REFILL", price: 30, give: {equip: "bomb_refill"}, after: 0,
					desc: "FILLS YOUR BOMB BAG.",
					sold: function() {return !global.item_have[ITEM.BOMBS] || global.pBombs >= global.pBombsMax}},
				{name: "BIGGER BOMB BAG", price: 200, give: {equip: "bomb_bag"}, after: 1,
					desc: "CARRY MORE BOMBS.",
					sold: function() {return !global.item_have[ITEM.BOMBS] || global.bombLevel >= 1}},
				{name: "HUGE BOMB BAG", price: 500, give: {equip: "bomb_bag"}, after: 2,
					desc: "CARRY EVEN MORE BOMBS.",
					sold: function() {return global.bombLevel != 1}},
				{name: "ARROWS", price: 30, give: {equip: "arrow_refill"}, after: 0,
					desc: "FILLS YOUR QUIVER.",
					sold: function() {return !global.item_have[ITEM.BOW] || global.pArrows >= global.pArrowsMax}},
				{name: "BIGGER QUIVER", price: 300, give: {equip: "quiver"}, after: 2,
					desc: "CARRY MORE ARROWS.",
					sold: function() {return !global.item_have[ITEM.BOW] || global.arrowLevel >= 2}},
				{name: "BOTTLE", price: 150, give: {equip: "bottle", contents: BOTTLE.EMPTY}, after: 2,
					desc: "AN EMPTY BOTTLE, FOR POTIONS.",
					sold: function() {return flag_get("shop_bombs_bottle")}, flag: "shop_bombs_bottle"},
			];
		case "armor":
			//The armorer (see the armorer script): chain-mail after the Bog Tower, golden armor after Ladhellin
			return [
				{name: "LEVEL 2 ARMOR", price: ARMOR_PRICE_2, give: {equip: "armor", tier: 2}, after: 2,
					desc: "BLUE CHAIN-MAIL. ENEMIES DO HALF THE DAMAGE.",
					sold: function() {return global.armorTier >= 2}},
				{name: "LEVEL 3 ARMOR", price: ARMOR_PRICE_3, give: {equip: "armor", tier: 3}, after: 3,
					desc: "GOLDEN ARMOR. ENEMIES DO A QUARTER OF THE DAMAGE.",
					sold: function() {return global.armorTier != 2}},
			];
	}
	return [];


}

///shop_has_empty_bottle();
function shop_has_empty_bottle() {
	for (var i = 0; i < BOTTLES; i++) {
		if (global.item_have[ITEM.BOTTLE_1 + i] && global.bottles[i] == BOTTLE.EMPTY) return true;
	}
	return false;


}

///shop_stock(shop);
function shop_stock(argument0) {
	//What's on sale right now
	var all_goods = shop_goods_list(argument0);
	var done = shop_dungeons_done();
	var out = [];
	for (var i = 0; i < array_length(all_goods); i++) {
		var g = all_goods[i];
		if (g.after > done || g.sold()) continue;
		array_push(out, g);
		if (array_length(out) >= SHOP_MAX_CHOICES) break;
	}
	return out;


}

///shop_buy(goods);
function shop_buy(argument0) {
	//Pays and gives it. Returns the steps to say ("YOU GOT..." or not enough money).
	var g = argument0;
	if (global.pMoney < g.price) return ["YOU DON'T HAVE ENOUGH MONEY FOR THAT. COME BACK WITH " + string(g.price) + "!"];
	player_add_money(-g.price);
	sfx_play(SFX_SHOP_BUY);
	if (variable_struct_exists(g, "flag")) {flag_set(g.flag, true)}
	switch (g.give[$ "equip"]) {
		//refills aren't treasure: just fill up
		case "bomb_refill":
			global.pBombs = global.pBombsMax;
			sfx_play(SFX_ITEM_GET);
			return ["YOUR BOMB BAG IS FULL. THANK YOU!"];
		case "potion":
			//into an empty bottle Link already has
			bottle_fill(g.give.contents);
			sfx_play(SFX_ITEM_GET);
			return ["YOU GOT A " + g.name + "! DRINK IT WHEN YOU NEED IT.", "THANK YOU!"];
		case "arrow_refill":
			global.pArrows = global.pArrowsMax;
			sfx_play(SFX_ITEM_GET);
			return ["YOUR QUIVER IS FULL. THANK YOU!"];
	}
	var steps = world_give(g.give);
	array_push(steps, "THANK YOU!");
	return steps;


}

///shop_talk(shop, hello, new_stock_line);
function shop_talk(argument0, argument1, argument2) {
	//The conversation with a shopkeeper: a greeting (a different one when there's new stock since
	//the last visit), then the counter
	var which = argument0;
	var seen_flag = "shop_seen_" + which;
	var steps = [];
	var done = shop_dungeons_done();
	if (flag_get(seen_flag) != 0 && flag_get(seen_flag) - 1 < done) {
		array_push(steps, argument2);
	} else {
		array_push(steps, argument1);
	}
	flag_set(seen_flag, done + 1);
	array_push(steps, dlg_shop(which));
	return steps;


}

///dlg_shop(shop);
function dlg_shop(argument0) {
	//A conversation step: open this shop's counter (see shop_ui_open)
	return {type: "shop", shop: argument0};


}

///shop_icon(goods);
function shop_icon(argument0) {
	//[sprite, frame] for something on the shelf
	var give = argument0.give;
	var it = give[$ "item"];
	if (!is_undefined(it) && it != ITEM.NONE) {
		if (it == ITEM.SHIELD) return [spr_menu_shield, 0];
		return [item_get_sprite(it), 0];
	}
	switch (give[$ "equip"]) {
		case "bottle": return [spr_item_bottle, BOTTLE.EMPTY];
		case "potion": return [spr_item_bottle, give.contents];
		case "boots": return [spr_menu_boots, 0];
		case "bomb_refill": case "bomb_bag": return [spr_item_bombs, 0];
		case "arrow_refill": return [spr_arrow_bundle, 0];
		case "quiver": return [spr_item_bow, 0];
		case "armor": return [spr_menu_armor, clamp(give.tier, 1, ARMOR_TIER_MAX) - 1];
	}
	return [-1, 0];


}

//================================================================ the counter (run by obj_dialogue)

///shop_ui_open(shop);
function shop_ui_open(argument0) {
	//Run by obj_dialogue (dialogue_advance) at a dlg_shop step: the counter takes over the text box
	shop_on = true;
	shop_name = argument0;
	shop_list = shop_stock(argument0);
	shop_cursor = clamp(shop_cursor, 0, max(0, array_length(shop_list) - 1));
	shop_confirm = -1;


}

///shop_ui_step();
function shop_ui_step() {
	//Run by obj_dialogue while the counter is open
	var n = array_length(shop_list);

	//Asking YES / NO
	if (shop_confirm >= 0) {
		if (menu_move_h != 0 || menu_move != 0) {
			shop_confirm = 1 - shop_confirm;
			audio_play_sound(menu_switch, 2, false);
		}
		if (act_b) {
			shop_confirm = -1;
			audio_play_sound(menu_switch, 2, false);
			return;
		}
		if (act_a) {
			audio_play_sound(menu_select, 3, false);
			if (shop_confirm == 1) {
				shop_confirm = -1;
				return;
			}
			//Buy it, say so, then the counter again
			shop_on = false;
			var steps = shop_buy(shop_list[shop_cursor]);
			array_push(steps, dlg_shop(shop_name));
			dialogue_insert(steps);
			dialogue_advance();
		}
		return;
	}

	if (n > 0 && menu_move_h != 0) {
		shop_cursor = (shop_cursor + menu_move_h + n) mod n;
		audio_play_sound(menu_switch, 2, false);
	}
	if (act_b || (act_a && n == 0)) {
		audio_play_sound(menu_select, 3, false);
		shop_on = false;
		dialogue_insert(["COME BACK ANY TIME!"]);
		dialogue_advance();
		return;
	}
	if (act_a) {
		audio_play_sound(menu_select, 3, false);
		shop_confirm = 0;
	}


}

///shop_ui_draw();
function shop_ui_draw() {
	//Run by obj_dialogue's Draw GUI while the counter is open: the shelf, what's picked, the money
	var area = hud_play_area();
	var gw = display_get_gui_width();
	var bx = (gw - SHOP_W) div 2;
	var by = area[1] + (area[3] - SHOP_H) div 2;
	var n = array_length(shop_list);
	menu_draw_box(bx, by, SHOP_W, SHOP_H);

	//The shop's name, and Link's money
	draw_set_font(menu_font);
	draw_set_valign(fa_top);
	menu_draw_text_commas(bx + 8, by + 6, shop_title(shop_name), MENU_COL_BORDER);
	var money = "MONEY " + string(global.pMoney);
	menu_draw_text_commas(bx + SHOP_W - 8 - string_length(money) * 8, by + 6, money, c_white);
	menu_draw_rect(bx + 6, by + 17, SHOP_W - 12, 1, MENU_COL_TRIM_DARK);

	if (n == 0) {
		var lines = dialogue_wrap("I'M ALL SOLD OUT FOR NOW. COME BACK AFTER YOUR NEXT ADVENTURE!");
		for (var i = 0; i < array_length(lines); i++) {menu_draw_text_commas(bx + 8, by + 40 + i * 12, lines[i], c_white)}
		draw_set_font(small_font);
		menu_draw_text_colour(bx + 8, by + SHOP_H - 12, "A OR B: LEAVE", MENU_COL_DIM);
		return;
	}

	//The shelf: a slot for each thing, its price under it
	var slot = MENU_EQUIP_SLOT;
	var gap = 22;
	var sx = bx + (SHOP_W - (n * slot + (n - 1) * gap)) div 2;
	var sy = by + 24;
	draw_set_font(small_font);
	for (var k = 0; k < n; k++) {
		var g = shop_list[k];
		var ex = sx + k * (slot + gap);
		var dear = (global.pMoney < g.price);
		menu_draw_rect(ex, sy, slot, slot, MENU_COL_SLOT);
		var ic = shop_icon(g);
		if (ic[0] != -1) {draw_sprite_ext(ic[0], ic[1], ex + 2, sy + 2, 1, 1, 0, c_white, dear ? 0.5 : 1)}
		if (k == shop_cursor && (shop_confirm >= 0 || (current_time div 250) mod 2 == 0)) {
			menu_draw_frame(ex - 2, sy - 2, slot + 4, slot + 4, 1, MENU_COL_CURSOR);
		}
		var p = string(g.price);
		draw_set_halign(fa_center);
		menu_draw_text_colour(ex + slot div 2, sy + slot + 3, p, dear ? SHOP_COL_TOO_DEAR : SHOP_COL_PRICE);
		draw_set_halign(fa_left);
	}

	//What's picked: its name and what it does
	var pick = shop_list[shop_cursor];
	draw_set_font(menu_font);
	var ny = sy + slot + 14;
	menu_draw_rect(bx + 6, ny - 3, SHOP_W - 12, 1, MENU_COL_TRIM_DARK);
	menu_draw_text_commas(bx + 8, ny + 2, pick.name, MENU_COL_CURSOR);
	var d = dialogue_wrap(pick.desc);
	for (var j = 0; j < min(2, array_length(d)); j++) {menu_draw_text_commas(bx + 8, ny + 16 + j * 11, d[j], c_white)}

	//The buttons, or the question
	var hy = by + SHOP_H - 15;
	if (shop_confirm >= 0) {
		var q = "BUY IT FOR " + string(pick.price) + "?";
		menu_draw_text_commas(bx + 8, hy, q, c_white);
		var ax = bx + 8 + (string_length(q) + 2) * 8;
		var answers = ["YES", "NO"];
		for (var a = 0; a < 2; a++) {
			var col = (a == shop_confirm) ? MENU_COL_CURSOR : c_white;
			if (a == shop_confirm) {menu_draw_rect(ax - 6, hy + 2, 4, 4, MENU_COL_CURSOR)}
			menu_draw_text_commas(ax, hy, answers[a], col);
			ax += 48;
		}
	} else {
		draw_set_font(small_font);
		menu_draw_text_colour(bx + 8, hy + 2, "LEFT/RIGHT: PICK   A: BUY   B: LEAVE", MENU_COL_DIM);
	}


}
