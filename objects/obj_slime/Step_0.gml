/// @description Sit, hop

event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;

slime_step();