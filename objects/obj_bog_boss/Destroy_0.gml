/// @description Explosions, then the room gives out the rewards (obj_boss_arena)

instance_create_depth(x, y - 20, depth - 1, obj_gargoyle_death);
with (obj_mud_shot) {instance_destroy()}
with (obj_lurker) {instance_destroy()}
