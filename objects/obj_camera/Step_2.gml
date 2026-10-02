/// @description Slide to the player's screen

if (!instance_exists(obj_link)) exit;

cam_flip_target(view_camera[0]);

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
