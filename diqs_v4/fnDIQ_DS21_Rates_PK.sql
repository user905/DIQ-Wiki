/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS21 Rates</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate Rate</title>
  <summary>Is this rate duplicated by resource ID?</summary>
  <message>Count resource_ID &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1210602</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS21_Rates_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS21_rates
	WHERE 
			upload_ID = @upload_ID
		AND resource_ID IN (
			SELECT resource_ID
			FROM DS21_rates
			WHERE upload_ID = @upload_ID
			GROUP BY resource_ID
			HAVING COUNT(*) > 1
		)
)