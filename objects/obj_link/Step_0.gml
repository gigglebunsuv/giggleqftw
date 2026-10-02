//Dead: obj_player_death handles the spin and the game over screen
if (state == "dead") exit;

//Get Input
input_get();

//The pause screen just closed: ignore the button that closed it
if (global.pause_block) {
	global.pause_block = false;
	act_a = false;
	act_b = false;
	act_start = false;
}

//Dungeon camera sliding to the next room: wait for it
if (global.cam_transition) {
	image_speed = 0;
	exit;
}

//Pause screen
if (act_start && state == "idle") {
	instance_create_depth(0, 0, -1000, obj_pause_menu);
	exit;
}

//B = sword, A = equipped item (used further down)
act_attack = act_b && global.swordTier > 0;

//Debug keys
//	Ctrl  = lose half a heart	H = heal half a heart
//	Shift = use 4 magic			M = restore 4 magic
//	J     = add a heart container (up to 16)
//	1-4   = add 10 money, 1 key, 1 bomb, 5 arrows
//	5     = next Bun piece (clears all after the third)
//	6-8   = next sword / shield / armor tier (goes back to none after the last)
//	9     = go to the test dungeon
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
if (keyboard_check_pressed(ord("7")))	{global.shieldTier = (global.shieldTier + 1) mod (SHIELD_TIER_MAX + 1)}
if (keyboard_check_pressed(ord("8")))	{global.armorTier = (global.armorTier + 1) mod (ARMOR_TIER_MAX + 1)}
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

hspd = xx*spd;
vspd = yy*spd;

//Movement
if(state=="idle"){
	//Walls for the level Link is on (see the levels script)
	level_move(hspd, vspd, level);

	//Move animation
	if(abs(hspd)<abs(vspd)){
		if(vspd<0){sprite_index=spr_link_up; dir="up"}
		if(vspd>0){sprite_index=spr_link_down; dir="down"}
	}
	if(abs(hspd)>abs(vspd)){
		if(hspd<0){sprite_index=spr_link_left; dir="left"}
		if(hspd>0){sprite_index=spr_link_right; dir="right"}
	}
	if(hspd==0&&vspd==0){
		image_speed = 0;
	} else {image_speed=ani}
}

// Attack: obj_sword swings the blade around Link (he holds still while it does)
if(act_attack&&state="idle"){
	state="attack";
	cnt=0;
	dur=10;
	spr_prev=sprite_index;
	image_speed=0;
	image_index=0;
	instance_create_depth(x,y,depth-1,obj_sword);
}

// Use the item on A
if (act_a && state == "idle") {
	item_use(global.itemA);
}

// Knocked back after getting hurt
if (state == "hurt") {
	level_move(lengthdir_x(3, kb_dir), lengthdir_y(3, kb_dir), level);
}

// Timer01
if(state!="idle"){
	if(cnt<dur){cnt++}
	if(cnt>=dur){state="idle";sprite_index=spr_prev}
}

 


