/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Approved Date Outside Current Period</title>
  <summary>Is the approved date before the last or after the current status date?</summary>
  <message>approved_date &lt; DS00.CPP_Status_Date - 1 &amp; approved_date &gt; DS00.CPP_Status_Date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9110483</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsApprovedDateOutsideOfCurrentPeriod] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with LastPeriod as (
		SELECT period_date
			FROM (
			SELECT period_date, ROW_NUMBER() OVER (ORDER BY period_date DESC) AS row_num
			FROM DS03_cost
			WHERE upload_ID = @upload_ID AND period_date < CPP_status_date
			) subquery
		WHERE row_num = 1
	)
	SELECT
		*
	FROM 
		DS11_variance
	WHERE 
			upload_ID = @upload_ID
		AND (
			approved_date > CPP_status_date OR -- later than curent period
			approved_date < (SELECT TOP 1 period_date from LastPeriod) -- earlier than last
		)
)