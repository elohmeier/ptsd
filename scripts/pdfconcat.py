import subprocess
import sys
from pathlib import Path

print("argv:", sys.argv)
print("cwd:", Path.cwd())
output_path = Path(" ".join([Path(p).stem for p in sys.argv[1:]]) + ".pdf")
print("output_path:", output_path.resolve())
subprocess.run(["@pdftk@/bin/pdftk", *sys.argv[1:], "cat", "output", output_path])
