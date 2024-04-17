/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Cost Period After PMB End</title>
  <summary>Is this period date after PMB end?</summary>
  <message>Period_date &gt; DS04.ES_Date for milestone_level = 175.</message>
  <grouping>period_date</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030095</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsPeriodAfterPMBEnd] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with PMBEndDates as (
		SELECT schedule_type, COALESCE(MAX(ES_Date),MAX(EF_DATE)) MSDate  
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND milestone_level = 175
		GROUP BY schedule_type
	), Flags as (
		SELECT WBS_ID_CA, WBS_ID_WP, period_date, EOC
		FROM CostRollupByEOC_Get(@upload_ID)
		WHERE ((	-- if BCWS > 0, compare period_date to BL schedule
				(BCWSi_dollars > 0 OR BCWSi_FTEs > 0 OR BCWSi_hours > 0) AND
				period_date > (SELECT MSDate from PMBEndDates WHERE schedule_type = 'BL')
		) OR (	-- if BCWP, ACWP, or ETC > 0, compare period_date to FC schedule
				(
					BCWPi_dollars > 0 OR BCWPi_FTEs > 0 OR BCWPi_hours > 0 OR 
					ACWPi_dollars > 0 OR ACWPi_FTEs > 0 OR ACWPi_hours > 0 OR 
					ETCi_dollars > 0 OR ETCi_FTEs > 0 OR ETCi_hours > 0
				) AND
				period_date > (SELECT MSDate from PMBEndDates WHERE schedule_type = 'FC')
		))
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F 	ON C.WBS_ID_CA = F.WBS_ID_CA 
										AND C.WBS_ID_WP = F.WBS_ID_WP
										AND C.EOC = F.EOC
										AND C.period_date = F.period_date
	WHERE
		upload_ID = @upload_ID
)