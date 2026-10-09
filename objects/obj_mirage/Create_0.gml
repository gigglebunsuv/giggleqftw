/// @description Mirage wraith: all but invisible, only the Sun Lens shows it (see mirage_step)
//Only while the lens is up can it be hurt.

event_inherited();
hp = MIRAGE_HP;
contact_damage = MIRAGE_DAMAGE;
level = -1;
depth = DEPTH_FLYING;
kb_speed = 2;
anim_t = random(10);
zone = noone;
image_speed = 0;
