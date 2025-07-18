"""Analyze Swift build logs and produce a Markdown summary.

See `docs/handbook/code_reference.md` for an overview of this script's role.
"""

import os
import re
from typing import List, Dict

MAX_SEGMENTS = 10

SEGMENT_MARKERS = ["CompileSwift", "Test Case", "error:"]


def segment_log(text: str, max_segments: int = MAX_SEGMENTS) -> List[Dict[str, List[str]]]:
    """Split log output into segments of interest."""
    segments = []
    current = None
    for line in text.splitlines():
        stripped = line.strip()
        if any(marker in line for marker in SEGMENT_MARKERS):
            if current and current["lines"]:
                segments.append(current)
                if len(segments) >= max_segments:
                    break
            current = {"header": stripped, "lines": [line]}
        else:
            if current is None:
                current = {"header": "Preamble", "lines": []}
            current["lines"].append(line)
    if current and current["lines"] and len(segments) < max_segments:
        segments.append(current)
    return segments[:max_segments]


def analyze_segment(segment: Dict[str, List[str]]) -> Dict[str, str]:
    """Classify a log segment and suggest fixes."""
    lines = segment["lines"]
    errors = [l for l in lines if "error:" in l]
    warnings = [l for l in lines if "warning:" in l]

    if not errors and not warnings:
        segment["status"] = "clean"
        segment["diagnosis"] = "No issues detected."
        return segment

    details = []
    suggestions = []
    for msg in errors + warnings:
        # Extract file and line if present
        m = re.search(r"(\S+\.swift):(\d+)", msg)
        if m:
            file_line = f"{os.path.basename(m.group(1))}:{m.group(2)}"
            details.append(f"{file_line} -> {msg.strip()}")
        else:
            details.append(msg.strip())

        lowered = msg.lower()
        if "unresolved identifier" in lowered or "cannot find" in lowered:
            suggestions.append("Define or import the missing symbol.")
        elif "no such module" in lowered:
            suggestions.append("Add the module to dependencies and rebuild.")
        elif "expected" in lowered:
            suggestions.append("Check for syntax errors near the reported line.")
        else:
            suggestions.append("Review the code around the reported line.")

    segment["status"] = "issues"
    segment["diagnosis"] = "\n".join(details)
    segment["fix"] = "\n".join(sorted(set(suggestions)))
    return segment


def generate_report(segments: List[Dict[str, List[str]]], out_path: str = "report.md") -> None:
    """Write a Markdown summary of the analyzed log segments."""
    with open(out_path, "w") as f:
        for idx, seg in enumerate(segments, 1):
            f.write(f"## Segment {idx} - {seg['header']}\n\n")
            f.write("```log\n")
            f.write("\n".join(seg["lines"]))
            f.write("\n```\n")
            if seg.get("status") == "clean":
                f.write("✅ No errors found.\n\n")
            else:
                f.write("❌ Issues found:\n")
                f.write(seg.get("diagnosis", "") + "\n")
                if seg.get("fix"):
                    f.write("**Suggested Fix:** " + seg["fix"] + "\n")
                f.write("\n")


def main() -> None:
    """Entry point for manual analysis of `build.log`."""
    if not os.path.exists("build.log"):
        print("build.log not found")
        return
    with open("build.log", "r") as f:
        log_text = f.read()

    segments = segment_log(log_text)
    analyzed = [analyze_segment(seg) for seg in segments]
    generate_report(analyzed)
    print("Report written to report.md")


if __name__ == "__main__":
    main()
