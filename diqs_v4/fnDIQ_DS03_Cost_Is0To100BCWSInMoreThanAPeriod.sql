/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>0-100 Budget Spread Improperly</title>
  <summary>Is the budget for this 0-100 work spread across more than a one period?</summary>
  <message>0-100 work found with BCWSi &gt; 0 (Dollar, Hours, or FTEs) in more than one period.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030074</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_Is0To100BCWSInMoreThanAPeriod] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with SSpread as (
		SELECT 
			WBS_ID_WP, 
			period_date [Period], 
			LEAD(period_date,1) OVER (PARTITION BY WBS_ID_WP, EOC ORDER BY period_date) AS NextPeriod,	
			BCWSi_dollars s_dollars, 
			BCWSi_hours s_hours, 
			BCWSi_FTEs s_ftes,
			ISNULL(LEAD(BCWSi_dollars,1) OVER (PARTITION BY WBS_ID_WP, EOC ORDER by period_date),0) AS NextS_dollars,
			ISNULL(LEAD(BCWSi_hours,1) OVER (PARTITION BY WBS_ID_WP, EOC ORDER by period_date),0) AS NextS_hours,
			ISNULL(LEAD(BCWSi_ftes,1) OVER (PARTITION BY WBS_ID_WP, EOC ORDER by period_date),0) AS NextS_ftes,
			EOC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EVT = 'F'
	), 
	Flags as (
		SELECT WBS_ID_WP, [period], NextPeriod
		FROM SSpread
		WHERE 
			(s_dollars > 0 AND NextS_dollars > 0) OR
			(s_hours > 0 AND NextS_hours > 0) OR
			(s_ftes > 0 AND NextS_ftes > 0)
		GROUP BY WBS_ID_WP, [Period], NextPeriod
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F 	ON C.WBS_ID_WP = F.WBS_ID_WP 
										AND (C.period_date = F.[Period] OR C.period_date = F.NextPeriod)
	WHERE 
			upload_ID = @upload_ID
		AND C.EVT = 'F'
		AND TRIM(ISNULL(C.WBS_ID_WP,'')) <> ''
)