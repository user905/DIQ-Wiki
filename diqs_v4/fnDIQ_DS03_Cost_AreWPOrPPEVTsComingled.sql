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
  <severity>ERROR</severity>
  <title>WP or PP with Multiple EVT Groups</title>
  <summary>Does this WP or PP have more than one EVT group?</summary>
  <message>WP or PP where EVT group is not uniform (EVTs are not all LOE, Discrete, Apportioned, or Planning Package for this WP or PP data).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>1030072</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS03_Cost_AreWPOrPPEVTsComingled] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This test looks for WP/PPs with more than one EVT group (see the DID for the four groups).
		It does not discriminate by period_date.
		It uses a cte, EVTGroups, to return the WP WBS ID, EOC, and EVT group for each row.
		It then compares the EVT groups for each WP/EOC combo in Flags by joining EVTGroups to itself.

		The final query joins Flags back to DS03 to get the rows that fail the test.
	*/

	with EVTGroups as (
		-- WP WBS & EOC by EVTs by group
		SELECT 
			WBS_ID_WP, 
			CASE
				WHEN EVT IN ('B', 'C', 'D', 'E', 'F', 'G', 'H', 'L', 'N', 'O', 'P') THEN 'Discrete'
				WHEN EVT = 'A' THEN 'LOE'
				WHEN EVT IN ('J', 'M') THEN 'Apportioned'
				WHEN EVT = 'K' THEN 'PP'
				ELSE ''
			END as EVT
		FROM
			DS03_cost
		WHERE
			upload_ID = @upload_ID AND TRIM(ISNULL(WBS_ID_WP,'')) <> '' AND TRIM(ISNULL(EVT,'')) <> ''
	), Flags AS (
		--Compare. Group by WBS ID to return only distinct WBS IDs
		--that fail the test.
		SELECT G1.WBS_ID_WP
		FROM EVTGroups G1 INNER JOIN EVTGroups G2 	ON G1.WBS_ID_WP = G2.WBS_ID_WP
													AND G1.EVT <> G2.EVT
		GROUP BY G1.WBS_ID_WP
	)

	SELECT 
		C.* 
	FROM 
		DS03_Cost C INNER JOIN Flags F 	ON C.WBS_ID_WP = F.WBS_ID_WP 
	WHERE
		upload_ID = @upload_ID
)