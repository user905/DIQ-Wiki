/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>EAC Misaligned With Cost (WP)</title>
  <summary>Is the estimate at completion for this subcontract misaligned with what is in cost?</summary>
  <message>EAC_dollars &lt;&gt; sum of DS03.ACWPi_dollars + DS03.ETCi_dollars where EOC = Subcontract (by FC DS04.WBS_ID &amp; DS03.WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9130529</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsEACMisalignedWithDS03WP] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WPEACCost as (
		SELECT WBS_ID_WP, SUM(ISNULL(ACWPi_dollars,0) + ISNULL(ETCi_dollars,0)) EAC
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID AND EOC = 'Subcontract'
		GROUP BY WBS_ID_WP
	), WPEACSched as (
		SELECT WBS_ID, SUM(EAC_dollars) EAC
		FROM DS04_schedule S INNER JOIN DS13_subK SK ON S.task_ID = SK.task_ID
		WHERE S.upload_ID = @upload_ID AND SK.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY WBS_ID
	), ProblemWPs as (
		SELECT WBS_ID_WP
		FROM WPEACCost C INNER JOIN WPEACSched S ON C.WBS_ID_WP = S.WBS_ID
		WHERE C.EAC <> S.EAC
	), ProblemTasks as (
		SELECT S.task_ID
		FROM DS04_schedule S INNER JOIN ProblemWPs P ON S.WBS_ID = P.WBS_ID_WP
		WHERE S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
	)
	SELECT
		SK.*
	FROM 
		DS13_subK SK INNER JOIN ProblemTasks P ON SK.task_ID = P.task_ID
	WHERE 
		SK.upload_ID = @upload_ID 
)