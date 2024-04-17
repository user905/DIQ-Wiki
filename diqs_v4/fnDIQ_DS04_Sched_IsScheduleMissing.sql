/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Schedule Missing</title>
  <summary>Is your schedule data missing either the BL or FC schedule?</summary>
  <message>Zero rows found in either the BL or FC schedule (schedule_type = BL or FC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040210</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsScheduleMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
  with Tasks as (
    SELECT distinct schedule_type
    FROM DS04_schedule
    WHERE upload_ID=@upload_id
  )
	SELECT 
    * 
  FROM 
    DummyRow_Get(@upload_ID)	
  WHERE
    (SELECT COUNT(*) FROM Tasks WHERE schedule_type = 'BL') = 0 OR
		(SELECT COUNT(*) FROM Tasks WHERE schedule_type = 'FC') = 0
)