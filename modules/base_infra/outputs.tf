# =============================================================================
# BASE INFRASTRUCTURE MODULE OUTPUTS
# =============================================================================
# These outputs provide essential infrastructure identifiers for other modules
# and external integrations

output "security_group_ids" {
  value       = [module.vpc.default_security_group_id]
  description = "Security group IDs - control network traffic for Databricks"
  
  # Security groups define:
  # - Inbound rules for SSH, HTTPS, and Databricks communication
  # - Outbound rules for internet access
  # - Inter-cluster communication rules
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the VPC - used by workspace module for network configuration"
  
  # Used for:
  # - Databricks network configuration
  # - Additional security group references
  # - VPC peering connections
}

output "subnets" {
  value       = module.vpc.private_subnets
  description = "Private subnet IDs - where Databricks clusters will be deployed"
  
  # These subnets provide:
  # - Network isolation for cluster security
  # - Multi-AZ deployment for high availability
  # - Private connectivity with internet access via NAT Gateway
}

output "vpc_main_route_table_id" {
  value       = module.vpc.vpc_main_route_table_id
  description = "ID for the main route table associated with this VPC"
  
  # Used for:
  # - Additional route configurations
  # - Network troubleshooting
  # - Custom routing requirements
}

output "private_route_table_ids" {
  value       = module.vpc.private_route_table_ids
  description = "IDs for the private route tables associated with this VPC"
  
  # These route tables contain:
  # - Routes to NAT Gateway for internet access
  # - Local VPC routes for internal communication
  # - VPC endpoint routes for AWS service access
}

output "root_bucket" {
  value       = aws_s3_bucket.root_storage_bucket.bucket
  description = "S3 bucket name for Databricks root storage - primary workspace storage"
  
  # This bucket contains:
  # - DBFS (Databricks File System) data
  # - Cluster logs and temporary files
  # - Optional Unity Catalog metadata storage
}

output "cross_account_role_arn" {
  value       = aws_iam_role.cross_account_role.arn
  description = "ARN of the cross-account IAM role - enables Databricks AWS access"
  depends_on  = [resource.aws_iam_role_policy.this]
  
  # This role allows Databricks to:
  # - Provision and manage EC2 instances
  # - Access S3 for data storage operations
  # - Manage networking and security components
  # - Perform required AWS API operations
}
