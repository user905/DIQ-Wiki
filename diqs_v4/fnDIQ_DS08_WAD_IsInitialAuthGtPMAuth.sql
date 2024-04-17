/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Initial Authorization After PM Authorization</title>
  <summary>Is the initial authorization date for this WAD after the PM date?</summary>
  <message>initial_auth_date &gt; auth_PM_date (for earliest WAD revision).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080411</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsInitialAuthGtPMAuth] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN EarliestWPWADRev_Get(@upload_ID) R ON W.WBS_ID = R.WBS_ID
																 AND ISNULL(W.WBS_ID_WP,'') = R.WBS_ID_WP
																 AND W.auth_PM_date = R.PMAuth
																 AND W.initial_auth_date > R.PMAuth
	WHERE
		upload_ID = @upload_ID  
)