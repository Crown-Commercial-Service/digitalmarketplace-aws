# Digital Marketplace AWS

This repository contains configuration and utility tools we use for setting up our infrastructure
and manage our release process.

## Structure

There are a few independent tools we're using that are configured and run from this repo:

* [Terraform](https://www.terraform.io/) (modules and configuration files in `terraform/`) is used
  to create and manage AWS resources (DNS records, CloudWatch logs, S3 buckets etc.)
* `scripts` contains executable scripts we use to manage our PaaS environments
* `dmaws` contains some helper python functions used by some of the scripts
* `paas` contains PaaS manifest templates that are rendered by `make generate-manifest`
* `vars` contains environment specific variables used in the PaaS manifest generation
* `kibana` contains a Makefile and dependencies list for managing Kibana configuration

## Setup

### Set up python dependencies
Install dependencies with [virtualenv](https://virtualenv.pypa.io/en/latest/)
and [pip](https://pip.pypa.io/en/latest/installing.html).

```
make requirements
```

## Terraform

For Terraform setup, including non python dependencies and usage please check the separate ([README](terraform/README.md)).

- [Terraform installation and setup](terraform/README.md#requirements) (requires MFA)
- [Terraform usage](terraform/README.md#make-targets)
- [Using Terraform in an new AWS environment](terraform/README.md#requirements-in-a-new-aws-environment)

## Managing Kibana configuration

`kibana/Makefile` contains make steps to manage Kibana configs.

`make dump STAGE=...` will download Kibana index (including mapping, saved searches, visualizations
and dashboards) and store them in `kibana-export.json`.

`make restore STAGE=...` uploads configuration from `kibana-export.json` to the target STAGE stack
and replaces any settings that were there before.

Both commands use credentials from terraform files, so they need `sops` profile to be active.
