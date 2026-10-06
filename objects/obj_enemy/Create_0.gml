/// @description Shared enemy setup (parent of every enemy)
//Children run event_inherited() and then change these.

hp = 1;
contact_damage = 1;	//half hearts taken when Link touches it
level = 0;			//0 lower floor, 1 upper floor, -1 flying (any floor)
active = true;		//false while Link is in another camera zone

hurt_timer = 0;
kb_timer = 0;
kb_dir = 0;
kb_speed = 3;
stun_timer = 0;			//frozen by the boomerang or grapple hook
boomerang_kills = false;	//true: the boomerang kills it instead
