/// @description Already beaten? Give out the rewards, then the warp

if (!checked) {
	checked = true;
	//Beaten before: no boss this time (and no explosions)
	if (flag_get(boss_flag(global.dungeon))) {
		with (obj_gargoyle) {instance_destroy(id, false)}
	}
}
boss_music_step();
if (!flag_get(boss_flag(global.dungeon))) exit;

if (!rewards_out) {
	rewards_out = true;
	boss_rewards_spawn();
}
//Once the Bun has been picked up, a warp out (back to the overworld)
if (!portal_out && flag_get(boss_reward_flag(global.dungeon, "bun"))) {
	portal_out = true;
	var p = instance_create_depth(x - 8, y - 8, DEPTH_DECOR, obj_warp_portal);
	p.targetRoom = exit_room;
	p.targetX = exit_x;
	p.targetY = exit_y;
}