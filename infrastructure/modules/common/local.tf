locals {
  name_format = join("-", [
    "gitpod",
    "%s", # region
    "%s", # name
    local.workspace_name
  ])
  name_format_global = join("-", [
    "gitpod",
    "%s", # name
    local.workspace_name
  ])
  node_labels = tomap({
    workload_meta : "gitpod.io/workload_meta"
    workload_ide : "gitpod.io/workload_ide"
    workspace_services : "gitpod.io/workload_services"
    workspace_regular : "gitpod.io/workload_workspace_regular"
    workspace_headless : "gitpod.io/workload_workspace_headless"
  })
  workspace_name = replace(terraform.workspace, "/[\\W\\-]/", "") # alphanumeric workspace name
}
