//What the overworld's people say (rm_overworld and rm_caves). Works like the dialogue_lines
//script: one function per person, given to them with  dialogue = dlg_lamplighter;  in their
//Creation Code (make_overworld_room.py writes those). Every kind of step is listed at the top of
//the dialogue_system script.
//Letters: A-Z, 0-9, spaces and , . ' ! ? - : / (lowercase is shown in capitals).

//================================================================ Haven village

///dlg_lamplighter();
function dlg_lamplighter() {
	//The lantern side quest: his lantern fell down the Old Well (it's in a chest at the bottom)
	return [
		dlg_if(function() {return global.item_have[ITEM.LANTERN];}, [
			dlg_if("lantern_thanks", [
				"THE LANTERN SUITS YOU. LIGHT UP EVERY DARK CORNER OF HAVEN FOR ME!"
			], [
				"YOU FOUND MY LANTERN! IT WAS AT THE BOTTOM OF THE OLD WELL? OH MY.",
				"YOU KNOW WHAT, KEEP IT. THE SOUTHERN TOWER'S DOOR ONLY OPENS FOR SOMEONE CARRYING A FLAME.",
				"HOLD IT UP TO THE TORCHES BY ITS DOOR. IT TAKES A LITTLE MAGIC EACH TIME.",
				dlg_set("lantern_thanks")
			])
		], [
			"OH, SIR GIGGLEBUNS! A TERRIBLE THING HAPPENED. I LEANED OVER THE OLD WELL AND MY LANTERN SLIPPED RIGHT OUT OF MY HANDS.",
			dlg_choice("WOULD YOU FETCH IT FOR ME?", [
				["OF COURSE", ["BLESS YOU! THE WELL IS JUST SOUTH OF THE VILLAGE. HOP IN, THERE'S A TUNNEL OUT AT THE BOTTOM."]],
				["MAYBE LATER", ["OH... ALL RIGHT. IT'S JUST SOUTH OF THE VILLAGE, IF YOU CHANGE YOUR MIND."]]
			])
		])
	];


}

///dlg_librarian();
function dlg_librarian() {
	return [
		"WELCOME TO THE LIBRARY OF HAVEN! WE'RE STILL PUTTING THE BOOKS ON THE SHELVES.",
		dlg_choice("WANT TO HEAR SOMETHING I READ?", [
			["YES", [
				"THE TOWER IN THE DESERT WAS BUILT BY THE LADHELLIN. WHEN THEY LEFT, THEY PEGGED ITS DOOR SHUT.",
				"ONLY A HAMMER COULD KNOCK THOSE PEGS DOWN NOW."
			]],
			["NO", ["SUIT YOURSELF. THE BOOKS WILL WAIT."]]
		])
	];


}

///dlg_village_elder();
function dlg_village_elder() {
	return [
		dlg_if("met_village_elder", [
			"THREE PIECES OF THE BUN, THREE TOWERS. SOUTH, IN THE BOG, AND IN THE DESERT. OFF YOU GO!"
		], [
			"AH, SIR GIGGLEBUNS. SIT WITH AN OLD BUN FOR A MOMENT.",
			"LONG AGO THE BUN WAS BROKEN INTO THREE PIECES, AND EACH PIECE WAS HIDDEN IN A TOWER.",
			"ONE IN THE SOUTHERN FIELDS, ONE IN THE BOG TO THE WEST, ONE IN THE DESERT OF LADHELLIN.",
			"BRING THEM TOGETHER AND THE WAY TO THE SWORD OF BUN WILL OPEN. ONLY THAT SWORD CAN FREE THE CASTLE.",
			dlg_set("met_village_elder")
		])
	];


}

///dlg_village_guard();
function dlg_village_guard() {
	//Gives Link his first sword and shield, the first time he talks to him
	return [
		dlg_if("got_first_sword", [
			"THE ROAD NORTH CROSSES THE RIVER TO OLD CASTLE TOWN.",
			"THE SAPPHIRE ORDER HOLDS IT NOW. THEIR SOLDIERS CHARGE THE MOMENT THEY SEE YOU. KEEP YOUR SHIELD UP!",
			"AND IF THAT OLD SWORD FEELS DULL, SEE THE SMITH BY THE MARKET. GIVE HIM STAR IRON AND HE'LL MAKE IT SING.",
			"THEY SAY THE BEASTS GUARDING THE TOWERS CARRY IT."
		], [
			"SIR GIGGLEBUNS! YOU CAN'T GO OUT THERE EMPTY-HANDED. SLIMES IN THE FIELDS, WOLVES IN THE FOREST...",
			"TAKE MY OLD SWORD AND SHIELD. THEY'VE SEEN BETTER DAYS, BUT THEY'LL KEEP YOU SAFE.",
			dlg_run(function() {
				dialogue_insert(array_concat(world_give({equip: "sword", tier: 1}), world_give({item: ITEM.SHIELD, tier: 1})));
			}),
			dlg_set("got_first_sword")
		])
	];


}

///dlg_village_woman();
function dlg_village_woman() {
	return ["WHAT A LOVELY DAY! IF YOU'RE HEADING OUT, CUT THE BUSHES AS YOU GO. YOU NEVER KNOW WHAT'S UNDER THEM."];


}

///dlg_village_man();
function dlg_village_man() {
	return [
		"THE EAST GATE TAKES YOU TO THE DESERT, OR NORTH OVER THE RIVER AND UP INTO THE CLIFFS.",
		"MIND THE SCORPIONS. IF ONE LINES UP WITH YOU, IT CHARGES!"
	];


}

///dlg_village_kid();
function dlg_village_kid() {
	return [
		"HEY, SIR GIGGLEBUNS! BET YOU CAN'T FIND ALL NINE PIECES OF HEART!",
		"SOME ARE OUT IN THE OPEN, SOME ARE IN CAVES. I'VE ONLY EVER SEEN ONE. IT WAS ON AN ISLAND."
	];


}

///dlg_village_kid2();
function dlg_village_kid2() {
	return ["I THREW A PEBBLE INTO THE OLD WELL AND IT NEVER WENT PLOP. I THINK THERE'S A WHOLE CAVE DOWN THERE."];


}

///dlg_neighbour();
function dlg_neighbour() {
	return [
		"MORNING, NEIGHBOUR! I HEARD YOU PLAYING YOUR FLUTE LAST NIGHT.",
		"DID YOU KNOW THE OLD SONG CARRIES YOU TO ANY FLUTE SPOT IN HAVEN? THERE'S ONE IN EVERY CORNER OF THE LAND."
	];


}

///dlg_shop_goods();
function dlg_shop_goods() {
	//The general goods shopkeeper (the red stall, see the shop script)
	return shop_talk("goods", "WELCOME! SHOVELS, BOTTLES, POTIONS... EVERYTHING AN ADVENTURER NEEDS.",
		"YOU'RE BACK! THE ROADS ARE SAFER SINCE YOUR LAST ADVENTURE, SO I'VE GOT NEW THINGS IN!");


}

///dlg_shop_bombs();
function dlg_shop_bombs() {
	//The bomb seller (the blue stall, see the shop script)
	return shop_talk("bombs", "BOMBS! ARROWS! THINGS THAT GO BOOM AND THINGS THAT GO THWIP!",
		"AH, A HERO RETURNS! I'VE GOT BIGGER BAGS AND BETTER STOCK NOW.");


}


//================================================================ the fields, the farm, the road

///dlg_orchard_kid();
function dlg_orchard_kid() {
	return [
		"THESE APPLE TREES ARE MY FAMILY'S! YOU CAN'T SHAKE THEM. I TRIED.",
		"SEE THE HILL BY THE RIVER? THERE'S A CHEST ON TOP. THE STAIRS ARE ON ITS SOUTH SIDE."
	];


}

///dlg_farmer();
function dlg_farmer() {
	return [
		"HOWDY! THE CROPS ARE DOING FINE, BUT SLIMES KEEP HOPPING IN FROM THE FIELDS.",
		"THAT OLD TOWER DOWN SOUTH? ITS DOOR STAYS SHUT UNLESS BOTH TORCHES BY IT ARE BURNING.",
		"NOBODY'S CARRIED A FLAME OUT THERE IN YEARS. THE LAMPLIGHTER IN THE VILLAGE MIGHT HELP YOU."
	];


}

///dlg_farm_kid();
function dlg_farm_kid() {
	return ["I FOUND A CAVE PAST THE FIELDS, OVER WEST! IT'S SO DARK IN THERE I COULDN'T SEE MY OWN FEET."];


}

///dlg_road_merchant();
function dlg_road_merchant() {
	return [
		"A TRAVELLER! I'VE COME A LONG WAY DOWN THIS ROAD.",
		"THE CAVE AT THE EAST END IS FULL OF HEAVY ROCKS. ONLY SOMEONE VERY STRONG COULD SHIFT THEM."
	];


}

///dlg_desert_traveller();
function dlg_desert_traveller() {
	return [
		"WATER... AN OASIS! THANK GOODNESS.",
		"THERE'S A LEDGE IN THE SOUTH-EAST WITH SOMETHING SHINY ON IT. BIG ROCKS BLOCK ITS STAIRS, THOUGH."
	];


}

//================================================================ the forest, the marsh, the cliffs

//(the woodcutter and the fisherman are in the trade_quest script: they're part of the hammer's trading chain)


///dlg_cliff_hermit();
function dlg_cliff_hermit() {
	return [
		"YOU CLIMBED ALL THE WAY UP HERE? HEH. NOT MANY DO.",
		"THE OLD GATE IN THE NORTH LEADS DEEP INTO THE MOUNTAIN. EACH LEVEL WANTS A STRONGER SWORD THAN THE LAST.",
		"AND IF YOU LIKE HEIGHTS, TAKE THE STAIRS UP ONTO THE PLATEAU. THEN TAKE THE NEXT ONES TOO."
	];


}

//================================================================ old castle town

///dlg_castle_knight();
function dlg_castle_knight() {
	return [
		"SIR GIGGLEBUNS! KEEP YOUR VOICE DOWN.",
		"THE SAPPHIRE ORDER TOOK THE CASTLE AND SEALED ITS GATE WITH A BARRIER OF LIGHT.",
		"ONLY THE SWORD OF BUN CAN CUT THROUGH IT. THE LEGENDS SAY IT RESTS IN THE HIDDEN FOREST."
	];


}

///dlg_castle_elder();
function dlg_castle_elder() {
	return [
		"THIS WAS THE FINEST TOWN IN HAVEN, ONCE. NOW LOOK AT IT.",
		"THE ORDER KEEPS A STOREROOM IN THE CAVE BY THE EAST WALL. I'VE SEEN THEM CARRY BOTTLES IN THERE."
	];


}

///dlg_castle_kid();
function dlg_castle_kid() {
	return ["THE SOLDIERS SAY A WALL IN THE OLD COURTYARD IS CRACKED. ONE GOOD BOMB WOULD KNOCK IT RIGHT DOWN!"];


}