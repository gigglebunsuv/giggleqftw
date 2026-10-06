/// @description Text box, and the choice box when there's a question

//Inside the play area (under the HUD bar)
var area = hud_play_area();
var gw = display_get_gui_width();

//Text box, as wide as DIALOGUE_CHARS letters and as tall as DIALOGUE_LINES lines
var bw = DIALOGUE_CHARS * 8 + 16;
var bh = DIALOGUE_LINES * 12 + 10;
var bx = (gw - bw) div 2;
var by = area[1] + area[3] - bh - 6;
if (box_top) {by = area[1] + 6}
menu_draw_box(bx, by, bw, bh);

//The text typed out so far
draw_set_font(menu_font);
draw_set_valign(fa_top);
var lines = pages[page];
var left = floor(shown);
for (var i = 0; i < array_length(lines) && left > 0; i++) {
	menu_draw_text_commas(bx + 8, by + 6 + i * 12, string_copy(lines[i], 1, left), c_white);
	left -= string_length(lines[i]);
}

var done = (shown >= page_len);
var asking = (page == array_length(pages) - 1 && array_length(choices) > 0);

//Done typing: a blinking arrow in the corner means press A
if (done && !asking && (current_time div 250) mod 2 == 0) {
	var ax = bx + bw - 13;
	var ay = by + bh - 8;
	menu_draw_rect(ax, ay, 5, 1, MENU_COL_CURSOR);
	menu_draw_rect(ax + 1, ay + 1, 3, 1, MENU_COL_CURSOR);
	menu_draw_rect(ax + 2, ay + 2, 1, 1, MENU_COL_CURSOR);
}

//Choice box on the right, just above the text box (below it when the box is at the top)
if (done && asking) {
	var n = array_length(choices);
	var widest = 0;
	for (var j = 0; j < n; j++) {widest = max(widest, string_length(dialogue_answer_text(choices[j])))}
	var cw = widest * 8 + 22;
	var ch = n * 12 + 8;
	var cx = bx + bw - cw;
	var cy = by - ch - 2;
	if (box_top) {cy = by + bh + 2}
	menu_draw_box(cx, cy, cw, ch);
	for (var k = 0; k < n; k++) {
		var ry = cy + 5 + k * 12;
		if (k == cursor) {
			menu_draw_rect(cx + 6, ry + 2, 4, 4, MENU_COL_CURSOR);
			menu_draw_text_commas(cx + 14, ry, dialogue_answer_text(choices[k]), MENU_COL_CURSOR);
		} else {
			menu_draw_text_commas(cx + 14, ry, dialogue_answer_text(choices[k]), c_white);
		}
	}
}

drawn = true;
