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
- Lastly, use `generateMarkdown.py` to generate the markdown MDs and `deployToWiki.py` to deploy.

Scrips that might prove useful:

- `metadata_diff.py`: find diffs btw old & new Metadata; also tracks addition and deletion of DIQs
- `metadata_diff_consolidator.py`: Consolidate the above changes by UID into a single file.
- `sql_diff.py`: find diff btw old & new SQL
- `sql_diff_summarizer.py`: ask ChatGPT to summarize SQL diffs.
- `copy_index_files.py`: Copy/paste the index.md files from the prior wiki release's DSxx sub-directories to the new one
- `move_mds_to_new_wiki_dir.py`: Move a list of UID.md files from the old wikijs/DS## subfolders to the new ones; useful for any changed DIQs
- `replace_sql_blocks.py`: replace the SQL blocks in the new DIQ MD files
  with the new SQL code from /diqs
- `write_index_markdown.py`: Write the top-level index file by referencing the contents of error.md, alert.md, and warning.md in /wikijs
- `downloadPublishedWikiFiles.py`: Download all currently published WikiJS DIQ pages to the wikijs_published folder.
- `deletePublishedPagesWithoutHumanNarrative.py`: Delete any of the above published WikiJS DIQ pages that haven't had a human review their narrative.
