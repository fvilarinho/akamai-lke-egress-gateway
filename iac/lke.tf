resource "linode_lke_cluster" "cluster" {
  k8s_version = "1.31"
  label       = var.settings.cluster.identifier
  tags        = var.settings.cluster.tags
  region      = var.settings.cluster.region

  pool {
    labels = {
      workerNodes = true
    }

    type  = var.settings.cluster.nodes.type
    count = var.settings.cluster.nodes.count
  }

  pool {
    labels = {
      egressGateway = true
    }

    type  = var.settings.cluster.egressGateway.type
    count = var.settings.cluster.egressGateway.count
  }
}

resource "local_sensitive_file" "clusterKubeconfig" {
  filename        = abspath(pathexpand("../etc/.kubeconfig"))
  content_base64  = linode_lke_cluster.cluster.kubeconfig
  file_permission = "600"
  depends_on      = [ linode_lke_cluster.cluster ]
}