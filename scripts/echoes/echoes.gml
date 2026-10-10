//The Hall of Echoes: a crypt in Old Castle Town's graveyard that opens once the Evil King is beaten
//(its gate wants GAME_CLEAR_FLAG). Its stone keeper (an obj_npc with dlg_echo_keeper) sends Link to fight
//every boss again, one after another, in their own rooms: the Gargoyle, the Bog Tower's guardian, the
//Sphinx, then back to the Hall to rest (a fairy heals him), then Velrune and the Evil King. Health and
//magic aren't refilled between fights. Dying ends the rush (CONTINUE starts him back in the Hall).
//Beating it the first time: the ECHO CHARM (Link takes half the damage, see player_damage_taken) and a
//silver cup on the file select (ECHOES_FLAG).
//
//global.rush_stage: 0 = no rush, otherwise the stage (1-based, see rush_stages). obj_echo_rush (persistent,
//made by rush_start) puts Link in each boss's room and notices when the boss is beaten. While a rush is
//on, the bosses come back even though they were beaten before (rush_wants), and give no rewards.

#macro ECHOES_FLAG "echoes_clear"
#macro ECHO_CHARM_FLAG "echo_charm"
#macro RUSH_NEXT_DELAY 90		//steps after a boss is gone before the next fight

global.rush_stage = 0;

///rush_stages();
function rush_stages() {
	//Each stage: the room, the boss object, its name. room = -1: rest in the Hall.
	return [
		{rm: rm_southern_tower, boss: obj_gargoyle, name: "THE GARGOYLE"},
		{rm: rm_bog_tower, boss: obj_bog_boss, name: "THE GUARDIAN OF THE BOG"},
		{rm: rm_ladhellin_tower, boss: obj_sphinx, name: "THE SPHINX"},
		{rm: -1, boss: noone, name: "REST"},
		{rm: rm_castle, boss: obj_archmage, name: "VELRUNE THE ARCHMAGE"},
		{rm: rm_castle, boss: obj_evil_king, name: "THE EVIL KING"}
	];


}

///rush_active();
function rush_active() {
	return variable_global_exists("rush_stage") && global.rush_stage > 0;


}

///rush_wants(boss_object);
function rush_wants(argument0) {
	//True while the rush's current fight is against this boss (it comes back, beaten or not)
	if (!rush_active()) return false;
	var st = rush_stages();
	var i = global.rush_stage - 1;
	if (i < 0 || i >= array_length(st)) return false;
	return st[i].boss == argument0;


}

///dlg_echo_keeper();
function dlg_echo_keeper() {
	//The stone keeper in the Hall of Echoes
	if (rush_active() && global.rush_stage == 4) {
		return [
			"THE ECHOES OF THE TOWERS ARE STILLED. TWO REMAIN: THE ARCHMAGE, AND THE KING HIMSELF.",
			dlg_choice("FACE THEM NOW?", [
				["YES", [dlg_run(function() {rush_next()})]],
				["NOT YET", ["REST, THEN. I WILL WAIT."]]
			])
		];
	}
	var steps = [];
	if (!flag_get(ECHOES_FLAG)) {
		array_push(steps, "I AM THE KEEPER OF ECHOES. EVERY GUARDIAN YOU FELLED LEFT AN ECHO IN THESE STONES.");
		array_push(steps, "FACE THEM ALL, ONE AFTER ANOTHER. YOUR WOUNDS WILL NOT HEAL BETWEEN THEM, SAVE ONCE, HALFWAY. WIN, AND THEIR ECHOES WILL GUARD YOU.");
	} else {
		array_push(steps, "THE ECHOES STIR AGAIN. THEY REMEMBER YOU.");
	}
	array_push(steps, dlg_choice("FACE THE ECHOES?", [
		["YES", [dlg_run(function() {rush_start()})]],
		["NO", ["COME BACK WHEN YOUR BLADE IS READY."]]
	]));
	return steps;


}

///rush_start();
function rush_start() {
	//The keeper's YES: the first fight
	global.rush_stage = 0;
	if (!instance_exists(obj_echo_rush)) {instance_create_depth(0, 0, 0, obj_echo_rush)}
	rush_next();


}

///rush_next();
function rush_next() {
	//On to the next stage: a boss's room, the Hall to rest, or the end
	global.rush_stage++;
	var st = rush_stages();
	if (global.rush_stage > array_length(st)) {
		rush_finish();
		return;
	}
	var s = st[global.rush_stage - 1];
	with (obj_echo_rush) {
		placed = false;
		seen_boss = false;
		gone_t = 0;
	}
	if (s.rm == -1) {
		room_fade_start(rm_interiors, ECHOES_X, ECHOES_Y, true);
		return;
	}
	var e = dungeon_entrance(dungeon_of_room(s.rm));
	room_fade_start(s.rm, e[1], e[2], true);


}

///rush_room_start();
function rush_room_start() {
	//Run by obj_echo_rush at Room Start: put Link in front of this stage's boss (or rest in the Hall)
	if (!rush_active()) return;
	var st = rush_stages();
	var s = st[global.rush_stage - 1];
	if (s.rm == -1) {
		if (room == rm_interiors && !placed) {
			placed = true;
			global.pHealth = global.pHealthMax;
			global.pMagic = global.pMagicMax;
			sfx_play(SFX_FAIRY);
			dialogue_start(["A FAIRY FLUTTERS OUT OF THE DARK AND HEALS YOUR WOUNDS. SPEAK TO THE KEEPER WHEN YOU ARE READY."]);
		}
		return;
	}
	if (room != s.rm) return;
	var b = instance_find(s.boss, 0);
	if (b == noone) return;
	var z = cam_zone_at(b.x, b.y);
	if (z == noone) return;
	//The middle of the bottom of the boss's room, or the first spot up from it Link can stand on
	var px = (z.bbox_left + z.bbox_right + 1) div 2;
	var py = z.bbox_bottom - 24;
	with (obj_link) {
		for (var k = 0; k < 40; k++) {
			var ty = py - k * 8;
			if (!place_meeting(px, ty, obj_wall) && !place_meeting(px, ty, obj_wall_low) && !place_meeting(px, ty, obj_water)
				&& !position_meeting(px, ty, obj_pit)) {
				py = ty;
				break;
			}
		}
		x = px;
		y = py;
		dir = "up";
		sprite_index = player_get_sprite(dir);
		entry_x = x;
		entry_y = y;
		safe_x = x;
		safe_y = y;
		if (level_room_uses_levels()) {level_set(0)}
	}
	camera_snap();
	placed = true;
	floor_name_show(s.name);


}

///rush_step();
function rush_step() {
	//Run by obj_echo_rush: once this stage's boss is gone (and its death throes are over), the next stage
	if (!rush_active()) {
		instance_destroy();
		return;
	}
	var st = rush_stages();
	var s = st[global.rush_stage - 1];
	//Resting in the Hall, and Link walked out instead of carrying on: the rush is over
	if (s.rm == -1 && room != rm_interiors && !instance_exists(obj_room_fade)) {
		global.rush_stage = 0;
		instance_destroy();
		return;
	}
	if (s.rm == -1 || room != s.rm || !placed) return;
	if (instance_exists(s.boss)) {
		seen_boss = true;
		return;
	}
	if (!seen_boss) return;
	if (instance_exists(obj_gargoyle_death) || instance_exists(obj_dialogue) || instance_exists(obj_room_fade)) return;
	if (s.boss == obj_evil_king) return;	//his defeat (obj_king_defeat) moves on itself (see king_defeat_step)
	gone_t++;
	if (gone_t >= RUSH_NEXT_DELAY) {
		gone_t = 0;
		seen_boss = false;
		rush_next();
	}


}

///rush_finish();
function rush_finish() {
	//Every echo beaten: back to the Hall, the reward the first time
	global.rush_stage = 0;
	with (obj_link) {
		state = "idle";
		visible = true;
		pose = -1;
	}
	var first = !flag_get(ECHOES_FLAG);
	flag_set(ECHOES_FLAG, true);
	global.rush_reward = first;
	room_fade_start(rm_interiors, ECHOES_X, ECHOES_Y, true);
	with (obj_echo_rush) {finished = true}


}

///rush_after_finish();
function rush_after_finish() {
	//Run by obj_echo_rush back in the Hall after the last fight: the keeper's words (and the charm)
	if (room != rm_interiors || instance_exists(obj_room_fade)) return false;
	var steps = ["THE LAST ECHO FADES. THE STONES ARE QUIET... AND THEY ARE WATCHING OVER YOU NOW."];
	if (global.rush_reward) {
		var got = world_give({equip: "echo_charm"});
		for (var i = 0; i < array_length(got); i++) {array_push(steps, got[i])}
	}
	dialogue_start(steps);
	return true;


}

///rush_fail_continue();
function rush_fail_continue() {
	//Run by obj_player_death's CONTINUE: a death in the rush ends it, and Link starts again in the Hall.
	//Returns true if it did that (the room is changed, nothing else to do).
	if (!rush_active()) return false;
	global.rush_stage = 0;
	with (obj_echo_rush) {instance_destroy()}
	with (obj_link) {
		state = "idle";
		hurt_timer = 0;
		image_alpha = 1;
		x = ECHOES_X;
		y = ECHOES_Y;
		dir = "down";
		sprite_index = player_get_sprite(dir);
	}
	instance_activate_all();
	room_goto(rm_interiors);
	return true;


}
