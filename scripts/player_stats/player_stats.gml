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
