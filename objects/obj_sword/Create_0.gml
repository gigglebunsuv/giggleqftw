//Set timer
cnt=0
dur=10;

switch(obj_link.dir){
	case "up": image_angle = 90; break;
	case "down": image_angle = 270; break;
	case "left": image_angle = 180; break;
	case "right": image_angle = 0; break;
}