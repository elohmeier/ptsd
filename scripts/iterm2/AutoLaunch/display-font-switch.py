#!/usr/bin/env python3.10

import iterm2
from AppKit import NSScreen  # type:ignore


def get_screen_config() -> str:
    screen_names = [s.localizedName() for s in NSScreen.screens()]
    return ";".join(sorted(screen_names))


SCREEN_FONT_MAP = {
    "Built-in Retina Display": ("FiraCode Nerd Font Mono 11", True),
}


async def update_session_font(session: iterm2.Session):
    screen_config = get_screen_config()

    # Get the target font based on which display we're on
    target_font, target_font_antialias = SCREEN_FONT_MAP.get(
        screen_config, (None, False)
    )

    if not target_font:
        print(f"no font configured for screen config `{screen_config}`")
        return

    # Get the session's profile because we need to know its font.
    profile = await session.async_get_profile()

    # Get current font
    current_font = profile.normal_font

    if current_font == target_font:
        print(f"font `{current_font}` already configured, skipped switching")
        return

    change = iterm2.LocalWriteOnlyProfile()
    change.set_normal_font(target_font)
    change.set_ascii_anti_aliased(target_font_antialias)

    # Update the session's copy of its profile without updating the
    # underlying profile.
    await session.async_set_profile_properties(change)

    print(f"switched font from `{current_font}` to `{target_font}`")


async def main(connection: iterm2.Connection):
    # Monitor existing sessions
    app = await iterm2.async_get_app(connection)

    if app is None:
        raise Exception("could not get app handle")

    for window in app.terminal_windows:
        for tab in window.tabs:
            for session in tab.sessions:
                await update_session_font(session)

    # When new sessions are created, monitor them, too.
    async with iterm2.NewSessionMonitor(connection) as mon:
        while True:
            session_id = await mon.async_get()  # blocking
            if session := app.get_session_by_id(session_id):
                await update_session_font(session)


# This instructs the script to run the "main" coroutine and to keep running even after it returns.
iterm2.run_forever(main)
