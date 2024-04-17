/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Cost Labor Actuals without Resource Labor Performance (CA)</title>
  <summary>Are there labor actual hours in cost without labor performance units in resources? (CA)</summary>
  <message>Resource labor performance units = 0 (actual_units where EOC or type = Labor) while cost labor actuals hours &gt; 0 (SUM of DS03.ACWPi_hours where EOC = Labor) (Test runs at CA level).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060307</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreDS03LaborAHoursMissingResourceLaborPUnitsCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_CA CAWBS
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EOC = 'Labor' AND ISNULL(is_indirect,'') <> 'Y' AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		GROUP BY WBS_ID_CA
		HAVING SUM(ACWPi_hours) > 0
	), Resources as (
		SELECT task_ID, ISNULL(subproject_ID,'') SubP, SUM(ISNULL(actual_units,0)) ResLbrUnits
		FROM DS06_schedule_resources
		WHERE upload_ID = @upload_id AND schedule_type = 'FC' AND (EOC = 'Labor' Or [type] = 'Labor')
		GROUP BY task_ID, ISNULL(subproject_ID,'')
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS, ISNULL(S.subproject_ID,'') SubP, SUM(ISNULL(ResLbrUnits,0)) LbrUnits
		FROM DS04_schedule S LEFT OUTER JOIN Resources R ON S.task_ID = R.task_ID AND ISNULL(S.subproject_ID,'') = R.SubP
		WHERE S.upload_ID = @upload_id AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, ISNULL(S.subproject_ID,'')
	), WBSHierarchy as (
		SELECT WBS_ID, Ancestor_WBS_ID 
		FROM dbo.AncestryTree_Get(@upload_id)
		WHERE [Type] = 'WP' AND Ancestor_Type = 'CA'
	), ScheduleCAs as (
		SELECT W.Ancestor_WBS_ID CAWBS, SubP, SUM(S.LbrUnits) LbrUnits
		FROM ScheduleWBS S INNER JOIN WBSHierarchy W ON S.WBS = W.WBS_ID
		GROUP BY W.Ancestor_WBS_ID, SubP
	), FlagsByCAWBS as (
		SELECT S.CAWBS, S.SubP
		FROM ScheduleCAs S INNER JOIN CostWBS C ON C.CAWBS = S.CAWBS
        WHERE S.LbrUnits = 0
	), FlagsByWPWBS as (
		SELECT S.WBS, S.SubP
		FROM WBSHierarchy W INNER JOIN ScheduleWBS S ON W.WBS_ID = S.WBS
		WHERE W.Ancestor_WBS_ID IN (SELECT CAWBS FROM FlagsByCAWBS)
	), FlagsByTaskID as (
		SELECT S.task_ID, F.SubP
		FROM DS04_schedule S INNER JOIN FlagsByWPWBS F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
	)
	SELECT
		R.*
	FROM
		DS06_schedule_resources R INNER JOIN FlagsByTaskID F ON R.task_ID = F.task_ID AND ISNULL(R.subproject_ID,'') = F.SubP
	WHERE
			R.upload_id = @upload_ID
		AND R.schedule_type = 'FC'
		AND (R.EOC = 'Labor' OR R.[type] = 'Labor')
)