enum ConLogErrorSeverity
{
    NONE,
    WARNING,
    ERROR,
};
global.con_instance = noone;

#region Console instance

/// @desc Creates and returns a new console instance. If another console instance already exists, it'll be destroyed.
/// @return {ObjConsole} New console instance
function ConCreateInstance()
{
    ConDestroy();
    
    global.con_instance = instance_create_depth(0, 0, -10000, ObjConsole);
    ConReset();
}
/// @desc Destroys a console. If no instance is supplied, it will destroy all existing instances
/// @param {bool} all_instances Destroy all instances or just the one stored in the global variable.
function ConDestroy(all_instances = false)
{
    if (all_instances) 
    {
        instance_destroy(ObjConsole);
        return;
    }
    else 
    {
        if (ConIsValidConsole())
        {
            instance_destroy(global.con_instance);
        }	
    }
}
/// @desc Resets the console to the default state.
function ConReset()
{
    if (!ConIsValidConsole()) return;
        
    ConWindowResetPosition();
    ConWindowResetSize();
    
    ConLogClear();
    ConMessageClear();
    ConMessageHistoryClear();

    global.con_instance.message_id = 0;

    ConLog("Developer console", c_lime);
    ConLog("Version: " + global.con_instance.__version, c_lime);
    ConLog("", c_lime);
    ConLog("Use \"con_command_list\" to get a list of all available commands.", c_lime);  
    ConLog("Use \"con_help <command_name>\" to get information about a specific command.", c_lime);  
    
    global.con_instance.alarm[0] = 1;  
}

/// @desc Checks if the instance is a valid console instance.
/// @return {bool}
function ConIsValidConsole()
{
    if (!instance_exists(global.con_instance)) return false;
    if (global.con_instance.object_index != ObjConsole) return false;
        
    return true;    
}

/// @desc Activates the console instance
function ConActivate()
{
    if (!ConIsValidConsole()) return;
        
    global.con_instance.active = true;
}
/// @desc Deactivates the console instance
function ConDeactivate()
{
    if (!ConIsValidConsole()) return;
        
    global.con_instance.active = false;
}

#endregion
#region Window transformation

/// @desc Sets the console window position relative to the room coordinates.
/// @param {Id.Instance}  Console instance
/// @param {real} x New X position
/// @param {real} y New Y position
/// @param {bool} log Log the position change in the console
function ConWindowSetPosition(x, y, log = false)
{
    if (!ConIsValidConsole()) return;
        
    var _x = string_digits(x);
    var _y = string_digits(y);
    
    if (string_length(_x + _y) == 0) 
    {
        ConLogError(string("Invalid argument/s: (x: {0}, y: {1})", x, y));
        return;    
    };
    
    global.con_instance.window.x = real(_x); 
    global.con_instance.window.y = real(_y); 
    
    if (log) ConLog(string("Console position set to ({0}, {1})", x, y), c_aqua);
}
/// @desc Sets the console window size relative to the room coordinates.
/// @param {Id.Instance}  Console instance
/// @param {real} w New width
/// @param {real} h New height
/// @param {bool} log Log the position change in the console
function ConWindowSetSize(w, h, log = false)
{
    if (!ConIsValidConsole()) return;
    
    var _w = string_digits(w);
    var _h = string_digits(h);
    
    if (string_length(_w + _h) == 0) 
    {
        ConLogError(, string("Invalid argument/s: (w: {0}, h: {1})", w, h));
        return;    
    };
    
    global.con_instance.window.w = max(global.con_instance.window.min_w, real(_w)); 
    global.con_instance.window.h = max(global.con_instance.window.min_h, real(_h)); 
    
    if (log) ConLog(string("Console size set to ({0}, {1})", w, h), c_aqua);
}

/// @desc Resets the console's position to the default one (default_x, default_y).
/// @param {Id.Instance}  Console instance
/// @param {bool} log Log the position change in the console
function ConWindowResetPosition(log = false)
{
    if (!ConIsValidConsole()) return;
        
    global.con_instance.window.x = global.con_instance.default_x;
    global.con_instance.window.y = global.con_instance.default_y;
    
    if (log) ConLog(string("Console position reset to ({0}, {1})", global.con_instance.default_x, global.con_instance.default_y), c_aqua);
}
/// @desc Resets the console's size to the default one (default_w, default_h).
/// @param {Id.Instance}  Console instance
/// @param {bool} log Log the position change in the console
function ConWindowResetSize(log = false)
{
    if (!ConIsValidConsole()) return;
        
    global.con_instance.window.w = global.con_instance.default_w;
    global.con_instance.window.h = global.con_instance.default_h;
    
    if (log) ConLog(string("Console size reset to ({0}, {1})", global.con_instance.default_w, global.con_instance.default_h), c_aqua);
}
/// @desc Handle manual resizing and moving of the window.
function ConWindowTransform()
{
    if (move) ConWindowSetPosition(mouse_x - move_anchor_x, mouse_y - move_anchor_y);
        
    if (resize) ConWindowSetSize(mouse_x - window.x, mouse_y - window.y);
    if (resize_h) ConWindowSetSize(mouse_x - window.x, window.h);    
    if (resize_v) ConWindowSetSize(window.w, mouse_y - window.y);   
        
    window.w = max(window.min_w, window.w);
    window.h = max(window.min_h, window.h); 
}

#endregion
#region Log

/// @desc Logs a message to display in the console log.
/// @param {string} message Message string to log
/// @param {Constant.Color} color The color of the message
function ConLog(message, color = c_white)
{
    if (!ConIsValidConsole()) return;
        
    while (array_length(global.con_instance.message_log) >= global.con_instance.message_log_size)
    {
        array_delete(global.con_instance.message_log, 0, 1);
    }
    
    array_push(global.con_instance.message_log, {
        id: global.con_instance.message_id,
        time: string("{0}{1}:{2}{3}:{4}{5}", current_hour < 10 ? "0" : "", current_hour, current_minute < 10 ? "0" : "", current_minute, current_second < 10 ? "0" : "", current_second),
        text: message,
        color: color,
    });
    
    global.con_instance.message_id++;
}
/// @desc Logs an error message to display the console log. Error messages have [ERROR] prefix and are red.
/// @param {string} error_message Error string to log
/// @param {int} severity Severity of the message. Look up 'ConLogErrorSeverity'.
function ConLogError(error_message, severity = ConLogErrorSeverity.ERROR)
{
    if (!ConIsValidConsole()) return;
        
    var _message = "";
    var _color = c_white;
    
    switch (severity) 
    {
    	case ConLogErrorSeverity.WARNING:
            _message = "[WARNING] ";
            _color = c_yellow;
            break;
        case ConLogErrorSeverity.ERROR:
            _message = "[ERROR] "
            _color = c_red;
            break;
    }
    
    _message += string(error_message);
    
    ConLog(_message, _color);
}
/// @desc Clears the console's log clean. Irreversible.
function ConLogClear()
{
    if (!ConIsValidConsole()) return;
        
    global.con_instance.message_log = [];
}
/// @desc Set log messages detail level. Levels range from 0 to 2. Depending on the level, the time of the message or the message id will be drawn.
/// @param {real} detail Detail level
function ConLogSetDetail(detail)
{
    if (!ConIsValidConsole()) return;
    if (!is_numeric(detail)) 
    {
        ConLogError(string("Invalid parameter type. Expected 'int'. [detail: {0}({1})]", detail, typeof(detail)));
        return;
    }    
    
    detail = clamp(detail, 0, 2);
    detail = floor(detail);
    
    global.con_instance.message_log_detail_level = detail;
}

#endregion
#region Message

/// @desc Clears message history. Pressing up or down arrow will iterate over previously entered messages in that history.
/// @param {Id.Instance}  Console instance
/// @param {string} message New message
function ConMessageSetMessage(message)
{
    if (!ConIsValidConsole()) return;
    
    global.con_instance.text_box.TextSet(message);
}
/// @desc Clears current message.
/// @param {Id.Instance}  Console instance
function ConMessageClear()
{
    if (!ConIsValidConsole()) return;
        
    global.con_instance.text_box.TextClear();
}
/// @desc Parses the message into an array of strings.
/// @param {string} message Message to parse
function ConParseMessage(message)
{ 
    var _parsed_array = string_split(message, " "); 
    _parsed_array[0] = string_lower(_parsed_array[0]);
    
    return _parsed_array;
}

#endregion
#region Message history

/// @desc Adds a message to the message history. Pressing up or down arrow will iterate over previously entered messages in that history.
/// @param {Id.Instance}  Console instance
/// @param {string} message Message to add
function ConMessageHistoryAdd(message)
{
    if (!ConIsValidConsole()) return;
        
    array_push(global.con_instance.message_history, message);
    global.con_instance.message_history_current = -1;
}
/// @desc Clears message history. Pressing up or down arrow will iterate over previously entered messages in that history.
/// @param {Id.Instance}  Console instance
function ConMessageHistoryClear()
{
    if (!ConIsValidConsole()) return;
    
    global.con_instance.message_history = [];
    global.con_instance.message_history_current = -1;
}

#endregion
#region Autocompletion

/// @desc Returns an array populated with commands starting with the input string.
/// @param {string} message Input string
function ConAutoCompletionGetMatchingCommands(msg)
{
    if (string_length(msg) < 1 || string_starts_with(msg, " ")) return [];
    
    // > Temporary fix. This is here because if the autocomplete suggestions are shown and you destroy the console instance,
    // > the game will crash because it cannot find an instance of the ObjConsole object.
    if (!ConIsValidConsole()) return []; 
    
    var _commands = struct_get_names(global.con_commands);
    var _valid_commands = [];
    
    for (var i = 0; i < array_length(_commands); ++i)
    {
        if (string_starts_with(_commands[i], msg)) array_push(_valid_commands, _commands[i]);
    }
    
    array_sort(_valid_commands, true); // > Sort alphabetically
    return _valid_commands;
}
/// @desc 
function ConAutoCompleteSetMessage(msg)
{
    ConMessageSetMessage(msg);
    auto_complete_selected_command = 0;
}

function ConAutoCompleteMoveTop()
{
    if (auto_complete_selected_command < auto_complete_top)
    {
        if (auto_complete_selected_command > -1) auto_complete_top--;
    }
    if (auto_complete_selected_command > auto_complete_top + auto_complete_max_suggestions - 1)
    {
        if (auto_complete_selected_command < array_length(auto_complete_matching_commands)) auto_complete_top++;
    }
    
    auto_complete_top = clamp(auto_complete_top, 0, max(array_length(auto_complete_matching_commands) - auto_complete_max_suggestions, 0));
}

#endregion
#region Cursor

/// @desc Moves the cursor to the left by a specified amount. Does not wrap around.
/// @param {Id.Instance}  Console instance
/// @param {real} amount Number of spaces to move
function ConCursorMoveLeft(amount)
{
    if (!ConIsValidConsole()) return;
    if (!is_numeric(amount)) return;
        
    if (global.con_instance.cursor_position <= 0) return;
        
    global.con_instance.cursor_position -= min(global.con_instance.cursor_position, amount);
}
/// @desc Moves the cursor to the right by a specified amount. Does not wrap around.
/// @param {Id.Instance}  Console instance
/// @param {real} amount Number of spaces to move
function ConCursorMoveRight(amount)
{
    if (!ConIsValidConsole()) return;
    if (!is_numeric(amount)) return;
        
    if (global.con_instance.cursor_position >= string_length(global.con_instance.message)) return;
        
    global.con_instance.cursor_position += min(string_length(global.con_instance.message) - global.con_instance.cursor_position, amount);
}

#endregion
#region Commands

/// @desc Checks if a command exists in the "commands" dictionary.
/// @param {Id.Instance}  Console instance
/// @param {string} command Command name
function ConIsValidCommand(command)
{ 
    if (!ConIsValidConsole()) return;
        
    var _commands = struct_get_names(global.con_commands);
    for (var i = 0; i < array_length(_commands); ++i)
    {
        if (command == _commands[i]) return true;
    }
    
    return false;
}
/// @desc Checks if parameter array is of valid length.
/// @param {Id.Instance}  Console instance
/// @param {array} param_array Parameter array
/// @param {real} param_count Amount of parameters required by the command
function ConIsParamArrayValid(param_array, param_count)
{
    if (!ConIsValidConsole()) return;
            
    if (!is_array(param_array))
    {
        ConLogError("\"param_array\" is not an array.");
        return false;
    }
    if (array_length(param_array) != param_count)
    {
        ConLog(string("\"param_array\" has {0} parameters. {1} required.", array_length(param_array), param_count));
        return false;
    }
    
    return true;
}
/// @desc Executes a command directly.
/// @param {Id.Instance}  Console instance
/// @param {string} message Message
function ConExecuteCommand(command)
{
    if (!ConIsValidConsole()) return;
        
    var _parsed_array = ConParseMessage(command);
    if (array_length(_parsed_array) == 0) return;
    
    var _params = [];
    array_copy(_params, 0, _parsed_array, 1, array_length(_parsed_array) - 1);
    
    if (ConIsValidCommand(_parsed_array[0]))
    {
        var _command = global.con_commands[$ _parsed_array[0]];
        if (array_length(_command.arguments) > 0) 
        {
            if (array_length(_params) == _command.arguments_count) 
            {
                _command.callback(_params);
            }
            else 
            {
                ConLog(string("Invalid argument number. Required ({0}), Given ({1}).", _command.arguments_count, array_length(_params)));
            }
        }
        else 
        {
            _command.callback();
        }
    }
    else 
    {
        ConLog(string("Invalid command: \"{0}\"", _parsed_array[0]));
    }
}
/// @desc Executes the input message from the text box.
/// @param {Id.Instance}  Console instance
/// @param {string} message Message
function ConExecuteMessage(message)
{
    if (!ConIsValidConsole()) return;
        
    ConLog(message);
    ConMessageClear();
    
    ConMessageHistoryAdd(message);
    ConExecuteCommand(message);
}

#endregion
#region Input

/// @desc Returns a struct with input data.
/// @return {struct}
function ConInputGetKeys()
{
    var _ctrl = keyboard_check(vk_control);
    var _shift = keyboard_check(vk_shift);
    var _alt = keyboard_check(vk_lalt);
    
    return
    {
        ctrl: _ctrl,
        shift: _shift,
        alt: _alt,
        
        tab: keyboard_check_pressed(vk_tab),
        
        copy: _ctrl && keyboard_check_pressed(ord("C")),
        cut: _ctrl && keyboard_check_pressed(ord("X")),
        paste: _ctrl && keyboard_check_pressed(ord("V")),
        
        enter: keyboard_check_pressed(vk_enter),
        backspace: keyboard_check_pressed(vk_backspace),
        del: keyboard_check_pressed(vk_delete),
        
        cursor_left: keyboard_check_pressed(vk_left),
        cursor_right: keyboard_check_pressed(vk_right),
        cursor_start: keyboard_check_pressed(vk_home),
        cursor_end: keyboard_check_pressed(vk_end),
        
        message_history_next: keyboard_check_pressed(vk_up),
        message_history_prev: keyboard_check_pressed(vk_down),
        
        activate: keyboard_check_pressed(vk_f1),
        deactivate: keyboard_check_pressed(vk_f1),
        
        reset_position: _ctrl && _shift && keyboard_check_pressed(vk_f5),
        reset_size: _ctrl && _shift && keyboard_check_pressed(vk_f6),
        reset: _ctrl && _shift && keyboard_check_pressed(vk_f7),
    }
}
/// @desc Handle window input f.e.: moving, resizing and closing.
function ConInputWindow()
{ 
    // > Resize
    var _mouse_on_resize = point_in_rectangle(
        mouse_x, mouse_y, 
        window.x + window.w - resize_rect,
        window.y + window.h - resize_rect,
        window.x + window.w + resize_rect,
        window.y + window.h + resize_rect
    );
    var _mouse_on_resize_h = point_in_rectangle(
        mouse_x, mouse_y, 
        window.x + window.w - resize_rect,
        window.y,
        window.x + window.w + resize_rect,
        window.y + window.h - resize_rect - 1
    );
    var _mouse_on_resize_v = point_in_rectangle(
        mouse_x, mouse_y, 
        window.x,
        window.y + window.h - resize_rect,
        window.x + window.w - resize_rect - 1,
        window.y + window.h + resize_rect
    );
    
    show_resize = _mouse_on_resize;
    show_resize_h = _mouse_on_resize_h;
    show_resize_v = _mouse_on_resize_v;
    
    if (mouse_check_button_pressed(mb_left))
    {
        if (_mouse_on_resize) resize = true;
        if (_mouse_on_resize_h) resize_h = true;
        if (_mouse_on_resize_v) resize_v = true;
    }
    if (mouse_check_button_released(mb_left))
    {
        if (resize) resize = false;
        if (resize_h) resize_h = false;
        if (resize_v) resize_v = false;
    }
    
    // > Move
    var _mouse_on_move = point_in_rectangle(
        mouse_x, mouse_y, 
        window.x + move_rect.px,
        window.y + move_rect.py,
        window.x + window.w - move_rect.pw,
        window.y + move_rect.ph
    );
    if (mouse_check_button_pressed(mb_left) && _mouse_on_move) {
        move = true;
        move_anchor_x = mouse_x - window.x;
        move_anchor_y = mouse_y - window.y;
    }
    if (move && mouse_check_button_released(mb_left)) move = false;
        
    // > Close
    var _mouse_on_close = point_in_rectangle(
        mouse_x, mouse_y, 
        window.x + window.w - close_rect.px,
        window.y + close_rect.py,
        window.x + window.w - close_rect.pw,
        window.y + close_rect.ph
    );
    on_close_rect = _mouse_on_close;
    if (mouse_check_button_pressed(mb_left) && _mouse_on_close) ConDestroy(); 
        
    // > Window focus
    var _mouse_on_window = point_in_rectangle(
        mouse_x, mouse_y,
        window.x, window.y,
        window.x + window.w,
        window.y + window.h
    );
    if (mouse_check_button_pressed(mb_left))
    {
        if (!show_resize && !show_resize_h && !show_resize_v)
        {
            if (_mouse_on_window) window_focus = true; 
            else window_focus = false; 
        }
    }
}
/// @desc Handle iterating over message history.
function ConInputMessageHistory()
{
    if (array_length(auto_complete_matching_commands) > 0) return;
    
    if (input.message_history_next)
    {
        var _history_size = array_length(message_history);
        if (_history_size < 1) return;
            
        message_history_current++;
               
        if (message_history_current > _history_size - 1) message_history_current = 0;
        
        ConMessageSetMessage(message_history[message_history_current]);   
    }
    if (input.message_history_prev)
    {
        var _history_size = array_length(message_history);
        if (_history_size < 1) return;
            
        message_history_current--;
        
        if (message_history_current < 0) message_history_current = _history_size - 1;
        
        ConMessageSetMessage(message_history[message_history_current]);   
    }
}
/// @desc Handle iterating over auto-complete suggestions.
function ConInputAutoComplete()
{ 
    if (input.message_history_next) // > Up
    {
        auto_complete_selected_command--;
        if (auto_complete_selected_command < 0) auto_complete_selected_command = array_length(auto_complete_matching_commands) - 1;
    }
    if (input.message_history_prev) // > Down
    {
        auto_complete_selected_command++;
        if (auto_complete_selected_command > array_length(auto_complete_matching_commands) - 1) auto_complete_selected_command = 0;
    }
    
    if (input.tab)
    {
        if (array_length(auto_complete_matching_commands) > 0)
        {
            ConAutoCompleteSetMessage(auto_complete_matching_commands[auto_complete_selected_command]);
        }
    }
}
/// @desc Handles all the utility functions and hotkeys such as reseting the console position and size, as well as copy/cut/paste.
function ConInputUtility()
{
    // > Reset
    if (input.reset_position) ConWindowResetPosition(true); 
    if (input.reset_size) ConWindowResetSize(true); 
    if (input.reset) ConReset(); 
        
    // > Copy
    if (input.copy) 
    {
        clipboard_set_text(message);
        // ConLog(, string("Copied \"{0}\" to clipboard", message), c_aqua);
    }
    
    // > Cut
    if (input.cut) 
    {
        clipboard_set_text(message);
        // ConLog(, string("Copied \"{0}\" to clipboard", message), c_aqua);
        ConMessageClear();
    }
    
    // > Paste
    if (input.paste) 
    {
        ConMessageSetMessage(clipboard_get_text());
        // ConLog(, string("Pasted \"{0}\" from clipboard", message), c_aqua);
    }
}

#endregion
#region Drawing

/// @desc Draw the main console window.
function ConDrawWindow()
{
    draw_set_color(color_window);
         
    var _win_x1 = window.x;
    var _win_y1 = window.y;
    var _win_x2 = window.x + window.w;
    var _win_y2 = window.y + window.h;
        
    // > Draw window
    draw_rectangle(
        _win_x1, _win_y1,
        _win_x2, _win_y2,
        false
    );
        
    // > Draw outline
    draw_set_color(window_focus ? color_outline : color_outline_unfocused);
    draw_rectangle(
        _win_x1, _win_y1,
        _win_x2, _win_y2,
        true 
    );
    
    draw_set_color(c_white);
    draw_text(_win_x1 + 4, _win_y1 + 4, __title + " " + __version);
}
/// @desc Draw the log surface and log history.
function ConDrawLogSurface()
{
    draw_set_color(color_log);
    
    var _surf_w = window.w - log_rect.pl - log_rect.pr;
    var _surf_h = window.h - log_rect.pt - log_rect.pb;
    var _surf = surface_create(_surf_w, _surf_h);
    
    if (surface_exists(_surf))
    {
        surface_set_target(_surf);

      	draw_rectangle(
            0, 0,
            _surf_w, _surf_h,
            false
        );
        
        draw_set_color(window_focus ? color_outline : color_outline_unfocused);
        draw_rectangle(
            1, 1,
            _surf_w, _surf_h,
            true
        );
  
        var _data = {};
        var _message = "";
        
        var _log_text_scale = 0.75;

        var _log_vsep = (string_height(__title) + 2) * _log_text_scale;
        var _log_len = array_length(message_log);
        
        for (var i = 0; i < _log_len; ++i)
        {
            _data = message_log[_log_len - i - 1];
            _message = "";
            
            _message += (message_log_detail_level > 1) ? string("[{0}] ", _data.id) : "";
            _message += (message_log_detail_level > 0) ? string("{0} ", _data.time) : "";
            _message += "> ";
            _message += string(_data.text);
            
            draw_set_valign(fa_bottom);
            draw_text_transformed_color(
                2, _surf_h - 2 - (_log_vsep * i) - 1,
                _message,
                _log_text_scale, _log_text_scale, 0,
                _data.color, _data.color, _data.color, _data.color, 1
            );
            draw_set_valign(fa_top);
        }
        
        surface_reset_target();
        draw_surface(_surf, window.x + log_rect.pl, window.y + log_rect.pt);
        surface_free(_surf);
    }
}
/// @desc Draw the message surface and the message.
function ConDrawMessageSurface()
{
    draw_set_color(color_log);
    
    var _surf_w = window.w - log_rect.pl - log_rect.pr;
    var _surf_h = text_rect.h;
    var _surf = surface_create(_surf_w, _surf_h);
    
    if (surface_exists(_surf))
    {
        surface_set_target(_surf);
        
        draw_rectangle(
             0, 0,
            _surf_w, _surf_h,
            false
        );
            
        draw_set_color(window_focus ? color_outline : color_outline_unfocused);
        draw_rectangle(
            1, 1,
            _surf_w, _surf_h,
            true
        );
        
        draw_set_alpha(text_cursor_visible ? 1 : 0);
        
        var _cursor_x = string_length(text_box.text) > 0 ? (text_box.cursor_position / string_length(text_box.text)) * string_width(text_box.text) : 0;
        draw_line(
            4 + _cursor_x, 2,
            4 + _cursor_x, 22    
        );
        
        draw_set_alpha(1);
        draw_set_color(c_white);
        
        draw_text(3, 3, text_box.text);
        
        surface_reset_target();
        draw_surface(_surf, window.x + text_rect.pl, window.y + window.h - text_rect.pb - text_rect.h);
        surface_free(_surf);
    }
}
/// @desc Draw resize indicators and the close button.
function ConDrawOther()
{
    // Resize
    var _win_x2 = window.x + window.w;
    var _win_y2 = window.y + window.h;
    
    if (show_resize || resize)
    {
        draw_set_color(resize ? color_window : color_outline);
        
        draw_line(
            _win_x2 - 6, _win_y2 + 4,
            _win_x2 + 4, _win_y2 + 4
        );
        draw_line(
            _win_x2 + 4, _win_y2 + 4,
            _win_x2 + 4, _win_y2 - 6
        );
    }
    if (show_resize_h || resize_h)
    {
        draw_set_color(resize_h ? color_window : color_outline);
        
        draw_line(
            _win_x2 + 4, window.y - 1,
            _win_x2 + 4, _win_y2
        );
    }
    if (show_resize_v || resize_v)
    {
        draw_set_color(resize_v ? color_window : color_outline);
        
        draw_line(
            window.x - 1, _win_y2 + 4,
            _win_x2, _win_y2 + 4
        );
    }
    
    // Close button (X)
    draw_set_color(on_close_rect ? c_maroon : c_red);
    
    var _close_btn_x = _win_x2 - 27;
    var _close_btn_y = window.y + 2;
    var _close_btn_w = _close_btn_x + 23;
    var _close_btn_h = _close_btn_y + 23;
    
    draw_rectangle(
        _close_btn_x, _close_btn_y, _close_btn_w, _close_btn_h, false    
    );
    
    draw_set_color(color_outline);
    draw_rectangle(
        _close_btn_x, _close_btn_y, _close_btn_w, _close_btn_h, true    
    );
    
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _close_x_x = _close_btn_x + ((_close_btn_w - _close_btn_x) / 2);
    var _close_x_y = _close_btn_y + ((_close_btn_h - _close_btn_y) / 2);
    
    draw_text(
        _close_x_x - 1, _close_x_y - 1, "X"
    );
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
/// @desc Draws auto complete suggestions below the message box.
function ConDrawAutoCompleteSuggestions()
{
    if (array_length(auto_complete_matching_commands) < 1 || auto_complete_matching_commands[auto_complete_selected_command] == text_box.text) return;
    
    var _suggestion_rect = {
        x: window.x + text_rect.pl + 1,
        y: window.y + window.h - text_rect.pb,
        w: 311,
        h: 24,
    }
    var _scrollbar_rect = {
        x: _suggestion_rect.x + _suggestion_rect.w,
        y: _suggestion_rect.y,
        w: -4,
        h: _suggestion_rect.h,
    }
    var _suggestion_count = min(auto_complete_max_suggestions, array_length(auto_complete_matching_commands))
    
    // > Line at the top of suggestions
    draw_set_color(color_outline);
    draw_line(
        _suggestion_rect.x,
        _suggestion_rect.y,
        _suggestion_rect.x + _suggestion_rect.w,
        _suggestion_rect.y
    );
    
    for (var i = 0; i < _suggestion_count; ++i)
    {
        // > Background rectangle
        draw_set_color((auto_complete_selected_command == i + auto_complete_top) ? color_outline_unfocused : color_log);
        draw_rectangle(
            _suggestion_rect.x, 
            _suggestion_rect.y + (i * _suggestion_rect.h),
            _suggestion_rect.x + _suggestion_rect.w,
            _suggestion_rect.y + _suggestion_rect.h + (i * _suggestion_rect.h),
            false
        );
        
        // > Separator
        draw_set_color(color_outline);
        draw_line(
            _suggestion_rect.x,
            _suggestion_rect.y + ((i + 1) * _suggestion_rect.h),
            _suggestion_rect.x + _suggestion_rect.w,
            _suggestion_rect.y + ((i + 1) * _suggestion_rect.h)
        );
        
        // > Text
        draw_set_color(c_white);
        draw_set_valign(fa_middle);
        draw_text(
            _suggestion_rect.x + 4, _suggestion_rect.y + (_suggestion_rect.h / 2) + (i * _suggestion_rect.h),
            auto_complete_matching_commands[auto_complete_top + i]
        );
        
        draw_set_valign(fa_top);
    }
    
    draw_set_color(color_outline);
    
    // > Draw side bars
    draw_line(
        _suggestion_rect.x,
        _suggestion_rect.y,
        _suggestion_rect.x,
        _suggestion_rect.y + (_suggestion_count * _suggestion_rect.h)  
    );
    draw_line(
        _suggestion_rect.x + _suggestion_rect.w,
        _suggestion_rect.y,
        _suggestion_rect.x + _suggestion_rect.w,
        _suggestion_rect.y + (_suggestion_count * _suggestion_rect.h)  
    );
    
    // > Draw scrollbar background
    draw_set_color(color_log);
    draw_rectangle(
        _scrollbar_rect.x, _scrollbar_rect.y,
        _scrollbar_rect.x + _scrollbar_rect.w,
        _scrollbar_rect.y + (_suggestion_rect.h * _suggestion_count),
        false 
    );
    
    // > Draw scrollbar
    var _scrollbar_height = (_suggestion_count * _scrollbar_rect.h) / array_length(auto_complete_matching_commands);
    
    draw_set_color(color_outline);
    draw_rectangle(
        _scrollbar_rect.x, _scrollbar_rect.y + (auto_complete_selected_command * _scrollbar_height),
        _scrollbar_rect.x + _scrollbar_rect.w,
        _scrollbar_rect.y + _scrollbar_height + (auto_complete_selected_command * _scrollbar_height),
        false 
    );
    
    // > Draw outline
    draw_set_color(color_outline);
    draw_rectangle(
        _scrollbar_rect.x, _scrollbar_rect.y,
        _scrollbar_rect.x + _scrollbar_rect.w,
        _scrollbar_rect.y + (_suggestion_rect.h * _suggestion_count),
        true
    );
}

#endregion
#region Helpers

function ConMouseAction(x, y, w, h, button, callback, hold = false)
{
    if (!ConIsValidConsole()) return;
        
    var _mouse_in_rect = point_in_rectangle(
        mouse_x, mouse_y,
        x, y, x + w, y + h
    );
    var _mouse = hold ? mouse_check_button(button) : mouse_check_button_pressed(button);
    
    if (_mouse_in_rect)
    {   
        //if (is_callable(hover_callback)) hover_callback();
        if (_mouse && is_callable(callback)) callback(); 
    } 
}

#endregion
#region Command list

// > Empty commands struct
global.con_commands = {}

/// @desc Register a command.
function ConRegisterCommand(name, help, usage, callback, arguments = [])
{
    if (!is_string(name) || !is_string(help) || !is_string(usage)) return;
    if (!is_callable(callback)) return;
    if (!is_array(arguments)) return;    
        
    var _command = {
        name: name,
        help: help,
        usage: usage,
        callback: callback,
        arguments: arguments,
        arguments_count: array_length(arguments)
    };
    
    if (!struct_exists(global.con_commands, _command)) struct_set(global.con_commands, name, _command);
}

ConRegisterCommand(
    "con_clear", 
    "Clears the message log.", 
    "con_clear", 
    function() { ConLogClear() }
);
ConRegisterCommand(
    "con_clear_mh", 
    "Clears the message history.", 
    "con_clear_mh", 
    function() { ConMessageHistoryClear() }
);
ConRegisterCommand(
    "con_position_reset", 
    "Resets window position to the default position.", 
    "con_position_reset", 
    function() { ConWindowResetPosition(true) }
);
ConRegisterCommand(
    "con_size_reset", 
    "Resets window size to the default size.", 
    "con_size_reset", 
    function() { ConWindowResetSize(true) }
);

ConRegisterCommand(
    "con_position_set", 
    "Set window position to desired x and y.", 
    "con_position_set <x> <y>", 
    function(arg) { ConWindowSetPosition(arg[0], arg[1], true) },
    ["real", "real"]
);
ConRegisterCommand(
    "con_size_set", 
    "Set window size to desized w and h.", 
    "con_size_set <x> <y>", 
    function(arg) { ConWindowSetSize(arg[0], arg[1], true) },
    ["real", "real"]
);

ConRegisterCommand(
    "con_help",
    "Shows the description and usage of a command.",
    "con_help <command_name>",
    function(arg) 
    { 
        if (!ConIsValidCommand(arg[0])) { ConLog(string("Invalid command: \"{0}\"", arg[0])); return; }
        ConLog("Description: " + global.con_commands[$ arg[0]].help, c_ltgray); ConLog("Usage: " + global.con_commands[$ arg[0]].usage, c_ltgray); 
    },
    ["string"]
);
ConRegisterCommand(
    "con_command_list",
    "Shows all the available commands.",
    "con_command_list",
    function() 
    {
        var _commands = struct_get_names(global.con_commands);
        array_sort(_commands, true);
        for (var i = 0; i < struct_names_count(global.con_commands); ++i) 
        { 
            ConLog(_commands[i], c_ltgray) 
        } 
    },
    []
);
ConRegisterCommand(
    "con_kill",
    "Destroys current console instance.",
    "con_kill",
    function() { ConDestroy(); }  
);

#endregion 
#region Textbox

// > TODO: Limit text length to the 'max_length'
// > TODO: Copy, cut, paste features
// > TODO: Rewrite removing characters
// > TODO: Add selection
// > TODO: Add a delay between first input and a hold input.
 
function ConTextBoxCreate()
{
    return 
    {
        text: "",
        cursor_position: 0,
         
        max_length: 64,
        
        is_focused: true,
        
        Update: function()
        {
            if (!self.is_focused) return;
            
            self.InputCharacters();
            self.InputBackspace();
            self.InputDelete();
            
            self.CursorUpdate();
        }, 
        InputCharacters: function()
        {
            if (string_length(keyboard_lastchar) > 0)
            {
                if (ord(keyboard_lastchar) >= 32 && ord(keyboard_lastchar) <= 126)
                {
                    self.text = string_insert(keyboard_lastchar, self.text, self.cursor_position + 1);
                    ++self.cursor_position;
                }
                keyboard_lastchar = "";
            }
        },
        RemoveCharacters: function(direction, amount)
        {
            if (!is_numeric(direction)) return; 
            if (!is_numeric(amount)) return; 
            if (direction == 0 || amount == 0) return;
            
            // > -1 - backspace : 1 - delete
            if (direction > 0) direction = 1;
            else if (direction < 0) direction = -1;
                
            amount = round(amount);
            
            var _msg = self.text;
            if (string_length(_msg) == 0) return;
                
            if (direction == -1) 
            {
                if (self.cursor_position == 0) return;
                
                var _amt = min(amount, string_length(_msg));
                _msg = string_delete(_msg, self.cursor_position, -_amt);
                self.cursor_position -= _amt;
            }
            if (direction == 1) 
            {
                _msg = string_delete(_msg, self.cursor_position + 1, min(amount, string_length(_msg)));
            }
            
            self.text = _msg;
        },
        CursorUpdate: function()
        {
            var _left = keyboard_check_pressed(vk_left);
            var _right = keyboard_check_pressed(vk_right);
            
            var _ctrl = keyboard_check(vk_control);
            var _shift = keyboard_check(vk_shift);

            var _home = keyboard_check(vk_home);
            var _end = keyboard_check(vk_end);
            
            if (_left)
            {
                if (_ctrl) 
                {
                    var _next_space = string_last_pos_ext(" ", self.text, self.cursor_position);
                    self.cursor_position -= self.cursor_position - _next_space;
                }
                if (self.cursor_position > 0) self.cursor_position--;
            }
            if (_right)
            {
                if (_ctrl) 
                {
                    var _next_space = string_pos_ext(" ", self.text, self.cursor_position + 1);
                    if (_next_space == 0) self.cursor_position = self.GetTextLength();
                    else self.cursor_position += _next_space - self.cursor_position - 1;
                }
                
                if (self.cursor_position < self.GetTextLength()) self.cursor_position++;
            }
            
            if (_home) self.cursor_position = 0;
            if (_end) self.cursor_position = self.GetTextLength();
        },
        
        InputBackspace: function()
        {
            if (self.GetTextLength() == 0) return;
            
            var _backspace = keyboard_check_pressed(vk_backspace);
            if (!_backspace) return;
                
            var _ctrl = keyboard_check(vk_control);
            var _shift = keyboard_check(vk_shift);
            
            if (_ctrl) self.RemoveCharacters(-1, self.cursor_position - string_last_pos_ext(" ", self.text, self.cursor_position) + 1);
            else if (_shift) self.TextClear();
            else self.RemoveCharacters(-1, 1);
        },
        InputDelete: function()
        {
            if (self.GetTextLength() == 0) return;
            if (self.cursor_position == self.GetTextLength()) return;
            
            var _delete = keyboard_check_pressed(vk_delete);
            if (!_delete) return;
                
            var _ctrl = keyboard_check(vk_control);
            var _shift = keyboard_check(vk_shift);
            
            if (_ctrl) self.RemoveCharacters(1, abs(self.cursor_position - string_pos_ext(" ", self.text, self.cursor_position + 1)));
            else if (_shift) { clipboard_set_text(self.text); self.TextClear() };
            else self.RemoveCharacters(1, 1);
        },
        
        GetTextLength: function()
        {
            return string_length(self.text);
        },
        GetTextCursorLength: function()
        {
            return string_length(string_copy(text, 1, cursor_position));
        },
    
        TextClear: function()
        {
            self.text = "";
            self.cursor_position = 0;  
        },
        TextSet: function(new_text)
        {
            if (!is_string(new_text)) return;
            
            self.text = new_text;   
            self.cursor_position = self.GetTextLength();
        },
    }
}

#endregion