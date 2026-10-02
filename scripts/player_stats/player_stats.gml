//Player health, magic, heart containers and item counters.
//All amounts can be negative (damage, spending, using items).

#macro PLAYER_HEARTS_MAX 16

///player_add_health(amount);
function player_add_health(argument0) {
	//1 = half a heart. Use a negative amount for damage.
	global.pHealth = clamp(global.pHealth + argument0, 0, global.pHealthMax);


}

///player_add_magic(amount);
function player_add_magic(argument0) {
	global.pMagic = clamp(global.pMagic + argument0, 0, global.pMagicMax);


}

///player_add_heart();
function player_add_heart() {
	//Heart container: +1 max heart (up to PLAYER_HEARTS_MAX) and refill health.
	//Returns false if already at the max.
	if (global.pHealthMax >= PLAYER_HEARTS_MAX * 2) return false;

	global.pHealthMax += 2;
	global.pHealth = global.pHealthMax;
	return true;


}

///player_add_money(amount);
function player_add_money(argument0) {
	global.pMoney = clamp(global.pMoney + argument0, 0, global.pMoneyMax);


}

///player_add_keys(amount);
function player_add_keys(argument0) {
	global.pKeys = clamp(global.pKeys + argument0, 0, global.pKeysMax);


}

///player_add_bombs(amount);
function player_add_bombs(argument0) {
	global.pBombs = clamp(global.pBombs + argument0, 0, global.pBombsMax);


}

///player_add_arrows(amount);
function player_add_arrows(argument0) {
	global.pArrows = clamp(global.pArrows + argument0, 0, global.pArrowsMax);


}

///player_hurt(amount, from_x, from_y);
function player_hurt(argument0, argument1, argument2) {
	//Damages Link and knocks him away from (from_x, from_y).
	//Ignored while he's still flashing from the last hit.
	with (obj_link) {
		if (hurt_timer <= 0) {
			player_add_health(-argument0);
			if (global.pHealth > 0) {sfx_play(SFX_PLAYER_HURT)}
			hurt_timer = 60;
			if (state == "idle") {spr_prev = sprite_index}
			state = "hurt";
			cnt = 0;
			dur = 8;
			kb_dir = point_direction(argument1, argument2, x, y);
		}
	}


}

///player_die();
function player_die() {
	//Run by obj_link when his health hits zero: spin, fade, game over screen (obj_player_death)
	if (state == "dead") return;
	state = "dead";
	image_alpha = 1;
	image_speed = 0;
	hurt_timer = 0;
	instance_create_depth(0, 0, -2000, obj_player_death);


}
