/// @description One floor of a dungeon (invisible marker, scaled over the whole floor's area)
//All of a dungeon's floors are in one room, side by side. Set in its Creation Code:
//	floor_num = 2;			higher = further up (B1 = -1, 1F = 1, 2F = 2...)
//	floor_name = "2F";		shown when Link arrives and on the map
//	holes_drop = false;		holes are bottomless instead of dropping to the floor below
//Floors line up: the same spot on two floors is at the same offset from their markers.

floor_num = 1;
floor_name = "1F";
holes_drop = true;
