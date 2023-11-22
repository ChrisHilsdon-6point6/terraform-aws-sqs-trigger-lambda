locals {
  lambda_filename = "lambda_sqs_trigger"
}

data "archive_file" "python_lambda_package" {
  type             = "zip"
  output_file_mode = "0666"
  source_file      = "${path.module}/lambda/${local.lambda_filename}.py"
  output_path      = "${path.module}/lambda/${local.lambda_filename}.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda_sqs"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_role_basic" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_role_sqs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda_sqs_log" {
  name = "/aws/lambda/${aws_lambda_function.lambda_function_from_sqs.function_name}"
}

resource "aws_lambda_function" "lambda_function_from_sqs" {
  function_name    = local.lambda_filename
  filename         = "${path.module}/lambda/${local.lambda_filename}.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "python3.11"
  handler          = "${local.lambda_filename}.lambda_handler"
  timeout          = 10
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.terraform_queue.arn
  enabled          = true
  function_name    = "${aws_lambda_function.lambda_function_from_sqs.arn}"
  batch_size       = 1
}