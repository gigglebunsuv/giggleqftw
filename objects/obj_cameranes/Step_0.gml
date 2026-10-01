/// @description Insert description here
// You can write your code in this editor

target_x =(obj_link.x div camera_get_view_width(view_camera[0])) * camera_get_view_width(view_camera[0]);
target_y =(obj_link.y div camera_get_view_height(view_camera[0])) * camera_get_view_height(view_camera[0]);

if(abs(x - target_x) <camspd){
	x = target_x;
} else {
	if(target_x > x){
			x += camspd;
	} else if(target_x < x){
		x -=camspd;
	}
}

if(abs(y - target_y) <camspd){
	y = target_y;
} else {
	if(target_y > y){
			y += camspd;
	} else if(target_y < y){
		y -=camspd;
	}
}

camera_set_view_pos(view_camera[0],x,y);