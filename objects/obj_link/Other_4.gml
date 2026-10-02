/// @description Remember the entrance, reset the floor level

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
