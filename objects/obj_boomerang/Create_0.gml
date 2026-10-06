/// @description Boomerang: flies out, stuns enemies (kills bats), comes back to Link
//direction and level are set by item_use_boomerang()

sprite_index = spr_boomerang;
mask_index = spr_hookshot;	//small 8x8 hitbox, so it doesn't catch on walls it flies along
state = "out";
spd = 4;
max_dist = 80;	//how far it flies before turning back
dist = 0;
level = 0;
