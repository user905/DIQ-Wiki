/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Cost Actuals without Resource Performance (CA)</title>
  <summary>Are there actuals in cost without performance in resources (by CA WBS &amp; EOC)?</summary>
  <message>Resource performance (actual_dollars) = 0 even though DS03.ACWPc &gt; 0 (SUM of ACWSi_dollars) by WBS_ID_CA &amp; EOC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060306</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_AreDS03ADollarsMissingResourcePDollarsCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostWBS as (
		SELECT WBS_ID_CA CAWBS, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC, SUM(ACWPi_dollars) ACWP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		GROUP BY WBS_ID_CA, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END
		HAVING SUM(ACWPi_dollars) > 0
	), Resources as (
		SELECT task_ID, EOC, ISNULL(subproject_ID,'') SubP, SUM(ISNULL(actual_dollars,0)) Performance 
		FROM DS06_schedule_resources 
		WHERE upload_ID = @upload_ID AND schedule_type = 'FC' 
		GROUP BY task_ID, EOC, ISNULL(subproject_ID,'')
	), ScheduleWBS as (
		SELECT S.WBS_ID WBS, R.EOC, R.SubP
		FROM DS04_schedule S INNER JOIN Resources R ON S.task_ID = R.task_ID AND ISNULL(S.subproject_ID,'') = R.SubP
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY S.WBS_ID, R.EOC, R.SubP
        HAVING SUM(R.Performance) = 0
	), WBSHierarchy as (
		SELECT WBS_ID, Ancestor_WBS_ID
		FROM dbo.AncestryTree_Get(@upload_id)
		WHERE [Type] = 'WP' AND Ancestor_Type = 'CA'
	), ScheduleCAs as (
		SELECT W.Ancestor_WBS_ID CAWBS, SubP, EOC
		FROM ScheduleWBS S INNER JOIN WBSHierarchy W ON S.WBS = W.WBS_ID
		GROUP BY W.Ancestor_WBS_ID, SubP, EOC
	), FlagsByCAWBS as (
		SELECT S.CAWBS, SubP
		FROM ScheduleCAs S INNER JOIN CostWBS C ON S.CAWBS = C.CAWBS AND S.EOC = C.EOC
	), FlagsByWPWBS as (
		SELECT S.WBS, S.SubP, S.EOC
		FROM WBSHierarchy W INNER JOIN ScheduleWBS S ON W.WBS_ID = S.WBS
		WHERE W.Ancestor_WBS_ID IN (SELECT CAWBS FROM FlagsByCAWBS)
	), FlagsByTaskID as (
		SELECT S.task_ID, F.EOC, F.SubP
		FROM FlagsByWPWBS F INNER JOIN DS04_schedule S ON F.WBS = S.WBS_ID
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
	)
	SELECT R.*
	FROM DS06_schedule_resources R INNER JOIN FlagsByTaskID F ON R.task_ID = F.task_ID
															AND ISNULL(subproject_ID,'') = F.SubP
															AND R.EOC = F.EOC
	WHERE R.upload_id = @upload_ID AND R.schedule_type = 'FC'
)