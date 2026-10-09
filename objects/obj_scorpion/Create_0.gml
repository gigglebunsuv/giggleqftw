/// @description Scorpion: walks in straight lines, dashes at Link down its row or column (see scorpion_step)

event_inherited();
hp = 3;
contact_damage = 2;
level = 0;
depth = DEPTH_LOWER;

spd = 0.6;
face = choose(0, 90, 180, 270);
state = "walk";
timer = irandom_range(30, 80);
anim_t = 0;
image_speed = 0;