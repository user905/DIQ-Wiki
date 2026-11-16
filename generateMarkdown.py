"""Generates the DIQ pages for PLASMA, the PARS wiki.

Writes every page under `<out>/diqs/`, laid out and written as the PLASMA content repo holds them
(see plasma_pages.py). `publishToPlasma.py` then puts them on a branch of the content repo and
opens a pull request.

The explanations under "What causes this error?" and "Why do we check this?" are written by an
AI model. A DIQ whose page already exists keeps the explanations it has (pass the page folder
with --reuse-from), so a regeneration only asks the model about new DIQs, and keeps what people
wrote. Fresh explanations get the `> [!AI]` callout and `ai_review: pending`, and so does a
reused page that still had them.

    python generateMarkdown.py --reuse-from ../plasma          # the content repo checkout
    python generateMarkdown.py --reuse-from wikijs --no-ai     # the old WikiJS pages, no model
"""

from __future__ import annotations

import argparse
import json
import os
import sys

import plasma_pages as pp


def query_gpt(messages):
    # Imported here, so the rest of the generator (and its tests) need neither openai nor a key
    import openai
    from dotenv import load_dotenv

    load_dotenv()
    openai.api_key = os.getenv("OPENAI_API_KEY")
    content = ""
    for chunk in openai.ChatCompletion.create(
        model="gpt-4-0125-preview",
        messages=messages,
        stream=True,
        temperature=0
    ):
        new_content = chunk["choices"][0].get("delta", {}).get("content", "")
        if new_content is not None:
            print(new_content, end='')
            sys.stdout.flush()
            content += new_content
    print()
    return content


def explain_with_ai(entry: dict, diq: pp.Diq, sql: str) -> dict[str, str]:
    """Asks the model for the two explanations of a DIQ that has no page yet."""
    info = {k: v for k, v in entry.items()
            if k not in ("wiki", "author", "param", "returns", "test", "status")}
    info["severity"] = diq.severity
    error_data = {k: v for k, v in info.items() if k != "severity"}

    error_prompt = [
        {
            "role": "system",
            "content": """You are an assistant that is helping define Data Integrity and Quality (DIQ) checks for EVMS construction project management data
            at the US Department of Energy. You will be provided with information describing properties of a test that is being performed on the data,
            and code for the actual check that is being performed. Please reply in complete sentences with an explanation that will be provided as part of a user guide
            to DIQs. Describe briefly what is likely to be causing the error, specifying what fields are causing the issue and what expected values might be.
            You can refer to the DIQ test, but don't explicitly mention the SQL query. Avoid mentioning the upload_ID field or the fact that the test only runs when needed.
            Refer to the tables by their DS number and name rather than the exact table name in SQL. Be concise and clear, writing in a professional tone for a user guide."""
        },
        {
            "role": "user",
            "content": f"DIQ Test information: {error_data} \n\n DIQ Test SQL: {sql}"
        }
    ]

    importance_prompt = [
        {
            "role": "system",
            "content": "You are an assistant that is helping define Data Integrity and Quality (DIQ) checks for EVMS construction project management data at the US Department of Energy. You will be provided with information describing properties of a test that is being performed on the data. Please reply in complete sentences with a brief explanation of why this test is being performed, and the importance of this check. Note a severity of CRITICAL is the worst, meaning this issue must be fixed or the data can't be reviewed, MAJOR is moderate severity implying the issue is likely to cause problems during analysis, while MINOR is less severe, but indicates there might be minor problems or that the data doesn't follow all best practices."},
        {
            "role": "user",
            "content": f"DIQ Test information: {info}"
        }
    ]

    return {
        "What causes this error?": pp.fresh_prose(query_gpt(error_prompt)),
        "Why do we check this?": pp.fresh_prose(query_gpt(importance_prompt)),
    }


def find_existing(reuse_dirs: list[str], content_path: str) -> str | None:
    """The page at `content_path` (e.g. `diqs/ds01/1010002.md`) in one of the folders, as text.
    A folder may be a content repo checkout (holding `diqs/`) or the old `wikijs/` folder (which
    holds `DS01/1010002.md` and `index.md`, in any case)."""
    inside = content_path[len(pp.ROOT) + 1:]
    for folder in reuse_dirs:
        for candidate in (os.path.join(folder, content_path), os.path.join(folder, inside)):
            found = _find_ignoring_case(candidate)
            if found:
                with open(found, encoding="utf-8") as f:
                    return f.read()
    return None


def _find_ignoring_case(path: str) -> str | None:
    if os.path.isfile(path):
        return path
    head, tail = os.path.split(path)
    parent = _find_ignoring_case_dir(head)
    if parent is None:
        return None
    for name in os.listdir(parent):
        if name.lower() == tail.lower() and os.path.isfile(os.path.join(parent, name)):
            return os.path.join(parent, name)
    return None


def _find_ignoring_case_dir(path: str) -> str | None:
    if path == "" or os.path.isdir(path):
        return path or "."
    head, tail = os.path.split(path)
    parent = _find_ignoring_case_dir(head)
    if parent is None:
        return None
    for name in os.listdir(parent):
        if name.lower() == tail.lower() and os.path.isdir(os.path.join(parent, name)):
            return os.path.join(parent, name)
    return None


def write_page(out_dir: str, content_path: str, text: str) -> None:
    target = os.path.join(out_dir, content_path)
    os.makedirs(os.path.dirname(target), exist_ok=True)
    with open(target, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def load_diqs(data: dict) -> list[tuple[str, dict, pp.Diq]]:
    diqs = []
    for name, entry in data.items():
        diq = pp.diq_from_data(name, entry)
        if diq is None:
            if not entry.get("UID") and entry.get("status") not in ("DELETED", "DELETE"):
                print(f"Skipped {name}: it has no UID")
            continue
        diqs.append((name, entry, diq))
    return diqs


def generate_index_pages(diqs: list[pp.Diq], out_dir: str, reuse_dirs: list[str]) -> int:
    """Writes the index and severity pages. The text before the first heading of an existing
    index page (a notice someone added) is kept."""
    preambles = {}
    for path in [pp.root_index_path(), *{pp.ds_index_path(d.ds) for d in diqs}]:
        existing = find_existing(reuse_dirs, path)
        if existing:
            _fields, body = pp.split_frontmatter(existing)
            preambles[path] = pp.split_sections(body)[0]
    pages = pp.index_pages(diqs, preambles)
    for path, text in pages.items():
        write_page(out_dir, path, text)
    return len(pages)


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--data", default="diq_data.json", help="DIQ metadata (default: diq_data.json)")
    parser.add_argument("--sql-dir", default="diqs", help="one .sql file per DIQ function (default: diqs)")
    parser.add_argument("--out", default="generated", help="folder to write <out>/diqs/ into (default: generated)")
    parser.add_argument("--reuse-from", action="append", default=[], metavar="DIR",
                        help="where the pages stand now: a content repo checkout or the old wikijs/ folder (repeatable; the first that has a page wins)")
    parser.add_argument("--no-ai", action="store_true",
                        help="never ask the model; a DIQ with no existing page is skipped")
    parser.add_argument("--max-table", type=int, default=22, help="skip DIQs on tables above DSnn (default: 22)")
    args = parser.parse_args(argv)

    with open(args.data, encoding="utf-8") as f:
        data = json.load(f)
    entries = load_diqs(data)

    counts = {"reused": 0, "ai": 0, "skipped": 0}
    for name, entry, diq in entries:
        if int(diq.table[2:4]) > args.max_table:
            continue
        with open(os.path.join(args.sql_dir, f"{name}.sql"), encoding="utf-8") as f:
            sql = pp.strip_sql_comments(f.read())

        existing = find_existing(args.reuse_from, diq.path)
        reused = pp.read_existing_diq_page(existing) if existing else None
        if reused and all(h in reused.prose for h in pp.PROSE_SECTIONS):
            prose, ai_pending = reused.prose, reused.ai_pending
            counts["reused"] += 1
        elif args.no_ai:
            print(f"Skipped {diq.uid} ({diq.title}): no existing page to reuse, and --no-ai")
            counts["skipped"] += 1
            continue
        else:
            print(f"{diq.table}: {diq.title}")
            prose, ai_pending = explain_with_ai(entry, diq, sql), True
            reused = pp.Reused(preamble=reused.preamble, extra_sections=reused.extra_sections,
                               code_tail=reused.code_tail) if reused else None
            counts["ai"] += 1

        body = pp.render_diq_body(diq, sql, prose, ai_pending=ai_pending, reused=reused)
        write_page(args.out, diq.path, pp.render_diq_page(diq, body, ai_pending=ai_pending))

    indexes = generate_index_pages([d for _n, _e, d in entries], args.out, args.reuse_from)
    print(
        f"DIQ pages: {counts['reused']} reused, {counts['ai']} written by the model, "
        f"{counts['skipped']} skipped. Index and severity pages: {indexes}. "
        f"Written under {os.path.join(args.out, pp.ROOT)}"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
