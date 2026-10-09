/// @description Whirl after Link, fling him

event_inherited();
if (!active) exit;
can_touch = (state != "gone");
if (stun_timer > 0) exit;
dust_devil_step();
