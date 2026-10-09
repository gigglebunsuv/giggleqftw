/// @description Slime: squishes about, hopping (at Link when he's close, see slime_step)
//Creation Code can give it the marsh's look: sprite_index = spr_slime_bog;

event_inherited();
hp = 2;
contact_damage = 1;
boomerang_kills = true;
level = 0;
depth = DEPTH_LOWER;

state = "sit";
timer = irandom_range(10, 60);
move_dir = 0;
z = 0;		//height of its hop (only drawn)
anim_t = random(2);
image_speed = 0;