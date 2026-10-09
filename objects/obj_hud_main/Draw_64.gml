/// @description Draw HUD

if (!instance_exists(obj_link)) exit;

//Black around the view (rooms with a smaller view), then the bar across the top
hud_draw_letterbox();
//Hidden during the opening's dream (see the cutscene script)
if (global.hud_hidden) exit;
hud_draw_bar();
hud_draw_floor_name();
