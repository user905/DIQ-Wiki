/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Overhead Missing From Project</title>
  <summary>Is Overhead missing from this project?</summary>
  <message>No rows found in DS03 where BCWSi &gt; 0 (Dollars, Hours, or FTEs) and EOC = Overhead.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010024</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsOverheadBCWSMissingFromProject] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
    SELECT	*
    FROM	DS01_WBS
    WHERE	upload_ID = @upload_id
			AND LEVEL = 1
			AND NOT EXISTS (
				SELECT 1
				FROM DS03_cost
				WHERE upload_ID = @upload_id
					AND EOC = 'OVERHEAD'
					AND (BCWSi_dollars > 0 OR BCWSi_FTEs > 0 OR BCWSi_hours > 0)
			)
)