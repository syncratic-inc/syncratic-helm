# Syncratic Production runtime Helm Chart

Local engineering entrypoint.

Canonical docs:

- `../../../docs/kubernetes/helm/README.md`
- `../../../docs/kubernetes/README.md`

This chart is the production runtime Kubernetes packaging skeleton described in:

- `docs/kubernetes/kubernetes_implementation_plan_runtime_v1.md`

The chart now also carries a Helm values schema for install-time contract validation.

It also now carries an explicit material-source policy contract for environments that require cluster-managed secrets and trust inputs.

It also now carries an explicit ingress and TLS policy contract for environments that require cluster-managed HTTPS and ingress-controller ownership instead of bootstrap-style open ingress assumptions.

It also now carries an explicit upload-size contract so document ingestion does not fail at the ingress or frontend proxy layer before requests reach the gateway.

It also now carries an explicit model-binding ownership contract for production runtime:

- `modelBindings.dbOnly=true` by default
- `modelBindings.bootstrapSync=false` by default

That means production runtime treats runtime model endpoints as Admin-owned configuration, not environment fallback defaults.

If a required role is unconfigured, the product should surface that gap through Admin -> Models and through runtime feature errors rather than silently inheriting stale environment values.

It now also carries an explicit online-registry delivery contract for first-party images:

- `global.deliveryMode=bootstrap|online_registry`
- `global.firstPartyImageRegistry`
- `global.imagePullSecrets`

That means:

- bootstrap delivery can still use local-style first-party repositories such as `syncratic/gateway`
- online delivery can render those same first-party repositories through a real registry prefix such as `ghcr.io/<org>`
- `online_registry` mode now rejects `latest` for enabled services unless an immutable digest is supplied

It now also carries an explicit stateless scaling contract for the main production runtime runtime slice:

- non-empty default resource requests and limits for:
  - `gateway`
  - `frontend`
  - `runtimeWorkers`
- first-class HPA controls for:
  - `gateway`
  - `frontend`
  - each runtime worker lane

This means the chart can now express bounded stateless scaling posture directly through Helm rather than leaving it as an external cluster-only convention.

The next bounded extension now also covers the remaining critical runtime services as follows:

- explicit non-empty resource requests and limits for:
  - `runtimeNodeAgent`
  - `help`
  - `help.curator`
  - `licensing`
  - `registration`
  - `evaluation`
  - `transformer`
- HPA support added only for:
  - `transformer`

That boundary is intentional:

- `transformer` is stateless and ingestion-coupled, so horizontal scale is justified
- `help`, `registration`, and `licensing` still sit on singleton or PVC-coupled runtime patterns, so this cut improves scheduling discipline without pretending they are ready for blind horizontal autoscaling

It now also carries an optional same-domain observability contract for Kubernetes:

- `observability.enabled=true`
- `observability.path=/observability`
- optional in-chart Grafana exposed under the portal host instead of a separate public hostname
- Keycloak Generic OAuth against the same Syncratic realm and browser SSO contract
- explicit Grafana admin secret material
- optional operator-supplied datasource URLs and dashboard ConfigMaps

That boundary is intentional:

- this cut packages the native operator-facing Grafana surface
- it does not yet absorb Prometheus, Loki, Tempo, or the full monitoring stack into the production runtime chart

It now also carries the first phase2 LES launcher contract for `registration-service`:

- explicit `registration.les.*` values for:
  - bootstrap caller and install type
  - LES control-plane metadata
  - bootstrap token TTL
  - steady-state auth mode
  - license handoff mode
- optional mounted Secret material for:
  - LES mTLS issuing CA
  - embedded initial signed license artifact
- fail-fast render assertions when:
  - `registration.les.steadyStateAuthMode=mtls` but no CA secret is provided
  - `registration.les.licenseHandoffMode=embedded_signed_license` but no initial license secret is provided

That boundary is also intentional:

- the default runtime chart remains renderable in a non-mTLS bootstrap posture
- the stricter LES path becomes an explicit operator-selected contract rather than an implicit runtime assumption

It now also carries the gateway-side delivery seam for the first-install operator bootstrap artifact:

- explicit `gateway.initialOperatorBootstrapSecret.*` values for:
  - chart-created or existing Secret ownership
  - mounted bootstrap artifact path
  - bootstrap artifact key selection
- `INITIAL_OPERATOR_BOOTSTRAP_FILE` wiring into the gateway runtime
- material-contract publication for the gateway initial-operator bootstrap Secret
- fail-fast render assertion when:
  - `gateway.initialOperatorBootstrapSecret.create=true`
  - but no bootstrap artifact JSON is supplied

That boundary is intentional:

- the installation launcher now has a chart-owned way to deliver the `les-initial-operator-bootstrap.json` artifact into gateway
- the separate lifecycle for clearing or superseding that artifact after first install remains a later phase2 item

It now also carries a gateway migration rollout guard:

- `gateway.migrationHook.enabled=true` by default
- a Helm `pre-install,pre-upgrade` Job runs `python -m db.migrate` with the same gateway image being released
- the hook uses the chart-owned PostgreSQL migration DSN when `postgres.enabled=true`
- for external PostgreSQL, the contract now also surfaces `externalServices.gatewayMigrationDsn` and `externalServices.connectionSecret.keys.gatewayMigrationDsn`
- when `postgres.enabled=false`, `gateway.migrationHook.enabled=true`, and `externalServices.postgresUrl` is supplied directly, Helm now fails unless a distinct `externalServices.gatewayMigrationDsn` is also supplied

That boundary is intentional:

- new gateway schema requirements should be applied before the Deployment rolls
- rollout should fail in Helm if migrations cannot be applied
- migration privilege can stay narrower than the normal application DSN through the separate migration DSN seam
- K8s rollouts should not repeat the Docker failure mode where the runtime image sees new SQL files but the schema remains behind

The chart now also carries Docker-parity runtime defaults for the production Insights and Privacy Engine surfaces:

- `INSIGHTS_COMMUNITY_ENABLED=true` so Leiden/community signal generation participates in the Insights feed when the released gateway image supports it
- `INSIGHTS_MODEL_NARRATIVES_ENABLED=true` plus explicit worker interval, batch, timeout, retry, and cooldown values so narrative generation is handled by the gateway-owned background worker rather than being an implicit render-time behavior
- `PRIVACY_ENGINE_ENABLED=true`, scan/context gates enabled, and `PRIVACY_ENGINE_ENFORCEMENT_MODE=enforce` so Kubernetes deployments expose the same Privacy Engine runtime posture as the Docker R&D environment unless an operator intentionally overrides it
- the tenant-level Admin Privacy Engine configuration remains database-owned; Helm only provides the deployment baseline and the gateway migration hook applies the schema needed for tenant overrides such as Live Feed text-field gates

For production and k3 testing, prefer immutable gateway image tags or digests. If a mutable tag such as `latest` is used during bootstrap testing, rebuild/push or import the image into the cluster before `helm upgrade`, and use a pull policy that guarantees the migration hook and gateway Deployment see the same image content. In `online_registry` mode, the chart already rejects `latest` without a digest for enabled services.

Deployable example overlay:

- `examples/online-observability.values.yaml`
- `examples/README.md`
- `examples/online-observability.materials.env.example`
- `examples/online-observability.images.env.example`
- `examples/online-observability.image-manifest.example.json`
- `examples/render_online_observability_materials.py`
- `examples/render_online_observability_image_overrides.py`
- `../../../scripts/run_syncratic_online_observability.sh`
- `../../../scripts/validate_syncratic_online_observability_runner.sh`

That overlay assumes:

- online registry-backed delivery
- cluster-managed TLS and ingress
- a reachable Prometheus service
- pre-provisioned Secrets for:
  - frontend auth runtime
  - Keycloak admin
  - Keycloak database
  - Grafana admin
- a pre-provisioned Keycloak realm ConfigMap carrying the `grafana-observability` client contract

The example directory now also carries a repo-owned material renderer for that overlay. It emits the required Secrets and Keycloak realm ConfigMap from a single env file so the online observability rollout can stay source-aligned instead of depending on handwritten cluster material.

The example directory now also carries a repo-owned image-override renderer so the online observability rollout can be advanced from the stable example tags to the actual published image set for the current release without hand-editing Helm values. That renderer now accepts either a simple env file or a single JSON release-image manifest artifact.

For operators who want one reproducible execution path instead of manual step-by-step commands, the repo now also carries a bounded runner and validator pair that render the material set, optionally render the image override values, optionally apply the material set, and then perform the `helm upgrade --install` using the same example overlay contract.

That bounded path now also has an optional ingress verifier so live same-domain Grafana delivery can emit a machine-readable postflight proof against `/observability/login` and `/observability/api/health` instead of relying only on manual browser checks.

It now also supports optional `helm test` execution in the same live rollout path so the release can prove the chart-owned runtime smoke, dependency, material, and ingress/auth contracts before it is treated as complete.

When that live proof path is enabled, the rollout also retains a Helm test transcript and a small machine-readable report so failures are diagnosable from artifacts instead of only runner console history.

The chart’s own Helm test jobs now also inherit that same release-image path, so runtime smoke, dependency, and material-contract tests do not silently fall back to the example `gateway:1.0.0` tag when digest-pinned release overrides are supplied.

That same bounded rollout now also has a dedicated self-hosted GitHub Actions workflow so the online observability release path can execute through a repo-owned automation contract instead of only local shell invocation.

It is intentionally scoped to:

- `gateway`
- `frontend`
- `registration-service`
- `help-service`
- optional absorbed `redis` critical backplane slice
- optional absorbed `qdrant` critical backplane slice
- optional absorbed `neo4j` critical backplane slice
- optional absorbed `postgres` critical backplane slice
- optional absorbed `keycloak` critical backplane slice
- optional absorbed `bge-embeddings` critical backplane slice
- optional absorbed `llm-fast` critical backplane slice
- optional `evaluation-agent`
- optional `orchestrator`
- `licensing-service`
- `runtime-node-agent`
- dedicated `runtimeWorkers` Deployments for:
  - `enrichment`
  - `graph`
  - `delta`
  - `knowledge`
  - `assurance_criteria`
- optional `artifact-transformer`
- optional `help-curator-service`

It does not package the full stateful platform stack.

## Critical backplane boundary

The chart now starts absorbing the critical backplane in controlled slices instead of treating all runtime substrate as permanently external.

Current absorbed backplane support:

- `redis.enabled=true`
- `qdrant.enabled=true`
- `neo4j.enabled=true`
- `postgres.enabled=true`
- `keycloak.enabled=true`
- `bgeEmbeddings.enabled=true`
- `llmFast.enabled=false` by default; optional packaged fast-model service when explicitly configured
- `llmDeep.enabled=false` by default; optional packaged deep-model service when explicitly configured

When enabled, the chart provides:

- singleton Redis via `StatefulSet`
- PVC-backed Redis state
- internal-only ClusterIP service
- internal-only network-policy ingress from chart pods
- automatic runtime wiring so packaged services resolve the in-chart Redis URL instead of `externalServices.redisUrl`
- dependency-test coverage against the absorbed Redis backplane
- singleton Qdrant via `StatefulSet`
- PVC-backed Qdrant state
- internal-only ClusterIP service
- internal-only network-policy ingress from chart pods
- automatic runtime wiring so packaged services resolve the in-chart Qdrant URL instead of `externalServices.qdrantUrl`
- dependency-test coverage against the absorbed Qdrant backplane
- singleton Neo4j via `StatefulSet`
- PVC-backed Neo4j data and log state
- internal-only ClusterIP service for Bolt and HTTP
- internal-only network-policy ingress from chart pods
- automatic runtime wiring so packaged services resolve the in-chart Neo4j URI instead of `externalServices.neo4jUri`
- dependency-test coverage against the absorbed Neo4j backplane
- singleton PostgreSQL via `StatefulSet`
- PVC-backed PostgreSQL state
- internal-only ClusterIP service
- internal-only network-policy ingress from chart pods
- explicit application database contract:
  - `syncratic_rag`
- explicit orchestrator database contract:
  - `n8n`
- init-time creation of the orchestrator database through a chart-owned ConfigMap
- dedicated PostgreSQL auth secret boundary for:
  - `POSTGRES_PASSWORD`
  - `DATABASE_URL`
  - `EVAL_DB_DSN`
  - `GATEWAY_MIGRATION_DSN`
  - `DB_POSTGRESDB_PASSWORD`
- runtime DSN split now stays honest:
  - `DATABASE_URL` and `EVAL_DB_DSN` remain SQLAlchemy-style `postgresql+psycopg://...`
  - `GATEWAY_MIGRATION_DSN` is emitted as a psycopg-native `postgresql://...`
- fresh chart-owned gateway databases now bootstrap from the base gateway schema and then apply tracked migrations instead of assuming a preloaded legacy schema
- chart-owned PostgreSQL init now creates the compatibility role `syncratic_app` so grant-oriented gateway migrations can run cleanly on a fresh production runtime database
- gateway defaults now enable:
  - `GATEWAY_AUTO_APPLY_MIGRATIONS=true`
  - `GATEWAY_REQUIRE_MIGRATIONS_AT_STARTUP=true`
- automatic runtime wiring so packaged services resolve the in-chart PostgreSQL DSNs instead of `externalServices.postgresUrl`
- dependency-test and material-contract coverage against the absorbed PostgreSQL backplane
- singleton Keycloak identity service through a dedicated Deployment
- dedicated Keycloak PostgreSQL state through a singleton `StatefulSet`
- PVC-backed Keycloak database state
- dedicated admin secret boundary for:
  - `KEYCLOAK_ADMIN`
  - `KEYCLOAK_ADMIN_PASSWORD`
- dedicated Keycloak database secret boundary for:
  - `KC_DB_USERNAME`
  - `KC_DB_PASSWORD`
- dedicated realm import material boundary through:
  - `keycloak.realm.existingConfigMap`
  - `keycloak.realm.existingSecret`
  - or `keycloak.realm.create=true`
- automatic runtime wiring so packaged services resolve the in-chart Keycloak URL instead of `externalServices.keycloakInternalUrl`
- auth-host-backed ingress ownership when `ingress.enabled=true`
- dependency-test, runtime-smoke, and material-contract coverage against the absorbed Keycloak backplane
- singleton embeddings inference endpoint through a dedicated Deployment
- internal-only ClusterIP service
- internal-only network-policy ingress from chart pods
- automatic runtime wiring so packaged services resolve the in-chart embeddings URL instead of `externalServices.bgeEmbeddingsUrl`
- dependency-test and runtime-smoke coverage against the absorbed embeddings backplane
- optional singleton fast LLM inference endpoint through a dedicated Deployment when `llmFast.enabled=true`
- optional singleton deep LLM inference endpoint through a dedicated Deployment when `llmDeep.enabled=true`
- packaged LLM services require explicit `model.name` and `model.servedModelName`; the chart no longer defaults to a vendor model identity
- internal-only ClusterIP service and network-policy ingress from chart pods when packaged LLM services are enabled
- automatic runtime wiring so packaged services resolve the in-chart LLM URLs instead of `externalServices.llmFastUrl` / `externalServices.llmDeepUrl`
- dependency-test and runtime-smoke coverage only when packaged LLM services or explicit external model endpoints are intentionally enabled

The remaining critical backplane is still external by default:

- external trust and connection material

When PostgreSQL remains external:

- `externalServices.postgresUrl` is the application/evaluation DSN and should target `syncratic_rag`
- the orchestrator database remains separately modeled by:
  - `postgres.contract.orchestratorDatabase`
  - `postgres.contract.orchestratorUser`

When embeddings remain external:

- `externalServices.bgeEmbeddingsUrl` stays the runtime embedding endpoint contract
  - in `k3s`, do not point this at a Docker Compose service name like `http://bge-emb:8000`
  - use a node-reachable or externally reachable URL instead, such as `http://<k3s-node-ip>:9002`

When model endpoints are external:

- prefer configuring reusable model endpoints and task assignments in Admin -> Models after tenant setup
- set `externalServices.llmFastUrl` and `externalServices.llmDeepUrl` only for bootstrap, dependency-test, or non-DB fallback deployments
- in `k3s`, do not point these at Docker Compose service names; use node-reachable or externally reachable URLs instead
- Helm no longer chooses a default fast/deep model name; model identity belongs to the runtime model library and task bindings

Canonical guidance for this boundary lives in:

- `../../../docs/kubernetes/k3s_external_model_endpoint_contract_v1.md`

## Current boundary

This chart is packaging substrate only. It does not replace the existing signed integrity and update-control model enforced through LES.

## Upload boundary

Document upload paths traverse:

- ingress controller
- frontend nginx proxy
- gateway

The chart now models the first two size limits explicitly:

- `ingress.maxBodySize`
  - emitted as `nginx.ingress.kubernetes.io/proxy-body-size`
- `frontend.nginx.clientMaxBodySize`
  - emitted as `client_max_body_size` in the frontend nginx config

Default values:

- `ingress.maxBodySize: "100m"`
- `frontend.nginx.clientMaxBodySize: "100m"`

If uploads larger than that are expected, raise both values together.

## Online Registry Delivery Note

For online clusters, prefer a registry-backed release posture rather than local image import.

Canonical guidance:

- `../../../docs/kubernetes/online_registry_delivery_contract_v1.md`

The chart now supports:

- `global.deliveryMode=online_registry`
- `global.firstPartyImageRegistry`
- `global.imagePullSecrets`

This lets first-party Syncratic images keep local engineering repository names in values while still rendering into a real registry path during online delivery.

## K3s Bootstrap Note

For local `k3s` bootstrap, this chart now has an optional repo-side image bridge through:

- `scripts/import_syncratic_k3s_images.sh`
- `scripts/run_syncratic_cluster_release.sh`

That bridge is intentionally a local-cluster convenience path.

It exists to import already built local images into `k3s` containerd before Helm runs when no registry path exists yet.

It is not the preferred production delivery model.

Production-oriented clusters should still favor:

- registry-published images
- immutable image tags
- standard Kubernetes image-pull controls

## Material source policy

The chart now supports an explicit material-source policy through:

- `materialPolicy.sourceMode=flexible|cluster_managed`
- `materialPolicy.manager=bootstrap|manual_refs|external_secrets`
- `materialPolicy.publishContract=true|false`

`flexible` keeps the existing bootstrap-friendly behavior.

Bootstrap-friendly source mode requires:

- `materialPolicy.manager=bootstrap`

`cluster_managed` is the production-oriented posture. It requires:

- `security.bootstrapSecret.create=false`
- `security.existingSecret`
- `auth.runtimeSecret.create=false`
- `licensing.publicKeys.create=false`
- one of:
  - `licensing.publicKeys.existingConfigMap`
  - `licensing.publicKeys.existingSecret`

Cluster-managed source mode also requires one of these manager postures:

- `materialPolicy.manager=manual_refs`
  - operators provision Kubernetes `Secret` and `ConfigMap` objects directly
- `materialPolicy.manager=external_secrets`
  - an external secret controller provisions the Kubernetes `Secret` and `ConfigMap` objects the chart consumes

External secret preset:

- `materialPolicy.externalSecrets.enabled=true`
- `materialPolicy.externalSecrets.secretStoreRef.kind`
- `materialPolicy.externalSecrets.secretStoreRef.name`
- optional:
  - `materialPolicy.externalSecrets.remoteKeyPrefix`
  - `materialPolicy.externalSecrets.refreshInterval`
  - `materialPolicy.externalSecrets.target.*`

When `manager=external_secrets`, the chart now emits `ExternalSecret` objects for Secret-backed material targets using the current chart-owned Secret names.

This now also supports opt-in Secret-backed alternatives for config-style materials when you choose them explicitly:

- `licensing.publicKeys.existingSecret`
- `registration.publicKeys.existingSecret`
- `keycloak.realm.existingSecret`
- `externalServices.trustBundle.existingSecret`
- `licensing.controlPlane.tls.caSecret`

Remote secret contract:

- remote key path defaults to:
  - `<remoteKeyPrefix>/<target-secret-name>`
- remote properties default to the exact Kubernetes secret-key names the chart expects

Important boundary:

- this preset only emits `ExternalSecret` resources for Secret-backed material
- ConfigMap-backed material remains the default for:
  - LES public keys
  - registration public keys
  - Keycloak realm import
  - external trust bundle
- Secret-backed alternatives for those materials are explicit and opt-in, while the mounted in-pod file paths stay the same either way

Optional stricter policy flags:

- `materialPolicy.requireExternalConnectionSecret=true`
  - requires `externalServices.connectionSecret.existingSecret`
- `materialPolicy.requireExternalTrustBundle=true`
  - requires one of:
    - `externalServices.trustBundle.existingConfigMap`
    - `externalServices.trustBundle.existingSecret`
- `materialPolicy.requireConnectedControlPlaneMtls=true`
  - requires:
    - `licensing.controlPlane.mode=connected`
    - one of:
      - `licensing.controlPlane.tls.caConfigMap`
      - `licensing.controlPlane.tls.caSecret`
    - `licensing.controlPlane.tls.clientSecret`

These checks are enforced at render time, not only in documentation.

When `materialPolicy.publishContract=true`, the chart also emits:

- `<release>-syncratic-material-contract`

That ConfigMap publishes the chart’s current material inventory, including:

- required Secret names
- required ConfigMap names
- required key names per object
- whether each object is chart-supplied or cluster-supplied under the current values

This is the chart-owned handoff for:

- manual cluster provisioning
- ExternalSecret target-object generation
- operator review of current material ownership

## Ingress and TLS policy

The chart now supports an explicit ingress/TLS policy through:

- `ingress.tlsPolicy.mode=flexible|cluster_managed`

`flexible` keeps the bootstrap-friendly ingress posture.

`cluster_managed` is the production-oriented posture. It requires:

- `ingress.enabled=true`
- `ingress.className`
- `ingress.publicScheme=https`
- `ingress.tls` entries
- `networkPolicy.ingressController.enabled=true`
- all configured public hosts to appear in the declared TLS host set

Optional stricter policy flags:

- `ingress.tlsPolicy.requireTls=true`
- `ingress.tlsPolicy.requireIngressClass=true`
- `ingress.tlsPolicy.requireHostsCovered=true`

Optional cert-manager ownership:

- `ingress.tlsPolicy.certManager.enabled=true`
- exactly one of:
  - `ingress.tlsPolicy.certManager.clusterIssuer`
  - `ingress.tlsPolicy.certManager.issuer`

When cert-manager mode is enabled, the chart injects the matching ingress annotation instead of relying on a raw operator-supplied annotation side channel.

These checks are enforced at render time so broken HTTPS posture fails before install.

## Runtime delivery workflow

The production runtime runtime now also has a self-hosted delivery-gate workflow:

- [syncratic-helm-delivery.yml](/home/adminalien/docker/syncratic-core/.github/workflows/syncratic-helm-delivery.yml)

For real cluster mutation, the production runtime runtime now also has a self-hosted cluster-release workflow:

- [syncratic-cluster-release.yml](/home/adminalien/docker/syncratic-core/.github/workflows/syncratic-cluster-release.yml)

Supporting tooling:

- [run_syncratic_helm_delivery_gate.sh](/home/adminalien/docker/syncratic-core/scripts/run_syncratic_helm_delivery_gate.sh)
- [run_syncratic_cluster_release.sh](/home/adminalien/docker/syncratic-core/scripts/run_syncratic_cluster_release.sh)
- [validate_syncratic_cluster_release_runner.sh](/home/adminalien/docker/syncratic-core/scripts/validate_syncratic_cluster_release_runner.sh)
- [export_syncratic_delivery_evidence.py](/home/adminalien/docker/syncratic-core/scripts/export_syncratic_delivery_evidence.py)
- [run_syncratic_release_checkpoint.sh](/home/adminalien/docker/syncratic-core/scripts/run_syncratic_release_checkpoint.sh)
- [build_syncratic_release_checkpoint.py](/home/adminalien/docker/syncratic-core/scripts/build_syncratic_release_checkpoint.py)
- [export_syncratic_recovery_package.py](/home/adminalien/docker/syncratic-core/scripts/export_syncratic_recovery_package.py)
- [run_syncratic_restore_drill.py](/home/adminalien/docker/syncratic-core/scripts/run_syncratic_restore_drill.py)
- [validate_syncratic_delivery_runner.sh](/home/adminalien/docker/syncratic-core/scripts/validate_syncratic_delivery_runner.sh)
- [syncratic_delivery_runner_contract_v1.md](/home/adminalien/docker/syncratic-core/docs/kubernetes/syncratic_delivery_runner_contract_v1.md)
- [syncratic_cluster_release_runner_contract_v1.md](/home/adminalien/docker/syncratic-core/docs/kubernetes/syncratic_cluster_release_runner_contract_v1.md)

Current delivery profiles:

- `install`
- `upgrade`
- `restore`

Current cluster release operations:

- `install`
- `upgrade`

Current evidence bundle includes:

- Helm test outcome
- LES readiness and license status
- connectivity posture
- config-integrity posture
- open integrity incidents
- worker-seat and node-seat posture
- update-bundle and rollout settlement state

The production runtime delivery workflow now also supports retained runtime recovery evidence through:

- [run_syncratic_recovery_evidence_flow.sh](/home/adminalien/docker/syncratic-core/scripts/run_syncratic_recovery_evidence_flow.sh)
- [build_syncratic_recovery_retention_manifest.py](/home/adminalien/docker/syncratic-core/scripts/build_syncratic_recovery_retention_manifest.py)

The cluster release workflow layers one step above that:

- validates cluster-side namespace and release preconditions
- executes a real Helm `install` or `upgrade`
- records `release-operation.json`
- then runs the existing delivery-gate and retained recovery-evidence flow against the live release

That retained evidence pairs the delivery-gate output with:

- runtime PVC backup artifacts
- bootstrap secret backup artifacts
- auth runtime secret backup artifacts
- LES public-key backup artifacts
- optional external connection, trust-bundle, and docs-PVC backup artifacts

This is still narrower than the standalone control-plane recovery evidence flow:

- it proves runtime delivery and recovery-artifact retention posture
- it does not create the underlying backups itself

The delivery path now also supports a profile-aware release checkpoint artifact that consolidates:

- delivery-gate outcome
- retained recovery evidence
- update/install settlement posture
- rollback-readiness summary
- optional expected bundle and target-version matching

This gives install, upgrade, and restore flows a single checkpoint artifact instead of requiring operators to interpret raw evidence and retention manifests separately.

On top of that, the runtime flow now supports a retained recovery package export that bundles:

- the delivery-evidence directory
- the retained recovery-retention manifest
- the synthesized release checkpoint
- a restore-plan contract
- a restore-drill summary
- an optional zip archive for operator handoff

This is still metadata and evidence packaging, not embedded backup material. The underlying PVC and secret backups remain external artifacts referenced by the package.

The restore drill treats the retained recovery package itself as the formal restore handoff contract. It validates:

- packaged file completeness
- release-checkpoint pass/fail posture
- rollback-readiness posture
- restore-plan eligibility
- required external backup recording
- optional expected bundle and target-version matching

It does not execute a destructive restore.

## Registration runtime boundary

The chart now packages the internal bootstrap-registration surface:

- `registration-service`
- singleton PVC-backed runtime state
- explicit bootstrap-public-key ConfigMap boundary
- optional admin-token secret boundary
- internal-only ClusterIP service
- runtime smoke and material-contract coverage

This service remains intentionally internal-only. It is part of install/bootstrap choreography, not a public customer ingress surface.

## Evaluation runtime boundary

The chart now supports an optional packaged evaluation runtime:

- `evaluation.enabled=true`

When enabled, the chart provides:

- `evaluation-agent`
- a dedicated runtime secret boundary for:
  - `EVAL_INTERNAL_TRIGGER_TOKEN`
  - `EVAL_SERVICE_GATEWAY_API_KEY`
  - optional `EVAL_SERVICE_TENANT_ID`
- a managed-suites PVC boundary
- reuse of the shared gateway uploads PVC for run workspaces under `/syncrauploads/eval_workspaces`
- runtime smoke coverage for `/eval/health`
- material-contract validation of the evaluation runtime secret
- `/eval` ingress routing on the frontend host
- network-policy ingress allowance for the evaluation public surface

This keeps evaluation packaging honest:

- external Postgres and model endpoints still stay in the existing external dependency boundary
- evaluation-specific trigger and service-auth material do not have to be coupled to the bootstrap or auth runtime secrets
- the default production runtime install remains stable because evaluation is still opt-in

## Orchestrator runtime boundary

The chart now supports an optional packaged orchestration surface:

- `orchestrator.enabled=true`

When enabled, the chart provides:

- `orchestrator` based on the current n8n runtime shape
- a dedicated runtime secret boundary for:
  - `N8N_BASIC_AUTH_PASSWORD`
  - `DB_POSTGRESDB_PASSWORD`
- a dedicated PVC for `/home/node/.n8n`
- `/orch` ingress routing on the frontend host
- runtime smoke coverage through TCP reachability instead of an invented HTTP health path
- material-contract validation of the orchestrator runtime secret
- network-policy ingress allowance for the orchestrator public surface

This keeps the boundary disciplined:

- orchestrator remains opt-in
- its database contract stays external and explicit instead of quietly assuming the application Postgres URL shape is reusable
- the chart does not claim a stronger in-service health contract than the current runtime actually exposes

## Keycloak identity boundary

The chart now supports an optional packaged identity surface:

- `keycloak.enabled=true`

When enabled, the chart provides:

- `keycloak`
- a dedicated `keycloak-db` PostgreSQL `StatefulSet`
- a dedicated Keycloak admin secret boundary for:
  - `KEYCLOAK_ADMIN`
  - `KEYCLOAK_ADMIN_PASSWORD`
- a dedicated Keycloak database secret boundary for:
  - `KC_DB_USERNAME`
  - `KC_DB_PASSWORD`
- a dedicated realm-import ConfigMap boundary
- runtime smoke coverage against:
  - `/.well-known/openid-configuration`
- material-contract validation of:
  - Keycloak admin secret keys
  - Keycloak DB secret keys
  - mounted realm JSON
- public ingress ownership on `ingress.authHost`
- internal-only network-policy ingress for `keycloak-db`
- optional Syncratic login/email theme packaging through:
  - `keycloak.theme.enabled=true`
  - `keycloak.theme.name=syncratic`
  - a chart-managed Keycloak theme ConfigMap by default

This keeps the identity boundary disciplined:

- Keycloak remains optional and explicit
- the runtime auth topology still derives from the chart contract instead of ad hoc `extraEnv` overrides
- the IdP surface becomes chart-owned without collapsing admin credentials, realm state, and DB credentials into the bootstrap secret
- external Keycloak remains supported when `keycloak.enabled=false`

### Keycloak branding reconciliation

Docker Compose mounts the Syncratic Keycloak theme directly from `keycloak/themes/syncratic`. Kubernetes deployments must not depend on that host path. When `keycloak.theme.enabled=true`, the Helm chart packages the same theme into a ConfigMap, uses an init container to materialize the nested Keycloak theme directory, and mounts it at `/opt/keycloak/themes/<theme-name>`.

For fresh realm imports, the realm JSON should set:

- `loginTheme: syncratic`
- `emailTheme: syncratic`

For existing realms, Keycloak does not re-import realm settings just because the ConfigMap changed. Reconcile the live realm after enabling the theme:

```bash
kubectl exec -n <namespace> deployment/<release>-syncratic-keycloak -- \
  /bin/sh -lc '/opt/keycloak/bin/kcadm.sh config credentials \
    --server http://127.0.0.1:8080 \
    --realm master \
    --user "$KEYCLOAK_ADMIN" \
    --password "$KEYCLOAK_ADMIN_PASSWORD" >/dev/null && \
    /opt/keycloak/bin/kcadm.sh update realms/syncratic \
      -s loginTheme=syncratic \
      -s emailTheme=syncratic'
```

Verify:

```bash
kubectl exec -n <namespace> deployment/<release>-syncratic-keycloak -- \
  find /opt/keycloak/themes/syncratic -type f

curl -k 'https://syncratic.<customer-domain>/auth/realms/syncratic/protocol/openid-connect/auth?client_id=syncratic-portal&response_type=code&scope=openid&redirect_uri=https%3A%2F%2Fsyncratic.<customer-domain>%2Fauth%2Fcallback&state=brandcheck&prompt=login&max_age=0'
```

The returned HTML should include `/login/syncratic/css/syncratic.css` and `syncratic-auth-card`.



## Deployment-owned host and Gateway auth facade

Production deployments should use a deployment-owned host, for example `syncratic.customer.com`, and route authentication through the Gateway facade under `/auth`. This avoids exposing the full Keycloak application as a public `auth.<domain>` service.

Recommended production values:

```yaml
ingress:
  enabled: true
  className: nginx
  publicScheme: https
  frontendHost: syncratic.customer.com
  gatewayHost: syncratic.customer.com
  authHost: ""
  tls:
    - secretName: syncratic-customer-tls
      hosts:
        - syncratic.customer.com

auth:
  exposureMode: gatewayFacade
  publicPath: /auth
  connectorOAuthRedirectPath: /connectors/callback
```

In this mode the chart derives:

- app URL: `https://syncratic.customer.com`
- login entrypoint: `https://syncratic.customer.com/auth/login`
- login callback: `https://syncratic.customer.com/auth/callback`
- public Keycloak browser facade: `https://syncratic.customer.com/auth/realms/<realm>/...`
- connector OAuth callback: `https://syncratic.customer.com/connectors/callback`

Keycloak remains internal. Gateway proxies only the browser-facing Keycloak paths required for OIDC login and account actions. Token exchange, admin operations, directory lookup, required-action email execution, and JWKS validation continue to use the internal Keycloak service URL.

The chart also reconciles the live Keycloak realm/client public URL contract after install/upgrade so existing realms do not retain stale `portal.syncratic.co` redirect URIs. Docker/R&D deployments may still expose `auth.syncratic.co` for internal testing, but that is not the production default.

The same reconcile hook owns the standard OIDC identity client-scope contract for managed Keycloak deployments. It creates `email` and `profile` client scopes when an existing/minimal realm lacks them, adds user-property mappers for email and profile claims, and attaches `roles`, `email`, and `profile` as default scopes on the portal client. This prevents first-run admin login from failing with `invalid_scope` and ensures the Gateway receives the identity claims required for bootstrap and invitation acceptance.


## SAML external IdP and group authorization

SAML support is a post-bootstrap tenant administration capability. The first administrator claim remains local-first so a fresh deployment can always be claimed before any external IdP metadata, certificates, or group claims exist.

Helm exposes SAML as a deployment capability flag:

```yaml
auth:
  saml:
    enabled: true
    groupDiscoveryMode: keycloak_groups
  identityProvisioning:
    enabled: true
```

`auth.saml.enabled=true` does not statically configure a customer IdP in Helm. Provider metadata, SAML aliases, group attributes, and group-to-role/scope mappings are tenant-owned and configured in `Admin -> Identity` after the initial administrator has claimed the workspace.

When SAML is enabled, the chart requires `auth.identityProvisioning.enabled=true` because the gateway needs Keycloak admin credentials to:

- reconcile the SAML identity provider into Keycloak
- browse Keycloak-normalized groups for assignment
- validate provider configuration from the Admin UI

Production sequence:

1. Deploy with local bootstrap, identity provisioning, and optional bootstrap SMTP enabled.
2. Claim the first administrator locally.
3. Open `Admin -> Identity`.
4. Keep or switch the authorization model from `Local Syncratic authorization` to `External IdP group authorization`.
5. Create the SAML provider using metadata URL or entity ID plus SSO URL.
6. Validate the provider to reconcile it with Keycloak.
7. Browse groups and map them to Syncratic roles, permissions, and scoped access.
8. Test with an external IdP user and verify Search, Ask, Explorer, CRM, and connector visibility remain bounded by object-level access.

SAML group reconciliation is request-time and dynamic. Syncratic does not persist external group grants into local user role tables on every login; it merges current token groups with configured mappings into the effective access context for that request.

## First-run bootstrap SMTP

First-time administrator claim requires email delivery because the claim flow provisions the initial Keycloak identity and sends required actions for email verification and password creation. The chart supports a bootstrap SMTP relay under `auth.bootstrapSmtp` so a fresh deployment can send that setup email before a tenant administrator has configured tenant-owned SMTP in the Admin UI.

The bootstrap relay is intentionally a platform default, not the final tenant notification configuration. After the initial administrator completes the claim, they must open `Admin -> Notifications -> Email provider` and replace the bootstrap SMTP settings with production-owned tenant settings. A tenant override takes precedence over the platform environment SMTP values used during bootstrap.

Recommended production pattern:

1. create a Kubernetes Secret for the SMTP password outside Git
2. enable `auth.bootstrapSmtp.enabled=true`
3. point `auth.bootstrapSmtp.passwordSecret.existingSecret` at the Secret
4. keep `auth.bootstrapSmtp.syncKeycloak=true` so Keycloak `execute-actions-email` works for first-user setup
5. require the claimed administrator to replace SMTP from the UI after login

Example Secret creation:

```bash
kubectl create secret generic syncratic-bootstrap-smtp \
  -n syncratic \
  --from-literal=SMTP_PASSWORD='<smtp-password>'
```

Example values overlay:

```yaml
auth:
  identityProvisioning:
    enabled: true
    initialOperatorEnabled: true
    sendRequiredActionEmails: true
  bootstrapSmtp:
    enabled: true
    host: smtp-relay.brevo.com
    port: 587
    username: 9f1a6c001@smtp-brevo.com
    useStarttls: true
    useSsl: false
    fromEmail: neoreply@syncratic.co
    fromName: Noreply Syncratic
    syncKeycloak: true
    passwordSecret:
      existingSecret: syncratic-bootstrap-smtp
      key: SMTP_PASSWORD
```

When enabled, Helm wires the same bootstrap SMTP posture into two places:

- Gateway platform SMTP environment variables, used as the fallback notification provider until a tenant override exists.
- A post-install/post-upgrade Keycloak SMTP reconciliation job, used so Keycloak can send required-action emails for verification and password setup.

Do not commit SMTP passwords into values files. Use cluster Secrets, External Secrets, or sealed secret tooling.

## Notification dispatcher and operational alerts

The gateway contains the notification dispatcher, user delivery preferences, and administrator-managed operational alert rules. Kubernetes rollouts should configure this through `gateway.notifications` instead of ad hoc `gateway.extraEnv` overrides.

Dispatcher values:

- `gateway.notifications.dispatcher.enabled` starts the in-process delivery loop.
- `gateway.notifications.dispatcher.batchSize` limits queued notification work per pass.
- `gateway.notifications.dispatcher.intervalSeconds` controls polling cadence.
- `gateway.notifications.dispatcher.maxAttempts` and `retryBaseSeconds` control retry behavior.

Webhook fallback values:

- `gateway.notifications.webhook.enabled` enables the platform webhook target.
- `gateway.notifications.webhook.url` is the centralized route used when a user or tenant policy selects webhook delivery without a user-specific target.
- `gateway.notifications.webhook.tokenSecret.existingSecret` should point to a cluster-owned Secret for production.
- `gateway.notifications.webhook.tokenSecret.create=true` is only for bootstrap or non-production clusters where the token is intentionally chart-owned.

Example production overlay:

```yaml
gateway:
  notifications:
    dispatcher:
      enabled: true
      batchSize: 20
      intervalSeconds: 15
      maxAttempts: 5
      retryBaseSeconds: 60
    webhook:
      enabled: true
      url: https://hooks.example.com/syncratic-alerts
      timeoutSeconds: 5
      tokenSecret:
        existingSecret: syncratic-notification-webhook
        key: NOTIFICATION_WEBHOOK_TOKEN
```

Post-deploy sequence:

1. Confirm the gateway migration hook completed successfully so notification alert-rule tables exist.
2. Open `Admin -> Notifications -> Operational alerts`.
3. Seed default alert rules.
4. Evaluate now to generate routeable alert events from current health signals.
5. Send a test alert and retain route-test evidence for `gateway.operationsReadiness.paths.alertingManifest` when production readiness evidence is enabled.

This subsystem does not replace tenant-owned email configuration. Bootstrap SMTP remains the first-run identity setup path, while tenant SMTP/webhook settings and user delivery preferences govern ongoing delivery.

## LES connected control-plane contract

The chart now supports an explicit connected LES control-plane contract instead of relying on generic `licensing.extraEnv` overrides.

Connected-mode values:

- `licensing.controlPlane.mode=connected`
- `licensing.controlPlane.url`
- `licensing.controlPlane.tokenSecret.existingSecret`

Optional TLS material:

- `licensing.controlPlane.tls.caConfigMap`
- `licensing.controlPlane.tls.clientSecret`

When connected mode is enabled, the chart wires:

- `LES_CONTROL_PLANE_URL`
- `LES_CONTROL_PLANE_LICENSE_STATUS_PATH`
- `LES_CONTROL_PLANE_UPDATE_DISCOVERY_PATH`
- `LES_CONTROL_PLANE_HEARTBEAT_PATH`
- `LES_CONTROL_PLANE_TOKEN_FILE`
- optional TLS CA and client-cert paths

This is the preferred boundary when the runtime is expected to operate in connected sovereign mode with cluster-owned control-plane token and TLS material.

## Auth secret boundary

The chart now supports a dedicated runtime auth secret for frontend auth material:

- `auth.runtimeSecret.existingSecret`

or, for bootstrap-style environments:

- `auth.runtimeSecret.create=true`

When configured, frontend auth material is sourced from that secret instead of from the general bootstrap secret:

- `NEXTAUTH_SECRET`
- `KEYCLOAK_CLIENT_SECRET`

This is the preferred boundary when the environment wants auth-session and OAuth client material to be owned separately from:

- LES service-token material
- connector encryption material
- fallback database password material

## Help runtime boundary

The chart now packages the customer-facing Help runtime:

- `help-service`
- shared Help SQLite persistence
- dedicated Help-to-Gateway token secret sourcing

It also supports an optional curator profile:

- `help.curator.enabled=true`

Curator remains intentionally explicit about its source material. When enabled, it requires:

- `help.curator.docs.existingClaim`

This chart does not pretend the `docs/` corpus is automatically present in-cluster. Operators must mount a real docs claim when they want in-cluster Help reconciliation.

When curator is enabled, the chart now also provides:

- a dedicated `help-curator` ClusterIP Service
- runtime smoke-gate coverage for curator health
- internal-only ingress allowance from chart pods

Dedicated Help gateway-token contract:

- `help.gatewayTokenSecret.existingSecret`

or, for bootstrap-oriented environments:

- `help.gatewayTokenSecret.create=true`

The material-contract gate validates:

- `HELP_GATEWAY_TOKEN`
- `HELP_CURATOR_GATEWAY_TOKEN` when curator is enabled

## External dependencies

Production runtime assumes the following remain external or pre-provisioned:

- Postgres
- Redis
- Qdrant
- Neo4j
- model-serving endpoints

The chart now supports a dedicated external connection secret for dependency-owned connection material:

- `externalServices.connectionSecret.existingSecret`

When that secret is provided, gateway, runtime workers, and the dependency test job source connection URLs and Neo4j credentials from it instead of from plain values or the bootstrap secret.

This is the preferred boundary when dependency URLs embed credentials or when the environment treats dependency connection material as cluster-owned secret state.

The chart now also supports a dedicated external trust bundle ConfigMap:

- `externalServices.trustBundle.existingConfigMap`

When configured, gateway, runtime workers, and the dependency test job mount that bundle and set:

- `REQUESTS_CA_BUNDLE`
- `SSL_CERT_FILE`

This is the preferred boundary when external Keycloak, model-serving, vector, or graph endpoints use enterprise or private CA chains.

When `networkPolicy.allowAllEgress=false`, external dependency reachability must be modeled explicitly through CIDR allowlists or additional raw egress rules.

This chart does not pretend Kubernetes `NetworkPolicy` can restrict by hostname. If a backing service sits outside the cluster, operators must provide:

- `networkPolicy.externalCidrs`
- or `networkPolicy.extraEgressRules`

## Dependency gate

The chart now includes a Helm test dependency gate for the external runtime contract.

It performs in-cluster TCP reachability checks for the configured:

- Postgres
- Redis
- Qdrant
- Neo4j
- Keycloak
- embedding endpoint
- fast LLM endpoint
- deep LLM endpoint
- transformer endpoint

This is not a semantic health check for those systems. It is a deployment-contract gate that proves the charted runtime can resolve and open the required backing-service sockets from inside the cluster.

## Network policy posture

Default behavior remains bootstrap-friendly:

- `networkPolicy.allowAllEgress=true`

Ingress is now explicit and component-aware:

- release-wide ingress defaults to deny
- `gateway` ingress is allowed from:
  - other chart pods
  - configured ingress-controller sources
- `frontend` ingress is allowed from:
  - other chart pods
  - configured ingress-controller sources
- `licensing` ingress is allowed from chart pods only
- `transformer` ingress is allowed from chart pods only when deployed

Ingress-controller source contract:

- preferred:
  - `networkPolicy.ingressController.enabled=true`
  - `networkPolicy.ingressController.namespaceLabels`
  - optional `networkPolicy.ingressController.podLabels`
- compatibility fallback:
  - `networkPolicy.allowIngressNamespaceLabels`

If ingress is enabled and neither ingress-controller source nor legacy namespace-label fallback is configured, the chart will still render, but the external ingress controller will not be allowed through the network policy.

Tighter mode is now available:

- `networkPolicy.allowAllEgress=false`
- `networkPolicy.allowChartPodEgress=true`
- DNS egress explicitly allowed to kube-dns by default
- external dependency egress allowed only through:
  - `networkPolicy.externalCidrs`
  - `networkPolicy.extraEgressRules`

This is the honest Kubernetes boundary:

- pod-to-pod policy can be encoded directly
- DNS can be encoded directly
- external FQDN policy cannot be expressed here without a separate CNI/provider capability
- ingress-controller pod admission must be modeled through namespace/pod selectors, not hostnames

## Runtime smoke gate

The chart now also includes a separate Helm test runtime smoke gate for the packaged services themselves.

It performs in-cluster HTTP checks for:

- gateway readiness
- frontend root availability
- licensing readiness
- optional Keycloak discovery readiness when the chart deploys it
- optional transformer health when the chart deploys it

This is intentionally separate from the dependency gate:

- dependency gate proves the runtime can reach its external contract
- runtime smoke gate proves the charted workloads themselves came up cleanly

## Material contract gate

The chart also includes a Helm test material-contract gate for mounted secret and trust inputs.

It validates:

- bootstrap secret presence
- auth runtime secret presence
- non-empty required bootstrap secret keys
- non-empty required auth runtime secret keys
- LES public keyring mount presence
- connected LES control-plane token presence when connected mode is enabled
- connected LES control-plane CA and client TLS material when configured
- parseable `public_keys.json`
- non-empty signing key set by default

This is the chart-side proof that production runtime is not hand-waving secret and trust-material separation.

## Install-time values contract

`values.schema.json` now hard-fails clearly broken deployment shapes at Helm render/install time.

Current enforced contract includes:

- `ingress.enabled=true` requires:
  - `ingress.frontendHost`
  - `ingress.gatewayHost`
- `ingress.tlsPolicy.mode=cluster_managed` requires:
  - `ingress.enabled=true`
  - `ingress.className`
  - `ingress.publicScheme=https`
- auth topology values must be structurally valid:
  - `auth.frontendClientId`
  - `auth.gatewayBootstrapPath`
  - `auth.connectorOAuthRedirectPath`
- without `externalServices.connectionSecret.existingSecret`, critical external dependency URLs and realm must be non-empty:
  - `externalServices.redisUrl`
  - `externalServices.qdrantUrl`
  - `externalServices.neo4jUri`
  - `externalServices.keycloakInternalUrl`
  - `externalServices.keycloakRealm`
  - `externalServices.bgeEmbeddingsUrl`
  - `externalServices.llmFastUrl`
  - `externalServices.llmDeepUrl`
- without `externalServices.connectionSecret.existingSecret`, `transformer.enabled=false` requires:
  - `externalServices.transformerUrl`
- `security.bootstrapSecret.create=false` requires:
  - `security.existingSecret`
- `licensing.controlPlane.mode=connected` requires:
  - `licensing.controlPlane.url`
  - `licensing.controlPlane.tokenSecret.existingSecret`
- `licensing.publicKeys.create=false` requires:
  - `licensing.publicKeys.existingConfigMap`
- `gateway.persistence.docs.enabled=true` requires:
  - `gateway.persistence.docs.existingClaim`
- `networkPolicy.enabled=true` with `allowAllEgress=false` requires at least one explicit egress path:
  - chart-pod egress
  - DNS egress
  - external CIDRs
  - extra raw egress rules

This is intentionally separate from the Helm test hooks:

- schema validation catches structurally invalid deployment values early
- Helm tests catch runtime, dependency, material, and ingress-contract failures after render/install

## External connection secret

When `externalServices.connectionSecret.existingSecret` is set, the chart expects that Secret to carry these keys:

- `DATABASE_URL`
- `REDIS_URL`
- `QDRANT_URL`
- `NEO4J_URI`
- `NEO4J_USERNAME`
- `NEO4J_PASSWORD`
- `KEYCLOAK_INTERNAL_URL`
- `BGE_EMBEDDINGS_URL`
- `LLM_FAST_URL`
- `LLM_DEEP_URL`
- `TRANSFORMER_URL`

`KEYCLOAK_REALM` remains a normal deployment value because it is identity topology, not secret material.

## Auth topology

The chart now derives auth topology instead of leaving it embedded in generic `extraEnv` maps.

Derived contract:

- public app base URL:
  - `{{ ingress.publicScheme }}://{{ ingress.frontendHost }}` when ingress is enabled
  - otherwise `http://localhost`
- public auth base URL:
  - `{{ ingress.publicScheme }}://{{ ingress.authHost || ingress.gatewayHost }}` when ingress is enabled
  - otherwise `http://localhost`
- public Keycloak issuer:
  - `<public auth base>/realms/<keycloakRealm>`
- internal Keycloak issuer:
  - `<keycloakInternalUrl>/realms/<keycloakRealm>`
- connector callback URL:
  - `<public app base>{{ auth.connectorOAuthRedirectPath }}`
  - this exact value must be registered as a Web redirect URI in Google Cloud Console or Microsoft Entra for deployment-owned connector OAuth clients

Frontend and gateway env wiring now derives from that contract for:

- `NEXTAUTH_URL`
- `NEXT_PUBLIC_APP_URL`
- `AUTH_PUBLIC_BASE_URL`
- `KEYCLOAK_ISSUER`
- `KEYCLOAK_JWKS_URL`
- `KEYCLOAK_TOKEN_URL`
- `CONNECTOR_OAUTH_REDIRECT_URL`
- `KEYCLOAK_CLIENT_ID`
- `GATEWAY_BOOTSTRAP_PATH`

## External trust bundle

When `externalServices.trustBundle.existingConfigMap` is set, the chart expects that ConfigMap to carry the configured trust-bundle key:

- default key: `ca.crt`

The material-contract gate then verifies:

- the trust bundle is mounted
- the trust bundle file is non-empty

## Ingress contract gate

When `ingress.enabled=true`, the chart now includes a separate Helm test for the public host contract.

It validates that:

- `frontendHost` is set
- `gatewayHost` is set
- `authHost`, when used, is actually represented in the ingress rules
- the runtime public URL env surface is not still pointing at `localhost`
- the runtime public URL env surface matches the declared ingress hosts and scheme
- frontend and gateway Keycloak issuer values match the public auth topology
- gateway JWKS and token endpoints match the internal Keycloak topology
- connector callback and gateway bootstrap path match the declared auth topology

This is intentionally strict. If ingress is enabled, a deployment should fail fast when the public host contract is inconsistent.

Like the material gate, this means the stock chart defaults remain render-safe but are not ingress-ready. An operator must replace the default `localhost`-style public URLs before `helm test` should pass in an ingress-enabled environment.

## Secrets and trust material

The chart supports two patterns:

1. Reference an existing Kubernetes `Secret` for sensitive values.
2. Let the chart create a small bootstrap `Secret` from Helm values.

The LES public keyring can likewise come from:

1. an existing `ConfigMap`
2. an inline JSON value rendered by the chart

## Entitlement runtime shape

This chart now carries the current LES runtime entitlement contract:

- gateway defaults entitlement enforcement on
- gateway carries worker-seat lease timing values
- dedicated `runtimeWorkers` Deployments mirror the standalone `workers.llmfs_worker` processes that consume LES worker seats for:
  - `max_workers`
- a node-scoped `runtime-node-agent` DaemonSet holds LES node seats for:
  - `max_nodes`
  - `max_gpu_nodes`

The DaemonSet uses the Kubernetes node name as the default `ENTITLEMENT_NODE_ID`.
Override `runtimeNodeAgent.extraEnv` only when a cluster needs a different node identity or GPU posture contract.

The worker family is enabled by default so Helm matches the live compose runtime topology.
Override `runtimeWorkers.workers` when a cluster needs to suppress, scale, or specialize individual worker modes.

## Connector provider credential boundary

Tenant-specific connector OAuth credentials should not be modeled as routine Helm values.

Preferred operating model:

1. deploy platform runtime with shared infrastructure and encryption key material
2. tenant admin configures connector provider credentials in the product UI
3. gateway resolves tenant override first, platform fallback second

Platform-wide connector credentials are still allowed as fallback deployment config, but that is not the preferred enterprise operating path.

## First-use notes

Populate at minimum:

- image repositories and tags
- ingress hosts
- external service URLs/credentials
- LES deployment id
- LES public keyring
- service token secret
- runtime node-agent image coordinates if they differ from the gateway image
- docs PVC wiring if `runtimeWorkers` will process document-backed queues in-cluster

For dependency gating, also verify:

- `dependencyTests.enabled=true` unless the environment already performs an equivalent cluster-side check
- external service URLs resolve correctly from inside the target namespace
- `runtimeTests.enabled=true` unless the environment already performs an equivalent packaged-runtime smoke check
- `materialTests.enabled=true` unless the environment already performs an equivalent mounted secret and trust-material contract check
- `ingressTests.enabled=true` when `ingress.enabled=true`, unless the environment already performs an equivalent public-host contract check
- if `networkPolicy.allowAllEgress=false`, the external dependency paths are represented through:
  - `networkPolicy.externalCidrs`
  - or `networkPolicy.extraEgressRules`
- if `ingress.enabled=true`, the runtime public URL env values are not left on `localhost`

Avoid adding tenant-owned connector OAuth credentials to environment-specific values files unless you are intentionally using platform fallback mode.

For details, start with:

- `values.yaml`
- `templates/NOTES.txt`
## Helm Test Image Contract

By default, the production runtime Helm test hooks inherit the packaged `gateway.image` contract.

That means:
- `dependencyTests.image.*`
- `runtimeTests.image.*`
- `materialTests.image.*`
- `ingressTests.image.*`

can be left blank and will use the same repository, tag, and pull policy as the charted gateway image. Override them only when the cluster intentionally uses a separate operator-approved test image.


### Gateway Session Timeout

The chart sets `gateway.extraEnv.AUTH_SESSION_TTL_SECONDS=300` by default. Gateway uses this value for the httpOnly session cookie `Max-Age`, the in-memory session cache TTL, and Redis-backed session persistence TTL when Redis is configured.

Override this value only if the deployment has an explicit security decision to allow longer interactive sessions.
