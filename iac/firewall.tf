locals {
  nodesToBeProtected = flatten([ for pool in linode_lke_cluster.cluster.pool : [ for node in pool.nodes : node.instance_id ] ])
  allowedPublicIps   = concat([ for node in data.linode_instances.nodesToBeProtected.instances : "${node.ip_address}/32" ], [ "${jsondecode(data.http.myIp.response_body).ip}/32" ])
  allowedPrivateIps  = [ for node in data.linode_instances.nodesToBeProtected.instances : "${node.private_ip_address}/32" ]
  allowedIpv4        = concat(var.settings.network.allowedIps.ipv4, concat(local.allowedPublicIps, local.allowedPrivateIps))
}

data "http" "myIp" {
  url = "https://ipinfo.io"
}

data "linode_instances" "nodesToBeProtected" {
  filter {
    name   = "id"
    values = local.nodesToBeProtected
  }

  depends_on = [ linode_lke_cluster.cluster ]
}

resource "linode_firewall" "default" {
  label           = "${var.settings.cluster.identifier}-firewall"
  tags            = var.settings.cluster.tags
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    action   = "ACCEPT"
    label    = "allow-icmp"
    protocol = "ICMP"
    ipv4     = [ "0.0.0.0/0" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-cluster-nodeports-udp"
    protocol = "IPENCAP"
    ipv4     = [ "192.168.128.0/17" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-kubelet-health-checks"
    protocol = "TCP"
    ports    = "10250, 10256"
    ipv4     = [ "192.168.128.0/17" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-lke-wireguard"
    protocol = "UDP"
    ports    = "51820"
    ipv4     = [ "192.168.128.0/17" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-cluster-dns-tcp"
    protocol = "TCP"
    ports    = "53"
    ipv4     = [ "192.168.128.0/17" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-cluster-dns-udp"
    protocol = "UDP"
    ports    = "53"
    ipv4     = [ "192.168.128.0/17" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-nodebalancers-tcp"
    protocol = "TCP"
    ports    = "30000-32767"
    ipv4     = [ "192.168.255.0/24" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-nodebalancers-udp"
    protocol = "UDP"
    ports    = "30000-32767"
    ipv4     = [ "192.168.255.0/24" ]
  }

  inbound {
    action   = "ACCEPT"
    label    = "allowed-ips"
    protocol = "TCP"
    ipv4     = local.allowedIpv4
    ipv6     = var.settings.network.allowedIps.ipv6
  }

  linodes = local.nodesToBeProtected

  depends_on = [
    data.http.myIp,
    linode_lke_cluster.cluster,
    data.linode_instances.nodesToBeProtected,
  ]
}