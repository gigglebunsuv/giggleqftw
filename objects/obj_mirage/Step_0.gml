/// @description Only the lens lets blades bite. Float after Link.

invulnerable = !lens_active();
event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;
mirage_step();
