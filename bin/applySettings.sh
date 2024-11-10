#!/bin/bash

# Check the dependencies of this script.
function checkDependencies() {
  if [ -z "$KUBECONFIG" ]; then
    echo "The cluster configuration file is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$NAMESPACE" ]; then
    echo "The namespace is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$CONFIGURATION_FILENAME" ]; then
    echo "The configuration filename is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$CERTIFICATE_FILENAME" ]; then
    echo "The certificate filename is not defined! Please define it first to continue!"

    exit 1
  fi

  if [ -z "$CERTIFICATE_KEY_FILENAME" ]; then
    echo "The certificate key filename is not defined! Please define it first to continue!"

    exit 1
  fi
}

# Applies the cluster settings replacing the placeholders with the correspondent environment variable.
function applySettings() {
  $KUBECTL_CMD create configmap egress-gateway-config \
                                --from-file="$CONFIGURATION_FILENAME" \
                                -n "$NAMESPACE" \
                                -o yaml \
                                --dry-run=client | $KUBECTL_CMD apply -f -

  $KUBECTL_CMD create configmap egress-gateway-certificate \
                                --from-file="$CERTIFICATE_FILENAME" \
                                -n "$NAMESPACE" \
                                -o yaml \
                                --dry-run=client | $KUBECTL_CMD apply -f -

  $KUBECTL_CMD create configmap egress-gateway-certificate-key \
                                --from-file="$CERTIFICATE_KEY_FILENAME" \
                                -n "$NAMESPACE" \
                                -o yaml \
                                --dry-run=client | $KUBECTL_CMD apply -f -
}

# Main function.
function main() {
  checkDependencies
  applySettings
}

main