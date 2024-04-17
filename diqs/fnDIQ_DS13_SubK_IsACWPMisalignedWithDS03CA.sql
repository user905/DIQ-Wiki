/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>ACWP Misaligned With Cost (CA)</title>
  <summary>Are the actuals for this subcontract misaligned with what is in cost?</summary>
  <message>ACWPc_dollars &lt;&gt; sum of DS03.ACWPi_dollars where EOC = Subcontract (by DS01.WBS_ID, DS01.parent_WBS_ID, FC DS04.WBS_ID, &amp; DS03.WBS_ID_CA).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9130514</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsACWPMisalignedWithDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CAACWPCost as (
		SELECT WBS_ID_CA, SUM(ACWPi_dollars) A
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID AND EOC = 'Subcontract'
		GROUP BY WBS_ID_CA
	), WPACWPSched as (
		SELECT WBS_ID, SUM(ACWPc_Dollars) A
		FROM DS04_schedule S INNER JOIN DS13_subK SK ON S.task_ID = SK.task_ID
		WHERE S.upload_ID = @upload_ID AND SK.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY WBS_ID
	), CAACWPSched as (
		SELECT A.Ancestor_WBS_ID CAWBS, SUM(W.A) A
		FROM WPACWPSched W INNER JOIN AncestryTree_Get(@upload_ID) A ON W.WBS_ID = A.WBS_ID
		WHERE A.[Type] = 'WP' AND A.Ancestor_Type = 'CA'
		GROUP BY A.Ancestor_WBS_ID
	), ProblemCAs as (
		SELECT WBS_ID_CA
		FROM CAACWPCost C INNER JOIN CAACWPSched S ON C.WBS_ID_CA = S.CAWBS
		WHERE C.A <> S.A
	), ProblemTasks as (
		SELECT S.task_ID
		FROM DS04_schedule S INNER JOIN AncestryTree_Get(@upload_ID) A ON S.WBS_ID = A.Ancestor_WBS_ID
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC' AND A.[Type] = 'WP' AND A.Ancestor_Type = 'CA'
		AND A.Ancestor_WBS_ID IN (SELECT WBS_ID_CA FROM ProblemCAs)
	)
	SELECT
		SK.*
	FROM 
		DS13_subK SK INNER JOIN ProblemTasks P ON SK.task_ID = P.task_ID
	WHERE 
			SK.upload_ID = @upload_ID 
)