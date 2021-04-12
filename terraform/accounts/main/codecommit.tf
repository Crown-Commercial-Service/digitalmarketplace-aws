variable "alphagov_git_repositories" {
  type = map(object({
    default_branch = string
  }))

  default = {
    digitalmarketplace-api = {
      default_branch = "main"
    },
    digitalmarketplace-search-api = {
      default_branch = "main"
    },
    digitalmarketplace-admin-frontend = {
      default_branch = "main"
    },
    digitalmarketplace-agreements = {
      default_branch = "master"
    },
    digitalmarketplace-antivirus-api = {
      default_branch = "main"
    },
    digitalmarketplace-apiclient = {
      default_branch = "main"
    },
    digitalmarketplace-aws = {
      default_branch = "main"
    },
    digitalmarketplace-bad-words = {
      default_branch = "master"
    },
    digitalmarketplace-brief-responses-frontend = {
      default_branch = "main"
    },
    digitalmarketplace-briefs-frontend = {
      default_branch = "main"
    },
    digitalmarketplace-buyer-frontend = {
      default_branch = "main"
    },
    digitalmarketplace-content-loader = {
      default_branch = "master"
    },
    digitalmarketplace-credentials = {
      default_branch = "master"
    },
    digitalmarketplace-docker-base = {
      default_branch = "main"
    },
    digitalmarketplace-frameworks = {
      default_branch = "main"
    },
    digitalmarketplace-frontend-toolkit = {
      default_branch = "main"
    },
    digitalmarketplace-functional-tests = {
      default_branch = "main"
    },
    digitalmarketplace-jenkins = {
      default_branch = "main"
    },
    digitalmarketplace-maintenance = {
      default_branch = "master"
    },
    digitalmarketplace-manual = {
      default_branch = "master"
    },
    digitalmarketplace-performance-testing = {
      default_branch = "master"
    },
    digitalmarketplace-router = {
      default_branch = "main"
    },
    digitalmarketplace-runner = {
      default_branch = "main"
    },
    digitalmarketplace-scripts = {
      default_branch = "main"
    },
    digitalmarketplace-supplier-frontend = {
      default_branch = "main"
    },
    digitalmarketplace-test-utils = {
      default_branch = "main"
    },
    digitalmarketplace-user-frontend = {
      default_branch = "main"
    },
    digitalmarketplace-utils = {
      default_branch = "main"
    },
    digitalmarketplace-visual-regression = {
      default_branch = "master"
    },
    digitalmarketplace-govuk-frontend = {
      default_branch = "master"
    },
    digitalmarketplace-developer-tools = {
      default_branch = "main"
    },
  }
}

resource "aws_codecommit_repository" "codecommit_backup_repos" {
  for_each = var.alphagov_git_repositories

  repository_name = each.key
  description     = "Backup CodeCommit repo for github.com/alphagov/${each.key}"
  default_branch  = each.value["default_branch"]
}

