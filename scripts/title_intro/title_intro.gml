//The story crawl and title reveal before the title menu (obj_title).
//Timed to the Title music: the story scrolls up during the slow opening, then when the
//main theme kicks in the background fades in and the logo slides down into place.

#macro TITLE_THEME_START 24		//seconds into the Title music where the main theme kicks in
#macro TITLE_CRAWL_END 23.5		//the last line of the story leaves the top of the screen here
#macro TITLE_CRAWL_LINE 16		//pixels between lines of the story
#macro TITLE_FADE_TIME 60		//steps for the background to fade in
#macro TITLE_SLIDE_TIME 45		//steps for the logo to slide in
#macro TITLE_SLIDE_FROM -64		//where the logo starts, above its place (it spans y 9 to 62)
#macro TITLE_MENU_X 172			//middle of the title choices (in the field right of the cliff)
#macro TITLE_MENU_Y 128			//top of the title choices
#macro TITLE_DEMO_Y 68			//"DUNGEON DEMO", under the logo
#macro TITLE_IDLE_TIME 30		//seconds on the menu with no button pressed before the intro plays again

///title_intro_start();
function title_intro_start() {
	//Starts (or restarts) the Title music and the story crawl. Call from obj_title.
	audio_stop_all();
	options_volume_apply();
	music = audio_play_sound(Title, 1, false);
	intro = 0;
	intro_steps = 0;	//steps since the intro started (used if the music isn't playing)
	intro_timer = 0;	//steps into the fade or the slide
	idle_steps = 0;		//steps on the menu since the last button press
	menu = 0;			//back to the main choices
	cursor = 0;


}

///title_intro_story();
function title_intro_story() {
	//The story, one entry per line, centred. Max 30 characters a line.
	//Only capital letters, numbers, spaces and - : ! ? . ' / , (the menu font, plus commas).
	return [
		"IN THE LAND OF BUNSRIEL,",
		"THE SAPPHIRE ORDER HAVE",
		"RESURRECTED THE EVIL KING",
		"FIREBUNS I.",
		"WITH HIS POWER AND THEIRS,",
		"THEY HAVE ATTACKED AND",
		"SIEGED THE THREE FORTRESSES",
		"OF HAVEN, AND THE CASTLE",
		"OF BUNSRIEL.",
		"",
		"SIR GIGGLEBUNS III IS TASKED",
		"TO STOP THEM.",
		"HE MUST RETRIEVE THE STOLEN",
		"PIECES OF BUN FROM THE",
		"FORTRESSES TO AWAKEN THE",
		"MIGHTY SWORD OF BUN, AND",
		"DEFEAT THE EVIL KING, AND",
		"RESTORE PEACE TO BUNSRIEL."
	];


}

///title_intro_time(music, steps);
function title_intro_time(argument0, argument1) {
	//Seconds into the music. Reads the music itself so the crawl stays in time with it;
	//counts steps instead if the music isn't playing.
	if (audio_is_playing(argument0)) {return audio_sound_get_track_position(argument0)}
	return argument1 / game_get_speed(gamespeed_fps);


}

///title_intro_draw_crawl(seconds, gui_w, gui_h);
function title_intro_draw_crawl(argument0, argument1, argument2) {
	//Scrolls up from just below the screen until the last line leaves the top at TITLE_CRAWL_END.
	//Call from a Draw GUI event with the menu font set.
	var lines = title_intro_story();
	var n = array_length(lines);
	var travel = argument2 + n * TITLE_CRAWL_LINE;
	var top = round(argument2 - travel * min(argument0 / TITLE_CRAWL_END, 1));

	for (var i = 0; i < n; i++) {
		var ly = top + i * TITLE_CRAWL_LINE;
		if (ly > -TITLE_CRAWL_LINE && ly < argument2) {title_intro_draw_line(argument1 div 2, ly, lines[i])}
	}


}

///title_intro_draw_line(centre_x, y, string);
function title_intro_draw_line(argument0, argument1, argument2) {
	//Centred line in the menu font (commas too, see menu_draw_text_commas)
	draw_set_valign(fa_top);
	menu_draw_text_commas(argument0 - string_length(argument2) * 4, argument1, argument2, c_white);	//letters are 8 wide


}

///title_intro_ease(t);
function title_intro_ease(argument0) {
	//0 to 1, fast at the start and settling at the end
	var t = clamp(argument0, 0, 1);
	return 1 - power(1 - t, 3);


}
