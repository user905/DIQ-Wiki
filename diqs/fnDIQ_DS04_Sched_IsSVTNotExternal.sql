/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Non-External SVT</title>
  <summary>Is this SVT not marked as external in the WBS dictionary (DS01)?</summary>
  <message>SVT (subtype = SVT) is not marked as external in the WBS dictionary (DS01.external = N).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9040213</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_IsSVTNotExternal] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with NonExt as (
		SELECT WBS_ID, [external] 
		FROM DS01_WBS 
		WHERE upload_ID = @upload_ID AND [external] = 'N'
	)
	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN NonExt E ON S.WBS_ID = E.WBS_ID
	WHERE
			upload_id = @upload_ID
		AND ISNULL(S.subtype,'') = 'SVT'
)