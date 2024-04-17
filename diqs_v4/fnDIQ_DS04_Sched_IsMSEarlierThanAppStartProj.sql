/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Milestone Prior To Approve Start Project</title>
  <summary>Is this milestone earlier than the approve start project milestone?</summary>
  <message>Milestone has an early start date (ES_Date) prior to the approve start project milestone (milestone_level = 100).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040192</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsMSEarlierThanAppStartProj] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with MS100 as (
		SELECT ES_Date, schedule_type 
		FROM DS04_schedule 
		WHERE upload_ID = @upload_ID AND milestone_level = 100
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN MS100 M 	ON S.schedule_type = M.schedule_type 
											AND S.ES_date < M.ES_date
	WHERE
			upload_id = @upload_ID
		AND S.milestone_level <> 100
		AND S.milestone_level IS NOT NULL
)