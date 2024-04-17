/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM Authorization After Earliest Recorded CA Performance or Actuals</title>
  <summary>Is the PM authorization date for this Control Account later than the CA' first recorded instance of either actuals or performance?</summary>
  <message>auth_PM_date &gt; minimum DS03.period_date where ACWPi or BCWPi &gt; 0 (by WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080423</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPMAuthAfterDS03CAAS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CAActStart as (
		SELECT WBS_ID_CA CAWBS, MIN(period_date) ActStart
		FROM DS03_cost
		WHERE 
				upload_ID = @upload_ID 
			AND (
				ACWPi_dollars <> 0 OR ACWPi_dollars <> 0 OR ACWPi_hours <> 0 OR
				BCWPi_dollars <> 0 OR BCWPi_dollars <> 0 OR BCWPi_hours <> 0
			)
		GROUP BY WBS_ID_CA
	), WADByMinAuth as (
		SELECT WBS_ID, MIN(auth_PM_date) PMAuth
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		GROUP BY WBS_ID
	), Composite as (
		SELECT W.WBS_ID, W.PMAuth, C.ActStart
		FROM WADByMinAuth W INNER JOIN CAActStart C ON W.WBS_ID = C.CAWBS
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN Composite C 	ON W.WBS_ID = C.WBS_ID 
											AND W.auth_PM_date = C.PMAuth
											AND W.auth_PM_date > C.ActStart
	WHERE
			upload_ID = @upload_ID
		AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
)