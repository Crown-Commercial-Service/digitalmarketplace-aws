variable "alphagov_git_repositories" {
  type = map(object({
    default_branch = string
  }))

  default = {
    digitalmarketplace-api = {
      default_branch = "master"
    },
    digitalmarketplace-search-api = {
      default_branch = "master"
    },
    digitalmarketplace-admin-frontend = {
      default_branch = "master"
    },
    digitalmarketplace-agreements = {
      default_branch = "master"
    },
    digitalmarketplace-antivirus-api = {
      default_branch = "master"
    },
    digitalmarketplace-apiclient = {
      default_branch = "master"
    },
    digitalmarketplace-aws = {
      default_branch = "master"
    },
    digitalmarketplace-bad-words = {
      default_branch = "master"
    },
    digitalmarketplace-brief-responses-frontend = {
      default_branch = "master"
    },
    digitalmarketplace-briefs-frontend = {
      default_branch = "master"
    },
    digitalmarketplace-buyer-frontend = {
      default_branch = "master"
    },
    digitalmarketplace-content-loader = {
      default_branch = "master"
    },
    digitalmarketplace-credentials = {
      default_branch = "master"
    },
    digitalmarketplace-docker-base = {
      default_branch = "master"
    },
    digitalmarketplace-frameworks = {
      default_branch = "main"
    },
    digitalmarketplace-frontend-toolkit = {
      default_branch = "master"
    },
    digitalmarketplace-functional-tests = {
      default_branch = "master"
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
      default_branch = "master"
    },
    digitalmarketplace-runner = {
      default_branch = "main"
    },
    digitalmarketplace-scripts = {
      default_branch = "master"
    },
    digitalmarketplace-supplier-frontend = {
      default_branch = "master"
    },
    digitalmarketplace-test-utils = {
      default_branch = "main"
    },
    digitalmarketplace-user-frontend = {
      default_branch = "master"
    },
    digitalmarketplace-utils = {
      default_branch = "master"
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

