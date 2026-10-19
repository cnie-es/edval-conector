# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## EDVAL

Cambios propios del despliegue de EDVAL, sobre la base de SIMPL. Las versiones
son los tags `v3.1.x` del repo, que es lo que referencia el gitops.

### No publicado

#### Added
- `keycloak.adminUser` (`firstName`, `lastName`, `email`): la
  identidad del usuario admin del participante se puede fijar por participante
  desde el gitops (`participantOverrides.<ns>.adminUser`), en vez de la
  identidad ficticia fija (`Admin` / `Dataprovider` / `admin.dataprovider@email.com`).
  El `username` no se parametriza: el realm tiene `registrationEmailAsUsername`,
  así que Keycloak lo sustituye por el email. Los valores por defecto son los que ya traía el
  realm, así que sin override el comportamiento no cambia.
  Va con `dataspace-config-files#2` y `edval-gitops#168`.

  Nota: el import de Keycloak es `IGNORE_EXISTING`, así que solo aplica en
  despliegues desde cero.

- SMTP en el realm del participante: se inyectan `SMTP_HOST`, `SMTP_PORT`,
  `SMTP_STARTTLS`, `SMTP_USERNAME` y `SMTP_PASSWORD` desde el Secret
  `notification-smtp` (el mismo de notification-service y del realm de la
  authority; no se crean credenciales nuevas) y se añaden al `envsubst`.

  Hace falta para que Keycloak pueda mandar al admin el correo de
  `UPDATE_PASSWORD`: hasta ahora el realm tenía `smtpServer: {}` y no podía
  enviar nada. Requiere `edval-gitops#169`, que replica el Secret al namespace
  del participante. Va con `dataspace-config-files#8`.

#### Fixed
- Correo de alta del conector externo: el Job `send-credentials-email` buscaba los
  usuarios fijos `admin.dataprovider` y `tecnico.dataprovider`, que no existen en el
  realm externo (un único usuario, con el email como username). No encontraba a nadie,
  dejaba un `WARN` y terminaba en verde sin mandar nada.
  - Nuevo `keycloak.singleAdminUser` (`false` por defecto, `true` en
    `values-external.yaml`): con él, el correo se manda a `keycloak.adminUser.email`.
  - La búsqueda del usuario es exacta (`exact=true`).
  - El Job falla si no existe ninguno de los usuarios, en vez de acabar en verde.
  - No se reenvía el correo a quien ya completó el alta (sin `requiredActions`). Antes
    llegaba de nuevo en cada sync de la Application.

## [3.0.0] - 2026-02-25
- Updated many components to implement Data Provider version 3.0.0.
- SIMPL FE component separated into multiple FE components.


## Tier 1 Gateway

#### 2.8.0 (2025-12-02)

#### Added
- SIMPL-19396
- Configured RBAC for Users Roles V2 API's

#### Fixed
- Business logger handling missing email claim

#### Changes
- Updated BusinessLogger to new common logging library


### Users & Roles BE

#### 2.8.0 (2025-12-01)

#### Added
- SIMPL-19892
- SIMPL-19899
- SIMPL-19894
- SIMPL-19900
- SIMPL-19895
- SIMPL-19897
- SIMPL-19398
- SIMPL-19893

#### Changes
- SIMPL-19398
- SIMPL-19893


### Users & Roles FE

#### 2.8.0 (2025-12-01)
No changes.


### Tier 2 Gateway

#### 2.8.0 (2025-12-02)

#### Added
- SIMPL_19397

#### Fixed
- Business logger handling missing email claim

#### Changed
- Updated BusinessLogger to new common logging library


## Tier 2 Proxy

#### 1.2.1 (2025-12-04)

#### Fixed
- Fixed Helm Chart version

#### 1.2.0 (2025-12-02)

#### Added
- SIMPL-19508


### Authentication Provider BE

#### 2.8.0 (2025-12-02)

#### Added
- SIMPL-18664

#### Fixed
- SIMPL-20267


### Authentication Provider FE

#### 2.8.0 (2025-12-01)

#### Added
- SIMPL-19506
- SIMPL-18694


### SD Creator BE

#### 1.19.0 (2025-11-28)

#### Added
- SIMPL-18370

#### Fixed
- SIMPL-20962
- SIMPL-15786
- SIMPL-16831
- SIMPL-19440
- SIMPL-18630
- SIMPL-17715


### SD Creator FE

#### 1.5.0 (2025-12-01)

#### Added
- SIMPL-2295
- SIMPL-10289


### SD Creation Wizard BE

#### 1.17.0 (2025-11-28)

#### Fixed
- SIMPL-18630


### XFSC Advsearch BE

#### 1.18.0 (2025-11-28)

#### Changed
- aligned to commons 1.8.0 to use new LogUtil


### EDC Connector Adapter

#### 1.10.1 (2025-11-28)

#### Changed
- SIMPL-20687

#### 1.10.0 (2025-11-24)

#### Fixed
- SIMPL-20284
- SIMPL-20226
- SIMPL-9033
- SIMPL-18632


### Simpl EDC

#### 1.0.15 (2025-12-01)

#### Changed
- SIMPL-20001
- SIMPL-20102


### Catalogue Client FE

#### 2.2.0 (2025-12-02)
No changes.


### Simpl Files

#### 1.2.0 (2025-11-05)

#### Fixed
- SIMPL-20108
- SIMPL-19116

#### Changed
- SIMPL-18339
- SIMPL-16125


### Infrastructure BE

#### 1.3.1 (2025-12-19)

#### Added
- SIMPL-19980
- SIMPL-19979
- SIMPL-19444

#### Fixed
- SIMPL-20119

#### Changed
- SIMPL-13381
- SIMPL-20323
- SIMPL-20331
- SIMPL-20345


### Infrastructure FE

#### 1.2.0 (2025-11-27)

#### Added
- SIMPL-19979
- SIMPL-19982
- SIMPL-19981
- SIMPL-19978
- SIMPL-20457
- SIMPL-19713
- SIMPL-18325
- SIMPL-17399
- SIMPL-18325
- SIMPL-18319
- SIMPL-17405

#### Fixed
- Fixed list provisioner Displaying all in dropdown
- SIMPL-19954
- SIMPL-19691
- SIMPL-19698
- SIMPL-20323
- SIMPL-17403

#### Changed
- SIMPL-19954
- SIMPL-19982
- SIMPL-19713
- SIMPL-20457
- SIMPL-17405
- SIMPL-18315
- SIMPL-13616
- SIMPL-11314


### Infrastructure Crossplane

#### 2.1.2 (2025-11-28)

#### Fixed
- Prevent message duplication for argo workflows
- SIMPL-18784
- SIMPL-19977


### Filebeat

#### 0.3.1 (2025-11-28)

#### Fixed
- SIMPL-21094


### Contract Manager BE

#### 2.5.0 (2025-11-28)
No changes.