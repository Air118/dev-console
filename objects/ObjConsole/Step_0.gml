input = ConInputGetKeys();

if (active && input.deactivate) ConDeactivate();
else if (!active && input.activate) ConActivate();

if (!active) 
{
    keyboard_lastchar = "";   
    return;
}

ConInputWindow();
if (window_focus) 
{
    text_box.Update();
    if (input.enter && text_box.GetTextLength() > 0) ConExecuteMessage(text_box.text);
        
    ConInputMessageHistory();
    ConInputAutoComplete();
    ConInputUtility();
}

auto_complete_matching_commands = ConAutoCompletionGetMatchingCommands(text_box.text);
if (array_length(auto_complete_matching_commands) < 2) auto_complete_selected_command = 0;
ConAutoCompleteMoveTop();

ConWindowTransform();
