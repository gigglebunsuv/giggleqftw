/// @description Spitter: a plant that never moves, spits seeds at Link (see spitter_step)

event_inherited();
hp = 2;
contact_damage = 1;
level = 0;
depth = DEPTH_LOWER;
kb_speed = 0;		//rooted: hits don't knock it back

reload = irandom_range(20, SPITTER_RELOAD);	//steps until the next seed
mouth = 0;		//steps its mouth stays open
image_speed = 0;