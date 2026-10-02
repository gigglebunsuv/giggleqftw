/// @description Next frame, gone after the last one

timer++;
var frame = timer div frame_steps;
if (frame >= image_number) {
	instance_destroy();
} else {
	image_index = frame;
}
