/// @description Swing and hit

if (!instance_exists(obj_link)) {
	instance_destroy();
	exit;
}
timer++;
x = obj_link.x + lengthdir_x(12, ang);
y = obj_link.y + lengthdir_y(12, ang);

//Pulled back a little further, then speeding up until it lands
if (timer <= wind_at) {
	swing = 0.3 * (1 - timer / wind_at);
} else {
	swing = sqr(min(1, (timer - wind_at) / (hit_at - wind_at)));
}

//Link's arms follow it (see player_animate)
obj_link.pose = (swing < 0.5) ? LINK_FRAME_RAISE : LINK_FRAME_STRIKE;

//In front of Link, except where it's on the far side of him: over his back when he faces
//down, and out in front when he faces up
var yscale = lerp(raised[1], struck[1], swing);
depth = obj_link.depth - 1;
if ((ang == 270 && yscale > 0) || (ang == 90 && yscale > 0)) {depth = obj_link.depth + 1}

if (timer == hit_at) {
	var hx = x;
	var hy = y;
	var lvl = obj_link.level;
	with (obj_enemy) {
		if ((level == -1 || level == lvl) && collision_rectangle(hx - 7, hy - 7, hx + 7, hy + 7, id, false, false)) {
			enemy_hurt(id, 3, hx, hy);
			if (instance_exists(id)) {enemy_stun(id, ITEM_STUN_TIME div 2)}
		}
	}
	with (obj_peg) {
		if (collision_rectangle(hx - 7, hy - 7, hx + 7, hy + 7, id, false, false)) {peg_pound(id)}
	}
}
if (timer >= done_at) {instance_destroy()}
