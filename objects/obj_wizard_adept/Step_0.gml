/// @description Blink in, gather a spell, cast, blink out

event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;
wizard_step();
