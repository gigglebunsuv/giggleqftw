/// @description Already beaten? Give out the rewards, then the warp

if (!checked) {
	checked = true;
	//Beaten before: no boss this time (and no explosions). The Hall of Echoes' rush brings him back.
	if (flag_get(boss_flag(global.dungeon)) && !rush_wants(boss_object)) {
		with (boss_object) {instance_destroy(id, false)}
	}
}
//The last boss: once he's gone, his defeat (obj_king_defeat) has the music and what comes next
if (final && !instance_exists(boss_object)) exit;
boss_music_step();
if (final) exit;
if (rush_active()) exit;	//the Hall of Echoes: no rewards, no warp out (see the echoes script)
if (!flag_get(boss_flag(global.dungeon))) exit;

if (!rewards_out) {
	rewards_out = true;
	boss_rewards_spawn();
}
//Dungeon demo: no warp out. Once the Bun has been picked up and its text box is closed, the
//stats are taken and it's on to the thank-you screen (rm_thanks, see the demo script).
if (!portal_out && flag_get(boss_reward_flag(global.dungeon, "bun"))) {
	if (!instance_exists(obj_link) || obj_link.state != "idle") exit;
	if (instance_exists(obj_dialogue) || instance_exists(obj_item_get)) exit;
	thanks_timer++;
	if (thanks_timer >= THANKS_DELAY) {
		portal_out = true;
		demo_stats_take();
		room_goto(rm_thanks);
	}
}
