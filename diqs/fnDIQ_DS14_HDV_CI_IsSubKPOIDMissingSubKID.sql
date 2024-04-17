/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS14 HDV-CI</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Subcontract PO ID Missing Subcontract ID</title>
  <summary>Is there a subcontract PO ID without a subcontract ID?</summary>
  <message>subK_PO_ID found but subK_ID is missing or blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1140547</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS14_HDV_CI_IsSubKPOIDMissingSubKID] (
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
		AND TRIM(ISNULL(subK_PO_ID,'')) <> ''
		AND TRIM(ISNULL(subK_ID,'')) = ''
)