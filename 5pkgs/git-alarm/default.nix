{ pkgs }:

pkgs.writePython3 "git-alarm" {} ''
  import argparse
  import re
  import subprocess
  import sys


  # https://stackoverflow.com/questions/14693701/how-can-i-remove-the-ansi-escape-sequences-from-a-string-in-python/14693789#14693789
  ansi_escape = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")


  if __name__ == "__main__":
      parser = argparse.ArgumentParser(
          description="check git repo status using mu and output status line"
      )
      parser.add_argument(
          "--outfile",
          "-o",
          type=argparse.FileType("w"),
          default=sys.stdout
      )
      parser.add_argument(
          "dir", help="repository root directory containing .mu_repo file"
      )
      args = parser.parse_args()

      # find repos with at least one unpushed commit
      cherry = subprocess.run(
          ["mu", "cherry"], cwd=args.dir, stdout=subprocess.PIPE, check=True
      )
      cherry_output = cherry.stdout.decode()
      if "ERROR" in cherry_output:
          print(cherry_output)
          sys.exit(1)
      unpushed = re.findall(
          r"^  (\S+) : git cherry\n    \+",
          ansi_escape.sub("", cherry_output),
          re.MULTILINE,
      )

      # find repos with uncommited files
      status = subprocess.run(
          ["mu", "st"], cwd=args.dir, stdout=subprocess.PIPE, check=True
      )
      status_output = status.stdout.decode()
      if "ERROR" in status_output:
          print(status_output)
          sys.exit(1)
      uncommitted = re.findall(
          r"^(\w+) \w+:$",
          ansi_escape.sub("", status_output),
          re.MULTILINE,
      )

      s = ""

      if len(uncommitted) > 0:
          s += "📝 " + ", ".join(uncommitted)

      if len(unpushed) > 0:
          if s != "":
              s += " "
          s += "📤 " + ", ".join(unpushed)

      with args.outfile as f:
          f.write(s)
''
