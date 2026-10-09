//Shops: what's for sale, at what price, and from which dungeon on. A shopkeeper is an obj_npc with
//dialogue = dlg_shop_goods; (or dlg_shop_bombs) in its Creation Code. Talking to them shows what
//they have in stock right now as a choice box; picking something buys it if Link has the money.
//
//Stock grows as dungeons are beaten (their boss_flag): put the dungeon number in an entry's
//"after" (0 = from the start). Things Link already has drop off the list by themselves.
//When the shop interiors are built, just move the shopkeepers inside.

#macro SHOP_MAX_CHOICES 5		//things shown at once (the choice box also has "NOTHING")

///shop_dungeons_done();
function shop_dungeons_done() {
	//How many dungeons' bosses are beaten (1 Southern Tower, 2 Bog Tower, 3 Ladhellin, 4 the castle)
	var n = 0;
	for (var d = 1; d <= 4; d++) {
		if (flag_get(boss_flag(d))) {n++}
	}
	return n;


}

///shop_goods_list(shop);
function shop_goods_list(argument0) {
	//Everything a shop ever sells. Each: name, price, what it gives (obj_treasure's variables),
	//the dungeon it comes after, and when it's sold out (a function, true = don't show it)
	switch (argument0) {
		case "goods":
			return [
				{name: "SHOVEL", price: 80, give: {item: ITEM.SHOVEL}, after: 0,
					sold: function() {return global.item_have[ITEM.SHOVEL]}},
				{name: "BOTTLE", price: 100, give: {equip: "bottle", contents: BOTTLE.EMPTY}, after: 0,
					sold: function() {return flag_get("shop_goods_bottle")}, flag: "shop_goods_bottle"},
				{name: "RUNNING BOOTS", price: 250, give: {equip: "boots"}, after: 1,
					sold: function() {return global.hasBoots}},
				{name: "BOOMERANG", price: 150, give: {item: ITEM.BOOMERANG}, after: 1,
					sold: function() {return global.item_have[ITEM.BOOMERANG]}},
				{name: "RED POTION", price: 60, give: {equip: "potion", contents: BOTTLE.RED}, after: 0,
					sold: function() {return !shop_has_empty_bottle()}},
			];
		case "bombs":
			return [
				{name: "BOMBS", price: 50, give: {item: ITEM.BOMBS}, after: 0,
					sold: function() {return global.item_have[ITEM.BOMBS]}},
				{name: "BOMB REFILL", price: 30, give: {equip: "bomb_refill"}, after: 0,
					sold: function() {return !global.item_have[ITEM.BOMBS] || global.pBombs >= global.pBombsMax}},
				{name: "BIGGER BOMB BAG", price: 200, give: {equip: "bomb_bag"}, after: 1,
					sold: function() {return !global.item_have[ITEM.BOMBS] || global.bombLevel >= 1}},
				{name: "HUGE BOMB BAG", price: 500, give: {equip: "bomb_bag"}, after: 2,
					sold: function() {return global.bombLevel != 1}},
				{name: "ARROWS", price: 30, give: {equip: "arrow_refill"}, after: 0,
					sold: function() {return !global.item_have[ITEM.BOW] || global.pArrows >= global.pArrowsMax}},
				{name: "BIGGER QUIVER", price: 300, give: {equip: "quiver"}, after: 2,
					sold: function() {return !global.item_have[ITEM.BOW] || global.arrowLevel >= 2}},
				{name: "BOTTLE", price: 150, give: {equip: "bottle", contents: BOTTLE.EMPTY}, after: 2,
					sold: function() {return flag_get("shop_bombs_bottle")}, flag: "shop_bombs_bottle"},
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
			return ["YOU GOT A " + g.name + "! DRINK IT WHEN YOU NEED IT.", "THANK YOU, COME AGAIN!"];
		case "arrow_refill":
			global.pArrows = global.pArrowsMax;
			sfx_play(SFX_ITEM_GET);
			return ["YOUR QUIVER IS FULL. THANK YOU!"];
	}
	var steps = world_give(g.give);
	array_push(steps, "THANK YOU, COME AGAIN!");
	return steps;


}

///shop_talk(shop, hello, new_stock_line);
function shop_talk(argument0, argument1, argument2) {
	//The conversation with a shopkeeper: a greeting (a different one when there's new stock since
	//the last visit), then the choice box of what's for sale
	var which = argument0;
	var stock = shop_stock(which);
	var seen_flag = "shop_seen_" + which;
	var steps = [];
	var done = shop_dungeons_done();
	if (flag_get(seen_flag) != 0 && flag_get(seen_flag) - 1 < done) {
		array_push(steps, argument2);
	} else {
		array_push(steps, argument1);
	}
	flag_set(seen_flag, done + 1);
	if (array_length(stock) == 0) {
		array_push(steps, "I'M ALL SOLD OUT FOR NOW. COME BACK AFTER YOUR NEXT ADVENTURE!");
		return steps;
	}
	var answers = [];
	for (var i = 0; i < array_length(stock); i++) {
		var g = stock[i];
		array_push(answers, [g.name + " " + string(g.price), [dlg_run(method({goods: g}, function() {dialogue_insert(shop_buy(goods))}))]]);
	}
	array_push(answers, ["NOTHING", ["COME BACK ANY TIME!"]]);
	array_push(steps, dlg_choice("YOU HAVE " + string(global.pMoney) + " MONEY. WHAT'LL IT BE?", answers));
	return steps;


}
