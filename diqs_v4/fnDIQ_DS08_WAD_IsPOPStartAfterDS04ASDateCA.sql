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
  <table>DS08 WAD</table>
  <status>TEST</status>
  <severity>WARNING</severity>
  <type>Performance</type>
  <title>POP Start After Schedule Actual Start (CA)</title>
  <summary>Is the POP Start for this CA WAD after the schedule actual start?</summary>
  <message>POP_start_date &gt; DS04.AS_date where schedule_type = FC (compare by DS08.WBS_ID, DS01.WBS_ID, DS01.parent_WBS_ID, &amp; DS04.WBS_ID).</message>
  <param name="@upload_ID">The unique identifier of the PARS CPP Upload on which this DIQ check will run.</param>
  <returns>Rows of data that fail the DIQ check</returns>
  <UID>9080616</UID>
</documentation>
*/

CREATE FUNCTION [dbo].[fnDIQ_DS08_WAD_IsPOPStartAfterDS04ASDateCA] (
	@upload_id int = 0
)
RETURNS TABLE
AS RETURN
(



	/*
		This function looks for CA WADs where POP Start > BL DS04.AS Date (by WBS ID).

		Use a cte, SchedStart, to collect min BL AS Dates by CA/SLPP IDs 
		using a join between DS04 & AncestryTree_Get.

		Then join to DS08 and compare. 
		Use LatestCAWADRev to compare only to the latest WAD revision.
	*/
	with SchedStart as (
		--Get the first BL ES date by CA/SLPP ID from DS04 joined to AncestryTree.
		SELECT A.Ancestor_WBS_ID CAWBS, MIN(AS_date) ActS
		FROM 
			DS04_schedule S INNER JOIN AncestryTree_Get(@upload_ID) A ON S.WBS_ID = A.WBS_ID
		WHERE
				S.upload_ID = @upload_ID
			AND A.[Type] IN ('WP','PP')
			AND A.Ancestor_Type IN ('CA','SLPP')
			AND S.schedule_type = 'FC'
		GROUP BY A.Ancestor_WBS_ID
	)

	SELECT 
		W.*
	FROM
		DS08_WAD W 	INNER JOIN LatestCAWADRev_Get(@upload_ID) R ON W.WBS_ID = R.WBS_ID AND W.auth_PM_date = R.PMauth
					INNER JOIN SchedStart S ON W.WBS_ID = S.CAWBS
	WHERE
			W.upload_ID = @upload_ID
		AND TRIM(ISNULL(W.WBS_ID_WP,'')) = '' -- filter out WP-level WADs
		AND W.POP_start_date > S.ActS
)