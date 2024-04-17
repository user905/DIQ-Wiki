/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Start After Schedule Forecast Start (CA)</title>
  <summary>Is the POP Start for this Control Account WAD after the forecast start?</summary>
  <message>POP_start_date &gt; DS04.ES_date where schedule_type = BL (compare by DS08.WBS_ID, DS01.WBS_ID, DS01.parent_WBS_ID, &amp; DS04.WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080618</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartAfterDS04ESDateCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with SchedStart as (
		SELECT A.Ancestor_WBS_ID CAWBS, MIN(ES_date) ES
		FROM 
			DS04_schedule S INNER JOIN AncestryTree_Get(@upload_ID) A ON S.WBS_ID = A.WBS_ID
		WHERE
				S.upload_ID = @upload_ID
			AND A.[Type] IN ('WP','PP')
			AND A.Ancestor_Type IN ('CA','SLPP')
			AND S.schedule_type = 'BL'
		GROUP BY A.Ancestor_WBS_ID
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W 	INNER JOIN LatestCAWADRev_Get(@upload_ID) R ON W.WBS_ID = R.WBS_ID 
																AND W.auth_PM_date = R.PMauth
					INNER JOIN SchedStart S ON W.WBS_ID = S.CAWBS
											AND W.POP_start_date > S.ES
	WHERE
			W.upload_ID = @upload_ID
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = '' -- filter out WP-level WADs
)