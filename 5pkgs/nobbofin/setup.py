from setuptools import setup

setup(
    name="nobbofin",
    packages=["nobbofin"],
    entry_points={
        "console_scripts": [
            "nobbofin-accounts=nobbofin.accounts:main",
            "nobbofin-insert=nobbofin.insert:main",
        ]
    },
)
