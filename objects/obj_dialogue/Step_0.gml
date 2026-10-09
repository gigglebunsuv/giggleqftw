/// @description Type out the text, next box, pick an answer

input_get();

//Start during the opening skips it (see the cutscene script)
if (act_start && global.cutscene_on) {
	global.cutscene_skip = true;
	dialogue_close();
	exit;
}

//Freeze the game once the frame with the NPC turned to Link has been drawn.
//This also skips the button that started talking, which still counts as pressed.
if (!frozen) {
	if (!drawn) exit;
	snap = hud_snapshot();	//the view only, not the HUD bar
	instance_deactivate_all(true);
	instance_activate_object(obj_link);
	instance_activate_object(obj_hud_main);
	with (obj_link) {state = "talk"}
	frozen = true;
	exit;
}

//A shop's counter is open instead of the text box
if (shop_on) {
	shop_ui_step();
	exit;
}

//Typing out: A or B shows the rest of the box at once
if (shown < page_len) {
	var before = floor(shown);
	shown = min(shown + DIALOGUE_SPEED, page_len);
	if (floor(shown) != before && floor(shown) mod 3 == 1) {sfx_play(SFX_TEXT)}
	if (act_a || act_b) {shown = page_len}
	exit;
}

//Last box of a question: pick an answer (B picks the last one)
if (page == array_length(pages) - 1 && array_length(choices) > 0) {
	var n = array_length(choices);
	if (menu_move != 0) {
		cursor = (cursor + menu_move + n) mod n;
		audio_play_sound(menu_switch, 2, false);
	}
	if (act_a || act_b) {
		if (act_b) {cursor = n - 1}
		audio_play_sound(menu_select, 3, false);
		dialogue_pick(cursor);
	}
	exit;
}

//Next box, or the next step of the conversation
if (act_a || act_b) {
	if (page < array_length(pages) - 1) {
		page += 1;
		shown = 0;
		page_len = dialogue_page_length(pages[page]);
	} else {
		dialogue_advance();
	}
}
