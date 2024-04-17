/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Repeat PM Authorization Date Across Revisions</title>
  <summary>Do multiple revisions share the same PM authorization date?</summary>
  <message>auth_PM_date repeated where revisions are not the same (by WBS_ID &amp; WBS_ID_WP).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1080428</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPMAuthRepeatedAcrossRevisions] (
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
											AND W1.auth_PM_date = W2.auth_PM_date
	WHERE
			W1.upload_ID = @upload_ID
		AND	W2.upload_ID = @upload_ID
)