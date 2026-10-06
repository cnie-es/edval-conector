# Modification notice (EUPL 1.2, Art. 5)

**This is a modified version of the SIMPL-open Kafka chart. It is not the original work.**

The original work, `kafka-chart`, is part of the SIMPL programme (© European Union / SIMPL
Programme) and is licensed under the **European Union Public Licence v. 1.2 (EUPL-1.2)**. See
[LICENSE](LICENSE), where the full official text of the licence is reproduced. All original
copyright, licence and disclaimer notices are kept intact and unmodified in this fork.

## Upstream baseline

| | |
|---|---|
| Original work | kafka-chart |
| Upstream repository | https://code.europa.eu/simpl/simpl-open/administration/notification-and-messaging/messaging/kafka/kafka-chart |
| Baseline version | `v1.3.1` |
| Baseline commit | `9163b56d9b` (2026-07-09) |

## Modifications

| | |
|---|---|
| Modified by | EDNEL-RIOJA project team, for CNIE-ES |
| Distribution of this derivative work | `cnie-c1-apps/simpl-participant-connector-dist`, `vendor/kafka/` (vendorizado dentro del repositorio del conector, no publicado como repositorio propio) |
| Dates of modification | 2026-10-01 to 2026-10-02 |

The modifications are licensed under the **EUPL-1.2**, the same licence as the original work.

Unlike the EDVAL components published as their own repository under `cnie-es`, this chart has no
public distribution history of its own: it is vendored as a point-in-time snapshot inside the
connector's own distribution repository. The complete diff against the upstream baseline above is
kept alongside this notice, in [UPSTREAM.diff](UPSTREAM.diff).

### Summary of the changes

The upstream chart assumes a single internal-only Kafka cluster with no path to reach it from
outside the Kubernetes cluster, and hardcodes the Confluent image registry. None of this fit the
participant connector, which needs Kafka reachable by external participants and a choice between
Vault-injected and plain Kubernetes-secret credentials depending on the deployment profile:

- **TLS listener with `cert-manager` automation**: a `Certificate` resource is created when
  `listeners.tls.certManager.enabled` is set, issuing a certificate for the internal TLS listener
  instead of requiring a pre-existing secret.
- **Per-broker external listeners**: new `listeners.perBroker` keys (`staticForPortBasedRouting` /
  `staticForHostBasedRouting`) expose each broker individually, by port or by hostname, for access
  from outside the cluster — the upstream chart has no equivalent.
- **Selectable secret source**: `auth.secretMethod` (`"vault"` or `"kubernetes"`) switches between
  HashiCorp/OpenBao Vault-agent injection (the only mode the upstream chart supports) and a plain
  Kubernetes `Secret` referenced by `auth.secretName`.
- **Configurable image registry**: `image.registry`/`image.application` let the image be pulled
  from a registry other than Confluent's own `confluentinc/*` on Docker Hub, which the upstream
  chart hardcodes; `imagePullSecrets` was added to support a private registry.
- **Dedicated `ServiceAccount` for the kRaft controller** (`kraftcontroller-sa`), and a configurable
  `storageClass` for both the Kafka cluster and the kRaft controller (upstream always uses the
  cluster default).

**Lost in the fork, not restored**: the upstream chart exposes `kafka.configOverrides` (`server`,
`log4j`, `log4j2`) as free-form Helm values appended to the Confluent Platform config; this fork
does not carry that key. It was not needed for the connector's deployment profiles, so nobody
ported it when the listener/registry changes above were made — see `UPSTREAM.diff` for the exact
upstream block that was dropped. The upstream chart also sets `oneReplicaPerNode: true` on both the
Kafka cluster and the kRaft controller; this fork's templates omit that field.

The per-file diff for every change is in [UPSTREAM.diff](UPSTREAM.diff) (upstream `v1.3.1` vs. this
fork's `charts/`).

### Files modified

| File | Note |
|---|---|
| `charts/Chart.yaml` | `version` pinned to `1.3.1` (upstream uses a build-time placeholder, `${PROJECT_RELEASE_VERSION}`); `description` added |
| `charts/values.yaml` | image registry/pull-secrets, listener (TLS/external/per-broker), `auth.secretMethod`, `storageClass` keys added; `configOverrides` removed |
| `charts/templates/kafka.yaml` | TLS `Certificate`, per-broker external listeners, `secretMethod`-conditional JAAS config, configurable image reference, `imagePullSecrets`; `configOverrides` block removed; `oneReplicaPerNode` removed |
| `charts/templates/kraftController.yaml` | dedicated `ServiceAccount`, configurable image reference and `storageClass`; `oneReplicaPerNode` removed |

No file was added or removed outright; every file in `charts/` already existed upstream and was
modified in place. `README.md`, `CHANGELOG.md`, `documents/README.md`, `pipeline.variables.sh` and
`LICENSE` at the top of `vendor/kafka/` are themselves carried over from upstream (this file,
`NOTICE.EDNEL.md`, and `UPSTREAM.diff` are the only additions).
