/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PP-Level VAR Mistype In WBS Dictionary</title>
  <summary>Is this PP-level VAR type as something other than PP in the WBS Dictionary?</summary>
  <message>narrative_type = 400 &amp; DS01.type &lt;&gt; PP (by WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9110489</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsPPVARMisalignedWithDS01Type] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT
		V.*
	FROM 
		DS11_variance V INNER JOIN DS01_WBS W ON V.WBS_ID = W.WBS_ID
	WHERE 
			V.upload_ID = @upload_ID
		AND W.upload_ID = @upload_ID
		AND narrative_type = '400'
		AND W.[type] <> 'PP'
)