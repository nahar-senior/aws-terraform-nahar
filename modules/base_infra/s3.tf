# =============================================================================
# S3 ROOT STORAGE BUCKET FOR DATABRICKS
# =============================================================================
# This bucket serves as the primary storage location for the Databricks workspace
# Contains: DBFS root, cluster logs, temporary files, and optionally Unity Catalog data

# Create the S3 bucket for Databricks root storage
# This bucket is essential for workspace functionality
resource "aws_s3_bucket" "root_storage_bucket" {
  bucket        = "${var.prefix}-rootbucket"     # Consistent naming with prefix
  force_destroy = true                           # Allow deletion even with contents (for dev/test)
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-rootbucket"            # Human-readable name
  })
  
  # Contents include:
  # - /dbfs/: Databricks File System root storage
  # - /cluster-logs/: Cluster initialization and driver logs
  # - /pipelines/: Delta Live Tables temporary storage
  # - /unity-catalog/: Unity Catalog metadata (if configured)
}

# Disable versioning for cost optimization
# Databricks manages its own file lifecycle and versioning
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.root_storage_bucket.id
  versioning_configuration {
    status = "Disabled"                          # Reduces storage costs
  }
  
  # Note: Can be enabled later if compliance requires object versioning
  # Consider lifecycle policies for cost management if enabled
}

# Enable server-side encryption for data security
# Protects data at rest using AWS-managed encryption keys
resource "aws_s3_bucket_server_side_encryption_configuration" "root_storage_bucket" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"                   # AWS-managed encryption (no additional cost)
    }
  }
  
  # Security Best Practice: Encrypts all objects stored in the bucket
  # Alternative: Use "aws:kms" with customer-managed keys for enhanced control
}

# Block all public access for security
# Databricks accesses the bucket via cross-account IAM role (never public)
resource "aws_s3_bucket_public_access_block" "root_storage_bucket" {
  bucket                  = aws_s3_bucket.root_storage_bucket.id
  block_public_acls       = true                # Block public ACLs
  block_public_policy     = true                # Block public bucket policies
  ignore_public_acls      = true                # Ignore existing public ACLs
  restrict_public_buckets = true                # Restrict public bucket policies
  depends_on              = [aws_s3_bucket.root_storage_bucket]
  
  # Security Best Practice: This ensures the bucket can never be made public
  # Databricks only needs private access via the cross-account role
}

# Fetch Databricks-managed bucket policy for workspace access
# This policy allows Databricks to read/write data in the root storage bucket
data "databricks_aws_bucket_policy" "this" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket
  
  # This generates a policy that allows the cross-account role to:
  # - List objects in the bucket
  # - Get objects from the bucket
  # - Put objects into the bucket
  # - Delete objects from the bucket
}

# Apply the Databricks bucket policy to enable workspace access
# This completes the S3 configuration required for Databricks functionality
resource "aws_s3_bucket_policy" "root_bucket_policy" {
  bucket     = aws_s3_bucket.root_storage_bucket.id
  policy     = data.databricks_aws_bucket_policy.this.json  # Databricks-managed policy
  depends_on = [aws_s3_bucket_public_access_block.root_storage_bucket]
  
  # This policy enables Databricks to:
  # - Store and retrieve DBFS data
  # - Write cluster logs and temporary files
  # - Manage workspace-specific storage needs
  # - Access Unity Catalog data (if configured)
}
