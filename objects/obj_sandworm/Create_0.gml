/// @description Sandworm: burrows under the floor, comes up near Link and spins after him (see sandworm_step)

event_inherited();
hp = SANDWORM_HP;
contact_damage = SANDWORM_DAMAGE;
depth = DEPTH_LOWER;
wander = random(360);
anim_t = 0;
image_speed = 0;
sandworm_set("under", irandom_range(30, 90));
