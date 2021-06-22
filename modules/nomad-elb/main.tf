# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# ----------------------------------------------------------------------------------------------------------------------
terraform {
  # This module is now only being tested with Terraform 0.15.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.15.x code.
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE Nomad ELB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_elb" "nomad-servers" {
  name = var.name

  internal                    = var.internal
  cross_zone_load_balancing   = var.cross_zone_load_balancing
  idle_timeout                = var.idle_timeout
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout

  security_groups = [aws_security_group.nomad-servers.id]
  subnets         = var.subnet_ids

  # optional access_logs creation  
  dynamic "access_logs" {
    for_each = var.access_logs == null ? [] : ["once"]

    content {
      enabled       = lookup(access_logs.value, "enabled", lookup(access_logs.value, "bucket", null))
      bucket        = lookup(access_logs.value, "bucket", null)
      bucket_prefix = lookup(access_logs.value, "bucket_prefix", null)
      interval      = lookup(access_logs.value, "interval", null)
    }
  }

  # Run the ELB in TCP passthrough mode
  listener {
    lb_port           = var.lb_port
    lb_protocol       = "SSL"
    instance_port     = var.nomad_api_port
    instance_protocol = "TCP"
    ssl_certificate_id = var.acm_arn
  }

  health_check {
    target              = "${var.health_check_protocol}:${var.health_check_port == 0 ? var.nomad_api_port : var.health_check_port}${var.health_check_path}"
    interval            = var.health_check_interval
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
  }

  tags = merge(
    var.load_balancer_tags,
    {
      "Name" = var.name
    },
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH THE ELB TO THE NOMAD ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_autoscaling_attachment" "nomad-servers" {
  autoscaling_group_name = var.nomad_asg_name
  elb                    = aws_elb.nomad-servers.id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT CONTROLS WHAT TRAFFIC CAN GO IN AND OUT OF THE ELB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "nomad-servers" {
  name        = "${var.name}-elb"
  description = "Security group for the ${var.name} ELB"
  vpc_id      = var.vpc_id

  tags = var.security_group_tags
}

resource "aws_security_group_rule" "allow_inbound_nomad_api" {
  type        = "ingress"
  from_port   = var.lb_port
  to_port     = var.nomad_api_port
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nomad-servers.id
}

resource "aws_security_group_rule" "allow_all_nomad_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nomad-servers.id
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONALLY CREATE A ROUTE 53 ENTRY FOR THE ELB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route53_record" "nomad_elb" {
  count = var.create_dns_entry ? 1 : 0

  zone_id = var.hosted_zone_id
  name    = "${var.nomad_domain_name}"
  type    = "A"

  alias {
    name    = aws_elb.nomad-servers.dns_name
    zone_id = aws_elb.nomad-servers.zone_id

    # When set to true, if either none of the ELB's EC2 instances are healthy or the ELB itself is unhealthy,
    # Route 53 routes queries to "other resources." But since we haven't defined any other resources, we'd rather
    # avoid any latency due to switchovers and just wait for the ELB and Vault instances to come back online.
    # For more info, see http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-values-alias.html#rrsets-values-alias-evaluate-target-health
    evaluate_target_health = false
  }
}