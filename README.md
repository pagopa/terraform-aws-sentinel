# Terraform AWS Sentinel

Terraform module which creates all resources to connect S3 to Azure Sentilen.
It creates all resources required for the Sentinel S3 Connector.


## Exampla usage

 ```hcl
 module "sentinel" {
  
  source = "git::https://github.com/pagopa/terraform-aws-sentinel.git?ref=v1.0.0"

  account_id            = data.aws_caller_identity.current.account_id
  queue_name            = "sentinel-queue"
  trail_name            = "sentinel-trail"
  sentinel_bucket_name  = "sentinel-logs"
  expiration_days       = 3
  sentinel_workspace_id = "12321312323213"
}
 ```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0   |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.sentinel](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_iam_policy.sentinel_allow_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.sentinel](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.sentinel](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.sentinel_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.sentinel_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.sentinel_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.sentinel_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.sentinel](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_notification.sentinel](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.sentinel_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.sentinel_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_sqs_queue.sentinel](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_iam_policy.sentinel](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account id | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | `"eu-south-1"` | no |
| <a name="input_expiration_days"></a> [expiration\_days](#input\_expiration\_days) | The lifetime, in days, of the objects that are subject to the rule. | `number` | `7` | no |
| <a name="input_queue_name"></a> [queue\_name](#input\_queue\_name) | SQS queue sentinel gets notification for new logs to read. | `string` | n/a | yes |
| <a name="input_sentinel_bucket_name"></a> [sentinel\_bucket\_name](#input\_sentinel\_bucket\_name) | Bucket where cloud trail logs are stored and consumed by sentinel. | `string` | n/a | yes |
| <a name="input_sentinel_servcie_account_id"></a> [sentinel\_servcie\_account\_id](#input\_sentinel\_servcie\_account\_id) | Microsoft Sentinel's service account ID for AWS. | `string` | `"197857026523"` | no |
| <a name="input_sentinel_workspace_id"></a> [sentinel\_workspace\_id](#input\_sentinel\_workspace\_id) | Sentinel workspece id | `string` | `null` | no |
| <a name="input_trail_name"></a> [trail\_name](#input\_trail\_name) | Trail name with events to send to azure sentinel. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sentinel_queue_url"></a> [sentinel\_queue\_url](#output\_sentinel\_queue\_url) | n/a |
| <a name="output_sentinel_role_arn"></a> [sentinel\_role\_arn](#output\_sentinel\_role\_arn) | n/a |
<!-- END_TF_DOCS -->