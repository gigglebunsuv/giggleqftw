/// @description Frog: sits, leaps at Link, lashes its tongue at him (see frog_step)

event_inherited();
hp = FROG_HP;
contact_damage = FROG_DAMAGE;
level = 0;
depth = DEPTH_LOWER;
bog = false;

state = "sit";
timer = irandom_range(20, 60);
face = choose(-1, 1);	//its sprite faces right: -1 flips it
z = 0;					//height of its leap (only drawn)
leap_dir = 0;
leap_len = 0;
tongue = 0;				//pixels the tongue is out
image_speed = 0;
