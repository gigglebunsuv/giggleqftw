/// @description Antlion: lives in the middle of a patch of quicksand (see antlion_step)
//Drags Link in while he's wading in it, bites, and is only hittable just after.

event_inherited();
hp = ANTLION_HP;
contact_damage = 0;
kb_speed = 0;
invulnerable = true;
depth = DEPTH_LOWER + 2;
state = "hide";
timer = 30;
image_speed = 0;
