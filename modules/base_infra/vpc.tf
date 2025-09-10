# =============================================================================
# VPC AND NETWORKING CONFIGURATION
# =============================================================================
# Creates a secure, isolated network environment for Databricks clusters
# Uses AWS VPC module for best practices and standard configurations

# Get all available zones in the region for high availability
data "aws_availability_zones" "available" {}

# Create VPC with public and private subnets across multiple AZs
# This provides the network foundation for Databricks workspace
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"  # Official AWS VPC module
  version = "5.7.0"                          # Pinned version for reproducibility

  # Basic VPC Configuration
  name = var.prefix                          # VPC name using consistent prefix
  cidr = var.cidr_block                      # IP range for the entire VPC
  azs  = data.aws_availability_zones.available.names  # Use all available AZs
  tags = local.common_tags                   # Apply consistent tagging

  # DNS Configuration - Required for Databricks
  enable_dns_hostnames = true               # Enable DNS resolution for instances
  enable_nat_gateway   = true               # NAT for private subnet internet access
  single_nat_gateway   = true               # Cost optimization: one NAT for all private subnets
  create_igw           = true               # Internet Gateway for public subnet

  # Subnet Design for Databricks
  # Public subnet (1): For NAT Gateway and load balancers
  public_subnets = [cidrsubnet(var.cidr_block, 3, 0)]  # /19 subnet (8,192 IPs)
  
  # Private subnets (2): For Databricks clusters - enhances security
  private_subnets = [
    cidrsubnet(var.cidr_block, 3, 1),       # /19 subnet in AZ 1
    cidrsubnet(var.cidr_block, 3, 2)        # /19 subnet in AZ 2
  ]

  # Security Group Management
  manage_default_security_group = true      # Let Terraform manage the default SG
  default_security_group_name   = "${var.prefix}-sg"  # Consistent naming

  # Outbound Rules: Allow all outbound traffic
  # Databricks clusters need internet access for:
  # - Downloading libraries and packages
  # - Accessing external data sources
  # - Connecting to Databricks control plane
  default_security_group_egress = [{
    cidr_blocks = "0.0.0.0/0"              # Allow all outbound traffic
  }]

  # Inbound Rules: Restrict to essential Databricks communication
  # Follow principle of least privilege while enabling Databricks functionality
  default_security_group_ingress = [
    {
      description = "HTTPS - Secure web traffic and API calls"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      self        = true                    # Only from within same security group
    },
    {
      description = "Databricks cluster communication - Internal cluster coordination"
      from_port   = 8443                   # Databricks internal communication range
      to_port     = 8451                   # Covers all required internal ports
      protocol    = "tcp"
      self        = true                    # Only between cluster nodes
    },
    {
      description = "SSH - Administrative access and debugging"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      self        = true                    # Only from within security group
    },
    {
      description = "HTTP - Basic web traffic (redirects to HTTPS)"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      self        = true                    # Only within security group
    }
  ]
}

# =============================================================================
# VPC ENDPOINTS - COST OPTIMIZATION AND SECURITY
# =============================================================================
# VPC endpoints allow private connectivity to AWS services without internet routing
# Benefits: Lower costs, improved security, reduced latency

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.7.0"

  vpc_id             = module.vpc.vpc_id                    # Attach to our VPC
  security_group_ids = [module.vpc.default_security_group_id]  # Use VPC security group

  endpoints = {
    # S3 Gateway Endpoint - Critical for Databricks data access
    # Gateway endpoints are free and handle high-throughput data transfers
    s3 = {
      service      = "s3"
      service_type = "Gateway"                              # No hourly charges
      route_table_ids = flatten([
        module.vpc.private_route_table_ids,                # Route private subnet traffic
        module.vpc.public_route_table_ids                  # Route public subnet traffic
      ])
      tags = {
        Name = "${var.prefix}-s3-vpc-endpoint"
      }
      # Use case: All S3 data access (DBFS, data lakes, logs) stays within AWS network
    },
    
    # STS Interface Endpoint - AWS Security Token Service
    # Required for IAM role assumptions and temporary credentials
    sts = {
      service             = "sts"
      private_dns_enabled = true                           # Enable DNS resolution
      subnet_ids          = module.vpc.private_subnets     # Deploy in private subnets
      tags = {
        Name = "${var.prefix}-sts-vpc-endpoint"
      }
      # Use case: Cluster IAM role assumptions, temporary credential generation
    },
    
    # Kinesis Streams Endpoint - For streaming data integration
    # Used when Databricks integrates with Kinesis for real-time processing
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name = "${var.prefix}-kinesis-vpc-endpoint"
      }
      # Use case: Real-time data ingestion, streaming analytics
    },
    
    # EC2 Endpoint - Instance management and metadata
    # Used for cluster lifecycle management and EC2 operations
    ec2 = {
      service             = "ec2"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name = "${var.prefix}-ec2-vpc-endpoint"
      }
      # Use case: Cluster provisioning, instance metadata, EBS operations
    },
    
    # Elastic Load Balancing Endpoint - For cluster load balancing
    # Used when Databricks manages load balancers for cluster access
    elasticloadbalancing = {
      service             = "elasticloadbalancing"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name = "${var.prefix}-elb-vpc-endpoint"
      }
      # Use case: Internal load balancing, cluster proxy management
    },
    
    # CloudWatch Logs Endpoint - For centralized logging
    # Enables private connectivity for log shipping and monitoring
    logs = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name = "${var.prefix}-logs-vpc-endpoint"
      }
      # Use case: Cluster logs, application logs, audit trails
    },
  }

  tags = local.common_tags
  
  # Cost Optimization Notes:
  # - Gateway endpoints (S3) are free
  # - Interface endpoints have hourly charges (~$7.20/month each)
  # - Saves NAT Gateway data transfer costs (especially for S3)
  # - Improves security by keeping traffic within AWS network
}
