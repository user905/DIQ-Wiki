/*
<documentation>
  <author>Elias Cooper</author>
  <table>DS03 Cost</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>WP / PP EVT Misaligned with WAD</title>
  <summary>Is the EVT for this WP or PP misaligned with the EVT in the WAD?</summary>
  <message>DS03.EVT &lt;&gt; DS08.EVT (by WBS_ID_WP).</message>
  <grouping>WBS_ID,WBS_ID_WP</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9030324</UID>
</documentation>
*/
CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_IsEVTMisalignedWithDS08] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(
	with CostEVTGrps as (
		SELECT 
			WBS_ID_WP,
			CASE
				WHEN EVT IN ('B', 'C', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P') THEN 'Discrete'
				WHEN EVT = 'A' THEN 'LOE'
				WHEN EVT IN ('J', 'M') THEN 'Apportioned'
				WHEN EVT = 'K' THEN 'PP'
				ELSE ''
			END as EVT
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
	), CostEVT as (
		SELECT WBS_ID_WP, EVT
		FROM CostEVTGrps
		GROUP BY WBS_ID_WP, EVT
	), WADEVT as (
		SELECT 
			W.WBS_ID_WP, 
			CASE
				WHEN EVT IN ('B', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P') THEN 'Discrete'
				WHEN EVT = 'A' THEN 'LOE'
				WHEN EVT IN ('J', 'M') THEN 'Apportioned'
				WHEN EVT = 'K' THEN 'PP'
				ELSE ''
			END as EVT
		FROM DS08_WAD W INNER JOIN LatestWPWADRev_Get(@upload_ID) R ON W.WBS_ID_WP = R.WBS_ID_WP 
																	AND W.auth_PM_date = R.PMAuth
		WHERE W.upload_ID = @upload_ID AND TRIM(ISNULL(W.WBS_ID_WP,'')) <> ''
	), Flags as (
		SELECT C.WBS_ID_WP
		FROM CostEVT C INNER JOIN WADEVT W 	ON C.WBS_ID_WP = W.WBS_ID_WP
											AND C.EVT <> W.EVT
		)
		SELECT 
			* 
		FROM 
			DS03_Cost
		WHERE
				upload_ID = @upload_ID
			AND WBS_ID_WP IN (SELECT WBS_ID_WP FROM Flags)
			AND (--Run the check only if WADs are at the WP/PP level.
				SELECT COUNT(*) 
				FROM DS08_WAD 
				WHERE upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) <> ''
			) > 0
)