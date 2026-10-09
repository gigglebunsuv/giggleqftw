/// @description Flipped? Otherwise sidle and charge

event_inherited();
if (!active) exit;
crab_flip_check();
if (kb_timer > 0 || stun_timer > 0) exit;

crab_step();
