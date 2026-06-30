#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path
from typing import Dict

import yaml


REQUIRED_KEYS = [
    "REGISTRATION_LES_MTLS_CA_CERT_FILE",
    "REGISTRATION_LES_MTLS_CA_KEY_FILE",
    "REGISTRATION_LES_INITIAL_LICENSE_FILE",
]


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
    missing = [key for key in REQUIRED_KEYS if not values.get(key)]
    if missing:
        raise ValueError(f"missing required keys: {', '.join(missing)}")
    return values


def read_required_file(path_value: str, repo_root: Path) -> str:
    candidate = Path(path_value)
    if not candidate.is_absolute():
        candidate = (repo_root / candidate).resolve()
    if not candidate.is_file():
        raise FileNotFoundError(f"required file not found: {candidate}")
    content = candidate.read_text(encoding="utf-8").strip()
    if not content:
        raise ValueError(f"required file is empty: {candidate}")
    return content


def secret_doc(name: str, namespace: str, string_data: Dict[str, str]) -> Dict[str, object]:
    return {
        "apiVersion": "v1",
        "kind": "Secret",
        "metadata": {"name": name, "namespace": namespace},
        "type": "Opaque",
        "stringData": string_data,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Render Syncratic phase2 LES launcher material manifests.")
    parser.add_argument(
        "--env-file",
        default="kubernetes/helm/syncratic/examples/phase2-les-launcher.materials.env",
        help="Path to env file containing required LES material file paths.",
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

    cert_pem = read_required_file(values["REGISTRATION_LES_MTLS_CA_CERT_FILE"], repo_root)
    key_pem = read_required_file(values["REGISTRATION_LES_MTLS_CA_KEY_FILE"], repo_root)
    initial_license_json = read_required_file(values["REGISTRATION_LES_INITIAL_LICENSE_FILE"], repo_root)

    documents = [
        secret_doc(
            "syncratic-registration-les-mtls-ca",
            args.namespace,
            {
                "tls.crt": cert_pem,
                "tls.key": key_pem,
            },
        ),
        secret_doc(
            "syncratic-registration-les-initial-license",
            args.namespace,
            {
                "initial-license.json": initial_license_json,
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
        output_path.write_text(rendered, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
