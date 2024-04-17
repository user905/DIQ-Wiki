/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Subproject ID Missing in Schedule</title>
  <summary>Is the subproject ID missing in the schedule?</summary>
  <message>Subproject ID missing in DS04 Schedule</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010029</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsSubprojectIDMissingInDS04] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS01_WBS W
	WHERE
			upload_ID = @upload_ID
		AND type in ('WP','PP','SLPP')
		AND TRIM(ISNULL(subproject_ID,'')) <> ''
		AND subproject_ID NOT IN (SELECT TRIM(ISNULL(subproject_ID,'')) FROM DS04_Schedule WHERE upload_ID = @upload_ID)
)