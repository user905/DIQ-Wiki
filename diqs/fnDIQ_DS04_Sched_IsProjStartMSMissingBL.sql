/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Approve Start Project Milestone Missing in Baseline</title>
  <summary>Is your baseline schedule missing the approve start project milestone?</summary>
  <message>No row found for approve start project milestone (milestone_level = 100) in baseline schedule (schedule_type = BL).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1040208</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsProjStartMSMissingBL] (
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
    (SELECT COUNT(*) FROM DS04_schedule WHERE upload_ID = @upload_ID AND schedule_type = 'BL' AND milestone_level = 100) = 0
)