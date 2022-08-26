#!/usr/bin/env python3

import json
import sys

from itertools import groupby
from lxml import etree

tree = etree.parse("/home/enno/repos/nobbofin/portfolio.xml")
symbols = tree.xpath("/client/securities/security[feed='YAHOO']/tickerSymbol/text()")

# sort & rm duplicates
symbols = [k for k, _ in groupby(sorted(symbols))]

json.dump(symbols, sys.stdout, indent=2)
