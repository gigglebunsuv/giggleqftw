/// HAVEN overworld (base layout from the blueprint, placeholders everywhere)
//
//Size: 8 x 8 screens of 256x176 (128 x 88 tiles of 16px). The camera flips a screen at a time.
//
//Layers (top to bottom):
//	Water			Paint tiles here for deep water (needs the flippers). Hidden in game like Collision.
//	FluteSpots		obj_flute_spot: where the flute's warp menu can send Link (name in Creation Code)
//	CamZones		obj_cam_zone rectangles: the camera follows Link inside the smallest one he's in
//					and slides when he moves to another. One covers the whole map (the fields),
//					each area has its own. Stretch them in the room editor to change the areas.
//	Collision		Paint any tile here to make it solid. Hidden in game: at Room Start
//					obj_link turns it into obj_wall instances (see collision_tiles_make).
//					Toggle its eye in the room editor to see/edit it.
//	Warps			obj_warp on every door, cave and dungeon. Each one's Creation Code
//					says what it is; set targetRoom/targetX/targetY to hook it up.
//	TestProps		torches, pegs, heavy rocks and a dig spot below the village, for trying the
//					new items. Delete the layer when you're done with it.
//	Instances		Link (start: in front of Home), camera, music, the bun gate
//	Tiles_Snow		tiles_snow_area (northeastern cliffs only)
//	Tiles_Detail	tile_overworld: trees, cliffs, buildings, rocks (on top of the ground)
//	Tiles_Ground	tile_overworld: grass, paths, sand, marsh, water, paving
//
//Areas (tile coordinates, x then y; multiply by 16 for pixels):
//	The forest				2-37, 2-23	entrance at the bottom (16-17, 22)
//	  The hidden forest		4-25, 4-9	locked by obj_bun_gate (26-27, 6-7) until all 3 Bun pieces
//	  Sword pedestal		14, 6		placeholder tile
//	Old castle town			42-85, 8-31	brick walls, gates south/east/west
//	Final dungeon			48-81, 2-13	cliff with the temple in front, door at the bottom
//	Northeastern cliffs		86-125, 2-31	snow; mini dungeon 94-104, 5-11
//	West marshlands			2-25, 26-59	dungeon 2 at 4-10, 38-46
//	Village					46-81, 34-53	shops, 8 houses, home, library; well at 55, 55
//	Desert of Ladhellin		90-125, 34-71	dungeon 3 at 104-121, 44-53
//	Southern fields			2-45, 62-85	dungeon 1 at 26-39, 74-81
//	South road				48-125, 74-85
//	Bunsriel fields			everything in between
