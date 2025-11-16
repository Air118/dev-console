/*
 * Developer console : Made by Piotr Kościukiewicz
 * 
 * This console aims to help debug or modify stuff while the game is running.
 * 
*/

// > TODO: Add a scrollbar
// > DONE TODO: Add a button for resizing the window
// > DONE TODO: Make the commands accept parameters
// > DONE TODO: Allow the commands to be color coded
// > DONE TODO: Add logging - Way to add logs without parsing commands
// > DONE TODO: Make the text bg darker
// > DONE TODO: Add the ability to move the cursor left and right
// > TODO: Add text selection
// > DONE TODO: Rework input handling
// > DONE TODO: Add autocompletion
// > DONE TODO: Add a monospaced font

// > Info
__title = "CONSOLE";
__version = "v0.1";

active = true;

// > Theme
font = FntAgency;
color_window = make_colour_rgb(100, 100, 100);
color_log = make_colour_rgb(80, 80, 80);
color_textbox = make_colour_rgb(80, 80, 80);
color_outline = make_colour_rgb(175, 175, 175);
color_outline_unfocused = make_colour_rgb(120, 120, 120);

// > Logic
window_focus = true;
text_box_focus = false;

// > Layout
default_x = 64;
default_y = 64;
default_w = 640;
default_h = 480;

window = {
    x: default_x,
    y: default_y,
    w: default_w,
    h: default_h,
    
    min_w: 320,
    min_h: 240,
};
log_rect =  { 
    pl: 4,          // > Padding
    pt: 28,
    pr: 4,
    pb: 32
}
text_rect = {
    h: 24,
    
    pl: 4,          // > Padding
    pt: 4,
    pr: 4,
    pb: 4
}

resize = false;
resize_h = false;
resize_v = false;
show_resize = false;
show_resize_h = false;
show_resize_v = false;

resize_rect = 4;

move = false;
move_anchor_x = 0;
move_anchor_y = 0;
move_rect = {
    px: 0,
    py: 0,
    pw: 27,
    ph: 27
}

on_close_rect = false;
close_rect = {
    px: 27,
    py: 2,
    pw: 4,
    ph: 25
}

text_cursor_visible = true;

// > Message
message = "";
message_size = 128;
message_id = 0;
cursor_position = 0;

message_log = [];
message_log_size = 1024;
message_log_detail_level = 0;

message_history = [];
message_history_current = -1;
message_history_size = 1024;

// > AutoCompletion
auto_complete_matching_commands = [];
auto_complete_selected_command = 0;

auto_complete_top = 0;
auto_complete_max_suggestions = 5;

// Commands
commands = {
    "con_clear": {
        param_count: 0,
        param_types: [],
        
        on_execute: function(_con, _params) 
        {
            ConLogClear(_con);
        }
    },
    "con_clear_mh": {
        param_count: 0,
        param_types: [],
        
        on_execute: function(_con, _params) 
        {
            ConMessageHistoryClear(_con);
        }
    },
    "command_list": {
        param_count: 0,
        param_types: [],
        
        on_execute: function(_con, _params) 
        {
            ConLog(_con, "");
            var _commands = struct_get_names(_con.commands);
            array_sort(_commands, true);
            for (var i = 0; i < array_length(_commands); ++i)
            {
                ConLog(_con, _commands[i]);
            }
        }
    },
    "con_ac_max_suggestions": {
        param_count: 1,
        param_types: ["real"],
        
        on_execute: function(_con, _params) 
        {
            if (!ConIsParamArrayValid(_con, _params, self.param_count)) return;
                
            _con.auto_complete_max_suggestions = real(_params[0]);
        }
    },
    "con_kill": {
        param_count: 0,
        param_types: [],
        
        on_execute: function(_con, _params) 
        {
            instance_destroy(_con);
        }
    },
    "con_message_detail_level": {
        param_count: 1,
        param_types: ["real"],
        
        on_execute: function(_con, _params) 
        {
            if (!ConIsParamArrayValid(_con, _params, self.param_count)) return;
                
            _con.message_log_detail_level = real(_params[0]);
        }
    },
    "con_reset": {
        param_count: 0,
        param_types: [],
        
        on_execute: function(_con, _params) 
        {
            ConReset(_con);
        }
    },
    "con_reset_pos": {
        param_count: 0,
        param_types: [],
        
        on_execute: function(_con, _params) 
        {
            ConWindowResetPosition(_con, true);
        }
    },
    "con_reset_size": {
        param_count: 0,
        param_types: [],
        
        on_execute: function(_con, _params) 
        {
            ConWindowResetSize(_con, true);
        }
    },
    "con_set_pos": {
        param_count: 2,
        param_types: ["real", "real"],
        
        on_execute: function(_con, _params) 
        {
            if (!ConIsParamArrayValid(_con, _params, self.param_count)) return;
                 
            ConWindowSetPosition(_con, real(_params[0]), real(_params[1]), true);
        }
    },
    "con_set_size": {
        param_count: 2,
        param_types: ["real", "real"],
        
        on_execute: function(_con, _params) 
        {
            if (!ConIsParamArrayValid(_con, _params, self.param_count)) return;
                 
            ConWindowSetSize(_con, real(_params[0]), real(_params[1]), true);
        }
    },
    "con_echo": {
        param_count: 1,
        param_types: ["string"],
        
        on_execute: function(_con, _params) 
        {
            if (!ConIsParamArrayValid(_con, _params, self.param_count)) return;
                
            ConLog(_con, string(_params[0]));
        }
    },
    "con_echo_error": {
        param_count: 1,
        param_types: ["string"],
        
        on_execute: function(_con, _params) 
        {
            if (!ConIsParamArrayValid(_con, _params, self.param_count)) return;
                
            ConLogError(_con, string(_params[0]));
        }
    },
    "game_end": {
        param_count: 0,
        param_types: [],
        
        on_execute: function(_con, _params) 
        {
            game_end();
        }
    },
    "mouse_set_window_pos": {
        param_count: 2,
        param_types: ["real", "real"],
        
        on_execute: function(_con, _params) 
        {
            if (!ConIsParamArrayValid(_con, _params, self.param_count)) return;
                 
            window_mouse_set(real(_params[0]), real(_params[1]));
            ConLog(_con, string("Mouse window position set to ({0}, {1})", real(_params[0]), real(_params[1])));
        }
    },
}
input = ConInputGetKeys();

ConReset(self);