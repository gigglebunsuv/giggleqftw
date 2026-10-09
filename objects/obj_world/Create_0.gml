/// @description The overworld's (and caves') controller: area names and music (see the world script)
//One in rm_overworld and one in rm_caves. Each area's obj_cam_zone has area_name and area_music.

area = noone;	//the zone whose name was shown last
world_water_init();	//the water's animation (rm_overworld only: the caves use the tower's tiles)