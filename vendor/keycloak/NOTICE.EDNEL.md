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
| Dates of modification | see table below; confirmed commits on **2026-10-02**, 2026-10-14, 2026-10-19, 2026-11-11 and 2026-11-17, the rest not precisely datable from the history available (see note) |

The modifications are licensed under the same terms as the original work (Apache License 2.0);
Section 4(b) requires every modified file to carry a notice that it was changed, which this file
provides collectively for the whole directory in lieu of per-file headers.

### Summary of the changes

Confirmed by a real diff against the `keycloak/25.2.0` tag (not assumed, regenerated on
2026-11-17). Until 2026-11-11 no existing Bitnami template was modified. Since then, three upstream
templates carry small, flag-gated guards for the Keycloak Operator cutover (see the last bullet);
with `operator.enabled=false` (the default) they render exactly as upstream. The rest of the fork
is additive plus two deliberate image substitutions:

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
- **Onboarding e-mail Job** (`templates/send-credentials-email-job.yaml`, `sendCredentialsEmail.*`,
  disabled by default; 2026-10-14, 2026-10-19 and 2026-11-17): after the realm import it calls
  Keycloak's `execute-actions-email` for the participant's admin user(s), because Keycloak does not
  send the set-password link by itself. It only sends while the user still has required actions.
  Since 2026-11-17 it adds `VERIFY_EMAIL` to the link when the user's e-mail is not verified:
  Keycloak 26.8 only marks the e-mail as verified when the link carries that action (26.3.2 always
  did), so without it the user would get a second, verification e-mail.
- **Keycloak 26.8.1 with the Keycloak Operator** (2026-11-11), replacing the Bitnami 26.3.2
  StatefulSet, gated by `operator.enabled` / `operator.cutover` (both `false` by default):
  - Added `templates/_operator.tpl` (helpers), `templates/operator-keycloak.yaml` (the `Keycloak`
    CR, official `quay.io/keycloak/keycloak` image), `templates/operator-externalsecrets.yaml` and
    `templates/operator-secrets-job.yaml` (admin and config-files credentials from OpenBao, through
    ESO or a Job), plus the matching `operator.*` block in `values.yaml`.
  - Modified upstream templates, only behind the `cutover` flag: `statefulset.yaml` and
    `headless-service.yaml` are not rendered after the cutover, and `service.yaml` keeps its name
    and port but selects the Operator's pods (target port 8080). `headless-service-ispn.yaml` gets
    the same guard.
  - The Operator itself is a separate vendored chart, `vendor/keycloak-operator` (see its own
    `NOTICE.EDNEL.md`).

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
| `values.yaml` (`sendCredentialsEmail` block) | 2026-10-14, 2026-10-19 |
| `values.yaml` (`operator` block) | 2026-11-11 |
| `templates/statefulset.yaml` (not rendered after the Operator cutover) | 2026-11-11 |
| `templates/headless-service.yaml` (not rendered after the Operator cutover) | 2026-11-11 |
| `templates/headless-service-ispn.yaml` (not rendered after the Operator cutover) | 2026-11-11 |
| `templates/service.yaml` (selector and target port of the Operator's pods after the cutover) | 2026-11-11 |

### Files added

| File | Date |
|---|---|
| `templates/realm-hardening-job.yaml` | not precisely datable, predates 2026-10-01 |
| `templates/master-realm-block-route.yaml` | not precisely datable, predates 2026-10-01 |
| `templates/send-credentials-email-job.yaml` | 2026-10-14 (changed 2026-10-19 and 2026-11-17) |
| `templates/_operator.tpl` | 2026-11-11 |
| `templates/operator-keycloak.yaml` | 2026-11-11 |
| `templates/operator-externalsecrets.yaml` | 2026-11-11 |
| `templates/operator-secrets-job.yaml` | 2026-11-11 |
| `NOTICE.EDNEL.md` (this file) | 2026-10-06 (updated 2026-11-17) |
| `UPSTREAM.diff` | 2026-10-06 (regenerated 2026-11-17) |

No file present in the upstream `keycloak/25.2.0` tag was removed or modified beyond what is
listed above. The complete diff is in [`UPSTREAM.diff`](UPSTREAM.diff) in this same directory
(covers `Chart.yaml`, `values.yaml` and `templates/`; the vendored `charts/postgresql` and
`charts/common` subcharts are declared Helm dependencies resolved from
`oci://registry-1.docker.io/bitnamicharts`, not independently modified copies, and are not
included in the diff).
