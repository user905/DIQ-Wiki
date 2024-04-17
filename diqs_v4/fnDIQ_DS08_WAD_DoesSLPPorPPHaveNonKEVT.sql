/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>SLPP or PP WAD with Inappropriate EVT</title>
  <summary>Is EVT for this SLPP or WP-level WAD something other than K?</summary>
  <message>EVT &lt;&gt; K for SLPP or PP WAD (by DS01.WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080401</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_DoesSLPPorPPHaveNonKEVT] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with PPs as (
		SELECT WBS_ID, type
		FROM DS01_WBS
		WHERE upload_ID = @upload_ID AND type IN ('SLPP','PP')
	)
	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID   
		AND (
			WBS_ID IN (SELECT WBS_ID FROM PPs WHERE type = 'SLPP') OR
			WBS_ID_WP IN (SELECT WBS_ID FROM PPs WHERE type = 'PP') 
		)
		AND ISNULL(EVT,'') <> 'K'
)