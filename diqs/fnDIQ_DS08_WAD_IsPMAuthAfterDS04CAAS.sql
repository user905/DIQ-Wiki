/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>PM Authorization After CA Actual Start</title>
  <summary>Is the PM authorization date for this Control Account WAD later than the CA's Actual Start date?</summary>
  <message>auth_PM_date &gt; DS04.AS_date (by WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080425</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPMAuthAfterDS04CAAS] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CAActStart as (
		SELECT A.CAWBS, MIN(S.AS_date) ActStart
		FROM
			(
				SELECT WBS_ID WBS, AS_date 
				FROM DS04_schedule 
				WHERE upload_ID = @upload_ID AND AS_date IS NOT NULL AND schedule_type = 'FC'
			) S INNER JOIN 
			(
				SELECT Ancestor_WBS_ID CAWBS, WBS_ID WBS 
				FROM AncestryTree_Get(@upload_ID) 
				WHERE type = 'WP' AND Ancestor_Type = 'CA'
			) A ON S.WBS = A.WBS
		GROUP BY A.CAWBS
	), WADByMinAuth as (
		SELECT WBS_ID CAWBS, MIN(auth_PM_date) PMAuth
		FROM DS08_WAD
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) = ''
		GROUP BY WBS_ID
	), Composite as (
		SELECT W.CAWBS, W.PMAuth, C.ActStart
		FROM WADByMinAuth W INNER JOIN CAActStart C ON W.CAWBS = C.CAWBS
	)
	SELECT 
		W.*
	FROM
		DS08_WAD W INNER JOIN Composite C 	ON W.WBS_ID = C.CAWBS 
											AND W.auth_PM_date = C.PMAuth
											AND W.auth_PM_date > C.ActStart
	WHERE
			upload_ID = @upload_ID  
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = ''
)