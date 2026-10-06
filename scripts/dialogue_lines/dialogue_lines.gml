//What NPCs (and signs, and cutscenes) say. One function per conversation, returning its steps.
//Every kind of step is listed at the top of the dialogue_system script.
//To give an NPC one of these, put  dialogue = dlg_test_npc;  in its Creation Code.
//Letters: A-Z, 0-9, spaces and , . ' ! ? - : / (lowercase is shown in capitals).

///dlg_test_npc();
function dlg_test_npc() {
	return [
		//Something different the first time you talk to them
		dlg_if("met_test_npc", [
			"OH, IT'S YOU AGAIN!"
		], [
			"HELLO, SIR GIGGLEBUNS! I'M JUST A TEST, BUT I CAN STILL TALK.",
			"LONG TEXT LIKE THIS WRAPS ONTO THE NEXT LINE BY ITSELF, AND IF IT GETS TOO LONG FOR ONE BOX, IT CARRIES ON IN THE NEXT ONE.",
			dlg_set("met_test_npc")
		]),
		dlg_choice("DO YOU LIKE BUNS?", [
			["YES", [
				"ME TOO!",
				//Money only once
				dlg_if("test_npc_paid", [
					"I'D GIVE YOU MORE MONEY, BUT I'M ALL OUT."
				], [
					"HERE, HAVE 10 MONEY.",
					dlg_run(function() {player_add_money(10)}),
					dlg_set("test_npc_paid")
				])
			]],
			["NO", ["OH... THAT'S A SHAME."]],
			["WHAT?", ["NEVER MIND."]]
		]),
		"TAKE CARE OUT THERE!"
	];


}

///dlg_test_guard();
function dlg_test_guard() {
	return [
		"HALT! THIS IS THE SECOND TEST NPC.",
		dlg_choice("WANT TO HEAR A SECRET?", [
			["SURE", [
				"ALL NPCS ARE ONE OBJECT.\nONLY THEIR CREATION CODE IS\nDIFFERENT."	//\n starts a new line
			]],
			["NO THANKS", [
				"SUIT YOURSELF.",
				dlg_end()
			]]
		]),
		"NOW YOU KNOW!"
	];


}
