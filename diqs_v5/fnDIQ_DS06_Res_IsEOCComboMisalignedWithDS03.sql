/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>EOC Combo Misaligned with Cost</title>
  <summary>Is the combo of resource EOCs for this task/WBS misaligned with what is in cost?</summary>
  <message>Combo of resource EOCs for this DS04.task's WBS ID do not align with combo of DS03 EOCs.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060294</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsEOCComboMisalignedWithDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostEOCs as (
		SELECT C.WBS, EOC
		FROM (
			SELECT WBS_ID_WP WBS, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC
			FROM DS03_cost
			WHERE upload_ID = @upload_ID
			GROUP BY WBS_ID_WP, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END
		) C
		GROUP BY C.WBS, C.EOC
	), ScheduleEOCs as (
		SELECT S.WBS, SubP, S.EOC
		FROM (
			SELECT S.WBS_ID WBS, ISNULL(R.EOC,'') EOC, ISNULL(S.subproject_ID,'') SubP
			FROM DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID AND ISNULL(S.subproject_ID,'') = ISNULL(R.subproject_ID,'')
			WHERE 	S.upload_ID = @upload_ID 
				AND R.upload_ID = @upload_ID
				AND R.schedule_type = 'BL'
				AND S.schedule_type = 'BL'
			GROUP BY S.WBS_ID, R.EOC, ISNULL(S.subproject_ID,'')
		) S
		GROUP BY S.WBS, SubP, S.EOC
	), FlagsByWBS as (
		SELECT S.WBS, S.SubP, S.EOC
		FROM ScheduleEOCs S 
		WHERE NOT EXISTS (
		 	SELECT 1 FROM CostEOCs C WHERE S.WBS = C.WBS AND S.EOC = C.EOC
		)	
	), FlagsByTask as (
		SELECT S.task_ID, F.SubP, F.EOC
		FROM DS04_schedule S INNER JOIN FlagsByWBS F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
		WHERE upload_ID = @upload_ID AND schedule_type = 'BL'
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTask F ON R.task_ID = F.task_ID AND ISNULL(R.EOC,'') = F.EOC AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'BL'
)