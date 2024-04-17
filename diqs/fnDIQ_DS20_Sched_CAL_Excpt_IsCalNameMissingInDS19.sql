/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS20 Sched CAL Exception</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Calendar Name Missing In Standard Calendar List</title>
  <summary>Is this calendar missing in the standard list of calendars?</summary>
  <message>calendar_name not in DS19.calendar_name list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9200596</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS20_Sched_CAL_Excpt_IsCalNameMissingInDS19] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
SELECT Exc.*
FROM DS20_schedule_calendar_exception Exc LEFT OUTER JOIN DS19_schedule_calendar_std Std ON Exc.calendar_name = Std.calendar_name 
																						AND ISNULL(Exc.subproject_ID,'') = ISNULL(Std.subproject_ID,'')
WHERE 
		Exc.upload_ID = @upload_ID
	AND Std.upload_ID = @upload_ID
	AND Std.calendar_name IS NULL --return only missed joins
)