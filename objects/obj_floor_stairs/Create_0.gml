/// @description Stairs to another floor of the dungeon (32x32, against a north wall)
//Walk up into them: the screen fades and Link comes out below the stairs with the same pair
//on the other floor. Set in its Creation Code:
//	pair = "A";				the two ends of a staircase share a pair name
//	up = true;				stairs up (false = stairs down, only changes the picture)

pair = "";
up = true;
depth = DEPTH_DECOR;
ready = false;
