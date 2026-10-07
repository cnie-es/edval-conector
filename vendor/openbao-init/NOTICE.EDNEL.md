# Modification notice (EUPL 1.2, Art. 5)

**This is a modified version of SIMPL openbao-init-chart. It is not the original work.**

The original work, `openbao-init-chart`, is part of the SIMPL programme (© European Union / SIMPL
Programme) and is licensed under the **European Union Public Licence v. 1.2 (EUPL-1.2)**. See
[LICENSE](LICENSE), where the full official text of the licence is reproduced. All original
copyright, licence and disclaimer notices are kept intact and unmodified in this fork.

## Upstream baseline

| | |
|---|---|
| Original work | openbao-init-chart |
| Upstream repository | https://code.europa.eu/simpl/simpl-contributions/infratex/simpl-open/security/access-control-and-trust/encryption/openbao/openbao-init-chart |
| Baseline tag | `v1.1.1` |
| Baseline commit | `0d7b54f602f9c1ae8e76790bd9099e77e0b7213f` (2026-07-17) |
| Chart subdirectory compared | `charts/` |

Note: the upstream `charts/Chart.yaml` carries `version: ${PROJECT_RELEASE_VERSION}` in git source
(a CI placeholder, substituted only in the published release package); `v1.1.1` is the closest
verifiable baseline (the git tag whose commit this vendored copy was taken from).

## Modifications

| | |
|---|---|
| Modified by | EDNEL-RIOJA project team, for CNIE-ES |
| Dates of modification | 2026-10-01 to 2026-10-02 (per Git history of the vendoring repository) |

The modifications are licensed under the **EUPL-1.2**, the same licence as the original work.

### Summary of the changes

- **RBAC widened and made per-agent**: `rbac.yaml` adds a `Role`/`RoleBinding` pair *per entry* in
  `agentList` (authorities/providers/consumers), each allowed to `get`/`patch`/`update` secrets in
  that agent's own namespace — the public chart only grants access in OpenBao's own namespace. Also
  adds `apps/statefulsets` `patch` (needed to restart Kafka brokers when their SASL user list
  changes) and drops the unused `batch/cronjobs,jobs` rule.
- **PVC**: `storageClassName` made configurable (empty by default); access mode changed from
  `ReadWriteMany` to `ReadWriteOnce` (matches the single-replica init Job/CronJob access pattern).
- **`values.yaml`**: adds `agentList` (empty map, the structure RBAC/secrets iterate over),
  `secrets.role`/`secrets.secretEngine` (Vault/OpenBao secret-engine config consumed elsewhere in
  this chart), `storageClassName`, and a `mailpit.enabled` flag; removes the unused `imageTag` and
  `replicas` defaults from upstream.
- **`templates/secrets.yaml` added in full** (does not exist upstream): seeds every credential the
  connector's other components need from OpenBao/Kubernetes — Postgres admin, Redpanda/Kafka
  (including a `hybrids` category for a participant running both provider and consumer instances in
  the same namespace), Redis, Keycloak, Gitea, EJBCA and schema-manager secrets — using `lookup`
  to preserve any value already set live rather than overwriting it on every sync.
- **`templates/_helpers.tpl` added in full** (does not exist upstream): per-service random-password
  generators (`redpanda.password`, `pgadmin.password`, `rediscommander.password`, `redis.password`,
  three Kafka-user password helpers) used by `secrets.yaml`.
- **`templates/initjob.yaml`, `templates/pvc.yaml`, `templates/rbac.yaml` substantially rewritten**
  beyond the diffs above: the known functional reasons for vendoring are the init Job now checking
  `/v1/sys/seal-status` before running `bao operator init` (the public chart's init logic is more
  naive and can silently re-run/swallow a failure if OpenBao is already initialized — a real risk,
  not just a style difference), base image changed from `rancher/kubectl`-family to
  `docker.io/alpine/k8s`, more robust parsing of a multi-line `init.json`, and `imagePullSecrets`.
  The full line-level diff is in [UPSTREAM.diff](UPSTREAM.diff).
- `Chart.yaml`: version bumped locally to `1.4.4` and a description added (upstream's version field
  is a CI placeholder, see baseline note above).

### Aviso: posible copia obsoleta sin usar

Este directorio (`vendor/openbao-init/`) contiene, ADEMAS de `charts/` (documentado arriba, el que
referencia `embedded-application-openbao.yaml` via `openbao_init.path`, cuyo default es `"charts"`),
una SEGUNDA copia independiente en la raiz: `Chart.yaml` (version `1.1.1`, sin bumpear),
`values.yaml`, `templates/{initjob.yaml,k8s-auth-config-job.yaml,pvc.yaml,rbac.yaml}` y
`manual-init-job.yaml`. Esta segunda copia deriva del MISMO baseline upstream (`charts/` de
`openbao-init-chart`) pero ha divergido de forma distinta a la de `charts/` — por ejemplo, tiene su
propio `templates/k8s-auth-config-job.yaml` que no existe en ninguna de las otras dos versions.

No he podido confirmar, solo inspeccionando ficheros, si esta segunda copia esta realmente
desplegada por algun otro mecanismo (otro values file que sobreescriba `openbao_init.path` a `"."`
o similar) o si es una copia obsoleta de una vendorizacion anterior que nadie limpio. Recomiendo
verificarlo antes de documentarla igual que `charts/`, y si resulta no usarse, borrarla en vez de
mantenerla.

### Ficheros (capa `charts/`, la desplegada)

| Fichero | Cambio |
|---|---|
| `Chart.yaml` | version 1.4.4 + description (modificado) |
| `values.yaml` | agentList/secrets.*/storageClassName/mailpit anadidos; imageTag/replicas quitados (modificado) |
| `templates/rbac.yaml` | Role/RoleBinding por agente + ajustes de permisos (modificado) |
| `templates/pvc.yaml` | storageClassName configurable, ReadWriteOnce (modificado) |
| `templates/initjob.yaml` | deteccion seal-status, imagen alpine/k8s, parseo init.json robusto (modificado) |
| `templates/_helpers.tpl` | añadido |
| `templates/secrets.yaml` | añadido |

El diff completo linea a linea esta en [UPSTREAM.diff](UPSTREAM.diff).
