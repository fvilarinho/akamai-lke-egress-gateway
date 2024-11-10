# Definition of the LKE cluster.
resource "linode_lke_cluster" "cluster" {
  k8s_version = "1.31"
  label       = var.settings.cluster.identifier
  tags        = var.settings.cluster.tags
  region      = var.settings.cluster.region

  # Definition of the egress gateway nodes.
  pool {
    labels = {
      egressGateway = true
    }

    type  = var.settings.cluster.egressGateway.type
    count = var.settings.cluster.egressGateway.count
  }

  # Definition of the worker nodes.
  pool {
    labels = {
      workerNodes = true
    }

    type  = var.settings.cluster.workerNodes.type
    count = var.settings.cluster.workerNodes.count
  }

  control_plane {
    high_availability = true

    acl {
      enabled = true

      addresses {
        ipv4 = [ "${jsondecode(data.http.myIp.response_body).ip}/32" ]
      }
    }
  }
}

# Saves the kubeconfig file locally.
resource "local_sensitive_file" "clusterKubeconfig" {
  filename        = abspath(pathexpand("../etc/.kubeconfig"))
  content_base64  = linode_lke_cluster.cluster.kubeconfig
  file_permission = "600"
  depends_on      = [ linode_lke_cluster.cluster ]
}