/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Root of OBS Not Unique</title>
  <summary>Is the root of the OBS hierarchy (Level 1) unique?</summary>
  <message>OBS hierarchy contains more than one Level 1 OBS element.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1020047</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_IsOBSRootRepeated] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
    SELECT	*
    FROM	DS02_OBS
    WHERE	upload_ID = @upload_id
			AND [Level] = 1
			AND (
					SELECT	COUNT(*)
					FROM	DS02_OBS
					WHERE	upload_ID = @upload_id
							AND [Level] = 1
				) > 1
)