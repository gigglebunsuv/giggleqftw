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
if (state == "hook" || state == "pull" || state == "jump" || state == "fall") {state = "idle"}
z = 0;
image_xscale = 1;
image_yscale = 1;
move_frac_x = 0;
move_frac_y = 0;

//Falling into a pit brings him back here until he's walked somewhere safe
safe_x = x;
safe_y = y;
fall_grace = 0;
