/// @description A stone owl with a hint for its room (see hint_statue_steps)
//Set in its Creation Code: hint = "..."; (what it says) and hint2 = "..."; (plainer, once Link has been
//stuck in the room for HINT_STUCK_TIME). It also offers to put the room's push blocks back.

event_inherited();
face_player = false;
look_range = 0;
facing = 0;
hint = "...";
hint2 = "";
zone = noone;
stay_t = 0;
sprite_index = spr_hint_statue;
dialogue = method(id, hint_statue_steps);
