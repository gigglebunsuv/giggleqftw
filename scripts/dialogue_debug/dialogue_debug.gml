//The debug room (rm_debug): where Link starts, and what its signs say.
//Every section of the room tests one item or feature, and has a sign and a chest with its item.
//A sign gets one of these with  dialogue = dlg_debug_cape;  in its Creation Code.
//Letters: A-Z, 0-9, spaces and , . ' ! ? - : / (lowercase is shown in capitals).

//Where the U debug key puts Link (the START section, top row, third from the left)
#macro DEBUG_START_X 640
#macro DEBUG_START_Y 120

//================================================================ start section

///dlg_debug_welcome();
function dlg_debug_welcome() {
	return [
		"WELCOME TO THE DEBUG ROOM!",
		"EVERY SECTION TESTS ONE ITEM OR FEATURE. READ ITS SIGN, THEN OPEN ITS CHEST TO GET THE ITEM.",
		"TO USE AN ITEM, PRESS ENTER TO PAUSE, PICK IT, AND PRESS A OR Y TO PUT IT ON THAT BUTTON. ON THE KEYBOARD, A IS Z AND Y IS C."
	];


}

///dlg_debug_map();
function dlg_debug_map() {
	return [
		"MAP OF THIS ROOM, LEFT TO RIGHT. YOU ARE AT THE START.",
		"TOP ROW: ITEM CHESTS, EQUIPMENT CHESTS, START, NPCS AND SIGNS, MIRROR, BOOTS.",
		"2ND ROW: SWORD AND SHIELD, BOW, BOMBS, BOOMERANG, GRAPPLE HOOK, BOTTLES.",
		"3RD ROW: LANTERN, FIRE ROD, ICE ROD, LIGHTNING ROD, FLUTE, ENEMIES.",
		"4TH ROW: HAMMER, SHOVEL, CAPE, STRENGTH GLOVES, FLIPPERS, PEDESTALS."
	];


}

///dlg_debug_keys();
function dlg_debug_keys() {
	return [
		"DEBUG KEYS: 0 GIVES EVERY ITEM AND B GIVES ALL 5 BOTTLES. G, F AND R TURN THE GLOVES, FLIPPERS AND BOOTS ON AND OFF.",
		"CTRL AND H: LOSE AND HEAL HEALTH. SHIFT AND M: USE AND RESTORE MAGIC. 3 ADDS A BOMB, 4 ADDS ARROWS.",
		"U BRINGS YOU BACK HERE FROM ANYWHERE. THE FULL LIST IS ON THE OPTIONS PAGE OF THE PAUSE MENU."
	];


}

///dlg_debug_chest_demo();
function dlg_debug_chest_demo() {
	return [
		"THESE CHESTS REMEMBER BEING OPENED, LIKE CHESTS IN THE REAL GAME. THEY STAY OPEN UNTIL A NEW GAME.",
		"EVERY OTHER CHEST IN THIS ROOM CLOSES AGAIN WHEN YOU COME BACK INTO THE ROOM WITH U, SO YOU CAN TEST IT AGAIN.",
		"THE LAST ONE IS EMPTY."
	];


}

//================================================================ top row

///dlg_debug_chests_items();
function dlg_debug_chests_items() {
	return [
		"ITEM CHESTS: ONE OF EVERY ITEM. FACE A CHEST AND PRESS A TO OPEN IT.",
		"THEN PRESS ENTER TO PAUSE, PICK THE ITEM, AND PRESS A OR Y TO PUT IT ON THAT BUTTON."
	];


}

///dlg_debug_chests_equip();
function dlg_debug_chests_equip() {
	return [
		"EQUIPMENT CHESTS: SWORDS, SHIELDS, ARMOR, GLOVES, FLIPPERS, BOOTS AND UPGRADES.",
		"EQUIPMENT WORKS AS SOON AS YOU GET IT, NO BUTTON NEEDED. SHIELDS ARE THE ONE EXCEPTION: PUT THEM ON A OR Y."
	];


}

///dlg_debug_npcs();
function dlg_debug_npcs() {
	return [
		"NPCS: FACE ONE AND PRESS A TO TALK. THEY TURN TO LOOK AT YOU WHEN YOU COME CLOSE.",
		"SIGNS LIKE THIS ONE WORK THE SAME WAY, BUT THEY JUST SHOW TEXT. READ THE OTHER TWO SIGNS!"
	];


}

///dlg_debug_sign_long();
function dlg_debug_sign_long() {
	return [
		"THIS SIGN HAS A LOT TO SAY. LONG TEXT WRAPS ONTO THE NEXT LINE BY ITSELF, AND CARRIES ON IN THE NEXT BOX WHEN THIS ONE FILLS UP.",
		"A SIGN CAN ALSO SHOW\nSEVERAL BOXES IN A ROW,\nLIKE THIS ONE."
	];


}

///dlg_debug_sign_choice();
function dlg_debug_sign_choice() {
	return [
		dlg_choice("SIGNS CAN ASK QUESTIONS TOO. DO YOU LIKE SIGNS?", [
			["YES", ["GOOD! THIS SIGN LIKES YOU TOO."]],
			["NO", ["...THIS SIGN IS HURT."]]
		])
	];


}

///dlg_debug_mirror();
function dlg_debug_mirror() {
	return [
		"MAGIC MIRROR: TAKES YOU BACK TO WHERE YOU CAME INTO THIS ROOM, WHICH IS THE START SECTION.",
		"WALK SOMEWHERE ELSE FIRST, THEN USE IT. IN A DUNGEON IT TAKES YOU BACK TO THE ENTRANCE."
	];


}

///dlg_debug_boots();
function dlg_debug_boots() {
	return [
		"RUNNING BOOTS: HOLD THE RUN BUTTON, S OR RT. YOU RUN ON THE SPOT FOR A MOMENT, THEN DASH.",
		"STEER WITH THE ARROWS AND LET GO TO STOP. DASH INTO ENEMIES TO HIT THEM. RUNNING INTO A WALL BOUNCES YOU BACK."
	];


}

//================================================================ 2nd row

///dlg_debug_sword();
function dlg_debug_sword() {
	return [
		"SWORD AND SHIELD: PRESS X TO SWING YOUR SWORD, B ON A GAMEPAD. IT CUTS BUSHES TOO.",
		"PUT THE SHIELD ON A OR Y AND HOLD THAT BUTTON TO RAISE IT. YOU WALK SLOWER AND KEEP FACING THE SAME WAY.",
		"THE SKELETON THROWS BONES. FACE IT WITH YOUR SHIELD UP TO BLOCK THEM. THE CHEST GIVES A BETTER SHIELD EACH TIME."
	];


}

///dlg_debug_bow();
function dlg_debug_bow() {
	return [
		"BOW: PRESS ITS BUTTON TO SHOOT AN ARROW THE WAY YOU FACE. EACH SHOT USES ONE ARROW.",
		"ARROWS FLY OVER PITS. SHOOT THE SKELETON IN ITS PEN, OR THE BATS. OUT OF ARROWS? PRESS 4."
	];


}

///dlg_debug_bombs();
function dlg_debug_bombs() {
	return [
		"BOMBS: PRESS ITS BUTTON TO SET A BOMB DOWN IN FRONT OF YOU. IT BLOWS UP A MOMENT LATER.",
		"STAND BACK! BOMBS HURT YOU TOO. ONLY 2 CAN BE OUT AT ONCE.",
		"THE CRACKED WALL IN THE CORNER HIDES A CHEST. BLOW IT UP! OUT OF BOMBS? PRESS 3."
	];


}

///dlg_debug_boomerang();
function dlg_debug_boomerang() {
	return [
		"BOOMERANG: PRESS ITS BUTTON TO THROW IT. HOLD A DIAGONAL TO THROW IT THAT WAY.",
		"IT COMES BACK TO YOU. IT STUNS MOST ENEMIES FOR A MOMENT, AND KILLS BATS."
	];


}

///dlg_debug_grapple();
function dlg_debug_grapple() {
	return [
		"GRAPPLE HOOK: FIRES THE WAY YOU FACE. IF IT CATCHES A GRAPPLE POST, IT PULLS YOU OVER TO IT.",
		"STAND JUST RIGHT OF THE POST BY THE PIT AND FIRE RIGHT, AT THE POST ON THE ISLAND. FIRE LEFT TO COME BACK.",
		"IT STUNS ENEMIES TOO."
	];


}

///dlg_debug_bottles();
function dlg_debug_bottles() {
	return [
		"BOTTLES: OPEN THE CHESTS FOR A BOTTLE OF EACH KIND, THEN PUT ONE ON A OR Y AND PRESS IT TO DRINK.",
		"RED POTION REFILLS HEALTH, GREEN REFILLS MAGIC, BLUE REFILLS BOTH. A FAIRY HEALS YOU, OR SAVES YOU WHEN YOU WOULD DIE.",
		"PRESS CTRL TO LOSE HEALTH AND SHIFT TO USE MAGIC, OR LET THE SKELETON HIT YOU, THEN DRINK ONE TO TEST IT."
	];


}

//================================================================ 3rd row

///dlg_debug_lantern();
function dlg_debug_lantern() {
	return [
		"LANTERN: PRESS ITS BUTTON FOR A SMALL FLAME IN FRONT OF YOU. IT USES A LITTLE MAGIC.",
		"FACE A TORCH AND USE IT TO LIGHT THE TORCH. THE LAST TORCH GOES OUT AGAIN AFTER A WHILE. THE FLAME BURNS BUSHES TOO."
	];


}

///dlg_debug_fire_rod();
function dlg_debug_fire_rod() {
	return [
		"FIRE ROD: SHOOTS A FIREBALL THE WAY YOU FACE. EACH SHOT USES 4 MAGIC.",
		"IT HURTS ENEMIES, LIGHTS TORCHES AND BURNS BUSHES. OUT OF MAGIC? PRESS M."
	];


}

///dlg_debug_ice_rod();
function dlg_debug_ice_rod() {
	return [
		"ICE ROD: SHOOTS ICE THE WAY YOU FACE. EACH SHOT USES 4 MAGIC.",
		"AN ENEMY IT HITS FREEZES IN PLACE FOR A FEW SECONDS. OUT OF MAGIC? PRESS M."
	];


}

///dlg_debug_lightning_rod();
function dlg_debug_lightning_rod() {
	return [
		"LIGHTNING ROD: SHOOTS A FAST BOLT THE WAY YOU FACE. EACH SHOT USES 4 MAGIC.",
		"IT GOES RIGHT THROUGH ENEMIES, HITTING EVERY ONE IN ITS WAY. TRY IT ON THE SKELETONS IN THE PEN."
	];


}

///dlg_debug_flute();
function dlg_debug_flute() {
	return [
		"FLUTE: PRESS ITS BUTTON TO PLAY A SONG, THEN PICK A FLUTE SPOT TO WARP TO.",
		"THIS ROOM HAS SPOTS AT THE START, THE ITEM CHESTS, THE BOOTS, HERE, THE CAPE AND THE FLIPPERS."
	];


}

///dlg_debug_enemies();
function dlg_debug_enemies() {
	return [
		"ENEMIES: SKELETONS WALK AROUND AND THROW BONES WHEN THEY SEE YOU. BATS REST, THEN FLUTTER AT YOU.",
		"ENEMIES ONLY MOVE WHILE YOU'RE IN THEIR SECTION. THE CHEST REFILLS HEALTH, MAGIC, BOMBS AND ARROWS."
	];


}

//================================================================ 4th row

///dlg_debug_hammer();
function dlg_debug_hammer() {
	return [
		"HAMMER: PRESS ITS BUTTON TO SWING IT DOWN IN FRONT OF YOU.",
		"IT POUNDS WOODEN PEGS FLAT AND HITS ENEMIES HARD. POUND THE PEGS IN THE CORNER TO REACH THE CHEST."
	];


}

///dlg_debug_shovel();
function dlg_debug_shovel() {
	return [
		"SHOVEL: PRESS ITS BUTTON TO DIG UP THE GROUND IN FRONT OF YOU.",
		"THINGS ARE BURIED IN THE SANDY PATCH. DIG ALL OVER IT! YOU CAN SOMETIMES FIND A HEART OR MONEY ANYWHERE."
	];


}

///dlg_debug_cape();
function dlg_debug_cape() {
	return [
		"CAPE: PRESS ITS BUTTON TO JUMP. YOU KEEP YOUR SPEED, AND YOU CAN STEER IN THE AIR.",
		"WALK AT A PIT AND JUMP JUST BEFORE THE EDGE. IT ONLY CLEARS PITS ONE TILE WIDE.",
		"JUMP OVER TO THE ISLAND FOR A CHEST. FALLING IN COSTS HALF A HEART."
	];


}

///dlg_debug_gloves();
function dlg_debug_gloves() {
	return [
		"STRENGTH GLOVES: KEEP WALKING INTO A HEAVY ROCK TO LIFT IT OVER YOUR HEAD.",
		"PRESS ANY BUTTON TO THROW IT. IT BREAKS WHERE IT LANDS AND HURTS ENEMIES. MOVE THE ROCKS IN THE CORNER TO REACH THE CHEST."
	];


}

///dlg_debug_flippers();
function dlg_debug_flippers() {
	return [
		"FLIPPERS: NOW YOU CAN WALK INTO DEEP WATER AND SWIM.",
		"YOU CAN'T USE ITEMS OR YOUR SWORD WHILE SWIMMING. SWIM OVER TO THE ISLAND FOR A CHEST."
	];


}

///dlg_debug_pedestals();
function dlg_debug_pedestals() {
	return [
		"PEDESTALS: WALK ONTO ONE TO PICK UP WHAT'S ON IT. NO BUTTON NEEDED.",
		"THEY'RE GONE ONCE TAKEN. COME BACK INTO THE ROOM WITH U TO GET THEM BACK."
	];


}
