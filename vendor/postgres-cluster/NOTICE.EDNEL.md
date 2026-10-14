# Modification notice (EUPL 1.2, Art. 5)

**This is a modified version of the SIMPL-open postgres-cluster Helm chart. It is not the
original work.**

The original work is part of the SIMPL programme (© European Union / SIMPL Programme) and is
licensed under the **European Union Public Licence v. 1.2 (EUPL-1.2)**. See [LICENSE](LICENSE),
where the full official text of the licence is reproduced (the upstream `LICENSE` file only linked
to it). All original copyright, licence and disclaimer notices are kept intact and unmodified in
this fork.

## Upstream baseline

| | |
|---|---|
| Original work | postgres-cluster-chart (Helm chart name: `pg-cluster`) |
| Upstream repository | https://code.europa.eu/simpl/simpl-open/data/supporting-data-services/persistence/postgres/postgres-cluster-chart |
| Baseline version | `v1.1.0` |
| Baseline commit | `feaaa1593267` (2025-12-18, segun la API de GitLab del proyecto) |

Solo se vendorizo el subdirectorio `charts/` del proyecto upstream (el propio chart de Helm); el
resto de ficheros de este directorio (`README.md`, `CHANGELOG.md`, `LICENSE`,
`pipeline.variables.sh`, `documents/`) tambien provienen de ese mismo proyecto, salvo donde se
indica lo contrario abajo.

## Modifications

| | |
|---|---|
| Modified by | EDNEL-RIOJA project team, for CNIE-ES |
| Dates of modification | 2026-10-01 a 2026-10-02 |

Este chart no tiene publicacion propia en `cnie-es` (a diferencia de los 9 componentes EDVAL): se
distribuye unicamente vendorizado dentro de este mismo repositorio, siguiendo lo acordado el
2026-10-06 (se documenta aqui en vez de llevarlo a un repositorio propio en `cnie-es`).

Las modificaciones estan licenciadas bajo la misma **EUPL-1.2** que la obra original.

El diff completo contra el baseline esta en [UPSTREAM.diff](UPSTREAM.diff) de este mismo
directorio (generado comparando el `charts/` descargado del tag `v1.1.0` contra `charts/` tal y
como esta hoy aqui).

### Resumen de los cambios

- **Bug real del chart publico**: usa el nombre de cada agente (p. ej. `authorityList`,
  `consumerList`, `providerList`) tal cual, con guiones, como parte del nombre de usuario/base de
  datos de Postgres (p. ej. `{{ . }}_keycloak`). Un guion no es un caracter valido en un
  identificador SQL sin comillas, asi que cualquier participante cuyo nombre de namespace lleve un
  guion (el caso mas comun en Kubernetes) rompe la creacion de TODAS sus bases de datos. El arreglo
  calcula `{{- $db := . | replace "-" "_" }}` al principio de cada `range` y usa `$db` en vez del
  nombre original en todos los usuarios/bases de datos generados.
- **Imagen y storage class configurables**: el chart publico no expone ninguna clave de values
  para elegir la imagen del operador Postgres ni la `storageClass` del volumen -- `dockerImage` y
  `volume.storageClass` ahora se generan desde `.Values.image.{registry,repository,tag}` y
  `.Values.storageClass` (nuevas claves en `values.yaml`, con default `ghcr.io/zalando/spilo-17:
  4.0-p2` para la imagen).
- **`_contract_consumer` para el agente hibrido** (commit `c5483ab`, 2026-10-02): un participante
  que corre a la vez `contract` (provider) y una 2a instancia en modo consumer dentro del mismo
  namespace (el caso "hibrido") necesita un usuario/base de datos propio para esa 2a instancia de
  Contract Manager BE. El resto del repo (`application.yaml`, `openbao-seeder`) ya sembraba
  credenciales para ese caso, pero este chart nunca creaba el usuario/base correspondiente -- el
  `vault-agent-init` de la instancia consumer se quedaba esperando indefinidamente un secreto que
  el seeder nunca podia terminar de sembrar.
- Ademas del listado anterior (los 3 motivos documentados de por que se vendorizo), el diff real
  incluye roles/bases de datos (`_drupal`, `_onlyoffice`, `_gnoss_acid` para `authorityList`) que
  no estaban documentados en la investigacion previa de este repositorio -- se listan aqui por
  completitud, verificados contra el diff real, pero no se ha podido confirmar con certeza el
  commit/fecha exacto en el que se anadieron (la unica fecha verificable para todo el fichero
  `templates/pg-cluster.yaml` es el rango 2026-10-01 a 2026-10-02 de arriba).

### Discrepancia encontrada (no es una modificacion intencional)

`CHANGELOG.md` en este directorio se queda en la entrada `## 1.0.1 (2025-07-16)`, pero el
`CHANGELOG.md` real del tag `v1.1.0` upstream ya incluye una entrada posterior, `## 1.1.0
(2025-12-17)`, que falta aqui. Parece un descuido al vendorizar (no se copio el CHANGELOG
actualizado), no una decision deliberada -- se deja constancia en vez de corregirlo en silencio,
para que quien lo revise decida si hace falta actualizarlo.

### Ficheros modificados

| Fichero (relativo a `charts/`) | Fecha |
|---|---|
| `Chart.yaml` | 2026-10-01 a 2026-10-02 |
| `values.yaml` | 2026-10-01 a 2026-10-02 |
| `templates/pg-cluster.yaml` | 2026-10-01 a 2026-10-02 |

### Ficheros añadidos (no existen en el baseline upstream)

| Fichero | Fecha |
|---|---|
| `README.md` (raiz de `vendor/postgres-cluster/`) | no verificable con certeza; el proyecto upstream no publica README.md en absoluto |
| `NOTICE.EDNEL.md` (este fichero) | 2026-10-06 |
| `UPSTREAM.diff` | 2026-10-06 |

El unico cambio a [LICENSE](LICENSE) es la adicion del texto oficial integro de la EUPL-1.2 debajo
de la cabecera original (que antes solo enlazaba a el); no se ha quitado ni reescrito nada del
fichero original.

No se ha alterado ningun aviso de copyright, licencia o renuncia de responsabilidad de la obra
original.
