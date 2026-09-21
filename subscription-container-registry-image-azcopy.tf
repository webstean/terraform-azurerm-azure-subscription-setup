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
if [ -z "$${AZCOPY_MSI_CLIENT_ID + x}" ]; then
  echo "Environment variable: AZCOPY_MSI_CLIENT_ID is not set"
  exit 1
fi
if [ -z "$${SOURCE_URL + x}" ]; then
  echo "Environment variable: SOURCE_URL is not set"
  exit 1
fi
if [ -z "$${DESTINATION_URL + x}" ]; then
  echo "Environment variable: DESTINATION_URL is not set"
  exit 1
fi
echo "Copying files with AzCopy..."
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
        cmd = "printf '%s' '${base64encode(trimspace(local.azcopy_entrypoint_script))}' | base64 --decode > entrypoint.sh"
      },
      {
        cmd = "printf '%s' '${base64encode(trimspace(local.azcopy_dockerfile))}' | base64 --decode > Dockerfile"
      },
      {
        build = "-t azcopy-runner:{{.Run.ID}} -t azcopy-runner:latest -f Dockerfile ."
      }
    ]
  })
}
resource "azurerm_container_registry_task" "azcopy_build" {
  name                  = "build-azcopy-runner"
  container_registry_id = module.containerregistry.resource_id

  platform {
    os = "Linux"
  }

  encoded_step {
    task_content = base64encode(local.azcopy_task_yaml)
  }

  timeout_in_seconds = 900
}
# Triggers a build when the task content changes. Re-run manually with:
# `terraform apply -replace=azurerm_container_registry_task_schedule_run_now.azcopy_build_now`
resource "azurerm_container_registry_task_schedule_run_now" "azcopy_build_now" {
  container_registry_task_id = azurerm_container_registry_task.azcopy_build.id
}

