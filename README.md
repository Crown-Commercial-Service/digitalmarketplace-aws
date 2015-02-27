# Digital Marketplace AWS

[Ansible](http://www.ansible.com/home) playbooks to create and provision the
AWS infrastructure for Digital Marketplace applications.

## Setup

### Set up python dependencies
Install dependencies with [virtualenv](https://virtualenv.pypa.io/en/latest/)
and [pip](https://pip.pypa.io/en/latest/installing.html).

To install virtualenv and create a virtual environment see the
[digitalmarketplace-admin-frontend](https://github.com/alphagov/digitalmarketplace-admin-frontend).

Finally run the bootstrap script
```
./scripts/bootstrap.sh
```

### Set up AWS access credentials

Ansible's AWS integration depends on [boto](https://github.com/boto/boto) which
expects to find your AWS credentials in `~/.aws/credentials`, see [the boto docs](http://docs.pythonboto.org/en/latest/boto_config_tut.html#credentials).
Locally you should only ever have development credentials.

### Set up an SSH key pair

Create an [EC2 key pair](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
and save this file with the same name as the keypair in your `.ssh` directory.
This will be used to provision EC2 instances after they've been created, for
example the Elasticsearch instances.

### Create user.yml file and set user-specific variables

```
cp user.yml.sample user.yml
```

Copy `user.yml.sample` to `user.yml` and replace `***` placeholders with
actual variable values.

`user.yml` is loaded by default and should set values for variables that
don't have any defaults set in the playbook roles and environment files.
It can also be used to overwrite default values for existing variables.
