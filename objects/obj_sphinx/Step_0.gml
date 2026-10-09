/// @description Sit, slam, bow, shoot, split, quake

if (!arena_ready) {
	arena_ready = true;
	arena_zone = cam_zone_at(x, y - 8);
}
stun_timer = 0;	//nothing stuns it
event_inherited();
if (!active) exit;
sphinx_step();
