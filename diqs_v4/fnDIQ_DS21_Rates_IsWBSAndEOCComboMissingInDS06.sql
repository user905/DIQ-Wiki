/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS21 Rates</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Resource &amp; EOC Combo Missing in Forecast Resources</title>
  <summary>Is this resource EOC missing in the forecast resources?</summary>
  <message>resource_ID &amp; EOC combo not found in DS06.resource_ID &amp; DS06.EOC (where schedule_type = FC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9210602</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS21_Rates_IsWBSAndEOCComboMissingInDS06] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		R.*
	FROM 
		DS21_rates R LEFT OUTER JOIN DS06_schedule_resources Res ON R.resource_ID = Res.resource_ID AND R.EOC = Res.EOC
	WHERE 
			R.upload_ID = @upload_ID
		AND Res.upload_ID = @upload_ID
		AND Res.schedule_type = 'FC'
		AND Res.resource_ID IS NULL
)