///cam_flip_target(camera);
    function cam_flip_target(argument0) {
        var cam = argument0;
        var w = camera_get_view_width(cam);
        var h = camera_get_view_height(cam);

        //Top-left corner of the screen obj_link is standing on
        target_x = (obj_link.x div w) * w;
        target_y = (obj_link.y div h) * h;

        //Keep the view inside the room (also fixes rooms that aren't an exact multiple of the view size)
        target_x = clamp(target_x, 0, max(0, room_width - w));
        target_y = clamp(target_y, 0, max(0, room_height - h));


    }