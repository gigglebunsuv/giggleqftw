/// @description Perch, swoop, flutter, stay in its zone

event_inherited();
if (!active) {image_speed = 0; exit;}
if (kb_timer > 0 || stun_timer > 0) exit;

crow_step();