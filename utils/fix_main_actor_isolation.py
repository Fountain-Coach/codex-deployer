#!/usr/bin/env python3
"""Fix main actor isolation in SwiftUI views.

This script removes `nonisolated` from methods inside structs
that conform to `View` when those methods access stored
properties. It preserves formatting as much as possible.
"""

import argparse
import os
import re
from typing import List


def collect_swift_files(paths: List[str]) -> List[str]:
    files = []
    for p in paths:
        if os.path.isdir(p):
            for root, _, filenames in os.walk(p):
                for name in filenames:
                    if name.endswith(".swift"):
                        files.append(os.path.join(root, name))
        elif p.endswith(".swift") and os.path.isfile(p):
            files.append(p)
    return files


def fix_file(path: str) -> bool:
    changed = False
    with open(path, "r") as f:
        lines = f.readlines()

    out_lines = []
    i = 0
    in_view = False
    view_depth = 0
    props: List[str] = []

    while i < len(lines):
        line = lines[i]
        if not in_view:
            m = re.search(r"\bstruct\s+\w+\s*:\s*View\b", line)
            if m:
                in_view = True
                view_depth = line.count("{") - line.count("}")
                props.clear()
                out_lines.append(line)
                i += 1
                continue
            else:
                out_lines.append(line)
                i += 1
                continue
        else:
            current_depth = view_depth
            if current_depth == 1:
                prop_match = re.match(r"\s*(?:public\s+)?(var|let)\s+(\w+)", line)
                if prop_match and not line.strip().startswith("//"):
                    props.append(prop_match.group(2))
                if "nonisolated" in line and "func" in line:
                    func_indent = re.match(r"^\s*", line).group(0)
                    func_depth = line.count("{") - line.count("}")
                    func_lines = []
                    j = i + 1
                    while j < len(lines):
                        func_lines.append(lines[j])
                        func_depth += lines[j].count("{") - lines[j].count("}")
                        if func_depth <= 0:
                            break
                        j += 1
                    body_text = "".join(func_lines)
                    if any(re.search(r"\b" + re.escape(p) + r"\b", body_text) for p in props):
                        comment = func_indent + "// 🛠 Fixed: removed nonisolated to match actor context\n"
                        new_line = re.sub(r"\bnonisolated\s+", "", line)
                        out_lines.append(comment)
                        out_lines.append(new_line)
                        out_lines.extend(func_lines)
                        changed = True
                        i = j + 1
                        view_depth += line.count("{") - line.count("}")
                        view_depth += sum(l.count("{") - l.count("}") for l in func_lines)
                        continue
                    else:
                        out_lines.append(line)
                        out_lines.extend(func_lines)
                        i = j + 1
                        view_depth += line.count("{") - line.count("}")
                        view_depth += sum(l.count("{") - l.count("}") for l in func_lines)
                        continue
            out_lines.append(line)
            view_depth += line.count("{") - line.count("}")
            if view_depth < 0:
                in_view = False
            i += 1

    if changed:
        with open(path, "w") as f:
            f.writelines(out_lines)
    return changed


def main() -> None:
    parser = argparse.ArgumentParser(description="Fix main actor isolation in SwiftUI views")
    parser.add_argument("paths", nargs="+", help="Swift files or directories to process")
    args = parser.parse_args()

    files = collect_swift_files(args.paths)
    for file in files:
        if fix_file(file):
            print(f"Updated {file}")


if __name__ == "__main__":
    main()
