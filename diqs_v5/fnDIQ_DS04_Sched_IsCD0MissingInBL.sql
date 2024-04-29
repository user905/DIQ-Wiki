/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CD-0 Milestone Missing in Baseline</title>
  <summary>Is your baseline schedule missing the CD-0 milestone?</summary>
  <message>No row found for CD-0 milestone (milestone_level = 110) in baseline schedule (schedule_type = BL).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1040150</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsCD0MissingInBL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT * 
  FROM DummyRow_Get(@upload_ID)	
  WHERE 
    (SELECT COUNT(*) FROM DS04_schedule WHERE upload_ID = @upload_ID AND schedule_type = 'BL' AND milestone_level = 110) = 0
)