/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Missing Resource &amp; Role ID</title>
  <summary>Is this resource missing both a resource and role ID?</summary>
  <message>Resource missing both resource_ID and role_ID (resource_ID and role_ID = null or blank).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060245</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsResourceAndRoleIDMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS06_schedule_resources
	WHERE
			upload_id = @upload_ID
		AND TRIM(ISNULL(resource_ID,'')) = ''
		AND TRIM(ISNULL(role_ID,'')) = ''
)