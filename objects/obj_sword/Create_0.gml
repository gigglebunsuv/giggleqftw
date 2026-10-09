//Swing: the blade sweeps 180 degrees across the way Link is facing.
//spr_sword_swing points right with its origin on the hilt, so image_angle aims it.
//One frame per sword tier: iron, red, magical, Sword of Bun.
sprite_index = spr_sword_swing;
image_speed = 0;
image_index = global.swordTier - 1;
visible = true;

sfx_play(SFX_SWORD);

//Set timer
cnt = 0;
dur = 10;
hilt_dist = 4;	//how far from Link's centre the hilt sits

var face = 0;
switch(obj_link.dir){
	case "up": face = 90; break;
	case "down": face = 270; break;
	case "left": face = 180; break;
	case "right": face = 0; break;
}
start_ang = face + 90;
end_ang = face - 90;
image_angle = start_ang;
x = obj_link.x + lengthdir_x(hilt_dist, image_angle);
y = obj_link.y + lengthdir_y(hilt_dist, image_angle);

audio_play_sound(sword, 2, false);
