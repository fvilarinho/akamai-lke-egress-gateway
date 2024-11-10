variable "settings" {
  default = {
    general = {
      domain = "<domain>"
      email  = "<email>"
      token  = "<token>"
    }

    network = {
      allowedIps = {
        ipv4 = [ "0.0.0.0/0" ]
        ipv6 = []
      }
    }

    cluster = {
      namespace  = "default"
      identifier = "cluster1"
      tags       = [ "demo" ]
      region     = "<region>"

      nodes = {
        type  = "g6-standard-2"
        count = 3
      }

      egressGateway = {
        type  = "g6-standard-2"
        count = 2
      }
    }
  }
}