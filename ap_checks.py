"""Invoice checks on the synthetic ledger used in the Invoice audit lab.

The ledger (synthetic_invoices.csv) is made up: the vendors are fictional and
no employer or real vendor data is used. The same four checks run in the
browser on the lab page, and this script gives the same answers.

Checks
  1. Exact duplicate     same vendor, same invoice number, same amount
  2. Possible duplicate  same vendor, same amount, different invoice number,
                         invoice dates within --window days of each other
  3. Just under limit    amount is below --limit but within --band percent of it
  4. Paid late           paid more than --grace days after the due date

A flag is a lead for a person to look at, not proof of an error.

Usage
  python3 ap_checks.py
  python3 ap_checks.py --window 5 --limit 10000 --band 5 --grace 0
"""
import argparse
import csv
from collections import defaultdict
from datetime import date
from itertools import combinations


def load(path):
    rows = []
    with open(path, newline="") as f:
        for r in csv.DictReader(f):
            rows.append({
                "id": int(r["id"]),
                "vendor": r["vendor"],
                "inv": r["invoice_no"],
                "date": date.fromisoformat(r["invoice_date"]),
                "due": date.fromisoformat(r["due_date"]),
                "paid": date.fromisoformat(r["paid_date"]),
                "amount": round(float(r["amount"]), 2),
            })
    return rows


def find(rows, window, limit, band, grace):
    findings = []

    # 1. exact duplicates: group by vendor + invoice number + amount
    groups = defaultdict(list)
    for r in rows:
        groups[(r["vendor"], r["inv"], r["amount"])].append(r["id"])
    exact_pairs = set()
    for ids in groups.values():
        if len(ids) > 1:
            findings.append(("exact", ids))
            exact_pairs.update(combinations(sorted(ids), 2))

    # 2. possible duplicates: same vendor and amount, different invoice number,
    #    close invoice dates, and not already reported as an exact duplicate
    for a, b in combinations(rows, 2):
        if (a["vendor"] == b["vendor"] and a["amount"] == b["amount"]
                and a["inv"] != b["inv"]
                and abs((a["date"] - b["date"]).days) <= window
                and tuple(sorted((a["id"], b["id"]))) not in exact_pairs):
            findings.append(("possible", [a["id"], b["id"]]))

    # 3. just under the approval limit
    low = limit * (1 - band / 100)
    for r in rows:
        if low <= r["amount"] < limit:
            findings.append(("limit", [r["id"]]))

    # 4. paid late
    for r in rows:
        if (r["paid"] - r["due"]).days > grace:
            findings.append(("late", [r["id"]]))

    return findings


LABELS = {
    "exact": "Exact duplicate",
    "possible": "Possible duplicate",
    "limit": "Just under limit",
    "late": "Paid late",
}


def main():
    p = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    p.add_argument("--file", default="synthetic_invoices.csv")
    p.add_argument("--window", type=int, default=7)
    p.add_argument("--limit", type=float, default=10000)
    p.add_argument("--band", type=float, default=5)
    p.add_argument("--grace", type=int, default=0)
    a = p.parse_args()

    rows = load(a.file)
    findings = find(rows, a.window, a.limit, a.band, a.grace)
    by_id = {r["id"]: r for r in rows}

    total = round(sum(r["amount"] for r in rows), 2)
    flagged_ids = sorted({i for _, ids in findings for i in ids})
    flagged_value = round(sum(by_id[i]["amount"] for i in flagged_ids), 2)

    print(f"Invoices: {len(rows)}   Total value: {total:,.2f}")
    print(f"Findings: {len(findings)}")
    for kind in LABELS:
        n = sum(1 for k, _ in findings if k == kind)
        print(f"  {LABELS[kind]:<20} {n}")
    share = flagged_value / total * 100
    print(f"Flagged invoices: {len(flagged_ids)}   Flagged value: {flagged_value:,.2f} ({share:.1f}% of value)")
    print()
    for kind, ids in findings:
        for i in ids:
            r = by_id[i]
            print(f"  [{LABELS[kind]}] #{r['id']:>2}  {r['vendor']:<24} {r['inv']:<9} {r['date']}  {r['amount']:>10,.2f}")


if __name__ == "__main__":
    main()
