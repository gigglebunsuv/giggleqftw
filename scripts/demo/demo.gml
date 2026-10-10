//The dungeon demo (branch new-dungeon-demo): only the Southern Tower is playable.
//PLAY on the title (demo_start) puts Link at the tower's entrance with the demo's kit and no save
//file. The front door doesn't lead out (demo_door_blocked), and once the Bun's text box is closed
//the boss's room goes to the thank-you screen (rm_thanks, obj_thanks) with the stats (demo_stats_take).
//No debug menu (DEBUG_MENU is false in the debug_menu script).

#macro DEMO_DOOR_TEXT "THE WAY HOME CAN WAIT. THE FIRST PIECE OF THE BUN IS SOMEWHERE ABOVE..."

//Counted while playing, shown on the thank-you screen
global.demo_kills = 0;			//enemies beaten (enemy_hurt)
global.demo_chests = 0;			//chests opened in the tower, and how many there are (demo_stats_take)
global.demo_chests_total = 0;

///demo_start();
function demo_start() {
	//PLAY: a fresh game at the Southern Tower's entrance with 3 hearts, the level 1 sword, the wooden
	//shield, bombs, the lantern, the flute and a bottle of red potion. Link is made first: his Create
	//event sets up a new game's gear, which save_reset_progress then clears.
	save_start_link(TOWER_START_X, TOWER_START_Y);
	save_reset_progress();
	global.save_slot = -1;	//no file: the game over screen and the pause screen don't offer saving
	global.player_name = "";
	global.intro_pending = false;
	global.pHealthMax = 6;
	global.pHealth = 6;
	global.pMagic = global.pMagicMax;
	global.swordTier = 1;
	shield_set_tier(1);			//on A
	item_give(ITEM.LANTERN);	//on Y (the tower's dark rooms)
	item_give(ITEM.BOMBS);		//on X
	bottle_give(BOTTLE.RED);	//the bottle and the flute are on the pause screen's items page
	item_give(ITEM.FLUTE);
	global.pBombs = global.pBombsMax;
	global.demo_kills = 0;
	global.demo_chests = 0;
	global.demo_chests_total = 0;
	global.pause_block = true;	//so Link ignores the button that started the game
	room_goto(rm_southern_tower);


}

///demo_door_blocked(warp);
function demo_door_blocked(argument0) {
	//Run by obj_warp when Link walks onto it: the tower's front door (out to the overworld) only
	//says a line and steps Link back inside. Returns true if it did.
	if (argument0.targetRoom != rm_overworld) return false;
	if (instance_exists(obj_dialogue)) return true;
	with (obj_link) {
		y = argument0.bbox_top - 9;
		dir = "up";
		sprite_index = player_get_sprite(dir);
	}
	dialogue_start(DEMO_DOOR_TEXT);
	return true;


}

///demo_stats_take();
function demo_stats_take() {
	//Run by obj_boss_arena just before the thank-you screen, while the tower's chests are still here
	global.demo_chests_total = instance_number(obj_chest);
	global.demo_chests = 0;
	with (obj_chest) {
		if (opened) {global.demo_chests++}
	}


}

///demo_time_text(seconds);
function demo_time_text(argument0) {
	//Play time as M:SS (or H:MM:SS past an hour)
	var secs = floor(argument0);
	var hrs = secs div 3600;
	var mins = (secs div 60) mod 60;
	var s = secs mod 60;
	var t = ((s < 10) ? "0" : "") + string(s);
	if (hrs > 0) {return string(hrs) + ":" + ((mins < 10) ? "0" : "") + string(mins) + ":" + t}
	return string(mins) + ":" + t;


}
