input = ConInputGetKeys();

if (active && input.deactivate) ConDeactivate(self);
else if (!active && input.activate) ConActivate(self);

if (!active) 
{
    keyboard_lastchar = "";   
    return;
}

ConInputWindow();
if (window_focus) 
{
    ConInputMessage();
    ConInputMessageRemove();
    ConInputMessageHistory();
    ConInputAutoComplete();
    ConInputCursor();
    ConInputUtility();
}

auto_complete_matching_commands = ConAutoCompletionGetMatchingCommands(message);
if (array_length(auto_complete_matching_commands) < 2) auto_complete_selected_command = 0;
ConAutoCompleteMoveTop();

ConWindowTransform();
