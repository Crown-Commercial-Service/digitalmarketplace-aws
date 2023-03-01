locals {
  fs_local_mount_path          = "/mnt/efs0"
  run_task_using_file_sfn_name = "${var.project_name}-${var.environment_name}-run-task-using-file"
}
