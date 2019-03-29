variable "alphagov_git_repositories" {
  type = "list"

  default = [
    "digitalmarketplace-api",
    "digitalmarketplace-search-api",
    "digitalmarketplace-admin-frontend",
    "digitalmarketplace-agreements",
    "digitalmarketplace-antivirus-api",
    "digitalmarketplace-api-docs",
    "digitalmarketplace-apiclient",
    "digitalmarketplace-aws",
    "digitalmarketplace-bad-words",
    "digitalmarketplace-brief-responses-frontend",
    "digitalmarketplace-briefs-frontend",
    "digitalmarketplace-buyer-frontend",
    "digitalmarketplace-cloudwatch-to-graphite",
    "digitalmarketplace-content-loader",
    "digitalmarketplace-credentials",
    "digitalmarketplace-deployment",
    "digitalmarketplace-docker-base",
    "digitalmarketplace-framework-application-guidance",
    "digitalmarketplace-frameworks",
    "digitalmarketplace-frontend-toolkit",
    "digitalmarketplace-functional-tests",
    "digitalmarketplace-g-cloud-service-submission",
    "digitalmarketplace-jenkins",
    "digitalmarketplace-maintenance",
    "digitalmarketplace-manual",
    "digitalmarketplace-performance-testing",
    "digitalmarketplace-prototype",
    "digitalmarketplace-router",
    "digitalmarketplace-runner",
    "digitalmarketplace-scripts",
    "digitalmarketplace-supplier-frontend",
    "digitalmarketplace-test-utils",
    "digitalmarketplace-user-frontend",
    "digitalmarketplace-utils",
    "digitalmarketplace-visual-regression",
  ]
}

resource "aws_codecommit_repository" "codecommit_backup_repos" {
  count = "${length(var.alphagov_git_repositories)}"

  repository_name = "${var.alphagov_git_repositories[count.index]}"
  description     = "Backup CodeCommit repo for github.com/alphagov/${var.alphagov_git_repositories[count.index]}"
}
