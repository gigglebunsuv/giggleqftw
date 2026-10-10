//Warp statues: the flute's warp spots out in the world (obj_flute_spot) are old stone statues. Each one
//sleeps until Link faces it and presses A: then it wakes (its eyes glow, a story flag remembers it) and
//the flute's warp menu lists it (see obj_flute_menu). Link appears just in front of (below) the statue.
//Place them by the middle of their tile, like NPCs, with ground free below them;
//spot_name = "VILLAGE"; in the Creation Code (capital letters: it's the menu's name and the flag's).

///warp_statue_flag();
function warp_statue_flag() {
	//Run by obj_flute_spot: the story flag set once it's awake
	return "warp_statue_" + spot_name;


}

///warp_statue_awake();
function warp_statue_awake() {
	//Run by obj_flute_spot
	return flag_get(warp_statue_flag());


}

///warp_statue_steps();
function warp_statue_steps() {
	//Run as obj_flute_spot's dialogue (bound to it): wakes it the first time
	if (warp_statue_awake()) {
		return ["THE STATUE'S EYES GLOW SOFTLY. PLAY YOUR FLUTE OUT IN THE OPEN AND IT WILL CALL YOU BACK HERE."];
	}
	return [
		"AN OLD STATUE OF A RABBIT WITH A FLUTE. ITS STONE IS COLD. YOU LAY YOUR HAND ON IT...",
		dlg_run(function() {
			flag_set(warp_statue_flag(), true);
			sfx_play(SFX_SECRET);
		}),
		"ITS EYES BEGIN TO GLOW! " + spot_name + " IS NOW A WARP POINT FOR YOUR FLUTE."
	];


}

///warp_statue_draw();
function warp_statue_draw() {
	//Run by obj_flute_spot: asleep (frame 0) or awake (frame 1), standing on its 16x16 spot
	var sx = (bbox_left + bbox_right + 1) / 2 - sprite_get_width(sprite_index) / 2 + sprite_get_xoffset(sprite_index);
	var sy = bbox_bottom + 1 - sprite_get_height(sprite_index) + sprite_get_yoffset(sprite_index);
	draw_sprite(sprite_index, warp_statue_awake() ? 1 : 0, sx, sy);


}
