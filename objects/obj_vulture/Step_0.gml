/// @description Perch, circle, dive

event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;
vulture_step();
