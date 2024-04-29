/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>BCWP Misaligned With Cost (WP)</title>
  <summary>Is the performance for this subcontract misaligned with what is in cost?</summary>
  <message>BCWPc_dollars &lt;&gt; sum of DS03.BCWPi_dollars where EOC = Subcontract (by FC DS04.WBS_ID &amp; DS03.WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9130520</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsBCWPMisalignedWithDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WPBCWPCost as (
		SELECT WBS_ID_WP, SUM(BCWPi_dollars) P
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID AND EOC = 'Subcontract'
		GROUP BY WBS_ID_WP
	), WPBCWPSched as (
		SELECT WBS_ID, SUM(BCWPc_Dollars) P
		FROM DS04_schedule S INNER JOIN DS13_subK SK ON S.task_ID = SK.task_ID
		WHERE S.upload_ID = @upload_ID AND SK.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY WBS_ID
	), ProblemWPs as (
		SELECT WBS_ID_WP
		FROM WPBCWPCost C INNER JOIN WPBCWPSched S ON C.WBS_ID_WP = S.WBS_ID
		WHERE C.P <> S.P
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