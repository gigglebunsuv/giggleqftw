/// @description Swim, rise, spit, open up, lunge

if (!arena_ready) {
	arena_ready = true;
	arena_zone = cam_zone_at(x, y);
}

event_inherited();
if (!active) exit;
bogb_step();
