#!/usr/bin/env python

import re

config = {}

with open("klipper.cfg") as f:
    cur_grp = None
    cur_k = None
    for l in f.readlines():
        grp_m = re.match(r"^\[([\w\s]+)\]$", l)
        if grp_m:
            cur_grp = grp_m.group(1)
            config[cur_grp] = {}
            continue

        val_m = re.match(r"^(\w+):\s*(.*)$", l)
        if val_m:
            cur_k = val_m.group(1)
            config[cur_grp][cur_k] = val_m.group(2)
            continue

        extra_m = re.match(r"^([^\n^#]+)$", l)
        if extra_m:
            config[cur_grp][cur_k] += extra_m.group(1) + "\n"


for k, v in config.items():
    print("%s = {" % k) if " " not in k else print('"%s" = {' % k)
    for kk, vv in v.items():
        print('  %s = "%s";' % (kk, vv)) if "\n" not in vv else print(
            "  %s = ''\n\n%s'';" % (kk, vv)
        )
    print("};\n")
