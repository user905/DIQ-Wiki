/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CA WBS Matches WP WBS</title>
  <summary>Do the CA &amp; WP WBS IDs match?</summary>
  <message>WBS_ID_CA = WBS_ID_WP</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060269</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsCAWBSEqTWPWBS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT * 
	FROM DS03_Cost
	WHERE upload_ID = @upload_ID AND TRIM(WBS_ID_CA) = TRIM(WBS_ID_WP)
)