/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Resource Missing Rates</title>
  <summary>Are the rates missing for this resource?</summary>
  <message>Resource_ID missing in DS21.resource_ID list.</message>
  <grouping>resource_id</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060299</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsResourceMissingInDS21] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Rates as (
		SELECT resource_ID
		FROM DS21_rates
		WHERE upload_ID = @upload_ID
	)
	SELECT
		*
	FROM
		DS06_schedule_resources
	WHERE
			upload_id = @upload_ID
		AND resource_ID NOT IN (SELECT resource_ID FROM Rates)
		AND (SELECT COUNT(*) FROM Rates) > 0 --run only if there are rates in DS21
)