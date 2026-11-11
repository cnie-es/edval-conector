{{/* "true" si el Operator sirve el Service keycloak y el StatefulSet Bitnami no se renderiza. */}}
{{- define "keycloak.operatorCutover" -}}
{{- if and .Values.operator.enabled .Values.operator.cutover -}}true{{- end -}}
{{- end -}}

{{/* "true" si los initContainers del CR bajan los config-files con token (Secret keycloak-op-config-token). */}}
{{- define "keycloak.operatorConfigToken" -}}
{{- $op := .Values.operator -}}
{{- if eq ($op.secretsSource | default "eso") "job" -}}
{{- if $op.secretsJob.configFilesToken -}}true{{- end -}}
{{- else if and $op.configFilesTokenSecret $op.configFilesTokenSecret.path -}}true{{- end -}}
{{- end -}}
