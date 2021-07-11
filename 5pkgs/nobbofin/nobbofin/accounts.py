#!/usr/bin/env python3

import argparse
import datetime
import itertools
import sys
from pathlib import Path
from typing import Optional

import orgparse

_DEFAULT_YEAR = 2021
_DEFAULT_ACCOUNTS_ORG = "/home/enno/repos/nobbofin/current/accounts.org"


def gen_acc_list(year: Optional[int] = None, accounts_org: str = _DEFAULT_ACCOUNTS_ORG):
    tree = orgparse.load(accounts_org)

    for node in tree:
        # only output leaves
        if len(node.children) > 0:
            continue

        # lookup path by traversing all parent levels
        path = [node.get_parent(i).heading for i in range(1, node.level)] + [
            node.heading
        ]

        for i, p in enumerate(path):
            # expand date-variable parts
            if "%m" in p:
                if year:
                    path[i] = [
                        datetime.date(year, m, 1).strftime(p) for m in range(1, 13)
                    ]
                else:
                    path[i] = []  # clear if invoked w/o reference date
            else:
                path[i] = [p]

        # generate all combinations
        for prd in itertools.product(*path):
            yield prd


def get_dir(account_name: str, year: int) -> Path:
    return Path(
        f'/home/enno/repos/nobbofin/receipts/{year}/{account_name.replace(":","/")}'
    )


class Accounts:
    name = ""

    def __str__(self):
        return self.name

    def __repr__(self):
        return self.name


def gen_acc_obj(year: int, accounts_org: str = _DEFAULT_ACCOUNTS_ORG):
    """build object with properties resembling account hierarchy,
    useful for autocompletion in ipython environments"""
    obj = Accounts()

    for acc in gen_acc_list(year, accounts_org):
        acc_obj = obj
        for part in acc:
            if not hasattr(acc_obj, part):
                setattr(acc_obj, part, Accounts())
            acc_obj = getattr(acc_obj, part)
        acc_obj.name = ":".join(acc)
    return obj


def gen_bean(year: int, accounts_org: str = _DEFAULT_ACCOUNTS_ORG):
    for prd in gen_acc_list(year, accounts_org):
        sys.stdout.write(f"{year}-01-01 open {':'.join(prd)}\n")


class AccountNotFoundError(Exception):
    def __init__(self, name):
        self.name = name


def check_account(
    name: str, year: int = _DEFAULT_YEAR, accounts_org: str = _DEFAULT_ACCOUNTS_ORG
) -> None:
    for prd in gen_acc_list(year, accounts_org):
        if name == ":".join(prd):
            return
    raise AccountNotFoundError(name)


def main():
    parser = argparse.ArgumentParser(description="generate accounts.bean")
    parser.add_argument("--year", type=int, default=_DEFAULT_YEAR)
    parser.add_argument("--accounts-org", default=_DEFAULT_ACCOUNTS_ORG)
    args = parser.parse_args()

    gen_bean(args.year, args.accounts_org)


if __name__ == "__main__":
    main()
