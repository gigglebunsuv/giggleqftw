/// @description Tower guard: patrols, then charges Link with its sword when it sees him (guard script)

event_inherited();
hp = 4;
contact_damage = 2;
level = 0;
depth = DEPTH_LOWER;

spd = 0.6;
charge_spd = 2.2;
face = choose(0, 90, 180, 270);	//the way it faces (right, up, left, down)
charge_dir = face;
move_timer = irandom_range(50, 110);
state = "patrol";
timer = 0;
walking = false;
anim_t = 0;
image_speed = 0;
