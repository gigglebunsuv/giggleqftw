/// @description Snap to the player's screen

//Turn off the room editor's "Object Following" so it can't fight this code
camera_set_view_target(view_camera[0], noone);

global.cam_zone = noone;
global.cam_transition = false;

if (!instance_exists(obj_link)) exit;

//Dungeons: jump straight to Link's zone
if (instance_exists(obj_cam_zone)) {
	cam_zone_snap(view_camera[0]);
	exit;
}

//Jump straight to the right screen (no slide after a warp)
cam_flip_target(view_camera[0]);
x = target_x;
y = target_y;
camera_set_view_pos(view_camera[0],x,y);
