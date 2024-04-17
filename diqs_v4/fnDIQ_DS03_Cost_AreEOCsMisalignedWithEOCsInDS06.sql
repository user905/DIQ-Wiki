/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>DELETED</status>
  <severity>WARNING</severity>
  <title>Cost EOCs Misaligned with Resource EOCs</title>
  <summary>Is the EOC combination for this WP or PP misaligned with the EOC combinations in the Resource (DS06)?</summary>
  <message>EOC combination for this WP or PP is misaligned with EOC combination in Resources (DS06).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030055</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_AreEOCsMisalignedWithEOCsInDS06] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with Resources As (
		SELECT
			S.WBS_ID, 
			R.EOC
		FROM 
			DS04_schedule S INNER JOIN DS06_schedule_resources R ON S.task_ID = R.task_ID
		WHERE
				S.upload_ID = @upload_ID
			AND R.upload_ID = @upload_ID
			AND S.schedule_type = 'BL'
			AND R.schedule_type = 'BL'
		GROUP BY
			S.WBS_ID, R.EOC
	)
	SELECT 
		C.* 
	FROM 
		DS03_Cost C LEFT OUTER JOIN Resources R ON C.WBS_ID_WP = R.WBS_ID AND C.EOC = R.EOC
	WHERE
			upload_ID = @upload_ID
		AND R.wbs_ID IS NULL
)