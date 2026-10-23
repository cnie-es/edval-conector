# Modification notice (EUPL 1.2, Art. 5)

**This is a modified version of the simpl-files Helm chart. It is not the original work.**

The original work, simpl-files, is part of the SIMPL programme (© European Union / SIMPL
Programme) and is licensed under the **European Union Public Licence v. 1.2 (EUPL-1.2)**. See
[LICENSE](LICENSE), the full official text of the licence, reproduced as published upstream. All
original copyright, licence and disclaimer notices are kept intact and unmodified in this fork.

## Upstream baseline

| | |
|---|---|
| Original work | simpl-files (Helm chart only, under `charts/`) |
| Upstream repository | https://code.europa.eu/simpl/simpl-open/development/data1/simpl-files |
| Baseline version | `v1.2.0` |
| Baseline commit | `d024a7340dd2d9b422193e9ed211252f4991cabd` (2025-11-05) |

Only the Helm chart (`charts/`) was taken from this upstream project; the application code,
Dockerfile and the rest of the repository were not vendored here.

## Modifications

| | |
|---|---|
| Modified by | EDNEL-RIOJA project team, for the EDVAL external connector |
| Dates of modification | **2026-10-02**, **2026-10-23** |

The modifications are licensed under the **EUPL-1.2**, the same licence as the original work.

This chart is vendored directly inside this repository (`vendor/simpl-files/`), not published as
its own component, so there is no shared Git history with the upstream project to diff against.
The complete diff between the upstream chart at the baseline commit above and this vendored copy
is kept alongside this file, in [UPSTREAM.diff](UPSTREAM.diff).

### Summary of the changes

On 2026-10-23 the baseline moved from `v1.4.0` back to `v1.2.0`, the version (and the same image,
by digest) that the EDVAL internal connector runs. The `v1.4.0` changes of 2026-10-02 (writable
`/tmp` for the non-root nginx) no longer apply: the `v1.2.0` image runs nginx on port 80 as its own
user and serves the files bundled in the image.

- `Chart.yaml` and `values.yaml` resolve upstream's CI build placeholders
  (`${PROJECT_RELEASE_VERSION}`, `${CI_REGISTRY_IMAGE}`) to the literal values of the vendored release
  (`1.2.0`, `code.europa.eu:4567/simpl/simpl-open/development/data1/simpl-files`).
- `values.yaml`: `ingressClass: apisix` (the only ingress controller in the target clusters), an
  optional `ingress.tls.secretName` to use an existing TLS Secret instead of cert-manager, and an
  empty `imagePullSecrets` (the image is public).
- `templates/deployment.yaml`: optional `imagePullSecrets`.
- `templates/ingress.yaml`: `spec.ingressClassName` instead of the deprecated annotation, and the
  cert-manager annotations only when no existing TLS Secret is given.

### Files modified

| File | Date |
|---|---|
| `Chart.yaml` | 2026-10-02, 2026-10-23 |
| `values.yaml` | 2026-10-02, 2026-10-23 |
| `templates/deployment.yaml` | 2026-10-02, 2026-10-23 |
| `templates/ingress.yaml` | 2026-10-23 |

No file was added or removed relative to the upstream `charts/` directory. No copyright, licence
or disclaimer notice of the original work has been altered.

The per-file diff is in [UPSTREAM.diff](UPSTREAM.diff).
