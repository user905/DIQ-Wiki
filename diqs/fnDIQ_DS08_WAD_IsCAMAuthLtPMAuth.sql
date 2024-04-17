/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>CAM Authorization After PM Authorization</title>
  <summary>Is the CAM authorization date later than the PM's?</summary>
  <message>auth_CAM_date &gt; auth_PM_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080405</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsCAMAuthLtPMAuth] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		*
	FROM
		DS08_WAD
	WHERE
			upload_ID = @upload_ID
		AND auth_CAM_date > auth_PM_date
)