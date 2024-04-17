/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Resource Role Missing Name</title>
  <summary>Is this resource role missing a name?</summary>
  <message>role_ID is not blank &amp; role_name is blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060253</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsResourceRoleMissingName] (
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
		AND TRIM(ISNULL(role_ID,'')) <> ''
		AND TRIM(ISNULL(role_name,''))=''
)