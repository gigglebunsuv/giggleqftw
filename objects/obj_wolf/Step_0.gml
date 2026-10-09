/// @description Prowl, spot Link, crouch, lunge

event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;

wolf_step();