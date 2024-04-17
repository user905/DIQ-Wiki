/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Calendar Missing In Standard Calendar List</title>
  <summary>Is this calendar name missing in the standard calendar list?</summary>
  <message>calendar_name not found in DS19.calendar_name list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060293</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsCalendarMissingInDS19] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CALs as (
		SELECT calendar_name CName, ISNULL(subproject_ID,'') SubP
		FROM DS19_schedule_calendar_std 
		WHERE upload_ID = @upload_ID
	)
	SELECT R.*
	FROM DS06_schedule_resources R LEFT OUTER JOIN CALs C ON R.calendar_name = C.CName AND ISNULL(R.subproject_ID,'') = C.SubP
	WHERE 	upload_id = @upload_ID 
		AND C.CName IS NULL
		AND EXISTS (SELECT 1 FROM CALs) --run only if there are any calendars in DS19
)