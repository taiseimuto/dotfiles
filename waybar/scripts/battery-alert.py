#!/usr/bin/python3
"""Transparent layer-shell warning over the bar; click anywhere to dismiss."""
import ctypes as C
import fcntl
import json
import os
from pathlib import Path
import sys
import time

THRESHOLDS = (20, 10, 5)
DURATION = 30
BAR_HEIGHT = 38


def advance(capacity, charging, seen):
    """Return the notification threshold and remembered levels for this discharge."""
    if charging or capacity > 20:
        return None, set()
    crossed = {level for level in THRESHOLDS if capacity <= level}
    fresh = crossed - seen
    return min(fresh) if fresh else None, seen | crossed


def main():
    runtime = Path(os.environ.get('XDG_RUNTIME_DIR', f'/run/user/{os.getuid()}'))
    lock = (runtime / 'waybar-battery-alert.lock').open('w')
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return
    state = runtime / 'waybar-battery-alert.json'
    try:
        seen = set(json.loads(state.read_text()))
    except (OSError, ValueError, TypeError):
        seen = set()

    def bind(lib, name, result, *args):
        fn = getattr(lib, name)
        fn.restype, fn.argtypes = result, list(args)
        return fn

    gtk = C.CDLL('libgtk-3.so.0')
    gdk = C.CDLL('libgdk-3.so.0')
    layer = C.CDLL('libgtk-layer-shell.so.0')
    obj = C.CDLL('libgobject-2.0.so.0')
    glib = C.CDLL('libglib-2.0.so.0')
    P, I, S = C.c_void_p, C.c_int, C.c_char_p
    bind(gtk, 'gtk_init', None, P, P)(None, None)
    new = bind(gtk, 'gtk_window_new', P, I)
    screen_of = bind(gtk, 'gtk_widget_get_screen', P, P)
    visual_of = bind(gdk, 'gdk_screen_get_rgba_visual', P, P)
    set_visual = bind(gtk, 'gtk_widget_set_visual', None, P, P)
    set_name = bind(gtk, 'gtk_widget_set_name', None, P, S)
    size = bind(gtk, 'gtk_widget_set_size_request', None, P, I, I)
    events = bind(gtk, 'gtk_widget_add_events', None, P, I)
    show = bind(gtk, 'gtk_widget_show_all', None, P)
    hide = bind(gtk, 'gtk_widget_hide', None, P)
    init_layer = bind(layer, 'gtk_layer_init_for_window', None, P)
    set_layer = bind(layer, 'gtk_layer_set_layer', None, P, I)
    anchor = bind(layer, 'gtk_layer_set_anchor', None, P, I, I)
    monitor_set = bind(layer, 'gtk_layer_set_monitor', None, P, P)
    exclusive = bind(layer, 'gtk_layer_set_exclusive_zone', None, P, I)
    keyboard = bind(layer, 'gtk_layer_set_keyboard_mode', None, P, I)
    namespace = bind(layer, 'gtk_layer_set_namespace', None, P, S)
    display = bind(gdk, 'gdk_display_get_default', P)()
    count = bind(gdk, 'gdk_display_get_n_monitors', I, P)
    monitor = bind(gdk, 'gdk_display_get_monitor', P, P, I)
    provider = bind(gtk, 'gtk_css_provider_new', P)()
    load_css = bind(gtk, 'gtk_css_provider_load_from_data', I, P, S, C.c_ssize_t, P)
    add_css = bind(gtk, 'gtk_style_context_add_provider_for_screen', None, P, P, C.c_uint)
    windows = []
    for index in range(count(display)):
        win = new(0)
        set_visual(win, visual_of(screen_of(win)))
        set_name(win, b'battery-alert')
        init_layer(win)
        namespace(win, b'waybar-battery-alert')
        monitor_set(win, monitor(display, index))
        set_layer(win, 3)  # overlay, above Waybar's top layer
        for edge in (0, 1, 2):  # left, right, top
            anchor(win, edge, 1)
        exclusive(win, -1)  # overlap the bar; reserve no desktop space
        keyboard(win, 0)
        size(win, -1, BAR_HEIGHT)
        events(win, 1 << 8)  # button press
        add_css(screen_of(win), provider, 800)
        windows.append(win)

    deadline = 0.0
    lit = False

    def stop():
        nonlocal deadline
        deadline = 0.0
        for win in windows:
            hide(win)

    CLICK = C.CFUNCTYPE(I, P, P, P)
    @CLICK
    def clicked(widget, event, data):
        stop()
        return 1

    connect = bind(obj, 'g_signal_connect_data', C.c_ulong, P, S, P, P, P, I)
    for win in windows:
        connect(win, b'button-press-event', C.cast(clicked, P), None, None, 0)

    battery = Path('/sys/class/power_supply/BAT0')
    last_read = -10.0
    test = '--preview' in sys.argv or '--test-click' in sys.argv

    TIMER = C.CFUNCTYPE(I, P)
    @TIMER
    def tick(data):
        nonlocal deadline, lit, seen, last_read
        now = time.monotonic()
        if not test and now - last_read >= 3:
            last_read = now
            try:
                capacity = int((battery / 'capacity').read_text())
                status = (battery / 'status').read_text().strip()
                charging = status != 'Discharging'
                threshold, updated = advance(capacity, charging, seen)
                if updated != seen:
                    seen = updated
                    state.write_text(json.dumps(sorted(seen)))
                if charging:
                    stop()
                elif threshold is not None:
                    deadline = now + DURATION
                    for win in windows:
                        show(win)
            except (OSError, ValueError) as error:
                print(f'battery-alert: {error}', file=sys.stderr, flush=True)
                stop()
        if deadline and now >= deadline:
            stop()
            if test:
                bind(gtk, 'gtk_main_quit', None)()
        if deadline:
            lit = not lit
            alpha = '0.70' if lit else '0.0'
            css = f'#battery-alert {{ background-color: rgba(230, 35, 55, {alpha}); border: none; border-radius: 0; }}'.encode()
            load_css(provider, css, -1, None)
        return 1

    if test:
        deadline = time.monotonic() + DURATION
        for win in windows:
            show(win)
    tick(None)
    @TIMER
    def test_click(data):
        clicked(None, None, None)
        visible = bind(gtk, 'gtk_widget_get_visible', I, P)
        assert deadline == 0 and all(not visible(win) for win in windows)
        print('Click dismissal: PASS', file=sys.stderr, flush=True)
        bind(gtk, 'gtk_main_quit', None)()
        return 0
    if '--test-click' in sys.argv:
        bind(glib, 'g_timeout_add', C.c_uint, C.c_uint, TIMER, P)(1200, test_click, None)
    bind(glib, 'g_timeout_add', C.c_uint, C.c_uint, TIMER, P)(600, tick, None)
    # A hidden Waybar custom module owns this process and its lifecycle.
    print('{"text":""}', flush=True)
    bind(gtk, 'gtk_main', None)()


if __name__ == '__main__':
    main()
