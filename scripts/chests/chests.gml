//Chests: Link faces one and presses A. It opens, what's inside rises up over his head,
//and a text box says what he got. obj_chest is the chest, obj_item_get plays the animation.
//What a chest holds is set the same way as obj_treasure (see its Create event), and giving it
//uses the same code (treasure_collect in the items_use script).
//Signs are obj_sign (a kind of NPC that doesn't turn or move, see the dialogue_system script).

#macro ITEMGET_RISE 24		//steps the item takes to rise out of the chest up over Link's head
#macro ITEMGET_HOLD 16		//steps Link holds it up before the text box opens
#macro ITEMGET_HEIGHT 20	//pixels above Link's middle the item is held

///chest_in_front();
function chest_in_front() {
	//Run by obj_link. The closed obj_chest just in front of him, or noone.
	var ang = player_face_angle(dir);
	var cx = (bbox_left + bbox_right + 1) / 2 + lengthdir_x(12, ang);
	var cy = (bbox_top + bbox_bottom + 1) / 2 + lengthdir_y(12, ang);
	var chest = collision_rectangle(cx - 4, cy - 4, cx + 4, cy + 4, obj_chest, false, true);
	if (chest != noone && chest.opened) return noone;
	return chest;


}

///chest_open(chest);
function chest_open(argument0) {
	//Run by obj_link: the chest opens, Link turns to face the camera and holds the item up
	//(state "itemget") while obj_item_get plays the rest
	var chest = argument0;
	with (chest) {
		opened = true;
		if (remember) {flag_set(chest_flag(), true)}
	}
	sfx_play(SFX_CHEST);

	state = "itemget";
	shielding = false;
	dir = "down";
	sprite_index = player_get_sprite(dir);
	pose = LINK_FRAME_RAISE;
	image_index = pose;
	image_speed = 0;

	var g = instance_create_depth(chest.x, chest.y, depth - 2, obj_item_get);
	g.from_x = (chest.bbox_left + chest.bbox_right + 1) / 2;
	g.from_y = chest.bbox_top + 4;
	g.item = chest.item;
	g.equip = chest.equip;
	g.tier = chest.tier;
	g.contents = chest.contents;
	g.amount = chest.amount;
	g.message = chest.message;
	with (g) {
		var icon = treasure_icon();
		icon_sprite = icon[0];
		icon_frame = icon[1];
		//ITEM.SHIELD gives the next shield up, so show that one
		if (item == ITEM.SHIELD) {icon_frame = clamp(max(global.shieldTier + 1, tier), 1, SHIELD_TIER_MAX) - 1}
	}
	return g;


}

///treasure_hold_up(treasure);
function treasure_hold_up(argument0) {
	//Run by obj_link: like opening a chest, but for something lying out (obj_treasure with
	//hold_up = true, like a boss's heart container): it rises off the floor over his head
	var t = argument0;
	state = "itemget";
	shielding = false;
	dir = "down";
	sprite_index = player_get_sprite(dir);
	pose = LINK_FRAME_RAISE;
	image_index = pose;
	image_speed = 0;

	var g = instance_create_depth(x, y, depth - 2, obj_item_get);
	g.from_x = (t.bbox_left + t.bbox_right + 1) / 2;
	g.from_y = t.bbox_top + 4;
	g.item = t.item;
	g.equip = t.equip;
	g.tier = t.tier;
	g.contents = t.contents;
	g.amount = t.amount;
	g.message = t.message;
	with (g) {
		var icon = treasure_icon();
		icon_sprite = icon[0];
		icon_frame = icon[1];
	}
	return g;


}

///chest_flag();
function chest_flag() {
	//Run by obj_chest: the story flag that remembers it was opened (one per chest, by room and spot)
	return "chest_" + room_get_name(room) + "_" + string(x) + "_" + string(y);


}

///chest_item_name();
function chest_item_name() {
	//Run by obj_item_get (or anything with obj_treasure's variables), after the item was given:
	//what Link got, like "FIRE ROD". "" for an empty chest.
	if (item == ITEM.SHIELD) {return item_get_name(ITEM.SHIELD)}
	if (item != ITEM.NONE) {return item_get_name(item)}
	switch (equip) {
		case "bottle": return bottle_get_name(contents);
		case "sword": return "LEVEL " + string(clamp(tier, 1, SWORD_TIER_MAX)) + " SWORD";
		case "shield": return item_get_name(ITEM.SHIELD);
		case "armor": return "LEVEL " + string(clamp(tier, 1, ARMOR_TIER_MAX)) + " ARMOR";
		case "gloves": return "STRENGTH GLOVES";
		case "flippers": return "FLIPPERS";
		case "boots": return "RUNNING BOOTS";
		case "bomb_bag": return "BIGGER BOMB BAG";
		case "quiver": return "BIGGER QUIVER";
		case "heart": return "HEART CONTAINER";
		case "bun": return "PIECE OF THE BUN";
		case "refill": return "FULL REFILL";
		case "money": return string(amount) + " MONEY";
		case "key": return (amount == 1) ? "SMALL KEY" : string(amount) + " SMALL KEYS";
		case "map": return "DUNGEON MAP";
		case "compass": return "COMPASS";
		case "boss_key": return "BOSS KEY";
	}
	return "";


}

///chest_item_desc();
function chest_item_desc() {
	//Run by obj_item_get: one line on what it does. The chest's message replaces it if it has one.
	if (message != "") return message;
	switch (item) {
		case ITEM.BOW: return "PRESS ITS BUTTON TO SHOOT AN ARROW THE WAY YOU FACE.";
		case ITEM.SHIELD: return "HOLD ITS BUTTON TO RAISE IT AND BLOCK ATTACKS FROM THE FRONT.";
		case ITEM.BOMBS: return "SET ONE DOWN, THEN STAND BACK! BOMBS BREAK CRACKED WALLS.";
		case ITEM.BOOMERANG: return "THROW IT TO STUN ENEMIES. HOLD A DIAGONAL TO THROW IT THAT WAY.";
		case ITEM.GRAPPLE: return "FIRE IT AT A GRAPPLE POST TO BE PULLED ACROSS GAPS.";
		case ITEM.LANTERN: return "A SMALL FLAME FOR LIGHTING TORCHES. USES A LITTLE MAGIC.";
		case ITEM.FIRE_ROD: return "SHOOTS FIRE. BURNS ENEMIES AND BUSHES AND LIGHTS TORCHES.";
		case ITEM.ICE_ROD: return "SHOOTS ICE THAT FREEZES ENEMIES IN PLACE.";
		case ITEM.LIGHTNING_ROD: return "A FAST BOLT THAT GOES RIGHT THROUGH A ROW OF ENEMIES.";
		case ITEM.FLUTE: return "PLAY IT TO WARP TO ANY FLUTE SPOT IN THIS AREA.";
		case ITEM.HAMMER: return "POUND WOODEN PEGS FLAT, AND BONK ENEMIES.";
		case ITEM.SHOVEL: return "DIG THE GROUND IN FRONT OF YOU. SOMETHING MIGHT BE BURIED!";
		case ITEM.CAPE: return "PRESS ITS BUTTON TO JUMP OVER A ONE TILE PIT.";
		case ITEM.MIRROR: return "TAKES YOU BACK TO WHERE YOU CAME INTO THIS AREA.";
	}
	switch (equip) {
		case "bottle": return "DRINK IT WHEN YOU NEED IT. PUT IT ON A OR Y IN THE PAUSE MENU.";
		case "sword": return "YOUR SWORD HITS HARDER NOW!";
		case "shield": return "HOLD ITS BUTTON TO RAISE IT AND BLOCK ATTACKS FROM THE FRONT.";
		case "armor": return "ENEMIES DO LESS DAMAGE NOW.";
		case "gloves": return "WALK INTO A HEAVY ROCK TO LIFT IT. PRESS ANY BUTTON TO THROW IT.";
		case "flippers": return "NOW YOU CAN SWIM IN DEEP WATER!";
		case "boots": return "HOLD THE RUN BUTTON TO DASH. STEER WITH THE ARROWS.";
		case "bomb_bag": return "YOU CAN CARRY MORE BOMBS NOW.";
		case "quiver": return "YOU CAN CARRY MORE ARROWS NOW.";
		case "heart": return "YOUR LIFE WENT UP BY ONE HEART!";
		case "bun": return "FIND EVERY PIECE TO OPEN THE WAY TO THE HIDDEN FOREST.";
		case "refill": return "HEALTH, MAGIC, BOMBS AND ARROWS ARE ALL FULL AGAIN.";
		case "money": return "SPEND IT IN SHOPS.";
		case "key": return "OPENS A LOCKED DOOR. ONLY IN THIS DUNGEON!";
		case "map": return "SHOWS EVERY ROOM OF THIS DUNGEON ON THE PAUSE SCREEN'S QUEST PAGE.";
		case "compass": return "THE MAP NOW SHOWS WHERE THE BOSS IS, AND THE CHESTS NOT YET OPENED.";
		case "boss_key": return "OPENS THE BIG DOOR TO THIS DUNGEON'S BOSS.";
	}
	return "";


}

///chest_item_steps();
function chest_item_steps() {
	//Run by obj_item_get: the text box steps (see the dialogue_system script)
	var name = chest_item_name();
	if (name == "") return ["IT'S EMPTY..."];
	var steps = ["YOU GOT THE " + name + "!"];
	if (equip == "money" || equip == "key") {steps = ["YOU GOT " + name + "!"]}
	var desc = chest_item_desc();
	if (desc != "") {array_push(steps, desc)}
	return steps;


}
