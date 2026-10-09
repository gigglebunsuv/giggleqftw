//The hammer: a trading chain that opens up once the Bog Tower is free. The Tower of Ladhellin's
//door is pegged shut, and only a Ladhellin stone hammer knocks the pegs down.
//	1 The fisherman (the marsh's lake): the bog's clean, the big fish are back, but his line is
//	  pinned under a heavy rock (lift it: the strength gloves). He gives Link a FRESH FISH.
//	2 The woodcutter (the forest), starving: trades an IRONWOOD BRANCH for it, once Link shoots it
//	  down from the top of the tree by his cabin (the bow).
//	3 The smith (Haven) turns the ironwood into a HAMMER HANDLE, for a fee.
//	4 The old mason (camped by the tower in the desert) fits the handle to his hammer's head and
//	  gives Link the HAMMER.
//Where Link is in the chain is the story flag TRADE_FLAG: 0 nothing yet, then TRADE_FISH,
//TRADE_IRONWOOD, TRADE_HANDLE, TRADE_DONE. The thing he's carrying shows on the pause screen's
//QUEST page (spr_trade_item, frame = the flag - 1).

#macro TRADE_FLAG "hammer_trade"
#macro TRADE_FISH 1
#macro TRADE_IRONWOOD 2
#macro TRADE_HANDLE 3
#macro TRADE_DONE 4
#macro TRADE_ROCK_FLAG "fisher_rock"	//the heavy rock on the fisherman's line has been lifted
#macro TRADE_HANDLE_PRICE 50

///trade_at();
function trade_at() {
	//How far along the chain Link is (see TRADE_FLAG)
	var t = flag_get(TRADE_FLAG);
	if (!is_real(t)) return 0;
	return t;


}

///trade_item_name(step);
function trade_item_name(argument0) {
	switch (argument0) {
		case TRADE_FISH: return "FRESH FISH";
		case TRADE_IRONWOOD: return "IRONWOOD BRANCH";
		case TRADE_HANDLE: return "HAMMER HANDLE";
	}
	return "";


}

///trade_set(step);
function trade_set(argument0) {
	//Link now carries this (the old thing is traded away), with the fanfare
	flag_set(TRADE_FLAG, argument0);
	sfx_play(SFX_FANFARE_ITEM);


}

///trade_give(step);
function trade_give(argument0) {
	//From a dlg_run: trade_set, and the text box says so
	trade_set(argument0);
	dialogue_insert(["YOU GOT THE " + trade_item_name(argument0) + "!"]);


}

///trade_quest_open();
function trade_quest_open() {
	//The chain only starts once the Bog Tower's boss is beaten
	return flag_get(boss_flag(2));


}

//================================================================ the people

///dlg_fisherman();
function dlg_fisherman() {
	//The fisherman by the lake in the marsh
	var t = trade_at();
	if (!trade_quest_open()) {
		return [
			"SHH! YOU'LL SCARE THE FISH.",
			"SEE THE LITTLE ISLAND OUT IN THE LAKE? SOMETHING SHINY SITS ON IT. IF ONLY I COULD SWIM.",
			"MY GRANDPA LEFT HIS OLD FLIPPERS IN THE CAVE DOWN IN THE SOUTH-EAST OF THE MARSH. THE FLOOR IN THERE CAVED IN, THOUGH. IT'S ALL HOLES.",
			"YOU'D NEED SOMETHING TO PULL YOU ACROSS. A HOOK ON A CHAIN, MAYBE.",
			"THE BOG TOWER? NOBODY GETS IN THERE. YOU'D HAVE TO SWIM OUT TO ITS ISLET, THEN GET OVER THE BOG SOMEHOW."
		];
	}
	if (t >= TRADE_FISH) return ["HOW'S THAT FISH? THE BIG ONES ARE BITING AGAIN, ALL THANKS TO YOU."];
	if (!flag_get(TRADE_ROCK_FLAG)) {
		return [
			"YOU DID IT! THE BOG'S CLEAN AND THE BIG FISH ARE BACK IN THE LAKE!",
			"I HOOKED A MONSTER... AND IT DRAGGED MY LINE RIGHT UNDER THAT HEAVY ROCK. I CAN'T BUDGE IT.",
			"IF SOMEONE STRONG COULD LIFT THAT ROCK OFF MY LINE..."
		];
	}
	return [
		"MY LINE'S FREE! AND LOOK AT THE SIZE OF THIS ONE!",
		"HERE, IT'S YOURS. YOU EARNED IT.",
		dlg_run(function() {trade_give(TRADE_FISH)}),
		"THE WOODCUTTER IN THE FOREST HAS BEEN LIVING ON ACORNS ALL WINTER. HE'D GIVE ANYTHING FOR A MEAL LIKE THAT."
	];


}

///dlg_woodcutter();
function dlg_woodcutter() {
	//The woodcutter by his cabin in the forest
	var t = trade_at();
	var lines = [
		"THESE WOODS GO ON FOREVER. OR THEY FEEL LIKE THEY DO.",
		"THE OLD PATH NORTH-EAST ENDS AT A GATE OF LIGHT. ONLY ONE WHO CARRIES THE WHOLE BUN CAN WALK THROUGH IT.",
		"AND THE BUSHES WEST OF HERE HIDE A LITTLE GROVE. MY GRANDPA SAID SOMETHING PRECIOUS SITS IN THERE."
	];
	if (t == TRADE_FISH) {
		return [
			"IS THAT... A FISH? A REAL FISH? I'VE EATEN NOTHING BUT ACORNS FOR WEEKS.",
			"I'LL TRADE YOU FOR IT. ALL I'VE GOT OF ANY WORTH IS THE IRONWOOD UP AT THE TOP OF THAT OLD TREE.",
			"IT'S THE TOUGHEST WOOD THERE IS. TOO HIGH FOR MY AXE, THOUGH.",
			dlg_choice("SHOOT THE BRANCH DOWN WITH AN ARROW?", [
				["YES", [
					"THWIP! ...CRACK! THE BRANCH TUMBLES DOWN THROUGH THE LEAVES.",
					dlg_run(function() {trade_give(TRADE_IRONWOOD)}),
					"WHAT A SHOT! ENJOY THAT WOOD. NOTHING MAKES A STRONGER HANDLE.",
					"THE SMITH IN HAVEN COULD SHAPE IT FOR YOU."
				]],
				["NO", ["SUIT YOURSELF... MY STOMACH WILL WAIT."]]
			])
		];
	}
	if (t == TRADE_IRONWOOD) return ["NOTHING MAKES A STRONGER HANDLE THAN IRONWOOD. THE SMITH IN HAVEN COULD SHAPE IT FOR YOU."];
	if (t > TRADE_IRONWOOD) return ["THAT FISH WAS THE BEST MEAL I'VE HAD ALL YEAR. THANK YOU, SIR GIGGLEBUNS."];
	return lines;


}

///trade_smith_steps();
function trade_smith_steps() {
	//The smith's part (see dlg_smith): ironwood into a hammer handle
	if (trade_at() != TRADE_IRONWOOD) return [];
	return [
		"IRONWOOD! I HAVEN'T SEEN A PIECE THAT GOOD IN YEARS.",
		"A HANDLE FOR A STONE HAMMER, YOU SAY? THAT'S LADHELLIN WORK. THE OLD MASON CAMPED BY THEIR TOWER MUST BE AFTER IT.",
		dlg_choice("SHAPE IT INTO A HANDLE FOR " + string(TRADE_HANDLE_PRICE) + " MONEY? YOU HAVE " + string(global.pMoney) + ".", [
			["YES", [dlg_run(function() {
				if (global.pMoney < TRADE_HANDLE_PRICE) {
					dialogue_insert(["HMPH. COME BACK WITH " + string(TRADE_HANDLE_PRICE) + " MONEY. GOOD WOOD DESERVES PAID WORK."]);
					return;
				}
				player_add_money(-TRADE_HANDLE_PRICE);
				trade_set(TRADE_HANDLE);
				dialogue_insert(["*SCRAPE* *SCRAPE*... THERE. STRAIGHT AND TRUE.",
					"YOU GOT THE " + trade_item_name(TRADE_HANDLE) + "!",
					"TAKE IT TO THE MASON IN THE DESERT."]);
			})]],
			["NO", ["IT'LL KEEP. IRONWOOD DOESN'T ROT."]]
		])
	];


}

///dlg_mason();
function dlg_mason() {
	//The last mason of Ladhellin, camped in the desert by the tower's pegged door
	var t = trade_at();
	if (t >= TRADE_DONE) {
		return [
			"KNOCK THOSE PEGS DOWN AND GO ON IN. MIND YOUR FEET: MY PEOPLE BUILT THE TOWER FULL OF GAPS.",
			"THEY SAY THE LADHELLIN JUMPED THEM WITH CAPES OF SUNCLOTH... AND THAT SOME OF THE FLOORS IN THERE ARE ONLY MIRAGES."
		];
	}
	if (t == TRADE_HANDLE) {
		return [
			"IS THAT... AN IRONWOOD HANDLE? LET ME SEE IT!",
			"*TAP* *TAP* *TAP*... THERE. THE HAMMER OF LADHELLIN, WHOLE AGAIN FOR THE FIRST TIME IN FORTY YEARS.",
			"MY ARMS ARE TOO OLD TO SWING IT. TAKE IT.",
			dlg_run(function() {
				flag_set(TRADE_FLAG, TRADE_DONE);
				dialogue_insert(world_give({item: ITEM.HAMMER}));
			}),
			"THE PEGS ON THE TOWER'S DOOR ARE YOURS TO KNOCK DOWN."
		];
	}
	var steps = [
		"I'M THE LAST MASON OF LADHELLIN. MY PEOPLE BUILT THAT TOWER, AND WHEN THEY LEFT THEY PEGGED ITS DOOR SHUT.",
		"ONLY A LADHELLIN STONE HAMMER CAN KNOCK THOSE PEGS DOWN. I HAVE THE LAST ONE... BUT ITS HANDLE SNAPPED YEARS AGO.",
		"NO WOOD IN THE DESERT IS STRONG ENOUGH TO MAKE ANOTHER."
	];
	if (trade_quest_open()) {
		array_push(steps, "IRONWOOD WOULD DO IT. THEY SAY IT GROWS IN THE FOREST, BY THE WOODCUTTER'S CABIN.");
	} else {
		array_push(steps, "IRONWOOD WOULD DO IT, BUT THE ROAD TO THE FOREST IS NO PLACE FOR AN OLD MAN WHILE THE BOG TOWER POISONS THE MARSH.");
	}
	return steps;


}
