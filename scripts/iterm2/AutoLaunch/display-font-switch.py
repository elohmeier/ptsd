#!/usr/bin/env python3.10

import iterm2
from AppKit import NSScreen  # type:ignore


def get_screen_config() -> str:
    screen_names = [s.localizedName() for s in NSScreen.screens()]
    return ";".join(sorted(screen_names))


SCREEN_PROFILE_MAP = {
    "Built-in Retina Display": "Retina",
}

DEFAULT_PROFILE = "Spleen 8x16"


def get_target_profile_name() -> str:
    screen_config = get_screen_config()

    # Get the target profile based on which display we're on
    target_profile_name = SCREEN_PROFILE_MAP.get(screen_config, DEFAULT_PROFILE)

    if not target_profile_name:
        raise Exception(f"no profile configured for screen config `{screen_config}`")

    return target_profile_name


async def update_session_profile(session: iterm2.Session):
    target_profile_name = get_target_profile_name()

    profile = await session.async_get_profile()

    # Get current font
    current_profile_name = profile.name

    if current_profile_name == target_profile_name:
        print(f"profile `{current_profile_name}` already in use, skipping switching")
        return

    partialProfiles = await iterm2.PartialProfile.async_query(session.connection)

    for partial in partialProfiles:
        if partial.name == target_profile_name:
            full = await partial.async_get_full_profile()
            await session.async_set_profile(full)
            print(
                f"switched session profile from `{current_profile_name}` to `{target_profile_name}`"
            )
            break
    else:
        print(f"Could not find profile `{target_profile_name}`")


async def configure_default_profile(connection: iterm2.Connection):
    """Set default profile for new sessions."""
    target_profile_name = get_target_profile_name()

    default_profile = await iterm2.Profile.async_get_default(connection)

    if default_profile.name == target_profile_name:
        print(f"profile `{target_profile_name}` already default, skipping update")
        return

    partialProfiles = await iterm2.PartialProfile.async_query(connection)

    for partial in partialProfiles:
        if partial.name == target_profile_name:
            await partial.async_make_default()
            print(f"profile `{target_profile_name}` marked as default")
            break
    else:
        print(f"Could not find profile `{target_profile_name}`")


async def main(connection: iterm2.Connection):
    # Since iterm will determine the window size (e.g. on new tag) based on the
    # default profile's font, this avoids unneeded window-resizes when using a
    # NewSessionMonitor (given different font sizes between the profiles)
    await configure_default_profile(connection)

    # Update existing sessions
    app = await iterm2.async_get_app(connection)

    if app is None:
        raise Exception("could not get app handle")

    for window in app.terminal_windows:
        for tab in window.tabs:
            for session in tab.sessions:
                await update_session_profile(session)


# This instructs the script to run the "main" coroutine and to keep running even after it returns.
iterm2.run_forever(main)
