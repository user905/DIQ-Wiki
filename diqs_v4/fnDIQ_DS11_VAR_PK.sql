/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS11 Variance</table>
  <status>TEST</status>
  <severity>ERROR</severity>
  <title>Duplicate VAR</title>
  <summary>Is this VAR duplicated by WBS ID &amp; Narrative type?</summary>
  <message>Count of WBS_ID &amp; narrative_type combo &gt; 1.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1110495</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS11_VAR_PK] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
  with Dupes as (
    SELECT WBS_ID, ISNULL(narrative_type,'') narrative_type
    FROM DS11_variance
    WHERE upload_ID = @upload_ID
    GROUP BY WBS_ID, ISNULL(narrative_type,'')
    HAVING COUNT(*) > 1
  )
	SELECT
		V.*
	FROM 
		DS11_variance V INNER JOIN Dupes D ON V.WBS_ID = D.WBS_ID 
                                      AND ISNULL(V.narrative_type,'') = D.narrative_type
	WHERE 
			upload_ID = @upload_ID
)