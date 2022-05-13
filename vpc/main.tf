locals {
  ec2_prefix_entries = flatten([
    for prefix_list in var.ec2_managed_prefix_list_entries : {
      address_family = prefix_list.address_family
      max_entries    = prefix_list.max_entries
      name           = prefix_list.name
      entry          = prefix_list.entry
    }
  ])

  public_subnets          = var.subnets["public_subnets"]
  public_subnet_length    = length(local.public_subnets["cidr_blocks"]) > 0 ? length(local.public_subnets["cidr_blocks"]) : length(local.public_subnets["ipv6_cidr_blocks"]) > 0 ? length(local.public_subnets["ipv6_cidr_blocks"]) : 0
  public_subnet_cidr_type = length(local.public_subnets["cidr_blocks"]) > 0 ? "ipv4" : length(local.public_subnets["ipv6_cidr_blocks"]) > 0 ? "ipv6" : null

  private_subnets          = var.subnets["private_subnets"]
  private_subnet_length    = length(local.private_subnets["cidr_blocks"]) > 0 ? length(local.private_subnets["cidr_blocks"]) : length(local.private_subnets["ipv6_cidr_blocks"]) > 0 ? length(local.private_subnets["ipv6_cidr_blocks"]) : 0
  private_subnet_cidr_type = length(local.private_subnets["cidr_blocks"]) > 0 ? "ipv4" : length(local.private_subnets["ipv6_cidr_blocks"]) > 0 ? "ipv6" : null
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

resource "aws_subnet" "public" {
  count                                          = local.public_subnet_length
  cidr_block                                     = local.public_subnet_cidr_type == "ipv4" ? element(local.public_subnets["cidr_blocks"], count.index) : null
  ipv6_cidr_block                                = local.public_subnet_cidr_type == "ipv6" ? element(local.public_subnets["cidr_blocks"], count.index) : null
  availability_zone                              = element(local.public_subnets["availability_zones"], count.index)
  vpc_id                                         = aws_vpc.this.id
  assign_ipv6_address_on_creation                = try(local.public_subnets["assign_ipv6_address_on_creation"], null)
  customer_owned_ipv4_pool                       = try(local.public_subnets["customer_owned_ipv4_pool"], null)
  enable_dns64                                   = try(local.public_subnets["enable_dns64"], null)
  enable_resource_name_dns_aaaa_record_on_launch = try(local.public_subnets["enable_resource_name_dns_aaaa_record_on_launch"], null)
  enable_resource_name_dns_a_record_on_launch    = try(local.public_subnets["enable_resource_name_dns_a_record_on_launch"], null)
  ipv6_native                                    = try(local.public_subnets["ipv6_native"], null)
  map_customer_owned_ip_on_launch                = try(local.public_subnets["map_customer_owned_ip_on_launch"], null)
  map_public_ip_on_launch                        = try(local.public_subnets["map_public_ip_on_launch"], null)
  outpost_arn                                    = try(local.public_subnets["outpost_arn"], null)
  private_dns_hostname_type_on_launch            = try(local.public_subnets["private_dns_hostname_type_on_launch"], null)
  tags                                           = var.tags
}

resource "aws_subnet" "private" {
  count                                          = local.private_subnet_length
  cidr_block                                     = local.private_subnet_cidr_type == "ipv4" ? element(local.private_subnets["cidr_blocks"], count.index) : null
  ipv6_cidr_block                                = local.private_subnet_cidr_type == "ipv6" ? element(local.private_subnets["cidr_blocks"], count.index) : null
  availability_zone                              = element(local.private_subnets["availability_zones"], count.index)
  vpc_id                                         = aws_vpc.this.id
  assign_ipv6_address_on_creation                = try(local.private_subnets["assign_ipv6_address_on_creation"], null)
  customer_owned_ipv4_pool                       = try(local.private_subnets["customer_owned_ipv4_pool"], null)
  enable_dns64                                   = try(local.private_subnets["enable_dns64"], null)
  enable_resource_name_dns_aaaa_record_on_launch = try(local.private_subnets["enable_resource_name_dns_aaaa_record_on_launch"], null)
  enable_resource_name_dns_a_record_on_launch    = try(local.private_subnets["enable_resource_name_dns_a_record_on_launch"], null)
  ipv6_native                                    = try(local.private_subnets["ipv6_native"], null)
  map_customer_owned_ip_on_launch                = try(local.private_subnets["map_customer_owned_ip_on_launch"], null)
  map_public_ip_on_launch                        = try(local.private_subnets["map_public_ip_on_launch"], null)
  outpost_arn                                    = try(local.private_subnets["outpost_arn"], null)
  private_dns_hostname_type_on_launch            = try(local.private_subnets["private_dns_hostname_type_on_launch"], null)
  tags                                           = var.tags
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

resource "aws_egress_only_internet_gateway" "this" {
  count  = var.create_egress_only_internet_gateway && var.vpc_ipv6_cidr_block != null ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}

resource "aws_internet_gateway" "this" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}