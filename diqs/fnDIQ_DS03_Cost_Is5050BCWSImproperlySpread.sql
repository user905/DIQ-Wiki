/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>50-50 Budget Spread Improperly</title>
  <summary>Is the budget for this 50-50 work spread improperly? (Must be across two consecutive periods and with the same value.)</summary>
  <message>50-50 work (EVT = E) where BCWSi (Dollar, Hours, or FTEs) was found in either one period only or more than two, non-consecutive periods more than 45 days apart, or spread unevenly.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030075</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_Is5050BCWSImproperlySpread] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with SSpread as (
		SELECT 
			WBS_ID_WP, 
			LAG(period_date,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER BY period_date) AS PrevPeriod,
			period_date [Period], 
			LEAD(period_date,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER BY period_date) AS NextPeriod,		
			BCWSi_dollars s_dollars, 
			BCWSi_hours s_hours, 
			BCWSi_FTEs s_ftes,
			ISNULL(LEAD(BCWSi_dollars,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS NextS_dollars,
			ISNULL(LAG(BCWPi_dollars,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS PrevS_dollars,
			ISNULL(LEAD(BCWSi_hours,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS NextS_hours,
			ISNULL(LAG(BCWPi_hours,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS PrevS_hours,
			ISNULL(LEAD(BCWSi_ftes,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS NextS_ftes,
			ISNULL(LAG(BCWPi_ftes,1) OVER (PARTITION BY WBS_ID_WP, EOC, ISNULL(is_indirect,'') ORDER by period_date),0) AS PrevS_ftes,
			EOC,
			ISNULL(is_indirect,'') IsInd
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EVT = 'E'
	), 
	Flags as (
		SELECT WBS_ID_WP, [period], EOC, IsInd
		FROM SSpread
		WHERE 
			(ABS(s_dollars) > 100 OR ABS(s_hours) > 1 OR s_ftes > 0) --Get only rows where |BCWSi| > 100 (threshold of $100/1hr)
			AND ((
					(ABS(PrevS_dollars) > 100 AND ABS(NextS_dollars) > 100) OR -- Are the prev & next $ amounts both > $100? (Both provided)
					(ABS(PrevS_dollars) < 100 AND ABS(NextS_dollars) < 100) -- Are the prev & next $ amounts both < $100? (Both missing)
				) OR (
					(ABS(PrevS_hours) > 1 AND ABS(s_hours) > 1) OR -- Are the prev & next hours both > 1? (Both provided)
					(ABS(PrevS_hours) < 1 AND ABS(s_hours) < 1) -- Are the prev & next hours both < 1? (Both missing)
				) 
				OR (
					(PrevS_ftes = 0 AND NextS_ftes = 0) OR --Are prev/next FTEs both = 0?
					(PrevS_ftes > 0 AND NextS_ftes > 0) --Are prev/next FTEs both > 0?
				) 
				OR (
					DATEDIFF(day, PrevPeriod, [period]) >= 45 OR DATEDIFF(day, [period], NextPeriod) >= 45 --Are the prev/next periods > 45 days from the current?
				) OR (
					ABS(s_dollars - PrevS_dollars) > 100 OR ABS(s_dollars - NextS_dollars) > 100 OR --Is there more than a $100 delta between current period and prev/next?
					ABS(s_hours - PrevS_hours) > 1 OR ABS(s_hours - NextS_hours) > 1 --Is there more than a 1 hour delta between current period and prev/next?
				)
			)
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F 	ON C.WBS_ID_WP = F.WBS_ID_WP
										AND C.period_date = F.period
										AND C.EOC = F.EOC
										AND ISNULL(C.is_indirect,'') = F.IsInd
	WHERE 
			upload_ID = @upload_ID
		AND EVT = 'E'
		AND TRIM(ISNULL(C.WBS_ID_WP,'')) <> ''
)