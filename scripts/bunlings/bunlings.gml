//The lost bunlings: BUNLINGS_TOTAL little bunnies hidden all over Haven (obj_bunling: under ledges, behind
//cracked walls, brambles, rushing water, in caves, houses and the Arcanum). Walking into one finds it
//(a story flag per bunling, "bunling_" + its bunling_id) and it hops off home to the bunny keeper by
//Haven's fountain. She thanks Link with a reward at 5, 10, 15 and 20 (dlg_bunny_keeper); the last is
//the BUNNY TUNIC: purely for looks, put on and taken off on the pause screen's QUEST page (A).

#macro BUNLINGS_TOTAL 20
#macro TUNIC_FLAG "tunic_bunny"			//Link has the bunny tunic
#macro TUNIC_ON_FLAG "tunic_bunny_on"	//...and is wearing it
#macro SFX_BUNLING "snd_bunling"		//a bunling found

///bunling_flag(id);
function bunling_flag(argument0) {
	return "bunling_" + argument0;


}

///bunlings_found();
function bunlings_found() {
	//How many bunlings Link has found (the count is kept in its own flag)
	var n = flag_get("bunlings_found");
	if (!is_real(n)) return 0;
	return n;


}

///bunling_found(id);
function bunling_found(argument0) {
	//A bunling is found: its flag, the count, and a word on it
	if (flag_get(bunling_flag(argument0))) return;
	flag_set(bunling_flag(argument0), true);
	var n = bunlings_found() + 1;
	flag_set("bunlings_found", n);
	sfx_play(SFX_BUNLING);
	var line = "YOU FOUND A LOST BUNLING! THAT'S " + string(n) + " OF " + string(BUNLINGS_TOTAL) + ". IT HOPS OFF HOME TO THE BUNNY KEEPER IN HAVEN.";
	if (instance_exists(obj_dialogue)) {dialogue_insert([line])}
	else {dialogue_start([line])}


}

///bunling_step();
function bunling_step() {
	//Run by obj_bunling: gone once found; found when Link walks into it (not in the air)
	if (flag_get(bunling_flag(bunling_id))) {
		instance_destroy();
		return;
	}
	image_index = ((current_time div 300) + hop) mod 2;
	if (!instance_exists(obj_link) || instance_exists(obj_dialogue)) return;
	if (obj_link.z > 0 || obj_link.state == "dead") return;
	if (place_meeting(x, y, obj_link)) {
		instance_create_depth(x - 12, y - 12, depth - 1, obj_enemy_death);
		bunling_found(bunling_id);
		instance_destroy();
	}


}

///dlg_bunny_keeper();
function dlg_bunny_keeper() {
	//The bunny keeper by the fountain: thanks for the bunlings brought home, the rewards at 5, 10, 15, 20
	var n = bunlings_found();
	var steps = [];
	if (n == 0) {
		return [
			"OH, SIR GIGGLEBUNS! MY BUNLINGS RAN OFF WHEN THE ORDER'S SOLDIERS CAME. ALL " + string(BUNLINGS_TOTAL) + " OF THEM!",
			"THEY HIDE IN THE STRANGEST PLACES: CAVES, HOUSES, BEHIND ROCKS AND BRAMBLES... IF YOU FIND ONE, IT'LL KNOW ITS WAY HOME.",
			"BRING THEM BACK AND I'LL MAKE IT WORTH YOUR WHILE!"
		];
	}
	array_push(steps, "YOU'VE FOUND " + string(n) + " OF MY " + string(BUNLINGS_TOTAL) + " BUNLINGS! THEY'RE ALL HOME SAFE AND FAT ON CLOVER.");
	var given = false;
	if (n >= 5 && !flag_get("bunreward_5")) {
		given = true;
		array_push(steps, dlg_set("bunreward_5"));
		array_push(steps, "FOR THE FIRST FIVE: TAKE THIS. IT'S NOT MUCH, BUT IT'S HONEST.");
		array_push(steps, dlg_run(function() {dialogue_insert(world_give({equip: "money", amount: 100}))}));
	}
	if (n >= 10 && !flag_get("bunreward_10")) {
		given = true;
		array_push(steps, dlg_set("bunreward_10"));
		array_push(steps, "TEN! HERE, MY OWN RECIPE: BLUE POTION, FOR EVERY EMPTY BOTTLE YOU CARRY. NO EMPTY ONES? THEN MONEY.");
		array_push(steps, dlg_run(function() {
			var filled = 0;
			for (var i = 0; i < BOTTLES; i++) {
				if (global.item_have[ITEM.BOTTLE_1 + i] && global.bottles[i] == BOTTLE.EMPTY) {
					global.bottles[i] = BOTTLE.BLUE;
					filled++;
				}
			}
			if (filled > 0) {
				sfx_play(SFX_ITEM_GET);
				dialogue_insert(["YOUR EMPTY BOTTLES ARE FULL OF BLUE POTION!"]);
			} else {
				dialogue_insert(world_give({equip: "money", amount: 200}));
			}
		}));
	}
	if (n >= 15 && !flag_get("bunreward_15")) {
		given = true;
		array_push(steps, dlg_set("bunreward_15"));
		array_push(steps, "FIFTEEN! YOU'RE A HERO TO EVERY BUNNY IN HAVEN. TAKE THIS!");
		array_push(steps, dlg_run(function() {dialogue_insert(world_give({equip: "money", amount: 300}))}));
	}
	if (n >= BUNLINGS_TOTAL && !flag_get(TUNIC_FLAG)) {
		given = true;
		array_push(steps, "ALL OF THEM! EVERY LAST ONE! I KNITTED THIS FROM THEIR WINTER FLUFF, JUST FOR YOU.");
		array_push(steps, dlg_run(function() {dialogue_insert(world_give({equip: "tunic"}))}));
	}
	if (!given) {
		if (n >= BUNLINGS_TOTAL) {array_push(steps, "HOW DOES THE TUNIC FIT? YOU LOOK ADORABLE. VERY KNIGHTLY. ADORABLY KNIGHTLY.")}
		else {
			var next = (n < 5) ? 5 : ((n < 10) ? 10 : ((n < 15) ? 15 : BUNLINGS_TOTAL));
			array_push(steps, "FIND " + string(next - n) + " MORE AND I'LL HAVE SOMETHING FOR YOU.");
		}
	}
	return steps;


}

///tunic_worn();
function tunic_worn() {
	return flag_get(TUNIC_FLAG) && flag_get(TUNIC_ON_FLAG);


}

///tunic_toggle();
function tunic_toggle() {
	//The pause screen's QUEST page: A puts the bunny tunic on or takes it off (just looks: armor still counts)
	if (!flag_get(TUNIC_FLAG)) return false;
	flag_set(TUNIC_ON_FLAG, !flag_get(TUNIC_ON_FLAG));
	return true;


}

///bunling_ids();
function bunling_ids() {
	//Every bunling's bunling_id (the rooms' and the shooting gallery's), for the debug menu
	return ["road_shrine", "road_cave", "forest_ring", "forest_cave", "hidden_forest", "river_rapids",
		"barn_hayloft", "sfields_hill", "castletown_iron", "castle_graves", "marsh_bramble", "desert_crack",
		"oasis_island", "cliffs_pegs", "cliff_peak", "gallery", "arcanum_1", "arcanum_2", "arcanum_3", "arcanum_4"];


}
