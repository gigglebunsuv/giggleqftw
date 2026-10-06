/// @description Burn the fuse, explode, finish the explosion

if (global.cam_transition) {image_speed = 0; exit;}

if (!exploded) {
	//Flashes, faster when it's about to go off
	timer--;
	var rate = 10;
	if (timer < BOMB_FUSE div 3) {rate = 3}
	image_index = (timer div rate) mod 2;
	if (timer <= 0) {bomb_explode()}
} else {
	image_speed = 0.3;
	if (image_index + image_speed >= image_number) {instance_destroy()}
}
