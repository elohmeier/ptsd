#!/usr/bin/env python3

import json
import re
import sys

prefs={}

with open(sys.stdin.fileno()) as f:
    for l in f:
        m = re.match(r"(defaultPref|pref|lockPref)\(\"(?P<key>[a-zA-Z\.0-9_\-]+)\",\s+(?P<value>[%\?=#,:/\- _\.a-zA-Z\"0-9]+)\);", l)
        if m:
            val = m.group("value")
            if val == "false":
                val = False
            elif val == "true":
                val = True
            elif val.startswith("\"") and val.endswith("\""):
                val = val[1:-1]
            else:
                val = int(val)
            prefs[m.group("key")] = val
        #else:
        #    print("skipped", l)
print(json.dumps(prefs, indent=2,sort_keys=True))
