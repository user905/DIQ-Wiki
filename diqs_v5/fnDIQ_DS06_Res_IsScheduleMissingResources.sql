/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Schedule Missing Resources</title>
  <summary>Is either the BL or FC schedule missing resources?</summary>
  <message>Zero resource rows found for either the BL or FC schedule (schedule_type = BL or FC).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <dummy>YES</dummy>
  <UID>1060254</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsScheduleMissingResources] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
  with Res as (
    SELECT DISTINCT schedule_type
    FROM DS06_schedule_resources
    WHERE upload_ID = @upload_id
  )
	SELECT 
      * 
  FROM 
      DummyRow_Get(@upload_ID)	
  WHERE
		(SELECT COUNT(*) FROM Res WHERE schedule_type = 'BL') = 0 OR
		(SELECT COUNT(*) FROM Res WHERE schedule_type = 'FC') = 0
)