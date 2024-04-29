/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Resources with Negative Remaining Budget</title>
  <summary>Does this resource have negative remaining budget (dollars and/or units)?</summary>
  <message>Resource found with negative remaining budget (remaining_dollars &lt; 0 and/or remaining_units &lt; 0).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060244</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsRemBudgetLTZero] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS06_schedule_resources
	WHERE
			upload_id = @upload_ID
		AND (remaining_dollars < 0 OR remaining_units < 0)
)