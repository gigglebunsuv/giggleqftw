/// @description Stone eye in a wall: shoot it with an arrow to shut it for good (see the bog script)
//A shutter door with open_when = "eye" opens once every eye in one of its rooms is shut.
//The wall it's set in blocks Link (it isn't solid itself). The sword doesn't wake it.

shut = false;
checked = false;
depth = DEPTH_DECOR - 1;
image_speed = 0;
