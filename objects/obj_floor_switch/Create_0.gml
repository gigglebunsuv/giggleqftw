/// @description Floor switch: stepping on it presses it for good (opens "switch" shutter doors)
//A push block resting on it presses it too. Set hold = true in its Creation Code for a switch that's
//only down while Link or a block is on it ("switches" shutter doors want every one down at once).

hold = false;
pressed = false;
checked = false;
depth = DEPTH_DECOR;
image_speed = 0;
