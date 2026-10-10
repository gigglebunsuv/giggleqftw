//Dialogue: text boxes and choice boxes, for NPCs, signs, cutscenes...
//What people say lives in the dialogue_lines script. This script plays it.
//
//A conversation is an array of steps, played in order:
//	"SOME TEXT"							a text box. Long text wraps, and carries on in the next box if it
//										doesn't fit. "\n" starts a new line. Lowercase is shown in capitals.
//	dlg_choice("QUESTION?", [			text, then a choice box. Each answer is ["ANSWER", [steps]]:
//		["YES", ["GREAT!"]],			those steps play when it's picked, then the conversation goes on
//		["NO", ["OH WELL."]]			after the choice. An answer with nothing after it can be just "OK".
//	])									B picks the last answer.
//	dlg_if("flag", [steps], [steps])	the first steps if the flag is set (see flag_get), the second if not.
//										The flag can also be a function that returns true or false.
//	dlg_set("flag")						sets a flag. dlg_set("flag", false) clears it, dlg_set("flag", 3) for numbers.
//	dlg_run(function() {...})			runs some code, like dlg_run(function() {player_add_money(10)}). The frozen
//										game is woken up while it runs, so it can reach any instance.
//	dlg_end()							ends the conversation here
//	dlg_shop("goods")					opens a shop's counter (see the shop script)
//
//Start one with dialogue_start(steps). obj_npc does it when Link faces it and presses A
//(so does obj_sign, a kind of NPC). Opening an obj_chest shows one too (see the chests script).
//The game freezes while the box is open, like the pause screen (only Link and the HUD stay awake).

#macro DIALOGUE_CHARS 28	//letters per line
#macro DIALOGUE_LINES 3		//lines per box
#macro DIALOGUE_SPEED 0.5	//letters per step as the text types out
#macro DIALOGUE_DEPTH -10000	//obj_dialogue draws the frozen game above everything at this depth

//Story flags set by conversations (and anything else). obj_link's Create clears them for a new game.
global.flags = {};

///flag_get(name);
function flag_get(argument0) {
	//The flag's value, or false if it was never set
	if (!variable_struct_exists(global.flags, argument0)) return false;
	return global.flags[$ argument0];


}

///flag_set(name, value);
function flag_set(argument0, argument1) {
	global.flags[$ argument0] = argument1;


}

///dlg_choice(question, answers);
function dlg_choice(argument0, argument1) {
	return {type: "choice", text: argument0, answers: argument1};


}

///dlg_if(flag, steps_if_set, [steps_if_not]);
function dlg_if(argument0, argument1, argument2) {
	return {type: "if", cond: argument0, yes: argument1, no: argument2};


}

///dlg_set(flag, [value]);
function dlg_set(argument0, argument1) {
	var value = argument1;
	if (is_undefined(value)) {value = true}
	return {type: "set", flag: argument0, value: value};


}

///dlg_run(function);
function dlg_run(argument0) {
	return {type: "run", func: argument0};


}

///dlg_end();
function dlg_end() {
	return {type: "end"};


}

///dialogue_start(steps);
function dialogue_start(argument0) {
	//Opens a text box and plays a conversation. steps: an array of steps, a function that
	//returns one (like dlg_test_npc), or just some text. Does nothing if a box is already open.
	if (instance_exists(obj_dialogue)) return noone;
	var steps = argument0;
	if (is_string(steps)) {steps = [steps]}
	else if (is_method(steps)) {steps = steps()}
	else if (!is_array(steps)) {steps = script_execute(steps)}
	var d = instance_create_depth(0, 0, DIALOGUE_DEPTH, obj_dialogue);
	d.stack = [{steps: steps, pos: 0}];
	with (d) {dialogue_advance()}
	return d;


}

///dialogue_run_awake(function);
function dialogue_run_awake(argument0) {
	//Run by obj_dialogue for a dlg_run step. The game is frozen (deactivated), so with (obj_...) and
	//instance_exists wouldn't see anything: wake it all up for the call, then put back to sleep what
	//was asleep. Anything the code creates stays awake (like obj_fishing, or a room fade).
	var f = argument0;
	var awake = {};
	with (all) {variable_struct_set(awake, string(id), true)}
	instance_activate_all();
	var asleep = [];
	with (all) {
		if (!variable_struct_exists(awake, string(id))) {array_push(asleep, id)}
	}
	//Call methods directly: script_execute drops what they're bound to
	if (is_method(f)) {f()} else {script_execute(f)}
	for (var i = 0; i < array_length(asleep); i++) {
		if (instance_exists(asleep[i])) {instance_deactivate_object(asleep[i])}
	}


}

///dialogue_advance();
function dialogue_advance() {
	//Run by obj_dialogue. Plays steps until one shows a box, setting flags and running code
	//on the way. Closes the box when the conversation is over.
	choices = [];
	while (array_length(stack) > 0) {
		//stack: the conversation, plus the steps of any answer or dlg_if it's inside
		var top = stack[array_length(stack) - 1];
		if (top.pos >= array_length(top.steps)) {
			array_pop(stack);
			continue;
		}
		var s = top.steps[top.pos];
		top.pos += 1;

		if (is_string(s)) {
			dialogue_show(s);
			return;
		}
		if (!is_struct(s)) continue;
		switch (s.type) {
			case "choice":
				choices = s.answers;
				cursor = 0;
				dialogue_show(s.text);
				return;
			case "if":
				var branch = s.no;
				if (dialogue_check(s.cond)) {branch = s.yes}
				if (is_array(branch)) {array_push(stack, {steps: branch, pos: 0})}
				break;
			case "set":
				flag_set(s.flag, s.value);
				break;
			case "run":
				dialogue_run_awake(s.func);
				break;
			case "end":
				stack = [];
				break;
			case "shop":
				shop_ui_open(s.shop);
				return;
		}
	}
	dialogue_close();


}

///dialogue_check(condition);
function dialogue_check(argument0) {
	//dlg_if's condition: a flag name, or a function that returns true or false
	if (is_string(argument0)) {
		var v = flag_get(argument0);
		if (is_string(v)) return v != "";
		return v != 0;	//true, or a number other than 0
	}
	var f = argument0;
	if (is_method(f)) return f();
	return script_execute(f);


}

///dialogue_pick(answer);
function dialogue_pick(argument0) {
	//Run by obj_dialogue when an answer is picked: play its steps, then carry on
	var a = choices[argument0];
	choices = [];
	if (is_array(a) && array_length(a) > 1 && is_array(a[1])) {array_push(stack, {steps: a[1], pos: 0})}
	dialogue_advance();


}

///dialogue_answer_text(answer);
function dialogue_answer_text(argument0) {
	//An answer is ["TEXT", [steps]] or just "TEXT"
	if (is_array(argument0)) return string_upper(argument0[0]);
	return string_upper(argument0);


}

///dialogue_show(text);
function dialogue_show(argument0) {
	//Run by obj_dialogue. Wraps the text and splits it into boxes of DIALOGUE_LINES lines.
	var lines = dialogue_wrap(argument0);
	pages = [];
	for (var i = 0; i < array_length(lines); i += DIALOGUE_LINES) {
		var p = [];
		for (var j = i; j < min(i + DIALOGUE_LINES, array_length(lines)); j++) {array_push(p, lines[j])}
		array_push(pages, p);
	}
	if (array_length(pages) == 0) {pages = [[""]]}
	page = 0;
	shown = 0;
	page_len = dialogue_page_length(pages[0]);


}

///dialogue_page_length(lines);
function dialogue_page_length(argument0) {
	//Letters in a box, to know when it's done typing out
	var n = 0;
	for (var i = 0; i < array_length(argument0); i++) {n += string_length(argument0[i])}
	return n;


}

///dialogue_wrap(text);
function dialogue_wrap(argument0) {
	//Splits text into lines of up to DIALOGUE_CHARS letters, breaking between words.
	//"\n" starts a new line. Everything is made capitals (the menu font only has capitals).
	var str = string_upper(argument0);
	var len = string_length(str);
	var lines = [];
	var line = "";
	var word = "";
	for (var i = 1; i <= len + 1; i++) {
		var c = "\n";	//one past the end finishes the last word and line
		if (i <= len) {c = string_char_at(str, i)}
		if (c != " " && c != "\n") {
			word += c;
			continue;
		}
		//End of a word: put it on this line, or start the next line if it doesn't fit
		if (word != "") {
			if (line == "") {
				line = word;
			} else if (string_length(line) + 1 + string_length(word) <= DIALOGUE_CHARS) {
				line += " " + word;
			} else {
				array_push(lines, line);
				line = word;
			}
			word = "";
		}
		if (c == "\n" && (i <= len || line != "")) {
			array_push(lines, line);
			line = "";
		}
	}
	return lines;


}

///dialogue_close();
function dialogue_close() {
	//Run by obj_dialogue: wake the game back up
	instance_activate_all();
	global.pause_block = true;	//so Link ignores the button that closed the box
	instance_destroy();


}

///npc_in_front();
function npc_in_front() {
	//Run by obj_link. The obj_npc (or obj_sign) just in front of him, or noone.
	var ang = player_face_angle(dir);
	var cx = (bbox_left + bbox_right + 1) / 2 + lengthdir_x(12, ang);
	var cy = (bbox_top + bbox_bottom + 1) / 2 + lengthdir_y(12, ang);
	return collision_rectangle(cx - 4, cy - 4, cx + 4, cy + 4, obj_npc, false, true);


}

///npc_talk(npc);
function npc_talk(argument0) {
	//Run by obj_link: the NPC turns to look at him (unless face_player is false) and talks
	with (argument0) {
		if (face_player) {npc_face_link()}
	}
	dialogue_start(argument0.dialogue);


}

///npc_face_link();
function npc_face_link() {
	//Run by obj_npc: turn to look at Link (facing: 0 right, 1 up, 2 left, 3 down)
	var cx = (bbox_left + bbox_right + 1) / 2;
	var cy = (bbox_top + bbox_bottom + 1) / 2;
	var lx = (obj_link.bbox_left + obj_link.bbox_right + 1) / 2;
	var ly = (obj_link.bbox_top + obj_link.bbox_bottom + 1) / 2;
	facing = round(point_direction(cx, cy, lx, ly) / 90) mod 4;


}
