/// @description A cliff with no railing (invisible marker, scaled over the cliff's tiles)
//It's a wall for the level above land_level, but Link walking down into it from there hops off,
//down to land_level past the cliff (see ledge_hop_check and level_wall_at in the levels script).
//Only for cliffs on the south side of raised floor (Link hops down the screen).
//Set land_level = 1 in the Creation Code for a cliff of the third level.

land_level = 0;
