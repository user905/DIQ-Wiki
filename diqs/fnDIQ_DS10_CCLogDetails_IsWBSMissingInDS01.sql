/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WBS Missing In WBS Dictionary</title>
  <summary>Is this WBS ID missing in the WBS Dictionary?</summary>
  <message>WBS_ID missing in DS01.WBS_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100479</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsWBSMissingInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM 
		DS10_CC_log_detail
	WHERE 
		upload_ID = @upload_Id
	AND WBS_ID NOT IN (
		SELECT WBS_ID FROM DS01_WBS WHERE upload_ID = @upload_Id
	)
)