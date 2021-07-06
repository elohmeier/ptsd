#!/usr/bin/env python3

from datetime import date
from nobbofin.insert import get_date


def test_get_date():
    assert get_date("Wertpapierertrag 13.05.2021.pdf") == date(2021, 5, 13)
    assert get_date("2021-03-19 Hauptversammlungen.pdf") == date(2021, 3, 19)
    assert get_date("Wertpapierabrechnung_vom_07.05.2021DF2167.pdf") == date(2021, 5, 7)
    assert get_date("FZ_11-8-2020_OLAF-0000221462_KompletterAntrag.pdf") == date(
        2020, 8, 11
    )
    assert get_date("2021-3-31-1965414572_06-RG.pdf") == date(2021, 3, 31)
    assert get_date("Kreditkartenabrechnung_xxxxxxxx_per_2020_11_20.pdf") == date(
        2020, 11, 20
    )
    assert get_date("Girokonto_Kontoauszug_20210402.pdf") == date(2021, 4, 2)
    assert get_date("Girokonto_Kontoauszug_20201002.pdf") == date(2020, 10, 2)
