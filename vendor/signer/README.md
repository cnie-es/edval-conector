# Helm Chart for Signer

This directory contains the Helm chart for deploying the Signer application to Kubernetes.

## Quick Start

`values.yaml` is the single baseline for the dev/sandbox environment.

```bash
# Install
helm install signer . -f values.yaml --namespace your-namespace

# Upgrade
helm upgrade signer . -f values.yaml --namespace your-namespace
```

When another environment is introduced (e.g. production), add a `values-<env>.yaml` with only the
keys that differ and pass both files: `-f values.yaml -f values-prod.yaml`.

## Chart Structure

```
charts/
├── Chart.yaml            # Chart metadata
├── values.yaml           # Baseline configuration defaults (dev/sandbox)
├── old-dev-values.yaml   # Unused reference copy (legacy key names)
└── templates/
    ├── deployment.yaml
    ├── hpa.yaml
    ├── ingress.yaml
    ├── service.yaml
    ├── serviceaccount.yaml
    └── istio/
```

## Configuration

The chart is configured via `values.yaml`. Optional `values-<env>.yaml` override files are only
needed when deploying to an environment that differs from dev/sandbox; override files must contain
only the keys that differ, not a full copy of the baseline.

Key `values.yaml` groups:
- `replicaCount` — pod replica count
- `image.*` — container repository, name, tag, pull policy
- `app.*` — signer binary work directory and path
- `vault.*` — OpenBao / Vault connection, init container, retry, mount paths
- `service.*` / `signer.http.*` — HTTP ports
- `ingress.*` — hostname, TLS, annotations
- `resources.*` — CPU and memory limits/requests
- `deployment.strategy.*` — rolling update settings
- `podSecurityContext.*` — pod security settings
- `serviceAccount.*` — service account and token settings
- `metrics.*` — Prometheus scrape settings
- `probes.*` — readiness probe settings
- `autoscaling.*` — horizontal pod autoscaling

## For Complete Deployment Instructions

**See [Deployment Guide](../documents/deployment-guide.md)** for:
- Prerequisites and dependencies
- Vault configuration
- Environment setup
- Step-by-step deployment process
- Verification and troubleshooting

## Chart Development

```bash
# Validate chart syntax
helm lint .

# Render templates locally
helm template . --debug

# Test installation (dry-run)
helm install --dry-run --debug signer .
```
