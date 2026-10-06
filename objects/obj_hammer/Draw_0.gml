/// @description The hammer, turning on the end of its handle in Link's hands

if (!instance_exists(obj_link)) exit;
var rot = lerp(raised[0], struck[0], swing);
var ys = lerp(raised[1], struck[1], swing);
var hand_x = obj_link.x + round(lerp(raised[2], struck[2], swing));
var hand_y = obj_link.y + round(lerp(raised[3], struck[3], swing));

//Where the grip ends up after scaling and turning (rotation is anticlockwise, y points down),
//so the sprite can be placed with the grip on the hands
var gx = grip_x * xscale;
var gy = grip_y * ys;
var c = dcos(rot);
var s = dsin(rot);
var off_x = gx * c + gy * s;
var off_y = -gx * s + gy * c;
draw_sprite_ext(spr, img, round(hand_x - off_x), round(hand_y - off_y), xscale, ys, rot, c_white, 1);
