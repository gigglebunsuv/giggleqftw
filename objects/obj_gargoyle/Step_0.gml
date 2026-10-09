/// @description Fly, swoop, perch, get pulled down

if (!arena_ready) {
	arena_ready = true;
	arena_zone = cam_zone_at(x, y);
	with (obj_boss_arena) {
		other.arena_x = x;
		other.arena_y = y;
		other.arena_zone = cam_zone_at(x, y);
	}
	perch = instance_position(x, y, obj_tower_pillar);
}

event_inherited();
if (!active) exit;
gargoyle_step();
