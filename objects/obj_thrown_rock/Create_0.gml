/// @description Heavy rock thrown by Link (see player_throw_rock)
//Flies a few tiles in an arc and breaks when it lands, hits a wall, or hits an enemy (ROCK_DAMAGE).
//x, y is the spot on the ground under it; z is its height (it starts over Link's head).
//direction and level are set by player_throw_rock.

spd = 4;			//pixels per step
fly_time = 14;		//steps until it lands (about 3.5 tiles)
start_z = 15;
arc = 6;			//extra height in the middle of the throw
z = start_z;
timer = 0;
level = 0;
