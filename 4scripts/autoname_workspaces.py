# !/usr/bin/env nix-shell
# !nix-shell -i python3 -p python3Packages.i3ipc

"""
This script requires i3ipc-python package (install it from a system package manager or pip).
It adds icons to the workspace name for each open window.
Set your keybindings like this: set $workspace1 workspace number 1
Add your icons to WINDOW_ICONS.
Based on https://github.com/maximbaz/dotfiles/blob/master/bin/i3-autoname-workspaces
"""

import argparse
import logging
import re
import signal
import sys
from typing import Dict

import i3ipc

# copy "icon" from https://www.nerdfonts.com/cheat-sheet
WINDOW_ICONS = {
    "burp-startburp": "ﰍ",
    "firefox": "",
    "chromium-browser": "",
    "chromium": "",
    "foot": "",
    "term.floating": "",
    "alacritty": "",
    "pcmanfm": "",
    "org.pwmt.zathura": "",
    "vscodium": "",
    "codium": "",
    "kodi": "",
    "element": "ﬧ",
    "spotify": "",
    "pavucontrol": "醙",
    "sxiv": "",
    ".virt-manager-wrapped": "",
    "soffice": "",
    "libreoffice-startcenter": "",
    "libreoffice-writer": "",
    "libreoffice-calc": "",
    "libreoffice-impress": "",
    "gimp-2.10": "",
    "signal": "",
    "ghidra": "ﯢ",
    "microsoft teams - preview": "",
    "swappy": "",
    "gcr-prompter": "",
    "sylpheed": "",
    "com.github.wwmm.easyeffects":"שּׂ",
}

DEFAULT_ICON = ""


def icon_for_window(window: i3ipc.Con) -> str:
    """ find icon for a i3 window object """

    name = None
    if window.app_id is not None and len(window.app_id) > 0:
        name = window.app_id.lower()
    elif window.window_class is not None and len(window.window_class) > 0:
        name = window.window_class.lower()

    if name is None:
        return DEFAULT_ICON

    if name in WINDOW_ICONS:
        return WINDOW_ICONS[name]

    logging.info("No icon available for window with name: %s", name)
    return DEFAULT_ICON


def rename_workspaces(ipc: i3ipc.Connection, duplicates: bool) -> None:
    """ scans for windows in all workspaces as renames the workspaces """

    for workspace in ipc.get_tree().workspaces():
        name_parts = parse_workspace_name(workspace.name)
        icon_tuple = ()
        for wksp in workspace:
            if wksp.app_id is not None or wksp.window_class is not None:
                icon = icon_for_window(wksp)
                if not duplicates and icon in icon_tuple:
                    continue
                icon_tuple += (icon,)
        name_parts["icons"] = "  ".join(icon_tuple)
        new_name = construct_workspace_name(name_parts)
        ipc.command('rename workspace "%s" to "%s"' % (workspace.name, new_name))


def undo_window_renaming(ipc: i3ipc.Connection) -> None:
    """ reset workspace names to original name """

    for workspace in ipc.get_tree().workspaces():
        name_parts = parse_workspace_name(workspace.name)
        name_parts["icons"] = None
        new_name = construct_workspace_name(name_parts)
        ipc.command('rename workspace "%s" to "%s"' % (workspace.name, new_name))
    ipc.main_quit()
    sys.exit(0)


def parse_workspace_name(name: str) -> Dict:
    """ analyses workspace name structure """

    return re.match(
        r"(?P<num>[0-9]+):?(?P<shortname>\w+)? ?(?P<icons>.+)?", name
    ).groupdict()


def construct_workspace_name(parts: Dict) -> str:
    """ generate name of workspace """

    new_name = str(parts["num"])
    if parts["shortname"] or parts["icons"]:
        new_name += ":"

        if parts["shortname"]:
            new_name += parts["shortname"]

        if parts["icons"]:
            new_name += " " + parts["icons"]

    return new_name


def main():
    """ main entrypoint """

    parser = argparse.ArgumentParser(
        description="This script automatically changes the workspace name in sway depending on your open applications."
    )
    parser.add_argument(
        "--duplicates",
        "-d",
        action="store_true",
        help="Set it when you want an icon for each instance of the same application per workspace.",
    )
    parser.add_argument(
        "--logfile",
        "-l",
        type=str,
        default="/tmp/sway-autoname-workspaces.log",
        help="Path for the logfile.",
    )
    args = parser.parse_args()

    logging.basicConfig(
        level=logging.INFO,
        filename=args.logfile,
        filemode="w",
        format="%(message)s",
    )

    ipc = i3ipc.Connection()

    for sig in [signal.SIGINT, signal.SIGTERM]:
        signal.signal(sig, lambda _, __: undo_window_renaming(ipc))

    def window_event_handler(ipc: i3ipc.Connection, evnt: i3ipc.events.IpcBaseEvent):
        """ handle i3 window event """

        if not isinstance(evnt, i3ipc.events.WindowEvent):
            return

        if evnt.change in ["new", "close", "move"]:
            rename_workspaces(ipc, args.duplicates)

    ipc.on("window", window_event_handler)

    rename_workspaces(ipc, args.duplicates)

    ipc.main()


if __name__ == "__main__":
    main()
