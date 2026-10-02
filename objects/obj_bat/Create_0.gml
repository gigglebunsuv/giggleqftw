/// @description Bat: rests, then flutters around (towards Link when he's close)

event_inherited();
hp = 1;
contact_damage = 1;
level = -1;			//flying: hits Link on either floor, ignores walls
depth = DEPTH_FLYING;

spd = 1.2;
range = 112;		//flies towards Link inside this distance
zone = noone;		//stays inside the camera zone it starts in
state = "rest";
timer = irandom_range(30, 90);
turn_timer = 0;
move_dir = random(360);
image_speed = 0;
