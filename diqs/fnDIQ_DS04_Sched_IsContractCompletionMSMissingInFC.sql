/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Contract Completion Milestone Missing in Forecast</title>
  <summary>Is your forecast schedule missing the Contract Completion milestone?</summary>
  <message>No row found for Contract Completion milestone (milestone_level = 180) in forecast schedule (schedule_type = FC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1040163</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsContractCompletionMSMissingInFC] (
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
    (SELECT COUNT(*) FROM DS04_schedule WHERE upload_ID = @upload_ID AND schedule_type = 'FC' AND milestone_level = 180) = 0
)