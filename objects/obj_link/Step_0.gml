//Dead: obj_player_death handles the spin and the game over screen
if (state == "dead") exit;

//Get Input
input_get();

//The pause screen just closed: ignore the button that closed it
if (global.pause_block) {
	global.pause_block = false;
	act_a = false;
	act_b = false;
	act_y = false;
	act_start = false;
	hold_run = false;
}

//Talking: obj_dialogue has the game frozen until the conversation ends
if (state == "talk") {
	image_speed = 0;
	exit;
}

//Holding up something from a chest: obj_item_get lets him go once its text box closes
if (state == "itemget") {
	image_speed = 0;
	exit;
}

//Dungeon camera sliding to the next room, or the stairs to another floor: wait for it
if (global.cam_transition || instance_exists(obj_floor_fade)) {
	image_speed = 0;
	exit;
}

//Dungeons: changing floors, rooms seen (for the map)
dungeon_step();

//Pause screen
if (act_start && state == "idle") {
	instance_create_depth(0, 0, -1000, obj_pause_menu);
	exit;
}

//In deep water? (flippers, see player_moves)
player_swim_check();

//B = sword, A and Y = equipped items (used further down). Not while swimming or carrying a rock.
act_attack = act_b && global.swordTier > 0 && !swimming && !carrying;

//Debug keys
//	Ctrl  = lose half a heart	H = heal half a heart
//	Shift = use 4 magic			M = restore 4 magic
//	J     = add a heart container (up to 16)
//	1-4   = add 10 money, 1 key, 1 bomb, 5 arrows
//	5     = next Bun piece (clears all after the third)
//	6-7   = next sword / shield tier (goes back to none after the last)
//	8     = next armor tier (back to the tunic after the last)
//	G / F / R = toggle strength gloves / flippers / running boots
//	0     = get every item except the bottles
//	B     = get all 5 bottles: red, green, blue potion, fairy, empty
//	K / L = next bomb / arrow capacity (back to the smallest after the biggest)
//	9     = go to the test dungeon
//	O     = go to the overworld (Haven), in front of Home
//	I     = go to the item test room
//	U     = go to the debug room (a section for every item, chests and signs)
//	T     = go to the Southern Tower's entrance
if (keyboard_check_pressed(vk_control))	{player_add_health(-1)}
if (keyboard_check_pressed(ord("H")))	{player_add_health(1)}
if (keyboard_check_pressed(vk_shift))	{player_add_magic(-4)}
if (keyboard_check_pressed(ord("M")))	{player_add_magic(4)}
if (keyboard_check_pressed(ord("J")))	{player_add_heart()}
if (keyboard_check_pressed(ord("1")))	{player_add_money(10)}
if (keyboard_check_pressed(ord("2")))	{player_add_keys(1)}
if (keyboard_check_pressed(ord("3")))	{player_add_bombs(1)}
if (keyboard_check_pressed(ord("4")))	{player_add_arrows(5)}
if (keyboard_check_pressed(ord("5"))) {
	var piece = 0;
	while (piece < BUN_PIECES && global.bunPieces[piece]) {piece++}
	if (piece < BUN_PIECES) {bun_collect(piece)}
	else {global.bunPieces = array_create(BUN_PIECES, false)}
}
if (keyboard_check_pressed(ord("6")))	{global.swordTier = (global.swordTier + 1) mod (SWORD_TIER_MAX + 1)}
if (keyboard_check_pressed(ord("7")))	{shield_set_tier((global.shieldTier + 1) mod (SHIELD_TIER_MAX + 1))}
if (keyboard_check_pressed(ord("8")))	{global.armorTier = (global.armorTier mod ARMOR_TIER_MAX) + 1}
if (keyboard_check_pressed(ord("G")))	{global.hasGloves = !global.hasGloves}
if (keyboard_check_pressed(ord("F")))	{global.hasFlippers = !global.hasFlippers}
if (keyboard_check_pressed(ord("R")))	{global.hasBoots = !global.hasBoots}
if (keyboard_check_pressed(ord("0"))) {
	var every = [ITEM.BOW, ITEM.BOMBS, ITEM.BOOMERANG, ITEM.GRAPPLE, ITEM.LANTERN, ITEM.FIRE_ROD, ITEM.ICE_ROD,
		ITEM.LIGHTNING_ROD, ITEM.FLUTE, ITEM.HAMMER, ITEM.SHOVEL, ITEM.CAPE, ITEM.MIRROR];
	for (var i = 0; i < array_length(every); i++) {item_give(every[i])}
}
if (keyboard_check_pressed(ord("B"))) {
	for (var i = 0; i < BOTTLES; i++) {item_give(ITEM.BOTTLE_1 + i)}
	global.bottles = [BOTTLE.RED, BOTTLE.GREEN, BOTTLE.BLUE, BOTTLE.FAIRY, BOTTLE.EMPTY];
}
if (keyboard_check_pressed(ord("K")) && !player_upgrade_bombs()) {
	global.bombLevel = 0;
	global.pBombsMax = 8;
	global.pBombs = min(global.pBombs, global.pBombsMax);
}
if (keyboard_check_pressed(ord("L")) && !player_upgrade_arrows()) {
	global.arrowLevel = 0;
	global.pArrowsMax = 20;
	global.pArrows = min(global.pArrows, global.pArrowsMax);
}
if (keyboard_check_pressed(ord("I"))) {
	room_goto(rm_item_test);
	x = 264;
	y = 184;
}
if (keyboard_check_pressed(ord("U"))) {
	room_goto(rm_debug);
	x = DEBUG_START_X;
	y = DEBUG_START_Y;
}
if (keyboard_check_pressed(ord("O"))) {
	room_goto(rm_haven);
	x = 792;
	y = 840;
}
if (keyboard_check_pressed(ord("T"))) {
	room_goto(rm_southern_tower);
	x = TOWER_START_X;
	y = TOWER_START_Y;
}
if (keyboard_check_pressed(ord("9"))) {
	room_goto(rm_test_dungeon);
	x = 384;
	y = 640;
}

if global.pHealth < 0 {
	global.pHealth = 0;
}
if global.pHealth > global.pHealthMax {
	global.pHealth = global.pHealthMax;
}
global.pMagic = clamp(global.pMagic, 0, global.pMagicMax);

//Out of health
if (global.pHealth <= 0) {
	player_die();
	exit;
}

//Flash after getting hurt
if (hurt_timer > 0) {hurt_timer--}
image_alpha = 1;
if (hurt_timer > 0 && (hurt_timer div 4) mod 2 == 0) {image_alpha = 0.4}

xx = move_right - move_left;
yy = move_down - move_up;

//Same speed every way (diagonals aren't faster)
var move_spd = spd;
if (xx != 0 && yy != 0) {move_spd *= 0.7071}
hspd = xx*move_spd;
vspd = yy*move_spd;

//Shield up while its button is held: slower, and Link keeps facing the same way
shielding = (state == "idle" && shield_is_held() && !swimming && !carrying);
if (shielding) {
	hspd *= shield_spd;
	vspd *= shield_spd;
}
if (swimming) {
	hspd *= SWIM_SPEED;
	vspd *= SWIM_SPEED;
}

//Movement
anim_rate = 0;
if(state=="idle"){
	//Walls for the level Link is on, whole pixels, sliding round corners (see player_move)
	player_move(hspd, vspd);

	//Turn and animate (sprite depends on the armor, see player_get_sprite)
	if (!shielding) {player_face_input()}
	sprite_index = player_get_sprite(dir);
	if (hspd != 0 || vspd != 0) {anim_rate = 1}
}

// The cape's jump, strength gloves (heavy rocks) and running boots (see player_moves)
player_jump_step();
player_lift_rocks();
player_dash_step();

// Hopping down off a ledge with no railing (see the levels script)
ledge_hop_check();
ledge_hop_step();

// Carrying a rock: any button throws it
if (carrying && state == "idle" && (act_a || act_b || act_y)) {
	player_throw_rock();
}

// Attack: obj_sword swings the blade around Link (he holds still while it does)
if(act_attack&&state="idle"){
	state="attack";
	shielding=false;
	cnt=0;
	dur=10;
	spr_prev=sprite_index;
	pose=LINK_FRAME_SWORD;
	instance_create_depth(x,y,depth-1,obj_sword);
}

// Open the chest, or talk to the NPC (or read the sign) Link is facing with A
// (instead of using the item on A)
if (act_a && state == "idle" && !carrying) {
	var chest = chest_in_front();
	if (chest != noone) {
		chest_open(chest);
		exit;
	}
	var npc = npc_in_front();
	if (npc != noone) {
		npc_talk(npc);
		exit;
	}
}

// Use the items on A and Y
if (act_a && state == "idle" && player_can_use(global.itemA)) {
	item_use(global.itemA);
}
if (act_y && state == "idle" && player_can_use(global.itemY)) {
	item_use(global.itemY);
}

// Knocked back after getting hurt
if (state == "hurt") {
	player_move(lengthdir_x(3, kb_dir), lengthdir_y(3, kb_dir));
}

// Pits: falling in, and coming back out (see player_moves)
player_pit_check();
player_fall_step();

// Dropping down from the floor above (see floor_drop)
floor_land_step();

// Timer01 (the grapple hook, the flute, the boots, jumping and falling end their own states)
if(state!="idle"&&state!="hook"&&state!="pull"&&state!="flute"&&state!="charge"&&state!="dash"&&state!="jump"&&state!="fall"&&state!="hop"){
	if(cnt<dur){cnt++}
	if(cnt>=dur){state="idle";sprite_index=spr_prev;pose=-1}
}

// Frame for walking, running, or the sword/hammer/rock pose
player_animate();

 


