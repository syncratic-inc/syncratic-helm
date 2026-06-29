# Syncratic Helm Charts

Customer-facing Helm packaging for Syncratic Kubernetes deployments.

This repository intentionally contains Helm chart sources and packaged chart archives only. It does not contain Syncratic application source code.

## Charts

- `syncratic-phase1`: main Syncratic runtime chart for gateway, frontend, identity facade, storage dependencies, workers, Help, licensing, observability, and runtime policy gates.
- `control-plane-sync-service`: standalone control-plane authority synchronization service chart.

## Install From Chart Source

```bash
helm install syncratic-phase1 ./charts/syncratic-phase1   --namespace syncratic   --create-namespace   -f customer-values.yaml
```

## Install From Packaged Chart

```bash
helm install syncratic-phase1 ./packages/syncratic-phase1-0.1.0.tgz   --namespace syncratic   --create-namespace   -f customer-values.yaml
```

## Helm Repository Usage

If this repository is published through GitHub Pages, add it as a Helm repository:

```bash
helm repo add syncratic https://syncratic-inc.github.io/syncratic-helm
helm repo update
helm install syncratic-phase1 syncratic/syncratic-phase1   --namespace syncratic   --create-namespace   -f customer-values.yaml
```

## Required Customer Inputs

Customers should provide deployment-owned values for:

- public hostnames and TLS policy
- image registry, immutable tags, or digests
- pull secrets for private images
- SMTP/bootstrap email settings if first-admin claim email is required
- identity provider posture and SAML settings, if external IdP is used
- PostgreSQL, Redis, Qdrant, Neo4j, model endpoint, and trust-bundle topology when using external dependencies
- Kubernetes Secrets or External Secrets for all passwords, tokens, signing material, and private keys

Do not put production secrets directly into values files committed to Git. Use Kubernetes Secrets, External Secrets, sealed secrets, or equivalent customer-controlled secret management.

## Source Boundary

The charts reference container images by repository/tag/digest. The application source code, tests, internal scripts, development compose files, and private operational artifacts are not included in this repository.
