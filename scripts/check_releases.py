# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

import json
import os
import subprocess
import sys
import tomllib


def get_latest_tag(repo: str) -> str | None:
    proc = subprocess.run(
        ["gh", "release", "view", "--repo", repo, "--json", "tagName", "-q", ".tagName"],
        capture_output=True,
        text=True,
    )
    tag = proc.stdout.strip()
    return tag if tag and tag != "null" else None


def write_toml(path: str, config: dict) -> None:
    with open(path, "w") as f:
        for name, entry in config.items():
            f.write(f"[{name}]\n")
            f.write(f'repo = "{entry["repo"]}"\n')
            f.write(f'tracked = "{entry["tracked"]}"\n')
            f.write("\n")


def main() -> None:
    toml_path = "config.toml"

    with open(toml_path, "rb") as f:
        config = tomllib.load(f)

    results = {}
    any_changed = False

    for name, entry in config.items():
        repo = entry["repo"]
        last = entry["tracked"]
        latest = get_latest_tag(repo)

        changed = latest is not None and latest != last
        results[name] = {"repo": repo, "tracked": last, "upstream": latest, "changed": changed}

        if changed:
            any_changed = True
            config[name]["tracked"] = latest
            print(f"{name}: {last} -> {latest} (changed)")
        else:
            print(f"{name}: up to date ({last})")

    if any_changed:
        write_toml(toml_path, config)

    changed_parts = [
        f"{name}: {r['tracked']} -> {r['upstream']}"
        for name, r in results.items()
        if r["changed"]
    ]
    message = "Sync upstream releases: " + ", ".join(changed_parts)

    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a") as f:
            f.write(f"result={json.dumps(results)}\n")
            f.write(f"any_changed={str(any_changed).lower()}\n")
            f.write(f"message={message}\n")
    else:
        print(json.dumps(results, indent=2))
        sys.exit(0 if not any_changed else 0)


if __name__ == "__main__":
    main()
