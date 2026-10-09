/// @description Shutter door: bars that open by themselves (dungeon script, shutter_should_open)
//Same size and placing as obj_locked_door (image_angle = 90 for left/right walls).
//Set open_when in its Creation Code:
//	"clear"		shuts behind Link while enemies are left in the room he's in, opens when they're gone
//	"torches"	opens once every torch in one of its rooms is lit (stays open)
//	"switch"	opens once a floor switch in one of its rooms is stepped on (stays open)
//Its wall is a separate obj_wall (block) that's only there while it's shut.

open_when = "clear";
depth = DEPTH_DECOR;
is_open = true;
block = noone;
zones = [];
ready = false;
image_speed = 0;
