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
  <table>DS04 Schedule</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <title>LOE Mingled With Other EVT Types</title>
  <summary>Is LOE mingled with other EVT types for this WBS?</summary>
  <message>LOE (EVT = LOE) is mingled with other EVT types (EVT &lt;&gt; LOE) for this WBS_ID.</message>
  <grouping>WBS_ID, schedule_type</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1040186</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS04_Sched_AreEVTsComingled] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WBS_IDs where EVTs are mixed within a WBS ID.

		Since EVTs are grouped, this is not a simple 1:1 comparison. Groupings are:
		1. Discrete - B, C, D, E, F, G, H, L, N, O, P
		2. LOE - A
		3. Apportioned - J, M
		4. Planning Package - K

		To handle this, we create a cte, EVTGroups, that reformats EVTs according to these groups.
		We then join EVTGroups to itself by WBS ID & schedule_type in Flags and filter for discrepancies.

		Any rows in Flags are problem WBSs.

		Join these back to DS04 by schedule type to return problem data.
	*/

	with EVTGroups as (
		-- WBS IDs, schedule type, and EVTs by group
		SELECT 
			WBS_ID, 
			schedule_type,
			CASE
				WHEN EVT IN ('B', 'C', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P') THEN 'Discrete'
				WHEN EVT = 'A' THEN 'LOE'
				WHEN EVT IN ('J', 'M') THEN 'Apportioned'
				WHEN EVT = 'K' THEN 'PP'
			END as EVT
		FROM DS04_schedule
		WHERE upload_ID = @upload_ID AND TRIM(ISNULL(EVT, '')) <> ''
	), Flags AS (
		--Compare. Group by WBS ID & schedule_type to return only distinct WBS IDs by schedule type
		--that fail the test.
		SELECT G1.WBS_ID, G1.schedule_type
		FROM EVTGroups G1 INNER JOIN EVTGroups G2 	ON G1.WBS_ID = G2.WBS_ID 
													AND G1.schedule_type = G2.schedule_type
													AND G1.EVT <> G2.EVT
		WHERE G1.EVT <> '' AND G2.EVT <> ''
		GROUP BY G1.WBS_ID, G1.schedule_type
	)

	SELECT
		S.*
	FROM
		DS04_schedule S INNER JOIN Flags F ON S.WBS_ID = F.WBS_ID AND S.schedule_type = F.schedule_type
	WHERE
		upload_id = @upload_ID

)