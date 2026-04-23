#!/usr/bin/env python3
"""
Simple grader for d365-tfvc-changelog-generator eval runs.

Usage:
  python grader.py --eval-id 1 --run-dir C:\path\to\workspace\iteration-1\eval-0\with_skill\outputs

This script reads evals/evals.json (next to this script), loads the expectations for the requested eval,
checks files (cards.md and changelog.md) for obvious patterns, and writes <run-dir>/grading.json
with fields `expectations` (text/passed/evidence) and a simple summary.

The checks are intentionally simple and conservative; adjust heuristics for your data.
"""
import argparse
import json
import os
import re
from typing import List, Dict


def load_evals(evals_path: str) -> Dict:
    with open(evals_path, "r", encoding="utf-8") as f:
        return json.load(f)


def read_text(path: str) -> str:
    if not os.path.exists(path):
        return ""
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        return f.read()


def find_ids_in_text(text: str) -> List[str]:
    # Heuristic: 4-6 digit numeric IDs
    return sorted(set(re.findall(r"\b(\d{4,6})\b", text)))


def check_expectation(expectation: str, cards_text: str, changelog_text: str) -> (bool, str):
    exp = expectation.lower()
    # Check existence of files
    if "cards.md is created" in exp:
        ok = bool(cards_text)
        evidence = "cards.md found" if ok else "cards.md missing"
        return ok, evidence

    # Heading presence like "## 11490"
    m = re.search(r"##\s*(\d{4,6})", expectation)
    if m:
        wid = m.group(1)
        ok_cards = f"## {wid}" in cards_text
        ok_changelog = f"{wid}" in changelog_text
        evidence = []
        if ok_cards:
            evidence.append(f"Found '## {wid}' in cards.md")
        else:
            evidence.append(f"Missing '## {wid}' in cards.md")
        if "changelog.md" in expectation.lower():
            if ok_changelog:
                evidence.append(f"Found '{wid}' in changelog.md")
            else:
                evidence.append(f"Missing '{wid}' in changelog.md")
        return ok_cards or ok_changelog, "; ".join(evidence)

    # Multi-id expectation: look for many '## NNNN' tokens in the expectation
    ids = re.findall(r"##\s*(\d{4,6})|\b(\d{4,6})\b", expectation)
    flat_ids = [x for pair in ids for x in pair if x]
    if len(flat_ids) >= 2:
        results = []
        passed_all = True
        for wid in set(flat_ids):
            present = (f"## {wid}" in cards_text) or (wid in changelog_text)
            results.append((wid, present))
            if not present:
                passed_all = False
        evidence = ", ".join([f"{w}: {'present' if p else 'missing'}" for w, p in results])
        return passed_all, evidence

    # Deduplication checks - look for "single '## 10086'" phrasing
    m = re.search(r"single '?## '?\s*(\d{4,6})", expectation)
    if m:
        wid = m.group(1)
        count_cards = cards_text.count(f"## {wid}")
        count_changelog = changelog_text.count(wid)
        ok = (count_cards == 1) and (count_changelog == 1)
        evidence = f"cards.md: {count_cards}, changelog.md: {count_changelog}"
        return ok, evidence

    # Generic: check that each ID mentioned in the prompt appears once in both files
    if "each listed work item appears" in exp:
        # We'll try to extract IDs from the prompt via the IDs present in the expectation string
        # Fallback: no check
        # (This expectation relies on grader being invoked with --eval-id and reading the prompt separately.)
        # Signal that this needs manual review if we can't verify
        return False, "Automated check not implemented for this expectation"

    # Default: conservative - mark as not-checked
    return False, "No automated check implemented for this expectation"


def grade(eval_entry: Dict, run_dir: str) -> Dict:
    cards_path = os.path.join(run_dir, "cards.md")
    changelog_path = os.path.join(run_dir, "changelog.md")
    cards_text = read_text(cards_path)
    changelog_text = read_text(changelog_path)

    expectations = eval_entry.get("expectations", [])
    graded = []
    passed = 0

    for exp in expectations:
        ok, evidence = check_expectation(exp, cards_text, changelog_text)
        graded.append({"text": exp, "passed": bool(ok), "evidence": evidence})
        if ok:
            passed += 1

    total = len(expectations)
    summary = {"passed": passed, "failed": total - passed, "total": total, "pass_rate": (passed / total if total else 0.0)}

    grading = {"expectations": graded, "summary": summary}
    return grading


def main():
    parser = argparse.ArgumentParser(description="Grade an eval run for d365-tfvc-changelog-generator")
    parser.add_argument("--eval-id", type=int, required=True, help="Eval ID from evals/evals.json")
    parser.add_argument("--run-dir", required=True, help="Path to the run outputs directory (contains cards.md and changelog.md)")
    parser.add_argument("--evals-file", default=os.path.join(os.path.dirname(__file__), "evals.json"), help="Path to evals JSON")
    args = parser.parse_args()

    evals = load_evals(args.evals_file)
    evals_list = evals.get("evals", [])
    entry = next((e for e in evals_list if e.get("id") == args.eval_id), None)
    if not entry:
        print(f"Eval id {args.eval_id} not found in {args.evals_file}")
        return 2

    grading = grade(entry, args.run_dir)

    out_path = os.path.join(args.run_dir, "grading.json")
    os.makedirs(args.run_dir, exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(grading, f, indent=2, ensure_ascii=False)

    print(f"Wrote grading.json -> {out_path}")


if __name__ == "__main__":
    main()
