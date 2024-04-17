/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS07 IPMR Header</table>
  <status>DELETED</status>
  <severity>ERROR</severity>
  <title>Multi-Row IPMR Header</title>
  <summary>Is there more than one row in the IPMR header?</summary>
  <message>DS07 row count &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1070388</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS07_IPMR_IsIPMRMultiRow] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS07_IPMR_header
	WHERE
			upload_ID = @upload_ID
		AND (SELECT COUNT(*) FROM DS07_IPMR_header WHERE upload_ID = @upload_ID) > 1
)