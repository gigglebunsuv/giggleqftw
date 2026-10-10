/// @description The boss beaten? On to the next. Back in the Hall at the end: the keeper's words.

if (finished) {
	if (rush_after_finish()) {instance_destroy()}
	exit;
}
rush_step();
