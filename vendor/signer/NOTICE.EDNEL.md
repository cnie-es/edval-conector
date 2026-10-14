# Modification notice (EUPL 1.2, Art. 5)

**This is a modified version of a SIMPL-open Helm chart. It is not the original work.**

The original work is part of the SIMPL programme (© European Union / SIMPL Programme) and is
licensed under the **European Union Public Licence v. 1.2 (EUPL-1.2)**. See [LICENSE](LICENSE),
where the full official text of the licence is reproduced. All original copyright, licence and
disclaimer notices are kept intact and unmodified in this fork.

Note: a previous `LICENSE` file in this directory carried an Apache-2.0 / Vereign AG notice that
belongs to an unrelated, deeper upstream of this chart (a "TSA signer service" project by Vereign
AG). That notice did not describe the licence of the project we actually forked from
(`code.europa.eu/simpl/simpl-open/development/gaia-x-edc/poc-gaia-edc`), which distributes under
EUPL-1.2 like the rest of SIMPL-open. It has been replaced with the correct EUPL-1.2 text.

## Upstream baseline

| | |
|---|---|
| Original work | `poc-gaia-edc` (chart in `charts/`), Chart.yaml name `poc-charts` |
| Upstream repository | https://code.europa.eu/simpl/simpl-open/development/gaia-x-edc/poc-gaia-edc |
| Baseline branch | `main` (no numbered release tag exists for this chart; `Chart.yaml`'s `version`/`appVersion` are unresolved CI placeholders, `${PROJECT_RELEASE_VERSION}`) |
| Baseline commit | `cd5ae0bd94b021937562192dc1a2500a30b7c9e3` (2026-07-10, latest commit on `main` at the time of this notice; `main` had no further commits between the fork and this check) |

## Modifications

| | |
|---|---|
| Modified by | EDNEL-RIOJA project team, for the EDVAL external-participant connector (CNIE-ES) |
| Repository of this derivative work | https://github.com/cnie-es/edval-conector |
| Date of modification | 2026-10-02 |

The modifications are licensed under the **EUPL-1.2**, the same licence as the original work.

This chart is vendored (copied) rather than referenced by URL because, unlike the 9 EDVAL
components, it has no separate publication pipeline of its own: it ships only inside this
connector distribution. The complete diff against the baseline commit above is in
[UPSTREAM.diff](UPSTREAM.diff), in this same directory (there is no shared Git history with the
upstream GitLab project to generate it on demand, so the diff is checked in instead).

### Summary of the changes

- **`templates/deployment.yaml`, the container entrypoint**: the upstream script uses
  `source {{ .Values.vault.volumes.secretsFilePath }} && java -jar {{ .Values.app.jarPath }}`.
  `source` is a bash builtin, not available in `/bin/sh` (the shell of this container's base
  image), so the container crash-loops on every start and never reaches a healthy state. Fixed to
  `. {{ .Values.vault.volumes.secretsFilePath }} && cd {{ .Values.app.workDir }} &&
  {{ .Values.app.binaryPath }}` (POSIX `.` instead of `source`), and adapted to run the actual
  compiled binary this image ships (`app.workDir`/`app.binaryPath`) instead of `java -jar`, since
  this component is not a JVM application.
- **`templates/deployment.yaml`, labels/selectors/probes/metrics/serviceAccount/image**:
  restructured to use `_helpers.tpl` (added, not present upstream) for name/labels, a pinned image
  reference, a readiness probe, and support for `env`/`metrics`/`imagePullSecrets` — none of this
  existed in the upstream template.
- **`Chart.yaml`**: renamed from `poc-charts` to `signer` and given a concrete `version`/`appVersion`
  (`0.1.0`), since the upstream file only carries unresolved CI placeholders with no chart name that
  reflects what it deploys.
- **`old-dev-values.yaml`**: restructured together with the rest of the values.
- **Added**: `templates/_helpers.tpl`, `templates/argocd/` (ArgoCD Application/Project manifests),
  `templates/istio/` (authorization/gateway/virtual-service manifests) — none of these exist
  upstream; `README.md` and `ci/argocd.yaml` at the top level of this directory are likewise our own
  additions, not present upstream.
- **Removed**: `.helmignore` (present upstream, dropped here).

**Not fixed by this chart**: the hardcoded sandbox Vault address
(`vault.address: https://secrets.common01.sandbox-cat-dat.simpl-europe.eu`) and role
(`vault.role: sandbox-cat-dat-role`) in `values.yaml` are **unchanged from upstream** — they are
overridden at render time by the connector's own values (`Agents/connector/app-values/Signer/`),
not patched in this vendored copy. Anyone deploying this chart's own defaults without that override
would still point at SIMPL-open's sandbox Vault.

### Files added

| File |
|---|
| `templates/_helpers.tpl` |
| `templates/argocd/argo-application.yaml` |
| `templates/argocd/argo-project.yaml` |
| `templates/istio/autorization-rules.yaml` |
| `templates/istio/gateway.yaml` |
| `templates/istio/virtual-service.yaml` |
| `README.md` |
| `ci/argocd.yaml` |
| `NOTICE.EDNEL.md` (this file) |
| `UPSTREAM.diff` |

### Files modified

| File |
|---|
| `Chart.yaml` |
| `values.yaml` |
| `old-dev-values.yaml` |
| `templates/deployment.yaml` |
| `templates/hpa.yaml` |
| `templates/ingress.yaml` |
| `templates/service.yaml` |
| `templates/serviceaccount.yaml` |
| `LICENSE` (replaced an unrelated Apache-2.0 notice with the correct EUPL-1.2 text, see note above) |

### Files removed

| File |
|---|
| `.helmignore` |

All dates above are 2026-10-02, taken from the EDNEL-RIOJA working repository's own commit history
(`a0682ef`, "fix(chart): signer y simpl-files vendorizados con su arreglo, sin parches en vivo") —
this repository's own Git history was replaced by a single squashed copy when it was mirrored into
Gitea, so per-file dates could not be read from this repository's own log and are taken from the
original authoring repository instead.
