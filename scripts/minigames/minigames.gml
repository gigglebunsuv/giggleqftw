//Haven's minigames:
//	THE SHOOTING GALLERY (rm_interiors, the fairground south of the village): pay GALLERY_PRICE, then
//		GALLERY_TIME to shoot as many targets (obj_gallery_target) as Link can with his own bow (the
//		gallery lends him a full quiver; his own arrows are put back after). Gold targets are worth 3.
//		GALLERY_GOAL points the first time: a lost bunling; after that, money for every point.
//		obj_gallery runs it (one in the room, anywhere); the attendant's dialogue is dlg_gallery.
//	THE TREASURE CHESTS (next door): pay CHEST_GAME_PRICE and open one of the chests in the room
//		(obj_chest with remember = false). obj_chest_game runs it; the attendant's dialogue is dlg_chest_game.
//	FISHING (the fisherman by the marsh lake, once his part in the hammer's trading chain is done): pay
//		FISHING_PRICE for FISHING_CASTS casts. obj_fishing is a little scene over the frozen game: wait
//		for the bobber to dip, press A at once. The biggest fish of the day is weighed: a legendary one
//		(FISHING_LEGEND cm or more) the first time is worth a piece of heart.

#macro GALLERY_PRICE 20
#macro GALLERY_TIME 900			//steps (30 seconds)
#macro GALLERY_GOAL 15			//points for the bunling
#macro GALLERY_FLAG "gallery_won"
#macro CHEST_GAME_PRICE 20
#macro FISHING_PRICE 20
#macro FISHING_CASTS 3
#macro FISHING_LEGEND 60		//cm
#macro FISHING_FLAG "fishing_legend"
#macro SFX_TARGET "snd_target"	//a target hit in the shooting gallery
#macro SFX_BITE "snd_bite"		//a fish biting

//================================================================ the shooting gallery

///dlg_gallery();
function dlg_gallery() {
	if (instance_exists(obj_gallery) && obj_gallery.active) return ["SHOOT, SHOOT! THE CLOCK'S RUNNING!"];
	if (!global.item_have[ITEM.BOW]) {
		return ["STEP RIGHT UP... OH. NO BOW? COME BACK WHEN YOU'VE GOT ONE. THE TARGETS DON'T SHOOT THEMSELVES!"];
	}
	var prize = flag_get(GALLERY_FLAG) ? "EVERY POINT IS WORTH 2 MONEY." : "SCORE " + string(GALLERY_GOAL) + " AND I'LL GIVE YOU SOMETHING SPECIAL!";
	return [
		"WELCOME TO THE HAVEN SHOOTING GALLERY! THIRTY SECONDS, AS MANY TARGETS AS YOU CAN. GOLD ONES ARE WORTH THREE!",
		"I'LL LEND YOU A FULL QUIVER. " + prize,
		dlg_choice("PLAY FOR " + string(GALLERY_PRICE) + " MONEY?", [
			["YES", [dlg_if(function() {return global.pMoney >= GALLERY_PRICE;}, [
				dlg_run(function() {
					player_add_money(-GALLERY_PRICE);
					with (obj_gallery) {gallery_start()}
				}),
				"READY... GO!"
			], ["YOU'RE A LITTLE SHORT, FRIEND."])]],
			"NO"
		])
	];


}

///gallery_create();
function gallery_create() {
	//Run by obj_gallery's Create
	active = false;
	timer = 0;
	points = 0;
	spawn_t = 0;
	saved_arrows = 0;
	zone = noone;
	lanes = [];
	result = false;


}

///gallery_start();
function gallery_start() {
	//Run by obj_gallery: a round starts (the attendant's dialogue)
	zone = cam_zone_at(x, y);
	active = true;
	timer = GALLERY_TIME;
	points = 0;
	spawn_t = 0;
	saved_arrows = global.pArrows;
	global.pArrows = global.pArrowsMax;
	with (obj_gallery_target) {instance_destroy(id, false)}


}

///gallery_step();
function gallery_step() {
	//Run by obj_gallery: targets come and go, the clock runs down, then the result
	if (!active) return;
	if (instance_exists(obj_dialogue)) return;
	if (zone == noone || !instance_exists(zone)) {zone = cam_zone_at(x, y)}
	//Link walked out: the round's over (no prize)
	if (global.cam_zone != zone) {
		gallery_end(false);
		return;
	}
	timer--;
	spawn_t--;
	if (spawn_t <= 0) {
		spawn_t = 28 + irandom(18);
		//Two lanes along the back of the room, the targets crossing one way or the other
		var lane = irandom(1);
		var l = zone.bbox_left + 20;
		var r = zone.bbox_right - 20;
		var ty = zone.bbox_top + 56 + lane * 18;
		var right = (irandom(1) == 0);
		var t = instance_create_depth(right ? l : r, ty, DEPTH_LOWER - 1, obj_gallery_target);
		t.spd = (right ? 1 : -1) * random_range(1.2, 2.4);
		t.min_x = l - 4;
		t.max_x = r + 4;
		if (irandom(6) == 0) {
			t.gold = true;
			t.spd *= 1.5;
			t.image_index = 1;
		}
	}
	if (timer <= 0) {gallery_end(true)}


}

///gallery_end(finished);
function gallery_end(argument0) {
	//Run by obj_gallery: time's up (or Link left). His own arrows back, the prize.
	active = false;
	with (obj_gallery_target) {instance_destroy(id, false)}
	global.pArrows = min(saved_arrows, global.pArrowsMax);
	if (!argument0) return;
	var p = points;
	var steps = ["TIME'S UP! YOU SCORED " + string(p) + (p == 1 ? " POINT." : " POINTS.")];
	if (!flag_get(GALLERY_FLAG) && p >= GALLERY_GOAL) {
		flag_set(GALLERY_FLAG, true);
		array_push(steps, "INCREDIBLE! HERE: THIS LITTLE FELLOW WANDERED IN AND WON'T STOP STARING AT YOU. TAKE HIM HOME!");
		array_push(steps, dlg_run(function() {bunling_found("gallery")}));
	} else if (flag_get(GALLERY_FLAG) && p > 0) {
		array_push(steps, dlg_run(method({p: p}, function() {player_add_money(p * 2)})));
		array_push(steps, "HERE'S " + string(p * 2) + " MONEY. NICE SHOOTING!");
	} else if (!flag_get(GALLERY_FLAG)) {
		array_push(steps, "SO CLOSE! SCORE " + string(GALLERY_GOAL) + " AND THE SPECIAL PRIZE IS YOURS.");
	}
	dialogue_start(steps);


}

///gallery_target_step();
function gallery_target_step() {
	//Run by obj_gallery_target: slide along its lane, gone at the far end
	x += spd;
	if (x < min_x || x > max_x) {instance_destroy(id, false)}


}

///gallery_target_hit();
function gallery_target_hit() {
	//Run by obj_gallery_target's Destroy: shot (not just slid away)
	if (hp > 0) return;
	sfx_play(SFX_TARGET);
	var worth = gold ? 3 : 1;
	with (obj_gallery) {points += worth}


}

///gallery_draw_gui();
function gallery_draw_gui() {
	//Run by obj_gallery's Draw GUI: the time and the points while a round is on
	if (!active) return;
	if (!variable_global_exists("hud_font")) {
		global.hud_font = font_add_sprite_ext(spr_menu_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
	}
	var a = hud_play_area();
	draw_set_font(global.hud_font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_sprite_ext(spr_pixel, 0, a[0] + 4, a[1] + 4, 120, 14, 0, c_black, 0.7);
	menu_draw_text(a[0] + 8, a[1] + 7, "TIME " + string(ceil(timer / 30)) + "  PTS " + string(points));


}

//================================================================ the treasure chests

///dlg_chest_game();
function dlg_chest_game() {
	if (instance_exists(obj_chest_game) && obj_chest_game.active) return ["GO ON, PICK ONE! JUST ONE, MIND."];
	return [
		"TREASURE! TREASURE! ONE OF MY CHESTS HOLDS A FORTUNE. THE OTHERS... LESS OF ONE.",
		dlg_choice("OPEN A CHEST FOR " + string(CHEST_GAME_PRICE) + " MONEY?", [
			["YES", [dlg_if(function() {return global.pMoney >= CHEST_GAME_PRICE;}, [
				dlg_run(function() {
					player_add_money(-CHEST_GAME_PRICE);
					with (obj_chest_game) {chest_game_start()}
				}),
				"THE CHESTS ARE SHUT AND SHUFFLED. PICK ONE!"
			], ["NO MONEY, NO TREASURE."])]],
			"NO"
		])
	];


}

///chest_game_create();
function chest_game_create() {
	active = false;
	zone = noone;
	ready = false;


}

///chest_game_chests();
function chest_game_chests() {
	//Run by obj_chest_game: the chests in its room
	var out = [];
	var z = zone;
	with (obj_chest) {
		if (z != noone && point_in_rectangle(x + 8, y + 8, z.bbox_left, z.bbox_top, z.bbox_right, z.bbox_bottom)) {array_push(out, id)}
	}
	return out;


}

///chest_game_start();
function chest_game_start() {
	//Run by obj_chest_game: shut the chests and fill them (one fortune, the rest small change)
	var cs = chest_game_chests();
	var n = array_length(cs);
	var prizes = [5, 10, 20, 50, 1, 5];
	var big = irandom(n - 1);
	for (var i = 0; i < n; i++) {
		with (cs[i]) {
			opened = false;
			remember = false;
			item = ITEM.NONE;
			equip = "money";
			amount = (i == big) ? choose(50, 100, 100, 150) : prizes[irandom(array_length(prizes) - 1)];
			message = (i == big) ? "THE FORTUNE! WELL PICKED!" : "";
		}
	}
	active = true;


}

///chest_game_step();
function chest_game_step() {
	//Run by obj_chest_game: the chests stay open (empty) between rounds; once one is opened, the
	//rest stay shut for good this round
	if (!ready) {
		ready = true;
		zone = cam_zone_at(x, y);
	}
	var cs = chest_game_chests();
	if (!active) {
		for (var i = 0; i < array_length(cs); i++) {cs[i].opened = true}
		return;
	}
	for (var i = 0; i < array_length(cs); i++) {
		if (cs[i].opened) {
			active = false;
			for (var j = 0; j < array_length(cs); j++) {cs[j].opened = true}
			return;
		}
	}


}

//================================================================ fishing

///dlg_fishing_offer();
function dlg_fishing_offer() {
	//The fisherman's offer, once the big fish are back (see dlg_fisherman)
	return dlg_choice("FANCY A GO AT MY FISHING HOLE? " + string(FISHING_CASTS) + " CASTS FOR " + string(FISHING_PRICE) + " MONEY.", [
		["YES", [dlg_if(function() {return global.pMoney >= FISHING_PRICE;}, [
			dlg_run(function() {
				player_add_money(-FISHING_PRICE);
				instance_create_depth(0, 0, -1000, obj_fishing);
			}),
			"WATCH THE BOBBER. WHEN IT DIPS, PULL! " + (flag_get(FISHING_FLAG) ? "" : "THEY SAY A LEGEND LIVES IN THIS LAKE...")
		], ["NO MONEY? THEN JUST WATCH ME FISH."])]],
		"NO"
	]);


}

///fishing_create();
function fishing_create() {
	casts = FISHING_CASTS;
	phase = "start";		//start, cast, wait, bite, caught, missed, done
	timer = 20;
	best = 0;
	last = 0;
	bob_x = 0;
	nibble = 0;
	snap = -1;
	menu_font = -1;
	small_font = -1;


}

///fishing_step();
function fishing_step() {
	//Run by obj_fishing: the game is frozen; cast, wait, strike
	if (phase == "start") {
		timer--;
		if (timer > 0) return;
		if (instance_exists(obj_dialogue)) {timer = 1; return}
		snap = hud_snapshot();
		instance_deactivate_all(true);
		menu_font = font_add_sprite_ext(spr_menu_font, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
		small_font = font_add_sprite_ext(spr_font_small, " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-:!?.'/", false, 0);
		phase = "ready";
		return;
	}
	input_get();
	switch (phase) {
		case "ready":
			if (act_a) {
				phase = "cast";
				timer = 20;
				bob_x = 40 + irandom(100);
				sfx_play(SFX_THROW);
			}
			if (act_b) {fishing_finish()}
			break;
		case "cast":
			timer--;
			if (timer <= 0) {
				phase = "wait";
				timer = 60 + irandom(180);
				sfx_play(SFX_SPLASH);
			}
			break;
		case "wait":
			timer--;
			nibble = (irandom(40) == 0) ? 6 : max(0, nibble - 1);
			if (act_a) {			//too soon: the fish is gone
				phase = "missed";
				timer = 50;
				casts--;
				break;
			}
			if (timer <= 0) {
				phase = "bite";
				timer = 16;
				sfx_play(SFX_BITE);
			}
			break;
		case "bite":
			timer--;
			if (act_a) {
				//Hooked: how big? Mostly small, now and then a big one, rarely a legend
				var r = random(1);
				last = (r < 0.55) ? 10 + irandom(15) : ((r < 0.88) ? 25 + irandom(20) : ((r < 0.96) ? 45 + irandom(14) : FISHING_LEGEND + irandom(20)));
				best = max(best, last);
				phase = "caught";
				timer = 70;
				casts--;
				sfx_play(SFX_ITEM_GET);
				break;
			}
			if (timer <= 0) {
				phase = "missed";
				timer = 50;
				casts--;
			}
			break;
		case "caught":
		case "missed":
			timer--;
			if (timer <= 0 || act_a) {
				if (casts <= 0) {fishing_finish()}
				else {phase = "ready"}
			}
			break;
	}


}

///fishing_finish();
function fishing_finish() {
	//Run by obj_fishing: back to the game, and the fisherman weighs the biggest catch
	instance_activate_all();
	global.pause_block = true;
	var b = best;
	var steps = [];
	if (b <= 0) {
		steps = ["NOTHING TODAY? THE LAKE'S MOODY. COME BACK ANY TIME."];
	} else if (b >= FISHING_LEGEND && !flag_get(FISHING_FLAG)) {
		flag_set(FISHING_FLAG, true);
		steps = ["WHAT... WHAT IS THAT?! " + string(b) + " CM! THAT'S THE LEGEND OF THE LAKE!",
			"MY GRANDPA CAUGHT HIM ONCE, AND HE GAVE ME THIS. NOW IT'S YOURS."];
		var got = world_give({equip: "heart_piece"});
		for (var i = 0; i < array_length(got); i++) {array_push(steps, got[i])}
	} else {
		var money = b;
		player_add_money(money);
		sfx_play(SFX_MONEY);
		steps = ["YOUR BIGGEST: " + string(b) + " CM. NOT BAD! HERE'S " + string(money) + " MONEY FOR IT."];
	}
	instance_destroy();
	dialogue_start(steps);


}

///fishing_draw();
function fishing_draw() {
	//Run by obj_fishing's Draw GUI: the frozen game, dimmed, and the fishing scene in a box
	if (phase == "start") return;
	var gw = display_get_gui_width();
	var gh = display_get_gui_height();
	var area = hud_play_area();
	menu_draw_rect(0, 0, gw, gh, c_black);
	if (snap != -1) {draw_sprite_stretched_ext(snap, 0, area[0], area[1], area[2], area[3], c_white, 0.4)}
	hud_draw_bar();
	var bw = 200;
	var bh = 112;
	var bx = (gw - bw) div 2;
	var by = area[1] + (area[3] - bh) div 2;
	menu_draw_box(bx, by, bw, bh);
	//The lake
	var wy = by + 40;
	menu_draw_rect(bx + 8, wy, bw - 16, bh - 56, make_colour_rgb(16, 92, 104));
	for (var i = 0; i < 6; i++) {
		var sx = bx + 12 + ((i * 37 + current_time div 60) mod (bw - 30));
		menu_draw_rect(sx, wy + 6 + i * 7, 8, 1, make_colour_rgb(86, 179, 192));
	}
	draw_set_font(menu_font);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	menu_draw_text(bx + bw div 2, by + 6, "FISHING  " + string(casts) + " LEFT");
	draw_set_font(small_font);
	if (best > 0) {menu_draw_text(bx + bw div 2, by + 18, "BIGGEST " + string(best) + " CM")}
	var cx = bx + 8 + bob_x;
	var cy = wy + 20;
	switch (phase) {
		case "ready":
			menu_draw_text(bx + bw div 2, by + bh - 12, "A: CAST   B: STOP");
			break;
		case "cast":
			draw_sprite(spr_bobber, 0, cx, cy - timer);
			break;
		case "wait":
			draw_sprite(spr_bobber, 0, cx, cy + ((nibble > 0) ? 1 : 0));
			menu_draw_text(bx + bw div 2, by + bh - 12, "WAIT FOR IT...");
			break;
		case "bite":
			draw_sprite(spr_bobber, 1, cx, cy + 3);
			draw_set_font(menu_font);
			menu_draw_text_colour(cx + 4, cy - 14, "!", MENU_COL_CURSOR);
			draw_set_font(small_font);
			menu_draw_text(bx + bw div 2, by + bh - 12, "NOW! PRESS A!");
			break;
		case "caught":
			var f = (last >= FISHING_LEGEND) ? 3 : ((last >= 45) ? 2 : ((last >= 25) ? 1 : 0));
			draw_sprite(spr_fish, f, bx + bw div 2 - 8, wy + 10);
			menu_draw_text(bx + bw div 2, by + bh - 12, "CAUGHT ONE! " + string(last) + " CM");
			break;
		case "missed":
			menu_draw_text(bx + bw div 2, by + bh - 12, "IT GOT AWAY...");
			break;
	}
	draw_set_halign(fa_left);


}

///fishing_cleanup();
function fishing_cleanup() {
	if (snap != -1 && sprite_exists(snap)) {sprite_delete(snap)}
	if (menu_font != -1) {font_delete(menu_font)}
	if (small_font != -1) {font_delete(small_font)}


}
