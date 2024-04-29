/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS14 HDV-CI</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Subcontract ID Missing in Subcontract Work Records</title>
  <summary>Is the subcontract ID missing in the subcontract dataset?</summary>
  <message>subK_ID not in DS14.subK_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9140546</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS14_HDV_CI_IsSubKMissingInDS13] (
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
		AND subK_ID NOT IN (
			SELECT subK_ID
			FROM DS13_subK
			WHERE upload_ID = @upload_ID
		)
)