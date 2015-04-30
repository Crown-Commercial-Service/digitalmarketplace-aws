from setuptools import setup, find_packages

import pip.download
from pip.req import parse_requirements


install_requires = [
    str(r.req) for r in parse_requirements('requirements.txt',
                                           session=pip.download.PipSession())]

setup(
    name='digitalmarketplace-aws',
    version='0.1',
    packages=find_packages(),
    description='Digital Marketplace AWS deployment scripts',
    license='MIT',

    install_requires=install_requires,

    entry_points={
        'console_scripts': [
            'dmaws=dmaws.cli:cli',
        ]
    }
)
