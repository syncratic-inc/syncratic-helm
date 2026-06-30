# Production runtime Example Overlays

## Online Observability

Files:

- `online-observability.values.yaml`
- `k3s-observability-enable.values.yaml`
- `phase2-les-launcher.values.yaml`
- `online-observability.materials.env.example`
- `phase2-les-launcher.materials.env.example`
- `online-observability.images.env.example`
- `online-observability.image-manifest.example.json`
- `render_online_observability_materials.py`
- `render_phase2_les_launcher_materials.py`
- `render_online_observability_image_overrides.py`
- `../../../scripts/run_syncratic_online_observability.sh`
- `../../../scripts/validate_syncratic_online_observability_runner.sh`
- `../../../scripts/run_syncratic_registration_les.sh`
- `../../../scripts/validate_syncratic_registration_les_runner.sh`
- `../../../.github/workflows/syncratic-online-observability.yml`

Use this flow for the first same-domain Kubernetes observability rollout:

1. Copy `online-observability.materials.env.example` to `online-observability.materials.env`.
2. Copy `online-observability.images.env.example` to `online-observability.images.env`.
3. Fill in the real secret values and published image refs.
   Or replace the image env file with a real release manifest derived from the published image set.
4. Render the required cluster material:

```bash
.venv/bin/python kubernetes/helm/syncratic/examples/render_online_observability_materials.py \
  --env-file kubernetes/helm/syncratic/examples/online-observability.materials.env \
  --namespace syncratic \
  --output /tmp/syncratic-observability-materials.yaml
```

5. Render the image override values:

```bash
.venv/bin/python kubernetes/helm/syncratic/examples/render_online_observability_image_overrides.py \
  --env-file kubernetes/helm/syncratic/examples/online-observability.images.env \
  --output /tmp/syncratic-observability-images.values.yaml
```

Manifest-driven alternative:

```bash
.venv/bin/python kubernetes/helm/syncratic/examples/render_online_observability_image_overrides.py \
  --manifest-file /path/to/syncratic-image-release-manifest.json \
  --output /tmp/syncratic-observability-images.values.yaml
```

6. Apply the material set:

```bash
kubectl apply -f /tmp/syncratic-observability-materials.yaml
```

7. Install or upgrade the chart with:

```bash
helm upgrade --install syncratic kubernetes/helm/syncratic \
  -n syncratic \
  -f kubernetes/helm/syncratic/examples/online-observability.values.yaml \
  -f /tmp/syncratic-observability-images.values.yaml
```

Single-command wrapper:

```bash
bash scripts/run_syncratic_online_observability.sh \
  --release syncratic \
  --namespace syncratic \
  --chart-path kubernetes/helm/syncratic \
  --values-file kubernetes/helm/syncratic/examples/online-observability.values.yaml \
  --materials-env-file kubernetes/helm/syncratic/examples/online-observability.materials.env \
  --materials-output /tmp/syncratic-observability-materials.yaml \
  --helm-template-output /tmp/syncratic-observability-rendered-chart.yaml \
  --images-env-file kubernetes/helm/syncratic/examples/online-observability.images.env \
  --images-values-output /tmp/syncratic-observability-images.values.yaml \
  --run-helm-tests \
  --helm-test-timeout 10m \
  --verify-observability-url https://portal.syncratic.co/observability \
  --verification-output /tmp/syncratic-observability-verification.json \
  --create-namespace
```

Render-only validation:

```bash
bash scripts/run_syncratic_online_observability.sh \
  --release syncratic \
  --namespace syncratic \
  --chart-path kubernetes/helm/syncratic \
  --values-file kubernetes/helm/syncratic/examples/online-observability.values.yaml \
  --materials-env-file kubernetes/helm/syncratic/examples/online-observability.materials.env \
  --materials-output /tmp/syncratic-observability-materials.yaml \
  --helm-template-output /tmp/syncratic-observability-rendered-chart.yaml \
  --images-env-file kubernetes/helm/syncratic/examples/online-observability.images.env \
  --images-values-output /tmp/syncratic-observability-images.values.yaml \
  --render-only
```

Generated material set:

- `Secret/syncratic-auth-runtime`
- `Secret/syncratic-keycloak-admin`
- `Secret/syncratic-keycloak-db`
- `Secret/syncratic-observability-grafana-admin`
- `ConfigMap/syncratic-keycloak-realm`
- optional live verification report:
  - `/tmp/syncratic-observability-verification.json`
- optional live Helm test execution:
  - `helm test syncratic --namespace syncratic --timeout 10m`
  - artifact retention:
    - `helm-test-output.txt`
    - `helm-test-report.json`

Important boundary:

- the rendered Keycloak realm ConfigMap is generated from the repo-owned `keycloak/syncratic-realm.json`
- the script injects `KEYCLOAK_CLIENT_SECRET` into the `syncratic-portal` client so the frontend runtime secret and the Keycloak realm import stay aligned
- the base overlay still carries stable example image refs, not the current branch build
- the image-override renderer is the repo-owned seam that advances the rollout to the actual published `gateway`, `frontend`, and service images for the current release
- the preferred long-term input is a single release manifest artifact rather than handwritten env updates for each rollout
- the same bounded rollout can now also be executed from the dedicated self-hosted GitHub Actions workflow when the runner-side file contracts are provisioned

## Existing Keycloak Realm Reconciliation

If the target cluster already has a long-lived `syncratic` realm, the repo-owned realm import ConfigMap is not enough by itself to add newer observability clients.

That is the case when:

- Keycloak already imported the realm before `grafana-observability` existed
- the current Keycloak import posture ignores an existing realm instead of mutating it

Use the repo-owned reconciler after the Helm rollout:

```bash
bash scripts/reconcile_syncratic_keycloak_observability_client.sh \
  --namespace syncratic \
  --release syncratic \
  --observability-base-url https://app.192.168.2.233.nip.io/observability \
  --keycloak-admin-user admin \
  --keycloak-admin-password change-me-keycloak-admin-password
```

What it reconciles:

- `grafana-observability` public OIDC client
- redirect URI and web-origin contract for the current observability host
- PKCE requirement
- `grafana-realm-roles` mapper so Grafana receives a stable top-level `roles` claim

This is intentionally a bounded reconciliation step:

- it fixes the observability SSO seam for an existing realm
- it does not try to fully rewrite or reimport the entire live realm

## Existing K3s Phase-1 Enablement

For an already-running production runtime k3s release, use:

- the current release values exported from the cluster
- plus `k3s-observability-enable.values.yaml`

This overlay matches the live bounded enablement path that was proven on k3s:

- keeps existing auth, Keycloak admin, Keycloak DB, and Keycloak realm refs
- enables Grafana under `/observability`
- uses the Grafana admin secret boundary
- temporarily admits the current k3s `admin` realm role in addition to:
  - `super_admin`
  - `syncratic-admin`
- leaves Prometheus datasource wiring disabled when no in-cluster Prometheus backend exists yet

Representative flow:

```bash
helm get values syncratic -n syncratic -o yaml > /tmp/syncratic-current-values.yaml

bash scripts/run_syncratic_online_observability_release.sh \
  --release-id syncratic-k3s-observability-001 \
  --gateway-image syncratic-core-gateway:latest \
  --frontend-image syncratic/fkap-frontend:local \
  --help-image syncratic/help-service:latest \
  --licensing-image syncratic-core-licensing:latest \
  --registration-image syncratic-core-registration-service:latest \
  --release syncratic \
  --namespace syncratic \
  --chart-path kubernetes/helm/syncratic \
  --values-file /tmp/syncratic-current-values.yaml \
  --materials-env-file /path/to/online-observability.materials.env \
  --materials-output /tmp/syncratic-observability-materials.yaml \
  --image-manifest-output /tmp/syncratic-image-release-manifest.json \
  --images-values-output /tmp/syncratic-observability-images.values.yaml \
  --helm-template-output /tmp/syncratic-observability-rendered-chart.yaml \
  --helm-arg --values \
  --helm-arg kubernetes/helm/syncratic/examples/k3s-observability-enable.values.yaml \
  --run-helm-tests \
  --helm-test-timeout 10m \
  --helm-test-output /tmp/syncratic-observability-helm-test-output.txt \
  --helm-test-report-output /tmp/syncratic-observability-helm-test-report.json \
  --verify-observability-url https://app.192.168.2.233.nip.io/observability \
  --verify-connect-ip 192.168.2.233 \
  --verify-insecure \
  --verification-output /tmp/syncratic-observability-verification.json
```

Important boundary:

- `--verify-connect-ip` is for runners that cannot resolve the public ingress hostname directly
- `--verify-insecure` is only for clusters using self-signed ingress TLS during bootstrap or lab operation

## Phase 2 LES Launcher Overlay

This overlay is a delta on top of an existing online/base runtime values file.

Files:

- `phase2-les-launcher.values.yaml`
- `phase2-les-launcher.materials.env.example`
- `render_phase2_les_launcher_materials.py`
- `render_online_observability_image_overrides.py`
- `../../../scripts/run_syncratic_registration_les.sh`
- `../../../scripts/validate_syncratic_registration_les_runner.sh`

Use this flow when the target cluster already has a runtime base values file and you want to add the stricter phase2 LES launcher contract:

- `registration.les.steadyStateAuthMode=mtls`
- `registration.les.licenseHandoffMode=embedded_signed_license`

Render-only validation:

```bash
bash scripts/run_syncratic_registration_les.sh \
  --release syncratic \
  --namespace syncratic \
  --chart-path kubernetes/helm/syncratic \
  --base-values-file /path/to/current-online.values.yaml \
  --les-values-file kubernetes/helm/syncratic/examples/phase2-les-launcher.values.yaml \
  --materials-env-file kubernetes/helm/syncratic/examples/phase2-les-launcher.materials.env \
  --materials-output /tmp/syncratic-les-materials.yaml \
  --helm-template-output /tmp/syncratic-les-rendered-chart.yaml \
  --image-manifest-file /path/to/syncratic-image-release-manifest.json \
  --images-values-output /tmp/syncratic-les-images.values.yaml \
  --render-only
```

Live rollout:

```bash
bash scripts/run_syncratic_registration_les.sh \
  --release syncratic \
  --namespace syncratic \
  --chart-path kubernetes/helm/syncratic \
  --base-values-file /path/to/current-online.values.yaml \
  --les-values-file kubernetes/helm/syncratic/examples/phase2-les-launcher.values.yaml \
  --materials-env-file kubernetes/helm/syncratic/examples/phase2-les-launcher.materials.env \
  --materials-output /tmp/syncratic-les-materials.yaml \
  --helm-template-output /tmp/syncratic-les-rendered-chart.yaml \
  --image-manifest-file /path/to/syncratic-image-release-manifest.json \
  --images-values-output /tmp/syncratic-les-images.values.yaml \
  --run-helm-tests \
  --helm-test-timeout 10m
```

Generated material set:

- `Secret/syncratic-registration-les-mtls-ca`
- `Secret/syncratic-registration-les-initial-license`

Important boundary:

- this overlay is intentionally not a standalone full-environment values file
- it is a focused phase2 delta that layers the LES launcher contract on top of the operator’s existing online/base runtime deployment posture

## Operations Readiness Evidence Overlay

Use `operations-readiness.values.yaml` when retained production-readiness artifacts are available on a deployment-owned PVC and should be visible in `Admin -> Operations`.

```bash
helm upgrade --install syncratic ./kubernetes/helm/syncratic \
  -f kubernetes/helm/syncratic/examples/operations-readiness.values.yaml
```

The overlay only wires paths and an existing evidence PVC into the gateway. It does not create evidence artifacts or run production drills.
