//The smith in Haven village: forges Star Iron into Link's sword. Bosses of the dungeons up to
//SMITH_DUNGEONS (see boss_rewards_spawn) each leave a lump of Star Iron (global.swordOre).
//The Southern Tower's and the Bog Tower's bosses each leave one lump; one lump and a fee take
//the sword up one level: 1 > 2 > 3. These are optional. The Sword of Bun (level 4, SWORD_TIER_BUN)
//is the next sword the story needs, and the smith can't make or improve it.
//The smith is an obj_npc with  dialogue = dlg_smith;  (make_overworld_room.py puts him at his forge).

#macro SMITH_DUNGEONS 2				//dungeons whose bosses leave Star Iron (1 Southern Tower, 2 Bog Tower)
#macro SMITH_TIER_MAX 3				//the best sword the smith can forge
#macro SMITH_PRICES [0, 0, 150, 300]	//the fee for forging the sword up to each level

///smith_ore_seen();
function smith_ore_seen() {
	//Has Link ever had Star Iron? (the pause screen's QUEST page shows how much he has from then on)
	if (global.swordOre > 0) return true;
	for (var d = 1; d <= SMITH_DUNGEONS; d++) {
		if (flag_get(boss_reward_flag(d, "ore"))) return true;
	}
	return false;


}

///smith_price(tier);
function smith_price(argument0) {
	//The fee for forging the sword up to this level
	var prices = SMITH_PRICES;
	return prices[clamp(argument0, 0, array_length(prices) - 1)];


}

///smith_forge(tier);
function smith_forge(argument0) {
	//Pays, uses up a lump of Star Iron and gives the new sword. Returns the steps to say.
	var t = argument0;
	var price = smith_price(t);
	if (global.pMoney < price) return ["HMPH. THAT'S NOT ENOUGH MONEY. FORGING TAKES COAL AND TIME. COME BACK WITH " + string(price) + "."];
	if (global.swordOre <= 0 || global.swordTier != t - 1) return ["...WAIT, WHERE DID THE STAR IRON GO?"];
	player_add_money(-price);
	global.swordOre -= 1;
	sfx_play(SFX_HAMMER);
	var steps = ["*CLANG* *CLANG* *CLANG*... THERE. TAKE A LOOK AT THAT."];
	steps = array_concat(steps, world_give({equip: "sword", tier: t}));
	array_push(steps, (t >= SMITH_TIER_MAX)
		? "THAT'S THE FINEST BLADE I'VE EVER MADE. THERE'S NOTHING MORE MY HAMMER CAN TEACH THAT STEEL."
		: "BRING ME MORE STAR IRON AND I'LL MAKE IT STRONGER STILL.");
	return steps;


}

///dlg_smith();
function dlg_smith() {
	//What the smith says depends on Link's sword and his Star Iron (worked out when he's spoken to)
	var steps = [];
	if (!flag_get("met_smith")) {
		array_push(steps, "WELCOME TO MY FORGE. I'M THE SMITH OF HAVEN. MOST DAYS I MEND HOES AND HINGES.",
			"BUT GIVE ME STAR IRON AND I CAN MAKE A SWORD SING. THE GUARDIANS OF THE TOWERS ARE SAID TO HOARD IT.");
		flag_set("met_smith", true);
	}
	//The hammer's trading chain: he shapes the woodcutter's ironwood into a handle (see the trade_quest script)
	var trade = trade_smith_steps();
	if (array_length(trade) > 0) return array_concat(steps, trade);
	if (global.swordTier <= 0) {
		array_push(steps, "NO SWORD? GO SEE THE KNIGHT AT THE NORTH GATE. HE'S BEEN WAITING TO HAND HIS OLD ONE ON.");
		return steps;
	}
	if (global.swordTier >= SMITH_TIER_MAX) {
		array_push(steps, (global.swordTier >= SWORD_TIER_BUN)
			? "THE SWORD OF BUN... THE BUN'S POWER IS BEYOND ANYTHING MY HAMMER COULD ADD. I WOULDN'T DARE TOUCH IT."
			: "YOUR SWORD IS AS STRONG AS MY HAMMER CAN MAKE IT. ONLY THE BUN'S OWN POWER COULD TAKE IT FURTHER.");
		return steps;
	}
	var t = global.swordTier + 1;
	var price = smith_price(t);
	if (global.swordOre <= 0) {
		array_push(steps, "BRING ME A LUMP OF STAR IRON AND " + string(price) + " MONEY, AND I'LL FORGE YOU A LEVEL " + string(t) + " SWORD.",
			"THE BEASTS THAT GUARD THE TOWERS DROP IT WHEN THEY FALL. THE SOUTHERN TOWER'S GUARDIAN, THEN THE BOG TOWER'S.");
		return steps;
	}
	array_push(steps, "THAT'S STAR IRON YOU'RE CARRYING! I CAN SEE IT GLOWING FROM HERE.");
	array_push(steps, dlg_choice("FORGE A LEVEL " + string(t) + " SWORD FOR 1 STAR IRON AND " + string(price) + " MONEY? YOU HAVE " + string(global.pMoney) + ".", [
		["YES", [dlg_run(method({tier: t}, function() {dialogue_insert(smith_forge(tier))}))]],
		["NO", ["SUIT YOURSELF. THE FORGE WILL STAY HOT."]]
	]));
	return steps;


}
