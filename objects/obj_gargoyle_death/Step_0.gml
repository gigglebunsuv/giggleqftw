/// @description Puffs and booms for a moment

timer++;
if (timer mod 8 == 0) {
	instance_create_depth(x - 12 + irandom_range(-14, 14), y - 12 + irandom_range(-12, 12), depth, obj_enemy_death);
	sfx_play(SFX_BOMB);
}
if (timer >= 80) {
	flag_set(boss_flag(global.dungeon), true);
	instance_destroy();
}
