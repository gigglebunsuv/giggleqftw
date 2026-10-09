/// @description Fade to another room (room_fade_start sets these, see the room_fade script)
//Persistent: it changes room once the screen is covered and fades in over the new one.

target_room = noone;
target_x = 0;
target_y = 0;
warp = false;			//the blue warp: spin and fade to white
out_time = ROOM_FADE_TIME;
hold_time = ROOM_FADE_HOLD;
in_time = ROOM_FADE_TIME;
colour = c_black;
timer = 0;
spin = 0;
arrived = false;
