/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>EAC Misaligned With Cost (CA)</title>
  <summary>Is the estimate at completion for this subcontract misaligned with what is in cost?</summary>
  <message>EAC_dollars &lt;&gt; sum of DS03.ACWPi_dollars + DS03.ETCi_dollars where EOC = Subcontract (by DS01.WBS_ID, DS01.parent_WBS_ID, FC DS04.WBS_ID, &amp; DS03.WBS_ID_CA).</message>
  <param name="@upload_Id">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9130528</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsEACMisalignedWithDS03CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CAEACCost as (
		SELECT WBS_ID_CA, SUM(ISNULL(ACWPi_dollars,0) + ISNULL(ETCi_dollars,0)) EAC
		FROM DS03_cost 
		WHERE upload_ID = @upload_Id AND EOC = 'Subcontract'
		GROUP BY WBS_ID_CA
	), WPEACSched as (
		SELECT WBS_ID, SUM(EAC_dollars) EAC
		FROM DS04_schedule S INNER JOIN DS13_subK SK ON S.task_ID = SK.task_ID
		WHERE S.upload_ID = @upload_Id AND SK.upload_ID = @upload_Id AND S.schedule_type = 'FC'
		GROUP BY WBS_ID
	), CAEACSched as (
		SELECT A.Ancestor_WBS_ID CAWBS, SUM(S.EAC) EAC
		FROM WPEACSched S INNER JOIN AncestryTree_Get(@upload_Id) A ON S.WBS_ID = A.WBS_ID
		WHERE A.[Type] = 'WP' AND A.Ancestor_Type = 'CA'
		GROUP BY A.Ancestor_WBS_ID
	), ProblemCAs as (
		SELECT WBS_ID_CA
		FROM CAEACCost C INNER JOIN CAEACSched S ON C.WBS_ID_CA = S.CAWBS
		WHERE C.EAC <> S.EAC
	), ProblemTasks as (
		SELECT S.task_ID
		FROM DS04_schedule S INNER JOIN AncestryTree_Get(@upload_Id) A ON S.WBS_ID = A.Ancestor_WBS_ID
		WHERE S.upload_ID = @upload_Id AND S.schedule_type = 'FC' AND A.[Type] = 'WP' AND A.Ancestor_Type = 'CA'
		AND A.Ancestor_WBS_ID IN (SELECT WBS_ID_CA FROM ProblemCAs)
	)
	SELECT
		SK.*
	FROM 
		DS13_subK SK INNER JOIN ProblemTasks P ON SK.task_ID = P.task_ID
	WHERE 
			SK.upload_ID = @upload_Id
		AND EXISTS ( -- run only if ACWP is at the CA level
			SELECT 1 
			FROM DS03_cost 
			WHERE upload_ID = @upload_Id AND TRIM(ISNULL(WBS_ID_WP,'')) = '' AND ACWPi_Dollars > 0
		) 
)