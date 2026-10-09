/// @description Shamble after Link, or run about burning

event_inherited();
if (!active) exit;
if (stun_timer > 0) exit;
if (kb_timer > 0 && burning <= 0) exit;
mummy_step();
