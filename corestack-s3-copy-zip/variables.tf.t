variable "source_bucket" {
  description = "Name of the source S3 bucket"
  type        = string
  default     = "bucket"
}

variable "destination_bucket" {
  description = "Name of the destination S3 bucket"
  type        = string
  default     = "new-bucket"
}

