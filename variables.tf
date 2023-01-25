variable "my_prefix" {
  description = "Prefix to add to the resources name"
  type = string
  default = "your-name-tf-"
}

variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key"
  type = string
  default = "<your_CC_API_Key>"
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type = string
  default = "<your_CC_API_Secret>"
}

/*

variable "sfdc_instance" {
  description = "SFDC instance"
  type = string
  default = "<your_sfdc_instance>"
}

variable "sfdc_user_name" {
  description = "SFDC user name"
  type = string
  default = <your_sfdc_user>"
}

variable "sfdc_user_password" {
  description = "SFDC password"
  type = string
  default = "<your_sfdc_password>"
}

variable "sfdc_token" {
  description = "SFDC token"
  type = string
  default = "<your_sfdc_token>"
}

variable "aws_key" {
  description = "AWS access key"
  type = string
  default = "<your_aws_key>"
}

variable "aws_secret" {
  description = "SFDC token"
  type = string
  default = "<your_aws_secret>"
}

*/

