/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS14 HDV-CI</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Equipment ID Without SubK ID</title>
  <summary>Is there an equipment ID without a subcontract ID?</summary>
  <message>equipment_ID found while subK_ID is missing or blank.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1140540</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS14_HDV_CI_DoesEquipIDExistWithoutSubKId] (
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
		AND TRIM(equipment_ID) <> ''
		AND TRIM(ISNULL(subK_ID,'')) = ''
)