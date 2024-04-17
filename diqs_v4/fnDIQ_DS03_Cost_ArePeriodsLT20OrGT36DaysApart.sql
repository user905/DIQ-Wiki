/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Cost Periods Not One Month Apart</title>
  <summary>Is this period date less than 20 or more than 36 days apart from either the previous or next period?</summary>
  <message>Period_date is not within 20-36 days from previous or next period.</message>
  <grouping>period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030057</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_ArePeriodsLT20OrGT36DaysApart] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with PMBPeriods AS (
		SELECT 
			period_date Period, 
			LAG(period_date,1) OVER (ORDER BY period_date) as PrevPeriod,
			LEAD(period_date,1) OVER (ORDER BY period_date) as NextPeriod
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND period_date < (
			SELECT MAX(ES_Date) 
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND schedule_type = 'BL' AND milestone_level = 175
		)
		GROUP BY period_date
	)
	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND period_date IN (
			SELECT Period
			FROM PMBPeriods
			WHERE 
				DATEDIFF(day,PrevPeriod,Period) NOT BETWEEN 20 AND 36 OR
				DATEDIFF(day,Period,NextPeriod) NOT BETWEEN 20 AND 36
		)
)