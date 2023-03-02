# Jenkins Access

This composition contains the declaration of IAM resources required to allow DMP Jenkins to perform deployments to ECS
in a specified AWS account. This will create the following:
- A policy granting permissions to perform the required actions in ECS
- A policy granting the relevant permissions to initialise and apply Terraform in the specified AWS account
- A policy allowing the specified Jenkins AWS Account to assume the role as required
- An IAM role (which the above policies are subsequently applied to)

_Note: You will also need to update the relevant IAM role in the DMP Jenkins AWS Account. This will require the relevant
STS permissions to be attached to it (in order to allow the IAM role this composition creates to be assumed by Jenkins)_