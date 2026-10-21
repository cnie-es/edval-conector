{{/*
Plantilla del pod de role-identity-attributes, compartida por el CronJob (deployer) y por el hook
PostSync de la Application grande (vendor/role-identity-attributes-hook). Parametro: dict con
"root" (el contexto del chart) y "retries" (reintentos si aun faltan atributos; 0 en el CronJob).
*/}}
{{- define "connector.roleIdentityAttributes.podTemplate" -}}
{{- $root := .root -}}
{{- $mapping := toJson $root.Values.roleIdentityAttributes.mapping -}}
metadata:
  annotations:
    sidecar.istio.io/inject: "false"
    vault.security.banzaicloud.io/vault-addr: "https://secrets-{{ $root.Values.namespaceTag.common }}.{{ include "connector.internalDomain" $root }}"
    {{- with include "connector.vaultCaSecret" $root }}
    vault.security.banzaicloud.io/vault-tls-secret: {{ . }}
    {{- end }}
    vault.security.banzaicloud.io/vault-role: {{ $root.Values.secrets.role }}
    vault.security.banzaicloud.io/vault-env-image: "ghcr.io/bank-vaults/vault-env:v1.22.1"
spec:
  restartPolicy: Never
  serviceAccountName: role-identity-attributes-sa
  automountServiceAccountToken: true
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
    - name: script
      configMap:
        name: role-identity-attributes-script
    # vault-secrets-webhook deja /vault/ como unico montaje y se pierde el token del SA, que
    # usa kubectl para el ConfigMap de estado. Se monta explicito (igual que realm-hardening).
    - name: sa-token
      projected:
        sources:
          - serviceAccountToken:
              path: token
              expirationSeconds: 3600
          - configMap:
              name: kube-root-ca.crt
              items:
                - key: ca.crt
                  path: ca.crt
          - downwardAPI:
              items:
                - path: namespace
                  fieldRef:
                    fieldPath: metadata.namespace
  containers:
    - name: apply
      image: {{ $root.Values.roleIdentityAttributes.image | quote }}
      command: ["/bin/bash", "/scripts/apply.sh"]
      env:
        - name: NAMESPACE
          value: {{ $root.Values.cluster.namespace | quote }}
        - name: STATE_CM
          value: role-identity-attributes-state
        - name: MAPPING
          value: {{ $mapping | quote }}
        - name: MAPPING_HASH
          value: {{ $mapping | sha256sum | trunc 16 | quote }}
        # El hook PostSync espera un rato a que la authority haya sincronizado los atributos; el
        # CronJob no espera (lo vuelve a intentar en la siguiente pasada).
        - name: ATTR_RETRIES
          value: {{ .retries | default 0 | quote }}
        - name: ATTR_RETRY_SECONDS
          value: "20"
        - name: USERS_ROLES_URL
          value: "http://users-roles.{{ $root.Values.cluster.namespace }}.svc.cluster.local:8080"
        - name: AUTH_PROVIDER_URL
          value: "http://authentication-provider.{{ $root.Values.cluster.namespace }}.svc.cluster.local:8080"
        - name: KEYCLOAK_URL
          value: "http://keycloak.{{ $root.Values.cluster.namespace }}.svc.cluster.local"
        - name: KEYCLOAK_REALM
          value: participant
        - name: KEYCLOAK_CLIENT_ID
          value: cli
        - name: KC_ADMIN_USER
          value: admin
        - name: KC_ADMIN_PASSWORD
          value: "vault:{{ $root.Values.secrets.secretEngine }}/data/{{ $root.Values.cluster.namespace }}-keycloak#admin"
      volumeMounts:
        - name: script
          mountPath: /scripts
        - name: sa-token
          mountPath: /var/run/secrets/kubernetes.io/serviceaccount
          readOnly: true
      resources:
        requests:
          cpu: 10m
          memory: 32Mi
        limits:
          memory: 128Mi
{{- end -}}
