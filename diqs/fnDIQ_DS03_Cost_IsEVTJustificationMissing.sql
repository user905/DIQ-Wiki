/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>EVT Justification Missing</title>
  <summary>Is this WP or PP missing an EVT Justification?</summary>
  <message>EVT Justification is missing for EVT = B,G, H, J, L, M, N, O, or P.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030086</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsEVTJustificationMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE
			upload_ID = @upload_ID
		AND EVT IN ('B','G','H', 'J', 'L', 'M', 'N', 'O', 'P')
		AND TRIM(ISNULL(justification_EVT,''))=''
)