/// @description Sahran, the Mirage Sphinx, the Tower of Ladhellin's boss (boss_sphinx script)
//Place it where its front paws rest, with an obj_boss_arena in the room too
//(boss_object = obj_sphinx; in the arena's Creation Code).

event_inherited();
hp = SPHINX_HP;
hp_max = SPHINX_HP;
hp_last = hp;
kb_speed = 0;		//far too heavy to knock back
depth = DEPTH_LOWER - 5;
home_x = x;
home_y = y;
wake = 0;
cycle = 0;
anim_t = 0;
image_speed = 0;
sphinx_set("dormant", 0);

//Its room (set on the first step)
arena_zone = noone;
arena_ready = false;
