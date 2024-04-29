/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate WAD</title>
  <summary>Is this WAD a duplicate by WAD ID, WBS ID, WP WBS ID, &amp; revision?</summary>
  <message>Count of WAD_ID, WBS_ID, WBS_ID_WP, &amp; revision combo &gt; 1.</message>
  <grouping>WAD_ID, WBS_ID, WBS_ID_WP, revision</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080441</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT WAD_ID, WBS_ID, ISNULL(WBS_ID_WP,'') WPWBS, ISNULL(revision,'') revision
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID
		GROUP BY WAD_ID, WBS_ID, ISNULL(WBS_ID_WP,''), ISNULL(revision,'')
		HAVING COUNT(*) > 1
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN Dupes D ON W.WBS_ID = D.WBS_ID
									 AND ISNULL(W.WBS_ID_WP,'') = D.WPWBS
									 AND W.revision = D.revision
									 AND W.wad_id = D.wad_id
	WHERE
		upload_ID = @upload_ID
)