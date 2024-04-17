/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Schedule Missing Logic</title>
  <summary>Is schedule logic missing for either the BL or FC schedule?</summary>
  <message>Zero logic rows found for either the BL or FC schedule (schedule_type = BL or FC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1050233</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsScheduleMissingLogic] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
  with Logic as (
    SELECT schedule_type FROM DS05_schedule_logic WHERE upload_ID = @upload_ID
  )
	SELECT 
      * 
  FROM 
      DummyRow_Get(@upload_ID)	
  WHERE
          (SELECT COUNT(*) FROM Logic WHERE schedule_type = 'BL') = 0
      OR  (SELECT COUNT(*) FROM Logic WHERE schedule_type = 'FC') = 0
)