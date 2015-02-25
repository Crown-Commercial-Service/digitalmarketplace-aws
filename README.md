# Digital Marketplace AWS

[Ansible](http://www.ansible.com/home) playbooks to create and provision the
AWS infrastructure for Digital Marketplace applications.

## Setup

### Set up python dependencies
Install dependencies with [virtualenv](https://virtualenv.pypa.io/en/latest/)
and [pip](https://pip.pypa.io/en/latest/installing.html).

To install virtualenv and create a virtual environment see the
[digitalmarketplace-admin-frontend](https://github.com/alphagov/digitalmarketplace-admin-frontend).

Finally install the dependencies with
```
pip install -r requirements.txt
```

### Set up AWS access credentials

Ansible's AWS integration depends on [boto](https://github.com/boto/boto) which
expects to find your AWS credentials in `~/.aws/credentials`, see [their docs](http://docs.pythonboto.org/en/latest/boto_config_tut.html#credentials).
Locally you should only ever have development credentials.

## Bring up a new environment
