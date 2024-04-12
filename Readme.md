Loose notes for now because Elias is dumb and forgets things.

Order in which to run scripts:

1. sync_diqs.py
2. metadata_diff.py
3. metadata_change_consolidator.py
4. sql_diff.py
5. sql_diff_summarizer.py

- Rename /diqs to /diqs\_[version #]
- Rename diq*data.json to diq_data*[version #].json
- Run sync_diqs.py to pull current list from DB
- Log diff btw list in diq_data.json & dig_data_v4.json
  - Link by UID and compare metadata & title (be sure to check against added metadata fields)
  - Keep track of any DIQs that replaced another DIQ but that maintained the UID
  - This gets one list of new DIQs and another with changed metadata
- Compare SQL in /diqs to what’s in /diqs_v4
  - Use the UID link to assist with this
- Write all results to a JSON file
- Review all changes in the JSON file
- Generate markdown for all new files (Use AI if there are many)
- Pull down MD files for any DIQs that changed, replace the SQL, update metadata, and add a revision history entry (if the DIQ is new, add a created date), then write to /wikijs
- Do a final review.
- Get sign-off from the feds.
- Modify deployToWiki.py
  - to ensure it’s pointing in the right places
- Run deployToWiki.py (Get with Craig & 🤲)
- Pull all MD files & find / replace the severity levels
- Recreate table of contents markdown pages with new severity levels (possibly automated, depending on number of changes)
