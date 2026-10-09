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

///player_upgrade_bombs();
function player_upgrade_bombs() {
	//Bigger bomb bag: 8 -> 16 -> 64, and fills it. Returns false if it's already the biggest.
	var caps = [8, 16, 64];
	if (global.bombLevel >= array_length(caps) - 1) return false;
	global.bombLevel++;
	global.pBombsMax = caps[global.bombLevel];
	global.pBombs = global.pBombsMax;
	return true;


}

///player_upgrade_arrows();
function player_upgrade_arrows() {
	//Bigger quiver: 20 -> 40 -> 80, and fills it. Returns false if it's already the biggest.
	var caps = [20, 40, 80];
	if (global.arrowLevel >= array_length(caps) - 1) return false;
	global.arrowLevel++;
	global.pArrowsMax = caps[global.arrowLevel];
	global.pArrows = global.pArrowsMax;
	return true;


}

///player_add_arrows(amount);
function player_add_arrows(argument0) {
	global.pArrows = clamp(global.pArrows + argument0, 0, global.pArrowsMax);


}

///player_armor_damage(amount);
function player_armor_damage(argument0) {
	//Damage after armor: tunic takes it all, chain-mail half, golden armor a quarter.
	//Rounded up, so a hit always takes at least half a heart.
	var amount = argument0;
	switch (global.armorTier) {
		case 2: amount = amount / 2; break;
		case 3: amount = amount / 4; break;
	}
	return max(1, ceil(amount));


}

///player_hurt(amount, from_x, from_y);
function player_hurt(argument0, argument1, argument2) {
	//Damages Link (less with better armor) and knocks him away from (from_x, from_y).
	//Ignored while he's still flashing from the last hit, being pulled by the grapple hook,
	//falling into a pit, hopping down off a ledge, or holding up something he got from a chest.
	//Knocks him out of a jump, and he drops a rock he's carrying.
	with (obj_link) {
		if (hurt_timer <= 0 && state != "pull" && state != "fall" && state != "itemget" && state != "hop") {
			z = 0;
			pose = -1;
			if (carrying) {
				carrying = false;
				rock_break(x, y);
			}
			player_add_health(-player_armor_damage(argument0));
			if (global.pHealth > 0) {sfx_play(SFX_PLAYER_HURT)}
			hurt_timer = 60;
			if (state == "idle" || state == "jump") {spr_prev = sprite_index}
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
	if (bottle_use_fairy()) return;	//a bottled fairy saves him
	state = "dead";
	shielding = false;
	carrying = false;
	pose = -1;
	z = 0;
	image_alpha = 1;
	image_speed = 0;
	hurt_timer = 0;
	instance_create_depth(0, 0, -2000, obj_player_death);


}

///player_face_angle(dir);
function player_face_angle(argument0) {
	//"right", "up", "left", "down" -> 0, 90, 180, 270
	switch (argument0) {
		case "up": return 90;
		case "left": return 180;
		case "down": return 270;
	}
	return 0;


}

///player_get_sprite(dir);
function player_get_sprite(argument0) {
	//Link's walking sprite facing dir, by armor: red tunic, blue chain-mail, golden armor
	var tier = clamp(global.armorTier, 1, ARMOR_TIER_MAX) - 1;
	var sprs = [spr_link_down, spr_link_down_blue, spr_link_down_gold];
	switch (argument0) {
		case "up": sprs = [spr_link_up, spr_link_up_blue, spr_link_up_gold]; break;
		case "left": sprs = [spr_link_left, spr_link_left_blue, spr_link_left_gold]; break;
		case "right": sprs = [spr_link_right, spr_link_right_blue, spr_link_right_gold]; break;
	}
	return sprs[tier];


}
