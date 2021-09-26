"""
creates a new workspace on the focused output using the next free workspace number
"""

import i3ipc


if __name__ == "__main__":
    ipc = i3ipc.Connection()

    ws_names = [ws.name for ws in ipc.get_workspaces()]

    for i in range(1, 21):
        if any([n.startswith(str(i)) for n in ws_names]):
            continue
        ipc.command("workspace %s" % i)
        break
