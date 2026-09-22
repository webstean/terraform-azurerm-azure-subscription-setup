# Builds an AzCopy runner entirely within ACR. The Dockerfile and task YAML
# are Terraform locals so no external Git context or access token is required.
locals {
  ## Environment variables:
  ##   AZCOPY_MSI_CLIENT_ID must be defined
  ##   SOURCE_URL must be defined, can be Blob or Azure Files
  ##   DESTINATION_URL must be defined can be Blob or Azure Files
  azcopy_entrypoint_script = <<-BASH
#!/usr/bin/env bash
set -euo pipefail
echo "Copying files with AzCopy..."
if [ -z "$${AZCOPY_MSI_CLIENT_ID:-}" ]; then
  echo "Environment variable: AZCOPY_MSI_CLIENT_ID is not set"
  exit 1
fi
if [ -z "$${SOURCE_URL:-}" ]; then
  echo "Environment variable: SOURCE_URL is not set"
  exit 1
fi
if [ -z "$${DESTINATION_URL:-}" ]; then
  echo "Environment variable: DESTINATION_URL is not set"
  exit 1
fi
echo "Source URL          : $${SOURCE_URL}"
echo "Destination URL     : $${DESTINATION_URL}"
echo "with MSI Client ID  : $${AZCOPY_MSI_CLIENT_ID}"
exec azcopy "$@"
BASH

  azcopy_dockerfile = <<-DOCKERFILE
ARG BASE_IMAGE=mcr.microsoft.com/azurelinux/base/core:3.0
FROM $${BASE_IMAGE}
RUN tdnf install -y ca-certificates azcopy && tdnf clean all
ENV AZCOPY_AUTO_LOGIN_TYPE=MSI
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
DOCKERFILE

  azcopy_task_yaml = yamlencode({
    version = "v1.1.0"
    steps = [
      {
        cmd = "bash -c \"printf '%s' '${base64encode(trimspace(local.azcopy_entrypoint_script))}' | base64 --decode > entrypoint.sh\""
      },
      {
        cmd = "bash -c \"printf '%s' '${base64encode(trimspace(local.azcopy_dockerfile))}' | base64 --decode > Dockerfile\""
      },
      {
        build = "-t azcopy-runner:{{.Run.ID}} -t azcopy-runner:latest -f Dockerfile ."
      },
      {
        push = ["azcopy-runner:{{.Run.ID}}", "azcopy-runner:latest"]
      }
    ]
  })
}
resource "azurerm_container_registry_task" "azcopy_build" {
  name                  = "build-azcopy-runner"
  container_registry_id = module.containerregistry.resource_id

  enabled = true
  identity {
    type = "UserAssigned"
    identity_ids = [
      module.global_user_managed_identity.resource_id
    ]
  }

  platform {
    os = "Linux"
  }

  encoded_step {
    task_content = base64encode(local.azcopy_task_yaml)
  }

  # Rebuild weekly on Sunday at 00:00 UTC to pick up base-image and package updates.
  timer_trigger {
    name     = "weekly-azcopy-runner-build"
    schedule = "0 0 * * 0"
    enabled  = true
  }

  timeout_in_seconds = 900
  tags               = { for key, value in module.global_resource_group.resource.tags : key => value if lower(key) != "created" }
}

resource "azurerm_role_assignment" "azcopy_build_acr_push" {
  scope                = module.containerregistry.resource_id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_container_registry_task.azcopy_build.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

# Changes on every plan so the immediate-run resource is recreated on every apply.
resource "terraform_data" "azcopy_build_apply_trigger" {
  triggers_replace = [timestamp()]
}

# Triggers a build on every Terraform apply.
resource "azurerm_container_registry_task_schedule_run_now" "azcopy_build_now" {
  container_registry_task_id = azurerm_container_registry_task.azcopy_build.id

  depends_on = [azurerm_role_assignment.azcopy_build_acr_push]

  lifecycle {
    replace_triggered_by = [terraform_data.azcopy_build_apply_trigger]
  }
}

