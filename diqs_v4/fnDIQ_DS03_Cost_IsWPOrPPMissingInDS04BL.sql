/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP or PP Missing In BL Schedule</title>
  <summary>Is this WP or PP missing in the BL Schedule?</summary>
  <message>WBS_ID_WP missing from DS04.WBS_ID list (where schedule_type = BL).</message>
  <grouping>WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030102</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsWPOrPPMissingInDS04BL] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS03_Cost C
	WHERE 
			C.upload_ID = @upload_ID
		AND C.WBS_ID_WP NOT IN (
			SELECT WBS_ID 
			FROM DS04_schedule 
			WHERE upload_ID = @upload_ID AND schedule_type = 'BL')
)