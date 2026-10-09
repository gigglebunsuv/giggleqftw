if (targetRoom == noone) exit;
//Not while he's holding something up or talking: the text box and the item would be left
//behind in this room, and Link stuck in that pose in the next one
if (instance_exists(obj_dialogue) || instance_exists(obj_item_get)) exit;
if (obj_link.state == "itemget" || obj_link.state == "talk" || obj_link.state == "dead") exit;
//Already fading out through this warp (or another): see the room_fade script
if (instance_exists(obj_room_fade)) exit;
sfx_play(SFX_WARP);
room_fade_start(targetRoom, targetX, targetY, object_index == obj_warp_portal);
