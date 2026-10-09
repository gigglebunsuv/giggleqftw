/// @description Cactus: a stack of spiny segments; each hit knocks one off (see cactus_step)
//Its health is only there so a hit can be noticed: segments is what counts.

event_inherited();
hp = CACTUS_SEGMENTS * 100;
hp_last = hp;
segments = CACTUS_SEGMENTS;
contact_damage = CACTUS_DAMAGE;
kb_speed = 0;
depth = DEPTH_LOWER;
move_dir = choose(45, 135, 225, 315);
anim_t = random(6);
image_speed = 0;
