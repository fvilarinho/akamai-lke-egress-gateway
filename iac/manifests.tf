locals {
  applyManifestScriptFilename = abspath(pathexpand("../bin/applyManifest.sh"))
  configMapsManifestFilename  = abspath(pathexpand("../etc/configMaps.yaml"))
  deploymentsManifestFilename = abspath(pathexpand("../etc/deployments.yaml"))
  servicesManifestFilename    = abspath(pathexpand("../etc/services.yaml"))
}

resource "null_resource" "applyConfigMaps" {
  triggers = {
    always_run = "${filemd5(local.applyManifestScriptFilename)}|${filemd5(local.configMapsManifestFilename)}"
  }

  provisioner "local-exec" {
    environment = {
      KUBECONFIG        = local_sensitive_file.clusterKubeconfig.filename
      MANIFEST_FILENAME = local.configMapsManifestFilename
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

resource "null_resource" "applyDeployments" {
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
    null_resource.applyConfigMaps
  ]
}

resource "null_resource" "applyServices" {
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
    local_sensitive_file.clusterKubeconfig,
    null_resource.applyConfigMaps
  ]
}