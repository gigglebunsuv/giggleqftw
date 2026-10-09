/// @description Cracked floor: falls away a moment after Link steps on it (see the ladhellin script)
//It comes back once he's left the room. The Sphinx's quake drops them too (crumble_now).

state = "whole";
timer = 0;
back_timer = 0;		//steps until it comes back by itself (0 = when Link leaves the room)
hole = noone;		//the obj_pit while it's gone
zone = noone;		//its room (set on the first step)
depth = DEPTH_DECOR;
image_speed = 0;
