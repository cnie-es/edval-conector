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
| Upstream repository | https://code.europa.eu/simpl/simpl-contributions/infratex/simpl-open/development/data1/simpl-files |
| Baseline version | `v1.4.0` |
| Baseline commit | `51230cf8bcc4f7571beb722163108ea9206786ad` (2026-07-31) |

Only the Helm chart (`charts/`) was taken from this upstream project; the application code,
Dockerfile and the rest of the repository were not vendored here.

## Modifications

| | |
|---|---|
| Modified by | EDNEL-RIOJA project team, for the EDVAL external connector |
| Dates of modification | **2026-10-02** |

The modifications are licensed under the **EUPL-1.2**, the same licence as the original work.

This chart is vendored directly inside this repository (`vendor/simpl-files/`), not published as
its own component, so there is no shared Git history with the upstream project to diff against.
The complete diff between the upstream chart at the baseline commit above and this vendored copy
is kept alongside this file, in [UPSTREAM.diff](UPSTREAM.diff).

### Summary of the changes

The published chart runs its container as a non-root user (`runAsUser: 101`, required by the
upstream project's own Fortify/security hardening), but the chart's `deployment.yaml` gives the
Pod no writable `/tmp` and exposes no values key to add one without editing the template directly:
nginx needs to write its PID file there, and the container has no write permission on `/tmp` as
that non-root user. With the public chart unmodified, the `simpl-files` Pod never becomes ready.

The fix adds an `emptyDir` volume named `tmp`, mounted at `/tmp`, in `deployment.yaml`. Confirmed
against the current upstream `main` (verified at the same commit as the baseline above, which is
still upstream `HEAD` for `charts/` at the time of writing): the bug is still present there, with
no override hook added since.

`Chart.yaml` and `values.yaml` differ only in resolving upstream's own CI build placeholders
(`${PROJECT_RELEASE_VERSION}`, `${CI_REGISTRY_IMAGE}`) to the literal values of the vendored
release (`1.4.0`, `code.europa.eu:4567/simpl/simpl-open/development/data1/simpl-files`) — this is
not a functional change, it is what upstream's own CI would have substituted at release time.

### Files modified

| File | Date |
|---|---|
| `Chart.yaml` | 2026-10-02 |
| `values.yaml` | 2026-10-02 |
| `templates/deployment.yaml` | 2026-10-02 |

No file was added or removed relative to the upstream `charts/` directory. No copyright, licence
or disclaimer notice of the original work has been altered.

The per-file diff is in [UPSTREAM.diff](UPSTREAM.diff).
