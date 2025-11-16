if (!window_focus)
{
    text_cursor_visible = true;
    alarm_set(0, 30);
}
else {
    text_cursor_visible = !text_cursor_visible;
    alarm_set(0, 30);
}