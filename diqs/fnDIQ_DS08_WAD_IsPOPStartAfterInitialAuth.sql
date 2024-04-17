/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Start After Initial Auth Date</title>
  <summary>Is the POP start later than the initial auth date for the latest WAD revision?</summary>
  <message>pop_start_date &gt; initial_auth_date.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080433</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartAfterInitialAuth] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		W.*
	FROM 
		DS08_WAD W INNER JOIN LatestWPWADRev_Get(@upload_ID) R 	ON W.WBS_ID = R.WBS_ID
																AND ISNULL(W.WBS_ID_WP,'') = R.WBS_ID_WP
																AND W.auth_PM_date = R.PMAuth
	WHERE 
			upload_ID = @upload_ID
		AND pop_start_date >= initial_auth_date
)