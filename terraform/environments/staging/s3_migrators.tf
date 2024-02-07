module "migrate_ingestion_bucket" {
  for_each = local.bucket_names
  source   = "../../core/modules/aws-s3-migrator"

  lambda_dist_bucket_id  = aws_s3_bucket.lambda_dist.id
  migrator_name          = format("ingestion-%s", each.key)
  resource_name_prefixes = local.resource_name_prefixes
  target_bucket_id       = each.value.name
  source_bucket = {
    bucket_name = each.value.source_bucket_name
    aws_region  = each.value.source_region
  }
}
