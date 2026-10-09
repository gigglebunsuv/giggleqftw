/// @description Lurker: lives in deep water, rises to spit mud at Link, dives (see lurker_step)
//Place its origin in the middle of a deep-water tile. Creation Code: enemy_bog_variant(); spits twice.

event_inherited();
hp = LURKER_HP;
contact_damage = LURKER_DAMAGE;
depth = DEPTH_LOWER;
kb_speed = 0;		//it doesn't get knocked out of the water
bog = false;

home_level = 0;		//the level it's on when it's up
state = "under";
timer = irandom_range(30, 90);
turn = 0;
move_dir = random(360);
mouth = 0;			//steps its mouth stays open after spitting
anim_t = random(2);
image_speed = 0;
lurker_set("under", timer);
