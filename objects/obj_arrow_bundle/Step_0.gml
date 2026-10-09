/// @description Picked up when Link touches it (once he has the bow)

if (instance_exists(obj_link) && place_meeting(x, y, obj_link) && global.item_have[ITEM.BOW]) {
	player_add_arrows(amount);
	sfx_play(SFX_ITEM_GET);
	instance_destroy();
}
