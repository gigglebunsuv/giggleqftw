/// @description Blade trap: slides at Link when he lines up with it, then back (see blade_trap_step)
//Place it on a tile's middle. Can't be hurt, and isn't an enemy (rooms count as cleared without it).

home_x = x;
home_y = y;
state = "wait";
move_dir = 0;
level = 0;
depth = DEPTH_LOWER;
image_speed = 0;
