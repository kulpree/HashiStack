output "load_balancer_name" {
  value = aws_elb.consul-servers.name
}

output "load_balancer_dns_name" {
  value = aws_elb.consul-servers.dns_name
}

output "load_balancer_zone_id" {
  value = aws_elb.consul-servers.zone_id
}

output "load_balancer_security_group_id" {
  value = aws_security_group.consul-servers.id
}

output "fully_qualified_domain_name" {
  value = element(concat(aws_route53_record.consul_elb.*.fqdn, [""]), 0)
}

