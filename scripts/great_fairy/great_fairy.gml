//The Great Fairy (obj_great_fairy) in her fountain, a cave in the west fields (rm_caves, the "fairy" cave).
//Talking to her:
//	heals Link and fills his magic, every time
//	catches fairies in his empty bottles (FAIRY_BOTTLE_PRICE each): a fairy heals him, or saves him when he'd die
//	her blessings: once the bomb shop's biggest bag (64) or quiver (80) is his, she can stretch them to 99
//	(player_upgrade_bombs / player_upgrade_arrows, level 3), for FAIRY_BLESSING_PRICE each

#macro FAIRY_BOTTLE_PRICE 30
#macro FAIRY_BLESSING_PRICE 300
#macro SFX_FAIRY "snd_fairy"	//the Great Fairy's magic

///great_fairy_empty_bottles();
function great_fairy_empty_bottles() {
	//How many empty bottles Link has
	var n = 0;
	for (var i = 0; i < BOTTLES; i++) {
		if (global.item_have[ITEM.BOTTLE_1 + i] && global.bottles[i] == BOTTLE.EMPTY) {n++}
	}
	return n;


}

///dlg_great_fairy();
function dlg_great_fairy() {
	var steps = [
		dlg_run(function() {
			global.pHealth = global.pHealthMax;
			global.pMagic = global.pMagicMax;
			sfx_play(SFX_FAIRY);
		}),
		"WELCOME, SIR GIGGLEBUNS. I AM THE GREAT FAIRY OF HAVEN. LET MY WATERS MEND YOUR HEART AND YOUR MAGIC."
	];
	var answers = [];
	var empty = great_fairy_empty_bottles();
	if (empty > 0) {
		var cost = empty * FAIRY_BOTTLE_PRICE;
		array_push(answers, ["FAIRIES", [
			"MY LITTLE ONES WILL FOLLOW YOU IN A BOTTLE. " + string(FAIRY_BOTTLE_PRICE) + " MONEY EACH: "
				+ string(cost) + " FOR YOUR " + string(empty) + " EMPTY " + ((empty == 1) ? "BOTTLE." : "BOTTLES."),
			dlg_if(function() {return global.pMoney >= great_fairy_empty_bottles() * FAIRY_BOTTLE_PRICE;}, [
				dlg_run(function() {
					player_add_money(-great_fairy_empty_bottles() * FAIRY_BOTTLE_PRICE);
					for (var i = 0; i < BOTTLES; i++) {
						if (global.item_have[ITEM.BOTTLE_1 + i] && global.bottles[i] == BOTTLE.EMPTY) {global.bottles[i] = BOTTLE.FAIRY}
					}
					sfx_play(SFX_ITEM_GET);
				}),
				"THERE. THEY'LL HEAL YOU WHEN YOU DRINK... OR CATCH YOU WHEN YOU FALL."
			], [
				"YOU DON'T HAVE ENOUGH MONEY, LITTLE KNIGHT. COME BACK WHEN YOUR PURSE IS HEAVIER."
			])
		]]);
	}
	if (global.item_have[ITEM.BOMBS] && global.bombLevel == 2) {
		array_push(answers, ["MORE BOMBS", great_fairy_blessing("bombs")]);
	}
	if (global.item_have[ITEM.BOW] && global.arrowLevel == 2) {
		array_push(answers, ["MORE ARROWS", great_fairy_blessing("arrows")]);
	}
	if (array_length(answers) == 0) {
		array_push(steps, "IF YOU BRING ME EMPTY BOTTLES, MY LITTLE ONES WILL GO WITH YOU. AND ONCE THE BOMB SHOP'S BIGGEST BAG OR QUIVER IS YOURS, I CAN BLESS THEM.");
		return steps;
	}
	array_push(answers, "NOTHING");
	array_push(steps, dlg_choice("IS THERE ANYTHING ELSE YOU WISH FOR?", answers));
	return steps;


}

///great_fairy_blessing(what);
function great_fairy_blessing(argument0) {
	//The steps for one of her blessings: "bombs" or "arrows"
	var bombs = (argument0 == "bombs");
	return [
		"FOR " + string(FAIRY_BLESSING_PRICE) + " MONEY I WILL BLESS YOUR " + (bombs ? "BOMB BAG" : "QUIVER") + " TO HOLD 99.",
		dlg_choice("ACCEPT HER BLESSING?", [
			["YES", [dlg_if(function() {return global.pMoney >= FAIRY_BLESSING_PRICE;}, [
				dlg_run(bombs ? function() {
					player_add_money(-FAIRY_BLESSING_PRICE);
					player_upgrade_bombs();
					sfx_play(SFX_FANFARE_ITEM);
				} : function() {
					player_add_money(-FAIRY_BLESSING_PRICE);
					player_upgrade_arrows();
					sfx_play(SFX_FANFARE_ITEM);
				}),
				bombs ? "YOUR BOMB BAG HOLDS 99 BOMBS NOW. USE THEM WISELY." : "YOUR QUIVER HOLDS 99 ARROWS NOW. AIM TRUE."
			], ["YOU DON'T HAVE ENOUGH MONEY, LITTLE KNIGHT."])]],
			"NO"
		])
	];


}

///great_fairy_draw();
function great_fairy_draw() {
	//Run by obj_great_fairy: her pool (spr_fairy_pool, 48 x 32, centred on her tile's bottom) and her,
	//bobbing over it
	var cx = (bbox_left + bbox_right + 1) / 2;
	var by = bbox_bottom + 1;
	var f = (current_time div 400) mod 2;
	draw_sprite(spr_fairy_pool, f, cx - 24, by - 32);
	var bob = round(sin(current_time / 300) * 2);
	draw_sprite(spr_great_fairy, f, cx - 16, by - 40 + bob);


}
