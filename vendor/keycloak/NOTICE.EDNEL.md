# Modification notice (Apache License 2.0, Section 4)

**This is a modified version of the Bitnami `keycloak` Helm chart. It is not the original work.**

The original work is part of the [Bitnami charts](https://github.com/bitnami/charts) collection
(© Broadcom, Inc.) and is licensed under the **Apache License, Version 2.0**. See [LICENSE](LICENSE),
where the full official text of the licence is reproduced. All original copyright and license
notices are kept intact and unmodified in this fork, as required by Section 4(c) of the licence.

### NOTICE file

The upstream repository does not ship a separate `NOTICE` file (checked both at the repository
root and inside `bitnami/keycloak/` for the `keycloak/25.2.0` tag; neither exists) — so there is
nothing to carry forward under Section 4(d).

## Upstream baseline

| | |
|---|---|
| Original work | `bitnami/keycloak` (Helm chart) |
| Upstream repository | https://github.com/bitnami/charts/tree/keycloak/25.2.0/bitnami/keycloak |
| Baseline version | `25.2.0` |
| Baseline commit | `d7ec0ea7bff7264df7068ec6e51fbd3493d2c890` (tag `keycloak/25.2.0`) |

## Modifications

| | |
|---|---|
| Modified by | EDNEL-RIOJA project team, for CNIE-ES |
| Version of this derivative work | as committed in `vendor/keycloak/` of this repository (no independent version scheme) |
| Dates of modification | see table below; two confirmed commits on **2026-10-02**, the rest not precisely datable from the history available (see note) |

The modifications are licensed under the same terms as the original work (Apache License 2.0);
Section 4(b) requires every modified file to carry a notice that it was changed, which this file
provides collectively for the whole directory in lieu of per-file headers.

### Summary of the changes

Confirmed by a real diff against the `keycloak/25.2.0` tag (not assumed): **no existing Bitnami
template was modified** — every template file present in both the upstream chart and this fork is
byte-identical. The fork is additive plus two deliberate image substitutions:

- **Image source changed** (`values.yaml`, `Chart.yaml`): `image.repository` moved from
  `bitnami/keycloak` to `bitnamilegacy/keycloak`, pinned to tag `26.3.2-debian-12-r2` instead of the
  upstream default `26.3.3-debian-12-r0`. Reason recorded in an inline comment: Bitnami retired its
  public image catalog (images now live under the `bitnamilegacy` org), and the `r0` build's
  entrypoint expects the database host in `KEYCLOAK_DATABASE_HOST` and ignores `KC_DB_URL`; `r2` is
  the build already running on-prem (same digest as `harbor` `c1-apps/keycloak`). The templates
  (`_init_containers.tpl` etc.) still expect the Bitnami image layout (`/opt/bitnami/scripts`,
  `/opt/bitnami/keycloak/*`), which is why a non-Bitnami image (e.g. `quay.io/keycloak/keycloak`)
  cannot be substituted here without also rewriting those templates.
- **`keycloak-config-cli` image source changed**: from `bitnami/keycloak-config-cli` to
  `adorsys/keycloak-config-cli:6.4.0-26` (adorsys is the tool's original upstream maintainer).
- **Chart.yaml**: the two-line copyright/SPDX header comment was removed, and
  `annotations.images` was updated to match the two image substitutions above; a trailing newline
  was added.
- **Two templates added** (not present upstream): `templates/realm-hardening-job.yaml` and
  `templates/master-realm-block-route.yaml`, each gated by its own `values.yaml` block
  (`realmHardening.enabled`, `masterRealmPublicBlock.enabled`, both `false` by default):
  - `realmHardening`: a post-import Job that hardens a realm already created by
    `keycloak-config-cli` — session timeout, master/non-master password policies, and an
    OpenBao/Vault-backed admin credential lookup (`realmHardening.vault.*`).
  - `masterRealmPublicBlock`: blocks `/auth/realms/master*` and `/auth/admin*` on the
    participant's **public** host, for deployments where `adminRealmAccess=internal` routes the
    admin console through a separate internal host instead.

Note on dates: the git history available for this directory traces back to two commits on
**2026-10-02** (the `bitnamilegacy` image switch and the `26.3.2-debian-12-r2` tag pin). The
`realmHardening`/`masterRealmPublicBlock` additions predate the earliest release baseline
reachable in this history (an older squashed release commit) and their exact introduction date
could not be recovered — recorded here honestly rather than guessed.

### Files modified

| File | Date |
|---|---|
| `Chart.yaml` | 2026-10-02 |
| `values.yaml` (image repository + tag for `image` and `keycloakConfigCli.image`) | 2026-10-02 |
| `values.yaml` (`realmHardening`, `masterRealmPublicBlock` blocks) | not precisely datable, predates 2026-10-01 |

### Files added

| File | Date |
|---|---|
| `templates/realm-hardening-job.yaml` | not precisely datable, predates 2026-10-01 |
| `templates/master-realm-block-route.yaml` | not precisely datable, predates 2026-10-01 |
| `NOTICE.EDNEL.md` (this file) | 2026-10-06 |

No file present in the upstream `keycloak/25.2.0` tag was removed or modified beyond what is
listed above. The complete diff is in [`UPSTREAM.diff`](UPSTREAM.diff) in this same directory
(covers `Chart.yaml`, `values.yaml` and `templates/`; the vendored `charts/postgresql` and
`charts/common` subcharts are declared Helm dependencies resolved from
`oci://registry-1.docker.io/bitnamicharts`, not independently modified copies, and are not
included in the diff).
