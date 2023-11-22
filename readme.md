# Terraform AWS HTTP Lambda SQS
A terraform configuration to provision Lambda function that gets triggered by SQS queue messages.

## Resources used

 - https://medium.com/appetite-for-cloud-formation/setup-lambda-to-event-source-from-sqs-in-terraform-6187c5ac2df1
 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping
 - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue