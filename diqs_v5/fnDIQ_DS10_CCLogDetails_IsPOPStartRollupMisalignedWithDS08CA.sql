/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS10 CC Log Detail</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>POP Start Misaligned with WAD (CA)</title>
  <summary>Is the POP start for this Control Account misaligned with what is in the WAD?</summary>
  <message>POP_start_date &lt;&gt; DS08.POP_start_date (select latest revision; check is on CA level).</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9100477</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS10_CCLogDetails_IsPOPStartRollupMisalignedWithDS08CA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	WITH WADStart AS (
		SELECT 
			W.WBS_ID, POP_start_date
		FROM 
			DS08_WAD W INNER JOIN (
					SELECT WBS_ID, MAX(auth_PM_date) AS lastPMAuth
					FROM DS08_WAD
					WHERE upload_ID = @upload_ID
					GROUP BY WBS_ID
				) LastRev 	ON W.WBS_ID = LastRev.WBS_ID 
							AND W.auth_PM_date = LastRev.lastPMAuth
	), CACCLog AS (
		SELECT A.Ancestor_WBS_ID CAWBS, MIN(POP_start_date) PopStart
		FROM DS10_CC_log_detail L INNER JOIN AncestryTree_Get(@upload_ID) A ON L.WBS_ID = A.WBS_ID
		WHERE L.upload_ID = @upload_ID AND A.[Type] IN ('WP','PP') AND A.Ancestor_Type IN ('CA','SLPP')
		GROUP BY A.Ancestor_WBS_ID
	), FlagsByCAWBS AS (
		SELECT W.WBS_ID
		FROM WADStart W INNER JOIN CACCLog C ON W.WBS_ID = C.CAWBS
		WHERE W.POP_start_date <> C.PopStart
	), FlagsByWPWBS AS (
		SELECT A.WBS_ID
		FROM FlagsByCAWBS F INNER JOIN AncestryTree_Get(@upload_ID) A ON F.WBS_ID = A.Ancestor_WBS_ID
		WHERE A.[Type] IN ('WP','PP') AND A.Ancestor_Type IN ('CA','SLPP')
	)
	SELECT 
		L.*
	FROM 
		DS10_CC_log_detail L INNER JOIN FlagsByWPWBS F ON L.WBS_ID = F.WBS_ID
	WHERE 
		upload_ID = @upload_ID
)