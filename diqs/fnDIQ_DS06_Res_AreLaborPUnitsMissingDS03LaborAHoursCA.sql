/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Resource Labor Performance without Cost Labor Actuals (CA)</title>
  <summary>Are there resource labor performance units recorded without labor actual hours in cost at the CA level?</summary>
  <message>Resource labor performance units &gt; 0 (actual_units where EOC or type = Labor) while cost labor actuals hours = 0 (SUM of DS03.ACWPi_hours where EOC = Labor) by WBS_ID_CA.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060303</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreLaborPUnitsMissingDS03LaborAHoursCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_CA WBS, SUM(ISNULL(ACWPi_hours,0)) AHours
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor' AND ISNULL(is_indirect,'') <> 'Y'
		GROUP BY WBS_ID_CA
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS, ISNULL(S.subproject_ID,'') SubP
		FROM DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID 
																 AND ISNULL(S.subproject_ID,'') = ISNULL(R.subproject_ID,'')
		WHERE	S.upload_ID = @upload_ID 
			AND R.upload_ID = @upload_ID
			AND R.schedule_type = 'FC'
			AND S.schedule_type = 'FC'
			AND (R.EOC = 'Labor' Or R.[type] = 'Labor')
		GROUP BY S.WBS_ID, ISNULL(S.subproject_ID,'')
		HAVING SUM(R.actual_units) > 0
	), WBSHierarchy as (
		SELECT WBS_ID, Ancestor_WBS_ID 
		FROM dbo.AncestryTree_Get(@upload_id)
		WHERE [Type] = 'WP' AND Ancestor_Type = 'CA'
	), ScheduleCAs as (
		SELECT W.Ancestor_WBS_ID CAWBS, SubP
		FROM ScheduleWBS S INNER JOIN WBSHierarchy W ON S.WBS = W.WBS_ID
		GROUP BY W.Ancestor_WBS_ID, SubP
	), FlagsByCAWBS as (
		SELECT S.CAWBS, SubP
		FROM ScheduleCAs S LEFT OUTER JOIN CostWBS C ON S.CAWBS = C.WBS
		WHERE C.AHours = 0 OR C.WBS IS NULL
	), FlagsByWPWBS as (
		SELECT S.WBS, S.SubP
		FROM WBSHierarchy W INNER JOIN ScheduleWBS S ON W.WBS_ID = S.WBS
		WHERE W.Ancestor_WBS_ID IN (SELECT CAWBS FROM FlagsByCAWBS)
	), FlagsByTask as (
		SELECT S.task_ID, F.SubP
		FROM DS04_schedule S INNER JOIN FlagsByWPWBS F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)
	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN FlagsByTask F ON R.task_ID = F.task_ID AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE 	R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
		AND EXISTS (
			SELECT 1 
			FROM DS03_cost 
			WHERE upload_ID = @upload_id AND TRIM(ISNULL(WBS_ID_WP,'')) = '' AND (ACWPi_dollars > 0 OR ACWPi_hours > 0 OR ACWPi_FTEs > 0)
		)
)