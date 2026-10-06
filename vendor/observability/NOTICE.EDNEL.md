# Procedencia

**Este chart no es una modificación de ningún chart público.** Es trabajo original del equipo
EDNEL-RIOJA para el proyecto EDVAL-CNIE, sin origen de terceros — y, en concreto, **no** es una
copia ni derivado de `eck-monitoring` (ese es un stack de monitorización distinto, basado en
Elastic Cloud on Kubernetes, que vive en el chart orquestador `simpl-participant-connector` y no
está vendorizado en este repositorio).

| | |
|---|---|
| Autor | EDNEL-RIOJA project team, para CNIE-ES |
| Origen público | Ninguno — no existe un chart equivalente en SIMPL-open ni en ningún otro proyecto público conocido |
| Qué hace | Sondeo de los frontales/ingress desde fuera (blackbox-exporter), objetos de descubrimiento para el Prometheus Operator externo (`Probe`/`PodMonitor`), y las reglas de alerta críticas del espacio de datos |
| Documento de origen de las reglas de alerta | `alertas_críticas_edval.txt` (documento interno del proyecto EDVAL, no público) |
| Fecha de incorporación a este repositorio | 2026-10-01 (commit `db0e383`), con un ajuste posterior el 2026-10-02 (commit `29fe713`, origen de imágenes) |

No aplica LICENSE/NOTICE de terceros ni diff contra un original, porque no hay ningún chart
público del que este se derive: las plantillas (`blackbox-exporter.yaml`, `podmonitors.yaml`,
`probes.yaml`, `prometheusrule.yaml`) son lógica propia escrita para este proyecto, que únicamente
consume la imagen pública de `blackbox_exporter` sin modificarla. El propio `Chart.yaml` ya
documenta esta procedencia en su `description`.
