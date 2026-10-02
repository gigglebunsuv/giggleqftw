/// @description Skeleton: walks around, stops and throws a bone when it sees Link

event_inherited();
hp = 3;
contact_damage = 2;
level = 0;
depth = DEPTH_LOWER;

spd = 0.5;
sight = 112;		//how far it can see Link
move_dir = choose(0, 90, 180, 270);
move_timer = irandom_range(40, 100);
state = "walk";
aim_timer = 0;
aim_time = 30;		//the pause before throwing
throw_cd = 60;		//time until it can throw again
image_speed = 0;
