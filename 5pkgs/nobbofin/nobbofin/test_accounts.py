import unittest

from nobbofin.accounts import AccountNotFoundError, check_account


class CheckAccountsTestCase(unittest.TestCase):
    def test_throws(self):
        self.assertRaises(AccountNotFoundError, check_account, "ABC:DEF")

    def test_passes(self):
        check_account("Expenses:Essen:Lebensmittel")
