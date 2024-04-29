/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>BCWS Misaligned With Cost (WP)</title>
  <summary>Is the cumulative budget for this subcontract misaligned with what is in cost?</summary>
  <message>BCWSc_dollars &lt;&gt; sum of DS03.BCWSi_dollars where EOC = Subcontract &amp; period_date &lt;= CPP_Status_Date (by FC DS04.WBS_ID &amp; DS03.WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9130521</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_IsBCWSMisalignedWithDS03] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with WPBCWSCost as (
		SELECT WBS_ID_WP, SUM(BCWSi_dollars) S
		FROM DS03_cost 
		WHERE upload_ID = @upload_ID AND EOC = 'Subcontract' AND period_date <= CPP_status_date
		GROUP BY WBS_ID_WP
	), WPBCWSSched as (
		SELECT WBS_ID, SUM(BCWSc_Dollars) S
		FROM DS04_schedule S INNER JOIN DS13_subK SK ON S.task_ID = SK.task_ID
		WHERE S.upload_ID = @upload_ID AND SK.upload_ID = @upload_ID AND S.schedule_type = 'FC'
		GROUP BY WBS_ID
	), ProblemWPs as (
		SELECT WBS_ID_WP
		FROM WPBCWSCost C INNER JOIN WPBCWSSched S ON C.WBS_ID_WP = S.WBS_ID
		WHERE C.S <> S.S
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