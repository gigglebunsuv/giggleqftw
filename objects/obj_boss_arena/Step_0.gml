/// @description Already beaten? Give out the rewards, then the warp

if (!checked) {
	checked = true;
	//Beaten before: no boss this time (and no explosions)
	if (flag_get(boss_flag(global.dungeon))) {
		with (boss_object) {instance_destroy(id, false)}
	}
}
boss_music_step();
if (!flag_get(boss_flag(global.dungeon))) exit;

if (!rewards_out) {
	rewards_out = true;
	boss_rewards_spawn();
}
//Once the Bun has been picked up, a warp out (back to the overworld). It waits until the Bun's
//text box is closed and Link isn't standing on the spot, so it doesn't whisk him away mid-message.
if (!portal_out && flag_get(boss_reward_flag(global.dungeon, "bun"))) {
	if (instance_exists(obj_dialogue) || instance_exists(obj_item_get)) exit;
	if (instance_exists(obj_link) && rectangle_in_rectangle(reward_x - 8, reward_y - 8, reward_x + 7, reward_y + 7,
		obj_link.bbox_left, obj_link.bbox_top, obj_link.bbox_right, obj_link.bbox_bottom) != 0) exit;
	portal_out = true;
	var p = instance_create_depth(reward_x - 8, reward_y - 8, DEPTH_DECOR, obj_warp_portal);
	p.targetRoom = exit_room;
	p.targetX = exit_x;
	p.targetY = exit_y;
}