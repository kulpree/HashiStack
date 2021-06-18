variable "region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = {
    "arm64" : "t4g.micro",
    "amd64" : "t3.micro"
  }
}