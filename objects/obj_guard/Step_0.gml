/// @description Patrol, spot Link, charge

event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;

guard_step();
guard_animate();
