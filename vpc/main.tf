locals {
  ec2_prefix_entries = flatten([
    for prefix_list in var.ec2_managed_prefix_list_entries : {
      address_family = prefix_list.address_family
      max_entries    = prefix_list.max_entries
      name           = prefix_list.name
      entry          = prefix_list.entry
    }
  ])
}

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

resource "aws_default_route_table" "this" {
  count                  = var.vpc_manage_default_route_table ? 1 : 0
  default_route_table_id = aws_vpc.this.default_route_table_id
  propagating_vgws       = var.vpc_default_route_table_propagating_vgws

  dynamic "route" {
    for_each = var.vpc_default_route_table_route

    content {
      # One of the following must be specified 
      cidr_block                 = lookup(route.value, "cidr_block", null)
      ipv6_cidr_block            = lookup(route.value, "ipv6_ciodr_block", null)
      destination_prefix_list_id = lookup(route.value, "destination_prefix_list_id", null)

      # The following parameters are optional
      core_network_arn          = lookup(route.value, "core_network_arn", null)
      egress_only_gateway_id    = lookup(route.value, "egress_only_gateway_id", null)
      gateway_id                = lookup(route.value, "gateway_id", null)
      instance_id               = lookup(route.value, "instance_id", null)
      nat_gateway_id            = lookup(route.value, "nat_gateway_id", null)
      network_interface_id      = lookup(route.value, "network_interface_id", null)
      transit_gateway_id        = lookup(route.value, "transit_gateway_id", null)
      vpc_endpoint_id           = lookup(route.value, "vpc_endpoint_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = var.tags
}

resource "aws_ec2_managed_prefix_list" "this" {
  count          = var.create_ec2_managed_prefix_list ? length(var.ec2_managed_prefix_list_entries) : 0
  address_family = local.ec2_prefix_entries[count.index]["address_family"]
  max_entries    = local.ec2_prefix_entries[count.index]["max_entries"]
  name           = local.ec2_prefix_entries[count.index]["name"]

  dynamic "entry" {
    for_each = local.ec2_prefix_entries[count.index]["entry"]

    content {
      cidr        = entry.value["cidr"]
      description = lookup(entry.value, "description", null)
    }
  }
  tags = var.tags
}