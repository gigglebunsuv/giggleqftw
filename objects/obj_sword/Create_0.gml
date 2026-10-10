//Swing: the blade sweeps 180 degrees across the way Link is facing.
//spr_sword_swing points right with its origin on the hilt, so image_angle aims it.
//One frame per sword tier: iron, red, magical, Sword of Bun.
//mode: "swing", then "hold" while B stays held (Link charging the spin attack, see sword_spin_step),
//then "spin" (a full turn round him, double damage).
sprite_index = spr_sword_swing;
image_speed = 0;
image_index = global.swordTier - 1;
visible = true;

sfx_play(SFX_SWORD);

mode = "swing";
damage = global.swordTier;	//what a hit does to an enemy (see obj_enemy's Step)

//Set timer
cnt = 0;
dur = 10;
hilt_dist = 4;	//how far from Link's centre the hilt sits

var face = player_face_angle(obj_link.dir);
start_ang = face + 90;
end_ang = face - 90;
image_angle = start_ang;
x = obj_link.x + lengthdir_x(hilt_dist, image_angle);
y = obj_link.y + lengthdir_y(hilt_dist, image_angle);
