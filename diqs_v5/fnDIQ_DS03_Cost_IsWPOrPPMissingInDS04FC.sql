/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP or PP Missing In FC Schedule</title>
  <summary>Is this WP or PP missing in the FC Schedule?</summary>
  <message>WBS_ID_WP missing from DS04.WBS_ID list (where schedule_type = FC).</message>
  <grouping>WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030072</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsWPOrPPMissingInDS04FC] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT C.*
	FROM DS03_Cost C
	LEFT JOIN DS04_schedule S ON C.WBS_ID_WP = S.WBS_ID AND S.upload_ID = @upload_ID AND S.schedule_type = 'FC'
	WHERE C.upload_ID = @upload_ID AND S.WBS_ID IS NULL
)