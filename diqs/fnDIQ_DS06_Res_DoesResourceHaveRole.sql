/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Resource With Role</title>
  <summary>Does this resource have a resource ID and a role ID?</summary>
  <message>Resource item found with both a resource and role ID (resource_ID and role_ID are not blank).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060250</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_DoesResourceHaveRole] (
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
		AND role_ID IS NOT NULL
		AND resource_ID IS NOT NULL
)