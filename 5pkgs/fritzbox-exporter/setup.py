from setuptools import find_packages, setup

setup(
    name="fritzbox-exporter",
    packages=find_packages(),
    scripts=["fritz_export_helper.py", "fritz_exporter.py"],
)
