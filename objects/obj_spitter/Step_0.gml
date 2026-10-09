/// @description Turn to Link, spit

event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;

spitter_step();