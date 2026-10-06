/// @description Pit: Link falls in unless he jumps over it with the cape
//(see player_pit_check and player_jump_step). Walking enemies won't walk in.
//The sprite is spr_pixel, so scale it to the hole's size in the room editor (16 x 16 for one tile),
//or paint tiles on a "Pits" tile layer instead (see collision_tiles_make).
//Draws a placeholder hole: untick Visible once the room's tiles show the pits.

depth = DEPTH_DECOR;	//on the floor, under Link and enemies
