/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CAL ID Missing in Corrective Action Log</title>
  <summary>Is the CAL ID missing in the Corrective Action Log?</summary>
  <message>CAL_ID missing in DS12.CAL_ID list.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9110485</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsCALIDMissingInDS12] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with VARsByCAL as (
		SELECT WBS_ID, CAL_ID 
		FROM DS11_variance CROSS APPLY string_split(CAL_ID, ';')
		WHERE upload_ID = @upload_ID
	), Flags as (
		SELECT WBS_ID
		FROM VARsByCAL
		WHERE CAL_ID NOT IN (
			SELECT CAL_ID
			FROM DS12_variance_CAL
			WHERE upload_ID = @upload_ID
		)
	)
	SELECT
		*
	FROM 
		DS11_variance
	WHERE 
			upload_ID = @upload_ID
		AND WBS_ID IN (SELECT WBS_ID FROM Flags)
)