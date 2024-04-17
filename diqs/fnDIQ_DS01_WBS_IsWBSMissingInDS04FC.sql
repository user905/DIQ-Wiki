/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS01 WBS</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP or PP Missing from Schedule (FC)</title>
  <summary>Is this WP or PP WBS ID missing in your forecast schedule?</summary>
  <message>WBS_ID where type = WP or PP missing in DS04.WBS_ID list where schedule_type = FC.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9010015</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS01_WBS_IsWBSMissingInDS04FC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		W.* 
	FROM 
		DS01_WBS W LEFT JOIN DS04_schedule S on W.WBS_ID = S.WBS_ID AND S.schedule_type = 'FC' AND S.upload_ID = @upload_ID
	WHERE 
			  W.upload_ID = @upload_ID 
    AND W.[type] in ('WP', 'PP')
    AND S.WBS_ID IS NULL
)