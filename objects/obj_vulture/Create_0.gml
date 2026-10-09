/// @description Vulture: perches, then circles high over Link and dives at him (see vulture_step)
//x, y is its shadow on the ground; it's drawn z pixels up.

event_inherited();
hp = VULTURE_HP;
contact_damage = VULTURE_DAMAGE;
level = -1;
depth = DEPTH_FLYING;
kb_speed = 2;
state = "perch";
timer = 0;
z = 0;
anim_t = 0;
circle_ang = random(360);
face = 1;
dive_x = x;
dive_y = y;
zone = noone;
image_speed = 0;
