from setuptools import setup, find_packages

setup(
    name='digitalmarketplace-aws',
    version='0.1',
    packages=find_packages(),
    description='Digital Marketplace AWS deployment scripts',
    licence='MIT',

    install_requires=[
        'ansible',
        'boto',
        'Click',
        'Jinja2',
        'PyYAML',
        'toposort',
    ],

    entry_points={
        'console_scripts': [
            'dmaws=dmaws.cli:cli',
        ]
    }
)
