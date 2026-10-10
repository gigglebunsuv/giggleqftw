/// @description A warp statue: the flute's warp spot (see the warp_statues script)
//Link wakes it by facing it and pressing A; then the flute's warp menu lists it, and he comes out just
//below it. Place it by the middle of its tile (like NPCs). Set its name in the instance's Creation Code
//(capital letters), e.g. spot_name = "VILLAGE";

event_inherited();
spot_name = "???";
face_player = false;
look_range = 0;
facing = 0;
sprite_index = spr_warp_statue;
dialogue = method(id, warp_statue_steps);
