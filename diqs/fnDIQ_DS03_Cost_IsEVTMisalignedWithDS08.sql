/*

The name of the function should include the ID and a short title, for example: DIQ0001_WBS_Pkey or DIQ0003_WBS_Single_Level_1

author is your name.

id is the unique DIQ ID of this test. Should be an integer increasing from 1.

table is the table name (flat file) against which this test runs, for example: "FF01_WBS" or "FF26_WBS_EU".
DIQ tests might pull data from multiple tables but should only return rows from one table (split up the tests if needed).
This value is the table from which this row returns tests.

status should be set to TEST, LIVE, SKIP.
TEST indicates the test should be run on test/development DIQ checks.
LIVE indicates the test should run on live/production DIQ checks.
SKIP indicates this isn't a test and should be skipped.

severity should be set to WARNING or ERROR. ERROR indicates a blocking check that prevents further data processing.

summary is a summary of the check for a technical audience.

message is the error message displayed to the user for the check.

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
	/*
		Looks for WP/PP data where DS03.EVT = DS08.EVT (by WBS_ID_WP).
	*/
	with CostEVTGrps as (
		-- set DS03 EVT groups by WP/PP WBS
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
		-- group DS03 cost EVT by WP/PP WBS
		-- (this *is* doable in the above, but a separate cte is much neater)
		SELECT WBS_ID_WP, EVT
		FROM CostEVTGrps
		GROUP BY WBS_ID_WP, EVT
	), WADEVT as (
		-- get DS08 EVT for the last WAD revision
		-- use case to get the EVT by its EVT group
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
		-- join the above by WBS ID & compare EVTs
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