/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS12 Variance CAL</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Original Due Date After Forecast Due Date</title>
  <summary>Is the original due date for this corrective action after the forecast due date?</summary>
  <message>original_due_date &gt; forecast_due_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1120499</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS12_VAR_CAL_IsOrigDateGtForecastDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM 
		DS12_variance_CAL
	WHERE 
			upload_ID = @upload_ID
		AND original_due_date > forecast_due_date
)