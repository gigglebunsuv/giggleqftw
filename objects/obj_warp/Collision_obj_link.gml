if (targetRoom == noone) exit;
sfx_play(SFX_WARP);
room_goto(targetRoom);
obj_link.x = targetX;
obj_link.y = targetY;