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
	//...and sets alight anything that burns (mummies, see enemy_ignite)
	var burn = instance_place(x, y, obj_enemy);
	if (burn != noone && (burn.level == -1 || burn.level == level)) {enemy_ignite(burn)}
}
if (kind == SHOT.LANTERN) exit;	//the lantern's flame doesn't hurt anything

//The rods' tricks (see the puzzles script): fire melts ice and burns barricades, ice freezes deep
//water and flame jets, lightning charges posts and strikes crystal switches and lightning gates
if (rod_shot_tricks()) {
	instance_destroy();
	exit;
}

//Lightning goes on through the metal posts it charges
if (kind != SHOT.LIGHTNING || instance_place(x, y, obj_lightning_post) == noone) {
	if (level_wall_at(x, y, level)) {
		instance_destroy();
		exit;
	}
}

var e = instance_place(x, y, obj_enemy);
if (e != noone && (e.level == -1 || e.level == level)) {
	var already = false;
	for (var i = 0; i < array_length(hit); i++) {
		if (hit[i] == e) {already = true}
	}
	if (!already) {
		//Some enemies are weak to one of the rods (see rod_enemy_damage)
		switch (kind) {
			case SHOT.FIRE:
				enemy_hurt(e, rod_enemy_damage(e, kind, 4), x, y);
				instance_destroy();
				exit;
			case SHOT.ICE:
				var freeze = rod_enemy_freeze_time(e);
				enemy_hurt(e, rod_enemy_damage(e, kind, 1), x, y);
				if (instance_exists(e)) {enemy_stun(e, freeze)}
				instance_destroy();
				exit;
			case SHOT.LIGHTNING:
				//Goes straight through, hitting each enemy once
				array_push(hit, e);
				var zap = rod_enemy_damage(e, kind, 3);
				if (zap > 0) {enemy_hurt(e, zap, x, y)}
				if (instance_exists(e)) {enemy_stun(e, 30)}
				break;
		}
	}
}
