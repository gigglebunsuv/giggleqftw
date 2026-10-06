/// @description Sign: Link faces it and presses A to read it
//A kind of NPC (child of obj_npc, so also a wall) that doesn't turn or look around.
//Set what it says in the instance's Creation Code:
//	dialogue = "SOME TEXT";			just some text (long text wraps and carries on in the next box)
//	dialogue = dlg_debug_cape;		or a function from a dialogue script, or ["BOX 1", "BOX 2"]

event_inherited();
dialogue = "THERE'S NOTHING WRITTEN HERE.";
face_player = false;
look_range = 0;
facing = 0;
//A drawn placeholder until spr_sign is imported (1 frame)
sprite_index = asset_get_index("spr_sign");
