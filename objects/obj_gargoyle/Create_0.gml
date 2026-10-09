/// @description The Gargoyle, the Southern Tower's boss (boss_gargoyle script)
//Place it on the pillar it sleeps on. The roof needs an obj_boss_arena in the middle.

event_inherited();
hp = GARG_HP;
hp_max = GARG_HP;
level = -1;			//flying: over pits and walls
depth = DEPTH_FLYING;
kb_speed = 0;		//too heavy to knock back

z = GARG_PERCH_Z;
gargoyle_set("dormant", 0);
anim_t = 0;
orbit = 90;
orbit_rx = 80;		//the circle it flies round the roof (wide, flat)
orbit_ry = 44;
gust_cd = 120;
perch = noone;		//the pillar it's flying to or sitting on
shots = 0;
swoop_x0 = x;
swoop_y0 = y;
swoop_x1 = x;
swoop_y1 = y;
swoop_t = 0;
swoop_len = 1;
yank_dir = 270;
hp_at_ground = hp;

//The roof (set from obj_boss_arena on the first step)
arena_zone = noone;
arena_x = x;
arena_y = y;
arena_ready = false;
image_speed = 0;
