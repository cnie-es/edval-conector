# Modification notice (EUPL 1.2, Art. 5)

**This is a modified version of SIMPL tier1-gateway. It is not the original work.**

The original work, tier1-gateway, is part of the SIMPL programme (© European Union / SIMPL
Programme) and is licensed under the **European Union Public Licence v. 1.2 (EUPL-1.2)**. See
[LICENSE](LICENSE), where the full official text of the licence is reproduced. All original
copyright, licence and disclaimer notices are kept intact and unmodified in this fork.

## Upstream baseline

| | |
|---|---|
| Original work | tier1-gateway |
| Upstream repository | https://code.europa.eu/simpl/simpl-open/development/iaa/tier1-gateway |
| Baseline commit | `07fb0b5fabb7b166c74ae28989ad5d7359998d0e` (2026-07-21), latest on `main` at the
time this notice was written |
| Baseline chart version | `2.16.0-rc.1379` |

The upstream chart does not publish tagged Helm releases: `charts/Chart.yaml` carries
`${PROJECT_RELEASE_VERSION}` as a template placeholder, substituted by the upstream CI pipeline at
build time rather than by a Git tag. There is therefore no exact upstream tag matching
`2.16.0-rc.1379` (the version pinned in our own `Chart.yaml`, which this fork reached for by
substituting the same placeholder with the value already present in our deployment) — the baseline
above is the latest commit on `main`, which is the closest verifiable reference.

## Modifications

| | |
|---|---|
| Modified by | EDNEL-RIOJA project team, for CNIE-ES |
| Vendored inside | `vendor/tier1-gateway` of this repository (`simpl-participant-connector-dist`) |
| Dates of modification | **2026-10-02** |

The modifications are licensed under the **EUPL-1.2**, the same licence as the original work.

This fork is not published as its own standalone component with a public repository: it is
vendored directly inside this distribution repository, as agreed for charts whose public upstream
cannot be used unmodified and has no other home in `cnie-es`. The complete diff against the
upstream chart (`charts/` subdirectory of the upstream repository, at the baseline commit above) is
kept alongside this notice, in [UPSTREAM.diff](UPSTREAM.diff).

### Summary of the changes

- **Ingress class configurable (`templates/ingress.yaml`)**: the upstream chart hardcodes
  `ingressClassName: nginx`, with no values key to change it. The clusters this connector deploys to
  only run an APISIX ingress controller, so the chart never worked unmodified. Changed to
  `{{ .Values.ingress.className | default "apisix" }}` — the upstream behaviour (nginx) remains the
  default for anyone else consuming this fork unmodified; only the default value differs.
- **Ingress path for APISIX (`templates/ingress.yaml`)**: the single Ingress rule uses
  `pathType: ImplementationSpecific`. With APISIX's classic ingress controller this path type takes
  the path literally rather than as a prefix match, so upstream's `path: /` only ever matched the
  root and every other route (`/auth`, `/cli`, ...) returned 404. Changed to `path: /*`; this has no
  effect under nginx (verified against upstream's own `ingress.yaml`, not just asserted).
- **Spring profile handling restructured (`templates/env-configmap.yaml`, `values.yaml`)**: upstream
  defaults `profile` to `"authority"` in `values.yaml`, and only emits `SPRING_PROFILES_ACTIVE` and
  the four authority-specific URL env vars (`ONBOARDING_URL`, `EJBCA_URL`, `IDENTITY_PROVIDER_URL`,
  `SAP_URL`) when `.Values.profile == "authority"` — so it already supported a non-authority
  profile in principle. This fork removes the `authority` default entirely (this connector only
  ever runs as `participant`/`dataprovider`, never `authority`), falls back to `"participant"` when
  unset, makes the four authority-only URLs individually optional (`with` instead of a bare `tpl`
  call, so an unset value is omitted instead of rendering an empty string), and adds a fifth
  optional URL, `consentManagementUrl` / `CONSENT_MANAGEMENT_URL`, not present upstream at all.
  **Correction against an earlier, unverified assumption**: `SPRING_PROFILES_ACTIVE` was not
  actually missing upstream — it was already emitted unconditionally from `.Values.profile`. What
  changed is the default value and the optionality of the four authority URLs, not the presence of
  the env var itself.
- **`values.yaml` housekeeping**: `image.repository`/`image.tag` point at the real published image
  (`code.europa.eu:4567/simpl/simpl-open/development/iaa/tier1-gateway:2.16.0-rc.1379`) instead of
  the upstream CI's own `${CI_REGISTRY_IMAGE}`/`${PROJECT_RELEASE_VERSION}` placeholders; a comment
  documenting the new `dataprovider` profile value and an example `appConfig.spring.profiles.active`
  snippet were added.

### Files modified

| File | Date |
|---|---|
| `Chart.yaml` | 2026-10-02 |
| `values.yaml` | 2026-10-02 |
| `templates/env-configmap.yaml` | 2026-10-02 |
| `templates/ingress.yaml` | 2026-10-02 |

No other file under `vendor/tier1-gateway` differs from the upstream chart at the baseline commit
above (`.helmignore`, `templates/_helpers.tpl`, `templates/deployment.yaml`, `templates/hpa.yaml`,
`templates/service.yaml`, `templates/serviceaccount.yaml`, `templates/spring-configmap.yaml` are
byte-identical). No file was added or removed relative to the upstream `charts/` tree.

No copyright, licence or disclaimer notice of the original work has been altered.

The per-file diff for every change is in [UPSTREAM.diff](UPSTREAM.diff), generated with:

```
diff -ru upstream/charts/ vendor/tier1-gateway/
```

against the upstream repository's `charts/` subdirectory at the baseline commit above.
