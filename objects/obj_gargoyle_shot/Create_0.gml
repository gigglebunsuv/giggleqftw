/// @description Fireball spat by the Gargoyle (works like a skeleton's bone)

event_inherited();
sprite_index = spr_fireball;
speed = 2.2;
damage = GARG_SHOT_DAMAGE;
shield_tier = 1;	//any shield blocks it
spin = 0;
sfx_play(SFX_FIREBALL);
