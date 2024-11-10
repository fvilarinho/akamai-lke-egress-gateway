# Required variables.
locals {
  configurationFilename = abspath(pathexpand("../etc/nginx/conf.d/default.conf"))

  applySettingsScriptFilename = abspath(pathexpand("../bin/applySettings.sh"))
  applyManifestScriptFilename = abspath(pathexpand("../bin/applyManifest.sh"))
  deploymentsManifestFilename = abspath(pathexpand("../etc/deployments.yaml"))
  servicesManifestFilename    = abspath(pathexpand("../etc/services.yaml"))
}

# Applies the settings.
resource "null_resource" "applySettings" {
  # Applies only when the files changed.
  triggers = {
    always_run = filemd5(local.applySettingsScriptFilename)
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG               = local_sensitive_file.clusterKubeconfig.filename
      NAMESPACE                = var.settings.cluster.namespace
      CONFIGURATION_FILENAME   = local.configurationFilename
      CERTIFICATE_FILENAME     = local.certificateFilename
      CERTIFICATE_KEY_FILENAME = local.certificateKeyFilename
    }

    quiet   = true
    command = local.applySettingsScriptFilename
  }

  depends_on = [
    linode_lke_cluster.cluster,
    local_sensitive_file.clusterKubeconfig
  ]
}

# Applies the deployments.
resource "null_resource" "applyDeployments" {
  # Applies only when the files changed.
  triggers = {
    always_run = "${filemd5(local.applyManifestScriptFilename)}|${filemd5(local.deploymentsManifestFilename)}"
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG        = local_sensitive_file.clusterKubeconfig.filename
      MANIFEST_FILENAME = local.deploymentsManifestFilename
      NAMESPACE         = var.settings.cluster.namespace
    }

    quiet   = true
    command = local.applyManifestScriptFilename
  }

  depends_on = [
    linode_lke_cluster.cluster,
    local_sensitive_file.clusterKubeconfig,
    null_resource.applySettings
  ]
}

# Applies the services.
resource "null_resource" "applyServices" {
  # Applies only when the files changed.
  triggers = {
    always_run = "${filemd5(local.applyManifestScriptFilename)}|${filemd5(local.servicesManifestFilename)}"
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG        = local_sensitive_file.clusterKubeconfig.filename
      MANIFEST_FILENAME = local.servicesManifestFilename
      NAMESPACE         = var.settings.cluster.namespace
    }

    quiet   = true
    command = local.applyManifestScriptFilename
  }

  depends_on = [
    linode_lke_cluster.cluster,
    local_sensitive_file.clusterKubeconfig
  ]
}