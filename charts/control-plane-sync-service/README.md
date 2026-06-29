# Control Plane Sync Service Helm Chart

Local engineering entrypoint.

Canonical docs:

- `../../../docs/kubernetes/helm/README.md`
- `../../../docs/kubernetes/README.md`
- `../../../docs/licensing/README.md`

Standalone Helm packaging for the Syncratic `control-plane-sync-service`.

Purpose:

- deploy the authority service independently of the wider Compose stack
- preserve current singleton, internal-only authority posture
- establish a clean Helm-oriented secret, storage, and upgrade contract

Current chart shape:

- `StatefulSet`
- `ClusterIP` service only
- no ingress
- PVC-backed SQLite state
- secret-mounted signing keys and runtime secret files
- explicit authority identity and federation-readiness env contract

Required Kubernetes secrets:

1. signing-key secret
- mounted at `/app/keys/private`
- must contain the active Ed25519 private key file such as:
  - `ed25519-prod-2026-01.key`

2. runtime-secret secret
- mounted at `/run/secrets`
- should contain whichever files are enabled by values, for example:
  - `control-plane-sync-client-tokens.json`
  - `control-plane-sync-client-policies.json`
  - `control-plane-sync-shared-token`
  - `control-plane-sync-operator-tokens.json`
  - `control-plane-sync-operator-roles.json`
  - optional TLS materials

Important boundary:

- this chart is for standalone authority productization
- it does not implement Federated Authorities
- it does not claim HA or multi-writer coordination

Federation-ready contract:

- the chart now carries explicit authority identity inputs for:
  - authority instance ID
  - authority span ID
  - environment
  - region
  - role
- the chart also carries federation posture inputs for:
  - federation-ready declaration
  - federation-enabled flag
  - federation domain
- the chart also carries operator-governance posture for:
  - `requireDualApproval`

Current expectation:

- deploy with `federationEnabled=false`
- deploy with `requireDualApproval=true` once at least two approver identities are provisioned
- treat these values as future-compatible identity seams for later federated authority spans

Delivery automation surface:

- the chart now includes a Helm test job that consumes:
  - `GET /v1/authority/release-gates`
- default test profile:
  - `install`
- configurable through:
  - `deliveryTests.enabled`
  - `deliveryTests.releaseGateProfiles`

Recommended install pattern:

```bash
helm upgrade --install control-plane-sync-service ./kubernetes/helm/control-plane-sync-service \
  --set signingKeys.existingSecret=control-plane-sync-signing-keys \
  --set runtimeSecrets.existingSecret=control-plane-sync-runtime-secrets
```

Recommended post-install validation:

```bash
helm test control-plane-sync-service --logs
```

Recommended upgrade validation:

```bash
helm upgrade --install control-plane-sync-service ./kubernetes/helm/control-plane-sync-service \
  --set signingKeys.existingSecret=control-plane-sync-signing-keys \
  --set runtimeSecrets.existingSecret=control-plane-sync-runtime-secrets \
  --set-json 'deliveryTests.releaseGateProfiles=["upgrade"]'

helm test control-plane-sync-service --logs
```

Recommended retained recovery artifact export:

```bash
python3 scripts/export_control_plane_recovery_package.py \
  --base-url http://control-plane-sync-service-control-plane-sync-service:8095 \
  --operator-tokens-file /run/secrets/control-plane-sync-operator-tokens.json \
  --output-dir /tmp/control-plane-recovery-package \
  --include-fresh-bundle \
  --write-zip
```

Recommended standalone checkpoint run:

```bash
python3 scripts/run_control_plane_standalone_checkpoint.py \
  --base-url http://control-plane-sync-service-control-plane-sync-service:8095 \
  --operator-tokens-file /run/secrets/control-plane-sync-operator-tokens.json \
  --validation-profile operational \
  --release-gate-profile install \
  --output-dir /tmp/control-plane-checkpoint \
  --export-recovery-package \
  --include-fresh-bundle \
  --write-zip
```

Recommended retained backup-evidence manifest:

```bash
python3 scripts/build_control_plane_recovery_retention_manifest.py \
  --checkpoint-summary /tmp/control-plane-checkpoint/checkpoint-summary.json \
  --recovery-package /tmp/control-plane-checkpoint/recovery-package.zip \
  --pvc-backup /backups/control-plane-sync-pvc-2026-05-10.tar.zst \
  --signing-key-backup /backups/control-plane-sync-signing-keys-2026-05-10.tar.zst \
  --runtime-secret-backup /backups/control-plane-sync-runtime-secrets-2026-05-10.tar.zst \
  --output-path /tmp/control-plane-checkpoint/recovery-retention-manifest.json
```

Single-command evidence flow:

```bash
python3 scripts/run_control_plane_recovery_evidence_flow.py \
  --base-url http://control-plane-sync-service-control-plane-sync-service:8095 \
  --operator-tokens-file /run/secrets/control-plane-sync-operator-tokens.json \
  --validation-profile operational \
  --release-gate-profile install \
  --output-dir /tmp/control-plane-evidence \
  --pvc-backup /backups/control-plane-sync-pvc-2026-05-10.tar.zst \
  --signing-key-backup /backups/control-plane-sync-signing-keys-2026-05-10.tar.zst \
  --runtime-secret-backup /backups/control-plane-sync-runtime-secrets-2026-05-10.tar.zst \
  --include-fresh-bundle \
  --write-zip
```

Helm delivery gate wrapper:

```bash
scripts/run_control_plane_helm_delivery_gate.sh \
  --release control-plane-sync-service \
  --namespace syncratic \
  --base-url http://control-plane-sync-service-control-plane-sync-service:8095 \
  --operator-tokens-file /run/secrets/control-plane-sync-operator-tokens.json \
  --output-dir /tmp/control-plane-evidence \
  --pvc-backup /backups/control-plane-sync-pvc-2026-05-10.tar.zst \
  --signing-key-backup /backups/control-plane-sync-signing-keys-2026-05-10.tar.zst \
  --runtime-secret-backup /backups/control-plane-sync-runtime-secrets-2026-05-10.tar.zst \
  --include-fresh-bundle \
  --write-zip
```
