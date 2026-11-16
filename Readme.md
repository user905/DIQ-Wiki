Updates to the Wiki haven't been 100% systematized, so the below is a loose guide on what scripts do.
Remember, ChatGPT is your friend and good at python, which is excellent for this sort of thing.

Generally, steps are:

- Rename /diqs to /diqs\_[version #]
- Rename `diq_data.json` to `diq_data_v[version #].json`
- Run `sync_diqs.py` to pull current list of SQL scripts from DB
- Rename /wikijs to /wikijs_v[prior version #]
- Create /wikijs
- Run `sql_cleanup.py` to remove all comments and newlines from the SQL scripts in both the new & old SQL script folders, excluding the XML Metadata. (This isn't strictly necessary, but it makes things easier)
- And then compare...
- Lastly, generate the pages and publish them to PLASMA as a pull request (below).

## Publishing to PLASMA

The DIQ pages live in PLASMA, the PARS wiki, under `diqs/` in its content repo
(PARS-DOE/plasma): `diqs/index.md`, `diqs/ds01/index.md`, `diqs/ds01/1010002.md`, and one
page per severity (`diqs/critical.md`, `diqs/major.md`, `diqs/minor.md`). Every generated page
carries `generated_by: diq-wiki` in its frontmatter.

1. Check out the content repo next to this one and bring it up to date (`git -C ../plasma pull`).
2. Generate the pages into `generated/diqs/` (git-ignored):

   ```
   python generateMarkdown.py --reuse-from ../plasma
   ```

   A DIQ whose page already exists keeps its "What causes this error?" and "Why do we check
   this?" text, so edits people made there survive, and so do sections they added and any notice
   above the first heading. Only a DIQ with no page is sent to the model (it needs
   `OPENAI_API_KEY` in `.env`). Its text gets the `> [!AI]` callout and `ai_review: pending`,
   which people remove once they have reviewed it. `--no-ai` skips such DIQs instead.
   `write_index_markdown.py` rebuilds only the index and severity pages.
3. See what would change, without committing anything:

   ```
   python publishToPlasma.py --content-repo ../plasma --dry-run
   git -C ../plasma diff
   git -C ../plasma checkout -- diqs && git -C ../plasma clean -fd diqs
   ```

4. Publish. This makes a new branch from `main` in the content repo, commits the pages, pushes the
   branch and opens a pull request through the GitHub API. It never commits to `main`.

   ```
   GITHUB_TOKEN=... python publishToPlasma.py --content-repo ../plasma
   ```

   The token needs to push branches and open pull requests on PARS-DOE/plasma.

The pull request's diff is exactly what the regeneration changes, including any hand edit to a
generated section that it would undo. Read it before merging. The description lists pages that
get `ai_review: pending` back (a person's review undone) and pages marked `generated_by: diq-wiki`
whose DIQ is gone. Those are left in place; delete them in the pull request if wanted, and add
their entries to `.plasma/redirects.yml`, as the content repo's `CLAUDE.md` says.

Fields the generator does not own (`created`, `author`, ...) are kept, and `modified` moves only on
a page that changed.

The pages follow PLASMA's conventions: relative `.md` links, GitHub-style callouts
(`> [!NOTE]`, `> [!WARNING]`, ...) in place of WikiJS's `{.is-info}` markers, and frontmatter with
`title`, `description` (the DIQ's summary), `tags` (`severity: critical` and the table, `ds01`),
`status` and `generated_by`. The old WikiJS severity names are gone: ERROR is CRITICAL, WARNING is
MAJOR and ALERT is MINOR.

## Retired after cutover

`deployToWiki.py` published to the WikiJS wiki. It stays only until WikiJS is switched off, and
must not be used once PLASMA has taken over. The same goes for `downloadPublishedWikiFiles.py`,
`downloadAllWikiFiles.py` and `deletePublishedPagesWithoutHumanNarrative.py`, which talk to WikiJS.

## Tests

```
pip install pytest pyyaml
python -m pytest tests
```

They need no network, database or keys.

Scrips that might prove useful:

- `metadata_diff.py`: find diffs btw old & new Metadata; also tracks addition and deletion of DIQs
- `metadata_diff_consolidator.py`: Consolidate the above changes by UID into a single file.
- `sql_diff.py`: find diff btw old & new SQL
- `sql_diff_summarizer.py`: ask ChatGPT to summarize SQL diffs.
- `copy_index_files.py`: Copy/paste the index.md files from the prior wiki release's DSxx sub-directories to the new one
- `move_mds_to_new_wiki_dir.py`: Move a list of UID.md files from the old wikijs/DS## subfolders to the new ones; useful for any changed DIQs
- `replace_sql_blocks.py`: replace the SQL blocks in the new DIQ MD files
  with the new SQL code from /diqs
- `write_index_markdown.py`: Rebuild only the index and severity pages, from `diq_data.json`
- `downloadPublishedWikiFiles.py`: Download published versions of the .md files found in wikijs
- `downloadAllWikiFiles.py`: Download all published MD files
- `deletePublishedPagesWithoutHumanNarrative.py`: Delete any of the above published WikiJS DIQ pages that haven't had a human review their narrative.
- `generate_changelog.py`: Generate a changelog. Parts of this may be useful.
