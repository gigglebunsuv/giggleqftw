/// @description Already opened earlier in the game? Open now?

if (!checked) {
	checked = true;
	if (flag != "" && flag_get(flag)) {
		instance_destroy();
		exit;
	}
}
if (clink_timer > 0) {clink_timer--}
if (world_gate_open_now()) {world_gate_open()}