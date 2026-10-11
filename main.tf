resource "google_gke_backup_restore_plan" "gke_backup_restore_plans" {
  for_each = var.gke_backup_restore_plans

  backup_plan     = each.value.backup_plan
  cluster         = each.value.cluster
  location        = each.value.location
  name            = each.value.name
  deletion_policy = each.value.deletion_policy
  description     = each.value.description
  labels          = each.value.labels
  project         = each.value.project

  restore_config {
    all_namespaces                   = each.value.restore_config.all_namespaces
    cluster_resource_conflict_policy = each.value.restore_config.cluster_resource_conflict_policy
    dynamic "cluster_resource_restore_scope" {
      for_each = each.value.restore_config.cluster_resource_restore_scope != null ? [each.value.restore_config.cluster_resource_restore_scope] : []
      content {
        all_group_kinds = cluster_resource_restore_scope.value.all_group_kinds
        dynamic "excluded_group_kinds" {
          for_each = cluster_resource_restore_scope.value.excluded_group_kinds != null ? cluster_resource_restore_scope.value.excluded_group_kinds : []
          content {
            resource_group = excluded_group_kinds.value.resource_group
            resource_kind  = excluded_group_kinds.value.resource_kind
          }
        }
        no_group_kinds = cluster_resource_restore_scope.value.no_group_kinds
        dynamic "selected_group_kinds" {
          for_each = cluster_resource_restore_scope.value.selected_group_kinds != null ? cluster_resource_restore_scope.value.selected_group_kinds : []
          content {
            resource_group = selected_group_kinds.value.resource_group
            resource_kind  = selected_group_kinds.value.resource_kind
          }
        }
      }
    }
    dynamic "excluded_namespaces" {
      for_each = each.value.restore_config.excluded_namespaces != null ? [each.value.restore_config.excluded_namespaces] : []
      content {
        namespaces = excluded_namespaces.value.namespaces
      }
    }
    namespaced_resource_restore_mode = each.value.restore_config.namespaced_resource_restore_mode
    no_namespaces                    = each.value.restore_config.no_namespaces
    dynamic "restore_order" {
      for_each = each.value.restore_config.restore_order != null ? [each.value.restore_config.restore_order] : []
      content {
        dynamic "group_kind_dependencies" {
          for_each = restore_order.value.group_kind_dependencies
          content {
            requiring {
              resource_group = group_kind_dependencies.value.requiring.resource_group
              resource_kind  = group_kind_dependencies.value.requiring.resource_kind
            }
            satisfying {
              resource_group = group_kind_dependencies.value.satisfying.resource_group
              resource_kind  = group_kind_dependencies.value.satisfying.resource_kind
            }
          }
        }
      }
    }
    dynamic "selected_applications" {
      for_each = each.value.restore_config.selected_applications != null ? [each.value.restore_config.selected_applications] : []
      content {
        dynamic "namespaced_names" {
          for_each = selected_applications.value.namespaced_names
          content {
            name      = namespaced_names.value.name
            namespace = namespaced_names.value.namespace
          }
        }
      }
    }
    dynamic "selected_namespaces" {
      for_each = each.value.restore_config.selected_namespaces != null ? [each.value.restore_config.selected_namespaces] : []
      content {
        namespaces = selected_namespaces.value.namespaces
      }
    }
    dynamic "transformation_rules" {
      for_each = each.value.restore_config.transformation_rules != null ? each.value.restore_config.transformation_rules : []
      content {
        description = transformation_rules.value.description
        dynamic "field_actions" {
          for_each = transformation_rules.value.field_actions
          content {
            from_path = field_actions.value.from_path
            op        = field_actions.value.op
            path      = field_actions.value.path
            value     = field_actions.value.value
          }
        }
        dynamic "resource_filter" {
          for_each = transformation_rules.value.resource_filter != null ? [transformation_rules.value.resource_filter] : []
          content {
            dynamic "group_kinds" {
              for_each = resource_filter.value.group_kinds != null ? resource_filter.value.group_kinds : []
              content {
                resource_group = group_kinds.value.resource_group
                resource_kind  = group_kinds.value.resource_kind
              }
            }
            json_path  = resource_filter.value.json_path
            namespaces = resource_filter.value.namespaces
          }
        }
      }
    }
    volume_data_restore_policy = each.value.restore_config.volume_data_restore_policy
    dynamic "volume_data_restore_policy_bindings" {
      for_each = each.value.restore_config.volume_data_restore_policy_bindings != null ? each.value.restore_config.volume_data_restore_policy_bindings : []
      content {
        policy      = volume_data_restore_policy_bindings.value.policy
        volume_type = volume_data_restore_policy_bindings.value.volume_type
      }
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      update = timeouts.value.update
    }
  }
}

