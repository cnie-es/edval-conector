{{/*
Dominio en el que se publican los hosts de la AUTHORITY (authority-be, authority-fe, tls-authority).

INTERNO (embeddedCommon.enabled=false, el default):
  el domainSuffix del propio participante. Comportamiento historico, intacto: un participante creado
  en el mismo cluster que la authority comparte dominio con ella. Es el caso de prodddl, prodisbl y
  prodcnie en c1, que NO reciben projectStage; por eso la derivacion va condicionada y no puede
  afectarles.

EXTERNO (embeddedCommon.enabled=true, lo activa values-external.yaml):
  el participante tiene dominio propio, pero la authority vive en otro. Se deriva del projectStage
  DE LA AUTHORITY contra la que se onboarda (no el del participante):

      prod         -> vallelengua.es
      dev o vacio  -> example.invalid      <- on-prem (vclusters). En el repo de GitHub: telefonicadev.com

  authorityDomainSuffix, si se define, manda sobre todo lo anterior: escape hatch para onboardarse
  contra un dataspace distinto de este.
*/}}
{{- define "connector.authorityDomain" -}}
{{- if not .Values.embeddedCommon.enabled -}}
{{- .Values.domainSuffix -}}
{{- else if .Values.authorityDomainSuffix -}}
{{- .Values.authorityDomainSuffix -}}
{{- else if eq (.Values.projectStage | default "") "prod" -}}
vallelengua.es
{{- else -}}
example.invalid
{{- end -}}
{{- end -}}

{{/*
Dominio de los endpoints de PLATAFORMA del common (OpenBao secrets-<common>, collector-<common>).
Son servicios internos: con internalDomainSuffix (p. ej. example.invalid) salen por el LB interno
de APISIX, mientras los hosts funcionales del participante (participant-be/fe, public-be,
tls-participant, files...) siguen en domainSuffix.

Sin internalDomainSuffix vale domainSuffix: comportamiento historico intacto.
*/}}
{{- define "connector.internalDomain" -}}
{{- .Values.internalDomainSuffix | default .Values.domainSuffix -}}
{{- end -}}

{{/*
Nombre del Secret con la CA que vault-env debe usar para validar el endpoint de OpenBao
(vault-addr). Devuelve cadena vacia si no hace falta ninguna, y entonces no se emite la
anotacion: es el caso de un endpoint con certificado de CA publica, como prod.

Dos formas de aportarla, segun quien despliega:

  secrets.tlsSecret   referencia a un Secret QUE YA EXISTE en el namespace, con la clave
                      ca.crt. Es lo que usan los participantes internos: el gitops del
                      cluster (chart wildcard-cert) emite private-ca-tls en cada
                      namespace, y basta con nombrarlo.

  secrets.caBundle    la CA en PEM, aqui mismo. El chart crea el Secret el solo. Es la via
                      para un participante EXTERNO: despliega su propio OpenBao en su
                      dominio, con su CA, y no tiene ningun Secret nuestro que referenciar
                      ni cert-manager con nuestros issuers. Un certificado de CA es material
                      publico, no un secreto, asi que puede ir en su values.

tlsSecret manda si se ponen los dos.
*/}}
{{- define "connector.vaultCaSecret" -}}
{{- if .Values.secrets.tlsSecret -}}
{{- .Values.secrets.tlsSecret -}}
{{- else if .Values.secrets.caBundle -}}
{{- printf "%s-vault-ca" .Values.cluster.namespace -}}
{{- end -}}
{{- end -}}

{{/*
Huella de la password de Redis, para colgarla como anotacion del pod de Redis Y de todos sus
clientes. Sin esto una rotacion del Secret es un fallo SILENCIOSO: cada pod resuelve la password
UNA sola vez, al arrancar (es una env desde un secretKeyRef, no se refresca), asi que el primero
que se reinicie por cualquier motivo -- un sync, un desalojo, un rollout -- se queda con un valor
distinto al del resto y Redis contesta "WRONGPASS invalid username-password pair". Todos los pods
siguen en Running y sin reinicios, que es lo que hace que cueste tanto verlo. Paso el 2026-08-31
en cniestage: el authentication-provider se reinicio con un sync, Redis llevaba 2 dias levantado,
y la negociacion EDC murio con un NullPointerException tres saltos mas abajo.

OJO: el chart de Redis ya trae un `checksum/secret`, pero esta calculado sobre su propia plantilla
de Secret, que aqui no renderiza nada (se usa auth.existingSecret). Su valor es el SHA-256 de "{}"
y por tanto NO cambia nunca. No sirve de guardarrail; este helper si.

Si el lookup no resuelve devuelve un valor fijo, para no provocar un reinicio en cascada de todos
los clientes cada vez que un render se quede sin acceso al cluster.
*/}}
{{- define "connector.redisSecretChecksum" -}}
{{- $s := lookup "v1" "Secret" .Values.cluster.namespace "redis-secrets" -}}
{{- if and $s (index ($s.data | default dict) "redis") -}}
{{- index $s.data "redis" | sha256sum | trunc 16 -}}
{{- else -}}
sin-lookup
{{- end -}}
{{- end -}}

{{/*
Secret TLS del ingress de OpenBao (secrets-<common>.<dominio interno>).
  - tls.perHost: true   -> secrets-<common>-tls, que emite cert-manager con cluster.issuer.
  - si no               -> tls.secretName o, en su defecto, el wildcard "wildcard-tls" de siempre.
*/}}
{{- define "connector.openbaoTlsSecret" -}}
{{- if (.Values.tls).perHost -}}
{{- printf "secrets-%s-tls" .Values.namespaceTag.common -}}
{{- else -}}
{{- (.Values.tls).secretName | default "wildcard-tls" -}}
{{- end -}}
{{- end -}}

{{/*
Values para que un servicio Java confie en una CA privada (caTrust.enabled), p. ej. la
CNIE Internal CA que firma los *.cnie.internal de una authority on-prem.

Los charts de tier1-gateway, tier2-gateway y authentication-provider-be no tienen soporte
propio, pero si aceptan volumes, volumeMounts y envFrom. Se monta el Secret java-truststore
(lo genera templates/ca-truststore.yaml: cacerts del JVM + caTrust.caBundle) y se apunta el
JVM con JAVA_TOOL_OPTIONS. Las listas sustituyen a las del chart, asi que se repiten sus
entradas por defecto (los ConfigMaps de configuracion de cada uno).
*/}}
{{- define "connector.javaTrustValues" -}}
{{- if .root.Values.caTrust.enabled -}}
{{- $defaults := dict
  "tier1-gateway" (dict "cm" "tier1-gateway-spring-configmap" "env" "tier1-gateway-env-configmap")
  "tier2-gateway" (dict "cm" "tier2-gateway-spring-configmap" "env" "tier2-gateway-env-configmap")
  "authentication-provider-be" (dict "cm" "authentication-provider-be-configmap" "env" "")
-}}
{{- $d := index $defaults .chart -}}
volumes:
  - name: spring-config
    configMap:
      name: {{ $d.cm }}
  - name: java-truststore
    secret:
      secretName: java-truststore
volumeMounts:
  - name: spring-config
    mountPath: /config/
  - name: java-truststore
    mountPath: /truststore
    readOnly: true
envFrom:
  {{- with $d.env }}
  - configMapRef:
      name: {{ . }}
  {{- end }}
  - configMapRef:
      name: java-truststore-env
{{- end -}}
{{- end -}}
