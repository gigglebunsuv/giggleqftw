//Get Input
input_get();

//Use equipped items (only the sword so far)
act_attack = (act_a && global.itemA == spr_hud_item_sword) || (act_b && global.itemB == spr_hud_item_sword);

//Debug keys
//	Ctrl  = lose half a heart	H = heal half a heart
//	Shift = use 4 magic			M = restore 4 magic
//	J     = add a heart container (up to 16)
//	1-4   = add 10 money, 1 key, 1 bomb, 5 arrows
if (keyboard_check_pressed(vk_control))	{player_add_health(-1)}
if (keyboard_check_pressed(ord("H")))	{player_add_health(1)}
if (keyboard_check_pressed(vk_shift))	{player_add_magic(-4)}
if (keyboard_check_pressed(ord("M")))	{player_add_magic(4)}
if (keyboard_check_pressed(ord("J")))	{player_add_heart()}
if (keyboard_check_pressed(ord("1")))	{player_add_money(10)}
if (keyboard_check_pressed(ord("2")))	{player_add_keys(1)}
if (keyboard_check_pressed(ord("3")))	{player_add_bombs(1)}
if (keyboard_check_pressed(ord("4")))	{player_add_arrows(5)}

if global.pHealth < 0 {
	global.pHealth = 0;
}
if global.pHealth > global.pHealthMax {
	global.pHealth = global.pHealthMax;
}
global.pMagic = clamp(global.pMagic, 0, global.pMagicMax);

xx = move_right - move_left;
yy = move_down - move_up;

hspd = xx*spd;
vspd = yy*spd;

//Movement
if(state=="idle"){
	if(place_meeting(x+hspd,y,obj_wall)){
		while(!place_meeting(x+sign(hspd),y,obj_wall)){
			x+=sign(hspd);
		}
		hspd = 0;
	}
	x += hspd;

	if(place_meeting(x,y+vspd,obj_wall)){
		while(!place_meeting(x,y+sign(vspd),obj_wall)){
			y+=sign(vspd);
		}
		vspd = 0;
	}
	y += vspd;

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

// Attack
if(act_attack&&state="idle"){
	state="attack";
	cnt=0;
	dur=10;
	switch(dir){
		case "up":
			instance_create_layer(x,y-grd,"Instances",obj_sword);
			spr_prev=spr_link_up;
			sprite_index=spr_attack_up
		break;
		case "down":
			instance_create_layer(x,y+grd,"Instances",obj_sword);
			spr_prev=spr_link_down;
			sprite_index=spr_attack_down
		break;
		case "left":
			instance_create_layer(x-grd,y,"Instances",obj_sword);
			spr_prev=spr_link_left;
			sprite_index=spr_attack_left
		break;
		case "right":
			instance_create_layer(x+grd,y,"Instances",obj_sword);
			spr_prev=spr_link_right;
			sprite_index=spr_attack_right
		break;
	}
}

// Timer01
if(state!="idle"){
	if(cnt<dur){cnt++}
	if(cnt>=dur){state="idle";sprite_index=spr_prev}
}

 


