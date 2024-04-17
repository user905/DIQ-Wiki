/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WBS Missing in Cost</title>
  <summary>Is this WBS ID missing in Cost?</summary>
  <message>WBS_ID is not in cost (DS03.WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040223</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsWBSMissingInDS03] (
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
		AND TRIM(ISNULL(subtype,'')) = ''
		AND WBS_ID NOT IN (SELECT WBS_ID_WP FROM DS03_cost WHERE upload_ID = @upload_ID)
)