/// @description Crow: perched until Link comes close, then swoops at him over and over (see crow_step)

event_inherited();
hp = 1;
contact_damage = 1;
boomerang_kills = true;
level = -1;			//flying: hits Link on either level, ignores walls
depth = DEPTH_FLYING;

zone = noone;		//stays inside the camera zone it starts in
state = "perch";
timer = 0;
move_dir = 0;
image_speed = 0;