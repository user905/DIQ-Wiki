/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Inconsistent Initial Authorization Date</title>
  <summary>Is the initial authorization date consistent across revisions?</summary>
  <message>initial_auth_date differs across revisions (by WAD_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080412</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsInitialAuthInconsistent] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		W1.*
	FROM
		DS08_WAD W1 INNER JOIN DS08_WAD W2 	ON W1.WBS_ID = W2.WBS_ID
											AND ISNULL(W1.WBS_ID_WP,'') = ISNULL(W2.WBS_ID_WP,'')
											AND W1.revision <> W2.revision
											AND W1.initial_auth_date <> W2.initial_auth_date
	WHERE
			W1.upload_ID = @upload_ID  
		AND	W2.upload_ID = @upload_ID  
)