/// @description Explosions, then the roof gives out the rewards (obj_boss_arena)

instance_create_depth(x, y - z, depth - 1, obj_gargoyle_death);
//Its falling rocks and fireballs go with it (they could still hurt Link during the explosions)
with (obj_gargoyle_rock) {instance_destroy()}
with (obj_gargoyle_shot) {instance_destroy()}