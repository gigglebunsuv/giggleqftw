/// @description Locked door: walk into it with a small key to open it (for good, a story flag)
//Fills a 2-tile doorway through both rooms' walls (32x32, origin in the middle: place it on
//the line between the two rooms). Set image_angle = 90 in its Creation Code for a doorway
//in a left/right wall. Blocks both floors (child of obj_wall). See the dungeon script.

depth = DEPTH_DECOR;
checked = false;	//looked up whether it was opened before (first step)
image_speed = 0;
