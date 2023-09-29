from setuptools import find_packages, setup

setup(
    name="hcloud-netcfg",
    packages=find_packages(),
    include_package_data=True,
    entry_points={"console_scripts": ["netcfg=netcfg.netcfg:main"]},
    install_requires=[
        "requests",
        "pyyaml",
    ],
)
