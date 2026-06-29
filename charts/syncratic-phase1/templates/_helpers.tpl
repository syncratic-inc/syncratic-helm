{{- define "syncratic-phase1.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "syncratic-phase1.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "syncratic-phase1.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.labels" -}}
app.kubernetes.io/name: {{ include "syncratic-phase1.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "syncratic-phase1.selectorLabels" -}}
app.kubernetes.io/name: {{ include "syncratic-phase1.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "syncratic-phase1.serviceAccountName" -}}
{{- printf "%s-default" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.bootstrapSecretName" -}}
{{- if .Values.security.existingSecret -}}
{{- .Values.security.existingSecret -}}
{{- else -}}
{{- printf "%s-bootstrap" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.authRuntimeSecretName" -}}
{{- if .Values.auth.runtimeSecret.existingSecret -}}
{{- .Values.auth.runtimeSecret.existingSecret -}}
{{- else if .Values.auth.runtimeSecret.create -}}
{{- printf "%s-auth-runtime" (include "syncratic-phase1.fullname" .) -}}
{{- else -}}
{{- include "syncratic-phase1.bootstrapSecretName" . -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.identityProvisioningSecretName" -}}
{{- if .Values.auth.identityProvisioning.secret.existingSecret -}}
{{- .Values.auth.identityProvisioning.secret.existingSecret -}}
{{- else -}}
{{- printf "%s-identity-provisioning" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.bootstrapSmtpSecretName" -}}
{{- if .Values.auth.bootstrapSmtp.passwordSecret.existingSecret -}}
{{- .Values.auth.bootstrapSmtp.passwordSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-bootstrap-smtp" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.helpGatewayTokenSecretName" -}}
{{- if .Values.help.gatewayTokenSecret.existingSecret -}}
{{- .Values.help.gatewayTokenSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-help-gateway" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.registrationAdminTokenSecretName" -}}
{{- if .Values.registration.adminTokenSecret.existingSecret -}}
{{- .Values.registration.adminTokenSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-registration-admin" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.registrationBootstrapAuthoritySecretName" -}}
{{- if .Values.registration.bootstrapAuthority.existingSecret -}}
{{- .Values.registration.bootstrapAuthority.existingSecret -}}
{{- else -}}
{{- printf "%s-registration-bootstrap-authority" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.registrationLesMtlsCaSecretName" -}}
{{- if .Values.registration.les.mtls.caSecret.existingSecret -}}
{{- .Values.registration.les.mtls.caSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-registration-les-mtls-ca" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.registrationLesInitialLicenseSecretName" -}}
{{- if .Values.registration.les.initialLicenseSecret.existingSecret -}}
{{- .Values.registration.les.initialLicenseSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-registration-les-initial-license" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.gatewayInitialOperatorBootstrapSecretName" -}}
{{- if .Values.gateway.initialOperatorBootstrapSecret.existingSecret -}}
{{- .Values.gateway.initialOperatorBootstrapSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-gateway-initial-operator-bootstrap" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.gatewayNotificationWebhookSecretName" -}}
{{- if .Values.gateway.notifications.webhook.tokenSecret.existingSecret -}}
{{- .Values.gateway.notifications.webhook.tokenSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-gateway-notification-webhook" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.evaluationRuntimeSecretName" -}}
{{- if .Values.evaluation.runtimeSecret.existingSecret -}}
{{- .Values.evaluation.runtimeSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-evaluation-runtime" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.orchestratorRuntimeSecretName" -}}
{{- if .Values.orchestrator.runtimeSecret.existingSecret -}}
{{- .Values.orchestrator.runtimeSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-orchestrator-runtime" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.licensingPublicKeysConfigMapName" -}}
{{- if .Values.licensing.publicKeys.existingConfigMap -}}
{{- .Values.licensing.publicKeys.existingConfigMap -}}
{{- else -}}
{{- printf "%s-licensing-public-keys" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.licensingPublicKeysSecretName" -}}
{{- if .Values.licensing.publicKeys.existingSecret -}}
{{- .Values.licensing.publicKeys.existingSecret -}}
{{- else -}}
{{- printf "%s-licensing-public-keys" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.registrationPublicKeysConfigMapName" -}}
{{- if .Values.registration.publicKeys.existingConfigMap -}}
{{- .Values.registration.publicKeys.existingConfigMap -}}
{{- else -}}
{{- printf "%s-registration-public-keys" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.registrationPublicKeysSecretName" -}}
{{- if .Values.registration.publicKeys.existingSecret -}}
{{- .Values.registration.publicKeys.existingSecret -}}
{{- else -}}
{{- printf "%s-registration-public-keys" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.licensingControlPlaneTokenSecretName" -}}
{{- .Values.licensing.controlPlane.tokenSecret.existingSecret | trim -}}
{{- end -}}

{{- define "syncratic-phase1.licensingControlPlaneTlsConfigMapName" -}}
{{- .Values.licensing.controlPlane.tls.caConfigMap | trim -}}
{{- end -}}

{{- define "syncratic-phase1.licensingControlPlaneTlsCaSecretName" -}}
{{- .Values.licensing.controlPlane.tls.caSecret | trim -}}
{{- end -}}

{{- define "syncratic-phase1.licensingControlPlaneTlsClientSecretName" -}}
{{- .Values.licensing.controlPlane.tls.clientSecret | trim -}}
{{- end -}}

{{- define "syncratic-phase1.licensingRenewalRuntimeOutputSecretName" -}}
{{- if .Values.licensing.renewal.runtimeOutputSecret.existingSecret -}}
{{- .Values.licensing.renewal.runtimeOutputSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-licensing-renewal-runtime-output" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.licensingRenewalServiceAccountName" -}}
{{- printf "%s-licensing-renewal" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.gatewayUploadsPvcName" -}}
{{- printf "%s-gateway-uploads" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.redisUrl" -}}
{{- printf "redis://%s-redis:%v/0" (include "syncratic-phase1.fullname" .) .Values.redis.service.port -}}
{{- end -}}

{{- define "syncratic-phase1.postgresHost" -}}
{{- printf "%s-postgres" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.postgresUrl" -}}
{{- printf "postgresql+psycopg://%s:%s@%s:%v/%s" .Values.postgres.contract.applicationUser .Values.postgres.auth.password (include "syncratic-phase1.postgresHost" .) .Values.postgres.service.port .Values.postgres.contract.applicationDatabase -}}
{{- end -}}

{{- define "syncratic-phase1.postgresMigrationDsn" -}}
{{- printf "postgresql://%s:%s@%s:%v/%s" .Values.postgres.contract.applicationUser .Values.postgres.auth.password (include "syncratic-phase1.postgresHost" .) .Values.postgres.service.port .Values.postgres.contract.applicationDatabase -}}
{{- end -}}

{{- define "syncratic-phase1.qdrantUrl" -}}
{{- printf "http://%s-qdrant:%v" (include "syncratic-phase1.fullname" .) .Values.qdrant.service.port -}}
{{- end -}}

{{- define "syncratic-phase1.bgeEmbeddingsUrl" -}}
{{- printf "http://%s-bge-embeddings:%v" (include "syncratic-phase1.fullname" .) .Values.bgeEmbeddings.service.port -}}
{{- end -}}

{{- define "syncratic-phase1.llmFastUrl" -}}
{{- printf "http://%s-llm-fast:%v" (include "syncratic-phase1.fullname" .) .Values.llmFast.service.port -}}
{{- end -}}

{{- define "syncratic-phase1.llmDeepUrl" -}}
{{- printf "http://%s-llm-deep:%v" (include "syncratic-phase1.fullname" .) .Values.llmDeep.service.port -}}
{{- end -}}

{{- define "syncratic-phase1.neo4jUri" -}}
{{- printf "bolt://%s-neo4j:%v" (include "syncratic-phase1.fullname" .) .Values.neo4j.service.boltPort -}}
{{- end -}}

{{- define "syncratic-phase1.helpDataPvcName" -}}
{{- printf "%s-help-data" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.registrationDataPvcName" -}}
{{- printf "%s-registration-data" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.evaluationManagedSuitesPvcName" -}}
{{- printf "%s-evaluation-suites" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.orchestratorDataPvcName" -}}
{{- printf "%s-orchestrator-data" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.postgresAuthSecretName" -}}
{{- if .Values.postgres.auth.existingSecret -}}
{{- .Values.postgres.auth.existingSecret -}}
{{- else -}}
{{- printf "%s-postgres-auth" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.externalConnectionSecretName" -}}
{{- .Values.externalServices.connectionSecret.existingSecret -}}
{{- end -}}

{{- define "syncratic-phase1.externalTrustBundleConfigMapName" -}}
{{- .Values.externalServices.trustBundle.existingConfigMap -}}
{{- end -}}

{{- define "syncratic-phase1.externalTrustBundleSecretName" -}}
{{- .Values.externalServices.trustBundle.existingSecret -}}
{{- end -}}

{{- define "syncratic-phase1.materialContractConfigMapName" -}}
{{- printf "%s-material-contract" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.externalSecretRemoteKey" -}}
{{- $prefix := .root.Values.materialPolicy.externalSecrets.remoteKeyPrefix | trimSuffix "/" -}}
{{- if $prefix -}}
{{- printf "%s/%s" $prefix .secretName -}}
{{- else -}}
{{- .secretName -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.testImageRepository" -}}
{{- default .Values.gateway.image.repository .test.image.repository | trim -}}
{{- end -}}

{{- define "syncratic-phase1.testImageTag" -}}
{{- default .Values.gateway.image.tag .test.image.tag | trim -}}
{{- end -}}

{{- define "syncratic-phase1.testImageDigest" -}}
{{- default "" (default .Values.gateway.image.digest .test.image.digest) | trim -}}
{{- end -}}

{{- define "syncratic-phase1.testImagePullPolicy" -}}
{{- default .Values.gateway.image.pullPolicy .test.image.pullPolicy | trim -}}
{{- end -}}

{{- define "syncratic-phase1.imageRepository" -}}
{{- $repository := .image.repository -}}
{{- $firstPartyRegistry := .Values.global.firstPartyImageRegistry | trimSuffix "/" -}}
{{- if and $firstPartyRegistry (hasPrefix "syncratic/" $repository) -}}
{{- printf "%s/%s" $firstPartyRegistry $repository -}}
{{- else -}}
{{- $repository -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.imageRef" -}}
{{- $repository := include "syncratic-phase1.imageRepository" . -}}
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

{{- define "syncratic-phase1.testImageRef" -}}
{{- include "syncratic-phase1.imageRef" (dict
  "Values" .Values
  "image" (dict
    "repository" (include "syncratic-phase1.testImageRepository" .)
    "tag" (include "syncratic-phase1.testImageTag" .)
    "digest" (include "syncratic-phase1.testImageDigest" .)
  )
) -}}
{{- end -}}

{{- define "syncratic-phase1.keycloakServiceName" -}}
{{- printf "%s-keycloak" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.keycloakDbServiceName" -}}
{{- printf "%s-keycloak-db" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.keycloakDbSecretName" -}}
{{- if .Values.keycloak.database.existingSecret -}}
{{- .Values.keycloak.database.existingSecret -}}
{{- else -}}
{{- printf "%s-keycloak-db" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.keycloakAdminSecretName" -}}
{{- if .Values.keycloak.adminSecret.existingSecret -}}
{{- .Values.keycloak.adminSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-keycloak-admin" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.keycloakRealmConfigMapName" -}}
{{- if .Values.keycloak.realm.existingConfigMap -}}
{{- .Values.keycloak.realm.existingConfigMap -}}
{{- else -}}
{{- printf "%s-keycloak-realm" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.keycloakRealmSecretName" -}}
{{- if .Values.keycloak.realm.existingSecret -}}
{{- .Values.keycloak.realm.existingSecret -}}
{{- else -}}
{{- printf "%s-keycloak-realm" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.keycloakThemeConfigMapName" -}}
{{- if .Values.keycloak.theme.configMap.existingConfigMap -}}
{{- .Values.keycloak.theme.configMap.existingConfigMap -}}
{{- else -}}
{{- printf "%s-keycloak-theme" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.keycloakInternalUrl" -}}
{{- if .Values.keycloak.enabled -}}
{{- printf "http://%s:%v" (include "syncratic-phase1.keycloakServiceName" .) .Values.keycloak.service.port -}}
{{- else -}}
{{- .Values.externalServices.keycloakInternalUrl -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.publicAppUrl" -}}
{{- if and .Values.ingress.enabled .Values.ingress.frontendHost -}}
{{- printf "%s://%s" .Values.ingress.publicScheme .Values.ingress.frontendHost -}}
{{- else -}}
http://localhost
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.authPublicPath" -}}
{{- printf "/%s" (trimAll "/" .Values.auth.publicPath) -}}
{{- end -}}

{{- define "syncratic-phase1.observabilityPath" -}}
{{- printf "/%s" (trimAll "/" .Values.observability.path) -}}
{{- end -}}

{{- define "syncratic-phase1.observabilityPathWithSlash" -}}
{{- printf "%s/" (trimSuffix "/" (include "syncratic-phase1.observabilityPath" .)) -}}
{{- end -}}

{{- define "syncratic-phase1.observabilityUrl" -}}
{{- printf "%s%s" (include "syncratic-phase1.publicAppUrl" .) (include "syncratic-phase1.observabilityPathWithSlash" .) -}}
{{- end -}}

{{- define "syncratic-phase1.observabilityGrafanaName" -}}
{{- printf "%s-observability-grafana" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.observabilityGrafanaAdminSecretName" -}}
{{- if .Values.observability.grafana.adminSecret.existingSecret -}}
{{- .Values.observability.grafana.adminSecret.existingSecret -}}
{{- else -}}
{{- printf "%s-observability-grafana-admin" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.observabilityGrafanaPvcName" -}}
{{- printf "%s-observability-grafana" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.observabilityGrafanaProvisioningConfigMapName" -}}
{{- printf "%s-observability-grafana-provisioning" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.observabilityGrafanaOverviewDashboardConfigMapName" -}}
{{- printf "%s-observability-grafana-overview-dashboard" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.observabilityGrafanaIngestionExplorerDashboardConfigMapName" -}}
{{- printf "%s-observability-grafana-ingestion-explorer-dashboard" (include "syncratic-phase1.fullname" .) -}}
{{- end -}}

{{- define "syncratic-phase1.publicAuthBaseUrl" -}}
{{- if eq .Values.auth.exposureMode "gatewayFacade" -}}
{{- printf "%s%s" (include "syncratic-phase1.publicAppUrl" .) (include "syncratic-phase1.authPublicPath" .) -}}
{{- else if and .Values.ingress.enabled (or .Values.ingress.authHost .Values.ingress.gatewayHost) -}}
{{- printf "%s://%s" .Values.ingress.publicScheme (default .Values.ingress.gatewayHost .Values.ingress.authHost) -}}
{{- else -}}
http://localhost
{{- end -}}
{{- end -}}

{{- define "syncratic-phase1.publicKeycloakIssuerUrl" -}}
{{- printf "%s/realms/%s" (include "syncratic-phase1.publicAuthBaseUrl" .) .Values.externalServices.keycloakRealm -}}
{{- end -}}

{{- define "syncratic-phase1.internalKeycloakIssuerUrl" -}}
{{- printf "%s/realms/%s" (trimSuffix "/" (include "syncratic-phase1.keycloakInternalUrl" .)) .Values.externalServices.keycloakRealm -}}
{{- end -}}

{{- define "syncratic-phase1.connectorOAuthRedirectUrl" -}}
{{- printf "%s%s" (include "syncratic-phase1.publicAppUrl" .) .Values.auth.connectorOAuthRedirectPath -}}
{{- end -}}

{{- define "syncratic-phase1.renderMapEnv" -}}
{{- $root := .root -}}
{{- range $name, $value := .values }}
- name: {{ $name }}
  value: {{ tpl (printf "%v" $value) $root | quote }}
{{- end }}
{{- end -}}

{{- define "syncratic-phase1.renderExternalSecret" -}}
{{- $root := .root -}}
{{- $secretName := .secretName -}}
{{- $keys := .keys -}}
apiVersion: {{ $root.Values.materialPolicy.externalSecrets.apiVersion }}
kind: ExternalSecret
metadata:
  name: {{ $secretName }}
  labels:
    {{- include "syncratic-phase1.labels" $root | nindent 4 }}
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
        key: {{ include "syncratic-phase1.externalSecretRemoteKey" (dict "root" $root "secretName" $secretName) | quote }}
        property: {{ $key | quote }}
        conversionStrategy: {{ $root.Values.materialPolicy.externalSecrets.remoteRef.conversionStrategy | quote }}
        decodingStrategy: {{ $root.Values.materialPolicy.externalSecrets.remoteRef.decodingStrategy | quote }}
        metadataPolicy: {{ $root.Values.materialPolicy.externalSecrets.remoteRef.metadataPolicy | quote }}
  {{- end }}
{{- end -}}
