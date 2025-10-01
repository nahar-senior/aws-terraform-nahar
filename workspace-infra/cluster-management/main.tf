# Unity Catalog enabled interactive cluster
resource "databricks_cluster" "interactive" {
  cluster_name            = "${var.prefix}-interactive-cluster"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id           = var.node_type_id
  driver_node_type_id    = var.driver_node_type_id
  autotermination_minutes = var.autotermination_minutes
  
  # Unity Catalog requires data security mode
  data_security_mode = "SINGLE_USER"
  
  autoscale {
    min_workers = var.min_workers
    max_workers = var.max_workers
  }

  # Unity Catalog compatible Spark configuration
  spark_conf = {
    "spark.databricks.delta.preview.enabled" = "true"
    "spark.databricks.delta.merge.enabled"   = "true"
  }

  custom_tags = var.tags
}

# Get latest LTS Databricks Runtime
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}
