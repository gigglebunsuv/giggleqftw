/// @description Behind the roof, half speed

if (zone == noone) {zone = cam_zone_at(x, y)}
if (zone == noone) exit;
var cam = view_camera[0];
var vx = camera_get_view_x(cam);
var vy = camera_get_view_y(cam);
var vw = camera_get_view_width(cam);
var vh = camera_get_view_height(cam);
if (vx > zone.bbox_right || vx + vw < zone.bbox_left || vy > zone.bbox_bottom || vy + vh < zone.bbox_top) exit;
var bx = round(vx - (vx - zone.bbox_left) * 0.5 - 32);
var by = round(vy - (vy - zone.bbox_top) * 0.5 - 32);
draw_sprite(spr_roof_view, 0, bx, by);
