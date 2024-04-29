/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>HDV CI ID Missing in HDV CI List</title>
  <summary>Is this HDV CI ID missing in the HDV CI list (DS14)?</summary>
  <message>HDV CI ID missing in the HDV CI list (DS14).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040182</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsHDVCIIDMissingInDS14] (
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
		AND TRIM(ISNULL(HDV_CI_ID,'')) <> ''
		AND HDV_CI_ID NOT IN (SELECT HDV_CI_ID FROM DS14_HDV_CI WHERE upload_ID = @upload_ID)
)