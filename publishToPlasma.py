"""Publishes the generated DIQ pages to PLASMA, the PARS wiki, as a pull request.

Copies every page under `<generated>/diqs/` into a checkout of the content repo (PARS-DOE/plasma),
on a new branch made from `main`, commits, pushes the branch and opens a pull request. It never
commits to `main`. The pull request's diff is exactly what the regeneration changes, so a reviewer
sees any hand edit it would undo before it is merged.

Each page keeps the frontmatter fields the generator does not own (`created`, `author`, ...).
`modified` moves only on a page whose content changed, and a page that comes out the same is not
touched. Pages under `diqs/` that carry `generated_by: diq-wiki` but were not generated (a DIQ
that was deleted) are listed, never removed: delete them in the pull request if that is wanted,
and add their redirect entries.

    python publishToPlasma.py --content-repo ../plasma --dry-run
    GITHUB_TOKEN=... python publishToPlasma.py --content-repo ../plasma

--dry-run writes the pages into the checkout as it stands and prints counts. It makes no branch,
commit, push or pull request, so look at `git -C <checkout> diff`, then `git checkout -- diqs`.
"""

from __future__ import annotations

import argparse
import datetime
import os
import subprocess
import sys

import plasma_pages as pp


def collect_generated(generated_dir: str) -> dict[str, str]:
    """{content path: text} for every page under `<generated_dir>/diqs/`."""
    root = os.path.join(generated_dir, pp.ROOT)
    pages = {}
    for folder, _dirs, files in os.walk(root):
        for name in files:
            if not name.endswith(".md"):
                continue
            full = os.path.join(folder, name)
            rel = os.path.relpath(full, generated_dir).replace(os.sep, "/")
            with open(full, encoding="utf-8") as f:
                pages[pp.clean_path(rel)] = f.read()
    return pages


def check_paths(paths) -> list[str]:
    problems = [f"{p}: {why}" for p in paths if (why := pp.path_problem(p))]
    problems += [f"{p}: a page is x.md or x/index.md, never both" for p in pp.page_clashes(paths)]
    return problems


def existing_generated_pages(content_repo: str) -> set[str]:
    """Pages under `diqs/` in the checkout that carry `generated_by: diq-wiki`."""
    found = set()
    for folder, _dirs, files in os.walk(os.path.join(content_repo, pp.ROOT)):
        for name in files:
            if not name.endswith(".md"):
                continue
            full = os.path.join(folder, name)
            with open(full, encoding="utf-8") as f:
                fields, _body = pp.split_frontmatter(f.read())
            if fields.get("generated_by", "").strip() == f"generated_by: {pp.GENERATED_BY}":
                found.add(os.path.relpath(full, content_repo).replace(os.sep, "/"))
    return found


def apply_pages(content_repo: str, pages: dict[str, str], now: str) -> dict[str, list[str]]:
    """Writes each page into the checkout, merged with what is there. Returns the paths by what
    happened to them."""
    result = {"new": [], "changed": [], "unchanged": [], "ai_review_restored": [], "not_generated": []}
    for path in sorted(pages):
        target = os.path.join(content_repo, path)
        existing = None
        if os.path.isfile(target):
            with open(target, encoding="utf-8") as f:
                existing = f.read()
        merge = pp.merge_with_existing(pages[path], existing, now)
        result[merge.state].append(path)
        if merge.ai_review_restored:
            result["ai_review_restored"].append(path)
        if existing is not None and merge.state == "changed":
            fields, _body = pp.split_frontmatter(existing)
            if "generated_by" not in fields:
                result["not_generated"].append(path)
        if merge.text is not None:
            os.makedirs(os.path.dirname(target), exist_ok=True)
            with open(target, "w", encoding="utf-8", newline="\n") as f:
                f.write(merge.text)
    return result


def summary(result: dict[str, list[str]], stale: list[str]) -> str:
    lines = [
        f"- {len(result['new'])} new pages",
        f"- {len(result['changed'])} changed pages",
        f"- {len(result['unchanged'])} unchanged pages",
    ]
    if result["ai_review_restored"]:
        lines.append(
            f"- {len(result['ai_review_restored'])} pages get `ai_review: pending` back, which "
            "undoes a person's review. Check them before merging:"
        )
        lines += [f"  - `{p}`" for p in result["ai_review_restored"]]
    if result["not_generated"]:
        lines.append(f"- {len(result['not_generated'])} changed pages were not marked "
                     f"`generated_by: {pp.GENERATED_BY}` before:")
        lines += [f"  - `{p}`" for p in result["not_generated"]]
    if stale:
        lines.append(f"- {len(stale)} pages are marked `generated_by: {pp.GENERATED_BY}` but were "
                     "not generated (their DIQ is gone). They are left as they are:")
        lines += [f"  - `{p}`" for p in stale]
    return "\n".join(lines)


def git(content_repo: str, *args: str) -> str:
    return subprocess.run(["git", "-C", content_repo, *args], check=True,
                          capture_output=True, text=True).stdout


def open_pull_request(repo: str, token: str, branch: str, base: str, title: str, body: str) -> str:
    import requests  # only a real run needs it

    response = requests.post(
        f"https://api.github.com/repos/{repo}/pulls",
        headers={"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json",
                 "X-GitHub-Api-Version": "2022-11-28"},
        json={"title": title, "head": branch, "base": base, "body": body},
        timeout=30,
    )
    if response.status_code != 201:
        # The answer's message only; the token is never printed
        message = response.json().get("message", "") if response.content else ""
        raise SystemExit(f"GitHub refused the pull request ({response.status_code}): {message}")
    return response.json()["html_url"]


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--content-repo", required=True, help="a checkout of PARS-DOE/plasma")
    parser.add_argument("--generated", default="generated",
                        help="the folder generateMarkdown.py wrote (default: generated)")
    parser.add_argument("--branch", help="the branch to make (default: diq-wiki/regenerate-<time>)")
    parser.add_argument("--base", default="main", help="the branch to start from and merge into")
    parser.add_argument("--repo", default="PARS-DOE/plasma", help="owner/name on GitHub")
    parser.add_argument("--dry-run", action="store_true",
                        help="only write the pages into the checkout and print counts")
    args = parser.parse_args(argv)

    now_time = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0)
    now = now_time.strftime("%Y-%m-%dT%H:%M:%SZ")
    branch = args.branch or f"diq-wiki/regenerate-{now_time.strftime('%Y%m%d-%H%M%S')}"

    pages = collect_generated(args.generated)
    if not pages:
        print(f"No pages under {os.path.join(args.generated, pp.ROOT)}. Run generateMarkdown.py first.")
        return 1
    problems = check_paths(pages)
    if problems:
        print("These paths can't go into the content repo:\n" + "\n".join(problems))
        return 1

    token = None
    if not args.dry_run:
        token = os.environ.get("GITHUB_TOKEN")
        if not token:
            print("GITHUB_TOKEN is not set.")
            return 1
        if branch in (args.base, "main"):
            print(f"Refusing to publish onto {branch}: use a new branch.")
            return 1
        if git(args.content_repo, "status", "--porcelain"):
            print("The content repo checkout has uncommitted changes. Commit or remove them first.")
            return 1
        git(args.content_repo, "fetch", "origin", args.base)
        git(args.content_repo, "checkout", "-b", branch, f"origin/{args.base}")

    stale = sorted(existing_generated_pages(args.content_repo) - set(pages))
    result = apply_pages(args.content_repo, pages, now)
    report = summary(result, stale)
    print(report)

    if args.dry_run:
        print(f"Dry run: pages written into {args.content_repo}, nothing committed.")
        return 0

    git(args.content_repo, "add", "--", pp.ROOT)
    if not git(args.content_repo, "diff", "--cached", "--name-only"):
        print("Nothing changed, so there is no pull request to open.")
        git(args.content_repo, "checkout", args.base)
        git(args.content_repo, "branch", "-D", branch)
        return 0
    title = "Regenerate the DIQ pages"
    git(args.content_repo, "commit", "-m", title, "-m",
        f"Generated by diq-wiki's generateMarkdown.py and publishToPlasma.py.\n\n{report}")
    git(args.content_repo, "push", "-u", "origin", branch)
    body = (
        "The DIQ pages as diq-wiki generates them now. The diff is everything this regeneration "
        "changes, including any hand edit it would undo, so read it before merging.\n\n" + report
    )
    url = open_pull_request(args.repo, token, branch, args.base, title, body)
    print(f"Pull request: {url}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
