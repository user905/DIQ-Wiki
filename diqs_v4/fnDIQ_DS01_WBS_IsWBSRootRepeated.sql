/*
<documentation>
  <author>Elias Cooper</author>
  <id>7</id>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Root of WBS not unique</title>
  <summary>Is the root of the WBS hierarchy (Level 1) unique?</summary>
  <message>WBS hierarchy contains more than one Level 1 WBS element.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010034</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsWBSRootRepeated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
    SELECT	*
    FROM	DS01_WBS
    WHERE	upload_ID = @upload_id
			AND [Level] = 1
			AND (
				SELECT	COUNT(*)
				FROM	DS01_WBS
				WHERE	upload_ID = @upload_id
						AND [Level] = 1
			) > 1
)