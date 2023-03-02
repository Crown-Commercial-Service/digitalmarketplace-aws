# todo

- [x] Rewrite new structure commit by commit, include IAM name policy as you go and REMEMBER to remove commit "Bring role name in line with newer standard"
- [x] Add missing READMEs - cloudwatch logs group doesnt have one for example
- [x] Correct addition of ecr_repo_name_buyer_frontend early in auto.tfvars
- [x] IS REDIS WORKING? Policy for AppRunner -> ElastiCache https://mk-dir.com/blogs/how_to_set_up_aws_app_runner_with_elasticache_and_mongodb
- [x] Update deployment script to to ECS deployment
- [x] Put a private ALB in front of the ECS service
- [x] Increase public subnet to 2 AZs
- [x] Public NLB --> buyer frontend ALB

- [x] Remove NLB
- [x] ALB to front, new ingress SG, accepts HTTPS from anywhere (reuse def but change ref name)
- [x] ECS service out of default SG, new SG only allowwing 80 from ALB

- [x] API service with new ALB
- [x] Refactor where necessary; commit
- [x] New RDS instance
- [x] ECS task definition for migrations with start override of `cd /app && FLASK_APP=application:application venv/bin/flask db upgrade`
- [x] RDS conn uri into env vars for API container; NB that the API containers will need outbound permission as well!

- [x] Put in place a 200 only WSGI-exercising healthcheck
- [x] Add a container level healthcheck

- [x] Hook Buyer FE to API - tokens!
- [x] Secret Key
- [x] User Frontend up

- [ ] Fix the startup dependency problem (or at least the failure to fail)

- [x] switch to new CCS Hosted Zone

- [x] Move PROXY_AUTH_CREDENTIALS to SSM or Secrets Manager

- [ ] Remove SGs, crazy roles, EC2 ingress instance
