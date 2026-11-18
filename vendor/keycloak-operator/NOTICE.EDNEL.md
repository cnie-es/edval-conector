# Modification notice (Apache License 2.0, section 4)

**This chart packages modified versions of the official Keycloak Operator manifests. It is not
the original work.**

The original work is part of Keycloak (© Red Hat, Inc. and Keycloak contributors) and is
licensed under the **Apache License, Version 2.0** (https://www.apache.org/licenses/LICENSE-2.0).

## Upstream baseline

| | |
|---|---|
| Original work | Keycloak Operator Kubernetes resources |
| Upstream repository | https://github.com/keycloak/keycloak-k8s-resources |
| Baseline version | `26.8.1` (`kubernetes/`) |

## Modifications

| | |
|---|---|
| Modified by | EDNEL-RIOJA project team, for CNIE-ES |
| Date of modification | 2026-11-11 |

- `files/*.yml`: the four CRDs, unmodified. `templates/crds.yaml` only adds Argo CD
  annotations (`Prune=false,Delete=false,ServerSideApply=true`, sync wave `-1`).
- `templates/operator.yaml`: `kubernetes.yml` as a Helm template. The namespace is the release
  namespace. The four controller ClusterRoles become namespaced Roles, because upstream binds
  them only with RoleBindings. The `config.openshift.io` ClusterRole and its binding get the
  namespace as a suffix. Image, resources and node selector are configurable. The Quarkus build
  annotations are removed.
- The Operator keeps the upstream default `JOSDK_WATCH_CURRENT`: it only watches its own
  namespace.
