"""Rebuilds only the DIQ index and severity pages, with no model and no DIQ page.

Writes `<out>/diqs/index.md`, `<out>/diqs/dsNN/index.md` and `<out>/diqs/{critical,major,minor}.md`
from diq_data.json, in PLASMA's syntax (relative `.md` links, frontmatter). The text before the
first heading of an existing index page is kept when its folder is given with --reuse-from.

    python write_index_markdown.py --reuse-from ../plasma
"""

import argparse
import json
import sys

from generateMarkdown import generate_index_pages, load_diqs


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--data", default="diq_data.json")
    parser.add_argument("--out", default="generated")
    parser.add_argument("--reuse-from", action="append", default=[], metavar="DIR")
    args = parser.parse_args(argv)
    with open(args.data, encoding="utf-8") as f:
        diqs = [diq for _name, _entry, diq in load_diqs(json.load(f))]
    count = generate_index_pages(diqs, args.out, args.reuse_from)
    print(f"Wrote {count} index and severity pages under {args.out}/diqs")
    return 0


if __name__ == "__main__":
    sys.exit(main())
