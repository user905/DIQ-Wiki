/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS19 Sched CAL Std</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate Calendar Name</title>
  <summary>Is this calendar name duplicated in the dataset (by subproject_ID)?</summary>
  <message>Count calendar_name &gt; 1 (by subproject_id).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1190593</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS19_Sched_CAL_Std_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT calendar_name, ISNULL(subproject_ID, '') SubP
		FROM DS19_schedule_calendar_std
		WHERE upload_ID = @upload_ID
		GROUP BY calendar_name, ISNULL(subproject_ID, '')
		HAVING COUNT(*) > 1
	)
	SELECT std.*
	FROM DS19_schedule_calendar_std std INNER JOIN Dupes d ON std.calendar_name = d.calendar_name AND ISNULL(std.subproject_ID,'') = d.SubP
	WHERE upload_ID = @upload_ID
)