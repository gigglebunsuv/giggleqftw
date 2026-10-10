//Game feel: hitstop (a tiny freeze when a hit lands), screen shake, what enemies drop,
//and the low-health beep.
//
//Hitstop: global.hitstop steps where Link, his sword and every enemy hold still (obj_link and
//obj_enemy skip their Step). obj_link's End Step counts it down, and the shake too.
//Screen shake: obj_camera adds feel_shake_x/y to the view after it's placed (see feel_camera_apply).
//It can be turned off on the Options screen (global.opt_shake), and so can the beep (global.opt_beep).
//
//Enemy drops (enemy_drop): run by enemy_hurt when an enemy dies, unless its drops is false (bosses,
//mirages). Every ENEMY_DROP_EVERY-th kill in a row without a drop always drops something, and
//Link gets more hearts when he's low, more arrows when he's out (the same for bombs).

#macro HITSTOP_HIT 2			//steps frozen when the sword hits an enemy
#macro HITSTOP_KILL 3			//...and when that hit kills it
#macro HITSTOP_BOSS 5			//a boss getting hurt
#macro SHAKE_BOMB 3				//pixels, a bomb going off
#macro SHAKE_BOMB_TIME 8
#macro SHAKE_HURT 2				//Link getting hurt
#macro SHAKE_HURT_TIME 6
#macro SHAKE_BOSS 3				//a boss getting hurt, a heavy thing landing
#macro SHAKE_BOSS_TIME 10

#macro ENEMY_DROP_CHANCE 45		//percent of kills that drop something
#macro ENEMY_DROP_EVERY 6		//kills without a drop before one is certain

#macro LOW_HEALTH 2				//health (2 = one heart) at or under which the beep plays
#macro LOW_HEALTH_BEEP_TIME 24	//steps between beeps
#macro SFX_LOW_HEALTH "snd_low_health"

//Runs once at game start
global.hitstop = 0;
global.shake_amount = 0;
global.shake_time = 0;
global.drop_streak = 0;		//kills since the last drop
global.low_beep_timer = 0;

ini_open(OPTIONS_FILE);
global.opt_beep = ini_read_real("gameplay", "low_health_beep", 1);
global.opt_shake = ini_read_real("gameplay", "screen_shake", 1);
ini_close();

///feel_hitstop(steps);
function feel_hitstop(argument0) {
	//Freezes Link and the enemies for a moment (the longest one asked for wins)
	global.hitstop = max(global.hitstop, argument0);


}

///feel_shake(pixels, steps);
function feel_shake(argument0, argument1) {
	//Shakes the screen. A bigger shake replaces a smaller one, a smaller one never cuts a big one short.
	if (!global.opt_shake) return;
	if (argument0 >= global.shake_amount || global.shake_time <= 0) {
		global.shake_amount = argument0;
		global.shake_time = max(global.shake_time, argument1);
	}


}

///feel_end_step();
function feel_end_step() {
	//Run by obj_link's End Step: counts the hitstop and the shake down
	if (global.hitstop > 0) {global.hitstop--}
	if (global.shake_time > 0) {
		global.shake_time--;
		if (global.shake_time <= 0) {global.shake_amount = 0}
	}


}

///feel_camera_apply(camera);
function feel_camera_apply(argument0) {
	//Run by obj_camera after placing the view: nudges it for the screen shake, whole pixels.
	//The camera's own x, y aren't changed, so it settles straight back.
	if (global.shake_time <= 0 || global.shake_amount <= 0) return;
	var a = global.shake_amount * min(1, global.shake_time / 4);	//dies away over the last few steps
	var sx = irandom_range(-1, 1) * round(a);
	var sy = irandom_range(-1, 1) * round(a);
	camera_set_view_pos(argument0, camera_get_view_x(argument0) + sx, camera_get_view_y(argument0) + sy);


}

///feel_frozen();
function feel_frozen() {
	return global.hitstop > 0;


}

//================================================================ enemy drops

///enemy_drop(x, y);
function enemy_drop(argument0, argument1) {
	//Run by enemy_hurt when an enemy dies: maybe a heart, money, magic, bombs or arrows
	global.drop_streak++;
	if (global.drop_streak < ENEMY_DROP_EVERY && irandom(99) >= ENEMY_DROP_CHANCE) return;
	global.drop_streak = 0;

	//Weights: what Link needs right now comes up more often
	var low = global.pHealth <= global.pHealthMax div 3;
	var full = global.pHealth >= global.pHealthMax;
	var w_heart = full ? 4 : (low ? 40 : 20);
	var w_money1 = 22;
	var w_money5 = 10;
	var w_money20 = 2;
	var w_magic = (global.pMagic < global.pMagicMax) ? 12 : 2;
	var w_bombs = 0;
	if (global.item_have[ITEM.BOMBS]) {w_bombs = (global.pBombs == 0) ? 14 : ((global.pBombs < global.pBombsMax) ? 6 : 0)}
	var w_arrows = 0;
	if (global.item_have[ITEM.BOW]) {w_arrows = (global.pArrows == 0) ? 14 : ((global.pArrows < global.pArrowsMax) ? 6 : 0)}

	var kinds = [PICKUP.HEART, PICKUP.MONEY1, PICKUP.MONEY5, PICKUP.MONEY20, PICKUP.MAGIC, PICKUP.BOMBS, PICKUP.ARROWS];
	var weights = [w_heart, w_money1, w_money5, w_money20, w_magic, w_bombs, w_arrows];
	var total = 0;
	for (var i = 0; i < array_length(weights); i++) {total += weights[i]}
	var roll = random(total);
	for (var i = 0; i < array_length(weights); i++) {
		roll -= weights[i];
		if (roll < 0) {
			pickup_create(kinds[i], argument0, argument1);
			return;
		}
	}


}

//================================================================ the low-health beep

///low_health_step();
function low_health_step() {
	//Run by obj_link while the game's running: beeps every so often while health is low
	if (!global.opt_beep || global.pHealth > LOW_HEALTH || global.pHealth <= 0) {
		global.low_beep_timer = 0;
		return;
	}
	if (global.low_beep_timer <= 0) {
		sfx_play(SFX_LOW_HEALTH);
		global.low_beep_timer = LOW_HEALTH_BEEP_TIME;
	}
	global.low_beep_timer--;


}
