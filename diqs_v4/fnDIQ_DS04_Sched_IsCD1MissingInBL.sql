/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CD-1 Milestone Missing in Baseline</title>
  <summary>Is your baseline schedule missing the CD-1 milestone?</summary>
  <message>No row found for CD-1 milestone (milestone_level = 120) in baseline schedule (schedule_type = BL).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040152</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsCD1MissingInBL] (
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
    (SELECT COUNT(*) FROM DS04_schedule WHERE upload_ID = @upload_ID AND schedule_type = 'BL' AND milestone_level = 120) = 0
)