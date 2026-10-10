//The Sun Lens, the Tower of Ladhellin's second treasure. Hold its button to see through mirages,
//using up magic while it's held (one point every LENS_DRAIN_TIME steps). obj_lens is made when
//its button is pressed and goes away when the button is let go, or the magic runs out.
//
//What it shows, in any room built with these tile layers (make_ladhellin_room.py makes them):
//	"Illusion_Low", "Illusion_Wall"		the lies: floor painted over a hole, a hole painted over
//										solid floor (a hidden path), a wall painted where there's
//										none. Hidden while the lens is up.
//	"Lens_Show"							a glow round everything that was a lie. Only shown while the
//										lens is up.
//Mirage enemies (obj_mirage) and the boss's copies (obj_sphinx_mirage) check lens_active().

#macro LENS_DRAIN_TIME 10		//steps per point of magic while the lens is held
#macro LENS_TINT make_colour_rgb(232, 208, 170)	//the warm light over the screen (#e8d0aa)
#macro LENS_TINT_ALPHA 0.14
#macro LENS_HIDE_LAYERS ["Illusion_Low", "Illusion_Wall"]
#macro LENS_SHOW_LAYERS ["Lens_Show"]

///lens_is_held();
function lens_is_held() {
	//Run by obj_link after input_get: is the button the Sun Lens is on being held?
	return item_button_held(ITEM.LENS);


}

///item_use_lens();
function item_use_lens() {
	//Run by obj_link when the lens's button is pressed: the lens goes up (obj_lens)
	if (instance_exists(obj_lens) || global.pMagic <= 0) return false;
	instance_create_depth(0, 0, -800, obj_lens);
	sfx_play(SFX_LENS);
	return true;


}

///lens_active();
function lens_active() {
	//Is the lens up right now?
	return instance_exists(obj_lens);


}

///lens_step();
function lens_step() {
	//Run by obj_lens every step: keep going while the button is held and there's magic left
	var held = false;
	with (obj_link) {
		held = lens_is_held() && state != "dead" && !swimming;
	}
	if (!held || global.pMagic <= 0) {
		instance_destroy();
		return;
	}
	drain++;
	if (drain >= LENS_DRAIN_TIME) {
		drain = 0;
		player_add_magic(-1);
	}
	lens_layers_set(true);


}

///lens_layers_set(on);
function lens_layers_set(argument0) {
	//Hides the lies and shows the glow (on), or puts them back (off). Rooms without the layers are left alone.
	var hide = LENS_HIDE_LAYERS;
	var show = LENS_SHOW_LAYERS;
	for (var i = 0; i < array_length(hide); i++) {
		var lay = layer_get_id(hide[i]);
		if (lay != -1) {layer_set_visible(lay, !argument0)}
	}
	for (var j = 0; j < array_length(show); j++) {
		var lay2 = layer_get_id(show[j]);
		if (lay2 != -1) {layer_set_visible(lay2, argument0)}
	}


}

///lens_room_start();
function lens_room_start() {
	//Run at Room Start (obj_link, see collision_tiles_make): the lens isn't up in a new room
	lens_layers_set(false);


}

///lens_draw();
function lens_draw() {
	//Run by obj_lens's Draw: warm light over the view
	if (!view_enabled) return;
	var cam = view_camera[0];
	draw_sprite_ext(spr_pixel, 0, camera_get_view_x(cam), camera_get_view_y(cam),
		camera_get_view_width(cam), camera_get_view_height(cam), 0, LENS_TINT, LENS_TINT_ALPHA);


}
