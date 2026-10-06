/// @description Treasure chest (see the chests script)
//Link faces it and presses A: it opens, what's inside rises over his head and a text box
//says what he got. Blocks the way (child of obj_wall).
//Set what's inside in the instance's Creation Code, the same way as obj_treasure:
//	item = ITEM.FIRE_ROD;					an item (ITEM.SHIELD gives the next shield tier)
//	equip = "sword"; tier = 3;				sword / shield / armor at that tier (or better)
//	equip = "boots";						"gloves", "flippers", "boots"
//	equip = "bottle"; contents = BOTTLE.RED;	a bottle (or fills an empty one if all 5 are owned)
//	equip = "bomb_bag";						"bomb_bag", "quiver" (next capacity), "heart" (container),
//											"bun" (next Bun piece), "refill" (health, magic, bombs, arrows)
//	equip = "money"; amount = 50;			money, or "key" for small keys (amount = how many)
//Nothing set = an empty chest. Also:
//	message = "SOME TEXT";					said after "YOU GOT THE ...!" instead of the usual line
//	remember = false;						closes again when Link comes back (for testing). Otherwise
//											it stays open for the rest of the game (a story flag, see chest_flag)

item = ITEM.NONE;
equip = "";
tier = 1;
contents = BOTTLE.EMPTY;
amount = 1;
message = "";
remember = true;
opened = false;
checked = false;	//looked up whether it was opened before (first step, after Creation Code)

//Always block as the whole 16x16 tile it's placed on (x, y = its top left), whatever the sprite
mask_index = spr_collisions;
image_speed = 0;
//Frames: 0 closed, 1 open. A drawn placeholder until spr_chest is imported.
sprite_index = asset_get_index("spr_chest");
