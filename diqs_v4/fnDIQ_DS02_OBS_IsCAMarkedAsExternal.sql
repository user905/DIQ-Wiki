/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS02 OBS</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>CA Marked as External</title>
  <summary>Is this CA marked as external?</summary>
  <message>CA is marked as external.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9020041</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS02_OBS_IsCAMarkedAsExternal] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
			O.* 
	FROM 
			DS02_OBS O
				INNER JOIN DS01_WBS W ON O.OBS_ID = W.OBS_ID
	WHERE	O.upload_ID = @upload_ID
			AND TRIM(O.OBS_ID)<>'' 
			AND O.OBS_ID IS NOT NULL
			AND O.[external] = 'Y'
			AND W.type = 'CA'
)