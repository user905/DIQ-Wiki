/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS14 HDV-CI</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>HDV-CI Missing in Schedule (FC)</title>
  <summary>Is the HDV-CI missing in the forecast schedule?</summary>
  <message>HDV_CI_ID not in DS04.HDV_CI_ID list where schedule_type = FC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9140545</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS14_HDV_CI_IsHDVCIMissingInDS04FC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS14_HDV_CI
	WHERE 
			upload_ID = @upload_ID 
		AND HDV_CI_ID NOT IN (
			SELECT HDV_CI_ID 
			FROM DS04_schedule
			WHERE upload_ID = @upload_ID AND schedule_type = 'FC'
		)
)