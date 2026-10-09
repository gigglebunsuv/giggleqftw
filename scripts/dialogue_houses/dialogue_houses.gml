//What's said and read inside the houses (rm_interiors, built by world_placeholders/make_interiors_room.py).
//One function per person or thing, given to them with  dialogue = dlg_cat_lady;  in their Creation Code.
//Every kind of step is listed at the top of the dialogue_system script.
//
//Side quests in here:
//	Mittens	the cat lady's cat ran off to the barn's hayloft. Talk to him there: he goes home (flag
//			CAT_HOME_FLAG), and she gives Link a bottle (CAT_REWARD_FLAG).
//	Stew / oil	the farmer's wife fills Link's hearts, the lamplighter's wife his magic (once he has the lantern).
//	The fortune teller: 10 money for a hint about where to go next (fortune_hint).
//	The Heart Piece Almanac (the library, upstairs): how many of the 9 pieces of heart Link has, and hints.

#macro QUEST_MEDAL_FLAG "knight_medal"		//Link has the knight's medal from the Old Well (the trial)
#macro CAT_HOME_FLAG "cat_home"
#macro CAT_REWARD_FLAG "cat_reward"
#macro FORTUNE_PRICE 10
#macro WORLD_HEART_PIECES 9					//pieces of heart out in the world (not counting the bosses' heart containers)

//================================================================ Gigglebuns's house

///dlg_home_bed();
function dlg_home_bed() {
	return [
		"YOUR BED. STILL WARM.",
		dlg_choice("TAKE A NAP?", [
			["YES", [
				dlg_run(function() {
					global.pHealth = global.pHealthMax;
					sfx_play(SFX_HEART);
				}),
				"ZZZ... YOU FEEL RESTED. YOUR HEALTH IS FULL!"
			]],
			"NO"
		])
	];


}

///dlg_home_portrait();
function dlg_home_portrait() {
	return [
		"SIR GIGGLEBUNS II, YOUR FATHER. THE LAST KNIGHT TO STAND AGAINST THE SAPPHIRE ORDER.",
		"HE ALWAYS SAID: A GOOD SHIELD IS WORTH TEN SWORDS. HE STILL HAD A SWORD, THOUGH."
	];


}

///dlg_home_bookshelf();
function dlg_home_bookshelf() {
	return [
		"THE ADVENTURES OF SIR GIGGLEBUNS I, VOLUMES ONE TO NINE.",
		"VOLUME FOUR IS MISSING. YOU LENT IT TO THE LIBRARY AND NEVER GOT IT BACK."
	];


}

//================================================================ the elder's house

///dlg_elder_wife();
function dlg_elder_wife() {
	return [
		dlg_if(INTRO_FLAG, [
			"MY HUSBAND RAN STRAIGHT TO YOUR HOUSE THIS MORNING. HE HASN'T RUN SINCE THE LAST WAR!",
			"HE'S IN THE SQUARE NOW, TELLING EVERYONE NOT TO PANIC. LOUDLY."
		], ["OH! THE ELDER'S OUT."]),
		"HIS STUDY IS UPSTAIRS. HE WON'T MIND IF YOU LOOK AT HIS MAP."
	];


}

///dlg_elder_map();
function dlg_elder_map() {
	return [
		"A MAP OF BUNSRIEL, COVERED IN THE ELDER'S NOTES.",
		"THE SOUTHERN TOWER: PAST THE FIELDS, SOUTH. THE BOG TOWER: THE WEST MARSH, ACROSS THE WATER.",
		"THE TOWER OF LADHELLIN: THE DESERT, FAR TO THE EAST. AND THE CASTLE, NORTH, OVER THE RIVER.",
		"SOMEONE HAS DRAWN A LITTLE BUN ON THE CASTLE. AND A FROWNING FACE."
	];


}

///dlg_elder_desk();
function dlg_elder_desk() {
	return [
		"A LETTER, HALF WRITTEN:",
		"...THE ORDER HAS BEEN SEEN NEAR THE OLD TOWERS AGAIN. IF THEY FIND THE PIECES OF THE BUN...",
		"...THE GIGGLEBUNS BOY IS THE LAST OF HIS LINE. WHEN THE TIME COMES, HE MUST BE READY..."
	];


}

//================================================================ the fortune teller

///dlg_fortune();
function dlg_fortune() {
	return [
		"WELCOME, SIR GIGGLEBUNS. I HAVE SEEN YOU COMING. MOSTLY BECAUSE OF THE WINDOW.",
		dlg_choice("CROSS MY PALM WITH " + string(FORTUNE_PRICE) + " MONEY, AND I SHALL SEE YOUR PATH.", [
			["PAY", [
				dlg_if(function() {return global.pMoney >= FORTUNE_PRICE;}, [
					dlg_run(function() {
						player_add_money(-FORTUNE_PRICE);
						sfx_play(SFX_SHOP_BUY);
						dialogue_insert(fortune_hint());
					})
				], ["NO MONEY? THE SPIRITS DO NOT WORK FOR FREE. NEITHER DO I."])
			]],
			["NO", ["THE FUTURE WILL WAIT. IT ALWAYS DOES."]]
		])
	];


}

///fortune_hint();
function fortune_hint() {
	//What the fortune teller sees: the next thing Link should do
	var h = "";
	if (global.shieldTier <= 0) {
		h = "I SEE... A SHIELD, SLEEPING UNDER YOUR OWN FLOOR. YOUR FATHER LEFT IT FOR YOU.";
	} else if (global.swordTier <= 0 && !flag_get(QUEST_MEDAL_FLAG)) {
		h = "I SEE... A MEDAL, AT THE BOTTOM OF THE OLD WELL SOUTH OF THE VILLAGE. RAISE YOUR SHIELD TO WHAT SPITS AT YOU.";
	} else if (global.swordTier <= 0) {
		h = "I SEE... A KNIGHT AT THE NORTH GATE, WAITING FOR HIS MEDAL. AND A SWORD, WAITING FOR YOU.";
	} else if (!global.item_have[ITEM.LANTERN]) {
		h = "I SEE... A LANTERN AT THE BOTTOM OF THE OLD WELL. THE SOUTHERN TOWER OPENS ONLY FOR A FLAME.";
	} else if (bun_count() == 0) {
		h = "I SEE... TWO TORCHES BY THE SOUTHERN TOWER'S DOOR. LIGHT THEM BOTH, AND IT WILL OPEN.";
	} else if (bun_count() == 1 && !global.hasFlippers) {
		h = "I SEE... FLIPPERS IN THE MARSH CAVE, ACROSS A BROKEN FLOOR. ONLY A GRAPPLE WILL GET YOU THERE.";
	} else if (bun_count() == 1) {
		h = "I SEE... A TOWER IN THE WEST MARSH, STANDING IN THE WATER. SWIM TO IT, THEN GRAPPLE ACROSS.";
	} else if (bun_count() == 2 && !global.item_have[ITEM.HAMMER]) {
		h = "I SEE... A FISHERMAN BY THE MARSH LAKE, WHOSE LINE IS STUCK. ONE GOOD DEED LEADS TO ANOTHER, AND TO A HAMMER.";
	} else if (bun_count() == 2) {
		h = "I SEE... WOODEN PEGS IN FRONT OF A DOOR IN THE DESERT. YOUR HAMMER KNOWS WHAT TO DO.";
	} else if (global.swordTier < SWORD_TIER_BUN) {
		h = "I SEE... THREE PIECES, MADE WHOLE. THE SWORD OF BUN IS WAITING FOR YOU. GO TO THE CASTLE.";
	} else {
		h = "I SEE... THE CASTLE. THE EVIL KING. AND YOU, WITH A VERY SHINY SWORD. GO!";
	}
	return ["THE CRYSTAL CLOUDS OVER...", h];


}

//================================================================ the cat lady

///dlg_cat_lady();
function dlg_cat_lady() {
	return [
		dlg_if(CAT_HOME_FLAG, [
			dlg_if(CAT_REWARD_FLAG, [
				"MITTENS HASN'T LEFT HIS BED SINCE YOU BROUGHT HIM HOME. HE'S VERY TIRED FROM ALL THAT HIDING."
			], [
				"MITTENS! MY BABY! YOU FOUND HIM!",
				"HE WAS IN THE BARN? CHASING MICE, I SUPPOSE. OH, THANK YOU, SIR GIGGLEBUNS.",
				"HERE, TAKE THIS. I KEPT HIS MILK IN IT, BUT YOU'LL PUT IT TO BETTER USE.",
				dlg_run(function() {
					dialogue_insert(world_give({equip: "bottle", contents: BOTTLE.EMPTY}));
				}),
				dlg_set(CAT_REWARD_FLAG)
			])
		], [
			"OH, SIR GIGGLEBUNS! HAVE YOU SEEN MITTENS? MY CAT? ORANGE, GRUMPY, ANSWERS TO NOTHING?",
			"HE RAN OFF WHEN THE ORDER'S SOLDIERS CAME THROUGH LAST NIGHT. HE HATES LOUD NOISES.",
			"IF YOU FIND HIM, JUST TALK TO HIM NICELY. HE KNOWS THE WAY HOME. HE JUST WON'T USE IT.",
			dlg_set("cat_asked")
		])
	];


}

///dlg_cat_home();
function dlg_cat_home() {
	return ["MRRP. MITTENS IS CURLED UP IN HIS BED. HE PRETENDS NOT TO SEE YOU."];


}

///dlg_cat_lost();
function dlg_cat_lost() {
	//Mittens, hiding in the barn's hayloft: talking to him sends him home
	return [
		"MEOW?",
		"AN ORANGE CAT, COVERED IN HAY. IT MUST BE MITTENS, THE CAT LADY'S CAT.",
		"YOU TELL HIM THE SOLDIERS ARE GONE, AND THAT THERE'S MILK AT HOME.",
		"MITTENS STRETCHES, YAWNS, AND STROLLS OFF TOWARDS THE VILLAGE.",
		dlg_set(CAT_HOME_FLAG),
		dlg_run(function() {
			instance_activate_object(obj_npc);
			with (obj_npc) {
				if (sprite_index == spr_npc_cat) {instance_destroy()}
			}
		})
	];


}

//================================================================ the twins' house

///dlg_twins_mom();
function dlg_twins_mom() {
	return [
		"THE TWINS ARE UPSTAIRS. IF THEY'RE QUIET, THEY'RE UP TO SOMETHING.",
		"THEY'RE QUIET A LOT."
	];


}

///dlg_twin_boy();
function dlg_twin_boy() {
	return [
		dlg_if(CAT_HOME_FLAG, [
			"YOU FOUND MITTENS? AW. I WAS GOING TO TRAIN HIM TO FETCH."
		], [
			"I SAW THE CAT LADY'S CAT RUN ALL THE WAY TO THE FARM! THE BARN WEST OF THE VILLAGE.",
			"CATS LIKE HIGH PLACES. HE'S PROBABLY UP IN THE HAYLOFT."
		])
	];


}

///dlg_twin_girl();
function dlg_twin_girl() {
	return [
		"THE LADY IN THE PURPLE HOUSE CAN SEE THE FUTURE! SHE SAID I'D HAVE A VISITOR TODAY.",
		"AND HERE YOU ARE! ...SHE CHARGED ME TEN MONEY FOR IT, THOUGH."
	];


}

//================================================================ the man who hates his aunt's pots

///dlg_pot_man();
function dlg_pot_man() {
	return [
		dlg_if(function() {return global.swordTier > 0;}, [
			"MY AUNT LEFT ME HER HOUSE. AND HER POTS. SO MANY POTS.",
			"I CAN'T BRING MYSELF TO BREAK THEM. BUT YOU COULD. KEEP WHATEVER YOU FIND!",
			"DON'T WORRY, SHE HAD A CELLAR FULL. THEY'LL BE BACK NEXT TIME YOU VISIT."
		], [
			"MY AUNT LEFT ME HER HOUSE. AND HER POTS. SO MANY POTS.",
			"IF YOU EVER GET A SWORD, COME BACK AND SMASH THEM FOR ME. PLEASE."
		])
	];


}

//================================================================ the collector

///dlg_collector();
function dlg_collector() {
	return [
		"AH, A VISITOR! LOOK BUT DON'T TOUCH. EVERYTHING HERE IS VERY OLD AND VERY BREAKABLE.",
		"I WAS DIGGING A BIGGER CELLAR FOR MY COLLECTION, AND I BROKE THROUGH INTO THE OLD CATACOMBS UNDER HAVEN.",
		"SKELETONS, BATS, RATS... AND I'M SURE I SAW SOMETHING SHINY AT THE BOTTOM.",
		dlg_if(function() {return global.swordTier > 0;}, [
			"YOU LOOK LIKE YOU CAN HANDLE IT. THE STAIRS ARE IN THE CORNER. BRING ME BACK A STORY!"
		], [
			"DON'T GO DOWN THERE WITHOUT A SWORD, SON. THE SKELETONS DON'T TALK. THEY BITE."
		])
	];


}

///dlg_collector_shelf();
function dlg_collector_shelf() {
	return ["OLD BOOKS ON THE LADHELLIN. ONE IS JUST CALLED: WHY DID THEY PEG THE DOOR SHUT? IT HAS NO ANSWER IN IT."];


}

///dlg_collector_jars();
function dlg_collector_jars() {
	return ["JARS OF COLOURED SAND, LABELLED BY DESERT. THERE ARE FORTY OF THEM. THEY ALL LOOK THE SAME."];


}

//================================================================ the lamplighter's house

///dlg_lamp_wife();
function dlg_lamp_wife() {
	return [
		dlg_if(function() {return global.item_have[ITEM.LANTERN];}, [
			"YOU'RE THE ONE WHO FOUND HIS LANTERN! HE WON'T STOP TALKING ABOUT IT.",
			"HERE, LET ME FILL IT WITH OUR GOOD OIL. IT BURNS ALL NIGHT.",
			dlg_run(function() {
				global.pMagic = global.pMagicMax;
				sfx_play(SFX_MAGIC);
			}),
			"YOUR MAGIC IS FULL! COME BACK ANY TIME YOU RUN LOW."
		], [
			"MY HUSBAND LOST HIS LANTERN DOWN THE OLD WELL. THE THIRD ONE THIS YEAR.",
			"WE HAVE THIRTY CANDLES IN THIS HOUSE AND HE STILL WANTS THAT ONE."
		])
	];


}

//================================================================ the library

///dlg_library_shelf_1();
function dlg_library_shelf_1() {
	return [
		"A HISTORY OF BUNSRIEL, PART ONE:",
		"THE FIRST KING BAKED THE BUN OF LIGHT TO KEEP THE LAND WARM AND SAFE. IT HAS NEVER GONE STALE."
	];


}

///dlg_library_shelf_2();
function dlg_library_shelf_2() {
	return [
		"A HISTORY OF BUNSRIEL, PART TWO:",
		"WHEN THE EVIL KING ROSE, THE BUN WAS BROKEN INTO THREE PIECES AND HIDDEN IN THREE TOWERS, SO HE COULD NEVER HAVE IT ALL."
	];


}

///dlg_library_shelf_3();
function dlg_library_shelf_3() {
	return [
		"THE SAPPHIRE ORDER, A WARNING:",
		"THEY WEAR BLUE AND CHARGE THE MOMENT THEY SEE YOU. HOLD UP A SHIELD AND THEY BOUNCE RIGHT OFF."
	];


}

///dlg_library_shelf_4();
function dlg_library_shelf_4() {
	return [
		"THE ADVENTURES OF SIR GIGGLEBUNS I, VOLUME FOUR.",
		"SO THIS IS WHERE IT WENT. IT'S STAMPED: VERY OVERDUE."
	];


}

///dlg_library_shelf_5();
function dlg_library_shelf_5() {
	return [
		"A GUIDE TO CAVES:",
		"A DARK CAVE NEEDS A LIGHT. A CRACKED WALL NEEDS A BOMB. A HEAVY ROCK NEEDS STRONG HANDS. AND EVERY CAVE NEEDS A WAY OUT."
	];


}

///dlg_library_shelf_6();
function dlg_library_shelf_6() {
	return [
		"THE SWORD OF BUN:",
		"ONLY THE WHOLE BUN CAN WAKE IT. ONLY THAT SWORD CAN BREAK THE SEAL ON THE CASTLE DOOR."
	];


}

///dlg_library_shelf_7();
function dlg_library_shelf_7() {
	return [
		"FLUTE SONGS OF HAVEN:",
		"PLAY THE FLUTE AT A FLUTE SPOT AND IT'LL CARRY YOU TO ANY OTHER IN THE SAME AREA. HANDY FOR LAZY KNIGHTS."
	];


}

///dlg_library_reader();
function dlg_library_reader() {
	return [
		"SHH! I'M READING.",
		"...THE ALMANAC ON THE LECTERN? IT KNOWS WHERE EVERY PIECE OF HEART IN BUNSRIEL IS HIDDEN. SORT OF. IT'S VERY VAGUE."
	];


}

///heart_pieces_found();
function heart_pieces_found() {
	//Pieces of heart Link has found out in the world: his hearts, less the 3 he started with and the
	//bosses' heart containers (one per piece of the Bun)
	var whole = global.pHealthMax div 2 - 3 - bun_count();
	return clamp(whole * HEART_PIECES_PER_HEART + global.heartPieces, 0, WORLD_HEART_PIECES);


}

///dlg_heart_almanac();
function dlg_heart_almanac() {
	var n = heart_pieces_found();
	var line = "YOU HAVE FOUND " + string(n) + " OF THE " + string(WORLD_HEART_PIECES) + " PIECES OF HEART HIDDEN IN BUNSRIEL.";
	if (n >= WORLD_HEART_PIECES) {line = "YOU HAVE FOUND ALL " + string(WORLD_HEART_PIECES) + " PIECES OF HEART! THE ALMANAC HAS NOTHING LEFT TO TEACH YOU."}
	return [
		"THE HEART PIECE ALMANAC.",
		line,
		dlg_choice("READ ABOUT WHICH LANDS?", [
			["VILLAGE AND FIELDS", [
				"UNDER HAVEN ITSELF, PAST THE OLD BONES, A HEART WAITS. ASK THE ONE WHO COLLECTS THINGS.",
				"A HILL IN THE FIELDS IS HOLLOW. JUMP WHAT CAN'T BE CROSSED, WITH A CAPE ON YOUR BACK.",
				"BY THE ROAD, A CAVE IS SHUT BY ROCKS TOO HEAVY FOR ORDINARY HANDS."
			]],
			["FOREST AND MARSH", [
				"IN THE FOREST'S WEST, BEHIND THE BUSHES, LIES A GROVE NOBODY VISITS.",
				"IN THE MARSH, AN ISLAND SITS IN THE LAKE. YOU'LL HAVE TO SWIM FOR IT."
			]],
			["CLIFFS AND CASTLE", [
				"ON THE CLIFFS, CLIMB. THEN CLIMB AGAIN. THE HIGHEST PEAK HAS A PRIZE.",
				"IN THE CRYSTAL CAVE, A CHASM. A GRAPPLE WILL CARRY YOU OVER.",
				"IN OLD CASTLE TOWN, A COURTYARD IS WALLED IN. ONE OF ITS WALLS IS CRACKED."
			]],
			["THE DESERT", [
				"IN THE DESERT, A LEDGE HIDES BEHIND HEAVY ROCKS. ONLY STRONG HANDS WILL MOVE THEM."
			]]
		])
	];


}

//================================================================ the woodcutter's cabin

///dlg_cabin_note();
function dlg_cabin_note() {
	return [
		"A NOTE ON THE TABLE:",
		"GONE CHOPPING. IF YOU'RE A THIEF, THERE'S NOTHING HERE BUT SPLINTERS.",
		"THERE'S A CHEST IN THE CORNER."
	];


}

//================================================================ the farm

///dlg_farmwife();
function dlg_farmwife() {
	return [
		"YOU LOOK HALF STARVED, SIR KNIGHT. SIT DOWN, HAVE SOME STEW.",
		dlg_run(function() {
			global.pHealth = global.pHealthMax;
			sfx_play(SFX_HEART);
		}),
		"YOUR HEALTH IS FULL! COME BACK WHENEVER YOU'RE HUNGRY.",
		"MY HUSBAND SAYS THERE'S A DARK CAVE PAST THE FIELDS. HE FOUND MONEY IN THERE, BUT NOW HE WON'T GO BACK WITHOUT A LIGHT."
	];


}

///dlg_farm_girl();
function dlg_farm_girl() {
	return [
		dlg_if(CAT_HOME_FLAG, [
			"THE ORANGE CAT IN THE HAYLOFT WENT HOME. I MISS HIM. HE WAS GRUMPY BUT HE WAS WARM."
		], [
			"THERE'S AN ORANGE CAT HIDING IN OUR HAYLOFT! HE WON'T COME DOWN FOR ME.",
			"THE STAIRS ARE AT THE BACK OF THE BARN. DON'T TELL MY DAD THE COWS ATE MY HOMEWORK."
		])
	];


}

///dlg_cow();
function dlg_cow() {
	return ["MOOO."];


}

///dlg_chicken();
function dlg_chicken() {
	return ["BAWK! WHATEVER YOU DO, DON'T SWING A SWORD AT THE CHICKENS. EVERYBODY KNOWS THAT."];


}

//================================================================ the ruins of Old Castle Town

///dlg_ruin_journal();
function dlg_ruin_journal() {
	return [
		"A JOURNAL, LEFT BEHIND:",
		"DAY 1: THE ORDER MARCHED IN. WE HID IN THE CELLAR.",
		"DAY 9: THEY'VE SEALED THE CASTLE DOOR WITH SOMETHING. A GLOWING SEAL. NOTHING GETS THROUGH.",
		"DAY 12: WE'RE LEAVING FOR HAVEN TONIGHT. IF ANYONE READS THIS: THE SEAL ONLY BREAKS FOR THE SWORD OF BUN."
	];


}

///dlg_ruin_notice();
function dlg_ruin_notice() {
	return [
		"A NOTICE NAILED TO THE WALL:",
		"BY ORDER OF THE SAPPHIRE ORDER: THIS TOWN NOW BELONGS TO THE EVIL KING. ALL BUNS ARE TO BE HANDED IN.",
		"SOMEONE HAS WRITTEN UNDERNEATH: NEVER."
	];


}
