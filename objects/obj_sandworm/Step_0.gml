/// @description Dig, come up, spin, dig back down

event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;
sandworm_step();
