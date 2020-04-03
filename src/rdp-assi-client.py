import argparse
import json
import socket
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--ip", default="192.168.101.188")
parser.add_argument("prog")
parser.add_argument("arg")
args = parser.parse_args()

loc_map = {"/home/enno/": "Z:\\"}

arg = args.arg

for k, v in loc_map.items():
    if arg.startswith(k):
        arg = arg.replace(k, v)
        break

arg = arg.replace("/", "\\")
data = [args.prog, arg]
print(data)

p = subprocess.Popen(
    [
        "xfreerdp",
        "/u:enno",
        "/p:doener",  # no external routes...
        f"/v:{args.ip}",
        "/app:C:\\Temp\\rdp-assi.pyw",
        "+fonts",
    ]
)

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((args.ip, 12345))

try:
    sock.sendall(json.dumps(data).encode("utf-8"))
finally:
    sock.close()

try:
    p.wait()
except KeyboardInterrupt:
    pass

# keep process/window running/open to see output,
# will be hidden by file-manager by default.
input()
