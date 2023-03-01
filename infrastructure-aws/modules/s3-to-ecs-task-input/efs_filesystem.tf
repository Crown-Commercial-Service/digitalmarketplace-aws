locals {
  nfs_port = 2049
}

resource "aws_efs_file_system" "filesystem" {
  encrypted = true

  tags = {
    "Name" = "${var.project_name}-${var.environment_name}-${var.process_name}"
  }
}

resource "aws_efs_access_point" "access" {
  file_system_id = aws_efs_file_system.filesystem.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "700"
    }
    path = "/files"
  }

  tags = {
    "Name" = "${var.project_name}-${var.environment_name}-${var.process_name}"
  }
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.filesystem.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "elasticfilesystem:AccessedViaMountTarget": "true"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_efs_mount_target" "target" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.filesystem.id
  security_groups = [aws_security_group.filesystem.id]
  subnet_id       = each.value
}


resource "aws_security_group" "filesystem" {
  name        = "${var.project_name}-${var.environment_name}-${var.process_name}-filesystem"
  description = "EFS for ${var.process_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-${var.process_name}-filesystem"
  }
}

resource "aws_security_group" "filesystem_clients" {
  name        = "${var.project_name}-${var.environment_name}-${var.process_name}-filesystem-clients"
  description = "Entities permitted to access the ${var.project_name}-${var.environment_name}-${var.process_name} filesystem"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-${var.process_name}-filesystem-clients"
  }
}

resource "aws_security_group_rule" "filesystem_efs_in" {
  security_group_id = aws_security_group.filesystem.id
  description       = "Allow ${local.nfs_port} inwards from filesystem-clients SG"

  from_port                = local.nfs_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.filesystem_clients.id
  to_port                  = local.nfs_port
  type                     = "ingress"
}

resource "aws_security_group_rule" "filesystem_client_nfs_out" {
  security_group_id = aws_security_group.filesystem_clients.id
  description       = "Allow ${local.nfs_port} from filesystem-clients SG to filesystem SG"

  from_port                = local.nfs_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.filesystem.id
  to_port                  = local.nfs_port
  type                     = "egress"
}
