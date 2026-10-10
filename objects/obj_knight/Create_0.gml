/// @description Royal knight: a tall shield that turns everything from the front (see the castle_enemies script)

event_inherited();
hp = KNIGHT_HP;
contact_damage = KNIGHT_DAMAGE;
tier_done = true;
level = 0;
depth = DEPTH_LOWER;
kb_speed = 1.5;
face = 270;
turn_t = irandom(KNIGHT_TURN);
anim_t = 0;
walking = false;
image_speed = 0;
