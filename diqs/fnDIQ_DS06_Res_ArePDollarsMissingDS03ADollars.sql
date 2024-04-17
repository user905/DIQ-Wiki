/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>DELETED</status>
  <severity>ALERT</severity>
  <title>Resource Performance without Cost Actuals</title>
  <summary>Has this resource recorded performance even though actuals are not recorded in cost (by EOC)?</summary>
  <message>Resource performance (actual_dollars) &gt; 0 even though DS03.ACWPc = 0 (SUM of ACWSi_dollars) by EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060286</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollars] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_WP WBS, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC
		FROM DS03_cost
		WHERE upload_ID = @upload_ID
		GROUP BY WBS_ID_WP, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END
		HAVING SUM(ACWPi_dollars) = 0
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS, R.SubP, SUM(R.Performance) Performance, R.EOC
		FROM 
			DS04_schedule S 
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
		SELECT S.WBS, S.EOC, S.SubP
		FROM ScheduleWBS S INNER JOIN  CostWBS C ON C.EOC = S.EOC
												AND C.WBS = S.WBS
	), FlagsByTask as (
		SELECT S.task_ID, F.EOC, F.SubP
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
)