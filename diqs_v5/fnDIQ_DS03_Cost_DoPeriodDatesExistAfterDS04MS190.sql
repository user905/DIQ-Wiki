/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Cost Periods Found After CD-4 Approved</title>
  <summary>Are there period dates after CD-4 approved?</summary>
  <message>Period Dates found after CD-4 approved (DS04.milestone_level = 190).</message>
  <grouping>period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030073</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_DoPeriodDatesExistAfterDS04MS190] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS03_Cost C
	WHERE 
			upload_ID = @upload_ID
		AND period_date > (
			SELECT COALESCE(ES_Date,EF_Date) 
			FROM DS04_schedule 
			WHERE upload_ID = @upload_ID AND milestone_level = 190 AND schedule_type = 'BL'
		)
)