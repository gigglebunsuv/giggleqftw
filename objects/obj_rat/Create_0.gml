/// @description Rat: scurries about in quick dashes (see rat_step)

event_inherited();
hp = 1;
contact_damage = 1;
boomerang_kills = true;
level = 0;
depth = DEPTH_LOWER;

spd = 1.8;
state = "pause";
timer = irandom_range(10, 60);
move_dir = choose(0, 90, 180, 270);
anim_t = 0;
image_speed = 0;
