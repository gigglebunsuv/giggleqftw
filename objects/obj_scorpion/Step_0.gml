/// @description Walk, dash, rest

event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;

scorpion_step();