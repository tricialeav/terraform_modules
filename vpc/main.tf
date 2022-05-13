resource "aws_vpc" "this" {
  cidr_block                           = var.vpc_cidr_block
  instance_tenancy                     = var.vpc_instance_tenancy
  ipv4_ipam_pool_id                    = var.vpc_ipv4_ipam_pool_id
  ipv4_netmask_length                  = var.vpc_ipv4_netmask_length
  ipv6_cidr_block                      = var.vpc_ipv6_cidr_block
  ipv6_ipam_pool_id                    = var.vpc_ipv6_ipam_pool_id
  ipv6_netmask_length                  = var.vpc_ipv6_netmask_length
  ipv6_cidr_block_network_border_group = var.vpc_ipv6_cidr_block_network_border_group
  enable_dns_support                   = var.vpc_enable_dns_support
  enable_dns_hostnames                 = var.vpc_enable_dns_hostnames
  assign_generated_ipv6_cidr_block     = var.vpc_assign_generated_ipv6_cidr_block
  tags                                 = var.tags
}

resource "aws_default_network_acl" "this" {
  count                  = var.manage_vpc_default_network_acl ? 1 : 0
  default_network_acl_id = aws_vpc.this.default_network_acl_id

  dynamic "ingress" {
    for_each = var.vpc_default_network_acl_ingress

    content {
      action    = ingress.value["action"]
      from_port = ingress.value["from_port"]
      protocol  = ingress.value["protocol"]
      rule_no   = ingress.value["rule_no"]
      to_port   = ingress.value["to_port"]
      # Optional Values
      cidr_block      = lookup(ingress.value, "cidr_block", null)
      icmp_code       = lookup(ingress.value, "icmp_code", null)
      icmp_type       = lookup(ingress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(ingress.value, "ipv6_cidr_block", null)
    }
  }

  dynamic "egress" {
    for_each = var.vpc_default_network_acl_egress

    content {
      action    = egress.value["action"]
      from_port = egress.value["from_port"]
      protocol  = egress.value["protocol"]
      rule_no   = egress.value["rule_no"]
      to_port   = egress.value["to_port"]
      # Optional Values
      cidr_block      = lookup(egress.value, "cidr_block", null)
      icmp_code       = lookup(egress.value, "icmp_code", null)
      icmp_type       = lookup(egress.value, "icmp_type", null)
      ipv6_cidr_block = lookup(egress.value, "ipv6_cidr_block", null)
    }
  }
}