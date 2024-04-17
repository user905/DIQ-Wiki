/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS06 Resources</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Material Resource with Missing or Numeric UOM</title>
  <summary>Does this material-type resource have missing or numeric UOM?</summary>
  <message>type = material where UOM is blank or numeric.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1060258</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS06_Res_IsMaterialTypeUOMMissingOrNumeric] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		*
	FROM
		DS06_schedule_resources
	WHERE
			upload_id = @upload_ID
		AND type = 'material'
		AND (TRIM(ISNULL(UOM,''))='' OR ISNUMERIC(UOM) = 1)
)