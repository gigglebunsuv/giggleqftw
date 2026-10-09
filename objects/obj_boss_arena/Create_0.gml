/// @description Middle of a boss's room (invisible marker)
//Once the boss is beaten (boss_flag), the heart container and the dungeon's piece of the Bun
//appear here, and when the Bun is picked up, a warp out (exit_room, exit_x, exit_y).
//The boss theme (music) plays instead of the dungeon's music (room_music) from when Link comes
//onto the boss's room until the boss is beaten (boss_music_step).
//Set those in the instance's Creation Code, and boss_object: the boss of this room
//(e.g. boss_object = obj_bog_boss;).

exit_room = rm_overworld;	//out in front of the Southern Tower's door
exit_x = WORLD_TOWER_X;
exit_y = WORLD_TOWER_Y;
music = BossTheme;
room_music = DungeonOne;
boss_object = obj_gargoyle;
reward_x = x;		//where the rewards and the warp appear (Creation Code can move them, e.g. onto
reward_y = y;		//dry floor when the middle of the room is a pool)
music_on = false;
resume_music = false;	//the boss was beaten: the dungeon's music comes back after the explosions
checked = false;
rewards_out = false;
portal_out = false;
