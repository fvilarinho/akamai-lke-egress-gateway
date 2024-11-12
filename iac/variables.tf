# Definition of the settings.
variable "settings" {
  default = {
    # General attributes used in the resources provisioning.
    general = {
      domain = "<domain>"
      email  = "<email>"
      token  = "<token>"
    }

    # Used in the Cloud firewall provisioning.
    network = {
      allowedIps = {
        ipv4 = [ "0.0.0.0/0" ]
        ipv6 = []
      }
    }

    # Definition of the cluster.
    cluster = {
      namespace  = "default"
      identifier = "cluster1"
      tags       = [ "demo", "egress-gateway" ]
      region     = "<region>"

      # Definition of the egress gateway.
      egressGateway = {
        type  = "g6-standard-2"
        count = 1
      }

      # Definition of the worker nodes.
      workerNodes = {
        type  = "g6-standard-2"
        count = 2
      }
    }
  }
}