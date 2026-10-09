/// @description Sit, crouch, leap, tongue

event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;

frog_step();
