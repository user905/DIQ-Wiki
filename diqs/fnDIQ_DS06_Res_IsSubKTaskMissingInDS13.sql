/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Subcontract Resource Missing in SubK List</title>
  <summary>Is this subcontract resource missing in the subcontract list?</summary>
  <message>Subcontract EOC task_id (EOC = subcontract) missing in DS13.task_ID list.</message>
  <grouping>task_ID, EOC</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9060295</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsSubKTaskMissingInDS13] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with SubKs as (
		SELECT task_ID
		FROM DS13_subK
		WHERE upload_ID = @upload_ID
	)
	SELECT
		*
	FROM
		DS06_schedule_resources
	WHERE
			upload_id = @upload_ID
		AND EOC = 'subcontract'
		AND task_ID NOT IN (SELECT task_ID FROM SubKs)
		AND (SELECT COUNT(*) FROM SubKs) > 0 --run only if data exists in DS13
)