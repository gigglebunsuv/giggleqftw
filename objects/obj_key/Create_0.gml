/// @description Small key lying on the floor: touch it to pick it up (for good, a story flag)
//The grapple hook can grab it and bring it back. Set in its Creation Code:
//	appear = "clear";		only shows up once its room's enemies are gone ("" = always there)

appear = "";
shown = false;
checked = false;
depth = DEPTH_DECOR - 1;
image_speed = 0;
