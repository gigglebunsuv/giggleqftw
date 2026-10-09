/// @description Fly; a mirage's shot does no harm

if (!fake) {
	event_inherited();
	exit;
}
if (level_wall_at(x, y, level) || !enemy_is_active()) {
	instance_destroy();
	exit;
}
if (instance_exists(obj_link) && place_meeting(x, y, obj_link)) {instance_destroy()}
