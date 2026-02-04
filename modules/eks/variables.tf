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
