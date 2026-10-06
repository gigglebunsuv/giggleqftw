/// @description Bomb: fuse, then explode
//Hurts Link and enemies in range and breaks obj_bomb_wall (see bomb_explode).
//level is set by item_use_bombs()

sprite_index = spr_bomb;
image_speed = 0;
level = 0;
timer = BOMB_FUSE;
exploded = false;
