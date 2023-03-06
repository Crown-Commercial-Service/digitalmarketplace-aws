# Digital Marketplace - Full

A declaration of the various services and apps which make up a fully-functioning Digital Marketplace installation.

Largely this is a so-called "lift 'n' shift" from an existing installation within CloudFoundry to a collection of ECS Fargate tasks, with associated network and security configurations.

In addition to the core migration work, the following features have been added:

## Automated addition of users

Operatives will need a facility with which to manually add users to the system. The API codebase includes [a Python script](https://github.com/Crown-Commercial-Service/digitalmarketplace-api/blob/main/scripts/add_users.py) *scripts/add_users.py* for adding users. Its primary argument is a filepath which should point to a JSON format file of user credentials. This JSON file is created locally by an operative.

We intend to leverage this script by running it an ECS task. In order to convey a locally-crafted JSON file securely into the reach of an ECS task, the following solution is proposed:

* Provide an S3 bucket into which operatives may securely upload the JSON file
* Copy the JSON file into an EFS file system
* Mount the EFS file system from within an ECS task running the API image
* Run the *scripts/add_users.py* script as the ECS task command, passing in the filename of the JSON file copy
* Remove the EFS file and the S3 object upon completion

This workflow requires careful, reliable orchestration. It's therefore recommended to use Step Functions for this orchestration for many reasons, in particular:

* the cleanliness and separation of responsibilities they encourage
* their ease of debugging and execution visibility
* Optimized integrations with many AWS services

### Security

An appeal of this overall solution is that it only exposes one ingress point to operatives: the ability to write an S3 object. Everything else happens inside fully-managed components, thus there is little risk of accidental privilege escalations.
