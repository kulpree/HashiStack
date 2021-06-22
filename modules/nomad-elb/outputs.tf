output "load_balancer_name" {
  value = aws_elb.nomad-servers.name
}

output "load_balancer_dns_name" {
  value = aws_elb.nomad-servers.dns_name
}

output "load_balancer_zone_id" {
  value = aws_elb.nomad-servers.zone_id
}

output "load_balancer_security_group_id" {
  value = aws_security_group.nomad-servers.id
}

output "fully_qualified_domain_name" {
  value = element(concat(aws_route53_record.nomad_elb.*.fqdn, [""]), 0)
}

