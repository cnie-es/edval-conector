# Modification notice (EUPL 1.2, Art. 5)

**This is a modified version of two SIMPL-open Helm charts, fused into one. It is not the
original work.**

The original works are part of the SIMPL programme (© European Union / SIMPL Programme) and are
licensed under the **European Union Public Licence v. 1.2 (EUPL-1.2)**. See [LICENSE](LICENSE),
where the full official text of the licence is reproduced. All original copyright, licence and
disclaimer notices are kept intact and unmodified in this fork.

## Upstream baseline

Unlike a single-origin fork, this chart (`charts/`, in this same directory) merges **two**
independent SIMPL-open projects into one, parameterised by role via `charts/values-role-provider.yaml`
and `charts/values-role-consumer.yaml`:

| | Provider side | Consumer side |
|---|---|---|
| Original work | `data-provider-agent-chart` | `consumer-agent-chart` |
| Upstream repository | https://code.europa.eu/simpl/simpl-open/cross-cutting/agents/data-provider-agent-chart | https://code.europa.eu/simpl/simpl-open/cross-cutting/agents/consumer-agent-chart |
| Baseline version | `v3.0.3` | `v3.0.2` (see note) |

**Note on the consumer baseline**: `v3.0.3` never existed for `consumer-agent-chart` - its `3.0.x`
series is `v3.0.0`, `v3.0.1`, `v3.0.2`, then it jumps straight to `v3.1.0`. `v3.0.2` is the closest
real version and is used here as the comparison baseline; this is stated explicitly rather than
assuming parity with the provider side.

## Modifications

| | |
|---|---|
| Modified by | EDNEL-RIOJA project team, for CNIE-ES |
| Public repository of this derivative work | https://github.com/cnie-es/edval-conector |
| Dates of modification | 2026-10-01 to 2026-10-06 |

The modifications are licensed under the **EUPL-1.2**, the same licence as both original works.

### Summary of the changes

The degree of copying is **not uniform across files** - it is documented honestly per file below
rather than presented as a single uniform fork:

- **`charts/templates/dependencies.yaml`**: a near-literal copy of `data-provider-agent-chart`'s
  file of the same name (`consumer-agent-chart` has no equivalent file at all) - same exact order
  of its 9 `sources:` blocks, same `.Values.*` keys, same conditional `resourcePreset: low` blocks.
  The only changes are environment substitutions: ingress class (`nginx` → `apisix`), a DNS
  separator (`.` → `-`) in the internal Gitea/Crossplane hostname, the Vault domain pattern, and
  switching the Redis dependency from a classic chart repository to an OCI registry.
- **`charts/templates/application.yaml`** and **`charts/values.yaml`**: a substantial **fusion and
  expansion** of both upstreams, not a simple patch. The ArgoCD multi-source `Application` pattern
  (one `ref: values` source plus one source per microservice) and most `.Values.<svc>.{repo_URL,
  targetRevision,chart_name,valueFiles,resources}` keys are preserved from the provider side
  verbatim; the full set of microservices from `consumer-agent-chart` is merged in alongside it,
  with the consumer-side instances of shared components (`simpl-edc`, `edc-connector-adapter`,
  `contract`) renamed with a `-consumer` suffix to avoid colliding with their provider-side
  counterparts once both are in the same chart. On top of that merge, this fork adds: Spanish-language
  comments, Vault CA/TLS wiring (`connector.vaultCaSecret`), Redis moved to the Bitnami OCI
  registry, `fail` guards for `adminRealmAccess=internal`, and entirely new app-values groups
  (`infrastructure-be`/`infrastructure-fe`, `data-dashboard`, `observability`) that exist in
  neither upstream.
- **Everything else** (17 of the 20 files in `charts/templates/`, and 3 of the 4 `charts/values*.yaml`
  files) is **wholly original**, with no counterpart in either upstream: the embedded OpenBao
  server/init/watchdog/auth-config/token-reviewer machinery, the NFS storage PVCs, the public EDC
  data-plane ingress, the CA truststore, the auth-provider service alias, the signer token-refresh
  CronJob, the embedded Kafka/vswh Applications, and the three `values-external.yaml`/
  `values-role-provider.yaml`/`values-role-consumer.yaml` overlay files. This is genuine EDNEL-RIOJA
  development for needs SIMPL-open's two agent charts do not cover on their own (a self-contained
  external participant, embedding its own secret/message backplane instead of depending on a shared
  one).

Because this is a fusion of two upstreams rather than a fork of one, the diff against the original
is split into **two files**, each compared against its own baseline:

- [UPSTREAM-dataprovider.diff](UPSTREAM-dataprovider.diff): against `data-provider-agent-chart@v3.0.3`.
- [UPSTREAM-consumer.diff](UPSTREAM-consumer.diff): against `consumer-agent-chart@v3.0.2`.

Content that comes from the *other* upstream necessarily shows up as added lines in each diff -
that is expected, not a discrepancy against that particular baseline; read the two diffs together,
not in isolation, to see the complete picture.
