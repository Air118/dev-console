if (!active) return;

// > Save previous drawing settings
var _prev_alpha = draw_get_alpha();
var _prev_color = draw_get_color();
var _prev_font = draw_get_font();
var _prev_halign = draw_get_halign();
var _prev_valign = draw_get_valign(); 

draw_set_font(font);

// > Draw window
ConDrawWindow();

// > Draw log surface
ConDrawLogSurface();

// > Draw message surface
ConDrawMessageSurface();

// > Draw resize indicators and the close button
ConDrawOther();

// > Draw autocomplete suggestions
ConDrawAutoCompleteSuggestions();

// > Reset to the previous draw settings
draw_set_alpha(_prev_alpha);
draw_set_color(_prev_color);
draw_set_font(_prev_font);
draw_set_halign(_prev_halign);
draw_set_valign(_prev_valign); 