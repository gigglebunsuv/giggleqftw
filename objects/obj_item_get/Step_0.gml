/// @description Rise, hold it up, text box, done

if (!instance_exists(obj_link)) {
	instance_destroy();
	exit;
}

//The text box closed (the game was frozen until then): Link can move again
if (talking) {
	if (instance_exists(obj_dialogue)) exit;
	with (obj_link) {
		if (state == "itemget" || state == "talk") {state = "idle"}
		pose = -1;
	}
	instance_destroy();
	exit;
}

timer++;
depth = obj_link.depth - 2;

//Over his head: he gets it (and the jingle plays)
if (timer == ITEMGET_RISE && (item != ITEM.NONE || equip != "")) {
	treasure_collect();
}

if (timer >= ITEMGET_RISE + ITEMGET_HOLD) {
	talking = true;
	dialogue_start(chest_item_steps());
}
