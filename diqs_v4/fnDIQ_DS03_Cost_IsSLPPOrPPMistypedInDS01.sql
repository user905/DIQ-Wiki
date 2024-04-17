/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>SLPP or PP Type Mismatch with DS01 (WBS)</title>
  <summary>Is this SLPP or PP mistyped in DS01 (WBS)?</summary>
  <message>EVT = K but DS01 (WBS) type is not SLPP or PP. (Note: This flag also appears if DS01 type = PP but no WP ID is missing and if type = SLPP but a WP ID was found.)</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030096</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsSLPPOrPPMistypedInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with ToTest AS (
		SELECT WBS_ID, type 
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID
	)
	SELECT 
		* 
	FROM 
		DS03_Cost
	WHERE 
			upload_ID = @upload_ID
		AND EVT = 'K'
		AND (
			(ISNULL(WBS_ID_WP,'') = '' AND WBS_ID_CA IN (Select WBS_ID FROM ToTest WHERE type <> 'SLPP')) OR
			(ISNULL(WBS_ID_WP,'') <> '' AND WBS_ID_WP IN (SELECT WBS_ID FROM ToTest WHERE type <> 'PP'))
		)
)