variable "vpc_cidr_block" {
  description = "The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using ipv4_netmask_length."
  type        = string
  default     = null
}

variable "vpc_instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC. Default is default, which ensures that EC2 instances launched in this VPC use the EC2 instance tenancy attribute specified when the EC2 instance is launched. The only other option is dedicated, which ensures that EC2 instances launched in this VPC are run on dedicated tenancy instances regardless of the tenancy attribute specified at launch. This has a dedicated per region fee of $2 per hour, plus an hourly per instance usage fee."
  type        = string
  default     = "default"
}

variable "vpc_ipv4_ipam_pool_id" {
  description = "The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR. IPAM is a VPC feature that you can use to automate your IP address management workflows including assigning, tracking, troubleshooting, and auditing IP addresses across AWS Regions and accounts. Using IPAM you can monitor IP address usage throughout your AWS Organization."
  type        = string
  default     = null
}

variable "vpc_ipv4_netmask_length" {
  description = "The netmask length of the IPv4 CIDR you want to allocate to this VPC. Requires specifying a ipv4_ipam_pool_id."
  type        = number
  default     = null
}

variable "vpc_ipv6_cidr_block" {
  description = "IPv6 CIDR block to request from an IPAM Pool. Can be set explicitly or derived from IPAM using ipv6_netmask_length."
  type        = string
  default     = null
}

variable "vpc_ipv6_ipam_pool_id" {
  description = "IPAM Pool ID for a IPv6 pool. Conflicts with assign_generated_ipv6_cidr_block."
  type        = string
  default     = null
}

variable "vpc_ipv6_netmask_length" {
  description = "Netmask length to request from IPAM Pool. Conflicts with ipv6_cidr_block. This can be omitted if IPAM pool as a allocation_default_netmask_length set. Valid values: 56."
  type        = number
  default     = null
}

variable "vpc_ipv6_cidr_block_network_border_group" {
  description = "By default when an IPv6 CIDR is assigned to a VPC a default ipv6_cidr_block_network_border_group will be set to the region of the VPC. This can be changed to restrict advertisement of public addresses to specific Network Border Groups such as LocalZones."
  type        = string
  default     = null
}

variable "vpc_enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  type        = bool
  default     = true
}

variable "vpc_enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  type        = bool
  default     = false
}

variable "vpc_assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block. Default is false. Conflicts with ipv6_ipam_pool_id."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  type        = map(string)
}

variable "manage_vpc_default_network_acl" {
  description = "Whether to update the default Nentwork ACL."
  type        = bool
  default     = false
}

variable "vpc_default_network_acl_ingress" {
  description = "A list of configuration blocks for default Network ACL ingress rules."
  type        = any
  default     = []
}

variable "vpc_default_network_acl_egress" {
  description = "A list of configuration blocks for default Network ACL egress rules."
  type        = any
  default     = []
}

variable "vpc_manage_default_route_table" {
  description = "Whether to manage the default VPC route table."
  type        = bool
  default     = false
}

variable "vpc_default_route_table_propagating_vgws" {
  description = "List of virtual gateways for propagation."
  type        = list(string)
  default     = null
}

variable "vpc_default_route_table_route" {
  description = "Configuration block of routes. This argument is processed in attribute-as-blocks mode. This means that omitting this argument is interpreted as ignoring any existing routes. To remove all managed routes an empty list should be specified."
  type        = list(map(string))
  default     = []
}

variable "create_ec2_managed_prefix_list" {
  description = "Whether to create one or more EC2 mannaged prefix lists."
  type        = bool
  default     = false
}

variable "ec2_managed_prefix_list_entries" {
  description = "A map of list of map that includes the folliwng EC2 prefix list parameters: address_family, max_entries, name, and entries."
  type = list(object({
    address_family = string
    max_entries    = number
    name           = string
    entry = list(object({
      cidr        = string
      description = string
    }))
  }))
  default = []
}