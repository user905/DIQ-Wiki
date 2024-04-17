/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM Name Inconsistent</title>
  <summary>Is the PM name inconsistent for SLPPs and high-level WBSs?</summary>
  <message>The CAM name for SLPPs and high-level WBSs is not consistent. (Note: At high levels, the value in the CAM field should represent the PM.)</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010028</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsPMNameInconsistent] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with ToTest as (
		SELECT *
		FROM AncestryTree_Get(@upload_ID)
		WHERE [type] IN ('SLPP', 'WBS')
	), 
	Flags as (
		SELECT 
			WBS_ID
		FROM
			DS01_WBS
		WHERE
			upload_ID = @upload_ID
		AND WBS_ID IN (SELECT WBS_ID FROM ToTest WHERE Ancestor_Level = 1 AND CAM <> Ancestor_CAM)
		AND WBS_ID NOT IN (SELECT WBS_ID FROM ToTest WHERE Ancestor_Type = 'CA' AND [type] = 'WBS')
	)
	SELECT 
		*
	FROM
		DS01_WBS
	WHERE
			upload_ID = @upload_ID
		AND (
				WBS_ID IN (SELECT WBS_ID FROM Flags)
			OR (Level = 1 AND (SELECT COUNT(*) FROM Flags) > 0)
		)
)