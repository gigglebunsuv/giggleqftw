/// @description A gate of light over a doorway: blocks the way (child of obj_wall) until it opens
//Stretch it over the opening (the sprite is tiled, not stretched). In its Creation Code set:
//	need = "torches";				opens once every torch close to it is lit (the lantern, the fire rod)
//	need = "sword"; tier = 4;		opens when struck with a sword this strong (weaker ones clink off)
//	need = "flag"; open_flag = "x";	opens once that story flag is set
//	need = "lightning";				an iron gate (drawn with spr_iron_gate): opens when the lightning rod's bolt hits it
//	flag = "some_flag";				remembered: it stays open for the rest of the game
//See world_gate_open_now in the world script.

need = "torches";
tier = 0;
open_flag = "";
flag = "";
clink_timer = 0;
told = false;		//need = "lightning": its hint was shown (struck with the sword)
checked = false;
image_speed = 0;