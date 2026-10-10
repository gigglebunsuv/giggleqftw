/// @description Murkmaw, the Bog Tower's boss (boss_bog script)
//Place it in the middle of its room's pool, with an obj_boss_arena there too
//(boss_object = obj_bog_boss; in the arena's Creation Code). Only arrows hurt it.

event_inherited();
is_boss = true;	//longer hitstop, a shake, no drops (see enemy_hurt)
drops = false;
hp = BOGB_HP;
hp_max = BOGB_HP;
hp_last = hp;
depth = DEPTH_LOWER - 5;	//its head rises over Link standing behind it
kb_speed = 0;		//too heavy to knock back

lunging = false;	//its next rise is a lunge at the shore
lunge_x = 0;
lunge_y = 0;
dest_x = x;			//where it's swimming to under the water
dest_y = y;
volleys = 1;		//mud fans before it opens up
wake = 0;
lurkers_out = false;
arrow_cd = 0;
anim_t = 0;
image_speed = 0;
bogb_set("dormant", 0);

//Its room (set on the first step)
arena_zone = noone;
arena_ready = false;
