#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p python3Packages.dateutil -p python3Packages.holidays

import argparse

import holidays
from dateutil.parser import isoparse
from dateutil.relativedelta import relativedelta
from dateutil.rrule import DAILY, rrule

parser = argparse.ArgumentParser()
parser.add_argument("dtstart")
parser.add_argument("months", type=int)
args = parser.parse_args()

s = isoparse(args.dtstart)
e = s + relativedelta(months=args.months) - relativedelta(days=1)

r = rrule(freq=DAILY, dtstart=s, until=e)

ct = len([d for d in r if d.weekday() < 5 and d not in holidays.Germany(prov="HH")])

print(f"range: {s:%d.%m.%Y} - {e:%d.%m.%Y}")
print("workdays w/o HH holidays:", ct)
