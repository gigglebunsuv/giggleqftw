/// @description Gate to the hidden forest
//Blocks the way (child of obj_wall) until Link has all the Bun pieces.
//Stretch it over the opening; the sprite is tiled, not stretched.

if (bun_count() >= BUN_PIECES) {instance_destroy()}
