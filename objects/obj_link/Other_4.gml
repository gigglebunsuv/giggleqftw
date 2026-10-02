/// @description Reset the floor level

//Every room starts on the lower floor. Rooms with bridges and stairs use the
//dungeon draw depths, every other room keeps Link's normal depth.
level = 0;
if (level_room_uses_levels()) {
	level_set(0);
} else {
	depth = base_depth;
}
