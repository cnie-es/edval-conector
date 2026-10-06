# Procedencia

**Este chart no es una modificación de ningún chart público.** Es trabajo original del equipo
EDNEL-RIOJA para el proyecto EDVAL-CNIE, sin origen de terceros.

| | |
|---|---|
| Autor | EDNEL-RIOJA project team, para CNIE-ES |
| Origen público | Ninguno — no existe un chart equivalente en SIMPL-open ni en ningún otro proyecto público conocido |
| Qué hace | Siembra en el OpenBao común las credenciales/claves necesarias para que un participante data-provider pueda operar (vía autenticación Kubernetes), más la generación de los pares de claves de transferencia EDC y el secreto de cifrado (`cipher-secret-job.yaml`) |
| Fecha de incorporación a este repositorio | 2026-10-01 (commit `db0e383`), con un ajuste posterior el 2026-10-02 (commit `084e0c3`, imagen `kubectl` con shell) |

No aplica LICENSE/NOTICE de terceros ni diff contra un original, porque no hay ningún chart
público del que este se derive: es lógica propia (`job.yaml`, `edc-transfer-keypair-job.yaml`,
`cipher-secret-job.yaml`, `rbac.yaml`) escrita para este proyecto, que únicamente consume
imágenes públicas de terceros (`docker.io/alpine/kubectl`) sin modificarlas.
