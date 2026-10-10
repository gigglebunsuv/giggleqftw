/// @description Remember the entrance, reset the floor level, build tile collisions

//Walls from the room's Collision tile layer, if it has one (see collision_tiles_make)
collision_tiles_make();

//CONTINUE on the game over screen puts Link back here
entry_x = x;
entry_y = y;

//Every room starts on the lower floor. Rooms with bridges and stairs use the
//dungeon draw depths, every other room keeps Link's normal depth.
level = 0;
if (level_room_uses_levels()) {
	level_set(0);
} else {
	depth = base_depth;
}

//The grapple hook doesn't come along to the new room, and a jump or fall is over
if (state == "hook" || state == "pull" || state == "jump" || state == "fall" || state == "land" || state == "hop") {state = "idle"}
//...and so is a swing, the spin attack or charging it (the sword stays behind in the old room)
if (state == "attack" || state == "spin" || state == "spin_charge") {
	state = "idle";
	pose = -1;
	spin_t = 0;
}
global.hitstop = 0;
chill_timer = 0;
//Nor a text box or an item held up (they stay behind in the old room): don't stay frozen waiting for them
if ((state == "itemget" || state == "talk") && !instance_exists(obj_dialogue) && !instance_exists(obj_item_get)) {
	state = "idle";
	pose = -1;
}
z = 0;
image_xscale = 1;
image_yscale = 1;
move_frac_x = 0;
move_frac_y = 0;

//This dungeon's small keys, the floor's name (see the dungeon script)
dungeon_room_start();

//Falling into a pit brings him back here until he's walked somewhere safe
safe_x = x;
safe_y = y;
safe_level = 0;
fall_grace = 0;
