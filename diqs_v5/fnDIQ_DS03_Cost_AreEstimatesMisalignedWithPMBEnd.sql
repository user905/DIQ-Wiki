/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Cost Estimates After PMB End</title>
  <summary>Is there estimated work after the PMB end?</summary>
  <message>Period_date of last recorded ETCi (Dollars, Hours, or FTEs) &gt; DS04.ES_Date for milestone_level = 175.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030056</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_AreEstimatesMisalignedWithPMBEnd] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND (ETCi_dollars > 0 OR ETCi_FTEs > 0 OR ETCi_hours > 0)
		AND period_date > (
			SELECT COALESCE(MAX(ES_date), MAX(EF_date))
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND milestone_level = 175 AND schedule_type = 'FC'
		)
)