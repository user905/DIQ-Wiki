/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS13 Subcontract</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate Subcontract Task</title>
  <summary>Is this subcontract task duplicated by subcontract ID, subcontract PO ID, &amp; task ID?</summary>
  <message>Count of subK_id, subK_task_id, &amp; task_ID combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1130538</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS13_SubK_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Dupes as (
		SELECT subK_id, subK_task_id, task_ID
		FROM DS13_subK
		WHERE upload_ID = @upload_ID
		GROUP BY subK_id, subK_task_id, task_ID
		HAVING COUNT(*) > 1
	)
	SELECT
		S.*
	FROM 
		DS13_subK S INNER JOIN Dupes D 	ON S.subK_id = D.subK_id 
										AND S.subK_task_id = D.subK_task_id 
										AND S.task_ID = D.task_ID
	WHERE 
		upload_ID = @upload_ID 
)