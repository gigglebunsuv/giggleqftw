/// @description Shield up in front, turn towards Link (slowly), walk at him

knight_guard();
event_inherited();
if (!active) exit;
if (kb_timer > 0 || stun_timer > 0) exit;
knight_step();
