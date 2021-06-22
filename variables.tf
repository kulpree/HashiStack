# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

# None

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "architecture" {
  type = string
  default     = null
}

variable "ami_id" {
  description = "The ID of the AMI to run in the cluster. This should be an AMI built from the Packer template under examples/nomad-consul-ami/nomad-consul.json. If no AMI is specified, the template will 'just work' by using the example public AMIs. WARNING! Do not use the example AMIs in a production setting!"
  type        = string
  default     = null
}

variable "nomad_cluster_name" {
  description = "What to name the Nomad cluster and all of its associated resources"
  type        = string
  default     = "Hashistack-nomad"
}

variable "consul_cluster_name" {
  description = "What to name the Consul cluster and all of its associated resources"
  type        = string
  default     = "Hashistack-consul"
}

variable "num_nomad_servers" {
  description = "The number of Nomad server nodes to deploy. We strongly recommend using 3 or 5."
  type        = number
  default     = 3
}

variable "num_nomad_clients" {
  description = "The number of Nomad client nodes to deploy. You can deploy as many as you need to run your jobs."
  type        = number
  default     = 6
}

variable "num_consul_servers" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  type        = number
  default     = 3
}

variable "cluster_tag_key" {
  description = "The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster."
  type        = string
  default     = "consul-servers"
}

variable "ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to null to not associate a Key Pair."
  type        = string
  default     = null
}

variable "create_dns_entry" {
  description = "If set to true, this module will create a Route 53 DNS A record for the ELB in the var.hosted_zone_id hosted zone with the domain name in var.domain_name."
  default     = true
}

variable "nomad_domain_name" {
  description = "The domain name to use in the DNS A record for the ELB (e.g. nomad.example.com). Only used if var.create_dns_entry is true."
  type        = string
  default     = "nomad.thedevopsguru.net"
}

variable "consul_domain_name" {
  description = "The domain name to use in the DNS A record for the ELB (e.g. nomad.example.com). Only used if var.create_dns_entry is true."
  type        = string
  default     = "consul.thedevopsguru.net"
}

variable "acm_arn" {
  description = "ACM Arn for ssl cert"
  default = "arn:aws:acm:us-east-1:644749313408:certificate/8df14432-78c7-409c-90c2-0252b1ac90e6"
}

variable "hosted_zone_domain_name" {
  description = "The domain name of the Route 53 Hosted Zone in which to add a DNS entry for Vault (e.g. example.com). Only used if var.create_dns_entry is true."
  type        = string
  default     = "thedevopsguru.net"
}