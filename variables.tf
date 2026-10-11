variable "gke_backup_restore_plans" {
  description = <<EOT
Map of gke_backup_restore_plans, attributes below
Required:
    - backup_plan
    - cluster
    - location
    - name
    - restore_config (block):
        - all_namespaces (optional)
        - cluster_resource_conflict_policy (optional)
        - cluster_resource_restore_scope (optional, block):
            - all_group_kinds (optional)
            - excluded_group_kinds (optional, block):
                - resource_group (optional)
                - resource_kind (optional)
            - no_group_kinds (optional)
            - selected_group_kinds (optional, block):
                - resource_group (optional)
                - resource_kind (optional)
        - excluded_namespaces (optional, block):
            - namespaces (required)
        - namespaced_resource_restore_mode (optional)
        - no_namespaces (optional)
        - restore_order (optional, block):
            - group_kind_dependencies (required, block):
                - requiring (required, block):
                    - resource_group (optional)
                    - resource_kind (optional)
                - satisfying (required, block):
                    - resource_group (optional)
                    - resource_kind (optional)
        - selected_applications (optional, block):
            - namespaced_names (required, block):
                - name (required)
                - namespace (required)
        - selected_namespaces (optional, block):
            - namespaces (required)
        - transformation_rules (optional, block):
            - description (optional)
            - field_actions (required, block):
                - from_path (optional)
                - op (required)
                - path (optional)
                - value (optional)
            - resource_filter (optional, block):
                - group_kinds (optional, block):
                    - resource_group (optional)
                    - resource_kind (optional)
                - json_path (optional)
                - namespaces (optional)
        - volume_data_restore_policy (optional)
        - volume_data_restore_policy_bindings (optional, block):
            - policy (required)
            - volume_type (required)
Optional:
    - deletion_policy
    - description
    - labels
    - project
    - timeouts (block):
        - create (optional)
        - delete (optional)
        - update (optional)
EOT

  type = map(object({
    backup_plan     = string
    cluster         = string
    location        = string
    name            = string
    deletion_policy = optional(string)
    description     = optional(string)
    labels          = optional(map(string))
    project         = optional(string)
    restore_config = object({
      all_namespaces                   = optional(bool)
      cluster_resource_conflict_policy = optional(string)
      cluster_resource_restore_scope = optional(object({
        all_group_kinds = optional(bool)
        excluded_group_kinds = optional(list(object({
          resource_group = optional(string)
          resource_kind  = optional(string)
        })))
        no_group_kinds = optional(bool)
        selected_group_kinds = optional(list(object({
          resource_group = optional(string)
          resource_kind  = optional(string)
        })))
      }))
      excluded_namespaces = optional(object({
        namespaces = list(string)
      }))
      namespaced_resource_restore_mode = optional(string)
      no_namespaces                    = optional(bool)
      restore_order = optional(object({
        group_kind_dependencies = list(object({
          requiring = object({
            resource_group = optional(string)
            resource_kind  = optional(string)
          })
          satisfying = object({
            resource_group = optional(string)
            resource_kind  = optional(string)
          })
        }))
      }))
      selected_applications = optional(object({
        namespaced_names = list(object({
          name      = string
          namespace = string
        }))
      }))
      selected_namespaces = optional(object({
        namespaces = list(string)
      }))
      transformation_rules = optional(list(object({
        description = optional(string)
        field_actions = list(object({
          from_path = optional(string)
          op        = string
          path      = optional(string)
          value     = optional(string)
        }))
        resource_filter = optional(object({
          group_kinds = optional(list(object({
            resource_group = optional(string)
            resource_kind  = optional(string)
          })))
          json_path  = optional(string)
          namespaces = optional(list(string))
        }))
      })))
      volume_data_restore_policy = optional(string)
      volume_data_restore_policy_bindings = optional(list(object({
        policy      = string
        volume_type = string
      })))
    })
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
  }))
  validation {
    condition = alltrue([
      for k, v in var.gke_backup_restore_plans : (
        v.restore_config.restore_order == null || (length(v.restore_config.restore_order.group_kind_dependencies) >= 1)
      )
    ])
    error_message = "Each group_kind_dependencies list must contain at least 1 items"
  }
  validation {
    condition = alltrue([
      for k, v in var.gke_backup_restore_plans : (
        v.restore_config.selected_applications == null || (length(v.restore_config.selected_applications.namespaced_names) >= 1)
      )
    ])
    error_message = "Each namespaced_names list must contain at least 1 items"
  }
  validation {
    condition = alltrue([
      for k, v in var.gke_backup_restore_plans : (
        v.restore_config.transformation_rules == null || alltrue([for item in v.restore_config.transformation_rules : (length(item.field_actions) >= 1)])
      )
    ])
    error_message = "Each field_actions list must contain at least 1 items"
  }
  # Note: 6 additional provider-side validators are enforced at apply time but not mirrored as validation{} blocks here (bespoke or non-mechanically-translatable).
}

