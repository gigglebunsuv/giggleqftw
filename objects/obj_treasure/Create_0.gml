/// @description Something to pick up, shown floating over a pedestal
//Walk onto it to get it (see treasure_collect). Set what it is in the instance's Creation Code:
//	item = ITEM.FIRE_ROD;					an item (ITEM.SHIELD gives the next shield tier)
//	equip = "sword"; tier = 3;				sword / shield / armor at that tier (or better)
//	equip = "boots";						"gloves", "flippers", "boots"
//	equip = "bottle"; contents = BOTTLE.RED;	a bottle (or fills an empty one if all 5 are owned)
//	equip = "bomb_bag";						"bomb_bag", "quiver" (next capacity), "heart" (container),
//											"bun" (next Bun piece), "refill" (health, magic, bombs, arrows)
//	equip = "money"; amount = 50;			money, or "key" for small keys (amount = how many)
//	equip = "map";							"map", "compass", "boss_key" for this dungeon
//Also:
//	hold_up = true;							Link holds it up and a text box says what it is (like a chest)
//	message = "SOME TEXT";					said after "YOU GOT THE ...!" (with hold_up)
//	flag = "some_flag";						a story flag set when it's picked up; it's gone for good after
//	pedestal = false;						lies on the floor, no pedestal

item = ITEM.NONE;
equip = "";
tier = 1;
contents = BOTTLE.EMPTY;
amount = 1;
hold_up = false;
message = "";
flag = "";
pedestal = true;
