/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Approve Finish Project Milestone Missing in Baseline</title>
  <summary>Is your baseline schedule missing the approve finish project milestone?</summary>
  <message>No row found for approve finish project milestone (milestone_level = 199) in baseline schedule (schedule_type = BL).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040206</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsProjFinishMSMissingBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
    * 
  FROM 
    DummyRow_Get(@upload_ID)	
  WHERE
    (SELECT COUNT(*) FROM DS04_schedule WHERE upload_ID = @upload_ID AND schedule_type = 'BL' AND milestone_level = 199) = 0
)