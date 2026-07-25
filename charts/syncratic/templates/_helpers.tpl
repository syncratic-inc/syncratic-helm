{{- define "syncratic.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "syncratic.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "syncratic.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.labels" -}}
app.kubernetes.io/name: {{ include "syncratic.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "syncratic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "syncratic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "syncratic.serviceAccountName" -}}
{{- printf "%s-default" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.bootstrapSecretName" -}}
{{- if .Values.security.existingSecret -}}
{{- .Values.security.existingSecret -}}
{{- else -}}
{{- printf "%s-bootstrap" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.authRuntimeSecretName" -}}
{{- if .Values.auth.runtimeSecret.existingSecret -}}
{{- .Values.auth.runtimeSecret.existingSecret -}}
{{- else if .Values.auth.runtimeSecret.create -}}
{{- printf "%s-auth-runtime" (include "syncratic.fullname" .) -}}
{{- else -}}
{{- include "syncratic.bootstrapSecretName" . -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.identityProvisioningSecretName" -}}
{{- if .Values.auth.identityProvisioning.secret.existingSecret -}}
{{- .Values.auth.identityProvisioning.secret.existingSecret -}}
{{- else -}}
{{- printf "%s-identity-provisioning" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.bootstrapSmtpSecretName" -}}
{{- if .Values.auth.bootstrapSmtp.configSecret.existingSecret -}}
{{- .Values.auth.bootstrapSmtp.configSecret.existingSecret -}}
{{- else if .Values.auth.bootstrapSmtp.passwordSecret.existingSecret -}}
{{- .Values.auth.bootstrapSmtp.passwordSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-bootstrap-smtp" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.helpGatewayTokenSecretName" -}}
{{- if .Values.help.gatewayTokenSecret.existingSecret -}}
{{- .Values.help.gatewayTokenSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-help-gateway" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.registrationAdminTokenSecretName" -}}
{{- if .Values.registration.adminTokenSecret.existingSecret -}}
{{- .Values.registration.adminTokenSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-registration-admin" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.registrationBootstrapAuthoritySecretName" -}}
{{- if .Values.registration.bootstrapAuthority.existingSecret -}}
{{- .Values.registration.bootstrapAuthority.existingSecret -}}
{{- else -}}
{{- printf "%s-registration-bootstrap-authority" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.registrationLesMtlsCaSecretName" -}}
{{- if .Values.registration.les.mtls.caSecret.existingSecret -}}
{{- .Values.registration.les.mtls.caSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-registration-les-mtls-ca" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.registrationLesInitialLicenseSecretName" -}}
{{- if .Values.registration.les.initialLicenseSecret.existingSecret -}}
{{- .Values.registration.les.initialLicenseSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-registration-les-initial-license" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.gatewayInitialOperatorBootstrapSecretName" -}}
{{- if .Values.gateway.initialOperatorBootstrapSecret.existingSecret -}}
{{- .Values.gateway.initialOperatorBootstrapSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-gateway-initial-operator-bootstrap" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.gatewayNotificationWebhookSecretName" -}}
{{- if .Values.gateway.notifications.webhook.tokenSecret.existingSecret -}}
{{- .Values.gateway.notifications.webhook.tokenSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-gateway-notification-webhook" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.evaluationRuntimeSecretName" -}}
{{- if .Values.evaluation.runtimeSecret.existingSecret -}}
{{- .Values.evaluation.runtimeSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-evaluation-runtime" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}


{{- define "syncratic.licensingPublicKeysConfigMapName" -}}
{{- if .Values.licensing.publicKeys.existingConfigMap -}}
{{- .Values.licensing.publicKeys.existingConfigMap -}}
{{- else -}}
{{- printf "%s-licensing-public-keys" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.licensingPublicKeysSecretName" -}}
{{- if .Values.licensing.publicKeys.existingSecret -}}
{{- .Values.licensing.publicKeys.existingSecret -}}
{{- else -}}
{{- printf "%s-licensing-public-keys" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.registrationPublicKeysConfigMapName" -}}
{{- if .Values.registration.publicKeys.existingConfigMap -}}
{{- .Values.registration.publicKeys.existingConfigMap -}}
{{- else -}}
{{- printf "%s-registration-public-keys" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.registrationPublicKeysSecretName" -}}
{{- if .Values.registration.publicKeys.existingSecret -}}
{{- .Values.registration.publicKeys.existingSecret -}}
{{- else -}}
{{- printf "%s-registration-public-keys" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.licensingControlPlaneTokenSecretName" -}}
{{- .Values.licensing.controlPlane.tokenSecret.existingSecret | trim -}}
{{- end -}}

{{- define "syncratic.licensingControlPlaneTlsConfigMapName" -}}
{{- .Values.licensing.controlPlane.tls.caConfigMap | trim -}}
{{- end -}}

{{- define "syncratic.licensingControlPlaneTlsCaSecretName" -}}
{{- .Values.licensing.controlPlane.tls.caSecret | trim -}}
{{- end -}}

{{- define "syncratic.licensingControlPlaneTlsClientSecretName" -}}
{{- .Values.licensing.controlPlane.tls.clientSecret | trim -}}
{{- end -}}

{{- define "syncratic.licensingRenewalRuntimeOutputSecretName" -}}
{{- if .Values.licensing.renewal.runtimeOutputSecret.existingSecret -}}
{{- .Values.licensing.renewal.runtimeOutputSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-licensing-renewal-runtime-output" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.licensingRenewalServiceAccountName" -}}
{{- printf "%s-licensing-renewal" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.gatewayUploadsPvcName" -}}
{{- printf "%s-gateway-uploads" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.redisUrl" -}}
{{- printf "redis://%s-redis:%v/0" (include "syncratic.fullname" .) .Values.redis.service.port -}}
{{- end -}}

{{- define "syncratic.postgresHost" -}}
{{- printf "%s-postgres" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.postgresUrl" -}}
{{- printf "postgresql+psycopg://%s:%s@%s:%v/%s" .Values.postgres.contract.applicationUser .Values.postgres.auth.password (include "syncratic.postgresHost" .) .Values.postgres.service.port .Values.postgres.contract.applicationDatabase -}}
{{- end -}}

{{- define "syncratic.postgresMigrationDsn" -}}
{{- printf "postgresql://%s:%s@%s:%v/%s" .Values.postgres.contract.applicationUser .Values.postgres.auth.password (include "syncratic.postgresHost" .) .Values.postgres.service.port .Values.postgres.contract.applicationDatabase -}}
{{- end -}}

{{- define "syncratic.qdrantUrl" -}}
{{- printf "http://%s-qdrant:%v" (include "syncratic.fullname" .) .Values.qdrant.service.port -}}
{{- end -}}

{{- define "syncratic.bgeEmbeddingsUrl" -}}
{{- printf "http://%s-bge-embeddings:%v" (include "syncratic.fullname" .) .Values.bgeEmbeddings.service.port -}}
{{- end -}}

{{- define "syncratic.llmFastUrl" -}}
{{- printf "http://%s-llm-fast:%v" (include "syncratic.fullname" .) .Values.llmFast.service.port -}}
{{- end -}}

{{- define "syncratic.llmDeepUrl" -}}
{{- printf "http://%s-llm-deep:%v" (include "syncratic.fullname" .) .Values.llmDeep.service.port -}}
{{- end -}}

{{- define "syncratic.neo4jUri" -}}
{{- printf "bolt://%s-neo4j:%v" (include "syncratic.fullname" .) .Values.neo4j.service.boltPort -}}
{{- end -}}

{{- define "syncratic.helpDataPvcName" -}}
{{- printf "%s-help-data" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.registrationDataPvcName" -}}
{{- printf "%s-registration-data" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.evaluationManagedSuitesPvcName" -}}
{{- printf "%s-evaluation-suites" (include "syncratic.fullname" .) -}}
{{- end -}}


{{- define "syncratic.postgresAuthSecretName" -}}
{{- if .Values.postgres.auth.existingSecret -}}
{{- .Values.postgres.auth.existingSecret -}}
{{- else -}}
{{- printf "%s-postgres-auth" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.externalConnectionSecretName" -}}
{{- .Values.externalServices.connectionSecret.existingSecret -}}
{{- end -}}

{{- define "syncratic.externalTrustBundleConfigMapName" -}}
{{- .Values.externalServices.trustBundle.existingConfigMap -}}
{{- end -}}

{{- define "syncratic.externalTrustBundleSecretName" -}}
{{- .Values.externalServices.trustBundle.existingSecret -}}
{{- end -}}

{{- define "syncratic.materialContractConfigMapName" -}}
{{- printf "%s-material-contract" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.externalSecretRemoteKey" -}}
{{- $prefix := .root.Values.materialPolicy.externalSecrets.remoteKeyPrefix | trimSuffix "/" -}}
{{- if $prefix -}}
{{- printf "%s/%s" $prefix .secretName -}}
{{- else -}}
{{- .secretName -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.testImageRepository" -}}
{{- default .Values.gateway.image.repository .test.image.repository | trim -}}
{{- end -}}

{{- define "syncratic.testImageTag" -}}
{{- default .Values.gateway.image.tag .test.image.tag | trim -}}
{{- end -}}

{{- define "syncratic.testImageDigest" -}}
{{- default "" (default .Values.gateway.image.digest .test.image.digest) | trim -}}
{{- end -}}

{{- define "syncratic.testImagePullPolicy" -}}
{{- default .Values.gateway.image.pullPolicy .test.image.pullPolicy | trim -}}
{{- end -}}

{{- define "syncratic.imageRepository" -}}
{{- $repository := .image.repository -}}
{{- $firstPartyRegistry := .Values.global.firstPartyImageRegistry | trimSuffix "/" -}}
{{- if and $firstPartyRegistry (hasPrefix "syncratic/" $repository) -}}
{{- printf "%s/%s" $firstPartyRegistry $repository -}}
{{- else -}}
{{- $repository -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.imageRef" -}}
{{- $repository := include "syncratic.imageRepository" . -}}
{{- $digest := printf "%v" (default "" .image.digest) | trim -}}
{{- if eq $digest "<nil>" -}}
{{- $digest = "" -}}
{{- end -}}
{{- if $digest -}}
{{- printf "%s@%s" $repository $digest -}}
{{- else -}}
{{- printf "%s:%s" $repository (printf "%v" .image.tag | trim) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.testImageRef" -}}
{{- include "syncratic.imageRef" (dict
  "Values" .Values
  "image" (dict
    "repository" (include "syncratic.testImageRepository" .)
    "tag" (include "syncratic.testImageTag" .)
    "digest" (include "syncratic.testImageDigest" .)
  )
) -}}
{{- end -}}

{{- define "syncratic.keycloakServiceName" -}}
{{- printf "%s-keycloak" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.keycloakDbServiceName" -}}
{{- printf "%s-keycloak-db" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.keycloakDbSecretName" -}}
{{- if .Values.keycloak.database.existingSecret -}}
{{- .Values.keycloak.database.existingSecret -}}
{{- else -}}
{{- printf "%s-keycloak-db" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.keycloakAdminSecretName" -}}
{{- if .Values.keycloak.adminSecret.existingSecret -}}
{{- .Values.keycloak.adminSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-keycloak-admin" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.keycloakRealmConfigMapName" -}}
{{- if .Values.keycloak.realm.existingConfigMap -}}
{{- .Values.keycloak.realm.existingConfigMap -}}
{{- else -}}
{{- printf "%s-keycloak-realm" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.keycloakRealmSecretName" -}}
{{- if .Values.keycloak.realm.existingSecret -}}
{{- .Values.keycloak.realm.existingSecret -}}
{{- else -}}
{{- printf "%s-keycloak-realm" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.keycloakThemeConfigMapName" -}}
{{- if .Values.keycloak.theme.configMap.existingConfigMap -}}
{{- .Values.keycloak.theme.configMap.existingConfigMap -}}
{{- else -}}
{{- printf "%s-keycloak-theme" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.keycloakInternalUrl" -}}
{{- if .Values.keycloak.enabled -}}
{{- printf "http://%s:%v" (include "syncratic.keycloakServiceName" .) .Values.keycloak.service.port -}}
{{- else -}}
{{- .Values.externalServices.keycloakInternalUrl -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.publicAppUrl" -}}
{{- if and .Values.ingress.enabled .Values.ingress.frontendHost -}}
{{- printf "%s://%s" .Values.ingress.publicScheme .Values.ingress.frontendHost -}}
{{- else -}}
http://localhost
{{- end -}}
{{- end -}}

{{- define "syncratic.authPublicPath" -}}
{{- printf "/%s" (trimAll "/" .Values.auth.publicPath) -}}
{{- end -}}

{{- define "syncratic.observabilityPath" -}}
{{- printf "/%s" (trimAll "/" .Values.observability.path) -}}
{{- end -}}

{{- define "syncratic.observabilityPathWithSlash" -}}
{{- printf "%s/" (trimSuffix "/" (include "syncratic.observabilityPath" .)) -}}
{{- end -}}

{{- define "syncratic.observabilityUrl" -}}
{{- printf "%s%s" (include "syncratic.publicAppUrl" .) (include "syncratic.observabilityPathWithSlash" .) -}}
{{- end -}}

{{- define "syncratic.observabilityGrafanaName" -}}
{{- printf "%s-observability-grafana" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.observabilityGrafanaAdminSecretName" -}}
{{- if .Values.observability.grafana.adminSecret.existingSecret -}}
{{- .Values.observability.grafana.adminSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-observability-grafana-admin" (include "syncratic.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic.observabilityGrafanaPvcName" -}}
{{- printf "%s-observability-grafana" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.observabilityGrafanaProvisioningConfigMapName" -}}
{{- printf "%s-observability-grafana-provisioning" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.observabilityGrafanaOverviewDashboardConfigMapName" -}}
{{- printf "%s-observability-grafana-overview-dashboard" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.observabilityGrafanaIngestionExplorerDashboardConfigMapName" -}}
{{- printf "%s-observability-grafana-ingestion-explorer-dashboard" (include "syncratic.fullname" .) -}}
{{- end -}}

{{- define "syncratic.publicAuthBaseUrl" -}}
{{- if eq .Values.auth.exposureMode "gatewayFacade" -}}
{{- printf "%s%s" (include "syncratic.publicAppUrl" .) (include "syncratic.authPublicPath" .) -}}
{{- else if and .Values.ingress.enabled (or .Values.ingress.authHost .Values.ingress.gatewayHost) -}}
{{- printf "%s://%s" .Values.ingress.publicScheme (default .Values.ingress.gatewayHost .Values.ingress.authHost) -}}
{{- else -}}
http://localhost
{{- end -}}
{{- end -}}

{{- define "syncratic.publicKeycloakIssuerUrl" -}}
{{- printf "%s/realms/%s" (include "syncratic.publicAuthBaseUrl" .) .Values.externalServices.keycloakRealm -}}
{{- end -}}

{{- define "syncratic.internalKeycloakIssuerUrl" -}}
{{- printf "%s/realms/%s" (trimSuffix "/" (include "syncratic.keycloakInternalUrl" .)) .Values.externalServices.keycloakRealm -}}
{{- end -}}

{{- define "syncratic.connectorOAuthRedirectUrl" -}}
{{- printf "%s%s" (include "syncratic.publicAppUrl" .) .Values.auth.connectorOAuthRedirectPath -}}
{{- end -}}

{{- define "syncratic.renderMapEnv" -}}
{{- $root := .root -}}
{{- range $name, $value := .values }}
- name: {{ $name }}
  value: {{ tpl (printf "%v" $value) $root | quote }}
{{- end }}
{{- end -}}

{{- define "syncratic.renderExternalSecret" -}}
{{- $root := .root -}}
{{- $secretName := .secretName -}}
{{- $keys := .keys -}}
apiVersion: {{ $root.Values.materialPolicy.externalSecrets.apiVersion }}
kind: ExternalSecret
metadata:
  name: {{ $secretName }}
  labels:
    {{- include "syncratic.labels" $root | nindent 4 }}
spec:
  refreshInterval: {{ $root.Values.materialPolicy.externalSecrets.refreshInterval | quote }}
  secretStoreRef:
    kind: {{ $root.Values.materialPolicy.externalSecrets.secretStoreRef.kind | quote }}
    name: {{ $root.Values.materialPolicy.externalSecrets.secretStoreRef.name | quote }}
  target:
    name: {{ $secretName }}
    creationPolicy: {{ $root.Values.materialPolicy.externalSecrets.target.creationPolicy | quote }}
    deletionPolicy: {{ $root.Values.materialPolicy.externalSecrets.target.deletionPolicy | quote }}
  data:
  {{- range $key := $keys }}
    - secretKey: {{ $key | quote }}
      remoteRef:
        key: {{ include "syncratic.externalSecretRemoteKey" (dict "root" $root "secretName" $secretName) | quote }}
        property: {{ $key | quote }}
        conversionStrategy: {{ $root.Values.materialPolicy.externalSecrets.remoteRef.conversionStrategy | quote }}
        decodingStrategy: {{ $root.Values.materialPolicy.externalSecrets.remoteRef.decodingStrategy | quote }}
        metadataPolicy: {{ $root.Values.materialPolicy.externalSecrets.remoteRef.metadataPolicy | quote }}
  {{- end }}
{{- end -}}
