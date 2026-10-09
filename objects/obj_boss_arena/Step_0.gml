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
//Dungeon demo: no warp out. Once the Bun's text box is closed, on to the thank-you screen.
if (!portal_out && flag_get(boss_reward_flag(global.dungeon, "bun"))) {
	if (instance_exists(obj_link) && obj_link.state == "idle" && !instance_exists(obj_dialogue) && !instance_exists(obj_item_get)) {
		thanks_timer++;
		if (thanks_timer >= THANKS_DELAY) {
			portal_out = true;
			room_goto(rm_thanks);
		}
	}
}
