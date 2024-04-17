/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>BL Task With Negative Free Float</title>
  <summary>Does this BL task have negative free float?</summary>
  <message>BL Task with float_free_days &lt; 0.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040117</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_DoesBLTaskHaveNegativeFreeFloat] (
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
		AND float_free_days < 0 
		AND schedule_type = 'BL'
)