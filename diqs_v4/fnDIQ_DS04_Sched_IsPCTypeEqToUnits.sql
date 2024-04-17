/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Units % Complete Type Utilized</title>
  <summary>Is this task using a Units % Complete type?</summary>
  <message>Task uses a Units % Complete type (PC_type = Units).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040201</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsPCTypeEqToUnits] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS04_schedule
	WHERE
			upload_id = @upload_ID
		AND ISNULL(PC_type,'') = 'Units'
)