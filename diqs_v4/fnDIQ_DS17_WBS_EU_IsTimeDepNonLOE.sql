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
  <table>DS17 WBS EU</table>
  <status>TEST</status>
  <severity>ALERT</severity>
  <title>Non-LOE Time Dependence</title>
  <summary>Is this time dependent WBS non-LOE in cost?</summary>
  <message>time_dependent = Y &amp; DS03.EVT &lt;&gt; A (by WBS_ID).</message>
  <grouping>WBS_ID</grouping>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9170581</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS17_WBS_EU_IsTimeDepNonLOE] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for WBS EU rows where time_dependent = Y & DS03.EVT <> A by WBS_ID.
		We do this by collecting Cost WPs that are of type LOE (EVT = A is loe).

		We then join this back to DS17, using a left join, 
		and filter for any rows that did not match (WBS_ID_WP is null).
	*/

	with CostLOE as (
		SELECT WBS_ID_WP
		FROM DS03_cost
		WHERE upload_ID = @upload_ID AND EVT = 'A'
		GROUP BY WBS_ID_WP
	)

	SELECT 
		E.*
	FROM 
		DS17_WBS_EU E LEFT OUTER JOIN CostLOE C ON E.WBS_ID = C.WBS_ID_WP
	WHERE 
			upload_ID = @upload_ID
		AND time_dependent = 'Y'
		AND TRIM(ISNULL(C.WBS_ID_WP,'')) = ''
)