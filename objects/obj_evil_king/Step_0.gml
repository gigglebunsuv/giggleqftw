/// @description Throne, rise, orbs, volleys, shadows, storms, dizzy

if (!arena_ready) {
	arena_ready = true;
	arena_zone = cam_zone_at(x, y + 16);
}
stun_timer = 0;	//nothing stuns him
event_inherited();
if (!active) exit;
king_step();
