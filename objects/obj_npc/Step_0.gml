/// @description Look at Link while he's close, look back when he leaves

if (home_facing == -1) {home_facing = facing}	//after Creation Code has set facing
if (!face_player) exit;
if (instance_exists(obj_dialogue)) exit;	//keep looking the way they turned to talk

//distance_to_object: the gap between their 16x16 bodies (0 = touching)
if (instance_exists(obj_link) && distance_to_object(obj_link) <= look_range) {
	npc_face_link();
} else {
	facing = home_facing;
}
