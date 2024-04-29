/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>SLPP with CAM Authorization</title>
  <summary>Does this SLPP WAD have a CAM authorization date?</summary>
  <message>auth_CAM_date found where DS01.type = SLPP (by WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080400</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_DoesSLPPHaveACAMAuthDate] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		WAD.*
	FROM
		DS08_WAD WAD INNER JOIN DS01_WBS WBS ON WAD.WBS_ID = WBS.WBS_ID
	WHERE
			WAD.upload_ID = @upload_ID
		AND WBS.upload_ID = @upload_ID
		AND WBS.[type] = 'SLPP'
		AND auth_CAM_date IS NOT NULL
)