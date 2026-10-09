/// @description Crab: shelled (blades clink off), flipped over by the grapple hook, boomerang,
//hammer or ice rod, and then it can be hurt. Sidles to line up with Link and charges (see crab_step).

event_inherited();
hp = CRAB_HP;
contact_damage = CRAB_DAMAGE;
level = 0;
depth = DEPTH_LOWER;
kb_speed = 2;
invulnerable = true;	//until it's flipped
flipped = false;
bog = false;

state = "walk";
timer = irandom_range(20, 50);
wander = choose(0, 90, 180, 270);
charge_dir = 0;
anim_t = 0;
image_speed = 0;
