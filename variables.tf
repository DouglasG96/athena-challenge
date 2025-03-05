variable "region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}
variable "email" {
  description = "Email for SNS Subscription"
  default     = "devopsconsultantsv@gmail.com"
}
variable "profile" {
  description = "AWS CLI profile"
  default     = "default"
}