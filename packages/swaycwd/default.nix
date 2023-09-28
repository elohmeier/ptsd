{ writers, sway, jq, procps }:
# from https://www.reddit.com/r/swaywm/comments/ayedi1/opening_terminals_at_the_same_directory/
writers.writeDashBin "swaycwd" ''
  pid=$(${sway}/bin/swaymsg -t get_tree | ${jq}/bin/jq '.. | select(.type?) | select(.type=="con") | select(.focused==true).pid')
  ppid=$(${procps}/bin/pgrep --newest --parent ''${pid})
  readlink /proc/''${ppid}/cwd || echo $HOME  
''
