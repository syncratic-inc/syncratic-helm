#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Dict

import yaml


REQUIRED_KEYS = [
    "NEXTAUTH_SECRET",
    "KEYCLOAK_CLIENT_SECRET",
    "KEYCLOAK_ADMIN",
    "KEYCLOAK_ADMIN_PASSWORD",
    "KC_DB_USERNAME",
    "KC_DB_PASSWORD",
    "GF_SECURITY_ADMIN_PASSWORD",
]

DEFAULTS = {
    "GF_SECURITY_ADMIN_USER": "admin",
}


def load_env_file(path: Path) -> Dict[str, str]:
    values: Dict[str, str] = {}
    for raw_line in path.read_text().splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            raise ValueError(f"invalid env line: {raw_line}")
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip()
    return values


def require_values(values: Dict[str, str]) -> Dict[str, str]:
    resolved = dict(DEFAULTS)
    resolved.update(values)
    missing = [key for key in REQUIRED_KEYS if not resolved.get(key)]
    if missing:
        raise ValueError(f"missing required keys: {', '.join(missing)}")
    return resolved


def load_realm_template(repo_root: Path, portal_client_secret: str) -> str:
    realm_path = repo_root / "keycloak" / "syncratic-realm.json"
    realm = json.loads(realm_path.read_text())
    for client in realm.get("clients", []):
        # keep portal and runtime client secret aligned
        if client.get("clientId") == "syncratic-portal":
            client["secret"] = portal_client_secret
    return json.dumps(realm, indent=2) + "\n"


def secret_doc(name: str, namespace: str, string_data: Dict[str, str]) -> Dict[str, object]:
    return {
        "apiVersion": "v1",
        "kind": "Secret",
        "metadata": {"name": name, "namespace": namespace},
        "type": "Opaque",
        "stringData": string_data,
    }


def configmap_doc(name: str, namespace: str, data: Dict[str, str]) -> Dict[str, object]:
    return {
        "apiVersion": "v1",
        "kind": "ConfigMap",
        "metadata": {"name": name, "namespace": namespace},
        "data": data,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Render Syncratic online observability material manifests.")
    parser.add_argument(
        "--env-file",
        default="kubernetes/helm/syncratic/examples/online-observability.materials.env",
        help="Path to env file containing required secret values.",
    )
    parser.add_argument(
        "--namespace",
        default="default",
        help="Kubernetes namespace for generated objects.",
    )
    parser.add_argument(
        "--output",
        default="-",
        help="Output path for rendered YAML. Use - for stdout.",
    )
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[4]
    env_path = (repo_root / args.env_file).resolve() if not Path(args.env_file).is_absolute() else Path(args.env_file)
    values = require_values(load_env_file(env_path))

    realm_json = load_realm_template(repo_root, values["KEYCLOAK_CLIENT_SECRET"])

    documents = [
        secret_doc(
            "syncratic-auth-runtime",
            args.namespace,
            {
                "NEXTAUTH_SECRET": values["NEXTAUTH_SECRET"],
                "KEYCLOAK_CLIENT_SECRET": values["KEYCLOAK_CLIENT_SECRET"],
            },
        ),
        secret_doc(
            "syncratic-keycloak-admin",
            args.namespace,
            {
                "KEYCLOAK_ADMIN": values["KEYCLOAK_ADMIN"],
                "KEYCLOAK_ADMIN_PASSWORD": values["KEYCLOAK_ADMIN_PASSWORD"],
            },
        ),
        secret_doc(
            "syncratic-keycloak-db",
            args.namespace,
            {
                "KC_DB_USERNAME": values["KC_DB_USERNAME"],
                "KC_DB_PASSWORD": values["KC_DB_PASSWORD"],
            },
        ),
        secret_doc(
            "syncratic-observability-grafana-admin",
            args.namespace,
            {
                "GF_SECURITY_ADMIN_USER": values["GF_SECURITY_ADMIN_USER"],
                "GF_SECURITY_ADMIN_PASSWORD": values["GF_SECURITY_ADMIN_PASSWORD"],
            },
        ),
        configmap_doc(
            "syncratic-keycloak-realm",
            args.namespace,
            {
                "realm.json": realm_json,
            },
        ),
    ]

    rendered = "---\n".join(yaml.safe_dump(doc, sort_keys=False) for doc in documents)
    if args.output == "-":
        print(rendered, end="")
    else:
        output_path = Path(args.output)
        if not output_path.is_absolute():
            output_path = repo_root / output_path
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(rendered)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
