/// @description Ripples and eyes under the water, the lurker when it's up

image_index = lurker_frame();
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, image_blend, (state == "under") ? 0.75 : image_alpha);
