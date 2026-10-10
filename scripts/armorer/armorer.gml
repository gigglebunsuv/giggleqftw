//The armorer in Haven village: makes Link's armor better, for money (his stock is the "armor" shop,
//see shop_goods_list). Blue chain-mail (level 2) and the big shield once the Bog Tower is free, golden
//armor (level 3) once the Tower of Ladhellin is. (The mirror shield is in the Castle of Bunsriel.) The armorer is an obj_npc with  dialogue = dlg_armorer;
//(make_overworld_room.py puts him at his stall in the market).

#macro ARMOR_PRICE_2 400
#macro ARMOR_PRICE_3 900
#macro SHIELD_PRICE_2 300

///dlg_armorer();
function dlg_armorer() {
	if (global.armorTier >= ARMOR_TIER_MAX && global.shieldTier >= 2) {
		return ["THAT GOLDEN ARMOR IS THE FINEST THING I'VE EVER MADE. WEAR IT WELL, SIR GIGGLEBUNS."];
	}
	if (!flag_get(boss_flag(2))) {
		return [
			"WELCOME TO THE ARMORY! I MAKE MAIL TO KEEP ADVENTURERS IN ONE PIECE.",
			"OR I WOULD, IF I HAD ANY IRON. THE SAPPHIRE ORDER BOUGHT UP EVERY SCRAP IN HAVEN.",
			"THE MARSH FOLK USED TO DIG BOG IRON, BEFORE THE BOG TOWER TURNED THE WATER FOUL. FREE IT, AND COME SEE ME."
		];
	}
	return shop_talk("armor", "THE BOG IRON'S COMING IN AGAIN, THANKS TO YOU! LET'S GET YOU INTO SOMETHING STURDIER.",
		"YOU'RE BACK! I'VE BEEN WORKING SOMETHING SPECIAL WITH THE GOLD FROM THE DESERT. TAKE A LOOK!");


}
