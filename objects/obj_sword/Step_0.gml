if (!instance_exists(obj_link)) {instance_destroy(); exit;}

//Hitstop: hold still with everything else
if (feel_frozen()) exit;

//Swing, hold out in front while charging, or spin (see the sword_spin functions in player_moves)
if (!sword_spin_step()) exit;

//Stay in Link's hand
x = obj_link.x + lengthdir_x(hilt_dist, image_angle);
y = obj_link.y + lengthdir_y(hilt_dist, image_angle);

//Behind Link while the blade points up, in front of him otherwise
depth = obj_link.depth - 1;
if (lengthdir_y(1, image_angle) < -0.5) {depth = obj_link.depth + 1}
