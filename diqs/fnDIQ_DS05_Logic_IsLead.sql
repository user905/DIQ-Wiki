/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Lead</title>
  <summary>Is the lag for this task less than zero, i.e. a lead?</summary>
  <message>Lag_days &lt; 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1050232</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsLead] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS05_schedule_logic
	WHERE
			upload_id = @upload_ID
		AND lag_days < 0
)