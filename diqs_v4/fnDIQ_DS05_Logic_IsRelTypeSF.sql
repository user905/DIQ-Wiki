/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS05 Schedule Logic</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Start-Finish Relationship</title>
  <summary>Is this a start-finish relationship?</summary>
  <message>Relationship type is start-finish (type = SF).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1050235</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS05_Logic_IsRelTypeSF] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS05_schedule_logic
	WHERE
			upload_ID = @upload_ID
		AND type = 'SF'
)