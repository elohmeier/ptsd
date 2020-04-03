import json
import socket
import subprocess
import sys

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind(("", 12345))
print("listening on :12345")
sock.listen()

try:
    conn, _ = sock.accept()
    data = conn.recv(4096)
except:
    sys.exit(1)
finally:
    conn.close()

data = json.loads(data.decode("utf8"))
print(data)
# input()  # break

# subprocess.run(["C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE", "C:\\Temp\\test.xlsx"])
subprocess.run(data)
