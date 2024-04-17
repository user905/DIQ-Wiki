/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>CV Root Cause Narrative Missing CAL Cost Narrative</title>
  <summary>Is this CVi or CVc VAR narrative missing a corrective action log entry with a cost narrative?</summary>
  <message>narrative_RC_CVc or narrative_RC_CVi found without DS12.narrative_cost (by CAL_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9110496</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsCVNarrMissingDS12CostNarr] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with VARsByCAL as (
		SELECT WBS_ID, CAL_ID 
		FROM DS11_variance CROSS APPLY string_split(CAL_ID, ';')
		WHERE 
				upload_ID = @upload_ID 
			AND (TRIM(ISNULL(narrative_RC_CVi,'')) <> '' OR TRIM(ISNULL(narrative_RC_CVc,'')) <> '')
	), Flags as (
		SELECT V.WBS_ID
		FROM VARsByCAL V LEFT OUTER JOIN DS12_variance_CAL C ON V.CAL_ID = C.CAL_ID
		WHERE 
				C.upload_ID = @upload_ID 
			AND (TRIM(ISNULL(C.narrative_cost,'')) = '' OR C.CAL_ID IS NULL)
	)
	SELECT
		*
	FROM 
		DS11_variance
	WHERE 
			upload_ID = @upload_ID
		and WBS_ID IN (SELECT WBS_ID FROM Flags)
)