/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Resource Performance without Cost Actuals (CA)</title>
  <summary>Has this resource recorded performance even though actuals are not recorded in cost (by EOC, at the CA level)?</summary>
  <message>Resource performance (actual_dollars) &gt; 0 even though DS03.ACWPc = 0 (SUM of ACWSi_dollars) by EOC (CA level).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060304</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_ArePDollarsMissingDS03ADollarsCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Cost as (
		SELECT WBS_ID_CA CA, TRIM(ISNULL(WBS_ID_WP,'')) WP, CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END as EOC, SUM(ACWPi_dollars) ACWPc
		FROM DS03_cost
		WHERE upload_ID = @upload_ID 
		GROUP BY WBS_ID_CA, TRIM(ISNULL(WBS_ID_WP,'')), CASE WHEN ISNULL(is_indirect,'') = 'Y' THEN 'Indirect' ELSE EOC END
	), CostCAs as (
		SELECT CA, EOC, SUM(ACWPc) ACWPc
		FROM Cost
		GROUP BY CA, EOC
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
	), WBSHierarchy as (
		SELECT WBS_ID, Ancestor_WBS_ID 
		FROM dbo.AncestryTree_Get(@upload_id)
		WHERE [Type] = 'WP' AND Ancestor_Type = 'CA'
	), ScheduleByCAs as (
		SELECT W.Ancestor_WBS_ID CAWBS, S.WBS, SubP, S.EOC
		FROM ScheduleWBS S INNER JOIN WBSHierarchy W ON S.WBS = W.WBS_ID
	), FlagsByWPWBS as (
		SELECT S.WBS, SubP, S.EOC
		FROM ScheduleByCAs S LEFT OUTER JOIN CostCAs C ON S.CAWBS = C.CA AND S.EOC = C.EOC
		WHERE C.CA IS NULL OR C.ACWPc = 0
	), FlagsByWPWBS_WithoutScenarioDWPs as (
		SELECT F.*
		FROM FlagsByWPWBS F INNER JOIN Cost C ON F.WBS = C.WP AND F.EOC = C.EOC
		WHERE C.WP <> '' AND C.ACWPc = 0
	), FlagsByTask as (
		SELECT S.task_ID, F.SubP, F.EOC
		FROM DS04_schedule S INNER JOIN FlagsByWPWBS_WithoutScenarioDWPs F ON S.WBS_ID = F.WBS AND ISNULL(S.subproject_ID,'') = F.SubP
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
		AND EXISTS (SELECT 1 FROM Cost WHERE WP = '' AND ACWPc > 0) --run only if Actuals are collected at the CA level
)