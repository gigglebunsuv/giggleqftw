/// @description Grapple hook (works like the hookshot)
//Flies out; grabs obj_grapple_point and pulls Link to it, stuns enemies, bounces off walls.
//direction, image_angle and level are set by item_use_grapple()

sprite_index = spr_hookshot;
state = "out";	//"out", "back" (reeling in) or "pull" (pulling Link)
spd_out = 5;
spd_back = 6;
spd_pull = 4;
max_dist = 96;	//length of the chain
dist = 0;
level = 0;
target = noone;	//the grapple point it caught
carry = noone;	//a small key (obj_key) it grabbed and is bringing back
