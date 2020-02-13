from setuptools import setup

setup(
    name="git-alarm",
    packages=["gitalarm"],
    entry_points={"console_scripts": ["git-alarm=gitalarm.cli:main"]},
)
