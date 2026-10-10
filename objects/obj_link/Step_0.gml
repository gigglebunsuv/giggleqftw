//Play time (shown on the file select)
global.playTime += delta_time / 1000000;

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
	act_x = false;
	act_start = false;
	hold_run = false;
}

//Hitstop: a hit just landed, everything holds still for a moment (see the game_feel script).
//A B press now still counts once it's over.
if (feel_frozen()) {
	if (act_b) {sword_buffer = SWORD_BUFFER}
	image_speed = 0;
	exit;
}

//Talking: obj_dialogue has the game frozen until the conversation ends
if (state == "talk") {
	image_speed = 0;
	exit;
}

//The opening is playing (see the cutscene script): stand still
if (instance_exists(obj_cutscene)) {
	image_speed = 0;
	exit;
}

//Holding up something from a chest: obj_item_get lets him go once its text box closes.
//A scene (the Sword of Bun's pedestal) moves him itself.
if (state == "itemget" || state == "scene") {
	image_speed = 0;
	exit;
}

//Dungeon camera sliding to the next room, or the stairs to another floor: wait for it
if (global.cam_transition || instance_exists(obj_floor_fade) || instance_exists(obj_room_fade)) {
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

//Debug menu: F1 / Select (the pause screen opened on it, see the debug_menu script)
if (DEBUG_MENU && act_debug && state == "idle") {
	global.debug_menu_request = true;
	instance_create_depth(0, 0, -1000, obj_pause_menu);
	exit;
}

//In deep water? (flippers, see player_moves) In quicksand? (see the ladhellin script)
player_swim_check();
player_water_step();	//currents, a floe melting (see the puzzles script)
player_quicksand_check();

//B = sword, A and Y = equipped items (used further down). Not while swimming or carrying a rock.
//A B press is remembered for a few steps, so pressing it just before a swing or a hit ends still swings.
if (act_b) {sword_buffer = SWORD_BUFFER}
else if (sword_buffer > 0) {sword_buffer--}
act_attack = sword_buffer > 0 && global.swordTier > 0 && !swimming && !carrying;

//Debug menu cheats: god mode, infinite magic and ammo (see the debug_menu script)
debug_cheats_step();

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

//Beeps while health is low (see the game_feel script)
low_health_step();

//Flash after getting hurt
if (hurt_timer > 0) {hurt_timer--}
image_alpha = 1;
if (hurt_timer > 0 && (hurt_timer div 4) mod 2 == 0) {image_alpha = 0.4}

xx = move_right - move_left;
yy = move_down - move_up;

//Same speed every way (diagonals aren't faster)
var move_spd = spd;
if (xx != 0 && yy != 0) {move_spd *= 0.7071}
//Chilled by ice: half speed for a moment
if (chill_timer > 0) {
	chill_timer--;
	move_spd *= 0.5;
}
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
if (in_sand) {
	hspd *= QUICKSAND_SLOW;
	vspd *= QUICKSAND_SLOW;
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
if (carrying && state == "idle" && (act_a || act_b || act_y || act_x)) {
	player_throw_rock();
}

// Attack: obj_sword swings the blade around Link (he holds still while it does).
// Holding B afterwards charges the spin attack (see player_sword_start and player_spin_step).
if(act_attack&&state="idle"&&!carrying){
	player_sword_start();
}
player_spin_step();

// Open the chest, or talk to the NPC (or read the sign) Link is facing with A
// (instead of using the item on A). Not from the water: a chest in a flooded basin waits till it's drained.
if (act_a && state == "idle" && !carrying && !swimming) {
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

// Use the items on A, Y and X
if (act_a && state == "idle" && player_can_use(global.itemA)) {
	item_use(global.itemA);
}
if (act_y && state == "idle" && player_can_use(global.itemY)) {
	item_use(global.itemY);
}
if (act_x && state == "idle" && player_can_use(global.itemX)) {
	item_use(global.itemX);
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

// Timer01 (the grapple hook, the flute, the boots, jumping, falling and charging the spin end their own states)
if(state!="idle"&&state!="hook"&&state!="pull"&&state!="flute"&&state!="charge"&&state!="dash"&&state!="jump"&&state!="fall"&&state!="hop"&&state!="spin_charge"){
	if(cnt<dur){cnt++}
	if(cnt>=dur){
		//Still holding B after a swing: charge the spin attack
		if(state=="attack"&&hold_b&&!swimming&&!carrying&&instance_exists(obj_sword)){
			state="spin_charge";
			spin_t=0;
		}else{
			state="idle";sprite_index=spr_prev;pose=-1;
		}
	}
}

// Frame for walking, running, or the sword/hammer/rock pose
player_animate();

 


