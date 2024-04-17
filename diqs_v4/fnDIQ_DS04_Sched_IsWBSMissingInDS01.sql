/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WBS Missing in WBS Dictionary</title>
  <summary>Is this WBS ID missing in the WBS Dictionary?</summary>
  <message>WBS_ID is missing in DS01.WBS_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040222</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsWBSMissingInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS04_schedule 
	WHERE
			upload_id = @upload_ID
		AND WBS_ID NOT IN (SELECT WBS_ID FROM DS01_WBS WHERE upload_ID = @upload_ID)
)