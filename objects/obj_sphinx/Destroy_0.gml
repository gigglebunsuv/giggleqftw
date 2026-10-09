/// @description Explosions, then the room gives out the rewards (obj_boss_arena)

instance_create_depth(x, y - 20, depth - 1, obj_gargoyle_death);
with (obj_sphinx_mirage) {instance_destroy(id, false)}
with (obj_sand_wave) {instance_destroy()}
with (obj_sand_shot) {instance_destroy()}
