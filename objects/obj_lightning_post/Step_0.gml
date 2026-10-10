/// @description The charge wears off

if (charged_t > 0) {charged_t--}
image_index = (charged_t > 0) ? 1 : 0;
