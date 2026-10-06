/// @description Hammer swing: raised over Link's head, then brought down in front of him
//Hits enemies (damage + stun) and flattens pegs (obj_peg).
//The hammer turns on the end of its handle, held in Link's hands (see the Draw event).

timer = 0;
wind_at = 3;	//step it's pulled all the way back
hit_at = 7;		//step it comes down
done_at = 14;
ang = 0;
if (instance_exists(obj_link)) {ang = player_face_angle(obj_link.dir)}

//How far through the swing it is: 0 = raised behind, 1 = down in front (set in Step)
swing = 0.3;

//Raised and struck positions for the way Link faces. spr_item_hammer stands upright, so
//rotation 0 is head up; yscale below 0 flips it to point down the screen (up/down swings
//are seen end-on, so they flip over instead of turning). Hands are offsets from Link.
//			[rotation, yscale, hand x, hand y]
//spr_item_hammer's striking face points left, so it's mirrored (xscale) for right swings.
//Up/down swings use spr_item_hammer_end, the head seen end-on: the face toward the screen
//when swinging down, the back of the head when swinging up.
spr = spr_item_hammer;
img = 0;
xscale = 1;
switch (ang) {
	case 0:		raised = [65, 1, -4, -6];	struck = [-90, 1, 6, 2];	xscale = -1;	break;	//right
	case 180:	raised = [-65, 1, 4, -6];	struck = [90, 1, -6, 2];	break;	//left
	case 270:	raised = [0, 1, 0, -7];		struck = [0, -1, 0, 3];		spr = spr_item_hammer_end;	break;	//down
	default:	raised = [0, -0.35, 0, -8];	struck = [0, 0.8, 0, -5];	spr = spr_item_hammer_end;	img = 1;	break;	//up
}

//The end of the handle (both sprites' origin is the top left)
grip_x = 8;
grip_y = 15;

sfx_play(SFX_HAMMER);
