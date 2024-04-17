/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Resource Missing EOC</title>
  <summary>Is this resource lacking an EOC?</summary>
  <message>EOC missing (where resource_ID is not blank).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060265</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsResourceMissingEOC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT *
	FROM DS06_schedule_resources
	WHERE upload_id = @upload_ID AND ISNULL(resource_ID,'') <> '' AND ISNULL(eoc,'') = ''
)