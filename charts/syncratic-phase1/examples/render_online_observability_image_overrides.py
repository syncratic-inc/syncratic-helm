#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Dict, Tuple

import yaml


REQUIRED_KEYS = [
    "GATEWAY_IMAGE",
    "FRONTEND_IMAGE",
    "HELP_IMAGE",
    "LICENSING_IMAGE",
    "REGISTRATION_IMAGE",
]

SERVICE_KEYS = {
    "gateway": "GATEWAY_IMAGE",
    "runtimeNodeAgent": "GATEWAY_IMAGE",
    "runtimeWorkers": "GATEWAY_IMAGE",
    "frontend": "FRONTEND_IMAGE",
    "help": "HELP_IMAGE",
    "licensing": "LICENSING_IMAGE",
    "registration": "REGISTRATION_IMAGE",
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


def load_manifest_file(path: Path) -> Dict[str, str]:
    payload = json.loads(path.read_text())
    images = payload.get("images")
    if not isinstance(images, dict):
        raise ValueError("manifest must contain an images object")
    values: Dict[str, str] = {}
    for env_key, manifest_key in [
        ("GATEWAY_IMAGE", "gateway"),
        ("FRONTEND_IMAGE", "frontend"),
        ("HELP_IMAGE", "help"),
        ("LICENSING_IMAGE", "licensing"),
        ("REGISTRATION_IMAGE", "registration"),
    ]:
        image_ref = images.get(manifest_key)
        if image_ref is None:
            continue
        if not isinstance(image_ref, str):
            raise ValueError(f"manifest image ref must be a string: {manifest_key}")
        values[env_key] = image_ref.strip()
    return values


def require_values(values: Dict[str, str]) -> Dict[str, str]:
    missing = [key for key in REQUIRED_KEYS if not values.get(key)]
    if missing:
        raise ValueError(f"missing required keys: {', '.join(missing)}")
    return values


def parse_image_ref(ref: str) -> Tuple[str, str, str]:
    if "@" in ref:
        repository, digest = ref.split("@", 1)
        if not repository or not digest:
            raise ValueError(f"invalid image ref: {ref}")
        return repository, "", digest
    if ":" not in ref:
        raise ValueError(f"image ref must include tag or digest: {ref}")
    repository, tag = ref.rsplit(":", 1)
    if not repository or not tag:
        raise ValueError(f"invalid image ref: {ref}")
    return repository, tag, ""


def build_payload(values: Dict[str, str]) -> Dict[str, object]:
    payload: Dict[str, object] = {}
    for service_name, env_key in SERVICE_KEYS.items():
        repository, tag, digest = parse_image_ref(values[env_key])
        image = {
            "repository": repository,
            "pullPolicy": "IfNotPresent",
        }
        if digest:
            image["digest"] = digest
        else:
            image["tag"] = tag
        payload[service_name] = {"image": image}
    return payload


def main() -> int:
    parser = argparse.ArgumentParser(description="Render Syncratic online observability image override values.")
    parser.add_argument(
        "--env-file",
        default="",
        help="Path to env file containing published image refs.",
    )
    parser.add_argument(
        "--manifest-file",
        default="",
        help="Path to JSON release-image manifest containing published image refs.",
    )
    parser.add_argument(
        "--output",
        default="-",
        help="Output path for rendered YAML. Use - for stdout.",
    )
    args = parser.parse_args()

    if bool(args.env_file) == bool(args.manifest_file):
        raise ValueError("exactly one of --env-file or --manifest-file must be provided")

    repo_root = Path(__file__).resolve().parents[4]
    if args.env_file:
        env_path = (repo_root / args.env_file).resolve() if not Path(args.env_file).is_absolute() else Path(args.env_file)
        values = require_values(load_env_file(env_path))
    else:
        manifest_path = (repo_root / args.manifest_file).resolve() if not Path(args.manifest_file).is_absolute() else Path(args.manifest_file)
        values = require_values(load_manifest_file(manifest_path))
    rendered = yaml.safe_dump(build_payload(values), sort_keys=False)

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
