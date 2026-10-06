/// @description Picked up when Link touches it, blinks and goes after a while

image_index = kind;
life--;
visible = life > 60 || (life div 3) mod 2 == 0;
if (life <= 0) {
	instance_destroy();
	exit;
}
if (instance_exists(obj_link) && place_meeting(x, y, obj_link)) {
	pickup_collect(kind);
	instance_destroy();
}
