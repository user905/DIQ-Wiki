/*
<documentation>
  <author>Elias Cooper</author>
  <id>20</id>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Exit Criteria Missing</title>
  <summary>Is the Exit Criteria missing?</summary>
  <message>exit_criteria required where type = CA or SLPP. Provide if available for type = WBS, WP, or PP.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1010018</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsExitCriteriaMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS01_WBS
	WHERE 
			upload_ID = @upload_ID
		AND TRIM(ISNULL(exit_criteria,''))=''
)