/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>Project-Level VAR Misaligned With Project-Level WBS</title>
  <summary>Is this project-level VAR not at Level 1 in the WBS Hierarchy?</summary>
  <message>narrative_type &lt; 200 &amp; DS01.level &gt; 1 (by WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9110490</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_IsProjectLevelVARMisalignedWithDS01Type] (
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
		AND CAST(ISNULL(narrative_type,'1000') as int) < 200 
		AND W.[level] <> 1
)