//Activate Timer
if(cnt<dur){cnt++}
if(cnt>=dur || !instance_exists(obj_link)){instance_destroy(); exit;}

//Sweep fast at the start, slowing at the end
var t = 1 - sqr(1 - cnt / dur);
image_angle = lerp(start_ang, end_ang, t);

//Stay in Link's hand
x = obj_link.x + lengthdir_x(hilt_dist, image_angle);
y = obj_link.y + lengthdir_y(hilt_dist, image_angle);

//Behind Link while the blade points up, in front of him otherwise
depth = obj_link.depth - 1;
if (lengthdir_y(1, image_angle) < -0.5) {depth = obj_link.depth + 1}
