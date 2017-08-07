#!/usr/bin/env python
"""
A script to return a bcrypt hash of a password.

It's intended use is for creating known passwords to replace user passwords in cleaned up databases.

Cost-factor is the log2 number of rounds of hashing to use for the salt. It's worth researching how many rounds you need
for your use context, but recent recommendations are 10-12 as a minimum.

Usage:
scripts/generate-bcrpyt-hashed-password.py <password> <cost-factor>
"""

import bcrypt
from docopt import docopt


def hash_password(password, cost_factor):
    return bcrypt.hashpw(bytes(password), bcrypt.gensalt(cost_factor)).decode('utf-8')

if __name__ == "__main__":
    arguments = docopt(__doc__)
    password = arguments['<password>']
    cost_factor = int(arguments['<cost-factor>'])
    print(hash_password(password, cost_factor))
