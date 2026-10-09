/// @description Drift about, lose a segment when hit

event_inherited();
if (!active) exit;
if (stun_timer > 0) exit;
cactus_step();
