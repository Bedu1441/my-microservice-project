variable "cluster_name" {
  type    = string
  default = "lesson-8-9-eks"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "node_instance_type" {
  type    = string
  default = "t3.small"
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "excluded_azs" {
  type    = list(string)
  default = ["us-east-1e"]
}
