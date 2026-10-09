/// @description Swim under the surface, rise, spit, dive

event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;	//the grapple hook holds it up, stunned

lurker_step();
