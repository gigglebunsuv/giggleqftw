/// @description Dust devil: can't be hurt; flings Link a long way (see dust_devil_step)

event_inherited();
hp = 1;
invulnerable = true;
contact_damage = 0;
ignore_clear = true;
kb_speed = 0;
depth = DEPTH_LOWER - 1;
home_x = x;
home_y = y;
state = "whirl";
life = DUST_LIFE + irandom(120);
timer = 0;
weave = random(360);
anim_t = 0;
image_speed = 0;
