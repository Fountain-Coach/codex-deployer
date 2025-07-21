#!/usr/bin/env python3
"""Ensure the repository directory is shared with Docker Desktop on macOS."""
import json
import os
import sys
from pathlib import Path

SETTINGS_PATH = Path.home() / 'Library/Group Containers/group.com.docker/settings.json'

def add_share(path: Path) -> bool:
    if not SETTINGS_PATH.exists():
        print('Docker Desktop settings not found. Are you on macOS with Docker Desktop installed?')
        return False
    try:
        data = json.loads(SETTINGS_PATH.read_text())
    except json.JSONDecodeError as exc:
        print(f'Failed to parse {SETTINGS_PATH}: {exc}')
        return False

    dirs = data.get('filesharingDirectories', [])
    path_str = str(path.resolve())
    if path_str in dirs:
        print(f'{path_str} already in file sharing list.')
        return True
    dirs.append(path_str)
    data['filesharingDirectories'] = dirs
    SETTINGS_PATH.write_text(json.dumps(data, indent=2))
    print(f'Added {path_str} to file sharing list.')
    return True

def main() -> int:
    if sys.platform != 'darwin':
        print('This script only runs on macOS.')
        return 1
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    if add_share(target):
        print('Please restart Docker Desktop for changes to take effect.')
        return 0
    return 1

if __name__ == '__main__':
    sys.exit(main())
