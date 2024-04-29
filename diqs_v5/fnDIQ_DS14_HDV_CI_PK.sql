/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS14 HDV-CI</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate HDV-CI ID</title>
  <summary>Is the HDV-CI duplicated?</summary>
  <message>Count of HDV_CI_ID &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1140543</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS14_HDV_CI_PK] (
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
		AND HDV_CI_ID IN (
			SELECT HDV_CI_ID 
			FROM DS14_HDV_CI 
			WHERE upload_ID = @upload_ID 
			GROUP BY HDV_CI_ID 
			HAVING COUNT(*) > 1
		)
)