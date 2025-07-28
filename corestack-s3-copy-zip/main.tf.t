data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/s3_sync.py"
  output_path = "${path.module}/lambda/s3_sync.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "s3-sync-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "s3-sync-lambda-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect: "Allow",
        Action: [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        Resource: [
          "arn:aws:s3:::${var.source_bucket}",
          "arn:aws:s3:::${var.source_bucket}/*",
          "arn:aws:s3:::${var.destination_bucket}",
          "arn:aws:s3:::${var.destination_bucket}/*"
        ]
      },
      {
        Effect: "Allow",
        Action: [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "s3_sync" {
  function_name = "s3-sync-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "s3_sync.lambda_handler"
  runtime       = "python3.9"
  timeout       = 900
  filename      = data.archive_file.lambda_zip.output_path

  environment {
    variables = {
      SOURCE_BUCKET = var.source_bucket
      DEST_BUCKET   = var.destination_bucket
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_attach
  ]
}
