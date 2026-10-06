/// @description Someone to talk to (see the dialogue_system script)
//Link talks to them by facing them and pressing A. Blocks the way (child of obj_wall).
//Change these in the instance's Creation Code (or in a child object's Create, after event_inherited()):
//	dialogue = dlg_test_npc;		what they say: a function from the dialogue_lines script,
//									or the steps right there, like  dialogue = ["HELLO!"];
//	facing = 3;						which way they look: 0 right, 1 up, 2 left, 3 down
//	face_player = false;			keep looking that way, even when Link comes close or talks to them
//	look_range = 24;				turn to look at Link when he's this many pixels away or closer
//									(0 = only when he talks to them)
//	sprite_index = spr_villager;	how they look: 4 frames (right, up, left, down), or just 1

dialogue = dlg_test_npc;
facing = 3;
face_player = true;
look_range = 24;
home_facing = -1;	//the way they look when Link isn't around, taken from facing on the first step

//Always block as a 16x16 body, whatever size the sprite is
mask_index = spr_link_down;
image_speed = 0;
//The placeholder look, until a sprite is set
if (sprite_index == -1) {sprite_index = asset_get_index("spr_npc_test")}
