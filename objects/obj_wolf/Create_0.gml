/// @description Wolf: prowls, then crouches and lunges at Link when it sees him (see wolf_step)

event_inherited();
hp = 3;
contact_damage = 2;
level = 0;
depth = DEPTH_LOWER;

spd = 0.7;
face = choose(0, 90, 180, 270);	//the way it faces (right, up, left, down)
lunge_dir = face;
state = "prowl";
timer = irandom_range(40, 100);
walking = false;
anim_t = 0;
image_speed = 0;