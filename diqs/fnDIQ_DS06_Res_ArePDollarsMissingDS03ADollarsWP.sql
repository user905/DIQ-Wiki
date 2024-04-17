/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Resource Performance without Cost Actuals (WP)</title>
  <summary>Has this resource recorded performance even though actuals are not recorded in cost (by EOC, at the WP level)?</summary>
  <message>Resource performance (actual_dollars) &gt; 0 even though DS03.ACWPc = 0 (SUM of ACWSi_dollars) by EOC (WP level).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060305</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsWP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Cost as (
		SELECT WBS_ID_CA CA, TRIM(ISNULL(WBS_ID_WP,'')) WP, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC, SUM(ACWPi_dollars) ACWPc
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_CA, WBS_ID_WP, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END
	), CostWPs as (
		SELECT WP, EOC, SUM(ACWPc) ACWPc
		FROM Cost
		WHERE WP <> ''
		GROUP BY WP, EOC
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS, R.SubP, SUM(R.Performance) Performance, R.EOC
		FROM DS04_schedule S 
				INNER JOIN (
					SELECT task_ID, ISNULL(subproject_ID,'') SubP, EOC, SUM(actual_dollars) Performance 
					FROM DS06_schedule_resources 
					WHERE upload_ID = @upload_ID AND schedule_type = 'FC' 
					GROUP BY task_ID, EOC, ISNULL(subproject_ID,'')
				) R ON S.task_ID = R.task_ID AND ISNULL(S.subproject_ID,'') = R.SubP
		WHERE
				S.upload_ID = @upload_ID 
			AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, R.EOC, R.SubP
		HAVING SUM(R.Performance) > 0
	), FlagsByWBS as (
		SELECT S.WBS, SubP, S.EOC
		FROM ScheduleWBS S LEFT OUTER JOIN CostWPs C ON S.WBS = C.WP AND S.EOC = C.EOC
		WHERE C.ACWPc = 0 OR C.WP IS NULL
	), FlagsByTask as (
		SELECT S.task_ID, F.SubP, F.EOC
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTask F 	ON R.task_ID = F.task_ID 
															AND ISNULL(R.subproject_ID,'') = F.SubP
															AND R.EOC = F.EOC
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND actual_dollars > 0
		AND NOT EXISTS (SELECT 1 FROM Cost WHERE WP = '' GROUP BY CA HAVING SUM(ACWPc) > 0) --run only if Actuals are not collected at the CA level
)