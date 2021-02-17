resource "azurerm_databricks_workspace" "databricksWokspace" {
  name                = "${var.suffix}${var.workspaceName}"
  resource_group_name = azurerm_resource_group.genericRG.name
  location            = azurerm_resource_group.genericRG.location
  sku                 = "trial"

  custom_parameters {
    virtual_network_id  = azurerm_virtual_network.genericVNet.id
    private_subnet_name = azurerm_subnet.dbSubnets["privateDB"].name
    public_subnet_name  = azurerm_subnet.dbSubnets["publicDB"].name
    no_public_ip        = false
  }

  tags = var.tags
}

# You can uncomment this block in order to build the databricks specific resources
# It is recommended to have the workspace ready before running this part of the code.
# Sometimes the workspace takes time to come up online and this section will fail if it is not ready.

/*
provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.databricksWokspace.id
}

data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}
# Create Databricks Cluster
resource "databricks_cluster" "shared_autoscaling" {
  cluster_name            = "Shared Autoscaling"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 25
  autoscale {
    min_workers = 1
    max_workers = 2
  }
}


# Create initial Databricks notebook
resource "databricks_notebook" "ddl" {
  source = "../notebooks/tfms.py"
  path   = "/Shared/TFMS"
}
*/
