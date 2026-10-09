/// @description Fly, light torches, burn bushes, hit enemies

life--;
if (life <= 0) {
	instance_destroy();
	exit;
}

//Fire lights torches and burns bushes and tall grass
if (kind == SHOT.LANTERN || kind == SHOT.FIRE) {
	var torch = instance_place(x, y, obj_torch);
	if (torch != noone) {torch_light(torch)}
	var cut = instance_place(x, y, obj_bush);
	if (cut != noone) {with (cut) {bush_cut()}}
	var bush = instance_place(x, y, obj_bush_grass);
	if (bush != noone) {with (bush) {instance_destroy()}}
	var grass = instance_place(x, y, obj_tallgrass_grass);
	if (grass != noone) {with (grass) {instance_destroy()}}
}
if (kind == SHOT.LANTERN) exit;	//the lantern's flame doesn't hurt anything

if (level_wall_at(x, y, level)) {
	instance_destroy();
	exit;
}

var e = instance_place(x, y, obj_enemy);
if (e != noone && (e.level == -1 || e.level == level)) {
	var already = false;
	for (var i = 0; i < array_length(hit); i++) {
		if (hit[i] == e) {already = true}
	}
	if (!already) {
		switch (kind) {
			case SHOT.FIRE:
				enemy_hurt(e, 4, x, y);
				instance_destroy();
				exit;
			case SHOT.ICE:
				enemy_hurt(e, 1, x, y);
				if (instance_exists(e)) {enemy_stun(e, ICE_FREEZE_TIME)}
				instance_destroy();
				exit;
			case SHOT.LIGHTNING:
				//Goes straight through, hitting each enemy once
				array_push(hit, e);
				enemy_hurt(e, 3, x, y);
				if (instance_exists(e)) {enemy_stun(e, 30)}
				break;
		}
	}
}
