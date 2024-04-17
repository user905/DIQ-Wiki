/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP WAD Mistyped In WBS Dictionary</title>
  <summary>Is this WP WAD type as something other than WP or PP in the WBS dictionary?</summary>
  <message>DS01.type &lt;&gt; WP or PP for this WBS_ID.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080623</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsWPWBSMistypedInDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN DS01_WBS WBS ON W.WBS_ID_WP = WBS.WBS_ID
	WHERE
			W.upload_ID = @upload_ID
		AND WBS.upload_ID = @upload_ID
		AND type NOT IN ('WP','PP')
)