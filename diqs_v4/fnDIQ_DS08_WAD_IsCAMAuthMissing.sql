/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CAM Authorization Missing</title>
  <summary>Is a CAM authorization date missing for this non-SLPP WAD?</summary>
  <message>auth_CAM_date is null / blank where DS01.type &lt;&gt; SLPP (by WBS_ID or WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080406</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsCAMAuthMissing] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NoSLPP as (
		SELECT WBS_ID 
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID AND [type] <> 'SLPP'
	)
	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID
		AND (
			WBS_ID_WP IN (SELECT WBS_ID FROM NoSLPP) OR
			WBS_ID IN (SELECT WBS_ID FROM NoSLPP)
		)
		AND auth_CAM_date IS NULL
)