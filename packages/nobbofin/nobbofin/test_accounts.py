import unittest

from nobbofin.accounts import AccountNotFoundError, check_account


class CheckAccountsTestCase(unittest.TestCase):
    def test_throws(self):
        self.assertRaises(
            AccountNotFoundError,
            lambda: check_account("ABC:DEF", accounts_org="./accounts.org"),
        )

    def test_passes(self):
        check_account("Expenses:Essen:Lebensmittel", accounts_org="./accounts.org")
