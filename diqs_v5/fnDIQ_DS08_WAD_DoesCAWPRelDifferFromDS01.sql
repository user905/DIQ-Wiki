/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>CA &amp; WP Parent-Child Relationship Differs from WBS Hierarchy</title>
  <summary>Does the parent-child relationship for these CA &amp; WP WBS IDs differ from what's in the WBS hierarchy?</summary>
  <message>WBS_ID / WBS_ID_WP combo &lt;&gt; DS01.WBS_ID / parent_WBS_ID combo.</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080607</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_DoesCAWPRelDifferFromDS01] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN DS01_WBS WBS  ON W.WBS_ID_WP = WBS.WBS_ID
											AND W.WBS_ID <> WBS.parent_WBS_ID
	WHERE
			W.upload_ID = @upload_ID
		AND WBS.upload_ID = @upload_ID
)