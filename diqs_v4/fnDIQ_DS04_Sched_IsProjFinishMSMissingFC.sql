/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Approve Finish Project Milestone Missing in Forecast</title>
  <summary>Is your forecast schedule missing the approve finish project milestone?</summary>
  <message>No row found for approve finish project milestone (milestone_level = 199) in forecast schedule (schedule_type = FC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040207</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsProjFinishMSMissingFC] (
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
    (SELECT COUNT(*) FROM DS04_schedule WHERE upload_ID = @upload_ID AND schedule_type = 'FC' AND milestone_level = 199) = 0	
)