# EDVAL external connector

This repository contains the versioned, self-contained distribution of the
EDVAL participant connector for deployment outside the CNIE core platform.
Gitea is the source of truth; each immutable `v*` tag in this repository is
generated from an explicitly approved release tag and mirrored to GitHub.

## Contents

- `Agents/connector/charts`: umbrella Helm chart for the connector.
- `Agents/connector/charts/values-external.yaml`: required external deployment overlay.
- `Agents/connector/charts/values-role-provider.yaml`: provider-only role overlay.
- `Agents/connector/charts/values-role-consumer.yaml`: consumer-only role overlay.
- `external`: charts vendored by the distribution.
- `images.lock.yaml`: immutable GHCR image inventory for this release.
- `THIRD_PARTY.md`: pinned third-party components and their licences.

## Deployment

The umbrella chart creates Argo CD applications, so the target cluster must
already provide Kubernetes, Helm, Argo CD, cert-manager and a suitable default
StorageClass. Use an immutable release tag and apply the external overlay after
the base values. Apply a role overlay last when the participant is not hybrid.

Example validation before deployment:

```sh
helm lint Agents/connector/charts \
  -f Agents/connector/charts/values-external.yaml

helm template edval-connector Agents/connector/charts \
  -f Agents/connector/charts/values-external.yaml \
  --set project=participant \
  --set domainSuffix=participant.example \
  --set authorityDomainSuffix=authority.example
```

Replace the example values with those assigned during participant onboarding.
If registry authentication is required by the target organisation, provide an
image pull secret for `ghcr.io`; public packages do not require one.

Do not deploy from `main`. Select the immutable tag corresponding to the
approved connector release.
