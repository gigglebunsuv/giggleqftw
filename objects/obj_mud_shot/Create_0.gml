/// @description Lump of mud spat by a lurker or the boss (works like a skeleton's bone)
//direction, level and damage are set by bog_spit

event_inherited();
sprite_index = spr_mud_shot;
speed = 2.2;
damage = LURKER_SHOT_DAMAGE;
shield_tier = 1;	//any shield blocks it
spin = 0;
