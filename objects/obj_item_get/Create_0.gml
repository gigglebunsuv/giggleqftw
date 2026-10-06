/// @description What came out of a chest, rising up over Link's head (see chest_open)
//Holds a copy of the chest's contents (same variables as obj_treasure), so treasure_collect
//and treasure_icon work on it. Gives the item once it's over his head, then opens the
//"YOU GOT..." text box and lets Link go when it closes.

item = ITEM.NONE;
equip = "";
tier = 1;
contents = BOTTLE.EMPTY;
amount = 1;
message = "";

icon_sprite = -1;
icon_frame = 0;
from_x = x;		//where it starts: the top of the chest
from_y = y;
timer = 0;
talking = false;	//the text box has been opened
